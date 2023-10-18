.text
;
; ****************************
; *****  %_div.DCOMPLEX  *****  z3 = z1 / z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
;	   Re(z1) * Re(z2) + Im(z1) * Im(z2)
; Re(z3) = ---------------------------------
;	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
;
;	   Im(z1) * Re(z2) - Im(z2) * Re(z1)
; Im(z3) = ---------------------------------
;	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
;
.globl %_div.DCOMPLEX
%_div.DCOMPLEX:
fld	qword ptr [esi]		;calculate real part of quotient
fld	qword ptr [edi]
fmul
fld	qword ptr [esi+8]
fld	qword ptr [edi+8]
fmul
fadd										;st(0) = numerator
fld	qword ptr [edi]
fld	st(0)
fmul
fld	qword ptr [edi+8]
fld	st(0)
fmul
fadd										;st(0) = denominator, st(1) = numerator
fst	st(2)							;save denominator for later
fdiv
fstp	qword ptr [eax]		;store real part of quotient
fld	qword ptr [esi+8] ;calculate imaginary part of quotient
fld	qword ptr [edi]
fmul
fld	qword ptr [edi+8]
fld	qword ptr [esi]
fmul
fsub										;st(0) = numerator, st(1) = denominator
fdivr
fstp	qword ptr [eax+8] ;store imaginary part of quotient
ret

