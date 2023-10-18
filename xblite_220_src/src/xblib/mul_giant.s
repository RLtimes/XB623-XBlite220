.text
;
; *************************
; *****  %_mul.GIANT  *****
; *************************
;
; in:	edx:eax = left operand
;	ecx:ebx = right operand
; out:	edx:eax = result
;
; destroys: nothing
;
; local variables:
;	[ebp-4]:[ebp-8] = left operand, result
;	[ebp-12]:[ebp-16] = right operand
;	[ebp-18] = saved FPU control word
;	[ebp-20] = new FPU control word
;
.globl %_mul.GIANT
%_mul.GIANT:
push	ebp
mov	ebp,esp
sub	esp,20
mov	[ebp-8],eax			;put operands in memory so coprocessor
mov	[ebp-4],edx			; can access them
mov	[ebp-16],ebx
mov	[ebp-12],ecx
; Save FPU control word
fstcw	word ptr [ebp-18]
; Set FPU precision to 64 bits
fstcw	word ptr [ebp-20]
or	word ptr [ebp-20], 0x0300
fldcw	word ptr [ebp-20]
fild	qword ptr [ebp-8]
fild	qword ptr [ebp-16]
fmul
fistp	qword ptr [ebp-8]
; Restore FPU control word
fldcw	word ptr [ebp-18]
fwait
mov	eax,[ebp-8]
mov	edx,[ebp-4]
mov	esp,ebp
pop	ebp
ret
