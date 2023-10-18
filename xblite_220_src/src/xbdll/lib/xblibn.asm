
; #######################
; #####  xblibn.asm #####  XstStringToNumber ()
; #######################

.code

; *******************************
; *****  XstStringToNumber  *****
; *******************************

; XstStringToNumber (text$, startOffset, afterOffset, valueType, value$$)

; in:	arg4 = ignored
;	arg3 = ignored
;	arg2 = ignored
;	arg1 = (zero-biased) start offset into text$
;	arg0 -> text$, string from which to parse a number
; out:	eax = "explicit" type (see below)
;	arg4 = SINGLE, DOUBLE, or GIANT value of number parsed [ebp+24]:[ebp+28]
;	arg3 = valueType (see below)				[ebp+20]
;	arg2 = (zero-biased) offset into text$ of character	[ebp+16]
;	       after last character from text$ that was part
;	       of parsed number
;	arg1 = unchanged					[ebp+12]
;	arg0 = unchanged					[ebp+8]

; destroys: ebx, ecx, edx, esi, edi

; local variables:
;	[ebp-4] = hi (most significant) 32 bits of integer result
;	[ebp-8] = lo (least significant) 32 bits of integer result
;	[ebp-12] = current state (see "state table" at end of this file)
;	[ebp-16] = number of digits received so far
;	[ebp-20] = hi 32 bits of double result
;	[ebp-24] = lo 32 bits of double result / single result
;	[ebp-28] = sign of result (0 = positive, -1 = negative)
;	[ebp-32] = exponent
;	[ebp-36] = return value
;	[ebp-40] = current character
;	[ebp-44] = 0 if nothing in st0, 1 if result in st0
;	[ebp-48] = number of digits after decimal point received so far
;	[ebp-52] = number of exponent digits
;	[ebp-56] = sign of exponent (0 = positive, -1 = negative)
;	[ebp-60] = minimum number of digits for number to be legal
;	[ebp-64] = minimum number of digits for exponent to be legal
;	[ebp-68] = force type (for example: > 8 hex digits = giant)

; Characters <= space (0x20) and > 0x80 at the beginning of text$ (actually,
; starting at text${startOffset}) are skipped.

; On exit, the return value (eax) is set according to the following rules:

;	1. If number starts with "0s", then return value = $$SINGLE.

;	2. If number starts with "0d", then return value = $$DOUBLE.

;	3. If number is invalid or there was no number, then return value = -1.

;	4. Otherwise, return value = 0.

; On exit, arg3 (valueType) is set according to the following rules:

;	1. If return value == $$SINGLE or return value == $$DOUBLE,
;	   valueType = return value.

;	2. If the number was floating-point, valueType = $$DOUBLE.

;	3. If number was integer and could not fit in an SLONG,
;	   valueType = $$GIANT.

;	4. If there was no number, valueType = 0.

;	5. Otherwise, valueType = $$XLONG.

; The number stored in arg4 on exit has the type indicated by valueType (arg3).

; Number formats:  ("n" = decimal digit; "h" = hexadecimal digit; "O" =
; octal digit; "B" = binary digit; "+" = plus or minus)

;	Format			Type of result
;	------			--------------
;	nnnnn			integer
;	nnnnn.			floating-point
;	nnnnn.e+nn		floating-point
;	nnnnn.d+nn		floating-point
;	0xhhhhhh		integer
;	0oOOOOOO		integer
;	0bBBBBBB		integer
;	0shhhhhhhh		single-precision floating-point
;	0dhhhhhhhhhhhhhhhh	double-precision floating-point

; Complete documentation on the formats in which numbers are represented
; in strings is in the XBasic Language Description.

; See STATE TABLE, near end of file, for outline of algorithm.

_XstStringToNumber@24:
	push	ebp
	mov	ebp,esp
	sub	esp,80

	xor	eax,eax											; ready to initialize some variables
	mov	[ebp-4],eax
	mov	[ebp-8],eax									; integer result = 0
	mov d[ebp-12],ADDR ST_START 		; current state = ST_START
	mov	[ebp-16],eax								; number of digits received so far = 0
	mov	[ebp-20],eax
	mov	[ebp-24],eax								; floating-point result = 0
	mov	[ebp-28],eax								; sign of result = positive
	mov	[ebp-32],eax								; exponent = 0
	mov d[ebp+20],8									; valueType = $$XLONG
	mov	[ebp-36],eax								; return value = 0
	mov	[ebp-44],eax								; there's nothing in st0 yet
	mov	[ebp-48],eax								; # digits after decimal point = 0
	mov	[ebp-52],eax								; # of exponent digits = 0
	mov	[ebp-56],eax								; sign of exponent = positive
	mov	[ebp-60],eax								; minimum number of digits for number to be
																	; legal = 0
	mov	[ebp-64],eax								; no exponent is necessary
	mov	[ebp-68],eax								; forcetype = 0 = none

	mov	ecx,[ebp+12]								; ecx = startOffset
	mov	[ebp+16],ecx								; afterOffset = startOffset

	mov	esi,[ebp+8]									; esi -> text$
	test esi,esi										; null pointer?
	jz	> done											; yes: nothing to do

main_loop_top:										; assuming: esi -> text$, ecx = afterOffset
	cmp	ecx,[esi-8]									; past end of text$?
	jae	> done											; yes: no characters left to parse

	movzx	eax,b[esi+ecx] 						; eax = current character
	mov	ebx,[ebp-12]								; ebx -> first structure for current state

struct_loop_top:
	cmp	eax,[ebx+0]									; eax >= lower bound?
	jb	> try_next_struct 					; no: no match
	cmp	eax,[ebx+4]									; eax <= upper bound?
	ja	> try_next_struct 					; no: no match

	mov	[ebp-40],eax								; save current character
	mov	edx,[ebx+12]								; eax = next state
	mov	[ebp-12],edx								; new current state
	jmp	[ebx+8]											; go to action routine for current structure

try_next_struct:
	add	ebx,16											; ebx -> next structure for current state
	jmp	struct_loop_top

next_char:
	mov	esi,[ebp+8]									; esi -> text$
	mov	ecx,[ebp+16]								; ecx = afterOffset -> current char
	inc	ecx													; bump character pointer
	mov	[ebp+16],ecx								; save it
	jmp	main_loop_top

done_inc:													; done, but bump afterOffset before exiting
	inc	 d[ebp+16]									; bump afterOffset

done:
	cmp	 d[ebp-16],0								; received any digits at all?
	jz	> no_number									; nope: error return

; if floating-point number and had exponent, adjust number for exponent

	cmp d[ebp-44],0									; result is in st0?
	je	> make_arg4									; no: all done
	cmp d[ebp-52],0									; at least one exponent digit?
	je	> exponent_done 						; no: no need to adjust for exponent

	mov	edx,[ebp-32]								; edx = exponent
	cmp d[ebp-56],0									; sign of exponent is negative?
	je	> exponent_adjust 					; no
	neg	edx													; yes: now edx really = exponent

exponent_adjust:
	add	edx,308											; exponent table begins at -308
	fld	Q [%_pwr_10_table + edx*8] 	; load exponent multiplier
	fmulp st1,st0										; multiply result by exponent multiplier
	fwait

exponent_done:
	cmp d[ebp-28],0									; sign is negative?
	je	> store_float_result 				; no
	fchs														; yes: make result negative
store_float_result:
	fstp	Q [ebp-24] 								; store result

make_arg4:
	mov	eax,[ebp+20]								; eax = valueType
	cmp	eax,13											; $$SINGLE?
	je	> make_single 							; yes: go do it
	cmp	eax,14											; $$DOUBLE?
	je	> make_double 							; yes: go do it

; result is an integer

	mov	edx,[ebp-4]									; edx = hi 32 bits of result
	mov	eax,[ebp-8]									; eax = lo 32 bits of result

	test edx,edx										; anything in hi 32 bits?
	jnz	> integer_giant 						; yes, so result is GIANT

	mov	ecx,[ebp-68]								; eax = force type
	cmp	ecx,12											; GIANT ???
	je	> integer_giant							; yes

	cmp	ecx,8												; valueType == XLONG ???
	mov d[ebp+20],8									; valueType = XLONG
	je	> integer_xlong							; yes

	or	eax,eax											; sign bit in low 32 bits?
	js	> integer_giant 						; yes, so result is GIANT

hd_32:
	mov d[ebp+20],6									; valueType = $$SLONG

integer_xlong:
	cmp d[ebp-28],0									; sign is positive?
	je	> xlong_sign_ok 						; yes
	neg	eax													; no: negate result

xlong_sign_ok:
	mov	[ebp+24],eax								; store result to lo 32 bits of arg4
	mov d[ebp+28],0									; hi 32 bits of arg4 = 0
	jmp	> validity_check

integer_giant:
	mov d[ebp+20],12								; valueType = $$GIANT
	cmp d[ebp-28],0									; sign is positive?
	je	> giant_sign_ok 						; yes
	not	edx													; no: negate result
	neg	eax
	sbb	edx,-1
giant_sign_ok:
	mov	[ebp+24],eax								; store lo 32 bits of result
	mov	[ebp+28],edx								; store hi 32 bits of result
	jmp	> validity_check

make_single:
	mov	eax,[ebp-24]								; eax = result
	mov	[ebp+24],eax								; store result into arg4
	mov d[ebp+28],0									; clear high 32 bits of arg4
	jmp	 validity_check

make_double:
	fwait
	mov	eax,[ebp-24]								; eax = lo 32 bits of result
	mov	[ebp+24],eax								; store lo 32 bits of result into arg4
	mov	eax,[ebp-20]								; eax = hi 32 bits of result
	mov	[ebp+28],eax								; store hi 32 bits of result into arg4

validity_check:
	mov	eax,[ebp-36]								; eax = return value
	mov	ebx,[ebp-60]								; ebx = minimum number of digits to be legal
	cmp	ebx,[ebp-16]								; received enough digits?
	ja	> invalidate_number 				; no

	mov	ebx,[ebp-64]								; ebx = minimum number of digits in exponent
	cmp	ebx,[ebp-52]								; received enough digits in exponent?
	ja	> invalidate_number 				;no

stn_exit:
	leave
	ret	24

no_number:
	xor	eax,eax											; ready to write some zeros
	mov	[ebp+20],eax								; valueType = 0, to indicate that no number
																	; was found
	mov	[ebp+24],eax								; set result to 0, too
	mov	[ebp+28],eax
	dec	eax													; return value = -1
	leave
	ret	24

invalidate_number:
	mov	eax,-1											; return value = -1 to indicate invalid number
	jmp	stn_exit

stn_abort:
	mov d[ebp-36],-1								; mark that current number is invalid
	jmp	done

; *****************************
; *****  ACTION ROUTINES  *****  routines pointed to in state table,
; *****************************  except for next_char

; in:	eax = current character

; All action routines jump to either next_char or done on completion.

add_dec_digit:										; multiply current integer result by 10
																	; and add current digit in
	mov	edx,[ebp-4]									; edx = hi 32 bits of integer
	cmp	edx,0x10000000							; number getting too big to fit in integer?
	ja	> too_big_for_int 					; yes
	mov	eax,[ebp-8]									; eax = lo 32 bits of integer

	shl	eax,1
	rcl	edx,1												; edx:eax = integer * 2
	mov	ebx,eax
	mov	ecx,edx											; ecx:ebx = integer * 2
	shld	edx,eax,2
	shl	eax,2												; edx:eax = integer * 8
	add	eax,ebx
	adc	edx,ecx											; edx:eax = integer*8 + integer*2 = integer*10

	mov	ebx,[ebp-40]								; ebx = current character
	sub	ebx,'0'											; ebx = current digit
	add	eax,ebx											; add in current digit
	adc	edx,0												; propagate carry bit

	mov	[ebp-4],edx									; save hi 32 bits of integer
	mov	[ebp-8],eax									; save lo 32 bits of integer
	inc d[ebp-16]										; bump digit counter
	jmp	next_char


too_big_for_int:
	fild	Q [ebp-8] 								; st0 = integer built so far
	mov d[ebp+20],14								; valueType = $$DOUBLE
	mov d[ebp-44],1									; mark that result is in st0
	mov d[ebp-12],ADDR ST_IN_FLOAT 	; switch to floating-point state

; fall through
add_float_digit:									; add a digit to floating-point number
																	; before decimal point
	fimul	d[ten]										; old result *= 10
	sub d[ebp-40],'0'								; current character = current digit
	fiadd	d[ebp-40] 								; add current digit into result
	inc d[ebp-16]										; bump digit counter
	jmp	next_char

sign_negative:										; set sign to negative
	mov d[ebp-28],-1
	jmp	next_char

type_double:											; set type to $$DOUBLE
																	; once a floating-point number has been
																	; detected, its running value is kept in
																	; st0, until the decimal point is found
	fild	Q [ebp-8] 								; convert current integer to floating-point
	mov d[ebp+20],14								; valueType = $$DOUBLE
	mov d[ebp-44],1									; mark that result is in st0
	jmp	next_char

begin_simage:											; set type to $$SINGLE and accumulate
																	; result in [ebp-20]
	mov d[ebp+20],13								; valueType = $$SINGLE
	mov d[ebp-36],13								; return value = $$SINGLE
	mov d[ebp-16],0									; digit count = 0
	mov d[ebp-60],8									;	minimum number of digits to be legal = 8
	jmp	next_char

begin_dimage:											; set type to $$DOUBLE and accumulate
																	; result in [ebp-20]:[ebp-24]
	mov d[ebp+20],14								; valueType = $$DOUBLE
	mov d[ebp-36],14								; return value = $$DOUBLE
	mov d[ebp-16],0									; digit count = 0
	mov d[ebp-60],16								; minimum number of digits to be legal = 16
	jmp	next_char

add_hex_digit:										; multiply current integer by 16 and add
																	; in current digit
	mov	ebx,[ebp-8]									; ebx = lo 32 bits of current integer
	mov	ecx,[ebp-4]									; ecx = hi 32 bits of current integer
	shld	ecx,ebx,4
	shl	ebx,4												; ebx:ecx = integer * 16

	movzx	eax,b[%_lctouc+eax] 			; convert current char to upper case
	sub	eax,'0'											; eax = current digit
	cmp	eax,9												; was it A,B,C,D,E, or F?
	jbe	 > hd_add										; no: eax really is current digit
	sub	eax,7												; now eax really is current digit

hd_add:														; eax = current digit
	or	ebx,eax											; add in current digit
	mov	[ebp-8],ebx									; save lo 32 bits of integer
	mov	[ebp-4],ecx									; save hi 32 bits of integer

	mov	eax,[ebp-16]								; eax = number of digits read so far
	inc	eax													; bump digit counter
	mov	[ebp-16],eax								; save digit counter
	cmp	eax,9												; digits beyond XLONG ???
	jnz	> hd_long										; not yet
	mov d[ebp-68],12								; yes, so force hex # to GIANT

hd_long:
	cmp	eax,16											; reached last (16th) possible hex digit?
	jae	> no_more_digits						; yes: don't read any more
	jmp	next_char

add_bin_digit:										;	multiply current integer by 2 and add
																	; in current digit
	mov	ebx,[ebp-8]									; ebx = lo 32 bits of current integer
	mov	ecx,[ebp-4]									; ecx = hi 32 bits of current integer
	shl	ebx,1
	rcl	ecx,1												; ecx:ebx = integer * 2

	sub	eax,'0'											; eax = current digit
	or	ebx,eax											; add in current digit
	mov	[ebp-8],ebx									; save lo 32 bits of integer
	mov	[ebp-4],ecx									; save hi 32 bits of integer

	mov	eax,[ebp-16]								; eax = number of digits read so far
	inc	eax													; bump digit counter
	mov	[ebp-16],eax								; save digit counter
	cmp	eax,64											; reached last (64th) possible binary digit?
	jae	> no_more_digits						; yes: don't read any more
	jmp	next_char

add_oct_digit:										; multiply current integer by 8 and add
																	; in current digit
	mov	ebx,[ebp-8]									; ebx = lo 32 bits of current integer
	mov	ecx,[ebp-4]									; ecx = hi 32 bits of current integer
	shld	ecx,ebx,3
	shl	ebx,3												; ecx:ebx = integer * 8

	sub	eax,'0'											; eax = current digit
	or	ebx,eax											; add in current digit
	mov	[ebp-8],ebx									; save lo 32 bits of integer
	mov	[ebp-4],ecx									; save hi 32 bits of integer

	mov	eax,[ebp-16]								; eax = number of digits read so far
	inc	eax													; bump digit counter
	mov	[ebp-16],eax								; save digit counter
	cmp	eax,22											; reached last (22nd) possible octal digit?
	jae	> no_more_digits						; yes: don't read any more
	jmp	next_char

add_simage_digit:									; append current hex digit to SINGLE result
	movzx	eax,b[%_lctouc+eax] 			; convert current char to upper case
	sub	eax,'0'											; eax = current digit
	cmp	eax,9												; was it A,B,C,D,E, or F?
	jbe	> simage_hd_ok 							; no: eax really is current digit
	sub	eax,7												; now eax really is current digit

simage_hd_ok:
	mov	ecx,[ebp-16]								; ecx = number of digits read so far
	shl	eax,28											; move digit up to very top of eax
	mov	ebx,ecx											; save number of digits read so far
	shl	ecx,2												; ecx = number of digits * 4 = # of bits to shift
	shr	eax,cl											; move digit to correct position in eax
	or	[ebp-24],eax								; add in digit to SINGLE result

	inc	ebx													; bump digit counter
	mov	[ebp-16],ebx								; save digit counter
	cmp	ebx,8												; reached last (8th) possible hex digit?
	jae	> no_more_digits						; yes: don't read any more
	jmp	next_char

add_dimage_digit:									; append current hex digit to DOUBLE result
	movzx	eax,b[%_lctouc+eax] 			;	convert current char to upper case
	sub	eax,'0'											;	eax = current digit
	cmp	eax,9												;	was it A,B,C,D,E, or F?
	jbe	> dimage_hd_ok 							;	no: eax really is current digit
	sub	eax,7												;	now eax really is current digit

dimage_hd_ok:
	mov	ecx,[ebp-16]								;	ecx = number of digits read so far
	shl	eax,28											;	move digit up to very top of eax
	mov	ebx,ecx											;	save number of digits read so far
	shl	ecx,2												;	ecx = number of digits * 4 = # of bits to shift
	shr	eax,cl											;	move digit to correct position in eax
	cmp	ebx,8												;	digit is in second word?
	jae	> dimage_loword 						;	yes

dimage_hiword:
	or	[ebp-20],eax								; move digit into DOUBLE result
	jmp	 dimage_done

dimage_loword:
	or	[ebp-24],eax								; move digit into DOUBLE result

dimage_done:
	inc	ebx													; bump digit counter
	mov	[ebp-16],ebx								; save digit counter
	cmp	ebx,16											; reached last (16th) possible hex digit?
	jae	> no_more_digits 						; yes: don't read any more
	jmp	next_char

no_more_digits:										; set state so that if a hex digit comes
																	; next, the number is considered invalid
	mov d[ebp-12],ADDR ST_NUMERIC_BAD
	jmp	next_char

add_after_point:									; add a digit after the decimal point
	mov	edx,[ebp-48]								; edx = # of digits after dec point rec'd so far
	cmp	edx,308											; if 308 or more, digit is of no significance,
	ja	next_char										;  so throw it away

	sub d[ebp-40],'0'								; convert current character to current digit
	fild	d[ebp-40] 								; st0 = current digit, st1 = n
	inc	edx													; bump digit-after-dec-point counter
	mov	[ebp-48],edx								; save it for next time
	neg	edx													; edx = offset relative to 10^0
	fld	Q[%_pwr_10_to_0 + edx*8] 		; load multiplier for current digit
	fmulp st1,st0										; st0 = digit * 10^-position
	faddp st1,st0										; st0 = new n
	inc d[ebp-16]										; bump digit counter
	jmp	next_char


add_exp_digit:										; add a digit to the exponent
	mov	ebx,[ebp-32]								; ebx = current exponent
	sub	eax,'0'											; eax = current digit
	imul	ebx,ebx,10								; current exponent *= 10
	add	ebx,eax											; add in current digit

	cmp	ebx,308											; exponent greater than can be represented?
	ja	stn_abort										; yes: entire number is invalid

	mov	[ebp-32],ebx								; save new current exponent
	inc d[ebp-52]										; bump counter of exponent digits
	jmp	next_char


exp_negative:											; make exponent negative
	mov d[ebp-56],-1								; sign = negative

; fall through
need_exponent:										; mark that we must have an exponent, or
	mov d[ebp-64],1									; number is invalid
	jmp	next_char


bump_digit_count:									; just bump digit counter, and ignore
	inc d[ebp-16]										; current digit
	jmp	next_char


clear_digit_count:								; set digit counter back to zero
	mov d[ebp-68],8									; 0x and 0o and 0b produce XLONG or GIANT
	mov d[ebp-16],0
	jmp	next_char



; ##################
; #####  DATA  #####  XstStringToNumber()
; ##################

.const
align	4
ten:	dd	10											; a place in memory guaranteed to contain 10

; *************************
; *****  STATE TABLE  *****
; *************************

; Each "state" of the parser has a list of structures, each of which
; contains four dwords:

;	0	lower bound of range for current character
;	1	upper bound of range for current character
;	2	location to jump to if current character is in range
;		specified by dwords 0 and 1
;	3	state to change to if current character is in range
;		specified by dwords 0 and 1

; The last such structure in each state's list has a lower bound of
; 0x00 and an upper bound of 0xFF, so that it catches all possible
; characters.  Each time a new character is retrieved from text$,
; XstStringToNumber checks it against each structure in turn, starting
; with the structure pointed to by the "current state" variable,
; until one is found that matches the current character.  XstStringToNumber
; then jumps to the location given in dword 2, and changes the "current
; state" variable to the value in dword 3.

.const
align	8
ST_START:													; parser starts in this state
	dd	'0', '0'
	dd	bump_digit_count
	dd	ST_GOT_LEAD_ZERO

	dd	'1', '9'
	dd	add_dec_digit
	dd	ST_IN_INT

	dd	'+', '+'
	dd	next_char
	dd	ST_IN_INT

	dd	'-', '-'
	dd	sign_negative
	dd	ST_IN_INT

	dd	'.', '.'
	dd	type_double
	dd	ST_AFTER_DEC_POINT

	dd	1, 0x20											; ignore leading whitespace
	dd	next_char
	dd	ST_START

	dd	0x80, 0xFF									; ignore leading chars with high bit set
	dd	next_char
	dd	ST_START

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_GOT_LEAD_ZERO:
	dd	'0', '9'
	dd	add_dec_digit
	dd	ST_IN_INT

	dd	'.', '.'
	dd	type_double
	dd	ST_AFTER_DEC_POINT

	dd	'x', 'x'
	dd	clear_digit_count
	dd	ST_IN_HEX

	dd	'o', 'o'
	dd	clear_digit_count
	dd	ST_IN_OCT

	dd	'b', 'b'
	dd	clear_digit_count
	dd	ST_IN_BIN

	dd	's', 's'
	dd	begin_simage
	dd	ST_IN_SIMAGE

	dd	'd', 'd'
	dd	begin_dimage
	dd	ST_IN_DIMAGE

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_IN_INT:												; inside an integer or the part of a floating-
	dd	'0', '9'										; point number that is to the left of the
	dd	add_dec_digit								; decimal point
	dd	ST_IN_INT

	dd	'.', '.'
	dd	type_double
	dd	ST_AFTER_DEC_POINT

	dd	'd', 'd'
	dd	type_double
	dd	ST_START_EXP

	dd	'e', 'e'										; "nnnne+nn" is converted into double-
	dd	type_double									; precision floating-point, even though
	dd	ST_START_EXP								; the "e" is supposed to mean "single-precision"

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_IN_FLOAT:											; inside a floating-point number and haven't
	dd	'0', '9'										; reached the decimal point yet; the only way
	dd	add_float_digit							; to get to this state is for add_dec_digit
	dd	ST_IN_FLOAT									; to force the state variable to point to it
																	; when the current integer result gets too
	dd	'.', '.'										; large to hold in a GIANT
	dd	next_char
	dd	ST_AFTER_DEC_POINT

	dd	'd', 'd'
	dd	next_char
	dd	ST_START_EXP

	dd	'e', 'e'
	dd	next_char
	dd	ST_START_EXP

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_IN_HEX:
	dd	'0', '9'
	dd	add_hex_digit
	dd	ST_IN_HEX

	dd	'A', 'F'
	dd	add_hex_digit
	dd	ST_IN_HEX

	dd	'a', 'f'
	dd	add_hex_digit
	dd	ST_IN_HEX

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_IN_OCT:
	dd	'0', '7'
	dd	add_oct_digit
	dd	ST_IN_OCT

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_IN_BIN:
	dd	'0', '1'
	dd	add_bin_digit
	dd	ST_IN_BIN

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_IN_SIMAGE:
	dd	'0', '9'
	dd	add_simage_digit
	dd	ST_IN_SIMAGE

	dd	'A', 'F'
	dd	add_simage_digit
	dd	ST_IN_SIMAGE

	dd	'a', 'f'
	dd	add_simage_digit
	dd	ST_IN_SIMAGE

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_IN_DIMAGE:
	dd	'0', '9'
	dd	add_dimage_digit
	dd	ST_IN_DIMAGE

	dd	'A', 'F'
	dd	add_dimage_digit
	dd	ST_IN_DIMAGE

	dd	'a', 'f'
	dd	add_dimage_digit
	dd	ST_IN_DIMAGE

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_AFTER_DEC_POINT:
	dd	'0', '9'
	dd	add_after_point
	dd	ST_AFTER_DEC_POINT

	dd	'd', 'd'
	dd	next_char
	dd	ST_START_EXP

	dd	'e', 'e'
	dd	next_char
	dd	ST_START_EXP

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_START_EXP:
	dd	'0', '9'
	dd	add_exp_digit
	dd	ST_IN_EXP

	dd	'+', '+'
	dd	need_exponent
	dd	ST_IN_EXP

	dd	'-', '-'
	dd	exp_negative
	dd	ST_IN_EXP

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_IN_EXP:
	dd	'0', '9'
	dd	add_exp_digit
	dd	ST_IN_EXP

	dd	0x00, 0xFF
	dd	done
	dd	ST_START

ST_NUMERIC_BAD:										; reached end of 0s or 0d number; if next
	dd	'0', '9'										; digit is numeric, then number is too long.
	dd	stn_abort										; The only way to reach this state is to
	dd	ST_START										; be forced into it by add_simage_digit
																	; or add_dimage_digit
	dd	'a', 'f'
	dd	stn_abort
	dd	ST_START

	dd	'A', 'F'
	dd	stn_abort
	dd	ST_START

	dd	0x00, 0xFF
	dd	done
	dd	ST_START


; ***************************
; *****  POWERS OF TEN  *****
; ***************************

; First element of table is 10^-308; last element is 10^308.  All
; elements are in double precision.

.const
align	8
%_pwr_10_table:
	dd	0x7819E8D3, 0x000730D6, 0x2C40C60E, 0x0031FA18
	dd	0x3750F792, 0x0066789E, 0xC5253576, 0x009C16C5
	dd	0x9B374169, 0x00D18E3B, 0x820511C3, 0x0105F1CA
	dd	0x22865634, 0x013B6E3D, 0x3593F5E0, 0x017124E6
	dd	0xC2F8F358, 0x01A56E1F, 0xB3B7302D, 0x01DAC9A7
	dd	0xD0527E1D, 0x0210BE08, 0x04671DA4, 0x0244ED8B
	dd	0xC580E50D, 0x027A28ED, 0x9B708F28, 0x02B05994
	dd	0xC24CB2F2, 0x02E46FF9, 0x32DFDFAE, 0x03198BF8
	dd	0x3F97D799, 0x034FEEF6, 0xE7BEE6C0, 0x0383F559
	dd	0x61AEA070, 0x03B8F2B0, 0x7A1A488B, 0x03EF2F5C
	dd	0xCC506D57, 0x04237D99, 0x3F6488AD, 0x04585D00
	dd	0x4F3DAAD8, 0x048E7440, 0x31868AC7, 0x04C308A8
	dd	0x3DE82D79, 0x04F7CAD2, 0xCD6238D8, 0x052DBD86
	dd	0x405D6387, 0x05629674, 0x5074BC69, 0x05973C11
	dd	0xA491EB82, 0x05CD0B15, 0x86DB3332, 0x060226ED
	dd	0xE891FFFF, 0x0636B0A8, 0x22B67FFE, 0x066C5CD3
	dd	0xF5B20FFE, 0x06A1BA03, 0xF31E93FE, 0x06D62884
	dd	0x2FE638FD, 0x070BB2A6, 0xDDEFE39E, 0x07414FA7
	dd	0xD56BDC85, 0x0775A391, 0x4AC6D3A7, 0x07AB0C76
	dd	0xEEBC4448, 0x07E0E7C9, 0x6A6B555A, 0x081521BC
	dd	0x85062AB1, 0x084A6A2B, 0x3323DAAF, 0x0880825B
	dd	0xFFECD15A, 0x08B4A2F1, 0x7FE805B1, 0x08E9CBAE
	dd	0x0FF1038F, 0x09201F4D, 0x53ED4473, 0x09542720
	dd	0x68E89590, 0x098930E8, 0x8322BAF4, 0x09BF7D22
	dd	0x91F5B4D9, 0x09F3AE35, 0xF673220F, 0x0A2899C2
	dd	0xB40FEA93, 0x0A5EC033, 0x5089F29C, 0x0A933820
	dd	0x64AC6F43, 0x0AC80628, 0x7DD78B14, 0x0AFE07B2
	dd	0x8EA6B6EC, 0x0B32C4CF, 0x725064A7, 0x0B677603
	dd	0x4EE47DD1, 0x0B9D5384, 0xB14ECEA3, 0x0BD25432
	dd	0x5DA2824B, 0x0C06E93F, 0x350B22DE, 0x0C3CA38F
	dd	0x8126F5CA, 0x0C71E639, 0xE170B33D, 0x0CA65FC7
	dd	0xD9CCE00D, 0x0CDBF7B9, 0x28200C08, 0x0D117AD4
	dd	0x32280F0A, 0x0D45D989, 0x7EB212CC, 0x0D7B4FEB
	dd	0x2F2F4BBF, 0x0DB111F3, 0xFAFB1EAF, 0x0DE5566F
	dd	0xF9B9E65B, 0x0E1AAC0B, 0x7C142FF9, 0x0E50AB87
	dd	0x5B193BF8, 0x0E84D669, 0xB1DF8AF5, 0x0EBA0C03
	dd	0x4F2BB6DA, 0x0EF04782, 0xE2F6A490, 0x0F245962
	dd	0x9BB44DB4, 0x0F596FBB, 0x82A16122, 0x0F8FCBAA
	dd	0x91A4DCB5, 0x0FC3DF4A, 0x360E13E2, 0x0FF8D71D
	dd	0x839198DA, 0x102F0CE4, 0xD23AFF88, 0x1063680E
	dd	0x86C9BF6A, 0x10984212, 0x287C2F45, 0x10CE5297
	dd	0x794D9D8B, 0x1102F39E, 0x17A104EE, 0x1137B086
	dd	0x9D894628, 0x116D9CA7, 0xC275CBD9, 0x11A281E8
	dd	0xF3133ECF, 0x11D72262, 0xAFD80E83, 0x120CEAFB
	dd	0x4DE70912, 0x124212DD, 0xA160CB56, 0x12769794
	dd	0xC9B8FE2C, 0x12AC3D79, 0x1E139EDB, 0x12E1A66C
	dd	0x25988692, 0x13161007, 0xEEFEA836, 0x134B9408
	dd	0x955F2922, 0x13813C85, 0xFAB6F36B, 0x13B58BA6
	dd	0xB964B045, 0x13EAEE90, 0x73DEEE2C, 0x1420D51A
	dd	0x10D6A9B6, 0x14550A61, 0x550C5424, 0x148A4CF9
	dd	0xD527B496, 0x14C0701B, 0xCA71A1BC, 0x14F48C22
	dd	0x7D0E0A2A, 0x1529AF2B, 0x2E28C65A, 0x15600D7B
	dd	0xF9B2F7F1, 0x159410D9, 0x781FB5ED, 0x15C91510
	dd	0x9627A369, 0x15FF5A54, 0xDDD8C622, 0x16339874
	dd	0x154EF7AA, 0x16687E92, 0x9AA2B594, 0x169E9E36
	dd	0x20A5B17D, 0x16D322E2, 0xA8CF1DDC, 0x1707EB9A
	dd	0x5302E553, 0x173DE681, 0xD3E1CF54, 0x1772B010
	dd	0x08DA4328, 0x17A75C15, 0x4B10D3F2, 0x17DD331A
	dd	0x6EEA8477, 0x18123FF0, 0x8AA52594, 0x1846CFEC
	dd	0xAD4E6EFA, 0x187C83E7, 0xCC51055C, 0x18B1D270
	dd	0xFF6546B3, 0x18E6470C, 0x3F3E9860, 0x191BD8D0
	dd	0x27871F3C, 0x19516782, 0xB168E70A, 0x1985C162
	dd	0x5DC320CD, 0x19BB31BB, 0x1A99F480, 0x19F0FF15
	dd	0x614071A1, 0x1A253EDA, 0xF9908E09, 0x1A5A8E90
	dd	0x9BFA58C6, 0x1A90991A, 0x42F8EEF7, 0x1AC4BF61
	dd	0x93B72AB5, 0x1AF9EF39, 0xFC527AB1, 0x1B303583
	dd	0xFB67195E, 0x1B6442E4, 0x3A40DFB5, 0x1B99539E
	dd	0xC8D117A2, 0x1BCFA885, 0x9D82AEC5, 0x1C03C953
	dd	0x84E35A77, 0x1C38BBA8, 0xA61C3115, 0x1C6EEA92
	dd	0xA7D19EAD, 0x1CA3529B, 0x91C60658, 0x1CD82742
	dd	0x363787EF, 0x1D0E3113, 0x01E2B4F5, 0x1D42DEAC
	dd	0x025B6232, 0x1D779657, 0xC2F23ABE, 0x1DAD7BEC
	dd	0xF9D764B7, 0x1DE26D73, 0xF84D3DE4, 0x1E1708D0
	dd	0x36608D5D, 0x1E4CCB05, 0x41FC585A, 0x1E81FEE3
	dd	0x127B6E71, 0x1EB67E9C, 0x171A4A0D, 0x1EEC1E43
	dd	0xEE706E48, 0x1F2192E9, 0x6A0C89DA, 0x1F55F7A4
	dd	0x848FAC50, 0x1F8B758D, 0x72D9CBB3, 0x1FC12978
	dd	0x8F903E9F, 0x1FF573D6, 0x33744E46, 0x202AD0CC
	dd	0xA028B0EC, 0x2060C27F, 0x8832DD28, 0x2094F31F
	dd	0x6A3F9471, 0x20CA2FE7, 0xA267BCC6, 0x21005DF0
	dd	0xCB01ABF8, 0x2134756C, 0xFDC216F5, 0x216992C7
	dd	0xFD329CB3, 0x219FF779, 0x3E3FA1F0, 0x21D3FAAC
	dd	0x4DCF8A6D, 0x2208F957, 0x21436D08, 0x223F37AD
	dd	0x34CA2425, 0x227382CC, 0x41FCAD2E, 0x22A8637F
	dd	0x127BD87A, 0x22DE7C5F, 0x6B8D674D, 0x23130DBB
	dd	0x4670C120, 0x2347D12A, 0xD80CF167, 0x237DC574
	dd	0x070816E1, 0x23B29B69, 0x48CA1C99, 0x23E74243
	dd	0x1AFCA3BE, 0x241D12D4, 0x90DDE657, 0x24522BC4
	dd	0xB5155FED, 0x2486B6B5, 0x225AB7E8, 0x24BC6463
	dd	0xF578B2F1, 0x24F1BEBD, 0x72D6DFAE, 0x25262E6D
	dd	0xCF8C9799, 0x255BBA08, 0x81B7DEBF, 0x25915445
	dd	0xE225D66F, 0x25C5A956, 0x9AAF4C0B, 0x25FB13AC
	dd	0xE0AD8F87, 0x2630EC4B, 0xD8D8F368, 0x2665275E
	dd	0x8F0F3042, 0x269A7136, 0x19697E29, 0x26D086C2
	dd	0x9FC3DDB4, 0x2704A872, 0x47B4D521, 0x2739D28F
	dd	0x8CD10535, 0x27702399, 0xF0054682, 0x27A42C7F
	dd	0xEC069822, 0x27D9379F, 0xE7083E2C, 0x280F8587
	dd	0xF06526DB, 0x2843B374, 0x2C7E7091, 0x2878A052
	dd	0xB79E0CB5, 0x28AEC866, 0x32C2C7F1, 0x28E33D40
	dd	0x3F7379ED, 0x29180C90, 0x4F505869, 0x294E0FB4
	dd	0xB1923742, 0x2982C9D0, 0xDDF6C512, 0x29B77C44
	dd	0x15747656, 0x29ED5B56, 0xCD68C9F6, 0x2A225915
	dd	0x40C2FC73, 0x2A56EF5B, 0x10F3BB91, 0x2A8CAB32
	dd	0x4A98553A, 0x2AC1EAFF, 0x1D3E6A89, 0x2AF665BF
	dd	0xE48E052B, 0x2B2BFF2E, 0x4ED8C33B, 0x2B617F7D
	dd	0xA28EF40A, 0x2B95DF5C, 0xCB32B10C, 0x2BCB5733
	dd	0x5EFFAEA7, 0x2C011680, 0x76BF9A51, 0x2C355C20
	dd	0x946F80E6, 0x2C6AB328, 0x5CC5B090, 0x2CA0AFF9
	dd	0xB3F71CB4, 0x2CD4DBF7, 0xA0F4E3E2, 0x2D0A12F5
	dd	0x84990E6D, 0x2D404BD9, 0xE5BF5208, 0x2D745ECF
	dd	0xDF2F268A, 0x2DA97683, 0xD6FAF02D, 0x2DDFD424
	dd	0x065CD61D, 0x2E13E497, 0xC7F40BA4, 0x2E48DDBC
	dd	0xF9F10E8D, 0x2E7F152B, 0x7C36A919, 0x2EB36D3B
	dd	0x5B44535F, 0x2EE8488A, 0xF2156837, 0x2F1E5AAC
	dd	0x174D6123, 0x2F52F8AC, 0x1D20B96B, 0x2F87B6D7
	dd	0xE468E7C5, 0x2FBDA48C, 0x0EC190DC, 0x2FF286D8
	dd	0x1271F513, 0x3027288E, 0x970E7257, 0x305CF2B1
	dd	0xFE690777, 0x309217AE, 0xBE034954, 0x30C69D9A
	dd	0x6D841BA9, 0x30FC4501, 0xE472914A, 0x3131AB20
	dd	0x1D8F359D, 0x316615E9, 0x64F30304, 0x319B9B63
	dd	0x1F17E1E2, 0x31D1411E, 0xA6DDDA5B, 0x32059165
	dd	0x109550F1, 0x323AF5BF, 0x6A5D5296, 0x3270D997
	dd	0x44F4A73C, 0x32A50FFD, 0x9631D10B, 0x32DA53FC
	dd	0xDDDF22A7, 0x3310747D, 0x5556EB51, 0x3344919D
	dd	0xAAACA625, 0x3379B604, 0xEAABE7D8, 0x33B011C2
	dd	0xA556E1CD, 0x33E41633, 0x8EAC9A41, 0x34191BC0
	dd	0xB257C0D1, 0x344F62B0, 0x6F76D882, 0x34839DAE
	dd	0x0B548EA3, 0x34B8851A, 0x8E29B24D, 0x34EEA660
	dd	0x58DA0F70, 0x352327FC, 0x6F10934C, 0x3557F1FB
	dd	0x4AD4B81E, 0x358DEE7A, 0x6EC4F313, 0x35C2B50C
	dd	0x8A762FD8, 0x35F7624F, 0x6D13BBCE, 0x362D3AE3
	dd	0x242C5561, 0x366244CE, 0xAD376ABA, 0x3696D601
	dd	0x18854568, 0x36CC8B82, 0x4F534B61, 0x3701D731
	dd	0xA3281E39, 0x37364CFD, 0x0BF225C8, 0x376BE03D
	dd	0x2777579D, 0x37A16C26, 0xB1552D85, 0x37D5C72F
	dd	0x9DAA78E6, 0x380B38FB, 0x428A8B8F, 0x3841039D
	dd	0x932D2E73, 0x38754484, 0xB7F87A0F, 0x38AA95A5
	dd	0x92FB4C4A, 0x38E09D87, 0x77BA1F5C, 0x3914C4E9
	dd	0xD5A8A734, 0x3949F623, 0x65896880, 0x398039D6
	dd	0xFEEBC2A0, 0x39B4484B, 0xFEA6B348, 0x39E95A5E
	dd	0xBE50601A, 0x3A1FB0F6, 0x36F23C10, 0x3A53CE9A
	dd	0xC4AECB15, 0x3A88C240, 0xF5DA7DDA, 0x3ABEF2D0
	dd	0x99A88EA8, 0x3AF357C2, 0x4012B252, 0x3B282DB3
	dd	0x10175EE6, 0x3B5E3920, 0x0A0E9B4F, 0x3B92E3B4
	dd	0x0C924223, 0x3BC79CA1, 0x4FB6D2AC, 0x3BFD83C9
	dd	0xD1D243AC, 0x3C32725D, 0x4646D497, 0x3C670EF5
	dd	0x97D889BC, 0x3C9CD2B2, 0x9EE75616, 0x3CD203AF
	dd	0x86A12B9B, 0x3D06849B, 0x68497682, 0x3D3C25C2
	dd	0x812DEA11, 0x3D719799, 0xE1796495, 0x3DA5FD7F
	dd	0xD9D7BDBB, 0x3DDB7CDF, 0xE826D695, 0x3E112E0B
	dd	0xE2308C3A, 0x3E45798E, 0x9ABCAF48, 0x3E7AD7F2
	dd	0xA0B5ED8D, 0x3EB0C6F7, 0x88E368F1, 0x3EE4F8B5
	dd	0xEB1C432D, 0x3F1A36E2, 0xD2F1A9FC, 0x3F50624D
	dd	0x47AE147B, 0x3F847AE1, 0x9999999A, 0x3FB99999

%_pwr_10_to_0:
	dd	0x00000000, 0x3FF00000, 0x00000000, 0x40240000
	dd	0x00000000, 0x40590000, 0x00000000, 0x408F4000
	dd	0x00000000, 0x40C38800, 0x00000000, 0x40F86A00
	dd	0x00000000, 0x412E8480, 0x00000000, 0x416312D0
	dd	0x00000000, 0x4197D784, 0x00000000, 0x41CDCD65
	dd	0x20000000, 0x4202A05F, 0xE8000000, 0x42374876
	dd	0xA2000000, 0x426D1A94, 0xE5400000, 0x42A2309C
	dd	0x1E900000, 0x42D6BCC4, 0x26340000, 0x430C6BF5
	dd	0x37E08000, 0x4341C379, 0x85D8A000, 0x43763457
	dd	0x674EC800, 0x43ABC16D, 0x60913D00, 0x43E158E4
	dd	0x78B58C40, 0x4415AF1D, 0xD6E2EF50, 0x444B1AE4
	dd	0x064DD592, 0x4480F0CF, 0xC7E14AF6, 0x44B52D02
	dd	0x79D99DB4, 0x44EA7843, 0x2C280290, 0x45208B2A
	dd	0xB7320334, 0x4554ADF4, 0xE4FE8401, 0x4589D971
	dd	0x2F1F1281, 0x45C027E7, 0xFAE6D721, 0x45F431E0
	dd	0x39A08CE9, 0x46293E59, 0x8808B023, 0x465F8DEF
	dd	0xB5056E16, 0x4693B8B5, 0x2246C99C, 0x46C8A6E3
	dd	0xEAD87C03, 0x46FED09B, 0x72C74D82, 0x47334261
	dd	0xCF7920E2, 0x476812F9, 0x4357691A, 0x479E17B8
	dd	0x2A16A1B0, 0x47D2CED3, 0xF49C4A1C, 0x48078287
	dd	0xF1C35CA3, 0x483D6329, 0x371A19E6, 0x48725DFA
	dd	0xC4E0A060, 0x48A6F578, 0xF618C878, 0x48DCB2D6
	dd	0x59CF7D4B, 0x4911EFC6, 0xF0435C9E, 0x49466BB7
	dd	0xEC5433C6, 0x497C06A5, 0xB3B4A05C, 0x49B18427
	dd	0xA0A1C873, 0x49E5E531, 0x08CA3A90, 0x4A1B5E7E
	dd	0xC57E649A, 0x4A511B0E, 0x76DDFDC0, 0x4A8561D2
	dd	0x14957D30, 0x4ABABA47, 0x6CDD6E3E, 0x4AF0B46C
	dd	0x8814C9CE, 0x4B24E187, 0x6A19FC42, 0x4B5A19E9
	dd	0xE2503DA9, 0x4B905031, 0x5AE44D13, 0x4BC4643E
	dd	0xF19D6058, 0x4BF97D4D, 0x6E04B86E, 0x4C2FDCA1
	dd	0xE4C2F345, 0x4C63E9E4, 0x1DF3B016, 0x4C98E45E
	dd	0xA5709C1C, 0x4CCF1D75, 0x87666192, 0x4D037269
	dd	0xE93FF9F6, 0x4D384F03, 0xE38FF874, 0x4D6E62C4
	dd	0x0E39FB48, 0x4DA2FDBB, 0xD1C87A1A, 0x4DD7BD29
	dd	0x463A98A0, 0x4E0DAC74, 0xABE49F64, 0x4E428BC8
	dd	0xD6DDC73D, 0x4E772EBA, 0x8C95390C, 0x4EACFA69
	dd	0xF7DD43A8, 0x4EE21C81, 0x75D49492, 0x4F16A3A2
	dd	0x1349B9B6, 0x4F4C4C8B, 0xEC0E1412, 0x4F81AFD6
	dd	0xA7119916, 0x4FB61BCC, 0xD0D5FF5C, 0x4FEBA2BF
	dd	0xE285BF9A, 0x502145B7, 0xDB272F80, 0x50559725
	dd	0x51F0FB60, 0x508AFCEF, 0x93369D1C, 0x50C0DE15
	dd	0xF8044463, 0x50F5159A, 0xB605557C, 0x512A5B01
	dd	0x11C3556E, 0x516078E1, 0x56342ACA, 0x51949719
	dd	0xABC1357C, 0x51C9BCDF, 0xCB58C16E, 0x5200160B
	dd	0xBE2EF1CA, 0x52341B8E, 0x6DBAAE3C, 0x52692272
	dd	0x092959CB, 0x529F6B0F, 0x65B9D81F, 0x52D3A2E9
	dd	0xBF284E27, 0x53088BA3, 0xAEF261B1, 0x533EAE8C
	dd	0xED577D0F, 0x53732D17, 0xE8AD5C53, 0x53A7F85D
	dd	0x62D8B368, 0x53DDF675, 0x5DC77021, 0x5412BA09
	dd	0xB5394C29, 0x5447688B, 0xA2879F33, 0x547D42AE
	dd	0x2594C380, 0x54B249AD, 0x6EF9F460, 0x54E6DC18
	dd	0x8AB87178, 0x551C931E, 0x16B346EB, 0x5551DBF3
	dd	0xDC6018A6, 0x558652EF, 0xD3781ED0, 0x55BBE7AB
	dd	0x642B1342, 0x55F170CB, 0x3D35D812, 0x5625CCFE
	dd	0xCC834E16, 0x565B403D, 0x9FD210CE, 0x56910826
	dd	0x47C69502, 0x56C54A30, 0x59B83A42, 0x56FA9CBC
	dd	0xB8132469, 0x5730A1F5, 0x2617ED83, 0x5764CA73
	dd	0xEF9DE8E4, 0x5799FD0F, 0xF5C2B18E, 0x57D03E29
	dd	0x73335DF2, 0x58044DB4, 0x9000356E, 0x58396121
	dd	0xF40042CA, 0x586FB969, 0x388029BE, 0x58A3D3E2
	dd	0xC6A0342E, 0x58D8C8DA, 0x7848413A, 0x590EFB11
	dd	0xEB2D28C4, 0x59435CEA, 0xA5F872F5, 0x59783425
	dd	0x0F768FB2, 0x59AE412F, 0x69AA19CF, 0x59E2E8BD
	dd	0xC414A043, 0x5A17A2EC, 0xF519C854, 0x5A4D8BA7
	dd	0xF9301D34, 0x5A827748, 0x377C2481, 0x5AB7151B
	dd	0x055B2DA1, 0x5AECDA62, 0x4358FC85, 0x5B22087D
	dd	0x942F3BA6, 0x5B568A9C, 0xB93B0A90, 0x5B8C2D43
	dd	0x53C4E69A, 0x5BC19C4A, 0xE8B62040, 0x5BF6035C
	dd	0x22E3A850, 0x5C2B8434, 0x95CE4932, 0x5C6132A0
	dd	0xBB41DB7E, 0x5C957F48, 0xEA12525E, 0x5CCADF1A
	dd	0xD24B737B, 0x5D00CB70, 0x06DE505A, 0x5D34FE4D
	dd	0x4895E470, 0x5D6A3DE0, 0x2D5DAEC6, 0x5DA066AC
	dd	0x38B51A78, 0x5DD48057, 0x06E26116, 0x5E09A06D
	dd	0x244D7CAE, 0x5E400444, 0x2D60DBDA, 0x5E740555
	dd	0x78B912D0, 0x5EA906AA, 0x16E75784, 0x5EDF4855
	dd	0x2E5096B2, 0x5F138D35, 0x79E4BC5E, 0x5F487082
	dd	0x185DEB76, 0x5F7E8CA3, 0xEF3AB32A, 0x5FB317E5
	dd	0x6B095FF4, 0x5FE7DDDF, 0x45CBB7F1, 0x601DD557
	dd	0x8B9F52F7, 0x6052A556, 0x2E8727B5, 0x60874EAC
	dd	0x3A28F1A2, 0x60BD2257, 0x84599705, 0x60F23576
	dd	0x256FFCC6, 0x6126C2D4, 0x2ECBFBF8, 0x615C7389
	dd	0xBD3F7D7B, 0x6191C835, 0x2C8F5CDA, 0x61C63A43
	dd	0xF7B33410, 0x61FBC8D3, 0x7AD0008A, 0x62315D84
	dd	0x998400AC, 0x6265B4E5, 0xFFE500D7, 0x629B221E
	dd	0x5FEF2086, 0x62D0F553, 0x37EAE8A8, 0x630532A8
	dd	0x45E5A2D2, 0x633A7F52, 0x6BAF85C3, 0x63708F93
	dd	0x469B6734, 0x63A4B378, 0x58424101, 0x63D9E056
	dd	0xF72968A1, 0x64102C35, 0x74F3C2C9, 0x64443743
	dd	0x5230B37B, 0x64794514, 0x66BCE05A, 0x64AF9659
	dd	0xE0360C38, 0x64E3BDF7, 0xD8438F46, 0x6518AD75
	dd	0x4E547318, 0x654ED8D3, 0x10F4C7EF, 0x65834784
	dd	0x1531F9EB, 0x65B81965, 0x5A7E7866, 0x65EE1FBE
	dd	0xF88F0B40, 0x6622D3D6, 0xB6B2CE10, 0x665788CC
	dd	0xE45F8194, 0x668D6AFF, 0xEEBBB0FC, 0x66C262DF
	dd	0xEA6A9D3B, 0x66F6FB97, 0xE505448A, 0x672CBA7D
	dd	0xAF234AD6, 0x6761F48E, 0x5AEC1D8C, 0x679671B2
	dd	0xF1A724EF, 0x67CC0E1E, 0x57087715, 0x680188D3
	dd	0x2CCA94DA, 0x6835EB08, 0x37FD3A10, 0x686B65CA
	dd	0x62FE444A, 0x68A11F9E, 0xFBBDD55C, 0x68D56785
	dd	0x7AAD4AB3, 0x690AC167, 0xACAC4EB0, 0x6940B8E0
	dd	0xD7D7625C, 0x6974E718, 0x0DCD3AF3, 0x69AA20DF
	dd	0x68A044D8, 0x69E0548B, 0x42C8560E, 0x6A1469AE
	dd	0xD37A6B92, 0x6A498419, 0x48590676, 0x6A7FE520
	dd	0x2D37A40A, 0x6AB3EF34, 0x38858D0C, 0x6AE8EB01
	dd	0x86A6F04F, 0x6B1F25C1, 0xF4285631, 0x6B537798
	dd	0x31326BBD, 0x6B88557F, 0xFD7F06AC, 0x6BBE6ADE
	dd	0x5E6F642C, 0x6BF302CB, 0x360B3D37, 0x6C27C37E
	dd	0xC38E0C85, 0x6C5DB45D, 0x9A38C7D3, 0x6C9290BA
	dd	0x40C6F9C8, 0x6CC734E9, 0x90F8B83A, 0x6CFD0223
	dd	0x3A9B7324, 0x6D322156, 0xC9424FED, 0x6D66A9AB
	dd	0xBB92E3E8, 0x6D9C5416, 0x353BCE71, 0x6DD1B48E
	dd	0xC28AC20D, 0x6E0621B1, 0x332D7290, 0x6E3BAA1E
	dd	0xDFFC679A, 0x6E714A52, 0x97FB8180, 0x6EA59CE7
	dd	0x7DFA61E0, 0x6EDB0421, 0xEEBC7D2C, 0x6F10E294
	dd	0x2A6B9C77, 0x6F451B3A, 0xB5068395, 0x6F7A6208
	dd	0x7124123D, 0x6FB07D45, 0xCD6D16CC, 0x6FE49C96
	dd	0x80C85C7F, 0x7019C3BC, 0xD07D39CF, 0x70501A55
	dd	0x449C8843, 0x708420EB, 0x15C3AA54, 0x70B92926
	dd	0x9B3494E9, 0x70EF736F, 0xC100DD12, 0x7123A825
	dd	0x31411456, 0x7158922F, 0xFD91596C, 0x718EB6BA
	dd	0xDE7AD7E4, 0x71C33234, 0x16198DDD, 0x71F7FEC2
	dd	0x9B9FF154, 0x722DFE72, 0xA143F6D4, 0x7262BF07
	dd	0x8994F489, 0x72976EC9, 0xEBFA31AB, 0x72CD4A7B
	dd	0x737C5F0B, 0x73024E8D, 0xD05B76CE, 0x7336E230
	dd	0x04725482, 0x736C9ABD, 0x22C774D1, 0x73A1E0B6
	dd	0xAB795205, 0x73D658E3, 0x9657A686, 0x740BEF1C
	dd	0xDDF6C814, 0x74417571, 0x55747A19, 0x7475D2CE
	dd	0xEAD1989F, 0x74AB4781, 0x32C2FF63, 0x74E10CB1
	dd	0x7F73BF3C, 0x75154FDD, 0xDF50AF0B, 0x754AA3D4
	dd	0x0B926D67, 0x7580A665, 0x4E7708C1, 0x75B4CFFE
	dd	0xE214CAF1, 0x75EA03FD, 0xAD4CFED7, 0x7620427E
	dd	0x58A03E8D, 0x7654531E, 0xEEC84E30, 0x768967E5
	dd	0x6A7A61BC, 0x76BFC1DF, 0xA28C7D16, 0x76F3D92B
	dd	0x8B2F9C5C, 0x7728CF76, 0x2DFB8373, 0x775F0354
	dd	0x9CBD3228, 0x77936214, 0xC3EC7EB2, 0x77C83A99
	dd	0x34E79E5E, 0x77FE4940, 0x2110C2FB, 0x7832EDC8
	dd	0x2954F3BA, 0x7867A93A, 0xB3AA30A8, 0x789D9388
	dd	0x704A5E69, 0x78D27C35, 0xCC5CF603, 0x79071B42
	dd	0x7F743384, 0x793CE213, 0x2FA8A032, 0x79720D4C
	dd	0x3B92C83E, 0x79A6909F, 0x0A777A4E, 0x79DC34C7
	dd	0x668AAC71, 0x7A11A0FC, 0x802D578D, 0x7A46093B
	dd	0x6038AD70, 0x7A7B8B8A, 0x7C236C66, 0x7AB13736
	dd	0x1B2C4780, 0x7AE58504, 0x21F75960, 0x7B1AE645
	dd	0x353A97DC, 0x7B50CFEB, 0x02893DD3, 0x7B8503E6
	dd	0x832B8D48, 0x7BBA44DF, 0xB1FB384D, 0x7BF06B0B
	dd	0x9E7A0660, 0x7C2485CE, 0x461887F8, 0x7C59A742
	dd	0x6BCF54FB, 0x7C900889, 0xC6C32A3A, 0x7CC40AAB
	dd	0xB873F4C8, 0x7CF90D56, 0x6690F1FA, 0x7D2F50AC
	dd	0xC01A973C, 0x7D63926B, 0xB0213D0B, 0x7D987706
	dd	0x5C298C4E, 0x7DCE94C8, 0x3999F7B1, 0x7E031CFD
	dd	0x8800759D, 0x7E37E43C, 0xAA009304, 0x7E6DDD4B
	dd	0x4A405BE2, 0x7EA2AA4F, 0x1CD072DA, 0x7ED754E3
	dd	0xE4048F90, 0x7F0D2A1B, 0x6E82D9BA, 0x7F423A51
	dd	0xCA239028, 0x7F76C8E5, 0x3CAC7432, 0x7FAC7B1F
	dd	0x85EBC89F, 0x7FE1CCF3


; #################
; #####  END  #####
; #################
