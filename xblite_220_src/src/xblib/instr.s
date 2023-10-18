.text
;
; ************************
; *****  %_instr.vv  *****  INSTR(x$, y$, z)
; *****  %_instr.vs  *****
; *****  %_instr.sv  *****
; *****  %_instr.ss  *****
; ************************
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
; INSTR()'s search is case-sensitive.  A start position of 0 is treated
; the same as a start position of 1.  If the start position is greater
; than LEN(x$), INSTR() returns 0.  If y$ is null or zero-length, INSTR()
; returns 0.
;
; INSTR() never generates a run-time error.
;
.globl %_instr.vv
%_instr.vv:
xor	ebx,ebx                ;don't free x$ on exit
xor	ecx,ecx                ;don't free y$ on exit
jmp	short instr.x
;
.globl %_instr.vs
%_instr.vs:
xor	ebx,ebx                ;don't free x$ on exit
mov	ecx,[esp+8]            ;free y$ on exit
jmp	short instr.x
;
.globl %_instr.sv
%_instr.sv:
mov	ebx,[esp+4]            ;free x$ on exit
xor	ecx,ecx                ;don't free y$ on exit
jmp	short instr.x
;
.globl %_instr.ss
%_instr.ss:
mov	ebx,[esp+4]            ;free x$ on exit
mov	ecx,[esp+8]            ;free y$ on exit
;;
;; fall through
;;
instr.x:
push	ebp
mov	ebp,esp
sub	esp,12
;;
mov	[ebp-4],ebx            ;save ptr to 1st string to free on exit
cld
mov	[ebp-8],ecx            ;save ptr to 2nd string to free on exit
mov	[ebp-12],0             ;return value is zero until proven otherwise
; rule out cases that don't require searching
mov	edi,[ebp+8]            ;edi -> x$
or	edi,edi                  ;null pointer?
jz	short instr_done         ;yes: can't find anything in null string
mov	ecx,[edi-8]            ;ecx = LEN(x$)
jecxz	short instr_done     ;same with zero-length string
mov	eax,[ebp+16]           ;eax = start position
cmp	eax,ecx                ;start position greater than length?
ja	short instr_done         ;yes: can't find anything beyond end of string
;;
mov	esi,[ebp+12]           ;esi -> y$
or	esi,esi                  ;null pointer?
jz	short instr_done         ;yes: can't find a null string
mov	edx,[esi-8]            ;edx = LEN(y$)
or	edx,edx                  ;zero length?
jz	short instr_done         ;yes: can't find a zero-length string
cmp	edx,ecx                ;LEN(y$) > LEN(x$)?
ja	short instr_done         ;yes: can't find bigger string in smaller
; set up variables for loop
dec	eax                    ;eax = start offset
jns	instr_skip1            ;wait!
inc	eax                    ;if start position was zero, start search
instr_skip1:                ;at beginning of string
sub	ecx,edx                ;ecx = LEN(x$) - LEN(y$) = last position
;                           ;in x$ at which there's any point in starting
;                           ;a comparison
mov	ebx,ecx                ;ebx = last position to check
mov	edx,edi                ;edx -> x$
; loop through x$, comparing with y$ at each position until match is found
instr_loop:
cmp	eax,ebx                ;past last position to check?
ja	instr_done               ;yes: no match
lea	esi,[edx+eax]          ;esi -> current position in x$
mov	edi,[ebp+12]           ;edi -> y$
mov	ecx,[edi-8]            ;ecx = LEN(y$)
repz
cmpsb                       ;compare y$ with substring of x$
jz	short instr_found        ;got a match
inc	eax                    ;bump current-position counter
jmp	instr_loop
; free stack strings and exit
instr_done:
mov	esi,[ebp-4]            ;esi -> x$ if x$ needs to be freed
call	%____free
mov	esi,[ebp-8]            ;esi -> y$ if y$ needs to be freed
call	%____free
mov	eax,[ebp-12]           ;eax = return value
mov	esp,ebp
pop	ebp
ret
instr_found:
inc	eax                    ;convert zero-biased position to one-biased
mov	[ebp-12],eax           ;save return value
jmp	instr_done
