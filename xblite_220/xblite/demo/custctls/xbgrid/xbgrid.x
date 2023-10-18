'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' XBLite version of "BabyGrid" grid control.
' BABYGRID code (c) 2002 by David Hillard
' New xbgrid modified code (c) 2004 by David Szafranski
'
PROGRAM	"xbgrid"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"msvcrt"

TYPE XGRIDDATA
	XLONG	.gridmenu
	XLONG	.hlist1
	STRING * 2   .protect							' char protect[2]
	STRING * 305 .title 							' title[305]
	STRING * 305 .editstring 					' editstring[305]
	STRING * 305 .editstringdisplay 	' editstringdisplay[305]
	XLONG	.rows
	XLONG	.cols
	XLONG	.gridwidth
	XLONG	.gridheight
	XLONG	.homerow
	XLONG	.homecol
	XLONG	.rowheight
	XLONG	.leftvisiblecol
	XLONG	.rightvisiblecol
	XLONG	.topvisiblerow
	XLONG	.bottomvisiblerow
	XLONG	.headerrowheight
	XLONG	.cursorrow
	XLONG	.cursorcol
	XLONG	.ownerdrawitem
	XLONG	.visiblecolumns
	XLONG	.titleheight
	XLONG	.fontascentheight
	XLONG	.cursorcolor
	XLONG	.protectcolor
	XLONG	.unprotectcolor
	XLONG	.textcolor
	XLONG	.highlightcolor
	XLONG	.gridlinecolor
	XLONG	.highlighttextcolor
	XLONG	.DRAWHIGHLIGHT
	XLONG	.ADVANCEROW
	XLONG	.CURRENTCELLPROTECTED
	XLONG	.GRIDHASFOCUS
	XLONG	.AUTOROW
	RECT  .activecellrect
	XLONG	.hfont
	XLONG	.hcolumnheadingfont
	XLONG	.htitlefont
	XLONG	.ROWSNUMBERED
	XLONG	.COLUMNSNUMBERED
	XLONG	.EDITABLE
	XLONG	.EDITING
	XLONG	.EXTENDLASTCOLUMN
	XLONG	.HSCROLL
	XLONG	.VSCROLL
	XLONG	.SHOWINTEGRALROWS
	XLONG	.SIZING
	XLONG	.ELLIPSIS
	XLONG	.COLAUTOWIDTH
	XLONG	.COLUMNSIZING
	XLONG	.ALLOWCOLUMNRESIZING
	XLONG	.columntoresize
	XLONG	.columntoresizeinitsize
	XLONG	.columntoresizeinitx
	XLONG	.cursortype
	XLONG	.columnwidths[256]
	XLONG	.REMEMBERINTEGRALROWS
	XLONG	.wannabeheight
	XLONG	.wannabewidth
	XLONG	.getBorder
	XLONG	.SHOWCURSOR
END TYPE

EXPORT

TYPE BGCELL
	XLONG	.row
	XLONG	.col
END TYPE

DECLARE FUNCTION  Xbgrid ()
END EXPORT

DECLARE FUNCTION  XbGridProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  HomeColumnNthVisible (XGRIDDATA xgd)
DECLARE FUNCTION  RefreshGrid (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  GetNextColWithWidth (XGRIDDATA xgd, startcol, direction)
DECLARE FUNCTION  GetRowOfMouse (XGRIDDATA xgd, y)
DECLARE FUNCTION  GetColOfMouse (XGRIDDATA xgd, x)
DECLARE FUNCTION  OutOfRange (BGCELL cell)
DECLARE FUNCTION  DetermineDataType (data$)
DECLARE FUNCTION  CalcVisibleCellBoundaries (XGRIDDATA xgd)
DECLARE FUNCTION  RECT GetCellRect (hWnd, XGRIDDATA xgd, r, c)
DECLARE FUNCTION  DisplayTitle (hWnd, XGRIDDATA xgd, hFont)
DECLARE FUNCTION  DisplayColumn (hWnd, XGRIDDATA xgd, c, offset, hFont, hColumnHeadingFont)
DECLARE FUNCTION  DrawCursor (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  SetCurrentCellStatus (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  GetASCII (wParam, lParam)
DECLARE FUNCTION  SetHomeRow (hWnd, XGRIDDATA xgd, row, col)
DECLARE FUNCTION  SetHomeCol (hWnd, XGRIDDATA xgd, row, col)
DECLARE FUNCTION  ShowVscroll (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  ShowHscroll (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyRowChanged (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyColChanged (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyEndEdit (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyDelete (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyEditBegin (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyEditEnd (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF1 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF2 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF3 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF4 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF5 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF6 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF7 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF8 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF9 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF10 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF11 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyF12 (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  NotifyCellClicked (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  GetVisibleColumns (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  GetNthVisibleColumn (hWnd, XGRIDDATA xgd, n)
DECLARE FUNCTION  CloseEdit (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  DisplayEditString (hWnd, XGRIDDATA xgd, @string$)
DECLARE FUNCTION  SizeGrid (hWnd, XGRIDDATA xgd)
DECLARE FUNCTION  FindLongestLine (hdc, @text$, SIZEAPI size)
DECLARE FUNCTION  BinarySearchListBox (hWndLB, @searchtext$)
DECLARE FUNCTION  CalcIntegralRows (XGRIDDATA xgd, width, @height)
DECLARE FUNCTION  GetBorderSize (hWnd)

EXPORT
DECLARE FUNCTION  InitCell (hGrid, row, col, text$)
DECLARE FUNCTION  SetCell (BGCELL cell, row, col)
DECLARE FUNCTION  PutCell (hGrid, row, col, text$)
DECLARE FUNCTION  SetDefaultFonts (hWnd)
DECLARE FUNCTION  SetDefaultColWidths (hWnd)
DECLARE FUNCTION  SetDefaultCursorColor (hWnd)
DECLARE FUNCTION  SetDefaultHeaderRowHeight (hWnd)

$$XBGRIDCLASSNAME = "xbgridctrl"

' control notification messages
$$BGN_LBUTTONDOWN = 0x0001
$$BGN_MOUSEMOVE   = 0x0002
$$BGN_OUTOFRANGE  = 0x0003
$$BGN_OWNERDRAW   = 0x0004
$$BGN_SELCHANGE   = 0x0005
$$BGN_ROWCHANGED  = 0x0006
$$BGN_COLCHANGED  = 0x0007
$$BGN_EDITBEGIN   = 0x0008
$$BGN_DELETECELL  = 0x0009
$$BGN_EDITEND     = 0x000A
$$BGN_F1          = 0x000B
$$BGN_F2          = 0x000C
$$BGN_F3          = 0x000D
$$BGN_F4          = 0x000E
$$BGN_F5          = 0x000F
$$BGN_F6          = 0x0010
$$BGN_F7          = 0x0011
$$BGN_F8          = 0x0012
$$BGN_F9          = 0x0013
$$BGN_F10         = 0x0014
$$BGN_F11         = 0x0015
$$BGN_F12         = 0x0016
$$BGN_GOTFOCUS    = 0x0017
$$BGN_LOSTFOCUS   = 0x0018
$$BGN_CELLCLICKED = 0x0019

' control messages
$$BGM_PROTECTCELL = 1025
$$BGM_SETPROTECT  = 1026
$$BGM_SETCELLDATA = 1027
$$BGM_GETCELLDATA = 1028
$$BGM_CLEARGRID   = 1029
$$BGM_SETGRIDDIM  = 1030
$$BGM_DELETECELL  = 1031
$$BGM_SETCURSORPOS = 1032
$$BGM_AUTOROW     = 1033
$$BGM_GETOWNERDRAWITEM = 1034
$$BGM_SETCOLWIDTH = 1035
$$BGM_SETHEADERROWHEIGHT = 1036
$$BGM_GETTYPE     = 1037
$$BGM_GETPROTECTION = 1038
$$BGM_DRAWCURSOR  = 1039
$$BGM_SETROWHEIGHT = 1040
$$BGM_SETCURSORCOLOR = 1041
$$BGM_SETPROTECTCOLOR = 1042
$$BGM_SETUNPROTECTCOLOR = 1043
$$BGM_SETROWSNUMBERED = 1044
$$BGM_SETCOLSNUMBERED = 1045
$$BGM_SHOWHILIGHT = 1046
$$BGM_GETROWS = 1047
$$BGM_GETCOLS = 1048
$$BGM_NOTIFYROWCHANGED = 1049
$$BGM_NOTIFYCOLCHANGED = 1050
$$BGM_GETROW = 1051
$$BGM_GETCOL = 1052
$$BGM_PAINTGRID = 1053
$$BGM_GETCOLWIDTH = 1054
$$BGM_GETROWHEIGHT = 1055
$$BGM_GETHEADERROWHEIGHT = 1056
$$BGM_SETTITLEHEIGHT = 1057

$$BGM_SETHILIGHTCOLOR = 1058
$$BGM_SETHILIGHTTEXTCOLOR = 1059
$$BGM_SETEDITABLE = 1060
$$BGM_SETGRIDLINECOLOR = 1061
$$BGM_EXTENDLASTCOLUMN = 1062
$$BGM_SHOWINTEGRALROWS = 1063
$$BGM_SETELLIPSIS = 1064
$$BGM_SETCOLAUTOWIDTH = 1065
$$BGM_SETALLOWCOLRESIZE = 1066
$$BGM_SETTITLEFONT = 1067
$$BGM_SETHEADINGFONT = 1068
$$BGM_SHOWCURSOR = 1069

$$BGM_SETLISTBOXREDRAW = 1070     ' wParam = 0 - No Redraw, 1 - Redraw
$$BGM_INITCELLDATA = 1071         ' only use on empty grid

END EXPORT

$$MAX_ROWS = 32000
$$MAX_COLS = 256

'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' PURPOSE	: Initialize xbgrid control class.
'
FUNCTION  Xbgrid ()

	WNDCLASS wc
	STATIC init

' do this once
	IF init THEN RETURN
	init = $$TRUE

' Register control window class.
	className$       = "xbgridctrl"
	wc.style         = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_GLOBALCLASS
  wc.lpfnWndProc   = &XbGridProc()
  wc.cbClsExtra    = 0
  wc.cbWndExtra    = 0
  wc.hInstance     = GetModuleHandleA (0)
  wc.hIcon         = NULL										' LoadIconA (hInst, &icon$)
  wc.hCursor       = NULL										' LoadCursorA (0, $$IDC_ARROW)
  wc.hbrBackground = $$COLOR_BTNFACE + 1		' GetStockObject ($$GRAY_BRUSH)
  wc.lpszMenuName  = NULL
  wc.lpszClassName = &className$

  IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  XbGridProc ()  #####
' ###########################
'
FUNCTION  XbGridProc (hWnd, msg, wParam, lParam)

	XGRIDDATA xgd, txgd
	POINT pt
	LOGFONT lf
	PAINTSTRUCT ps
	RECT rc, rect, gridrect, grect, prect
	RECT crect
	SIZEAPI size
	BGCELL BGcell
	TEXTMETRIC tm
	CREATESTRUCT cs
	WINDOWPLACEMENT wp
	WINDOWPOS winpos
	SHARED borderSize

' store pointer to grid data in GWL_USERDATA
' allocate memory for new grid data
  pXgridData = GetWindowLongA (hWnd, $$GWL_USERDATA)
  IFZ pXgridData THEN
		pXgridData = HeapAlloc (GetProcessHeap(), $$HEAP_ZERO_MEMORY, SIZE(xgd))
		IF pXgridData THEN
' set pointer to link data in user data
			SetWindowLongA (hWnd, $$GWL_USERDATA, pXgridData)
		ELSE
			RETURN
		END IF
  END IF

' fill xgd with current grid data
	RtlMoveMemory (&xgd, pXgridData, SIZE(xgd))

' update the grid width and height variable
	GetClientRect (hWnd, &rect)
	xgd.gridwidth = rect.right - rect.left
	xgd.gridheight = rect.bottom - rect.top

	SELECT CASE msg
	
	  CASE $$BGM_SETLISTBOXREDRAW :
	    SendMessageA (xgd.hlist1, $$WM_SETREDRAW, wParam, 0)
	    RETURN

		CASE $$WM_DESTROY:
			DeleteObject (xgd.hfont)
			DeleteObject (xgd.hcolumnheadingfont)
			DeleteObject (xgd.htitlefont)
			SendMessageA (xgd.hlist1, $$LB_RESETCONTENT, 0, 0)
			DestroyWindow (xgd.hlist1)
			HeapFree (GetProcessHeap (), 0, pXgridData)
			RETURN

		CASE $$WM_CREATE:
			GOSUB InitializeData
			RETURN

		CASE $$WM_PAINT:
			hdc = BeginPaint (hWnd, &ps)
			GetClientRect (hWnd, &rc)
			CalcVisibleCellBoundaries (@xgd)

			IF (GetFocus () == hWnd) THEN xgd.GRIDHASFOCUS = $$TRUE

 ' display title
			DisplayTitle (hWnd, @xgd, xgd.htitlefont)

' display column 0
			DisplayColumn (hWnd, @xgd, 0, 0, xgd.hfont, xgd.hcolumnheadingfont)

' display remaining columns
			offset = xgd.columnwidths[0]
			j = xgd.leftvisiblecol
			k = xgd.rightvisiblecol
			FOR c = j TO k
				DisplayColumn (hWnd, @xgd, c, offset, xgd.hfont, xgd.hcolumnheadingfont)
				offset = offset + xgd.columnwidths[c]
			NEXT c
			EndPaint (hWnd, &ps)

			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))

			IF (GetFocus() == hWnd) THEN
'				PostMessageA (hWnd, $$BGM_DRAWCURSOR, 0, 0)
				DrawCursor (hWnd, @xgd)
			END IF
			RETURN

		CASE $$BGM_DRAWCURSOR:
			IF (xgd.SHOWCURSOR) THEN
				DrawCursor (hWnd, @xgd)
			END IF
			RETURN

		CASE $$BGM_PAINTGRID:
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$TRUE)
			UpdateWindow (hWnd)
			MessageBeep (0)
			RETURN

		CASE $$WM_SETTEXT:
			text$ = CSTRING$ (lParam)
			IF LEN (text$) > 300 THEN
 				xgd.title = "Title too long (300 chars max)"
			ELSE
				xgd.title = text$
 			END IF

			hdc = GetDC (hWnd)

' get linecount of title
			length = LEN (xgd.title)
			IF length > 0 THEN
				linecount = 1
				upp = length - 1
				FOR j = 0 TO upp
					IF xgd.title{j} == '\n' THEN INC linecount
				NEXT j
				holdfont = SelectObject (hdc, xgd.htitlefont)
 				GetTextExtentPoint32A (hdc, &xgd.title, length, &size)
				SelectObject (hdc, holdfont)
				xgd.titleheight = (size.cy*1.2) * linecount
			ELSE
' no title
				xgd.titleheight = 0
			END IF
			ReleaseDC (hWnd, hdc)
			SizeGrid (hWnd, @xgd)
			RefreshGrid (hWnd, @xgd)
			InvalidateRect (GetParent (hWnd), NULL, $$TRUE)

		CASE $$BGM_GETROWS:
			RETURN xgd.rows

		CASE $$BGM_GETCOLS:
			RETURN xgd.cols

		CASE $$BGM_GETCOLWIDTH:
			RETURN xgd.columnwidths[wParam]

		CASE $$BGM_GETROWHEIGHT:
			RETURN xgd.rowheight

		CASE $$BGM_GETHEADERROWHEIGHT:
			RETURN xgd.headerrowheight

		CASE $$BGM_GETOWNERDRAWITEM:
			RETURN xgd.ownerdrawitem

		CASE $$BGM_SETCURSORPOS:
			DrawCursor (hWnd, @xgd)
 			IF (((wParam <= xgd.rows) && (wParam > 0)) && ((lParam <= xgd.cols) && (lParam > 0))) THEN
				xgd.cursorrow = wParam
				xgd.cursorcol = lParam
			ELSE
				DrawCursor (hWnd, @xgd)
				EXIT SELECT
			END IF
			SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
			SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
			DrawCursor (hWnd, @xgd)
			RefreshGrid (hWnd, @xgd)

		CASE $$BGM_SHOWHILIGHT:
			xgd.DRAWHIGHLIGHT = wParam
			RefreshGrid (hWnd, @xgd)

		CASE $$BGM_EXTENDLASTCOLUMN:
			xgd.EXTENDLASTCOLUMN = wParam
			RefreshGrid (hWnd, @xgd)

		CASE $$BGM_SHOWINTEGRALROWS:
			xgd.SHOWINTEGRALROWS = wParam
			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))
			SizeGrid (hWnd, @xgd)
			RefreshGrid (hWnd, @xgd)
			InvalidateRect (GetParent (hWnd), NULL, $$TRUE)

		CASE $$BGM_SETCOLAUTOWIDTH:
			xgd.COLAUTOWIDTH = wParam

		CASE $$BGM_SETALLOWCOLRESIZE:
			xgd.ALLOWCOLUMNRESIZING = wParam

		CASE $$BGM_PROTECTCELL:
			RtlMoveMemory (&BGcell, wParam, SIZE(BGcell))
			IF (OutOfRange (@BGcell)) THEN
				wParam = MAKELONG (GetMenu (hWnd), $$BGN_OUTOFRANGE)
				lParam = 0
				SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)
				RETURN (-1)
			END IF
			buffer$ = NULL$ (1024)
			wsprintfA (&buffer, &"%05d-%03d", BGcell.row, BGcell.col)
			buffer$ = CSIZE$ (buffer$)
' see if that cell is already loaded
			findResult = BinarySearchListBox (xgd.hlist1, @buffer$)
			IF (findResult != $$LB_ERR) THEN
' it was found, get the text, modify text delete it from list, add modified to list
				buffer$ = NULL$ (1024)
				SendMessageA (xgd.hlist1, $$LB_GETTEXT, findResult, &buffer$)
				IF lParam THEN
					buffer${10} = 'P'
				ELSE
					buffer${10} = 'U'
				END IF
				buffer$ = CSIZE$ (buffer$)
				SendMessageA (xgd.hlist1, $$LB_DELETESTRING, findResult, 0)
				SendMessageA (xgd.hlist1, $$LB_ADDSTRING, findResult, &buffer$)
			ELSE
' protecting or unprotecting a cell that isn't in the list
' add it as blank
				buffer$ = buffer$ + "|"			' strcat(buffer,"|")
				IF lParam THEN
					buffer$ = buffer$ + "PA"	' strcat(buffer,"PA")
				ELSE
					buffer$ = buffer$ + "UA"	' strcat(buffer,"UA")
				END IF
				buffer$ = buffer$ + "|"			' strcat(buffer,"|")
				SendMessageA (xgd.hlist1, $$LB_ADDSTRING, findResult, &buffer$)
			END IF

		CASE $$BGM_NOTIFYROWCHANGED:
			NotifyRowChanged (hWnd, @xgd)

		CASE $$BGM_NOTIFYCOLCHANGED:
			NotifyColChanged (hWnd, @xgd)

		CASE $$BGM_SETPROTECT:
			IF (wParam) THEN
				xgd.protect = "P"
			ELSE
				xgd.protect = "U"
			END IF

		CASE $$BGM_AUTOROW:
			IF (wParam) THEN
				xgd.AUTOROW = $$TRUE
			ELSE
				xgd.AUTOROW = $$FALSE
			END IF

		CASE $$BGM_SETEDITABLE:
			IF (wParam) THEN
				xgd.EDITABLE = $$TRUE
			ELSE
				xgd.EDITABLE = $$FALSE
			END IF

' this is experimental! only to be used on an empty grid and
' an empty listbox. It does not sort the listbox, nor check
' to see if data for a cell alread exists. If duplicate
' cell entries are added here, it will mess up!!!
		CASE $$BGM_INITCELLDATA:

			RtlMoveMemory (&BGcell, wParam, SIZE (BGcell))
			IF (OutOfRange (@BGcell)) THEN
				wParam = MAKELONG (GetMenu (hWnd), $$BGN_OUTOFRANGE)
				lParam = 0
				SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)
				RETURN  (-1)
			END IF

			buffer$ = NULL$ (24)
			row = BGcell.row
			col = BGcell.col
			wsprintfA (&buffer$, &"%05d-%03d", row, col)
			buffer$ = CSIZE$ (buffer$)

' determine data type (text, numeric, or boolean)
			data$ = CSTRING$ (lParam)
			iDataType = DetermineDataType (data$)

			SELECT CASE iDataType
				CASE 1: type$ = "A"		' 1 = Text or Alpha
				CASE 2: type$ = "N"		' 2 = Numeric  (has .)
				CASE 3: type$ = "T"		' 3 = Boolean TRUE
				CASE 4: type$ = "F"		' 4 = Boolean FALSE
				CASE 5: type$ = "G"		' 5 = Graphic - user drawn (cell text begins with ~)
			END SELECT

' create data string
     	buffer$ = buffer$ + "|" + xgd.protect + type$ + "|" + data$

			findResult = SendMessageA (xgd.hlist1, $$LB_INSERTSTRING, -1, &buffer$)
      RETURN
'			rect = GetCellRect (hWnd, @xgd, BGcell.row, BGcell.col)
'			InvalidateRect (hWnd, &rect, $$FALSE)


		CASE $$BGM_SETCELLDATA:
			RtlMoveMemory (&BGcell, wParam, SIZE (BGcell))
			IF (OutOfRange (@BGcell)) THEN
				wParam = MAKELONG (GetMenu (hWnd), $$BGN_OUTOFRANGE)
				lParam = 0
				SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)
				RETURN  (-1)
			END IF

			buffer$ = NULL$ (24)
			row = BGcell.row
			col = BGcell.col
			wsprintfA (&buffer$, &"%05d-%03d", row, col)
			buffer$ = CSIZE$ (buffer$)

' see if that cell is already loaded
			findResult = BinarySearchListBox (xgd.hlist1, @buffer$)

			IF (findResult != $$LB_ERR) THEN
' it was found, delete it
				SendMessageA (xgd.hlist1, $$LB_DELETESTRING, findResult, 0)
			END IF

' determine data type (text, numeric, or boolean)
			data$ = CSTRING$ (lParam)
			iDataType = DetermineDataType (data$)

			SELECT CASE iDataType
				CASE 1: type$ = "A"		' 1 = Text or Alpha
				CASE 2: type$ = "N"		' 2 = Numeric  (has .)
				CASE 3: type$ = "T"		' 3 = Boolean TRUE
				CASE 4: type$ = "F"		' 4 = Boolean FALSE
				CASE 5: type$ = "G"		' 5 = Graphic - user drawn (cell text begins with ~)
			END SELECT

' create data string
     	buffer$ = buffer$ + "|" + xgd.protect + type$ + "|" + data$
     	
' add to listbox
			findResult = SendMessageA (xgd.hlist1, $$LB_ADDSTRING, 0, &buffer$)

'			IF (findResult == $$LB_ERR) THEN MessageBeep (0)

			rect = GetCellRect (hWnd, @xgd, BGcell.row, BGcell.col)
			InvalidateRect (hWnd, &rect, $$FALSE)

' get the last line and adjust grid dimensions
			IF (xgd.AUTOROW) THEN
				j = SendMessageA (xgd.hlist1, $$LB_GETCOUNT, 0, 0)
				IF (j > 0) THEN
					buffer$ = NULL$ (1024)
					SendMessageA (xgd.hlist1, $$LB_GETTEXT, j-1, &buffer$)
					buffer${5} = 0x00
					buffer$ = CSIZE$ (buffer$)
					j = XLONG (buffer$)
					IF (j > xgd.rows) THEN xgd.rows = j
				ELSE
' no items in the list
					xgd.rows = j
				END IF
			END IF

' adjust the column width if COLAUTOWIDTH==TRUE
			IF ((xgd.COLAUTOWIDTH) || (BGcell.row == 0)) THEN
				hdc = GetDC (hWnd)
				IF (BGcell.row == 0) THEN
					holdfont = SelectObject (hdc, xgd.hcolumnheadingfont)
				ELSE
					holdfont = SelectObject (hdc, xgd.hfont)
				END IF
' if there are \n codes in the string, find the longest line
				longestline = FindLongestLine (hdc, data$, @size)

				SelectObject (hdc, holdfont)
				ReleaseDC (hWnd, hdc)

				required_width = longestline + 9 				'+ 5
				required_height = size.cy

' count lines
 				count = 1
				tbuffer$ = data$
				upp = LEN (tbuffer$) - 1
				FOR j = 0 TO upp
					IF (tbuffer${j} == '\n') THEN INC count
				NEXT j
				IF ((!xgd.ELLIPSIS) || (BGcell.row == 0)) THEN
					required_height = required_height * count
				END IF

				required_height = required_height + 5
				current_width = xgd.columnwidths[BGcell.col]

				IF (BGcell.row == 0) THEN
					current_height = xgd.headerrowheight
					IF (required_height > current_height) THEN
						xgd.headerrowheight = required_height
					END IF
				ELSE
					current_height = xgd.rowheight
					IF (required_height > current_height) THEN
						xgd.rowheight = required_height
					END IF
				END IF

				IF (required_width > current_width) THEN
					xgd.columnwidths[BGcell.col] = required_width
				END IF
			END IF

		CASE $$BGM_GETCELLDATA:
			RtlMoveMemory (&BGcell, wParam, SIZE (BGcell))
			IF (OutOfRange (@BGcell)) THEN
				wParam = MAKELONG (GetMenu (hWnd), $$BGN_OUTOFRANGE)
				lParam = 0
				SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)
				RETURN (-1)
			END IF

			buffer$ = NULL$ (1024)
			row = BGcell.row
			col = BGcell.col
			wsprintfA (&buffer$, &"%05d-%03d", row, col)
			fbuffer$ = CSIZE$ (buffer$)

'see if that cell is already loaded
			findResult = BinarySearchListBox (xgd.hlist1, @fbuffer$)

			IF (findResult != $$LB_ERR) THEN
' it was found, get it
				tbuffer$ = NULL$ (1024)
				len = SendMessageA (xgd.hlist1, $$LB_GETTEXT, findResult, &tbuffer$)
				k = len - 1
				c = 0
				FOR j = 13 TO k
					buffer${c} = tbuffer${j}
					INC c
				NEXT j
				buffer${c} = 0x00
				buffer$ = CSIZE$ (buffer$)
			ELSE
				buffer$ = ""
			END IF
			RtlMoveMemory (lParam, &buffer$, LEN (buffer$))
			RETURN

 		CASE $$BGM_CLEARGRID:
			SendMessageA (xgd.hlist1, $$LB_RESETCONTENT, 0, 0)
			xgd.rows = 0
			xgd.cursorrow = 1
			xgd.homerow = 1
			xgd.homecol = 1
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$TRUE)

		CASE $$BGM_DELETECELL:
			RtlMoveMemory (&BGcell, wParam, SIZE (BGcell))
			IF (OutOfRange (@BGcell)) THEN
				wParam = MAKELONG (GetMenu (hWnd), $$BGN_OUTOFRANGE)
				lParam = 0
				SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)
				RETURN (-1)
			END IF

			buffer$ = NULL$ (1024)
			wsprintfA (&buffer$, &"%05d-%03d", BGcell.row, BGcell.col)
			buffer$ = CSIZE$ (buffer$)

' see if that cell is already loaded
			findResult = BinarySearchListBox (xgd.hlist1, @buffer$)
			IF (findResult != $$LB_ERR) THEN
' it was found, delete it
 				SendMessageA (xgd.hlist1, $$LB_DELETESTRING, findResult, 0)
				NotifyEndEdit (hWnd, @xgd)
			END IF

		CASE $$BGM_SETGRIDDIM:
			IF ((wParam >= 0) && (wParam <= $$MAX_ROWS)) THEN
				xgd.rows = wParam
			ELSE
				IF (wParam < 0) THEN
					xgd.rows = 0
				ELSE
					xgd.rows = $$MAX_ROWS
				END IF
			END IF

			IF ((lParam > 0) && (lParam <= $$MAX_COLS)) THEN
				xgd.cols = lParam
			ELSE
				IF (lParam <= 0) THEN
					xgd.cols = 1
				ELSE
					xgd.cols = $$MAX_COLS
				END IF
			END IF
			SendMessageA (xgd.hlist1, $$LB_RESETCONTENT, 0, 0)
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$TRUE)
			GetVisibleColumns (hWnd, @xgd)

		CASE $$BGM_SETCOLWIDTH:
			IF ((wParam <= $$MAX_COLS) && (wParam >= 0) && (lParam >= 0)) THEN
				xgd.columnwidths[wParam] = lParam
				GetClientRect (hWnd, &rect)
				InvalidateRect (hWnd, &rect, $$FALSE)
				GetVisibleColumns (hWnd, @xgd)
			END IF

		CASE $$BGM_SETHEADERROWHEIGHT:
			IF (wParam >= 0) THEN
				xgd.headerrowheight = wParam
				RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))
				SizeGrid (hWnd, @xgd)
				GetClientRect (hWnd, &rect)
				InvalidateRect (hWnd, &rect, $$FALSE)
				InvalidateRect (GetParent (hWnd), NULL, $$TRUE)
			END IF

		CASE $$BGM_GETROW:
			RETURN xgd.cursorrow

		CASE $$BGM_GETCOL:
			RETURN xgd.cursorcol

		CASE $$BGM_GETTYPE:
			RtlMoveMemory (&BGcell, wParam, SIZE (BGcell))
			IF (OutOfRange (@BGcell)) THEN
				wParam = MAKELONG (GetMenu (hWnd), $$BGN_OUTOFRANGE)
				lParam = 0
				SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)
				RETURN (-1)
			END IF

			buffer$ = NULL$ (1024)
			row = BGcell.row
			col = BGcell.col
			wsprintfA (&buffer$, &"%05d-%03d", row, col)
			buffer$ = CSIZE$ (buffer$)

' see if that cell is already loaded
			findResult = BinarySearchListBox (xgd.hlist1, @buffer$)
			IF (findResult != $$LB_ERR) THEN
' it was found, get it
				buffer$ = NULL$ (1024)
				SendMessageA (xgd.hlist1, $$LB_GETTEXT, findResult, &buffer$)
				SELECT CASE (buffer${11})
					CASE 'A'	: RETURN (1)
					CASE 'N'	: RETURN (2)
					CASE 'T'	: RETURN (3)
					CASE 'F'	: RETURN (4)
					CASE 'G'	: RETURN (5)
					CASE ELSE	: RETURN (1)
				END SELECT
			END IF
			RETURN (-1)

		CASE $$BGM_GETPROTECTION:
			RtlMoveMemory (&BGcell, wParam, SIZE (BGcell))
			IF (OutOfRange (@BGcell)) THEN
				wParam = MAKELONG (GetMenu (hWnd), $$BGN_OUTOFRANGE)
				lParam = 0
				SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)
				RETURN (-1)
			END IF

			buffer$ = NULL$ (1024)
			row = BGcell.row
			col = BGcell.col
			wsprintfA (&buffer$, &"%05d-%03d", row, col)
			buffer$ = CSIZE$ (buffer$)

' see if that cell is already loaded
			findResult = BinarySearchListBox (xgd.hlist1, @buffer$)
			IF (findResult != $$LB_ERR) THEN
' it was found, get it
				buffer$ = NULL$ (1024)
				SendMessageA (xgd.hlist1, $$LB_GETTEXT, findResult, &buffer$)
				SELECT CASE (buffer${10})
				   CASE 'U':		RETURN (0)
				   CASE 'P':		RETURN (1)
				   CASE ELSE : 	RETURN (0)
				END SELECT
			END IF
			RETURN (-1)

		CASE $$BGM_SETROWHEIGHT:
			IF (wParam < 1) THEN wParam = 1
			xgd.rowheight = wParam
			SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
			SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))
			SizeGrid (hWnd, @xgd)
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)
			InvalidateRect (GetParent (hWnd), NULL, $$TRUE)

		CASE $$BGM_SETTITLEHEIGHT:
			IF (wParam < 0) THEN wParam = 0
			xgd.titleheight = wParam
			SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
			SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$BGM_SETGRIDLINECOLOR:
			DrawCursor (hWnd, @xgd)
			xgd.gridlinecolor = wParam
			DrawCursor (hWnd, @xgd)
			RefreshGrid (hWnd, @xgd)

		CASE $$BGM_SETCURSORCOLOR:
			DrawCursor (hWnd, @xgd)
			xgd.cursorcolor = wParam
			DrawCursor (hWnd, @xgd)
			RefreshGrid (hWnd, @xgd)

		CASE $$BGM_SETHILIGHTTEXTCOLOR:
			xgd.highlighttextcolor = wParam
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$BGM_SETHILIGHTCOLOR:
			xgd.highlightcolor = wParam
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$BGM_SETPROTECTCOLOR:
			xgd.protectcolor = wParam
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$BGM_SETUNPROTECTCOLOR:
			xgd.unprotectcolor = wParam
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$BGM_SETELLIPSIS:
			xgd.ELLIPSIS = wParam
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$WM_SETFONT:
			IF wParam <= 0 THEN RETURN
			type = GetObjectType (wParam)
			IF type != $$OBJ_FONT THEN RETURN
			IF xgd.hfont THEN DeleteObject (xgd.hfont)
			xgd.hfont = wParam
			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))
			RefreshGrid (hWnd, @xgd)
			RETURN

		CASE $$BGM_SETTITLEFONT:
			IF wParam <= 0 THEN RETURN
			type = GetObjectType (wParam)
			IF type != $$OBJ_FONT THEN RETURN
			IF xgd.htitlefont THEN DeleteObject (xgd.htitlefont)
			xgd.htitlefont = wParam
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$BGM_SETHEADINGFONT:
			IF wParam <= 0 THEN RETURN
			type = GetObjectType (wParam)
			IF type != $$OBJ_FONT THEN RETURN
			IF xgd.hcolumnheadingfont THEN DeleteObject (xgd.hcolumnheadingfont)
			xgd.hcolumnheadingfont = wParam
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$BGM_SETROWSNUMBERED:
			xgd.ROWSNUMBERED = wParam
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)

		CASE $$BGM_SETCOLSNUMBERED:
			xgd.COLUMNSNUMBERED = wParam
			SizeGrid (hWnd, @xgd)
			GetClientRect (hWnd, &rect)
			InvalidateRect (hWnd, &rect, $$FALSE)
			InvalidateRect (GetParent (hWnd), NULL, $$TRUE)

		CASE $$WM_ENABLE:
			IF (wParam == $$FALSE) THEN
				xgd.textcolor = RGB (120,120,120)
			ELSE
				xgd.textcolor = RGB (0,0,0)
			END IF

		CASE $$WM_MOUSEMOVE:
			x = LOWORD (lParam)
			y = HIWORD (lParam)
			r = GetRowOfMouse (@xgd, y)
			c = GetColOfMouse (@xgd, x)
			t = GetColOfMouse (@xgd, x+10)
			z = GetColOfMouse (@xgd, x-10)

			IF (xgd.COLUMNSIZING) THEN
				dx = x - xgd.columntoresizeinitx
				nx = xgd.columntoresizeinitsize + dx
				IF (nx <= 0) THEN nx = 0
				cr = xgd.columntoresize
				SendMessageA (hWnd, $$BGM_SETCOLWIDTH, cr, nx)
				xgd.columnwidths[cr] = nx
			END IF

			IF ((r == 0) && (c >= -1) && ((t != c) || (z != c)) && (!xgd.COLUMNSIZING)) THEN
				IF ((xgd.cursortype != 2) && (xgd.ALLOWCOLUMNRESIZING)) THEN
					xgd.cursortype = 2
				END IF
			ELSE
				IF ((xgd.cursortype != 1) && (!xgd.COLUMNSIZING)) THEN
					xgd.cursortype = 1
				END IF
			END IF

		CASE $$WM_SETCURSOR:
			IF xgd.cursortype = 2 THEN
				SetCursor (LoadCursorA (NULL, $$IDC_SIZEWE))
			ELSE
				SetCursor (LoadCursorA (NULL, $$IDC_ARROW))
			END IF
			RETURN ($$TRUE)

		CASE $$WM_LBUTTONUP:
			IF (xgd.COLUMNSIZING) THEN
				xgd.COLUMNSIZING = $$FALSE
				SetCursor (LoadCursorA (NULL, $$IDC_ARROW))
				xgd.cursortype = 1
				xgd.SHOWINTEGRALROWS = xgd.REMEMBERINTEGRALROWS
				SizeGrid (hWnd, @xgd)
			END IF

		CASE $$WM_LBUTTONDOWN:
' check for column sizing
			IF (xgd.cursortype == 2) THEN
' start column sizing
				IF (!xgd.COLUMNSIZING) THEN
					xgd.REMEMBERINTEGRALROWS = xgd.SHOWINTEGRALROWS
				END IF
				xgd.COLUMNSIZING = $$TRUE
				xgd.SHOWINTEGRALROWS = $$FALSE
				x = LOWORD (lParam)
				xgd.columntoresizeinitx = x
				t = GetColOfMouse (@xgd, x+10)
				z = GetColOfMouse (@xgd, x-10)
				c = GetColOfMouse (@xgd, x)
				IF (t != c) THEN
' resizing column c
					xgd.columntoresize = c
				END IF
				IF (z != c) THEN
' resizing hidden column to the left of cursor
					IF (c == -1) THEN
'						c = SendMessageA (hWnd, $$BGM_GETCOLS, 0, 0)
						c = xgd.cols
					ELSE
						c = c - 1
 					END IF
					xgd.columntoresize = c
				END IF
				xgd.columntoresizeinitsize = xgd.columnwidths[c]
			END IF

			IF (xgd.EDITING) THEN
				CloseEdit (hWnd, @xgd)
			ELSE
				IF (GetFocus () != hWnd) THEN SetFocus (hWnd)
			END IF

'			NRC = $$FALSE
'			NCC = $$FALSE

			IF (GetFocus () == hWnd) THEN
				x = LOWORD (lParam)
				y = HIWORD (lParam)
				r = GetRowOfMouse (@xgd, y)
				c = GetColOfMouse (@xgd, x)

				DrawCursor (hWnd, @xgd)

				IF ((r > 0) && (c > 0)) THEN
					NRC = $$FALSE
					NCC = $$FALSE
					IF (r != xgd.cursorrow) THEN
						xgd.cursorrow = r
						NRC = $$TRUE
					ELSE
						xgd.cursorrow = r
					END IF
					IF (c != xgd.cursorcol) THEN
						xgd.cursorcol = c
						NCC = $$TRUE
					ELSE
						xgd.cursorcol = c
					END IF
					NotifyCellClicked (hWnd, @xgd)
					IF (NRC) THEN NotifyRowChanged (hWnd, @xgd)
					IF (NCC) THEN NotifyColChanged (hWnd, @xgd)
				END IF

'				IF (NRC) THEN NotifyRowChanged (hWnd, @xgd)
'				IF (NCC) THEN NotifyColChanged (hWnd, @xgd)

				DrawCursor (hWnd, @xgd)
				SetCurrentCellStatus (hWnd, @xgd)
				SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
				SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
				RefreshGrid (hWnd, @xgd)
			ELSE
				SetFocus (hWnd)
			END IF

		CASE $$WM_ERASEBKGND:
			RETURN ($$TRUE)

		CASE $$WM_GETDLGCODE:
			returnValue = $$DLGC_WANTARROWS | $$DLGC_WANTCHARS | $$DLGC_DEFPUSHBUTTON
			IF (wParam == 13) THEN
' same as arrow down
				IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
				DrawCursor (hWnd, @xgd)
				INC xgd.cursorrow
				IF (xgd.cursorrow > xgd.rows) THEN
					xgd.cursorrow = xgd.rows
				ELSE
					NotifyRowChanged (hWnd, @xgd)
				END IF
				DrawCursor (hWnd, @xgd)
				SetCurrentCellStatus (hWnd, @xgd)
				SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
				RefreshGrid (hWnd, @xgd)
				xgd.EDITING = $$FALSE
				GOTO return
			END IF

			IF (wParam == $$VK_ESCAPE) THEN
				IF (xgd.EDITING) THEN
					xgd.EDITING = $$FALSE
					xgd.editstring = ""
					HideCaret (hWnd)
					RefreshGrid (hWnd, @xgd)
					NotifyEditEnd (hWnd, @xgd)
				ELSE
					returnValue = 0
				END IF
			END IF
return:
			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))
			RETURN returnValue

		CASE $$WM_KEYDOWN:
			SELECT CASE wParam
				CASE $$VK_ESCAPE:
					IF (xgd.EDITING) THEN
						xgd.EDITING = $$FALSE
						xgd.editstring = ""
						HideCaret (hWnd)
						RefreshGrid (hWnd, @xgd)
						NotifyEditEnd (hWnd, @xgd)
						GOTO break
					END IF

				CASE $$VK_F1: NotifyF1 (hWnd, @xgd) : GOTO break
				CASE $$VK_F2: NotifyF2 (hWnd, @xgd) : GOTO break
				CASE $$VK_F3: NotifyF3 (hWnd, @xgd) : GOTO break
				CASE $$VK_F4: NotifyF4 (hWnd, @xgd) : GOTO break
				CASE $$VK_F5: NotifyF5 (hWnd, @xgd) : GOTO break
				CASE $$VK_F6: NotifyF6 (hWnd, @xgd) : GOTO break
				CASE $$VK_F7: NotifyF7 (hWnd, @xgd) : GOTO break
				CASE $$VK_F8: NotifyF8 (hWnd, @xgd) : GOTO break
				CASE $$VK_F9: NotifyF9 (hWnd, @xgd) : GOTO break
				CASE $$VK_F10: NotifyF10 (hWnd, @xgd) : GOTO break
				CASE $$VK_F11: NotifyF11 (hWnd, @xgd) : GOTO break
				CASE $$VK_F12: NotifyF12 (hWnd, @xgd) : GOTO break
				CASE $$VK_DELETE: NotifyDelete (hWnd, @xgd) : GOTO break
				CASE $$VK_TAB: SetFocus (GetParent (hWnd)) : GOTO break

				CASE $$VK_NEXT:				' PgDn key
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					IF (xgd.rows == 0) THEN GOTO break
					IF (xgd.cursorrow == xgd.rows) THEN GOTO break
'get rows per page
					GetClientRect (hWnd, &gridrect)
					rpp = (gridrect.bottom - (xgd.headerrowheight + xgd.titleheight))/(xgd.rowheight)
					DrawCursor (hWnd, @xgd)
					xgd.cursorrow = xgd.cursorrow + rpp
					IF (xgd.cursorrow > xgd.rows) THEN xgd.cursorrow = xgd.rows
					NotifyRowChanged (hWnd, @xgd)
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break

				CASE $$VK_END:				' End key
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					IF (xgd.rows == 0) THEN GOTO break
					IF (xgd.cursorrow == xgd.rows) THEN GOTO break
					DrawCursor (hWnd, @xgd)
					xgd.cursorrow = xgd.rows
					NotifyRowChanged (hWnd, @xgd)
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break

				CASE  $$VK_HOME:				' Home key
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					IF (xgd.rows == 0) THEN GOTO break
					IF (xgd.cursorrow == 1) THEN GOTO break
					DrawCursor (hWnd, @xgd)
					xgd.cursorrow = 1
					NotifyRowChanged (hWnd, @xgd)
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break

				CASE  $$VK_PRIOR:				' PgUp key
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					IF (xgd.rows == 0) THEN GOTO break
					IF (xgd.cursorrow == 1) THEN GOTO break
'get rows per page
					GetClientRect (hWnd, &gridrect)
					rpp = (gridrect.bottom - (xgd.headerrowheight + xgd.titleheight))/xgd.rowheight
					DrawCursor (hWnd, @xgd)
					xgd.cursorrow = xgd.cursorrow - rpp
					IF (xgd.cursorrow < 1) THEN xgd.cursorrow = 1
					NotifyRowChanged (hWnd, @xgd)
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break

				CASE $$VK_DOWN:
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					IF (xgd.rows == 0) THEN GOTO break
					IF (xgd.cursorrow == xgd.rows) THEN GOTO break
					DrawCursor (hWnd, @xgd)
					INC xgd.cursorrow
					IF (xgd.cursorrow > xgd.rows) THEN
						xgd.cursorrow = xgd.rows
					ELSE
						NotifyRowChanged (hWnd, @xgd)
					END IF
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break

				CASE $$VK_UP:
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					IF (xgd.rows == 0) THEN GOTO break
					IF (xgd.cursorrow == 1) THEN GOTO break
					DrawCursor (hWnd, @xgd)
					DEC xgd.cursorrow
					IF (xgd.cursorrow < 1) THEN
						xgd.cursorrow = 1
					ELSE
						NotifyRowChanged (hWnd, @xgd)
					END IF
					DrawCursor (hWnd,@xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break

				CASE $$VK_LEFT:
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					IF (!GetNextColWithWidth (@xgd, xgd.cursorcol, -1)) THEN GOTO break
					DrawCursor (hWnd, @xgd)
					k = GetNextColWithWidth (@xgd, xgd.cursorcol, -1)
					IF (k) THEN
						xgd.cursorcol = k
						NotifyColChanged (hWnd, @xgd)
					END IF
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break

				CASE $$VK_RIGHT:
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					DrawCursor (hWnd, @xgd)
					k = GetNextColWithWidth (@xgd, xgd.cursorcol, 1)
					IF (k) THEN
						xgd.cursorcol = k
						NotifyColChanged (hWnd, @xgd)
					END IF
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break
 			END SELECT

			SetCurrentCellStatus (hWnd, @xgd)

			IF ((xgd.CURRENTCELLPROTECTED) && (wParam == 13)) THEN
				DrawCursor (hWnd, @xgd)
				INC xgd.cursorrow
				IF (xgd.cursorrow > xgd.rows) THEN
					xgd.cursorrow = xgd.rows
				ELSE
					NotifyRowChanged (hWnd, @xgd)
				END IF
				DrawCursor (hWnd, @xgd)
				SetCurrentCellStatus (hWnd, @xgd)
				SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
				RefreshGrid (hWnd, @xgd)
				GOTO break
 			END IF

			IF (xgd.CURRENTCELLPROTECTED) THEN GOTO break

			IF (!xgd.EDITABLE) THEN
				ascii = GetASCII (wParam, lParam)
				IF (ascii == 13) THEN 		' enter pressed, treat as arrow down
' same as arrow down
					DrawCursor (hWnd, @xgd)
					INC xgd.cursorrow
					IF (xgd.cursorrow > xgd.rows) THEN
						xgd.cursorrow = xgd.rows
					ELSE
						NotifyRowChanged (hWnd, @xgd)
					END IF
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					GOTO break
				END IF
			END IF

' if it's not an arrow key, make an edit box in the active cell rectangle
			IF ((xgd.EDITABLE) && (xgd.rows > 0)) THEN
				SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
				DrawCursor (hWnd, @xgd)
				DrawCursor (hWnd, @xgd)

				ascii = GetASCII (wParam, lParam)
				wParam = ascii

				IF ((wParam >= 32) && (wParam <= 125)) THEN
					IF (!xgd.EDITING) THEN NotifyEditBegin (hWnd, @xgd)
					xgd.EDITING = $$TRUE
					tstring$ = CHR$ (wParam)
					DisplayEditString (hWnd, @xgd, @tstring$)
 					GOTO break
				END IF

				IF (wParam == 8) THEN 		' backspace
					IF (!xgd.EDITING) THEN NotifyEditBegin (hWnd, @xgd)
					xgd.EDITING = $$TRUE
					IF (LEN (xgd.editstring) == 0) THEN
						DisplayEditString (hWnd, @xgd, @"")
						GOTO break
					ELSE
						es$ = xgd.editstring
						j = LEN (es$)
						es${j-1} = 0x00
						xgd.editstring = es$
						DisplayEditString (hWnd, @xgd, "")
					END IF
					GOTO break
				END IF

				IF (wParam == 13) THEN
' same as arrow down
					IF (xgd.EDITING) THEN CloseEdit (hWnd, @xgd)
					DrawCursor (hWnd, @xgd)
					INC xgd.cursorrow
					IF (xgd.cursorrow > xgd.rows) THEN
						xgd.cursorrow = xgd.rows
					ELSE
						NotifyRowChanged (hWnd, @xgd)
					END IF
					DrawCursor (hWnd, @xgd)
					SetCurrentCellStatus (hWnd, @xgd)
					SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
					RefreshGrid (hWnd, @xgd)
					xgd.EDITING = $$FALSE
					GOTO break
				END IF
			END IF

		CASE $$WM_HSCROLL:
			code = LOWORD (wParam)
			SetFocus (hWnd)
			SELECT CASE code
				CASE $$SB_LINERIGHT, $$SB_PAGERIGHT:
					cp = GetScrollPos (hWnd, $$SB_HORZ)
					SetScrollPos (hWnd, $$SB_HORZ, cp+1, $$TRUE)
					cp = GetScrollPos (hWnd, $$SB_HORZ)
					np = GetNthVisibleColumn (hWnd, @xgd, cp)
					xgd.homecol = np
					SetScrollPos (hWnd, $$SB_HORZ, cp, $$TRUE)

				CASE $$SB_LINELEFT, $$SB_PAGELEFT:
					cp = GetScrollPos (hWnd, $$SB_HORZ)
					SetScrollPos (hWnd, $$SB_HORZ, cp-1, $$TRUE)
					cp = GetScrollPos (hWnd, $$SB_HORZ)
					np = GetNthVisibleColumn (hWnd, @xgd, cp)
					xgd.homecol = np
					SetScrollPos (hWnd, $$SB_HORZ, cp, $$TRUE)

				CASE $$SB_THUMBTRACK:
					cp = HIWORD (wParam)
					np = GetNthVisibleColumn (hWnd, @xgd, cp)
					SetScrollPos (hWnd, $$SB_HORZ, np, $$TRUE)
					xgd.homecol = np
					SetScrollPos (hWnd, $$SB_HORZ, cp, $$TRUE)
			END SELECT
			RefreshGrid (hWnd, @xgd)

		CASE $$WM_VSCROLL:
			SetFocus (hWnd)
			code = LOWORD (wParam)
			SELECT CASE code

				CASE $$SB_THUMBTRACK:
					xgd.homerow = HIWORD (wParam)
					SetScrollPos (hWnd, $$SB_VERT, HIWORD (wParam), $$TRUE)
					GetClientRect (hWnd, &gridrect)
					GetScrollRange (hWnd, $$SB_VERT, &min, &max)
					IF (HIWORD (wParam) == max) THEN
						gridrect.top = gridrect.bottom - (xgd.rowheight)
						InvalidateRect (hWnd, &gridrect, $$TRUE)
					ELSE
'						InvalidateRect (hWnd, &gridrect, $$FALSE)
					END IF

				CASE $$SB_PAGEDOWN:
' get rows per page
					GetClientRect (hWnd, &gridrect)
					rpp = (gridrect.bottom - (xgd.headerrowheight + xgd.titleheight))/xgd.rowheight
					GetScrollRange (hWnd, $$SB_VERT, &min, &max)
					sp = GetScrollPos (hWnd, $$SB_VERT)
					sp = sp + rpp
					IF (sp > max) THEN sp = max
					xgd.homerow = sp
					SetScrollPos (hWnd, $$SB_VERT, sp, $$TRUE)
					SetHomeRow (hWnd, @xgd, sp, xgd.homecol)
					IF (sp == max) THEN
						gridrect.top = gridrect.bottom - (xgd.rowheight)
						InvalidateRect (hWnd, &gridrect, $$TRUE)
					ELSE
'						InvalidateRect (hWnd, &gridrect, $$FALSE)
					END IF

				CASE $$SB_LINEDOWN:
' get rows per page
					GetClientRect (hWnd, &gridrect)
					GetScrollRange (hWnd, $$SB_VERT, &min, &max)
					sp = GetScrollPos (hWnd, $$SB_VERT)
					INC sp
					IF (sp > max) THEN sp = max
					xgd.homerow = sp
					SetScrollPos (hWnd, $$SB_VERT, sp, $$TRUE)
					SetHomeRow (hWnd, @xgd, sp, xgd.homecol)
					IF (sp==max) THEN
						gridrect.top = gridrect.bottom - (xgd.rowheight)
						InvalidateRect (hWnd, &gridrect, $$TRUE)
					ELSE
'						InvalidateRect (hWnd, &gridrect, $$FALSE)
					END IF

				CASE $$SB_PAGEUP:
' get rows per page
					GetClientRect (hWnd, &gridrect)
					rpp = (gridrect.bottom - (xgd.headerrowheight + xgd.titleheight))/xgd.rowheight
					GetScrollRange (hWnd, $$SB_VERT, &min, &max)
					sp = GetScrollPos (hWnd, $$SB_VERT)
					sp = sp - rpp
					IF (sp < 1) THEN sp = 1
					xgd.homerow = sp
					SetScrollPos (hWnd, $$SB_VERT, sp, $$TRUE)
					SetHomeRow (hWnd, @xgd, sp, xgd.homecol)
					IF (sp == max) THEN
						gridrect.top = gridrect.bottom - (xgd.rowheight)
						InvalidateRect (hWnd, &gridrect, $$TRUE)
					ELSE
'						InvalidateRect (hWnd, &gridrect, $$FALSE)
					END IF

				CASE $$SB_LINEUP:
' get rows per page
					GetClientRect (hWnd, &gridrect)
					sp = GetScrollPos (hWnd, $$SB_VERT)
					GetScrollRange (hWnd, $$SB_VERT, &min, &max)
					DEC sp
'					IF (sp < 1) THEN sp = 1
					IF (sp < 1) THEN RETURN
					xgd.homerow = sp
					SetScrollPos (hWnd, $$SB_VERT, sp, $$TRUE)
					SetHomeRow (hWnd, @xgd, sp, xgd.homecol)
					IF (sp==max) THEN
						gridrect.top = gridrect.bottom - (xgd.rowheight)
						InvalidateRect (hWnd, &gridrect, $$TRUE)
					ELSE
'						InvalidateRect (hWnd, &gridrect, $$FALSE)
					END IF
			END SELECT
			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))
			RefreshGrid (hWnd, @xgd)
			RETURN

		CASE $$WM_SETFOCUS:
			DrawCursor (hWnd, @xgd)
			xgd.GRIDHASFOCUS = $$TRUE
			DrawCursor (hWnd, @xgd)
			SetCurrentCellStatus (hWnd, @xgd)
			SetHomeRow (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
			SetHomeCol (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)

			wParam = MAKELONG(GetMenu (hWnd), $$BGN_GOTFOCUS)
			lParam = 0
			SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

			hdc = GetDC (hWnd)
			GetTextMetricsA (hdc, &tm)
			ReleaseDC (hWnd, hdc)
			xgd.fontascentheight = tm.ascent
			CreateCaret (hWnd, NULL, 2, tm.ascent)
			RefreshGrid (hWnd, @xgd)

		CASE $$WM_KILLFOCUS:
			IF (xgd.EDITING) THEN
				xgd.EDITING = $$FALSE
				xgd.editstring = ""
				HideCaret (hWnd)
				RefreshGrid (hWnd, @xgd)
				NotifyEditEnd (hWnd, @xgd)
			END IF
			DestroyCaret ()
			DrawCursor (hWnd, @xgd)
			xgd.GRIDHASFOCUS = $$FALSE
			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))
			wParam = MAKELONG (GetMenu (hWnd), $$BGN_LOSTFOCUS)
			lParam = 0
			SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)
			RefreshGrid (hWnd, @xgd)
			RETURN

		CASE $$WM_SIZE :
			IFZ xgd.getBorder THEN
				IF ((wParam==0) && (lParam==0)) THEN
					RETURN
				ELSE
					xgd.getBorder = $$TRUE
					borderSize = GetBorderSize (hWnd)
				END IF
			END IF
			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))
			RETURN

		CASE $$WM_WINDOWPOSCHANGING:
			RtlMoveMemory (&winpos, lParam, SIZE(winpos))
			width = winpos.cx
			height = winpos.cy
			xgd.wannabeheight = height
			xgd.wannabewidth = width
			RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))

			IF (xgd.SHOWINTEGRALROWS) THEN
				txgd = xgd
				CalcIntegralRows (@txgd, width, @height)
			END IF

' set new window height
			winpos.cy = height
			RtlMoveMemory (lParam, &winpos, SIZE(winpos))
			RETURN

		CASE $$WM_RBUTTONDOWN:
			SendMessageA (GetParent (hWnd), msg, wParam, lParam)

		CASE $$BGM_SHOWCURSOR:
			DrawCursor (hWnd, @xgd)
			xgd.SHOWCURSOR = wParam
			RefreshGrid (hWnd, @xgd)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

break:
' copy data back into memory
	RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))


' ***** InitializeData *****
SUB InitializeData

	xgd.gridmenu = NULL
	xgd.hlist1 = NULL
	xgd.protect = "U"
	xgd.rows = 100
	xgd.cols = 255
	xgd.homerow = 1
	xgd.homecol = 1
	xgd.rowheight = 21
	xgd.headerrowheight = 21
	xgd.ROWSNUMBERED = $$TRUE
	xgd.COLUMNSNUMBERED = $$TRUE
	xgd.EDITABLE = $$FALSE
	xgd.EDITING = $$FALSE
	xgd.AUTOROW = $$TRUE
	xgd.cursorcol = 1
	xgd.cursorrow = 1
	xgd.ADVANCEROW = $$TRUE
	xgd.DRAWHIGHLIGHT = $$TRUE
	xgd.cursorcolor = RGB(255,255,255)
	xgd.protectcolor = RGB(255,255,255)
	xgd.unprotectcolor = RGB(255,255,255)
	xgd.highlightcolor = RGB(0,0,128)
	xgd.gridlinecolor = RGB(220,220,220)
	xgd.highlighttextcolor = RGB(255,255,255)
	xgd.textcolor = RGB(0,0,0)
	xgd.titleheight = 0
	xgd.EXTENDLASTCOLUMN = $$FALSE
	xgd.SHOWINTEGRALROWS = $$FALSE
	xgd.SIZING = $$FALSE
	xgd.ELLIPSIS = $$TRUE
	xgd.COLAUTOWIDTH = $$FALSE
	xgd.COLUMNSIZING = $$FALSE
	xgd.ALLOWCOLUMNRESIZING = $$FALSE
	xgd.cursortype = 0
	xgd.hcolumnheadingfont = NULL
	xgd.htitlefont = NULL
	xgd.editstring = ""
	xgd.SHOWCURSOR = $$TRUE
'	xgd.columnwidths[0]=50
	FOR k = 0 TO $$MAX_COLS-1
		xgd.columnwidths[k] = 50
	NEXT k

	xgd.gridmenu = GetMenu (hWnd)

	RtlMoveMemory (&cs, lParam, SIZE (cs))
	hInst = cs.hInstance
'	xgd.hlist1 = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"LISTBOX", NULL, $$WS_CHILD | $$LBS_STANDARD, 50, 150, 200, 100, hWnd, NULL, hInst, NULL)
	xgd.hlist1 = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"LISTBOX", NULL, $$WS_CHILD | $$LBS_SORT, 50, 150, 200, 100, hWnd, NULL, hInst, NULL)

	xgd.hfont               = CreateFontA (16, 0, 0, 0, $$FW_THIN, $$FALSE, $$FALSE, $$FALSE, $$ANSI_CHARSET, $$OUT_DEFAULT_PRECIS, $$CLIP_DEFAULT_PRECIS, $$PROOF_QUALITY, $$VARIABLE_PITCH | $$FF_MODERN, NULL)
	xgd.hcolumnheadingfont  = CreateFontA (18, 0, 0, 0, $$FW_BOLD, $$FALSE, $$FALSE, $$FALSE, $$ANSI_CHARSET, $$OUT_DEFAULT_PRECIS, $$CLIP_DEFAULT_PRECIS, $$PROOF_QUALITY, $$VARIABLE_PITCH | $$FF_MODERN, NULL)
	xgd.htitlefont          = CreateFontA (20, 0, 0, 0, $$FW_BOLD, $$FALSE, $$FALSE, $$FALSE, $$ANSI_CHARSET, $$OUT_DEFAULT_PRECIS, $$CLIP_DEFAULT_PRECIS, $$PROOF_QUALITY, $$VARIABLE_PITCH | $$FF_MODERN, NULL)

	xgd.title = CSTRING$ (cs.lpszName)

' copy data back into memory before sending any messages
	RtlMoveMemory (pXgridData, &xgd, SIZE(xgd))

	SendMessageA (hWnd, $$WM_SETTEXT, 0, cs.lpszName)

END SUB
END FUNCTION
'
'
' #####################################
' #####  HomeColumnNthVisible ()  #####
' #####################################
'
FUNCTION  HomeColumnNthVisible (XGRIDDATA xgd)

	hc = xgd.homecol
	count = 0

	FOR j = 1 TO hc
 		IF xgd.columnwidths[j] > 0 THEN
			INC count
		END IF
	NEXT j
	RETURN count

END FUNCTION
'
'
' ############################
' #####  RefreshGrid ()  #####
' ############################
'
FUNCTION  RefreshGrid (hWnd, XGRIDDATA xgd)

	RECT rect
	GetClientRect (hWnd, &rect)
	InvalidateRect (hWnd, &rect, $$FALSE)
	IF (xgd.EDITING) THEN
		DisplayEditString (hWnd, @xgd, @"")
	END IF

END FUNCTION
'
'
' ####################################
' #####  GetNextColWithWidth ()  #####
' ####################################
'
FUNCTION  GetNextColWithWidth (XGRIDDATA xgd, startcol, direction)

' calls with direction == 1 for right, direction == -1 for left
' returns 0 if no more cols in that direction, else column number

	j = startcol
	IF (direction == 1) THEN INC j
	IF (direction != 1) THEN DEC j

	DO WHILE ((xgd.columnwidths[j] == 0) && (j <= xgd.cols) && (j > 0))

		IF (direction == 1) THEN INC j
		IF (direction != 1) THEN DEC j

	LOOP

	IF ((xgd.columnwidths[j] > 0) && (j <= xgd.cols)) THEN
		RETURN j
	ELSE
		RETURN 0
	END IF

END FUNCTION
'
'
' ##############################
' #####  GetRowOfMouse ()  #####
' ##############################
'
FUNCTION  GetRowOfMouse (XGRIDDATA xgd, y)
	IF (y <= xgd.titleheight) THEN RETURN (-1)
	IF ((y >= xgd.titleheight) && (y <= xgd.headerrowheight + xgd.titleheight)) THEN RETURN
	y = y - (xgd.headerrowheight + xgd.titleheight)
	y = y/xgd.rowheight
	ReturnValue = xgd.homerow + y
	IF (ReturnValue > xgd.rows) THEN ReturnValue = -1
	RETURN ReturnValue

END FUNCTION
'
'
' ##############################
' #####  GetColOfMouse ()  #####
' ##############################
'
FUNCTION  GetColOfMouse (XGRIDDATA xgd, x)

	IF (x <= xgd.columnwidths[0]) THEN RETURN

	x = x - xgd.columnwidths[0]
	j = xgd.homecol

	DO WHILE (x > 0)
		x = x - xgd.columnwidths[j]
		INC j
	LOOP

	DEC j

	ReturnValue = j

	IF (xgd.EXTENDLASTCOLUMN) THEN
		IF (j > xgd.cols) THEN ReturnValue = xgd.cols
 	ELSE
		IF (j > xgd.cols) THEN ReturnValue = -1
	END IF
	RETURN ReturnValue

END FUNCTION
'
'
' ###########################
' #####  OutOfRange ()  #####
' ###########################
'
FUNCTION  OutOfRange (BGCELL cell)

	IF ((cell.row > $$MAX_ROWS) || (cell.col > $$MAX_COLS)) THEN
		RETURN ($$TRUE)
	ELSE
		RETURN ($$FALSE)
	END IF

END FUNCTION
'
'
' ##################################
' #####  DetermineDataType ()  #####
' ##################################
'
FUNCTION  DetermineDataType (data$)

' return values:
'       1 = Text or Alpha
'       2 = Numeric
'       3 = Boolean TRUE
'       4 = Boolean FALSE
'       5 = Graphic - user drawn (cell text begins with ~)

	tbuffer$ = TRIM$ (data$)
	k = LEN (tbuffer$)
	tbuffer$ = UCASE$ (tbuffer$)

' is it boolean?
	IF tbuffer$ = "TRUE" THEN RETURN 3
	IF tbuffer$ = "FALSE" THEN RETURN 4

' is it graphic (~)
	IF tbuffer${0} = '~' THEN RETURN 5

	DIGIT 			= $$FALSE
	ALPHA 			= $$FALSE
	PERIOD 			= $$FALSE
	WHITESPACE 	= $$FALSE
	SYMBOL 			= $$FALSE
	POSITIVE 		= $$FALSE
	NEGATIVE 		= $$FALSE

	numberofperiods   = 0
	numberofpositives = 0
	numberofnegatives = 0

	FOR j = 0 TO k-1
 		c = tbuffer${j}
		IF (isalpha (c)) THEN ALPHA = 1
		IF (isdigit(c))  THEN DIGIT = 1
		IF (iswspace(c)) THEN WHITESPACE = 1
		IF (c == '.')    THEN PERIOD = 1 : INC numberofperiods
		IF (c == '+')    THEN
			IF (j > 0)     THEN ALPHA = 1
		END IF
		IF (c == '-')    THEN
			IF (j > 0)     THEN ALPHA = 1
		END IF
	NEXT j

	IF ((ALPHA) || (WHITESPACE)) THEN RETURN 1
	IF ((DIGIT) && (!ALPHA) && (!WHITESPACE)) THEN
		IF (numberofperiods > 1) THEN
			RETURN 1
		ELSE
			RETURN 2
		END IF
	END IF
	RETURN 1

END FUNCTION
'
'
' ##########################################
' #####  CalcVisibleCellBoundaries ()  #####
' ##########################################
'
FUNCTION  CalcVisibleCellBoundaries (XGRIDDATA xgd)

	gridx = xgd.gridwidth
	gridy = xgd.gridheight

	j = xgd.homecol
	xgd.leftvisiblecol = xgd.homecol
	xgd.topvisiblerow  = xgd.homerow

' calc columns visible
' first subtract the width of col 0
	gridx = gridx - xgd.columnwidths[0]

	DO
		gridx = gridx - xgd.columnwidths[j]
		INC j
	LOOP WHILE ((gridx >= 0) && (j < xgd.cols))

	IF (j > xgd.cols) THEN j = xgd.cols
	xgd.rightvisiblecol = j

' calc rows visible
	gridy = gridy - xgd.headerrowheight
	j = xgd.homerow

	DO
		gridy = gridy - xgd.rowheight
		INC j
	LOOP WHILE ((gridy > 0) && (j < xgd.rows))

	IF (j > xgd.rows) THEN j = xgd.rows
	xgd.bottomvisiblerow = j

END FUNCTION
'
'
' ############################
' #####  GetCellRect ()  #####
' ############################
'
FUNCTION  RECT GetCellRect (hWnd, XGRIDDATA xgd, r, c)

	 RECT rect, trect

' c and r must be greater than zero

' get column offset
' first get col 0 width

	offset = xgd.columnwidths[0]
	FOR j = xgd.homecol TO c-1
		offset = offset + xgd.columnwidths[j]
	NEXT j

	rect.left = offset
	rect.right = offset + xgd.columnwidths[c]

	IF (xgd.EXTENDLASTCOLUMN) THEN

' see if this is the last column
		IF (!GetNextColWithWidth (@xgd, c, 1)) THEN
' extend this column
			GetClientRect (hWnd, &trect)
			temp = (offset + (trect.right - rect.left)) - rect.left
			IF (temp > xgd.columnwidths[c]) THEN
				rect.right = offset + (trect.right - rect.left)
			END IF
		END IF
	END IF

' now get the top and bottom of the rect
	offset = xgd.headerrowheight + xgd.titleheight
	FOR j = xgd.homerow TO r-1
		offset = offset + xgd.rowheight
	NEXT j

	rect.top = offset
	rect.bottom = offset + xgd.rowheight
	RETURN rect

END FUNCTION
'
'
' #############################
' #####  DisplayTitle ()  #####
' #############################
'
FUNCTION  DisplayTitle (hWnd, XGRIDDATA xgd, hFont)

	RECT rect

	GetClientRect (hWnd, &rect)
	hdc = GetDC (hWnd)
	oldMode = SetBkMode (hdc, $$TRANSPARENT)
	holdfont = SelectObject (hdc, hFont)
	rect.bottom = xgd.titleheight
	ret = DrawEdge (hdc, &rect, $$EDGE_ETCHED, $$BF_MIDDLE | $$BF_RECT | $$BF_ADJUST)
	ret = DrawTextExA (hdc, &xgd.title, -1, &rect, $$DT_END_ELLIPSIS | $$DT_CENTER | $$DT_WORDBREAK | $$DT_NOPREFIX, NULL)
	SelectObject (hdc, holdfont)
	SetBkMode (hdc, oldMode)
	ReleaseDC (hWnd, hdc)

END FUNCTION
'
'
' ##############################
' #####  DisplayColumn ()  #####
' ##############################
'
FUNCTION  DisplayColumn (hWnd, XGRIDDATA xgd, c, offset, hFont, hColumnHeadingFont)

	BGCELL BGcell
	RECT rect, rectsave, trect
	STATIC buffer$, tbuffer$

'start = GetTickCount()

	IF (xgd.columnwidths[c] == 0) THEN RETURN

	hdc = GetDC (hWnd)
	SetBkMode (hdc, $$TRANSPARENT)
	ShowHscroll (hWnd, xgd)
	ShowVscroll (hWnd, xgd)

	holdfont = SelectObject (hdc, hColumnHeadingFont)
	SetTextColor (hdc, xgd.textcolor)

' display header row
	r=0
	rect.left = offset
	rect.top = xgd.titleheight
	rect.right = xgd.columnwidths[c] + offset
	rect.bottom = xgd.headerrowheight + xgd.titleheight

	IF (xgd.EXTENDLASTCOLUMN) THEN
' see if this is the last column
		IF (!GetNextColWithWidth (@xgd, c, 1)) THEN
' extend this column
			GetClientRect (hWnd, &trect)
			rect.right = offset + (trect.right - rect.left)
		END IF
	ELSE
		IF (!GetNextColWithWidth (@xgd, c, 1)) THEN
' repaint right side of grid
			GetClientRect (hWnd, &trect)
			trect.left = offset + (rect.right - rect.left)
			holdbrush = SelectObject (hdc, GetStockObject ($$GRAY_BRUSH))
			holdpen = SelectObject (hdc, GetStockObject ($$NULL_PEN))
			Rectangle (hdc, trect.left, trect.top+xgd.titleheight, trect.right+1, trect.bottom+1)
			SelectObject (hdc, holdbrush)
			SelectObject (hdc, holdpen)
		END IF
 	END IF

	BGcell.row = r
	BGcell.col = c

	IF (xgd.COLUMNSNUMBERED) && (c > 0) THEN
		high = ((c-1)/26.0)
		low = c MOD 26
		IF (high == 0) THEN
			high = 32
		ELSE
			high = high + 64
		END IF
		IF (low == 0) THEN low = 26
		low = low + 64
		tbuffer$ = NULL$ (2)
		wsprintfA (&tbuffer$, &"%c%c", high, low)
	ELSE
		GOSUB GetData
		tbuffer$ = CSIZE$ (buffer$)
	END IF

	rectsave = rect
	DrawEdge (hdc, &rect, $$EDGE_ETCHED, $$BF_MIDDLE | $$BF_RECT | $$BF_ADJUST)
	IF tbuffer$ THEN DrawTextExA (hdc, &tbuffer$, -1, &rect, $$DT_END_ELLIPSIS | $$DT_CENTER | $$DT_WORDBREAK | $$DT_NOPREFIX, NULL)
	rect = rectsave

	r = xgd.topvisiblerow

' select font for grid body
	SelectObject (hdc, hFont)

' create some objects
	hbrush_hlc 						= CreateSolidBrush (xgd.highlightcolor)
	hbrush_hlc_notfocused = CreateSolidBrush (RGB(200,200,200))
	hbrush_protect 				= CreateSolidBrush (xgd.protectcolor)
	hbrush_unprotect 			= CreateSolidBrush (xgd.unprotectcolor)
	holdbrush 						= SelectObject (hdc, hbrush_hlc)

	hpen 									= CreatePen ($$PS_SOLID, 1, xgd.gridlinecolor)
	holdpen 							= SelectObject (hdc, hpen)

	DO WHILE (r <= xgd.bottomvisiblerow)

' try to set cursor row to different display color
		IF ((r == xgd.cursorrow) && (c > 0) && (xgd.DRAWHIGHLIGHT)) THEN
 			IF (xgd.GRIDHASFOCUS) THEN
				SetTextColor (hdc, xgd.highlighttextcolor)
			ELSE
' set black text for nonfocus grid highlight
				SetTextColor (hdc, 0)
			END IF
		ELSE
			SetTextColor (hdc, 0)
		END IF

		rect.top 		= rect.bottom
		rect.bottom = rect.top + xgd.rowheight
		rectsave 		= rect

' set cell
		BGcell.row = r
		BGcell.col = c

' get cell data, type, and protection
		IF ((c == 0) && (xgd.ROWSNUMBERED)) THEN
			tbuffer$ = NULL$ (6)
			wsprintfA (&tbuffer$, &"%d", r)
			tbuffer$ = CSIZE$ (tbuffer$)
		ELSE
			GOSUB GetData
			tbuffer$ = CSIZE$ (buffer$)
		END IF

' draw cell border
		IF (c == 0) THEN
			DrawEdge (hdc, &rect, $$EDGE_ETCHED, $$BF_MIDDLE | $$BF_RECT | $$BF_ADJUST)
		ELSE
			IF (xgd.DRAWHIGHLIGHT) THEN 		' highlight on
				IF (r == xgd.cursorrow) THEN
					IF (xgd.GRIDHASFOCUS) THEN
						SelectObject (hdc, hbrush_hlc)
					ELSE
						SelectObject (hdc, hbrush_hlc_notfocused)
					END IF
				ELSE
					IF (iProtection == 1) THEN
						SelectObject (hdc, hbrush_protect)
					ELSE
						SelectObject (hdc, hbrush_unprotect)
					END IF
				END IF
			ELSE
				IF (iProtection == 1) THEN
					SelectObject (hdc, hbrush_protect)
				ELSE
					SelectObject (hdc, hbrush_unprotect)
				END IF
			END IF

			Rectangle (hdc, rect.left, rect.top, rect.right, rect.bottom)
		END IF

' skip empty cells
		IFZ tbuffer$ THEN GOTO skipit

		rect.right = rect.right - 2
		rect.left = rect.left + 2
		IF rect.right - rect.left < xgd.rowheight - 4 THEN
			rect.right = rect.left + xgd.rowheight - 4
		END IF

		IF (c == 0) THEN iDataType = 2

		SELECT CASE iDataType
			CASE 1 : 						' ALPHA
				IF (xgd.ELLIPSIS) THEN
					DrawTextExA (hdc, &tbuffer$, -1, &rect, $$DT_END_ELLIPSIS | $$DT_LEFT | $$DT_VCENTER | $$DT_SINGLELINE | $$DT_NOPREFIX, NULL)
				ELSE
					DrawTextExA (hdc, &tbuffer$, -1, &rect, $$DT_LEFT | $$DT_WORDBREAK | $$DT_EDITCONTROL | $$DT_NOPREFIX, NULL)
				END IF

			CASE 2 :						' NUMERIC
				DrawTextExA (hdc, &tbuffer$, -1, &rect, $$DT_END_ELLIPSIS | $$DT_RIGHT | $$DT_VCENTER | $$DT_SINGLELINE | $$DT_NOPREFIX, NULL)

			CASE 3 :						' BOOLEAN TRUE
				k = 2
				rect.top = rect.top + k
				rect.bottom = rect.bottom - k
				IF ((rect.bottom - rect.top) > 24) THEN
					excess = (rect.bottom - rect.top) - 16
					rect.top = rect.top + (excess/2.0)
					rect.bottom = rect.bottom - (excess/2.0)
				END IF
				DrawFrameControl (hdc, &rect, $$DFC_BUTTON, $$DFCS_BUTTONCHECK | $$DFCS_CHECKED)

			CASE 4 : 						' BOOLEAN FALSE
				k = 2
				rect.top = rect.top + k
				rect.bottom = rect.bottom - k
				IF ((rect.bottom - rect.top) > 24) THEN
					excess= (rect.bottom - rect.top) - 16
					rect.top = rect.top + (excess/2.0)
					rect.bottom = rect.bottom - (excess/2.0)
				END IF
				DrawFrameControl (hdc, &rect, $$DFC_BUTTON, $$DFCS_BUTTONCHECK)

			CASE 5 :						' user drawn graphic
				buffer${0} = 0x20
				buffer$ = CSIZE$ (buffer$)
				xgd.ownerdrawitem = atoi (&buffer$)
				wParam = MAKELONG (GetMenu (hWnd), $$BGN_OWNERDRAW)
				SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, &rect)
		END SELECT

skipit:
		IF (xgd.EDITING) THEN DisplayEditString (hWnd, @xgd, @"")
 		rect = rectsave
		INC r
	LOOP


' delete objects
	SelectObject (hdc, holdbrush)
	SelectObject (hdc, holdpen)
	DeleteObject (hpen)
	DeleteObject (hbrush_hlc)
	DeleteObject (hbrush_hlc_notfocused)
	DeleteObject (hbrush_protect)
	DeleteObject (hbrush_unprotect)

' repaint bottom of grid
	GetClientRect (hWnd, &trect)
	trect.top = rect.bottom
	trect.left = rect.left
	trect.right = rect.right

	holdbrush = SelectObject (hdc, GetStockObject ($$GRAY_BRUSH))
	holdpen = SelectObject (hdc, GetStockObject ($$NULL_PEN))
	Rectangle (hdc, trect.left, trect.top, trect.right+1, trect.bottom+1)
	SelectObject (hdc, holdbrush)
	SelectObject (hdc, holdpen)
	SelectObject (hdc, holdfont)
	DeleteObject (holdfont)
	ReleaseDC (hWnd, hdc)

'PRINT "DisplayColumn time: "; GetTickCount() - start

' ***** GetData *****
SUB GetData

	buffer$ = NULL$ (1024)
	iDataType = 1
	iProtection = 0

	wsprintfA (&buffer$, &"%05d-%03d", r, c)
	fbuffer$ = CSIZE$ (buffer$)

'see if that cell is already loaded
	findResult = BinarySearchListBox (xgd.hlist1, @fbuffer$)

	IF (findResult != $$LB_ERR) THEN
' it was found, get it
		tbuffer$ = NULL$ (1024)
		len = SendMessageA (xgd.hlist1, $$LB_GETTEXT, findResult, &tbuffer$)

' get data type
		SELECT CASE (tbuffer${11})
			CASE 'A'	: iDataType = 1
			CASE 'N'	: iDataType = 2
			CASE 'T'	: iDataType = 3
			CASE 'F'	: iDataType = 4
			CASE 'G'	: iDataType = 5
			CASE ELSE	: iDataType = 1
		END SELECT

' get cell protection
		SELECT CASE (tbuffer${10})
			CASE 'U':		iProtection = 0
			CASE 'P':		iProtection = 1
			CASE ELSE : iProtection = 0
		END SELECT

'copy data string
		k = len - 1
		count = 0
		FOR j = 13 TO k
			buffer${count} = tbuffer${j}
			INC count
		NEXT j
		buffer${count} = 0x00
	ELSE
'		buffer$ = ""
		buffer${0} = 0x00
	END IF

END SUB

END FUNCTION
'
'
' ###########################
' #####  DrawCursor ()  #####
' ###########################
'
FUNCTION  DrawCursor (hWnd, XGRIDDATA xgd)

	RECT rect, rectwhole

	IF (xgd.rows == 0) THEN RETURN
	IFZ (xgd.SHOWCURSOR) THEN RETURN

	GetClientRect (hWnd, &rect)

' if active cell has scrolled off the top, don't draw a focus rectangle
	IF (xgd.cursorrow < xgd.homerow) THEN RETURN

' if active cell has scrolled off to the left, don't draw a focus rectangle
	IF (xgd.cursorcol < xgd.homecol) THEN RETURN

	rect = GetCellRect (hWnd, @xgd, xgd.cursorrow, xgd.cursorcol)
'	rectwhole = rect
	hdc = GetDC (hWnd)
	xgd.activecellrect = rect
	rop = GetROP2 (hdc)
	SetROP2 (hdc, $$R2_XORPEN)
	SelectObject (hdc, GetStockObject ($$NULL_BRUSH))
	hpen = CreatePen ($$PS_SOLID, 3, xgd.cursorcolor)  ' width of 3
	holdpen = SelectObject (hdc, hpen)
	Rectangle (hdc, rect.left, rect.top, rect.right, rect.bottom)
	SelectObject (hdc, holdpen)
	DeleteObject (hpen)
	SetROP2 (hdc, rop)
	ReleaseDC (hWnd, hdc)

END FUNCTION
'
'
' #####################################
' #####  SetCurrentCellStatus ()  #####
' #####################################
'
FUNCTION  SetCurrentCellStatus (hWnd, XGRIDDATA xgd)

	BGCELL BGcell

	SetCell (@BGcell, xgd.cursorrow, xgd.cursorcol)
	IF (SendMessageA (hWnd, $$BGM_GETPROTECTION, &BGcell, 0)) THEN
		xgd.CURRENTCELLPROTECTED = $$TRUE
	ELSE
		xgd.CURRENTCELLPROTECTED = $$FALSE
 	END IF

END FUNCTION
'
'
' #########################
' #####  GetASCII ()  #####
' #########################
'
FUNCTION  GetASCII (wParam, lParam)

	UBYTE keys[]

	DIM keys[255]
	GetKeyboardState (&keys[])
'	scancode = (lParam >> 16) && 0xFF
'	result = ToAscii (wParam, scancode, &keys[], &returnvalue, 0)
	result = ToAscii (wParam, lParam, &keys[], &returnvalue, 0)
	IF (returnvalue < 0) THEN returnvalue = 0
' check to see if one character was copied to returnvalue
 	IF (result != 1) THEN returnvalue = 0
 	RETURN returnvalue

END FUNCTION
'
'
' ###########################
' #####  SetHomeRow ()  #####
' ###########################
'
FUNCTION  SetHomeRow (hWnd, XGRIDDATA xgd, row, col)

	 RECT gridrect, cellrect

' get rect of grid window
	 GetClientRect (hWnd, &gridrect)

' get rect of current cell
	cellrect = GetCellRect (hWnd, @xgd, row, col)

	IF ((cellrect.bottom > gridrect.bottom) && ((cellrect.bottom - cellrect.top) < (gridrect.bottom-(xgd.headerrowheight+xgd.titleheight)))) THEN

		DO WHILE (cellrect.bottom > gridrect.bottom)
			INC xgd.homerow
			IF (row == xgd.rows) THEN
				gridrect.top = gridrect.bottom - (xgd.rowheight)
				InvalidateRect (hWnd, &gridrect, $$TRUE)
			ELSE
				InvalidateRect (hWnd, &gridrect, $$FALSE)
			END IF
			cellrect = GetCellRect (hWnd, @xgd, row, col)
		LOOP
	ELSE
		IF ((cellrect.bottom - cellrect.top) >= (gridrect.bottom - (xgd.headerrowheight+xgd.titleheight))) THEN
			INC xgd.homerow
		END IF
 	END IF

	cellrect = GetCellRect (hWnd, @xgd, row, col)

	DO WHILE ((row < xgd.homerow))
		DEC xgd.homerow
		InvalidateRect (hWnd, &gridrect, $$FALSE)
		cellrect = GetCellRect (hWnd, @xgd, row, col)
	LOOP

' set the vertical scrollbar position
	SetScrollPos (hWnd, $$SB_VERT, xgd.homerow, $$TRUE)

END FUNCTION
'
'
' ###########################
' #####  SetHomeCol ()  #####
' ###########################
'
FUNCTION  SetHomeCol (hWnd, XGRIDDATA xgd, row, col)

 	RECT gridrect, cellrect

' get rect of grid window
	GetClientRect (hWnd, &gridrect)

' get rect of current cell
	cellrect = GetCellRect (hWnd, @xgd, row, col)

' determine if scroll left or right is needed
	DO WHILE ((cellrect.right > gridrect.right) && (cellrect.left != xgd.columnwidths[0]))
' scroll right is needed
		INC xgd.homecol
' see if last column is visible
		cellrect = GetCellRect (hWnd, @xgd, row, xgd.cols)
		IF (cellrect.right <= gridrect.right) THEN
			LASTCOLVISIBLE = $$TRUE
		ELSE
			LASTCOLVISIBLE = $$FALSE
		END IF
		cellrect = GetCellRect (hWnd, @xgd, row, col)
		InvalidateRect (hWnd, &gridrect, $$FALSE)
	LOOP

	cellrect = GetCellRect (hWnd, @xgd, row, col)
	DO WHILE ((xgd.cursorcol < xgd.homecol) && (xgd.homecol > 1))
'scroll left is needed
		DEC xgd.homecol
' see if last column is visible
		cellrect = GetCellRect (hWnd, @xgd, row, xgd.cols)
		IF (cellrect.right <= gridrect.right) THEN
			LASTCOLVISIBLE = $$TRUE
		ELSE
			LASTCOLVISIBLE = $$FALSE
 		END IF

		cellrect = GetCellRect (hWnd, @xgd, row, col)
		InvalidateRect (hWnd, &gridrect, $$FALSE)
	LOOP

	k = HomeColumnNthVisible (@xgd)
	SetScrollPos (hWnd, $$SB_HORZ, k, $$TRUE)

END FUNCTION
'
'
' ############################
' #####  ShowVscroll ()  #####
' ############################
'
FUNCTION  ShowVscroll (hWnd, XGRIDDATA xgd)

' if more rows than can be visible on grid, display vertical scrollbar
' otherwise, hide it.

	RECT gridrect

	GetClientRect (hWnd, &gridrect)
	totalpixels = gridrect.bottom
	totalpixels = totalpixels - xgd.titleheight
	totalpixels = totalpixels - xgd.headerrowheight
	totalpixels = totalpixels - (xgd.rowheight * xgd.rows)
	rowsvisibleonscreen = (gridrect.bottom - (xgd.headerrowheight + xgd.titleheight)) / xgd.rowheight

	IF (totalpixels < 0) THEN
' show vscrollbar
		ret = ShowScrollBar (hWnd, $$SB_VERT, $$TRUE)
		ret = SetScrollRange (hWnd, $$SB_VERT, 1, (xgd.rows-rowsvisibleonscreen)+1, $$TRUE)
		xgd.VSCROLL = $$TRUE
	ELSE
' hide vscrollbar
		ShowScrollBar (hWnd, $$SB_VERT, $$FALSE)
		xgd.VSCROLL = $$FALSE
	END IF

END FUNCTION
'
'
' ############################
' #####  ShowHscroll ()  #####
' ############################
'
FUNCTION  ShowHscroll (hWnd, XGRIDDATA xgd)

' if more rows than can be visible on grid, display vertical scrollbar
' otherwise, hide it.

	RECT gridrect

	GetClientRect (hWnd, &gridrect)
	totalpixels = gridrect.right
'	totalpixels = totalpixels - xgd.columnwidths[0]
	colswithwidth = 0
	FOR j = 0 TO xgd.cols
		totalpixels = totalpixels - xgd.columnwidths[j]
		IF (xgd.columnwidths[j] > 0) THEN INC colswithwidth
	NEXT j
	IF (totalpixels < 0) THEN
' show hscrollbar
		ShowScrollBar (hWnd, $$SB_HORZ, $$TRUE)
		SetScrollRange (hWnd, $$SB_HORZ,1, colswithwidth, $$TRUE)
		xgd.HSCROLL = $$TRUE
	ELSE
' hide hscrollbar
		ShowScrollBar (hWnd, $$SB_HORZ, $$FALSE)
		xgd.HSCROLL = $$FALSE
	END IF

END FUNCTION
'
'
' #################################
' #####  NotifyRowChanged ()  #####
' #################################
'
FUNCTION  NotifyRowChanged (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_ROWCHANGED)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

	wParam = MAKELONG (xgd.gridmenu, $$BGN_SELCHANGE)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #################################
' #####  NotifyColChanged ()  #####
' #################################
'
FUNCTION  NotifyColChanged (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_COLCHANGED)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

	wParam = MAKELONG (xgd.gridmenu, $$BGN_SELCHANGE)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' ##############################
' #####  NotifyEndEdit ()  #####
' ##############################
'
FUNCTION  NotifyEndEdit (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_EDITEND)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #############################
' #####  NotifyDelete ()  #####
' #############################
'
FUNCTION  NotifyDelete (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_DELETECELL)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' ################################
' #####  NotifyEditBegin ()  #####
' ################################
'
FUNCTION  NotifyEditBegin (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_EDITBEGIN)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' ################################
' #####  NotifyEditBegin ()  #####
' ################################
'
FUNCTION  NotifyEditEnd (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_EDITEND)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF1 ()  #####
' #########################
'
FUNCTION  NotifyF1 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F1)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF2 ()  #####
' #########################
'
FUNCTION  NotifyF2 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F2)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF3 ()  #####
' #########################
'
FUNCTION  NotifyF3 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F3)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF4 ()  #####
' #########################
'
FUNCTION  NotifyF4 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F4)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF5 ()  #####
' #########################
'
FUNCTION  NotifyF5 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F5)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF6 ()  #####
' #########################
'
FUNCTION  NotifyF6 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F6)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF7 ()  #####
' #########################
'
FUNCTION  NotifyF7 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F7)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF8 ()  #####
' #########################
'
FUNCTION  NotifyF8 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F8)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  NotifyF9 ()  #####
' #########################
'
FUNCTION  NotifyF9 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F9)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' ##########################
' #####  NotifyF10 ()  #####
' ##########################
'
FUNCTION  NotifyF10 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F10)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' ##########################
' #####  NotifyF11 ()  #####
' ##########################
'
FUNCTION  NotifyF11 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F11)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' ##########################
' #####  NotifyF12 ()  #####
' ##########################
'
FUNCTION  NotifyF12 (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_F12)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' ##################################
' #####  NotifyCellClicked ()  #####
' ##################################
'
FUNCTION  NotifyCellClicked (hWnd, XGRIDDATA xgd)

	lParam = MAKELONG (xgd.cursorrow, xgd.cursorcol)
	wParam = MAKELONG (xgd.gridmenu, $$BGN_CELLCLICKED)
	SendMessageA (GetParent (hWnd), $$WM_COMMAND, wParam, lParam)

END FUNCTION
'
'
' ##################################
' #####  GetVisibleColumns ()  #####
' ##################################
'
FUNCTION  GetVisibleColumns (hWnd, XGRIDDATA xgd)

	value = 0
	FOR j = 1 TO xgd.cols
 		IF (xgd.columnwidths[j] > 0) THEN
			INC value
		END IF
	NEXT j
	xgd.visiblecolumns = value
	SetScrollRange (hWnd, $$SB_HORZ, 1, value, $$TRUE)

END FUNCTION
'
'
' ####################################
' #####  GetNthVisibleColumn ()  #####
' ####################################
'
FUNCTION  GetNthVisibleColumn (hWnd, XGRIDDATA xgd, n)

	j = 1
	count = 0
	value = n - 1
	DO WHILE (j <= xgd.cols)
		IF (xgd.columnwidths[j] > 0) THEN
 			INC count
			IF (count == n) THEN
				value = j
			END IF
		END IF
		INC j
	LOOP
	RETURN value

END FUNCTION
'
'
' ##########################
' #####  CloseEdit ()  #####
' ##########################
'
FUNCTION  CloseEdit (hWnd, XGRIDDATA xgd)

	BGCELL cell

	r = xgd.cursorrow
	c = xgd.cursorcol
	cell.row = r
	cell.col = c
	SendMessageA (hWnd, $$BGM_SETCELLDATA, &cell, &xgd.editstring)
	xgd.editstring = ""			' strcpy(xgd.editstring,"")
	RefreshGrid (hWnd, @xgd)
	xgd.EDITING = $$FALSE
	HideCaret (hWnd)
	NotifyEditEnd (hWnd, @xgd)

END FUNCTION
'
'
' ##################################
' #####  DisplayEditString ()  #####
' ##################################
'
FUNCTION  DisplayEditString (hWnd, XGRIDDATA xgd, @string$)

	RECT rt
	TEXTMETRIC tm

	r = xgd.cursorrow
	c = xgd.cursorcol
	ShowCaret (hWnd)
	IF ((r < xgd.homerow) || (c < xgd.homecol)) THEN
		HideCaret (hWnd)
		RETURN
	END IF
	rt = GetCellRect (hWnd, @xgd, r, c)
	rt.top = rt.top + 2
	rt.bottom = rt.bottom - 2
	rt.right = rt.right - 2
	rt.left = rt.left + 2

	hdc = GetDC (hWnd)
	Rectangle (hdc, rt.left, rt.top, rt.right, rt.bottom)
	rt.top = rt.top + 2
	rt.bottom = rt.bottom - 2
	rt.right = rt.right - 2
	rt.left = rt.left + 2

	xgd.editstring = xgd.editstring + string$
	xgd.editstringdisplay = xgd.editstring

	holdfont = SelectObject (hdc, xgd.hfont)
	rt.right = rt.right - 5
	es$ = xgd.editstringdisplay
	DrawTextA (hdc, &es$, -1, &rt, $$DT_RIGHT | $$DT_VCENTER | $$DT_SINGLELINE)
	rt.right = rt.right + 5
	ShowCaret (hWnd)

	GetTextMetricsA (hdc, &tm)
	xgd.fontascentheight = tm.ascent

	SetCaretPos (rt.right-4, rt.top + (xgd.rowheight/2.0)-xgd.fontascentheight+2)

	SelectObject (hdc, holdfont)
	ReleaseDC (hWnd, hdc)

END FUNCTION
'
'
' #########################
' #####  SizeGrid ()  #####
' #########################
'
FUNCTION  SizeGrid (hWnd, XGRIDDATA xgd)

	RECT rc
	POINT pt

	IF ((xgd.wannabewidth == 0) || (xgd.wannabeheight == 0)) THEN RETURN

	GetWindowRect (hWnd, &rc)
	pt.x = rc.left
	pt.y = rc.top
	ScreenToClient (GetParent (hWnd), &pt)
	MoveWindow (hWnd, pt.x, pt.y, xgd.wannabewidth, xgd.wannabeheight, $$FALSE)

END FUNCTION
'
'
' ################################
' #####  FindLongestLine ()  #####
' ################################
'
FUNCTION  FindLongestLine (hdc, @text$, SIZEAPI size)

	longest = 0

' what do the following 7 lines do???
'	lines = 1
'	upp = LEN (text$) - 1
'	FOR j = 0 TO upp
'		IF (text{j} == '\n') THEN
'			INC lines
'		END IF
'	NEXT j

	temptext$ = text$							' strcpy(temptext,text)
	p = strtok (&temptext$, &"\n")
	DO WHILE (p)
		tok$ = CSTRING$ (p)
		GetTextExtentPoint32A (hdc, p, LEN (tok$), &size)
		IF (size.cx > longest) THEN
			longest = size.cx
		END IF
		p = strtok('\0', &"\n")
	LOOP

' MessageBoxA (NULL, &text$, &"FindLongestLine", $$MB_OK)
 	RETURN longest

END FUNCTION
'
'
' ####################################
' #####  BinarySearchListBox ()  #####
' ####################################
'
FUNCTION  BinarySearchListBox (hWndLB, @searchtext$)

' note: list boxes are sorted automatically
' binary searches must be done on a sorted list

	IFZ searchtext$ THEN RETURN ($$LB_ERR)

' get count of items in listbox
	lbcount = SendMessageA (hWndLB, $$LB_GETCOUNT, 0, 0)

 	IF (lbcount == 0) THEN RETURN ($$LB_ERR)

	IF (lbcount < 12) THEN
' not worth doing binary search, do regular search
		RETURN SendMessageA (hWndLB, $$LB_FINDSTRING, -1, &searchtext$)
	END IF

' do a binary search
	head = 0
	tail = lbcount - 1

' is it the head?
	headtext$ = NULL$ (1024)
	SendMessageA (hWndLB, $$LB_GETTEXT, head, &headtext$)
	headtext${9} = 0x00
	headtext$ = CSIZE$ (headtext$)

	SELECT CASE TRUE
		CASE searchtext$ = headtext$ : RETURN (head)			' it was the head
		CASE searchtext$ < headtext$ : RETURN ($$LB_ERR)	' it was less than the head... not found
	END SELECT

' is it the tail?
	tailtext$ = NULL$ (1024)
	SendMessageA (hWndLB, $$LB_GETTEXT, tail, &tailtext$)
	tailtext${9} = 0x00
	tailtext$ = CSIZE$ (tailtext$)

	SELECT CASE TRUE
		CASE searchtext$ = tailtext$ : RETURN (tail)			' it was the tail
		CASE searchtext$ > tailtext$ : RETURN ($$LB_ERR)	' it was greater than the tail... not found
	END SELECT

' is it the finger?
	tbuffer$ = NULL$ (1024)

	DO WHILE ((tail-head) > 1)
		finger = head + ((tail - head) / 2)
		SendMessageA (hWndLB, $$LB_GETTEXT, finger, &tbuffer$)
		tbuffer${9} = 0x00
		buffer$ = CSIZE$ (tbuffer$)

		SELECT CASE TRUE
			CASE buffer$ = searchtext$ : RETURN (finger)	' found it
			CASE buffer$ < searchtext$ : head = finger 		' change head to finger
			CASE buffer$ > searchtext$ : tail = finger 		' change tail to finger
		END SELECT

	LOOP
	RETURN ($$LB_ERR)		' not found

END FUNCTION
'
'
' #################################
' #####  CalcIntegralRows ()  #####
' #################################
'
FUNCTION  CalcIntegralRows (XGRIDDATA xgd, width, @height)

	SHARED borderSize

' note width and height parameters from
' WM_WINDOWPOSCHANGING are window rect dimensions,
' and NOT client rect dimensions.

	width = width - borderSize - borderSize
	height = height - borderSize - borderSize

	totalpixels = width
	FOR j = 0 TO xgd.cols
		totalpixels = totalpixels - xgd.columnwidths[j]
	NEXT j
	IF (totalpixels < 0) THEN
		xgd.HSCROLL = $$TRUE				' show hscrollbar
	ELSE
		xgd.HSCROLL = $$FALSE				' hide hscrollbar
	END IF

	totalpixels = height
	totalpixels = totalpixels - xgd.titleheight
	totalpixels = totalpixels - xgd.headerrowheight
	totalpixels = totalpixels - (xgd.rowheight * xgd.rows)

'	rowsvisibleonscreen = (height - (xgd.headerrowheight + xgd.titleheight)) / xgd.rowheight
	IF (totalpixels < 0) THEN
		xgd.VSCROLL = $$TRUE				' show vscrollbar
	ELSE
		xgd.VSCROLL = $$FALSE				' hide vscrollbar
	END IF

	IF ((xgd.SHOWINTEGRALROWS) && (xgd.VSCROLL)) THEN
		cheight = height - xgd.titleheight - xgd.headerrowheight

' get height of horizontal scrollbar
		sbheight = GetSystemMetrics ($$SM_CYHSCROLL)

		IF (xgd.HSCROLL) THEN
			cheight = cheight - sbheight
		END IF

		IF (cheight <= xgd.rowheight) THEN
			GOTO end
		ELSE
' calculate fractional part of cheight/rowheight
			nrows = cheight/xgd.rowheight
			remainder = cheight - (nrows * xgd.rowheight)
' make the window remainder pixels shorter
			height = height - remainder
		END IF
	END IF

end:
	height = height + borderSize + borderSize

END FUNCTION
'
'
' ##############################
' #####  GetBorderSize ()  #####
' ##############################
'
FUNCTION  GetBorderSize (hWnd)

	RECT rc

	GetWindowRect (hWnd, &rc)
	outer = rc.right - rc.left

	GetClientRect (hWnd, &rc)
	inner = rc.right

	RETURN ((outer-inner)/2)

END FUNCTION
'
'
' ########################
' #####  SetCell ()  #####
' ########################
'
FUNCTION  SetCell (BGCELL cell, row, col)

	 cell.row = row
	 cell.col = col

END FUNCTION
'
'
' ########################
' #####  PutCell ()  #####
' ########################
'
FUNCTION  PutCell (hGrid, row, col, text$)

	BGCELL cell

	cell.row = row
	cell.col = col
 	SendMessageA (hGrid, $$BGM_SETCELLDATA, &cell, &text$)

END FUNCTION
'
'
' #########################
' #####  InitCell ()  #####
' #########################
'
FUNCTION  InitCell (hGrid, row, col, text$)

	BGCELL cell

	cell.row = row
	cell.col = col
 	SendMessageA (hGrid, $$BGM_INITCELLDATA, &cell, &text$)

END FUNCTION
'
'
' ################################
' #####  SetDefaultFonts ()  #####
' ################################
'
FUNCTION  SetDefaultFonts (hWnd)

	hfont = CreateFontA (16, 0, 0, 0, $$FW_THIN,  $$FALSE, $$FALSE, $$FALSE, $$ANSI_CHARSET, $$OUT_DEFAULT_PRECIS, $$CLIP_DEFAULT_PRECIS, $$PROOF_QUALITY, $$VARIABLE_PITCH | $$FF_MODERN, NULL)
	SendMessageA (hWnd, $$WM_SETFONT, hfont, $$TRUE)

	hfont = 0
	hfont = CreateFontA (18, 0, 0, 0, $$FW_BOLD, $$FALSE, $$FALSE, $$FALSE, $$ANSI_CHARSET, $$OUT_DEFAULT_PRECIS, $$CLIP_DEFAULT_PRECIS, $$PROOF_QUALITY, $$VARIABLE_PITCH | $$FF_MODERN, NULL)
	SendMessageA (hWnd, $$BGM_SETHEADINGFONT, hfont, 0)

	hfont = 0
	hfont = CreateFontA (20, 0, 0, 0, $$FW_BOLD, $$FALSE, $$FALSE, $$FALSE, $$ANSI_CHARSET, $$OUT_DEFAULT_PRECIS, $$CLIP_DEFAULT_PRECIS, $$PROOF_QUALITY, $$VARIABLE_PITCH | $$FF_MODERN, NULL)
	SendMessageA (hWnd, $$BGM_SETTITLEFONT, hfont, 0)

END FUNCTION
'
'
' ####################################
' #####  SetDefaultColWidths ()  #####
' ####################################
'
FUNCTION  SetDefaultColWidths (hWnd)

	cols = SendMessageA (hWnd, $$BGM_GETCOLS, 0, 0)

	FOR i = 0 TO cols
		SendMessageA (hWnd, $$BGM_SETCOLWIDTH, i, 50)
	NEXT i

END FUNCTION
'
'
' ######################################
' #####  SetDefaultCursorColor ()  #####
' ######################################
'
FUNCTION  SetDefaultCursorColor (hWnd)

	SendMessageA (hWnd, $$BGM_SETCURSORCOLOR, RGB (255,255,255), 0)

END FUNCTION
'
'
' ##########################################
' #####  SetDefaultHeaderRowHeight ()  #####
' ##########################################
'
FUNCTION  SetDefaultHeaderRowHeight (hWnd)

	SendMessageA (hWnd, $$BGM_SETHEADERROWHEIGHT, 21, 0)

END FUNCTION
END PROGRAM
