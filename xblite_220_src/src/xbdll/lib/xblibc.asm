
; ########################
; #####  xblibc.asm  #####  Composite String routines
; ########################

.code

; *******************************
; *****  %_AssignComposite  *****  copies a composite
; *******************************

; in:	esi -> source address
;	edi -> destination address
;	ecx = number of bytes to copy

; out:	nothing

; destroys: ebx, ecx, edx, esi, edi  (must not destroy eax)

; Guaranteed to not copy any extra bytes in addition to the number
; of bytes requested.  If destination address is null, does nothing.
; If source address is null, zeros destination.

%_AssignComposite:
%_assignComposite:
assignComposite:
	push	eax												; save eax  ( )
	cld
	test edi,edi										;	null destination?
	jz	> ac_done										;	yes: nothing to do
	test esi,esi										;	null source?
	jz	> ac_zero										;	yes: zero destination

	mov	eax,esi											;	eax = source address
	or	eax,edi											;	ready for alignment check
	test	eax,1											;	copy one byte at a time?
	jnz	> copy_bytes 								;	yes
	test	eax,2											;	copy one word at a time?
	jnz	> copy_words 								;	yes

copy_dwords:											; copy a dword at a time
	mov	ebx,ecx											; save # of bytes to copy
	shr	ecx,2												; ecx = # of dwords to copy
	rep movsd												; copy them!
	test	ebx,2											; an odd word left to copy?
	jz	> dw_odd_byte 							; no
	movsw														; yes: copy it

dw_odd_byte:
	test	ebx,1											; an odd byte left to copy?
	jz	> ac_done										; no

copy_odd_byte:
	movsb														; yes: copy it
ac_done:
	pop	eax													; restore entry eax ( )
	ret

copy_words:												;	copy a word at a time
	mov	ebx,ecx											;	save # of bytes to copy
	shr	ecx,1												;	ecx = # of words to copy
	rep
	movsw														;	copy them!
	test	ebx,1											;	an odd byte left to copy?
	jnz	copy_odd_byte								; yes: copy it
	pop	eax													; restore eax ( )
	ret															; no: all done

copy_bytes:												; copy a byte at a time
	rep movsb												; copy them!
	pop	eax													; restore eax ( )
	ret

ac_zero:													; zero destination
	xor	eax,eax											; eax = 0, the better to clear memory with
	mov	ebx,esi											; ebx = source address
	or	ebx,edi											; ready for alignment check
	test	ebx,1											; zero one byte at a time?
	jnz	> zero_bytes 								; yes
	test	ebx,2											; zero one word at a time?
	jnz	> zero_words 								; yes

zero_dwords:											; zero a dword at a time
	mov	edx,ecx											; save number of bytes to zero
	shr	ecx,2												; ecx = # of dwords to zero
	call %_ZeroMem0									; zero them!
	test	edx,2											; an odd word left over?
	jz	> zd_odd_byte 							; no
	stosw														; yes: zero it

zd_odd_byte:
	test	edx,1											; an odd byte left over?
	jz	> zc_done										; no: all done

zero_odd_byte:
	stosb														; yes: zero it

zc_done:
	pop	eax													; restore eax ( )
	ret

zero_words:												; zero a word at a time
	mov	edx,ecx											; save number of bytes to zero
	shr	ecx,1												; ecx = # of words to zero
	rep stosw												; zero them!
	test	edx,1											; an odd byte left over
	jnz	zero_odd_byte								; yes: zero it
	pop	eax													; restore eax ( )
	ret															; no: all done

zero_bytes:												; zero a byte at a time
	rep stosb												; zero them!
	pop	eax													; restore eax ( )
	ret															; bd, bd, bdea, that's all, folks!


; #################
; #####  END  #####
; #################
