'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program uses SetWindowsHookExA to add a
' message hook to a standard message box.
' The messagebox is then subclassed so that it
' can be treated like any other dialog window.
' Thus, you can move it, hide it, change button
' texts, add more child controls to it, or add
' your own icon. You could also add a timer to
' close the window after a certain timeout period.
' ---
' MsgBoxEx() allows you to change the message box
' position and icon.
' ---
' Notes: when a message box dialog is created,
' it includes one or more buttons, a static
' control to display an icon, and a static
' control to display the text message.
' ---
' The MessageBox dialog window
' classname is "#32770".
'
PROGRAM	"msgboxex"
VERSION	"0.0002"
'
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
DECLARE FUNCTION  MsgBoxEx (hWnd, text$, caption$, type, fCentering, x, y, hIcon)
DECLARE FUNCTION  CallWndProc (nCode, wParam, lParam)
DECLARE FUNCTION  MsgBoxProc (hWnd, msg, wParam, lParam)

' MsgBoxEx centering flags

$$MSGBOXEX_CUSTOM = 2			' set custom position
$$MSGBOXEX_PARENT = 1			' center within parent window

'Control IDs

$$Button1  = 100
$$Button2  = 101
$$Button3  = 102
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
	SHARED hMsgBoxWnd

	SELECT CASE msg

		CASE $$WM_CREATE :
			#button1 = NewChild ("button", "MsgBoxEx : Centered", 		$$BS_PUSHBUTTON | $$WS_TABSTOP, 10, 10, 220, 24, hWnd, $$Button1, 0)
			#button2 = NewChild ("button", "MsgBoxEx : Custom X/Y", 	$$BS_PUSHBUTTON | $$WS_TABSTOP, 10, 34, 220, 24, hWnd, $$Button2, 0)
			#button3 = NewChild ("button", "MsgBoxEx : Custom Icon", 	$$BS_PUSHBUTTON | $$WS_TABSTOP, 10, 58, 220, 24, hWnd, $$Button3, 0)

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
							msg$ = "A message box centered on parent window."
							ret = MsgBoxEx (hWnd, msg$, "MsgBoxEx Demo 1.", $$MB_OK | $$MB_ICONINFORMATION, $$MSGBOXEX_PARENT, 0, 0, 0)

						CASE $$Button2 :
							msg$ = "A message box moved to custom screen coordinates."
							MsgBoxEx (hWnd, msg$, "MsgBoxEx Demo 2.", $$MB_OK | $$MB_ICONQUESTION, $$MSGBOXEX_CUSTOM, 25, 400, 0)

						CASE $$Button3 :
							msg$ = "A message box with a custom icon."
							hIcon = LoadIconA (hInst, &"scrabble")
							MsgBoxEx (hWnd, msg$, "MsgBoxEx Demo 3.", 0, 0, 0, 0, hIcon)

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
	h 					= 150
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
' #########################
' #####  MsgBoxEx ()  #####
' #########################
'
' A wrapper around standard MessageBox function
' so that a hook can be set.
' fCentering	- flag to position message box
' x, y				- custom x, y coordinates of upper-left corner of mb
' hIcon				- handle to custom icon
'
FUNCTION  MsgBoxEx (hWnd, text$, caption$, type, fCentering, x, y, hIcon)

	SHARED hMsgBoxHook
	SHARED MSGBOXEX_X, MSGBOXEX_Y, MSGBOXEX_HICON, MSGBOXEX_CENTERING
	SHARED hInstance

	MSGBOXEX_X = x
	MSGBOXEX_Y = y
	MSGBOXEX_HICON = hIcon
	MSGBOXEX_CENTERING = fCentering

' install a window hook so we can intercept the message box
' before creation and customize it
' this hook is installed for this thread only
'
	hMsgBoxHook = SetWindowsHookExA ($$WH_CALLWNDPROC, &CallWndProc(), hInstance, GetCurrentThreadId())
	IFZ hMsgBoxHook THEN RETURN ($$TRUE)

' if user icon is specified, make sure an icon (static control) is available
	IF hIcon THEN type = type | $$MB_ICONINFORMATION

' display a standard message box
' it doesn't matter if it has no parent window or a
' message loop because MessageBox has its own message loop.
	IFZ caption$ THEN caption$ = "Message Window"
	ret = MessageBoxA (hWnd, &text$, &caption$, type)

' remove the window hook
	UnhookWindowsHookEx (hMsgBoxHook)

	RETURN ret

END FUNCTION
'
'
' ############################
' #####  CallWndProc ()  #####
' ############################

' The CallWndProc hook procedure is an application-defined
' or library-defined callback function that the system calls
' whenever the SendMessage function is called. Before passing
' the message to the destination window procedure, the system
' passes the message to the hook procedure. The hook procedure
' can examine the message; it cannot modify it.
'
FUNCTION  CallWndProc (nCode, wParam, lParam)

	SHARED hMsgBoxHook
'	CWPSTRUCT cwp
	SHARED oldMsgProc
	
	IF nCode < 0 THEN RETURN CallNextHookEx (hMsgBoxHook, nCode, wParam, lParam)
'	RtlMoveMemory (&cwp, lParam, SIZE(cwp))	
	message = ULONGAT(lParam+8)
	hwnd = ULONGAT(lParam+12)

	SELECT CASE message
'		CASE $$WM_CREATE :							' the system is about to create a window/dialog
		CASE $$WM_INITDIALOG:
			class$ = NULL$(255)
			GetClassNameA (hwnd, &class$, LEN(class$))
			class$ = CSIZE$(class$)
			IF class$ = "#32770" THEN 		' this is the messagebox class name, so subclass it
				oldMsgProc = SetWindowLongA (hwnd, $$GWL_WNDPROC, &MsgBoxProc())	' set a new address for the messagebox procedure
			END IF
	END SELECT

	RETURN CallNextHookEx (hMsgBoxHook, nCode, wParam, lParam)

END FUNCTION
'
'
' ###########################
' #####  MsgBoxProc ()  #####
' ###########################
'
FUNCTION  MsgBoxProc (hWnd, msg, wParam, lParam)

	SHARED oldMsgProc
	SHARED MSGBOXEX_X, MSGBOXEX_Y, MSGBOXEX_HICON, MSGBOXEX_CENTERING
	RECT rect, parent
	
	SELECT CASE msg
		CASE $$WM_INITDIALOG :									' reposition or resize msgbox
			GetWindowRect (hWnd, &rect)
			w = rect.right - rect.left
			h = rect.bottom - rect.top

			screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
			screenHeight = GetSystemMetrics ($$SM_CYSCREEN)
			x = (screenWidth - w)/2
			y = (screenHeight - h)/2

			SELECT CASE MSGBOXEX_CENTERING

				CASE $$MSGBOXEX_PARENT :						' center msgbox within parent window
					hParentWnd = GetParent(hWnd)
					IF hParentWnd THEN
						GetWindowRect (hParentWnd, &parent)
						rect.left = parent.left + (((parent.right - parent.left) - w) / 2)
						rect.top = parent.top + (((parent.bottom - parent.top) - h) / 2)
						IF rect.left < 0 THEN rect.left = 0
						IF rect.top < 0 THEN rect.top = 0
						IF rect.right > screenWidth THEN rect.left = screenWidth - w
						IF rect.bottom > screenHeight THEN rect.top = screenHeight - h
						SetWindowPos (hWnd, 0, rect.left, rect.top, 0, 0, $$SWP_NOZORDER | $$SWP_NOSIZE)
					ELSE
						SetWindowPos (hWnd, 0, x, y, 0, 0, $$SWP_NOZORDER | $$SWP_NOSIZE)
					END IF

				CASE $$MSGBOXEX_CUSTOM :						' center msgbox at custom x, y
					IF MSGBOXEX_X != -1 THEN x = MSGBOXEX_X
					IF MSGBOXEX_Y != -1 THEN y = MSGBOXEX_Y
					SetWindowPos (hWnd, 0, x, y, 0, 0, $$SWP_NOZORDER | $$SWP_NOSIZE)
			END SELECT

			IF MSGBOXEX_HICON THEN																' user passed a custom icon
				hStaticIcon = FindWindowExA (hWnd, 0, &"static", 0)	' 1st static control for icon
				SendMessageA (hStaticIcon, $$STM_SETICON, MSGBOXEX_HICON, 0)

'				hStaticText = FindWindowExA (hWnd, hStaticIcon, &"static", 0)	' 2nd static control for text
'				PRINT "hStaticText ="; hStaticText
'				SetWindowTextA (hStaticText, &"This is a static control to display text messages.")

			END IF

			ret = SetWindowLongA (hWnd, $$GWL_WNDPROC, oldMsgProc)	' restore the default window proc
	END SELECT

	RETURN CallWindowProcA (oldMsgProc, hWnd, msg, wParam, lParam)
END FUNCTION
END PROGRAM
