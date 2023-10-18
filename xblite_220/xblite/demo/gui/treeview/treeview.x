'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of the treeview control.
'
PROGRAM	"treeview"
VERSION	"0.0002"
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

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_NOTIFY :
			idCtrl = wParam
			SELECT CASE idCtrl
				CASE $$TreeView1 :
					GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

				SELECT CASE code :
					CASE $$NM_DBLCLK :
						MessageBoxA (hWnd, &"Doubleclick selection", &"TreeView Test", 0)

					CASE $$NM_RETURN :
						MessageBoxA (hWnd, &"Return key pressed", &"TreeView Test", 0)

					CASE $$TVN_SELCHANGED :
						hItem = GetTreeViewSelection (#hTreeView)
						GetTreeViewItemText (#hTreeView, hItem, @text$)
						msg$ = "Selection has changed\nItem: " + STRING$(hItem) + "\nLabel: " + text$
						MessageBoxA (hWnd, &msg$, &"TreeView Test", 0)
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

	SHARED className$, hInst

' register window class
	className$  = "TreeView"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "TreeView Control Example."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 230
	h 					= 340
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	style = $$TVS_HASLINES | $$TVS_HASBUTTONS | $$TVS_LINESATROOT
	#hTreeView = NewChild ($$WC_TREEVIEW, text$, style, 10, 10, 200, 280, #winMain, $$TreeView1, $$WS_EX_CLIENTEDGE)

' add some root level items to treeview
	#hwndFruit = AddTreeViewItem (#hTreeView, 0, "Fruits", 0, 0, $$TVI_LAST)
	#hwndVeget = AddTreeViewItem (#hTreeView, 0, "Vegetables", 0, 0, $$TVI_LAST)
	#hwndBread = AddTreeViewItem (#hTreeView, 0, "Breads", 0, 0, $$TVI_LAST)
	#hwndWines = AddTreeViewItem (#hTreeView, 0, "Wines", 0, 0, $$TVI_LAST)

' add some child items to "Fruits" root
	#hwndBanana = AddTreeViewItem (#hTreeView, #hwndFruit, "Banana", 0, 0, $$TVI_LAST)
	#hwndApple  = AddTreeViewItem (#hTreeView, #hwndFruit, "Apple", 0, 0, $$TVI_LAST)
	#hwndOrange = AddTreeViewItem (#hTreeView, #hwndFruit, "Orange", 0, 0, $$TVI_LAST)

' add some child items to "Vegetables" root
	#hwndBeans  = AddTreeViewItem (#hTreeView, #hwndVeget, "Beans", 0, 0, $$TVI_LAST)
	#hwndCarrot = AddTreeViewItem (#hTreeView, #hwndVeget, "Carrot", 0, 0, $$TVI_LAST)
	#hwndPepper = AddTreeViewItem (#hTreeView, #hwndVeget, "Pepper", 0, 0, $$TVI_LAST)

' add some child items to "Pepper" child
	#hwndChile  = AddTreeViewItem (#hTreeView, #hwndPepper, "Chili", 0, 0, $$TVI_LAST)
	#hwndRed    = AddTreeViewItem (#hTreeView, #hwndPepper, "Red", 0, 0, $$TVI_LAST)
	#hwndGreen  = AddTreeViewItem (#hTreeView, #hwndPepper, "Green", 0, 0, $$TVI_LAST)

' add some child items to "Bread" root
	#hwndWhite  = AddTreeViewItem (#hTreeView, #hwndBread, "White", 0, 0, $$TVI_LAST)
	#hwndWhole  = AddTreeViewItem (#hTreeView, #hwndBread, "Whole Grain", 0, 0, $$TVI_LAST)
	#hwndRye    = AddTreeViewItem (#hTreeView, #hwndBread, "Rye", 0, 0, $$TVI_LAST)

' add some child items to "Wines" root
	#hwndWhiteWine = AddTreeViewItem (#hTreeView, #hwndWines, "White", 0, 0, $$TVI_LAST)
	#hwndRedWine   = AddTreeViewItem (#hTreeView, #hwndWines, "Red", 0, 0, $$TVI_LAST)
	#hwndRoseWine  = AddTreeViewItem (#hTreeView, #hwndWines, "Rose", 0, 0, $$TVI_LAST)

' add some child items to "Red" wine child
	#hwndBordeaux  = AddTreeViewItem (#hTreeView, #hwndRedWine, "Bordeaux", 0, 0, $$TVI_LAST)
	#hwndLanguedoc = AddTreeViewItem (#hTreeView, #hwndRedWine, "Languedoc", 0, 0, $$TVI_LAST)
	#hwndBurgundy  = AddTreeViewItem (#hTreeView, #hwndRedWine, "Burgundy", 0, 0, $$TVI_LAST)
	#hwndLoire     = AddTreeViewItem (#hTreeView, #hwndRedWine, "Loire", 0, 0, $$TVI_LAST)

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
END PROGRAM
