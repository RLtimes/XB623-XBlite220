.code
; *************************
; *****  %_ReadArray  *****  READ #n, v[]   and   READ #n, v$
; *************************
;
; in:	arg1 -> array or string to read
;	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
; local variables:
;	[ebp-4] = number of bytes to read

%_ReadArray:
%_ReadString:
	push	ebp
	mov	ebp,esp
	sub	esp,4
	mov	eax,[ebp+12]								; ebx -> array or string to read
	mov	ebx,eax
	or	eax,eax											; empty string ?
	jz	> readarray_good						; yes
	mov	eax, [ebx-4]
	test	eax, 0x20000000						; is array nodal?
	jnz	> readarray_nodal
	and	eax, 0x40FF0000
	xor	eax, 0x40130000							; is it a string array?
	jnz	> readarray_not_string			; handle string array same as a node
readarray_nodal:
	mov	ecx, [ebx-8]								; number of elements
	sub	esp, 16
readarray_loop:
	mov	[esp+8], ecx								; save element counter
	mov	[esp+12], ebx								; save array node
	mov	ebx, [ebx]									; address of subarray or string
	mov	[esp+4], ebx
	mov	eax, [ebp+8]
	mov	[esp], eax									; file number
	call	%_ReadArray
	mov	ebx, [esp+12]
	mov	ecx, [esp+8]
	add	ebx,4												; increment node
	loop	readarray_loop
	jmp	> readarray_good
readarray_not_string:
	movzx	eax,w[ebx-4] 							;	eax = # of bytes per element
	mov	ecx,[ebx-8]									;	ecx = # of elements
	mul	ecx													;	eax = # of bytes to read
	mov	[ebp-4],eax									;	save it where \"read\" syscall can't get to it
readarray_again:
	sub	esp, 20											; ntntnt ;;;
	mov	eax, [ebp+ 8]								; ntntnt
	mov	[esp+ 0], eax								; ntntnt  fileNumber
	mov	eax, [ebp+12]								; ntntnt
	mov	[esp+ 4], eax								; ntntnt  bufferAddr
	mov	eax, [ebp-4]								; ntntnt
	mov	[esp+ 8], eax								; ntntnt  bufferSize
	lea	eax, [esp+12]								; ntntnt
	mov	[esp+12], eax								; ntntnt  bytesRead
	xor	eax, eax										; ntntnt
	mov	[esp+16], eax								; ntntnt  0
	call	_XxxReadFile@20						; ntntnt ;;;
	or	eax,eax											; was there an error?  (eax < 0 if error)
	jmp	> readarray_good						; ntntnt  (add error checking)
	jns	> readarray_good 						; no: done
	jne	> readarray_crash 					; no: it was a real error
	cmp	d[_##SOFTBREAK],0						; was it a soft break?
	jne	readarray_again							; no: it was just some blowhard signal
	jmp	readarray_again
readarray_crash:
	mov	esp,ebp
	pop	ebp
	call	%_InvalidFunctionCall			; Return directly from there
readarray_good:
	mov	esp,ebp
	pop	ebp
	ret

; DATA SECTION SHARED "shr_data"
;  	_##SOFTBREAK							dd ?	; ##SOFTBREAK		(all XBasic SYSTEMCALLs)


