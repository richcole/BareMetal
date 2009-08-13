; -----------------------------------------------------------------
; Music keyboard
; Based on keyboard.asm from MikeOS
; Use Z key rightwards for an octave
; -----------------------------------------------------------------


[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.asm"

music_keyboard:

	mov rsi, startstring
	call os_print_string
	call os_print_newline

.retry:
	call os_wait_for_key

; And start matching keys with notes

	cmp al, 'z'
	jne .x
	mov al, 'C'
	call os_print_char	; Print note
	mov ax, 4000
	jmp .playnote

.x:
	cmp al, 'x'
	jne .c
	mov al, 'D'
	call os_print_char	; Print note
	mov ax, 3600
	jmp .playnote

.c:
	cmp al, 'c'
	jne .v
	mov al, 'E'
	call os_print_char	; Print note
	mov ax, 3200
	jmp .playnote

.v:
	cmp al, 'v'
	jne .b
	mov al, 'F'
	call os_print_char	; Print note
	mov ax, 3000
	jmp .playnote

.b:
	cmp al, 'b'
	jne .n
	mov al, 'G'
	call os_print_char	; Print note
	mov ax, 2700
	jmp .playnote

.n:
	cmp al, 'n'
	jne .m
	mov al, 'A'
	call os_print_char	; Print note
	mov ax, 2400
	jmp .playnote

.m:
	cmp al, 'm'
	jne .comma
	mov al, 'B'
	call os_print_char
	mov ax, 2100
	jmp .playnote

.comma:
	cmp al, ','
	jne .space
	mov al, 'C'
	call os_print_char
	mov ax, 2000
	jmp .playnote

.space:
	cmp al, ' '
	jne .q
	call os_speaker_off
	jmp .retry

.playnote:
	call os_speaker_tone
	jmp .retry

.q:
	cmp al, 'q'
	je .end
	cmp al, 'Q'
	je .end
	jmp .retry	; Didn't get any key we were expecting so try again.

.end:
	call os_speaker_off
	call os_print_newline
	ret			; Back to OS

; -----------------------------------------------------------------

startstring: db 'Musical keyboard. Use "Z"-"," to play notes. Space to stop the note. Q to quit.', 0