'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo to display directories in a treeview control.
' An imagelist is associated with the treeview control
' in order to display icons alongside the directories.
' The example searches for all of the directories on
' the c:\ drive.
'
PROGRAM	"treeviewdir"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "xio"
	IMPORT  "xsx"				' Standard extended library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "shell32"		' shell32.dll
'
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
DECLARE FUNCTION  AddTreeViewItem (hwndCtl, hParent, label$, idxImage, idxSelectedImage, hInsertAfter)
DECLARE FUNCTION  GetTreeViewSelection (hwndCtl)
DECLARE FUNCTION  GetTreeViewItemText (hwndCtl, hItem, @text$)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  FindDirs (dirStart$, recurse, @dir$[])
DECLARE FUNCTION  GetSysFolderIcon (file$, @hIconFolder, @iIconFolder, @hIconFolderOpen, @iIconFolderOpen)
DECLARE FUNCTION  InitTreeViewImageList (hTreeView)
'
'Control IDs
'
$$TreeView1 = 101
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

	NMHDR nmhdr
	NM_TREEVIEW nmtv
	TV_ITEM tviNew

	SELECT CASE msg
	
		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_NOTIFY :
			idCtrl = wParam
			SELECT CASE idCtrl
				CASE $$TreeView1 :
					GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

				SELECT CASE code :
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
	className$  = "TreeViewDir"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "TreeView Directory."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 230
	h 					= 340
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)
	
' create treeview control
  style = $$TVS_HASLINES | $$TVS_HASBUTTONS | $$TVS_LINESATROOT
	#hTreeView = NewChild ($$WC_TREEVIEW, @text$, style, 10, 10, 200, 280, #winMain, $$TreeView1, $$WS_EX_CLIENTEDGE)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

' create and associate an imagelist to the treeview control
	InitTreeViewImageList(#hTreeView)
	
' create sorted directory information with root c:\
	FindDirs ("c:\\", $$TRUE, @dir$[])
  DIM n[]
	XstQuickSort (@dir$[], @n[], 0, UBOUND(dir$[]), $$SortIncreasing | $$SortCaseInsensitive)

' add all directory items to treeview
	upper = UBOUND(dir$[])
	DIM hItems[upper]										' keep track of item handles
	DIM hwndPrev[256]										' track up to 256 levels deep from root

' create c: root item using icons 2 & 3 from imagelist
	label$ = "Drive_c(C:)"
	hwndPrev[0] = AddTreeViewItem (#hTreeView, 0, label$, 2, 3, $$TVI_LAST)

' add all directories using icons 0 & 1 from imagelist
	FOR i = 0 TO upper
		XstParseStringToStringArray (dir$[i], "\\", @pathList$[])
		levels = UBOUND(pathList$[])
		label$ = pathList$[levels]				' get item text
		IF levels = 1 THEN								' root level item
			hwndPrev[1] = AddTreeViewItem (#hTreeView, hwndPrev[0], label$, 0, 1, $$TVI_LAST)
			hItems[i] = hwndPrev[1]
		ELSE
			hwndPrev[levels] = AddTreeViewItem (#hTreeView, hwndPrev[levels-1], label$, 0, 1, $$TVI_LAST)
			hItems[i] = hwndPrev[levels]
		END IF
	NEXT i

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
FUNCTION  AddTreeViewItem (hwndCtl, hParent, @label$, idxImage, idxSelectedImage, hInsertAfter)

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
' #########################
' #####  FindDirs ()  #####
' #########################
'
' Find all directories within specified starting
' directory. If recurse is $$TRUE, then also find
' all subdirectories.
' IN  : dirStart$ - directory to begin search
'     : recurse - if $$TRUE, then find all subdirectories
' OUT : dir$[] - array of directories (unsorted - faster this way)
' NOTE: use XstQuickSort on dir$[] if sorted array is needed.
'
FUNCTION  FindDirs (dirStart$, recurse, @dir$[])

	FILEINFO  fileinfo[]

	path$ = XstPathString$ (@dirStart$)
	IFZ path$ THEN RETURN ($$TRUE)

	XstGetFileAttributes (@path$, @attribute)
	IFZ (attribute AND $$FileDirectory) THEN RETURN ($$TRUE)

	DIM new$[]
	udir = UBOUND (dir$[])

	pathend$ = RIGHT$ (path$, 1)
	attributeFilter = $$FileDirectory
	IF ((pathend$ != $$PathSlash$) AND (pathend$ != "/")) THEN path$ = path$ + $$PathSlash$

	XstGetFilesAndAttributes (path$ + "*", attributeFilter, @new$[], @fileinfo[])
	idir = udir + 1

' append names of matching directories to end of dir$[]

	IF new$[] THEN
		upper = UBOUND (new$[])
		DIM order[]
'		XstQuickSort (@new$[], @order[], 0, upper, $$SortIncreasing)
		udir = udir + upper + 1
		REDIM dir$[udir]
		FOR i = 0 TO upper
			IF new$[i] THEN
				dir$[idir] = path$ + new$[i]
				IF recurse THEN
					dir$ = dir$[idir]
					FindDirs (@dir$, recurse, @dir$[])
				END IF
				INC idir
			END IF
		NEXT i
	END IF

END FUNCTION
'
'
' #################################
' #####  GetSysFolderIcon ()  #####
' #################################
'
FUNCTION  GetSysFolderIcon (file$, @hIconFolder, @iIconFolder, @hIconFolderOpen, @iIconFolderOpen)

	SHFILEINFO sfi

'	file$ = "c:\\"						' this will give you the hard-disk icon
'	file$ = "c:\\windows\\"		' this gives the standard folder icons

	hSysImageList = SHGetFileInfoA (&file$, 0, &sfi, SIZE(sfi), $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_SYSICONINDEX)
	hIconFolder = sfi.hIcon
	iIconFolder = sfi.iIcon

	il = SHGetFileInfoA (&file$, 0, &sfi, SIZE(sfi), $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_OPENICON | $$SHGFI_SYSICONINDEX)
	hIconFolderOpen = sfi.hIcon
	iIconFolderOpen = sfi.iIcon

	RETURN hSysImageList

END FUNCTION
'
'
' ######################################
' #####  InitTreeViewImageList ()  #####
' ######################################
'
FUNCTION  InitTreeViewImageList (hTreeView)

' create a masked image list for 4 small folder icons
	himl = ImageList_Create (16, 16, $$ILC_COLOR8 | $$ILC_MASK, 4, 0)

' get the system folder icons
  XstGetOSVersion (@major, @minor, @platformId, @version$, @platform$)
  SELECT CASE platform$
    CASE "Windows"  : dir$ = "c:\\windows\\"
    CASE "NT"       : dir$ = "c:\\winnt\\"
    CASE ELSE       : dir$ = "c:\\winnt\\"
  END SELECT
      
  hSysImageList = GetSysFolderIcon (@dir$, @hIconFolder, @iIconFolder, @hIconFolderOpen, @iIconFolderOpen)

' get the C: drive icons
	sil = GetSysFolderIcon (@"c:\\", @hIconCDrive, @iIconCDrive, @hIconCDriveOpen, @iIconCDriveOpen)
'	PRINT hSysImageList, hIconCDrive, iIconCDrive, hIconCDriveOpen, iIconCDriveOpen

' add the icons to the imagelist
	ret1 = ImageList_ReplaceIcon (himl, -1, hIconFolder)			' use index of -1 to add icons
	ret2 = ImageList_ReplaceIcon (himl, -1, hIconFolderOpen)
	ret3 = ImageList_ReplaceIcon (himl, -1, hIconCDrive)
	ret4 = ImageList_ReplaceIcon (himl, -1, hIconCDriveOpen)

'	PRINT "ImageList_ReplaceIcon rets:"; ret1, ret2, ret3, ret4

' associate the imagelist with the treeview control
	SendMessageA (hTreeView, $$TVM_SETIMAGELIST, $$TVSIL_NORMAL, himl)


END FUNCTION
END PROGRAM
