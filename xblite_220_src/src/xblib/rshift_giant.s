.text
;
; ****************************
; *****  %_rshift.giant  *****  logical right shift giant
; ****************************
;
; in:	edx:eax = source operand
;	ecx = number of bits to shift
; out:	edx:eax = result
;
; destroys: nothing
;
.globl %_rshift.giant
%_rshift.giant:
cmp	ecx,0							;shifting zero or fewer bits?
jle	short rshift_ret		;yes: result = input
cmp	ecx,64						;shifting 64 or more bits?
jge	short rshift_ret		;yes: result = input
cmp	cl,32
je	short grshift32			;shifting exactly 32 bits
ja	short grshift33			;shifting more than 32 bits
;											;shifting less than 32 bits
shrd	eax,edx,cl
slr	edx,cl
ret
grshift32:			;shift right exactly 32 bits
mov	eax,edx		;copy most significant half to least signif.
xor	edx,edx		;clear most significant half
ret
grshift33:			;shift right more than 32 bits
mov	eax,edx		;copy most significant half to least signif.
xor	edx,edx		;clear most significant half
slr	eax,cl		;shift (cl - 32) bits
ret
rshift_ret:
ret
