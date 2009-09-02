; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; The BareMetal OS kernel. Assemble with NASM
; =============================================================================


[BITS 64]
[ORG 0x0000000000100000]

kernel_start:
	jmp start		; Skip over the function call index

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
	jmp os_smp_get_id
	align 8
	jmp os_smp_set_task
	align 8
	jmp os_smp_wakeup
	align 8
	jmp os_smp_find_free
	align 8
	jmp os_smp_wakeup_all
	align 8
	jmp os_smp_wait_for_aps
	align 16

start:

	call init_64		; After this point we are in a working 64-bit enviroment

	call hd_setup		; gather information about the harddrive and set it up

;	call init_pci

	mov ax, 0x0016		; print the "ready" message
	call os_move_cursor
	mov rsi, readymsg
	call os_print_string

	mov ax, 0x0018		; set the hardware cursor to the bottom left-hand corner
	call os_move_cursor
	call os_show_cursor

	; assign the command line "program" to CPU 0
	xor rax, rax			; Clear RAX to 0
	mov rbx, os_command_line	; Set RBX to the memory address of the command line
	xor rcx, rcx			; Clear RCX as well since there is no need to pass a data address or variable
	call os_smp_set_task		; Set it, don't need to wake it up as interrupts are enabled

	jmp sleep_ap


align 16

clear_ap:					; AP's start here after an exception

	; Get local ID without using the stack
	mov rsi, [os_LocalAPICAddress]		; We would call os_smp_get_id here but the stack is not ...
	add rsi, 0x20				; ... yet defined. It is safer to find the value directly.
	lodsd					; Load a 32-bit value. We only want the high 8 bits
	shr rax, 24				; Shift to the right and AL now holds the CPU's APIC ID

	; Find the task in the taskdata
	mov rdi, taskdata
	shl rax, 4		; quickly multiply RAX by 16 as each record (code+data) is 16 bytes (64bits x2)
	add rdi, rax

	; Clear it
	xor rax, rax
	stosq

	; Clear the local CPU flag
;	mov rsi, [os_LocalAPICAddress]		; We would call os_smp_get_id here but the stack is not ...
;	add rsi, 0x20				; ... yet defined. It is safer to find the value directly.
;	lodsd					; Load a 32-bit value. We only want the high 8 bits
;	shr rax, 24				; Shift to the right and AL now holds the CPU's APIC ID
;	mov rdi, cpuflags			; Point RDI to the start of the cpuflags area
;	add rdi, rax				; Add the APIC ID as an offset
;	xor rax, rax
;	stosb					; Write over the existing byte with 0x00

	; We fall through to sleep_ap as align fills the space with No-Ops


align 16

sleep_ap:					; AP's will be running here

	; Reset the stack. Each CPU gets a 1024-byte unique stack location
	xor rax, rax				; Clear RAX as the high 32 bits may contain data
	mov rsi, [os_LocalAPICAddress]		; We would call os_smp_get_id here but the stack is not ...
	add rsi, 0x20				; ... yet defined. It is safer to find the value directly.
	lodsd					; Load a 32-bit value. We only want the high 8 bits
	shr rax, 24				; Shift to the right and AL now holds the CPU's APIC ID
	shl rax, 10				; shift left 10 bits for a 1024byte stack
	add rax, 0x0000000000050400		; stacks decrement when you "push", start at 1024 bytes in
	mov rsp, rax				; Pure64 leaves 0x50000-0x9FFFF free so we use that

	; Clear registers. Gives us a clean slate to work with
	xor rax, rax				; aka r0
	xor rbx, rbx				; aka r3
	xor rcx, rcx				; aka r1
	xor rdx, rdx				; aka r2
	xor rsi, rsi				; aka r6
	xor rdi, rdi				; aka r7
	xor rbp, rbp				; aka r5
	xor r8, r8				; We skip RSP (aka r4) as it was previously set
	xor r9, r9
	xor r10, r10
	xor r11, r11
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15

	; Wait for a interrupt or "wakeup" IPI. No need to spin when there is nothing to do
	hlt

	; On wakeup find out which CPU we are
	call os_smp_get_id

	; Check for a pending task
	mov rsi, taskdata
	shl rax, 4		; Quickly multiply RAX by 16 as each record (code+data) is 16 bytes (64bits x2)
	add rsi, rax
	lodsq			; Load the task code address into RAX
	xchg rax, rbx		; Swap RAX and RBX since LODSQ uses RAX
	lodsq			; Load the task data address/data variable into RAX
	xchg rax, rbx		; Swap RAX and RBX again
	xor rsi, rsi		; Clear RSI since we used it

	; If there is no pending task to complere then go back to sleep
	cmp rax, 0x0000000000000000
	je sleep_ap		; If it was NULL then there is nothing to work on

	; If there is a pending task then call RAX
	call rax

	; Clear the pending task after execution. We will only get here is the task returned successfully.
	call os_smp_get_id	; Get the APIC ID again. We could use the stack to save the id from earlier ...
	mov rdi, taskdata	; ... but we don't know what the condition of the stack is on return.
	shl rax, 4
	add rdi, rax
	xor rax, rax
	stosq

	; Go back to sleep
	jmp sleep_ap

; Includes
%include "init_64.asm"
%include "init_hd.asm"
%include "syscalls.asm"
%include "drivers.asm"
%include "interrupt.asm"
%include "sysvar.asm"
%include "cli.asm"

times 8192-($-$$) db 0		; Set the compiled binary to at least this size in bytes

; =============================================================================
; EOF
