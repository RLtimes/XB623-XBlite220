.text
;
; ***********************
; *****  %_error.d  *****  error$ = ERROR$(errorNumber)
; ***********************
;
.globl %_error.d
%_error.d:
push	0             ; arg = error$ (by reference)
push	eax           ; arg = error (error number)
call	_XstErrorNumberToName@8  ;error number to name
mov	eax,[esp-4]   ; error$
ret
