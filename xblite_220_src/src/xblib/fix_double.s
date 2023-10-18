.text
;
; **************************
; *****  %_fix.double  *****  FIX(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = source number truncated
;
; destroys: ebx
;
.globl %_fix.double
%_fix.double:
fld	qword ptr [esp+4]
.globl fix.x
fix.x:
fnstcw	[orig_control_bits]
fwait
mov	bx,[orig_control_bits]
or	bx,0x0C00              ;set rounding mode to: \"truncate\"
mov	[control_bits],bx    ;why have one CPU when two will do?
fldcw	[control_bits]
frndint                   ;FIX() the God-damned number, finally!
fldcw	[orig_control_bits]
ret
