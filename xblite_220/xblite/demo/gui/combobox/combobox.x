'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo showing the use of various
' styles of combobox controls.
'
PROGRAM	"combobox"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"xsx"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
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
DECLARE FUNCTION  ComboboxAddString (hwndCtl, text$)

'Control IDs
$$Combobox1  = 101
$$Combobox2  = 102
$$Combobox3  = 103
$$Combobox4  = 104
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

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$CBN_SELENDOK :
					index = SendMessageA (hwndCtl, $$CB_GETCURSEL, 0, 0)			' get current selection index
					len = SendMessageA (hwndCtl, $$CB_GETLBTEXTLEN, index, 0)	' get length of selected text
					text$ = NULL$(len)
					SendMessageA (hwndCtl, $$CB_GETLBTEXT, index, &text$)			' get selected text
					msg$ = "Combobox: " + STRING$(controlID) + " Index: " + STRING$(index) + " Text: " + text$
					MessageBoxA (hWnd, &msg$, &"Combobox Test", 0)
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
	className$  = "ComboboxControls"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Combobox Controls."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 530
	h 					= 200
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

'create and show various button class controls

	#combobox1 = NewChild ("combobox", "", $$CBS_SIMPLE | $$WS_VSCROLL | $$CBS_AUTOHSCROLL, 20, 20, 150, 150, #winMain, $$Combobox1, $$WS_EX_CLIENTEDGE)
	#combobox2 = NewChild ("combobox", "", $$CBS_DROPDOWNLIST | $$WS_VSCROLL, 190, 20, 150, 150, #winMain, $$Combobox2, $$WS_EX_CLIENTEDGE)
	#combobox3 = NewChild ("combobox", "", $$CBS_DROPDOWNLIST | $$WS_VSCROLL | $$CBS_SORT, 360, 20, 150, 150, #winMain, $$Combobox3, $$WS_EX_CLIENTEDGE)

' initialize comboboxes with data
	FOR i = 0 TO 19
		text$ = STRING$(i) + " mississippi"
		ComboboxAddString (#combobox1, text$)
	NEXT i

' set initial current selection in combobox1
	SendMessageA (#combobox1, $$CB_SETCURSEL, 0, 0)

' add list of filenames to combobox2
	XstFindFiles ("c:\\", "*.*", $$FALSE,  @filelist$[])
	IF filelist$[] THEN
		FOR i = 0 TO UBOUND (filelist$[])
			XstDecomposePathname (filelist$[i], @path$, @parent$, @filename$, @file$, @extent$)
 			ComboboxAddString (#combobox2, filename$)
		NEXT i
	END IF

' set initial current selection in combobox2
	SendMessageA (#combobox2, $$CB_SETCURSEL, 0, 0)

' add items to sorted combobox
	ComboboxAddString (#combobox3, "Static")
	ComboboxAddString (#combobox3, "Listbox")
	ComboboxAddString (#combobox3, "Combobox")
	ComboboxAddString (#combobox3, "PushButton")
	ComboboxAddString (#combobox3, "Edit")
	ComboboxAddString (#combobox3, "Scrollbar")
	ComboboxAddString (#combobox3, "RadioButton")
	ComboboxAddString (#combobox3, "CheckBox")
	ComboboxAddString (#combobox3, "GroupBox")

' set initial current selection in combobox3
	SendMessageA (#combobox3, $$CB_SETCURSEL, 0, 0)

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
	UnregisterClassA(&className$, hInst)

END FUNCTION
'
'
' ##################################
' #####  ComboboxAddString ()  #####
' ##################################
'
FUNCTION  ComboboxAddString (hwndCtl, text$)
	IF text$ THEN
		RETURN SendMessageA (hwndCtl, $$CB_ADDSTRING, 0, &text$)
	END IF
END FUNCTION
END PROGRAM
