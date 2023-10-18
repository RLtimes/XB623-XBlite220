'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Use a font resource included as RCDATA in resource file.
'
PROGRAM	"fontresource"
VERSION	"0.0001"
'
	IMPORT	"xst_s.lib"   		' standard library	: required by most programs
	IMPORT  "xsx_s.lib"				' extended std library
'	IMPORT	"xio"				' console io library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll			: common controls library

DECLARE FUNCTION Entry            ()
DECLARE FUNCTION WndProc          (hwnd, msg, wParam, lParam)
DECLARE FUNCTION InitGui          ()
DECLARE FUNCTION RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION CreateWindows    ()
DECLARE FUNCTION NewWindow        (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION MessageLoop      ()
DECLARE FUNCTION CleanUp          ()
DECLARE FUNCTION LoadResData      (resName$, resID, @data$)
DECLARE FUNCTION GetTimeStamp     (@stamp$)
DECLARE FUNCTION NewFont          (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION SetNewFont       (hWnd, hFont)
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

	PAINTSTRUCT ps
	RECT rect
	POINT pt
	STATIC font$, hFont, fTrack, xi, yi

	SELECT CASE msg

		CASE $$WM_CREATE :
			font$ = "lcd.ttf"									' create font filename
			LoadResData ("", 100, @data$)			' load resource data into data$
			XstSaveString (@font$, @data$)		' save data$ to file font$
			ret = AddFontResourceA (&font$)		' add font to win32 font list
			IF ret THEN 
				SendMessageA ($$HWND_BROADCAST, $$WM_FONTCHANGE, 0, 0)
				hFont = NewFont ("Digital Readout Upright", 60, $$FW_NORMAL, 0, 0)
				ret = SetNewFont (hWnd, hFont)
			END IF
			SetTimer (hWnd, 1, 1000, 0)				' set timer id 1, 1000 ms time-out
			
'		CASE $$WM_CLOSE : DestroyWindow (hWnd)

		CASE $$WM_DESTROY :
			DeleteObject (hFont)
			RemoveFontResourceA (&font$)
			SendMessageA ($$HWND_BROADCAST, $$WM_FONTCHANGE, 0, 0)
			KillTimer (hWnd, 1)
			ret = XstDeleteFile (font$)
			PostQuitMessage(0)
			RETURN

		CASE $$WM_PAINT :
			hdc = BeginPaint (hWnd, &ps)
			GetTimeStamp (@stamp$)
			GetClientRect (hWnd, &rect)
			oldFont = SelectObject (hdc, hFont)
			hBrush = CreateSolidBrush (RGB(206, 221, 242))
			oldBrush = SelectObject (hdc, hBrush)
			SetTextColor (hdc, RGB(0, 0, 255))
			SetBkColor (hdc, RGB(206, 221, 242))
			ret = DrawTextA (hdc, &stamp$, LEN(stamp$), &rect, $$DT_VCENTER	| $$DT_CENTER)
			SelectObject (hdc, oldFont)
			SelectObject (hdc, oldBrush)
			DeleteObject (hBrush)
			EndPaint (hWnd, &ps)
			
		CASE $$WM_TIMER :
			InvalidateRect (hWnd, NULL, 1)
			UpdateWindow (hWnd)
			
		CASE $$WM_LBUTTONDOWN :
			fTrack = $$TRUE					' user has pressed the left button
			xi = LOWORD(lParam)			' initial x mouse position
			yi = HIWORD(lParam)			' initial y mouse position
			
		CASE $$WM_MOUSEMOVE:
			IF (fTrack) THEN
				xPos = LOWORD(lParam)  	' horizontal position of cursor 
				yPos = HIWORD(lParam)		' vertical position of cursor 
				pt.x = xPos
				pt.y = yPos
				ClientToScreen (hWnd, &pt)
				SetWindowPos (hWnd, 0, pt.x-xi, pt.y-yi, 0, 0, $$SWP_NOSIZE |	$$SWP_NOZORDER) 
			END IF
			
		CASE $$WM_LBUTTONUP:
			fTrack = $$FALSE

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
	wc.hbrBackground   = CreateSolidBrush (RGB(206, 221, 242)) 
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
	className$  = "lcdclock"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$ = "LCD Clock"
	style 		= $$WS_POPUPWINDOW
	w 				= 260
	h 				= 70
	exStyle		= 0
	hMain = NewWindow (@className$, @titleBar$, style, x, y, w, h, exStyle)
	IFZ hMain THEN RETURN ($$TRUE)

	XstCenterWindow (hMain)							' center window position
	ShowWindow (hMain, $$SW_SHOWNORMAL)	' show window

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
' ############################
' #####  LoadResData ()  #####
' ############################
'
'
' PURPOSE : Load resource data into a string buffer.
' Resource must be identified with type RCDATA in
' *.rc file.
' IN      : resName$ - resource name string
'         : resID - resource integer ID
' OUT     : data$ - returned resource data as string
' NOTE    : use either a resource string name or integer id, but not both!
' EXAMPLE : 100   RCDATA   "mygif.gif"
'         : agif  RCDATA   "mygif.gif"
' RETURN  : 0 on success, -1 on error
'
FUNCTION  LoadResData (resName$, resID, @data$)

  data$ = ""

' search for the resource
  IF resName$ THEN
    lpName = &resName$
  ELSE
    IF resID THEN
      lpName = resID
    ELSE
      RETURN ($$TRUE)
    END IF
  END IF

  hRes = FindResourceA (0, lpName, $$RT_RCDATA)
  IF (!hRes) THEN RETURN ($$TRUE)

' get the memory for the loaded resource
  memBlock = LoadResource (0, hRes)
  IF (!memBlock) THEN RETURN ($$TRUE)

' obtain the size for the resource
  sizeRes = SizeofResource (0, hRes)
  IF (!sizeRes) THEN RETURN ($$TRUE)

' get the memory location of the loaded resource
  pData = LockResource (memBlock)
  IF (!pData) THEN RETURN ($$TRUE)

' create a string buffer to hold data
  data$ = NULL$ (sizeRes)

' copy data to string buffer
  RtlMoveMemory (&data$, pData, sizeRes)

END FUNCTION
'
'
' ####################################
' #####  GetTimeAndDateStamp ()  #####
' ####################################
'
'
' PURPOSE : Return current date and time
' OUT     : stamp$  - current date and time
'
FUNCTION  GetTimeStamp (@stamp$)

	SYSTEMTIME st
	GetLocalTime (&st)
	stamp$ = RIGHT$("0" + STRING$(st.hour),2) + ":" +  RIGHT$("0" + STRING$(st.minute),2) + ":" + RIGHT$("0" + STRING$(st.second),2)

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
	lf.underline = underline										' set underline (0 or 1)
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
FUNCTION  SetNewFont (hWnd, hFont)

	SendMessageA (hWnd, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
END PROGRAM