.data
half DQ 0.5
.code
;
; **************************
; *****  %_round.double  *****  ROUND(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = ROUND(source number) = nearest integer to source number 
; destroys: ebx
;
%_round.double:
fld     Q[esp+4]
round.x:
fnstcw  W[orig_control_bits]
fwait
mov     bx,W[orig_control_bits]
and	bx,0xF3FF          		;mask out rounding-control bits
or	bx,0x0400            	;set rounding mode to: \"round down\"
mov     W[control_bits],bx 
fldcw   W[control_bits]
fld     Q[half]
fadd   										;add 0.5
frndint                 	;INT(source_number + 0.5)
fldcw   W[orig_control_bits]
ret
