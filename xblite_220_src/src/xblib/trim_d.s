.text
;
; ************************
; *****  %_trim.d.v  *****  TRIM$(x$)
; *****  %_trim.d.s  *****
; ************************
;
; in:	arg0 -> string to trim of leading and trailing chars <= 0x20 and >= 0x7F
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;
.globl %_trim.d.v
%_trim.d.v:
xor	ebx,ebx               ;must create new string to hold result
jmp	short trim.d.x
;
.globl %_trim.d.s
%_trim.d.s:
mov	ebx,[esp+4]           ;store result on top of source string
;;
;                          ;fall through
;;
trim.d.x:
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx           ;save string to free on exit, if any
cld
mov	esi,[ebp+8]           ;esi -> source string
or	esi,esi                 ;a null pointer?
jz	trim_null               ;yes: return null pointer
mov	edi,esi               ;save pointer to source string
xor	ebx,ebx               ;ebx = start position for MID$ = 0
mov	ecx,[esi-8]           ;ecx = length of source string
trim_left_loop:
jecxz	trim_null           ;entire string is trimmed away: return null
inc	ebx                   ;bump start position
dec	ecx                   ;bump length counter
lodsb                      ;get next character
cmp	al,' '                ;space or lower?
jbe	trim_left_loop        ;yes: trim it
cmp	al,0x7F               ;DEL or higher?
jae	trim_left_loop        ;yes: trim it
dec	esi                   ;esi -> first non-trimmed character
mov	eax,[edi-8]           ;eax = original length of string
add	edi,eax               ;edi -> char after last char in string
trim_right_loop:           ;in this loop, we start at the end of the
;                          ;string and search backwards for a
;                          ;non-trimmable character
dec	edi                   ;edi -> next character
mov	al,[edi]              ;al = next character
cmp	al,' '                ;space or lower?
jbe	trim_right_loop       ;yes: trim it
cmp	al,0x7F               ;DEL or higher?
jae	trim_right_loop       ;yes: trim it
;                          ;if fell through, edi -> last non-trimmed char
inc	edi
sub	edi,esi               ;edi = length of result string
push	edi                   ;push length of substring
push	ebx                   ;push start position
push	[ebp+8]               ;push pointer to source string
mov	ebx,[ebp-4]           ;ebx indicates whether source is trashable
call	mid.d.x               ;let MID$ do all the work
add	esp,12
mov	esp,ebp
pop	ebp
ret
trim_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
