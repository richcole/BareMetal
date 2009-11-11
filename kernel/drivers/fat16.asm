; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; FAT16 Functions
; =============================================================================

align 16
db 'DEBUG: FAT16    '
align 16


; -----------------------------------------------------------------------------
; readcluster -- Read a cluster from the FAT16 volume
; IN:	AX - (cluster)
;	RDI - (memory location to store at least 32KB)
; OUT:	AX - (next cluster)
;	RDI - points one byte after the last byte read
readcluster: ; 0x8c52
	push rsi
	push rdx
	push rcx
	push rbx
	
	and rax, 0x000000000000FFFF		; Clear the top 48 bits
	mov rbx, rax				; Save the cluster number to be used later

	cmp ax, 2				; If less than 2 then bail out...
	jl near readcluster_bailout		; as clusters start at 2

; Calculate the LBA address --- startingsector = (cluster-2) * clustersize + data_start
	xor rcx, rcx	
	mov cl, byte [fat16_SectorsPerCluster]
	push rcx				; Save the number of sectors per cluster
	sub ax, 2
	imul cx					; EAX now holds starting sector
	add eax, dword [fat16_DataStart]	; EAX now holds the sector where our cluster starts

	pop rcx					; Restore the number of sectors per cluster
readcluster_nextsector:				; Read the sectors in one-by-one
	call readsector
	dec cl
	cmp cl, 0
	jne readcluster_nextsector		; Keep going until we have a whole cluster

; Calculate the next cluster
; Psuedo-code
; tint1 = Cluster / 256  <- Dump the remainder
; sector_to_read = tint + ReservedSectors
; tint2 = (Cluster - (tint1 * 256)) * 2
	push rdi
	mov rdi, hdbuffer1			; Read to this temporary buffer
	mov rsi, rdi				; Copy buffer address to RSI
	push rbx				; Save the original cluster value
	shr rbx, 8				; Divide the cluster value by 256. Keep no remainder
	movzx ax, [fat16_ReservedSectors]	; First sector of the first FAT
	add rax, rbx				; Add the sector offset
	call readsector
	pop rax					; Get our original cluster value back
	shl rbx, 8				; Quick multiply by 256 (RBX was the sector offset in the FAT)
	sub rax, rbx				; RAX is now pointed to the offset within the sector
	shl rax, 1				; Quickly multiply by 2 (since entries are 16-bit)
	add rsi, rax
	lodsw					; AX now holds the next cluster
	pop rdi
	
	jmp readcluster_end

readcluster_bailout:
	mov ax, 0x0000

readcluster_end:
	pop rbx
	pop rcx
	pop rdx
	pop rsi
ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; findfile -- 
; IN: RSI(Pointer to file name, must be in 'FILENAMEEXT" format)
; OUT: AX(Staring cluster), 0x0 if not found
; Notes: Only searches the root sector.. not the following sectors.
findfile:
	push rsi
	push rdi
	push rcx
	push rbx

	xor rax, rax
	mov eax, [fat16_RootStart]	; eax points to the first sector of the root
	mov rdi, hdbuffer1
	push rdi
	call readsector
	pop rdi
	mov rbx, 16	; records / sector

findfile_next_entry:
	cmp byte [rdi], 0x00 ; end of records
	je findfile_notfound
	
	mov rcx, 11
	push rsi
	repe cmpsb
	pop rsi
	mov ax, [rdi+15]	; AX now holds the starting cluster # of the file we just looked at
	jz findfile_done	; The file was found. Note that rdi now is at dirent+11

	add rdi, byte 0x20
	and rdi, byte -0x20
	dec rbx
	cmp rbx, 0
	jne findfile_next_entry	

findfile_notfound:
	xor ax, ax

findfile_done:
	pop rbx
	pop rcx
	pop rdi
	pop rsi
ret
; -----------------------------------------------------------------------------


; =============================================================================
; EOF
