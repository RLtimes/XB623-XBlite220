'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Test the buttonex custom control.
'
PROGRAM	"dropbuttontest"
VERSION	"0.0000"
'
	IMPORT	"xst"   		' standard library	: required by most programs
'	IMPORT  "xsx"				' extended std library
'	IMPORT	"xio"				' console io library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll			: common controls library
'	IMPORT	"comdlg32"  ' comdlg32.dll	    : common dialog library
'	IMPORT	"xma"   		' math library			: Sin/Asin/Sinh/Asinh/Log/Exp/Sqrt...
'	IMPORT	"xcm"				' complex math library
'	IMPORT  "msvcrt"		' msvcrt.dll				: C function library
'	IMPORT  "shell32"   ' shell32.dll
	IMPORT  "dropbutton"
'
DECLARE FUNCTION Entry            ()
DECLARE FUNCTION WndProc          (hwnd, msg, wParam, lParam)
DECLARE FUNCTION InitGui          ()
DECLARE FUNCTION RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION CreateWindows    ()
DECLARE FUNCTION NewWindow        (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION NewChild         (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION MessageLoop      ()
DECLARE FUNCTION CleanUp          ()
DECLARE FUNCTION GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
'
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	STATIC	entry
'
	IF entry THEN RETURN							' enter once
	entry =  $$TRUE										' enter occured

'	XioCreateConsole (title$, 950)			' create console, if console is not wanted, comment out this line
	InitGui ()												' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create windows and other child controls
	MessageLoop ()										' the main message loop
	CleanUp ()												' unregister all window classes
'	XioFreeConsole ()									' free console

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION WndProc (hWnd, msg, wParam, lParam)

	PAINTSTRUCT ps
	RECT rect
	DROPBUTITEM dbi
	SHARED hInst
	
	$DropButton1 = 100
	$DropButton2 = 200

	SELECT CASE msg

		CASE $$WM_CREATE :
			
			' create first buttonex control
			hDropButton1 = NewChild ($$DROPBUTTONCLASSNAME, "Drop Button 1", 0, 20, 20, 180, 24, hWnd, $DropButton1, 0)

			' add popup box items
			FOR i = 1 TO 5				
				dbi.iCode = $DropButton1 + i
				sz$ = "Item No. " + STRING$(i)
				dbi.szLabel = &sz$
				SendMessageA (hDropButton1, $$DBM_APPENDITEM, 0, &dbi)
			NEXT i
			
			' create second buttonex control
			hDropButton2 = NewChild ($$DROPBUTTONCLASSNAME, "Drop Button 2", 0, 220, 20, 180, 24, hWnd, $DropButton2, 0)

			' add popup box items
			FOR i = 1 TO 10				
				dbi.iCode = $DropButton2 + i
				sz$ = "Item No. " + STRING$(i)
				dbi.szLabel = &sz$
				SendMessageA (hDropButton2, $$DBM_APPENDITEM, 0, &dbi)
			NEXT i
			
			SetFocus (hDropButton1)

		CASE $$WM_COMMAND :
			id = LOWORD(wParam)
			hWndCtl = lParam
			text$ = " Drop Button Selection id: " + STRING$(id)
			MessageBoxA (hWnd, &text$, &"ButtonEx Control Pressed", 0) 
			SetFocus (hWndCtl)
			
		
'		CASE $$WM_NOTIFY :
'			PRINT "WM_NOTIFY"
'			GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
'			PRINT idFrom, code
			
		CASE $$WM_DESTROY :
			PostQuitMessage(0)
			
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
FUNCTION InitGui ()

	SHARED hInst
	hInst = GetModuleHandleA (0) 	' get current instance handle
	IFZ hInst THEN QUIT (0)
	InitCommonControls ()					' initialize comctl32.dll library

END FUNCTION
'
'
' #################################
' #####  RegisterWinClass ()  #####
' #################################
'
FUNCTION RegisterWinClass (className$, addrWndProc, icon$, menu$)

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
FUNCTION CreateWindows ()

' register window class
	className$  = "DropButtonTestClass"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$ = "Test DropButton Controls"
	style 		= $$WS_OVERLAPPEDWINDOW
	w 				= 430
	h 				= 300
	exStyle		= 0
	#winMain = NewWindow (@className$, @titleBar$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window
	UpdateWindow (#winMain)

END FUNCTION
'
'
' ##########################
' #####  NewWindow ()  #####
' ##########################
'
FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

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

	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION MessageLoop ()

	MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
				hwnd = GetActiveWindow ()
				IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN		' send only non-dialog messages
  				TranslateMessage (&msg)					' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)					' send message to window callback function WndProc()
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
FUNCTION CleanUp ()

	SHARED hInst, className$

	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' #############################
' #####  GetNotifyMsg ()  #####
' #############################
'
FUNCTION GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

	NMHDR nmhdr
	nmhdrAddr = lParam
'	XstCopyMemory (nmhdrAddr, &nmhdr, SIZE(nmhdr))	'Xsx library function
	RtlMoveMemory (&nmhdr, nmhdrAddr, SIZE(nmhdr))	'kernel32 library function
	hwndFrom = nmhdr.hwndFrom
	idFrom   = nmhdr.idFrom
	code     = nmhdr.code

END FUNCTION

END PROGRAM