'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo to display folders & files in a treeview control.
' The treeview is updated as folder nodes are selected.
' User can select if individual files are to be displayed.
' Optionally, one can use the code to filter the displayed files.
' A system imagelist is associated with the treeview control
' in order to display icons alongside both folders and files.
'
PROGRAM	"filetree"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "xio"
	IMPORT  "xsx"				' Standard extended library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"
	
PACKED FILE_NOTIFY_INFORMATION
   XLONG .NextEntryOffset
   XLONG .Action
   XLONG .FileNameLength
   STRING*1280 .FileName
END TYPE

TYPE CONTROLDATA
	XLONG .hTree
	STRING * 3 .drive
END TYPE
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
DECLARE FUNCTION  GetSysFolderIcon (@hIconFolder, @iIconFolder, @hIconFolderOpen, @iIconFolderOpen)
DECLARE FUNCTION  InitTreeViewImageList (hTreeView)
DECLARE FUNCTION  InitDriveInfo (hTree)
DECLARE FUNCTION InsertDriveItem (hTree, @driveString$)
DECLARE FUNCTION InsertItem (hTree, mask, @item$, image, selectedImage, state, stateMask, lParam, hParent, hInsertAfter)
DECLARE FUNCTION AddDriveStrings (drive$)
DECLARE FUNCTION InsertDummyItem (hTree, hParent)
DECLARE FUNCTION GetRootItem (hTree)
DECLARE FUNCTION LookForChanges (hTree, @drive$)
DECLARE FUNCTION TrackChanges (pParam)
DECLARE FUNCTION Update (hTree, @strCurPath$, action)
DECLARE FUNCTION SetItemState (hTree, hItem, state, stateMask)
DECLARE FUNCTION GetItemFrmPath (hTree, @path$)
DECLARE FUNCTION GetItemState (hTree, hItem, stateMask)
DECLARE FUNCTION DeleteAllItems (hTree, hParentItem)
DECLARE FUNCTION GetItemText$ (hTree, hItem)
DECLARE FUNCTION DeleteItem (hTree, hItem)
DECLARE FUNCTION SetItemText (hTree, hItem, @text$)
DECLARE FUNCTION GetChildItem (hTree, hItem)
DECLARE FUNCTION GetNextSiblingItem (hTree, hItem)
DECLARE FUNCTION GetDriveItem (hTree, @path$)
DECLARE FUNCTION ExpandPathToItem (hTree, @path$, hItem)
DECLARE FUNCTION IsDirectory (hTree, hItem)
DECLARE FUNCTION GetItemImage (hTree, hItem, @image, @selectedImage)
DECLARE FUNCTION ExpandTreeView (hTree, hItem, flag)
DECLARE FUNCTION OnItemExpanding (hTree, lParam, @result)
DECLARE FUNCTION GetFullPath$ (hTree, strPath$, hItem)
DECLARE FUNCTION SetItemImage (hTree, hItem, image, selectedImage)
DECLARE FUNCTION DoWaitCursor (code)
DECLARE FUNCTION BeginWaitCursor ()
DECLARE FUNCTION EndWaitCursor ()
DECLARE FUNCTION FillItem (hTree, @strFindCriteria$, hPresentItem)
DECLARE FUNCTION GetParentItem (hTree, hItem)
DECLARE FUNCTION IsDriveItem (hTree, hItem)
DECLARE FUNCTION SetFileFlag (hTree, flag)
DECLARE FUNCTION OnKeyDown (hTree, lParam, @result)
DECLARE FUNCTION UpdateTree (hTree)
DECLARE FUNCTION IsValidDir (hTree, hItem)
DECLARE FUNCTION FillFileItems (hTree, hItem)
DECLARE FUNCTION OptimizeShowingDrives (hTree, driveItem)
DECLARE FUNCTION DeleteFileItems (hTree, hItem)
DECLARE FUNCTION SetSubDirState (hTree, hItem)
DECLARE FUNCTION UpdateDriveInfo (hTree)
DECLARE FUNCTION SetFileFilter (hTree, filter$)
DECLARE FUNCTION GetSelectedPath (hTree, @path$)
DECLARE FUNCTION SetSelectedPath (hTree, path$)
DECLARE FUNCTION DeleteDriveItem (hTree, driveName$)
DECLARE FUNCTION GetSysFileIcon (file$, @hIcon, @iIcon)
DECLARE FUNCTION GetSysDriveIcon (drive$, @hIcon, @iIcon)
DECLARE FUNCTION GetSysImageListHandle ()
DECLARE FUNCTION GetMyComputerIcon (@iIcon)
DECLARE FUNCTION NewFont (fontName$, pointSize, weight, italic, underline, angle#)
DECLARE FUNCTION SetNewFont (hwndCtl, hFont)
'
'Control IDs
'
$$TreeView1 = 200
$$Static    = 201
$$Check     = 202
$$Button    = 203

$$ALL_FILES				= "*.*"
$$NONE						= ""
$$PATH_SEPERATOR	= "\\"

$$SYSFILEATTR = 0x4111  ' $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_SYSICONINDEX | $$SHGFI_USEFILEATTRIBUTES
$$SIZE_SFI    = 352

$$IDS_ERR_DRIVE_READ = "The drive is either not ready or network connection is not restored.  Please try later.   "  
$$IDS_APP_TITLE      = "Directory Explorer"
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

'	XioCreateConsole (title$, 850)	' create console, if console is not wanted, comment out this line
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
	SHARED hUpdateSemph
	SHARED err
	SHARED fileFlag, dblClkFlag, dblClkMsg, folderItemMask
	SHARED strCurFilter$
	
	SELECT CASE msg
		
		CASE $$WM_CREATE :
			' create treeview control
			style = $$TVS_HASLINES | $$TVS_HASBUTTONS | $$TVS_LINESATROOT | $$WS_TABSTOP
			#hTreeView = NewChild ($$WC_TREEVIEW, @text$, style, 0, 20, 300, 420, hWnd, $$TreeView1, $$WS_EX_CLIENTEDGE)
			
			folderItemMask = $$TVIF_HANDLE | $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE | $$TVIF_STATE  | $$TVIF_TEXT

			' create and associate an imagelist to the treeview control
			InitTreeViewImageList(#hTreeView)

			hUpdateSemph = CreateSemaphoreA (NULL, 1, 1, NULL)
			IF (!hUpdateSemph) THEN err = GetLastError() : PRINT "CreateSemaphore error: "; err

			' Initially set the filter to *.*
			filter$ = $$ALL_FILES
			SetFileFilter (#hTreeView, filter$)

			InitDriveInfo (#hTreeView)
			ExpandTreeView (#hTreeView, GetRootItem (#hTreeView), $$TVE_EXPAND)
	
		CASE $$WM_DESTROY :
			DeleteObject (#hArial)
			PostQuitMessage(0)
			
		CASE $$WM_COMMAND :
			controlID = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam
			
			SELECT CASE controlID
				CASE $$Check  : 
					state = SendMessageA (hwndCtl, $$BM_GETCHECK, 0, 0)
					SetFileFlag (#hTreeView, state)
					UpdateTree (#hTreeView)
					
				CASE $$Button :
					BeginWaitCursor()
					UpdateTree (#hTreeView)
					EndWaitCursor()
			END SELECT 

		CASE $$WM_NOTIFY :
			idCtrl = wParam
			SELECT CASE idCtrl
				CASE $$TreeView1 :
					GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

				SELECT CASE code :
'					CASE $$NM_RETURN :
'						MessageBoxA (hWnd, &"Return key pressed", &"TreeView Test", 0)

					CASE $$NM_DBLCLK: 
						hItem = GetTreeViewSelection (#hTreeView)
						GetTreeViewItemText (#hTreeView, hItem, @path$)
						path$ = GetFullPath$ (#hTreeView, path$, hItem)
						text$ = "  " + path$
						ret = SetWindowTextA (#hStatic, &text$)
'						PRINT "Treeview DBLCLK: item: "; path$
						SetSelectedPath (#hTreeView, path$)

					CASE $$TVN_SELCHANGED :
'						PRINT "TVN_SELCHANGED"
						hItem = GetTreeViewSelection (#hTreeView)
						GetTreeViewItemText (#hTreeView, hItem, @path$)
						path$ = GetFullPath$ (#hTreeView, path$, hItem)
						SetSelectedPath (#hTreeView, path$)
'						msg$ = "Selection has changed\nItem: " + STRING$(hItem) + "\nLabel: " + path$
'						MessageBoxA (hWnd, &msg$, &"TreeView Test", 0)
						SetWindowTextA (GetDlgItem (hWnd, $$Static), &path$)
						
					CASE $$TVN_ITEMEXPANDING : 
						OnItemExpanding (#hTreeView, lParam, @result)
						RETURN result
						
					CASE $$TVN_KEYDOWN : OnKeyDown (#hTreeView, lParam, @result)
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
	w 					= 350
	h 					= 520
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)
	
	#hStatic = NewChild ("static", "", $$SS_LEFTNOWORDWRAP, 0, 0, 300, 20, #winMain, $$Static, $$WS_EX_STATICEDGE)
	
	#hArial = NewFont ("Arial", 9, $$FW_NORMAL, 0, 0, 0)
	SetNewFont (#hStatic, #hArial)
	
	#hCheck = NewChild ("button", "Display Files", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 10, 450, 130, 24, #winMain, $$Check, 0)
	SetNewFont (#hCheck, #hArial)
	
	#hRefresh = NewChild ("button", "Refresh Tree - F5", $$BS_PUSHBUTTON | $$WS_TABSTOP, 140, 450, 150, 24, #winMain, $$Button, 0)
	SetNewFont (#hRefresh, #hArial)
	
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

	MSG msg

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
				hwnd = GetActiveWindow ()
				IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN		' send only non-dialog messages
  				TranslateMessage (&msg)					' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)					' send message to window callback function WndProc()
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
' ################################
' #####  AddTreeViewItem ()  #####
' ################################
'
' hInsertAfter - handle to the item after which the new item
' is to be inserted or one of the following values:

' Value	Meaning
' TVI_FIRST	Inserts the item at the beginning of the list.
' TVI_LAST	Inserts the item at the end of the list.
' TVI_SORT	Inserts the item into the list in alphabetical order.
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
	RtlMoveMemory (&nmhdr, nmhdrAddr, SIZE(nmhdr))	'kernel32 library function
	hwndFrom = nmhdr.hwndFrom
	idFrom   = nmhdr.idFrom
	code     = nmhdr.code

END FUNCTION

'
' #################################
' #####  GetSysFolderIcon ()  #####
' #################################
'
FUNCTION  GetSysFolderIcon (@hIconFolder, @iIconFolder, @hIconFolderOpen, @iIconFolderOpen)

	SHFILEINFO sfi

'	file$ = "c:\\windows\\"		' this gives the standard folder icons

  sysDir$ = NULL$(256)
  GetSystemDirectoryA (&sysDir$, LEN(sysDir$))
	sysDir$ = CSIZE$(sysDir$)

	hSysImageList = SHGetFileInfoA (&sysDir$, 0, &sfi, SIZE(sfi), $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_SYSICONINDEX)
	hIconFolder = sfi.hIcon
	iIconFolder = sfi.iIcon

	il = SHGetFileInfoA (&sysDir$, 0, &sfi, SIZE(sfi), $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_OPENICON | $$SHGFI_SYSICONINDEX)
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
FUNCTION InitTreeViewImageList (hTreeView)

	SHARED hInst
	SHARED rootImage, driveImage, networkImage, floppyImage
	SHARED cdImage, clsFolderImage, openFolderImage
	SHARED himl

	' get system image list handle
	himl = GetSysImageListHandle ()

	' associate the system imagelist with the treeview control
	SendMessageA (hTreeView, $$TVM_SETIMAGELIST, $$TVSIL_NORMAL, himl)

	' get system folder icon indexes
  GetSysFolderIcon (@hIconFolder, @clsFolderImage, @hIconFolderOpen, @openFolderImage)
	
	' get 'my computer' icon index
	GetMyComputerIcon (@rootImage)

END FUNCTION

FUNCTION InitDriveInfo (hTree)

	SHARED rootImage

	szBuf$ = NULL$(256)
	GetLogicalDriveStringsA (LEN(szBuf$), &szBuf$)
	szTemp$ = NULL$(3)

	hRoot = AddTreeViewItem (hTree, 0, @"My Computer", rootImage, rootImage, $$TVI_FIRST)
	counter = 0
	temp = 0
	
	DO 
		DO WHILE (szBuf${counter} != NULL)   
			szTemp${temp} = szBuf${counter}
			INC counter
			INC temp
		LOOP
		szTemp${temp} = '\0'
		InsertDriveItem (hTree, szTemp$)
		temp = 0
		INC counter

	LOOP WHILE (szBuf${counter} != NULL)

END FUNCTION

FUNCTION InsertDriveItem (hTree, @driveString$)

	SHARED folderItemMask
	SHARED rootImage, driveImage, networkImage, floppyImage
	SHARED cdImage, clsFolderImage, openFolderImage
'	SHARED allFileImage
	SHARED himl

	IFZ hTree THEN RETURN ($$TRUE)
	IFZ driveString$ THEN RETURN 

	root$ = driveString$
	type = GetDriveTypeA (&root$)
	hRootItem = GetRootItem (hTree)
	
	GetSysDriveIcon (@root$, @hIcon, @iIcon)
	
	SELECT CASE (type)
		CASE $$DRIVE_REMOVABLE :
			IFZ floppyImage THEN floppyImage = iIcon
			iImage = floppyImage
		CASE $$DRIVE_FIXED     : 
			IFZ driveImage THEN driveImage = iIcon
			iImage = driveImage
		CASE $$DRIVE_REMOTE    : 
			IFZ networkImage THEN networkImage = iIcon
			iImage = networkImage
		CASE $$DRIVE_CDROM     : 
			IFZ cdImage THEN cdImage = iIcon
			iImage = cdImage
		CASE ELSE              : 
			iImage = iIcon
			IFZ iImage THEN iImage = driveImage
	END SELECT

	hDriveItem = InsertItem (hTree, folderItemMask, @root$, iImage, iImage, 0, $$TVIS_EXPANDED | $$TVIS_EXPANDEDONCE | $$TVIS_SELECTED, 0, hRootItem, $$TVI_SORT)	
	InsertDummyItem (hTree, hDriveItem)
	AddDriveStrings (@root$)

	' This will monitor each drive for any folder/file changes
	' and update the treeview control.
	' LookForChanges() starts a new thread to monitor each drive, see TrackChanges().
	' This is unstable since strings are not currently thread-safe. 
	' Comment out next three lines to prevent auto folder/file changes monitoring.
	SELECT CASE (type)
		CASE $$DRIVE_REMOVABLE, $$DRIVE_FIXED : LookForChanges (hTree, @root$)
	END SELECT

END FUNCTION

FUNCTION InsertItem (hTree, mask, @item$, image, selectedImage, state, stateMask, lParam, hParent, hInsertAfter)

	TV_INSERTSTRUCT tvis
	
	IF IsWindow (hTree) = 0 THEN RETURN

	tvis.hParent 							= hParent
	tvis.hInsertAfter 				= hInsertAfter
	tvis.item.mask 						= mask
	tvis.item.pszText 				= &item$
	tvis.item.iImage 					= image
	tvis.item.iSelectedImage 	= selectedImage
	tvis.item.state 					= state
	tvis.item.stateMask 			= stateMask
	tvis.item.lParam 					= lParam
	RETURN  SendMessageA (hTree, $$TVM_INSERTITEM, 0, &tvis)

END FUNCTION

FUNCTION AddDriveStrings (drive$)

	SHARED driveStrings$[]
	
	IFZ drive$ THEN RETURN ($$TRUE)
	
	upp = UBOUND (driveStrings$[])
	REDIM driveStrings$[upp+1]
	driveStrings$[upp+1] = drive$

END FUNCTION

FUNCTION InsertDummyItem (hTree, hParent)

	TV_INSERTSTRUCT tvis
	TV_ITEM tvi
	
	IFZ hTree THEN RETURN 
	
	DUMMY$ = "AAAAA"  ' all As given so that it will be first item when sorted and will be deleted

	tvi.mask 						= $$TVIF_TEXT
	tvi.pszText 				= &DUMMY$
	tvi.cchTextMax 			= LEN(DUMMY$)

	tvis.hParent 				= hParent
	tvis.hInsertAfter 	= $$TVI_FIRST	
	tvis.item 					= tvi

	RETURN SendMessageA (hTree, $$TVM_INSERTITEM, 0, &tvis)

END FUNCTION

FUNCTION GetRootItem (hTree)

	IFZ hTree THEN RETURN 

	RETURN SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_ROOT, 0)

END FUNCTION

FUNCTION LookForChanges (hTree, @drive$)

	SHARED hUpdateSemph
	STATIC CONTROLDATA cd

	IFZ drive$ THEN RETURN ($$TRUE)
	
	WaitForSingleObject (hUpdateSemph, $$INFINITE)

	cd.drive = drive$
	cd.hTree = hTree

	threadId = 0
	hThread = CreateThread (NULL, 0, &TrackChanges(), &cd, 0, &threadId)
	CloseHandle (hThread)

END FUNCTION

FUNCTION TrackChanges (pParam)

	SHARED hUpdateSemph
	SHARED err
	FILE_NOTIFY_INFORMATION fni
	CONTROLDATA cd

	hDir = NULL
	RtlMoveMemory (&cd, pParam, SIZE(cd))

	strDrive$ = cd.drive
	hTree = cd.hTree

	hDir = CreateFileA (&strDrive$, $$FILE_LIST_DIRECTORY, $$FILE_SHARE_READ | $$FILE_SHARE_WRITE, NULL, $$OPEN_EXISTING, $$FILE_FLAG_BACKUP_SEMANTICS, NULL)

	prevCnt = 0
 	ReleaseSemaphore (hUpdateSemph, 1, &prevCnt)	
	
	IF (hDir == $$INVALID_HANDLE_VALUE) THEN RETURN 

	szBuff$ = NULL$ (1280)
	bytesWritten = 0

	DO
		DIM args[7]
		args[0] = hDir
		args[1] = &szBuff$
		args[2] = SIZE (szBuff$)
		args[3] = 1
		args[4] = $$FILE_NOTIFY_CHANGE_FILE_NAME | $$FILE_NOTIFY_CHANGE_DIR_NAME
		args[5] = &bytesWritten
		args[6] = NULL
		args[7] = NULL
		res = XstCall (@"ReadDirectoryChangesW", @"kernel32.dll", @args[]) 

		IF (!res) THEN 
			err = GetLastError() : PRINT "ReadDirectoryChangesW error:"; err
			EXIT DO 

		ELSE 
			pFileNotify = 0
'PRINT "TrackChanges: bytesWritten="; bytesWritten
			szBuff${bytesWritten} = '\0'

			pFileNotify = &szBuff$
			RtlMoveMemory (&fni, pFileNotify, bytesWritten)

			bFlag = $$TRUE		
			
			DO WHILE (bFlag)

				IF (fni.NextEntryOffset == 0) THEN bFlag = $$FALSE

				fileNameLen = fni.FileNameLength
				pszBuff$ = NULL$(fileNameLen/2 + 1)
				pTemp = &fni.FileName
				nTemp = 0
				nIndex = 0

				DO WHILE nTemp < fileNameLen
					pszBuff${nIndex} = UBYTEAT(pTemp+nTemp)
					nTemp = nTemp + 2
					INC nIndex
				LOOP

'				pszBuff${nIndex} = '\0'
				pszBuff$ = CSIZE$(pszBuff$)

				strTemp$ = pszBuff$
				strTemp$ = (strDrive$ + strTemp$)
'PRINT "strTemp$="; strTemp$
				WaitForSingleObject (hUpdateSemph, $$INFINITE)
'PRINT "fni.Action="; fni.Action
				Update (hTree, strTemp$, fni.Action)
				ReleaseSemaphore (hUpdateSemph, 1, &pPrevCnt)

'				pTempFileNotify = (FILE_NOTIFY_INFORMATION*)
'					  ((PBYTE)pTempFileNotify + pTempFileNotify->NextEntryOffset);
'PRINT "fni.NextEntryOffset="; fni.NextEntryOffset
				pFileNotify = pFileNotify + fni.NextEntryOffset
				bytesWritten = bytesWritten - fni.NextEntryOffset
				RtlMoveMemory (&fni, pFileNotify, bytesWritten)

			LOOP
		END IF 
	LOOP

	CloseHandle (hDir)	


END FUNCTION

FUNCTION Update (hTree, @strCurPath$, action)

	STATIC hRenameOld 
	SHARED folderItemMask
	SHARED clsFolderImage
'	SHARED allFileImage
	SHARED fileFlag
	
	bRetFlag = 1
	nPos = -1
	hItem = NULL

SELECT CASE (action)

	CASE $$FILE_ACTION_ADDED:
		nPos = RINSTR (strCurPath$, "\\")
		IF (nPos == -1) THEN EXIT SELECT
				
		strPath$ = LEFT$ (strCurPath$, nPos)  ' strCurPath.Mid(0,nPos+1)
'PRINT "FILE_ACTION_ADDED: strPath$=", strPath$
		hItem = GetItemFrmPath (hTree, @strPath$)
		strItem$ = MID$ (strCurPath$, nPos+1)   ' strCurPath.Mid(nPos+1)

		IF (hItem) THEN 
			nMask = GetItemState (hTree, hItem, $$TVIS_EXPANDED)
			
			IF (!(nMask & $$TVIS_EXPANDED)) THEN  ' not yet expanded
				DeleteAllItems (hTree, hItem)
				InsertDummyItem (hTree, hItem)
				SetItemState (hTree, hItem, 0, $$TVIS_EXPANDEDONCE)
				EXIT SELECT 
			END IF 
			
			strTemp$ = GetItemText$ (hTree, hItem)
			nPos = INSTR (strCurPath$, ".") 
			IFZ nPos THEN  ' . not found, should be a directroy
				hItemTemp = NULL
				hItemTemp = InsertItem (hTree, folderItemMask, @strItem$, clsFolderImage, clsFolderImage, 0, $$TVIS_EXPANDED | $$TVIS_EXPANDEDONCE | $$TVIS_SELECTED, 0, hItem, $$TVI_SORT)	
				InsertDummyItem (hTree, hItemTemp)
			ELSE 
				IF (fileFlag) THEN 
					GetSysFileIcon (strItem$, @hIcon, @iIcon)
'					AddTreeViewItem (hTree, hItem, @strItem$, allFileImage, allFileImage, $$TVI_SORT)
					AddTreeViewItem (hTree, hItem, @strItem$, iIcon, iIcon, $$TVI_SORT)
				END IF 
			END IF 
		END IF 
		bRetFlag = 1

	CASE $$FILE_ACTION_REMOVED:
'PRINT "FILE_ACTION_REMOVED: "; strCurPath$
		hItem = GetItemFrmPath (hTree, strCurPath$)
		IF (hItem) THEN 
			bRetFlag = 1
			DeleteItem (hTree, hItem)
		END IF 

	CASE $$FILE_ACTION_RENAMED_OLD_NAME:
'PRINT "FILE_ACTION_RENAMED_OLD_NAME: "; strCurPath$ 
		hRenameOld = GetItemFrmPath (hTree, strCurPath$)

	CASE $$FILE_ACTION_RENAMED_NEW_NAME:
'PRINT "FILE_ACTION_RENAMED_NEW_NAME: "; strCurPath$
		nPos = RINSTR(strCurPath$, "\\")
		IF (nPos != -1 && hRenameOld) THEN 
			strTemp$ = MID$(strCurPath$, nPos+1)
			SetItemText (hTree, hRenameOld, strTemp$)
			bRetFlag = 1
		END IF 

	CASE ELSE:

END SELECT

	RETURN bRetFlag

END FUNCTION

FUNCTION SetItemState (hTree, hItem, state, stateMask)

	TV_ITEM tvi
	
	tvi.mask 			 = $$TVIF_STATE
	tvi.hItem      = hItem
	tvi.stateMask  = stateMask
	tvi.state      = state
	
	RETURN SendMessageA (hTree, $$TVM_SETITEM, 0, &tvi) 

END FUNCTION

FUNCTION GetItemFrmPath (hTree, @path$)

	SHARED fileFlag

	IFZ hTree THEN RETURN
	IFZ path$ THEN RETURN

	nFind = INSTR (path$, "\\")
	IF (nFind == -1) THEN RETURN

	hRetItem = 0

	drive$ = LEFT$(path$, nFind)
	hRoot = GetDriveItem (hTree, drive$)    
	IFZ hRoot THEN RETURN

	hRetItem = ExpandPathToItem (hTree, path$, hRoot)

	IF (!IsDirectory (hTree, hRetItem))  THEN ' item is file image
		IF (!fileFlag) THEN RETURN 
	END IF 

	RETURN hRetItem

END FUNCTION

FUNCTION GetItemState (hTree, hItem, stateMask)

	TV_ITEM tvi
	
	IF IsWindow (hTree) = 0 THEN RETURN 
	
	tvi.hItem      = hItem
	tvi.mask 			 = $$TVIF_STATE 
	tvi.stateMask  = stateMask
	tvi.state      = 0
	
	ret = SendMessageA (hTree, $$TVM_GETITEM, 0, &tvi) 
	
	RETURN tvi.state

END FUNCTION

FUNCTION DeleteAllItems (hTree, hParentItem)

	hChildItem = GetChildItem (hTree, hParentItem)

	DO WHILE (hChildItem != NULL)
		hTempItem = hChildItem
		hChildItem = GetNextSiblingItem (hTree, hChildItem)
		DeleteItem (hTree, hTempItem)
	LOOP

END FUNCTION

FUNCTION GetItemText$ (hTree, hItem)

	TV_ITEM	tvi

	tvi.mask = $$TVIF_TEXT
	tvi.hItem = hItem
	text$ = NULL$(256)
	tvi.pszText = &text$
	tvi.cchTextMax = LEN(text$)

	SendMessageA (hTree, $$TVM_GETITEM, 0, &tvi)
	
	RETURN (CSIZE$(text$))

END FUNCTION

FUNCTION DeleteItem (hTree, hItem)

	IFZ hTree THEN RETURN

	RETURN SendMessageA (hTree, $$TVM_DELETEITEM, 0, hItem)

END FUNCTION

FUNCTION SetItemText (hTree, hItem, @text$)

	TV_ITEM tvi
	
	IFZ hTree THEN RETURN 
	IFZ text$ THEN RETURN
	
	tvi.mask 						= $$TVIF_TEXT '| $$TVIF_HANDLE
	tvi.hItem           = hItem
	tvi.pszText 				= &text$
	tvi.cchTextMax 			= LEN(text$)

	RETURN SendMessageA (hTree, $$TVM_SETITEM, 0, &tvi)

END FUNCTION

FUNCTION GetChildItem (hTree, hItem)

	RETURN SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_CHILD	, hItem)

END FUNCTION

FUNCTION GetNextSiblingItem (hTree, hItem)

	RETURN SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_NEXT, hItem)

END FUNCTION

FUNCTION GetDriveItem (hTree, @path$)

	IFZ hTree THEN RETURN
	IFZ path$ THEN RETURN

	nPos = INSTR (path$, "\\")

	IF (nPos == -1) THEN RETURN 

	strDrive$ = LEFT$ (path$, nPos)
	hRootItem = GetRootItem (hTree)
	hDriveItem = GetChildItem (hTree, hRootItem)

	DO WHILE (hDriveItem)
		IF strDrive$ = GetItemText$ (hTree, hDriveItem) THEN 
			RETURN hDriveItem
		END IF 
		hDriveItem = GetNextSiblingItem (hTree, hDriveItem)
	LOOP 

END FUNCTION

FUNCTION ExpandPathToItem (hTree, @path$, hItem)

	IFZ hItem THEN RETURN 
	IFZ hTree THEN RETURN 
	IFZ path$ THEN RETURN 

	hRetItem = 0
	hChildItem = 0

	hChildItem = GetChildItem (hTree, hItem)
	nFind = INSTR (path$, "\\")
	strPath$ =  MID$ (path$, nFind+1) ' extract path excluding the first seperator
	strPath$ = strPath$ + $$PathSlash$
	nFind = INSTR (strPath$, "\\")
	strItem$ = LEFT$(strPath$, nFind-1)

	IFZ strItem$ THEN RETURN hItem

	DO
		strTemp$ = GetItemText$ (hTree, hChildItem)

		IF strItem$ = strTemp$ THEN
			hRetItem = ExpandPathToItem (hTree, strPath$, hChildItem)
		END IF 
		hChildItem = GetNextSiblingItem (hTree, hChildItem)
	LOOP WHILE (hChildItem != 0)
	
	RETURN hRetItem

END FUNCTION

FUNCTION IsDirectory (hTree, hItem)

'	SHARED allFileImage
	SHARED rootImage, driveImage, networkImage, floppyImage
	SHARED cdImage, clsFolderImage, openFolderImage

' Description	: The function returns $$TRUE if the argument item is a folder;
'               returns $$FALSE if the argument item is file

	IF (hItem == GetRootItem (hTree)) THEN RETURN $$FALSE
	
	GetItemImage (hTree, hItem, @nImage, @nSelectedImage)

	SELECT CASE nImage
		CASE rootImage, driveImage, networkImage, floppyImage, cdImage, clsFolderImage, openFolderImage : RETURN ($$TRUE)
		CASE ELSE : RETURN ($$FALSE)
	END SELECT
	  
'	IF (nImage == allFileImage) THEN 
'		RETURN  $$FALSE
'	ELSE 
'		RETURN $$TRUE
'	END IF 

END FUNCTION

FUNCTION GetItemImage (hTree, hItem, @image, @selectedImage)

	TV_ITEM item

	IF IsWindow (hTree) = 0 THEN RETURN 
	
	item.hItem = hItem
	item.mask = $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE
	res = SendMessageA (hTree, $$TVM_GETITEM, 0, &item)
	IF (res) THEN 
		image = item.iImage
		selectedImage = item.iSelectedImage
	END IF 
	RETURN res

END FUNCTION

FUNCTION ExpandTreeView (hTree, hItem, flag)

	RETURN SendMessageA (hTree, $$TVM_EXPAND, flag, hItem)

END FUNCTION

FUNCTION OnItemExpanding (hTree, lParam, @result)

	NM_TREEVIEW nmtv
	SHARED clsFolderImage, openFolderImage
	
	RtlMoveMemory (&nmtv, lParam, SIZE(nmtv))

	strFindCriteria$ = GetItemText$ (hTree, nmtv.itemNew.hItem)
	
	nMask = GetItemState (hTree, nmtv.itemNew.hItem, $$TVIS_EXPANDEDONCE)
	
	IF (!(nMask & $$TVIS_EXPANDEDONCE)) THEN   ' the item is first time expanding

		IF (nmtv.itemNew.hItem != GetRootItem (hTree)) THEN 

			strFindCriteria$ = GetFullPath$ (hTree, strFindCriteria$, nmtv.itemNew.hItem)	
			IF (nmtv.itemNew.hItem != GetRootItem (hTree) || IsDriveItem (hTree, nmtv.itemNew.hItem)) THEN 
				strFindCriteria$ = strFindCriteria$ + $$PATH_SEPERATOR
			END IF 
			strFindCriteria$ = strFindCriteria$ + $$ALL_FILES	

			' get DUMMY child item		
			hItemTemp = GetChildItem (hTree, nmtv.itemNew.hItem)

			BeginWaitCursor ()
			
			bRetVal = FillItem (hTree, strFindCriteria$, nmtv.itemNew.hItem)
			
			IFZ bRetVal THEN 
				result = 1				' return TRUE to prevent item from expanding
				RETURN
			END IF 

			' delete DUMMY item	
			IF (hItemTemp != 0) THEN 
			  DeleteItem (hTree, hItemTemp)
			END IF 

			EndWaitCursor()
			
		END IF 
	END IF 

	IF (IsDriveItem (hTree, nmtv.itemNew.hItem)) THEN 
		result = 0
		RETURN 
	END IF 
	
	IF (nmtv.action == $$TVE_COLLAPSE) THEN 
		  SetItemImage (hTree, nmtv.itemNew.hItem, clsFolderImage, clsFolderImage)
	END IF 
	
	IF (nmtv.action == $$TVE_EXPAND) THEN 
		SetItemImage (hTree, nmtv.itemNew.hItem, openFolderImage, openFolderImage)
	END IF 

	result = 0

END FUNCTION

FUNCTION GetFullPath$ (hTree, strPath$, hItem)

	IF (hItem == GetRootItem (hTree)) THEN RETURN (strPath$)
	
	hParentItem	= GetParentItem (hTree, hItem)
	IF (hParentItem == GetRootItem (hTree)) THEN RETURN (strPath$)

	strParentText$ = GetItemText$ (hTree, hParentItem)
	IF (IsDriveItem (hTree, hParentItem)) THEN 
		strPath$ = (strParentText$ + strPath$)
	ELSE 
		strPath$ = (strParentText$ + $$PATH_SEPERATOR + strPath$)
	END IF 

	strPath$ = GetFullPath$ (hTree, strPath$, hParentItem)		

	RETURN (strPath$)

END FUNCTION

FUNCTION SetItemImage (hTree, hItem, image, selectedImage)

	TV_ITEM item

	IF IsWindow (hTree) = 0 THEN RETURN 
	
	item.hItem = hItem
	item.iImage = image
	item.iSelectedImage = selectedImage
	item.mask = $$TVIF_IMAGE | $$TVIF_SELECTEDIMAGE
	RETURN SendMessageA (hTree, $$TVM_SETITEM, 0, &item)

END FUNCTION

FUNCTION DoWaitCursor (code)
' code: 0 => restore, 1=> begin, -1=> end

	STATIC waitCursorCount, hWaitCursorRestore

	SELECT CASE code
		CASE 0, 1, -1 :
		CASE ELSE : RETURN
	END SELECT

	waitCursorCount = waitCursorCount + code
	
	IF (waitCursorCount > 0) THEN 
		hCurWait = LoadCursorA (0, $$IDC_WAIT)	 
		hCurPrev = SetCursor (hCurWait)
		IF (code > 0 && waitCursorCount == 1) THEN 
			hWaitCursorRestore = hCurPrev
		END IF 
	ELSE
		' turn everything off
		waitCursorCount = 0 
		SetCursor (hWaitCursorRestore)
	END IF 
END FUNCTION

FUNCTION BeginWaitCursor ()

	DoWaitCursor (1)

END FUNCTION

FUNCTION EndWaitCursor ()

	DoWaitCursor (-1)

END FUNCTION

FUNCTION FillItem (hTree, @strFindCriteria$, hPresentItem)

'	SHARED allFileImage
	SHARED clsFolderImage
	SHARED folderItemMask
	FIND data
	SHARED fileFlag
	SHARED strCurFilter$

	nFind = INSTR (strFindCriteria$, "*")

	' Retrieve path before *.fileextension (*.*, *.grb etc.,)
	strPath$ = LEFT$(strFindCriteria$, nFind-1)
	strOrigiPath$ = strPath$

	nFileHandle = _findfirst(&strFindCriteria$, &data)

	IF (nFileHandle == -1) THEN 
		strMsg$ = $$IDS_ERR_DRIVE_READ
		strTitle$ = $$IDS_APP_TITLE
		strTitle$ = strTitle$ + ":-Error in Reading Drive"
		MessageBoxA (0, &strMsg$, &strTitle$, $$MB_OK | $$MB_ICONSTOP)
		_findclose (nFileHandle)		
		RETURN 
	END IF 

	DO
		' if the contents is a folder  
		IF (data.attrib & $$_A_SUBDIR) THEN 

			' Ignore directory with dot "." and ".."
			IF data.name = "." || data.name = ".." THEN GOTO nextfile
			IF data.name = "RECYCLED" THEN GOTO nextfile

			hTempItem = InsertItem (hTree, folderItemMask, data.name, clsFolderImage, clsFolderImage, 0, $$TVIS_EXPANDED | $$TVIS_EXPANDEDONCE | $$TVIS_SELECTED, 0, hPresentItem, $$TVI_SORT)
			
			' Add a dummy item to SUB-DIR; this dummy item will be deleted 
			' later when the item is expanded
			InsertDummyItem (hTree, hTempItem)
		END IF 
nextfile:		
		nTemp = _findnext (nFileHandle, &data)
		
	LOOP WHILE (!nTemp)

	_findclose (nFileHandle)

	IF (!fileFlag) THEN  ' no need to fill files
		RETURN 1
	END IF 

	IFZ strCurFilter$ THEN strCurFilter$ = $$ALL_FILES
	strFindCriteria$ = strOrigiPath$ + strCurFilter$
	nFileHandle = _findfirst (&strFindCriteria$, &data)

	IF (nFileHandle == -1) THEN RETURN 1

	DO

		IF (data.attrib & $$_A_SUBDIR) THEN GOTO next
		
		GetSysFileIcon (data.name, @hIcon, @iIcon)
		AddTreeViewItem (hTree, hPresentItem, data.name, iIcon, iIcon, $$TVI_LAST)
'		AddTreeViewItem (hTree, hPresentItem, data.name, allFileImage, allFileImage, $$TVI_LAST)
next:
		nTemp = _findnext (nFileHandle, &data)
	LOOP WHILE (!nTemp)

	' close the file handle so that the files/directories can be 
	' accessed from elsewhere
	_findclose (nFileHandle)   
	RETURN  1

END FUNCTION

FUNCTION GetParentItem (hTree, hItem)

	RETURN SendMessageA (hTree, $$TVM_GETNEXTITEM, $$TVGN_PARENT, hItem)

END FUNCTION

FUNCTION IsDriveItem (hTree, hItem)

	IF (GetRootItem(hTree) == hItem) THEN RETURN (1)
	
	IF (GetParentItem (hTree, hItem) != GetRootItem (hTree)) THEN 
		RETURN (0) 
	ELSE 
		RETURN (1) 
	END IF 

END FUNCTION

FUNCTION SetFileFlag (hTree, flag)
' flag = 0, files not displayed
' flag = $$TRUE, files are displayed

	SHARED fileFlag
	fileFlag = flag

END FUNCTION

FUNCTION OnKeyDown (hTree, lParam, @result)

	TV_KEYDOWN tvkd
	
	RtlMoveMemory (&tvkd, lParam, SIZE(tvkd))
	IF (tvkd.wVKey == $$VK_F5) THEN UpdateTree (hTree)
	result = 0

END FUNCTION

FUNCTION UpdateTree (hTree)
' When filter extension changes, this function updates the tree

	SHARED strSelectedPath$
	SHARED fileFlag
	
	BeginWaitCursor()
	
	UpdateDriveInfo (hTree)
	hRootItem = GetRootItem (hTree)
	hDriveItem = 0
	hDriveItem = GetDriveItem (hTree, strSelectedPath$)

	IFZ hDriveItem THEN 
		EndWaitCursor ()
		RETURN 
	END IF 

	' collapse other drives
	 OptimizeShowingDrives (hTree, hDriveItem)
		
	IF (!IsValidDir (hTree, hDriveItem)) THEN 
		DeleteAllItems (hTree, hDriveItem)
		InsertDummyItem (hTree, hDriveItem)
		ExpandTreeView (hTree, hDriveItem, $$TVE_COLLAPSE)
		SetItemState (hTree, hDriveItem, 0, $$TVIS_EXPANDEDONCE)
		EndWaitCursor()
		RETURN
	END IF 

	drive$ = GetItemText$ (hTree, hDriveItem) 
	IF (GetDriveTypeA (&drive$) == $$DRIVE_REMOTE) THEN 
		DeleteAllItems (hTree, hDriveItem)
		InsertDummyItem (hTree, hDriveItem)
		ExpandTreeView (hTree, hDriveItem, $$TVE_COLLAPSE)
		SetItemState (hTree, hDriveItem, 0, $$TVIS_EXPANDEDONCE)
		EndWaitCursor ()
		RETURN 
	END IF 

	' delete  file items with old filter
	DeleteFileItems (hTree, hDriveItem)		
		
	' fill file items with present filter		
	IF (fileFlag) THEN FillFileItems (hTree, hDriveItem)
		
	' fill file items in the opened folders
	SetSubDirState (hTree, hDriveItem)

	EndWaitCursor ()

END FUNCTION

FUNCTION IsValidDir (hTree, hItem)

	FIND data

	strText$ = GetItemText$ (hTree, hItem)

	strText$ = GetFullPath$ (hTree, strText$, hItem)

	strText$ = strText$ + "\\"
	strText$ = strText$ + $$ALL_FILES

	nHandle = _findfirst (&strText$, &data)

	IF (nHandle == -1) THEN 
		RETURN (0)
	ELSE 
		_findclose (nHandle)
		RETURN (1)
	END IF 

END FUNCTION

FUNCTION FillFileItems (hTree, hItem)
' The function fills non-specified file items under a given parent item

	SHARED strCurFilter$
	FIND data
'	SHARED allFileImage

	IFZ (GetParentItem (hTree, hItem)) THEN RETURN 

	strFindCriteria$ = GetItemText$ (hTree, hItem)
	strFindCriteria$ = GetFullPath$ (hTree, strFindCriteria$, hItem)	
	
	IF (hItem != GetRootItem (hTree) || IsDriveItem (hTree, hItem)) THEN 
		strFindCriteria$ = strFindCriteria$ + $$PATH_SEPERATOR
	END IF 

	IFZ strCurFilter$ THEN strCurFilter$ = $$ALL_FILES
	strFindCriteria$ = strFindCriteria$ + strCurFilter$
	nFileHandle = _findfirst (&strFindCriteria$, &data)

	IF (nFileHandle == -1) THEN 
		' close the file handle so that the files/directories can be accessed from elsewhere
		_findclose (nFileHandle)
		RETURN 
	END IF 
	
	DO
		IF (data.attrib & $$_A_SUBDIR) THEN ' if the contents is a folder  
			GOTO skipit
		ELSE  ' simple file
			GetSysFileIcon (data.name, @hIcon, @iIcon)
			AddTreeViewItem (hTree, hItem, data.name, iIcon, iIcon, $$TVI_LAST)	
'			AddTreeViewItem (hTree, hItem, data.name, allFileImage, allFileImage, $$TVI_LAST)		
		END IF
skipit:
		nTemp = _findnext (nFileHandle, &data)
	LOOP WHILE (!nTemp)

	' close the file handle so that the files/directories can be accessed from elsewhere
	_findclose (nFileHandle)
	RETURN (1)

END FUNCTION

FUNCTION OptimizeShowingDrives (hTree, driveItem)

	hRootItem = GetRootItem (hTree)

	' collapse other drive items
	hCurDriveItem = GetChildItem (hTree, hRootItem)

	DO WHILE (hCurDriveItem)

		IF (hCurDriveItem != driveItem) THEN 
			ExpandTreeView (hTree, hCurDriveItem, $$TVE_COLLAPSE)
			DeleteAllItems (hTree, hCurDriveItem)
			InsertDummyItem (hTree, hCurDriveItem) 
			SetItemState (hTree, hCurDriveItem, 0, $$TVIS_EXPANDEDONCE)
		END IF 
		
		hCurDriveItem = GetNextSiblingItem (hTree, hCurDriveItem)
	LOOP

END FUNCTION

FUNCTION DeleteFileItems (hTree, hItem)
' The function deletes all file items of a given parent

'	SHARED allFileImage
	SHARED rootImage, driveImage, networkImage, floppyImage
	SHARED cdImage, clsFolderImage, openFolderImage

	hChildItem =  GetChildItem (hTree, hItem)
	
	DO WHILE (hChildItem != 0)

		GetItemImage (hTree, hChildItem, @nImage, @nSelectedImage)

		' Depending upon ICON image we can determine whether it is file or not
		SELECT CASE nImage
			CASE rootImage, driveImage, networkImage, floppyImage, cdImage, clsFolderImage, openFolderImage :
				hChildItem = GetNextSiblingItem (hTree, hChildItem)
			CASE ELSE :
				hTempItem = hChildItem
				hChildItem = GetNextSiblingItem (hTree, hChildItem)
				DeleteItem (hTree, hTempItem) 
		END SELECT
		 
'		IF (nImage == allFileImage) THEN 
'			hTempItem = hChildItem
'			hChildItem = GetNextSiblingItem (hTree, hChildItem)
'			DeleteItem (hTree, hTempItem)
'		ELSE
'			hChildItem = GetNextSiblingItem (hTree, hChildItem)
'		END IF 
	LOOP

END FUNCTION

FUNCTION SetSubDirState (hTree, hItem)

	SHARED openFolderImage, clsFolderImage
	SHARED fileFlag

	hChildItem = GetChildItem (hTree, hItem)

	DO WHILE (hChildItem != 0)

		' if the child is a folder
		IF (IsDirectory (hTree, hChildItem)) THEN 

			GetItemImage (hTree, hChildItem, @nImage, @nSelectedImage)

			IF (nImage == openFolderImage) THEN 	' folder is presently expanded
					
				DeleteFileItems (hTree, hChildItem)

				IF (fileFlag) THEN 
					FillFileItems (hTree, hChildItem)
					SetItemState (hTree, hChildItem, $$TVIS_EXPANDEDONCE, $$TVIS_EXPANDEDONCE)
					ExpandTreeView (hTree, hChildItem, $$TVE_EXPAND)
				END IF 

				' search for sub-sub directories states (expanded or collapsed)
				SetSubDirState (hTree, hChildItem)

			ELSE

				DeleteAllItems (hTree, hChildItem)
				dummy$ = "AAAAA"
				AddTreeViewItem (hTree, hChildItem, @dummy$, clsFolderImage, clsFolderImage, $$TVI_FIRST)
				
				' FORCE IT as if it never expanded
				SetItemState (hTree, hChildItem, 0, $$TVIS_EXPANDEDONCE)
			END IF
		END IF 
				
		hChildItem = GetNextSiblingItem (hTree, hChildItem)
	LOOP

END FUNCTION

FUNCTION UpdateDriveInfo (hTree)

	SHARED driveStrings$[]

	szBuf$ = NULL$(256)
	GetLogicalDriveStringsA (LEN(szBuf$), &szBuf$)
	szTemp$ = NULL$(3)
	temp = 0
	counter = 0
	index = 0

	DO
		DO WHILE (szBuf${counter} != NULL)   
			szTemp${temp} = szBuf${counter}
			INC counter
			INC temp
		LOOP
		szTemp${temp} = '\0'

		strTemp$ = szTemp$
		REDIM tempDriveStrings$[index]
		tempDriveStrings$[index] = strTemp$
		temp = 0
		INC counter
		INC index
	LOOP WHILE (szBuf${counter} != NULL)
	
	nExistDriveCnt = UBOUND(driveStrings$[]) + 1
	nNewDriveCnt = UBOUND(tempDriveStrings$[]) + 1

	' if some drive is removed/unmapped then update existing list
	FOR nOuter = 0 TO nExistDriveCnt-1 

		strTemp$ = driveStrings$[nOuter]
		FOR nInner = 0 TO nNewDriveCnt-1 
			IF strTemp$ = tempDriveStrings$[nInner] THEN EXIT FOR 
		NEXT nInner

		IF (nInner >= nNewDriveCnt) THEN   ' string not found
			DeleteDriveItem (hTree, strTemp$)
			GOSUB Remove 	
			DEC nOuter
			nExistDriveCnt = UBOUND(driveStrings$[]) + 1
		END IF 
		
	NEXT nOuter

	' If Drive not already there then add it 
	FOR nOuter = 0 TO nNewDriveCnt-1 

		strTemp$ = tempDriveStrings$[nOuter]
		FOR nInner = 0 TO nExistDriveCnt-1 
			IF strTemp$ = driveStrings$[nInner] THEN EXIT FOR
		NEXT nInner
		
		IF (nInner >= nExistDriveCnt) THEN  ' string not found
			InsertDriveItem (hTree, strTemp$)
			GOSUB Add 
			nExistDriveCnt = UBOUND(driveStrings$[]) + 1
		END IF 
	NEXT nOuter

SUB Remove
	upper = UBOUND (driveStrings$[])
	FOR i = nOuter TO upper-1
		driveStrings$[i] = driveStrings$[i+1]
	NEXT i
	REDIM driveStrings$[upper-1]
END SUB

SUB Add
	upp = UBOUND (driveStrings$[])
	REDIM driveStrings$[upp+1]
	driveStrings$[upp+1] = strTemp$
END SUB


END FUNCTION

FUNCTION SetFileFilter (hTree, filter$)

	SHARED strCurFilter$

	IFZ filter$ THEN filter$ = $$ALL_FILES
	strCurFilter$ = filter$

END FUNCTION

FUNCTION GetSelectedPath (hTree, @path$)

' The function assigns the argument with full path of a selected tree item

	SHARED strSelectedPath$
	path$ = strSelectedPath$

END FUNCTION

FUNCTION SetSelectedPath (hTree, path$)

	SHARED strSelectedPath$
	strSelectedPath$ = path$

END FUNCTION

FUNCTION DeleteDriveItem (hTree, driveName$)

	hRootItem = GetRootItem (hTree)
	hDriveItem = GetChildItem (hTree, hRootItem)

	DO WHILE (hDriveItem)

		strTemp$ = GetItemText$ (hTree, hDriveItem)

		IF strTemp$ = driveName$ THEN   				' drive found
			DeleteItem (hTree, hDriveItem)
			EXIT DO
		END IF 

		hDriveItem = GetNextSiblingItem (hTree, hDriveItem)
	LOOP

END FUNCTION

FUNCTION  GetSysFileIcon (file$, @hIcon, @iIcon)

	SHFILEINFO sfi
	
	x = RINSTR(file$, ".")
	IFZ x THEN file$ = "blah.log"
	
	hSysImageList = SHGetFileInfoA (&file$, $$FILE_ATTRIBUTE_NORMAL, &sfi, $$SIZE_SFI, $$SYSFILEATTR)
	hIcon = sfi.hIcon
	iIcon = sfi.iIcon

	RETURN hSysImageList

END FUNCTION

FUNCTION  GetSysDriveIcon (drive$, @hIcon, @iIcon)

	SHFILEINFO sfi
	
	hSysImageList = SHGetFileInfoA (&drive$, 0, &sfi, SIZE(sfi), $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_SYSICONINDEX)
	hIcon = sfi.hIcon
	iIcon = sfi.iIcon

	RETURN hSysImageList

END FUNCTION

FUNCTION GetSysImageListHandle ()

  SHFILEINFO sfi

  flags = $$SHGFI_USEFILEATTRIBUTES | $$SHGFI_SYSICONINDEX | $$SHGFI_SMALLICON

  himl = SHGetFileInfoA (&".txt", $$FILE_ATTRIBUTE_NORMAL, &sfi, SIZE(sfi), flags)

  RETURN himl

END FUNCTION

FUNCTION GetMyComputerIcon (@iIcon)

	SHFILEINFO sfi
	
	$CSIDL_DRIVES = 0x0011

	SHGetSpecialFolderLocation (0, $CSIDL_DRIVES, &pidl)
	hSysImageList = SHGetFileInfoA (pidl, 0, &sfi, SIZE(sfi), $$SHGFI_PIDL | $$SHGFI_SMALLICON | $$SHGFI_SYSICONINDEX)
	iIcon = sfi.iIcon

	RETURN hSysImageList

END FUNCTION
'
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline, angle#)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underlined
	lf.escapement = angle# * 10									' set text rotation
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

END FUNCTION
'
'
' ###########################
' #####  SetNewFont ()  #####
' ###########################
'
FUNCTION  SetNewFont (hwndCtl, hFont)

	SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION

END PROGRAM
