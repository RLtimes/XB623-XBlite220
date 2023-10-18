'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of WrapText$(), a word wrapping function.
'
PROGRAM	"wordwrap"
VERSION	"0.0001"
CONSOLE
'
IMPORT "xst"
IMPORT "xio"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WrapText$ (text$, nLength)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 250)
	XioCloseStdHandle (hStdOut)

	PRINT "text$ :"
	in$ = "A few blocks away, at Twelfth and Pennsylvania, the assassination of Vice\nPresident Andrew Johnson is set to take place at the same time. All\nseemed ready. That evening, an unsuspecting Johnson had eaten a leisurely\nmeal in the dining room of the Kirkwood House."
	PRINT in$
	PRINT

	FOR i = 4 TO 40 STEP 4
		PRINT "WrapText$() wrapped at"; i; " characters"
		PRINT CHR$('#', i)
		out$ = WrapText$ (in$, i)
		PRINT out$
		PRINT CHR$('#', i)
		PRINT
	NEXT i

	PRINT
	a$ = INLINE$("Press ENTER to exit >")
END FUNCTION
'
'
' ##########################
' #####  WrapText$ ()  #####
' ##########################
'
' PURPOSE	: Word wrap a text string to a specified length.
' IN			: text$ - text string to wrap
' 				: nLength - length of line
'
' NOTE		: Wrapped lines will use LF ("\n") as the new line char.
'           Words that are longer than nLength will not be broken.
'						Existing newline \n chars are not modified.
'
' RETURN	: return is a word-wrapped string
'
FUNCTION  WrapText$ (text$, nLength)

	IFZ text$ THEN RETURN ""
	IFZ nLength THEN RETURN ""

	len = LEN (text$)

	IF len <= nLength THEN RETURN text$				' no need to go any further

' this is a hack to deal with \r chars
' by just stripping them
	IF INSTRI (text$, "\r") THEN
		upper = len - 1
		out$ = NULL$(len)
		FOR i = 0 TO upper
			char = text${i}
			SELECT CASE char
				CASE 13 :
				CASE ELSE : out${pos} = char : INC pos
			END SELECT
		NEXT i
		text1$ = TRIM$(out$)
	ELSE
		text1$ = text$
	END IF

	len = LEN (text1$)
	upper = len - 1
	out$ = NULL$ (len)

	pos = 0
	count = 1

	FOR i = 0 TO upper

		char = text1${i}

		SELECT CASE char

			CASE 10 	:
				out${pos} = 10												' normal \n
				count = 1															' reset count
				lastSpace = 0													' reset last space char position

			CASE 32 	:
				out${pos} = 32
				lastSpace = i													' remember position of last space char

			CASE ELSE :	out${pos} = char

		END SELECT

		IF count = nLength THEN
			IF (i+1) <= upper THEN
				nextChar = text1${i+1}								' peek next character
				SELECT CASE nextChar
					CASE 32, 10 :
						DEC count													' wait for the next char

					CASE ELSE :
						IF lastSpace THEN									' word is shorter than nLength
							out${lastSpace} = 10						' replace last space with \n
							count = pos - lastSpace					' move count back to position after \n
							lastSpace = 0
						ELSE															' word is longer than nLength
							DEC count												' try next char until a space is reached
						END IF

				END SELECT
			END IF
		END IF

		INC count
		INC pos

	NEXT i

	RETURN (out$)


END FUNCTION
END PROGRAM
