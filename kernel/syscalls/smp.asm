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
;  IN:	CPU #, Address to execute
; OUT:	
os_smp_call:
	push rax

	pop rax
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_localid -- Returns the ID of the CPU that ran this function
;  IN:	Nothing
; OUT:	RAX = CPU ID number
os_smp_localid:
	push rax

	pop rax
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
