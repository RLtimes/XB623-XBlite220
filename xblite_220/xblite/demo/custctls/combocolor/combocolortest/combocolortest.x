'
'
' ####################
' #####  PROLOG  #####
' ####################

' A test of the custom control,
' "combocolor", an owner-drawn control.
'
PROGRAM	"combocolortest"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"
	IMPORT  "comdlg32"	' comdlg32.dll
	IMPORT	"combocolor"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

'Control IDs
$$Combobox1  = 101
$$Combobox2  = 102
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry

	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create windows and other child controls
	MessageLoop ()								' the main message loop
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

		CASE $$WM_CREATE :

			hCombo1 = CreateComboColor (hWnd, $$Combobox1, 10, 10, 150, 150, GetSysColor ($$COLOR_WINDOWTEXT), GetSysColor ($$COLOR_WINDOWTEXT))
			IF hCombo1 THEN SendMessageA (hCombo1, $$CB_SETCURSEL, 5, 0)
			SendMessageA (hCombo1, $$CBCOL_SETAUTOCOLOR, $$Black, 0)

			hCombo2 = CreateComboColor (hWnd, $$Combobox2, 180, 10, 150, 150, GetSysColor ($$COLOR_WINDOWTEXT), GetSysColor ($$COLOR_WINDOWTEXT))
			IF hCombo2 THEN
				SendMessageA (hCombo2, $$CB_SETCURSEL, 2, 0)
				#hFontSS = NewFont ("MS Sans Serif", 9, 0, 0, 0)
				SendMessageA (hCombo2, $$WM_SETFONT, #hFontSS, 1)
			END IF

		CASE $$WM_DRAWITEM :
' must pass this one on to ownerdrawn combo!
			SELECT CASE wParam
				CASE $$Combobox1 :
					SendMessageA (GetDlgItem (hWnd, $$Combobox1), msg, wParam, lParam)
					RETURN ($$TRUE)
				CASE $$Combobox2 :
					SendMessageA (GetDlgItem (hWnd, $$Combobox2), msg, wParam, lParam)
					RETURN ($$TRUE)
			END SELECT

		CASE $$WM_DESTROY :
			DeleteObject (#hFontSS)
			PostQuitMessage (0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$CBN_SELENDOK :
					index = SendMessageA (hwndCtl, $$CB_GETCURSEL, $$TRUE, 0)			' get current selection index
					len = SendMessageA (hwndCtl, $$CB_GETLBTEXTLEN, index, 0)	' get length of selected text
					text$ = NULL$(len)
					SendMessageA (hwndCtl, $$CB_GETLBTEXT, index, &text$)			' get selected text
					c = SendMessageA (hwndCtl, $$CBCOL_GETSELCOLOR, $$TRUE, 0)			' get selected color

					msg$ = " Selected Color : " + text$ + " : " + HEXX$ (c)
					MessageBoxA (hWnd, &msg$, &"ComboColor Test", 0)
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

' register window class
	className$  = "ComboboxColor"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Combobox Color Selection."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 350
	h 					= 200
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
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
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName  = fontName$										' set font name
	lf.italic    = italic												' set italic (0 or 1)
	lf.underline = underline										' set underline (0 or 1)
	lf.weight    = weight												' set weight (0 to 1000, 400 is normal, 700 is bold)
	lf.height    = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

END FUNCTION
END PROGRAM
