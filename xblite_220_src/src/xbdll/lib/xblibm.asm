
; ########################
; #####  xblibm.asm  #####  Memory-allocation routines
; ########################


#define  PAGE_NOACCESS	  				0x00000001
#define  MEM_RESERVE	  					0x00002000
#define  PAGE_READWRITE   				0x00000004
#define  MEM_COMMIT	  						0x00001000

; ********************
; *****  calloc  ***** allocate and clear a chunk for n elements of m bytes
; ********************

; *****  calloc  *****  C entry point

; in:  size = size of each element
;		 number = number of elements
; out:	eax -> allocated block, or NULL if memory not available

; Also returns NULL if size of requested block is zero.

.code

calloc:
_calloc:
__calloc FRAME number, size
	xor	eax,eax											; speed up following comparisons (I think)
	cmp	[number],eax	             	; number of elements = 0?
	jz	> ccalloc0									; then quit wasting my time
	cmp	[size],eax									; same if element size is zero
	jz	> ccalloc0

	push ebx,esi,edi

	mov	esi,[size]
	imul	esi,[number]							; esi = # of element * element size = total size
	call	%_____calloc							; esi -> new block's header, or NULL if none
	mov	eax,esi

	pop	edi,esi,ebx

	test eax,eax
	jz	> ccalloc0
	add	eax,16
ccalloc0:
	ret
	ENDF


; *****  calloc  *****  XBASIC entry point

;  in:  size = total size of block to allocate
; out:	eax -> allocated block, or NULL if memory not available

; Also returns NULL if size of requested block is zero.

; Except for the fact that the XBASIC entry point for calloc takes
; only one parameter, the result of multiplying the C entry point's
; parameters together, this entry point is the same as the C
; entry point.
;
_Xcalloc:
___calloc FRAME size
	cmp d[size],0										; size to allocate is zero?
	jz	> xcalloc0									; then quit wasting my time

	push	ebx,esi,edi

	mov	esi,[size]									; esi = size of block to allocate
	call	%_____calloc							; esi -> new block's header, or NULL if none
	mov	eax,esi

	pop	edi,esi,ebx

	test eax,eax										; null pointer?
	jz	> xcalloc0
	add	eax,16
xcalloc0:
	ret
	ENDF


; *****  calloc  *****  internal entry point

; in:	esi = size of block to allocate
; out:	esi -> allocated block's data area, or zero if error

; destroys: edi

%____calloc:
	USES eax,ebx,ecx,edx
	call	%_____calloc
	test esi,esi
	jz	> icalloc0
	add	esi,16
icalloc0:
	ret
	ENDU

; *****  calloc  *****  CORE ROUTINE

;  in:  esi = size of block to allocate
; out:  esi -> allocated block's HEADER (not data)

; destroys: eax, ebx, ecx, edx, edi

%_____calloc:
	test esi,esi										; if zero-size block, return null pointer
	jz	> calloc_exit
	call	%_____malloc							; esi->alloc'ed block's header

	test esi,esi										; error?
	jz	> calloc_exit 							; yep

	mov	ecx,[esi]										; ecx = size of block, including header
	sub	ecx,16											; ecx = size of block's data area
	lea	edi,[esi+16]								; edi -> block's data area
	shr	ecx,2												; ecx = # of dwords to zero (block size can
	;																; only be a multiple of 16)
	call %_ZeroMem0									; fill with zeros
calloc_exit:
	ret


; ********************
; *****  malloc  *****  allocate a chunk of storage
; ********************

; *****  malloc  *****  C entry point  and  XBASIC entry point

; in: size = number of bytes to allocate
; out: eax -> allocated block, or NULL if none available

; Also returns NULL if requested to allocate zero bytes.

malloc:
_malloc:
__malloc:
_Xmalloc:
___malloc FRAME size

	cmp	d[size],0										; trying to malloc zero bytes?
	jz	> cmalloc0									; then quit wasting my time

	push ebx,esi,edi

minited:
	mov	esi,[size]
	call	%_____malloc							; esi -> new block's header, or NULL if none
	mov	eax,esi

	pop	edi,esi,ebx

	test eax,eax
	jz	> cmalloc0
	add	eax,16
cmalloc0:
	ret
	ENDF


; *****  malloc  *****  internal entry point

; in:	esi = size of block to allocate
; out:	esi -> data area of allocated block

; destroys: edi

; Returns null pointer if error.

%____malloc:
	USES eax,ebx,ecx,edx
	call	%_____malloc
	test esi,esi										; error?
	jz >														; yes
	add	esi,16											; no: esi -> data area of allocated block
	:
	ret
	ENDU


; ##########################################
; ##  *****  malloc  *****  CORE ROUTINE  ##
; ##########################################

;  in: esi = size of block to allocate
; out: esi -> HEADER of allocated block (not data area)
;
; destroys: eax, ebx, ecx, edx, edi
;
; Optimized, commented, and rewritten for clarity by Greg Heller April 2006
;
%_____malloc FRAME								; standard stack frame

	local mem_size                  ;	Size of block to allocate = original esi
	local total_size                ;	Total size of block to allocate, including header
	local chunk_addr                ;	Address of big-enough chunk (when searching thru big-chunk list)
	local best_size                 ;	Size of best-fitting big chunk found so far

	test esi,esi	         					; request for zero-length block?
	jz >	malloc_exit        				; if so, return null pointer
	mov	[mem_size],esi	       			; save requested size

	test d[%initialized],-1      		; make sure _DllMain has been called
	jnz > malloop
		push esi
		call %_XxxXstInitialize				; simulates DllMain
		pop esi
;
; Down below there is a table called %pointers.  This table is created with all values equal to zero,
; meaning that they point to nothing.  When a chunk of memory is needed of a certain size, we look
; at this table to see if the appropriate pointer number is pointing at anything (meaning it has a
; non-zero value).
;
; get pointer number for specified size
malloop:
	dec esi
	mov ebx,esi											; ebx = size - 1
	shr	esi,4												; esi = (size - 1) / 16 = pointer #
	mov	edx,esi
	shl	edx,4												; edx = size needed - 16
	add	edx,0x20										; edx = total size needed, including header
	mov	[total_size],edx						; save for later
	and	ebx,0xFFFFFF00							; ebx = 0 if size <= 256
	jnz	> big_chunk									; size is > 256; special large chunk required

; size <= 256
	mov	ebx,[%pointers+esi*4] 			; ebx -> 1st chunk this size
	test ebx,ebx										; any chunks this size?
	jz	> not_exact									; nope

; CASE A: Found free chunk of desired size
	mov	eax,[ebx+8]	         				; eax -> size-upstream header
	mov	ecx,[mem_size]	         		; ecx = size requested
	mov edx,0x00000001							; one byte per element
	bts d[ebx+4],31	         				; mark as allocated
	jnc	> blockOk0	         				; previously allocated
		call	%_eeeAllocation					; block allocated
		xor	esi,esi										; return null pointer
		retn													; we hope to never get here

blockOk0:
	mov	[ebx+8],ecx									; size of block = requested size
	mov	[ebx+12],edx								; write info word into header
	mov	[%pointers+esi*4],eax 			; update pointer to unlink this chunk
	test eax,eax										; size uplink = 0?
	jz	> skip_zip									; yes -- no further chunks
	mov	d[eax+12],0 								; zero size downlink of next chunk

skip_zip:
	mov	esi,ebx											; return pointer to header of new block in esi
malloc_exit:
	ret

; no exact-size chunks are free
not_exact:
	mov	ebx,esi
	inc	ebx													; ebx = next pointer #
not_yet:
	mov	eax,[%pointers+ebx*4] 			; eax =  to block of next higher size
	test eax,eax										; is there a pointer?
	jnz >	got_chunk									; yes, go allocate it
	inc	ebx													; nope, point to next size up
	cmp	ebx,16											; are we past the end of the table?
	jbe	not_yet											; no, try next size up, else fall through

; CASE B:  No free chunks of desired size or larger exist, get more memory
; compute new break address and uplink to new top header
none_big_enough:
	;		_##DYNOZ	= base of new pages to alloc
	; 	0x100000	=	1MB (new area size)
 	invoke	_VirtualAlloc@16, [_##DYNOZ], 0x100000, MEM_COMMIT, PAGE_READWRITE
	test eax,eax										; error check
	jnz	> breaker.good							; if error, fall through
		call	%_eeeErrorNT						; process Win32 error
		retn													; better not get here !!!

; got another 1mb memory from the OS
breaker.good:
	add	eax,0x100000								; eax = address after top (add 1MB)
	mov	[_##DYNOZ],eax							; ##DYNOZ = ditto
	sub	eax,0x0010									; eax = new top header address
	mov	[_##DYNOX],eax							; ##DYNOX = ditto
	mov	d[eax+0],0									; addr-uplink(new-top) = 0
	mov d[eax+4],0x80100000					; addr-downlink(new-top)=1MB
	mov	d[eax+8],0									; size-uplink(new-top) = 0 (last header)
	mov d[eax+12],0x0001						; size-down(new-top)=bytes/ele
	mov	esi,eax											; esi = new top header address
	sub	esi,0x100000								; esi = old top header address
	mov d[esi],0x100000							; addr-uplink(old-top) = 1MB

; free previous top header
	call	%____Hfree								; free old top header (probable merge)
	mov	esi,[mem_size]							; esi = original requested size
	jmp	malloop											; we have more memory now, so try again

; CASE C:  No free chunk of perfect size, but found larger free chunk
; entry:  eax = pointer contents = address of 1st chunk in this free list
;	  [total_size] = size needed, including header
;	  ebx = pointer # (pointer of size-list having chunk to use)

; unlink this header from size links
got_chunk:
	mov	esi,[eax+8]									; esi = size-uplink to size-upstream chunk
	mov	[%pointers+ebx*4],esi				; point size pointer at size-upstream chunk
	test	esi,esi										; if uplink = 0, then no size-upstream chunk
	jz	> whole_or_part
		mov	d[esi+12],0								; mark size-upstream header as new 1st chunk

; decide whether to use this entire free chunk, or only a lower portion
whole_or_part:
	mov	edx,[mem_size]							; edx = requested size
	mov esi,0x00000001							; esi = 1 byte per element
	bts d[eax+4],31									; mark as allocated
	jnc	> blockOk1									; previously allocated
		call	%_eeeAllocation					; block allocated
		xor	esi,esi										; return null pointer
		retn

blockOk1:
	mov	[eax+8],edx									; header word2 = requested size
	mov	[eax+12],esi								; mark this header as in use
	mov	esi,[eax]										; esi = size of chunk including header
	sub	esi,[total_size]						; esi = size - needed size = new free size
	cmp	esi,0x20										; still room for header and 16-byte data block?
	jb > no_new											; nope, allocate entire chunk

; address link a new free header above the chunk being allocated
	mov	edi,[total_size]						; edi = size needed (including header)
	lea	edx,[eax+edi]								; edx -> new free chunk
	mov	[edx],esi										; put address up-link in new free chunk
	mov	[edx+4],edi									; put address down-link in new free chunk
	mov	[eax],edi										; put address up-link in this chunk
	lea	edi,[edx+esi]								; edi -> header above new free chunk
	bts	esi,31											; esi = addr-down-link + allocated bit
	mov	[edi+4],esi									; put address down-link in header above new free
	btr	esi,31											; restore esi

; compute pointer # to size-link the new free header
	sub	esi,17											; esi = size of new free chunk's data area - 1
	mov	edi,esi
	shr	esi,4												; esi = pointer # for small chunk
	and	edi,0xFFFFFF00							; edi = 0 if new free chunk size <= 256 bytes
	jz	> small_chunk 							; if edi = 0, a small chunk is adequate
	mov	esi,16											; esi = pointer # for large chunk

; size-link new free block to pointer and next size up-link header
small_chunk:
	mov	edi,[%pointers+esi*4] 			; edi -> 1st header of this size
	mov	[%pointers+esi*4],edx 			; update size pointer to new free chunk
	mov	[edx+8],edi									; put size-uplink into new free header
	mov	d[edx+12],0 								; put size down-link into new free header
	test edi,edi										; if size-uplink = 0, no size-upstream
	jz	> no_new
	mov	[edi+12],edx								; put size down-link into next up-link header
no_new:
	mov	esi,eax											; esi -> allocated header
	ret

; malloc executes the following code when the required size > 256 bytes.
; It attempts to find a free chunk 1.125 to 1.375 times the minimum
; size by searching through the size-linked big chunks

; entry:  edx = required size, including header

big_chunk:
	mov d[chunk_addr],0							; no big-enough chunk found yet
	mov d[best_size],0							; size of best-fitting chunk = 0
	mov	esi,[%pointers+0x40] 				; esi -> first big-chunk header
	mov	ebx,edx
	shr	ebx,3												; ebx = 1/8 minimum chunk size
	mov	ecx,edx
	shr	ecx,2												; ecx = 1/4 minimum chunk size
	add	edx,ebx											; edx = 1.125 * mimimum chunk size
	lea	ebx,[edx+ecx]								; ebx = 1.375 * minimum chunk size
	and	edx,0xFFFFFFF0							; edx = align16(new-min-chunk-size)
	and	ebx,0xFFFFFFF0							; ebx = align16(new-max-chunk-size)

; edx = min-perfect-chunk-size    ebx = max-perfect-chunk-size
bcloop:
	test esi,esi
	jz > no_perfect_fit							; if esi null pointer, not perfect fit found
	mov	ecx,[esi]										; ecx = address uplink = size of chunk
	cmp	ecx,edx											; excess size (chunk size - needed size) > 0?
	jae	 > big_enough 							; yes, chunk is big enough
	mov	esi,[esi+8]									; no, get next header upstream
	jmp	bcloop

; found big-enough chunk; use if in perfect range, else see if best so far
big_enough:
	cmp	ebx,ecx											; max-perfect-size - this-chunk-size
	jae	> perfect_fit 							; chunk size is between max and min: perfect
	cmp	d[chunk_addr],0 						; has a big-enough chunk already been found?
	jnz	> pick_best_fit 						; yes, see if new chunk better fit than old

; large enough chunk, but not perfect size
best_so_far:
	mov	[chunk_addr],esi						; save address of header of current chunk
	mov	[best_size],ecx							; save size of current chunk
	mov	esi,[esi+8]									; esi -> next chunk upstream
	jmp	bcloop

; chunk is perfect size: unlink this chunk from size-links
; esi -> header
perfect_fit:
	mov	edi,[esi+8]									; edi -> size-upstream header
	mov	ecx,0x0001									; ecx = system/user bit in info word
	bts d[esi+4],31									; mark as allocated
	jnc	> blockOk2									; previously allocated
		call	%_eeeAllocation					; block allocated
		xor	esi,esi										; return null pointer
		retn

blockOk2:
	mov	eax,[esi+12]								; eax -> size-downstream header
	test edi,edi										; is there a header size-upstream?
	jz	> no_up											; nope
	mov	[esi+12],ecx								; mark this header allocated
	test eax,eax										; is there a header size-downstream?
	jz	> no_down_yes_up 						; nope

; valid header size-downstream, valid header size-upstream
yes_down_yes_up:
	mov	ebx,[mem_size]							; ebx = requested size
	mov	[eax+8],edi									; SD header -> SU header
	mov	[edi+12],eax								; SU header -> SD header
	mov	[esi+8],ebx									; this header word2 = requested size
	ret

; no valid header size-downstream, valid header size_upstream
no_down_yes_up:
	mov	eax,[mem_size]							; eax = requested size
	mov	[%pointers+0x40],edi 				; pointer -> size-upstream header
	mov	d[edi+12],0 								; mark size-upstream header as 1st in size-links
	mov	[esi+8],eax									; this header word2 = requested size
	ret

; no valid header size-upstream
no_up:
	mov	[esi+12],ecx								; mark this header allocated
	test eax,eax										; is there a header size-downstream?
	jz	> no_down_no_up 						; nope

; valid header size-downstream, no valid header size_upstream
yes_down_no_up:
	mov	ebx,[mem_size]							; ebx = size requested
	mov	d[eax+8],0 									; downstream header is last in size-links
	mov	[esi+8],ebx									; this header word2 = requested size
	ret

; no valid header size-downstream, no valid header size-upstream
no_down_no_up:
	mov	eax,[mem_size]							; eax = requested size
	mov	[%pointers+0x40],edi 				; zero pointer (no big chunks left)
	mov	[esi+8],eax									; header word2 = requested size
	ret

; chunk bigger than optimum; see if better fit (smaller) than previous best
pick_best_fit:
	cmp	ecx,[best_size]							; this-size - prev-best-size
	jb	best_so_far 								; if this size < prev best, we have new best
	mov	esi,[esi+8]									; esi -> next size-upstream header
	jmp	bcloop

; no perfect big chunk exists; maybe no big-enough big chunks exist
no_perfect_fit:
	mov	edi,[chunk_addr]						; edi -> best big-enough chunk found
	test edi,edi										; was any chunk found at all?
	jz	none_big_enough 						; nope
	mov	ecx,[edi+12]								; ecx -> size-downstream header

; a big-enough chunk was found, though none in perfect size range
	mov	ebx,[edi+8]									; ebx -> size-upstream header
	jecxz	> first_biggie 						; if ecx = 0, then found 1st in big-chunk list

; update size-links in size-downstream/upstream headers to unlink this chunk
; unlink this header
not_first_biggie:
	mov	[ecx+8],ebx									; link SD header to SU header
	test	ebx,ebx										; if ebx = 0, no size-upstream chunks exist
	jz	> no_upsize
		mov	[ebx+12],ecx							; link SU header to SD header
no_upsize:
	mov	eax,0x0001									; one byte per element
	bts d[edi+4],31									; mark as allocated
	jnc	> blockOk3									; previously allocated
		call	%_eeeAllocation					; block allocated
		xor	esi,esi										; return null pointer
		retn

blockOk3:
	mov	[edi+8],ebx									; size-uplink = 0
	mov	[edi+12],eax								; one byte per element
	jmp	 chop_too_biggie 						; break big chunk: allocate lower,
																	; free higher

; best-fit chunk is 1st chunk:  update pointer and header to unlink it
first_biggie:
	mov eax,0x0001									; 1 byte per element
	bts d[edi+4],31									; mark as allocated
	jnc	> blockOk4									; previously allocated
		call	%_eeeAllocation					; block allocated
		xor	esi,esi										; return null pointer
		retn

blockOk4:
	mov d[edi+8],0									; size-uplink = 0
	mov	[edi+12],eax								; 1 byte per element
	mov	[%pointers+0x40],ebx 				;	big-chunk pointer = size-upstream address
	test ebx,ebx										;	is there a size-upstream block?
	jz	> chop_too_biggie 					;	no, skip ahead to chopping routine
	mov d[ebx+12],0									;	zero size-downlink of next chunk (new 1st)

; divide too-big chunk in two, allocate low part, free high part
; entry:  edx = minimum perfect chunk size
;	  edi      -> this chunk
;	  best_size = size of this chunk

chop_too_biggie:
	lea	esi,[edi+edx]								;	esi -> new free chunk
	mov	[esi+4],edx									;	put address downlink in new free chunk
	mov	eax,[best_size]							;	eax = size of chunk to break up
	mov	ebx,eax											;	save for later
	sub	eax,edx											;	eax = size of new free chunk
	mov	[esi],eax										;	put address up-link in new free chunk
	mov	[edi],edx										;	put address up-link in this chunk
	add	ebx,edi											;	ebx -> header above new free chunk
	bts	eax,31											;	eax = addr-down-link + allocated bit
	mov	[ebx+4],eax									; put address downlink in header above new free
	btr	eax,31											; restore eax

; compute pointer # to size-link the new free header
	sub	eax,17											; eax = size of new free chunk - 1
	mov	ecx,eax
	shr	eax,4												; eax = pointer # for small chunk
	and	ecx,0xFFFFFF00							; free chunk <= 256 bytes?
	jz	> mini_chunk 								; yes, a small chunk is adequate
	mov	eax,16											; eax = pointer # for big chunk

; size-link new free block to pointer and next size up-link header
mini_chunk:
	mov	ebx,[%pointers+eax*4] 			; ebx -> first header of this size
	mov	[%pointers+eax*4],esi 			; update pointer to point to new free chunk
	mov	[esi+8],ebx									; put size-upstream address into new header
	mov d[esi+12],0									; zero size-downstream in new free header
	test ebx,ebx										; is there an upstream header?
	jz	> up_nope										; nope
	mov	[ebx+12],esi								; put size-downlink into size-uplink header
up_nope:
	mov	eax,[mem_size]							; eax = requested size
	mov	esi,edi											; esi -> allocated header
	mov	[esi+8],eax									; header word2 = requested size
	ret
	ENDF

; ******************
; *****  free  *****  frees a chunk of memory
; ******************

; *****  free  *****  C entry point  and  XBASIC entry point

;  in: address -> block to free
; out: random value in eax

free:
_free:
__free:
_Xfree:
___free FRAME address

	cmp d[address],0								; we were given a null pointer?
	jz	> cfree0										; then don't try to free anything
	push ebx,esi,edi
	mov	esi,[address]								; esi -> data block to free
	sub	esi,16											; esi -> its header
	mov d[ebp-4],-1									; indicate that %_____free is being called from C
	call	%_____free
	pop	edi,esi,ebx
cfree0:
	ret
	ENDF


; ***********************
; *****  %____free  *****  internal entry point to %_____free
; ***********************

;  in: esi = data address of chunk to free
; out: esi = 0 if error or tried to free null pointer, != 0 if ok

; destroys: edi

; Allocates frame for %_____free and puts a zero at [ebp-4] to indicate
; that %_____free was not called (directly) from C.

%____free:
	test esi,esi										; trying to free null pointer?
	jz	> fret											; yes: skip the free
	push	ebp
	mov	ebp,esp
	sub	esp,8

	push eax,ebx,ecx,edx

	sub	esi,16
	mov d[ebp-4],0
	call	%_____free

	pop	edx,ecx,ebx,eax

	leave
fret:
	ret


; ************************
; *****  %____Hfree  *****  internal entry point to %_____free
; ************************

;  in: esi = header address of chunk to free
; out: esi = 0 if error or tried to free null pointer, != 0 if ok

; destroys: eax, ebx, ecx, edx, edi

; Allocates frame for %_____free and puts a zero at [ebp-4] to indicate
; that %_____free was not called (directly) from C.

; %____Hfree is exactly the same as %____free except that on entry,
; esi -> the header of the block to free, not the block's data area.

%____Hfree:
	push	ebp
	mov	ebp,esp
	sub	esp,8
	mov d[ebp-4],0
	call	%_____free
	leave
	ret


; *****  free  *****  CORE ROUTINE  *****

;  in: esi = header address of chunk to free
;      ebp -> top of 8-byte local frame, which must already have been allocated
;      [ebp-4] = -1 if called from C entry point, 0 if not
; out: esi = 0 if error or tried to free null pointer, != 0 if ok

; destroys: eax, ebx, ecx, edx, edi

; Local variables:
;	IMPORTANT: assumes that caller has already allocated 8-byte frame
;	-4	-1 if called from C entry point, 0 if not
;	-8	buffer for short error message to print

%_____free:
	test esi,esi										;	null pointer?
	jz	> free_exit									;	if so, nothing to free
	mov	eax,[esi+4]									;	eax = offset to L header	; 05/01/93
	test eax,eax										; eax = 0 if literal string	; 05/01/93
	jz	> free_exit									;	if literal string, don't free	; 05/01/93
	btr	eax,31											;	clear allocated bit
	mov	[esi+4],eax									;	mark block free
	jnc	> serious										;	block already free

; NOTE: I'm skipping the test code in the original (for now, anyway)
	mov	ebx,'x'
	cmp	[_##DYNO],esi								;	is addr(1st header) > addr(request)?
	ja	> serious										;	if so, it's a serious error
	inc	ebx													;	ebx = 'y'
	cmp	[_##DYNOX],esi							; is addr(last header) < addr(request)?
	jb	> serious										; if so, it's a serious error

	mov	eax,[esi]										; eax = offset to H header
	add	eax,esi											; eax -> H header
	mov	ecx,[esi+4]									; ecx = offset to L header
	btr	ecx,31											; assure positive offset
	neg	ecx
	add	ecx,esi											;	ecx -> L header
	inc	ebx													;	ebx = 'z'
	mov	ebx,[eax+12]								;	ebx -> H's info word
	jmp	 ok_to_free

; attempt to free an already free chunk reveals a serious allocation bug!
serious:
	cmp	d[ebp-4],0 									; non-zero if called from a C function
	jnz	> Csucks										; if C function, go complain on stderr
	xor	esi,esi											; return null pointer because of error
free_exit:
	ret

; report C functions trying to free garbage
; entry: ebx = 'x', 'y', or 'z', depending on where error was detected
Csucks:
	call	%_eeeAllocation						; block allocated
	xor	esi,esi											; return null pointer because of error
	ret

; okay to free M chunk; merge with H and/or L chunks if they're free
; entry: eax -> H header
;	 ebx -> H's info word
;	 ecx -> L header
ok_to_free:
	mov	edx,[ecx+12]								; edx = L's info word
	or	ebx,ebx											; is H info word = 0?	   (necessary !!!)
	bt d[eax+4],31									; is H allocated?
	jc	> hi_not										; yes
	;																; no: H info word (ebx) is really size-downlink

; H chunk is free; unlink it, and then check L chunk
	mov	edi,[eax+8]									; edi = size-uplink of H
	jz	> down_pointer 							; skip ahead if H's size-downlink null pointer
	mov	d[eax+8],0	 								; size-uplink(H) = 0, i.e. mark unlinked
	mov	[ebx+8],edi									; size-uplink(SD(H)) -> SU(H)
	test edi,edi										; is SU(H) a null pointer?
	jz	> q_lower										; yes, we have no size-uplink
	mov	[edi+12],ebx								; size-downlink(SU(H)) -> SD(H)
	jmp	> q_lower										; see if lower is free

; the H chunk is 1st in size-links (unlink from pointer on downstream side)

down_pointer:
	mov	d[eax+8],0 									; size-uplink(H) = 0, i.e. mark unlinked
	mov	ebx,[eax]										; ebx = size(H) = addr-uplink(H)
	sub	ebx,17											; ebx = size - 17 (data size - 1)
	shr	ebx,4												; ebx = (size-1) / 16 = pointer #
	cmp	ebx,16											; pointer # is beyond big-chunk pointer?
	jbe	> unlink_small  						; no, ebx is ok
	mov	ebx,16											; ebx = big-chunk pointer #

unlink_small:
	mov	[%pointers+ebx*4],edi 			; pointer now -> SU(H)
	test edi,edi										; is SU(H) a null pointer?
	jz	> q_lower										; skip if null pointer, i.e. no SU(H)
	mov	d[edi+12],0 								; mark SU(H) as 1st in size-links

q_lower:
	mov	edi,[ecx+12]								;	edi = SD(L)
	bt d[ecx+4],31									;	is L allocated?
	jc	> hi_free_lo_not						;	yes, so don't combine with M


; H is free, L is free: unlink L from size-links of chunks downstream
; and upstream from L
; ecx -> L		esi -> M		ebx = trash
; eax -> H		edx -> SD(L)		edi -> SU(L)
hi_free_lo_free:
	mov	edx,[ecx+12]								; edx -> SD(L)  [is this necessary?]
	mov	edi,[ecx+8]									; edi -> SU(L)  [is this necessary?]
	test edx,edx										; is SD(L) null pointer?  [is this necessary?]
	jz	> pointer_down 							; if no SD(L), L is first chunk its size
	mov	d[ecx+8],0 									; SU(L) = 0, i.e. unlinked
	mov	[edx+8],edi									; SU(SD(L)) -> SU(L)
	test edi,edi										; is SU(L) a null pointer?
	jz	> do_addr										; if SU(L) is null, no SU(L)
	mov	[edi+12],edx								; SD(SU(L)) -> SD(L)
	jmp	 do_addr

; the L chunk is 1st in size-links (unlink from pointer on downstream side)
pointer_down:
	mov	d[ecx+8],0 									; SU(L) = 0 (unlinked)
	mov	ebx,[ecx]										; ebx = size(L) = addr-uplink(L)
	sub	ebx,17											; ebx = size - 17 = data size - 1
	shr	ebx,4												; ebx = (size-1) / 16 = pointer #
	cmp	ebx,16											; pointer # is beyond big-chunk pointer?
	jbe	> small_unlink 							; no, ebx is ok
	mov	ebx,16											; ebx = big-chunk pointer #

small_unlink:
	mov	[%pointers+ebx*4],edi 			; pointer header past L to SU(L)
	test edi,edi										; is SU(L) a null pointer?
	jz	> do_addr										; if so, there is no SU(L)
	mov d[edi+12],0									; mark SU(L) as 1st in size-links

; update address links in L and XH to abolish M and H (merge L, M, H into L)
do_addr:
	mov	edi,[eax]										; edi = size(H)
	mov	ebx,eax
	sub	ebx,ecx											; ebx = addr(H) - addr(L) = size(L) + size(M)
	jns	> duh1											; DEBUG
	call	%_eeeAllocation						; block allocated

duh1:				  										; DEBUG
	add	ebx,edi											; ebx = size(L) + size(M) + size(H)
	mov	[ecx],ebx										; addr-uplink(L) = size(L) + size(M) + size(H)
	bts	ebx,31											; XH is allocated
	mov	[eax+edi+4],ebx							; addr-downlink(XH) = new-size(L)
	btr	ebx,31											; ebx is down distance

; link new L into size-links
	mov	esi,ecx											; esi -> chunk to enter in size-links
	jmp	hi_not_lo_not


; the H chunk (above) is free; the L chunk (below) is not free
hi_free_lo_not:
	mov	d[esi+12],0 								; mark this header free
	mov	edi,[eax]										; edi = size(H)
	mov	ebx,eax
	sub	ebx,esi											; ebx = addr(H) - addr(M) = size(M)
	jns	> duh2											; DEBUG
	call	%_eeeAllocation						; block allocated

duh2:															; DEBUG
	add	ebx,edi											; ebx = size(M) + size(H)
	mov	[esi],ebx										; addr-uplink(M) = size(M) + size(H)

; go link new L into size-links
	bts	ebx,31											; XH is allocated
	mov	[eax+edi+4],ebx							; addr-downlink(XH) = new-size(L)
	btr	ebx,31											; ebx is down distance
	jmp	 hi_not_lo_not 							; addr-uplink and addr-downlink not free now

; the H chunk (above) is not free (check the L chunk)
hi_not:
	bt d[ecx+4],31									; is L header allocated?
	jc	> hi_not_lo_not							; yes

; the H chunk is not free, the L chunk is free
; unlink L from size-links of chunks downstream and upstream from L
hi_not_lo_free:
	mov	d[esi+12],0 								; mark this header free
	mov	edi,[ecx+8]									; edi = SU(L)
	test edx,edx										; is SD(L) a null pointer?  [is this necessary?]
	jz	> pointer_case							; yes, L is 1st chunk its size
	mov	[edx+8],edi									; SU(SD(L)) = SU(L)
	test edi,edi										; is SU(L) a null pointer?
	jz	> addr_do										; yes, we have no SU(L)
	mov	[edi+12],edx								; SD(SU(L)) = SD(L)
	jmp	 addr_do

; the L chunk is 1st in size-links (unlink from pointer on downstream side)

pointer_case:
	mov	ebx,[ecx]										; ebx = size(L) = addr-uplink(L)
	sub	ebx,17
	shr	ebx,4												; ebx = (size-1) / 16 = pointer #
	cmp	ebx,16											; pointer # is beyond big-chunk pointer?
	jbe	> wimpy_unlink 							; no, ebx is ok
	mov	ebx,16											; ebx = big-chunk pointer #

wimpy_unlink:
	mov	[%pointers+ebx*4],edi 			; point header past L to size-uplink(L)
	test edi,edi										; is SU(L) null pointer?
	jz	> addr_do										; yes, we have no SU(L)
	mov	d[edi+12],0 								; mark SU(L) as 1st in size-links

; update address links in L to abolish M  (merge L, M, into L)
addr_do:
	mov	edi,eax
	sub	edi,ecx											; edi = addr(H) - addr(L) = new-size(L)
	jns	> duh3											; DEBUG
	call	%_eeeAllocation						; block allocated

duh3:															; DEBUG
	mov	[ecx],edi										; addr-uplink(L) = new-size(L)
	bts	edi,31											; mark H allocated
	mov	[eax+4],edi									; addr-downlink(H) = new-size(L)
	btr	edi,31											; restore edi
	mov	esi,ecx											; esi -> L (prepare to put L in size-links)

; the H chunk is not free, the L chunk is not free
hi_not_lo_not:
	mov	d[esi+12],0 								; mark this header free
	mov	ebx,[esi]										; ebx = size(M) = addr-uplink(M)
	sub	ebx,17
	shr	ebx,4												; ebx = (size-1) / 16 = pointer #
	cmp	ebx,16											; pointer # is beyond big-chunk pointer?
	jbe	> free_any									; no, ebx is ok
	mov	ebx,16											; ebx = big-chunk pointer #

free_any:
	mov	eax,[%pointers+ebx*4] 			; eax -> 1st header of this sie
	mov	[%pointers+ebx*4],esi 			; pointer -> this header
	mov	[esi+8],eax									; size-uplink(M) = size-uplink(pointer)
	test eax,eax										; was old pointer null?
	jz	> no_upstream 							; in that case, there's no upstream header
	mov	[eax+12],esi								; size-downlink(size-upstream) -> M

no_upstream:
	mov	d[esi+12],0 								; SD(M) = 0 (mark as 1st this size)
	ret

; #################
; #####  END  #####
; #################
