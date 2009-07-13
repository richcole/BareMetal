; =============================================================================
; Bare Metal OS -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008 Ian Seyler -- see LICENSE.TXT
;
;
; =============================================================================

align 16
db 'DEBUG: SOUND    '
align 16


; -----------------------------------------------------------------------------
; os_speaker_tone -- Generate PC speaker tone (call os_speaker_off after)
; IN:	RAX = note frequency
; OUT:	Nothing (registers preserved)
os_speaker_tone:
	push rax
	push rcx

	mov cx, ax		; Store note value for now

	mov al, 182
	out 0x43, al	; System timers..
	mov ax, cx		; Set up frequency
	out 0x42, al
	mov al, ah		; 64-bit mode.... AH allowed????
	out 0x42, al

	in al, 0x61		; Switch PC speaker on
	or al, 0x03
	out 0x61, al

	pop rcx
	pop rax
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_speaker_off -- Turn off PC speaker
; IN:	Nothing
; OUT:	Nothing (registers preserved)
os_speaker_off:
	push rax

	in al, 0x61		; Switch PC speaker off
	and al, 0xFC
	out 0x61, al

	pop rax
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_speaker_beep -- Create a standard OS beep
; IN:	Nothing
; OUT:	Nothing (registers preserved)
os_speaker_beep:
	push rax
	push rcx

	mov rax, 0x0000000000000C80
	call os_speaker_tone
	mov rcx, 0x0000000000000008
	call os_delay
	call os_speaker_off

	pop rcx
	pop rax
	ret
; -----------------------------------------------------------------------------

; =============================================================================
; EOF
