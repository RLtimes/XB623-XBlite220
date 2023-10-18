'
' ####################
' #####  PROLOG  #####
' ####################
'
' Search a text string for a match string.
' Can be used to search for text within any type of file.
'
PROGRAM "filesearch"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst_s.lib"				' Standard library : required by most programs
	IMPORT  "xsx_s.lib"				' Extended standard library
'	IMPORT  "xio_s.lib"				' Console input/ouput library
' IMPORT	"gdi32"			' gdi32.dll
'	IMPORT  "user32"		' user32.dll
'	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"		' msvcrt.dll

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION StringSearch (s$, find$, fFullWords, @position)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	file$ = "c:/xblite/demo/console/filesearch/filesearch.x"
	XstLoadString (file$, @s$)
	find$ = "standard"
	fFullWords = 0 
	result = StringSearch (s$, find$, fFullWords, @position) 
	PRINT "StringSearch result: "; result; " at position:"; position;
	IF result THEN 
		c = s${position}
		PRINT " and first character is: "; CHR$ (c)
	END IF

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
' ##########################
' #####  StringSearch  #####
' ##########################
'
' Search in s$ for find$, returning $$TRUE if a match is found
' at position. If fFullWords is $$TRUE, then return is $$TRUE
' if whole word is found. position is zero-based.
'
FUNCTION StringSearch (s$, find$, fFullWords, @position)

	IFZ s$ THEN RETURN
	IFZ find$ THEN RETURN

	lenFind = LEN (find$)
	bufIndex = lenFind
	bufPtr = &s$
	findPtr = &find$
	bufLen = LEN (s$)
	initBufPtr = bufPtr
	
	position = 0
	
  DO
    i = _memicmp (bufPtr, findPtr, lenFind)						' do memory comparison
    IF fFullWords THEN       													' apply restrictive pattern matching
      IFZ i THEN																			' found a match
				IF bufPtr = initBufPtr THEN
					IFZ isalpha (UBYTEAT(bufPtr+lenFind)) THEN 	' is char after non alpha
						position = bufPtr - initBufPtr
            RETURN $$TRUE
          END IF					
				ELSE
					IFZ isalpha (UBYTEAT(bufPtr-1)) THEN					' is char before non alpha
						IFZ isalpha (UBYTEAT(bufPtr+lenFind)) THEN 	' is char after non alpha
							position = bufPtr - initBufPtr
							RETURN $$TRUE
						END IF
					END IF
				END IF
      END IF
    ELSE
      IFZ i THEN 
				position = bufPtr - &s$
				RETURN $$TRUE
			END IF
    END IF
    INC bufPtr
    INC bufIndex
    IF bufIndex > bufLen THEN EXIT DO
  LOOP

END FUNCTION

END PROGRAM