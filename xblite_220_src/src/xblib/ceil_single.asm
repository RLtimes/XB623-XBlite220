.code
;
; ***************************
; *****  %_ceil.single  *****  CEIL(single)
; ***************************
;
; in:	arg0 = source number
; out:	st(0) = CEIL(source number) = round towards + infinity
;
; destroys: ebx
;
%_ceil.single:
fld     D[esp+4]
jmp	ceil.x
