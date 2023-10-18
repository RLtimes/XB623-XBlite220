.text
;
; *********************
; *****  %_Write  *****  WRITE #n, v
; *********************
;
; in:	arg2 = number of bytes to write
;	arg1 -> bytes to write
;	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
;
.globl %_Write
%_Write:
push	ebp
mov	ebp,esp
write_again:
sub	esp, 20					; ntntnt ;;;
mov	eax, [ebp+ 8]		; ntntnt
mov	[esp+ 0], eax		; ntntnt  fileNumber
mov	eax, [ebp+12]		; ntntnt
mov	[esp+ 4], eax		; ntntnt  bufferAddr
mov	eax, [ebp+16]		; ntntnt
mov	[esp+ 8], eax		; ntntnt  bufferSize
lea	eax, [esp+12]		; ntntnt
mov	[esp+12], eax		; ntntnt  bytesRead
xor	eax, eax				; ntntnt
mov	[esp+16], eax		; ntntnt  0
call	_XxxWriteFile@20	; ntntnt ;;;
or	eax,eax							;was there an error?  (eax < 0 if error)
jmp	short write_good	; ntntnt  (add error checking)
jns	short write_good 	;no: done
jne	short write_crash ;no: it was a real error
cmp	[_##SOFTBREAK],0	;was it a soft break?
jne	write_again				;no: it was just some blowhard signal
jmp	write_again
write_crash:
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall	; Return directly from there
;
write_good:
mov	esp,ebp
pop	ebp
ret
