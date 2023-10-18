.text
;
; ****************************
; *****  %_lshift.giant  *****  logical left shift giant
; *****  %_ushift.giant  *****  arithmetic left shift giant
; ****************************
;
; in:	edx:eax = source operand
;	ecx = number of bits to shift
; out:	edx:eax = result
;
; destroys: nothing
;
.globl %_lshift.giant
%_lshift.giant:					;left logical and arithmetic shifts are the same
.globl %_ushift.giant
%_ushift.giant:
cmp	ecx,0								;shifting zero or fewer bits?
jle	short ushift_ret			;yes: result = input
cmp	ecx,64							;shifting 64 or more bits?
jge	short ushift_ret			;yes: result = input
cmp	cl,32
je	short glshift32				;shifting exactly 32 bits
ja	short glshift33				;shifting more than 32 bits
;												;shifting less than 32 bits
shld	edx,eax,cl
sll	eax,cl
ret
glshift32:			;shift left exactly 32 bits
mov	edx,eax		;copy least significant half to most signif.
xor	eax,eax		;clear least significant half
ret
glshift33:			;shift left more than 32 bits
mov	edx,eax		;copy least significant half to most signif.
xor	eax,eax		;clear least significant half
sll	edx,cl		;shift (cl - 32) bits
ushift_ret:
ret
