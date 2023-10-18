.text
;
; *************************
; *****  %_ltrim.d.v  *****  LTRIM$(x$)
; *****  %_ltrim.d.s  *****
; *************************
;
; in:	arg0 -> source string
; out:	eax -> string trimmed of all leading spaces and unprintable
;	       characters (i.e. bytes <= 0x20 and >= 0x7F)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;
.globl %_ltrim.d.v
%_ltrim.d.v:
xor	ebx,ebx                ;must create copy to hold result
jmp	short ltrim.d.x
;
.globl %_ltrim.d.s
%_ltrim.d.s:
mov	ebx,[esp+4]            ;store result on top of source string
;;
;                           ;fall through
;;
ltrim.d.x:
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx            ;save pointer to string to free on exit, if any
cld
mov	esi,[ebp+8]            ;esi -> source string
or	esi,esi                  ;null pointer?
jz	ltrim_null               ;yes: outta here
mov	ecx,[esi-8]            ;ecx = length of source string
inc	ecx                    ;prepare for loop (cancel out initial DEC ECX)
dec	esi                    ;cancel out initial INC ESI
ltrim_loop:                 ;decide where in source string to begin copying
dec	ecx                    ;ecx = number of chars left in source string
jz	ltrim_null               ;if none left, return null pointer
inc	esi
mov	al,[esi]               ;al = next character from string
cmp	al,' '                 ;space or less?
jbe	ltrim_loop             ;yes: skip this character
cmp	al,0x7F                ;DEL or has high bit set?
jae	ltrim_loop             ;yes: skip this character
;                           ;no: exit loop
ltrim_loop_done:
or	ebx,ebx                  ;do we have to make a new string to hold result?
jnz	short ltrim_just_copy  ;no: skip straight to copy routine
push	esi
push	ecx
lea	esi,[ecx+1]            ;esi = length of result (+1 for null terminator)
call	%____calloc            ;esi -> result string
mov	eax,0                  ;eax = system/user bit
or	eax,0x80130001           ;eax = info word for allocated string
mov	[esi-4],eax            ;store info word
pop	ecx                    ;ecx = new length
mov	edi,esi                ;edi -> result string
pop	esi                    ;esi -> first non-trimmed char in source string
ltrim_copy:
mov	[edi-8],ecx            ;store length of result string
mov	eax,edi                ;eax -> result string
rep
movsb                       ;copy non-trimmed section
mov	byte ptr [edi],0       ;write null terminator
mov	esp,ebp
pop	ebp
ret
ltrim_just_copy:            ;no need to allocate new string
mov	edi,[ebp+8]            ;edi -> source string, which is also result str
cmp	esi,edi                ;nothing is being trimmed?
jne	ltrim_copy             ;no: go move non-trimmed part on top of trimmed
;                           ;part
mov	eax,esi                ;yes, nothing is being trimmed: nothing to do
mov	esp,ebp                ;return result in eax
pop	ebp
ret
;
ltrim_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
