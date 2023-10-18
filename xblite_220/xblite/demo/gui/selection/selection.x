'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo of drawing various selection areas
' using the mouse and drawing "rubber-band"
' lines, circles or rectangles.
' A menu is created from data in a resource file.
'
PROGRAM	"selection"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll

TYPE MPOINT
	SSHORT	.x
	SSHORT	.y
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
DECLARE FUNCTION  MAKEMPOINT (lParam, MPOINT mpt)
DECLARE FUNCTION  StartSelection (hWnd, MPOINT ptCurrent, RECT selectRect, flags)
DECLARE FUNCTION  UpdateSelection (hWnd, MPOINT ptCurrent, RECT selectRect, flags)
DECLARE FUNCTION  EndSelection (MPOINT ptCurrent, RECT selectRect)
DECLARE FUNCTION  ClearSelection (hWnd, RECT selectRect, flags)

'Control IDs
$$Options        = 101
$$Options_Box    = 102
$$Options_Block  = 103
$$Options_Dotted = 104
$$Options_Circle = 107
$$Options_Retain = 105
$$Options_Exit   = 106

' These defines determine the meaning of the flags variable.
' The low byte is used for the various types of "boxes" to draw.
' The high byte is available for special commands.

$$SL_BOX    = 1             ' Draw a solid border rectangle
$$SL_BLOCK  = 2             ' Draw a solid filled rectangle
$$SL_DOTTED_LINE = 3				' Draw a dotted rectangle
$$SL_CIRCLE = 4							' Draw a circle

$$SL_EXTEND = 256           ' Extend the current pattern

$$SL_TYPE    = 0x00FF       ' Mask out everything but the type flags
$$SL_SPECIAL = 0xFF00       ' Mask out everything but the special flags
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

'MESSAGES:

' WM_SYSCOMMAND - system menu (About dialog box)
' WM_CREATE     - create window
' WM_DESTROY    - destroy window
' WM_LBUTTONDOWN - left mouse button
' WM_MOUSEMOVE   - mouse movement
' WM_LBUTTONUP   - left button released

' WM_COMMAND messages:
'     IDM_BOX    - use inverted box for selecting region
'     IDM_BLOCK  - use empty box for selecting a region
'     IDM_RETAIN - retain/delete selection on button release

'
' COMMENTS:

' When the left mouse button is pressed, btrack is set to TRUE so that
' the code for WM_MOUSEMOVE will keep track of the mouse and update the
' box accordingly.  Once the button is released, btrack is set to
' FALSE, and the current position is saved.  Holding the SHIFT key
' while pressing the left button will extend the current box rather
' then erasing it and starting a new one.  The exception is when the
' retain shape option is enabled.  With this option, the rectangle is
' zeroed whenever the mouse is released so that it can not be erased or
' extended.

'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	STATIC retainShape, bTrack
	SHARED lastShape, shape
	STATIC RECT rect
	MPOINT mpoint

	SELECT CASE msg

		CASE $$WM_CREATE :
			bTrack = $$FALSE
			shape = $$SL_BLOCK
			retainShape = $$FALSE

		CASE $$WM_DESTROY :
			PostQuitMessage (0)

		CASE $$WM_COMMAND :
			id         = LOWORD (wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD (wParam)

			SELECT CASE id
				CASE $$Options_Exit :
					PostQuitMessage (0)

				CASE $$Options_Box:
					shape = $$SL_BOX
					hMenu = GetMenu (hWnd)
					CheckMenuItem (hMenu, $$Options_Box, $$MF_CHECKED)
					CheckMenuItem (hMenu, $$Options_Block, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Dotted, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Circle, $$MF_UNCHECKED)

				CASE $$Options_Block:
					shape = $$SL_BLOCK
					hMenu = GetMenu (hWnd)
					CheckMenuItem (hMenu, $$Options_Box, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Block, $$MF_CHECKED)
					CheckMenuItem (hMenu, $$Options_Dotted, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Circle, $$MF_UNCHECKED)

				CASE $$Options_Dotted:
					shape = $$SL_DOTTED_LINE
					hMenu = GetMenu (hWnd)
					CheckMenuItem (hMenu, $$Options_Box, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Block, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Dotted, $$MF_CHECKED)
					CheckMenuItem (hMenu, $$Options_Circle, $$MF_UNCHECKED)

				CASE $$Options_Circle:
					shape = $$SL_CIRCLE
					hMenu = GetMenu (hWnd)
					CheckMenuItem (hMenu, $$Options_Box, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Block, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Dotted, $$MF_UNCHECKED)
					CheckMenuItem (hMenu, $$Options_Circle, $$MF_CHECKED)

				CASE $$Options_Retain:
					IF retainShape THEN
						hMenu = GetMenu (hWnd)
						CheckMenuItem (hMenu, $$Options_Retain, $$MF_UNCHECKED)
						retainShape = $$FALSE
					ELSE
						hMenu = GetMenu (hWnd)
						CheckMenuItem (hMenu, $$Options_Retain, $$MF_CHECKED)
						retainShape = $$TRUE
					END IF
				END SELECT

		CASE $$WM_LBUTTONDOWN :

			bTrack = $$TRUE               ' user has pressed the left button

' If you don't want the shape cleared, you must clear the rect
' coordinates before calling StartSelection
'
			IF (retainShape) THEN SetRectEmpty (&rect)
			IF (wParam & $$MK_SHIFT) THEN
				flags = $$SL_EXTEND | shape
			ELSE
				flags = shape
			END IF
			MAKEMPOINT(lParam, @mpoint)
			StartSelection (hWnd, mpoint, @rect, flags)

		CASE $$WM_MOUSEMOVE:
			IF (bTrack) THEN
				MAKEMPOINT(lParam, @mpoint)
				UpdateSelection (hWnd, mpoint, @rect, shape)
			END IF

		CASE $$WM_LBUTTONUP:
			IF (bTrack) THEN
				MAKEMPOINT(lParam, @mpoint)
				lastShape = shape
				EndSelection (mpoint, @rect)
			END IF
			bTrack = $$FALSE

		CASE $$WM_SIZE:
			SELECT CASE wParam
				CASE $$SIZEICONIC:

          ' If we aren't in retain mode we want to clear the
          ' current rectangle now!

					IF (!retainShape) THEN SetRectEmpty (&rect)
			END SELECT

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
FUNCTION  InitGui ()

	SHARED hInst

' get current instance handle
	hInst = GetModuleHandleA (0)
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
	wc.hbrBackground   = GetStockObject ($$WHITE_BRUSH)
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
	className$  = "SelectionDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "menu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Selection Area Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 450
	h 					= 400
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
		ret = GetMessageA (&msg, 0, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
  			TranslateMessage (&msg)
  			DispatchMessageA (&msg)
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
' ###########################
' #####  MAKEMPOINT ()  #####
' ###########################
'
FUNCTION  MAKEMPOINT (lParam, MPOINT mpt)

	mpt.x = LOWORD(lParam)
	mpt.y = HIWORD(lParam)

END FUNCTION
'
'
' ###############################
' #####  StartSelection ()  #####
' ###############################

' PURPOSE: Begin selection of region
'
FUNCTION  StartSelection (hWnd, MPOINT ptCurrent, RECT selectRect, flags)

	IF (selectRect.left != selectRect.right || selectRect.top != selectRect.bottom) THEN
		ClearSelection (hWnd, selectRect, flags)
	END IF

	selectRect.right = ptCurrent.x
	selectRect.bottom = ptCurrent.y

' If you are extending the box, then invert the current rectangle

	IF ((flags & $$SL_SPECIAL) == $$SL_EXTEND) THEN
		ClearSelection (hWnd, selectRect, flags)

' Otherwise, set origin to current location

	ELSE
		selectRect.left = ptCurrent.x
		selectRect.top = ptCurrent.y
	END IF

' capture mouse movement for this window

	SetCapture (hWnd)
	RETURN 1

END FUNCTION
'
'
' ################################
' #####  UpdateSelection ()  #####
' ################################

' PURPOSE: Update selection
'
FUNCTION  UpdateSelection (hWnd, MPOINT ptCurrent, RECT selectRect, flags)

	RECT rect
	hDC = GetDC (hWnd)

	SELECT CASE (flags & $$SL_TYPE)

		CASE $$SL_BOX:
			OldROP = SetROP2 (hDC, $$R2_NOTXORPEN)
			MoveToEx (hDC, selectRect.left, selectRect.top, 0)
			LineTo (hDC, selectRect.right, selectRect.top)
			LineTo (hDC, selectRect.right, selectRect.bottom)
			LineTo (hDC, selectRect.left, selectRect.bottom)
			LineTo (hDC, selectRect.left, selectRect.top)
			LineTo (hDC, ptCurrent.x, selectRect.top)
			LineTo (hDC, ptCurrent.x, ptCurrent.y)
			LineTo (hDC, selectRect.left, ptCurrent.y)
			LineTo (hDC, selectRect.left, selectRect.top)
			SetROP2	(hDC, OldROP)

		CASE $$SL_BLOCK:
			PatBlt (hDC, selectRect.left, selectRect.bottom, selectRect.right - selectRect.left, ptCurrent.y - selectRect.bottom, $$DSTINVERT)
			PatBlt (hDC, selectRect.right, selectRect.top, ptCurrent.x - selectRect.right, ptCurrent.y - selectRect.top, $$DSTINVERT)

		CASE $$SL_DOTTED_LINE:
			DrawFocusRect (hDC, &selectRect)
			rect.left 	= selectRect.left
			rect.top 		= selectRect.top
			rect.right 	= ptCurrent.x
			rect.bottom = ptCurrent.y
			DrawFocusRect (hDC, &rect)

		CASE $$SL_CIRCLE :
			OldROP = SetROP2 (hDC, $$R2_NOTXORPEN)
			Ellipse (hDC, selectRect.left, selectRect.top, selectRect.right, selectRect.bottom)
			Ellipse (hDC, selectRect.left, selectRect.top, ptCurrent.x, ptCurrent.y)
			SetROP2	(hDC, OldROP)
	END SELECT

	selectRect.right = ptCurrent.x
	selectRect.bottom = ptCurrent.y
	ReleaseDC (hWnd, hDC)
	RETURN 1

END FUNCTION
'
'
' #############################
' #####  EndSelection ()  #####
' #############################

' PURPOSE: End selection of region, release capture of mouse movement
'
FUNCTION  EndSelection (MPOINT ptCurrent, RECT selectRect)

	selectRect.right = ptCurrent.x
	selectRect.bottom = ptCurrent.y
	ReleaseCapture ()
	RETURN 1

END FUNCTION
'
'
' ###############################
' #####  ClearSelection ()  #####
' ###############################
'
' PURPOSE: Clear the current selection
'
FUNCTION  ClearSelection (hWnd, RECT selectRect, flags)

	SHARED lastShape, shape

	IF lastShape <> shape THEN flags = lastShape		' make sure last selection is properly erased

	hDC = GetDC (hWnd)
	SELECT CASE (flags & $$SL_TYPE)

		CASE $$SL_BOX:
			OldROP = SetROP2 (hDC, $$R2_NOTXORPEN)
			MoveToEx (hDC, selectRect.left, selectRect.top, NULL)
			LineTo (hDC, selectRect.right, selectRect.top)
			LineTo (hDC, selectRect.right, selectRect.bottom)
			LineTo (hDC, selectRect.left, selectRect.bottom)
			LineTo (hDC, selectRect.left, selectRect.top)
			SetROP2 (hDC, OldROP)

		CASE $$SL_BLOCK:
			PatBlt (hDC, selectRect.left, selectRect.top, selectRect.right - selectRect.left, selectRect.bottom - selectRect.top, $$DSTINVERT)

		CASE $$SL_DOTTED_LINE:
			DrawFocusRect (hDC, &selectRect)

		CASE $$SL_CIRCLE:
			OldROP = SetROP2 (hDC, $$R2_NOTXORPEN)
			Ellipse (hDC, selectRect.left, selectRect.top, selectRect.right, selectRect.bottom)
			SetROP2 (hDC, OldROP)

	END SELECT
	ReleaseDC (hWnd, hDC)
	RETURN 1


END FUNCTION
END PROGRAM
