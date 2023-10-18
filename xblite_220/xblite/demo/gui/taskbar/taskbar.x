'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This taskbar demo places an icon in the
' system tray. A pop-up menu is displayed when
' the tray icon is right-clicked. Also note that
' when this window is minimized, it is not
' shown in the taskbar. The window is restored
' when the tray icon is left-clicked.
'
PROGRAM	"taskbar"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
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
DECLARE FUNCTION  CreateLabel (hWnd, label$, x, y, id)
DECLARE FUNCTION  SetTaskbarIcon (hWnd, iconName$, tooltip$)
DECLARE FUNCTION  DeleteTrayIcon (hWnd)
DECLARE FUNCTION  ModifyTaskbarIcon (hWnd, iconName$, tooltip$)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

' user identified notify message

$$WM_TRAYICON = 1025						' WM_USER = 1024

' user control IDs

$$Edit1 = 120
$$Static1 = 121

$$PopUp_XB      = 130
$$PopUp_News    = 131
$$PopUp_Icon    = 132
$$PopUp_Wordpad = 133
$$PopUp_Exit    = 134
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
	POINT pt
	RECT rc

	SELECT CASE msg

		CASE $$WM_DESTROY :
			DeleteTrayIcon (hWnd)						' delete the taskbar icon
			DestroyMenu (#hPopMenu)					' delete the pop-up menu
			PostQuitMessage(0)

			CASE $$WM_TRAYICON :  											' taskbar mouse event message
				idIcon = wParam
				mouseMsg = lParam
				SELECT CASE mouseMsg

					CASE $$WM_RBUTTONDOWN   :
						GetCursorPos (&pt)
    				SetForegroundWindow (hWnd)
    				TrackPopupMenuEx (#hPopMenu, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, hWnd, 0)

					CASE $$WM_LBUTTONDOWN   : ShowWindow (#winMain, $$SW_SHOWNORMAL)
				END SELECT

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE id

				CASE $$PopUp_XB :
					ShellExecuteA (0, 0, &"http://sourceforge.net/projects/xbasic", 0, 0, 0)

				CASE $$PopUp_News :
					ShellExecuteA (0, 0, &"http://groups.google.com/group/xblite/", 0, 0, 0)

				CASE $$PopUp_Icon :
					ModifyTaskbarIcon (hWnd, "xscience", "Tray Icons are FUN!")

				CASE $$PopUp_Wordpad :
					ShellExecuteA (0, 0, &"wordpad.exe", 0, 0, $$SW_SHOW)

				CASE $$PopUp_Exit :
    			DestroyWindow (hWnd)
			END SELECT

		CASE $$WM_SIZE :
			fSizeType = wParam
			width = LOWORD(lParam)
			height = HIWORD(lParam)
			SELECT CASE fSizeType

				CASE $$SIZE_MINIMIZED : ShowWindow (hWnd, $$SW_HIDE)

				CASE $$SIZE_RESTORED, $$SIZE_MAXIMIZED  :
					GetClientRect (hWnd, &rc)
					MoveWindow (#hStatic1, 0, 0, rc.right, rc.bottom, $$TRUE)
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

	SHARED className$
	RECT rc

' register window class
	className$  = "TaskBarDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Taskbar Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	#winMain = NewWindow (className$, title$, style, 0, 0, 280, 200, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create pop-up menu
	#hPopMenu = CreatePopupMenu ()

' add menu items to pop-up menu
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_XB,      &"&XBASIC Homepage")
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_News,    &"XBLite &Newsgroup")
	AppendMenuA (#hPopMenu, $$MF_SEPARATOR, 0, 0)
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_Icon,    &"&Change Tray Icon")
	AppendMenuA (#hPopMenu, $$MF_SEPARATOR, 0, 0)
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_Wordpad, &"&WordPad")
	AppendMenuA (#hPopMenu, $$MF_SEPARATOR, 0, 0)
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_Exit,    &"&Exit")

' add an icon to the taskbar "tray"
	SetTaskbarIcon (#winMain, "xlaunch", "Taskbar Icon Demo")

' create a static text control to display some text
	text$ = "  This taskbar demo creates an icon in the "
	text$ = text$ + "system tray. A pop-up menu is displayed "
	text$ = text$ + "when the tray icon is right-clicked.\n\n"
	text$ = text$ + "  Also note that when this window is "
	text$ = text$ + "minimized, there is not a window button "
	text$ = text$ + "on the taskbar. The window is restored "
	text$ = text$ + "when the tray icon is left-clicked."
	GetClientRect (#winMain, &rc)
	#hStatic1 = NewChild ("static", text$, $$SS_LEFT, 0, 0, rc.right, rc.bottom, #winMain, $$Static1, $$WS_EX_CLIENTEDGE)

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
' ############################
' #####  CreateLabel ()  #####
' ############################
'
FUNCTION  CreateLabel (hWnd, label$, x, y, id)
	SIZEAPI size
	SHARED hInst
	IFZ hWnd THEN RETURN
	hDC = GetDC (hWnd)
	IFZ hDC THEN RETURN
	GetTextExtentPoint32A (hDC, &label$, LEN(label$), &size)
	w = size.cx
	h = size.cy
' create child static icon control
	style = $$SS_LEFT | $$WS_CHILD | $$WS_VISIBLE
	hStatic = CreateWindowExA (0, &"static", &label$, style, x, y, w, h, hWnd, id, hInst, 0)
	ReleaseDC (hWnd, hDC)
	RETURN hStatic
END FUNCTION
'
'
' ###############################
' #####  SetTaskbarIcon ()  #####
' ###############################
'
FUNCTION  SetTaskbarIcon (hWnd, iconName$, tooltip$)

	SHARED hInst
	NOTIFYICONDATA nid

	IFZ hWnd THEN RETURN
	IFZ iconName$ THEN RETURN

  nid.cbSize = SIZE(nid)
  nid.hWnd   = hWnd
  nid.uID    = hInst
  IF tooltip$ THEN
		nid.uFlags = $$NIF_ICON | $$NIF_MESSAGE | $$NIF_TIP
		nid.szTip  = tooltip$
	ELSE
		nid.uFlags = $$NIF_ICON | $$NIF_MESSAGE
	END IF
  nid.uCallbackMessage = $$WM_TRAYICON
  nid.hIcon  = LoadIconA(hInst, &iconName$)
	ret = Shell_NotifyIconA ($$NIM_ADD, &nid)
	IF nid.hIcon THEN DestroyIcon (nid.hIcon)
	RETURN ret

END FUNCTION
'
'
' ###############################
' #####  DeleteTrayIcon ()  #####
' ###############################
'
FUNCTION  DeleteTrayIcon (hWnd)

	SHARED hInst
	NOTIFYICONDATA nid

  nid.cbSize = SIZE(nid)
  nid.hWnd   = hWnd
  nid.uID    = hInst

	Shell_NotifyIconA ($$NIM_DELETE, &nid)

END FUNCTION
'
'
' ##################################
' #####  ModifyTaskbarIcon ()  #####
' ##################################
'
FUNCTION  ModifyTaskbarIcon (hWnd, iconName$, tooltip$)

	SHARED hInst
	NOTIFYICONDATA nid

	IFZ hWnd THEN RETURN
	IFZ iconName$ THEN RETURN

  nid.cbSize = SIZE(nid)
  nid.hWnd   = hWnd
  nid.uID    = hInst
  IF tooltip$ THEN
		nid.uFlags = $$NIF_ICON | $$NIF_MESSAGE | $$NIF_TIP
		nid.szTip  = tooltip$
	ELSE
		nid.uFlags = $$NIF_ICON | $$NIF_MESSAGE
	END IF
  nid.uCallbackMessage = $$WM_TRAYICON
  nid.hIcon  = LoadIconA(hInst, &iconName$)
	ret = Shell_NotifyIconA ($$NIM_MODIFY, &nid)
	IF nid.hIcon THEN DestroyIcon (nid.hIcon)
	RETURN ret

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
END PROGRAM
