; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; Include file for Bare Metal program development (API version 1)
; =============================================================================


os_print_string		equ	0x0000000000100010	; Displays text, IN: RSI = message location (zero-terminated string)
os_print_char		equ	0x0000000000100018	; Displays a char, IN: AL = char to display
os_print_char_hex	equ	0x0000000000100020	; Displays a char in hex mode, AL = char to display
os_print_newline	equ	0x0000000000100028	; Print a new line
os_check_for_key	equ	0x0000000000100030	; Scans keyboard for input, but doesn't wait, OUT: AL = 0 if no key pressed, otherwise ASCII code, other regs preserved
os_wait_for_key		equ	0x0000000000100038	; Waits for keypress and returns key, OUT: AL = key pressed, other regs preserved
os_input_string		equ	0x0000000000100040	; Take string from keyboard entry, IN/OUT: RDI = location where string will be stored
os_delay		equ	0x0000000000100048	; 
os_speaker_tone		equ	0x0000000000100050	; Generate PC speaker tone (call os_speaker_off after), IN: RAX = note frequency
os_speaker_off		equ	0x0000000000100058	; 
os_speaker_beep		equ	0x0000000000100060	; 
os_move_cursor		equ	0x0000000000100068	; 
os_string_length	equ	0x0000000000100070	; 
os_find_char_in_string	equ	0x0000000000100078	; 
os_string_copy		equ	0x0000000000100080	; 
os_string_truncate	equ	0x0000000000100088	; 
os_string_join		equ	0x0000000000100090	; 
os_string_chomp		equ	0x0000000000100098	; 
os_string_strip		equ	0x00000000001000A0	;
os_string_compare	equ	0x00000000001000A8	; 
os_string_uppercase	equ	0x00000000001000B0	; 
os_string_lowercase	equ	0x00000000001000B8	; 
os_int_to_string	equ	0x00000000001000C0	; 
os_dump_reg		equ	0x00000000001000C8	; 
os_dump_mem		equ	0x00000000001000D0	;
os_dump_rax		equ	0x00000000001000D8	;
os_string_to_int	equ	0x00000000001000E0	; 
os_smp_get_id		equ	0x00000000001000E8	;
os_smp_set_task		equ	0x00000000001000F0	;
os_smp_wakeup		equ	0x00000000001000F8	;
os_smp_find_free	equ	0x0000000000100100	;
os_smp_wakeup_all	equ	0x0000000000100108	;
os_smp_wait_for_aps	equ	0x0000000000100110	;
os_smp_set_free		equ	0x0000000000100118	;
os_serial_send		equ	0x0000000000100120	;
os_serial_recv		equ	0x0000000000100128	;
os_string_parse		equ	0x0000000000100130	;

; =============================================================================
; EOF
