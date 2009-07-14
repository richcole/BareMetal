; =============================================================================
; Bare Metal OS -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008 Ian Seyler -- see LICENSE.TXT
;
;
; =============================================================================

align 16
db 'DEBUG: MATH     '
align 16


; -----------------------------------------------------------------------------
; os_oword_add -- 
; IN:	RDX,RAX = Value 1, RCX,RBX = Value 2
; OUT:	RDX,RAX = Result
; Note:	Carry set if overflow
os_oword_add:
	add rax, rbx
	adc rdx, rcx
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
