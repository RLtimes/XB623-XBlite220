'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo of using the XBLite sprite library xsp.dll.
'
PROGRAM	"spritedemo"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library 	: required by most programs
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "xsp"       ' xsp.dll      			: Sprite library
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
DECLARE FUNCTION  Demo1 ()
DECLARE FUNCTION  LoadSprites ()
DECLARE FUNCTION  Demo2 ()
DECLARE FUNCTION  Demo3 ()
DECLARE FUNCTION  DrawColorText (hWnd, text$, x, y, txtClr, bkClr, fTransparent, font$, point, weight, fItalic, fUnderline, style)
DECLARE FUNCTION  Demo4 ()
DECLARE FUNCTION  Demo5 ()
DECLARE FUNCTION  Demo6 ()
DECLARE FUNCTION  Demo7 ()
DECLARE FUNCTION  Demo8 ()
DECLARE FUNCTION  DrawGradientFill (hWnd, r1, g1, b1, r2, g2, b2, mode)
DECLARE FUNCTION  Line (hDC, x1, y1, x2, y2)

' DrawColorText styles
$$TS_NORMAL  = 0
$$TS_LOWERED = 1
$$TS_RAISED  = 2
'
'Control IDs
'
$$Button1  = 101
$$Button2  = 102
$$Button3  = 103
$$Button4  = 104
$$Button5  = 105
$$Button6  = 106
$$Button7  = 107
$$Button8  = 108

$$Canvas1  = 110
$$Canvas2  = 120
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

	RECT rect

	SELECT CASE msg

		CASE $$WM_CREATE :

			GetClientRect (hWnd, &rect)
			bh = 22
			bw = 140
			by2 = rect.bottom - bh
			by1 = rect.bottom - bh - bh
			#hButton1 = NewChild ("button", "Demo1", $$BS_PUSHBUTTON | $$WS_TABSTOP, 0,   by1, bw, bh, hWnd, $$Button1, 0)
			#hButton2 = NewChild ("button", "Demo2", $$BS_PUSHBUTTON | $$WS_TABSTOP, 140, by1, bw, bh, hWnd, $$Button2, 0)
			#hButton3 = NewChild ("button", "Demo3", $$BS_PUSHBUTTON | $$WS_TABSTOP, 280, by1, bw, bh, hWnd, $$Button3, 0)
			#hButton4 = NewChild ("button", "Demo4", $$BS_PUSHBUTTON | $$WS_TABSTOP, 420, by1, bw, bh, hWnd, $$Button4, 0)

			#hButton5 = NewChild ("button", "Demo5", $$BS_PUSHBUTTON | $$WS_TABSTOP, 0,   by2, bw, bh, hWnd, $$Button5, 0)
			#hButton6 = NewChild ("button", "Demo6", $$BS_PUSHBUTTON | $$WS_TABSTOP, 140, by2, bw, bh, hWnd, $$Button6, 0)
			#hButton7 = NewChild ("button", "Demo7", $$BS_PUSHBUTTON | $$WS_TABSTOP, 280, by2, bw, bh, hWnd, $$Button7, 0)
			#hButton8 = NewChild ("button", "Demo8", $$BS_PUSHBUTTON | $$WS_TABSTOP, 420, by2, bw, bh, hWnd, $$Button8, 0)

			cw = rect.right
			ch = 120
			#hCanvas1 = NewChild ("static", "", $$SS_LEFT, 0, 0,   cw, ch, hWnd, $$Canvas1, $$WS_EX_STATICEDGE)
			#hCanvas2 = NewChild ("static", "", $$SS_LEFT, 0, 121, cw, ch, hWnd, $$Canvas2, $$WS_EX_STATICEDGE)

			LoadSprites ()					' load required sprites into memory bitmaps


		CASE $$WM_DESTROY :
			XspUnloadSprites ()			' delete all sprite objects
'			DeleteObject (#hFontArial)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE hwndCtl
						CASE #hButton1 : Demo1 ()
						CASE #hButton2 : Demo2 ()
						CASE #hButton3 : Demo3 ()
						CASE #hButton4 : Demo4 ()
						CASE #hButton5 : Demo5 ()
						CASE #hButton6 : Demo6 ()
						CASE #hButton7 : Demo7 ()
						CASE #hButton8 : Demo8 ()
					END SELECT
					RETURN
			END SELECT

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
	className$  = "SpriteDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Sprite Library Demo."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 568
	h 					= 312
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
		ret = GetMessageA (&msg, NULL, 0, 0)

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
' ######################
' #####  Demo1 ()  #####
' ######################
'
FUNCTION  Demo1 ()

' ***** Demo1 *****
' Set background sprite bitmap and then draw a few sprites
' onto background in various scales and orientations

' Initialize background first
	sID = 2
	XspSetBackgroundBmp (#hCanvas1, sID)			' Sprite IDs are zero based - 0, 1, 2...

' Add some sprites of various sizes and orientations
	XspDrawSprite (#hCanvas1, 0, 50, 25, 0)		' 0=normal 1=mirror 2=flip 3=180
	XspDrawSprite (#hCanvas1, 0, 100, 25, 1)
	XspDrawSprite (#hCanvas1, 0, 150, 25, 2)
	XspDrawSprite (#hCanvas1, 0, 200, 25, 3)

	XspSetSpriteScale (#clone0, 70)						' scale clone0 sprite using percentage
	XspDrawSprite (#hCanvas1, #clone0, 250, 25, 0)
	XspSetSpriteScale (#clone0, 130)					' scale clone0 sprite using percentage
	XspDrawSprite (#hCanvas1, #clone0, 300, 25, 0)

' Update screen
	XspRefreshScreen (#hCanvas1)							' always use RefreshScreen to draw all sprites to physical screen

END FUNCTION
'
'
' ############################
' #####  LoadSprites ()  #####
' ############################
'
FUNCTION  LoadSprites ()

' Load sprite bmp images into memory with XspLoadSpriteBmp().
' The sprites are not drawn yet.
' Background sprite images do not have masks.
' Sprite images must have masks, usually the sprite bitmap
' has two images. The top image is the mask, which is the
' shape of the sprite in black against a white background.
' The bottom image is the sprite against a black background.

	dir$ = "/xblite/images/"
	fileName$ = dir$ + "cave1.bmp"
	ret = XspLoadSpriteBmp (#hCanvas1, fileName$, @sID)

	fileName$ = dir$ + "cave2.bmp"
	ret = XspLoadSpriteBmp (#hCanvas1, fileName$, @sID)

	fileName$ = dir$ + "bg1.bmp"
	ret = XspLoadSpriteBmp (#hCanvas1, fileName$, @sID)

	fileName$ = dir$ + "bg2.bmp"
	ret = XspLoadSpriteBmp (#hCanvas1, fileName$, @sID)

	fileName$ = dir$ + "rock.bmp"
	ret = XspLoadSpriteBmp (#hCanvas1, fileName$, @#rock)

'clone caveman sprites so we can have two of them at the same time
'save sID's as clone0 and clone 1 in STATIC variables
	XspCloneSprite (0, @#clone0)					'clone first sprite so we can have two sprites running in the grid
	XspCloneSprite (1, @#clone1)					'clone second sprite

' print sprite info
'	sID = 0
'	DO
'		ret = XspGetSpriteInfo (sID, @fileName$, @hWnd, @hMemBmp, @w, @h, @x, @y, @dx, @dy)
'		IF ret = 0 THEN EXIT DO
'		PRINT "sprite ID        : "; sID
'		PRINT	"filename         : "; fileName$  	'file name
'		PRINT	"bmp width        : "; w  					'BMP width
'		PRINT	"bmp height       : "; h						'BMP height
'		PRINT "hWnd             : "; hWnd					'window handle
'		PRINT	"memory bitmap    : "; hMemBmp  		'bmp image grid number
'		INC sID
'	LOOP

END FUNCTION
'
'
' ######################
' #####  Demo2 ()  #####
' ######################
'
FUNCTION  Demo2 ()

' Animate various sprites against a static bmp background
' at different speeds and scales

	XspSetBackgroundBmp (#hCanvas1, 3)					' Initialize background first
	XspGetStageSize (#hCanvas1, @w, @h)					' get w and h of window
	DO WHILE sx < w + 10															' animate sprite moving right
  	IF sID = 0 THEN sID = 1 ELSE sID = 0			' alternate between 2 sprites
    IF sy = 20 THEN sy = 5 ELSE sy = 20				' change y location each loop
		XspDrawSprite (#hCanvas1, sID, sx, sy, 0)	' draw sprite position in window
		XspRefreshScreen (#hCanvas1)							' draw current image to window
    XspPause (100)														' add Pause(msec) to slow animation
    sx = sx + 10															' move sprite to next x location
	LOOP

	XspSetBackgroundBmp (#hCanvas1, 2)					' Always set background sprite first
	sx1 = w - 150																' set 1st sprite starting x position
	sx2 = w																			' set 2nd sprite starting x position
	XspGetSpriteInfo (0, gn$, 0, 0, @sw, @sh, 0, 0, 0, 0)	' get sprite width
	XspSetSpriteScale (#clone0, 75)							' set sprite clone0 scale
	XspSetSpriteScale (#clone1, 75)							' set sprite clone1 scale

	DO WHILE sx1 > 0 - sw - 10									' animate sprite moving left
  	IF sID1 = 0 THEN sID1 = 1 ELSE sID1 = 0		' alternate between 2 sprites
  	IF sID2 = #clone0 THEN										' alternate between 2 sprites
			sID2 = #clone1
		ELSE
			sID2 = #clone0
		END IF
    IF sy1 = 50 THEN sy1 = 35 ELSE sy1 = 50		' change y location each loop
    IF sy2 = 25 THEN sy2 = 15 ELSE sy2 = 25		' change y location each loop
		XspDrawSprite (#hCanvas1, sID2, sx2, sy2, 1)	' draw 1st sprite position
		XspDrawSprite (#hCanvas1, sID1, sx1, sy1, 1)	' draw 2nd sprite position
		XspRefreshScreen (#hCanvas1)									' draw current image to window
    XspPause (100)														' add Pause(msec) to slow animation
    sx1 = sx1 - 7															' move sprite to next x location
		sx2 = sx2 - 12														' move 2nd sprite faster
	LOOP

	XspSetSpriteScale (#clone0, 140)							' set sprite clone0 scale
	XspDrawSprite (#hCanvas1, #clone0, 20, 15, 3)	' draw sprite upside down
	XspRefreshScreen (#hCanvas1)									' draw current image to window


END FUNCTION
'
'
' ######################
' #####  Demo3 ()  #####
' ######################
'
FUNCTION  Demo3 ()

	RECT rect

' Animate a sprite against a drawn background
' and then draw a border, text, and some static sprites
' to the background. This shows that any kind of
' graphic can be drawn and captured as a background.
'

	r1 = 255 : g1 = 100 : b1 = 100
	r2 = 0   : g2 = 0  : b2 = 0
	DrawGradientFill (#hCanvas1, r1, g1, b1, r2, g2, b2, 0)	' draw a gradient background
	XspCaptureBackground (#hCanvas1)							' capture drawn background first to initialize scrGrid array
	XspGetStageSize (#hCanvas1, @w, @h)						' get window w and h

	DO WHILE rx < w + 20 													' animate sprite moving right
  	IF sID = 0 THEN sID = 1 ELSE sID = 0				' alternate between 2 sprites
    IF ry = 35 THEN ry = 20 ELSE ry = 35				' change y location each loop
		XspDrawSprite (#hCanvas1, sID, rx, ry, 0)		' draw sprite position in window
		XspRefreshScreen (#hCanvas1)								' update current image in window
    XspPause (100)															' add Pause(msec) to slow animation
    rx = rx + 10																' move sprite to next x location
	LOOP

	text$ = ">>>Sprites are Fun!<<<"							' add text to background
	DrawColorText (#hCanvas1, text$, 100, 0, RGB(255, 255, 0), -1, $$TRUE, "Arial", 18, $$FW_BOLD, 1, 1, 0)

	hdc = GetDC (#hCanvas1)
	GetClientRect (#hCanvas1, &rect)
	DrawEdge (hdc, &rect, $$EDGE_BUMP, $$BF_RECT)	' draw a new border
	ReleaseDC (#hCanvas1, hdc)

	XspCaptureBackground (#hCanvas1)							' capture new background

	XspAddSpriteToBackground (#hCanvas1, 0, 90, 40, 100, 0)		' add a permanant sprite to background
	XspAddSpriteToBackground (#hCanvas1, 0, 320, 40, 100, 1)	' add a permanant sprite to background

	rx = w 																				' set initial sprite x position
	DO WHILE rx > 0 															' animate sprite moving left
  	IF sID = 0 THEN sID = 1 ELSE sID = 0				' alternate between 2 sprites
    IF ry = 35 THEN ry = 20 ELSE ry = 35				' change y location each loop
		XspDrawSprite (#hCanvas1, sID, rx, ry, 1)		' draw sprite position in window
		XspRefreshScreen (#hCanvas1)								' update current image in window
    XspPause (100)															' add Pause(msec) to slow animation
    rx = rx - 10																' move sprite to next x location
	LOOP


END FUNCTION
'
'
' ##############################
' #####  DrawColorText ()  #####
' ##############################
'
' PURPOSE	:	Draw text at position x, y with various style and font options
' IN	:	hWnd					window handle
'				text$					text to draw
'				x, y					position to draw text
'				txtClr				text color,	-1 = use default
'				bkClr					background color,  -1 = use default
'				fTransparent	draw text transparently, leave bg unchanged,  $$TRUE=on, $$FALSE=off
'				font$					name of font
'       point					font point size,  default is 10
'				weight				font weight,  default is FW_NORMAL
'				fItalic				draw italic, $$TRUE=on, $$FALSE=off
'				fUnderline		draw underline, $$TRUE=on, $$FALSE=off
'				style					text style,  0=normal flat, 1=lowered, 2=raised
' 										text style constants
' 										$$TS_NORMAL = 0
' 										$$TS_LOWERED = 1
' 										$$TS_RAISED = 2

FUNCTION  DrawColorText (hWnd, text$, x, y, txtClr, bkClr, fTransparent, font$, point, weight, fItalic, fUnderline, style)

	LOGFONT lf

	hDC = GetDC (hWnd)
	IF style > 2 THEN style = 0

	IF font$ THEN
		IFZ point THEN point = 10
		IFZ weight THEN weight = $$FW_NORMAL
		hFont = GetStockObject($$DEFAULT_GUI_FONT)	' get a font handle
		bytes = GetObjectA(hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
		lf.faceName = font$													' set font name
		lf.italic = fItalic													' set italic
		lf.weight = weight													' set weight
		lf.underline = fUnderline										' set underline
		lf.height = -1 * point * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
		hFont = CreateFontIndirectA (&lf)						' create a new font and get handle
		oldFont = SelectObject (hDC, hFont)
	END IF

	IF txtClr != -1 THEN
		oldTextColor = SetTextColor (hDC, txtClr)
	END IF
	IF bkClr != -1 THEN
		oldBkColor   = SetBkColor (hDC, bkClr)
	END IF

	IF fTransparent THEN
		lastBkMode = SetBkMode (hDC, $$TRANSPARENT)
	END IF

	SELECT CASE style
		CASE $$TS_NORMAL : 	TextOutA (hDC, x, y, &text$, LEN(text$))
		CASE $$TS_LOWERED :
			lastColor =SetTextColor (hDC, RGB (255, 255, 255))
			TextOutA (hDC, x+1, y+1, &text$, LEN(text$))
			SetTextColor (hDC, lastColor)
			SetBkMode (hDC, $$TRANSPARENT)
			TextOutA (hDC, x, y, &text$, LEN(text$))
			SetBkMode (hDC, $$OPAQUE)
		CASE $$TS_RAISED :
			TextOutA (hDC, x+1, y+1, &text$, LEN(text$))
			lastColor = SetTextColor (hDC, RGB (255, 255, 255))
			SetBkMode (hDC, $$TRANSPARENT)
			TextOutA (hDC, x, y, &text$, LEN(text$))
			SetTextColor (hDC, lastColor)
			SetBkMode (hDC, $$OPAQUE)
	END SELECT

	IF oldBkColor THEN SetBkColor (hDC, oldBkColor)
	IF oldTxtColor THEN SetTextColor (hDC, oldTextColor)

	IF lastBkMode THEN SetBkMode (hDC, lastBkMode)

	IF font$ THEN
		SelectObject (hDC, oldFont)
		DeleteObject (hFont)
	END IF
	ReleaseDC (hWnd, hDC)
END FUNCTION
'
'
' ######################
' #####  Demo4 ()  #####
' ######################
'
FUNCTION  Demo4 ()

' Animate a sprite against a scrolling bmp background.
' Then change bmp background and scroll in a different direction.

	XspSetBackgroundBmp (#hCanvas1, 2)							' initialize by setting background sprite
	XspRefreshScreen (#hCanvas1)										' update screen
	delta = 10
	XspGetStageSize (#hCanvas1, @w, @h)							' get window w and h
	FOR dx = 0 TO w+delta STEP delta
		XspScrollBackground (#hCanvas1, dx, 0)				' scroll background left BEFORE drawing and sprites
																									' dx, dy must be > 0
  	IF sID = 0 THEN sID = 1 ELSE sID = 0					' alternate between 2 sprites
    IF ry = 35 THEN ry = 20 ELSE ry = 35					' change y location each loop
		XspDrawSprite (#hCanvas1, sID, 200, ry, 0)		' set sprite position in window
		XspRefreshScreen (#hCanvas1)									' update screen
		XspPause (100)																' slow it down
	NEXT dx

	XspSetBackgroundBmp (#hCanvas1, 3)							' change to a new background
	XspRefreshScreen (#hCanvas1)										' update screen
	FOR dx = w+delta TO 0 STEP -1*delta							' animate
		XspScrollBackground (#hCanvas1, dx, 0)				' scroll background right BEFORE drawing and sprites
  	IF sID = 0 THEN sID = 1 ELSE sID = 0					' alternate between 2 sprites
    IF ry = 35 THEN ry = 20 ELSE ry = 35					' change y location each loop
		XspDrawSprite (#hCanvas1, sID, 200, ry, 1)		' draw sprite at x y position in window
		XspRefreshScreen (#hCanvas1)									' update screen
		XspPause (100)																' slow it down
	NEXT dx


END FUNCTION
'
'
' ######################
' #####  Demo5 ()  #####
' ######################
'
FUNCTION  Demo5 ()

' Set up an animation sequence to automatically move
' sprites using XspDrawSpriteAnimation().

	XspSetBackgroundBmp (#hCanvas1, 2)								' initialize by setting background sprite
	XspRefreshScreen (#hCanvas1)											' update screen

	DIM sequence[2]																		' DIM sequence array for 2 sprites
	sequence[0] = 0																		' set sID for first sprite in sequence
	sequence[1] = 1																		' set sID for second sprite in sequence
	XspSetSpriteSequence (0, @sequence[])							' set first sID in animation with arrary

	XspSetSpritePositionAndSpeed (0, 0, 20, 10, 15)		' set first sprite initial position
	XspSetSpritePositionAndSpeed (1, 0, 35, 10, -15)	' set second sprite initial position

	XspSetSpriteOrientation (#clone0, 1)							' set first clone orientation to mirror
	XspSetSpriteOrientation (#clone1, 1)							' set second clone orientation to mirror
	XspSetSpriteScale (#clone0, 100)									' set sprite scale
	XspSetSpriteScale (#clone1, 100)

	XspGetSpriteInfo (#clone0, @fn$, 0, 0, @sw, @sh, 0, 0, 0, 0)
	XspGetStageSize (#hCanvas1, @w, @h)
	XspSetSpritePositionAndSpeed (#clone0, w-sw, 20, -10, 15)		' set first clone sprite initial position and speed
	XspSetSpritePositionAndSpeed (#clone1, w-sw, 35, -10, -15)	' set second clone sprite initial position and speed
	XspGetSpritePositionAndSpeed (#clone0, @x, @y, @dx, @dy)	' set second clone sprite initial position and speed

	sequence[0] = #clone0															' set sID for first clone sprite in sequence
	sequence[1] = #clone1															' set sID for second clonesprite in sequence
	XspSetSpriteSequence (#clone0, @sequence[])				' set first sID in animation with arrary

	sID1 = 0
	sID2 = #clone0
	FOR i = 0 TO 23
		XspStartSpriteAnimation (0)											' initialize sprite animation cycle
		XspDrawSpriteAnimation (#hCanvas1, @sID1, 0, 1)	' draw sprite animation beginning at sID and direction (0=forward, 1=backward), 1 repeat for each frame
		XspStartSpriteAnimation (#clone0)								' start 1 clone0 sprite animation cycle
		XspDrawSpriteAnimation (#hCanvas1, @sID2, 0, 1)	' draw cloned sprite animation
		XspRefreshScreen (#hCanvas1)										' update screen
		XspPause (100)																	' slow it down
	NEXT i

	XspGetSpritePositionAndSpeed (0, @x, @y, @dx, @dy)	' reverse direction
	XspSetSpritePositionAndSpeed (0, x, y, -10, 15)			' set sprite speed in first sprite
	XspGetSpritePositionAndSpeed (1, @x, @y, @dx, @dy)
	XspSetSpritePositionAndSpeed (1, x, y, -10, -15)		' set sprite speed in second sprite

	XspGetSpritePositionAndSpeed (#clone0, @x, @y, @dx, @dy)	'set clone in reverse direction																								'reverse direction
	XspSetSpritePositionAndSpeed (#clone0, x, y, 10, 15)
	XspGetSpritePositionAndSpeed (#clone1, @x, @y, @dx, @dy)
	XspSetSpritePositionAndSpeed (#clone1, x, y, 10, -15)

	sID1 = 0
	sID2 = #clone0
	FOR i = 0 TO 23
		XspStartSpriteAnimation (0)
		XspDrawSpriteAnimation (#hCanvas1, @sID1, 0, 1)		' draw sprite animation beginning at sID and direction (0=forward, 1=backward)
		XspStartSpriteAnimation (#clone0)
		XspDrawSpriteAnimation (#hCanvas1, @sID2, 0, 1)
		XspRefreshScreen (#hCanvas1)											' update screen
		XspPause (100)																		' slow it down
	NEXT i

END FUNCTION
'
'
' ######################
' #####  Demo6 ()  #####
' ######################
'
FUNCTION  Demo6 ()

' Demo of collision detection between two sprites

	XspSetBackgroundBmp (#hCanvas1, 2)							' initialize by setting background sprite
	XspRefreshScreen (#hCanvas1)										' update screen

	XspGetStageSize (#hCanvas1, @w, @h)							' get window w and h
	sx = -30
	rx = w + 30
	DO WHILE sx < w 																' animate sprite moving right
  	IF sID = 0 THEN sID = 1 ELSE sID = 0					' alternate between 2 sprites
    IF sy = 35 THEN sy = 20 ELSE sy = 35					' change y location each loop
		XspDrawSprite (#hCanvas1, sID, sx, sy, 0)			' draw sprite position in window
		XspDrawSprite (#hCanvas1, #rock, rx, 35, 0)		' draw rock sprite
		XspRefreshScreen (#hCanvas1)									' update screen
		ret = XspDetectCollision (sID, #rock)					' detect collision between sprites and rock
		IF ret THEN EXIT DO														' exit loop after refreshing screen
    XspPause (100)																' add XspPause(msec) to slow animation
    sx = sx + 10																	' move sprite to next x location
		rx = rx - 5
	LOOP

	IF ret THEN
		FOR ry = 45 TO 75 STEP 5
			XspDrawSprite (#hCanvas1, sID, sx, sy, 0)		' draw sprite in last position
			XspDrawSprite (#hCanvas1, #rock, rx, ry, 0)	' drop the rock
			XspRefreshScreen (#hCanvas1)								' update screen
			XspPause (60)
		NEXT
	END IF




END FUNCTION
'
'
' ######################
' #####  Demo7 ()  #####
' ######################
'
FUNCTION  Demo7 ()

' Demo of using sprites in two windows at same time

	XspSetSpriteScale (#clone0, 100)									' set scale to 100
	XspSetSpriteScale (#clone1, 100)									' set scale to 100

	XspSetBackgroundBmp (#hCanvas1, 2)								' initialize by setting background sprite
	XspSetBackgroundBmp (#hCanvas2, 3)								' initialize by setting background sprite

	XspRefreshScreen (#hCanvas1)											' update canvas1
	XspRefreshScreen (#hCanvas2)											' update canvas2

	delta = 10																				' set scrolling increment
	XspGetStageSize (#hCanvas1, @w, @h)								' get window w and h
	XspGetSpriteInfo (#clone0, @fn$, 0, 0, @sw, @sh, 0, 0, 0, 0)
	sx2 = w																						' set initial x position for clones
	sx1 = -sw																					' set initial x position for sprites
	dx2 = w
	FOR dx1 = 0 TO w STEP delta
		XspScrollBackground (#hCanvas1, dx1, 0)					' scroll background left BEFORE drawing and sprites
		XspScrollBackground (#hCanvas2, dx2, 0)					' scroll background right BEFORE drawing and sprites
  	IF sID1 = 0 THEN sID1 = 1 ELSE sID1 = 0					' alternate between 2 sprites
  	IF sID2 = #clone0 THEN sID2 = #clone1 ELSE sID2 = #clone0		' alternate between 2 sprites
    IF sy = 35 THEN sy = 20 ELSE sy = 35						' change y location each loop
		XspDrawSprite (#hCanvas1, sID1, sx1, sy, 0)			' set sprite position in window
		XspDrawSprite (#hCanvas2, sID2, sx2, sy, 1)			' set sprite position in window
		XspRefreshScreen (#hCanvas1)										' update screen
		XspRefreshScreen (#hCanvas2)										' update screen
		XspPause (100)																	' slow it down
		sx1 = sx1 + 10																	' increment sprite x
		sx2 = sx2 - 10																	' increment clone x
		dx2 = dx2 - delta																' decrement scroll background dx position for clone grid
	NEXT dx1


END FUNCTION
'
'
' ######################
' #####  Demo8 ()  #####
' ######################
'
FUNCTION  Demo8 ()
'
' Draw a looping animation that
' uses XspDrawSpriteRange().

	XspSetBackgroundBmp (#hCanvas2, 2)							' initialize by setting background sprite
	XspRefreshScreen (#hCanvas2)										' update screen

	XspSetSpritePositionAndSpeed (0, 100, 50, 20, 0)
	XspSetSpritePositionAndSpeed (1, 100, 35, 20, 0)

	XspSetSpriteRange (0, 100, 300, yMin, yMax)
	XspSetSpriteRange (1, 100, 300, yMin, yMax)

	XspSetSpritePositionAndSpeed (#rock, 350, 10, 20, 10)
	XspSetSpriteRange (#rock, 350, 450, 0, 80)

	FOR i = 0 TO 100
  	IF sID = 0 THEN sID = 1 ELSE sID = 0				' alternate between 2 sprites
		XspDrawSpriteRange (#hCanvas2, sID, 0, $$TRUE)	' draw sprite 0/1 within preset range
		XspDrawSpriteRange (#hCanvas2, #rock, 2, $$FALSE)	' draw sprite #rock within x/y ranges
		XspRefreshScreen (#hCanvas2)								' draw current image to window
    XspPause (100)															' add Pause(msec) to slow animation
	NEXT


END FUNCTION
'
'
' #################################
' #####  DrawGradientFill ()  #####
' #################################
'
'PURPOSE : Draw a gradient background from color1 to color2
'IN      : hWnd, r1, g1, b1, r2, g2, b2, mode (0 = vertical, 1 = horizontal)
'
FUNCTION  DrawGradientFill (hWnd, r1, g1, b1, r2, g2, b2, mode)

	DOUBLE sRedHor, sGreenHor, sBlueHor
	DOUBLE sRedVert, sGreenVert, sBlueVert
	DOUBLE width, height
	DOUBLE deltaRed, deltaGreen, deltaBlue
	RECT rect

	IFZ hWnd THEN RETURN

'Get window width & height
	GetClientRect (hWnd, &rect)
	width = rect.right - rect.left - 1
	height = rect.bottom - rect.top - 1

	deltaRed 		= r2 - r1
	deltaGreen 	= g2 - g1
	deltaBlue 	= b2 - b1

	sRedHor 		=	deltaRed/width
	sGreenHor 	= deltaGreen/width
	sBlueHor 		= deltaBlue/width

	sRedVert 		= deltaRed/height
	sGreenVert 	= deltaGreen/height
	sBlueVert 	=	deltaBlue/height

	hdc = GetDC (hWnd)

	IFZ mode THEN
		FOR i = 0 TO height
			red = r1 + i * sRedVert
			green = g1 + i * sGreenVert
			blue = b1 + i * sBlueVert
			hPen = CreatePen ($$PS_SOLID, 1, RGB(red, green, blue))
			hPenOld = SelectObject (hdc, hPen)
			Line (hdc, 0, i, width+1, i)
			SelectObject (hdc, hPenOld)
			DeleteObject (hPen)
		NEXT i
	ELSE
		FOR i = 0 TO width
			red = r1 + i * sRedHor
			green = g1 + i * sGreenHor
			blue = b1 + i * sBlueHor
			hPen = CreatePen ($$PS_SOLID, 1, RGB(red, green, blue))
			hPenOld = SelectObject (hdc, hPen)
			Line (hdc, i, 0, i, height+1)
			SelectObject (hdc, hPenOld)
			DeleteObject (hPen)
		NEXT i
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################
' #####  Line ()  #####
' #####################
'
FUNCTION  Line (hDC, x1, y1, x2, y2)

	MoveToEx (hDC, x1, y1, 0)
	LineTo (hDC, x2, y2)

END FUNCTION
END PROGRAM
