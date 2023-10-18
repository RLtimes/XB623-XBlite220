.text
;
; *************************
; *****  %_rinstr.vv  *****  RINSTR(x$, y$, z)
; *****  %_rinstr.vs  *****
; *****  %_rinstr.sv  *****
; *****  %_rinstr.ss  *****
; *************************
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
;
; RINSTR()'s search is case-sensitive.  A start position of 0 is treated
; the same as a start position of 1.  A start position greater
; than LEN(x$) is the same as LEN(x$).  If y$ is null or zero-length, RINSTR()
; returns 0.
;
; RINSTR() never generates a run-time error.
;
.globl %_rinstr.vv
%_rinstr.vv:
xor	ebx,ebx                ;don't free x$ on exit
xor	ecx,ecx                ;don't free y$ on exit
jmp	short rinstr.x
;
.globl %_rinstr.vs
%_rinstr.vs:
xor	ebx,ebx                ;don't free x$ on exit
mov	ecx,[esp+8]            ;free y$ on exit
jmp	short rinstr.x
;
.globl %_rinstr.sv
%_rinstr.sv:
mov	ebx,[esp+4]            ;free x$ on exit
xor	ecx,ecx                ;don't free y$ on exit
jmp	short rinstr.x
;
.globl %_rinstr.ss
%_rinstr.ss:
mov	ebx,[esp+4]            ;free x$ on exit
mov	ecx,[esp+8]            ;free y$ on exit
;;
;; fall through
;;
rinstr.x:
push	ebp
mov	ebp,esp
sub	esp,12
mov	[ebp-4],ebx            ;save ptr to 1st string to free on exit
cld
mov	[ebp-8],ecx            ;save ptr to 2nd string to free on exit
mov	[ebp-12],0             ;return value is zero until proven otherwise
;                           ;rule out cases that don't require searching
mov	edi,[ebp+8]            ;edi -> x$
or	edi,edi                  ;null pointer?
jz	short rinstr_done        ;yes: can't find anything in null string
mov	ecx,[edi-8]            ;ecx = LEN(x$)
jecxz	short rinstr_done    ;same with zero-length string
mov	eax,[ebp+16]           ;eax = start position
mov	esi,[ebp+12]           ;esi -> y$
or	esi,esi                  ;null pointer?
jz	short rinstr_done        ;yes: can't find a null string
mov	edx,[esi-8]            ;edx = LEN(y$)
or	edx,edx                  ;zero length?
jz	short rinstr_done        ;yes: can't find a zero-length string
cmp	edx,ecx                ;LEN(y$) > LEN(x$)?
ja	short rinstr_done        ;yes: can't find bigger string in smaller
; set up variables for loop
sub	ecx,edx                ;end of string = LEN(x$) - LEN(y$); must not
; start a comparison beyond this point in x$
inc	ecx                    ;make ecx one-biased
or	eax,eax                  ;start offset is zero?
jz	rinstr_skip2             ;yes: default to end of string
cmp	eax,ecx                ;start offset is beyond end of string?
jna	rinstr_skip1           ;no: start offset is ok
rinstr_skip2:
mov	eax,ecx                ;eax = LEN(x$): start search at end of string
rinstr_skip1:
mov	edx,edi                ;edx -> x$
mov	ebx,esi                ;ebx -> y$
; loop through x$, comparing with y$ at each position until match is found
rinstr_loop:
dec	eax                    ;bump position counter
js	rinstr_done              ;no match if past beginning of string
lea	esi,[edx+eax]          ;esi -> current position in x$
mov	edi,ebx                ;edi -> y$
mov	ecx,[edi-8]            ;ecx = LEN(y$)
repz
cmpsb                       ;compare y$ with substring of x$
jz	short rinstr_found       ;got a match
jmp	rinstr_loop
; free stack strings and exit
rinstr_done:
mov	esi,[ebp-4]            ;esi -> x$ if x$ needs to be freed
call	%____free
mov	esi,[ebp-8]            ;esi -> y$ if y$ needs to be freed
call	%____free
mov	eax,[ebp-12]           ;eax = return value
mov	esp,ebp
pop	ebp
ret
rinstr_found:
inc	eax                    ;convert zero-biased position to one-biased
mov	[ebp-12],eax           ;save return value
jmp	rinstr_done
