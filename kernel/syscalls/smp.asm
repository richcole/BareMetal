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
;		RBX = location of code to return to
; OUT:	Nothing. All registers preserved.
; Note:	This code gets an AP to modify its stack to reprogram the return RIP after the IRETQ
;		For setup use only.
;		Uses interrupt 0x81 to pull the address from the stagingarea into the AP stack
os_smp_call:
	push rdi
	push rbx
	push rax

	mov [stagingarea], rbx
	
	mov rdi, [os_LocalAPICAddress]
	
	push rdi
	add rdi, 0x0310
	shl rax, 24		; AL holds the CPU #, shift left 24 bits to get it into 31:24, 23:0 are reserved
	stosd
	
	xor rax, rax

	pop rdi
	add rdi, 0x0300
	mov al, 0x81
	stosd

	pop rax
	pop rbx
	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_wakeup -- wake up a certain CPU
;  IN:	AL = CPU #
; OUT:	Nothing
; Note:	Uses interrupt 0x80. Just a stub interrupt with no real code behind it.
os_smp_wakeup:
	push rdi
	push rax
	
	mov rdi, [os_LocalAPICAddress]	; Load the address of the LAPIC from memory

	push rdi		; Save the RDI register so we don't need to load from memory twice
	add rdi, 0x0310
	shl rax, 24		; AL holds the CPU #, shift left 24 bits to get it into 31:24, 23:0 are reserved
	stosd
	
	xor rax, rax

	pop rdi			; Restore RDI from the stack. Saves a second memory load
	add rdi, 0x0300
	mov al, 0x80		; 0x80 is our wakeup interrupt
	stosd

	pop rax
	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_set_cpu_task -- 
;  IN:	RAX = CPU #
;		RBX = Code to execute
;		RCX = Data to work on
; OUT:	Nothing
os_set_cpu_task:
	push rdi
	push rbx
	push rax

	shl rax, 4		; quick multiply by 16 as each record (code+data) is 16 bytes (64bits x2)
	mov rdi, taskdata
	add rdi, rax
	mov rax, rbx
	stosq
	mov rax, rcx
	stosq

	pop rax
	pop rbx
	pop rdi
ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_localid -- Returns the APIC ID of the CPU that ran this function
;  IN:	Nothing
; OUT:	RAX = CPU ID number
os_smp_get_local_id:
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
