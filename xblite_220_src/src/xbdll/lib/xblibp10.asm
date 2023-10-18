; **********************************
; *****  %_print.tab.first.a0  *****  creates a string containing a given number
; **********************************  of spaces

.code

; in:	eax = one more than number of spaces to create
; out:	eax -> created string

; destroys: edx, esi, edi

; Result string is dynamically allocated; freeing it is the caller's
; responsibility.  Returns null pointer if caller asks for zero or
; fewer spaces.

%_print.tab.first.a0:
	lea	esi,[eax-1]									; esi = # of spaces to create
	or	esi,esi											; zero or less?
	jbe	 > ptf_null									; yes: return null string

	push	ebx												; must not destroy a1
	push	ecx

	push	eax
	add	esi,64											; get 64 bytes more than required, since string
																	; will probably be appended to
	call	%____calloc								; esi -> new string
	pop	ebx													; ebx = requested tab stop

	mov eax,0x80130001							; indicate: allocated string
	mov	[esi-4],eax									; store new string's info word

	mov	edi,esi											; edi -> new string
	lea	ecx,[ebx-1]									; ecx = # of spaces to create
	mov	[esi-8],ecx									; store length of new string
	cld
	mov	al,' '											; ready to write spaces
	rep stosb												; write them spaces!
	mov	b[edi],0 										; null terminator at end of string
	mov	eax,esi											; eax -> new string
	pop	ecx													; restore a1
	pop	ebx
	ret

ptf_null:
	xor	eax,eax											; return null pointer
	ret


; #################
; #####  END  #####
; #################
