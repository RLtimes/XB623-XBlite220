.text
;
; ****************************
; *****  %_sub.DCOMPLEX  *****  z3 = z1 - z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) - Re(z2)
; Im(z3) = Im(z1) - Im(z2)
;
.globl %_sub.DCOMPLEX
%_sub.DCOMPLEX:
fld	qword ptr [esi] 		;subtract real components
fld	qword ptr [edi]
fsub
fstp	qword ptr [eax]
fld	qword ptr [esi+8] 	;subtract imaginary components
fld	qword ptr [edi+8]
fsub
fstp	qword ptr [eax+8]
ret
