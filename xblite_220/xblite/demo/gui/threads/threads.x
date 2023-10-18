'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo to create and run two thread processes.
' Both threads appear to execute concurrently.
' This demo also uses accelerator key resources.
'
PROGRAM	"threads"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
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
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  MyThread1 (param)
DECLARE FUNCTION  MyThread2 (param)
'
$$MAX = 2000
$$PAUSE1 = 5
'
'Control IDs
$$IDM_THREAD    = 100
$$IDM_HELP      = 101
$$IDM_EXIT      = 102
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

	PAINTSTRUCT ps
	RECT wRect
	SHARED str$

	SELECT CASE msg

		CASE $$WM_CREATE:
			str$ = NULL$(255)								' for output strings

		CASE $$WM_DESTROY:
			PostQuitMessage (0)

		CASE $$WM_COMMAND :
			id = LOWORD (wParam)
			SELECT CASE id
				CASE $$IDM_THREAD :
					#hThread1 = CreateThread (NULL, 0, &MyThread1(), hWnd, 0, &tid1)
					#hThread2 = CreateThread (NULL, 0, &MyThread2(), hWnd, 0, &tid2)

				CASE $$IDM_EXIT :
					response = MessageBoxA (hWnd, &"Quit the Program?", &"Exit", $$MB_YESNO)
					IF response = $$IDYES THEN PostQuitMessage (0)

				CASE $$IDM_HELP :
					MessageBoxA (hWnd, &"F1: Help\nF2: Start Threads", &"Help", $$MB_OK)

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

	hInst = GetModuleHandleA (0) 	' get current instance handle
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
	wc.hbrBackground   = GetStockObject ($$WHITE_BRUSH)
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

	SHARED hInst, className$

' register window class
	className$  = "ThreadDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "ThreadMenu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Demonstrate Threads."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 300
	h 					= 250
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	#hAccel = LoadAcceleratorsA (hInst, &"ThreadMenu")

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

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

		hWnd = GetActiveWindow ()
		IF !(TranslateAcceleratorA (hWnd, #hAccel, &msg)) THEN
			SELECT CASE ret
				CASE  0 : RETURN msg.wParam					' WM_QUIT message
				CASE -1 : RETURN $$TRUE							' error
				CASE ELSE:
  				TranslateMessage (&msg)						' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)						' send message to window callback function WndProc()
			END SELECT
		END IF
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
' ##########################
' #####  MyThread1 ()  #####
' ##########################
'
' A thread of execution within the current process.
'
FUNCTION  MyThread1 (param)

	SHARED str$

	FOR i = 0 TO $$MAX

		wsprintfA (&str$, &"Thread 1: loop # %5d ", i)
		text$ = CSIZE$ (str$)
		hdc = GetDC (param)
		TextOutA (hdc, 1, 1, &text$, LEN (text$))
		ReleaseDC (param, hdc)
		Sleep ($$PAUSE1)

	NEXT i

END FUNCTION
'
'
' ##########################
' #####  MyThread2 ()  #####
' ##########################
'
' A thread of execution within the current process.
'
FUNCTION  MyThread2 (param)

	SHARED str$

	FOR i = 0 TO $$MAX

		wsprintfA (&str$, &"Thread 2: loop # %5d ", i)
		text$ = CSIZE$ (str$)
		hdc = GetDC (param)
		TextOutA (hdc, 1, 20, &text$, LEN (text$))
		ReleaseDC (param, hdc)
		Sleep ($$PAUSE1)

	NEXT i

END FUNCTION
END PROGRAM
