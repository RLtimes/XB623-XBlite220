.text
;
; **************************
; *****  %_MIN.double  *****
; **************************
;
.globl %_MIN.double
%_MIN.double:
fld	qword ptr [esp+4]			; 1st arg
fld	qword ptr [esp+12]		; 2nd arg
fcompp											; 1st : 2nd
fstsw	ax									; get flags in ax
sahf												; put flags in cc
jb	short %dd2nd						; 2nd arg is larger
;;
%dd1st:
fld	qword ptr [esp+4]			; 1st arg
ret
;
%dd2nd:
fld	qword ptr [esp+12]		; 2nd arg
ret
