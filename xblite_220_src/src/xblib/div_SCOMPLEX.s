.text
;
; ****************************
; *****  %_div.SCOMPLEX  *****  z3 = z1 / z2
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
.globl %_div.SCOMPLEX
%_div.SCOMPLEX:
fld	dword ptr [esi]		;calculate real part of quotient
fld	dword ptr [edi]
fmul
fld	dword ptr [esi+4]
fld	dword ptr [edi+4]
fmul
fadd										;st(0) = numerator
fld	dword ptr [edi]
fld	st(0)
fmul
fld	dword ptr [edi+4]
fld	st(0)
fmul
fadd										;st(0) = denominator, st(1) = numerator
fst	st(2)							;save denominator for later
fdiv
fstp	dword ptr [eax]		;store real part of quotient
fld	dword ptr [esi+4] ;calculate imaginary part of quotient
fld	dword ptr [edi]
fmul
fld	dword ptr [edi+4]
fld	dword ptr [esi]
fmul
fsub										;st(0) = numerator, st(1) = denominator
fdivr
fstp	dword ptr [eax+4] ;store imaginary part of quotient
ret
