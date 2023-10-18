'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo shows how to use a tooltips control to display
' tooltip hints for child controls or window regions.
'
PROGRAM	"tooltips"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"

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
DECLARE FUNCTION  NewTooltipControl (hWnd)
DECLARE FUNCTION  SetTooltip (hWnd, tip$)
DECLARE FUNCTION  UpdateTooltip (hWnd, hTooltip, tip$)

'Control IDs

$$Edit1    = 120
$$Button1  = 130
$$Button2  = 131
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
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					IF id = $$Button2 THEN
						UpdateTooltip (#hButton2, #hTooltip3, "Tooltips are fun!")
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
	className$  = "TooltipsDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Tooltips Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 198
	h 					= 190
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create edit control
	#hEdit1 = NewChild ($$EDIT, "Edit Control", 0, 20, 20, 150, 20, #winMain, $$Edit1, $$WS_EX_CLIENTEDGE)

' create button controls
	#hButton1 = NewChild ($$BUTTON, "Button Control", $$BS_PUSHBUTTON, 20, 50, 150, 24, #winMain, $$Button1, 0)
	#hButton2 = NewChild ($$BUTTON, "Change Tooltip", $$BS_PUSHBUTTON, 20, 84, 150, 24, #winMain, $$Button2, 0)

' add tooltips to controls and main window
	#hTooltip1 = SetTooltip (#hEdit1,   "Tooltip for Edit Control")
	#hTooltip2 = SetTooltip (#hButton1, "Tooltip for Button1 Control")
	#hTooltip3 = SetTooltip (#hButton2, "Tooltip for Button2 Control")

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
	hwnd = CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)
	RETURN hwnd

END FUNCTION
'
'
' ##################################
' #####  NewTooltipControl ()  #####
' ##################################
'
FUNCTION  NewTooltipControl (hWnd)

	SHARED hInst
	IFZ hWnd THEN RETURN
	className$ = $$TOOLTIPS_CLASS
	text$ = ""
	RETURN CreateWindowExA (0, &className$, &text$, 0, 0, 0, 0, 0, hWnd, 0, hInst, 0)

END FUNCTION
'
'
' ###########################
' #####  SetTooltip ()  #####
' ###########################
'
FUNCTION  SetTooltip (hWnd, tip$)

TOOLINFO ti

' create tooltip control
	hTooltip = NewTooltipControl (GetParent (hWnd))
	IFZ hTooltip THEN RETURN

' fill TOOLINFO struct ti
	ti.cbSize   = SIZE (ti)
	ti.uFlags   = $$TTF_SUBCLASS | $$TTF_IDISHWND
	ti.hwnd     = GetParent (hWnd)
	ti.uId      = hWnd

' if tooltip already exists, then delete it
	IF SendMessageA (hTooltip, $$TTM_GETTOOLINFO, 0, &ti) THEN
		SendMessageA (hTooltip, $$TTM_DELTOOL, 0, &ti)
	END IF

' add new tooltip
	ti.cbSize   = SIZE(ti)
	ti.uFlags   = $$TTF_SUBCLASS | $$TTF_IDISHWND
	ti.hwnd     = GetParent (hWnd)
	ti.uId      = hWnd
	ti.lpszText = &tip$
	ret = SendMessageA (hTooltip, $$TTM_ADDTOOL, 0, &ti)

	IF ret THEN RETURN hTooltip

END FUNCTION
'
'
' ##############################
' #####  UpdateTooltip ()  #####
' ##############################
'
FUNCTION  UpdateTooltip (hWnd, hTooltip, tip$)

	TOOLINFO ti

	IFZ hTooltip THEN RETURN
	IFZ tip$ THEN RETURN

' fill TOOLINFO struct ti
	ti.cbSize   = SIZE (ti)
	ti.uFlags   = $$TTF_SUBCLASS | $$TTF_IDISHWND
	ti.hwnd     = GetParent (hWnd)
	ti.uId      = hWnd
	ti.lpszText = &tip$

' update text
	SendMessageA (hTooltip, $$TTM_UPDATETIPTEXT, 0, &ti)

END FUNCTION
END PROGRAM
