.text
;
; ****************************
; *****  %_string.giant  *****  STRING(giant)  and  STRING$(giant)
; ****************************
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
.globl %_string.giant
%_string.giant:
.globl %_string.d.giant
%_string.d.giant:
push	ebp
mov	ebp,esp
mov	eax,'-'								;prefix with hyphen if negative
mov	ebx,[ebp+12]					;ebx = most significant dword
or	ebx,ebx									;negative?
js	short string_giant_cvt 	;yes: leave prefix character alone
sub	eax,'-'								;prefix with nothing if positive or zero
string_giant_cvt:
push	eax										;push prefix character
push	ebx										;push most significant dword
push	[ebp+8]								;push least significant dword
call	giant.decimal					;convert to decimal string
mov	esp,ebp
pop	ebp
ret
