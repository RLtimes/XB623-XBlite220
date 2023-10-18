'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo program using the listview control
' with a progress bar as a subitem.
'
PROGRAM	"lvprogbar"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' standard library
'	IMPORT	"xio"				' console io library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll

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

' functions required for adding progress bars as subitems to listview control

DECLARE FUNCTION  ListViewProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  GetListViewSubItemRect (item, subItem, @left, @top, @right, @bottom)
DECLARE FUNCTION  CreateListViewProgBar (hListView, item, subItem, style, minRange, maxRange, step, pos)
DECLARE FUNCTION  SetListViewData (hwndCtl, iItem, data)
DECLARE FUNCTION  GetListViewData (hwndCtl, iItem)
DECLARE FUNCTION  UpdateListViewProgBars (hListView, fRedraw)
DECLARE FUNCTION  SetListViewProgBarPos (hListView, item, pos)
DECLARE FUNCTION  DeleteListViewProgBar (hListView, item)
DECLARE FUNCTION  StepListViewProgBar (hListView, item)
DECLARE FUNCTION  GetListViewProgBarPos (hListView, item, pos)

' Control ID constants
$$ListView1 = 101
$$ProgressBar1 = 102

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

	SELECT CASE msg

    CASE $$WM_CREATE :
' create a report style List View control
      GetClientRect (hWnd, &rc)
      style = $$LVS_REPORT | $$WS_CLIPCHILDREN
      #hListView = NewChild ($$WC_LISTVIEW, "", style, 0, 0, rc.right, rc.bottom, hWnd, $$ListView1, exStyle)

' set extended listview style to enable full row select style (Win98+)
      exStyle = SendMessageA (#hListView, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
      exStyle = exStyle | $$LVS_EX_FULLROWSELECT
      SendMessageA (#hListView, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)

' add columns for Report View style
      AddListViewColumn (#hListView, 0, 120, "Text")
      AddListViewColumn (#hListView, 1, 220, "Progress Bar")

' add listview items to column 0
      DIM text$[9]
      DIM iImage[9]
      DIM data[9]
      FOR i = 0 TO 9
        text$[i] = "Row " + STRING$(i)
      NEXT i
      AddListViewItems (#hListView, @iImage[], @text$[], @data[])

' create progress bar controls
'			style = $$PBS_SMOOTH
			step = 1
			subIndex = 1
			FOR index = 0 TO 9
				INC style
				style = style MOD 2
				pos = index * 10
				hProgBar = CreateListViewProgBar (#hListView, index, subIndex, style, minRange, maxRange, step, pos)
				INC step
			NEXT index

' subclass listview control
      SetLastError(0)
			#old_lvproc = SetWindowLongA (#hListView, $$GWL_WNDPROC, &ListViewProc())

' start a timer to change progress bar positions
			SetTimer (hWnd, 1, 500, NULL)

' set focus onto listview
			SetFocus (#hListView)

		CASE $$WM_TIMER :
			FOR item = 0 TO 9
				StepListViewProgBar (#hListView, item)
			NEXT item

		CASE $$WM_DESTROY :
			KillTimer (hWnd, 1)
			PostQuitMessage(0)

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
  INITCOMMONCONTROLSEX icc

	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT(0)
	InitCommonControls()					' initialize comctl32.dll library

  icc.dwSize = SIZE (icc)
  icc.dwICC = $$ICC_LISTVIEW_CLASSES
  InitCommonControlsEx (&icc)

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
	w 					= 364
	h 					= 140
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

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
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

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
'
'
' #############################
' #####  ListViewProc ()  #####
' #############################
'
' Subclass ListView Control
'
FUNCTION  ListViewProc (hWnd, msg, wParam, lParam)

  SELECT CASE msg

		CASE $$WM_PAINT :
			UpdateListViewProgBars (hWnd, $$TRUE)

		CASE $$WM_HSCROLL :
			scrollCode = LOWORD (wParam)
			SELECT CASE scrollCode
'				CASE $$SB_ENDSCROLL, $$SB_THUMBTRACK :
				CASE $$SB_ENDSCROLL :
					UpdateListViewProgBars (hWnd, $$FALSE)
			END SELECT
	END SELECT

	RETURN CallWindowProcA (#old_lvproc, hWnd, msg, wParam, lParam)

END FUNCTION
'
'
' #######################################
' #####  GetListViewSubItemRect ()  #####
' #######################################
'
FUNCTION  GetListViewSubItemRect (item, subItem, @left, @top, @right, @bottom)

	RECT rc
	HD_ITEM hdi

' item is zero based (first column)
' subIten is 1 based

' get handle to header control
  hHeader = SendMessageA (#hListView, $$LVM_GETHEADER, 0, 0)
  nColumns = SendMessageA (hHeader, $$HDM_GETITEMCOUNT, 0, 0)

	IF subItem > nColumns-1 THEN RETURN ($$TRUE)

' get list view item dimensions
	w = SendMessageA (#hListView, $$LVM_GETCOLUMNWIDTH, subItem, 0)

' When the LVM_GETITEMRECT message is sent, the left member of the RECT structure
' is used to determine the portion of the list view item for which
' to retrieve the bounding rectangle.

' LVIR_BOUNDS  Returns the bounding rectangle of the entire item, including the icon and label.

	rc.left = $$LVIR_BOUNDS
  SendMessageA (#hListView, $$LVM_GETITEMRECT, item, &rc)

' now add up the column widths to get x position
	FOR i = 1 TO subItem
		cw = SendMessageA (#hListView, $$LVM_GETCOLUMNWIDTH, i-1, 0)
		x = x + cw
	NEXT i

	left   = x
	right  = x + w
	top    = rc.top
	bottom = rc.bottom

END FUNCTION
'
'
' ######################################
' #####  CreateListViewProgBar ()  #####
' ######################################
'
' Create a progress bar which is positioned inside a listview subitem
' Returns 0 on success, -1 on error
' NOTE: only one progress bar per listview row (item) is allowed by this code.
'
FUNCTION  CreateListViewProgBar (hListView, item, subItem, style, minRange, maxRange, step, pos)

	IF GetListViewSubItemRect (item, subItem, @left, @top, @right, @bottom) = $$TRUE THEN RETURN ($$TRUE)
	x = left
	y = top
	w = right - left
	h = bottom - top

' create progress bar
' set parent to ListView control
	hProgBar = NewChild ($$PROGRESS_CLASS, @"", style, x, y, w, h, hListView, 1, 0)
	IFZ hProgBar THEN RETURN ($$TRUE)

' store handle to progress bars in lParam value in listview LVI struct
	SetListViewData (hListView, item, hProgBar)

' store subItem in progbar GWL_USERDATA
	SetWindowLongA (hProgBar, $$GWL_USERDATA, subItem)

' set range
	IFZ maxRange THEN maxRange = 100
	lParam = MAKELONG (minRange, maxRange)
	SendMessageA (hProgBar, $$PBM_SETRANGE, 0, lParam)

' set step increment
	IFZ step THEN step = 10
	SendMessageA (hProgBar, $$PBM_SETSTEP, step, 0)

' set initial position
	SendMessageA (hProgBar, $$PBM_SETPOS, pos, 0)

	RETURN hProgBar

END FUNCTION
'
'
' ################################
' #####  SetListViewData ()  #####
' ################################
'
FUNCTION  SetListViewData (hwndCtl, iItem, data)

	LV_ITEM lvi

	lvi.mask = $$LVIF_PARAM
	lvi.iItem = iItem
	lvi.lParam = data
	RETURN SendMessageA (hwndCtl, $$LVM_SETITEM, 0, &lvi)

END FUNCTION
'
'
' ################################
' #####  GetListViewData ()  #####
' ################################
'
FUNCTION  GetListViewData (hwndCtl, iItem)

	LV_ITEM lvi

	lvi.mask = $$LVIF_PARAM
	lvi.iItem = iItem
	lvi.lParam = 0
	SendMessageA (hwndCtl, $$LVM_GETITEM, 0, &lvi)
	RETURN lvi.lParam

END FUNCTION
'
'
' #######################################
' #####  UpdateListViewProgBars ()  #####
' #######################################
'
' Move all listview progress bars to correct positions
' This repositions all progress bars into column = subItem
' Returns 0 on success, -1 on error
'
FUNCTION  UpdateListViewProgBars (hListView, fRedraw)

	RECT rc
	POINT pt

	IFZ hListView THEN RETURN ($$TRUE)

' get number of items in listview control
	itemCount = SendMessageA (hListView, $$LVM_GETITEMCOUNT, 0, 0)
	IFZ itemCount THEN RETURN ($$TRUE)

	FOR i = 0 TO itemCount-1

' make sure there is a progressbar
		hProgBar = GetListViewData (hListView, i)
		IFZ hProgBar THEN DO NEXT

' get subItem
		subItem = GetWindowLongA (hProgBar, $$GWL_USERDATA)

 		IF GetListViewSubItemRect (i, subItem, @left, @top, @right, @bottom) = $$TRUE THEN DO NEXT
		x = left
		y = top
		w = right - left
		h = bottom - top

' get offset scrolled position of first column
' and adjust x position
		SendMessageA (hListView, $$LVM_GETITEMPOSITION, i, &pt)
		x = x + pt.x - 2

' need to get height of header
		IFZ headerHeight THEN
			hHeader = SendMessageA (hListView, $$LVM_GETHEADER, 0, 0)
			GetWindowRect (hHeader, &rc)
			headerHeight = rc.bottom - rc.top
		END IF

' hide progress bar if it scrolls up onto header control
		IF top <= headerHeight+1 THEN
			ShowWindow (hProgBar, $$SW_HIDE)
' move progress bar into new position but don't update
			MoveWindow (hProgBar, x, y, w, h, 0)
		ELSE
' move progress bar into new position and update
			MoveWindow (hProgBar, x, y, w, h, 1)
			ShowWindow (hProgBar, $$SW_SHOW)
		END IF

	NEXT i

' update listview
	IF fRedraw THEN
		GetClientRect (hListView, &rc)
		rc.top = headerHeight
		InvalidateRect (hListView, &rc, 0)
	END IF

END FUNCTION
'
'
' ######################################
' #####  SetListViewProgBarPos ()  #####
' ######################################
'
' Set progress bar position. Returns the previous position.
'
FUNCTION  SetListViewProgBarPos (hListView, item, pos)

' get number of items in listview control
	itemCount = SendMessageA (hListView, $$LVM_GETITEMCOUNT, 0, 0)
	IF item + 1 > itemCount THEN RETURN ($$TRUE)

' make sure there is a progressbar
	hProgBar = GetListViewData (hListView, item)
	IFZ hProgBar THEN RETURN ($$TRUE)

' set position
	RETURN SendMessageA (hProgBar, $$PBM_SETPOS, pos, 0)

END FUNCTION
'
'
' ######################################
' #####  DeleteListViewProgBar ()  #####
' ######################################
'
FUNCTION  DeleteListViewProgBar (hListView, item)

' get number of items in listview control
	itemCount = SendMessageA (hListView, $$LVM_GETITEMCOUNT, 0, 0)
	IF item + 1 > itemCount THEN RETURN ($$TRUE)

' make sure there is a progressbar
	hProgBar = GetListViewData (hListView, item)
	IFZ hProgBar THEN RETURN ($$TRUE)

	DestroyWindow (hProgBar)

END FUNCTION
'
'
' ####################################
' #####  StepListViewProgBar ()  #####
' ####################################
'
' Step progress bar. Returns the previous position.
'
FUNCTION  StepListViewProgBar (hListView, item)

' get number of items in listview control
	itemCount = SendMessageA (hListView, $$LVM_GETITEMCOUNT, 0, 0)
	IF item + 1 > itemCount THEN RETURN ($$TRUE)

' make sure there is a progressbar
	hProgBar = GetListViewData (hListView, item)
	IFZ hProgBar THEN RETURN ($$TRUE)

	ret = SendMessageA (hProgBar, $$PBM_STEPIT, 0, 0)

	InvalidateRect (hProgBar, NULL, 1)

	RETURN ret

END FUNCTION
'
'
' ######################################
' #####  GetListViewProgBarPos ()  #####
' ######################################
'
FUNCTION  GetListViewProgBarPos (hListView, item, pos)

' get number of items in listview control
	itemCount = SendMessageA (hListView, $$LVM_GETITEMCOUNT, 0, 0)
	IF item + 1 > itemCount THEN RETURN ($$TRUE)

' make sure there is a progressbar
	hProgBar = GetListViewData (hListView, item)
	IFZ hProgBar THEN RETURN ($$TRUE)

' get position
	SendMessageA (hProgBar, $$PBM_SETPOS, pos, 0)

END FUNCTION
END PROGRAM
