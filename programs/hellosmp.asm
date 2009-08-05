[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.inc"

start:						; Start of program label

call ap_print_hello			; Once for the BSP to print hello

mov al, 0x01				; Once for each AP
mov rbx, ap_print_hello
call os_dosomething

mov al, 0x02
mov rbx, ap_print_hello
call os_dosomething

mov al, 0x03
mov rbx, ap_print_hello
call os_dosomething

ret							; Return to OS


ap_print_hello:
	mov rsi, hellofrom
	call os_print_string
	call os_smp_localid

	mov rdi, tempstring
	mov rsi, rdi
	call os_int_to_string
	call os_print_string
ret

	hellofrom db '  Hello from CPU #', 0

