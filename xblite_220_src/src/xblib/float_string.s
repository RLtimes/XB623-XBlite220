.text
; **************************
; *****  float.string  *****  creates decimal representation of st(0)
; **************************
;
; in:	st(0) = number to convert to string; MUST BE POSITIVE!
;	arg2 = prefix character, or 0 if no prefix character
;	arg1 = letter for exponent of scientific notation necessary
;	arg0 = maximum number of digits
; out:	eax -> result string (prefix character is prepended to result string)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> result string
;	[ebp-8]:[ebp-12] input number (double precision)
;	[ebp-16] = current digit
;	[ebp-20] = flag: do zeros get printed? (are we past leading zeros?)
;	[ebp-24] = exponent to print at end (if scientific notation)
;	[ebp-28] = FPU control-word buffer
;	[ebp-32] = on-entry FPU control word
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
; Result string is in scientific notation if:
;
;	number > 100000, or
;	number < 0.00001
;
.globl float.string
float.string:
push	ebp
mov	ebp,esp
sub	esp,32
mov	esi,30								;get room for at least 30 bytes to hold result
call	%_____calloc					;esi -> header of result string
add	esi,16								;esi -> result string
mov	[ebp-4],esi						;save it
mov	eax,0                 ;eax = system/user bit
or	eax,0x80130001					;info word indicates: allocated string
mov	[esi-4],eax						;store info word
mov	edi,esi								; edi=esi  (max added fix for STRING$(+value) 05/15/9
mov	eax,[ebp+16]					;eax = prefix character
or	eax,eax									;a null?
jz	short float_prefix_done ;yes: don't prepend a prefix
mov	[esi],al							;no: store it
lea	edi,[esi+1]						;edi -> character after prefix character
float_prefix_done:
fnstcw	word ptr [ebp-28] 	;get current control word
mov	bx,[ebp-28]						;bx = control word
mov	[ebp-32],bx						;save original control word
or	bx,0x0C00								;set rounding mode to: truncate
mov	[ebp-28],bx						;[ebp-28] = new control word
fldcw	word ptr [ebp-28] 	;truncation is on
fxam												;what sort of number is st(0)?
fstsw	ax
and	ah,0b01000101					;mask out all but C3, C2, and C0
movzx	ebx,ah							;build index into jump table in ebx
slr	ah,5									;shift C3 bit in between C2 and C0
or	bl,ah										;copy C3 bit into ebx
and	ebx,0b111							;just the lower three bits now
jmp	[fxam_table + ebx*4] 	;go to float_normal, float_zero,
;													; float_nan, or float_infinity, as
; appropriate
;
.globl float_normal
float_normal:							;we have ourselves a non-zero number to print
fst	qword ptr [ebp-12] 		;put input number into memory...
mov	[ebp-20],0						;mark that leading zeros don't get printed
xor	edx,edx								;clear digit counter
fwait
mov	ebx,[ebp-8]						;...so we can
slr	ebx,20								;extract its exponent
imul	ebx,0x4D1							;multiply exponent by .301 of 0x1000
slr	ebx,12								;div by 0x1000: ebx = exponent * 0.301
add	ebx,1									;ebx = index into %_pwr_10_table
fcom	qword ptr [hundred_thousand]
fstsw	ax									;greater than or equal to 100000 requires
sahf												; scientific notation
jae	float_scientific
fcom	qword ptr [hundred_thousandth]
fstsw	ax									;less than .00001 requires
sahf												; scientific notation
jb	float_scientific
mov	[ebp-24],0						;do not output trailing exponent
;                          ;if number < 1, make exponent 307
cmp	ebx,307								;is 1 > number > 0?
ja	short float_normalized 	;no: it's okay already
mov	ebx,307								;yes: start output at tenths digit
float_normalized:
mov	esi,ebx
sub	esi,[ebp+8]						;esi -> pwr of 10 of (non-)digit to right of
;													; least significant possible digit
jns	short float_round
xor	esi,esi								;if before beginning of table, point to 10^-308
jmp	short float_round_done
float_round:
fld	qword ptr [%_pwr_10_table + esi*8]
fld	qword ptr [ffive]
fmul												;multiply digit past last possible digit by 5
fadd												;round off number to maximum possible digits
inc	esi										;esi -> pwr of 10 of last possible digit
float_round_done:
fl_normal_loop:
cmp	ebx,307								;just crossed over into decimal land?
jne	short fl_digit				;nope
mov	al,'.'								;yep: output decimal point
stosb
mov	[ebp-20],1						;mark that zeros now get printed
fl_digit:
fld	st(0)									;save current number to st(1)
fdiv	qword ptr [%_pwr_10_table + ebx*8] ;div by current power of ten
frndint										;truncate to get current digit
fist	dword ptr [ebp-16] 		;write current digit to memory, and hold
; in st(0)
fwait
mov	al,[ebp-16]						;al = current digit
or	al,al										;a zero?
jnz	short fl_normal_digit ;no: output it unconditionally
cmp	[ebp-20],0						;are we past leading zeros?
jz	short fl_normal_digit_done ;no: move on to next digit
fl_normal_digit:
add	al,'0'								;convert digit to ASCII
stosb											;append it to result string
inc	edx										;bump digit counter
mov	[ebp-20],1						;mark that we're past leading zeros
fl_normal_digit_done:
fmul	qword ptr [%_pwr_10_table + ebx*8] ;digit * power of ten
fst	qword ptr [fdebug]		;DEBUG
fwait											;DEBUG
fwait											;DEBUG
fwait											;DEBUG
fsubp											;st(0) = what's left
fst	qword ptr [fdebug]		;DEBUG
fwait											;DEBUG
fwait											;DEBUG
fwait											;DEBUG
fld	qword ptr [%_pwr_10_table + esi*8] ;value of least significant
;													; possible digit
fcomp											;anything other than trailing zeros left
fstsw	ax									; to print?
sahf
ja	short fl_normal_zero		;no: print trailing zeros
dec	ebx										;bump current power of ten
cmp	edx,[ebp+8]						;reached maximum number of digits?
jae	short float_exponent 	;yes
jmp	fl_normal_loop
fl_normal_zero:						;number is down to zero (or close enough)
cmp	ebx,308								;any trailing zeros to print?
jbe	short float_exponent 	;no
mov	byte ptr [edi],'0' 		;yes: print one
inc	edi
dec	ebx										;next power of ten
jmp	fl_normal_zero
float_scientific:					;print a number with an exponent at the end
fl_find_1st_digit_loop:
fcom	qword ptr [%_pwr_10_table + ebx*8] ;number is >=
fstsw	ax				   				; current power of ten?
sahf
jae	short fl_got_first_digit
dec	ebx										;next lower power of ten
cmp	ebx,-308							;past end of table?
jl	float_zero							;yes: it's zero for all practical purposes
jmp	fl_find_1st_digit_loop
fl_got_first_digit:
lea	ecx,[ebx-308]					;ecx = exponent to append to number
mov	[ebp-24],ecx					;save it
neg	ecx										;ecx = offset relative to %_pwr_10_to_0 of
;													; negative of original exponent
fmul	qword ptr [%_pwr_10_to_0 + ecx*8] ;normalize number
; (i.e. put number in terms of 10^0)
fst	qword ptr [fdebug]		;DEBUG
fwait											;DEBUG
fwait											;DEBUG
fwait											;DEBUG
mov	ebx,308								;ebx = offset for 10^0
jmp	float_normalized 			;output the number; it should now be in
;													; range 1 <= number < 10
float_exponent:						;just finished printing mantissa
mov	ecx,[ebp-24]					;ecx = exponent
or	ecx,ecx									;need to print any exponent at all?
jz	short float_done 				;nope
mov	al,[ebp+12]						;al = exponent letter ('e' or 'd')
stosb											;append it to result string
mov	al,'+'								;pre-load with plus sign
;													;flags are still set from \"or ecx,ecx\"
jns	short fl_exp_sign 		;yes: plus sign is correct
mov	al,'-'								;no: minus sign for negative exponent
neg	ecx										;and now force exponent positive
fl_exp_sign:
stosb											;append sign to result string
mov	eax,ecx								;eax = exponent
mov	ecx,100
cmp	eax,ecx								;exponent has three digits?
jb	short fl_exp_two_digits ;no: maybe it has two digits
xor	edx,edx								;clear high 32 bits of numerator
idiv	ecx										;eax = # of hundreds, edx = what's left
add	eax,'0'								;convert to ASCII
stosb											;append hundreds digit to result string
mov	eax,edx								;eax = what's left of exponent
mov	ecx,10
jmp	short fl_exp_tens_digit
;
fl_exp_two_digits:
mov	ecx,10
cmp	eax,ecx								;exponent has two digits?
jb	short fl_exp_last_digit ;no: only one digit
;;
fl_exp_tens_digit:
xor	edx,edx								;clear high 32 bits of numerator
idiv	ecx										;eax = # of tens, edx = units
add	eax,'0'								;convert to ASCII
stosb											;append tens digit to result string
mov	eax,edx								;eax = units
fl_exp_last_digit:
add	eax,'0'								;convert to ASCII
stosb											;append units digit to result string
jmp	float_done
;
.globl float_nan
float_nan:
mov	al,'N'								;just send \"NAN\" to result string
stosb
mov	al,'A'
stosb
mov	al,'N'
stosb
jmp	short float_done
;
.globl float_infinity
float_infinity:
mov	al,'i'								;just send \"inf\" to result string
stosb
mov	al,'n'
stosb
mov	al,'f'
stosb
jmp	short float_done
;
.globl float_zero
float_zero:								;just send \"0\" to result string
mov	al,'0'
stosb
;;
;; fall through
;;
float_done:								;assumes edi -> char after last char of result
fstp	st(0)									;pop input number; clear FPU stack
mov	esi,edi								;esi also -> char after last char
mov	eax,[ebp-4]						;eax -> result string
sub	esi,eax								;esi = LEN(result string)
mov	[eax-8],esi						;save string length
mov	byte ptr [edi],0 			;write terminating null
fldcw	word ptr [ebp-32] 	;restore on-entry rounding mode
mov	esp,ebp
pop	ebp
ret												;return with eax -> result string
;
;
.align	8
fxam_table:		;jump table for values of C2, C3, C0 bits of FPU
; after FXAM
.dword	float_nan	;C2 = 0   C3 = 0   C0 = 0
.dword	float_nan	;     0        0        1
.dword	float_zero	;     0        1        0
.dword	float_nan	;     0        1        1
.dword	float_normal	;     1        0        0
.dword	float_infinity	;     1        0        1
.dword	float_normal	;     1        1        0
.dword	float_nan	;     1        1        1
;
.align	8
hundred_thousand:
.dword	0x0, 0x40F86A00
;
hundred_thousandth:
.dword	0x88E368F1, 0x3EE4F8B5
;
;
ffive:	.dword	0x0, 0x40140000
;
.data
.align	8
fdebug:	.dword	0,0,0,0		; DEBUG (often ends up with status word to check floa
;
.text
.align	8
%_pwr_10_table:
.dword	0x7819E8D3, 0x000730D6, 0x2C40C60E, 0x0031FA18
.dword	0x3750F792, 0x0066789E, 0xC5253576, 0x009C16C5
.dword	0x9B374169, 0x00D18E3B, 0x820511C3, 0x0105F1CA
.dword	0x22865634, 0x013B6E3D, 0x3593F5E0, 0x017124E6
.dword	0xC2F8F358, 0x01A56E1F, 0xB3B7302D, 0x01DAC9A7
.dword	0xD0527E1D, 0x0210BE08, 0x04671DA4, 0x0244ED8B
.dword	0xC580E50D, 0x027A28ED, 0x9B708F28, 0x02B05994
.dword	0xC24CB2F2, 0x02E46FF9, 0x32DFDFAE, 0x03198BF8
.dword	0x3F97D799, 0x034FEEF6, 0xE7BEE6C0, 0x0383F559
.dword	0x61AEA070, 0x03B8F2B0, 0x7A1A488B, 0x03EF2F5C
.dword	0xCC506D57, 0x04237D99, 0x3F6488AD, 0x04585D00
.dword	0x4F3DAAD8, 0x048E7440, 0x31868AC7, 0x04C308A8
.dword	0x3DE82D79, 0x04F7CAD2, 0xCD6238D8, 0x052DBD86
.dword	0x405D6387, 0x05629674, 0x5074BC69, 0x05973C11
.dword	0xA491EB82, 0x05CD0B15, 0x86DB3332, 0x060226ED
.dword	0xE891FFFF, 0x0636B0A8, 0x22B67FFE, 0x066C5CD3
.dword	0xF5B20FFE, 0x06A1BA03, 0xF31E93FE, 0x06D62884
.dword	0x2FE638FD, 0x070BB2A6, 0xDDEFE39E, 0x07414FA7
.dword	0xD56BDC85, 0x0775A391, 0x4AC6D3A7, 0x07AB0C76
.dword	0xEEBC4448, 0x07E0E7C9, 0x6A6B555A, 0x081521BC
.dword	0x85062AB1, 0x084A6A2B, 0x3323DAAF, 0x0880825B
.dword	0xFFECD15A, 0x08B4A2F1, 0x7FE805B1, 0x08E9CBAE
.dword	0x0FF1038F, 0x09201F4D, 0x53ED4473, 0x09542720
.dword	0x68E89590, 0x098930E8, 0x8322BAF4, 0x09BF7D22
.dword	0x91F5B4D9, 0x09F3AE35, 0xF673220F, 0x0A2899C2
.dword	0xB40FEA93, 0x0A5EC033, 0x5089F29C, 0x0A933820
.dword	0x64AC6F43, 0x0AC80628, 0x7DD78B14, 0x0AFE07B2
.dword	0x8EA6B6EC, 0x0B32C4CF, 0x725064A7, 0x0B677603
.dword	0x4EE47DD1, 0x0B9D5384, 0xB14ECEA3, 0x0BD25432
.dword	0x5DA2824B, 0x0C06E93F, 0x350B22DE, 0x0C3CA38F
.dword	0x8126F5CA, 0x0C71E639, 0xE170B33D, 0x0CA65FC7
.dword	0xD9CCE00D, 0x0CDBF7B9, 0x28200C08, 0x0D117AD4
.dword	0x32280F0A, 0x0D45D989, 0x7EB212CC, 0x0D7B4FEB
.dword	0x2F2F4BBF, 0x0DB111F3, 0xFAFB1EAF, 0x0DE5566F
.dword	0xF9B9E65B, 0x0E1AAC0B, 0x7C142FF9, 0x0E50AB87
.dword	0x5B193BF8, 0x0E84D669, 0xB1DF8AF5, 0x0EBA0C03
.dword	0x4F2BB6DA, 0x0EF04782, 0xE2F6A490, 0x0F245962
.dword	0x9BB44DB4, 0x0F596FBB, 0x82A16122, 0x0F8FCBAA
.dword	0x91A4DCB5, 0x0FC3DF4A, 0x360E13E2, 0x0FF8D71D
.dword	0x839198DA, 0x102F0CE4, 0xD23AFF88, 0x1063680E
.dword	0x86C9BF6A, 0x10984212, 0x287C2F45, 0x10CE5297
.dword	0x794D9D8B, 0x1102F39E, 0x17A104EE, 0x1137B086
.dword	0x9D894628, 0x116D9CA7, 0xC275CBD9, 0x11A281E8
.dword	0xF3133ECF, 0x11D72262, 0xAFD80E83, 0x120CEAFB
.dword	0x4DE70912, 0x124212DD, 0xA160CB56, 0x12769794
.dword	0xC9B8FE2C, 0x12AC3D79, 0x1E139EDB, 0x12E1A66C
.dword	0x25988692, 0x13161007, 0xEEFEA836, 0x134B9408
.dword	0x955F2922, 0x13813C85, 0xFAB6F36B, 0x13B58BA6
.dword	0xB964B045, 0x13EAEE90, 0x73DEEE2C, 0x1420D51A
.dword	0x10D6A9B6, 0x14550A61, 0x550C5424, 0x148A4CF9
.dword	0xD527B496, 0x14C0701B, 0xCA71A1BC, 0x14F48C22
.dword	0x7D0E0A2A, 0x1529AF2B, 0x2E28C65A, 0x15600D7B
.dword	0xF9B2F7F1, 0x159410D9, 0x781FB5ED, 0x15C91510
.dword	0x9627A369, 0x15FF5A54, 0xDDD8C622, 0x16339874
.dword	0x154EF7AA, 0x16687E92, 0x9AA2B594, 0x169E9E36
.dword	0x20A5B17D, 0x16D322E2, 0xA8CF1DDC, 0x1707EB9A
.dword	0x5302E553, 0x173DE681, 0xD3E1CF54, 0x1772B010
.dword	0x08DA4328, 0x17A75C15, 0x4B10D3F2, 0x17DD331A
.dword	0x6EEA8477, 0x18123FF0, 0x8AA52594, 0x1846CFEC
.dword	0xAD4E6EFA, 0x187C83E7, 0xCC51055C, 0x18B1D270
.dword	0xFF6546B3, 0x18E6470C, 0x3F3E9860, 0x191BD8D0
.dword	0x27871F3C, 0x19516782, 0xB168E70A, 0x1985C162
.dword	0x5DC320CD, 0x19BB31BB, 0x1A99F480, 0x19F0FF15
.dword	0x614071A1, 0x1A253EDA, 0xF9908E09, 0x1A5A8E90
.dword	0x9BFA58C6, 0x1A90991A, 0x42F8EEF7, 0x1AC4BF61
.dword	0x93B72AB5, 0x1AF9EF39, 0xFC527AB1, 0x1B303583
.dword	0xFB67195E, 0x1B6442E4, 0x3A40DFB5, 0x1B99539E
.dword	0xC8D117A2, 0x1BCFA885, 0x9D82AEC5, 0x1C03C953
.dword	0x84E35A77, 0x1C38BBA8, 0xA61C3115, 0x1C6EEA92
.dword	0xA7D19EAD, 0x1CA3529B, 0x91C60658, 0x1CD82742
.dword	0x363787EF, 0x1D0E3113, 0x01E2B4F5, 0x1D42DEAC
.dword	0x025B6232, 0x1D779657, 0xC2F23ABE, 0x1DAD7BEC
.dword	0xF9D764B7, 0x1DE26D73, 0xF84D3DE4, 0x1E1708D0
.dword	0x36608D5D, 0x1E4CCB05, 0x41FC585A, 0x1E81FEE3
.dword	0x127B6E71, 0x1EB67E9C, 0x171A4A0D, 0x1EEC1E43
.dword	0xEE706E48, 0x1F2192E9, 0x6A0C89DA, 0x1F55F7A4
.dword	0x848FAC50, 0x1F8B758D, 0x72D9CBB3, 0x1FC12978
.dword	0x8F903E9F, 0x1FF573D6, 0x33744E46, 0x202AD0CC
.dword	0xA028B0EC, 0x2060C27F, 0x8832DD28, 0x2094F31F
.dword	0x6A3F9471, 0x20CA2FE7, 0xA267BCC6, 0x21005DF0
.dword	0xCB01ABF8, 0x2134756C, 0xFDC216F5, 0x216992C7
.dword	0xFD329CB3, 0x219FF779, 0x3E3FA1F0, 0x21D3FAAC
.dword	0x4DCF8A6D, 0x2208F957, 0x21436D08, 0x223F37AD
.dword	0x34CA2425, 0x227382CC, 0x41FCAD2E, 0x22A8637F
.dword	0x127BD87A, 0x22DE7C5F, 0x6B8D674D, 0x23130DBB
.dword	0x4670C120, 0x2347D12A, 0xD80CF167, 0x237DC574
.dword	0x070816E1, 0x23B29B69, 0x48CA1C99, 0x23E74243
.dword	0x1AFCA3BE, 0x241D12D4, 0x90DDE657, 0x24522BC4
.dword	0xB5155FED, 0x2486B6B5, 0x225AB7E8, 0x24BC6463
.dword	0xF578B2F1, 0x24F1BEBD, 0x72D6DFAE, 0x25262E6D
.dword	0xCF8C9799, 0x255BBA08, 0x81B7DEBF, 0x25915445
.dword	0xE225D66F, 0x25C5A956, 0x9AAF4C0B, 0x25FB13AC
.dword	0xE0AD8F87, 0x2630EC4B, 0xD8D8F368, 0x2665275E
.dword	0x8F0F3042, 0x269A7136, 0x19697E29, 0x26D086C2
.dword	0x9FC3DDB4, 0x2704A872, 0x47B4D521, 0x2739D28F
.dword	0x8CD10535, 0x27702399, 0xF0054682, 0x27A42C7F
.dword	0xEC069822, 0x27D9379F, 0xE7083E2C, 0x280F8587
.dword	0xF06526DB, 0x2843B374, 0x2C7E7091, 0x2878A052
.dword	0xB79E0CB5, 0x28AEC866, 0x32C2C7F1, 0x28E33D40
.dword	0x3F7379ED, 0x29180C90, 0x4F505869, 0x294E0FB4
.dword	0xB1923742, 0x2982C9D0, 0xDDF6C512, 0x29B77C44
.dword	0x15747656, 0x29ED5B56, 0xCD68C9F6, 0x2A225915
.dword	0x40C2FC73, 0x2A56EF5B, 0x10F3BB91, 0x2A8CAB32
.dword	0x4A98553A, 0x2AC1EAFF, 0x1D3E6A89, 0x2AF665BF
.dword	0xE48E052B, 0x2B2BFF2E, 0x4ED8C33B, 0x2B617F7D
.dword	0xA28EF40A, 0x2B95DF5C, 0xCB32B10C, 0x2BCB5733
.dword	0x5EFFAEA7, 0x2C011680, 0x76BF9A51, 0x2C355C20
.dword	0x946F80E6, 0x2C6AB328, 0x5CC5B090, 0x2CA0AFF9
.dword	0xB3F71CB4, 0x2CD4DBF7, 0xA0F4E3E2, 0x2D0A12F5
.dword	0x84990E6D, 0x2D404BD9, 0xE5BF5208, 0x2D745ECF
.dword	0xDF2F268A, 0x2DA97683, 0xD6FAF02D, 0x2DDFD424
.dword	0x065CD61D, 0x2E13E497, 0xC7F40BA4, 0x2E48DDBC
.dword	0xF9F10E8D, 0x2E7F152B, 0x7C36A919, 0x2EB36D3B
.dword	0x5B44535F, 0x2EE8488A, 0xF2156837, 0x2F1E5AAC
.dword	0x174D6123, 0x2F52F8AC, 0x1D20B96B, 0x2F87B6D7
.dword	0xE468E7C5, 0x2FBDA48C, 0x0EC190DC, 0x2FF286D8
.dword	0x1271F513, 0x3027288E, 0x970E7257, 0x305CF2B1
.dword	0xFE690777, 0x309217AE, 0xBE034954, 0x30C69D9A
.dword	0x6D841BA9, 0x30FC4501, 0xE472914A, 0x3131AB20
.dword	0x1D8F359D, 0x316615E9, 0x64F30304, 0x319B9B63
.dword	0x1F17E1E2, 0x31D1411E, 0xA6DDDA5B, 0x32059165
.dword	0x109550F1, 0x323AF5BF, 0x6A5D5296, 0x3270D997
.dword	0x44F4A73C, 0x32A50FFD, 0x9631D10B, 0x32DA53FC
.dword	0xDDDF22A7, 0x3310747D, 0x5556EB51, 0x3344919D
.dword	0xAAACA625, 0x3379B604, 0xEAABE7D8, 0x33B011C2
.dword	0xA556E1CD, 0x33E41633, 0x8EAC9A41, 0x34191BC0
.dword	0xB257C0D1, 0x344F62B0, 0x6F76D882, 0x34839DAE
.dword	0x0B548EA3, 0x34B8851A, 0x8E29B24D, 0x34EEA660
.dword	0x58DA0F70, 0x352327FC, 0x6F10934C, 0x3557F1FB
.dword	0x4AD4B81E, 0x358DEE7A, 0x6EC4F313, 0x35C2B50C
.dword	0x8A762FD8, 0x35F7624F, 0x6D13BBCE, 0x362D3AE3
.dword	0x242C5561, 0x366244CE, 0xAD376ABA, 0x3696D601
.dword	0x18854568, 0x36CC8B82, 0x4F534B61, 0x3701D731
.dword	0xA3281E39, 0x37364CFD, 0x0BF225C8, 0x376BE03D
.dword	0x2777579D, 0x37A16C26, 0xB1552D85, 0x37D5C72F
.dword	0x9DAA78E6, 0x380B38FB, 0x428A8B8F, 0x3841039D
.dword	0x932D2E73, 0x38754484, 0xB7F87A0F, 0x38AA95A5
.dword	0x92FB4C4A, 0x38E09D87, 0x77BA1F5C, 0x3914C4E9
.dword	0xD5A8A734, 0x3949F623, 0x65896880, 0x398039D6
.dword	0xFEEBC2A0, 0x39B4484B, 0xFEA6B348, 0x39E95A5E
.dword	0xBE50601A, 0x3A1FB0F6, 0x36F23C10, 0x3A53CE9A
.dword	0xC4AECB15, 0x3A88C240, 0xF5DA7DDA, 0x3ABEF2D0
.dword	0x99A88EA8, 0x3AF357C2, 0x4012B252, 0x3B282DB3
.dword	0x10175EE6, 0x3B5E3920, 0x0A0E9B4F, 0x3B92E3B4
.dword	0x0C924223, 0x3BC79CA1, 0x4FB6D2AC, 0x3BFD83C9
.dword	0xD1D243AC, 0x3C32725D, 0x4646D497, 0x3C670EF5
.dword	0x97D889BC, 0x3C9CD2B2, 0x9EE75616, 0x3CD203AF
.dword	0x86A12B9B, 0x3D06849B, 0x68497682, 0x3D3C25C2
.dword	0x812DEA11, 0x3D719799, 0xE1796495, 0x3DA5FD7F
.dword	0xD9D7BDBB, 0x3DDB7CDF, 0xE826D695, 0x3E112E0B
.dword	0xE2308C3A, 0x3E45798E, 0x9ABCAF48, 0x3E7AD7F2
.dword	0xA0B5ED8D, 0x3EB0C6F7, 0x88E368F1, 0x3EE4F8B5
.dword	0xEB1C432D, 0x3F1A36E2, 0xD2F1A9FC, 0x3F50624D
.dword	0x47AE147B, 0x3F847AE1, 0x9999999A, 0x3FB99999
%_pwr_10_to_0:
.dword	0x00000000, 0x3FF00000, 0x00000000, 0x40240000
.dword	0x00000000, 0x40590000, 0x00000000, 0x408F4000
.dword	0x00000000, 0x40C38800, 0x00000000, 0x40F86A00
.dword	0x00000000, 0x412E8480, 0x00000000, 0x416312D0
.dword	0x00000000, 0x4197D784, 0x00000000, 0x41CDCD65
.dword	0x20000000, 0x4202A05F, 0xE8000000, 0x42374876
.dword	0xA2000000, 0x426D1A94, 0xE5400000, 0x42A2309C
.dword	0x1E900000, 0x42D6BCC4, 0x26340000, 0x430C6BF5
.dword	0x37E08000, 0x4341C379, 0x85D8A000, 0x43763457
.dword	0x674EC800, 0x43ABC16D, 0x60913D00, 0x43E158E4
.dword	0x78B58C40, 0x4415AF1D, 0xD6E2EF50, 0x444B1AE4
.dword	0x064DD592, 0x4480F0CF, 0xC7E14AF6, 0x44B52D02
.dword	0x79D99DB4, 0x44EA7843, 0x2C280290, 0x45208B2A
.dword	0xB7320334, 0x4554ADF4, 0xE4FE8401, 0x4589D971
.dword	0x2F1F1281, 0x45C027E7, 0xFAE6D721, 0x45F431E0
.dword	0x39A08CE9, 0x46293E59, 0x8808B023, 0x465F8DEF
.dword	0xB5056E16, 0x4693B8B5, 0x2246C99C, 0x46C8A6E3
.dword	0xEAD87C03, 0x46FED09B, 0x72C74D82, 0x47334261
.dword	0xCF7920E2, 0x476812F9, 0x4357691A, 0x479E17B8
.dword	0x2A16A1B0, 0x47D2CED3, 0xF49C4A1C, 0x48078287
.dword	0xF1C35CA3, 0x483D6329, 0x371A19E6, 0x48725DFA
.dword	0xC4E0A060, 0x48A6F578, 0xF618C878, 0x48DCB2D6
.dword	0x59CF7D4B, 0x4911EFC6, 0xF0435C9E, 0x49466BB7
.dword	0xEC5433C6, 0x497C06A5, 0xB3B4A05C, 0x49B18427
.dword	0xA0A1C873, 0x49E5E531, 0x08CA3A90, 0x4A1B5E7E
.dword	0xC57E649A, 0x4A511B0E, 0x76DDFDC0, 0x4A8561D2
.dword	0x14957D30, 0x4ABABA47, 0x6CDD6E3E, 0x4AF0B46C
.dword	0x8814C9CE, 0x4B24E187, 0x6A19FC42, 0x4B5A19E9
.dword	0xE2503DA9, 0x4B905031, 0x5AE44D13, 0x4BC4643E
.dword	0xF19D6058, 0x4BF97D4D, 0x6E04B86E, 0x4C2FDCA1
.dword	0xE4C2F345, 0x4C63E9E4, 0x1DF3B016, 0x4C98E45E
.dword	0xA5709C1C, 0x4CCF1D75, 0x87666192, 0x4D037269
.dword	0xE93FF9F6, 0x4D384F03, 0xE38FF874, 0x4D6E62C4
.dword	0x0E39FB48, 0x4DA2FDBB, 0xD1C87A1A, 0x4DD7BD29
.dword	0x463A98A0, 0x4E0DAC74, 0xABE49F64, 0x4E428BC8
.dword	0xD6DDC73D, 0x4E772EBA, 0x8C95390C, 0x4EACFA69
.dword	0xF7DD43A8, 0x4EE21C81, 0x75D49492, 0x4F16A3A2
.dword	0x1349B9B6, 0x4F4C4C8B, 0xEC0E1412, 0x4F81AFD6
.dword	0xA7119916, 0x4FB61BCC, 0xD0D5FF5C, 0x4FEBA2BF
.dword	0xE285BF9A, 0x502145B7, 0xDB272F80, 0x50559725
.dword	0x51F0FB60, 0x508AFCEF, 0x93369D1C, 0x50C0DE15
.dword	0xF8044463, 0x50F5159A, 0xB605557C, 0x512A5B01
.dword	0x11C3556E, 0x516078E1, 0x56342ACA, 0x51949719
.dword	0xABC1357C, 0x51C9BCDF, 0xCB58C16E, 0x5200160B
.dword	0xBE2EF1CA, 0x52341B8E, 0x6DBAAE3C, 0x52692272
.dword	0x092959CB, 0x529F6B0F, 0x65B9D81F, 0x52D3A2E9
.dword	0xBF284E27, 0x53088BA3, 0xAEF261B1, 0x533EAE8C
.dword	0xED577D0F, 0x53732D17, 0xE8AD5C53, 0x53A7F85D
.dword	0x62D8B368, 0x53DDF675, 0x5DC77021, 0x5412BA09
.dword	0xB5394C29, 0x5447688B, 0xA2879F33, 0x547D42AE
.dword	0x2594C380, 0x54B249AD, 0x6EF9F460, 0x54E6DC18
.dword	0x8AB87178, 0x551C931E, 0x16B346EB, 0x5551DBF3
.dword	0xDC6018A6, 0x558652EF, 0xD3781ED0, 0x55BBE7AB
.dword	0x642B1342, 0x55F170CB, 0x3D35D812, 0x5625CCFE
.dword	0xCC834E16, 0x565B403D, 0x9FD210CE, 0x56910826
.dword	0x47C69502, 0x56C54A30, 0x59B83A42, 0x56FA9CBC
.dword	0xB8132469, 0x5730A1F5, 0x2617ED83, 0x5764CA73
.dword	0xEF9DE8E4, 0x5799FD0F, 0xF5C2B18E, 0x57D03E29
.dword	0x73335DF2, 0x58044DB4, 0x9000356E, 0x58396121
.dword	0xF40042CA, 0x586FB969, 0x388029BE, 0x58A3D3E2
.dword	0xC6A0342E, 0x58D8C8DA, 0x7848413A, 0x590EFB11
.dword	0xEB2D28C4, 0x59435CEA, 0xA5F872F5, 0x59783425
.dword	0x0F768FB2, 0x59AE412F, 0x69AA19CF, 0x59E2E8BD
.dword	0xC414A043, 0x5A17A2EC, 0xF519C854, 0x5A4D8BA7
.dword	0xF9301D34, 0x5A827748, 0x377C2481, 0x5AB7151B
.dword	0x055B2DA1, 0x5AECDA62, 0x4358FC85, 0x5B22087D
.dword	0x942F3BA6, 0x5B568A9C, 0xB93B0A90, 0x5B8C2D43
.dword	0x53C4E69A, 0x5BC19C4A, 0xE8B62040, 0x5BF6035C
.dword	0x22E3A850, 0x5C2B8434, 0x95CE4932, 0x5C6132A0
.dword	0xBB41DB7E, 0x5C957F48, 0xEA12525E, 0x5CCADF1A
.dword	0xD24B737B, 0x5D00CB70, 0x06DE505A, 0x5D34FE4D
.dword	0x4895E470, 0x5D6A3DE0, 0x2D5DAEC6, 0x5DA066AC
.dword	0x38B51A78, 0x5DD48057, 0x06E26116, 0x5E09A06D
.dword	0x244D7CAE, 0x5E400444, 0x2D60DBDA, 0x5E740555
.dword	0x78B912D0, 0x5EA906AA, 0x16E75784, 0x5EDF4855
.dword	0x2E5096B2, 0x5F138D35, 0x79E4BC5E, 0x5F487082
.dword	0x185DEB76, 0x5F7E8CA3, 0xEF3AB32A, 0x5FB317E5
.dword	0x6B095FF4, 0x5FE7DDDF, 0x45CBB7F1, 0x601DD557
.dword	0x8B9F52F7, 0x6052A556, 0x2E8727B5, 0x60874EAC
.dword	0x3A28F1A2, 0x60BD2257, 0x84599705, 0x60F23576
.dword	0x256FFCC6, 0x6126C2D4, 0x2ECBFBF8, 0x615C7389
.dword	0xBD3F7D7B, 0x6191C835, 0x2C8F5CDA, 0x61C63A43
.dword	0xF7B33410, 0x61FBC8D3, 0x7AD0008A, 0x62315D84
.dword	0x998400AC, 0x6265B4E5, 0xFFE500D7, 0x629B221E
.dword	0x5FEF2086, 0x62D0F553, 0x37EAE8A8, 0x630532A8
.dword	0x45E5A2D2, 0x633A7F52, 0x6BAF85C3, 0x63708F93
.dword	0x469B6734, 0x63A4B378, 0x58424101, 0x63D9E056
.dword	0xF72968A1, 0x64102C35, 0x74F3C2C9, 0x64443743
.dword	0x5230B37B, 0x64794514, 0x66BCE05A, 0x64AF9659
.dword	0xE0360C38, 0x64E3BDF7, 0xD8438F46, 0x6518AD75
.dword	0x4E547318, 0x654ED8D3, 0x10F4C7EF, 0x65834784
.dword	0x1531F9EB, 0x65B81965, 0x5A7E7866, 0x65EE1FBE
.dword	0xF88F0B40, 0x6622D3D6, 0xB6B2CE10, 0x665788CC
.dword	0xE45F8194, 0x668D6AFF, 0xEEBBB0FC, 0x66C262DF
.dword	0xEA6A9D3B, 0x66F6FB97, 0xE505448A, 0x672CBA7D
.dword	0xAF234AD6, 0x6761F48E, 0x5AEC1D8C, 0x679671B2
.dword	0xF1A724EF, 0x67CC0E1E, 0x57087715, 0x680188D3
.dword	0x2CCA94DA, 0x6835EB08, 0x37FD3A10, 0x686B65CA
.dword	0x62FE444A, 0x68A11F9E, 0xFBBDD55C, 0x68D56785
.dword	0x7AAD4AB3, 0x690AC167, 0xACAC4EB0, 0x6940B8E0
.dword	0xD7D7625C, 0x6974E718, 0x0DCD3AF3, 0x69AA20DF
.dword	0x68A044D8, 0x69E0548B, 0x42C8560E, 0x6A1469AE
.dword	0xD37A6B92, 0x6A498419, 0x48590676, 0x6A7FE520
.dword	0x2D37A40A, 0x6AB3EF34, 0x38858D0C, 0x6AE8EB01
.dword	0x86A6F04F, 0x6B1F25C1, 0xF4285631, 0x6B537798
.dword	0x31326BBD, 0x6B88557F, 0xFD7F06AC, 0x6BBE6ADE
.dword	0x5E6F642C, 0x6BF302CB, 0x360B3D37, 0x6C27C37E
.dword	0xC38E0C85, 0x6C5DB45D, 0x9A38C7D3, 0x6C9290BA
.dword	0x40C6F9C8, 0x6CC734E9, 0x90F8B83A, 0x6CFD0223
.dword	0x3A9B7324, 0x6D322156, 0xC9424FED, 0x6D66A9AB
.dword	0xBB92E3E8, 0x6D9C5416, 0x353BCE71, 0x6DD1B48E
.dword	0xC28AC20D, 0x6E0621B1, 0x332D7290, 0x6E3BAA1E
.dword	0xDFFC679A, 0x6E714A52, 0x97FB8180, 0x6EA59CE7
.dword	0x7DFA61E0, 0x6EDB0421, 0xEEBC7D2C, 0x6F10E294
.dword	0x2A6B9C77, 0x6F451B3A, 0xB5068395, 0x6F7A6208
.dword	0x7124123D, 0x6FB07D45, 0xCD6D16CC, 0x6FE49C96
.dword	0x80C85C7F, 0x7019C3BC, 0xD07D39CF, 0x70501A55
.dword	0x449C8843, 0x708420EB, 0x15C3AA54, 0x70B92926
.dword	0x9B3494E9, 0x70EF736F, 0xC100DD12, 0x7123A825
.dword	0x31411456, 0x7158922F, 0xFD91596C, 0x718EB6BA
.dword	0xDE7AD7E4, 0x71C33234, 0x16198DDD, 0x71F7FEC2
.dword	0x9B9FF154, 0x722DFE72, 0xA143F6D4, 0x7262BF07
.dword	0x8994F489, 0x72976EC9, 0xEBFA31AB, 0x72CD4A7B
.dword	0x737C5F0B, 0x73024E8D, 0xD05B76CE, 0x7336E230
.dword	0x04725482, 0x736C9ABD, 0x22C774D1, 0x73A1E0B6
.dword	0xAB795205, 0x73D658E3, 0x9657A686, 0x740BEF1C
.dword	0xDDF6C814, 0x74417571, 0x55747A19, 0x7475D2CE
.dword	0xEAD1989F, 0x74AB4781, 0x32C2FF63, 0x74E10CB1
.dword	0x7F73BF3C, 0x75154FDD, 0xDF50AF0B, 0x754AA3D4
.dword	0x0B926D67, 0x7580A665, 0x4E7708C1, 0x75B4CFFE
.dword	0xE214CAF1, 0x75EA03FD, 0xAD4CFED7, 0x7620427E
.dword	0x58A03E8D, 0x7654531E, 0xEEC84E30, 0x768967E5
.dword	0x6A7A61BC, 0x76BFC1DF, 0xA28C7D16, 0x76F3D92B
.dword	0x8B2F9C5C, 0x7728CF76, 0x2DFB8373, 0x775F0354
.dword	0x9CBD3228, 0x77936214, 0xC3EC7EB2, 0x77C83A99
.dword	0x34E79E5E, 0x77FE4940, 0x2110C2FB, 0x7832EDC8
.dword	0x2954F3BA, 0x7867A93A, 0xB3AA30A8, 0x789D9388
.dword	0x704A5E69, 0x78D27C35, 0xCC5CF603, 0x79071B42
.dword	0x7F743384, 0x793CE213, 0x2FA8A032, 0x79720D4C
.dword	0x3B92C83E, 0x79A6909F, 0x0A777A4E, 0x79DC34C7
.dword	0x668AAC71, 0x7A11A0FC, 0x802D578D, 0x7A46093B
.dword	0x6038AD70, 0x7A7B8B8A, 0x7C236C66, 0x7AB13736
.dword	0x1B2C4780, 0x7AE58504, 0x21F75960, 0x7B1AE645
.dword	0x353A97DC, 0x7B50CFEB, 0x02893DD3, 0x7B8503E6
.dword	0x832B8D48, 0x7BBA44DF, 0xB1FB384D, 0x7BF06B0B
.dword	0x9E7A0660, 0x7C2485CE, 0x461887F8, 0x7C59A742
.dword	0x6BCF54FB, 0x7C900889, 0xC6C32A3A, 0x7CC40AAB
.dword	0xB873F4C8, 0x7CF90D56, 0x6690F1FA, 0x7D2F50AC
.dword	0xC01A973C, 0x7D63926B, 0xB0213D0B, 0x7D987706
.dword	0x5C298C4E, 0x7DCE94C8, 0x3999F7B1, 0x7E031CFD
.dword	0x8800759D, 0x7E37E43C, 0xAA009304, 0x7E6DDD4B
.dword	0x4A405BE2, 0x7EA2AA4F, 0x1CD072DA, 0x7ED754E3
.dword	0xE4048F90, 0x7F0D2A1B, 0x6E82D9BA, 0x7F423A51
.dword	0xCA239028, 0x7F76C8E5, 0x3CAC7432, 0x7FAC7B1F
.dword	0x85EBC89F, 0x7FE1CCF3
