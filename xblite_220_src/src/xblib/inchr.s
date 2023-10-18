.text
;
; ************************
; *****  %_inchr.vv  *****  INCHR(x$, y$, z)
; *****  %_inchr.vs  *****
; *****  %_inchr.sv  *****
; *****  %_inchr.ss  *****
; ************************
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
; INCHR()'s search is case-sensitive.  A start position of 0 is treated
; the same as a start position of 1.  If the start position is greater
; than LEN(x$), INCHR() returns 0.
;
; INCHR() builds a lookup table at search_tab, a 256-byte table in which
; each byte corresponds to one ASCII code.  All elements of the table
; are zero except those corresponding to characters in y$.
;
; INCHR() never generates a run-time error.
;
.globl %_inchr.vv
%_inchr.vv:
xor	ebx,ebx							;don't free x$ on exit
xor	ecx,ecx							;don't free y$ on exit
jmp	short inchr.x
;
.globl %_inchr.vs
%_inchr.vs:
xor	ebx,ebx							;don't free x$ on exit
mov	ecx,[esp+8]					;free y$ on exit
jmp	short inchr.x
;
.globl %_inchr.sv
%_inchr.sv:
mov	ebx,[esp+4]					;free x$ on exit
xor	ecx,ecx							;don't free y$ on exit
jmp	short inchr.x
;
.globl %_inchr.ss
%_inchr.ss:
mov	ebx,[esp+4]					;free x$ on exit
mov	ecx,[esp+8]					;free y$ on exit
;;
;; fall through
;;
inchr.x:
push	ebp
mov	ebp,esp
sub	esp,12
mov	[ebp-4],ebx					;save ptr to 1st string to free on exit
cld
mov	[ebp-8],ecx					;save ptr to 2nd string to free on exit
mov	[ebp-12],0					;return value is zero until proven otherwise
; rule out cases that don't require searching
mov	edi,[ebp+8]					;edi -> x$
or	edi,edi								;null pointer?
jz	short inchr_done 			;yes: can't find anything in null string
mov	edx,[edi-8]					;edx = LEN(x$)
or	edx,edx								;length is zero?
jz	short inchr_done 			;yes: can't find anything in zero-length string
cmp	edx,[ebp+16]				;length is less than start position?
jb	short inchr_done 			;yes: can't find anything off right end of x$
mov	esi,[ebp+12]				;esi -> y$
or	esi,esi								;null pointer?
jz	short inchr_done 			;yes: null string can't contain matches
mov	ecx,[esi-8]					;ecx = LEN(y$)
or	ecx,ecx								;length is zero?
jz	short inchr_done 			;yes: zero-length string can't contain matches
; build table at search_tab
mov	ebx,search_tab			;ebx -> base of search table
xor	eax,eax							;zero upper 24 bits of index into search_tab
inchr_table_build_loop:
lodsb										;get next char from y$ into al
mov	byte ptr [ebx+eax],1 	;mark char's element in table
dec	ecx									;bump character counter
jnz	inchr_table_build_loop 	;next character
; search x$ for any chars with non-zero element in search_tab
mov	esi,edi							;esi -> x$
mov	edi,[ebp+16]				;edi = start position (one-biased)
or	edi,edi								;start position is zero?
jz	short inchr_skip1 		;yes: start at first position
dec	edi									;edi = start offset
inchr_skip1:
sub	edx,edi							;edx = number of chars to check
add	esi,edi							;esi -> first character to check
inchr_search_loop:
inc	edi									;bump position counter
lodsb										;get next char from x$ into al
xlatb										;look up al's element in search_tab
or	al,al									;al != 0 iff al was in y$
jnz	short inchr_found 	;if char is in y$, done
dec	edx									;bump character counter
jnz	inchr_search_loop
; re-zero table at search_tab (so next call to INCHR() works)
inchr_rezero:
mov	esi,[ebp+12]				;esi -> y$
mov	ecx,[esi-8]					;ecx = number of chars in y$
inchr_table_zero_loop:
lodsb										;get next char from y$ into al
mov	byte ptr [ebx+eax],0 	;zero char's element in table
dec	ecx									;bump character counter
jnz	inchr_table_zero_loop
; free stack strings and exit
inchr_done:
mov	esi,[ebp-4]					;esi -> x$ if x$ needs to be freed
call	%____free
mov	esi,[ebp-8]					;esi -> y$ if y$ needs ro be freed
call	%____free
mov	eax,[ebp-12]				;eax = return value
mov	esp,ebp
pop	ebp
ret
inchr_found:
mov	[ebp-12],edi				;return value is current character position
jmp	inchr_rezero
