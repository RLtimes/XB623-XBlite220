'
'
' ####################
' #####  PROLOG  #####
' ####################

' An image list of system icons is associated with
' a listview control. Each of the listview styles
' can be displayed: icon view, small icon view,
' list view, and report view.
'
PROGRAM	"listviewicons"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"   ' shell32.dll
'
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
DECLARE FUNCTION  AddMenu (hWnd)
DECLARE FUNCTION  SetListViewStyle (hwndCtl, lvStyle)
DECLARE FUNCTION  AddListViewColumn (hwndCtl, iCol, width, heading$)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  GetListViewSelection (lParam, @iItem, @iSubItem)
DECLARE FUNCTION  GetListViewItemText (hwndCtl, iItem, iSubItem, @text$)
DECLARE FUNCTION  SetListViewItemState (hwndCtl, iItem, iSubItem, state, mask)
DECLARE FUNCTION  AddListViewItems (hwndCtl, iColumn, @iImage[], @text$[], @data[])

' Control ID constants
$$ListView1 = 101

$$Menu_File_Exit = 110
$$Menu_Style_Icon = 111
$$Menu_Style_Small = 112
$$Menu_Style_List = 113
$$Menu_Style_Report = 114
'
' ######################
' #####  Entry ()  #####
' ######################
'
' Programs contain:
'   1. A PROLOG with type/function/constant declarations.
'   2. This Entry() function where execution begins.
'   3. Zero or more additional functions.
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
			SELECT CASE id
				CASE $$Menu_File_Exit :
					PostQuitMessage(0)

				CASE $$Menu_Style_Icon :
					CheckMenuRadioItem (#styleMenu, 0, 3, 0, $$MF_BYPOSITION)
					SetListViewStyle (#hListView, $$LVS_ICON | $$LVS_ALIGNTOP | $$LVS_AUTOARRANGE)

				CASE $$Menu_Style_Small :
					CheckMenuRadioItem (#styleMenu, 0, 3, 1, $$MF_BYPOSITION)
					SetListViewStyle (#hListView, $$LVS_SMALLICON | $$LVS_ALIGNTOP | $$LVS_AUTOARRANGE)

				CASE $$Menu_Style_List :
					CheckMenuRadioItem (#styleMenu, 0, 3, 2, $$MF_BYPOSITION)
					SetListViewStyle (#hListView, $$LVS_LIST)

				CASE $$Menu_Style_Report :
					CheckMenuRadioItem (#styleMenu, 0, 3, 3, $$MF_BYPOSITION)
					SetListViewStyle (#hListView, $$LVS_REPORT)
			END SELECT

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
	SHFILEINFO sfi
	SHARED className$, hInst

' register window class
	className$  = "SysIconImageList"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "System Icons"
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 360
	h 					= 410
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' add a menu to the window
	#hMenu = AddMenu (#winMain)

' create a icon style List View control
	GetClientRect (#winMain, &rc)
	style = $$LVS_ICON | $$LVS_ALIGNTOP | $$LVS_AUTOARRANGE
	#hListView = NewChild ($$WC_LISTVIEW, "", style, 0, 0, rc.right, rc.bottom, #winMain, $$ListView1, 0)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

' get handles to large and small system image lists
' note: two image lists are necessary for ListView controls,
' one for small 16x16 icons, and one for 32x32 icons.

	hsilLarge = SHGetFileInfoA (&"c:\\", 0, &sfi, SIZE(sfi), $$SHGFI_LARGEICON | $$SHGFI_ICON | $$SHGFI_SYSICONINDEX)
	hsilSmall = SHGetFileInfoA (&"c:\\", 0, &sfi, SIZE(sfi), $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_SYSICONINDEX)

' get number of system icons
	iCount = ImageList_GetImageCount (hsilLarge)

'	use the first 50
	IF iCount > 50 THEN iCount = 50

' create two new masked image lists, small and large, 64 color
	#himlLarge = ImageList_Create (32, 32, $$ILC_COLOR8 | $$ILC_MASK, iCount, 0)
	#himlSmall = ImageList_Create (16, 16, $$ILC_COLOR8 | $$ILC_MASK, iCount, 0)

' add icons to large and small image lists
	FOR i = 0 TO iCount-1
		hIcon = ImageList_GetIcon (hsilLarge, i, $$ILD_TRANSPARENT)		' create new icons from system image list
		ret = ImageList_ReplaceIcon (#himlLarge, -1, hIcon)						' add icons to image list
		hIcon = ImageList_GetIcon (hsilSmall, i, $$ILD_TRANSPARENT)		' create new icons from system image list
		ret = ImageList_ReplaceIcon (#himlSmall, -1, hIcon)						' add icons to image list
	NEXT i

' associate imagelists to the listview control
	ret = SendMessageA (#hListView, $$LVM_SETIMAGELIST, $$LVSIL_NORMAL, #himlLarge)
	ret = SendMessageA (#hListView, $$LVM_SETIMAGELIST, $$LVSIL_SMALL , #himlSmall)

' now add specific items to ListView control
	FOR i = 0 TO iCount-1
		text$ = "SysIcon: " + STRING$(i)
		AddListViewItem (#hListView, i, text$, i, 0)
	NEXT i

' add one column for Report View style
	ret = AddListViewColumn (#hListView, 0, 150, "System Icons")

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
' ########################
' #####  AddMenu ()  #####
' ########################
'
FUNCTION  AddMenu (hWnd)

' build a main menu
	mainMenu = CreateMenu()							' create main menu

' build dropdown submenus
	fileMenu = CreateMenu()							' create dropdown file menu
	InsertMenuA (mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, fileMenu, &"&File")
	AppendMenuA (fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")

	#styleMenu = CreateMenu()
	InsertMenuA (mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #styleMenu, &"&ListView Styles")
	AppendMenuA (#styleMenu, $$MF_STRING, $$Menu_Style_Icon, &"&Icon View")
	AppendMenuA (#styleMenu, $$MF_STRING, $$Menu_Style_Small, &"&Small Icon View")
	AppendMenuA (#styleMenu, $$MF_STRING, $$Menu_Style_List, &"&List View")
	AppendMenuA (#styleMenu, $$MF_STRING, $$Menu_Style_Report, &"&Report View")

	CheckMenuRadioItem (#styleMenu, 0, 3, 0, $$MF_BYPOSITION)

	SetMenu (hWnd, mainMenu)						' activate the menu
	RETURN mainMenu
END FUNCTION
'
'
' #################################
' #####  SetListViewStyle ()  #####
' #################################
'
FUNCTION  SetListViewStyle (hwndCtl, lvStyle)

	STYLESTRUCT ss

	lStyle = GetWindowLongA (hwndCtl, $$GWL_STYLE)			' get last window style
	IF ((lStyle & $$LVS_TYPEMASK) != lvStyle) THEN			' check if new style is different from last style
		nStyle = (lStyle & ~$$LVS_TYPEMASK) | lvStyle			' create new style flag
		ss.styleOld = lStyle
		ss.styleNew = nStyle
		SendMessageA (hwndCtl, $$WM_STYLECHANGING, $$GWL_STYLE, &ss)	' send $$WM_STYLECHANGING to control to ensure redraw
		SetWindowLongA (hwndCtl, $$GWL_STYLE, nStyle)									' set new style
		SendMessageA (hwndCtl, $$WM_STYLECHANGED, $$GWL_STYLE, &ss)		' send  $$WM_STYLECHANGED to control to ensure redraw
	END IF



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

FUNCTION  AddListViewItems (hwndCtl, iColumn, @iImage[], @text$[], @data[])

	LV_ITEM lvi

	IFZ iColumn THEN
		upper = UBOUND(text$[])
		itemCount = SendMessageA (hwndCtl, $$LVM_GETITEMCOUNT, 0, 0)
		FOR i = 0 TO upper
			lvi.mask = $$LVIF_TEXT | $$LVIF_IMAGE | $$LVIF_PARAM | $$LVIF_STATE
			lvi.state = 0
			lvi.stateMask = 0
			lvi.iItem = i + itemCount
			lvi.pszText = &text$[i]
			lvi.cchTextMax = LEN(text$[i])
			lvi.iImage = iImage[i]
			lvi.iSubItem = 0
			lvi.lParam = data[0]
		SendMessageA (hwndCtl, $$LVM_INSERTITEM, 0, &lvi)
		NEXT i
	ELSE
		upper = UBOUND(text$[])
		itemCount = SendMessageA (hwndCtl, $$LVM_GETITEMCOUNT, 0, 0)
		FOR i = 0 TO upper
			lvi.mask = $$LVIF_TEXT | $$LVIF_IMAGE | $$LVIF_PARAM | $$LVIF_STATE
			lvi.state = 0
			lvi.stateMask = 0
			lvi.iItem = i + itemCount
			lvi.pszText = &text$[i]
			lvi.cchTextMax = LEN(text$[i])
			lvi.iImage = iImage[i]
			lvi.iSubItem = iColumn
			lvi.lParam = data[i]
		SendMessageA (hwndCtl, $$LVM_SETITEM, 0, &lvi)
		NEXT i
	END IF




END FUNCTION
END PROGRAM
