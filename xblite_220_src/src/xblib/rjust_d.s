.text
;
; *************************
; *****  %_rjust.d.v  *****  RJUST$(x$, y)
; *****  %_rjust.d.s  *****
; *************************
;
; in:	arg1 = desired width of result string
;	arg0 -> string to right-justify
; out:	eax -> copy of source string, padded with space on left so that it's
;	       arg1 characters long
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, or null to not free anything
;
.globl %_rjust.d.v
%_rjust.d.v:
xor	ebx,ebx                 ;don't free anything on exit
jmp	short rjust.d.x
;
.globl %_rjust.d.s
%_rjust.d.s:
mov	ebx,[esp+4]             ;ebx -> string to free on exit (arg0)
;;
;; fall through
;;
rjust.d.x:
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx             ;store pointer to string to free on exit
cld
mov	esi,[ebp+12]            ;esi = desired length of string
or	esi,esi                   ;zero or less??
jbe	short rjust_null        ;yes: return null string
inc	esi                     ;add one to length for null terminator
call	%____calloc             ;esi -> result string
mov	eax,0                   ;eax = system/user bit
or	eax,0x80130001            ;eax = info word for allocated string
mov	[esi-4],eax             ;store info word
mov	ecx,[ebp+12]            ;ecx = desired length of string
mov	[esi-8],ecx             ;store length
mov	edi,esi                 ;edi -> result string
mov	esi,[ebp+8]             ;esi -> source string
mov	edx,edi                 ;save pointer to result string in edx
xor	ebx,ebx                 ;ebx = length of source string if it's null
or	esi,esi                   ;source string is null pointer?
jz	short rjust_not_null      ;yes: ebx is correct
mov	ebx,[esi-8]             ;ebx = length of source string
rjust_not_null:
cmp	ecx,ebx                 ;desired length no more than current length?
jbe	short rjust_copy_orig   ;yes: just copy part of original string
sub	ecx,ebx                 ;ecx = number of spaces to prepend to string
mov	al,' '                  ;ready to write some spaces
rep
stosb                        ;write them spaces!
mov	ecx,ebx                 ;ecx = length of original string
rjust_copy_orig:
rep
movsb                        ;copy original string
mov	byte ptr [edi],0        ;write null terminator
mov	eax,edx                 ;eax -> result string
rjust_ret:
push	eax                     ;save result
mov	esi,[ebp-4]             ;esi -> string to free
call	%____free
pop	eax                     ;eax -> result
mov	esp,ebp
pop	ebp
ret
;
rjust_null:
xor	eax,eax                 ;return null string
jmp	rjust_ret
