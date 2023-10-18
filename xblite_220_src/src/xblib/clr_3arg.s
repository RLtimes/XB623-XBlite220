.text
;
; ************************
; *****  %_clr.3arg  *****  CLR(v, width, offset)
; ************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
; out:	eax = arg0 with specified bitfield cleared
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_clr.3arg
%_clr.3arg:
mov	eax,[esp+4]         ;eax = value from which to extract bit field
mov	ecx,[esp+8]         ;ecx = width
mov	ebx,[esp+12]        ;ebx = offset
dec	ecx                 ;translate 0 to 32, leave shift count in ecx
and	ecx,31              ;only low bits of width
and	ebx,31              ;only low bits of offset
mov	edx,0x80000000      ;get a bit to copy
sar	edx,cl              ;copy it (width-1) times
add	ecx,ebx             ;ecx = width + offset
neg	ecx
add	ecx,31              ;ecx = 32 - (width + offset)
slr	edx,cl              ;move block of 1's into position for mask
not	edx                 ;edx = mask: 0's where bitfield is
and	eax,edx             ;clear the bitfield
ret
