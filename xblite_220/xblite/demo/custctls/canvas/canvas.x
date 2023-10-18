'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This custom canvas control can be used to display
' graphics or images on a scrolling window.
' ---
' This example shows how XBLite can create
' custom control dlls using custom window messages.
' ---
' To use this control, just IMPORT "canvas" in
' your PROLOG. ' The graph control class is
' registered automatically in the dll's Entry ()
' function. The programmer can then create
' multiple instances of this control just like
' any other Win32 common control.
' ---
' The graph class name is:
' $$CANVASCLASSNAME = "canvasctrl".
' ---
' NOTE: do NOT use any window border styles like
' WS_BORDER or exStyles like WS_EX_CLIENTEDGE
' when creating this child control with
' CreateWindow() or CreateWindowEx(). At this
' time, the control needs to be borderless.
' If you need a border, then draw a border with
' graphics functions around the control as needed.
' ---
' For examples, see canvastest.x, canvasswap.x,
' canvasmulti.x.
' ---
' (c) GPL 2002 David SZAFRANSKI
' dszafranski@wanadoo.fr

PROGRAM	"canvas"
VERSION	"0.0003"

'
' 5-21-2005 v0.0003 
' Simplified code
' Corrected error in erasing background.
' Added support for mousewheel scrolling
' Added support for scrolling using keys Home, End, PageUp, PageDown
' and arrow keys.
'
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT  "gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"
'
' *****************************
' ***** Type Declarations *****
' *****************************
'
TYPE CANVASDATA
	XLONG	.hWndParent			' handle of parent window
	XLONG	.hScroll				' scrolling window handle
	XLONG	.id							' static control id
	XLONG .style					' (not used)
	XLONG	.hImage					' handle to memory bitmap to display
	XLONG	.width					' image width
	XLONG	.height					' image height
	XLONG	.fSize					' sizing flag (not used)
	XLONG	.fScroll				' scrollbar toggle flag (IF $$TRUE then hide scrollbars)
END TYPE

EXPORT
DECLARE FUNCTION Canvas ()
DECLARE FUNCTION CanvasProc (hWnd, msg, wParam, lParam)
END EXPORT
'
DECLARE FUNCTION UpdateStdScrollbars (hWnd, code, pos, bar)
DECLARE FUNCTION OnMouseWheel (hWnd, msg, wParam, lParam)
DECLARE FUNCTION OnKeyDown (hWnd, msg, wParam, lParam)
DECLARE FUNCTION SetScrollBar (hWnd, bar, maxsize, pagesize)
DECLARE FUNCTION OnScroll (hWnd, bar, code, pos)
'
EXPORT

' canvas control class name
$$CANVASCLASSNAME = "canvasctrl"

' define custom window messages
$$WM_SET_CANVAS_IMAGE		= 1025		' set image handle to display - lParam = hMemBmpImage
$$WM_CLEAR_CANVAS_IMAGE	= 1026		' clear canvas
$$WM_TOGGLE_SCROLLBARS  = 1027    ' hide/show scrollbars (default is scrollbars displayed)
END EXPORT
'
'
' #######################
' #####  Canvas ()  #####
' #######################
'
'
FUNCTION  Canvas ()

	WNDCLASS wc
	STATIC init
	SHARED hInst

' do this once
	IF init THEN RETURN
	init = $$TRUE

' get Instance handle
	hInst = GetModuleHandleA (0)

' fill in WNDCLASS struct
	wc.style           = $$CS_GLOBALCLASS | $$CS_HREDRAW | $$CS_VREDRAW '| $$CS_OWNDC
	wc.lpfnWndProc     = &CanvasProc()			' canvas control callback function
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 4									' space for a pointer to a CANVASDATA struct
	wc.hInstance       = hInst
	wc.hIcon           = 0
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = GetStockObject ($$LTGRAY_BRUSH) 
	wc.lpszMenuName    = NULL
	wc.lpszClassName   = &"canvasctrl"

' register window class
	RETURN RegisterClassA (&wc)

END FUNCTION
'
'
' ##########################
' #####  CanvasProc ()  #####
' ##########################
'
FUNCTION  CanvasProc (hWnd, msg, wParam, lParam)

	WNDCLASS wc
	CREATESTRUCT cs
	RECT rect, rc
	CANVASDATA candata
	STATIC idCount				' id of static control
	SHARED hInst
	PAINTSTRUCT ps
	BITMAP bm
	SCROLLINFO siv, sih, si

	pData = GetWindowLongA (hWnd, $$GWL_USERDATA)											' get canvas control data
	IF pData THEN RtlMoveMemory (&candata, pData, SIZE(CANVASDATA))		' copy current info to candata

	SELECT CASE msg

		CASE $$WM_CREATE:
' create the heap for this instance of the class and
' allocate heap for the CANVASDATA struct
			hHeap = GetProcessHeap ()
			pData = HeapAlloc (hHeap, $$HEAP_ZERO_MEMORY, SIZE(CANVASDATA))

' store this data pointer in class data area
			SetLastError (0)
			ret = SetWindowLongA (hWnd, $$GWL_USERDATA, pData)

' get data in createstruct from pointer lParam
			RtlMoveMemory (&cs, lParam, SIZE(CREATESTRUCT))
			
' set window style for using scrollbars
			styleNew = cs.style | $$WS_HSCROLL | $$WS_VSCROLL
			SetWindowLongA (hWnd, $$GWL_STYLE, styleNew)	
			SetWindowPos (hWnd, 0, 0, 0, 0, 0, $$SWP_NOMOVE | $$SWP_NOSIZE | $$SWP_NOZORDER | $$SWP_FRAMECHANGED)

' initialize default CANVASDATA into data buffer
			IF pData THEN
				XLONGAT(pData)   	= cs.hWndParent			' handle of parent window
				XLONGAT(pData+4) 	=	hWnd						  ' handle of scrolling window ?? needed??
				XLONGAT(pData+8) 	= idCount						' control id
			END IF
			INC idCount
			RETURN

		CASE $$WM_DESTROY:
			hHeap = GetProcessHeap ()
			IF pData THEN
				HeapFree (hHeap, 0, pData)					' free the heap created in WM_CREATE
			END IF
			RETURN
			
		CASE $$WM_TOGGLE_SCROLLBARS :
			IFZ candata.fScroll THEN
				IF pData THEN 
					XLONGAT(pData+32) = $$TRUE
					SetScrollRange(hWnd, $$SB_HORZ, 0, 0, 1)
					SetScrollRange(hWnd, $$SB_VERT, 0, 0, 1)
				END IF	
			ELSE
				IF pData THEN 
					XLONGAT(pData+32) = $$FALSE	
				END IF					
			END IF
			SendMessageA (hWnd, $$WM_SIZE, $$SIZE_RESTORED, 0)
			InvalidateRect (hWnd, NULL, 1)
			UpdateWindow (hWnd)
			RETURN
			

		CASE $$WM_SET_CANVAS_IMAGE:																' client calls SendMessageA () to set the canvas style
			hImage = lParam
			IFZ hImage THEN RETURN
			IF GetObjectType (hImage) != $$OBJ_BITMAP THEN RETURN		' make sure handle is a valid bitmap object handle
			GetObjectA (hImage, SIZE(bm), &bm)											' get BITMAP data for image
			IF pData THEN
				XLONGAT(pData+16) = hImage														' set data into memory
				XLONGAT(pData+20) = bm.width													' set width
				XLONGAT(pData+24)	= bm.height													' set height
			END IF

			GetClientRect (hWnd, &rect)
			w = rect.right - rect.left
			h = rect.bottom - rect.top
			IF (bm.width < w) OR (bm.height < h) THEN								' if bitmap is smaller than client area
				color = RGB(192, 192, 192) 
				hdc = GetDC (hWnd)
				hPen = CreatePen ($$PS_SOLID, 1, color)
				hOldPen = SelectObject (hdc, hPen)
				hBrush = CreateSolidBrush (color)
				hOldBrush = SelectObject (hdc, hBrush)
				IF bm.width < w THEN																	' then erase areas around bitmap
					Rectangle (hdc, bm.width, rect.top, rect.right, rect.bottom)
				END IF
				IF bm.height < h THEN
					Rectangle (hdc, rect.left, bm.height, rect.right, rect.bottom)
				END IF
				SelectObject (hdc, hOldPen)
				SelectObject (hdc, hOldBrush)
				DeleteObject (hPen)
				DeleteObject (hBrush)
				ReleaseDC (hWnd, hdc)
			END IF

			SendMessageA (hWnd, $$WM_SIZE, $$SIZE_RESTORED, 0)	' send WM_SIZE msg
			InvalidateRect (hWnd, NULL, 1)											' paint scrollbar window to display image
			UpdateWindow (hWnd)																	' send WM_PAINT msg
			RETURN ($$TRUE)

		CASE $$WM_CLEAR_CANVAS_IMAGE :
			IF pData THEN
				XLONGAT(pData+16) = 0
				XLONGAT(pData+20) = 0
				XLONGAT(pData+24)	= 0
			END IF
			SendMessageA (hWnd, $$WM_SIZE, $$SIZE_RESTORED, 0)	' send WM_SIZE msg
			RETURN

		CASE $$WM_RBUTTONDOWN :
			hParent = GetParent (hWnd)
			IF hParent THEN SendMessageA (hParent, $$WM_RBUTTONDOWN, wParam, lParam)
			RETURN
			
		CASE $$WM_KEYDOWN :
			RETURN OnKeyDown (hWnd, msg, wParam, lParam)
			
		CASE $$WM_GETDLGCODE: RETURN $$DLGC_WANTARROWS	
			
		CASE $$WM_MOUSEWHEEL: 
			RETURN OnMouseWheel (hWnd, msg, wParam, lParam)
			
		CASE $$WM_MOUSEMOVE:
			SetFocus (hWnd)
			RETURN
			
		CASE $$WM_VSCROLL:
			IF candata.fScroll THEN RETURN
			OnScroll (hWnd, $$SB_VERT, LOWORD (wParam), HIWORD (wParam))
			RETURN
			
		CASE $$WM_HSCROLL:
			IF candata.fScroll THEN RETURN
			OnScroll (hWnd, $$SB_HORZ, LOWORD (wParam), HIWORD (wParam))
			RETURN
			
		CASE $$WM_PAINT :
			xCurrentScroll = GetScrollPos (hWnd, $$SB_HORZ)
			yCurrentScroll = GetScrollPos (hWnd, $$SB_VERT)
			hdc = BeginPaint (hWnd, &ps)
			hImage = candata.hImage
			hMemDC = CreateCompatibleDC (NULL)
			SelectObject (hMemDC, hImage)
			BitBlt (ps.hdc, ps.left, ps.top, (ps.right - ps.left), (ps.bottom - ps.top), hMemDC, ps.left+xCurrentScroll, ps.top+yCurrentScroll, $$SRCCOPY)
			EndPaint (hWnd, &ps)
			DeleteDC (hMemDC)
			RETURN

		CASE $$WM_SIZE:
			IF candata.fScroll THEN RETURN
			' reset scrollbar settings
			GetClientRect (hWnd, &rect)
			width = rect.right - rect.left
			height = rect.bottom - rect.top
			SetScrollBar (hWnd, $$SB_HORZ, candata.width, width)
			SetScrollBar (hWnd, $$SB_VERT, candata.height, height)
			RETURN

	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
'
' ####################################
' #####  UpdateStdScrollbars ()  #####
' ####################################
'
' Update thumb position in a standard window scrollbar
'
' IN : 	hWnd		window handle
' 			code		scrollbar message (LOWWORD(wParam))
'				pos			scrollbar position (HIWORD(wParam))
'				bar			horizontal or vertical bar (SB_HORZ or SB_VERT)
'
FUNCTION  UpdateStdScrollbars (hWnd, code, pos, bar)

	RECT rect
	SCROLLINFO si

	si.cbSize = SIZE(si)
	si.fMask = $$SIF_ALL
	GetScrollInfo (hWnd, bar, &si)

  SELECT CASE code
		
		CASE $$SB_TOP:						' Scroll to top
			newPos = 0
			
		CASE $$SB_BOTTOM:					' Scroll to bottom
			newPos = si.nMax

		CASE $$SB_LINEDOWN:       ' Scrolls one line down
			newPos = si.nPos + 5

		CASE $$SB_LINEUP:         ' Scrolls one line up
			newPos = si.nPos - 5

		CASE $$SB_PAGEDOWN:       ' Scrolls one page down
			newPos = si.nPos + 35

		CASE $$SB_PAGEUP:         ' Scrolls one page up
			newPos = si.nPos - 35

		CASE $$SB_THUMBTRACK:     ' The user is dragging the scroll box. This message is sent repeatedly until the user releases the mouse button. The nPos parameter indicates the position that the scroll box has been dragged to.
			newPos = si.nTrackPos

		CASE ELSE:
			newPos = si.nPos

	END SELECT

	GetClientRect (hWnd, &rect)

	IF bar = $$SB_VERT THEN
		newSize = rect.bottom - rect.top
	ELSE
		newSize = rect.right - rect.left
	END IF

	newPos = MAX(0, newPos)
	newPos = MIN(si.nMax-newSize+1, newPos)

	IF newPos = si.nPos THEN RETURN

	delta = newPos - si.nPos
	si.nPos = newPos

	IF bar = $$SB_VERT THEN
		dy = -delta
	ELSE
		dx = -delta
	END IF

	si.cbSize = SIZE(si)
	si.fMask = $$SIF_POS
	SetScrollInfo (hWnd, bar, &si, $$TRUE)

	ScrollWindowEx (hWnd, dx, dy, 0, 0, 0, 0, $$SW_INVALIDATE)

END FUNCTION
'
' ##########################
' #####  OnMouseWheel  #####
' ##########################
'
' Handle mousewheel messages, scroll image
'
FUNCTION OnMouseWheel (hWnd, msg, wParam, lParam)

	delta = HIWORD(wParam)

	SELECT CASE TRUE
		CASE wParam & $$MK_SHIFT   : RETURN DefWindowProcA (hWnd, msg, wParam, lParam) ' datazoom
		CASE wParam & $$MK_CONTROL : RETURN DefWindowProcA (hWnd, msg, wParam, lParam) ' zoom image?? 
		CASE ELSE : 
	END SELECT
	
	IF delta < 0 THEN
		wP = $$SB_LINEDOWN 
	ELSE
		wP = $$SB_LINEUP
	END IF
	SendMessageA (hWnd, $$WM_VSCROLL, wP, 0) 

END FUNCTION
'
' #######################
' #####  OnKeyDown  #####
' #######################
'
' Handle key messages, scroll image
'
FUNCTION OnKeyDown (hWnd, msg, wParam, lParam)

	virtKey = wParam
	
	SELECT CASE wParam
		CASE $$VK_PRIOR : SendMessageA (hWnd, $$WM_VSCROLL, $$SB_PAGEUP, 0) 
		CASE $$VK_NEXT  : SendMessageA (hWnd, $$WM_VSCROLL, $$SB_PAGEDOWN, 0) 
		CASE $$VK_END   : SendMessageA (hWnd, $$WM_VSCROLL, $$SB_BOTTOM, 0)
											SendMessageA (hWnd, $$WM_HSCROLL, $$SB_BOTTOM, 0)
		CASE $$VK_HOME  :	SendMessageA (hWnd, $$WM_VSCROLL, $$SB_TOP, 0)
											SendMessageA (hWnd, $$WM_HSCROLL, $$SB_TOP, 0)
		CASE $$VK_LEFT	:	SendMessageA (hWnd, $$WM_HSCROLL, $$SB_LINEUP, 0)
		CASE $$VK_RIGHT	:	SendMessageA (hWnd, $$WM_HSCROLL, $$SB_LINEDOWN, 0)
		CASE $$VK_UP		: SendMessageA (hWnd, $$WM_VSCROLL, $$SB_LINEUP, 0)
		CASE $$VK_DOWN	: SendMessageA (hWnd, $$WM_VSCROLL, $$SB_LINEDOWN, 0)
			
	END SELECT

END FUNCTION

'
' ##########################
' #####  SetScrollBar  #####
' ##########################
'
' Set scroll bar maxsize and page size
' bar is $$SB_HORZ or $$SB_VERT 
'
FUNCTION SetScrollBar (hWnd, bar, maxsize, pagesize)

  SCROLLINFO si

  si.cbSize = SIZE(SCROLLINFO)
  si.fMask  = $$SIF_ALL
  si.nMin   = 0
  si.nMax   = maxsize - 1
  si.nPage  = pagesize
  si.nPos   = 0
  SetScrollInfo (hWnd, bar, &si, 1)

END FUNCTION
'
' ######################
' #####  OnScroll  #####
' ######################
'
' handle scrollbar messages, update scrollbar positions
'
FUNCTION OnScroll (hWnd, bar, code, pos)

  SCROLLINFO si

' get current scrollbar info
	si.cbSize = SIZE(si)
	si.fMask = $$SIF_ALL
	GetScrollInfo (hWnd, bar, &si)
	
' check to see if scrollbar is enabled
' if scrollbar is enabled then update canvas and scrollbar positions
	IF si.nPage <= (si.nMax - si.nMin) THEN 
		UpdateStdScrollbars (hWnd, code, pos, bar)
	END IF

END FUNCTION

END PROGRAM
