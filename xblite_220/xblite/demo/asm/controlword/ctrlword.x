'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Get or set the FPU control word.
' Set the FPU rounding mode.
' Set the FPU precision mode.
' Test the FPU classifying functions for LONGDOUBLE:
' IsFiniteL, IsNormalL, IsSubNormalL, IsInfL,
' IsNanL, IsZeroL, and SignBitL.
'
PROGRAM	"ctrlword"
VERSION	"0.0002"	' modified 16 Oct 05 for goasm
CONSOLE

	IMPORT	"xst"   ' Standard library : required by most programs

DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	USHORT cw, cwLast, sw
	LONGDOUBLE xld

	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	cwLast = XstSetFPURounding ($$ROUND_DOWN)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	XstSetFPURounding ($$ROUND_UP)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	XstSetFPURounding ($$TRUNCATE)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	XstSetFPURounding ($$ROUND_NEAREST)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	XstSetFPUControlWord (cwLast)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	XstSetFPUPrecision ($$24_BITS)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	XstSetFPUPrecision ($$53_BITS)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	XstSetFPUPrecision ($$64_BITS)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	XstSetFPUControlWord (cwLast)
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

' disable the FPU exception bits by using finit
ASM finit
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

' unmask divide-by-zero, overflow, and underflow FPU exceptions
	XstEnableFPExceptions ()
	cw = XstGetFPUControlWord ()
	PRINT BIN$ (cw, 16)

	x## = 1##
	y## = 1.0e-4932##

	PRINT SignBitL (x##), SignBitL (y##)
	PRINT IsNanL (x##), IsNanL (y##)
	PRINT IsFiniteL (x##), IsFiniteL (y##)
	PRINT IsInfL (x##), IsInfL (y##)
	PRINT IsNormalL (x##), IsNormalL (y##)
	PRINT IsZeroL (x##), IsZeroL (y##)
	PRINT IsSubNormalL (x##), IsSubNormalL (y##)

	PRINT
	a$ = INLINE$ ("Press Enter key to quit >")


END FUNCTION
END PROGRAM
