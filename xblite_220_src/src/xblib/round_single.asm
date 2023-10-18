.code
;
; **************************
; *****  %_round.single  *****  ROUND(single)
; **************************
;
; in:	arg0 = source number
; out:	st(0) = ROUND(source number) = nearest integer to source number
;
; destroys: ebx
;
%_round.single:
fld     D[esp+4]
jmp	round.x
