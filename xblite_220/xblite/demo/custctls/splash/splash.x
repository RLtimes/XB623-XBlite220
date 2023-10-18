'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This custom splash screen control creates
' an independent window that displays a resource
' bmp image for a limited time.
' ---
' Static controls are used to display a resource
' bitmap and optionally, to display a brief message
' below the bitmap. The static text can be used
' to indicate progress during some operation.
' ---
' The splashscreen window is run from a separate
' thread with its own message loop so the calling
' program continues in the background while the
' splash window is displayed.
' ---
' To use this control, just IMPORT "splashctl"
' in your PROLOG. The programmer can then create
' multiple instances of this control just like
' any other Win32 common control.
' ---
' The splash class name is:
' $$SPLASHCTLCLASSNAME = "splashctl"
' ---
' See splashtest.x
' ---
' (c) 2002 GPL David SZAFRANSKI
' dszafranski@wanadoo.fr

PROGRAM	"splash"
VERSION	"0.0002"

	IMPORT	"xst"
	IMPORT  "gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"

' *****************************
' ***** Type Declarations *****
' *****************************

TYPE SPLASHINFO
	STRING*128	.resName				' name of bitmap resource
	XLONG	.timerId							' id number for splash window timer
	XLONG	.txtColor							' message text color
	XLONG	.bkColor							' message back color
	STRING*512	.text						' message text
	XLONG	.msgHeight						' height of static text child control (default = 22)
	XLONG	.hStatic1							' static bitmap handle
	XLONG	.hStatic2							' static text handle
END TYPE

TYPE SPLASHMAINARGS
	STRING*128	.resName				' name of bitmap resource
	XLONG	.delay
	XLONG	.fDone
	XLONG	.hWnd
	XLONG	.txtColor							' message text color
	XLONG	.bkColor							' message back color
	STRING*512	.text						' message text
	XLONG	.msgHeight						' height of static text child control
END TYPE

TYPE SPLASHCREATEPARAMS
	STRING*128	.resName				' name of bitmap resource
	XLONG	.delay								' time to display window in msecs
	XLONG	.txtColor							' message text color
	XLONG	.bkColor							' message back color
	STRING*512	.text						' message text
	XLONG	.msgHeight						' height of static text child control
END TYPE

EXPORT
DECLARE FUNCTION  Splash							()
END EXPORT

' internal functions

DECLARE FUNCTION  CenterWindow (hWnd)
DECLARE FUNCTION  SplashMain (splashMainArgsAddr)
DECLARE FUNCTION  RegisterSplashClass ()
DECLARE FUNCTION  SplashIsRunning (hWnd)
INTERNAL FUNCTION  SplashProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  GetSplashInfo (hWnd, SPLASHINFO spinfo)
DECLARE FUNCTION  SetSplashInfo (hWnd, SPLASHINFO spinfo)
DECLARE FUNCTION  CreateSplash (resName$, delay, msg$, msgHeight, textColor, backColor)

EXPORT

' user functions

DECLARE FUNCTION  KillSplash 					(hWnd)
DECLARE FUNCTION  RunSplash 					(resName$, delay, msg$, msgHeight, textColor, backColor)
DECLARE FUNCTION  SetSplashText 			(hWnd, text$)
DECLARE FUNCTION  SetSplashTextFont 	(hWnd, hFont)
'
' splitter class name
$$SPLASHCTLCLASSNAME = "splashctl"
'
' define custom window messages
$$WM_KILLSPLASH     							= 1025		' destroy splash window
$$WM_SETSPLASHTEXTFONT 						= 1026		' lParam = font handle
$$WM_SETSPLASHTEXT								= 1027		' wParam = text length, lParam = address of text string
END EXPORT
'
$$SPLASH_TIMER = 1
'
'
' #######################
' #####  Splash ()  #####
' #######################
'
'
FUNCTION  Splash ()

	IF LIBRARY(0) THEN RETURN

END FUNCTION
'
'
' #############################
' #####  CenterWindow ()  #####
' #############################
'
FUNCTION  CenterWindow (hWnd)

	RECT wRect

	GetWindowRect (hWnd, &wRect)
	#screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	#screenHeight = GetSystemMetrics ($$SM_CYSCREEN)
	x = (#screenWidth - (wRect.right - wRect.left))/2
	y = (#screenHeight - (wRect.bottom - wRect.top))/2
	SetWindowPos (hWnd, 0, x, y, 0, 0, $$SWP_NOSIZE OR $$SWP_NOZORDER)

END FUNCTION
'
'
' ###########################
' #####  SplashMain ()  #####
' ###########################
'
FUNCTION  SplashMain (splashMainArgsAddr)

	SPLASHMAINARGS args
	MSG msg

	RtlMoveMemory (&args, splashMainArgsAddr, SIZE(SPLASHMAINARGS))

	hWnd = CreateSplash (args.resName, args.delay, args.text, args.msgHeight, args.txtColor, args.bkColor)
	IFZ hWnd THEN
		args.hWnd 	= 0
		args.fDone 	= $$TRUE
		exitCode 		= 0
		hThread 		= GetCurrentThread ()
		GetExitCodeThread (hThread, &exitCode)
'		ExitThread (exitCode)
		RETURN exitCode
	END IF

	CenterWindow (hWnd)									' center window position
	ShowWindow (hWnd, $$SW_SHOWNORMAL)	' show window

	args.hWnd  = hWnd
	args.fDone = $$TRUE
	RtlMoveMemory (splashMainArgsAddr, &args, SIZE(SPLASHMAINARGS))

	fGotMsg = GetMessageA (&msg, 0, 0, 0)
	DO WHILE (fGotMsg)
		IF (fGotMsg == -1) THEN EXIT DO
		DispatchMessageA (&msg)
		fGotMsg = GetMessageA (&msg, 0, 0, 0)
	LOOP

	exitCode = 0
	hThread  = GetCurrentThread ()
	ret = GetExitCodeThread (hThread, &exitCode)
'	ExitThread (exitCode)
	RETURN exitCode

END FUNCTION
'
'
' ####################################
' #####  RegisterSplashClass ()  #####
' ####################################
'
FUNCTION  RegisterSplashClass ()

	WNDCLASS wc

' only register this class once
	hInst = GetModuleHandleA (0)
	IF (!GetClassInfoA (hInst, &"splashctl", &wc)) THEN

' fill in WNDCLASS struct
		wc.style           = $$CS_GLOBALCLASS | $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
		wc.lpfnWndProc     = &SplashProc()										' splash control callback function
		wc.cbClsExtra      = 0
		wc.cbWndExtra      = 4																' space for a pointer to a SPLASHINFO struct
		wc.hInstance       = GetModuleHandleA (0)							' get current instance handle
		wc.hIcon           = 0
		wc.hCursor         = 0
		wc.hbrBackground   = GetStockObject ($$NULL_BRUSH)
		wc.lpszMenuName    = 0
		wc.lpszClassName   = &"splashctl"

' register window class
		RETURN (RegisterClassA (&wc) != 0)
	END IF
	RETURN ($$TRUE)


END FUNCTION
'
'
' ################################
' #####  SplashIsRunning ()  #####
' ################################
'
FUNCTION  SplashIsRunning (hWnd)

	RETURN IsWindow (hWnd)

END FUNCTION
'
'
' ###########################
' #####  SplashProc ()  #####
' ###########################
'
FUNCTION  SplashProc (hWnd, msg, wParam, lParam)

	CREATESTRUCT cs
	RECT rect
	SPLASHINFO splashinfo
	SPLASHCREATEPARAMS cp
	STATIC hNewBrush

	SELECT CASE msg

		CASE $$WM_CREATE:
' create the heap for this instance of the class and
' allocate heap for the SPLASHINFO struct
			hHeap = GetProcessHeap ()
			pData = HeapAlloc (hHeap, $$HEAP_ZERO_MEMORY, SIZE(SPLASHINFO))
			IFZ pData THEN RETURN 0

' store this data pointer in class data area

			ret = SetWindowLongA (hWnd, $$GWL_USERDATA, pData)

' get data in createstruct from pointer lParam
			RtlMoveMemory (&cs, lParam, SIZE(CREATESTRUCT))

' get createParams info
			RtlMoveMemory (&cp, cs.lpCreateParams, SIZE(SPLASHCREATEPARAMS))

' initialize default SPASHINFO struct
			splashinfo.resName 	= cp.resName					' name of bitmap resource
			IF cp.txtColor = -1 THEN
				splashinfo.txtColor = RGB(255,255,255)	' default = white
			ELSE
				splashinfo.txtColor = cp.txtColor				' message text color
			END IF
			IF cp.bkColor = -1 THEN
				splashinfo.bkColor = 0									' default = black
			ELSE
				splashinfo.bkColor = cp.bkColor					' message back color
			END IF
			splashinfo.text			 = cp.text						' message text
			splashinfo.msgHeight = cp.msgHeight				' text static control height
			splashinfo.hStatic1  = 0									' static control handle for bitmap
			splashinfo.hStatic2  = 0									' static control handle for text

' add two static controls to use to display image and text message
' they will be resized in WM_SIZE

			hInst = GetModuleHandleA (0)												' get current instance handle

			IF cp.resName THEN
				text$ = TRIM$(cp.resName)
				style = $$SS_BITMAP | $$WS_CHILD | $$WS_VISIBLE
				splashinfo.hStatic1 = CreateWindowExA (0, &"static", &text$, style, 0, 0, 0, 0, hWnd, 0, hInst, 0)
				IFZ splashinfo.hStatic1 THEN
					HeapFree (hHeap, 0, pData)					' free the heap
					RETURN ($$TRUE)
				END IF
				fImage = $$TRUE
			END IF

			IF cp.text THEN
				text$ = cp.text
				style = $$SS_LEFT | $$WS_CHILD | $$WS_VISIBLE
				splashinfo.hStatic2 = CreateWindowExA ($$WS_EX_STATICEDGE, &"static", &text$, style, 0, 0, 0, 0, hWnd, 0, hInst, 0)
				IFZ splashinfo.hStatic2 THEN
					HeapFree (hHeap, 0, pData)					' free the heap
					RETURN ($$TRUE)
				END IF
				fMsg = $$TRUE
			END IF

			IF cp.delay > 0 THEN										' start timer
				splashinfo.timerId = SetTimer (hWnd, $$SPLASH_TIMER, cp.delay, 0)
				IFZ splashinfo.timerId THEN
					HeapFree (hHeap, 0, pData)					' free the heap
					RETURN ($$TRUE)
				END IF
			END IF

' save current splash info
			SetSplashInfo (hWnd, splashinfo)

			RETURN 0

		CASE $$WM_DESTROY:
			GetSplashInfo (hWnd, splashinfo)
			IF splashinfo.timerId THEN KillTimer (hWnd, splashinfo.timerId)
			hHeap = GetProcessHeap ()
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			IF pData THEN HeapFree (hHeap, 0, pData)				' free the heap created in WM_CREATE
			DeleteObject (hNewBrush)
			PostQuitMessage (0)
			RETURN 0

		CASE $$WM_SIZE :
			sizeType = wParam
			width = LOWORD (lParam)
			height = HIWORD (lParam)
			IF sizeType = $$SIZE_RESTORED THEN
				GetSplashInfo (hWnd, @splashinfo)
				IF splashinfo.hStatic1 THEN							' we have an image so now resize window to fit
					GetClientRect (splashinfo.hStatic1, &rect)
					w = rect.right
					h = rect.bottom
					IF splashinfo.hStatic2 THEN
						MoveWindow (splashinfo.hStatic2, 0, h, w, splashinfo.msgHeight, 1)
						h = h + splashinfo.msgHeight
					END IF
					w = w + 6
					h = h + 6
					ret = MoveWindow (hWnd, 0, 0, w, h, 1)				' resize main window
				END IF
			END IF

			CenterWindow (hWnd)
			RETURN 0

		CASE $$WM_SETSPLASHTEXTFONT :
			IFZ lParam THEN RETURN 0
			GetSplashInfo (hWnd, @splashinfo)
			ret = SendMessageA (splashinfo.hStatic2, $$WM_SETFONT, lParam, $$TRUE)
			InvalidateRect (splashinfo.hStatic2, 0, $$TRUE)
			UpdateWindow (splashinfo.hStatic2)
			RETURN 0

		CASE $$WM_SETSPLASHTEXT :
			IFZ lParam THEN RETURN 0
			text$ = NULL$(wParam)
			RtlMoveMemory (&text$, lParam, wParam)
			GetSplashInfo (hWnd, @splashinfo)
			SetWindowTextA (splashinfo.hStatic2, &text$)
			RETURN 0

		CASE $$WM_KILLSPLASH :
			IF (SplashIsRunning (hWnd)) THEN DestroyWindow (hWnd)
			RETURN 0

		CASE $$WM_TIMER :
			timerId = wParam
			IF timerId = $$SPLASH_TIMER THEN
				DestroyWindow (hWnd)
			END IF
			RETURN 0


		CASE $$WM_CTLCOLORSTATIC :							' set static control background color
			GetSplashInfo (hWnd, @splashinfo)
			SetBkColor (wParam, splashinfo.bkColor)
			SetTextColor (wParam, splashinfo.txtColor)
			hNewBrush = CreateSolidBrush (splashinfo.bkColor)
			RETURN hNewBrush

	END SELECT

' The DefWindowProcA function calls the default window
' procedure to provide default processing for any window
' messages that an application does not process. This
' function ensures that every message is processed.
' DefWindowProc is called with the same parameters
' received by the window procedure.

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
'
' ##############################
' #####  GetSplashInfo ()  #####
' ##############################
'
FUNCTION  GetSplashInfo (hWnd, SPLASHINFO spinfo)

	pData = GetWindowLongA (hWnd, $$GWL_USERDATA)				' get splash data pointer
	IF pData THEN
		RtlMoveMemory (&spinfo, pData, SIZE(SPLASHINFO))
		RETURN 0
	END IF
	RETURN ($$TRUE)

END FUNCTION
'
'
' ##############################
' #####  SetSplashInfo ()  #####
' ##############################
'
FUNCTION  SetSplashInfo (hWnd, SPLASHINFO spinfo)

	pData = GetWindowLongA (hWnd, $$GWL_USERDATA)				' get splash data pointer
	IF pData THEN RtlMoveMemory (pData, &spinfo, SIZE(SPLASHINFO))		' copy spinfo to storage

END FUNCTION
'
'
' #############################
' #####  CreateSplash ()  #####
' #############################
'
FUNCTION  CreateSplash (resName$, delay, msg$, msgHeight, textColor, backColor)

	SPLASHCREATEPARAMS createParams

	createParams.resName 		= resName$
	createParams.delay 			= delay
	createParams.txtColor 	= textColor
	createParams.bkColor  	= backColor
	createParams.text 			= msg$
	createParams.msgHeight	= msgHeight

	hInst = GetModuleHandleA (0)			' get current instance handle
	RETURN CreateWindowExA ($$WS_EX_TOPMOST | $$WS_EX_DLGMODALFRAME, &$$SPLASHCTLCLASSNAME, 0, $$WS_POPUP | $$WS_DISABLED, 0, 0, 50, 50, 0, 0, hInst, &createParams)

END FUNCTION
'
'
' ###########################
' #####  KillSplash ()  #####
' ###########################
'
FUNCTION  KillSplash (hWnd)

	IF (SplashIsRunning (hWnd)) THEN
		PostMessageA (hWnd, $$WM_KILLSPLASH, 0, 0)
	END IF

END FUNCTION
'
'
' ##########################
' #####  RunSplash ()  #####
' ##########################
'
FUNCTION  RunSplash (resName$, delay, msg$, msgHeight, textColor, backColor)

	SPLASHMAINARGS smargs

	IFZ delay THEN RETURN 0
	IF resName$ = "" && msg$ = "" THEN RETURN 0
	IF textColor = 0 && backColor = 0 THEN
		textColor = -1
		backColor = -1
	END IF

' register the splash control
	IF (!RegisterSplashClass ()) THEN RETURN 0

' create the Splash as a pop-up window, with its own
' message loop in a separate thread

	smargs.resName	= resName$
	smargs.delay		= delay
	smargs.fDone 		= $$FALSE
	smargs.hWnd 		= 0
	smargs.txtColor = textColor
	smargs.bkColor  = backColor
	smargs.text			= msg$
	IFZ msgHeight THEN
		smargs.msgHeight = 22				' set default msg text box height
	ELSE
		smargs.msgHeight = msgHeight
	END IF

	threadId = 0
	hThread = CreateThread (0, 2000, &SplashMain(), &smargs, 0, &threadId)

' wait for the thread to create the new window handle
	DO UNTIL (smargs.fDone)
	LOOP

	IF hThread THEN	CloseHandle (hThread)

	RETURN smargs.hWnd

END FUNCTION
'
'
' ##############################
' #####  SetSplashText ()  #####
' ##############################
'
FUNCTION  SetSplashText (hWnd, text$)

	IF (SplashIsRunning (hWnd)) THEN
		SendMessageA (hWnd, $$WM_SETSPLASHTEXT, LEN(text$), &text$)
	END IF


END FUNCTION
'
'
' ##################################
' #####  SetSplashTextFont ()  #####
' ##################################
'
FUNCTION  SetSplashTextFont (hWnd, hFont)

	IF (SplashIsRunning (hWnd)) THEN
		SendMessageA (hWnd, $$WM_SETSPLASHTEXTFONT, 0, hFont)
	END IF

END FUNCTION
END PROGRAM
