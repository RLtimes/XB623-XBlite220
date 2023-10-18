.text
; ***************************
; *****  giant.decimal  *****  converts positive GIANT to decimal strin
; ***************************
;
; in:	arg2 = prefix character, or 0 if no prefix
;	arg1:arg0 = number to convert to string
; out:	eax -> result string (prefix character is prepended to result st
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> result string
;	[ebp-8] = pointer to next char in result string
;	[ebp-12] = leading-zero flag: != 0 if at least one digit has been
;		   printed
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl giant.decimal
giant.decimal:
push	ebp
mov	ebp,esp
sub	esp,12
mov	esi,30						;get room for at least 30 bytes to hold result
call	%_____calloc			;esi -> header of result string
add	esi,16						;esi -> result string
mov	[ebp-4],esi				;save it
mov	eax,0	            ;eax = system/user bit
or	eax,0x80130001			;info word indicates: allocated string
mov	[esi-4],eax				;store info word
mov	edi,esi						;edi -> result string
mov	eax,[ebp+16]			;eax = prefix character
or	eax,eax							;a null?
jz	short gd_make_abs 	;yes: don't prepend a prefix
stosb									;no: store it
gd_make_abs:						;make absolute-value copy of number to convert
mov	edx,[ebp+12]			;edx = ms dword of number to convert
mov	eax,[ebp+8]				;eax = ls dword of number to convert
or	edx,edx							;negative?
jns	short gd_not_negative ;no: don't negate it
or	eax,eax							;but don't negate 0x8000000000000000
jnz	short gd_negate
cmp	edx,0x80000000
je	gd_not_negative
gd_negate:
not	edx
neg	eax
sbb	edx,-1						;edx:eax = ABS(original number)
gd_not_negative:
or	edx,edx							;ms dword is zero?
jnz	short gd_ms_not_zero ;no: have to do some honest work
cmp	eax,edx						;yes: is ls half zero, too?
jz	gd_zero							;yes: just make a \"0\" string
gd_ls_not_zero:
bsr	ecx,eax						;find highest one bit in ls half of giant
jmp	short gd_go
gd_ms_not_zero:
bsr	ecx,edx						;find highest one bit in ms half of giant
add	ecx,32						;eax is index into gd_start_digits
gd_go:
mov	[ebp-12],0						;clear leading-zero flag (ecx from now on)
movzx	ecx,byte ptr [gd_start_digits+ecx] ;ecx = index into gd_table
;													; of 1st power of ten to divide by
lea	esi,[gd_table+ecx*8] 	;esi -> 1st power of ten
mov	[ebp-8],edi						;save pointer to next char in result string
gd_digit_loop:
xor	edi,edi								;current digit = 0
mov	ebx,[esi]
mov	ecx,[esi+4]						;ecx:ebx = current power of ten
;in the following comments, n = what's
; left of the current number to convert,
; and p10 = the current power of ten
gd_subtract_loop:
cmp	edx,ecx								;compare most significant halves: n - p10
jb	short gd_got_digit 			;n < p10: current digit is correct
ja	short gd_next_subtract 	;n > p10: keep subtracting
cmp	eax,ebx								;compare least significant halves: n - p10
jb	short gd_got_digit 			;n < 10: current digit is correct
gd_next_subtract:
sub	eax,ebx
sbb	edx,ecx								;n -= p10
inc	edi										;bump digit counter
jmp	gd_subtract_loop
gd_got_digit:
or	edi,edi									;digit is zero?
jnz	short gd_output_digit ;no: output it unconditionally
cmp	[ebp-12],0						;has anything been output yet?
jz	short gd_next_digit 		;no: this is a leading zero, so skip it
gd_output_digit:
mov	ebx,[ebp-8]						;ebx -> next char of result string
lea	ecx,[edi+'0']					;convert digit to ASCII
mov	[ebx],cl							;write digit to result string
inc	ebx										;bump pointer into result string
mov	[ebp-8],ebx						;save pointer into result string
mov	[ebp-12],1						;mark that at least one digit has been outpu
gd_next_digit:
sub	esi,8									;esi -> next lower power of ten
cmp	esi,gd_table					;backed up past beginning of table?
jae	gd_digit_loop					;no: do next digit
mov	edi,ebx								;edi -> next char in result string
gd_done:
xor	al,al
stosb											;append null terminator
mov	eax,[ebp-4]						;eax -> result string
sub	edi,eax								;edi = LEN(result string) + 1
dec	edi										;edi = LEN(result string)
mov	[eax-8],edi						;store length of result string
mov	esp,ebp
pop	ebp
ret
gd_zero:										;just generate \"0\" string
mov	al,'0'
stosb											;write '0' after prefix
jmp	gd_done
;
;
.text
.align	8
gd_start_digits:	;indexes into gd_table according to the position
;of the first one bit in the 64-bit number to
;convert to a decimal string
.byte	0		; bit 00: highest possible MSD for 0x00000001 LSW
.byte	0		; bit 01: highest possible MSD for 0x00000003 LSW
.byte	0		; bit 02: highest possible MSD for 0x00000007 LSW
.byte	1		; bit 03: highest possible MSD for 0x0000000F LSW
.byte	1		; bit 04: highest possible MSD for 0x0000001F LSW
.byte	1		; bit 05: highest possible MSD for 0x0000003F LSW
.byte	2		; bit 06: highest possible MSD for 0x0000007F LSW
.byte	2		; bit 07: highest possible MSD for 0x000000FF LSW
.byte	2		; bit 08: highest possible MSD for 0x000001FF LSW
.byte	3		; bit 09: highest possible MSD for 0x000003FF LSW
.byte	3		; bit 10: highest possible MSD for 0x000007FF LSW
.byte	3		; bit 11: highest possible MSD for 0x00000FFF LSW
.byte	3		; bit 12: highest possible MSD for 0x00001FFF LSW
.byte	4		; bit 13: highest possible MSD for 0x00003FFF LSW
.byte	4		; bit 14: highest possible MSD for 0x00007FFF LSW
.byte	4		; bit 15: highest possible MSD for 0x0000FFFF LSW
.byte	5		; bit 16: highest possible MSD for 0x0001FFFF LSW
.byte	5		; bit 17: highest possible MSD for 0x0003FFFF LSW
.byte	5		; bit 18: highest possible MSD for 0x0007FFFF LSW
.byte	6		; bit 19: highest possible MSD for 0x000FFFFF LSW
.byte	6		; bit 20: highest possible MSD for 0x001FFFFF LSW
.byte	6		; bit 21: highest possible MSD for 0x003FFFFF LSW
.byte	6		; bit 22: highest possible MSD for 0x007FFFFF LSW
.byte	7		; bit 23: highest possible MSD for 0x00FFFFFF LSW
.byte	7		; bit 24: highest possible MSD for 0x01FFFFFF LSW
.byte	7		; bit 25: highest possible MSD for 0x03FFFFFF LSW
.byte	8		; bit 26: highest possible MSD for 0x07FFFFFF LSW
.byte	8		; bit 27: highest possible MSD for 0x0FFFFFFF LSW
.byte	8		; bit 28: highest possible MSD for 0x1FFFFFFF LSW
.byte	9		; bit 29: highest possible MSD for 0x3FFFFFFF LSW
.byte	9		; bit 30: highest possible MSD for 0x7FFFFFFF LSW
.byte	9		; bit 31: highest possible MSD for 0xFFFFFFFF LSW
.byte	9		; bit 32: highest possible MSD for 0x00000001 MSW
.byte	10		; bit 33: highest possible MSD for 0x00000003 MSW
.byte	10		; bit 34: highest possible MSD for 0x00000007 MSW
.byte	10		; bit 35: highest possible MSD for 0x0000000F MSW
.byte	11		; bit 36: highest possible MSD for 0x0000001F MSW
.byte	11		; bit 37: highest possible MSD for 0x0000003F MSW
.byte	11		; bit 38: highest possible MSD for 0x0000007F MSW
.byte	12		; bit 39: highest possible MSD for 0x000000FF MSW
.byte	12		; bit 40: highest possible MSD for 0x000001FF MSW
.byte	12		; bit 41: highest possible MSD for 0x000003FF MSW
.byte	12		; bit 42: highest possible MSD for 0x000007FF MSW
.byte	13		; bit 43: highest possible MSD for 0x00000FFF MSW
.byte	13		; bit 44: highest possible MSD for 0x00001FFF MSW
.byte	13		; bit 45: highest possible MSD for 0x00003FFF MSW
.byte	14		; bit 46: highest possible MSD for 0x00007FFF MSW
.byte	14		; bit 47: highest possible MSD for 0x0000FFFF MSW
.byte	14		; bit 48: highest possible MSD for 0x0001FFFF MSW
.byte	15		; bit 49: highest possible MSD for 0x0003FFFF MSW
.byte	15		; bit 50: highest possible MSD for 0x0007FFFF MSW
.byte	15		; bit 51: highest possible MSD for 0x000FFFFF MSW
.byte	15		; bit 52: highest possible MSD for 0x001FFFFF MSW
.byte	16		; bit 53: highest possible MSD for 0x003FFFFF MSW
.byte	16		; bit 54: highest possible MSD for 0x007FFFFF MSW
.byte	16		; bit 55: highest possible MSD for 0x00FFFFFF MSW
.byte	17		; bit 56: highest possible MSD for 0x01FFFFFF MSW
.byte	17		; bit 57: highest possible MSD for 0x03FFFFFF MSW
.byte	17		; bit 58: highest possible MSD for 0x07FFFFFF MSW
.byte	18		; bit 59: highest possible MSD for 0x0FFFFFFF MSW
.byte	18		; bit 60: highest possible MSD for 0x1FFFFFFF MSW
.byte	18		; bit 61: highest possible MSD for 0x3FFFFFFF MSW
.byte	18		; bit 62: highest possible MSD for 0x7FFFFFFF MSW
.byte	19		; bit 63: highest possible MSD for 0xFFFFFFFF MSW
;
.align	8
gd_table:			; 64-bit powers of ten
.dword	0x00000001, 0x00000000  ;                          1	 1 digit
.dword	0x0000000A, 0x00000000  ;                         10	 2 digits
.dword	0x00000064, 0x00000000  ;                        100	 3 digits
.dword	0x000003E8, 0x00000000  ;                      1,000	 4 digits
.dword	0x00002710, 0x00000000  ;                     10,000	 5 digits
.dword	0x000186A0, 0x00000000  ;                    100,000	 6 digits
.dword	0x000F4240, 0x00000000  ;                  1,000,000	 7 digits
.dword	0x00989680, 0x00000000  ;                 10,000,000	 8 digits
.dword	0x05F5E100, 0x00000000  ;                100,000,000	 9 digits
.dword	0x3B9ACA00, 0x00000000  ;              1,000,000,000	10 digits
.dword	0x540BE400, 0x00000002  ;             10,000,000,000	11 digits
.dword	0x4876E800, 0x00000017  ;            100,000,000,000	12 digits
.dword	0xD4A51000, 0x000000E8  ;          1,000,000,000,000	13 digits
.dword	0x4E72A000, 0x00000918  ;         10,000,000,000,000	14 digits
.dword	0x107A4000, 0x00005AF3  ;        100,000,000,000,000	15 digits
.dword	0xA4C68000, 0x00038D7E  ;      1,000,000,000,000,000	16 digits
.dword	0x6FC10000, 0x002386F2  ;     10,000,000,000,000,000	17 digits
.dword	0x5D8A0000, 0x01634578  ;    100,000,000,000,000,000	18 digits
.dword	0xA7640000, 0x0DE0B6B3  ;  1,000,000,000,000,000,000	19 digits
.dword	0x89E80000, 0x8AC72304  ; 10,000,000,000,000,000,000	20 digits
