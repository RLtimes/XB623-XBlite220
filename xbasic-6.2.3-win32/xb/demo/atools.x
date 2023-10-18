'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"atools"
VERSION	"0.0005"
'
IMPORT	"xst"
IMPORT	"xgr"
IMPORT	"xui"
'
' This program demonstrates the non-modal "convenience functions"
' in GuiDesigner.  Programs can create and operate simple or complex
' GUI windows with only these ten or twelve convenience functions.
'
' This program lets the user display and operate all 32 standard
' toolkit grids, and it displays the callback messages from these
' grids as they happen.  That makes this program a good way to learn
' or review the standard toolkit grids and how they operate.
'
' #######################
' #####  FUNCTIONS  #####
' #######################
'
INTERNAL FUNCTION  Entry              ( )
INTERNAL FUNCTION  CreateDisplayGrid  ( @label, x, y, w, h )
INTERNAL FUNCTION  CreateGrids        ( x, y, w, h, grid[] )
INTERNAL FUNCTION  Initialize         ( func[], grid$[], image$[] )
INTERNAL FUNCTION  CreateListWindow   ( grid, x, y, w, h, grid$[] )
INTERNAL FUNCTION  DisplayCallback    ( label, grid, message$, v0, v1, v2, v3, kid, r1$ )
'
INTERNAL FUNCTION  CallbackHelp       ( v0$, v1$, v2$, v3$, xx$ )
INTERNAL FUNCTION  CallbackTextEvent  ( v0$, v1$, v2$, v3$, xx$ )
INTERNAL FUNCTION  CallbackTextString ( grid, kid, text$, xx$ )
'
INTERNAL FUNCTION  Color              ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Label              ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  CheckBox           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  RadioBox           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  PressButton        ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  PushButton         ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  ToggleButton       ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  RadioButton        ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  ScrollBarH         ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  ScrollBarV         ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  TextLine           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  TextArea           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Menu               ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  MenuBar            ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  PullDown           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  List               ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Message1B          ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Message2B          ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Message3B          ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Message4B          ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Progress           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Dialog2B           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Dialog3B           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Dialog4B           ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  DropButton         ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  DropBox            ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  ListButton         ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  ListBox            ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Range              ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  File               ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  Font               ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
INTERNAL FUNCTION  ListDialog2B       ( grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$ )
'
'
' #######################
' #####  CONSTANTS  #####
' #######################
'
' grid numbers of standard toolkit grids in grid[]
'
	$$XuiColor        =  0
	$$XuiLabel        =  1
	$$XuiCheckBox     =  2
	$$XuiRadioBox     =  3
	$$XuiPressButton  =  4
	$$XuiPushButton   =  5
	$$XuiToggleButton =  6
	$$XuiRadioButton  =  7
	$$XuiScrollBarH   =  8
	$$XuiScrollBarV   =  9
	$$XuiTextLine     = 10
	$$XuiTextArea     = 11
	$$XuiMenu         = 12
	$$XuiMenuBar      = 13
	$$XuiPullDown     = 14
	$$XuiList         = 15
	$$XuiMessage1B    = 16
	$$XuiMessage2B    = 17
	$$XuiMessage3B    = 18
	$$XuiMessage4B    = 19
	$$XuiProgress     = 20
	$$XuiDialog2B     = 21
	$$XuiDialog3B     = 22
	$$XuiDialog4B     = 23
	$$XuiDropButton   = 24
	$$XuiDropBox      = 25
	$$XuiListButton   = 26
	$$XuiListBox      = 27
	$$XuiRange        = 28
	$$XuiFile         = 29
	$$XuiFont         = 30
	$$XuiListDialog2B = 31
'
' windows in this program
'
	$$SwitchWindow    = 32
	$$CallbackWindow  = 33
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
' CreateListWindow() creates window with list of all 32 standard grids.
' CreateDisplayGrid() creates window to display callback arguments in.
' CreateGrids() creates one window each for the 32 standard grids.
'
'
' the message loop is typical for a convenience function program
'
' 1: Wait for one message in XgrProcessMessages(1) then process it.
' 2: Call XuiGetNextCallback() to check for a pending callback message.
' 3: If a callback message is ready & returned by XuiGetNextCallback(),
'    call the subroutine designed to handle callbacks from that grid.
' 4: Once the callback is processed, loop to continue processing.
'
'
' SUB ReportCallback displays the values of the callback arguments
' and calls a function for each grid type to get information about
' any callback arguments that are significant, plus other comments.
'
'
' SUB GridName subroutines set up v0$, v1$, v2$, v3$ with strings
' that describe each callback argument with a defined meaning.
'
'
'
FUNCTION  Entry ()
	STATIC  FUNCADDR  func[] (XLONG, STRING, XLONG, XLONG, XLONG, XLONG, XLONG, STRING, STRING, STRING, STRING, STRING, STRING, STRING)
	STATIC  terminate
'
	IFZ func[] THEN Initialize (@func[], @grid$[], @image$[])
'
'
' base window sizes on display size in pixels
'
	visible = -1
	XgrGetDisplaySize ("", @dw, @dh, @bw, @th)
	XgrCreateFont (@bigfont, @"Courier", 480, 700, 0, 0)
'
'
' create a window to display and select the standard toolkit grids
'
	xx = bw
	yy = bw + th
	ww = 160
	hh = 420
	CreateListWindow (@grid, xx, yy, ww, hh, @grid$[])
'
'
' create a window to display callback arguments
'
	x = xx + ww + bw + bw
	y = yy + 320
	w = 420
	h = dh - y - bw
	CreateDisplayGrid ( @call, x, y, w, h )
'
'
' create the 32 standard toolkit grids
'
	x = xx + ww + bw + bw
	y = yy
	w = 200
	h = 80
	CreateGrids (x, y, w, h, @grid[])
'
'
' typical convenience function message loop
'
	DO
		XgrProcessMessages (1)
		DO WHILE XuiGetNextCallback (@grid, @message$, @v0, @v1, @v2, @v3, @rr0, @r1$)
			GOSUB Callback
		LOOP
	LOOP UNTIL terminate
	RETURN ($$FALSE)
'
'
' *****  Callback  *****
'
SUB Callback
	wintag = rr0 >> 16
	kid = rr0 AND 0xFFFF
	IF (message$ = "CloseWindow") THEN QUIT (0)		' from any window
'
	SELECT CASE wintag
		CASE $$SwitchWindow	:	GOSUB SwitchWindow		' display new grid
		CASE ELSE						:	GOSUB ReportCallback	' callback arguments
	END SELECT
END SUB
'
'
' *****  ReportCallback  *****
'
SUB ReportCallback
	xx$ = ""
	v0$ = ""
	v1$ = ""
	v2$ = ""
	v3$ = ""
	kid$ = ""
	comments$ = ""
	IF (grid <= 0) THEN EXIT SUB
	IF (wintag < 0) THEN EXIT SUB
	IF (wintag > 31) THEN EXIT SUB
	XuiSendStringMessage (grid, @"GetGridName", 0, 0, 0, 0, 0, @name$)
	XuiSendStringMessage (grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @type$)
	hgrid$ = HEX$(grid,8)
	hv0$ = HEX$(v0,8)
	hv1$ = HEX$(v1,8)
	hv2$ = HEX$(v2,8)
	hv3$ = HEX$(v3,8)
	hkid$ = "    " + HEX$(kid,4)
	hwt$ = LEFT$(HEX$(rr0,8),4)
	image$ = image$[wintag]
	XuiSendStringMessage (call, @"SetImage", 0, 0, 8, 8, 0, @image$)
	@func[wintag] (grid, message$, v0, v1, v2, v3, kid, r1$, @v0$, @v1$, @v2$, @v3$, @kid$, @xx$)
'	GOSUB @sub[wintag]
	a$ = "\n\n\n\n"
	a$ = a$ + "    grid = " + hgrid$ + "\n"
	a$ = a$ + " message = " + message$ + "\n"
	a$ = a$ + "      v0 = " + hv0$ + " : " + v0$ + "\n"
	a$ = a$ + "      v1 = " + hv1$ + " : " + v1$ + "\n"
	a$ = a$ + "      v2 = " + hv2$ + " : " + v2$ + "\n"
	a$ = a$ + "      v3 = " + hv3$ + " : " + v3$ + "\n"
	a$ = a$ + "     kid = " + hkid$ + " : " + kid$ + "\n"
	a$ = a$ + "     r1$ = " + r1$ + "\n"
	a$ = a$ + "  wintag = " + hwt$
	IF xx$ THEN a$ = a$ + "\n\n" + xx$
'
	XuiSendStringMessage (call, @"SetTextString", 0, 0, 0, 0, 0, a$)
	XuiSendStringMessage (call, @"RedrawGrid", 0, 0, 0, 0, 0, 0)
	IF bigfont THEN
		XgrMoveTo (call, 48, 18)
		XgrGetGridFont (call, @temp)
		XgrSetGridFont (call, bigfont)
		XgrDrawText (call, $$LightCyan, @type$)
		XgrSetGridFont (call, temp)
	END IF
END SUB
'
'
' *****  SwitchWindow  *****
'
SUB SwitchWindow
	IF (v0 < 0) THEN EXIT SUB
	IF (v0 > 31) THEN EXIT SUB
	grid = grid[v0]
	IF grid THEN
		IF (visible >= 0) THEN
			XuiSendStringMessage (visible, @"HideWindow", 0, 0, 0, 0, 0, 0)
		END IF
		visible = grid
		XuiSendStringMessage (visible, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
	END IF
	type$ = grid$[v0]
	XgrClearGrid (call, -1)
	image$ = image$[v0]
	XuiSendStringMessage (call, @"SetImage", 0, 0, 8, 8, 0, @image$)
	XuiSendStringMessage (call, @"SetTextString", 0, 0, 0, 0, 0, "")
	XuiSendStringMessage (call, @"RedrawGrid", 0, 0, 0, 0, 0, 0)
	IF bigfont THEN
		XgrMoveTo (call, 48, 18)
		XgrGetGridFont (call, @temp)
		XgrSetGridFont (call, bigfont)
		XgrDrawText (call, $$LightCyan, @type$)
		XgrSetGridFont (call, temp)
	END IF
END SUB
END FUNCTION
'
'
' ##################################
' #####  CreateDisplayGrid ()  #####
' ##################################
'
FUNCTION  CreateDisplayGrid ( label, x, y, w, h )
  STATIC  grid
'
  IFZ grid THEN
		XuiCreateWindow      (@grid, @"XuiLabel", x, y, w, h, 0, "")
'		XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $CallbackWindow, -1)
		XuiSendStringMessage ( grid, @"SetWindowTitle", 0, 0, 0, 0, 0, @" Callback Arguments")
		XuiSendStringMessage ( grid, @"SetAlign", $$AlignUpperLeft, -1, -1, -1, 0, 0)
		XuiSendStringMessage ( grid, @"SetColor", $$Blue, $$LightGreen, -1, -1, 0, 0)
		XuiSendStringMessage ( grid, @"SetJustify", $$JustifyLeft, -1, -1, -1, 0, 0)
		XuiSendStringMessage ( grid, @"SetTexture", 0, 0, 0, 0, 0, 0)
		XuiSendStringMessage ( grid, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
  END IF
'
  label = grid
END FUNCTION
'
'
' ############################
' #####  CreateGrids ()  #####
' ############################
'
FUNCTION  CreateGrids (x, y, w, h, grid[])
	STATIC  short$[]
	STATIC  text$[]
'
	IFZ text$[] THEN GOSUB Initialize
'
'
' create and configure the XuiColor window
'
	XuiCreateWindow      (@grid, @"XuiColor", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiColor, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiColor] = grid
'
' create and configure the XuiLabel window
'
	XuiCreateWindow      (@grid, @"XuiLabel", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiLabel, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, -1, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTexture", $$TextureRaise1, $$TextureRaise1, $$TextureRaise1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiLabel] = grid
'
' create and configure the XuiCheckBox window
'
	XuiCreateWindow      (@grid, @"XuiCheckBox", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiCheckBox, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, -1, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTexture", $$TextureLower1, $$TextureLower1, $$TextureLower1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiCheckBox] = grid
'
' create and configure the XuiRadioBox window
'
	XuiCreateWindow      (@grid, @"XuiRadioBox", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiRadioBox, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, -1, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTexture", $$TextureLower1, $$TextureLower1, $$TextureLower1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiRadioBox] = grid
'
' create and configure the XuiPressButton window
'
	XuiCreateWindow      (@grid, @"XuiPressButton", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiPressButton, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, -1, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTexture", $$TextureLower1, $$TextureLower1, $$TextureLower1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiPressButton] = grid
'
' create and configure the XuiPushButton window
'
	XuiCreateWindow      (@grid, @"XuiPushButton", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiPushButton, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, -1, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTexture", $$TextureLower1, $$TextureLower1, $$TextureLower1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
'	XuiSendStringMessage ( grid, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
	grid[$$XuiPushButton] = grid
'
' create and configure the XuiToggleButton window
'
	XuiCreateWindow      (@grid, @"XuiToggleButton", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiToggleButton, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, -1, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTexture", $$TextureLower1, $$TextureLower1, $$TextureLower1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiToggleButton] = grid
'
' create and configure the XuiRadioButton window
'
	XuiCreateWindow      (@grid, @"XuiRadioButton", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiRadioButton, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, -1, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTexture", $$TextureLower1, $$TextureLower1, $$TextureLower1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiRadioButton] = grid
'
' create and configure the XuiScrollBarH window
'
	XuiCreateWindow      (@grid, @"XuiScrollBarH", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiScrollBarH, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetPosition", 0, 25, 85, 100, 0, 0)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiScrollBarH] = grid
'
' create and configure the XuiScrollBarV window
'
	XuiCreateWindow      (@grid, @"XuiScrollBarV", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiScrollBarV, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetPosition", 0, 25, 85, 100, 0, 0)
	XuiSendStringMessage ( grid, @"ResizeWindow", x, y, w, h, 0, 0)
	grid[$$XuiScrollBarV] = grid
'
' create and configure the XuiTextLine window
'
	XuiCreateWindow      (@grid, @"XuiTextLine", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiTextLine, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, " " + gridType$ + " ")
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiTextLine] = grid
'
' create and configure the XuiTextArea window
'
	XuiCreateWindow      (@grid, @"XuiTextArea", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiTextArea, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @grid$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiTextArea] = grid
'
' create and configure the XuiMenu window
'
	XuiCreateWindow      (@grid, @"XuiMenu", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiMenu, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @text$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiMenu] = grid
'
' create and configure the XuiMenuBar window
'
	XuiCreateWindow      (@grid, @"XuiMenuBar", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiMenuBar, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @"_File  _Edit  _Help")
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiMenuBar] = grid
'
' create and configure the XuiPullDown window
'
	XuiCreateWindow      (@grid, @"XuiPullDown", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiPullDown, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @short$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiPullDown] = grid
'
' create and configure the XuiList window
'
	XuiCreateWindow      (@grid, @"XuiList", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiList, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @short$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiList] = grid
'
' create and configure the XuiMessage1B window
'
	XuiCreateWindow      (@grid, @"XuiMessage1B", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiMessage1B, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiMessage1B] = grid
'
' create and configure the XuiMessage2B window
'
	XuiCreateWindow      (@grid, @"XuiMessage2B", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiMessage2B, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiMessage2B] = grid
'
' create and configure the XuiMessage3B window
'
	XuiCreateWindow      (@grid, @"XuiMessage3B", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiMessage3B, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiMessage3B] = grid
'
' create and configure the XuiMessage4B window
'
	XuiCreateWindow      (@grid, @"XuiMessage4B", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiMessage4B, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiMessage4B] = grid
'
' create and configure the XuiProgress window
'
	XuiCreateWindow      (@grid, @"XuiProgress", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiProgress, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	XuiSendStringMessage ( grid, @"SetValues", 10, 25, 75, 100, 0, 0)
	grid[$$XuiProgress] = grid
'
' create and configure the XuiDialog2B window
'
	XuiCreateWindow      (@grid, @"XuiDialog2B", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiDialog2B, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiDialog2B] = grid
'
' create and configure the XuiDialog3B window
'
	XuiCreateWindow      (@grid, @"XuiDialog3B", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiDialog3B, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiDialog3B] = grid
'
' create and configure the XuiDialog4B window
'
	XuiCreateWindow      (@grid, @"XuiDialog4B", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiDialog4B, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiDialog4B] = grid
'
' create and configure the XuiDropButton window
'
	XuiCreateWindow      (@grid, @"XuiDropButton", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiDropButton, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @short$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiDropButton] = grid
'
' create and configure the XuiDropBox window
'
	XuiCreateWindow      (@grid, @"XuiDropBox", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiDropBox, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @short$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiDropBox] = grid
'
' create and configure the XuiListButton window
'
	XuiCreateWindow      (@grid, @"XuiListButton", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiListButton, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @short$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiListButton] = grid
'
' create and configure the XuiListBox window
'
	XuiCreateWindow      (@grid, @"XuiListBox", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiListBox, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @short$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiListBox] = grid
'
' create and configure the XuiRange window
'
	XuiCreateWindow      (@grid, @"XuiRange", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiRange, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiRange] = grid
'
' create and configure the XuiFile window
'
	XuiCreateWindow      (@grid, @"XuiFile", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiFile, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @short$[])
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiFile] = grid
'
' create and configure the XuiFont window
'
	XuiCreateWindow      (@grid, @"XuiFont", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiFont, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiFont] = grid
'
' create and configure the XuiListDialog2B window
'
	XuiCreateWindow      (@grid, @"XuiListDialog2B", x, y, w, h, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$XuiListDialog2B, -1)
	XuiSendStringMessage ( grid, @"GetGridTypeName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @gridType$)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 2, @short$[])
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 3, @gridType$)
	XuiSendStringMessage ( grid, @"Resize", 0, 0, w, h, 0, 0)
	grid[$$XuiListDialog2B] = grid
'
	RETURN ($$FALSE)
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM grid[31]
	DIM text$[11]
	DIM short$[7]
'
	text$[ 0] = "_File"
	text$[ 1] = " _Load"
	text$[ 2] = " _Save"
	text$[ 3] = " _Quit"
	text$[ 4] = "_Edit"
	text$[ 5] = " _Cut"
	text$[ 6] = " _Grab"
	text$[ 7] = " _Paste"
	text$[ 8] = "_Help"
	text$[ 9] = " _Contents"
	text$[10] = " _Index"
	text$[11] = " _None"
'
	short$[0] = "Zero"
	short$[1] = "One"
	short$[2] = "Two"
	short$[3] = "Three"
	short$[4] = "Four"
	short$[5] = "Five"
	short$[6] = "Six"
	short$[7] = "Seven"
END SUB
END FUNCTION
'
'
' ###########################
' #####  Initialize ()  #####
' ###########################
'
FUNCTION  Initialize ( func[], grid$[], image$[] )
'
	DIM func[31]
	DIM grid$[31]
	DIM image$[31]
'
	func[ 0] = &Color()
	func[ 1] = &Label()
	func[ 2] = &CheckBox()
	func[ 3] = &RadioBox()
	func[ 4] = &PressButton()
	func[ 5] = &PushButton()
	func[ 6] = &ToggleButton()
	func[ 7] = &RadioButton()
	func[ 8] = &ScrollBarH()
	func[ 9] = &ScrollBarV()
	func[10] = &TextLine()
	func[11] = &TextArea()
	func[12] = &Menu()
	func[13] = &MenuBar()
	func[14] = &PullDown()
	func[15] = &List()
	func[16] = &Message1B()
	func[17] = &Message2B()
	func[18] = &Message3B()
	func[19] = &Message4B()
	func[20] = &Progress()
	func[21] = &Dialog2B()
	func[22] = &Dialog3B()
	func[23] = &Dialog4B()
	func[24] = &DropButton()
	func[25] = &DropBox()
	func[26] = &ListButton()
	func[27] = &ListBox()
	func[28] = &Range()
	func[29] = &File()
	func[30] = &Font()
	func[31] = &ListDialog2B()
'
	grid$[ 0] = "XuiColor"
	grid$[ 1] = "XuiLabel"
	grid$[ 2] = "XuiCheckBox"
	grid$[ 3] = "XuiRadioBox"
	grid$[ 4] = "XuiPressButton"
	grid$[ 5] = "XuiPushButton"
	grid$[ 6] = "XuiToggleButton"
	grid$[ 7] = "XuiRadioButton"
	grid$[ 8] = "XuiScrollBarH"
	grid$[ 9] = "XuiScrollBarV"
	grid$[10] = "XuiTextLine"
	grid$[11] = "XuiTextArea"
	grid$[12] = "XuiMenu"
	grid$[13] = "XuiMenuBar"
	grid$[14] = "XuiPullDown"
	grid$[15] = "XuiList"
	grid$[16] = "XuiMessage1B"
	grid$[17] = "XuiMessage2B"
	grid$[18] = "XuiMessage3B"
	grid$[19] = "XuiMessage4B"
	grid$[20] = "XuiProgress"
	grid$[21] = "XuiDialog2B"
	grid$[22] = "XuiDialog3B"
	grid$[23] = "XuiDialog4B"
	grid$[24] = "XuiDropButton"
	grid$[25] = "XuiDropBox"
	grid$[26] = "XuiListButton"
	grid$[27] = "XuiListBox"
	grid$[28] = "XuiRange"
	grid$[29] = "XuiFile"
	grid$[30] = "XuiFont"
	grid$[31] = "XuiListDialog2B"
'
	image$[ 0] = "$XBDIR\\xxx\\xcolor.bmp"
	image$[ 1] = "$XBDIR\\xxx\\xlabel.bmp"
	image$[ 2] = "$XBDIR\\xxx\\xcheckbx.bmp"
	image$[ 3] = "$XBDIR\\xxx\\xradiobx.bmp"
	image$[ 4] = "$XBDIR\\xxx\\xpress.bmp"
	image$[ 5] = "$XBDIR\\xxx\\xpush.bmp"
	image$[ 6] = "$XBDIR\\xxx\\xtoggle.bmp"
	image$[ 7] = "$XBDIR\\xxx\\xradio.bmp"
	image$[ 8] = "$XBDIR\\xxx\\xscrollh.bmp"
	image$[ 9] = "$XBDIR\\xxx\\xscrollv.bmp"
	image$[10] = "$XBDIR\\xxx\\xtxtline.bmp"
	image$[11] = "$XBDIR\\xxx\\xtxtarea.bmp"
	image$[12] = "$XBDIR\\xxx\\xmenu.bmp"
	image$[13] = "$XBDIR\\xxx\\xmenubar.bmp"
	image$[14] = "$XBDIR\\xxx\\xpullist.bmp"
	image$[15] = "$XBDIR\\xxx\\xsclist.bmp"
	image$[16] = "$XBDIR\\xxx\\xmess1.bmp"
	image$[17] = "$XBDIR\\xxx\\xmess2.bmp"
	image$[18] = "$XBDIR\\xxx\\xmess3.bmp"
	image$[19] = "$XBDIR\\xxx\\xmess4.bmp"
	image$[20] = "$XBDIR\\xxx\\xprogres.bmp"
	image$[21] = "$XBDIR\\xxx\\xdialog2.bmp"
	image$[22] = "$XBDIR\\xxx\\xdialog3.bmp"
	image$[23] = "$XBDIR\\xxx\\xdialog4.bmp"
	image$[24] = "$XBDIR\\xxx\\xdropbut.bmp"
	image$[25] = "$XBDIR\\xxx\\xdropbox.bmp"
	image$[26] = "$XBDIR\\xxx\\xlistbut.bmp"
	image$[27] = "$XBDIR\\xxx\\xlistbox.bmp"
	image$[28] = "$XBDIR\\xxx\\xrange.bmp"
	image$[29] = "$XBDIR\\xxx\\xfiles.bmp"
	image$[30] = "$XBDIR\\xxx\\xfont.bmp"
	image$[31] = "$XBDIR\\xxx\\xlist2b.bmp"
END FUNCTION
'
'
' #################################
' #####  CreateListWindow ()  #####
' #################################
'
FUNCTION  CreateListWindow (grid, xx, yy, ww, hh, grid$[])
'
	XuiCreateWindow      (@grid, @"XuiList", xx, yy, ww, hh, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $$SwitchWindow, -1)
	XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @grid$[])
	XuiSendStringMessage ( grid, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' ################################
' #####  DisplayCallback ()  #####
' ################################
'
FUNCTION  DisplayCallback ( label, grid, message$, v0, v1, v2, v3, kid, r1$ )
'
  text$ = ""
  text$ = text$ + "   grid = " + STRING$ (grid) + "\n"
  text$ = text$ + "message = " + message$ + "\n"
  text$ = text$ + "     v0 = " + STRING$ (v0) + "\n"
  text$ = text$ + "     v1 = " + STRING$ (v1) + "\n"
  text$ = text$ + "     v2 = " + STRING$ (v2) + "\n"
  text$ = text$ + "     v3 = " + STRING$ (v3) + "\n"
  text$ = text$ + "    kid = " + STRING$ (kid) + "\n"
  text$ = text$ + "    r1$ = " + r1$
'
  XuiSendStringMessage (label, @"SetTextString", 0, 0, 0, 0, 0, @text$)
  XuiSendStringMessage (label, @"Redraw", 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' #############################
' #####  CallbackHelp ()  #####
' #############################
'
FUNCTION  CallbackHelp (v0$, v1$, v2$, v3$, xx$)
'
	v0$ = "x : mouse cursor"
	v1$ = "y : mouse cursor"
	v2$ = ""
	v3$ = ""
	xx$ = ""
END FUNCTION
'
'
' ##################################
' #####  CallbackTextEvent ()  #####
' ##################################
'
FUNCTION  CallbackTextEvent (v0$, v1$, v2$, v3$, xx$)
'
	v0$ = "xDisp : mouse cursor"
	v1$ = "yDisp : mouse cursor"
	v2$ = "state"
	v3$ = "time"
	xx$ = ""
END FUNCTION
'
'
' ###################################
' #####  CallbackTextString ()  #####
' ###################################
'
FUNCTION  CallbackTextString (grid, kid, text$, xx$)
'
	XuiSendStringMessage (grid, @"GetTextString", 0, 0, 0, 0, kid, @text$)
	IF text$ THEN
		xx$ = "\n"
		xx$ = xx$ + "\n " + r1$ + " TextString : \"" + text$ + "\""
	END IF
END FUNCTION
'
'
' ######################
' #####  Color ()  #####
' ######################
'
FUNCTION  Color (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiColorSelection
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiColorSelection  *****
'
SUB XuiColorSelection
	XgrColorNumberToName (v0, @xx$)
	IF xx$ THEN color$ = " : " + xx$
	v0$ = "color #" + color$
	v1$ = "red     : 0x0000 to 0xFFFF"
	v2$ = "green   : 0x0000 to 0xFFFF"
	v3$ = "blue    : 0x0000 to 0xFFFF"
	IF xx$ THEN xx$ = "\n\n " + xx$
END SUB
END FUNCTION
'
'
' ######################
' #####  Label ()  #####
' ######################
'
FUNCTION  Label (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' #########################
' #####  CheckBox ()  #####
' #########################
'
FUNCTION  CheckBox (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiCheckBoxSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiCheckBoxSelection  *****
'
SUB XuiCheckBoxSelection
	IF v0 THEN
		v0$ = "selected"
	ELSE
		v0$ = "not selected"
	END IF
	v2$ = "state"
	v3$ = "time"
END SUB
END FUNCTION
'
'
' #########################
' #####  RadioBox ()  #####
' #########################
'
FUNCTION  RadioBox (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiRadioBoxSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiRadioBoxSelection  *****
'
SUB XuiRadioBoxSelection
	IF v0 THEN
		v0$ = "selected"
	ELSE
		v0$ = "not selected"
	END IF
END SUB
END FUNCTION
'
'
' ############################
' #####  PressButton ()  #####
' ############################
'
FUNCTION  PressButton (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiPressButtonSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiPressButtonSelection  *****
'
SUB XuiPressButtonSelection
	v2$ = "state"
	v3$ = "time"
END SUB
END FUNCTION
'
'
' ###########################
' #####  PushButton ()  #####
' ###########################
'
FUNCTION  PushButton (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiPushButtonSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiPushButtonSelection  *****
'
SUB XuiPushButtonSelection
	v2$ = "state"
	v3$ = "time"
END SUB
END FUNCTION
'
'
' #############################
' #####  ToggleButton ()  #####
' #############################
'
FUNCTION  ToggleButton (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiToggleButtonSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiToggleButtonSelection  *****
'
SUB XuiToggleButtonSelection
	IF v0 THEN
		v0$ = "selected"
	ELSE
		v0$ = "not selected"
	END IF
	v2$ = "state"
	v3$ = "time"
END SUB
END FUNCTION
'
'
' ############################
' #####  RadioButton ()  #####
' ############################
'
FUNCTION  RadioButton (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiRadioButtonSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiRadioButtonSelection  *****
'
SUB XuiRadioButtonSelection
	IF v0 THEN
		v0$ = "selected"
	ELSE
		v0$ = "not selected"
	END IF
END SUB
END FUNCTION
'
'
' ###########################
' #####  ScrollBarH ()  #####
' ###########################
'
FUNCTION  ScrollBarH (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "MuchLess"		: GOSUB XuiScrollBarCallback
		CASE "SomeLess"		: GOSUB XuiScrollBarCallback
		CASE "OneLess"		: GOSUB XuiScrollBarCallback
		CASE "Change"			: GOSUB XuiScrollBarCallback
		CASE "OneMore"		: GOSUB XuiScrollBarCallback
		CASE "SomeMore"		: GOSUB XuiScrollBarCallback
		CASE "MuchMore"		: GOSUB XuiScrollBarCallback
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiScrollBarCallback  *****
'
SUB XuiScrollBarCallback
	v0$ = " min position"
	v1$ = " low position"
	v2$ = "high position"
	v3$ = " max position"
END SUB
END FUNCTION
'
'
' ###########################
' #####  ScrollBarV ()  #####
' ###########################
'
FUNCTION  ScrollBarV (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "MuchLess"		: GOSUB XuiScrollBarCallback
		CASE "SomeLess"		: GOSUB XuiScrollBarCallback
		CASE "OneLess"		: GOSUB XuiScrollBarCallback
		CASE "Change"			: GOSUB XuiScrollBarCallback
		CASE "OneMore"		: GOSUB XuiScrollBarCallback
		CASE "SomeMore"		: GOSUB XuiScrollBarCallback
		CASE "MuchMore"		: GOSUB XuiScrollBarCallback
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiScrollBarCallback  *****
'
SUB XuiScrollBarCallback
	v0$ = " min position"
	v1$ = " low position"
	v2$ = "high position"
	v3$ = " max position"
END SUB
END FUNCTION
'
'
' #########################
' #####  TextLine ()  #####
' #########################
'
FUNCTION  TextLine (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiTextLineSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiTextLineSelection  *****
'
SUB XuiTextLineSelection
	v0$ = "state"
	XuiSendStringMessage (grid, @"GetTextString", 0, 0, 0, 0, 0, @text$)
	xx$ = "\n"
	xx$ = xx$ + "\n Text line : \"" + text$ + "\""
END SUB
END FUNCTION
'
'
' #########################
' #####  TextArea ()  #####
' #########################
'
FUNCTION  TextArea (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' #####################
' #####  Menu ()  #####
' #####################
'
FUNCTION  Menu (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiMenuSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiMenuSelection  *****
'
SUB XuiMenuSelection
	v0$ = "MenuBar entry : 1+"
	v1$ = "PullDown item : 0+"
	XuiSendStringMessage (grid, @"GetTextArray", 0, 0, 0, 0, 0, @text$[])
	IFZ text$[] THEN EXIT SUB
	u = UBOUND (text$[])
	menubar = 0
	FOR i = 0 TO u
		text$ = text$[i]
		IF text$ THEN
			char = text${0}
			IF ((char != ' ') AND (char != '	')) THEN		' not tab or space
				INC menubar
				IF (menubar = v0) THEN
					header = i
					EXIT FOR
				END IF
			END IF
		END IF
	NEXT i
	IF (v0 = menubar) THEN
		menu$ = text$[header]
		list = header + v1 + 1
		IF (list <= u) THEN list$ = text$[list]
		xx$ = "\n"
		xx$ = xx$ + "\n Menu entry : \"" + menu$ + "\""
		xx$ = xx$ + "\n List entry : \"" + list$ + "\""
	END IF
END SUB
END FUNCTION
'
'
' ########################
' #####  MenuBar ()  #####
' ########################
'
FUNCTION  MenuBar (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiMenuBarSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiMenuBarSelection  *****
'
SUB XuiMenuBarSelection
	v0$ = "MenuBar entry : 1+"
	XuiSendStringMessage (grid, @"GetTextString", 0, 0, 0, 0, 0, @text$)
	IFZ text$ THEN EXIT SUB
	item = $$FALSE
	done = $$FALSE
	pos = $$FALSE
	DO UNTIL (item >= v0)
		INC item
		item$ = XstNextField$ (@text$, @pos, @done)
	LOOP UNTIL done
	IF item$ THEN
		IF (v0 = item) THEN
			xx$ = "\n"
			xx$ = xx$ + "\n MenuBar item : \"" + item$ + "\""
		END IF
	END IF
END SUB
END FUNCTION
'
'
' #########################
' #####  PullDown ()  #####
' #########################
'
FUNCTION  PullDown (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiPullDownSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiPullDownSelection  *****
'
SUB XuiPullDownSelection
	v0$ = "PullDown item = 0+"
	XuiSendStringMessage (grid, @"GetTextArrayLine", v0, 0, 0, 0, 0, @text$)
	IF text$ THEN
		xx$ = "\n"
		xx$ = xx$ + "\n PullDown item : " + text$
	END IF
END SUB
END FUNCTION
'
'
' #####################
' #####  List ()  #####
' #####################
'
FUNCTION  List (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiListSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiListSelection  *****
'
SUB XuiListSelection
	v0$ = "List item : 0+"
	XuiSendStringMessage (grid, @"GetTextArrayLine", v0, 0, 0, 0, 0, @list$)
	IF (v0 >= 0) THEN
		xx$ = "\n"
		xx$ = xx$ + "\n List item = " + list$
	END IF
END SUB
END FUNCTION
'
'
' ##########################
' #####  Message1B ()  #####
' ##########################
'
FUNCTION  Message1B (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: CallbackTextString (grid, kid, @text$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' ##########################
' #####  Message2B ()  #####
' ##########################
'
FUNCTION  Message2B (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: CallbackTextString (grid, kid, @text$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' ##########################
' #####  Message3B ()  #####
' ##########################
'
FUNCTION  Message3B (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: CallbackTextString (grid, kid, @text$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' ##########################
' #####  Message4B ()  #####
' ##########################
'
FUNCTION  Message4B (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: CallbackTextString (grid, kid, @text$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' #########################
' #####  Progress ()  #####
' #########################
'
FUNCTION  Progress (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' #########################
' #####  Dialog2B ()  #####
' #########################
'
FUNCTION  Dialog2B (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: CallbackTextString (grid, kid, @text$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' #########################
' #####  Dialog3B ()  #####
' #########################
'
FUNCTION  Dialog3B (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: CallbackTextString (grid, kid, @text$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' #########################
' #####  Dialog4B ()  #####
' #########################
'
FUNCTION  Dialog4B (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: CallbackTextString (grid, kid, @text$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
END FUNCTION
'
'
' ###########################
' #####  DropButton ()  #####
' ###########################
'
FUNCTION  DropButton (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiDropButtonSelection
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiDropButtonSelection  *****
'
SUB XuiDropButtonSelection
	v0$ = "PullDown item : 0+"
	XuiSendStringMessage (grid, @"GetTextArrayLine", v0, 0, 0, 0, 0, @text$)
	xx$ = "\n"
	xx$ = xx$ + "\n List item : " + text$
END SUB
END FUNCTION
'
'
' ########################
' #####  DropBox ()  #####
' ########################
'
FUNCTION  DropBox (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiDropBoxSelection
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiDropBoxSelection  *****
'
SUB XuiDropBoxSelection
	v0$ = "PullDown item : 0+"
	XuiSendStringMessage (grid, @"GetTextArrayLine", v0, 0, 0, 0, 0, @list$)
	XuiSendStringMessage (grid, @"GetTextString", v0, 0, 0, 0, 0, @text$)
	xx$ = "\n"
	xx$ = xx$ + "\n List item : " + list$
	xx$ = xx$ + "\n Text item : " + text$
END SUB
END FUNCTION
'
'
' ###########################
' #####  ListButton ()  #####
' ###########################
'
FUNCTION  ListButton (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiListButtonSelection
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiListButtonSelection  *****
'
SUB XuiListButtonSelection
	v0$ = "List item : 0+"
	XuiSendStringMessage (grid, @"GetTextArrayLine", v0, 0, 0, 0, 0, @text$)
	xx$ = "\n"
	xx$ = xx$ + "\n List item : " + text$
END SUB
END FUNCTION
'
'
' ########################
' #####  ListBox ()  #####
' ########################
'
FUNCTION  ListBox (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiListBoxSelection
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiListBoxSelection  *****
'
SUB XuiListBoxSelection
	v0$ = "List item : 0+"
	XuiSendStringMessage (grid, @"GetTextArrayLine", v0, 0, 0, 0, 0, @list$)
	XuiSendStringMessage (grid, @"GetTextString", 0, 0, 0, 0, 0, @text$)
	xx$ = "\n"
	xx$ = xx$ + "\n List item : " + list$
	xx$ = xx$ + "\n Text item : " + text$
END SUB
END FUNCTION
'
'
' ######################
' #####  Range ()  #####
' ######################
'
FUNCTION  Range (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiRangeSelection
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiRangeSelection  *****
'
SUB XuiRangeSelection
	v0$ = "value"
	v1$ = "delta : +/-1"
	v2$ = "minimum"
	v3$ = "maximum"
	xx$ = ""
END SUB
END FUNCTION
'
'
' #####################
' #####  File ()  #####
' #####################
'
FUNCTION  File (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiFileSelection
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiFileSelection  *****
'
SUB XuiFileSelection
	IF (v0 < 0) THEN
		v0$ = "cancel"
	ELSE
		XuiSendStringMessage (grid, @"GetTextString", 0, 0, 0, 0, 2, @file$)
		IF file$ THEN xx$ = "\n\n selected file : " + file$ + "\n"
		XstGetFileAttributes (@file$, @attributes)
		IFZ attributes THEN
			xx$ = xx$ + "\n $$FileNonexistent"
		ELSE
			SELECT CASE ALL TRUE
				CASE (attributes AND $$FileReadOnly)		: xx$ = xx$ + "\n $$FileReadOnly"
				CASE (attributes AND $$FileHidden)			: xx$ = xx$ + "\n $$FileHidden"
				CASE (attributes AND $$FileSystem)			: xx$ = xx$ + "\n $$FileSystem"
				CASE (attributes AND $$FileDirectory)		: xx$ = xx$ + "\n $$FileDirectory"
				CASE (attributes AND $$FileArchive)			: xx$ = xx$ + "\n $$FileArchive"
				CASE (attributes AND $$FileNormal)			: xx$ = xx$ + "\n $$FileNormal"
				CASE (attributes AND $$FileTemporary)		: xx$ = xx$ + "\n $$FileTemporary"
				CASE (attributes AND $$FileAtomicWrite)	: xx$ = xx$ + "\n $$FileAtomicWrite"
				CASE (attributes AND $$FileExecutable)	: xx$ = xx$ + "\n $$FileExecutable"
			END SELECT
		END IF
	END IF
END SUB
END FUNCTION
'
'
' #####################
' #####  Font ()  #####
' #####################
'
FUNCTION  Font (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiFontSelection
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiFontSelection  *****
'
SUB XuiFontSelection
	font = v0
	IF (font < 0) THEN
		v0$ = "cancel"
	ELSE
		XgrGetFontInfo (font, @font$, @size, @weight, @italic, @angle)
		v0$ = "font #"
		IF font$ THEN
			xx$ = "\n"
			xx$ = xx$ + "\n font information from XgrGetFontInfo() ***\n"
			xx$ = xx$ + "\n    name : " + font$
			xx$ = xx$ + "\n    size : " + RJUST$(STRING$(size),4)
			xx$ = xx$ + "\n  weight : " + RJUST$(STRING$(weight),4)
			xx$ = xx$ + "\n  italic : " + RJUST$(STRING$(italic),4)
			xx$ = xx$ + "\n   angle : " + RJUST$(STRING$(angle),4)
			xx$ = xx$ + "\n"
			xx$ = xx$ + "\n    name : typeface name"
			xx$ = xx$ + "\n    size : 20 * size in points"
			xx$ = xx$ + "\n  weight : 0 to 1000 : 400 normal : 700 bold"
			xx$ = xx$ + "\n  italic : 0 to 1000 :   0 normal else italic"
			xx$ = xx$ + "\n   angle : 0 to 3600 :  .1 degree units"
		END IF
	END IF
END SUB
END FUNCTION
'
'
' #############################
' #####  ListDialog2B ()  #####
' #############################
'
FUNCTION  ListDialog2B (grid, message$, v0, v1, v2, v3, kid, r1$, v0$, v1$, v2$, v3$, kid$, xx$)
'
	SELECT CASE message$
		CASE "Selection"	: GOSUB XuiListDialog2BSelection
		CASE "TextEvent"	: CallbackTextEvent (@v0$, @v1$, @v2$, @v3$, @xx$)
		CASE "Help"				: CallbackHelp (@v0$, @v1$, @v2$, @v3$, @xx$)
	END SELECT
	RETURN
'
'
' *****  XuiListDialog2BSelection  *****
'
SUB XuiListDialog2BSelection
	SELECT CASE kid
		CASE 2	: GOSUB XuiListDialog2BList
		CASE 3	: GOSUB XuiListDialog2BTextLine
		CASE 4	: GOSUB XuiListDialog2BEnterButton
		CASE 5	: GOSUB XuiListDialog2BCancelButton
	END SELECT
END SUB
'
'
' *****  XuiListDialog2BList  *****
'
SUB XuiListDialog2BList
	v0$ = "List item : 0+"
	XuiSendStringMessage (grid, @"GetTextArrayLine", v0, 0, 0, 0, 2, @list$)
	IF list$ THEN
		xx$ = "\n"
		xx$ = xx$ + "\n List item = " + list$
	END IF
END SUB
'
'
' *****  XuiListDialog2BTextLine  *****
'
SUB XuiListDialog2BTextLine
	XuiSendStringMessage (grid, @"GetTextString", v0, 0, 0, 0, 3, @text$)
	IF text$ THEN
		xx$ = "\n"
		xx$ = xx$ + "\n Text line = " + text$
	END IF
END SUB
'
'
' *****  XuiListDialog2BEnterButton  *****
'
SUB XuiListDialog2BEnterButton
	XuiSendStringMessage (grid, @"GetTextCursor", @pos, @line, 0, 0, 2, 0)
	XuiSendStringMessage (grid, @"GetTextArrayLine", line, 0, 0, 0, 2, @list$)
	XuiSendStringMessage (grid, @"GetTextString", v0, 0, 0, 0, 3, @text$)
	xx$ = "\n"
	xx$ = xx$ + "\n Enter Button"
	xx$ = xx$ + "\n  List item = " + list$
	xx$ = xx$ + "\n  Text line = " + text$
END SUB
'
'
' *****  XuiListDialog2BCancelButton  *****
'
SUB XuiListDialog2BCancelButton
	xx$ = "\n"
	xx$ = xx$ + "\n Cancel Button"
END SUB
END FUNCTION
END PROGRAM
