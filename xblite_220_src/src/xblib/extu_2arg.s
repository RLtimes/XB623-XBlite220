.text
;
; *************************
; *****  %_extu.2arg  *****  EXTU(v, bitfield)
; *************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = bitfield extracted from arg0, zero-extended
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_extu.2arg
%_extu.2arg:
mov	eax,[esp+4]       ;eax = value from which to extract bit field
mov	ebx,[esp+8]       ;ebx = width:offset
mov	ecx,ebx           ;ecx = offset with extra bits on top
slr	ebx,5             ;shift width into low 5 bits of ebx
slr	eax,cl            ;shift bitfield to right (low) end of eax
and	ebx,31            ;only want low 5 bits of width
and	eax,[width_table + ebx*4] ;screen out all but width bits
ret
