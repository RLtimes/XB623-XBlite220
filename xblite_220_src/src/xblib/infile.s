.text
;
.globl %_infile_d
%_infile_d:
mov	eax, [esp+4]	; ;;;
push	eax		; ;;;
call	_XxxInfile$@4	; ;;;
ret
