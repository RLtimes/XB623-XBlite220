.text
;
; **************************
; *****  %_MAX.double  *****
; **************************
;
.globl %_MAX.double
%_MAX.double:
fld	qword ptr [esp+4]			; 1st arg
fld	qword ptr [esp+12]		; 2nd arg
fcompp											; 1st : 2nd
fstsw	ax									; get flags in ax
sahf												; put flags in cc
ja	short %d2nd							; 2nd arg is larger
;;
.globl %d1st
%d1st:
fld	qword ptr [esp+4]			; 1st arg
ret
;
.globl %d2nd
%d2nd:
fld	qword ptr [esp+12]		; 2nd arg
ret
