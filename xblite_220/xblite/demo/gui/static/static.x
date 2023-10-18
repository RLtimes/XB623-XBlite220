'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo to show various styles of static controls.
'
PROGRAM	"static"
VERSION	"0.0003"

	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
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

'Control IDs
$$Static1  = 101
$$Static2  = 102
$$Static3  = 103
$$Static4  = 104
$$Static5  = 105
$$Static6  = 106
$$Static7  = 107
$$Static8  = 108
$$Static9  = 109
$$Static10  = 110
$$Static11  = 111
$$Static12  = 112
$$Static13  = 113

$$Button1 = 120
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

	SHARED hNewBrush

	SELECT CASE msg

		CASE $$WM_DESTROY :
			DeleteObject (hNewBrush)
			DeleteObject (#hFontTNR)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			child = LOWORD (wParam)
			SELECT CASE child
				CASE $$Static12 : MessageBoxA (hWnd, &"You clicked on the Icon, thankyou!", &"Goodjob!", 0)

				CASE $$Button1 :  text$ = "Put the flour, sugar, and eggs in bowl and mix. Add a half glass of water..."
													SetWindowTextA (#static11, &text$)

			END SELECT

		CASE $$WM_CTLCOLORSTATIC :
			hdcStatic = wParam
			hwndStatic = lParam
			SELECT CASE hwndStatic
				CASE #static8 :											' change the text and background color
					RETURN SetColor (RGB(255, 0, 0), RGB(192, 192, 192), wParam, lParam)
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

	SHARED className$, hInst

' register window class
	className$  = "StaticControls"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Static Controls."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 340
	h 					= 500
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

'create and show various static controls

	#static1 = NewChild ("static", "", $$SS_BLACKFRAME, 20, 20, 300, 20, #winMain, $$Static1, 0)
	#static2 = NewChild ("static", "", $$SS_WHITEFRAME, 20, 50, 300, 20, #winMain, $$Static2, 0)
	#static3 = NewChild ("static", "", $$SS_ETCHEDFRAME, 20, 80, 300, 20, #winMain, $$Static3, 0)
	#static4 = NewChild ("static", "", $$SS_SUNKEN, 20, 110, 300, 20, #winMain, $$Static4, 0)
	#static5 = NewChild ("static", "", $$SS_BLACKRECT, 20, 140, 300, 20, #winMain, $$Static5, 0)
	#static6 = NewChild ("static", "", $$SS_WHITERECT, 20, 170, 300, 20, #winMain, $$Static6, 0)
	#static7 = NewChild ("static", "SS_LEFTNOWORDWRAP + WS_EX_STATICEDGE", $$SS_LEFTNOWORDWRAP, 20, 200, 300, 20, #winMain, $$Static7, $$WS_EX_STATICEDGE)
	#static8 = NewChild ("static", "SS_LEFT Style", $$SS_LEFT , 20, 230, 300, 20, #winMain, $$Static8, 0)
	#static9 = NewChild ("static", "SS_CENTER OR WS_BORDER Style", $$SS_CENTER | $$WS_BORDER, 20, 260, 300, 20, #winMain, $$Static9, 0)
	#static10 = NewChild ("static", "SS_RIGHT + WS_EX_CLIENTEDGE", $$SS_RIGHT, 20, 290, 300, 20, #winMain, $$Static10, $$WS_EX_CLIENTEDGE)
	text$ = "Crepes Recipe: 500g flour, 250g sugar, 100g butter, 3 tsp oil, 3 eggs, 1 liter milk"
	#static11 = NewChild ("static", text$, $$SS_LEFT, 20, 320, 150, 80, #winMain, $$Static11, 0)
	#static12 = NewChild ("static", "scrabble", $$SS_ICON | $$SS_NOTIFY, 20, 410, 0, 0, #winMain, $$Static12, 0)
	#static13 = NewChild ("static", "<< Click on the Icon!", $$SS_LEFT, 60, 416, 260, 20, #winMain, $$Static13, 0)

' create button controls
	#button1 = NewChild ("button", "Change the Text!", 0, 180, 320, 140, 20, #winMain, $$Button1, 0)

' initialize fonts in controls
	#hFontTNR = NewFont ("Times New Roman", 10, $$FW_BOLD, $$TRUE, $$FALSE)
	SetNewFont (#static9, #hFontTNR)

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
FUNCTION  NewChild (className$, @text$, style, x, y, w, h, parent, id, exStyle)

	SHARED hInst

	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

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
  			TranslateMessage (&msg)
  			DispatchMessageA (&msg)
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
END PROGRAM
