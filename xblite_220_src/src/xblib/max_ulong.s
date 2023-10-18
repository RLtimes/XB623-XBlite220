.text
;
; *************************
; *****  %_MAX.ulong  *****
; *************************
;
.globl %_MAX.ulong
%_MAX.ulong:
mov	eax, [esp+4]		; 1st arg
mov	ebx, [esp+8]		; 2nd arg
cmp	eax, ebx				; 1st : 2nd
ja	short %done1			; 1st > 2nd
mov	eax, ebx				; 2nd > 1st
%done1:
ret
