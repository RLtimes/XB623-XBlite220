.code
;
; ******************************
; *****  %_roundne.single  *****  ROUNDNE(single)
; ******************************
;
; in:	arg0 = source number
; out:	st(0) = ROUNDNE(source number) = nearest integer to source number or even
;
; destroys: ebx
;
%_roundne.single:
fld     D[esp+4]
jmp	roundne.x
