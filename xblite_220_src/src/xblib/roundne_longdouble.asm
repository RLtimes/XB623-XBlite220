.code
;
; **********************************
; *****  %_roundne.longdouble  *****  ROUNDNE(longdouble)
; **********************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = ROUNDNE(source number) = nearest integer to source number or even
; destroys: ebx
;
%_roundne.longdouble:
fld     T[esp+4]
jmp     roundne.x
