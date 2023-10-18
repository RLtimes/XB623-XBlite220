.text
;
; *********************
; *****  %_chr.d  *****  CHR$(x, y)
; *********************
;
; in:	arg1 = number of times to duplicate it
;	arg0 = ASCII code to duplicate
; out:	eax -> generated string
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_chr.d
%_chr.d:
push	ebp
mov	ebp,esp
mov	esi,[ebp+12]        ;esi = # of times to duplicate char
or	esi,esi               ;set flags
jz	short chr_null        ;if zero, just return null pointer
js	short chr_IFC         ;if less than zero, generate an error
mov	ebx,[ebp+8]         ;ebx = char to duplicate
test	ebx,0xFFFFFF00      ;greater than 255?
jnz	short chr_IFC       ;yes: generate error
inc	esi                 ;esi = # of chars needed to hold string,
                         ; including null terminator
call	%____calloc         ;esi -> result string
mov	ecx,[ebp+12]        ;ecx = # of times to duplicate it
mov	edi,esi             ;edi -> result string
mov	[esi-8],ecx         ;store length of string
mov	eax,0               ;eax = system/user bit
or	eax,0x80130001        ;eax = system/user bit OR allocated-string info
mov	[esi-4],eax         ;store info word
cld
mov	al,[ebp+8]          ;al = char to duplicate
rep
stosb                    ;write them character!
mov	eax,esi             ;eax -> result string
mov	esp,ebp
pop	ebp
ret
chr_IFC:
xor	eax,eax             ;return null pointer
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall	; Return from there
chr_null:
xor	eax,eax             ;return null pointer
mov	esp,ebp
pop	ebp
ret
