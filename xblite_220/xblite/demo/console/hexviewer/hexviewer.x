'
' ####################
' #####  PROLOG  #####
' ####################
'
' A hex viewer.
'
PROGRAM "hexviewer"
VERSION "0.0001"
CONSOLE
'
  IMPORT  "xst"        ' Standard library : required by most programs
  IMPORT  "xsx"        ' Extended standard library
  IMPORT  "xio"        ' Console input/ouput library
'	IMPORT	"gdi32.dec"
'  IMPORT  "user32"    ' user32.dll
  IMPORT  "kernel32"  ' kernel32.dll
'  IMPORT  "shell32"    ' shell32.dll
'  IMPORT  "msvcrt"    ' msvcrt.dll

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION HexView (@in$, @out$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	hStdOut = XioGetStdOut ()
	FillConsoleOutputAttribute (hStdOut, $$WHITE | $$BACKGROUND_BLUE | $$BACKGROUND_INTENSITY, 0xFFFFFF, 0, &written)
	XioSetTextColor (hStdOut, $$WHITE)
	XioSetTextBackColor (hStdOut, $$LIGHTBLUE)

start:
  PRINT "Enter q to Quit or"
  file$ = INLINE$ ("Enter full path of file to view ? ")
  IF LCASE$(file$) = "q" THEN QUIT(0)
  IFZ file$ THEN QUIT(0)
  
  of = OPEN (file$, $$RD)		' open file for read
  IF (of < 3) THEN 
    PRINT "File OpenError. Try Again."
    GOTO start
  END IF
  length = LOF (of)					' length of file in bytes
  in$ = NULL$ (length)			' make a string that long 
  READ [of], in$						' and read the file into in$ 
  CLOSE (of)								' then close the file  
  HexView (@in$, @out$)			' create hex output

	lines = lines + LEN(out$)/80		' approx no of lines
	XioSetConsoleBufferSize (hStdOut, 0, lines*1.5) ' make sure it can be displayed
	
	XstStringToStringArray (out$, @out$[])
	upp = UBOUND(out$[])
	FOR i = 0 TO upp
		PRINT out$[i]						' display output
	NEXT i

	PRINT
  GOTO start

END FUNCTION

FUNCTION HexView (@in$, @out$)

	out$ = ""
	IFZ in$ THEN RETURN ($$TRUE)
	
	index = 0
	done = 0
	upp = LEN (in$) - 1

	DO
		hex$ = ""
		text$ = ""
		FOR j = 0 TO 15
			IF index > upp THEN
				done = $$TRUE
				EXIT FOR
			END IF
			ch = in${index}
			INC index
			hex$ = hex$ + HEX$(ch, 2)
			IF j = 7 THEN space$ = "-" ELSE space$ = " "
			hex$ = hex$ + space$
			
			IF (ch >= 'a' && ch <= 'z' || ch >= 'A' && ch <= 'Z' || ch >= '!' && ch <= '@' || ch >= '{' && ch <= '~') THEN
				text$ = text$ + CHR$(ch)
			ELSE
				text$ = text$ + "."
			END IF
			
		NEXT j
		IFZ hex$ THEN EXIT DO
		bytes$ = HEX$(bytes, 8)
		len = LEN(hex$) 
		IF len < 48 THEN hex$ = hex$ + SPACE$(48 - len) 
		line$ = bytes$ + "  " + hex$ + "  " + text$
		out$ = out$ + line$ + "\r\n"
		bytes = bytes + 16

	LOOP UNTIL done

END FUNCTION
END PROGRAM