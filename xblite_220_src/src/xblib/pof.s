.text
.globl %_pof
%_pof:
mov	eax, [esp+4]
push	eax
call	_XxxPof@4
ret
