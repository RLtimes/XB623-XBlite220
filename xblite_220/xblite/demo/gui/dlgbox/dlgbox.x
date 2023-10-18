'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo program displays a Modal Dialog Box.
' It uses a Dialog Box Template to create the
' various controls in the Dialog Box.
' ---
' The Template was created using the program
' MS Dialog Editor, Dlgedit.exe.
' ---
' All of the controls are placed on the main
' dialog box and assigned control numbers.
' Note - do not assign any Dlg. Symbol names.

' The final Template is saved as a .dlg file.
' In order to use this template, it must be
' merged with the default resource script file
' used for your program, a *.rc file. This file
' is created the first time you build your program.
' Open up both the .dlg and .rc files in a text
' editor, and copy the text from the template file
' .dlg to the resource script file .rc.
' ---
' Now when you link your final executable program
' using nmake, the resource compiler will create
' the necessary .res file.
' ---
' To use the Dialog Template Resource in a program,
' you must use the DialogBoxParamA () function.
' A separate dialog box procedure is necessary to
' handle all of the callbacks associated with the
' dialog box (see DialogProc ()).

PROGRAM	"dlgbox"
VERSION	"0.0004"
'
	IMPORT	"xst"   		' Standard library : required by most programs
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
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  DialogProc (hwndDlg, uMsg, wParam, lParam)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

'Control IDs

$$Menu_File_Exit = 101
$$Menu_File_Dialog = 102

$$Edit1 = 107
$$Edit2 = 123

$$Button1 = 110

$$CheckBox1 = 111

$$Group1 = 109
$$Group2 = 112

$$Radio1 = 113
$$Radio2 = 114
$$Radio3 = 115

$$Combo1 = 125
$$Combo2 = 117
$$Combo3 = 118

$$ScrollBarH = 119
$$ScrollBarV = 121

$$Progressbar1 = 150
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

	InitGui ()										' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create main windows and other child controls
	MessageLoop ()								' the message loop
	CleanUp ()										' unregister all window classes

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	SHARED hInst

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

				CASE $$Menu_File_Dialog :					' create modal dialog box from resource identifier of the dialog box template
					ret = DialogBoxParamA (hInst, 100, hWnd, &DialogProc(), 0)
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
	className$  = "DialogBox"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Modal Dialog Box Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 200
	h 					= 100
	exStyle			= 0
	#winMain = NewWindow (className$, @title$, style, x, y, w, h, exStyle)

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
' ###########################
' #####  DialogProc ()  #####
' ###########################
'
FUNCTION  DialogProc (hwndDlg, msg, wParam, lParam)

	bkColor = GetSysColor ($$COLOR_BTNFACE)

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			XstCenterWindow (hwndDlg)

		CASE $$WM_CTLCOLORDLG :
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (0, bkColor, wParam, lParam)

		CASE $$WM_CTLCOLORBTN :
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (0, bkColor, wParam, lParam)

		CASE $$WM_CTLCOLORSTATIC :
			hdcDlg = wParam
			hwndDlg = lParam
			RETURN SetColor (0, bkColor, wParam, lParam)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			ID         = LOWORD(wParam)
			hwndCtl    = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE ID :

						CASE $$IDCANCEL :
							EndDialog (hwndDlg, ID)

						CASE $$Button1:
							text$ = "When in the Course of human Events it becomes necessary for one People dissolve the Political Bands which have connected them with another, and to assume among the Powers of the Earth, the separate and equal Station to which the Laws of Nature and of Nature's God entitle them, a decent Respect to the Opinions of Mankind requires that they should declare the causes which impel them to the Separation."
							SetDlgItemTextA (hwndDlg, $$Edit2, &text$)						' set text in edit controls
							text$ = "Howdy, Howdy, Howdy."
							SetDlgItemTextA (hwndDlg, $$Edit1, &text$)

							SendMessageA (GetDlgItem (hwndDlg, $$Progressbar1), $$PBM_SETSTEP, 1, 0)		' set step increment

							FOR i = 1 TO 100
								SendMessageA (GetDlgItem (hwndDlg, $$Progressbar1), $$PBM_STEPIT, 0, 0)		' advance current position by step increment
								Sleep (30)
							NEXT i

						CASE $$CheckBox1:
							text$ = "You clicked on checkbox " + STRING$(ID)
							state = SendMessageA(hwndCtl, $$BM_GETCHECK, 0, 0)
							SELECT CASE state
								CASE $$BST_CHECKED				: state$ = "checked"
								CASE $$BST_INDETERMINATE	: state$ = "indeterminate"
								CASE $$BST_UNCHECKED			: state$ = "unchecked"
							END SELECT
							text$ = text$ + "\nButton state is " + state$
							MessageBoxA (hWnd, &text$, &"DialogBox Test", 0)

						CASE $$Radio1, $$Radio2, $$Radio3:
							text$ = "You clicked on radio button " + STRING$(ID)
							MessageBoxA (hWnd, &text$, &"DialogBox Test", 0)

					END SELECT
			END SELECT

		CASE ELSE :	RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

END FUNCTION
'
'
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
	SHARED hNewBrush
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush
END FUNCTION
END PROGRAM
