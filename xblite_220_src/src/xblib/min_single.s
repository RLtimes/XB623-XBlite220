.text
;
; **************************
; *****  %_MIN.single  *****
; **************************
;
.globl %_MIN.single
%_MIN.single:
fld	dword ptr [esp+4]		; 1st arg
fld	dword ptr [esp+8]		; 2nd arg
fcompp										; 1st : 2nd
fstsw	ax								; get flags in ax
sahf											; put flags in cc
jb	short %ss2nd					; 2nd arg is larger
;;
%ss1st:
fld	dword ptr [esp+4]		; 1st arg
ret
;
%ss2nd:
fld	dword ptr [esp+8]		; 2nd arg
ret
