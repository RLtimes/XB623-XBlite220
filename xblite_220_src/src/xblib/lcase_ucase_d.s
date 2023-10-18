.text
;
; *************************
; *****  %_lcase.d.s  *****  LCASE$(x$) and UCASE$(x$)
; *****  %_lcase.d.v  *****
; *****  %_ucase.d.s  *****
; *****  %_ucase.d.v  *****
; *************************
;
; in:	arg0 - > string to convert
; out:	eax -> converted string
;
; destroys: ebx, ecx, edx, esi, edi
;
; .s routines convert string at arg0
; .v routines create a new string.
;
.globl %_lcase.d.s
%_lcase.d.s:
mov	ebx,%_uctolc        ;ebx -> table to convert to lower case
jmp	short xcase.d.s     ;branch to common routine
;
.globl %_ucase.d.s
%_ucase.d.s:
mov	ebx,%_lctouc        ;ebx -> table to convert to upper case
;                        ;fall through
xcase.d.s:
mov	esi,[esp+4]         ;esi -> string to convert
cld
or	esi,esi               ;null pointer?
jz	short xcase_ret       ;yes: nothing to do
mov	ecx,[esi-8]         ;ecx = length of input string
mov	edi,esi             ;edi -> input string, which is also output string
xcase_d_s_loop:
jecxz	xcase_ret         ;quit loop if reached last character
lodsb                    ;get next char
xlatb                    ;convert char
stosb                    ;store it
dec	ecx                 ;bump character counter
jmp	xcase_d_s_loop      ;do next character
xcase_ret:
mov	eax,[esp+4]
ret
;
;
.globl %_lcase.d.v
%_lcase.d.v:
mov	ebx,%_uctolc        ;ebx -> table to convert upper to lower
jmp	short xcase.d.v     ;branch to common routine
;
.globl %_ucase.d.v
%_ucase.d.v:
mov	ebx,%_lctouc        ;ebx -> table to convert to upper case
;;
;                        ;fall through
;;
xcase.d.v:
mov	esi,[esp+4]         ;esi -> string to convert
or	esi,esi               ;null pointer?
jz	short xcase_ret       ;yes: nothing to do
push	ebx                 ;save pointer to translation table
mov	esi,[esi-8]         ;esi = length of result string
inc	esi                 ;add one for null terminator
call	%____calloc         ;esi -> result string
mov	eax,0               ;eax = system/user bit
or	eax,0x80130001        ;eax = info word for allocated string
mov	[esi-4],eax         ;store info word
pop	ebx                 ;ebx -> translation table
mov	edi,esi             ;edi -> result string
mov	edx,esi             ;save pointer so we can return it later
mov	esi,[esp+4]         ;esi -> source string
mov	ecx,[esi-8]         ;ecx = length of source string
mov	[edi-8],ecx         ;store length into result string
xcase_d_v_loop:
jecxz	xcase_d_v_ret     ;exit loop if all characters have been copied
lodsb                    ;fetch character from source string
xlatb                    ;convert its case
stosb                    ;store character to result string
dec	ecx                 ;bump character counter
jmp	xcase_d_v_loop      ;do next character
xcase_d_v_ret:
mov	byte ptr [edi],0    ;write null terminator
mov	eax,edx             ;eax -> result string
ret
