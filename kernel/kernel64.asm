; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; The BareMetal OS kernel. Assemble with NASM
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
	align 8
	jmp os_smp_get_local_id
	align 8
	jmp os_set_cpu_task
	align 8
	jmp os_smp_wakeup
	align 16

start:

	call init_64	; After this point we are in a working 64-bit enviroment

	call hd_setup	; gather information about the harddrive and set it up

;	call init_pci

	mov ax, 0x0016		; print the "ready" message
	call os_move_cursor
	mov rsi, readymsg
	call os_print_string

	mov ax, 0x0018		; set the hardware cursor to the bottom left-hand corner
	call os_move_cursor
	call os_show_cursor

	; assign the command line "program" to CPU 0
	xor rax, rax				; Clear RAX to 0
	mov rbx, os_command_line	; Set RBX to the memory address of the command line
	call os_set_cpu_task		; Set it, don't need to wake it up as interrupts are enabled


align 16

sleep_ap:						; AP's will be running here

	; reset the stack
	call os_smp_get_local_id
	shl rax, 10	; a 1024byte stack
	add rax, 0x0000000000090400		; stacks decrement when you "push", start at 1024 bytes in
	mov rsp, rax

	; clear registers
	xor rax, rax					; aka r0
	xor rbx, rbx					; aka r3
	xor rcx, rcx					; aka r1
	xor rdx, rdx					; aka r2
	xor rsi, rsi					; aka r6
	xor rdi, rdi					; aka r7
	xor rbp, rbp					; aka r5
	xor r8, r8
	xor r9, r9
	xor r10, r10
	xor r11, r11
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15
	
	hlt							; Wait for a interrupt or "wakeup" IPI
	
	call os_smp_get_local_id	; On wakeup find out which CPU we are

	; check for a pending task
	mov rsi, taskdata
	shl rax, 4	; quickly multiply RAX by 16 as each record (code+data) is 16 bytes (64bits x2)
	add rsi, rax
	push rsi
	lodsq		; load the task address into RAX
	
	; if there is none go back to sleep
	cmp rax, 0x0000000000000000
	je sleep_ap

	; if there is then call RAX
	call rax
	
	; clear the pending task after execution
	pop rdi
	xor rax, rax
	stosq

	; go back to sleep
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
