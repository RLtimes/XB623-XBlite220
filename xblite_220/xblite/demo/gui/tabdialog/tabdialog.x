'
'
' ####################
' #####  PROLOG  #####
' ####################

' A simple demo to create a tabbed dialog box using
' loaded resource templates.
'
PROGRAM	"tabdialog"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"comctl32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  DialogProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  SetTabCtlPage (hWnd, page)
DECLARE FUNCTION  TabDialogProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

'Control IDs
$$IDM_FILE_EXIT   = 120
$$IDM_FILE_DIALOG = 121

$$IDD_MAIN 				= 100
$$IDD_PAGE_GENERAL = 101
$$IDD_PAGE_OPTIONS = 102

$$IDC_TAB = 110
$$IDC_EDIT1 = 111
$$IDC_EDIT2 = 112
$$IDC_STATIC1 = 113
$$IDC_STATIC2 = 118
$$IDC_RADIO1 = 114
$$IDC_RADIO2 = 115
$$IDC_RADIO3 = 116
$$IDC_RADIO4 = 117
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

	SELECT CASE msg

		CASE $$WM_DESTROY:
			PostQuitMessage(0)
			RETURN

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$IDM_FILE_EXIT :
					PostQuitMessage(0)
					RETURN

				CASE $$IDM_FILE_DIALOG :

' create dialog box from resource identifier of the dialog box template
					DialogBoxParamA (hInst, $$IDD_MAIN, hWnd, &DialogProc(), 0)

					RETURN
			END SELECT
			RETURN

	END SELECT

RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

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

	SHARED hInst, className$

' register window class
	className$  = "TabDialogBox"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Tabbed Dialog Box Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 200
	h 					= 100
	exStyle			= 0
	#winMain = NewWindow (className$, @title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' build a main menu
	#mainMenu = CreateMenu()				' create main menu

' build dropdown submenus
	#fileMenu = CreateMenu()				' create dropdown file menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
	AppendMenuA (#fileMenu, $$MF_STRING, $$IDM_FILE_EXIT, &"&Exit")
	AppendMenuA (#fileMenu, $$MF_STRING, $$IDM_FILE_DIALOG, &"&Show Dialog")

	SetMenu (#winMain, #mainMenu)						' activate the menu

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window
	UpdateWindow (#winMain)

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
		ret = GetMessageA (&msg, hwnd, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  				TranslateMessage (&msg)						' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)						' send message to window callback function WndProc()
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
' ###########################
' #####  DialogProc ()  #####
' ###########################
'
FUNCTION  DialogProc (hWnd, msg, wParam, lParam)

	TC_ITEM item
	SHARED hInst
	SHARED hNewBrush

	SELECT CASE msg

		CASE $$WM_INITDIALOG:
			hCtl = GetDlgItem (hWnd, $$IDC_TAB)								' get handle to tab control
			item.mask = $$TCIF_TEXT
			item.pszText = &"General"													' set tab label text
			SendMessageA (hCtl, $$TCM_INSERTITEM, 0 , &item)	' insert a new tab into a tab control

			item.pszText = &"Options"
			SendMessageA (hCtl, $$TCM_INSERTITEM, 1 , &item)	' insert a new tab into a tab control

    	SetTabCtlPage (hWnd, 0)														' set the current page to index 0
			XstCenterWindow (hWnd)														' center the dialog box

			hIcon = LoadIconA (hInst, &"scrabble")
			SendMessageA (hWnd, $$WM_SETICON, 1, hIcon)				' set dialog icon

		CASE $$WM_NOTIFY:
			IF (wParam = $$IDC_TAB) THEN
				GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
				hCtl = GetDlgItem (hWnd, $$IDC_TAB)										' get handle of a control in specified dialog box
				IF code = $$TCN_SELCHANGE THEN												' currently selected tab has changed
					index = SendMessageA (hCtl, $$TCM_GETCURSEL, 0, 0) 	' determine the currently selected tab
					SetTabCtlPage (hWnd, index)
				END IF
			ELSE
				RETURN ($$FALSE)
			END IF

		CASE $$WM_CLOSE:
			DeleteObject (hNewBrush)
			EndDialog (hWnd, 0)

		CASE $$WM_CTLCOLORDLG :
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)

		CASE ELSE : RETURN ($$FALSE)

	END SELECT
	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  GetNotifyMsg ()  #####
' #############################
'
FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

	NMHDR nmhdr

	nmhdrAddr = lParam
'	XstCopyMemory (nmhdrAddr, &nmhdr, SIZE(nmhdr))	'Xst library function
	RtlMoveMemory (&nmhdr, nmhdrAddr, SIZE(nmhdr))	'kernel32 library function
	hwndFrom = nmhdr.hwndFrom
	idFrom   = nmhdr.idFrom
	code     = nmhdr.code


END FUNCTION
'
'
' ##############################
' #####  SetTabCtlPage ()  #####
' ##############################
'
FUNCTION  SetTabCtlPage (hWnd, page)

	SHARED hInst

	hGen = GetDlgItem (hWnd, $$IDD_PAGE_GENERAL)
	IFZ hGen THEN
' create first tab page, $$IDD_PAGE_GENERAL
		hGen = CreateDialogParamA (hInst, $$IDD_PAGE_GENERAL, hWnd, &TabDialogProc(), 0)
		SetWindowLongA (hGen, $$GWL_ID, $$IDD_PAGE_GENERAL)
		SetWindowPos (hGen, 0, 0, 0, 0, 0, $$SWP_HIDEWINDOW | $$SWP_NOZORDER | $$SWP_NOACTIVATE | $$SWP_NOSIZE | $$SWP_NOMOVE)
	END IF

  hOpt = GetDlgItem (hWnd, $$IDD_PAGE_OPTIONS)
	IFZ hOpt THEN
' create 2nd tab page, $$IDD_PAGE_OPTIONS
		hOpt = CreateDialogParamA (hInst, $$IDD_PAGE_OPTIONS, hWnd, &TabDialogProc(), 0)
		SetWindowLongA (hOpt, $$GWL_ID, $$IDD_PAGE_OPTIONS)
		SetWindowPos (hOpt, 0, 0, 0, 0, 0, $$SWP_HIDEWINDOW | $$SWP_NOZORDER | $$SWP_NOACTIVATE | $$SWP_NOSIZE | $$SWP_NOMOVE)
	END IF

	SELECT CASE page

		CASE 0:
				SetWindowPos (hGen, 0, 0, 0, 0, 0, $$SWP_SHOWWINDOW | $$SWP_NOZORDER | $$SWP_NOACTIVATE | $$SWP_NOSIZE | $$SWP_NOMOVE)
				SetWindowPos (hOpt, 0, 0, 0, 0, 0, $$SWP_HIDEWINDOW | $$SWP_NOZORDER | $$SWP_NOACTIVATE | $$SWP_NOSIZE | $$SWP_NOMOVE)
				SetFocus (GetWindow (hGen, $$GW_CHILD))

		CASE 1:
				SetWindowPos (hGen, 0, 0, 0, 0, 0, $$SWP_HIDEWINDOW | $$SWP_NOZORDER | $$SWP_NOACTIVATE | $$SWP_NOSIZE | $$SWP_NOMOVE)
				SetWindowPos (hOpt, 0, 0, 0, 0, 0, $$SWP_SHOWWINDOW | $$SWP_NOZORDER | $$SWP_NOACTIVATE | $$SWP_NOSIZE | $$SWP_NOMOVE)
				SetFocus (GetWindow (hOpt, $$GW_CHILD))

	END SELECT

END FUNCTION
'
'
' ##############################
' #####  TabDialogProc ()  #####
' ##############################
'
FUNCTION  TabDialogProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg

		CASE $$WM_INITDIALOG:
			RETURN ($$TRUE)

		CASE $$WM_CTLCOLORDLG :			' set tab bk color to gray
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)

		CASE $$WM_CTLCOLORSTATIC :	' set static controls bk color to gray
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)

		CASE $$WM_CTLCOLORBTN :			' set button/radio controls bk color to gray
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)

	END SELECT
	RETURN ($$FALSE)

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
END PROGRAM
