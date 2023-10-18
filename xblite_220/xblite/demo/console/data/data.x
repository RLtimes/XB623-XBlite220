'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo which loads a data file containing
' comma-delimited numbers. The file is loaded
' into a string using XstLoadString() and
' then parsed using XstNextItem$().
'
PROGRAM	"data"
VERSION	"0.0002"
CONSOLE
'
IMPORT	"xst"
IMPORT	"xsx"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()
'
	filename$ = "numbers.dat"
	XstLoadString (@filename$, @data$)
	IFZ data$ THEN
		PRINT "No data"
		GOTO end
	END IF
'
	GOSUB PrintHeader
	index = 0
	ix = 0
'
	DO
		item$ = XstNextItem$ (@data$, @index, @terminator, @done)
		GOSUB ReportItem
	LOOP UNTIL done
'
	PRINT
	PRINT "#####   end   #####"
'
end:
	PRINT
	a$ = INLINE$("Press ENTER to exit >")
	RETURN
'
'
' *****  PrintHeader  *****
'
SUB PrintHeader
	PRINT
	PRINT "#####  data$  #####"
	PRINT data$
	PRINT "#####  start  #####"
	PRINT
	PRINT "number index terminator done"
	PRINT "------ ----- ---------- ----"
END SUB
'
'
' *****  ReportItem  *****
'
SUB ReportItem
	number$ = RJUST$(item$,6)
	index$ = RJUST$(STRING$(index),6)
	term$ = "          " + CHR$(terminator)
	IF ((terminator < 0x20) OR (terminator >= 0x80)) THEN term$ = "         " + HEX$(terminator,2)
	IF done THEN done$ = " done" ELSE done$ = " more"
	PRINT number$; index$; term$; done$
END SUB
END FUNCTION
END PROGRAM
