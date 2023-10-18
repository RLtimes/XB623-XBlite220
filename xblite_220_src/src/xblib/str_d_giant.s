.text
;
; ***************************
; *****  %_str.d.giant  *****  STR$(giant)
; ***************************
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
.globl %_str.d.giant
%_str.d.giant:

push	ebp
mov	ebp,esp
mov	eax,'-'						;prefix with hyphen if negative
mov	ebx,[ebp+12]			;ebx = most significant dword
or	ebx,ebx							;negative?
js	short str_giant_cvt ;yes: leave prefix character alone
mov	eax,' '						;prefix with space if positive or zero
str_giant_cvt:
push	eax								;push prefix character
push	ebx								;push most significant dword
push	[ebp+8]						;push least significant dword
call	giant.decimal			;convert to decimal string
mov	esp,ebp
pop	ebp
ret
