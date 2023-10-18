'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of drawing unicode text using ExtTextOutW
' and "Lucida Sans Unicode" font.
'
PROGRAM	"lucida"
VERSION	"0.0002"
'
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
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  OnPaint (hWnd, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline, angle#)
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

		CASE $$WM_CREATE:
			#hLucidaFont = NewFont ("Lucida Sans Unicode", 16, $$FW_NORMAL, 0, 0, 0)
			IFZ #hLucidaFont THEN
				MessageBoxA (hWnd, &"Lucida Sans Unicode Font Not Found", &"Error lucida.x", 0)
				#hLucidaFont = NewFont ("Arial Unicode MS", 16, $$FW_NORMAL, 0, 0, 0)
				IF #hLucidaFont THEN MessageBoxA (hWnd, &"Using Arial Unicode MS Font", &"Error lucida.x", 0)
				IFZ #hLucidaFont THEN
					#hLucidaFont = NewFont ("Arial", 16, $$FW_NORMAL, 0, 0, 0)
					IF #hLucidaFont THEN MessageBoxA (hWnd, &"Using Arial Font", &"Error lucida.x", 0)
				END IF
			END IF

		CASE $$WM_PAINT: OnPaint (hWnd, wParam, lParam)

		CASE $$WM_DESTROY:
			DeleteObject (#hLucidaFont)
			PostQuitMessage(0)

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
	wc.hbrBackground   = GetStockObject ($$WHITE_BRUSH) '$$COLOR_BTNFACE + 1
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
	className$  = "LucidaSansUnicodeDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Demo of Lucida Sans Unicode Font."
	#winMain = NewWindow (className$, titleBar$, $$WS_OVERLAPPEDWINDOW, x, y, 750, 290, 0)
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
' ########################
' #####  OnPaint ()  #####
' ########################
'
FUNCTION  OnPaint (hWnd, wParam, lParam)

	PAINTSTRUCT ps
	RECT rc
	STATIC entry
	STATIC USHORT text[]

	IFZ entry THEN GOSUB Init

	hdc = BeginPaint (hWnd, &ps)
	hOldFont = SelectObject (hdc, #hLucidaFont)
	GetClientRect (hWnd, &rc)
	ExtTextOutW (hdc, 20, 25,  $$ETO_OPAQUE, NULL, &text[0],   26, NULL)
	ExtTextOutW (hdc, 20, 50,  $$ETO_OPAQUE, NULL, &text[26],  7, NULL)
	ExtTextOutW (hdc, 20, 75,  $$ETO_OPAQUE, NULL, &text[33],  7, NULL)
	ExtTextOutW (hdc, 20, 100, $$ETO_OPAQUE, NULL, &text[40],  25, NULL)
	ExtTextOutW (hdc, 20, 125, $$ETO_OPAQUE, NULL, &text[65],  47, NULL)
	ExtTextOutW (hdc, 20, 150, $$ETO_OPAQUE, NULL, &text[112], 27, NULL)
	ExtTextOutW (hdc, 20, 175, $$ETO_OPAQUE, NULL, &text[139], 7, NULL)
	ExtTextOutW (hdc, 20, 200, $$ETO_OPAQUE, NULL, &text[146], 7, NULL)
	SelectObject (hdc, hOldFont)
	EndPaint (hWnd, &ps)

' ***** Init *****
SUB Init
' create a unicode array of text
	DIM text[153]

	count = -1

' capital letters
	FOR i = 0 TO 25 : INC count : text[count] = 'A' + i    : NEXT i

' latin extended-a
	FOR i = 0 TO 6  : INC count : text[count] = 0x0100 + i : NEXT i

' latin extended-b
	FOR i = 0 TO 6  : INC count : text[count] = 0x0180 + i : NEXT i

' greek
	FOR i = 0 TO 24  : INC count : text[count] = 0x0391 + i : NEXT i

' cyrillic
	FOR i = 0 TO 46  : INC count : text[count] = 0x0400 + i : NEXT i

' hebrew
	FOR i = 0 TO 26  : INC count : text[count] = 0x05D0 + i : NEXT i

' symbols
	FOR i = 0 TO 6  : INC count : text[count] = 0x2100 + i : NEXT i

' arrows
	FOR i = 0 TO 6  : INC count : text[count] = 0x2190 + i : NEXT i


END SUB


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
	lf.underline = underline										' set underline
	lf.escapement = angle# * 10									' set text rotation
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

END FUNCTION
END PROGRAM
