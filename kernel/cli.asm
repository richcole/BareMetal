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
	mov rcx, 250			; Limit the capture of characters to 250
	call os_input_string

	push rdi
	mov rsi, newline		; The user hit enter so print a new line
	call os_print_string
	pop rsi

	cmp rcx, 0			; If just enter pressed, prompt again
	je os_command_line		; os_input_string stores the number of charaters received in RCX

	call os_string_parse		; Remove extra spaces
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

; At this point it is not one of the built-in CLI functions. Check the filesystem.

; copy the first word in the string to a new string.
	xor rcx, rcx
	mov rsi, tempstring
	mov rdi, app_tstring
	push rdi
nextbyte:
	inc rcx
	lodsb
	cmp al, ' '	; End of the word
	je endofcommand
	cmp al, 0x00	; End of the string
	je endofcommand
	cmp rcx, 13	; More than 12 bytes
	je endofcommand
	stosb
	jmp nextbyte
endofcommand:
	mov al, 0x00
	stosb		; Terminate the string
	pop rsi
; At this point app_tstring holds at least "a" and at most "abcdefgh.ijk"

	mov al, '.'
	call os_find_char_in_string	; Check for a '.' in the string
	cmp rax, 0
	jne full_name			; If there was a '.' then a suffix is present

add_suffix:
	call os_string_length
	cmp rcx, 8
	jg fail				; If the string is longer than 8 chars we can't add a suffix
	add rsi, rcx			; Move to end of input string

	mov byte [rsi], '.'
	mov byte [rsi+1], 'A'
	mov byte [rsi+2], 'P'
	mov byte [rsi+3], 'P'
	mov byte [rsi+4], 0		; Zero-terminate string

full_name:
	mov rsi, app_tstring
	mov rdi, programlocation	; We load the program to this location in memory (currently 0x00100000 : at the 2MB mark)
	call os_file_load		; Load the file
	jc fail				; If carry is set then the file was not found
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
;	mov rdi, tempstring		; Get string from user
;	mov rsi, rdi
;	mov rcx, 20			; Limit the capture of characters to 20
;	call os_input_string
;	call os_print_newline

;	call int_filename_convert
;	mov rsi, rdi
	
;	call os_string_parse
;	call os_print_string
;	mov al, '!'
;	call os_print_char
;	call os_print_newline
;
;	mov rax, rcx
;	call os_dump_rax
;	call os_print_newline
;	mov al, 65
;	call os_print_char



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

	app_tstring		times 14 db 0

; =============================================================================
; EOF
