'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of the treeview control in which
' every sub item can be selected and moved to
' another item position.
' Based on BCX example by Andreas Guenther
'
PROGRAM	"treedragdrop"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
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
DECLARE FUNCTION  AddTreeViewItem (hwndCtl, hParent, @label$, idxImage, idxSelectedImage, hInsertAfter)
DECLARE FUNCTION  GetTreeViewSelection (hwndCtl)
DECLARE FUNCTION  GetTreeViewItemText (hwndCtl, hItem, @text$)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  TreeViewSetup (hTreeView)
DECLARE FUNCTION  Tv_OnBeginDrag (hTreeView, lParam)
DECLARE FUNCTION  Tv_OnMouseMove (hTreeView, px, py)
DECLARE FUNCTION  Tv_OnLButtonUp (hTreeView, px, py)
DECLARE FUNCTION  Tv_MoveTree (hTreeView, hDest, hSrc)
DECLARE FUNCTION  Tv_CopyTree (hTreeView, hDest, hSrc)
DECLARE FUNCTION  Tv_CopyChildren (hTreeView, hDest, hSrc)

'Control IDs

$$TreeView1 = 101
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

	SELECT CASE msg

		CASE $$WM_CREATE:
			style = $$TVS_HASLINES | $$TVS_HASBUTTONS | $$TVS_LINESATROOT | $$WS_TABSTOP
			styleEx = $$WS_EX_RIGHTSCROLLBAR | $$WS_EX_CLIENTEDGE
			#hTreeView = NewChild ($$WC_TREEVIEW, text$, style, 0, 0, 0, 0, hWnd, $$TreeView1, styleEx)
			TreeViewSetup (#hTreeView)

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_SIZE :
			width = LOWORD (lParam)
			height = HIWORD (lParam)
			MoveWindow (#hTreeView, 0, 0, width, height, $$TRUE)

' ***** next 3 messages used for Drag N Drop *****

		CASE $$WM_MOUSEMOVE :
			Tv_OnMouseMove (#hTreeView, LOWORD(lParam), HIWORD(lParam))

		CASE $$WM_LBUTTONUP
			Tv_OnLButtonUp (#hTreeView, LOWORD(lParam), HIWORD(lParam))

		CASE $$WM_NOTIFY :
			idCtrl = wParam
			SELECT CASE idCtrl
				CASE $$TreeView1 :
					GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

				SELECT CASE code :

					CASE $$TVN_BEGINDRAG :
						Tv_OnBeginDrag (hwndFrom, lParam)

'					CASE $$TVN_SELCHANGED :
'						hItem = GetTreeViewSelection (#hTreeView)
'						GetTreeViewItemText (#hTreeView, hItem, @text$)
'						msg$ = "Selection has changed\nItem: " + STRING$(hItem) + "\nLabel: " + text$
'						MessageBoxA (hWnd, &msg$, &"TreeView Test", 0)
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
	INITCOMMONCONTROLSEX icex

	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT (0)
	InitCommonControls ()					' initialize comctl32.dll library

  icex.dwSize = SIZE (INITCOMMONCONTROLSEX)
  icex.dwICC = $$ICC_TREEVIEW_CLASSES
  InitCommonControlsEx (&icex)

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

' register window class
	className$  = "TreeViewDragNDrop"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "TreeView Drag N Drop Example."
	style 			= $$WS_POPUPWINDOW | $$WS_CAPTION | $$WS_SYSMENU
	styleEx			= $$WS_EX_WINDOWEDGE | $$WS_EX_RIGHTSCROLLBAR
	w 					= 230
	h 					= 340
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, styleEx)
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
' #####  AddTreeViewItem ()  #####
' ################################
'
FUNCTION  AddTreeViewItem (hwndCtl, hParent, label$, idxImage, idxSelectedImage, hInsertAfter)

	TV_INSERTSTRUCT tvis
	TV_ITEM tvi

	tvi.mask 						= $$TVIF_TEXT | $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_PARAM
	tvi.pszText 				= &label$
	tvi.cchTextMax 			= LEN(label$)
	tvi.iImage 					= idxImage
	tvi.iSelectedImage 	= idxSelectedImage

	tvis.hParent 				= hParent
	tvis.hInsertAfter 	= hInsertAfter
	tvis.item 					= tvi

	RETURN SendMessageA (hwndCtl, $$TVM_INSERTITEM, 0, &tvis)

END FUNCTION
'
'
' #####################################
' #####  GetTreeViewSelection ()  #####
' #####################################
'
FUNCTION  GetTreeViewSelection (hwndCtl)

RETURN SendMessageA (hwndCtl, $$TVM_GETNEXTITEM, $$TVGN_CARET, 0)

END FUNCTION
'
'
' ####################################
' #####  GetTreeViewItemText ()  #####
' ####################################
'
FUNCTION  GetTreeViewItemText (hwndCtl, hItem, @text$)

	TV_ITEM	tvi

	tvi.mask = $$TVIF_TEXT | $$TVIF_HANDLE
	tvi.hItem = hItem
	text$ = NULL$(256)
	tvi.pszText = &text$
	tvi.cchTextMax = 256

	SendMessageA (hwndCtl, $$TVM_GETITEM, 0, &tvi)
	text$ = CSIZE$(text$)

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
' #####  TreeViewSetup ()  #####
' ##############################
'
FUNCTION  TreeViewSetup (hTreeView)

	SHARED hInst
	TV_INSERTSTRUCT tvs
	TVITEM tvi

  SendMessageA (hTreeView, $$WM_SETFONT, GetStockObject($$DEFAULT_GUI_FONT), 0)

	hImageList = ImageList_LoadImage (hInst, &"treeviewicons", 16, 1, RGB (255, 0, 255), $$IMAGE_BITMAP, $$LR_LOADTRANSPARENT)
	SendMessageA (hTreeView, $$TVM_SETIMAGELIST, $$TVSIL_NORMAL, hImageList)

' add root items
	hParentC = AddTreeViewItem (hTreeView, $$TVI_ROOT, "Drive C:", 0, 0, $$TVI_LAST)
	hParentD = AddTreeViewItem (hTreeView, $$TVI_ROOT, "Drive D:", 0, 0, $$TVI_LAST)
	hParentE = AddTreeViewItem (hTreeView, $$TVI_ROOT, "Drive E:", 0, 0, $$TVI_LAST)

' add child items
	text$ = "Folder "

	FOR i = 1 TO 8
		label$ = text$ + STRING$ (i)
		AddTreeViewItem (hTreeView, hParentC, label$, 1, 2, $$TVI_LAST)
		label$ = text$ + STRING$ (8 + i)
		AddTreeViewItem (hTreeView, hParentD, label$, 1, 2, $$TVI_LAST)
		label$ = text$ + STRING$ (16 + i)
		AddTreeViewItem (hTreeView, hParentE, label$, 1, 2, $$TVI_LAST)
	NEXT i

' expand first root item
	SendMessageA (hTreeView, $$TVM_EXPAND, $$TVE_EXPAND, hParentC)

END FUNCTION
'
'
' ###############################
' #####  Tv_OnBeginDrag ()  #####
' ###############################
'
' Startup of DragNDrop (called from WM_NOTIFY code - TVN_BEGINDRAG)
'
FUNCTION  Tv_OnBeginDrag (hTreeView, lParam)

	RECT rect
	POINT hotSpot
	NM_TREEVIEW nmtv
	SHARED bDragging, hDragItem, hImageList

	nmtvAddr = lParam
	RtlMoveMemory (&nmtv, nmtvAddr, SIZE(nmtv))	'kernel32 library function

' Do nothing if the user is attempting to drag a top-level item.
	hItem = nmtv.itemNew.hItem
	IFZ SendMessageA (hTreeView, $$TVM_GETNEXTITEM, $$TVGN_PARENT, hItem) THEN RETURN

' Create a drag image. If the assertion fails, you probably forgot
' to assign an image list to the control with SetImageList. Create-
' DragImage will not work if the control hasn't been assigned an image list!

	hImageList = SendMessageA (hTreeView, $$TVM_CREATEDRAGIMAGE, 0, hItem)

  IF hImageList <> NULL THEN
' Compute the coordinates of the "hot spot"--the location of the
' cursor relative to the upper left corner of the item rectangle.
		SendMessageA (hTreeView, $$TVM_GETITEMRECT, $$TRUE, &rect)
		hotSpot.x = nmtv.ptDrag.x - rect.left
		hotSpot.y = nmtv.ptDrag.y - rect.top

' Capture the mouse and begin dragging.
		ImageList_BeginDrag (hImageList, 0, 0, 0)
		SetCapture (GetParent(hTreeView))
		ImageList_DragEnter (hTreeView, hotSpot.x, hotSpot.y)
		hDragItem = hItem
		bDragging = $$TRUE
  END IF

END FUNCTION
'
'
' ###############################
' #####  Tv_OnMouseMove ()  #####
' ###############################
'
' Move selected drag item around treeview control
'
FUNCTION  Tv_OnMouseMove (hTreeView, px, py)

	TV_HITTESTINFO tvhi
	SHARED bDragging

	IF bDragging THEN
		tvhi.pt.x = px
		tvhi.pt.y = py

' Find out which item (if any) the cursor is over.
		hItem = SendMessageA (hTreeView, $$TVM_HITTEST, 0, &tvhi)

' Erase the old drag image and draw a new one.
		ImageList_DragMove (px, py)

' Highlight the item, or unhighlight all items if the cursor isn't over an item.
		ImageList_DragShowNolock ($$FALSE)
		SendMessageA (hTreeView, $$TVM_SELECTITEM, $$TVGN_DROPHILITE, hItem)
		ImageList_DragShowNolock ($$TRUE)

' Modify the cursor to provide visual feedback to the user.
' Note: It's important to do this AFTER the call to DragMove.
		IFZ hItem THEN
			SetCursor (LoadCursorA (NULL, $$IDC_NO))
		ELSE
			SetCursor (LoadCursorA (NULL, $$IDC_ARROW))
		END IF
  END IF

END FUNCTION
'
'
' ###############################
' #####  Tv_OnLButtonUp ()  #####
' ###############################
'
' End the DragNDrop action
'
FUNCTION  Tv_OnLButtonUp (hTreeView, px, py)

	SHARED bDragging, hImageList, hDragItem
	TV_HITTESTINFO hti

	IF bDragging THEN
' Terminate the dragging operation and release the mouse.
		ImageList_DragLeave (hTreeView)
		ImageList_EndDrag ()
		ReleaseCapture ()
		bDragging = $$FALSE
		SendMessageA (hTreeView, $$TVM_SELECTITEM, $$TVGN_DROPHILITE, 0)

' Delete the image list created by CreateDragImage.
		ImageList_Destroy (hImageList)
		hImageList = 0

' Get the HTREEITEM of the drop target and exit now if it's NULL.
		hti.pt.x = px
		hti.pt.y = py
		hItem = SendMessageA (hTreeView, $$TVM_HITTEST, 0, &hti)
		IFZ hItem THEN RETURN

' Display an error message if the move is illegal.
		IF hItem = hDragItem THEN
			text$ = "An item can't be dropped onto itself"
			MessageBoxA (NULL, &text$, &"Error Message: Tv_OnLButtonUp", 0)
			RETURN
		ELSE
			IF hItem = SendMessageA (hTreeView, $$TVM_GETNEXTITEM, $$TVGN_PARENT, hDragItem) THEN
				text$ = "An item can't be dropped onto its parent"
				MessageBoxA (NULL, &text$, &"Error Message: Tv_OnLButtonUp", 0)
				RETURN
			ELSE
				IF hDragItem = SendMessageA (hTreeView, $$TVM_GETNEXTITEM, $$TVGN_PARENT, hItem) THEN
					text$ = "An item can't be dropped onto one of its children"
					MessageBoxA (NULL, &text$, &"Error Message: Tv_OnLButtonUp", 0)
					RETURN
				END IF
			END IF
		END IF

' Move the dragged item and its subitems (if any) to the drop point.
		Tv_MoveTree (hTreeView, hItem, hDragItem)
		hDragItem = 0
  END IF

END FUNCTION
'
'
' ############################
' #####  Tv_MoveTree ()  #####
' ############################
'
FUNCTION  Tv_MoveTree (hTreeView, hDest, hSrc)

  Tv_CopyTree (hTreeView, hDest, hSrc)
	SendMessageA (hTreeView, $$TVM_DELETEITEM, 0, hSrc)

END FUNCTION
'
'
' ############################
' #####  Tv_CopyTree ()  #####
' ############################
'
FUNCTION  Tv_CopyTree (hTreeView, hDest, hSrc)

	TV_ITEM tvi, tvid
	TV_INSERTSTRUCT tvis

' Get the attributes of item to be copied.
	tvi.mask  			= $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_TEXT
  tvi.hItem 			= hSrc
	text$ 					= NULL$(256)
  tvi.pszText 		= &text$
  tvi.cchTextMax 	= 256
	SendMessageA (hTreeView, $$TVM_GETITEM, 0, &tvi)

	tvid.mask       = $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_TEXT
	text$						= CSTRING$ (tvi.pszText) ' NULL$ (256)
	tvid.pszText    = &text$
	tvid.cchTextMax = 256
	tvid.iImage     = tvi.iImage
	tvid.iSelectedImage = tvi.iSelectedImage

	tvis.hParent      = hDest
	tvis.hInsertAfter = $$TVI_LAST
  tvis.item         = tvid

' Create an exact copy of the item at the destination.
	hNewItem = SendMessageA (hTreeView, $$TVM_INSERTITEM, 0, &tvis)

' If the item has subitems, copy them, too.
  IF SendMessageA (hTreeView, $$TVM_GETNEXTITEM, $$TVGN_CHILD, hSrc) THEN
     Tv_CopyChildren (hTreeView, hNewItem, hSrc)
  END IF

' Select the newly added item.
	SendMessageA (hTreeView, $$TVM_SELECTITEM, $$TVGN_CARET, hNewItem)

END FUNCTION
'
'
' ################################
' #####  Tv_CopyChildren ()  #####
' ################################
'
FUNCTION  Tv_CopyChildren (hTreeView, hDest, hSrc)

	TV_ITEM tvi, tvid
	TV_INSERTSTRUCT tvis

' Get the first subitem.
	hItem = SendMessageA (hTreeView, $$TVM_GETNEXTITEM, $$TVGN_CHILD, hSrc)

	IF hItem THEN
' Create a copy of it at the destination.
		tvi.mask 				= $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_TEXT '|$$TVIF_HANDLE
		tvi.hItem 			= hItem
		text$ 					= NULL$ (256)
		tvi.pszText 		= &text$
		tvi.cchTextMax 	= 256
		SendMessageA (hTreeView, $$TVM_GETITEM, 0, &tvi)

		tvid.mask       = $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_TEXT
		text$ 					= CSTRING$ (tvi.pszText) ' NULL$ (256)
		tvid.pszText    = &text$
		tvid.cchTextMax = 256
		tvid.iImage     = tvi.iImage
		tvid.iSelectedImage = tvi.iSelectedImage

		tvis.hParent      = hDest
		tvis.hInsertAfter = $$TVI_LAST
		tvis.item         = tvid
		hNewItem = SendMessageA (hTreeView, $$TVM_INSERTITEM, 0, &tvis)

' If the subitem has subitems, copy them, too.
		IF SendMessageA (hTreeView, $$TVM_GETNEXTITEM, $$TVGN_CHILD, hItem) THEN
			Tv_CopyChildren (hTreeView, hNewItem, hItem)
		END IF

' Do the same for other subitems of hSrc.
		DO
			hItem = SendMessageA (hTreeView, $$TVM_GETNEXTITEM, $$TVGN_NEXT, hItem)
			IFZ hItem THEN EXIT DO

			tvi.mask       	= $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_TEXT
			tvi.hItem      	= hItem
			text$ 					= NULL$ (256)
			tvi.pszText    	= &text$
			tvi.cchTextMax 	= 256
			SendMessageA (hTreeView, $$TVM_GETITEM, 0, &tvi)

			tvid.mask       = $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_TEXT
			text$ 					= CSTRING$ (tvi.pszText) ' NULL$ (256)
			tvid.pszText    = &text$
			tvid.cchTextMax = 256
			tvid.iImage     = tvi.iImage
			tvid.iSelectedImage = tvi.iSelectedImage

			tvis.hParent      = hDest
			tvis.hInsertAfter = $$TVI_LAST
			tvis.item         = tvid
			hNewItem = SendMessageA (hTreeView, $$TVM_INSERTITEM, 0, &tvis)

			IF SendMessageA (hTreeView, $$TVM_GETNEXTITEM, $$TVGN_CHILD, hItem) THEN
				Tv_CopyChildren (hTreeView, hNewItem, hItem)
			END IF
 		LOOP
  END IF

END FUNCTION
END PROGRAM
