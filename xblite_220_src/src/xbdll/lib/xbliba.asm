
; ########################
; #####  xbliba.asm  #####  Low-level array processing
; ########################

.code

; ************************
; *****  %_DimArray  *****  dimensions an array
; ************************  (recursive to handle multi-dimensional arrays)

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

; destroys: ebx, ecx, edx, esi, edi

; local variables:
;	[ebp-4] = dim.number, i.e. current dimension
;	[ebp-8] = # of elements in current dimension

;  array headers look like this:

;	word3 = info.word = info.byte + data.type.byte + bytes.per.element.word
;	word2 = upper.bound of this dimension
;	word1 = address downlink  (MSb = 1 if chunk allocated (new 01-June-93)
;	word0 = address uplink

;  info word bits:
;	bit 31 = NO LONGER USED (the next line is obsolete)
;	bit 31 = ALLOCATED  	(must always = 1 on allocated chunks)
;       bit 30 = ARRAY BIT  	(1 = array, 0 = string)
;	bit 29 = NON-LOW-DIM	(1 = non-lowest-dimension, 0 = lowest dimension)
;	bit 28 =
;	bit 27 =
;	bit 26 =
;	bit 25 =
;	bit 24 = INFOMASK       (1 = USER array, 0 = SYSTEM array)

%_DimArray:
	push ebp
	mov	ebp,esp
	sub	esp,8

	mov	esi,[ebp+8]									; esi -> base address of array
	test esi,esi										; null pointer?
	jz	> DimArray									; yes: don't bother to free it
	call	%_FreeArray								; no: free existing array first

DimArray:
	mov d[ebp-4],0									; dim.number starts at zero
	call	dim.dim										; do the dimensioning

	mov	eax,esi											; eax -> base address of array
	leave
	ret

; ***** recursive entry point  (does not modify ebp or allocate local frame)
;	in:	[ebp-4] = dim.number = last dimension that was dimensioned
;	out:	esi -> base address of dimensioned array
;	destroys: eax, ebx, ecx, edx, edi, [ebp-8]

dim.dim:
	inc d[ebp-4]										; next dim.number
	mov	ebx,[ebp-4]									; ebx = dim.number, i.e. current dimension
	mov	eax,[ebp+20+ebx*4] 					; eax = upper.bound for current dimension
	xor	esi,esi											; prepare to return null pointer if necessary
	add	eax,1												; eax = # of elements in current dim
	mov	[ebp-8],eax									; save it
	jle	> dim.dim.exit 							; if negative upper bound (illegal), then
																	; return null array (a zero)
	cmp	ebx,[ebp+12]								; is current dim < total # of dims?
	jl	> not.lowest.dim 						; yes: not yet on lowest dim

; create lowest-dimension array
lowest.dim:
	mov	esi,eax											; esi = # of elements in current dimension
	movzx	eax,w[ebp+16] 						; eax = # of bytes per element
	imul	esi,eax										; esi = total # of bytes in array
	call	%_____calloc							; allocate and zero array
																	; esi -> array's header
	test esi,esi										; error?
	jz	> dim.dim.exit							; yep (88000 version jumps to dim.dim.exit)

	mov	eax,[ebp+16]								; eax = info word
	mov	[esi+12],eax								; put info word in array's header
	mov	eax,[ebp-8]									; eax = # of elements in lowest dimension
	mov	[esi+8],eax									; put # of elements in array's header
	add	esi,16											; esi -> data area of array
	jmp	> dim.dim.exit

; create non-lowest-dimension array
;	in: eax = # of elements in current dimension
not.lowest.dim:
	lea	esi,[eax*4]									; esi = # elems in current dim * 4 = # of bytes
	call	%_____calloc							; allocate and zero array
																	; esi -> array's header
	test esi,esi										; error?
	jz	> dim.dim.exit 							; yep (88000 version jumps to dim.dim.exit)

	mov	eax,[ebp+16]								; eax = info word
	mov	ax,4												; bytes per element = 4
	or	eax,0x20000000							; not.lowest.dim = TRUE  (in info word)
	mov	[esi+12],eax								; put info word in array's header
	mov	eax,[ebp-8]									; eax = # of elements in current dimension
	mov	[esi+8],eax									; put # of elements in array header

	lea	ebx,[esi+16]								; ebx -> array's data area
	xor	ecx,ecx											; ecx = current element number
	mov	edx,eax											; edx = # of elements in current dimension

dim.loop:
	push ebx,ecx,edx								; watch out for those recursive functions!
	call	dim.dim										; allocate array for current element
	pop	edx,ecx,ebx									; esi -> its base address

	test esi,esi										; error?
	jz	> dim.dim.exit 							; yep
	mov	[ebx+ecx*4],esi							; store pointer for current element
	inc	ecx													; current element number++
	cmp	ecx,edx											; current element = # of elements?
	jne	dim.loop										; no: keep going
																	; yes: fall through
	mov	esi,ebx											; esi -> base address of just-allocated array

dim.dim.exit:
	dec d[ebp-4]										; dim.number--
	ret															; esi -> base address of just-allocated array


; *************************
; *****  %_FreeArray  *****  frees an array
; *************************  (recursive to handle multi-dimensional arrays)

; in:	esi -> base address of array to free

; out:	esi < 0 iff error, 0 if ok

; destroys: ebx, ecx, edi  (must not destroy "eax/edx" return values)

; local variables:
;	[ebp-4]	= current element
;	[ebp-8] -> array to free

%_FreeArray:
	push	ebp
	mov	ebp,esp
	push	eax												; save eax  (return value from function)
	push	edx												; save edx  (ditto if GIANT or DOUBLE)
	sub	esp,8

	test esi,esi										; is array free already?
	jz	> a.free.exit 							; yes

	mov	eax,[esi-4]									; eax = info word
	test	eax,0x40000000						; test bit 30: array/string bit
	jz	> ok.to.free.this 					; if it's a string, free it
	test	eax,0x20000000						; test bit 29: no-low-dim bit
	jnz	> not.lowest.free 					; if not lowest dim, free its elements
	and	eax,0x00FF0000							; eax = just data-type field from info word
	cmp	eax,0x00130000							; is object of string.type?
	je	> not.lowest.free 					; yes: free strings first (?)

; lowest.dim and numeric, or string... so free it

ok.to.free.this:
	call	%____free									; free the object
	test esi,esi										; error?
	jz	> a.free.bad
a.free.ok:
	xor	esi,esi											; esi = 0 to indicate success
a.free.exit:
	mov	esp,ebp
	mov	eax,[ebp-4]
	mov	edx,[ebp-8]
	pop	ebp
	ret

not.lowest.free:
	xor	edx,edx											; current element number = 0
	mov	[ebp-12],edx								; save current element number
	mov	[ebp-16],esi								; save pointer to first element of array

a.free.loop:
	mov	esi,[esi+edx*4]							; esi -> chunk to free
	test esi,esi										; null element?
	jz	> a.free.null 							; yes: go to next element
	call	%_FreeArray								; no: free it and all its sub-arrays (and so on)

	cmp	esi,-1											; error ?
	je	 a.free.exit 								; yes: return without freeing the rest

a.free.null:
	mov	esi,[ebp-16]								; esi -> first element of array to free
	inc d[ebp-12]										; current element number++
	mov	edx,[ebp-12]								; edx = current element number
	cmp	edx,[esi-8]									; current element number >= number of elements?
	jb	a.free.loop									; no: free next element
																	; yes: free current array
	call	%____free									; free current array
	test esi,esi										; error?
	jnz	a.free.ok										; no: say so and return
																	; yes: fall through and indicate error
a.free.bad:												; esi assumed to be zero on entry
	dec	esi													; esi is now < 0 to indicate error
	mov	esp,ebp
	mov	eax,[ebp-4]
	mov	edx,[ebp-8]
	pop	ebp
	ret

; #################
; #####  END  #####
; #################


