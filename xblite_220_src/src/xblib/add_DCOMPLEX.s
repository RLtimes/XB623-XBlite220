.text
;
; ****************************
; *****  %_add.DCOMPLEX  *****  z3 = z1 + z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) + Re(z2)
; Im(z3) = Im(z1) + Im(z2)
;
.globl %_add.DCOMPLEX
%_add.DCOMPLEX:
fld	qword ptr [esi]			;add real components
fld	qword ptr [edi]
fadd
fstp	qword ptr [eax]
fld	qword ptr [esi+8] 	;add imaginary components
fld	qword ptr [edi+8]
fadd
fstp	qword ptr [eax+8]
ret
