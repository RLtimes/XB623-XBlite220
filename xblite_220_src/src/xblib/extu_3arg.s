.text
;
; *************************
; *****  %_extu.3arg  *****  EXTU(v, width, offset)
; *************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
;
; out:	eax = bitfield extract from arg0, zero-extended
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_extu.3arg
%_extu.3arg:
mov	eax,[esp+4]     ;eax = value from which to extract bitfield
mov	ebx,[esp+8]     ;ebx = width
mov	ecx,[esp+12]    ;ecx = offset
slr	eax,cl          ;shift bitfield to right (low) end of eax
and	ebx,31          ;only want low 5 bits of width
and	eax,[width_table + ebx*4] ;screen out all but width bits
ret
