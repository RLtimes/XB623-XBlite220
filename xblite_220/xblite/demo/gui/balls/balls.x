'
'
' ####################
' #####  PROLOG  #####
' ####################

' A screensaver demo that draws moving spheres
' which bounce off one another. This demo is
' chock full of various examples:
' 1. Using dialog resources
' 2. Reading and writing to the registry
' 3. Getting command line arguments
' 4. Capturing the screen
' 5. Drawing masked bitmaps
' 6. Creating an executable which incorporates
'    the runtime library xbl.dll using a custom
'    makefile with the MAKEFILE statement.
'
PROGRAM	"balls"
VERSION	"0.0005"
MAKEFILE "makeballs.mak"
'
	IMPORT	"xst_s.lib"	' static link xst library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"msvcrt"		' msvcrt.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "advapi32"	' advapi32.dll
'	IMPORT	"xio"				' xio.dll
'
TYPE BALL
  XLONG .x
  XLONG .y
  XLONG .xDir
  XLONG .yDir
  XLONG .color
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  GetCommandLineArgs (@argv$[])
DECLARE FUNCTION  SetupProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  CreateScreenBuffer (hWnd, w, h)
DECLARE FUNCTION  DeleteScreenBuffer (hMemDC)
DECLARE FUNCTION  InitBalls (BALL balls[])
DECLARE FUNCTION  DrawBalls ()
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  ReadSettings (subkey$, @rate, @nBalls, @radius)
DECLARE FUNCTION  SaveSettings (subkey$, rate, nBalls, radius)
DECLARE FUNCTION  DoSaver (hWndParent)
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  CloseSaverWindow (hWnd)
'
' constants
'
' Size of the Texture and the Lookuptable
' (Only Powers of 2 below or equal to 256 are allowed)
$$SIZEOFTEX = 256
$$EPSILON   = 0.0000001
'
' Control IDs
'
$$B_OK 					= 201
$$B_CANCEL 			= 202
$$B_SET_DEFAULT	= 207

$$TB_SPEED 			= 301
$$TB_BALLS			= 302
$$TB_RADIUS			= 303
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry
	SHARED saver, config, preview, password
	SHARED hInst

	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50) ' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries

	hWnd = 0

	GetCommandLineArgs (@argv$[])
	IFZ argv$[] THEN RETURN
	argc = UBOUND(argv$[]) + 1

	IF argc = 1 THEN								' no args, saver should display config dialog
		config = $$TRUE
		hWnd = GetForegroundWindow ()
	ELSE
		FOR i = 1 TO argc - 1
			arg$ = TRIM$ (argv$[i])
			IFZ arg$ THEN EXIT FOR

			IF (arg${0} = '-') OR (arg${0} = '/') THEN		' we found a command switch

' /s indicates that the saver should run itself as a full-screen saver
				SELECT CASE LEFT$(LCASE$(arg$),2)
					CASE "-s", "/s" :	saver = $$TRUE

' /c:#### with #### containing integer value of handle to window
' where configuration dialog/window should run as child
					CASE "-c", "/c" :
						config = $$TRUE
						IF INSTR (arg$, ":") THEN
							hWnd = XLONG (RIGHT$ (arg$, 4))
						ELSE
							IF i < argc -1 THEN
								hWnd = XLONG (TRIM$ (argv$[i+1]))
							END IF
						END IF
						IFZ hWnd THEN hWnd = GetForegroundWindow ()

' /p:#### with #### containing integer value of handle to window
' where preview dialog/window should run as child
					CASE "-p", "/p" :
						preview = $$TRUE
						IF INSTR (arg$, ":") THEN
							hWnd = XLONG (RIGHT$ (arg$, 4))
						ELSE
							IF i < argc-1 THEN
								hWnd = XLONG (TRIM$ (argv$[i+1]))
							END IF
						END IF

' /l:#### with #### containing integer value of handle to window
' where preview dialog/window should run as child
					CASE "-l", "/l" :
						preview = $$TRUE
						IF INSTR (arg$, ":") THEN
							hWnd = XLONG (RIGHT$ (arg$, 4))
						ELSE
							IF i < arg-1 THEN
								hWnd = XLONG (TRIM$ (argv$[i+1]))
							END IF
						END IF

					CASE "-a", "/a" : password = $$TRUE
					CASE ELSE 			:
				END SELECT
			END IF
		NEXT i
	END IF

' run configuration dialog
	IF config THEN
		DialogBoxParamA (hInst, 100, hWnd, &SetupProc(), 0)
	END IF

' run as screen saver
	IF (saver = $$TRUE) || (preview = $$TRUE) THEN
		DoSaver (hWnd)
	END IF

	CleanUp ()
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
	InitCommonControls()					' initialize comctl32.dll library

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
' ###################################
' #####  GetCommandLineArgs ()  #####
' ###################################
'
FUNCTION  GetCommandLineArgs (@argv$[])
'
	argc = 0
	index = 0
	DIM argv$[]
	addr = GetCommandLineA ()			' address of full command line
	line$ = CSTRING$ (addr)
'
	done = 0
	IF addr THEN
		DIM argv$[1023]
		quote = $$FALSE
		argc = 0
		empty = $$FALSE
		I = 0
		DO
			char = UBYTEAT (addr, I)
			IF (char < ' ') THEN EXIT DO

			IF (char = ' ') AND NOT quote THEN
				IF NOT empty THEN
					INC argc
					argv$[argc] = ""
					empty = $$TRUE
				END IF
			ELSE
				IF (char = '"') THEN
					quote = NOT quote
				ELSE
					argv$[argc] = argv$[argc] + CHR$(char)
					empty = $$FALSE
				END IF
			END IF
			INC I
		LOOP
		IF NOT empty THEN
			argc = argc + 1
		END IF
		REDIM argv$[argc-1]

	END IF

END FUNCTION
'
'
' ##########################
' #####  SetupProc ()  #####
' ##########################
'
FUNCTION  SetupProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg

		CASE $$WM_INITDIALOG

			XstCenterWindow (hWnd)

' get trackbar handles
			#hTrackBar1 = GetDlgItem (hWnd, $$TB_SPEED)
			#hTrackBar2 = GetDlgItem (hWnd, $$TB_BALLS)
			#hTrackBar3 = GetDlgItem (hWnd, $$TB_RADIUS)

' set tick marks and ranges for trackbars
			SendMessageA (#hTrackBar1, $$TBM_SETRANGE, $$TRUE, MAKELONG(0, 50))
			SendMessageA (#hTrackBar1, $$TBM_SETTICFREQ, 5, 0)

			SendMessageA (#hTrackBar2, $$TBM_SETRANGE, $$TRUE, MAKELONG(10, 100))
			SendMessageA (#hTrackBar2, $$TBM_SETTICFREQ, 10, 0)

			SendMessageA (#hTrackBar3, $$TBM_SETRANGE, $$TRUE, MAKELONG(8, 32))
			SendMessageA (#hTrackBar3, $$TBM_SETTICFREQ, 2, 0)

' read settings from registry
			subkey$ = "Software\\XBLite\\Balls Screensaver"
			ReadSettings (subkey$, @rate, @nBalls, @radius)

' set trackbars to current settings (or to default settings)
			SendMessageA (#hTrackBar1, $$TBM_SETPOS, $$TRUE, rate)
			SendMessageA (#hTrackBar2, $$TBM_SETPOS, $$TRUE, nBalls)
			SendMessageA (#hTrackBar3, $$TBM_SETPOS, $$TRUE, radius)

			RETURN ($$TRUE)

		CASE $$WM_COMMAND
			ctlID = LOWORD (wParam)
			SELECT CASE ctlID
' OK button
				CASE $$B_OK :
' get current settings from trackbars
					rate   = SendMessageA (#hTrackBar1, $$TBM_GETPOS, 0, 0)
					nBalls = SendMessageA (#hTrackBar2, $$TBM_GETPOS, 0, 0)
					radius = SendMessageA (#hTrackBar3, $$TBM_GETPOS, 0, 0)

' save settings in registry
					subkey$ = "Software\\XBLite\\Balls Screensaver"
					SaveSettings (subkey$, rate, nBalls, radius)
					EndDialog (hWnd, 0)

				CASE $$B_SET_DEFAULT :         	' set default button
					subkey$ = "Software\\XBLite\\Balls Screensaver"
					SaveSettings (subkey$, 3, 15, 12)
					EndDialog (hWnd, 0)

				CASE $$B_CANCEL :         	' cancel button
					EndDialog (hWnd, 0)

			END SELECT
			RETURN ($$TRUE)

		CASE $$WM_CLOSE									'close dialog
    	EndDialog (hWnd, 0)
			RETURN ($$TRUE)

		CASE $$WM_CTLCOLORDLG :
			RETURN GetStockObject ($$LTGRAY_BRUSH)

		CASE $$WM_CTLCOLORSTATIC :
			bkColor = RGB (0xc0, 0xc0, 0xc0)
			RETURN SetColor (0, bkColor, wParam, lParam)

		CASE $$WM_CTLCOLORBTN :
			bkColor = RGB (0xc0, 0xc0, 0xc0)
			RETURN SetColor (0, bkColor, wParam, lParam)

	END SELECT

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
'
'
' ##########################
' #####  InitBalls ()  #####
' ##########################
'
FUNCTION  InitBalls (BALL balls[])

	SHARED bwidth, bheight, radius
	SHARED DOUBLE speed

	upper = UBOUND (balls[])
	FOR i = 0 TO upper
' place balls
  	balls[i].x = rand () MOD (#screenW - bwidth)
  	balls[i].y = rand () MOD (#screenH - bheight)

' give balls their slope (or speed)
		dir = rand () MOD 5 + 1
  	SELECT CASE dir
    	CASE 1   balls[i].xDir = 1 * speed
    	CASE 2   balls[i].xDir = -1 * speed
    	CASE 3   balls[i].xDir =  2 * speed
    	CASE 4   balls[i].xDir = -2 * speed
    	CASE 5   balls[i].xDir = 3 * speed
    	CASE 6   balls[i].xDir = -3 * speed
  	END SELECT

  	dir = rand () MOD 5 + 1
  	SELECT CASE dir
    	CASE 1   balls[i].yDir = 1 * speed
    	CASE 2   balls[i].yDir = -1 * speed
    	CASE 3   balls[i].yDir =  2 * speed
    	CASE 4   balls[i].yDir = -2 * speed
    	CASE 5   balls[i].yDir = 3 * speed
    	CASE 6   balls[i].yDir = -3 * speed
  	END SELECT
	NEXT i

END FUNCTION
'
'
' ##########################
' #####  DrawBalls ()  #####
' ##########################
'
FUNCTION  DrawBalls ()

	SHARED BALL myBalls[]
	SHARED bwidth, bheight, radius
	SHARED DOUBLE speed

	SHARED fps

	upper = UBOUND (myBalls[])
	rq = 4 * radius*radius
	maxRight = #screenW - bwidth
	maxBottom = #screenH - bheight

'	fps$ = "FPS =" + STRING$ (fps)
'	TextOutA (#hMemDC, 10, 10, &fps$, LEN(fps$))

	FOR i = 0 TO upper

' erase last ball position (copy original window image to #hMemDC)
		StretchBlt (#hMemDC, myBalls[i].x, myBalls[i].y, bwidth, bheight, #hMemWindow, myBalls[i].x, myBalls[i].y, bwidth, bheight, $$SRCCOPY)

' update new ball position
		myBalls[i].x = myBalls[i].x + myBalls[i].xDir
		myBalls[i].y = myBalls[i].y + myBalls[i].yDir

' improved collision detection
' by Guenther Schott

' check to see if we have colliding balls
' but don't test 2 balls twice

		FOR i2 = i+1 TO upper

			IF i2 = i THEN DO NEXT
			IF i+1 >= upper THEN DO NEXT

' detect collision
			dx = myBalls[i].x - myBalls[i2].x
			dy = myBalls[i].y - myBalls[i2].y

' use phythagoras' formula
			IF (dx*dx)+(dy*dy) <= rq THEN

' but don't compare with squareroot
' bring distance between balls so they will not glue together

				IF dx > 0 THEN
					myBalls[i].x = myBalls[i].x+1
				ELSE
					myBalls[i].x = myBalls[i].x-1
				ENDIF

				IF dy > 0 THEN
					myBalls[i].y = myBalls[i].y+1
				ELSE
					myBalls[i].y = myBalls[i].y-1
				ENDIF

' if collision then swap speed
' only "swap", not something else
				SWAP myBalls[i].xDir, myBalls[i2].xDir
				SWAP myBalls[i].yDir, myBalls[i2].yDir

			END IF
		NEXT i2

' check for collision with wall boundary
		IF myBalls[i].x > maxRight THEN
			myBalls[i].x = maxRight
			myBalls[i].xDir = myBalls[i].xDir * -1
		END IF

		IF myBalls[i].y > maxBottom THEN
			myBalls[i].y = maxBottom
			myBalls[i].yDir = myBalls[i].yDir * -1
		END IF

		IF myBalls[i].x < 0 THEN
			myBalls[i].x = 0
			myBalls[i].xDir = myBalls[i].xDir * -1
		END IF

		IF myBalls[i].y < 0 THEN
			myBalls[i].y = 0
			myBalls[i].yDir = myBalls[i].yDir * -1
		END IF

' BitBlt #hMemDC with the mask using AND (SRCAND)
		BitBlt (#hMemDC, myBalls[i].x, myBalls[i].y, bwidth, bheight, #hMemMask, 0, 0, $$SRCAND)

' BitBlt #hMemDC with the source using XOR (SRCINVERT)
	  BitBlt (#hMemDC, myBalls[i].x, myBalls[i].y, bwidth, bheight, #hMemBall, 0, 0, $$SRCINVERT)

	NEXT i

END FUNCTION
'
'
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush

END FUNCTION
'
'
' #############################
' #####  ReadSettings ()  #####
' #############################
'
' Read data settings from the registry.
' NOTE: subkey$ should be "Software\\XBLite\\Balls Screensaver"
'
FUNCTION  ReadSettings (subkey$, @rate, @nBalls, @radius)

	IFZ subkey$ THEN RETURN

	hKey = 0

' NOTE: subkey$ should be "Balls Screensaver"

' open subkey
	IFZ RegOpenKeyExA ($$HKEY_CURRENT_USER, &subkey$, 0, $$KEY_READ, &hKey) THEN

' if present, read data from registry

' get the required data type and size (they are all the same)
		ret = RegQueryValueExA (hKey, &"nballs", 0, &datatype, NULL, &size)

' now get the data
		RegQueryValueExA (hKey, &"nballs", 0, &datatype, &nBalls, &size)
		RegQueryValueExA (hKey, &"radius", 0, &datatype, &radius, &size)
		RegQueryValueExA (hKey, &"rate",   0, &datatype, &rate,   &size)

' close registry key
		RegCloseKey (hKey)
	END IF

' default values
'	IFZ rate   THEN rate   = 3
	IFZ nBalls THEN nBalls = 15
	IFZ radius THEN radius = 12

END FUNCTION
'
'
' #############################
' #####  SaveSettings ()  #####
' #############################
'
' Save screensaver data in registry.
' It should be saved in the registry in the
' standard location:
' HKEY_CURRENT_USER\Software\MyCompany\MyProduct\
'
FUNCTION  SaveSettings (subkey$, rate, nBalls, radius)
'
' create a registry key for screensaver data. If the key
' already exists, the function opens it.
' NOTE: subkey$ should be "Software\\XBLite\\Balls Screensaver"

	IFZ subkey$ THEN RETURN

' create/open registry subkey
	class$ = ""
	IFZ RegCreateKeyExA ($$HKEY_CURRENT_USER, &subkey$, 0, &class$, 0, $$KEY_WRITE, NULL, &hKey, &neworused) THEN

' save data in registry
		RegSetValueExA (hKey, &"rate",   0, $$REG_DWORD, &rate,   SIZE(rate))
		RegSetValueExA (hKey, &"nballs", 0, $$REG_DWORD, &nBalls, SIZE(nBalls))
		RegSetValueExA (hKey, &"radius", 0, $$REG_DWORD, &radius, SIZE(radius))

' close registry
		RegCloseKey (hKey)
	END IF

END FUNCTION
'
'
' ########################
' #####  DoSaver ()  #####
' ########################
'
FUNCTION  DoSaver (hWndParent)

	MSG msg
	SHARED hInst, className$
	SHARED preview, saver
	RECT rc
	STATIC hdc, hWndScr
	SHARED rate
	SHARED fps

	className$  = "ScrSaver"
	titleBar$  	= "Colliding Balls"
	IF RegisterWinClass (@className$, &WndProc(), @"scrabble", @"") THEN QUIT(0)

	IF preview THEN
		GetWindowRect (hWndParent, &rc)
		cx = rc.right - rc.left
		cy = rc.bottom - rc.top

		#destWidth = cx
		#destHeight = cy

		style	= $$WS_CHILD | $$WS_VISIBLE
		hWndScr = CreateWindowExA (0, &className$, &title$, style, 0, 0, cx, cy, hWndParent, 0, hInst, 0)
		#hWndPreview = hWndScr
	ELSE
		h = GetDesktopWindow ()
    GetWindowRect (h, &rc)
		cx = rc.right
		cy = rc.bottom
		#destWidth = cx
		#destHeight = cy

		exstyle = $$WS_EX_TOPMOST
		style	= $$WS_POPUP | $$WS_VISIBLE
		hWndScr = CreateWindowExA (exstyle, &className$, &title$, style, 0, 0, cx, cy, hWndParent, 0, hInst, 0)
	END IF

	IFZ hWndScr THEN RETURN

' turn off Ctrl-alt-Del and alt-Tab
	IF saver THEN
		SystemParametersInfoA ($$SPI_SCREENSAVERRUNNING, 1, &oldval, 0)
		hdc = GetDC (hWndScr)
	END IF

	DO																		' the message loop
'		start = GetTickCount()
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN
			IF msg.message = $$WM_QUIT THEN EXIT DO
			TranslateMessage (&msg)						' translate virtual-key messages into character messages
			DispatchMessageA (&msg)						' send message to window callback function WndProc()
		ELSE
	    DrawBalls ()																			' draw some balls
			IF rate THEN Sleep (rate)													' slow it down
			IF saver THEN 																		' copy memory bitmap to screen
		    BitBlt (hdc, 0, 0, #screenW, #screenH, #hMemDC, 0, 0, $$SRCCOPY)
			ELSE																							' use StretchBlt on preview to shrink it
				hdc = GetDC (#hWndPreview)
				StretchBlt (hdc, 0, 0, #destWidth, #destHeight, #hMemDC, 0, 0, #screenW, #screenH, $$SRCCOPY)
				ReleaseDC (#hWndPreview, hdc)
			END IF
		END IF
' calculate fps
'		lend = GetTickCount () - start
'		IF lend THEN fps = 1.0/DOUBLE(lend) * 1000.0
	LOOP

' restore Ctrl-alt-Del and alt-Tab
	IF saver THEN
		SystemParametersInfoA ($$SPI_SCREENSAVERRUNNING, 0, &oldval, 0)
		ReleaseDC (hWndScr, hdc)
	END IF

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
	wc.hIcon           = NULL
	wc.hCursor         = NULL
	wc.hbrBackground   = $$COLOR_BTNFACE + 1
	wc.lpszMenuName    = &menu$
	wc.lpszClassName   = &className$

	IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ########################
' #####  DlgProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	RECT rect, rc
	STATIC POINT pt, dd
	STATIC timerID
	SHARED nBalls, radius, rate
	SHARED BALL myBalls[]
	SHARED bwidth, bheight
	SHARED DOUBLE speed
	STATIC msec
	SHARED preview, saver
	SHARED reallyClose

' mouse move threshold for exiting screensaver
	$MouseMove = 10.0

	SELECT CASE msg

		CASE $$WM_CREATE:
' get window sizes
			#screenW = GetSystemMetrics ($$SM_CXSCREEN)
			#screenH = GetSystemMetrics ($$SM_CYSCREEN)

' for debug purposes only, set smaller screen size
'			IF saver THEN
'    		SetWindowPos (hWnd, $$HWND_TOPMOST, 0, 300, 480, 240, 0)
'			END IF

' get initial mouse position
    	GetCursorPos (&dd)

' read saved settings from registry
			subkey$ = "Software\\XBLite\\Balls Screensaver"
			ReadSettings (subkey$, @rate, @nBalls, @radius)

' init balls
			speed   = 2											' speed factor
'			IFZ rate   THEN rate    = 3			' update rate
			IFZ nBalls THEN nBalls	= 15		' number of balls
			IFZ radius THEN radius  = 12		' ball radius
			bwidth  = 2 * radius
			bheight = 2 * radius

' init rand ()
			seed = (GetTickCount () MOD 32767) + 1
			srand (seed)

' create array of balls
			upper = nBalls - 1
			DIM myBalls[upper]
			InitBalls (@myBalls[])

' create memory bitmaps for ball & mask images
			#hMemBall = CreateScreenBuffer (hWnd, bwidth, bheight)	' image of ball in memory
			#hMemMask = CreateScreenBuffer (hWnd, bwidth, bheight)	' image of mask in memory

' draw sphere and mask
			GOSUB DrawSphere

' create two screen bitmaps, one as a target, the second to capture screen
			#hMemDC = CreateScreenBuffer (hWnd, #screenW, #screenH)			' a target to draw on
			#hMemWindow = CreateScreenBuffer (hWnd, #screenW, #screenH)	' current captured screen image

' copy current screen to screen memory bitmap
			hdcScreen = CreateDCA (&"DISPLAY", 0, 0, 0)										' get screen dc
			BitBlt (#hMemWindow, 0, 0, #screenW, #screenH, hdcScreen, 0, 0, $$SRCCOPY)	' copy screen to memory bitmap

' copy original screen image to memory buffer
			BitBlt (#hMemDC, 0, 0, #screenW, #screenH, #hMemWindow, 0, 0, $$SRCCOPY)

			hProcess = GetCurrentProcess ()
			ret = SetPriorityClass (hProcess, $$HIGH_PRIORITY_CLASS)

			RETURN ($$FALSE)


		CASE $$WM_MOUSEMOVE :
' check if mouse was moved beyond movement threshold
			IF saver THEN
				GetCursorPos (&pt)
				c = ABS(dd.x - pt.x)/$MouseMove + ABS(dd.y - pt.y)/$MouseMove
				IF c > 0 THEN
					GOSUB Exit
				END IF
			END IF


		CASE $$WM_SETCURSOR :
			IF saver THEN
				SetCursor (0)															' hide the cursor in saver
			ELSE
				SetCursor (LoadCursorA (0, $$IDC_ARROW))	' display the cursor in preview
			END IF


		CASE $$WM_LBUTTONDOWN, $$WM_RBUTTONDOWN, $$WM_MBUTTONDOWN, $$WM_KEYDOWN :
			IF saver THEN	GOSUB Exit


		CASE $$WM_ACTIVATE, $$WM_ACTIVATEAPP, $$WM_NCACTIVATE :
			IF (saver = $$TRUE) && (LOWORD (wParam) = $$WA_INACTIVE) THEN
				GOSUB Exit
			END IF


		CASE $$WM_SYSCOMMAND :
			IF saver THEN
				IF wParam = $$SC_SCREENSAVE THEN RETURN ($$FALSE)
				IF wParam = $$SC_CLOSE THEN RETURN ($$FALSE)
			END IF


		CASE $$WM_CLOSE :
			IF (saver = $$TRUE) && (reallyClose = $$TRUE) THEN
				DestroyWindow (hWnd)
			END IF
			IF saver THEN RETURN ($$FALSE)  ' return FALSE here so that DefWindowProc doesn't get called, because it would just DestroyWindow itself


		CASE $$WM_DESTROY :
			PostQuitMessage (0)

	END SELECT

RETURN DefWindowProcA (hWnd, msg, wParam, lParam)


' ***** Exit *****
SUB Exit
	DeleteScreenBuffer (#hMemDC)
	DeleteScreenBuffer (#hMemBall)
	DeleteScreenBuffer (#hMemMask)
	DeleteScreenBuffer (#hMemWindow)
	hProcess = GetCurrentProcess ()
	SetPriorityClass (hProcess, $$NORMAL_PRIORITY_CLASS)
	CloseSaverWindow (hWnd)
END SUB

' ***** DrawSphere *****
SUB DrawSphere

	r = radius
	upper = 2*r-1
	white = RGB (255, 255, 255)
	black = 0

' find c0
	c0 = 0
	DO
		min = 10000
		FOR x = 0 TO upper
  		FOR y = 0 TO upper
    		h2 = -x*x - y*y + 2*r*x + 2*r*y - r*(r+1)
				IF h2 >= 0 THEN
					h = sqrt(h2)
					b = 9*h - 6*y + 4*x + c0
					min = MIN(min, b)
				END IF
			NEXT y
		NEXT x
		IF min >= 0 THEN EXIT DO
		INC c0
	LOOP

' find c1#
	c1# = 0
	DO
		FOR x = 0 TO upper
  		FOR y = 0 TO upper
    		h2 = -x*x - y*y + 2*r*x + 2*r*y - r*(r+1)
				IF h2 >= 0 THEN
					h = sqrt(h2)
					b = (9*h - 6*y + 4*x + c0) * c1#
					max = MAX(max, b)
				END IF
			NEXT y
		NEXT x
		IF max >= 255 THEN
 			c1# = c1# - 0.01
			EXIT DO
		END IF
		c1# = c1# + 0.01
	LOOP

' select a color
	c = rand() MOD 7 + 1

' draw pixels
	FOR x = 0 TO upper
  	FOR y = 0 TO upper
    	h2 = -x*x - y*y + 2*r*x + 2*r*y - r*(r+1)
			IF h2 >= 0 THEN
				h = sqrt(h2)
				b = (9*h - 6*y + 4*x + c0)*c1#

				SELECT CASE c
					CASE 1 : color =  b << 16 + b << 8 + b
					CASE 2 : color =  b << 16 + b << 8
					CASE 3 : color =  b << 16
					CASE 4 : color =  b << 16          + b
					CASE 5 : color =            b << 8 + b
					CASE 6 : color =            b << 8
					CASE 7 : color =                     b
				END SELECT

				SetPixelV (#hMemBall, x, y, color)
				SetPixelV (#hMemMask, x, y, black)
			ELSE
				SetPixelV (#hMemMask, x, y, white)
			END IF
		NEXT y
	NEXT x
END SUB

END FUNCTION
'
'
' #################################
' #####  CloseSaverWindow ()  #####
' #################################
'
' The function CloseSaverWindow uses ReallyClose,
' as part of a workaround to deal with the WM_CLOSE
' messages that get sent automatically under NT.
'
FUNCTION  CloseSaverWindow (hWnd)

	SHARED reallyClose

	reallyClose = $$TRUE
	PostMessageA (hWnd, $$WM_CLOSE, 0, 0)

END FUNCTION
END PROGRAM
