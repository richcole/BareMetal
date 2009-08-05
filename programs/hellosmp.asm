[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.inc"

start:						; Start of program label

;mov rsi, hello_message		; Load RSI with memory address of string
;call os_print_string		; Print the string that RSI points to

;	push rsi
;	push rdi
;	push rax
;
;	mov rsi, hellofrom
;	call os_print_string
;	call os_smp_localid
;
;	mov rdi, tempstring
;	mov rsi, rdi
;	call os_int_to_string
;	call os_print_string
;
;	mov rdi, [os_LocalAPICAddress]
;	add rdi, 0xB0
;	xor rax, rax
;	stosd
;
;	pop rax
;	pop rdi
;	pop rsi
;	iretq
;
;	hellofrom db '  Hello from CPU #', 0

ret							; Return to OS

hello_message: db 'Hello, world!', 13, 0
