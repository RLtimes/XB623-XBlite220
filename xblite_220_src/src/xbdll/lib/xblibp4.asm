
; *****************************
; *****  %_PrintThenFree  *****  prints a string, then frees it
; *****************************

.code

; in:	eax -> string to print
;	arg0 = file number
; out:	nothing

; Destroys: eax, ebx, ecx, edx, esi, edi.

; Local variables:
;	[ebp-4] -> string to print (on-entry eax)

; Frees string pointed to by eax before exiting.

%_PrintThenFree:
	push	ebp
	mov	ebp,esp
	sub	esp,4
	mov	[ebp-4],eax									; save pointer
	push	eax												; push pointer to string to print
	push [ebp+8]										; push file number
	call	main.print								; print the string
	add	esp,8
	mov	esi,[ebp-4]									; esi -> string to free
	call	%____free									; free printed string
	leave
	ret


; #################
; #####  END  #####
; #################

