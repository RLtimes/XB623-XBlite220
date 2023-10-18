'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of creating and displaying various styles,
' sizes, and colors of fonts.
'
PROGRAM	"fontfun"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT "xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "shell32"		' shell32.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (@className$, @title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline, angle#)
DECLARE FUNCTION  GetLineHeight (hDC, @lineSpace, @pixels, @leading)
DECLARE FUNCTION  DrawStockFontText (hDC, fStockFont, x, y, text$, @lineSpace)
DECLARE FUNCTION  DrawCustomFontText (hDC, fontName$, pointSize, weight, italic, underline, angle#, x, y, text$, @lineSpace)
DECLARE FUNCTION  OnEraseBkgnd (hWnd, color)
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

	SHARED hInst
	PAINTSTRUCT ps

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_PAINT :
			hDC = BeginPaint (hWnd, &ps)

'stock font examples
			DrawStockFontText (hDC, $$ANSI_FIXED_FONT,   x, y, "Stock Font: ANSI_FIXED_FONT", @spacing)
			y = y + spacing
			DrawStockFontText (hDC, $$ANSI_VAR_FONT,     x, y, "Stock Font: ANSI_VAR_FONT", @spacing)
			y = y + spacing
			DrawStockFontText (hDC, $$DEFAULT_GUI_FONT,  x, y, "Stock Font: DEFAULT_GUI_FONT", @spacing)
			y = y + spacing
			DrawStockFontText (hDC, $$OEM_FIXED_FONT,    x, y, "Stock Font: OEM_FIXED_FONT", @spacing)
			y = y + spacing
			DrawStockFontText (hDC, $$SYSTEM_FONT,       x, y, "Stock Font: SYSTEM_FONT", @spacing)
			y = y + spacing
			DrawStockFontText (hDC, $$SYSTEM_FIXED_FONT, x, y, "Stock Font: SYSTEM_FIXED_FONT", @spacing)
			y = y + spacing

' custom font examples
			DrawCustomFontText (hDC, "arial",           16, $$FW_BOLD,   $$FALSE, $$TRUE,  0, x, y, "Custom Font: Arial, 16pt, Bold, Underlined", @spacing)
			y = y + spacing
			DrawCustomFontText (hDC, "times new roman", 12, $$FW_NORMAL, $$TRUE,  $$FALSE, 0, x, y, "Custom Font: Times New Roman, 12pt, Italic", @spacing)
			y = y + spacing
			DrawCustomFontText (hDC, "century gothic",  20, $$FW_LIGHT,  $$FALSE, $$FALSE, 0, x, y, "Custom Font: Century Gothic, 20pt, Light",   @spacing)
			y = y + spacing

' change text and background colors
			cTextLast = SetTextColor (hDC, RGB(255, 0, 0))
			cBackLast = SetBkColor (hDC, RGB(255, 255, 0))
			DrawCustomFontText (hDC, "courier new", 14, $$FW_NORMAL, $$FALSE, $$FALSE, 0, x, y, "Custom Font: Courier New, 14pt", @spacing)

' draw rotated text, angle# is degrees counterclockwise direction text should be rotated
			x = 570
			y = 0
			angle# = 270
			DrawCustomFontText (hDC, "arial", 16, $$FW_NORMAL, $$FALSE, $$FALSE, angle#, x, y, "Arial, 16pt, 270 Degree Rotation", @spacing)

' change colors back to default
			SetTextColor (hDC, cTextLast)
			SetBkColor (hDC, cBackLast)

			EndPaint (hWnd, &ps)

		CASE $$WM_ERASEBKGND :
' set window background color to white
			OnEraseBkgnd (hWnd, RGB (255, 255, 255))
			RETURN ($$TRUE)

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

	SHARED className$, hInst

' register window class
	className$  = "FontDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Font Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 600
	h 					= 350
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

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
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline, angle#)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underlined
	lf.escapement = angle# * 10									' set text rotation
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

END FUNCTION
'
'
' ##############################
' #####  GetLineHeight ()  #####
' ##############################
'
FUNCTION  GetLineHeight (hDC, @lineSpace, @pixels, @leading)

	TEXTMETRIC tm

	GetTextMetricsA (hDC, &tm)
	lineSpace 	= tm.height + tm.externalLeading
	pixels 			= tm.height
	leading 		= tm.externalLeading

END FUNCTION
'
'
' ##################################
' #####  DrawStockFontText ()  #####
' ##################################
'
FUNCTION  DrawStockFontText (hDC, fStockFont, x, y, text$, @lineSpace)

	hStockFont = GetStockObject (fStockFont)
	hOldFont = SelectObject (hDC, hStockFont)
	GetLineHeight (hDC, @lineSpace, @pixels, @leading)
	TextOutA (hDC, x, y, &text$, LEN(text$))
	SelectObject (hDC, hOldFont)

END FUNCTION
'
'
' ###################################
' #####  DrawCustomFontText ()  #####
' ###################################
'
FUNCTION  DrawCustomFontText (hDC, fontName$, pointSize, weight, italic, underline, angle#, x, y, text$, @lineSpace)

	hCustFont = NewFont (fontName$, pointSize, weight, italic, underline, angle#)
	hOldFont = SelectObject (hDC, hCustFont)
	GetLineHeight (hDC, @lineSpace, @pixels, @leading)
	TextOutA (hDC, x, y, &text$, LEN(text$))
	SelectObject (hDC, hOldFont)
	DeleteObject (hCustFont)

END FUNCTION
'
'
' #############################
' #####  OnEraseBkgnd ()  #####
' #############################
'
' PURPOSE : Set background color of window on WM_ERASEBKGND msg
'
FUNCTION  OnEraseBkgnd (hWnd, color)

	RECT rect
	GetClientRect (hWnd, &rect)
	hBrush = CreateSolidBrush (color)
	hdc = GetDC (hWnd)
	hOldBrush = SelectObject (hdc, hBrush)
	PatBlt (hdc, rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top, $$PATCOPY)
	SelectObject (hdc, hOldBrush)
	DeleteObject (hBrush)
	ReleaseDC (hWnd, hdc)

END FUNCTION
END PROGRAM
