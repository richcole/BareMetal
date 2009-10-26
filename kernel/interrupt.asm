; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; Interupts
; =============================================================================

align 16
db 'DEBUG: INTERRUPT'
align 16


; -----------------------------------------------------------------------------
; Default exception handler
exception_gate:
	mov rsi, int_string00
	call os_print_string
	mov rsi, exc_string
	call os_print_string
	jmp $			; hang
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Default interrupt handler
interrupt_gate:				; handler for all other interrupts
	iretq				; It was an undefined interrupt so return to caller
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Timer interrupt. IRQ 0x00, INT 0x20
; Currently this IRQ runs 100 times per second (As defined in Pure64)
; That gives us a runtime of 184467440737095516 seconds before rollover
; That translates to ~5,845,545,310 years. Do we really need the "hi" counter?
timer:
	push rax

	call timer_debug		; For debug to see if system is still running

	add qword [timer_counter_lo], 1	; 128-bit counter started at bootup
;	adc qword [timer_counter_hi], 0	; If 'lo' overflowed then 1 will be added to 'hi'

	mov al, 20h			; Acknowledge the IRQ
	out 20h, al

	pop rax
	iretq
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Keyboard interrupt. IRQ 0x01, INT 0x21
keyboard:
	push rax
	push rbx

	call keyboard_debug		; For debug to see if system is still running

	mov al, 0xad
	out 0x64, al			; disable keyboard

	in al, 0x61			; get the scancode
	mov [scancode], al		; store the scancode
	xor al, 0x80			; next five lines are for acknowledging the scancode
	out 0x61, al
	mov al, [scancode]
	and al, 0x7f
	out 0x61, al

	xor eax, eax
	in al, 0x60			; get the key

	test al, 0x80
	jz keydown
	jmp keyup

keydown:
	mov ebx, keylayoutlower
	add ebx, eax
	mov bl, [ebx]
	mov [kkey], bl
	mov al, [kkey]
	jmp donekey

keyup:
	; else we got a valid key

;	mov byte [0xB8f9c], al	; put the typed character in the bottom right hand corner


donekey:
	mov al, 0xae
	out 0x64, al ; enable keyboard

	mov al, 20h			; Acknowledge the IRQ
	out 20h, al

	pop rbx
	pop rax
	iretq
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Cascade interrup. IRQ 0x02, INT 0x22
cascade:
	push rax

	mov al, 0x20			; Acknowledge the IRQ
	out 0x20, al

	pop rax
	iretq
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Real-time clock interrupt. IRQ 0x08, INT 0x28
; Currently this IRQ runs 8 times per second (As defined in init_64.asm)
; http://wiki.osdev.org/RTC
; The supervisor lives here
rtc:
	push rax
	push rcx
	push rsi
	push rdi
	
	call clock_debug		; For debug to see if system is still running
	
	; Check to make sure that at least one core is running something
	mov rsi, taskdata
	xor rcx, rcx
	mov cx, [os_NumCores]
check_loop:
	dec rcx
	lodsq
	add rsi, 8
	cmp rax, 0x0000000000000000
	jne check_end
	cmp rcx, 0
	jne check_loop

	; If we got here then there are no active tasks.. start the CLI
	mov rdi, taskdata
	mov rax, os_command_line
	stosq

check_end:

	mov al, 0x0c			; Select RTC register C
	out 0x70, al			; Port 0x70 is the RTC index, and 0x71 is the RTC data
	in al, 0x71			; Read the value in register C

	mov al, 0x20			; Acknowledge the IRQ
	out 0xa0, al
	out 0x20, al

	pop rdi
	pop rsi
	pop rcx
	pop rax
	iretq
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; A simple interrupt that just acknowledges an IPI. Useful for getting an AP past a 'hlt' in the code.
ap_wakeup:
	push rdi
	push rax
	
	mov rdi, [os_LocalAPICAddress]	; Acknowledge the IPI
	add rdi, 0xB0
	xor rax, rax
	stosd
	
	pop rax
	pop rdi

	iretq				; Return from the IPI.
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Modifies the running CPUs stack so after the iretq it jumps to the code address in stagingarea
ap_call:
	mov rax, [stagingarea]		; Grab the code address from the staging area

	mov [rsp], rax			; Overwrite the return address on the CPU's stack

	mov rdi, [os_LocalAPICAddress]	; Acknowledge the IPI
	add rdi, 0xB0
	xor rax, rax
	stosd

	iretq				; Return from the IPI. CPU will execute code at the address that was in stagingarea
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; CPU Exception Gates
align 16
exception_gate_00:
	mov al, 0x00
	jmp exception_gate_main

align 16
exception_gate_01:
	mov al, 0x01
	jmp exception_gate_main

align 16
exception_gate_02:
	mov al, 0x02
	jmp exception_gate_main

align 16
exception_gate_03:
	mov al, 0x03
	jmp exception_gate_main

align 16
exception_gate_04:
	mov al, 0x04
	jmp exception_gate_main

align 16
exception_gate_05:
	mov al, 0x05
	jmp exception_gate_main

align 16
exception_gate_06:
	mov al, 0x06
	jmp exception_gate_main

align 16
exception_gate_07:
	mov al, 0x07
	jmp exception_gate_main

align 16
exception_gate_08:
	mov al, 0x08
	jmp exception_gate_main

align 16
exception_gate_09:
	mov al, 0x09
	jmp exception_gate_main

align 16
exception_gate_10:
	mov al, 0x0A
	jmp exception_gate_main

align 16
exception_gate_11:
	mov al, 0x0B
	jmp exception_gate_main

align 16
exception_gate_12:
	mov al, 0x0C
	jmp exception_gate_main

align 16
exception_gate_13:
	mov al, 0x0D
	jmp exception_gate_main

align 16
exception_gate_14:
	mov al, 0x0E
	jmp exception_gate_main

align 16
exception_gate_15:
	mov al, 0x0F
	jmp exception_gate_main

align 16
exception_gate_16:
	mov al, 0x10
	jmp exception_gate_main

align 16
exception_gate_17:
	mov al, 0x11
	jmp exception_gate_main

align 16
exception_gate_18:
	mov al, 0x12
	jmp exception_gate_main

align 16
exception_gate_19:
	mov al, 0x13
	jmp exception_gate_main

align 16
exception_gate_main:
	push rax			; Save RAX since os_smp_get_id clobers it
	mov rsi, int_string00
	call os_print_string
	call os_smp_get_id		; Get the local CPU ID and print it
	mov rdi, tempstring
	mov rsi, rdi
	call os_int_to_string
	call os_print_string
	mov rsi, int_string01
	call os_print_string
	mov rsi, exc_string00
	pop rax
	and rax, 0x00000000000000FF	; Clear out everything in RAX except for AL
	push rax
	mov bl, 52
	mul bl				; AX = AL x BL
	add rsi, rax			; Use the value in RAX as an offset to get to the right message
	pop rax
	call os_print_string
	xor rax, rax
	pop rax				; The processor puts an error code on the stack, get it and print it
	call os_print_newline
	call os_dump_reg

	sti				; Re-enable interrupts	
	jmp ap_clear			; jump to AP clear code


int_string00 db 'BareMetal OS - CPU ', 0
int_string01 db ' - ', 0
; Strings for the error messages
exc_string db 'Unknown Fatal Exception!', 0
exc_string00 db 'Interrupt 00 - Divide Error Exception (#DE)        ', 0
exc_string01 db 'Interrupt 01 - Debug Exception (#DB)               ', 0
exc_string02 db 'Interrupt 02 - NMI Interrupt                       ', 0
exc_string03 db 'Interrupt 03 - Breakpoint Exception (#BP)          ', 0
exc_string04 db 'Interrupt 04 - Overflow Exception (#OF)            ', 0
exc_string05 db 'Interrupt 05 - BOUND Range Exceeded Exception (#BR)', 0
exc_string06 db 'Interrupt 06 - Invalid Opcode Exception (#UD)      ', 0
exc_string07 db 'Interrupt 07 - Device Not Available Exception (#NM)', 0
exc_string08 db 'Interrupt 08 - Double Fault Exception (#DF)        ', 0
exc_string09 db 'Interrupt 09 - Coprocessor Segment Overrun         ', 0	; No longer generated on new CPU's
exc_string10 db 'Interrupt 10 - Invalid TSS Exception (#TS)         ', 0
exc_string11 db 'Interrupt 11 - Segment Not Present (#NP)           ', 0
exc_string12 db 'Interrupt 12 - Stack Fault Exception (#SS)         ', 0
exc_string13 db 'Interrupt 13 - General Protection Exception (#GP)  ', 0
exc_string14 db 'Interrupt 14 - Page-Fault Exception (#PF)          ', 0
exc_string15 db 'Interrupt 15 - Undefined                           ', 0
exc_string16 db 'Interrupt 16 - x87 FPU Floating-Point Error (#MF)  ', 0
exc_string17 db 'Interrupt 17 - Alignment Check Exception (#AC)     ', 0
exc_string18 db 'Interrupt 18 - Machine-Check Exception (#MC)       ', 0
exc_string19 db 'Interrupt 19 - SIMD Floating-Point Exception (#XM) ', 0


; =============================================================================
; EOF
