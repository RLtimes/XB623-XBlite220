.code
;
; ********************************
; *****  %_str.d.longdouble  *****  STR$(longdouble)
; ********************************
;
%_str.d.longdouble:
fld	T[esp+4] 											; get number to convert to string
fxam															; test against zero
fstsw	ax													; C1 bit = sign bit
test	ah,2												; copy C1 bit to zero bit (inverted)
fabs															; float.string expects a positive number
mov	eax,'-'												; preload with leading minus sign
jnz	> str_longdouble_prefix 			; if negative, minus sign is correct
mov	eax,' '												; nope, number needs leading space
str_longdouble_prefix:
push	eax													; push leading character
push	'd'													; push exponent letter
push	19													; push maximum number of digits
sub  esp,12
fstp	T[esp]
call	_XstLongDoubleToString$@24
ret
