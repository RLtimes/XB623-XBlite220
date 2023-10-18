.text
;
; ***************************
; *****  %_bin.d.giant  *****  converts a giant to binary string
; ***************************
;
; in:	arg2 = minimum number of digits
;	arg1 = most significant dword of number to convert
;	arg0 = least significant dword of number to convert
; out:	eax -> string containing binary digits
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_bin.d.giant
%_bin.d.giant:
push	ebp
mov	ebp,esp
sub	esp,12
mov	[ebp-8],0           ;tell cvt32 to not prepend anything
mov	[ebp-12],bin.dword  ;convert into binary digits
mov	eax,[ebp+16]        ;eax = requested number of digits
mov	[sn_save],eax       ;save eax someplace safe
mov	[ebp+16],0          ;print nothing if asked for <= 32 digits
cmp	eax,32              ;requested more than 32 digits?
jbe	short bing_msdword  ;no: no change
sub	eax,32              ;yes: indicate # of digits in ms dword
mov	[ebp+16],eax
bing_msdword:
call	cvt32               ;convert most significant dword
;eax -> result string
mov	ebx,[eax-8]         ;ebx = length of string so far
lea	edi,[eax+ebx]       ;edi -> where to place second dword's digits
mov	esi,[sn_save]       ;esi = minimum number of digits
mov	edx,[ebp+8]         ;edx = least significant dword
mov	[sn_save],eax       ;save eax someplace safe
or	ebx,ebx               ;anything written to string?
jz	bing_lsdword          ;no: skip
mov	esi,127             ;yes: do not suppress leading zeros
bing_lsdword:
call	bin.dword           ;append second dword's binary digits to first's
mov	eax,[sn_save]       ;eax -> result string
sub	edi,eax             ;edi = total length of string
jnz	bing_done           ;if length is non-zero, done
mov	[eax],'0'           ;generate a \"0\" string
inc	edi                 ;length = 1
bing_done:
mov	[eax-8],edi         ;write length of string
mov	esp,ebp
pop	ebp
ret
