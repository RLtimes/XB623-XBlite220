'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Rudimentary long double math library.
'
PROGRAM	"xml"
VERSION	"0.0002"
CONSOLE

'IMPORT	"xst"   ' Standard library : required by most programs
EXPORT
DECLARE FUNCTION  VOID        Xml   ()
DECLARE FUNCTION  LONGDOUBLE  SqrtL (LONGDOUBLE xld)
DECLARE FUNCTION  LONGDOUBLE  PiL   ()
DECLARE FUNCTION  LONGDOUBLE  Ln2L  ()
DECLARE FUNCTION  LONGDOUBLE  Log2L ()
DECLARE FUNCTION  LONGDOUBLE  SinL  (LONGDOUBLE xld)
DECLARE FUNCTION  LONGDOUBLE  CosL  (LONGDOUBLE xld)
DECLARE FUNCTION  LONGDOUBLE  TanL  (LONGDOUBLE xld)
DECLARE FUNCTION  LONGDOUBLE  LogL  (LONGDOUBLE xld)
DECLARE FUNCTION  LONGDOUBLE  LnL   (LONGDOUBLE xld)
END EXPORT
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Xml ()

	IF LIBRARY (0) THEN RETURN
	
	PRINT PiL()
	PRINT Log2L()
	PRINT Ln2L ()

	PRINT SqrtL(2##), SqrtL(100.0##)

	PRINT SinL (45.0## * PiL() / 180##)
	PRINT CosL (45.0## * PiL() / 180##)
	PRINT TanL (45.0## * PiL() / 180##)
	
	PRINT LogL (10.0##)
	PRINT LogL (2.0##)
	PRINT LogL (1000##)
	
	PRINT LnL (2.0##)
	PRINT LnL (1000##)

	a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
'
' ######################
' #####  SqrtL ()  #####
' ######################
'
' Compute the square root of a long double value
'
FUNCTION  LONGDOUBLE SqrtL (LONGDOUBLE xld)

	LONGDOUBLE sqrt
	
ASM	fld	  t[ebp+8]
ASM	fsqrt
ASM	fstp	t[ebp-32]

	RETURN sqrt

END FUNCTION
'
'
' ####################
' #####  PiL ()  #####
' ####################
'
' Return value for Pi.
'
FUNCTION  LONGDOUBLE PiL ()

	LONGDOUBLE pi

ASM	fldpi												; load pi into st(0)
ASM	fstp	t[ebp-32]

	RETURN pi

END FUNCTION
'
'
' ######################
' #####  Log2L ()  #####
' ######################
'
' Return value for the log base 10 of 2 (log(2)).
'
FUNCTION  LONGDOUBLE Log2L ()

	LONGDOUBLE log2

ASM	fldlg2												; load log(2) into st(0)
ASM	fstp	t[ebp-32]

	RETURN log2

END FUNCTION
'
'
' ######################
' #####  Ln2L ()  #####
' ######################
'
' Return value for the natural log base e of 2 (ln(2)).
'
FUNCTION  LONGDOUBLE Ln2L ()

	LONGDOUBLE ln2

ASM	fldln2												; load ln(2) into st(0)
ASM	fstp	t[ebp-32]

	RETURN ln2

END FUNCTION
'
'
' #####################
' #####  SinL ()  #####
' #####################
'
' Compute the sine of a long double value in radians
'
FUNCTION  LONGDOUBLE SinL (LONGDOUBLE xld)

	LONGDOUBLE sin
	
ASM	fld	  t[ebp+8]
ASM	fsin
ASM	fstp	t[ebp-32]

	RETURN sin

END FUNCTION
'
'
' #####################
' #####  CosL ()  #####
' #####################
'
' Compute the cosine of a long double value in radians
'
FUNCTION  LONGDOUBLE CosL (LONGDOUBLE xld)

	LONGDOUBLE cos
	
ASM	fld	  t[ebp+8]
ASM	fcos
ASM	fstp	t[ebp-32]

	RETURN cos

END FUNCTION
'
'
' #####################
' #####  TanL ()  #####
' #####################
'
' Compute the tangent of a long double value in radians
'
FUNCTION  LONGDOUBLE TanL (LONGDOUBLE xld)

	LONGDOUBLE tan
	
ASM	fld	  t[ebp+8]
ASM	fptan											;ST(0)=1.0, ST(1)=tan(rad)
ASM	fstp	st0       				;this pops the TOP register, ST(0)=tan(rad)
ASM	fstp	t[ebp-32]

	RETURN tan

END FUNCTION
'
'
' #####################
' #####  LogL ()  #####
' #####################
'
' Compute the common log base 10 of a long double value (log10(x)).
'
FUNCTION  LONGDOUBLE LogL (LONGDOUBLE xld)

	LONGDOUBLE log
	
ASM	fldlg2         							;ST(0)=log10(2), ST(1)=zzz
ASM	fld  		t[ebp+8]		;ST(0)=xld, ST(1)=log10(2), ST(2)=zzz
ASM	fyl2x          							;log2(xld)*log10(2)=>ST(1) and ST(0) is POPed
'               							;ST(0)=log10(xld), ST(1)=zzz
ASM	fstp		t[ebp-32]
	
	RETURN log

END FUNCTION
'
'
' #####################
' #####  LnL ()  #####
' #####################
'
' Compute the natural log of a long double value (ln(x)).
'
FUNCTION  LONGDOUBLE LnL (LONGDOUBLE xld)

	LONGDOUBLE ln
	
ASM	fldln2         							;ST(0)=ln(2), ST(1)=zzz
ASM	fld  		t[ebp+8]		;ST(0)=xld, ST(1)=ln(2), ST(2)=zzz
ASM	fyl2x          							;log2(xld)*ln(2)=>ST(1) and ST(0) is POPed
'               							;ST(0)=log10(xld), ST(1)=zzz
ASM	fstp		t[ebp-32]
	
	RETURN ln

END FUNCTION
END PROGRAM
