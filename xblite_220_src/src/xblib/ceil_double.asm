.code
;
; **************************
; *****  %_ceil.double  ****  CEIL(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = CEIL(source number) = round toward + infinity
; destroys: ebx
;
%_ceil.double:
fld     Q[esp+4]
ceil.x:
fnstcw  W[orig_control_bits]
fwait
mov     bx,W[orig_control_bits]
and	bx,0xF3FF          		;mask out rounding-control bits
or	bx,0x0800            	;set rounding mode to: \"round up\"
mov     W[control_bits],bx 
fldcw   W[control_bits]
frndint                 	;CEIL(source_number)
fldcw   W[orig_control_bits]
ret
