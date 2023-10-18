.text
;
; *************************
; *****  %_cjust.d.v  *****
; *****  %_cjust.d.s  *****
; *************************
;
; in:	arg1 = desired length
;	arg0 -> string to center
; out:	eax -> centered version of string at arg0
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, or null if nothing to free
;	[ebp-8] -> result string
;
.globl %_cjust.d.v
%_cjust.d.v:
xor	ebx,ebx               ;no string to free on exit
jmp	short cjust.d.x
;
.globl %_cjust.d.s
%_cjust.d.s:
mov	ebx,[esp+4]           ;ebx -> string to free on exit (arg0)
;;
;; fall through
;;
cjust.d.x:
push	ebp
mov	ebp,esp
sub	esp,8
mov	[ebp-4],ebx           ;save pointer to string to free on exit
cld
mov	esi,[ebp+12]          ;esi = desired length of string
or	esi,esi                 ;zero or less??
jbe	cjust_null            ;yes: return null string
inc	esi                   ;add one to length for null terminator
call	%____calloc           ;esi -> result string
mov	eax,0                 ;eax = system/user bit
or	eax,0x80130001          ;eax = info word for allocated string
mov	[esi-4],eax           ;store info word
mov	ecx,[ebp+12]          ;ecx = desired length of string
mov	[esi-8],ecx           ;store length
mov	edi,esi               ;edi -> result string
mov	esi,[ebp+8]           ;esi -> source string
mov	[ebp-8],edi           ;save pointer to result string
xor	ebx,ebx               ;ebx = length of source string if it's null
or	esi,esi                 ;source string is null pointer?
jz	short cjust_not_null    ;yes: ebx is correct
mov	ebx,[esi-8]           ;ebx = length of source string
cjust_not_null:
cmp	ecx,ebx               ;desired length no more than original length?
jbe	short cjust_copy_only ;yes: pad no spaces on either side
mov	edx,ecx               ;save desired length in edx
sub	ecx,ebx               ;ecx = desired length - original length
slr	ecx,1                 ;ecx = # of spaces to add on left
lea	eax,[ecx+ebx]         ;eax = left spaces + original length
sub	edx,eax               ;edx = # of spaces to add on right
mov	al,' '                ;ready to write some spaces
rep
stosb                      ;store spaces on left side of string
mov	ecx,ebx               ;ecx = length of original string
rep
movsb                      ;copy original string
mov	ecx,edx               ;ecx = # of spaces to add on right
rep
stosb                      ;store spaces on right side of string
cjust_exit:
mov	byte ptr [edi],0      ;write null terminator
mov	esi,[ebp-4]           ;ebx -> string to free, if any
call	%____free
mov	eax,[ebp-8]           ;eax -> result string
mov	esp,ebp
pop	ebp
ret
cjust_copy_only:
rep
movsb                      ;copy source string to result string
jmp	short cjust_exit
;
cjust_ret:
push	eax                   ;save result
mov	esi,[ebp-4]           ;esi -> string to free
call	%____free
pop	eax                   ;eax -> result
mov	esp,ebp
pop	ebp
ret
;
cjust_null:
xor	eax,eax               ;return null string
jmp	cjust_ret
