.text
;
; ************************
; *****  %_set.2arg  *****  SET(v, bitfield)
; ************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = arg0 with specified bitfield set
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_set.2arg
%_set.2arg:
mov	eax,[esp+4]        ;eax = value from which to extract bit field
mov	ebx,[esp+8]        ;ebx = width:offset
mov	ecx,ebx            ;ecx = offset with extra bits on top
slr	ecx,5              ;shift width into low 5 bits of ecx
dec	ecx                ;translate 0 to 32, leave shift count in ecx
and	ecx,31             ;only low bits of width
and	ebx,31             ;only low bits of offset
mov	edx,0x80000000     ;get a bit to copy
sar	edx,cl             ;copy it width times
add	ecx,ebx            ;ecx = width + offset - 1
neg	ecx
add	ecx,31             ;ecx = 32 - (width + offset)
slr	edx,cl             ;move block of 1's into position for mask
or	eax,edx              ;set the bitfield
ret
