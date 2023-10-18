'
'
' ####################
' #####  PROLOG  #####
' ####################

' A screensaver demo that draws colored circles
' using a full screen dialog resource.
'
PROGRAM	"bubbles"
VERSION	"0.0003"
'
	IMPORT	"xst"				' xst.dll
'	IMPORT	"xio"				' xio.dll
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"msvcrt"		' msvcrt.dll
'
TYPE BUBBLE
	XLONG	.x			' x-coordinate
	XLONG	.y			' y-coordinate
	XLONG	.rad		' radius
	XLONG	.red		' bubble color
	XLONG	.green
	XLONG	.blue
	XLONG	.z			' depth of bubble in 3d space
	XLONG	.frac
	XLONG	.mx			' middle of screen
	XLONG	.my
	XLONG	.preview
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  InitBubble (BUBBLE b)
DECLARE FUNCTION  DrawBubblesToScreen (hdc)
DECLARE FUNCTION  DrawBubble (hdc, id)
DECLARE FUNCTION  DlgProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  CreateScreenBuffer (hWnd, w, h)
DECLARE FUNCTION  DeleteScreenBuffer (hMemDC)

$$MaxBubbles = 500
'
'
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
'	CleanUp ()										' unregister all window classes
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

	SHARED hInst
	ret = DialogBoxParamA (hInst, 100, 0, &DlgProc(), 0)
	IF ret = -1 THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$
	UnregisterClassA(&className$, hInst)

END FUNCTION
'
'
' ###########################
' #####  InitBubble ()  #####
' ###########################
'
FUNCTION  InitBubble (BUBBLE b)

	b.x		= 0
	b.y		= 0
	b.mx 	= 320
	b.my 	= 240
	b.z		= rand() MOD 1000
	IF (rand() MOD 4 <= 3) THEN
		b.rad = rand() MOD 20 + 1
	ELSE
		b.rad = rand() MOD 30 + 10
	END IF

	IF (b.preview) THEN b.rad = rand() MOD 10 + 1

	b.frac 	= rand() MOD b.rad + 2
	b.red		= rand() MOD 256
	b.green = rand() MOD 256
	b.blue 	= rand() MOD 256

END FUNCTION
'
'
' ####################################
' #####  DrawBubblesToScreen ()  #####
' ####################################
'
FUNCTION  DrawBubblesToScreen (hdc)

	SHARED BUBBLE myBubbles[]
	SHARED nBubbles

' erase screen
	PatBlt (hdc, 0, 0, #scrWidth, #scrHeight, $$PATCOPY)

' update bubble position and size
	upper = nBubbles - 1

	FOR i = 0 TO upper
		FOR j = 0 TO upper-1
			IF (myBubbles[j].z > myBubbles[j+1].z) THEN
				SWAP myBubbles[j],myBubbles[j+1]
			END IF
		NEXT j
	NEXT i

	FOR i = 0 TO upper
		DrawBubble (hdc, i)
	NEXT i

END FUNCTION
'
'
' ###########################
' #####  DrawBubble ()  #####
' ###########################
'
' Draw the current bubble position
'
FUNCTION  DrawBubble (hdc, id)

	SHARED BUBBLE myBubbles[]
	BUBBLE b
	POINT p

	b = myBubbles[id]

'	xx = b.x * b.z / 1000
'	yy = b.y * b.z / 1000
'	ra = b.rad * b.z / 1000

'	hPen = CreatePen ($$PS_SOLID, 1, RGB(0, 0, 0))
'	hOldPen = SelectObject (hdc, hPen)
'	hBrush = CreateSolidBrush (RGB(0, 0, 0))
'	hOldBrush = SelectObject (hdc, hBrush)

'	left 		= xx + b.mx - ra
'	right 	= xx + b.mx + ra
'	top 		= yy + b.my - ra
'	bottom 	= yy + b.my + ra

'	Ellipse (hdc, left, top, right, bottom)

'	SelectObject (hdc, hOldPen)
'	SelectObject (hdc, hOldBrush)
'	DeleteObject (hPen)
'	DeleteObject (hBrush)

	b.z = b.z + b.frac
	xx = b.x * b.z / 1000
	yy = b.y * b.z / 1000
	ra = b.rad * b.z / 1000

	IF ((xx < -(b.mx + ra)) | (yy < -(b.my + ra)) | (xx > (b.mx + ra)) | (yy > (b.my + ra))) THEN
		b.z = rand() MOD 1000
		xx = b.x * b.z / 1000
		yy = b.y * b.z / 1000
		ra = b.rad * b.z / 1000
	END IF

	hPen = CreatePen ($$PS_SOLID, 1, RGB(b.red, b.green, b.blue))
	hOldPen = SelectObject (hdc, hPen)
	hBrush = CreateSolidBrush (RGB(b.red, b.green, b.blue))
	hOldBrush = SelectObject (hdc, hBrush)

	left 		= xx + b.mx - ra
	right 	= xx + b.mx + ra
	top 		= yy + b.my - ra
	bottom 	= yy + b.my + ra

	Ellipse (hdc, left, top, right, bottom)

	SelectObject (hdc, hOldPen)
	SelectObject (hdc, hOldBrush)
	DeleteObject (hPen)
	DeleteObject (hBrush)

	myBubbles[id] = b

END FUNCTION
'
'
' ########################
' #####  DlgProc ()  #####
' ########################
'
' A dialog box procedure is similar to a window procedure
' in that the system sends messages to the procedure when
' it has information to give or tasks to carry out.
' Unlike a window procedure, a dialog box procedure never
' calls the DefWindowProc function. Instead, it returns TRUE
' if it processes a message or FALSE if it does not.
'
FUNCTION  DlgProc (hWnd, msg, wParam, lParam)

	RECT rect, rc
	STATIC POINT dd
	STATIC POINT pt
	STATIC timerID
	SHARED nBubbles
	SHARED BUBBLE myBubbles[]
	BUBBLE b

' mouse move threshold for exiting screensaver
	$MouseMove = 10.0

	SELECT CASE msg

		CASE $$WM_INITDIALOG:

' set window title
			SetWindowTextA (hWnd, &"Bubbles Screen Saver")

' size dialog to fit screen
			h = GetDesktopWindow ()
    	GetWindowRect (h, &rc)
    	SetWindowPos (hWnd, $$HWND_TOPMOST, 0, 0, rc.right, rc.bottom, 0)
			#scrWidth = rc.right
			#scrHeight = rc.bottom

' get initial mouse position
    	GetCursorPos (&dd)

' hide the annoying mouse pointer
'    	ShowCursor (0)

' start timer
			speed = 55   				' (this is the fastest that SetTimer can do)
    	timerID = SetTimer (hWnd, 1, speed, 0)

' init bubbles
			nBubbles = 400
			preview = $$FALSE
			mx = rc.right/2
			my = rc.bottom/2
			upper = nBubbles -1
			DIM myBubbles[upper]
			FOR i = 0 TO upper
				b = myBubbles[i]
				InitBubble (@b)
				myBubbles[i] = b
				myBubbles[i].mx = mx
				myBubbles[i].my =	my
				myBubbles[i].x	=	rand() MOD rc.right - myBubbles[i].mx
				myBubbles[i].y	=	rand() MOD rc.bottom - myBubbles[i].my
				myBubbles[i].preview = preview
			NEXT i

			#hMemDC = CreateScreenBuffer (hWnd, rc.right, rc.bottom)

		CASE $$WM_KEYDOWN :
			GOSUB Exit

		CASE $$WM_TIMER :
' draw some bubbles
			hdc = GetDC (hWnd)
			GetClientRect (hWnd, &rc)
			DrawBubblesToScreen (#hMemDC)
			BitBlt (hdc, 0, 0, rc.right, rc.bottom, #hMemDC, 0, 0, $$SRCCOPY)
			ReleaseDC (hWnd, hdc)

		CASE $$WM_MOUSEMOVE :
' check if mouse was moved beyond threshold
			GetCursorPos (&pt)
			c = ABS(dd.x - pt.x)/$MouseMove + ABS(dd.y - pt.y)/$MouseMove
			IF c > 0 THEN
				GOSUB Exit
			END IF

		CASE $$WM_LBUTTONDOWN :	GOSUB Exit

		CASE $$WM_CLOSE :	GOSUB Exit

		CASE $$WM_CTLCOLORDLG :
			RETURN GetStockObject ($$BLACK_BRUSH)  ' CreateSolidBrush (RGB(0, 0, 0))

    CASE ELSE :
      RETURN ($$FALSE)

	END SELECT

  RETURN ($$TRUE)


' ***** Exit *****
SUB Exit
	DeleteScreenBuffer (#hMemDC)
	KillTimer (hWnd, timerID)
	EndDialog (hWnd, 0)
END SUB

END FUNCTION
'
'
' ###################################
' #####  CreateScreenBuffer ()  #####
' ###################################
'
'	make a compatible memory image buffer
' IN 			: hWnd			window handle
'						w					buffer width
'						h					buffer height
' RETURN 	: hMemDC		handle to a memory device context
'
FUNCTION  CreateScreenBuffer (hWnd, w, h)

	hDC 		= GetDC (hWnd)
	memDC 	= CreateCompatibleDC (hDC)
	hBit 		= CreateCompatibleBitmap (hDC, w, h)
	SelectObject (memDC, hBit)
	hBrush 	= GetStockObject ($$BLACK_BRUSH)
	SelectObject (memDC, hBrush)
	PatBlt (memDC, 0, 0, w, h, $$PATCOPY)
	ReleaseDC (hWnd, hDC)
	RETURN memDC

END FUNCTION
'
'
' ###################################
' #####  DeleteScreenBuffer ()  #####
' ###################################
'
FUNCTION  DeleteScreenBuffer (hMemDC)

	hBmp = GetCurrentObject (hMemDC, $$OBJ_BITMAP)
	DeleteObject (hBmp)
	DeleteDC (hMemDC)

END FUNCTION
END PROGRAM
