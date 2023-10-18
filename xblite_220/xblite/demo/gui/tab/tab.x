'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo of creating a multi-tab control with the aid of
' a visual tab editor program for PBasic and BCX.
' BCX_QTAB.EXE - Jules Marchildon's Qtab.exe converted
' for outputing BCX code is found on a bcx files page
' on Yahoo groups.
' http://groups.yahoo.com/group/BCX/files/Visual%20BCX%20and%20Other%20Stuff/
'
PROGRAM	"tab"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"  ' comctl32.dll
'	IMPORT  "shell32"   ' shell32.dll
'
TYPE TDLGDATA
	DLGTEMPLATE	.dltt
	USHORT	.menu
	USHORT	.class
	USHORT	.title
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (@className$, @title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (@className$, @text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  TabDialogMainProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  TabPageHolderWndProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  CreateMainTabControl (hWnd)
DECLARE FUNCTION  SetTabPageRectSDK (hTab, rcReturnAddr)
DECLARE FUNCTION  CreateStdTabCtlButtons (hWnd)
DECLARE FUNCTION  CreateControlTabPage1 (hTab)
DECLARE FUNCTION  CreateControlTabPage2 (hTab)
DECLARE FUNCTION  MessageHandlerTabPage1 (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  MessageHandlerTabPage2 (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  InitTrackBarCtrl (hWnd, ctlID, rangeMin, rangeMax, initPos, pageSize, lineSize, ticFreq)
DECLARE FUNCTION  NewDialogBox (hWndParent, width, height, dlgProcAddr, initParam)
DECLARE FUNCTION  CreateControlTabPage5 (hTab)
DECLARE FUNCTION  MessageHandlerTabPage5 (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  MessageHandlerTabPage3 (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  MessageHandlerTabPage4 (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  CreateControlTabPage3 (hTab)
DECLARE FUNCTION  CreateControlTabPage4 (hTab)

$$Menu_File_Exit   = 200
$$Menu_Show_Dialog = 201

'---Main Tab Identifiers
$$IDTAB_MAIN     = 100
$$IDTAB_PAGE_1	 = 101
$$IDTAB_PAGE_2	 = 102
$$IDTAB_PAGE_3	 = 103
$$IDTAB_PAGE_4	 = 104
$$IDTAB_PAGE_5	 = 105
$$IDC_OK    	= 106
$$IDC_CANCEL	   = 107
$$IDC_APPLY 	= 108

'---Page 1 control identifiers
$$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_ALL   = 1000
$$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_JPG   = 1001
$$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_GIF   = 1002
$$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_PNG   = 1003
$$TAB_DOWNLOAD_GROUPBOX_IMAGE          = 1004
$$TAB_DOWNLOAD_RADIOBUTTON_LINK_ALL    = 1005
$$TAB_DOWNLOAD_RADIOBUTTON_LINK_NONE   = 1006
$$TAB_DOWNLOAD_RADIOBUTTON_LINK_STD    = 1007
$$TAB_DOWNLOAD_RADIOBUTTON_LINK_THUMB  = 1008
$$TAB_DOWNLOAD_GROUPBOX_LINK           = 1009
$$TAB_DOWNLOAD_TRACKBAR_1              = 1010
$$TAB_DOWNLOAD_BUTTON_DEFAULT          = 1011
$$TAB_THUMB_STATICLABEL_4              = 1012
$$TAB_THUMB_STATICLABEL_5              = 1013
$$TAB_THUMB_STATICLABEL_6              = 1014
$$TAB_THUMB_STATICLABEL_7              = 1015
$$TAB_THUMB_STATICLABEL_8              = 1016

'---Page 2 control identifiers
$$TAB_THUMB_STATICLABEL_1              = 1017
$$TAB_THUMB_TRACKBAR_SIZE              = 1018
$$TAB_THUMB_BUTTON_IMAGE               = 1019
$$TAB_THUMB_STATICLABEL_2              = 1020
$$TAB_THUMB_STATICLABEL_3              = 1021
$$TAB_THUMB_GROUPBOX_1                 = 1022
$$TAB_THUMB_BUTTON_DEFAULTSIZE         = 1023

'---Page 3 control identifiers
$$TAB_STARTUP_RADIOBUTTON_LASTSIZE  = 1029
$$TAB_STARTUP_RADIOBUTTON_DEFSIZE   = 1031
$$TAB_STARTUP_GROUPBOX_SIZE         = 1032
$$TAB_STARTUP_RADIOBUTTON_BLANK     = 1034
$$TAB_STARTUP_RADIOBUTTON_HOME      = 1035
$$TAB_STARTUP_RADIOBUTTON_LAST      = 1036
$$TAB_STARTUP_GROUPBOX_PAGE         = 1037
$$TAB_STARTUP_STATICLABEL_1         = 1038
$$TAB_STARTUP_EDIT_HOMEPAGE         = 1039
$$TAB_STARTUP_BUTTON_PAGE           = 1040
$$TAB_STARTUP_GROUPBOX_HOME         = 1041
$$TAB_STARTUP_CHECKBOX_AUTO         = 1042
$$TAB_STARTUP_GROUPBOX_OPTIONS      = 1043

'---Page 4 control identifiers

'---Page 5 control identifiers
$$TAB_REG_EDIT_NAME                    = 1024
$$TAB_REG_STATICLABEL_9                = 1025
$$TAB_REG_EDIT_KEY                     = 1026
$$TAB_REG_STATICLABEL_11               = 1027
$$TAB_REG_GROUPBOX_1                   = 1028
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
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

	RECT rc

	SELECT CASE msg

		CASE $$WM_CREATE :

' build the main menu
			#mainMenu = CreateMenu()			' create main menu

' build dropdown submenus
			#fileMenu = CreateMenu()			' create dropdown file menu
			InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
			AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_Show_Dialog, &"&Show Tab Dialog Window")
			AppendMenuA (#fileMenu, $$MF_SEPARATOR, 0, 0)
			AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")

			SetMenu (hWnd, #mainMenu)						' activate the menu

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD (wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD (wParam)

			SELECT CASE id
				CASE $$Menu_File_Exit :
					PostQuitMessage(0)

				CASE $$Menu_Show_Dialog :
					id = NewDialogBox (hWnd, 515, 382, &TabDialogMainProc (), initParam)	' create dialog box
					SELECT CASE id :
						CASE $$IDC_OK :
						CASE $$IDC_CANCEL, $$IDCANCEL :
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

	SHARED winProcAddr
	SHARED className$, hInst, tabPageClassName$
	RECT rc
	WNDCLASS wc

' register the tab page holder class
	tabPageClassName$  = "TABPAGEHOLDER"
	wc.style           = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_OWNDC
	wc.lpfnWndProc     = &TabPageHolderWndProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = 0
	wc.hCursor         = NULL														' LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = $$COLOR_BTNFACE + 1 						' GetStockObject ($$LTGRAY_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &tabPageClassName$
	ret =  RegisterClassA (&wc)

' register window class
	className$  = "TabControlDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
' both parent and tab control must have the WS_CLIPSIBLINGS window style
	titleBar$  	= "Tab Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 300
	h 					= 100
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

' create dialog-like window to contain tab control

'	tabClassName$ = "TABWINDOW"
'	titleBar$  	= "Settings Dialog"
'	style 			= $$WS_TABSTOP | $$WS_CAPTION | $$WS_SYSMENU | $$WS_CLIPSIBLINGS
'	w 					= 515
'	h 					= 394
'	exStyle			= $$WS_EX_DLGMODALFRAME
'	winProcAddr = &TabDialogMainProc ()
'	#hTabMain = NewWindow (tabClassName$, titleBar$, style, x, y, w, h, 0)

'	XstCenterWindow (#hTabMain)									' center window position

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
'				IFZ IsDialogMessageA (#winMain, &msg) THEN
'					IFZ IsDialogMessageA (#hTabMain, &msg) THEN
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  					TranslateMessage (&msg)
  					DispatchMessageA (&msg)
'					END IF
				END IF
		END SELECT
	LOOP

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
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA(hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underline (0 or 1)
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

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
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$, tabPageClassName$

	UnregisterClassA(&className$, hInst)
	UnregisterClassA(&tabPageClassName$, hInst)

END FUNCTION
'
'
' ##################################
' #####  TabDialogMainProc ()  #####
' ##################################
'
FUNCTION  TabDialogMainProc (hWnd, msg, wParam, lParam)

	SHARED hTab[]

	SELECT CASE msg

		CASE $$WM_INITDIALOG :

' add the main tab control
			CreateMainTabControl (hWnd)

' add three standard buttons to bottom of window, ok, apply, cancel
			CreateStdTabCtlButtons (hWnd)

' set title bar text
			title$ = "Setup Options Dialog"
			SetWindowTextA (hWnd, &title$)

' set focus to ok button
			SetFocus (GetDlgItem (hWnd, $$IDC_OK))
			RETURN ($$FALSE)

		CASE $$WM_COMMAND :
			id = LOWORD (wParam)

			SELECT CASE id

' button ok, apply/save changes, close window
				CASE $$IDC_OK :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
						EndDialog (hWnd, id)
					END IF

' button apply, apply/save changes, do not close window
				CASE $$IDC_APPLY :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
					END IF

' button cancel, return without making any changes
				CASE $$IDC_CANCEL, $$IDCANCEL :
					IF HIWORD (wParam) = $$BN_CLICKED THEN
'						SendMessageA (hWnd, $$WM_CLOSE, 0, 0)
						EndDialog (hWnd, id)
					END IF
			END SELECT

		CASE $$WM_NOTIFY  										' trap main tab notifications
			GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

			SELECT CASE idFrom
				CASE $$IDTAB_MAIN :
					SELECT CASE code
						CASE $$TCN_SELCHANGING :
							pageNo = SendMessageA (GetDlgItem (hWnd, $$IDTAB_MAIN), $$TCM_GETCURSEL, 0, 0)
							ShowWindow (hTab[pageNo], $$SW_HIDE)
						CASE $$TCN_SELCHANGE :
							pageNo = SendMessageA (GetDlgItem (hWnd, $$IDTAB_MAIN), $$TCM_GETCURSEL, 0, 0)
							ShowWindow (hTab[pageNo], $$SW_SHOW)
					END SELECT
			END SELECT

		CASE $$WM_DESTROY
' destroy the tab control font
			hFontTab = SendMessageA (GetDlgItem (hWnd, $$IDTAB_MAIN), $$WM_GETFONT, 0, 0)
			IF hFontTab THEN DeleteObject (hFontTab)

' destroy all tab page control parents
			DestroyWindow (GetDlgItem (hWnd, $$IDTAB_PAGE_1))
			DestroyWindow (GetDlgItem (hWnd, $$IDTAB_PAGE_2))
			DestroyWindow (GetDlgItem (hWnd, $$IDTAB_PAGE_3))
			DestroyWindow (GetDlgItem (hWnd, $$IDTAB_PAGE_4))
			DestroyWindow (GetDlgItem (hWnd, $$IDTAB_PAGE_5))

		CASE ELSE :  RETURN ($$FALSE)

	END SELECT

	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  TabPageHolderWndProc ()  #####
' #####################################
'
FUNCTION  TabPageHolderWndProc (hWnd, msg, wParam, lParam)

	SHARED hInst

	TabPageID = GetDlgCtrlID (hWnd)

	SELECT CASE (msg)

		CASE $$WM_CREATE:
			SELECT CASE (TabPageID) :
				CASE $$IDTAB_PAGE_1  : CreateControlTabPage1 (hWnd)
				CASE $$IDTAB_PAGE_2  : CreateControlTabPage2 (hWnd)
				CASE $$IDTAB_PAGE_3  : CreateControlTabPage3 (hWnd)
				CASE $$IDTAB_PAGE_4  : CreateControlTabPage4 (hWnd)
				CASE $$IDTAB_PAGE_5  : CreateControlTabPage5 (hWnd)
			END SELECT

		CASE $$WM_COMMAND, $$WM_NOTIFY, $$WM_HSCROLL, $$WM_VSCROLL :
			SELECT CASE (TabPageID)
				CASE $$IDTAB_PAGE_1  : MessageHandlerTabPage1 (hWnd, msg, wParam, lParam)
				CASE $$IDTAB_PAGE_2  : MessageHandlerTabPage2 (hWnd, msg, wParam, lParam)
				CASE $$IDTAB_PAGE_3  : MessageHandlerTabPage3 (hWnd, msg, wParam, lParam)
				CASE $$IDTAB_PAGE_4  : MessageHandlerTabPage4 (hWnd, msg, wParam, lParam)
				CASE $$IDTAB_PAGE_5  : MessageHandlerTabPage5 (hWnd, msg, wParam, lParam)
			END SELECT

		CASE WM_DESTROY :
' delete fonts for all controls on each page...
			hCtlChild = GetWindow (hWnd, $$GW_CHILD)
			DO WHILE hCtlChild
				hFontCtl = SendMessageA (hCtlChild, $$WM_GETFONT, 0, 0)
				IF hFontCtl THEN DeleteObject (hFontCtl)
				hCtlChild = GetWindow (hCtlChild, $$GW_HWNDNEXT)
			LOOP

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
'
'
' #####################################
' #####  CreateMainTabControl ()  #####
' #####################################
'
FUNCTION  CreateMainTabControl (hWnd)

	RECT rc
	TC_ITEM ttc_item
	SHARED hInst
	SHARED hTab[]

	style = $$WS_CHILD OR $$WS_VISIBLE OR $$WS_TABSTOP OR $$TCS_TABS OR $$TCS_SINGLELINE OR $$TCS_FOCUSONBUTTONDOWN OR $$WS_CLIPSIBLINGS
	styleEx = 0
	SetRect (&rc, 6, 6, 494, 323)

' create tab control
	#hMainTab = CreateWindowExA (styleEx, &"SysTabControl32", &text$, style, rc.left, rc.top, rc.right, rc.bottom, hWnd, $$IDTAB_MAIN, hInst, NULL)

	hFontTab	= NewFont ("MS Sans Serif", 8, 0, 0, 0)
	SendMessageA (#hMainTab, $$WM_SETFONT, hFontTab, $$TRUE)

' insert tabs in the tab control
	DIM text$[4]
	text$[0] = "Download Filters"
	text$[1] = "Thumbnail Size"
	text$[2] = "Start Up"
	text$[3] = "History-Cache"
	text$[4] = "Register"

	FOR i = 0 TO 4
		item$               = text$[i]
		ttc_item.mask       = $$TCIF_TEXT
		ttc_item.pszText    = &item$
		ttc_item.cchTextMax = LEN (item$)
		ttc_item.iImage     = -1
		ttc_item.lParam     = 0
		SendMessageA (#hMainTab, $$TCM_INSERTITEM, i, &ttc_item)
	NEXT

' create the individual tab pages

	style   = $$WS_CHILD
	styleEx = $$WS_EX_CONTROLPARENT

' allow the tab pages to fit evenly within the tab control
	SetTabPageRectSDK (#hMainTab, &rc)

' create tab pages
	DIM hTab[4]

	FOR i = 0 TO 4
		hTab[i] = CreateWindowExA (styleEx, &"TABPAGEHOLDER", &text$, style, rc.left, rc.top, rc.right, rc.bottom, hWnd, ($$IDTAB_PAGE_1+i), hInst, NULL)
	NEXT

' show first tab page as the default page
	ShowWindow (hTab[0], $$SW_SHOW)

	RETURN  #hMainTab


END FUNCTION
'
'
' ##################################
' #####  SetTabPageRectSDK ()  #####
' ##################################
'
FUNCTION  SetTabPageRectSDK (hTab, rcReturnAddr)

	RECT tRect, twRect, pRect

	GetWindowRect (hTab, &twRect)
	GetWindowRect (GetParent (hTab), &pRect)

	lb = twRect.left-pRect.left
	tb = twRect.top-pRect.top
	c  = GetSystemMetrics ($$SM_CYCAPTION)
	f  = GetSystemMetrics ($$SM_CXBORDER)

	SendMessageA (hTab, $$TCM_GETITEMRECT, 0, &tRect)

	tm = 8
	l  = lb - 2 * f + tm
	t  = tb - c - f + tRect.bottom + tm
	r  = twRect.right - twRect.left - 4 * f - 2 * tm
	b  = twRect.bottom - twRect.top - tRect.bottom - 4 * f - 2 * tm

	SetRect (rcReturnAddr, l, t, r, b)


END FUNCTION
'
'
' #######################################
' #####  CreateStdTabCtlButtons ()  #####
' #######################################
'
FUNCTION  CreateStdTabCtlButtons (hWnd)

	RECT rc, rcm
	SHARED hInst

	GetClientRect (hWnd, &rcm)
	cap  = GetSystemMetrics ($$SM_CYCAPTION)
	bord = GetSystemMetrics ($$SM_CXBORDER)
	tm  = 10
	gap = 8

' create ok button
	caption$ = "&OK"
	SetRect (&rc, rcm.right+bord-tm-240-gap*2, rcm.bottom-cap-12, 80, 24)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$BS_DEFPUSHBUTTON
	styleEx = 0
	hButtonOK = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hWnd, $$IDC_OK, hInst, NULL)

' create cancel button
	caption$ = "&Cancel"
	SetRect (&rc, rcm.right+bord-tm-160-gap, rcm.bottom-cap-12, 80, 24)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE
	styleEx = 0
	hButtonCancel = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hWnd, $$IDC_CANCEL, hInst, NULL)

' create apply button
	caption$ = "&Apply"
	SetRect (&rc, rcm.right+bord-tm-80, rcm.bottom-cap-12, 80, 24)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE
	styleEx = 0
	hButtonApply = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left, rc.top,rc.right, rc.bottom, hWnd, $$IDC_APPLY, hInst, NULL)

' set same font of tab control to buttons
	hFontTab = SendMessageA (GetDlgItem (hWnd, $$IDTAB_MAIN), $$WM_GETFONT, 0, 0)
	IF hFontTab THEN
		SendMessageA (hButtonApply,  $$WM_SETFONT, hFontTab, $$TRUE)
		SendMessageA (hButtonCancel, $$WM_SETFONT, hFontTab, $$TRUE)
		SendMessageA (hButtonOK,     $$WM_SETFONT, hFontTab, $$TRUE)
	END IF

END FUNCTION
'
'
' ######################################
' #####  CreateControlTabPage1 ()  #####
' ######################################
'
FUNCTION  CreateControlTabPage1 (hTab)

	RECT rc
	SHARED hInst

	caption$ = "All Image File Types (jpg, gif, png)"
	SetRect (&rc,32,32,188,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_GROUP OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl    = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_ALL, hInst, NULL)
	hFont   = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Only jpg image files"
	SetRect(&rc,32,56,200,20)
	style    = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx  = 0
	hCtl     = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_JPG, hInst, NULL)
	hFont    = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Only gif image files"
	SetRect(&rc,32,80,200,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_GIF, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Only png image files"
	SetRect (&rc,32,104,200,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_PNG, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Image File Type Filter"
	SetRect(&rc,16,8,218,128)

	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_GROUPBOX
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_GROUPBOX_IMAGE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Download all linked or non-linked images"
	SetRect(&rc,32,168,264,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_GROUP OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"BUTTON", &caption$, style, rc.left, rc.top,rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_RADIOBUTTON_LINK_ALL, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Download only images without links"
	SetRect(&rc,32,192,264,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_RADIOBUTTON_LINK_NONE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Download only images with normal links"
	SetRect(&rc,32,216,264,20)

	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_RADIOBUTTON_LINK_STD, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Download only images with image links (thumbnails)"
	SetRect(&rc,32,240,272,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_RADIOBUTTON_LINK_THUMB, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Link Type Filter"
	SetRect(&rc,16,144,440,128)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_GROUPBOX
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_GROUPBOX_LINK, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Trackbar2"
	SetRect(&rc,252,66,203,36)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$TBS_AUTOTICKS OR $$TBS_BOTTOM OR $$TBS_ENABLESELRANGE OR $$TBS_HORZ
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"MSCTLS_TRACKBAR32", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_TRACKBAR_1 , hInst, NULL)

	caption$ = "Set Default Count"
	SetRect(&rc,290,114,130,22)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$BS_PUSHBUTTON
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_DOWNLOAD_BUTTON_DEFAULT, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Set minimum thumbnail image count per page."
	SetRect(&rc,250,16,218,18)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE 'OR $$SS_NOTIFY
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"STATIC", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_THUMB_STATICLABEL_4, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Applies only to images with with image links."
	SetRect(&rc,250,32,219,18)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE 'OR $$SS_NOTIFY
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"STATIC", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_THUMB_STATICLABEL_5, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "Default count is 6."
	SetRect(&rc,250,48,200,18)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE 'OR $$SS_NOTIFY
	styleEx = 0
	hCtl = CreateWindowExA(styleEx, &"STATIC", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_THUMB_STATICLABEL_6, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "0"
	SetRect(&rc,262,102,20,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE 'OR $$SS_NOTIFY
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"STATIC", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_THUMB_STATICLABEL_7, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	caption$ = "20"
	SetRect(&rc,435,102,24,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE 'OR $$SS_NOTIFY
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"STATIC", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab,$$TAB_THUMB_STATICLABEL_8, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT ,hFont, $$TRUE)

	InitTrackBarCtrl (hTab, $$TAB_DOWNLOAD_TRACKBAR_1, 0, 20, 6, 4, 2, 2)

END FUNCTION
'
'
' ######################################
' #####  CreateControlTabPage2 ()  #####
' ######################################
'
FUNCTION  CreateControlTabPage2 (hTab)

	RECT rc
	SHARED hInst

	caption$ = "Select thumbnail size (default is 110x110 pixels)"
	SetRect(&rc,32,30,256,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE 'OR $$SS_NOTIFY
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"STATIC", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_THUMB_STATICLABEL_1, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = ""
	SetRect(&rc,24,50,240,36)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$TBS_AUTOTICKS OR $$TBS_BOTTOM OR $$TBS_ENABLESELRANGE OR $$TBS_HORZ
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"MSCTLS_TRACKBAR32", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_THUMB_TRACKBAR_SIZE, hInst, NULL)

	caption$ = ""
	SetRect(&rc,284,54,110,110)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_PUSHBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_THUMB_BUTTON_IMAGE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "60"
	SetRect(&rc,31,88,40,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE 'OR $$SS_NOTIFY
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"STATIC", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_THUMB_STATICLABEL_2, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "160"
	SetRect(&rc,238,88,40,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE 'OR $$SS_NOTIFY
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"STATIC", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_THUMB_STATICLABEL_3, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Set Default Size"
	SetRect(&rc,284,228,160, 22)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$BS_PUSHBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right,rc.bottom, hTab, $$TAB_THUMB_BUTTON_DEFAULTSIZE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Thumbnail Size"
	SetRect(&rc,11,10,451,252)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_GROUPBOX
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_THUMB_GROUPBOX_1, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)


	InitTrackBarCtrl (hTab, $$TAB_THUMB_TRACKBAR_SIZE, 60, 160, 110, 10, 5, 5)

END FUNCTION
'
'
' #######################################
' #####  MessageHandlerTabPage1 ()  #####
' #######################################
'
FUNCTION  MessageHandlerTabPage1 (hWnd, msg, wParam, lParam)

	SELECT CASE (msg)

		CASE $$WM_COMMAND :
			id   = LOWORD (wParam)
			code = HIWORD (wParam)

			IF code = $$BN_CLICKED THEN
				SELECT CASE id
					CASE $$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_ALL  :
					CASE $$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_JPG  :
					CASE $$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_GIF  :
					CASE $$TAB_DOWNLOAD_RADIOBUTTON_IMAGE_PNG  :
					CASE $$TAB_DOWNLOAD_RADIOBUTTON_LINK_ALL   :
					CASE $$TAB_DOWNLOAD_RADIOBUTTON_LINK_NONE  :
					CASE $$TAB_DOWNLOAD_RADIOBUTTON_LINK_STD   :
					CASE $$TAB_DOWNLOAD_RADIOBUTTON_LINK_THUMB :
					CASE $$TAB_DOWNLOAD_BUTTON_DEFAULT         :
				END SELECT
			END IF
			RETURN

		CASE $$WM_HSCROLL :
			SELECT CASE GetDlgCtrlID (lParam)
				CASE $$TAB_DOWNLOAD_TRACKBAR_1  :
					SELECT CASE LOWORD (wParam)
						CASE $$SB_PAGELEFT      :
						CASE $$SB_PAGERIGHT     :
						CASE $$SB_LINELEFT      :
						CASE $$SB_LINERIGHT     :
						CASE $$SB_TOP           :
						CASE $$SB_BOTTOM        :
						CASE $$SB_ENDSCROLL     :
						CASE $$SB_THUMBPOSITION :
						CASE $$SB_THUMBTRACK    :
					END SELECT
			END SELECT
			RETURN

	END SELECT


END FUNCTION
'
'
' #######################################
' #####  MessageHandlerTabPage2 ()  #####
' #######################################
'
FUNCTION  MessageHandlerTabPage2 (hWnd, msg, wParam, lParam)

	SELECT CASE (msg)

		CASE $$WM_COMMAND :
			id   = LOWORD (wParam)
			code = HIWORD (wParam)

			IF code = $$BN_CLICKED THEN
				SELECT CASE id
					CASE $$TAB_THUMB_BUTTON_DEFAULTSIZE :
				END SELECT
			END IF
			RETURN

		CASE $$WM_HSCROLL :
			SELECT CASE GetDlgCtrlID (lParam)
				CASE $$TAB_DOWNLOAD_TRACKBAR_1  :
					SELECT CASE LOWORD (wParam)
						CASE $$SB_PAGELEFT      :
						CASE $$SB_PAGERIGHT     :
						CASE $$SB_LINELEFT      :
						CASE $$SB_LINERIGHT     :
						CASE $$SB_TOP           :
						CASE $$SB_BOTTOM        :
						CASE $$SB_ENDSCROLL     :
						CASE $$SB_THUMBPOSITION :
						CASE $$SB_THUMBTRACK    :
					END SELECT
			END SELECT
			RETURN

	END SELECT


END FUNCTION
'
'
' #################################
' #####  InitTrackBarCtrl ()  #####
' #################################
'
FUNCTION  InitTrackBarCtrl (hWnd, ctlID, rangeMin, rangeMax, initPos, pageSize, lineSize, ticFreq)

	SendMessageA (GetDlgItem (hWnd, ctlID), $$TBM_SETRANGE, $$TRUE, MAKELONG (rangeMin, rangeMax))
	SendMessageA (GetDlgItem (hWnd, ctlID), $$TBM_SETTICFREQ, ticFreq, 0)
	SendMessageA (GetDlgItem (hWnd, ctlID), $$TBM_SETPAGESIZE, 0, pageSize)
	SendMessageA (GetDlgItem (hWnd, ctlID), $$TBM_SETLINESIZE, 0, lineSize)
	SendMessageA (GetDlgItem (hWnd, ctlID), $$TBM_SETPOS, $$TRUE, initPos)

END FUNCTION
'
'
' #############################
' #####  NewDialogBox ()  #####
' #############################
'
FUNCTION  NewDialogBox (hWndParent, width, height, dlgProcAddr, initParam)

	SHARED hInst
	TDLGDATA tdd				' user defined in this program
	DLGTEMPLATE dltt

' fill in DLGTEMPLATE struct
	dltt.style 	= $$DS_MODALFRAME | $$DS_3DLOOK | $$WS_POPUP | $$WS_CAPTION | $$WS_SYSMENU | $$WS_VISIBLE | $$DS_ABSALIGN  | $$DS_SETFONT
	dltt.dwExtendedStyle 	= 0
	dltt.cdit 						= 0					' number of control items in dialog box, this creates an empty dialog box

	bu = GetDialogBaseUnits ()				' get dialog base units
	screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	screenHeight = GetSystemMetrics ($$SM_CYSCREEN)

	x = (screenWidth - width)/2				' center dialogbox on screen
	y = (screenHeight - height)/2

	dialogUnitX = (x*4)/LOWORD(bu)
	dialogUnitY = (y*8)/HIWORD(bu)

	dltt.x = dialogUnitX
	dltt.y = dialogUnitY

	dialogUnitWidth = (width*4)/LOWORD(bu)		' convert width in pixels to dialog units
	dialogUnitHeight = (height*8)/HIWORD(bu)	' convert height in pixels to dialog units

	dltt.cx = dialogUnitWidth
	dltt.cy = dialogUnitHeight

' fill in TDLGDATA struct
	tdd.dltt 	= dltt
	tdd.menu 	= 0
	tdd.class = 0
	tdd.title = 0

' create dialog box
	RETURN DialogBoxIndirectParamA (hInst, &tdd, hWndParent, dlgProcAddr, initParam)


END FUNCTION
'
'
' ######################################
' #####  CreateControlTabPage5 ()  #####
' ######################################
'
FUNCTION  CreateControlTabPage5 (hTab)

	RECT rc
	SHARED hInst

	caption$ = ""
	SetRect(&rc,115,40,200,22)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE
	styleEx = $$WS_EX_CLIENTEDGE
	hCtl = CreateWindowExA (styleEx, &"EDIT", &caption$, style, rc.left, rc.top, rc.right, rc.bottom, hTab, $$TAB_REG_EDIT_NAME, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Name"
	SetRect(&rc,22,45,84,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$SS_RIGHT
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"STATIC", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_REG_STATICLABEL_9, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = ""
	SetRect(&rc,115,75,200,22)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$ES_PASSWORD
	styleEx = $$WS_EX_CLIENTEDGE
	hCtl = CreateWindowExA (styleEx, &"EDIT", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_REG_EDIT_KEY, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Registration Key"
	SetRect(&rc,22,81,84,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$SS_RIGHT
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"STATIC", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_REG_STATICLABEL_11, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Register Program"
	SetRect(&rc,16,15,329,185)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_GROUPBOX
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$, style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_REG_GROUPBOX_1, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)


END FUNCTION
'
'
' #######################################
' #####  MessageHandlerTabPage5 ()  #####
' #######################################
'
FUNCTION  MessageHandlerTabPage5 (hWnd, msg, wParam, lParam)

	SELECT CASE (msg)

		CASE $$WM_COMMAND :
			id   = LOWORD (wParam)
			code = HIWORD (wParam)

				SELECT CASE id
					CASE $$TAB_REG_EDIT_NAME  :
						SELECT CASE code
							CASE $$EN_CHANGE :
						END SELECT

					CASE $$TAB_REG_EDIT_KEY  :
						SELECT CASE code
							CASE $$EN_CHANGE :
						END SELECT

				END SELECT
			RETURN

	END SELECT


END FUNCTION
'
'
' #######################################
' #####  MessageHandlerTabPage3 ()  #####
' #######################################
'
FUNCTION  MessageHandlerTabPage3 (hWnd, msg, wParam, lParam)

	SELECT CASE (msg)

		CASE $$WM_COMMAND :
			id   = LOWORD (wParam)
			code = HIWORD (wParam)

			IF code = $$BN_CLICKED THEN
				SELECT CASE id
					CASE $$TAB_STARTUP_RADIOBUTTON_LASTSIZE :
					CASE $$TAB_STARTUP_RADIOBUTTON_DEFSIZE :
					CASE $$TAB_STARTUP_RADIOBUTTON_BLANK :
					CASE $$TAB_STARTUP_RADIOBUTTON_HOME :
					CASE $$TAB_STARTUP_RADIOBUTTON_LAST :
					CASE $$TAB_STARTUP_EDIT_HOMEPAGE :
						SELECT CASE code
							CASE $$EN_CHANGE :
						END SELECT
					CASE $$TAB_STARTUP_BUTTON_PAGE :
					CASE $$TAB_STARTUP_CHECKBOX_AUTO :
				END SELECT
			END IF
			RETURN

	END SELECT


END FUNCTION
'
'
' #######################################
' #####  MessageHandlerTabPage4 ()  #####
' #######################################
'
FUNCTION  MessageHandlerTabPage4 (hWnd, msg, wParam, lParam)

	SELECT CASE (msg)

		CASE $$WM_COMMAND :
			id   = LOWORD (wParam)
			code = HIWORD (wParam)

			IF code = $$BN_CLICKED THEN
				SELECT CASE id

				END SELECT
			END IF
			RETURN

	END SELECT


END FUNCTION
'
'
' ######################################
' #####  CreateControlTabPage3 ()  #####
' ######################################
'
FUNCTION  CreateControlTabPage3 (hTab)

	RECT rc
	SHARED hInst

	caption$ = "Using last window positions and sizes"
	SetRect(&rc,24,24,208,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_GROUP OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_RADIOBUTTON_LASTSIZE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Using default window positions and sizes"
	SetRect(&rc,24,56,216,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_RADIOBUTTON_DEFSIZE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "On start up, display program"
	SetRect(&rc,8,8,240,72)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_GROUPBOX
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_GROUPBOX_SIZE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Blank page"
	SetRect(&rc,24,120,200,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_GROUP OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_RADIOBUTTON_BLANK, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Homepage"
	SetRect(&rc,24,144,200,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_RADIOBUTTON_HOME, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Last page downloaded"
	SetRect(&rc,24,168,200,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_AUTORADIOBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_RADIOBUTTON_LAST, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "On start up, download and display"
	SetRect(&rc,8,96,240,96)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_GROUPBOX
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_GROUPBOX_PAGE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Location"
	SetRect(&rc,16,234,48,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$SS_RIGHT
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"STATIC", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_STATICLABEL_1, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = ""
	SetRect(&rc,72,232,248,22)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$ES_AUTOHSCROLL
	styleEx = $$WS_EX_CLIENTEDGE
	hCtl = CreateWindowExA (styleEx, &"EDIT", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_EDIT_HOMEPAGE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Use Current Page"
	SetRect(&rc,336,232,112,22)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$BS_PUSHBUTTON
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_BUTTON_PAGE, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Set Homepage"
	SetRect(&rc,8,208,456,64)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_GROUPBOX
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_GROUPBOX_HOME, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Run Auto Download on start up"
	SetRect(&rc,272,24,184,20)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_TABSTOP OR $$WS_VISIBLE OR $$BS_AUTOCHECKBOX
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_CHECKBOX_AUTO, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

	caption$ = "Start Up Options"
	SetRect(&rc,256,8,208,184)
	style   = $$WS_CHILD OR $$WS_CLIPSIBLINGS OR $$WS_VISIBLE OR $$BS_GROUPBOX
	styleEx = 0
	hCtl = CreateWindowExA (styleEx, &"BUTTON", &caption$,style, rc.left,rc.top,rc.right,rc.bottom, hTab, $$TAB_STARTUP_GROUPBOX_OPTIONS, hInst, NULL)
	hFont = NewFont ("MS Sans Serif", 8, 400, 0, 0)
	SendMessageA (hCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
'
'
' ######################################
' #####  CreateControlTabPage4 ()  #####
' ######################################
'
FUNCTION  CreateControlTabPage4 (hTab)

	RECT rc
	SHARED hInst

END FUNCTION
END PROGRAM
