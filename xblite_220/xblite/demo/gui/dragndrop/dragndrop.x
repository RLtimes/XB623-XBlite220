'
'
' ####################
' #####  PROLOG  #####
' ####################

' This example allows files to be dropped onto
' a listview control from File Explorer.
' ---
' To enable file drag-n-drop on any window or
' control from File Explorer is very easy:
' ---
'	1. Call DragAcceptFiles using handle of window
'    which is to accept dropped files.
' 2. Subclass the control so it can monitor
'    WM_DROPFILE messages.
' 3. Call DrapQueryFileA to retrieve the file
'    names of dropped files.
' 4. Process file as required by application.
'
'
PROGRAM	"dragndrop"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT  "xsx"				' Standard extended library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
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
DECLARE FUNCTION  SetListViewStyle (hwndCtl, lvStyle)
DECLARE FUNCTION  AddListViewColumn (hwndCtl, iCol, width, heading$)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  GetListViewSelection (lParam, @iItem, @iSubItem)
DECLARE FUNCTION  GetListViewItemText (hwndCtl, iItem, iSubItem, @text$)
DECLARE FUNCTION  SetListViewItemState (hwndCtl, iItem, iSubItem, state, mask)
DECLARE FUNCTION  AddListViewItems (hwndCtl, @iImage[], @text$[], @data[])
DECLARE FUNCTION  SetListViewSubItems (hwndCtl, iColumn, @text$[], iStart)
DECLARE FUNCTION  SetListViewSubItem (hwndCtl, iItem, iSubItem, text$)
DECLARE FUNCTION  GetFileInfoProperties (FILEINFO fi, @name$, @kbSize$, @modified$)
DECLARE FUNCTION  SetListViewColumnFormat (hwndCtl, iColumn, fFormat)
DECLARE FUNCTION  ListViewCompareProc (index1, index2, iSubItem)
DECLARE FUNCTION  GetListViewNotifyMsg (lParam, @hwndFrom, @idFrom, @code, @iItem, @iSubItem)
DECLARE FUNCTION  SetListViewSubItemParam (hwndCtl, iItem, iSubItem, lParam)
DECLARE FUNCTION  SetListViewParamsToIndex (hwndCtl, iColumn)
DECLARE FUNCTION  SortListViewColumnText (hwndCtl, iColumn)
DECLARE FUNCTION  ListViewProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  AddListViewFile (hListView, file$)

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

	RECT rect

	SELECT CASE msg

		CASE $$WM_CREATE :

' create a report style List View control
			GetClientRect (hWnd, &rect)
			#hListView = NewChild ($$WC_LISTVIEW, "", $$LVS_REPORT, 0, 0, rect.right, rect.bottom, hWnd, $$ListView1, 0)	' $$WS_EX_CLIENTEDGE

' add columns for Report View style
			AddListViewColumn (#hListView, 0, 192, "Name")
			AddListViewColumn (#hListView, 1,  80, "Size")
			AddListViewColumn (#hListView, 2, 100, "Type")
			AddListViewColumn (#hListView, 3, 140, "Modified")

' change listview column format to right-aligned text
			SetListViewColumnFormat (#hListView, 1, $$LVCFMT_RIGHT)
'			SetListViewColumnFormat (#hListView, 3, $$LVCFMT_RIGHT)

' set extended listview style to enable full row select style (Win98+)
			exStyle = SendMessageA(#hListView, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
			exStyle = exStyle | $$LVS_EX_FULLROWSELECT
			SendMessageA (#hListView, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)

' subclass the listview control so it can handle WM_DROPFILES message
			#old_proc = SetWindowLongA (#hListView, $$GWL_WNDPROC, &ListViewProc())

' register listview window as accepting drag files
			DragAcceptFiles (#hListView, $$TRUE)

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_NOTIFY :
			idCtrl = wParam
			SELECT CASE idCtrl

				CASE $$ListView1 :
					GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

					SELECT CASE code :

'						CASE $$NM_DBLCLK :
'							MessageBoxA (hWnd, &"Doubleclick selection", &"ListView Test", 0)

'						CASE $$NM_RETURN :
'							MessageBoxA (hWnd, &"Return key pressed", &"ListView Test", 0)

'						CASE $$LVN_ITEMCHANGED :
'								IFT GetListViewSelection (lParam, @iItem, @iSubItem) THEN
'									GetListViewItemText (#hListView, iItem, iSubItem, @text$)
'									msg$ = "ListView Selection"
'									msg$ = msg$ + "\nItem index: " + STRING$(iItem)
'									msg$ = msg$ + "\nSubItem index: " + STRING$(iSubItem)
'									msg$ = msg$ + "\nText: " + text$
'									MessageBoxA (hWnd, &msg$, &"ListView Test", 0)
'								END IF

						CASE $$LVN_COLUMNCLICK :
							GetListViewNotifyMsg (lParam, @hwndFrom, @idFrom, @code, @iItem, @iSubItem)
							SortListViewColumnText (hwndFrom, iSubItem)
					END SELECT
			END SELECT

		CASE $$WM_SETFOCUS :
			' set focus back onto listview control so selections are highlighted
			SendMessageA (#hListView, $$WM_SETFOCUS, hWnd, 0)

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
	className$  = "Dragndrop"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Drag files from File Explorer onto this window."
	#winMain = NewWindow (className$, titleBar$, $$WS_OVERLAPPEDWINDOW, 0, 0, 520, 260, 0)

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
' ###################################
' #####  SetListViewSubItem ()  #####
' ###################################
'
FUNCTION  SetListViewSubItem (hwndCtl, iItem, iSubItem, @text$)

	LV_ITEM lvi

	lvi.mask 				= $$LVIF_TEXT
	lvi.iItem 			= iItem
	lvi.pszText 		= &text$
	lvi.cchTextMax 	= LEN(text$)
	lvi.iSubItem 		= iSubItem
	RETURN SendMessageA (hwndCtl, $$LVM_SETITEM, 0, &lvi)

END FUNCTION
'
'
' ######################################
' #####  GetFileInfoProperties ()  #####
' ######################################
'
FUNCTION  GetFileInfoProperties (FILEINFO fi, @name$, @kbSize$, @modified$)

	$MaxDword = 0xFFFF

' get file/directory name
		name$ = LCASE$(fi.name)

'get size of file in kb
		IFT (fi.attributes & $$FileDirectory) THEN
			kbSize$ = ""
		ELSE
'file size in bytes = sizeHigh * $MaxDword + sizeLow
			size = ((fi.sizeHigh * $MaxDword + fi.sizeLow) / 1024.0) + 0.5
			kbSize$ = STRING$(size) + "KB"
		END IF

'get modified time and date
'create giant argument for fileTime$$ from high and low filetime values from fi[]
		fileTime$$ = GMAKE (fi.modifyTimeHigh, fi.modifyTimeLow)

'convert fileTime$$ to system time
		XstFileTimeToDateAndTime (fileTime$$, @year, @month, @day, @hour, @minute, @second, @nanos)

		month$ = STRING$(month)
		IF LEN(month$) < 2 THEN month$ = "0" + month$

		day$ = STRING$(day)
		IF LEN(day$) < 2 THEN day$ = "0" + day$

		date$ = month$ + "/" + day$ + "/" + STRING$(year)

		hour$ = STRING$(hour)
		IF LEN(hour$) < 2 THEN hour$ = "0" + hour$

		minute$ = STRING$(minute)
		IF LEN(minute$) < 2 THEN minute$ = "0" + minute$

		time$ = hour$ + ":" + minute$

		IF hour > 11 && hour < 24 THEN
			ampm$ = "PM"
		ELSE
			ampm$ = "AM"
		END IF

		modified$ = date$ + " " + time$ + ampm$

END FUNCTION
'
'
' ########################################
' #####  SetListViewColumnFormat ()  #####
' ########################################
'
FUNCTION  SetListViewColumnFormat (hwndCtl, iColumn, fFormat)

	LV_COLUMN lvcol

	lvcol.mask = $$LVCF_FMT
	lvcol.fmt  = fFormat

	RETURN SendMessageA (hwndCtl, $$LVM_SETCOLUMN, iColumn, &lvcol)


END FUNCTION
'
'
' ####################################
' #####  ListViewCompareProc ()  #####
' ####################################
'
FUNCTION  ListViewCompareProc (index1, index2, iSubItem)

' index1 and index2 are provided by the lParam attribute from LV_ITEM struct

	GetListViewItemText (#hListView, index1, iSubItem, @text1$)
	GetListViewItemText (#hListView, index2, iSubItem, @text2$)
	RETURN lstrcmpiA (&text1$, &text2$)				'compare strings, case insensitive

END FUNCTION
'
'
' #####################################
' #####  GetListViewNotifyMsg ()  #####
' #####################################
'
FUNCTION  GetListViewNotifyMsg (lParam, @hwndFrom, @idFrom, @code, @iItem, @iSubItem)

	NM_LISTVIEW nmlv
	NMHDR	nmhdr

	nmlvAddr = lParam
'	XstCopyMemory (nmlvAddr, &nmlv, SIZE(nmlv))			'Xst library function
	RtlMoveMemory (&nmlv, nmlvAddr, SIZE(nmlv))			'kernel32 library function

	nmhdr 		= nmlv.hdr
	hwndFrom 	= nmhdr.hwndFrom
	idFrom   	= nmhdr.idFrom
	code     	= nmhdr.code

	iItem			= nmlv.iItem
	iSubItem	= nmlv.iSubItem

END FUNCTION
'
'
' ###################################
' #####  SetListViewSubItem ()  #####
' ###################################
'
FUNCTION  SetListViewSubItemParam (hwndCtl, iItem, iSubItem, lParam)

	LV_ITEM lvi

	lvi.mask 				= $$LVIF_PARAM
	lvi.iItem 			= iItem
	lvi.iSubItem 		= iSubItem
	lvi.lParam			= lParam
	RETURN SendMessageA (hwndCtl, $$LVM_SETITEM, 0, &lvi)

END FUNCTION
'
'
' #########################################
' #####  SetListViewParamsToIndex ()  #####
' #########################################
'
FUNCTION  SetListViewParamsToIndex (hwndCtl, iColumn)

	iCount = SendMessageA (hwndCtl, $$LVM_GETITEMCOUNT, 0, 0)
	IFZ iCount THEN RETURN 0

	FOR i = 0 TO iCount-1
		SetListViewSubItemParam (hwndCtl, i, iColumn, i)
	NEXT i


END FUNCTION
'
'
' #######################################
' #####  SortListViewColumnText ()  #####
' #######################################
'
FUNCTION  SortListViewColumnText (hwndCtl, iColumn)

' note that this will only sort by text in each column
' also see the use of callback function ListViewCompareProc() for comparing strings

	SendMessageA (hwndCtl, $$LVM_SORTITEMS, iColumn, &ListViewCompareProc())
	SetListViewParamsToIndex (hwndCtl, 0)			' reset lParam value in LV_ITEM to new iIndex

END FUNCTION
'
'
' #############################
' #####  ListViewProc ()  #####
' #############################
'
FUNCTION  ListViewProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg

		CASE $$WM_DROPFILES:
			hDrop = wParam
' get count of number of files dropped
			file$ = NULL$ (255)
			fCount = DragQueryFileA (hDrop, -1, &file$, LEN (file$))

' get filename of every dropped file
			IFZ fCount THEN RETURN
			FOR i = 0 TO fCount-1
				file$ = NULL$ (255)
				charCount = DragQueryFileA (hDrop, i, &file$, LEN (file$))
				file$ = CSIZE$ (file$)

' update listview with new file
				AddListViewFile (#hListView, file$)
			NEXT i

		CASE ELSE :
			RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

	END SELECT
END FUNCTION
'
'
' ################################
' #####  AddListViewFile ()  #####
' ################################
'
FUNCTION  AddListViewFile (hListView, file$)

	SHFILEINFO shinfo
	STATIC counter

'define constant
	$UpdateFreq = 15

'assign FILEINFO TYPE struct to fi[]
	FILEINFO fi[], finfo

	IFZ hListView THEN RETURN
	IFZ file$ THEN RETURN

'call XstGetFilesAndAttributes to fill fi[]
'for just files, use this group of flags
'	flags = $$FileNormal | $$FileReadOnly | $$FileHidden | $$FileSystem | $$FileArchive | $$FileTemporary | $$FileAtomicWrite | $$FileExecutable
'for all files and directories, use -1
	flags = -1
	maxLen = XstGetFilesAndAttributes (file$, flags, @files$[], @fi[])

	upper = UBOUND(fi[])
	IF upper = -1 THEN RETURN 0

'assign SHFILEINFO flags
	flags = $$SHGFI_TYPENAME | $$SHGFI_SHELLICONSIZE | $$SHGFI_SYSICONINDEX | $$SHGFI_DISPLAYNAME | $$SHGFI_EXETYPE

'get file info and fill in listview items and subitems
	FOR i = 0 TO upper

'get name, size, and modified properties from FILEINFO
	finfo = fi[i]
	GetFileInfoProperties (finfo, @name$, @kbSize$, @modified$)

'get file type attribute
		XstGetPathComponents (file$, @path$, "", "", "", 0)
		fullPath$ = path$ + name$

		hInfo = SHGetFileInfoA (&fullPath$, 0, &shinfo, SIZE(shinfo), flags)
		type$ = LCASE$(CSIZE$(shinfo.szTypeName))

'add file info to Listview control
		AddListViewItem    (hListView, i, @name$, iImage, i)	' set data or lParam member to index i for sorting
		SetListViewSubItem (hListView, i, 1, @kbSize$)
		SetListViewSubItem (hListView, i, 2, @type$)
		SetListViewSubItem (hListView, i, 3, @modified$)

'update listview control
		INC counter
		IF counter = $UpdateFreq THEN
			counter = 0
			InvalidateRect (hListView, 0, 0)			' redraw listview control
			UpdateWindow (hListView)							' repaint it
		END IF

	NEXT i

END FUNCTION
END PROGRAM
