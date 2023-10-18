.code
;
; ******************************
; *****  %_round.longdouble  *****  ROUND(longdouble)
; ******************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = ROUND(source number) = nearest integer to source number
; destroys: ebx
;
%_round.longdouble:
fld     T[esp+4]
jmp     round.x
