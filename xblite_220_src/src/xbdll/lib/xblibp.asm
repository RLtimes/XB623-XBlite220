
; ########################
; #####  xblibp.asm  #####  Mostly PRINT routines
; ########################

.code

; ************************
; *****  main.print  *****  main print routine - internal entry point
; ************************

; in:	arg1 -> string to print
;	arg0 = file number
; out:	nothing

; Destroys: eax, ebx, ecx, edx, esi, edi.

main.print:
mainPrint:
	push	ebp
	mov	ebp,esp

print_again:
	mov	eax,[ebp+12]								; eax -> string to print
	test	eax,eax										; null pointer?
	jz	> print_null								; yes: do nothing
	push	0													;
	push	esp												;
	push [eax-8]										; push "nbytes" parameter
	push	eax												; push "buf" parameter
	mov	eax, [ebp+8]								; eax = fileNumber
	cmp	eax, 2											; is it stdin, stdout, stderr
	jg	> prtfile										; no
	mov	eax, 1											; eax = stdout fileNumber

prtfile:
	push	eax												; push fileNumber
	call	_XxxWriteFile@20

print_null:
	leave
	ret


.const
align	8
dd	0x20,	0x0,	0x1,	0x80130001
%_newline.string:
	db	0x0A
	db 15 DUP 0

; #################
; #####  END  #####
; #################
