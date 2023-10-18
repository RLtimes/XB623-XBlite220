'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of sending raw text directly to printer
' using winspool functions.
'
PROGRAM "printdirect"
VERSION "0.0001"
CONSOLE

IMPORT  "xst"				' Standard library : required by most programs
IMPORT  "xsx"
IMPORT	"gdi32"			' gdi32.dll
IMPORT  "user32"		' user32.dll
IMPORT  "kernel32"
IMPORT  "winspool"	' printer spooling library

DECLARE FUNCTION Entry ()
DECLARE FUNCTION PrintDirect (s$, printerName$)
DECLARE FUNCTION GetDefaultPrinter (@printer$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	GetDefaultPrinter (@printer$)
	PRINT "Default Printer: "; printer$

	text$ = "All work and no play makes Jack a dull boy.\r\n"
	text$ = text$ + "All work and no play makes Jack a dull boy.\r\n"
	PrintDirect (text$, printer$) 
	PrintDirect ("\f", printer$)

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
' #########################
' #####  PrintDirect  #####
' #########################
'
' Send string directly to printer
'
FUNCTION PrintDirect (s$, printerName$)

	DOC_INFO_1 doc_info
	
	IFZ s$ THEN RETURN ($$TRUE)
	
	IFZ printerName$ THEN
		GetDefaultPrinter (@printerName$)
		IFZ printerName$ THEN 
			default$ = ""
			result$  = NULL$(1024)
			size     = LEN(result$)
			bytes = GetProfileStringA (&"windows", &"device", &default$, &result$, LEN(result$))
			IF (bytes <= 0) THEN RETURN ($$TRUE)
			profile$ = CSIZE$ (result$)
			j = INSTR(profile$, ",", 1)
			printerName$ = LEFT$(profile$, j-1)
			IFZ printerName$ THEN RETURN ($$TRUE)
		END IF
	END IF

	ret = $$TRUE
	
  IF OpenPrinterA (&printerName$, &hPrinter, NULL) THEN
    doc_info.pDocName = &"Raw Print Job"
		doc_info.pOutputFile = NULL
		doc_info.pDataType = &"RAW"
    jobid = StartDocPrinterA (hPrinter, 1, &doc_info)
		
    IF jobid THEN
			IF StartPagePrinter (hPrinter) THEN
				numBytes = LEN (s$)
				WritePrinter (hPrinter, &s$, numBytes, &written)
				IF (written == numBytes) THEN ret = 0
				EndPagePrinter (hPrinter)
			END IF
    END IF

    EndDocPrinter (hPrinter)
    ClosePrinter (hPrinter)
  END IF
  RETURN ret

END FUNCTION
'
' ###############################
' #####  GetDefaultPrinter  #####
' ###############################
'
' The GetDefaultPrinter function retrieves the printer name of the
' default printer for the current user on the local computer.
'
FUNCTION GetDefaultPrinter (@printer$)

	printer$ = ""
	
	DIM param[1]
	buffer$ = NULL$(255) 
	param[0] = &buffer$
	size = LEN(buffer$)
	param[1] = &size
	
	ret = XstCall ("GetDefaultPrinter", "winspool.drv", @param[])
	
	IFZ ret THEN RETURN ($$TRUE)
	
	printer$ = CSIZE$(buffer$)

END FUNCTION


END PROGRAM