; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2009 Return Infinity -- see LICENSE.TXT
;
; File System Functions
; =============================================================================

align 16
db 'DEBUG: FILESYS  '
align 16


; -----------------------------------------------------------------------------
; os_file_load -- Load a file into memory
; IN:	RSI = Address of filename string
;	RDI = Memory location where file will be loaded to
; OUT:	Carry set if file was not found
os_file_load:
	jmp os_fat16_file_load
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; os_get_file_list -- Generate a list of files on disk
; IN:	RDI = location to store list
; OUT:	RDI = pointer to end of list
os_get_file_list:
	jmp os_fat16_get_file_list
; -----------------------------------------------------------------------------


; =============================================================================