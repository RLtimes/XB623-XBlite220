'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  XBasic mathematics function library
'
' Xma is the XBasic mathematics function library.
' ---
' subject to LGPL license - see COPYING_LIB
' maxreason@maxreason.com
' for Windows XBasic/XBLite
' ---
' Note that this version of Xma is a separate
' function library, xma.dll. The names of the
' functions have all been changed to indicate
' that they are no longer built-in functions;
' e.g., Sin, Cos, Tan, Log, Log10, Sqrt...
'
' Version 0.0021  05 Jan 2006 DTS
' added Fmod and Fround functions
'
PROGRAM	"xma"
VERSION	"0.0021"
'
'
EXPORT
' 
' ###########################
' #####  xma functions  #####
' ###########################
'
' Angles are always in RADIANS
'
DECLARE  FUNCTION  Xma             ()
DECLARE  FUNCTION  XmaVersion$     ()  

DECLARE  FUNCTION  DOUBLE  Acos    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Acosh   (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Acot    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Acoth   (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Acsc    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Acsch   (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Asec    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Asech   (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Asin    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Asinh   (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Atanh   (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Cosh    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Cot     (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Coth    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Csc     (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Csch    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Log     (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Log10   (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Sec     (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Sech    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Sinh    (DOUBLE x)
DECLARE  FUNCTION  DOUBLE  Tanh    (DOUBLE x)

EXTERNAL FUNCTION  DOUBLE  Atan    (DOUBLE x)
EXTERNAL FUNCTION  DOUBLE  Cos     (DOUBLE x)
EXTERNAL FUNCTION  DOUBLE  Exp     (DOUBLE x)
EXTERNAL FUNCTION  DOUBLE  Exp2    (DOUBLE x)
EXTERNAL FUNCTION  DOUBLE  Exp10   (DOUBLE x)
EXTERNAL FUNCTION  DOUBLE  Power   (DOUBLE x, DOUBLE y)
EXTERNAL FUNCTION  DOUBLE  Sin     (DOUBLE x)
EXTERNAL FUNCTION  DOUBLE  Sqrt    (DOUBLE x)
EXTERNAL FUNCTION  DOUBLE  Tan     (DOUBLE x)

DECLARE  FUNCTION  DOUBLE  Fmod    (DOUBLE num1, DOUBLE num2)
DECLARE  FUNCTION  DOUBLE  Fround  (DOUBLE number, power)

'
END EXPORT
'
INTERNAL FUNCTION  DOUBLE  Asin0   (DOUBLE x)
INTERNAL FUNCTION  DOUBLE  Expmo   (DOUBLE x)
INTERNAL FUNCTION  DOUBLE  Log0    (DOUBLE x)
'
' for xma:
'
EXTERNAL FUNCTION  XxxFSTCW ()
EXTERNAL FUNCTION  XxxFSTSW ()
'
EXTERNAL FUNCTION  DOUBLE  XxxF2XM1   (x#)
EXTERNAL FUNCTION  DOUBLE  XxxFABS    (x#)
EXTERNAL FUNCTION  DOUBLE  XxxFCHS    (x#)
EXTERNAL FUNCTION  DOUBLE  XxxFCOS    (x#)
EXTERNAL FUNCTION  DOUBLE  XxxFLDZ    ()
EXTERNAL FUNCTION  DOUBLE  XxxFLD1    ()
EXTERNAL FUNCTION  DOUBLE  XxxFLDPI   ()
EXTERNAL FUNCTION  DOUBLE  XxxFLDL2E  ()
EXTERNAL FUNCTION  DOUBLE  XxxFLDL2T  ()
EXTERNAL FUNCTION  DOUBLE  XxxFLDLG2  ()
EXTERNAL FUNCTION  DOUBLE  XxxFLDLN2  ()
EXTERNAL FUNCTION  DOUBLE  XxxFPATAN  (x#, @y#)
EXTERNAL FUNCTION  DOUBLE  XxxFPREM   (x#, @y#)
EXTERNAL FUNCTION  DOUBLE  XxxFPREM1  (x#, @y#)
EXTERNAL FUNCTION  DOUBLE  XxxFPTAN   (x#, @y#)
EXTERNAL FUNCTION  DOUBLE  XxxFRNDINT (x#)
EXTERNAL FUNCTION  DOUBLE  XxxFSCALE  (x#, y#)
EXTERNAL FUNCTION  DOUBLE  XxxFSIN    (x#)
EXTERNAL FUNCTION  DOUBLE  XxxFSINCOS (x#, @y#)
EXTERNAL FUNCTION  DOUBLE  XxxFSQRT   (x#)
EXTERNAL FUNCTION  DOUBLE  XxxFXTRACT (x#, @y#)
EXTERNAL FUNCTION  DOUBLE  XxxFYL2X   (x#, @y#)
EXTERNAL FUNCTION  DOUBLE  XxxFYL2XP1 (x#, @y#)
'
EXPORT
'
' ###########################
' #####  xma constants  #####
' ###########################
'
	$$NNAN			=	0dFFFFFFFFFFFFFFFF
	$$PNAN			= 0d7FFFFFFFFFFFFFFF
	$$NINF			= 0dFFF0000000000000
	$$PINF			= 0d7FF0000000000000
	$$RADIANS		= 1
	$$DEGREES		= 2
	$$DEGTORAD	= 0d3F91DF46A2529D39
	$$RADTODEG	= 0d404CA5DC1A63C1F8
	$$PI				= 0d400921FB54442D18
	$$TWOPI			= 0d401921FB54442D18
	$$PI3DIV2		= 0d4012D97C7F3321D2
	$$PIDIV2		= 0d3FF921FB54442D18
	$$PIDIV4		= 0d3FE921FB54442D18
	$$INVPI			= 0d3FD45F306DC9C883
	$$SQRT2			= 0d3FF6A09E667F3BCD
	$$SQRT2DIV2	= 0d3FE6A09E667F3BCD
	$$INVSQRT2	= 0d3FE6A09E667F3BCD
	$$E					= 0d4005BF0A8B145769
	$$LOG2E			= 0d3FF71547652B82FE
	$$LOG210		= 0d400A934F0979A371
	$$LOGE2			= 0d3FE62E42FEFA39EF
	$$LOGE10 		= 0d40026BB1BBB55516
	$$LOGESQRT2	= 0d3FD62E42FEFA39EF
	$$LOG102		= 0d3FD34413509F79FF
	$$LOG10E		= 0d3FDBCB7B1526E50E
	$$PIDIV8		= 0d3FD921FB54442D18
	$$PI3DIV8		= 0d3FF2D97C7F3321D2
END EXPORT

$$XmaErrorNatureInvalidArgument     = 57
'
'
' ####################
' #####  Xma ()  #####
' ####################
'
FUNCTION  Xma ()

	IF LIBRARY(0) THEN RETURN
'
'	a$ = "Max Reason"
'	a$ = "copyright 1988-2000"
'	a$ = "XBasic mathematics function library"
'	a$ = "maxreason@maxreason.com"
'	a$ = ""
'
'
' the following doesn't work unless the answer is less than 2
' because the stupid f2xm1 opcode only works if -1 <= x <= +1.
'
'	FOR x# = .01# TO 2# STEP .125#
'		asw = XxxFSTSW ()
'		acw = XxxFSTCW ()
'		a# = EXP (x#)
'		i# = XxxFETOX (x#)
'		zsw = XxxFSTSW ()
'		PRINT FORMAT$("###.###########",x#);;; FORMAT$("###.###########",a#);; FORMAT$("###.###########",i#);; HEX$(asw>>11,1);; HEX$(zsw>>11,1);; HEX$(acw,4)
'	NEXT x#
'	PRINT
'
' the following doesn't work unless the answer is less than 2
' because the stupid f2xm1 opcode only works if -1 <= x <= +1.
'
'
'	FOR x# = .01# TO 2# STEP .125#
'		asw = XxxFSTSW ()
'		b# = 10# ** x#
'		j# = XxxFTENTOX (x#)
'		zsw = XxxFSTSW ()
'		PRINT FORMAT$("###.###########",x#);;; FORMAT$("###.###########",b#);; FORMAT$("###.###########",j#);; HEX$(asw>>11,1);; HEX$(zsw>>11,1)
'	NEXT x#
'	PRINT
'
' the following doesn't work unless the answer is less than 2
' because the stupid f2xm1 opcode only works if -1 <= x <= +1.
'
'
'	FOR x# = .1# TO 2.0001# STEP .02978#
'		asw = XxxFSTSW ()
'		c# = x# ** x#
'		k# = XxxFYTOX (x#, x#)
'		c$$ = GIANTAT (&c#)
'		x$$ = GIANTAT (&x#)
'		k$$ = GIANTAT (&k#)
'		zsw = XxxFSTSW ()
'		PRINT FORMAT$("###.###########",x#);;; FORMAT$("###.###########",c#);; FORMAT$("###.###########",k#);; HEX$(x$$,16);; HEX$(c$$,16);; HEX$(k$$,16);;; HEX$(asw>>11,1);; HEX$(zsw>>11,1)
'	NEXT x#
'	PRINT
'	RETURN
'
'
' test math library against pentium instructions
'
' test constants
'
'	GOSUB TestFLDZ
'	GOSUB TestFLD1
'	GOSUB TestFLDPI
'	GOSUB TestFLDL2E
'	GOSUB TestFLDL2T
'	GOSUB TestFLDLG2
'	GOSUB TestFLDLN2
'
' test functions
'
'	GOSUB TestF2XM1
'	GOSUB TestFABS
'	GOSUB TestFCHS
'	GOSUB TestFCOS
'	GOSUB TestFPATAN
'	GOSUB TestFPREM
'	GOSUB TestFPREM1
'	GOSUB TestFPTAN
'	GOSUB TestFRNDINT
'	GOSUB TestFSCALE
'	GOSUB TestFSIN
'	GOSUB TestFSINCOS
'	GOSUB TestFSQRT
'	GOSUB TestFXTRACT
'	GOSUB TestFYL2X
'	GOSUB TestFYL2XP1
'
'
'
	RETURN
'
'
'
' *****  test subroutines  *****
'
' 0# vs XxxFLDZ
'
'SUB TestFLDZ
'	a# = 0#
'	b# = XxxFLDZ ()
'	a$$ = GIANTAT(&a#)
'	b$$ = GIANTAT(&b#)
'	PRINT HEX$(a$$,16);; HEX$(b$$,16)
'END SUB
'
' 1# vs XxxFLD1
'
'SUB TestFLD1
'	a# = 1#
'	b# = XxxFLD1 ()
'	a$$ = GIANTAT(&a#)
'	b$$ = GIANTAT(&b#)
'	PRINT HEX$(a$$,16);; HEX$(b$$,16)
'END SUB
'
' $$PI vs XxxFLDPI
'
'SUB TestFLDPI
'	a# = $$PI
'	b# = XxxFLDPI ()
'	a$$ = GIANTAT(&a#)
'	b$$ = GIANTAT(&b#)
'	PRINT HEX$(a$$,16);; HEX$(b$$,16)
'END SUB
'
' $$LOG2E vs XxxFLDL2E
'
'SUB TestFLDL2E
'	a# = $$LOG2E
'	b# = XxxFLDL2E ()
'	a$$ = GIANTAT(&a#)
'	b$$ = GIANTAT(&b#)
'	PRINT HEX$(a$$,16);; HEX$(b$$,16)
'END SUB
'
' $$LOG210 vs XxxFLDL2T
'
'SUB TestFLDL2T
'	a# = $$LOG210
'	b# = XxxFLDL2T ()
'	a$$ = GIANTAT(&a#)
'	b$$ = GIANTAT(&b#)
'	PRINT HEX$(a$$,16);; HEX$(b$$,16)
'END SUB
'
' $$LOG102 vs XxxFLDLG2
'
'SUB TestFLDLG2
'	a# = $$LOG102
'	b# = XxxFLDLG2 ()
'	a$$ = GIANTAT(&a#)
'	b$$ = GIANTAT(&b#)
'	PRINT HEX$(a$$,16);; HEX$(b$$,16)
'END SUB
'
' $$LOGE2 vs XxxFLDLN2
'
'SUB TestFLDLN2
'	a# = $$LOGE2
'	b# = XxxFLDLN2 ()
'	a$$ = GIANTAT(&a#)
'	b$$ = GIANTAT(&b#)
'	PRINT HEX$(a$$,16);; HEX$(b$$,16)
'END SUB
'
' (2# ** x# - 1#) vs XxxF2XM1
'
'SUB TestF2XM1
'	FOR i# = -1# TO +1# STEP 1# / 64#
'		x# = 2# ** i# - 1#
'		y# = XxxF2XM1 (i#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' ABS() vs XxxFABS
'
'SUB TestFABS
'	FOR i# = -$$TWOPI TO $$TWOPI STEP $$TWOPI / 64#
'		x# = ABS (i#)
'		y# = XxxFABS (i#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#/$$PIDIV2);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' - vs XxxFCHS
'
'SUB TestFCHS
'	FOR i# = -$$TWOPI TO $$TWOPI STEP $$TWOPI / 64#
'		x# = -i#
'		y# = XxxFCHS (i#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#/$$PIDIV2);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' COS() vs XxxFCOS
'
'SUB TestFCOS
'	FOR i# = 0 TO $$TWOPI * 2# STEP $$TWOPI / 64#
'		x# = COS (i#)
'		y# = XxxFCOS (i#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#/$$PIDIV2);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' ATAN() vs XxxFPATAN
'
'SUB TestFPATAN
'	FOR i# = 0# TO $$TWOPI * 2# STEP $$TWOPI / 64#
'		x# = ATAN (i#)
'		y# = XxxFPATAN (i#, 1#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#/$$PIDIV2);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' XxxFPREM
'
'SUB TestFPREM
'	FOR i# = 10# TO 14# STEP .5#
'		FOR j# = -2# TO 2# STEP .35#
'			x# = XxxFPREM (i#, j#)
'			y# = XxxFPREM1 (i#, j#)
'			PRINT FORMAT$ ("##.####", i#);; FORMAT$ ("##.####", j#);; FORMAT$ ("##.####", x#);; FORMAT$ ("##.####", y#)
'		NEXT j#
'	NEXT i#
'END SUB
'
' XxxFPREM1
'
'SUB TestFPREM1
'	FOR i# = 10# TO 14# STEP .5#
'		FOR j# = -2# TO 2# STEP .35#
'			x# = XxxFPREM1 (i#, j#)
'			y# = XxxFPREM (i#, j#)
'			PRINT FORMAT$ ("##.####", i#);; FORMAT$ ("##.####", j#);; FORMAT$ ("##.####", x#);; FORMAT$ ("##.####", y#)
'		NEXT j#
'	NEXT i#
'END SUB
'
' TAN() vs XxxFPTAN
'
'SUB TestFPTAN
'	FOR i# = 0 TO $$TWOPI * 2# STEP $$TWOPI / 64#
'		x# = TAN (i#)
'		k# = XxxFPTAN (i#, @j#)
'		y# = k# / j#
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#/$$PIDIV2);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' INT() and FIX() vs XxxFRNDINT
'
'SUB TestFRNDINT
'	FOR i# = -2# TO +2# STEP .25#
'		x# = INT (i#)
'		y# = FIX (i#)
'		z# = XxxFRNDINT (i#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		z$$ = GIANTAT (&z#)
'		PRINT FORMAT$ ("##.####", i#);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(z$$,16);; HEX$(z$$-y$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#);; FORMAT$ ("##.##################", z#)
'		PRINT FORMAT$ ("##.####", i#);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#);; FORMAT$ ("##.##################", z#)
'	NEXT i#
'END SUB
'
' (2# ** i * j#) vs XxxFSCALE
'
'SUB TestFSCALE
'	FOR i# = -2# TO 2# STEP .25#
'		FOR j# = -2# TO 2# STEP .25#
'			x# = 2# ** DOUBLE(FIX(i#)) * j#
'			y# = XxxFSCALE (i#, j#)
'			i$$ = GIANTAT (&i#)
'			x$$ = GIANTAT (&x#)
'			y$$ = GIANTAT (&y#)
'			PRINT FORMAT$ ("##.####", i#);; FORMAT$ ("##.####", j#);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'		NEXT j#
'	NEXT i#
'END SUB
'
' SIN() vs XxxFSIN
'
'SUB TestFSIN
'	FOR i# = 0 TO $$TWOPI * 2# STEP $$TWOPI / 64#
'		x# = SIN (i#)
'		y# = XxxFSIN (i#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#/$$PIDIV2);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' SIN() and COS() vs XxxFSINCOS
'
'SUB TestFSINCOS
'	FOR i# = 0 TO $$TWOPI * 2# STEP $$TWOPI / 64#
'		x# = SIN (i#)
'		xx# = COS (i#)
'		y# = XxxFSINCOS (i#, @z#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		xx$$ = GIANTAT (&xx#)
'		y$$ = GIANTAT (&y#)
'		z$$ = GIANTAT (&z#)
'		PRINT FORMAT$ ("##.####", i#/$$PIDIV2);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(xx$$,16);; HEX$(y$$,16);; HEX$(z$$,16);; HEX$(y$$-x$$,16);; HEX$(z$$-xx$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' SQRT() vs XxxFSQRT
'
'SUB TestFSQRT
'	FOR i# = 0 TO $$TWOPI * 2# STEP $$TWOPI / 64#
'		x# = SQRT (i#)
'		y# = XxxFSQRT (i#)
'		i$$ = GIANTAT (&i#)
'		x$$ = GIANTAT (&x#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#);; HEX$(i$$,16);; HEX$(x$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", x#);; FORMAT$ ("##.##################", y#)
'	NEXT i#
'END SUB
'
' XxxFXTRACT
'
'SUB TestFXTRACT
'	FOR i# = .25# TO 2# STEP 1# / 64#
'		y# = XxxFXTRACT (i#, @j#)
'		i$$ = GIANTAT (&i#)
'		j$$ = GIANTAT (&j#)
'		y$$ = GIANTAT (&y#)
'		PRINT FORMAT$ ("##.####", i#);; HEX$(i$$,16);; HEX$(j$$,16);; HEX$(y$$,16);; FORMAT$ ("##.##################", y#);; FORMAT$ ("##.##################", j#)
'	NEXT i#
'END SUB
'
' XxxFYL2X
'
'SUB TestFYL2X
'	FOR i# = 1# TO 2# STEP .25#
'		FOR j# = 1# TO 2# STEP .25#
'			y# = XxxFYL2X (i#, j#)
'			i$$ = GIANTAT (&i#)
'			j$$ = GIANTAT (&j#)
'			y$$ = GIANTAT (&y#)
'			z$$ = GIANTAT (&z#)
'			PRINT FORMAT$ ("##.####", i#);; FORMAT$ ("##.####", j#);; HEX$(i$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", y#)
'		NEXT j#
'	NEXT i#
'END SUB
'
' XxxFYL2XP1
'
'SUB TestFYL2XP1
'	FOR i# = 1# TO 2# STEP .25#
'		FOR j# = 1# TO 2# STEP .25#
'			y# = XxxFYL2XP1 (i#, j#)
'			i$$ = GIANTAT (&i#)
'			j$$ = GIANTAT (&j#)
'			y$$ = GIANTAT (&y#)
'			z$$ = GIANTAT (&z#)
'			PRINT FORMAT$ ("##.####", i#);; FORMAT$ ("##.####", j#);; HEX$(i$$,16);; HEX$(y$$,16);; HEX$(y$$-x$$,16);; FORMAT$ ("##.##################", y#)
'		NEXT j#
'	NEXT i#
'END SUB
'END FUNCTION
END FUNCTION
'
'
'  ############################
'  #####  XmaVersion$ ()  #####
'  ############################
'
FUNCTION  XmaVersion$ ()
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' #####################
' #####  Acos ()  #####
' #####################
'
FUNCTION DOUBLE Acos (DOUBLE v) DOUBLE
'
	SELECT CASE TRUE
		CASE (v < -1#)			: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
		CASE (v > 1#)				: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
		CASE (v = -1#)			: RETURN ($$PI)
		CASE (v =  0#)			: RETURN ($$PIDIV2)
		CASE (v =  1#)			: RETURN (0#)
		CASE ELSE						: RETURN ($$PIDIV2 - Asin(v))
	END SELECT
END FUNCTION
'
'
' ######################
' #####  Acosh ()  #####
' ######################
'
FUNCTION DOUBLE Acosh (DOUBLE v) DOUBLE
'
  SELECT CASE TRUE
	  CASE (v < 1#)			: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
    CASE (v > 1d20)		: RETURN (Log(2#*v))
		CASE ELSE					: RETURN (Log(v + Sqrt(v*v - 1#)))
  END SELECT
END FUNCTION
'
'
' #####################
' #####  Acot ()  #####
' #####################
'
FUNCTION DOUBLE Acot (DOUBLE v) DOUBLE
  IF (v > 1#) THEN RETURN (Atan(1#/v))
 	RETURN ($$PIDIV2 - Atan(v))
END FUNCTION
'
'
' ######################
' #####  Acoth ()  #####
' ######################
'
FUNCTION DOUBLE Acoth (DOUBLE v) DOUBLE
'
	SELECT CASE TRUE
		CASE (ABS(v) > 1#)	: RETURN (Atanh(1#/v))
		CASE ELSE						: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
	END SELECT
END FUNCTION
'
'
' #####################
' #####  Acsc ()  #####
' #####################
'
FUNCTION DOUBLE Acsc (DOUBLE v) DOUBLE
'
  SELECT CASE TRUE
		CASE (ABS(v) < 1#)	: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
		CASE ELSE:					: RETURN (Asin(1#/v))
  END SELECT
END FUNCTION
'
'
' ######################
' #####  Acsch ()  #####
' ######################
'
FUNCTION DOUBLE Acsch (DOUBLE v) DOUBLE
'
	SELECT CASE TRUE
		CASE (v = 0#)	: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
		CASE ELSE			: RETURN (Asinh(1#/v))
	END SELECT
END FUNCTION
'
'
' #####################
' #####  Asec ()  #####
' #####################
'
FUNCTION DOUBLE Asec (DOUBLE v) DOUBLE
'
	IF (ABS(v) < 1#) THEN errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
	RETURN ($$PIDIV2 - Asin(1#/v))
END FUNCTION
'
'
' ######################
' #####  Asech ()  #####
' ######################
'
FUNCTION DOUBLE Asech (DOUBLE v) DOUBLE
'
	SELECT CASE TRUE
		CASE (v <= 0#)		: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
		CASE (v > 1#)			: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
		CASE ELSE					: RETURN (Acosh(1#/v))
	END SELECT
END FUNCTION
'
'
' #####################
' #####  Asin ()  #####  Returns values between -PI/2 and +PI/2 inclusive
' #####################
'
FUNCTION DOUBLE Asin (DOUBLE a) DOUBLE
'
	SELECT CASE TRUE
		CASE (ABS(a) > 1#)			: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
		CASE (ABS(a) < 1d-5)		: RETURN (a*(1#+a*a/6#))
		CASE (a > 0#)		: theSign = +1#
		CASE ELSE				: theSign = -1# : a = -a
	END SELECT
'
	IF (a <= $$INVSQRT2) THEN									' a <= sin(45)
		aa = a * a
		x = a * Asin0 (aa)
	ELSE
		aa = (.5# - (a * .5#))                  ' aa = COS(ASIN(a/2))**2
		a = Sqrt (aa)
		x = $$PIDIV2 - (2# * a * Asin0 (aa))		' x = 90 - 2 arcsin(a)
	END IF
	RETURN (x * theSign)
END FUNCTION
'
'
' ######################
' #####  Asinh ()  #####
' ######################
'
FUNCTION DOUBLE Asinh (DOUBLE v) DOUBLE
'
  SELECT CASE TRUE
    CASE (v < -1d8)				: RETURN (-Log(-2#*v-0.5#/v))
    CASE (ABS(v) < 1d-4)  : RETURN (v*(1#-v*v/6#))
    CASE (v > 1d8)        : RETURN (Log(2*v+0.5#/v))
    CASE ELSE             :	RETURN (Log(v + Sqrt(v*v + 1#)))
  END SELECT
END FUNCTION
'
' ######################
' #####  Atanh ()  #####
' ######################
'
FUNCTION DOUBLE Atanh (DOUBLE v) DOUBLE
'
	SELECT CASE TRUE
		CASE (ABS(v) < 1d-5)		: RETURN (v*(1#+v*v/3#))
    CASE (ABS(v) < 1#)      : RETURN (Log((1# + v) / (1# - v)) * 0.5#)
		CASE ELSE								: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
	END SELECT
END FUNCTION
'
' #####################
' #####  Cosh ()  #####
' #####################
'
FUNCTION DOUBLE Cosh (DOUBLE v) DOUBLE
'
	SELECT CASE TRUE
		CASE (v = 0#)			: RETURN (1#)
		CASE (v >= 19#)		: RETURN (Exp(v) * 0.5#)
		CASE (v <= -19#)	: RETURN (Exp(-v) * 0.5#)
		CASE ELSE					: RETURN ((Exp(v) + Exp(-v)) * 0.5#)
	END SELECT
END FUNCTION
'
'
' ####################
' #####  Cot ()  #####
' ####################
'
FUNCTION DOUBLE Cot (DOUBLE a) DOUBLE
'
' FPU routine
'
	k# = XxxFPTAN (a, @j#)
	RETURN (j# / k#)

END FUNCTION
'
'
' #####################
' #####  Coth ()  #####
' #####################
'
FUNCTION DOUBLE Coth (DOUBLE v) DOUBLE
'
	SELECT CASE TRUE
		CASE (v = 0#)					: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
    CASE (ABS(v) < 1d-4)	: RETURN (1#/v+v/3#)
		CASE (v >= 19#)				: RETURN (1#)
		CASE (v <= -19#)			: RETURN (-1#)
		CASE ELSE							: RETURN ((Exp(v)+Exp(-v))/(Exp(v)-Exp(-v)))
	END SELECT
END FUNCTION
'
'
' ####################
' #####  Csc ()  #####  1 / SIN()
' ####################
'
FUNCTION DOUBLE Csc (DOUBLE a)
'
	x# = Sin(a)
	IFZ x# THEN
		RETURN ($$PINF)
	ELSE
		RETURN (1# / x#)
	END IF
END FUNCTION
'
'
' #####################
' #####  Csch ()  #####
' #####################
'
FUNCTION DOUBLE Csch (DOUBLE v) DOUBLE
'
	IFZ v THEN  : errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
	RETURN (1# / Sinh(v))
END FUNCTION
'
' ####################
' #####  Log ()  #####
' ####################
'
FUNCTION DOUBLE Log (DOUBLE v) DOUBLE
	SLONG  upper,  lower,  exp,  exp0,  exp1,  exp2
'
	K1 = DMAKE (0xBF2BD010, 0x5C610CA9)
	K2 = SMAKE (0x3F318000)
'
	SELECT CASE TRUE
		CASE (v < 0#)	: errLast = ERROR($$XmaErrorNatureInvalidArgument) : RETURN ($$PNAN)
		CASE (v = 0#)	: RETURN ($$NINF)
		CASE (v = 1#)	: RETURN (0#)
	END SELECT
'
	upper	= DHIGH (v)
	lower	= DLOW (v)
	exp		= upper {11, 20}
	exp0	= upper AND 0x800FFFFF
	exp1	= exp0 OR 0x3FE00000
	exp2	= exp - 1022
	frac	= DMAKE (exp1, lower)						' frac is between 1/2 and 1
	IF (frac >= $$INVSQRT2) THEN					' frac must be between 1/sqrt2 and sqrt2
		z = (frac - 1#) / (frac + 1#)				' it is!
	ELSE
		DEC exp2														' nope: dec the exponent, transfer to frac
		z = (frac - .5#) / (frac + .5#)			' mult frac by 2 (clever...)
	END IF
	zp = z * Log0 (z)
	j = ((exp2 * K1) + zp) + (exp2 * K2)
'	j = exp2 * $$LOGE2 + zp
	RETURN (j)
END FUNCTION
'
'
' ######################
' #####  Log10 ()  #####
' ######################
'
FUNCTION DOUBLE Log10 (DOUBLE v) DOUBLE
	RETURN (Log (v) * $$LOG10E)
END FUNCTION
'
' ####################
' #####  Sec ()  #####  1 / COS()
' ####################
'
FUNCTION DOUBLE Sec (DOUBLE a) DOUBLE
'
	x = Cos(a)
	IFZ x THEN
		RETURN ($$PINF)
	ELSE
  	RETURN (1# / x)
	END IF
END FUNCTION
'
'
' #####################
' #####  Sech ()  #####
' #####################
'
FUNCTION DOUBLE Sech (DOUBLE v) DOUBLE
	RETURN (1# / Cosh(v))
END FUNCTION
'
' #####################
' #####  Sinh ()  #####  >>>  may need add'l stuff for exp(v) ~= exp(-v)
' #####################
'
FUNCTION DOUBLE Sinh (DOUBLE v) DOUBLE
	SELECT CASE TRUE
		CASE (v = 0#)			: RETURN (0#)
		CASE (v >= 19#)   : RETURN (Exp(v) * 0.5#)
		CASE (v <= -19#)	: RETURN (Exp(-v) * -0.5#)
		CASE (v > .3#)		: RETURN ((Exp(v) - Exp(-v)) * 0.5#)
		CASE (v < -.3#)		: RETURN ((Exp(v) - Exp(-v)) * 0.5#)
		CASE ELSE					: dx = Expmo(v)
												RETURN (0.5# * dx*(1# + 1# / (dx + 1)))
	END SELECT
END FUNCTION
'
' #####################
' #####  Tanh ()  #####	 >>>  may have problems similar to XmaSinh ???  <<<
' #####################
'
FUNCTION DOUBLE Tanh (DOUBLE v) DOUBLE
	SELECT CASE TRUE
		CASE (v = 0#)				:										RETURN (0#)
		CASE (v >= 19#)			:										RETURN (1#)
		CASE (v <= -19#)		:										RETURN (-1#)
		CASE (ABS(v) > .1#)	: ev = Exp(v+v)		: RETURN ((ev - 1#) / (ev + 1#))
		CASE ELSE						: xv = Expmo(v+v)	: RETURN (xv / (2# + xv))
	END SELECT
END FUNCTION
'
'
' ######################
' #####  Asin0 ()  #####  Hart #4731  :  INTERNAL FUNCTION  :  returns RADIANS
' ######################
'
FUNCTION DOUBLE Asin0 (DOUBLE aa) DOUBLE
'
	x = aa * .28887940520319958009# - .1532823762188072258146d2#
	x = x * aa + .15627431676469845164879d3#
	x = x * aa - .61608581811333824880753d3#
	x = x * aa + .1131354445141400374754542d4#
	x = x * aa - .975678343527571443444814d3#
	x = x * aa + .31952141659008684896086d3#
	y = aa - .282183566472129245114d2#
	y = y * aa + .22430629957413222990564d3#
	y = y * aa - .76632677210477257595839d3#
	y = y * aa + .1278878991056988003191528d4#
	y = y * aa - .1028931912959252211748113d4#
	y = y * aa + .319521416590086848208615d3#
	RETURN (x / y)
END FUNCTION
'
' ######################
' #####  Expmo ()  #####  Hart #1802
' ######################
'
' EXP(v) - 1, for small v (presumably)
'
FUNCTION DOUBLE Expmo (DOUBLE v) DOUBLE
	vv = v * v
	x = vv * .3333206802628149222225154d-1 + .1400022777377555304975874306d2
	x = x * vv + .5040127554054843027460596926d3
	y = vv + .1120025814484651564577585494d3
	y = y * vv + .1008025510810968605492139581d4
	z = (2# * v * x) / (y - (v * x))
	RETURN (z)
END FUNCTION
'
'
' #####################
' #####  Log0 ()  #####  Hart #2705
' #####################
'
FUNCTION DOUBLE Log0 (DOUBLE v) DOUBLE
  vv = v * v
	x = vv * .4210873712179797145# - .96376909336868659324d1
	x = x * vv + .30957292821537650062264d2
	x = x * vv - .240139179559210509868484d2
	y = vv - .89111090279378312337d1
	y = y * vv + .19480966070088973051623d2
	y = y * vv - .120069589779605254717525d2
	z = x / y
	RETURN (z)

END FUNCTION
'
'
' #####################
' #####  Fmod ()  #####
' #####################
'
' Floating point modulus function.
'
FUNCTION DOUBLE Fmod (DOUBLE num1, DOUBLE num2)

ASM finit
ASM fld     q[ebp+16]  					; st0 = num2
ASM fld     q[ebp+8]  					; st1 = num2, st0 = num1

ASM fmod:
ASM	fprem												; partial remainder
ASM	fstsw 	ax 									; store status word in ax
ASM fwait
ASM	sahf  											; copy the condition bits in the CPU's flag register
ASM	jp 			fmod
ASM	fstp 		st1
ASM	jmp			end.Fmod.xma			  ; return with modulus in st(0)

END FUNCTION
'
'
' #######################
' #####  Fround ()  #####
' #######################
'
' Floating point rounding function.
'
FUNCTION  DOUBLE Fround (DOUBLE number, power)
  pTen# = 10# ** power
  RETURN ROUND(number / pTen#) * pTen#
END FUNCTION
END PROGRAM
