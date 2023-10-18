.text
;
; *********************
; *****  %_oct.d  *****  converts a ULONG to its octal representation
; *********************
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing octal digits
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_oct.d
%_oct.d:
push	ebp
lea	ebp,[esp-4]
sub	esp,16
mov	[ebp-8],0               ;tell cvt32 to not prepend anything
mov	[ebp-12],oct.dword      ;convert into octal digits
mov	[oct_shift],oct_lsd_64  ;we're only converting one dword
mov	[oct_first],0           ;no extra bit to OR into first digit
call	cvt32                   ;eax -> result string
cmp	[eax-8],0               ;zero-length string?
jnz	short oct_d_done        ;no: done
mov	byte ptr [eax],'0'      ;create a \"0\" string
mov	[eax-8],1               ;length is 1
oct_d_done:
lea	esp,[ebp+4]
pop	ebp
ret
