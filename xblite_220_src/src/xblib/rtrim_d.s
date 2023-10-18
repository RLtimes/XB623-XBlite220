.text
;
; *************************
; *****  %_rtrim.d.v  *****  RTRIM$(x$)
; *****  %_rtrim.d.s  *****
; *************************
;
; in:	arg0 -> source string
; out:	eax -> string trimmed of all trailing spaces and unprintable
;	       characters (i.e. bytes <= 0x20 and >= 0x7F)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;	[ebp-8] -> length of result string
;
.globl %_rtrim.d.v
%_rtrim.d.v:
xor	ebx,ebx                 ;must create new string to hold result
jmp	short rtrim.d.x
;
.globl %_rtrim.d.s
%_rtrim.d.s:
mov	ebx,[esp+4]             ;free source string if we free anything
;;
;; fall through              ; and store result on top of source
;;
rtrim.d.x:
push	ebp
mov	ebp,esp
sub	esp,8
mov	[ebp-4],ebx             ;save string to free on exit, if any
cld
mov	esi,[ebp+8]             ;esi -> source string
or	esi,esi                   ;a null pointer?
jz	rtrim_null                ;yes: return null pointer
mov	ecx,[esi-8]             ;ecx = length of source string
lea	edi,[esi+ecx]           ;edi -> char after last char in source strin
inc	ecx                     ;cancel out DEC ECX at beginning of loop
rtrim_loop:                  ;start at end of string and work backwards,
;                            ;searching for first non-trimmable char;
dec	edi                     ;bump pointer into source string
dec	ecx                     ;ecx = length of result string
jz	rtrim_null                ;if nothing left, return null pointer
mov	al,[edi]                ;al = next character
cmp	al,' '                  ;space or less?
jbe	rtrim_loop              ;yes: keep looping
cmp	al,0x7F                 ;DEL or above?
jae	rtrim_loop
;ecx = length of result string
;edi -> last char before trimmable chars
inc	edi                     ;edi -> first char to trim
mov	eax,[ebp+8]             ;eax -> result string, if no copy
or	ebx,ebx                   ;do we need to create a copy?
jnz	short rtrim_terminator  ;no: just stick in null terminator
mov	[ebp-8],ecx             ;save length of result string
mov	esi,ecx                 ;esi = length of result string
inc	esi                     ;plus one for null terminator
call	%____calloc             ;esi -> result string
mov	eax,0                   ;eax = system/user bit
or	eax,0x80130001            ;eax = info word for allocated string
mov	[esi-4],eax             ;store info word
mov	ecx,[ebp-8]             ;ecx = length of result string
mov	edi,esi                 ;edi -> result string
mov	esi,[ebp+8]             ;esi -> source string
mov	eax,edi                 ;eax -> result string (save it)
rep
movsb                        ;copy source string up to trimmed section
mov	ecx,[ebp-8]             ;ecx = length of result string
rtrim_terminator:
mov	[eax-8],ecx             ;store length of result string
mov	byte ptr [edi],0        ;write null terminator
mov	esp,ebp
pop	ebp
ret
;
rtrim_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
