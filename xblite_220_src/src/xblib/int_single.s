.text
;
; **************************
; *****  %_int.single  *****  INT(single)
; **************************
;
; in:	arg0 = source number
; out:	st(0) = INT(source number) = largest integer less than or equal
;				     to source number
;
; destroys: ebx
;
.globl %_int.single
%_int.single:
fld	dword ptr [esp+4]
jmp	int.x
