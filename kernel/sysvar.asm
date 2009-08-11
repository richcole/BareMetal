; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; System Variables
; =============================================================================

align 16
db 'DEBUG: SYSVAR   '
align 16


%DEFINE BAREMETALOS_VER 'v0.4 (August 11, 2009)'
%DEFINE BAREMETALOS_API_VER 1

; Strings
readymsg:			db 'BareMetal is ready.', 0
prompt:				db '> ', 0
space:				db ' ', 0
newline:			db 13, 0

; HD info
hd1_enable:			db 0 ; 1 if the drive is there and enabled
hd1_lba48:			db 0 ; 1 if LBA48 is allowed
hd1_size:			dd 0x00000000 ; size in MiB
hd1_maxlba:			dq 0x0000000000000000 ; we need at least a 64-bit value since at most it will hold a 48-bit value

; Memory addresses
hdbuffer:			equ 0x0000000000070000 ; 32768 bytes = 0x70000 -> 0x77FFF
hdbuffer1:			equ 0x0000000000078000 ; 32768 bytes = 0x78000 -> 0x7FFFF
tempstring:			equ 0x0000000000080000 ; 1024 bytes = 0xE300 -> 0xE5FF
programlocation:	equ 0x0000000000200000 ; Location in memory where programs are loaded (the start of 2M)

os_LocalAPICAddress	dq 0x0000000000000000
os_IOAPICAddress	dq 0x0000000000000000
timer_counter_lo:	dq 0x0000000000000000 ; These timer counters make up the 128-bit system counter
timer_counter_hi:	dq 0x0000000000000000
stagingarea			dq 0x0000000000000000
ram_amount:			dw 0x0000
cpu_speed:			dd 0x00000000
cursorx:			db 0x00		; cursor row location
cursory:			db 0x00		; cursor column location
hextable: 			db '0123456789ABCDEF'
scancode:			db 0x00
kkey:				db 0x00

screen_rows 		db 25 ; x
screen_cols 		db 80 ; y
screen_cursor_x		db 0x00
screen_cursor_y		db 0x00
screen_cursor_offset	dq 0x0000000000000000

keylayoutlower:
db 0, '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x0e, 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x1c, 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 0, 0, 0, 0, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, 0, 0, ' ', 0
	
;keylayoutupper:
;db 0, '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 0x0e, 0, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U','I', 'O', 'P', '{', '}', 0x1c, 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', 0, 0, 0, 0, 'Z', 'X', 'C', 'V', 'B', 'N', 'M' , '<', '>', '?', 0, 0, 0, ' ', 0

; 0e = backspace
; 1c = enter

align 16
taskdata:
codecpu00	dq 0x0000000000000000
datacpu00	dq 0x0000000000000000
codecpu01	dq 0x0000000000000000
datacpu01	dq 0x0000000000000000
codecpu02	dq 0x0000000000000000
datacpu02	dq 0x0000000000000000
codecpu03	dq 0x0000000000000000
datacpu03	dq 0x0000000000000000

;--------------------------------------------------------------------

SYS64_CODE_SEL	equ 8		; defined by Pure64

; =============================================================================
; EOF
