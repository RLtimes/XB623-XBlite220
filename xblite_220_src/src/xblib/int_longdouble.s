.text
;
; ******************************
; *****  %_int.longdouble  *****  INT(longdouble)
; ******************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = INT(source number) = largest integer less than or equal
;				     to source number
; destroys: ebx
;
.globl %_int.longdouble
%_int.longdouble:
fld	tword ptr [esp+4]
jmp	int.x
