.text
;
; *************************
; *****  %_rclip.d.v  *****  RCLIP$(x$, y)
; *****  %_rclip.d.s  *****
; *************************
;
; in:	arg1 = number of characters to clip off right side of string
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, or null if none
;
.globl %_rclip.d.v
%_rclip.d.v:
xor	ebx,ebx              ;no string to free on exit
jmp	short rclip.d.x
;
.globl %_rclip.d.s
%_rclip.d.s:
mov	ebx,[esp+4]          ;ebx -> source string; modify it in place
;;
;                         ;fall through
;;
rclip.d.x:
push	ebp
mov	ebp,esp
mov	[ebp-4],ebx          ;save pointer to string to free on exit, if any
cld
mov	eax,[ebp+8]          ;eax -> source string
or	eax,eax                ;null pointer?
jz	rclip_null             ;yes: return null string
mov	ecx,[eax-8]          ;ecx = length of source string
mov	edx,[ebp+12]         ;edx = # of chars to clip
or	edx,edx                ;fewer than zero bytes?
js	rclip_IFC              ;yes: get angry
sub	ecx,edx              ;ecx = new length of source string
jbe	rclip_null           ;return null if clipping everything
or	ebx,ebx                ;do we have to create a copy?
jnz	rclip_nocopy         ;no: just write a null and change the length
push	ecx
lea	esi,[ecx+1]          ;esi = length of copy (+ 1 for null terminator)
call	%____calloc          ;esi -> result string
mov	eax,0                ;eax = system/user bit
or	eax,0x80130001         ;eax = info word for allocated string
mov	[esi-4],eax          ;store info word
pop	ecx
mov	[esi-8],ecx          ;store length
mov	edi,esi              ;edi -> result string
mov	eax,esi              ;save it in order to return it
mov	esi,[ebp+8]          ;esi -> source string
rep
movsb                     ;copy left part of source string
mov	byte ptr [edi],0     ;write null terminator
mov	esp,ebp
pop	ebp
ret
rclip_nocopy:
mov	byte ptr [eax+ecx],0 ;write null terminator
mov	[eax-8],ecx          ;write length
mov	esp,ebp
pop	ebp
ret
rclip_IFC:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
call	%_InvalidFunctionCall ; Return directly from there
;
rclip_null:
mov	esi,[ebp-4]           ;esi -> string to free, if any
call	%____free
xor	eax,eax               ;return null pointer
mov	esp,ebp
pop	ebp
ret
