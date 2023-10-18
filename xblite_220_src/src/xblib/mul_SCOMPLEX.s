.text
;
; ****************************
; *****  %_mul.SCOMPLEX  *****  z3 = z1 * z2
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
.globl %_mul.SCOMPLEX
%_mul.SCOMPLEX:
fld	dword ptr [esi]			;calculate real part of product
fld	dword ptr [edi]
fmul
fld	dword ptr [esi+4]
fld	dword ptr [edi+4]
fmul
fsub
fstp	dword ptr [eax]
fld	dword ptr [esi]			;calculate imaginary part of product
fld	dword ptr [edi+4]
fmul
fld	dword ptr [esi+4]
fld	dword ptr [edi]
fmul
fadd
fstp	dword ptr [eax+4]
ret
