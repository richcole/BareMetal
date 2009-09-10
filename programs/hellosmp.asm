[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.asm"

start:					; Start of program label

	mov rax, ap_print_hello

set_AP:					; Go though the AP's and find the free ones
	call os_smp_set_free		; Try to set a free AP to run the ap_print_hello function
	jc no_more			; If there are none then the Carry flag is set
	jmp set_AP			; Check if there are more

no_more:
	call os_smp_wakeup_all		; Send a "wakeup call" to all AP's
	call ap_print_hello		; Once for the BSP to print hello
	call os_smp_wait_for_aps	; Once the BSP is done wait for all AP's
	call os_print_newline

ret					; Return to OS


; This procedure will be executed by each of the processors
; It requires mutually exclusive access while it creates the string and prints to the screen
; We must insure that only one CPU at a time can execute this code, so we employ a 'spinlock'.
ap_print_hello:
	bt word [mutex], 0	; Check if the mutex is free
	jnc ap_print_hello	; If not check it again

	lock			; The mutex was free, lock the bus
	btr word [mutex], 0	; Try to grab the mutex
	jnc ap_print_hello	; Jump if we were unsuccessful

	mov rsi, hellofrom
	call os_print_string	; Print the "hello from" string

	call os_smp_get_id	; Get the local APIC ID
	mov rdi, tempstring
	mov rsi, rdi
	call os_int_to_string	; Convert it to a string
	call os_print_string	; Print the APIC ID

	bts word [mutex], 0	; Release the mutex
ret

	hellofrom db '  Hello from CPU #', 0
	mutex dw 1	; The MUTual-EXclustion flag

tempstring:

