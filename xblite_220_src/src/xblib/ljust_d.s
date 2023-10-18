.text
;
; *************************
; *****  %_ljust.d.v  *****  LJUST$(x$, y)
; *****  %_ljust.d.s  *****
; *************************
;
; in:	arg1 = desired length
;	arg0 -> string to left-justify
; out:	eax -> copy of source string, padded with space on right so that it's
;	       arg1 characters long
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, or null to not free anything
;
.globl %_ljust.d.v
%_ljust.d.v:
xor	ebx,ebx		;don't free anything on exit
jmp	short ljust.d.x
;
.globl %_ljust.d.s
%_ljust.d.s:
mov	ebx,[esp+4]                ;ebx -> string to free on exit
;;
;                               ;fall through
;;
ljust.d.x:
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx                ;save pointer to string to free on exit
cld
mov	esi,[ebp+12]               ;esi = desired length of string
or	esi,esi                      ;zero or less??
jbe	short ljust_null           ;yes: return null string
inc	esi                        ;add one to length for null terminator
call	%____calloc                ;esi -> result string
mov	eax,0                      ;eax = system/user bit
or	eax,0x80130001               ;eax = info word for allocated string
mov	[esi-4],eax                ;store info word
mov	ebx,[ebp+12]               ;ebx = desired length of string
mov	[esi-8],ebx                ;store length
mov	edi,esi                    ;edi -> result string
mov	esi,[ebp+8]                ;esi -> source string
mov	edx,edi                    ;save pointer to result string in edx
or	esi,esi                      ;source string is null pointer?
jz	short ljust_spaces           ;yes: create nothing but spaces
mov	ecx,[esi-8]                ;ecx = length of source string
ljust_not_null:
xor	eax,eax                    ;eax = 0 to flag need to append spaces
cmp	ebx,ecx                    ;desired length greater than current length?
ja	short ljust_copy             ;no: skip
mov	ecx,ebx                    ;copy only desired-length characters
inc	eax                        ;eax != 0 to indicate no need to append spaces
ljust_copy:
rep
movsb                           ;copy source string to result string
or	eax,eax                      ;need to append spaces?
jnz	short ljust_done           ;nope
mov	esi,[ebp+8]                ;esi -> source string
sub	ebx,[esi-8]                ;ebx = desired - current = # of spaces to add
ljust_spaces:
mov	ecx,ebx                    ;counter register = # of spaces to add
mov	al,' '                     ;ready to write spaces
rep
stosb                           ;write them spaces!
ljust_done:
mov	byte ptr [edi],0           ;append null terminator
push	edx                        ;save pointer to result string
mov	esi,[ebp-4]                ;esi -> string to free, if any
call	%____free
pop	eax                        ;return result pointer in eax
mov	esp,ebp
pop	ebp
ret
ljust_ret:
push	eax                        ;save result
mov	esi,[ebp-4]                ;esi -> string to free
call	%____free
pop	eax                        ;eax -> result
mov	esp,ebp
pop	ebp
ret
;
ljust_null:
xor	eax,eax                    ;return null string
jmp	ljust_ret
