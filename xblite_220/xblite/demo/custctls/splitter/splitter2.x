'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This custom splitter control is a container
' control. It is used to contain two controls.
' The user can use the mouse to move a splitter
' panel dividing the two controls to change
' their relative sizes.
' ---
' Also note that two cursors are loaded from
' resources in the dll and are used by the
' splitter control.
' ---
' To use this control, just IMPORT "splitter"
' in your PROLOG. The splitter control class is
' registered automatically in the dll's Entry ()
' function. The programmer can then create
' multiple instances of this control just like
' any other Win32 common control.
' ---
' The splitter class name is:
' $$SPLITTERCLASSNAME = "splitterctrl".
' ---
' See splittest.x, tsplit.x
' ---
' (c) 2000 GPL David SZAFRANSKI
' dszafranski@wanadoo.fr
'
PROGRAM	"splitter"
VERSION	"0.0005"
'
	IMPORT	"xst"
	IMPORT  "gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"
	IMPORT  "comctl32"
'
' *****************************
' ***** Type Declarations *****
' *****************************

TYPE SPLITTERDATA
	XLONG	.hWndParent			' handle of parent window
	XLONG	.hWnd1					' handle to contained window 1 (left or top)
	XLONG	.hWnd2					' handle to contained window 2 (right or bottom)
	XLONG	.wnd1MinSize		' window 1 minimum size allowed
	XLONG	.wnd2MinSize		' window 2 minimum size allowed
	XLONG	.style					' splitter style ($$SS_HORZ or $$SS_VERT)
	XLONG	.splitterSize		' size of the splitter bar in pixels
	XLONG	.hStatic				' handle of static control used as splitter panel
	XLONG	.id							' static control id
	XLONG .lastX					' last x position of static control
	XLONG .lastY					' last y position of static control
END TYPE

EXPORT
DECLARE FUNCTION  Splitter ()
END EXPORT

INTERNAL FUNCTION  SplitterProc (hWnd, msg, wParam, lParam)
INTERNAL FUNCTION  StaticProc (hWnd, msg, wParam, lParam)
INTERNAL FUNCTION  PaintSplitter (hWnd, style)
INTERNAL FUNCTION  DottedRectangle (hDC, x1, y1, x2, y2)

EXPORT
' splitter class name
$$SPLITTERCLASSNAME = "splitterctrl"

' define splitter styles
$$SS_HORZ = 0
$$SS_VERT = 1

' define custom window messages
$$WM_SET_SPLITTER_PANEL_HWND     = 1025		' this msg MUST be called, wParam = left/top panel hWnd, lParam = right/bottom panel hWnd
$$WM_SET_SPLITTER_MIN_PANEL_SIZE = 1026		' wParam = left/top panel minimum size, lParam = right/bottom panel minimum size
$$WM_SET_SPLITTER_SIZE           = 1027		' size of splitter panel, wParam = 0, lParam = width/height of splitter panel in pixels
$$WM_SET_SPLITTER_STYLE          = 1028		' splitter control style, wParam = 0, lParam = style flag (default = $$SS_HORZ)
$$WM_SET_SPLITTER_POSITION       = 1029		' splitter position, wParam = x position (for $$SS_HORZ style), lParam = y position (for $$SS_VERT style), only one arg is necessary
$$WM_GET_SPLITTER_POSITION       = 1030		' return is current splitter panel position
$$WM_GET_SPLITTER_MIN_SIZE       = 1031		' return is minimum splitter control size (splitterSize + minPanel1Size + minPanel2Size)
$$WM_SPITTER_BAR_MOVED           = 1032		' this message is sent to splitter parent after splitter bar has been moved
END EXPORT
'
'
' #########################
' #####  Splitter ()  #####
' #########################
'
'
FUNCTION  Splitter ()

	WNDCLASS wc
	STATIC init
	SHARED hInst

' do this once
	IF init THEN RETURN
	init = $$TRUE

' get Instance handle
	hInst = GetModuleHandleA (0)

' fill in WNDCLASS struct
	wc.style           = $$CS_GLOBALCLASS | $$CS_HREDRAW | $$CS_VREDRAW | $$CS_PARENTDC
	wc.lpfnWndProc     = &SplitterProc()										' splitter control callback function
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 4																	' space for a pointer to a SPLITTERDATA struct
	wc.hInstance       = hInst
	wc.hIcon           = 0
	wc.hCursor         = 0
	wc.hbrBackground   = $$COLOR_BTNFACE + 1
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &"splitterctrl"

' register window class
	RETURN RegisterClassA (&wc)

END FUNCTION
'
'
' #############################
' #####  SplitterProc ()  #####
' #############################
'
FUNCTION  SplitterProc (hWnd, msg, wParam, lParam)

	CREATESTRUCT cs
	RECT splitterRect
	RECT wnd1Rect
	RECT wnd2Rect
	RECT rect
	SPLITTERDATA spdata
	POINT ptClient
	POINT pt
	SHARED moveX, moveY
	STATIC idCount				' id of static control
	SHARED hInst
	SHARED hCursorH, hCursorV
	STATIC hNewBrush

	SELECT CASE msg

		CASE $$WM_CREATE:
' create the heap for this instance of the class and
' allocate heap for the SPLITTERDATA struct
			hHeap = GetProcessHeap ()
			pData = HeapAlloc (hHeap, $$HEAP_ZERO_MEMORY, SIZE(SPLITTERDATA))

' store this data pointer in class data area
			SetLastError (0)
			ret = SetWindowLongA (hWnd, $$GWL_USERDATA, pData)

' get data in createstruct from pointer lParam
			RtlMoveMemory (&cs, lParam, SIZE(CREATESTRUCT))

' create the splitter panel using a static control, set initial size and position in middle
			text$        	= ""
			splitterSize 	= 6								' default splitter panel size
			style        	= $$SS_LEFT | $$SS_NOTIFY | $$WS_CHILD | $$WS_VISIBLE
			w 						= cs.cx
			IF w < splitterSize THEN w = splitterSize
			x 						= w/2 - splitterSize/2
			h 						= cs.cy

			hStatic = CreateWindowExA (0, &"static", &text$, style, x, 0, splitterSize, h, hWnd, idCount, hInst, 0)
			INC idCount

' assign static control callbacks StaticProc ()
			#old_proc = SetWindowLongA (hStatic, $$GWL_WNDPROC, &StaticProc())

' initialize default SPLITTERDATA into data buffer
			IF pData THEN
				XLONGAT(pData)   	= cs.hWndParent	' hWndParent
				XLONGAT(pData+4) 	= 0							' hWnd1
				XLONGAT(pData+8) 	= 0							' hWnd2
				XLONGAT(pData+12) = 20						' wnd1 min size
				XLONGAT(pData+16) = 20						' wnd2 min size
				XLONGAT(pData+20) = 0							' splitter style = default = 0 = horizontal
				XLONGAT(pData+24) = splitterSize	' splitter size
				XLONGAT(pData+28) = hStatic				' handle static control
				XLONGAT(pData+32) = idCount				' static control id
			END IF

' get dll instance handle
			hDllInst = GetModuleHandleA (&"splitter.dll")

' load resource cursors in splitter.dll
			hCursorH = LoadCursorA (hDllInst, &"hsplit")
			hCursorV = LoadCursorA (hDllInst, &"vsplit")

		CASE $$WM_DESTROY:
			hHeap = GetProcessHeap ()
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			IF pData THEN
				HeapFree (hHeap, 0, pData)					' free the heap created in WM_CREATE
			END IF
			DeleteObject (hNewBrush)

  	CASE $$WM_SIZE:
			width  = LOWORD(lParam)
			height = HIWORD(lParam)

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)				' get splitter data
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			hWndParent 		= spdata.hWndParent
			hWnd1 				= spdata.hWnd1
			hWnd2 				= spdata.hWnd2
			minSize1 			= spdata.wnd1MinSize
			minSize2 			= spdata.wnd2MinSize
			splitterSize 	= spdata.splitterSize
			hStatic       = spdata.hStatic
			style         = spdata.style

' don't resize below minimum total splitter size
			minSize = splitterSize + minSize1 + minSize2
			IF style = $$SS_HORZ THEN
				width = MAX(minSize, width)
			ELSE
				height = MAX(minSize, height)
			END IF

			GOSUB CalcSizes										' compute the sizes of all the panels
			IF style = $$SS_HORZ THEN					' resize windows
				MoveWindow (hStatic, splitterRect.left, splitterRect.top, splitterSize, height, 0)
 				MoveWindow (hWnd1, wnd1Rect.left, wnd1Rect.top, wnd1Rect.right, height, 0)
 				MoveWindow (hWnd2, wnd2Rect.left, wnd2Rect.top, wnd2Rect.right - wnd2Rect.left, height, 0)
			ELSE
				MoveWindow (hStatic, 0, splitterRect.top, width, splitterSize, 0)
 				MoveWindow (hWnd1, 0, wnd1Rect.top, width, wnd1Rect.bottom, 0)
 				MoveWindow (hWnd2, 0, wnd2Rect.top, width, wnd2Rect.bottom - wnd2Rect.top, 0)
			END IF
			InvalidateRgn (hWnd, 0, 0)

		CASE $$WM_SET_SPLITTER_PANEL_HWND:
' client calls SendMessageA() just after the control is created
' to set the two side panel window handles
' store this data in object area
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+4) 	= wParam									' hWnd1
			XLONGAT(pData+8) 	= lParam									' hWnd2
			GOSUB Resize																' resize all panels

		CASE $$WM_SET_SPLITTER_MIN_PANEL_SIZE:
' client calls SendMessageA() just after the control is created
' to set the border width for the splitter control
' store data in object area
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+12) = wParam									' wnd1 min size
			XLONGAT(pData+16) = lParam									' wnd2 min size
			GOSUB Resize																' resize all panels

		CASE $$WM_SET_SPLITTER_SIZE:
' client calls SendMessageA() just after the control is created
' to set the splitter size
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+24) = lParam									' splitter size
			GOSUB Resize																' resize all panels

		CASE $$WM_SET_SPLITTER_STYLE:
' client calls SendMessageA() just after the control is created
' to set the splitter style
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+20) = lParam									' set splitter style
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			hStatic      = spdata.hStatic
			style        = lParam
			splitterSize = spdata.splitterSize

			GetWindowRect (hWnd, &rect)
			IF style = $$SS_HORZ THEN
				x = (rect.right - rect.left)/2 - splitterSize/2
				MoveWindow (hStatic, x, 0, splitterSize, rect.bottom-rect.top, 0)
			ELSE
				y = (rect.bottom - rect.top)/2 - splitterSize/2
				MoveWindow (hStatic, 0, y, rect.right-rect.left, splitterSize,  0)
			END IF
			GOSUB Resize																' resize all panels


		CASE $$WM_SET_SPLITTER_POSITION:
' client calls SendMessageA() just after the control is created
' to set the splitter panel horizontal (x) or vertical (y) position
' wParam - x, lParam - y ... only one value is needed

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			hStatic      = spdata.hStatic
			style        = spdata.style
			splitterSize = spdata.splitterSize
			hWndParent   = spdata.hWndParent

			GetWindowRect (hWndParent, &rect)
			IF style = $$SS_HORZ THEN
				MoveWindow (hStatic, wParam, 0, splitterSize, rect.bottom-rect.top, 0)
			ELSE
				MoveWindow (hStatic, 0, lParam, rect.right-rect.left, splitterSize,  0)
			END IF
			GOSUB Resize																' resize all panels


		CASE $$WM_GET_SPLITTER_POSITION:
' client calls SendMessageA() just after the control is created
' to get the splitter panel horizontal (x) or vertical (y) position
' return value is current splitter (x or y) depending on style.

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			hStatic      = spdata.hStatic
			style        = spdata.style

' get bounding rectangle for splitter panel (hStatic)
			GetWindowRect (hStatic, &splitterRect)

' convert splitter panel coords to client coords
			pt.x = splitterRect.left
			pt.y = splitterRect.top
			ScreenToClient (hWnd, &pt)
			splitterRect.left = pt.x
			splitterRect.top = pt.y

			IF style = $$SS_HORZ THEN
				RETURN splitterRect.left
			ELSE
				RETURN splitterRect.top
			END IF

		CASE $$WM_GET_SPLITTER_MIN_SIZE:
' the minimum splitter size is the smallest size the control
' should be resized in width or height based on style
' minSize = splitterWidth + minSizePanel1 + minSizePanel2
' applications should call this function before resizing the control
' default minSize = 6 + 20 + 20 = 46

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			RETURN spdata.splitterSize + spdata.wnd1MinSize + spdata.wnd2MinSize

		CASE $$WM_CTLCOLORSTATIC :										' set static control background color
			bkColor = GetSysColor ($$COLOR_BTNFACE)			' match color of main window background
			hNewBrush = CreateSolidBrush (bkColor)
			SetBkColor (wParam, bkColor)
			RETURN hNewBrush

		CASE $$WM_NOTIFY :
			hParent = GetParent (hWnd)
			IF hParent THEN SendMessageA (hParent, $$WM_NOTIFY, wParam, lParam)

		CASE $$WM_COMMAND :
			hParent = GetParent (hWnd)
			IF hParent THEN SendMessageA (hParent, $$WM_COMMAND, wParam, lParam)

		CASE $$WM_CONTEXTMENU :			' right button click inside window
			hParent = GetParent (hWnd)
			IF hParent THEN SendMessageA (hParent, $$WM_CONTEXTMENU, wParam, lParam)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** Resize *****
SUB Resize
' resize all splitter panels
	GetClientRect (hWnd, &rect)
	SendMessageA (hWnd, $$WM_SIZE, 0, MAKELONG(rect.right, rect.bottom))
END SUB


' ***** CalcSizes *****
SUB CalcSizes

' calculate the sizes for all the panels

' get bounding rectangle for splitter panel (hStatic)
	GetWindowRect (hStatic, &splitterRect)

' convert splitter panel coords to client coords
	pt.x = splitterRect.left
	pt.y = splitterRect.top
	ScreenToClient (hWnd, &pt)
	splitterRect.left = pt.x
	splitterRect.top = pt.y

	pt.x = splitterRect.right
	pt.y = splitterRect.bottom
	ScreenToClient (hWnd, &pt)
	splitterRect.right = pt.x
	splitterRect.bottom = pt.y

	IF style = $$SS_HORZ THEN
' set new splitter panel position
		splitterRect.left   = splitterRect.left + moveX
		splitterRect.right  = splitterRect.left + splitterSize
		splitterRect.top    = 0
		splitterRect.bottom = height

' resize panel 1 (left)
		wnd1Rect.left   = 0
		wnd1Rect.right  = splitterRect.left
		wnd1Rect.top    = 0
		wnd1Rect.bottom = height

' resize panel 2 (right)
		wnd2Rect.left   = splitterRect.right
		wnd2Rect.right  = width
		wnd2Rect.top    = 0
		wnd2Rect.bottom = height

' check if panel 1 (left) width is too small
		IF wnd1Rect.right < minSize1 THEN
			wnd1Rect.right     = minSize1
			splitterRect.left  = wnd1Rect.right
			splitterRect.right = wnd1Rect.right + splitterSize
			wnd2Rect.left      = splitterRect.right
		ELSE
' check if panel2 (right) width is too small
			width2 = wnd2Rect.right - wnd2Rect.left
			IF width2 < minSize2 THEN
				wnd2Rect.left      = width - minSize2
				splitterRect.right = wnd2Rect.left
				splitterRect.left  = splitterRect.right - splitterSize
				wnd1Rect.right     = splitterRect.left
			END IF
		END IF

	ELSE
' vertical splitter
' set new splitter panel position
		splitterRect.left   = 0
		splitterRect.right  = width
		splitterRect.top    = splitterRect.top + moveY
		splitterRect.bottom = splitterRect.top + splitterSize

' resize panel 1 (top)
		wnd1Rect.left   = 0
		wnd1Rect.right  = width
		wnd1Rect.top    = 0
		wnd1Rect.bottom = splitterRect.top

' resize panel 2 (bottom)
		wnd2Rect.left   = 0
		wnd2Rect.right  = width
		wnd2Rect.top    = splitterRect.bottom
		wnd2Rect.bottom = height
	END IF

' check if panel 1 (top) height is too small
		IF wnd1Rect.bottom < minSize1 THEN
			wnd1Rect.bottom     = minSize1
			splitterRect.top    = wnd1Rect.bottom
			splitterRect.bottom = wnd1Rect.bottom + splitterSize
			wnd2Rect.top        = splitterRect.bottom
		ELSE
' check if panel2 (bottom) height is too small
			height2 = wnd2Rect.bottom - wnd2Rect.top
			IF height2 < minSize2 THEN
				wnd2Rect.top        = height - minSize2
				splitterRect.bottom = wnd2Rect.top
				splitterRect.top    = splitterRect.bottom - splitterSize
				wnd1Rect.bottom     = splitterRect.top
			END IF
		END IF

END SUB

END FUNCTION
'
'
' ###########################
' #####  StaticProc ()  #####
' ###########################
'
' subclass static control callback function
' this allows mouse messages to be tracked/captured
' and for setting the splitter cursor

FUNCTION  StaticProc (hWnd, msg, wParam, lParam)

	SPLITTERDATA spdata
	STATIC splitterX0, splitterY0
	SHARED hCursorH, hCursorV
	SHARED moveX, moveY
	RECT rect
	STATIC fTrackMouse
	TRACKMOUSEEVENT tme

	hWndParent = GetParent (hWnd)
	pData = GetWindowLongA (hWndParent, $$GWL_USERDATA)								' get splitter data
	IF pData THEN RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))	' copy data into local struct spdata

	SELECT CASE msg

		CASE $$WM_LBUTTONDOWN:
			style = spdata.style						' get horz or vert splitter style
			IF style = $$SS_HORZ THEN
				SetCursor (hCursorH)					' set cursor
			ELSE
				SetCursor (hCursorV)
			END IF

			SetCapture (hWnd)								' capture the mouse to static control
			splitterX0 = LOWORD (lParam)		' get initial x mouse position
			splitterY0 = HIWORD (lParam)
			

		CASE $$WM_LBUTTONUP:
			ReleaseCapture ()								' release the mouse
			
			GetClientRect (hWndParent, &rect)		' get parent size and send WM_SIZE message to splitter control
			SendMessageA (hWndParent, $$WM_SIZE, 0, MAKELONG(rect.right, rect.bottom))
			
			spdata.lastX = 0
			spdata.lastY = 0
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))	' copy data into local struct spdata
			
'			hSplitter = GetParent (hWnd)
			SendMessageA (GetParent (hWndParent), $$WM_SPITTER_BAR_MOVED, 0, 0)
			

		CASE $$WM_MOUSELEAVE:
			fTrackMouse = 0
			SetCursor (LoadCursorA (0, $$IDC_ARROW))	' change cursor back to standard arrow
			
		CASE $$WM_MOUSEMOVE:
			style = spdata.style

			IF style = $$SS_HORZ THEN
				last = SetCursor (hCursorH)										' change cursor
			ELSE
				last = SetCursor (hCursorV)
			END IF

			IFZ fTrackMouse THEN
				tme.cbSize = SIZE(tme)
				tme.dwFlags = $$TME_LEAVE
				tme.hwndTrack = hWnd
				ret = TrackMouseEvent (&tme)
				fTrackMouse = $$TRUE
			END IF

			IF (wParam & $$MK_LBUTTON) THEN						' left button down (drag)

				IF style = $$SS_HORZ THEN
					moveX = LOWORD (lParam) - splitterX0	' get delta x mouse position
					IFZ moveX THEN RETURN
				ELSE
					moveY = HIWORD (lParam) - splitterY0
					IFZ moveY THEN RETURN
				END IF
				
				' draw new splitter position
				PaintSplitter (hWnd, style)

'				GetClientRect (hWndParent, &rect)		' get parent size and send WM_SIZE message to splitter control
'				SendMessageA (hWndParent, $$WM_SIZE, 0, MAKELONG(rect.right, rect.bottom))
			END IF

		CASE ELSE :
			RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
'
' ###########################
' #####  PaintSplitter  #####
' ###########################
'
'
'
FUNCTION PaintSplitter (hWnd, style)

	SPLITTERDATA spdata
	SHARED moveX, moveY
	RECT re, rc, rect
	POINT pt, spt
	
	hWndParent = GetParent (hWnd)
	pData = GetWindowLongA (hWndParent, $$GWL_USERDATA)								' get splitter data
	IF pData THEN RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))	' copy data into local struct spdata
	
	' get position of static splitter control
	GetClientRect (hWnd, &rc)
	
	' convert coords to window coords
	spt.x = rc.left
	spt.y = rc.top
	ClientToScreen (hWnd, &spt)
	
	' convert back to screen coords for parent
	ScreenToClient (GetParent(hWnd), &spt)
	spTop = spt.y
	spLeft = spt.x
	
  GetWindowRect (GetParent(hWnd), &re)
  yTop = re.top + 1
  yBottom = re.bottom - 2
	xRight = re.right - 2
	xLeft = re.left + 1
  
  hDC = GetDC (0)
	size = spdata.splitterSize
	
	SELECT CASE style
		CASE $$SS_HORZ :

			IF spdata.lastX THEN
				pt.x = spdata.lastX + spLeft
				pt.y = spdata.lastY + spTop
				ClientToScreen (GetParent(hWnd), &pt)
				rect.left 	= pt.x
				rect.right 	= pt.x+size
				rect.top 		= yTop
				rect.bottom = yBottom
				DrawFocusRect (hDC, &rect)
			END IF

			pt.x = moveX + spLeft
			pt.y = moveY + spTop
			ClientToScreen (GetParent(hWnd), &pt)
	
			rect.left 	= pt.x
			rect.right 	= pt.x+size
			rect.top 		= yTop
			rect.bottom = yBottom
			DrawFocusRect (hDC, &rect)
	
		CASE ELSE :
			
			IF spdata.lastY THEN
				pt.x = spdata.lastX + spLeft
				pt.y = spdata.lastY + spTop
				ClientToScreen (GetParent(hWnd), &pt)
				rect.left		= xLeft
				rect.right	= xRight
				rect.top		= pt.y
				rect.bottom	= pt.y+size
				DrawFocusRect (hDC, &rect)
			END IF

			pt.x = moveX + spLeft
			pt.y = moveY + spTop
			ClientToScreen (GetParent(hWnd), &pt)
	
			rect.left		= xLeft
			rect.right	= xRight
			rect.top		= pt.y
			rect.bottom	= pt.y+size
			DrawFocusRect (hDC, &rect)
			
	END SELECT
  
  ReleaseDC (0, hDC)
	
  spdata.lastX = moveX
	spdata.lastY = moveY
	
	IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))	' copy data into local struct spdata
	
END FUNCTION
'
' #############################
' #####  DottedRectangle  #####
' #############################
'
'
'
FUNCTION DottedRectangle (hDC, x1, y1, x2, y2)

	USHORT pattern[]

	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	IF x2 < x1 THEN SWAP x1, x2
	IF y2 < y1 THEN SWAP y1, y2

	DIM pattern[7]
	pattern[0] = 0xAA
	pattern[1] = 0x55
	pattern[2] = 0xAA
	pattern[3] = 0x55
	pattern[4] = 0xAA
	pattern[5] = 0x55
	pattern[6] = 0xAA
	pattern[7] = 0x55

	hBitmap = CreateBitmap (8, 8, 1, 1, &pattern[0])
	hBrush = CreatePatternBrush (hBitmap)
	DeleteObject (hBitmap)
	hOld = SelectObject (hDC, hBrush)

	PatBlt (hDC, x1, y1, x2-x1, 1, $$PATINVERT)
	PatBlt (hDC, x1, y2, x2-x1, 1, $$PATINVERT)
	PatBlt (hDC, x1, y1, 1, y2-y1, $$PATINVERT)
	PatBlt (hDC, x2, y1, 1, y2-y1, $$PATINVERT)

	SelectObject (hDC, hOld)
	DeleteObject (hBrush)
	RETURN ($$TRUE)

END FUNCTION
END PROGRAM
