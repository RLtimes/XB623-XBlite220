'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo program to show how to create an
' on-the-fly modal dialog box without using a
' resource file. The modal dialog box is created
' with DialogBoxIndirectParamA ().
'
PROGRAM	"custdlgbox"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"

TYPE TDLGDATA
	DLGTEMPLATE	.dltt
	USHORT	.menu
	USHORT	.class
	USHORT	.title
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewDialogBox (hWndParent, width, height, dlgProcAddr, initParam)
DECLARE FUNCTION  DialogProc (hwndDlg, uMsg, wParam, lParam)

'Control IDs

$$Menu_File_Exit = 110
$$Menu_File_Dialog = 111

$$ButtonOk = 120
$$ButtonCancel = 121

$$Group1 = 130

$$Radio1 = 140
$$Radio2 = 141
$$Radio3 = 142
$$Radio4 = 143
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

	SHARED selectedItem$, lastSelItem$

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$Menu_File_Exit :
					PostQuitMessage(0)

				CASE $$Menu_File_Dialog :
					ID = NewDialogBox (hWnd, 300, 210, &DialogProc(), initParam)	' create dialog box
					SELECT CASE ID :
						CASE $$ButtonOk :
							text$ = "Ok Pressed\n"
							text$ = text$ + "Control ID: " + STRING$(ID) +"\n"
							text$ = text$ + selectedItem$
							MessageBoxA (hWnd, &text$, &"Quiz Result", 0)
							lastSelItem$ = selectedItem$
							#fRadioLast = #fRadioChecked
						CASE $$ButtonCancel, $$IDCANCEL :
							text$ = "Cancel Pressed\n"
							text$ = text$ + "Control ID: " + STRING$(ID) + "\n"
							text$ = text$ + lastSelItem$
							MessageBoxA (hWnd, &text$, &"Quiz Result", 0)
							#fRadioChecked = #fRadioLast									'set default radio to last checked ok
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

	SHARED className$

' register window class
	className$  = "CustDialogBox"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Custom Dialog Box."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 200
	h 					= 100
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' build a main menu
	#mainMenu = CreateMenu()				' create main menu

' build dropdown submenus
	#fileMenu = CreateMenu()				' create dropdown file menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Dialog, &"&Show Dialog")

	SetMenu (#winMain, #mainMenu)						' activate the menu

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
' #############################
' #####  NewDialogBox ()  #####
' #############################
'
FUNCTION  NewDialogBox (hWndParent, width, height, dlgProcAddr, initParam)

	SHARED hInst
	TDLGDATA tdd				' user defined in this program
	DLGTEMPLATE dltt

' fill in DLGTEMPLATE struct
	dltt.style 	= $$DS_MODALFRAME | $$DS_3DLOOK | $$WS_POPUP | $$WS_CAPTION | $$WS_SYSMENU | $$WS_VISIBLE | $$DS_ABSALIGN  | $$DS_SETFONT
	dltt.dwExtendedStyle 	= 0
	dltt.cdit 						= 0					' number of control items in dialog box, this creates an empty dialog box

	bu = GetDialogBaseUnits ()				' get dialog base units
	screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	screenHeight = GetSystemMetrics ($$SM_CYSCREEN)

	x = (screenWidth - width)/2				' center dialogbox on screen
	y = (screenHeight - height)/2

	dialogUnitX = (x*4)/LOWORD(bu)
	dialogUnitY = (y*8)/HIWORD(bu)

	dltt.x = dialogUnitX
	dltt.y = dialogUnitY

	dialogUnitWidth = (width*4)/LOWORD(bu)		' convert width in pixels to dialog units
	dialogUnitHeight = (height*8)/HIWORD(bu)	' convert height in pixels to dialog units

	dltt.cx = dialogUnitWidth
	dltt.cy = dialogUnitHeight

' fill in TDLGDATA struct
	tdd.dltt 	= dltt
	tdd.menu 	= 0
	tdd.class = 0
	tdd.title = 0

' create dialog box
	RETURN DialogBoxIndirectParamA (hInst, &tdd, hWndParent, dlgProcAddr, initParam)

END FUNCTION
'
'
' ###########################
' #####  DialogProc ()  #####
' ###########################
'
FUNCTION  DialogProc (hwndDlg, msg, wParam, lParam)

	SHARED selectedItem$, lastSelItem$

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
'			PRINT "WM_INITDIALOG: add controls here"
			title$ = "An On-the-fly Dialog Box"
			SetWindowTextA (hwndDlg, &title$)				' set dialog box title

' add child controls to dialog box
			#group1 = NewChild ("button", "How do you rate this DialogBox?", $$BS_GROUPBOX, 10, 10, 280, 135, hwndDlg, $$Group1, 0)

			#radio1 = NewChild ("button", "Super",     $$BS_AUTORADIOBUTTON | $$WS_GROUP | $$WS_TABSTOP, 20, 30, 200, 25, hwndDlg, $$Radio1, 0)
			#radio2 = NewChild ("button", "Ok",        $$BS_AUTORADIOBUTTON, 20, 55, 200, 25, hwndDlg, $$Radio2, 0)
			#radio3 = NewChild ("button", "Boring",    $$BS_AUTORADIOBUTTON, 20, 80, 200, 25, hwndDlg, $$Radio3, 0)
			#radio4 = NewChild ("button", "Who Cares", $$BS_AUTORADIOBUTTON, 20, 105, 200, 25, hwndDlg, $$Radio4, 0)

			#button1 = NewChild ("button", "Ok",     $$BS_DEFPUSHBUTTON | $$WS_TABSTOP, 10, 165, 135, 25, hwndDlg, $$ButtonOk, 0)
			#button2 = NewChild ("button", "Cancel", $$BS_PUSHBUTTON | $$WS_TABSTOP, 155, 165, 135, 25, hwndDlg, $$ButtonCancel, 0)

' initialize radio button to checked state
			IFZ selectedItem$ THEN selectedItem$ = "Super"					'set default selected radio text
			IFZ lastSelItem$ THEN lastSelItem$ = "Super"						'set last selected radio text
			IFZ #fRadioChecked THEN #fRadioChecked = $$Radio1				'set default radio button selection
			hRadio = GetDlgItem (hwndDlg, #fRadioChecked)						'get handle to radio button
			SendMessageA (hRadio, $$BM_SETCHECK, $$BST_CHECKED, 0)	'set check state of radio button

' set focus to ok button
			SetFocus (GetDlgItem (hwndDlg, $$ButtonOk))
			RETURN ($$FALSE)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			ID         = LOWORD(wParam)
			hwndCtl    = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE ID :

						CASE $$IDCANCEL :									' window close button pressed
							EndDialog (hwndDlg, ID)

						CASE $$ButtonOk, $$ButtonCancel:
							EndDialog (hwndDlg, ID)

						CASE $$Radio1, $$Radio2, $$Radio3, $$Radio4:
							state = SendMessageA(hwndCtl, $$BM_GETCHECK, 0, 0)
							IF state = $$BST_CHECKED THEN
								#fRadioChecked = ID									' save currently checked radio button
								text$ = NULL$(256)
								SendMessageA (hwndCtl, $$WM_GETTEXT, LEN(text$), &text$)
								selectedItem$ = CSIZE$(text$)
							END IF
					END SELECT
			END SELECT

		CASE ELSE :	RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

END FUNCTION
END PROGRAM
