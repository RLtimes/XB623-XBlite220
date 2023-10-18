'
'
' ####################
' #####  PROLOG  #####
' ####################
'
'MAKEFILE "makexformat.mak"

PROGRAM	"xformat"
VERSION	"0.0001"
'
	IMPORT	"xst"   ' Standard library : required by most programs
'
DECLARE FUNCTION  XFormat ()
EXPORT
DECLARE FUNCTION  ValidFormat (format$, validPtr)
DECLARE FUNCTION  XxxFormat$ (format$, argType, arg$$)

END EXPORT
'
'
' ############################
' #####  ValidFormat ()  #####
' ############################
'
FUNCTION  ValidFormat (format$, validPtr)
	STATIC	UBYTE  fmtSeq[]
'
	IFZ fmtSeq[] THEN GOSUB Initialize
	IFZ format$ THEN RETURN ($$FALSE)
	valid = $$FALSE
'
' format is invalid if not part of ascending value sequence
' (else) format is valid if the next format character can become a digit
'
	DO
		now = format${validPtr}
		nxt = format${validPtr+1}
		IF (fmtSeq[now] >= fmtSeq[nxt]) THEN valid = $$FALSE : EXIT DO
		IF ((nxt = '*') OR (nxt = '#') OR (nxt = ',')) THEN valid = $$TRUE : EXIT DO
		INC validPtr
	LOOP
	RETURN (valid)
'
' *****  Initialize  *****
'
SUB Initialize
	DIM fmtSeq[255]
	fmtSeq['+'] =  40
	fmtSeq['-'] =  40
	fmtSeq['('] =  40
	fmtSeq['*'] =  50
	fmtSeq['$'] =  60
	fmtSeq[','] =  80
	fmtSeq['.'] =  90
	fmtSeq['#'] = 100
END SUB

END FUNCTION
'
'
' ###########################
' #####  XxxFormat$ ()  #####
' ###########################
'
FUNCTION  XxxFormat$ (format$, argType, arg$$)

	STATIC	UBYTE  fmtLevel[]
	STATIC	UBYTE  fmtBegin[]
'
'	PRINT "FORMAT$() : <"; format$; "> <"; STRING$(argType); "> <"; STRING$(arg$$); ">"
'
	IFZ fmtLevel[] THEN GOSUB Initialize
	IFZ format$ THEN RETURN 										' empty format string
'
	IF (argType = $$STRING) THEN arg$ = CSTRING$(GLOW(arg$$))
'
	fmtStrPtr = 1
	lenFmtStr = LEN (format$)
	GOSUB StringString													'	top StringString call
'
	IFZ fmtStrPtr THEN
'		PRINT "a<" + resultString$ + "> " + STRING$(LEN(resultString$))
		RETURN (resultString$)
	END IF
'
' initialize argument counters, flags, etc.
'
	argH	= 0
	argL	= 0
	arg&&	= 0
	lenArg = 0
	negArg = 0
	argStr$	= ""
	argDPLoc = 0
	numShift = 0
	argExpIx = 0
	argExpVal = 0
	argMSDOrder	= 0
'
' initialize format counters, flags, etc.
'
	fmtChar = 0
	lastChar = 0
	nextChar = 0
	levelNow = 0
	levelNext = 0
	nPlaces = 0
	preDec = 0
	postDec = 0
	expCtr = 0
	hasDec = 0
	commaFlag = 0
	padFlag = 0
	dollarSign$ = ""
	leadSign$ = ""
	trailSign$ = ""
	errSign$ = ""
'
' Format argument and add it to the result loop
'
	DO
		lastChar = fmtChar
		fmtChar = format${fmtStrPtr-1}
'
		IFZ ((fmtChar = '#') AND ((lastChar = ',') OR (lastChar = '.') OR (lastChar = '#'))) THEN
				levelNow  = fmtLevel[fmtChar]
		END IF
'
		IF (fmtStrPtr = lenFmtStr) THEN							' check for end of fmt string
			nextChar = 'A'														'   set bogus next char
		ELSE
			nextChar  = format${fmtStrPtr}					'   get real next char
		END IF
'
		IF ((nextChar = '#') AND ((fmtChar = ',') OR (fmtChar = '.') OR (fmtChar = '#'))) THEN
			levelNext = levelNow
		ELSE
			levelNext = fmtLevel[nextChar]
		END IF
'
' Unformatted string "format"
'
		IF (fmtChar = '&') THEN
			IF (argType != $$STRING) THEN
				PRINT "FORMAT$() : error : (numeric data with '&')"
				GOTO eeeQuitFormat
			END IF
			resultString$ = resultString$ + arg$
			INC fmtStrPtr
			EXIT DO
		END IF
		INC nPlaces
'
		SELECT CASE fmtChar
			CASE '$': dollarSign$ = "$"
			CASE ',':	commaFlag = $$TRUE
								INC preDec
			CASE '*': padFlag = $$TRUE
								INC preDec
			CASE '.': hasDec = 1
			CASE '#': IF hasDec THEN
									INC postDec
								ELSE
									INC preDec
								END IF
			CASE '-': INC preDec						' sign can only be leading here.
			CASE '+', '('
								IFZ leadSign$ THEN
									leadSign$ = CHR$ (fmtChar)
								ELSE
									PRINT "FORMAT$() : error : (leading"; leadSign$; "excludes"; CHR$ (fmtChar); ")"
									GOTO eeeQuitFormat
								END IF
		END SELECT
'
' case < or | or >:		all we needed to do is count them
' End of char fmt:		add to resultString$, and exit loop
'
		IF (((fmtChar = '<') OR (fmtChar = '|') OR (fmtChar = '>')) AND (nextChar != fmtChar)) THEN
			IF (argType != $$STRING) THEN
				PRINT "FORMAT$() : error : (can't print number with string format)"
				GOTO eeeQuitFormat
			END IF
			SELECT CASE fmtChar
				CASE '<': resultString$ = resultString$ + LJUST$(arg$, nPlaces)
				CASE '|': resultString$ = resultString$ + CJUST$(arg$, nPlaces)
				CASE '>': resultString$ = resultString$ + RJUST$(arg$, nPlaces)
			END SELECT
			INC fmtStrPtr
			EXIT DO
		END IF
'
' SPECIAL TRAILING NUMERIC FMT INFO
'
' get exponent: !! new nextChar$ if legit exponent !!
'
		IF (nextChar = '^') THEN
			DO																				' count ^s
				INC expCtr
				IF (format${fmtStrPtr + expCtr} != '^') THEN EXIT DO
			LOOP UNTIL (expCtr = 5)
'
			IF (expCtr >= 4) THEN											' legitimate exponent
				nPlaces    = nPlaces    + expCtr
				fmtStrPtr  = fmtStrPtr  + expCtr
				nextChar   = format${fmtStrPtr}					' to look for trailing +, -, )
			ELSE
				expCtr = 0															' reset if not valid exponent
			END IF
		END IF
'
' look for trailing + or - in nextChar here. add flags
'
		IF (((nextChar = '-') OR (nextChar = '+')) AND (leadSign$ = "")) THEN
			trailSign$ = CHR$ (nextChar)
'
' incr ptrs: trailing sign picked up (but don't leave loop yet).
'
			levelNext = 0
			INC nPlaces
			INC fmtStrPtr
		END IF
'
' get closing parenthesis; legit only if opening parenthesis has been set.
'
		IF ((nextChar = ')') AND (leadSign$ = "(")) THEN
			trailSign$ = CHR$ (nextChar)
			INC nPlaces
			INC fmtStrPtr
		END IF
'
' a second '.' means the beginning of a new fmt.
'
		IF (hasDec AND (nextChar = '.')) THEN levelNext = 0
'
' End of num fmt: validate fmt, add to resultString$ and exit loop.
'
		IF (levelNext < levelNow) THEN
			IFZ (preDec + postDec) THEN
				PRINT "FORMAT$() : error : (no printable digits)"
				GOTO eeeQuitFormat
			END IF
'
' missing close parenthesis: treat open paren as fixed.
'
			IF ((leadSign$ = "(") AND (trailSign$ != ")")) THEN
				resultString$ = resultString$ + "("
				leadSign$ = ""
				DEC nPlaces
			END IF
'
' Get argument
'
			IF (argType = $$STRING) THEN
				PRINT "FORMAT$() : error : (string argument)"
				GOTO eeeQuitFormat
			END IF
'
			argH  = GHIGH(arg$$)
			argL  = GLOW (arg$$)
			arg&& = GLOW (arg$$)				' type casts XLONG as ULONG
			arg		= GLOW (arg$$)
'
			SELECT CASE argType
				CASE $$DOUBLE	: argStr$ = STR$ (DMAKE(argH, argL))
				CASE $$SINGLE	: argStr$ = STR$ (SMAKE(argL))
				CASE $$GIANT	: argStr$ = STR$ (arg$$)
				CASE $$ULONG	: argStr$ = STR$ (arg&&)
				CASE ELSE			: argStr$ = STR$ (arg)
			END SELECT
'
' decompose argument string: sign, exponent, length and DP location
'
' get sign: the 1st column of argStr$ will always be '-' or ' '.
'
			negArg = argStr${0}
			argStr$ = MID$(argStr$, 2)
'
' remove any exponent from argStr$. argExpVal is its numeric value.
'
			argExpIx = INCHR(argStr$, "de")
			argExpVal = 0
			IF (argExpIx > 0) THEN

'				argExpVal = XLONG (MID$(argStr$, argExpIx + 1))

' ok, trying to eliminate the use of above XLONG intrinsic in Xst library
				expVal$ = MID$(argStr$, argExpIx + 1)
				specType = XstStringToNumber (@expVal$, 0, @after, @rtype, @value$$)
				SELECT CASE rtype
					CASE $$SLONG : argExpVal = GLOW(value$$)
					CASE $$XLONG : argExpVal = value$$
				END SELECT
' end of substitution

				argStr$ = LEFT$ (argStr$, argExpIx - 1)
			END IF
'
' length of argument string after sign, exponent and DP are removed
'
			lenArg = LEN (argStr$)
'
' get argument decimal point location. Remove it from argStr and
'		deincrement lenArg if needed.
'
			argDPLoc = INSTR (argStr$, ".")
			IFZ argDPLoc THEN
				argDPLoc = lenArg + 1
			ELSE
				argStr$ = LEFT$(argStr$, argDPLoc -1) + MID$(argStr$, argDPLoc +1)
				DEC lenArg
			END IF
'
			k = 0
			DO WHILE argStr${k} = '0'
				DEC argExpVal
				INC k
			LOOP
			argStr$ = MID$(argStr$, k+1)
			lenArg = lenArg - k
'
' argMSDOrder, if pos, is the exponent of the most significant digit.
'		if neg, it is one less than the exponent.
'
			argMSDOrder = argDPLoc - 1 + argExpVal
'
' numShift is the power of 10 difference between the MSD of the format
'		and the MSD of the argument
'
			numShift = preDec - argMSDOrder
'
' put numeric argument string and format together
'
			IFZ expCtr THEN											' formats without an exponent
				IF (numShift > 0) THEN
					argStr$ = CHR$ ('0', numShift) + argStr$
					lenArg = lenArg + numShift
				END IF
				GOSUB Rounder
'
' restore DP and add commas
'
				IF hasDec THEN
					IF (preDec > argMSDOrder) THEN
						argStr$ = LEFT$(argStr$, preDec) + "." + MID$(argStr$, preDec +1)
						comIx = preDec
					ELSE
						argStr$ = LEFT$(argStr$, argMSDOrder) + "." + MID$(argStr$, argMSDOrder +1)
						comIx = argMSDOrder
					END IF
				ELSE												' no decimal place
					IF (preDec > argMSDOrder) THEN
						comIx = preDec
					ELSE
						comIx = argMSDOrder
					END IF
				END IF
'
				IF (commaFlag AND (argMSDOrder > 3)) THEN GOSUB AddCommas
'
' strip off any leading 0s before DP
'
				IF ((argMSDOrder < preDec) AND (preDec > 0)) THEN
					IF (argMSDOrder <= 1) THEN
						argStr$ = MID$(argStr$, preDec)
					ELSE
						argStr$ = MID$(argStr$, preDec - argMSDOrder + 1)
					END IF
				END IF
'
' if not enough digits in format then set mess up formatting flag
'
				IF (LEN(argStr$) > (preDec + postDec + hasDec)) THEN errSign$ = "%"
			ELSE										' formats with exponent
				GOSUB Rounder					' round off significant digits
'
' restore DP
'
				IF hasDec THEN argStr$ = LEFT$(argStr$, preDec) + "." + MID$(argStr$, preDec +1)
'
' get exponent in usable form
'
				expString$ = STR$ (numShift * -1)
				IF (expString${0} = ' ') THEN expString${0} = '+'
				expLen = LEN (expString$)
				DEC expCtr
'
				SELECT CASE TRUE
					CASE (expLen < expCtr)
								expString$ = LEFT$ (expString$, 1) + CHR$ ('0', expCtr - expLen) + MID$ (expString$, 2)
					CASE (expLen > expCtr)
								errSign$ = "%"
				END SELECT
				argStr$ = argStr$ + "E" + expString$
			END IF
'
' take care of leading and trailing sign stuff
'
			IF (negArg = '-') THEN
				SELECT CASE TRUE
					CASE (leadSign$ = "") AND (trailSign$ = ""):	leadSign$  = "-"
					CASE (leadSign$ = "+"):												leadSign$  = "-"
					CASE (trailSign$ = "+"):											trailSign$ = "-"
				END SELECT
			ELSE
				SELECT CASE TRUE
					CASE (leadSign$ = "(") AND (trailSign$ = ")")
								leadSign$ = " "
								trailSign$ = " "
					CASE trailSign$ = "-"
								trailSign$ = " "
				END SELECT
			END IF
'
' add signs and padding as necessary
'
			argStr$ = leadSign$ + dollarSign$ + argStr$ + trailSign$
			padLen  = nPlaces - LEN(argStr$)
			IF (padLen > 0) THEN
				IF padFlag THEN
					argStr$ = CHR$ ('*', padLen) + argStr$
				ELSE
					argStr$ = CHR$ (' ', padLen) + argStr$
				END IF
			END IF
			resultString$ = resultString$ + errSign$ + argStr$
			INC fmtStrPtr
			EXIT DO
		END IF
		INC fmtStrPtr							' incremented when looping through fmt chars
	LOOP
	GOSUB StringString					' get trailing constant string, if any
'
' reset fmt string ptrs to cycle through again as necessary
'
	IF ((fmtStrPtr = 0) AND (argIx < nArg-1)) THEN
		fmtStrPtr = 1
		GOSUB StringString
	END IF
'	PRINT "b<" + resultString$ + "> " + STRING$(LEN(resultString$))
	RETURN (resultString$)
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM fmtLevel[255]		' initialize format character priority level arrays
	DIM fmtBegin[255]
'
' All format characters are listed in fmtLevel.
' The fmtBegin array is used to determine the legitimacy of formats
' that cannot stand alone. These formats require a sequence of characters
' to establish their legitimacy.
' The lower the format level value, the higher the priority, so the
' characters not given a priority level here default to fmtlevel[] = 0,
' and therefore the highest priority. The lowest priority = 255.
'
	fmtLevel['&'] =  20
	fmtLevel['<'] =  30
	fmtLevel['|'] =  30
	fmtLevel['>'] =  30
	fmtLevel['+'] =  40:	fmtBegin['+'] =  40
	fmtLevel['-'] =  40:	fmtBegin['-'] =  40
	fmtLevel['('] =  40:	fmtBegin['('] =  40
	fmtLevel['*'] =  50:	fmtBegin['*'] =  50
	fmtLevel['$'] =  60:	fmtBegin['$'] =  60
	fmtLevel['#'] =  70
	fmtLevel[','] =  80:	fmtBegin[','] =  80
	fmtLevel['.'] =  90:	fmtBegin['.'] =  90
'
'	fmtLevel['^'] =   0		' When these two are format characters, they will be
'	fmtLevel[')'] =   0		' picked up by checking nextChar (just like trailing
'													' signs).
END SUB
'
' *****  StringString  *****
'
SUB StringString
	DO
		fmtThisPtr = fmtStrPtr - 1
		q = format${fmtThisPtr}
		qq = fmtBegin[q]
		qqq = fmtLevel[q]
		IFZ q THEN EXIT DO
		r = format${fmtStrPtr}
		SELECT CASE TRUE
			CASE (q = '_')	: INC fmtStrPtr: q = r
			CASE qq					: IF ValidFormat (format$, fmtThisPtr) THEN EXIT DO
			CASE qqq				: EXIT DO
		END SELECT
		resultString$ = resultString$ + CHR$ (q)
		INC fmtStrPtr
	LOOP
	IF (fmtStrPtr > lenFmtStr) THEN fmtStrPtr = 0
END SUB
'
' *****  AddCommas  *****
'
SUB AddCommas
	DO WHILE comIx > (preDec - argMSDOrder + 3)
		comIx = comIx - 3
		argStr$ = LEFT$(argStr$, comIx) + "," + MID$(argStr$, comIx+1)
		INC lenArg
	LOOP
END SUB
'
' *****  Rounder  *****
'
SUB Rounder
	IF ((expCtr = 0) AND (numShift < 0)) THEN		' no fmt exp & int(arg) > int(fmt)
		fmtDigCtr = argMSDOrder + postDec
	ELSE
		fmtDigCtr = preDec + postDec
	END IF
'
	IF (lenArg > fmtDigCtr) THEN
		rndDig  = argStr${fmtDigCtr}
		argStr$ = LEFT$(argStr$, fmtDigCtr)
'
		IF (rndDig >= '5') THEN
			stopIt = $$FALSE
			DO UNTIL stopIt OR (fmtDigCtr = 0)		' DO WHILE (fmtDigCtr) in using9.x
				DEC fmtDigCtr
				lastDig = argStr${fmtDigCtr}
				INC lastDig
				IF (lastDig = 0x3a) THEN
					lastDig = '0'											' 9 -> 0: keep rounding
				ELSE
					stopIt = $$TRUE										' no more rounding
				END IF
				argStr${fmtDigCtr} = lastDig
			LOOP																	' LOOP UNTIL (stopIt) in using9.x
'
			IF stopIt AND (fmtDigCtr < numShift) AND (expCtr == 0) THEN		' added significant digit
				INC argMSDOrder
				DEC numShift
			END IF
'
			IF !stopIt THEN																' ran out of format digits
				IFZ expCtr THEN
					argStr$ = "1" + argStr$
				ELSE
					argStr${0} = '1'
				END IF
				INC argMSDOrder
				DEC numShift
			END IF
		END IF																					' rndDig >= '5'
	ELSE																							' lenArg <= fmtDigCtr
		argStr$ = argStr$ + CHR$ ('0', fmtDigCtr - lenArg)
	END IF
END SUB
'
eeeQuitFormat:
	lastErr = ERROR ($$ErrorNatureInvalidArgument)
'	PRINT "e<" + resultString$ + "> " + STRING$(LEN(resultString$))
	RETURN (resultString$)


END FUNCTION
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  XFormat ()

END FUNCTION
END PROGRAM
