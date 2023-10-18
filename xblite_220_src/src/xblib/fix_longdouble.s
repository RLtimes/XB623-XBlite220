.text
;
; ******************************
; *****  %_fix.longdouble  *****  FIX(longdouble)
; ******************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = source number truncated
;
; destroys: ebx
;
.globl %_fix.longdouble
%_fix.longdouble:
fld	tword ptr [esp+4]
jmp	fix.x
