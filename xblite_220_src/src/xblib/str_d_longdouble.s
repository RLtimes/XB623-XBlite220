.text
;
; ********************************
; *****  %_str.d.longdouble  *****  STR$(longdouble)
; ********************************
;
.globl %_str.d.longdouble
%_str.d.longdouble:
fld	tword ptr [esp+4] 						; get number to convert to string
fxam															; test against zero
fstsw	ax													; C1 bit = sign bit
test	ah,2												; copy C1 bit to zero bit (inverted)
fabs															; float.string expects a positive numbe
mov	eax,'-'												; preload with leading minus sign
jnz	short str_longdouble_prefix 	; if negative, minus sign is correc
mov	eax,' '												; nope, number needs leading space
str_longdouble_prefix:
push	eax													; push leading character
push	'd'													; push exponent letter
push	19													; push maximum number of digits
sub  esp,12
fstp	tword ptr [esp]
call	_XstLongDoubleToString$@24
ret
