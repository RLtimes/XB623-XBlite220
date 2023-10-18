.text
;
; ******************************
; *****  %_MIN.longdouble  *****
; ******************************
;
.globl %_MIN.longdouble
%_MIN.longdouble:
fld	tword ptr [esp+4]			; 1st arg
fld	tword ptr [esp+16]		; 2nd arg
fcompp											; 1st : 2nd
fstsw	ax									; get flags in ax
sahf												; put flags in cc
jb	short %ldd2nd						; 2nd arg is larger
;;
%ldd1st:
fld	tword ptr [esp+4]			; 1st arg
ret
;
%ldd2nd:
fld	tword ptr [esp+16]		; 2nd arg
ret
