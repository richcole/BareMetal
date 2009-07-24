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
	mov rcx, 20
	xor rdi, rdi
make_real_exception_gates:
	mov rax, exception_gate_00
	call create_gate
	inc rdi
	add rax, 16				; The exception gates are aligned at 16 bytes
	dec rcx
	jnz make_real_exception_gates

	; Enable specific interrupts
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

	mov rdi, 0x22
	mov rax, cascade
	call create_gate

	mov rdi, 0x28
	mov rax, rtc
	call create_gate

	mov rdi, 0x50
	mov rax, tester
	call create_gate
	
	;Set up RTC
	mov al, 0x0a
	out 0x70, al
	mov al, 00100110b ; RTC@32.768KHz, Rate@1024MHz
	out 0x71, al
	mov al, 0x0b
	out 0x70, al
	mov al, 01000010b ; Periodic(6), 24H clock(2)
	out 0x71, al

	;Grab data from Pure64's infomap
	mov rsi, 0xf000
	xor rax, rax
	lodsd
	mov [os_LocalAPICAddress], rax
	lodsd
	mov [os_IOAPICAddress], rax
	

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

	pop rax
	pop rdi
ret


; =============================================================================
; EOF
