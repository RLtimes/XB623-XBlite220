'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A scrolling marquee.
' This simple version is double-buffered.
'
PROGRAM	"marquee1"
VERSION	"0.0000"
'
	IMPORT	"xst"   		' standard library	: required by most programs
'	IMPORT  "xsx"				' extended std library
'	IMPORT	"xio"				' console io library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll			: common controls library
	IMPORT  "xbm"
		
'	IMPORT	"comdlg32"  ' comdlg32.dll	    : common dialog library
'	IMPORT	"xma"   		' math library			: Sin/Asin/Sinh/Asinh/Log/Exp/Sqrt...
'	IMPORT	"xcm"				' complex math library
'	IMPORT  "msvcrt"		' msvcrt.dll				: C function library
'	IMPORT  "shell32"   ' shell32.dll
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
DECLARE FUNCTION GetNotifyMsg     (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION NewFont          (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION SetNewFont       (hwndCtl, hFont)
DECLARE FUNCTION DrawBackGround   (hBmp, color, mode)
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

'	XioCreateConsole (title$, 50)			' create console, if console is not wanted, comment out this line
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

	$STATIC = 1

	PAINTSTRUCT ps
	RECT rect
	SHARED hStatic, hFont
	DRAWITEMSTRUCT dis
	TEXTMETRIC tm
	SHARED text$
	SHARED xScroll
	SIZEAPI size
	SHARED speed
	SHARED hBackGrnd, hCanvas
	
	speed = 1

	SELECT CASE msg

		CASE $$WM_CREATE :
			text$ = "A Scrolling Marquee Control"
			hStatic = NewChild ("static", "", $$SS_OWNERDRAW, 0, 0, 0, 0, hWnd, $$STATIC, exStyle)
			hFont = NewFont ("Times New Roman", 10, $$FW_NORMAL	, italic, underline)
'			SetNewFont (hStatic, hFont)
			
			IFZ SetTimer (hWnd, 1, 25, 0)  THEN
				MessageBoxA (hWnd, &"Timer Error", &"Error", $$MB_OK)
				PostQuitMessage (0)
			END IF
			
		CASE $$WM_TIMER:
			' update static control with text movement
			InvalidateRect (hStatic, NULL, 0)
			UpdateWindow (hStatic)
			
		CASE $$WM_DRAWITEM:
			idCtl = wParam
			RtlMoveMemory (&dis, lParam, SIZE(dis))
'			hdc = dis.hDC

			IF dis.CtlType <> $$ODT_STATIC THEN RETURN	 
			
			' get canvas hdc and select hCanvas into hdc
			hdcCanvas = CreateCompatibleDC (0) 
			
			' set transparent mode
			SetBkMode (hdcCanvas, $$TRANSPARENT)
			
			' select font into canvas
			SelectObject (hdcCanvas, hFont)

			' make sure text will fill up control width
			GetTextExtentPoint32A (hdcCanvas, &text$, LEN(text$), &size)
			textSize = size.cx
			
			' draw text
			GetTextMetricsA (hdcCanvas, &tm)				
			y = dis.rcItem.bottom/2 - tm.height/2
			
			' copy background to canvas
			XbmCopyImage (hCanvas, hBackGrnd)
			
			' draw text onto canvas
			prevObject = SelectObject (hdcCanvas, hCanvas)
			
			TextOutA (hdcCanvas, xScroll+dis.rcItem.right, y, &text$, LEN(text$))
			
			SelectObject (prevObject, hCanvas)
			DeleteDC (hdcCanvas)
			
			' copy canvas to static control
			XbmCopyImage (hStatic, hCanvas)
		
			xScroll = xScroll - speed
			
			IF ABS(xScroll) >= textSize + dis.rcItem.right THEN xScroll = 0 
			
			RETURN (1)
				

		CASE $$WM_DESTROY :
			DeleteObject (hFont)
			PostQuitMessage(0)

'		CASE $$WM_PAINT :
'			hdc = BeginPaint (hWnd, &ps)
'			EndPaint (hWnd, &ps)

		CASE $$WM_SIZE :
			w = LOWORD (lParam)
			h = HIWORD (lParam)
			MoveWindow (hStatic, 0, 0, w, h, 1)	
			
			' bitmap to hold background picture
			IF hBackBrnd THEN XbmDeleteMemBitmap (hBackGrnd) 
			XbmCreateMemBitmap (hWnd, w, h, @hBackGrnd) 

			DrawBackGround (hBackGrnd, RGB(127,255,127), mode) 
			
			' canvas to copy to screen
			IF hCanvas THEN XbmDeleteMemBitmap (hCanvas) 
			XbmCreateMemBitmap (hWnd, w, h, @hCanvas)
			
			SetNewFont (hCanvas, hFont)


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
	className$  = "MarqueeWindow"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$ = "Marquee Text"
	style 		= $$WS_OVERLAPPEDWINDOW
	w 				= 500
	h 				= 80
	exStyle		= 0
	#winMain = NewWindow (@className$, @titleBar$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

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
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA(hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underline
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle


END FUNCTION
'
'
' ###########################
' #####  SetNewFont ()  #####
' ###########################
'
FUNCTION  SetNewFont (hwndCtl, hFont)

	SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
'
' ############################
' #####  DrawBackGround  #####
' ############################
'
'
'
FUNCTION DrawBackGround (hBmp, color, mode)

	LOGBRUSH lb
	
	hdc = CreateCompatibleDC (0) 
	prevObject = SelectObject (hdc, hBmp)
	XbmGetImageSize (hBmp, @w, @h)

	IFZ mode THEN
	' paint background color
		lb.style = $$BS_SOLID	
		lb.color = color
		hbrush = CreateBrushIndirect (&lb)
		SelectObject (hdc, hbrush)
		PatBlt (hdc, 0, 0, w, h, $$PATCOPY)
		DeleteObject (hbrush)
	END IF
	
	SelectObject (prevObject, hBmp)
	DeleteDC (hdc)

END FUNCTION
END PROGRAM