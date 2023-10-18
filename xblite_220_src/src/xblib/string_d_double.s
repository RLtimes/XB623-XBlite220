.text
;
; *******************************
; *****  %_string.d.double  *****  STRING(x)
; *******************************
;
; in:	arg1:arg0 = number to convert to string
; out:	eax -> result string:	no leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_string.double
%_string.double:
.globl %_string.d.double
%_string.d.double:
fld	qword ptr [esp+4] 			;get number to convert to string
fxam													;test against zero
fstsw	ax										;C1 bit = sign bit
test	ah,2										;copy C1 bit to zero bit (inverted)
fabs													;float.string expects a positive number
mov	eax,'-'									;preload with leading minus sign
jnz	short string_double_prefix ;if negative, minus sign is correct
xor	eax,eax									;nope, number gets no leading char
string_double_prefix:
push	eax											;push leading character
push	'd'											;push exponent letter
push	15											;push maximum number of digits
call	float.string						;eax -> result string
add	esp,12
ret
