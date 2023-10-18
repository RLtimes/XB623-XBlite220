'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo shows how to load/use a hand cursor
' and have it appear while hovering over
' text, much like in a html hyperlink.
'
PROGRAM	"mouseover"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
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

	PAINTSTRUCT ps
	RECT rect
	STATIC RECT rect1, rect2, rect3
	STATIC text1$, text2$, text3$
	STATIC onLink1, onLink2, onLink3

	SELECT CASE msg

		CASE $$WM_CREATE :

' assign url test strings
			text1$ = "http://www.xbasic.org/"
			text2$ = "http://slashdot.org/"
			text3$ = "http://www.google.com/"

' create two fonts
			#hFontSS10  = NewFont ("MS Sans Serif", 10, $$FW_NORMAL, $$FALSE, $$FALSE)
			#hFontSS10U = NewFont ("MS Sans Serif", 10, $$FW_NORMAL, $$FALSE, $$TRUE)

' initialize some rect areas for text
			rect1.top = 20 : rect1.left = 20
			rect2.top = 38 : rect2.left = 20
			rect3.top = 56 : rect3.left = 20

' get text rect width and height
			hdc = GetDC (hWnd)
			hOldFont = SelectObject (hdc, #hFontSS10U)
			DrawTextA (hdc, &text1$, -1, &rect1, $$DT_CALCRECT)
			DrawTextA (hdc, &text2$, -1, &rect2, $$DT_CALCRECT)
			DrawTextA (hdc, &text3$, -1, &rect3, $$DT_CALCRECT)

' set text background color
			SetBkColor (hdc, GetSysColor ($$COLOR_BTNFACE))
			SelectObject (hdc, hOldFont)
			ReleaseDC (hWnd, hdc)

		CASE $$WM_DESTROY :
			DeleteObject (#hFontSS10)
			DeleteObject (#hFontSS10U)
			PostQuitMessage(0)

		CASE $$WM_PAINT:
			hdc = BeginPaint (hWnd, &ps)									' prepare window for painting, drawing, filling
			style = $$DT_SINGLELINE OR $$DT_TOP OR $$DT_LEFT

			IFT onLink1 THEN
				SetTextColor (hdc, RGB (255, 0, 0))					' set red text
				hOldFont = SelectObject (hdc, #hFontSS10U)	' select underlined font
				DrawTextA (hdc, &text1$, -1, &rect1, style)
				SelectObject (hdc, hOldFont)
			ELSE
				SetTextColor (hdc, RGB (0, 0, 255))					' set blue text
				hOldFont = SelectObject (hdc, #hFontSS10)		' select normal font
				DrawTextA (hdc, &text1$, -1, &rect1, style)
				SelectObject (hdc, hOldFont)
			END IF

			IFT onLink2 THEN
				SetTextColor (hdc, RGB (255, 0, 0))					' set red text
				hOldFont = SelectObject (hdc, #hFontSS10U)	' select underlined font
				DrawTextA (hdc, &text2$, -1, &rect2, style)
				SelectObject (hdc, hOldFont)
			ELSE
				SetTextColor (hdc, RGB (0, 0, 255))					' set blue text
				hOldFont = SelectObject (hdc, #hFontSS10)		' select normal font
				DrawTextA (hdc, &text2$, -1, &rect2, style)
				SelectObject (hdc, hOldFont)
			END IF

			IFT onLink3 THEN
				SetTextColor (hdc, RGB (255, 0, 0))					' set red text
				hOldFont = SelectObject (hdc, #hFontSS10U)	' select underlined font
				DrawTextA (hdc, &text3$, -1, &rect3, style)
				SelectObject (hdc, hOldFont)
			ELSE
				SetTextColor (hdc, RGB (0, 0, 255))					' set blue text
				hOldFont = SelectObject (hdc, #hFontSS10)		' select normal font
				DrawTextA (hdc, &text3$, -1, &rect3, style)
				SelectObject (hdc, hOldFont)
			END IF

			EndPaint (hWnd, &ps)													' finished painting window


		CASE $$WM_LBUTTONDOWN :
			SELECT CASE TRUE
				CASE onLink1 : SetCursor (#hHand0) : ShellExecuteA (hWnd, &"open", &text1$, NULL, 0, $$SW_SHOWNORMAL)
				CASE onLink2 : SetCursor (#hHand0) : ShellExecuteA (hWnd, &"open", &text2$, NULL, 0, $$SW_SHOWNORMAL)
				CASE onLink3 : SetCursor (#hHand0) : ShellExecuteA (hWnd, &"open", &text3$, NULL, 0, $$SW_SHOWNORMAL)
			END SELECT

		CASE $$WM_LBUTTONUP :
			SELECT CASE TRUE
				CASE onLink1 : SetCursor (#hHand0)
				CASE onLink2 : SetCursor (#hHand0)
				CASE onLink3 : SetCursor (#hHand0)
			END SELECT

		CASE $$WM_MOUSEMOVE :
			xPos = LOWORD (lParam)
			yPos = HIWORD (lParam)

			IFT PtInRect (&rect1, xPos, yPos) THEN
				SetCursor (#hHand0)
				IFF onLink1 THEN InvalidateRect (hWnd, &rect1, $$TRUE)
				onLink1 = $$TRUE
			ELSE
				IFT onLink1 THEN InvalidateRect (hWnd, &rect1, $$TRUE)
				onLink1 = $$FALSE
			END IF

			IF PtInRect (&rect2, xPos, yPos) THEN
				SetCursor (#hHand0)
				onLink2 = $$TRUE
				InvalidateRect (hWnd, &rect2, $$TRUE)
			ELSE
				onLink2 = $$FALSE
				InvalidateRect (hWnd, &rect2, $$TRUE)
			END IF

			IFT PtInRect (&rect3, xPos, yPos) THEN
				SetCursor (#hHand0)
				onLink3 = $$TRUE
				InvalidateRect (hWnd, &rect3, $$TRUE)
			ELSE
				onLink3 = $$FALSE
				InvalidateRect (hWnd, &rect3, $$TRUE)
			END IF

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

	SHARED hInst, className$

' register window class
	className$  = "MouseOverDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Mouseover Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 400
	h 					= 300
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' assign some rect structures for the static controls
'	GetWindowRect (#hStatic1, &rect1)
'	MapWindowPoints (0, #winMain, &rect1, 2)

' load resource cursors from executable
	#hHand0 	= LoadCursorA (hInst, &"hand0")

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
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

	STATIC MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN			' main program executes message loop

	DO
		ret = GetMessageA (&msg, NULL, 0, 0)

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
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC 					= GetDC ($$HWND_DESKTOP)
	hFont 				= GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes 				= GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName 	= fontName$														' set font name
	lf.italic 		= italic															' set italic
	lf.weight 		= weight															' set weight
	lf.underline 	= underline														' set underlined
	lf.height 		= -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72.0
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)										' create a new font and get handle

END FUNCTION
END PROGRAM
