'
'
' ####################
' #####  PROLOG  #####
' ####################

' A comboboxex demo which uses an image list
' to display an icon before each item in the
' combobox list.
'
PROGRAM	"comboboxex"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"xsx"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
  IMPORT  "comctl32"
'
  TYPE ITEMINFO
    XLONG	.iImage
    XLONG	.iSelectedImage
    XLONG	.iIndent
    STRING * 256	.text
  END TYPE
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
DECLARE FUNCTION  AddComboBoxItems (hComboBoxEx)

'Control IDs
$$Combobox1  = 101
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry

	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	CreateWindows ()							' create windows and other child controls
	MessageLoop ()								' the main message loop
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

		CASE $$WM_CREATE :
			#comboboxex = NewChild ($$WC_COMBOBOXEX, "", $$CBS_DROPDOWN, 20, 20, 200, 120, hWnd, $$Combobox1, 0)
			AddComboBoxItems (#comboboxex)

' set initial current selection in combobox1
			SendMessageA (#comboboxex, $$CB_SETCURSEL, 5, 0)

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$CBN_SELCHANGE :
					index = SendMessageA (hwndCtl, $$CB_GETCURSEL, 0, 0)			' get current selection index
					len = SendMessageA (hwndCtl, $$CB_GETLBTEXTLEN, index, 0)	' get length of selected text
					text$ = NULL$(len)
					SendMessageA (hwndCtl, $$CB_GETLBTEXT, index, &text$)			' get selected text
					msg$ = "ComboboxEx: " + STRING$(controlID) + " Index: " + STRING$(index) + " Text: " + text$
					MessageBoxA (hWnd, &msg$, &"ComboboxEx Test", 0)
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
	INITCOMMONCONTROLSEX iccex

	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT(0)
	InitCommonControls()					' initialize comctl32.dll library

	iccex.dwSize = SIZE(iccex)		' initialize common controls extended
	iccex.dwICC = $$ICC_USEREX_CLASSES | $$ICC_COOL_CLASSES
	InitCommonControlsEx (&iccex)

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
	className$  = "ComboboxExDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "ComboboxEx Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 240
	h 					= 200
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
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  				TranslateMessage (&msg)
  				DispatchMessageA (&msg)
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
	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' #################################
' #####  AddComboBoxItems ()  #####
' #################################
'
FUNCTION  AddComboBoxItems (hComboBoxEx)

SHARED hInst
COMBOBOXEXITEM cbei
ITEMINFO iinf[]

  $MAX_ITEMS = 9
  $NUM_ICONS = 9
  $CX_ICON = 16       	' width of each icon

' set the mask common to all items.
  cbei.mask = $$CBEIF_TEXT | $$CBEIF_INDENT | $$CBEIF_IMAGE | $$CBEIF_SELECTEDIMAGE

	DIM iinf[$NUM_ICONS-1]
	FOR i = 0 TO $NUM_ICONS-1
		iinf[i].iImage = i
		iinf[i].iSelectedImage = i
		iinf[i].iIndent = i MOD 3
	NEXT i
	iinf[0].text = "first"
	iinf[1].text = "second"
	iinf[2].text = "third"
	iinf[3].text = "fourth"
	iinf[4].text = "fifth"
	iinf[5].text = "sixth"
	iinf[6].text = "seventh"
	iinf[7].text = "eighth"
	iinf[8].text = "ninth"

	hImageList =ImageList_LoadImage (hInst, &"toolbar", $CX_ICON, $NUM_ICONS, $$CLR_NONE, $$IMAGE_BITMAP, $$LR_LOADTRANSPARENT)

	FOR iCnt = 0 TO $MAX_ITEMS-1
' initialize the COMBOBOXEXITEM struct.
		cbei.iItem          = iCnt

		text$ = iinf[iCnt].text
		cbei.pszText        = &text$
		cbei.cchTextMax     = LEN (text$)

		cbei.iImage         = iinf[iCnt].iImage
		cbei.iSelectedImage = iinf[iCnt].iSelectedImage
		cbei.iIndent        = iinf[iCnt].iIndent

' tell the ComboBoxEx to add the item. Return FALSE if this fails.
  	IF (SendMessageA (hComboBoxEx, $$CBEM_INSERTITEM, 0, &cbei) = -1) THEN RETURN
	NEXT iCnt

' assign the existing image list to the ComboBoxEx control
	SendMessageA (hComboBoxEx, $$CBEM_SETIMAGELIST, 0, hImageList)

	DeleteObject (hImageList)

END FUNCTION
END PROGRAM
