'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Compare XstGetEnvironmentVariables () with
' the Win32 function GetEnvironmentStrings ().
'
PROGRAM	"getenv"
VERSION	"0.0002"
CONSOLE
'
	IMPORT  "xsx"
	IMPORT	"xst"
	IMPORT	"xio"
	IMPORT  "kernel32"
'
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 50)
	XioCloseStdHandle (hStdOut)

	XstGetEnvironmentVariables (@count, @envp$[])
	PRINT "***** XstGetEnvironmentVariables *****"
	PRINT "count="; count
	IF envp$[] THEN
		FOR i = 0 TO UBOUND(envp$[])
			PRINT envp$[i]
		NEXT i
	END IF

	PRINT

	count = 0
	index = 0
	DIM envp$[1023]
	addr = GetEnvironmentStrings ()

	IF addr THEN
		DO
			line$ = XstNextCLine$ (addr, @index, @done)
			IF line$ THEN
				envp$[count] = line$
				INC count
			END IF
		LOOP WHILE line$
	END IF
'
	ret = FreeEnvironmentStringsA (addr)
'	PRINT "FreeEnvironmentStringsA ret="; ret

	upper = count - 1
	REDIM envp$[upper]

	PRINT "***** Environment Strings *****"
	FOR i = 0 TO upper
		PRINT "envp$["; i; "] = "; envp$[i]
	NEXT i

	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
END PROGRAM
