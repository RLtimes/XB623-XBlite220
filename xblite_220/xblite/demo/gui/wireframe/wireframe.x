'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This graphics demo draws 3D wire-frame objects and allows
' for its rotation and translation.
' Data for objects found at
' http://astronomy.swin.edu.au/~pbourke/polyhedra/super3d/

' modifications by Michael McElligott  (28/9/03)
' modified rendering technique for smooth flicker-free
' animation (BitBlt() in SUB RotateObject).
' added 'editbox' switches to auto-update object when
' angle is changed (EN_CHANGE message).
' object is now displayed upon window creation.
' object is now auto-updated once new object file
' (via combobox) has been selected.
' due to the above, arrow keys can now be used to select
' an object (ie, combobox is in focus).
'
PROGRAM	"wireframe"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"		' msvcrt.dll

TYPE VERTICE
	DOUBLE	.x
	DOUBLE	.y
	DOUBLE	.z
END TYPE

' ************ .raw format **************

$$MAXFACETS 	= 95						' increase this for larger objects
$$MAXVERTICES = 11

TYPE FACET
	ULONG	.nVertices
	VERTICE	.v[$$MAXVERTICES]
END TYPE

TYPE WIREOBJ
	ULONG	.nFacets
	FACET	.f[$$MAXFACETS]			' larger values reduce the rotation speed
END TYPE

'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  RotateX (DOUBLE angle, DOUBLE y, DOUBLE z)
DECLARE FUNCTION  RotateY (DOUBLE angle, DOUBLE x, DOUBLE z)
DECLARE FUNCTION  RotateZ (DOUBLE angle, DOUBLE x, DOUBLE y)
DECLARE FUNCTION  CreateScreenBuffer (hWnd, w, h)
DECLARE FUNCTION  DeleteScreenBuffer (hMemDC)
DECLARE FUNCTION  DrawObject (hDC, WIREOBJ obj, flength, camz, x0, y0, POINT min, POINT max)
DECLARE FUNCTION  LoadObject (fileName$, WIREOBJ obj)
DECLARE FUNCTION  StringToStringArray (s$, s$[])
DECLARE FUNCTION  ComboboxAddString (hwndCtl, @text$)
DECLARE FUNCTION  GetComboboxSelection (hwndCtl, text$)
DECLARE FUNCTION  RotateObject (WIREOBJ objIn, WIREOBJ objOut, DOUBLE angleX, DOUBLE angleY, DOUBLE angleZ)
DECLARE FUNCTION  ScaleObject (WIREOBJ obj, DOUBLE scale)
DECLARE FUNCTION  DrawRect (hDC, x1, y1, x2, y2)
DECLARE FUNCTION  FileExists (fileName$)

' ***** Constants *****

$$DEGTORAD	= 0d3F91DF46A2529D39

'Control IDs

$$Button1  = 100
$$Button2  = 101
$$Button3  = 102
$$Button4  = 103
$$Button5  = 104
$$Button6  = 105
$$Button7  = 106
$$Button8  = 107

$$Static1 = 110
$$Static2 = 111
$$Static3 = 112

$$Edit1 = 120
$$Edit2 = 121
$$Edit3 = 122

$$Combobox1 = 130
$$Statusbar = 140
$$Group1 = 150
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

	SHARED hInst
	RECT rect, rc
	PAINTSTRUCT ps
	STATIC WIREOBJ object, object2, object3
	STATIC x0, y0, flength, camz
	STATIC fObject, scale#
	STATIC anglex, angley, anglez
	STATIC rawFiles$[]
	POINT min, max, oldMin, oldMax
	STATIC fZoom

	$ZoomMax = 2												' max zoom level

	SELECT CASE msg

		CASE $$WM_CREATE :

' create child controls
			#combo1  = NewChild ("combobox", "", 											$$CBS_DROPDOWNLIST | $$WS_VSCROLL, 	10,  12, 200, 150, hWnd, $$Combobox1, $$WS_EX_CLIENTEDGE)
			#button1 = NewChild ("button", "Draw Object", 						$$BS_PUSHBUTTON | $$WS_TABSTOP,  		10,  36, 202, 24, hWnd, $$Button1, 0)
			#button2 = NewChild ("button", "Rotate Around X-Axis",		$$BS_PUSHBUTTON | $$WS_TABSTOP,  		10,  60, 202, 24, hWnd, $$Button2, 0)
			#button3 = NewChild ("button", "Rotate Around Y-Axis", 		$$BS_PUSHBUTTON | $$WS_TABSTOP,  		10,  84, 202, 24, hWnd, $$Button3, 0)
			#button4 = NewChild ("button", "Rotate Around Z-Axis", 		$$BS_PUSHBUTTON | $$WS_TABSTOP,  		10, 108, 202, 24, hWnd, $$Button4, 0)
			#button5 = NewChild ("button", "Clear Drawing", 					$$BS_PUSHBUTTON | $$WS_TABSTOP, 		10, 132, 202, 24, hWnd, $$Button5, 0)
			#static1 = NewChild ("static", "Init X Angle ", 					$$SS_RIGHT | $$SS_CENTERIMAGE	, 		10, 156, 160, 24, hWnd, $$Static1, $$WS_EX_STATICEDGE)
			#static2 = NewChild ("static", "Init Y Angle ", 					$$SS_RIGHT | $$SS_CENTERIMAGE	, 		10, 180, 160, 24, hWnd, $$Static2, $$WS_EX_STATICEDGE)
			#static3 = NewChild ("static", "Init Z Angle ", 					$$SS_RIGHT | $$SS_CENTERIMAGE	, 		10, 204, 160, 24, hWnd, $$Static2, $$WS_EX_STATICEDGE)
			#edit1   = NewChild ("edit", "90", 												$$ES_NUMBER | $$ES_AUTOHSCROLL | $$WS_TABSTOP, 	170, 156,  40, 24, hWnd, $$Edit1, $$WS_EX_CLIENTEDGE)
			#edit2   = NewChild ("edit", "30", 												$$ES_NUMBER | $$ES_AUTOHSCROLL | $$WS_TABSTOP, 	170, 180,  40, 24, hWnd, $$Edit2, $$WS_EX_CLIENTEDGE)
			#edit3   = NewChild ("edit", "0", 												$$ES_NUMBER | $$ES_AUTOHSCROLL | $$WS_TABSTOP, 	170, 204,  40, 24, hWnd, $$Edit3, $$WS_EX_CLIENTEDGE)

' data files
			DIM rawFiles$[22]
			rawFiles$[0] = "Cube.raw"
			rawFiles$[1] = "Dodec.raw"
			rawFiles$[2] = "DualRhombTriHex.raw"
			rawFiles$[3] = "GreatRhombIcosDodec.raw"
			rawFiles$[4] = "GreatRhombTriHexTriHex.raw"
			rawFiles$[5] = "Icosahedron.raw"
			rawFiles$[6] = "IcosDod.raw"
			rawFiles$[7] = "Octahedron.raw"
			rawFiles$[8] = "RhombicDodecahedron.raw"
			rawFiles$[9] = "RhombIcosDodec.raw"
			rawFiles$[10] = "RhombiCubeOcta.raw"
			rawFiles$[11] = "SnbDdcleft.raw"
			rawFiles$[12] = "SnubCubeRight.raw"
			rawFiles$[13] = "SnubTriHexTriHex.raw"
			rawFiles$[14] = "Tetrahedron.raw"
			rawFiles$[15] = "TriHexMaleInterm.raw"
			rawFiles$[16] = "TriTri.raw"
			rawFiles$[17] = "TruncateDodeca.raw"
			rawFiles$[18] = "TruncateTetrahedron.raw"
			rawFiles$[19] = "TruncCube.raw"
			rawFiles$[20] = "TruncCubeOcta.raw"
			rawFiles$[21] = "TruncIcos.raw"
			rawFiles$[22] = "TruncOctahedron.raw"

' add items to combobox
			upper = UBOUND(rawFiles$[])
			FOR i = 0 TO upper
				ComboboxAddString (#combo1, rawFiles$[i])
			NEXT i

' add a statusbar control
			#statusBar = NewChild ($$STATUSCLASSNAME, "Use right/left mouse button to change current scaling.", $$SBARS_SIZEGRIP, 0, 0, 0, 0, hWnd, $$Statusbar, 0)

' set initial current selection in combobox3
			SendMessageA (#combo1, $$CB_SETCURSEL, 0, 0)

' create a screen buffer
			GetClientRect (hWnd, &rect)
			#hMemDC = CreateScreenBuffer (hWnd, rect.right, rect.bottom)
			FillRect (#hMemDC, &rect, GetStockObject ($$BLACK_BRUSH))

' create and select a solid green pen
			#hPen 		= CreatePen ($$PS_SOLID, 1, RGB(0, 255, 0))
			#hOldPen 	= SelectObject (#hMemDC, #hPen)

			GOSUB GetInitData
			GOSUB DrawObject

		CASE $$WM_DESTROY :
			SelectObject (#hMemDC, #hOldPen)
			DeleteObject (#hPen)									' delete pen
			DeleteScreenBuffer (#hMemDC)
			PostQuitMessage(0)

		CASE $$WM_PAINT :
			hDC = BeginPaint (hWnd, &ps)
			BitBlt (hDC, ps.left, ps.top, ps.right-ps.left, ps.bottom-ps.top, #hMemDC, ps.left, ps.top, $$SRCCOPY)
			EndPaint (hWnd, &ps)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID  = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode

				CASE $$CBN_SELCHANGE :
					SELECT CASE controlID
						CASE $$Combobox1 : GOSUB GetInitData : GOSUB DrawObject
					END SELECT

				CASE $$EN_CHANGE :
					SELECT CASE	controlID
						CASE $$Edit1 : IF fObject THEN GOSUB DrawObject
						CASE $$Edit2 : IF fObject THEN GOSUB DrawObject
						CASE $$Edit3 : IF fObject THEN GOSUB DrawObject
					END SELECT

				CASE $$BN_CLICKED :
					SELECT CASE controlID
						CASE $$Button1 :	GOSUB GetInitData : GOSUB DrawObject
						CASE $$Button2 :	anglex = 1 : angley = 0 : anglez = 0 : IF fObject THEN GOSUB RotateObject
						CASE $$Button3 :	anglex = 0 : angley = 1 : anglez = 0 : IF fObject THEN GOSUB RotateObject
						CASE $$Button4 :	anglex = 0 : angley = 0 : anglez = 1 : IF fObject THEN GOSUB RotateObject
						CASE $$Button5 :	GOSUB Clear
					END SELECT
			END SELECT

		CASE $$WM_LBUTTONDOWN :
			IFZ fObject THEN RETURN
			INC fZoom
			IF fZoom > $ZoomMax THEN									' only one positive level of zoom allowed
				DEC fZoom
				RETURN
			END IF
			object2 = object													' original object is never altered
			scale# = 1.5 * scale#											' scale 1.5x
			ScaleObject (@object2, scale#)						' scale object2
			GOSUB DrawObject

		CASE $$WM_RBUTTONDOWN :
			IFZ fObject THEN RETURN 0
			DEC fZoom																	' decrease zoom level
			object2 = object													' original object is never altered
			scale# = scale#/1.5												' scale 1/1.5x
			ScaleObject (@object2, scale#)						' scale object2
			GOSUB DrawObject

		CASE $$WM_CTLCOLORSTATIC :
			RETURN SetColor (0, RGB(192, 192, 192), wParam, lParam)	' set static control background color

    CASE ELSE :
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

' ***** GetInitData *****
SUB GetInitData

' initialize object origin and camera flength and camz
	GetClientRect (hWnd, &rect)
	x0 = (rect.right >> 1) + 110					' set x origin
	y0 = (rect.bottom >> 1) - 24					' set y origin
	flength =	260													' set camera focal length
	camz 		= -8													' set camera z position (must be <-1)

' get object selection from combobox
	index = SendMessageA (#combo1, $$CB_GETCURSEL, 0, 0)	' get current selection index

' load object data into WIREOBJ struct

'	dir$ = "c:/xblite/demo/gui/wireframe/"								' normally files are in same directory as executable
	dir$ = ""

	IFZ FileExists (dir$ + rawFiles$[index]) THEN 				' make sure file exists
		error$ = "Error : Unable to Load Object File Correctly"
		GOSUB Error
		RETURN 0
	ELSE
		LoadObject (dir$ + rawFiles$[index], @object)			' open file and parse data
		fObject = $$TRUE														' an object has been loaded
	END IF

	object2 = object															' original object is never altered
	scale# = 1.0/50.0
	ScaleObject (@object2, scale#)								' scale object2

	fZoom = 0																			' initialize zoom level
END SUB

' ***** GetInitAngles *****
SUB GetInitAngles
' get initial starting rotation angles from input text boxes
	anglex$ = NULL$(10)
	GetWindowTextA (#edit1, &anglex$, 10)
	anglex$ = CSIZE$(anglex$)
	angle_x0# = DOUBLE(anglex$)

	angley$ = NULL$(10)
	GetWindowTextA (#edit2, &angley$, 10)
	angley$ = CSIZE$(angley$)
	angle_y0# = DOUBLE(angley$)

	anglez$ = NULL$(10)
	GetWindowTextA (#edit3, &anglez$, 10)
	anglez$ = CSIZE$(anglez$)
	angle_z0# = DOUBLE(anglez$)
END SUB

' ***** DrawObject *****
SUB DrawObject
	GOSUB Clear
	GOSUB GetInitAngles

' rotate object
	RotateObject (object2, @object3, angle_x0#, angle_y0#, angle_z0#)

' draw object
	DrawObject (#hMemDC, object3, flength, camz, x0, y0, @min, @max)

' update only parts of screen that have object
	GetClientRect (hWnd, &rect)
	x1 = min.x-1
	x2 = max.x+1
	rect.left 	= MAX(210, x1)
	rect.right 	= MIN(rect.right, x2)
	y1 = min.y-1
	y2 = max.y+1
	rect.top 		= MAX(0, y1)
	rect.bottom = MIN(rect.bottom-22, y2)
	InvalidateRect (hWnd, &rect, 1)
	UpdateWindow (hWnd)
END SUB


' ***** RotateObject *****
' this is clearly the section of code that needs
' optimization to improve speed of drawing

SUB RotateObject
	GOSUB Clear
	GOSUB GetInitAngles

'	start = GetTickCount ()

	hDC = GetDC (hWnd)

	GetClientRect (hWnd, &rect)

	right  = rect.right
	bottom = rect.bottom-22

	angle_x# = angle_x0#
	angle_y# = angle_y0#
	angle_z# = angle_z0#

	oldMin.x = 1
	oldMin.y = 1
	oldMax.x = 0
	oldMax.y = 0

	FOR i = 0 TO 360
		IF anglex THEN
			angle_x# = angle_x0# + i
		ELSE
			IF angley THEN
				angle_y# = angle_y0# + i
			ELSE
				angle_z# = angle_z0# + i
			END IF
		END IF

' clear previous object on screen
		x1 = oldMin.x-1
		x2 = oldMax.x+1
		rect.left 	= MAX(210, x1)
		rect.right 	= MIN(right, x2)
		y1 = oldMin.y-1
		y2 = oldMax.y+1
		rect.top 		= MAX(0, y1)
		rect.bottom = MIN(bottom, y2)
		FillRect (#hMemDC, &rect, GetStockObject ($$BLACK_BRUSH))

' rotate and draw object
		RotateObject (object2, @object3, angle_x#, angle_y#, angle_z#)
		DrawObject (#hMemDC, object3, flength, camz, x0, y0, @min, @max)

		oldMin = min : oldMax = max

' update only newly drawn portions of screen
		x1 = min.x-2
		x2 = max.x+2
		rect.left 	= MAX(210, x1)
		rect.right 	= MIN(right, x2)
		y1 = min.y-2
		y2 = max.y+2
		rect.top 		= MAX(0, y1)
		rect.bottom = MIN(bottom, y2)

'		DrawRect (#hMemDC, rect.left, rect.top, rect.right, rect.bottom) ' draw region that will be invalidated

' draw image from memory bitmap to screen
		BitBlt (hDC, rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top, #hMemDC, rect.left, rect.top, $$SRCCOPY)

		Sleep (5)																	' slow it down
	NEXT i

	ReleaseDC (hWnd, hDC)
'	finish = GetTickCount ()
'	PRINT "time="; finish-start
END SUB

' ***** Clear *****
SUB Clear
	GetClientRect (hWnd, &rect)
	rect.left = 220
	rect.bottom = rect.bottom - 24
	FillRect (#hMemDC, &rect, GetStockObject ($$BLACK_BRUSH))
	InvalidateRect (hWnd, &rect, 1)

END SUB

' ***** Error *****
SUB Error
	MessageBoxA (hWnd, &error$, &"Error Message", 0)
END SUB

END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
FUNCTION  InitGui ()

	SHARED hInst
	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT(0)
	InitCommonControls()					' initialize comctl32.dll library

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

	SHARED className$, hInst

' register window class
	className$  = "wireframedemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window as a "dialog box" style window
	title$  		= "3-D Wireframe Object Demo."
	style 			= $$WS_TABSTOP | $$WS_CAPTION | $$WS_SYSMENU   		' $$WS_OVERLAPPEDWINDOW
	w 					= 680
	h 					= 480
	exStyle			= $$WS_EX_DLGMODALFRAME
	#winMain		= NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' remove maximize button in titlebar
	oldStyle = GetWindowLongA (#winMain, $$GWL_STYLE)
	newStyle = oldStyle & ~$$WS_MAXIMIZEBOX
	SetWindowLongA (#winMain, $$GWL_STYLE, newStyle)

' gray out system menu items to prevent min/max action
	hSysMenu = GetSystemMenu (#winMain, 0)
	EnableMenuItem (hSysMenu, 3, $$MF_BYPOSITION | $$MF_GRAYED)
	EnableMenuItem (hSysMenu, 4, $$MF_BYPOSITION | $$MF_GRAYED)
	DrawMenuBar (hSysMenu)

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
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
'
'
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush
	IF hNewBrush THEN DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush (bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush

END FUNCTION
'
'
' ########################
' #####  RotateX ()  #####
' ########################
'
FUNCTION  RotateX (DOUBLE angle, DOUBLE y, DOUBLE z)

	DOUBLE ytemp
	angle = angle * $$DEGTORAD
	ytemp = y*cos(angle) - z*sin(angle)
	z 		= y*sin(angle) + z*cos(angle)
	y			= ytemp

END FUNCTION
'
'
' ########################
' #####  RotateY ()  #####
' ########################
'
FUNCTION  RotateY (DOUBLE angle, DOUBLE x, DOUBLE z)

	DOUBLE xtemp
	angle = angle * $$DEGTORAD
	xtemp	= x*cos(angle)  + z*sin(angle)
	z			= -x*sin(angle) + z*cos(angle)
	x			= xtemp


END FUNCTION
'
'
' ########################
' #####  RotateZ ()  #####
' ########################
'
FUNCTION  RotateZ (DOUBLE angle, DOUBLE x, DOUBLE y)

	DOUBLE xtemp
	angle = angle * $$DEGTORAD
	xtemp	= x*cos(angle) - y*sin(angle)
	y			= x*sin(angle) + y*cos(angle)
	x			= xtemp

END FUNCTION
'
'
' ###################################
' #####  CreateScreenBuffer ()  #####
' ###################################

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
	hBrush 	= GetStockObject ($$LTGRAY_BRUSH)
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
' #########################
' #####  DrawWire ()  #####
' #########################
'
FUNCTION  DrawObject (hDC, WIREOBJ obj, flength, camz, x0, y0, POINT min, POINT max)

	DOUBLE x, y, z
	POINT ptOld, poly[]

' create array of points for drawing with Polyline

	MoveToEx (hDC, 0, 0, &ptOld)

	min.x = 65536
	min.y = 65536

	upper = obj.nFacets-1

	FOR i = 0 TO upper
		nVertices = obj.f[i].nVertices
		top = nVertices - 1

		DIM poly[top]

		FOR j = 0 TO top
			x = obj.f[i].v[j].x
			y = -obj.f[i].v[j].y
			z = obj.f[i].v[j].z

			IFZ (z-camz) THEN RETURN
			tmp# 		= flength/(DOUBLE(z-camz))
			screenx = x * tmp# + x0
			screeny = y * tmp# + y0
			max.x = MAX (max.x, screenx)
			max.y = MAX (max.y, screeny)
			min.x = MIN (min.x, screenx)
			min.y = MIN (min.y, screeny)

			poly[j].x = screenx
			poly[j].y = screeny

		NEXT j

		MoveToEx (hDC, poly[top].x, poly[top].y, 0)
		PolylineTo (hDC, &poly[0], nVertices)
	NEXT i

	MoveToEx (hDC, ptOld.x, ptOld.y, 0)

END FUNCTION
'
'
' ###########################
' #####  LoadObject ()  #####
' ###########################
'
FUNCTION  LoadObject (fileName$, WIREOBJ obj)

	ifile = OPEN(fileName$, $$RD)
	IF ifile < 0 THEN GOSUB Error

	fileSize = LOF(ifile)
	IF fileSize THEN
		text$ = NULL$(fileSize)
		READ [ifile], text$
	END IF
	CLOSE (ifile)

	DIM text$[]
	StringToStringArray (text$, @text$[])

	upper = UBOUND(text$[])
	obj.nFacets = upper + 1

' parse line
	FOR i = 0 TO upper
		line$ = text$[i]
		GOSUB ParseLine
		index = 0
		nVertices = ULONG(data$[index])
		IFZ nVertices THEN
			PRINT "Error : LoadObject : Line with Zero Vertices"
			RETURN ($$TRUE)
		END IF

		INC index
		obj.f[i].nVertices = nVertices

		FOR j = 0 TO nVertices-1
			obj.f[i].v[j].x = DOUBLE(data$[index]) : INC index
			obj.f[i].v[j].y = DOUBLE(data$[index]) : INC index
			obj.f[i].v[j].z = DOUBLE(data$[index]) : INC index
		NEXT j
	NEXT i

' ***** ParseLine *****
SUB ParseLine
	DIM data$[37]							' important! change this if max vertices changes in FACET struct
	count = 0
	upper = LEN(line$)
	FOR v = 0 TO upper-1
		c = line${v}
		IF c = 32 || c = 10 || c = 13 THEN
 			INC count
			DO NEXT
		END IF
		data$[count] = data$[count] + CHR$(c)
	NEXT v
END SUB

RETURN


' ***** Error *****
SUB Error
	error = ERROR (0)
	XstErrorNumberToName (error, @error$)
	PRINT "error #"; error; "  = "; error$
	IF (ifile > 3) THEN CLOSE (ifile)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ####################################
' #####  StringToStringArray ()  #####
' ####################################
'
FUNCTION  StringToStringArray (s$, s$[])
'
	DIM s$[]
	IFZ s$ THEN RETURN
'
	lenString = LEN(s$)
	uString = (lenString >> 5) OR 7								' guess 32 chars/line
	DIM s$[uString]
	firstChar = 0
	line = 0
'
	DO
		nl = INSTR (s$, "\n", firstChar + 1)
		IFZ nl THEN																	' last line
			nl = lenString + 1
			GOSUB AddLine
			EXIT DO
		END IF
		GOSUB AddLine
		IF (firstChar >= lenString) THEN EXIT DO
	LOOP
'
	IF (s${lenString-1} != '\n') THEN DEC line
	IF (line != uString) THEN REDIM s$[line]
	RETURN ($$FALSE)
'
'	Add next s$ line to array.  Don't include \n or \r
'		firstChar	= offset (from 0) of first character on this line
'		nl				= index (from 1) of newLine (LF)
'
SUB AddLine
	chars = nl - firstChar - 1
	IF (nl > 1) THEN
		IF (s${nl-2} = '\r') THEN DEC chars		' skip \r before \n
	END IF
	IF (s${nl} = '\r') THEN INC nl					' skip \r after \n
	IF (chars > 0) THEN
		line$ = NULL$(chars)
		FOR i = 0 TO chars - 1
			line${i} = s${firstChar+i}
		NEXT i
		ATTACH line$ TO s$[line]
	END IF
	INC line
	firstChar = nl
	IF (line > uString) THEN
		uString = (uString + (uString >> 1)) OR 63
		REDIM s$[uString]
	END IF
END SUB

END FUNCTION
'
'
' ##################################
' #####  ComboboxAddString ()  #####
' ##################################
'
FUNCTION  ComboboxAddString (hwndCtl, @text$)
	IF text$ THEN
		RETURN SendMessageA (hwndCtl, $$CB_ADDSTRING, 0, &text$)
	END IF
END FUNCTION
'
'
' #####################################
' #####  GetComboboxSelection ()  #####
' #####################################
'
FUNCTION  GetComboboxSelection (hwndCtl, text$)

	index = SendMessageA (hwndCtl, $$CB_GETCURSEL, 0, 0)				' get current selection index
	len 	= SendMessageA (hwndCtl, $$CB_GETLBTEXTLEN, index, 0)	' get length of selected text
	text$ = NULL$(len)
	SendMessageA (hwndCtl, $$CB_GETLBTEXT, index, &text$)				' get selected text

END FUNCTION
'
'
' #############################
' #####  RotateObject ()  #####
' #############################
'
FUNCTION  RotateObject (WIREOBJ objIn, WIREOBJ objOut, DOUBLE angleX, DOUBLE angleY, DOUBLE angleZ)

	STATIC WIREOBJ objTemp

	objTemp = objIn
	upper = objIn.nFacets-1

	FOR i = 0 TO upper
		top = objIn.f[i].nVertices-1
		FOR j = 0 TO top

			IF angleX THEN
				y# = objTemp.f[i].v[j].y : z# = objTemp.f[i].v[j].z
				RotateX (angleX, @y#, @z#)
				objTemp.f[i].v[j].y = y# : objTemp.f[i].v[j].z = z#
			END IF

			IF angleY THEN
				x# = objTemp.f[i].v[j].x : z# = objTemp.f[i].v[j].z
				RotateY (angleY, @x#, @z#)
				objTemp.f[i].v[j].x = x# : objTemp.f[i].v[j].z = z#
			END IF

			IF angleZ THEN
				x# = objTemp.f[i].v[j].x : y# = objTemp.f[i].v[j].y
				RotateZ (angleZ, @x#, @y#)
				objTemp.f[i].v[j].x = x# : objTemp.f[i].v[j].y = y#
			END IF

		NEXT j
	NEXT i

	objOut = objTemp


END FUNCTION
'
'
' ############################
' #####  ScaleObject ()  #####
' ############################
'
FUNCTION  ScaleObject (WIREOBJ obj, DOUBLE scale)

	upper = obj.nFacets-1
	FOR i = 0 TO upper
		top = obj.f[i].nVertices-1
		FOR j = 0 TO top
			obj.f[i].v[j].x = obj.f[i].v[j].x * scale
			obj.f[i].v[j].y = obj.f[i].v[j].y * scale
			obj.f[i].v[j].z = obj.f[i].v[j].z * scale
		NEXT j
	NEXT i

END FUNCTION
'
'
' #########################
' #####  DrawRect ()  #####
' #########################
'
FUNCTION  DrawRect (hDC, x1, y1, x2, y2)

	MoveToEx (hDC, x1, y1, 0)
	LineTo (hDC, x2, y1)
	LineTo (hDC, x2, y2)
	LineTo (hDC, x1, y2)
	LineTo (hDC, x1, y1)


END FUNCTION
'
'
' ###########################
' #####  FileExists ()  #####
' ###########################
'
FUNCTION  FileExists (fileName$)

' try to find file using GetFileAttributes
	ret = GetFileAttributesA (&fileName$)

' if file was found
	IF ret <> -1 THEN

' make sure that 'file' isn't actually a directory
		IF (ret & $$FILE_ATTRIBUTE_DIRECTORY) <> $$FILE_ATTRIBUTE_DIRECTORY THEN RETURN ($$TRUE)
	END IF
	RETURN ($$FALSE)

END FUNCTION
END PROGRAM
