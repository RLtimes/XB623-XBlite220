'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This custom docking splitter control is a container
' control. It is used to contain two controls.
' The user can use the mouse to move a splitter
' panel dividing the two controls to change
' their relative sizes.
' The splitter bar can be docked to one side
' of the splitter so only one panel is displayed.
' ---
' Also note that three cursors are loaded from
' resources in the dll and are used by the
' splitter control.
' ---
' To use this control, just IMPORT "docksplitter"
' in your PROLOG. The splitter control class is
' registered automatically in the dll's Entry ()
' function. The programmer can then create
' multiple instances of this control just like
' any other Win32 common control.
' ---
' The splitter class name is:
' $$DOCKSPLITTERCLASSNAME = "docksplitterctrl".
' ---
' See docksplittertest.x
' ---
' (c) 2005 GPL David SZAFRANSKI
' david.szafranski@wanadoo.fr
'
' v0.0003 11 Jan 2006
' - splitter child controls now assign parent to same parent as splitter control
' - child controls should now send messages to their parent control correctly
' - splitter now draws borders correctly
'
PROGRAM	"docksplitter"
VERSION	"0.0003"
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
	XLONG .xpos						' x position of split bar
	XLONG .ypos						' y position of split bar
	XLONG .xlower					' x lower drag margin
	XLONG .ylower					' y lower drag margin
	XLONG .xupper					' x uppper drag margin
	XLONG .yupper         ' y upper drag margin
	XLONG .xdrag					' x position during drag (-1 = no drag)
	XLONG .ydrag					' y position during drag (-1 = no drag)
	XLONG .dragDone				' drag operation completed flag
	XLONG .dockStyle      ' docking style ($$DS_LEFT, $$DS_RIGHT, $$DS_TOP, $$DS_BOTTOM)
	XLONG .hot						' button hotspot 
	XLONG .state					' 0 = displayed, -1 = collapsed
	XLONG .lastPos				' last position before collapsing
	XLONG .buttonStyle    ' style of splitter gripper button
	XLONG .hCursorH       ' handle to horz cursor
	XLONG .hCursorV       ' handle to vert cursor
	XLONG .hCursorHand    ' handle to hand cursor
	XLONG .hbrDotty       ' handle to dot brush
END TYPE

EXPORT
TYPE NMSPLITTER
    NMHDR  .hdr		      ' WM_NOTIFY message header
    XLONG	 .x				    ' X-parameter of notification
    XLONG	 .y				    ' Y-parameter of notification
END TYPE

DECLARE FUNCTION  DockSplitter ()
DECLARE FUNCTION GetRed (color)
DECLARE FUNCTION GetGreen (color)
DECLARE FUNCTION GetBlue (color)
DECLARE FUNCTION DrawLine (hdc, x1, y1, x2, y2, penStyle, width, color)
DECLARE FUNCTION DrawArrow (hdc, x, y, color, direction)
DECLARE FUNCTION DrawRectangle (hdc, x, y, w, h, color)

END EXPORT

INTERNAL FUNCTION  SplitterProc (hWnd, msg, wParam, lParam)
INTERNAL FUNCTION  StaticProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION SPLT (pos, w)
DECLARE FUNCTION SPRB (pos, w)
DECLARE FUNCTION CURSORPOS_OK (cur, spl, w)
DECLARE FUNCTION SplitterNotifyParent (hSplitter, code, xParam, yParam)
DECLARE FUNCTION CalculateColor (front, back, alpha)


EXPORT
' splitter class name
$$DOCKSPLITTERCLASSNAME = "docksplitterctrl"

' define gripper button styles
$$BS_MOZILLA    = 0
$$BS_DOUBLEDOTS = 1
$$BS_WIN9X      = 2
$$BS_WINXP      = 3
$$BS_LINES      = 4

' define splitter styles
$$SS_HORZ = 0
$$SS_VERT = 1

' define docking styles
$$DS_LEFT   = 0
$$DS_RIGHT  = 1
$$DS_TOP    = 2
$$DS_BOTTOM = 3

' define custom window messages
$$WM_SET_SPLITTER_PANEL_HWND     = 1025		' this msg MUST be called, wParam = left/top panel hWnd, lParam = right/bottom panel hWnd
$$WM_SET_SPLITTER_MIN_PANEL_SIZE = 1026		' wParam = left/top panel minimum size, lParam = right/bottom panel minimum size
$$WM_SET_SPLITTER_SIZE           = 1027		' size of splitter panel, wParam = 0, lParam = width/height of splitter panel in pixels
$$WM_SET_SPLITTER_STYLE          = 1028		' splitter control style, wParam = 0, lParam = style flag (default = $$SS_HORZ)
$$WM_SET_SPLITTER_POSITION       = 1029		' splitter position, wParam = x position (for $$SS_HORZ style), lParam = y position (for $$SS_VERT style), only one arg is necessary
$$WM_GET_SPLITTER_POSITION       = 1030		' return is current splitter panel position
$$WM_GET_SPLITTER_MIN_SIZE       = 1031		' return is minimum splitter control size (splitterSize + minPanel1Size + minPanel2Size)
$$WM_SET_SPLITTER_DOCKING_STYLE  = 1033   ' set the docking style, wParam = 0, lParam = style ($$DS_RIGHT, $$DS_LEFT, $$DS_TOP, $$DS_BOTTOM)
$$WM_SET_SPLITTER_BUTTON_STYLE   = 1034   ' set the button style, wParam = 0, lParam = style ($$BS_MOZILLA, $$BS_DOUBLEDOTS, $$BS_WIN9X...see above)
$$WM_DOCK_SPLITTER               = 1035   ' dock splitter
$$WM_UNDOCK_SPLITTER             = 1036   ' restore splitter to last position

' Splitter notifications
$$NM_SPLITTER_BAR_MOVED = -2000		' this notification message is sent to splitter parent after splitter bar has been moved

' triangle directions
$$TriangleUp     = 0x0010
$$TriangleRight  = 0x0014
$$TriangleDown   = 0x0018
$$TriangleLeft   = 0x001C

END EXPORT
'
'
' #########################
' #####  Splitter ()  #####
' #########################
'
'
FUNCTION  DockSplitter ()

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
	wc.lpszClassName   = &"docksplitterctrl"

' register window class
	RegisterClassA (&wc)

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
	RECT rect, rc
	SPLITTERDATA spdata
	POINT ptClient
	POINT pt
	POINT pt1, pt2
	SHARED moveX, moveY
	STATIC idCount				' id of static control
	SHARED hInst
	STATIC hNewBrush
	USHORT dottyData[]
	
	pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
	IF pData THEN RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA)) 

	SELECT CASE msg

		CASE $$WM_CREATE:
' create the heap for this instance of the class and
' allocate heap for the SPLITTERDATA struct
			hHeap = GetProcessHeap ()
			pData = HeapAlloc (hHeap, $$HEAP_ZERO_MEMORY, SIZE(SPLITTERDATA))

' store this data pointer in class data area
			SetLastError (0)
			ret = SetWindowLongA (hWnd, $$GWL_USERDATA, pData)
			
' set window style to WS_CLIPSIBLINGS
			st = GetWindowLongA (hWnd, $$GWL_STYLE) 
			SetWindowLongA (hWnd, $$GWL_STYLE, st | $$WS_CLIPSIBLINGS)

' get data in createstruct from pointer lParam
			RtlMoveMemory (&cs, lParam, SIZE(CREATESTRUCT))

' create the splitter panel using a static control, set initial position in middle
			text$        	= ""
			splitterSize 	= 8								' default splitter panel size
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

			spdata.hWndParent   = cs.hWndParent	' hWndParent
			spdata.wnd1MinSize  = 0							' wnd1 min size
			spdata.wnd2MinSize  = 0							' wnd2 min size
			spdata.style        = $$SS_HORZ			' splitter style = default = horizontal
			spdata.splitterSize = splitterSize	' splitter size
			spdata.hStatic      = hStatic				' handle static control
			spdata.id           = idCount				' static control id
			spdata.xpos         = -1
			spdata.ypos         = -1
			spdata.xdrag        = -1
			spdata.ydrag        = -1
			spdata.dockStyle    = $$DS_LEFT			' default dock style
			spdata.state        = -1

' get dll instance handle
			hDllInst = GetModuleHandleA (&"docksplitter.dll")
			IFZ hDllInst THEN hDllInst = hInst

' load resource cursors in splitter.dll
			hCursorH = LoadCursorA (hDllInst, &"hsplit")
			hCursorV = LoadCursorA (hDllInst, &"vsplit")
			hCursorHand = LoadCursorA (hDllInst, &"hand1")
			
			spdata.hCursorH = hCursorH
			spdata.hCursorV = hCursorV
			spdata.hCursorHand = hCursorHand
			
			DIM dottyData[7]
			dottyData[0] = 0x55
			dottyData[1] = 0xAA
			dottyData[2] = 0x55
			dottyData[3] = 0xAA
			dottyData[4] = 0x55
			dottyData[5] = 0xAA
			dottyData[6] = 0x55
			dottyData[7] = 0xAA
			
			hbm      = CreateBitmap (8, 8, 1, 1, &dottyData[])
			hbrDotty = CreatePatternBrush (hbm)
			DeleteObject (hbm)
			
			spdata.hbrDotty = hbrDotty
			
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))
			
		CASE $$WM_DESTROY:
			DeleteObject (spdata.hCursorH)
			DeleteObject (spdata.hCursorV)
			DeleteObject (spdata.hCursorHand)
			DeleteObject (spdata.hbrDotty)
			hHeap = GetProcessHeap ()
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			IF pData THEN
				HeapFree (hHeap, 0, pData)					' free the heap created in WM_CREATE
			END IF
			DeleteObject (hNewBrush)

  	CASE $$WM_SIZE:
			width  = LOWORD(lParam)
			height = HIWORD(lParam)

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
			spdata.xpos = splitterRect.left
			spdata.ypos = splitterRect.top
			
			MapWindowPoints (hWnd, GetParent(hWnd1), &wnd1Rect, 2)
			MapWindowPoints (hWnd, GetParent(hWnd2), &wnd2Rect, 2)
			 
			IF style = $$SS_HORZ THEN					' resize windows
				MoveWindow (hStatic, splitterRect.left, splitterRect.top, splitterSize, height, 1)
 				MoveWindow (hWnd1, wnd1Rect.left, wnd1Rect.top, wnd1Rect.right - wnd1Rect.left, height, 1)
 				MoveWindow (hWnd2, wnd2Rect.left, wnd2Rect.top, wnd2Rect.right - wnd2Rect.left, height, 1)
			ELSE
				MoveWindow (hStatic, 0, splitterRect.top, width, splitterSize, 1)
 				MoveWindow (hWnd1, wnd1Rect.left, wnd1Rect.top, width, wnd1Rect.bottom - wnd1Rect.top, 1)
 				MoveWindow (hWnd2, wnd2Rect.left, wnd2Rect.top, width, wnd2Rect.bottom - wnd2Rect.top, 1)
			END IF
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

		CASE $$WM_SET_SPLITTER_PANEL_HWND:
			spdata.hWnd1 	= wParam									' hWnd1
			spdata.hWnd2 	= lParam									' hWnd2
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))
			
			' set splitter window to bottom of z-order so all others paint on top
			SetWindowPos (hWnd, $$HWND_BOTTOM, 0, 0, 0, 0, $$SWP_NOACTIVATE | $$SWP_NOMOVE | $$SWP_NOREDRAW | $$SWP_NOSIZE)			
			GOSUB Resize													' resize all panels

		CASE $$WM_SET_SPLITTER_MIN_PANEL_SIZE:
			spdata.wnd1MinSize = 0								' wnd1 min size (cannot alter)
			spdata.wnd2MinSize = 0								' wnd2 min size (cannot alter)
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))

		CASE $$WM_SET_SPLITTER_SIZE:
			spdata.splitterSize = 8								' cannot change splitter width
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))

		CASE $$WM_SET_SPLITTER_DOCKING_STYLE:
			SELECT CASE spdata.style
				CASE $$SS_HORZ:
					SELECT CASE lParam
						CASE $$DS_LEFT, $$DS_RIGHT : 
						CASE ELSE : lParam = $$DS_LEFT
					END SELECT 
					
				CASE $$SS_VERT:
					SELECT CASE lParam
						CASE $$DS_TOP, $$DS_BOTTOM:
						CASE ELSE : lParam = $$DS_BOTTOM
					END SELECT  
			END SELECT
			spdata.dockStyle = lParam
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))
			
		CASE $$WM_SET_SPLITTER_BUTTON_STYLE:
			IF lParam > $$BS_LINES THEN lParam = 0 
			spdata.buttonStyle = lParam
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))

		CASE $$WM_SET_SPLITTER_STYLE:
			
			SELECT CASE lParam
				CASE $$SS_HORZ, $$SS_VERT :
				CASE ELSE : lParam = $$SS_HORZ
			END SELECT 
			
			spdata.style = lParam	
			hStatic      = spdata.hStatic
			style        = lParam
			splitterSize = spdata.splitterSize
			
			IF style = $$SS_HORZ THEN 
				spdata.dockStyle = $$DS_LEFT
			ELSE
				spdata.dockStyle = $$DS_BOTTOM
			END IF

			GetWindowRect (hWnd, &rect)
			IF style = $$SS_HORZ THEN
				x = (rect.right - rect.left)/2 - splitterSize/2
				spdata.xpos = x
				MoveWindow (hStatic, x, 0, splitterSize, rect.bottom-rect.top, 0)
			ELSE
				y = (rect.bottom - rect.top)/2 - splitterSize/2
				spdata.ypos = y
				MoveWindow (hStatic, 0, y, rect.right-rect.left, splitterSize,  0)
			END IF
			GOSUB Resize																' resize all panels
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))

		CASE $$WM_SET_SPLITTER_POSITION:
			' wParam - x, lParam - y ... only one value is needed

			hStatic      = spdata.hStatic
			style        = spdata.style
			splitterSize = spdata.splitterSize
			hWndParent   = spdata.hWndParent
			
			spdata.xpos = wParam
			spdata.ypos = lParam
			IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))
			
			GetWindowRect (hWndParent, &rect)
			IF style = $$SS_HORZ THEN
				MoveWindow (hStatic, wParam, 0, splitterSize, rect.bottom-rect.top, 0)
			ELSE
				MoveWindow (hStatic, 0, lParam, rect.right-rect.left, splitterSize,  0)
			END IF
			
			GOSUB Resize																' resize all panels
			
		CASE $$WM_DOCK_SPLITTER :
			IF spdata.state THEN
				spdata.state = 0
				IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))
				
				spdata.lastPos = SendMessageA (hWnd, $$WM_GET_SPLITTER_POSITION, 0, 0) 
				IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))
					
				GetClientRect (hWnd, &rc)
					
				IF spdata.style = $$SS_HORZ THEN
					IF spdata.dockStyle = $$DS_LEFT THEN
						SendMessageA (hWnd, $$WM_SET_SPLITTER_POSITION, 0, 0) 
						x = 0
						y = 0
					ELSE
						SendMessageA (hWnd, $$WM_SET_SPLITTER_POSITION, rc.right-spdata.splitterSize, 0) 
						x = rc.right-spdata.splitterSize
						y = 0
					END IF 
				ELSE
					IF spdata.dockStyle = $$DS_TOP THEN
						SendMessageA (hWnd, $$WM_SET_SPLITTER_POSITION, 0, 0) 
						x = 0
						y = 0
					ELSE
						SendMessageA (hWnd, $$WM_SET_SPLITTER_POSITION, 0, rc.bottom-spdata.splitterSize) 
						x = 0
						y = rc.bottom-spdata.splitterSize 
					END IF 
				END IF
				SplitterNotifyParent (hWnd, $$NM_SPLITTER_BAR_MOVED, x, y)
			END IF
			
		CASE $$WM_UNDOCK_SPLITTER :
			IFZ spdata.state THEN
				spdata.state = $$TRUE
				IF pData THEN RtlMoveMemory (pData, &spdata, SIZE(SPLITTERDATA))
				IF spdata.style = $$SS_HORZ THEN 
					SendMessageA (hWnd, $$WM_SET_SPLITTER_POSITION, spdata.lastPos, 0)
					x = spdata.lastPos
					y = 0
				ELSE
					SendMessageA (hWnd, $$WM_SET_SPLITTER_POSITION, 0, spdata.lastPos)
					x = 0
					y = spdata.lastPos
				END IF
				SplitterNotifyParent (hWnd, $$NM_SPLITTER_BAR_MOVED, x, y) 
			END IF
			
		CASE $$WM_GET_SPLITTER_POSITION:
			hStatic = spdata.hStatic
			style   = spdata.style

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
' default minSize = 5 + 20 + 20 = 45

			RETURN spdata.splitterSize + spdata.wnd1MinSize + spdata.wnd2MinSize

		CASE $$WM_CTLCOLORSTATIC :										' set static control background color
			bkColor = GetSysColor ($$COLOR_BTNFACE)			' match color of main window background
			hNewBrush = CreateSolidBrush (bkColor)
			SetBkColor (wParam, bkColor)
			RETURN hNewBrush

'		CASE $$WM_NOTIFY :
'			hParent = GetParent (hWnd)
'			IF hParent THEN SendMessageA (hParent, $$WM_NOTIFY, wParam, lParam)

'		CASE $$WM_COMMAND :
'			hParent = GetParent (hWnd)
'			IF hParent THEN SendMessageA (hParent, $$WM_COMMAND, wParam, lParam)

'		CASE $$WM_CONTEXTMENU :			' right button click inside window
'			hParent = GetParent (hWnd)
'			IF hParent THEN SendMessageA (hParent, $$WM_CONTEXTMENU, wParam, lParam)

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

	SPLITTERDATA sp
	RECT rect, rc, r, rr
	STATIC fTrackMouse
	TRACKMOUSEEVENT tme
	POINT pt, pt2
	STATIC fHot

	hWndParent = GetParent (hWnd)
	pData = GetWindowLongA (hWndParent, $$GWL_USERDATA)						' get splitter data
	IF pData THEN RtlMoveMemory (&sp, pData, SIZE(SPLITTERDATA))	' copy data into local struct spdata

	SELECT CASE msg
		
		CASE $$WM_PAINT:
			
			CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)
			
			hdc = GetDC (hWnd)
			GetClientRect (hWnd, &r)
			
			' paint background
			bkColor = GetSysColor ($$COLOR_BTNFACE)
			hbr = CreateSolidBrush (bkColor)
			last = SelectObject (hdc, hbr)
			FillRect (hdc, &r, hbr)
			SelectObject (hdc, last)
			DeleteObject (hbr)
			
			hotColor = CalculateColor (GetSysColor($$COLOR_HIGHLIGHT), bkColor, 70)
			
			SELECT CASE sp.style
				CASE $$SS_HORZ:
					IF sp.dockStyle = $$DS_RIGHT || sp.dockStyle = $$DS_LEFT THEN
						' create a new rectangle in the vertical center of the splitter for our collapse control button
						rr.top = (r.bottom - 115)/2
						rr.bottom = rr.top + 115 
						rr.left = r.left
						rr.right = r.right
						
						' draw the background color for our control image
						IF fHot THEN 
							hbr = CreateSolidBrush (hotColor)
						ELSE
							hbr = CreateSolidBrush (bkColor)
						END IF
						
						last = SelectObject (hdc, hbr)
						InflateRect (&rr, -1, 0) 
						ret = FillRect (hdc, &rr, hbr)
						SelectObject (hdc, last)
						DeleteObject (hbr)

						' draw the top & bottom lines for our control image
						x1 = rr.left
						y1 = rr.top
						x2 = rr.left + (rr.right-rr.left)
						y2 = rr.top
						DrawLine (hdc, x1, y1, x2, y2, $$PS_SOLID, 1, GetSysColor ($$COLOR_3DSHADOW))
						x1 = rr.left
						y1 = rr.top + (rr.bottom-rr.top)
						x2 = rr.left + (rr.right - rr.left)
						y2 = rr.top + (rr.bottom-rr.top)
						DrawLine (hdc, x1, y1, x2, y2, $$PS_SOLID, 1, GetSysColor ($$COLOR_3DSHADOW))
						
						' draw the arrows for our control image
						' the ArrowPointArray is a point array that defines an arrow shaped polygon
						SELECT CASE TRUE
							CASE (sp.dockStyle == $$DS_RIGHT && sp.state) || (sp.dockStyle == $$DS_LEFT && !sp.state): 		' right arrow
								DrawArrow (hdc, rr.left + 1, rr.top + 3, GetSysColor ($$COLOR_3DDKSHADOW), $$TriangleRight)
								DrawArrow (hdc, rr.left + 1, rr.top + (rr.bottom-rr.top) - 9, GetSysColor ($$COLOR_3DDKSHADOW), $$TriangleRight)
							CASE (sp.dockStyle == $$DS_RIGHT && !sp.state) || (sp.dockStyle == $$DS_LEFT && sp.state) : 	' left arrow
								DrawArrow (hdc, rr.left + 1, rr.top + 3, GetSysColor ($$COLOR_3DDKSHADOW), $$TriangleLeft)
								DrawArrow (hdc, rr.left + 1, rr.top + (rr.bottom-rr.top) - 9, GetSysColor ($$COLOR_3DDKSHADOW), $$TriangleLeft)
						END SELECT
						
						' draw the dots for our control image using a loop
						x = rr.left + 2
						y = rr.top + 14

				' draw button by style
						SELECT CASE sp.buttonStyle
							CASE $$BS_MOZILLA :
								FOR i = 0 TO 29 
								' light dot
									DrawLine (hdc, x, y + (i*3), x+1, y + 1 + (i*3), $$PS_SOLID, 1, GetSysColor($$COLOR_3DHILIGHT))
								' dark dot
									DrawLine (hdc, x+1, y + 1 + (i*3), x+2, y + 2 + (i*3), $$PS_SOLID, 1, GetSysColor($$COLOR_3DDKSHADOW))
								' overdraw the background color as we actually drew 2px diagonal lines, not just dots
									IF (fHot) THEN 
										DrawLine (hdc, x+2, y + 1 + (i*3), x+2, y + 2 + (i*3), $$PS_SOLID, 1, hotColor)
									ELSE 
										DrawLine (hdc, x+2, y + 1 + (i*3), x+2, y + 2 + (i*3), $$PS_SOLID, 1, bkColor)
									END IF 
								NEXT i
							CASE $$BS_DOUBLEDOTS :
								FOR i = 0 TO 29
									' light dot
									SetPixelV (hdc, x, y + 1 + (i*3), GetSysColor($$COLOR_3DHILIGHT)) 
									' dark dot
									SetPixelV (hdc, x - 1, y +(i*3), GetSysColor ($$COLOR_3DSHADOW))
									INC i 
									' light dot
									SetPixelV (hdc, x + 2, y + 1 + (i*3), GetSysColor($$COLOR_3DHILIGHT))
									' dark dot
									SetPixelV (hdc, x + 1, y  + (i*3), GetSysColor ($$COLOR_3DSHADOW))
								NEXT i
							CASE $$BS_WIN9X :
								y = y - 1
								DrawLine (hdc, x, y, x + 2, y, $$PS_SOLID, 1, GetSysColor($$COLOR_3DHILIGHT))
								DrawLine (hdc, x, y, x, y + 90, $$PS_SOLID, 1, GetSysColor($$COLOR_3DHILIGHT))
								DrawLine (hdc, x + 2, y, x + 2, y + 90, $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
								DrawLine (hdc, x, y + 90, x + 2, y + 90, $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
							CASE $$BS_WINXP :
								FOR i = 0 TO 17 
									' light dot
									DrawRectangle (hdc, x, y + (i*5), 2, 2, GetSysColor($$COLOR_3DLIGHT))
									' light light dot
									SetPixelV (hdc, x + 1, y + 1 + (i*5), GetSysColor($$COLOR_3DHILIGHT)) 
									' dark dark dot
									SetPixelV (hdc, x, y +(i*5), GetSysColor($$COLOR_3DDKSHADOW))
									' dark fill
									DrawLine (hdc, x, y + (i*5), x, y + (i*5) + 1, $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
									DrawLine (hdc, x, y + (i*5), x + 1, y + (i*5), $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
								NEXT i
							CASE $$BS_LINES :
								FOR i = 0 TO 43 
									DrawLine (hdc, x, y + (i*2), x + 2, y + (i*2), $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
								NEXT i
						END SELECT
					END IF
					
				CASE $$SS_VERT:
					IF sp.dockStyle = $$DS_TOP || sp.dockStyle = $$DS_BOTTOM THEN
						' create a new rectangle in the vertical center of the splitter for our collapse control button
						rr.top = r.top 
						rr.bottom = r.bottom 
						rr.left = (r.right - 115)/2
						rr.right = rr.left + 115
						
						' draw the background color for our control image
						IF fHot THEN 
							hbr = CreateSolidBrush (hotColor)
						ELSE
							hbr = CreateSolidBrush (bkColor)
						END IF
						
						last = SelectObject (hdc, hbr)
						InflateRect (&rr, 0, -1) 
						ret = FillRect (hdc, &rr, hbr)
						SelectObject (hdc, last)
						DeleteObject (hbr)

						' draw the left & right lines for our control image
						x1 = rr.left
						y1 = rr.top 
						x2 = rr.left 
						y2 = rr.top + (rr.bottom - rr.top)
						DrawLine (hdc, x1, y1, x2, y2, $$PS_SOLID, 1, GetSysColor ($$COLOR_3DSHADOW))
						x1 = rr.left + (rr.right - rr.left) 
						y1 = rr.top 
						x2 = rr.left + (rr.right - rr.left)
						y2 = rr.top + (rr.bottom-rr.top)
						DrawLine (hdc, x1, y1, x2, y2, $$PS_SOLID, 1, GetSysColor ($$COLOR_3DSHADOW))
						
						' draw the arrows for our control image
						' the ArrowPointArray is a point array that defines an arrow shaped polygon
						SELECT CASE TRUE
							CASE (sp.dockStyle == $$DS_TOP && sp.state) || (sp.dockStyle == $$DS_BOTTOM && !sp.state): 		' up arrow
								DrawArrow (hdc, rr.left + 3, rr.top + 1, GetSysColor ($$COLOR_3DDKSHADOW), $$TriangleUp)
								DrawArrow (hdc, rr.left + (rr.right - rr.left) - 9, rr.top + 1, GetSysColor ($$COLOR_3DDKSHADOW), $$TriangleUp)
							CASE (sp.dockStyle == $$DS_TOP && !sp.state) || (sp.dockStyle == $$DS_BOTTOM && sp.state) : 	' down arrow
								DrawArrow (hdc, rr.left + 3, rr.top + 1, GetSysColor ($$COLOR_3DDKSHADOW), $$TriangleDown)
								DrawArrow (hdc, rr.left + (rr.right - rr.left) - 9, rr.top + 1, GetSysColor ($$COLOR_3DDKSHADOW), $$TriangleDown)
						END SELECT
						
						' draw the dots for our control image using a loop
						x = rr.left + 14
						y = rr.top + 2

				' draw gripper button by style
						SELECT CASE sp.buttonStyle
							CASE $$BS_MOZILLA :
								FOR i = 0 TO 29 
								' light dot
									DrawLine (hdc, x + (i*3), y, x + 1 + (i*3), y + 1, $$PS_SOLID, 1, GetSysColor($$COLOR_3DHILIGHT))
								' dark dot
									DrawLine (hdc, x + 1 + (i*3), y + 1, x + 2 + (i*3), y + 2, $$PS_SOLID, 1, GetSysColor($$COLOR_3DDKSHADOW))
								' overdraw the background color as we actually drew 2px diagonal lines, not just dots
									IF (fHot) THEN 
										DrawLine (hdc, x + 1 + (i*3), y + 2, x + 2 + (i*3), y + 2, $$PS_SOLID, 1, hotColor)
									ELSE 
										DrawLine (hdc, x + 1 + (i*3), y + 2, x + 2 + (i*3), y + 2, $$PS_SOLID, 1, bkColor)
									END IF 
								NEXT i
							CASE $$BS_DOUBLEDOTS :
								FOR i = 0 TO 29
									' light dot
									SetPixelV (hdc, x + 1 + (i*3), y, GetSysColor($$COLOR_3DHILIGHT)) 
									' dark dot
									SetPixelV (hdc, x + (i*3), y - 1, GetSysColor ($$COLOR_3DSHADOW))
									INC i 
									' light dot
									SetPixelV (hdc, x + 1 + (i*3), y + 2, GetSysColor($$COLOR_3DHILIGHT))
									' dark dot
									SetPixelV (hdc, x + (i*3), y + 1, GetSysColor ($$COLOR_3DSHADOW))
								NEXT i
							CASE $$BS_WIN9X :
								x = x - 1
								DrawLine (hdc, x, y, x, y + 2, $$PS_SOLID, 1, GetSysColor($$COLOR_3DHILIGHT))
								DrawLine (hdc, x, y, x + 90, y, $$PS_SOLID, 1, GetSysColor($$COLOR_3DHILIGHT))
								DrawLine (hdc, x, y + 2, x + 90, y + 2, $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
								DrawLine (hdc, x + 90, y, x + 90, y + 2, $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
							CASE $$BS_WINXP :
								FOR i = 0 TO 17 
									' light dot
									DrawRectangle (hdc, x + (i*5), y, 2, 2, GetSysColor($$COLOR_3DLIGHT))
									' light light dot
									SetPixelV (hdc, x + 1 + (i*5), y + 1, GetSysColor($$COLOR_3DHILIGHT)) 
									' dark dark dot
									SetPixelV (hdc, x +(i*5), y, GetSysColor($$COLOR_3DDKSHADOW))
									' dark fill
									DrawLine (hdc, x + (i*5), y, x + (i*5) + 1, y, $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
									DrawLine (hdc, x + (i*5), y, x + (i*5), y + 1, $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
								NEXT i
							CASE $$BS_LINES :
								FOR i = 0 TO 43 
									DrawLine (hdc, x + (i*2), y, x + (i*2), y + 2, $$PS_SOLID, 1, GetSysColor($$COLOR_3DSHADOW))
								NEXT i
						END SELECT
					END IF					
			END SELECT

			ReleaseDC (hWnd, hdc)
		
		CASE  $$WM_CAPTURECHANGED:
			IF (sp.xdrag >= 0 || sp.ydrag >= 0) THEN 
		    GetClientRect (hWndParent, &rc)

		    hdc = GetDCEx (hWndParent, NULL, $$DCX_PARENTCLIP)
		    hbr = SelectObject (hdc, sp.hbrDotty)

				IF sp.style = $$SS_HORZ THEN 
					IF (sp.xdrag >= 0) THEN 
						PatBlt (hdc, SPLT (sp.xdrag, sp.splitterSize), 0, sp.splitterSize, rc.bottom, $$PATINVERT)
						IF (sp.dragDone) THEN 
							sp.xpos = sp.xdrag
						END IF 
						sp.xdrag = -1
					END IF 
				ELSE 
					IF (sp.ydrag >= 0) THEN 
						PatBlt (hdc, 0, SPLT (sp.ydrag, sp.splitterSize), rc.right, sp.splitterSize, $$PATINVERT)
						IF (sp.dragDone) THEN 
							sp.ypos = sp.ydrag
						END IF 
						sp.ydrag = -1
					END IF 
				END IF

		    SelectObject (hdc, hbr)
		    ReleaseDC (hWndParent, hdc)
				IF pData THEN RtlMoveMemory (pData, &sp, SIZE(SPLITTERDATA))

		    IF (sp.dragDone) THEN
					
					sp.state = $$TRUE

					SELECT CASE sp.style
						CASE $$SS_HORZ :

							IF (sp.xpos <= 0) THEN 
								sp.xpos = 0	
							ELSE
								IF (sp.xpos >= rc.right-sp.splitterSize) THEN 
									sp.xpos = rc.right-sp.splitterSize
								END IF
							END IF
									
							SELECT CASE sp.dockStyle
								CASE $$DS_LEFT :
									IF sp.xpos = 0 THEN sp.state = $$FALSE
								CASE $$DS_RIGHT :
									IF sp.xpos = rc.right-sp.splitterSize THEN sp.state = $$FALSE
							END SELECT 
							
						CASE $$SS_VERT :
							IF (sp.ypos <= 0) THEN 
								sp.ypos = 0	
							ELSE
								IF (sp.ypos >= rc.bottom-sp.splitterSize) THEN 
									sp.ypos = rc.bottom-sp.splitterSize
								END IF 
							END IF 														
							
							SELECT CASE sp.dockStyle
								CASE $$DS_TOP :
									IF sp.ypos = 0 THEN sp.state = $$FALSE
								CASE $$DS_BOTTOM :
										IF sp.ypos = rc.bottom-sp.splitterSize THEN sp.state = $$FALSE
							END SELECT 

					END SELECT 

					sp.dragDone = $$FALSE
					IF pData THEN RtlMoveMemory (pData, &sp, SIZE(SPLITTERDATA))
					SendMessageA (hWndParent, $$WM_SET_SPLITTER_POSITION, sp.xpos, sp.ypos)
					SplitterNotifyParent (hWndParent, $$NM_SPLITTER_BAR_MOVED, sp.xpos, sp.ypos)
				END IF 
			END IF 
		RETURN 1

		CASE $$WM_LBUTTONDOWN:
			IF (fHot) THEN	
				sp.state = !sp.state
				IF pData THEN RtlMoveMemory (pData, &sp, SIZE(SPLITTERDATA))
				
				IF !sp.state THEN
					' contract
					sp.lastPos = SendMessageA (hWndParent, $$WM_GET_SPLITTER_POSITION, 0, 0) 
					IF pData THEN RtlMoveMemory (pData, &sp, SIZE(SPLITTERDATA))
					
					GetClientRect (hWndParent, &rc)
					
					IF sp.style = $$SS_HORZ THEN
						IF sp.dockStyle = $$DS_LEFT THEN
							SendMessageA (hWndParent, $$WM_SET_SPLITTER_POSITION, 0, 0) 
							x = 0
							y = 0
						ELSE
							SendMessageA (hWndParent, $$WM_SET_SPLITTER_POSITION, rc.right-sp.splitterSize, 0) 
							x = rc.right-sp.splitterSize
							y = 0
						END IF 
					ELSE
						IF sp.dockStyle = $$DS_TOP THEN
							SendMessageA (hWndParent, $$WM_SET_SPLITTER_POSITION, 0, 0) 
							x = 0
							y = 0
						ELSE
							SendMessageA (hWndParent, $$WM_SET_SPLITTER_POSITION, 0, rc.bottom-sp.splitterSize) 
							x = 0
							y = rc.bottom-sp.splitterSize 
						END IF 
					END IF
				ELSE
					' expand
					IF sp.style = $$SS_HORZ THEN 
						SendMessageA (hWndParent, $$WM_SET_SPLITTER_POSITION, sp.lastPos, 0)
						x = sp.lastPos
						y = 0
					ELSE
						SendMessageA (hWndParent, $$WM_SET_SPLITTER_POSITION, 0, sp.lastPos)
						x = 0
						y = sp.lastPos
					END IF 
				END IF
				InvalidateRect (hWnd, NULL, 1)
				SplitterNotifyParent (hWndParent, $$NM_SPLITTER_BAR_MOVED, x, y)
				RETURN 1
			END IF

			pt.x = LOWORD(lParam)
			pt.y = HIWORD(lParam)	
			ClientToScreen (hWnd, &pt)
			ScreenToClient (hWndParent, &pt)
					
			IF sp.style = $$SS_HORZ THEN 
				sp.xdrag = pt.x 
			ELSE 
				sp.ydrag = pt.y
			END IF  

			IF (sp.xdrag >= 0 || sp.ydrag >= 0) THEN 
				GetClientRect (hWndParent, &rc)

		    hdc = GetDCEx (hWndParent, NULL, $$DCX_PARENTCLIP)
		    hbr = SelectObject (hdc, sp.hbrDotty)
				IF sp.style = $$SS_HORZ THEN 
					IF (sp.xdrag >= 0) THEN 
						PatBlt (hdc, SPLT (sp.xdrag, sp.splitterSize), 0, sp.splitterSize, rc.bottom, $$PATINVERT)
					END IF 
				ELSE 
					IF (sp.ydrag >= 0) THEN 
						PatBlt (hdc, 0, SPLT (sp.ydrag, sp.splitterSize), rc.right, sp.splitterSize, $$PATINVERT)
					END IF
				END IF  
		    SelectObject (hdc, hbr)
		    ReleaseDC (hWndParent, hdc)

		    SetCapture (hWnd)
			END IF
			IF pData THEN RtlMoveMemory (pData, &sp, SIZE(SPLITTERDATA)) 
			RETURN 1

		CASE $$WM_LBUTTONUP:
			IF (sp.xdrag >= 0 || sp.ydrag >= 0) THEN
		    sp.dragDone = 1
				IF pData THEN RtlMoveMemory (pData, &sp, SIZE(SPLITTERDATA))
		    ReleaseCapture ()
			END IF
			RETURN 1
			
		CASE $$WM_MOUSELEAVE:
			fTrackMouse = 0
			IF fHot THEN
				fHot = 0
				InvalidateRect (hWnd, NULL, 1)
			END IF 
			SetCursor (LoadCursorA (0, $$IDC_ARROW))	' change cursor back to standard arrow
			
		CASE $$WM_MOUSEMOVE:
			IFZ fTrackMouse THEN
				tme.cbSize = SIZE(tme)
				tme.dwFlags = $$TME_LEAVE
				tme.hwndTrack = hWnd
				ret = TrackMouseEvent (&tme)
				fTrackMouse = $$TRUE
			END IF
			
			GetClientRect (hWnd, &rc)
			x = LOWORD (lParam)
			y = HIWORD (lParam)
			
			' check to see if mouse is in hot button area
			SELECT CASE sp.style
				CASE $$SS_HORZ:
					top = ((rc.bottom - 115)/2)
					bottom = top + 115 
					IF (y >= top && y <= bottom) THEN
						SetCursor (sp.hCursorHand)
						IF !fHot THEN
							fHot = $$TRUE
							InvalidateRect (hWnd, NULL, 1)
							RETURN 1
						END IF
					ELSE
						SetCursor (sp.hCursorH)
						IF (fHot) THEN 
							fHot = 0
							InvalidateRect (hWnd, NULL, 1)
						END IF 
					END IF 
				CASE $$SS_VERT:
					left = ((rc.right - 115)/2)
					right = left + 115 
					IF (x >= left && x <= right) THEN
						SetCursor (sp.hCursorHand)
						IF !fHot THEN
							fHot = $$TRUE
							InvalidateRect (hWnd, NULL, 1)
							RETURN 1
						END IF
					ELSE
						SetCursor (sp.hCursorV)
						IF (fHot) THEN 
							fHot = 0
							InvalidateRect (hWnd, NULL, 1)
						END IF 
					END IF 
			END SELECT

			IF (sp.xdrag >= 0 || sp.ydrag >= 0) THEN
		    GetClientRect (hWndParent, &rc)

				pos = GetMessagePos ()
				pt.x = LOWORD (pos)	
				pt.y = HIWORD (pos)
		    ScreenToClient (hWndParent, &pt)

		    hdc = GetDCEx (hWndParent, NULL, $$DCX_PARENTCLIP)
		    hbr = SelectObject (hdc, sp.hbrDotty)

				IF sp.style = $$SS_HORZ THEN
					IF (pt.x < sp.xlower) THEN pt.x = sp.xlower
					IF (pt.x > rc.right - sp.xupper) THEN pt.x = rc.right - sp.xupper
					IF (sp.xdrag >= 0) THEN
						PatBlt (hdc, SPLT (sp.xdrag, sp.splitterSize), 0, sp.splitterSize, rc.bottom, $$PATINVERT)
						sp.xdrag = pt.x
						PatBlt (hdc, SPLT (sp.xdrag, sp.splitterSize), 0, sp.splitterSize, rc.bottom, $$PATINVERT)
					END IF
				ELSE
			    IF (pt.y < sp.ylower) THEN pt.y = sp.ylower
			    IF (pt.y > rc.bottom - sp.yupper) THEN pt.y = rc.bottom - sp.yupper
					IF (sp.ydrag >= 0) THEN
						PatBlt (hdc, 0, SPLT (sp.ydrag, sp.splitterSize), rc.right, sp.splitterSize, $$PATINVERT)
						sp.ydrag = pt.y
						PatBlt (hdc, 0, SPLT (sp.ydrag, sp.splitterSize), rc.right, sp.splitterSize, $$PATINVERT)
					END IF
				END IF 

				IF pData THEN RtlMoveMemory (pData, &sp, SIZE(SPLITTERDATA))
		    SelectObject (hdc, hbr)
		    ReleaseDC (hSplitter, hdc)
			END IF
			RETURN 1
			
		CASE ELSE :
			RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION


FUNCTION SPLT (pos, w)
	RETURN ((pos) - (w)/2 + 1)
END FUNCTION

FUNCTION SPRB (pos, w)
	RETURN ((pos) - (w)/2 + 1 + (w))
END FUNCTION

FUNCTION CURSORPOS_OK (cur, spl, w)
	RETURN ((spl) >= 0 && (cur) >= SPLT (spl, w) && (cur) <= SPRB (spl, w))
END FUNCTION

FUNCTION SplitterNotifyParent (hSplitter, code, xParam, yParam)

	STATIC NMSPLITTER notify

  notify.hdr.hwndFrom	= hSplitter
  notify.hdr.idFrom	= GetWindowLongA (hSplitter, $$GWL_ID)
  notify.hdr.code	= code
  notify.x = xParam
  notify.y = yParam

  SendMessageA (GetParent (hSplitter), $$WM_NOTIFY, notify.hdr.idFrom, &notify)

END FUNCTION


FUNCTION CalculateColor (front, back, alpha)

	' solid color obtained as a result of alpha-blending

		frontRed = GetRed (front)
		frontGreen = GetGreen (front)
		frontBlue = GetBlue (front)
		
		backRed = GetRed (back)
		backGreen = GetGreen (back)
		backBlue = GetBlue (back)
			
		newRed   = UBYTE (frontRed*alpha/255.0 + backRed*((255-alpha)/255.0))
		newGreen = UBYTE (frontGreen*alpha/255.0 + backGreen*((255-alpha)/255.0))
		newBlue  = UBYTE (frontBlue*alpha/255.0 + backBlue*((255-alpha)/255.0))

		RETURN RGB (newRed, newGreen, newBlue)

END FUNCTION

FUNCTION GetRed (color)

	RETURN (color MOD 256)

END FUNCTION

FUNCTION GetGreen (color)

	RETURN ((color\256) MOD 256)

END FUNCTION

FUNCTION GetBlue (color)

	RETURN ((color\65536) MOD 256)

END FUNCTION

FUNCTION DrawLine (hdc, x1, y1, x2, y2, penStyle, width, color)

	IFZ hdc THEN RETURN ($$TRUE)
	IFZ width THEN width = 1
	
	hPen = CreatePen (penStyle, width, color)
	last = SelectObject (hdc, hPen)
	
	MoveToEx (hdc, x1, y1, 0)
	LineTo (hdc, x2, y2)
	
	SelectObject (hdc, last)
	DeleteObject (hPen)

END FUNCTION

FUNCTION DrawArrow (hdc, x, y, color, direction)

	POINT corner[]

	IFZ hdc THEN RETURN ($$TRUE)

	hPen = CreatePen ($$PS_SOLID, 1, color)
	lastPen = SelectObject (hdc, hPen)	
	
	hbr = CreateSolidBrush (color)
	lastBrush = SelectObject (hdc, hbr)
	
	DIM corner[4]
	
	SELECT CASE direction
		CASE $$TriangleUp :
			corner[0].x = x + 3
			corner[0].y = y
			corner[1].x = x + 6
			corner[1].y = y + 4
			corner[2].x = x
			corner[2].y = y + 4
			corner[3].x = x + 3
			corner[3].y = y
			corner[4].x = x + 6
			corner[4].y = y + 4
		CASE $$TriangleRight :
			corner[0].x = x
			corner[0].y = y
			corner[1].x = x + 3
			corner[1].y = y + 3
			corner[2].x = x
			corner[2].y = y + 6
			corner[3].x = x
			corner[3].y = y
			corner[4].x = x + 3
			corner[4].y = y + 3
		CASE $$TriangleDown :
			corner[0].x = x
			corner[0].y = y
			corner[1].x = x + 6
			corner[1].y = y
			corner[2].x = x + 3
			corner[2].y = y + 3
			corner[3].x = x
			corner[3].y = y
			corner[4].x = x + 6
			corner[4].y = y
		CASE $$TriangleLeft :
			corner[0].x = x + 3
			corner[0].y = y
			corner[1].x = x 
			corner[1].y = y + 3
			corner[2].x = x + 3
			corner[2].y = y + 6
			corner[3].x = x + 3
			corner[3].y = y
			corner[4].x = x
			corner[4].y = y + 3	
	END SELECT 

	Polygon (hdc, &corner[], 3)
	
	SelectObject (hdc, lastPen)
	SelectObject (hdc, lastBrush)
	DeleteObject (hPen)
	DeleteObject (hbr)

	RETURN ($$TRUE)

END FUNCTION

FUNCTION DrawRectangle (hdc, x, y, w, h, color)

	IFZ hdc THEN RETURN ($$TRUE)
	
	hPen = CreatePen ($$PS_SOLID, 1, color)
	lastPen = SelectObject (hdc, hPen)

	Rectangle (hdc, x, y, x+w, y+h)
	
	SelectObject (hdc, lastPen)
	DeleteObject (hPen)

END FUNCTION

END PROGRAM
