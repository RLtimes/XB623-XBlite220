
; **************************************
; ***** %_PrintWithNewlineThenFree *****
; **************************************

.code

; in:	eax -> string to print, followed by newline
;	arg0 = file number
; out:	nothing

; Destroys: eax, ebx, ecx, edx, esi, edi.

; Local variables:
;	[ebp-4] -> string to print (on-entry eax)

; Frees string pointed to by eax before exiting.

%_PrintWithNewlineThenFree:
	test eax,eax										; null pointer?
	jnz	> pwntfa										; no
	mov	eax,[esp+4]									; eax = file number
	jmp	%_PrintFileNewline

pwntfa:
	push	ebp
	mov	ebp,esp
	sub	esp,4
	mov	[ebp-4],eax									; save pointer

ptfn_again:
	mov	eax,[ebp-4]									; eax -> string to print
	mov	ebx,[eax-8]									; ebx = length of string
	mov	b[eax+ebx],0x0A 						;'\n' ;replace null terminator with newline
	inc	ebx													; ebx = length of string including newline
	push	0													;
	push	esp												;
	push	ebx												; push "nbytes" parameter
	push	eax												; push "buf" parameter
	mov	eax, [ebp+8]								; eax = fileNumber
	cmp	eax, 2											; is it stdin, stdout, stderr
	jg	> prtfilex									; no
	mov	eax, 1											; eax = stdout fileNumber

prtfilex:
	push	eax												; push fileNumber
	call	_XxxWriteFile@20
	mov	esi,[ebp-4]									; esi -> string to free
	call	%____free									; free printed string
	leave
	ret


; #################
; #####  END  #####
; #################
