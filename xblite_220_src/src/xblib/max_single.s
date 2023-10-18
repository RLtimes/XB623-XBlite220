.text
;
; **************************
; *****  %_MAX.single  *****
; **************************
;
.globl %_MAX.single
%_MAX.single:
fld	dword ptr [esp+4]		; 1st arg
fld	dword ptr [esp+8]		; 2nd arg
fcompp										; 1st : 2nd
fstsw	ax								; get flags in ax
sahf											; put flags in cc
ja	short %s2nd						; 2nd arg is larger
;;
.globl %s1st
%s1st:
fld	dword ptr [esp+4]		; 1st arg
ret
;
.globl %s2nd
%s2nd:
fld	dword ptr [esp+8]		; 2nd arg
ret
