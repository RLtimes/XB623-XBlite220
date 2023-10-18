
; #########################
; #####  xblibs2.asm  #####
; #########################

.code

; XstFindMemoryMatch (addrBufferStart, addrBufferPast, addrString, minMatch)

; input
; arg1   = addr of buffer to search - first byte
; arg2   = addr of buffer to search - byte past end
; arg3   = addr of string to search for - first byte
; arg4   = minimum number of bytes that must match
; arg5   = maximum number of bytes that may match (length of match string)

; output
; arg1   = addr of buffer to search - first byte that matched
; arg2   = unchanged
; arg3   = unchanged
; arg4   = # of characters that matched
; arg5   = unchanged
; return = addr of buffer to search - first byte that matched

; arg1   = ebp +  8
; arg2   = ebp + 12
; arg3   = ebp + 16
; arg4   = ebp + 20
; arg5   = ebp + 24

_XstFindMemoryMatch@20:
	push	ebp												; standard function entry
	mov	ebp,esp											; ditto
	sub	esp,16											; 16 byte frame - local variables

	push	esi												; save esi
	push	edi												; save edi
	push	ebx												; save ebx
	push	ecx												; save ecx

	mov	edi,[ebp+8]									; edi = addr of first byte of search buffer
	mov	edx,[ebp+12]								; edx = addr of byte past end of search buffer
	mov	esi,[ebp+16]								; ebx = addr of 1st byte of match buffer
	mov	ebx,[ebp+20]								; esi = minimum # of bytes that must match
	mov	eax,[ebp+24]								; eax = maximum # of bytes that may match

	test	edi,edi										; buffer address = 0 ???
	jz	> fsnomatch									; start address = 0 is error or empty string

	test	edx,edx										; past address = 0 ???
	jz	> fsnomatch									; past address = 0 is an error

	test	esi,esi										; match buffer address = 0 ???
	jz	> fsnomatch									; match buffer address = 0 is error or empty

	test	ebx,ebx										; min # of bytes that must match = 0 ???
	jz	> fsnomatch									; min # of bytes = 0 is error

	test	eax,eax										; max # of bytes that can match
	jle	> fsnomatch									; max # of bytes <= 0 is error

	mov	ecx,edx											; ecx = addr past last byte of buffer to search
	sub	ecx,edi											; ecx = overall size of buffer to search
	jbe	> fsnomatch									; search zero or negative number of bytes ???

	sub	ecx,ebx											; ecx = maximum number of bytes to search
	jb	> fsnomatch									; search through a negative number of bytes ???
	inc	ecx													; ecx = number of bytes to search
	movzx	eax,b[esi]								; 1st byte of string to match

; eax = byte to match
; edi = addr of buffer to search
; ecx = how many bytes to search through
; edx = addr of byte past end of buffer to search through
xfsloop:
	cld															; search forward through memory
	repne														; repeat until byte in buffer = byte in eax
	scasb														; search for match with byte in eax

	jne	> fsnomatch									; no match to byte in eax

	push	eax												; save 1st search byte
	push	ecx												; save number of bytes left to search through
	push	esi												; save addr of 1st byte of match string
	push	edi												; save addr of byte after match

; found 1st byte of match, now see how many subsequent bytes match
	dec	edi													; edi = addr of 1st byte in buffer of match
	mov	ecx,edx											; ecx = addr of byte past end of search buffer
	sub	ecx,edi											; ecx = # of bytes in buffer after match byte

	mov	eax,[ebp+24]								; eax = max # of bytes to match
	cmp	eax,ecx											; eax < ecx ???
	jae >	xfscmp										; no, ecx is okay
	mov	ecx,eax											; ecx is now okay = max # of bytes to match

xfscmp:
	xor	eax,eax											; z flag = true = 1
	repe														; repeat until bytes don't match
	cmpsb														; see how many bytes match (at least 1)

	jnz	> xfsmm											; found mismatch
	inc	esi													; make compatible with mismatch case
	inc	edi													; make compatible with mismatch case

xfsmm:
	mov	eax,edi											; eax = addr of byte past match
	sub	eax,[esp]										; eax = # of bytes that match - 1
	cmp	eax,ebx											; was # of bytes that matched >= required ???
	jae	> xfsm											; yes, so we have a match

; match was too short - continue search where it left off
	pop	edi													; edi = addr of byte after match
	pop	esi													; esi = addr of 1st byte of match string
	pop	ecx													; ecx = # of bytes left to search through
	pop	eax													; eax = byte to search for - 1st byte in match string
	jmp	 xfsloop										; continue search for long enough match

; found a sufficiently long match - eax = match length = return value
xfsm:
	pop	edi													; edi = addr of 1st byte of match + 1
	dec	edi													; edi = addr of 1st byte of match
	add	esp,12											; remove pushed values esi,ecx,eax from stack
	mov	[ebp+8],edi									; arg1 = addr of 1st byte of match in buffer
	mov	[ebp+20],eax								; arg4 = match length

; restore registers
xfs_done:
	pop	ecx													; restore ecx
	pop	ebx													; restore ebx
	pop	edi													; restore edi
	pop	esi													; restore esi

	leave														; restore frame pointer
	ret	20													; remove 20 bytes of arguments - STDCALL

fsnomatch:
	xor	eax,eax											; eax = 0 = no match
	jmp	 xfs_done


; #################
; #####  END  #####
; #################
