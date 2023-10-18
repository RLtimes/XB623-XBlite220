'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo creates a "flat" style of toolbar
' with text labels, separators, and tooltips.
' The toolbar bitmap toolbar.bmp contains 9
' button images and is included in the resource
' file toolbar.rc.
'
PROGRAM	"toolbar"
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
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  SetToolTipText (addrTOOLTIPTEXT, text$)

'Control IDs

$$Toolbar1  = 110

$$ToolText1 = 111
$$ToolText2 = 112
$$ToolText3 = 113
$$ToolText4 = 114
$$ToolText5 = 115
$$ToolText6 = 116
$$ToolText7 = 117
$$ToolText8 = 118
$$ToolText9 = 119
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
	SHARED tbStrings$[]
	TOOLTIPTEXT ttt

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_SIZE :
			SendMessageA (#hToolbar1, $$WM_SIZE, wParam, lParam)

		CASE $$WM_NOTIFY :
			idTT = wParam
			GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)			' get info from first NMHDR struct
			SELECT CASE code :
				CASE $$TTN_NEEDTEXT :																' process TTN_NEEDTEXT notify message
				tttAddr = lParam
				SELECT CASE idTT																		' selection on button id
					CASE $$ToolText1 : SetToolTipText (tttAddr, tbStrings$[0])
					CASE $$ToolText2 : SetToolTipText (tttAddr, tbStrings$[1])
					CASE $$ToolText3 : SetToolTipText (tttAddr, tbStrings$[2])
					CASE $$ToolText4 : SetToolTipText (tttAddr, tbStrings$[3])
					CASE $$ToolText5 : SetToolTipText (tttAddr, tbStrings$[4])
					CASE $$ToolText6 : SetToolTipText (tttAddr, tbStrings$[5])
					CASE $$ToolText7 : SetToolTipText (tttAddr, tbStrings$[6])
					CASE $$ToolText8 : SetToolTipText (tttAddr, tbStrings$[7])
					CASE $$ToolText9 : SetToolTipText (tttAddr, tbStrings$[8])
				END SELECT
			END SELECT

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					text$ = "You clicked on button " + STRING$(id)
					MessageBoxA (hWnd, &text$, &"Flat Toolbar Test", 0)
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
	SHARED tbStrings$[]
	TBBUTTON tbbn[]

' register window class
	className$  = "ToolbarDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Toolbar Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 400
	h 					= 100
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' fill TBBUTTON array
	DIM tbbn[10]
	iBMP = 0
	FOR i = 0 TO 10
		SELECT CASE i

			CASE 3, 7 :																		' add a separator
				tbbn[i].fsStyle 		= $$TBSTYLE_SEP

			CASE ELSE :
				tbbn[i].iBitmap 		= iBMP										' id of bitmap
				tbbn[i].idCommand 	= iBMP + $$Toolbar1 + 1		' button control id
				tbbn[i].fsState 		= $$TBSTATE_ENABLED				' enable button
				tbbn[i].fsStyle 		= $$TBSTYLE_BUTTON				' set style
				tbbn[i].iString 		= iBMP										' string index to associate with button
				INC iBMP
		END SELECT
	NEXT i

' create toolbar control with tooltip style
	hwnd 				= #winMain													' parent handle
	wStyle			= $$WS_CHILD | $$WS_VISIBLE | $$WS_BORDER	| $$TBSTYLE_TOOLTIPS | $$TBSTYLE_FLAT	' window style
	wID 				= $$Toolbar1												' child window ID
	nBitmaps 		= 9																	' no of bitmaps in BMP
	hBMinst 		= hInst															' resource instance
	wBMID 			= 1																	' bitmap resource ID
	lpButtons		= &tbbn[0]													' address to TBBUTTON array
	iNumButtons = 11																' no of buttons to create
	dxButton 		= 16																' width of button
	dyButton 		= 15																' height of button
	dxBitmap 		= 16																' width of bitmap
	dyBitmap 		= 15																' height of bitmap
	uStructSize = SIZE(TBBUTTON)										' size of TBBUTTON struct

	#hToolbar1 = CreateToolbarEx (hwnd, wStyle, wID, nBitmaps, hBMinst, wBMID, lpButtons, iNumButtons, dxButton, dyButton, dxBitmap, dyBitmap, uStructSize)

' add text to each button
' note that these strings can be used as tooltips as well
	DIM tbStrings$[8]
	tbStrings$[0] = "New"
	tbStrings$[1] = "Open"
	tbStrings$[2] = "Save"
	tbStrings$[3] = "Cut"
	tbStrings$[4] = "Copy"
	tbStrings$[5] = "Paste"
	tbStrings$[6] = "Print"
	tbStrings$[7] = "Help"
	tbStrings$[8] = "What"

' send TB_ADDSTRING message to toolbar
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &tbStrings$[0])
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &tbStrings$[1])
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &tbStrings$[2])
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &tbStrings$[3])
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &tbStrings$[4])
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &tbStrings$[5])
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &tbStrings$[6])
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &tbStrings$[7])
	last$ = tbStrings$[8] + CHR$(0)
	SendMessageA (#hToolbar1, $$TB_ADDSTRING, 0, &last$)

' resize toolbar to accomodate new text strings
	SendMessageA (#hToolbar1, $$TB_AUTOSIZE, 0, 0)

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
' ###############################
' #####  SetToolTipText ()  #####
' ###############################
'
FUNCTION  SetToolTipText (addrTOOLTIPTEXT, text$)

	TOOLTIPTEXT ttt
	tttAddr = addrTOOLTIPTEXT
	RtlMoveMemory (&ttt, tttAddr, SIZE(ttt))						' copy mem addr for ttt into ttt struct (kernel32)
	ttt.lpszText = &text$																' assign address of tooltip text to ttt.lpszText
	RtlMoveMemory (tttAddr, &ttt, SIZE(ttt))						' copy changed ttt info back to original address

END FUNCTION
END PROGRAM
