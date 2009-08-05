; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; The BareMetal OS kernel
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; Assemble with NASM
; =============================================================================


[BITS 64]
[ORG 0x0000000000100000]

kernel_start:
	jmp start

	; Aligned for simplicity... It does waste a bit of space.
	align 16

	jmp os_print_string	; 0x00010010
	align 8
	jmp os_print_char
	align 8
	jmp os_print_char_hex
	align 8
	jmp os_print_newline
	align 8
	jmp os_check_for_key
	align 8
	jmp os_wait_for_key
	align 8
	jmp os_input_string
	align 8
	jmp os_delay
	align 8
	jmp os_speaker_tone
	align 8
	jmp os_speaker_off
	align 8
	jmp os_speaker_beep
	align 8
	jmp os_move_cursor
	align 8
	jmp os_string_length
	align 8
	jmp os_find_char_in_string
	align 8
	jmp os_string_copy
	align 8
	jmp os_string_truncate
	align 8
	jmp os_string_join
	align 8
	jmp os_string_chomp
	align 8
	jmp os_string_strip
	align 8
	jmp os_string_compare
	align 8
	jmp os_string_uppercase
	align 8
	jmp os_string_lowercase
	align 8
	jmp os_int_to_string
	align 8
	jmp os_dump_reg
	align 8
	jmp os_dump_mem
	align 8
	jmp os_dump_rax
	align 8
	jmp os_string_to_int
	align 16

start:

	call init_64	; After this point we are in a working 64-bit enviroment

	call hd_setup	; gather information about the harddrive and set it up
;	call init_pci

	mov ax, 0x0016
	call os_move_cursor
	mov rsi, readymsg
	call os_print_string
	
	mov ax, 0x0018
	call os_move_cursor
	call os_show_cursor

; once init is done we start the CLI so the user can start their own apps/utils
	jmp os_command_line ; could be a call as well if we ever wanted to get out

hang64:
	jmp hang64					; Loop, self-jump

sleep_ap:						; AP's should be running here
	hlt
	jmp sleep_ap

; Includes
%include "init_64.asm"
%include "init_hd.asm"
%include "syscalls.asm"
%include "drivers.asm"
%include "interrupt.asm"
%include "sysvar.asm"
%include "cli.asm"

times 8192-($-$$) db 0			; Set the compiled binary to at least this size

; =============================================================================
; EOF
