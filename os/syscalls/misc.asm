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
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_delay -- Delay by X
; IN:	RAX = Time in hundredths of a second
; OUT:	All registers preserved
; A value of 100 in RAX will delay 1 second and a value of 1 will delay 1/100 of a second
; This function depends on the PIT (IRQ 0) so interrupts must be enabled.
os_delay:
	push rcx
	push rax

	mov rcx, [timer_counter]	; Grab the initial timer counter. It increments 100 times a second
	add rax, rcx			; Add RCX so we get the end time we want
os_delay_loop:
	cmp qword [timer_counter], rax	; Compare it against our end time
	jle os_delay_loop		; Loop if RAX is still lower

	pop rax
	pop rcx
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_seed_random -- Seed the RNG based on the current date and time
; IN:	Nothing
; OUT:	All registers preserved
os_seed_random:
	push rbx
	push rax

	xor rbx, rbx
	mov al, 0x32		; century
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl rbx, 8
	mov al, 0x09		; year
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl rbx, 8
	mov al, 0x08		; month
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl rbx, 8
	mov al, 0x07		; day
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl rbx, 8
	mov al, 0x04		; hour
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl rbx, 8
	mov al, 0x02		; minute
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl rbx, 8
	mov al, 0x00		; second
	out 0x70, al
	in al, 0x71
	mov bl, al
	mov [os_random_seed], rbx	; Seed will be something like 0x0020091229164435
	;shift again and get rtsc?

	pop rax
	pop rbx
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_get_random -- Return a random integer
; IN:	Nothing
; OUT:	RAX = Random number
;	All other registers preserved
os_get_random:
	push rdx
	push rbx

	mov rax, [os_random_seed]
	mov rdx, 0x0019660D0019660D
	mul rdx
	mov rbx, 0x3C6EF35F3C6EF35F
	add rax, rbx
	mov [os_random_seed], rax

	pop rbx
	pop rdx
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_get_random_integer -- Return a random integer between Low and High (incl)
; IN:	RAX = Low integer
;	RBX = High integer
; OUT:	RCX = Random integer
os_get_random_integer:
	push rdx
	push rbx
	push rax

	sub rbx, rax		; We want to look for a number between 0 and (High-Low)
	call os_get_random
	mov rdx, rbx
	add rdx, 1
	mul rdx
	mov rcx, rdx

	pop rax
	pop rbx
	pop rdx
	add rcx, rax		; Add the low offset back
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
