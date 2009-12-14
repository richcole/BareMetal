; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; Screen Output Functions
; =============================================================================

align 16
db 'DEBUG: SCREEN   '
align 16


; -----------------------------------------------------------------------------
; os_move_cursor -- Moves cursor in text mode
;  IN:	AH  = row
;	AL  = column
; OUT:	All registers preserved
os_move_cursor:
	push rdx
	push rcx
	push rbx
	push rax

	mov [screen_cursor_x], ah
	mov [screen_cursor_y], al
	push rax
	and rax, 0x000000000000FFFF	; only keep the low 16 bits
	;calculate the new offset
	mov cl, 80
	mul cl				; AX = AL * CL
	xor rbx, rbx
	mov bl, [screen_cursor_x]
	add ax, bx
	shl ax, 1			; multiply by 2
	add rax, 0x00000000000B8000
	mov [screen_cursor_offset], rax
	pop rax				; Move the hardware cursor
	mov bh, ah
	mov bl, al
	xor ax, ax
	mov al, 0x50
	mul bl				; bl * al = ax
	movzx bx, bh
	add bx, ax
	mov al, 0x0E
	mov ah, bh
	mov dx, 0x03D4
	out dx, ax
	inc ax
	mov ah, bl
	out dx, ax	

	pop rax
	pop rbx
	pop rcx
	pop rdx
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_inc_cursor -- Increment the hardware cursor by one
;  IN:	Nothing
; OUT:	All registers preserved
os_inc_cursor:
	push rax

	mov ah, [screen_cursor_x]	; grab the current cursor location values
	mov al, [screen_cursor_y]
	inc ah
	cmp ah, [screen_cols]		; 80
	jne os_inc_cursor_done
	xor ah, ah
	inc al
	cmp al, [screen_rows]		; 25
	jne os_inc_cursor_done
	call os_scroll_screen		; we are on the last column of the last row (bottom right) so we need to scroll the screen up by one line
	mov ah, 0x00			; now reset the cursor to be in the first colum of the last row (bottom left)
	mov al, [screen_rows]
	dec al

os_inc_cursor_done:
	call os_move_cursor

	pop rax
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_dec_cursor -- Decrement the hardware cursor by one
;  IN:	Nothing
; OUT:	All registers preserved
os_dec_cursor:
	push rax

	mov ah, [screen_cursor_x]	; Get the current cursor location values
	mov al, [screen_cursor_y]
	cmp ah, 0			; Check if the cursor in located on the first column?
	jne os_dec_cursor_done
	dec al				; Wrap the cursor back to the above line
	mov ah, [screen_cols]

os_dec_cursor_done:
	dec ah
	call os_move_cursor

	pop rax
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_print_newline -- Reset cursor to start of next line and scroll if needed
;  IN:	Nothing
; OUT:	All registers perserved
os_print_newline:
	push rax

	mov ah, 0			; Set the cursor x value to 0
	mov al, [screen_cursor_y]	; Grab the cursor y value
	cmp al, 24			; Compare to see if we are on the last line
	je os_print_newline_scroll	; If so then we need to scroll the sreen
	inc al				; If not then we can go ahead an increment the y value
	jmp os_print_newline_done

os_print_newline_scroll:
	call os_scroll_screen

os_print_newline_done:
	call os_move_cursor		; update the cursor

	pop rax
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_print_string -- Displays text
;  IN:	RSI = message location (zero-terminated string)
; OUT:	All registers perserved
os_print_string:
	push rsi
	push rax

	cld				; Clear the direction flag.. we want to increment through the string
os_print_string_nextchar:
	lodsb				; Get char from string and store in AL
	cmp al, 0			; Strings are Zero terminated.
	je os_print_string_done		; If char is Zero then it is the end of the string
	cmp al, 10			; Check if there was a newline character in the string
	je os_print_string_newline	; If so then we print a new line
	cmp al, 13			; Check if there was a newline character in the string
	je os_print_string_newline	; If so then we print a new line
	mov rdi, [screen_cursor_offset]
	stosb				; Write the char to the screen
	mov al, 0x07			; Default of light grey on black
	stosb				; Write the attrib to the screen
	call os_inc_cursor
	jmp os_print_string_nextchar

os_print_string_newline:
	call os_print_newline
	jmp os_print_string_nextchar

os_print_string_done:
	pop rax
	pop rsi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_print_string_with_color -- Displays text with color
;  IN:	RSI = message location (zero-terminated string)
;	BL  = color
; OUT:	All registers perserved
os_print_string_with_color:
	push rsi
	push rax

	cld					; Clear the direction flag.. we want to increment through the string
os_print_string_with_color_nextchar:
	lodsb					; Get char from string and store in AL
	cmp al, 0				; Strings are Zero terminated.
	je os_print_string_with_color_done	; If char is Zero then it is the end of the string
	cmp al, 13				; Check if there was a newline character in the string
	je os_print_string_with_color_newline	; If so then we print a new line
	mov rdi, [screen_cursor_offset]
	stosb					; Write the char to the screen
	mov al, bl
	stosb					; Write the attrib to the screen
	call os_inc_cursor
	jmp os_print_string_with_color_nextchar

os_print_string_with_color_newline:
	call os_print_newline
	jmp os_print_string_with_color_nextchar

os_print_string_with_color_done:
	pop rax
	pop rsi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_print_char -- Displays a char
;  IN:	AL  = char to display
; OUT:	All registers perserved
os_print_char:
	push rdi

	mov rdi, [screen_cursor_offset]
	stosb
	push ax
	mov al, 0x07		; Default of light grey on black
	stosb
	pop ax
	call os_inc_cursor

	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_print_char_with_color -- Displays a char with color
;  IN:	AL  = char to display
;	BL  = color
; OUT:	All registers perserved
os_print_char_with_color:
	push rdi

	mov rdi, [screen_cursor_offset]
	stosb
	xchg al, bl
	stosb
	xchg al, bl
	call os_inc_cursor

	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_print_char_hex -- Displays a char in hex mode
;  IN:	AL  = char to display
; OUT:	All registers perserved
os_print_char_hex:
	push rbx
	push rax

	mov rbx, hextable

	push rax	; save rax for the next part
	shr al, 4	; we want to work on the high part so shift right by 4 bits
	xlatb
	call os_print_char

	pop rax
	and al, 0x0f	; we want to work on the low part so clear the high part
	xlatb
	call os_print_char

	pop rax
	pop rbx
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_scroll_screen -- Scrolls the screen up by one line
;  IN:	Nothing
; OUT:	All registers perserved
os_scroll_screen:
	push rsi
	push rdi
	push rcx
	push rax

	cld				; Clear the direction flag.. we want to increment through the string
	mov rsi, 0x00000000000B80A0	; start of video text memory for row 2
	mov rdi, 0x00000000000B8000	; start of video text memory
	mov rcx, 0x0000000000000780	; Set to repeat 1920 times (80x24)
	rep movsw
; now we need to clear the last line in video memory
	mov ax, 0x0720			;0x00 characteristic	00 actual diplayed character (char 0x20 is a space)
	mov rdi, 0x00000000000B8F00
	mov rcx, 0x0000000000000050	; Set to repeat 80 times
	rep stosw

	pop rax
	pop rcx
	pop rdi
	pop rsi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_hide_cursor -- Turns off cursor in text mode
;  IN:	Nothing
; OUT:	All registers perserved
os_hide_cursor:
	push rdx
	push rbx
	push rax

	mov dx, 0x03d4
	mov ax, 0x000a		; Cursor Start Register
	out dx, ax
	inc dx
	xor ax, ax
	in al, dx
	mov bl, al
	or bl, 00100000b	; Bit 5 set to 1 to disable cursor
	dec dx
	mov ax, 0x000a		; Cursor Start Register
	out dx, ax
	inc dx
	mov al, bl
	out dx, al

	pop rax
	pop rbx
	pop rdx
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_show_cursor -- Turns on cursor in text mode
;  IN:	Nothing
; OUT:	All registers perserved
os_show_cursor:
	push rdx
	push rbx
	push rax

	mov dx, 0x03d4
	mov ax, 0x000a		; Cursor Start Register
	out dx, ax
	inc dx
	xor ax, ax
	in al, dx
	mov bl, al
	and bl, 11011111b	; Bit 5 set to 0 to enable cursor
	dec dx
	mov ax, 0x000a		; Cursor Start Register
	out dx, ax
	inc dx
	mov al, bl
	out dx, al

	pop rax
	pop rbx
	pop rdx
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
