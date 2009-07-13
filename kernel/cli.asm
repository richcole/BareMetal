; =============================================================================
; Bare Metal OS -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008 Ian Seyler -- see LICENSE.TXT
;
; COMMAND LINE INTERFACE
; =============================================================================

align 16
db 'DEBUG: CLI      '
align 16


os_command_line:

	xor rbp, rbp
	mov rsp, 0x0000000000098000

.more:

	mov rsi, .default_prompt	; Prompt for input
	call os_print_string

	mov rdi, input				; Get string from user
	mov rcx, 255				; Limit the capture of characters to 255
	call os_input_string
	
	push rdi
	mov rsi, .newline
	call os_print_string
	pop rsi

	cmp rcx, 0					; If just enter pressed, prompt again
	je .more
	
	call os_string_chomp		; Remove leading and trailing spaces
	call os_string_uppercase	; Convert to uppercase for comparison

	mov rdi, .help_string		; 'HELP' entered?
	call os_string_compare
	jc near .print_help

	mov rdi, .cls_string		; 'CLS' entered?
	call os_string_compare
	jc near .clear_screen

	mov rdi, .ver_string		; 'VER' entered?
	call os_string_compare
	jc near .print_ver

	mov rdi, .dir_string		; 'DIR' entered?
	call os_string_compare
	jc near .dir

	mov rdi, .date_string		; 'DATE' entered?
	call os_string_compare
	jc near .date

	mov rdi, .time_string		; 'TIME' entered?
	call os_string_compare
	jc near .time

	mov rdi, .testzone_string	; 'TESTZONE' entered?
	call os_string_compare
	jc near .testzone

	mov rdi, .reboot_string		; 'REBOOT' entered?
	call os_string_compare
	jc near .reboot

	mov rdi, .debug_string		; 'DEBUG' entered?
	call os_string_compare
	jc near .debug

	mov al, '.'
	call os_find_char_in_string	; User entered dot in filename?
	cmp rax, 0
	je .notadot					; If not, see if it's 11 chars
	dec rax
	jmp .padout					; Otherwise, make sure it's padded out

.notadot:
	call os_string_length

	cmp rax, 11
	je near .full_name
	jg near .fail

.padout:
	add rsi, rax			; Pad with spaces and 'BIN'

.bitmore:
	cmp rax, 8
	jge .suffix
	mov byte [rsi], ' '
	inc rsi
	inc rax
	jmp .bitmore

.suffix:
	mov byte [rsi], 'B'		; So sloppy!!
	inc rsi
	mov byte [rsi], 'I'
	inc rsi
	mov byte [rsi], 'N'
	inc rsi
	mov byte [rsi], 0		; Zero-terminate string

.full_name:
	mov rbx, input

	call findfile			; Fuction will return the starting cluster value in ebx or 0 if not found
	cmp ebx, 0				; If ebx is 0 then the file was not found
	je .fail	; bail out if the file was not found

	mov rdi, programlocation	; We load the program to this location in memory (currently 0x00100000 : at the 2MB mark)
	.readfile_getdata:
	call readcluster		; store in memory
	cmp ebx, 0x0FFFFFFF 	; 
	jl .readfile_getdata	; Are there more clusters? If so then read again.. if not fall through.

	call programlocation	; 0x00100000 : at the 2MB mark

	jmp .more	

.fail:						; We didn't get a valid command or program name
	mov rsi, .not_found_msg
	call os_print_string
	jmp .more

.print_help:
	mov rsi, .help_text
	call os_print_string
	jmp .more

.clear_screen:
	mov rdi, 0x00000000000B8000			; memory address of color video
	mov ax, 0x0720		; 0x07 for black background/white foreground, 0x20 for space (black) character
	mov cx, 0x4000
	rep stosw					; clear the screen, Store word in AX to RDI CX times
	mov ax, 0x0018
	call os_move_cursor
	jmp .more

.print_ver:
	mov rsi, .version_msg
	call os_print_string
	jmp .more

.dir:
	mov rdi, dirlist
	push rdi
	call os_fat32_get_file_list
	pop rsi;mov rsi, dirlist
	call os_print_string
	jmp .more

.date:
	mov rdi, tempstring;datestring
	call os_get_date_string
	mov rsi, rdi
	call os_print_string
	call os_print_newline
	jmp .more

.time:
	mov rdi, tempstring;timestring
	call os_get_time_string
	mov rsi, rdi
	call os_print_string
	call os_print_newline
	jmp .more

.poomsg db 'OMG TESTZONE', 0
.testzone:

;mov rsi, 0x0000000000001000
;mov rcx, 256
;call os_dump_mem

;mov rdi, input				; Get string from user
;mov rcx, 255				; Limit the capture of characters to 255
;call os_input_string

;mov al, 'a'
;mov bl, 'b'
;mov rsi, rdi
;call os_string_charchange
;call os_print_newline
;call os_print_string

;mov rsi, .tempgarbage
;call os_fat32_filename_convert
;call os_print_string

;mov rax, 0xFFFFFFFFFFFFFFFF
;mov rdi, .tmpstring
;call os_int_to_string
;mov rsi, .tmpstring
;call os_print_string
;call os_print_newline

;call os_dump_mem
;	mov al, 0x65
;	out 0xE9, al	; Send an 'e' to the Bochs debug port. It shows up in the bochs console.
	
; Cause an int 14 - Page-Fault exception (Trying to access memory not in the page map)
;	mov rdi, 0x00007FFF12345678
;	stosq

; Cause an int 13 - General Protection Fault (Trying to access memory outside of the canonical range)
;	mov rdi, 0x1234567812345678
;	stosq

; Cause an int 0 - Divide Error Exception
;	xor rax, rax
;	xor rbx, rbx
;	xor rcx, rcx
;	xor rdx, rdx
;	div rbx

jmp .more

;.tempgarbage db 'FILE.SY', 0, 0, 0, 0, 0, 0

.reboot:
	mov al, 0xD1
	out 0x64, al
	mov al, 0xFE
	out 0x64, al
	jmp .reboot

.debug:
	call os_dump_reg
	jmp .more

; Strings
;	.tmpstring	times 30 db 0

	.default_prompt		db '> ', 0
	.newline			db 13, 0
	.help_text			db 'Built-in commands: CLS, HELP, VER, DIR, DATE, TIME', 13, 0
	.not_found_msg		db 'Command or program not found', 13, 0
	.chprompt_msg		db 'Enter a new prompt:', 13, 0
	.version_msg		db 'BareMetal ', BAREMETALOS_VER, 13, 0

	.help_string		db 'HELP', 0
	.cls_string			db 'CLS', 0
	.ver_string			db 'VER', 0
	.dir_string			db 'DIR', 0
	.date_string		db 'DATE', 0
	.time_string		db 'TIME', 0
	.testzone_string	db 'TESTZONE', 0
	.reboot_string		db 'REBOOT', 0
	.debug_string		db 'DEBUG', 0

; =============================================================================
; EOF
