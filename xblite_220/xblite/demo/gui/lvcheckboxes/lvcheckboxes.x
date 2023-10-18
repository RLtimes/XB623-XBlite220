'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo program using the listview control
' and adds checkboxes, full row selection,
' and grid lines. The demo also performs
' a hit test to determine which item in
' listbox was selected.
'
PROGRAM	"lvcheckboxes"
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
DECLARE FUNCTION  GetListViewItemText (hwndCtl, iItem, iSubItem, @text$)
DECLARE FUNCTION  SetListViewItemState (hwndCtl, iItem, state, stateMask)
DECLARE FUNCTION  AddListViewItems (hwndCtl, @iImage[], @text$[], @data[])
DECLARE FUNCTION  SetListViewSubItems (hwndCtl, iColumn, @text$[], iStart)
DECLARE FUNCTION  ListViewProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  SetListViewCheckState (hWnd, iIndex, bChecked)
DECLARE FUNCTION  SelectListViewItem (hwndCtl, iItem, bSelect)
DECLARE FUNCTION  GetListViewCheckState (hWnd, iIndex)
DECLARE FUNCTION  SetListViewCheckAllItems (hWnd, bChecked)
DECLARE FUNCTION  SetListViewCheckInvertAll (hWnd)
DECLARE FUNCTION  GetListViewItemChanged (lParam, @iItem, @iSubItem)
DECLARE FUNCTION  GetListViewCheckItemChanged (lParam, @iItem, @bChecked)

' Control ID constants
$$ListView1 = 101

$$CheckRowSelect  = 110
$$CheckGridLines  = 111
$$CheckCheckBoxes = 112

$$StaticMsg1 = 120
$$StaticMsg2 = 121

$$PButtonGetAllChecked = 130
$$PButtonSetChecked    = 132
$$PButtonCheckAll      = 133
$$PButtonUncheckAll    = 134
$$PButtonInvertChecks  = 135

$$EditItemNumber =  140

' custom message
$$LV_LEFTBUTTONDOWN  = 1024
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

	LV_HITTESTINFO hti
	LV_ITEM lvi

	$CRLF = "\r\n"

	SELECT CASE msg

		CASE $$WM_CREATE :

' create a few checkboxes
			#hCheck1 = NewChild ("button", "Full Row Select", $$BS_AUTOCHECKBOX, 10,  10, 130, 20, hWnd, $$CheckRowSelect, 0)
			#hCheck2 = NewChild ("button", "Grid Lines",      $$BS_AUTOCHECKBOX, 140, 10, 100, 20, hWnd, $$CheckGridLines, 0)
			#hCheck3 = NewChild ("button", "Check Boxes",     $$BS_AUTOCHECKBOX, 240, 10, 120, 20, hWnd, $$CheckCheckBoxes, 0)

' create some pushbuttons
			#hPButton1 = NewChild ("button", "Set Checked",     $$BS_PUSHBUTTON, 70,  250, 120, 24, hWnd, $$PButtonSetChecked, 0)
			#hPButton2 = NewChild ("button", "Get All Checked", $$BS_PUSHBUTTON, 70,  274, 120, 24, hWnd, $$PButtonGetAllChecked, 0)
			#hPButton3 = NewChild ("button", "Check All",       $$BS_PUSHBUTTON, 200, 250, 120, 24, hWnd, $$PButtonCheckAll, 0)
			#hPButton4 = NewChild ("button", "Uncheck All",     $$BS_PUSHBUTTON, 200, 274, 120, 24, hWnd, $$PButtonUncheckAll, 0)
			#hPButton5 = NewChild ("button", "Invert Checks",   $$BS_PUSHBUTTON, 330, 250, 120, 24, hWnd, $$PButtonInvertChecks, 0)

' create static controls
			#hStatic1 = NewChild ("static", "", $$SS_LEFT, 10, 200, 470, 20, hWnd, $$StaticMsg1, $$WS_EX_STATICEDGE)
			#hStatic2 = NewChild ("static", "", $$SS_LEFT, 10, 220, 470, 20, hWnd, $$StaticMsg2, $$WS_EX_STATICEDGE)

' create an edit control
			#hEdit = NewChild ("edit", "0", $$ES_NUMBER | $$ES_RIGHT, 10, 250, 50, 22, hWnd, $$EditItemNumber, $$WS_EX_CLIENTEDGE)

' create a report style List View control
			#hListView = NewChild ($$WC_LISTVIEW, "", $$LVS_REPORT, 10, 40, 470, 150, hWnd, $$ListView1, $$WS_EX_CLIENTEDGE)

'	Subclass the listview control by assigning it a new callback
' function. It will be used to trap WM_LBUTTONDOWN msgs
' in order to send a custom LV_LEFTBUTTONDOWN message to the control's
' parent window procedure
			#old_proc = SetWindowLongA (#hListView, $$GWL_WNDPROC, &ListViewProc())

' add columns for Report View style
			ret = AddListViewColumn (#hListView, 0, 126, "Last Name")
			ret = AddListViewColumn (#hListView, 1,  90, "First Name")
			ret = AddListViewColumn (#hListView, 2, 140, "E-Mail")
			ret = AddListViewColumn (#hListView, 3, 110, "Cell Phone")

' add listview items
			DIM last$[7]
			DIM iImage[7]
			DIM data[7]
			last$[0] = "Smith"
			last$[1] = "Anderson"
			last$[2] = "White"
			last$[3] = "Johnson"
			last$[4] = "Acker"
			last$[5] = "Boon"
			last$[6] = "Campbell"
			last$[7] = "Tucker"
			AddListViewItems (#hListView, @iImage[], @last$[], @data[])

' set subItems in column 1
			DIM first$[7]
			first$[0] = "Mr"
			first$[1] = "Neo"
			first$[2] = "Jim"
			first$[3] = "John"
			first$[4] = "Allen"
			first$[5] = "Rick"
			first$[6] = "Jerry"
			first$[7] = "Steve"
			SetListViewSubItems (#hListView, 1, @first$[], 0)

' set subItems in column 2
			DIM email$[7]
			email$[0] = "smitty@unplugged.net"
			email$[1] = "neo@zion.com"
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


		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE id

' set extended listview style to enable full row select style (Win98+)
						CASE $$CheckRowSelect  :
							buttonState = SendMessageA (#hCheck1, $$BM_GETCHECK, 0, 0)
							exStyle = SendMessageA (#hListView, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
							IF buttonState THEN
								exStyle = exStyle | $$LVS_EX_FULLROWSELECT
							ELSE
								exStyle = exStyle & ~$$LVS_EX_FULLROWSELECT
							END IF
							SendMessageA (#hListView, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)
							SetFocus (#hListView)

' set extended listview style to use gridlines
						CASE $$CheckGridLines  :
							buttonState = SendMessageA (#hCheck2, $$BM_GETCHECK, 0, 0)
							exStyle = SendMessageA (#hListView, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
							IF buttonState THEN
								exStyle = exStyle | $$LVS_EX_GRIDLINES
							ELSE
								exStyle = exStyle & ~$$LVS_EX_GRIDLINES
							END IF
							SendMessageA (#hListView, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)
							SetFocus (#hListView)

' set extended listview style to use checkboxes in first column
						CASE $$CheckCheckBoxes :
							buttonState = SendMessageA (#hCheck3, $$BM_GETCHECK, 0, 0)
							exStyle = SendMessageA (#hListView, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
							IF buttonState THEN
								exStyle = exStyle | $$LVS_EX_CHECKBOXES
							ELSE
								exStyle = exStyle & ~$$LVS_EX_CHECKBOXES
							END IF
							ret = SendMessageA (#hListView, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)
							SetFocus (#hListView)

' find out which checkboxes have been checked
						CASE $$PButtonGetAllChecked :

' get count of items in listbox
								count = SendMessageA (#hListView, $$LVM_GETITEMCOUNT, 0, 0)
								IFZ count THEN RETURN

' the initial msgbox text
   							msg$ = "The following ListView items are checked (0-based):" + $CRLF + $CRLF

' iterate through each item, checking its item state
   							FOR i = 0 TO count - 1

									checked = GetListViewCheckState (#hListView, i)

' if it's checked, get item text string
									IF checked THEN
										GetListViewItemText (#hListView, i, 0, @text$)

' and continue building the msgbox string with the info
         						msg$ = msg$ + "item " + STRING$(i) + "  ( "
										msg$ = msg$ + text$ + " )" + $CRLF
									END IF
								NEXT i
								MessageBoxA (hWnd, &msg$, &"ListView Checkboxes", 0)

						CASE $$PButtonSetChecked   :
							count = SendMessageA (#hListView, $$LVM_GETITEMCOUNT, 0, 0)
							IFZ count THEN RETURN
							text$ = NULL$ (256)
							GetWindowTextA (#hEdit, &text$, LEN (text$))
							index = XLONG (CSIZE$ (text$))
							lvCount = count - 1
							IF index <= lvCount THEN
								SetListViewCheckState (#hListView, index, $$TRUE)
							ELSE
								msg$ = "Select item 0 to" + STRING$(lvCount) + " only!"
								MessageBoxA (hWnd, &msg$, &"ListView Checkboxes", 0)
							END IF

						CASE $$PButtonCheckAll     : SetListViewCheckAllItems (#hListView, $$TRUE)
						CASE $$PButtonUncheckAll   : SetListViewCheckAllItems (#hListView, $$FALSE)
						CASE $$PButtonInvertChecks : SetListViewCheckInvertAll (#hListView)

					END SELECT
			END SELECT

		CASE $$LV_LEFTBUTTONDOWN :
			fwKeys = wParam
			xPos = LOWORD (lParam)
			yPos = HIWORD (lParam)

' get the hittest info using the mouse coords
			hti.pt.x = xPos
			hti.pt.y = yPos
			hti.flags = $$LVHT_ONITEM
			SendMessageA (#hListView, $$LVM_SUBITEMHITTEST, 0, &hti)

' this determines whether the hit test returned a main or sub item
			IF hti.iSubItem = 0 THEN
				IF hti.iItem > -1 THEN
					msg1$ = "User clicked over main item " + STRING$(hti.iItem)
				ELSE
					msg1$ = "User clicked a main item's white space"
				END IF
			ELSE
				IF hti.iSubItem > 0 THEN
					IF hti.iItem > -1 THEN
						msg1$ = "User clicked main item " + STRING$(hti.iItem)
						msg1$ = msg1$ + " by clicking SubItem " + STRING$(hti.iSubItem)
					ELSE
						msg1$ = "User clicked a subitem's white space"
					END IF
				END IF
			END IF

' this determines what part of the item or SubItem was clicked
			IF hti.flags AND $$LVHT_ONITEM THEN

				IF hti.flags AND $$LVHT_ONITEMICON THEN
					msg2$ = "(click occurred over the item's icon area)"
				END IF

				IF hti.flags AND $$LVHT_ONITEMLABEL THEN
					SELECT CASE hti.iSubItem
						CASE 0    : msg2$ = "(click occurred over the item's main text)"
						CASE ELSE : msg2$ = "(click occurred over the SubItem text)"
					END SELECT
      	END IF
			END IF

' now select the current item if the control's FullRowSelect
' style is not selected, and a SubItem was clicked.
' NOTE: this is currently not working correctly
'       the item is selected only when mouse is down???
'			IF hti.iSubItem > 0 THEN
'				ret = SelectListViewItem (#hListView, hti.iItem, $$TRUE)
'			END IF

			SetWindowTextA (#hStatic1, &msg1$)
			SetWindowTextA (#hStatic2, &msg2$)

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
' get notification of change in checkbox state
								IFT GetListViewCheckItemChanged (lParam, @iItem, @bChecked) THEN
									IF bChecked THEN state$ = "checked." ELSE state$ = "unchecked."
									msg2$ = "Checkbox Event : item" + STRING$(iItem) + " is now " + state$
 									SetWindowTextA (#hStatic2, &msg2$)
								END IF

' get notification of change in main item selection
'								IFT GetListViewItemChanged (lParam, @iItem, @iSubItem) THEN
'									GetListViewItemText (#hListView, iItem, iSubItem, @text$)
'									msg$ = "ListView Selection"
'									msg$ = msg$ + "\nItem index: " + STRING$(iItem)
'									msg$ = msg$ + "\nSubItem index: " + STRING$(iSubItem)
'									msg$ = msg$ + "\nText: " + text$
'									MessageBoxA (hWnd, &msg$, &"ListView Test", 0)
'								END IF
					END SELECT
			END SELECT

'		CASE $$WM_SETFOCUS :
' set focus back onto listview control so selections are highlighted
'			SendMessageA (#hListView, $$WM_SETFOCUS, hWnd, 0)

'		CASE $$WM_SIZE :
'			' make the listview control the size of the window's client area
'			MoveWindow (#hListView, 0, 0, LOWORD(lParam), HIWORD(lParam), $$TRUE)

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

	INITCOMMONCONTROLSEX iccex
	SHARED hInst

	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT(0)
	InitCommonControls()					' initialize comctl32.dll library

' initialize common controls extended classes for listview control
'	iccex.dwSize = SIZE(iccex)
'	iccex.dwICC = $$ICC_LISTVIEW_CLASSES
'	ret = InitCommonControlsEx (&iccex)


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
	className$  = "ListViewDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "ListView Demo"
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 500
	h 					= 340
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
		ret = GetMessageA (&msg, 0, 0, 0)

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
FUNCTION  SetListViewItemState (hwndCtl, iItem, state, stateMask)

	LV_ITEM lvi

	PRINT "SetListViewItemState :"; hwndCtl, iItem, state, stateMask

	lvi.mask      = $$LVIF_STATE
	lvi.stateMask	= stateMask
	lvi.state 		= state
	lvi.iItem     = iItem
	ret = SendMessageA (hwndCtl, $$LVM_SETITEMSTATE, iItem, &lvi)
'	SendMessageA (hwndCtl, $$LVM_UPDATE, iItem, 0)

	RETURN ret

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
' PURPOSE : The listview control does not send any mouse
'           messages to the control's parent window.
'           This procedure will send a custom mouse
'           message $$LV_LEFTBUTTONDOWN to the parent.
'
'
FUNCTION  ListViewProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg

		CASE $$WM_LBUTTONDOWN :
			SendMessageA (GetParent (hWnd), $$LV_LEFTBUTTONDOWN, wParam, lParam)

	END SELECT

RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

END FUNCTION
'
'
' ######################################
' #####  SetListViewCheckState ()  #####
' ######################################
'
FUNCTION  SetListViewCheckState (hWnd, iIndex, bChecked)

	LV_ITEM lvi

	lvi.stateMask = $$LVIS_STATEIMAGEMASK
'	lvi.state = (bChecked) ? 8192 : 4196
	IF bChecked THEN
		lvi.state = 8192
	ELSE
		lvi.state = 4196
	END IF

	SendMessageA (hWnd, $$LVM_SETITEMSTATE, iIndex, &lvi)

END FUNCTION
'
'
' ###################################
' #####  SelectListViewItem ()  #####
' ###################################
'
FUNCTION  SelectListViewItem (hwndCtl, iItem, bSelect)

	LV_ITEM lvi

	PRINT "SetListViewItemState :"; hwndCtl, iItem, state, stateMask

	lvi.mask      = $$LVIF_STATE
	IF bSelect THEN
		lvi.stateMask	= $$LVIS_FOCUSED | $$LVIS_SELECTED
		lvi.state 		= $$LVIS_FOCUSED | $$LVIS_SELECTED
	ELSE
		lvi.stateMask	= $$LVIS_FOCUSED | $$LVIS_SELECTED
		lvi.state 		= 0
	END IF
	lvi.iItem     = iItem
	ret = SendMessageA (hwndCtl, $$LVM_SETITEMSTATE, iItem, &lvi)
'	SendMessageA (hwndCtl, $$LVM_UPDATE, iItem, 0)

	RETURN ret

END FUNCTION
'
'
' ######################################
' #####  SetListViewCheckState ()  #####
' ######################################
'
FUNCTION  GetListViewCheckState (hWnd, iIndex)

	mask = $$LVIS_STATEIMAGEMASK
	state = SendMessageA (hWnd, $$LVM_GETITEMSTATE, iIndex, mask)
	IF state = 8192 THEN RETURN ($$TRUE)

END FUNCTION
'
'
' #########################################
' #####  SetListViewCheckAllItems ()  #####
' #########################################
'
FUNCTION  SetListViewCheckAllItems (hWnd, bChecked)

	count = SendMessageA (hWnd, $$LVM_GETITEMCOUNT, 0, 0)
	IFZ count THEN RETURN

	FOR i = 0 TO count - 1
		SetListViewCheckState (hWnd, i, bChecked)
	NEXT i

END FUNCTION
'
'
' ##########################################
' #####  SetListViewCheckInvertAll ()  #####
' ##########################################
'
FUNCTION  SetListViewCheckInvertAll (hWnd)

	count = SendMessageA (hWnd, $$LVM_GETITEMCOUNT, 0, 0)
	IFZ count THEN RETURN

	FOR i = 0 TO count - 1
		bChecked = GetListViewCheckState (hWnd, i)
		IF bChecked THEN
			bChecked = $$FALSE
		ELSE
			bChecked = $$TRUE
		END IF
		SetListViewCheckState (hWnd, i, bChecked)
	NEXT i


END FUNCTION
'
'
' #######################################
' #####  GetListViewItemChanged ()  #####
' #######################################
'
FUNCTION  GetListViewItemChanged (lParam, @iItem, @iSubItem)

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
' ############################################
' #####  GetListViewCheckItemChanged ()  #####
' ############################################
'
FUNCTION  GetListViewCheckItemChanged (lParam, @iItem, @bChecked)

	NM_LISTVIEW nmlv

	nmlvAddr = lParam
'	XstCopyMemory (nmlvAddr, &nmlv, SIZE(nmlv))	'Xst library function
	RtlMoveMemory (&nmlv, nmlvAddr, SIZE(nmlv))	'kernel32 library function

' check to see if state has changed
	IF (nmlv.uOldState == 0) && (nmlv.uNewState == 0) THEN RETURN

' get last checkbox state
	bPrevState = ((nmlv.uOldState & $$LVIS_STATEIMAGEMASK) >> 12) - 1

	IF bPrevState < 0 THEN					' on startup there isn't a previous state
		bPrevState = 0 								' so assign as false (unchecked)
	END IF

	bChecked = ((nmlv.uNewState & $$LVIS_STATEIMAGEMASK) >> 12) - 1

	IF bChecked < 0 THEN						' on non-checkbox notification assume false
		bChecked = 0
	END IF

	IF bPrevState == bChecked THEN	' no change in checkbox state
		RETURN
	ELSE
		iItem = nmlv.iItem
		RETURN ($$TRUE)
	END IF

'	IF (nmlv.uOldState & $$LVIS_SELECTED) == 0 && (nmlv.uNewState & $$LVIS_SELECTED) == $$LVIS_SELECTED THEN
'		iItem = nmlv.iItem
'		iSubItem = nmlv.iSubItem
'		RETURN $$TRUE
'	ELSE
'		RETURN $$FALSE
'	END IF

END FUNCTION
END PROGRAM
