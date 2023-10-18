.text
;
; **********************
; *****  %_null.d  *****  NULL$(x)
; **********************
;
; in:	arg0 = number of nulls to put in result string
; out:	eax -> string containing requested number of nulls
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_null.d
%_null.d:
push	ebp
mov	ebp,esp
mov	esi,[ebp+8]        ;esi = # of times to duplicate char
or	esi,esi              ;set flags
jz	short null_null      ;if zero, just return null pointer
js	short null_IFC       ;if less than zero, generate an error
inc	esi                ;one more for null terminator, ha ha
call	%____calloc        ;esi -> result string
mov	eax,[ebp+8]        ;eax = requested number of nulls
mov	[esi-8],eax        ;write length of result string
mov	eax,0              ;eax = system/user bit
or	eax,0x80130001       ;eax = system/user bit OR allocated-string info
mov	[esi-4],eax        ;write info word
mov	eax,esi            ;eax -> result string
mov	esp,ebp
pop	ebp
ret
null_null:
xor	eax,eax            ;return null pointer
mov	esp,ebp
pop	ebp
ret
null_IFC:
xor	eax,eax            ;return null pointer
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall ;Return from there
