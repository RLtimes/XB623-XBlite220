;
; [1] '
;
; [2] '
;
; [3] ' ####################
;
; [4] ' #####  PROLOG  #####
;
; [5] ' ####################
;
; [6] '
;
; [7] 'MAKEFILE "makexformat.mak"
;
; [9] PROGRAM	"xformat"
;
; [10] VERSION	"0.0001"
;
; [11] '
;
; [12] IMPORT	"xst"   ' Standard library : required by most programs
;
; [13] '
;
; [14] DECLARE FUNCTION  XFormat ()
;
; [15] EXPORT
;
; [16] DECLARE FUNCTION  ValidFormat (format$, validPtr)
;
; [17] DECLARE FUNCTION  XxxFormat$ (format$, argType, arg$$)
;
; [19] END EXPORT
;
; [20] '
;
; [21] '
;
; [22] ' ############################
;
; [23] ' #####  ValidFormat ()  #####
;
; [24] ' ############################
;
; [25] '
;
; [26] FUNCTION  ValidFormat (format$, validPtr)
.code
	jmp	%_StartLibrary_xformat			;;; i156
PrologCode.xformat:
	ret				;;; i158 ;;; end prolog code
_ValidFormat@8:
;  *****
;  *****  FUNCTION  ValidFormat ()  *****
;  *****
func2.xformat:
	push	ebp			;;; i112
	mov	ebp,esp		;;; i113
	sub	esp,8			;;; i114
	push	esi			;;; save esi
	push	edi			;;; save edi
	push	ebx			;;; save ebx
;
;	#### Begin Local Initialization Code ####
	xor	eax,eax		;;; .
	push	eax			;;; ..
	push	eax			;;; ..
	push	eax			;;; ..
	push	eax			;;; ..
;	#### End Local Initialization Code ####
;
;	################################################################################
;	### *** IMPORTANT *** - If hand-optimizing by eliminating the initialization ###
;	### code above, the first 'sub esp,____' line below must be uncommented, and ###
;	### the second must be either deleted or commented out.                      ###
;	### !!! Failure to do so will cause the resultant program to crash !!!       ###
;	################################################################################
;
;	sub esp,236			;;; uncomment this line for hand-optimization!
	sub	esp,220			;;; i114a
;
funcBody2.xformat:
;
; [27] STATIC	UBYTE  fmtSeq[]
data section 'globals$statics'
align	4
%%2%%fmtSeq.xformat:	db 4 dup ?
.code
;
; [28] '
;
; [29] IFZ fmtSeq[] THEN GOSUB Initialize
	mov	eax,d[%%2%%fmtSeq.xformat]			;;; i663a
	test	eax,eax			;;; i194
	jnz	>> else.0001.xformat			;;; i195
	call	%s%Initialize%2			;;; i163
else.0001.xformat:
end.if.0001.xformat:
;
; [30] IFZ format$ THEN RETURN ($$FALSE)
	mov	eax,[ebp+8]			;;; i665
	test	eax,eax			;;; i188
	jz	> A.1			;;; i189
	mov	eax,d[eax-8]			;;; i190
	test	eax,eax			;;; i191
	jnz	>> else.0002.xformat			;;; i192
A.1:
	mov	eax,0			;;; i659
	jmp	end.func2.xformat			;;; i258
else.0002.xformat:
end.if.0002.xformat:
;
; [31] valid = $$FALSE
	mov	eax,0			;;; i659
	mov	d[ebp-24],eax			;;; i670
;
; [32] '
;
; [33] ' format is invalid if not part of ascending value sequence
;
; [34] ' (else) format is valid if the next format character can become a digit
;
; [35] '
;
; [36] DO
do.0003.xformat:
;
; [37] now = format${validPtr}
	mov	eax,d[ebp+12]			;;; i665
	mov	edx,d[ebp+8]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-28],eax			;;; i670
;
; [38] nxt = format${validPtr+1}
	mov	eax,d[ebp+12]			;;; i665
	add	eax,1			;;; i775
	mov	edx,d[ebp+8]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-32],eax			;;; i670
;
; [39] IF (fmtSeq[now] >= fmtSeq[nxt]) THEN valid = $$FALSE : EXIT DO
	mov	eax,d[ebp-28]			;;; i665
	mov	edx,d[%%2%%fmtSeq.xformat]			;;; i663a
	movzx	eax,b[edx+eax]			;;; i464
	mov	ebx,d[ebp-32]			;;; i665
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	movzx	ebx,b[ecx+ebx]			;;; i464
	cmp	eax,ebx			;;; i684a
	jl	>> else.0004.xformat			;;; i219
	mov	eax,0			;;; i659
	mov	d[ebp-24],eax			;;; i670
	jmp	end.do.0003.xformat			;;; i144
else.0004.xformat:
end.if.0004.xformat:
;
; [40] IF ((nxt = '*') OR (nxt = '#') OR (nxt = ',')) THEN valid = $$TRUE : EXIT DO
	mov	eax,d[ebp-32]			;;; i665
	cmp	eax,42			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.2			;;; i467
	not	eax			;;; i468
A.2:
	mov	ebx,d[ebp-32]			;;; i665
	cmp	ebx,35			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.3			;;; i467
	not	ebx			;;; i468
A.3:
	or	eax,ebx			;;; i763
	mov	ebx,d[ebp-32]			;;; i665
	cmp	ebx,44			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.4			;;; i467
	not	ebx			;;; i468
A.4:
	or	eax,ebx			;;; i763
	test	eax,eax			;;; i220
	jz	>> else.0005.xformat			;;; i221
	mov	eax,-1			;;; i659
	mov	d[ebp-24],eax			;;; i670
	jmp	end.do.0003.xformat			;;; i144
else.0005.xformat:
end.if.0005.xformat:
;
; [41] INC validPtr
	inc	d[ebp+12]			;;; i84
;
; [42] LOOP
do.loop.0003.xformat:
	jmp	do.0003.xformat			;;; i222
end.do.0003.xformat:
;
; [43] RETURN (valid)
	mov	eax,d[ebp-24]			;;; i665
	jmp	end.func2.xformat			;;; i258
;
; [44] '
;
; [45] ' *****  Initialize  *****
;
; [46] '
;
; [47] SUB Initialize
	jmp	out.sub2.0.xformat			;;; i262
%s%Initialize%2:
;
; [48] DIM fmtSeq[255]
	sub	esp,64			;;; i430
	mov	eax,255			;;; i659
	mov	d[esp+16],eax			;;; i432
	mov	esi,d[%%2%%fmtSeq.xformat]			;;; i663a
	mov	d[esp],esi			;;; i433
	mov	d[esp+4],1			;;; i434
	mov	d[esp+8],-1073545215			;;; i435
	mov	d[esp+12],0			;;; i436
	call	%_DimArray			;;; i437
	add	esp,64			;;; i438
	mov	d[%%2%%fmtSeq.xformat],eax			;;; i668
;
; [49] fmtSeq['+'] =  40
	mov	eax,40			;;; i659
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	lea	ebx,[ecx+43]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [50] fmtSeq['-'] =  40
	mov	eax,40			;;; i659
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	lea	ebx,[ecx+45]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [51] fmtSeq['('] =  40
	mov	eax,40			;;; i659
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	lea	ebx,[ecx+40]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [52] fmtSeq['*'] =  50
	mov	eax,50			;;; i659
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	lea	ebx,[ecx+42]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [53] fmtSeq['$'] =  60
	mov	eax,60			;;; i659
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	lea	ebx,[ecx+36]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [54] fmtSeq[','] =  80
	mov	eax,80			;;; i659
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	lea	ebx,[ecx+44]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [55] fmtSeq['.'] =  90
	mov	eax,90			;;; i659
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	lea	ebx,[ecx+46]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [56] fmtSeq['#'] = 100
	mov	eax,100			;;; i659
	mov	ecx,d[%%2%%fmtSeq.xformat]			;;; i663a
	lea	ebx,[ecx+35]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [57] END SUB
end.sub2.0.xformat:
	ret				;;; i127
out.sub2.0.xformat:
;
; [59] END FUNCTION
	xor	eax,eax			;;; i862
end.ValidFormat.xformat:  ;;; Function end label for Assembly Programmers.
end.func2.xformat:
	lea	esp,[ebp-20]				;;; i110
	pop	ebx				;;; restore ebx
	pop	edi				;;; restore edi
	pop	esi				;;; restore esi
	leave					;;; replaces "mov esp,ebp", "pop ebp"
	ret	8			;;; i111a
;  *****
;  *****  END FUNCTION  ValidFormat ()  *****
;  *****
;
; [60] '
;
; [61] '
;
; [62] ' ###########################
;
; [63] ' #####  XxxFormat$ ()  #####
;
; [64] ' ###########################
;
; [65] '
;
; [66] FUNCTION  XxxFormat$ (format$, argType, arg$$)
.code
_XxxFormat$@16:
;  *****
;  *****  FUNCTION  XxxFormat$ ()  *****
;  *****
func3.xformat:
	push	ebp			;;; i112
	mov	ebp,esp		;;; i113
	sub	esp,8			;;; i114
	push	esi			;;; save esi
	push	edi			;;; save edi
	push	ebx			;;; save ebx
;
;	#### Begin Local Initialization Code ####
	mov	ecx,16				;;; ..
	xor	eax,eax			;;; ...
A.54:
	push	eax, eax, eax, eax
	push	eax, eax, eax, eax
	dec	ecx					;;; ....
	jnz	 < A.54			;;; .....
;	#### End Local Initialization Code ####
;
;	################################################################################
;	### *** IMPORTANT *** - If hand-optimizing by eliminating the initialization ###
;	### code above, the first 'sub esp,____' line below must be uncommented, and ###
;	### the second must be either deleted or commented out.                      ###
;	### !!! Failure to do so will cause the resultant program to crash !!!       ###
;	################################################################################
;
;	sub esp,268			;;; uncomment this line for hand-optimization!
	sub	esp,4			;;; i114a
;
funcBody3.xformat:
;
; [68] STATIC	UBYTE  fmtLevel[]
data section 'globals$statics'
align	4
%%3%%fmtLevel.xformat:	db 4 dup ?
.code
;
; [69] STATIC	UBYTE  fmtBegin[]
data section 'globals$statics'
align	4
%%3%%fmtBegin.xformat:	db 4 dup ?
.code
;
; [70] '
;
; [71] '	PRINT "FORMAT$() : <"; format$; "> <"; STRING$(argType); "> <"; STRING$(arg$$); ">"
;
; [72] '
;
; [73] IFZ fmtLevel[] THEN GOSUB Initialize
	mov	eax,d[%%3%%fmtLevel.xformat]			;;; i663a
	test	eax,eax			;;; i194
	jnz	>> else.0006.xformat			;;; i195
	call	%s%Initialize%3			;;; i163
else.0006.xformat:
end.if.0006.xformat:
;
; [74] IFZ format$ THEN RETURN 										' empty format string
	mov	eax,[ebp+8]			;;; i665
	test	eax,eax			;;; i188
	jz	> A.8			;;; i189
	mov	eax,d[eax-8]			;;; i190
	test	eax,eax			;;; i191
	jnz	>> else.0007.xformat			;;; i192
A.8:
	xor	eax,eax			;;; i862
	jmp	end.func3.xformat			;;; i258
else.0007.xformat:
end.if.0007.xformat:
;
; [75] '
;
; [76] IF (argType = $$STRING) THEN arg$ = CSTRING$(GLOW(arg$$))
	mov	eax,d[ebp+12]			;;; i665
	cmp	eax,19			;;; i684a
	jne	>> else.0008.xformat			;;; i219
	sub	esp,64			;;; i487
	sub	esp,64			;;; i487
	mov	eax,d[ebp+16]			;;; i665
	mov	edx,d[ebp+20]
	add	esp,64			;;; i600
	mov	d[esp],eax			;;; i887
	call	%_cstring.d			;;; i573
	add	esp,64			;;; i600
	lea	ebx,[ebp-24]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
else.0008.xformat:
end.if.0008.xformat:
;
; [77] '
;
; [78] fmtStrPtr = 1
	mov	eax,1			;;; i659
	mov	d[ebp-28],eax			;;; i670
;
; [79] lenFmtStr = LEN (format$)
	mov	eax,d[ebp+8]			;;; i665
	test	eax,eax			;;; i593
	jz	> A.9			;;; i594
	mov	eax,d[eax-8]			;;; i595
A.9:
	mov	d[ebp-32],eax			;;; i670
;
; [80] GOSUB StringString													'	top StringString call
	call	%s%StringString%3			;;; i163
;
; [81] '
;
; [82] IFZ fmtStrPtr THEN
	mov	eax,d[ebp-28]			;;; i665
	test	eax,eax			;;; i194
	jnz	>> else.0009.xformat			;;; i195
;
; [83] '		PRINT "a<" + resultString$ + "> " + STRING$(LEN(resultString$))
;
; [84] RETURN (resultString$)
	mov	eax,[ebp-36]			;;; i665
	xor	esi,esi			;;; i869
	mov	d[ebp-36],esi			;;; i670
	jmp	end.func3.xformat			;;; i258
;
; [85] END IF
else.0009.xformat:
end.if.0009.xformat:
;
; [86] '
;
; [87] ' initialize argument counters, flags, etc.
;
; [88] '
;
; [89] argH	= 0
	mov	eax,0			;;; i659
	mov	d[ebp-40],eax			;;; i670
;
; [90] argL	= 0
	mov	eax,0			;;; i659
	mov	d[ebp-44],eax			;;; i670
;
; [91] arg&&	= 0
	mov	eax,0			;;; i659
	or	eax,eax			;;; i366
	jns	> A.10			;;; i367
	call	%_eeeOverflow			;;; i368
A.10:
	mov	d[ebp-48],eax			;;; i670
;
; [92] lenArg = 0
	mov	eax,0			;;; i659
	mov	d[ebp-52],eax			;;; i670
;
; [93] negArg = 0
	mov	eax,0			;;; i659
	mov	d[ebp-56],eax			;;; i670
;
; [94] argStr$	= ""
	xor	eax,eax
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [95] argDPLoc = 0
	mov	eax,0			;;; i659
	mov	d[ebp-64],eax			;;; i670
;
; [96] numShift = 0
	mov	eax,0			;;; i659
	mov	d[ebp-68],eax			;;; i670
;
; [97] argExpIx = 0
	mov	eax,0			;;; i659
	mov	d[ebp-72],eax			;;; i670
;
; [98] argExpVal = 0
	mov	eax,0			;;; i659
	mov	d[ebp-76],eax			;;; i670
;
; [99] argMSDOrder	= 0
	mov	eax,0			;;; i659
	mov	d[ebp-80],eax			;;; i670
;
; [100] '
;
; [101] ' initialize format counters, flags, etc.
;
; [102] '
;
; [103] fmtChar = 0
	mov	eax,0			;;; i659
	mov	d[ebp-84],eax			;;; i670
;
; [104] lastChar = 0
	mov	eax,0			;;; i659
	mov	d[ebp-88],eax			;;; i670
;
; [105] nextChar = 0
	mov	eax,0			;;; i659
	mov	d[ebp-92],eax			;;; i670
;
; [106] levelNow = 0
	mov	eax,0			;;; i659
	mov	d[ebp-96],eax			;;; i670
;
; [107] levelNext = 0
	mov	eax,0			;;; i659
	mov	d[ebp-100],eax			;;; i670
;
; [108] nPlaces = 0
	mov	eax,0			;;; i659
	mov	d[ebp-104],eax			;;; i670
;
; [109] preDec = 0
	mov	eax,0			;;; i659
	mov	d[ebp-108],eax			;;; i670
;
; [110] postDec = 0
	mov	eax,0			;;; i659
	mov	d[ebp-112],eax			;;; i670
;
; [111] expCtr = 0
	mov	eax,0			;;; i659
	mov	d[ebp-116],eax			;;; i670
;
; [112] hasDec = 0
	mov	eax,0			;;; i659
	mov	d[ebp-120],eax			;;; i670
;
; [113] commaFlag = 0
	mov	eax,0			;;; i659
	mov	d[ebp-124],eax			;;; i670
;
; [114] padFlag = 0
	mov	eax,0			;;; i659
	mov	d[ebp-128],eax			;;; i670
;
; [115] dollarSign$ = ""
	xor	eax,eax
	lea	ebx,[ebp-132]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [116] leadSign$ = ""
	xor	eax,eax
	lea	ebx,[ebp-136]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [117] trailSign$ = ""
	xor	eax,eax
	lea	ebx,[ebp-140]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [118] errSign$ = ""
	xor	eax,eax
	lea	ebx,[ebp-144]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [119] '
;
; [120] ' Format argument and add it to the result loop
;
; [121] '
;
; [122] DO
do.000A.xformat:
;
; [123] lastChar = fmtChar
	mov	eax,d[ebp-84]			;;; i665
	mov	d[ebp-88],eax			;;; i670
;
; [124] fmtChar = format${fmtStrPtr-1}
	mov	eax,d[ebp-28]			;;; i665
	sub	eax,1			;;; i791
	mov	edx,d[ebp+8]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-84],eax			;;; i670
;
; [125] '
;
; [126] IFZ ((fmtChar = '#') AND ((lastChar = ',') OR (lastChar = '.') OR (lastChar = '#'))) THEN
	mov	eax,d[ebp-84]			;;; i665
	cmp	eax,35			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.11			;;; i467
	not	eax			;;; i468
A.11:
	mov	ebx,d[ebp-88]			;;; i665
	cmp	ebx,44			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.12			;;; i467
	not	ebx			;;; i468
A.12:
	mov	d[ebp-152],eax			;;; i670
	mov	eax,d[ebp-88]			;;; i665
	cmp	eax,46			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.13			;;; i467
	not	eax			;;; i468
A.13:
	or	eax,ebx			;;; i763
	mov	ebx,d[ebp-88]			;;; i665
	cmp	ebx,35			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.14			;;; i467
	not	ebx			;;; i468
A.14:
	or	eax,ebx			;;; i763
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i194
	jnz	>> else.000B.xformat			;;; i195
;
; [127] levelNow  = fmtLevel[fmtChar]
	mov	eax,d[ebp-84]			;;; i665
	mov	edx,d[%%3%%fmtLevel.xformat]			;;; i663a
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-96],eax			;;; i670
;
; [128] END IF
else.000B.xformat:
end.if.000B.xformat:
;
; [129] '
;
; [130] IF (fmtStrPtr = lenFmtStr) THEN							' check for end of fmt string
	mov	eax,d[ebp-28]			;;; i665
	mov	ebx,d[ebp-32]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> else.000C.xformat			;;; i219
;
; [131] nextChar = 'A'														'   set bogus next char
	mov	eax,65			;;; i659
	mov	d[ebp-92],eax			;;; i670
;
; [132] ELSE
	jmp	end.if.000C.xformat			;;; i107
else.000C.xformat:
;
; [133] nextChar  = format${fmtStrPtr}					'   get real next char
	mov	eax,d[ebp-28]			;;; i665
	mov	edx,d[ebp+8]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-92],eax			;;; i670
;
; [134] END IF
end.if.000C.xformat:
;
; [135] '
;
; [136] IF ((nextChar = '#') AND ((fmtChar = ',') OR (fmtChar = '.') OR (fmtChar = '#'))) THEN
	mov	eax,d[ebp-92]			;;; i665
	cmp	eax,35			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.15			;;; i467
	not	eax			;;; i468
A.15:
	mov	ebx,d[ebp-84]			;;; i665
	cmp	ebx,44			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.16			;;; i467
	not	ebx			;;; i468
A.16:
	mov	d[ebp-152],eax			;;; i670
	mov	eax,d[ebp-84]			;;; i665
	cmp	eax,46			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.17			;;; i467
	not	eax			;;; i468
A.17:
	or	eax,ebx			;;; i763
	mov	ebx,d[ebp-84]			;;; i665
	cmp	ebx,35			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.18			;;; i467
	not	ebx			;;; i468
A.18:
	or	eax,ebx			;;; i763
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.000D.xformat			;;; i221
;
; [137] levelNext = levelNow
	mov	eax,d[ebp-96]			;;; i665
	mov	d[ebp-100],eax			;;; i670
;
; [138] ELSE
	jmp	end.if.000D.xformat			;;; i107
else.000D.xformat:
;
; [139] levelNext = fmtLevel[nextChar]
	mov	eax,d[ebp-92]			;;; i665
	mov	edx,d[%%3%%fmtLevel.xformat]			;;; i663a
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-100],eax			;;; i670
;
; [140] END IF
end.if.000D.xformat:
;
; [141] '
;
; [142] ' Unformatted string "format"
;
; [143] '
;
; [144] IF (fmtChar = '&') THEN
	mov	eax,d[ebp-84]			;;; i665
	cmp	eax,38			;;; i684a
	jne	>> else.000E.xformat			;;; i219
;
; [145] IF (argType != $$STRING) THEN
	mov	eax,d[ebp+12]			;;; i665
	cmp	eax,19			;;; i684a
	je	>> else.000F.xformat			;;; i219
;
; [146] PRINT "FORMAT$() : error : (numeric data with '&')"
	push	1			;;; i844
	sub	esp,64			;;; i845
	mov	eax,addr @_string.006E.xformat			;;; i663
	call	%_clone.a0			;;; i429
	add	esp,64
	call	%_PrintWithNewlineThenFree			;;; i859
	add	esp,4
;
; [147] GOTO eeeQuitFormat
	jmp	%g%eeeQuitFormat%3			;;; i163
;
; [148] END IF
else.000F.xformat:
end.if.000F.xformat:
;
; [149] resultString$ = resultString$ + arg$
	mov	eax,[ebp-36]			;;; i665
	mov	ebx,[ebp-24]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.vv			;;; i782
	lea	ebx,[ebp-36]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [150] INC fmtStrPtr
	inc	d[ebp-28]			;;; i84
;
; [151] EXIT DO
	jmp	end.do.000A.xformat			;;; i144
;
; [152] END IF
else.000E.xformat:
end.if.000E.xformat:
;
; [153] INC nPlaces
	inc	d[ebp-104]			;;; i84
;
; [154] '
;
; [155] SELECT CASE fmtChar
	mov	eax,d[ebp-84]			;;; i665
	mov	d[ebp-160],eax			;;; i670
;
; [156] CASE '$': dollarSign$ = "$"
	mov	eax,36			;;; i659
	mov	ebx,d[ebp-160]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0010.0001.xformat			;;; i71
	mov	eax,addr @_string.006F.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-132]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [157] CASE ',':	commaFlag = $$TRUE
	jmp	end.select.0010.xformat			;;; i69
case.0010.0001.xformat:
	mov	eax,44			;;; i659
	mov	ebx,d[ebp-160]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0010.0002.xformat			;;; i71
	mov	eax,-1			;;; i659
	mov	d[ebp-124],eax			;;; i670
;
; [158] INC preDec
	inc	d[ebp-108]			;;; i84
;
; [159] CASE '*': padFlag = $$TRUE
	jmp	end.select.0010.xformat			;;; i69
case.0010.0002.xformat:
	mov	eax,42			;;; i659
	mov	ebx,d[ebp-160]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0010.0003.xformat			;;; i71
	mov	eax,-1			;;; i659
	mov	d[ebp-128],eax			;;; i670
;
; [160] INC preDec
	inc	d[ebp-108]			;;; i84
;
; [161] CASE '.': hasDec = 1
	jmp	end.select.0010.xformat			;;; i69
case.0010.0003.xformat:
	mov	eax,46			;;; i659
	mov	ebx,d[ebp-160]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0010.0004.xformat			;;; i71
	mov	eax,1			;;; i659
	mov	d[ebp-120],eax			;;; i670
;
; [162] CASE '#': IF hasDec THEN
	jmp	end.select.0010.xformat			;;; i69
case.0010.0004.xformat:
	mov	eax,35			;;; i659
	mov	ebx,d[ebp-160]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0010.0005.xformat			;;; i71
	mov	eax,d[ebp-120]			;;; i665
	test	eax,eax			;;; i220
	jz	>> else.0011.xformat			;;; i221
;
; [163] INC postDec
	inc	d[ebp-112]			;;; i84
;
; [164] ELSE
	jmp	end.if.0011.xformat			;;; i107
else.0011.xformat:
;
; [165] INC preDec
	inc	d[ebp-108]			;;; i84
;
; [166] END IF
end.if.0011.xformat:
;
; [167] CASE '-': INC preDec						' sign can only be leading here.
	jmp	end.select.0010.xformat			;;; i69
case.0010.0005.xformat:
	mov	eax,45			;;; i659
	mov	ebx,d[ebp-160]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0010.0006.xformat			;;; i71
	inc	d[ebp-108]			;;; i84
;
; [168] CASE '+', '('
	jmp	end.select.0010.xformat			;;; i69
case.0010.0006.xformat:
	mov	eax,43			;;; i659
	mov	ebx,d[ebp-160]			;;; i665
	cmp	eax,ebx			;;; i684a
	je	>> caser.0010.0006.xformat			;;; i70
	mov	eax,40			;;; i659
	cmp	eax,ebx			;;; i684a
	jne	>> case.0010.0007.xformat			;;; i71
caser.0010.0006.xformat:
;
; [169] IFZ leadSign$ THEN
	mov	eax,[ebp-136]			;;; i665
	test	eax,eax			;;; i188
	jz	> A.19			;;; i189
	mov	eax,d[eax-8]			;;; i190
	test	eax,eax			;;; i191
	jnz	>> else.0012.xformat			;;; i192
A.19:
;
; [170] leadSign$ = CHR$ (fmtChar)
	sub	esp,64			;;; i487
	mov	eax,d[ebp-84]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	d[esp+4],1
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	lea	ebx,[ebp-136]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [171] ELSE
	jmp	end.if.0012.xformat			;;; i107
else.0012.xformat:
;
; [172] PRINT "FORMAT$() : error : (leading"; leadSign$; "excludes"; CHR$ (fmtChar); ")"
	push	1			;;; i844
	sub	esp,64			;;; i845
	mov	eax,addr @_string.0070.xformat			;;; i663
	call	%_clone.a0			;;; i429
	mov	ebx,[ebp-136]			;;; i665
	call	%_clone.a1			;;; i429
	call	%_concat.ubyte.a0.eq.a0.plus.a1.ss			;;; i852
	mov	ebx,addr @_string.0071.xformat			;;; i663
	call	%_clone.a1			;;; i429
	call	%_concat.ubyte.a0.eq.a0.plus.a1.ss			;;; i852
	mov	[ebp-152],eax			;;; i670
	sub	esp,64			;;; i487
	mov	eax,d[ebp-84]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	d[esp+4],1
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	mov	ebx,[ebp-152]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.ss			;;; i852
	mov	ebx,addr @_string.0072.xformat			;;; i663
	call	%_clone.a1			;;; i429
	call	%_concat.ubyte.a0.eq.a0.plus.a1.ss			;;; i852
	add	esp,64
	call	%_PrintWithNewlineThenFree			;;; i859
	add	esp,4
;
; [173] GOTO eeeQuitFormat
	jmp	%g%eeeQuitFormat%3			;;; i163
;
; [174] END IF
end.if.0012.xformat:
;
; [175] END SELECT
case.0010.0007.xformat:
end.select.0010.xformat:
;
; [176] '
;
; [177] ' case < or | or >:		all we needed to do is count them
;
; [178] ' End of char fmt:		add to resultString$, and exit loop
;
; [179] '
;
; [180] IF (((fmtChar = '<') OR (fmtChar = '|') OR (fmtChar = '>')) AND (nextChar != fmtChar)) THEN
	mov	eax,d[ebp-84]			;;; i665
	cmp	eax,60			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.20			;;; i467
	not	eax			;;; i468
A.20:
	mov	ebx,d[ebp-84]			;;; i665
	cmp	ebx,124			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.21			;;; i467
	not	ebx			;;; i468
A.21:
	or	eax,ebx			;;; i763
	mov	ebx,d[ebp-84]			;;; i665
	cmp	ebx,62			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.22			;;; i467
	not	ebx			;;; i468
A.22:
	or	eax,ebx			;;; i763
	mov	d[ebp-152],eax			;;; i670
	mov	eax,d[ebp-92]			;;; i665
	mov	ebx,d[ebp-84]			;;; i665
	cmp	eax,ebx			;;; i684a
	mov	eax,0			;;; i466
	je	> A.23			;;; i467
	not	eax			;;; i468
A.23:
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.0013.xformat			;;; i221
;
; [181] IF (argType != $$STRING) THEN
	mov	eax,d[ebp+12]			;;; i665
	cmp	eax,19			;;; i684a
	je	>> else.0014.xformat			;;; i219
;
; [182] PRINT "FORMAT$() : error : (can't print number with string format)"
	push	1			;;; i844
	sub	esp,64			;;; i845
	mov	eax,addr @_string.0076.xformat			;;; i663
	call	%_clone.a0			;;; i429
	add	esp,64
	call	%_PrintWithNewlineThenFree			;;; i859
	add	esp,4
;
; [183] GOTO eeeQuitFormat
	jmp	%g%eeeQuitFormat%3			;;; i163
;
; [184] END IF
else.0014.xformat:
end.if.0014.xformat:
;
; [185] SELECT CASE fmtChar
	mov	eax,d[ebp-84]			;;; i665
	mov	d[ebp-164],eax			;;; i670
;
; [186] CASE '<': resultString$ = resultString$ + LJUST$(arg$, nPlaces)
	mov	eax,60			;;; i659
	mov	ebx,d[ebp-164]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0015.0001.xformat			;;; i71
	sub	esp,64			;;; i487
	mov	eax,[ebp-24]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-104]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_ljust.d.v			;;; i578
	add	esp,64			;;; i600
	mov	ebx,[ebp-36]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.vs			;;; i782
	lea	ebx,[ebp-36]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [187] CASE '|': resultString$ = resultString$ + CJUST$(arg$, nPlaces)
	jmp	end.select.0015.xformat			;;; i69
case.0015.0001.xformat:
	mov	eax,124			;;; i659
	mov	ebx,d[ebp-164]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0015.0002.xformat			;;; i71
	sub	esp,64			;;; i487
	mov	eax,[ebp-24]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-104]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_cjust.d.v			;;; i578
	add	esp,64			;;; i600
	mov	ebx,[ebp-36]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.vs			;;; i782
	lea	ebx,[ebp-36]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [188] CASE '>': resultString$ = resultString$ + RJUST$(arg$, nPlaces)
	jmp	end.select.0015.xformat			;;; i69
case.0015.0002.xformat:
	mov	eax,62			;;; i659
	mov	ebx,d[ebp-164]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0015.0003.xformat			;;; i71
	sub	esp,64			;;; i487
	mov	eax,[ebp-24]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-104]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_rjust.d.v			;;; i578
	add	esp,64			;;; i600
	mov	ebx,[ebp-36]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.vs			;;; i782
	lea	ebx,[ebp-36]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [189] END SELECT
case.0015.0003.xformat:
end.select.0015.xformat:
;
; [190] INC fmtStrPtr
	inc	d[ebp-28]			;;; i84
;
; [191] EXIT DO
	jmp	end.do.000A.xformat			;;; i144
;
; [192] END IF
else.0013.xformat:
end.if.0013.xformat:
;
; [193] '
;
; [194] ' SPECIAL TRAILING NUMERIC FMT INFO
;
; [195] '
;
; [196] ' get exponent: !! new nextChar$ if legit exponent !!
;
; [197] '
;
; [198] IF (nextChar = '^') THEN
	mov	eax,d[ebp-92]			;;; i665
	cmp	eax,94			;;; i684a
	jne	>> else.0016.xformat			;;; i219
;
; [199] DO																				' count ^s
do.0017.xformat:
;
; [200] INC expCtr
	inc	d[ebp-116]			;;; i84
;
; [201] IF (format${fmtStrPtr + expCtr} != '^') THEN EXIT DO
	mov	eax,d[ebp-28]			;;; i665
	mov	ebx,d[ebp-116]			;;; i665
	add	eax,ebx			;;; i775
	mov	edx,d[ebp+8]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	cmp	eax,94			;;; i684a
	je	>> else.0018.xformat			;;; i219
	jmp	end.do.0017.xformat			;;; i144
else.0018.xformat:
end.if.0018.xformat:
;
; [202] LOOP UNTIL (expCtr = 5)
do.loop.0017.xformat:
	mov	eax,d[ebp-116]			;;; i665
	cmp	eax,5			;;; i684a
	jne	< do.0017.xformat			;;; i219
end.do.0017.xformat:
;
; [203] '
;
; [204] IF (expCtr >= 4) THEN											' legitimate exponent
	mov	eax,d[ebp-116]			;;; i665
	cmp	eax,4			;;; i684a
	jl	>> else.0019.xformat			;;; i219
;
; [205] nPlaces    = nPlaces    + expCtr
	mov	eax,d[ebp-104]			;;; i665
	mov	ebx,d[ebp-116]			;;; i665
	add	eax,ebx			;;; i775
	mov	d[ebp-104],eax			;;; i670
;
; [206] fmtStrPtr  = fmtStrPtr  + expCtr
	mov	eax,d[ebp-28]			;;; i665
	mov	ebx,d[ebp-116]			;;; i665
	add	eax,ebx			;;; i775
	mov	d[ebp-28],eax			;;; i670
;
; [207] nextChar   = format${fmtStrPtr}					' to look for trailing +, -, )
	mov	eax,d[ebp-28]			;;; i665
	mov	edx,d[ebp+8]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-92],eax			;;; i670
;
; [208] ELSE
	jmp	end.if.0019.xformat			;;; i107
else.0019.xformat:
;
; [209] expCtr = 0															' reset if not valid exponent
	mov	eax,0			;;; i659
	mov	d[ebp-116],eax			;;; i670
;
; [210] END IF
end.if.0019.xformat:
;
; [211] END IF
else.0016.xformat:
end.if.0016.xformat:
;
; [212] '
;
; [213] ' look for trailing + or - in nextChar here. add flags
;
; [214] '
;
; [215] IF (((nextChar = '-') OR (nextChar = '+')) AND (leadSign$ = "")) THEN
	mov	eax,d[ebp-92]			;;; i665
	cmp	eax,45			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.24			;;; i467
	not	eax			;;; i468
A.24:
	mov	ebx,d[ebp-92]			;;; i665
	cmp	ebx,43			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.25			;;; i467
	not	ebx			;;; i468
A.25:
	or	eax,ebx			;;; i763
	mov	d[ebp-152],eax			;;; i670
	mov	eax,[ebp-136]			;;; i665
	xor	ebx,ebx			;;; i658
	call	%_string.compare.vv			;;; i690
	mov	eax,0			;;; i466
	jne	> A.26			;;; i467
	not	eax			;;; i468
A.26:
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.001A.xformat			;;; i221
;
; [216] trailSign$ = CHR$ (nextChar)
	sub	esp,64			;;; i487
	mov	eax,d[ebp-92]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	d[esp+4],1
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	lea	ebx,[ebp-140]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [217] '
;
; [218] ' incr ptrs: trailing sign picked up (but don't leave loop yet).
;
; [219] '
;
; [220] levelNext = 0
	mov	eax,0			;;; i659
	mov	d[ebp-100],eax			;;; i670
;
; [221] INC nPlaces
	inc	d[ebp-104]			;;; i84
;
; [222] INC fmtStrPtr
	inc	d[ebp-28]			;;; i84
;
; [223] END IF
else.001A.xformat:
end.if.001A.xformat:
;
; [224] '
;
; [225] ' get closing parenthesis; legit only if opening parenthesis has been set.
;
; [226] '
;
; [227] IF ((nextChar = ')') AND (leadSign$ = "(")) THEN
	mov	eax,d[ebp-92]			;;; i665
	cmp	eax,41			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.27			;;; i467
	not	eax			;;; i468
A.27:
	mov	d[ebp-152],eax			;;; i670
	mov	eax,[ebp-136]			;;; i665
	mov	ebx,addr @_string.007B.xformat			;;; i663
	call	%_string.compare.vv			;;; i690
	mov	eax,0			;;; i466
	jne	> A.28			;;; i467
	not	eax			;;; i468
A.28:
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.001B.xformat			;;; i221
;
; [228] trailSign$ = CHR$ (nextChar)
	sub	esp,64			;;; i487
	mov	eax,d[ebp-92]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	d[esp+4],1
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	lea	ebx,[ebp-140]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [229] INC nPlaces
	inc	d[ebp-104]			;;; i84
;
; [230] INC fmtStrPtr
	inc	d[ebp-28]			;;; i84
;
; [231] END IF
else.001B.xformat:
end.if.001B.xformat:
;
; [232] '
;
; [233] ' a second '.' means the beginning of a new fmt.
;
; [234] '
;
; [235] IF (hasDec AND (nextChar = '.')) THEN levelNext = 0
	mov	eax,d[ebp-92]			;;; i665
	cmp	eax,46			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.29			;;; i467
	not	eax			;;; i468
A.29:
	mov	ebx,d[ebp-120]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.001C.xformat			;;; i221
	mov	eax,0			;;; i659
	mov	d[ebp-100],eax			;;; i670
else.001C.xformat:
end.if.001C.xformat:
;
; [236] '
;
; [237] ' End of num fmt: validate fmt, add to resultString$ and exit loop.
;
; [238] '
;
; [239] IF (levelNext < levelNow) THEN
	mov	eax,d[ebp-100]			;;; i665
	mov	ebx,d[ebp-96]			;;; i665
	cmp	eax,ebx			;;; i684a
	jge	>> else.001D.xformat			;;; i219
;
; [240] IFZ (preDec + postDec) THEN
	mov	eax,d[ebp-108]			;;; i665
	mov	ebx,d[ebp-112]			;;; i665
	add	eax,ebx			;;; i775
	test	eax,eax			;;; i194
	jnz	>> else.001E.xformat			;;; i195
;
; [241] PRINT "FORMAT$() : error : (no printable digits)"
	push	1			;;; i844
	sub	esp,64			;;; i845
	mov	eax,addr @_string.007C.xformat			;;; i663
	call	%_clone.a0			;;; i429
	add	esp,64
	call	%_PrintWithNewlineThenFree			;;; i859
	add	esp,4
;
; [242] GOTO eeeQuitFormat
	jmp	%g%eeeQuitFormat%3			;;; i163
;
; [243] END IF
else.001E.xformat:
end.if.001E.xformat:
;
; [244] '
;
; [245] ' missing close parenthesis: treat open paren as fixed.
;
; [246] '
;
; [247] IF ((leadSign$ = "(") AND (trailSign$ != ")")) THEN
	mov	eax,[ebp-136]			;;; i665
	mov	ebx,addr @_string.007B.xformat			;;; i663
	call	%_string.compare.vv			;;; i690
	mov	eax,0			;;; i466
	jne	> A.30			;;; i467
	not	eax			;;; i468
A.30:
	mov	d[ebp-152],eax			;;; i670
	mov	eax,[ebp-140]			;;; i665
	mov	ebx,addr @_string.0072.xformat			;;; i663
	call	%_string.compare.vv			;;; i690
	mov	eax,0			;;; i466
	je	> A.31			;;; i467
	not	eax			;;; i468
A.31:
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.001F.xformat			;;; i221
;
; [248] resultString$ = resultString$ + "("
	mov	eax,[ebp-36]			;;; i665
	mov	ebx,addr @_string.007B.xformat			;;; i663
	call	%_concat.ubyte.a0.eq.a0.plus.a1.vv			;;; i782
	lea	ebx,[ebp-36]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [249] leadSign$ = ""
	xor	eax,eax
	lea	ebx,[ebp-136]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [250] DEC nPlaces
	dec	d[ebp-104]			;;; i84
;
; [251] END IF
else.001F.xformat:
end.if.001F.xformat:
;
; [252] '
;
; [253] ' Get argument
;
; [254] '
;
; [255] IF (argType = $$STRING) THEN
	mov	eax,d[ebp+12]			;;; i665
	cmp	eax,19			;;; i684a
	jne	>> else.0020.xformat			;;; i219
;
; [256] PRINT "FORMAT$() : error : (string argument)"
	push	1			;;; i844
	sub	esp,64			;;; i845
	mov	eax,addr @_string.007D.xformat			;;; i663
	call	%_clone.a0			;;; i429
	add	esp,64
	call	%_PrintWithNewlineThenFree			;;; i859
	add	esp,4
;
; [257] GOTO eeeQuitFormat
	jmp	%g%eeeQuitFormat%3			;;; i163
;
; [258] END IF
else.0020.xformat:
end.if.0020.xformat:
;
; [259] '
;
; [260] argH  = GHIGH(arg$$)
	sub	esp,64			;;; i487
	mov	eax,d[ebp+16]			;;; i665
	mov	edx,d[ebp+20]
	mov	eax,edx			;;; i508
	add	esp,64			;;; i600
	mov	d[ebp-40],eax			;;; i670
;
; [261] argL  = GLOW (arg$$)
	sub	esp,64			;;; i487
	mov	eax,d[ebp+16]			;;; i665
	mov	edx,d[ebp+20]
	add	esp,64			;;; i600
	mov	d[ebp-44],eax			;;; i670
;
; [262] arg&& = GLOW (arg$$)				' type casts XLONG as ULONG
	sub	esp,64			;;; i487
	mov	eax,d[ebp+16]			;;; i665
	mov	edx,d[ebp+20]
	add	esp,64			;;; i600
	mov	d[ebp-48],eax			;;; i670
;
; [263] arg		= GLOW (arg$$)
	sub	esp,64			;;; i487
	mov	eax,d[ebp+16]			;;; i665
	mov	edx,d[ebp+20]
	add	esp,64			;;; i600
	mov	d[ebp-168],eax			;;; i670
;
; [264] '
;
; [265] SELECT CASE argType
	mov	eax,d[ebp+12]			;;; i665
	mov	d[ebp-172],eax			;;; i670
;
; [266] CASE $$DOUBLE	: argStr$ = STR$ (DMAKE(argH, argL))
	mov	eax,14			;;; i659
	mov	ebx,d[ebp-172]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0021.0001.xformat			;;; i71
	sub	esp,64			;;; i487
	sub	esp,64			;;; i487
	mov	eax,d[ebp-40]			;;; i665
	mov	ebx,d[ebp-44]			;;; i665
	mov	d[ebp-8],ebx			;;; i505
	mov	d[ebp-4],eax			;;; i506
	fld	q[ebp-8]			;;; i507
	add	esp,64			;;; i600
	fstp	q[esp]
	call	%_str.d.double			;;; i576
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [267] CASE $$SINGLE	: argStr$ = STR$ (SMAKE(argL))
	jmp	end.select.0021.xformat			;;; i69
case.0021.0001.xformat:
	mov	eax,13			;;; i659
	mov	ebx,d[ebp-172]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0021.0002.xformat			;;; i71
	sub	esp,64			;;; i487
	sub	esp,64			;;; i487
	mov	eax,d[ebp-44]			;;; i665
	mov	d[ebp-8],eax
	fld	d[ebp-8]
	add	esp,64			;;; i600
	fstp	d[esp]
	call	%_str.d.single			;;; i576
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [268] CASE $$GIANT	: argStr$ = STR$ (arg$$)
	jmp	end.select.0021.xformat			;;; i69
case.0021.0002.xformat:
	mov	eax,12			;;; i659
	mov	ebx,d[ebp-172]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0021.0003.xformat			;;; i71
	sub	esp,64			;;; i487
	mov	eax,d[ebp+16]			;;; i665
	mov	edx,d[ebp+20]
	mov	d[esp],eax			;;; i885
	mov	d[esp+4],edx			;;; i886
	call	%_str.d.giant			;;; i576
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [269] CASE $$ULONG	: argStr$ = STR$ (arg&&)
	jmp	end.select.0021.xformat			;;; i69
case.0021.0003.xformat:
	mov	eax,7			;;; i659
	mov	ebx,d[ebp-172]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0021.0004.xformat			;;; i71
	sub	esp,64			;;; i487
	mov	eax,d[ebp-48]			;;; i665
	mov	d[esp],eax			;;; i887
	call	%_str.d.ulong			;;; i576
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [270] CASE ELSE			: argStr$ = STR$ (arg)
	jmp	end.select.0021.xformat			;;; i69
case.0021.0004.xformat:
	sub	esp,64			;;; i487
	mov	eax,d[ebp-168]			;;; i665
	mov	d[esp],eax			;;; i887
	call	%_str.d.xlong			;;; i576
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [271] END SELECT
end.select.0021.xformat:
;
; [272] '
;
; [273] ' decompose argument string: sign, exponent, length and DP location
;
; [274] '
;
; [275] ' get sign: the 1st column of argStr$ will always be '-' or ' '.
;
; [276] '
;
; [277] negArg = argStr${0}
	mov	edx,d[ebp-60]			;;; i665
	movzx	eax,b[edx]			;;; i464
	mov	d[ebp-56],eax			;;; i670
;
; [278] argStr$ = MID$(argStr$, 2)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	d[esp+4],2
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [279] '
;
; [280] ' remove any exponent from argStr$. argExpVal is its numeric value.
;
; [281] '
;
; [282] argExpIx = INCHR(argStr$, "de")
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,addr @_string.0084.xformat			;;; i663
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],0			;;; i571
	call	%_inchr.vv			;;; i572
	add	esp,64			;;; i600
	mov	d[ebp-72],eax			;;; i670
;
; [283] argExpVal = 0
	mov	eax,0			;;; i659
	mov	d[ebp-76],eax			;;; i670
;
; [284] IF (argExpIx > 0) THEN
	mov	eax,d[ebp-72]			;;; i665
	cmp	eax,0			;;; i684a
	jle	>> else.0022.xformat			;;; i219
;
; [286] '				argExpVal = XLONG (MID$(argStr$, argExpIx + 1))
;
; [288] ' ok, trying to eliminate the use of above XLONG intrinsic in Xst library
;
; [289] expVal$ = MID$(argStr$, argExpIx + 1)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-72]			;;; i665
	add	eax,1			;;; i775
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	lea	ebx,[ebp-176]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [290] specType = XstStringToNumber (@expVal$, 0, @after, @rtype, @value$$)
;
; [0] EXTERNAL FUNCTION  XstStringToNumber             (s$, startOff, afterOff, rtype, value$$)
	push	[ebp-192]
	push	[ebp-196]			;;; i674a
	push	[ebp-188]			;;; i674a
	push	[ebp-184]			;;; i674a
	push	0			;;; i656a
	push	[ebp-176]			;;; i674a
	call	_XstStringToNumber@24			;;; i619
	mov	esi,d[esp-24]			;;; i877
	mov	[ebp-176],esi			;;; i670
	mov	esi,d[esp-16]			;;; i877
	mov	d[ebp-184],esi			;;; i670
	mov	esi,d[esp-12]			;;; i877
	mov	d[ebp-188],esi			;;; i670
	mov	esi,d[esp-8]			;;; i875
	mov	edi,d[esp-4]			;;; i876
	mov	d[ebp-196],esi			;;; i670
	mov	d[ebp-192],edi
	mov	d[ebp-180],eax			;;; i670
;
; [291] SELECT CASE rtype
	mov	eax,d[ebp-188]			;;; i665
	mov	d[ebp-200],eax			;;; i670
;
; [292] CASE $$SLONG : argExpVal = GLOW(value$$)
	mov	eax,6			;;; i659
	mov	ebx,d[ebp-200]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0023.0001.xformat			;;; i71
	sub	esp,64			;;; i487
	mov	eax,d[ebp-196]			;;; i665
	mov	edx,d[ebp-192]
	add	esp,64			;;; i600
	mov	d[ebp-76],eax			;;; i670
;
; [293] CASE $$XLONG : argExpVal = value$$
	jmp	end.select.0023.xformat			;;; i69
case.0023.0001.xformat:
	mov	eax,8			;;; i659
	mov	ebx,d[ebp-200]			;;; i665
	cmp	eax,ebx			;;; i684a
	jne	>> case.0023.0002.xformat			;;; i71
	mov	eax,d[ebp-196]			;;; i665
	mov	edx,d[ebp-192]
	or	eax,eax			;;; i417
	jns	> A.32			;;; i418
	not	edx			;;; i419
A.32:
	test	edx,edx			;;; i420
	jz	> A.33			;;; i421a
	call	%_eeeOverflow			;;; i421b
A.33:
	mov	d[ebp-76],eax			;;; i670
;
; [294] END SELECT
case.0023.0002.xformat:
end.select.0023.xformat:
;
; [295] ' end of substitution
;
; [297] argStr$ = LEFT$ (argStr$, argExpIx - 1)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-72]			;;; i665
	sub	eax,1			;;; i791
	mov	d[esp+4],eax			;;; i887
	call	%_left.d.v			;;; i578
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [298] END IF
else.0022.xformat:
end.if.0022.xformat:
;
; [299] '
;
; [300] ' length of argument string after sign, exponent and DP are removed
;
; [301] '
;
; [302] lenArg = LEN (argStr$)
	mov	eax,d[ebp-60]			;;; i665
	test	eax,eax			;;; i593
	jz	> A.34			;;; i594
	mov	eax,d[eax-8]			;;; i595
A.34:
	mov	d[ebp-52],eax			;;; i670
;
; [303] '
;
; [304] ' get argument decimal point location. Remove it from argStr and
;
; [305] '		deincrement lenArg if needed.
;
; [306] '
;
; [307] argDPLoc = INSTR (argStr$, ".")
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,addr @_string.008C.xformat			;;; i663
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],0			;;; i571
	call	%_instr.vv			;;; i572
	add	esp,64			;;; i600
	mov	d[ebp-64],eax			;;; i670
;
; [308] IFZ argDPLoc THEN
	mov	eax,d[ebp-64]			;;; i665
	test	eax,eax			;;; i194
	jnz	>> else.0024.xformat			;;; i195
;
; [309] argDPLoc = lenArg + 1
	mov	eax,d[ebp-52]			;;; i665
	add	eax,1			;;; i775
	mov	d[ebp-64],eax			;;; i670
;
; [310] ELSE
	jmp	end.if.0024.xformat			;;; i107
else.0024.xformat:
;
; [311] argStr$ = LEFT$(argStr$, argDPLoc -1) + MID$(argStr$, argDPLoc +1)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-64]			;;; i665
	sub	eax,1			;;; i791
	mov	d[esp+4],eax			;;; i887
	call	%_left.d.v			;;; i578
	add	esp,64			;;; i600
	mov	[ebp-152],eax			;;; i670
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-64]			;;; i665
	add	eax,1			;;; i775
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	mov	ebx,[ebp-152]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.ss			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [312] DEC lenArg
	dec	d[ebp-52]			;;; i84
;
; [313] END IF
end.if.0024.xformat:
;
; [314] '
;
; [315] k = 0
	mov	eax,0			;;; i659
	mov	d[ebp-204],eax			;;; i670
;
; [316] DO WHILE argStr${k} = '0'
do.0025.xformat:
	mov	eax,d[ebp-204]			;;; i665
	mov	edx,d[ebp-60]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	cmp	eax,48			;;; i684a
	jne	>> end.do.0025.xformat			;;; i219
;
; [317] DEC argExpVal
	dec	d[ebp-76]			;;; i84
;
; [318] INC k
	inc	d[ebp-204]			;;; i84
;
; [319] LOOP
do.loop.0025.xformat:
	jmp	do.0025.xformat			;;; i222
end.do.0025.xformat:
;
; [320] argStr$ = MID$(argStr$, k+1)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-204]			;;; i665
	add	eax,1			;;; i775
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [321] lenArg = lenArg - k
	mov	eax,d[ebp-52]			;;; i665
	mov	ebx,d[ebp-204]			;;; i665
	sub	eax,ebx			;;; i791
	mov	d[ebp-52],eax			;;; i670
;
; [322] '
;
; [323] ' argMSDOrder, if pos, is the exponent of the most significant digit.
;
; [324] '		if neg, it is one less than the exponent.
;
; [325] '
;
; [326] argMSDOrder = argDPLoc - 1 + argExpVal
	mov	eax,d[ebp-64]			;;; i665
	sub	eax,1			;;; i791
	mov	ebx,d[ebp-76]			;;; i665
	add	eax,ebx			;;; i775
	mov	d[ebp-80],eax			;;; i670
;
; [327] '
;
; [328] ' numShift is the power of 10 difference between the MSD of the format
;
; [329] '		and the MSD of the argument
;
; [330] '
;
; [331] numShift = preDec - argMSDOrder
	mov	eax,d[ebp-108]			;;; i665
	mov	ebx,d[ebp-80]			;;; i665
	sub	eax,ebx			;;; i791
	mov	d[ebp-68],eax			;;; i670
;
; [332] '
;
; [333] ' put numeric argument string and format together
;
; [334] '
;
; [335] IFZ expCtr THEN											' formats without an exponent
	mov	eax,d[ebp-116]			;;; i665
	test	eax,eax			;;; i194
	jnz	>> else.0026.xformat			;;; i195
;
; [336] IF (numShift > 0) THEN
	mov	eax,d[ebp-68]			;;; i665
	cmp	eax,0			;;; i684a
	jle	>> else.0027.xformat			;;; i219
;
; [337] argStr$ = CHR$ ('0', numShift) + argStr$
	sub	esp,64			;;; i487
	mov	eax,48			;;; i659
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-68]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	mov	ebx,[ebp-60]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [338] lenArg = lenArg + numShift
	mov	eax,d[ebp-52]			;;; i665
	mov	ebx,d[ebp-68]			;;; i665
	add	eax,ebx			;;; i775
	mov	d[ebp-52],eax			;;; i670
;
; [339] END IF
else.0027.xformat:
end.if.0027.xformat:
;
; [340] GOSUB Rounder
	call	%s%Rounder%3			;;; i163
;
; [341] '
;
; [342] ' restore DP and add commas
;
; [343] '
;
; [344] IF hasDec THEN
	mov	eax,d[ebp-120]			;;; i665
	test	eax,eax			;;; i220
	jz	>> else.0028.xformat			;;; i221
;
; [345] IF (preDec > argMSDOrder) THEN
	mov	eax,d[ebp-108]			;;; i665
	mov	ebx,d[ebp-80]			;;; i665
	cmp	eax,ebx			;;; i684a
	jle	>> else.0029.xformat			;;; i219
;
; [346] argStr$ = LEFT$(argStr$, preDec) + "." + MID$(argStr$, preDec +1)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-108]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_left.d.v			;;; i578
	add	esp,64			;;; i600
	mov	ebx,addr @_string.008C.xformat			;;; i663
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	mov	[ebp-152],eax			;;; i670
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-108]			;;; i665
	add	eax,1			;;; i775
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	mov	ebx,[ebp-152]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.ss			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [347] comIx = preDec
	mov	eax,d[ebp-108]			;;; i665
	mov	d[ebp-208],eax			;;; i670
;
; [348] ELSE
	jmp	end.if.0029.xformat			;;; i107
else.0029.xformat:
;
; [349] argStr$ = LEFT$(argStr$, argMSDOrder) + "." + MID$(argStr$, argMSDOrder +1)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-80]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_left.d.v			;;; i578
	add	esp,64			;;; i600
	mov	ebx,addr @_string.008C.xformat			;;; i663
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	mov	[ebp-152],eax			;;; i670
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-80]			;;; i665
	add	eax,1			;;; i775
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	mov	ebx,[ebp-152]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.ss			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [350] comIx = argMSDOrder
	mov	eax,d[ebp-80]			;;; i665
	mov	d[ebp-208],eax			;;; i670
;
; [351] END IF
end.if.0029.xformat:
;
; [352] ELSE												' no decimal place
	jmp	end.if.0028.xformat			;;; i107
else.0028.xformat:
;
; [353] IF (preDec > argMSDOrder) THEN
	mov	eax,d[ebp-108]			;;; i665
	mov	ebx,d[ebp-80]			;;; i665
	cmp	eax,ebx			;;; i684a
	jle	>> else.002A.xformat			;;; i219
;
; [354] comIx = preDec
	mov	eax,d[ebp-108]			;;; i665
	mov	d[ebp-208],eax			;;; i670
;
; [355] ELSE
	jmp	end.if.002A.xformat			;;; i107
else.002A.xformat:
;
; [356] comIx = argMSDOrder
	mov	eax,d[ebp-80]			;;; i665
	mov	d[ebp-208],eax			;;; i670
;
; [357] END IF
end.if.002A.xformat:
;
; [358] END IF
end.if.0028.xformat:
;
; [359] '
;
; [360] IF (commaFlag AND (argMSDOrder > 3)) THEN GOSUB AddCommas
	mov	eax,d[ebp-80]			;;; i665
	cmp	eax,3			;;; i684a
	mov	eax,0			;;; i466
	jle	> A.35			;;; i467
	not	eax			;;; i468
A.35:
	mov	ebx,d[ebp-124]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.002B.xformat			;;; i221
	call	%s%AddCommas%3			;;; i163
else.002B.xformat:
end.if.002B.xformat:
;
; [361] '
;
; [362] ' strip off any leading 0s before DP
;
; [363] '
;
; [364] IF ((argMSDOrder < preDec) AND (preDec > 0)) THEN
	mov	eax,d[ebp-80]			;;; i665
	mov	ebx,d[ebp-108]			;;; i665
	cmp	eax,ebx			;;; i684a
	mov	eax,0			;;; i466
	jge	> A.36			;;; i467
	not	eax			;;; i468
A.36:
	mov	ebx,d[ebp-108]			;;; i665
	cmp	ebx,0			;;; i684a
	mov	ebx,0			;;; i466
	jle	> A.37			;;; i467
	not	ebx			;;; i468
A.37:
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.002C.xformat			;;; i221
;
; [365] IF (argMSDOrder <= 1) THEN
	mov	eax,d[ebp-80]			;;; i665
	cmp	eax,1			;;; i684a
	jg	>> else.002D.xformat			;;; i219
;
; [366] argStr$ = MID$(argStr$, preDec)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-108]			;;; i665
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [367] ELSE
	jmp	end.if.002D.xformat			;;; i107
else.002D.xformat:
;
; [368] argStr$ = MID$(argStr$, preDec - argMSDOrder + 1)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-108]			;;; i665
	mov	ebx,d[ebp-80]			;;; i665
	sub	eax,ebx			;;; i791
	add	eax,1			;;; i775
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [369] END IF
end.if.002D.xformat:
;
; [370] END IF
else.002C.xformat:
end.if.002C.xformat:
;
; [371] '
;
; [372] ' if not enough digits in format then set mess up formatting flag
;
; [373] '
;
; [374] IF (LEN(argStr$) > (preDec + postDec + hasDec)) THEN errSign$ = "%"
	mov	eax,d[ebp-60]			;;; i665
	test	eax,eax			;;; i593
	jz	> A.38			;;; i594
	mov	eax,d[eax-8]			;;; i595
A.38:
	mov	d[ebp-152],eax			;;; i670
	mov	eax,d[ebp-108]			;;; i665
	mov	ebx,d[ebp-112]			;;; i665
	add	eax,ebx			;;; i775
	mov	ebx,d[ebp-120]			;;; i665
	add	eax,ebx			;;; i775
	mov	ebx,d[ebp-152]			;;; i665
	cmp	eax,ebx			;;; i684a
	jge	>> else.002E.xformat			;;; i219
	mov	eax,addr @_string.0091.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-144]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
else.002E.xformat:
end.if.002E.xformat:
;
; [375] ELSE										' formats with exponent
	jmp	end.if.0026.xformat			;;; i107
else.0026.xformat:
;
; [376] GOSUB Rounder					' round off significant digits
	call	%s%Rounder%3			;;; i163
;
; [377] '
;
; [378] ' restore DP
;
; [379] '
;
; [380] IF hasDec THEN argStr$ = LEFT$(argStr$, preDec) + "." + MID$(argStr$, preDec +1)
	mov	eax,d[ebp-120]			;;; i665
	test	eax,eax			;;; i220
	jz	>> else.002F.xformat			;;; i221
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-108]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_left.d.v			;;; i578
	add	esp,64			;;; i600
	mov	ebx,addr @_string.008C.xformat			;;; i663
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	mov	[ebp-152],eax			;;; i670
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-108]			;;; i665
	add	eax,1			;;; i775
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	mov	ebx,[ebp-152]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.ss			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
else.002F.xformat:
end.if.002F.xformat:
;
; [381] '
;
; [382] ' get exponent in usable form
;
; [383] '
;
; [384] expString$ = STR$ (numShift * -1)
	sub	esp,64			;;; i487
	mov	eax,1			;;; i659
	neg	eax			;;; i916
	mov	ebx,d[ebp-68]			;;; i665
	imul	eax,ebx			;;; i805
	mov	d[esp],eax			;;; i887
	call	%_str.d.xlong			;;; i576
	add	esp,64			;;; i600
	lea	ebx,[ebp-212]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [385] IF (expString${0} = ' ') THEN expString${0} = '+'
	mov	edx,d[ebp-212]			;;; i665
	movzx	eax,b[edx]			;;; i464
	cmp	eax,32			;;; i684a
	jne	>> else.0030.xformat			;;; i219
	mov	eax,43			;;; i659
	mov	ecx,d[ebp-212]			;;; i665
	lea	ebx,[ecx]			;;; i464
	mov	b[ebx],al			;;; i29
else.0030.xformat:
end.if.0030.xformat:
;
; [386] expLen = LEN (expString$)
	mov	eax,d[ebp-212]			;;; i665
	test	eax,eax			;;; i593
	jz	> A.39			;;; i594
	mov	eax,d[eax-8]			;;; i595
A.39:
	mov	d[ebp-216],eax			;;; i670
;
; [387] DEC expCtr
	dec	d[ebp-116]			;;; i84
;
; [388] '
;
; [389] SELECT CASE TRUE
;
; [390] CASE (expLen < expCtr)
	mov	eax,d[ebp-216]			;;; i665
	mov	ebx,d[ebp-116]			;;; i665
	cmp	eax,ebx			;;; i684a
	jge	>> case.0031.0001.xformat			;;; i219
;
; [391] expString$ = LEFT$ (expString$, 1) + CHR$ ('0', expCtr - expLen) + MID$ (expString$, 2)
	sub	esp,64			;;; i487
	mov	eax,[ebp-212]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	d[esp+4],1
	call	%_left.d.v			;;; i578
	add	esp,64			;;; i600
	mov	[ebp-152],eax			;;; i670
	sub	esp,64			;;; i487
	mov	eax,48			;;; i659
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-116]			;;; i665
	mov	ebx,d[ebp-216]			;;; i665
	sub	eax,ebx			;;; i791
	mov	d[esp+4],eax			;;; i887
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	mov	ebx,[ebp-152]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.ss			;;; i782
	mov	[ebp-152],eax			;;; i670
	sub	esp,64			;;; i487
	mov	eax,[ebp-212]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	d[esp+4],2
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	mov	ebx,[ebp-152]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.ss			;;; i782
	lea	ebx,[ebp-212]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [392] CASE (expLen > expCtr)
	jmp	end.select.0031.xformat			;;; i69
case.0031.0001.xformat:
	mov	eax,d[ebp-216]			;;; i665
	mov	ebx,d[ebp-116]			;;; i665
	cmp	eax,ebx			;;; i684a
	jle	>> case.0031.0002.xformat			;;; i219
;
; [393] errSign$ = "%"
	mov	eax,addr @_string.0091.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-144]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [394] END SELECT
case.0031.0002.xformat:
end.select.0031.xformat:
;
; [395] argStr$ = argStr$ + "E" + expString$
	mov	eax,[ebp-60]			;;; i665
	mov	ebx,addr @_string.0095.xformat			;;; i663
	call	%_concat.ubyte.a0.eq.a0.plus.a1.vv			;;; i782
	mov	ebx,[ebp-212]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [396] END IF
end.if.0026.xformat:
;
; [397] '
;
; [398] ' take care of leading and trailing sign stuff
;
; [399] '
;
; [400] IF (negArg = '-') THEN
	mov	eax,d[ebp-56]			;;; i665
	cmp	eax,45			;;; i684a
	jne	>> else.0032.xformat			;;; i219
;
; [401] SELECT CASE TRUE
;
; [402] CASE (leadSign$ = "") AND (trailSign$ = ""):	leadSign$  = "-"
	mov	eax,[ebp-136]			;;; i665
	xor	ebx,ebx			;;; i658
	call	%_string.compare.vv			;;; i690
	mov	eax,0			;;; i466
	jne	> A.40			;;; i467
	not	eax			;;; i468
A.40:
	mov	d[ebp-152],eax			;;; i670
	mov	eax,[ebp-140]			;;; i665
	xor	ebx,ebx			;;; i658
	call	%_string.compare.vv			;;; i690
	mov	eax,0			;;; i466
	jne	> A.41			;;; i467
	not	eax			;;; i468
A.41:
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> case.0033.0001.xformat			;;; i221
	mov	eax,addr @_string.0096.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-136]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [403] CASE (leadSign$ = "+"):												leadSign$  = "-"
	jmp	end.select.0033.xformat			;;; i69
case.0033.0001.xformat:
	mov	eax,[ebp-136]			;;; i665
	mov	ebx,addr @_string.0097.xformat			;;; i663
	call	%_string.compare.vv			;;; i690
	jne	>> case.0033.0002.xformat			;;; i219
	mov	eax,addr @_string.0096.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-136]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [404] CASE (trailSign$ = "+"):											trailSign$ = "-"
	jmp	end.select.0033.xformat			;;; i69
case.0033.0002.xformat:
	mov	eax,[ebp-140]			;;; i665
	mov	ebx,addr @_string.0097.xformat			;;; i663
	call	%_string.compare.vv			;;; i690
	jne	>> case.0033.0003.xformat			;;; i219
	mov	eax,addr @_string.0096.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-140]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [405] END SELECT
case.0033.0003.xformat:
end.select.0033.xformat:
;
; [406] ELSE
	jmp	end.if.0032.xformat			;;; i107
else.0032.xformat:
;
; [407] SELECT CASE TRUE
;
; [408] CASE (leadSign$ = "(") AND (trailSign$ = ")")
	mov	eax,[ebp-136]			;;; i665
	mov	ebx,addr @_string.007B.xformat			;;; i663
	call	%_string.compare.vv			;;; i690
	mov	eax,0			;;; i466
	jne	> A.42			;;; i467
	not	eax			;;; i468
A.42:
	mov	d[ebp-152],eax			;;; i670
	mov	eax,[ebp-140]			;;; i665
	mov	ebx,addr @_string.0072.xformat			;;; i663
	call	%_string.compare.vv			;;; i690
	mov	eax,0			;;; i466
	jne	> A.43			;;; i467
	not	eax			;;; i468
A.43:
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> case.0034.0001.xformat			;;; i221
;
; [409] leadSign$ = " "
	mov	eax,addr @_string.0098.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-136]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [410] trailSign$ = " "
	mov	eax,addr @_string.0098.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-140]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [411] CASE trailSign$ = "-"
	jmp	end.select.0034.xformat			;;; i69
case.0034.0001.xformat:
	mov	eax,[ebp-140]			;;; i665
	mov	ebx,addr @_string.0096.xformat			;;; i663
	call	%_string.compare.vv			;;; i690
	jne	>> case.0034.0002.xformat			;;; i219
;
; [412] trailSign$ = " "
	mov	eax,addr @_string.0098.xformat			;;; i663
	call	%_clone.a0			;;; i3
	lea	ebx,[ebp-140]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [413] END SELECT
case.0034.0002.xformat:
end.select.0034.xformat:
;
; [414] END IF
end.if.0032.xformat:
;
; [415] '
;
; [416] ' add signs and padding as necessary
;
; [417] '
;
; [418] argStr$ = leadSign$ + dollarSign$ + argStr$ + trailSign$
	mov	eax,[ebp-136]			;;; i665
	mov	ebx,[ebp-132]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.vv			;;; i782
	mov	ebx,[ebp-60]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	mov	ebx,[ebp-140]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [419] padLen  = nPlaces - LEN(argStr$)
	mov	eax,d[ebp-60]			;;; i665
	test	eax,eax			;;; i593
	jz	> A.44			;;; i594
	mov	eax,d[eax-8]			;;; i595
A.44:
	mov	ebx,d[ebp-104]			;;; i665
	xchg	eax,ebx			;;; i790
	sub	eax,ebx			;;; i791
	mov	d[ebp-220],eax			;;; i670
;
; [420] IF (padLen > 0) THEN
	mov	eax,d[ebp-220]			;;; i665
	cmp	eax,0			;;; i684a
	jle	>> else.0035.xformat			;;; i219
;
; [421] IF padFlag THEN
	mov	eax,d[ebp-128]			;;; i665
	test	eax,eax			;;; i220
	jz	>> else.0036.xformat			;;; i221
;
; [422] argStr$ = CHR$ ('*', padLen) + argStr$
	sub	esp,64			;;; i487
	mov	eax,42			;;; i659
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-220]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	mov	ebx,[ebp-60]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [423] ELSE
	jmp	end.if.0036.xformat			;;; i107
else.0036.xformat:
;
; [424] argStr$ = CHR$ (' ', padLen) + argStr$
	sub	esp,64			;;; i487
	mov	eax,32			;;; i659
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-220]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	mov	ebx,[ebp-60]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [425] END IF
end.if.0036.xformat:
;
; [426] END IF
else.0035.xformat:
end.if.0035.xformat:
;
; [427] resultString$ = resultString$ + errSign$ + argStr$
	mov	eax,[ebp-36]			;;; i665
	mov	ebx,[ebp-144]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.vv			;;; i782
	mov	ebx,[ebp-60]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	lea	ebx,[ebp-36]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [428] INC fmtStrPtr
	inc	d[ebp-28]			;;; i84
;
; [429] EXIT DO
	jmp	end.do.000A.xformat			;;; i144
;
; [430] END IF
else.001D.xformat:
end.if.001D.xformat:
;
; [431] INC fmtStrPtr							' incremented when looping through fmt chars
	inc	d[ebp-28]			;;; i84
;
; [432] LOOP
do.loop.000A.xformat:
	jmp	do.000A.xformat			;;; i222
end.do.000A.xformat:
;
; [433] GOSUB StringString					' get trailing constant string, if any
	call	%s%StringString%3			;;; i163
;
; [434] '
;
; [435] ' reset fmt string ptrs to cycle through again as necessary
;
; [436] '
;
; [437] IF ((fmtStrPtr = 0) AND (argIx < nArg-1)) THEN
	mov	eax,d[ebp-28]			;;; i665
	cmp	eax,0			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.45			;;; i467
	not	eax			;;; i468
A.45:
	mov	ebx,d[ebp-228]			;;; i665
	sub	ebx,1			;;; i791
	mov	d[ebp-152],eax			;;; i670
	mov	eax,d[ebp-224]			;;; i665
	cmp	eax,ebx			;;; i684a
	mov	eax,0			;;; i466
	jge	> A.46			;;; i467
	not	eax			;;; i468
A.46:
	mov	ebx,d[ebp-152]			;;; i665
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.0037.xformat			;;; i221
;
; [438] fmtStrPtr = 1
	mov	eax,1			;;; i659
	mov	d[ebp-28],eax			;;; i670
;
; [439] GOSUB StringString
	call	%s%StringString%3			;;; i163
;
; [440] END IF
else.0037.xformat:
end.if.0037.xformat:
;
; [441] '	PRINT "b<" + resultString$ + "> " + STRING$(LEN(resultString$))
;
; [442] RETURN (resultString$)
	mov	eax,[ebp-36]			;;; i665
	xor	esi,esi			;;; i869
	mov	d[ebp-36],esi			;;; i670
	jmp	end.func3.xformat			;;; i258
;
; [443] '
;
; [444] '
;
; [445] ' *****  Initialize  *****
;
; [446] '
;
; [447] SUB Initialize
	jmp	out.sub3.0.xformat			;;; i262
%s%Initialize%3:
;
; [448] DIM fmtLevel[255]		' initialize format character priority level arrays
	sub	esp,64			;;; i430
	mov	eax,255			;;; i659
	mov	d[esp+16],eax			;;; i432
	mov	esi,d[%%3%%fmtLevel.xformat]			;;; i663a
	mov	d[esp],esi			;;; i433
	mov	d[esp+4],1			;;; i434
	mov	d[esp+8],-1073545215			;;; i435
	mov	d[esp+12],0			;;; i436
	call	%_DimArray			;;; i437
	add	esp,64			;;; i438
	mov	d[%%3%%fmtLevel.xformat],eax			;;; i668
;
; [449] DIM fmtBegin[255]
	sub	esp,64			;;; i430
	mov	eax,255			;;; i659
	mov	d[esp+16],eax			;;; i432
	mov	esi,d[%%3%%fmtBegin.xformat]			;;; i663a
	mov	d[esp],esi			;;; i433
	mov	d[esp+4],1			;;; i434
	mov	d[esp+8],-1073545215			;;; i435
	mov	d[esp+12],0			;;; i436
	call	%_DimArray			;;; i437
	add	esp,64			;;; i438
	mov	d[%%3%%fmtBegin.xformat],eax			;;; i668
;
; [450] '
;
; [451] ' All format characters are listed in fmtLevel.
;
; [452] ' The fmtBegin array is used to determine the legitimacy of formats
;
; [453] ' that cannot stand alone. These formats require a sequence of characters
;
; [454] ' to establish their legitimacy.
;
; [455] ' The lower the format level value, the higher the priority, so the
;
; [456] ' characters not given a priority level here default to fmtlevel[] = 0,
;
; [457] ' and therefore the highest priority. The lowest priority = 255.
;
; [458] '
;
; [459] fmtLevel['&'] =  20
	mov	eax,20			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+38]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [460] fmtLevel['<'] =  30
	mov	eax,30			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+60]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [461] fmtLevel['|'] =  30
	mov	eax,30			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+124]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [462] fmtLevel['>'] =  30
	mov	eax,30			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+62]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [463] fmtLevel['+'] =  40:	fmtBegin['+'] =  40
	mov	eax,40			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+43]			;;; i464
	mov	b[ebx],al			;;; i30
	mov	eax,40			;;; i659
	mov	ecx,d[%%3%%fmtBegin.xformat]			;;; i663a
	lea	ebx,[ecx+43]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [464] fmtLevel['-'] =  40:	fmtBegin['-'] =  40
	mov	eax,40			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+45]			;;; i464
	mov	b[ebx],al			;;; i30
	mov	eax,40			;;; i659
	mov	ecx,d[%%3%%fmtBegin.xformat]			;;; i663a
	lea	ebx,[ecx+45]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [465] fmtLevel['('] =  40:	fmtBegin['('] =  40
	mov	eax,40			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+40]			;;; i464
	mov	b[ebx],al			;;; i30
	mov	eax,40			;;; i659
	mov	ecx,d[%%3%%fmtBegin.xformat]			;;; i663a
	lea	ebx,[ecx+40]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [466] fmtLevel['*'] =  50:	fmtBegin['*'] =  50
	mov	eax,50			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+42]			;;; i464
	mov	b[ebx],al			;;; i30
	mov	eax,50			;;; i659
	mov	ecx,d[%%3%%fmtBegin.xformat]			;;; i663a
	lea	ebx,[ecx+42]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [467] fmtLevel['$'] =  60:	fmtBegin['$'] =  60
	mov	eax,60			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+36]			;;; i464
	mov	b[ebx],al			;;; i30
	mov	eax,60			;;; i659
	mov	ecx,d[%%3%%fmtBegin.xformat]			;;; i663a
	lea	ebx,[ecx+36]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [468] fmtLevel['#'] =  70
	mov	eax,70			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+35]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [469] fmtLevel[','] =  80:	fmtBegin[','] =  80
	mov	eax,80			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+44]			;;; i464
	mov	b[ebx],al			;;; i30
	mov	eax,80			;;; i659
	mov	ecx,d[%%3%%fmtBegin.xformat]			;;; i663a
	lea	ebx,[ecx+44]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [470] fmtLevel['.'] =  90:	fmtBegin['.'] =  90
	mov	eax,90			;;; i659
	mov	ecx,d[%%3%%fmtLevel.xformat]			;;; i663a
	lea	ebx,[ecx+46]			;;; i464
	mov	b[ebx],al			;;; i30
	mov	eax,90			;;; i659
	mov	ecx,d[%%3%%fmtBegin.xformat]			;;; i663a
	lea	ebx,[ecx+46]			;;; i464
	mov	b[ebx],al			;;; i30
;
; [471] '
;
; [472] '	fmtLevel['^'] =   0		' When these two are format characters, they will be
;
; [473] '	fmtLevel[')'] =   0		' picked up by checking nextChar (just like trailing
;
; [474] '													' signs).
;
; [475] END SUB
end.sub3.0.xformat:
	ret				;;; i127
out.sub3.0.xformat:
;
; [476] '
;
; [477] ' *****  StringString  *****
;
; [478] '
;
; [479] SUB StringString
	jmp	out.sub3.1.xformat			;;; i262
%s%StringString%3:
;
; [480] DO
do.0038.xformat:
;
; [481] fmtThisPtr = fmtStrPtr - 1
	mov	eax,d[ebp-28]			;;; i665
	sub	eax,1			;;; i791
	mov	d[ebp-240],eax			;;; i670
;
; [482] q = format${fmtThisPtr}
	mov	eax,d[ebp-240]			;;; i665
	mov	edx,d[ebp+8]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-244],eax			;;; i670
;
; [483] qq = fmtBegin[q]
	mov	eax,d[ebp-244]			;;; i665
	mov	edx,d[%%3%%fmtBegin.xformat]			;;; i663a
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-248],eax			;;; i670
;
; [484] qqq = fmtLevel[q]
	mov	eax,d[ebp-244]			;;; i665
	mov	edx,d[%%3%%fmtLevel.xformat]			;;; i663a
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-252],eax			;;; i670
;
; [485] IFZ q THEN EXIT DO
	mov	eax,d[ebp-244]			;;; i665
	test	eax,eax			;;; i194
	jnz	>> else.0039.xformat			;;; i195
	jmp	end.do.0038.xformat			;;; i144
else.0039.xformat:
end.if.0039.xformat:
;
; [486] r = format${fmtStrPtr}
	mov	eax,d[ebp-28]			;;; i665
	mov	edx,d[ebp+8]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-256],eax			;;; i670
;
; [487] SELECT CASE TRUE
;
; [488] CASE (q = '_')	: INC fmtStrPtr: q = r
	mov	eax,d[ebp-244]			;;; i665
	cmp	eax,95			;;; i684a
	jne	>> case.003A.0001.xformat			;;; i219
	inc	d[ebp-28]			;;; i84
	mov	eax,d[ebp-256]			;;; i665
	mov	d[ebp-244],eax			;;; i670
;
; [489] CASE qq					: IF ValidFormat (format$, fmtThisPtr) THEN EXIT DO
	jmp	end.select.003A.xformat			;;; i69
case.003A.0001.xformat:
	mov	eax,d[ebp-248]			;;; i665
	test	eax,eax			;;; i220
	jz	>> case.003A.0002.xformat			;;; i221
	mov	eax,d[ebp+8]			;;; i665
	call	%_clone.a0			;;; i634
	mov	d[ebp-152],eax			;;; i670
	push	[ebp-240]			;;; i674a
	push	[ebp-152]			;;; i674a
	call	func2.xformat			;;; i619
	sub	esp,8			;;; xnt1i
	mov	esi,d[esp]			;;; i871
	call	%____free			;;; i872
	add	esp,8			;;; i633
	test	eax,eax			;;; i220
	jz	>> else.003B.xformat			;;; i221
	jmp	end.do.0038.xformat			;;; i144
else.003B.xformat:
end.if.003B.xformat:
;
; [490] CASE qqq				: EXIT DO
	jmp	end.select.003A.xformat			;;; i69
case.003A.0002.xformat:
	mov	eax,d[ebp-252]			;;; i665
	test	eax,eax			;;; i220
	jz	>> case.003A.0003.xformat			;;; i221
	jmp	end.do.0038.xformat			;;; i144
;
; [491] END SELECT
case.003A.0003.xformat:
end.select.003A.xformat:
;
; [492] resultString$ = resultString$ + CHR$ (q)
	sub	esp,64			;;; i487
	mov	eax,d[ebp-244]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	d[esp+4],1
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	mov	ebx,[ebp-36]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.vs			;;; i782
	lea	ebx,[ebp-36]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [493] INC fmtStrPtr
	inc	d[ebp-28]			;;; i84
;
; [494] LOOP
do.loop.0038.xformat:
	jmp	do.0038.xformat			;;; i222
end.do.0038.xformat:
;
; [495] IF (fmtStrPtr > lenFmtStr) THEN fmtStrPtr = 0
	mov	eax,d[ebp-28]			;;; i665
	mov	ebx,d[ebp-32]			;;; i665
	cmp	eax,ebx			;;; i684a
	jle	>> else.003C.xformat			;;; i219
	mov	eax,0			;;; i659
	mov	d[ebp-28],eax			;;; i670
else.003C.xformat:
end.if.003C.xformat:
;
; [496] END SUB
end.sub3.1.xformat:
	ret				;;; i127
out.sub3.1.xformat:
;
; [497] '
;
; [498] ' *****  AddCommas  *****
;
; [499] '
;
; [500] SUB AddCommas
	jmp	out.sub3.2.xformat			;;; i262
%s%AddCommas%3:
;
; [501] DO WHILE comIx > (preDec - argMSDOrder + 3)
do.003D.xformat:
	mov	eax,d[ebp-108]			;;; i665
	mov	ebx,d[ebp-80]			;;; i665
	sub	eax,ebx			;;; i791
	add	eax,3			;;; i775
	mov	ebx,d[ebp-208]			;;; i665
	cmp	eax,ebx			;;; i684a
	jge	>> end.do.003D.xformat			;;; i219
;
; [502] comIx = comIx - 3
	mov	eax,d[ebp-208]			;;; i665
	sub	eax,3			;;; i791
	mov	d[ebp-208],eax			;;; i670
;
; [503] argStr$ = LEFT$(argStr$, comIx) + "," + MID$(argStr$, comIx+1)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-208]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_left.d.v			;;; i578
	add	esp,64			;;; i600
	mov	ebx,addr @_string.00A5.xformat			;;; i663
	call	%_concat.ubyte.a0.eq.a0.plus.a1.sv			;;; i782
	mov	[ebp-152],eax			;;; i670
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-208]			;;; i665
	add	eax,1			;;; i775
	mov	d[esp+4],eax			;;; i887
	mov	d[esp+8],2147483647			;;; i579
	call	%_mid.d.v			;;; i580
	add	esp,64			;;; i600
	mov	ebx,[ebp-152]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.ss			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [504] INC lenArg
	inc	d[ebp-52]			;;; i84
;
; [505] LOOP
do.loop.003D.xformat:
	jmp	do.003D.xformat			;;; i222
end.do.003D.xformat:
;
; [506] END SUB
end.sub3.2.xformat:
	ret				;;; i127
out.sub3.2.xformat:
;
; [507] '
;
; [508] ' *****  Rounder  *****
;
; [509] '
;
; [510] SUB Rounder
	jmp	out.sub3.3.xformat			;;; i262
%s%Rounder%3:
;
; [511] IF ((expCtr = 0) AND (numShift < 0)) THEN		' no fmt exp & int(arg) > int(fmt)
	mov	eax,d[ebp-116]			;;; i665
	cmp	eax,0			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.47			;;; i467
	not	eax			;;; i468
A.47:
	mov	ebx,d[ebp-68]			;;; i665
	cmp	ebx,0			;;; i684a
	mov	ebx,0			;;; i466
	jge	> A.48			;;; i467
	not	ebx			;;; i468
A.48:
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.003E.xformat			;;; i221
;
; [512] fmtDigCtr = argMSDOrder + postDec
	mov	eax,d[ebp-80]			;;; i665
	mov	ebx,d[ebp-112]			;;; i665
	add	eax,ebx			;;; i775
	mov	d[ebp-268],eax			;;; i670
;
; [513] ELSE
	jmp	end.if.003E.xformat			;;; i107
else.003E.xformat:
;
; [514] fmtDigCtr = preDec + postDec
	mov	eax,d[ebp-108]			;;; i665
	mov	ebx,d[ebp-112]			;;; i665
	add	eax,ebx			;;; i775
	mov	d[ebp-268],eax			;;; i670
;
; [515] END IF
end.if.003E.xformat:
;
; [516] '
;
; [517] IF (lenArg > fmtDigCtr) THEN
	mov	eax,d[ebp-52]			;;; i665
	mov	ebx,d[ebp-268]			;;; i665
	cmp	eax,ebx			;;; i684a
	jle	>> else.003F.xformat			;;; i219
;
; [518] rndDig  = argStr${fmtDigCtr}
	mov	eax,d[ebp-268]			;;; i665
	mov	edx,d[ebp-60]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-272],eax			;;; i670
;
; [519] argStr$ = LEFT$(argStr$, fmtDigCtr)
	sub	esp,64			;;; i487
	mov	eax,[ebp-60]			;;; i665
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-268]			;;; i665
	mov	d[esp+4],eax			;;; i887
	call	%_left.d.v			;;; i578
	add	esp,64			;;; i600
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [520] '
;
; [521] IF (rndDig >= '5') THEN
	mov	eax,d[ebp-272]			;;; i665
	cmp	eax,53			;;; i684a
	jl	>> else.0040.xformat			;;; i219
;
; [522] stopIt = $$FALSE
	mov	eax,0			;;; i659
	mov	d[ebp-276],eax			;;; i670
;
; [523] DO UNTIL stopIt OR (fmtDigCtr = 0)		' DO WHILE (fmtDigCtr) in using9.x
do.0041.xformat:
	mov	eax,d[ebp-268]			;;; i665
	cmp	eax,0			;;; i684a
	mov	eax,0			;;; i466
	jne	> A.49			;;; i467
	not	eax			;;; i468
A.49:
	mov	ebx,d[ebp-276]			;;; i665
	or	eax,ebx			;;; i763
	test	eax,eax			;;; i194
	jnz	>> end.do.0041.xformat			;;; i195
;
; [524] DEC fmtDigCtr
	dec	d[ebp-268]			;;; i84
;
; [525] lastDig = argStr${fmtDigCtr}
	mov	eax,d[ebp-268]			;;; i665
	mov	edx,d[ebp-60]			;;; i665
	movzx	eax,b[edx+eax]			;;; i464
	mov	d[ebp-280],eax			;;; i670
;
; [526] INC lastDig
	inc	d[ebp-280]			;;; i84
;
; [527] IF (lastDig = 0x3a) THEN
	mov	eax,d[ebp-280]			;;; i665
	cmp	eax,58			;;; i684a
	jne	>> else.0042.xformat			;;; i219
;
; [528] lastDig = '0'											' 9 -> 0: keep rounding
	mov	eax,48			;;; i659
	mov	d[ebp-280],eax			;;; i670
;
; [529] ELSE
	jmp	end.if.0042.xformat			;;; i107
else.0042.xformat:
;
; [530] stopIt = $$TRUE										' no more rounding
	mov	eax,-1			;;; i659
	mov	d[ebp-276],eax			;;; i670
;
; [531] END IF
end.if.0042.xformat:
;
; [532] argStr${fmtDigCtr} = lastDig
	mov	eax,d[ebp-280]			;;; i665
	mov	ebx,d[ebp-268]			;;; i665
	mov	ecx,d[ebp-60]			;;; i665
	lea	ebx,[ecx+ebx]			;;; i464
	mov	b[ebx],al			;;; i29
;
; [533] LOOP																	' LOOP UNTIL (stopIt) in using9.x
do.loop.0041.xformat:
	jmp	do.0041.xformat			;;; i222
end.do.0041.xformat:
;
; [534] '
;
; [535] IF stopIt AND (fmtDigCtr < numShift) AND (expCtr == 0) THEN		' added significant digit
	mov	eax,d[ebp-268]			;;; i665
	mov	ebx,d[ebp-68]			;;; i665
	cmp	eax,ebx			;;; i684a
	mov	eax,0			;;; i466
	jge	> A.50			;;; i467
	not	eax			;;; i468
A.50:
	mov	ebx,d[ebp-276]			;;; i665
	and	eax,ebx			;;; i769
	mov	ebx,d[ebp-116]			;;; i665
	cmp	ebx,0			;;; i684a
	mov	ebx,0			;;; i466
	jne	> A.51			;;; i467
	not	ebx			;;; i468
A.51:
	and	eax,ebx			;;; i769
	test	eax,eax			;;; i220
	jz	>> else.0043.xformat			;;; i221
;
; [536] INC argMSDOrder
	inc	d[ebp-80]			;;; i84
;
; [537] DEC numShift
	dec	d[ebp-68]			;;; i84
;
; [538] END IF
else.0043.xformat:
end.if.0043.xformat:
;
; [539] '
;
; [540] IF !stopIt THEN																' ran out of format digits
	mov	eax,d[ebp-276]			;;; i665
	neg	eax			;;; i888
	cmc				;;; i889
	rcr	eax,1			;;; i890
	sar	eax,31			;;; i891
	test	eax,eax			;;; i220
	jz	>> else.0044.xformat			;;; i221
;
; [541] IFZ expCtr THEN
	mov	eax,d[ebp-116]			;;; i665
	test	eax,eax			;;; i194
	jnz	>> else.0045.xformat			;;; i195
;
; [542] argStr$ = "1" + argStr$
	mov	eax,addr @_string.00AC.xformat			;;; i663
	mov	ebx,[ebp-60]			;;; i665
	call	%_concat.ubyte.a0.eq.a0.plus.a1.vv			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [543] ELSE
	jmp	end.if.0045.xformat			;;; i107
else.0045.xformat:
;
; [544] argStr${0} = '1'
	mov	eax,49			;;; i659
	mov	ecx,d[ebp-60]			;;; i665
	lea	ebx,[ecx]			;;; i464
	mov	b[ebx],al			;;; i29
;
; [545] END IF
end.if.0045.xformat:
;
; [546] INC argMSDOrder
	inc	d[ebp-80]			;;; i84
;
; [547] DEC numShift
	dec	d[ebp-68]			;;; i84
;
; [548] END IF
else.0044.xformat:
end.if.0044.xformat:
;
; [549] END IF																					' rndDig >= '5'
else.0040.xformat:
end.if.0040.xformat:
;
; [550] ELSE																							' lenArg <= fmtDigCtr
	jmp	end.if.003F.xformat			;;; i107
else.003F.xformat:
;
; [551] argStr$ = argStr$ + CHR$ ('0', fmtDigCtr - lenArg)
	sub	esp,64			;;; i487
	mov	eax,48			;;; i659
	mov	d[esp],eax			;;; i887
	mov	eax,d[ebp-268]			;;; i665
	mov	ebx,d[ebp-52]			;;; i665
	sub	eax,ebx			;;; i791
	mov	d[esp+4],eax			;;; i887
	call	%_chr.d			;;; i575
	add	esp,64			;;; i600
	mov	ebx,[ebp-60]			;;; i665
	call	%_concat.ubyte.a0.eq.a1.plus.a0.vs			;;; i782
	lea	ebx,[ebp-60]			;;; i5
	mov	esi,d[ebx]			;;; i6a
	mov	d[ebx],eax			;;; i6b
	call	%____free			;;; i6c
;
; [552] END IF
end.if.003F.xformat:
;
; [553] END SUB
end.sub3.3.xformat:
	ret				;;; i127
out.sub3.3.xformat:
;
; [554] '
;
; [555] eeeQuitFormat:
%g%eeeQuitFormat%3:
;
; [556] lastErr = ERROR ($$ErrorNatureInvalidArgument)
	sub	esp,64			;;; i487
	mov	eax,57			;;; i659
	call	%_error
	add	esp,64			;;; i600
	mov	d[ebp-284],eax			;;; i670
;
; [557] '	PRINT "e<" + resultString$ + "> " + STRING$(LEN(resultString$))
;
; [558] RETURN (resultString$)
	mov	eax,[ebp-36]			;;; i665
	xor	esi,esi			;;; i869
	mov	d[ebp-36],esi			;;; i670
	jmp	end.func3.xformat			;;; i258
;
; [561] END FUNCTION
	xor	eax,eax			;;; i862
end.XxxFormat$.xformat:  ;;; Function end label for Assembly Programmers.
end.func3.xformat:
	xor	ebx,ebx			;;; i422
	mov	esi,[ebp-36]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-36],ebx			;;; i670
	mov	esi,[ebp-136]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-136],ebx			;;; i670
	mov	esi,[ebp-212]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-212],ebx			;;; i670
	mov	esi,[ebp-24]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-24],ebx			;;; i670
	mov	esi,[ebp-60]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-60],ebx			;;; i670
	mov	esi,[ebp-132]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-132],ebx			;;; i670
	mov	esi,[ebp-176]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-176],ebx			;;; i670
	mov	esi,[ebp-140]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-140],ebx			;;; i670
	mov	esi,[ebp-144]			;;; i665
	call	%____free			;;; i423
	mov	d[ebp-144],ebx			;;; i670
	lea	esp,[ebp-20]				;;; i110
	pop	ebx				;;; restore ebx
	pop	edi				;;; restore edi
	pop	esi				;;; restore esi
	leave					;;; replaces "mov esp,ebp", "pop ebp"
	ret	16			;;; i111a
;  *****
;  *****  END FUNCTION  XxxFormat$ ()  *****
;  *****
;
; [562] '
;
; [563] '
;
; [564] ' ######################
;
; [565] ' #####  Entry ()  #####
;
; [566] ' ######################
;
; [567] '
;
; [568] FUNCTION  XFormat ()
.code
%_StartLibrary_xformat:
	call	func1.xformat			;;; i162c
	ret	0			;;; i162d
_XFormat.xformat@0:
;  *****
;  *****  FUNCTION  XFormat ()  *****
;  *****
func1.xformat:
	push	ebp			;;; i112
	mov	ebp,esp		;;; i113
	sub	esp,8			;;; i114
	push	esi			;;; save esi
	push	edi			;;; save edi
	push	ebx			;;; save ebx
	call	%%%%initOnce.xformat
funcBody1.xformat:
;
; [570] END FUNCTION
	xor	eax,eax			;;; i862
end.XFormat.xformat:  ;;; Function end label for Assembly Programmers.
end.func1.xformat:
	lea	esp,[ebp-20]				;;; i110
	pop	ebx				;;; restore ebx
	pop	edi				;;; restore edi
	pop	esi				;;; restore esi
	leave					;;; replaces "mov esp,ebp", "pop ebp"
	ret						;;; i111d
;  *****
;  *****  END FUNCTION  XFormat ()  *****
;  *****
%%%%initOnce.xformat:
	cmp d[%%%entered.xformat],-1		;;; i117
	jne > A.57	;;; i117a
	ret			;;; i117b
A.57:
	call	PrologCode.xformat			;;; i118a
	lea esi,%_begin_external_data_xformat
	lea edi,%_end_external_data_xformat
	call %_ZeroMemory
	call	InitSharedComposites.xformat			;;; i119
	mov	d[%%%entered.xformat],-1
	ret				;;; i120
data section 'xformat$internals'
align	8
%%%entered.xformat:
db 8 dup 0
.code
;
; [571] END PROGRAM
end_program.xformat:
	push	ebp			;;; i128
	mov	ebp,esp			;;; i129
	sub	esp,128			;;; i130
	xor	ebx,ebx			;;; i422
	mov	esi,d[%%3%%fmtBegin.xformat]			;;; i663a
	call	%_FreeArray			;;; i424
	mov	d[%%3%%fmtBegin.xformat],ebx			;;; i668
	mov	esi,d[%%3%%fmtLevel.xformat]			;;; i663a
	call	%_FreeArray			;;; i424
	mov	d[%%3%%fmtLevel.xformat],ebx			;;; i668
	mov	esp,ebp			;;; i132
	pop	ebp			;;; i133
	ret				;;; i134
InitSharedComposites.xformat:
	ret				;;; i143
;;;  *****  DEFINE '.bss' SECTION LIMITS  *****
;
align 8
data section 'xformat$aaaaa'
%_begin_external_data_xformat dd ?
;
align 8
data section 'xformat$zzzzz'
%_end_external_data_xformat dd ?
;
;
;;;  *****  DEFINE LITERAL STRINGS  *****
.const
align 8
;
dd	24,0, 7,0x80130001
@_string.0029.xformat:
db	"xformat"
db	1 dup 0
;
dd	24,0, 6,0x80130001
@_string.002A.xformat:
db	"0.0001"
db	2 dup 0
;
dd	24,0, 3,0x80130001
@_string.002B.xformat:
db	"xst"
db	5 dup 0
;
dd	64,0, 43,0x80130001
@_string.006E.xformat:
db	"FORMAT$() : error : (numeric data with '&')"
db	5 dup 0
;
dd	24,0, 1,0x80130001
@_string.006F.xformat:
db	"$"
db	7 dup 0
;
dd	48,0, 28,0x80130001
@_string.0070.xformat:
db	"FORMAT$() : error : (leading"
db	4 dup 0
;
dd	32,0, 8,0x80130001
@_string.0071.xformat:
db	"excludes"
db	8 dup 0
;
dd	24,0, 1,0x80130001
@_string.0072.xformat:
db	")"
db	7 dup 0
;
dd	80,0, 59,0x80130001
@_string.0076.xformat:
db	"FORMAT$() : error : (can't print number with string format)"
db	5 dup 0
;
dd	24,0, 1,0x80130001
@_string.007B.xformat:
db	"("
db	7 dup 0
;
dd	64,0, 41,0x80130001
@_string.007C.xformat:
db	"FORMAT$() : error : (no printable digits)"
db	7 dup 0
;
dd	56,0, 37,0x80130001
@_string.007D.xformat:
db	"FORMAT$() : error : (string argument)"
db	3 dup 0
;
dd	24,0, 2,0x80130001
@_string.0084.xformat:
db	"de"
db	6 dup 0
;
dd	24,0, 1,0x80130001
@_string.008C.xformat:
db	"."
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.0091.xformat:
db	"%"
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.0095.xformat:
db	"E"
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.0096.xformat:
db	"-"
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.0097.xformat:
db	"+"
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.0098.xformat:
db	" "
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.00A5.xformat:
db	","
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.00AC.xformat:
db	"1"
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.00BB.xformat:
db	0x5C
db	7 dup 0
;
dd	24,0, 1,0x80130001
@_string.00C1.xformat:
db	";"
db	7 dup 0
;
dd	32,0, 15,0x80130001
@_string.StartLibrary.xformat:
db	"%_StartLibrary_"
db	1 dup 0
