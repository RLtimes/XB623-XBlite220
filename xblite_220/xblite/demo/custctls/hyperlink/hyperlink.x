'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A hyperlink custom control.
' Based on PB code by Bernard Ertl.
' Various styles are available.
' If control is created using WS_TABSTOP,
' then the user can move between controls
' by using TAB key. Plus, pressing spacebar
' will activate the currently focused control.
'
' v0.0002 - 2004-04-17 by Matthias C. Hormann (mhormann@gmx.de)
'   - Modified to handle $$WM_SETTEXT messages correctly
'     so you can change hyperlinks on a dialog dynamically :-)
'     (I needed this for the "about" box in my XBLite Application Skeleton.)
'   - Modified to leave the current focus unchanged but change the link color
'     when mousing over the control. Corrected some minor display problems.
'   - Unfortunately still needs the timer construct to reset the link colors.
'     I wonder if that is a Windows problem or a silly mistake somewhere...
'
PROGRAM	"hyperlink"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"shell32"
	IMPORT  "advapi32"

TYPE HYPERLINKDATA
	XLONG	.hBrush
	XLONG	.hFont
	XLONG	.txtBack
	XLONG	.txtClr
	XLONG	.hTimer
	XLONG	.sx1
	XLONG	.sy1
	XLONG	.sx2
	XLONG	.sy2
	XLONG	.clicked
	XLONG	.style
	XLONG	.hCurArrow
	XLONG	.hCurHand
	XLONG	.focus
	XLONG	.tabstop
END TYPE

EXPORT
DECLARE FUNCTION  Hyperlink ()
END EXPORT
INTERNAL FUNCTION  HyperLinkProc (hWnd, msg, wParam, lParam)
EXPORT
DECLARE FUNCTION  GoToURL (url$, showcmd)
DECLARE FUNCTION  GetRegKey (key, subkey$, @retdata$)

$$HYPERLINKCLASSNAME = "hyperlinkctrl"

' custom hyperlink control messages
$$SET_HYPERLINK_STYLE   = 1025 		' set style in lParam
$$SET_HYPERLINK_BKCOLOR = 1026		' set color in lParam

' hyperlink styles
$$HS_RELIEFTEXT    = 0x01					' draw relief style text
$$HS_NOUNDERLINE   = 0x02					' do not draw underline
$$HS_NOHANDCURSOR  = 0x04					' use only arrow cursor
$$HS_DRAWFOCUSRECT = 0x08					' draw a focus rect if window style is WS_TABSTOP
$$HS_CENTERHORZ		 = 0x10					' center text horizontally in control
$$HS_CENTERVERT    = 0x20					' center text vertically in control

END EXPORT

$$BLUE   = 0xFF0000
$$RED    = 0x0000FF
$$PURPLE = 0x990099
$$DKGRAY = 0x808080
$$WHITE  = 0xFFFFFF
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' PURPOSE	: Initialize hyperlink control class.
'
FUNCTION  Hyperlink ()

	SHARED hCurArrow, hCurHand
	WNDCLASS wc
	STATIC init

' do this once
	IF init THEN RETURN
	init = $$TRUE

' Get arrow cursor
	hCurArrow = LoadCursorA (NULL, $$IDC_ARROW)

' Use a cursor from resource file.
  hCurHand = LoadCursorA (GetModuleHandleA (&"hyperlink.dll"), &"hand")

' If we couldn't get the hand (custom) cursor then use arrow
  IFZ hCurHand THEN
    hCurHand = hCurArrow
  END IF

' Register control window class.
	className$       = "hyperlinkctrl"
	wc.style         = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_GLOBALCLASS
  wc.lpfnWndProc   = &HyperLinkProc()
  wc.cbClsExtra    = 0
  wc.cbWndExtra    = 0    			' use 4 pre allocated bytes at offset $$GWL_USERDATA
  wc.hInstance     = GetModuleHandleA (0)
  wc.hIcon         = NULL
  wc.hCursor       = NULL
  wc.hbrBackground = $$COLOR_WINDOW + 1
  wc.lpszMenuName  = NULL
  wc.lpszClassName = &className$

  RETURN RegisterClassA (&wc)

END FUNCTION
'
'
' ##############################
' #####  HyperLinkProc ()  #####
' ##############################
'
FUNCTION  HyperLinkProc (hWnd, msg, wParam, lParam)

	HYPERLINKDATA hld
	POINT pt
	LOGFONT lf
	PAINTSTRUCT ps
	RECT rc, rect
	SIZEAPI sz
	SHARED hCurArrow, hCurHand

  pHyperLinkData = GetWindowLongA (hWnd, $$GWL_USERDATA)
  IFZ pHyperLinkData THEN
		pHyperLinkData = HeapAlloc (GetProcessHeap(), $$HEAP_ZERO_MEMORY, SIZE(hld))
		IF pHyperLinkData THEN
' set pointer to link data in user data
			SetWindowLongA (hWnd, $$GWL_USERDATA, pHyperLinkData)
		ELSE
			RETURN
		END IF
  END IF
	RtlMoveMemory (&hld, pHyperLinkData, SIZE(hld))

	SELECT CASE msg
		CASE $$WM_DESTROY:
			DeleteObject (hld.hFont)
			DeleteObject (hld.hBrush)
			IF hld.hTimer THEN KillTimer (hWnd, hld.hTimer)
			HeapFree (GetProcessHeap (), 0, pHyperLinkData)

' Get the colors and create a brush for the background
		CASE $$WM_CREATE:
			hld.txtClr    = $$BLUE
			hld.txtBack   = GetSysColor ($$COLOR_3DFACE)
			hld.hBrush    = CreateSolidBrush (hld.txtBack)
			hld.hCurArrow = hCurArrow
			hld.hCurHand  = hCurHand

' check if window style has WS_TABSTOP
			wstyle = GetWindowLongA (hWnd, $$GWL_STYLE)
			IF (wstyle AND $$WS_TABSTOP) THEN hld.tabstop = $$TRUE

			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))

' init default font
			SendMessageA (hWnd, $$WM_SETFONT, 0, 1)

' Add an underline to the default dialog font
		CASE $$WM_SETFONT:
			IF hld.hFont THEN DeleteObject (hld.hFont)
			hFont = wParam
			IFZ hFont THEN hFont = GetStockObject ($$DEFAULT_GUI_FONT)
			GetObjectA (hFont, SIZE (lf), &lf)
      lf.underline = 1
      hld.hFont = CreateFontIndirectA (&lf)

			text$ = NULL$(256)
			GetWindowTextA (hWnd, &text$, SIZE(text$))
			text$ = TRIM$ (text$)
			hDC = GetDC (hWnd)
			hLastFont = SelectObject (hDC, hld.hFont)
			GetTextExtentPoint32A (hDC, &text$, LEN(text$), &sz)
			SelectObject (hDC, hLastFont)
			GetClientRect (hWnd, &rc)
			hld.sx2 = MIN (sz.cx, rc.right)
			hld.sy2 = MIN (sz.cy, rc.bottom)
			hld.sx1 = 0
			hld.sy1 = 0
			ReleaseDC (hWnd, hDC)
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
			InvalidateRect (hWnd, 0, $$TRUE) ' v0.0002: new
			UpdateWindow (hWnd)              ' v0.0002: new

		CASE $$WM_MOUSEMOVE:
			x = LOWORD (lParam)
			y = HIWORD (lParam)
			IF (x < hld.sx2) AND (x > hld.sx1) AND (y < hld.sy2) AND (y > hld.sy1) THEN
				SetCursor (hld.hCurHand)
				IF hld.txtClr <> $$RED THEN
					hld.txtClr = $$RED
					hld.hTimer = SetTimer (hWnd, 1, 100, NULL)
				END IF
			ELSE
				SetCursor (hld.hCurArrow)
				IF hld.txtClr = $$RED THEN
					IFZ hld.focus THEN     ' v0.0002: changed
						IF hld.clicked THEN
							hld.txtClr = $$PURPLE
						ELSE
							hld.txtClr = $$BLUE
						END IF
					END IF
					IF hld.hTimer THEN
						KillTimer (hWnd, hld.hTimer)
						hld.hTimer = 0
					END IF
				END IF
      END IF
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
			InvalidateRect (hWnd, 0, $$TRUE) ' v0.0002: new
			UpdateWindow (hWnd)              ' v0.0002: new

' If the left mouse button is clicked, post a message to the parent window/dialog for processing
		CASE $$WM_LBUTTONDOWN:
			hld.clicked = $$TRUE
			hld.txtClr = $$PURPLE
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
			InvalidateRect (hWnd, 0, $$TRUE) ' v0.0002: new
			UpdateWindow (hWnd)              ' v0.0002: new
			wparam = MAKELONG (GetWindowLongA (hWnd, $$GWL_ID), $$BN_CLICKED)
      PostMessageA (GetWindowLongA (hWnd, $$GWL_HWNDPARENT), $$WM_COMMAND, wparam, hWnd)

		CASE $$WM_TIMER:
			GetCursorPos (&pt)
			GetWindowRect (hWnd, &rc)
			IF (pt.x >= rc.left + hld.sx1) && (pt.x < rc.left + hld.sx2) && (pt.y >= rc.top + sy1) && (pt.y < rc.top + hld.sy2) THEN
' Still mousing over it
			ELSE
' Lost focus
				IF hld.clicked THEN
					hld.txtClr = $$PURPLE
				ELSE
					hld.txtClr = $$BLUE
				END IF

				KillTimer (hWnd, hld.hTimer)
				hld.hTimer = 0
				RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
				InvalidateRect (hWnd, 0, $$TRUE)
				UpdateWindow (hWnd)
      END IF

		CASE $$WM_ENABLE:
			RedrawWindow (hWnd, 0, 0, $$RDW_ERASE OR $$RDW_INVALIDATE OR $$RDW_UPDATENOW OR $$RDW_NOCHILDREN)

    CASE $$WM_SETTEXT:
      ' NEW, not in v.0001: allows dynamically changing the link
      ' must update internally saved size if new text is set
      ' get new text
      text$ = NULL$(256)
			RtlMoveMemory (&text$, lParam, SIZE(text$)) ' lParam has lp to new text
			text$ = CSIZE$ (text$)
			' find size and adjust saved box size
      hDC = GetDC (hWnd)
			hLastFont = SelectObject (hDC, hld.hFont)
			GetTextExtentPoint32A (hDC, &text$, LEN(text$), &sz)
			SelectObject (hDC, hLastFont)
			GetClientRect (hWnd, &rc)
			hld.sx2 = MIN (sz.cx, rc.right)
			hld.sy2 = MIN (sz.cy, rc.bottom)
			hld.sx1 = 0
			hld.sy1 = 0
			ReleaseDC (hWnd, hDC)
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
      ' start gettin' lazy and let the default procedure handle the rest ;-)
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

		CASE $$WM_PAINT:
			text$ = NULL$ (256)
			GetWindowTextA (hWnd, &text$, SIZE (text$))
			text$ = TRIM$ (text$)
			hDC = BeginPaint (hWnd, &ps)
				hLastFont = SelectObject (hDC, hld.hFont)
				GetClientRect (hWnd, &rc)

' draw focus rectangle
				IF hld.tabstop THEN
					IF (hld.style & $$HS_DRAWFOCUSRECT) THEN
						IF hld.focus THEN DrawFocusRect (hDC, &rc)
					END IF
				END IF

				lastMode = SetBkMode (hDC, $$TRANSPARENT)

' if window is enabled, then use normal color
' otherwise use gray for disabled control
				IF IsWindowEnabled (hWnd) THEN
					color = hld.txtClr
				ELSE
					color = GetSysColor ($$COLOR_GRAYTEXT)	' $$DKGRAY
				END IF

' get text rect to draw
				SetRect (&rc, hld.sx1, hld.sy1, hld.sx2, hld.sy2)

' draw text onto control
' check for ReliefText style
				IF hld.style & $$HS_RELIEFTEXT THEN
					SetTextColor (hDC, $$WHITE)
					rect = rc
					OffsetRect (&rect, 1, 1)
					DrawTextA (hDC, &text$, -1, &rect, $$DT_SINGLELINE)
				END IF

				lastColor = SetTextColor (hDC, color)
				DrawTextA (hDC, &text$, -1, &rc, $$DT_SINGLELINE)

				SetTextColor (hDC, lastColor)
				SetBkMode (hDC, lastMode)
				SelectObject (hDC, hLastFont)
			EndPaint (hWnd, &ps)

' Draw the background
		CASE $$WM_ERASEBKGND:
			hDC = wParam
			GetClientRect (hWnd, &rc)
			FillRect (hDC, &rc, hld.hBrush)
			RETURN ($$TRUE)

		CASE $$SET_HYPERLINK_STYLE:
			hld.style = hld.style OR lParam

' check for NoHandCursor style
			IF (hld.style & $$HS_NOHANDCURSOR) THEN hld.hCurHand = hld.hCurArrow

' check for NoUnderline style
			IF (hld.style & $$HS_NOUNDERLINE) THEN
				GetObjectA (hld.hFont, SIZE (lf), &lf)
				DeleteObject (hld.hFont)
      	lf.underline = 0
      	hld.hFont = CreateFontIndirectA (&lf)
			END IF

' check for CenterHorz style
			IF (hld.style & $$HS_CENTERHORZ) THEN
				text$ = NULL$(256)
				GetWindowTextA (hWnd, &text$, SIZE(text$))
				text$ = TRIM$ (text$)
				hDC = GetDC (hWnd)
				hLastFont = SelectObject (hDC, hld.hFont)
				GetTextExtentPoint32A (hDC, &text$, LEN(text$), &sz)
				SelectObject (hDC, hLastFont)
				ReleaseDC (hWnd, hDC)
				GetClientRect (hWnd, &rc)
				w = MIN (sz.cx, rc.right)
				hld.sx1 = (rc.right-rc.left)/2 - w/2
				hld.sx2 = hld.sx1 + w
			END IF

' check for CenterVert style
			IF (hld.style & $$HS_CENTERVERT) THEN
				text$ = NULL$(256)
				GetWindowTextA (hWnd, &text$, SIZE(text$))
				text$ = TRIM$ (text$)
				hDC = GetDC (hWnd)
				hLastFont = SelectObject (hDC, hld.hFont)
				GetTextExtentPoint32A (hDC, &text$, LEN(text$), &sz)
				SelectObject (hDC, hLastFont)
				ReleaseDC (hWnd, hDC)
				GetClientRect (hWnd, &rc)
				h = MIN (sz.cy, rc.bottom)
				hld.sy1 = (rc.bottom-rc.top)/2 - h/2
				hld.sy2 = hld.sy1 + h
			END IF
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
			InvalidateRect (hWnd, 0, $$TRUE) ' v0.0002: new
			UpdateWindow (hWnd)              ' v0.0002: new

		CASE $$SET_HYPERLINK_BKCOLOR:
			IF hld.hBrush THEN DeleteObject (hld.hBrush)
			hld.txtBack  = lParam
			hld.hBrush   = CreateSolidBrush (hld.txtBack)
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
			InvalidateRect (hWnd, 0, $$TRUE) ' v0.0002: new
			UpdateWindow (hWnd)              ' v0.0002: new

		CASE $$WM_SETFOCUS:
			hld.txtClr = $$RED
			hld.focus  = $$TRUE
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
			InvalidateRect (hWnd, 0, $$TRUE)
			UpdateWindow (hWnd)

		CASE $$WM_KILLFOCUS:
			IF hld.clicked THEN
				hld.txtClr = $$PURPLE
			ELSE
				hld.txtClr = $$BLUE
			END IF
			hld.focus = $$FALSE
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
			InvalidateRect (hWnd, 0, $$TRUE)
			UpdateWindow (hWnd)

		CASE $$WM_KEYDOWN:
			virtKey = wParam
			IF virtKey = $$VK_SPACE THEN
				wparam = MAKELONG (GetWindowLongA (hWnd, $$GWL_ID), $$BN_CLICKED)
      	PostMessageA (GetWindowLongA (hWnd, $$GWL_HWNDPARENT), $$WM_COMMAND, wparam, hWnd)
			END IF
			hld.clicked = $$TRUE
			hld.txtClr = $$PURPLE
			RtlMoveMemory (pHyperLinkData, &hld, SIZE(hld))
			InvalidateRect (hWnd, 0, $$TRUE) ' v0.0002: new
			UpdateWindow (hWnd)              ' v0.0002: new

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
'
'
' ########################
' #####  GoToURL ()  #####
' ########################
'
' PURPOSE : launch a url$ in default browser.
' IN			: url$ - url to display.
'					: showcmd - specify how the window is to be shown.
'						use ShowWindow() values such as $$SW_SHOWNORMAL.
' RETURN	: if the function succeeds, the return value is greater than 32.
'
FUNCTION  GoToURL (url$, showcmd)

	IFZ url$ THEN RETURN

	key$ = NULL$ (512)

' First try ShellExecute()
	result = ShellExecuteA (NULL, &"open", &url$, NULL, NULL, showcmd)

' If it failed, get the .htm regkey and lookup the program
	IF (result <= $$HINSTANCE_ERROR) THEN
		IF (GetRegKey ($$HKEY_CLASSES_ROOT, ".htm", @key$) == $$ERROR_SUCCESS) THEN
			key$ = key$ + "\\shell\\open\\command"
			IF (GetRegKey ($$HKEY_CLASSES_ROOT, key$, @path$) == $$ERROR_SUCCESS) THEN
				pos = INSTR (path$, "\"%1\"")						' Look for "%1"
				IFZ pos THEN 														' No quotes found
					pos = INSTR (path$, "%1") 						' Check for %1, without quotes
				END IF
				IF pos THEN path$ = TRIM$ (LEFT$ (path$, pos-1))
				path$ = path$ + " " + url$
				result = WinExec (&path$, showcmd)
			END IF
		END IF
	END IF
	RETURN result

END FUNCTION
'
'
' ##########################
' #####  GetRegKey ()  #####
' ##########################
'
' PURPOSE : Return the data string from a register key/subkey.
' IN			: key - main register key
'					: subkey - subkey string
' OUT			: retdata$ - string value of subkey$
' RETURN	: on success, return value is ERROR_SUCCESS
'
FUNCTION  GetRegKey (key, subkey$, @retdata$)

	retval = RegOpenKeyExA (key, &subkey$, 0, $$KEY_QUERY_VALUE, &hkey)

	IF (retval == $$ERROR_SUCCESS) THEN
		datasize = $$MAX_PATH
		retdata$ = NULL$ ($$MAX_PATH)
		RegQueryValueA (hkey, NULL, &retdata$, &datasize)
		retdata$ = TRIM$ (retdata$)
		RegCloseKey (hkey)
	END IF

	RETURN retval

END FUNCTION
END PROGRAM
