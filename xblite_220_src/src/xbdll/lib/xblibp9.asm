
; *****************************************
; *****  %_print.tab.a0.eq.a1.tab.a0  *****  appends spaces to reach desired
; *****************************************  tab stop

.code

; in:	eax = one more than desired length of string
; 	ebx -> string to append spaces to
; out:	eax -> new string

; destroys: ebx, ecx, edx, esi, edi

; String pointed to by ebx is assumed to be in dynamic memory; it may
; be realloc'ed.

%_print.tab.a0.eq.a1.tab.a0:
%_print.tab.a0.eq.a1.tab.a0.ss:
	xchg	eax,ebx
	jmp	%_print.tab.a0.eq.a0.tab.a1



; #################
; #####  END  #####
; #################
