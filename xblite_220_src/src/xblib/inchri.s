.text
;
; *************************
; *****  %_inchri.vv  *****  INCHRI(x$, y$, z)
; *****  %_inchri.vs  *****
; *****  %_inchri.sv  *****
; *****  %_inchri.ss  *****
; *************************
;
; in:	arg2 = start position in x$ at which to begin search (one-biased)
;	arg1 -> y$: string containing set of characters to search for
;	arg0 -> x$: string in which to search
; out:	eax = index (one-biased) of first char in y$ that was found in
;	      x$, or 0 if none were found
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;
; INCHRI()'s search is case-insensitive.  A start position of 0 is treate
; the same as a start position of 1.  If the start position is greater
; than LEN(x$), INCHRI() returns 0.
;
; INCHRI() builds a lookup table at search_tab, a 256-byte table in which
; each byte corresponds to one ASCII code.  All elements of the table
; are zero except those corresponding to upper- and lower-case versions
; of characters in y$.
;
; INCHRI() never generates a run-time error.
;
.globl %_inchri.vv
%_inchri.vv:
xor	ebx,ebx								;don't free x$ on exit
xor	ecx,ecx								;don't free y$ on exit
jmp	short inchri.x
;
.globl %_inchri.vs
%_inchri.vs:
xor	ebx,ebx								;don't free x$ on exit
mov	ecx,[esp+8]						;free y$ on exit
jmp	short inchri.x
;
.globl %_inchri.sv
%_inchri.sv:
mov	ebx,[esp+4]						;free x$ on exit
xor	ecx,ecx								;don't free y$ on exit
jmp	short inchri.x
;
.globl %_inchri.ss
%_inchri.ss:
mov	ebx,[esp+4]						;free x$ on exit
mov	ecx,[esp+8]						;free y$ on exit
;;
;; fall through
;;
inchri.x:
push	ebp
mov	ebp,esp
sub	esp,12
mov	[ebp-4],ebx						;save ptr to 1st string to free on exit
cld
mov	[ebp-8],ecx						;save ptr to 2nd string to free on exit
mov	[ebp-12],0						;return value is zero until proven otherwise
; rule out cases that don't require searching
mov	edi,[ebp+8]						;edi -> x$
or	edi,edi									;null pointer?
jz	inchri_done							;yes: can't find anything in null string
mov	edx,[edi-8]						;edx = LEN(x$)
or	edx,edx									;length is zero?
jz	inchri_done 						;yes: can't find anything in 0-length string
cmp	edx,[ebp+16]					;length is less than start position?
jb	short inchri_done 			;yes: can't find anything off right end of x$
mov	esi,[ebp+12]					;esi -> y$
or	esi,esi									;null pointer?
jz	short inchri_done 			;yes: null string can't contain matches
mov	ecx,[esi-8]						;ecx = LEN(y$)
or	ecx,ecx									;length is zero?
jz	short inchri_done 			;yes: zero-length string can't contain matches
;
; build table at search_tab
;
mov	edx,search_tab				;edx -> base of search table
mov	ebx,%_uctolc					;ebx -> base of upper-to-lower conv. table
mov	edi,%_lctouc					;edi -> base of lower-to-upper conv. table
xor	eax,eax								;zero upper 24 bits of index into search_tab
inchri_table_build_loop:
lodsb											;get next char from y$ into al
xlatb											;convert char to lower case
mov	byte ptr [edx+eax],1 	;mark char's element in table
mov	al,[edi+eax]					;convert char to upper case
mov	byte ptr [edx+eax],1 	;mark char's element in table
dec	ecx										;bump character counter
jnz	inchri_table_build_loop ;next character
;
; search x$ for any chars with non-zero element in search_tab
;
mov	esi,[ebp+8]						;esi -> x$
mov	edi,[ebp+16]					;edi = start position (one-biased)
or	edi,edi									;start position is zero?
jz	short inchri_skip1 			;yes: start at first position
dec	edi										;edi = start offset
inchri_skip1:
mov	edx,[esi-8]						;edx = number of chars in x$
sub	edx,edi								;edx = number of chars to check
add	esi,edi								;esi -> first character to check
mov	ebx,search_tab				;ebx -> base of y$ lookup table
;
inchri_search_loop:
inc	edi										;bump position counter
lodsb											;get next char from x$ into al
xlatb											;look up al's element in search_tab
or	al,al										;al != 0 iff al was in y$
jnz	short inchri_found 		;if char is in y$, done
dec	edx										;bump character counter
jnz	inchri_search_loop
;
; re-zero table at search_tab (so next call to INCHR() works)
;
inchri_rezero:
mov	esi,[ebp+12]					;esi -> y$
mov	edx,search_tab				;edx -> base of search table
mov	edi,%_lctouc					;edi -> base of lower-to-upper conv. table
mov	ebx,%_uctolc					;ebx -> base of upper-to-lower conv. table
mov	ecx,[esi-8]						;ecx = number of chars in y$
inchri_table_zero_loop:
lodsb											;get next char from y$ into al
xlatb											;convert char to lower case
mov	byte ptr [edx+eax],0 	;zero char's element in table
mov	al,[edi+eax]					;convert char to upper case
mov	byte ptr [edx+eax],0 	;zero char's element in table
dec	ecx										;bump character counter
jnz	inchri_table_zero_loop
; free stack strings and exit
inchri_done:
mov	esi,[ebp-4]						;esi -> x$ if x$ needs to be freed
call	%____free
mov	esi,[ebp-8]						;esi -> y$ if y$ needs ro be freed
call	%____free
mov	eax,[ebp-12]					;eax = return value
mov	esp,ebp
pop	ebp
ret
inchri_found:
mov	[ebp-12],edi					;return value is current character position
jmp	inchri_rezero
