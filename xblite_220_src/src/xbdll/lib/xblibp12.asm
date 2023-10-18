
; *************************************
; *****  %_print.first.spaces.a0  *****  creates a string containing a given
; *************************************  number of spaces

.code

; in:	eax = desired number of spaces
; out:	eax -> string containing spaces

; destroys: edx, esi, esi

; Result string is dynamically allocated; freeing it is the caller's
; responsibility.  Returns null pointer if caller asks for zero or
; fewer spaces.

%_print.first.spaces.a0:
	inc	eax													;eax = tab stop after making spaces
	jmp	%_print.tab.first.a0


; #################
; #####  END  #####
; #################
