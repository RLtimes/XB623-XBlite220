; *************************************
; *****  Assign Composite String  *****  fills extra bytes with 0x20
; *************************************

.code

; edi = destination address	(address of Fixed String in composite)
; esi = source address		(address of Elastic String)
; ecx = number of bytes in composite string

; fixed strings do NOT have an extra 0x00 byte
; source must be 0x00 terminated

%_assignCompositeString.v:
	mov	edx, 0											; don't free source string after
	jmp	 acs_start

%_assignCompositeString.s:
	mov	edx, esi										; free source string after

acs_start:
	push	eax												; save eax ( )
	push	ebp												; framewalk support
	mov	ebp, esp										; framewalk support
	sub	esp, 64											; create local frame (workspace)

	mov [esp], edx									; save string to free after
	test edi, edi
	jz	> acs_done									; if destination address = 0, do nothing
	cmp	ecx, 0
	jbe	> acs_done									; if destination length <= 0, do nothing


	xor	ebx, ebx										; ebx = byte offset = 0 to start
	test	esi, esi
	jz	> acs_pad										; if source = "", just pad with spaces
	mov	edx, [esi-8]								; edx = source length
	test	edx, edx
	jz	> acs_pad										; if source = "", just pad with spaces

acs_copy:
	mov	al, [esi+ebx]								; read from source
	dec	edx													; edx = one less source byte left
	mov	[edi+ebx], al								; write to destination
	dec	ecx													; one less byte to copy
	inc	ebx													; offset to next byte
	test	ecx, ecx
	jz	> acs_done									; destination filled
	test	edx, edx
	jnz	 acs_copy										; if source not depleated, copy next byte

acs_pad:
	mov	eax, 0x20										; eax = space character (padding)
	mov	[edi+ebx], al								; write space to destination
	inc	ebx													; offset to next byte
	dec	ecx													; one less byte to write
	jnz	 acs_pad										; write more until count = 0

acs_done:
	mov	esi, [esp]									; string to free
	test	esi, esi
	jnz	> asc_zip										; none to free
	call	%____free									; free string

asc_zip:
	leave
	pop	eax													; restore eax ( )
	ret															; return to caller

; #################
; #####  END  #####
; #################
