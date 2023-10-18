'
'
' ####################
' #####  PROLOG  #####
' ####################

' A pong-like game demo. Use right/left
' arrow keys to move paddle. Program uses
' GetAsyncKeyState to get keyboard input
' and uses QueryPerformanceCounter to
' regulate game speed.
'
PROGRAM	"pong"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
  IMPORT  "msvcrt"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  RenderGame (fNewGame)
DECLARE FUNCTION  KeyPress (vk_code)
DECLARE FUNCTION  NewGame ()
DECLARE FUNCTION  EndGame ()
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
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

	SHARED width, height, fRunning
	SHARED hdc
	SHARED fNewGame
	SHARED paddleX, paddleY, ballX, ballY
	SHARED ballSize, paddleHeight, paddleWidth
	SHARED deltaX, deltaY, speed, score, lose, level
  SHARED GIANT freq, next_pc
  SHARED fPerfCount
  SHARED hArialFont

	SELECT CASE msg

		CASE $$WM_CREATE:
			hdc = GetDC (hWnd)
			fRunning = $$TRUE
			fNewGame = $$TRUE

' check to see if QueryPerformanceFrequency function is available (Pentium only)
      IFZ QueryPerformanceFrequency (&freq) THEN fPerfCount = $$TRUE
      QueryPerformanceCounter (&next_pc)

' create "GAMEOVER" font
      hArialFont = NewFont ("Arial", 36, 600, 0, 0)

		CASE $$WM_SIZE:
			width = LOWORD (lParam)
 			height = HIWORD (lParam)
	    paddleY = height - 40
      PatBlt (hdc, 0, 0, width, height, $$BLACKNESS)
	    PatBlt (hdc, ballX, ballY, ballSize, ballSize, $$DSTINVERT)
    	PatBlt (hdc, paddleX, paddleY, paddleWidth, paddleHeight, $$DSTINVERT)

		CASE $$WM_DESTROY:
			ReleaseDC (hWnd, hdc)
      DeleteObject (hArialFont)
			fRunning = $$FALSE
			PostQuitMessage (0)

    CASE $$WM_SETFOCUS:
      fRunning = $$TRUE
	    PatBlt (hdc, ballX, ballY, ballSize, ballSize, $$DSTINVERT)
    	PatBlt (hdc, paddleX, paddleY, paddleWidth, paddleHeight, $$DSTINVERT)

    CASE $$WM_KILLFOCUS:
      fRunning = $$FALSE
	    PatBlt (hdc, ballX, ballY, ballSize, ballSize, $$DSTINVERT)
    	PatBlt (hdc, paddleX, paddleY, paddleWidth, paddleHeight, $$DSTINVERT)

		CASE ELSE
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
	wc.hbrBackground   = GetStockObject ($$BLACK_BRUSH)
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
	className$  = "PongDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Pong - Use Right or Left Arrows to move bar."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 400
	h 					= 300
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
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

	SHARED fNewGame, fRunning, speed
  SHARED GIANT pc, next_pc, freq
  SHARED fPerfCount

	IF LIBRARY(0) THEN RETURN									' main program executes message loop

	DO
		hWnd = GetActiveWindow ()
		IF PeekMessageA (&msg, hWnd, 0, 0, $$PM_REMOVE) THEN
			IF msg.message = $$WM_QUIT THEN EXIT DO
			TranslateMessage (&msg)
			DispatchMessageA (&msg)
		ELSE
      IF fRunning THEN
        IFZ fPerfCount THEN
          QueryPerformanceCounter (&pc)
          IF pc > next_pc THEN
			      RenderGame (@fNewGame)
            countsPerFrame = freq/speed            ' get counts per frame
            next_pc = next_pc + countsPerFrame     ' get next count
            IF next_pc < pc THEN                   ' skip frame if we get behind
              next_pc = pc + countsPerFrame
            END IF
          END IF
        ELSE
			    RenderGame (@fNewGame)
          Sleep (1)
        END IF
      ELSE
        Sleep (0)
      END IF
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
' ###########################
' #####  RenderGame ()  #####
' ###########################
'
FUNCTION  RenderGame (@fNewGame)

	SHARED width, height, fRunning
	SHARED hdc
	SHARED paddleX, paddleY, ballX, ballY
	SHARED ballSize, paddleHeight, paddleWidth
	SHARED deltaX, deltaY, speed, score, lose, level
  SHARED GIANT next_pc
  SHARED hArialFont
  RECT rc

	IF fNewGame THEN GOSUB Initialize
	IFZ fRunning THEN RETURN

	GOSUB EraseBall
	GOSUB UpdateBall
	GOSUB DrawBall
	GOSUB ErasePaddle
  GOSUB UpdatePaddle
	GOSUB DrawPaddle
  GOSUB DrawScore

' ***** UpdatePaddle *****
SUB UpdatePaddle
	IF KeyPress ($$VK_RIGHT) THEN paddleX = paddleX + 2
	IF KeyPress ($$VK_LEFT)  THEN paddleX = paddleX - 2
END SUB

' ***** EraseBall *****
SUB EraseBall
	PatBlt (hdc, ballX, ballY, ballSize, ballSize, $$DSTINVERT)
END SUB

' ***** UpdateBall *****
SUB UpdateBall

	ballX = ballX + deltaX
	ballY = ballY + deltaY

	SELECT CASE ALL TRUE

' check for collision between ball and paddle
    CASE (ballY + ballSize = paddleY) :
      IF (ballX + ballSize >= paddleX) && (ballX <= paddleX + paddleWidth) THEN
        INC score                ' we have a collision
        deltaY = -1              ' change Y direction
        IFZ (score MOD 5) THEN   ' increase level, difficulty, and speed
          INC level
          speed = speed + 15
          GOSUB ErasePaddle
          paddleWidth = paddleWidth - 2
          IF paddleWidth < 10 THEN paddleWidth = 10
          GOSUB DrawPaddle
        END IF
      END IF

' check for game over
    CASE (ballY > height) :
      INC lose
      IF lose >= 3 THEN
        GOSUB DrawGameOverText
        Sleep (3000)
        IF EndGame () THEN
          fNewGame = $$TRUE
          QueryPerformanceCounter (&next_pc)
        ELSE
          DestroyWindow (#winMain)
        END IF
      ELSE
        ballX = rand() MOD (width - ballSize)
        ballY = 0
      END IF

		CASE (ballX + ballSize > width) :
			ballX = width - ballSize
			deltaX = -1

		CASE (ballX < 0) :
			ballX = 0
			deltaX = 1

		CASE (ballY < 0) :
			ballY = 0
			deltaY = 1

	END SELECT

END SUB

' ***** DrawBall *****
SUB DrawBall
	PatBlt (hdc, ballX, ballY, ballSize, ballSize, $$DSTINVERT)
END SUB

' ***** ErasePaddle *****
SUB ErasePaddle
	PatBlt (hdc, paddleX, paddleY, paddleWidth, paddleHeight, $$DSTINVERT)
END SUB

' ***** DrawPaddle *****
SUB DrawPaddle
  paddleX = MAX (paddleX, 0)
  paddleX = MIN (paddleX, width-paddleWidth)
	PatBlt (hdc, paddleX, paddleY, paddleWidth, paddleHeight, $$DSTINVERT)
END SUB

' ***** EraseScreen *****
SUB EraseScreen
' erase screen to black
  PatBlt (hdc, 0, 0, width, height, $$BLACKNESS)
END SUB

' ***** Initialize *****
SUB Initialize

' init random number generator
	seed = (GetTickCount () MOD 32767) + 1
	srand (seed)

' initialize variables
  fNewGame = $$FALSE
  score        = 0
  level        = 0
  lose         = 0
	speed        = 100
	ballSize     = 10
  paddleHeight = 5
	paddleWidth  = 40
	paddleX      = (width/2) - (paddleWidth/2)
	paddleY      = height - 40
  ballX        = rand() MOD (width - ballSize)
  ballY        = 0
  dir = rand() MOD 2
  IF dir THEN deltaX = 1 ELSE deltaX = -1
  deltaY       = 1

' erase screen to black
  GOSUB EraseScreen

' draw initial positions of paddle and ball
	GOSUB DrawPaddle
  GOSUB DrawBall
END SUB

' ***** DrawScore *****
SUB DrawScore
  score$ = "  SCORE = " + STRING$ (score) + "      LEVEL = " + STRING$ (level) + "  "
  GetClientRect (#winMain, &rc)
  rc.bottom = 30
  DrawTextA (hdc, &score$, LEN (score$), &rc, $$DT_SINGLELINE |	$$DT_CENTER | $$DT_VCENTER)
END SUB

' ***** DrawGameOverText *****
SUB DrawGameOverText
  hLastFont = SelectObject (hdc, hArialFont)
  lastColor = SetTextColor (hdc, RGB (255, 0, 0))
  lastBkMode = SetBkMode (hdc, $$TRANSPARENT)
  over$ = "GAMEOVER"
  GetClientRect (#winMain, &rc)
  DrawTextA (hdc, &over$, LEN (over$), &rc, $$DT_SINGLELINE |	$$DT_CENTER | $$DT_VCENTER)
  SetBkMode (hdc, lastBkMode)
  SetTextColor (hdc, lastColor)
  SelectObject (hdc, hLastFont)
END SUB


END FUNCTION
'
'
' #########################
' #####  KeyPress ()  #####
' #########################
'
FUNCTION  KeyPress (vk_code)

	IF (GetAsyncKeyState (vk_code) & 0x8000) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ########################
' #####  NewGame ()  #####
' ########################
'
FUNCTION  NewGame ()

	SHARED fRunning
	STATIC paddleX, paddleY, ballX, ballY
	STATIC ballSize, paddleHeight, paddleWidth
	STATIC deltaX, deltaY, speed, score

  IFZ fRunning THEN RETURN

  score        = 0
  paddleHeight = 30
  paddleY      = 100

  ballX = 0
  ballY = 0
  speed = 200

  deltaX = 1
  deltaY = 1

'  QueryPerformanceFrequency((LARGE_INTEGER *) &perf_cnt)
'  time_count=perf_cnt/speed        ' calculate time per frame based on frequency
'  QueryPerformanceCounter((LARGE_INTEGER *) &next_time)

'  call DrawPaddle()

END FUNCTION
'
'
' ########################
' #####  EndGame ()  #####
' ########################
'
FUNCTION  EndGame ()

  SHARED fRunning, score

  IFZ fRunning THEN RETURN

  a$ = "Your score:" + STRING$ (score) + "\nPlay again?"
  IF MessageBoxA (NULL, &a$, &"GAME OVER!", $$MB_YESNO | $$MB_ICONASTERISK) = $$IDYES THEN
    RETURN ($$TRUE)
  END IF

END FUNCTION
'
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC 					= GetDC ($$HWND_DESKTOP)
	hFont 				= GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes 				= GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName 	= fontName$														' set font name
	lf.italic 		= italic															' set italic
	lf.weight 		= weight															' set weight
	lf.underline 	= underline														' set underlined
	lf.height 		= -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72.0
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)										' create a new font and get handle


END FUNCTION
END PROGRAM
