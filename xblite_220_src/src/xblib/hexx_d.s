.text
;
; **********************
; *****  %_hexx.d  *****  converts a ULONG to its hexadecimal representation
; **********************  and prepends \"0x\" to it
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing hex digits
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_hexx.d
%_hexx.d:
push	ebp
lea	ebp,[esp-4]
sub	esp,16
mov	[ebp-8],0x7830        ;tell cvt32 to prepend \"0x\"
mov	[ebp-12],hex.dword    ;convert into hex digits
call	cvt32                 ;eax -> result string
cmp	[eax-8],2             ;length = 2?  I.e. string is nothing but \"0x\"?
jne	short hexx_d_done     ;no: done
mov	byte ptr [eax+2],'0'  ;append \"0\"
mov	[eax-8],3             ;length = 3
hexx_d_done:
lea	esp,[ebp+4]
pop	ebp
ret
