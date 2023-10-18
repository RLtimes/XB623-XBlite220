.text
.globl %_eof
%_eof:
mov	eax, [esp+4]
push	eax
call	_XxxEof@4
ret
