.text
.globl %_rpower.ulong
%_rpower.ulong:
push	0
push	ebx
push	0
push	eax
fild	qword ptr [esp+0]				; FPU = y
fild	qword ptr [esp+8]				; FPU = x
fstp	qword ptr [esp+0]				; arg1 = x#
fstp	qword ptr [esp+8]				; arg2 = y#
call	_POWER@16								; math library function  a# = POWER (x#, y#)
sub	esp,8
fistp	qword ptr [esp+0]			; a$$
pop	eax											; eax = LSW of a$$
pop	edx											; edx = MSW of a$$
or	edx,edx										; is MSW = 0 ???
jnz	rpower.ulong.overflow		; if not, result is too large for ULONG
ret
rpower.ulong.overflow:
call	%_eeeOverflow						; no, so result is too large for ULONG
ret
