; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; FAT32 Functions
; =============================================================================

align 16
db 'DEBUG: FAT32    '
align 16


; -----------------------------------------------------------------------------
; readcluster -- Reads a cluster from the hard drive
; IN:	EBX = cluster # to read
;		RDI = memory location to store at least 32KB
; OUT:  EBX = next cluster #
readcluster:
	push rdx
	push rcx
	push rax

;	call os_dump_reg	
	and rbx, 0x000000000FFFFFFF	; clear the top 36 bits since we don't need them.
	mov [tempcluster], ebx ; store the cluster number we are about to read. We will use this value later on to calculate where the next cluster is (if there is one)

	cmp ebx, 2 ; the cluster value has to be at least 2. Cluster 0 and 1 are not used
	jl near readcluster_bailout
	; calculate the LBA address	sector = (cluster-2) * clustersize + data_start
	dec rbx
	dec rbx
	mov rax, rbx
	movzx rdx, byte [fat32_sectorspercluster]
	mul	rdx ; RDX:RAX = RAX * RDX
	add	rax, [fat32_ClusterStart]
	mov rbx, rax
	; rbx now contains the starting sector for this cluster

	mov dx, 1f2h		; Sector count Port 7:0
	movzx rax, byte [fat32_sectorspercluster]	; Read X sectors
	out dx, al

	mov dx, 1f3h		; LBA Low Port 7:0
	mov al, bl
	out dx, al

	mov dx, 1f4h		; LBA Mid Port 15:8
	shr rbx, 8
	mov al, bl
	out dx, al

	mov dx, 1f5h		; LBA High Port 23:16
	shr rbx, 8
	mov al, bl
	out dx, al

	mov dx, 1f6h		; Device Port Bit 6 set for LBA mode, Bit 4 for device (0 = master, 1 = slave), Bits 3-0 for LBA "Extra High" (27:24)
	shr rbx, 8
	mov al, bl
	and al, 00001111b 	; clear bits 4-7 just to be safe
	or al, 01000000b	; Turn bit 6 on since we want to use LBA addressing
	out dx, al

	mov dx, 1f7h		; Command Port
	mov al, 20h			; Read. 24 if LBA48
	out dx, al

readcluster_wait:
	in al, dx
	test al, 8			; This means the sector buffer requires servicing.
	jz readcluster_wait	; Don't continue until the sector buffer is ready.

	movzx rax, byte [fat32_sectorspercluster]
	mov rdx, 256
	mul	rdx				; RDX:RAX = RAX * RDX
	mov rcx, rax		; One sector is 512 bytes but we are reading 2 bytes at a time. We need to read fat32_sectorspercluster * 256 words
	; TODO move this to a global variable
	mov dx, 1f0h		; Data port - data comes in and out of here.
	rep insw			; Read data to the address starting at RDI

	; FIX THIS!!!!!
	; check with the fat if this is the end of the cluster chain. Return the value in rbx. FFFFFFF8 if end according to FAT32 spec.
	; FAT is sequential.. so me can use math to find out what fat sector the info is in.
	push rdi
	push rsi
	
	mov rbx, [fat32_FatStart]
	mov rdi, hdbuffer1
	call readsector ; the root cluster is now in memory at RDI

;	mov rsi, hdbuffer1
;	call os_dump_mem

	xor rbx, rbx
	mov ebx, [tempcluster]		; ebx now stores the cluster number that we just read
	;multipy ebx by 4 since each record is 4 bytes
	xor rcx, rcx
	mov ecx, ebx
	shl ecx, 2
	mov rsi, hdbuffer1
	add rsi, rcx
	lodsd
	
	pop rsi
	pop rdi

	mov ebx, eax				; ebx now stores the cluster number that we just read
	and rbx, 0x000000000FFFFFFF	; clear the top 36 bits since we don't need them.
;	xor rax, rax
;	call os_dump_reg
;	call os_print_newline
	
readcluster_bailout:

	pop rax
	pop rcx
	pop rdx
ret

tempcluster:	dd 0x00000000
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; findfile -- 
; IN:	RBX(Pointer to file name, must be in "blah    txt" format)
; OUT:	EBX(Staring cluster), 0x0 if not found
; Notes: Only searches the root cluster.. not the following clusters.
findfile:
	push rsi
	push rdi
	push rcx
	
	mov rsi, rbx
	mov rdi, filetofind
	call os_string_copy

	mov rsi, filetofind
	call os_string_uppercase ; make sure the name is all uppercase

	xor rcx, rcx
	mov ebx, [fat32_rootcluster] ; read in the first cluster
	mov rdi, hdbuffer
	push rdi
	call readcluster	; there should be a readcluster command as well. This will only work if the cluster is 512bytes
;	mov os_find_file_nextcluster, ebx
	pop rdi

	; start reading
os_find_file_read:
	cmp byte [rdi+rcx], 0x00 ; end of records
	je near os_find_file_end
	cmp byte [rdi+rcx], 0xE5 ; unused record
	je os_find_file_skip
	; FIX : Someway to skip the FAT32 long filenames. Just show the 8.3 names bitte!

;	we found a valid file, store the name into the string. name is 11 bytes long
;	valid filename is sitting at [rdi+rcx]
;	we need to store it at [rax]

	push rdx
	push rcx
	
	xor rdx, rdx
	mov rax, tempfilename

os_find_file_copy:
	mov bl, [rdi+rcx]
	mov [rax], bl
	inc rcx
	inc rax
	inc rdx
	cmp rdx, 11
	jne os_find_file_copy

	mov byte [rax], 0x00 ; newline character
	inc rax
	
	pop rcx
	pop rdx
	
	;run the compare
	push rsi
	push rdi
	mov rdi, filetofind
	mov rsi, tempfilename
	call os_string_compare ; are the two strings identical? Carry is set if they are
	pop rdi
	pop rsi
	jc os_find_file_foundit ; if carry is set then we found the name we are looking for. If not look at the next record.

os_find_file_skip:
	add rcx, 32
	jmp os_find_file_read

os_find_file_foundit:
	add rcx, 20
	xor rbx, rbx
	mov bx, [rdi+rcx]
	add rcx, 6
	shr rbx, 16
	mov bx, [rdi+rcx]	
;	call os_speaker_beep
	jmp os_find_file_done

os_find_file_end:
	xor ebx, ebx	;file was not found.. reset to 0

os_find_file_done:

	pop rcx
	pop rdi
	pop rsi
ret

filetofind: times 12 db 1 ; stores the name of the file we are looking for
tempfilename: times 12 db 2 ; stores the temporary file name.. we will compare it to the file we want to find.
;os_find_file_nextcluster dd 0
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_fat32_get_file_list -- Generate a list of files on disk
; IN:	RDI = location to store list
; OUT:	RDI = pointer to end of list
; FIX: Does not follow cluster chains. We are currently not able to see more that the first cluster worth of records
os_fat32_get_file_list:
	push rsi
	push rdi
	push rcx
	push rbx
	push rax

	xor rcx, rcx
	mov ebx, [fat32_rootcluster] ; read in the first cluster
	push rdi
	mov rdi, hdbuffer
	call readcluster
;	mov dword os_fat32_get_file_list_nextcluster, ebx
	pop rdi
	mov rsi, hdbuffer
	
	; RDI = location of string
	; RSI = buffer that contains the cluster

	; start reading
os_fat32_get_file_list_read:
	cmp byte [rsi], 0x00 ; end of records
	je os_fat32_get_file_list_done
	cmp byte [rsi], 0xE5 ; unused record
	je os_fat32_get_file_list_skip
	; FIX : Someway to skip the FAT32 long filenames. Just show the 8.3 names bitte!

;	we found a valid name, store the name into the string. name is 11 bytes long
	xor rcx, rcx
	xor rax, rax
getname:
	mov al, [rsi + 8]	; Grab the attribute byte
	bt ax, 5			; check if bit 3 is set
	jc os_fat32_get_file_list_skip	; if so skip the entry
	mov al, [rsi + rcx]
	inc rcx
	stosb
	cmp rcx, 8
	jne getname
	mov al, ' ' ; Store a ' ' as the separtator between the name and extension
	stosb
getextension:
	mov al, [rsi + rcx]
	inc rcx
	stosb
	cmp rcx, 11
	jne getextension
	mov al, ' ' ; Store 2 spaces as the separtator full name and file size
	stosb
	stosb
	xor rax, rax
	mov eax, [rsi + 28] ; EAX now contains the file size in binary
	call os_int_to_string
	dec rdi	; go back one because os_int_to_string adds a null to the end
	mov al, 13 ; Store a newline character there instead
	stosb

;	fall through to the skip section.

os_fat32_get_file_list_skip:
	add rsi, 32
	jmp os_fat32_get_file_list_read
	
os_fat32_get_file_list_done:
	mov al, 0x00
	stosb
	pop rax
	pop rbx
	pop rcx
	pop rdi
	pop rsi
	ret
	
;os_fat32_get_file_list_nextcluster: dd 0x00000000
;poo db 'poo: ', 0
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_fat32_filename_convert -- Change "TEST.BIN" into "TEST    BIN" as per FAT32
; IN:	RSI = filename string
; OUT:	carry set if invalid
; This function modifies the string in RSI. Make a copy if you need it.
os_fat32_filename_convert:
	push rsi
	push rdi
	push rdx
	push rcx
	push rax

;	call os_string_chomp
	call os_string_length
	cmp rax, 12			; Bigger than name + dot + extension?
	jg os_fat32_filename_convert_failure			; Fail if so

	cmp rax, 0
	je os_fat32_filename_convert_failure			; Similarly, fail if zero-char string

	mov rdx, rax			; Store string length for now

	mov rdi, temp_dest_string
	call os_string_copy	; make a local copy of the string
	xchg rsi, rdi	; switch the contents of src and dest
	
	mov rcx, 0
copy_loop:
	lodsb
	cmp al, '.'
	je found_extension
	stosb
	inc rcx
	cmp rcx, rdx
	jg os_fat32_filename_convert_failure
	jmp copy_loop

found_extension:
	cmp rcx, 0
	je os_fat32_filename_convert_failure			; Fail if extension dot is first char

	cmp rcx, 8
	je do_extension		; Skip spaces if first bit is 8 chars

	; Now it's time to pad out the rest of the first part of the filename
	; with spaces, if necessary

add_spaces:
	mov byte [rdi], ' '
	inc rdi
	inc rcx
	cmp rcx, 8
	jl add_spaces

	; Finally, copy over the extension
	; This needs work as it does not factor for 1 or 2 letter extensions
do_extension:
;	lodsb				; 3 characters
;	stosb
;	lodsb
;	stosb
;	lodsb
;	stosb

	mov byte [rdi], 0x00		; Zero-terminate filename
	
os_fat32_filename_convert_success:
	clc				; Clear carry for success
	jmp os_fat32_filename_convert_end

os_fat32_filename_convert_failure:
	stc				; Set carry for failure

os_fat32_filename_convert_end:
	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi
	ret

	temp_dest_string: times 12 db 0	; 8 (name) + 3 (extension) + 1
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_fat32_load_file -- Load file into RAM
; IN:	RSI = filename string
;		RDI = location in memory to store file
; OUT:	RBX = file size (in bytes)
;		carry set if file not found
os_fat32_load_file:

	ret
; -----------------------------------------------------------------------------

; os_fat32_check_file -- Check a file from the hard drive
; to get file details like size
; carry set if doesn't exist
; os_fat32_file_exists
; os_file_exists -- Check for presence of file on the floppy
; IN: AX = filename location; OUT: carry clear if found, set if not
; os_get_file_size -- Get file size information for specified file
; IN: AX = filename; OUT: BX = file size in bytes (up to 64K)
; or carry set if file not found

; getdriveinfo

fat32_bytespersector: dw 0 ; This will most likely be set to 512. All IDE drives have 512byte sectors
fat32_sectorspercluster: db 0 ; This will depend on the drive size. Possible values are 1, 2, 4, 8, 16, or 32
fat32_reservedsectors: dw 0 ; After the boot sector FAT keeps a number of sectors reserved for no apparent use
fat32_numoffats: db 0 ; This will most likely be 2. We will be using the first one.. dunno about the second
fat32_totalsectors: dd 0 ; How many sectors on the drive
fat32_sectorsperfat: dd 0 ; How many sectors does the FAT use
fat32_rootcluster: dd 0 ; Where the root cluster is stored. This is the first sector where file names and locations are stored
fat32_FatStart: dd 0 ; FAT starts here. Chain information is stored at this location, sector value
fat32_ClusterStart: dd 0 ; Data Clusters start here. ; rename to Data Start?
fat32_FileEntriesPerCluster dd 0 ; How many file entries are there per cluster
fat32_WordsPerCluster dd 0 ; How many words (16-bit) are in a cluster

; =============================================================================
; EOF
