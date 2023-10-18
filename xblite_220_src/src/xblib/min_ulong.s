.text
;
; *************************
; *****  %_MIN.ulong  *****
; *************************
;
.globl %_MIN.ulong
%_MIN.ulong:
mov	eax, [esp+4]		; 1st arg
mov	ebx, [esp+8]		; 2nd arg
cmp	eax, ebx				; 1st : 2nd
jb	short %done3			; 1st > 2nd
mov	eax, ebx				; 2nd > 1st
%done3:
ret
