; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; System Variables
; =============================================================================

align 16
db 'DEBUG: SYSVAR   '
align 16

; Constants
hextable: 		db '0123456789ABCDEF'

; Strings
readymsg:		db 'BareMetal is ready.', 0
prompt:			db '> ', 0
space:			db ' ', 0
newline:		db 13, 0

; HD info
hd1_enable:		db 0 ; 1 if the drive is there and enabled
hd1_lba48:		db 0 ; 1 if LBA48 is allowed
hd1_size:		dd 0x00000000 ; size in MiB
hd1_maxlba:		dq 0x0000000000000000 ; we need at least a 64-bit value since at most it will hold a 48-bit value
hdtempstring:		times 8 db 0

; Memory addresses
hdbuffer:		equ 0x0000000000070000	; 32768 bytes = 0x70000 -> 0x77FFF
hdbuffer1:		equ 0x0000000000078000	; 32768 bytes = 0x78000 -> 0x7FFFF
cli_temp_string:	equ 0x0000000000080000	; 1024 bytes = 0x80000 -> 0x803FF
os_temp_string:		equ 0x0000000000080400	; 1024 bytes = 0x00400 -> 0x807FF
programlocation:	equ 0x0000000000200000	; Location in memory where programs are loaded (the start of 2M)
taskdata:		equ 0x00000000001FF000	; Location of task data (4KB before the 2MB mark)
stackbase:		equ 0x0000000000050400	; Address for the base of the stacks

os_LocalAPICAddress	dq 0x0000000000000000
os_IOAPICAddress	dq 0x0000000000000000
timer_counter:		dq 0x0000000000000000	; 64-bit system counter
stagingarea		dq 0x0000000000000000
os_random_seed		dq 0x0000000000000000	; Seed for RNG
cpu_speed:		dd 0x00000000
ram_amount:		dw 0x0000
os_NumCores:		dw 0x0000
cursorx:		db 0x00		; cursor row location
cursory:		db 0x00		; cursor column location
scancode:		db 0x00
key:			db 0x00
timer_debug_counter:	db 0x30 ; '0'
keyboard_debug_counter:	db 0x30 ; '0'
clock_debug_counter:	db 0x30 ; '0'
screen_rows: 		db 25 ; x
screen_cols: 		db 80 ; y
screen_cursor_x:	db 0x00
screen_cursor_y:	db 0x00
screen_cursor_offset:	dq 0x0000000000000000

; Function variables
os_dump_reg_stage:	db 0x00

; File System
fat16_BytesPerSector:		dw 0x0000
fat16_SectorsPerCluster:	db 0x00
fat16_ReservedSectors:		dw 0x0000
fat16_FatStart:			dd 0x00000000
fat16_Fats:			db 0x00
fat16_SectorsPerFat:		dw 0x0000
fat16_TotalSectors:		dd 0x00000000
fat16_RootDirEnts:		dw 0x0000
fat16_DataStart:		dd 0x00000000
fat16_RootStart:		dd 0x00000000

keylayoutlower:
db 0, '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x0e, 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x1c, 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 0, 0, 0, 0, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, 0, 0, ' ', 0
	
;keylayoutupper:
;db 0, '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 0x0e, 0, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U','I', 'O', 'P', '{', '}', 0x1c, 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', 0, 0, 0, 0, 'Z', 'X', 'C', 'V', 'B', 'N', 'M' , '<', '>', '?', 0, 0, 0, ' ', 0

cli_command_string:	times 14 db 0
cli_args:		db 0
; 0e = backspace
; 1c = enter

;------------------------------------------------------------------------------

SYS64_CODE_SEL	equ 8		; defined by Pure64

; =============================================================================
; EOF
