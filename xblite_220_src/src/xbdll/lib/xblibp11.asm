
; **********************************
; *****  %_print.tab.first.a1  *****  creates a string containing a given number
; **********************************  of spaces

.code

; in:	ebx = one more than number of spaces to create
; out:	ebx -> created string

; destroys: ecx, esi, edi

; Result string is dynamically allocated; freeing it is the caller's
; responsibility.  Returns null pointer if caller asks for zero or
; fewer spaces.

%_print.tab.first.a1:
	xchg	eax,ebx
	xchg	edx,ecx
	call	%_print.tab.first.a0
	xchg	eax,ebx
	xchg	edx,ecx
	ret


; #################
; #####  END  #####
; #################
