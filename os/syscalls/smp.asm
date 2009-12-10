; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; SMP Functions
; =============================================================================

align 16
db 'DEBUG: SMP      '
align 16


; -----------------------------------------------------------------------------
; os_smp_call -- Set a CPU/Core to run a piece of code
;  IN:	AL = CPU #
;	RBX = location of code to return to
; OUT:	Nothing. All registers preserved.
; Note:	This code gets an AP to modify its stack to reprogram the return RIP after the IRETQ
;	For setup use only.
;	Uses interrupt 0x81 to pull the address from the stagingarea into the AP stack
os_smp_call:
	push rdi
	push rbx
	push rax

	mov [stagingarea], rbx
	mov rdi, [os_LocalAPICAddress]
	push rdi
	add rdi, 0x0310
	shl rax, 24		; AL holds the CPU #, shift left 24 bits to get it into 31:24, 23:0 are reserved
	stosd
	xor rax, rax
	pop rdi
	add rdi, 0x0300
	mov al, 0x81
	stosd

	pop rax
	pop rbx
	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_wakeup -- Wake up a CPU/Core
;  IN:	AL = CPU #
; OUT:	Nothing. All registers perserved.
; Note:	Uses interrupt 0x80. Just a stub interrupt with no real code behind it.
os_smp_wakeup:
	push rdi
	push rax

	mov rdi, [os_LocalAPICAddress]	; Load the address of the LAPIC from memory
	push rdi		; Save the RDI register so we don't need to load from memory twice
	add rdi, 0x0310
	shl rax, 24		; AL holds the CPU #, shift left 24 bits to get it into 31:24, 23:0 are reserved
	stosd
	xor rax, rax
	pop rdi			; Restore RDI from the stack. Saves a second memory load
	add rdi, 0x0300
	mov al, 0x80		; 0x80 is our wakeup interrupt
	stosd

	pop rax
	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_wakeup_all -- Wake up all CPU's (except self)
;  IN:	Nothing
; OUT:	Nothing. All registers perserved.
; Note:	Should use os_smp_wakeup
os_smp_wakeup_all:
	push rdi
	push rax

	mov rdi, [os_LocalAPICAddress]	; Load the address of the LAPIC from memory
	push rdi		; Save the RDI register so we don't need to load from memory twice
	add rdi, 0x0310
	xor rax, rax		; Nothing needed here
	stosd
	xor rax, rax
	pop rdi			; Restore RDI from the stack. Saves a second memory load
	add rdi, 0x0300
	mov eax, 0x000C0080	; 0x0C for all except self, 0x80 is our wakeup interrupt
	stosd

	pop rax
	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_set_task -- Set an AP to execute a piece of code
;  IN:	RAX = CPU #
;	RBX = Code to execute
;	RCX = Data to work on
; OUT:	Nothing
os_smp_set_task:
	push rdi
	push rax

	shl rax, 4		; Quick multiply by 16 as each record (code+data) is 16 bytes (64bits x2)
	mov rdi, taskdata
	add rdi, rax		; Add the offset to RDI
	mov rax, rbx
	stosq			; Store the address of the code to execute
	mov rax, rcx
	stosq			; Store the address of/data itself for AP to use (if any)

	pop rax
	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_get_id -- Returns the APIC ID of the CPU that ran this function
;  IN:	Nothing
; OUT:	RAX = CPU's APIC ID number, All other registers perserved.
os_smp_get_id:
	push rsi

	xor rax, rax		; We clear RAX since lodsd does not clear the high 32 bits
	mov rsi, [os_LocalAPICAddress]
	add rsi, 0x20		; Add the offset for the APIC ID location
	lodsd			; APIC ID is stored in bits 31:24
	shr rax, 24		; AL now holds the CPU's APIC ID (0 - 255)

	pop rsi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_find_free -- Returns the APIC ID of a free (not busy) CPU
;  IN:	Nothing
; OUT:	RAX = CPU ID of first free (not busy) CPU
;	Carry flag = Set if a free CPU was not found
os_smp_find_free:
	push rsi
	push rcx

	xor rcx, rcx

	mov rsi, taskdata			; Set RSI to the location of the task data
os_smp_find_free_load:
	lodsq					; Load the code value
	cmp rax, 0x0000000000000000
	je os_smp_find_free_found		; If NULL then we found a free CPU
	lodsq					; Load the data value
	add rcx, 1
	cmp rcx, 256
	je os_smp_find_free_not_found
	jmp os_smp_find_free_load

os_smp_find_free_found:
	mov rax, rcx				; Copy the APIC ID to RAX
	clc					; Clear the carry flag as it was a success

	pop rcx
	pop rsi
	ret

os_smp_find_free_not_found:
	stc					; Set the carry flag as it was a failure

	pop rcx
	pop rsi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_set_free -- Set a free CPU to run some code
;  IN:	Nothing
; OUT:	RAX = Address of Code
;	RBX = Address of Data/Variable
;	Carry flag = Set if a free CPU was not found
os_smp_set_free:
	push rsi
	push rdi
	push rdx
	push rcx

	mov rdx, rax				; Save the code address as lodsq will clobber RAX
	xor rcx, rcx
	mov rsi, taskdata			; Set RSI to the location of the task data
os_smp_set_free_load:
	mov rdi, rsi
	lodsq					; Load the code value
	cmp rax, 0x0000000000000000
	je os_smp_set_free_found		; If NULL then we found a free CPU
	lodsq					; Load the data value
	add rcx, 1
	cmp rcx, 256
	jne os_smp_set_free_load		; If RCX is equal to 256 then fall through
	stc					; Set the carry flag as it was a failure
	jmp os_smp_set_free_end

os_smp_set_free_found:
	clc					; Clear the carry flag as it was a success
	mov rax, rdx				; Put the code address back into RAX
	stosq					; Store the code address
	xchg rax, rbx
	stosq					; Store the data/data address
	xchg rax, rbx

os_smp_set_free_end:
	pop rcx
	pop rdx
	pop rdi
	pop rsi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_smp_wait_for_aps -- Wait for all AP's to finish
;  IN:	Nothing
; OUT:	Nothing. All registers preserved.
os_smp_wait_for_aps:
	push rsi
	push rcx
	push rax

	mov rsi, taskdata			; Set RSI to the location of the task data
	add rsi, 24				; Skip the BSP entry (16 bytes) and the first AP code entry (8 bytes)
	xor rcx, rcx

os_smp_check_next:
	sub rsi, 8
	lodsq					; Load the code value
	cmp rax, 0x0000000000000000		; If all bits are clear then this AP is idle
	je os_smp_check_foundfree
	cmp rax, 0xFFFFFFFFFFFFFFFF		; If all bits are set then this AP is unusable
	jne os_smp_check_next			; If it was equal we will just fall through to found_free

os_smp_check_foundfree:
	add rsi, 16				; Skip to next record
	add rcx, 1
	cmp rcx, 255
	jne os_smp_check_next

	pop rax
	pop rcx
	pop rsi
	ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
