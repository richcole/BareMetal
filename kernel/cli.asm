; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; COMMAND LINE INTERFACE
; =============================================================================

align 16
db 'DEBUG: CLI      '
align 16


os_command_line:
	mov rsi, prompt			; Prompt for input
	mov bl, 0x0C			; Black background, Light Red text
	call os_print_string_with_color

	mov rdi, tempstring		; Get string from user
	mov rcx, 255			; Limit the capture of characters to 255
	call os_input_string

	push rdi
	mov rsi, newline
	call os_print_string
	pop rsi

	cmp rcx, 0			; If just enter pressed, prompt again
	je os_command_line

	call os_string_chomp		; Remove leading and trailing spaces
	call os_string_uppercase	; Convert to uppercase for comparison

	mov rdi, help_string		; 'HELP' entered?
	call os_string_compare
	jc near print_help

	mov rdi, cls_string		; 'CLS' entered?
	call os_string_compare
	jc near clear_screen

	mov rdi, ver_string		; 'VER' entered?
	call os_string_compare
	jc near print_ver

	mov rdi, dir_string		; 'DIR' entered?
	call os_string_compare
	jc near dir

	mov rdi, date_string		; 'DATE' entered?
	call os_string_compare
	jc near date

	mov rdi, time_string		; 'TIME' entered?
	call os_string_compare
	jc near time

	mov rdi, testzone_string	; 'TESTZONE' entered?
	call os_string_compare
	jc near testzone

	mov rdi, reboot_string		; 'REBOOT' entered?
	call os_string_compare
	jc near reboot

	mov rdi, debug_string		; 'DEBUG' entered?
	call os_string_compare
	jc near debug

	mov rdi, exit_string		; 'EXIT' entered?
	call os_string_compare
	jc near exit

	mov al, '.'
	call os_find_char_in_string	; User entered dot in filename?
	cmp rax, 0
	je notadot			; If not, see if it's 11 chars
	dec rax
	jmp padout			; Otherwise, make sure it's padded out

notadot:
	call os_string_length

	cmp rax, 11
	je near full_name
	jg near fail

padout:
	add rsi, rax			; Pad with spaces and 'BIN'

bitmore:
	cmp rax, 8
	jge suffix
	mov byte [rsi], ' '
	inc rsi
	inc rax
	jmp bitmore

suffix:
	mov byte [rsi], 'A'		; So sloppy!!
	inc rsi
	mov byte [rsi], 'P'
	inc rsi
	mov byte [rsi], 'P'
	inc rsi
	mov byte [rsi], 0		; Zero-terminate string

full_name:
	mov rsi, tempstring

	call findfile			; Fuction will return the starting cluster value in ebx or 0 if not found
	cmp ax, 0x0000			; If ebx is 0 then the file was not found
	je fail				; bail out if the file was not found

	mov rdi, programlocation	; We load the program to this location in memory (currently 0x00100000 : at the 2MB mark)
readfile_getdata:
	call readcluster		; store in memory
	cmp ax, 0xFFFF
	jne readfile_getdata		; Are there more clusters? If so then read again.. if not fall through.

	call programlocation		; 0x00100000 : at the 2MB mark

	jmp os_command_line		; After the program is finished we go back to the start of the CLI

fail:					; We didn't get a valid command or program name
	mov rsi, not_found_msg
	call os_print_string
	jmp os_command_line

print_help:
	mov rsi, help_text
	call os_print_string
	jmp os_command_line

clear_screen:
	mov rdi, 0x00000000000B8000	; memory address of color video
	mov ax, 0x0720			; 0x07 for black background/white foreground, 0x20 for space (black) character
	mov cx, 0x4000
	rep stosw			; clear the screen, Store word in AX to RDI CX times
	mov ax, 0x0018
	call os_move_cursor
	jmp os_command_line

print_ver:
	mov rsi, version_msg
	call os_print_string
	jmp os_command_line

dir:
	mov rdi, tempstring
	call os_fat16_get_file_list
	call os_print_string
	jmp os_command_line

date:
	mov rdi, tempstring
	call os_get_date_string
	mov rsi, rdi
	call os_print_string
	call os_print_newline
	jmp os_command_line

time:
	mov rdi, tempstring
	call os_get_time_string
	mov rsi, rdi
	call os_print_string
	call os_print_newline
	jmp os_command_line

align 16
poomsg db 'OMG TESTZONE', 0
align 16
testzone:
	mov rdi, tempstring		; Get string from user
	mov rcx, 20			; Limit the capture of characters to 255
	call os_input_string

	call os_string_parse
	mov rax, rcx
	call os_dump_rax
	
	call os_print_newline



;	mov al, 65
;	call os_serial_send
;	mov rcx, 100
;	mov al, '5'
;	call os_print_char
;	call os_delay
;	mov al, '4'
;	call os_print_char
;	call os_delay
;	mov al, '3'
;	call os_print_char
;	call os_delay
;	mov al, '2'
;	call os_print_char
;	call os_delay
;	mov al, '1'
;	call os_print_char
;	call os_delay
;	call os_speaker_beep
;	call os_print_newline

;	ud2
;	xor rax, rax
;	xor rbx, rbx
;	xor rcx, rcx
;	xor rdx, rdx
;	div rax
;	mov rsi, taskdata
;	mov rcx, 256
;	call os_dump_mem
;	call os_print_newline
	jmp os_command_line

;testzone_ap:
;	push rsi
;
;	pop rsi
;	ret

reboot:
	mov al, 0xFE
	out 0x64, al
	jmp reboot

debug:
	call os_dump_reg
	jmp os_command_line

exit:
	ret

; Strings
	help_text		db 'Built-in commands: CLS, DATE, DEBUG, DIR, HELP, REBOOT, TIME, VER', 13, 0
	not_found_msg		db 'Command or program not found', 13, 0
	version_msg		db 'BareMetal ', BAREMETALOS_VER, 13, 0

	help_string		db 'HELP', 0
	cls_string		db 'CLS', 0
	ver_string		db 'VER', 0
	dir_string		db 'DIR', 0
	date_string		db 'DATE', 0
	time_string		db 'TIME', 0
	testzone_string		db 'TESTZONE', 0
	reboot_string		db 'REBOOT', 0
	debug_string		db 'DEBUG', 0
	exit_string		db 'EXIT', 0

; =============================================================================
; EOF
