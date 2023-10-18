
; ########################
; #####  xblibs.asm  #####  Mostly String routines
; ########################

.code

; *********************************
; *****  %_string.compare.vv  *****  string comparisons
; *****  %_string.compare.vs  *****
; *****  %_string.compare.sv  *****
; *****  %_string.compare.ss  *****
; *********************************

; in:	eax -> string1
;	ebx -> string2
; out:	flags set as if a "cmp *eax,*ebx" instruction had been executed,
;	so that the unsigned conditional jump instructions will make
;       sense if executed immediately upon return from the string
;	comparison routine

; destroys: ecx, edx, esi, edi

; local variables:
;	[ebp-4] -> string1, if it needs to be freed on exit
;	[ebp-8] -> string2, if it needs to be freed on exit
;	[ebp-12] holds the flags to be returned

%_string.compare.vv:
	xor	esi,esi											; don't free string1 on exit
	xor	edi,edi											; don't free string2 on exit
	jmp	 string.compare.x

%_string.compare.vs:
	xor	esi,esi											; don't free string1 on exit
	mov	edi,ebx											; must free string2 on exit
	jmp	 string.compare.x

%_string.compare.sv:
	mov	esi,eax											; must free string1 on exit
	xor	edi,edi											; don't free string2 on exit
	jmp	 string.compare.x

%_string.compare.ss:
	mov	esi,eax											; must free string1 on exit
	mov	edi,ebx											; must free string2 on exit

; fall through
string.compare.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12
	mov	[ebp-4],esi									; save  to first string to free on exit
	mov	[ebp-8],edi									; save  to second string to free on exit
	test eax,eax										; string1 is a null pointer?
	jz	> string1_null 							; yes: special processing
	test ebx,ebx										; string2 is a null pointer?
	jz	> string2_null 							; yes: special processing

	mov	ecx,[eax-8]									; ecx = LEN(string1)
	cmp	ecx,[ebx-8]									; LEN(string1) > LEN(string2)?
	jb	> sc_compare 								; no: ecx = LEN(shortest string)
	mov	ecx,[ebx-8]									; ecx = LEN(string2) = LEN(shortest string)

sc_compare:
	mov	esi,eax											; esi -> string1
	mov	edi,ebx											; edi -> string2
	repe  													; changed by Greg from rep - is this correct????
	cmpsb														; compare them strings!
	je	> sc_compare_lengths 				; if equal, longer string is "greater"
																	; otherwise, flags after rep cmpsb are
																	; the result flags
sc_done:
	lahf														; result flags to AH
	mov	[ebp-12],eax								; save result flags
	mov	esi,[ebp-4]									; esi -> first string to free on exit
	call	%____free
	mov	esi,[ebp-8]									; esi -> second string to free on exit
	call	%____free

	mov	eax,[ebp-12]								; AH = result flags
	sahf														; put result flags back into flag register
	leave
	ret

string1_null:											; string1 is a null pointer
	cmp	eax,ebx											; string2 a null pointer too?
	je	sc_done											; yes
	mov	ebx,[ebx-8]									; ebx = length of string2
	cmp	eax,ebx											; both empty?
	jmp	sc_done											; comparison tells all

string2_null:
	cmp	ebx,eax											; string2 is a null pointer
	je	sc_done											; string1 a null pointer too?
	mov	eax,[eax-8]									; eax = length of string1
	cmp	ebx,eax											; both empty?
	jmp	sc_done											; comparison tells all

sc_compare_lengths:
	mov	ecx,[eax-8]									; ecx = LEN (string1)
	cmp	ecx,[ebx-8]									; compare with LEN (string2),
	jmp	sc_done											; yielding result flags


; #################
; #####  END  #####
; #################
