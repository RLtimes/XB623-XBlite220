.text
;
; *************************
; *****  %_make.3arg  *****  MAKE(v, width, offset)
; *************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
; out:	eax = arg0 with specified bitfield set
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_make.3arg
%_make.3arg:
mov	eax,[esp+4]     							;eax = value from which to extract bitfield
mov	ebx,[esp+8]     							;ebx = width
mov	ecx,[esp+12]    							;ecx = offset
and	ebx,31          							;want only low 5 bits of width
and	eax,[width_table + ebx*4] 		;cut off all but width bits
sll	eax,cl          							;shift up to offset position
ret
