.text
;
; ***********************
; *****  %_space.d  *****  SPACE$(x)
; ***********************
;
; in:	arg0 = number of spaces
; out:	eax -> string containing requested number of spaces
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_space.d
%_space.d:
push	ebp
mov	ebp,esp
push	[ebp+8]          ;push number of spaces requested
push	' '              ;push space character
call	%_chr.d          ;eax -> result string
add	esp,8
mov	esp,ebp
pop	ebp
ret
