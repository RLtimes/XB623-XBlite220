'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A command line program to format and
' indent XBLite source code.
' Based upon PB code by George W. Bleck.
' Use and/or update freely at your own
' responsibility and risk. Use the -b 
' command line switch to backup your
' source program.
' (c) David Szafranski 2005 under GPL
'
PROGRAM	"formatcode"
VERSION	"0.0002"
CONSOLE

'	IMPORT	"xio"		' Console IO library
'	IMPORT	"xst"   ' Standard library : required by most programs
'	IMPORT  "xsx"

	IMPORT "xst_s.lib"
	IMPORT "xio_s.lib"
	IMPORT "xsx_s.lib"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  IndentTheLine (@sourceLine$, @newLine$, fIndentComment, @indentCount)
DECLARE FUNCTION  SplitOffComment (@sourceString$, @code$, @comment$)
DECLARE FUNCTION  IsCharLiteral (@s$, pos)
DECLARE FUNCTION  CalculateTheIndentAndOutputTheLine (@code$, @comment$, @newLine$, fIndentComment, @indentCount)
DECLARE FUNCTION  WhiteSpaceTheLine$ (@line$)
DECLARE FUNCTION  IsStringQuote (@string$, position)
DECLARE FUNCTION  AddWhiteSpace$ (@line$)
DECLARE FUNCTION  FindNextQuote (src$, index, type)
DECLARE FUNCTION  GetCommandLine (@srcFile$, @destFile$, @fIndentComment, @fBackUp)
EXPORT
DECLARE FUNCTION  FormatCode (@code$, fIndentComment)
DECLARE FUNCTION  FormatFile (fileNameSrc$, fileNameDest$, fIndentComment, fBackUp)
END EXPORT
'
$$CR_CR = "\r\r"
$$CRLF_CRLF = "\r\n\r\n"
$$DOUBLE_QUOTE = "\""
$$SINGLE_QUOTE = "\'"
$$SINGLE_SPACE = " "
$$DOUBLE_SPACE = "  "
$$SPACE_OR_QUOTE = " \""
$$TAB_OR_SPACE = "\t "
$$TAB_TAB = "\t\t"
$$TAB = "\t"
$$DQ = 1
$$SQ = 2
'
$$STATE_OPERATOR = 0
$$STATE_KEYWORD = 1
$$STATE_BRACKET = 2
$$STATE_NUMBER = 3
$$STATE_SEPARATOR = 4

'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

  IF LIBRARY(0) THEN RETURN
  GetCommandLine (@srcFile$, @destFile$, @fIndentComment, @fBackUp)
  ret = FormatFile (srcFile$, destFile$, fIndentComment, fBackUp)
  QUIT (ret)

'  in$ = "formatcode.x"
'  in$ = "C:\\xblite\\demo\\console\\uncomment\\uncomment.x"
'  out$ = "testformatcode.x"
'  FormatFile (in$, out$, $$TRUE, 0)
'  XstLoadString (out$, @code$)
'	 PRINT code$
'  PRINT
'	 a$ = INLINE$ ("Press any key to quit >")

END FUNCTION
'
'
' ###########################
' #####  FormatCode ()  #####
' ###########################
'
' Indent code based on keywords. 
' If fIndentComment is $$TRUE, then indent all
' commented lines at same level of indentation
' as previous line.
'
FUNCTION FormatCode (@code$, fIndentComment)

  IFZ code$ THEN RETURN ($$TRUE)
  XstStringToStringArray (code$, @code$[])

  upp = UBOUND(code$[])
  indentCount = 0
	FOR i = 0 TO upp
		line$ = code$[i]
		IFZ line$ THEN DO NEXT
		IndentTheLine (@line$, @newLine$, fIndentComment, @indentCount)
		code$[i] = newLine$
	NEXT i

	XstStringArrayToStringCRLF (@code$[], @code$)

END FUNCTION
'
'
' ##############################
' #####  IndentTheLine ()  #####
' ##############################
'
' Indent current line.
'
FUNCTION IndentTheLine (@sourceLine$, @newLine$, fIndentComment, @indentCount)

' remove any commented code
	SplitOffComment (@sourceLine$, @code$, @comment$)

' format code
  wsCode$ = WhiteSpaceTheLine$ (@code$)

' indent code
	CalculateTheIndentAndOutputTheLine (@wsCode$, @comment$, @newLine$, fIndentComment, @indentCount)

END FUNCTION
'
'
' ###################################################
' #####  CalculateTheIndentAndOutputTheLine ()  #####
' ###################################################
'
FUNCTION CalculateTheIndentAndOutputTheLine (@source$, @comment$, @newLine$, fIndentComment, @indentCount)

  firstWord$ = XstNextField$ (source$, @index, @done)
  firstPhrase$ = firstWord$ + " " + XstNextField$ (source$, @index, @done)
  
  index = 0
  done = 0
  DO
    prevWord$ = lastWord$
    lastWord$ = XstNextField$ (source$, @index, @done)
  LOOP UNTIL done
  lastWord$ = prevWord$
  
	SELECT CASE firstWord$
			'Check for keywords that decrement the indent
		CASE "CASE", "ELSE", "END", "LOOP", "NEXT", "ENDIF", "SUB" :
			DEC indentCount
			'If this is an END SELECT then decrement it again unless the previous line was a END SELECT
			IF (firstPhrase$ = "END SELECT" ) THEN DEC indentCount
	END SELECT

  IF indentCount < 0 THEN indentCount = 0

' identify GOTO labels - do not indent
  IF RIGHT$(firstWord$, 1) = ":" THEN fLabel = $$TRUE

' output newLine$
  SELECT CASE TRUE
    CASE fLabel       :   ' do not indent labels
      IF comment$ THEN 
        newLine$ = source$ + $$TAB_TAB + comment$
      ELSE
        newLine$ = source$
      END IF
    CASE source$ = "" :
      IF LEFT$(comment$, 1) = "?" THEN  ' do not indent ASM lines
        newLine$ = comment$
      ELSE
        IF fIndentComment THEN
          IF comment$ THEN
            comment$ = "' " + LTRIM$(MID$(comment$, 2))
            newLine$ = CHR$(9, indentCount) + comment$
          ELSE
            newLine$ = ""
          END IF
        ELSE
          newLine$ = comment$
        END IF
      END IF
    CASE comment$ = "" : newLine$ = CHR$(9, indentCount) + source$
    CASE ELSE          : newLine$ = CHR$(9, indentCount) + source$ + $$TAB_TAB + comment$
  END SELECT

	SELECT CASE firstWord$
		CASE "CASE", "ELSE", "SUB", "UNION" :
			INC indentCount
		CASE "TYPE" :
      IFZ INSTR (source$, "=") THEN INC indentCount
		CASE "SELECT"
			INC indentCount
			INC indentCount
		CASE "FUNCTION"
			INC indentCount
		CASE "FOR"
			IFZ INSTR (source$, "NEXT ") THEN INC indentCount
		CASE "DO"
			IF INSTR(source$, " LOOP", 3) = 0 && INSTR(source$, " DO", 3) = 0 && INSTR(source$, " NEXT", 3) = 0 && INSTR(source$, " FOR", 3) = 0 THEN
				INC indentCount
			END IF
	END SELECT
	IF lastWord$ = "THEN" THEN INC indentCount

END FUNCTION
'
'
' ################################
' #####  SplitOffComment ()  #####
' ################################
'
' Split source line into code and comment component strings.
'
FUNCTION SplitOffComment (@sourceString$, @code$, @comment$)

  IFZ sourceString$ THEN RETURN

	fQuotedMaterial = $$FALSE
	source$ = TRIM$(sourceString$)

  IFZ source$ THEN
    code$ = source$
    comment$ = ""
    RETURN
  END IF

	'Check if the line only has a comment or is an ASM line
	IF LEFT$(source$, 1) = "'" || LEFT$(source$, 1) = "?" THEN
		code$ = ""
		comment$ = source$
		RETURN
	END IF

	'Find the comment start if any
	nextCh = ASC(source$, 1)
	ch = ' '
	upp = LEN(source$)

	FOR pos = 1 TO upp

'    prevCh = ch
    ch = nextCh
    nextCh = ' '

    IF pos + 1 <= upp THEN nextCh = ASC(source$, pos+1)

		SELECT CASE ch
			CASE '\"' :  fQuotedMaterial = NOT fQuotedMaterial
			
			CASE '\t' :

			CASE ''' :
        skip = IsCharLiteral (@source$, pos)
        IF skip THEN                            ' it is a char literal
          pos = pos + skip
          IF pos > upp THEN EXIT FOR
          nextCh = ' '
          IF pos + 1 <= upp THEN nextCh = ASC(source$, pos+1)
          DO NEXT
        ELSE
          IF fQuotedMaterial = $$FALSE THEN
            'Break up the line
            code$ = TRIM$(LEFT$(source$, pos - 1))
            comment$ = TRIM$(MID$(source$, pos))
            RETURN
				  END IF
				END IF
		END SELECT

	NEXT pos
	'No comment found
	code$ = source$
	comment$ = ""

END FUNCTION
'
'
' ##############################
' #####  IsCharLiteral ()  #####
' ##############################
'
' Determine if char ' at pos is part of char literal
' string within string s$.
' Return value is 0 if not literal char string
' and not 0 if it is part of a literal char string
' (or optionally the number of chars to skip after initial ' pos
' if you want to jump over a literal string).
'
FUNCTION IsCharLiteral (s$, pos)

  upp = LEN(s$)

  nextCh  = ' '
  nextCh2 = ' '
  nextCh3 = ' '
  IF pos + 1 <= upp THEN nextCh  = ASC(s$, pos+1)
  IF pos + 2 <= upp THEN nextCh2 = ASC(s$, pos+2)   ' get next char
  IF pos + 3 <= upp THEN nextCh3 = ASC(s$, pos+3)   ' get next char
  
  chPrev = ' '
  chPrev2 = ' '
  chPrev3 = ' '
  IF pos - 1 >= 1 THEN chPrev  = ASC(s$, pos-1)
  IF pos - 2 >= 1 THEN chPrev2 = ASC(s$, pos-2)
  IF pos - 3 >= 1 THEN chPrev3 = ASC(s$, pos-3)
  
  SELECT CASE nextCh
    CASE '\\' :                             ' we have '\
      IF nextCh3 = ''' THEN RETURN (3)      ' we have '\char'
      
    CASE ELSE :                             ' we have 'char
      IF nextCh2 = ''' THEN RETURN (2)      ' we have 'char'
  END SELECT

  SELECT CASE chPrev
    CASE '\\' :                             ' we could have \' or '\'' or '\\'
      IF nextCh = ''' && chPrev2 = ''' THEN RETURN ($$TRUE)   ' we have '\''
      IF chPrev2 = '\\' && chPrev3 = ''' THEN RETURN ($$TRUE) ' we have '\\'

    CASE ELSE :
      IF chPrev2 = ''' THEN RETURN ($$TRUE)   ' we have 'char'
      IF chPrev2 = '\\' && chPrev3 = ''' THEN RETURN ($$TRUE)  ' we have '\char'
  END SELECT
  
  RETURN ($$FALSE)

END FUNCTION
'
'
' ###################################
' #####  WhiteSpaceTheLine$ ()  #####
' ###################################
'
' Add white space to properly format a de-commented line.
'
FUNCTION WhiteSpaceTheLine$ (line$)

  IFZ line$ THEN EXIT FUNCTION
  s$ = line$
  XstReplace (@s$, $$TAB, $$SINGLE_SPACE, 0)

  ' split line into sections based on double-quote
  ' skip over double-quoted strings
  
  pos = 0
  posStart = pos
  lineBuffer$ = ""
  len = LEN(s$)
  qType = 0
  DO 
    pos = FindNextQuote (@s$, pos+1, @qType)
    IF pos = len THEN atEnd = $$TRUE

    IF pos THEN
      SELECT CASE qType
        CASE $$DQ : 
          IF fSQ THEN DO LOOP
          IF IsStringQuote (s$, pos) THEN
            fDQ = NOT fDQ
            INC quoteCount
            posEnd = pos - 1
          ELSE
            DO LOOP
          END IF

        CASE $$SQ :
          IF fDQ THEN DO LOOP
          IF IsCharLiteral (s$, pos) THEN
            fSQ = NOT fSQ
            INC quoteCount
            posEnd = pos - 1
          ELSE
            DO LOOP
          END IF
      END SELECT
    ELSE
      posEnd = len
      quoteCount = 1    ' end of line, not a quote
    END IF

    sectionModified$ = ""
    sectionRaw$ = MID$ (s$, posStart+1, posEnd-posStart)
    posStart = posEnd + 1

    IF (quoteCount > 0) && (quoteCount MOD 2 = 0) THEN
      IF qType = $$DQ THEN
        sectionModifed$ = $$DOUBLE_QUOTE + sectionRaw$ + $$DOUBLE_QUOTE
        prev$ = RIGHT$ (lineBuffer$, 1)
        IF INSTR ("(&", prev$) THEN
          lineBuffer$ = lineBuffer$ + sectionModifed$
        ELSE
          lineBuffer$ = lineBuffer$ + $$SINGLE_SPACE + sectionModifed$
        END IF
      END IF
      IF qType = $$SQ THEN
        sectionModifed$ = $$SINGLE_QUOTE + sectionRaw$ + $$SINGLE_QUOTE
        lineBuffer$ = lineBuffer$ + $$SINGLE_SPACE + sectionModifed$
      END IF
		ELSE
			DO
			LOOP UNTIL XstReplace (@sectionRaw$, $$DOUBLE_SPACE, $$SINGLE_SPACE, 0) <= 0
			sectionRaw$ = TRIM$ (sectionRaw$)
			IFZ sectionRaw$ THEN DO LOOP

			' add white space to enable better parsing of words
			sectionRaw$ = AddWhiteSpace$ (@sectionRaw$)

      ' Loop through the each of the words in the section
      index = 0
      done = 0
      state = 0
      lastState = 0
      prev$ = ""
			DO
        word$ = XstNextField$ (sectionRaw$, @index, @done)
        lastState = state
        fSpace = $$FALSE
        prev$ = RIGHT$ (sectionModified$, 1)
				SELECT CASE word$
					CASE "=", "+", "-", "*", "<", ">", "|", "!", "^", "~", ":", "'":
					  fSpace = $$TRUE
					  state = $$STATE_OPERATOR
            SELECT CASE word$
							CASE "=" : IF INSTR ("=<>", prev$) THEN fSpace = $$FALSE
							CASE "<" : IF INSTR ("<", prev$) THEN fSpace = $$FALSE
							CASE ">" : IF INSTR ("><", prev$) THEN fSpace = $$FALSE
              CASE "!" : 
                IF INSTR ("("   , prev$) THEN fSpace = $$FALSE
                IF lastState = $$STATE_NUMBER THEN
                  fSpace = $$FALSE
                  state = $$STATE_NUMBER
                END IF
              CASE "~" : IF INSTR ("("   , prev$) THEN fSpace = $$FALSE
              CASE "*" : IF INSTR ("*"   , prev$) THEN fSpace = $$FALSE
              CASE "^" : IF INSTR ("^"   , prev$) THEN fSpace = $$FALSE
              CASE "|" : IF INSTR ("|"   , prev$) THEN fSpace = $$FALSE
              CASE "+", "-" : 
                IF lastState = $$STATE_NUMBER && (prev$ = "d" || prev$ = "e") THEN
                  fSpace = $$FALSE
                  state = $$STATE_NUMBER
                END IF
                IF prev$ = "(" THEN fSpace = $$FALSE
            END SELECT
            IF fSpace THEN
							sectionModified$ = sectionModified$+ $$SINGLE_SPACE + word$
						ELSE
							sectionModified$ = sectionModified$ + word$
						END IF
						
					CASE "[", "]", "{", "}" : 
            sectionModified$ = sectionModified$ + word$
            state = $$STATE_BRACKET

					CASE "" :   ' do nothing

					CASE ",", ";" :
            sectionModified$ = sectionModified$ + word$
            state = $$STATE_SEPARATOR

					CASE "(" :
            fSpace = $$TRUE
            state = $$STATE_BRACKET
            SELECT CASE TRUE
              CASE INSTR ("(!~", prev$) : fSpace = $$FALSE
						END SELECT
						IF fSpace THEN
							sectionModified$ = sectionModified$ + $$SINGLE_SPACE + word$
						ELSE
							sectionModified$ = sectionModified$ + word$
						END IF

					CASE ")" :
            sectionModified$ = sectionModified$ + word$
            state = $$STATE_BRACKET

					CASE ELSE :
						IF GIANT (word$) = 0 && word$ <> "0" THEN		'is it a number?
							' it is not a number, it is an intrinsic or function name or var name
							state = $$STATE_KEYWORD
							prev2$ = RIGHT$ (sectionModified$, 2)
							SELECT CASE TRUE
						    CASE INSTR ("([{!~", prev$) : sectionModified$ = sectionModified$ + word$
                CASE (prev2$ = "(-") || (prev2$ = "(+") : sectionModified$ = sectionModified$ + word$
						    CASE ELSE : sectionModified$ = sectionModified$ + $$SINGLE_SPACE + word$
							END SELECT
						ELSE
							'yes it's a number
							state = $$STATE_NUMBER
							SELECT CASE TRUE
						    CASE (lastState = $$STATE_NUMBER) || (INSTR ("({", prev$)) :
								  sectionModified$ = sectionModified$ + word$
                CASE (prev2$ = "(-") || (prev2$ = "(+") : sectionModified$ = sectionModified$ + word$
						    CASE ELSE : sectionModified$ = sectionModified$ + $$SINGLE_SPACE + word$
							END SELECT
						END IF
				END SELECT
      LOOP UNTIL done
			lineBuffer$ = lineBuffer$ + sectionModified$
		END IF

  LOOP UNTIL pos = 0 || atEnd = $$TRUE
  
  RETURN LTRIM$ (lineBuffer$)

END FUNCTION
'
' ##############################
' #####  IsStringQuote ()  #####
' ##############################
'
' Return $$TRUE if double quote at position
' in string$ is a string quote.
'
FUNCTION IsStringQuote (string$, position)

  IFZ string$ THEN RETURN

  x = position-1
  
  chPrev = ' '
  IF x - 1 >= 0 THEN chPrev = string${x-1}
  chPrev2 = ' '
  IF x - 2 >= 0 THEN chPrev2 = string${x-2}
  chNext = ' '
  IF x + 1 <= LEN(string$)-1 THEN chNext = string${x+1}

  IF chPrev = 39 && chNext = 39 THEN RETURN                   ' is '"'
  IF chPrev = 92 && chPrev2 = 39 && chNext = 39 THEN RETURN   ' is '\"'
  IF chPrev = 34 && chNext = 34 THEN RETURN                   ' is """
  IF chPrev = 92 && chPrev2 = 34 && chNext = 34 THEN RETURN   ' is "\""
	
	IF chPrev = 92 && chPrev2 <> 92 THEN RETURN   							' is \" and not "\\"

  RETURN ($$TRUE)

END FUNCTION
'
' ###############################
' #####  AddWhiteSpace$ ()  #####
' ###############################
'
' add a space char before and after each operator or bracket
' character in order to get proper tokens
'
FUNCTION AddWhiteSpace$ (@line$)
	IFZ line$ THEN EXIT FUNCTION

' replace ! operators
' this is due to the problem of a! < b! vs a !< b!
	text$ = line$
	DO
	LOOP UNTIL XstReplace (@text$, "!=", "<>", 0) <= 0
	DO
	LOOP UNTIL XstReplace (@text$, "!<=", ">", 0) <= 0
	DO
	LOOP UNTIL XstReplace (@text$, "!<", ">=", 0) <= 0
	DO
	LOOP UNTIL XstReplace (@text$, "!>=", "<", 0) <= 0
	DO
	LOOP UNTIL XstReplace (@text$, "!>", "<=", 0) <= 0
	
	newline$ = text$
		
	count = 0
	FOR i = 0 TO LEN (text$) - 1
		SELECT CASE text${i}
			CASE '(', ')', ',', '~', '|', '=', '<', '>', '+', '-', '*', '\\', '/', '{', '}', ';', '^', '!' :		' &, : have been left out
				pos = i + 2 * count
				newline$ = LEFT$ (newline$, pos) + " " + CHR$ (text${i}) + " " + RIGHT$ (newline$, LEN (newline$) - pos - 1)
				INC count
		END SELECT
	NEXT i
	RETURN newline$
END FUNCTION
'
' ##############################
' #####  FindNextQuote ()  #####
' ##############################
'
' Find next single or double quote character
'
FUNCTION FindNextQuote (src$, index, @type)

  IFZ src$ THEN RETURN
'  ftype = 0
  IF index < 1 THEN index = 1
  length = LEN(src$)
  IF index > length THEN RETURN 'length
  start = index - 1
  upp = length - 1

  FOR i = start TO upp
    ch = src${i}
      SELECT CASE ch
        CASE 34       : type = 1  : EXIT FOR ' found double quote
        CASE '''      : type = 2  : EXIT FOR ' found single quote
      END SELECT
  NEXT i

  IF i + 1 > length THEN RETURN (0)
  RETURN (i + 1)

END FUNCTION
'
' ###########################
' #####  FormatFile ()  #####
' ###########################
'
' Format source file and copy results to destination
' file. If fIndentComment is $$TRUE, then indent commented
' lines at same level of indentation as previous line.
' If fBackUp is $$TRUE, source file will be backed up to
' same name as source file but with .bak extension.

FUNCTION FormatFile (fileNameSrc$, fileNameDest$, fIndentComment, fBackUp)

  IFZ fileNameSrc$ THEN RETURN ($$TRUE)

  ' validate file extension, is xb file?
  x = INSTR(fileNameSrc$, ".")
  ext$ = UCASE$(MID$(fileNameSrc$, x+1))
  IF ext$ <> "X" && ext$ <> "XBL" THEN RETURN ($$TRUE)

  ' backup source file
  bak$ = LEFT$(fileNameSrc$, x) + "bak"
  IF fBackUp THEN
    IF XstCopyFile (fileNameSrc$, bak$) THEN RETURN ($$TRUE)
  END IF

  ' load source file and format it
  IF XstLoadString (fileNameSrc$, @code$) THEN RETURN ($$TRUE)
  FormatCode (@code$, fIndentComment)

  ' save formatted code
  IFZ fileNameDest$ THEN
    fileNameDest$ = fileNameSrc$
    ' save a backup copy of source file
    XstCopyFile (fileNameSrc$, bak$)
  END IF

  ' save formatted code
  XstSaveString (@fileNameDest$, @code$)

END FUNCTION
'
' ###############################
' #####  GetCommandLine ()  #####
' ###############################
'
' command line syntax
'
'   formatcode [-b|-i] sourcefilename destfilename
'
' -b switch means "backup the source file"
' -i switch means "indent commented lines"
' -h switch means "display help"
'
FUNCTION GetCommandLine (@srcFile$, @destFile$, @fIndentComment, @fBackUp)

  PRINT "XBLite formatcode v1.0"
  PRINT "Only for use on *.x or *.xbl files."

	XstGetCommandLineArguments (@argc, @argv$[])		' get command line
'
' get [-switch], source filename, destinaton filename from command line
'
	IF (argc > 1) THEN
		FOR i = 1 TO argc-1								' for all command line arguments
			arg$ = TRIM$(argv$[i])					' get next argument
			IF arg$ THEN										' if not empty
				char = arg${0}								' get 1st byte
				IF (char = '-') THEN					' command line switch?
					next = arg${1}							' get switch character
					SELECT CASE next								           ' which switch?
						CASE 'b'	: fBackUp = $$TRUE		         ' backup file
						CASE 'i'	: fIndentComments = $$TRUE		 ' indent commented lines
						CASE 'h'  : fHelp = $$TRUE               ' display help
					END SELECT
				ELSE													' not a switch argument
					IFZ srcFile$ THEN						' if 1st filename not yet given
						srcFile$ = arg$						' get 1st filename aka source file
					ELSE
						IFZ destFile$ THEN				' if 2nd filename not yet given
							destFile$ = arg$				' get 2nd filename aka result file
						END IF
					END IF
				END IF
			END IF
		NEXT i
	END IF
	
	IFZ hHelp THEN
    IFZ srcFile$ THEN
      PRINT
      PRINT "No source file specified."
      fHelp = $$TRUE
    END IF
  END IF
	
	IF fHelp THEN
	  PRINT
    PRINT "Command line syntax for formatcode"
    PRINT
    PRINT "formatcode [-b|-i] sourcefilename destfilename"
    PRINT
    PRINT "[-b] - backup the source file"
    PRINT "[-i] - indent commented lines"
    PRINT
    QUIT(0)
  END IF

	
END FUNCTION

END PROGRAM
