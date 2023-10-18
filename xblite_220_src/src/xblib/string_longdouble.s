.text
;
; *******************************
; *****  %_string.d.longdouble  *****  STRING(longdouble)
; *******************************
;
.globl %_string.longdouble
%_string.longdouble:
.globl %_string.d.longdouble
%_string.d.longdouble:
fld	tword ptr [esp+4] 			;get number to convert to string
fxam													;test against zero
fstsw	ax										;C1 bit = sign bit
test	ah,2										;copy C1 bit to zero bit (inverted)
fabs													;float.string expects a positive number
mov	eax,'-'									;preload with leading minus sign
jnz	short string_longdouble_prefix ;if negative, minus sign is correct
xor	eax,eax									;nope, number gets no leading char
string_longdouble_prefix:
push	eax											;push leading character
push	'd'											;push exponent letter
push	19											;push maximum number of digits
sub  esp,12
fstp	tword ptr [esp]
call	_XstLongDoubleToString$@24
ret
