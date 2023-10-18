.text
;
; *******************************
; *****  %_string.d.single  *****  STRING$(x)
; *******************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	no leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_string.single
%_string.single:
.globl %_string.d.single
%_string.d.single:
fld	dword ptr [esp+4] 			;get number to convert to string
fxam													;test against zero
fstsw	ax										;C1 bit = sign bit
test	ah,2										;copy C1 bit to zero bit (inverted)
fabs													;float.string expects a positive number
mov	eax,'-'									;preload with leading minus sign
jnz	short string_single_prefix ;if negative, minus sign is correct
xor	eax,eax									;nope, number gets no leading char
string_single_prefix:
push	eax											;push leading character
push	'e'											;push exponent letter
push	7												;push maximum number of digits
call	float.string						;eax -> result string
add	esp,12
ret
