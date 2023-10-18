.text
;
; ***********************
; *****  hex.dword  *****  converts a dword to hexadecimal representation
; ***********************  internal entry point
;
; in:	esi = minimum number of digits to output
;	edx = value to output
;	edi -> output buffer
; out:	edi -> char after last char output by hex.dword
;
; destroys: eax, ebx, ecx, edx, esi
;
; Output buffer is assumed to have enough space to hold all digits generated.
; Output string will contain more than esi characters if edx cannot
; be represented in esi characters.  If minimum number of digits is zero
; and the value to output is zero, no output will be generated.  No
; terminating null is appended to the output string.
;
.globl hex.dword
hex.dword:
mov	ebx,hex_digits       ;ebx -> table of ASCII characters
mov	ecx,8                ;ecx = current digit
cld
hd_loop_top:
xor	eax,eax
shld	eax,edx,4            ;shift next digit into al
sll	edx,4                ;shld should have done this
cmp	ecx,esi              ;into range of mandatory digits? (i.e. print
                          ; even if zero?)
jbe	short hd_output      ;yes: print current char
or	al,al                  ;a non-zero digit before mandatory digits?
jz	short hd_loop_end      ;no: skip this digit
mov	esi,127              ;yes: force all digits from here to print
hd_output:
xlatb                     ;al = ASCII representation of digit
stosb                     ;put digit into buffer
hd_loop_end:
dec	ecx                  ;bump digit counter
jnz	hd_loop_top          ;keep going if haven't reached last digit
ret
