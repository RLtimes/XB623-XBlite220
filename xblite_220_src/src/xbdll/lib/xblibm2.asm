; *********************
; *****  realloc  *****  reallocate chunk at addr(a) for n bytes
; *********************

.code

; *****  realloc  *****  C entry point  and  XBASIC entry point

;   in:	arg1 = new size
;	arg0 = current address of block to re-size
;  out:	eax -> new block, or NULL if none or error

; Stores new size into # of elements in header of new block.

realloc:
_realloc:
__realloc:
_Xrealloc:
___realloc FRAME size, address

	push ebx,esi,edi

	mov	esi,[address]								; esi -> current block (data, not header)
	mov	edi,[size]									; edi = new size
	call	%_____realloc
	mov	eax,[ebp+12]								; eax = new size
	mov	[esi-8],eax									; write new size into new block
	mov	eax,esi											; eax -> new block, or NULL if none

	pop	edi,esi,ebx

	cmp	eax,-1											; was there an error?
	jne	> _realloc_ret 							; no: just return normally
	xor	eax,eax											; yes: change return value to NULL

_realloc_ret:
	ret
	ENDF


; *****  realloc  *****  CORE ROUTINE  *****

;  in:	esi = DATA address of chunk to reallocate
;	edi = requested new size of block
; out:	esi = new DATA address of block, or NULL if no memory, or -1 if
;	      attempted to re-allocate a non-allocated block

; %____realloc destroys: edi
; %_____realloc  destroys: eax, ebx, ecx, edx, edi

; Local variables:
;	[ebp-4] = header of chunk to reallocate
;	[ebp-8] = requested new size of block
;	[ebp-12] = register spill

; It is the caller's responsibility to fill in the info word and # of
; elements in the new block.

%____realloc:
	push eax,ebx,ecx,edx
	call	%_____realloc
	pop	edx,ecx,ebx,eax
	ret


%_____realloc FRAME

	local header
	local new_size
	local spill

	sub	esi,16											; esi -> header of block to re-size
	test edi,edi										; is requested size 0?
	jz >	refree										; yes: just free the block

; check for out-of-bounds request address
	cmp	[_##DYNO],esi								; addr(1st header) > addr(request)?
	ja	> redisaster 								; if so, it's a disastrous error
	cmp	[_##DYNOX],esi							; addr(last header) < addr(request)?
	jb	> redisaster 								; if so, it's another disastrous error

	mov	[header],esi								; save pointer to header of block
	mov	[new_size],edi							; save requested new size
	bt d[esi+4],31									; see if allocated
	jc	> recheck

;	yes: reallocate it
;	no: fall through to error routine
redisaster:
	mov	esi,-1											; indicate that there was an error
	ret

; also: re-enter here after freeing higher free block, if applicable
recheck:
	mov	eax,edi											; eax = requested new size
	dec	eax													; eax = requested size - 1
	jns	> not_null									; if requested size != 0, compute pointer #
	inc	eax													; else set eax back to zero

not_null:
	mov	edi,eax											; edi = requested size - 1
	and	eax,0xFFFFFFF0							; eax = data size needed - 16
	add	eax,0x20										; eax = size needed including header
	mov	ebx,[esi+0]									; ebx = size of chunk now
	and	edi,0xFFFFFF00							; edi = 0 if required chunk <= 256 bytes
	jnz	> need_big_one							; separate algorithm for size > 256 bytes
	sub	ebx,eax											; ebx = excess size of current chunk
	jb	> need_more									; if excess size < 0, need bigger chunk

; current chunk is too big or just right
	lea	ecx,[esi+eax]								; ecx = addr(excess part of this chunk)
	cmp	ebx,0x20										; plus 32 bytes for another header/data?
	jae	> current_too_big 					; yes, so turn high portion into free area

; current chunk is perfect... leave it alone, return its address
perfectoid:
	add	esi,16											; esi -> DATA area of reallocated chunk
	ret

; current chunk is too big; make a new chunk (H) above and re-size this one (M)

current_too_big:
	mov	[esi+0],eax									; addr-uplink(M) = new-size(M)
	mov	[ecx+0],ebx									; addr-uplink(H) = size(H)
	bts	eax,31											; mark H as allocated
	mov	[ecx+4],eax									; addr-downlink(H) = new-size(M)
	btr	eax,31											; restore eax
	mov	edi,0x0001									; edi = 1 byte per element
	mov	[ecx+12],edi								; create info word in H
	lea	edx,[ecx+ebx]								; edx -> XH
	mov	esi,[edx+4]									; esi = XH addr-down-link
	and	esi,0x80000000							; remove all but alloc bit
	or	esi,ebx											; esi = alloc bit OR size(H)
	mov	[edx+4],esi									; add-downlink(XH) = size(H)
	mov	esi,ecx											; esi -> new chunk
	call	%____Hfree								; free the new chunk (H) (possible merge with XH)

; after H is freed, return address of shrunk chunk
	mov	esi,[header]								;	esi -> shrunk chunk
	add	esi,0x10										;	esi -> DATA area of shrunk chunk
	ret

; need a bigger chunk
; see if the next higher chunk is free and large enough
;  to provide sufficient room by merging with this chunk
need_more:
	mov	ebx,[esi+0]									; ebx = size of this chunk (M) now
	lea	edi,[ebx+esi]								; edi -> next higher chunk (H)
	mov	ecx,[edi+12]								; ecx = size-downlink(H)
	mov	edx,[edi+0]									; edx = size(H)
	bt d[edi+4],31									; if H is allocated, can't use H space
	jc	> not_enough

; H is free; is it too small, just right, or too big to expand into?
	add	edx,ebx											; edx = size(M) + size(H)
	cmp	edx,eax											; is excess size of M+H less than zero?
	jb	> not_enough 								; yes: not enough space here

; note: previous instruction was bcnd.n in 88000 version; I'm translating
; it as if it were bcnd

; size(M+H) is at least enough to fill request; graft H onto top of M
; address-unlink H from M and XH (address link M <==> H)
	lea	eax,[esi+edx]								; eax = addr(XH) = addr(M) + size(M+H)
	bts	edx,31											; XH is allocated
	mov	[eax+4],edx									; addr-downlink(XH) = size(M+H)
	btr	edx,31											; restore edx = size
	mov	[esi+0],edx									; addr-uplink(M) = size(M+H)
	mov	[spill],eax									; spill eax: [spill] = addr(XH)

; H is now address-unlinked; size-unlink it now
	mov	eax,[edi+8]									; eax = size-uplink(H)
	or ecx,ecx											; is size-downlink(H) != 0?
	jne	> down_not_ptr 							; yes: H is not 1st chunk of its size

; size-downstream from H is the pointer, not another chunk
	mov	ebx,[edi+0]									; ebx = size(H)
	sub	ebx,17											; ebx = size(H) - 17  (size of data - 1)
	shr	ebx,4												; ebx = (size-1) / 16 = pointer #
	cmp	ebx,16											; pointer # is beyond big-chunk pointer?
	jbe	> small_guy									; no, ebx is ok
	mov	ebx,16											; ebx = big-chunk pointer #

small_guy:
	mov	edi,[new_size]							; edi = original size request
	mov	[%pointers+ebx*4],eax 			; pointer = addr(SU(H))
	test eax,eax										; is there no SU(H)?
	jz  recheck											; nope: skip next instruction
	mov	[eax+12],ecx								; size-downlink(SU(H)) = addr(SD(H))
	jmp	recheck

down_not_ptr:
	mov	edi,[new_size]							; edi = original size request
	mov	[ecx+8],eax									; size-uplink(SD(H)) = addr(SU(H))
	test eax,eax										; is there no SU(H)?
	jz	recheck											; nope: skip next instruction
	mov	[eax+12],ecx								; size-downlink(SU(H)) = addr(SD(H))
	jmp	recheck

; H is now address-linked and size-unlinked; branch back to recheck fit
; not enough space in M for reallocation; get a new block to allocate

not_enough:
	mov	esi,[new_size]							; esi = original size request
	call	%_____malloc							; let malloc find a new block

; CORE malloc returns HEADER address of allocated chunk in esi
	mov	edi,[header]								; edi = header address of original chunk
	mov	ecx,[edi+0]									; ecx = total size of original chunk
	mov	edx,[edi+8]									; edx = word2 from original chunk
	mov	ebx,[edi+12]								; ebx = word3 from original chunk
	mov	eax,edi											; eax = header address of original chunk
	mov	[header],esi								; save new allocated address
	mov	[esi+8],edx									; new chunk's word2 = old chunk's word2
	mov	[esi+12],ebx								; new chunk's word3 = old chunk's word3

	sub	ecx,0x10										; start copy 16 words into it (i.e. skip header)
	xchg esi,edi										; esi -> original chunk; edi -> new chunk
	add	esi,0x10										; esi -> original chunk's data area
	add	edi,0x10										; edi -> new chunk's data area
	add	ecx,3
	shr	ecx,2												; divide size by 4 (# of bytes in dword)
	cld															; make sure direction is right
	jecxz	> recalloc_skip
	rep movsd												; copy original data area to new data area

; original data has been moved to new destination; free original chunk
recalloc_skip:
	mov	esi,eax											;	esi = address of original chunk
	call	%____Hfree								;	free original chunk

; original chunk is free; return address of new chunk containing original data
	mov	esi,[header]								; esi -> header of new chunk

another_perfectoid:								; same as perfectoid; label allows short branch
	add	esi,0x10										; esi -> data area of new chunk
	ret

; need a big chunk to reallocate the chunk size requested

; esi = address of chunk to realloc
; ebx = chunk size now, including header (mod 16 size)
; eax = chunk size needed, including header (mod 16 size)

need_big_one:
	mov	edi,ebx
	sub	edi,eax											; edi = (size now - size needed) = excess size
	js	need_more										; if excess < 0 then need a bigger chunk

; previous instruction was bcnd.n; I'm translating it as if it were bcnd
	mov	edx,edi
	shl	edx,1												; edx = excess * 2
	cmp	edx,eax											; is size-now < 1.5 times size-needed?
	jb	 another_perfectoid 				; yes: leave as is

; previous instruction was bcnd.n; I'm translating it as if it were bcnd
	mov	edx,eax
	shr	edx,3												; edx = .125 * size needed
	add	eax,edx											; eax = 1.125 * size needed (size to make it)
	and	eax,0xFFFFFFF0							;	eax = mod 16 size of reallocated chunk
	lea	ecx,[esi+eax]								;	ecx = address of H chunk to create/free
	sub	ebx,eax											;	ebx = excess size of existing = size(new H)
	jmp	current_too_big

refree:
	call	%____Hfree								;	free chunk being realloc'ed tp zero size
	xor	esi,esi											;	return zero
	ret
	ENDF

; #################
; #####  END  #####
; #################
