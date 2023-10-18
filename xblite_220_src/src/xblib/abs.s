.text
;
; *************************
; *****  %_abs.slong  *****  ABS(x)
; *****  %_abs.xlong  *****
; *************************
;
; in:	arg0 = source number
; out:	eax = absolute value of source number
;
; destroys: nothing
;
; Generates overflow trap if source number is 0x80000000.
;
.globl %_abs.slong
%_abs.slong:
.globl %_abs.xlong
%_abs.xlong:
	mov	eax,[esp+4]	        ;eax = source number
	or	eax,eax             ;less than zero?
	jns	short abs_ret       ;no: it's already its own absolute value
	cmp	eax,0x80000000	    ;cannot represent as positive signed number?
	je	short gen_overflow  ;cannot: so generate an overflow
	neg	eax		              ;eax = ABS(source number)
abs_ret:
	ret
;
gen_overflow:
;	xor	eax,eax           ;return zero
call	%_eeeOverflow       ;Return from there
;
;
; *************************
; *****  %_abs.ulong  *****  ABS(x)
; *************************
;
; in:	arg0 = source number
; out:	eax = source number
;
; destroys: nothing
;
.globl %_abs.ulong
%_abs.ulong:
	mov	eax,[esp+4]
	ret
;
;
; *************************
; *****  %_abs.giant  *****  ABS(giant)
; *************************
;
; in:	arg1:arg0 = source number
; out:	edx:eax = absolute value of source number
;
; destroys: nothing
;
; Generates an overflow trap if source number is 0x8000000000000000.
;
.globl %_abs.giant
%_abs.giant:
	mov	edx,[esp+8]        ;edx = ms half of source number
	mov	eax,[esp+4]        ;eax = ls half of source number
	or	edx,edx            ;greater than or equal to zero?
	jns	short gabs_ret     ;yes: source number is its own absolute value
;
	cmp	edx,0x80000000     ;make sure |edx:eax| can be represented as
	jne	short gabs_negate  ;a signed 64-bit positive number
	or	eax,eax
	jz	gen_overflow
;
gabs_negate:
	not	edx                ;negate edx:eax
	neg	eax
	sbb	edx,-1
;
gabs_ret:
	ret
;
;
; **************************
; *****  %_abs.single  *****  ABS(single)
; **************************
;
; in:	arg0 = source number
; out:	st(0) = absolute value of source number
;
; destroys: nothing
;
.globl %_abs.single
%_abs.single:
	fld	dword ptr [esp+4]
	fabs
	ret
;
;
; **************************
; *****  %_abs.double  *****  ABS(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = absolute value of source number
;
; destroys: nothing
;
.globl %_abs.double
%_abs.double:
	fld	qword ptr [esp+4]
	fabs
	ret
;
;
; ******************************
; *****  %_abs.longdouble  *****  ABS(longdouble)
; ******************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = absolute value of source number
;
; destroys: nothing
;
.globl %_abs.longdouble
%_abs.longdouble:
	fld	tword ptr [esp+4]
	fabs
	ret
