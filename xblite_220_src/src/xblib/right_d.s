.text
;
; *************************
; *****  %_right.d.v  *****  RIGHT$(x$,y)
; *****  %_right.s.s  *****
; *************************
;
; in:	arg1 = # of characters to peel off of right
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;
.globl %_right.d.v
%_right.d.v:
xor	ebx,ebx             ;must create new string to hold result
jmp	short right.d.x
;
.globl %_right.d.s
%_right.d.s:
mov	ebx,[esp+4]         ;put result on top of source string
;;
;                        ;fall through
;;
right.d.x:
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx         ;save pointer to string to free on exit, if any
mov	esi,[ebp+8]         ;esi -> source string
or	esi,esi               ;a null pointer?
jz	right_null            ;yes: return null pointer
mov	ecx,[esi-8]         ;ecx = length of source string
jecxz	right_null        ;if nothing in string, return null pointer
mov	edx,[ebp+12]        ;edx = requested number of characters
or	edx,edx
jz	right_null            ;if zero requested, return null pointer
jb	right_IFC             ;if less than zero, get angry
push	edx                 ;push number of chars requested
sub	ecx,edx             ;ecx = LEN(x$) - # chars requested = start pos
ja	short right_skip      ;if start pos is in string, then no problem
xor	ecx,ecx             ;otherwise force start pos to first char
right_skip:
inc	ecx                 ;make start pos one-biased
push	ecx                 ;pass start pos to MID$
push	esi                 ;push source string
call	mid.d.x             ;get MID$ to do all the work
add	esp,12
mov	esp,ebp
pop	ebp
ret
right_IFC:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall ; Return directly from there
right_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
