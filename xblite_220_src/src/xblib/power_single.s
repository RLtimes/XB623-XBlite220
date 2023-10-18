.text
;
.globl %_power.single
%_power.single:
sub	esp,16			;
fstp	qword ptr [esp+8]	;
fstp	qword ptr [esp+0]	;
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fst	dword ptr [esp+0]	; a!
pop	eax			; eax = a!
pop	edx			; garbage  (clean stack)
ret
