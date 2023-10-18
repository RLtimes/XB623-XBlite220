.text
;
; **************************
; *****  %_int.double  *****  INT(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = INT(source number) = largest integer less than or equal
;				     to source number
; destroys: ebx
;
.globl %_int.double
%_int.double:
fld	qword ptr [esp+4]
.globl int.x
int.x:
fnstcw	[orig_control_bits]
fwait
mov	bx,[orig_control_bits]
and	bx,0xF3FF          ;mask out rounding-control bits
or	bx,0x0400            ;set rounding mode to: \"round down\"
mov	[control_bits],bx  ;why have one CPU when two will do?
fldcw	[control_bits]
frndint                 ;INT() the God-damned number, finally!
fldcw	[orig_control_bits]
ret
