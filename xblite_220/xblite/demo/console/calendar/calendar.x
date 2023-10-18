'
' ####################
' #####  PROLOG  #####
' ####################
'
' A console calendar.
'
PROGRAM "calendar"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
	IMPORT  "xio"				' Console input/ouput library

'
DECLARE FUNCTION Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

'   NOT A BAD LOOKING CALENDAR!
'   BY JUUITCHAN -- on 30 June 2005

	DIM ADIG$[9, 4]
	ADIG$[0,1] = ".--."
	ADIG$[1,1] = "  , "
	ADIG$[2,1] = ".--."
	ADIG$[3,1] = ".--."
	ADIG$[4,1] = " / ."
	ADIG$[5,1] = ".--'"
	ADIG$[6,1] = ".--."
	ADIG$[7,1] = ".--."
	ADIG$[8,1] = ".--."
	ADIG$[9,1] = ".--."
	ADIG$[0,2] = "|  |"
	ADIG$[1,2] = "  | "
	ADIG$[2,2] = " __|"
	ADIG$[3,2] = "  _|"
	ADIG$[4,2] = "/__|"
	ADIG$[5,2] = "|__ "
	ADIG$[6,2] = "|__ "
	ADIG$[7,2] = "   |"
	ADIG$[8,2] = "|__|"
	ADIG$[9,2] = "|__|"
	ADIG$[0,3] = "|  |"
	ADIG$[1,3] = "  | "
	ADIG$[2,3] = "|   "
	ADIG$[3,3] = "   |"
	ADIG$[4,3] = "   |"
	ADIG$[5,3] = "   |"
	ADIG$[6,3] = "|  |"
	ADIG$[7,3] = "   |"
	ADIG$[8,3] = "|  |"
	ADIG$[9,3] = "   |"
	ADIG$[0,4] = "`--'"
	ADIG$[1,4] = " -'-"
	ADIG$[2,4] = "`--'"
	ADIG$[3,4] = "`--'"
	ADIG$[4,4] = "   '"
	ADIG$[5,4] = "`--'"
	ADIG$[6,4] = "`--'"
	ADIG$[7,4] = "   |"
	ADIG$[8,4] = "`--'"
	ADIG$[9,4] = "`--'"

	BAR$ = "===================================================================="
	WHITE$ = "                        "

	' month length in days
	data$ = "\x1F\x1C\x1F\x1E\x1F\x1E\x1F\x1F\x1E\x1F\x1E\x1F"
	DIM MLEN[12]
	FOR i = 1 TO 12
		MLEN[i] = data${i-1}
	NEXT i

	' get year
	Y = XLONG (INLINE$ ("ENTER YEAR (1583-9999)? "))
	IF Y <> INT(Y) || Y < 1583 || Y > 9999 THEN QUIT (0)

	' get first day of week for calendar
first:
	WB = XLONG ( INLINE$ ("ENTER FIRST DAY OF WEEK (SUN=1,MON=2..SAT=7)? "))
	IFZ WB THEN WB = 1
	IF WB < 1 || WB > 7 || WB <> INT(WB) THEN GOTO first
	
	hStdOut = XioGetStdOut ()
	XioClearConsole (hStdOut)
	XioSetConsoleCursorPos (hStdOut, 0, 0)
	PRINT

	' get year digits
	SK = 13 - WB
	PRINT "." + BAR$ + "."
	THOU = INT(Y / 1000)
	HUND = INT(Y / 100) MOD 10
	TENS = INT(Y / 10) MOD 10
	ONES = Y MOD 10
	IF THOU * 1000 + HUND * 100 + TENS * 10 + ONES <> Y THEN QUIT (0)

	' print out selected year
	FOR i = 1 TO 4
		PRINT "|" + WHITE$ + ADIG$[THOU, i] + "  " + ADIG$[HUND, i] + "";
		PRINT ADIG$[TENS, i] + "  " + ADIG$[ONES, i] + WHITE$ + "|"
	NEXT i

	DIM MBEG[12]
	MBEG[12] = Y + INT(Y / 4) - INT(Y / 100) + INT(Y / 400) + SK
	MBEG[12] = MBEG[12] MOD 7
	IF (Y MOD 4 = 0 && Y MOD 100 > 0) || Y MOD 400 = 0 THEN MLEN[2] = 29
	
	FOR i = 11 TO 1 STEP -1
		MBEG[i] = (MBEG[i + 1] + 35 - MLEN[i]) MOD 7
	NEXT i
	
	DAYS$ = " Su Mo Tu We Th Fr Sa Su Mo Tu We Th Fr "
	DAYS$ = MID$(DAYS$, WB * 3 - 2, 22)

	DIM MNAM$[12]
	MNAM$[1] = " JANUARY "
	MNAM$[2] = " FEBRUARY"
	MNAM$[3] = "  MARCH  "
	MNAM$[4] = "  APRIL  "
	MNAM$[5] = "   MAY   "
	MNAM$[6] = "   JUNE  "
	MNAM$[7] = "   JULY  "
	MNAM$[8] = "  AUGUST "
	MNAM$[9] = "SEPTEMBER"
	MNAM$[10] = " OCTOBER "
	MNAM$[11] = " NOVEMBER"
	MNAM$[12] = " DECEMBER"

	FOR RR = 1 TO 4
		PRINT "|" + BAR$ + "|"
		FOR CC = 1 TO 3
			MM = RR * 3 + CC - 3
			PRINT "|      " + MNAM$[MM] + "       ";
		NEXT CC
		PRINT "|"
		PRINT "|" + DAYS$ + "|" + DAYS$ + "|" + DAYS$ + "|"
		FOR CRR = 0 TO 5
			FOR CC = 1 TO 3
				MM = RR * 3 + CC - 3
				PRINT "| ";
				FOR CDD = 0 TO 6
					NN = CRR * 7 + CDD + 1 - MBEG[MM]
					IF NN > 0 && NN <= MLEN[MM] THEN PRINT FORMAT$("## ", NN); 
					IF NN < 1 || NN > MLEN[MM] THEN PRINT "   ";
				NEXT CDD
			NEXT CC
			PRINT "|"
		NEXT CRR
	NEXT RR
	
	PRINT "`" + BAR$ + "'"

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM