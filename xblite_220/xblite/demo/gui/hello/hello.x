'
'
' ####################
' #####  PROLOG  #####
' ####################

' This is the most basic windows gui program that can
' be created using XBLite (other than just calling
' the MessageBox() function).

' The following ten steps describe how windows
' are created and how they function.

' ===================================================

' 1. get instance handle using GetModuleHandleA().
' 2. define class name and window title
' 3. fill in WNDCLASS struct, which gives the window
'    a particular style, callback function address,
'    backcolor, icon, cursor, and class name. All
'    windows created with this class name will all
'    have the same window properties and callback
'    procedure, WndProc().
' 4. register the window class using RegisterClassA().
' 5. create the window and get a window handle by
'    using CreateWindowExA()
' 6. optionally, center window position in display
' 7. display the window using ShowWindow(). You can
'    create many windows and show/hide them as needed
'    within your program.
' 8. begin a main message loop that runs continuously
'    while your program is running. it gets messages
'    from any user input from the keyboard or mouse
'    and sends them to your callback procedure.
'    Normally, you use GetMessageA(), TranslateMessage(),
'    and DispatchMessageA() to process all events in
'    the message queue. A PostQuitMessage() will cause
'    GetMessageA() to return 0 and indicate that the
'    message loop should be exited.
' 9. unregister the window class using UnregisterClassA().
' 10. a callback function WndProc() is used to process
'    or take action on all messages/events pertaining to
'    the main window. Messages are created based on user
'    events such as mouse movement or keyboard input.
'    Message examples include WM_CREATE, WM_PAINT,
'    WM_NOTIFY, WM_DESTROY, WM_KEYDOWN, etc.
'
PROGRAM	"hello"  		' 1-8 char program/file name without .x or any .extent
VERSION	"0.0002"    ' version number - increment before saving altered program
'
' Programs contain:  1: PROLOG          - no executable code - see below
'                    2: Entry function  - start execution at 1st declared func
' * = optional       3: Other functions - everything else - all other functions
'
' The PROLOG contains (in this order):
' * 1. Program name statement             PROGRAM "progname"
' * 2. Version number statement           VERSION "0.0000"
' * 3. Import library statements          IMPORT  "libName"
' * 4. Composite type definitions         TYPE <typename> ... END TYPE
'   5. Internal function declarations     DECLARE/INTERNAL FUNCTION Func (args)
' * 6. External function declarations     EXTERNAL FUNCTION FuncName (args)
' * 7. Shared constant definitions        $$ConstantName = literal or constant
' * 8. Shared variable declarations       SHARED  variable
'
' ******  Comment libraries in/out as needed  *****
'
'	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT  "xst_s.lib" ' Static version of xst.dll
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hWnd, msg, wParam, lParam)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	WNDCLASS wc
	MSG msg

' get instance handle
	hInst = GetModuleHandleA (0)

' define class name and window title
	className$  = "HelloDemo"
	caption$    = "Hello World"

' fill in WNDCLASS struct
	wc.style           = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_OWNDC
	wc.lpfnWndProc     = &WndProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"scrabble")		' load icon from resource file
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)			' use standard arrow cursor
	wc.hbrBackground   = GetStockObject ($$LTGRAY_BRUSH)	' paint window background gray
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &className$

' register window class
	IFZ RegisterClassA (&wc) THEN QUIT(0)

' create window
	hwnd = CreateWindowExA (0, &className$, &caption$, $$WS_OVERLAPPEDWINDOW, 0, 0, 200, 200, 0, 0, hInst, 0)
	IFZ hwnd THEN QUIT (0)

' center window position in display
	XstCenterWindow (hwnd)

' show window
	ShowWindow (hwnd, $$SW_SHOWNORMAL)

' main message loop
	DO
		SELECT CASE GetMessageA (&msg, 0, 0, 0)
			CASE  0 : EXIT DO					' RETURN msg.wParam
			CASE -1 : EXIT DO					' RETURN $$TRUE
			CASE ELSE:
  			TranslateMessage (&msg)
  			DispatchMessageA (&msg)
		END SELECT
	LOOP

' unregister window
	UnregisterClassA(&className$, hInst)

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
' This is the main window callback function
' All messages pertaining to the main window
' are sent to this function, eg, WM_CREATE,
' WM_PAINT, WM_NOTIFY, WM_DESTROY, etc.

FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	PAINTSTRUCT ps
	RECT wRect

	SELECT CASE msg

		CASE $$WM_PAINT:
			hdc = BeginPaint (hWnd, &ps)								' prepare window for painting, drawing, filling
			GetClientRect (hWnd, &wRect)								' get window rect
			SetBkColor (hdc, RGB(255, 255, 0))					' set text background color
			SetTextColor (hdc, RGB(255, 0, 0))					' set text color
			text$ = " Hello, XBLite for Windows! "
			style = $$DT_SINGLELINE OR $$DT_CENTER OR $$DT_VCENTER
			DrawTextA (hdc, &text$, -1, &wRect, style)	' draw text centered in window
			EndPaint (hWnd, &ps)												' finished painting window

		CASE $$WM_DESTROY:
			PostQuitMessage(0)

		CASE ELSE :
' The DefWindowProcA function calls the default window
' procedure to provide default processing for any window
' messages that an application does not process. This
' function ensures that every message is processed.
' DefWindowProc is called with the same parameters
' received by the window procedure.

		RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
END PROGRAM
