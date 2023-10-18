; **********************
; *****  recalloc  *****  reallocate chunk at addr(a) for n bytes, zero excess
; **********************

.code

; *****  recalloc  *****  C entry point  and  XBASIC entry point

; in:	size = new size
;	 address = current address of block to re-size
; out:	eax -> new block, or NULL if none or error

; local variables:
;	old_size = old # of bytes in object
;	new_size = new # of bytes in object

recalloc:
_recalloc:
__recalloc:
_Xrecalloc:
___recalloc FRAME size, address

	USES ebx,esi,edi

	local old_size
	local new_size

	mov	esi,[address]								;	esi -> DATA area of chunk to recalloc
	sub	esi,0x10										;	esi -> HEADER of chunk to recalloc
	mov	ebx,[esi+8]									;	ebx = old # of elements

	;replace following two instructions with movzx eax,[esi+12]?
	mov	eax,[esi+12]								;	eax = old info word
	and	eax,0xFFFF									;	eax = old # of bytes per element
	imul	ebx,eax										;	ebx = old # of bytes in object
	mov	eax,[size]									;	eax = new # of bytes in object
	mov	[old_size],ebx							;	save old # of bytes in object
	mov	[new_size],eax							;	save new # of bytes in object

	add	esi,0x10										;	esi -> DATA area of chunk to recalloc
	mov	edi,eax											;	edi = new # of bytes in object
	call	%____realloc							;	re-size the chunk (preserving current data)

	test esi,esi										;	couldn't allocate memory?
	jz	> recalloc_error
	cmp	esi,-1											;	tried to recalloc a non-allocated block?
	jne	> recalloc_ok
	xor	esi,esi											;	indicate error so that C can understand it
	jmp	 recalloc_error

recalloc_ok:
	mov	ebx,[old_size]							;	restore old # of bytes in object
	mov	eax,[new_size]							;	restore new # of bytes in object
	call	zero.excess								;	zero chunk after last active byte

recalloc_error:
	mov	eax,esi
	ret
	ENDF


; *****  zero.excess  *****  zero chunk

;   in:	esi -> data area of realloc'ed chunk
;	ebx = old # of bytes in object
;	eax = new # of bytes in object
;  out:	esi -> data area of recalloc'ed chunk (same as on input)

; destroys: eax, ebx, ecx, edx, edi

zero.excess:
	test esi,esi										; new size = empty ???
	jz >	zero.done									; yes - nothing to zero

	cmp	ebx,eax											; if old # of bytes < new # of bytes
	jae	> zero.skip									; then use old
	mov	eax,ebx											; eax = old # of bytes = # to leave alone

zero.skip:
	lea	edi,[esi+eax]								; edi -> where to start zeroing
	mov	ecx,[esi-16]								; ecx = size of chunk including header
	sub	ecx,0x10										; ecx = size of chunk excluding header
	sub	ecx,eax											; ecx = size of chunk - # to leave alone =
																	; # of bytes to zero
	jbe	> zero.done									; if negative or none, no excess and no zeroing
	xor	eax,eax											; ready to write some zeros
	cld															; make sure we write them in the right direction

q.zero.byte:
	test	edi,1											; if bit 0 == 0 then no bytes to zero
	jz	> q.zero.word
	stosb														; write a zero byte
	dec	ecx													; ecx = # of bytes left to zero
	jz	> zero.done

q.zero.word:
	test	edi,2											;	if bit 1 == 0 then no words to zero
	jz	> q.zero.dwords
	stosw														;	write two zero bytes
	sub	ecx,2												;	ecx = # of bytes left to zero
	jz	> zero.done
q.zero.dwords:
	shr	ecx,2												;	ecx = # of dwords to zero
	jecxz >	zero.done								;	skip if nothing left to zero
	call %_ZeroMem0									;	write zeros

zero.done:
	ret


; **********************
; *****  recalloc  *****  reallocate chunk at addr(a) for n bytes, zero excess
; **********************

; *****  recalloc  *****  internal entry point

;   in:	esi -> data area of block to resize
;	edi = requested new number of bytes
;  out:	esi -> new block, NULL if esi was NULL on entry, or -1 if error

; destroys: edi

; local variables:
	old_bytes = ebp-4	;	[ebp-4] = old # of bytes in object
	new_bytes = ebp-8	;	[ebp-8] = new # of bytes in object

%____recalloc:
	test esi,esi										; null pointer?
	jz	> rc_null										; yes: calloc instead

	push	ebp
	mov	ebp,esp
	sub	esp,8
	push eax,ebx,ecx,edx

	mov	ebx,[esi-8]									; ebx = old # of elements

; replace following two instructions with movzx eax,[esi+12] ???
	mov	eax,[esi-4]									;	eax = old info word
	and	eax,0xFFFF									;	eax = old # of bytes per element
	imul	ebx,eax										;	ebx = old # of bytes in object
	mov	[old_bytes],ebx							;	save old # of bytes in object
	mov	[new_bytes],edi							;	save new # of bytes in object

	call	%_____realloc							; re-size the chunk (preserving current data)
	cmp	esi,-1											; tried to recalloc a non-allocated block?
	je	> rc_error									; yes: abort

	mov	ebx,[old_bytes]							; restore old # of bytes in object
	mov	eax,[new_bytes]							; restore new # of bytes in object
	call	zero.excess								; zero chunk after last active byte

rc_error:
	pop	edx,ecx,ebx,eax
	leave
	ret

rc_null:
	mov	esi,edi											; esi = requested number of bytes
	call	%____calloc
	pop	edx,ecx,ebx,eax
	leave
	ret
#undef old_bytes
#undef new_bytes

; #################
; #####  END  #####
; #################
