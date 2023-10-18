.text
;
.globl %_rpower.slong
%_rpower.slong:
.globl %_rpower.xlong
%_rpower.xlong:
push	0
push	ebx			; y
push	0
push	eax			; x
fild	dword ptr [esp+0]	; FPU = x
fild	dword ptr [esp+8]	; FPU = y
fstp	qword ptr [esp+0]	; arg1 = x#
fstp	qword ptr [esp+8]	; arg2 = y#
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fistp	dword ptr [esp+0]	; a
pop	eax			; eax = a  (result)
pop	edx			; edx = garbage  (clean up stack)
ret
