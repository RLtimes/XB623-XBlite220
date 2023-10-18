.text
;
; **********************************
; *****  **  (POWER operator)  *****
; **********************************
;
.globl %_power.slong
%_power.slong:
.globl %_power.xlong
%_power.xlong:
push	0
push	eax			; x
push	0
push	ebx			; y
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
