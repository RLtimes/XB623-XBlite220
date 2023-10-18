'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo program using the listview control.
'
PROGRAM	"listview"
VERSION	"0.0002"
'
'	IMPORT	"xma"   		' math library
	IMPORT	"xst"   		' standard library
'	IMPORT	"xio"				' console io library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "shell32"   ' shell32.dll

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  AddListViewItem (hwndCtl, iItem, text$, iImage, data)
DECLARE FUNCTION  AddListViewColumn (hwndCtl, iCol, width, heading$)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  GetListViewSelection (lParam, @iItem, @iSubItem)
DECLARE FUNCTION  GetListViewItemText (hwndCtl, iItem, iSubItem, @text$)
DECLARE FUNCTION  SetListViewItemState (hwndCtl, iItem, iSubItem, state, mask)
DECLARE FUNCTION  AddListViewItems (hwndCtl, @iImage[], @text$[], @data[])
DECLARE FUNCTION  SetListViewSubItems (hwndCtl, iColumn, @text$[], iStart)

' Control ID constants
$$ListView1 = 101

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

		CASE $$WM_NOTIFY :
			idCtrl = wParam
			SELECT CASE idCtrl
				CASE $$ListView1 :
					GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

					SELECT CASE code :
						CASE $$NM_DBLCLK :
							MessageBoxA (hWnd, &"Doubleclick selection", &"ListView Test", 0)

						CASE $$NM_RETURN :
							MessageBoxA (hWnd, &"Return key pressed", &"ListView Test", 0)

						CASE $$LVN_ITEMCHANGED :
								IFT GetListViewSelection (lParam, @iItem, @iSubItem) THEN
									GetListViewItemText (#hListView, iItem, iSubItem, @text$)
									msg$ = "ListView Selection"
									msg$ = msg$ + "\nItem index: " + STRING$(iItem)
									msg$ = msg$ + "\nSubItem index: " + STRING$(iSubItem)
									msg$ = msg$ + "\nText: " + text$
									MessageBoxA (hWnd, &msg$, &"ListView Test", 0)
								END IF
					END SELECT
			END SELECT

		CASE $$WM_SETFOCUS :
			' set focus back onto listview control so selections are highlighted
			SendMessageA (#hListView, $$WM_SETFOCUS, hWnd, 0)

		CASE $$WM_SIZE :
			' make the listview control the size of the window's client area
			MoveWindow (#hListView, 0, 0, LOWORD(lParam), HIWORD(lParam), $$TRUE)

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

	RECT rc
	SHARED className$

' register window class
	className$  = "ListViewDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "ListView Demo"
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 488
	h 					= 200
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' create a report style List View control
	GetClientRect (#winMain, &rc)
	style = $$LVS_REPORT
	#hListView = NewChild ($$WC_LISTVIEW, "", style, 0, 0, rc.right, rc.bottom, #winMain, $$ListView1, 0)

' add columns for Report View style
	ret = AddListViewColumn (#hListView, 0, 120, "Last Name")
	ret = AddListViewColumn (#hListView, 1, 120, "First Name")
	ret = AddListViewColumn (#hListView, 2, 120, "E-Mail")
	ret = AddListViewColumn (#hListView, 3, 120, "Cell Phone")

' add listview items
	DIM last$[7]
	DIM iImage[7]
	DIM data[7]
	last$[0] = "Smith"
	last$[1] = "Jones"
	last$[2] = "White"
	last$[3] = "Johnson"
	last$[4] = "Acker"
	last$[5] = "Boon"
	last$[6] = "Campbell"
	last$[7] = "Tucker"
	AddListViewItems (#hListView, @iImage[], @last$[], @data[])

' set subItems in column 1
	DIM first$[7]
	first$[0] = "Tom"
	first$[1] = "Bob"
	first$[2] = "Jim"
	first$[3] = "John"
	first$[4] = "Allen"
	first$[5] = "Rick"
	first$[6] = "Jerry"
	first$[7] = "Steve"
	SetListViewSubItems (#hListView, 1, @first$[], 0)

' set subItems in column 2
	DIM email$[7]
	email$[0] = "tommy@mymail.net"
	email$[1] = "bb@csi.com"
	email$[2] = "jimbo@gateway.com"
	email$[3] = "JJ@null.com"
	email$[4] = "gotcha@uspsucks.com"
	email$[5] = "xxx@xxx.com"
	email$[6] = "dontgothere@aol.com"
	email$[7] = "agent@ncsa.com"
	SetListViewSubItems (#hListView, 2, @email$[], 0)

' set subItems in column 3
	DIM cell$[7]
	cell$[0] = "123-4567"
	cell$[1] = "555-9999"
	cell$[2] = "345-6789"
	cell$[3] = "717-4444"
	cell$[4] = "098-7654"
	cell$[5] = "689-0432"
	cell$[6] = "666-9999"
	cell$[7] = "933-6712"
	SetListViewSubItems (#hListView, 3, @cell$[], 0)

' set extended listview style to enable full row select style (Win98+)
	exStyle = SendMessageA (#hListView, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
	exStyle = exStyle | $$LVS_EX_FULLROWSELECT
	SendMessageA (#hListView, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)

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
		ret = GetMessageA (&msg, NULL, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
  			TranslateMessage (&msg)
  			DispatchMessageA (&msg)
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
' ################################
' #####  AddListViewItem ()  #####
' ################################
'
FUNCTION  AddListViewItem (hwndCtl, iItem, text$, iImage, data)

	LV_ITEM lvi

	lvi.mask = $$LVIF_TEXT | $$LVIF_IMAGE | $$LVIF_PARAM | $$LVIF_STATE
	lvi.state = 0
	lvi.stateMask = 0
	lvi.iItem = iItem
	lvi.pszText = &text$
	lvi.cchTextMax = LEN(text$)
	lvi.iImage = iImage
	lvi.iSubItem = 0
	lvi.lParam = data

	RETURN SendMessageA (hwndCtl, $$LVM_INSERTITEM, 0, &lvi)

END FUNCTION
'
'
' ##################################
' #####  AddListViewColumn ()  #####
' ##################################
'
FUNCTION  AddListViewColumn (hwndCtl, iCol, width, heading$)

	LV_COLUMN lvcol

	lvcol.mask 				= $$LVCF_FMT | $$LVCF_WIDTH | $$LVCF_TEXT | $$LVCF_SUBITEM
	lvcol.fmt 				= $$LVCFMT_LEFT
	lvcol.cx 					= width
	lvcol.pszText 		= &heading$
	lvcol.cchTextMax 	= LEN(heading$)
	lvcol.iSubItem		= iCol
	RETURN SendMessageA (hwndCtl, $$LVM_INSERTCOLUMN, iCol, &lvcol)

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
' #####################################
' #####  GetListViewSelection ()  #####
' #####################################
'
FUNCTION  GetListViewSelection (lParam, @iItem, @iSubItem)

	NM_LISTVIEW nmlv

	nmlvAddr = lParam
'	XstCopyMemory (nmlvAddr, &nmlv, SIZE(nmlv))	'Xst library function
	RtlMoveMemory (&nmlv, nmlvAddr, SIZE(nmlv))	'kernel32 library function

	IF (nmlv.uOldState & $$LVIS_SELECTED) == 0 && (nmlv.uNewState & $$LVIS_SELECTED) == $$LVIS_SELECTED THEN
		iItem = nmlv.iItem
		iSubItem = nmlv.iSubItem
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF

END FUNCTION
'
'
' ####################################
' #####  GetListViewItemText ()  #####
' ####################################
'
FUNCTION  GetListViewItemText (hwndCtl, iItem, iSubItem, @text$)

	LV_ITEM lvi

	lvi.iSubItem 		= iSubItem
	text$ 					= NULL$(256)
	lvi.cchTextMax 	= LEN(text$)
	lvi.pszText 		= &text$
	SendMessageA (hwndCtl, $$LVM_GETITEMTEXT, iItem, &lvi)
	text$ = CSIZE$(text$)


END FUNCTION
'
'
' #####################################
' #####  SetListViewItemState ()  #####
' #####################################
'
FUNCTION  SetListViewItemState (hwndCtl, iItem, iSubItem, state, mask)

	LV_ITEM lvi

	lvi.stateMask	= mask
	lvi.state 		= value
	lvi.iSubItem 	= iSubItem
	RETURN SendMessageA (hwndCtl, $$LVM_SETITEMSTATE, iItem, &lvi)

END FUNCTION
'
'
' #################################
' #####  AddListViewItems ()  #####
' #################################
'
' Add ListView items by column

FUNCTION  AddListViewItems (hwndCtl, @iImage[], @text$[], @data[])

	LV_ITEM lvi
'	itemCount = SendMessageA (hwndCtl, $$LVM_GETITEMCOUNT, 0, 0)

		upper = UBOUND(text$[])

		FOR i = 0 TO upper
			lvi.mask 				= $$LVIF_TEXT | $$LVIF_IMAGE | $$LVIF_PARAM | $$LVIF_STATE
			lvi.state		 = 0
			lvi.stateMask 	= 0
			lvi.iItem 			= i
			lvi.pszText 		= &text$[i]
			lvi.cchTextMax 	= LEN(text$[i])
			lvi.iImage 			= iImage[i]
			lvi.iSubItem 		= 0
			lvi.lParam 			= data[i]
			SendMessageA (hwndCtl, $$LVM_INSERTITEM, 0, &lvi)
		NEXT i


END FUNCTION
'
'
' ####################################
' #####  SetListViewSubItems ()  #####
' ####################################
'
' Set ListView subItems by column

FUNCTION  SetListViewSubItems (hwndCtl, iColumn, @text$[], iStart)

	LV_ITEM lvi

		upper = UBOUND(text$[])

		FOR i = 0 TO upper
			lvi.mask 				= $$LVIF_TEXT
			lvi.iItem 			= i + iStart
			lvi.pszText 		= &text$[i]
			lvi.cchTextMax 	= LEN(text$[i])
			lvi.iSubItem 		= iColumn
			SendMessageA (hwndCtl, $$LVM_SETITEM, 0, &lvi)
		NEXT i


END FUNCTION
END PROGRAM
