; =============================================================================
; Bare Metal OS -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008 Ian Seyler -- see LICENSE.TXT
;
; INIT_64
; =============================================================================

align 16
db 'DEBUG: INIT_64  '
align 16


init_64:
	xor	rdi, rdi 			; create the 64-bit IDT (at linear address 0x0000000000000000) as defined by Pure64

	mov	rcx, 32
make_exception_gates: 		; make gates for exception handlers
	mov rax, exception_gate
	push rax				; save the exception gate to the stack for later use
	stosw					; store the low word (15..0) of the address
	mov ax, SYS64_CODE_SEL
	stosw					; store the segment selector
	mov ax, 0x8E00
	stosw					; store exception gate marker
	pop rax					; get the exception gate back
	shr rax, 16
	stosw					; store the high word (31..16) of the address
	shr rax, 16
	stosd					; store the extra high dword (63..32) of the address.
	xor rax, rax
	stosd					; reserved
	dec rcx
	jnz make_exception_gates

	mov	rcx, 256-32
make_interrupt_gates: 		; make gates for the other interrupts
	mov rax, interrupt_gate
	push rax				; save the interrupt gate to the stack for later use
	stosw					; store the low word (15..0) of the address
	mov ax, SYS64_CODE_SEL
	stosw					; store the segment selector
	mov ax, 0x8F00
	stosw					; store interrupt gate marker
	pop rax					; get the interrupt gate back
	shr rax, 16
	stosw					; store the high word (31..16) of the address
	shr rax, 16
	stosd					; store the extra high dword (63..32) of the address.
	xor rax, rax
	stosd					; reserved
	dec rcx
	jnz make_interrupt_gates

	; Set up the exception gates for all of the CPU exceptions
	; The following code will be seriously busted if the exception gates are moved above 16MB
	mov	word [0x00*16], exception_gate_00
	mov	word [0x01*16], exception_gate_01
	mov	word [0x02*16], exception_gate_02
	mov	word [0x03*16], exception_gate_03
	mov	word [0x04*16], exception_gate_04
	mov	word [0x05*16], exception_gate_05
	mov	word [0x06*16], exception_gate_06
	mov	word [0x07*16], exception_gate_07
	mov	word [0x08*16], exception_gate_08
	mov	word [0x09*16], exception_gate_09
	mov	word [0x0A*16], exception_gate_10
	mov	word [0x0B*16], exception_gate_11
	mov	word [0x0C*16], exception_gate_12
	mov	word [0x0D*16], exception_gate_13
	mov	word [0x0E*16], exception_gate_14
	mov	word [0x0F*16], exception_gate_15
	mov	word [0x10*16], exception_gate_16
	mov	word [0x11*16], exception_gate_17
	mov	word [0x12*16], exception_gate_18
	mov	word [0x13*16], exception_gate_19

	in	al, 0x21
	mov	al, 11111000b			; enable cascade, keyboard, timer
	out	0x21, al
	in	al, 0xA1
	mov	al, 11111110b			; enable rtc
	out	0xA1, al

	; Set up the IRQ handlers
	mov rdi, 0x20
	mov rax, timer
	call create_gate

	mov rdi, 0x21
	mov rax, keyboard
	call create_gate

;	lidt [IDTR64]				; load IDT register
	sti							; Re-enable interupts.

ret

; create_gate
; rax = address of handler
; rdi = gate to set up
create_gate:
	push rdi
	push rax
	
	shl rdi, 4	; quickly multiply rdi by 16

	stosw		; store the low word (15..0)
	shr rax, 16
	add rdi, 4
	stosw		; store the high word (31..16)
	shr rax, 32
	stosd		; store the extra high dword (63..32)

	pop rdi
	pop rax
ret


; =============================================================================
; EOF
