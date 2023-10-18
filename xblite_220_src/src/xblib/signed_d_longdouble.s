.text
;
; ***********************************
; *****  %_signed.d.longdouble  *****  SIGNED$(longdouble)
; ***********************************
;
.globl %_signed.d.longdouble
%_signed.d.longdouble:
fld	tword ptr [esp+4] 				;get number to convert to string
fxam														;test against zero
fstsw	ax											;C1 bit = sign bit
test	ah,2											;copy C1 bit to zero bit (inverted)
fabs														;float.string expects a positive number
mov	eax,'-'										;preload with leading minus sign
jnz	short signed_longdouble_prefix ;if negative, minus sign is correct
mov	eax,'+'										;nope, number needs leading plus sign
signed_longdouble_prefix:
push	eax												;push leading character
push	'd'												;push exponent letter
push	19												;push maximum number of digits
sub  esp,12
fstp	tword ptr [esp]
call	_XstLongDoubleToString$@24
ret
