

; *****************************************
; *****  %_print.tab.a0.eq.a0.tab.a1  *****  appends spaces to reach desired
; *****************************************  tab stop

.code

; in:	eax -> string to append spaces to
;	ebx = one more than desired length of string
; out:	eax -> new string

; destroys: ebx, ecx, edx, esi, edi

; String pointed to by eax is assumed to be in dynamic memory; it may
; be realloc'ed.

%_print.tab.a0.eq.a0.tab.a1:
%_print.tab.a0.eq.a0.tab.a1.ss:
	cld
	lea	ecx,[ebx-1]									; ecx = desired length of string
	or	ecx,ecx											; desired length <= 0?
	jbe	> pt_abort									; yes: do nothing
	test eax,eax										; null string?
	jnz	> pt001											; no: it's our job
	mov	eax,ebx											; yes: pass it off on specialized routine
	jmp	%_print.tab.first.a0

pt001:
	mov	edi,[eax-8]									; edi = length of existing string
	cmp	edi,ecx											; string is too long or already right length?
	jae	> pt_abort									; yes: nothing to do

	mov	edx,[eax-16]								; edx = length of string's chunk including header
	sub	edx,16											; edx = length of string's chunk excluding header
	cmp	edx,ebx											; is chunk already big enough to hold new string?
	jae	 > pt_append								; yes: no reallocation necessary

	mov	esi,eax											; esi -> existing string
	lea	edi,[ebx+64]								; edi = new length plus 64, since string will
	push	ebx												;  probably be appended to
	call	%____realloc							; make room for spaces we're about to append
	pop	ebx													; esi -> new string
	mov	eax,esi											; eax -> new string
	mov	edi,[eax-8]									; edi = length of existing string
	lea	ecx,[ebx-1]									; ecx = desired length of string

pt_append:
	mov	[eax-8],ecx									; store new length of string
	sub	ecx,edi											; ecx = number of spaces to append
	lea	edi,[eax+edi]								; edi -> char after last char of existing string
	jecxz	> pt_no_stosb							; just in case...
	mov	esi,eax											; save pointer to result string
	mov	al,' '											; ready to write some spaces
	rep stosb												; append spaces!
	mov	eax,esi											; eax -> result string

pt_no_stosb:
	mov	b[edi],0 										; append null terminator

pt_abort:
	ret


; #################
; #####  END  #####
; #################
