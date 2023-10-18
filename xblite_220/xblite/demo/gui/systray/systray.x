'
'
' ####################
' #####  PROLOG  #####
' ####################

' A program which manipulates an icon in the system
' task tray. It displays a dialog box window which
' allows the user to pick the icon to be used in
' the task bar.
'
PROGRAM	"systray"
VERSION	"0.0002"
'	MAKEFILE "xexe.xxx"	' use custom template to include xb.dll object files
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  DialogProc (hDlg, msg, wParam, lParam)

$$WM_TRAYICON = 1424

'Control IDs
$$Button1  = 101
$$Button2  = 102
$$Button3  = 103
$$Button4  = 104
$$Button5  = 105

$$PopMenuExit = 106
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

	hInst = GetModuleHandleA (0) 	' get current instance handle
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

' create main window

	#hDlg = DialogBoxParamA (hInst, 100, $$HWND_DESKTOP, &DialogProc(), NULL)
	IFZ #hDlg THEN RETURN ($$TRUE)

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

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  				TranslateMessage (&msg)						' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)						' send message to window callback function WndProc()
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
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  DialogProc (hDlg, msg, wParam, lParam)

	STATIC hMenu
	STATIC NOTIFYICONDATA nid
	STATIC POINT pt
	SHARED hInst

	SELECT CASE msg

    CASE $$WM_INITDIALOG :
' ** Get Menu Handle
			hMenu = GetSubMenu (LoadMenuA (hInst, &"POPUPMENU"), 0)

' ** Add tray icon
			nid.cbSize           = SIZE (nid)
			nid.hWnd             = hDlg
			nid.uID              = hInst
			nid.uFlags           = $$NIF_ICON |$$NIF_MESSAGE | $$NIF_TIP
			nid.uCallbackMessage = $$WM_TRAYICON
			nid.hIcon            = LoadIconA (hInst, &"FACE1")
			nid.szTip            = "Task Tray Example"
			Shell_NotifyIconA ($$NIM_ADD, &nid)
			DestroyIcon (nid.hIcon)

			XstCenterWindow (hDlg)

		CASE $$WM_TRAYICON :
			SELECT CASE LOWORD (lParam)

' ** Left button press
				CASE $$WM_LBUTTONDOWN :	ShowWindow (hDlg, $$SW_SHOW)

' ** Right button press
				CASE $$WM_RBUTTONDOWN :
					SetForegroundWindow (hDlg)
					GetCursorPos (&pt)
					TrackPopupMenuEx (hMenu, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, hDlg, 0)

			END SELECT

		CASE $$WM_DESTROY :
' ** Remove the tray icon if the application is closed
			Shell_NotifyIconA ($$NIM_DELETE, &nid)		' delete the taskbar icon
			DestroyMenu (hMenu)												' delete the pop-up menu
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			SELECT CASE LOWORD (wParam)

				CASE 101, 102, 103, 104, 105 :
' ** change tray icon
					icon$ = "face" + STRING$(LOWORD(wParam)-100)
					nid.hIcon = LoadIconA (hInst, &icon$)
					Shell_NotifyIconA ($$NIM_MODIFY, &nid)
					DestroyIcon (nid.hIcon)

				CASE $$PopMenuExit :
' ** Make sure they want to exit
					IF MessageBoxA (hDlg, &"Close Tray Example and remove its icon from the task tray?", &"Tray Example", $$MB_ICONEXCLAMATION | $$MB_OKCANCEL) = $$IDOK THEN
						EndDialog (hDlg, 0)
					END IF

			END SELECT

		CASE $$WM_SYSCOMMAND :

' ** If either the minimize or close buttons are pressed, hide the
'    window so it doesn't appear in the task bar.

			SELECT CASE wParam

				CASE $$SC_MINIMIZE :
					ShowWindow (hDlg, $$SW_HIDE)

				CASE $$SC_CLOSE :
					ShowWindow (hDlg, $$SW_HIDE)

			END SELECT

		CASE ELSE : RETURN ($$FALSE)

	END SELECT

	RETURN ($$TRUE)

END FUNCTION
END PROGRAM
