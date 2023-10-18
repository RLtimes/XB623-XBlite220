'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo showing how to implement an
' owner-drawn control "combocolor".
' The color-pick combobox is created
' by using a subclassed, owner-drawn
' combobox control.
' Based on PB demo by Borje Hagsten.
'
PROGRAM	"combocolor"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"
	IMPORT  "comdlg32"	' comdlg32.dll

TYPE CBCOLORDATA
	XLONG	.oldProc
	XLONG	.autoColor
	XLONG	.userColor
	XLONG	.cols[15]
END TYPE

DECLARE FUNCTION  Entry ()
INTERNAL FUNCTION  CBProc (hWnd, msg, wParam, lParam)
EXPORT
DECLARE FUNCTION  CreateComboColor (hWnd, ctrlId, left, top, width, height, autoCol, userCol)
END EXPORT
INTERNAL FUNCTION  GetQBColor (hWnd, c, dlg)

$$CBCOLORDATAPTR = "CBCOLORDATAPTR"

EXPORT

$$CBCOL_SETAUTOCOLOR = 1124
$$CBCOL_SETUSERCOLOR = 1125
$$CBCOL_GETAUTOCOLOR = 1224
$$CBCOL_GETUSERCOLOR = 1225
$$CBCOL_GETSELCOLOR  = 1226   ' wParam is $$TRUE to show ColorDialog on user color

END EXPORT
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()


END FUNCTION
'
'
' #######################
' #####  CBProc ()  #####
' #######################
'
FUNCTION  CBProc (hWnd, msg, wParam, lParam)

	CBCOLORDATA cbc
	DRAWITEMSTRUCT dis
	RECT rc

' get stored data address
	cbcAddr = GetPropA (hWnd, &$$CBCOLORDATAPTR)

' get data
	RtlMoveMemory (&cbc, cbcAddr, SIZE(cbc))

	SELECT CASE msg
		CASE $$CBCOL_SETAUTOCOLOR :
			cbc.autoColor = wParam   														' allows programmer to change auto color
			RtlMoveMemory (cbcAddr, &cbc, SIZE(cbc))
			RETURN

		CASE $$CBCOL_SETUSERCOLOR :
			cbc.userColor = wParam   														' allows programmer to change user selected color
			RtlMoveMemory (cbcAddr, &cbc, SIZE(cbc))
			RETURN

		CASE $$CBCOL_GETAUTOCOLOR : RETURN cbc.autoColor 			' allows programmer to get selected auto color
		CASE $$CBCOL_GETUSERCOLOR : RETURN cbc.userColor 			' allows programmer to get selected user color
		CASE $$CBCOL_GETSELCOLOR  :  													' return selected color
			lRes = SendMessageA (hWnd, $$CB_GETCURSEL, 0, 0)
			IF lRes > $$CB_ERR THEN RETURN GetQBColor (hWnd, lRes, wParam)

		CASE $$WM_DESTROY : 																	' un-subclass combobox
			IF cbc.oldProc THEN SetWindowLongA (hWnd, $$GWL_WNDPROC, cbc.oldProc)
			IF cbcAddr THEN HeapFree (GetProcessHeap(), 0, cbcAddr)
			RemovePropA (hWnd, &$$CBCOLORDATAPTR)
			RETURN

		CASE $$WM_DRAWITEM :
			RtlMoveMemory (&dis, lParam, SIZE(dis))

			IF dis.itemID = 0xFFFFFFFF THEN RETURN

			SELECT CASE dis.itemAction
				CASE $$ODA_DRAWENTIRE, $$ODA_SELECT :
					' CLEAR BACKGROUND
					FillRect (dis.hDC, &dis.rcItem, GetSysColorBrush ($$COLOR_WINDOW))

					' GET/DRAW TEXT
					txt$ = NULL$ (80)
					SendMessageA (hWnd, $$CB_GETLBTEXT, dis.itemID, &txt$) 			' get text
					txt$ = TRIM$ (txt$)

					rc = dis.rcItem

					rc.left = 28
					SetBkColor (dis.hDC, GetSysColor ($$COLOR_WINDOW))   				' set text background
					SetTextColor (dis.hDC, GetSysColor ($$COLOR_WINDOWTEXT)) 		' set text color
					DrawTextA (dis.hDC, &txt$, LEN(txt$), &rc, $$DT_SINGLELINE | $$DT_LEFT | $$DT_VCENTER)

					' SELECTED ITEM
					IF (dis.itemState AND $$ODS_SELECTED) THEN      	' if selected
						IFZ (dis.itemState AND 0x1000) THEN      				' if not $$ODS_COMBOBOXEDIT (= 0x1000)
							FillRect (dis.hDC, &dis.rcItem, GetSysColorBrush ($$COLOR_HIGHLIGHT))
							rc.left = 28
							SetBkColor (dis.hDC, GetSysColor ($$COLOR_HIGHLIGHT))   				' set text background
							SetTextColor (dis.hDC, GetSysColor ($$COLOR_HIGHLIGHTTEXT)) 		' set text color
							DrawTextA (dis.hDC, &txt$, LEN(txt$), &rc, $$DT_SINGLELINE | $$DT_LEFT | $$DT_VCENTER)
						END IF
						SetTextColor (dis.hDC, GetSysColor ($$COLOR_WINDOWTEXT))
						DrawFocusRect (dis.hDC, &dis.rcItem)  											' and draw a focus rectangle around all
					END IF

					' PAINT COLOR RECTANGLE (using RoundRect for nicer looks.. :-)
					IF (dis.itemState AND 0x1000) THEN             		' if $$ODS_COMBOBOXEDIT (= 0x1000)
						rc.left = 4 : rc.right = 24              				' set coordinates
					ELSE
						rc.left = 3 : rc.right = 23              				' a tiny bit to the left in list..
					END IF
					rc.top    = dis.rcItem.top + 2
					rc.bottom = dis.rcItem.bottom - 2

					hBrush = CreateSolidBrush (GetQBColor (hWnd, dis.itemID, 0)) 			' create brush with proper color
					hOldBrush = SelectObject (dis.hDC, hBrush)         								' select brush into device context
					RoundRect (dis.hDC, rc.left, rc.top, rc.right, rc.bottom, 3, 3) 	' draw rectangle
					DeleteObject (SelectObject (dis.hDC, hOldBrush))     							' select old brush back and delete new one

			END SELECT
			RETURN ($$TRUE)

  END SELECT

  RETURN CallWindowProcA (cbc.oldProc, hWnd, msg, wParam, lParam) 			' pass on for processing in oldProc

END FUNCTION
'
'
' ###########################
' #####  GetQBColor ()  #####
' ###########################
'
FUNCTION  GetQBColor (hWnd, c, dlg)

	CBCOLORDATA cbc
	CHOOSECOLOR cc

	cbcAddr = GetPropA (hWnd, &$$CBCOLORDATAPTR)
	RtlMoveMemory (&cbc, cbcAddr, SIZE(cbc))

	SELECT CASE c
		CASE  0 : RETURN cbc.autoColor    ' pre-set system color, like %COLOR_WINDOW or %COLOR_WINDOWTEXT
		CASE  1 : RETURN RGB(0,0,0)       ' Black
		CASE  2 : RETURN RGB(0,0,128)     ' Blue
		CASE  3 : RETURN RGB(0,128,0)     ' Green
		CASE  4 : RETURN RGB(0,128,128)   ' Cyan
		CASE  5 : RETURN RGB(196,0,0)     ' Red
		CASE  6 : RETURN RGB(128,0,128)   ' Magenta
		CASE  7 : RETURN RGB(128,64,0)    ' Brown
		CASE  8 : RETURN RGB(196,196,196) ' Light Gray
		CASE  9 : RETURN RGB(128,128,128) ' Gray
		CASE 10 : RETURN RGB(0,0,255)     ' Light Blue
		CASE 11 : RETURN RGB(0,255,0)     ' Light Green
		CASE 12 : RETURN RGB(0,255,255)   ' Light Cyan
		CASE 13 : RETURN RGB(255,0,0)     ' Light Red
		CASE 14 : RETURN RGB(255,0,255)   ' Light Magenta
		CASE 15 : RETURN RGB(255,255,0)   ' Yellow
		CASE 16 : RETURN RGB(255,255,255) ' Bright White
		CASE 17 :
			IF dlg THEN                                      	' show COMDLG32's color selection dialog..
				cc.lStructSize  = SIZE(cc)                  		' fill structure..
				cc.lpCustColors = &cbc.cols[0]        					' pointer to defined custom color array (a must, otherwise GPF..)
				cc.flags        = $$CC_RGBINIT | $$CC_FULLOPEN 	' show entire dialog
				cc.hwndOwner    = hWnd                        	' best if control is owner, or..?
				cc.rgbResult    = cbc.userColor              		' give dialog chance to "auto-select" previously selected color
                                                     		' (only works for base colors, but still better than nothing..)
				cc.hInstance    = GetWindowLongA (GetParent (hWnd), $$GWL_HINSTANCE)

				IF ChooseColorA (&cc) THEN
					cbc.userColor = cc.rgbResult  								' otherwise userColor is same as before
					RtlMoveMemory (cbcAddr, &cbc, SIZE(cbc))
				END IF
			END IF
			RETURN cbc.userColor                        			' return user-selected color
	END SELECT



END FUNCTION
'
'
' #################################
' #####  CreateComboColor ()  #####
' #################################
'
FUNCTION  CreateComboColor (hWnd, ctrlId, left, top, width, height, autoCol, userCol)

	CBCOLORDATA cbc
	STRING arr[]

	DIM arr[17]

' create items for combo list
  arr[0]  = "Auto"          : arr[1]  = "Black"
  arr[2]  = "Blue"          : arr[3]  = "Green"
  arr[4]  = "Cyan"          : arr[5]  = "Red"
  arr[6]  = "Magenta"       : arr[7]  = "Brown"
  arr[8]  = "Light Gray"    : arr[9]  = "Gray"
  arr[10] = "Light Blue"    : arr[11] = "Light Green"
  arr[12] = "Light Cyan"    : arr[13] = "Light Red"
  arr[14] = "Light Magenta" : arr[15] = "Yellow"
  arr[16] = "Bright White"  : arr[17] = "User-selected.."

	hCombo = CreateWindowExA ($$WS_EX_CLIENTEDGE, &"COMBOBOX", 0, $$WS_VISIBLE | $$WS_CHILD | $$WS_VISIBLE | $$CBS_OWNERDRAWFIXED | $$CBS_HASSTRINGS | $$CBS_DROPDOWNLIST | $$WS_TABSTOP | $$CBS_DISABLENOSCROLL | $$WS_VSCROLL, left, top, width, height, hWnd, ctrlId, GetWindowLongA (hWnd, $$GWL_HINSTANCE), 0)

' add items to combo list
	IF hCombo THEN
		FOR i = 0 TO UBOUND(arr[])
			SendMessageA (hCombo, $$CB_ADDSTRING, 0, &arr[i])
		NEXT i
	END IF

' return 0 to indicate failure
  IFZ hCombo THEN RETURN

	cbcAddr = HeapAlloc (GetProcessHeap(), $$HEAP_ZERO_MEMORY, SIZE(cbc))

'sub-class the combo and initialize some control specific data
  IF cbcAddr THEN
		cbc.oldProc   = SetWindowLongA (hCombo, $$GWL_WNDPROC, &CBProc())
		cbc.autoColor = autoCol 		' usually $$COLOR_WINDOW or $$COLOR_WINDOWTEXT
		cbc.userColor = userCol 		' same here

		FOR i = 1 TO 16                        	' create initial grayscale color map for
			cl = i * 16 - 1                     	' COMDLG32's extra colors in ChooseColor dialog
			cbc.cols[16 - i] = RGB (cl, cl, cl) 	' note: array is static, but still local to each created control..
		NEXT

		SetPropA (hCombo, &$$CBCOLORDATAPTR, cbcAddr)   ' store pointer to memory for UDT in control's property list
		RtlMoveMemory (cbcAddr, &cbc, SIZE(cbc))				' move data into memory address
  ELSE
		RETURN                         					' return 0 to indicate failure
  END IF

  RETURN hCombo                         		' return handle to indicate success

END FUNCTION
END PROGRAM
