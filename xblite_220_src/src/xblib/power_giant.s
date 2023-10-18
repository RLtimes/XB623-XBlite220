.text
;
.globl %_power.giant
%_power.giant:
push	edx
push	eax
push	ecx
push	ebx
fild	qword ptr [esp+0]	; FPU = y
fild	qword ptr [esp+8]	; FPU = x
fstp	qword ptr [esp+0]	; arg1 = x#
fstp	qword ptr [esp+8]	; arg2 = y#
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fistp	qword ptr [esp+0]	; a$$
pop	eax			; eax = LSW of a$$
pop	edx			; edx = MSW of a$$
ret
