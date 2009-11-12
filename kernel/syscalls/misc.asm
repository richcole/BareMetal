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
timer_debug:
	push rdi
	push rax

	mov rdi, 0x00000000000B809C
	mov al, 'T'
	stosb
	inc rdi
	mov al, [timer_debug_counter]
	stosb
	inc al
	cmp al, 0x3A ; 0x39 is '9'
	jne timer_debug_end
	mov al, 0x30

timer_debug_end:
	mov [timer_debug_counter], al
	pop rax
	pop rdi
	ret

timer_debug_counter:	db 0x30 ; '0'
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Show a incrementing digit on the screen... as long as it is incrementing the system is working (not hung)
; After 9 it wraps back to 0
keyboard_debug:
	push rdi
	push rax

	mov rdi, 0x00000000000B8090
	mov al, 'K'
	stosb
	inc rdi
	mov al, [keyboard_debug_counter]
	stosb
	inc al
	cmp al, 0x3A ; 0x39 is '9'
	jne keyboard_debug_end
	mov al, 0x30

keyboard_debug_end:
	mov [keyboard_debug_counter], al
	pop rax
	pop rdi
	ret

keyboard_debug_counter:	db 0x30 ; '0'
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Show a incrementing digit on the screen... as long as it is incrementing the system is working (not hung)
; After 9 it wraps back to 0
clock_debug:
	push rdi
	push rax

	mov rdi, 0x00000000000B8096
	mov al, 'C'
	stosb
	inc rdi
	mov al, [clock_debug_counter]
	stosb
	inc al
	cmp al, 0x3A ; 0x39 is '9'
	jne clock_debug_end
	mov al, 0x30

clock_debug_end:
	mov [clock_debug_counter], al
	pop rax
	pop rdi
	ret

clock_debug_counter: db 0x30 ; '0'
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

	mov rax, [timer_counter]	; Grab the initial timer counter. It increments 100 times a second
	add rcx, rax			; Add RCX so we get the end time we want
os_delay_loop:
	mov rax, [timer_counter]	; Grab the timer couter again
	cmp rax, rcx			; Compare it against our end time
	jle os_delay_loop		; Loop if RCX is still lower

	pop rax
	pop rcx
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
