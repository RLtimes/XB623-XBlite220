; ************************
; *****  %_clone.a0  *****  clones object pointed to by eax
; ************************

.code

; in:	eax -> object to clone
; out:	eax -> cloned object

; Destroys: edx, esi, edi.

; Returns 0 in eax if eax was 0 on entry or if size of object to clone is 0.

%_clone.a0:
	test eax,eax										; were we passed a null pointer?
	jz	> xret											; yes: get out of here
	push	ebx												; must not trash ebx (accumulator 1)
	push	ecx												; ecx is part of accumulator 1

	movzx	ebx,w[eax-4] 							; ebx = # of bytes per element
	mov	esi,[eax-8]									; esi = # of elements
	test esi,esi										; test esi for 0x00  (zero elements)
	jnz	> ok.a0											; object not empty
	pop	ecx													; restore ecx
	pop	ebx													; restore ebx
	ret															; done

ok.a0:
	mov	edx,esi											; save # of elements for later
	imul	esi,ebx										; esi = size of object to clone
	test esi,esi										; imul leaves ZF in a random state!
	jz	> clone.a0.null							; if object is zero len, quit and return null

	push	esi												; save # of bytes for rep movsd, later
	inc	esi													; add one to size, for terminator (is this
	push	eax												; necessary?)
	push	edx
	call	%____calloc								; esi -> data area of new block
	pop	edx
	pop	eax
	pop	ecx													; ecx = # of bytes for rep movsd

	mov	ebx,[eax-4]									; ebx = info word of original object
	btr	ebx,24											; ebx
	or	ebx,0												; OR whomask into info word

	mov	[esi-4],ebx									; store (old_infoword | whomask) to new infoword
	mov	[esi-8],edx									; store old # of elements to new object's header

	mov	ebx,esi											; save pointer to new block for later
	mov	edi,esi											; edi -> data area of new block
	mov	esi,eax											; esi -> data area of old block
	add	ecx,3												; round # of bytes to move up to next
;																	; four-word boundary
	shr	ecx,2												; ecx = # of dwords to move
	cld															; make sure direction is right
	rep movsd												; clone it!

	mov	eax,ebx											; eax -> cloned object's data area
	pop	ecx
	pop	ebx
	ret

clone.a0.null:
	xor	eax,eax											; return null pointer
	pop	ebx
	pop	ecx

xret:
	ret


; #################
; #####  END  #####
; #################
