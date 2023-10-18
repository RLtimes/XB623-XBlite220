.text
;
; **************************
; *****  %_stuff.d.vv  *****  STUFF$(x$,y$,i,j)
; *****  %_stuff.d.vs  *****
; *****  %_stuff.d.sv  *****
; *****  %_stuff.d.ss  *****
; **************************
;
; in:	arg3 = # of chars to copy from y$
;	arg2 = start position (one-biased) in x$ at which to start copying
;	arg1 -> y$
;	arg0 -> x$
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> y$ if .vs or .ss routine (if need to free y$ on exit)
;	[ebp-8] -> result string
;	[ebp-12] = start offset (i.e. zero-biased start position)
;
; Creation of result string happens in three phases, after all checking
; for errors and null pointers is done:
;
;    1.  Copy MIN(LEN(x$), start_offset) chars from x$ to result.
;
;    2.  Copy MIN(j, LEN(y$), LEN(x$) - start_offset) chars from y$ to result.
;
;    3.  Copy remaining chars from x$ to result, so result has same length
;        as x$.
;
.globl %_stuff.d.vv
%_stuff.d.vv:
xor	ebx,ebx             ;indicate no need to free y$ on exit
or	eax,1                 ;eax != 0 to indicate x$ cannot be trashed
jmp	short stuff.d.x
;
.globl %_stuff.d.vs
%_stuff.d.vs:
mov	ebx,[esp+8]         ;ebx -> y$; must free y$ on exit
or	eax,1                 ;eax != 0 to indicate x$ cannot be trashed
jmp	short stuff.d.x
;
.globl %_stuff.d.sv
%_stuff.d.sv:
xor	ebx,ebx             ;indicate no need to free y$ on exit
xor	eax,eax             ;eax == 0 to indicate result goes over x$
jmp	short stuff.d.x
;
.globl %_stuff.d.ss
%_stuff.d.ss:
mov	ebx,[esp+8]         ;ebx -> y$; must free y$ on exit
xor	eax,eax             ;eax == 0 to indicate result goes over x$
;;
;                        ;fall through
;;
stuff.d.x:
push	ebp
mov	ebp,esp
sub	esp,12
mov	[ebp-4],ebx         ;save pointer to string to free on exit
cld
mov	edi,[ebp+8]         ;edi -> x$ (string to stuff into)
or	edi,edi               ;null pointer?
jz	stuff_null            ;yes: return null pointer and free y$ if nec.
mov	ecx,[edi-8]         ;ecx = LEN(x$)
mov	edx,[ebp+16]        ;edx = start position (one-biased)
dec	edx                 ;edx = start offset (i.e. zero-biased start pos)
js	stuff_IFC             ;starting before first char is absurd
mov	[ebp-12],edx        ;save start offset
mov	[ebp-8],edi         ;[ebp-8] -> result string if x$ is trashable
or	eax,eax               ;can we trash x$?
jz	short stuff_begin     ;yes: skip code to create new string
lea	esi,[ecx+1]         ;esi = LEN(x$) + 1 for null terminator
call	%____calloc         ;esi -> result string
mov	eax,0               ;eax = system/user bit
or	eax,0x80130001        ;eax = info word for allocated string
mov	[esi-4],eax         ;store info word
mov	[esi-8],ecx         ;store length
mov	[ebp-8],esi         ;[ebp-8] -> result string
stuff_begin:
mov	esi,[ebp+12]        ;esi -> y$ (string to copy from)
or	esi,esi               ;y$ is null pointer?
jz	short stuff_just_copy ;yes: result is same as x$
mov	edi,[ebp-8]         ;edi -> result string
mov	edx,[edi-8]         ;edx = length of result string ( = LEN(x$) )
mov	ebx,[ebp-12]        ;ebx = start offset
mov	ecx,edx             ;ecx = LEN(x$)
xor	edx,edx             ;edx = MAX(LEN(x$) - start offset, 0) if
;                        ;LEN(x$) - start offset < 0
cmp	ecx,ebx             ;LEN(x$) < start offset?
jb	short stuff_skip1     ;yes: copy only LEN(x$) chars in phase 1
mov	edx,ecx
sub	edx,ebx             ;edx = LEN(x$) - start offset
mov	ecx,ebx             ;no: copy up to the start offset
stuff_skip1:
mov	eax,[esi-8]         ;eax = LEN(y$)
cmp	[ebp+20],eax        ;j < LEN(y$)?
ja	short stuff_skip2     ;no: eax = LEN(y$) = MIN(j, LEN(y$))
mov	eax,[ebp+20]        ;eax = j = MIN(j, LEN(y$))
stuff_skip2:
cmp	edx,eax             ;LEN(x$) - start offset < MIN(j, LEN(y$))?
ja	short stuff_skip3     ;no: eax = # of chars to copy in phase 2
mov	eax,edx             ;eax = LEN(x$) - start offset
stuff_skip3:
lea	ebx,[ecx+eax]       ;ebx = # of chars to copy in phases 1 and 2
mov	edx,[edi-8]         ;edx = length of result string
sub	edx,ecx             ;...minus # of chars to copy in phase 1
mov	esi,[ebp+8]         ;esi -> x$
rep
movsb                    ;copy chars for phase 1
mov	ecx,eax             ;ecx = # of chars to copy in phase 2
sub	edx,eax             ;edx = # of chars to copy in phase 3
mov	esi,[ebp+12]        ;esi -> y$
rep
movsb                    ;copy chars for phase 2
mov	ecx,edx             ;ecx = # of chars to copy in phase 3
mov	esi,[ebp+8]         ;esi -> x$
add	esi,ebx             ;esi -> 1st char to copy for phase 3
rep
movsb                    ;copy chars for phase 3
mov	byte ptr [edi],0    ;write null terminator
stuff_exit:
mov	esi,[ebp-4]         ;esi = string to free on exit, if any
call	%____free
mov	eax,[ebp-8]         ;eax -> result string
mov	esp,ebp
pop	ebp
ret
stuff_just_copy:         ;result will be exactly the same as x$
mov	edi,[ebp-8]         ;edi -> result string
mov	esi,[ebp+8]         ;esi -> x$
cmp	edi,esi             ;result string is x$?
je	stuff_exit            ;yes: then copy is already made
mov	ecx,[esi-8]         ;ecx = LEN(x$)
rep
movsb                    ;copy x$ to result string
mov	byte ptr [edi],0    ;write null terminator
jmp	stuff_exit
stuff_IFC:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall ; Return directly from there
stuff_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
