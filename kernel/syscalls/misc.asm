; =============================================================================
; Bare Metal OS -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008 Ian Seyler -- see LICENSE.TXT
;
;
; =============================================================================

align 16
db 'DEBUG: MISC     '
align 16


; -----------------------------------------------------------------------------
; Show a incrementing digit on the screen... as long as it is incrementing the system is working (not hung)
; After 9 it wraps back to 0
;showprogress64:
;	push rax
;	mov al, [progress64]
;	mov [0x00000000000B809E], al		; we write the digit to the top right corner
;	inc al
;	cmp al, 0x3A ; 0x39 is '9'
;	jne showprogress64_end
;	mov al, 0x30
;
;showprogress64_end:
;	mov [progress64], al
;	pop rax
;	ret
;
;progress64:	db 0x30 ; '0'
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_delay -- Delay by X microseconds
; IN:	RCX
; OUT:	RCX = 0
; 1 second = 1000000 microseconds
; 1 milisecond = 1000 microseconds
os_delay:
	push rax

;	mov [delay_timer], rcx
;os_delay_loop:
;	mov rax, [delay_timer]
;	cmp rax, 0
;	jne os_delay_loop

	pop rax
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
