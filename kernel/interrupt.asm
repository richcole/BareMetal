; =============================================================================
; Bare Metal OS -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008 Ian Seyler -- see LICENSE.TXT
;
; Interupts
; =============================================================================

align 16
db 'DEBUG: INTERRUPT'
align 16


; -----------------------------------------------------------------
; Default exception handler
exception_gate:
	mov rsi, int_string00
	call os_print_string
	mov rsi, exc_string
	call os_print_string
	jmp	$					; hang
; -----------------------------------------------------------------


; -----------------------------------------------------------------
; Default interrupt handler
interrupt_gate:				; handler for all other interrupts
	iretq
; -----------------------------------------------------------------


; -----------------------------------------------------------------	
timer:
;	call showprogress64			; for debug purposes.. the timer is being called as long as the spinning cursor is on screen
	push rax

	add qword [timer_counter], 1		; 64-bit counter started at bootup
	
	mov rax, [delay_timer]
	cmp rax, 0
	je timer_over
	dec rax
	mov [delay_timer], rax

timer_over:
	
	mov al, 20h
	out 20h, al
	pop rax
	iretq
	
delay_timer: dq 0x0000000000000000
timer_counter: dq 0x0000000000000000
; -----------------------------------------------------------------


; -----------------------------------------------------------------
keyboard:
	push rax
	push rbx
	
	mov al, 0xad
	out 0x64, al ; disable keyboard
	
	in al, 0x61	; get the scancode
	mov [scancode], al	; store the scancode
	xor al, 0x80	; next five lines are for acknowledging the scancode
	out 0x61, al
	mov al, [scancode]
	and al, 0x7f
	out 0x61, al
	
	xor eax, eax
	in al, 0x60	; get the key

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
	
	mov al, 20h
	out 20h, al
	pop rbx
	pop rax
	iretq

scancode: db 0x00
kkey: db 0x00
; -----------------------------------------------------------------	


; -----------------------------------------------------------------
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
	mov rsi, int_string00
	call os_print_string
	mov rsi, exc_string00
	and rax, 0x00000000000000FF	; Clear out everything in RAX except for AL
	push rax
	mov bl, 51
	mul bl						; AX = AL x BL
	add rsi, rax				; Use the value in RAX as an offset to get to the right message
	pop rax
	call os_print_string
	xor rax, rax
	pop rax						; The processor puts an error code on the stack, get it and print it
	call os_print_newline
	call os_dump_reg

	sti							; Re-enable interrupts
	jmp os_command_line			; jump to start of the command line


int_string00 db 'BareMetal OS - ', 0
int_string01 db ' System Halted!', 0
; Strings for the error messages
exc_string db 'Unknown Fatal Exception!', 0
exc_string00 db 'Interrupt 0 - Divide Error Exception (#DE)        ', 0
exc_string01 db 'Interrupt 1 - Debug Exception (#DB)               ', 0
exc_string02 db 'Interrupt 2 - NMI Interrupt                       ', 0
exc_string03 db 'Interrupt 3 - Breakpoint Exception (#BP)          ', 0
exc_string04 db 'Interrupt 4 - Overflow Exception (#OF)            ', 0
exc_string05 db 'Interrupt 5 - BOUND Range Exceeded Exception (#BR)', 0
exc_string06 db 'Interrupt 6 - Invalid Opcode Exception (#UD)      ', 0
exc_string07 db 'Interrupt 7 - Device Not Available Exception (#NM)', 0
exc_string08 db 'Interrupt 8 - Double Fault Exception (#DF)        ', 0
exc_string09 db 'Interrupt 9 - Coprocessor Segment Overrun         ', 0
exc_string10 db 'Interrupt 10 - Invalid TSS Exception (#TS)        ', 0
exc_string11 db 'Interrupt 11 - Segment Not Present (#NP)          ', 0
exc_string12 db 'Interrupt 12 - Stack Fault Exception (#SS)        ', 0
exc_string13 db 'Interrupt 13 - General Protection Exception (#GP) ', 0
exc_string14 db 'Interrupt 14 - Page-Fault Exception (#PF)         ', 0
exc_string15 db 'Interrupt 15 - Undefined                          ', 0
exc_string16 db 'Interrupt 16 — x87 FPU Floating-Point Error (#MF) ', 0
exc_string17 db 'Interrupt 17 — Alignment Check Exception (#AC)    ', 0
exc_string18 db 'Interrupt 18 — Machine-Check Exception (#MC)      ', 0
exc_string19 db 'Interrupt 19 — SIMD Floating-Point Exception (#XM)', 0

; =============================================================================
; EOF
