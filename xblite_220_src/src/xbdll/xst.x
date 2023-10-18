

' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2003
' ####################  XBLite standard function library

' Xst is the XBlite standard function library
' which is included as an object library
' within xb.dll
' ---
' Xst now contains the minimum number of functions
' required to build/compile/run XBLite programs.
' Many of the functions have been moved to
' another external library, Xsx.
' ---
' subject to LGPL license - see COPYING_LIB
' maxreason@maxreason.com
' ---
' XBLite modifications by David Szafranski 2002
' david.szafranski@wanadoo.fr
'
' 11/2003 - New exception routines by Ken Minogue
' - XstExceptionNameToNumber()
' - XstRaiseException()
' - XstRegisterException()
'
' 01/2004
' - Moved IO console functions to an external library xio.
'	- Moved XxxFormat$ and ValidFormat to external library.
'	- Removed use of INCHR intrinsic from within Xst library (substituted INSTR).
'	- Removed use of LEFT$ intrinsic from within Xst library (substituted MID$).
'	- Removed use of RCLIP$/LCLIP$ intrinsics from within Xst library (substituted MID$).
'
' 03/2004
' - Added XstStringToLongDouble function for LONGDOUBLE type support.
' - Added XstLongDoubleToString$ function.
' - Added FPU control word functions.
' - Added FP classification functions for LONGDOUBLE type.
' - Modified XxxInline$() so that CRLF characters are not returned in string.
'
' 06/2004
' - Modified XxxInline$(), added FlushConsoleInputBuffer().
'
' 05/2005
' - Modified include files
'
' v0.052 07/2005
' - fixed bug in XstLongDoubleToString$ to print trailing zeros correctly.
'
' v0.053 11 October 2005
' - Modified inline asm to GoAsm syntax
'
' v0.054 18 October 2005
' - Moved ValidFormat and XxxFormat$ functions into xblib.lib (for FORMAT$ support)
'
' v0.055 19 October 2005
' - Moved DllMain from xlib.asm to be emmitted from xcowlite.
'
' v0.056 6 December 2005
' - moved exception$[] intialization from InitProgram to InitExceptionArray.
' - modified InitProgram, XstSystemErrorToError, XstSystemErrorNumberToName,
'   and XstErrorNumberToName. System errors are now placed in the high word
'   of xblite error values, while xblite errors are in the low word. This was done
'   so that arrays #OSERROR$[] and #OSTOXERROR$[] are no longer needed.
'   The only drawback to this is that XstErrorNameToNumber() will not work on system errors.

' v0.057 21 February 2006
' - changed inline assembly ? to ASM

PROGRAM	"xst"
VERSION	"0.057"
'
'IMPORT	"xblib.lib"
IMPORT  "gdi32.dec"
IMPORT	"user32"
IMPORT	"kernel32"
'IMPORT "msvcrt"

' **********************************************
' *****  Standard Library COMPOSITE TYPES  *****
' **********************************************
'
'
'
TYPE FILE
  STRING*112   .fileName
  XLONG        .fileHandle
  XLONG        .consoleGrid
  XLONG        .entries
END TYPE
'
TYPE LOCK
  XLONG        .file
  XLONG        .sfile
  GIANT        .offset
  GIANT        .length
  GIANT        .end
END TYPE
'
EXPORT
'
TYPE EXCEPTION_DATA
	XLONG	.code
	XLONG .type
	XLONG	.address
	XLONG	.response
	XLONG .info[14]
END TYPE
'
TYPE TBYTE
	UNION
		UBYTE 			.ub[11]
		USHORT			.us[5]
		LONGDOUBLE 	.ld
	END UNION
END TYPE
'
'END EXPORT
'
'EXPORT
'
' ****************************************
' *****  Standard Library Functions  *****
' ****************************************
'
' system functions, error functions, exception functions
'
DECLARE FUNCTION  Xst                            ()
DECLARE FUNCTION  XstVersion$                    ()
DECLARE FUNCTION  XstCauseException              (exception)
DECLARE FUNCTION  XstErrorNameToNumber           (error$, @error)
DECLARE FUNCTION  XstErrorNumberToName           (error, @error$)
DECLARE FUNCTION  XstExceptionNameToNumber       (exception$, exception)
DECLARE FUNCTION  XstExceptionNumberToName       (exception, @exception$)
DECLARE FUNCTION  XstExceptionToSystemException  (exception, @sysException)
DECLARE FUNCTION  XstRaiseException              (exception, type, arguments[])
DECLARE FUNCTION  XstRegisterException           (@exception$, @exception)
DECLARE FUNCTION  XstSystemErrorNumberToName     (sysError, @sysError$)
DECLARE FUNCTION  XstSystemExceptionToException  (sysException, @exception)
DECLARE FUNCTION  XstSystemErrorToError          (sysError, error)
DECLARE FUNCTION  XstSystemExceptionNumberToName (sysException, sysException$)
DECLARE FUNCTION  XstGetSystemError              (sysError)
DECLARE FUNCTION  XstSetSystemError              (sysError)
DECLARE FUNCTION  XstGetException                (@exception)
DECLARE FUNCTION  XstGetExceptionFunction        (@function)
DECLARE FUNCTION  XstSetException                (exception)
DECLARE FUNCTION  XstSetExceptionFunction        (function)
DECLARE FUNCTION  XstGetEnvironmentVariable      (@name$, @value$)
'
EXTERNAL FUNCTION XstGetExceptionInformation     (EXCEPTION_RECORD @exRec, CONTEXT @context)
EXTERNAL FUNCTION XstTry                         (SUBADDR Try, SUBADDR Handler, EXCEPTION_DATA @exception)
'
'
' win32 helper functions
'
DECLARE FUNCTION  HIWORD                         (x)
DECLARE FUNCTION  LOWORD                         (x)
DECLARE FUNCTION  MAKELONG                       (lo, hi)
DECLARE FUNCTION  RGB                            (r, g, b)
'
' file functions
'
DECLARE FUNCTION  XstFileToSystemFile            (fileNumber, @systemFileNumber)
DECLARE FUNCTION  XstLockFileSection             (fileNumber, mode, offset$$, length$$)
DECLARE FUNCTION  XstUnlockFileSection           (fileNumber, mode, offset$$, length$$)
DECLARE FUNCTION  XstPathString$                 (path$)
'
' LONGDOUBLE support functions
'
DECLARE FUNCTION  USHORT FPClassifyL             (LONGDOUBLE x)
DECLARE FUNCTION  IsFiniteL                      (LONGDOUBLE x)
DECLARE FUNCTION  IsInfL                         (LONGDOUBLE x)
DECLARE FUNCTION  IsNanL                         (LONGDOUBLE x)
DECLARE FUNCTION  IsNormalL                      (LONGDOUBLE x)
DECLARE FUNCTION  IsSubNormalL                   (LONGDOUBLE x)
DECLARE FUNCTION  IsZeroL                        (LONGDOUBLE x)
DECLARE FUNCTION  SignBitL                       (LONGDOUBLE x)
DECLARE FUNCTION  XstStringToLongDouble          (text$, start, @after, @rtype, LONGDOUBLE value)
DECLARE FUNCTION  XstLongDoubleToString$         (LONGDOUBLE ld, maxDigits, expChar, prefixChar)
'
' xlib functions
'
EXTERNAL FUNCTION  XstStringToNumber             (s$, startOff, afterOff, rtype, value$$)
EXTERNAL FUNCTION  XstFindMemoryMatch            (addrStart, addrAfter, addrMatch, minLength, maxLength)
'
' misc functions
'
DECLARE FUNCTION  XstCenterWindow                (hWnd)
'
DECLARE FUNCTION  XxxXstFreeLibrary              (lib$, handle)
DECLARE FUNCTION  XxxXstLoadLibrary              (lib$)
DECLARE FUNCTION  InitProgram                    ()
'
' FPU control word functions
'
DECLARE FUNCTION  USHORT XstEnableFPExceptions   ()
DECLARE FUNCTION  USHORT XstGetFPUControlWord    ()
DECLARE FUNCTION  USHORT XstSetFPUControlWord    (USHORT cw)
DECLARE FUNCTION  USHORT XstSetFPUPrecision      (mode)
DECLARE FUNCTION  USHORT XstSetFPURounding       (mode)
'
END EXPORT
'
' internal Xst functions
'
INTERNAL FUNCTION  InvalidFileNumber             (fileNumber)
INTERNAL FUNCTION  GetLocaleDecimalPoint         ()
INTERNAL FUNCTION  Init_POT_Tables               ()

'
' intrinsic support functions
'
EXPORT
DECLARE FUNCTION  XxxEof                         (fileNumber)
DECLARE FUNCTION  XxxWriteFile                   (fileNumber, addr, bytes, bytesWritten, overlapped)
DECLARE FUNCTION  XxxReadFile                    (fileNumber, addr, bytes, bytesRead, overlapped)
DECLARE FUNCTION  XxxClose                       (fileNumber)
DECLARE FUNCTION  XxxLof                         (fileNumber)
DECLARE FUNCTION  XxxOpen                        (fileName$, openMode)
DECLARE FUNCTION  XxxPof                         (fileNumber)
DECLARE FUNCTION  XxxInfile$                     (fileNumber)
DECLARE FUNCTION  XxxInline$                     (prompt$)
DECLARE FUNCTION  XxxSeek                        (fileNumber, position)
DECLARE FUNCTION  XxxShell                       (command$)
'
' exception handler initialization
'
DECLARE FUNCTION  Xit                            (appStart)
DECLARE FUNCTION InitExceptionArray ()
DECLARE FUNCTION InitErrorStringArrays ()

'
'
' ****************************************
' *****  Standard Library Constants  *****
' ****************************************
'
' path slash characters (different for DOS/Windows vs UNIX)
'
  $$PathSlash$          = "\\"      ' Windows
  $$PathSlash           = '\\'      ' Windows
' This is the character that separates directories in environment-variables
' (e.g. PATH).
	$$PathSeparator				= ';'				' Windows
	$$PathSeparator$			= ";"				' Windows
' $$PathSlash$          = "/"       ' UNIX
' $$PathSlash           = '/'       ' UNIX
'	$$PathSeparator				= ':'				' Unix
'	$$PathSeparator$			= ":"				' Unix

' ********************************
' *****  File I/O Constants  *****  for OPEN()
' ********************************
'
  $$RD                  = 0x0000    ' read file
  $$WR                  = 0x0001    ' write file
  $$RW                  = 0x0002    ' read/write file
  $$WRNEW               = 0x0003    ' write new file
  $$RWNEW               = 0x0004    ' read/write new file
  $$NOSHARE             = 0x0000    ' share file for none
  $$RDSHARE             = 0x0010    ' share file for read
  $$WRSHARE             = 0x0020    ' share file for write
  $$RWSHARE             = 0x0030    ' share file for read & write
  $$ALL                 = -1        ' CLOSE ($$ALL)
'
' ********************************
' *****  Language Constants  *****  I/O, Kinds, DataTypes, Scope, etc...
' ********************************
'
  $$ZERO                =  0
  $$ONE                 =  1
  $$ENDIAN              =  0
  $$STDIN               =  0
  $$STDOUT              =  1
  $$STDERR              =  2
  $$VOID                =  1
  $$SBYTE               =  2
  $$UBYTE               =  3
  $$SSHORT              =  4
  $$USHORT              =  5
  $$SLONG               =  6
  $$ULONG               =  7
  $$XLONG               =  8
  $$GOADDR              =  9
  $$SUBADDR             = 10
  $$FUNCADDR            = 11
  $$GIANT               = 12
  $$SINGLE              = 13
  $$DOUBLE              = 14
	$$LONGDOUBLE          = 15
  $$ARRAY               = 16
  $$ANY                 = 16
  $$ETC                 = 17
  $$VARARG              = 18
  $$STRING              = 19
  $$COMPOSITE           = 31
  $$SCOMPLEX            = 32
  $$DCOMPLEX            = 33
  $$AUTO                =  0
  $$AUTOX               =  1
  $$STATIC              =  2
  $$SHARED              =  3
  $$EXTERNAL            =  4
  $$ARGUMENT            =  7

' FPU rounding modes
$$ROUND_NEAREST = 0
$$ROUND_DOWN = 1
$$ROUND_UP = 2
$$TRUNCATE = 3

' FPU precision modes
$$24_BITS = 0
$$53_BITS = 1
$$64_BITS = 2
'
' FP Classification constants
$$FP_NAN		   = 0x0100
$$FP_NORMAL	   = 0x0400
$$FP_INFINITE	 = 0x0500		' (FP_NAN | FP_NORMAL)
$$FP_ZERO		   = 0x4000
$$FP_SUBNORMAL = 0x4400		' (FP_NORMAL | FP_ZERO)
'
'
' **********************************
' *****  Native Error Numbers  *****
' **********************************
'
' "Native Error Numbers" are USHORT values composed of two parts:
'    1. ErrorObject in upper byte - object associated with error
'    2. ErrorNature in lower byte - nature of action or error
'
  $$ErrorObjectNone                =  0    ' or unknown
  $$ErrorObjectData                =  1
  $$ErrorObjectDisk                =  2
  $$ErrorObjectFile                =  3
  $$ErrorObjectFont                =  4
  $$ErrorObjectGrid                =  5
  $$ErrorObjectIcon                =  6
  $$ErrorObjectName                =  7
  $$ErrorObjectNode                =  8
  $$ErrorObjectPipe                =  9
  $$ErrorObjectUser                = 10
  $$ErrorObjectArray               = 11
  $$ErrorObjectImage               = 12
  $$ErrorObjectMedia               = 13
  $$ErrorObjectQueue               = 14
  $$ErrorObjectStack               = 15
  $$ErrorObjectTimer               = 16
  $$ErrorObjectBuffer              = 17
  $$ErrorObjectCursor              = 18
  $$ErrorObjectDevice              = 19
  $$ErrorObjectDriver              = 20
  $$ErrorObjectMemory              = 21
  $$ErrorObjectSocket              = 22
  $$ErrorObjectString              = 23
  $$ErrorObjectSystem              = 24
  $$ErrorObjectThread              = 25
  $$ErrorObjectWindow              = 26
  $$ErrorObjectCommand             = 27
  $$ErrorObjectDisplay             = 28
  $$ErrorObjectLibrary             = 29
  $$ErrorObjectMessage             = 30
  $$ErrorObjectNetwork             = 31
  $$ErrorObjectPrinter             = 32
  $$ErrorObjectProcess             = 33
  $$ErrorObjectProgram             = 34
  $$ErrorObjectArgument            = 35
  $$ErrorObjectComputer            = 36
  $$ErrorObjectFunction            = 37
  $$ErrorObjectIdentity            = 38
  $$ErrorObjectPassword            = 39
  $$ErrorObjectClipboard           = 40
  $$ErrorObjectDirectory           = 41
  $$ErrorObjectSemaphore           = 42
  $$ErrorObjectStatement           = 43
  $$ErrorObjectSystemRoutine       = 44
  $$ErrorObjectSystemFunction      = 45
  $$ErrorObjectSystemResource      = 46
  $$ErrorObjectOperatingSystem     = 47
  $$ErrorObjectIntegerLogicUnit    = 48
  $$ErrorObjectFloatingPointUnit   = 49
'
  $$ErrorNatureNone                =  0
  $$ErrorNatureBusy                =  1
  $$ErrorNatureFull                =  2
  $$ErrorNatureError               =  3
  $$ErrorNatureEmpty               =  4
  $$ErrorNatureReset               =  5
  $$ErrorNatureExists              =  6
  $$ErrorNatureFailed              =  7
  $$ErrorNatureHalted              =  8
  $$ErrorNatureExpired             =  9
  $$ErrorNatureInvalid             = 10
  $$ErrorNatureMissing             = 11
  $$ErrorNatureTimeout             = 12
  $$ErrorNatureTooMany             = 13
  $$ErrorNatureUnknown             = 14
  $$ErrorNatureBreakKey            = 15
  $$ErrorNatureDeadlock            = 16
  $$ErrorNatureDisabled            = 17
  $$ErrorNatureNotEmpty            = 18
  $$ErrorNatureObsolete            = 19
  $$ErrorNatureOverflow            = 20
  $$ErrorNatureTooLarge            = 21
  $$ErrorNatureTooSmall            = 22
  $$ErrorNatureAbandoned           = 23
  $$ErrorNatureAvailable           = 24
  $$ErrorNatureDuplicate           = 25
  $$ErrorNatureExhausted           = 26
  $$ErrorNaturePrivilege           = 27
  $$ErrorNatureUndefined           = 28
  $$ErrorNatureUnderflow           = 29
  $$ErrorNatureAllocation          = 30
  $$ErrorNatureBreakpoint          = 31
  $$ErrorNatureContention          = 32
  $$ErrorNaturePermission          = 33
  $$ErrorNatureTerminated          = 34
  $$ErrorNatureUndeclared          = 35
  $$ErrorNatureUnexpected          = 36
  $$ErrorNatureWouldBlock          = 37
  $$ErrorNatureInterrupted         = 38
  $$ErrorNatureMalfunction         = 39
  $$ErrorNatureNonexistent         = 40
  $$ErrorNatureUnavailable         = 41
  $$ErrorNatureUnspecified         = 42
  $$ErrorNatureDisconnected        = 43
  $$ErrorNatureDivideByZero        = 44
  $$ErrorNatureIncompatible        = 45
  $$ErrorNatureNotConnected        = 46
  $$ErrorNatureLimitExceeded       = 47
  $$ErrorNatureNotInitialized      = 48
  $$ErrorNatureHigherDimension     = 49
  $$ErrorNatureLowestDimension     = 50
  $$ErrorNatureCannotInitialize    = 51
  $$ErrorNatureInitializeFailed    = 52
  $$ErrorNatureAlreadyInitialized  = 53
  $$ErrorNatureInvalidAccess       = 54
  $$ErrorNatureInvalidAddress      = 55
  $$ErrorNatureInvalidAlignment    = 56
  $$ErrorNatureInvalidArgument     = 57
  $$ErrorNatureInvalidCheck        = 58
  $$ErrorNatureInvalidCoordinates  = 59
  $$ErrorNatureInvalidCommand      = 60
  $$ErrorNatureInvalidData         = 61
  $$ErrorNatureInvalidDimension    = 62
  $$ErrorNatureInvalidEntry        = 63
  $$ErrorNatureInvalidFormat       = 64
  $$ErrorNatureInvalidKind         = 65
  $$ErrorNatureInvalidIdentity     = 66
  $$ErrorNatureInvalidInstruction  = 67
  $$ErrorNatureInvalidLocation     = 68
	$$ErrorNatureInvalidMessage      = 69
  $$ErrorNatureInvalidName         = 70
  $$ErrorNatureInvalidNode         = 71
  $$ErrorNatureInvalidNumber       = 72
  $$ErrorNatureInvalidOperand      = 73
  $$ErrorNatureInvalidOperation    = 74
  $$ErrorNatureInvalidReply        = 75
  $$ErrorNatureInvalidRequest      = 76
  $$ErrorNatureInvalidResult       = 77
  $$ErrorNatureInvalidSelection    = 78
  $$ErrorNatureInvalidSignature    = 79
  $$ErrorNatureInvalidSize         = 80
  $$ErrorNatureInvalidType         = 81
  $$ErrorNatureInvalidValue        = 82
  $$ErrorNatureInvalidVersion      = 83
  $$ErrorNatureInvalidDistribution = 84
  $$ErrorNatureInvalidMargin       = 85
'
'
' ****************************************
' *****  Native Exception Constants  *****
' ****************************************
'
  $$ExceptionNone                  =  0
  $$ExceptionSegmentViolation      =  1
  $$ExceptionOutOfBounds           =  2
  $$ExceptionBreakpoint            =  3
  $$ExceptionBreakKey              =  4
  $$ExceptionAlignment             =  5
  $$ExceptionDenormal              =  6
  $$ExceptionDivideByZero          =  7
  $$ExceptionInvalidOperation      =  8
  $$ExceptionOverflow              =  9
  $$ExceptionStackCheck            = 10
  $$ExceptionUnderflow             = 11
  $$ExceptionInvalidInstruction    = 12
  $$ExceptionPrivilege             = 13
  $$ExceptionStackOverflow         = 14
  $$ExceptionReserved              = 15
  $$ExceptionTimer                 = 16
  $$ExceptionUnknown               = 17
	$$ExceptionIntDivideByZero       = 18
	$$ExceptionIntOverflow           = 19
	$$ExceptionPrecision             = 20
	$$ExceptionGuardPage             = 21
	$$ExceptionInPage                = 22
	$$ExceptionDisposition           = 23
	$$ExceptionNoncontinuable        = 24
	$$ExceptionSingleStep            = 25
	$$ExceptionMemoryAllocation      = 26
	$$ExceptionNodeNotEmpty          = 27
	$$ExceptionArrayDimension        = 28
	$$ExceptionInvalidArgument       = 29
  $$ExceptionUpper                 = 31
	$$ExceptionFloatDivideByZero     = $$ExceptionDivideByZero
  $$ExceptionFloatOverflow         = $$ExceptionOverflow
'
  $$ExceptionTerminate             =  0
  $$ExceptionContinue              = -1
	$$ExceptionRetry                 = -2
	$$ExceptionForward							 =  1

	$$ExceptionCodeUser              = 0x20000000

	$$ExceptionTypeInformation       = 0x40000000
	$$ExceptionTypeWarning           = 0x80000000
	$$ExceptionTypeError             = 0xC0000000

END EXPORT
'
'
' ####################
' #####  Xst ()  #####
' ####################
'
'
FUNCTION  Xst ()

	STATIC  entry

	IF entry THEN RETURN
	entry = $$TRUE

	InitProgram ()		' !!! must call InitProgram() before XxxOpen() !!!
										' Xst() called by DllMain in xlib.s

' initialize console
	confile = XxxOpen ("CON:", $$RD)			' Create/reserve a console FILE entry in fileInfo[]
																				' This does not create the Console window
																				' For GUI programs, XstCreateConsole is used to
                                        ' to allocate a console window.
END FUNCTION
'
'
' ############################
' #####  XstVersion$ ()  #####
' ############################
'
FUNCTION  XstVersion$ ()
'
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' ##################################
' #####  XstCauseException ()  #####
' ##################################
'
FUNCTION  XstCauseException (exception)
'
	XstExceptionToSystemException (exception, @sysException)
	RaiseException (sysException, 0, 0, 0)
END FUNCTION
'
'
' #####################################
' #####  XstErrorNameToNumber ()  #####
' #####################################
'
FUNCTION  XstErrorNameToNumber (err$, error)
	SHARED	errorObject$[]
	SHARED	errorNature$[]

	IFZ errorObject$[] THEN InitErrorStringArrays ()
'
	error = 0
	return = $$TRUE																' error name not found
	object = $$FALSE															' object not yet found
	nature = $$FALSE															' nature not yet found
	error$ = TRIM$ (err$)
	uobject = UBOUND (errorObject$[])
	unature = UBOUND (errorNature$[])
'
'	space = INCHR (error$, " \t")								' space or tab separator
' *****
' note: trying to eliminate use of INCHR in Xst library
	space = INSTR (error$, " ")
	IFZ space THEN space = INSTR (error$, "\t")
' *****
	IFZ space THEN
		e$ = error$
		error$ = ""
	ELSE
'		e$ = TRIM$(LEFT$(error$, space))
' *****
' note: trying to eliminate use of LEFT$ in Xst library
		e$ = TRIM$(MID$(error$, 1, space))
' *****
		error$ = TRIM$(MID$(error$, space+1))
	END IF
'
	FOR i = 1 TO uobject
		IF (e$ = errorObject$[i]) THEN
			error = error OR (i << 8)							' error object found
			EXIT FOR
		END IF
		IF (error$ = errorObject$[i]) THEN
			error = error OR (i << 8)
			EXIT FOR
		END IF
	NEXT i
'
	FOR i = 1 TO unature
		IF (error$ = errorNature$[i]) THEN
			error = error OR i										' error nature found
			EXIT FOR															' only one error nature
		END IF
		IF (e$ = errorNature$[i]) THEN
			error = error OR i
			EXIT FOR
		END IF
	NEXT i
	RETURN (error)
END FUNCTION
'
'
' #####################################
' #####  XstErrorNumberToName ()  #####
' #####################################
'
FUNCTION  XstErrorNumberToName (error, @error$)
	SHARED	errorObject$[]
	SHARED	errorNature$[]

	sysError = HIWORD (error)
	IF sysError THEN
		XstSystemErrorNumberToName (sysError, @error$)
		RETURN
	END IF

	IFZ errorObject$[] THEN InitErrorStringArrays ()
'
	nature = error AND 0x00FF
	object = (error >> 8) AND 0x00FF
	upperObject = UBOUND (errorObject$[])
	upperNature = UBOUND (errorNature$[])
'
	error$ = ""
	SELECT CASE TRUE
		CASE (object < 0) 					: error$ = "Unknown Negative Object Number"
		CASE (nature < 0)						: error$ = "Unknown Negative Nature Number"
		CASE (object > upperObject)	: error$ = "$$ErrorObject too large"
		CASE (nature > upperNature)	: error$ = "$$ErrorNature too large"
	END SELECT
'
	IF error$ THEN RETURN
	object$ = errorObject$[object]
	nature$ = errorNature$[nature]
	IFZ (object OR nature) THEN error$ = "NoError" : RETURN
'
	IF object$ THEN
		IF nature$ THEN
			error$ = object$ + " " + nature$
		ELSE
			error$ = object$
		END IF
	ELSE
		IF nature THEN
			error$ = nature$
		ELSE
			error$ = "UnknownError"
		END IF
	END IF
END FUNCTION
'
'
' #########################################
' #####  XstExceptionNameToNumber ()  #####
' #########################################
'
FUNCTION  XstExceptionNameToNumber (exception$, exception)
	SHARED exception$[]

	IFZ exception$[] THEN InitExceptionArray()

	exception = 0
	ex$ = TRIM$(exception$)
	IFZ ex$ THEN RETURN

	FOR ex = 0 TO UBOUND(exception$[])
		IF ex$ == exception$[ex] THEN exception = ex: RETURN
	NEXT ex
END FUNCTION
'
'
' #########################################
' #####  XstExceptionNumberToName ()  #####
' #########################################
'
FUNCTION  XstExceptionNumberToName (exception, exception$)
	SHARED	exception$[]

	IFZ exception$[] THEN InitExceptionArray()
'
	exception$ = ""
	upper = UBOUND (exception$[])
	IF (exception < 0) THEN RETURN ($$TRUE)
	IF (exception > upper) THEN RETURN ($$TRUE)
	exception$ = exception$[exception]
END FUNCTION
'
'
' ##############################################
' #####  XstExceptionToSystemException ()  #####
' ##############################################
'
FUNCTION  XstExceptionToSystemException (exception, sysException)
'
	SHARED exception$[]
	IFZ exception$[] THEN InitExceptionArray()
'
	SELECT CASE exception
		CASE $$ExceptionSegmentViolation					: sysException = $$EXCEPTION_ACCESS_VIOLATION
		CASE $$ExceptionOutOfBounds								: sysException = $$EXCEPTION_ARRAY_BOUNDS_EXCEEDED
		CASE $$ExceptionBreakpoint								: sysException = $$EXCEPTION_BREAKPOINT
		CASE $$ExceptionBreakKey									: sysException = $$EXCEPTION_CONTROL_C_EXIT
		CASE $$ExceptionAlignment									: sysException = $$EXCEPTION_DATATYPE_MISALIGNMENT
		CASE $$ExceptionDenormal									: sysException = $$EXCEPTION_FLOAT_DENORMAL_OPERAND
		CASE $$ExceptionFloatDivideByZero					: sysException = $$EXCEPTION_FLOAT_DIVIDE_BY_ZERO
		CASE $$ExceptionInvalidOperation					: sysException = $$EXCEPTION_FLOAT_INVALID_OPERATION
		CASE $$ExceptionFloatOverflow							: sysException = $$EXCEPTION_FLOAT_OVERFLOW
		CASE $$ExceptionStackCheck								: sysException = $$EXCEPTION_FLOAT_STACK_CHECK
		CASE $$ExceptionUnderflow									: sysException = $$EXCEPTION_FLOAT_UNDERFLOW
		CASE $$ExceptionInvalidInstruction				: sysException = $$EXCEPTION_ILLEGAL_INSTRUCTION
		CASE $$ExceptionIntDivideByZero						: sysException = $$EXCEPTION_INT_DIVIDE_BY_ZERO
		CASE $$ExceptionIntOverflow								: sysException = $$EXCEPTION_INT_OVERFLOW
		CASE $$ExceptionPrivilege									: sysException = $$EXCEPTION_PRIV_INSTRUCTION
		CASE $$ExceptionStackOverflow							: sysException = $$EXCEPTION_STACK_OVERFLOW
		CASE $$ExceptionPrecision                 : sysException = $$EXCEPTION_FLOAT_INEXACT_RESULT
		CASE $$ExceptionGuardPage                 : sysException = $$EXCEPTION_GUARD_PAGE
		CASE $$ExceptionInPage                    : sysException = $$EXCEPTION_IN_PAGE_ERROR
		CASE $$ExceptionDisposition               : sysException = $$EXCEPTION_INVALID_DISPOSITION
		CASE $$ExceptionNoncontinuable            : sysException = $$EXCEPTION_NONCONTINUABLE_EXCEPTION
		CASE $$ExceptionSingleStep                : sysException = $$EXCEPTION_SINGLE_STEP
		CASE ELSE
			sysException = 0
			IF exception < 0 THEN RETURN
			IF exception > UBOUND(exception$[]) THEN RETURN
			IF exception$[exception] THEN
				sysException = $$ExceptionTypeError | $$ExceptionCodeUser | exception
			END IF
	END SELECT
END FUNCTION
'
'
'
'
' ##################################
' #####  XstRaiseException ()  #####
' ##################################
'
' exception is a native exception code or a user code registered through XstRegisterException()
'
' type is $$ExceptionTypeInformation, $$ExceptionTypeWarning, or $$ExceptionTypeError. If 0,
'            $$ExceptionTypeError is assumed. Valid only for user-registered exceptions
'
' arguments[] is an array of arguments to be passed to the .ExceptionInformation[] member
'            of an EXCEPTION_RECORD variable.  Maximum 15 ($$EXCEPTION_MAXIMUM_PARAMETERS)
'            elements; any extras are ignored.
'
FUNCTION  XstRaiseException (exception, type, arguments[])

	IF exception <= $$ExceptionUpper THEN	'native exception constant
			XstExceptionToSystemException (exception, @sysException)
		ELSE	'user-registered exception
			t = type & 0xC0000000
			IFZ t THEN t = $$ExceptionTypeError
			sysException = t | $$ExceptionCodeUser | exception
	END IF

	nArgs = UBOUND(arguments[]) + 1
	IF nArgs THEN
		IF nArgs > $$EXCEPTION_MAXIMUM_PARAMETERS THEN nArgs = $$EXCEPTION_MAXIMUM_PARAMETERS
		DIM args[nArgs-1]
		FOR i = 0 TO nArgs - 1
			args[i] = arguments[i]
		NEXT i
	END IF

	RaiseException (sysException, 0, nArgs, &args[])
END FUNCTION
'
'
'
'
' #####################################
' #####  XstRegisterException ()  #####
' #####################################
'
'
FUNCTION  XstRegisterException (exception$, exception)
	SHARED exception$[]
	IFZ exception$[] THEN InitExceptionArray()

	ex$ = TRIM$(exception$)
	IFZ ex$ THEN exception = $$ExceptionNone: RETURN

	FOR ex = ($$ExceptionUpper+1) TO UBOUND(exception$[])
		IFZ exception$[ex] GOTO emptySlot
		IF ex$ == exception$[ex] THEN exception = ex: RETURN
	NEXT ex
	REDIM exception$[ex+15]

emptySlot:
	exception$[ex] = ex$
	exception = ex
END FUNCTION
'
'
' ###########################################
' #####  XstSystemErrorNumberToName ()  #####
' ###########################################
'
FUNCTION  XstSystemErrorNumberToName (sysError, sysError$)
'
'	upper = UBOUND (#OSERROR$[])
'	IF ((sysError < 0) OR (sysError > upper)) THEN sysError$ = "Unknown System Error Number" : RETURN
'	sysError$ = #OSERROR$[sysError]

	IF sysError < 0 THEN sysError$ = "Unknown System Error Number" : RETURN

	sysError$ = NULL$(256)
	FormatMessageA ($$FORMAT_MESSAGE_FROM_SYSTEM, 0, sysError, 0, &sysError$, LEN(sysError$), 0)
	sysError$ = TRIM$(CSIZE$(sysError$))
	IFZ sysError$ THEN sysError$ = "Unknown System Error Name"

END FUNCTION
'
'
' ##############################################
' #####  XstSystemExceptionToException ()  #####
' ##############################################
'
FUNCTION  XstSystemExceptionToException (sysException, exception)
'
	SHARED exception$[]
	IFZ exception$[] THEN InitExceptionArray()
'
	IF sysException & $$ExceptionCodeUser THEN
		exception = sysException & 0x0FFFFFFF
		IF exception > UBOUND(exception$[]) THEN exception = $$ExceptionUnknown
		RETURN
	END IF
'
	SELECT CASE sysException
		CASE $$EXCEPTION_ACCESS_VIOLATION					: exception = $$ExceptionSegmentViolation
		CASE $$EXCEPTION_ARRAY_BOUNDS_EXCEEDED		: exception = $$ExceptionOutOfBounds
		CASE $$EXCEPTION_BREAKPOINT								: exception = $$ExceptionBreakpoint
		CASE $$EXCEPTION_CONTROL_C_EXIT						: exception = $$ExceptionBreakKey
		CASE $$EXCEPTION_DATATYPE_MISALIGNMENT		: exception = $$ExceptionAlignment
		CASE $$EXCEPTION_FLOAT_DENORMAL_OPERAND		: exception = $$ExceptionDenormal
		CASE $$EXCEPTION_FLOAT_DIVIDE_BY_ZERO			: exception = $$ExceptionFloatDivideByZero
		CASE $$EXCEPTION_FLOAT_INEXACT_RESULT			: exception = $$ExceptionPrecision
		CASE $$EXCEPTION_FLOAT_INVALID_OPERATION	: exception = $$ExceptionInvalidOperation
		CASE $$EXCEPTION_FLOAT_OVERFLOW						: exception = $$ExceptionFloatOverflow
		CASE $$EXCEPTION_FLOAT_STACK_CHECK				: exception = $$ExceptionStackCheck
		CASE $$EXCEPTION_FLOAT_UNDERFLOW					: exception = $$ExceptionUnderflow
		CASE $$EXCEPTION_GUARD_PAGE								: exception = $$ExceptionGuardPage
		CASE $$EXCEPTION_ILLEGAL_INSTRUCTION			: exception = $$ExceptionInvalidInstruction
		CASE $$EXCEPTION_IN_PAGE_ERROR						: exception = $$ExceptionInPage
		CASE $$EXCEPTION_INT_DIVIDE_BY_ZERO				: exception = $$ExceptionIntDivideByZero
		CASE $$EXCEPTION_INT_OVERFLOW							: exception = $$ExceptionIntOverflow
		CASE $$EXCEPTION_INVALID_DISPOSITION      : exception = $$ExceptionDisposition
		CASE $$EXCEPTION_NONCONTINUABLE_EXCEPTION : exception = $$ExceptionNoncontinuable
		CASE $$EXCEPTION_PRIV_INSTRUCTION					: exception = $$ExceptionPrivilege
		CASE $$EXCEPTION_SINGLE_STEP							: exception = $$ExceptionSingleStep
		CASE $$EXCEPTION_STACK_OVERFLOW						: exception = $$ExceptionStackOverflow
		CASE ELSE																	: exception = $$ExceptionUnknown
	END SELECT
END FUNCTION
'
'
' ######################################
' #####  XstSystemErrorToError ()  #####
' ######################################
'
' Move system error to high word of error value.
'
FUNCTION  XstSystemErrorToError (sysError, @error)

'	upper = UBOUND (#OSTOXERROR[])
'	error = ($$ErrorObjectSystem << 8) OR $$ErrorNatureError
'	IF ((sysError < 0) OR (sysError > upper)) THEN RETURN
'	error = #OSTOXERROR[sysError]

	error = ($$ErrorObjectSystem << 8) OR $$ErrorNatureError
	IF (sysError < 0) THEN RETURN
	error = sysError << 16

END FUNCTION
'
'
' ###############################################
' #####  XstSystemExceptionNumberToName ()  #####
' ###############################################
'
FUNCTION  XstSystemExceptionNumberToName (sysException, sysException$)
'
	SHARED exception$[]
	IFZ exception$[] THEN InitExceptionArray()
'
	IF sysException & $$ExceptionCodeUser THEN
		exception = sysException & 0x0FFFFFFF
		IF exception <= UBOUND(exception$[]) THEN
				sysException$ = exception$[exception]
			ELSE
				sysException$ = "Unknown User Exception"
		END IF
		RETURN
	END IF
'
	SELECT CASE sysException
		CASE $$EXCEPTION_ACCESS_VIOLATION					: sysException$ = "Access Violation"
		CASE $$EXCEPTION_ARRAY_BOUNDS_EXCEEDED		: sysException$ = "Bounds Error"
		CASE $$EXCEPTION_BREAKPOINT								: sysException$ = "Breakpoint"
		CASE $$EXCEPTION_CONTROL_C_EXIT						: sysException$ = "Control C Break"
		CASE $$EXCEPTION_DATATYPE_MISALIGNMENT		: sysException$ = "Data Misaligned"
		CASE $$EXCEPTION_FLOAT_DENORMAL_OPERAND		: sysException$ = "Denormal Operand"
		CASE $$EXCEPTION_FLOAT_DIVIDE_BY_ZERO			: sysException$ = "Divide by Zero"
		CASE $$EXCEPTION_FLOAT_INEXACT_RESULT			: sysException$ = "Inexact Result"
		CASE $$EXCEPTION_FLOAT_INVALID_OPERATION	: sysException$ = "Invalid Operation"
		CASE $$EXCEPTION_FLOAT_OVERFLOW						: sysException$ = "Overflow"
		CASE $$EXCEPTION_FLOAT_STACK_CHECK				: sysException$ = "Stack Check"
		CASE $$EXCEPTION_FLOAT_UNDERFLOW					: sysException$ = "Underflow"
		CASE $$EXCEPTION_GUARD_PAGE								: sysExcetions$ = "Guard Page"
		CASE $$EXCEPTION_ILLEGAL_INSTRUCTION			: sysException$ = "Invalid Instruction"
		CASE $$EXCEPTION_IN_PAGE_ERROR						: sysException$ = "In Page Error"
		CASE $$EXCEPTION_INT_DIVIDE_BY_ZERO				: sysException$ = "Integer Divide by Zero"
		CASE $$EXCEPTION_INT_OVERFLOW							: sysException$ = "Integer Overflow"
		CASE $$EXCEPTION_INVALID_DISPOSITION			: sysException$ = "Invalid Disposition"
		CASE $$EXCEPTION_NONCONTINUABLE_EXCEPTION	: sysException$ = "Fatal Exception"
		CASE $$EXCEPTION_PRIV_INSTRUCTION					: sysException$ = "Privilege Violation"
		CASE $$EXCEPTION_SINGLE_STEP							: sysException$ = "Single Step"
		CASE $$EXCEPTION_STACK_OVERFLOW						: sysException$ = "Stack Overflow"
		CASE ELSE																	: sysException$ = "Unknown System Exception"
	END SELECT
'
END FUNCTION
'
'
' ##################################
' #####  XstGetSystemError ()  #####
' ##################################
'
FUNCTION  XstGetSystemError (sysError)
	sysError = GetLastError ()
END FUNCTION
'
'
' ##################################
' #####  XstSetSystemError ()  #####
' ##################################
'
FUNCTION  XstSetSystemError (sysError)
	SetLastError (sysError)
END FUNCTION
'
'
' ################################
' #####  XstGetException ()  #####
' ################################
'
FUNCTION  XstGetException (exception)
	EXTERNAL	##EXCEPTION
	exception = ##EXCEPTION
END FUNCTION
'
'
' ########################################
' #####  XstGetExceptionFunction ()  #####
' ########################################
'
FUNCTION  XstGetExceptionFunction (function)
	SHARED	exceptionFunction
'
	function = exceptionFunction
END FUNCTION
'
'
' ################################
' #####  XstSetException ()  #####
' ################################
'
FUNCTION  XstSetException (exception)
	EXTERNAL ##EXCEPTION
	##EXCEPTION = exception
END FUNCTION
'
'
' ########################################
' #####  XstSetExceptionFunction ()  #####
' ########################################
'
FUNCTION  XstSetExceptionFunction (function)
	SHARED	exceptionFunction
'
	exceptionFunction = function
END FUNCTION
'
'
' ##########################################
' #####  XstGetEnvironmentVariable ()  #####
' ##########################################
'
FUNCTION  XstGetEnvironmentVariable (name$, @value$)
'
	value$ = ""
	IFZ name$ THEN RETURN ($$TRUE)
'
	value$ = NULL$ (4095)
	length = GetEnvironmentVariableA (&name$, &value$, 4095)
	IF (length < 0) THEN
		value$ = ""
	ELSE
'		value$ = LEFT$ (value$, length)
		value$ = MID$ (value$, 1, length)
	END IF
END FUNCTION
'
'
' #######################
' #####  HIWORD ()  #####
' #######################
'
FUNCTION  HIWORD (x)

RETURN x{{16,16}}

END FUNCTION
'
'
' #######################
' #####  LOWORD ()  #####
' #######################
'
FUNCTION  LOWORD (x)

RETURN x{{16,0}}

END FUNCTION
'
'
' #########################
' #####  MAKELONG ()  #####
' #########################
'
FUNCTION  MAKELONG (lo, hi)

	RETURN lo | (hi << 16)

END FUNCTION
'
'
' ####################
' #####  RGB ()  #####
' ####################
'
FUNCTION  RGB (r, g, b)

	IF r > 255 THEN r = 255
	IF g > 255 THEN g = 255
	IF b > 255 THEN b = 255

	RETURN r | (g << 8) | (b << 16)

END FUNCTION
'
'
' ####################################
' #####  XstFileToSystemFile ()  #####
' ####################################
'
FUNCTION  XstFileToSystemFile (fileNumber, systemFileNumber)
	SHARED  FILE  fileInfo[]
'
	systemFileNumber = 0
	IF fileInfo[] THEN
		upper = UBOUND (fileInfo[])
		IF (fileNumber <= upper) THEN
			fileHandle = fileInfo[fileNumber].fileHandle
			IF fileHandle THEN systemFileNumber = fileHandle
		END IF
	END IF
END FUNCTION
'
'
' ###################################
' #####  XstLockFileSection ()  #####
' ###################################
'
FUNCTION  XstLockFileSection (file, mode, offset$$, length$$)
	SHARED  LOCK  fileLock[]
	SHARED  FILE  fileInfo[]
	AUTOX  LOCK  lock[]
'
	IF (file <= 2) THEN
		lastErr = ERROR (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid)
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND (fileInfo[])
	IF (file > upper) THEN
		lastErr = ERROR (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid)
		RETURN ($$TRUE)
	END IF
'
	IF (offset$$ < 0) THEN
		lastErr = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue)
		RETURN ($$TRUE)
	END IF
'
	IF (length$$ < 0) THEN
		lastErr = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue)
		RETURN ($$TRUE)
	END IF
'
	sfile = fileInfo[file].fileHandle
'
	IF (sfile <= 0) THEN
		lastErr = ERROR (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid)
		RETURN ($$TRUE)
	END IF
'
	IFZ fileLock[] THEN
		upper = (file + 16) OR 0x000F
		DIM fileLock[upper,]
	END IF
'
	upper = UBOUND (fileLock[])
	IF (upper < file) THEN
		upper = (file + 16) OR 0x000F
		REDIM fileLock[upper,]
	END IF
'
	IFZ fileLock[file,] THEN
		DIM lock[3]
		ATTACH lock[] TO fileLock[file,]
	END IF
'
	slot = -1
	overlap = $$FALSE
	begin$$ = offset$$
	end$$ = offset$$ + length$$ - 1$$
	IFZ length$$ THEN end$$ = 0x7FFFFFFFFFFFFFFF
	upper = UBOUND (fileLock[file,])
'
	FOR i = 0 TO upper
		IFZ fileLock[file,i].file THEN
			IF (slot < 0) THEN slot = i
		ELSE
			first$$ = fileLock[file,i].offset
			final$$ = first$$ + fileLock[file,i].length - 1$$
			IF (final$$ < first$$) THEN final$$ = 0x7FFFFFFFFFFFFFFF
			IF ((begin$$ <= final$$) AND (end$$ >= first$$)) THEN INC overlap
		END IF
	NEXT i
'
' if the new section overlaps an existing section, that's an error
'
	IF overlap THEN
		lastErr = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidRequest)
		RETURN ($$TRUE)
	END IF
'
' lock the new section
'
	offsetLow = GLOW (begin$$)
	offsetHigh = GHIGH (begin$$)
	lengthLow = GLOW (end$$ - begin$$ + 1)
	lengthHigh = GHIGH (end$$ - begin$$ + 1)
'
	okay = LockFile (sfile, offsetLow, offsetHigh, lengthLow, lengthHigh)
'
	IFZ okay THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IF (slot < 0) THEN
		slot = upper + 1
		upper = upper + 4
		ATTACH fileLock[file,] TO lock[]
		REDIM lock[upper]
		ATTACH lock[] TO fileLock[file,]
	END IF
'
' log the newly locked section
'
	fileLock[file,slot].file = file
	fileLock[file,slot].sfile = sfile
	fileLock[file,slot].offset = offset$$
	fileLock[file,slot].length = length$$
	fileLock[file,slot].end = end$$
END FUNCTION
'
'
' #####################################
' #####  XstUnlockFileSection ()  #####
' #####################################
'
FUNCTION  XstUnlockFileSection (file, mode, offset$$, length$$)
	SHARED  LOCK  fileLock[]
	SHARED  FILE  fileInfo[]
	AUTOX  LOCK  lock[]
'
	IF (file <= 2) THEN
		lastErr = ERROR (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid)
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND (fileInfo[])
	IF (file > upper) THEN
		lastErr = ERROR (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent)
		RETURN ($$TRUE)
	END IF
'
	IF (offset$$ < 0) THEN
		lastErr = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue)
		RETURN ($$TRUE)
	END IF
'
	IF (length$$ < 0) THEN
		lastErr = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue)
		RETURN ($$TRUE)
	END IF
'
	sfile = fileInfo[file].fileHandle
'
	IF (sfile <= 0) THEN
		lastErr = ERROR (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent)
		RETURN ($$TRUE)
	END IF
'
	IFZ fileLock[] THEN
		upper = (file + 16) OR 0x000F
		DIM fileLock[upper,]
	END IF
'
	upper = UBOUND (fileLock[])
	IF (upper < file) THEN
		upper = (file + 16) OR 0x000F
		REDIM fileLock[upper,]
	END IF
'
	IFZ fileLock[file,] THEN
		lastErr = ERROR (($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument)
		RETURN ($$TRUE)
	END IF
'
	slot = -1
	begin$$ = offset$$
	end$$ = offset$$ + length$$ - 1$$
	IFZ length$$ THEN end$$ = 0x7FFFFFFFFFFFFFFF
	upper = UBOUND (fileLock[file,])
'
	found = $$FALSE
	FOR i = 0 TO upper
		IF fileLock[file,i].file THEN
			IF fileLock[file,i].sfile THEN
				IF (offset$$ = fileLock[file,i].offset) THEN
					IF (length$$ = fileLock[file,i].length) THEN
						found = $$TRUE
						EXIT FOR
					END IF
				END IF
			END IF
		END IF
	NEXT i
'
' if specified section not found in lock list
'
	IFZ found THEN
		lastErr = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidRequest)
		RETURN ($$TRUE)
	END IF
'
' found the specified locked section - unlock it
'
	begin$$ = offset$$
	end$$ = fileLock[file,i].end
	offsetLow = GLOW (begin$$)
	offsetHigh = GHIGH (begin$$)
	lengthLow = GLOW (end$$ - begin$$ + 1)
	lengthHigh = GHIGH (end$$ - begin$$ + 1)
'
	okay = UnlockFile (sfile, offsetLow, offsetHigh, lengthLow, lengthHigh)
'
	IFZ okay THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	fileLock[file,i].file = 0
	fileLock[file,i].sfile = 0
	fileLock[file,i].offset = 0
	fileLock[file,i].length = 0
	fileLock[file,i].end = 0
END FUNCTION
'
'
' ###############################
' #####  XstPathString$ ()  #####
' ###############################
'
FUNCTION  XstPathString$ (path$)
	SHARED  UBYTE  charsetFilename[]
	SHARED  UBYTE  charsetFilenameFirstLast[]
'
	IFZ charsetFilename[] THEN GOSUB Initialize
'
	IFZ path$ THEN RETURN ("")
'
	upper = UBOUND (path$)
	name$ = NULL$ (upper+1)
'
	first = 0
	DO UNTIL charsetFilenameFirstLast[path${first}]
		INC first
	LOOP UNTIL (first > upper)
'
	IF (first > upper) THEN RETURN ("")
'
	final = first + 1
	IF (first < upper) THEN
		DO WHILE charsetFilename[path${final}]
			INC final
		LOOP UNTIL (final > upper)
	END IF
'
	DO WHILE (final > first)
		DEC final
	LOOP UNTIL charsetFilenameFirstLast[path${final}]
'
	length = final - first + 1
	p$ = NULL$ (length)
'
	FOR i = 0 TO length-1
		p${i} = charsetFilename[path${first}]
		INC first
	NEXT i
'
	term$ = $$PathSlash$ + "$"
	total = LEN (p$)
	offset = 0
	DO
		first = INSTR (p$, "$", offset+1)								' $NAME or $(NAME) form
		IFZ first THEN EXIT DO
		IF (p${first} = '(') THEN												' $(NAME) form probably
			after = INSTR (p$, ")", first+2)							' find ) name terminator
			IFZ after THEN EXIT DO												' $( without ) - ignore
			offset = after																' move past $NAME
			variable$ = MID$ (p$, first+2, after-first-2)	' environment variable
			IFZ variable$ THEN DO LOOP										' ignore $()
		ELSE																						' $NAME form
'			after = INCHR (p$, term$, first+1)						' find / or $ to terminate name
' *****
' note: trying to eliminate use of INCHR in Xst library
			after = INSTR (p$, $$PathSlash$, first+1)
			IFZ after THEN after = INSTR (p$, "$", first+1)
' *****
      IFZ after THEN after = LEN (p$) + 1					  ' $NAME past end of string
			offset = after																' move past $NAME
			variable$ = MID$ (p$, first+1, after-first-1)	' environment variable
			IFZ variable$ THEN DO LOOP										' ignore $/
			DEC after
		END IF
		XstGetEnvironmentVariable (@variable$, @value$)
		IFZ value$ THEN DO LOOP
'		a$ = LEFT$ (p$, first-1)
		a$ = MID$ (p$, 1, first-1)
		c$ = MID$ (p$, after+1)
		p$ = a$ + value$ + c$
		total = LEN (p$)
		offset = LEN (a$) + LEN (value$)
	LOOP WHILE (offset < total)
'
' process "/./" (nop)
'
	nop$ = $$PathSlash$ + "." + $$PathSlash$
	DO
		nop = INSTR (p$, nop$)
'		IF nop THEN p$ = LEFT$(p$,nop) + MID$(p$,nop+3)		' "/./" to "/"
		IF nop THEN p$ = MID$(p$,1,nop) + MID$(p$,nop+3)
	LOOP WHILE nop
'
' process "/../" (parent)
'
	parent$ = $$PathSlash$ + ".." + $$PathSlash$
	DO
		parent = INSTR (p$, parent$)

		IF parent THEN
			IF (parent = 1) THEN
				p$ = MID$ (p$, 4)																	' path starts "/../"  - change to "/"
			ELSE
				slash = RINSTR (p$, $$PathSlash$, parent-1)				' find / before "/../"
'				p$ = LEFT$ (p$, slash) + MID$ (p$, parent + 4)		' remove parent directory
				p$ = MID$ (p$, 1, slash) + MID$ (p$, parent + 4)
			END IF
		END IF
	LOOP WHILE parent
'
	RETURN (p$)
'
'
' *****  Initialize  *****
'
SUB Initialize
'
	DIM charsetFilename[255]
	DIM charsetFilenameFirstLast[255]
'
	FOR i = 0x20 TO 0xFF
		charsetFilename[i] = i
		charsetFilenameFirstLast[i] = i
	NEXT i
'
	charsetFilename['/'] = charsetFilename['\\']		' windows
'	charsetFilename['\\'] = charsetFilename['/']		' unix
	charsetFilename['"'] = 0
	charsetFilename['<'] = 0
	charsetFilename['>'] = 0
'	charsetFilename[':'] = 0
	charsetFilename['|'] = 0
	charsetFilenameFirstLast['/'] = '\\'	' path separator character (windows)
'	charsetFilenameFirstLast['\\'] = '/'	' path separator character (unix)
	charsetFilenameFirstLast[' '] = 0			' no leading/trailing spaces
	charsetFilenameFirstLast['"'] = 0			' no leading/trailing """
	charsetFilenameFirstLast['<'] = 0			' no leading/trailing "<"
	charsetFilenameFirstLast['>'] = 0			' no leading/trailing ">"
'	charsetFilenameFirstLast[':'] = 0			' no leading/trailing ":"
	charsetFilenameFirstLast['|'] = 0			' no leading/trailing "|"
END SUB
END FUNCTION
'
'
' ################################
' #####  XstCenterWindow ()  #####
' ################################
'
' PURPOSE	:	Center a window in the screen area.
' IN			: hWnd	- handle of window
' RETURN	:	zero on success, -1 on failure
'
FUNCTION  XstCenterWindow (hWnd)
	RECT rect
	IFZ IsWindow(hWnd) THEN
		lastErr = ERROR ($$ErrorNatureInvalidValue)
 		RETURN ($$TRUE)
	END IF
	GetWindowRect (hWnd, &rect)
	#screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	#screenHeight = GetSystemMetrics ($$SM_CYSCREEN)
	x = (#screenWidth - (rect.right - rect.left))/2
	IF x < 0 THEN x = 0
	y = (#screenHeight - (rect.bottom - rect.top))/2
	IF y < 0 THEN y = 0
	IFZ SetWindowPos (hWnd, 0, x, y, 0, 0, $$SWP_NOSIZE OR $$SWP_NOZORDER) THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' ##################################
' #####  XxxXstFreeLibrary ()  #####
' ##################################
'
FUNCTION  XxxXstFreeLibrary (lib$, handle)

	SHARED  libraryName$[]
	SHARED  libraryHandle[]
'
	IFZ libraryName$[] THEN RETURN
	upper = UBOUND (libraryName$[])
'
	FOR i = 0 TO upper
		name$ = libraryName$[i]
		hand = libraryHandle[i]
		free = $$FALSE
		IF name$ THEN
			IF hand THEN
				SELECT CASE TRUE
					CASE (handle = -1)		:	free = $$TRUE
					CASE (handle = hand)	:	free = $$TRUE
					CASE (lib$ = name$)		:	free = $$TRUE
				END SELECT
			END IF
		END IF
		IF free THEN
			FreeLibrary (hand)
			libraryName$[i] = ""
			libraryHandle[i] = 0
		END IF
	NEXT i

END FUNCTION
'
'
' ##################################
' #####  XxxXstLoadLibrary ()  #####
' ##################################
'
FUNCTION  XxxXstLoadLibrary (lib$)

	SHARED  libraryName$[]
	SHARED  libraryHandle[]
'
	IFZ lib$ THEN RETURN
'
	upper = UBOUND (lib$)
'	IF (lib${upper} = '"') THEN lib$ = RCLIP$ (lib$,1)
'	IF (lib${0} = '"') THEN lib$ = LCLIP$ (lib$,1)
'
	IF (lib${upper} = '"') THEN lib$ = MID$ (lib$,1,upper)
	IF (lib${0} = '"') THEN lib$ = MID$ (lib$,2)
'
	IFZ libraryName$[] THEN GOSUB Initialize
	upper = UBOUND (libraryName$[])
	handle = 0
	slot = -1
'
	FOR i = 0 TO upper
		name$ = libraryName$[i]
		hand = libraryHandle[i]
		IF (slot < 0) THEN
			IFZ name$ THEN slot = i : hand = 0
			IFZ hand THEN slot = i : name$ = ""
		END IF
		IFZ handle THEN
			IF name$ THEN
				IF hand THEN
					IF (lib$ = name$) THEN handle = hand
				END IF
			END IF
		END IF
	NEXT i
'
	IF handle THEN RETURN (handle)
'
	handle = LoadLibraryA (&lib$)		' returns 0 when fails
'
	IF handle THEN
		IF (slot < 0) THEN
			slot = upper + 1
			upper = upper + 16
			REDIM libraryName$[upper]
			REDIM libraryHandle[upper]
		END IF
		libraryName$[slot] = lib$
		libraryHandle[slot] = handle
	END IF
'
	RETURN (handle)
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM libraryName$[15]
	DIM libraryHandle[15]
END SUB

END FUNCTION
'
'
' ############################
' #####  InitProgram ()  #####
' ############################
'
FUNCTION  InitProgram ()
'
	STATIC	initiated

	EXTERNAL ##EXCEPTION_MEMORY_ALLOCATION
	EXTERNAL ##EXCEPTION_INT_OVERFLOW
	EXTERNAL ##EXCEPTION_OUT_OF_BOUNDS
	EXTERNAL ##EXCEPTION_NODE_NOT_EMPTY
	EXTERNAL ##EXCEPTION_ARRAY_DIMENSION
	EXTERNAL ##EXCEPTION_INVALID_ARGUMENT

	IF initiated THEN RETURN
	initiated = $$TRUE

	##EXCEPTION_MEMORY_ALLOCATION = $$ExceptionMemoryAllocation
	##EXCEPTION_INT_OVERFLOW      = $$ExceptionIntOverflow
	##EXCEPTION_OUT_OF_BOUNDS     = $$ExceptionOutOfBounds
	##EXCEPTION_NODE_NOT_EMPTY    = $$ExceptionNodeNotEmpty
	##EXCEPTION_ARRAY_DIMENSION   = $$ExceptionArrayDimension
	##EXCEPTION_INVALID_ARGUMENT  = $$ExceptionInvalidArgument

END FUNCTION
'
'
' ##################################
' #####  InvalidFileNumber ()  #####
' ##################################
'
FUNCTION  InvalidFileNumber (fileNumber)
	SHARED  FILE  fileInfo[]

	IFZ fileInfo[] THEN GOTO eeeBadFileNumber
	uFile = UBOUND(fileInfo[])
	IF (fileNumber > uFile) THEN GOTO eeeBadFileNumber
	IF (fileNumber < 1) THEN GOTO eeeBadFileNumber
	fileHandle = fileInfo[fileNumber].fileHandle
	IFZ fileHandle THEN GOTO eeeBadFileNumber
	RETURN ($$FALSE)

eeeBadFileNumber:
	lastErr = ERROR ((($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument))
	RETURN ($$TRUE)
END FUNCTION
'
'
' #######################
' #####  XxxEof ()  #####
' #######################
'
'
'	Return TRUE if current file pointer is beyond the end of file
'
'	In:				fileNumber		File Number
'	Out:			none--arg unchanged
'	Return:		$$TRUE		file at EOF
'						$$FALSE		file not at EOF
'						$$TRUE		error (##ERROR is set)		**** this must be resolved
'
'	The return values of TRUE and -max are ambiguous if tested with
'		"IF Eof(fileNumber) THEN".  User should test explicitely.
'		(Note that action based on EOF is usually consistent with that for error.)
'
FUNCTION  XxxEof (fileNumber)

	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)			' Console Grid
'
	c = SetFilePointer (fileHandle, 0, 0, $$FILE_CURRENT)	' get file position
	IF (c = -1) THEN GOTO SeekError
	s = SetFilePointer (fileHandle, 0, 0, $$FILE_END)			' get size of file
	IF (s = -1) THEN GOTO SeekError
	a = SetFilePointer (fileHandle, c, 0, $$FILE_BEGIN)		' restore file position
	IF (a = -1) THEN GOTO SeekError
'
	IF (c >= s) THEN RETURN ($$TRUE) ELSE RETURN ($$FALSE)
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XxxWriteFile ()  #####
' #############################
'
'	In:				fileNumber		File Number
'						buffer
'						bytes					to be written
'						bytesWritten
'						overlapped		NULL
'	Out:			none--arg unchanged
'
'	Valid on console grids for now
'	xlibs.s calls XxxWriteFile() for stdout
'
FUNCTION  XxxWriteFile (fileNumber, buffer, bytes, bytesWritten, overlapped)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IFZ bytes THEN RETURN ($$TRUE)
	IF InvalidFileNumber(fileNumber) THEN
		IF (fileNumber != 1) THEN RETURN ($$FALSE)
		IFZ fileInfo[] THEN RETURN ($$FALSE)
		IFZ fileInfo[1].fileHandle THEN RETURN ($$FALSE)		' not initialized
	END IF
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN						' console
		fileHandle = GetStdHandle ($$STD_OUTPUT_HANDLE)
		IF fileHandle = $$INVALID_HANDLE_VALUE THEN GOSUB Error
		IFZ WriteFile (fileHandle, buffer, bytes, &bytesWritten, 0) THEN GOSUB Error
		RETURN ($$FALSE)
	END IF
'
	IFZ WriteFile (fileHandle, buffer, bytes, @bytesWritten, overlapped) THEN GOSUB Error
'
' ***** Error *****
SUB Error
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
		RETURN ($$TRUE)
END SUB
END FUNCTION
'
'
' ############################
' #####  XxxReadFile ()  #####
' ############################

'	In:				fileNumber		File Number
'						buffer
'						bytes					to be written
'						bytesRead
'						overlapped		NULL
'
'	Invalid on console windows
'
FUNCTION  XxxReadFile (fileNumber, buffer, bytes, bytesRead, overlapped)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IFZ bytes THEN RETURN ($$TRUE)
	IF InvalidFileNumber(fileNumber) THEN
		IF (fileNumber != 1) THEN RETURN ($$FALSE)
		IFZ fileInfo[] THEN RETURN ($$FALSE)
		IFZ fileInfo[1].fileHandle THEN RETURN ($$FALSE)		' not initialized
	END IF
	fileHandle = fileInfo[fileNumber].fileHandle
'
	IF (fileHandle = -1) THEN RETURN ($$FALSE)						' can't read from console window
'
	result = ReadFile (fileHandle, buffer, bytes, @bytesRead, overlapped)
'
	IFZ result THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' #########################
' #####  XxxClose ()  #####
' #########################

'	In:				fileNumber		File number
'						$$ALL					(-1)  Close all files
'
'	Out:			none		(arg unchanged)
'
'	Return:		$$TRUE		error (##ERROR is set)
'						$$FALSE		no error
'
'	User can only close user files
'
FUNCTION  XxxClose (fileNumber)
	EXTERNAL  errno
	SHARED  FILE  fileInfo[]
	SHARED  LOCK  fileLock[]
'
	IFZ fileInfo[] THEN
		IF (fileNumber != -1) THEN GOTO eeeBadFileNumber
		RETURN ($$FALSE)
	END IF
'
	err = $$FALSE
	lastErr = ERROR ($$FALSE)
	uFile = UBOUND(fileInfo[])
	IF (fileNumber = $$ALL) THEN
		firstNumber = 1

		FOR fileNumber = firstNumber TO uFile
			fileHandle = fileInfo[fileNumber].fileHandle
			IFZ fileHandle THEN DO NEXT
			GOSUB CloseFileHandle
		NEXT fileNumber
		fileNumber = $$ALL
	ELSE
		IF InvalidFileNumber(fileNumber) THEN RETURN ($$FALSE)
		fileHandle = fileInfo[fileNumber].fileHandle
		GOSUB CloseFileHandle
	END IF
	RETURN (err)
'
SUB CloseFileHandle
	consoleGrid = fileInfo[fileNumber].consoleGrid
	IFZ consoleGrid THEN
		IF fileLock[] THEN
			IF (file <= UBOUND (fileLock[]))
				IF fileLock[file,] THEN
					FOR i = 0 TO UBOUND (fileLock[file,])
						IF fileLock[file,i].file THEN
							IF fileLock[file,i].sfile THEN
								offset$$ = fileLock[file,i].offset
								length$$ = fileLock[file,i].length
								XstUnlockFileSection (file, 0, offset$$, length$$)
							END IF
						END IF
					NEXT i
				END IF
			END IF
		END IF
		a = CloseHandle (fileHandle)
		IFZ a THEN
			GOSUB CloseError
		ELSE
			fileInfo[fileNumber].fileName			= ""
			fileInfo[fileNumber].fileHandle		= 0
			fileInfo[fileNumber].consoleGrid	= 0
			fileInfo[fileNumber].entries			= 0
		END IF
	ELSE
		DEC fileInfo[fileNumber].entries
		IF (fileInfo[fileNumber].entries > 0) THEN EXIT SUB
		fileInfo[fileNumber].fileName			= ""
		fileInfo[fileNumber].fileHandle		= 0
		fileInfo[fileNumber].consoleGrid	= 0
		fileInfo[fileNumber].entries			= 0
	END IF
END SUB
'
SUB CloseError
	errno	= GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	err = $$TRUE
END SUB
'
eeeBadFileNumber:
	error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' #######################
' #####  XxxLof ()  #####
' #######################
'
'	RETURN	0...	length of file
'					-1		error (##ERROR is set on error)
'
FUNCTION  XxxLof (fileNumber)
	EXTERNAL  errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)			' Console Grid
'
	c = SetFilePointer (fileHandle, 0, 0, $$FILE_CURRENT)		' get file pointer
	IF (c = -1) THEN GOTO SeekError
	s = SetFilePointer (fileHandle, 0, 0, $$FILE_END)				' get size of file
	IF (s = -1) THEN GOTO SeekError
	a = SetFilePointer (fileHandle, c, 0, $$FILE_BEGIN)			' restore file pointer
	IF (a = -1) THEN GOTO SeekError
	RETURN (s)
'
'	Error
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ########################
' #####  XxxOpen ()  #####
' ########################

'	Open a file, return a fileNumber
'
'	in			: filename$		May include absolute or relative path
'												MUST NOT FREE filename$ (%_open.s must do so)
'	out			: none				(args unaltered)
'	return	: 1...				File Number
'						-1					error (##ERROR is set)
'
'	$$RD			Open existing file for reading only.		Error if file doesn't exist.
'	$$WR			Open existing file for writing only.		Error if file doesn't exist.
'	$$RW			Open existing file for read/write.			Error if file doesn't exist.
'	$$WRNEW		Open new file for writing.  						If file exists, delete it first.
'	$$RWNEW		Open new file for read/write.						If file exists, delete it first.
'	$$NOSHARE Let no other processes access this file.
'	$$RDSHARE Let other processes read this file.
'	$$WRSHARE	Let other processes write this file.
'	$$RWSHARE	Let other processes read/write this file.
'
'	filename$ = "CON:" is a win32 console
'
FUNCTION  XxxOpen (filename$, mode)
	EXTERNAL  errno
	SHARED  FILE  fileInfo[]
'
	okay = $$TRUE
	f$ = TRIM$(filename$)
'
	IF f$ = "CON:" THEN
		IF fileInfo[] THEN
			FOR fileNumber = 1 TO UBOUND(fileInfo[])
				IFZ fileInfo[fileNumber].fileHandle THEN DO NEXT
				IF (f$ = TRIM$(fileInfo[fileNumber].fileName)) THEN
					INC fileInfo[fileNumber].entries
					RETURN (fileNumber)
				END IF
			NEXT fileNumber
		END IF
		fileHandle = -1						' Windows HANDLEs are never -1
	ELSE
		f$ = XstPathString$ (@f$)
		ntShare = (mode >> 4) AND 0x0003
		SELECT CASE (mode AND 0x0007)
			CASE $$RD			:	ntMode		= $$GENERIC_READ
											ntCreate	= $$OPEN_EXISTING
			CASE $$WR			:	ntMode		= $$GENERIC_WRITE
											IF f$ = "CON" THEN
												ntCreate= $$OPEN_EXISTING
											ELSE
											  ntCreate= $$OPEN_ALWAYS
											END IF
			CASE $$RW			:	ntMode		= $$GENERIC_READ | $$GENERIC_WRITE
											ntCreate	= $$OPEN_ALWAYS
			CASE $$WRNEW	:	ntMode		= $$GENERIC_WRITE
											ntCreate	= $$CREATE_ALWAYS
			CASE $$RWNEW	:	ntMode		= $$GENERIC_READ | $$GENERIC_WRITE
											ntCreate	= $$CREATE_ALWAYS
		END SELECT
'
		fileHandle = CreateFileA (&f$, ntMode, ntShare, 0, ntCreate, $$FILE_ATTRIBUTE_NORMAL, 0)
'
		IF (fileHandle = -1) THEN okay = $$FALSE
'
	END IF
'
	IF okay THEN
		IFZ fileInfo[] THEN
			DIM fileInfo[15]
		END IF
'
		IF (f$ = "CON:") THEN
			fileNumber = 1
		ELSE
			uFile = UBOUND(fileInfo[])
			FOR fileNumber = 3 TO uFile
				IFZ fileInfo[fileNumber].fileHandle THEN EXIT FOR		' Find an open slot
			NEXT fileNumber
			IF (fileNumber > uFile) THEN													' No room at the inn
				uFile = (uFile << 1) OR 3
				REDIM fileInfo[uFile]
			END IF
		END IF
'
		fileInfo[fileNumber].fileName    = f$
		fileInfo[fileNumber].fileHandle  = fileHandle
		fileInfo[fileNumber].consoleGrid = 0
		fileInfo[fileNumber].entries     = 1
'
		RETURN (fileNumber)
	END IF
'
	errno = GetLastError ()
'
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' #######################
' #####  XxxPof ()  #####
' #######################
'
'	RETURN	0...	current position
'					-1		error (##ERROR is set on error)
'
FUNCTION  XxxPof (fileNumber)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)			' Console Grid
'
	a = SetFilePointer (fileHandle, 0, 0, $$FILE_CURRENT)
	IF (a = -1) THEN GOTO SeekError
	RETURN (a)
'
'	Error
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ###########################
' #####  XxxInfile$ ()  #####
' ###########################

'	RETURN	line$		File string
'					""			End of file (##ERROR = $$ErrorEndOfFile)
'					""			error (##ERROR is set on error)

FUNCTION  XxxInfile$ (fileNumber)
	AUTOX  bytesRead
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber(fileNumber) THEN
		IF (fileNumber != 1) THEN RETURN ("")
		IFZ fileInfo[] THEN RETURN ("")
		IFZ fileInfo[1].fileHandle THEN RETURN ("")		' not initialized
	END IF
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN												' console
		RETURN ("")																		' not going to read from console
	END IF
'
	p = SetFilePointer (fileHandle, 0, 0, $$FILE_CURRENT)	' p = file pointer before
	IF (p = -1) THEN GOTO SeekError
'
	a$			= NULL$ (530)
	bufAddr	= &a$
	length	= 0
	nl			= 0
'
	DO
		a = ReadFile (fileHandle, bufAddr, 86, &bytesRead, 0)
		IFZ a THEN GOTO ReadError
		IFZ bytesRead THEN EXIT DO
		nl = INSTR(a$, "\n", length + 1)	' \n in last segment?
		IF nl THEN
			length = nl - 1
			a${length} = 0									' put null terminator over <nl>
			IF length THEN
				cr = a${length-1}							' Check for <cr> before <nl>.  Why?
				IF (cr = 13) THEN							' Because WindowsNT sends <cr> + <nl>
					DEC length
					a${length} = 0							' put null terminator over <cr>
				END IF
			END IF
			EXIT DO
		END IF

		length		= length + bytesRead
		bytesLeft	= LEN(a$) - length
		IF (bytesLeft < 87) THEN a$ = a$ + NULL$ (530)
		bufAddr	= &a$ + length											' bufAddr = next input address
	LOOP
'
' n = number of characters including newline <nl>
'
	IFZ length THEN
		a$ = ""
	ELSE
		aAddr = &a$
		XLONGAT (aAddr, -8)			= length				' put length in header
		UBYTEAT (aAddr, length)	= 0							' put null byte over <nl>
	END IF

	IF nl THEN
		p = p + nl															' put file pointer after <nl>
	ELSE
		p = p + length													' put file pointer after last char
	END IF
	a = SetFilePointer (fileHandle, p, 0, $$FILE_BEGIN)
	IF (a = -1) THEN GOTO SeekError
	RETURN (a$)
'
'	Error
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN
'
ReadError:
	errno = GetLastError ()
	IF (bytesRead = 0) THEN
		s = SetFilePointer (fileHandle, 0, 0, $$FILE_END)		' get size of file
		IF (s = -1) THEN GOTO SeekError
		a = SetFilePointer (fileHandle, p, 0, $$FILE_BEGIN)	' restore file position
		IF (a = -1) THEN GOTO SeekError
		IF (p >= s) THEN
			lastErr = ERROR (($$ErrorObjectFile << 8) OR $$ErrorNatureExhausted)
		ELSE
			lastErr = ERROR ($$ErrorNatureTerminated)
		END IF
	ELSE
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
	END IF
	RETURN
END FUNCTION
'
'
' ###########################
' #####  XxxInline$ ()  #####
' ###########################
'
'	In:			prompt$		MUST NOT FREE prompt$ (%_inline_d.s must do so)
'	RETURN	line$			input string
'					""				error (##ERROR is set on error)
'
FUNCTION  XxxInline$ (prompt$)

	err = XxxWriteFile (1, &prompt$, LEN (prompt$), @bytesWritten, 0)
	IF err THEN RETURN ("")

	hStdIn 		= GetStdHandle ($$STD_INPUT_HANDLE)
	IF hStdIn = $$INVALID_HANDLE_VALUE THEN RETURN ("")

  FlushConsoleInputBuffer(hStdIn)
	ret$ 	= NULL$(8192)
	err = ReadFile (hStdIn, &ret$, LEN (ret$), &bytesRead, 0)
	IFZ err THEN RETURN ("")
'	ret$ = LEFT$ (ret$, bytesRead)
'	ret$ = MID$ (ret$, 1, bytesRead)
  ret$ = MID$ (ret$, 1, bytesRead-2)
	RETURN (ret$)

END FUNCTION
'
'
' ########################
' #####  XxxSeek ()  #####
' ########################
'
'	RETURN	0...	new position
'					-1		error (##ERROR is set on error)
'
FUNCTION  XxxSeek (fileNumber, position)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]

	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)			' Console Grid

	a = SetFilePointer (fileHandle, position, 0, $$FILE_BEGIN)
	IF (a = -1) THEN GOTO SeekError
	RETURN (a)
'
'	Error
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' #########################
' #####  XxxShell ()  #####
' #########################
'
'	command$	MUST NOT FREE command$ (%_shell.s must do so)
'
'	wait till process completes unless 1st character of command$ = ":"
' inherit socket and file handles unless 1st character of command$ = "-"
'
FUNCTION  XxxShell (command$)
	AUTOX  PROCESS_INFORMATION  processInfo
	AUTOX  STARTUPINFO  startupInfo
	AUTOX  status
	AUTOX  c$
'
	$PROCESS_ALL_ACCESS					= 0x001F0FFF
	$PROCESS_QUERY_INFORMATION	= 0x00000400
	$STILL_ACTIVE								= 0x00000103
'
	c$ = TRIM$ (command$)										' !!! don't free command$ !!!
'
	IFZ c$ THEN
		RETURN
	END IF
'
	inherit = 1
	waitTillProcessCompleted = $$TRUE
'
	IF (c${0} = '-') THEN
		inherit = 0
		c$ = MID$(c$,2)
		IFZ c$ THEN
			RETURN
		END IF
	END IF
'
	IF (c${0} = ':') THEN
		waitTillProcessCompleted = $$FALSE
		c$ = MID$(c$,2)
		IFZ c$ THEN
			RETURN
		END IF
	END IF
'
	IF (c${0} = '-') THEN
		inherit = 0
		c$ = MID$(c$,2)
		IFZ c$ THEN
			RETURN
		END IF
	END IF
'
	startupInfo.cb					= SIZE(STARTUPINFO)
	startupInfo.dwFlags			= 1										' look at wShowWindow
	startupInfo.wShowWindow	= 4										' show process window
'
	CreateProcessA (0, &c$, 0, 0, inherit, 0, 0, 0, &startupInfo, &processInfo)
'
' CreateProcess() creates an extra set of process/thread handles for
' the calling process.  New process will not die until all handles are
' closed.  Standard procedure is to close these handles immediately.
'
'	PRINT HEX$(processInfo.hProcess,8);; HEX$(processInfo.hThread,8);; HEX$(processInfo.dwProcessId,8);; HEX$(processInfo.dwThreadId,8)
'
	processID = processInfo.dwProcessId
	CloseHandle (processInfo.hProcess)
	CloseHandle (processInfo.hThread)
'
' For some unknown reason, cannot get process status using original
' process handle.  Must open a new handle.
'
	IF waitTillProcessCompleted THEN
'		hProcess = OpenProcess ($PROCESS_QUERY_INFORMATION, 1, processInfo.dwProcessId)
		hProcess = OpenProcess ($PROCESS_ALL_ACCESS, 1, processInfo.dwProcessId)
		DO
			Sleep (20)
			okay = GetExitCodeProcess (hProcess, &status)
'
			IFZ okay THEN EXIT DO
'
			IF ##SOFTBREAK THEN
'
' Prefer to terminate the new process, but TerminateProcess() is not
' recommended because it leaves DLLs hanging.  ExitProcess() only
' terminates the calling process ...
'
				EXIT DO
			END IF
		LOOP WHILE (status = $STILL_ACTIVE)
'
		CloseHandle (hProcess)
		RETURN (status)
	ELSE
		RETURN (processID)
	END IF
END FUNCTION
'
'
' ####################
' #####  Xit ()  #####
' ####################
'
FUNCTION  Xit (appStart)

	FUNCADDR	app()
	FUNCADDR	exFunc()
	EXCEPTION_DATA exception

	XstTry (SUBADDRESS(RunApp), SUBADDRESS(Except), @exception)
	RETURN (error)

	SUB RunApp
		app = appStart
		error = @app()
	END SUB

	SUB Except
		exception.response = $$ExceptionForward
		XstGetExceptionFunction (@exFunc)
		IF exFunc THEN
			response = @exFunc()
			SELECT CASE response
				CASE $$ExceptionTerminate, $$ExceptionContinue
					exception.response = response
				CASE ELSE
					exception.response = $$ExceptionForward
			END SELECT
		END IF
	END SUB

END FUNCTION
'
'
' ######################################
' #####  XstStringToLongDouble ()  #####
' ######################################
'
FUNCTION  XstStringToLongDouble (text$, start, @after, @rtype, LONGDOUBLE value)

	LONGDOUBLE sig, ten
'	LONGDOUBLE k, sign
	SHARED POT_IndexP[], POT_IndexN[]
	SHARED LONGDOUBLE POT_TableP[], POT_TableN[]

	IFZ text$ THEN RETURN ($$TRUE)
ASM finit			; initialize fpu, disable all fpu exceptions
	Init_POT_Tables ()
	value = 0
	sig = 0
	sign = 1
	expSign = 1
	after = start
	rtype = 0
	ten = 10

	dec_sym = GetLocaleDecimalPoint ()

' s is current place in string
	s = start

	upp = LEN (text$) - 1
	IF s > upp THEN GOTO error

' skip leading spaces, tabs, newlines, etc
	FOR i = start TO upp
		c = text${i}
		SELECT CASE c
			CASE ' ', '\t', '\n', '\r' : INC s
			CASE ELSE : EXIT FOR
		END SELECT
	NEXT i

	IF s > upp THEN GOTO error		' no number at all

	nsign = 0
	decflg = 0
	sgnflg = 0
	nexp = 0				' number of digits after decimal point
	exp = 0					' exponent value
	prec = 0
	trail = 0

nxtcom:
	k = text${s} - '0'
	IF ((k >= 0) && (k <= 9)) THEN

' Ignore leading zeros
		IF ((prec == 0) && (decflg == 0) && (k == 0)) THEN GOTO donchr

' Identify and strip trailing zeros after the decimal point.
		IF ((trail == 0) && (decflg != 0)) THEN
			sp = s
			DO WHILE ((text${sp} >= '0') && (text${sp} <= '9'))
				INC sp
			LOOP
			DEC sp
			DO WHILE (text${sp} == '0')
'				DEC sp
				text${sp} = 'z'
				DEC sp
			LOOP
			trail = 1
			IF (text${s} == 'z') THEN GOTO donchr
		END IF

' count digits after decimal point
		IF (decflg) THEN INC nexp

' multiply significand by ten and add current digit
		sig = sig * ten + k
		INC prec
		GOTO donchr
	END IF

	IF (text${s} == dec_sym) THEN
		IF (decflg) THEN GOTO daldone
    INC decflg
	ELSE
  	SELECT CASE text${s}
			CASE 'z':
			CASE 'E', 'e', 'D', 'd':
				GOTO expnt
			CASE '-':
				IF (sgnflg) THEN GOTO daldone
				nsign = -1
				INC sgnflg
			CASE '+':
				IF (sgnflg) THEN GOTO daldone
				INC sgnflg
			CASE 'i', 'I':
	  		INC s
	  		IF (text${s} != 'n' && text${s} != 'N') THEN GOTO zero
	  		INC s
	  		IF (text${s} == 'f' || text${s} == 'F') THEN
	  			INC s
	  			GOTO infinite
	  		END IF
		CASE 'n', 'N':
 	  	INC s
	  	IF (text${s} != 'a' && text${s} != 'A') THEN GOTO zero
	  	INC s
	  	IF (text${s} != 'n' && text${s} != 'N') THEN GOTO zero
	  	INC s
' set value to Nan
			addr = &sig
			USHORTAT (addr + 0 ) = 0x0000
			USHORTAT (addr + 2 ) = 0x0000
			USHORTAT (addr + 4 ) = 0x0000
			USHORTAT (addr + 6 ) = 0xC000
			USHORTAT (addr + 8 ) = 0xFFFF
	  	GOTO aexit
		CASE ELSE :
	  	GOTO daldone
		END SELECT
	END IF

donchr:
	INC s
	GOTO nxtcom

' Exponent interpretation
expnt:
	esign = 1
	exp = 0
	INC s
' check for + or -
	SELECT CASE text${s}
		CASE '-' : esign = -1 : INC esignflg : INC s
		CASE '+' : INC esignflg : INC s
	END SELECT

	DO WHILE ((text${s} >= '0') && (text${s} <= '9') && exp < 4978)
		INC expCount
		IF expCount > 4 THEN EXIT DO
		exp = exp * 10
		exp = exp + text${s} - '0'
		INC s
	LOOP

' found no digits after E,e,D,or d, it's an error
	IFZ expCount THEN
		DEC s
    IF esignflg THEN DEC s
  END IF

	IF (esign < 0) THEN exp = -exp

'	IF (exp > 4932) THEN
	IF (exp-nexp > 4932) THEN
infinite:
' set value to infinity
		lastErr = ERROR (($$ErrorObjectData << 8) OR $$ErrorNatureOverflow)
		addr = &sig
		USHORTAT (addr + 0 ) = 0x0000
		USHORTAT (addr + 2 ) = 0x0000
		USHORTAT (addr + 4 ) = 0x0000
		USHORTAT (addr + 6 ) = 0x8000
		USHORTAT (addr + 8 ) = 0x7FFF
		GOTO aexit
	END IF

	IF (exp < -4977) THEN
	lastErr = ERROR (($$ErrorObjectData << 8) OR $$ErrorNatureUnderflow)
zero:
		sig = 0
		GOTO aexit
	END IF

daldone:
	exp = exp - nexp
	IF sig = 0 THEN GOTO zero

' multiply by 10^exp
	IF (exp > 0) THEN
		POT_index = 0
' Until we hit 1.0 or finish exponent or overflow
		DO WHILE ((POT_index < 13) && (exp != 0) && (IsInfL(sig) = 0))
' Find the first power of ten in the table which is just less than the exponent.
			DO WHILE (exp < POT_IndexP[POT_index])
				INC POT_index
			LOOP
			IF (POT_index < 13) THEN
' Subtract out what we're multiplying in from exponent
				exp = exp - POT_IndexP[POT_index]
' Multiply by current power of 10
				sig = sig * POT_TableP[POT_index]
			END IF
		LOOP
	ELSE
		IF (exp < 0) THEN
			POT_index = 0
' Until we hit 1.0 or finish exponent or underflow
			DO WHILE ((POT_index < 13) && (exp != 0) && (IsZeroL(sig) = 0))
' Find the first power of ten in the table which is just less than  the exponent.
				DO WHILE (exp > POT_IndexN[POT_index])
					INC POT_index
				LOOP
	    	IF (POT_index < 13) THEN
' Subtract out what we're multiplying in from exponent
					exp = exp - POT_IndexN[POT_index]
' Multiply by current power of 10
					sig = sig * POT_TableN[POT_index]
				END IF
			LOOP
		END IF
	END IF

' init FPU again in case we had an exception
ASM finit

	IF nsign = -1 THEN sig = sig * nsign

aexit:
	value = sig
	after = s
	rtype = $$LONGDOUBLE

' unmask divide-by-zero, overflow, and underflow FPU exceptions
	XstEnableFPExceptions ()
	RETURN ($$LONGDOUBLE)

error:
' unmask divide-by-zero, overflow, and underflow FPU exceptions
	after = s
	XstEnableFPExceptions ()
	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  XstGetFPUControlWord ()  #####
' #####################################
'
' Return value is current FPU control word.
'
FUNCTION  USHORT XstGetFPUControlWord ()

	USHORT cw
	cw = 0

ASM	fstcw w[ebp-24]				; store control word in cw
ASM fwait

	RETURN cw

END FUNCTION
'
'
' #####################################
' #####  XstSetFPUControlWord ()  #####
' #####################################
'
' Sets the FPU control word.
' Return value is previous control word.
'
FUNCTION  USHORT XstSetFPUControlWord (USHORT cw)

	USHORT cwLast

	cwLast = XstGetFPUControlWord ()

ASM	fldcw w[ebp+8]

	RETURN cwLast

END FUNCTION
'
'
' ##################################
' #####  XstSetFPURounding ()  #####
' ##################################
'
' Sets the FPU rounding field of control word.
' Return value is the previous control word.
'
FUNCTION  USHORT XstSetFPURounding (mode)

' The RC field in the control word (bits 11 and 10)
' or Rounding Control determines how the FPU will
' round results in one of four ways:

' 00 = Round to nearest, or to even if equidistant (this is the initialized state)
' 01 = Round down (toward -infinity)
' 10 = Round up (toward +infinity)
' 11 = Truncate (toward 0)

' rounding modes
' $$ROUND_NEAREST = 0
' $$ROUND_DOWN = 1
' $$ROUND_UP = 2
' $$TRUNCATE = 3

	USHORT cw, cwLast

	cw = XstGetFPUControlWord ()
	cwLast = cw
	cw = cw & 0xF3FF				' clear bits 10 - 11
	SELECT CASE mode
		CASE $$ROUND_NEAREST 	:
		CASE $$ROUND_DOWN 		: cw = cw | 0x0400
		CASE $$ROUND_UP				: cw = cw | 0x0800
		CASE $$TRUNCATE				: cw = cw | 0x0C00
		CASE ELSE							: RETURN ($$TRUE)
	END SELECT
	XstSetFPUControlWord (cw)
	RETURN cwLast

END FUNCTION
'
'
' ###################################
' #####  XstSetFPUPrecision ()  #####
' ###################################
'
' Set the FPU precision control field
' in control word.
' Return value is previous control word.
'
FUNCTION  USHORT XstSetFPUPrecision (mode)

' The PC field (bits 9 and 8) or Precision Control
' determines to what precision the FPU rounds results
' after each arithmetic instruction in one of three ways:

' 00 = 24 bits (REAL4)
' 01 = Not used
' 10 = 53 bits (REAL8)
' 11 = 64 bits (REAL10) (this is the initialized state)
' note : XBLite loads msvcrt.lib on startup, which in turn,
'        initializes the FPU precision to 53-bit mode.

'$$24_BITS = 0
'$$53_BITS = 1
'$$64_BITS = 2

	USHORT cw, cwLast

	cw = XstGetFPUControlWord ()
	cwLast = cw
	cw = cw & 0xFCFF				' clear bits 8 - 9
	SELECT CASE mode
		CASE $$24_BITS 				:
		CASE $$53_BITS				: cw = cw | 0x0200
		CASE $$64_BITS				: cw = cw | 0x0300
		CASE ELSE							: RETURN ($$TRUE)
	END SELECT
	XstSetFPUControlWord (cw)
	RETURN cwLast

END FUNCTION
'
'
' ############################
' #####  FPClassifyL ()  #####
' ############################
'
FUNCTION  USHORT FPClassifyL (LONGDOUBLE x)

	USHORT sw
	sw = 0

ASM fld			t[ebp+8]   					; st(0) = x
ASM fxam												; examine the content of st(0)
ASM	fstsw 	w[ebp-24]						; store status word in sw
ASM fwait
ASM fstp		t[ebp+8]

	RETURN (sw & ($$FP_NAN | $$FP_NORMAL | $$FP_ZERO))

END FUNCTION
'
'
' ##########################
' #####  IsFiniteL ()  #####
' ##########################
'
FUNCTION  IsFiniteL (LONGDOUBLE x)

	RETURN ((FPClassifyL (x) & $$FP_NAN) == 0)

END FUNCTION
'
'
' ######################
' #####  IsInf ()  #####
' ######################
'
FUNCTION  IsInfL (LONGDOUBLE x)

RETURN (FPClassifyL (x) == $$FP_INFINITE)

END FUNCTION
'
'
' #########################
' #####  IsNormal ()  #####
' #########################
'
FUNCTION  IsNormalL (LONGDOUBLE x)

	RETURN (FPClassifyL (x) == $$FP_NORMAL)

END FUNCTION
'
'
' #######################
' #####  IsNanL ()  #####
' #######################
'
FUNCTION  IsNanL (LONGDOUBLE x)

	USHORT sw
	sw = 0

ASM fld		t[ebp+8]   					; st(0) = x
ASM fxam											; examine the content of st(0)
ASM	fstsw 	w[ebp-24]					; store status word in sw
ASM fwait
ASM fstp		t[ebp+8]

	RETURN ((sw & ($$FP_NAN | $$FP_NORMAL | $$FP_INFINITE | $$FP_ZERO | $$FP_SUBNORMAL)) == $$FP_NAN)

END FUNCTION
'
'
' #########################
' #####  SignBitL ()  #####
' #########################
'
FUNCTION  SignBitL (LONGDOUBLE x)

	USHORT sw
	sw = 0

ASM fld		t[ebp+8]   					; st(0) = x
ASM fxam											; examine the content of st(0)
ASM	fstsw 	w[ebp-24]					; store status word in sw
ASM fwait
ASM fstp		t[ebp+8]

	RETURN ((sw & 0x0200) != 0)

END FUNCTION
'
'
' ########################
' #####  IsZeroL ()  #####
' ########################
'
FUNCTION  IsZeroL (LONGDOUBLE x)

	USHORT sw
	sw = 0

ASM fld		t[ebp+8]   					; st(0) = x
ASM fxam											; examine the content of st(0)
ASM	fstsw 	w[ebp-24]					; store status word in sw
ASM fwait
ASM fstp		t[ebp+8]

	RETURN (FPClassifyL (x) == $$FP_ZERO)

END FUNCTION
'
'
' #############################
' #####  IsSubNormalL ()  #####
' #############################
'
FUNCTION  IsSubNormalL (LONGDOUBLE x)

	USHORT sw
	sw = 0

ASM fld		t[ebp+8]   					; st(0) = x
ASM fxam											; examine the content of st(0)
ASM	fstsw 	w[ebp-24]					; store status word in sw
ASM fwait
ASM fstp		t[ebp+8]

	RETURN (FPClassifyL (x) == $$FP_SUBNORMAL)

END FUNCTION
'
'
' ######################################
' #####  XstEnableFPExceptions ()  #####
' ######################################
'
' Unmask divide-by-zero, overflow, and underflow FPU exceptions.
' Returns last control word.
'
FUNCTION  USHORT XstEnableFPExceptions ()

	USHORT cw, lastCW

	cw = XstGetFPUControlWord ()
	cw = cw & 0xFFFFFFE3
	lastCW = XstSetFPUControlWord (cw)
	RETURN lastCW

END FUNCTION
'
'
' ######################################
' #####  GetLocaleDecimalPoint ()  #####
' ######################################
'
FUNCTION  GetLocaleDecimalPoint ()

	buf$ = NULL$ (7)
  IF GetLocaleInfoA ($$LOCALE_USER_DEFAULT, $$LOCALE_SDECIMAL, &buf$, LEN(buf$)) THEN
		buf$ = CSIZE$ (buf$)
		RETURN buf${0}
  ELSE
  	RETURN '.'
  END IF

END FUNCTION
'
' ################################
' #####  Init_POT_Tables ()  #####
' ################################
'
FUNCTION  Init_POT_Tables ()

	SHARED POT_IndexP[]
	SHARED POT_IndexN[]
	SHARED LONGDOUBLE POT_TableP[]
	SHARED LONGDOUBLE POT_TableN[]
	LONGDOUBLE xld
	STATIC entry

	IF entry THEN RETURN
	entry = $$TRUE

	DIM POT_IndexP[13]
	DIM POT_IndexN[13]
	DIM POT_TableP[13]
	DIM POT_TableN[13]

  POT_IndexP[13] = 0
  POT_IndexP[12] = 1
  POT_IndexP[11] = 2
  POT_IndexP[10] = 4
  POT_IndexP[9] = 8
  POT_IndexP[8] = 16
  POT_IndexP[7] = 32
  POT_IndexP[6] = 64
  POT_IndexP[5] = 128
  POT_IndexP[4] = 256
  POT_IndexP[3] = 512
  POT_IndexP[2] = 1024
  POT_IndexP[1] = 2048
  POT_IndexP[0] = 4096

  POT_IndexN[13] = 0
  POT_IndexN[12] = -1
  POT_IndexN[11] = -2
  POT_IndexN[10] = -4
  POT_IndexN[9] = -8
  POT_IndexN[8] = -16
  POT_IndexN[7] = -32
  POT_IndexN[6] = -64
  POT_IndexN[5] = -128
  POT_IndexN[4] = -256
  POT_IndexN[3] = -512
  POT_IndexN[2] = -1024
  POT_IndexN[1] = -2048
  POT_IndexN[0] = -4096

' POT table 80-bit precision
' USHORT array 0-4
' 10^+
' 4096 - 0x979B 0x8A20 0x5202 0xC460 0x7525
' 2048 - 0x5DE5 0xC53D 0x3B5D 0x9E8B 0x5A92
' 1024 - 0x0C17 0x8175 0x7586 0xC976 0x4D48
'  512 - 0x91C7 0xA60E 0xA0AE 0xE319 0x46A3
'  256 - 0xDE8E 0x9DF9 0xEBFB 0xAA7E 0x4351
'  128 - 0x8CE0 0x80E9 0x47C9 0x93BA 0x41A8
'   64 - 0xA6D5 0xFFCF 0x1F49 0xC278 0x40D3
'   32 - 0xB59E 0x2B70 0xADA8 0x9DC5 0x4069
'   16 - 0x0000 0x0400 0xC9BF 0x8E1B 0x4034
'    8 - 0x0000 0x0000 0x2000 0xBEBC 0x4019
'    4 - 0x0000 0x0000 0x0000 0x9C40 0x400C
'    2 - 0x0000 0x0000 0x0000 0xC800 0x4005
'    1 - 0x0000 0x0000 0x0000 0xA000 0x4002
'    0 - 0x0000 0x0000 0x0000 0x8000 0x3FFF

'-4096 - 0x9FDE 0xD2CE 0x04C8 0xA6DD 0x0AD8
'-2048 - 0x2DE4 0x3436 0x534F 0xCEAE 0x256B
'-1024 - 0xC0BE 0xDA57 0x82A5 0xA2A6 0x32B5
' -512 - 0xD21C 0xDB23 0xEE32 0x9049 0x395A
' -256 - 0x193A 0x637A 0x4325 0xC031 0x3CAC
' -128 - 0xE4A1 0x64BC 0x467C 0xDDD0 0x3E55
'  -64 - 0xE9A5 0xA539 0xEA27 0xA87F 0x3F2A
'  -32 - 0x94BA 0x4539 0x1EAD 0xCFB1 0x3F94
'  -16 - 0xE15B 0xC44D 0x94BE 0xE695 0x3FC9
'   -8 - 0xCEFD 0x8461 0x7711 0xABCC 0x3FE4
'   -4 - 0x652C 0xE219 0x1758 0xD1B7 0x3FF1
'   -2 - 0xD70A 0x70A3 0x0A3D 0xA3D7 0x3FF8
'   -1 - 0xCCCD 0xCCCC 0xCCCC 0xCCCC 0x3FFB
'    0 - 0x0000 0x0000 0x0000 0x8000 0x3FFF

	xld = 0
	addr = &xld

' POT table positive
  USHORTAT (addr + 0 ) = 0x979B
	USHORTAT (addr + 2 ) = 0x8A20
	USHORTAT (addr + 4 ) = 0x5202
	USHORTAT (addr + 6 ) = 0xC460
	USHORTAT (addr + 8 ) = 0x7525
	POT_TableP[0] = xld

  USHORTAT (addr + 0 ) = 0x5DE5
	USHORTAT (addr + 2 ) = 0xC53D
	USHORTAT (addr + 4 ) = 0x3B5D
	USHORTAT (addr + 6 ) = 0x9E8B
	USHORTAT (addr + 8 ) = 0x5A92
	POT_TableP[1] = xld

  USHORTAT (addr + 0 ) = 0x0C17
	USHORTAT (addr + 2 ) = 0x8175
	USHORTAT (addr + 4 ) = 0x7586
	USHORTAT (addr + 6 ) = 0xC976
	USHORTAT (addr + 8 ) = 0x4D48
	POT_TableP[2] = xld

  USHORTAT (addr + 0 ) = 0x91C7
	USHORTAT (addr + 2 ) = 0xA60E
	USHORTAT (addr + 4 ) = 0xA0AE
	USHORTAT (addr + 6 ) = 0xE319
	USHORTAT (addr + 8 ) = 0x46A3
	POT_TableP[3] = xld

  USHORTAT (addr + 0 ) = 0xDE8E
	USHORTAT (addr + 2 ) = 0x9DF9
	USHORTAT (addr + 4 ) = 0xEBFB
	USHORTAT (addr + 6 ) = 0xAA7E
	USHORTAT (addr + 8 ) = 0x4351
	POT_TableP[4] = xld

  USHORTAT (addr + 0 ) = 0x8CE0
	USHORTAT (addr + 2 ) = 0x80E9
	USHORTAT (addr + 4 ) = 0x47C9
	USHORTAT (addr + 6 ) = 0x93BA
	USHORTAT (addr + 8 ) = 0x41A8
	POT_TableP[5] = xld

  USHORTAT (addr + 0 ) = 0xA6D5
	USHORTAT (addr + 2 ) = 0xFFCF
	USHORTAT (addr + 4 ) = 0x1F49
	USHORTAT (addr + 6 ) = 0xC278
	USHORTAT (addr + 8 ) = 0x40D3
	POT_TableP[6] = xld

  USHORTAT (addr + 0 ) = 0xB59E
	USHORTAT (addr + 2 ) = 0x2B70
	USHORTAT (addr + 4 ) = 0xADA8
	USHORTAT (addr + 6 ) = 0x9DC5
	USHORTAT (addr + 8 ) = 0x4069
	POT_TableP[7] = xld

  USHORTAT (addr + 0 ) = 0x0000
	USHORTAT (addr + 2 ) = 0x0400
	USHORTAT (addr + 4 ) = 0xC9BF
	USHORTAT (addr + 6 ) = 0x8E1B
	USHORTAT (addr + 8 ) = 0x4034
	POT_TableP[8] = xld

 	USHORTAT (addr + 0 ) = 0x0000
	USHORTAT (addr + 2 ) = 0x0000
	USHORTAT (addr + 4 ) = 0x2000
	USHORTAT (addr + 6 ) = 0xBEBC
	USHORTAT (addr + 8 ) = 0x4019
	POT_TableP[9] = xld

	USHORTAT (addr + 0 ) = 0x0000
	USHORTAT (addr + 2 ) = 0x0000
	USHORTAT (addr + 4 ) = 0x0000
	USHORTAT (addr + 6 ) = 0x9C40
	USHORTAT (addr + 8 ) = 0x400C
	POT_TableP[10] = xld

	USHORTAT (addr + 0 ) = 0x0000
	USHORTAT (addr + 2 ) = 0x0000
	USHORTAT (addr + 4 ) = 0x0000
	USHORTAT (addr + 6 ) = 0xC800
	USHORTAT (addr + 8 ) = 0x4005
	POT_TableP[11] = xld

	USHORTAT (addr + 0 ) = 0x0000
	USHORTAT (addr + 2 ) = 0x0000
	USHORTAT (addr + 4 ) = 0x0000
	USHORTAT (addr + 6 ) = 0xA000
	USHORTAT (addr + 8 ) = 0x4002
	POT_TableP[12] = xld

	USHORTAT (addr + 0 ) = 0x0000
	USHORTAT (addr + 2 ) = 0x0000
	USHORTAT (addr + 4 ) = 0x0000
	USHORTAT (addr + 6 ) = 0x8000
	USHORTAT (addr + 8 ) = 0x3FFF
	POT_TableP[13] = xld

' POT table negative

	USHORTAT (addr + 0 ) = 0x9FDE
	USHORTAT (addr + 2 ) = 0xD2CE
	USHORTAT (addr + 4 ) = 0x04C8
	USHORTAT (addr + 6 ) = 0xA6DD
	USHORTAT (addr + 8 ) = 0x0AD8
	POT_TableN[0] = xld

	USHORTAT (addr + 0 ) = 0x2DE4
	USHORTAT (addr + 2 ) = 0x3436
	USHORTAT (addr + 4 ) = 0x534F
	USHORTAT (addr + 6 ) = 0xCEAE
	USHORTAT (addr + 8 ) = 0x256B
	POT_TableN[1] = xld

	USHORTAT (addr + 0 ) = 0xC0BE
	USHORTAT (addr + 2 ) = 0xDA57
	USHORTAT (addr + 4 ) = 0x82A5
	USHORTAT (addr + 6 ) = 0xA2A6
	USHORTAT (addr + 8 ) = 0x32B5
	POT_TableN[2] = xld

	USHORTAT (addr + 0 ) = 0xD21C
	USHORTAT (addr + 2 ) = 0xDB23
	USHORTAT (addr + 4 ) = 0xEE32
	USHORTAT (addr + 6 ) = 0x9049
	USHORTAT (addr + 8 ) = 0x395A
	POT_TableN[3] = xld

	USHORTAT (addr + 0 ) = 0x193A
	USHORTAT (addr + 2 ) = 0x637A
	USHORTAT (addr + 4 ) = 0x4325
	USHORTAT (addr + 6 ) = 0xC031
	USHORTAT (addr + 8 ) = 0x3CAC
	POT_TableN[4] = xld

	USHORTAT (addr + 0 ) = 0xE4A1
	USHORTAT (addr + 2 ) = 0x64BC
	USHORTAT (addr + 4 ) = 0x467C
	USHORTAT (addr + 6 ) = 0xDDD0
	USHORTAT (addr + 8 ) = 0x3E55
	POT_TableN[5] = xld

	USHORTAT (addr + 0 ) = 0xE9A5
	USHORTAT (addr + 2 ) = 0xA539
	USHORTAT (addr + 4 ) = 0xEA27
	USHORTAT (addr + 6 ) = 0xA87F
	USHORTAT (addr + 8 ) = 0x3F2A
	POT_TableN[6] = xld

	USHORTAT (addr + 0 ) = 0x94BA
	USHORTAT (addr + 2 ) = 0x4539
	USHORTAT (addr + 4 ) = 0x1EAD
	USHORTAT (addr + 6 ) = 0xCFB1
	USHORTAT (addr + 8 ) = 0x3F94
	POT_TableN[7] = xld

	USHORTAT (addr + 0 ) = 0xE15B
	USHORTAT (addr + 2 ) = 0xC44D
	USHORTAT (addr + 4 ) = 0x94BE
	USHORTAT (addr + 6 ) = 0xE695
	USHORTAT (addr + 8 ) = 0x3FC9
	POT_TableN[8] = xld

	USHORTAT (addr + 0 ) = 0xCEFD
	USHORTAT (addr + 2 ) = 0x8461
	USHORTAT (addr + 4 ) = 0x7711
	USHORTAT (addr + 6 ) = 0xABCC
	USHORTAT (addr + 8 ) = 0x3FE4
	POT_TableN[9] = xld

	USHORTAT (addr + 0 ) = 0x652C
	USHORTAT (addr + 2 ) = 0xE219
	USHORTAT (addr + 4 ) = 0x1758
	USHORTAT (addr + 6 ) = 0xD1B7
	USHORTAT (addr + 8 ) = 0x3FF1
	POT_TableN[10] = xld

	USHORTAT (addr + 0 ) = 0xD70A
	USHORTAT (addr + 2 ) = 0x70A3
	USHORTAT (addr + 4 ) = 0x0A3D
	USHORTAT (addr + 6 ) = 0xA3D7
	USHORTAT (addr + 8 ) = 0x3FF8
	POT_TableN[11] = xld

	USHORTAT (addr + 0 ) = 0xCCCD
	USHORTAT (addr + 2 ) = 0xCCCC
	USHORTAT (addr + 4 ) = 0xCCCC
	USHORTAT (addr + 6 ) = 0xCCCC
	USHORTAT (addr + 8 ) = 0x3FFB
	POT_TableN[12] = xld

	USHORTAT (addr + 0 ) = 0x0000
	USHORTAT (addr + 2 ) = 0x0000
	USHORTAT (addr + 4 ) = 0x0000
	USHORTAT (addr + 6 ) = 0x8000
	USHORTAT (addr + 8 ) = 0x3FFF
	POT_TableN[13] = xld

END FUNCTION
'
'
' #######################################
' #####  XstLongDoubleToString$ ()  #####
' ######################################
'
' PURPOSE : convert a long double to a ascii string.
' IN			: ld - long double value (must be positive value).
' 				: maxDigits - count of signficant digits in string, <= 19
'					: expChar - exponent character: 'e', 'E', 'd', or 'D'.
'					: prefixChar - prefix character is '+', '-', space ' ', or 0 for no prefix character.
' OUT			: returned string
'
FUNCTION  XstLongDoubleToString$ (LONGDOUBLE ld, maxDigits, expChar, prefixChar)

	TBYTE x
	LONGDOUBLE five, d, temp, temp1, pot
	USHORT lastCW, cw

	SHARED POT_IndexP[]
	SHARED POT_IndexN[]
	SHARED LONGDOUBLE POT_TableP[]
	SHARED LONGDOUBLE POT_TableN[]

' byte order reversed on 8087
	$_0 = 4
	$_1 = 3
	$_2 = 2
	$_3 = 1
	$_4 = 0

' get current control word
	lastCW = XstGetFPUControlWord ()

' disable FPU exceptions
ASM finit

	Init_POT_Tables ()

' 19 decimal digit precision max for LONGDOUBLE
	IF maxDigits > 19 THEN maxDigits = 19

	five = 5##

' make result string
	result$ = NULL$ (30)

' set result string pointer
	resPtr = 0

' check on prefix character
	IF prefixChar THEN
		SELECT CASE prefixChar
			CASE '-' : ok = $$TRUE
			CASE '+' : ok = $$TRUE
			CASE ' ' : ok = $$TRUE
			CASE ELSE
		END SELECT
		IF ok THEN
			result${0} = prefixChar
			INC resPtr
		END IF
	END IF

' set control word to truncate mode
	XstSetFPURounding ($$TRUNCATE)

' test if NaN or INF, or zero
	IF IsZeroL (ld) THEN GOTO ld_zero
	IF IsInfL (ld) THEN GOTO ld_infinity
	IF IsNanL (ld) THEN GOTO ld_nan

ld_normal:

' flag to print leading zeros
	fLeadZeros = 0

' set digit count to 0
	dCount = 0     	'edx

' data contained in first 5 words
	x.ld = ld

' get exponent
	exp = x.us[$_0] & 0x7fff

' equivalent power of 10
	exp = exp * 0.30103
	exp = exp + 1

' always use scientific notation
	GOTO ld_scientific

ld_normalized:
	pow = exp
	pow = pow - maxDigits

	IF pow >= 0 THEN GOTO ld_round

	pow = 0
	GOTO ld_round_done

ld_round:
	exponent = pow-4932 : GOSUB GetPOT
	ld = ld + (five * pot)
	INC pow

ld_round_done:
ld_normal_loop:
	IF exp != 4931 THEN GOTO ld_digit
	result${resPtr} = '.'
	INC resPtr
	fLeadZeros = 1

ld_digit:
	exponent = exp-4932 : GOSUB GetPOT
	d = ld/pot
	digit = INT (d)
	IF digit != 0 THEN GOTO ld_normal_digit
	IFZ fLeadZeros THEN GOTO ld_normal_digit_done

ld_normal_digit:
	result${resPtr} = digit + '0'
	INC resPtr
	INC dCount
	fLeadZeros = 1

ld_normal_digit_done:
	temp = digit
	exponent = exp-4932 : GOSUB GetPOT
	temp = temp * pot
	ld = ld - temp
	exponent = pow-4932 : GOSUB GetPOT
	temp1 = pot
'	IF temp1 > d THEN GOTO ld_normal_zero  ' <<<< bug?
	IF temp1 > ld THEN GOTO ld_normal_zero
	DEC exp
	IF dCount >= maxDigits THEN GOTO ld_exponent
	GOTO ld_normal_loop

ld_normal_zero:
 	IF exp <= 4932 THEN GOTO ld_exponent
 	result${resPtr} = '0'
 	INC resPtr
	DEC exp
	GOTO ld_normal_zero

ld_scientific:				' print a number with an exponent
ld_find_1st_digit_loop:
	exponent = exp - 4932 : GOSUB GetPOT
	IF ld >= pot THEN GOTO ld_got_first_digit
	DEC exp
	IF exp < -4951 THEN GOTO ld_zero
	GOTO ld_find_1st_digit_loop

ld_got_first_digit:
	ecx = exp - 4932
	expo = ecx
	ecx = -1 * ecx
	exponent = ecx : GOSUB GetPOT
	ld = ld * pot
	exp = 4932		' offset to 10^0
	GOTO ld_normalized

ld_exponent:
	ecx = expo
	IFZ ecx THEN GOTO ld_done
' verify exponent character is ok
	SELECT CASE expChar
		CASE 'e', 'E', 'd', 'D' :
		CASE ELSE : expChar = 'd'
	END SELECT
	result${resPtr} = expChar 		' add exponent character
	INC resPtr
	IF ecx >= 0 THEN
		s = '+'
	ELSE
		s = '-'
		ecx = ecx * -1
	END IF
	result${resPtr} = s
	INC resPtr

' get the exponent digits
	count = 0
	div = 1000
	FOR i = 0 TO 2
		a = ecx \ div
		IF a THEN
			ecx = ecx - (a * div)
			result${resPtr} = '0' + a
			INC resPtr
			INC count
		ELSE
			IF count THEN
				result${resPtr} = '0'
				INC resPtr
				INC count
			END IF
		END IF
		div = div / 10
	NEXT i
	result${resPtr} = '0' + ecx
	GOTO ld_done

ld_nan:
	result${resPtr} = 'N'
	INC resPtr
	result${resPtr} = 'A'
	INC resPtr
	result${resPtr} = 'N'
	GOTO ld_done

ld_infinity:
	result${resPtr} = 'i'
	INC resPtr
	result${resPtr} = 'n'
	INC resPtr
	result${resPtr} = 'f'
	GOTO ld_done

ld_zero:
	result${resPtr} = '0'

ld_done:
' clear any FPU exceptions
ASM finit

' enable FPU exceptions
'	XstEnableFPExceptions ()

' restore control word
	XstSetFPUControlWord (lastCW)

 RETURN (CSIZE$ (result$))

' ***** GetPOT *****
' return 10^exponent in variable pot
' multiply by 10^exp
SUB GetPOT
	pot = 1
	IF (exponent > 0) THEN
		POT_index = 0
' Until we hit 1.0 or finish exponent or overflow
		DO WHILE ((POT_index < 13) && (exponent != 0))
' Find the first power of ten in the table which is just less than the exponent.
			DO WHILE (exponent < POT_IndexP[POT_index])
				INC POT_index
			LOOP
			IF (POT_index < 13) THEN
' Subtract out what we're multiplying in from exponent
				exponent = exponent - POT_IndexP[POT_index]
' Multiply by current power of 10
				pot = pot * POT_TableP[POT_index]
			END IF
		LOOP
	ELSE
		IF (exponent < 0) THEN
			POT_index = 0
' Until we hit 1.0 or finish exponent or underflow
			DO WHILE ((POT_index < 13) && (exponent != 0))
' Find the first power of ten in the table which is just less than the exponent.
				DO WHILE (exponent > POT_IndexN[POT_index])
					INC POT_index
				LOOP
	    	IF (POT_index < 13) THEN
' Subtract out what we're multiplying in from exponent
					exponent = exponent - POT_IndexN[POT_index]
' Multiply by current power of 10
					pot = pot * POT_TableN[POT_index]
				END IF
			LOOP
		END IF
	END IF
END SUB
END FUNCTION
'
' ################################
' #####  InitExceptionArray  #####
' ################################
'
' Initialize exception$[] array.
'
FUNCTION InitExceptionArray ()

	SHARED exception$[]

	DIM exception$[31]

	exception$ [ $$ExceptionNone                   ] = "$$ExceptionNone"
	exception$ [ $$ExceptionSegmentViolation       ] = "$$ExceptionSegmentViolation"
	exception$ [ $$ExceptionOutOfBounds            ] = "$$ExceptionOutOfBounds"
	exception$ [ $$ExceptionBreakpoint             ] = "$$ExceptionBreakpoint"
	exception$ [ $$ExceptionBreakKey               ] = "$$ExceptionBreakKey"
	exception$ [ $$ExceptionAlignment              ] = "$$ExceptionAlignment"
	exception$ [ $$ExceptionDenormal               ] = "$$ExceptionDenormal"
	exception$ [ $$ExceptionFloatDivideByZero      ] = "$$ExceptionFloatDivideByZero"
	exception$ [ $$ExceptionInvalidOperation       ] = "$$ExceptionInvalidOperation"
	exception$ [ $$ExceptionFloatOverflow          ] = "$$ExceptionFloatOverflow"
	exception$ [ $$ExceptionStackCheck             ] = "$$ExceptionStackCheck"
	exception$ [ $$ExceptionUnderflow              ] = "$$ExceptionUnderflow"
	exception$ [ $$ExceptionInvalidInstruction     ] = "$$ExceptionInvalidInstruction"
	exception$ [ $$ExceptionPrivilege              ] = "$$ExceptionPrivilege"
	exception$ [ $$ExceptionStackOverflow          ] = "$$ExceptionStackOverflow"
	exception$ [ $$ExceptionReserved               ] = "$$ExceptionReserved"
	exception$ [ $$ExceptionUnknown                ] = "$$ExceptionUnknown"
	exception$ [ $$ExceptionIntDivideByZero        ] = "$$ExceptionIntDivideByZero"
	exception$ [ $$ExceptionIntOverflow            ] = "$$ExceptionIntOverflow"
	exception$ [ $$ExceptionPrecision              ] = "$$ExceptionPrecision"
	exception$ [ $$ExceptionGuardPage              ] = "$$ExceptionGuardPage"
	exception$ [ $$ExceptionInPage                 ] = "$$ExceptionInPage"
	exception$ [ $$ExceptionDisposition            ] = "$$ExceptionDisposition"
	exception$ [ $$ExceptionNoncontinuable         ] = "$$ExceptionNoncontinuable"
	exception$ [ $$ExceptionSingleStep             ] = "$$ExceptionSingleStep"
	exception$ [ $$ExceptionMemoryAllocation       ] = "$$ExceptionMemoryAllocation"
	exception$ [ $$ExceptionNodeNotEmpty           ] = "$$ExceptionNodeNotEmpty"
	exception$ [ $$ExceptionArrayDimension         ] = "$$ExceptionArrayDimension"
	exception$ [ $$ExceptionInvalidArgument        ] = "$$ExceptionInvalidArgument"
	exception$ [ $$ExceptionUpper                  ] = "$$ExceptionUpper"

END FUNCTION
'
' ###################################
' #####  InitErrorStringArrays  #####
' ###################################
'
' Initialize errorObject$[] and errorNature$[] arrays.
'
FUNCTION InitErrorStringArrays ()

	SHARED	errorObject$[]
	SHARED	errorNature$[]

	DIM errorObject$[255]
	DIM errorNature$[255]
'
' ****************************************************
' *****  Initialize Native Error Number Strings  *****
' ****************************************************
'
  errorObject$[ $$ErrorObjectNone                ] = ""
  errorObject$[ $$ErrorObjectData                ] = "Data"
  errorObject$[ $$ErrorObjectDisk                ] = "Disk"
  errorObject$[ $$ErrorObjectFile                ] = "File"
  errorObject$[ $$ErrorObjectFont                ] = "Font"
	errorObject$[ $$ErrorObjectGrid                ] = "Grid"
	errorObject$[ $$ErrorObjectIcon                ] = "Icon"
  errorObject$[ $$ErrorObjectName                ] = "Name"
	errorObject$[ $$ErrorObjectNode                ] = "Node"
  errorObject$[ $$ErrorObjectPipe                ] = "Pipe"
  errorObject$[ $$ErrorObjectUser                ] = "User"
	errorObject$[ $$ErrorObjectArray               ] = "Array"
	errorObject$[ $$ErrorObjectImage               ] = "Image"
  errorObject$[ $$ErrorObjectMedia               ] = "Media"
  errorObject$[ $$ErrorObjectQueue               ] = "Queue"
  errorObject$[ $$ErrorObjectStack               ] = "Stack"
	errorObject$[ $$ErrorObjectTimer               ] = "Timer"
  errorObject$[ $$ErrorObjectBuffer              ] = "Buffer"
	errorObject$[ $$ErrorObjectCursor              ] = "Cursor"
  errorObject$[ $$ErrorObjectDevice              ] = "Device"
  errorObject$[ $$ErrorObjectDriver              ] = "Driver"
  errorObject$[ $$ErrorObjectMemory              ] = "Memory"
	errorObject$[ $$ErrorObjectSocket              ] = "Socket"
	errorObject$[ $$ErrorObjectString              ] = "String"
  errorObject$[ $$ErrorObjectSystem              ] = "System"
  errorObject$[ $$ErrorObjectThread              ] = "Thread"
	errorObject$[ $$ErrorObjectWindow              ] = "Window"
  errorObject$[ $$ErrorObjectCommand             ] = "Command"
	errorObject$[ $$ErrorObjectDisplay             ] = "Display"
  errorObject$[ $$ErrorObjectLibrary             ] = "Library"
	errorObject$[ $$ErrorObjectMessage             ] = "Message"
  errorObject$[ $$ErrorObjectNetwork             ] = "Network"
  errorObject$[ $$ErrorObjectPrinter             ] = "Printer"
  errorObject$[ $$ErrorObjectProcess             ] = "Process"
  errorObject$[ $$ErrorObjectProgram             ] = "Program"
  errorObject$[ $$ErrorObjectArgument            ] = "Argument"
  errorObject$[ $$ErrorObjectComputer            ] = "Computer"
  errorObject$[ $$ErrorObjectFunction            ] = "Function"
  errorObject$[ $$ErrorObjectIdentity            ] = "Identity"
	errorObject$[ $$ErrorObjectPassword            ] = "Password"
  errorObject$[ $$ErrorObjectClipboard           ] = "Clipboard"
  errorObject$[ $$ErrorObjectDirectory           ] = "Directory"
  errorObject$[ $$ErrorObjectSemaphore           ] = "Semaphore"
  errorObject$[ $$ErrorObjectStatement           ] = "Statement"
	errorObject$[ $$ErrorObjectSystemRoutine       ] = "SystemRoutine"
	errorObject$[ $$ErrorObjectSystemFunction      ] = "SystemFunction"
	errorObject$[ $$ErrorObjectSystemResource      ] = "SystemResource"
	errorObject$[ $$ErrorObjectOperatingSystem     ] = "OperatingSystem"
  errorObject$[ $$ErrorObjectIntegerLogicUnit    ] = "IntegerLogicUnit"
  errorObject$[ $$ErrorObjectFloatingPointUnit   ] = "FloatingPointUnit"
'
  errorNature$[ $$ErrorNatureNone                ] = ""
  errorNature$[ $$ErrorNatureBusy                ] = "Busy"
  errorNature$[ $$ErrorNatureFull                ] = "Full"
  errorNature$[ $$ErrorNatureError               ] = "Error"
  errorNature$[ $$ErrorNatureEmpty               ] = "Empty"
  errorNature$[ $$ErrorNatureReset               ] = "Reset"
  errorNature$[ $$ErrorNatureExists              ] = "Exists"
  errorNature$[ $$ErrorNatureFailed              ] = "Failed"
  errorNature$[ $$ErrorNatureHalted              ] = "Halted"
  errorNature$[ $$ErrorNatureExpired             ] = "Expired"
  errorNature$[ $$ErrorNatureInvalid             ] = "Invalid"
  errorNature$[ $$ErrorNatureMissing             ] = "Missing"
  errorNature$[ $$ErrorNatureTimeout             ] = "Timeout"
  errorNature$[ $$ErrorNatureTooMany             ] = "TooMany"
  errorNature$[ $$ErrorNatureUnknown             ] = "Unknown"
  errorNature$[ $$ErrorNatureBreakKey            ] = "BreakKey"
  errorNature$[ $$ErrorNatureDeadlock            ] = "Deadlock"
  errorNature$[ $$ErrorNatureDisabled            ] = "Disabled"
  errorNature$[ $$ErrorNatureNotEmpty            ] = "NotEmpty"
  errorNature$[ $$ErrorNatureObsolete            ] = "Obsolete"
  errorNature$[ $$ErrorNatureOverflow            ] = "Overflow"
  errorNature$[ $$ErrorNatureTooLarge            ] = "TooLarge"
  errorNature$[ $$ErrorNatureTooSmall            ] = "TooSmall"
  errorNature$[ $$ErrorNatureAbandoned           ] = "Abandoned"
  errorNature$[ $$ErrorNatureAvailable           ] = "Available"
  errorNature$[ $$ErrorNatureDuplicate           ] = "Duplicate"
  errorNature$[ $$ErrorNatureExhausted           ] = "Exhausted"
  errorNature$[ $$ErrorNaturePrivilege           ] = "Privilege"
  errorNature$[ $$ErrorNatureUndefined           ] = "Undefined"
  errorNature$[ $$ErrorNatureUnderflow           ] = "Underflow"
  errorNature$[ $$ErrorNatureAllocation          ] = "Allocation"
  errorNature$[ $$ErrorNatureBreakpoint          ] = "Breakpoint"
  errorNature$[ $$ErrorNatureContention          ] = "Contention"
  errorNature$[ $$ErrorNaturePermission          ] = "Permission"
  errorNature$[ $$ErrorNatureTerminated          ] = "Terminated"
  errorNature$[ $$ErrorNatureUndeclared          ] = "Undeclared"
  errorNature$[ $$ErrorNatureUnexpected          ] = "Unexpected"
  errorNature$[ $$ErrorNatureWouldBlock          ] = "WouldBlock"
  errorNature$[ $$ErrorNatureInterrupted         ] = "Interrupted"
  errorNature$[ $$ErrorNatureMalfunction         ] = "Malfunction"
  errorNature$[ $$ErrorNatureNonexistent         ] = "Nonexistent"
  errorNature$[ $$ErrorNatureUnavailable         ] = "Unavailable"
  errorNature$[ $$ErrorNatureUnspecified         ] = "Unspecified"
  errorNature$[ $$ErrorNatureDisconnected        ] = "Disconnected"
  errorNature$[ $$ErrorNatureDivideByZero        ] = "DivideByZero"
  errorNature$[ $$ErrorNatureIncompatible        ] = "Incompatible"
  errorNature$[ $$ErrorNatureNotConnected        ] = "NotConnected"
  errorNature$[ $$ErrorNatureLimitExceeded       ] = "LimitExceeded"
  errorNature$[ $$ErrorNatureNotInitialized      ] = "NotInitialized"
  errorNature$[ $$ErrorNatureHigherDimension     ] = "HigherDimension"
  errorNature$[ $$ErrorNatureLowestDimension     ] = "LowestDimension"
  errorNature$[ $$ErrorNatureCannotInitialize    ] = "CannotInitialize"
  errorNature$[ $$ErrorNatureInitializeFailed    ] = "InitializeFailed"
  errorNature$[ $$ErrorNatureAlreadyInitialized  ] = "AlreadyInitialized"
  errorNature$[ $$ErrorNatureInvalidAccess       ] = "InvalidAccess"
  errorNature$[ $$ErrorNatureInvalidAddress      ] = "InvalidAddress"
  errorNature$[ $$ErrorNatureInvalidAlignment    ] = "InvalidAlignment"
  errorNature$[ $$ErrorNatureInvalidArgument     ] = "InvalidArgument"
  errorNature$[ $$ErrorNatureInvalidCheck        ] = "InvalidCheck"
  errorNature$[ $$ErrorNatureInvalidCoordinates  ] = "InvalidCoordinates"
  errorNature$[ $$ErrorNatureInvalidCommand      ] = "InvalidCommand"
  errorNature$[ $$ErrorNatureInvalidData         ] = "InvalidData"
  errorNature$[ $$ErrorNatureInvalidDimension    ] = "InvalidDimension"
  errorNature$[ $$ErrorNatureInvalidEntry        ] = "InvalidEntry"
  errorNature$[ $$ErrorNatureInvalidFormat       ] = "InvalidFormat"
  errorNature$[ $$ErrorNatureInvalidKind         ] = "InvalidKind"
  errorNature$[ $$ErrorNatureInvalidIdentity     ] = "InvalidIdentity"
  errorNature$[ $$ErrorNatureInvalidInstruction  ] = "InvalidInstruction"
  errorNature$[ $$ErrorNatureInvalidLocation     ] = "InvalidLocation"
	errorNature$[ $$ErrorNatureInvalidMessage      ] = "InvalidMessage"
  errorNature$[ $$ErrorNatureInvalidName         ] = "InvalidName"
  errorNature$[ $$ErrorNatureInvalidNode         ] = "InvalidNode"
  errorNature$[ $$ErrorNatureInvalidNumber       ] = "InvalidNumber"
  errorNature$[ $$ErrorNatureInvalidOperand      ] = "InvalidOperand"
  errorNature$[ $$ErrorNatureInvalidOperation    ] = "InvalidOperation"
  errorNature$[ $$ErrorNatureInvalidReply        ] = "InvalidReply"
  errorNature$[ $$ErrorNatureInvalidRequest      ] = "InvalidRequest"
  errorNature$[ $$ErrorNatureInvalidResult       ] = "InvalidResult"
  errorNature$[ $$ErrorNatureInvalidSelection    ] = "InvalidSelection"
  errorNature$[ $$ErrorNatureInvalidSignature    ] = "InvalidSignature"
  errorNature$[ $$ErrorNatureInvalidSize         ] = "InvalidSize"
  errorNature$[ $$ErrorNatureInvalidType         ] = "InvalidType"
  errorNature$[ $$ErrorNatureInvalidValue        ] = "InvalidValue"
  errorNature$[ $$ErrorNatureInvalidVersion      ] = "InvalidVersion"
	errorNature$[ $$ErrorNatureInvalidDistribution ] = "InvalidDistribution"


END FUNCTION

END PROGRAM
