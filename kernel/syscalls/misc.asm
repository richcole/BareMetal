; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; Misc Functions
; =============================================================================

align 16
db 'DEBUG: MISC     '
align 16


; -----------------------------------------------------------------------------
; Show a incrementing digit on the screen... as long as it is incrementing the system is working (not hung)
; After 9 it wraps back to 0
showprogress0:
	push rax
	mov al, [progress0]
	mov [0x00000000000B809E], al		; we write the digit to the top right corner
	inc al
	cmp al, 0x3A ; 0x39 is '9'
	jne showprogress0_end
	mov al, 0x30

showprogress0_end:
	mov [progress0], al
	pop rax
	ret

progress0:	db 0x30 ; '0'
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Show a incrementing digit on the screen... as long as it is incrementing the system is working (not hung)
; After 9 it wraps back to 0
showprogress1:
	push rax
	mov al, [progress1]
	mov [0x00000000000B809C], al		; we write the digit to the top right corner
	inc al
	cmp al, 0x3A ; 0x39 is '9'
	jne showprogress1_end
	mov al, 0x30

showprogress1_end:
	mov [progress1], al
	pop rax
	ret

progress1: db 0x30 ; '0'
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_delay -- Delay by X
; IN:	RCX = Time in hundredths of a second
; OUT:	All registers preserved
; A value of 100 in RCX will delay 1 second and a value of 1 will delay 1/100 of a second
; This function depends on the PIT (IRQ 0) so interrupts must be enabled.
os_delay:
	push rcx
	push rax

	mov rax, [timer_counter_lo]	; Grab the initial timer counter. It increments 100 times a second
	add rcx, rax			; Add RCX so we get the end time we want
os_delay_loop:
	mov rax, [timer_counter_lo]	; Grab the timer couter again
	cmp rax, rcx			; Compare it against our end time
	jle os_delay_loop		; Loop if RCX is still lower

	pop rax
	pop rcx
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
