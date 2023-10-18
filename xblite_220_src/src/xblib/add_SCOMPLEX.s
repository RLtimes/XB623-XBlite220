.text
;
; ****************************
; *****  %_add.SCOMPLEX  *****  z3 = z1 + z2
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
.globl %_add.SCOMPLEX
%_add.SCOMPLEX:
fld	dword ptr [esi]			;add real components
fld	dword ptr [edi]
fadd
fstp	dword ptr [eax]
fld	dword ptr [esi+4] 	;add imaginary components (but really add them)
fld	dword ptr [edi+4]
fadd
fstp	dword ptr [eax+4]
ret
