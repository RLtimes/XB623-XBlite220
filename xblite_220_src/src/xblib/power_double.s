.text
;
.globl %_power.double
%_power.double:
sub	esp,16			;
fstp	qword ptr [esp+8]	;
fstp	qword ptr [esp+0]	;
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fst	qword ptr [esp+0]	; a#
pop	eax			; eax = LSW of a#
pop	edx			; edx = MSW of a#
ret
