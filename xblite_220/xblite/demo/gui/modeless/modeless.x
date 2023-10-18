'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo program displays a Modeless Dialog Box
' as a main user window. It uses a Dialog Box Template
' to create the various controls in the Dialog Box.
' ---
' The Template was created using the program
' weditres.exe, the resource editor for lcc-win32.
' ---
' 1. File > New
'    Fill in name of app and current directory for app.
' 2. On Dialog Box Parameters Dialog, fill in new title,
'    and set any necessary parameters.
' 3. File > Files
'    Select Files to be generated:
'    Click on Definitions and prototypes (.h)
'    Click on RC ASCII resource file (.rc)
'    Deselect all the other files unless you want them.
' 4. Add controls to main dialog. Assign a symbol name
'    to each child control.
' 5. Save files using File > Save.
' 6. Copy and modify the control symbol definitions
'    in app.h to your programs PROLOG section.
'      #define  BUTTON1  101
'    should be translated to
'      $$BUTTON1 = 101
' 7. In order to use this .rc template, you must add
'    the line:
'      #include "winres.h"
'    plus a line which indicates the icon to be
'    used for your program:
'      scrabble ICON    scrabble.ico
' ---
' Now when you link your final executable program
' using nmake, the resource compiler will create
' the necessary .res file.
' ---
' To use the Dialog Template Resource in a program,
' you must use the CreateDialogParamA () function.
' A separate dialog box procedure is necessary to
' handle all of the callbacks associated with the
' dialog box (see DialogProc ()).
' ---
' To open an existing *.rc file in weditres.exe, you
' need to have winres.h and any other icon or bitmap
' files in the same directory as your program.

PROGRAM	"modeless"
VERSION	"0.0003"
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
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  DialogProc (hwndDlg, uMsg, wParam, lParam)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  SetClientEdgeWinStyle (hWnd)
'
'Control IDs
$$MENUFILE	= 1
$$MENUNEW	= 1011
$$MENUOPEN	= 1021
$$DLGBOX100	= 100
$$GROUPBOX1	= 101
$$CHECKBOX1	= 102
$$RADIOCONTROL1	= 103
$$RADIOCONTROL2	= 104
$$SLIDER	= 107
$$LABELSLIDER	= 108
$$PROGRESSCTL	= 109
$$LABELPROGRESS	= 110
$$RECTANGLE	= 111
$$SOLIDRECTANGLE	= 112
$$EDITCONTROL	= 113
$$LABELEDIT	= 114
$$PUSHBUTTON1	= 115
$$PUSHBUTTON2	= 116
$$COMBOCONTROL	= 117
$$PUSHBUTTON3	= 120
$$EDITBOX2	= 121
$$EDITCONTROL1	= 123
$$HORZSCROLLBAR	= 124
$$VERTSCROLLBAR	= 125
'
$$STATUSBAR = 500
'
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

' create modeless dialog window

	#hWndDlg = CreateDialogParamA (hInst, 100, 0, &DialogProc(), 0)
	IFZ #hWndDlg THEN RETURN ($$TRUE)

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
	DestroyWindow (#hWndDlg)								' destroy the dialog box window

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

' center window
			XstCenterWindow (hwndDlg)

' set some new extended window styles
' the WS_EX_CLIENTEDGE style is ignored in resource file
			SetClientEdgeWinStyle (GetDlgItem (hwndDlg, $$EDITCONTROL1))
			SetClientEdgeWinStyle (GetDlgItem (hwndDlg, $$SLIDER))
			SetClientEdgeWinStyle (GetDlgItem (hwndDlg, $$EDITBOX2))
			SetClientEdgeWinStyle (GetDlgItem (hwndDlg, $$PROGRESSCTL))

' set slider range
			SendDlgItemMessageA (hwndDlg, $$SLIDER, $$TBM_SETRANGE, $$TRUE, MAKELONG(0,100))
			SendDlgItemMessageA (hwndDlg, $$SLIDER, $$TBM_SETTICFREQ, 10, 0)

' set text in edit control
			SetDlgItemTextA (hwndDlg, $$EDITCONTROL1, &"An Edit Control")

' set text in multiline edit control
			text$ = "When in the Course of human \r\nEvents it becomes necessary for \r\none People dissolve the Political \r\nBands which have connected them \r\nwith another, and to assume \r\namong the Powers of the \r\nEarth, the separate and equal \r\nStation to which the Laws of \r\nNature and of Nature's God \r\nentitle them, a decent Respect \r\nto the Opinions of Mankind \r\nrequires that they should declare \r\nthe causes which impel them \r\nto the Separation."
			SetDlgItemTextA (hwndDlg, $$EDITBOX2, &text$)					' set text in edit controls

' store the input arguments if any
			SetPropA (hwndDlg, &"InputArgument", lParam)

' add a status bar
			CreateStatusWindowA ($$WS_CHILD | $$WS_VISIBLE, &"A Status Bar", hwndDlg, $$STATUSBAR)

' set window icon
			hIcon = LoadIconA (hInst, &"scrabble")
			SendMessageA (hwndDlg, $$WM_SETICON, 1, hIcon)

' set focus, if used, then return must be $$FALSE
'			SetFocus (GetDlgItem (hwndDlg, $$RADIOCONTROL1))

' if return is $$TRUE, then first control in resource template
' with WS_TABSTOP flag is default focus

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

' close button pressed
						CASE $$IDCANCEL :
							RemovePropA (hwndDlg, &"InputArgument")
							PostQuitMessage(0)

						CASE $$MENUNEW, $$MENUOPEN :
							text$ = "You selected menu item " + STRING$(ID)
							MessageBoxA (hwndDlg, &text$, &"Modeless Dialog Box Test", 0)

						CASE $$PUSHBUTTON1, $$PUSHBUTTON2, $$PUSHBUTTON3 :
							text$ = "You clicked on button " + STRING$(ID)
							MessageBoxA (hwndDlg, &text$, &"Modeless Dialog Box Test", 0)

						CASE $$CHECKBOX1 :
							text$ = "You clicked on checkbox " + STRING$(ID)
							state = SendMessageA (hwndCtl, $$BM_GETCHECK, 0, 0)
							SELECT CASE state
								CASE $$BST_CHECKED				: state$ = "checked"
								CASE $$BST_INDETERMINATE	: state$ = "indeterminate"
								CASE $$BST_UNCHECKED			: state$ = "unchecked"
							END SELECT
							text$ = text$ + "\nButton state is " + state$
							MessageBoxA (hwndDlg, &text$, &"Modeless Dialog Box Test", 0)

						CASE $$RADIOCONTROL1, $$RADIOCONTROL2 :
							text$ = "You clicked on radio button " + STRING$(ID)
							MessageBoxA (hwndDlg, &text$, &"Modeless Dialog Box Test", 0)

					END SELECT
			END SELECT

		CASE $$WM_SIZE :
' send resize msg to statusbar
			SendDlgItemMessageA (hwndDlg, $$STATUSBAR, $$WM_SIZE, wParam, lParam)

		CASE ELSE :
			RETURN ($$FALSE)

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
'
'
' ######################################
' #####  SetClientEdgeWinStyle ()  #####
' ######################################
'
FUNCTION  SetClientEdgeWinStyle (hWnd)

	style = GetWindowLongA (hWnd, $$GWL_EXSTYLE)
	SetWindowLongA (hWnd, $$GWL_EXSTYLE, style | $$WS_EX_CLIENTEDGE)
	SetWindowPos (hWnd, 0, 0, 0, 0, 0, $$SWP_NOMOVE | $$SWP_NOSIZE | $$SWP_NOZORDER | $$SWP_FRAMECHANGED)

END FUNCTION
END PROGRAM
