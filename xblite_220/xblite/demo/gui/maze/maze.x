'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo which draws mazes from one of
' three different maze generators. The
' maze solution can also be generated and
' displayed.
' Maze image can be saved to disk as BMP file.
'
PROGRAM	"maze"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"
	IMPORT  "comdlg32"	' comdlg32.dll
	IMPORT	"msvcrt"

TYPE MOVE_LIST
	USHORT	.x
	USHORT	.y
	UBYTE		.dir
	UBYTE		.ways
END TYPE

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  CreateScreenBuffer (hWnd, w, h)
DECLARE FUNCTION  DeleteScreenBuffer (hdcMem)
DECLARE FUNCTION  ShowSaveFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)
DECLARE FUNCTION  SaveMemAsBMP (file$, hdcMem)
DECLARE FUNCTION  get_random (x)
DECLARE FUNCTION  set_maze_sizes (width, height)
DECLARE FUNCTION  set_grid_size (size)
DECLARE FUNCTION  initialize_maze (gridSize, w, h)
DECLARE FUNCTION  ClearScreenBuffer (hdcMem)
DECLARE FUNCTION  draw_maze_border (hdcMem)
DECLARE FUNCTION  Line (hdc, color, x1, y1, x2, y2)
DECLARE FUNCTION  draw_solid_square (hdcMem, i, j, dir, gc)
DECLARE FUNCTION  FillRectangle (hdc, color, x, y, width, height)
DECLARE FUNCTION  create_maze (hdcMem)
DECLARE FUNCTION  choose_door (hdcMem)
DECLARE FUNCTION  backup ()
DECLARE FUNCTION  draw_wall (hdcMem, i, j, dir, gc)
DECLARE FUNCTION  alt_create_maze (hdcMem)
DECLARE FUNCTION  build_wall (hdcMem, i, j, dir)
DECLARE FUNCTION  UpdateMaze (hWnd, hdcMem, gridSize, w, h, generator)
DECLARE FUNCTION  solve_maze (hdcMem)
DECLARE FUNCTION  info_maze ()
DECLARE FUNCTION  longdeadend_p (hdcMem, x1, y1, x2, y2, endwall)
DECLARE FUNCTION  find_dead_regions (hdcMem)
DECLARE FUNCTION  paint_maze (hdcMem)
DECLARE FUNCTION  check_events ()
DECLARE FUNCTION  set_create_maze (hdcMem)
DECLARE FUNCTION  init_sets ()
DECLARE FUNCTION  get_set (num)
DECLARE FUNCTION  join_sets (num1, num2)
DECLARE FUNCTION  create_walk_maze (hdcMem)
DECLARE FUNCTION  create_walk_maze2 (hdcMem)

' Menubar control IDs
$$ID_DRAW_MAZE				= 101
$$ID_SOLVE_MAZE				= 104
$$ID_SAVE_AS_BMP			= 102
$$ID_FILE_EXIT				= 103

$$ID_GEN_A						= 118
$$ID_GEN_B						= 119
$$ID_GEN_C						= 120
$$ID_GEN_D						= 121

$$ID_SIZE_256					= 130
$$ID_SIZE_512					= 131


$$MAX_MAZE_SIZE_X	= 1000
$$MAX_MAZE_SIZE_Y	= 1000

$$MOVE_LIST_SIZE  = 1000000	'(MAX_MAZE_SIZE_X * MAX_MAZE_SIZE_Y)

$$NOT_DEAD	      = 0x8000
$$SOLVER_VISIT    = 0x4000
$$START_SQUARE	  = 0x2000
$$END_SQUARE	    = 0x1000

$$WALL_TOP	      = 0x8
$$WALL_RIGHT	    = 0x4
$$WALL_BOTTOM	    = 0x2
$$WALL_LEFT	      = 0x1
$$WALL_ANY	      = 0xF

$$DOOR_IN_TOP	    = 0x800
$$DOOR_IN_RIGHT	  = 0x400
$$DOOR_IN_BOTTOM	= 0x200
$$DOOR_IN_LEFT	  = 0x100
$$DOOR_IN_ANY	    = 0xF00

$$DOOR_OUT_TOP	  = 0x80
$$DOOR_OUT_RIGHT	= 0x40
$$DOOR_OUT_BOTTOM	= 0x20
$$DOOR_OUT_LEFT	  = 0x10
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

	PAINTSTRUCT ps
	RECT rect
	STATIC generator
	STATIC hMenuS, hMenuI
	STATIC hdcMem
	STATIC w, h
	STATIC imageSize
	SHARED maze_size_x, maze_size_y
	SHARED grid_width
	STATIC gridSize
	STATIC minimized

	SELECT CASE msg

		CASE $$WM_CREATE:
			hMenu = GetMenu (hWnd)
			hMenuS = GetSubMenu (hMenu, 1)														' menu index is 0 based
			item = 0
			CheckMenuRadioItem (hMenuS, 0, 3, item, $$MF_BYPOSITION)	' item index is 0 based
			generator = 0

			hMenuI = GetSubMenu (hMenu, 2)														' menu index is 0 based
			item = 0
			CheckMenuRadioItem (hMenuI, 0, 1, item, $$MF_BYPOSITION)	' item index is 0 based
			imageSize = 256

			gridSize = 8				' set maze grid size
			#screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
			#screenHeight = GetSystemMetrics ($$SM_CYSCREEN)

		CASE $$WM_PAINT :
			hdc = BeginPaint (hWnd, &ps)
			BitBlt (hdc, ps.left, ps.top, ps.right-ps.left, ps.bottom-ps.top, hdcMem, ps.left, ps.top, $$SRCCOPY)
			EndPaint (hWnd, &ps)

		CASE $$WM_SIZE:
			sizeType = wParam

			SELECT CASE sizeType

				CASE $$SIZE_RESTORED, $$SIZE_MAXIMIZED :
					IF minimized THEN
						minimized = $$FALSE
					ELSE
						IF hdcMem THEN DeleteScreenBuffer (hdcMem)
						w = LOWORD (lParam)
						h = HIWORD (lParam)
						hdcMem = CreateScreenBuffer (hWnd, w, h)
						UpdateMaze (hWnd, hdcMem, gridSize, w, h, generator)
						text$ = "Maze : w=" + STRING$(maze_size_x*grid_width) + " h=" + STRING$(maze_size_y*grid_width)
						SetWindowTextA (hWnd, &text$)
					END IF

				CASE $$SIZE_MINIMIZED	: minimized = $$TRUE
			END SELECT

		CASE $$WM_DESTROY:
			DeleteScreenBuffer (hdcMem)
			PostQuitMessage(0)

		CASE $$WM_COMMAND:
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE id
				CASE $$ID_DRAW_MAZE :
					UpdateMaze (hWnd, hdcMem, gridSize, w, h, generator)

				CASE $$ID_SOLVE_MAZE :
					hdc = GetDC (hWnd)
					solve_maze (hdcMem)

				CASE $$ID_SAVE_AS_BMP :
					filter$ = "BMP Files (*.bmp)" + CHR$(0) + "*.bmp" + CHR$(0) + "All Files (*.*)" + CHR$(0) + "*.*" + CHR$(0)
					title$ = "Save BMP image as"
					ShowSaveFileDialog (hWnd, @file$, filter$, initDir$, title$)
					ret = SaveMemAsBMP (file$, hdcMem)

				CASE $$ID_FILE_EXIT :		DestroyWindow (hWnd)

				CASE $$ID_GEN_A :
					generator = 0
					CheckMenuRadioItem (hMenuS, 0, 3, 0, $$MF_BYPOSITION)
					UpdateMaze (hWnd, hdcMem, gridSize, w, h, generator)

				CASE $$ID_GEN_B :
					generator = 1
					CheckMenuRadioItem (hMenuS, 0, 3, 1, $$MF_BYPOSITION)
					UpdateMaze (hWnd, hdcMem, gridSize, w, h, generator)

				CASE $$ID_GEN_C :
					generator = 2
					CheckMenuRadioItem (hMenuS, 0, 3, 2, $$MF_BYPOSITION)
					UpdateMaze (hWnd, hdcMem, gridSize, w, h, generator)

				CASE $$ID_GEN_D :
					generator = 3
					CheckMenuRadioItem (hMenuS, 0, 3, 3, $$MF_BYPOSITION)
					UpdateMaze (hWnd, hdcMem, gridSize, w, h, generator)

				CASE $$ID_SIZE_256 :
					imageSize = 256
					CheckMenuRadioItem (hMenuI, 0, 1, 0, $$MF_BYPOSITION)
					x = (#screenWidth - (imageSize+8))/2
					y = (#screenHeight - (imageSize + 46))/2
					SetWindowPos (hWnd, 0, x, y, imageSize+8, imageSize+46, $$SWP_NOZORDER)

				CASE $$ID_SIZE_512 :
					imageSize = 512
					CheckMenuRadioItem (hMenuI, 0, 1, 1, $$MF_BYPOSITION)
					x = (#screenWidth - (imageSize+8))/2
					y = (#screenHeight - (imageSize + 46))/2
					SetWindowPos (hWnd, 0, x, y, imageSize+8, imageSize+46, $$SWP_NOZORDER)
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

	SHARED className$

' register window class
	className$  = "MoireDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "menu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Moire pattern demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 264
	h 					= 302
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	UpdateWindow (#winMain)
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

	style = style | $$WS_CHILD
	hwnd = CreateWindowExA (0, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)
	ShowWindow (hwnd, $$SW_SHOWNORMAL)
	RETURN hwnd

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

	MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, 0, 0, 0)			' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
  			TranslateMessage (&msg)						' translate virtual-key messages into character messages
  			DispatchMessageA (&msg)						' send message to window callback function WndProc()
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
' ###################################
' #####  CreateScreenBuffer ()  #####
' ###################################
'
FUNCTION  CreateScreenBuffer (hWnd, w, h)

	hDC 		= GetDC (hWnd)
	memDC 	= CreateCompatibleDC (hDC)
	hBit 		= CreateCompatibleBitmap (hDC, w, h)
	SelectObject (memDC, hBit)
	hBrush 	= GetStockObject ($$BLACK_BRUSH)
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
' ###################################
' #####  ShowSaveFileDialog ()  #####
' ###################################
'
FUNCTION  ShowSaveFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)

	OPENFILENAME ofn
	SHARED hInst

	ofn.lStructSize = LEN(ofn)			'set length of struct
	ofn.hwndOwner 	= hWndOwner			'set parent window handle
	ofn.hInstance 	= hInst					'set the application's instance

'select a filter
'pstrFilter points to a buffer containing pairs of null-terminated
'filter strings. The first string in each pair describes a filter
'(for example, "Text Files"), and the second specifies the
'filter pattern (for example, "*.TXT"). Multiple filters can be
'specified for a single item by separating the filter pattern strings
'with a semicolon (for example, "*.TXT;*.DOC;*.BAK"). The last string
'in the buffer must be terminated by two NULL characters. If this member
'is NULL, the dialog box will not display any filters.
'The filter strings are assumed to be in the proper order - the
'operating system does not change the order.

'	filter$ = "XB Files (*.x, *.dec)" + CHR$(0) + "*.x;*.dec" + CHR$(0) + "Text Files (*.txt)" + CHR$(0) + "*.txt" + CHR$(0) + "All Files (*.*)" + CHR$(0) + "*.*" + CHR$(0) + CHR$(0)
	ofn.lpstrFilter = &filter$

'create a buffer for the returned file
	IF fileName$ = "" THEN
		fileName$ = SPACE$(254)
	ELSE
		fileName$ = fileName$ + SPACE$(254 - LEN(fileName$))
	END IF
	ofn.lpstrFile 			= &fileName$

	ofn.nMaxFile 				= 255					'set the maximum length of a returned file
	buffer2$ = SPACE$(254)
	ofn.lpstrFileTitle 	= &buffer2$		'Create a buffer for the file title
	ofn.nMaxFileTitle 	= 255					'Set the maximum length of a returned file title
	ofn.lpstrInitialDir = &initDir$		'Set the initial directory
  ofn.lpstrTitle 			= &title$			'Set the title
  ofn.flags = $$OFN_PATHMUSTEXIST OR $$OFN_EXPLORER	'flags

'call dialog
	IFZ GetSaveFileNameA (&ofn) THEN
		fileName$ = ""
		RETURN 0
	ELSE
		fileName$ = CSTRING$(ofn.lpstrFile)
		RETURN $$TRUE
	END IF


END FUNCTION
'
'
' #############################
' #####  SaveMemAsBMP ()  #####
' #############################
'
' PURPOSE : Save memory bitmap object as a BMP image.
'
FUNCTION  SaveMemAsBMP (file$, hdcMem)

	BITMAP bm
	UBYTE image[]

	$BI_RGB       = 0														' 24-bit RGB

	IFZ hdcMem THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	IFZ file$ THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidName
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	hImage = GetCurrentObject (hdcMem, $$OBJ_BITMAP)
	GetObjectA (hImage, SIZE(bm), &bm)
	width       = bm.width
	height      = bm.height

	dataOffset = 54

' alignment on multiple of 32 bits or 4 bytes

	size = dataOffset + (height * ((width * 3) + 3 AND -4))
	upper = size - 1
	DIM image[upper]

'	fill BITMAPFILEHEADER

	iAddr = &image[0]

	image[0] = 'B'															' DIB aka BMP signature
	image[1] = 'M'
	image[2] = size AND 0x00FF									' file size
	image[3] = (size >> 8) AND 0x00FF
	image[4] = (size >> 16) AND 0x00FF
	image[5] = (size >> 24) AND 0x00FF
	image[6] = 0
	image[7] = 0
	image[8] = 0
	image[9] = 0
	image[10] = dataOffset AND 0x00FF						' file offset of bitmap data
	image[11] = (dataOffset >> 8) AND 0x00FF
	image[12] = (dataOffset >> 16) AND 0x00FF
	image[13] = (dataOffset >> 24) AND 0x00FF

'	fill BITMAPINFOHEADER (first 6 members)

	info = 14
	image[info+0] = 40													' XLONG : BITMAPINFOHEADER size
	image[info+1] = 0
	image[info+2] = 0
	image[info+3] = 0
	image[info+4] = width AND 0x00FF						' XLONG : width in pixels
	image[info+5] = (width >> 8) AND 0x00FF
	image[info+6] = (width >> 16) AND 0x00FF
	image[info+7] = (width >> 24) AND 0x00FF
	image[info+8] = height AND 0x00FF						' XLONG : height in pixels
	image[info+9] = (height >> 8) AND 0x00FF
	image[info+10] = (height >> 16) AND 0x00FF
	image[info+11] = (height >> 24) AND 0x00FF
	image[info+12] = 1													' USHORT : # of planes
	image[info+13] = 0													'
	image[info+14] = 24													' USHORT : bits per pixel
	image[info+15] = 0													'
	image[info+16] = $BI_RGB										' XLONG : 24-bit RGB
	image[info+17] = 0													'
	image[info+18] = 0													'
	image[info+19] = 0													'
	image[info+20] = 0													' XLONG : sizeImage
	image[info+21] = 0													'
	image[info+22] = 0													'
	image[info+23] = 0													'
	image[info+24] = 0													' XLONG : xPPM
	image[info+25] = 0													'
	image[info+26] = 0													'
	image[info+27] = 0													'
	image[info+28] = 0													' XLONG : yPPM
	image[info+29] = 0													'
	image[info+30] = 0													'
	image[info+31] = 0													'
	image[info+32] = 0													' XLONG : clrUsed
	image[info+33] = 0													'
	image[info+34] = 0													'
	image[info+35] = 0													'
	image[info+36] = 0													' XLONG : clrImportant
	image[info+37] = 0													'
	image[info+38] = 0													'
	image[info+39] = 0													'

	dataAddr = iAddr + dataOffset
	infoAddr = iAddr + 14

	x = 0
	y = 0

	ok = GetDIBits (hdcMem, hImage, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)

	IFZ ok THEN RETURN ($$FALSE)

	size = SIZE (image[])

	ofile = OPEN (file$, $$WRNEW)

	IF (ofile < 3) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	bytesWritten = 0
	error = XxxWriteFile (ofile, &image[], size, &bytesWritten, 0)
	IF error THEN RETURN ($$FALSE)

	CLOSE (ofile)
	RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  get_random ()  #####
' ###########################
'
FUNCTION  get_random (x)

	STATIC entry

	IFZ entry THEN
		entry = $$TRUE
		seed = (GetTickCount () MOD 32767) + 1
		srand (seed)
	END IF

	RETURN rand() MOD x


END FUNCTION
'
'
' ###############################
' #####  set_maze_sizes ()  #####
' ###############################
'
FUNCTION  set_maze_sizes (width, height)

	SHARED maze_size_x, maze_size_y
	SHARED grid_width, grid_height

	IFZ width * height THEN RETURN ($$TRUE)

	maze_size_x = width / grid_width
	maze_size_y = height / grid_height


END FUNCTION
'
'
' ##############################
' #####  set_grid_size ()  #####
' ##############################
'
FUNCTION  set_grid_size (size)

	SHARED grid_width, grid_height
	SHARED bw

	IF size < 2 THEN size = 7 + get_random (30)

	grid_width = size
	grid_height = size

	IF size > 6 THEN
		bw = 3
	ELSE
		bw = (size-1)/2
	END IF

END FUNCTION
'
'
' ################################
' #####  initialize_maze ()  #####
' ################################
'
' PURPOSE : Draw the surrounding wall and start/end squares.
'
FUNCTION  initialize_maze (gridSize, w, h)

	SHARED maze[]
	SHARED maze_size_x, maze_size_y
	SHARED cur_sq_x, cur_sq_y
	SHARED start_x,	start_y, start_dir
	SHARED sqnum
	SHARED end_x,	end_y, end_dir
	SHARED tgc, gc, bc, sgc, cgc, ugc
	SHARED max_length
	SHARED grid_width

' init grid size
	set_grid_size (gridSize)

' set maze width, height
	set_maze_sizes (w, h)

' set max run length for alt_create_maze
	max_length = get_random ((MIN (w, h)/grid_width)/2) + 5

' init colors
	gc = RGB (0, 255, 0)				' foreground maze color
	tgc = RGB (255, 255, 0)			' foreground live color
	bc = RGB (0, 255, 0)				' foreground maze border color
	sgc = RGB (255, 0, 255)			' foreground skip color
	cgc = RGB (0, 0, 255)				' foreground backtrack color
'	ugc = RGB (255, 127, 127)		' foreground dead region color
	ugc = RGB (255, 97, 97)		' foreground dead region color

	sqnum = 0

' initialize all squares
	DIM maze[maze_size_x-1, maze_size_y-1]

' top wall/bottom wall
  FOR i = 0 TO maze_size_x-1
		maze[i, 0] = maze[i, 0] | $$WALL_TOP
		maze[i, maze_size_y-1] = maze[i, maze_size_y-1] | $$WALL_BOTTOM
	NEXT i

' right wall/left wall
	FOR j = 0 TO maze_size_y-1
		maze[maze_size_x-1, j] = maze[maze_size_x-1, j] | $$WALL_RIGHT
    maze[0, j] = maze[0, j] | $$WALL_LEFT
	NEXT j

' set start square
	wall = get_random (4)
	SELECT CASE (wall)
		CASE 0:
			i = get_random (maze_size_x)
			j = 0

		CASE 1:
			i = maze_size_x - 1
			j = get_random (maze_size_y)

		CASE 2:
			i = get_random (maze_size_x)
			j = maze_size_y - 1

		CASE 3:
			i = 0
			j = get_random (maze_size_y)
	END SELECT

	maze[i, j] = maze[i, j] | $$START_SQUARE
	maze[i, j] = maze[i, j] | ($$DOOR_IN_TOP >> wall)
  maze[i, j] = maze[i, j] & ~($$WALL_TOP >> wall)
	cur_sq_x = i
	cur_sq_y = j
	start_x = i
	start_y = j
	start_dir = wall

' set end square
	wall = (wall + 2) MOD 4
	SELECT CASE (wall)
		CASE 0:
			i = get_random (maze_size_x)
			j = 0

		CASE 1:
			i = maze_size_x - 1
			j = get_random (maze_size_y)

		CASE 2:
			i = get_random (maze_size_x)
			j = maze_size_y - 1

		CASE 3:
			i = 0
			j = get_random (maze_size_y)
	END SELECT

	maze[i, j] = maze[i, j] | $$END_SQUARE
	maze[i, j] = maze[i, j] | ($$DOOR_OUT_TOP >> wall)
	maze[i, j] = maze[i, j] & ~($$WALL_TOP >> wall)
	end_x = i
	end_y = j
	end_dir = wall

END FUNCTION
'
'
' ##################################
' #####  ClearScreenBuffer ()  #####
' ##################################
'
FUNCTION  ClearScreenBuffer (hdcMem)

	BITMAP bm

	IFZ hdcMem THEN RETURN ($$TRUE)
	hImage = GetCurrentObject (hdcMem, $$OBJ_BITMAP)
	IFZ hImage THEN RETURN ($$TRUE)

	GetObjectA (hImage, SIZE(bm), &bm)
	w = bm.width
	h = bm.height

	hBrush 	= GetStockObject ($$BLACK_BRUSH)
	lastBrush = SelectObject (hdcMem, hBrush)
	PatBlt (hdcMem, 0, 0, w, h, $$PATCOPY)
	SelectObject (hdcMem, lastBrush)

END FUNCTION
'
'
' #################################
' #####  draw_maze_border ()  #####
' #################################
'
FUNCTION  draw_maze_border (hdcMem)

	SHARED maze_size_x, maze_size_y
	SHARED grid_width, grid_height
	SHARED maze[]
	SHARED start_x,	start_y, start_dir
	SHARED end_x,	end_y, end_dir
	SHARED tgc, gc, bc

	border_x = 0
	border_y = 0

	FOR i = 0 TO maze_size_x-1
		IF (maze[i, 0] & $$WALL_TOP) THEN
			Line (hdcMem,	bc, border_x + grid_width * i, border_y, border_x + grid_width * (i+1) - 1,	border_y)
 		END IF

		IF (maze[i, maze_size_y - 1] & $$WALL_BOTTOM) THEN
			Line (hdcMem, bc, border_x + grid_width * i, border_y + grid_height * (maze_size_y) - 1, border_x + grid_width * (i+1) - 1, border_y + grid_height * (maze_size_y) - 1)
		END IF
	NEXT i

	FOR j = 0 TO maze_size_y-1
		IF (maze[maze_size_x - 1, j] & $$WALL_RIGHT) THEN
			Line (hdcMem,	bc, border_x + grid_width * maze_size_x - 1, border_y + grid_height * j, border_x + grid_width * maze_size_x - 1, border_y + grid_height * (j+1) - 1)
		END IF

		IF (maze[0, j] & $$WALL_LEFT) THEN
			Line (hdcMem,	bc, border_x, border_y + grid_height * j,	border_x,	border_y + grid_height * (j+1) - 1)
		END IF
	NEXT j

' tag starting and ending points of maze
  draw_solid_square (hdcMem, start_x, start_y, $$WALL_TOP >> start_dir, tgc)
  draw_solid_square (hdcMem, end_x, end_y, $$WALL_TOP >> end_dir, tgc)


END FUNCTION
'
'
' #####################
' #####  Line ()  #####
' #####################
'
FUNCTION  Line (hdc, color, x1, y1, x2, y2)

	hPen = CreatePen ($$PS_SOLID, 1, color)
	lastPen = SelectObject (hdc, hPen)

	MoveToEx (hdc, x1, y1, 0)
	LineTo (hdc, x2, y2)

	SelectObject (hdc, lastPen)
	DeleteObject (hPen)

END FUNCTION
'
'
' ##################################
' #####  draw_solid_square ()  #####
' ##################################
'
FUNCTION  draw_solid_square (hdcMem, i, j, dir, gc)

	SHARED bw
	SHARED grid_width, grid_height

	border_x = 0
	border_y = 0

	IFZ bw THEN
		bwm = 1
	ELSE
		bwm = 0
	END IF

	SELECT CASE dir

		CASE $$WALL_TOP:
			FillRectangle (hdcMem, gc, border_x + bw + bwm + grid_width * i, border_y - bw - bwm + grid_height * j, grid_width - (bw+bw+bwm), grid_height)

		CASE $$WALL_RIGHT:
			FillRectangle (hdcMem, gc, border_x + bw + bwm + grid_width * i, border_y + bw + bwm + grid_height * j, grid_width, grid_height - (bw+bw+bwm))

		CASE $$WALL_BOTTOM:
			FillRectangle (hdcMem, gc, border_x + bw + bwm + grid_width * i, border_y + bw + bwm + grid_height * j, grid_width - (bw+bw+bwm), grid_height)

		CASE $$WALL_LEFT:
			FillRectangle (hdcMem, gc, border_x - bw - bwm + grid_width * i, border_y + bw + bwm + grid_height * j, grid_width, grid_height - (bw+bw+bwm))

	END SELECT

END FUNCTION
'
'
' ##############################
' #####  FillRectangle ()  #####
' ##############################
'
FUNCTION  FillRectangle (hdc, color, x, y, width, height)

	hPen = CreatePen ($$PS_SOLID, 1, color)
	lastPen = SelectObject (hdc, hPen)
	hBrush = CreateSolidBrush (color)
	lastBrush = SelectObject (hdc, hBrush)

'	Rectangle (hdc, left, top, right, bottom)
	Rectangle (hdc, x, y, x+width, y+height)

	SelectObject (hdc, lastBrush)
	DeleteObject (hBrush)
	SelectObject (hdc, lastPen)
	DeleteObject (hPen)


END FUNCTION
'
'
' ############################
' #####  create_maze ()  #####
' ############################
'
' PURPOSE :  The original maze creator.
' Start somewhere. Take a step in a random
' direction. Keep doing this until we hit a wall.
' Then, backtrack until we find a point where we
' can go in another direction.

FUNCTION  create_maze (hdcMem)

	SHARED MOVE_LIST move_list[], save_path[]
	SHARED sqnum
	SHARED cur_sq_x, cur_sq_y
	SHARED maze_size_x, maze_size_y
	SHARED maze[]

	move_list_size = (maze_size_x * maze_size_y) - 1

	DIM move_list[move_list_size]
	DIM save_path[move_list_size]

	newdoor = 0

	DO
		move_list[sqnum].x = cur_sq_x
		move_list[sqnum].y = cur_sq_y
    move_list[sqnum].dir = newdoor
    DO
			newdoor = choose_door (hdcMem)					' pick a door
			IF newdoor != -1 THEN EXIT DO
			IF (backup () == -1) THEN RETURN 				' no more doors ... backup done ... return
		LOOP

' mark the out door
    maze[cur_sq_x, cur_sq_y] = maze[cur_sq_x, cur_sq_y] | ($$DOOR_OUT_TOP >> newdoor)

		SELECT CASE (newdoor)
			CASE 0: DEC cur_sq_y
			CASE 1: INC cur_sq_x
			CASE 2: INC cur_sq_y
			CASE 3: DEC cur_sq_x
		END SELECT

    INC sqnum

' mark the in door
		maze[cur_sq_x, cur_sq_y] = maze[cur_sq_x, cur_sq_y] | ($$DOOR_IN_TOP >> ((newdoor+2) MOD 4))

' if end square set path length and save path
		IF (maze[cur_sq_x, cur_sq_y] & $$END_SQUARE) THEN
			path_length = sqnum
			FOR i = 0 TO path_length-1
				save_path[i].x = move_list[i].x
				save_path[i].y = move_list[i].y
				save_path[i].dir = move_list[i].dir
			NEXT i
		END IF

	LOOP

END FUNCTION
'
'
' ############################
' #####  choose_door ()  #####
' ############################
'
FUNCTION  choose_door (hdcMem)

	SHARED maze[]
	SHARED cur_sq_x, cur_sq_y
	SHARED gc

	DIM candidates[3]

  num_candidates = 0

' top wall
	IF (maze[cur_sq_x, cur_sq_y] & $$DOOR_IN_TOP) THEN GOTO rightwall
  IF (maze[cur_sq_x, cur_sq_y] & $$DOOR_OUT_TOP) THEN GOTO rightwall
  IF (maze[cur_sq_x, cur_sq_y] & $$WALL_TOP) THEN GOTO rightwall
  IF (maze[cur_sq_x, cur_sq_y - 1] & $$DOOR_IN_ANY) THEN
		maze[cur_sq_x, cur_sq_y] = maze[cur_sq_x, cur_sq_y] | $$WALL_TOP
    maze[cur_sq_x, cur_sq_y - 1] = maze[cur_sq_x, cur_sq_y - 1] | $$WALL_BOTTOM
		draw_wall (hdcMem, cur_sq_x, cur_sq_y, 0, gc)
		GOTO rightwall
	END IF

  candidates[num_candidates] = 0
	INC num_candidates

rightwall:
' right wall
	IF (maze[cur_sq_x, cur_sq_y] & $$DOOR_IN_RIGHT) THEN GOTO bottomwall
	IF (maze[cur_sq_x, cur_sq_y] & $$DOOR_OUT_RIGHT) THEN GOTO bottomwall
	IF (maze[cur_sq_x, cur_sq_y] & $$WALL_RIGHT) THEN GOTO bottomwall
	IF (maze[cur_sq_x + 1, cur_sq_y] & $$DOOR_IN_ANY) THEN
		maze[cur_sq_x, cur_sq_y] = maze[cur_sq_x, cur_sq_y] | $$WALL_RIGHT
		maze[cur_sq_x + 1, cur_sq_y] = maze[cur_sq_x + 1, cur_sq_y] | $$WALL_LEFT
		draw_wall (hdcMem, cur_sq_x, cur_sq_y, 1, gc)
		GOTO bottomwall
	END IF

  candidates[num_candidates] = 1
	INC num_candidates

bottomwall:
' bottom wall
	IF (maze[cur_sq_x, cur_sq_y] & $$DOOR_IN_BOTTOM) THEN GOTO leftwall
	IF (maze[cur_sq_x, cur_sq_y] & $$DOOR_OUT_BOTTOM) THEN GOTO leftwall
  IF (maze[cur_sq_x, cur_sq_y] & $$WALL_BOTTOM) THEN GOTO leftwall
	IF (maze[cur_sq_x, cur_sq_y + 1] & $$DOOR_IN_ANY) THEN
		maze[cur_sq_x, cur_sq_y] = maze[cur_sq_x, cur_sq_y] | $$WALL_BOTTOM
		maze[cur_sq_x, cur_sq_y + 1] = maze[cur_sq_x, cur_sq_y + 1] | $$WALL_TOP
		draw_wall (hdcMem, cur_sq_x, cur_sq_y, 2, gc)
		GOTO leftwall
	END IF

  candidates[num_candidates] = 2
	INC num_candidates


leftwall:
' left wall
	IF (maze[cur_sq_x, cur_sq_y] & $$DOOR_IN_LEFT) THEN GOTO donewall
	IF (maze[cur_sq_x, cur_sq_y] & $$DOOR_OUT_LEFT) THEN GOTO donewall
	IF (maze[cur_sq_x, cur_sq_y] & $$WALL_LEFT) THEN GOTO donewall
	IF (maze[cur_sq_x - 1, cur_sq_y] & $$DOOR_IN_ANY) THEN
		maze[cur_sq_x, cur_sq_y] = maze[cur_sq_x, cur_sq_y] | $$WALL_LEFT
		maze[cur_sq_x - 1, cur_sq_y] = maze[cur_sq_x - 1, cur_sq_y] | $$WALL_RIGHT
		draw_wall (hdcMem, cur_sq_x, cur_sq_y, 3, gc)
		GOTO donewall
	END IF

  candidates[num_candidates] = 3
	INC num_candidates

donewall:
	IF (num_candidates == 0) THEN RETURN (-1)
	IF (num_candidates == 1) THEN RETURN (candidates[0])
  RETURN (candidates[get_random (num_candidates)])

END FUNCTION
'
'
' #######################
' #####  backup ()  #####
' #######################
'
FUNCTION  backup ()

	SHARED sqnum
	SHARED cur_sq_x, cur_sq_y
	SHARED MOVE_LIST move_list[]

	DEC sqnum
  cur_sq_x = move_list[sqnum].x
  cur_sq_y = move_list[sqnum].y
  RETURN (sqnum)

END FUNCTION
'
'
' ##########################
' #####  draw_wall ()  #####
' ##########################
'
' PURPOSE : Draw a single wall

FUNCTION  draw_wall (hdcMem, i, j, dir, gc)

	SHARED grid_width, grid_height

	border_x = 0
	border_y = 0

	SELECT CASE (dir)
		CASE 0:
			Line (hdcMem, gc, border_x + grid_width * i, border_y + grid_height * j, border_x + grid_width * (i+1), border_y + grid_height * j)

		CASE 1:
			Line (hdcMem, gc, border_x + grid_width * (i+1), border_y + grid_height * j, border_x + grid_width * (i+1), border_y + grid_height * (j+1))

		CASE 2:
			Line (hdcMem, gc, border_x + grid_width * i, border_y + grid_height * (j+1), border_x + grid_width * (i+1), border_y + grid_height * (j+1))

		CASE 3:
			Line (hdcMem, gc, border_x + grid_width * i, border_y + grid_height * j, border_x + grid_width * i, border_y + grid_height * (j+1))

	END SELECT


END FUNCTION
'
'
' ################################
' #####  alt_create_maze ()  #####
' ################################
'
FUNCTION  alt_create_maze (hdcMem)

	SHARED maze_size_x, maze_size_y
	SHARED max_length

  height = maze_size_y+1
  width = maze_size_x+1

	DIM corners[height*width]
	DIM c_idx[height*width]

	upper = height*width - 1
	FOR i = 0 TO upper
		c_idx[i] = i
	NEXT i

	FOR i = 0 TO upper
		j = c_idx[i]
		k = get_random (height * width)			'random()%(height*width);
		c_idx[i] = c_idx[k]
		c_idx[k] = j
	NEXT i

' Set up some initial walls.
' Outside walls.
	FOR i = 0 TO width-1
		corners[i] = 1
		corners[i+width*(height-1)] = 1
	NEXT i

	FOR i = 0 TO height-1
		corners[i*width] = 1
		corners[i*width+width-1] = 1
	NEXT i

' Count open gridpoints.
  open_corners = 0
	FOR i = 0 TO width-1
		FOR j = 0 TO height-1
			IF (!corners[i+width*j]) THEN INC open_corners
		NEXT j
	NEXT i

' Now do actual maze generation.
	DO WHILE (open_corners > 0)

		FOR i = 0 TO upper

			IF (!corners[c_idx[i]]) THEN
	      x = c_idx[i] MOD width
	      y = c_idx[i]/width
	      dir = get_random (4)						' Choose a random direction.

				k = 0

	      DO WHILE (!corners[x+width*y])	' Measure the length of the wall we'd draw.
					INC k
					SELECT CASE (dir)
						CASE 0: DEC y
						CASE 1: INC x
						CASE 2: INC y
						CASE 3: DEC x
					END SELECT
				LOOP
			END IF

			IF (k <= max_length) THEN
				x = c_idx[i] MOD width
				y = c_idx[i]/width

				DO WHILE (!corners[x+width*y])				' Draw a wall until we hit something.
					DEC open_corners
					corners[x+width*y] = 1
					SELECT CASE (dir)
						CASE 0:
							build_wall (hdcMem, x-1, y-1, 1)
							DEC y

						CASE 1:
							build_wall (hdcMem, x, y, 0)
							INC x

						CASE 2:
							build_wall (hdcMem, x, y, 3)
							INC y

						CASE 3:
							build_wall (hdcMem, x-1, y-1, 2)
							DEC x
					END SELECT
				LOOP
			END IF
		NEXT i
	LOOP

END FUNCTION
'
'
' ###########################
' #####  build_wall ()  #####
' ###########################
'
FUNCTION  build_wall (hdcMem, i, j, dir)

	SHARED gc
	SHARED maze[]
	SHARED maze_size_x, maze_size_y

' Draw it on the screen.
	draw_wall (hdcMem, i, j, dir, gc)

' Put it in the maze.
	SELECT CASE (dir)

		CASE 0:
			maze[i, j] = maze[i, j] | $$WALL_TOP
			IF (j > 0) THEN
				maze[i, j-1] = maze[i, j-1] | $$WALL_BOTTOM
			END IF

		CASE 1:
			maze[i, j] = maze[i, j] | $$WALL_RIGHT
			IF (i < maze_size_x-1) THEN
				maze[i+1, j] = maze[i+1, j] | $$WALL_LEFT
			END IF

		CASE 2:
			maze[i, j] = maze[i, j] | $$WALL_BOTTOM
			IF (j < maze_size_y-1) THEN
				maze[i, j+1] = maze[i, j+1] | $$WALL_TOP
 			END IF

		CASE 3:
			maze[i, j] = maze[i, j] | $$WALL_LEFT
			IF (i > 0) THEN
				maze[i-1, j] = maze[i-1, j] | $$WALL_RIGHT
			END IF

	END SELECT


END FUNCTION
'
'
' ###########################
' #####  UpdateMaze ()  #####
' ###########################
'
FUNCTION  UpdateMaze (hWnd, hdcMem, gridSize, w, h, generator)

	ClearScreenBuffer (hdcMem)

	initialize_maze (gridSize, w, h)
	draw_maze_border (hdcMem)

	SELECT CASE generator
		CASE 0: create_maze (hdcMem)
		CASE 1: alt_create_maze (hdcMem)
		CASE 2: set_create_maze (hdcMem)
		CASE 3: create_walk_maze2 (hdcMem)

	END SELECT

	InvalidateRect (hWnd, NULL, $$TRUE)

END FUNCTION
'
'
' ###########################
' #####  solve_maze ()  #####
' ###########################
'
' PURPOSE : Solve maze with graphical solution.
'
FUNCTION  solve_maze (hdcMem)

	SHARED maze[]
	SHARED end_x,	end_y, end_dir
	SHARED maze_size_x, maze_size_y
	SHARED start_x,	start_y, start_dir
	MOVE_LIST path[]
	SHARED sgc, tgc, cgc
	SHARED ignorant_p

'	ignorant_p = $$TRUE
	solve_delay = 50
 	bt = 0

	move_list_size = (maze_size_x * maze_size_y) - 1

	DIM path[move_list_size]

' plug up the surrounding wall
	maze[end_x, end_y] = maze[end_x, end_y] | ($$WALL_TOP >> end_dir)

' initialize search path
	i = 0
	path[i].x = end_x
	path[i].y = end_y
	path[i].dir = 0
	maze[end_x, end_y] = maze[end_x, end_y] | $$SOLVER_VISIT

' do it
	DO

' Repaint maze
		paint_maze (hdcMem)

' Abort solve on keydown
		IF (check_events ()) THEN RETURN

' Stop when finished solving maze
		IF (maze[path[i].x, path[i].y] & $$START_SQUARE) THEN RETURN

		IF (solve_delay) THEN Sleep (solve_delay)

		IF (!path[i].dir) THEN
			ways = 0
' First visit this square.  Which adjacent squares are open?
'	    for(dir = WALL_TOP; dir & WALL_ANY; dir >>= 1)

			dir = $$WALL_TOP
			DO UNTIL dir = 0x0		'0x1

				IF (maze[path[i].x, path[i].y] & dir) THEN GOTO donext

' !! returns -1 if TRUE, 0 if FALSE
				wt = !!(dir & $$WALL_TOP)
				IF wt THEN wt = 1
				wb = !!(dir & $$WALL_BOTTOM)
				IF wb THEN wb = 1
				wr = !!(dir & $$WALL_RIGHT)
				IF wr THEN wr = 1
				wl = !!(dir & $$WALL_LEFT)
				IF wl THEN wl = 1

				y = path[i].y - wt + wb
				x = path[i].x + wr - wl
'				y = path[i].y - !!(dir & $$WALL_TOP) + !!(dir & $$WALL_BOTTOM)
'				x = path[i].x + !!(dir & $$WALL_RIGHT) - !!(dir & $$WALL_LEFT)

				IF (maze[x, y] & $$SOLVER_VISIT) THEN GOTO donext

				from = ((dir << 2) & $$WALL_ANY) | ((dir >> 2) & $$WALL_ANY)

' don't enter obvious dead ends
				IF (((maze[x, y] & $$WALL_ANY) | from) != $$WALL_ANY) THEN
					IF (!longdeadend_p (hdcMem, path[i].x, path[i].y, x, y, dir)) THEN
						ways = ways | dir
					END IF
				ELSE
					draw_solid_square (hdcMem, x, y, from, sgc)
					maze[x, y] = maze[x, y] | $$SOLVER_VISIT
				END IF

donext:
				dir = dir >> 1
			LOOP

		ELSE
			ways = path[i].ways
		END IF

' ways now has a bitmask of open paths.

		IF (!ways) THEN GOTO backtrack

		IF (!ignorant_p) THEN

			x = path[i].x - start_x
			y = path[i].y - start_y

' choice one
			IF (ABS (y) <= ABS (x)) THEN
				IF x > 0 THEN dir = $$WALL_LEFT ELSE dir = $$WALL_RIGHT
			ELSE
				IF y > 0 THEN dir = $$WALL_TOP ELSE dir = $$WALL_BOTTOM
			END IF

			IF (dir & ways) THEN GOTO found

' choice two
			SELECT CASE (dir)
				CASE $$WALL_LEFT:
					IF y > 0 THEN dir = $$WALL_TOP ELSE dir = $$WALL_BOTTOM
				CASE $$WALL_RIGHT:
					IF y > 0 THEN dir = $$WALL_TOP ELSE dir = $$WALL_BOTTOM
				CASE $$WALL_TOP:
					IF x > 0 THEN dir = $$WALL_LEFT ELSE dir = $$WALL_RIGHT
				CASE $$WALL_BOTTOM:
					IF x > 0 THEN dir = $$WALL_LEFT ELSE dir = $$WALL_RIGHT
			END SELECT
			IF (dir & ways) THEN GOTO found

' choice three
			dir = (dir << 2 & $$WALL_ANY) | (dir >> 2 & $$WALL_ANY)
			IF (dir & ways) THEN GOTO found

'	choice four
			dir = ways
			IF (!dir) THEN GOTO backtrack

found:

		ELSE

			IF (ways & $$WALL_TOP) THEN
				dir = $$WALL_TOP
			ELSE
				IF (ways & $$WALL_LEFT) THEN
					dir = $$WALL_LEFT
				ELSE
					IF (ways & $$WALL_BOTTOM) THEN
						dir = $$WALL_BOTTOM
					ELSE
						IF (ways & $$WALL_RIGHT) THEN
							dir = $$WALL_RIGHT
						ELSE
							GOTO backtrack
						END IF
					END IF
				END IF
			END IF
		END IF

		bt = 0
		ways = ways & ~dir  						' tried this one

' !! returns -1 if TRUE, 0 if FALSE
		wt = !!(dir & $$WALL_TOP)
		IF wt THEN wt = 1
		wb = !!(dir & $$WALL_BOTTOM)
		IF wb THEN wb = 1
		wr = !!(dir & $$WALL_RIGHT)
		IF wr THEN wr = 1
		wl = !!(dir & $$WALL_LEFT)
		IF wl THEN wl = 1

		y = path[i].y - wt + wb
		x = path[i].x + wr - wl
'		y = path[i].y - !!(dir & $$WALL_TOP) + !!(dir & $$WALL_BOTTOM)
'		x = path[i].x + !!(dir & $$WALL_RIGHT) - !!(dir & $$WALL_LEFT)

' advance in direction dir
		path[i].dir = dir
		path[i].ways = ways
		draw_solid_square (hdcMem, path[i].x, path[i].y, dir, tgc)

		INC i
		path[i].dir = 0
		path[i].ways = 0
		path[i].x = x
		path[i].y = y
		maze[x, y] = maze[x, y] | $$SOLVER_VISIT

		DO DO

backtrack:

		IF (i == 0) THEN
'			PRINT "Unsolvable maze.\n"
			MessageBoxA (0, &"Unsolvable maze.", &"Maze Error", $$MB_OK | $$MB_ICONEXCLAMATION)
			RETURN
		END IF

		IF (!bt && !ignorant_p) THEN
			find_dead_regions (hdcMem)
		END IF

		bt = 1
		from = path[i-1].dir
		from = ((from << 2) & $$WALL_ANY) | ((from >> 2) & $$WALL_ANY)

		draw_solid_square (hdcMem, path[i].x, path[i].y, from, cgc)
		DEC i
	LOOP

END FUNCTION
'
'
' ##########################
' #####  info_maze ()  #####
' ##########################
'
FUNCTION  info_maze ()

'******************************************************************************
' * [ maze ] ...
'
' * modified:  [08-10-03 ] Ported to XBLite by David Szafranski
' *              Added new maze generator which carves out the maze.
' *              See create_walk_maze.
' *
' * modified:  [ 1-04-00 ]  Johannes Keukelaar <johannes@nada.kth.se>
' *              Added -ignorant option (not the default) to remove knowlege
' *              of the direction in which the exit lies.
' *
' * modified:  [ 6-28-98 ]  Zack Weinberg <zack@rabi.phys.columbia.edu>
' *
' *              Made the maze-solver somewhat more intelligent.  There are
' *              three optimizations:
' *
' *              - Straight-line lookahead: the solver does not enter dead-end
' *                corridors.  This is a win with all maze generators.
' *
' *              - First order direction choice: the solver knows where the
' *                exit is in relation to itself, and will try paths leading in
' *                that direction first. This is a major win on maze generator 1
' *                which tends to offer direct routes to the exit.
' *
' *              - Dead region elimination: the solver already has a map of
' *                all squares visited.  Whenever it starts to backtrack, it
' *                consults this map and marks off all squares that cannot be
' *                reached from the exit without crossing a square already
' *                visited.  Those squares can never contribute to the path to
' *                the exit, so it doesn't bother checking them.  This helps a
' *                lot with maze generator 2 and somewhat less with generator 1.
' *
' *              Further improvements would require knowledge of the wall map
' *              as well as the position of the exit and the squares visited.
' *              I would consider that to be cheating.  Generator 0 makes
' *              mazes which are remarkably difficult to solve mechanically --
' *              even with these optimizations the solver generally must visit
' *              at least two-thirds of the squares.  This is partially
' *              because generator 0's mazes have longer paths to the exit.
' *
' * modified:  [ 4-10-97 ]  Johannes Keukelaar <johannes@nada.kth.se>
' *              Added multiple maze creators. Robustified solver.
' *              Added bridge option.
' * modified:  [ 8-11-95 ] Ed James <james@mml.mmc.com>
' *              added fill of dead-end box to solve_maze while loop.
' * modified:  [ 3-7-93 ]  Jamie Zawinski <jwz@jwz.org>
' *		added the XRoger logo, cleaned up resources, made
' *		grid size a parameter.
' * modified:  [ 3-3-93 ]  Jim Randell <jmr@mddjmr.fc.hp.com>
' *		Added the colour stuff and integrated it with jwz's
' *		screenhack stuff.  There's still some work that could
' *		be done on this, particularly allowing a resource to
' *		specify how big the squares are.
' * modified:  [ 10-4-88 ]  Richard Hess    ...!uunet!cimshop!rhess
' *              [ Revised primary execution loop within main()...
' *              [ Extended X event handler, check_events()...
' * modified:  [ 1-29-88 ]  Dave Lemke      lemke@sun.com
' *              [ Hacked for X11...
' *              [  Note the word "hacked" -- this is extremely ugly, but at
' *              [   least it does the job.  NOT a good programming example
' *              [   for X.
' * original:  [ 6/21/85 ]  Martin Weiss    Sun Microsystems  [ SunView ]
' *
' ******************************************************************************
' Copyright 1988 by Sun Microsystems, Inc. Mountain View, CA.

' All Rights Reserved

' Permission to use, copy, modify, and distribute this software and its
' documentation for any purpose and without fee is hereby granted,
' provided that the above copyright notice appear in all copies and that
' both that copyright notice and this permission notice appear in
' supporting documentation, and that the names of Sun or MIT not be
' used in advertising or publicity pertaining to distribution of the
' software without specific prior written permission. Sun and M.I.T.
' make no representations about the suitability of this software for
' any purpose. It is provided "as is" without any express or implied warranty.

' SUN DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
' ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
' PURPOSE. IN NO EVENT SHALL SUN BE LIABLE FOR ANY SPECIAL, INDIRECT
' OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
' OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
' OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE
' OR PERFORMANCE OF THIS SOFTWARE.
' *****************************************************************************/

END FUNCTION
'
'
' ##############################
' #####  longdeadend_p ()  #####
' ##############################
'
FUNCTION  longdeadend_p (hdcMem, x1, y1, x2, y2, endwall)

	SHARED maze[]
	SHARED sgc
	SHARED maze_size_x, maze_size_y

 	dx = x2 - x1
	dy = y2 - y1

	sidewalls = endwall | (endwall >> 2 | endwall << 2)
	sidewalls = ~sidewalls & $$WALL_ANY

	DO WHILE ((maze[x2, y2] & $$WALL_ANY) == sidewalls)
		x2 = x2 + dx
		y2 = y2 + dy

		SELECT CASE TRUE
			CASE x2 < 0 : x2 = 0 : EXIT DO
			CASE y2 < 0 : y2 = 0 : EXIT DO
			CASE x2 > maze_size_x-1 : x2 = maze_size_x-1 : EXIT DO
			CASE y2 > maze_size_y-1 : y2 = maze_size_y-1 : EXIT DO
		END SELECT

 	LOOP

	IF ((maze[x2, y2] & $$WALL_ANY) == (sidewalls | endwall)) THEN
		endwall = (endwall >> 2 | endwall << 2) & $$WALL_ANY
		DO WHILE (x1 != x2 || y1 != y2)
			x1 = x1 + dx
			y1 = y1 + dy
			draw_solid_square (hdcMem, x1, y1, endwall, sgc)
			maze[x1, y1] = maze[x1, y1] | $$SOLVER_VISIT
		LOOP
		RETURN 1
	ELSE
		RETURN
	END IF

END FUNCTION
'
'
' ##################################
' #####  find_dead_regions ()  #####
' ##################################
'
' PURPOSE : Find all dead regions -- areas from which
' the goal cannot be reached, and mark them visited.
'
FUNCTION  find_dead_regions (hdcMem)

	SHARED maze[]
	SHARED start_x,	start_y
	SHARED maze_size_x, maze_size_y
	SHARED bw
	SHARED grid_width, grid_height
	SHARED ugc

	border_x = 0
	border_y = 0

' Find all not SOLVER_VISIT squares bordering NOT_DEAD squares
' and mark them NOT_DEAD also.  Repeat until no more such squares.

	maze[start_x, start_y] = maze[start_x, start_y] | $$NOT_DEAD

	DO

		flipped = 0
		FOR x = 0 TO maze_size_x-1
			FOR y = 0 TO maze_size_y-1

				IF x >= 1 THEN
					xbefore = x && (maze[x-1, y] & $$NOT_DEAD)
				ELSE
					xbefore = 0
				END IF

				IF y >= 1 THEN
					ybefore = y && (maze[x, y-1] & $$NOT_DEAD)
				ELSE
					ybefore = 0
				END IF

'				IF (!(maze[x, y] & ($$SOLVER_VISIT | $$NOT_DEAD)) && ((x && (maze[x-1, y] & $$NOT_DEAD)) || (y && (maze[x, y-1] & $$NOT_DEAD)))) THEN
				IF (!(maze[x, y] & ($$SOLVER_VISIT | $$NOT_DEAD)) && ((xbefore) || (ybefore))) THEN
					flipped = 1
					maze[x, y] = maze[x, y] | $$NOT_DEAD
				END IF
			NEXT y
		NEXT x

		FOR x = maze_size_x-1 TO 0 STEP -1
			FOR y = maze_size_y-1 TO 0 STEP -1

				IF x <= maze_size_x-2 THEN
					xafter = (x != maze_size_x-1) && (maze[x+1, y] & $$NOT_DEAD)
				ELSE
					xafter = 0
				END IF

				IF y <= maze_size_y-2 THEN
					yafter = (y != maze_size_y-1) && (maze[x, y+1] & $$NOT_DEAD)
				ELSE
					yafter = 0
				END IF

				IF (!(maze[x, y] & ($$SOLVER_VISIT | $$NOT_DEAD)) && ((xafter) || (yafter))) THEN
'				IF (!(maze[x, y] & ($$SOLVER_VISIT | $$NOT_DEAD)) && ((x != maze_size_x-1 && (maze[x+1, y] & $$NOT_DEAD)) || (y != maze_size_y-1 && (maze[x, y+1] & $$NOT_DEAD)))) THEN
					flipped = 1
					maze[x, y] = maze[x, y] | $$NOT_DEAD
				END IF
			NEXT y
		NEXT x

	LOOP WHILE (flipped)

	FOR y = 0 TO maze_size_y-1
		FOR x = 0 TO maze_size_x-1

			IF (maze[x, y] & $$NOT_DEAD) THEN
				maze[x, y] = maze[x, y] & ~$$NOT_DEAD
			ELSE
				IF (!(maze[x, y] & $$SOLVER_VISIT)) THEN

					maze[x, y] = maze[x, y] | $$SOLVER_VISIT

					IF (!(maze[x, y] & $$WALL_ANY)) THEN
						FillRectangle (hdcMem, ugc, border_x + bw + grid_width * x, border_y + bw + grid_height * y, grid_width - (bw+bw), grid_height - (bw+bw))
					ELSE
						IF (! (maze[x, y] & $$WALL_LEFT)) THEN
							draw_solid_square (hdcMem, x, y, $$WALL_LEFT, ugc)
						END IF
						IF (! (maze[x, y] & $$WALL_RIGHT)) THEN
							draw_solid_square (hdcMem, x, y, $$WALL_RIGHT, ugc)
						END IF
						IF (! (maze[x, y] & $$WALL_TOP)) THEN
							draw_solid_square (hdcMem, x, y, $$WALL_TOP, ugc)
						END IF
						IF (! (maze[x, y] & $$WALL_BOTTOM)) THEN
							draw_solid_square (hdcMem, x, y, $$WALL_BOTTOM, ugc)
						END IF
					END IF
				END IF
			END IF
		NEXT x
	NEXT y

END FUNCTION
'
'
' ###########################
' #####  paint_maze ()  #####
' ###########################
'
FUNCTION  paint_maze (hdcMem)

	RECT rc

	GetClientRect (#winMain, &rc)

	hdc = GetDC (#winMain)
	BitBlt (hdc, 0, 0, rc.right, rc.bottom, hdcMem, 0, 0, $$SRCCOPY)

	ReleaseDC (#winMain, hdc)
	InvalidateRect (#winMain, NULL, $$TRUE)

END FUNCTION
'
'
' #############################
' #####  check_events ()  #####
' #############################
'
FUNCTION  check_events ()

	MSG msg

	IF PeekMessageA (&msg, #winMain, 0, 0, $$PM_REMOVE) THEN

		SELECT CASE msg.message

			CASE $$WM_KEYDOWN : RETURN ($$TRUE)
'			CASE $$WM_PAINT   :

		END SELECT

	END IF

END FUNCTION
'
'
' ################################
' #####  set_create_maze ()  #####
' ################################
'
' Second alternative maze creator: Put each square in the maze in a
' separate set. Also, make a list of all the hedges. Randomize that list.
' Walk through the list. If, for a certain hedge, the two squares on both
' sides of it are in different sets, union the sets and remove the hedge.
' Continue until all hedges have been processed or only one set remains.
'
'
FUNCTION  set_create_maze (hdcMem)

	SHARED maze_size_x, maze_size_y
	SHARED hedges[], sets[]

 ' Do almost all the setup.
	init_sets ()

' Start running through the hedges.
	upper = 2 * maze_size_x * maze_size_y - 1

	FOR i = 0 TO upper
		h = hedges[i]

' This one is in the logo or outside border.
		IF (h == -1) THEN DO NEXT

		dir = (h MOD 2) + 1	' h%2?1:2;
		x = (h >> 1) MOD maze_size_x
		y = (h >> 1)/maze_size_x

		v = x
		w = y
		SELECT CASE (dir)
			CASE 1 : INC v
			CASE 2 : INC w
		END SELECT

		IF (get_set (x+y*maze_size_x) != get_set (v+w*maze_size_x)) THEN

			join_sets (x+y*maze_size_x, v+w*maze_size_x)

' Don't draw the wall.
		ELSE

' Don't join the sets.
			build_wall (hdcMem, x, y, dir)
		END IF
	NEXT

' Free some memory.
  DIM hedges[]
	DIM sets[]

END FUNCTION
'
'
' ##########################
' #####  init_sets ()  #####
' ##########################
'
FUNCTION  init_sets ()

	SHARED sets[], hedges[]
	SHARED maze_size_x, maze_size_y

	DIM sets[maze_size_x*maze_size_y-1]

	upper = UBOUND (sets[])
	FOR i = 0 TO upper
		sets[i] = i
	NEXT i

	DIM hedges[maze_size_x*maze_size_y*2-1]

	upper = UBOUND (hedges[])
	FOR i = 0 TO upper
		hedges[i] = i
	NEXT i

' Mask out outside walls.
	FOR i = 0 TO maze_size_y-1
		hedges[2*((maze_size_x)*i+maze_size_x-1)] = -1
'		hedges[2*((maze_size_x)*i+maze_size_x-1)+1] = -1
	NEXT i

	FOR i = 0 TO maze_size_x-1
		hedges[2*((maze_size_y-1)*maze_size_x+i)-1] = -1
'		hedges[2*((maze_size_y-1)*maze_size_x+i)] = -1
	NEXT i

	max = maze_size_x * maze_size_y * 2
	upper = maze_size_x * maze_size_y * 2 - 1
 	FOR i = 0 TO upper
		t = hedges[i]
		r = get_random (max)
		hedges[i] = hedges[r]
		hedges[r] = t
	NEXT i

END FUNCTION
'
'
' ########################
' #####  get_set ()  #####
' ########################
'
' Get the representative of a set.
'
FUNCTION  get_set (num)

	SHARED sets[]

	IF (sets[num] == num) THEN
		RETURN num
	ELSE
		s = get_set (sets[num])
		sets[num] = s
 		RETURN s
	END IF


END FUNCTION
'
'
' ##########################
' #####  join_sets ()  #####
' ##########################
'
FUNCTION  join_sets (num1, num2)

	SHARED sets[]

	s1 = get_set (num1)
	s2 = get_set (num2)

	IF (s1 < s2) THEN
		sets[s2] = s1
	ELSE
		sets[s1] = s2
	END IF

END FUNCTION
'
'
' #################################
' #####  create_walk_maze ()  #####
' #################################
'
' Create a maze with all cells with all cell walls.
' Then start a 'random walk' from the entry point,
' removing walls along the path. Do not 'break into
' a previously visited cell.  If you encounter a dead-end,
' then select at random a previously visited cell
' and start another random walk.  When you encounter the
' exit, remove that wall, though you can  continue that
' random walk.  Repeat this process until every cell has
' been visited. This process carves out a maze.
'
FUNCTION  create_walk_maze (hdcMem)

	SHARED maze[]
	SHARED maze_size_x, maze_size_y
	SHARED start_x,	start_y, start_dir
	SHARED end_x,	end_y, end_dir
	SHARED gc

PRINT "create_walk_maze start"

	DIM flag[3]

	maxRun = 5

' create a visited array
	DIM visit[maze_size_x-1, maze_size_y-1]

' initiate all cells to have all four walls
' except for start and end cells

	FOR i = 0 TO maze_size_x-1
		FOR j = 0 TO maze_size_y-1
			maze[i,j] = ~maze[i,j] & $$WALL_ANY
			maze[i,j] = $$WALL_ANY
		NEXT j
	NEXT i

' mark start and end cells
	maze[start_x,	start_y] = maze[start_x,	start_y] | $$START_SQUARE
	maze[end_x,	end_y] = maze[end_x,	end_y] | $$END_SQUARE

' clear outside wall on start and end cells
  maze[start_x,	start_y] = maze[start_x,	start_y] & ~($$WALL_TOP >> start_dir)
  maze[end_x,	end_y] = maze[end_x,	end_y] & ~($$WALL_TOP >> end_dir)


' keep track of current location in grid,
' start at entrance, go thru first random walk

	current_x = start_x
	current_y = start_y

	visit[current_x, current_y] = 1 				' mark first cell as visited

	cellCount = maze_size_x * maze_size_y

	GOSUB InitFlag
	deadend = 0
	lastDirection = -1

	DO

pickAnother:

' if deadend detected then stop loop
		IF flag[0] = 1 && flag[1] = 1 && flag[2] = 1 && flag[3] = 1 THEN EXIT DO

		GOSUB PickWall    					' pick a direction

' if nextCell is out of maze, then pick another cell,
' keep track of rejected directions with flags

		SELECT CASE TRUE
			CASE nextCellx > maze_size_x-1 	: flag[1] = 1 : GOTO pickAnother
			CASE nextCellx < 0 							: flag[3] = 1 : GOTO pickAnother
			CASE nextCelly > maze_size_y-1 	: flag[2] = 1 : GOTO pickAnother
			CASE nextCelly < 0 							: flag[0] = 1 : GOTO pickAnother
		END SELECT

' if cell has already been visited, then skip it,
' find another, set direction rejection flag

		IF visit[nextCellx, nextCelly] = 1 THEN
			flag[direction] = 1
			GOTO pickAnother
		END IF

' if the same direction has been selected more than
' maxRun times in a row, try new direction

		IF direction = lastDirection THEN
			INC dirCount
		ELSE
			dirCount = 0
		END IF

		IF dirCount > maxRun THEN
			dirCount = 0
			lastDirection = -1
			GOTO pickAnother
		END IF

		lastDirection = direction

		GOSUB RemoveWall  			' remove wall between two cells
		GOSUB CellVisited 			' mark cell visited
		GOSUB Swap        			' swap currentCell and nextCell
		GOSUB InitFlag    			' reinitialize flag[]
		DEC cellCount

	LOOP


' now continue random walks from previously
' visited cells until all cells visited

	DO WHILE cellCount <> 1

' choose next cell using list if < 1% remain
'		IF cellCount < totalCells * 0.01 THEN

' make a list of visited cells that have unvisited neighbors
'			GOSUB CellList2

' find a new starting point on current path of visited cells
'			GOSUB FindNewCell

'		ELSE

tryAnother:
			GOSUB SelectNewCell   					' select next visited cell randomly
			IF visit[current_x, current_y] = 0 THEN GOTO tryAnother
'			IF visit2[current_x, current_y] = 1 THEN GOTO tryAnother

			IF (current_x > 0) && (current_x < maze_size_x-1) && (current_y > 0) && (current_y < maze_size_y-1) THEN
				IF (visit[current_x+1, current_y] = 1) && (visit[current_x-1, current_y] = 1) && (visit[current_x, current_y+1] = 1) && (visit[current_x, current_y-1] = 1) THEN GOTO tryAnother
			END IF
'		END IF
'		visit2[current_x, current_y] = 1

		GOSUB InitFlag  						' initiate all flag() to 0
		deadend = 0       					' set deadend flag
		lastDirection = -1

		DO

getAnother:   									' pick another cell direction

' if dead end detected then stop loop
			IF flag[0] = 1 && flag[1] = 1 && flag[2] = 1 && flag[3] = 1 THEN EXIT DO

goAgain:
			GOSUB PickWall    				' pick a direction
			IF flag[direction] = 1 THEN GOTO goAgain

' if nextCell is out of maze, then pick another cell,
' keep track of rejected directions with flags

			SELECT CASE TRUE
				CASE nextCellx > maze_size_x-1 	: flag[1] = 1 : GOTO getAnother
				CASE nextCellx < 0 							: flag[3] = 1 : GOTO getAnother
				CASE nextCelly > maze_size_y-1 	: flag[2] = 1 : GOTO getAnother
				CASE nextCelly < 0 							: flag[0] = 1 : GOTO getAnother
			END SELECT

' if cell has already been visited, then skip it,
' find another, set direction rejection flag

			IF visit[nextCellx, nextCelly] = 1 THEN flag[direction] = 1 : GOTO getAnother

' if the same direction has been selected more than
' maxRun times in a row, try new direction

			IF direction = lastDirection THEN
				INC dirCount
			ELSE
				dirCount = 0
			END IF

			IF dirCount > maxRun THEN
				dirCount = 0
				lastDirection = -1
				GOTO getAnother
			END IF

			lastDirection = direction

			GOSUB RemoveWall  			' remove wall between two cells
			GOSUB CellVisited 			' mark cell visited
			GOSUB Swap        			' swap currentCell and nextCell
			GOSUB InitFlag    			' reinitialize flag[]
			DEC cellCount

		LOOP

	LOOP

PRINT "selCount="; selCount
PRINT "create_walk_maze done"

	GOSUB DrawMaze
	RETURN


' ***** InitFlag *****
SUB InitFlag
	FOR i = 0 TO 3
		flag[i] = 0
	NEXT i
END SUB

' ***** PickWall *****
SUB PickWall
' pick a random wall 0 = N, 1 = E, 2 = S, 3 = W
' oppWall = opposite wall for nextCell

	direction = get_random (4)

	SELECT CASE direction
		CASE 0 : nextCelly = current_y - 1 : nextCellx = current_x : oppWall = 2
		CASE 1 : nextCellx = current_x + 1 : nextCelly = current_y : oppWall = 3
		CASE 2 : nextCelly = current_y + 1 : nextCellx = current_x : oppWall = 0
		CASE 3 : nextCellx = current_x - 1 : nextCelly = current_y : oppWall = 1
	END SELECT
END SUB

' ***** CellVisited *****
SUB CellVisited
' update visit array to keep track of which valid
' next cells that have been visited
	visit[nextCellx, nextCelly] = 1        ' 1=visited, 0=unvisited
END SUB

' ***** RemoveWall *****
SUB RemoveWall
' remove wall between currentCell and nextCell
	maze[current_x, current_y] = maze[current_x, current_y] &  ~($$WALL_TOP >> direction)
	maze[nextCellx, nextCelly] = maze[nextCellx, nextCelly] &  ~($$WALL_TOP >> oppWall)
END SUB

' ***** Swap *****
SUB Swap
' swap contents of nextCell with currentCell
	current_x = nextCellx
	current_y = nextCelly
END SUB

' ***** SelectNewCell *****
SUB SelectNewCell
' choose a cell that has already been visited
' and then pick another new wall/direction

	current_x = get_random (maze_size_x)
	current_y = get_random (maze_size_y)

INC selCount

END SUB


' ***** DrawMaze *****
SUB DrawMaze

	FOR i = 0 TO maze_size_x - 1
		FOR j = 0 TO maze_size_y - 1
			SELECT CASE ALL TRUE
				CASE maze[i, j] & $$WALL_TOP 		: IF j > 0 THEN draw_wall (hdcMem, i, j, 0, gc)
				CASE maze[i, j] & $$WALL_RIGHT 	: IF i < maze_size_x-1 THEN draw_wall (hdcMem, i, j, 1, gc)
				CASE maze[i, j] & $$WALL_BOTTOM : IF j < maze_size_y-1 THEN draw_wall (hdcMem, i, j, 2, gc)
				CASE maze[i, j] & $$WALL_LEFT 	: IF i > 0 THEN draw_wall (hdcMem, i, j, 3, gc)
			END SELECT
		NEXT j
	NEXT i
END SUB

END FUNCTION
'
'
' #################################
' #####  create_walk_maze ()  #####
' #################################
'
' Create a maze with all cells with all cell walls.
' Then start a 'random walk' from the entry point,
' removing walls along the path. Do not 'break into
' a previously visited cell.  If you encounter a dead-end,
' then select at random a previously visited cell
' and start another random walk.  When you encounter the
' exit, remove that wall, though you can  continue that
' random walk.  Repeat this process until every cell has
' been visited. This process carves out a maze.
'
FUNCTION  create_walk_maze2 (hdcMem)

	SHARED maze[]
	SHARED maze_size_x, maze_size_y
	SHARED start_x,	start_y, start_dir
	SHARED end_x,	end_y, end_dir
	SHARED gc
	POINT visitList[]

'	startTime = GetTickCount ()

	DIM flag[3]
	DIM flagList[3]

	maxRun = 5

' create a visited array
	DIM visit[maze_size_x-1, maze_size_y-1]

' initiate all cells to have all four walls
' except for start and end cells

	FOR i = 0 TO maze_size_x-1
		FOR j = 0 TO maze_size_y-1
			maze[i,j] = ~maze[i,j] & $$WALL_ANY
			maze[i,j] = $$WALL_ANY
		NEXT j
	NEXT i

' mark start and end cells
	maze[start_x,	start_y] = maze[start_x,	start_y] | $$START_SQUARE
	maze[end_x,	end_y] = maze[end_x,	end_y] | $$END_SQUARE

' clear outside wall on start and end cells
  maze[start_x,	start_y] = maze[start_x,	start_y] & ~($$WALL_TOP >> start_dir)
  maze[end_x,	end_y] = maze[end_x,	end_y] & ~($$WALL_TOP >> end_dir)

' keep track of current location in grid,
' start at entrance, go thru first random walk

	current_x = start_x
	current_y = start_y

	visit[current_x, current_y] = 1 				' mark first cell as visited

	DIM visitList[0]
	visitList[0].x = current_x
	visitList[0].y = current_y

	cellCount = maze_size_x * maze_size_y

	GOSUB InitFlag
	deadend = 0
	lastDirection = -1

	DO

pickAnother:

' if deadend detected then stop loop
		IF flag[0] = 1 && flag[1] = 1 && flag[2] = 1 && flag[3] = 1 THEN EXIT DO

		GOSUB PickWall    					' pick a direction

' if nextCell is out of maze, then pick another cell,
' keep track of rejected directions with flags

		SELECT CASE TRUE
			CASE nextCellx > maze_size_x-1 	: flag[1] = 1 : GOTO pickAnother
			CASE nextCellx < 0 							: flag[3] = 1 : GOTO pickAnother
			CASE nextCelly > maze_size_y-1 	: flag[2] = 1 : GOTO pickAnother
			CASE nextCelly < 0 							: flag[0] = 1 : GOTO pickAnother
		END SELECT

' if cell has already been visited, then skip it,
' find another, set direction rejection flag

		IF visit[nextCellx, nextCelly] = 1 THEN
			flag[direction] = 1
			GOTO pickAnother
		END IF

' if the same direction has been selected more than
' maxRun times in a row, try new direction

		IF direction = lastDirection THEN
			INC dirCount
		ELSE
			dirCount = 0
		END IF

		IF dirCount > maxRun THEN
			dirCount = 0
			lastDirection = -1
			GOTO pickAnother
		END IF

		lastDirection = direction

		GOSUB RemoveWall  			' remove wall between two cells
		GOSUB CellVisited 			' mark cell visited
		GOSUB Swap        			' swap currentCell and nextCell
		GOSUB InitFlag    			' reinitialize flag[]
		DEC cellCount

	LOOP

' now continue random walks from previously
' visited cells until all cells visited

	DO WHILE cellCount <> 1

tryAnother:
		GOSUB SelectNewCell   					' select next visited cell randomly
		IF visit[current_x, current_y] = 0 THEN GOTO tryAnother

		IF (current_x > 0) && (current_x < maze_size_x-1) && (current_y > 0) && (current_y < maze_size_y-1) THEN
			IF (visit[current_x+1, current_y] = 1) && (visit[current_x-1, current_y] = 1) && (visit[current_x, current_y+1] = 1) && (visit[current_x, current_y-1] = 1) THEN GOTO tryAnother
		END IF

		GOSUB InitFlag  						' initiate all flag[] to 0
		deadend = 0       					' set deadend flag
		lastDirection = -1

		DO

getAnother:   									' pick another cell direction

' if dead end detected then stop loop
			IF flag[0] = 1 && flag[1] = 1 && flag[2] = 1 && flag[3] = 1 THEN EXIT DO

goAgain:
			GOSUB PickWall    				' pick a direction
			IF flag[direction] = 1 THEN GOTO goAgain

' if nextCell is out of maze, then pick another cell,
' keep track of rejected directions with flags

			SELECT CASE TRUE
				CASE nextCellx > maze_size_x-1 	: flag[1] = 1 : GOTO getAnother
				CASE nextCellx < 0 							: flag[3] = 1 : GOTO getAnother
				CASE nextCelly > maze_size_y-1 	: flag[2] = 1 : GOTO getAnother
				CASE nextCelly < 0 							: flag[0] = 1 : GOTO getAnother
			END SELECT

' if cell has already been visited, then skip it,
' find another, set direction rejection flag

			IF visit[nextCellx, nextCelly] = 1 THEN flag[direction] = 1 : GOTO getAnother

' if the same direction has been selected more than
' maxRun times in a row, try new direction

			IF direction = lastDirection THEN
				INC dirCount
			ELSE
				dirCount = 0
			END IF

			IF dirCount > maxRun THEN
				dirCount = 0
				lastDirection = -1
				GOTO getAnother
			END IF

			lastDirection = direction

			GOSUB RemoveWall  			' remove wall between two cells
			GOSUB CellVisited 			' mark cell visited
			GOSUB Swap        			' swap currentCell and nextCell
			GOSUB InitFlag    			' reinitialize flag[]
			DEC cellCount

		LOOP
	LOOP

'	endTime = GetTickCount ()
'	PRINT "time="; endTime - startTime

	GOSUB DrawMaze

	DIM visitList[]
	DIM visit[]

	RETURN


' ***** InitFlag *****
SUB InitFlag
	FOR i = 0 TO 3
		flag[i] = 0
	NEXT i
END SUB

' ***** PickWall *****
SUB PickWall
' pick a random wall 0 = N, 1 = E, 2 = S, 3 = W
' oppWall = opposite wall for nextCell

' get ok directions
	count = -1
	FOR i = 0 TO 3
		IFZ flag[i] THEN
			INC count
			flagList[count] = i
		END IF
	NEXT i

	choice = get_random (count+1)
	direction = flagList[choice]

'	direction = get_random (4)

	SELECT CASE direction
		CASE 0 : nextCelly = current_y - 1 : nextCellx = current_x : oppWall = 2
		CASE 1 : nextCellx = current_x + 1 : nextCelly = current_y : oppWall = 3
		CASE 2 : nextCelly = current_y + 1 : nextCellx = current_x : oppWall = 0
		CASE 3 : nextCellx = current_x - 1 : nextCelly = current_y : oppWall = 1
	END SELECT

END SUB

' ***** CellVisited *****
SUB CellVisited
' update visit array to keep track of which valid
' next cells that have been visited

	visit[nextCellx, nextCelly] = 1        ' 1=visited, 0=unvisited

'	GOSUB CheckVisitList

	addToList = $$FALSE
' only add cells to visitList[] that have unvisited neighbors

	IF nextCellx-1 >= 0 THEN
		IFZ visit[nextCellx-1, nextCelly] THEN addToList = $$TRUE : GOTO done
	END IF

	IF nextCellx+1 <= maze_size_x-1 THEN
		IFZ visit[nextCellx+1, nextCelly] THEN addToList = $$TRUE : GOTO done
	END IF

	IF nextCelly-1 >= 0 THEN
		IFZ visit[nextCellx, nextCelly-1] THEN addToList = $$TRUE : GOTO done
	END IF

	IF nextCelly+1 <= maze_size_y-1 THEN
		IFZ visit[nextCellx, nextCelly+1] THEN addToList = $$TRUE : GOTO done
	END IF

done:
	IF addToList THEN
		upper = UBOUND(visitList[])
		REDIM visitList[upper+1]
		visitList[upper+1].x = nextCellx
		visitList[upper+1].y = nextCelly
	END IF
END SUB

' ***** CheckVisitList *****
' redo visitList[] to include only visited cells with unvisited neighbors
' this is more efficient but SLOWER??
SUB CheckVisitList
	count = -1
	upper = UBOUND(visitList[])

	FOR i = 0 TO upper
		addToList = $$FALSE
' only add cells to visitList[] that have unvisited neighbors

		x = visitList[i].x
		y = visitList[i].y

		IF x-1 >= 0 THEN
			IFZ visit[x-1, y] THEN addToList = $$TRUE : INC count : GOTO doit
		END IF

		IF x+1 <= maze_size_x-1 THEN
			IFZ visit[x+1, y] THEN addToList = $$TRUE : INC count : GOTO doit
		END IF

		IF y-1 >= 0 THEN
			IFZ visit[x, y-1] THEN addToList = $$TRUE : INC count : GOTO doit
		END IF

		IF y+1 <= maze_size_y-1 THEN
			IFZ visit[x, y+1] THEN addToList = $$TRUE : INC count : GOTO doit
		END IF

doit:
		IF addToList THEN
			visitList[count].x = x
			visitList[count].y = y
		END IF

	NEXT i

	REDIM visitList[count]
END SUB


' ***** RemoveWall *****
SUB RemoveWall
' remove wall between currentCell and nextCell
	maze[current_x, current_y] = maze[current_x, current_y] &  ~($$WALL_TOP >> direction)
	maze[nextCellx, nextCelly] = maze[nextCellx, nextCelly] &  ~($$WALL_TOP >> oppWall)
END SUB

' ***** Swap *****
SUB Swap
' swap contents of nextCell with currentCell
	current_x = nextCellx
	current_y = nextCelly
END SUB

' ***** SelectNewCell *****
SUB SelectNewCell
' choose a cell that has already been visited
' and then pick another new wall/direction

'	current_x = get_random (maze_size_x)
'	current_y = get_random (maze_size_y)

	upper = UBOUND(visitList[])
	new = get_random (upper+1)
	current_x = visitList[new].x
	current_y = visitList[new].y

END SUB


' ***** DrawMaze *****
SUB DrawMaze
	count = 0
	FOR i = 0 TO maze_size_x - 1
		FOR j = 0 TO maze_size_y - 1
			IFZ (count MOD 2) THEN						' just draw every other cell
				SELECT CASE ALL TRUE
					CASE maze[i, j] & $$WALL_TOP 		: IF j > 0 THEN draw_wall (hdcMem, i, j, 0, gc)
					CASE maze[i, j] & $$WALL_RIGHT 	: IF i < maze_size_x-1 THEN draw_wall (hdcMem, i, j, 1, gc)
					CASE maze[i, j] & $$WALL_BOTTOM : IF j < maze_size_y-1 THEN draw_wall (hdcMem, i, j, 2, gc)
					CASE maze[i, j] & $$WALL_LEFT 	: IF i > 0 THEN draw_wall (hdcMem, i, j, 3, gc)
				END SELECT
			END IF
			INC count
		NEXT j
		INC count
	NEXT i
END SUB

END FUNCTION
END PROGRAM
