.text
;
; **************************
; *****  %_fix.single  *****  FIX(single)
; **************************
;
; in:	arg0 = source number
; out:	st(0) = source number truncated
;
; destroys: ebx
;
.globl %_fix.single
%_fix.single:
fld	dword ptr [esp+4]
jmp	fix.x
