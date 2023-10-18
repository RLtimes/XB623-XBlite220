.code

; ********************
; *****  %_Read  *****  READ #n, v
; ********************
;
; in:	arg2 = number of bytes to read
;	arg1 -> where to put them
;	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
;
%_Read:
	push	ebp
	mov	ebp,esp
read_again:
	sub	esp,20											; ntntnt ;;;
	mov	eax,[ebp+ 8]								; ntntnt
	mov	[esp+0],eax									; ntntnt  fileNumber
	mov	eax,[ebp+12]								; ntntnt
	mov	[esp+4],eax									; ntntnt  bufferAddr
	mov	eax,[ebp+16]								; ntntnt
	mov	[esp+8],eax									; ntntnt  bufferSize
	lea	eax,[esp+12]								; ntntnt
	mov	[esp+12],eax								; ntntnt  bytesRead
	xor	eax,eax											; ntntnt
	mov	[esp+16],eax								; ntntnt  0
	call	_XxxReadFile@20						; ntntnt ;;;
	or	eax,eax											; was there an error?  (eax < 0 if error
	jmp	> read_good									; ntntnt  (add error checking)
	jns	> read_good 								; no: done
	jne	> read_crash 								; no: it was a real error
	cmp	B[_##SOFTBREAK],0						; was it a soft break?
	jne	read_again									; no: it was just some blowhard signal
	jmp	read_again
read_crash:
	mov	esp,ebp
	pop	ebp
	call	%_InvalidFunctionCall			; Return directly from there
read_good:
	mov	esp,ebp
	pop	ebp
	ret

; DATA SECTION SHARED "shr_data"
;  	_##SOFTBREAK							dd ?	; ##SOFTBREAK		(all XBasic SYSTEMCALLs)

