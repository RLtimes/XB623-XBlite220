.text
;
; ************************
; *****  %_ext.2arg  *****  EXTS(v, bitfield)
; ************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = bitfield extracted from arg0, sign-extended
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_ext.2arg
%_ext.2arg:
mov	eax,[esp+4]       ;eax = value from which to extract bit field
mov	ebx,[esp+8]       ;ebx = width:offset
mov	ecx,ebx
slr	ecx,5             ;ecx = width with extra bits on top
and	ecx,31            ;only want low 5 bits of width
and	ebx,31            ;only want low 5 bits of offset
add	ecx,ebx           ;ecx = width + offset
neg	ecx
add	ecx,32            ;ecx = 32 - (width + offset)
sll	eax,cl            ;shift bit field to top of eax
add	ecx,ebx           ;ecx = 32 - width
sar	eax,cl            ;shift back to bottom of eax, sign-extending
;                      ;along the way
ret

