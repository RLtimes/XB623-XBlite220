.text
;
; *************************
; *****  %_cstring.d  *****  CSTRING$(x$)
; *************************
;
; in:	arg0 -> string with no header info
; out:	eax -> copy of same string, with header info
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] = length of source string
;
; Result string's length is the number of non-null characters in the source
; string up to the first null.  Characters in the source string beyond the
; first null are not copied to the result string.
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_cstring.d
%_cstring.d:
push	ebp
mov	ebp,esp
sub	esp,4
;
mov	edi,[ebp+8]           ;edi -> C string
or	edi,edi                 ;null pointer?
jz	short cstring_null      ;yes: return null pointer
;
movzx	eax, byte ptr [edi] ;first byte = 0x00 ???
or	eax,eax                 ;test eax for zero
jz	short cstring_null      ;first byte = 0x00 = empty string
;
mov	ecx,-1                ;search until we find zero byte or cause memory fault
xor	eax,eax               ;search for a zero byte
cld                        ;make sure we're going in the right direction
repne
scasb                      ;edi -> terminating null
;
not	ecx                   ;ecx = length + 1
mov	[ebp-4],ecx           ;save it
mov	esi,ecx               ;esi = length + 1 = size of copy
call	%____calloc           ;esi -> result string, w/ enough space for copy
;
mov	ecx,[ebp-4]           ;ecx = length + 1
lea	ebx,[ecx-1]           ;ebx = length not including terminating null
mov	[esi-8],ebx           ;store length
mov	eax,0                 ;eax = system/user bit
or	eax,0x80130001          ;eax = system/user bit OR allocated-string info
mov	[esi-4],eax           ;write info word
;
mov	eax,esi               ;eax -> result string
mov	esi,[ebp+8]           ;esi -> source string
mov	edi,eax               ;edi -> result string
rep
movsb                      ;copy source string to result string
;
mov	esp,ebp
pop	ebp
ret
;
cstring_null:
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
