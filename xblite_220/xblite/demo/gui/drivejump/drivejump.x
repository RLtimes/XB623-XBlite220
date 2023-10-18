'
'
' ####################
' #####  PROLOG  #####
' ####################

' Drive Jump is pop-up drive browser.
' Right click the program icon in the
' system tray and browse your drives.
' Uses GetDiskFreeSpaceExA to get free
' space available on diskdrives.
'
PROGRAM	"drivejump"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "shell32"		' shell32.dll"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  WndProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  BuildMenu ()

$$WM_SYSTEMTRAY = 1024

$$ID_EXIT  = 50
$$IDICON	 = 100
$$IDICONSM = 101
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

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

	SHARED hInst, className$

' register window class
	className$  = "DriveJump"
	addrWndProc = &WndProc()
	icon$ 			= "DJ"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create hidden window
	titleBar$  	= "DriveJump"
	style 			= $$WS_POPUP
	w 					= $$CW_USEDEFAULT
	h 					= $$CW_USEDEFAULT
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

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
  			TranslateMessage (&msg)						' translate virtual-key messages into character messages
  			DispatchMessageA (&msg)						' send message to window callback function WndProc()
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
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	POINT pt
	SHARED hInst
	STATIC NOTIFYICONDATA nid

	SELECT CASE msg

		CASE $$WM_CREATE :
' fill out NOTIFYICONDATA structure for system tray icon
			nid.cbSize           = SIZE (nid)
			nid.hWnd             = hWnd
			nid.uID              = 1
			nid.uFlags           = $$NIF_ICON |$$NIF_MESSAGE | $$NIF_TIP
			nid.uCallbackMessage = $$WM_SYSTEMTRAY
			nid.hIcon            = LoadIconA (hInst, $$IDICONSM)
			nid.szTip            = "Drive Jump"
			Shell_NotifyIconA ($$NIM_ADD, &nid)

		CASE $$WM_SYSTEMTRAY :
			SELECT CASE lParam
				CASE $$WM_RBUTTONUP :
					GetCursorPos (&pt)
					SetForegroundWindow (hWnd)
					hMenu = BuildMenu ()
					TrackPopupMenu (hMenu, $$TPM_LEFTALIGN, pt.x, pt.y, 0, hWnd, NULL)
					PostMessageA (hWnd, 0, 0, 0)
					DestroyMenu (hMenu)
			END SELECT

		CASE $$WM_COMMAND :
			item = LOWORD (wParam)
			SELECT CASE TRUE
' if item identifier is between 100 - 126 then
' user has clicked drive letter.

				CASE (item > 99 && item < 127) :
					drive$ = CHR$ (item - 35) + ":\\"
					ShellExecuteA (hWnd, &"open", &drive$, NULL, NULL, $$SW_SHOWDEFAULT)

				CASE item = $$ID_EXIT : DestroyWindow (hWnd)
			END SELECT

		CASE $$WM_DESTROY :
			DestroyIcon (nid.hIcon)
			PostQuitMessage (0)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT
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
' ##########################
' #####  BuildMenu ()  #####
' ##########################
'
' PURPOSE:       Create pop-up menu. Create menu of drives. If
'                drive is fixed (HD) or ramdrive it shows how many MB
'                are available, otherwise, it only shows drive letter.
' IN:            None
' OUT:           Handle of menu
' ERRORS:        Return NULL if something funny happened.

FUNCTION  BuildMenu ()

	GIANT fbac, tnob, tnfb
	FUNCADDR GetFreeDiskSpace (XLONG, XLONG, XLONG, XLONG)

	menu = CreatePopupMenu ()

' returns a bitmask representing the currently available disk drives.
	drives = GetLogicalDrives ()

'	hKernel = LoadLibraryA (&"kernel32.dll")
'	IFZ hKernel THEN RETURN
'	GetFreeDiskSpace = GetProcAddress (hKernel, &"GetDiskFreeSpaceExA")
'	IFZ GetFreeDiskSpace THEN
'		FreeLibrary (hKernel)
' 		RETURN
'	END IF

	FOR counter = 0 TO 25

		IF (drives & 1) THEN

			rootPath$ = CHR$ (65+counter) + ":\\"
			type = GetDriveTypeA (&rootPath$)

			IF (type == $$DRIVE_FIXED || type == $$DRIVE_RAMDISK) THEN

'				IFZ @GetFreeDiskSpace (&rootPath$, &fbac, &tnob, &tnfb) THEN
				IFZ GetDiskFreeSpaceExA (&rootPath$, &fbac, &tnob, &tnfb) THEN
					FreeLibrary (hKernel)
 					RETURN
				END IF

'PRINT "FreeBytesAvailableToCaller ="; fbac
'PRINT "TotalNumberOfBytes         ="; tnob
'PRINT "TotalNumberOfFreeBytes     ="; tnfb

				mByte =  fbac / (1024 * 1024)
				buf$ = CHR$ (65+counter) + ":\t" + STRING (mByte) + " MB"
			ELSE
				buf$ = CHR$ (65+counter) + ":"
			END IF

			IFZ InsertMenuA (menu, 0xFFFFFFFF, $$MF_BYPOSITION | $$MF_STRING, 100+counter, &buf$) THEN
				FreeLibrary (hKernel)
 				RETURN
			END IF

		END IF
		drives = drives >> 1
	NEXT counter

	FreeLibrary (hKernel)

	IFZ InsertMenuA (menu, 0xFFFFFFFF,MF_BYPOSITION | MF_SEPARATOR, 0, NULL) THEN RETURN
	IFZ InsertMenuA (menu, 200, $$MF_BYPOSITION | $$MF_STRING, $$ID_EXIT, &"Exit") THEN RETURN

	RETURN menu

END FUNCTION
END PROGRAM
