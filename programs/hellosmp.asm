[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.inc"

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
	mov rsi, hellofrom
	call os_print_string
	call os_smp_get_id

	mov rdi, tempstring
	mov rsi, rdi
	call os_int_to_string
	call os_print_string
ret

	hellofrom db '  Hello from CPU #', 0

tempstring:
