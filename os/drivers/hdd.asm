; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; Hard Drive Functions
; =============================================================================

align 16
db 'DEBUG: HDD      '
align 16


; -----------------------------------------------------------------------------
; readsector -- Read from a sector on the hard drive
; IN:	RAX = sector to read
;	RDI = memory location to store sector (512 Bytes)
; OUT:	RDI = RDI + 512
;	All other registers preserved
; This function uses Logical Block Addressing (LBA)
readsector:
	push rdx
	push rcx
	push rax

	push rax		; Save RAX since we are about to overwrite it
	mov dx, 0x01F2		; Sector count Port 7:0
	mov al, 1		; Read one sector, a value of 0 here would read 256 sectors
	out dx, al
	pop rax			; Restore RAX which is our sector number
	inc dx			; 0x01F3 - LBA Low Port 7:0
	out dx, al
	inc dx			; 0x01F4 - LBA Mid Port 15:8
	shr rax, 8
	out dx, al
	inc dx			; 0x01F5 - LBA High Port 23:16
	shr rax, 8
	out dx, al
	inc dx			; 0x01F6 - Device Port. Bit 6 set for LBA mode, Bit 4 for device (0 = master, 1 = slave), Bits 3-0 for LBA "Extra High" (27:24)
	shr rax, 8
	and al, 00001111b 	; Clear bits 4-7 just to be safe
	or al, 01000000b	; Turn bit 6 on since we want to use LBA addressing, leave device at 0 (master)
	out dx, al
	inc dx			; 0x01F7 - Command Port
	mov al, 0x20		; Read sector(s). 0x24 if LBA48
	out dx, al

readsector_wait:		; VERIFY THIS
	in al, dx
	test al, 8		; This means the sector buffer requires servicing.
	jz readsector_wait	; Don't continue until the sector buffer is ready.
	mov rcx, 256		; One sector is 512 bytes but we are reading 2 bytes at a time
	mov dx, 0x01F0		; Data port - data comes in and out of here.
	rep insw		; Read data to the address starting at RDI

	pop rax
	add rax, 1		; Point to the next sector
	pop rcx
	pop rdx
ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; writesector -- Write to a sector on the hard drive
; IN:	RAX = sector to write
;	RSI = memory location of data to write (512 Bytes)
; OUT:	RSI = RSI + 512
;	All other registers preserved
; This function uses Logical Block Addressing (LBA)
writesector:
	push rdx
	push rcx
	push rax

	push rax		; Save RAX since we are about to overwrite it
	mov dx, 0x01F2		; Sector count Port 7:0
	mov al, 1		; Write one sector, a value of 0 here will write 256 sectors
	out dx, al
	pop rax			; Restore RAX which is our sector number
	inc dx			; 0x01F3 - LBA Low Port 7:0
	out dx, al
	inc dx			; 0x01F4 - LBA Mid Port 15:8
	shr rax, 8
	out dx, al
	inc dx			; 0x01F5 - LBA High Port 23:16
	shr rax, 8
	out dx, al
	inc dx			; 0x01F6 - Device Port. Bit 6 set for LBA mode, Bit 4 for device (0 = master, 1 = slave), Bits 3-0 for LBA "Extra High" (27:24)
	shr rax, 8
	and al, 00001111b 	; Clear bits 4-7 just to be safe
	or al, 01000000b	; Turn bit 6 on since we want to use LBA addressing, leave device at 0 (master)
	out dx, al
	inc dx			; 0x01F7 - Command Port
	mov al, 0x30		; Write sector(s). 0x34 if LBA48
	out dx, al

writesector_wait:		; VERIFY THIS
	in al, dx
	test al, 8		; This means the sector buffer requires servicing.
	jz writesector_wait	; Don't continue until the sector buffer is ready.
	mov rcx, 256		; One sector is 512 bytes but we are writing 2 bytes at a time
	mov dx, 0x01F0		; Data port - data comes in and out of here.
	rep outsw		; Write data from the address starting at RSI

	pop rax
	add rax, 1		; Point to the next sector
	pop rcx
	pop rdx
ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
