.text
;
; ************************
; *****  %_ext.3arg  *****  EXTS(v, width, offset)
; ************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
;
; out:	eax = bitfield extract from arg0, sign-extended
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_ext.3arg
%_ext.3arg:
mov	eax,[esp+4]       ;eax = value from which to extract bitfield
mov	ecx,[esp+8]       ;ecx = width
mov	ebx,[esp+12]      ;ebx = offset
and	ecx,31            ;no silly widths
and	ebx,31            ;no silly offsets
add	ecx,ebx           ;ecx = width + offset
neg	ecx
add	ecx,32            ;ecx = 32 - (width + offset)
sll	eax,cl            ;shift bit field to top of eax
add	ecx,ebx           ;ecx = 32 - width
sar	eax,cl            ;shift back to bottom of eax, sign-extending
;                      ;along the way
ret
