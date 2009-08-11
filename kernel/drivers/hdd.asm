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
; readsector -- Read a sector from the hard drive
; IN:	RBX = sector
;		RDI = memory location to store sector 512Bytes
; OUT:	All other registers preserved
; This function uses Logical Block Addressing (LBA)
readsector:
	push rdx
	push rcx
	push rbx
	push rax
	
;	cmp rbx, [maxsectors]
;	jge bailout

	mov dx, 1f2h		; Sector count Port 7:0
	mov al, 1			; Read one sector
	out dx, al

	inc dx				;mov dx, 1f3h		; LBA Low Port 7:0
	mov al, bl
	out dx, al

	inc dx				;mov dx, 1f4h		; LBA Mid Port 15:8
	shr rbx, 8
	mov al, bl
	out dx, al

	inc dx				;mov dx, 1f5h		; LBA High Port 23:16
	shr rbx, 8
	mov al, bl
	out dx, al

	inc dx				;mov dx, 1f6h		; Device Port Bit 6 set for LBA mode, Bit 4 for device (0 = master, 1 = slave), Bits 3-0 for LBA "Extra High" (27:24)
	shr rbx, 8
	mov al, bl
	and al, 00001111b 	; clear bits 4-7 just to be safe
	or al, 01000000b	; Turn bit 6 on since we want to use LBA addressing
	out dx, al

	inc dx				;mov dx, 1f7h		; Command Port
	mov al, 20h			; Read. 24 if LBA48
	out dx, al

readsector_wait:
	in al, dx
	test al, 8			; This means the sector buffer requires servicing.
	jz readsector_wait	; Don't continue until the sector buffer is ready.

	mov cx, 256			; One sector is 512 bytes but we are reading 2 bytes at a time
	mov dx, 1f0h		; Data port - data comes in and out of here.
	rep insw			; Read data to the address starting at RDI

	pop rax
	pop rbx
	pop rcx
	pop rdx
ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; writesector -- 
; IN:	RBX = sector
;		RSI = sector to write 512Bytes
; OUT:	
writesector:
;	mov cl, 0x30 ; 34 if LBA48
;	call sendcmdtohd
ret
; -----------------------------------------------------------------------------


hdd_primary_controller		dw 0x01F0
hdd_secondary_controller	dw 0x0170

; =============================================================================
; EOF
