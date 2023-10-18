.text
;
; ***********************
; *****  %_mid.d.v  *****  MID$(x$,y,z)
; *****  %_mid.d.s  *****
; ***********************
;
; in:	arg2 = number of characters to put in result string
;	arg1 = start position at which to begin copying (first position is \"1\")
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;	[ebp-8] -> result string
;	[ebp-12] = min(LEN(source$) - startoffset + 1, substring_len)
;		 = length of result string
;
.globl %_mid.d.v
%_mid.d.v:
xor	ebx,ebx              ;create a new string to hold result
jmp	short mid.d.x
;
.globl %_mid.d.s
%_mid.d.s:
mov	ebx,[esp+4]          ;store result string on top of source string
;;
;                         ;fall through
;;
.globl mid.d.x
mid.d.x:                  ;general entry point for various string-reducers
push	ebp                  ;requires that ebx be set as if MID$ were
mov	ebp,esp              ;called from one of the above two entry points
sub	esp,12
mov	[ebp-4],ebx          ;save pointer to string to free on exit, if any
cld
mov	esi,[ebp+8]          ;esi -> source string
or	esi,esi                ;null pointer?
jz	mid_null               ;yes: return null pointer
mov	edx,[esi-8]          ;edx = length of source string
or	edx,edx                ;zero?
jz	mid_null               ;yes: can't take much of a substring from that
mov	eax,[ebp+12]         ;eax = start position (one-biased)
dec	eax                  ;eax = true start position
js	mid_IFC                ;less than zero is error
mov	ecx,[ebp+16]         ;ecx = length of substring
or	ecx,ecx
jz	mid_null               ;if zero, return null pointer
jb	mid_IFC                ;if less than zero, error
cmp	eax,edx              ;start position >= length?
jae	mid_null             ;yes: return null pointer
mov	ebx,edx              ;ebx = source len
sub	ebx,eax              ;ebx = source len - start pos
cmp	ecx,ebx              ;substring len greater than possible?
jbe	short mid_skip2      ;no: ecx already contains true length of result
mov	ecx,ebx              ;shorten ecx to true length of result
mid_skip2:
mov	[ebp-12],ecx         ;save length of result
cmp	[ebp-4],0            ;can we trash the source string?
jz	short mid_no_trash     ;no: have to make a copy
mov	edi,esi              ;yes: point destination at source
jmp	short mid_go         ;now finally get started
mid_no_trash:             ;destination is new string
lea	esi,[ecx+1]          ;esi = result length (+1 for null terminator)
call	%____calloc          ;esi -> result string; all others trashed
mov	eax,0                ;eax = system/user bit
or	eax,0x80130001         ;eax = info word for allocated string
mov	[esi-4],eax          ;store info word
mov	edi,esi              ;edi -> result string
mov	esi,[ebp+8]          ;esi -> source string
mov	eax,[ebp+12]         ;eax = start position
dec	eax                  ;eax = true start position
mov	ecx,[ebp-12]         ;ecx = length of substring
;eax = start position (zero-biased), known to be >= 0
;ecx = length of substring, known to be > 0 and known not to go off the end
;of the source string
;esi -> source string
;edi -> result string
mid_go:
mov	[ebp-8],edi          ;save pointer to result string
or	eax,eax                ;start position is start of source string?
jnz	short mid_start_nonzero ;no: will have to move the substring
cmp	[ebp-4],0            ;we're trashing the source string?
jnz	short mid_write_terminator ;yes: just write null into it
mid_copy:
rep
movsb                     ;copy source string to destination
mid_write_terminator:
mov	eax,[ebp-8]          ;eax -> result string
mov	ecx,[ebp-12]         ;ecx = length of substring = length of result
mov	[eax-8],ecx          ;write length of result string
mov	byte ptr [eax+ecx],0 ;write null terminator
mov	esp,ebp
pop	ebp
ret
mid_start_nonzero:
add	esi,eax              ;esi -> first character in source to copy
jmp	mid_copy
mid_IFC:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall ; Return directly from there
;
mid_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
