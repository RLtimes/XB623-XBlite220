.text
;
; ****************************
; *****  %_mul.DCOMPLEX  *****  z3 = z1 * z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) * Re(z2) - Im(z1) * Im(z2)
; Im(z3) = Re(z1) * Im(z2) + Im(z1) * Re(z2)
;
.globl %_mul.DCOMPLEX
%_mul.DCOMPLEX:
fld	qword ptr [esi]			;calculate real part of product
fld	qword ptr [edi]
fmul
fld	qword ptr [esi+8]
fld	qword ptr [edi+8]
fmul
fsub
fstp	qword ptr [eax]
fld	qword ptr [esi]			;calculate imaginary part of product
fld	qword ptr [edi+8]
fmul
fld	qword ptr [esi+8]
fld	qword ptr [edi]
fmul
fadd
fstp	qword ptr [eax+8]
ret
