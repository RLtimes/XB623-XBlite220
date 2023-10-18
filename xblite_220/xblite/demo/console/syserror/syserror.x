'
' ####################
' #####  PROLOG  #####
' ####################
'
' Generate system and xblite errors.
' Display error messages.
'
PROGRAM "syserror"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
'	IMPORT  "xio"				' Console input/ouput library
' IMPORT	"gdi32"			' gdi32.dll
'	IMPORT  "user32"		' user32.dll
	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
'	IMPORT  "msvcrt"		' msvcrt.dll

'
DECLARE FUNCTION Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	PRINT "***** Generate a system error *****"

	' generate a system error
	filename$ = "blah"
	err = XxxOpen (filename$, $$RD)
	PRINT "XxxOpen err =", err
	
	' get value of last error
	lastError = ERROR (-1)
	PRINT "lastError   ="; lastError, " (system error ="; lastError >> 16; ")"

	' get system error name using system error
	XstSystemErrorNumberToName (lastError >> 16, @sysError$)
	PRINT "sysError$   = "; sysError$

	' get system error name using xblite error 
	XstErrorNumberToName (lastError, @error$)
	PRINT "error$      = "; error$

	' get system error message (name) using system error
	sysError$ = NULL$(256)
	FormatMessageA ($$FORMAT_MESSAGE_FROM_SYSTEM, 0, lastError >> 16, 0, &sysError$, LEN(sysError$), 0)
	sysError$ = TRIM$(CSIZE$(sysError$))
	PRINT "sysError$   = "; sysError$
	PRINT
	
	PRINT "***** Generate an xblite error *****"

	' generate an xblite error
	err = XstLockFileSection (1, mode, offset$$, length$$)
	PRINT "XstLockFileSection err = "; err
	
	lastError = ERROR (-1)
	PRINT "lastError              ="; lastError
	
	error$ = ""
	XstErrorNumberToName (lastError, @error$)
	PRINT "error$                 = "; error$
	
	XstErrorNameToNumber (error$, @errorNumber)
	PRINT "error number           ="; errorNumber


  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM