.text
;
; ****************************
; *****  %_str.d.double  *****  STR$(x)
; ****************************
;
; in:	arg1:arg0 = number to convert to string
; out:	eax -> result string:	space is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_str.d.double
%_str.d.double:
fld	qword ptr [esp+4] 			;get number to convert to string
fxam													;test against zero
fstsw	ax										;C1 bit = sign bit
test	ah,2										;copy C1 bit to zero bit (inverted)
fabs													;float.string expects a positive number
mov	eax,'-'									;preload with leading minus sign
jnz	short str_double_prefix ;if negative, minus sign is correct
mov	eax,' '									;nope, number needs leading space
str_double_prefix:
push	eax											;push leading character
push	'd'											;push exponent letter
push	15											;push maximum number of digits
call	float.string						;eax -> result string
add	esp,12
ret
