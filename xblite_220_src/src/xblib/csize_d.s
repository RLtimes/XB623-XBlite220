.text
;
; *************************
; *****  %_csize.d.v  *****  CSIZE$(x$)
; *****  %_csize.d.s  *****
; *************************
;
; in:	arg0 -> source string
; out:	eax -> copy of source string, truncated at first null
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit
;
.globl %_csize.d.v
%_csize.d.v:
xor	ebx,ebx                ;nothing to free on exit
jmp	short csize.d.x
;
.globl %_csize.d.s
%_csize.d.s:
mov	ebx,[esp+4]            ;ebx -> string to free on exit
;;
;                           ;fall through
;;
csize.d.x:
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx            ;save pointer to string to free on exit
cld
mov	esi,[ebp+8]            ;esi -> source string
or	esi,esi                  ;null pointer?
jz	short csize_null         ;yes: nothing to do
mov	esi,[esi-8]            ;esi = length of source string
inc	esi                    ;one more for terminating null
call	%____calloc            ;allocate space for copy
;                           ;esi -> result string
mov	eax,0                  ;eax = system/user bit
or	eax,0x80130001           ;eax = info word for allocated string
mov	[esi-4],eax            ;store info word
mov	edi,esi                ;edi -> result string
mov	ebx,edi                ;save it
mov	esi,[ebp+8]            ;esi -> source string
xor	edx,edx                ;edx = length counter = 0
csize_loop:
lodsb                       ;al = next character
or	al,al                    ;found the null?
jz	short csize_done         ;yes: nothing left to copy
stosb                       ;no: write character to result string
inc	edx                    ;bump length counter
jmp	csize_loop
csize_done:
mov	[ebx-8],edx            ;store length of result string
push	ebx                    ;save pointer to result string
mov	esi,[ebp-4]            ;esi -> string to free on exit
call	%____free              ;free it
pop	eax                    ;eax -> result string
mov	esp,ebp
pop	ebp
ret
csize_null:                ;create a string with nothing but a null in it
inc	esi                   ;esi = bytes needed for string = 1
call	%____calloc           ;esi -> result string
mov	eax,0                 ;eax = system/user bit
or	eax,0x80130001          ;eax = info word for allocated string
mov	[esi-4],eax           ;store info word
mov	[esi-8],0             ;store length
;                          ;we got passed a null pointer, so there can
mov	eax,esi               ; be nothing to free
mov	esp,ebp               ;eax -> result string
pop	ebp
ret
