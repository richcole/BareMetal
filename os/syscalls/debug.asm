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
; os_debug_dump_reg -- Dump the values on the registers to the screen (For debug purposes)
;  IN:	Nothing
; OUT:	Nothing, all registers preserved
os_debug_dump_reg:
	push r15					; Push all of the registers to the stack
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

	mov byte [os_debug_dump_reg_stage], 0x00	; Reset the stage to 0 since we are starting
os_debug_dump_reg_next:
	mov rsi, os_debug_dump_reg_string00
	xor rax, rax
	xor rbx, rbx
	mov al, [os_debug_dump_reg_stage]
	mov bl, 5					; Each string is 5 bytes
	mul bl						; AX = BL x AL
	add rsi, rax					; Add the offset to get to the correct string
	call os_print_string				; Print the register name
	pop rax						; Pop the register from the stack
	call os_debug_dump_rax				; Print the hex string value of RAX
	inc byte [os_debug_dump_reg_stage]
	cmp byte [os_debug_dump_reg_stage], 0x10	; Check to see if all 16 registers are displayed
	jne os_debug_dump_reg_next

	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_debug_dump_mem -- Dump some memory content to the screen
;  IN:	RSI = Start of memory address to dump
;	RCX = number of bytes to dump
; OUT:	Nothing, all registers preserved
os_debug_dump_mem:
	push rsi
	push rcx
	push rax

os_debug_dump_mem_next_byte:
	lodsb
	call os_print_char_hex
	dec rcx
	jnz os_debug_dump_mem_next_byte	; jump if RCX is not equal to zero

	pop rax
	pop rcx
	pop rsi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_debug_dump_rax -- Dump content of RAX to the screen in hex format
;  IN:	RAX = content to dump
; OUT:	Nothing, all registers preserved
os_debug_dump_rax:
	push rsi
	push rdi

	mov rdi, os_temp_string
	mov rsi, rdi
	call os_int_to_hex_string
	call os_print_string

	pop rdi
	pop rsi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_debug_get_ip -- Dump content of RIP into RAX
;  IN:	Nothing
; OUT:	RAX = RIP
os_debug_get_ip:
	mov rax, qword [rsp]
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
