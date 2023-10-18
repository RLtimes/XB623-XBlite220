; ********************************
; *****  %_PrintFileNewline  *****  prints a newline to a file
; ********************************

.code

; in:	arg0 = file number
; out:	nothing

; destroys: eax, ebx, ecx, edx, esi, edi

%_PrintFileNewline:

; 5/5/93:  compiler doesn't push file number

	push	ADDR %_newline.string 		; push string to print
	push	eax												; push file number
	call	main.print
	add	esp,8
	ret

; #################
; #####  END  #####
; #################
