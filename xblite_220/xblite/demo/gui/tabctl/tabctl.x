'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A short demo of creating a tab control.
'
PROGRAM	"tabctl"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"  ' comctl32.dll
'	IMPORT  "shell32"   ' shell32.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (@className$, @titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (@className$, @text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  CleanUp ()

'Control IDs
$$Static1  = 101
$$Static2  = 102
$$Static3  = 103
$$Static4  = 104

$$Tab1 = 120
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
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

	RECT rc

	SELECT CASE msg

		CASE $$WM_DESTROY :
			DeleteObject (#hFontTab)
			DeleteObject (#hFontStatic)
			PostQuitMessage(0)

		CASE $$WM_SIZE :
			width = LOWORD(lParam)
			height = HIWORD(lParam)

' Calculate the display rectangle, assuming the
' tab control is the size of the client area
			SetRect(&rc, 0, 0, width, height)
			SendMessageA (#hTabCtl, $$TCM_ADJUSTRECT, $$FALSE, &rc)

' Size the tab control to fit the client area
			hdwp = BeginDeferWindowPos(2)
			DeferWindowPos(hdwp, #hTabCtl, 0, 0, 0, width, height, $$SWP_NOMOVE | $$SWP_NOZORDER)

' Position and size the static control to fit the
' tab control's display area, and make sure the
' static control is in front of the tab control.
			DeferWindowPos(hdwp, #hStatic1, $$HWND_TOP, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, 0)
			EndDeferWindowPos(hdwp)

		CASE $$WM_NOTIFY :
			GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
			idCtrl = idFrom
			SELECT CASE idCtrl
				CASE $$Tab1 :
					SELECT CASE code
						CASE $$TCN_SELCHANGE :
							iTab = SendMessageA (hwndFrom, $$TCM_GETCURSEL, 0, 0)		' get current tab selection
							DIM jour$[6]
							jour$[0] = "Dimanche"
							jour$[1] = "Lundi"
							jour$[2] = "Mardi"
							jour$[3] = "Mercredi"
							jour$[4] = "Jeudi"
							jour$[5] = "Vendredi"
							jour$[6] = "Samedi"
							text$ = jour$[iTab]
							SendMessageA (#hStatic1, $$WM_SETTEXT, 0, &text$)		' set text in static control
					END SELECT
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
	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT(0)
	InitCommonControls()					' initialize comctl32.dll library

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

	SHARED className$
	RECT rc
	TC_ITEM tci

' register window class
	className$  = "TabControlDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
' both parent and tab control must have the WS_CLIPSIBLINGS window style
	titleBar$  	= "Tab Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_CLIPSIBLINGS
	w 					= 500
	h 					= 100
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

'create tab control

	GetClientRect (#winMain, &rc)
	#hTabCtl = NewChild ($$WC_TABCONTROL, "", $$WS_CLIPSIBLINGS, 0, 0, rc.right, rc.bottom, #winMain, $$Tab1, 0)

'add tabs for each day of the week
	DIM day$[6]
	day$[0] = "Sunday"
	day$[1] = "Monday"
	day$[2] = "Tuesday"
	day$[3] = "Wednesday"
	day$[4] = "Thursday"
	day$[5] = "Friday"
	day$[6] = "Saturday"

	FOR i = 0 TO 6
		tci.mask 				= $$TCIF_TEXT
		tci.pszText 		= &day$[i]
		tci.cchTextMax 	= LEN(day$[i])
		SendMessageA (#hTabCtl, $$TCM_INSERTITEM, i, &tci)
	NEXT i

'create a static control to hold text
	#hStatic1 = NewChild ("static", "", $$WS_BORDER | $$SS_CENTER | $$SS_CENTERIMAGE, 0, 0, 100, 100, #winMain, $$Static1, 0)

' initialize font in tab control and static control
	#hFontTab = NewFont ("MS Sans Serif", 10, $$FW_NORMAL, $$FALSE, $$FALSE)
	SetNewFont (#hTabCtl, #hFontTab)
	#hFontStatic = NewFont ("MS Sans Serif", 14, $$FW_BOLD, $$FALSE, $$FALSE)
	SetNewFont (#hStatic1, #hFontStatic)

'set current tab control selection to first tab (iItem = 0)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 1, 0)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 0, 0)

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

	IF LIBRARY(0) THEN RETURN			' main program executes message loop

	DO
		ret = GetMessageA (&msg, 0, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  				TranslateMessage (&msg)
  				DispatchMessageA (&msg)
				END IF
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
' #############################
' #####  GetNotifyMsg ()  #####
' #############################
'
FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

	NMHDR nmhdr

	nmhdrAddr = lParam
'	XstCopyMemory (nmhdrAddr, &nmhdr, SIZE(nmhdr))	'Xst library function
	RtlMoveMemory (&nmhdr, nmhdrAddr, SIZE(nmhdr))	'kernel32 library function
	hwndFrom = nmhdr.hwndFrom
	idFrom   = nmhdr.idFrom
	code     = nmhdr.code


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
END PROGRAM
