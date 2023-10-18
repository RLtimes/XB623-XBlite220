'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo which uses an UnComment()
' function to remove any comments
' from a line of code.
'
PROGRAM	"uncomment"
VERSION	"0.0003"
CONSOLE
'
IMPORT	"xst"
IMPORT	"xsx"
IMPORT	"xio"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  UnComment$ (@line$, @comment$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 50)
	XioCloseStdHandle (hStdOut)

	DIM text$[7]
	upper = UBOUND (text$[])

	text$[0] = "A normal line of text without any comments"
	text$[1] = "'This is some text in a commented line"
	text$[2] = "IF LIBRARY(0) THEN RETURN    ' main program has message loop"
	text$[3] = "$$ResetAssembly	= 1          ' For ResetDataDisplays()"
	text$[4] = "IF entry THEN RETURN         ' enter once"
	text$[5] = "CASE 'a' : PRINT \"Do Something 'NOW' \"  ' this is the comment part"
	text$[6] = "IF LEFT$(source$, 1) = \"'\" || LEFT$(source$, 1) = \"?\" THEN x = 0"
	text$[7] = "CASE '\"', ''', '!', '%', '\\', '\t', '\a' : DO NEXT  ' this is the comment"

	FOR i = 0 TO upper
		PRINT
		PRINT " ***** Original *****"
		PRINT text$[i]
		PRINT

		PRINT " ***** Uncommented *****"
		new$ = UnComment$ (text$[i], @comment$)
		PRINT "code   : "; new$
		PRINT "comment: "; comment$
	NEXT i

	PRINT
	a$ = INLINE$("Press ENTER to exit >")

	RETURN

END FUNCTION
'
'
' ###########################
' #####  UnComment$ ()  #####
' ###########################
'
' PURPOSE	: Remove commented part of line
' IN      : line$ - line of code to remove comment
' OUT     : comment$ - extracted comment string
'	RETURN	: Decommented line of code
'
FUNCTION  UnComment$ (@line$, @comment$)

  $STATE_DEFAULT = 0
  $STATE_COMMENT = 1
  $STATE_STRING = 2
  $STATE_CHAR = 3

  comment$ = ""

	IFZ line$ THEN
    RETURN ""
  ENDIF

  text$ = TRIM$(line$)

  ' see if entire line is commented
  IF text${0} = ''' THEN
    comment$ = text$
    RETURN ""
  ENDIF

  chPrev = ' '
  upp = LEN(text$) - 1
  FOR i = 0 TO upp
  	statePrev = state
  	ch = text${i}
		chNext 	= ' '
		chNext2 = ' '
		chNext3 = ' '
		IF i+1 <= upp THEN chNext  = text${i+1}
		IF i+2 <= upp THEN chNext2 = text${i+2}
		IF i+3 <= upp THEN chNext3 = text${i+3}
    SELECT CASE state

    	CASE $STATE_DEFAULT
				SELECT CASE ch
					CASE '''
						IF (chNext2 = ''') || ((chNext = '\\') && (chNext3 = ''')) THEN
							state = $STATE_CHAR
						ELSE
							state = $STATE_COMMENT
							pos = i + 1
							EXIT FOR
						ENDIF
						startSeg = i
					CASE '\"'
						state = $STATE_STRING
						startSeg = i
				END SELECT

			CASE $STATE_CHAR
				IF ch = ''' THEN
					IF ((chNext = ''') && (chPrev = ''')) THEN
					ELSE
						state = $STATE_DEFAULT
						INC i
						ch = chNext
						chNext = ' '
						IF (i + 1 < upp) THEN chNext = text${i + 1}
						startSeg = i
					ENDIF
				ENDIF

			CASE $STATE_STRING
				SELECT CASE ch
					CASE '\\'
						IF (chNext = '\"') || (chNext = ''') || (chNext = '\\') THEN
							INC i
							ch = chNext
							chNext = ' '
							IF (i + 1 < upp) THEN chNext = text${i + 1}
						ENDIF
					CASE '\"'
						state = $STATE_DEFAULT
						INC i
						ch = chNext
						chNext = ' '
						IF (i + 1 < upp) THEN chNext = text${i + 1}
						startSeg = i
					END SELECT
			END SELECT

    chPrev = ch
  NEXT i

  IF pos THEN
    comment$ = MID$(text$, pos)
    RETURN (LEFT$(text$, pos-1))
  ENDIF

  ' no comment found
  RETURN (text$)

END FUNCTION
END PROGRAM
