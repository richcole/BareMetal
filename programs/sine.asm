[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.asm"

start:						; Start of program label

	fld QWORD [x]		;
	fmul st0, st0	; x = x * x			31 x 31 = 961
	fld QWORD [rf9]	; 
	fmul st0, st1	; x = x * rf9		0.002648258377425044091643953576
	fsub QWORD [rf7]	; x = x - rf7		0.002449845679012345678945540878
	fmul st0, st1	; x = x * rf9		6.7511179426045681186170117476512e-9
	fadd QWORD [rf5]	; x = x + rf5		0.0083333400844512759379014519500117
	fmul st0, st1	; x = x * rf9		2.2964451290926135189845777200108e-8
	fsub QWORD [rf3]	; x = x - rf3		-0.16666664370221537574053147682022
	fmulp st1, st0	;					-4.5928859044922667475839714068798e-7
	fmul QWORD [x]		; x = x * x			2.1094600931683747228215023212772e-13
	fadd QWORD [x]		; x = x + x
	fstp QWORD [x]		; store

	nop
	nop
	
ret							; Return to OS

; reciprocals of factorials
rf9	dq	0.0000027557319223985890651862166557
rf7	dq	0.0001984126984126984126984126984127
rf5	dq	0.0083333333333333333333333333333333
rf3	dq	0.1666666666666666666666666666666667
align 16
x	dq	31.0
