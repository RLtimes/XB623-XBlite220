.text
;
; *************************
; *****  %_MIN.slong  *****
; *****  %_MIN.xlong  *****
; *************************
;
.globl %_MIN.slong
%_MIN.slong:
.globl %_MIN.xlong
%_MIN.xlong:
mov	eax, [esp+4]		; 1st arg
mov	ebx, [esp+8]		; 2nd arg
cmp	eax, ebx				; 1st : 2nd
jle	short %done2		; 1st > 2nd
mov	eax, ebx				; 2nd > 1st
%done2:
ret
