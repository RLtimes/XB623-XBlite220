.text
; *************************
; *****  str.ulong.x  *****  converts a positive number to a string
; *************************  internal common entry point
;
; in:	arg1 = prefix character, or 0 if no prefix
;	arg0 = number to convert to string
; out:	eax -> result string (prefix character is prepended to result string)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> result string
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl str.ulong.x
str.ulong.x:
push	ebp
mov	ebp,esp
sub	esp,4
mov	esi,15							;get room for at least 15 bytes to hold result
call	%_____calloc				;esi -> header of result string
add	esi,16							;esi -> result string
mov	[ebp-4],esi					;save it
mov	eax,0								;eax = system/user bit
or	eax,0x80130001				;info word indicates: allocated string
mov	[esi-4],eax					;store info word
mov	eax,[ebp+12]				;eax = prefix character
or	eax,eax								;a null?
jz	short ulong_no_prefix ;yes: don't prepend a prefix
mov	[esi],al						;no: store it
inc	esi									;esi -> character after prefix character
ulong_no_prefix:
mov	eax,[ebp+8]					;eax = number to convert
or	eax,eax								;just converting a zero?
jz	short ulong_zero 			;yes: skip time-consuming loop
xor	ebx,ebx							;ebx = offset into ulong_table = 0
xor	edi,edi							;edi = # of digits generated so far = 0
mov	ecx,[ulong_table+ebx*4] ;ecx = current positional value
mov	edx,eax							;edx = what's left of current number =
;												; current number if first digit is a zero
ulong_digit_loop:
cmp	eax,ecx								;zero at this digit?
jb	short ulong_zero_digit 	;yes: skip division
xor	edx,edx								;clear upper 32 bits of dividend
div	ecx										;eax = digit, edx = remainder = what's left
;													; of current number
ulong_write_digit:
add	al,'0'								;convert digit to ASCII
mov	[esi+edi],al					;write current digit
inc	edi										;increment number of digits generated so far
ulong_next_digit:
inc	ebx										;increment offset into ulong_table
mov	eax,edx								;eax = what's left of number
mov	ecx,[ulong_table+ebx*4] ;ecx = current positional value
or	ecx,ecx									;reached end of table (last digit)?
jnz	ulong_digit_loop 			;no: do another digit
ulong_done:
mov	byte ptr [esi+edi],0 	;add null terminator
mov	eax,[ebp-4]						;eax -> start of result string
lea	ebx,[esi+edi]					;ebx -> null terminator
sub	ebx,eax								;ebx = true length of string
mov	[eax-8],ebx						;store length of result string
mov	esp,ebp
pop	ebp
ret
ulong_zero_digit:
or	edi,edi									;is current digit a leading zero?
jz	ulong_next_digit 				;yes: skip it
xor	eax,eax								;force current digit to zero
jmp	ulong_write_digit
ulong_zero:								;result string is \"0\"
mov	byte ptr [esi],'0' 		;store the zero digit
mov	edi,1									;edi = length of string, not counting prefix
jmp	ulong_done
;
;
.align	8
ulong_table:			;table of values for each decimal digit
.dword	1000000000	; read by str.ulong.x
.dword	100000000
.dword	10000000
.dword	1000000
.dword	100000
.dword	10000
.dword	1000
.dword	100
.dword	10
.dword	1
.dword	0		;zero indicates end of list
