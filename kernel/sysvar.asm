; =============================================================================
; Bare Metal OS -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008 Ian Seyler -- see LICENSE.TXT
;
; System Variables
; =============================================================================

align 16
db 'DEBUG: SYSVAR   '
align 16


%DEFINE BAREMETALOS_VER 'v0.4 (July 13, 2009)'
%DEFINE BAREMETALOS_API_VER 1

; Strings
readymsg: db 'BareMetal is ready.', 0
prompt: db '> ', 0
space: db ' ', 0

; HD info
hd1_enable: db 0 ; 1 if the drive is there and enabled
hd1_lba48: db 0 ; 1 if LBA48 is allowed
hd1_size: dd 0x00000000 ; size in MiB
hd1_maxlba: dq 0x0000000000000000 ; we need at least a 64-bit value since at most it will hold a 48-bit value

; Memory addresses
hdbuffer:			equ 0x0000000000070000 ; 32768 bytes = 0x70000 -> 0x77FFF
hdbuffer1:			equ 0x0000000000078000 ; 32768 bytes = 0x78000 -> 0x7FFFF
consoleinputstring:	equ 0x0000000000080000 ; 256 bytes = 0xE200 -> 0xE2FF
tempstring:			equ 0x0000000000080100 ; 256 bytes = 0xE300 -> 0xE3FF
input:				equ 0x0000000000080200 ; 256 bytes = 0xE400 -> 0xE4FF		; times 255 db 0
dirlist:			equ 0x0000000000080300 ; 256 bytes = 0xE500 -> 0xE5FF		; times 255 db 0
promptbuf:			equ 0x0000000000080400 ; 256 bytes = 0xE600 -> 0xE6FF		; times 255 db 0
programlocation:	equ 0x0000000000200000 ; Location in memory where programs are loaded (the start of 2M)
;hdtempstring:		times 8 db 0
;memtempstring:		times 8 db 0
;cpunumtempstring:	times 8 db 0
;cpuspeedtempstring:	times 8 db 0
;timestring:			times 9 db 0 ; "HH:MM:SS"
;datestring:			times 11 db 0 ; "YYYY/MM/DD"
ram_amount:			dw 0x0000
cpu_speed:			dd 0x00000000
cursorx:			db 0x00		; cursor row location
cursory:			db 0x00		; cursor column location
hextable: 			db '0123456789ABCDEF'

screen_rows 		db 25 ; x
screen_cols 		db 80 ; y
screen_cursor_x		db 0x00
screen_cursor_y		db 0x00
screen_cursor_offset	dq 0x0000000000000000

keylayoutlower:
db 0, '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x0e, 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x1c, 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 0, 0, 0, 0, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, 0, 0, ' ', 0
	
keylayoutupper:
db 0, '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 0x0e, 0, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U','I', 'O', 'P', '{', '}', 0x1c, 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', 0, 0, 0, 0, 'Z', 'X', 'C', 'V', 'B', 'N', 'M' , '<', '>', '?', 0, 0, 0, ' ', 0

; 0e = backspace
; 1c = enter

.blank db 0x20, 0x00

;--------------------------------------------------------------------

SYS64_CODE_SEL	equ 8		; defined by Pure64

;align 8
;IDTR64:						; Interrupt Descriptor Table Register
;	dw 256*16-1				; limit of IDT (size minus one) (4096 bytes - 1)
;	dq 0x0000000000000000	; linear address of IDT

; =============================================================================
; EOF
