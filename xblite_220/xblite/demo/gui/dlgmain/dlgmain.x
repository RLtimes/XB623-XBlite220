'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo program displays a Modal Dialog Box
' as the main window. It uses a Dialog Box
' Template to create the various controls in
' the Dialog Box.
' ---
' To use the Dialog Template Resource in a program,
' you must use the DialogBoxParamA () function.
' A separate dialog box procedure is necessary to
' handle all of the callbacks associated with the
' dialog box (see DialogProc ()).

PROGRAM	"dlgmain"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  CreateWindows ()
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

$$MENU_FILE_NEW = 201
$$MENU_FILE_OPEN = 202
$$MENU_FILE_SAVE = 203
$$MENU_FILE_SAVEAS = 204
$$MENU_FILE_PAGESETUP = 205
$$MENU_FILE_PRINT = 206
$$MENU_FILE_EXIT = 207

$$MENU_EDIT_CUT = 210
$$MENU_EDIT_COPY = 211
$$MENU_EDIT_PASTE = 212
$$MENU_EDIT_DELETE = 213


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
'	XioFreeConsole ()							' free console

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
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

	SHARED hInst

' create main modal dialog window.
' to process messages for the modal dialog box,
' Windows starts its own message loop, taking
' temporary control of the message queue for
' the entire application.

	IFZ DialogBoxParamA (hInst, 100, 0, &DialogProc(), 0) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  DialogProc ()  #####
' ###########################
'
FUNCTION  DialogProc (hwndDlg, msg, wParam, lParam)

	SHARED hInst
	bkColor = GetSysColor ($$COLOR_BTNFACE)

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			' add menu
      menu$ = "MENU"
		  SetMenu (hwndDlg, LoadMenuA (hInst, &menu$))
			' set icon in title bar
			icon$ = "scrabble"
			hIcon = LoadIconA (hInst, &icon$)
			IF hIcon THEN
				SendMessageA (hwndDlg, $$WM_SETICON, $$ICON_BIG, hIcon)
				SendMessageA (hwndDlg, $$WM_SETICON, $$ICON_SMALL, hIcon)
			END IF 
			' set cursor
'			hCursor = LoadCursorA (0, $$IDC_CROSS)
'			SetClassLongA (hwndDlg, $$GCL_HCURSOR, hCursor) 	 
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
							SetDlgItemTextA (hwndDlg, $$Edit2, &text$)					' set text in edit controls
							text$ = "Howdy, Howdy, Howdy."
							SetDlgItemTextA (hwndDlg, $$Edit1, &text$)

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
							
						CASE $$MENU_FILE_NEW, $$MENU_FILE_OPEN, $$MENU_FILE_SAVE, $$MENU_FILE_SAVEAS, $$MENU_FILE_PAGESETUP, $$MENU_FILE_PRINT, $$MENU_FILE_EXIT :
							text$ = "You clicked on Menu File item " + STRING$(ID)
							MessageBoxA (hWnd, &text$, &"DialogBox Test", 0)
							
						CASE $$MENU_EDIT_CUT, $$MENU_EDIT_COPY, $$MENU_EDIT_PASTE, $$MENU_EDIT_DELETE :
							text$ = "You clicked on Menu Edit item " + STRING$(ID)
							MessageBoxA (hWnd, &text$, &"DialogBox Test", 0)
					END SELECT
			END SELECT

		CASE ELSE : RETURN ($$FALSE)

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
