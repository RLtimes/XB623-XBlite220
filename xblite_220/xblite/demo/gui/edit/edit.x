'
'
' ####################
' #####  PROLOG  #####
' ####################

' This demo looks at using various edit controls,
' single and multiline, password, and number only
' controls. The single line edit controls have been
' sub-classed so that they will respond to a user
' pressing the Enter or Return key.
'
PROGRAM	"edit"
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
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CreateCallbacks ()
DECLARE FUNCTION  EditProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  CleanUp ()

' Edit box return message
$$EDITBOX_RETURN = 402

'Control IDs
$$Edit1  = 101
$$Edit2  = 102
$$Edit3  = 103
$$Edit4  = 104
$$Edit5  = 105

$$Button1 = 120
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
	CreateCallbacks ()						' if necessary, assign callback functions to child controls
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
			DeleteObject (#hFontArial)
			PostQuitMessage (0)

		CASE $$WM_COMMAND :
			id         = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE $$EDITBOX_RETURN :
					SELECT CASE id :
						CASE $$Edit1, $$Edit2, $$Edit3 :				' demonstrate that RETURN key was
							text$ = NULL$(1024)										' pressed in one of the edit controls
							SendMessageA (hwndCtl, $$WM_GETTEXT, 1024, &text$)
							text$ = "RETURN Key Pressed. Text: " + CSIZE$(text$)
							MessageBoxA (hWnd, &text$, &"Singleline Edit", 0)
					END SELECT

				CASE $$BN_CLICKED :					' change the text in the edit control
					text$ = "When in the Course of human Events it becomes necessary for one People dissolve the Political Bands which have connected them with another, and to assume among the Powers of the Earth, the separate and equal Station to which the Laws of Nature and of Nature's God entitle them, a decent Respect to the Opinions of Mankind requires that they should declare the causes which impel them to the Separation."
					SendMessageA (#edit5, $$WM_SETTEXT, 0, &text$)		' set new text
'					SetDlgItemTextA (hWnd, $$Edit5, &text$)					' or use this as well to set text
			END SELECT

		CASE $$WM_CTLCOLOREDIT :
			hdcStatic = wParam
			hwndStatic = lParam
			SELECT CASE hwndStatic
				CASE #edit3 :													' change the text and background color
					RETURN SetColor (RGB(255, 0, 0), RGB(100, 100, 100), wParam, lParam)

				CASE #edit5 :
					RETURN SetColor (RGB(0, 255, 0), RGB(0, 0, 0), wParam, lParam)
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

	SHARED className$

' register window class
	className$  = "EditControls"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Edit Controls."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 300
	h 					= 400
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' create and show various edit controls
' singleline controls
	#edit1 = NewChild ("edit", "Single Line Edit Control, 8 Pt Italic Arial Font", $$WS_BORDER | $$ES_AUTOHSCROLL | $$WS_TABSTOP, 20, 20, 260, 20, #winMain, $$Edit1, 0)
	#edit2 = NewChild ("edit", "Numbers Only Edit Control", $$ES_NUMBER | $$ES_AUTOHSCROLL | $$WS_TABSTOP, 20, 50, 260, 20, #winMain, $$Edit2, $$WS_EX_STATICEDGE)
	#edit3 = NewChild ("edit", "Password Edit Control", $$ES_PASSWORD | $$ES_AUTOHSCROLL | $$WS_TABSTOP, 20, 80, 260, 20, #winMain, $$Edit3, $$WS_EX_CLIENTEDGE)

' multiline controls
	#edit4 = NewChild ("edit", "Multiline Edit Control with Auto Scrolling", $$ES_MULTILINE | $$ES_AUTOHSCROLL | $$ES_AUTOVSCROLL | $$WS_TABSTOP, 20, 110, 260, 100, #winMain, $$Edit4, $$WS_EX_CLIENTEDGE)
	#edit5 = NewChild ("edit", "Multiline Edit Control with Vertical Scrollbar, green text and black background", $$ES_MULTILINE | $$ES_AUTOVSCROLL | $$WS_VSCROLL | $$ES_LEFT | $$WS_TABSTOP, 20, 230, 260, 100, #winMain, $$Edit5, $$WS_EX_CLIENTEDGE)

' create button controls
	#button1 = NewChild ("button", "Change the Text Above", $$BS_PUSHBUTTON, 20, 340, 260, 24, #winMain, $$Button1, 0)

' initialize fonts in controls
	#hFontArial = NewFont ("Arial", 8, $$FW_BOLD, $$TRUE, $$FALSE)
	SetNewFont (#edit1, #hFontArial)

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
		ret = GetMessageA (&msg, 0, 0, 0)			' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
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
' ################################
' #####  CreateCallbacks ()  #####
' ################################
'
FUNCTION  CreateCallbacks ()

'	assign a new callback function to be used by child edit controls
	#old_proc = SetWindowLongA(#edit1, $$GWL_WNDPROC, &EditProc())
	#old_proc = SetWindowLongA(#edit2, $$GWL_WNDPROC, &EditProc())
	#old_proc = SetWindowLongA(#edit3, $$GWL_WNDPROC, &EditProc())

END FUNCTION
'
'
' #########################
' #####  EditProc ()  #####
' #########################
'
FUNCTION  EditProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg

		CASE $$WM_KEYDOWN :			' WM_KEYDOWN returns virtKey constants
			virtKey = wParam
			IF virtKey = $$VK_RETURN THEN
				id = GetWindowLongA (hWnd, $$GWL_ID)
				wParam = ($$EDITBOX_RETURN << 16) OR id
				SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)	' send WM_COMMAND message to main window callback function
			END IF

'		CASE $$WM_CHAR :				' WM_CHAR can capture keyboard characters
'			charCode = wParam
'			PRINT "WM_CHAR message: ASCII charCode="; charCode, "CHAR="; CHR$(charCode)	' validate text entry by character

		CASE ELSE :
			RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

	END SELECT
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
