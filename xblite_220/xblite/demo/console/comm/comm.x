'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo to get default COM1 configuration
' settings using GetDefaultCommConfigA.
'
PROGRAM	"comm"
VERSION	"0.0001"
CONSOLE
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT	"xio"
	IMPORT	"gdi32"
	IMPORT	"kernel32"
	IMPORT	"user32"

DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	COMMCONFIG cc

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 100)
	XioCloseStdHandle (hStdOut)

	size  = SIZE (cc)
	port$ = "COM1"

	IFZ GetDefaultCommConfigA (&port$, &cc, &size) THEN
		error = GetLastError ()
		XstSystemErrorNumberToName (error, @error$)
		PRINT "GetDefaultCommConfigA : "; error$
		PRINT "DCB size required ="; size
		GOTO end
	END IF

	PRINT "***** COM1 Default Settings *****"
	PRINT

	PRINT "DCB size          ="; size
	PRINT "DCBLength         ="; cc.dcb.DCBlength
	PRINT "BaudRate          ="; cc.dcb.BaudRate

	bits = cc.dcb.fModes

	PRINT "fBinary           ="; bits{$$DCB_fBinary}
	PRINT "fParity           ="; bits{$$DCB_fParity}
	PRINT "fOutxCtsFlow      ="; bits{$$DCB_fOutxCtsFlow}
	PRINT "fOutxDsrFlow      ="; bits{$$DCB_fOutxDsrFlow}
	PRINT "fDtrControl       ="; bits{$$DCB_fDtrControl}
	PRINT "fDsrSensitivity   ="; bits{$$DCB_fDsrSensitivity}
	PRINT "fTXContinueOnXoff ="; bits{$$DCB_fTXContinueOnXoff}
	PRINT "fOutX             ="; bits{$$DCB_fOutX}
	PRINT "fInX              ="; bits{$$DCB_fInX}
	PRINT "fErrorChar        ="; bits{$$DCB_fErrorChar}
	PRINT "fNull             ="; bits{$$DCB_fNull}
	PRINT "fRtsControl       ="; bits{$$DCB_fRtsControl}
	PRINT "fAbortOnError     ="; bits{$$DCB_fAbortOnError}

	PRINT "XonLim            ="; cc.dcb.XonLim
	PRINT "XoffLim           ="; cc.dcb.XoffLim
	PRINT "ByteSize          ="; cc.dcb.ByteSize
	PRINT "Parity            ="; cc.dcb.Parity
	PRINT "StopBits          ="; cc.dcb.StopBits
	PRINT "XonChar           ="; cc.dcb.XonChar
	PRINT "XoffChar          ="; cc.dcb.XoffChar
	PRINT "ErrorChar         ="; cc.dcb.ErrorChar
	PRINT "EofChar           ="; cc.dcb.EofChar
	PRINT "EvtChar           ="; cc.dcb.EvtChar

end:
	PRINT
	a$ = INLINE$ ("Press any key to Quit >")


END FUNCTION
END PROGRAM
