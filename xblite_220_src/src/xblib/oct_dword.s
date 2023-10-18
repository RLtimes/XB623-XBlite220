.text
; ***********************
; *****  oct.dword  *****  converts a dword to octal representation
; ***********************  internal entry point
;
; in:	esi = minimum number of digits to output
;	edx = value to output
;	edi -> output buffer
;	[oct_shift] -> table of shift values
;	[oct_first] = value to add to first digit
; out:	edi -> char after last char output by oct.dword
;	[oct_first] = value of last digit, if last digit's shift value was 1
;	need some way to indicate that msd was non-zero
;
; destroys: eax, ebx, ecx, edx, esi
;
; local variables:
;	[ebp-4] = current digit (counts down)
;	[ebp-8] = current digit (counts up)
;
; Output buffer is assumed to have enough space to hold all digits generated.
; Output string will contain more than esi characters if edx cannot
; be represented in esi characters.  If minimum number of digits is zero
; and the value to output is zero, no output will be generated.  No
; terminating null is appended to the output string.
;
; On entry, [oct_shift] must point to either oct_msd_64 or oct_lsd_64
; according to whether oct.dword is being called on the most significant
; or least significant dword of a 64-bit number.  [oct_first] must
; equal zero when printing the msdw of a 64-bit number, and the value of
; the last bit of the msdw when printing the lsd.  On exit, when printing
; an msd, oct.dword sets [oct_first] to the value of the last bit, and
; does not generate a digit for this bit.  Oh, the complications of
; printing octal numbers...
;
.globl oct.dword
oct.dword:
push	ebp
mov	ebp,esp
sub	esp,8
mov	ebx,hex_digits            ;ebx -> table of ASCII characters
mov	[ebp-4],11                ;current digit (counting down) = 11
cld
xor	ecx,ecx                   ;ecx = current digit (counting up) = 0
mov	[ebp-8],ecx               ;save it
od_loop_top:
mov	eax,[oct_shift]           ;eax -> shift table
mov	cl,[eax+ecx]              ;cl = # of bits to shift for next digit
or	cl,cl                       ;zero?
jz	od_exit                     ;yes: we're done
xor	eax,eax
shld	eax,edx,cl                ;shift bits for next digit into eax
sll	edx,cl                    ;remove same bits from edx
cmp	cl,1                      ;shifted only one bit?
jne	short od_not_odd_bit      ;no: it's a normal digit
cmp	[ebp-8],0                 ;first digit?
jne	short od_odd_bit          ;no: it's that irritating bit at the end
                               ; of the first dword of a qword
od_not_odd_bit:
cmp	[ebp-8],0                 ;first digit?
jne	short od_not_first_digit
or	eax,[oct_first]             ;yes: OR in last bit from previous dword
od_not_first_digit:
cmp	[ebp-4],esi               ;into range of mandatory digits? (i.e. print
                               ; even if zero?)
jbe	short od_output           ;yes: print current char
or	al,al                       ;a non-zero digit before mandatory digits?
jz	short od_loop_end           ;no: skip this digit
mov	esi,127                   ;yes: force all digits from here to print
od_output:
xlatb                          ;al = ASCII representation of digit
stosb                          ;put digit into buffer
od_loop_end:
dec	[ebp-4]                   ;bump falling digit counter
inc	[ebp-8]                   ;bump rising digit counter
mov	ecx,[ebp-8]               ;ecx = rising digit counter
jmp	short od_loop_top         ;go convert next digit, if any
od_exit:
mov	[oct_first],0             ;no extra bit for next time if we got here
mov	esp,ebp
pop	ebp
ret
                               ;we're on irritating last bit of 1st dword
od_odd_bit:                    ; of a 64-bit number
sll	eax,2                     ;shift bit to where it attaches to next
; 3-bit group
mov	[oct_first],eax           ;save bit for next time
mov	esp,ebp
pop	ebp
ret
