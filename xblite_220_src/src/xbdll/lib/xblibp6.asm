
; *******************************
; *****  %_PrintFirstComma  *****  creates string with spaces for first tab stop
; *******************************

.code

; in:	nothing
; out:	eax -> string with [_##TABSAT] spaces in it

; destroys: ebx, ecx, edx, esi, edi

%_PrintFirstComma:
	mov	esi,[_##TABSAT]							; esi = # of spaces to create
	cld
	add	esi,64											; get more than necessary (caller will almost
																	; certainly append to this string)
	call	%_____calloc							; esi -> header of new string
	add	esi,16											; esi -> new string

	mov	edi,esi											; edi -> new string
	mov	ecx,[_##TABSAT]							; ecx = # of spaces to create
	jecxz	> pfc.no.stosb						; no tab stops?
	mov	al,' '											; ready to write some spaces
	rep stosb												; write them spaces!

	pfc.no.stosb:
	mov	b[edi],0 										; write terminating null
	sub	edi,esi											; edi = length of string
	mov	[esi-8],edi									; store length of new string
	mov	eax,0x80130001							; eax = new info word: allocated ubyte.string
	mov	[esi-4],eax									; store new info word

	mov	eax,esi											; eax = return value = addr of new string
	ret


; #################
; #####  END  #####
; #################
