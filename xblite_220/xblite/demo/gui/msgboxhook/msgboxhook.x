'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program uses SetWindowsHookExA to add
' a message hook to a standard message box.
' This allows one to modify the message box
' before it is displayed.
'
PROGRAM	"msgboxhook"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
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
DECLARE FUNCTION  CBTProc (nCode, wParam, lParam)
DECLARE FUNCTION  MsgBoxEx (hWnd, text$, caption$, type)

'Control IDs

$$Button1  = 100
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

		CASE $$WM_CREATE :
			#button1 = NewChild ("button", "Test MsgBoxEx()", $$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  10, 220, 24, hWnd, $$Button1, 0)

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID  = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE controlID
						CASE $$Button1 :
							msg$ = "A message box with a hook!"
							MsgBoxEx (hWnd, msg$, "Test MsgBoxEx()", $$MB_OK | $$MB_ICONINFORMATION)
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

	SHARED className$, hInst

' register window class
	className$  = "MessageBoxHookDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "MessageBox Hook Demo."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 250
	h 					= 100
	x 					= 50
	y						= 50
	exStyle			= 0
	#winMain		= NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

'	XstCenterWindow (#winMain)							' center window position
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
'
'
' ########################
' #####  CBTProc ()  #####
' ########################

' A computer-based training(CBT) hook callback function that
' the system calls before activating, creating, destroying,
' minimizing, maximizing, moving, or sizing a window.

' Thus, if you want to change the size or position of the message box,
' then you will need to subclass the message box and
' call a different hook callback function. See msgboxex.x.
'
FUNCTION  CBTProc (nCode, wParam, lParam)

	SHARED hMsgBoxHook

	IF nCode < 0 THEN RETURN CallNextHookEx (hMsgBoxHook, nCode, wParam, lParam)

	SELECT CASE nCode
		CASE $$HCBT_ACTIVATE :				' the system is about to activate a window
			hMsgBoxWnd = wParam					' get handle to messagebox
			SetWindowTextA (hMsgBoxWnd, &"Intercepted!")
			hWndButton = GetDlgItem (hMsgBoxWnd, $$IDOK)
			SetWindowTextA (hWndButton, &"Click me!")
	END SELECT

	RETURN CallNextHookEx (hMsgBoxHook, nCode, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  MsgBoxEx ()  #####
' #########################
'
' A wrapper around standard MessageBox function
' so that a hook can be set.
'
FUNCTION  MsgBoxEx (hWnd, text$, caption$, type)

	SHARED hMsgBoxHook

' install a window hook so we can intercept the message box
' before creation and customize it
' this hook is installed for this thread only
	threadId = GetCurrentThreadId()
	hMsgBoxHook = SetWindowsHookExA ($$WH_CBT, &CBTProc(), 0, threadId)
	IFZ hMsgBoxHook THEN RETURN ($$TRUE)

' display a standard message box
' it doesn't matter if it has no parent window or a
' message loop because MessageBox has its own message loop.
	IFZ caption$ THEN caption$ = "Message Window"
	ret = MessageBoxA (hWnd, &text$, &caption$, type)

' remove the window hook
	UnhookWindowsHookEx (hMsgBoxHook)

	RETURN ret

END FUNCTION
END PROGRAM
