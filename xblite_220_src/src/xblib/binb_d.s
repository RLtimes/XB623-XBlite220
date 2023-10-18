.text
;
; **********************
; *****  %_binb.d  *****  converts a ULONG to its binary representation
; **********************  and prepends \"0b\" to it
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing binary digits
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_binb.d
%_binb.d:
push	ebp
lea	ebp,[esp-4]
sub	esp,16
mov	[ebp-8],0x6230         ;tell cvt32 to prepend \"0b\"
mov	[ebp-12],bin.dword     ;convert into binary digits
call	cvt32                  ;eax -> result string
cmp	[eax-8],2              ;length = 2?  I.e. string is nothing but \"0b\"?
jne	short binb_d_done      ;no: done
mov	byte ptr [eax+2],'0'   ;append \"0\"
mov	[eax-8],3              ;length = 3
binb_d_done:
lea	esp,[ebp+4]
pop	ebp
ret
