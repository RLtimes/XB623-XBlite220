.text
;
; ****************************
; *****  %_str.d.single  *****  STR$(x)
; ****************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	space is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_str.d.single
%_str.d.single:
fld	dword ptr [esp+4] 			;get number to convert to string
fxam													;test against zero
fstsw	ax										;C1 bit = sign bit
test	ah,2										;copy C1 bit to zero bit (inverted)
fabs													;float.string expects a positive number
mov	eax,'-'									;preload with leading minus sign
jnz	short str_single_prefix ;if negative, minus sign is correct
mov	eax,' '									;nope, number needs leading space
str_single_prefix:
push	eax											;push leading character
push	'e'											;push exponent letter
push	7												;push maximum number of digits
call	float.string						;eax -> result string
add	esp,12
ret
