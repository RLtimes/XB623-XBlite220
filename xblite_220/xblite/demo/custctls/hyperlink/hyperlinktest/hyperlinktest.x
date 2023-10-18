'
'
' ####################
' #####  PROLOG  #####
' ####################

' A test of the hyperlink custom control.
'
PROGRAM	"hyperlinktest"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"hyperlink"

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
$$HyperLink1  = 101
$$HyperLink2  = 102
$$HyperLink3  = 103
$$HyperLink4  = 104
$$HyperLink5  = 105
$$HyperLink6  = 106
$$HyperLink7  = 107
$$HyperLink8  = 108
$$HyperLink9  = 109
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

' create hyperlink controls
			hHyperLink1 = NewChild ("hyperlinkctrl", "hyperlink 1 : default style",  0, 20,  20, 180, 20, hWnd, $$HyperLink1, 0)
			hHyperLink2 = NewChild ("hyperlinkctrl", "hyperlink 2 : custom font",    0, 20,  40, 180, 20, hWnd, $$HyperLink2, 0)
			hHyperLink3 = NewChild ("hyperlinkctrl", "hyperlink 3 : disabled",       0, 20,  60, 180, 20, hWnd, $$HyperLink3, 0)
			hHyperLink4 = NewChild ("hyperlinkctrl", "hyperlink 4 : relief text",    0, 20,  80, 180, 20, hWnd, $$HyperLink4, 0)
			hHyperLink5 = NewChild ("hyperlinkctrl", "hyperlink 5 : no hand cursor", $$WS_TABSTOP, 20, 100, 180, 20, hWnd, $$HyperLink5, 0)
			hHyperLink6 = NewChild ("hyperlinkctrl", "hyperlink 6 : no underline",   $$WS_TABSTOP, 20, 120, 180, 20, hWnd, $$HyperLink6, 0)
			hHyperLink7 = NewChild ("hyperlinkctrl", "hyperlink 7 : focus rect",     $$WS_TABSTOP, 20, 140, 180, 20, hWnd, $$HyperLink7, 0)
			hHyperLink8 = NewChild ("hyperlinkctrl", "hyperlink 8 : custom bkcolor", $$WS_TABSTOP | $$WS_BORDER, 20, 160, 180, 20, hWnd, $$HyperLink8, 0)
			hHyperLink9 = NewChild ("hyperlinkctrl", "http://perso.wanadoo.fr/xblite/", $$WS_TABSTOP, 20, 180, 180, 28, hWnd, $$HyperLink9, $$WS_EX_CLIENTEDGE)

' change control font
			IF hHyperLink2 THEN
				#hFontTNR = NewFont ("Times New Roman", 10, 0, 0, 0)
				SendMessageA (hHyperLink2, $$WM_SETFONT, #hFontTNR, 1)
			END IF

' disable control
			IF hHyperLink3 THEN EnableWindow (hHyperLink3, 0)

' set ReliefText style
			IF hHyperLink4 THEN SendMessageA (hHyperLink4, $$SET_HYPERLINK_STYLE, 0, $$HS_RELIEFTEXT)

' set NoHandCursor style
			IF hHyperLink5 THEN SendMessageA (hHyperLink5, $$SET_HYPERLINK_STYLE, 0, $$HS_NOHANDCURSOR)

' set NoUnderline style
			IF hHyperLink6 THEN SendMessageA (hHyperLink6, $$SET_HYPERLINK_STYLE, 0, $$HS_NOUNDERLINE)

' set DrawFocusRect style
			IF hHyperLink7 THEN SendMessageA (hHyperLink7, $$SET_HYPERLINK_STYLE, 0, $$HS_DRAWFOCUSRECT)

' set DrawFocusRect style
			IF hHyperLink8 THEN SendMessageA (hHyperLink8, $$SET_HYPERLINK_STYLE, 0, $$HS_DRAWFOCUSRECT)

' set new back color
			IF hHyperLink8 THEN SendMessageA (hHyperLink8, $$SET_HYPERLINK_BKCOLOR, 0, RGB (255, 255, 0))

' set DrawFocusRect style
			IF hHyperLink9 THEN SendMessageA (hHyperLink9, $$SET_HYPERLINK_STYLE, 0, $$HS_DRAWFOCUSRECT)

' set new back color
			IF hHyperLink9 THEN SendMessageA (hHyperLink9, $$SET_HYPERLINK_BKCOLOR, 0, RGB (255, 255, 255))

' set CenterHorz and CenterVert style
			IF hHyperLink9 THEN SendMessageA (hHyperLink9, $$SET_HYPERLINK_STYLE, 0, $$HS_CENTERHORZ | $$HS_CENTERVERT)


		CASE $$WM_DESTROY :
			DeleteObject (#hFontTNR)
			PostQuitMessage (0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID  = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl    = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					IF controlID = $$HyperLink9 THEN
						url$ = NULL$ (256)
						GetWindowTextA (hwndCtl, &url$, LEN (url$))
						url$ = TRIM$ (url$)
						ret = GoToURL (url$, $$SW_SHOWNORMAL)
					ELSE
						IF controlID = $$HyperLink1 THEN
							hCtrl = GetDlgItem (hWnd, $$HyperLink1)
							text$ = "HyperLink1 clicked"
							SendMessageA (hCtrl, $$WM_SETTEXT, 0, &text$)
						END IF
						msg$ = "Hyperlink control " + STRING (controlID) + " clicked."
						MessageBoxA (hWnd, &msg$, &"Hyperlink Control Test", 0)
					END IF
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
	className$  = "HyperLinkTest"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Hyperlink Control Test."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 280
	h 					= 250
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
	lf.height    = -1 * pointSize * GetDeviceCaps (hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

END FUNCTION
END PROGRAM
