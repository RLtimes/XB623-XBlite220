.text
;
; **************************
; *****  %_rinstri.vv  *****  RINSTRI(x$, y$, z)
; *****  %_rinstri.vs  *****
; *****  %_rinstri.sv  *****
; *****  %_rinstri.ss  *****
; **************************
;
; in:	arg2 = start position in x$ at which to begin search (one-biased)
;	arg1 -> y$: substring to search for
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
;	[ebp-16] = current offset in x$
;
; RINSTRI()'s search is case-insensitive.  A start position of 0 is treat
; the same as a start position of LEN(x$).  A start position greater
; than LEN(x$)is the same as LEN(x$).  If y$ is null or zero-length, RINS
; returns 0.
;
; RINSTRI() never generates a run-time error.
;
.globl %_rinstri.vv
%_rinstri.vv:
xor	ebx,ebx                ;don't free x$ on exit
xor	ecx,ecx                ;don't free y$ on exit
jmp	short rinstri.x
;
.globl %_rinstri.vs
%_rinstri.vs:
xor	ebx,ebx                ;don't free x$ on exit
mov	ecx,[esp+8]            ;free y$ on exit
jmp	short rinstri.x
;
.globl %_rinstri.sv
%_rinstri.sv:
mov	ebx,[esp+4]            ;free x$ on exit
xor	ecx,ecx                ;don't free y$ on exit
jmp	short rinstri.x
;
.globl %_rinstri.ss
%_rinstri.ss:
mov	ebx,[esp+4]            ;free x$ on exit
mov	ecx,[esp+8]            ;free y$ on exit
;;
;                           ;fall through
;;
rinstri.x:
push	ebp
mov	ebp,esp
sub	esp,16
mov	[ebp-4],ebx            ;save ptr to 1st string to free on exit
cld
mov	[ebp-8],ecx            ;save ptr to 2nd string to free on exit
mov	[ebp-12],0             ;return value is zero until proven otherwise
;                           ;rule out cases that don't require searching
mov	edi,[ebp+8]            ;edi -> x$
or	edi,edi                  ;null pointer?
jz	short rinstri_done       ;yes: can't find anything in null string
mov	ecx,[edi-8]            ;ecx = LEN(x$)
jecxz	short rinstri_done   ;same with zero-length string
mov	eax,[ebp+16]           ;eax = start position
mov	esi,[ebp+12]           ;esi -> y$
or	esi,esi                  ;null pointer?
jz	short rinstri_done       ;yes: can't find a null string
mov	edx,[esi-8]            ;edx = LEN(y$)
or	edx,edx                  ;zero length?
jz	short rinstri_done       ;yes: can't find a zero-length string
cmp	edx,ecx                ;LEN(y$) > LEN(x$)?
ja	short rinstri_done       ;yes: can't find bigger string in smaller
;                           ;set up variables for loop
sub	ecx,edx                ;end of string = LEN(x$) - LEN(y$); must not
;                           ;start a comparison beyond this point in x$
inc	ecx                    ;make ecx one-biased
or	eax,eax                  ;start position is zero?
jz	rinstri_skip2            ;yes: default to end of string
cmp	eax,ecx                ;start offset is beyond end of string?
jna	rinstri_skip1          ;no: start offset is ok
rinstri_skip2:
mov	eax,ecx                ;eax = LEN(x$): start search at end of string
rinstri_skip1:
mov	edx,edi                ;edx -> x$
mov	ebx,%_lctouc           ;ebx -> lower- to upper-case conversion table
;; loop through x$, comparing with y$ at each position until match is fou
dec	eax                    ;past beginning of string?
mov	[ebp-16],eax           ;store current position into memory variable
rinstri_loop:
js	rinstri_done             ;yes: no match
lea	esi,[edx+eax]          ;esi -> current position in x$
mov	edi,[ebp+12]           ;edi -> y$
mov	ecx,[edi-8]            ;ecx = LEN(y$)
rinstri_inner_loop:
lodsb                       ;al = char from x$
xlatb                       ;convert char from x$ to upper case
mov	ah,al                  ;ah = upper-cased char from x$
mov	al,[edi]               ;al = char from y$
xlatb                       ;convert char from y$ to upper case
cmp	ah,al                  ;upper-cased chars from x$ and y$ identical?
jne	short rinstri_nomatch  ;no: try comparing at next char in x$
inc	edi                    ;bump pointer into y$
dec	ecx                    ;bump character counter
jnz	rinstri_inner_loop     ;test against next char in y$, if there
; is one
jmp	short rinstri_found    ;there isn't one: we have a match
rinstri_nomatch:
mov	eax,[ebp-16]
dec	eax                   ;bump current-position counter
mov	[ebp-16],eax          ;flags are tested at top of loop
jmp	rinstri_loop
;                          ;free stack strings and exit
rinstri_done:
mov	esi,[ebp-4]           ;esi -> x$ if x$ needs to be freed
call	%____free
mov	esi,[ebp-8]           ;esi -> y$ if y$ needs to be freed
call	%____free
mov	eax,[ebp-12]          ;eax = return value
mov	esp,ebp
pop	ebp
ret
rinstri_found:
mov	eax,[ebp-16]          ;eax = current offset in x$
inc	eax                   ;convert zero-biased position to one-biased
mov	[ebp-12],eax          ;save return value"
jmp	rinstri_done
