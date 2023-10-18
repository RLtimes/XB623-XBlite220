'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo uses SetWindowLong() to dynamically change
' the window style.
'
PROGRAM	"winstyle"
VERSION	"0.0002"
'
'	IMPORT  "xsx"       ' Standard Extended library
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
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
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

'Control IDs

$$Button1  = 100
$$Button2  = 101
$$Button3  = 102
$$Button4  = 103
$$Button5  = 104
$$Button6  = 105
$$Button7  = 106
$$Button8  = 107
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
	RECT rect

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID  = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode

				CASE $$BN_CLICKED :
					SELECT CASE controlID
						CASE $$Button1 : fStyle = $$WS_VSCROLL 				: GOSUB ChangeWinStyle
						CASE $$Button2 : fStyle = $$WS_HSCROLL 				: GOSUB ChangeWinStyle
						CASE $$Button3 : fStyle = $$WS_MINIMIZEBOX 		: GOSUB ChangeWinStyle
						CASE $$Button4 : fStyle = $$WS_MAXIMIZEBOX 		: GOSUB ChangeWinStyle
						CASE $$Button5 : fStyle = $$WS_THICKFRAME 		: GOSUB ChangeWinStyle
						CASE $$Button6 : fStyle = $$WS_BORDER					: GOSUB ChangeWinStyle
						CASE $$Button7 : fStyle = $$WS_CAPTION 				: GOSUB ChangeWinStyle
					END SELECT

			END SELECT

    CASE ELSE :
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** ChangeWinStyle *****
SUB ChangeWinStyle

	oldStyle = GetWindowLongA (hWnd, $$GWL_STYLE)
	IF (oldStyle & fStyle) THEN
		newStyle = oldStyle & ~fStyle
	ELSE
		newStyle = oldStyle | fStyle
	END IF
	SetWindowLongA (hWnd, $$GWL_STYLE, newStyle)
	SetWindowPos (hWnd, 0, 0, 0, 0, 0, $$SWP_NOMOVE | $$SWP_NOSIZE | $$SWP_NOZORDER | $$SWP_FRAMECHANGED)
END SUB

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
	className$  = "SetWindowStyleDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Set Window Style Demo."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_VSCROLL | $$WS_HSCROLL | $$WS_TABSTOP
	w 					= 220
	h 					= 250
	exStyle			= 0
	#winMain		= NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create buttons
	#button1 = NewChild ("button", "+/- WS_VSCROLL", 			$$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  10, 170, 24, #winMain, $$Button1, 0)
	#button2 = NewChild ("button", "+/- WS_HSCROLL", 			$$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  34, 170, 24, #winMain, $$Button2, 0)
	#button3 = NewChild ("button", "+/- WS_MINIMIZEBOX", 	$$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  58, 170, 24, #winMain, $$Button3, 0)
	#button4 = NewChild ("button", "+/- WS_MAXIMIZEBOX", 	$$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  82, 170, 24, #winMain, $$Button4, 0)
	#button5 = NewChild ("button", "+/- WS_THICKFRAME", 	$$BS_PUSHBUTTON | $$WS_TABSTOP, 10, 106, 170, 24, #winMain, $$Button5, 0)
	#button6 = NewChild ("button", "+/- WS_BORDER", 			$$BS_PUSHBUTTON | $$WS_TABSTOP, 10, 130, 170, 24, #winMain, $$Button6, 0)
	#button7 = NewChild ("button", "+/- WS_CAPTION", 			$$BS_PUSHBUTTON | $$WS_TABSTOP, 10, 154, 170, 24, #winMain, $$Button7, 0)

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
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
END PROGRAM
