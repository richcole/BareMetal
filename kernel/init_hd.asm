; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; INIT HDD
; =============================================================================

align 16
db 'DEBUG: INIT_HDD '
align 16


hd_setup:

; Check if drive supports LBA48

; Read first sector into memory
mov rax, 0
mov rdi, hdbuffer
push rdi
call readsector
pop rdi

;get the values we need to start using fat32
xor rax, rax
mov ax, [rdi+0x0b]
mov [fat32_bytespersector], ax ; will probably be 512
mov al, [rdi+0x0d]
mov [fat32_sectorspercluster], al
mov ax, [rdi+0x0e]
mov [fat32_reservedsectors], ax
mov [fat32_FatStart], eax
mov al, [rdi+0x10]
mov [fat32_numoffats], al ; will probably be 2
mov eax, [rdi+0x20]
mov [fat32_totalsectors], eax
mov eax, [rdi+0x24]
mov [fat32_sectorsperfat], eax
mov eax, [rdi+0x2c]
mov [fat32_rootcluster], eax

xor rax, rax
mov eax, [fat32_totalsectors]
mov [hd1_maxlba], rax
shr rax, 11 ; rax = rax * 512 / 1048576
mov [hd1_size], eax ; in megabytes

xor rax, rax
xor rbx, rbx
xor rdx, rdx
mov eax, [fat32_sectorsperfat]
mov bl, [fat32_numoffats]
mul ebx ;EDX:EAX = EAX * EBX
mov bx, [fat32_reservedsectors]
add eax, ebx
mov [fat32_ClusterStart], eax ; fat32_reservedsectors + (fat32_numoffats * fat32_sectorsperfat)

ret

temphdstring: times 10 db 0


; =============================================================================
; EOF
