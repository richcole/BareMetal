[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.inc"

start:						; Start of program label



find_AP:
	call os_smp_find_free
	jc no_more
	mov rbx, ap_print_hello
	call os_smp_set_task
	call os_smp_wakeup
	jmp find_AP

no_more:
	call ap_print_hello			; Once for the BSP to print hello

ret						; Return to OS


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
