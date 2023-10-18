.text
;
; *******************************
; *****  %_sign.longdouble  *****
; *******************************
;
.globl %_sign.longdouble
%_sign.longdouble:
;
push	ebp
mov	ebp,esp
fld	tword ptr [ebp+8]
sub	esp,12
fstp	tword ptr [esp]
call	_SignBitL@12
or	eax,eax
jnz	sign.ret
mov	eax,1
sign.ret:
mov	esp,ebp
pop	ebp
ret	12
