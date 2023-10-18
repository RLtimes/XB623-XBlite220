' 
' 
' ####################
' #####  PROLOG  #####
' ####################
' 
' dropbutton.dll is a dropbutton control which
' acts similar to a pull-down button in a toolbar.
' A right click on the control will display a 
' popup menu from which a selection can be made.
' The selected item is displayed in the button.
' 
PROGRAM "dropbutton"
VERSION "0.0001"
' 
IMPORT "xst"					' standard library	: required by most programs
' IMPORT  "xsx"				' extended std library
' IMPORT	"xio"				' console io library
IMPORT "gdi32"				' gdi32.dll
IMPORT "user32"				' user32.dll
IMPORT "kernel32"			' kernel32.dll
IMPORT "comctl32"			' comctl32.dll			: common controls library
' IMPORT	"comdlg32"  ' comdlg32.dll	    : common dialog library
' IMPORT	"xma"   		' math library			: Sin/Asin/Sinh/Asinh/Log/Exp/Sqrt...
' IMPORT	"xcm"				' complex math library
IMPORT  "msvcrt"		' msvcrt.dll				: C function library
' IMPORT  "shell32"   ' shell32.dll
' 
EXPORT
'
TYPE DBLOCALINFO
	XLONG .hmenu
	XLONG .hhook
	XLONG .iTimeOut
	XLONG .iCurrentItem
	XLONG .iItemCount
	XLONG .fIgnoreSetState
END TYPE
'
TYPE DROPBUTITEM
	XLONG .iCode				' button identifier id
	XLONG .szLabel			' address of label string
	XLONG .iBufSize
END TYPE
'
DECLARE FUNCTION DropButton ()
DECLARE FUNCTION InitDropButtonControl ()
'
END EXPORT
'
DECLARE FUNCTION OLDWNDPROC (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION GetButtonExData (hwnd, DBLOCALINFO dbli)
DECLARE FUNCTION SetButtonExData (hwnd, DBLOCALINFO dbli)
DECLARE FUNCTION DropButtonProc_BM_SETSTATE (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_WM_RBUTTONDOWN (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_WM_COMMAND (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_WM_EXITMENULOOP (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_WM_CREATE (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_WM_DESTROY (hwnd, iMsg, wParam, lParam)
'
DECLARE FUNCTION DropButtonProc_DBM_APPENDITEM (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_INSERTITEM (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_REMOVEITEM (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_FINDITEM (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_CLEAR (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_SETITEMTEXT (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_SETITEMID (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_GETCOUNT (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_GETCURSEL (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DropButtonProc_DBM_GETITEMTEXT (hwnd, iMsg, wParam, lParam)
'
' owner-drawn functions
DECLARE FUNCTION InitConstants ()
DECLARE FUNCTION DrawLine (hdc, left, top, right, bottom, style, width, color)
DECLARE FUNCTION DrawFrame (hdc, RECT r, state)
DECLARE FUNCTION DrawFilledRect (hdc, RECT r, color)
DECLARE FUNCTION DrawButtonText (hdc, RECT r, text$, textColor, style)
DECLARE FUNCTION DrawButton (lpDrawItemStruct)
DECLARE FUNCTION ParentSubProc (hwnd, iMsg, wParam, lParam)
DECLARE FUNCTION DrawWidget (hdc, RECT rect, state)
'
EXPORT
'
' canvas control class name
$$DROPBUTTONCLASSNAME = "dropbutton"
$$DBWC_DROPBUTTON = "dropbutton"
'
$$DBDEF_MENUTIMEOUT = 500
'
' messages
$$DBM_APPENDITEM = 1025		' add an item to the end of the list of available items
$$DBM_INSERTITEM = 1026		' add an item at a specific index within the list of available items
$$DBM_REMOVEITEM = 1027		' remove an item from the list of available items given it's code id
$$DBM_FINDITEM = 1028			' find the first item based on the text
$$DBM_CLEAR = 1034				' remove all items from the list of available items
$$DBM_SETITEMTEXT = 1035	' set the label for an item
$$DBM_GETITEMTEXT = 1036	' get the label of an item
$$DBM_SETITEMID = 1037		' set the label of an item
$$DBM_GETCOUNT = 1044			' return count of items in list menu
$$DBM_SETCURSEL = 1074		' set current selection
$$DBM_GETCURSEL = 1075		' get current selection
'
END EXPORT

$$BUTTON_IN = 0x01
$$BUTTON_OUT = 0x02
$$BUTTON_BLACK_BORDER = 0x04

$$CLR_BTN_WHITE  = 16777215  ' RGB(255, 255, 255)
$$CLR_BTN_BLACK  = 0         ' GB(0, 0, 0)
$$CLR_BTN_DGREY  = 8421504   ' RGB(128, 128, 128)
$$CLR_BTN_GREY   = 12632256  ' RGB(192, 192, 192)
$$CLR_BTN_LGREY  = 14671839  ' RGB(223, 223, 223)

FUNCTION DropButton ()

	STATIC entry

	IF entry THEN RETURN					' enter once
	entry = $$TRUE								' enter occured
	InitConstants ()							' initialize constants
	InitDropButtonControl ()			' register control class name

END FUNCTION

FUNCTION OLDWNDPROC (hwnd, iMsg, wParam, lParam)

	SHARED lpfnButtonProc

	RETURN CallWindowProcA (lpfnButtonProc, hwnd, iMsg, wParam, lParam)
END FUNCTION


FUNCTION DropButtonProc (hwnd, iMsg, wParam, lParam)

	SELECT CASE (iMsg)

		CASE ($$BM_SETSTATE) 			: RETURN (DropButtonProc_BM_SETSTATE (hwnd, iMsg, wParam, lParam))
		CASE ($$WM_RBUTTONDOWN) 	: RETURN (DropButtonProc_WM_RBUTTONDOWN (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_SETCURSEL) 		:	RETURN (DropButtonProc_WM_COMMAND (hwnd, iMsg, wParam, lParam))
		CASE ($$WM_COMMAND) 			: RETURN (DropButtonProc_WM_COMMAND (hwnd, iMsg, wParam, lParam))
		CASE ($$WM_EXITMENULOOP) 	: RETURN (DropButtonProc_WM_EXITMENULOOP (hwnd, iMsg, wParam, lParam))
		CASE ($$WM_CREATE) 				: RETURN (DropButtonProc_WM_CREATE (hwnd, iMsg, wParam, lParam))
		CASE ($$WM_DESTROY) 			: RETURN (DropButtonProc_WM_DESTROY (hwnd, iMsg, wParam, lParam))

		CASE ($$DBM_APPENDITEM) : RETURN (DropButtonProc_DBM_APPENDITEM (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_INSERTITEM) : RETURN (DropButtonProc_DBM_INSERTITEM (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_REMOVEITEM) : RETURN (DropButtonProc_DBM_REMOVEITEM (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_FINDITEM) 	: RETURN (DropButtonProc_DBM_FINDITEM (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_CLEAR) 			: RETURN (DropButtonProc_DBM_CLEAR (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_SETITEMTEXT): RETURN (DropButtonProc_DBM_SETITEMTEXT (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_GETITEMTEXT): RETURN (DropButtonProc_DBM_GETITEMTEXT (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_SETITEMID) 	: RETURN (DropButtonProc_DBM_SETITEMID (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_GETCOUNT) 	: RETURN (DropButtonProc_DBM_GETCOUNT (hwnd, iMsg, wParam, lParam))
		CASE ($$DBM_GETCURSEL) 	: RETURN (DropButtonProc_DBM_GETCURSEL (hwnd, iMsg, wParam, lParam))

	END SELECT

	RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))
END FUNCTION


FUNCTION DropButtonProc_BM_SETSTATE (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	RECT rect
	SHARED localInfoIndex

	' get the local information
	lpdbli = GetButtonExData (hwnd, @dbli)

	' if the menu is just show, it tends to reset the state - prevent this here
	IF ((lpdbli <> NULL) && (dbli.fIgnoreSetState <> 0)) THEN
		dbli.fIgnoreSetState = 0
		SetButtonExData (hwnd, @dbli)
		RETURN (0)
	END IF

	RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))
END FUNCTION


FUNCTION DropButtonProc_WM_RBUTTONDOWN (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	RECT rect

	' prevent the button state from being changed

	lpdbli = GetButtonExData (hwnd, @dbli)

	IF ((lpdbli <> NULL) && (dbli.hmenu <> NULL)) THEN
		dbli.fIgnoreSetState = 1
		' display the menu at the appropriate location
		GetWindowRect (hwnd, &rect)
		TrackPopupMenu (dbli.hmenu, $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, rect.left, rect.bottom, 0, hwnd, NULL)
		SetButtonExData (hwnd, @dbli)
	END IF

	RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))

END FUNCTION


FUNCTION DropButtonProc_WM_COMMAND (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	MENUITEMINFO mii
	RECT rect
	NMHDR nmhdr

	iNewItem = LOWORD (wParam)

	' get the local information
	lpdbli = GetButtonExData (hwnd, @dbli)

	IF (lpdbli == NULL) THEN
		RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))
	END IF

	' check if the user selected the already selected item
	IF (iNewItem == dbli.iCurrentItem) THEN
		RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))
	END IF

	' get the handle to the menu
	hmenu = dbli.hmenu
	IF (hmenu == NULL) THEN
		RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))
	END IF

	' clear the previous item
	CheckMenuItem (hmenu, dbli.iCurrentItem, $$MF_BYCOMMAND | $$MF_UNCHECKED)
	CheckMenuItem (hmenu, iNewItem, $$MF_BYCOMMAND | $$MF_CHECKED)

	' and set the text to the new item
	' first get the length of the string of the text
	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_DATA
	GetMenuItemInfoA (hmenu, iNewItem, $$FALSE, &mii)

	sz$ = NULL$ (mii.dwItemData)

	IF (&sz$ <> NULL) THEN
		' mii.cbSize still set
		mii.fMask = $$MIIM_TYPE
		mii.dwTypeData = &sz$
		mii.cch = mii.dwItemData
		GetMenuItemInfoA (hmenu, iNewItem, $$FALSE, &mii)
		SetWindowTextA (hwnd, mii.dwTypeData)
	END IF

	dbli.iCurrentItem = iNewItem
	SetButtonExData (hwnd, @dbli)

	hwndParent = GetWindowLongA (hwnd, $$GWL_HWNDPARENT)
	IF (hwndParent <> NULL) THEN
		iControlID = GetWindowLongA (hwnd, $$GWL_ID)
		nmhdr.hwndFrom = hwnd
		nmhdr.idFrom = iControlID
		nmhdr.code = iNewItem
		SendMessageA (hwndParent, $$WM_NOTIFY, iControlID, &nmhdr)
		
		wP = MAKELONG (iNewItem, 0)
		lP = hwnd
		SendMessageA (hwndParent, $$WM_COMMAND, wP, lP)
	END IF
	
	RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))
END FUNCTION


FUNCTION DropButtonProc_WM_EXITMENULOOP (hwnd, iMsg, wParam, lParam)

	SendMessageA (hwnd, $$BM_SETSTATE, $$FALSE, 0)
	RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))
END FUNCTION


FUNCTION DropButtonProc_WM_CREATE (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	DROPBUTITEM dbi
	SHARED localInfoIndex
	
	' change button style to owner-drawn
	style = $$BS_OWNERDRAW | $$WS_CHILD | $$WS_VISIBLE | $$WS_TABSTOP	 
	SetWindowLongA (hwnd, $$GWL_STYLE, style)	
	
	hmenu = CreatePopupMenu ()

	' allocate the local information
	lpdbli = malloc (SIZE (dbli))

	IF (lpdbli == NULL) THEN
		RETURN (-1)
	END IF

	' create an empty menu
	dbli.hmenu = hmenu
	dbli.hhook = NULL
	dbli.iTimeOut = $$DBDEF_MENUTIMEOUT
	dbli.iCurrentItem = -1
	dbli.iItemCount = 0

	' store it in the window
	SetWindowLongA (hwnd, localInfoIndex, lpdbli)
	SetButtonExData (hwnd, @dbli)
	
	' check if the user specified a label and add it as the first item with command 0
	i = GetWindowTextLengthA (hwnd)

	IF (i <> 0) THEN
		sz$ = NULL$ (i + 1)
		IF (&sz$ <> NULL) THEN
			IF (GetWindowTextA (hwnd, &sz$, i + 1)) THEN
				' get the id off the current window
				dbi.iCode = GetDlgCtrlID (hwnd)
				dbi.szLabel = &sz$
				DropButtonProc_DBM_INSERTITEM (hwnd, iMsg, 0, &dbi)
				CheckMenuItem (hmenu, dbi.iCode, $$MF_BYCOMMAND | $$MF_CHECKED)
				dbli.iCurrentItem = dbi.iCode
				dbli.iItemCount = 1
				SetButtonExData (hwnd, @dbli)
			END IF
		END IF
	END IF
	
	' subclass parent proc to catch WM_DRAWITEM messages
	hWndParent = GetParent (hwnd)
	oldParentProc = SetWindowLongA (hWndParent, $$GWL_WNDPROC, &ParentSubProc())
	
	' save old parent proc address
	IFZ GetPropA (hWndParent, &"oldParentProc") THEN
		SetPropA (hWndParent, &"oldParentProc", oldParentProc)
	END IF
	
	' get count of dropbutton controls
	count = GetPropA (hWndParent, &"count")
	INC count
	
	' save hwnd of control and count
	hwnd$ = "hwnd" + STRING$(count)
	SetPropA (hWndParent, &hwnd$, hwnd)
	SetPropA (hWndParent, &"count", count) 

	RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))
END FUNCTION

FUNCTION ParentSubProc (hwnd, iMsg, wParam, lParam)

	SELECT CASE iMsg
		CASE $$WM_DRAWITEM :
			ok = 0
			idCtl = wParam
			
			' get handle of control
			hCtl = GetDlgItem (hwnd, idCtl)

			' get count of dropbox controls
			count = GetPropA (hwnd, &"count")

			' see if message is for one of the dropbox controls
			FOR i = 1 TO count
				hwnd$ = "hwnd" + STRING$(i)
				h = GetPropA (hwnd, &hwnd$)
				' draw button control
				IF h = hCtl THEN 
					DrawButton (lParam)
					EXIT FOR
				END IF
			NEXT i
	END SELECT
	
	oldParentProc = GetPropA (hwnd, &"oldParentProc") 
	
	RETURN CallWindowProcA (oldParentProc, hwnd, iMsg, wParam, lParam)  
END FUNCTION


FUNCTION DropButtonProc_WM_DESTROY (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli

	' release the menu
	lpdbli = GetButtonExData (hwnd, @dbli)
	
	IF (lpdbli <> NULL) THEN
		DestroyMenu (dbli.hmenu)
	END IF

	' release the local info
	free (lpdbli)

	RETURN (OLDWNDPROC (hwnd, iMsg, wParam, lParam))

END FUNCTION


' handlers of the custom messages
FUNCTION DropButtonProc_DBM_APPENDITEM (hwnd, iMsg, wParam, lParam)

	RETURN (DropButtonProc_DBM_INSERTITEM (hwnd, iMsg, -1, lParam))
END FUNCTION

FUNCTION DropButtonProc_DBM_INSERTITEM (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	MENUITEMINFO mii
	DROPBUTITEM dbi

	' get the parameters from the lParams

	lpdbi = lParam
	IF (!lpdbi) THEN
		RETURN (1)
	END IF
	RtlMoveMemory (&dbi, lpdbi, SIZE (dbi))

	iPosition = wParam

	' get the local information
	lpdbli = GetButtonExData (hwnd, @dbli)

	IF (!lpdbli) THEN
		RETURN (1)
	END IF

	' get the handle to the menu
	hmenu = dbli.hmenu
	IF (!hmenu) THEN
		RETURN (1)
	END IF

	' create regular menuitem
	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_ID | $$MIIM_TYPE | $$MIIM_DATA
	mii.fType = $$MFT_STRING
	mii.wID = dbi.iCode
	s$ = CSTRING$ (dbi.szLabel)
	length = LEN (s$)
	mii.dwItemData = (length + 1)		'use this to store the length of the string
	mii.dwTypeData = dbi.szLabel

	IF (!InsertMenuItemA (hmenu, iPosition, $$FALSE, &mii)) THEN
		RETURN (1)
	END IF

	IF (!dbli.iItemCount) THEN
		dbli.iCurrentItem = dbi.iCode
		CheckMenuItem (hmenu, dbi.iCode, $$MF_BYCOMMAND | $$MF_CHECKED)
		SetWindowTextA (hwnd, dbi.szLabel)
	END IF

	dbli.iItemCount = dbli.iItemCount + 1
	SetButtonExData (hwnd, @dbli)

	RETURN (0)
END FUNCTION


FUNCTION DropButtonProc_DBM_REMOVEITEM (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	MENUITEMINFO mii
	RECT rect

	uID = wParam

	' get the local information
	lpdbli = GetButtonExData (hwnd, @dbli)

	IF (lpdbli == NULL) THEN
		RETURN (1)
	END IF

	IF (dbli.iItemCount == 0) THEN
		RETURN (1)
	END IF

	' get the handle to the menu
	hmenu = dbli.hmenu
	IF (hmenu == NULL) THEN
		RETURN (1)
	END IF

	IF (DeleteMenu (hmenu, uID, $$MF_BYCOMMAND) == 0) THEN
		RETURN (1)
	END IF

	dbli.iItemCount = dbli.iItemCount - 1

	IF ((dbli.iItemCount <> 0) && (dbli.iCurrentItem == uID)) THEN
		' the removed item was the current item
		mii.cbSize = SIZE (mii)
		mii.fMask = $$MIIM_DATA | $$MIIM_ID
		GetMenuItemInfoA (hmenu, 0, $$TRUE, &mii)

		dbli.iCurrentItem = mii.wID

		sz$ = NULL$ (mii.dwItemData)
		IF (&sz$ <> NULL) THEN
			' mii.cbSize still set
			mii.fMask = $$MIIM_TYPE
			mii.dwTypeData = &sz$
			mii.cch = mii.dwItemData

			GetMenuItemInfoA (hmenu, 0, $$TRUE, &mii)
			SetWindowTextA (hwnd, mii.dwTypeData)
		ELSE
			text$ = ""
			SetWindowTextA (hwnd, &text$)
		END IF

		CheckMenuItem (hmenu, 0, $$MF_BYPOSITION | $$MF_CHECKED)
		SetButtonExData (hwnd, @dbli)
	END IF

END FUNCTION

FUNCTION DropButtonProc_DBM_GETITEMTEXT (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO	dbli

	lpdbli = GetButtonExData (hwnd, @dbli)
	IFZ lpdbli THEN RETURN (-1)

	hmenu = dbli.hmenu
	IFZ hmenu THEN RETURN (-1)
	
	' wParam is item id
	
	idItem = wParam
	
	' lParam is pointer to buffer string
	IFZ lParam THEN RETURN (-1)

	maxCount = GetMenuStringA (hmenu, idItem, lParam, 0, $$MF_BYCOMMAND) 
	RETURN GetMenuStringA (hmenu, idItem, lParam, maxCount+1, $$MF_BYCOMMAND)
	
END FUNCTION


FUNCTION DropButtonProc_DBM_FINDITEM (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO	dbli

	lpdbli = GetButtonExData (hwnd, @dbli)
	IFZ lpdbli THEN RETURN (-1)

	hmenu = dbli.hmenu
	IFZ hmenu THEN RETURN (-1)
	
	' lParam contain pointer to find$
	IFZ lParam THEN RETURN (-1)
	find$ = CSTRING$(lParam)
	IFZ find$ THEN RETURN (-1)
	
	count = SendMessageA (hwnd, $$DBM_GETCOUNT, 0, 0)
	
	IFZ count THEN RETURN (-1)
	
	FOR i = 0 TO count-1
		s$ = NULL$(255)
		maxCount = GetMenuStringA (hmenu, i, &s$, 0, $$MF_BYPOSITION) 
	  GetMenuStringA (hmenu, i, &s$, maxCount+1, $$MF_BYPOSITION)
		s$ = CSIZE$(s$)
		IF s$ = find$ THEN RETURN GetMenuItemID (hmenu, i) 
	NEXT i
	
END FUNCTION


FUNCTION DropButtonProc_DBM_CLEAR (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	RECT rect

	lpdbli = GetButtonExData (hwnd, @dbli)

	IF (lpdbli == NULL) THEN
		RETURN (1)
	END IF

	hmenu = dbli.hmenu
	IF (hmenu == NULL) THEN
		RETURN (1)
	END IF

	' empty the menu
	FOR i = dbli.iItemCount TO 1 STEP -1	

		IF (DeleteMenu (hmenu, 0, $$MF_BYPOSITION) == 0) THEN
			RETURN (1)
		END IF
	NEXT i

	dbli.iCurrentItem = 0
	dbli.iItemCount = 0

	text$ = ""
	SetWindowTextA (hwnd, &text$)
	SetButtonExData (hwnd, @dbli)

	RETURN (0)
END FUNCTION


FUNCTION DropButtonProc_DBM_SETITEMTEXT (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	MENUITEMINFO mii
	RECT rect

	lpdbli = GetButtonExData (hwnd, @dbli)

	IF (lpdbli == NULL) THEN
		RETURN (1)
	END IF

	hmenu = dbli.hmenu
	IF (hmenu == NULL) THEN
		RETURN (1)
	END IF

	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_TYPE
	mii.fType = $$MFT_STRING
	mii.dwTypeData = lParam
	SetMenuItemInfoA (hmenu, wParam, $$MF_BYCOMMAND, &mii)
	IF (dbli.iCurrentItem == wParam) THEN
		SetWindowTextA (hwnd, lParam)
	END IF

	RETURN (0)
END FUNCTION

FUNCTION DropButtonProc_DBM_SETITEMID (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli
	MENUITEMINFO mii

	lpdbli = GetButtonExData (hwnd, @dbli)

	IF (lpdbli == NULL) THEN
		RETURN (1)
	END IF

	hmenu = dbli.hmenu
	IF (hmenu == NULL) THEN
		RETURN (1)
	END IF

	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_ID
	mii.wID = lParam
	SetMenuItemInfoA (hmenu, wParam, $$MF_BYCOMMAND, &mii)
	IF (dbli.iCurrentItem == wParam) THEN
		dbli.iCurrentItem = lParam
		SetButtonExData (hwnd, @dbli)
	END IF

	RETURN (0)
END FUNCTION


FUNCTION DropButtonProc_DBM_GETCOUNT (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli

	lpdbli = GetButtonExData (hwnd, @dbli)

	IF (lpdbli == NULL) THEN
		RETURN (-1)
	END IF

	RETURN (dbli.iItemCount)
END FUNCTION


FUNCTION DropButtonProc_DBM_GETCURSEL (hwnd, iMsg, wParam, lParam)

	DBLOCALINFO dbli

	lpdbli = GetButtonExData (hwnd, @dbli)

	IF (lpdbli == NULL) THEN
		RETURN (-1)
	END IF

	RETURN (dbli.iCurrentItem)
END FUNCTION


FUNCTION DrawWidget (hdc, RECT rect, state)

	hfont = CreateFontA (-MulDiv (10, GetDeviceCaps (hdc, $$LOGPIXELSY), 72), 0, 0, 0, 0, 0, 0, 0, $$DEFAULT_CHARSET, $$OUT_DEFAULT_PRECIS, $$CLIP_DEFAULT_PRECIS, $$DEFAULT_QUALITY, $$DEFAULT_PITCH | $$FF_DONTCARE, &"Marlett")
	hfontOrg = SelectObject (hdc, hfont)
	SetBkMode (hdc, $$TRANSPARENT)

	IF state & $$BUTTON_IN THEN
		rect.left = rect.left + 2
		rect.top = rect.top + 2
	END IF

	DrawTextA (hdc, &"6", 1, &rect, $$DT_CENTER | $$DT_VCENTER | $$DT_SINGLELINE)

	SetBkMode (hdc, $$OPAQUE)
	SelectObject (hdc, hfontOrg)
	DeleteObject (hfont)

	ReleaseDC (hwnd, hdc)

END FUNCTION


FUNCTION InitDropButtonControl ()

	WNDCLASSEX wndclassex
	SHARED localInfoIndex
	SHARED lpfnButtonProc
	
	' get the address of the button wndproc
	' errors are gracefully ignored
	wndclassex.cbSize = SIZE (wndclassex)
	GetClassInfoExA (NULL, &"button", &wndclassex)
	lpfnButtonProc = wndclassex.lpfnWndProc
	localInfoIndex = wndclassex.cbWndExtra

	' update the old struct - cbSize is required
	wndclassex.cbSize = SIZE (wndclassex)
	wndclassex.lpfnWndProc = &DropButtonProc ()
	wndclassex.cbClsExtra = 0
	wndclassex.cbWndExtra = wndclassex.cbWndExtra + SIZE (DBLOCALINFO)
	wndclassex.hInstance = NULL
	wndclassex.lpszMenuName = NULL
	wndclassex.lpszClassName = &$$DROPBUTTONCLASSNAME

	' register the new class
	RETURN RegisterClassExA (&wndclassex)

END FUNCTION

FUNCTION GetButtonExData (hwnd, DBLOCALINFO dbli)

	SHARED localInfoIndex

	lpdbli = GetWindowLongA (hwnd, localInfoIndex)
	IF lpdbli THEN RtlMoveMemory (&dbli, lpdbli, SIZE (dbli))
	RETURN lpdbli

END FUNCTION

FUNCTION SetButtonExData (hwnd, DBLOCALINFO dbli)

	SHARED localInfoIndex

	lpdbli = GetWindowLongA (hwnd, localInfoIndex)
	IF lpdbli THEN RtlMoveMemory (lpdbli, &dbli, SIZE (dbli))
	RETURN lpdbli

END FUNCTION

FUNCTION InitConstants ()

SHARED text_colour, background_colour
SHARED disabled_background_colour
SHARED light, highlight
SHARED shadow, dark_shadow 

text_colour 			= GetSysColor ($$COLOR_BTNTEXT)
background_colour = GetSysColor ($$COLOR_BTNFACE)
disabled_background_colour = background_colour
light 						= GetSysColor ($$COLOR_3DLIGHT)
highlight 				= GetSysColor ($$COLOR_BTNHIGHLIGHT)
shadow 						= GetSysColor ($$COLOR_BTNSHADOW)
dark_shadow 			= GetSysColor ($$COLOR_3DDKSHADOW) 

END FUNCTION

FUNCTION DrawLine (hdc, left, top, right, bottom, style, width, color)

  newPen = NULL
  HoldPen = NULL
	
	IFZ width THEN width = 1

  newPen = CreatePen (style, width, color)
	IFZ newPen THEN RETURN ($$TRUE)

  IF newPen THEN
    oldPen = SelectObject (hdc, newPen)
	END IF

  MoveToEx (hdc, left, top, NULL)
  LineTo (hdc, right, bottom)

  IF oldPen THEN 
    SelectObject (hdc, oldPen)
    oldPen = NULL
	END IF

  DeleteObject (newPen)

END FUNCTION

FUNCTION DrawFrame (hdc, RECT r, state)

	SHARED light, highlight
	SHARED shadow, dark_shadow

	' IF (state & BUTTON_BLACK_BORDER) THEN
	' 	color = $$CLR_BTN_BLACK
	' 	DrawLine (hdc, r.left, r.top, r.right, r.top, $$PS_SOLID, 1, color) ' Across top
	' 	DrawLine (hdc, r.left, r.top, r.left,  r.bottom, $$PS_SOLID, 1, color) ' Down left
	' 	DrawLine (hdc, r.left, r.bottom - 1, r.right, r.bottom - 1, $$PS_SOLID, 1, color) ' Across bottom
	' 	DrawLine (hdc, r.right - 1, r.top, r.right - 1, r.bottom, $$PS_SOLID, 1, color) ' Down right
	' 	InflateRect (&r, -1, -1)
	' END IF

	IF (state & $$BUTTON_OUT) THEN
		color = highlight
		DrawLine (hdc, r.left, r.top, r.right, r.top, $$PS_SOLID, 1, color)		' Across top
		DrawLine (hdc, r.left, r.top, r.left, r.bottom, $$PS_SOLID, 1, color)		' Down left
		
		color = dark_shadow
		DrawLine (hdc, r.left, r.bottom - 1, r.right, r.bottom - 1, $$PS_SOLID, 1, color)		' Across bottom
		DrawLine (hdc, r.right - 1, r.top, r.right - 1, r.bottom, $$PS_SOLID, 1, color)		' Down right

		InflateRect (&r, -1, -1)

		' color = dark_shadow
		' DrawLine (hdc, r.left, r.top, r.right, r.top, $$PS_SOLID, 1, color) ' Across top
		' DrawLine (hdc, r.left, r.top, r.left,  r.bottom, $$PS_SOLID, 1, color) ' Down left

		color = shadow
		DrawLine (hdc, r.left, r.bottom - 1, r.right + 1, r.bottom - 1, $$PS_SOLID, 1, color)		' Across bottom
		DrawLine (hdc, r.right - 1, r.top, r.right - 1, r.bottom, $$PS_SOLID, 1, color)		' Down right
	END IF

	IF (state & $$BUTTON_IN) THEN

		color = dark_shadow
		DrawLine (hdc, r.left, r.top, r.right - 1, r.top, $$PS_SOLID, 1, color)		' Across top
		DrawLine (hdc, r.left, r.top, r.left, r.bottom, $$PS_SOLID, 1, color)		' Down left
		DrawLine (hdc, r.left, r.top + 1, r.right, r.top + 1, $$PS_SOLID, 1, color)		' Across top
		DrawLine (hdc, r.left + 1, r.top, r.left + 1, r.bottom, $$PS_SOLID, 1, color)		' Down left
		' DrawLine (hdc, r.left, r.bottom - 1, r.right, r.bottom - 1, $$PS_SOLID, 1, color) ' Across bottom
		' DrawLine (hdc, r.right - 1, r.top, r.right - 1, r.bottom, $$PS_SOLID, 1, color) ' Down right
		
		InflateRect (&r, - 1, - 1)
		color = highlight
		' DrawLine (hdc, r.left, r.top, r.right, r.top, $$PS_SOLID, 1, color) ' Across top
		' DrawLine (hdc, r.left, r.top, r.left,  r.bottom, $$PS_SOLID, 1, color) ' Down left
		DrawLine (hdc, r.left, r.bottom, r.right+1, r.bottom, $$PS_SOLID, 1, color)		' Across bottom
		DrawLine (hdc, r.right, r.top, r.right, r.bottom, $$PS_SOLID, 1, color)		' Down right
	END IF

END FUNCTION

FUNCTION DrawFilledRect (hdc, RECT r, color)

  hBrush = CreateSolidBrush (color)
	IFZ hBrush THEN RETURN ($$TRUE)
	FillRect (hdc, &r, hBrush)
	DeleteObject (hBrush)

END FUNCTION

FUNCTION DrawButtonText (hdc, RECT r, text$, textColor, style)

	IFZ text$ THEN RETURN ($$TRUE)
  prevColor = SetTextColor (hdc, textColor)
  SetBkMode (hdc, $$TRANSPARENT)
  DrawTextA (hdc, &text$, LEN(text$), &r, $$DT_CENTER | $$DT_VCENTER | $$DT_SINGLELINE)
  SetTextColor (hdc, prevColor)

END FUNCTION

FUNCTION DrawButton (lpDrawItemStruct)

	SHARED text_colour, background_colour
	SHARED disabled_background_colour

	DRAWITEMSTRUCT dis
	RECT focus_rect, button_rect, text_rect, offset_text_rect
	RECT arrow_rect

	RtlMoveMemory (&dis, lpDrawItemStruct, SIZE (dis))

	hdc = dis.hDC
	state = dis.itemState

	CopyRect (&button_rect, &dis.rcItem)
	
	CopyRect (&arrow_rect, &button_rect)				' set arrow part rect

	button_rect.right = button_rect.right '- 20  ' make button rect less wide
	arrow_rect.left = arrow_rect.right - 20     ' make arrow rect 20 wide
	
	CopyRect (&focus_rect, &button_rect)
	CopyRect (&text_rect, &button_rect)

	OffsetRect (&text_rect, -1, -1)
	CopyRect (&offset_text_rect, &text_rect)
	OffsetRect (&offset_text_rect, 1, 1)

	' Set the focus rectangle to just past the border decoration
	focus_rect.left = focus_rect.left + 4
	focus_rect.right = focus_rect.right - 4
	focus_rect.top = focus_rect.top + 4
	focus_rect.bottom = focus_rect.bottom - 4

	' Retrieve the button's caption
	buffer$ = NULL$ (512)
	GetWindowTextA (dis.hwndItem, &buffer$, LEN (buffer$))
	buffer$ = CSIZE$ (buffer$)

	IF (state & $$ODS_DISABLED) THEN
		DrawFilledRect (hdc, button_rect, disabled_background_colour)
'		DrawFilledRect (hdc, arrow_rect, disabled_background_colour)
	ELSE
		DrawFilledRect (hdc, button_rect, background_colour)
'		DrawFilledRect (hdc, arrow_rect, background_colour)
	END IF

	IF (state & $$ODS_SELECTED) THEN
		DrawFrame (hdc, button_rect, $$BUTTON_IN)
'		DrawFrame (hdc, arrow_rect, $$BUTTON_IN)
	ELSE
		IF ((state & $$ODS_DEFAULT) || (state & $$ODS_FOCUS)) THEN
			DrawFrame (hdc, button_rect, $$BUTTON_OUT | $$BUTTON_BLACK_BORDER)
'			DrawFrame (hdc, arrow_rect, $$BUTTON_OUT | $$BUTTON_BLACK_BORDER)
		ELSE
			DrawFrame (hdc, button_rect, $$BUTTON_OUT)
'			DrawFrame (hdc, arrow_rect, $$BUTTON_OUT)
		END IF
	END IF
	
	IF (state & $$ODS_DISABLED) THEN
		DrawButtonText (hdc, offset_text_rect, buffer$, $$CLR_BTN_WHITE, style)
		DrawButtonText (hdc, text_rect, buffer$, $$CLR_BTN_DGREY, style)
	ELSE
		IF (state & $$ODS_SELECTED) THEN
			DrawButtonText (hdc, offset_text_rect, buffer$, text_colour, style)
		ELSE
			DrawButtonText (hdc, offset_text_rect, buffer$, text_colour, style)
		END IF
	END IF

	IF (state & $$ODS_FOCUS) THEN
		DrawFocusRect (dis.hDC, &focus_rect)
	END IF
	
	IF (state & $$ODS_SELECTED) THEN
		DrawWidget (hdc, arrow_rect, $$BUTTON_IN)
	ELSE
		IF ((state & $$ODS_DEFAULT) || (state & $$ODS_FOCUS)) THEN
			DrawWidget (hdc, arrow_rect, $$BUTTON_OUT)
		ELSE
			DrawWidget (hdc, arrow_rect, $$BUTTON_OUT)
		END IF
	END IF

END FUNCTION



END PROGRAM