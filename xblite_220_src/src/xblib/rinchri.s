.text
;
; **************************
; *****  %_rinchri.vv  *****  RINCHRI(x$, y$, z)
; *****  %_rinchri.sv  *****
; *****  %_rinchri.vs  *****
; *****  %_rinchri.ss  *****
; **************************
;
; in:	arg2 = start position (one-biased) in x$ at which to begin search
;	arg1 -> y$: string containing set of characters to search for
;	arg0 -> x$: string in which to search
; out:	eax = position in x$
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;
; RINCHRI()'s search is case-insensitive, and proceeds backwards in x$ from
; the start position.  A start position of zero is treated the same as a
; start position of LEN(x$).  A start position greater than LEN(x$)
; is equivalent to a start position of LEN(x$).
;
; RINCHRI() builds a lookup table at search_tab, a 256-byte table in which
; each byte corresponds to one ASCII code.  All elements of the table
; are zero except those corresponding to upper- and lower-case versions
; of characters in y$.
;
; RINCHRI() never generates a run-time error.
;
.globl %_rinchri.vv
%_rinchri.vv:
xor	ebx,ebx								;don't free x$ on exit
xor	ecx,ecx								;don't free y$ on exit
jmp	short rinchri.x
;
.globl %_rinchri.vs
%_rinchri.vs:
xor	ebx,ebx								;don't free x$ on exit
mov	ecx,[esp+8]						;free y$ on exit
jmp	short rinchri.x
;
.globl %_rinchri.sv
%_rinchri.sv:
mov	ebx,[esp+4]						;free x$ on exit
xor	ecx,ecx								;don't free y$ on exit
jmp	short rinchri.x
;
.globl %_rinchri.ss
%_rinchri.ss:
mov	ebx,[esp+4]						;free x$ on exit
mov	ecx,[esp+8]						;free y$ on exit
;;
;; fall through
;;
rinchri.x:
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
jz	rinchri_done						;yes: can't find anything in null string
mov	edx,[edi-8]						;edx = LEN(x$)
or	edx,edx									;length is zero?
jz	rinchri_done						;yes: can't find anything in 0-length string
mov	esi,[ebp+12]					;esi -> y$
or	esi,esi									;null pointer?
jz	short rinchri_done 			;yes: null string can't contain matches
mov	ecx,[esi-8]						;ecx = LEN(y$)
or	ecx,ecx									;length is zero?
jz	short rinchri_done 			;yes: 0-length string can't contain matches
;
; build table at search_tab
;
mov	edx,search_tab				;edx -> base of search table
mov	ebx,%_uctolc					;ebx -> base of upper-to-lower conv. table
mov	edi,%_lctouc					;edi -> base of lower-to-upper conv. table
xor	eax,eax								;zero upper 24 bits of index into search_tab
rinchri_table_build_loop:
lodsb											;get next char from y$ into al
xlatb											;convert char to lower case
mov	byte ptr [edx+eax],1 	;mark char's element in table
mov	al,[edi+eax]					;convert char to upper case
mov	byte ptr [edx+eax],1 	;mark char's element in table
dec	ecx										;bump character counter
jnz	rinchri_table_build_loop ;next character
;
; search x$ for any chars with non-zero element in search_tab
;
mov	esi,[ebp+16]					;esi = start position (one-biased)
mov	edi,[ebp+8]						;edi -> x$
mov	edx,[edi-8]						;edx = LEN(x$)
or	esi,esi									;start position is zero?
jz	short rinchri_skip1 		;yes: set start position to end of string
cmp	esi,edx								;start position is greater than LEN(x$)?
jna	short rinchri_skip2 	;no: start position is ok
rinchri_skip1:
mov	esi,edx								;start position is at end of string
rinchri_skip2:
dec	esi										;esi = start offset
mov	ebx,search_tab				;ebx -> base of y$ lookup table
rinchri_search_loop:
mov	al,[edi+esi]					;get next char from x$ into al
xlatb											;look up al's element in search_tab
or	al,al										;al != 0 iff al was in y$
jnz	short rinchri_found 	;if char is in y$, done
dec	esi										;bump character counter
jns	rinchri_search_loop
;
; re-zero table at search_tab (so next call to INCHR() works)
;
rinchri_rezero:
mov	esi,[ebp+12]					;esi -> y$
mov	edx,search_tab				;edx -> base of search table
mov	edi,%_lctouc					;edi -> base of lower-to-upper conv. table
mov	ebx,%_uctolc					;ebx -> base of upper-to-lower conv. table
mov	ecx,[esi-8]						;ecx = number of chars in y$
rinchri_table_zero_loop:
lodsb											;get next char from y$ into al
xlatb											;convert char to lower case
mov	byte ptr [edx+eax],0 	;zero char's element in table
mov	al,[edi+eax]					;convert char to upper case
mov	byte ptr [edx+eax],0 	;zero char's element in table
dec	ecx										;bump character counter
jnz	rinchri_table_zero_loop
; free stack strings and exit
rinchri_done:
mov	esi,[ebp-4]						;esi -> x$ if x$ needs to be freed
call	%____free
mov	esi,[ebp-8]						;esi -> y$ if y$ needs ro be freed
call	%____free
mov	eax,[ebp-12]					;eax = return value
mov	esp,ebp
pop	ebp
ret
rinchri_found:
inc	esi										;esi = current char position (one-biased)
mov	[ebp-12],esi					;return value is current character position
jmp	rinchri_rezero
