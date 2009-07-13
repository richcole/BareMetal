[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.inc"

start:						; Start of program label

	mov rsi, startmessage		; Load RSI with memory address of string
	call os_print_string		; Print the string that RSI points to

;Get processor brand string
	xor rax, rax
	mov rdi, tstring
	mov eax, 0x80000002
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	mov eax, 0x80000003
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	mov eax, 0x80000004
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	mov rax, tstring
	call os_string_chomp
	mov rsi, cpustringmsg
	call os_print_string
	mov rsi, tstring
	call os_print_string

;get L1 cache info
mov eax, 0x80000005	; L1 cache info
cpuid

mov eax, edx		; edx bits 31 .. 24 store code L1 cache size in KB
;call os_dump_rax
shr eax, 24
mov rdi, tstring
call os_int_to_string
call os_print_newline
mov rsi, l1codecachemsg
call os_print_string
mov rsi, tstring
call os_print_string
mov rsi, kbmsg
call os_print_string


mov eax, ecx		; ecx bits 31 .. 24 store data L1 cache size in KB
;call os_dump_rax
shr eax, 24
mov rdi, tstring
call os_int_to_string
call os_print_newline
mov rsi, l1datacachemsg
call os_print_string
mov rsi, tstring
call os_print_string
mov rsi, kbmsg
call os_print_string

;get L2 cache info
mov eax, 0x80000006	; L2/L3 cache info
cpuid
mov eax, ecx
shr eax, 16
mov rdi, tstring
call os_int_to_string
call os_print_newline
mov rsi, l2cachemsg
call os_print_string
mov rsi, tstring
call os_print_string
mov rsi, kbmsg
call os_print_string

;call os_dump_rax
;call os_print_newline
;mov eax, edx
;shr eax, 14
;call os_dump_rax
	
	call os_print_newline


ret							; Return to OS

startmessage: db 'System Information:', 13, 0
cpustringmsg: db 'CPU String: ', 0
l1codecachemsg: db 'L1 code cache: ', 0
l1datacachemsg: db 'L1 data cache: ', 0
l2cachemsg: db 'L2 cache: ', 0
kbmsg: db 'KB', 0
;l3cachemessage1: db 'L3 cache: ', 0
;l3cachemessage2: db 'KB', 0

tstring: times 48 db 0