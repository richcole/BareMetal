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
	hlt
	jmp hang64					; Loop, self-jump

align 16
mess db 'AP SPIN ZONE', 0
align 16

sleep_ap:						; AP's will be running here
;	mov rsi, mess
;	call os_print_string
	hlt							; Wait for a "wakeup" IPI
	
	;If we got here than an interrupt has been triggered or this AP was told to wake up.
	mov rax, [mp_job_queue]
	cmp rax, 0x0000000000000000
	je sleep_ap
	push rax
	xor rax, rax
	mov [mp_job_queue], rax		; Clear the job queue as an AP will be dealing with it.
	mov byte [mp_job_queue_inuse], 0x00	; Clear the inuse marker
	pop rax
	call rax

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
