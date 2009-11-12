; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; Debug functions
; =============================================================================

align 16
db 'DEBUG: DEBUG    '
align 16


; -----------------------------------------------------------------------------
; os_dump_reg -- Dump the values on the registers to the screen (For debug purposes)
;  IN:	Nothing
; OUT:	Nothing, all registers preserved
os_dump_reg:
	push r15	; Push all of the major registers to the stack
	push r14
	push r13
	push r12
	push r11
	push r10
	push r9
	push r8
	push rsp
	push rbp
	push rdi
	push rsi
	push rdx
	push rcx
	push rbx
	push rax

	mov byte [os_dump_reg_stage], 0x00	; Reset the stage to 0 since we are starting
again:
	mov rsi, os_dump_reg_string00
	xor rax, rax
	xor rbx, rbx
	mov al, [os_dump_reg_stage]
	mov bl, 5	; each string is 5 bytes
	mul bl		; ax = bl x al
	add rsi, rax
	call os_print_string			; Print the register name
	pop rax							; Pop the next register from the stack
	call os_dump_rax				; Print the hex string vale of RAX
	inc byte [os_dump_reg_stage]
	cmp byte [os_dump_reg_stage], 0x10
	jne again

	ret

os_dump_reg_string00:	db '  A:', 0
os_dump_reg_string01:	db '  B:', 0
os_dump_reg_string02:	db '  C:', 0
os_dump_reg_string03:	db '  D:', 0
os_dump_reg_string04:	db ' SI:', 0
os_dump_reg_string05:	db ' DI:', 0
os_dump_reg_string06:	db ' BP:', 0
os_dump_reg_string07:	db ' SP:', 0
os_dump_reg_string08:	db '  8:', 0
os_dump_reg_string09:	db '  9:', 0
os_dump_reg_string0A:	db ' 10:', 0
os_dump_reg_string0B:	db ' 11:', 0
os_dump_reg_string0C:	db ' 12:', 0
os_dump_reg_string0D:	db ' 13:', 0
os_dump_reg_string0E:	db ' 14:', 0
os_dump_reg_string0F:	db ' 15:', 0

os_dump_reg_stage:		db 0x00
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_dump_mem -- Dump some memory content to the screen
;  IN:	RSI = location of memory to dump
;	RCX = number of bytes to dump
; OUT:	Nothing, all registers preserved
os_dump_mem:
	push rsi
	push rcx
	push rax

os_dump_mem_next_byte:
	lodsb
	call os_print_char_hex
	dec rcx
	jnz os_dump_mem_next_byte	; jump if RCX is not equal to zero

	pop rax
	pop rcx
	pop rsi
ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_dump_rax -- Dump content of RAX to the screen in hex format
;  IN:	RAX = content to dump
; OUT:	Nothing, all registers preserved
os_dump_rax:
	push rsi
	push rdi

	mov rdi, tempstring
	mov rsi, rdi
	call os_int_to_hex_string
	call os_print_string

	pop rdi
	pop rsi
ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_get_ip -- Dump content of RIP into RAX
;  IN:	Nothing
; OUT:	RAX = RIP
os_get_ip:
	mov rax, qword [rsp]
ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
