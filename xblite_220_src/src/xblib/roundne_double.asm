.code
;
; ******************************
; *****  %_roundne.double  *****  ROUNDNE(double)
; ******************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = ROUNDNE(source number) = nearest integer to source number or even
; destroys: ebx
;
%_roundne.double:
fld     Q[esp+4]
roundne.x:
fnstcw  W[orig_control_bits]
fwait
mov     bx,W[orig_control_bits]
and	bx,0xF3FF          		;mask out rounding-control bits - 00 = nearest or even
mov     W[control_bits],bx 
fldcw   W[control_bits]
frndint                 	;ROUNDNE(source_number)
fldcw   W[orig_control_bits]
ret
