
; #########################
; #####  xblibs1.asm  #####
; #########################

.code

; ***************************************
; *****  %_CompositeStringToString  *****
; ***************************************

; The result string is a conventional string.  The length
; of the result string is the length of the composite string
; up to the first 0x00 byte, or the whole composite string
; if it contains no 0x00 byte.

; edi = length in bytes
; esi = source address

%_CompositeStringToString:
	push	eax
	push	edx
	push	ebx
	push	ecx
	push	edi												; save composite string length
	push	esi												; save address of composite string
	mov	edx,edi											; edx = length of composite string
	mov	ecx,edi											; ecx = length of composite string
	mov	edi,esi											; edi = addr of composite string
	xor	eax,eax											; eax = 0 = byte to search for

	cld															; search forward
	repne														; repeat while not equal
	scasb														; find 0x00 byte in composite string

	mov	esi,edx											; esi = length of composite string
	jnz	> nozmatch									; no 0x00 byte in composite string
	dec	edi													; edi = address of 0x00 byte
	sub	edi,[esp]										; edi = addr of 0x00 - addr of composite string
	mov	esi,edi											; esi = length of composite string before 0x00
	jz	> ccsempty									; return empty string

nozmatch:
	push	esi												; save length of string
	inc	esi													; make room for 0x00 terminator
	call	%____calloc								; allocate space for result string

	mov	eax,0x80130001							; word3 of header for strings
	mov	[esi-4],eax									; word3 of header = 1 byte string

	pop	ecx													; ecx = length of string
	mov	[esi-8],ecx									; word2 of header = # of bytes in string

	mov	edi,esi											; edi = address of destination string
	pop	esi													; esi = address of composite string
	push	edi												; save address of destination string

	cld															; forward move
	rep															; repeat/move ecx bytes
	movsb														; move composite string to destination string

ccsdone:
	pop	esi													; esi = address of destination string
	pop	edi													; edi = entry edi
	pop	ecx													; ecx = entry ecx
	pop	ebx													; ebx = entry ebx
	pop	edx													; edx = entry edx
	pop	eax													; eax = entry eax
	ret

ccsempty:
	pop	esi													; esi = address of composite string (useless)
	pop	edi													; edi = entry edi
	pop	ecx													; ecx = entry ecx
	pop	ebx													; ebx = entry ebx
	pop	edx													; edx = entry edx
	pop	eax													; eax = entry eax
	xor	esi,esi											; esi = result = 0x00000000 = empty string
	ret

; #################
; #####  END  #####
; #################
