; *********************
; *****  %_Print  *****  prints a string
; *********************

.code

; in:	eax -> string to print
;	arg0 = file number
; out:	nothing

; Destroys: eax, ebx, ecx, edx, esi, edi.

; Frees string pointed to by eax before exiting.

%_Print:
	push	ebp
	mov	ebp,esp

	push	eax												; push pointer to string to print
	mov	eax, [ebp+8]								; eax = file number
	cmp	eax, 2											; see if STDIN, STDOUT, STDERR
	jl	> fpr												; nope, so it's a file print
	mov	eax, 1											; eax = stdout
fpr:
	push	eax												;	push file number
	call	main.print								; print the string
	add	esp,8
	leave
	ret

; #################
; #####  END  #####
; #################
