
; ********************************
; *****  %_PrintAppendComma  *****  appends enough spaces to reach next tab stop
; ********************************

.code

; in:	eax -> string to append to
; out:	eax -> string with spaces appended to it

; destroys: ebx, ecx, edx, esi, edi

%_PrintAppendComma:
	test eax,eax										; appending to null string?
	jnz	>
	jmp	%_PrintFirstComma 					; yes: use simpler subroutine
	:

	mov	esi,eax											; esi -> original string (safe from upcoming DIV)
	mov	eax,[eax-8]									; eax = size of current string
	mov	ecx,[_##TABSAT]							; there's a tab stop every ecx columns
	cld
	xor	edx,edx											; clear high-order bits of dividend
	div	cx													; edx = LEN(string) MOD [##TABSAT]
	sub	ecx,edx											; ecx = # of spaces to add to get to next tab

	mov	eax,[esi-8]									; eax = length of original string
	lea	edi,[eax+ecx]								; edi = length needed
	inc	edi													; one more for terminating null
	mov	edx,[esi-16]								; edx = length of string's chunk including header
	sub	edx,16											; edx = length of string's chunk excluding header
	cmp	edx,edi											; chunk big enough to hold expanded string?
	jae	> pac.big.enough 						; yes: skip realloc

	push eax,ecx,edx
	call	%____realloc							; esi -> string with enough space to hold new
	pop	edx,ecx,eax									; spaces; all other registers destroyed

pac.big.enough:
	lea	edi,[esi+eax]								; edi -> char after last char of original string
	mov	al,' '											; ready to write some spaces
	jecxz	> pac.skip.stosb					; ecx should be != 0, but just in case...
	rep stosb												; append them spaces!

pac.skip.stosb:
	mov	b[edi],0 										; append null terminator
	sub	edi,esi											; edi = length of new string
	mov	[esi-8],edi									; store length of new string
	mov eax,0x80130001							; eax = new info word: allocated ubyte.string
	mov	[esi-4],eax									; store new info word
	mov	eax,esi											; eax = return value = addr of new string
	ret


; #################
; #####  END  #####
; #################
