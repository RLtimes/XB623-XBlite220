.text
;
; *************************
; *****  %_MAX.slong  *****
; *****  %_MAX.xlong  *****
; *************************
;
.globl %_MAX.slong
%_MAX.slong:
.globl %_MAX.xlong
%_MAX.xlong:
mov	eax, [esp+4]		; 1st arg
mov	ebx, [esp+8]		; 2nd arg
cmp	eax, ebx		    ; 1st : 2nd
jge	short %done0		; 1st > 2nd
mov	eax, ebx		    ; 2nd > 1st
%done0:
ret
