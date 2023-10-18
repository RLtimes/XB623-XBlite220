
; ########################
; #####  xblibc.asm  #####  Composite String routines
; ########################

.code

; *************************************
; *****  Assign Composite String  *****  fills extra bytes with 0x00
; *************************************

; edi = destination address	(address of Fixed String in composite)
; esi = source address		(address of Elastic String)
; ecx = number of bytes in fixed string

; fixed Strings do NOT have an extra NULL byte
; source must be NULL terminated

%_assignCompositeStringlet.v:
	mov	edx, 0											; don't free source string after
	jmp	 zacs_start

%_assignCompositeStringlet.s:
	mov	edx, esi										; free source string after

zacs_start:
	push	eax												; save eax ( )
	push	ebp												; framewalk support
	mov	ebp, esp										; framewalk support
	sub	esp, 64											; create local frame (workspace)

	mov [esp], edx									; save string to free after
	test	edi, edi
	jz	> zacs_done									; if destination address = 0, do nothing
	cmp	ecx, 0
	jbe	> zacs_done									; if destination length <= 0, do nothing

	xor	ebx, ebx										; ebx = byte offset = 0 to start
	test	esi, esi
	jz	> zacs_pad									; if source = "", just pad with spaces
	mov	edx, [esi-8]								; edx = source length
	test	edx, edx
	jz	> zacs_pad									; if source = "", just pad with spaces

zacs_copy:
	mov	al, [esi+ebx]								; read from source
	dec	edx													; edx = one less source byte left
	mov	[edi+ebx], al								; write to destination
	dec	ecx													; one less byte to copy
	inc	ebx													; offset to next byte
	test	ecx, ecx
	jz	> zacs_done									; destination filled
	test	edx, edx
	jnz	 zacs_copy									; if source not depleated, copy next byte

zacs_pad:
	xor	eax,eax											; eax = 0x00 byte (padding)
	mov	[edi+ebx], al								; write space to destination
	inc	ebx													; offset to next byte
	dec	ecx													; one less byte to write
	jnz	 zacs_pad										; write more until count = 0

zacs_done:
	mov	esi, [esp]									; string to free
	test	esi, esi
	jnz	> zasc_zip									; none to free
	call	%____free									; free string

zasc_zip:
	leave
	pop	eax													; restore eax ( )
	ret

; #################
; #####  END  #####
; #################
