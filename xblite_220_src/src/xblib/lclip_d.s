.text
;
; *************************
; *****  %_lclip.d.v  *****  LCLIP$(x$, y)
; *****  %_lclip.d.s  *****
; *************************
;
; in:	arg1 = number of characters to clip from left of string
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> source string if .s, null if .v
;	[ebp-8] -> result string
;
.globl %_lclip.d.v
%_lclip.d.v:
xor	ebx,ebx               ;must create new string
jmp	short lclip.d.x
;
.globl %_lclip.d.s
%_lclip.d.s:
mov	ebx,[esp+4]           ;ebx -> source string; modify it in place
;;
;; fall through
;;
lclip.d.x:
push	ebp
mov	ebp,esp
sub	esp,8
mov	[ebp-4],ebx           ;store null or pointer to source string
cld
mov	edi,[ebp+8]           ;edi -> source string
or	edi,edi                 ;source string is null pointer?
jz	short lclip_null        ;yes: just return null pointer
mov	ecx,[edi-8]           ;ecx = current length of string
mov	esi,edi               ;esi -> source string
mov	edx,[ebp+12]          ;edx = # of bytes to clip
or	edx,edx                 ;fewer than zero bytes?
js	short lclip_IFC         ;yes: get angry
sub	ecx,edx               ;clipping more (or same #) chars than in string?
                           ;(ecx = number of chars to copy from string)
jbe	short lclip_null      ;yes: just return null pointer
or	ebx,ebx                 ;do we have to create a new string?
jnz	short lclip_copy      ;no: skip creation of new string
lea	esi,[ecx+1]           ;esi = length of result string (+1 for null)
call	%____calloc           ;create result string; esi -> it
mov	eax,0                 ;eax = system/user bit
or	eax,0x80130001          ;eax = info word for allocated string
mov	[esi-4],eax           ;store info word
mov	edi,esi               ;edi -> result string
mov	esi,[ebp+8]           ;esi -> original string
mov	ecx,[esi-8]           ;ecx = original length
mov	edx,[ebp+12]          ;edx = # of bytes to clip
sub	ecx,edx               ;ecx = # of bytes to copy from original string
lclip_copy:
mov	[edi-8],ecx           ;store length of result string
add	esi,edx               ;esi -> where in source string to begin copy
mov	eax,edi               ;eax -> result string
rep
movsb                      ;copy right side of source string
mov	byte ptr [edi],0      ;write null terminator
mov	esp,ebp
pop	ebp
ret
;
lclip_IFC:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall ; Return directly from there
;
lclip_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
