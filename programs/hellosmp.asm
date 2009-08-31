[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.asm"

start:					; Start of program label

find_AP:				; Go though the AP's and find the free ones
	call os_smp_find_free		; Returns a free AP ID in RAX
	jc no_more			; If there are none then the Carry flag is set
	mov rbx, ap_print_hello
	call os_smp_set_task		; Set the AP to run the print_hello task
	jmp find_AP			; Check if there are more

no_more:
	call os_smp_wakeup_all		; Send a "wakeup call" to all AP's
	call ap_print_hello		; Once for the BSP to print hello
	call os_smp_wait_for_aps	; Once the BSP is done wait for all AP's
	call os_print_newline

ret					; Return to OS


ap_print_hello:
	bt word [mutex], 0	; Check if the lock is open
	jnc ap_print_hello	; If not check it again

	lock		; The lock was open, try to lock it
	btr word [mutex], 0	; Set the lock
	jnc ap_print_hello	; Check if we were able to lock it, if not the check again
	
	mov rsi, hellofrom
	call os_print_string
	call os_smp_get_id

	mov rdi, tempstring
	mov rsi, rdi
	call os_int_to_string
	call os_print_string
	
	bts word [mutex], 0	; Release the lock
ret

	hellofrom db '  Hello from CPU #', 0
	mutex dw 1	; Our MUTual-EXclustion flag

tempstring:
