'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo of various listbox controls.
'
PROGRAM	"listbox"
VERSION	"0.0004"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  ListboxAddString (hwndCtl, text$)
DECLARE FUNCTION  EnumFontFamProc (logfontAddr, ntmAddr, type, lParam)

'Control IDs
$$Listbox1  = 101
$$Listbox2  = 102
$$Listbox3  = 103
$$Listbox4  = 104
$$Listbox5  = 105

$$Button1 = 110

$$Static1 = 120
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
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

	SELECT CASE msg

		CASE $$WM_DESTROY :
			DeleteObject (#hFontSS)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE $$LBN_DBLCLK :
					SELECT CASE id :
						CASE $$Listbox1:					' show that item in listbox was doubleclicked
							selItem = SendMessageA (hwndCtl, $$LB_GETCURSEL, 0, 0)
							text$ = NULL$(1024)
							SendMessageA (hwndCtl, $$LB_GETTEXT, selItem, &text$)
							text$ = "Current Selection: " + CSIZE$(text$)
							MessageBoxA (hWnd, &text$, &"Listbox Selection", 0)
					END SELECT

				CASE $$BN_CLICKED :
					count = SendMessageA (#listbox2, $$LB_GETSELCOUNT, 0, 0)
					REDIM items[count-1]
					SendMessageA (#listbox2, $$LB_GETSELITEMS, count, &items[])
					FOR i = 0 TO UBOUND(items[])
						len = SendMessageA (#listbox2, $$LB_GETTEXTLEN, items[i], 0)
						item$ = NULL$(len)
						SendMessageA (#listbox2, $$LB_GETTEXT, items[i], &item$)
						msg$ = msg$ + item$ + CHR$(10) + CHR$(13)
					NEXT i
					msg$ = "Multiple Listbox Selection:" + CHR$(10) + CHR$(13) + msg$
					MessageBoxA (hWnd, &msg$, &"Listbox Selection", 0)
			END SELECT

		CASE $$WM_CTLCOLORLISTBOX :
			hdcStatic = wParam
			hwndStatic = lParam
			SELECT CASE hwndStatic
				CASE #listbox2 :										' change the text and background color
					RETURN SetColor (RGB(0, 255, 0), RGB(0, 0, 0), wParam, lParam)
			END SELECT

		CASE $$WM_CTLCOLORSTATIC :
			hdcStatic = wParam
			hwndStatic = lParam
			bkColor = GetSysColor ($$COLOR_BTNFACE)
			SELECT CASE hwndStatic
				CASE #static1 :											' change the text and background color
					RETURN SetColor (0, bkColor, wParam, lParam)
			END SELECT

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

	hInst = GetModuleHandleA (0)		' get current instance handle
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
	wc.hbrBackground   = $$COLOR_BTNFACE + 1
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

	RECT rc
	SHARED className$
	SHARED fonts$[]

' register window class
	className$  = "ListBoxControlDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Listbox Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 620
	h 					= 250
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' create and show various listbox controls
	#listbox1 = NewChild ("listbox", "", $$LBS_STANDARD, 20, 20, 150, 150, #winMain, $$Listbox1, 0)
	#listbox2 = NewChild ("listbox", "", $$LBS_STANDARD | $$LBS_EXTENDEDSEL, 180, 20, 150, 150, #winMain, $$Listbox2, $$WS_EX_CLIENTEDGE)
	#listbox3 = NewChild ("listbox", "", $$LBS_STANDARD | $$LBS_EXTENDEDSEL | $$LBS_MULTICOLUMN, 340, 20, 250, 150, #winMain, $$Listbox3, $$WS_EX_CLIENTEDGE)

' create button controls
	#button1 = NewChild ("button", "Get Multiple Selection", $$BS_PUSHBUTTON, 180, 180, 150, 24, #winMain, $$Button1, 0)

' create a static label control
	#static1 = NewChild ("static", "Multicolumn Listbox", $$SS_LEFTNOWORDWRAP, 400, 180, 250, 24, #winMain, $$Static1, 0)

' add data to listboxes
	ListboxAddString (#listbox1, "France")
	ListboxAddString (#listbox1, "Scotland")
	ListboxAddString (#listbox1, "Ireland")
	ListboxAddString (#listbox1, "England")
	ListboxAddString (#listbox1, "Spain")
	ListboxAddString (#listbox1, "Holland")
	ListboxAddString (#listbox1, "Germany")
	ListboxAddString (#listbox1, "Italy")
	ListboxAddString (#listbox1, "Portugal")
	ListboxAddString (#listbox1, "Norway")
	ListboxAddString (#listbox1, "Sweden")
	ListboxAddString (#listbox1, "Denmark")
	ListboxAddString (#listbox1, "Belgium")

	ListboxAddString (#listbox2, "Banana")
	ListboxAddString (#listbox2, "Pear")
	ListboxAddString (#listbox2, "Orange")
	ListboxAddString (#listbox2, "Apple")
	ListboxAddString (#listbox2, "Kiwi")
	ListboxAddString (#listbox2, "Peach")
	ListboxAddString (#listbox2, "Apricot")
	ListboxAddString (#listbox2, "Cherry")
	ListboxAddString (#listbox2, "Melon")
	ListboxAddString (#listbox2, "Strawberry")
	ListboxAddString (#listbox2, "Raspberry")
	ListboxAddString (#listbox2, "Blackberry")
	ListboxAddString (#listbox2, "Grapefruit")

	hDC = GetDC (#winMain)
	count = EnumFontFamiliesA (hDC, 0, &EnumFontFamProc(), 0)
	ReleaseDC (#winMain, hDC)

	upper = count - 1
	REDIM fonts$[upper]

	FOR i = 0 TO upper
		str$ = fonts$[i]
		ListboxAddString (#listbox3, str$)				' add font names to listbox
	NEXT i

	SendMessageA (#listbox3, $$LB_SETCOLUMNWIDTH, 170, 0)		' set listbox column width

' initialize fonts in controls
	#hFontSS = NewFont ("MS Sans Serif", 10, $$FW_NORMAL, $$FALSE, $$FALSE)
	SetNewFont (#listbox3, #hFontSS)
	SetNewFont (#static1, #hFontSS)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

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
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	hwnd = CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

	RETURN hwnd

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

	STATIC MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

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
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush


END FUNCTION
'
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA(hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underline (0 or 1)
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

END FUNCTION
'
'
' ###########################
' #####  SetNewFont ()  #####
' ###########################
'
FUNCTION  SetNewFont (hwndCtl, hFont)

	SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$
	UnregisterClassA(&className$, hInst)

END FUNCTION
'
'
' #################################
' #####  ListboxAddString ()  #####
' #################################
'
FUNCTION  ListboxAddString (hwndCtl, text$)

	RETURN SendMessageA (hwndCtl, $$LB_ADDSTRING, 0, &text$)

END FUNCTION
'
'
' ################################
' #####  EnumFontFamProc ()  #####
' ################################
'
FUNCTION  EnumFontFamProc (logfontAddr, ntmAddr, type, lParam)

	LOGFONT logfont
	SHARED fonts$[]
	STATIC entry
	STATIC ifont

	IFZ entry THEN GOSUB Initialize

	RtlMoveMemory (&logfont, logfontAddr, SIZE(logfont))
	fontName$ = CSIZE$(logfont.faceName)

	IF fontName$ THEN
		ATTACH fontName$ TO fonts$[ifont]
		INC ifont
	END IF

	RETURN ifont

' ***** Initialize *****
SUB Initialize
	DIM fonts$[2000]
	ifont = 0
	entry = $$TRUE
END SUB


END FUNCTION
END PROGRAM
