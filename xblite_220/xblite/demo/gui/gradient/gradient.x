'
'
' ####################
' #####  PROLOG  #####
' ####################

' A program which creates a smooth color
' gradient which can be applied to a window
' or a control.
' Based on program FadeWDJ, by Davide Ficano 1998.
'
PROGRAM	"gradient"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"msvcrt"		' MS VC runtime library
	IMPORT  "comctl32.dec"
	IMPORT	"comdlg32"	' common dialog library
'
TYPE GRADIENT
	XLONG .crFrom
	XLONG .crTo
	XLONG .numEntries
	XLONG .startIdx
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  GetBValue (rgb)
DECLARE FUNCTION  GetGValue (rgb)
DECLARE FUNCTION  GetRValue (rgb)
DECLARE FUNCTION  REDMID (from, to)
DECLARE FUNCTION  GRNMID (from, to)
DECLARE FUNCTION  BLUMID (from, to)
DECLARE FUNCTION  CreateGradient (GRADIENT grad, @crColor[])
DECLARE FUNCTION  Go (@crColor[], crFrom, crTo, idxa, idxb)
DECLARE FUNCTION  CreateNewFadeBk (hWnd, w, h, GRADIENT grad)
DECLARE FUNCTION  DrawFade (hDC, RECT rc, @crPalette[], numColors)

'Control IDs
$$Button1 = 101
$$Button2 = 102
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
	RECT rc
	STATIC width, height
	SHARED NR_COLORS
	SHARED GRADIENT gradient
	SHARED memDC
	SHARED fadeBmp, oldBmp
	SHARED CHOOSECOLOR cc
	GRADIENT g
	SHARED hInst

	SELECT CASE msg

		CASE $$WM_CREATE:
			#hButton1 = NewChild ("button", "Select Start Color", $$BS_PUSHBUTTON, 10, 10, 150, 22, hWnd, $$Button1, 0)
			#hButton2 = NewChild ("button", "Select End Color",   $$BS_PUSHBUTTON, 10, 32, 150, 22, hWnd, $$Button2, 0)

' create memory DC
			memDC = CreateCompatibleDC (GetDC (hWnd))

			GetClientRect (hWnd, &rc)
			NR_COLORS = rc.bottom - rc.top

' initialize gradient struct
			gradient.crFrom     = RGB (255,  0, 128)
			gradient.crTo       = RGB(128, 128, 255)
			gradient.startIdx   = 0
			gradient.numEntries = NR_COLORS

		CASE $$WM_SIZE:
			width = LOWORD (lParam)						' width of client area
			height = HIWORD (lParam)					' height of client area
			NR_COLORS = height
			gradient.numEntries = NR_COLORS
			CreateNewFadeBk (hWnd, width, height, gradient)
			InvalidateRect (hWnd, NULL, $$TRUE)

		CASE $$WM_ERASEBKGND:
' Updates only uncovered area
			hdc = wParam
			GetClipBox (hdc, &rc)
			BitBlt (hdc, rc.left, rc.top, rc.right-rc.left, rc.bottom-rc.top, memDC, rc.left, rc.top, $$SRCCOPY)
			RETURN ($$TRUE)

		CASE $$WM_CLOSE:
			DestroyWindow (hWnd)

		CASE $$WM_DESTROY:
			IF memDC THEN
				IF (oldBmp) THEN SelectObject (memDC, oldBmp)
				IF (fadeBmp) THEN DeleteObject (fadeBmp)
				DeleteDC (memDC)
			END IF
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id = LOWORD (wParam)
			SELECT CASE id
				CASE $$Button1, $$Button2:
					GOSUB InitColorStruct

					IF ChooseColorA (&cc) THEN
						IF (id == $$Button1) THEN
							gradient.crFrom = cc.rgbResult
						ELSE
							gradient.crTo = cc.rgbResult
						END IF
						GetClientRect (hWnd, &rc)
						CreateNewFadeBk (hWnd, rc.right-rc.left, rc.bottom-rc.top, gradient)
						InvalidateRect (hwnd, NULL, $$TRUE)
					END IF
			END SELECT

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** InitColorStruct *****
SUB InitColorStruct
	srand (GetTickCount())

' Generates a palette for custom colors
	g.crFrom     = RGB (rand() & 127, rand() & 255, rand() & 255)
	g.crTo       = RGB (rand() & 255, rand() & 63, rand() & 255)
	g.startIdx   = 0
	g.numEntries = 16

	CreateGradient (g, @crCustom[])

	cc.lStructSize    = SIZE (CHOOSECOLOR)
	cc.hwndOwner      = hWnd
	cc.hInstance      = hInst
	IF id = Button1 THEN
		cc.rgbResult    = gradient.crFrom
	ELSE
		cc.rgbResult    = gradient.crTo
	END IF
	cc.lpCustColors   = &crCustom[]
	cc.flags          = $$CC_RGBINIT
	cc.lCustData      = 0
	cc.lpfnHook       = NULL
	cc.lpTemplateName = NULL

END SUB

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
FUNCTION  CreateWindows ()

	SHARED className$

' register window class
	className$  = "GradientDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Draw gradient demo"
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 450
	h 					= 300
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
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
FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

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
FUNCTION  MessageLoop ()

	STATIC MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, 0, 0, 0)			' retrieve next message from queue

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
' ##########################
' #####  GetBValue ()  #####
' ##########################
'
FUNCTION  GetBValue (rgb)

	RETURN (rgb >> 16) & 0xFF


END FUNCTION
'
'
' ##########################
' #####  GetGValue ()  #####
' ##########################
'
FUNCTION  GetGValue (rgb)

	RETURN (rgb >> 8) & 0xFF

END FUNCTION
'
'
' ##########################
' #####  GetRValue ()  #####
' ##########################
'
FUNCTION  GetRValue (rgb)

	RETURN rgb & 0xFF

END FUNCTION
'
'
' #######################
' #####  REDMID ()  #####
' #######################
'
FUNCTION  REDMID (from, to)

	RETURN ((GetRValue(from) + GetRValue(to)) >> 1)

END FUNCTION
'
'
' #######################
' #####  GRNMID ()  #####
' #######################
'
FUNCTION  GRNMID (from, to)

	RETURN ((GetGValue(from) + GetGValue(to)) >> 1)

END FUNCTION
'
'
' #######################
' #####  BLUMID ()  #####
' #######################
'
FUNCTION  BLUMID (from, to)

	RETURN ((GetBValue(from) + GetBValue(to)) >> 1)

END FUNCTION
'
'
' ###############################
' #####  CreateGradient ()  #####
' ###############################
'
FUNCTION  CreateGradient (GRADIENT grad, @crColor[])

	IF grad.numEntries <= 0 THEN RETURN

	endIdx = grad.startIdx + grad.numEntries - 1

	DIM crColor[endIdx]

' Sets initial & final colors
	crColor[grad.startIdx] = grad.crFrom
	crColor[endIdx]        = grad.crTo

	Go (@crColor[], grad.crFrom, grad.crTo, grad.startIdx, endIdx)

 	RETURN $$TRUE

END FUNCTION
'
'
' ###################
' #####  Go ()  #####
' ###################
'
FUNCTION  Go (@crColor[], crFrom, crTo, idxa, idxb)

	idxc = (idxa + idxb) >> 1

	IF (idxa < idxc && idxc < idxb) THEN

		crColor[idxc] = RGB (REDMID(crFrom, crTo), GRNMID(crFrom, crTo), BLUMID(crFrom, crTo))

' First half
		Go (@crColor[], crFrom, crColor[idxc], idxa, idxc)

' Second half
		Go (@crColor[], crColor[idxc], crTo, idxc, idxb)
	END IF

END FUNCTION
'
'
' ################################
' #####  CreateNewFadeBk ()  #####
' ################################
'
FUNCTION  CreateNewFadeBk (hWnd, w, h, GRADIENT grad)

	RECT rc
	STATIC prev_w, prev_h
	STATIC init
	SHARED fadeBmp, oldBmp
	SHARED memDC
	SHARED NR_COLORS

	IFZ init THEN
		init = $$TRUE
		prev_w = -1
		prev_h = -1
	END IF

	hDC = GetDC (hWnd)

	IFZ CreateGradient (grad, @crColor[]) THEN RETURN

' Creates a new bitmap only if actual differs in dimensions
' First time this is TRUE
	IF (prev_w != w || prev_h != h) THEN
		prev_w = w : prev_h = h

' Deletes previous bitmap
		IF fadeBmp THEN
			SelectObject (memDC, oldBmp)
			DeleteObject (fadeBmp)
		END IF

		fadeBmp = CreateCompatibleBitmap (hDC, w, h)
		IF fadeBmp THEN
			oldBmp = SelectObject (memDC, fadeBmp)
		ELSE
			RETURN
		END IF
	END IF

	SetRect (&rc, 0, 0, w, h)
	DrawFade (memDC, rc, @crColor[], NR_COLORS)

	RETURN ($$TRUE)

END FUNCTION
'
'
' #########################
' #####  DrawFade ()  #####
' #########################
'
FUNCTION  DrawFade (hDC, RECT rc, @crPalette[], numColors)

	IFZ crPalette[] THEN RETURN

' set offset
	offs = 1
	rc.bottom = rc.top + offs

	FOR i = 0 TO numColors-1

		br = CreateSolidBrush (crPalette[i])
		oldBrush = SelectObject (hDC, br)
		FillRect (hDC, &rc, br)
		SelectObject (hDC, oldBrush)
		DeleteObject (br)

' Go to next strip
		rc.top    = rc.top + offs
		rc.bottom = rc.bottom + offs

	NEXT i

END FUNCTION
END PROGRAM
