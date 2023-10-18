'
' ####################
' #####  PROLOG  #####
' ####################
'
' Convert an html string to a text string, stripping all tags.
'
PROGRAM "html2txt"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
	IMPORT  "xsx"				' Extended standard library
	IMPORT  "xio"				' Console input/ouput library
'	IMPORT  "user32"		' user32.dll
'	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"		' msvcrt.dll

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION Html2Txt (@html$, @text$)
DECLARE FUNCTION CheckTag (s)

	$$PRE = -1
	$$endPRE = -2
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

  hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 128, 1000)
	XioCloseStdHandle (hStdOut)

	file$ = "test.htm"
	XstLoadString (file$, @html$)
	Html2Txt (@html$, @text$)
	PRINT text$
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
' ######################
' #####  Html2Txt  #####
' ######################
'
' Strip html tags from source html$.
'
FUNCTION Html2Txt (@html$, @text$)

	UBYTE c
	UBYTE buffer[]
	
	text$ = ""
	IFZ html$ THEN RETURN
	
	text$ = NULL$(2*LEN(html$))
	
	index = 0
  putit = 1
  blank = 0
  pre = 0

	upp = LEN(html$)-1
	FOR i = 0 TO upp
		c = html${i}
 
		SELECT CASE c

			CASE '<': 				' beginning of tag 
				buffer$ = CHR$(c)
				putit = 0
	  
			CASE '>': 				' end of tag
				buffer$ = buffer$ + CHR$(c)
				c = CheckTag (&buffer$)

				SELECT CASE c
					CASE $$PRE:
						pre = 1
					CASE $$endPRE:
						pre = 0
					CASE ' ':
						IF (!blank) THEN text${index} = c : INC index
						blank = 1
					CASE ELSE:
						blank = 0
						text${index} = c : INC index
				END SELECT
				putit = 1
	  
			CASE '\n', '\r': 							' end of line is not considered unless we are not in PRE section 
				IF (pre) THEN
					text${index} = c : INC index 
				ELSE
					text${index} = 32 : INC index
				END IF
	  
			CASE ELSE :

				IF (putit) THEN   					' the character has to be printed 
					IF (c == ' ' && !pre) THEN
						IF (!blank) THEN 
							text${index} = c : INC index 
							blank = 1
						END IF
					ELSE
						text${index} = c : INC index
						blank = 0
					END IF

				ELSE 											' just store the character (in a tag)
					IF c <> '\n' && c <> '\r' THEN 
						buffer$ = buffer$ + CHR$(c)
					END IF
				
				END IF
		END SELECT
	NEXT i
	
	text$ = CSIZE$(text$)
	text$ = TRIM$(text$)
	
	XstReplace (@text$, "&nbsp;", " ", 0)
	XstReplace (@text$, "&lt;",   "<", 0)
	XstReplace (@text$, "&gt;",   ">", 0)
	XstReplace (@text$, "&quot;", "\"", 0)
	XstReplace (@text$, "amp;",   "&", 0)
	XstReplace (@text$, "&copy;", "(c)", 0)
	XstReplace (@text$, "&reg;",  "(R)", 0)
	
	DO WHILE XstReplace (@text$, "  ", " ", 0)
	LOOP

END FUNCTION
'
' ######################
' #####  CheckTag  #####
' ######################
'
'
'
FUNCTION CheckTag (s)

  ' check which HTML tag found 
  IF (!_strcmpi(s, &"<TR>"))   THEN RETURN ('\n')
  IF (!_strcmpi(s, &"</TH>"))  THEN RETURN ('\t')
  IF (!_strcmpi(s, &"</TD>"))  THEN RETURN ('\t')
  IF (!_strcmpi(s, &"<BR>"))   THEN RETURN ('\n')
  IF (!_strcmpi(s, &"<PRE>"))  THEN RETURN ($$PRE)
  IF (!_strcmpi(s, &"</PRE>")) THEN RETURN ($$endPRE)
  RETURN (' ')

END FUNCTION
END PROGRAM