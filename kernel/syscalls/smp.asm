; =============================================================================
; Bare Metal OS -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008 Ian Seyler -- see LICENSE.TXT
;
;
; =============================================================================

align 16
db 'DEBUG: SMP      '
align 16


; -----------------------------------------------------------------------------
; os_smp_call -- Set a certain CPU to run a piece of code
;  IN:	AL = CPU #
;		BL = int #
; OUT:	
os_smp_call:
	push rdi
	push rbx
	push rax

	mov rdi, [os_LocalAPICAddress]
	add rdi, 0x0310
	shl rax, 24		; AL holds the CPU #, shift left 24 bits to get it into 31:24, 23:0 are reserved
	stosd
	
	xor rax, rax

	mov rdi, [os_LocalAPICAddress]
	add rdi, 0x0300
	mov al, bl		; BL holds the int #, 8:0 for the int,
	stosd

	pop rax
	pop rbx
	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_localid -- Returns the APIC ID of the CPU that ran this function
;  IN:	Nothing
; OUT:	RAX = CPU ID number
os_smp_localid:
	push rsi

	mov rsi, [os_LocalAPICAddress]
	add rsi, 0x20
	lodsd
	shr rax, 24		; AL now holds the CPU's APIC ID

	pop rsi
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
