'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This custom graph control can be used to
' dynamically draw line or bar graph that
' which can be continuously updated.
' ---
' This custom control shows that XBasic can
' create custom control dlls using custom
' window messages.
' ---
' To use this control, just IMPORT "graph"
' in your PROLOG. The graph control class is
' registered automatically in the dll's
' Entry () function. The programmer can then
' create multiple instances of this control just
' like any other Win32 common control.
' ---
' The graph class name is:
' $$GRAPHCLASSNAME = "graphctrl"
' ---
' For an example, see graphtest.x or pid.x
' under /demo/gui/pid/
' ---
' (c) 2002 GPL David SZAFRANSKI
' dszafranski@wanadoo.fr

PROGRAM	"graph"  		' 1-8 char program/file name without .x or any .extent
VERSION	"0.0001"    ' version number - increment before saving altered program
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
TYPE GRAPHDATA
	XLONG	.hWndParent			' handle of parent window
	XLONG	.grColor				' graph line color
	XLONG	.bkColor				' graph back color
	XLONG	.gdColor				' grid line color
	XLONG	.grLineWidth		' graph line width
	XLONG	.gdLineWidth		' grid line width
	XLONG	.style					' graph style, $$GS_LINE or $$GS_BAR
	XLONG	.stepSize				' x axis interval for each update
	XLONG	.freeze					' update status - $$TRUE or $$FALSE
	XLONG	.direction			' direction of graph movement - $$GRAPH_LEFT or $$GRAPH_RIGHT
	XLONG	.hStatic				' static control handle
	XLONG	.id							' static control id
	XLONG	.min						' min range
	XLONG	.max						' max range
	XLONG	.gridUnits			' grid line spacing
	XLONG	.nPts						' number of points that can be plotted
	POINT	.graph[2047]		' array of xy data points
END TYPE

EXPORT
DECLARE FUNCTION  Graph ()
END EXPORT
'
INTERNAL FUNCTION  GraphProc (hWnd, msg, wParam, lParam)
INTERNAL FUNCTION  StaticProc (hWnd, msg, wParam, lParam)
'
EXPORT

' graph class name
$$GRAPHCLASSNAME = "graphctrl"

' define graph styles
$$GS_LINE = 0			' default style
$$GS_BAR  = 1

' define graph direction constants
$$GRAPH_LEFT  = 0
$$GRAPH_RIGHT = 1

' define custom window messages
$$WM_SET_GRAPH_RANGE             = 1025		' set the min and max y values for y array value scaling against control height, wParam = y min (default = 0), lParam = y max (default = 100)
$$WM_SET_GRAPH_LINE_WIDTHS       = 1026		' wParam = grid line width (default = 1), lParam = graph line width (default = 1)
$$WM_SET_GRAPH_LINE_COLORS       = 1027		' wParam = grid line color (default = LTGRAY = RGB(192, 192, 192)), lParam = graph line color (default = RED = RGB(255, 0, 0))
$$WM_SET_GRAPH_BACKCOLOR         = 1028		' wParam = 0, lParam = control back color (default = WHITE = RGB(255,255,255))
$$WM_SET_GRAPH_STYLE             = 1029		' wParam = 0, lParam = $$GS_LINE or $$GS_BAR (default = $$GS_LINE)
$$WM_SET_GRAPH_FREEZE            = 1030		' wParam = 0, lParam = set freeze status, $$TRUE or $$FALSE (default = $$FALSE)
$$WM_SET_GRAPH_STEPSIZE          = 1031		' wParam = 0, lParam = x axis step size between updates (default = 10)
$$WM_SET_GRAPH_DIRECTION         = 1032		' wParam = 0, lParam = $$GRAPH_LEFT or $$GRAPH_RIGHT (default = $$GRAPH_LEFT)
$$WM_SET_GRAPH_GRID_UNITS        = 1033		' wParam = 0, lParam = grid line spacing in pixels (default = 10)
$$WM_GRAPH_UPDATE                = 1034		' wParam = 0, lParam = new y value, update array of points and redraw graph
$$WM_GET_GRAPH_FREEZE            = 1035		' return is freeze status, $$TRUE or $$FALSE
END EXPORT
'
'
' ######################
' #####  Graph ()  #####
' ######################
'
'
FUNCTION  Graph ()

	WNDCLASS wc
	STATIC init
	SHARED hInst

' do this once
	IF init THEN RETURN
	init = $$TRUE

' get Instance handle
	hInst = GetModuleHandleA (0)

' fill in WNDCLASS struct
	wc.style           = $$CS_GLOBALCLASS | $$CS_HREDRAW | $$CS_VREDRAW | $$CS_PARENTDC   '$$CS_OWNDC   '
	wc.lpfnWndProc     = &GraphProc()						' graph control callback function
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 4											' space for a pointer to a GRAPHDATA struct
	wc.hInstance       = hInst
	wc.hIcon           = 0
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = 0
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &"graphctrl"

' register window class
	RETURN RegisterClassA (&wc)

END FUNCTION
'
'
' ##########################
' #####  GraphProc ()  #####
' ##########################
'
FUNCTION  GraphProc (hWnd, msg, wParam, lParam)

	CREATESTRUCT cs
	RECT rect
	GRAPHDATA grdata
	POINT pt
	POINT temp[]
	STATIC idCount				' id of static control
	SHARED hInst
	PAINTSTRUCT ps

	SELECT CASE msg

		CASE $$WM_CREATE:
' create the heap for this instance of the class and
' allocate heap for the GRAPHDATA struct
			hHeap = GetProcessHeap ()
			pData = HeapAlloc (hHeap, $$HEAP_ZERO_MEMORY, SIZE(GRAPHDATA))

' store this data pointer in class data area
			SetLastError (0)
			ret = SetWindowLongA (hWnd, $$GWL_USERDATA, pData)

' get data in createstruct from pointer lParam
			RtlMoveMemory (&cs, lParam, SIZE(CREATESTRUCT))

' create the graph using a static control
			GetClientRect (hWnd, &rect)
			w = rect.right - rect.left
			h = rect.bottom - rect.top
			text$  = ""
			style  = $$WS_CHILD | $$WS_VISIBLE | $$SS_WHITERECT	'$$SS_LEFT '| $$SS_OWNERDRAW | $$SS_NOTIFY
			hStatic = CreateWindowExA (0, &"static", &text$, style, 0, 0, w, h, hWnd, idCount, hInst, 0)
			INC idCount

' assign static control callbacks StaticProc ()
			#old_proc = SetWindowLongA (hStatic, $$GWL_WNDPROC, &StaticProc())

' initialize default GRAPHDATA into data buffer
			IF pData THEN
				XLONGAT(pData)   	= cs.hWndParent			' handle of parent window
				XLONGAT(pData+4) 	= RGB(255,0,0)			' graph line color (red)
				XLONGAT(pData+8) 	= RGB(255,255,255)	' graph back color (white)
				XLONGAT(pData+12) = RGB(192,192,192)	' grid line color (light gray)
				XLONGAT(pData+16) = 1									' graph line width
				XLONGAT(pData+20) = 1									' grid line width
				XLONGAT(pData+24) = 0									' graph style, $$GS_LINE or $$GS_BAR
				XLONGAT(pData+28) = 10								' x axis interval for each update
				XLONGAT(pData+32) = 0									' freeze status - $$TRUE or $$FALSE
				XLONGAT(pData+36) = $$GRAPH_LEFT			' direction of graph movement - $$GRAPH_LEFT
				XLONGAT(pData+40) = hStatic						' static control handle
				XLONGAT(pData+44) = idCount						' static control id
				XLONGAT(pData+48) = 0									' min range
				XLONGAT(pData+52) = 100								' max range
				XLONGAT(pData+56) = 10								' grid spacing
				XLONGAT(pData+60) = w / 10						' no of pts to plot = width/stepSize
			END IF
			GOSUB InitDataArray
			InvalidateRgn (hStatic, 0, 0)
			RETURN 0

		CASE $$WM_DESTROY:
			hHeap = GetProcessHeap ()
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			DestroyWindow (grdata.hStatic)
			IF pData THEN
				HeapFree (hHeap, 0, pData)					' free the heap created in WM_CREATE
			END IF
			RETURN 0

  	CASE $$WM_SIZE:
			width  = LOWORD(lParam)
			height = HIWORD(lParam)
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)				' get graph control data
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			XLONGAT(pData+60) = width / grdata.stepSize					' set new number of pts to plot
			GOSUB InitDataArray
			MoveWindow (grdata.hStatic, 0, 0, width, height, 0)	' resize static control
			InvalidateRgn (grdata.hStatic, 0, 0)								' paint window
			RETURN 0

		CASE $$WM_SET_GRAPH_RANGE :
' client calls SendMessageA() to set the min/max range sizes
' store this data in object area
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			IF wParam != -1 THEN
				XLONGAT(pData+48) 	= wParam									' min range
			END IF
			IF lParam != -1 THEN
				XLONGAT(pData+52) 	= lParam									' max range
			END IF
			RETURN 0

		CASE $$WM_SET_GRAPH_LINE_WIDTHS:
' client calls SendMessageA() to set the graph/grid line widths
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			IFZ wParam THEN RETURN 0
			IFZ lParam THEN RETURN 0
			IF wParam != -1 THEN
				XLONGAT(pData+20) = wParam								' grid line width
			END IF
			IF lParam != -1 THEN
				IF grdata.style = $$GS_BAR THEN
					IF lParam >= grdata.stepSize-1 THEN
						lParam = grdata.stepSize-2
					END IF
				END IF
				XLONGAT(pData+16) = lParam								' graph line width
			END IF
			InvalidateRgn (grdata.hStatic, 0, 0)
			RETURN 0

		CASE $$WM_SET_GRAPH_LINE_COLORS:
' client calls SendMessageA() to set the graph/grid line colors
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			IF wParam != -1 THEN
				XLONGAT(pData+12) = wParam								' grid line color
			END IF
			IF lParam != -1 THEN
				XLONGAT(pData+4) = lParam									' graph line color
			END IF
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			InvalidateRgn (grdata.hStatic, 0, 0)
			RETURN 0

		CASE $$WM_SET_GRAPH_BACKCOLOR:
' client calls SendMessageA() to set the graph backcolor
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+8) = lParam
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			InvalidateRgn (grdata.hStatic, 0, 0)
			RETURN 0

		CASE $$WM_SET_GRAPH_STYLE:
' client calls SendMessageA() to set the graph style
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			SELECT CASE lParam
				CASE $$GS_LINE	: XLONGAT(pData+24) = lParam
				CASE $$GS_BAR		: XLONGAT(pData+24) = lParam
				CASE ELSE				: XLONGAT(pData+24) = $$GS_LINE
			END SELECT
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			InvalidateRgn (grdata.hStatic, 0, 0)
			RETURN 0

		CASE $$WM_SET_GRAPH_FREEZE:
' client calls SendMessageA() to set the graph freeze status
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			SELECT CASE lParam
				CASE $$FALSE	: XLONGAT(pData+32) = lParam
				CASE $$TRUE		: XLONGAT(pData+32) = lParam
				CASE ELSE			: XLONGAT(pData+32) = $$FALSE
			END SELECT
			RETURN 0

		CASE $$WM_GET_GRAPH_FREEZE:
' client calls SendMessageA() to get the graph freeze status
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			RETURN grdata.freeze

		CASE $$WM_SET_GRAPH_STEPSIZE:
' client calls SendMessageA() to set the graph x axis step interval
			IF lParam <= 0 THEN RETURN 0
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+28) = lParam											' stepSize
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			GetClientRect (grdata.hStatic, &rect)
			w = rect.right - rect.left
			nPts = w / lParam
			IF nPts > 2047 THEN nPts = 2047
			XLONGAT(pData+60) = nPts												' nPts
			GOSUB InitDataArray
			RETURN 0

		CASE $$WM_SET_GRAPH_DIRECTION:
' client calls SendMessageA() to set the graph direction
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			SELECT CASE lParam
				CASE $$GRAPH_LEFT		: XLONGAT(pData+36) = lParam
				CASE $$GRAPH_RIGHT	: XLONGAT(pData+36) = lParam
				CASE ELSE						: XLONGAT(pData+36) = $$GRAPH_LEFT
			END SELECT
			GOSUB InitDataArray
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			InvalidateRgn (grdata.hStatic, 0, 0)
			RETURN 0

		CASE $$WM_SET_GRAPH_GRID_UNITS:
' client calls SendMessageA() to set the graph grid spacing
			IF lParam < 2 THEN RETURN 0
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+56) = lParam
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			InvalidateRgn (grdata.hStatic, 0, 0)
			RETURN 0

		CASE $$WM_GRAPH_UPDATE :
' update the current graph with a new point
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))

			IF grdata.freeze = $$TRUE THEN RETURN 0

			DIM temp[2047]
			RtlMoveMemory (&temp[0], &grdata.graph[0], SIZE(grdata.graph[]))

			GetClientRect (grdata.hStatic, &rect)
			w = rect.right - rect.left
			h = rect.bottom - rect.top
			updateY = lParam

			IF updateY > grdata.max THEN updateY = grdata.max
			IF updateY < grdata.min THEN updataY = grdata.min

			offsetY = pData+68
			IF grdata.direction = $$GRAPH_RIGHT THEN
				temp[0].y = h - ((h * updateY)/(DOUBLE(grdata.max - grdata.min)))
				FOR i = 1 TO grdata.nPts
					temp[i].y = grdata.graph[i-1].y
				NEXT i
			ELSE
				temp[grdata.nPts].y = h - ((h * updateY)/(DOUBLE(grdata.max - grdata.min)))
				FOR i = grdata.nPts-1 TO 0 STEP -1
					temp[i].y = grdata.graph[i+1].y
				NEXT i
			END IF
			RtlMoveMemory (&grdata.graph[0], &temp[0], SIZE(grdata.graph[]))
			RtlMoveMemory (pData, &grdata, SIZE(GRAPHDATA))
			InvalidateRgn (grdata.hStatic, 0, 0)
			RETURN 0

	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)


' ***** InitDataArray *****
SUB InitDataArray
' initialize point array
	pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
	RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
	GetClientRect (grdata.hStatic, &rect)
	h = rect.bottom - rect.top
	offsetX = pData+64
	offsetY = pData+68
	incr = 0
	IF grdata.direction = $$GRAPH_RIGHT THEN
		FOR i = 0 TO grdata.nPts
			XLONGAT(offsetX + incr) = i * grdata.stepSize
			XLONGAT(offsetY + incr) = h
			incr = incr + 8
		NEXT i
	ELSE
		incr = grdata.nPts * 8
		FOR i = grdata.nPts TO 0 STEP -1
			XLONGAT(offsetX + incr) = i * grdata.stepSize
			XLONGAT(offsetY + incr) = h
			incr = incr - 8
		NEXT i
	END IF
END SUB

END FUNCTION
'
'
' ###########################
' #####  StaticProc ()  #####
' ###########################
'
FUNCTION  StaticProc (hWnd, msg, wParam, lParam)

	GRAPHDATA grdata
	RECT rect
	RECT rc

	SELECT CASE msg

		CASE $$WM_PAINT :
			IF (GetUpdateRect (hWnd, 0, 0)) THEN GOSUB Redraw
			ValidateRgn (hWnd, 0)								' don't forget to validate the static control
			RETURN 0
	END SELECT

	RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

' ***** Redraw *****
SUB Redraw
			hWndParent = GetParent (hWnd)
			pData = GetWindowLongA (hWndParent, $$GWL_USERDATA)
			RtlMoveMemory (&grdata, pData, SIZE(GRAPHDATA))
			GetClientRect (hWnd, &rect)
			w = rect.right - rect.left
			h = rect.bottom - rect.top

			hBrush 			= CreateSolidBrush (grdata.bkColor)
			hBrushBar   = CreateSolidBrush (grdata.grColor)
			hPen1       = CreatePen ($$PS_SOLID, grdata.gdLineWidth, grdata.gdColor)
			hPen2       = CreatePen ($$PS_SOLID, grdata.grLineWidth, grdata.grColor)
			ScreenDC    = GetDC (hWnd)
			MemDC       = CreateCompatibleDC (ScreenDC)

' create a bitmap big enough for the client rectangle
			MemBM = CreateCompatibleBitmap (ScreenDC, w, h)
			OldBM = SelectObject (MemDC, MemBM)

' draw the Grid
			FillRect (MemDC, &rect, hBrush)						' fill in background

			IF grdata.style = $$GS_LINE THEN
				SelectObject (MemDC, hPen1)
				FOR x = 0 TO w STEP grdata.gridUnits		' draw vertical grid lines
  				MoveToEx (MemDC, x, 0, 0)
  				LineTo (MemDC, x, h)
				NEXT
				FOR y = 0 TO h STEP grdata.gridUnits		' draw horizontal grid lines
  				MoveToEx (MemDC, 0, y, 0)
  				LineTo (MemDC, w, y)
				NEXT

				SelectObject (MemDC, hPen2)
				Polyline (MemDC, &grdata.graph[0], grdata.nPts + 1)	' Now to draw the graph in one pass

			ELSE																			' draw bar (histogram) chart
				SelectObject (MemDC, hPen1)
				FOR y = 0 TO h STEP grdata.gridUnits		' draw horizontal grid lines
  				MoveToEx (MemDC, 0, y, 0)
  				LineTo (MemDC, w, y)
				NEXT
				FOR i = 0 TO grdata.nPts								' draw vertical bars
					rc.bottom = h
					rc.top    = grdata.graph[i].y
					IF grdata.direction = $$GRAPH_RIGHT THEN
						rc.left  = grdata.graph[i].x
						rc.right = rc.left + grdata.grLineWidth
					ELSE
						rc.right = grdata.graph[i].x
						rc.left  = rc.right - grdata.grLineWidth
					END IF
					FillRect (MemDC, &rc, hBrushBar)
				NEXT i
			END IF

' copy the offscreen MemDC into the ScreenDC
			BitBlt (ScreenDC, rect.left, rect.top, w, h, MemDC, 0, 0, $$SRCCOPY)

			GdiObj = SelectObject(MemDC, OldBM)   ' done with off-screen bitmap and DC

' clean up after ourselves to prevent resource leaks
' reminder: DeleteObject fails if we do not ReleaseDC FIRST!
			ReleaseDC    (hWnd, ScreenDC)     '  GetDC requires ReleaseDC
			DeleteDC     (MemDC)     					'  CreateCompatibleDC requires DeleteDC
			DeleteObject (hBrush)
			DeleteObject (hBrushBar)
			DeleteObject (hPen1)
			DeleteObject (hPen2)
			DeleteObject (OldBM)
			DeleteObject (MemBM)
			DeleteObject (GdiObj)
END SUB



END FUNCTION
END PROGRAM
