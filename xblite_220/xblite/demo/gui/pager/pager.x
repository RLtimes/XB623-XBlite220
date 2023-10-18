'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A pager control is a window container that is used
' with a window that does not have enough display area
' to show all of its content. The pager control allows
' the user to scroll to the area of the window that is
' not currently in view.
' ---
' See MSDN library on Pager Controls:
' http://msdn.microsoft.com/library/default.asp?url=
' /library/en-us/shellcc/platform/commctls/pager/pager.asp
'
PROGRAM	"pager"
VERSION	"0.0002"
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
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  CreateBMPToolbar (hWndParent, ctlID, nBitmaps, bmpID, nButtons, wButton, hButton, wBMP, hBMP, @strings$[], fFlat, noResize)
DECLARE FUNCTION  CreatePager (hWndParent, x, y, w, h, vertical, border)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  GetWindowBorder (hWnd, @style, @size)

' pager border style flags

$$PAGERBORDER_NONE   = 0
$$PAGERBORDER_LINE   = 1
$$PAGERBORDER_CLIENT = 2
$$PAGERBORDER_STATIC = 3


' user control IDs

$$BMPToolbar	= 100
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

	RECT rc
	NMPGCALCSIZE npcs
	SIZEAPI size

	SELECT CASE msg

		CASE $$WM_DESTROY :
			DestroyWindow (#hPager)
			DestroyWindow (#hBMPToolbar)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE ELSE :
					text$ = "You clicked on item " + STRING$(id)
					MessageBoxA (hWnd, &text$, &"Pager Test", 0)
			END SELECT
			RETURN

		CASE $$WM_NOTIFY :
			GetNotifyMsg (lParam, @hwndFrom, @idCtl, @code)
			SELECT CASE code
				CASE $$PGN_CALCSIZE :
					RtlMoveMemory (&npcs, lParam, SIZE(NMPGCALCSIZE))						' copy pager message into npcs
					SELECT CASE npcs.dwFlag																			' find which parameter is requested

						CASE $$PGF_CALCWIDTH :																		' iWidth parameter has been requested
							SendMessageA (#hBMPToolbar, $$TB_GETMAXSIZE, 0, &size)	' get width of toolbar
							npcs.iWidth = size.cx 																	' set iWidth
							RtlMoveMemory (lParam, &npcs, SIZE(NMPGCALCSIZE))				' copy result back to lParam

						CASE $$PGF_CALCHEIGHT :																		' iHeight parameter has been requested
							SendMessageA (#hBMPToolbar, $$TB_GETMAXSIZE, 0, &size)	' get height of toolbar
							npcs.iHeight = size.cy																	' set iHeight
							RtlMoveMemory (lParam, &npcs, SIZE(NMPGCALCSIZE))				' copy result back to lParam
					END SELECT
			END SELECT

		CASE $$WM_SIZE :
			fSizeType = wParam
			width = LOWORD(lParam)																			' width of main window
'			height = HIWORD(lParam)
			SELECT CASE fSizeType
				CASE $$SIZE_RESTORED, $$SIZE_MAXIMIZED  :
					SendMessageA (#hBMPToolbar, $$TB_GETMAXSIZE, 0, &size)	' get height of toolbar
					GetWindowBorder (#hPager, @style, @bw)									' get border size
					height = size.cy + bw + bw															' adjust height by border size
					MoveWindow (#hPager, 0, 0, width, height, $$TRUE)				' set pager control position
			END SELECT
			RETURN

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

' register window class
	className$  = "PagerDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Pager Demonstration."
	style 			= $$WS_OVERLAPPEDWINDOW
	exStyle			= 0

	#winMain = NewWindow (className$, title$, style, 0, 0, 150, 100, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create the pager control
	#hPager = CreatePager (#winMain, 0, 0, $$CW_USEDEFAULT, $$CW_USEDEFAULT, 0, $$PAGERBORDER_CLIENT)

' set pager button size
	SendMessageA (#hPager, $$PGM_SETBUTTONSIZE, 0, 18)

' set pager button color
	SendMessageA (#hPager, $$PGM_SETBKCOLOR, 0, RGB(140, 140, 140))

	DIM strings$[8]
	strings$[0] = "New"
	strings$[1] = "Open"
	strings$[2] = "Save"
	strings$[3] = "Cut"
	strings$[4] = "Copy"
	strings$[5] = "Paste"
	strings$[6] = "Print"
	strings$[7] = "Help"
	strings$[8] = "What"

' create a BMP toolbar control as child of pager control
	#hBMPToolbar = CreateBMPToolbar (#hPager, $$BMPToolbar, 9, 1, 9, 16, 15, 16, 15, @strings$[], $$TRUE, $$TRUE)

' set toolbar control in pager
	SendMessageA (#hPager, $$PGM_SETCHILD, 0, #hBMPToolbar)

	XstCenterWindow (#winMain)								' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)		' show window

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
' #################################
' #####  CreateBMPToolbar ()  #####
' #################################
'
' PURPOSE : Create a toolbar control from a resource bitmap

FUNCTION  CreateBMPToolbar (hWndParent, ctlID, nBitmaps, bmpID, nButtons, wButton, hButton, wBMP, hBMP, @strings$[], fFlat, noResize)

	SHARED hInst
	TBBUTTON tbbn[]

' fill TBBUTTON array
	DIM tbbn[nButtons-1]

	FOR i = 0 TO nButtons-1
		tbbn[i].iBitmap 		= i												' id of bitmap
		tbbn[i].idCommand 	= i	+ ctlID + 1						' button control id
		tbbn[i].fsState 		= $$TBSTATE_ENABLED				' enable button
		tbbn[i].fsStyle 		= $$TBSTYLE_BUTTON 				' set style
		tbbn[i].iString 		= i												' string index to associate with button
	NEXT i

' create toolbar control
	hwnd 				= hWndParent												' parent handle
	wStyle			= $$WS_CHILD | $$WS_VISIBLE | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS | $$CCS_NODIVIDER | $$TBSTYLE_TOOLTIPS 	' window style
	IF noResize THEN wStyle = wStyle | $$CCS_NORESIZE
	IF fFlat 		THEN wStyle = wStyle | $$TBSTYLE_FLAT
	wID 				= ctlID															' child window ID
	nBitmaps 		= nBitmaps													' no of bitmaps in BMP
	hBMinst 		= hInst															' resource instance
	wBMID 			= bmpID															' bitmap resource ID
	lpButtons		= &tbbn[0]													' address to TBBUTTON array
	iNumButtons = nButtons													' no of buttons to create
	dxButton 		= wButton														' width of button
	dyButton 		= hButton														' height of button
	dxBitmap 		= wBMP															' width of bitmap
	dyBitmap 		= hBMP															' height of bitmap
	uStructSize = SIZE(TBBUTTON)										' size of TBBUTTON struct

	hToolbar = CreateToolbarEx (hWndParent, wStyle, wID, nBitmaps, hBMinst, wBMID, lpButtons, iNumButtons, dxButton, dyButton, dxBitmap, dyBitmap, uStructSize)
	IFZ hToolbar THEN RETURN 0

' add text to each button
' note that these strings can be used as tooltips as well

	IF strings$[] THEN
		upper = UBOUND(strings$[])
		FOR i = 0 TO upper
			IF i = upper THEN strings$[i] = strings$[i] + CHR$(0)
			SendMessageA (hToolbar, $$TB_ADDSTRING, 0, &strings$[i])	' send TB_ADDSTRING message to toolbar
		NEXT i
		SendMessageA (hToolbar, $$TB_AUTOSIZE, 0, 0)		' resize toolbar to accomodate new text strings
	END IF

	RETURN hToolbar

END FUNCTION
'
'
' ############################
' #####  CreatePager ()  #####
' ############################
'
' PURPOSE : create a pager control
' vertical - $$TRUE - set pager control in vertical position
' border   - border styles
'            $$PAGERBORDER_NONE	(default)
'            $$PAGERBORDER_LINE
'            $$PAGERBORDER_CLIENT
'            $$PAGERBORDER_STATIC
'            $$PAGERBORDER_WINDOW

FUNCTION  CreatePager (hWndParent, x, y, w, h, vertical, border)

	INITCOMMONCONTROLSEX iccex
	SHARED hInst
	STATIC init
	SHARED pagerBorderStyle, pagerBorderSize

' initialize common controls extended
	IFZ init THEN
		iccex.dwSize = SIZE(iccex)
		iccex.dwICC = $$ICC_PAGESCROLLER_CLASS
		InitCommonControlsEx (&iccex)
		init = $$TRUE
	END IF

	style   = $$WS_VISIBLE | $$WS_CHILD | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS | $$CCS_NODIVIDER  | $$CCS_ADJUSTABLE
	IF vertical THEN
		style = style | $$PGS_VERT
	ELSE
		style = style | $$PGS_HORZ
	END IF

	exStyle = 0

	SELECT CASE border
		CASE $$PAGERBORDER_LINE   :	style   = style | $$WS_BORDER
		CASE $$PAGERBORDER_CLIENT : exStyle = $$WS_EX_CLIENTEDGE
		CASE $$PAGERBORDER_STATIC : exStyle = $$WS_EX_STATICEDGE
	END SELECT

	text$   = ""
	RETURN CreateWindowExA (exStyle, &$$WC_PAGESCROLLER, &text$, style, x, y, w, h, hWndParent, 0, hInst, 0)

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
' ################################
' #####  GetWindowBorder ()  #####
' ################################
'
FUNCTION  GetWindowBorder (hWnd, @style, @size)

' get window border style

' get _EXSTYLE
	lStyle = GetWindowLongA (hWnd, $$GWL_EXSTYLE)
	SELECT CASE TRUE
		CASE lStyle & $$WS_EX_CLIENTEDGE :
			style = $$WS_EX_CLIENTEDGE
			size = 2
			RETURN
		CASE lStyle & $$WS_EX_STATICEDGE :
			style = $$WS_EX_STATICEDGE
			size = 1
			RETURN
	END SELECT

' get _STYLE
	lStyle = GetWindowLongA (hWnd, $$GWL_STYLE)
	IF lStyle & $$WS_BORDER THEN
		style = $$WS_BORDER
		size = 1
	ELSE
		style = 0
		size = 0
	END IF

END FUNCTION
END PROGRAM
