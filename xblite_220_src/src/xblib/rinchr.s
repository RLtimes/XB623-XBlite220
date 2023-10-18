.text
;
; *************************
; *****  %_rinchr.vv  *****  RINCHR(x$, y$, z)
; *****  %_rinchr.sv  *****
; *****  %_rinchr.vs  *****
; *****  %_rinchr.ss  *****
; *************************
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
; RINCHR()'s search is case-sensitive, and proceeds backwards in x$ from
; the start position.  A start position of zero is equivalent to a
; start position of LEN(x$).  A start position greater than LEN(x$)
; is equivalent to a start position of LEN(x$).
;
; RINCHR() builds a lookup table at search_tab, a 256-byte table in which
; each byte corresponds to one ASCII code.  All elements of the table
; are zero except those corresponding to characters in y$.
;
; RINCHR() never generates a run-time error.
;
.globl %_rinchr.vv
%_rinchr.vv:
xor	ebx,ebx			;don't free x$ on exit
xor	ecx,ecx			;don't free y$ on exit
jmp	short rinchr.x
;
.globl %_rinchr.vs
%_rinchr.vs:
xor	ebx,ebx									;don't free x$ on exit
mov	ecx,[esp+8]							;free y$ on exit
jmp	short rinchr.x
;
.globl %_rinchr.sv
%_rinchr.sv:
mov	ebx,[esp+4]							;free x$ on exit
xor	ecx,ecx									;don't free y$ on exit
jmp	short rinchr.x
;
.globl %_rinchr.ss
%_rinchr.ss:
mov	ebx,[esp+4]							;free x$ on exit
mov	ecx,[esp+8]							;free y$ on exit
;;
;; fall through
;;
rinchr.x:
push	ebp
mov	ebp,esp
sub	esp,12
mov	[ebp-4],ebx							;save ptr to 1st string to free on exit
cld
mov	[ebp-8],ecx							;save ptr to 2nd string to free on exit
mov	[ebp-12],0							;return value is zero until proven otherwise
; rule out cases that don't require searching
mov	edi,[ebp+8]							;edi -> x$
or	edi,edi										;null pointer?
jz	short rinchr_done 				;yes: can't find anything in null string
mov	edx,[edi-8]							;edx = LEN(x$)
or	edx,edx										;length is zero?
jz	short rinchr_done 				;yes: can't find anything in 0-length string
mov	esi,[ebp+12]						;esi -> y$
or	esi,esi										;null pointer?
jz	short rinchr_done 				;yes: null string can't contain matches
mov	ecx,[esi-8]							;ecx = LEN(y$)
or	ecx,ecx										;length is zero?
jz	short rinchr_done 				;yes: zero-length string can't contain matches
;
; build table at search_tab
;
mov	ebx,search_tab					;ebx -> base of search table
xor	eax,eax									;zero upper 24 bits of index into search_tab
rinchr_table_build_loop:
lodsb												;get next char from y$ into al
mov	byte ptr [ebx+eax],1 		;mark char's element in table
dec	ecx											;bump character counter
jnz	rinchr_table_build_loop ;next character
;
; search x$ for any chars with non-zero element in search_tab
;
mov	esi,[ebp+16]						;esi = start position (one-biased)
or	esi,esi										;start position is zero?
jz	short rinchr_skip1 				;yes: set start position to end of string
cmp	esi,edx									;start position is greater than LEN(x$)?
jna	short rinchr_skip2 			;no: start position is ok
rinchr_skip1:
mov	esi,edx									;start position is at end of string
rinchr_skip2:
dec	esi											;esi = start offset
rinchr_search_loop:
mov	al,[edi+esi]						;get next char from x$ into al
xlatb												;look up al's element in search_tab
or	al,al											;al != 0 iff al was in y$
jnz	short rinchr_found 			;if char is in y$, done
dec	esi											;bump character counter
jns	rinchr_search_loop
;
; re-zero table at search_tab (so next call to INCHR() works)
;
rinchr_rezero:
mov	esi,[ebp+12]						;esi -> y$
mov	ecx,[esi-8]							;ecx = number of chars in y$
rinchr_table_zero_loop:
lodsb												;get next char from y$ into al
mov	byte ptr [ebx+eax],0 		;zero char's element in table
dec	ecx											;bump character counter
jnz	rinchr_table_zero_loop
; free stack strings and exit
rinchr_done:
mov	esi,[ebp-4]							;esi -> x$ if x$ needs to be freed
call	%____free
mov	esi,[ebp-8]							;esi -> y$ if y$ needs ro be freed
call	%____free
mov	eax,[ebp-12]						;eax = return value
mov	esp,ebp
pop	ebp
ret
rinchr_found:
inc	esi											;esi = current char position (one-biased)
mov	[ebp-12],esi						;return value is current character position
jmp	rinchr_rezero
