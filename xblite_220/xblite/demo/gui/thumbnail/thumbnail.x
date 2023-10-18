'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo program using the listview control
' to display BMP images as thumbnails.
'
PROGRAM	"thumbnail"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' standard library
	IMPORT  "xsx"
  IMPORT  "xbm"       ' bitmap library
'	IMPORT	"xio"				' console io library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  AddListViewItem (hwndCtl, iItem, text$, iImage, data)
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  GetListViewSelection (lParam, @iItem, @iSubItem)
DECLARE FUNCTION  GetListViewItemText (hwndCtl, iItem, iSubItem, @text$)
DECLARE FUNCTION  DrawThumbnails (hListView, hImageList, @files$[], thumbWidth, thumbHeight, borderStyle)
DECLARE FUNCTION  GetListViewMultiSelection (hListView, @index[])

' Control ID constants
$$ListView1 = 101

$$Menu_File_Exit = 110
$$Border_Turn_Off = 111
$$Border_Turn_On = 112

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

'	XioCreateConsole (title$, 200)	' create console, if console is not wanted, comment out this line
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

  LV_KEYDOWN lvkd
  LV_HITTESTINFO htinfo
  SHARED files$[]
  STATIC fStyle
  STATIC hMenuS
  STATIC thumbWidth, thumbHeight

	SELECT CASE msg
	
    CASE $$WM_CREATE :
' create List View control
'    style = $$LVS_SINGLESEL | $$LVS_SHOWSELALWAYS | $$LVS_ALIGNLEFT | $$WS_BORDER | $$WS_TABSTOP
      style = $$LVS_SHOWSELALWAYS | $$LVS_ALIGNLEFT | $$WS_BORDER | $$WS_TABSTOP
      #hListView = NewChild ($$WC_LISTVIEW, "", style, 0, 0, 0, 0, hWnd, $$ListView1, $$WS_EX_CLIENTEDGE)

' create an image list using images of 100 x 100 each, 24-bit color
' with 0 initial images and 1 image growth.
      thumbWidth = 100
      thumbHeight = 100
      #hImageList = ImageList_Create (thumbWidth, thumbHeight, $$ILC_COLOR24, 0, 1)

' assign image list to listview control
      SendMessageA (#hListView, $$LVM_SETIMAGELIST, $$LVSIL_NORMAL, #hImageList)

' get a list of BMP files to display as thumbnail images
      XstFindFiles ("c:/xblite/images/", "*.bmp", 0, @files$[])
      IFZ files$[] THEN RETURN

' draw thumbnail images in list control
      DrawThumbnails (#hListView, #hImageList, @files$[], thumbWidth, thumbHeight, fStyle)

' set focus to listview control
      SetFocus (#hListView)

' initialize menu selection
      hMenu = GetMenu (hWnd)
			hMenuS = GetSubMenu (hMenu, 1)														' menu index is 0 based
			item = 0
			CheckMenuRadioItem (hMenuS, 0, 1, item, $$MF_BYPOSITION)	' item index is 0 based
			fStyle = 0

		CASE $$WM_DESTROY :
			PostQuitMessage(0)
			
    CASE $$WM_CONTEXTMENU :
      hCtl = wParam
      xPos = LOWORD(lParam)
      yPos = HIWORD(lParam)
      msg$ = "Right mouse button clicked"
      MessageBoxA (hWnd, &msg$, &"Thumbnail Demo", 0)
      SetFocus (hCtl)

		CASE $$WM_NOTIFY :
			idCtrl = wParam
			SELECT CASE idCtrl
				CASE $$ListView1 :
					GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
					SELECT CASE code :

'						CASE $$NM_CLICK :
'							MessageBoxA (hWnd, &"Single click selection", &"Thumbnail Demo", 0)

'						CASE $$NM_RETURN :
'							MessageBoxA (hWnd, &"Return key pressed", &"Thumbnail Demo", 0)
							
						CASE $$LVN_KEYDOWN :
						  RtlMoveMemory (&lvkd, lParam, SIZE (lvkd))
						  virtualKey = lvkd.wVKey
              msg$ = ""
						  SELECT CASE virtualKey
						    CASE $$VK_RETURN : msg$ = "Return key pressed"
						    CASE $$VK_DELETE : msg$ = "Delete key pressed"
						    CASE $$VK_TAB    : msg$ = "Tab key pressed"
						  END SELECT
							IF msg$ THEN MessageBoxA (hWnd, &msg$, &"Thumbnail Demo", 0)

						CASE $$LVN_ITEMCHANGED :
								IFT GetListViewSelection (lParam, @iItem, @iSubItem) THEN
									GetListViewItemText (#hListView, iItem, iSubItem, @text$)
									msg$ = "ListView Selection"
									msg$ = msg$ + "\nItem index: " + STRING$(iItem)
									msg$ = msg$ + "\nText: " + text$
									MessageBoxA (hWnd, &msg$, &"Thumbnail Demo", 0)
								END IF
					END SELECT
			END SELECT
			SetFocus (#hListView)

		CASE $$WM_SIZE :
			' make the listview control the size of the window's client area
			MoveWindow (#hListView, 0, 0, LOWORD(lParam), HIWORD(lParam), $$TRUE)
			
		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE id
				CASE $$Menu_File_Exit  : DestroyWindow (hWnd)
				CASE $$Border_Turn_Off :
					fStyle = 0
					CheckMenuRadioItem (hMenuS, 0, 1, 0, $$MF_BYPOSITION)
					DrawThumbnails (#hListView, #hImageList, @files$[], thumbWidth, thumbHeight, fStyle)

				CASE $$Border_Turn_On :
					fStyle = $$EDGE_BUMP
					CheckMenuRadioItem (hMenuS, 0, 1, 1, $$MF_BYPOSITION)
					DrawThumbnails (#hListView, #hImageList, @files$[], thumbWidth, thumbHeight, fStyle)
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

	RECT rc
	SHARED className$

' register window class
	className$  = "ThumbnailDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "menu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Thumbnail Demo"
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 640
	h 					= 210
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
' ################################
' #####  AddListViewItem ()  #####
' ################################
'
FUNCTION  AddListViewItem (hwndCtl, iItem, text$, iImage, data)

	LV_ITEM lvi

	lvi.mask = $$LVIF_TEXT | $$LVIF_IMAGE | $$LVIF_PARAM | $$LVIF_STATE
	lvi.state = 0
	lvi.stateMask = 0
	lvi.iItem = iItem
	lvi.pszText = &text$
	lvi.cchTextMax = LEN(text$)
	lvi.iImage = iImage
	lvi.iSubItem = 0
	lvi.lParam = data

	RETURN SendMessageA (hwndCtl, $$LVM_INSERTITEM, 0, &lvi)

END FUNCTION
'
'
' #############################
' #####  GetNotifyMsg ()  #####
' #############################
'
FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

	NMHDR nmhdr

	nmhdrAddr = lParam
'	XstCopyMemory (nmhdrAddr, &nmhdr, SIZE(nmhdr))	'Xst library function
	RtlMoveMemory (&nmhdr, nmhdrAddr, SIZE(nmhdr))	'kernel32 library function
	hwndFrom = nmhdr.hwndFrom
	idFrom   = nmhdr.idFrom
	code     = nmhdr.code

END FUNCTION
'
'
' #####################################
' #####  GetListViewSelection ()  #####
' #####################################
'
FUNCTION  GetListViewSelection (lParam, @iItem, @iSubItem)

	NM_LISTVIEW nmlv

	nmlvAddr = lParam
'	XstCopyMemory (nmlvAddr, &nmlv, SIZE(nmlv))	'Xst library function
	RtlMoveMemory (&nmlv, nmlvAddr, SIZE(nmlv))	'kernel32 library function

	IF (nmlv.uOldState & $$LVIS_SELECTED) == 0 && (nmlv.uNewState & $$LVIS_SELECTED) == $$LVIS_SELECTED THEN
		iItem = nmlv.iItem
		iSubItem = nmlv.iSubItem
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF

END FUNCTION
'
'
' ####################################
' #####  GetListViewItemText ()  #####
' ####################################
'
FUNCTION  GetListViewItemText (hwndCtl, iItem, iSubItem, @text$)

	LV_ITEM lvi

	lvi.iSubItem 		= iSubItem
	text$ 					= NULL$(256)
	lvi.cchTextMax 	= LEN(text$)
	lvi.pszText 		= &text$
	SendMessageA (hwndCtl, $$LVM_GETITEMTEXT, iItem, &lvi)
	text$ = CSIZE$(text$)


END FUNCTION
'
'
' ###############################
' #####  DrawThumbnails ()  #####
' ###############################
'
' Draw thumbnail images in a listview control
' with associated imagelist. 
'
' Border styles:
' $$EDGE_RAISED
' $$EDGE_SUNKEN
' $$EDGE_ETCHED
' $$EDGE_BUMP
'
FUNCTION  DrawThumbnails (hListView, hImageList, @files$[], thumbWidth, thumbHeight, borderStyle)

  UBYTE image[]
  POINT pt
  RECT rc
  
  IFZ hListView THEN RETURN
  IFZ hImageList THEN RETURN
  IFZ files$[] THEN RETURN
  IFZ thumbWidth THEN thumbWidth = 100
  IFZ thumbHeight THEN thumbHeight = 100
  
' set the length of the space between thumbnails
' you can also calculate and set it based on the length of your list control
	nGap = 10

' hold the window update to avoid flicking
  SendMessageA (hListView, $$WM_SETREDRAW, 0, 0)

' reset our image list by removing all images
  ImageList_Remove (hImageList, -1)

' remove all items from list view
  IF SendMessageA (hListView, $$LVM_GETITEMCOUNT, 0, 0) THEN
    SendMessageA (hListView, $$LVM_DELETEALLITEMS, 0, 0)
	END IF
	
' get number of files
  upp = UBOUND (files$[])

' set the size of the image list
  ImageList_SetImageCount (hImageList, upp+1)
  
  bw = 0
  IF borderStyle THEN
    SELECT CASE borderStyle
      CASE $$EDGE_RAISED, $$EDGE_SUNKEN, $$EDGE_ETCHED, $$EDGE_BUMP :
      CASE ELSE : borderStyle = $$EDGE_BUMP
    END SELECT
		bw = 2
    thumbWidth = thumbWidth - bw - bw
    thumbHeight = thumbHeight - bw - bw
  END IF

' draw the thumbnails
  FOR i = 0 TO upp

' load the bitmap
		IFZ XbmLoadImage (files$[i], @image[]) THEN DO NEXT

' get size of image
    XbmGetImageArrayInfo (@image[], @bpp, @width, @height)

' create a bitmap object
		XbmCreateMemBitmap (hListView, width, height, @hImage)

' set image[] array in bitmap object
    XbmSetImage (hImage, @image[])

' create a thumbnail bitmap
		XbmCreateMemBitmap (hListView, thumbWidth+bw+bw, thumbHeight+bw+bw, @hThumb)

' fill thumbnail bitmap with solid white color
		wndDC 		= GetDC (hListView)
		hdc 			= CreateCompatibleDC (wndDC)
		hOldObj   = SelectObject (hdc, hThumb)
    hBrush    = CreateSolidBrush (RGB(255, 255, 255))
    hOldBrush = SelectObject (hdc, hBrush)
    PatBlt (hdc, 0, 0, thumbWidth+bw+bw, thumbHeight+bw+bw, $$PATCOPY)
    SelectObject (hdc, hOldBrush)
    DeleteObject (hBrush)

' draw a border
    IF borderStyle THEN
      rc.right 	= thumbWidth + bw + bw
		  rc.bottom = thumbHeight + bw + bw
		  DrawEdge (hdc, &rc, borderStyle, $$BF_RECT)
    END IF

' clean up
    SelectObject (hdc, hOldObj)
    DeleteDC (hdc)
    ReleaseDC (hListView, wndDC)

' copy image to thumb
' scale proportionally if necessary
' center it if necessary
    IF (width >= thumbWidth) || (height >= thumbHeight) THEN
      scale# = width/DOUBLE (height)
      IF width >= height THEN
        dx1 = bw
        dx2 = bw + thumbWidth    ' -1
      ELSE
        tw = scale# * thumbHeight
        dx1 = bw + (thumbWidth - tw)/2
        dx2 = dx1 + tw
      END IF
      IF height >= width THEN
        dy1 = bw
        dy2 = bw + thumbHeight   '-1
      ELSE
        th = thumbWidth / scale#
        dy1 = bw + ((thumbHeight - th)/2)
        dy2 = dy1 + th
      END IF
    ELSE
      dx1 = (thumbWidth - width)/2
      dx2 = dx1 + width
      dy1 = (thumbHeight - height)/2
      dy2 = dy1 + height
    END IF

    ret = XbmDrawImageEx (hThumb, hImage, 0, 0, -1, -1, dx1, dy1, dx2, dy2, fRop, orient)

' add thumb bitmap to our image list
    ret = ImageList_Replace (hImageList, i, hThumb, NULL)

' add item to ListView control
' set the image file name as item text
    XstGetPathComponents (files$[i], @path$, @drive$, @dir$, @filename$, @attributes)
		ret = AddListViewItem (hListView, i, filename$, i, data)

' get current item position
'    SendMessageA (hListView, $$LVM_GETITEMPOSITION, i, &pt)
	  
' shift the thumbnail to desired position
'    thumbWidth = 100
    pt.x = nGap + i*(thumbWidth + bw + bw + nGap)
    pt.y = nGap
    pos = MAKELONG (pt.x, pt.y)
    SendMessageA (hListView, $$LVM_SETITEMPOSITION, i, pos)

		IF hImage THEN XbmDeleteMemBitmap (hImage)
		IF hThumb THEN XbmDeleteMemBitmap (hImage)
		DIM image[]
  NEXT i

' draw the thumbnails in the window
  SendMessageA (hListView, $$WM_SETREDRAW, 1, 0)

END FUNCTION
'
'
' ##########################################
' #####  GetListViewMultiSelection ()  #####
' ##########################################
'
' Return index array of selected items in ListView control.
' Function returns -1 on error or else the number of items selected.
'
FUNCTION  GetListViewMultiSelection (hListView, @index[])

  IFZ hListView THEN RETURN ($$TRUE)
  DIM index[]
  index = -1
  count = SendMessageA (hListView, $$LVM_GETSELECTEDCOUNT, 0, 0)
  IFZ count THEN RETURN

  DIM index[count-1]
  c = 0
	DO
		index = SendMessageA (hListView, $$LVM_GETNEXTITEM, index, MAKELONG ($$LVNI_SELECTED, 0))
		IF index = -1 THEN EXIT DO
		index[c] = index
		INC c
	LOOP
  RETURN c

END FUNCTION
END PROGRAM
