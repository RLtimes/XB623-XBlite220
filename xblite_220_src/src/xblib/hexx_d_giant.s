.text
;
; ****************************
; *****  %_hexx.d.giant  *****  converts a giant to hexadecimal string
; ****************************  and prepend \"0x\"
;
; in:	arg2 = minimum number of digits
;	arg1 = most significant dword of number to convert
;	arg0 = least significant dword of number to convert
; out:	eax -> string containing hex digits
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_hexx.d.giant
%_hexx.d.giant:
push	ebp
mov	ebp,esp
sub	esp,12
mov	[ebp-8],0x7830          ;tell cvt32 to prepend \"0x\"
mov	[ebp-12],hex.dword      ;convert into hex digits
mov	eax,[ebp+16]            ;eax = requested number of digits
mov	[sn_save],eax           ;save eax someplace safe
mov	[ebp+16],0              ;print nothing if asked for <= 8 digits
cmp	eax,8                   ;requested more than 8 digits?
jbe	short hexxg_msdword     ;no: no change
sub	eax,8                   ;yes: indicate # of digits in ms dword
mov	[ebp+16],eax
hexxg_msdword:
call	cvt32                   ;convert most significant dword
;eax -> result string
mov	ebx,[eax-8]             ;ebx = length of string so far
lea	edi,[eax+ebx]           ;edi -> where to place second dword's digits
mov	esi,[sn_save]           ;esi = minimum number of digits
mov	edx,[ebp+8]             ;edx = least significant dword
mov	[sn_save],eax           ;save eax someplace safe
cmp	ebx,2                   ;any digits written to string?
jz	hexxg_lsdword             ;no: skip
mov	esi,127                 ;yes: do not suppress leading zeros
hexxg_lsdword:
call	hex.dword               ;append second dword's hex digits to first's
mov	eax,[sn_save]           ;eax -> result string
sub	edi,eax                 ;edi = total length of string
cmp	edi,2                   ;any digits written to string?
jnz	hexxg_done              ;if length is non-zero, done
mov	[eax+2],'0'             ;generate a \"0\" string
inc	edi                     ;length = 3
hexxg_done:
mov	[eax-8],edi             ;write length of string
mov	esp,ebp
pop	ebp
ret
