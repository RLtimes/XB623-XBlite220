; ***********************************
; *****  %_PrintConsoleNewline  *****  prints a newline to stdout
; ***********************************

.code

; in:	nothing
; out:	nothing

; Destroys: eax, ebx, ecx, edx, esi, edi.

%_PrintConsoleNewline:
%_print.console.newline:
	push ADDR %_newline.string			; push string to print
	push	1													; push stdout
	call	main.print
	add	esp,8
	ret

; #################
; #####  END  #####
; #################
