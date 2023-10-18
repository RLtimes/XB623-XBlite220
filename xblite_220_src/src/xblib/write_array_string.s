.text
;
; ***************************
; *****  %_WriteArray   *****  WRITE #n, v[]
; *****  %_WriteString  *****  WRITE #n, v$
; ***************************
;
; in:	arg1 -> array or string to write
;	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] = number of bytes to write
;
.globl %_WriteArray
%_WriteArray:
.globl %_WriteString
%_WriteString:
push	ebp
mov	ebp,esp
sub	esp,4
;
mov	ebx,[ebp+12]			;ebx -> array or string to write
or	ebx,ebx							;empty array?
jz	writearray_good			;yes, ignore
mov	eax, [ebx-4]
test	eax, 0x20000000		;is array nodal?
jnz	writearray_nodal
and	eax, 0x40FF0000
xor	eax, 0x40130000		;is it a string array?
jnz	writearray_not_string	;handle string array same as node
writearray_nodal:
mov	ecx, [ebx-8]			;number of elements
sub	esp, 16
writearray_loop:
mov	[esp+8], ecx			;save element counter
mov	[esp+12], ebx			;save array node
mov	ebx, [ebx]				;address of subarray or string
mov	[esp+4], ebx
mov	eax, [ebp+8]
mov	[esp], eax				;file number
call	%_WriteArray
mov	ebx, [esp+12]
mov	ecx, [esp+8]
add	ebx,4							;increment node
loop	writearray_loop
jmp	writearray_good
writearray_not_string:
movzx	eax,word ptr [ebx-4]	;eax = # of bytes per element
mov	ecx,[ebx-8]				;ecx = # of elements
mul	ecx								;eax = # of bytes to write
mov	[ebp-4],eax				;save it where \"write\" syscall can't get to it
writearray_again:
sub	esp, 20						; ntntnt ;;;
mov	eax, [ebp+ 8]			; ntntnt
mov	[esp+ 0], eax			; ntntnt  fileNumber
mov	eax, [ebp+12]			; ntntnt
mov	[esp+ 4], eax			; ntntnt  bufferAddr
mov	eax, [ebp-4]			; ntntnt
mov	[esp+ 8], eax			; ntntnt  bufferSize
lea	eax, [esp+12]			; ntntnt
mov	[esp+12], eax			; ntntnt  bytesRead
xor	eax, eax					; ntntnt
mov	[esp+16], eax			; ntntnt  0
call	_XxxWriteFile@20		; ntntnt ;;;
or	eax,eax							;was there an error?  (eax < 0 if error)
jmp	short writearray_good	; ntntnt  (add error checking)
jns	short writearray_good ;no: done
jne	short writearray_crash ;no: it was a real error
cmp	[_##SOFTBREAK],0	;was it a soft break?
jne	writearray_again 	;no: it was just some blowhard signal
jmp	writearray_again
writearray_crash:
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall	; Return directly from there
writearray_good:
mov	esp,ebp
pop	ebp
ret


