'
'
' ####################
' #####  PROLOG  #####
' ####################

' The DrawHTML() function is nearly a drop-in
' replacement of the standard DrawText() function,
' with limited support for HTML formatting tags..
'
PROGRAM	"drawhtml"
VERSION	"0.0001"

	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
'
TYPE TAGS
  STRING * 32 .mnemonic ' html tag
  XLONG .token          ' token type : $$tB, $$tBR...
  XLONG .param          ' number of parameters
  XLONG .block          ' block html? <font> </font>
END TYPE

TYPE TOKENDATA
  XLONG .token      ' token type
  XLONG .start      ' starting position of token in string (0 based)
  XLONG .end        ' ending position of token in string
  XLONG .space      ' space precedes text token? T/F
END TYPE

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()

DECLARE FUNCTION  InitTags ()
DECLARE FUNCTION  GetTokens (@html$, TOKENDATA tdata[]) 
DECLARE FUNCTION  DrawHTML (hdc, html$, rectAddr, format)
DECLARE FUNCTION  PushColor(hdc, clr)
DECLARE FUNCTION  PopColor (hdc)
DECLARE FUNCTION  ParseColor (text$, pos)
DECLARE FUNCTION  GetFontVariant (hdc, hfontSource, styles)

$$ENDFLAG   = 0x100
$$STACKSIZE = 8

' text formats
$$FV_BOLD        = 0x01
$$FV_ITALIC      = 0x02 '(FV_BOLD << 1)
$$FV_UNDERLINE   = 0x04 '(FV_ITALIC << 1)
$$FV_SUPERSCRIPT = 0x08 '(FV_UNDERLINE << 1)
$$FV_SUBSCRIPT   = 0x10 '(FV_SUPERSCRIPT << 1)
$$FV_NUMBER      = 0x20 '(FV_SUBSCRIPT << 1)

' tokens
$$tNONE    = 0    ' text
$$tB       = 1    ' bold
$$tBR      = 2    ' break
$$tFONT    = 3    ' font
$$tI       = 4    ' italic
$$tP       = 5    ' paragraph
$$tSUB     = 6    ' subscript
$$tSUP     = 7    ' superscript
$$tU       = 8    ' underline
$$tUNK     = 9    ' unknown type of tag (to be added later)
$$tNUMTAGS = 10   ' number of token types

'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

  TOKENDATA tdata[]

'	XioCreateConsole (title$, 850)	' create console, if console is not wanted, comment out this line

'  InitTags ()
  
'  html$ = "<p>Beauty, success, truth ..."
'  html$ = html$ + "<br><em>He is blessed who has two.</em>" + "\n\r"
'  html$ = html$ + "<br><font color='#C00000'><b>Your program has none.</b></font>" + "\n\r"
'  html$ = html$ + "<p><em>Ken Carpenter</em>"
'  GetTokens (@html$, @tdata[])
  
'  upp = UBOUND (tdata[])
'  FOR i = 0 TO upp
'    PRINT "token:"; tdata[i].token
'    PRINT "start:"; tdata[i].start
'    PRINT "end  :"; tdata[i].end
'    len = tdata[i].end-tdata[i].start
'    PRINT "tag  : "; MID$ (html$, tdata[i].start+1, len)
'    PRINT "len  :"; len
'    PRINT
'  NEXT i
  
'  a$ = INLINE$ ("Press any key to quit")

	InitGui ()										' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create main windows and other child controls
	MessageLoop ()								' the message loop
	CleanUp ()										' unregister all window classes
'	XioFreeConsole ()							' free console

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	PAINTSTRUCT ps
	RECT rc
	STATIC hfontBase
	
	$MARGIN = 10

	SELECT CASE msg

		CASE $$WM_CREATE:
		  InitTags ()
		  hfontBase = CreateFontA (20, 0, 0, 0, $$FW_NORMAL, 0, 0, 0, $$ANSI_CHARSET, $$ANSI_CHARSET, $$CLIP_DEFAULT_PRECIS, $$DEFAULT_QUALITY, $$VARIABLE_PITCH, &"Georgia")

		CASE $$WM_PAINT:
			hdc = BeginPaint (hWnd, &ps)

			hfontOrg = SelectObject (hdc, hfontBase)
      GetClientRect (hWnd, &rc)
      SetRect (&rc, rc.left + $MARGIN, rc.top + $MARGIN, rc.right - $MARGIN, rc.bottom - $MARGIN)

      html$ = "Beauty, success, truth ..."
      html$ = html$ + "<br><em>He is blessed who has two.</em>" + "\n\r"
      html$ = html$ + "<br><font color='#C00000'><b>Your program has all three.</b></font>" + "\n\r"
      html$ = html$ + "<p><em>XBLite!</em>"
      html$ = html$ + "<br>Normal Text<sub>subscript</sub><sup>superscript</sup>"
      html$ = html$ + "<br><font color='#00FF00'><u>How about them apples;-)</u>"

      DrawHTML (hdc, @html$, &rc, $$DT_WORDBREAK)

      SelectObject (hdc, hfontOrg)
			EndPaint (hWnd, &ps)

		CASE $$WM_DESTROY:
		  DeleteObject (hfontBase)
			PostQuitMessage (0)

    CASE ELSE :
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT
END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
FUNCTION  InitGui ()

	SHARED hInst

	hInst = GetModuleHandleA (0) 	' get current instance handle
	IFZ hInst THEN QUIT(0)

END FUNCTION
'
'
' #################################
' #####  RegisterWinClass ()  #####
' #################################
'
FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)

	SHARED hInst
	WNDCLASS wc

	wc.style           = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc     = addrWndProc
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &icon$)
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = $$COLOR_WINDOW + 1    ' $$COLOR_BTNFACE + 1
	wc.lpszMenuName    = &menu$
	wc.lpszClassName   = &className$

	IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

	SHARED hInst, className$

' register window class
	className$  = "DrawHTMLDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "DrawHTML Demo."
	#winMain = NewWindow (className$, titleBar$, $$WS_OVERLAPPEDWINDOW, x, y, 300, 200, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window
	UpdateWindow (#winMain)

END FUNCTION
'
'
' ##########################
' #####  NewWindow ()  #####
' ##########################
'
FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

	SHARED hInst

	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

  MSG msg
' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, 0, 0, 0)			' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
  			TranslateMessage (&msg)						' translate virtual-key messages into character messages
  			DispatchMessageA (&msg)						' send message to window callback function WndProc()
		END SELECT
	LOOP

END FUNCTION
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$
	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' #########################
' #####  InitTags ()  #####
' #########################
'
FUNCTION  InitTags ()

SHARED TAGS tags[]
SHARED stack[]

  DIM tags[10]
  
  ' order mnemonic tags alphabetically

  tags[0].mnemonic = ""       : tags[0].token = $$tNONE : tags[0].param = 0 : tags[0].block = 0
  tags[1].mnemonic = "b"      : tags[1].token = $$tB    : tags[1].param = 0 : tags[1].block = 0
  tags[2].mnemonic = "br"     : tags[2].token = $$tBR   : tags[2].param = 0 : tags[2].block = 1
  tags[3].mnemonic = "em"     : tags[3].token = $$tI    : tags[3].param = 0 : tags[3].block = 0
  tags[4].mnemonic = "font"   : tags[4].token = $$tFONT : tags[4].param = 1 : tags[4].block = 0
  tags[5].mnemonic = "i"      : tags[5].token = $$tI    : tags[5].param = 0 : tags[5].block = 0
  tags[6].mnemonic = "p"      : tags[6].token = $$tP    : tags[6].param = 0 : tags[6].block = 1
  tags[7].mnemonic = "strong" : tags[7].token = $$tB    : tags[7].param = 0 : tags[7].block = 0
  tags[8].mnemonic = "sub"    : tags[8].token = $$tSUB  : tags[8].param = 0 : tags[8].block = 0
  tags[9].mnemonic = "sup"    : tags[9].token = $$tSUP  : tags[9].param = 0 : tags[9].block = 0
  tags[10].mnemonic = "u"     : tags[10].token = $$tU   : tags[10].param = 0 : tags[10].block = 0
  
  DIM stack[$$STACKSIZE-1]
  
END FUNCTION
'
'
' ##########################
' #####  GetTokens ()  #####
' ##########################
'
' Break up html string into an array of tokens.
'
FUNCTION  GetTokens (@html$, TOKENDATA tdata[])

SHARED TAGS tags[]

  htm$ = html$
  IFZ htm$ THEN RETURN ($$TRUE)
  
  DIM tdata[64]

  upp = LEN (htm$)
  max = upp - 1

  FOR i = 0 TO max
    ch = htm${i}
    SELECT CASE ch

      CASE '<' :
        tagOn = $$TRUE              ' we have a html tag
        isEndTag = 0
        IF i <= max-1 THEN
          IF htm${i+1} = '/' THEN   ' check for ending block tag
            isEndTag = $$ENDFLAG    ' we got one
            INC i
          END IF
        END IF
        start = i + 1               ' set starting point of tag in string (0 based)
        
      CASE '>' :                    ' end of tag
        tagOn = $$FALSE
        tag$ = LCASE$ (tag$)        ' convert tag to lowercase
        index = 0
        end = i                     ' set ending point of tag in string
        u = UBOUND (tags[])
        FOR j = u TO 1 STEP -1      ' find out what kind of tag it is (start from largest size to smallest, reverse alphabetical)
          t$ = tags[j].mnemonic
          l = LEN (t$)
          tmptag$ = LEFT$ (tag$, l)
          IF tmptag$ = t$ THEN      ' compare it to all of the standard tags
            index = j               ' set index to matching tag
            EXIT FOR
          END IF
        NEXT j
        
        IFZ index THEN index = $$tUNK   ' unknown tag

        tdata[tagCount].token = tags[index].token | isEndTag    ' copy data to array
        tdata[tagCount].start = start
        tdata[tagCount].end = end
        INC tagCount                ' keep track of total tag count
        upper = UBOUND (tdata[])
        IF tagCount > upper THEN REDIM tdata[upper*2]
        
      CASE 10, 13 :                 ' skip crlf's
      
      CASE 32 :                     ' skip initial leading spaces of textout

      CASE ELSE :                   ' we have text of tag or textout
        tag$ = ""
        IFF tagOn THEN start = i    ' keep track of starting point for textout
        fSpace = 0                  ' does a word have a delimiting space before it?

        DO UNTIL i = max            ' loop until will get to next < or >
          chr = htm${i}
          tag$ = tag$ + CHR$(chr)   ' collect characters until end of text or find next tag
          IF i <= max - 1 THEN
            next = htm${i+1}
            IF next = '<' || next = '>' THEN EXIT DO  ' found next block, stop here
            IFF tagOn THEN
              IF next = ' ' THEN    ' parse textout by spaces between words
                fSpace = $$TRUE     ' delimiting space found after current word
                EXIT DO
              END IF
            END IF
          END IF
          INC i
        LOOP
'        PRINT "tag$="; tag$

        IFF tagOn THEN              ' we have textout
          tag$ = TRIM$ (tag$)
          IFZ tag$ THEN
            tdata[tagCount].token = $$TRUE  ' no printable text
          ELSE
            tdata[tagCount].token = $$tNONE
          END IF
          end = i + 1
          IF end > max THEN end = max
          tdata[tagCount].start = start
          tdata[tagCount].end   = end
          tdata[tagCount+1].space = fSpace  ' the NEXT tag has a space before it
          INC tagCount
          upper = UBOUND (tdata[])
          IF tagCount > upper THEN REDIM tdata[upper*2]
        END IF
        
     END SELECT
  NEXT i

  REDIM tdata[tagCount-1]

END FUNCTION
'
'
' #########################
' #####  DrawHTML ()  #####
' #########################
'
' Draw HTML into selected hdc using area given by
' RECT and according to format.
'
FUNCTION  DrawHTML (hdc, html$, lpRect, format)

  SIZEAPI size
  POINT curPos
  RECT rc, rect
  TOKENDATA tdata[]
  SHARED stacktop
  
  DIM hfontSpecial[$$FV_NUMBER-1]

  IF (hdc == 0 || html$ == "") THEN RETURN ($$TRUE)

  IF (lpRect != 0) THEN
    RtlMoveMemory (&rect, lpRect, SIZE (rect))
    left = rect.left
    top = rect.top
    maxWidth = rect.right - rect.left
  ELSE
    GetCurrentPositionEx (hdc, &curPos)
    left = curPos.x
    top = curPos.y
    maxWidth = GetDeviceCaps (hdc, $$HORZRES) - left
  END IF
  IF (maxWidth < 0) THEN maxWidth = 0

  ' toggle flags we do not support
  uFormat = uFormat & ~($$DT_CENTER | $$DT_RIGHT | $$DT_TABSTOP)
  uFormat = uFormat | ($$DT_LEFT | $$DT_NOPREFIX)

  ' get the "default" font from the DC 
  savedDC = SaveDC (hdc)
  hfontBase = SelectObject (hdc, GetStockObject ($$SYSTEM_FONT))
  SelectObject (hdc, hfontBase)

  ' clear the other fonts, they are created "on demand" 
  FOR index = 0 TO $$FV_NUMBER-1
    hfontSpecial[index] = 0
  NEXT index
  hfontSpecial[0] = hfontBase
  styles = 0 ' assume the active font is normal weight, roman, non-underlined

  ' get font height (use characters with ascender and descender)
  ' we make the assumption here that changing the font style will
  ' not change the font height
   
  GetTextExtentPoint32A (hdc, &"Åy", 2, &size)
  lineHeight = size.cy

  ' run through the string, word for word
  xPos = 0
  minWidth = 0
  stacktop = 0
  curStyles = -1 ' force a select of the proper style
  height = 0

  ' parse html string into array of tokens
  GetTokens (@html$, @tdata[])
  upper = UBOUND (tdata[])

  FOR i = 0 TO upper
    tag = tdata[i].token
    IF (tag < 0) THEN DO NEXT

    whiteSpace = tdata[i].space
    len = tdata[i].end - tdata[i].start
    word$ = MID$ (html$, tdata[i].start+1, len)
'PRINT "tag  ="; tag
'PRINT "word = "; word$
'PRINT

    SELECT CASE (tag & ~$$ENDFLAG)
      CASE $$tP:
        IF ((tag & $$ENDFLAG) == 0 && (uFormat & $$DT_SINGLELINE) == 0) THEN
          height = height + (3 * lineHeight / 2.0)
          xPos = 0
        END IF

      CASE $$tBR:
        IF ((tag & $$ENDFLAG) == 0 && (uFormat & $$DT_SINGLELINE) == 0) THEN
          height = height + lineHeight
          xPos = 0
        END IF

      CASE $$tB:
        IF (tag & $$ENDFLAG) THEN
          styles = styles & ~$$FV_BOLD
        ELSE
          styles = styles | $$FV_BOLD
        END IF

      CASE $$tI:
        IF (tag & $$ENDFLAG) THEN
          styles = styles & ~$$FV_ITALIC
        ELSE
          styles = styles | $$FV_ITALIC
        END IF

      CASE $$tU:
        IF (tag & $$ENDFLAG) THEN
          styles = styles & ~$$FV_UNDERLINE
        ELSE
          styles = styles | $$FV_UNDERLINE
        END IF

      CASE $$tSUB:
        IF (tag & $$ENDFLAG) THEN
          styles = styles & ~$$FV_SUBSCRIPT
        ELSE
          styles = styles | $$FV_SUBSCRIPT
        END IF

      CASE $$tSUP:
         IF (tag & $$ENDFLAG) THEN
          styles = styles & ~$$FV_SUPERSCRIPT
        ELSE
          styles = styles | $$FV_SUPERSCRIPT
        END IF

      CASE $$tFONT:
        IF ((tag & $$ENDFLAG) == 0) THEN
          x = INSTR (word$, "color=")
          IF x THEN PushColor (hdc, ParseColor (word$, x+6))
        ELSE
          PopColor (hdc)
        END IF

      CASE $$tUNK : DO NEXT

      CASE $$tNONE | $$ENDFLAG : DO NEXT

      CASE $$tNONE :

        IF (curStyles != styles) THEN
          IF (hfontSpecial[styles] == 0) THEN
            hfontSpecial[styles] = GetFontVariant (hdc, hfontBase, styles)
          END IF
          curStyles = styles
          SelectObject (hdc, hfontSpecial[styles])
          ' get the width of a space character (for word spacing)
          GetTextExtentPoint32A (hdc, &" ", 1, &size)
          widthOfSpace = size.cx
        END IF

        ' check word length, check whether to wrap around
        GetTextExtentPoint32A (hdc, &word$, LEN (word$), &size)
        IF (size.cx > maxWidth) THEN maxWidth = size.cx   ' must increase width: long non-breakable word

        IF (whiteSpace) THEN
          xPos = xPos + widthOfSpace
        END IF

        IF (xPos + size.cx > maxWidth && whiteSpace) THEN
          IF ((uFormat & $$DT_WORDBREAK) != 0) THEN
            ' word wrap
            height = height + lineHeight
            xPos = 0
          ELSE
            ' no word wrap, must increase the width
            maxWidth = xPos + size.cx
          END IF
        END IF
        ' output text (unless DT_CALCRECT is set)
        IF ((uFormat & $$DT_CALCRECT) == 0) THEN
          ' handle negative heights, too (suggestion of "Sims")
          IF (top < 0) THEN
            SetRect (&rc, left + xPos, top - height, left + maxWidth, top - (height + lineHeight))
          ELSE
            SetRect (&rc, left + xPos, top + height, left + maxWidth, top + height + lineHeight)
          END IF

          ' reposition subscript text to align below the baseline
          IF (styles & $$FV_SUBSCRIPT) THEN
            subFormat = uFormat | ($$DT_BOTTOM | $$DT_SINGLELINE)
            DrawTextA (hdc, &word$, LEN(word$), &rc, subFormat)
          ELSE
            DrawTextA (hdc, &word$, LEN(word$), &rc, uFormat)
          END IF

          ' for the underline style, the spaces between words should be
          ' underlined as well
         
          IF (whiteSpace && (styles & $$FV_UNDERLINE) && xPos >= widthOfSpace) THEN
            IF (top < 0) THEN
              SetRect (&rc, left + xPos - widthOfSpace, top - height, left + xPos, top - (height + lineHeight))
            ELSE
              SetRect (&rc, left + xPos - widthOfSpace, top + height, left + xPos, top + height + lineHeight)
            END IF
            DrawTextA (hdc, &" ", 1, &rc, uFormat)
          END IF

          ' update current position
          xPos = xPos + size.cx
          IF (xPos > minWidth) THEN minWidth = xPos
        END IF

    END SELECT
  NEXT i

  RestoreDC (hdc, savedDC)
  FOR index = 1 TO $$FV_NUMBER-1        ' do not erase hfontSpecial[0]
    IF (hfontSpecial[index] != 0) THEN
      DeleteObject(hfontSpecial[index])
    END IF
  NEXT index

  ' store width and height back into the lpRect structure 
  IF ((uFormat & $$DT_CALCRECT) != 0 && lpRect != NULL) THEN
    rect.right = rect.left + minWidth
    IF (rect.top < 0) THEN
      rect.bottom = rect.top - (height + lineHeight)
    ELSE
      rect.bottom = rect.top + height + lineHeight
    END IF
    RtlMoveMemory (lpRect, &rect, SIZE(rect))
  END IF

  RETURN height

END FUNCTION
'
'
' ##########################
' #####  PushColor ()  #####
' ##########################
'
FUNCTION PushColor (hdc, clr)

SHARED stack[]
SHARED stacktop

  IF (stacktop < $$STACKSIZE) THEN
    stack[stacktop] = GetTextColor (hdc)
    INC stacktop
  END IF
  SetTextColor (hdc, clr)

END FUNCTION
'
'
' #########################
' #####  PopColor ()  #####
' #########################
'
FUNCTION PopColor (hdc)

SHARED stack[]
SHARED stacktop

  okay = (stacktop > 0)

  IF (okay) THEN
    DEC stacktop
    clr = stack[stacktop]
  ELSE
    clr = stack[0]
  END IF
  SetTextColor (hdc, clr)
  RETURN okay

END FUNCTION
'
'
' ###########################
' #####  ParseColor ()  #####
' ###########################
'
FUNCTION  ParseColor (text$, pos)

  a$ = MID$ (text$, pos, 1)
  IF (a$ = "'") || (a$ = "\"") THEN INC pos
  a$ = MID$ (text$, pos, 1)
  IF a$ = "#" THEN INC pos

  red = XLONG ("0x" + MID$ (text$, pos, 2))
  pos = pos + 2
  green = XLONG ("0x" + MID$ (text$, pos, 2))
  pos = pos + 2
  blue = XLONG ("0x" + MID$ (text$, pos, 2))

  RETURN RGB(red, green, blue)

END FUNCTION
'
'
' ###############################
' #####  GetFontVariant ()  #####
' ###############################
'
FUNCTION  GetFontVariant (hdc, hfontSource, styles)

  LOGFONT logFont

  SelectObject(hdc, GetStockObject ($$SYSTEM_FONT))
  IF (!GetObjectA (hfontSource, SIZE (logFont), &logFont)) THEN RETURN ($$TRUE)

  ' set parameters, create new font
  IF styles & $$FV_BOLD THEN
    logFont.weight = $$FW_BOLD
  ELSE
    logFont.weight = $$FW_NORMAL
  END IF

  logFont.italic = (styles & $$FV_ITALIC) != 0
  logFont.underline = (styles & $$FV_UNDERLINE) != 0
  IF (styles & ($$FV_SUPERSCRIPT | $$FV_SUBSCRIPT)) THEN
    logFont.height = logFont.height * 7 / 10.0
  END IF
  RETURN CreateFontIndirectA (&logFont)

END FUNCTION
END PROGRAM
