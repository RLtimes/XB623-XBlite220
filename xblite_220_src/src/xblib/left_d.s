.text
;
; ************************
; *****  %_left.d.v  *****  LEFT$(x$,y)
; *****  %_left.d.s  *****
; ************************
;
; in:	arg1 = number of characters to peel off left
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, di
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;
.globl %_left.d.v
%_left.d.v:
xor	ebx,ebx            ;must create new string to hold result
jmp	short left.d.x
;
.globl %_left.d.s
%_left.d.s:
mov	ebx,[esp+4]        ;put result on top of source string
;;
;                       ;fall through
;;
left.d.x:
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx        ;save string to free on exit, if any
mov	esi,[ebp+8]        ;esi -> source string
or	esi,esi              ;null pointer?
jz	left_null            ;yes: return null pointer
mov	ecx,[ebp+12]       ;ecx = # of chars to peel off
jecxz	left_null        ;nothing to do if no chars requested
push	ecx                ;push number of chars requested
push	1                  ;push start position (always at left of string)
push	esi                ;push pointer to source string
call	mid.d.x            ;let MID$ do all the work
add	esp,12
mov	esp,ebp
pop	ebp
ret
left_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
