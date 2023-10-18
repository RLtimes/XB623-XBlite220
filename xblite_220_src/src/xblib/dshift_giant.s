.text
;
; ****************************
; *****  %_dshift.giant  *****  arithmetic right shift giant
; ****************************
;
; in:	edx:eax = source operand
;	ecx = number of bits to shift
; out:	edx:eax = result
;
; destroys: nothing
;
.globl %_dshift.giant
%_dshift.giant:
cmp	ecx,0							;shifting zero or fewer bits?
jle	short dshift_ret		;yes: result = input
cmp	ecx,64						;shifting 64 or more bits?
jge	short dshift_ret		;yes: result = input
cmp	cl,32
je	short gdshift32			;shifting exactly 32 bits
ja	short gdshift33			;shifting more than 32 bits
;shifting less than 32 bits
shrd	eax,edx,cl
sar	edx,cl
ret
gdshift32:			;shifting exactly 32 bits
mov	eax,edx		;copy most significant half to least signif.
sar	edx,31		;copy sign bit all over most significant half
ret
gdshift33:			;shifting more than 32 bits
mov	eax,edx		;copy most significant half to least signif.
sar	edx,31		;copy sign bit all over most significant half
sar	eax,cl		;shift right (cl - 32) bits
ret
dshift_ret:
ret
