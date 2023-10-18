
;  ****************************
;  *****  %_RedimArray    *****  redimensions an array
;  ****************************  contents are not altered!

.code

; in:	arg11 = upper bound of eighth dimension
;	arg10 = upper bound of seventh dimension
;	arg9 = upper bound of sixth dimension
;	arg8 = upper bound of fifth dimension
;	arg7 = upper bound of fourth dimension
;	arg6 = upper bound of third dimension
;	arg5 = upper bound of second dimension
;	arg4 = upper bound of first dimension		[ebp+24]
;	arg3 unused
;	arg2 = word 3 of header (info word)		[ebp+16]
;	arg1 = # of dimensions (maximum allowed: 8)	[ebp+12]
;	arg0 -> array address (i.e. [arg0] -> array)	[ebp+8]
; out:
;	eax -> highest-dimension array (to be stored in handle)
;	       or < 0 if error

; destroys: ebx, ecx, edx, esi, edi

; local variables:
;	[ebp-4] = dim.number, i.e. current dimension
;	[ebp-8] = new # of elements in current dimension

%_RedimArray:
	cmp d[esp+4],0									; null array?
	jne	>
		jmp %_DimArray								; yes: if never dimensioned, same as DIM
	:

	push	ebp
	mov	ebp,esp
	sub	esp,8

	mov d[ebp-4],0									; dim.number = 0
	mov	esi,[ebp+8]									; esi = base address of array
	call	redim.array.smaller
	cmp	esi,-1											; error ?
	je	> redim_exit								; yes: return without freeing the rest

	mov d[ebp-4],0									; dim.number = 0
	call	redim.array.larger

redim_exit:
	mov	eax,esi											; eax -> new array
	leave
	ret

; ***** recursive entry point  (does not modify ebp or allocate local frame)
;	redimensions all arrays that are being changed to smaller dimensions
;	in:	[ebp-4] = dim.number = last dimension redim'ed
;		esi -> array to redimension
;	out:	esi -> redimensioned array (may be different than on entry)

redim.array.smaller:
	test esi,esi										; null array?
	jz	> redim.null								; yes: don't redimension it smaller

	inc d[ebp-4]										; INC dimNumber
	mov	ebx,[ebp-4]									; ebx = dim.number = current dimension
	mov	eax,[esi-4]									; eax = info word of array
	mov	edx,[esi-8]									; edx = old # of elements
	dec	edx													; edx = old upper bound

	cmp	ebx,[ebp+12]								; at new lowest dimension?
	jne	> rs.not.lowest.dim 				; no: at an array of pointers to arrays
rs.lowest.dim:										; yes: at an array of actual data
	mov	edi,eax											; save old info word
	xor	eax,[ebp+16]								; bit 29 of eax = 1 iff not-lowest-dim bit of
																	; new array is different than not-lowest-dim
																	; bit at current dimension in old array
	test	eax,0x20000000						; changed number of dims?
	jnz	> redim.changed.dims				; yes: error: new # of dims

; I have no check for a type mismatch (??? who and why ???)
	mov	ecx,[ebp+20+ebx*4] 					; ecx = new upper bound for current dimension
	mov	[ebp-8],ecx									; save it
	cmp	ecx,edx											; new upper bound less than old upper bound?
	jge	> rs.recalloc 							; no: there's nothing to free	' 06/18/93

	mov	eax,[esi-4]									; eax = info word
	and	eax,0x00FF0000							; eax = just data-type field from info word
	cmp	eax,0x00130000							; is array of string type?
	je	> rs.free.strings 					; yes: free them extraneous strings

	test	edi,0x20000000						; lowest dim contains arrays?
	jz	> rs.recalloc 							; no: there's nothing to free

rs.free.strings:
	inc	ecx													; ecx = current element = newUpperBound + 1
rs.free.string.loop:
	push	esi
	push	ecx
	push	edx
	mov	esi,[esi+ecx*4]							; esi -> array[elem]   (i.e. current string)
	call	%____free									; free current element
	pop	edx
	pop	ecx
	mov	eax,esi											; eax = result from %____free
	pop	esi
	cmp	eax,-1											; error ?
	je	> redim.malloc.error				; yes: return without more free

	inc	ecx													; INC current element
	cmp	ecx,edx											; past old upper bound?
	jbe	rs.free.string.loop 				; no: free another string

rs.recalloc:
	mov	edi,[ebp-8]									; edi = new upper bound
	inc	edi													; edi = new # of elements in current dimension
	movzx	eax,w[esi-4] 							;	eax = # of bytes per element
	imul	edi,eax										; edi = # of bytes required for new array

	call	%____recalloc							; esi -> resized array
	test esi,esi										; esi = 0 = recalloc to empty string/array ???	; add 95/03/03
	jz	> rs.done										; yes						; add 95/03/03
	cmp	esi,-1											; error ?
	je	> redim.malloc.error				; yes: return without more free

	mov	eax,[ebp-8]									; eax = new upper bound of current dimension
	inc	eax													; eax = new # of elements
	mov	[esi-8],eax									; store it in header of array
	jmp	 rs.done

rs.not.lowest.dim:								; we're at an array of pointers to arrays
	test	eax,0x20000000						; at old lowest dimension or original array?
	jz	> redim.changed.dims 				; yes: error: new # of dims

	xor	ecx,ecx											; ecx = current elem = 0
	mov	ebx,[ebp+20+ebx*4] 					; ebx = new upper bound for current dimension
rs.shrink.loop:
	cmp	ecx,ebx											; current elem <= new upper bound?
	ja	> rs.free.array 						; no: free current element
																	; yes: redim current element
	mov	edi,esi											; edi -> current array
	mov	esi,[esi+ecx*4]							; esi = current element
	push	edi,ebx,ecx,edx
	call	redim.array.smaller 			; esi = new current element
	pop	edx,ecx,ebx,edi							; edi -> current array
	cmp	esi,-1											; error ?
	je	> rs.done										; yes: return without freeing the rest

	mov	[edi+ecx*4],esi							; store new current element
	mov	esi,edi
	jmp	 rs.shrink.loop.end

rs.free.array:										; current elem is beyond new dim: free it
	push	esi
	push	ebx,ecx,edx
	mov	esi,[esi+ecx*4]							; esi = current element
	call	%_FreeArray
	pop	edx,ecx,ebx
	pop	eax													; eax -> current array
	mov d[eax+ecx*4],0							; zero current elem (unnecessary, I think)
	cmp	esi,-1
	je	> rs.done
	mov	esi,eax											; esi -> current array

rs.shrink.loop.end:
	inc	ecx													; INC elem
	cmp	ecx,edx											; past old upper bound?
	jbe	rs.shrink.loop							; no: keep going
	jmp	 rs.done										; yes: all done

; the following four entry points are called from both redim.array.smaller
; and redim.array.larger
redim.malloc.error:								;	recalloc or free got an error
redim.changed.dims:								;	attempted to change # of dims
redim.ragged:											;	discovered ragged array
																	;	call appropriate run-time error routine?
	mov	esi,-1											;	esi < 0 to indicate error

rs.done:
rl.done:
	dec d[ebp-4]										;	DEC dimNumber
redim.null:												;	tried to redim null sub-array (esi assumed 0)
	ret															;	end of redim.array.smaller


; ***** recursive entry point  (does not modify ebp or allocate local frame)
;	redimensions all arrays that are being changed to larger dimensions
;	in:	[ebp-4] = dim.number = last dimension redim'ed
;		esi -> array to redimension
;	out:	esi -> redimensioned array (may be different than on entry)

redim.array.larger:
	inc d[ebp-4]										;	INC dimNumber
	mov	ebx,[ebp-4]									;	ebx = dimNumber
	cmp	ebx,[ebp+12]								;	at new lowest dim?
	mov	ebx,[ebp+20+ebx*4] 					;	ebx = new upper bound
	jb	> rl.not.lowest.dim 				;	no: we're at an array of pointers

rl.lowest.dim:										;	yes: we're at some real data
	or	ebx,ebx											;	ebx < 0 means want empty array here	; 95/03/03
	js	 rl.done										;	so can't be larger - done		; 95/03/03
	push	ebx
	movzx	edi,w[esi-4] 							;	edi = old # of bytes per element
	inc	ebx													;	ebx = new # of elements
	imul	edi,ebx										;	edi = bytes required by new array
	call	%____recalloc							;	esi -> resized array
	pop	ebx
	cmp	esi,-1
	je	 redim.malloc.error
	inc	ebx													;	ebx = new # of elements
	mov	[esi-8],ebx									;	store new # of elements
	jmp	 rl.done										;	all done

rl.not.lowest.dim:								;	we're at an array of pointers to arrays
	or	ebx,ebx											;	ebx < 0 means want empty array here	; 95/03/03
	js	 rl.done										;	so can't be larger - done		; 95/03/03
	push	ebx
	movzx	edi,w[esi-4] 							;	edi = old # of bytes per element
	inc	ebx													;	ebx = new # of elements
	imul	edi,ebx										;	edi = bytes required by new array
	call	%____recalloc							;	esi -> resized array
	pop	ebx
	cmp	esi,-1
	je	 redim.malloc.error
	inc	ebx													; ebx = new # of elements
	mov	[esi-8],ebx									; store new # of elements
	dec	ebx													; ebx = new upper bound

	xor	ecx,ecx											; ecx = current element # = 0
	mov	edi,esi											; edi -> current array
rl.redim.loop:
	push	ebx
	push	ecx
	push	edi
	mov	esi,[edi+ecx*4]							; esi = current element
	test esi,esi										; null pointer?
	jz	> rl.dim.array							; yes: replace it with a new (empty) array
																	; no: recurse through it
	call	redim.array.larger 				; esi -> new element
	jmp	 rl.redim.loop.end


rl.dim.array:
	call	dim.dim										; esi -> new element

rl.redim.loop.end:
	pop	edi
	pop	ecx
	pop	ebx
	cmp	esi,-1
	je	rl.done
	mov	[edi+ecx*4],esi							; store pointer to new array
	inc	ecx													; INC current element number
	cmp	ecx,ebx											; past new upper bound?
	jbe	rl.redim.loop								; no: keep going
	mov	esi,edi											; esi -> array again
	dec d[ebp-4]										; DEC dimNumber
	ret

; #################
; #####  END  #####
; #################
