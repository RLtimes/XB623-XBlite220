.text
;
; *************************
; *****  %_make.2arg  *****  MAKE(v, bitfield)
; *************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = arg0 with specified bitfield set
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_make.2arg
%_make.2arg:
mov	eax,[esp+4]       ;eax = value from which to extract bit field
mov	ebx,[esp+8]       ;ebx = width:offset
mov	ecx,ebx           ;ecx = offset with extra bits on top
slr	ebx,5             ;ebx = width with extra bits on top
and	ebx,31            ;want only low 5 bits of width
and	eax,[width_table + ebx*4] ;cut off all but width bits
sll	eax,cl            ;shift up to offset position
ret
