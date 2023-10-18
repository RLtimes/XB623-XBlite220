'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' The 'Puzzle of Fifteen' sliding tiles puzzle.
' This well-known puzzle became popular in the US
' during the 1870s. The puzzle consists of fifteen
' square tiles, labelled numerically from 1 to 15.
' They are arranged in a random ordering within a
' square tray that is just large enough to hold
' sixteen tiles in a 4 x 4 grid. The tiles can then
' be slid around the tray until they are in the correct
' numerical ordering of 1 to 15, with the blank space
' at the bottom-right hand corner. The tiles must not
' be picked out of the tray.
' See http://kevingong.com/Math/SixteenPuzzle.html
' The real challenge is to write a solver routine.
'
PROGRAM	"puzzle"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"xsx"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
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
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  SetNewPositions ()
DECLARE FUNCTION  Shuffle (ULONG data[])
DECLARE FUNCTION  UpdateStatusBar ()
DECLARE FUNCTION  SetDefaultPositions ()
DECLARE FUNCTION  MoveButton (id)
DECLARE FUNCTION  ValidateMove (x, y)
DECLARE FUNCTION  CheckSolution ()
DECLARE FUNCTION  IsLegal (@data[])

'Control IDs
$$Statusbar = 100
$$Group1    = 101

$$Button1   = 110
$$Button2   = 111
$$Button3   = 112
$$Button4   = 113
$$Button5   = 114
$$Button6   = 115
$$Button7   = 116
$$Button8   = 117
$$Button9   = 118
$$Button10   = 119
$$Button11   = 120
$$Button12   = 121
$$Button13   = 122
$$Button14   = 123
$$Button15   = 124

$$Menu_File_New_Game = 200
$$Menu_File_Exit     = 201
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry

	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	CreateWindows ()							' create windows and other child controls
	MessageLoop ()								' the main message loop
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

	SHARED hButton[]
	SHARED defPosX[], defPosY[]
	SHARED numMoves
	SHARED emptyX, emptyY

	SELECT CASE msg

		CASE $$WM_CREATE:

			DIM hButton[14]
			DIM defPosX[15]
			DIM defPosY[15]

' create a groupbox for a border
			#hGroup1 = NewChild ("button", "", $$BS_GROUPBOX, 22, 0, 206, 214, hWnd, $$Group1, 0)

' create and show various buttons
			FOR i = 0 TO 14
				SELECT CASE TRUE
					CASE i <= 3 :
						defPosX[i] = 25+i*50
						defPosY[i] = 11
						hButton[i] = NewChild ("button", STRING$(i+1), $$BS_PUSHBUTTON | $$WS_TABSTOP, defPosX[i], defPosY[i], 50, 50, hWnd, 110+i, 0)

					CASE i > 3 && i <= 7 :
						defPosX[i] = 25+(i-4)*50
						defPosY[i] = 61
						hButton[i] = NewChild ("button", STRING$(i+1), $$BS_PUSHBUTTON | $$WS_TABSTOP, defPosX[i], defPosY[i], 50, 50, hWnd, 110+i, 0)

					CASE i > 7 && i <= 11 :
						defPosX[i] = 25+(i-8)*50
						defPosY[i] = 111
						hButton[i] = NewChild ("button", STRING$(i+1), $$BS_PUSHBUTTON | $$WS_TABSTOP, defPosX[i], defPosY[i], 50, 50, hWnd, 110+i, 0)

					CASE i > 11 :
						defPosX[i] = 25+(i-12)*50
						defPosY[i] = 161
						hButton[i] = NewChild ("button", STRING$(i+1), $$BS_PUSHBUTTON | $$WS_TABSTOP, defPosX[i], defPosY[i], 50, 50, hWnd, 110+i, 0)

				END SELECT
			NEXT i

			defPosX[15] = 175
			defPosY[15] = 161
			emptyX = 175
			emptyY = 161

' create statusbar window with one part
			#hStatusBar = NewChild ($$STATUSCLASSNAME, @"Ready", $$SBARS_SIZEGRIP, 0, 0, 0, 0, hWnd, $$Statusbar, 0)

' initialize some fonts in buttons
			#hFontArial = NewFont (@"MS Sans Serif", 10, $$FW_NORMAL, $$FALSE, $$FALSE)
			FOR i = 0 TO 14
				SetNewFont (hButton[i], #hFontArial)
			NEXT i

		CASE $$WM_DESTROY :
			DeleteObject (#hFontArial)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			ctlID      = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam

			SELECT CASE TRUE

				CASE (ctlID >= $$Button1) && (ctlID <= $$Button15):
					MoveButton (ctlID - 110)
					UpdateStatusBar ()

				CASE ctlID = $$Menu_File_New_Game:
					SetDefaultPositions ()
					SetNewPositions ()
					numMoves = 0
					text$ = "Ready"
					SetWindowTextA (#hStatusBar, &text$)

				CASE ctlID = $$Menu_File_Exit:
					DestroyWindow (hWnd)
			END SELECT

		CASE $$WM_SIZE :
			SendMessageA (#hStatusBar, $$WM_SIZE, wParam, lParam)		' send resize msg to statusbar

'		CASE $$WM_CTLCOLORBTN :
'			hdcButton  = wParam
'			hwndButton = lParam
'			SELECT CASE hwndButton
'				CASE #check5 :
'					RETURN SetColor (RGB(255, 0, 0), RGB(192, 192, 192), wParam, lParam)
'				CASE ELSE :
'					RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)
'			END SELECT

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
'
'
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
FUNCTION  InitGui ()

	SHARED hInst

	hInst = GetModuleHandleA (0)		' get current instance handle
	IFZ hInst THEN QUIT(0)
	InitCommonControls()						' initialize comctl32.dll library

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
	className$  = "PuzzleGame"
	addrWndProc = &WndProc()
	icon$ 			= "puzzle"
	menu$ 			= "mainmenu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Puzzle of Fifteen."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 258
	h 					= 300
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position

' set random positions for all tiles
	SetNewPositions ()

	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

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

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	hwnd = CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

	RETURN hwnd

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

	IF LIBRARY(0) THEN RETURN			' main program executes message loop

	DO
		ret = GetMessageA (&msg, 0, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  				TranslateMessage (&msg)
  				DispatchMessageA (&msg)
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
FUNCTION  CleanUp ()

	SHARED hInst, className$
	UnregisterClassA(&className$, hInst)

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
'
' ################################
' #####  SetNewPositions ()  #####
' ################################
'
FUNCTION  SetNewPositions ()

	RECT rc[]
	SHARED numMoves
	SHARED hButton[]

	DIM data[14]
	DIM rc[14]

tryagain:

	FOR i = 0 TO 14
		data[i] = i
	NEXT i

	Shuffle (@data[])

	IFZ IsLegal (@data[]) THEN GOTO tryagain

	FOR i = 0 TO 14
		GetWindowRect (hButton[data[i]], &rc[i])
	NEXT i

	FOR i = 0 TO 14
		MapWindowPoints (0, #winMain, &rc[i], 2)
		MoveWindow (hButton[i], rc[i].left, rc[i].top, rc[i].right-rc[i].left, rc[i].bottom-rc[i].top, $$TRUE)
	NEXT i

	numMoves = 0

	UpdateStatusBar ()

END FUNCTION
'
'
' ########################
' #####  Shuffle ()  #####
' ########################
'
' PURPOSE	: Randomly shuffle a set of data.
'
FUNCTION  Shuffle (ULONG data[])

	ULONG where, i, upper

	IFZ data[] THEN RETURN 0
	upper = UBOUND(data[])

	FOR i = 0 TO upper
		where = XstRandom () MOD ULONG(upper+1)
		SWAP data[where], data[i]
	NEXT i

	RETURN ($$TRUE)


END FUNCTION
'
'
' ################################
' #####  UpdateStatusBar ()  #####
' ################################
'
FUNCTION  UpdateStatusBar ()

	SHARED numMoves

	text$ = "Moves = " + STRING$(numMoves)
	SetWindowTextA (#hStatusBar, &text$)

END FUNCTION
'
'
' ###################################
' #####  SetDefaultPositions ()  #####
' ###################################
'
FUNCTION  SetDefaultPositions ()

	SHARED defPosX[], defPosY[]
	SHARED hButton[]
	SHARED emptyX, emptyY

	REDIM posX[8]
	REDIM posY[8]

	FOR i = 0 TO 14
		MoveWindow (hButton[i], defPosX[i], defPosY[i], 50, 50, $$TRUE)
	NEXT i

	emptyX = defPosX[15]
	emptyY = defPosY[15]

END FUNCTION
'
'
' ###########################
' #####  MoveButton ()  #####
' ###########################
'
FUNCTION  MoveButton (id)

	RECT rc
	SHARED hButton[]
	SHARED emptyX, emptyY
	SHARED numMoves

  GetWindowRect (hButton[id], &rc)
  MapWindowPoints (NULL, #winMain, &rc, 2)

	IF ValidateMove (rc.left, rc.top) THEN

' slide button
		dx = (emptyX - rc.left)/25.0
		dy = (emptyY - rc.top)/25.0
		x = rc.left
		y = rc.top
		FOR i = 0 TO 48 STEP 2
			x = x + dx
			y = y + dy
			MoveWindow (hButton[id], x, y, 50, 50, $$TRUE)
			Sleep (10)
		NEXT i

'		MoveWindow (hButton[id], emptyX, emptyY, 50, 50, $$TRUE)

		emptyX = rc.left
		emptyY = rc.top
		INC numMoves
	END IF

	IF CheckSolution () THEN
		text$ = "Puzzle Solved !!" + "\n\nCompleted in " + STRING$(numMoves) + " moves."
		UpdateStatusBar ()
		MessageBoxA (#winMain, &text$, &"Puzzle", 0)

		SetDefaultPositions ()
		SetNewPositions ()

		numMoves = 0

		text$ = "Ready"
		SetWindowTextA (#hStatusBar, &text$)
	END IF

END FUNCTION
'
'
' #############################
' #####  ValidateMove ()  #####
' #############################
'
FUNCTION  ValidateMove (x, y)

	SHARED emptyX, emptyY

	IF ((ABS(x - emptyX) = 50) || (ABS(y - emptyY) = 50)) && ((x = emptyX) || (y = emptyY)) THEN RETURN $$TRUE

END FUNCTION
'
'
' ##############################
' #####  CheckSolution ()  #####
' ##############################
'
FUNCTION  CheckSolution ()

	SHARED hButton[]
	SHARED defPosX[], defPosY[]
	RECT rc

	count = 0

	FOR i = 0 TO 14
		GetWindowRect (hButton[i], &rc)
		MapWindowPoints (NULL, #winMain, &rc, 2)
		IF (defPosX[i] = (rc.left)) && (defPosY[i] = (rc.top)) THEN
			INC count
		END IF
	NEXT i

	IF count = 15 THEN RETURN $$TRUE

END FUNCTION
'
'
' ########################
' #####  IsLegal ()  #####
' ########################
'
' Determine if configuration is legal (solvable)
'
FUNCTION  IsLegal (@data[])

' rule : if number of columns is even
'        and placement of hole row i (empty tile) is even,
'        then a legal configuration has an even
'        number of inversions

	upper = UBOUND(data[])
	FOR i = 0 TO upper-1
		x = data[i]
		FOR j = i+1 TO upper
			IF x > data[j] THEN INC invCount
		NEXT j
	NEXT i

	IFZ (invCount MOD 2) THEN
'		PRINT "invCount is Even"
		RETURN $$TRUE
	END IF

END FUNCTION
END PROGRAM
