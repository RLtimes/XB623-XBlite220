.code
;
; *******************************
; *****  %_ceil.longdouble  *****  CEIL(longdouble)
; *******************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = CEIL(source number) = round towards + infinity
; destroys: ebx
;
%_ceil.longdouble:
fld     T[esp+4]
jmp     ceil.x
