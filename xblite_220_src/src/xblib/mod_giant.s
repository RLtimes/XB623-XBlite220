.text
;
; *************************
; *****  %_mod.GIANT  *****
; *************************
;
; in:	edx:eax = left operand
;	ecx:ebx = right operand
; out:	edx:eax = result
;
; destroys: ebx
;
; local variables:
;	[ebp-4]:[ebp-8] = left operand, result
;	[ebp-12]:[ebp-16] = right operand
;	[ebp-20] = coprocessor control word set for truncation
;	[ebp-24] = on-entry control word
;
.globl %_mod.GIANT
%_mod.GIANT:
push	ebp
mov	ebp,esp
sub	esp,24
mov	[ebp-8],eax	;put operands in memory so coprocessor
mov	[ebp-4],edx	; can access them
mov	[ebp-16],ebx
mov	[ebp-12],ecx
; save FPU control word
fstcw	word ptr [ebp-24]
; Set FPU precision to 64 bits
; Set FPU rounding to truncate
fstcw	word ptr [ebp-20]
or	word ptr [ebp-20], 0x0F00
fldcw	word ptr [ebp-20]
;coprocessor stack:
;													;st(0)        st(1)        st(2)
fild	qword ptr [ebp-8]			;  l
fabs
fild	qword ptr [ebp-16]		;  r            l
fabs
fld	st(0)									;  r            r            l
fwait
fdivr	st,st(2)						;  l/r          r            l
frndint										;int(l/r)       r            l
fmul												;b*int(r/l)     l
fsub												;l-(b*int(r/l))
cmp	[ebp-4],0							;numerator less than zero?
jnl	short mod_giant_skip 	;no
fchs			     							;yes: make remainder negative
mod_giant_skip:
fistp	qword ptr [ebp-8]
fwait
mov	eax,[ebp-8]
mov	edx,[ebp-4]
fldcw	word ptr [ebp-24] 	;back to old rounding mode
mov	esp,ebp
pop	ebp
ret
