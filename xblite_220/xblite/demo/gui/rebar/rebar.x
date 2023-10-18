'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo of a rebar control. This control is
' used as a container tool to display child
' controls to be displayed in the main window
' as part of a flexible "cool" toolbar.
' ---
' See MSDN library example: The Rebar Control:
' Using a Coolbar in Your Application
' http://msdn.microsoft.com/library/default.asp?
' url=/library/en-us/dnwui/html/msdn_rebar.asp
' ---
' Also on MSDN library, "Rebar Controls"
' http://msdn.microsoft.com/library/default.asp?
' url=/library/en-us/shellcc/platform/commctls
' /rebar/reflist.asp
'
PROGRAM	"rebar"
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
DECLARE FUNCTION  CreateRebar (hWndParent, w, h, vertical)
DECLARE FUNCTION  CreateToolbarMenu (hWndParent, @menu$[], controlID, firstID)
DECLARE FUNCTION  InsertBand (hWndRebar, hWndControl, bandText$, hBMP, breakLine, fixedSize)
DECLARE FUNCTION  CreateBMPToolbar (hWndParent, ctlID, nBitmaps, bmpID, nButtons, wButton, hButton, wBMP, hBMP, @strings$[], fFlat)

' user control IDs

$$Rebar1 = 100

$$ToolbarMenu1        = 120
$$ToolbarMenu_File    = 121
$$ToolbarMenu_Edit    = 122
$$ToolbarMenu_Search  = 123
$$ToolbarMenu_View    = 124
$$ToolbarMenu_Options = 125
$$ToolbarMenu_Help    = 126

$$PopUp_1      = 130
$$PopUp_2      = 131
$$PopUp_3      = 132
$$PopUp_Exit   = 134

$$Button1			 = 140

$$Combobox1		 = 150

$$BMPToolbar	 = 160
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
			DestroyMenu (#hPopMenu)								' delete the pop-up menu
			DestroyWindow (#hRebar)
			DestroyWindow (#hToolbarMenu)
			DestroyWindow (#hButton)
			DestroyWindow (#hCombobox)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$PopUp_Exit :
    			DestroyWindow (hWnd)

				CASE $$ToolbarMenu_File, $$ToolbarMenu_Edit, $$ToolbarMenu_Search, $$ToolbarMenu_View, $$ToolbarMenu_Options, $$ToolbarMenu_Help :
					SendMessageA (#hToolbarMenu, $$TB_GETRECT, id, &rc)
					MapWindowPoints (#hToolbarMenu, $$HWND_DESKTOP, &rc, 2)
					pt.x = rc.left
					pt.y = rc.bottom
					TrackPopupMenuEx (#hPopMenu, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_VERTICAL, pt.x, pt.y, hWnd, 0)

				CASE ELSE :
					text$ = "You clicked on item " + STRING$(id)
					MessageBoxA (hWnd, &text$, &"Rebar Test", 0)
			END SELECT

		CASE $$WM_SIZE :
			fSizeType = wParam
			width = LOWORD(lParam)
			height = HIWORD(lParam)
			SELECT CASE fSizeType
				CASE $$SIZE_RESTORED, $$SIZE_MAXIMIZED  :
					MoveWindow (#hRebar, 0, 0, width, height, $$TRUE)
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

	REBARBANDINFO rbbi
	SHARED className$

' register window class
	className$  = "RebarDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Rebar Demonstration."
	style 			= $$WS_OVERLAPPEDWINDOW
	exStyle			= 0

	#winMain = NewWindow (className$, title$, style, 0, 0, 500, 200, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create the rebar control
	#hRebar = CreateRebar (#winMain, $$CW_USEDEFAULT, $$CW_USEDEFAULT, 0)

' now create child "band" controls to insert into rebar

' create toolbar "menu" band
' this is a toolbar that displays strings but no bmp images
	DIM menu$[5]
	menu$[0] = "&File"
	menu$[1] = "&Edit"
	menu$[2] = "&Search"
	menu$[3] = "&View"
	menu$[4] = "&Options"
	menu$[5] = "&Help"
	#hToolbarMenu = CreateToolbarMenu (#winMain, @menu$[], $$ToolbarMenu1, $$ToolbarMenu_File)

' insert ToolbarMenu into rebar
	InsertBand (#hRebar, #hToolbarMenu, "", 0, 0, 0)

' create a button control
	#hButton = NewChild ($$BUTTON, "Button", $$BS_PUSHBUTTON, 0, 0, 75, 20, #winMain, $$Button1, 0)

' insert button control into rebar on next band line
	InsertBand (#hRebar, #hButton, "", 0, $$TRUE, 0)

' create a combobox control
	#hCombobox = NewChild ("combobox", "", $$CBS_DROPDOWNLIST | $$WS_VSCROLL, 0, 0, 125, 125, #winMain, $$Combobox1, $$WS_EX_CLIENTEDGE)

' insert combobox with text into rebar
	InsertBand (#hRebar, #hCombobox, "Label ", 0, 0, 0)

' insert a text band into rebar
	InsertBand (#hRebar, 0, "Text Band", 0, 0, 0)

' create a BMP toolbar control
	#hBMPToolbar = CreateBMPToolbar (#winMain, $$BMPToolbar, 15, 1, 15, 21, 16, 21, 16, @strings$[], $$TRUE)

' insert toolbar into rebar on next band line
	InsertBand (#hRebar, #hBMPToolbar, "", 0, $$TRUE, 0)

' create pop-up menu to use with menu toolbar
' normally you would create a separate PopupMenu for each
' menu item
	#hPopMenu = CreatePopupMenu ()

' add menu items to pop-up menu
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_1,    &"&La")
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_2,    &"&Di")
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_3,    &"Da&h")
	AppendMenuA (#hPopMenu, $$MF_SEPARATOR, 0, 0)
	AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_Exit, &"&Exit")

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
' ############################
' #####  CreateRebar ()  #####
' ############################
'
' Create a Rebar control
' vertical arg = style flag to set rebar in vertical position

FUNCTION  CreateRebar (hWndParent, w, h, vertical)

	INITCOMMONCONTROLSEX iccex
	SHARED hInst

' initialize common controls extended
	iccex.dwSize = SIZE(iccex)
	iccex.dwICC = $$ICC_USEREX_CLASSES | $$ICC_COOL_CLASSES
	ret = InitCommonControlsEx (&iccex)

	style   = $$WS_VISIBLE | $$WS_CHILD | $$WS_BORDER | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS | $$RBS_VARHEIGHT | $$RBS_BANDBORDERS | $$CCS_NODIVIDER  | $$CCS_ADJUSTABLE
	IF vertical THEN style = style | $$CCS_VERT

	text$   = ""
	RETURN CreateWindowExA (0, &$$REBARCLASSNAME, &text$, style, 0, 0, w, h, hWndParent, 0, hInst, 0)
'	RETURN CreateWindowA (&$$REBARCLASSNAME, &text$, style, 0, 0, w, h, hWndParent, 0, hInst, 0)

END FUNCTION
'
'
' ##################################
' #####  CreateToolbarMenu ()  #####
' ##################################
'
FUNCTION  CreateToolbarMenu (hWndParent, @menu$[], controlID, firstID)

	SHARED hInst
	TBBUTTON tbb[]

	IFZ menu$[] THEN RETURN

	upper = UBOUND(menu$[])
	DIM tbb[upper]

	FOR i = 0 TO upper
		tbb[i].iBitmap = $$I_IMAGENONE
		tbb[i].idCommand = firstID + i
		tbb[i].fsState = $$TBSTATE_ENABLED
		IF menu$[i] = "|" THEN
			tbb[i].fsStyle = $$TBSTYLE_SEP
		ELSE
			tbb[i].fsStyle = $$TBSTYLE_BUTTON | $$TBSTYLE_AUTOSIZE
		END IF
		tbb[i].iString = i
	NEXT i

	style = $$WS_CHILD | $$WS_VISIBLE | $$TBSTYLE_LIST | $$TBSTYLE_FLAT | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS | $$CCS_NODIVIDER | $$CCS_NORESIZE
	hToolbar = CreateToolbarEx (hWndParent, style, controlID, 0, hInst, firstID, &tbb[0], upper+1, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, SIZE(TBBUTTON))
	IFZ hToolbar THEN RETURN

' set menu strings
	FOR i = 0 TO upper
		IF menu$[i] = "|" THEN DO NEXT
		IF i = upper THEN menu$[upper] = menu$[upper] + CHR$(0)
		SendMessageA (hToolbar, $$TB_ADDSTRING, 0, &menu$[i])
	NEXT i

' resize toolbar to accomodate new text strings
'	SendMessageA (hToolbar, $$TB_AUTOSIZE, 0, 0)

	RETURN hToolbar

END FUNCTION
'
'
' ###########################
' #####  InsertBand ()  #####
' ###########################
'
' PURPOSE : Insert a child control into a rebar control
'	hWndRebar 	- handle of rebar control
' hWndControl - handle of child control to insert into rebar control
' bandText$ 	- text label to add to band
'	hBMP 				- handle to background bitmap
' breakLine 	- $$TRUE - add control to next band line
' fixedSize 	- $$TRUE - band cannot be resized

FUNCTION  InsertBand (hWndRebar, hWndControl, bandText$, hBMP, breakLine, fixedSize)

	REBARBANDINFO rbbi
	RECT rc

	IFZ hWndRebar THEN RETURN

	hWndReal = hWndControl

	IF hWndControl THEN
		rbbi.fMask = $$RBBIM_CHILD | $$RBBIM_CHILDSIZE
	END IF

	GetWindowRect (hWndReal, &rc)
	rc.bottom = rc.bottom + 2

	IF hBMP THEN
		rbbi.fMask = rbbi.fMask | $$RBBIM_BACKGROUND
	END IF

	rbbi.fMask = rbbi.fMask | $$RBBIM_STYLE | $$RBBIM_ID | $$RBBIM_COLORS | $$RBBIM_SIZE

	IF bandText$ THEN
		rbbi.fMask 	= rbbi.fMask | $$RBBIM_TEXT
		rbbi.lpText = &bandText$
		rbbi.cch 		= LEN(bandText$)
	END IF

	rbbi.fStyle = $$RBBS_CHILDEDGE | $$RBBS_FIXEDBMP

' start band on next band line
	IF breakLine THEN
		rbbi.fStyle = rbbi.fStyle | $$RBBS_BREAK
	END IF

' the band is not able to be resized
	IF fixedSize THEN
		rbbi.fStyle = rbbi.fStyle | $$RBBS_FIXEDSIZE
	ELSE
		rbbi.fStyle = rbbi.fStyle & ~ $$RBBS_FIXEDSIZE
	END IF

	IF hWndReal THEN
		rbbi.hwndChild = hWndReal
		rbbi.cxMinChild = rc.right - rc.left

' check to see if the control is a toolbar and get height
		className$ = NULL$(255)
		GetClassNameA (hWndControl, &className$, LEN(className$))
		className$ = UCASE$(CSIZE$(className$))
		IF className$ = "TOOLBARWINDOW32" THEN
			rbbi.cyMinChild = HIWORD (SendMessageA (hWndControl, $$TB_GETBUTTONSIZE, 0, 0))
		ELSE
			rbbi.cyMinChild = rc.bottom - rc.top
		END IF
	END IF

	bandCount = SendMessageA (hWndRebar, $$RB_GETBANDCOUNT, 0, 0)

	rbbi.wID 			= bandCount + 1
	rbbi.clrBack 	= GetSysColor ($$COLOR_BTNFACE)
	rbbi.clrFore 	= GetSysColor ($$COLOR_BTNTEXT)
	rbbi.cx 			= 200
	rbbi.hbmBack 	= hBMP

	rbbi.cbSize = SIZE(REBARBANDINFO)

' insert control into rebar band

' specify the zero-based index where the band
' is inserted in wParam
' to add the band to the end of the bar,
' specify -1 in the wParam

	RETURN SendMessageA (hWndRebar, $$RB_INSERTBAND, -1, &rbbi)

END FUNCTION
'
'
' #################################
' #####  CreateBMPToolbar ()  #####
' #################################
'
' PURPOSE : Create a toolbar control from a resource bitmap

FUNCTION  CreateBMPToolbar (hWndParent, ctlID, nBitmaps, bmpID, nButtons, wButton, hButton, wBMP, hBMP, @strings$[], fFlat)

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
	wStyle			= $$WS_CHILD | $$WS_VISIBLE | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS | $$CCS_NODIVIDER | $$TBSTYLE_TOOLTIPS | $$CCS_NORESIZE' window style
	IF fFlat THEN wStyle = wStyle | $$TBSTYLE_FLAT
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

	hToolbar = CreateToolbarEx (hwnd, wStyle, wID, nBitmaps, hBMinst, wBMID, lpButtons, iNumButtons, dxButton, dyButton, dxBitmap, dyBitmap, uStructSize)
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
END PROGRAM
