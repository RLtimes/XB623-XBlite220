.text
;
; ******************************
; *****  %_MAX.longdouble  *****
; ******************************
;
.globl %_MAX.longdouble
%_MAX.longdouble:
fld	tword ptr [esp+4]			; 1st arg
fld	tword ptr [esp+16]		; 2nd arg
fcompp											; 1st : 2nd
fstsw	ax									; get flags in ax
sahf												; put flags in cc
ja	short %ld2nd						; 2nd arg is larger
;;
.globl %ld1st
%ld1st:
fld	tword ptr [esp+4]			; 1st arg
ret
;
.globl %ld2nd
%ld2nd:
fld	tword ptr [esp+16]		; 2nd arg
ret
