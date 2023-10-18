.text
;
; **********************
; *****  %_octo.d  *****  converts a ULONG to its octal representation
; **********************  and prepends \"0o\" to it
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing octal digits
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_octo.d
%_octo.d:
push	ebp
lea	ebp,[esp-4]
sub	esp,16
mov	[ebp-8],0x6F30             ;tell cvt32 to prepend \"0o\"
mov	[ebp-12],oct.dword         ;convert into octal digits
mov	[oct_shift],oct_lsd_64     ;we're only converting one dword
mov	[oct_first],0              ;no extra bit to OR into first digit
call	cvt32                      ;eax -> result string
cmp	[eax-8],2                  ;length = 2?  I.e. string is nothing but \"0o\"?
jne	short octo_d_done          ;no: done
mov	byte ptr [eax+2],'0'       ;append \"0\"
mov	[eax-8],3                  ;length = 3
octo_d_done:
lea	esp,[ebp+4]
pop	ebp
ret
