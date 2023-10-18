
; **************************************
; *****  %_print.append.spaces.a0  *****  appends a given number of spaces
; **************************************  to a string

.code

; in:	eax -> string to append spaces to
;	ebx = # of spaces to append
; out:	eax -> new string

; destroys: ebx, ecx, edx, esi, edi

; String pointed to by eax is assumed to be in dynamic memory; it may
; be realloc'ed.

%_print.append.spaces.a0:
%_PrintAppendSpaces:
	test eax,eax										; null pointer?
	jz	> print_append_null 				; yes: create new string

	mov	ecx,[eax-8]									; ecx = current length of string
	lea	ebx,[ebx+ecx+1]							; ebx = position after last char after
																	; appending spaces
	jmp	%_print.tab.a0.eq.a0.tab.a1

print_append_null:
	lea	eax,[ebx+1]									; eax = one more than desired number of spaces
	jmp	%_print.tab.first.a0

; #################
; #####  END  #####
; #################
