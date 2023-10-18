
.text
;
; ******************************
; *****  %_sgn.longdouble  *****
; ******************************
;
.globl %_sgn.longdouble
%_sgn.longdouble:
;
push	ebp
mov	ebp,esp
fld	tword ptr [ebp+8]
sub	esp,12
fstp	tword ptr [esp]
call	_IsZeroL@12
neg	eax
cmc
rcr	eax,1
sar	eax,31
or	eax,eax
jnz	sgn.not.zero
jmp	sgn.ret
sgn.not.zero:
fld	tword ptr [ebp+8]
sub	esp,12
fstp	tword ptr [esp]
call	_SignBitL@12
or	eax,eax
jnz	sgn.ret
mov	eax,1
sgn.ret:
mov	esp,ebp
pop	ebp
ret	12
