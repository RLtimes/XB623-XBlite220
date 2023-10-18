.text
;
; *************************
; *****  %_instri.vv  *****  INSTRI(x$, y$, z)
; *****  %_instri.vs  *****
; *****  %_instri.sv  *****
; *****  %_instri.ss  *****
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
;	[ebp-16] = current offset in x$
;	[ebp-20] = last offset in x$ at which there's any point in starting
;		   a comparison with y$
;
; INSTRI()'s search is case-insensitive.  A start position of 0 is treated
; the same as a start position of 1.  If the start position is greater
; than LEN(x$), INSTRI() returns 0.  If y$ is null or zero-length, INSTRI()
; returns 0.
;
; INSTRI() never generates a run-time error.
;
.globl %_instri.vv
%_instri.vv:
xor	ebx,ebx                 ;don't free x$ on exit
xor	ecx,ecx                 ;don't free y$ on exit
jmp	short instri.x
;
.globl %_instri.vs
%_instri.vs:
xor	ebx,ebx                 ;don't free x$ on exit
mov	ecx,[esp+8]             ;free y$ on exit
jmp	short instri.x
;
.globl %_instri.sv
%_instri.sv:
mov	ebx,[esp+4]             ;free x$ on exit
xor	ecx,ecx                 ;don't free y$ on exit
jmp	short instri.x
;
.globl %_instri.ss
%_instri.ss:
mov	ebx,[esp+4]             ;free x$ on exit
mov	ecx,[esp+8]             ;free y$ on exit
;;
;                            ;fall through
;;
instri.x:
push	ebp
mov	ebp,esp
sub	esp,20
mov	[ebp-4],ebx             ;save ptr to 1st string to free on exit
cld
mov	[ebp-8],ecx             ;save ptr to 2nd string to free on exit
mov	[ebp-12],0              ;return value is zero until proven otherwise
;                            ;rule out cases that don't require searching
mov	edi,[ebp+8]             ;edi -> x$
or	edi,edi                   ;null pointer?
jz	short instri_done         ;yes: can't find anything in null string
mov	ecx,[edi-8]             ;ecx = LEN(x$)
jecxz	short instri_done     ;same with zero-length string
mov	eax,[ebp+16]            ;eax = start position
cmp	eax,ecx                 ;start position greater than length?
ja	short instri_done         ;yes: can't find anything beyond end of string
mov	esi,[ebp+12]            ;esi -> y$
or	esi,esi                   ;null pointer?
jz	short instri_done         ;yes: can't find a null string
mov	edx,[esi-8]             ;edx = LEN(y$)
or	edx,edx                   ;zero length?
jz	short instri_done         ;yes: can't find a zero-length string
cmp	edx,ecx                 ;LEN(y$) > LEN(x$)?
ja	short instri_done         ;yes: can't find bigger string in smaller
; set up variables for loop
dec	eax                     ;eax = start offset
jns	instri_skip1            ;wait!
inc	eax                     ;if start position was zero, start search
instri_skip1:                ;at beginning of string
mov	[ebp-16],eax            ;set current position variable to start offset
sub	ecx,edx                 ;ecx = LEN(x$) - LEN(y$) = last position
;                            ;in x$ at which there's any point in starting
;                            ;a comparison
mov	[ebp-20],ecx            ;[ebp-20] = last position to check
mov	edx,edi                 ;edx -> x$
mov	ebx,%_lctouc            ;ebx -> lower- to upper-case conversion table
; loop through x$, comparing with y$ at each position until match is found
instri_loop:
cmp	eax,[ebp-20]           ;past last position to check?
ja	instri_done              ;yes: no match
lea	esi,[edx+eax]          ;esi -> current position in x$
mov	edi,[ebp+12]           ;edi -> y$
mov	ecx,[edi-8]            ;ecx = LEN(y$)
instri_inner_loop:
lodsb                       ;al = char from x$
xlatb                       ;convert char from x$ to upper case
xchg	ah,al                  ;upper-cased char from x$ to ah
mov	al,[edi]               ;al = char from y$
xlatb                       ;convert char from y$ to upper case
cmp	ah,al                  ;upper-cased chars from x$ and y$ identical?
jne	short instri_nomatch   ;no: try comparing at next char in x$
inc	edi                    ;bump pointer into y$
dec	ecx                    ;bump character counter
jnz	instri_inner_loop      ;test against next char in y$, if there
; is one
jmp	short instri_found     ;there isn't one: we have a match
instri_nomatch:
mov	eax,[ebp-16]
inc	eax                    ;bump current-position counter
mov	[ebp-16],eax
jmp	instri_loop
; free stack strings and exit
instri_done:
mov	esi,[ebp-4]            ;esi -> x$ if x$ needs to be freed
call	%____free
mov	esi,[ebp-8]            ;esi -> y$ if y$ needs to be freed
call	%____free
mov	eax,[ebp-12]           ;eax = return value
mov	esp,ebp
pop	ebp
ret
instri_found:
mov	eax,[ebp-16]           ;eax = current offset in x$
inc	eax                    ;convert zero-biased position to one-biased
mov	[ebp-12],eax           ;save return value
jmp	instri_done
