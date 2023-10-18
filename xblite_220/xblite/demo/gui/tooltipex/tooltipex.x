' 
' 
' ####################
' #####  PROLOG  #####
' ####################
' 
' Custom tooltip example.
' 
PROGRAM "tooltipex"
VERSION "0.0000"
' 
IMPORT "xst"		' standard library	: required by most programs
' IMPORT  "xsx"				' extended std library
' IMPORT	"xio"				' console io library
IMPORT "gdi32"		' gdi32.dll
IMPORT "user32"		' user32.dll
IMPORT "kernel32"		' kernel32.dll
IMPORT "comctl32"		' comctl32.dll			: common controls library
' IMPORT	"comdlg32"  ' comdlg32.dll	    : common dialog library
' IMPORT	"xma"   		' math library			: Sin/Asin/Sinh/Asinh/Log/Exp/Sqrt...
' IMPORT	"xcm"				' complex math library
' IMPORT  "msvcrt"		' msvcrt.dll				: C function library
' IMPORT  "shell32"   ' shell32.dll
' 
DECLARE FUNCTION Entry ()
DECLARE FUNCTION WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION InitGui ()
DECLARE FUNCTION RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION CreateWindows ()
DECLARE FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION MessageLoop ()
DECLARE FUNCTION CleanUp ()
' 
' custom tooltip functions
DECLARE FUNCTION AddCustomToolTip (hCtl, ToolTipText$, hParent)
DECLARE FUNCTION ToolTip_DrawBalloon (hwndTip, hdc, szText$)
DECLARE FUNCTION CustomTipProc (hWnd, msg, wParam, lParam)
' 
' 
' 
' ######################
' #####  Entry ()  #####
' ######################
' 
FUNCTION Entry ()

	STATIC entry

	IF entry THEN RETURN		' enter once
	entry = $$TRUE		' enter occured

	InitGui ()
	IF CreateWindows () THEN QUIT (0)
	MessageLoop ()
	CleanUp ()

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

	SELECT CASE msg

		CASE $$WM_CREATE :
			' create some controls and add tooltip window
			hStatic = NewChild ("static", "The following controls have tooltips:", style, 10, 10, 280, 20, hWnd, 1, 0)

			hButton = NewChild ("button", "button control", $$WS_TABSTOP, 40, 45, 180, 22, hWnd, 2, 0)
			AddCustomToolTip (hButton, "Button control tooltip", hWnd)

			hEdit = NewChild ("edit", "edit control", $$WS_BORDER | $$WS_TABSTOP, 40, 80, 180, 22, hWnd, 3, 0)
			AddCustomToolTip (hEdit, "Edit control tooltip", hWnd)

		CASE $$WM_DESTROY :
			PostQuitMessage (0)

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
	hInst = GetModuleHandleA (0)		' get current instance handle
	IFZ hInst THEN QUIT (0)
	InitCommonControls ()		' initialize comctl32.dll library

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

	wc.style = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc = addrWndProc
	wc.cbClsExtra = 0
	wc.cbWndExtra = 0
	wc.hInstance = hInst
	wc.hIcon = LoadIconA (hInst, &icon$)
	wc.hCursor = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground = $$COLOR_BTNFACE + 1
	wc.lpszMenuName = &menu$
	wc.lpszClassName = &className$

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
	className$ = "TooTipExClass"
	addrWndProc = &WndProc ()
	icon$ = "scrabble"
	menu$ = ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

	' create main window
	titleBar$ = "Custom tooltip demo"
	style = $$WS_OVERLAPPEDWINDOW
	w = 300
	h = 300
	exStyle = 0
	#winMain = NewWindow (@className$, @titleBar$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)		' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)		' show window

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
FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

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

	IF LIBRARY (0) THEN RETURN		' main program executes message loop

	DO		' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)		' retrieve next message from queue

		SELECT CASE ret
			CASE 0 : RETURN msg.wParam		' WM_QUIT message
			CASE - 1 : RETURN $$TRUE		' error
			CASE ELSE:
				hwnd = GetActiveWindow ()
				IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN		' send only non-dialog messages
					TranslateMessage (&msg)		' translate virtual-key messages into character messages
					DispatchMessageA (&msg)		' send message to window callback function WndProc()
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


FUNCTION CustomTipProc (hWnd, msg, wParam, lParam)

	PAINTSTRUCT ps
	RECT rc
	LOGFONT lf
	POINT CurPos

	$iOffset = 8
	$FontType = "Tahoma"
	$FontSize = 13

	SELECT CASE msg
		
		CASE $$WM_PRINT :
			PostMessageA (hWnd, $$WM_PAINT, 0, 0)
			RETURN (1)

		CASE $$WM_PAINT:
			' Get the Current Window Rect
			GetWindowRect (hWnd, &rc)
			GetCursorPos (&CurPos)
			rc.right = CurPos.x - $iOffset + 6 + rc.right - rc.left
			rc.bottom = CurPos.y + 20 + rc.bottom - rc.top
			rc.left = CurPos.x - $iOffset + 6
			rc.top = CurPos.y + 20
			MoveWindow (hWnd, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, 0)
			
			' Get the Window Text (the ToolTip Text)
			iTextLen = GetWindowTextLengthA (hWnd) + 1
			szText$ = NULL$ (iTextLen)
			GetWindowTextA (hWnd, &szText$, iTextLen)
			szText$ = CSIZE$ (szText$)

			' prepare the DC for drawing
			BeginPaint (hWnd, &ps)

			' create and select the font to be used
			lf.height = $FontSize
			lf.weight = $$FW_NORMAL
			lf.faceName = $FontType
			hFont = CreateFontIndirectA (&lf)
			hFontOld = SelectObject (ps.hdc, hFont)

			' enlarge the window to exactly fit the size of the tooltip text
			' using DT_CALCRECT the function extends the base of the
			' rectangle to bound the last line of text but does not draw the text.
			DrawTextA (ps.hdc, &szText$, LEN (szText$), &rc, $$DT_VCENTER | $$DT_NOCLIP | $$DT_CALCRECT)
			rc.right = rc.right + 2 * $iOffset
			rc.bottom = rc.bottom + 3 * $iOffset

			' show the window before changing its size
			' (work around the WM_PRINT problem/feature)
			ShowWindow (hWnd, $$SW_SHOWNA)

			' apply new size
			MoveWindow (hWnd, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, 1)
			SetBkMode (ps.hdc, $$TRANSPARENT)

			' draw the balloon
			ToolTip_DrawBalloon (hWnd, ps.hdc, szText$)

			' Restore the Old Font
			SelectObject (ps.hdc, hFontOld)
			DeleteObject (hFont)

			' End Paint
			EndPaint (hWnd, &ps)
			RETURN
		CASE ELSE :
			' Sends message to previous procedure
			oldWndProc = GetPropA (hWnd, &"oldWndProc")
			RETURN CallWindowProcA (oldWndProc, hWnd, msg, wParam, lParam)

	END SELECT
END FUNCTION

FUNCTION ToolTip_DrawBalloon (hwndTip, hdc, szText$)

	$iOffset = 8
	$FontType = "Tahoma"
	$FontSize = 13

	RECT rc
	POINT pts[2]

	GetClientRect (hwndTip, &rc)
	pts[0].x = rc.left + $iOffset
	pts[0].y = rc.top
	pts[1].x = pts[0].x
	pts[1].y = pts[0].y + $iOffset
	pts[2].x = pts[1].x + $iOffset
	pts[2].y = pts[1].y
	hRgn = CreateRectRgn (0, 0, 0, 0)
	
	' Create the rounded box
	hrgn1 = CreateRoundRectRgn (rc.left, rc.top + $iOffset, rc.right, rc.bottom, 15, 15)
	
	' Create the arrow
	hrgn2 = CreatePolygonRgn (&pts[], 3, $$ALTERNATE)
	
	' combine the two regions
	CombineRgn (hRgn, hrgn1, hrgn2, $$RGN_OR)
	
	' Fill the Region with the Standard BackColor of the ToolTip Window
	FillRgn (hdc, hRgn, GetSysColorBrush ($$COLOR_INFOBK))
	
	' Draw the Frame Region
	FrameRgn (hdc, hRgn, GetStockObject ($$DKGRAY_BRUSH), 1, 1)
	
	rc.top = rc.top + $iOffset * 2
	rc.bottom = rc.bottom - $iOffset
	rc.left = rc.left + $iOffset
	rc.right = rc.right - $iOffset
	' Draw the Shadow Text
	SetTextColor (hdc, GetSysColor ($$COLOR_3DLIGHT))
	DrawTextA (hdc, &szText$, LEN (szText$), &rc, $$DT_VCENTER | $$DT_NOCLIP)
	
	rc.left = rc.left - 1
	rc.top = rc.top - 1
	' Draw the Text
	SetTextColor (hdc, GetSysColor ($$COLOR_INFOTEXT))
	DrawTextA (hdc, &szText$, LEN (szText$), &rc, $$DT_VCENTER | $$DT_NOCLIP)
END FUNCTION


FUNCTION AddCustomToolTip (hCtl, ToolTipText$, hParent)

	' Add the Custom ToolTip to the specified object
	TOOLINFO ti

	' A tooltip control with the TTS_ALWAYSTIP style appears when the cursor is
	' on a tool, regardless of whether the tooltip control's owner window is active
	' or inactive. Without this style, the tooltip control appears when the tool's
	' owner window is active, but not when it is inactive.
	hInst = GetModuleHandleA (0)
	hTip = CreateWindowExA (0, &"tooltips_class32", NULL, $$TTS_ALWAYSTIP, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, hParent, 0, hInst, 0)
	ti.cbSize = SIZE (ti)
	ti.uFlags = $$TTF_IDISHWND | $$TTF_SUBCLASS
	ti.hwnd = hCtl
	ti.uId = hCtl
	ti.lpszText = &ToolTipText$
	SendMessageA (hTip, $$TTM_ADDTOOL, 0, &ti)

	' SubClass the tooltip window
	oldWndProc = SetWindowLongA (hTip, $$GWL_WNDPROC, &CustomTipProc ())
	SetPropA (hTip, &"OldWndProc", oldWndProc)

	' Remove Border from ToolTip
	dwStyle = GetWindowLongA (hTip, $$GWL_STYLE)
	dwStyle = dwStyle & (~$$WS_BORDER)
	SetWindowLongA (hTip, $$GWL_STYLE, dwStyle)
END FUNCTION

END PROGRAM