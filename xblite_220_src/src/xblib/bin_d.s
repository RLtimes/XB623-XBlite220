.text
;
; *********************
; *****  %_bin.d  *****  converts a ULONG to its binary representation
; *********************
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing binary digits
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_bin.d
%_bin.d:
push	ebp
lea	ebp,[esp-4]
sub	esp,16
mov	[ebp-8],0           ;tell cvt32 to not prepend anything
mov	[ebp-12],bin.dword  ;convert into binary digits
call	cvt32               ;eax -> result string
cmp	[eax-8],0           ;zero-length string?
jnz	short bin_d_done    ;no: done
mov	byte ptr [eax],'0'  ;create a \"0\" string
mov	[eax-8],1           ;length is 1
bin_d_done:
lea	esp,[ebp+4]
pop	ebp
ret
