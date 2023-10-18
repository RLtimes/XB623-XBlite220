'
'
' ##############################  Max Reason
' #####  GraphicsDesigner  #####  copyright 1988-2000
' ##############################  Linux XBasic GraphicsDesigner
'
' subject to LGPL license - see COPYING_LIB
'
' maxreason@maxreason.com
'
' for Linux XBasic
'
'
PROGRAM	"xgr"
VERSION	"0.0515"
'
IMPORT	"xma"			' math library
IMPORT	"xst"			' standard library
IMPORT	"clib"		' C standard library
IMPORT	"xwin"		' XWindows library
'
EXPORT
'
'
' **********************************************
' *****  GraphicsDesigner COMPOSITE TYPES  *****
' **********************************************
'
TYPE MESSAGE
	XLONG			.wingrid						' window/grid number
	XLONG			.message						' message number
	XLONG			.v0									' arguments
	XLONG			.v1
	XLONG			.v2
	XLONG			.v3
	XLONG			.r0
	XLONG			.r1
END TYPE
END EXPORT
'
'
' *****  DIB = Device Independent Bitmap  *****
'
' A complete DIB contains:
'   		1		BitmapFileHeader
'   		1		BitmapInfoHeader
'   0-256		RGBQUAD elements (the palette) (0-2 RGB mask for 16,32)
'				*		image data
'
TYPE BitmapFileHeader				' 14 bytes
	USHORT   .bfType					' "BM"
	XLONG    .bfSize					' total DIB file size in bytes
	USHORT   .res1						'
	USHORT   .res2						'
	XLONG    .bfOffBits				' offset from file beginning to image data
END TYPE
'
TYPE BitmapInfoHeader
	XLONG    .size						' size of BitmapInfoHeader in bytes
	XLONG    .width						' width of image in pixels
	XLONG    .height					' height of image in pixels
	USHORT   .planes          ' always = 1
	USHORT   .bitCount				' bits per pixel (1,4,8,16,24,32)
	XLONG    .compression			' compression scheme (0 = none, 3 = BI_BITFIELDS)
	XLONG    .sizeImage				' ignore unless image compression
	XLONG    .xPixelsPerMeter	'
	XLONG    .yPixelsPerMeter	'
	XLONG    .colors					' number of colors in image
	XLONG    .importantColors	' number of important colors in image
END TYPE
'
' In a DIB, RGBQUAD data follows BitmapInfoHeader if bitCount = 1,4,8
' This data defines the pallete - it maps each pixel value into RGB.
' For bitCount = 1,4,8 there are 2,16,256 RGBQUAD elements.
'
' For bitCount = 16,24,32 there are three XLONG values (not RGBQUAD),
' one each for a mask to define red,green,blue bit fields, as in:
'			red		: 0xFFC00000		' 10 bits of red
'			green	: 0x003FF800		' 11 bits of green
'			blue	: 0x000007FF		' 11 bits of blue
'
'
TYPE RGBQUAD								'
	UBYTE    .blue						'
	UBYTE    .green						'
	UBYTE    .red							'
	UBYTE    .zero						'
END TYPE
'
'	status bits
'		0:  1 = actions registered	(by XgrCreateWindow)
'		1:  1 = colormap installed	(by XgrCreateWindow)
'
TYPE DISPLAY									' 1024 bytes : host display information
	XLONG   .display            ' native display #
	XLONG   .sdisplay           ' system display #
	XLONG   .status							' 0 if not open
	XLONG   .selectedWindow     '
	XLONG   .x                  ' should be 0
	XLONG   .y                  ' should be 0
	XLONG   .width              '
	XLONG   .height             '
	XLONG		.root								' native root window # (someday)
	XLONG   .reserved						'
	XLONG   .borderWidth       	' nominal
	XLONG   .titleHeight        ' nominal
	XLONG   .mouseX             '
	XLONG   .mouseY             '
	XLONG		.mouseState         '
	XLONG   .mouseTime          '
	XLONG		.mouseGrid          '
	XLONG   .mouseWindow        '
	XLONG   .mouseMessage       '
	XLONG   .mouseFocusGrid     ' ignored
	XLONG   .depth              '
	XLONG   .class              '
	XLONG		.screen							' X-Windows screen
	XLONG		.visual							' screen visual
	XLONG		.sroot              ' system root window #
	XLONG   .connect            ' connection file descriptor
	XLONG   .bitGravity         '
	XLONG   .winGravity         '
	XLONG   .backingStore       '
	XLONG   .backingPlanes      '
	XLONG   .backingPixel       '
	XLONG   .saveUnder          '
	XLONG   .mapInstalled       '
	XLONG   .mapState           '
	XLONG   .allEventMasks      '
	XLONG   .yourEventMask      '
	XLONG   .doNotPropagateMask '
	XLONG   .overrideRedirect   '
	XLONG   .defaultColormap    '
	XLONG   .colormap           '
	XLONG   .black              ' system color #
	XLONG   .white              ' system color #
	XLONG   .resyyy             '
	XLONG   .reszzz             '
	XLONG   .color[127]         ' native color # to system color #
	XLONG		.a[83]              ' pad / reserved
END TYPE
'
' *********************************
' *****  Xgr COMPOSITE TYPES  *****
' *********************************
'
TYPE FONT
	XLONG   .font								' native font #
	XLONG   .sfont							' system font #
	XLONG   .addrFont						' system font structure address
	XLONG   .count							' number of times created
	XLONG   .width							' max width of character cell
	XLONG   .height							' max height of character cell
	XLONG   .ascent							' baseline to highest top
	XLONG   .descent						' baseline to lowest bottom
	XLONG   .size               ' point size * 10
	XLONG   .weight             ' 0-1000 : thin, light, medium, bold, heavy
	XLONG   .italic             ' 0-1000 : slant-left, upright, slant-right
	XLONG   .angle              ' baseline angle in .1 degree units
	XLONG   .space
	XLONG   .gap
	XLONG   .resX
	XLONG   .resY
END TYPE
'
TYPE POINT
	XLONG		.x									' x position
	XLONG		.y									' y position
END TYPE
'
TYPE DPOINT
	DOUBLE	.x									' x# position
	DOUBLE	.y									' y# position
END TYPE
'
TYPE BOX
	XLONG		.x1									' x position of 1st corner
	XLONG		.y1									' y position of 1st corner
	XLONG		.x2									' x position of 2nd corner
	XLONG		.y2									' y position of 2nd corner
END TYPE
'
TYPE DBOX
	DOUBLE	.x1									' x# position of 1st corner
	DOUBLE	.y1									' y# position of 1st corner
	DOUBLE	.x2									' x# position of 2nd corner
	DOUBLE	.y2									' y# position of 2nd corner
END TYPE
'
TYPE LINE = BOX
TYPE DLINE = DBOX
'
TYPE WINDOW                   ' 512 bytes : native window and grid information
	XLONG   .window             ' 00 : 0 if unallocated (wingrid #0 is invalid)
	XLONG   .parent             ' 01 : native parent #
	XLONG   .leader             ' 02 : native window # this window follows
	XLONG   .kind               ' 04 : top window, grid, etc.
	XLONG   .type               ' 03 : window/grid type (windowType/gridType)
	XLONG   .top                ' 05 : native window # of top window in family
	XLONG   .winFunc            ' 06 : native window function address
	XLONG   .gridFunc           ' 07 : native grid function address
	XLONG   .display            ' 08 : native display #
	XLONG   .buffer             ' 09 : image grid to buffer graphics
	XLONG   .bufferX            ' 0A : image grid to buffer graphics
	XLONG   .bufferY            ' 0B : image grid to buffer graphics
	XLONG   .font               ' 0C : native font #
	XLONG   .border             ' 0D : current border # or function to draw it
	XLONG   .borderUp           ' 0E : normal border # or function to draw it
	XLONG   .borderDown         ' 0F : active border # or function to draw it
	XLONG   .backgroundColor    ' 10 : native color # of background color
	XLONG   .drawingColor       ' 11 : native color # of drawing color
	XLONG   .lowlightColor      ' 12 : native color # of 3D shadow color
	XLONG   .highlightColor     ' 13 : native color # of 3D highlight color
	XLONG   .dullColor          ' 14 : native color # of dull color
	XLONG   .accentColor        ' 15 : native color # of accent color
	XLONG   .lowtextColor       ' 16 : native color # of 3D text shadow color
	XLONG   .hightextColor      ' 17 : native color # of 3D text highlight color
	XLONG   .backColor          ' 18 : standard color of current background color
	XLONG   .backBlue           ' 19 : blue intensity of current background color
	XLONG   .backGreen          ' 1A : green intensity of current background color
	XLONG   .backRed            ' 1B : red intensity of current background color
	XLONG   .drawColor          ' 1C : standard color of current drawing color
	XLONG   .drawBlue           ' 1D : blue intensity of current drawing color
	XLONG   .drawGreen          ' 1E : green intensity of current drawing color
	XLONG   .drawRed            ' 1F : red intensity of current drawing color
	XLONG   .priorX             ' 20 : previous X position
	XLONG   .priorY             ' 21 : previous Y position
	XLONG   .priorWidth         ' 22 : previous width
	XLONG   .priorHeight        ' 23 : previous height
	XLONG   .visibility         ' 24 : hidden/displayed/iconfied (0/1/2, -1=never)
	XLONG   .priorVisibility    ' 25 : previous visibility
	XLONG   .visibilityRequest  ' 26 : visibility function called, waiting for event to confirm
	XLONG   .mapped             ' 27 : changed only by MapNotify/UnmapNotify
	XLONG   .lineWidth          ' 28 : last lineWidth
	XLONG   .lineStyle          ' 29 : last lineStyle
	XLONG   .drawMode           ' 2A : last drawMode
	XLONG   .state              ' 2B : window or grid disable / enable
	XLONG   .borderWidth        ' 2C : in pixels - determined in "reparent" event
	XLONG   .titleHeight        ' 2D : in pixels - determined in "reparent" event
	XLONG   .whomask            ' 2E : owner ##WHOMASK
	XLONG   .timer              ' 2F : timer ID
	XLONG   .x                  ' 30 : left edge of window on parent or display
	XLONG   .y                  ' 31 : top edge of window on parent or display
	XLONG   .width              ' 32 : width of window interior
	XLONG   .height             ' 33 : height of window interior
	XLONG   .minWidth           ' 34 : minimum width
	XLONG   .minHeight          ' 35 : minimum height
	XLONG   .maxWidth           ' 36 : maximum width
	XLONG   .maxHeight          ' 37 : maximum height
	XLONG   .borderOffsetLeft   ' 38 :
	XLONG   .borderOffsetTop    ' 39 :
	XLONG   .borderOffsetRight  ' 3A :
	XLONG   .borderOffsetBottom ' 3B :
	XLONG   .gridBoxX1          ' 3C : corners of grid-box in grid coords
	XLONG   .gridBoxY1          ' 3D : corners of grid-box in grid coords
	XLONG   .gridBoxX2          ' 3E : corners of grid-box in grid coords
	XLONG   .gridBoxY2          ' 3F : corners of grid-box in grid coords
	DOUBLE  .gridBoxScaledX1    ' 40 : corners of grid-box in scaled coords
	DOUBLE  .gridBoxScaledY1    ' 42 : corners of grid-box in scaled coords
	DOUBLE  .gridBoxScaledX2    ' 44 : corners of grid-box in scaled coords
	DOUBLE  .gridBoxScaledY2    ' 46 : corners of grid-box in scaled coords
	DOUBLE  .xPixelsPerScaled   ' 48 : x grid units equal 1 scaled unit (signed)
	DOUBLE  .yPixelsPerScaled   ' 4A : y grid units equal 1 scaled unit (signed)
	DOUBLE  .xScaledPerPixel    ' 4C : x scaled units equal 1 grid unit (signed)
	DOUBLE  .yScaledPerPixel    ' 4E : y scaled units equal 1 grid unit (signed)
	DOUBLE  .drawpointScaledX   ' 50 : scaled coords
	DOUBLE  .drawpointScaledY   ' 52 : scaled coords
	XLONG   .drawpointGridX     ' 54 : gridbox coords
	XLONG   .drawpointGridY     ' 55 : gridbox coords
	XLONG   .drawpointX         ' 56 : local coords
	XLONG   .drawpointY         ' 57 : local coords
	XLONG   .clipX              ' 58 : left edge of clip box
	XLONG   .clipY              ' 59 : top edge of clip box
	XLONG   .clipWidth          ' 5A : current clipping width
	XLONG   .clipHeight         ' 5B : current clipping height
	XLONG   .icon               ' 5C :
	XLONG   .sicon              ' 5D :
	XLONG   .iconWidth          ' 5E :
	XLONG   .iconHeight         ' 5F :
	XLONG   .stop               ' 60 : system window # of top window in family x
	XLONG   .sroot              ' 61 : system window # of root window x
	XLONG   .sframe             ' 62 : system window # of frame window (motif) x
	XLONG   .sdisplay           ' 63 : system display # x
	XLONG   .swindow            ' 64 : system window # x
	XLONG   .sparent            ' 65 : system parent window # x
	XLONG   .scursor            ' 66 : system cursor # x
	XLONG   .gc                 ' 67 : graphics context
	XLONG   .visual             ' 68 : address of system visual structure x
	XLONG   .clickTime          ' 69 : last mouse button down time
	XLONG   .clickCount         ' 6A : count of mouse button clicks
	XLONG   .clickButton        ' 6B : # of last mouse button down
	XLONG   .sbackground        ' 6C : current system background pixel x
	XLONG   .sforeground        ' 6D : current system foreground pixel x
	XLONG   .sbackgroundDefault ' 6E : system background pixel for default background color
	XLONG   .sforegroundDefault ' 6F : system foreground pixel for default drawing color
	XLONG   .eventMask          ' 70 : XSelectInput() event mask
	XLONG   .x71                ' 71 :
	XLONG   .x72                ' 72 :
	XLONG   .x73                ' 73 :
	XLONG   .x74                ' 74 :
	XLONG   .x75                ' 75 :
	XLONG   .x76                ' 76 :
	XLONG   .x77                ' 77 :
	XLONG   .x78                ' 78 :
	XLONG   .x79                ' 79 :
	XLONG   .x7A                ' 7A :
	XLONG   .x7B                ' 7B :
	XLONG   .destroy            ' 7C : destroy requested
	XLONG   .destroyed          ' 7D : destroyed event processed
	XLONG   .destroyProcessed 	' 7E : destroyed message processed
	XLONG   .x7F                ' 7F :
END TYPE
'
TYPE MOUSESTATE
	XLONG   .type               '
	XLONG   .window             '
	XLONG   .swindow            '
	XLONG   .time               '
	XLONG   .xWin               '
	XLONG   .yWin               '
	XLONG   .xDisp              '
	XLONG   .yDisp              '
	XLONG   .state              '
	XLONG   .button             ' 0 for motion event
	XLONG   .res1[5]
END TYPE
'
'
' *****  xlib "fake" types  *****
'
' TYPE Display     = XLONG       '
' TYPE Screen      = XLONG       '
' TYPE Visual      = XLONG       '
' TYPE Pixmap      = XLONG       '
' TYPE GC          = XLONG       ' address of opaque structure
' TYPE Font        = XLONG       ' font ID number
' TYPE XFontStruct = XLONG       ' address of font structure
'
'
' #######################
' #####  FUNCTIONS  #####
' #######################
'
' miscellaneous functions
'
EXPORT
DECLARE FUNCTION  Xgr                         ()
DECLARE FUNCTION  XgrBorderNameToNumber       (border$, @border)
DECLARE FUNCTION  XgrBorderNumberToName       (border, @border$)
DECLARE FUNCTION  XgrBorderNumberToWidth      (border, @width)
DECLARE FUNCTION  XgrColorNameToNumber        (color$, @color)
DECLARE FUNCTION  XgrColorNumberToName        (color, @color$)
DECLARE FUNCTION  XgrCursorNameToNumber       (cursor$, @cursor)
DECLARE FUNCTION  XgrCursorNumberToName       (cursor, @cursor$)
DECLARE FUNCTION  XgrGetClipboard             (clipboard, type, @data$, UBYTE @data[])
DECLARE FUNCTION  XgrGetCursor                (cursor)
DECLARE FUNCTION  XgrGetCursorOverride        (cursor)
DECLARE FUNCTION  XgrGetDisplaySize           (display$, @w, @h, @bw, @th)
DECLARE FUNCTION  XgrGetKeystateModify        (state, @modify, @edit)
DECLARE FUNCTION  XgrIconNameToNumber         (icon$, @icon)
DECLARE FUNCTION  XgrIconNumberToName         (icon, @icon$)
DECLARE FUNCTION  XgrRegisterCursor           (cursor$, @cursor)
DECLARE FUNCTION  XgrRegisterIcon             (icon$, @icon)
DECLARE FUNCTION  XgrSetClipboard             (clipboard, type, @data$, UBYTE @data[])
DECLARE FUNCTION  XgrSetCursor                (cursor, @oldCursor)
DECLARE FUNCTION  XgrSetCursorOverride        (cursor, @oldCursorOverride)
DECLARE FUNCTION  XgrSetDebug                 (debug)
DECLARE FUNCTION  XgrSystemWindowToWindow     (swindow, @wingrid, @top)
DECLARE FUNCTION  XgrWindowToSystemWindow     (wingrid, @swindow)
DECLARE FUNCTION  XgrVersion$                 ()
DECLARE FUNCTION  XgrResetUserMode            ()
'
' font functions
'
DECLARE FUNCTION  XgrCreateFont               (@font, fontName$, fontSize, fontWeight, fontItalic, fontAngle)
DECLARE FUNCTION  XgrDestroyFont              (font)
DECLARE FUNCTION  XgrGetFontInfo              (font, @fontName$, @fontSize, @fontWeight, @fontItalic, @fontAngle)
DECLARE FUNCTION  XgrGetFontMetrics           (font, @maxCharWidth, @maxCharHeight, @ascent, @descent, @gap, @space)
DECLARE FUNCTION  XgrGetFontNames             (@count, @fontName$[])
DECLARE FUNCTION  XgrGetTextArrayImageSize    (font, @text$[], @w, @h, @width, @height, extraX, extraY)
DECLARE FUNCTION  XgrGetTextImageSize         (font, @text$, @dx, @dy, @width, @height, @gap, @space)
'
' color functions
'
DECLARE FUNCTION  XgrConvertColorToRGB        (color, red, green, blue)
DECLARE FUNCTION  XgrConvertRGBToColor        (red, green, blue, color)
DECLARE FUNCTION  XgrGetBackgroundColor       (grid, color)
DECLARE FUNCTION  XgrGetBackgroundRGB         (grid, red, green, blue)
DECLARE FUNCTION  XgrGetDefaultColors         (back, draw, low, high, dull, acc, lowtext, hightext)
DECLARE FUNCTION  XgrGetDrawingColor          (grid, color)
DECLARE FUNCTION  XgrGetDrawingRGB            (grid, red, green, blue)
DECLARE FUNCTION  XgrGetGridColors            (grid, back, draw, low, high, dull, acc, lowtext, hightext)
DECLARE FUNCTION  XgrSetBackgroundColor       (grid, color)
DECLARE FUNCTION  XgrSetBackgroundRGB         (grid, red, green, blue)
DECLARE FUNCTION  XgrSetDefaultColors         (back, draw, low, high, dull, acc, lowtext, hightext)
DECLARE FUNCTION  XgrSetDrawingColor          (grid, color)
DECLARE FUNCTION  XgrSetDrawingRGB            (grid, red, green, blue)
DECLARE FUNCTION  XgrSetGridColors            (grid, back, draw, low, high, dull, acc, lowtext, hightext)
'
' window functions
'
DECLARE FUNCTION  XgrCreateWindow             (@window, windowType, x, y, width, height, winFunc, display$)
DECLARE FUNCTION  XgrDestroyWindow            (window)
DECLARE FUNCTION  XgrDisplayWindow            (window)
DECLARE FUNCTION  XgrGetModalWindow           (@window)
DECLARE FUNCTION  XgrGetWindowDisplay         (window, @display$)
DECLARE FUNCTION  XgrGetWindowFunction        (window, @func)
DECLARE FUNCTION  XgrGetWindowIcon            (window, @icon)
DECLARE FUNCTION  XgrGetWindowGrid            (window, @grid)
DECLARE FUNCTION  XgrGetWindowPositionAndSize (window, @x, @y, @width, @height)
DECLARE FUNCTION  XgrGetWindowState           (window, @visibility)
DECLARE FUNCTION  XgrGetWindowTitle           (window, @title$)
DECLARE FUNCTION  XgrGetWindowVisibility      (window, @visibility)
DECLARE FUNCTION  XgrHideWindow               (window)
DECLARE FUNCTION  XgrMaximizeWindow           (window)
DECLARE FUNCTION  XgrMinimizeWindow           (window)
DECLARE FUNCTION  XgrRestoreWindow            (window)
DECLARE FUNCTION  XgrSetModalWindow           (window)
DECLARE FUNCTION  XgrSetWindowFunction        (window, func)
DECLARE FUNCTION  XgrSetWindowIcon            (window, icon)
DECLARE FUNCTION  XgrSetWindowPositionAndSize (window, xDisp, yDisp, width, height)
DECLARE FUNCTION  XgrSetWindowState           (window, visibility)
DECLARE FUNCTION  XgrSetWindowTitle           (window, title$)
DECLARE FUNCTION  XgrSetWindowVisibility      (window, visibility)
DECLARE FUNCTION  XgrShowWindow               (window)
'
' coordinate functions
'
DECLARE FUNCTION  XgrConvertDisplayToGrid     (grid, xDisp, yDisp, @xGrid, @yGrid)
DECLARE FUNCTION  XgrConvertDisplayToLocal    (grid, xDisp, yDisp, @x, @y)
DECLARE FUNCTION  XgrConvertDisplayToScaled   (grid, xDisp, yDisp, @x#, @y#)
DECLARE FUNCTION  XgrConvertDisplayToWindow   (grid, xDisp, yDisp, @xWin, @yWin)
DECLARE FUNCTION  XgrConvertGridToDisplay     (grid, xGrid, yGrid, @xDisp, @yDisp)
DECLARE FUNCTION  XgrConvertGridToLocal       (grid, xGrid, yGrid, @x, @y)
DECLARE FUNCTION  XgrConvertGridToScaled      (grid, xGrid, yGrid, @x#, @y#)
DECLARE FUNCTION  XgrConvertGridToWindow      (grid, xGrid, yGrid, @xWin, @yWin)
DECLARE FUNCTION  XgrConvertLocalToDisplay    (grid, x, y, @xDisp, @yDisp)
DECLARE FUNCTION  XgrConvertLocalToGrid       (grid, x, y, @xGrid, @yGrid)
DECLARE FUNCTION  XgrConvertLocalToScaled     (grid, x, y, @x#, @y#)
DECLARE FUNCTION  XgrConvertLocalToWindow     (grid, x, y, @xWin, @yWin)
DECLARE FUNCTION  XgrConvertScaledToDisplay   (grid, x#, y#, @xDisp, @yDisp)
DECLARE FUNCTION  XgrConvertScaledToGrid      (grid, x#, y#, @x, @y)
DECLARE FUNCTION  XgrConvertScaledToLocal     (grid, x#, y#, @x, @y)
DECLARE FUNCTION  XgrConvertScaledToWindow    (grid, x#, y#, @xWin, @yWin)
DECLARE FUNCTION  XgrConvertWindowToDisplay   (grid, xWin, yWin, @xDisp, @yDisp)
DECLARE FUNCTION  XgrConvertWindowToGrid      (grid, xWin, yWin, @xGrid, @yGrid)
DECLARE FUNCTION  XgrConvertWindowToLocal     (grid, xWin, yWin, @x, @y)
DECLARE FUNCTION  XgrConvertWindowToScaled    (grid, xWin, yWin, @x#, @y#)
'
DECLARE FUNCTION  XgrGetGridBox               (grid, @x1Grid, @y1Grid, @x2Grid, @y2Grid)
DECLARE FUNCTION  XgrGetGridBoxDisplay        (grid, @x1Disp, @y1Disp, @x2Disp, @y2Disp)
DECLARE FUNCTION  XgrGetGridBoxGrid           (grid, @x1Grid, @y1Grid, @x2Grid, @y2Grid)
DECLARE FUNCTION  XgrGetGridBoxLocal          (grid, @x1, @y1, @x2, @y2)
DECLARE FUNCTION  XgrGetGridBoxScaled         (grid, @x1#, @y1#, @x2#, @y2#)
DECLARE FUNCTION  XgrGetGridBoxWindow         (grid, @x1Win, @y1Win, @x2Win, @y2Win)
DECLARE FUNCTION  XgrGetGridCoordinates       (grid, @x, @y, @x1, @y1, @x2, @y2)
DECLARE FUNCTION  XgrGetGridPositionAndSize   (grid, @x, @y, @width, @height)
DECLARE FUNCTION  XgrSetGridBox               (grid, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrSetGridBoxGrid           (grid, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrSetGridBoxScaled         (grid, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrSetGridBoxScaledAt       (grid, x1#, y1#, x2#, y2#, x1, y1, x2, y2)
DECLARE FUNCTION  XgrSetGridPositionAndSize   (grid, x, y, width, height)
'
' grid functions
'
DECLARE FUNCTION  XgrCreateGrid               (@grid, gridType, x, y, width, height, window, parent, func)
DECLARE FUNCTION  XgrDestroyGrid              (grid)
DECLARE FUNCTION  XgrGetGridBorder            (grid, @border, @borderA, @borderB, @borderFlags)
DECLARE FUNCTION  XgrGetGridBorderOffset      (grid, @left, @top, @right, @bottom)
DECLARE FUNCTION  XgrGetGridBuffer            (grid, @buffer, @x, @y)
DECLARE FUNCTION  XgrGetGridCharacterMapArray (grid, @map[])
DECLARE FUNCTION  XgrGetGridDrawingMode       (grid, @mode, @lineStyle, @lineWidth)
DECLARE FUNCTION  XgrGetGridFont              (grid, @font)
DECLARE FUNCTION  XgrGetGridFunction          (grid, @func)
DECLARE FUNCTION  XgrGetGridParent            (grid, @parent)
DECLARE FUNCTION  XgrGetGridState             (grid, @state)
DECLARE FUNCTION  XgrGetGridType              (grid, @type)
DECLARE FUNCTION  XgrGetGridWindow            (grid, @window)
DECLARE FUNCTION  XgrGridTypeNameToNumber     (type$, @type)
DECLARE FUNCTION  XgrGridTypeNumberToName     (type, @type$)
DECLARE FUNCTION  XgrRegisterGridType         (type$, @type)
DECLARE FUNCTION  XgrSetGridBorder            (grid, border, borderA, borderB, borderFlags)
DECLARE FUNCTION  XgrSetGridBorderOffset      (grid, left, top, right, bottom)
DECLARE FUNCTION  XgrSetGridBuffer            (grid, buffer, x, y)
DECLARE FUNCTION  XgrSetGridDrawingMode       (grid, mode, lineStyle, lineWidth)
DECLARE FUNCTION  XgrSetGridFont              (grid, font)
DECLARE FUNCTION  XgrSetGridFunction          (grid, func)
DECLARE FUNCTION  XgrSetGridParent            (grid, parent)
DECLARE FUNCTION  XgrSetGridState             (grid, state)
DECLARE FUNCTION  XgrSetGridTimer             (grid, msec)
DECLARE FUNCTION  XgrSetGridType              (grid, type)
DECLARE FUNCTION  XgrSetGridCharacterMapArray (grid, @map[])
'
' drawing functions
'
DECLARE FUNCTION  XgrClearGrid                (grid, color)
DECLARE FUNCTION  XgrClearWindow              (window, color)
DECLARE FUNCTION  XgrDrawArc                  (grid, color, r, startAngle#, endAndge#)
DECLARE FUNCTION  XgrDrawArcGrid              (grid, color, r, startAngle#, endAndge#)
DECLARE FUNCTION  XgrDrawArcScaled            (grid, color, r#, startAngle#, endAndge#)
DECLARE FUNCTION  XgrDrawBorder               (grid, border, back, low, high, x1, y1, x2, y2)
DECLARE FUNCTION  XgrDrawBorderGrid           (grid, border, back, low, high, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrDrawBorderScaled         (grid, border, back, low, high, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrDrawBox                  (grid, color, x1, y1, x2, y2)
DECLARE FUNCTION  XgrDrawBoxGrid              (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrDrawBoxScaled            (grid, color, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrDrawCircle               (grid, color, r)
DECLARE FUNCTION  XgrDrawCircleGrid           (grid, color, r)
DECLARE FUNCTION  XgrDrawCircleScaled         (grid, color, r#)
DECLARE FUNCTION  XgrDrawEllipse              (grid, color, rx, ry)
DECLARE FUNCTION  XgrDrawEllipseGrid          (grid, color, rx, ry)
DECLARE FUNCTION  XgrDrawEllipseScaled        (grid, color, rx#, ry#)
DECLARE FUNCTION  XgrDrawGridBorder           (grid, border)
DECLARE FUNCTION  XgrDrawLine                 (grid, color, x1, y1, x2, y2)
DECLARE FUNCTION  XgrDrawLineGrid             (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrDrawLineScaled           (grid, color, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrDrawLineTo               (grid, color, x, y)
DECLARE FUNCTION  XgrDrawLineToGrid           (grid, color, xGrid, yGrid)
DECLARE FUNCTION  XgrDrawLineToScaled         (grid, color, x#, y#)
DECLARE FUNCTION  XgrDrawLineToDelta          (grid, color, dx, dy)
DECLARE FUNCTION  XgrDrawLineToDeltaGrid      (grid, color, dxGrid, dyGrid)
DECLARE FUNCTION  XgrDrawLineToDeltaScaled    (grid, color, dx#, dy#)
DECLARE FUNCTION  XgrDrawLines                (grid, color, first, count, ANY line[])
DECLARE FUNCTION  XgrDrawLinesGrid            (grid, color, first, count, ANY line[])
DECLARE FUNCTION  XgrDrawLinesScaled          (grid, color, first, count, ANY line[])
DECLARE FUNCTION  XgrDrawLinesTo              (grid, color, first, count, ANY line[])
DECLARE FUNCTION  XgrDrawLinesToGrid          (grid, color, first, count, ANY line[])
DECLARE FUNCTION  XgrDrawLinesToScaled        (grid, color, first, count, ANY line[])
DECLARE FUNCTION  XgrDrawPoint                (grid, color, x, y)
DECLARE FUNCTION  XgrDrawPointGrid            (grid, color, xGrid, yGrid)
DECLARE FUNCTION  XgrDrawPointScaled          (grid, color, x#, y#)
DECLARE FUNCTION  XgrDrawPoints               (grid, color, first, count, ANY point[])
DECLARE FUNCTION  XgrDrawPointsGrid           (grid, color, first, count, ANY point[])
DECLARE FUNCTION  XgrDrawPointsScaled         (grid, color, first, count, ANY point[])
DECLARE FUNCTION  XgrDrawText                 (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextGrid             (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextScaled           (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextFill             (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextFillGrid         (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextFillScaled       (grid, color, text$)
DECLARE FUNCTION  XgrFillBox                  (grid, color, x1, y1, x2, y2)
DECLARE FUNCTION  XgrFillBoxGrid              (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrFillBoxScaled            (grid, color, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrFillTriangle             (grid, color, style, direction, x1, y1, x2, y2)
DECLARE FUNCTION  XgrFillTriangleGrid         (grid, color, style, direction, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrFillTriangleScaled       (grid, color, style, direction, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrGetDrawpoint             (grid, x, y)
DECLARE FUNCTION  XgrGetDrawpointGrid         (grid, xGrid, yGrid)
DECLARE FUNCTION  XgrGetDrawpointScaled       (grid, x#, y#)
DECLARE FUNCTION  XgrGrabPoint                (grid, x, y, @r, @g, @b, @color)
DECLARE FUNCTION  XgrGrabPointGrid            (grid, xGrid, yGrid, @r, @g, @b, @color)
DECLARE FUNCTION  XgrGrabPointScaled          (grid, x#, y#, @r, @g, @b, @color)
DECLARE FUNCTION  XgrMoveDelta                (grid, dx, dy)
DECLARE FUNCTION  XgrMoveDeltaGrid            (grid, dxGrid, dyGrid)
DECLARE FUNCTION  XgrMoveDeltaScaled          (grid, dx#, dy#)
DECLARE FUNCTION  XgrMoveTo                   (grid, x, y)
DECLARE FUNCTION  XgrMoveToGrid               (grid, xGrid, yGrid)
DECLARE FUNCTION  XgrMoveToScaled             (grid, x#, y#)
DECLARE FUNCTION  XgrRedrawWindow             (window, action, x, y, width, height)
DECLARE FUNCTION  XgrSetDrawpoint             (grid, x, y)
DECLARE FUNCTION  XgrSetDrawpointGrid         (grid, xGrid, yGrid)
DECLARE FUNCTION  XgrSetDrawpointScaled       (grid, x#, y#)
'
' image functions
'
DECLARE FUNCTION  XgrCopyImage                (grid, source)
DECLARE FUNCTION  XgrDrawImage                (grid, source, sx1, sy1, width, height, dx1, dy1)
DECLARE FUNCTION  XgrGetImage                 (grid, UBYTE image[])
DECLARE FUNCTION  XgrGetImage32               (grid, UBYTE image[])
DECLARE FUNCTION  XgrGetImageArrayInfo        (UBYTE image[], @depth, @width, @height)
DECLARE FUNCTION  XgrLoadImage                (file$, UBYTE image[])
DECLARE FUNCTION  XgrRefreshGrid              (grid)
DECLARE FUNCTION  XgrSaveImage                (file$, UBYTE image[])
DECLARE FUNCTION  XgrSetImage                 (grid, UBYTE image[])
'
' focus functions
'
DECLARE FUNCTION  XgrGetMouseInfo             (@window, @grid, @x, @y, @state, @time)
DECLARE FUNCTION  XgrGetSelectedWindow        (@window)
DECLARE FUNCTION  XgrGetTextSelectionGrid     (@grid)
DECLARE FUNCTION  XgrSetSelectedWindow        (window)
DECLARE FUNCTION  XgrSetTextSelectionGrid     (grid)
'
' message functions
'
DECLARE FUNCTION  XgrAddMessage               (wingrid, message, v0, v1, v2, v3, r0, r1)
DECLARE FUNCTION  XgrDeleteMessages           (count)
DECLARE FUNCTION  XgrGetCEO                   (func)
DECLARE FUNCTION  XgrGetMessages              (@count, MESSAGE @message[])
DECLARE FUNCTION  XgrGetMessageType           (message, @messageType)
DECLARE FUNCTION  XgrGetMonitors              (grid, MESSAGE @monitor[])
DECLARE FUNCTION  XgrJamMessage               (wingrid, message, v0, v1, v2, v3, r0, r1)
DECLARE FUNCTION  XgrMessageNameToNumber      (message$, @message)
DECLARE FUNCTION  XgrMessageNames             (@count, @message$[])
DECLARE FUNCTION  XgrMessageNumberToName      (message, @message$)
DECLARE FUNCTION  XgrMessagesPending          (count)
DECLARE FUNCTION  XgrMonitor                  (grid, message, v0, v1, v2, v3, r0, r1)
DECLARE FUNCTION  XgrPeekMessage              (wingrid, message, v0, v1, v2, v3, r0, r1)
DECLARE FUNCTION  XgrProcessMessages          (count)
DECLARE FUNCTION  XgrRegisterMessage          (message$, @message)
DECLARE FUNCTION  XgrSendMessage              (wingrid, message, v0, v1, v2, v3, r0, r1)
DECLARE FUNCTION  XgrSendStringMessage        (wingrid, message$, v0, v1, v2, v3, r0, r1)
DECLARE FUNCTION  XgrSetCEO                   (func)
'
' old names and functions - stubs to be link compatible with GuiDesigner
'
DECLARE FUNCTION  XgrGetColors                (grid, @back, @draw, @low, @high, @dull, @acc, @lowtext, @hightext)
DECLARE FUNCTION  XgrGetGridClip              (grid, @clip)
DECLARE FUNCTION  XgrRegisterIconColor        (icon$, @icon)
DECLARE FUNCTION  XgrSetColors                (grid, back, draw, low, high, dull, acc, lowtext, hightext)
DECLARE FUNCTION  XgrSetGridClip              (grid, clip)
DECLARE FUNCTION  XgrGetSystemDisplay					()
END EXPORT
'
' private externally visible functions
'
DECLARE FUNCTION  XxxCheckMessages            ()
DECLARE FUNCTION  XxxDispatchEvents           (arg1, arg2)
DECLARE FUNCTION  XxxXgrBlowback              ()
DECLARE FUNCTION  XxxXgrGridTimer             (timer, count, msec, time)
DECLARE FUNCTION  XxxXgrQuit                  ()
DECLARE FUNCTION  XxxXgrSetHelpWindow         (helpWindow)
DECLARE FUNCTION  XxxXgrSetHuh                (huh)
DECLARE FUNCTION  XxxXgrWindowToSystemDisplayAndWindow (window, @sdisplay, @swindow)
'
DECLARE FUNCTION  XxxDIBToDIB24               (UBYTE simage[], UBYTE dimage[])
DECLARE FUNCTION  XxxDIBToDIB32               (UBYTE simage[], UBYTE dimage[])
'
' ****************************************
' *****  internal support functions  *****
' ****************************************
'
INTERNAL FUNCTION  ConvertColorToSystemColor   (grid, color, @pixel)
INTERNAL FUNCTION  ConvertRGBToSystemColor     (grid, red, green, blue, @pixel)
INTERNAL FUNCTION  CreateQueue                 (queue)
INTERNAL FUNCTION  DestroySystemResources      ()
INTERNAL FUNCTION  DestroyUserResources        ()
INTERNAL FUNCTION  DispatchEvents              (sync, wait)
INTERNAL FUNCTION  Display                     (display, command, display$)
INTERNAL FUNCTION  Font                        (@font, command, display, @sfont, @addrFont, size, bold, italic, angle, ufont$)
INTERNAL FUNCTION  GetNewWindowNumber          (@wingrid)
INTERNAL FUNCTION  GraphicsContext             (@gc, command, sdisplay, screen, swindow, sfont)
INTERNAL FUNCTION  InvalidCursor               (cursor)
INTERNAL FUNCTION  InvalidDisplay              (display)
INTERNAL FUNCTION  InvalidFont                 (font)
INTERNAL FUNCTION  InvalidGrid                 (grid)
INTERNAL FUNCTION  InvalidGridType             (gridType)
INTERNAL FUNCTION  InvalidIcon                 (icon)
INTERNAL FUNCTION  InvalidWindow               (window)
INTERNAL FUNCTION  KeyboardMessage             (message)
INTERNAL FUNCTION  Log                         (log$, newline)
INTERNAL FUNCTION  MouseMessage                (message)
INTERNAL FUNCTION  NormalAngle                 (angle#)
INTERNAL FUNCTION  NormalAnglePlusMinus        (angle#)
INTERNAL FUNCTION  RedrawGridAndKids           (grid, action, xWin, yWin, width, height)
INTERNAL FUNCTION  RemoveMessage               (window, message, v0,v1,v2,v3,r0,r1)
INTERNAL FUNCTION  SetBackgroundColor          (window, color)
INTERNAL FUNCTION  SetBackgroundRGB            (window, red, green, blue)
INTERNAL FUNCTION  SetDrawingColor             (window, color)
INTERNAL FUNCTION  SetDrawingRGB               (window, red, green, blue)
INTERNAL FUNCTION  SystemButtonStateToButtonState   (button, system, time, state)
INTERNAL FUNCTION  SystemKeyStateToKeyState         (message, keysym, system, time, state)
INTERNAL FUNCTION  UpdateMouse                 (who)
INTERNAL FUNCTION  UpdateScaledCoordinates     (grid)
INTERNAL FUNCTION  LocalToBufferCoords         (grid, buffer, @sbuffer, @overlap, x1, y1, x2, y2, @xx1, @yy1, @xx2, @yy2)
'
' private external functions
'
EXTERNAL FUNCTION  XxxGetImplementation        (name$)
EXTERNAL FUNCTION  XxxXstLog                   (text$)
EXTERNAL FUNCTION  XxxGetEbpEsp                (@ebp, @esp)
EXTERNAL CFUNCTION  printf                     (addr, ...)
'
'
' ************************************
' *****  system event functions  *****
' ************************************
'
' each event function handles one event - the event gives the function its name.
' the following table shows what event structures are passed to each function.
'
' event               function                    xlib structure
'
' ButtonPress         EventButtonPress()          XButtonEvent
' ButtonRelease       EventButtonRelease()        XButtonEvent
' CirculateNotify     EventCirculateNotify()      XCirculateEvent
' CirculateRequest    EventCirculateRequest()     XCirculateRequestEvent
' ClientMessage       EventClientMessage()        XClientMessageEvent
' ColormapNotify      EventColormapNotify()       XColormapEvent
' ConfigureNotify     EventConfigureNotify()      XConfigureEvent
' ConfigureRequest    EventConfigureRequest()     XConfigureRequestEvent
' CreateNotify        EventCreateNotify()         XCreateWindowEvent
' DestroyNotify       EventDestroyNotify()        XDestroyWindowEvent
' EnterNotify         EventEnterNotify()          XCrossingEvent
' Error               EventError()                XErrorEvent
' Expose              EventExpose()               XExposeEvent
' FocusIn             EventFocusIn()              XFocusChangeEvent
' FocusOut            EventFocusOut()             XFocusChangeEvent
' GraphicsExpose      EventGraphicsExpose()       XGraphicsExposeEvent
' GravityNotify       EventGravityNotify()        XGravityEvent
' KeyPress            EventKeyPress()             XKeyEvent
' KeyRelease          EventKeyRelease()           XKeyEvent
' KeymapNotify        EventKeymapNotify()         XKeymapEvent
' LeaveNotify         EventLeaveNotify()          XCrossingEvent
' MapNotify           EventMapNotify()            XMapEvent
' MapRequest          EventMapRequest()           XMapRequestEvent
' MappingNotify       EventMappingNotify()        XMappingEvent
' MotionNotify        EventMotionNotify()         XMotionEvent
' NoExpose            EventNoExpose()             XNoExposeEvent
' PropertyNotify      EventPropertyNotify()       XPropertyEvent
' ReparentNotify      EventReparentNotify()       XReparentEvent
' ResizeRequest       EventResizeRequest()        XResizeRequestEvent
' SelectionClear      EventSelectionClear()       XSelectionClearEvent
' SelectionNotify     EventSelectionNotify()      XSelectionEvent
' SelectionRequest    EventSelectionRequest()     XSelectionRequestEvent
' UnmapNotify         EventUnmapNotify()          XUnmapEvent
' VisibilityNotify    EventVisibilityNotify()     XVisibilityEvent
'
'
INTERNAL FUNCTION  EventButtonPress          (ANY)
INTERNAL FUNCTION  EventButtonRelease        (ANY)
INTERNAL FUNCTION  EventCirculateNotify      (ANY)
INTERNAL FUNCTION  EventCirculateRequest     (ANY)
INTERNAL FUNCTION  EventClientMessage        (ANY)
INTERNAL FUNCTION  EventColormapNotify       (ANY)
INTERNAL FUNCTION  EventConfigureNotify      (ANY)
INTERNAL FUNCTION  EventConfigureRequest     (ANY)
INTERNAL FUNCTION  EventCreateNotify         (ANY)
INTERNAL FUNCTION  EventDestroyNotify        (ANY)
INTERNAL FUNCTION  EventEnterNotify          (ANY)
INTERNAL FUNCTION  EventError                (ANY)
INTERNAL FUNCTION  EventExpose               (ANY)
INTERNAL FUNCTION  EventFocusIn              (ANY)
INTERNAL FUNCTION  EventFocusOut             (ANY)
INTERNAL FUNCTION  EventGraphicsExpose       (ANY)
INTERNAL FUNCTION  EventGravityNotify        (ANY)
INTERNAL FUNCTION  EventKeyPress             (ANY)
INTERNAL FUNCTION  EventKeyRelease           (ANY)
INTERNAL FUNCTION  EventKeymapNotify         (ANY)
INTERNAL FUNCTION  EventLeaveNotify          (ANY)
INTERNAL FUNCTION  EventMapNotify            (ANY)
INTERNAL FUNCTION  EventMapRequest           (ANY)
INTERNAL FUNCTION  EventMappingNotify        (ANY)
INTERNAL FUNCTION  EventMotionNotify         (ANY)
INTERNAL FUNCTION  EventNoExpose             (ANY)
INTERNAL FUNCTION  EventPropertyNotify       (ANY)
INTERNAL FUNCTION  EventReparentNotify       (ANY)
INTERNAL FUNCTION  EventResizeRequest        (ANY)
INTERNAL FUNCTION  EventSelectionClear       (ANY)
INTERNAL FUNCTION  EventSelectionNotify      (ANY)
INTERNAL FUNCTION  EventSelectionRequest     (ANY)
INTERNAL FUNCTION  EventUnmapNotify          (ANY)
INTERNAL FUNCTION  EventVisibilityNotify     (ANY)
'
INTERNAL FUNCTION  PrintWindowAttributes     (XWindowAttributes)
'
INTERNAL FUNCTION  PrintButtonPress          (ANY)
INTERNAL FUNCTION  PrintButtonRelease        (ANY)
INTERNAL FUNCTION  PrintCirculateNotify      (ANY)
INTERNAL FUNCTION  PrintCirculateRequest     (ANY)
INTERNAL FUNCTION  PrintClientMessage        (ANY)
INTERNAL FUNCTION  PrintColormapNotify       (ANY)
INTERNAL FUNCTION  PrintConfigureNotify      (ANY)
INTERNAL FUNCTION  PrintConfigureRequest     (ANY)
INTERNAL FUNCTION  PrintCreateNotify         (ANY)
INTERNAL FUNCTION  PrintDestroyNotify        (ANY)
INTERNAL FUNCTION  PrintEnterNotify          (ANY)
INTERNAL FUNCTION  PrintErrorX               (ANY)
INTERNAL FUNCTION  PrintExpose               (ANY)
INTERNAL FUNCTION  PrintFocusIn              (ANY)
INTERNAL FUNCTION  PrintFocusOut             (ANY)
INTERNAL FUNCTION  PrintGraphicsExpose       (ANY)
INTERNAL FUNCTION  PrintGravityNotify        (ANY)
INTERNAL FUNCTION  PrintKeyPress             (ANY)
INTERNAL FUNCTION  PrintKeyRelease           (ANY)
INTERNAL FUNCTION  PrintKeymapNotify         (ANY)
INTERNAL FUNCTION  PrintLeaveNotify          (ANY)
INTERNAL FUNCTION  PrintMapNotify            (ANY)
INTERNAL FUNCTION  PrintMapRequest           (ANY)
INTERNAL FUNCTION  PrintMappingNotify        (ANY)
INTERNAL FUNCTION  PrintMotionNotify         (ANY)
INTERNAL FUNCTION  PrintNoExpose             (ANY)
INTERNAL FUNCTION  PrintPropertyNotify       (ANY)
INTERNAL FUNCTION  PrintReparentNotify       (ANY)
INTERNAL FUNCTION  PrintResizeRequest        (ANY)
INTERNAL FUNCTION  PrintSelectionClear       (ANY)
INTERNAL FUNCTION  PrintSelectionNotify      (ANY)
INTERNAL FUNCTION  PrintSelectionRequest     (ANY)
INTERNAL FUNCTION  PrintUnmapNotify          (ANY)
INTERNAL FUNCTION  PrintVisibilityNotify     (ANY)
'
INTERNAL FUNCTION  JunkHeap                  ()
INTERNAL FUNCTION  DefaultFontNames          (count, name$[])
'
EXPORT
'
' ****************************************
' *****  GraphicsDesigner Constants  *****
' ****************************************
'
' *****  kind of entity  *****
'
  $$KindWindow          = 1    ' same as $$Window
  $$KindGrid            = 2    ' same as $$Grid
  $$KindImage           = 4    ' same as $$Image
  $$Window              = 1    ' window = top level window, including pop-up
  $$Grid                = 2    ' grid = subwindow
  $$Image               = 4    ' image = pixmap
'
' permanently defined grid types (also registered as #GridTypeXXXX)
'
  $$GridTypeCoordinate  = 0    ' coordinate grid
  $$GridTypeImage       = 1    ' memory image
  $$GridTypeBuffer      = 1    ' alias
'
' permanently defined clipboard types
'
  $$ClipboardTypeNone   = 0    ' no contents
  $$ClipboardTypeText   = 1    ' ASCII text
  $$ClipboardTypeImage  = 2    ' DIB image
'
' *****  debug type  *****
'
  $$DebugBrief          = 1
  $$DebugWordy          = 2
  $$DebugError          = 4
'
' *****  monitor type  *****
'
  $$MonitorContext      = 1
  $$MonitorHelp         = 2
  $$MonitorKeyboard     = 4
  $$MonitorMouse        = 8
'
' *****  window types  *****
'
  $$WindowTypeTopMost        = 0x80000000
  $$WindowTypeNoSelect       = 0x40000000
  $$WindowTypeNoFrame        = 0x20000000
  $$WindowTypeResizeFrame    = 0x10000000
  $$WindowTypeTitleBar       = 0x08000000
  $$WindowTypeSystemMenu     = 0x04000000
  $$WindowTypeMinimizeBox    = 0x02000000
  $$WindowTypeMinimizeButton = 0x02000000
  $$WindowTypeMaximizeBox    = 0x01000000
  $$WindowTypeMaximizeButton = 0x01000000
  $$WindowTypeModal          = 0x99000000
  $$WindowTypeNormal         = 0x1F000000
  $$WindowTypeFixedSize      = 0x08000000
  $$WindowTypeNoIcon         = 0x00100000
  $$WindowTypeDefault        = 0x00000000
  $$WindowTypeCloseMinimize  = 0x00010000
  $$WindowTypeCloseHide      = 0x00020000
  $$WindowTypeCloseDestroy   = 0x00040000
  $$WindowTypeCloseTerminate = 0x00080000
'
' *****  window states  *****
'
  $$WindowHidden        = 0
  $$WindowDisplayed     = 1
  $$WindowMinimized     = 2
  $$WindowMaximized     = 3
'
' *****  grid states  *****
'
  $$GridDisabled        = 0
  $$GridEnabled         = 1
'
' *****  grid border styles  *****
'
  $$BorderNone          =  0
  $$BorderFlat          =  1 : $$BorderFlat1  =  1
  $$BorderFlat2         =  2
  $$BorderFlat4         =  3
  $$BorderHiLine1       =  4 : $$BorderLine1  =  4
  $$BorderHiLine2       =  5 : $$BorderLine2  =  5
  $$BorderHiLine4       =  6 : $$BorderLine4  =  6
  $$BorderLoLine1       =  7
  $$BorderLoLine2       =  8
  $$BorderLoLine4       =  9
  $$BorderRaise1        = 10 : $$BorderRaise  = 10
  $$BorderRaise2        = 11
  $$BorderRaise4        = 12
  $$BorderLower1        = 13 : $$BorderLower  = 13
  $$BorderLower2        = 14
  $$BorderLower4        = 15
  $$BorderFrame         = 16
  $$BorderDrain         = 17
  $$BorderRidge         = 18
  $$BorderValley        = 19
  $$BorderWide          = 20  ' wide window frame border w/o resize marks
  $$BorderWideResize    = 21  ' wide window frame border with resize marks
  $$BorderWindow        = 22  ' window frame border w/o resize marks
  $$BorderWindowResize  = 23  ' window frame border with resize marks
  $$BorderRise2         = 24
  $$BorderSink2         = 25
  $$BorderUpper         = 31  ' highest valid border number
'
' *****  drawing modes  *****
'
  $$DrawCOPY            = 0    ' obsolete set
  $$DrawSET             = 0
  $$DrawXOR             = 1
  $$DrawAND             = 2
  $$DrawOR              = 3
  $$DrawMax             = 3
'
  $$DrawModeCOPY        = 0    ' new set
  $$DrawModeSET         = 0
  $$DrawModeXOR         = 1
  $$DrawModeAND         = 2
  $$DrawModeOR          = 3
  $$DrawModeMax         = 3
'
  $$LineSolid           = 0    ' obsolete set
  $$LineDash            = 1
  $$LineDot             = 2
  $$LineDashDot         = 3
  $$LineDashDotDot      = 4
  $$LineMax             = 4
'
  $$LineStyleSolid      = 0    ' new set
  $$LineStyleDash       = 1
  $$LineStyleDot        = 2
  $$LineStyleDashDot    = 3
  $$LineStyleDashDotDot = 4
  $$LineStyleMax        = 4
'
  $$LineFill            = 0x0010
  $$LineFillDash        = 0x0011
  $$LineFillDot         = 0x0012
  $$LineFillDashDot     = 0x0013
  $$LineFillDashDotDot  = 0x0014
'
  $$TriangleUp          = 0x0010
  $$TriangleRight       = 0x0014
  $$TriangleDown        = 0x0018
  $$TriangleLeft        = 0x001C
'
  $$CurrentColor        = -1
  $$DefaultColor        = -1
'
  $$ClipTypeNone        = 0    ' none = no contents
  $$ClipTypeText        = 1    ' ASCII text
  $$ClipTypeImage       = 2    ' DIB format image
'
' ****************************************************
' *****  standard colors with names  (0 to 124)  *****
' ****************************************************
'
'   0xRRGGBBCC
'     RR          = 0x00 to 0xFF (0 to 255) red intensity
'       GG        = 0x00 to 0xFF (0 to 255) green intensity
'         BB      = 0x00 to 0xFF (0 to 255) blue intensity
'           CC    = 0x00 to 0x7C (0 to 124) standard color number
'
' ColorConstant  Decimal  Hexadecimal
'
'                         color#    RRGGBBCC
  $$Black               =   0   ' 0x00000000
  $$DarkBlue            =   1   ' 0x00003F01
  $$MediumBlue          =   2   ' 0x00007F02
  $$Blue                =   2   ' 0x00007F02
  $$BrightBlue          =   3   ' 0x0000BF03
  $$LightBlue           =   4   ' 0x0000FF04
  $$DarkGreen           =   5   ' 0x003F0005
  $$MediumGreen         =  10   ' 0x007F000A
  $$Green               =  10   ' 0x007F000A
  $$BrightGreen         =  15   ' 0x00BF000F
  $$LightGreen          =  20   ' 0x00FF0014
  $$DarkCyan            =   6   ' 0x003F3F06
  $$MediumCyan          =  12   ' 0x007F7F0C
  $$Cyan                =  12   ' 0x007F7F0C
  $$BrightCyan          =  18   ' 0x00BFBF12
  $$LightCyan           =  24   ' 0x00FFFF18
  $$DarkRed             =  25   ' 0x3F000019
  $$MediumRed           =  50   ' 0x7F000032
  $$Red                 =  50   ' 0x7F000032
  $$BrightRed           =  75   ' 0xBF00004B
  $$LightRed            = 100   ' 0xFF000064
  $$DarkMagenta         =  26   ' 0x3F003F1A
  $$MediumMagenta       =  52   ' 0x7F007F34
  $$Magenta             =  52   ' 0x7F007F34
  $$BrightMagenta       =  78   ' 0xBF00BF4E
  $$LightMagenta        = 104   ' 0xFF00FF68
  $$DarkBrown           =  30   ' 0x3F3F001E
  $$MediumBrown         =  60   ' 0x7F7F003C
  $$Brown               =  60   ' 0x7F7F003C
  $$Yellow              =  90   ' 0xBFBF005A
  $$BrightYellow        = 120   ' 0xFFFF0078
  $$LightYellow         = 120   ' 0xFFFF0078
  $$DarkGrey            =  31   ' 0x3F3F3F1F
  $$MediumGrey          =  62   ' 0x7F7F7F3E
  $$Grey                =  62   ' 0x7F7F7F3E
  $$BrightGrey          =  93   ' 0xBFBFBF5D
  $$LightGrey           =  93   ' 0xBFBFBF5D
  $$DarkSteel           =  32   ' 0x3F3F7F20
  $$MediumSteel         =  63   ' 0x7F7FBF3F
  $$Steel               =  63   ' 0x7F7FBF3F
  $$BrightSteel         =  94   ' 0xBFBFFF5E
  $$MediumOrange        =  81   ' 0xBF3F3F51
  $$Orange              =  81   ' 0xBF3F3F51
  $$BrightOrange        = 112   ' 0xFF7F7F70
  $$LightOrange         = 112   ' 0xFF7F7F70
  $$MediumAqua          =  42   ' 0x3FBF7F2A
  $$Aqua                =  42   ' 0x3FBF7F2A
  $$BrightAqua          =  73   ' 0x7FFFBF49
  $$DarkViolet          =  57   ' 0x7F3F7F39
  $$MediumViolet        =  88   ' 0xBF7FBF58
  $$Violet              =  88   ' 0xBF7FBF58
  $$BrightViolet        = 119   ' 0xFFBFFF77
  $$LightViolet         = 119   ' 0xFFBFFF77
  $$White               = 124   ' 0xFFFFFF7C
'
' keyboard key and mouse button bits in mouse messages
'
  $$MouseShiftKey       = 0x00010000  ' bit 16 = ShiftKey
  $$MouseControlKey     = 0x00020000  ' bit 17 = ControlKey
  $$MouseAltKey         = 0x00040000  ' bit 18 = AltKey
  $$MouseMod1Key        = 0x00040000  ' bit 18 = Mod1Key (alias AltKey)
  $$MouseMod2Key        = 0x00080000  ' bit 19 = Mod2Key
  $$MouseMod3Key        = 0x00100000  ' bit 20 = Mod3Key
  $$MouseMod4Key        = 0x00200000  ' bit 21 = Mod4Key
  $$MouseMod5Key        = 0x00400000  ' bit 22 = Mod5Key
  $$MouseButton1        = 0x01000000  ' bit 24 = MouseButton1  left button
  $$MouseButton2        = 0x02000000  ' bit 25 = MouseButton2  middle button
  $$MouseButton3        = 0x04000000  ' bit 26 = MouseButton3  right button
  $$MouseButton4        = 0x08000000  ' bit 27 = MouseButton4  extra button
  $$MouseButton5        = 0x10000000  ' bit 28 = MouseButton5  extra button
  $$MouseButtonMask     = 0x1F000000  '
'
  $$ShiftBit            = 0x00010000  ' bit 16
  $$ControlBit          = 0x00020000  ' bit 17
  $$CtrlBit             = 0x00020000  ' bit 17  alias
  $$AltBit              = 0x00040000  ' bit 18
	$$RightAltBit         = 0x00080000  ' bit 19
	$$RightShiftBit       = 0x00400000  ' bit 22
	$$RightControlBit     = 0x00800000  ' bit 23
  $$LeftButtonBit       = 0x01000000  ' bit 24
  $$MiddleButtonBit     = 0x02000000  ' bit 25
  $$RightButtonBit      = 0x04000000  ' bit 26
  $$HelpButtonBit       = 0x04000000  ' bit 26
'
' *****  key types  *****
'
  $$KeyTypeVirtualKey   = 0
  $$KeyTypeAscii        = 1
  $$KeyTypeUnicode      = 2
'
' *****  ASCII "control" characters  *****
'
  $$AsciiAlarm          = 0x07    ' \a
  $$AsciiBell           = 0x07    ' \a
  $$AsciiBackspace      = 0x08    ' \b
  $$AsciiTab            = 0x09    ' \t
  $$AsciiLinefeed       = 0x0A    ' \n
  $$AsciiNewline        = 0x0A    ' \n
  $$AsciiVerticalTab    = 0x0B    ' \v
  $$AsciiFormFeed       = 0x0C    ' \f
  $$AsciiEnter          = 0x0D    ' \r
  $$AsciiReturn         = 0x0D    ' \r
  $$AsciiEscape         = 0x1B    ' \e
  $$AsciiDelete         = 0x7F    ' \d
'
' *****  virtual key codes  *****
'
  $$VirtualKey          = BITFIELD (8,24)
  $$KeyLeftButton       = 0x01
  $$KeyRightButton      = 0x02
  $$KeyBreak            = 0x03
  $$KeyMiddleButton     = 0x04
  $$KeyBackspace        = 0x08
  $$KeyTab              = 0x09
  $$KeyClear            = 0x0C
  $$KeyEnter            = 0x0D
  $$KeyShift            = 0x10
  $$KeyControl          = 0x11
  $$KeyAlt              = 0x12
  $$KeyPause            = 0x13
  $$KeyCapLock          = 0x14
  $$KeyEscape           = 0x1B
  $$KeyControlA         = 0x01
  $$KeyControlB         = 0x02
  $$KeyControlC         = 0x03
  $$KeyControlD         = 0x04
  $$KeyControlE         = 0x05
  $$KeyControlF         = 0x06
  $$KeyControlG         = 0x07
  $$KeyControlH         = 0x08
  $$KeyControlI         = 0x09
  $$KeyControlJ         = 0x0A
  $$KeyControlK         = 0x0B
  $$KeyControlL         = 0x0C
  $$KeyControlM         = 0x0D
  $$KeyControlN         = 0x0E
  $$KeyControlO         = 0x0F
  $$KeyControlP         = 0x10
  $$KeyControlQ         = 0x11
  $$KeyControlR         = 0x12
  $$KeyControlS         = 0x13
  $$KeyControlT         = 0x14
  $$KeyControlU         = 0x15
  $$KeyControlV         = 0x16
  $$KeyControlW         = 0x17
  $$KeyControlX         = 0x18
  $$KeyControlY         = 0x19
  $$KeyControlZ         = 0x1A
  $$KeySpace            = 0x20
  $$KeyPageUp           = 0x21
  $$KeyPageDown         = 0x22
  $$KeyEnd              = 0x23
  $$KeyHome             = 0x24
  $$KeyLeftArrow        = 0x25
  $$KeyUpArrow          = 0x26
  $$KeyRightArrow       = 0x27
  $$KeyDownArrow        = 0x28
  $$KeySelect           = 0x29
  $$KeyExecute          = 0x2B
  $$KeyPrintScreen      = 0x2C
  $$KeyInsert           = 0x2D
  $$KeyDelete           = 0x2E
  $$KeyHelp             = 0x2F
  $$Key0                = 0x30
  $$Key1                = 0x31
  $$Key2                = 0x32
  $$Key3                = 0x33
  $$Key4                = 0x34
  $$Key5                = 0x35
  $$Key6                = 0x36
  $$Key7                = 0x37
  $$Key8                = 0x38
  $$Key9                = 0x39
  $$KeyA                = 0x41
  $$KeyB                = 0x42
  $$KeyC                = 0x43
  $$KeyD                = 0x44
  $$KeyE                = 0x45
  $$KeyF                = 0x46
  $$KeyG                = 0x47
  $$KeyH                = 0x48
  $$KeyI                = 0x49
  $$KeyJ                = 0x4A
  $$KeyK                = 0x4B
  $$KeyL                = 0x4C
  $$KeyM                = 0x4D
  $$KeyN                = 0x4E
  $$KeyO                = 0x4F
  $$KeyP                = 0x50
  $$KeyQ                = 0x51
  $$KeyR                = 0x52
  $$KeyS                = 0x53
  $$KeyT                = 0x54
  $$KeyU                = 0x55
  $$KeyV                = 0x56
  $$KeyW                = 0x57
  $$KeyX                = 0x58
  $$KeyY                = 0x59
  $$KeyZ                = 0x5A
  $$KeyLeftWindow       = 0x5B
  $$KeyRightWindow      = 0x5C
  $$KeyApps             = 0x5D
  $$Keypad0             = 0x60
  $$Keypad1             = 0x61
  $$Keypad2             = 0x62
  $$Keypad3             = 0x63
  $$Keypad4             = 0x64
  $$Keypad5             = 0x65
  $$Keypad6             = 0x66
  $$Keypad7             = 0x67
  $$Keypad8             = 0x68
  $$Keypad9             = 0x69
  $$KeypadMultiply      = 0x6A
  $$KeypadAdd           = 0x6B
  $$KeypadSubtract      = 0x6D
  $$KeypadDecimalPoint  = 0x6E
  $$KeypadDivide        = 0x6F
  $$KeyF1               = 0x70
  $$KeyF2               = 0x71
  $$KeyF3               = 0x72
  $$KeyF4               = 0x73
  $$KeyF5               = 0x74
  $$KeyF6               = 0x75
  $$KeyF7               = 0x76
  $$KeyF8               = 0x77
  $$KeyF9               = 0x78
  $$KeyF10              = 0x79
  $$KeyF11              = 0x7A
  $$KeyF12              = 0x7B
  $$KeyF13              = 0x7C
  $$KeyF14              = 0x7D
  $$KeyF15              = 0x7E
  $$KeyF16              = 0x7F
  $$KeyF17              = 0x80
  $$KeyF18              = 0x81
  $$KeyF19              = 0x82
  $$KeyF20              = 0x83
  $$KeyF21              = 0x84
  $$KeyF22              = 0x85
  $$KeyF23              = 0x86
  $$KeyF24              = 0x87
  $$KeyNumLock          = 0x90
  $$KeyScroll           = 0x91
  $$KeyLeftShift        = 0xA0
  $$KeyRightShift       = 0xA1
  $$KeyLeftControl      = 0xA2
  $$KeyRightControl     = 0xA3
  $$KeyLeftAlt          = 0xA4
  $$KeyLeftMenu         = 0xA4
  $$KeyRightAlt         = 0xA5
  $$KeyRightMenu        = 0xA5
END EXPORT
'
' *****  general  *****
'
  $$None                = 0
  $$Create              = 1
  $$Destroy             = 2
  $$DestroyAll          = 3
  $$Open                = 4
  $$Close               = 5
  $$CloseAll            = 6
  $$CloseExcess         = 7		' leave defaults and standards open
'
	$$StateContents       = BITFIELD (2, 20)		' 0,1,2 = VirtualKey, ascii, unicode
'
' overlap constants for XgrLocalToBufferCoords()
'
	$$RegionExceedsBufferLeft    = 0x00000001
	$$RegionExceedsBufferTop     = 0x00000002
	$$RegionExceedsBufferRight   = 0x00000004
	$$RegionExceedsBufferBottom  = 0x00000008
'
	$$RegionExceedsGridLeft      = 0x00000010
	$$RegionExceedsGridTop       = 0x00000020
	$$RegionExceedsGridRight     = 0x00000040
	$$RegionExceedsGridBottom    = 0x00000080
'
	$$BufferExceedsGridLeft      = 0x00000100
	$$BufferExceedsGridTop       = 0x00000200
	$$BufferExceedsGridRight     = 0x00000400
	$$BufferExceedsGridBottom    = 0x00000800
'
	$$GridExceedsBufferLeft      = 0x00001000
	$$GridExceedsBufferTop       = 0x00002000
	$$GridExceedsBufferRight     = 0x00004000
	$$GridExceedsBufferBottom    = 0x00008000
'
	$$RegionOutsideBufferLeft    = 0x00010000
	$$RegionOutsideBufferTop     = 0x00020000
	$$RegionOutsideBufferRight   = 0x00040000
	$$RegionOutsideBufferBottom  = 0x00080000
'
	$$RegionOutsideGridLeft      = 0x00100000
	$$RegionOutsideGridTop       = 0x00200000
	$$RegionOutsideGridRight     = 0x00400000
	$$RegionOutsdieGridBottom    = 0x00800000
'
	$$BufferOutsideGridLeft      = 0x01000000
	$$BufferOutsideGridTop       = 0x02000000
	$$BufferOutsideGridRight     = 0x04000000
	$$BufferOutsideGridBottom    = 0x08000000
'
	$$GridOutsideBufferLeft      = 0x10000000
	$$GridOutsideBufferTop       = 0x20000000
	$$GridOutsideBufferRight     = 0x40000000
	$$GridOutsideBufferBottom    = 0x80000000
'
'
' ####################
' #####  Xgr ()  #####
' ####################
'
FUNCTION  Xgr ()
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  charMap[]
	SHARED	debug
	SHARED	event$[]
	SHARED  FUNCADDR	event[] (ANY)
	SHARED  FUNCADDR	ehelp[] (ANY)
	SHARED  UBYTE	charsetKeystateModify[]
	SHARED  UBYTE	virtualKey00[]
	SHARED  UBYTE	virtualKeyFF[]
	SHARED  UBYTE	asciiKey00[]
	SHARED  UBYTE	asciiKeyFF[]
	SHARED	UBYTE	altChar[]
	SHARED	UBYTE	altCharFF[]
	SHARED  borderWidth[]
	SHARED  border$[]
	SHARED  connect[]
	SHARED  bitmask[]
	SHARED  color$[]
	SHARED  r[]
	SHARED  g[]
	SHARED  b[]
	SHARED  rgb[]
	STATIC	entry
'
	IF entry THEN RETURN ($$FALSE)
	entry = $$TRUE
'	debug = $$TRUE
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	a$ = "Max Reason"
	a$ = "copyright 1988-2000"
	a$ = "Linux XBasic GraphicsDesigner"
	a$ = "maxreason@maxreason.com"
	a$ = ""
'
	XxxGetImplementation (@#implementation$)
'
' force xlib functions to be linked in so user programs can call 'em
'
	a = &XGetErrorText()
	a = &XListProperties()
	a = &XSetErrorHandler()
	a = &XSetIOErrorHandler()
'
	XSetErrorHandler (&EventError())			' we will try to handle errors
'
	##WHOMASK = 0
	DIM r[4]
	DIM g[4]
	DIM b[4]
	DIM rgb[255]
	DIM border$[31]
	DIM borderWidth[31]
	DIM bitmask[31]
	DIM connect[63]
	DIM altChar[255]
	DIM altCharFF[255]
	DIM asciiKey00[255]
	DIM asciiKeyFF[255]
	DIM virtualKey00[255]
	DIM virtualKeyFF[255]
	DIM charsetKeystateModify[255]
	DIM event[$$LastEvent]
	DIM ehelp[$$LastEvent]
	DIM event$[$$LastEvent]
'
	bitmask [ 0] = 0x00000001
	bitmask [ 1] = 0x00000002
	bitmask [ 2] = 0x00000004
	bitmask [ 3] = 0x00000008
	bitmask [ 4] = 0x00000010
	bitmask [ 5] = 0x00000020
	bitmask [ 6] = 0x00000040
	bitmask [ 7] = 0x00000080
	bitmask [ 8] = 0x00000100
	bitmask [ 9] = 0x00000200
	bitmask [10] = 0x00000400
	bitmask [11] = 0x00000800
	bitmask [12] = 0x00001000
	bitmask [13] = 0x00002000
	bitmask [14] = 0x00004000
	bitmask [15] = 0x00008000
	bitmask [16] = 0x00010000
	bitmask [17] = 0x00020000
	bitmask [18] = 0x00040000
	bitmask [19] = 0x00080000
	bitmask [20] = 0x00100000
	bitmask [21] = 0x00200000
	bitmask [22] = 0x00400000
	bitmask [23] = 0x00800000
	bitmask [24] = 0x01000000
	bitmask [25] = 0x02000000
	bitmask [26] = 0x04000000
	bitmask [27] = 0x08000000
	bitmask [28] = 0x10000000
	bitmask [29] = 0x20000000
	bitmask [30] = 0x40000000
	bitmask [31] = 0x80000000
'
' initialize pre-defined grid types
'
	#GridTypeCoordinate = 0
	#GridTypeBuffer = 1
	#GridTypeImage = 1
'
' assign starting default colors
'
	#defaultBackground = $$LightGrey
	#defaultDrawing = $$Black
	#defaultLowlight = $$Black
	#defaultHighlight = $$White
	#defaultAccent = $$Yellow
	#defaultDull = $$Black
	#defaultLowtext = $$Black
	#defaultHightext = $$White
'
' initialize r[], g[], b[], rgb[] with standard color values
'
	r[0] = 0x0000 : g[0] = 0x0000 : b[0] = 0x0000
	r[1] = 0x7FFF : g[1] = 0x7FFF : b[1] = 0x7FFF
	r[2] = 0xAFFF : g[2] = 0xAFFF : b[2] = 0xAFFF
	r[3] = 0xCFFF : g[3] = 0xCFFF : b[3] = 0xCFFF
	r[4] = 0xFFFF : g[4] = 0xFFFF : b[4] = 0xFFFF
'
	color = 0
	FOR r = 0 TO 4
		FOR g = 0 TO 4
			FOR b = 0 TO 4
				rr = (r[r] AND 0xFF00) << 16
				gg = (g[g] AND 0xFF00) << 8
				bb = (b[b] AND 0xFF00)
				rgb[color] = rr + gg + bb + color
				INC color
			NEXT b
		NEXT g
	NEXT r
'
' define border names and widths
'
	border$[$$BorderNone]					= "$$BorderNone"
	border$[$$BorderFlat1]				= "$$BorderFlat1"
	border$[$$BorderFlat2]				= "$$BorderFlat2"
	border$[$$BorderFlat4]				= "$$BorderFlat4"
	border$[$$BorderHiLine1]			= "$$BorderHiLine1"
	border$[$$BorderHiLine2]			= "$$BorderHiLine2"
	border$[$$BorderHiLine4]			= "$$BorderHiLine4"
	border$[$$BorderLoLine1]			= "$$BorderLoLine1"
	border$[$$BorderLoLine2]			= "$$BorderLoLine2"
	border$[$$BorderLoLine4]			= "$$BorderLoLine4"
	border$[$$BorderRaise1]				= "$$BorderRaise1"
	border$[$$BorderLower1]				= "$$BorderLower1"
	border$[$$BorderRaise2]				= "$$BorderRaise2"
	border$[$$BorderLower2]				= "$$BorderLower2"
	border$[$$BorderRaise4]				= "$$BorderRaise4"
	border$[$$BorderLower4]				= "$$BorderLower4"
	border$[$$BorderFrame]				= "$$BorderFrame"
	border$[$$BorderDrain]				= "$$BorderDrain"
	border$[$$BorderRidge]				= "$$BorderRidge"
	border$[$$BorderValley]				= "$$BorderValley"
	border$[$$BorderWide]   			= "$$BorderWide"
	border$[$$BorderWideResize]		= "$$BorderWideResize"
	border$[$$BorderWindow]				= "$$BorderWindow"
	border$[$$BorderWindowResize]	= "$$BorderWindowResize"
	border$[$$BorderRise2]   			= "$$BorderRise2"
	border$[$$BorderSink2]   			= "$$BorderSink2"
'
	borderWidth[$$BorderNone]						= 0
	borderWidth[$$BorderFlat1]					= 1
	borderWidth[$$BorderFlat2]					= 2
	borderWidth[$$BorderFlat4]					= 4
	borderWidth[$$BorderHiLine1]				= 1
	borderWidth[$$BorderHiLine2]				= 2
	borderWidth[$$BorderHiLine4]				= 4
	borderWidth[$$BorderLoLine1]				= 1
	borderWidth[$$BorderLoLine2]				= 2
	borderWidth[$$BorderLoLine4]				= 4
	borderWidth[$$BorderRaise1]					= 1
	borderWidth[$$BorderLower1]					= 1
	borderWidth[$$BorderRaise2]					= 2
	borderWidth[$$BorderLower2]					= 2
	borderWidth[$$BorderRaise4]					= 4
	borderWidth[$$BorderLower4]					= 4
	borderWidth[$$BorderFrame]					= 4
	borderWidth[$$BorderDrain]					= 4
	borderWidth[$$BorderRidge]					= 2
	borderWidth[$$BorderValley]					= 2
	borderWidth[$$BorderWide]						= 6
	borderWidth[$$BorderWideResize]			= 6
	borderWidth[$$BorderWindow]					= 8
	borderWidth[$$BorderWindowResize]		= 8
	borderWidth[$$BorderRise2]					= 2
	borderWidth[$$BorderSink2]					= 2
'
'
' ***********************************************
' *****  Initialize Color Constant Strings  *****
' ***********************************************
'
	DIM color$[255]
	color$[$$Black]							= "$$Black"						'   0
	color$[$$DarkBlue]					= "$$DarkBlue"				'   1
	color$[$$Blue]							= "$$Blue"						'   2
	color$[$$BrightBlue]				= "$$BrightBlue"			'   3
	color$[$$LightBlue]					= "$$LightBlue"				'   4
	color$[$$DarkGreen]					= "$$DarkGreen"				'   5
	color$[$$DarkCyan]					= "$$DarkCyan"				'   6
	color$[$$Green]							= "$$Green"						'  10
	color$[$$Cyan]							= "$$Cyan"						'  12
	color$[$$BrightGreen]				= "$$BrightGreen"			'  15
	color$[$$BrightCyan]				= "$$BrightCyan"			'  18
	color$[$$LightGreen]				= "$$LightGreen"			'  20
	color$[$$LightCyan]					= "$$LightCyan"				'  24
	color$[$$DarkRed]						= "$$DarkRed"					'  25
	color$[$$DarkMagenta]				= "$$DarkMagenta"			'  26
	color$[$$DarkBrown]					= "$$DarkBrown"				'  30
	color$[$$DarkGrey]					= "$$DarkGrey"				'  31
	color$[$$DarkSteel]					= "$$DarkSteel"				'  32
	color$[$$Aqua]							= "$$Aqua"						'  42
	color$[$$Red]								= "$$Red"							'  50
	color$[$$Magenta]						= "$$Magenta"					'  52
	color$[$$DarkViolet]				= "$$DarkViolet"			'  57
	color$[$$Brown]							= "$$Brown"						'  60
	color$[$$Grey]							= "$$Grey"						'  62
	color$[$$Steel]							= "$$Steel"						'  63
	color$[$$BrightAqua]				= "$$BrightAqua"			'  73
	color$[$$BrightRed]					= "$$BrightRed"				'  75
	color$[$$BrightMagenta]			= "$$BrightMagenta"		'  78
	color$[$$Orange]						= "$$Orange"					'  81
	color$[$$Violet]						= "$$Violet"					'  88
	color$[$$Yellow]						= "$$Yellow"					'  90
	color$[$$BrightGrey]				= "$$BrightGrey"			'  93
	color$[$$BrightSteel]				= "$$BrightSteel"			'  94
	color$[$$LightRed]					= "$$LightRed"				' 100
	color$[$$LightMagenta]			= "$$LightMagenta"		' 104
	color$[$$BrightOrange]			= "$$BrightOrange"		' 112
	color$[$$BrightViolet]			= "$$BrightViolet"		' 119
	color$[$$LightYellow]				= "$$LightYellow"			' 120
	color$[$$White]							= "$$White"						' 124
'
' initialize event strings
'
	event$ [ $$KeyPress          ]  = "$$KeyPress"
	event$ [ $$KeyRelease        ]  = "$$KeyRelease"
	event$ [ $$ButtonPress       ]  = "$$ButtonPress"
	event$ [ $$ButtonRelease     ]  = "$$ButtonRelease"
	event$ [ $$MotionNotify      ]  = "$$MotionNotify"
	event$ [ $$EnterNotify       ]  = "$$EnterNotify"
	event$ [ $$LeaveNotify       ]  = "$$LeaveNotify"
	event$ [ $$FocusIn           ]  = "$$FocusIn"
	event$ [ $$FocusOut          ]  = "$$FocusOut"
	event$ [ $$KeymapNotify      ]  = "$$KeymapNotify"
	event$ [ $$Expose            ]  = "$$Expose"
	event$ [ $$GrapicsExpose     ]  = "$$GrapicsExpose"
	event$ [ $$NoExpose          ]  = "$$NoExpose"
	event$ [ $$VisibilityNotify  ]  = "$$VisibilityNotify"
	event$ [ $$CreateNotify      ]  = "$$CreateNotify"
	event$ [ $$DestroyNotify     ]  = "$$DestroyNotify"
	event$ [ $$UnmapNotify       ]  = "$$UnmapNotify"
	event$ [ $$MapNotify         ]  = "$$MapNotify"
	event$ [ $$MapRequest        ]  = "$$MapRequest"
	event$ [ $$ReparentNotify    ]  = "$$ReparentNotify"
	event$ [ $$ConfigureNotify   ]  = "$$ConfigureNotify"
	event$ [ $$ConfigureRequest  ]  = "$$ConfigureRequest"
	event$ [ $$GravityNotify     ]  = "$$GravityNotify"
	event$ [ $$ResizeRequest     ]  = "$$ResizeRequest"
	event$ [ $$CirculateNotify   ]  = "$$CirculateNotify"
	event$ [ $$CirculateRequest  ]  = "$$CirculateRequest"
	event$ [ $$PropertyNotify    ]  = "$$PropertyNotify"
	event$ [ $$SelectionClear    ]  = "$$SelectionClear"
	event$ [ $$SelectionRequest  ]  = "$$SelectionRequest"
	event$ [ $$SelectionNotify   ]  = "$$SelectionNotify"
	event$ [ $$ColormapNotify    ]  = "$$ColormapNotify"
	event$ [ $$ClientMessage     ]  = "$$ClientMessage "
	event$ [ $$MappingNotify     ]  = "$$MappingNotify"
	event$ [ $$LastEvent         ]  = "$$LastEvent"
'
	event [ $$KeyPress          ] = &EventKeyPress()
	event [ $$KeyRelease        ] = &EventKeyRelease()
	event [ $$ButtonPress       ] = &EventButtonPress()
	event [ $$ButtonRelease     ] = &EventButtonRelease()
	event [ $$MotionNotify      ] = &EventMotionNotify()
	event [ $$EnterNotify       ] = &EventEnterNotify()
	event [ $$LeaveNotify       ] = &EventLeaveNotify()
	event [ $$FocusIn           ] = &EventFocusIn()
	event [ $$FocusOut          ] = &EventFocusOut()
	event [ $$KeymapNotify      ] = &EventKeymapNotify()
	event [ $$Expose            ] = &EventExpose()
	event [ $$GrapicsExpose     ] = &EventGraphicsExpose()
	event [ $$NoExpose          ] = &EventNoExpose()
	event [ $$VisibilityNotify  ] = &EventVisibilityNotify()
	event [ $$CreateNotify      ] = &EventCreateNotify()
	event [ $$DestroyNotify     ] = &EventDestroyNotify()
	event [ $$UnmapNotify       ] = &EventUnmapNotify()
	event [ $$MapNotify         ] = &EventMapNotify()
	event [ $$MapRequest        ] = &EventMapRequest()
	event [ $$ReparentNotify    ] = &EventReparentNotify()
	event [ $$ConfigureNotify   ] = &EventConfigureNotify()
	event [ $$ConfigureRequest  ] = &EventConfigureRequest()
	event [ $$GravityNotify     ] = &EventGravityNotify()
	event [ $$ResizeRequest     ] = &EventResizeRequest()
	event [ $$CirculateNotify   ] = &EventCirculateNotify()
	event [ $$CirculateRequest  ] = &EventCirculateRequest()
	event [ $$PropertyNotify    ] = &EventPropertyNotify()
	event [ $$SelectionClear    ] = &EventSelectionClear()
	event [ $$SelectionRequest  ] = &EventSelectionRequest()
	event [ $$SelectionNotify   ] = &EventSelectionNotify()
	event [ $$ColormapNotify    ] = &EventColormapNotify()
	event [ $$ClientMessage     ] = &EventClientMessage()
	event [ $$MappingNotify     ] = &EventMappingNotify()
	event [ $$LastEvent         ] = 0
'
	ehelp [ $$KeyPress          ] = &PrintKeyPress()
	ehelp [ $$KeyRelease        ] = &PrintKeyRelease()
	ehelp [ $$ButtonPress       ] = &PrintButtonPress()
	ehelp [ $$ButtonRelease     ] = &PrintButtonRelease()
	ehelp [ $$MotionNotify      ] = &PrintMotionNotify()
	ehelp [ $$EnterNotify       ] = &PrintEnterNotify()
	ehelp [ $$LeaveNotify       ] = &PrintLeaveNotify()
	ehelp [ $$FocusIn           ] = &PrintFocusIn()
	ehelp [ $$FocusOut          ] = &PrintFocusOut()
	ehelp [ $$KeymapNotify      ] = &PrintKeymapNotify()
	ehelp [ $$Expose            ] = &PrintExpose()
	ehelp [ $$GrapicsExpose     ] = &PrintGraphicsExpose()
	ehelp [ $$NoExpose          ] = &PrintNoExpose()
	ehelp [ $$VisibilityNotify  ] = &PrintVisibilityNotify()
	ehelp [ $$CreateNotify      ] = &PrintCreateNotify()
	ehelp [ $$DestroyNotify     ] = &PrintDestroyNotify()
	ehelp [ $$UnmapNotify       ] = &PrintUnmapNotify()
	ehelp [ $$MapNotify         ] = &PrintMapNotify()
	ehelp [ $$MapRequest        ] = &PrintMapRequest()
	ehelp [ $$ReparentNotify    ] = &PrintReparentNotify()
	ehelp [ $$ConfigureNotify   ] = &PrintConfigureNotify()
	ehelp [ $$ConfigureRequest  ] = &PrintConfigureRequest()
	ehelp [ $$GravityNotify     ] = &PrintGravityNotify()
	ehelp [ $$ResizeRequest     ] = &PrintResizeRequest()
	ehelp [ $$CirculateNotify   ] = &PrintCirculateNotify()
	ehelp [ $$CirculateRequest  ] = &PrintCirculateRequest()
	ehelp [ $$PropertyNotify    ] = &PrintPropertyNotify()
	ehelp [ $$SelectionClear    ] = &PrintSelectionClear()
	ehelp [ $$SelectionRequest  ] = &PrintSelectionRequest()
	ehelp [ $$SelectionNotify   ] = &PrintSelectionNotify()
	ehelp [ $$ColormapNotify    ] = &PrintColormapNotify()
	ehelp [ $$ClientMessage     ] = &PrintClientMessage()
	ehelp [ $$MappingNotify     ] = &PrintMappingNotify()
	ehelp [ $$LastEvent         ] = 0
'
'
' *****  translate keysym to ascii character  *****
'
' When the AltKey is down, the char is always the basic char
'   for keys 'a'...'z' and '0'...'9'.
' for example, the char for Alt+Shift+3 = '3', not '#'
' for example, the char for Alt+A = 'A', not 'a'
'
	FOR i = 0x00 TO 0xFF
		altChar[i] = i
	NEXT i
'
	FOR i = 'a' TO 'z'
		altChar[i] = i - 0x20				' lower case to upper case
	NEXT i
'
	altChar [ ')' ] = '0'
	altChar [ '!' ] = '1'
	altChar [ '@' ] = '2'
	altChar [ '#' ] = '3'
	altChar [ '$' ] = '4'
	altChar [ '%' ] = '5'
	altChar [ '^' ] = '6'
	altChar [ '&' ] = '7'
	altChar [ '*' ] = '8'
	altChar [ '(' ] = '9'
'
'
' group 00 : keysym = 0x00kk where kk = entry in following array
'
	FOR i = 0x20 TO 0xFF
		asciiKey00 [ i ] = i
	NEXT i
'
' group FF : keysym = 0xFFkk where kk = entry in following array
'
' $$KeyDelete is not included here because it does not enter
' a character or delete an existing character.  (escape doesn't either)
'
	asciiKeyFF [ $$XK_Backspace				AND 0x00FF ] = $$AsciiBackspace
	asciiKeyFF [ $$XK_Tab							AND 0x00FF ] = $$AsciiTab
	asciiKeyFF [ $$XK_Return					AND 0x00FF ] = $$AsciiEnter
	asciiKeyFF [ $$XK_Escape					AND 0x00FF ] = $$AsciiEscape
' added 010109 SVG, improved keypad support
	asciiKeyFF [ $$XK_KeypadSpace			AND 0x00FF ] = $$KeySpace
	asciiKeyFF [ $$XK_KeypadTab				AND 0x00FF ] = $$AsciiTab
	asciiKeyFF [ $$XK_KeypadEnter			AND 0x00FF ] = $$AsciiEnter
	asciiKeyFF [ $$XK_KeypadEqual			AND 0x00FF ] = '='
	asciiKeyFF [ $$XK_KeypadMultiply  AND 0x00FF ] = '*'
	asciiKeyFF [ $$XK_KeypadAdd				AND 0x00FF ] = '+'
	asciiKeyFF [ $$XK_KeypadSeparator	AND 0x00FF ] = ','
	asciiKeyFF [ $$XK_KeypadSubtract	AND 0x00FF ] = '-'
	asciiKeyFF [ $$XK_KeypadDecimal		AND 0x00FF ] = '.'
	asciiKeyFF [ $$XK_KeypadDivide		AND 0x00FF ] = '/'
	asciiKeyFF [ $$XK_Keypad_0					AND 0x00FF ] = '0'
	asciiKeyFF [ $$XK_Keypad_1					AND 0x00FF ] = '1'
	asciiKeyFF [ $$XK_Keypad_2					AND 0x00FF ] = '2'
	asciiKeyFF [ $$XK_Keypad_3					AND 0x00FF ] = '3'
	asciiKeyFF [ $$XK_Keypad_4					AND 0x00FF ] = '4'
	asciiKeyFF [ $$XK_Keypad_5					AND 0x00FF ] = '5'
	asciiKeyFF [ $$XK_Keypad_6					AND 0x00FF ] = '6'
	asciiKeyFF [ $$XK_Keypad_7					AND 0x00FF ] = '7'
	asciiKeyFF [ $$XK_Keypad_8					AND 0x00FF ] = '8'
	asciiKeyFF [ $$XK_Keypad_9					AND 0x00FF ] = '9'
'
' *****  translate keysym to virtual key  *****
'
' group 00 : keysym = 0x00kk where kk = entry in following array
'
	virtualKey00 [ $$XK_space		] = $$KeySpace	' space character
	virtualKey00 [ $$XK_0				] = $$Key0
	virtualKey00 [ $$XK_1				] = $$Key1
	virtualKey00 [ $$XK_2				] = $$Key2
	virtualKey00 [ $$XK_3				] = $$Key3
	virtualKey00 [ $$XK_4				] = $$Key4
	virtualKey00 [ $$XK_5				] = $$Key5
	virtualKey00 [ $$XK_6				] = $$Key6
	virtualKey00 [ $$XK_7				] = $$Key7
	virtualKey00 [ $$XK_8				] = $$Key8
	virtualKey00 [ $$XK_9				] = $$Key9
'
	virtualKey00 [ $$XK_A				] = $$KeyA
	virtualKey00 [ $$XK_B				] = $$KeyB
	virtualKey00 [ $$XK_C				] = $$KeyC
	virtualKey00 [ $$XK_D				] = $$KeyD
	virtualKey00 [ $$XK_E				] = $$KeyE
	virtualKey00 [ $$XK_F				] = $$KeyF
	virtualKey00 [ $$XK_G				] = $$KeyG
	virtualKey00 [ $$XK_H				] = $$KeyH
	virtualKey00 [ $$XK_I				] = $$KeyI
	virtualKey00 [ $$XK_J				] = $$KeyJ
	virtualKey00 [ $$XK_K				] = $$KeyK
	virtualKey00 [ $$XK_L				] = $$KeyL
	virtualKey00 [ $$XK_M				] = $$KeyM
	virtualKey00 [ $$XK_N				] = $$KeyN
	virtualKey00 [ $$XK_O				] = $$KeyO
	virtualKey00 [ $$XK_P				] = $$KeyP
	virtualKey00 [ $$XK_Q				] = $$KeyQ
	virtualKey00 [ $$XK_R				] = $$KeyR
	virtualKey00 [ $$XK_S				] = $$KeyS
	virtualKey00 [ $$XK_T				] = $$KeyT
	virtualKey00 [ $$XK_U				] = $$KeyU
	virtualKey00 [ $$XK_V				] = $$KeyV
	virtualKey00 [ $$XK_W				] = $$KeyW
	virtualKey00 [ $$XK_X				] = $$KeyX
	virtualKey00 [ $$XK_Y				] = $$KeyY
	virtualKey00 [ $$XK_Z				] = $$KeyZ
'
	virtualKey00 [ $$XK_a				] = $$KeyA
	virtualKey00 [ $$XK_b				] = $$KeyB
	virtualKey00 [ $$XK_c				] = $$KeyC
	virtualKey00 [ $$XK_d				] = $$KeyD
	virtualKey00 [ $$XK_e				] = $$KeyE
	virtualKey00 [ $$XK_f				] = $$KeyF
	virtualKey00 [ $$XK_g				] = $$KeyG
	virtualKey00 [ $$XK_h				] = $$KeyH
	virtualKey00 [ $$XK_i				] = $$KeyI
	virtualKey00 [ $$XK_j				] = $$KeyJ
	virtualKey00 [ $$XK_k				] = $$KeyK
	virtualKey00 [ $$XK_l				] = $$KeyL
	virtualKey00 [ $$XK_m				] = $$KeyM
	virtualKey00 [ $$XK_n				] = $$KeyN
	virtualKey00 [ $$XK_o				] = $$KeyO
	virtualKey00 [ $$XK_p				] = $$KeyP
	virtualKey00 [ $$XK_q				] = $$KeyQ
	virtualKey00 [ $$XK_r				] = $$KeyR
	virtualKey00 [ $$XK_s				] = $$KeyS
	virtualKey00 [ $$XK_t				] = $$KeyT
	virtualKey00 [ $$XK_u				] = $$KeyU
	virtualKey00 [ $$XK_v				] = $$KeyV
	virtualKey00 [ $$XK_w				] = $$KeyW
	virtualKey00 [ $$XK_x				] = $$KeyX
	virtualKey00 [ $$XK_y				] = $$KeyY
	virtualKey00 [ $$XK_z				] = $$KeyZ
'
' group FF : keysym = 0xFFkk where kk = entry in following array
'
	virtualKeyFF [ $$XK_Backspace				AND 0x00FF ] = $$KeyBackspace
	virtualKeyFF [ $$XK_Tab							AND 0x00FF ] = $$KeyTab
	virtualKeyFF [ $$XK_Clear						AND 0x00FF ] = $$KeyClear
	virtualKeyFF [ $$XK_Return					AND 0x00FF ] = $$KeyEnter
	virtualKeyFF [ $$XK_Escape					AND 0x00FF ] = $$KeyEscape
	virtualKeyFF [ $$XK_PageUp					AND 0x00FF ] = $$KeyPageUp
	virtualKeyFF [ $$XK_PageDown				AND 0x00FF ] = $$KeyPageDown
	virtualKeyFF [ $$XK_End							AND 0x00FF ] = $$KeyEnd
	virtualKeyFF [ $$XK_Home						AND 0x00FF ] = $$KeyHome
	virtualKeyFF [ $$XK_Left						AND 0x00FF ] = $$KeyLeftArrow
	virtualKeyFF [ $$XK_Up							AND 0x00FF ] = $$KeyUpArrow
	virtualKeyFF [ $$XK_Right						AND 0x00FF ] = $$KeyRightArrow
	virtualKeyFF [ $$XK_Down						AND 0x00FF ] = $$KeyDownArrow
	virtualKeyFF [ $$XK_Select					AND 0x00FF ] = $$KeySelect
	virtualKeyFF [ $$XK_Execute					AND 0x00FF ] = $$KeyExecute
	virtualKeyFF [ $$XK_Print						AND 0x00FF ] = $$KeyPrintScreen
	virtualKeyFF [ $$XK_Insert					AND 0x00FF ] = $$KeyInsert
	virtualKeyFF [ $$XK_Delete					AND 0x00FF ] = $$KeyDelete
	virtualKeyFF [ $$XK_Help						AND 0x00FF ] = $$KeyHelp
'
	virtualKeyFF [ $$XK_KeypadHome			AND 0x00FF ] = $$KeyHome
	virtualKeyFF [ $$XK_KeypadLeft			AND 0x00FF ] = $$KeyLeftArrow
	virtualKeyFF [ $$XK_KeypadUp				AND 0x00FF ] = $$KeyUpArrow
	virtualKeyFF [ $$XK_KeypadRight			AND 0x00FF ] = $$KeyRightArrow
	virtualKeyFF [ $$XK_KeypadDown			AND 0x00FF ] = $$KeyDownArrow
	virtualKeyFF [ $$XK_KeypadPageUp		AND 0x00FF ] = $$KeyPageUp
	virtualKeyFF [ $$XK_KeypadPageDown	AND 0x00FF ] = $$KeyPageDown
	virtualKeyFF [ $$XK_KeypadEnd				AND 0x00FF ] = $$KeyEnd
	virtualKeyFF [ $$XK_KeypadBegin			AND 0x00FF ] = $$Keypad5
	virtualKeyFF [ $$XK_KeypadInsert		AND 0x00FF ] = $$KeyInsert
	virtualKeyFF [ $$XK_KeypadDelete		AND 0x00FF ] = $$KeyDelete
'
	virtualKeyFF [ $$XK_Keypad_0				AND 0x00FF ] = $$Keypad0
	virtualKeyFF [ $$XK_Keypad_1				AND 0x00FF ] = $$Keypad1
	virtualKeyFF [ $$XK_Keypad_2				AND 0x00FF ] = $$Keypad2
	virtualKeyFF [ $$XK_Keypad_3				AND 0x00FF ] = $$Keypad3
	virtualKeyFF [ $$XK_Keypad_4				AND 0x00FF ] = $$Keypad4
	virtualKeyFF [ $$XK_Keypad_5				AND 0x00FF ] = $$Keypad5
	virtualKeyFF [ $$XK_Keypad_6				AND 0x00FF ] = $$Keypad6
	virtualKeyFF [ $$XK_Keypad_7				AND 0x00FF ] = $$Keypad7
	virtualKeyFF [ $$XK_Keypad_8				AND 0x00FF ] = $$Keypad8
	virtualKeyFF [ $$XK_Keypad_9				AND 0x00FF ] = $$Keypad9
'
	virtualKeyFF [ $$XK_KeypadMultiply	AND 0x00FF ] = $$KeypadMultiply
	virtualKeyFF [ $$XK_KeypadAdd				AND 0x00FF ] = $$KeypadAdd
	virtualKeyFF [ $$XK_KeypadSubtract	AND 0x00FF ] = $$KeypadSubtract
	virtualKeyFF [ $$XK_KeypadDecimal		AND 0x00FF ] = $$KeypadDecimalPoint
	virtualKeyFF [ $$XK_KeypadDivide		AND 0x00FF ] = $$KeypadDivide
'
	virtualKeyFF [ $$XK_F1							AND 0x00FF ] = $$KeyF1
	virtualKeyFF [ $$XK_F2							AND 0x00FF ] = $$KeyF2
	virtualKeyFF [ $$XK_F3							AND 0x00FF ] = $$KeyF3
	virtualKeyFF [ $$XK_F4							AND 0x00FF ] = $$KeyF4
	virtualKeyFF [ $$XK_F5							AND 0x00FF ] = $$KeyF5
	virtualKeyFF [ $$XK_F6							AND 0x00FF ] = $$KeyF6
	virtualKeyFF [ $$XK_F7							AND 0x00FF ] = $$KeyF7
	virtualKeyFF [ $$XK_F8							AND 0x00FF ] = $$KeyF8
	virtualKeyFF [ $$XK_F9							AND 0x00FF ] = $$KeyF9
	virtualKeyFF [ $$XK_F10							AND 0x00FF ] = $$KeyF10
	virtualKeyFF [ $$XK_F11							AND 0x00FF ] = $$KeyF11
	virtualKeyFF [ $$XK_F12							AND 0x00FF ] = $$KeyF12
	virtualKeyFF [ $$XK_F13							AND 0x00FF ] = $$KeyF13
	virtualKeyFF [ $$XK_F14							AND 0x00FF ] = $$KeyF14
	virtualKeyFF [ $$XK_F15							AND 0x00FF ] = $$KeyF15
	virtualKeyFF [ $$XK_F16							AND 0x00FF ] = $$KeyF16
	virtualKeyFF [ $$XK_F17							AND 0x00FF ] = $$KeyF17
	virtualKeyFF [ $$XK_F18							AND 0x00FF ] = $$KeyF18
	virtualKeyFF [ $$XK_F19							AND 0x00FF ] = $$KeyF19
	virtualKeyFF [ $$XK_F20							AND 0x00FF ] = $$KeyF20
	virtualKeyFF [ $$XK_F21							AND 0x00FF ] = $$KeyF21
	virtualKeyFF [ $$XK_F22							AND 0x00FF ] = $$KeyF22
	virtualKeyFF [ $$XK_F23							AND 0x00FF ] = $$KeyF23
	virtualKeyFF [ $$XK_F24							AND 0x00FF ] = $$KeyF24
'	virtualKeyFF [ $$XK_F25							AND 0x00FF ] = $$KeyF25
'	virtualKeyFF [ $$XK_F26							AND 0x00FF ] = $$KeyF26
'	virtualKeyFF [ $$XK_F27							AND 0x00FF ] = $$KeyF27
'	virtualKeyFF [ $$XK_F28							AND 0x00FF ] = $$KeyF28
'	virtualKeyFF [ $$XK_F29							AND 0x00FF ] = $$KeyF29
'	virtualKeyFF [ $$XK_F30							AND 0x00FF ] = $$KeyF30
'	virtualKeyFF [ $$XK_F31							AND 0x00FF ] = $$KeyF31
'	virtualKeyFF [ $$XK_F32							AND 0x00FF ] = $$KeyF32
'	virtualKeyFF [ $$XK_F33							AND 0x00FF ] = $$KeyF33
'	virtualKeyFF [ $$XK_F34							AND 0x00FF ] = $$KeyF34
'	virtualKeyFF [ $$XK_F35							AND 0x00FF ] = $$KeyF35
	virtualKeyFF [ $$XK_Shift_Left			AND 0x00FF ] = $$KeyLeftShift
	virtualKeyFF [ $$XK_Shift_Right			AND 0x00FF ] = $$KeyRightShift
	virtualKeyFF [ $$XK_Control_Left		AND 0x00FF ] = $$KeyLeftControl
	virtualKeyFF [ $$XK_Control_Right		AND 0x00FF ] = $$KeyRightControl
	virtualKeyFF [ $$XK_Caps_Lock				AND 0x00FF ] = $$KeyCapLock
	virtualKeyFF [ $$XK_Shift_Lock			AND 0x00FF ] = $$KeyCapLock
	virtualKeyFF [ $$XK_Meta_Left				AND 0x00FF ] = $$KeyLeftAlt
	virtualKeyFF [ $$XK_Meta_Right			AND 0x00FF ] = $$KeyRightAlt
	virtualKeyFF [ $$XK_Alt_Left				AND 0x00FF ] = $$KeyLeftAlt
	virtualKeyFF [ $$XK_Alt_Right				AND 0x00FF ] = $$KeyRightAlt
	virtualKeyFF [ $$XK_Super_Left			AND 0x00FF ] = $$KeyLeftAlt
	virtualKeyFF [ $$XK_Super_Right			AND 0x00FF ] = $$KeyRightAlt
	virtualKeyFF [ $$XK_Hyper_Left			AND 0x00FF ] = $$KeyLeftAlt
	virtualKeyFF [ $$XK_Hyper_Right			AND 0x00FF ] = $$KeyRightAlt
'
' added altCharFF 010109 SVG, improved keypad support
'
	altCharFF [ $$XK_Backspace			AND 0x00FF ] = $$KeyBackspace
	altCharFF [ $$XK_Tab						AND 0x00FF ] = $$KeyTab
	altCharFF [ $$XK_Clear					AND 0x00FF ] = $$KeyClear
	altCharFF [ $$XK_Return					AND 0x00FF ] = $$KeyEnter
	altCharFF [ $$XK_Pause					AND 0x00FF ] = $$KeyPause
	altCharFF [ $$XK_Scroll_Lock		AND 0x00FF ] = $$KeyScroll
	altCharFF [ $$XK_Escape					AND 0x00FF ] = $$KeyEscape
	altCharFF [ $$XK_Multi_Key			AND 0x00FF ] = $$KeyRightAlt
	altCharFF [ $$XK_Home						AND 0x00FF ] = $$KeyHome
	altCharFF [ $$XK_Left						AND 0x00FF ] = $$KeyLeftArrow
	altCharFF [ $$XK_Right					AND 0x00FF ] = $$KeyRightArrow
	altCharFF [ $$XK_Up							AND 0x00FF ] = $$KeyUpArrow
	altCharFF [ $$XK_Down						AND 0x00FF ] = $$KeyDownArrow
	altCharFF [ $$XK_PageUp					AND 0x00FF ] = $$KeyPageUp
	altCharFF [ $$XK_PageDown				AND 0x00FF ] = $$KeyPageDown
	altCharFF [ $$XK_End						AND 0x00FF ] = $$KeyEnd
	altCharFF [ $$XK_Select					AND 0x00FF ] = $$KeySelect
	altCharFF [ $$XK_Print					AND 0x00FF ] = $$KeyPrintScreen
	altCharFF [ $$XK_Execute				AND 0x00FF ] = $$KeyExecute
	altCharFF [ $$XK_Insert					AND 0x00FF ] = $$KeyInsert
	altCharFF [ $$XK_Delete					AND 0x00FF ] = $$KeyDelete
	altCharFF [ $$XK_Help						AND 0x00FF ] = $$KeyHelp
	altCharFF [ $$XK_Menu						AND 0x00FF ] = $$KeyApps
	altCharFF [ $$XK_KeypadSpace		AND 0x00FF ] = $$KeySpace
	altCharFF [ $$XK_KeypadTab			AND 0x00FF ] = $$KeyTab
	altCharFF [ $$XK_KeypadEnter		AND 0x00FF ] = $$KeyEnter
	altCharFF [ $$XK_KeypadHome			AND 0x00FF ] = $$Keypad7
	altCharFF [ $$XK_KeypadLeft			AND 0x00FF ] = $$Keypad4
	altCharFF [ $$XK_KeypadUp				AND 0x00FF ] = $$Keypad8
	altCharFF [ $$XK_KeypadRight		AND 0x00FF ] = $$Keypad6
	altCharFF [ $$XK_KeypadDown			AND 0x00FF ] = $$Keypad2
	altCharFF [ $$XK_KeypadPageUp		AND 0x00FF ] = $$Keypad9
	altCharFF [ $$XK_KeypadPageDown	AND 0x00FF ] = $$Keypad3
	altCharFF [ $$XK_KeypadEnd			AND 0x00FF ] = $$Keypad1
	altCharFF [ $$XK_KeypadBegin		AND 0x00FF ] = $$Keypad5
	altCharFF [ $$XK_KeypadInsert		AND 0x00FF ] = $$Keypad0
	altCharFF [ $$XK_KeypadDelete		AND 0x00FF ] = $$KeypadDecimalPoint
	altCharFF [ $$XK_KeypadMultiply	AND 0x00FF ] = $$KeypadMultiply
	altCharFF [ $$XK_KeypadAdd			AND 0x00FF ] = $$KeypadAdd
	altCharFF [ $$XK_KeypadSubtract	AND 0x00FF ] = $$KeypadSubtract
	altCharFF [ $$XK_KeypadDivide		AND 0x00FF ] = $$KeypadDivide
	altCharFF [ $$XK_Num_Lock				AND 0x00FF ] = $$KeyNumLock
	altCharFF [ $$XK_F1							AND 0x00FF ] = $$KeyF1
	altCharFF [ $$XK_F2							AND 0x00FF ] = $$KeyF2
	altCharFF [ $$XK_F3							AND 0x00FF ] = $$KeyF3
	altCharFF [ $$XK_F4							AND 0x00FF ] = $$KeyF4
	altCharFF [ $$XK_F5							AND 0x00FF ] = $$KeyF5
	altCharFF [ $$XK_F6							AND 0x00FF ] = $$KeyF6
	altCharFF [ $$XK_F7							AND 0x00FF ] = $$KeyF7
	altCharFF [ $$XK_F8							AND 0x00FF ] = $$KeyF8
	altCharFF [ $$XK_F9							AND 0x00FF ] = $$KeyF9
	altCharFF [ $$XK_F10						AND 0x00FF ] = $$KeyF10
	altCharFF [ $$XK_F11						AND 0x00FF ] = $$KeyF11
	altCharFF [ $$XK_F12						AND 0x00FF ] = $$KeyF12
	altCharFF [ $$XK_F13						AND 0x00FF ] = $$KeyF13
	altCharFF [ $$XK_F14						AND 0x00FF ] = $$KeyF14
	altCharFF [ $$XK_F15						AND 0x00FF ] = $$KeyF15
	altCharFF [ $$XK_F16						AND 0x00FF ] = $$KeyF16
	altCharFF [ $$XK_F17						AND 0x00FF ] = $$KeyF17
	altCharFF [ $$XK_F18						AND 0x00FF ] = $$KeyF18
	altCharFF [ $$XK_F19						AND 0x00FF ] = $$KeyF19
	altCharFF [ $$XK_F20						AND 0x00FF ] = $$KeyF20
	altCharFF [ $$XK_F21						AND 0x00FF ] = $$KeyF21
	altCharFF [ $$XK_F22						AND 0x00FF ] = $$KeyF22
	altCharFF [ $$XK_F23						AND 0x00FF ] = $$KeyF23
	altCharFF [ $$XK_F24						AND 0x00FF ] = $$KeyF24
	altCharFF [ $$XK_Shift_Left			AND 0x00FF ] = $$KeyLeftShift
	altCharFF [ $$XK_Shift_Right		AND 0x00FF ] = $$KeyRightShift
	altCharFF [ $$XK_Control_Left		AND 0x00FF ] = $$KeyLeftControl
	altCharFF [ $$XK_Control_Right	AND 0x00FF ] = $$KeyRightControl
	altCharFF [ $$XK_Caps_Lock			AND 0x00FF ] = $$KeyCapLock
	altCharFF [ $$XK_Alt_Left				AND 0x00FF ] = $$KeyLeftAlt
	altCharFF [ $$XK_Alt_Right			AND 0x00FF ] = $$KeyRightAlt
'
' *****  charsetKeystateModify[]  *****
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE (i = $$KeyTab)					: charsetKeystateModify[i] = i
			CASE (i = $$KeyEnter)				: charsetKeystateModify[i] = i
			CASE (i = $$KeyDelete)			: charsetKeystateModify[i] = i
			CASE (i = $$KeyInsert)			: charsetKeystateModify[i] = i
			CASE (i = $$KeyBackspace)		: charsetKeystateModify[i] = i
			CASE (i < 32)								: charsetKeystateModify[i] = 0
			CASE ELSE										: charsetKeystateModify[i] = i
		END SELECT
	NEXT i
'
' need to open a display and window to be able to register cursors and get
' #displayWidth, #displayHeight, #windowBorderWidth, #windowTitleHeight
'
	display$ = ""
	error = Display (@display, $$Open, @display$)			' no error if already open
	IF error THEN
		PRINT "Can't open display \"" + display$ + "\""
		exit(1)
	END IF
	
	XgrCreateWindow (@window, 0, 8, 24, 64, 32, 0, "")
	#sdisplayEternal = window[window].sdisplay
	#displayEternal = window[window].display
	#swindowEternal = window[window].swindow
	#windowEternal = window
'
' register standard cursors
'
	XgrRegisterCursor (@"default",      @#cursorDefault)
	XgrRegisterCursor (@"arrow",        @#cursorArrow)
	XgrRegisterCursor (@"n",            @#cursorN)
	XgrRegisterCursor (@"s",            @#cursorS)
	XgrRegisterCursor (@"e",            @#cursorE)
	XgrRegisterCursor (@"w",            @#cursorW)
	XgrRegisterCursor (@"ns",           @#cursorArrowsNS)
	XgrRegisterCursor (@"ns",           @#cursorArrowsSN)
	XgrRegisterCursor (@"ew",           @#cursorArrowsEW)
	XgrRegisterCursor (@"ew",           @#cursorArrowsWE)
	XgrRegisterCursor (@"nwse",         @#cursorArrowsNWSE)
	XgrRegisterCursor (@"nesw",         @#cursorArrowsNESW)
	XgrRegisterCursor (@"all",          @#cursorArrowsAll)
	XgrRegisterCursor (@"plus",         @#cursorPlus)
	XgrRegisterCursor (@"wait",         @#cursorWait)
	XgrRegisterCursor (@"insert",       @#cursorInsert)
	XgrRegisterCursor (@"crosshair",    @#cursorCrosshair)
	XgrRegisterCursor (@"hourglass",    @#cursorHourglass)
	XgrRegisterCursor (@"hand",         @#cursorHand)
	XgrRegisterCursor (@"help",         @#cursorHelp)
'
' register GraphicsDesigner messages
'
	XgrRegisterMessage (@"Blowback",										@#Blowback)
	XgrRegisterMessage (@"Callback",										@#Callback)
	XgrRegisterMessage (@"Cancel",											@#Cancel)
	XgrRegisterMessage (@"Change",											@#Change)
	XgrRegisterMessage (@"CloseWindow",									@#CloseWindow)
	XgrRegisterMessage (@"ContextChange",								@#ContextChange)
	XgrRegisterMessage (@"Create",											@#Create)
	XgrRegisterMessage (@"CreateValueArray",						@#CreateValueArray)
	XgrRegisterMessage (@"CreateWindow",								@#CreateWindow)
	XgrRegisterMessage (@"CursorH",											@#CursorH)
	XgrRegisterMessage (@"CursorV",											@#CursorV)
	XgrRegisterMessage (@"Deselected",									@#Deselected)
	XgrRegisterMessage (@"Destroy",											@#Destroy)
	XgrRegisterMessage (@"Destroyed",										@#Destroyed)
	XgrRegisterMessage (@"DestroyWindow",								@#DestroyWindow)
	XgrRegisterMessage (@"Disable",											@#Disable)
	XgrRegisterMessage (@"Disabled",										@#Disabled)
	XgrRegisterMessage (@"Displayed",										@#Displayed)
	XgrRegisterMessage (@"DisplayWindow",								@#DisplayWindow)
	XgrRegisterMessage (@"Enable",											@#Enable)
	XgrRegisterMessage (@"Enabled",											@#Enabled)
	XgrRegisterMessage (@"Enter",												@#Enter)
	XgrRegisterMessage (@"ExitMessageLoop",							@#ExitMessageLoop)
	XgrRegisterMessage (@"Find",												@#Find)
	XgrRegisterMessage (@"FindForward",									@#FindForward)
	XgrRegisterMessage (@"FindReverse",									@#FindReverse)
	XgrRegisterMessage (@"Forward",											@#Forward)
	XgrRegisterMessage (@"GetAlign",										@#GetAlign)
	XgrRegisterMessage (@"GetBorder",										@#GetBorder)
	XgrRegisterMessage (@"GetBorderOffset",							@#GetBorderOffset)
	XgrRegisterMessage (@"GetCallback",									@#GetCallback)
	XgrRegisterMessage (@"GetCallbackArgs",							@#GetCallbackArgs)
	XgrRegisterMessage (@"GetCan",											@#GetCan)
	XgrRegisterMessage (@"GetCharacterMapArray",				@#GetCharacterMapArray)
	XgrRegisterMessage (@"GetCharacterMapEntry",				@#GetCharacterMapEntry)
	XgrRegisterMessage (@"GetClipGrid",									@#GetClipGrid)
	XgrRegisterMessage (@"GetColor",										@#GetColor)
	XgrRegisterMessage (@"GetColorExtra",								@#GetColorExtra)
	XgrRegisterMessage (@"GetCursor",										@#GetCursor)
	XgrRegisterMessage (@"GetCursorXY",									@#GetCursorXY)
	XgrRegisterMessage (@"GetDisplay",									@#GetDisplay)
	XgrRegisterMessage (@"GetEnclosedGrids",						@#GetEnclosedGrids)
	XgrRegisterMessage (@"GetEnclosingGrid",						@#GetEnclosingGrid)
	XgrRegisterMessage (@"GetFocusColor",								@#GetFocusColor)
	XgrRegisterMessage (@"GetFocusColorExtra",					@#GetFocusColorExtra)
	XgrRegisterMessage (@"GetFont",											@#GetFont)
	XgrRegisterMessage (@"GetFontMetrics",							@#GetFontMetrics)
	XgrRegisterMessage (@"GetFontNumber",								@#GetFontNumber)
	XgrRegisterMessage (@"GetGridFunction",							@#GetGridFunction)
	XgrRegisterMessage (@"GetGridFunctionName",					@#GetGridFunctionName)
	XgrRegisterMessage (@"GetGridName",									@#GetGridName)
	XgrRegisterMessage (@"GetGridNumber",								@#GetGridNumber)
	XgrRegisterMessage (@"GetGridProperties",						@#GetGridProperties)
	XgrRegisterMessage (@"GetGridType",									@#GetGridType)
	XgrRegisterMessage (@"GetGridTypeName",							@#GetGridTypeName)
	XgrRegisterMessage (@"GetGroup",										@#GetGroup)
	XgrRegisterMessage (@"GetHelp",											@#GetHelp)
	XgrRegisterMessage (@"GetHelpFile",									@#GetHelpFile)
	XgrRegisterMessage (@"GetHelpString",								@#GetHelpString)
	XgrRegisterMessage (@"GetHelpStrings",							@#GetHelpStrings)
	XgrRegisterMessage (@"GetHintString",								@#GetHintString)
	XgrRegisterMessage (@"GetImage",										@#GetImage)
	XgrRegisterMessage (@"GetImageCoords",							@#GetImageCoords)
	XgrRegisterMessage (@"GetIndent",										@#GetIndent)
	XgrRegisterMessage (@"GetInfo",											@#GetInfo)
	XgrRegisterMessage (@"GetJustify",									@#GetJustify)
	XgrRegisterMessage (@"GetKeyboardFocus",						@#GetKeyboardFocus)
	XgrRegisterMessage (@"GetKeyboardFocusGrid",				@#GetKeyboardFocusGrid)
	XgrRegisterMessage (@"GetKidArray",									@#GetKidArray)
	XgrRegisterMessage (@"GetKidNumber",								@#GetKidNumber)
	XgrRegisterMessage (@"GetKids",											@#GetKids)
	XgrRegisterMessage (@"GetKind",											@#GetKind)
	XgrRegisterMessage (@"GetMaxMinSize",								@#GetMaxMinSize)
	XgrRegisterMessage (@"GetMenuEntryArray",						@#GetMenuEntryArray)
	XgrRegisterMessage (@"GetMessageFunc",							@#GetMessageFunc)
	XgrRegisterMessage (@"GetMessageFuncArray",					@#GetMessageFuncArray)
	XgrRegisterMessage (@"GetMessageSub",								@#GetMessageSub)
	XgrRegisterMessage (@"GetMessageSubArray",					@#GetMessageSubArray)
	XgrRegisterMessage (@"GetModalInfo",								@#GetModalInfo)
	XgrRegisterMessage (@"GetModalWindow",							@#GetModalWindow)
	XgrRegisterMessage (@"GetParent",										@#GetParent)
	XgrRegisterMessage (@"GetPosition",									@#GetPosition)
	XgrRegisterMessage (@"GetProtoInfo",								@#GetProtoInfo)
	XgrRegisterMessage (@"GetRedrawFlags",							@#GetRedrawFlags)
	XgrRegisterMessage (@"GetSize",											@#GetSize)
	XgrRegisterMessage (@"GetSmallestSize",							@#GetSmallestSize)
	XgrRegisterMessage (@"GetState",										@#GetState)
	XgrRegisterMessage (@"GetStyle",										@#GetStyle)
	XgrRegisterMessage (@"GetTabArray",									@#GetTabArray)
	XgrRegisterMessage (@"GetTabWidth",									@#GetTabWidth)
	XgrRegisterMessage (@"GetTextArray",								@#GetTextArray)
	XgrRegisterMessage (@"GetTextArrayBounds",					@#GetTextArrayBounds)
	XgrRegisterMessage (@"GetTextArrayLine",						@#GetTextArrayLine)
	XgrRegisterMessage (@"GetTextArrayLines",						@#GetTextArrayLines)
	XgrRegisterMessage (@"GetTextCursor",								@#GetTextCursor)
	XgrRegisterMessage (@"GetTextFilename",							@#GetTextFilename)
	XgrRegisterMessage (@"GetTextPosition",							@#GetTextPosition)
	XgrRegisterMessage (@"GetTextSelection",						@#GetTextSelection)
	XgrRegisterMessage (@"GetTextSpacing",							@#GetTextSpacing)
	XgrRegisterMessage (@"GetTextString",								@#GetTextString)
	XgrRegisterMessage (@"GetTextStrings",							@#GetTextStrings)
	XgrRegisterMessage (@"GetTexture",									@#GetTexture)
	XgrRegisterMessage (@"GetTimer",										@#GetTimer)
	XgrRegisterMessage (@"GetValue",										@#GetValue)
	XgrRegisterMessage (@"GetValueArray",								@#GetValueArray)
	XgrRegisterMessage (@"GetValues",										@#GetValues)
	XgrRegisterMessage (@"GetWindow",										@#GetWindow)
	XgrRegisterMessage (@"GetWindowFunction",						@#GetWindowFunction)
	XgrRegisterMessage (@"GetWindowGrid",								@#GetWindowGrid)
	XgrRegisterMessage (@"GetWindowIcon",								@#GetWindowIcon)
	XgrRegisterMessage (@"GetWindowSize",								@#GetWindowSize)
	XgrRegisterMessage (@"GetWindowTitle",							@#GetWindowTitle)
	XgrRegisterMessage (@"GotKeyboardFocus",						@#GotKeyboardFocus)
	XgrRegisterMessage (@"GrabArray",										@#GrabArray)
	XgrRegisterMessage (@"GrabTextArray",								@#GrabTextArray)
	XgrRegisterMessage (@"GrabTextString",							@#GrabTextString)
	XgrRegisterMessage (@"GrabValueArray",							@#GrabValueArray)
	XgrRegisterMessage (@"Help",												@#Help)
	XgrRegisterMessage (@"Hidden",											@#Hidden)
	XgrRegisterMessage (@"HideTextCursor",							@#HideTextCursor)
	XgrRegisterMessage (@"HideWindow",									@#HideWindow)
	XgrRegisterMessage (@"Initialize",									@#Initialize)
	XgrRegisterMessage (@"Initialized",									@#Initialized)
	XgrRegisterMessage (@"Inline",											@#Inline)
	XgrRegisterMessage (@"InquireText",									@#InquireText)
	XgrRegisterMessage (@"KeyboardFocusBackward",				@#KeyboardFocusBackward)
	XgrRegisterMessage (@"KeyboardFocusForward",				@#KeyboardFocusForward)
	XgrRegisterMessage (@"KeyDown",											@#KeyDown)
	XgrRegisterMessage (@"KeyUp",												@#KeyUp)
	XgrRegisterMessage (@"LostKeyboardFocus",						@#LostKeyboardFocus)
	XgrRegisterMessage (@"LostTextSelection",						@#LostTextSelection)
	XgrRegisterMessage (@"Maximized",										@#Maximized)
	XgrRegisterMessage (@"MaximizeWindow",							@#MaximizeWindow)
	XgrRegisterMessage (@"Maximum",											@#Maximum)
	XgrRegisterMessage (@"Minimized",										@#Minimized)
	XgrRegisterMessage (@"MinimizeWindow",							@#MinimizeWindow)
	XgrRegisterMessage (@"Minimum",											@#Minimum)
	XgrRegisterMessage (@"MonitorContext",							@#MonitorContext)
	XgrRegisterMessage (@"MonitorHelp",									@#MonitorHelp)
	XgrRegisterMessage (@"MonitorKeyboard",							@#MonitorKeyboard)
	XgrRegisterMessage (@"MonitorMouse",								@#MonitorMouse)
	XgrRegisterMessage (@"MouseDown",										@#MouseDown)
	XgrRegisterMessage (@"MouseDrag",										@#MouseDrag)
	XgrRegisterMessage (@"MouseEnter",									@#MouseEnter)
	XgrRegisterMessage (@"MouseExit",										@#MouseExit)
	XgrRegisterMessage (@"MouseMove",										@#MouseMove)
	XgrRegisterMessage (@"MouseUp",											@#MouseUp)
	XgrRegisterMessage (@"MouseWheel",									@#MouseWheel)
	XgrRegisterMessage (@"MuchLess",										@#MuchLess)
	XgrRegisterMessage (@"MuchMore",										@#MuchMore)
	XgrRegisterMessage (@"Notify",											@#Notify)
	XgrRegisterMessage (@"OneLess",											@#OneLess)
	XgrRegisterMessage (@"OneMore",											@#OneMore)
	XgrRegisterMessage (@"PokeArray",										@#PokeArray)
	XgrRegisterMessage (@"PokeTextArray",								@#PokeTextArray)
	XgrRegisterMessage (@"PokeTextString",							@#PokeTextString)
	XgrRegisterMessage (@"PokeValueArray",							@#PokeValueArray)
	XgrRegisterMessage (@"Print",												@#Print)
	XgrRegisterMessage (@"Redraw",											@#Redraw)
	XgrRegisterMessage (@"RedrawGrid",									@#RedrawGrid)
	XgrRegisterMessage (@"RedrawLines",									@#RedrawLines)
	XgrRegisterMessage (@"Redrawn",											@#Redrawn)
	XgrRegisterMessage (@"RedrawText",									@#RedrawText)
	XgrRegisterMessage (@"RedrawWindow",								@#RedrawWindow)
	XgrRegisterMessage (@"Replace",											@#Replace)
	XgrRegisterMessage (@"ReplaceForward",							@#ReplaceForward)
	XgrRegisterMessage (@"ReplaceReverse",							@#ReplaceReverse)
	XgrRegisterMessage (@"Reset",												@#Reset)
	XgrRegisterMessage (@"Resize",											@#Resize)
	XgrRegisterMessage (@"Resized",											@#Resized)
	XgrRegisterMessage (@"ResizeNot",										@#ResizeNot)
	XgrRegisterMessage (@"ResizeWindow",								@#ResizeWindow)
	XgrRegisterMessage (@"ResizeWindowToGrid",					@#ResizeWindowToGrid)
	XgrRegisterMessage (@"Resized",											@#Resized)
	XgrRegisterMessage (@"Reverse",											@#Reverse)
	XgrRegisterMessage (@"ScrollH",											@#ScrollH)
	XgrRegisterMessage (@"ScrollV",											@#ScrollV)
	XgrRegisterMessage (@"Select",											@#Select)
	XgrRegisterMessage (@"Selected",										@#Selected)
	XgrRegisterMessage (@"Selection",										@#Selection)
	XgrRegisterMessage (@"SelectWindow",								@#SelectWindow)
	XgrRegisterMessage (@"SetAlign",										@#SetAlign)
	XgrRegisterMessage (@"SetBorder",										@#SetBorder)
	XgrRegisterMessage (@"SetBorderOffset",							@#SetBorderOffset)
	XgrRegisterMessage (@"SetCallback",									@#SetCallback)
	XgrRegisterMessage (@"SetCan",											@#SetCan)
	XgrRegisterMessage (@"SetCharacterMapArray",				@#SetCharacterMapArray)
	XgrRegisterMessage (@"SetCharacterMapEntry",				@#SetCharacterMapEntry)
	XgrRegisterMessage (@"SetClipGrid",									@#SetClipGrid)
	XgrRegisterMessage (@"SetColor",										@#SetColor)
	XgrRegisterMessage (@"SetColorAll",									@#SetColorAll)
	XgrRegisterMessage (@"SetColorExtra",								@#SetColorExtra)
	XgrRegisterMessage (@"SetColorExtraAll",						@#SetColorExtraAll)
	XgrRegisterMessage (@"SetCursor",										@#SetCursor)
	XgrRegisterMessage (@"SetCursorXY",									@#SetCursorXY)
	XgrRegisterMessage (@"SetDisplay",									@#SetDisplay)
	XgrRegisterMessage (@"SetFocusColor",								@#SetFocusColor)
	XgrRegisterMessage (@"SetFocusColorExtra",					@#SetFocusColorExtra)
	XgrRegisterMessage (@"SetFont",											@#SetFont)
	XgrRegisterMessage (@"SetFontNumber",								@#SetFontNumber)
	XgrRegisterMessage (@"SetGridFunction",							@#SetGridFunction)
	XgrRegisterMessage (@"SetGridFunctionName",					@#SetGridFunctionName)
	XgrRegisterMessage (@"SetGridName",									@#SetGridName)
	XgrRegisterMessage (@"SetGridProperties",						@#SetGridProperties)
	XgrRegisterMessage (@"SetGridType",									@#SetGridType)
	XgrRegisterMessage (@"SetGridTypeName",							@#SetGridTypeName)
	XgrRegisterMessage (@"SetGroup",										@#SetGroup)
	XgrRegisterMessage (@"SetHelp",											@#SetHelp)
	XgrRegisterMessage (@"SetHelpFile",									@#SetHelpFile)
	XgrRegisterMessage (@"SetHelpString",								@#SetHelpString)
	XgrRegisterMessage (@"SetHelpStrings",							@#SetHelpStrings)
	XgrRegisterMessage (@"SetHintString",								@#SetHintString)
	XgrRegisterMessage (@"SetImage",										@#SetImage)
	XgrRegisterMessage (@"SetImageCoords",							@#SetImageCoords)
	XgrRegisterMessage (@"SetIndent",										@#SetIndent)
	XgrRegisterMessage (@"SetInfo",											@#SetInfo)
	XgrRegisterMessage (@"SetJustify",									@#SetJustify)
	XgrRegisterMessage (@"SetKeyboardFocus",						@#SetKeyboardFocus)
	XgrRegisterMessage (@"SetKeyboardFocusGrid",				@#SetKeyboardFocusGrid)
	XgrRegisterMessage (@"SetKidArray",									@#SetKidArray)
	XgrRegisterMessage (@"SetMaxMinSize",								@#SetMaxMinSize)
	XgrRegisterMessage (@"SetMenuEntryArray",						@#SetMenuEntryArray)
	XgrRegisterMessage (@"SetMessageFunc",							@#SetMessageFunc)
	XgrRegisterMessage (@"SetMessageFuncArray",					@#SetMessageFuncArray)
	XgrRegisterMessage (@"SetMessageSub",								@#SetMessageSub)
	XgrRegisterMessage (@"SetMessageSubArray",					@#SetMessageSubArray)
	XgrRegisterMessage (@"SetModalWindow",							@#SetModalWindow)
	XgrRegisterMessage (@"SetParent",										@#SetParent)
	XgrRegisterMessage (@"SetPosition",									@#SetPosition)
	XgrRegisterMessage (@"SetRedrawFlags",							@#SetRedrawFlags)
	XgrRegisterMessage (@"SetSize",											@#SetSize)
	XgrRegisterMessage (@"SetState",										@#SetState)
	XgrRegisterMessage (@"SetStyle",										@#SetStyle)
	XgrRegisterMessage (@"SetTabArray",									@#SetTabArray)
	XgrRegisterMessage (@"SetTabWidth",									@#SetTabWidth)
	XgrRegisterMessage (@"SetTextArray",								@#SetTextArray)
	XgrRegisterMessage (@"SetTextArrayLine",						@#SetTextArrayLine)
	XgrRegisterMessage (@"SetTextArrayLines",						@#SetTextArrayLines)
	XgrRegisterMessage (@"SetTextCursor",								@#SetTextCursor)
	XgrRegisterMessage (@"SetTextFilename",							@#SetTextFilename)
	XgrRegisterMessage (@"SetTextSelection",						@#SetTextSelection)
	XgrRegisterMessage (@"SetTextSpacing",							@#SetTextSpacing)
	XgrRegisterMessage (@"SetTextString",								@#SetTextString)
	XgrRegisterMessage (@"SetTextStrings",							@#SetTextStrings)
	XgrRegisterMessage (@"SetTexture",									@#SetTexture)
	XgrRegisterMessage (@"SetTimer",										@#SetTimer)
	XgrRegisterMessage (@"SetValue",										@#SetValue)
	XgrRegisterMessage (@"SetValues",										@#SetValues)
	XgrRegisterMessage (@"SetValueArray",								@#SetValueArray)
	XgrRegisterMessage (@"SetWindowFunction",						@#SetWindowFunction)
	XgrRegisterMessage (@"SetWindowIcon",								@#SetWindowIcon)
	XgrRegisterMessage (@"SetWindowTitle",							@#SetWindowTitle)
	XgrRegisterMessage (@"ShowTextCursor",							@#ShowTextCursor)
	XgrRegisterMessage (@"ShowWindow",									@#ShowWindow)
	XgrRegisterMessage (@"SomeLess",										@#SomeLess)
	XgrRegisterMessage (@"SomeMore",										@#SomeMore)
	XgrRegisterMessage (@"StartTimer",									@#StartTimer)
	XgrRegisterMessage (@"SystemMessage",								@#SystemMessage)
	XgrRegisterMessage (@"TextDelete",									@#TextDelete)
	XgrRegisterMessage (@"TextEvent",										@#TextEvent)
	XgrRegisterMessage (@"TextInsert",									@#TextInsert)
	XgrRegisterMessage (@"TextModified",								@#TextModified)
	XgrRegisterMessage (@"TextReplace",									@#TextReplace)
	XgrRegisterMessage (@"TimeOut",											@#TimeOut)
	XgrRegisterMessage (@"Update",											@#Update)
	XgrRegisterMessage (@"WindowClose",									@#WindowClose)
	XgrRegisterMessage (@"WindowCreate",								@#WindowCreate)
	XgrRegisterMessage (@"WindowDeselected",						@#WindowDeselected)
	XgrRegisterMessage (@"WindowDestroy",								@#WindowDestroy)
	XgrRegisterMessage (@"WindowDestroyed",							@#WindowDestroyed)
	XgrRegisterMessage (@"WindowDisplay",								@#WindowDisplay)
	XgrRegisterMessage (@"WindowDisplayed",							@#WindowDisplayed)
	XgrRegisterMessage (@"WindowGetDisplay",						@#WindowGetDisplay)
	XgrRegisterMessage (@"WindowGetFunction",						@#WindowGetFunction)
	XgrRegisterMessage (@"WindowGetIcon",								@#WindowGetIcon)
	XgrRegisterMessage (@"WindowGetKeyboardFocusGrid",	@#WindowGetKeyboardFocusGrid)
	XgrRegisterMessage (@"WindowGetSelectedWindow",			@#WindowGetSelectedWindow)
	XgrRegisterMessage (@"WindowGetSize",								@#WindowGetSize)
	XgrRegisterMessage (@"WindowGetTitle",							@#WindowGetTitle)
	XgrRegisterMessage (@"WindowHelp",									@#WindowHelp)
	XgrRegisterMessage (@"WindowHide",									@#WindowHide)
	XgrRegisterMessage (@"WindowHidden",								@#WindowHidden)
	XgrRegisterMessage (@"WindowKeyDown",								@#WindowKeyDown)
	XgrRegisterMessage (@"WindowKeyUp",									@#WindowKeyUp)
	XgrRegisterMessage (@"WindowMaximize",							@#WindowMaximize)
	XgrRegisterMessage (@"WindowMaximized",							@#WindowMaximized)
	XgrRegisterMessage (@"WindowMinimize",							@#WindowMinimize)
	XgrRegisterMessage (@"WindowMinimized",							@#WindowMinimized)
	XgrRegisterMessage (@"WindowMonitorContext",				@#WindowMonitorContext)
	XgrRegisterMessage (@"WindowMonitorHelp",						@#WindowMonitorHelp)
	XgrRegisterMessage (@"WindowMonitorKeyboard",				@#WindowMonitorKeyboard)
	XgrRegisterMessage (@"WindowMonitorMouse",					@#WindowMonitorMouse)
	XgrRegisterMessage (@"WindowMouseDown",							@#WindowMouseDown)
	XgrRegisterMessage (@"WindowMouseDrag",							@#WindowMouseDrag)
	XgrRegisterMessage (@"WindowMouseEnter",						@#WindowMouseEnter)
	XgrRegisterMessage (@"WindowMouseExit",							@#WindowMouseExit)
	XgrRegisterMessage (@"WindowMouseMove",							@#WindowMouseMove)
	XgrRegisterMessage (@"WindowMouseUp",								@#WindowMouseUp)
	XgrRegisterMessage (@"WindowMouseWheel",						@#WindowMouseWheel)
	XgrRegisterMessage (@"WindowRedraw",								@#WindowRedraw)
	XgrRegisterMessage (@"WindowRegister",							@#WindowRegister)
	XgrRegisterMessage (@"WindowResize",								@#WindowResize)
	XgrRegisterMessage (@"WindowResized",								@#WindowResized)
	XgrRegisterMessage (@"WindowResizeToGrid",					@#WindowResizeToGrid)
	XgrRegisterMessage (@"WindowSelect",								@#WindowSelect)
	XgrRegisterMessage (@"WindowSelected",							@#WindowSelected)
	XgrRegisterMessage (@"WindowSetFunction",						@#WindowSetFunction)
	XgrRegisterMessage (@"WindowSetIcon",								@#WindowSetIcon)
	XgrRegisterMessage (@"WindowSetKeyboardFocusGrid",	@#WindowSetKeyboardFocusGrid)
	XgrRegisterMessage (@"WindowSetTitle",							@#WindowSetTitle)
	XgrRegisterMessage (@"WindowShow",									@#WindowShow)
	XgrRegisterMessage (@"WindowSystemMessage",					@#WindowSystemMessage)
	XgrRegisterMessage (@"LastMessage",									@#LastMessage)
'
' need to process events from created window to set up the
' internal windowBorderWidth and windowTitleHeight variables
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	DispatchEvents ($$TRUE, $$FALSE)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	XgrShowWindow (window)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	DispatchEvents ($$TRUE, $$FALSE)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	XgrHideWindow (window)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	DispatchEvents ($$TRUE, $$FALSE)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	XgrProcessMessages (-2)
'
'
' get window manager protocols to prevent forced window/application destruction
'
	sdisplay = window[window].sdisplay
	swindow = window[window].swindow
'
' if you want to see the name of the server vendor, as in "The XFree86 Project, Inc"
'
'	addr = XServerVendor (sdisplay)
'	a$ = CSTRING$(addr) + "\n"
'	write (1, &a$, LEN(a$))
'
' the following causes a segment violation exception in XInternAtom()
'
'	#XA_WM_PROTOCOLS = XInternAtom (sdisplay, &"WM_PROTOCOLS", 0)
'	#XA_WM_TAKE_FOCUS = XInternAtom (sdisplay, &"WM_TAKE_FOCUS", 0)
'	#XA_WM_SAVE_YOURSELF = XInternAtom (sdisplay, &"WM_SAVE_YOURSELF", 0)
'	#XA_WM_DELETE_WINDOW = XInternAtom (sdipslay, &"WM_DELETE_WINDOW", 0)
'
	a0$ = "DIB"
	a1$ = "TEXT"
	a2$ = "IMAGE"
	a3$ = "PIXMAP"
	a4$ = "STRING"
	a5$ = "PRIMARY"
	a6$ = "SECONDARY"
	a7$ = "CLIPBOARD"
	a8$ = "WM_NAME"
	a9$ = "WM_PROTOCOLS"
	aa$ = "WM_TAKE_FOCUS"
	ab$ = "WM_SAVE_YOURSELF"
	ac$ = "WM_DELETE_WINDOW"
'
	#XA_DIB = XInternAtom (sdisplay, &a0$, 0)
	#XA_TEXT = XInternAtom (sdisplay, &a1$, 0)
	#XA_IMAGE = XInternAtom (sdisplay, &a2$, 0)
	#XA_PIXMAP = XInternAtom (sdisplay, &a3$, 0)
	#XA_STRING = XInternAtom (sdisplay, &a4$, 0)
	#XA_PRIMARY = XInternAtom (sdisplay, &a5$, 0)
	#XA_SECONDARY = XInternAtom (sdisplay, &a6$, 0)
	#XA_CLIPBOARD = XInternAtom (sdisplay, &a7$, 0)
	#XA_WM_NAME = XInternAtom (sdisplay, &a8$, 0)
	#XA_WM_PROTOCOLS = XInternAtom (sdisplay, &a9$, 0)
	#XA_WM_TAKE_FOCUS = XInternAtom (sdisplay, &aa$, 0)
	#XA_WM_SAVE_YOURSELF = XInternAtom (sdisplay, &ab$, 0)
	#XA_WM_DELETE_WINDOW = XInternAtom (sdisplay, &ac$, 0)
'
'
' so a loop through XGetAtomName() will have to do for now
'
'	FOR atom = 1 TO 255
'		addr = XGetAtomName (sdisplay, atom)
'		atom$ = CSTRING$ (addr)
'		XFree (addr)
'		SELECT CASE atom$
'			CASE "WM_PROTOCOLS"			: #XA_WM_PROTOCOLS = atom
'			CASE "WM_DELETE_WINDOW"	: #XA_WM_DELETE_WINDOW = atom
'		END SELECT
'		IF #XA_WM_PROTOCOLS THEN
'			IF #XA_WM_DELETE_WINDOW THEN EXIT FOR
'		END IF
'	NEXT atom
'
' get display and window frame sizes
'
	XgrGetDisplaySize ("", @#displayWidth, @#displayHeight, @#windowBorderWidth, @#windowTitleHeight)
'
'	a$ = STRING$(#displayWidth) + " " + STRING$(#displayHeight) + " " + STRING$(#windowBorderWidth) + " " + STRING$(#windowTitleHeight) + "\n"
'	write (1, &a$, LEN(a$))
'
' install default character map if one exists
'
	IF charMap[] THEN
		name$ = "$HOME" + $$PathSlash$ + "charmap.bin"
		XstGetFileAttributes (@name$, @attr)
			IF ((attr = 0) OR (attr AND $$FileDirectory)) THEN
			name$ = "." + $$PathSlash$ + "charmap.bin"
			XstGetFileAttributes (@name$, @attr)
			IF ((attr = 0) OR (attr AND $$FileDirectory)) THEN
				name$ = "$XBDIR" + $$PathSlash$ + "templates" + $$PathSlash$ + "charmap.bin"
				XstGetFileAttributes (@name$, @attr)
			END IF
		END IF
		IF attr THEN
			IFZ (attr AND $$FileDirectory) THEN
				ifile = OPEN (name$, $$RD)
				IF (ifile > 2) THEN
					size = LOF (ifile)
					IF (size >= 1024) THEN
						upper = (size >> 2) - 1
						##WHOMASK = 0
						DIM map[upper]
						##WHOMASK = whomask
						READ [ifile], map[]
						ATTACH map[] TO charMap[0,]
					END IF
					CLOSE (ifile)
				END IF
			END IF
		END IF
	END IF
'
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ######################################
' #####  XgrBorderNameToNumber ()  #####
' ######################################
'
FUNCTION  XgrBorderNameToNumber (border$, @border)
	SHARED	border$[]
'
	IF #trace THEN PRINT "XgrBorderNameToNumber() : "; border$
'
	border = XLONG (border$)
	IF border THEN RETURN
	b$ = TRIM$ (border$)
	IFZ b$ THEN RETURN
'
	c = b${0}
	IF ((c >= '0') AND (c <= '9')) THEN RETURN		' "0" or "0x00" ...
	IF (c != '$') THEN b$ = "$$" + b$
'
	border = -1
	upper = UBOUND (border$[])
	FOR i = 0 TO upper
		IF (b$ = border$[i]) THEN
			border = i
			RETURN
		END IF
	NEXT i
	RETURN ($$TRUE)
END FUNCTION
'
'
' ######################################
' #####  XgrBorderNumberToName ()  #####
' ######################################
'
FUNCTION  XgrBorderNumberToName (border, @border$)
	SHARED	border$[]
'
	IF #trace THEN PRINT "XgrBorderNumberToName() : "; border
'
	border$ = ""
	upper = UBOUND (border$[])
	IF (border < 0) THEN RETURN
	IF (border > upper) THEN RETURN
	border$ = border$[border]
END FUNCTION
'
'
' #######################################
' #####  XgrBorderNumberToWidth ()  #####
' #######################################
'
FUNCTION  XgrBorderNumberToWidth (border, @width)
	SHARED	borderWidth[]
'
	IF #trace THEN PRINT "XgrBorderNumberToWidth() : "; border
'
	width = 0
	upper = UBOUND (borderWidth[])
	IF (border < 0) THEN RETURN
	IF (border > upper) THEN RETURN
	width = borderWidth[border]
END FUNCTION
'
'
' #####################################
' #####  XgrColorNameToNumber ()  #####
' #####################################
'
FUNCTION  XgrColorNameToNumber (color$, color)
	SHARED	color$[]
'
	color = XLONG (color$)
	IF color THEN RETURN
	c$ = TRIM$ (color$)
	IFZ c$ THEN RETURN
'
	c = c${0}
	IF ((c >= '0') AND (c <= '9')) THEN RETURN		' "0" or "0x00" ...
	IF (c != '$') THEN c$ = "$$" + c$
'
	IF (c$ = "$$LightGrey") THEN c$ = "$$BrightGrey"
	IF (c$ = "$$BrightYellow") THEN c$ = "$$LightYellow"
	IF (c$ = "$$LightOrange") THEN c$ = "$$BrightOrange"
	IF (c$ = "$$LightViolet") THEN c$ = "$$BrightViolet"
'
	color = -1
	upper = UBOUND (color$[])
	FOR i = 0 TO upper
		IF (c$ = color$[i]) THEN
			color = i
			RETURN
		END IF
	NEXT i
	RETURN ($$TRUE)
END FUNCTION
'
'
' #####################################
' #####  XgrColorNumberToName ()  #####
' #####################################
'
FUNCTION  XgrColorNumberToName (color, color$)
	SHARED	color$[]
'
	color$ = ""
	upper = UBOUND (color$[])
	IF (color < 0) THEN RETURN
	IF (color > upper) THEN RETURN
	color$ = color$[color]
END FUNCTION
'
'
' ######################################
' #####  XgrCursorNameToNumber ()  #####
' ######################################
'
FUNCTION  XgrCursorNameToNumber (cursor$, @cursor)
	SHARED  lastCursor
	SHARED  cursor$[]
	SHARED  cursor[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrCursorNameToNumber() : "; cursor$
'
	cursor = 0
	IFZ cursor$ THEN RETURN ($$FALSE)			' default system cursor
'
	IF (cursor$ = "LastCursor") THEN
		cursor = lastCursor
		RETURN ($$FALSE)
	END IF
'
	upper = UBOUND (cursor$[])
	FOR cursor = 0 TO upper
		IF (cursor$ = cursor$[cursor]) THEN RETURN ($$FALSE)	' found cursor
	NEXT cursor
'
	cursor = 0
	##ERROR = ($$ErrorObjectCursor << 8) OR $$ErrorNatureNonexistent
	IF debug THEN PRINT "XgrCursorNameToNumber() : unregistered cursor"
	RETURN ($$TRUE)
END FUNCTION
'
'
' ######################################
' #####  XgrCursorNumberToName ()  #####
' ######################################
'
FUNCTION  XgrCursorNumberToName (cursor, @cursor$)
	SHARED  cursor$[]
	SHARED  cursor[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrCursorNumberToName() : "; cursor
'
	cursor$ = ""
'
	upper = UBOUND (cursor$[])
	IF ((cursor < 0) OR (cursor > upper)) THEN
		##ERROR = ($$ErrorObjectCursor << 8) OR $$ErrorNatureInvalidIdentity
		IF debug THEN PRINT "XgrCursorNumberToName() : invalid cursor #"
		RETURN ($$TRUE)
	END IF
'
	cursor$ = cursor$[cursor]
END FUNCTION
'
'
' ################################
' #####  XgrGetClipboard ()  #####
' ################################
'
FUNCTION  XgrGetClipboard (clipboard, type, data$, UBYTE data[])
	SHARED  XSelectionEvent  selectionNotify
	SHARED  UBYTE  clipData[]
	SHARED  clipText$[]
	SHARED  clipType[]
	SHARED  eventTime
	SHARED  debug
	UBYTE  temp[]
	AUTOX  rtype,  format,  items,  after,  data
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	type = 0
	data$ = ""
	DIM data[]
'
'	PRINT "XgrGetClipboard() : "; clipboard, type
'
	IFZ clipData[] THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		DIM clipType[7]
		DIM clipText$[7]
		DIM clipData[7,]
		##LOCKOUT = lockout
		##WHOMASK = whomask
'
		FOR i = 0 TO 7
			clipType[i] = $$ClipboardTypeNone				' no contents
		NEXT i
	END IF
'
	IF ((clipboard < 0) OR (clipboard > 7)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrGetClipboard() : invalid clipboard # : "; clipboard
		RETURN ($$TRUE)
	END IF
'
	return = $$FALSE
	type = clipType[clipboard]
	sdisplay = #sdisplayEternal
	swindow = #swindowEternal
'
	IFZ clipboard THEN type = type OR $$ClipboardTypeText
'
	SELECT CASE ALL TRUE
		CASE (type AND $$ClipboardTypeText)		: GOSUB Text		' ASCII text
		CASE (type AND $$ClipboardTypeImage)	: GOSUB Image		' DIB format
	END SELECT
	RETURN (return)
'
'
' *****  Text  *****
'
SUB Text
	IF clipboard THEN
'		PRINT "XgrGetClipboard() : Text.x : "; clipboard; type
		data$ = clipText$[clipboard]								' copy of clipboard text
	ELSE
'		PRINT "XgrGetClipboard() : Text.0 : "; clipboard; type
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		selectionNotify.type = $$FALSE
		XConvertSelection (sdisplay, #XA_PRIMARY, #XA_STRING, #XA_TEXT, swindow, eventTime)
		##LOCKOUT = lockout
		##WHOMASK = whomask
'
'		PRINT "XgrGetClipboard() : Text.1 : "; clipboard; type; selectionNotify.type
		DO
			XstSleep (10)															' let the server execute
			DispatchEvents ($$TRUE, $$FALSE)					' wait for EventSelectionNotify
		LOOP UNTIL selectionNotify.type							' set by EventSelectionNotify
		selectionNotify.type = $$FALSE							' ready for next time
'		PRINT "XgrGetClipboard() : Text.2 : "; clipboard; type; selectionNotify.type
'
' need to call XGetWindowProperty() twice because the idiots who designed these functions
' and events don't provide any earlier way to know how many data bytes are in the selection.
'
		IF (selectionNotify.property = #XA_TEXT) THEN
			data$ = ""
			offset = 0					' start reading at the beginning of data$
			length = 0x00100000	' length is in XLONGs, not UBYTEs, so length = 1M XLONGs = 4MB
			delete = 1					' don't delete selection yet, since we're not really reading it here
			data = 0						' initialize data
			after = 0						' initialize after
			rtype = 0						' initialize rtype
			items = 0						' initialize items
			format = 0					' initialize format
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			error = XGetWindowProperty (sdisplay, swindow, #XA_TEXT, offset, length, delete, #XA_STRING, &rtype, &format, &items, &after, &data)
			##LOCKOUT = lockout
			##WHOMASK = whomask
'			PRINT "XgrGetClipboard() : Text.3 : "; clipboard; type;; HEX$(data,8);; HEX$(&data$,8)
'			PRINT "XgrGetClipboard() : "; HEX$(sdisplay,8);; HEX$(swindow,8);; HEX$(#XA_TEXT,8);; HEX$(#XA_STRING,8);; HEX$(rtype,8);; HEX$(format,8);; HEX$(items,8);; HEX$(after,8);; HEX$(data,8);; HEX$(LEN(data$),8)
'			PRINT "sdisplay          = "; HEX$(sdisplay,8);; 				"XGetWindowProperty ( arg 1 )
'			PRINT "swindow           = "; HEX$(swindow,8);;					"XGetWindowProperty ( arg 2 )
'			PRINT "#XA_TEXT          = "; HEX$(#XA_TEXT,8);;				"XGetWindowProperty ( arg 3 )
'			PRINT "offset            = "; HEX$(offset,8);;					"XGetWindowProperty ( arg 4 )
'			PRINT "length            = "; HEX$(length,8);;					"XGetWindowProperty ( arg 5 )
'			PRINT "delete            = "; HEX$(delete,8);;					"XGetWindowProperty ( arg 6 )
'			PRINT "#XA_STRING        = "; HEX$(#XA_STRING,8);;			"XGetWindowProperty ( arg 7 )
'			PRINT "rtype             = "; HEX$(rtype,8);;						"XGetWindowProperty ( arg 8 )
'			PRINT "format            = "; HEX$(format,8);;					"XGetWindowProperty ( arg 9 )
'			PRINT "items             = "; HEX$(items,8);;						"XGetWindowProperty ( arg A )
'			PRINT "after             = "; HEX$(after,8);;						"XGetWindowProperty ( arg B )
'			PRINT "data aka &data$   = "; HEX$(data,8);;						"XGetWindowProperty ( arg C )
'			PRINT "eventTime         = "; HEX$(eventTime,8)
'			PRINT "#XA_PRIMARY       = "; HEX$(#XA_PRIMARY,8)
			IF data THEN
'				PRINT "data[-1]          = "; HEX$(XLONGAT(data,[-1]))
'				PRINT "data[-2]          = "; HEX$(XLONGAT(data,[-2]))
'				PRINT "data[-3]          = "; HEX$(XLONGAT(data,[-3]))
'				PRINT "data[-4]          = "; HEX$(XLONGAT(data,[-4]))
				XLONGAT(data,[-1]) = 0x80130001
				XLONGAT(data,[-2]) = items
'				PRINT "data[-1]          = "; HEX$(XLONGAT(data,[-1]))
'				PRINT "data[-2]          = "; HEX$(XLONGAT(data,[-2]))
'				PRINT "data[-3]          = "; HEX$(XLONGAT(data,[-3]))
'				PRINT "data[-4]          = "; HEX$(XLONGAT(data,[-4]))
				XLONGAT (&&data$) = data
'				PRINT LEN(data$)
'				PRINT "."; data$; "."
			END IF
			IF data$ THEN
				##WHOMASK = 0
				clipText$[clipboard] = data$					' set local clipboard # 0
				##WHOMASK = whomask
			ELSE
				data$ = clipText$[clipboard]					' return local clipboard # 0
			END IF
		ELSE
			data$ = clipText$[clipboard]						' return local clipboard # 0
		END IF
	END IF
'	PRINT "XgrGetClipboard() : Text.5 : "; clipboard; type; "  <"; data$; ">"
END SUB
'
'
' *****  Image  *****
'
SUB Image
	IF clipData[clipboard,] THEN
		upper = UBOUND (clipData[clipboard,])
		DIM data[upper]
		FOR i = 0 TO upper
			data[i] = clipData[clipboard,i]						' copy of clipboard image
		NEXT i
	END IF
'	PRINT "XgrGetClipboard() : Image.z : "; clipboard; type
END SUB
END FUNCTION
'
'
' #############################
' #####  XgrGetCursor ()  #####
' #############################
'
FUNCTION  XgrGetCursor (cursor)
	SHARED  activeCursor
'
	IF #trace THEN PRINT "XgrGetCursor()"
'
	cursor = activeCursor
END FUNCTION
'
'
' #####################################
' #####  XgrGetCursorOverride ()  #####
' #####################################
'
FUNCTION  XgrGetCursorOverride (cursor)
	SHARED  activeCursorOverride
'
	IF #trace THEN PRINT "XgrGetCursorOverride()"
'
	cursor = activeCursorOverride
END FUNCTION
'
'
' ##################################
' #####  XgrGetDisplaySize ()  #####
' ##################################
'
FUNCTION  XgrGetDisplaySize (display$, width, height, borderWidth, titleHeight)
	SHARED  DISPLAY  display[]
	SHARED  display$[]
'
	IF #trace THEN PRINT "XgrGetDisplaySize()"
'
	IF INSTR (#implementation$, "linux") THEN
		width = 640
		height = 480
		borderWidth = 4
		titleHeight = 18
	ELSE
		width = 640
		height = 480
		borderWidth = 8
		titleHeight = 23
	END IF
	upper = UBOUND (display$[])
'
	FOR i = 1 TO upper
'		a$ = STRING$(i) + ".a : <" + display$ + "> <" + display$[i] + "> : " + HEX$(display[i].sdisplay,8) + " " + HEX$(display[i].borderWidth,4) + " " + HEX$(display[i].titleHeight,4) + "\n"
'		write (1, &a$, LEN(a$))
		IF (display$ = display$[i]) THEN
			IF display[i].sdisplay THEN
'				a$ = STRING$(i) + ".b : <" + display$ + "> <" + display$[i] + "> : " + HEX$(display[i].sdisplay,8) + " " + HEX$(display[i].borderWidth,4) + " " + HEX$(display[i].titleHeight,4) + "\n"
'				write (1, &a$, LEN(a$))
				width = display[i].width
				height = display[i].height
				bw = display[i].borderWidth
				th = display[i].titleHeight
				IF bw THEN borderWidth = bw
				IF th THEN titleHeight = th
				EXIT FOR
			END IF
		END IF
	NEXT i
'
	IF (i > upper) THEN
		#ERROR = $$ErrorObjectDisplay OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetDisplaySize() : invalid display name"
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' #####################################
' #####  XgrGetKeystateModify ()  #####
' #####################################
'
FUNCTION  XgrGetKeystateModify (state, modify, edit)
	SHARED  UBYTE  charsetKeystateModify[]
'
	edit = 0
	modify = 0
	vkey = state >> 24
	key = state AND 0x00FF
	IFZ key THEN key = vkey
	control = state AND $$ControlBit
	contents = state{$$StateContents}
'
	SELECT CASE contents
		CASE 0		:	IF control THEN
									SELECT CASE key
										CASE $$KeyTab					: modify = key	: edit = key
										CASE $$KeyEnter				: modify = key	: edit = key
										CASE $$KeyDelete			: modify = key	: edit = key
										CASE $$KeyInsert			: modify = 0		: edit = key
										CASE $$KeyBackspace		: modify = key	: edit = key
									END SELECT
								ELSE
									SELECT CASE key
										CASE $$KeyTab					: modify = key	: edit = key
										CASE $$KeyEnter				: modify = key	: edit = key
										CASE $$KeyDelete			: modify = key	: edit = key
										CASE $$KeyInsert			: modify = key	: edit = key
										CASE $$KeyBackspace		: modify = key	: edit = key
									END SELECT
								END IF
		CASE 1		: IF control THEN
									SELECT CASE key
										CASE $$KeyControlH	: modify = key	: edit = $$KeyBackspace	' ^I = backspace
										CASE $$KeyControlI	: modify = key	: edit = $$KeyTab				' ^I = tab
										CASE $$KeyControlM	: modify = key	: edit = $$KeyEnter			' ^M = enter
										CASE $$KeyControlV	: modify = key	: edit = $$KeyInsert		' ^V = insert
										CASE $$KeyControlX	: modify = key	: edit = $$KeyDelete		' ^X = delete
									END SELECT
								ELSE
									SELECT CASE key
										CASE $$KeyTab					: modify = key	: edit = key
										CASE $$KeyEnter				: modify = key	: edit = key
										CASE $$KeyDelete			: modify = key	: edit = key
										CASE $$KeyInsert			: modify = key	: edit = key
										CASE $$KeyBackspace		: modify = key	: edit = key
										CASE ELSE							: modify = charsetKeystateModify[key]
									END SELECT
								END IF
		CASE ELSE	: modify = 0
	END SELECT
	RETURN (modify)
END FUNCTION
'
'
' ####################################
' #####  XgrIconNameToNumber ()  #####
' ####################################
'
FUNCTION  XgrIconNameToNumber (icon$, @icon)
	SHARED  lastIcon
	SHARED  sicon[]
	SHARED  icon$[]
	SHARED  icon[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrIconNameToNumber() : "; icon$
'
	icon = 0
	IFZ icon$ THEN RETURN ($$FALSE)			' default system icon
'
	IF (icon$ = "LastIcon") THEN
		icon = lastIcon
		RETURN ($$FALSE)
	END IF
'
	upper = UBOUND (icon$[])
	FOR icon = 0 TO upper
		IF (icon$ = icon$[icon]) THEN RETURN ($$FALSE)	' found icon
	NEXT icon
'
	icon = 0
	##ERROR = ($$ErrorObjectIcon << 8) OR $$ErrorNatureNonexistent
	IF debug THEN PRINT "XgrIconNameToNumber() : unregistered icon"
	RETURN ($$TRUE)
END FUNCTION
'
'
' ####################################
' #####  XgrIconNumberToName ()  #####
' ####################################
'
FUNCTION  XgrIconNumberToName (icon, @icon$)
	SHARED  sicon[]
	SHARED  icon$[]
	SHARED  icon[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrIconNumberToName() : "; icon
'
	icon$ = ""
'
	upper = UBOUND (icon$[])
	IF ((icon < 0) OR (icon > upper)) THEN
		##ERROR = ($$ErrorObjectIcon << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrIconNumberToName() : invalid icon #"
		RETURN ($$TRUE)
	END IF
'
	icon$ = icon$[icon]
END FUNCTION
'
'
' ##################################
' #####  XgrRegisterCursor ()  #####
' ##################################
'
FUNCTION  XgrRegisterCursor (filename$, @cursor)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  lastCursor
	SHARED  cursor$[]
	SHARED  cursor[]
	SHARED  debug
	AUTOX  cx, cy
	AUTOX  mx, my
	AUTOX  cur, msk
	AUTOX  cwidth, cheight
	AUTOX  mwidth, mheight
	XColor  scb, scf
'
	IF #trace THEN PRINT "XgrRegisterCursor() : "; filename$
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	cursor = 0
	IFZ filename$ THEN RETURN ($$FALSE)								' default cursor
	IF (filename$ = "default") THEN RETURN ($$FALSE)	' ditto
'
	IF (filename$ = "LastCursor") THEN
		cursor = lastCursor
		RETURN ($$FALSE)
	END IF
'
	cursor$ = filename$
	u = UBOUND (cursor$)
	FOR i = 0 TO u
		c = cursor${i}
		IF (c = '\\') THEN cursor${i} = '/'		' change "\" to "/"
	NEXT i
'
	IFZ cursor$[] THEN
		##WHOMASK = 0
		DIM cursor[15]
		DIM cursor$[15]
		##WHOMASK = whomask
	END IF
'
	slot = -1
	upper = UBOUND (cursor$[])
	FOR cursor = 1 TO upper
		IF cursor$[cursor] THEN
			IF (cursor$ = cursor$[cursor]) THEN RETURN ($$FALSE)	' registered
		ELSE
			IF (slot < 0) THEN slot = cursor
		END IF
	NEXT cursor
'
' cursor not yet registered - try to load from disk
'
	IF (slot < 0) THEN
		##WHOMASK = 0
		slot = cursor
		upper = upper + 16
		REDIM cursor[upper]
		REDIM cursor$[upper]
		##WHOMASK = whomask
	END IF
'
	FOR w = 1 TO UBOUND (window[])
		IF window[w].window THEN
			swindow = window[w].swindow
			sdisplay = window[w].sdisplay
			EXIT FOR
		END IF
	NEXT w
'
	IF ((swindow = 0) OR (sdisplay = 0)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrRegisterCursor() : some display and window must exist"
		RETURN ($$TRUE)
	END IF
'
	path$ = LCASE$(cursor$)
	SELECT CASE path$
		CASE "default"		: path$ = "arrow"
		CASE "crosshair"	: path$ = "plus"
		CASE "hourglass"	: path$ = "wait"
	END SELECT
'
	cursor = 0
	dot = RINSTR (path$, ".")												' .extent ?
	IF dot THEN path$ = LEFT$ (path$, dot-1)				' remove .extent
	back = RINSTR (path$, "/")											' imbedded path ?
	IFZ back THEN path$ = "$XBDIR/images/" + path$			' default path
	cur$ = path$ + ".cur"
	msk$ = path$ + ".msk"
'
	cur$ = XstPathString$ (@cur$)
	msk$ = XstPathString$ (@msk$)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	cerror = XReadBitmapFile (sdisplay, swindow, &cur$, &cwidth, &cheight, &cur, &cx, &cy)
	merror = XReadBitmapFile (sdisplay, swindow, &msk$, &mwidth, &mheight, &msk, &mx, &my)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF (cerror OR merror) THEN
		##ERROR = ($$ErrorObjectSystemFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrRegisterCursor() : XReadBitmapFile() failed : "; cerror; merror;; cur$;; msk$
		RETURN ($$TRUE)
	END IF
'
	IF ((cwidth != mwidth) OR (cheight != mheight)) THEN
		##ERROR = ($$ErrorObjectCursor << 8) OR $$ErrorNatureInvalidSize
		IF debug THEN PRINT "XgrRegisterCursor() : cursor and mask are not the same size"
		RETURN ($$TRUE)
	END IF
'
' set cursor background and foreground colors
'
	scb.r = 0																	' black background
	scb.g = 0
	scb.b = 0
	scf.r = 0x0000FFFF												' yellow foreground
	scf.g = 0x0000FFFF
  scf.b = 0x00000000
	scb.scolor = display[1].color[$$Black]		' black background
	scf.scolor = display[1].color[$$Yellow]		' yellow foreground
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	scursor = XCreatePixmapCursor (sdisplay, cur, msk, &scf, &scb, cx, cy)
	XFreePixmap (sdisplay, cur)
	XFreePixmap (sdisplay, msk)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ scursor THEN
		##ERROR = ($$ErrorObjectSystemFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrRegisterCursor() : XCreatePixmapCursor() failed"
		RETURN ($$TRUE)
	END IF
'
	cur$ = RCLIP$ (cur$, 4)										' remove ".cur"
	back = RINSTR (cur$, $$PathSlash$)				' find last path slash
	IF back THEN cur$ = MID$ (cur$, back+1)		' cur$ = pure cursor name
'
	cursor = slot
	cursor$[cursor] = cur$
	cursor[cursor] = scursor
	#cursorMax = cursor
	IF (cursor > lastCursor) THEN lastCursor = cursor
END FUNCTION
'
'
' ################################
' #####  XgrRegisterIcon ()  #####
' ################################
'
FUNCTION  XgrRegisterIcon (filename$, @icon)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  lastIcon
	SHARED  sicon[]
	SHARED  icon$[]
	SHARED  icon[]
	SHARED  debug
	AUTOX  x
	AUTOX  y
	AUTOX  width
	AUTOX  height
	AUTOX  sicon
'
	IF #trace THEN PRINT "XgrRegisterIcon() : "; filename$
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	icon = 0
	IFZ filename$ THEN RETURN ($$FALSE)								' default icon
	IF (filename$ = "default") THEN RETURN ($$FALSE)	' ditto
'
	IF (filename$ = "LastIcon") THEN
		icon = lastIcon
		RETURN ($$FALSE)
	END IF
'
	icon$ = filename$
	u = UBOUND (icon$)
	FOR i = 0 TO u
		c = icon${i}
		IF (c = '\\') THEN icon${i} = '/'			' change "\" to "/"
	NEXT i
'
	IFZ icon$[] THEN
		##WHOMASK = 0
		DIM icon[15]
		DIM icon$[15]
		DIM sicon[15]
		##WHOMASK = whomask
	END IF
'
	slot = -1
	upper = UBOUND (icon$[])
	FOR icon = 1 TO upper
		IF icon$[icon] THEN
			IF (icon$ = icon$[icon]) THEN RETURN ($$FALSE)	' registered
		ELSE
			IF (slot < 0) THEN slot = icon
		END IF
	NEXT icon
'
' icon not yet registered - try to load from disk
'
	IF (slot < 0) THEN
		##WHOMASK = 0
		slot = icon
		upper = upper + 16
		REDIM icon[upper]
		REDIM icon$[upper]
		REDIM sicon[upper]
		##WHOMASK = whomask
	END IF
'
	FOR w = 1 TO UBOUND (window[])
		IF window[w].window THEN
			swindow = window[w].swindow
			sdisplay = window[w].sdisplay
			EXIT FOR
		END IF
	NEXT w
'
	IF ((swindow = 0) OR (sdisplay = 0)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrRegisterIcon() : some display and window must exist"
		RETURN ($$TRUE)
	END IF
'
	path$ = LCASE$(icon$)
'
	icon = 0
	dot = RINSTR (path$, ".")												' .extent ?
	IF dot THEN path$ = LEFT$ (path$, dot-1)				' remove .extent
	back = RINSTR (path$, "/")											' imbedded path ?
	IFZ back THEN path$ = "$XBDIR/images/" + path$			' default path
	ico$ = path$ + ".ico"
'
	ico$ = XstPathString$ (@ico$)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = XReadBitmapFile (sdisplay, swindow, &ico$, &width, &height, &sicon, &x, &y)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF error THEN
		##ERROR = ($$ErrorObjectSystemFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrRegisterIcon() : XReadBitmapFile() failed : "; ico$
		RETURN ($$TRUE)
	END IF
'
	ico$ = RCLIP$ (ico$, 4)										' remove ".ico"
	back = RINSTR (ico$, $$PathSlash$)				' find last path slash
	IF back THEN ico$ = MID$ (ico$, back+1)		' ico$ = pure icon name
'
	icon = slot
	icon[icon] = icon
	icon$[icon] = ico$
	sicon[icon] = sicon
	#iconMax = icon
	IF (icon > lastIcon) THEN lastIcon = icon
END FUNCTION
'
'
' ################################
' #####  XgrSetClipboard ()  #####
' ################################
'
FUNCTION  XgrSetClipboard (clipboard, type, data$, UBYTE data[])
	SHARED  UBYTE  clipData[]
	SHARED  clipText$[]
	SHARED  clipType[]
	SHARED  eventTime
	SHARED  debug
	UBYTE  temp[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
'	PRINT "XgrSetClipboard().A : "; clipboard; type
'
	IFZ clipData[] THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		DIM clipType[7]
		DIM clipText$[7]
		DIM clipData[7,]
		##LOCKOUT = lockout
		##WHOMASK = whomask
'
		FOR i = 0 TO 7
			clipType[i] = $$ClipboardTypeNone				' no contents
		NEXT i
	END IF
'
	IF ((clipboard < 0) OR (clipboard > 7)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrSetClipboard() : invalid clipboard #"
		RETURN ($$TRUE)
	END IF
'
	return = $$FALSE
	clipType[clipboard] = $$ClipboardTypeNone			' until proven otherwise
	sdisplay = #sdisplayEternal
	swindow = #swindowEternal
'
	SELECT CASE type
		CASE $$ClipboardTypeNone		: GOSUB None
		CASE $$ClipboardTypeText		:	GOSUB Text
		CASE $$ClipboardTypeImage		:	GOSUB Image
	END SELECT
'
	clipType = 0
	IF clipText$[clipboard] THEN clipType = clipType OR $$ClipboardTypeText
	IF clipData[clipboard,] THEN clipType = clipType OR $$ClipboardTypeImage
	clipType[clipboard] = clipType
	RETURN (return)
'
'
' *****  None  *****
'
SUB None
	clipText$[clipboard] = ""
	ATTACH clipData[clipboard,] TO temp[]
END SUB
'
'
' *****  Text  *****
'
SUB Text
'	PRINT "XgrSetClipboard() : Text.A"; clipboard; type
	##WHOMASK = 0
	clipText$[clipboard] = ""												' clear text
	IF data$ THEN clipText$[clipboard] = data$
	##WHOMASK = whomask
'
' clipboard #0 is the interapplication clipboard aka the xlib PRIMARY selection
'
'
'	PRINT "XgrSetClipboard() : Text.B"; clipboard; type
	IFZ clipboard THEN
		IFZ swindow THEN EXIT SUB
		IFZ sdisplay THEN EXIT SUB
'		PRINT "XgrSetClipboard() : Text.C"; clipboard; type
		sowner = XSetSelectionOwner (sdisplay, #XA_PRIMARY, swindow, eventTime)
'		PRINT "XgrSetClipboard() : Text.D"; clipboard; type;; HEX$(sdisplay,8); #XA_PRIMARY;; HEX$(swindow,8);; HEX$(sowner,8);; eventTime
	END IF
END SUB
'
'
' *****  Image  *****
'
SUB Image
	ATTACH clipData[clipboard,] TO temp[]						' clear image
	DIM temp[]
'
	IF data[] THEN
		upper = UBOUND (data[])
		datatype = TYPE (data[])
		IF (datatype != $$UBYTE) THEN
			##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidType
			IF debug THEN PRINT "XgrSetClipboard() : invalid image array type : data[] must be UBYTE"
			return = $$TRUE
			EXIT SUB
		END IF
'
		addr = &data[]
		b = UBYTEAT (addr, 0)
		m = UBYTEAT (addr, 1)
		IF ((b != 'B') OR (m != 'M')) THEN
			##ERROR = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidSignature
			IF debug THEN PRINT "XgrSetClipboard() : invalid image array signature : not BM"
			return = $$TRUE
			EXIT SUB
		END IF
'
		##WHOMASK = 0
		DIM temp[upper]
		##WHOMASK = whomask
'
		FOR i = 0 TO upper
			temp[i] = data[i]														' copy image data
		NEXT i
		ATTACH temp[] TO clipData[clipboard,]					' save image data
	END IF
'
' clipboard #0 is the interapplication clipboard aka the xlib PRIMARY selection
'
	IFZ clipboard THEN
		owner = XSetSelectionOwner (sdisplay, #XA_PRIMARY, swindow, eventTime)
'		PRINT "XgrSetClipboard(0) : "; HEX$(sdisplay,8);; HEX$(swindow,8);; HEX$(owner,8)
	END IF
END SUB
END FUNCTION
'
'
' #############################
' #####  XgrSetCursor ()  #####
' #############################
'
FUNCTION  XgrSetCursor (cursor, oldCursor)
	SHARED  WINDOW  window[]
	SHARED  activeCursorOverride
	SHARED  activeCursor
	SHARED  cursor$[]
	SHARED  cursor[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrSetCursor() : "; cursor
'
	oldCursor = activeCursor
	IF (cursor = activeCursor) THEN RETURN ($$FALSE)		' no change
'
	IF InvalidCursor (cursor) THEN
		##ERROR = ($$ErrorObjectCursor << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetCursor() : invalid cursor #"
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	activeCursor = cursor
	scursor = cursor[cursor]
	IF activeCursorOverride THEN RETURN ($$FALSE)				' no change now
'
	upper = UBOUND (window[])
	FOR w = 1 TO upper
		IF window[w].window THEN
			IF (w = window[w].top) THEN
				IF window[w].swindow THEN
					IFZ window[w].destroy THEN
						IFZ window[w].destroyed THEN
							IFZ window[w].destroyProcessed
								swindow = window[w].swindow
								sdisplay = window[w].sdisplay
								##WHOMASK = 0
								##LOCKOUT = $$TRUE
								XDefineCursor (sdisplay, swindow, scursor)
								##LOCKOUT = lockout
								##WHOMASK = whomask
							END IF
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT w
END FUNCTION
'
'
' #####################################
' #####  XgrSetCursorOverride ()  #####
' #####################################
'
FUNCTION  XgrSetCursorOverride (cursor, @oldCursorOverride)
	SHARED  WINDOW  window[]
	SHARED  activeCursorOverride
	SHARED  activeCursor
	SHARED  cursor$[]
	SHARED  cursor[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrSetCursorOverride() : "; cursor
'
	oldCursorOverride = activeCursorOverride
	IF (cursor = activeCursorOverride) THEN RETURN ($$FALSE)	' no change
'
	IF InvalidCursor (cursor) THEN
		##ERROR = ($$ErrorObjectCursor << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetCursor() : invalid cursor #"
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	scursor = cursor[cursor]
	activeCursorOverride = cursor
	IFZ cursor THEN scursor = cursor[activeCursor]
'
	upper = UBOUND (window[])
	FOR w = 1 TO upper
		IF window[w].window THEN
			IF (w = window[w].top) THEN
				swindow = window[w].swindow
				sdisplay = window[w].sdisplay
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				XDefineCursor (sdisplay, swindow, scursor)
				##LOCKOUT = lockout
				##WHOMASK = whomask
			END IF
		END IF
	NEXT w
END FUNCTION
'
'
' ############################
' #####  XgrSetDebug ()  #####  set debug variable
' ############################
'
FUNCTION  XgrSetDebug (arg)
	SHARED  debug
'
	debug = arg
END FUNCTION
'
'
' #####################################
' #####  XgrSystemWindowToWindow  #####
' #####################################
'
FUNCTION  XgrSystemWindowToWindow (swindow, window, top)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrSystemWindowToWindow() : "; swindow
'
	window = 0
	IFZ window[] THEN
		IF debug THEN
			PRINT "XgrSystemWindowToWindow() : Error : window[] is empty"
		END IF
		RETURN ($$TRUE)
	END IF
'
	FOR w = 1 TO UBOUND (window[])
		IF window[w].window THEN
			IF (window[w].swindow = swindow) THEN
				top = window[w].top
				window = w
				EXIT FOR
			END IF
		END IF
	NEXT w
'
' if a grid or its window is being destroyed, return non-zero
'
	trash = $$FALSE
	trash = trash OR window[top].destroy
	trash = trash OR window[top].destroyed
	trash = trash OR window[top].destroyProcessed
	trash = trash OR window[window].destroy
	trash = trash OR window[window].destroyed
	trash = trash OR window[window].destroyProcessed
	RETURN (trash)
END FUNCTION
'
'
' ########################################
' #####  XgrWindowToSystemWindow ()  #####
' ########################################
'
FUNCTION  XgrWindowToSystemWindow (window, swindow)
	SHARED  WINDOW  window[]
'
	IF #trace THEN PRINT "XgrWindowToSystemWindow() : "; window
'
	swindow = 0
	IF (window <= 0) THEN RETURN
	IF (window > UBOUND (window[])) THEN RETURN
	IFZ window[window].window THEN RETURN
	swindow = window[window].swindow
END FUNCTION
'
'
' ############################
' #####  XgrVersion$ ()  #####
' ############################
'
FUNCTION  XgrVersion$ ()
'
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' ##############################
' #####  XgrCreateFont ()  #####
' ##############################
'
' An X-Window font name is a string with 14 fields separated by "-"
'
' "-f-t-w-s-w-?-p-t-h-v-s-a-c-#"
'   | | | | | | | | | | | | | |
'   foundry - Adobe, Bitstream, etc
'     typeface - courier, helvetica, etc
'       weight - thin, normal, medium, demibold, bold, heavy, etc
'         slant - roman (normal), italic, oblique, ri (reverse italic), ro (reverse oblique), ot (other)
'           width - normal, condensed, semicondensed, narrow, doublewidth
'             ? - style ??? (informal, roman, serif, sansserif) ???
'               pixels -
'                 tenpoints - 10 * point size (point = 1/72 inch)
'                   hdpi - horizontal resolution in dots per inch
'                     vdpi - vertical resolution in dots per inch
'                       spacing - m = monospace : p = proportional : c = character cell
'                         average width in 1/10 pixels
'                           character set ("iso8859-1")
'                             character set number
'
FUNCTION  XgrCreateFont (@font, font$, size, weight, italic, angle)
	SHARED  FONT  font[]
	SHARED	font$[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrCreateFont() : "; font, font$, size, weight, italic, angle
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	font = 0
	IFZ font$ THEN RETURN ($$FALSE)
	typeface$ = TRIM$(LCASE$(font$))
	source$ = "*"
'
	SELECT CASE typeface$
		CASE "default"	: RETURN ($$FALSE)
		CASE "fixed"		: RETURN ($$FALSE)
		CASE "serif"		: source$ = "adobe"			: typeface$ = "utopia"
		CASE "sanserif"	: source$ = "adobe"			: typeface$ = "helvetica"
		CASE "courier"	: source$ = "bitstream"	: typeface$ = "courier"
		CASE "roman"		: source$ = "adobe"			: typeface$ = "utopia"
		CASE "fancy"		:	source$ = "bitstream"	: typeface$ = "charter"
	END SELECT
'
	source$ = "*"			' the sources above can cause problems and are not required
'
' generate X-Windows size name from size argument
'
'	size = size >> 1				' convert 1/20 points into 1/10 points
'
	SELECT CASE TRUE
		CASE (size <= 0)			: size$ = "*"
		CASE (size > 0)				: size$ = STRING$ (size >> 1)
	END SELECT
'
' generate X-Windows weight name from weight argument
'
	SELECT CASE TRUE
		CASE (weight <= 0)		: weight$ = "*"
		CASE (weight <= 700)	: weight$ = "medium"
		CASE ELSE							: weight$ = "bold"
	END SELECT
'
' generate X-Windows italic name from italic argument
'
	SELECT CASE TRUE
		CASE (italic < 0)			: italic$ = "i"			' was "*"
		CASE (italic = 0)			: italic$ = "r"
		CASE (italic > 0)			: italic$ = "i"
	END SELECT
'
' If font name is fully hyphenated X-Windows font name then base
' the font name on that, but insert size, bold, and italic fields.
' Otherwise generate an X-Windows font name from font name argument.
'
	DIM hyphen[15]
	DIM name$[15]
	offset = 0
	prior = 0
	entry = 0
	DO WHILE (entry <= 15)
		hyphen = INSTR (font$, "-", offset)
		IF hyphen THEN
			hyphen[entry] = hyphen
			offset = hyphen + 1
			IF entry THEN
'				PRINT font$, prior+1, hyphen-prior-1, LEN (font$)
'				PRINT SPACE$(prior) + "|" + CHR$('-', hyphen-prior-1)
				name$[entry] = MID$ (font$, prior+1, hyphen-prior-1)
			END IF
			INC entry
		END IF
		prior = hyphen
	LOOP WHILE hyphen
'
' 14 hyphens means valid X-Windows font name
'
	IF (entry = 14) THEN
		name$[14] = MID$ (font$, offset)			' field after last "-"
		FOR i = 0 TO 15
			IFZ name$[i] THEN name$[i] = "*"		' empty name to "*" wildcard
		NEXT i
	ELSE
		FOR i = 0 TO 15
			name$[i] = "*"											' not an X-Windows font name
		NEXT i
	END IF
'
	IF (entry >= 14) THEN typeface$ = "*"
'
	IF (name$[ 1] = "*") THEN name$[ 1] = source$
	IF (name$[ 2] = "*") THEN name$[ 2] = typeface$
	IF (name$[ 3] = "*") THEN name$[ 3] = weight$
	IF (name$[ 4] = "*") THEN name$[ 4] = italic$
	IF (name$[ 6] = "0") THEN name$[ 6] = "*"
	IF (name$[ 7] = "0") THEN name$[ 7] = "*"
	IF (name$[ 8] = "*") THEN name$[ 8] = size$
	IF (name$[ 8] = "0") THEN name$[ 8] = size$
	IF (name$[ 9] = "*") THEN name$[ 9] = "75"
	IF (name$[ 9] = "0") THEN name$[ 9] = "75"
	IF (name$[10] = "*") THEN name$[10] = "75"
	IF (name$[10] = "0") THEN name$[10] = "75"
	IF (name$[12] = "0") THEN name$[12] = "*"
'
'	XstLog ("XgrCreateFont().X : " + font$ + " " + STRING$(font) + " " + STRING$(size) + " " + STRING$(weight) + " " + STRING$(italic) + " " + STRING$(angle))
'
	filter$ = "-" + name$[1] + "-" + name$[2] + "-" + name$[3] + "-" + name$[4] + "-" + name$[5] + "-" + name$[6] + "-" + name$[7] + "-" + name$[8] + "-" + name$[9] + "-" + name$[10] + "-" + name$[11] + "-" + name$[12] + "-" + name$[13] + "-" + name$[14]
	IFZ (size OR weight OR italic OR angle) THEN filter$ = font$
'
'	XstLog ("XgrCreateFont().Y : " + filter$)
'
'	PRINT "XgrCreateFont() : "; filter$
'
	display = 1
	Font (@font, $$Create, display, @sfont, @addrFont, size, weight, italic, angle, @filter$)
'
	##WHOMASK = $$FALSE
	upper = UBOUND (font$[])
	IF (font > upper) THEN
		upper = font OR 0x0007
		REDIM font$[upper]
	END IF
	IF font THEN font$[font] = font$
	##WHOMASK = whomask
'
'	XstLog ("XgrCreateFont().Z : " + font$ + " " + STRING$(font) + " " + STRING$(size) + " " + STRING$(weight) + " " + STRING$(italic) + " " + STRING$(angle) + " " + HEX$(sfont,8) + " " + HEX$(addrFont,8))
'	PRINT font$; font;; HEX$(sfont);; HEX$(addrFont);; filter$
END FUNCTION
'
'
' ###############################
' #####  XgrDestroyFont ()  #####
' ###############################
'
FUNCTION  XgrDestroyFont (font)
'	PRINT "XgrDestroyFont() : unimpemented"
END FUNCTION
'
'
' ###############################
' #####  XgrGetFontInfo ()  #####
' ###############################
'
FUNCTION  XgrGetFontInfo (font, @font$, @size, @weight, @italic, @angle)
	SHARED  FONT  font[]
	SHARED  font$[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrGetFontInfo() : "; font
'
	IF InvalidFont (font) THEN
		##ERROR = ($$ErrorObjectFont << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetFontInfo() : invalid font #"
		RETURN ($$TRUE)
	END IF
'
	font$ = font$[font]
	size = font[font].size
	weight = font[font].weight
	italic = font[font].italic
	angle = font[font].angle
END FUNCTION
'
'
' ##################################
' #####  XgrGetFontMetrics ()  #####
' ##################################
'
FUNCTION  XgrGetFontMetrics (font, @maxCharWidth, @maxCharHeight, @ascent, @descent, @gap, @space)
	SHARED  FONT  font[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrGetFontMetrics() : "; font
'
	gap = 0
	space = 0
	ascent = 0
	descent = 0
	maxCharWidth = 0
	maxCharHeight = 0
'
	IF InvalidFont (font) THEN
		##ERROR = ($$ErrorObjectFont << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetFontMetrics() : invalid font #"
		RETURN ($$TRUE)
	END IF
'
	gap = font[font].gap
	space = font[font].space
	ascent = font[font].ascent
	descent = font[font].descent
	maxCharWidth = font[font].width
	maxCharHeight = font[font].height
END FUNCTION
'
'
' ################################
' #####  XgrGetFontNames ()  #####
' ################################
'
' An X-Window font name is a string with 14 fields separated by "-"
'
' "-f-t-w-s-w-?-p-t-h-v-s-a-c-#"
'   | | | | | | | | | | | | | |
'   foundry - Adobe, Bitstream, etc
'     typeface - courier, helvetica, etc
'       weight - thin, normal, medium, demibold, bold, heavy, etc
'         slant - roman (normal), italic, oblique, ri (reverse italic), ro (reverse oblique), ot (other)
'           width - normal, condensed, semicondensed, narrow, doublewidth
'             ? - style ??? (informal, roman, serif, sansserif) ???
'               pixels -
'                 tenpoints - 10 * point size (point = 1/72 inch)
'                   hdpi - horizontal resolution in dots per inch
'                     vdpi - vertical resolution in dots per inch
'                       spacing - m = monospace : p = proportional : c = character cell
'                         average width in 1/10 pixels
'                           character set ("iso8859")
'                             character set extension # ("1")
FUNCTION  XgrGetFontNames (@count, @fontName$[])
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	STATIC  entry
	AUTOX  fonts
'
	IFZ entry THEN
		entry = $$TRUE
		DefaultFontNames (@c, @f$[])
		IF f$[] THEN
			file$ = "$XBDIR" + $$PathSlash$ + "templates" + $$PathSlash$ + "fonts.xxx"
			XstSaveStringArray (@file$, @f$[])
			DIM f$[]
		END IF
	END IF
'
	IF #trace THEN PRINT "XgrGetFontNames()"
'
	count = 0
	DIM fontName$[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	sdisplay = display[1].sdisplay			' default display
	filter$ = "-*-*-*-*-*-*-0-0-*-*-*-0-*-*"
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	addrFontList = XListFonts (sdisplay, &filter$, 4096, &fonts)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
'
	IFZ fonts THEN RETURN ($$FALSE)						' no fonts
	IFZ addrFontList THEN RETURN ($$FALSE)		' no fonts
'
	f = 0
	count = 0
	upper = fonts
	addr = addrFontList
	DIM fontName$[upper]
	DIM field$[15]
	INC count
'
	DO
		INC f
		font = XLONGAT (addr)						' font = address of font name
		font$ = CSTRING$ (font)					' font$ = font name
		addr = addr + 4									' addr = address of next font name
		IF font$ THEN
			offset = 1
'			a$ = font$ + "\n"
'			write (1, &a$, LEN(a$))
			IF (font${0} = '-') THEN
				FOR i = 1 TO 14
					next = INSTR (font$, "-", offset+1)
					field$[i] = MID$ (font$, offset+1, next-offset-1)
					offset = next
				NEXT i
				IF (field$[7] = "0") THEN
					IF (field$[8] = "0") THEN
						IF (field$[11] != "c") THEN
							IF (field$[12] = "0") THEN
								fontName$ = field$[2]
								FOR i = 1 TO count
									IF (fontName$ = fontName$[i]) THEN DO LOOP
								NEXT i
'								a$ = field$[2] + "\n" + font$ + "\n"
'								write (1, &a$, LEN(a$))
								fontName$[count] = fontName$
								INC count
							END IF
						END IF
					END IF
				END IF
			END IF
		END IF
	LOOP UNTIL (f >= fonts)
'
	top = count - 1
	IF (top != upper) THEN REDIM fontName$[top]
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XFreeFontNames (addrFontList)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
END FUNCTION
'
'
' #########################################
' #####  XgrGetTextArrayImageSize ()  #####
' #########################################
'
FUNCTION  XgrGetTextArrayImageSize (font, text$[], w, h, width, height, extraX, extraY)
	SHARED  debug
'
	IF #trace THEN PRINT "XgrGetTextArrayImageSize() : "; font
'
	IF InvalidFont (font) THEN
		##ERROR = ($$ErrorObjectFont << 8) OR $$ErrorNatureInvalidNumber
		IF debug THEN PRINT "XgrGetTextArrayImageSize() : invalid font #"; font
		RETURN ($$TRUE)
	END IF
'
	empty = $$FALSE
	IFZ text$[] THEN GOSUB Empty
'
	found = $$FALSE
	upper = UBOUND (text$[])
	FOR i = upper TO 0 STEP -1
		IF text$[i] THEN
			found = $$TRUE
			final = i
			EXIT FOR
		END IF
	NEXT i
'
	IFZ found THEN GOSUB Empty
'
	IF (final < upper) THEN
		REDIM text$[final]
		upper = final
	END IF
'
	XgrGetFontInfo (font, @name$, @size, @weight, @italic, @angle)
	XgrGetTextImageSize (font, @"W", 0, 0, @ww, @hh, @gg, @ss)
	ww = ww + extraX
	hh = hh + extraY
'
	width = 0
	height = 0
	FOR i = 0 TO upper
		IFZ text$[i] THEN
			width = MAX (width, ww)
			height = height + hh
		ELSE
			text$ = text$[i]
			XgrGetTextImageSize (font, @text$, 0, 0, @w, @h, @g, @s)
			w = w + extraX : h = h + extraY
			width = MAX (width, w)
			height = height + h
		END IF
	NEXT i
'
	w = width
	h = height
	IFZ angle THEN
		IF empty THEN DIM text$[]
		RETURN
	END IF
'
' Now take angle into account
'
	w# = width >> 1									' w# = 1/2 width
	h# = height >> 1								' h# = 1/2 height
	r# = SQRT (w#*w# + h#*h#)				' r# = radius of text box
	a# = angle * .1# * $$DEGTORAD		' a# = tilt angle in radians
	na# = ASIN (h# / r#)						' na# = natural angle to corner
	ax = r# * COS (a# - na# + $$PI)	' final x coord of upper-left corner
	ay = r# * SIN (a# - na# + $$PI)	' final y coord of upper-left corner
	bx = r# * COS (a# + na#)				' final x coord of upper-right corner
	by = r# * SIN (a# + na#)				' final y coord of upper-right corner
	cx = r# * COS (a# + na# + $$PI)	' final x coord of lower-left corner
	cy = r# * SIN (a# + na# + $$PI)	' final y coord of lower-left corner
	dx = r# * COS (a# - na#)				' final x coord of lower-right corner
	dy = r# * SIN (a# - na#)				' final y coord of lower-right corner
'
' Find highest and lowest x and y values
'
	minX = +r#
	minY = +r#
	maxX = -r#
	maxY = -r#
'
	IF (ax < minX) THEN minX = ax
	IF (bx < minX) THEN minX = bx
	IF (cx < minX) THEN minX = cx
	IF (dx < minX) THEN minX = dx
	IF (ax > maxX) THEN maxX = ax
	IF (bx > maxX) THEN maxX = bx
	IF (cx > maxX) THEN maxX = cx
	IF (dx > maxX) THEN maxX = dx
	IF (ay < minY) THEN minY = ay
	IF (by < minY) THEN minY = by
	IF (cy < minY) THEN minY = cy
	IF (dy < minY) THEN minY = dy
	IF (ay > maxY) THEN maxY = ay
	IF (by > maxY) THEN maxY = by
	IF (cy > maxY) THEN maxY = cy
	IF (dy > maxY) THEN maxY = dy
'
	width = maxX - minX + 1
	height = maxY - minY + 1
	IF empty THEN DIM text$[]
	RETURN ($$FALSE)
'
'
' *****  Empty  *****
'
SUB Empty
	empty = $$TRUE
	DIM text$[0]
	text$[0] = "W"
END SUB
END FUNCTION
'
'
' ####################################
' #####  XgrGetTextImageSize ()  #####
' ####################################
'
FUNCTION  XgrGetTextImageSize (font, text$, @dx, @dy, @width, @height, @gap, @space)
	SHARED  FONT  font[]
	SHARED  XFontStruct  fontStruct[]
	AUTOX  direction,  ascent,  descent
	XFontStruct  fontStruct
	XCharStruct  info
'
	IF #trace THEN PRINT "XgrGetTextImageSize() : "; font, text$
'
	IF InvalidFont (font) THEN
		##ERROR = ($$ErrorObjectFont << 8) OR $$ErrorNatureInvalidNumber
		IF debug THEN PRINT "XgrGetTextImageSize() : invalid font #"; font
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	length = LEN (text$)
	addrFont = font[font].addrFont
	XLONGAT (&&fontStruct) = addrFont
	height = font[font].height
	flags = 0
	space = 0
	gap = 0
	dy = 0
	dx = 0
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XTextExtents (addrFont, &text$, length, &direction, &ascent, &descent, &info)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	width = info.width
	dx = width
'	PRINT "XgrGetTextImageSize() : text$, length, direction, ascent, descent, dx, dy, width, height"
'	PRINT text$; length; direction; ascent; descent; dx; dy; width; height
END FUNCTION
'
'
' #####################################
' #####  XgrConvertColorToRGB ()  #####
' #####################################
'
FUNCTION  XgrConvertColorToRGB (color, red, green, blue)
	SHARED  r[]
	SHARED  g[]
	SHARED  b[]
	SHARED  rgb[]
	SHARED  debug
'
	IF (color < 0) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrConvertColorToRGB() : invalid color # "; color
		RETURN ($$TRUE)
	END IF
'
	IF (color > 124) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrConvertColorToRGB() : invalid color # "; color
		RETURN ($$TRUE)
	END IF
'
	IF (color AND 0x000000FF) THEN
		rgb = rgb[color]
		red = ((rgb >> 24) AND 0x00FF) << 8
		green = ((rgb >> 16) AND 0x00FF) << 8
		blue = ((rgb >> 8) AND 0x00FF) << 8
	ELSE
		rgb = color
		red = ((rgb >> 24) AND 0x00FF) << 8
		green = ((rgb >> 16) AND 0x00FF) << 8
		blue = ((rgb >> 8) AND 0x00FF) << 8
	END IF
END FUNCTION
'
'
' #####################################
' #####  XgrConvertRGBToColor ()  #####
' #####################################
'
FUNCTION  XgrConvertRGBToColor (red, green, blue, color)
	SHARED  r[]
	SHARED  g[]
	SHARED  b[]
	SHARED  rgb[]
'
' get halfway intensities
'
	r1 = (r[0] + r[1]) >> 1
	r2 = (r[1] + r[2]) >> 1
	r3 = (r[2] + r[3]) >> 1
	r4 = (r[3] + r[4]) >> 1
'
	g1 = (g[0] + g[1]) >> 1
	g2 = (g[1] + g[2]) >> 1
	g3 = (g[2] + g[3]) >> 1
	g4 = (g[3] + g[4]) >> 1
'
	b1 = (b[0] + b[1]) >> 1
	b2 = (b[1] + b[2]) >> 1
	b3 = (b[2] + b[3]) >> 1
	b4 = (b[3] + b[4]) >> 1
'
' find closest r, g, b
'
	SELECT CASE TRUE
		CASE (red < r1)		: r = 0
		CASE (red < r2)		: r = 1
		CASE (red < r3)		: r = 2
		CASE (red < r4)		: r = 3
		CASE ELSE					: r = 4
	END SELECT
'
	SELECT CASE TRUE
		CASE (green < g1)	: g = 0
		CASE (green < g2)	: g = 1
		CASE (green < g3)	: g = 2
		CASE (green < g4)	: g = 3
		CASE ELSE					: g = 4
	END SELECT
'
	SELECT CASE TRUE
		CASE (blue < b1)	: b = 0
		CASE (blue < b2)	: b = 1
		CASE (blue < b3)	: b = 2
		CASE (blue < b4)	: b = 3
		CASE ELSE					: b = 4
	END SELECT
'
	c = r * 25 + g * 5 + b
	rr = (red >> 8) AND 0x00FF
	gg = (green >> 8) AND 0x00FF
	bb = (blue >> 8) AND 0x00FF
	color = (rr << 24) + (gg << 16) + (bb << 8) + c
END FUNCTION
'
'
' #######################################
' #####  XgrGetBackgroundColor  ()  #####
' #######################################
'
FUNCTION  XgrGetBackgroundColor (window, color)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetBackgroundColor() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	color = window[window].backgroundColor
END FUNCTION
'
'
' ####################################
' #####  XgrGetBackgroundRGB ()  #####
' ####################################
'
FUNCTION  XgrGetBackgroundRGB (window, red, green, blue)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetBackgroundRGB() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	red = window[window].backRed
	green = window[window].backGreen
	blue = window[window].backBlue
END FUNCTION
'
'
' ####################################
' #####  XgrGetDefaultColors ()  #####
' ####################################
'
FUNCTION  XgrGetDefaultColors (back, draw, low, high, dull, acc, lowtext, hightext)
'
	back = #defaultBackground
	draw = #defaultDrawing
	low = #defaultLowlight
	high = #defaultHighlight
	dull = #defaultDull
	acc = #defaultAccent
	lowtext = #defaultLowtext
	hightext = #defaultHightext
END FUNCTION
'
'
' ###################################
' #####  XgrGetDrawingColor ()  #####
' ###################################
'
FUNCTION  XgrGetDrawingColor (window, color)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetDrawingColor() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	color = window[window].drawingColor
END FUNCTION
'
'
' #################################
' #####  XgrGetDrawingRGB ()  #####
' #################################
'
FUNCTION  XgrGetDrawingRGB (window, red, green, blue)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetDrawingRGB() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	red = window[window].drawRed
	green = window[window].drawGreen
	blue = window[window].drawBlue
END FUNCTION
'
'
' #################################
' #####  XgrGetGridColors ()  #####
' #################################
'
FUNCTION  XgrGetGridColors (grid, @back, @draw, @low, @high, @dull, @acc, @lowtext, @hightext)
	SHARED  WINDOW  window[]
	SHARED  debug
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridColors() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	back = window[window].backgroundColor
	draw = window[window].drawingColor
	low = window[window].lowlightColor
	high = window[window].highlightColor
	dull = window[window].dullColor
	acc = window[window].accentColor
	lowtext = window[window].lowtextColor
	hightext = window[window].hightextColor
END FUNCTION
'
'
' ######################################
' #####  XgrSetBackgroundColor ()  #####
' ######################################
'
FUNCTION  XgrSetBackgroundColor (grid, color)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  rgb[]
	SHARED  debug
	AUTOX  XColor  sc
'
	IF #trace THEN PRINT "XgrSetBackgroundColors() : "; grid, color
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetBackgroundColor() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IF (color = -1) THEN RETURN ($$FALSE)				' no change
'
	window = grid
	gc = window[window].gc
	display = window[window].display
	sdisplay = window[window].sdisplay
	colormap = display[display].colormap
	sbackground = window[window].sbackground
	sbackgroundDefault = window[window].sbackgroundDefault
'
' color = 0 means standard color # 0 = $$Black
'
	IFZ color THEN
		window[window].backRed = 0
		window[window].backGreen = 0
		window[window].backBlue = 0
		window[window].backColor = 0
		window[window].backgroundColor = 0
		scolor = display[display].color[0]
		window[window].sbackground = scolor
		window[window].sbackgroundDefault = scolor
'
		IF (scolor != sbackground) THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XSetBackground (sdisplay, gc, scolor)
			##LOCKOUT = lockout
			##WHOMASK = whomask
		END IF
		RETURN ($$FALSE)
	END IF
'
' standard color # != 0 means color is standard color #
'
	c = color AND 0x000000FF
	IF (c > 124) THEN c = 124
'
	IF c THEN
		rgb = rgb[c]
		window[window].backColor = c
		window[window].backRed = (rgb AND 0xFF000000) >> 16
		window[window].backGreen = (rgb AND 0x00FF0000) >> 8
		window[window].backBlue = (rgb AND 0x0000FF00)
		window[window].backgroundColor = c
		scolor = display[display].color[c]
		window[window].sbackground = scolor
		window[window].sbackgroundDefault = scolor
'
		IF (scolor != sbackground) THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XSetBackground (sdisplay, gc, scolor)
			##LOCKOUT = lockout
			##WHOMASK = whomask
		END IF
		RETURN ($$FALSE)
	END IF
'
' color is in rgb field of rgbc color argument
'
	red = (color AND 0xFF000000) >> 16
	green = (color AND 0x00FF0000) >> 8
	blue = (color AND 0x0000FF00)
'
	r = red >> 8
	g = green >> 8
	b = blue >> 8
	c = 0
'
	window[window].backRed = red
	window[window].backGreen = green
	window[window].backBlue = blue
	window[window].backColor = 0
	window[window].backgroundColor = (r << 24) + (g << 16) + (b << 8) + c
'
	sc.scolor = 0
	sc.r = red
	sc.g = green
	sc.b = blue
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = XAllocColor (sdisplay, colormap, &sc)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	scolor = sc.scolor
	window[window].sbackground = scolor
	window[window].sbackgroundDefault = scolor
	IFZ okay THEN PRINT "XgrSetBackgroundColor() : XAllocColor() failed : "; window, color, scolor, sbackground, sbackgroundDefault
'
	IF (scolor != sbackground) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetBackground (sdisplay, gc, scolor)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ####################################
' #####  XgrSetBackgroundRGB ()  #####
' ####################################
'
FUNCTION  XgrSetBackgroundRGB (grid, red, green, blue)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
	AUTOX  XColor  sc
'
	IF #trace THEN PRINT "XgrSetBackgroundRGB() : "; grid, red, green, blue
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetBackgroundRGB() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	window = grid
	gc = window[window].gc
	display = window[window].display
	sdisplay = window[window].sdisplay
	colormap = display[display].colormap
	sbackground = window[window].sbackground
	sbackgroundDefault = window[window].sbackgroundDefault
'
' color = 0 means standard color # 0 = $$Black
'
	IFZ (red OR green OR blue) THEN
		window[window].backRed = 0
		window[window].backGreen = 0
		window[window].backBlue = 0
		window[window].backColor = 0
		window[window].backgroundColor = 0
		scolor = display[display].color[0]
		window[window].sbackground = scolor
		window[window].sbackgroundDefault = scolor
'
		IF (scolor != sbackground) THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XSetBackground (sdisplay, gc, scolor)
			##LOCKOUT = lockout
			##WHOMASK = whomask
		END IF
		RETURN ($$FALSE)
	END IF
'
' allocate rgb color
'
	red = red AND 0x0000FFFF
	green = green AND 0x0000FFFF
	blue = blue AND 0x0000FFFF
	r = red >> 8
	g = green >> 8
	b = blue >> 8
	c = 0
'
	window[window].backRed = red
	window[window].backGreen = green
	window[window].backBlue = blue
	window[window].backColor = 0
	window[window].backgroundColor = (r << 24) + (g << 16) + (b << 8) + c
'
	sc.scolor = 0
	sc.r = red
	sc.g = green
	sc.b = blue
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = XAllocColor (sdisplay, colormap, &sc)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	scolor = sc.scolor
	window[window].sbackground = scolor
	window[window].sbackgroundDefault = scolor
	IFZ okay THEN PRINT "XgrSetBackgroundRGB() : XAllocColor() failed : "; window, color, scolor, sbackground, sbackgroundDefault
'
	IF (scolor != sbackground) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetBackground (sdisplay, gc, scolor)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ####################################
' #####  XgrSetDefaultColors ()  #####
' ####################################
'
FUNCTION  XgrSetDefaultColors (back, draw, low, high, dull, acc, lowtext, hightext)
'
	IF (back != -1) THEN #defaultBackground = back
	IF (draw != -1) THEN #defaultDrawing = draw
	IF (low != -1) THEN #defaultLowlight = low
	IF (high != -1) THEN #defaultHighlight = high
	IF (dull != -1) THEN #defaultDull = dull
	IF (acc != -1) THEN #defaultAccent = acc
	IF (lowtext != -1) THEN #defaultLowtext = lowtext
	IF (hightext != -1) THEN #defaultHightext = hightext
END FUNCTION
'
'
' ###################################
' #####  XgrSetDrawingColor ()  #####
' ###################################
'
FUNCTION  XgrSetDrawingColor (grid, color)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  rgb[]
	SHARED  debug
	AUTOX  XColor  sc
'
	IF #trace THEN PRINT "XgrSetDrawingColor() : "; grid, color
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetDrawingColor() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	window = grid
	gc = window[window].gc
	display = window[window].display
	sdisplay = window[window].sdisplay
	colormap = display[display].colormap
	sforeground = window[window].sforeground
	sforegroundDefault = window[window].sforegroundDefault
'
' color = 0 means standard color # 0 = $$Black
'
	IFZ color THEN
		window[window].drawRed = 0
		window[window].drawGreen = 0
		window[window].drawBlue = 0
		window[window].drawColor = 0
		window[window].drawingColor = 0
		scolor = display[display].color[0]
		window[window].sforeground = scolor
		window[window].sforegroundDefault = scolor
'
		IF (scolor != sforeground) THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XSetForeground (sdisplay, gc, scolor)
			##LOCKOUT = lockout
			##WHOMASK = whomask
		END IF
		RETURN ($$FALSE)
	END IF
'
' standard color # != 0 means color is standard color #
'
	c = color AND 0x000000FF
	IF (c > 124) THEN c = 124
'
	IF c THEN
		rgb = rgb[c]
		window[window].drawColor = c
		window[window].drawRed = (rgb AND 0xFF000000) >> 16
		window[window].drawGreen = (rgb AND 0x00FF0000) >> 8
		window[window].drawBlue = (rgb AND 0x0000FF00)
		window[window].drawingColor = c
		scolor = display[display].color[c]
		window[window].sforeground = scolor
		window[window].sforegroundDefault = scolor
'
		IF (scolor != sforeground) THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XSetForeground (sdisplay, gc, scolor)
			##LOCKOUT = lockout
			##WHOMASK = whomask
		END IF
		RETURN ($$FALSE)
	END IF
'
' color is in rgb field of rgbc color argument
'
	red = (color AND 0xFF000000) >> 16
	green = (color AND 0x00FF0000) >> 8
	blue = (color AND 0x0000FF00)
'
	r = red >> 8
	g = green >> 8
	b = blue >> 8
	c = 0
'
	window[window].drawRed = red
	window[window].drawGreen = green
	window[window].drawBlue = blue
	window[window].drawColor = 0
	window[window].drawingColor = (r << 24) + (g << 16) + (b << 8) + c
'
	sc.scolor = 0
	sc.r = red
	sc.g = green
	sc.b = blue
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = XAllocColor (sdisplay, colormap, &sc)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	scolor = sc.scolor
	window[window].sforeground = scolor
	window[window].sforegroundDefault = scolor
	IFZ okay THEN PRINT "XgrSetDrawingColor() : XAllocColor() failed : "; window, color, scolor, sforeground, sforegroundDefault
'
	IF (scolor != sforeground) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetForeground (sdisplay, gc, scolor)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' #################################
' #####  XgrSetDrawingRGB ()  #####
' #################################
'
FUNCTION  XgrSetDrawingRGB (grid, red, green, blue)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
	AUTOX  XColor  sc
'
	IF #trace THEN PRINT "XgrSetDrawingRGB() : "; grid, red, green, blue
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetDrawingRGB() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	window = grid
	gc = window[window].gc
	display = window[window].display
	sdisplay = window[window].sdisplay
	colormap = display[display].colormap
	sforeground = window[window].sforeground
	sforegroundDefault = window[window].sforegroundDefault
'
' color = 0 means standard color # 0 = $$Black
'
	IFZ (red OR green OR blue) THEN
		window[window].drawRed = 0
		window[window].drawGreen = 0
		window[window].drawBlue = 0
		window[window].drawColor = 0
		window[window].drawingColor = 0
		scolor = display[display].color[0]
		window[window].sforeground = scolor
		window[window].sforegroundDefault = scolor
'
		IF (scolor != sforeground) THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XSetForeground (sdisplay, gc, scolor)
			##LOCKOUT = lockout
			##WHOMASK = whomask
		END IF
		RETURN ($$FALSE)
	END IF
'
' allocate rgb color
'
	red = red AND 0x0000FFFF
	green = green AND 0x0000FFFF
	blue = blue AND 0x0000FFFF
	r = red >> 8
	g = green >> 8
	b = blue >> 8
	c = 0
'
	window[window].drawRed = red
	window[window].drawGreen = green
	window[window].drawBlue = blue
	window[window].drawColor = 0
	window[window].drawingColor = (r << 24) + (g << 16) + (b << 8) + c
'
	sc.scolor = 0
	sc.r = red
	sc.g = green
	sc.b = blue
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = XAllocColor (sdisplay, colormap, &sc)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	scolor = sc.scolor
	window[window].sforeground = scolor
	window[window].sforegroundDefault = scolor
	IFZ okay THEN PRINT "XgrSetDrawingRGB() : XAllocColor() failed : "; window, color, scolor, sforeground, sforegroundDefault
'
	IF (scolor != sforeground) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetForeground (sdisplay, gc, scolor)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ################################
' #####  XgrSetGridColors()  #####
' ################################
'
FUNCTION  XgrSetGridColors (grid, back, draw, low, high, dull, acc, lowtext, hightext)
	SHARED  WINDOW  window[]
	SHARED  debug
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridColors() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IF (back != -1) THEN XgrSetBackgroundColor (grid, back)
	IF (draw != -1) THEN XgrSetDrawingColor (grid, draw)
	IF (low != -1) THEN window[window].lowlightColor = low
	IF (high != -1) THEN window[window].highlightColor = high
	IF (dull != -1) THEN window[window].dullColor = dull
	IF (acc != -1) THEN window[window].accentColor = acc
	IF (lowtext != -1) THEN window[window].lowtextColor = lowtext
	IF (hightext != -1) THEN window[window].hightextColor = hightext
END FUNCTION
'
'
' ################################
' #####  XgrCreateWindow ()  #####
' ################################
'
' call XgrCreateGrid() to create a "grid" == "subwindow"
'
' window = window[window].top is a window - others are grids and images
'
' parent == 0  :  create "top level window" (framed by window manager)
' parent != 0  :  create "pop-up window" (frameless top level window)
'
FUNCTION  XgrCreateWindow (window, windowType, x, y, w, h, winFunc, display$)
	SHARED  r[]
	SHARED  g[]
	SHARED  b[]
	SHARED  debug
	SHARED  eventTime
	SHARED  flushTime
	SHARED  window$[]
	SHARED  display$[]
	SHARED  sfontDefault
	SHARED  WINDOW	window[]
	SHARED  DISPLAY  display[]
	STATIC  WINDOW  defaultWindow
	STATIC  entry
	XWindowAttributes  attributes
	XSetWindowAttributes  setAttributes
	XSizeHints	sizeHints
	XGCValues  gcvalues
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
'	PRINT "XgrCreateWindow() : "; HEX$(##WHOMASK);; HEX$(whomask,8);; HEX$(winFunc,8)
'
'	XstLog (@"XgrCreateWindow().A")
	IFZ entry THEN GOSUB Initialize						' default window properties
'	XstLog (@"XgrCreateWindow().B")
	IF (window = 0xDEADC0DE) THEN inc = 4			' service for Design window
'
	window = 0
	parent = windowType AND 0x0000FFFF
	windowType = windowType AND 0xFFFF0000
'	XstLog (@"XgrCreateWindow().C")
	error = Display (@display, $$Open, @display$)			' no error if already open
'	XstLog (@"XgrCreateWindow().D")
'
	IF error THEN
		##ERROR = ($$ErrorObjectSystemRoutine << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrCreateWindow() : Display() : Open : failed"
		RETURN ($$TRUE)
	END IF
'
'	PRINT "XgrCreateWindow (" window, HEX$(windowType), x, y, w, h, HEX$(winFunc), "  \""; display$; "\""; " )"
'
	displayWidth = display[display].width
	displayHeight = display[display].height
	windowBorderWidth = display[display].borderWidth
	windowTitleHeight = display[display].titleHeight
'
	IFZ displayWidth THEN displayWidth = #displayWidth
	IFZ displayHeight THEN displayHeight = #displayHeight
	IFZ windowBorderWidth THEN windowBorderWidth = #windowBorderWidth
	IFZ windowTitleHeight THEN windowTitleHeight = #windowTitleHeight
'
	xxx = x
	yyy = y
'
	IF (x <= 0) THEN x = windowBorderWidth
	IF (y <= 0) THEN y = windowBorderWidth + windowTitleHeight
	IF (w <= 7) THEN w = displayWidth >> 2
	IF (h <= 7) THEN h = displayHeight >> 2
'
	xx = x
	yy = y
	ww = w
	hh = h
'
'	IF (xx >= (windowBorderWidth + windowBorderWidth)) THEN xx = xx - windowBorderWidth - windowBorderWidth
'	IF (yy >= (windowBorderWidth + windowBorderWidth + windowTitleHeight + windowTitleHeight)) THEN yy = yy - windowBorderWidth - windowTitleHeight - windowBorderWidth - windowTitleHeight
'	IF (xx >= (windowBorderWidth + windowBorderWidth)) THEN xx = xx - windowBorderWidth
'	IF (yy >= (windowBorderWidth + windowBorderWidth + windowTitleHeight + windowTitleHeight)) THEN yy = yy - windowBorderWidth - windowTitleHeight
'	a$ = "cw : " + HEX$(display,4) + " " + HEX$(xxx,4) + " " + HEX$(yyy,4) + " " + HEX$(x,4) + " " + HEX$(y,4) + " " + HEX$(xx,4) + " " + HEX$(yy,4) + " " + HEX$(ww,4) + " " + HEX$(hh,4) + " " + HEX$(displayWidth,4) + " " + HEX$(displayHeight,4) + " " + HEX$(windowBorderWidth,4) + " " + HEX$(windowTitleHeight,4) + "\n"
'	write (1, &a$, LEN(a$))
'
' set up info and attributes of window, including event types to receive
'
	root = display[display].root
	sroot = display[display].sroot
	class = display[display].class
	depth = display[display].depth
	sblack = display[display].black
	swhite = display[display].white
	visual = display[display].visual
	screen = display[display].screen
	sparent = display[display].sroot
	sdisplay = display[display].sdisplay
'
	IF parent THEN
		IF InvalidWindow (parent) THEN
			##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
			IF debug THEN PRINT "XgrCreateWindow() : error : bad parent : "; parent
			RETURN ($$TRUE)
		END IF
	END IF
'
	mask = 0
	valuemask = 0
	mask = mask OR $$KeyPressMask
	mask = mask OR $$KeyReleaseMask
	mask = mask OR $$ButtonPressMask
	mask = mask OR $$ButtonReleaseMask
	mask = mask OR $$EnterWindowMask
	mask = mask OR $$LeaveWindowMask
	mask = mask OR $$ButtonMotionMask
	mask = mask OR $$ExposureMask
'	mask = mask OR $$VisibilityChangeMask
	mask = mask OR $$StructureNotifyMask
	mask = mask OR $$FocusChangeMask
	setAttributes.eventMask = mask
	valuemask = $$CWEventMask
'
' popup windows want no frame and no window manager placement changes
'
	IF (parent OR (windowType AND $$WindowTypeNoFrame)) THEN
'		PRINT "XgrCreateWindow() : (parent OR (windowType AND $$WindowTypeNoFrame)) : parent, windowType = "; parent, HEX$(windowType)
		valuemask = valuemask | $$CWOverrideRedirect
		setAttributes.overrideRedirect = 1
'		IF XDoesSaveUnders (screen) THEN
			valuemask = valuemask | $$CWSaveUnder
			setAttributes.saveUnder = 1
'		END IF
	END IF
'
' create the window
'
'	PRINT "XgrCreateWindow (" window, HEX$(windowType), x, y, w, h, HEX$(winFunc), "  \""; display$; "\""; " )"
'	PRINT "sdisplay", "sparent", "sroot", "x", "y", "w", "h", "0", "depth", "visual", "valuemask", "&setAttributes"
'	PRINT HEX$(sdisplay), HEX$(sparent), HEX$(sroot), xx, yy, ww, hh, 0, depth, HEX$(visual), HEX$(valuemask), HEX$(&setAttributes)
'
'	XstLog (@"XgrCreateWindow().E")
'
	xxxx = xx
	yyyy = yy
	xxxx = xx - windowBorderWidth
	yyyy = yy - windowBorderWidth - windowTitleHeight
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
'	swindow = XCreateWindow (sdisplay, sparent, xx, yy, ww, hh, 0, depth, $$InputOutput, visual, valuemask, &setAttributes)
	swindow = XCreateWindow (sdisplay, sparent, xxxx, yyyy, ww, hh, 0, depth, $$InputOutput, visual, valuemask, &setAttributes)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'	XstLog (@"XgrCreateWindow().F")
'
	IFZ swindow THEN
		##ERROR = ($$ErrorObjectSystemRoutine << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrCreateWindow() : error : XCreateWindow() failed"
		RETURN ($$TRUE)
	END IF
'
' success - assign a native window number
'
'	XstLog (@"XgrCreateWindow().G")
	GetNewWindowNumber (@window)
'	XstLog (@"XgrCreateWindow().H")
'
	IF debug THEN PRINT "XgrCreateWindow() : "; window;; HEX$(swindow,8);; x;; y;; w;; h;; xx;; yy;; ww;; hh;; HEX$(valuemask,8);; HEX$(winFunc,8)
'
' set window manager hints for top level windows (window broken otherwise)
'
	maxWidth = displayWidth - windowBorderWidth - windowBorderWidth
	maxHeight = displayHeight - windowTitleHeight - windowBorderWidth - windowBorderWidth
	IF (maxWidth < 626) THEN maxWidth = 1600
	IF (maxHeight < 445) THEN maxHeight = 1280
'
'	XstLog (@"XgrCreateWindow().I")
'
	IF (inc <= 0) THEN inc = 1
'
	IFZ parent THEN
		sizeHints.flags = 0x003C
		sizeHints.x = xx
		sizeHints.y = yy
		sizeHints.width = ww
		sizeHints.height = hh
		sizeHints.minWidth = 64
		sizeHints.minHeight = 64
		sizeHints.maxWidth = maxWidth
		sizeHints.maxHeight = maxHeight
		' if inc = 0 then KDE crashes when a window is maximized
		IF inc = 0 THEN
			inc = 1
		END IF
		sizeHints.widthInc = inc
		sizeHints.heightInc = inc
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
'		DIM class$[1]
'		class$[0] = "XBasic"
'		class$[1] = "XBasic"
'		XSetClassHint (sdisplay, swindow, &class$[])
		XSetWMNormalHints (sdisplay, swindow, &sizeHints)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
'	XstLog (@"XgrCreateWindow().J")
'
' prevent close button from killing the application or top-level window
'
	IF #XA_WM_DELETE_WINDOW THEN
		XSetWMProtocols (sdisplay, swindow, &#XA_WM_DELETE_WINDOW, 1)
	END IF
'
' create font and gc (graphics context)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
'	XstLog (@"XgrCreateWindow().K")
	IFZ sfontDefault THEN Font (@font, $$Create, display, @sfontDefault, @addrFont, 0, 0, 0, 0, "")
'	XstLog (@"XgrCreateWindow().L")
	GraphicsContext (@gc, $$Create, sdisplay, screen, swindow, sfontDefault)
'	XstLog (@"XgrCreateWindow().M")
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	window$[window] = ""											' default window name/title
	window[window] = defaultWindow						' default window properties
'
	window[window].window = window            ' native window #
	window[window].type = windowType          ' native windowType
	window[window].leader = parent            ' native leader window #
	window[window].top = window               ' native top level window #
	window[window].display = display					' native display #
	window[window].winFunc = winFunc					' window function
	window[window].font = font                ' native font # (default)
'
	window[window].backgroundColor = #defaultBackground
	window[window].drawingColor = #defaultDrawing
	window[window].lowlightColor = #defaultLowlight
	window[window].highlightColor = #defaultHighlight
	window[window].dullColor = #defaultDull
	window[window].accentColor = #defaultAccent
	window[window].lowtextColor = #defaultLowtext
	window[window].hightextColor = #defaultHightext
'
'	XstLog (@"XgrCreateWindow().N")
	XgrConvertColorToRGB (#defaultBackground, @br, @bg, @bb)
	XgrConvertColorToRGB (#defaultDrawing, @dr, @dg, @db)
'	XstLog (@"XgrCreateWindow().O")
	window[window].backColor = #defaultBackground
	window[window].backBlue = bb
	window[window].backGreen = bg
	window[window].backRed = br
	window[window].drawColor = #defaultDrawing
	window[window].drawBlue = db
	window[window].drawGreen = dg
	window[window].drawRed = dr
	window[window].whomask = whomask					   ' owner whomask
'
'	PRINT "XgrCreateWindow() : whomasks : "; HEX$(##WHOMASK,8);; HEX$(whomask,8);; HEX$(window[window].whomask,8)
'
	window[window].x = x											   ' requested
	window[window].y = y											   ' requested
	window[window].width = w									   ' requested
	window[window].height = h									   ' requested
	window[window].minWidth = 4                  ' default
	window[window].minHeight = 4                 ' default
	window[window].maxWidth = 65536              ' default
	window[window].maxHeight = 65536             ' default
	window[window].gridBoxX1 = 0							   ' default origin = 0,0
	window[window].gridBoxY1 = 0							   ' default origin = 0,0
	window[window].gridBoxX2 = w - 1             ' from requested width
	window[window].gridBoxY2 = h - 1             ' from requested height
	window[window].gridBoxScaledX1 = 0#          '
	window[window].gridBoxScaledY1 = 0#          '
	window[window].gridBoxScaledX2 = DOUBLE(w-1) '
	window[window].gridBoxScaledY2 = DOUBLE(h-1) '
	window[window].xPixelsPerScaled = 1#         '
	window[window].yPixelsPerScaled = 1#         '
	window[window].xScaledPerPixel = 1#          '
	window[window].yScaledPerPixel = 1#          '
'
	window[window].gc = gc										' system gc #
	window[window].sroot = sroot							' system root #
	window[window].stop = swindow							' system window #
	window[window].visual = visual						' system visual
	window[window].swindow = swindow					' system window #
	window[window].sparent = sparent					' system parent #
	window[window].sdisplay = sdisplay				' system display #
	window[window].eventMask = mask           ' XSelectInput() event mask
'
'	XstLog (@"XgrCreateWindow().P")
	XgrSetDrawingColor (window, #defaultDrawing)
'	XstLog (@"XgrCreateWindow().Q")
	XSync (sdisplay, $$FALSE)
'	XstLog (@"XgrCreateWindow().R")
	flushTime = eventTime
'	XstLog (@"XgrCreateWindow().Z")
	RETURN ($$FALSE)
'
'
' *****  Initialize  *****
'
SUB Initialize
	defaultWindow.kind = $$KindWindow
	defaultWindow.backgroundColor = #defaultBackground
	defaultWindow.drawingColor = #defaultDrawing
	defaultWindow.lowlightColor = #defaultLowlight
	defaultWindow.highlightColor = #defaultHighlight
	defaultWindow.dullColor = #defaultDull
	defaultWindow.accentColor = #defaultAccent
	defaultWindow.lowtextColor = #defaultLowtext
	defaultWindow.hightextColor = #defaultHightext
	defaultWindow.backColor = #defaultBackground
	defaultWindow.backBlue = b[3]
	defaultWindow.backGreen = g[3]
	defaultWindow.backRed = r[3]
	defaultWindow.drawColor = #defaultDrawing
	defaultWindow.x = 0
	defaultWindow.y = 0
	defaultWindow.width = 0
	defaultWindow.height = 0
	defaultWindow.minWidth = 4
	defaultWindow.minHeight = 4
	defaultWindow.maxWidth = 65536
	defaultWindow.maxHeight = 65536
	defaultWindow.gridBoxX1 = 0
	defaultWindow.gridBoxY1 = 0
	defaultWindow.gridBoxX2 = 3
	defaultWindow.gridBoxY2 = 3
	defaultWindow.gridBoxScaledX1 = 0#
	defaultWindow.gridBoxScaledY1 = 0#
	defaultWindow.gridBoxScaledX2 = 3#
	defaultWindow.gridBoxScaledY2 = 3#
	defaultWindow.xScaledPerPixel = 1#
	defaultWindow.yScaledPerPixel = 1#
	defaultWindow.xPixelsPerScaled = 1#
	defaultWindow.yPixelsPerScaled = 1#
'
	defaultWindow.sbackground = -1				' default background scolor = none
	defaultWindow.sforeground = -1				' default foreground scolor = none
	defaultWindow.sbackgroundDefault = -1 ' default background scolor = none
	defaultWindow.sforegroundDefault = -1 ' default foreground scolor = none
	defaultWindow.state = $$TRUE          ' window enable
	defaultWindow.visibility = -1         ' window never visible
	defaultWindow.priorVisibility = -1    ' window never visible
	defaultWindow.visibilityRequest = -1  ' never requested
	entry = $$TRUE
END SUB
END FUNCTION
'
'
' #################################
' #####  XgrDestroyWindow ()  #####
' #################################
'
FUNCTION  XgrDestroyWindow (window)
	SHARED  debug
	SHARED  charMap[]
	SHARED  window$[]
	SHARED  modalWindowUser
	SHARED  modalWindowSystem
	SHARED  textSelectionGrid
	SHARED  WINDOW  window[]
	STATIC	WINDOW  zipwin
'
'	PRINT "XgrDestroyWindow().A : "; window;; HEX$(window[window].swindow,8)
	IF #trace THEN PRINT "XgrDestroyWindow() : "; window
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDestroyWindow() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
'	IF (window = modalWindowSystem) THEN PRINT "XgrDestroyWindow().modal.A" : XgrSetModalWindow (0)
'	IF (window = modalWindowUser) THEN PRINT "XgrDestroyWindow().modal.B" : XgrSetModalWindow (0)
	IF (window = modalWindowSystem) THEN XgrSetModalWindow (0)
	IF (window = modalWindowUser) THEN XgrSetModalWindow (0)
'
	gc = window[window].gc
	top = window[window].top
	stop = window[window].stop
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	processed = window[window].destroyProcessed
	destroyed = window[window].destroyed
	destroy = window[window].destroy
	timer = window[window].timer
	func = window[window].winFunc
'
	IF (window != top) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "XgrDestroyWindow() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IF (processed OR destroyed OR destroy) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDestroyWindow() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IFZ swindow THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDestroyWindow() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
' destroy in progress - destroy miscellaneous window resources
'
	func = window[window].winFunc				' get window function
	window[window].state = $$FALSE			' disable output to window
	window[window].destroy = $$TRUE			' destroy already started
	IF timer THEN XstKillTimer (timer)	' no more timer timeouts
'	XgrAddMessage (window, #WindowDestroyed, func, 0, 0, 0, 0, 0)
'
' flush events and message that might be headed for the destroyed window
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	DispatchEvents ($$TRUE, $$FALSE)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	XgrProcessMessages (-2)
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
' destroy all top-level windows that are kids of this window
'
	FOR kid = 1 TO UBOUND (window[])
		IF window[kid].window THEN									' kid is active
			IFZ window[kid].destroy THEN							' not in destroy
				IFZ window[kid].destroyed THEN					' not destroyed
					IF (window = window[kid].leader) THEN	' window is kids parent
						IF (kid != window) THEN							' kid != window
							XgrDestroyWindow (kid)						' destroy kid window
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT kid
'
' flush events and message that might be headed for the destroyed window
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	DispatchEvents ($$TRUE, $$FALSE)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	XgrProcessMessages (-2)
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
' destroy all parentless grids in this window
' these "top-level grids" will recursively destroy all kid grids
'
	FOR grid = 1 TO UBOUND (window[])
		IF window[grid].window THEN									' grid is active
			IFZ window[grid].parent THEN							' parentless grid
				IFZ window[grid].destroy THEN						' not in destroy
					IFZ window[grid].destroyed THEN				' not destroyed
						IF (window = window[grid].top) THEN	' grid is in window
							IF (grid != window) THEN					' grid is not the window
								XgrDestroyGrid (grid)						' destroy this grid
							END IF
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT grid
'
' flush events and message that might be headed for the destroyed grids
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	DispatchEvents ($$TRUE, $$FALSE)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	XgrProcessMessages (-2)
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
'	PRINT "XgrDestroyWindow().C : "; window;;; HEX$(swindow,8);; window[window].destroy;; window[window].destroyed;; window[window].destroyProcessed
'
' hide the window, force events to generate messages
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XUnmapWindow (sdisplay, swindow)
	DispatchEvents ($$TRUE, $$FALSE)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
' Report the #WindowDestroyed before destroying it so any
' laggart messages it generates don't accidently generate
' errant accesses of deleted resources = segment violation.
'
	XgrAddMessage (window, #WindowDestroyed, func, 0, 0, 0, 0, 0)
	XgrProcessMessages (-2)
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
' Destroy the window and graphics context, force events and messages
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XFreeGC (sdisplay, gc)
	XDestroyWindow (sdisplay, swindow)
	DispatchEvents ($$TRUE, $$FALSE)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
' DispatchEvents() will process a DestroyNotify event, which causes
' EventDestroyNotify() to set window[window].destroyed to $$TRUE.
' When XgrProcessMessages() processes #WindowDestroyed messages,
' it sets window[window].destroyProcessed to $$TRUE.
'
	XgrProcessMessages (-2)
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
	disaster = $$FALSE
	IFZ window[window].destroy THEN disaster = $$TRUE
	IFZ window[window].destroyed THEN disaster = $$TRUE
	IFZ window[window].destroyProcessed THEN disaster = $$TRUE
'
	IF disaster THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrDestroyWindow() : window not destroyed : window #"; window; window[window].destroy; window[window].destroyed; window[window].destroyProcessed
		RETURN ($$TRUE)
	END IF
'
	ATTACH charMap[window,] TO temp[] : DIM temp[]							' free char map array
	window[window].window = 0																		' mark window available
'	a$ = "XgrDestroyWindow().Z : " + STRING$(window) + "\n"
'	write (1, &a$, LEN(a$))
END FUNCTION
'
'
' #################################
' #####  XgrDisplayWindow ()  #####
' #################################
'
FUNCTION  XgrDisplayWindow (window)
	SHARED  WINDOW  window[]
	SHARED	debug
'
	IF #trace THEN PRINT "XgrDisplayWindow() : "; window
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDisplayWindow() : error : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	IF (window != top) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "XgrDisplayWindow() : error : window is not a top level window #"; window
		RETURN ($$TRUE)
	END IF
'
' map window and all its kid grids
'
	window[window].visibilityRequest = $$WindowDisplayed
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XMapRaised (sdisplay, swindow)
	DispatchEvents ($$TRUE, $$FALSE)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ##################################
' #####  XgrGetModalWindow ()  #####
' ##################################
'
FUNCTION  XgrGetModalWindow (window)
	SHARED  modalWindowSystem
	SHARED  modalWindowUser
'
	IF ##WHOMASK THEN
		window = modalWindowUser
	ELSE
		window = modalWindowSystem
	END IF
'	PRINT "XgrGetModalWindow() : "; window
END FUNCTION
'
'
' ####################################
' #####  XgrGetWindowDisplay ()  #####
' ####################################
'
FUNCTION  XgrGetWindowDisplay (window, display$)
	SHARED  WINDOW  window[]
	SHARED  display$[]
	SHARED  debug
'
	display$ = ""
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetWindowFunction() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND (display$[])
	display = window[window].display
	IF (display <= upper) THEN display$ = display$[display]
END FUNCTION
'
'
' #####################################
' #####  XgrGetWindowFunction ()  #####
' #####################################
'
FUNCTION  XgrGetWindowFunction (window, func)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetWindowFunction() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	func = window[window].winFunc
END FUNCTION
'
'
' #################################
' #####  XgrGetWindowGrid ()  #####
' #################################
'
FUNCTION  XgrGetWindowGrid (window, grid)
	SHARED  WINDOW  window[]
	SHARED  winGrid[]
'
	grid = 0
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	FOR g = 1 TO UBOUND (window[])
		IF window[g].window THEN									' grid is active
			IF (window == window[g].parent) THEN		' if window is parent of g
				grid = g															' found window grid
				EXIT FOR
			END IF
		END IF
	NEXT g
END FUNCTION
'
'
' #################################
' #####  XgrGetWindowIcon ()  #####
' #################################
'
FUNCTION  XgrGetWindowIcon (window, icon)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetWindowIcon() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	icon = window[window].icon
END FUNCTION
'
'
' ############################################
' #####  XgrGetWindowPositionAndSize ()  #####
' ############################################
'
FUNCTION  XgrGetWindowPositionAndSize (window, @x, @y, @width, @height)
	SHARED  WINDOW  window[]
	SHARED  debug
	AUTOX  XWindowAttributes  windowAttributes
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetWindowPositionAndSize() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	x = window[window].x
	y = window[window].y
	width = window[window].width
	height = window[window].height
END FUNCTION
'
'
' ##################################
' #####  XgrGetWindowState ()  #####
' ##################################
'
FUNCTION  XgrGetWindowState (window, visibility)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetWindowState() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
	visibility = window[top].visibility
END FUNCTION
'
'
' ##################################
' #####  XgrGetWindowTitle ()  #####
' ##################################
'
FUNCTION  XgrGetWindowTitle (window, title$)
	SHARED  WINDOW  window[]
	SHARED  window$[]
	XTextProperty  text
	AUTOX  name
'
	IF #trace THEN PRINT "XgrGetWindowTitle() : "; window
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetWindowTitle() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	sdisplay = window[window].sdisplay
	swindow = window[window].swindow
'
	status = $$FALSE
	title$ = NULL$ (255)
	text.value = &title$
	text.encoding = #XA_WM_NAME
	text.format = 8
	text.nItems = LEN (title$)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
'	XGetTextProperty (sdisplay, swindow, &text, #XA_WM_NAME)
	status = XFetchName (sdisplay, swindow, &name)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
'	PRINT "text.value    = "; HEX$ (text.value)
'	PRINT "text.encoding = "; HEX$ (text.encoding)
'	PRINT "text.format   = "; HEX$ (text.format)
'	PRINT "text.nItems   = "; HEX$ (text.nItems)
'
	IF status THEN
'		title$ = CSTRING$ (text.value)
		title$ = CSTRING$ (name)
		XFree (name)
	ELSE
		title$ = "NONE"
	END IF
END FUNCTION
'
'
' #######################################
' #####  XgrGetWindowVisibility ()  #####
' #######################################
'
FUNCTION  XgrGetWindowVisibility (window, visibility)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetWindowVisibility() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
	visibility = window[top].visibility
END FUNCTION
'
'
' ##############################
' #####  XgrHideWindow ()  #####
' ##############################
'
FUNCTION  XgrHideWindow (window)
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  flushTime
	SHARED	debug
'
	IF #trace THEN PRINT "XgrHideWindow() : "; window
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrHideWindow() : error : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	window = window[window].top
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrHideWindow() : error : bad top level window #"; window
		RETURN ($$TRUE)
	END IF
'
	parent = window[window].parent
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	window[window].visibilityRequest = $$WindowHidden
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XUnmapWindow (sdisplay, swindow)
	DispatchEvents ($$TRUE, $$FALSE)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	flushTime = eventTime
END FUNCTION
'
'
' ##################################
' #####  XgrMaximizeWindow ()  #####
' ##################################
'
FUNCTION  XgrMaximizeWindow (window)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED	debug
'
	IF #trace THEN PRINT "XgrMaximizeWindow() : "; window
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
' gotta work on maximize - for now, just display the window
'
	XgrDisplayWindow (window)
	RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMaximizeWindow() : error : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	window = window[window].top
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMaximizeWindow() : error : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	display = window[window].display
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	visibility = window[window].visibility
	window[window].visibilityRequest = $$WindowMaximized
'
	IF visibility THEN RETURN ($$FALSE)			' window already displayed
	borderWidth = window[window].borderWidth
	titleHeight = window[window].titleHeight
	dwidth = display[display].width
	dheight = display[display].height
'
	x = borderWidth
	y = borderWidth + titleHeight
	width = dwidth - borderWidth - borderWidth
	height = dheight - borderWidth - borderWidth - titleHeight
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XMoveResizeWindow (sdisplay, swindow, x, y, width, height)
	DispatchEvents ($$TRUE, $$FALSE)
	XMapRaised (sdisplay, swindow)
	DispatchEvents ($$TRUE, $$FALSE)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ##################################
' #####  XgrMinimizeWindow ()  #####
' ##################################
'
FUNCTION  XgrMinimizeWindow (window)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED	debug
'
	IF #trace THEN PRINT "XgrMinimizeWindow() : "; window
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMinimizeWindow() : error : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
'
	IF (window != top) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "XgrMinimizeWindow() : error : window not a top-level window #"; window
		RETURN ($$TRUE)
	END IF
'
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	visibility = window[window].visibility
	window[window].visibilityRequest = $$WindowMinimized
	screen = display[display].screen
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XIconifyWindow (sdisplay, swindow, screen)
	DispatchEvents ($$TRUE, $$FALSE)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #################################
' #####  XgrRestoreWindow ()  #####
' #################################
'
FUNCTION  XgrRestoreWindow (window)
	SHARED  WINDOW  window[]
	SHARED	debug
'
	IF #trace THEN PRINT "XgrRestoreWindow() : "; window
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDisplayWindow() : error : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	window = window[window].top
	visibility = window[window].visibility
'
	x = window[window].priorX
	y = window[window].priorY
	w = window[window].priorWidth
	h = window[window].priorHeight
'
	SELECT CASE visibility
		CASE $$WindowHidden			: XgrDisplayWindow (window)
		CASE $$WindowDisplayed	: XgrDisplayWindow (window)
		CASE $$WindowMinimized	: XgrDisplayWindow (window)
		CASE $$WindowMaximized	: XgrSetWindowPositionAndSize (window, x, y, w, h)
		CASE ELSE								: PRINT "XgrRestoreWindow() : unknown current visibility"
	END SELECT
END FUNCTION
'
'
' ##################################
' #####  XgrSetModalWindow ()  #####
' ##################################
'
FUNCTION  XgrSetModalWindow (window)
	SHARED  WINDOW  window[]
	SHARED  modalWindowSystem
	SHARED  modalWindowUser
	SHARED  helpWindow
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
'	PRINT "XgrSetModalWindow().A : "; window
	IF (window < 0) THEN window = 0
'
	IF window THEN
		IF InvalidWindow (window) THEN
			##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrSetModalWindow() : invalid window #"; window
			RETURN ($$TRUE)
		END IF
'
		window = window[window].top		' only top level windows can be modal
'
		IF InvalidWindow (window) THEN
			##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrSetModalWindow() : invalid top window #"
			RETURN ($$TRUE)
		END IF
'
' window = 0 means cancel modal window
'
		enable = $$FALSE
		who = window[window].whomask
		IF (who ^^ whomask) THEN window = 0
	END IF
'
' replace current modal window with new modal window or zero = none
'
	IF whomask THEN
		modalWindowUser = window
	ELSE
		modalWindowSystem = window
	END IF
'	PRINT "XgrSetModalWindow().Z : "; window
END FUNCTION
'
'
' #####################################
' #####  XgrSetWindowFunction ()  #####
' #####################################
'
FUNCTION  XgrSetWindowFunction (window, func)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetWindowFunction() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	window[window].winFunc = func
END FUNCTION
'
'
' #################################
' #####  XgrSetWindowIcon ()  #####
' #################################
'
FUNCTION  XgrSetWindowIcon (window, icon)
	SHARED  WINDOW  window[]
	SHARED  sicon[]
	SHARED  icon$[]
	SHARED  icon[]
	SHARED  debug
	AUTOX  list
	XIconSize  ix
	XWMHints  hint
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetWindowIcon() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	sicon = 0
	IF icon THEN
		IF InvalidIcon (icon) THEN
			##ERROR = ($$ErrorObjectIcon << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrSetWindowIcon() : invalid icon #"; icon
			RETURN ($$TRUE)
		END IF
'
		sdisplay = window[window].sdisplay
		swindow = window[window].swindow
		sicon = sicon[icon]
	END IF
'	XstLog ("XgrSetWindowIcon().Y : " + HEX$(sdisplay,8) + " : " + HEX$(swindow,8) + " : " + HEX$(sicon,8) + " : " + HEX$(icon,8) + " <" + icon$[icon] + ">")
'
	hint.flags = $$HintIconPixmap
	hint.iconPixmap = sicon
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	IF sicon THEN XSetWMHints (sdisplay, swindow, &hint)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'	XstLog (@"XgrSetWindowIcon().Z")
END FUNCTION
'
'
' ############################################
' #####  XgrSetWindowPositionAndSize ()  #####
' ############################################
'
FUNCTION  XgrSetWindowPositionAndSize (window, x, y, width, height)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrSetWindowPositionAndSize() : "; window, x, y, width, height
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetWindowPositionAndSize() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
	display = window[window].display
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	borderWidth = window[window].borderWidth
	titleHeight = window[window].titleHeight
	window[window].visibilityRequest = $$WindowDisplayed
'
	xx = window[window].x
	yy = window[window].y
	ww = window[window].width
	hh = window[window].height
'
	IF (x = -1) THEN x = xx
	IF (y = -1) THEN y = yy
	IF (width < 0) THEN width = ww
	IF (height < 0) THEN height = hh
'
	displayWidth = display[display].width
	displayHeight = display[display].height
	maxWidth = displayWidth - borderWidth - borderWidth
	maxHeight = displayHeight - borderWidth - borderWidth - titleHeight
'
' prevent window from extending outside display aka root window
'
	IF (x < 0) THEN x = borderWidth
	IF (y < titleHeight) THEN y = titleHeight
	IF (width > maxWidth) THEN width = maxWidth
	IF (height > maxHeight) THEN height = maxHeight
	IF (displayWidth < (x + width + borderWidth)) THEN x = displayWidth - borderWidth - width
	IF (displayHeight < (y + height + borderWidth)) THEN y = displayHeight - borderWidth - height
'
	window[window].x = x
	window[window].y = y
	window[window].width = width
	window[window].height = height
'
' this used to work properly
'
	moveX = x - borderWidth
	moveY = y - borderWidth - titleHeight
'
' this now works properly on RedHat 6.1 with GNOME - but not KDE
'
	moveX = x
	moveY = y
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XMoveResizeWindow (sdisplay, swindow, moveX, moveY, width, height)
	DispatchEvents ($$TRUE, $$FALSE)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ##################################
' #####  XgrSetWindowState ()  #####
' ##################################
'
FUNCTION  XgrSetWindowState (window, visibility)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetWindowState() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	return = $$FALSE
	window = window[window].top
'
	SELECT CASE visibility
		CASE $$WindowHidden			: return = XgrHideWindow (window)
		CASE $$WindowDisplayed	: return = XgrDisplayWindow (window)
		CASE $$WindowMinimized	: return = XgrMinimizeWindow (window)
		CASE $$WindowMaximized	: return = XgrMaximizeWindow (window)
		CASE ELSE								: ##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
															IF debug THEN PRINT "XgrSetWindowState() : invalid visibility argument"
															return = $$TRUE
	END SELECT
	RETURN (return)
END FUNCTION
'
'
' ##################################
' #####  XgrSetWindowTitle ()  #####
' ##################################
'
FUNCTION  XgrSetWindowTitle (window, title$)
	SHARED  WINDOW  window[]
	SHARED  window$[]
	XTextProperty  text
'
	IF #trace THEN PRINT "XgrSetWindowTitle() : "; title$
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetWindowTitle() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	##WHOMASK = 0
	sdisplay = window[window].sdisplay
	swindow = window[window].swindow
	window$[window] = title$
	##WHOMASK = whomask
'
	text.value = &title$
	text.encoding = #XA_WM_NAME
	text.format = 8
	text.nItems = LEN (title$)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
'	XSetTextProperty (sdisplay, swindow, &text, #XA_WM_NAME)
	XStoreName (sdisplay, swindow, &title$)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #######################################
' #####  XgrSetWindowVisibility ()  #####
' #######################################
'
FUNCTION  XgrSetWindowVisibility (window, visibility)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetWindowVisibility() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	return = $$FALSE
	window = window[window].top
'
	SELECT CASE visibility
		CASE $$WindowHidden			: return = XgrHideWindow (window)
		CASE $$WindowDisplayed	: return = XgrDisplayWindow (window)
		CASE $$WindowMinimized	: return = XgrMinimizeWindow (window)
		CASE $$WindowMaximized	: return = XgrMaximizeWindow (window)
		CASE ELSE								: ##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
															IF debug THEN PRINT "XgrSetWindowVisibility() : invalid visibility argument"
															return = $$TRUE
	END SELECT
	RETURN (return)
END FUNCTION
'
'
' ##############################
' #####  XgrShowWindow ()  #####
' ##############################
'
FUNCTION  XgrShowWindow (window)
	SHARED  WINDOW  window[]
	SHARED	debug
'
	IF #trace THEN PRINT "XgrShowWindow() : "; window
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrShowWindow() : error : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
'
	IF (window != top) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "XgrShowWindow() : error : window not a top-level window #"; window
		RETURN ($$TRUE)
	END IF
'
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	window[window].visibilityRequest = $$WindowDisplayed
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XMapRaised (sdisplay, swindow)
	DispatchEvents ($$TRUE, $$FALSE)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ########################################
' #####  XgrConvertDisplayToGrid ()  #####
' ########################################
'
FUNCTION  XgrConvertDisplayToGrid (grid, xDisp, yDisp, xGrid, yGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertDisplayToGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertDisplayToLocal (grid, xDisp, yDisp, @x, @y)
	XgrConvertLocalToGrid (grid, x, y, @xGrid, @yGrid)
END FUNCTION
'
'
' #########################################
' #####  XgrConvertDisplayToLocal ()  #####
' #########################################
'
' returns $$TRUE if x,y is outside grid
' computes x,y coords from xDisp,yDisp even if outside grid
'
FUNCTION  XgrConvertDisplayToLocal (grid, xDisp, yDisp, x, y)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertDisplayToLocal() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	width = window[window].width
	height = window[window].height
	display = window[window].display
	displayWidth = display[display].width
	displayHeight = display[display].height
'
' add all x,y window positions from this window back to top window
' to produce the xDisp, yDisp of the upper left corner of this window.
'
	dx = 0
	dy = 0
'
	DO
		dx = dx + window[window].x
		dy = dy + window[window].y
		window = window[window].parent
	LOOP WHILE window
'
	x = xDisp - dx													' x = xDisp in local coords
	y = yDisp - dy													' y = yDisp in local coords
END FUNCTION
'
'
' ##########################################
' #####  XgrConvertDisplayToScaled ()  #####
' ##########################################
'
FUNCTION  XgrConvertDisplayToScaled (grid, xDisp, yDisp, x#, y#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertDisplayToScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertDisplayToLocal (grid, xDisp, yDisp, @x, @y)
	XgrConvertLocalToScaled (grid, x, y, @x#, @y#)
END FUNCTION
'
'
' ##########################################
' #####  XgrConvertDisplayToWindow ()  #####
' ##########################################
'
FUNCTION  XgrConvertDisplayToWindow (grid, xDisp, yDisp, xWin, yWin)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertDisplayToWindow() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = window[grid].top
	width = window[window].width
	height = window[window].height
	xWin = xDisp - window[window].x
	yWin = yDisp - window[window].y
END FUNCTION
'
'
' ########################################
' #####  XgrConvertGridToDisplay ()  #####
' ########################################
'
FUNCTION  XgrConvertGridToDisplay (grid, xGrid, yGrid, xDisp, yDisp)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertGridToDisplay() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x, @y)
	XgrConvertLocalToDisplay (grid, x, y, @xDisp, @yDisp)
END FUNCTION
'
'
' ######################################
' #####  XgrConvertGridToLocal ()  #####
' ######################################
'
FUNCTION  XgrConvertGridToLocal (grid, xGrid, yGrid, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertGridToLocal() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1 = window[window].gridBoxX1
	y1 = window[window].gridBoxY1
	x2 = window[window].gridBoxX2
	y2 = window[window].gridBoxY2
'
	IF (x2 > x1) THEN
		x = xGrid - x1
	ELSE
		x = x1 - xGrid
	END IF
'
	IF (y2 > y1) THEN
		y = yGrid - y1
	ELSE
		y = y1 - yGrid
	END IF
END FUNCTION
'
'
' #######################################
' #####  XgrConvertGridToScaled ()  #####
' #######################################
'
FUNCTION  XgrConvertGridToScaled (grid, xGrid, yGrid, x#, y#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertGridToScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x, @y)
	XgrConvertLocalToScaled (grid, x, y, @x#, @y#)
END FUNCTION
'
'
' #######################################
' #####  XgrConvertGridToWindow ()  #####
' #######################################
'
FUNCTION  XgrConvertGridToWindow (grid, xGrid, yGrid, xWin, yWin)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertGridToWindow() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x, @y)
	XgrConvertLocalToWindow (grid, x, y, @xWin, @yWin)
END FUNCTION
'
'
' #########################################
' #####  XgrConvertLocalToDisplay ()  #####
' #########################################
'
FUNCTION  XgrConvertLocalToDisplay (grid, x, y, xDisp, yDisp)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertLocalToDisplay() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	top = window[window].top
'
' add all x,y positions from this window back to the top window
' to compute the dx,dy of the display origin to this window origin.
'
	dx = 0
	dy = 0
'
	DO
		dx = dx + window[window].x
		dy = dy + window[window].y
		window = window[window].parent
	LOOP WHILE window
'
	xDisp = x + dx
	yDisp = y + dy
END FUNCTION
'
'
' ######################################
' #####  XgrConvertLocalToGrid ()  #####
' ######################################
'
FUNCTION  XgrConvertLocalToGrid (grid, x, y, xGrid, yGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertLocalToGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1 = window[window].gridBoxX1
	y1 = window[window].gridBoxY1
	x2 = window[window].gridBoxX2
	y2 = window[window].gridBoxY2
'
	IF (x2 > x1) THEN
		xGrid = x1 + x
	ELSE
		xGrid = x1 - x
	END IF
'
	IF (y2 > y1) THEN
		yGrid = y1 + y
	ELSE
		yGrid = y1 - y
	END IF
END FUNCTION
'
'
' ########################################
' #####  XgrConvertLocalToScaled ()  #####
' ########################################
'
FUNCTION  XgrConvertLocalToScaled (grid, x, y, x#, y#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertLocalToScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1# = window[window].gridBoxScaledX1
	y1# = window[window].gridBoxScaledY1
	xm# = window[window].xScaledPerPixel
	ym# = window[window].yScaledPerPixel
'
	IFZ xm# THEN UpdateScaledCoordinates (window)
	IFZ ym# THEN UpdateScaledCoordinates (window)
'
	x# = x1# + (x * xm#)
	y# = y1# + (y * ym#)
END FUNCTION
'
'
' ########################################
' #####  XgrConvertLocalToWindow ()  #####
' ########################################
'
FUNCTION  XgrConvertLocalToWindow (grid, x, y, xWin, yWin)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertLocalToWindow() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
' add all x,y positions from this window back to the top window
' to compute the dx,dy of the top window origin to this grid origin.
'
	dx = 0
	dy = 0
	window = grid
	top = window[window].top
'
	DO UNTIL (window = top)
		dx = dx + window[window].x
		dy = dy + window[window].y
		window = window[window].parent
	LOOP WHILE window
'
	xWin = x + dx
	yWin = y + dy
END FUNCTION
'
'
' ##########################################
' #####  XgrConvertScaledToDisplay ()  #####
' ##########################################
'
FUNCTION  XgrConvertScaledToDisplay (grid, x#, y#, xDisp, yDisp)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertScaledToDisplay() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertScaledToLocal (grid, x#, y#, @x, @y)
	XgrConvertLocalToDisplay (grid, x, y, @xDisp, @yDisp)
END FUNCTION
'
'
' #######################################
' #####  XgrConvertScaledToGrid ()  #####
' #######################################
'
FUNCTION  XgrConvertScaledToGrid (grid, x#, y#, xGrid, yGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertScaledToGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertScaledToLocal (grid, x#, y#, @x, @y)
	XgrConvertLocalToGrid (grid, x, y, @xGrid, @yGrid)
END FUNCTION
'
'
' ########################################
' #####  XgrConvertScaledToLocal ()  #####
' ########################################
'
FUNCTION  XgrConvertScaledToLocal (grid, x#, y#, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
	STATIC  entry
	STATIC  max#
	STATIC  min#
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertScaledToLocal() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ entry THEN
		entry = $$TRUE
		max# = 0x7FFFFFFF
		min# = 0x80000001
	END IF
'
	window = grid
	update = $$FALSE
'
	x1# = window[window].gridBoxScaledX1
	y1# = window[window].gridBoxScaledY1
	xm# = window[window].xPixelsPerScaled
	ym# = window[window].yPixelsPerScaled
	mx# = window[window].xScaledPerPixel
	my# = window[window].yScaledPerPixel
'
	IFZ xm# THEN update = $$TRUE
	IFZ ym# THEN update = $$TRUE
	IFZ mx# THEN update = $$TRUE
	IFZ my# THEN update = $$TRUE
'
	IF update THEN
		UpdateScaledCoordinates (window)
		xm# = window[window].xPixelsPerScaled
		ym# = window[window].yPixelsPerScaled
	END IF
'
' to avoid math exceptions caused by too small or large values,
' compute floating point x#,y# and compare to min/max integers.
'
	xx# = (x# - x1#) * xm#		' local x coordinate
	yy# = (y# - y1#) * ym#		' local y coordinate
'
	IF (xx# < min#) THEN xx# = 0x80000001		' xx# was too negative for SLONG
	IF (yy# < min#) THEN yy# = 0x80000001		' yy# was too negative for SLONG
	IF (xx# > max#) THEN xx# = 0x7FFFFFFF		' xx# was too positive for SLONG
	IF (yy# > max#) THEN yy# = 0x7FFFFFFF		' yy# was too positive for SLONG
'
	x = xx#
	y = yy#
END FUNCTION
'
'
' #########################################
' #####  XgrConvertScaledToWindow ()  #####
' #########################################
'
FUNCTION  XgrConvertScaledToWindow (grid, x#, y#, xWin, yWin)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertScaledToWindow() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertScaledToLocal (grid, x#, y#, @x, @y)
	XgrConvertLocalToWindow (grid, x, y, @xWin, @yWin)
END FUNCTION
'
'
' ##########################################
' #####  XgrConvertWindowToDisplay ()  #####
' ##########################################
'
FUNCTION  XgrConvertWindowToDisplay (grid, xWin, yWin, xDisp, yDisp)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertWindowToDisplay() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window = window[window].top
	xDisp = xWin + window[window].x
	yDisp = yWin + window[window].y
END FUNCTION
'
'
' #######################################
' #####  XgrConvertWindowToGrid ()  #####
' #######################################
'
FUNCTION  XgrConvertWindowToGrid (grid, xWin, yWin, xGrid, yGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertWindowToGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertWindowToLocal (grid, xWin, yWin, @x, @y)
	XgrConvertLocalToGrid (grid, x, y, @xGrid, @yGrid)
END FUNCTION
'
'
' ########################################
' #####  XgrConvertWindowToLocal ()  #####
' ########################################
'
FUNCTION  XgrConvertWindowToLocal (grid, xWin, yWin, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertWindowToLocal() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
' add all x,y positions from this window back to the top window
' to compute the dx,dy of the top window origin to this grid origin.
'
	dx = 0
	dy = 0
	window = grid
	top = window[window].top
'
	DO UNTIL (window = top)
		dx = dx + window[window].x
		dy = dy + window[window].y
		window = window[window].parent
	LOOP WHILE window
'
	x = xWin - dx
	y = yWin - dy
END FUNCTION
'
'
' #########################################
' #####  XgrConvertWindowToScaled ()  #####
' #########################################
'
FUNCTION  XgrConvertWindowToScaled (grid, xWin, yWin, x#, y#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrConvertWindowToScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrConvertWindowToLocal (grid, xWin, yWin, @x, @y)
	XgrConvertLocalToScaled (grid, x, y, @x#, @y#)
END FUNCTION
'
'
' ##############################
' #####  XgrGetGridBox ()  #####
' ##############################
'
FUNCTION  XgrGetGridBox (grid, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBox() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1Grid = window[window].gridBoxX1
	y1Grid = window[window].gridBoxY1
	x2Grid = window[window].gridBoxX2
	y2Grid = window[window].gridBoxY2
END FUNCTION
'
'
' #####################################
' #####  XgrGetGridBoxDisplay ()  #####
' #####################################
'
FUNCTION  XgrGetGridBoxDisplay (grid, x1Disp, y1Disp, x2Disp, y2Disp)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBoxDisplay() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1 = 0
	y1 = 0
	x2 = window[window].width - 1
	y2 = window[window].height - 1
	XgrConvertLocalToDisplay (grid, x1, y1, @x1Disp, @y1Disp)
	XgrConvertLocalToDisplay (grid, x2, y2, @x2Disp, @y2Disp)
END FUNCTION
'
'
' ##################################
' #####  XgrGetGridBoxGrid ()  #####
' ##################################
'
FUNCTION  XgrGetGridBoxGrid (grid, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBoxGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1Grid = window[window].gridBoxX1
	y1Grid = window[window].gridBoxY1
	x2Grid = window[window].gridBoxX2
	y2Grid = window[window].gridBoxY2
END FUNCTION
'
'
' ###################################
' #####  XgrGetGridBoxLocal ()  #####
' ###################################
'
FUNCTION  XgrGetGridBoxLocal (grid, x1, y1, x2, y2)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBox() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1 = 0
	y1 = 0
	x2 = window[window].width - 1
	y2 = window[window].height - 1
END FUNCTION
'
'
' ####################################
' #####  XgrGetGridBoxScaled ()  #####
' ####################################
'
FUNCTION  XgrGetGridBoxScaled (grid, x1#, y1#, x2#, y2#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBoxScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1# = window[window].gridBoxScaledX1
	y1# = window[window].gridBoxScaledY1
	x2# = window[window].gridBoxScaledX2
	y2# = window[window].gridBoxScaledY2
END FUNCTION
'
'
' ####################################
' #####  XgrGetGridBoxWindow ()  #####
' ####################################
'
FUNCTION  XgrGetGridBoxWindow (grid, x1Win, y1Win, x2Win, y2Win)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBoxWindow() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1 = 0
	y1 = 0
	x2 = window[window].width - 1
	y2 = window[window].height - 1
	XgrConvertLocalToWindow (grid, x1, y1, @x1Win, @y1Win)
	XgrConvertLocalToWindow (grid, x2, y2, @x2Win, @y2Win)
END FUNCTION
'
'
' ######################################
' #####  XgrGetGridCoordinates ()  #####
' ######################################
'
FUNCTION  XgrGetGridCoordinates (grid, x, y, x1, y1, x2, y2)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridCoordinates() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x = window[window].x
	y = window[window].y
	x1 = 0
	y1 = 0
	x2 = window[window].width - 1
	y2 = window[window].height - 1
END FUNCTION
'
'
' ##########################################
' #####  XgrGetGridPositionAndSize ()  #####
' ##########################################
'
FUNCTION  XgrGetGridPositionAndSize (grid, @x, @y, @width, @height)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridPositionAndSize() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x = window[window].x
	y = window[window].y
	width = window[window].width
	height = window[window].height
END FUNCTION
'
'
' ##############################
' #####  XgrSetGridBox ()  #####
' ##############################
'
FUNCTION  XgrSetGridBox (grid, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridBox() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	width = window[window].width
	height = window[window].height
	newWidth = ABS(x2Grid-x1Grid) + 1
	newHeight = ABS(y2Grid-y1Grid) + 1
'
	IF (width != newWidth) THEN
		oldX1 = window[window].gridBoxX1
		oldX2 = window[window].gridBoxX2
		IF (oldX2 < oldX1) THEN
			x2Grid = x1Grid - width + 1			' x decreases rightward
		ELSE
			x2Grid = x1Grid + width - 1			' x increases rightward
		END IF
	END IF
'
	IF (height != newHeight) THEN
		oldY1 = window[window].gridBoxY1
		oldY2 = window[window].gridBoxY2
		IF (oldY2 < oldY1) THEN
			y2Grid = y1Grid - height + 1		' y decreases downward
		ELSE
			y2Grid = y1Grid + height - 1		' y increases downward
		END IF
	END IF
'
	window[window].gridBoxX1 = x1Grid
	window[window].gridBoxY1 = y1Grid
	window[window].gridBoxX2 = x2Grid
	window[window].gridBoxY2 = y2Grid
END FUNCTION
'
'
' ##################################
' #####  XgrSetGridBoxGrid ()  #####
' ##################################
'
FUNCTION  XgrSetGridBoxGrid (grid, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridBoxGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	width = window[window].width
	height = window[window].height
	newWidth = ABS(x2Grid-x1Grid) + 1
	newHeight = ABS(y2Grid-y1Grid) + 1
'
	IF (width != newWidth) THEN
		oldX1 = window[window].gridBoxX1
		oldX2 = window[window].gridBoxX2
		IF (oldX2 < oldX1) THEN
			x2Grid = x1Grid - width + 1			' x decreases rightward
		ELSE
			x2Grid = x1Grid + width - 1			' x increases rightward
		END IF
	END IF
'
	IF (height != newHeight) THEN
		oldY1 = window[window].gridBoxY1
		oldY2 = window[window].gridBoxY2
		IF (oldY2 < oldY1) THEN
			y2Grid = y1Grid - height + 1		' y decreases downward
		ELSE
			y2Grid = y1Grid + height - 1		' y increases downward
		END IF
	END IF
'
	window[window].gridBoxX1 = x1Grid
	window[window].gridBoxY1 = y1Grid
	window[window].gridBoxX2 = x2Grid
	window[window].gridBoxY2 = y2Grid
END FUNCTION
'
'
' ####################################
' #####  XgrSetGridBoxScaled ()  #####
' ####################################
'
FUNCTION  XgrSetGridBoxScaled (grid, x1#, y1#, x2#, y2#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridBoxScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
'
'	SELECT CASE x1#
'		CASE $$NNAN		:	x1# = 0#	: x2# = 1#
'		CASE $$PNAN		: x1# = 0#	: x2# = 1#
'		CASE $$NINF		: x1# = 0#	: x2# = 1#
'		CASE $$PINF		: x1# = 0#	: x2# = 1#
'	END SELECT
'
'	SELECT CASE y1#
'		CASE $$NNAN		:	y1# = 0#	: y2# = 1#
'		CASE $$PNAN		: y1# = 0#	: y2# = 1#
'		CASE $$NINF		: y1# = 0#	: y2# = 1#
'		CASE $$PINF		: y1# = 0#	: y2# = 1#
'	END SELECT
'
'	SELECT CASE x2#
'		CASE $$NNAN		:	x1# = 0#	: x2# = 1#
'		CASE $$PNAN		: x1# = 0#	: x2# = 1#
'		CASE $$NINF		: x1# = 0#	: x2# = 1#
'		CASE $$PINF		: x1# = 0#	: x2# = 1#
'	END SELECT
'
'	SELECT CASE y2#
'		CASE $$NNAN		:	y1# = 0#	: y2# = 1#
'		CASE $$PNAN		: y1# = 0#	: y2# = 1#
'		CASE $$NINF		: y1# = 0#	: y2# = 1#
'		CASE $$PINF		: y1# = 0#	: y2# = 1#
'	END SELECT
'
	IF (x1# = x2#) THEN													' avoid math exceptions
		x1# = window[window].gridBoxX1
		x2# = window[window].gridBoxX2
	END IF
	IF (x1# = x2#) THEN x1# = -1# : x2# = +1#
'
	IF (y1# = y2#) THEN													' avoid math exceptions
		y1# = window[window].gridBoxY1
		y2# = window[window].gridBoxY2
	END IF
	IF (y1# = y2#) THEN y1# = -1# : y2# = +1#
'
	window[window].gridBoxScaledX1 = x1#
	window[window].gridBoxScaledY1 = y1#
	window[window].gridBoxScaledX2 = x2#
	window[window].gridBoxScaledY2 = y2#
'
	window[window].xScaledPerPixel = 0#					' update when necessary
	window[window].yScaledPerPixel = 0#
	window[window].xPixelsPerScaled = 0#
	window[window].yPixelsPerScaled = 0#
END FUNCTION
'
'
' ######################################
' #####  XgrSetGridBoxScaledAt ()  #####
' ######################################
'
FUNCTION  XgrSetGridBoxScaledAt (grid, x1#, y1#, x2#, y2#, x1, y1, x2, y2)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridPositionAndSize() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	XgrGetGridBox (grid, @xx1, @yy1, @xx2, @yy2)
'
	dx = x2 - x1
	dy = y2 - y1
'
	dx# = x2# - x1#
	dy# = y2# - y1#
'
	ddx = xx2 - xx1
	ddy = yy2 - yy1
'
	xx# = dx# / dx
	yy# = dy# / dy
'
	xx1# = x1# - (xx# * x1)		' scaled coord of left pixel
	yy1# = y1# - (yy# * y1)		' scaled coord of top pixel
'
	xx2# = xx1# + (xx# * ddx)	' scaled coord of right pixel
	yy2# = yy1# + (yy# * ddy)	' scaled coord of bottom pixel
'
	XgrSetGridBoxScaled (grid, xx1#, yy1#, xx2#, yy2#)
'
'	PRINT FORMAT$ ("###.#####  ", x1); FORMAT$ ("###.#####  ", y1); FORMAT$ ("###.#####  ", x2); FORMAT$ ("###.#####  ", y2)
'	PRINT FORMAT$ ("###.#####  ", x1#); FORMAT$ ("###.#####  ", y1#); FORMAT$ ("###.#####  ", x2#); FORMAT$ ("###.#####  ", y2#)
'	PRINT FORMAT$ ("###.#####  ", xx1#); FORMAT$ ("###.#####  ", yy1#); FORMAT$ ("###.#####  ", xx2#); FORMAT$ ("###.#####  ", yy2#)
END FUNCTION
'
'
' ##########################################
' #####  XgrSetGridPositionAndSize ()  #####
' ##########################################
'
FUNCTION  XgrSetGridPositionAndSize (grid, x, y, width, height)
	SHARED  WINDOW  window[]
	SHARED  debug
	STATIC  WINDOW  winzip
'
	IF #trace THEN PRINT "XgrSetGridPositionAndSize() : "; grid, x, y, width, height
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridPositionAndSize() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	top = window[window].top
	parent = window[window].parent
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	gridFunc = window[window].gridFunc
	gridType = window[window].type
'
	IF (window = top) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "XgrSetGridPositionAndSize() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
' get current coordinates
'
	xx = window[window].x
	yy = window[window].y
	ww = window[window].width
	hh = window[window].height
	gridBoxX1 = window[window].gridBoxX1
	gridBoxY1 = window[window].gridBoxY1
	gridBoxX2 = window[window].gridBoxX2
	gridBoxY2 = window[window].gridBoxY2
'
	IF (gridType = 1) THEN x = 0 : y = 0 : xx = 0 : yy = 0
'
	IF (x = -1) THEN x = xx
	IF (y = -1) THEN y = yy
	IF (width <= 0) THEN width = ww
	IF (height <= 0) THEN height = hh
'
' see if position and/or size changed
'
	w = $$FALSE
	h = $$FALSE
	move = $$FALSE
'
	IF (x != xx) THEN move = $$TRUE
	IF (y != yy) THEN move = $$TRUE
	IF (width != ww) THEN w = $$TRUE
	IF (height != hh) THEN h = $$TRUE
'
' if same position and size don't move or resize window
'
	IFZ (move OR w OR h) THEN RETURN ($$FALSE)
'
' update grid position and size
'
	window[window].x = x
	window[window].y = y
	window[window].width = width
	window[window].height = height
'
	IF (move OR w OR h) THEN
		window[window].priorX = xx
		window[window].priorY = yy
		window[window].priorWidth = width
		window[window].priorHeight = height
		window[window].xScaledPerPixel = 0#			' invalidate
		window[window].yScaledPerPixel = 0#			' scaled coordinate
		window[window].xPixelsPerScaled = 0#		' multipliers
		window[window].yPixelsPerScaled = 0#		'
	END IF
'
' compute new grid box
' leave x1,y1 the same
' set x2,y2 with same direction (increasing left vs right / up vs down)
'
	IF (gridBoxX2 < gridBoxX1) THEN
		gridBoxX2 = gridBoxX1 - width + 1			' x coords decrease rightward
	ELSE
		gridBoxX2 = gridBoxX1 + width - 1			' x coords increase rightward
	END IF
'
	IF (gridBoxY2 < gridBoxY1) THEN
		gridBoxY2 = gridBoxY1 - height + 1		' y coords decrease downward
	ELSE
		gridBoxY2 = gridBoxY1 + height - 1		' y coords increase downward
	END IF
'
	window[window].gridBoxX1 = gridBoxX1
	window[window].gridBoxY1 = gridBoxY1
	window[window].gridBoxX2 = gridBoxX2
	window[window].gridBoxY2 = gridBoxY2
'
' cannot resize pixmaps, so create a new image grid of the new size
'
	image = 0
	IF (gridType = 1) THEN
		IFZ (w OR h) THEN RETURN ($$FALSE)			' image grid size unchanged
		XgrCreateGrid (@image, 1, 0, 0, width, height, window, parent, gridFunc)
		IF image THEN
			XgrDestroyGrid (grid)									' destroy old pixmap
			window[grid] = window[image]					' steal new grid slot
			window[grid].window = grid						' steal new grid number
			window[image] = winzip								' clear out image slot
		END IF
	ELSE
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XMoveResizeWindow (sdisplay, swindow, x, y, width, height)
		DispatchEvents ($$TRUE, $$FALSE)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ##############################
' #####  XgrCreateGrid ()  #####
' ##############################
'
FUNCTION  XgrCreateGrid (grid, gridType, x, y, w, h, window, parent, gridFunc)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  sfontDefault
	SHARED  window$[]
	SHARED  noExpose
	SHARED  debug
	SHARED  rgb[]
	SHARED  r[]
	SHARED  g[]
	SHARED  b[]
	STATIC  entry
	STATIC  WINDOW  defaultGrid
	XWindowAttributes  attributes
	XSetWindowAttributes  setAttributes
	XGCValues  gcvalues
'
	IF #trace THEN PRINT "XgrCreateGrid() : "; gridType, window, parent, HEX$(gridFunc,8)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ entry THEN GOSUB Initialize
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrCreateGrid() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	state = $$TRUE
	IF (gridType < 0) THEN gridType = -gridType : state = $$FALSE
'
'	XgrGridTypeNumberToName (gridType, @gt$)
'	PRINT "XgrCreateGrid() : "; grid; gridType;; gt$; x; y; w; h; window; parent;; HEX$(gridFunc,8);;;;
'
' if gridType = 1, then this is an image grid
' if parent != 0, then this is a "subwindow" or "grid"
' if parent = 0, then this is the "window grid" that IS the window
'
	sdisplay = window[window].sdisplay
	display = window[window].display
	IFZ parent THEN parent = window
'
	SELECT CASE TRUE
		CASE gridType = #GridTypeImage	: GOSUB Image
		CASE parent											: GOSUB Grid
		CASE ELSE												:	PRINT "XgrCreateGrid() : disaster"
	END SELECT
	RETURN (return)
'
'
' *****  Image  *****
'
SUB Image
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrCreateGrid() : Image : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
	stop = window[window].stop
	display = window[window].display
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	root = display[display].root
	sroot = display[display].sroot
	class = display[display].class
	depth = display[display].depth
	sblack = display[display].black
	swhite = display[display].white
	visual = display[display].visual
	screen = display[display].screen
'
' if zero width or height then set width, height to parent width, height
'
	IF ((w <= 0) OR (h <= 0)) THEN
		IF (parent AND (parent != top)) THEN
			h = window[parent].height
			w = window[parent].width
		END IF
	END IF
'
'	a$ = "\ndepth = " + STRING$ (depth) + "\n"
'	write (1, &a$, LEN(a$))
'
'	addr = XListPixmapFormats (sdisplay, &count)
'	IF addr THEN
'		IF count THEN
'			FOR i = 1 TO count
'				d = XLONGAT (addr)	: addr = addr + 4
'				b = XLONGAT (addr)	: addr = addr + 4
'				s = XLONGAT (addr)	: addr = addr + 4
'				a$ = STRING$(i) + " " + STRING$(d) + " " + STRING$(b) + " " + STRING$(s) + "\n"
'				write (1, &a$, LEN(a$))
'			NEXT i
'		END IF
'	END IF
'
	IF (w <= 0) THEN width = 32			' need valid width
	IF (h <= 0) THEN height = 32		' need valid height
'
' create the memory image == pixmap
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	simage = XCreatePixmap (sdisplay, stop, w, h, depth)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ simage THEN
		##ERROR = ($$ErrorObjectSystemRoutine << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrCreateGrid() : error : XCreatePixmap() failed"
		RETURN ($$TRUE)
	END IF
'
' assign graphics context, colors, font to image/pixmap
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	GraphicsContext (@gc, $$Create, sdisplay, screen, simage, sfontDefault)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
' get a grid # and initialize values
'
	GetNewWindowNumber (@grid)
'
	IF debug THEN PRINT "XgrCreateGrid() : Image : "; grid, HEX$(simage,8)
'
	window$[grid] = ""											' default grid name/title
	window[grid] = defaultGrid							' default grid properties
'
	window[grid].window = grid              ' native window / grid #
	window[grid].parent = parent            ' native parent window #
	window[grid].kind = $$KindGrid          ' $$KindGrid vs $$KindWindow
	window[grid].type = gridType            ' grid type
	window[grid].top = top                  ' native top level window #
	window[grid].display = display					' native display #
	window[grid].gridFunc = gridFunc				' grid function
	window[grid].whomask = whomask          ' owner whomask
	window[grid].font = font                ' native font # (default)
'
	window[grid].lowlightColor = #defaultLowlight
	window[grid].highlightColor = #defaultHighlight
	window[grid].dullColor = #defaultDull
	window[grid].accentColor = #defaultAccent
	window[grid].lowtextColor = #defaultLowtext
	window[grid].hightextColor = #defaultHightext
'
	window[grid].x = x											   ' requested
	window[grid].y = y											   ' requested
	window[grid].width = w									   ' requested
	window[grid].height = h									   ' requested
	window[grid].minWidth = 4                  ' default
	window[grid].minHeight = 4                 ' default
	window[grid].maxWidth = 65536              ' default
	window[grid].maxHeight = 65536             ' default
	window[grid].gridBoxX1 = 0							   ' default origin = 0,0
	window[grid].gridBoxY1 = 0							   ' default origin = 0,0
	window[grid].gridBoxX2 = w - 1             ' from requested width
	window[grid].gridBoxY2 = h - 1             ' from requested height
	window[grid].gridBoxScaledX1 = 0#          '
	window[grid].gridBoxScaledY1 = 0#          '
	window[grid].gridBoxScaledX2 = DOUBLE(w-1) '
	window[grid].gridBoxScaledY2 = DOUBLE(h-1) '
'
' swindow = simage = system pixmap #
'
	window[grid].gc = gc                       ' system gc #
	window[grid].stop = stop                   ' system top #
	window[grid].sroot = sroot                 ' system root #
	window[grid].visual = visual               ' system visual
	window[grid].swindow = simage              ' system window #
	window[grid].sparent = sparent             ' system parent #
	window[grid].sdisplay = sdisplay           ' system display #
'
' initialize the background and drawing colors and clear to background color
'
	XgrSetBackgroundColor (grid, #defaultBackground)
	XgrSetDrawingColor (grid, #defaultDrawing)
	XgrClearGrid (grid, #defaultBackground)
	return = $$FALSE
END SUB
'
'
' *****  Grid  *****  this grid has a parent, so it's a kid grid
'
SUB Grid
	IF InvalidGrid (parent) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrCreateGrid() : invalid parent #"
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
	stop = window[window].stop
	display = window[parent].display
	sparent = window[parent].swindow
	sdisplay = window[parent].sdisplay
'
	root = display[display].root
	sroot = display[display].sroot
	class = display[display].class
	depth = display[display].depth
	sblack = display[display].black
	swhite = display[display].white
	visual = display[display].visual
	screen = display[display].screen
'
' if zero width or height then set width, height to parent width, height
'
	IF ((w <= 0) OR (h <= 0)) THEN
		IF parent THEN
			h = window[parent].height
			w = window[parent].width
		ELSE
			h = window[top].height
			w = window[top].width
		END IF
	END IF
'
	IF (w < 4) THEN width = 32		' need valid width
	IF (h < 4) THEN height = 32		' need valid height
'
	mask = 0
	valuemask = 0
	mask = mask OR $$KeyPressMask
	mask = mask OR $$KeyReleaseMask
	mask = mask OR $$ButtonPressMask
	mask = mask OR $$ButtonReleaseMask
	mask = mask OR $$EnterWindowMask
	mask = mask OR $$LeaveWindowMask
	mask = mask OR $$ButtonMotionMask
	mask = mask OR $$ExposureMask
'	mask = mask OR $$VisibilityChangeMask
	mask = mask OR $$StructureNotifyMask				' !!!!!!
	mask = mask OR $$FocusChangeMask
	setAttributes.eventMask = mask
	valuemask = $$CWEventMask
'
'	PRINT x; y; w; h;;;; HEX$(sdisplay,8);; HEX$(sparent,8);; depth;; HEX$(visual,8);; HEX$(valuemask,8);; HEX$(&setAttributes)
'
' create the window
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	swindow = XCreateWindow (sdisplay, sparent, x, y, w, h, 0, depth, $$InputOutput, visual, valuemask, &setAttributes)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ swindow THEN
		##ERROR = ($$ErrorObjectSystemRoutine << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrCreateGrid() : error : XCreateWindow() failed"
		RETURN ($$TRUE)
	END IF
'
' success - assign a native window number
'
	GetNewWindowNumber (@grid)
'
	IF debug THEN
		XgrGridTypeNumberToName (gridType, @gridType$)
		PRINT "XgrCreateGrid() : "; grid;; HEX$(grid,8);; HEX$(swindow,8);; gridType;; gridType$;; parent;; window;;; HEX$(gridFunc,8)
	END IF
'
' create font and gc (graphics context)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	IFZ sfontDefault THEN Font (@font, $$Create, display, @sfontDefault, @addrFont, 0, 0, 0, 0, "")
	GraphicsContext (@gc, $$Create, sdisplay, screen, swindow, sfontDefault)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	window$[grid] = ""											' default grid name/title
	window[grid] = defaultGrid							' default grid properties
'
	winFunc = window[parent].winFunc        ' inheret parent window function
	window[grid].window = grid              ' native window / grid #
	window[grid].parent = parent            ' native parent window #
	window[grid].kind = $$KindGrid          ' $$KindGrid vs $$KindWindow
	window[grid].type = gridType            ' grid type
	window[grid].top = top                  ' native top level window #
	window[grid].display = display					' native display #
	window[grid].gridFunc = gridFunc				' grid function
	window[grid].winFunc = winFunc          ' no window function
	window[grid].font = font                ' native font # (default)
'
	window[grid].lowlightColor = #defaultLowlight
	window[grid].highlightColor = #defaultHighlight
	window[grid].dullColor = #defaultDull
	window[grid].accentColor = #defaultAccent
	window[grid].lowtextColor = #defaultLowtext
	window[grid].hightextColor = #defaultHightext
'
	window[grid].state = state                 ' grid enable / disable
	window[grid].visibility = -1               ' window never visible
	window[grid].priorVisibility = -1          ' window never visible
	window[grid].whomask = whomask             ' owner whomask
'
	window[grid].x = x											   ' requested
	window[grid].y = y											   ' requested
	window[grid].width = w									   ' requested
	window[grid].height = h									   ' requested
	window[grid].minWidth = 4                  ' default
	window[grid].minHeight = 4                 ' default
	window[grid].maxWidth = 65536              ' default
	window[grid].maxHeight = 65536             ' default
	window[grid].gridBoxX1 = 0							   ' default origin = 0,0
	window[grid].gridBoxY1 = 0							   ' default origin = 0,0
	window[grid].gridBoxX2 = w - 1             ' from requested width
	window[grid].gridBoxY2 = h - 1             ' from requested height
	window[grid].gridBoxScaledX1 = 0#          '
	window[grid].gridBoxScaledY1 = 0#          '
	window[grid].gridBoxScaledX2 = DOUBLE(w-1) '
	window[grid].gridBoxScaledY2 = DOUBLE(h-1) '
'
	window[grid].gc = gc                       ' system gc #
	window[grid].stop = stop                   ' system top #
	window[grid].sroot = sroot                 ' system root #
	window[grid].visual = visual               ' system visual
	window[grid].swindow = swindow             ' system window #
	window[grid].sparent = sparent             ' system parent #
	window[grid].sdisplay = sdisplay           ' system display #
	window[grid].eventMask = mask              ' XSelectInput() event mask
'
' initialize the background and drawing colors
'
	XgrSetBackgroundColor (grid, #defaultBackground)
	XgrSetDrawingColor (grid, #defaultDrawing)
'
	noExpose = grid
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	IF state THEN XMapWindow (sdisplay, swindow)
	DispatchEvents ($$TRUE, $$FALSE)
	##LOCKOUT = lockout
	##WHOMASK = whomask
	noExpose = 0
'
	return = $$FALSE
END SUB
'
'
' *****  Initialize  *****  anything not specified is 0 = zero
'
SUB Initialize
	defaultGrid.kind = $$KindGrid
	defaultGrid.backgroundColor = #defaultBackground
	defaultGrid.drawingColor = #defaultDrawing
	defaultGrid.lowlightColor = #defaultLowlight
	defaultGrid.highlightColor = #defaultHighlight
	defaultGrid.dullColor = #defaultDull
	defaultGrid.accentColor = #defaultAccent
	defaultGrid.lowtextColor = #defaultLowtext
	defaultGrid.hightextColor = #defaultHightext
	defaultGrid.backColor = #defaultBackground
	defaultGrid.backBlue = b[3]
	defaultGrid.backGreen = g[3]
	defaultGrid.backRed = r[3]
	defaultGrid.drawColor = #defaultDrawing
	defaultGrid.drawBlue = b[0]
	defaultGrid.drawGreen = g[0]
	defaultGrid.drawRed = r[0]
	defaultGrid.x = 0
	defaultGrid.y = 0
	defaultGrid.width = 4
	defaultGrid.height = 4
	defaultGrid.minWidth = 4
	defaultGrid.minHeight = 4
	defaultGrid.maxWidth = 65536
	defaultGrid.maxHeight = 65536
	defaultGrid.gridBoxX1 = 0
	defaultGrid.gridBoxY1 = 0
	defaultGrid.gridBoxX2 = 3
	defaultGrid.gridBoxY2 = 3
	defaultGrid.gridBoxScaledX1 = 0#
	defaultGrid.gridBoxScaledY1 = 0#
	defaultGrid.gridBoxScaledX2 = 3#
	defaultGrid.gridBoxScaledY2 = 3#
	defaultGrid.xPixelsPerScaled = 1#
	defaultGrid.yPixelsPerScaled = 1#
	defaultGrid.xScaledPerPixel = 1#
	defaultGrid.yScaledPerPixel = 1#
'
	defaultGrid.sbackground = -1        ' current background scolor = none
	defaultGrid.sforeground = -1        ' current foreground scolor = none
	defaultGrid.sbackgroundDefault = -1 ' default background scolor = none
	defaultGrid.sforegroundDefault = -1 ' default foreground scolor = none
	defaultGrid.state = $$TRUE          ' grid enable
	defaultGrid.visibility = -1         ' window never visible
	defaultGrid.priorVisibility = -1    ' window never visible
	entry = $$TRUE
END SUB
END FUNCTION
'
'
' ###############################
' #####  XgrDestroyGrid ()  #####
' ###############################
'
FUNCTION  XgrDestroyGrid (wingrid)
	SHARED  debug
	SHARED  window$[]
	SHARED  textSelectionGrid
	SHARED  WINDOW  window[]
	STATIC	WINDOW  zipwin
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	grid = wingrid
	window = wingrid
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDestroyGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	gc = window[grid].gc
	top = window[grid].top
	stop = window[grid].stop
	swindow = window[grid].swindow
	sdisplay = window[grid].sdisplay
	processed = window[grid].destroyProcessed
	destroyed = window[grid].destroyed
	destroy = window[grid].destroy
	gridType = window[grid].type
	timer = window[grid].timer
	func = window[grid].winFunc
'
	IF (grid = top) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalidKind
		IF debug THEN PRINT "XgrDestroyGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IF (processed OR destroyed OR destroy) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDestroyGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ swindow THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDestroyGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
' flush any events and message that might be headed for the destroyed grid
'
	DispatchEvents ($$FALSE, $$FALSE)
	XgrProcessMessages (-2)
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
' destroy in progress - destroy miscellaneous grid resources
'
	window[grid].state = $$FALSE
	window[grid].destroy = $$TRUE
	IF timer THEN XstKillTimer (timer)
	IF (grid = textSelectionGrid) THEN textSelectionGrid = 0
'
' destroy all kids of this grid - recursively kills all descendents
'
	FOR kid = 1 TO UBOUND (window[])
		IF window[kid].window THEN									' kid is active
			IFZ window[kid].destroy THEN							' not in destroy
				IFZ window[kid].destroyed THEN					' not destroyed
					IF (grid = window[kid].parent) THEN		' grid is kid parent
						IF (kid != grid) THEN								' kid is not the grid
							XgrDestroyGrid (kid)							' destroy kid
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT kid
'
' process all resulting events and messages
'
	XgrProcessMessages (-2)
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
' prevent further xlib events for this grid
' hide the grid, no events or messages for this grid should result
'
	IF (gridType != 1) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSelectInput (sdisplay, swindow, 0)
		XUnmapWindow (sdisplay, swindow)
		DispatchEvents ($$TRUE, $$FALSE)
		##WHOMASK = whomask
		##LOCKOUT = lockout
	END IF
'
' because of the way GuiDesigner is currently written,
' grids do not expect #Destroyed messages and blow-up.
'
'	XgrAddMessage (grid, #Destroyed, func, 0, 0, 0, 0, 0)
'
'
' destroy the grid and graphics context, no events or messages expected
'
	IF (gridType = 1) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XFreeGC (sdisplay, gc)
		XFreePixmap (sdisplay, swindow)
		DispatchEvents ($$TRUE, $$FALSE)
		##WHOMASK = whomask
		##LOCKOUT = lockout
	ELSE
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XFreeGC (sdisplay, gc)
		XDestroyWindow (sdisplay, swindow)
		DispatchEvents ($$TRUE, $$FALSE)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
'
	XgrProcessMessages (-2)
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
	window[grid].window = 0				' mark window/grid available
'	a$ = "XgrDestroyGrid().Z : " + STRING$(grid) + "\n"
'	write (1, &a$, LEN(a$))
END FUNCTION
'
'
' #################################
' #####  XgrGetGridBorder ()  #####
' #################################
'
FUNCTION  XgrGetGridBorder (grid, @border, @borderUp, @borderDown, @borderFlags)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBorder() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	border = window[window].border
	borderUp = window[window].borderUp
	borderDown = window[window].borderDown
	borderFlags = 0
END FUNCTION
'
'
' #######################################
' #####  XgrGetGridBorderOffset ()  #####
' #######################################
'
FUNCTION  XgrGetGridBorderOffset (grid, @left, @top, @right, @bottom)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBorderOffset() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	left = window[window].borderOffsetLeft
	top = window[window].borderOffsetTop
	right = window[window].borderOffsetRight
	bottom = window[window].borderOffsetBottom
END FUNCTION
'
'
' #################################
' #####  XgrGetGridBuffer ()  #####
' #################################
'
FUNCTION  XgrGetGridBuffer (grid, buffer, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	buffer = 0
	window = grid
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridBuffer() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	buffer = window[window].buffer
	x = window[window].bufferX
	y = window[window].bufferY
'
	IF buffer THEN
		IF InvalidGrid (buffer) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrGetGridBuffer() : invalid buffer grid #"
			RETURN ($$TRUE)
		END IF
'
		gt = window[buffer].type
		IF (gt != #GridTypeBuffer) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalidType
			IF debug THEN PRINT "XgrGetGridBuffer() : buffer grid type != #GridTypeImage"
			RETURN ($$TRUE)
		END IF
	END IF
END FUNCTION
'
'
' ############################################
' #####  XgrGetGridCharacterMapArray ()  #####
' ############################################
'
FUNCTION  XgrGetGridCharacterMapArray (grid, map[])
	SHARED  WINDOW  window[]
	SHARED  charMap[]
	SHARED  debug
'
	DIM map[]
'
' grid = 0 returns default character map array from grid # 0, so grid # 0 is valid
'
	IF grid THEN
		IF InvalidGrid (grid) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrGetGridCharacterMapArray() : invalid grid #"; grid
			RETURN ($$TRUE)
		END IF
	END IF
'
	u = UBOUND (charMap[])								' how big is char map array
	IF (u >= grid) THEN										' if big enough for this grid
		IF charMap[grid,] THEN							' if char map defined for this grid
			uu = UBOUND (charMap[grid,])			' what is last element
			DIM map[uu]												' create map array
			FOR i = 0 TO uu										' for all chars
				map[i] = charMap[grid,i]				' copy char
			NEXT i														' next
		END IF
	END IF
END FUNCTION
'
'
' ######################################
' #####  XgrGetGridDrawingMode ()  #####
' ######################################
'
FUNCTION  XgrGetGridDrawingMode (grid, @drawMode, @lineStyle, @lineWidth)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridDrawingMode() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	drawMode = window[window].drawMode
	lineStyle = window[window].lineStyle
	lineWidth = window[window].lineWidth
END FUNCTION
'
'
' ###############################
' #####  XgrGetGridFont ()  #####
' ###############################
'
FUNCTION  XgrGetGridFont (grid, @font)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridFont() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	font = window[window].font
END FUNCTION
'
'
' ###################################
' #####  XgrGetGridFunction ()  #####
' ###################################
'
FUNCTION  XgrGetGridFunction (grid, @gridFunc)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridFunction() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	gridFunc = window[window].gridFunc
END FUNCTION
'
'
' #################################
' #####  XgrGetGridParent ()  #####
' #################################
'
FUNCTION  XgrGetGridParent (grid, @parent)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridParent() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	parent = window[window].parent
END FUNCTION
'
'
' ################################
' #####  XgrGetGridState ()  #####
' ################################
'
FUNCTION  XgrGetGridState (grid, @state)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridState() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	state = window[window].state
END FUNCTION
'
'
'
' ###############################
' #####  XgrGetGridType ()  #####
' ###############################
'
FUNCTION  XgrGetGridType (grid, @gridType)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridType() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	gridType = window[window].type
END FUNCTION
'
'
' #################################
' #####  XgrGetGridWindow ()  #####
' #################################
'
FUNCTION  XgrGetGridWindow (grid, @window)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetGridWindow() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = window[grid].top
END FUNCTION
'
'
' ########################################
' #####  XgrGridTypeNameToNumber ()  #####
' ########################################
'
FUNCTION  XgrGridTypeNameToNumber (gridType$, @gridType)
	SHARED  lastGridType
	SHARED  gridType$[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ gridType$[] THEN
		##WHOMASK = 0
		DIM gridType$[15]
		gridType$[0] = "Coordinate"
		gridType$[1] = "Image"
		##WHOMASK = whomask
	END IF
'
	IF (gridType$ = "LastGridType") THEN
		gridType = lastGridType
		RETURN ($$FALSE)
	END IF
'
	upper = UBOUND (gridType$[])
'
	FOR gridType = 0 TO upper
		IF gridType$[gridType] THEN
			IF (gridType$ = gridType$[gridType]) THEN EXIT FOR
		END IF
	NEXT gridType
'
	IF (gridType > upper) THEN gridType = -1
END FUNCTION
'
'
' ########################################
' #####  XgrGridTypeNumberToName ()  #####
' ########################################
'
FUNCTION  XgrGridTypeNumberToName (gridType, @gridType$)
	SHARED  gridType$[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ gridType$[] THEN
		##WHOMASK = 0
		DIM gridType$[15]
		gridType$[0] = "Coordinate"
		gridType$[1] = "Image"
		##WHOMASK = whomask
	END IF
'
	gridType$ = ""
	upper = UBOUND (gridType$[])
	IF (gridType < 0) THEN RETURN ($$FALSE)
	IF (gridType > upper) THEN RETURN ($$FALSE)
	gridType$ = gridType$[gridType]
END FUNCTION
'
'
' ####################################
' #####  XgrRegisterGridType ()  #####
' ####################################
'
FUNCTION  XgrRegisterGridType (gridType$, @gridType)
	SHARED  lastGridType
	SHARED  gridType$[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ gridType$[] THEN
		##WHOMASK = 0
		DIM gridType$[15]
		gridType$[0] = "Coordinate"
		gridType$[1] = "Image"
		##WHOMASK = whomask
		lastGridType = 1
	END IF
'
	slot = -1
	upper = UBOUND (gridType$[])
'
	IF (gridType$ = "LastGridType") THEN
		gridType = lastGridType
		RETURN ($$FALSE)
	END IF
'
	FOR gridType = 0 TO upper
		IFZ gridType$[gridType] THEN
			IF (slot = -1) THEN slot = gridType
		ELSE
			IF (gridType$ = gridType$[gridType]) THEN EXIT FOR
		END IF
	NEXT gridType
'
	IF (gridType > upper) THEN
		IF (slot < 0) THEN
			upper = upper + 16
			##WHOMASK = 0
			REDIM gridType$[upper]
			##WHOMASK = whomask
		ELSE
			gridType = slot
		END IF
		##WHOMASK = 0
		gridType$[gridType] = gridType$
		##WHOMASK = whomask
	END IF
'
	IF (gridType > lastGridType) THEN lastGridType = gridType
END FUNCTION
'
'
' #################################
' #####  XgrSetGridBorder ()  #####
' #################################
'
FUNCTION  XgrSetGridBorder (grid, border, borderUp, borderDown, borderFlags)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridBorder() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IF (border != -1) THEN window[window].border = border
	IF (borderUp != -1) THEN window[window].borderUp = borderUp
	IF (borderDown != -1) THEN window[window].borderDown = borderDown
END FUNCTION
'
'
' #######################################
' #####  XgrSetGridBorderOffset ()  #####
' #######################################
'
FUNCTION  XgrSetGridBorderOffset (grid, left, top, right, bottom)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridBorderOffset() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].borderOffsetLeft = left
	window[window].borderOffsetTop = top
	window[window].borderOffsetRight = right
	window[window].borderOffsetBottom = bottom
END FUNCTION
'
'
' #################################
' #####  XgrSetGridBuffer ()  #####
' #################################
'
FUNCTION  XgrSetGridBuffer (grid, buffer, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridBuffer() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IF buffer THEN
		IF InvalidGrid (buffer) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrSetGridBuffer() : invalid grid #"; grid
			RETURN ($$TRUE)
		END IF
'
		gt = window[buffer].type
		IF (gt != #GridTypeBuffer) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalidType
			IF debug THEN PRINT "XgrSetGridBuffer() : buffer grid type != #GridTypeImage"
			RETURN ($$TRUE)
		END IF
	END IF
'
	window = grid
	window[window].bufferX = x
	window[window].bufferY = y
	window[window].buffer = buffer
END FUNCTION
'
'
' ######################################
' #####  XgrSetGridDrawingMode ()  #####
' ######################################
'
FUNCTION  XgrSetGridDrawingMode (grid, drawMode, lineStyle, lineWidth)
	SHARED  WINDOW  window[]
	SHARED  debug
	STATIC  UBYTE  dash[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridDrawingMode() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ dash[] THEN
		##WHOMASK = 0
		DIM dash[7]
		##WHOMASK = whomask
	END IF
'
	window = grid
	gc = window[window].gc
	sdisplay = window[window].sdisplay
'
' set drawing mode if changed and valid drawMode
'
	IF (drawMode != -1) THEN
		IF (drawMode != window[window].drawMode) THEN
			mode = -1
			SELECT CASE drawMode
				CASE $$DrawModeSET	: mode = $$GXCopy	: submode = $$ClipByChildren
				CASE $$DrawModeXOR	: mode = $$GXXor	: submode = $$IncludeInferiors
				CASE $$DrawModeAND	: mode = $$GXAnd	: submode = $$ClipByChildren
				CASE $$DrawModeOR		: mode = $$GXOr		: submode = $$ClipByChildren
			END SELECT
			IF (mode != -1) THEN
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				XSetFunction (sdisplay, gc, mode)
				XSetSubwindowMode (sdisplay, gc, submode)
				##LOCKOUT = lockout
				##WHOMASK = whomask
				window[window].drawMode = drawMode
			END IF
		END IF
	END IF
'
' set lineStyle and lineWidth if changed and valid values
'
	change = $$FALSE						' change requires XSetLineAttributes()
'
	IF (lineStyle < 0) THEN lineStyle = window[window].lineStyle
	IF (lineStyle > $$LineStyleMax) THEN lineStyle = $$LineStyleSolid
	IF (lineStyle != window[window].lineStyle) THEN
		window[window].lineStyle = lineStyle
		change = $$TRUE
	END IF
'
	SELECT CASE lineStyle
		CASE $$LineStyleSolid				: slineStyle = $$XLineSolid
																	dash[0] = 255 : dash[1] = 0 : dash[2] = 255 : dash[3] = 0
																	n = 2
		CASE $$LineStyleDash				: slineStyle = $$XLineOnOffDash
																	dash[0] = 3 : dash[1] = 3 : dash[2] = 3 : dash[3] = 3
																	n = 2
		CASE $$LineStyleDot					: slineStyle = $$XLineOnOffDash
																	dash[0] = 1 : dash[1] = 3 : dash[2] = 1 : dash[3] = 3
																	n = 2
		CASE $$LineStyleDashDot			: slineStyle = $$XLineOnOffDash
																	dash[0] = 3 : dash[1] = 3 : dash[2] = 1 : dash[3] = 3
																	n = 4
		CASE $$LineStyleDashDotDot	: slineStyle = $$XLineOnOffDash
																	dash[0] = 3 : dash[1] = 3 : dash[2] = 1 : dash[3] = 2 : dash[4] = 1 : dash[5] = 2
																	n = 6
	END SELECT
'
	IF (lineStyle != $$LineStyleSolid) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetDashes (sdisplay, gc, 0, &dash[], n)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
'
	IF (lineWidth < 0) THEN lineWidth = 0
'
	IF (lineWidth != window[window].lineWidth) THEN
		window[window].lineWidth = lineWidth
		change = $$TRUE
	END IF
'
	IF change THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetLineAttributes (sdisplay, gc, lineWidth, slineStyle, $$CapButt, $$JoinRound)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ###############################
' #####  XgrSetGridFont ()  #####
' ###############################
'
FUNCTION  XgrSetGridFont (grid, font)
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridFont() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IF InvalidFont (font) THEN
		##ERROR = ($$ErrorObjectFont << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridFont() : invalid font #"
		RETURN ($$TRUE)
	END IF
'
	window = grid
	gc = window[window].gc
	sfont = font[font].sfont
	window[window].font = font
	sdisplay = window[window].sdisplay
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSetFont (sdisplay, gc, sfont)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###################################
' #####  XgrSetGridFunction ()  #####
' ###################################
'
FUNCTION  XgrSetGridFunction (grid, gridFunc)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridFunction() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].gridFunc = gridFunc
END FUNCTION
'
'
' #################################
' #####  XgrSetGridParent ()  #####
' #################################
'
FUNCTION  XgrSetGridParent (grid, parent)
	PRINT "XgrSetGridParent() : unimplemented"
END FUNCTION
'
'
' ################################
' #####  XgrSetGridState ()  #####
' ################################
'
FUNCTION  XgrSetGridState (grid, state)
	SHARED  WINDOW  window[]
	SHARED  noExpose
	SHARED  debug
'
	IF #trace THEN PRINT "XgrSetGridState() : "; grid, state
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridState() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	old = window[window].state
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	window[window].state = state
'
	IF old THEN
		IFZ state THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XUnmapWindow (sdisplay, swindow)		' from enable to disable
			DispatchEvents ($$TRUE, $$FALSE)
			##LOCKOUT = lockout
			##WHOMASK = whomask
		END IF
	ELSE
		IF state THEN
			noExpose = window
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XMapWindow (sdisplay, swindow)			' from disable to enable
			DispatchEvents ($$TRUE, $$FALSE)
			##LOCKOUT = lockout
			##WHOMASK = whomask
			noExpose = 0
		END IF
	END IF
END FUNCTION
'
'
' ################################
' #####  XgrSetGridTimer ()  #####
' ################################
'
' Must be a one-shot else run the risk of filling the queue.
' SetTimer() resets timer, so KillTimer() is called after every timeout.
' SetTimer() second arg is the timerID used in KillTimer() = grid.
'	This will cause problems if grid numbers exceed 0xFFFF.
' SetTimer() WM_Timer message goes into application queue in this usage.
'
FUNCTION  XgrSetGridTimer (grid, msec)
	SHARED  WINDOW  window[]
	SHARED  debug
'
'	PRINT "XgrSetGridTimer().A : "; grid;; timer;; msec;; error
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridTimer() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid														' window is grid #
	timer = window[grid].timer							' current timer #
	window[grid].timer = $$FALSE						' timer invalid
	IF timer THEN XstKillTimer (timer)			' kill timer
'
' install new grid timer
'
	IF (msec > 0) THEN
		error = XstStartTimer (@timer, 1, msec, &XxxXgrGridTimer())
'		PRINT "XgrSetGridTimer().B : "; grid;; timer;; msec;; error
		IFZ error THEN window[grid].timer = timer
'		a$ = "\"" + STRING$(grid) + "." + STRING$(timer) + "." + STRING$(msec) + "." + STRING$(error) + "\""
'		write (1, &a$, LEN(a$))
	END IF
'	PRINT "XgrSetGridTimer().Z : "; grid;; timer;; msec;; error
	RETURN (error)
END FUNCTION
'
'
' ###############################
' #####  XgrSetGridType ()  #####
' ###############################
'
FUNCTION  XgrSetGridType (grid, gridType)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetGridType() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IF InvalidGridType (gridType) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrSetGridType() : invalid (unregistered) grid type"
		RETURN ($$TRUE)
	END IF
'
	nowType = window[window].type
'
	IF (gridType = #GridTypeImage) THEN
		IF (nowType != #GridTypeImage) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalidType
			IF debug THEN PRINT "XgrSetGridType() : attempt to change gridType to image grid"
			RETURN ($$TRUE)
		END IF
	ELSE
		IF (nowType = #GridTypeImage) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalidType
			IF debug THEN PRINT "XgrSetGridType() : attempt to change gridType from image grid"
			RETURN ($$TRUE)
		END IF
	END IF
'
	window = grid
	window[window].type = gridType
END FUNCTION
'
'
' ############################################
' #####  XgrSetGridCharacterMapArray ()  #####
' ############################################
'
FUNCTION  XgrSetGridCharacterMapArray (grid, map[])
	SHARED  WINDOW  window[]
	SHARED  charMap[]
	SHARED  debug
'
	whomask = ##WHOMASK
'
' grid = 0 sets default character map array, so grid # 0 is a valid grid #
'
	IF grid THEN
		IF InvalidGrid (grid) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrSetGridCharacterMapArray() : invalid grid #"; grid
			RETURN ($$TRUE)
		END IF
	END IF
'
	u = UBOUND (charMap[])								' how big is char map array
	IF (u < grid) THEN										' if not big enough for this grid
		u = (grid + 0xFF) OR 0xFF						' make new charMap[] upper bound higher
		##WHOMASK = 0												'
		DIM charMap[u,]											' increase charMap[] upper bound
		##WHOMASK = whomask									'
	END IF
'
	ATTACH charMap[grid,] TO temp[]				' remove existing map array
	DIM temp[]														' default = not char map array
'
	IF map[] THEN													' if defining a char map array
		u = UBOUND (map[])									' how many elements
		IF (u < 255) THEN u = 255						' at least 255
		##WHOMASK = 0												'
		DIM temp[u]													' create new char map array
		##WHOMASK = whomask									'
		FOR i = 0 TO u											' for all characters
			temp[i] = i												' default char is itself
		NEXT i															'
		u = UBOUND (map[])									' upper map array element
		FOR i = 0 TO u											' for all map array elements
			temp[i] = map[i]									' transfer char map char
		NEXT i															'
		ATTACH temp[] TO charMap[grid,]			' install new char map array
	END IF																'
END FUNCTION
'
'
' #############################
' #####  XgrClearGrid ()  #####
' #############################
'
FUNCTION  XgrClearGrid (grid, color)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED	debug
'
	IF #trace THEN PRINT "XgrClearGrid() : "; grid, color
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrClearGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	gc = window[window].gc
	width = window[window].width
	height = window[window].height
	buffer = window[window].buffer
	swindow = window[window].swindow
	display = window[window].display
	colormap = display[display].colormap
	sdisplay = display[display].sdisplay
	sbackground = window[window].sbackground
	sforeground = window[window].sforeground
	scolor = sbackground
	xcolor = color
'
	IF (color = $$DefaultColor) THEN color = window[window].backgroundColor
	ConvertColorToSystemColor (window, color, @scolor)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, 0, 0, width-1, height-1, @bx1, @by1, @bx2, @by2)
		bwidth = bx2 - bx1 + 1
		bheight = by2 - by1 + 1
	END IF
'
	IF (scolor = sforeground) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XFillRectangle (sdisplay, swindow, gc, 0, 0, width, height)
		IF sbuffer THEN XFillRectangle (sdisplay, sbuffer, gc, bx1, by1, bwidth, bheight)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	ELSE
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetForeground (sdisplay, gc, scolor)
		XFillRectangle (sdisplay, swindow, gc, 0, 0, width, height)
		IF sbuffer THEN XFillRectangle (sdisplay, sbuffer, gc, bx1, by1, bwidth, bheight)
		XSetForeground (sdisplay, gc, sforeground)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ###############################
' #####  XgrClearWindow ()  #####
' ###############################
'
FUNCTION  XgrClearWindow (window, color)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF #trace THEN PRINT "XgrClearWindow() : "; window, color
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrClearWindow() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	grid = window
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	gc = window[window].gc
	width = window[window].width
	height = window[window].height
	buffer = window[window].buffer
	swindow = window[window].swindow
	display = window[window].display
	colormap = display[display].colormap
	sdisplay = display[display].sdisplay
	sbackground = window[window].sbackground
	sforeground = window[window].sforeground
	scolor = sbackground
'
	IF (color = $$DefaultColor) THEN color = window[window].backgroundColor
	ConvertColorToSystemColor (grid, color, @scolor)
	window[window].sbackground = scolor
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, 0, 0, width-1, height-1, @bx1, @by1, @bx2, @by2)
		bwidth = bx2 - bx1 + 1
		bheight = by2 - by1 + 1
	END IF
'
	IF (scolor = sforeground) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XFillRectangle (sdisplay, swindow, gc, 0, 0, width, height)
		IF sbuffer THEN XFillRectangle (sdisplay, sbuffer, gc, bx1, by1, bwidth, bheight)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	ELSE
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetForeground (sdisplay, gc, scolor)
		XFillRectangle (sdisplay, swindow, gc, 0, 0, width, height)
		IF sbuffer THEN XFillRectangle (sdisplay, sbuffer, gc, bx1, by1, bwidth, bheight)
		XSetForeground (sdisplay, gc, sforeground)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ###########################
' #####  XgrDrawArc ()  #####
' ###########################
'
FUNCTION  XgrDrawArc (grid, color, r, startAngle#, endAngle#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawArc() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	x = window[window].drawpointX				' drawpoint is center of curvature
	y = window[window].drawpointY				' ditto
	x1 = x - r
	y1 = y - r
	x2 = x + r
	y2 = y + r
'
	IF (x2 < x1) THEN SWAP x1, x2
	IF (y2 < y1) THEN SWAP y1, y2
	ww = x2 - x1
	hh = y2 - y1
'
	NormalAngle (@startAngle#)
	NormalAngle (@endAngle#)
'
	IF (endAngle# < startAngle#) THEN endAngle# = endAngle# + $$TWOPI
	deltaAngle# = endAngle# - startAngle#
'
	startAngle = startAngle# * $$RADTODEG * 64#
	deltaAngle = deltaAngle# * $$RADTODEG * 64#
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x1, y1, x2, y2, @bx1, @by1, @bx2, @by2)
		bwidth = bx2 - bx1 + 1
		bheight = by2 - by1 + 1
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawArc (sdisplay, swindow, gc, x1, y1, ww, hh, startAngle, deltaAngle)
	IF sbuffer THEN XDrawArc (sdisplay, sbuffer, gc, bx1, by1, bwidth, bheight, startAngle, deltaAngle)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###############################
' #####  XgrDrawArcGrid ()  #####
' ###############################
'
FUNCTION  XgrDrawArcGrid (grid, color, r, startAngle#, endAngle#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawArcGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	xGrid = window[window].drawpointGridX
	yGrid = window[window].drawpointGridY
'
	XgrConvertGridToLocal (window, xGrid, yGrid, @x, @y)
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
'
	window[window].drawpointX = x
	window[window].drawpointY = y
'
	return = XgrDrawArc (grid, color, r, startAngle#, endAngle#)
'
	window[window].drawpointX = xx
	window[window].drawpointY = yy
	RETURN (return)
END FUNCTION
'
'
' #################################
' #####  XgrDrawArcScaled ()  #####
' #################################
'
FUNCTION  XgrDrawArcScaled (grid, color, r#, startAngle#, endAndge#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawArcGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	x# = window[window].drawpointScaledX
	y# = window[window].drawpointScaledY
'
	XgrConvertScaledToLocal (window, x#, y#, @x, @y)
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
'
	window[window].drawpointX = x
	window[window].drawpointY = y
'
	return = XgrDrawArc (grid, color, r, startAngle#, endAngle#)
'
	window[window].drawpointX = xx
	window[window].drawpointY = yy
	RETURN (return)
END FUNCTION
'
'
' ##############################
' #####  XgrDrawBorder ()  #####
' ##############################
'
FUNCTION  XgrDrawBorder (grid, border, back, lo, hi, x1, y1, x2, y2)
	SHARED  WINDOW  window[]
	SHARED  borderWidth[]
	SHARED  border$[]
	SHARED  debug
	STATIC  points[]
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawBorder() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	upper = UBOUND (border$[])
	IFZ points[] THEN GOSUB Initialize
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
	lot = window[window].lowtextColor
	hit = window[window].hightextColor
	IF (lo = -1) THEN lo = window[window].lowlightColor
	IF (hi = -1) THEN hi = window[window].highlightColor
	IF (back = -1) THEN back = window[window].backgroundColor
	IF ((border < 0) OR (border > $$BorderUpper)) THEN border = window[window].border
'
	IF ((border < 0) OR (border > upper)) THEN
		func = border
		valid = $$FALSE
		IF ((func > ##CODE) AND (func < ##CODEZ)) THEN valid = $$TRUE
		IF ((func > ##UCODE) AND (func < ##UCODEZ)) THEN valid = $$TRUE
		IF valid THEN return = @func (window, border, back, lo, hi, x1, y1, x2, y2)
		window[window].drawpointX = xx
		window[window].drawpointY = yy
		RETURN (return)
	END IF
'
	return = $$FALSE
	SELECT CASE border
		CASE $$BorderNone																				: RETURN
		CASE $$BorderFlat1																			: GOSUB Flat1
		CASE $$BorderFlat2																			: GOSUB Flat2
		CASE $$BorderFlat4																			: GOSUB Flat4
		CASE $$BorderHiLine1	: lo = hi													: GOSUB Raise1
		CASE $$BorderHiLine2	: lo = hi													: GOSUB Raise2
		CASE $$BorderHiLine4	: lo = hi													: GOSUB Raise4
		CASE $$BorderLoLine1	: hi = lo													: GOSUB Raise1
		CASE $$BorderLoLine2	: hi = lo													: GOSUB Raise2
		CASE $$BorderLoLine4	: hi = lo													: GOSUB Raise4
		CASE $$BorderLower1		: SWAP hi, lo											: GOSUB Raise1
		CASE $$BorderLower2		: SWAP hi, lo											: GOSUB Raise2
		CASE $$BorderLower4		: SWAP hi, lo											: GOSUB Raise4
		CASE $$BorderRaise1																			: GOSUB Raise1
		CASE $$BorderRaise2																			: GOSUB Raise2
		CASE $$BorderRaise4																			: GOSUB Raise4
		CASE $$BorderFrame																			: GOSUB Frame
		CASE $$BorderDrain		: SWAP hi, lo											: GOSUB Frame
		CASE $$BorderRidge																			: GOSUB Ridge
		CASE $$BorderValley																			: GOSUB Valley
		CASE $$BorderWide																				: GOSUB Wide
		CASE $$BorderWideResize																	: GOSUB WideResize
		CASE $$BorderWindow																			: GOSUB Window
		CASE $$BorderWindowResize																: GOSUB WindowResize
		CASE $$BorderRise2																			: GOSUB DrawBorderRise2
		CASE $$BorderSink2		: SWAP hi, lo		: SWAP hit, lot		: GOSUB DrawBorderRise2
	END SELECT
'
	window[window].drawpointX = xx					' restore drawpoint
	window[window].drawpointY = yy					' ditto
	RETURN (return)
'
'
' *****  Flat1  *****  Flat
'
SUB Flat1
	hi	= back
	lo	= back
	GOSUB DrawBorder1
END SUB
'
'
' *****  Flat2  *****  Flat2
'
SUB Flat2
	hi	= back
	lo	= back
	n		= 2
	GOSUB DrawBorderN
END SUB
'
'
' *****  Flat4  *****  Flat4
'
SUB Flat4
	hi	= back
	lo	= back
	n		= 4
	GOSUB DrawBorderN
END SUB
'
'
' *****  Raise1  *****  Up = 1
'
SUB Raise1
	GOSUB DrawBorder1
END SUB
'
'
' *****  Raise2  *****  Up = 2
'
SUB Raise2
	n		= 2
	GOSUB DrawBorderN
END SUB
'
'
' *****  Raise4  *****  Up = 4
'
SUB Raise4
	n		= 4
	GOSUB DrawBorderN
END SUB
'
'
' *****  Frame  *****  Up = 1, Flat = width-2, Down = 1  *****
'
SUB Frame
	GOSUB DrawBorder1												' draw up-slope outside
	xhi	= hi
	xlo	= lo
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= back															' flat
	lo	= back															' flat
	n		= 2																	' flat is 2 pixels wide
	GOSUB DrawBorderN												' draw flat
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= xlo																' reverse hi : lo
	lo	= xhi																' reverse hi : lo
	GOSUB DrawBorder1												' draw down-slope inside
END SUB
'
'
' *****  Ridge  *****  Looks simple, to draw is complex
'
SUB Ridge
	points[0] = x1 + 1	: points[1] = y2				' Line 0
	points[2] = x1 + 1	: points[3] = y1 + 1
	points[4] = x1 + 1	: points[5] = y1 + 1		' Line 1
	points[6] = x2			: points[7] = y1 + 1
	points[8] = x2			: points[9] = y1 + 1		' Line 2
	points[10] = x2			: points[11] = y2
	points[12] = x2			: points[13] = y2				' Line 3
	points[14] = x1 + 1	: points[15] = y2
	XgrDrawLines (window, lo, 0, 4, @points[])
	points[0] = x1			: points[1] = y2 - 1		' Line 0
	points[2] = x1			: points[3] = y1
	points[4] = x1			: points[5] = y1				' Line 1
	points[6] = x2 - 1	: points[7] = y1
	points[8] = x2 - 1	: points[9] = y1				' Line 2
	points[10] = x2 - 1	: points[11] = y2 - 1
	points[12] = x2 - 1	: points[13] = y2 - 1		' Line 3
	points[14] = x1			: points[15] = y2 - 1
	XgrDrawLines (window, hi, 0, 4, @points[])
END SUB
'
'
' *****  Valley  *****  Looks simple, to draw is complex
'
SUB Valley
	points[0] = x1			: points[1] = y2				' Line 0
	points[2] = x1			: points[3] = y1
	points[4] = x1			: points[5] = y1				' Line 1
	points[6] = x2			: points[7] = y1
	points[8] = x2 - 1	: points[9] = y1 + 2		' Line 2
	points[10] = x2 - 1	: points[11] = y2 - 1
	points[12] = x2 - 1	: points[13] = y2 - 1		' Line 3
	points[14] = x1 + 2	: points[15] = y2 - 1
	XgrDrawLines (window, lo, 0, 4, @points[])
	points[0] = x1 + 1	: points[1] = y2				' Line 0
	points[2] = x1 + 1	: points[3] = y1 + 1
	points[4] = x1 + 1	: points[5] = y1 + 1		' Line 1
	points[6] = x2			: points[7] = y1 + 1
	points[8] = x2			: points[9] = y1 + 1		' Line 2
	points[10] = x2			: points[11] = y2
	points[12] = x2			: points[13] = y2				' Line 3
	points[14] = x1 + 1	: points[15] = y2
	XgrDrawLines (window, hi, 0, 4, @points[])
END SUB
'
'
' *****  Wide  *****  up = 1, flat = 4, down = 1
'
SUB Wide
	GOSUB DrawBorder1												' draw up-slope outside
	xhi	= hi
	xlo	= lo
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= back															' flat
	lo	= back															' flat
	n		= 4																	' flat is 4 pixels wide
	GOSUB DrawBorderN												' draw flat
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= xlo																' reverse hi : lo
	lo	= xhi																' reverse hi : lo
	GOSUB DrawBorder1												' draw down-slope inside
END SUB
'
'
' *****  WideResize  *****  up = 1, flat = 4, down = 1, resize corner marks
'
SUB WideResize
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB Wide
'
' draw resize corner marks - 8 dark marks, then 8 light marks
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
	points[0] = x1+25		: points[1] = y1+1
	points[2] = x1+25		: points[3] = y1+4
	points[4] = x2-26		: points[5] = y1+1
	points[6] = x2-26		: points[7] = y1+4
	points[8] = x2-4		: points[9] = y1+25
	points[10] = x2-1		: points[11] = y1+25
	points[12] = x2-4		: points[13] = y2-26
	points[14] = x2-1		: points[15] = y2-26
	points[16] = x2-26	: points[17] = y2-1
	points[18] = x2-26	: points[19] = y2-4
	points[20] = x1+25	: points[21] = y2-1
	points[22] = x1+25	: points[23] = y2-4
	points[24] = x1+1		: points[25] = y2-26
	points[26] = x1+4		: points[27] = y2-26
	points[28] = x1+1		: points[29] = y1+25
	points[30] = x1+4		: points[31] = y1+25
	XgrDrawLines (window, lo, 0, 8, @points[])
'
	points[0] = x1+26		: points[1] = y1+1
	points[2] = x1+26		: points[3] = y1+4
	points[4] = x2-25		: points[5] = y1+1
	points[6] = x2-25		: points[7] = y1+4
	points[8] = x2-4		: points[9] = y1+26
	points[10] = x2-1		: points[11] = y1+26
	points[12] = x2-4		: points[13] = y2-25
	points[14] = x2-1		: points[15] = y2-25
	points[16] = x2-25	: points[17] = y2-4
	points[18] = x2-25	: points[19] = y2-1
	points[20] = x1+26	: points[21] = y2-4
	points[22] = x1+26	: points[23] = y2-1
	points[24] = x1+1		: points[25] = y2-25
	points[26] = x1+4		: points[27] = y2-25
	points[28] = x1+1		: points[29] = y1+26
	points[30] = x1+4		: points[31] = y1+26
	XgrDrawLines (window, hi, 0, 8, @points[])
END SUB
'
'
' *****  WindowFrame  *****
'
SUB WindowFrame
	GOSUB DrawBorder1												' draw up-slope outside
	xhi	= hi
	xlo	= lo
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= back															' flat
	lo	= back															' flat
	n		= 2																	' flat is 2 pixels wide
	GOSUB DrawBorderN												' draw flat
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= xlo																' reverse hi : lo
	lo	= xhi																' reverse hi : lo
	GOSUB DrawBorder1												' draw down-slope inside
END SUB
'
'
' *****  WindowFrameResize  *****
'
SUB WindowFrameResize
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB WindowFrame
'
' draw resize corner marks - 8 dark marks, then 8 light marks
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
'
	points[0] = x1+23		: points[1] = y1+0
	points[2] = x1+23		: points[3] = y1+3
	points[4] = x2-24		: points[5] = y1+0
	points[6] = x2-24		: points[7] = y1+3
	points[8] = x2-3		: points[9] = y1+23
	points[10] = x2-0		: points[11] = y1+23
	points[12] = x2-3		: points[13] = y2-24
	points[14] = x2-0		: points[15] = y2-24
	points[16] = x2-24	: points[17] = y2-0
	points[18] = x2-24	: points[19] = y2-3
	points[20] = x1+23	: points[21] = y2-0
	points[22] = x1+23	: points[23] = y2-3
	points[24] = x1+0		: points[25] = y2-24
	points[26] = x1+3		: points[27] = y2-24
	points[28] = x1+0		: points[29] = y1+23
	points[30] = x1+3		: points[31] = y1+23
	XgrDrawLines (grid, lo, 0, 8, @points[])
'
	points[0] = x1+24		: points[1] = y1+1
	points[2] = x1+24		: points[3] = y1+2
	points[4] = x2-23		: points[5] = y1+1
	points[6] = x2-23		: points[7] = y1+2
	points[8] = x2-3		: points[9] = y1+24
	points[10] = x2-0		: points[11] = y1+24
	points[12] = x2-3		: points[13] = y2-23
	points[14] = x2-0		: points[15] = y2-23
	points[16] = x2-23	: points[17] = y2-3
	points[18] = x2-23	: points[19] = y2-0
	points[20] = x1+24	: points[21] = y2-3
	points[22] = x1+24	: points[23] = y2-0
	points[24] = x1+0		: points[25] = y2-23
	points[26] = x1+3		: points[27] = y2-23
	points[28] = x1+0		: points[29] = y1+24
	points[30] = x1+3		: points[31] = y1+24
	XgrDrawLines (grid, hi, 0, 8, @points[])
END SUB
'
'
'
' *****  Window  *****
'
SUB Window
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB WindowFrame
'
' draw title bar - bright lines then dark lines
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
'
	points[0] = x1+4		: points[1] = y1+23
	points[2] = x2-4		: points[3] = y1+23
	points[4] = x2-4		: points[5] = y1+23
	points[6] = x2-4		: points[7] = y1+4
	XgrDrawLines (grid, lo, 0, 2, @points[])
'
	points[0] = x1+4		: points[1] = y1+4
	points[2] = x2-4		: points[3] = y1+4
	points[4] = x1+4		: points[5] = y1+4
	points[6] = x1+4		: points[7] = y1+23
	XgrDrawLines (grid, hi, 0, 2, @points[])
END SUB
'
'
' *****  WindowResize  *****
'
SUB WindowResize
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB WindowFrameResize
'
' draw title bar - bright lines then dark lines
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
'
	points[0] = x1+4		: points[1] = y1+23
	points[2] = x2-4		: points[3] = y1+23
	points[4] = x2-4		: points[5] = y1+23
	points[6] = x2-4		: points[7] = y1+4
	XgrDrawLines (grid, lo, 0, 2, @points[])
'
	points[0] = x1+4		: points[1] = y1+4
	points[2] = x2-4		: points[3] = y1+4
	points[4] = x1+4		: points[5] = y1+4
	points[6] = x1+4		: points[7] = y1+23
	XgrDrawLines (grid, hi, 0, 2, @points[])
END SUB
'
'
' an old version of this subroutine
'
' *****  WindowOld  *****  up = 2, flat = 4, down = 2
'
SUB WindowOld
	n		= 2																	' n = 2
	GOSUB DrawBorderN												' draw up-slope outside
	xhi	= hi																'
	xlo	= lo																'
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= back															' flat
	lo	= back															' flat
	n		= 4																	' flat is 4 pixels wide
	GOSUB DrawBorderN												' draw flat
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= xlo																' reverse hi : lo
	lo	= xhi																' reverse hi : lo
	n		= 2																	'
	GOSUB DrawBorderN												' draw down-slope inside
END SUB
'
' an old version of this subroutine
'
' *****  WindowResizeOld  *****  up = 2, flat = 4, down = 2, resize marks
'
SUB WindowResizeOld
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB Window
'
' draw resize corner marks - 8 dark marks, then 8 light marks
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
	points[0] = x1+25		: points[1] = y1+2
	points[2] = x1+25		: points[3] = y1+5
	points[4] = x2-26		: points[5] = y1+2
	points[6] = x2-26		: points[7] = y1+5
	points[8] = x2-5		: points[9] = y1+25
	points[10] = x2-2		: points[11] = y1+25
	points[12] = x2-5		: points[13] = y2-26
	points[14] = x2-2		: points[15] = y2-26
	points[16] = x2-26	: points[17] = y2-2
	points[18] = x2-26	: points[19] = y2-5
	points[20] = x1+25	: points[21] = y2-2
	points[22] = x1+25	: points[23] = y2-5
	points[24] = x1+2		: points[25] = y2-26
	points[26] = x1+5		: points[27] = y2-26
	points[28] = x1+2		: points[29] = y1+25
	points[30] = x1+5		: points[31] = y1+25
	XgrDrawLines (window, lo, 0, 8, @points[])
'
	points[0] = x1+26		: points[1] = y1+2
	points[2] = x1+26		: points[3] = y1+5
	points[4] = x2-25		: points[5] = y1+2
	points[6] = x2-25		: points[7] = y1+5
	points[8] = x2-5		: points[9] = y1+26
	points[10] = x2-2		: points[11] = y1+26
	points[12] = x2-5		: points[13] = y2-25
	points[14] = x2-2		: points[15] = y2-25
	points[16] = x2-25	: points[17] = y2-5
	points[18] = x2-25	: points[19] = y2-2
	points[20] = x1+26	: points[21] = y2-5
	points[22] = x1+26	: points[23] = y2-2
	points[24] = x1+2		: points[25] = y2-25
	points[26] = x1+5		: points[27] = y2-25
	points[28] = x1+2		: points[29] = y1+26
	points[30] = x1+5		: points[31] = y1+26
	XgrDrawLines (window, hi, 0, 8, @points[])
END SUB
'
'
' *****  DrawBorder1  *****  1 pixel wide border
'
SUB DrawBorder1
	points[0] = x1	: points[1] = y1		' left-edge
	points[2] = x1	: points[3] = y2
	points[4] = x1	: points[5] = y1		' top-edge
	points[6] = x2	: points[7] = y1
	XgrDrawLines (window, hi, 0, 2, @points[])
	points[0] = x2	: points[1] = y1		' right-edge
	points[2] = x2	: points[3] = y2
	points[4] = x1	: points[5] = y2		' bottom-edge
	points[6] = x2	: points[7] = y2
	XgrDrawLines (window, lo, 0, 2, @points[])
END SUB
'
'
' *****  DrawBorderN  *****  n pixel wide border - max 4 pixels wide
'
SUB DrawBorderN
	j = 0
	FOR i = 0 TO n - 1
		points[j    ] = x1 + i	: points[j + 1] = y2 - i			' left
		points[j + 2] = x1 + i	: points[j + 3] = y1 + i
		points[j + 4] = x1 + i	: points[j + 5] = y1 + i			' upper
		points[j + 6] = x2 - i	: points[j + 7] = y1 + i
		j = j + 8
	NEXT i
	XgrDrawLines (window, hi, 0, (n << 1), @points[])
	j = 0
	FOR i = 0 TO n - 1
		points[j    ] = x1 + i	: points[j + 1] = y2 - i			' right
		points[j + 2] = x2 - i	: points[j + 3] = y2 - i
		points[j + 4] = x2 - i	: points[j + 5] = y2 - i			' lower
		points[j + 6] = x2 - i	: points[j + 7] = y1 + i
		j = j + 8
	NEXT i
	XgrDrawLines (window, lo, 0, (n << 1), @points[])
END SUB
'
'
' *****  DrawBorderRise2  *****  2 pixel wide border with 2 dark and 2 bright colors
'
SUB DrawBorderRise2
	points[0] = x1		: points[1] = y1		' left-edge
	points[2] = x1		: points[3] = y2
	points[4] = x1		: points[5] = y1		' top-edge
	points[6] = x2		: points[7] = y1
	XgrDrawLines (grid, hi, 0, 2, @points[])
	points[0] = x1+1	: points[1] = y1+1	' left-edge
	points[2] = x1+1	: points[3] = y2-2
	points[4] = x1+1	: points[5] = y1+1	' top-edge
	points[6] = x2-2	: points[7] = y1+1
	XgrDrawLines (grid, hit, 0, 2, @points[])
'
	points[0] = x2		: points[1] = y1			' right-edge
	points[2] = x2		: points[3] = y2
	points[4] = x1		: points[5] = y2			' bottom-edge
	points[6] = x2		: points[7] = y2
	XgrDrawLines (grid, lo, 0, 2, @points[])
	points[0] = x2-1	: points[1] = y1+1		' right-edge
	points[2] = x2-1	: points[3] = y2-2
	points[4] = x1+1	: points[5] = y2-1		' bottom-edge
	points[6] = x2-1	: points[7] = y2-1
	XgrDrawLines (grid, lot, 0, 2, @points[])
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	##WHOMASK = 0
	DIM points[31]
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ##################################
' #####  XgrDrawBorderGrid ()  #####
' ##################################
'
FUNCTION  XgrDrawBorderGrid (grid, border, back, lo, hi, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawBorderGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertGridToLocal (window, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (window, x2Grid, y2Grid, @x2, @y2)
'
	return = XgrDrawBorder (window, border, back, lo, hi, x1, y1, x2, y2)
	RETURN (return)
END FUNCTION
'
'
' ####################################
' #####  XgrDrawBorderScaled ()  #####
' ####################################
'
FUNCTION  XgrDrawBorderScaled (grid, border, back, lo, hi, x1#, y1#, x2#, y2#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawBorderScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertScaledToLocal (window, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (window, x2#, y2#, @x2, @y2)
'
	return = XgrDrawBorder (window, border, back, lo, hi, x1, y1, x2, y2)
	RETURN (return)
END FUNCTION
'
'
' ###########################
' #####  XgrDrawBox ()  #####
' ###########################
'
FUNCTION  XgrDrawBox (grid, color, x1, y1, x2, y2)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawBox() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
'	*** SVG - check order on arguments, without changing values
'
	top = y1
	bottom = y2
	IF top > bottom THEN SWAP top, bottom
	left = x1
	right = x2
	IF right < left THEN SWAP left, right
'
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, left, top, right, bottom, @bx1, @by1, @bx2, @by2)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawRectangle (sdisplay, swindow, gc, left, top, right-left, bottom-top)
	IF sbuffer THEN XDrawRectangle (sdisplay, sbuffer, gc, bx1, by1, bx2-bx1, by2-by1)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###############################
' #####  XgrDrawBoxGrid ()  #####
' ###############################
'
FUNCTION  XgrDrawBoxGrid (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawBoxGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertGridToLocal (window, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (window, x2Grid, y2Grid, @x2, @y2)
'
	return = XgrDrawBox (window, color, x1, y1, x2, y2)
	RETURN (return)
END FUNCTION
'
'
' #################################
' #####  XgrDrawBoxScaled ()  #####
' #################################
'
FUNCTION  XgrDrawBoxScaled (grid, color, x1#, y1#, x2#, y2#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawBoxGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertScaledToLocal (window, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (window, x2#, y2#, @x2, @y2)
'
	return = XgrDrawBox (window, color, x1, y1, x2, y2)
	RETURN (return)
END FUNCTION
'
'
' ##############################
' #####  XgrDrawCircle ()  #####
' ##############################
'
FUNCTION  XgrDrawCircle (grid, color, r)
	' A circle is just an ellipse with equal X- and Y-radius.
	RETURN XgrDrawEllipse(grid, color, r, r)
END FUNCTION
'
'
' ###############################
' #####  XgrDrawEllipse ()  #####
' ###############################
'
'* Draw an ellipse.
' Note: The current drawing-point is used as the center of the ellipse.
' @param grid			The grid.
' @param color		The color in which to draw
' @param rx				The X-Radius
' @param ry				The Y-Radius
'
FUNCTION  XgrDrawEllipse (grid, color, rx, ry)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawCircle() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	buffer = window[window].buffer
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	gc = window[window].gc
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	x = window[window].drawpointX			' drawpoint is center of curvature
	y = window[window].drawpointY			' ditto
	x1 = x - rx
	y1 = y - ry
	x2 = x + rx
	y2 = y + ry
'
	IF (x2 < x1) THEN SWAP x1, x2
	IF (y2 < y1) THEN SWAP y1, y2
	ww = x2 - x1
	hh = y2 - y1
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x1, y1, x1, y1, @bx1, @by1, 0, 0)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawArc (sdisplay, swindow, gc, x1, y1, ww, hh, 0, 23040)
	IF sbuffer THEN XDrawArc (sdisplay, sbuffer, gc, bx1, bx2, ww, hh, 0, 23040)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ##################################
' #####  XgrDrawCircleGrid ()  #####
' ##################################
'
FUNCTION  XgrDrawCircleGrid (grid, color, r)
	RETURN XgrDrawEllipseGrid(grid, color, r, r)
END FUNCTION
'
'
' ###################################
' #####  XgrDrawEllipseGrid ()  #####
' ###################################
'
FUNCTION  XgrDrawEllipseGrid (grid, color, rx, ry)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xxGrid, @yyGrid)
	XgrConvertGridToLocal (grid, xxGrid, yyGrid, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawEllipse (grid, color, rx, ry)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ####################################
' #####  XgrDrawCircleScaled ()  #####
' ####################################
'
FUNCTION  XgrDrawCircleScaled (grid, color, r#)
	RETURN XgrDrawEllipseScaled(grid, color, r#, r#)
END FUNCTION
'
'
' #####################################
' #####  XgrDrawEllipseScaled ()  #####
' #####################################
'
FUNCTION  XgrDrawEllipseScaled (grid, color, rx#, ry#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
  XgrGetDrawpoint (grid, @xx, @yy)
  XgrGetDrawpointScaled (grid, @xx#, @yy#)
  XgrConvertScaledToLocal (grid, xx#, yy#, @x, @y)
  XgrConvertScaledToLocal (grid, xx# + rx#, yy# + ry#, @xr, @yr)
  xr = ABS (xr - x)
  yr = ABS (yr - y)
'
  XgrSetDrawpoint (grid, x, y)
  XgrDrawEllipse (grid, color, xr, yr)
  XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ##################################
' #####  XgrDrawGridBorder ()  #####
' ##################################
'
FUNCTION  XgrDrawGridBorder (grid, border)
	SHARED  WINDOW  window[]
	SHARED  borderWidth[]
	SHARED  border$[]
	SHARED  debug
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawGridBorder() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	low = window[window].lowlightColor
	high = window[window].highlightColor
	back = window[window].backgroundColor
	IF (border = -1) THEN border = window[window].border
'
	x1 = 0
	y1 = 0
	x2 = window[window].width - 1
	y2 = window[window].height - 1
'
	upper = UBOUND (border$[])
	IF ((border >= 0) AND (border <= upper)) THEN
		return = XgrDrawBorder (window, border, back, low, high, x1, y1, x2, y2)
	ELSE
		func = border
		valid = $$FALSE
		IF ((func > ##CODE) AND (func < ##CODEZ)) THEN valid = $$TRUE
		IF ((func > ##UCODE) AND (func < ##UCODEZ)) THEN valid = $$TRUE
		IF valid THEN return = @func (window, border, back, low, high, x1, y1, x2, y2)
	END IF
	RETURN (return)
END FUNCTION
'
'
' ############################
' #####  XgrDrawLine ()  #####
' ############################
'
FUNCTION  XgrDrawLine (grid, color, x1, y1, x2, y2)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLine() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	window[window].drawpointX = x2
	window[window].drawpointY = y2
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x1, y1, x2, y2, @bx1, @by1, @bx2, @by2)
		bwidth = bx2 - bx1 + 1
		bheight = by2 - by1 + 1
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawLine (sdisplay, swindow, gc, x1, y1, x2, y2)
	IF sbuffer THEN XDrawLine (sdisplay, sbuffer, gc, bx1, by1, bx2, by2)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ################################
' #####  XgrDrawLineGrid ()  #####
' ################################
'
FUNCTION  XgrDrawLineGrid (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLineGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointGridX = x2Grid
	window[window].drawpointGridY = y2Grid
'
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertGridToLocal (window, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (window, x2Grid, y2Grid, @x2, @y2)
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
'
	window[window].drawpointX = x
	window[window].drawpointY = y
'
	return = XgrDrawLine (window, color, x1, y1, x2, y2)
'
	window[window].drawpointX = xx
	window[window].drawpointY = yy
	RETURN (return)
END FUNCTION
'
'
' ##################################
' #####  XgrDrawLineScaled ()  #####
' ##################################
'
FUNCTION  XgrDrawLineScaled (grid, color, x1#, y1#, x2#, y2#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLineScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointScaledX = x2#
	window[window].drawpointScaledY = y2#
'
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertScaledToLocal (window, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (window, x2#, y2#, @x2, @y2)
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
'
	window[window].drawpointX = x
	window[window].drawpointY = y
'
	return = XgrDrawLine (window, color, x1, y1, x2, y2)
'
	window[window].drawpointX = xx
	window[window].drawpointY = yy
	RETURN (return)
END FUNCTION
'
'
' ##############################
' #####  XgrDrawLineTo ()  #####
' ##############################
'
FUNCTION  XgrDrawLineTo (grid, color, x2, y2)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLineTo() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
'
	x1 = window[window].drawpointX
	y1 = window[window].drawpointY
'
	return = XgrDrawLine (window, color, x1, y1, x2, y2)
	RETURN (return)
END FUNCTION
'
'
' ##################################
' #####  XgrDrawLineToGrid ()  #####
' ##################################
'
FUNCTION  XgrDrawLineToGrid (grid, color, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLineToGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
'
	x1Grid = window[window].drawpointGridX
	y1Grid = window[window].drawpointGridY
	window[window].drawpointGridX = x2Grid
	window[window].drawpointGridY = y2Grid
'
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertGridToLocal (window, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (window, x2Grid, y2Grid, @x2, @y2)
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
'
	return = XgrDrawLine (window, color, x1, y1, x2, y2)
'
	window[window].drawpointX = xx
	window[window].drawpointY = yy
	RETURN (return)
END FUNCTION
'
'
' ####################################
' #####  XgrDrawLineToScaled ()  #####
' ####################################
'
FUNCTION  XgrDrawLineToScaled (grid, color, x2#, y2#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLineToScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
'
	x1# = window[window].drawpointScaledX
	y1# = window[window].drawpointScaledY
	window[window].drawpointScaledX = x2#
	window[window].drawpointScaledY = y2#
'
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertScaledToLocal (window, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (window, x2#, y2#, @x2, @y2)
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
'
	return = XgrDrawLine (window, color, x1, y1, x2, y2)
'
	window[window].drawpointX = xx
	window[window].drawpointY = yy
	RETURN (return)
END FUNCTION
'
'
' ###################################
' #####  XgrDrawLineToDelta ()  #####
' ###################################
'
FUNCTION  XgrDrawLineToDelta (grid, color, dx, dy)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLineToDelta() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
'
	x1 = window[window].drawpointX
	y1 = window[window].drawpointY
	x2 = x1 + dx
	y2 = y1 + dy
'
	return = XgrDrawLine (window, color, x1, y1, x2, y2)
	RETURN (return)
END FUNCTION
'
'
' #######################################
' #####  XgrDrawLineToDeltaGrid ()  #####
' #######################################
'
FUNCTION  XgrDrawLineToDeltaGrid (grid, color, dxGrid, dyGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLineToDeltaGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
'
	x1Grid = window[window].drawpointGridX
	y1Grid = window[window].drawpointGridY
	x2Grid = x1Grid + dxGrid
	y2Grid = y1Grid + dyGrid
	window[window].drawpointGridX = x2Grid
	window[window].drawpointGridY = y2Grid
'
	XgrConvertGridToLocal (window, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (window, x2Grid, y2Grid, @x2, @y2)
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
'
	return = XgrDrawLine (window, color, x1, y1, x2, y2)
'
	window[window].drawpointX = xx
	window[window].drawpointY = yy
	RETURN (return)
END FUNCTION
'
'
' #########################################
' #####  XgrDrawLineToDeltaScaled ()  #####
' #########################################
'
FUNCTION  XgrDrawLineToDeltaScaled (grid, color, dx#, dy#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLineToDeltaScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
'
	x1# = window[window].drawpointScaledX
	y1# = window[window].drawpointScaledY
	x2# = x1# + dx#
	y2# = y1# + dy#
	window[window].drawpointScaledX = x2#
	window[window].drawpointScaledY = y2#
'
	XgrConvertScaledToLocal (window, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (window, x2#, y2#, @x2, @y2)
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
'
	return = XgrDrawLine (window, color, x1, y1, x2, y2)
'
	window[window].drawpointX = xx
	window[window].drawpointY = yy
	RETURN (return)
END FUNCTION
'
'
' #############################
' #####  XgrDrawLines ()  #####
' #############################
'
FUNCTION  XgrDrawLines (grid, color, first, count, line[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLines() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ line[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (line[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawLines() : invalid line[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of lines
'
	first = first << 2												' each line is 4 array elements
	upper = UBOUND (line[])										' upper bound of line[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count < 0) THEN count = upper					' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 2)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	points = (past - first)										'
	count = points >> 2												' # of lines at 4 points per line
	points = count << 1												' points is now a multiple of 2
	elements = points << 1										' array elements is 4 * line count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &line[]
'
	##WHOMASK = 0
	DIM segment[elements]							' array of SSHORT coords for X
	IF buffer DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x = SBYTEAT (addr, [i])		: INC i
												y = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x = UBYTEAT (addr, [i])		: INC i
												y = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x = SSHORTAT (addr, [i])	: INC i
												y = SSHORTAT (addr, [i])	: INC i
			CASE $$USHORT		: x = USHORTAT (addr, [i])	: INC i
												y = USHORTAT (addr, [i])	: INC i
			CASE $$SLONG		: x = SLONGAT (addr, [i])		: INC i
												y = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x = ULONGAT (addr, [i])		: INC i
												y = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x = XLONGAT (addr, [i])		: INC i
												y = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x = GIANTAT (addr, [i])		: INC i
												y = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x = SINGLEAT (addr, [i])	: INC i
												y = SINGLEAT (addr, [i])	: INC i
			CASE $$DOUBLE		: x = DOUBLEAT (addr, [i])	: INC i
												y = DOUBLEAT (addr, [i])	: INC i
		END SELECT
		segment[slot] = x	: INC slot
		segment[slot] = y	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x, y, x, y, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= points)
'
' final endpoint is final drawpoint
'
	window[window].drawpointX = x
	window[window].drawpointY = y
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawSegments (sdisplay, swindow, gc, &segment[], count)
	IF sbuffer THEN XDrawSegments (sdisplay, sbuffer, gc, &buffer[], count)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #################################
' #####  XgrDrawLinesGrid ()  #####
' #################################
'
FUNCTION  XgrDrawLinesGrid (grid, color, first, count, line[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLinesGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ line[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (line[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawLinesGrid() : invalid line[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of lines
'
	first = first << 2												' each line is 4 array elements
	upper = UBOUND (line[])										' upper bound of line[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count < 0) THEN count = upper					' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 2)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	points = (past - first)										'
	count = points >> 2												' # of lines at 4 points per line
	points = count << 1												' points is now a multiple of 2
	elements = points << 1										' array elements is 4 * line count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &line[]
'
	##WHOMASK = 0
	DIM segment[elements]									' array of SSHORT coords for X
	IF buffer THEN DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x = SBYTEAT (addr, [i])		: INC i
												y = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x = UBYTEAT (addr, [i])		: INC i
												y = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x = SSHORTAT (addr, [i])	: INC i
												y = SSHORTAT (addr, [i])	: INC i
			CASE $$USHORT		: x = USHORTAT (addr, [i])	: INC i
												y = USHORTAT (addr, [i])	: INC i
			CASE $$SLONG		: x = SLONGAT (addr, [i])		: INC i
												y = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x = ULONGAT (addr, [i])		: INC i
												y = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x = XLONGAT (addr, [i])		: INC i
												y = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x = GIANTAT (addr, [i])		: INC i
												y = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x = SINGLEAT (addr, [i])	: INC i
												y = SINGLEAT (addr, [i])	: INC i
			CASE $$DOUBLE		: x = DOUBLEAT (addr, [i])	: INC i
												y = DOUBLEAT (addr, [i])	: INC i
		END SELECT
'
		XgrConvertGridToLocal (window, x, y, @xx, @yy)
		segment[slot] = xx	: INC slot
		segment[slot] = yy	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, xx, yy, xx, yy, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= points)
'
' final endpoint is final drawpoint
'
	window[window].drawpointGridX = x
	window[window].drawpointGridY = y
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawSegments (sdisplay, swindow, gc, &segment[], count)
	IF sbuffer THEN XDrawSegments (sdisplay, sbuffer, gc, &buffer[], count)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###################################
' #####  XgrDrawLinesScaled ()  #####
' ###################################
'
FUNCTION  XgrDrawLinesScaled (grid, color, first, count, line[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLinesScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ line[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (line[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawLinesGrid() : invalid line[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of lines
'
	first = first << 2												' each line is 4 array elements
	upper = UBOUND (line[])										' upper bound of line[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count < 0) THEN count = upper					' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 2)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	points = (past - first)										'
	count = points >> 2												' # of lines at 4 points per line
	points = count << 1												' points is now a multiple of 2
	elements = points << 1										' array elements is 4 * line count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &line[]
'
	##WHOMASK = 0
	DIM segment[elements]									' array of SSHORT coords for X
	IF buffer THEN DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x# = SBYTEAT (addr, [i])		: INC i
												y# = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x# = UBYTEAT (addr, [i])		: INC i
												y# = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x# = SSHORTAT (addr, [i])		: INC i
												y# = SSHORTAT (addr, [i])		: INC i
			CASE $$USHORT		: x# = USHORTAT (addr, [i])		: INC i
												y# = USHORTAT (addr, [i])		: INC i
			CASE $$SLONG		: x# = SLONGAT (addr, [i])		: INC i
												y# = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x# = ULONGAT (addr, [i])		: INC i
												y# = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x# = XLONGAT (addr, [i])		: INC i
												y# = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x# = GIANTAT (addr, [i])		: INC i
												y# = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x# = SINGLEAT (addr, [i])		: INC i
												y# = SINGLEAT (addr, [i])		: INC i
			CASE $$DOUBLE		: x# = DOUBLEAT (addr, [i])		: INC i
												y# = DOUBLEAT (addr, [i])		: INC i
		END SELECT
'
		XgrConvertScaledToLocal (window, x#, y#, @xx, @yy)
		segment[slot] = xx	: INC slot
		segment[slot] = yy	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, xx, yy, xx, yy, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= points)
'
' final endpoint is final drawpoint
'
	window[window].drawpointScaledX = x#
	window[window].drawpointScaledY = y#
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawSegments (sdisplay, swindow, gc, &segment[], count)
	IF sbuffer THEN XDrawSegments (sdisplay, sbuffer, gc, &buffer[], count)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###############################
' #####  XgrDrawLinesTo ()  #####
' ###############################
'
FUNCTION  XgrDrawLinesTo (grid, color, first, count, line[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLinesTo() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ line[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (line[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawLinesTo() : invalid line[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of lines
'
	count = count + 1													' 1st x,y is starting point, not a line
	first = first + first											' each endpoint is 2 array elements
	upper = UBOUND (line[])										' upper bound of line[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count <= 0) THEN count = upper				' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 1)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	items = (past - first)										' # of array elements
	count = items >> 1												' # of coords at 2 points per coord
	elements = count << 1											' array elements is 2 * point count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &line[]
'
	##WHOMASK = 0
	DIM segment[elements]									' array of SSHORT coords for X
	IF buffer THEN DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x = SBYTEAT (addr, [i])		: INC i
												y = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x = UBYTEAT (addr, [i])		: INC i
												y = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x = SSHORTAT (addr, [i])	: INC i
												y = SSHORTAT (addr, [i])	: INC i
			CASE $$USHORT		: x = USHORTAT (addr, [i])	: INC i
												y = USHORTAT (addr, [i])	: INC i
			CASE $$SLONG		: x = SLONGAT (addr, [i])		: INC i
												y = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x = ULONGAT (addr, [i])		: INC i
												y = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x = XLONGAT (addr, [i])		: INC i
												y = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x = GIANTAT (addr, [i])		: INC i
												y = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x = SINGLEAT (addr, [i])	: INC i
												y = SINGLEAT (addr, [i])	: INC i
			CASE $$DOUBLE		: x = DOUBLEAT (addr, [i])	: INC i
												y = DOUBLEAT (addr, [i])	: INC i
		END SELECT
		segment[slot] = x	: INC slot
		segment[slot] = y	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x, y, x, y, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= points)
'
' final endpoint is final drawpoint
'
	window[window].drawpointX = x
	window[window].drawpointY = y
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawLines (sdisplay, swindow, gc, &segment[], count, 0)
	IF sbuffer THEN XDrawLines (sdisplay, sbuffer, gc, &buffer[], count, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###################################
' #####  XgrDrawLinesToGrid ()  #####
' ###################################
'
FUNCTION  XgrDrawLinesToGrid (grid, color, first, count, line[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLinesToGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ line[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (line[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawLinesToGrid() : invalid line[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of lines
'
	count = count + 1													' 1st x,y is starting point, not a line
	first = first + first											' each endpoint is 2 array elements
	upper = UBOUND (line[])										' upper bound of line[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count <= 0) THEN count = upper				' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 1)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	items = (past - first)										' # of array elements
	count = items >> 1												' # of coords at 2 points per coord
	elements = count << 1											' array elements is 2 * point count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &line[]
'
	##WHOMASK = 0
	DIM segment[elements]									' array of SSHORT coords for X
	IF buffer THEN DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x = SBYTEAT (addr, [i])		: INC i
												y = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x = UBYTEAT (addr, [i])		: INC i
												y = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x = SSHORTAT (addr, [i])	: INC i
												y = SSHORTAT (addr, [i])	: INC i
			CASE $$USHORT		: x = USHORTAT (addr, [i])	: INC i
												y = USHORTAT (addr, [i])	: INC i
			CASE $$SLONG		: x = SLONGAT (addr, [i])		: INC i
												y = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x = ULONGAT (addr, [i])		: INC i
												y = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x = XLONGAT (addr, [i])		: INC i
												y = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x = GIANTAT (addr, [i])		: INC i
												y = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x = SINGLEAT (addr, [i])	: INC i
												y = SINGLEAT (addr, [i])	: INC i
			CASE $$DOUBLE		: x = DOUBLEAT (addr, [i])	: INC i
												y = DOUBLEAT (addr, [i])	: INC i
		END SELECT
'
		XgrConvertGridToLocal (window, x, y, @xx, @yy)
		segment[slot] = xx	: INC slot
		segment[slot] = yy	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, xx, yy, xx, yy, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= points)
'
' final endpoint is final drawpoint
'
	window[window].drawpointGridX = x
	window[window].drawpointGridY = y
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawLines (sdisplay, swindow, gc, &segment[], count, 0)
	IF sbuffer THEN XDrawLines (sdisplay, sbuffer, gc, &buffer[], count, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #####################################
' #####  XgrDrawLinesToScaled ()  #####
' #####################################
'
FUNCTION  XgrDrawLinesToScaled (grid, color, first, count, line[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawLinesToScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ line[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (line[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawLinesToScaled() : invalid line[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of lines
'
	count = count + 1													' 1st x,y is starting point, not a line
	first = first + first											' each endpoint is 2 array elements
	upper = UBOUND (line[])										' upper bound of line[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count <= 0) THEN count = upper				' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 1)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	items = (past - first)										' # of array elements
	count = items >> 1												' # of coords at 2 points per coord
	elements = count << 1											' array elements is 2 * point count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &line[]
'
	##WHOMASK = 0
	DIM segment[elements]									' array of SSHORT coords for X
	IF buffer THEN DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x# = SBYTEAT (addr, [i])		: INC i
												y# = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x# = UBYTEAT (addr, [i])		: INC i
												y# = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x# = SSHORTAT (addr, [i])		: INC i
												y# = SSHORTAT (addr, [i])		: INC i
			CASE $$USHORT		: x# = USHORTAT (addr, [i])		: INC i
												y# = USHORTAT (addr, [i])		: INC i
			CASE $$SLONG		: x# = SLONGAT (addr, [i])		: INC i
												y# = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x# = ULONGAT (addr, [i])		: INC i
												y# = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x# = XLONGAT (addr, [i])		: INC i
												y# = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x# = GIANTAT (addr, [i])		: INC i
												y# = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x# = SINGLEAT (addr, [i])		: INC i
												y# = SINGLEAT (addr, [i])		: INC i
			CASE $$DOUBLE		: x# = DOUBLEAT (addr, [i])		: INC i
												y# = DOUBLEAT (addr, [i])		: INC i
		END SELECT
'
		XgrConvertScaledToLocal (window, x#, y#, @xx, @yy)
		segment[slot] = xx	: INC slot
		segment[slot] = yy	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, xx, yy, xx, yy, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= points)
'
' final endpoint is final drawpoint
'
	window[window].drawpointScaledX = x#
	window[window].drawpointScaledY = y#
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawLines (sdisplay, swindow, gc, &segment[], count, 0)
	IF sbuffer THEN XDrawLines (sdisplay, sbuffer, gc, &buffer[], count, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #############################
' #####  XgrDrawPoint ()  #####
' #############################
'
FUNCTION  XgrDrawPoint (grid, color, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawPoint() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	window[window].drawpointX = x
	window[window].drawpointY = y
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x, y, x, y, @bx, @by, 0, 0)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawPoint (sdisplay, swindow, gc, x, y)
	IF sbuffer THEN XDrawPoint (sdisplay, sbuffer, gc, bx, by)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #################################
' #####  XgrDrawPointGrid ()  #####
' #################################
'
FUNCTION  XgrDrawPointGrid (grid, color, xGrid, yGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawPointGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	window[window].drawpointGridX = xGrid
	window[window].drawpointGridY = yGrid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertGridToLocal (window, xGrid, yGrid, @x, @y)
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x, y, x, y, @bx, @by, 0, 0)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawPoint (sdisplay, swindow, gc, x, y)
	IF sbuffer THEN XDrawPoint (sdisplay, sbuffer, gc, bx, by)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###################################
' #####  XgrDrawPointScaled ()  #####
' ###################################
'
FUNCTION  XgrDrawPointScaled (grid, color, x#, y#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawPointScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	window[window].drawpointScaledX = x#
	window[window].drawpointScaledY = y#
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	XgrConvertScaledToLocal (window, x#, y#, @x, @y)
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x, y, x, y, @bx, @by, 0, 0)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawPoint (sdisplay, swindow, gc, x, y)
	IF sbuffer THEN XDrawPoint (sdisplay, sbuffer, gc, bx, by)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ##############################
' #####  XgrDrawPoints ()  #####
' ##############################
'
FUNCTION  XgrDrawPoints (grid, color, first, count, point[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawPoints() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ point[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (point[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawPoints() : invalid point[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of points
'
	first = first + first											' each point is 2 array elements
	upper = UBOUND (point[])									' upper bound of point[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count <= 0) THEN count = upper				' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 1)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	items = (past - first)										' # of array elements
	count = items >> 1												' # of coords at 2 points per coord
	elements = count << 1											' array elements is 2 * point count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &point[]
'
	##WHOMASK = 0
	DIM segment[elements]									' array of SSHORT coords for X
	IF buffer THEN DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x = SBYTEAT (addr, [i])		: INC i
												y = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x = UBYTEAT (addr, [i])		: INC i
												y = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x = SSHORTAT (addr, [i])	: INC i
												y = SSHORTAT (addr, [i])	: INC i
			CASE $$USHORT		: x = USHORTAT (addr, [i])	: INC i
												y = USHORTAT (addr, [i])	: INC i
			CASE $$SLONG		: x = SLONGAT (addr, [i])		: INC i
												y = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x = ULONGAT (addr, [i])		: INC i
												y = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x = XLONGAT (addr, [i])		: INC i
												y = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x = GIANTAT (addr, [i])		: INC i
												y = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x = SINGLEAT (addr, [i])	: INC i
												y = SINGLEAT (addr, [i])	: INC i
			CASE $$DOUBLE		: x = DOUBLEAT (addr, [i])	: INC i
												y = DOUBLEAT (addr, [i])	: INC i
		END SELECT
		segment[slot] = x	: INC slot
		segment[slot] = y	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x, y, x, y, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= count)
'
' final endpoint is final drawpoint
'
	window[window].drawpointX = x
	window[window].drawpointY = y
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawPoints (sdisplay, swindow, gc, &segment[], count, 0)
	IF sbuffer THEN XDrawPoints (sdisplay, sbuffer, gc, &buffer[], count, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ##################################
' #####  XgrDrawPointsGrid ()  #####
' ##################################
'
FUNCTION  XgrDrawPointsGrid (grid, color, first, count, point[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawPointsGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ point[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (point[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawPointsGrid() : invalid point[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of points
'
	first = first + first											' each point is 2 array elements
	upper = UBOUND (point[])									' upper bound of point[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count <= 0) THEN count = upper				' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 1)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	items = (past - first)										' # of array elements
	count = items >> 1												' # of coords at 2 points per coord
	elements = count << 1											' array elements is 2 * point count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &point[]
'
	##WHOMASK = 0
	DIM segment[elements]									' array of SSHORT coords for X
	IF buffer THEN DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x = SBYTEAT (addr, [i])		: INC i
												y = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x = UBYTEAT (addr, [i])		: INC i
												y = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x = SSHORTAT (addr, [i])	: INC i
												y = SSHORTAT (addr, [i])	: INC i
			CASE $$USHORT		: x = USHORTAT (addr, [i])	: INC i
												y = USHORTAT (addr, [i])	: INC i
			CASE $$SLONG		: x = SLONGAT (addr, [i])		: INC i
												y = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x = ULONGAT (addr, [i])		: INC i
												y = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x = XLONGAT (addr, [i])		: INC i
												y = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x = GIANTAT (addr, [i])		: INC i
												y = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x = SINGLEAT (addr, [i])	: INC i
												y = SINGLEAT (addr, [i])	: INC i
			CASE $$DOUBLE		: x = DOUBLEAT (addr, [i])	: INC i
												y = DOUBLEAT (addr, [i])	: INC i
		END SELECT
'
		XgrConvertGridToLocal (window, x, y, @xx, @yy)
		segment[slot] = xx	: INC slot
		segment[slot] = yy	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, xx, yy, xx, yy, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= count)
'
' final endpoint is final drawpoint
'
	window[window].drawpointGridX = x
	window[window].drawpointGridY = y
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawPoints (sdisplay, swindow, gc, &segment[], count, 0)
	IF sbuffer THEN XDrawPoints (sdisplay, swindow, gc, &buffer[], count, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ####################################
' #####  XgrDrawPointsScaled ()  #####
' ####################################
'
FUNCTION  XgrDrawPointsScaled (grid, color, first, count, point[])
	SHARED  WINDOW  window[]
	SHARED  debug
	SSHORT  segment[]
	SSHORT  buffer[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawPointsScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IFZ point[] THEN RETURN ($$FALSE)
'
	window = grid
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
' make sure array argument is a supported type
'
	type = TYPE (point[])
	IF ((type < $$SBYTE) OR (type > $$DOUBLE)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrDrawPointsScaled() : invalid point[] array type"
		RETURN ($$TRUE)
	END IF
'
' create X style array of points
'
	first = first + first											' each point is 2 array elements
	upper = UBOUND (point[])									' upper bound of point[] array
	IF (first < 0) THEN first = 0							' < 0 means start at 0
	IF (count <= 0) THEN count = upper				' < 0 means to upper bound
	IF (first > upper) THEN RETURN ($$FALSE)	' first is already beyond array
	past = first + (count << 1)								' past = requested last+1
	IF (past > upper) THEN past = upper + 1		' keep in bounds
	items = (past - first)										' # of array elements
	count = items >> 1												' # of coords at 2 points per coord
	elements = count << 1											' array elements is 2 * point count
	IFZ count THEN RETURN ($$FALSE)						' not enough elements in array
'
	n = 0
	slot = 0
	i = first
	addr = &point[]
'
	##WHOMASK = 0
	DIM segment[elements]									' array of SSHORT coords for X
	IF buffer THEN DIM buffer[elements]		' array of SSHORT coords for X
	##WHOMASK = whomask
'
	DO
		INC n
		SELECT CASE type
			CASE $$SBYTE		: x# = SBYTEAT (addr, [i])		: INC i
												y# = SBYTEAT (addr, [i])		: INC i
			CASE $$UBYTE		: x# = UBYTEAT (addr, [i])		: INC i
												y# = UBYTEAT (addr, [i])		: INC i
			CASE $$SSHORT		: x# = SSHORTAT (addr, [i])		: INC i
												y# = SSHORTAT (addr, [i])		: INC i
			CASE $$USHORT		: x# = USHORTAT (addr, [i])		: INC i
												y# = USHORTAT (addr, [i])		: INC i
			CASE $$SLONG		: x# = SLONGAT (addr, [i])		: INC i
												y# = SLONGAT (addr, [i])		: INC i
			CASE $$ULONG		: x# = ULONGAT (addr, [i])		: INC i
												y# = ULONGAT (addr, [i])		: INC i
			CASE $$XLONG		: x# = XLONGAT (addr, [i])		: INC i
												y# = XLONGAT (addr, [i])		: INC i
			CASE $$GIANT		: x# = GIANTAT (addr, [i])		: INC i
												y# = GIANTAT (addr, [i])		: INC i
			CASE $$SINGLE		: x# = SINGLEAT (addr, [i])		: INC i
												y# = SINGLEAT (addr, [i])		: INC i
			CASE $$DOUBLE		: x# = DOUBLEAT (addr, [i])		: INC i
												y# = DOUBLEAT (addr, [i])		: INC i
		END SELECT
'
		XgrConvertScaledToLocal (window, x#, y#, @xx, @yy)
		segment[slot] = xx	: INC slot
		segment[slot] = yy	: INC slot
'
		IF buffer THEN
			LocalToBufferCoords (window, buffer, @sbuffer, @overlap, xx, yy, xx, yy, @bx, @by, 0, 0)
			buffer[slot-2] = bx
			buffer[slot-1] = by
		END IF
	LOOP UNTIL (n >= count)
'
' final endpoint is final drawpoint
'
	window[window].drawpointScaledX = x#
	window[window].drawpointScaledY = y#
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawPoints (sdisplay, swindow, gc, &segment[], count, 0)
	IF sbuffer THEN XDrawPoints (sdisplay, sbuffer, gc, &buffer[], count, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ############################
' #####  XgrDrawText ()  #####
' ############################
'
' Add code to draw multiple lines when newline characters in text$
' and update drawpoint accordingly.
'
FUNCTION  XgrDrawText (grid, color, text$)
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	SHARED  charMap[]
	SHARED  debug
	AUTOX  dir
	AUTOX  up
	AUTOX  down
	AUTOX  XCharStruct  char
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ text$ THEN RETURN ($$FALSE)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawText() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	length = LEN (text$)
	upper = UBOUND (text$)
	gc = window[window].gc
	font = window[window].font
	sfont = font[font].sfont
	addrFont = font[font].addrFont
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	g = -1
	IF charMap[] THEN
		u = UBOUND (charMap[])
		IF (grid <= u) THEN
			IF charMap[0,] THEN g = 0
			IF charMap[grid,] THEN g = grid
'
			IF (g >= 0) THEN
				temp$ = NULL$ (length)
				FOR i = 0 TO length-1
					temp${i} = charMap[g,text${i}]				' map character
				NEXT i
				SWAP temp$, text$
			END IF
		END IF
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XTextExtents (addrFont, &text$, length, &dir, &up, &down, &char)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	x = window[window].drawpointX
	y = window[window].drawpointY + up
	window[window].drawpointX = x + char.width
	height = up + down
'
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x, y, x, y, @bx, @by, 0, 0)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawString (sdisplay, swindow, gc, x, y, &text$, length)
	IF sbuffer THEN XDrawString (sdisplay, sbuffer, gc, bx, by, &text$, length)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF (g >= 0) THEN
		SWAP text$, temp$
		temp$ = ""
	END IF
END FUNCTION
'
'
' ################################
' #####  XgrDrawTextGrid ()  #####
' ################################
'
FUNCTION  XgrDrawTextGrid (grid, color, text$)
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	SHARED  debug
	AUTOX  dir
	AUTOX  up
	AUTOX  down
	AUTOX  XCharStruct  char
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ text$ THEN RETURN ($$FALSE)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawTextGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x = window[window].drawpointX
	y = window[window].drawpointY
	xGrid = window[window].drawpointGridX
	yGrid = window[window].drawpointGridY
'
	XgrConvertGridToLocal (window, xGrid, yGrid, @xx, @yy)
	window[window].drawpointX = xx
	window[window].drawpointY = yy
'
' draw the text in local coords
'
	return = XgrDrawText (window, color, @text$)
'
' update grid coordinate drawpoint and restore local drawpoint
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
	return = XgrConvertLocalToGrid (window, xx, yy, @xGrid, @yGrid)
	window[window].drawpointGridX = xGrid
	window[window].drawpointGridY = yGrid
	window[window].drawpointX = x
	window[window].drawpointY = y
	RETURN (return)
END FUNCTION
'
'
' ##################################
' #####  XgrDrawTextScaled ()  #####
' ##################################
'
FUNCTION  XgrDrawTextScaled (grid, color, text$)
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	SHARED  debug
	AUTOX  dir
	AUTOX  up
	AUTOX  down
	AUTOX  XCharStruct  char
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ text$ THEN RETURN ($$FALSE)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawTextScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x = window[window].drawpointX
	y = window[window].drawpointY
	x# = window[window].drawpointScaledX
	y# = window[window].drawpointScaledY
'
	XgrConvertScaledToLocal (window, x#, y#, @xx, @yy)
	window[window].drawpointX = xx
	window[window].drawpointY = yy
'
' draw the text in local coords
'
	return = XgrDrawText (window, color, @text$)
'
' update scaled coordinate drawpoint and restore local drawpoint
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
	XgrConvertLocalToScaled (window, xx, yy, @x#, @y#)
	window[window].drawpointScaledX = x#
	window[window].drawpointScaledY = y#
	window[window].drawpointX = x
	window[window].drawpointY = y
	RETURN (return)
END FUNCTION
'
'
' ################################
' #####  XgrDrawTextFill ()  #####
' ################################
'
FUNCTION  XgrDrawTextFill (grid, color, text$)
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	SHARED  charMap[]
	SHARED  debug
	AUTOX  dir
	AUTOX  up
	AUTOX  down
	AUTOX  XCharStruct  char
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ text$ THEN RETURN ($$FALSE)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawTextFill() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	length = LEN (text$)
	gc = window[window].gc
	font = window[window].font
	sfont = font[font].sfont
	addrFont = font[font].addrFont
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	g = -1
	IF charMap[] THEN
		u = UBOUND (charMap[])
		IF (grid <= u) THEN
			IF charMap[0,] THEN g = 0
			IF charMap[grid,] THEN g = grid
'
			IF (g >= 0) THEN
				temp$ = NULL$ (length)
				FOR i = 0 TO length-1
					temp${i} = charMap[g,text${i}]				' map character
				NEXT i
				SWAP temp$, text$
			END IF
		END IF
	END IF
'
' the XQueryTextExtents() below doesn't work - can't figure out why
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XTextExtents (addrFont, &text$, length, &dir, &up, &down, &char)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	x = window[window].drawpointX
	y = window[window].drawpointY + up
	window[window].drawpointX = x + char.width
	height = up + down
'
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x, y, x, y, @bx, @by, 0, 0)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDrawImageString (sdisplay, swindow, gc, x, y, &text$, length)
	IF sbuffer THEN XDrawImageString (sdisplay, sbuffer, gc, bx, by, &text$, length)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF (g >= 0) THEN
		SWAP text$, temp$
		temp$ = ""
	END IF
END FUNCTION
'
'
' ####################################
' #####  XgrDrawTextFillGrid ()  #####
' ####################################
'
FUNCTION  XgrDrawTextFillGrid (grid, color, text$)
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	SHARED  debug
	AUTOX  dir
	AUTOX  up
	AUTOX  down
	AUTOX  XCharStruct  char
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ text$ THEN RETURN ($$FALSE)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawTextFillGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x = window[window].drawpointX
	y = window[window].drawpointY
	xGrid = window[window].drawpointGridX
	yGrid = window[window].drawpointGridY
'
	XgrConvertGridToLocal (window, xGrid, yGrid, @xx, @yy)
	window[window].drawpointX = xx
	window[window].drawpointY = yy
'
' draw the text in local coords
'
	return = XgrDrawTextFill (window, color, @text$)
'
' update grid coordinate drawpoint and restore local drawpoint
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
	XgrConvertLocalToGrid (window, xx, yy, @xGrid, @yGrid)
	window[window].drawpointGridX = xGrid
	window[window].drawpointGridY = yGrid
	window[window].drawpointX = x
	window[window].drawpointY = y
	RETURN (return)
END FUNCTION
'
'
' ######################################
' #####  XgrDrawTextFillScaled ()  #####
' ######################################
'
FUNCTION  XgrDrawTextFillScaled (grid, color, text$)
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	SHARED  debug
	AUTOX  dir
	AUTOX  up
	AUTOX  down
	AUTOX  XCharStruct  char
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ text$ THEN RETURN ($$FALSE)
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawTextScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x = window[window].drawpointX
	y = window[window].drawpointY
	x# = window[window].drawpointScaledX
	y# = window[window].drawpointScaledY
'
	XgrConvertScaledToLocal (window, x#, y#, @xx, @yy)
	window[window].drawpointX = xx
	window[window].drawpointY = yy
'
' draw the text in local coords
'
	return = XgrDrawTextFill (window, color, @text$)
'
' update scaled coordinate drawpoint and restore local drawpoint
'
	xx = window[window].drawpointX
	yy = window[window].drawpointY
	XgrConvertLocalToScaled (window, xx, yy, @x#, @y#)
	window[window].drawpointScaledX = x#
	window[window].drawpointScaledY = y#
	window[window].drawpointX = x
	window[window].drawpointY = y
	RETURN (return)
END FUNCTION
'
'
' ###########################
' #####  XgrFillBox ()  #####
' ###########################
'
FUNCTION  XgrFillBox (grid, color, x1, y1, x2, y2)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrFillBox() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x1, y1, x2, y2, @bx1, @by1, @bx2, @by2)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XFillRectangle (sdisplay, swindow, gc, x1, y1, x2-x1+1, y2-y1+1)
	IF sbuffer THEN XFillRectangle (sdisplay, sbuffer, gc, bx1, by1, bx2-bx1+1, by2-by1+1)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###############################
' #####  XgrFillBoxGrid ()  #####
' ###############################
'
FUNCTION  XgrFillBoxGrid (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrFillBoxGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	XgrConvertGridToLocal (window, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (window, x2Grid, y2Grid, @x2, @y2)
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x1, y1, x2, y2, @bx1, @by1, @bx2, @by2)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XFillRectangle (sdisplay, swindow, gc, x1, y1, x2-x1+1, y2-y1+1)
	IF sbuffer THEN XFillRectangle (sdisplay, sbuffer, gc, bx1, by1, bx2-bx1+1, by2-by1+1)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #################################
' #####  XgrFillBoxScaled ()  #####
' #################################
'
FUNCTION  XgrFillBoxScaled (grid, color, x1#, y1#, x2#, y2#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrFillBoxScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	gc = window[window].gc
	buffer = window[window].buffer
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	XgrConvertScaledToLocal (window, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (window, x2#, y2#, @x2, @y2)
'
	SetDrawingColor (window, color)
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, x1, y1, x2, y2, @bx1, @by1, @bx2, @by2)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XFillRectangle (sdisplay, swindow, gc, x1, y1, x2-x1+1, y2-y1+1)
	IF sbuffer THEN XFillRectangle (sdisplay, sbuffer, gc, bx1, by1, bx2-bx1+1, by2-by1+1)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ################################
' #####  XgrFillTriangle ()  #####
' ################################
'
FUNCTION  XgrFillTriangle (grid, color, style, direction, x1, y1, x2, y2)
	SHARED WINDOW window[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	way = direction AND 0x001E
	IFZ way THEN RETURN ($$FALSE)
'
	XgrGetGridBoxLocal (grid, @xx1, @yy1, @xx2, @yy2)
	w = xx2 - xx1 + 1
	h = yy2 - yy1 + 1
'
	IFZ (x1 OR y1 OR x2 OR y2) THEN
		x1 = 4
		y1 = 4
		x2 = w-5
		y2 = h-5
	END IF
'
	IF (x1 > x2) THEN SWAP x1, x2
	IF (y1 > y2) THEN SWAP y1, y2
	IF (x1 < 0) THEN x1 = 0
	IF (y1 < 0) THEN y1 = 0
	IF (x2 > (w-1)) THEN x2 = w-1
	IF (y2 > (h-1)) THEN y2 = h-1
	IF (x1 > x2) THEN SWAP x1, x2
	IF (y1 > y2) THEN SWAP y1, y2
'
	xx1 = x1 << 15
	xx2 = x2 << 15
	yy1 = y1 << 15
	yy2 = y2 << 15
	ddx = xx2 - xx1
	ddy = yy2 - yy1
	dx = x2 - x1
	dy = y2 - y1
'
	xxx = x1 + (dx >> 1)			' xxx = horizontal center of arrow
	yyy = y1 + (dy >> 1)			' yyy = vertical center of arrow
'
	xx = 0
	yy = 0
	dt = 0
	dh = ddy \ dx							' potential horizontal step size
	dv = ddx \ dy							' potential vertical step size
'
'	#####  v0.0433 : SVG : save current line style, set temporary style to $$LineStyleSolid
'
	lineStyle = window[grid].lineStyle
	window[grid].lineStyle = $$LineStyleSolid
'
'	#####
'
	SELECT CASE way
		CASE $$TriangleUp			: GOSUB TriangleUp
		CASE $$TriangleRight	: GOSUB TriangleRight
		CASE $$TriangleDown		: GOSUB TriangleDown
		CASE $$TriangleLeft		: GOSUB TriangleLeft
	END SELECT
'
'	#####  v0.0433 : SVG : restore original line style
'
	window[grid].lineStyle = lineStyle
'
'	#####
'
	RETURN
'
'
' *****  TriangleUp  *****
'
SUB TriangleUp
	FOR y = y1 TO y2
		xx1 = xxx - (dt >> 16)
		xx2 = xxx + (dt >> 16)
		XgrDrawLine (grid, color, xx1, y, xx2, y)
		dt = dt + dv
	NEXT y
END SUB
'
'
' *****  TriangleRight  *****
'
SUB TriangleRight
	FOR x = x2 TO x1 STEP -1
		yy1 = yyy - (dt >> 16)
		yy2 = yyy + (dt >> 16)
		XgrDrawLine (grid, color, x, yy1, x, yy2)
		dt = dt + dh
	NEXT x
END SUB
'
'
' *****  TriangleDown  *****
'
SUB TriangleDown
	FOR y = y2 TO y1 STEP -1
		xx1 = xxx - (dt >> 16)
		xx2 = xxx + (dt >> 16)
		XgrDrawLine (grid, color, xx1, y, xx2, y)
		dt = dt + dv
	NEXT y
END SUB
'
'
' *****  TriangleLeft  *****
'
SUB TriangleLeft
	FOR x = x1 TO x2
		yy1 = yyy - (dt >> 16)
		yy2 = yyy + (dt >> 16)
		XgrDrawLine (grid, color, x, yy1, x, yy2)
		dt = dt + dh
	NEXT x
END SUB
END FUNCTION
'
'
' ####################################
' #####  XgrFillTriangleGrid ()  #####
' ####################################
'
FUNCTION  XgrFillTriangleGrid (grid, color, style, direction, x1Grid, y1Grid, x2Grid, y2Grid)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xxGrid, @yyGrid)
	XgrConvertGridToLocal (grid, xxGrid, yyGrid, @x, @y)
	XgrConvertGridToLocal (grid, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (grid, x2Grid, y2Grid, @x2, @y2)
	XgrSetDrawpoint (grid, x, y)
	XgrFillTriangle (grid, color, style, direction, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ######################################
' #####  XgrFillTriangleScaled ()  #####
' ######################################
'
FUNCTION  XgrFillTriangleScaled (grid, color, style, direction, x1#, y1#, x2#, y2#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @xx#, @yy#)
	XgrConvertScaledToLocal (grid, xx#, yy#, @x, @y)
	XgrConvertScaledToLocal (grid, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (grid, x2#, y2#, @x2, @y2)
	XgrSetDrawpoint (grid, x, y)
	XgrFillTriangle (grid, color, style, direction, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ################################
' #####  XgrGetDrawpoint ()  #####
' ################################
'
FUNCTION  XgrGetDrawpoint (grid, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetDrawpoint() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x = window[window].drawpointX
	y = window[window].drawpointY
END FUNCTION
'
'
' ####################################
' #####  XgrGetDrawpointGrid ()  #####
' ####################################
'
FUNCTION  XgrGetDrawpointGrid (grid, xGrid, yGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetDrawpointGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	xGrid = window[window].drawpointGridX
	yGrid = window[window].drawpointGridY
END FUNCTION
'
'
' ######################################
' #####  XgrGetDrawpointScaled ()  #####
' ######################################
'
FUNCTION  XgrGetDrawpointScaled (grid, x#, y#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetDrawpointScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x# = window[window].drawpointScaledX
	y# = window[window].drawpointScaledY
END FUNCTION
'
'
' #############################
' #####  XgrGrabPoint ()  #####
' #############################
'
FUNCTION  XgrGrabPoint (grid, x, y, r, g, b, color)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  flushTime
	SHARED  debug
	XColor  sc
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGrabPoint() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	x1 = 0
	y1 = 0
	x2 = window[window].width - 1
	y2 = window[window].height - 1
'
	display = window[window].display
	swindow = window[window].swindow
	sdisplay = window[window].sdisplay
	colormap = display[display].colormap
'
	r = 0
	g = 0
	b = 0
	color = -1
'
	IF (x < x1) THEN RETURN
	IF (y < y1) THEN RETURN
	IF (x > x2) THEN RETURN
	IF (y > y2) THEN RETURN
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSync (sdisplay, $$FALSE)
	ximage = XGetImage (sdisplay, swindow, x, y, 1, 1, $$TRUE, $$ZPixmap)
	scolor = XGetPixel (ximage, 0, 0)
	sc.scolor = scolor
	XQueryColor (sdisplay, colormap, &sc)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	flushTime = eventTime
'
	r = sc.r
	g = sc.g
	b = sc.b
	XgrConvertRGBToColor (r, g, b, @color)
END FUNCTION
'
'
' #################################
' #####  XgrGrabPointGrid ()  #####
' #################################
'
FUNCTION  XgrGrabPointGrid (grid, xGrid, yGrid, @r, @g, @b, @color)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGrabPointGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	XgrConvertGridToLocal (window, xGrid, yGrid, @x, @y)
	XgrGrabPoint (window, x, y, @r, @g, @b, @color)
END FUNCTION
'
'
' ###################################
' #####  XgrGrabPointScaled ()  #####
' ###################################
'
FUNCTION  XgrGrabPointScaled (grid, x#, y#, @r, @g, @b, @color)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGrabPointScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	XgrConvertScaledToLocal (window, x#, y#, @x, @y)
	XgrGrabPoint (window, x, y, @r, @g, @b, @color)
END FUNCTION
'
'
' #############################
' #####  XgrMoveDelta ()  #####
' #############################
'
FUNCTION  XgrMoveDelta (grid, dx, dy)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMoveDelta() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointX = window[window].drawpointX + dx
	window[window].drawpointY = window[window].drawpointY + dy
END FUNCTION
'
'
' #################################
' #####  XgrMoveDeltaGrid ()  #####
' #################################
'
FUNCTION  XgrMoveDeltaGrid (grid, dxGrid, dyGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMoveDeltaGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointGridX = window[window].drawpointGridX + dxGrid
	window[window].drawpointGridY = window[window].drawpointGridY + dyGrid
END FUNCTION
'
'
' ###################################
' #####  XgrMoveDeltaScaled ()  #####
' ###################################
'
FUNCTION  XgrMoveDeltaScaled (grid, dx#, dy#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMoveDeltaScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointScaledX = window[window].drawpointScaledX + dx#
	window[window].drawpointScaledY = window[window].drawpointScaledY + dy#
END FUNCTION
'
'
' ##########################
' #####  XgrMoveTo ()  #####
' ##########################
'
FUNCTION  XgrMoveTo (grid, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMoveTo() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointX = x
	window[window].drawpointY = y
END FUNCTION
'
'
' ##############################
' #####  XgrMoveToGrid ()  #####
' ##############################
'
FUNCTION  XgrMoveToGrid (grid, xGrid, yGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMoveToGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointGridX = xGrid
	window[window].drawpointGridY = yGrid
END FUNCTION
'
'
' ################################
' #####  XgrMoveToScaled ()  #####
' ################################
'
FUNCTION  XgrMoveToScaled (grid, x#, y#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMoveToScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointScaledX = x#
	window[window].drawpointScaledY = y#
END FUNCTION
'
'
' ################################
' #####  XgrRedrawWindow ()  #####
' ################################
'
FUNCTION  XgrRedrawWindow (window, action, x, y, width, height)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrRedrawWindow() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
	IF (window != top) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrRedrawWindow() : not a top level window : invalid window #"; window; top
		RETURN ($$TRUE)
	END IF
'
' only redraw windows that are displayed
'
	SELECT CASE window[window].visibility
		CASE $$WindowDisplayed
		CASE $$WindowMaximized
		CASE ELSE								: RETURN ($$FALSE)
	END SELECT
'
' redraw whole window if width = 0 or height = 0
'
	IF ((width <= 0) OR (height <= 0)) THEN width = 0 : height = 0
'
' window visible - send/queue #RedrawGrid messages to all grids in xywh
'
	x1Win = x																			' rectangle left
	y1Win = y																			' rectangle top
	x2Win = x + width - 1													' rectangle right
	y2Win = y + height - 1												' rectangle bottom
'
	FOR w = 1 TO UBOUND (window[])
		IFZ window[w].window THEN DO NEXT							' grid must exist
		IF (window[w].top = w) THEN DO NEXT						' grids only, skip windows
		IF (window[w].kind != $$Grid) THEN DO NEXT		' grids only, skip images
		IF (window[w].parent != window) THEN DO NEXT	' grids with window parent
		IF (window[w].top != window) THEN DO NEXT			' grids in this window
		IFZ window[w].state THEN DO NEXT							' grid must be enabled
		RedrawGridAndKids (w, action, x, y, width, height)
	NEXT w
END FUNCTION
'
'
' ################################
' #####  XgrSetDrawpoint ()  #####
' ################################
'
FUNCTION  XgrSetDrawpoint (grid, x, y)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetDrawpoint() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointX = x
	window[window].drawpointY = y
END FUNCTION
'
'
' ####################################
' #####  XgrSetDrawpointGrid ()  #####
' ####################################
'
FUNCTION  XgrSetDrawpointGrid (grid, xGrid, yGrid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetDrawpointGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointGridX = xGrid
	window[window].drawpointGridY = yGrid
END FUNCTION
'
'
' ######################################
' #####  XgrSetDrawpointScaled ()  #####
' ######################################
'
FUNCTION  XgrSetDrawpointScaled (grid, x#, y#)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetDrawpointScaled() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	window[window].drawpointScaledX = x#
	window[window].drawpointScaledY = y#
END FUNCTION
'
'
' #############################
' #####  XgrCopyImage ()  #####
' #############################
'
FUNCTION  XgrCopyImage (dest, source)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (source) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrCopyImage() : invalid source grid #"; source
		RETURN ($$TRUE)
	END IF
'
	IF InvalidGrid (dest) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrCopyImage() : invalid destination grid #"; dest
		RETURN ($$TRUE)
	END IF
'
	IFZ window[dest].state THEN RETURN ($$FALSE)
	IFZ window[source].state THEN RETURN ($$FALSE)
'
	gc = window[dest].gc
	sdest = window[dest].swindow
	ssource = window[source].swindow
	sdisplay = window[dest].sdisplay
	buffer = window[dest].buffer
	IF (buffer = source) THEN buffer = 0
'
	dw = window[dest].width
	dh = window[dest].height
	sw = window[source].width
	sh = window[source].height
'
	width = sw
	height = sh
	IF (dw < sw) THEN width = dw
	IF (dh < sh) THEN height = dh
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, 0, 0, width-1, height-1, @bx1, @by1, @bx2, @by2)
		bwidth = bx2 - bx1 + 1
		bheight = by2 - by1 + 1
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XCopyArea (sdisplay, ssource, sdest, gc, 0, 0, width, height, 0, 0)
	IF sbuffer THEN XCopyArea (sdisplay, ssource, sbuffer, gc, bx1, by1, bwidth, bheight, 0, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #############################
' #####  XgrDrawImage ()  #####
' #############################
'
FUNCTION  XgrDrawImage (dest, source, sx1, sy1, width, height, dx1, dy1)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (source) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawImage() : invalid source grid #"; source
		RETURN ($$TRUE)
	END IF
'
	IF InvalidGrid (dest) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrDrawImage() : invalid destination grid #"; dest
		RETURN ($$TRUE)
	END IF
'
	IFZ window[dest].state THEN RETURN ($$FALSE)
	IFZ window[source].state THEN RETURN ($$FALSE)
'
	gc = window[dest].gc
	sdest = window[dest].swindow
	ssource = window[source].swindow
	sdisplay = window[dest].sdisplay
	buffer = window[dest].buffer
	IF (buffer = source) THEN buffer = 0
'
	dw = window[dest].width
	dh = window[dest].height
	sw = window[source].width
	sh = window[source].height
'
	IF (sx1 < 0) THEN sx1 = 0
	IF (sy1 < 0) THEN sy1 = 0
'
	ddw = dw - dx1
	ddh = dh - dy1
	ssw = sw - sx1
	ssh = sh - sy1
'
	w = ssw
	h = ssh
	IF (ddw < ssw) THEN w = ddw
	IF (ddh < ssh) THEN h = ddh
	IF (width <= 0) THEN width = w
	IF (height <= 0) THEN height = h
	IF (w < width) THEN width = w
	IF (h < height) THEN height = h
'
	IF buffer THEN
		LocalToBufferCoords (window, buffer, @sbuffer, @overlap, dx1, dy1, dx1+width-1, dy1+height-1, @bsx1, @bsy1, @bsx2, @bsy2)
		bwidth = bsx2 - bsx1 + 1
		bheight = bsy2 - bsy1 + 1
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XCopyArea (sdisplay, ssource, sdest, gc, sx1, sy1, width, height, dx1, dy1)
'	IF sbuffer THEN XCopyArea (sdisplay, ssource, sbuffer, bsx1, bsy1, bwidth, bheight, bx1, by1)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ############################
' #####  XgrGetImage ()  #####
' ############################
'
'	Get image in DIB format array
'
'	In:				grid
'	Out:			image[]			DIB format
'
'	Return:		$$FALSE			no errors
'						$$TRUE			errors
'
'	Win32s does not support 32-bit DIB, so stick with 24-bit DIB for now.
'
'
'		DIB BITMAPFILEHEADER:  Offset 0 bytes
'			USHORT	.bfType							'BM'  (for bitmap)
'			ULONG		.bfSize							Total size of the file in bytes
'			USHORT	.res1								0
'			USHORT	.res2								0
'			ULONG		.bfOffBits					Offset to bitmapData from beginning of file (66)
'
'		DIB BITMAPINFO:        Offset 14 bytes
'			DIB BITMAPINFOHEADER:  Offset 14 bytes
'				ULONG		.biSize						Size of BitmapInfoHeader in bytes (40)
'				SLONG		.biWidth					Width of bitmap in pixels
'				SLONG		.biHeight					Height of bitmap in pixels
'				USHORT	.biPlanes					1
'				USHORT	.biBitCount				Color bits per pixel (32)
'				ULONG		.biCompression		Compression scheme (BI_BITFIELDS = 3)
'				ULONG		.biSizeImage			Size of bitmap bits in bytes (0--no compression)
'				SLONG		.biXPelsPerMeter	Horizontal resolution in pixels per meter
'				SLONG		.biYPelsPerMeter	Vertical resolution
'				ULONG		.biClrUsed				Number of colors used in image (0)
'				ULONG		.biClrImportant		Number of important colors in image (0)
'
'			DIB bmiColors:			Offset 54 bytes
'				ULONG		.redBits					0xFFC00000		10 bits
'				ULONG		.greenBits				0x003FF800		11 bits
'				ULONG		.blueBits					0x000007FF		11 bits
'
'		DIB bitmapData:					Offset 66 bytes
'			biBitCount		Interpretation	  (start with BOTTOM row of pixels, at left)
'				32:					32-bits per pixel (10-11-11 = 0RGB)
'
'			Each ROW is padded to a multiple of 4 bytes.
'
'
'		24-bit format mods to the above:
'			BITMAPINFOHEADER
'				.biBitCount			= 24
'				.biCompression	= $BI_RGB
'
'			DIB bmiColors:		UNUSED (0 bytes)
'
'			DIB bitmapData:		offset = 54 bytes
'				24 bits per pixel (8 bits each for RGB)
'				Each ROW is padded to a multiple of 4 bytes.
'
FUNCTION  XgrGetImage (grid, UBYTE image[])
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  flushTime
	SHARED  debug
	STATIC  displayPrevious
	STATIC  XColor  cache[]
	STATIC  XColor  map[]
	UBYTE  dimage[]
	XColor  sc
'
	$BI_RGB       = 0					' 24-bit RGB
	$BI_BITFIELDS = 3					' 32-bit RGB
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	DIM image[]
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetImage() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	width = window[window].width					' image/grid width
	height = window[window].height				' image/grid height
	visual = window[window].visual				' visual (DirectColor, TrueColor, etc)
	swindow = window[window].swindow			' system image/grid #
	display = window[window].display			' native display #
	sdisplay = window[window].sdisplay		' system display #
	colormap = display[display].colormap	' system colormap
'
	IF (width <= 0) THEN RETURN ($$FALSE)
	IF (height <= 0) THEN RETURN ($$FALSE)
'
' compute size of DIB24 and create dimage[] array to hold it
'
'	dataOffset = 128			'???? why set to 128 if dataOffset for 24-bit is 54?
	dataOffset = 54
	widthbytes = ((width * 3) + 3) AND -4				' width of scan line in bytes
	size = dataOffset + (height * widthbytes)		' size of image file in bytes
	upper = size - 1
	DIM image[upper]
'
'	fill BITMAPFILEHEADER
'
	iAddr = &image[0]
'
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
'
'	fill BITMAPINFOHEADER (first 6 members)
'
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
'
' note : the following are for 32-bit $$BI_BITFIELDS only,
' not for the current 24-bit RGB format
'
	cbit = info+40															' color bitmasks offset
	rbits = 0xFFC00000													' 10-bits - red
	gbits = 0x003FF800													' 11-bits - green
	bbits = 0x000007FF													' 11-bits - blue
'
'	image[cbit+0] = rbits AND 0x00FF
'	image[cbit+1] = (rbits >> 8) AND 0x00FF
'	image[cbit+2] = (rbits >> 16) AND 0x00FF
'	image[cbit+3] = (rbits >> 24) AND 0x00FF
'	image[cbit+4] = gbits AND 0x00FF
'	image[cbit+5] = (gbits >> 8) AND 0x00FF
'	image[cbit+6] = (gbits >> 16) AND 0x00FF
'	image[cbit+7] = (gbits >> 24) AND 0x00FF
'	image[cbit+8] = bbits AND 0x00FF
'	image[cbit+9] = (bbits >> 8) AND 0x00FF
'	image[cbit+10] = (bbits >> 16) AND 0x00FF
'	image[cbit+11] = (bbits >> 24) AND 0x00FF
'
	dataAddr = iAddr + dataOffset
	infoAddr = iAddr + 14
	data = dataOffset
'
	daddr = &image[]
	daddrImage = daddr + dataOffset
'
'
' *****  IMPORTANT NOTE  *****
'
' The next to last argument is called "plane_mask", and in an example in
' the "xlib programming manual" book, the constant "AllPlanes" is passed
' to indicate data from all bit planes should be returned.  That's great,
' and should work, but on Linux at least I wasted a whole frigging day
' trying to make this routine work until I figured I would try $$TRUE
' aka -1 aka 0xFFFFFFFF in the "plane_mask" argument.  Note that the
' xlib constant "AllPlanes" is 0x00000000, not -1.  Gimme a break someday!
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSync (sdisplay, 0)
'	a$ = "XGetImage().A\n"
'	write (1, &a$, LEN(a$))
	ximage = XGetImage (sdisplay, swindow, 0, 0, width, height, $$TRUE, $$ZPixmap)
'	a$ = "XGetImage().Z\n"
'	write (1, &a$, LEN(a$))
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	flushTime = eventTime
'
	IFZ ximage THEN
		##ERROR = ($$ErrorObjectSystemFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrGetImage() : XGetImage() failed"
		DIM image[]
		RETURN ($$TRUE)
	END IF
'
	xwidth = XLONGAT (ximage, 0)
	xheight = XLONGAT (ximage, 4)
	xaddress = XLONGAT (ximage, 16)
	xdepth = XLONGAT (ximage, 36)
	xbytesperline = XLONGAT (ximage, 40)
	xbitsperpixel = XLONGAT (ximage, 44)
	xredmask = XLONGAT (ximage, 48)
	xgreenmask = XLONGAT (ximage, 52)
	xbluemask = XLONGAT (ximage, 56)
'
' look at the image header
'
'	test = $$TRUE
'	test = $$FALSE
'
'	IF test THEN GOSUB PrintImageHeader
'
' create a "pixel to rgb" cache to avoid excess XQueryColor() calls
'
	upper = 65535
	IFZ map[] THEN
		##WHOMASK = 0
		DIM map[upper]
		DIM cache[upper]
		##WHOMASK = whomask
	END IF
'
' keep previous entries if working on same display as last time
'
	IF (display != displayPrevious) THEN
		FOR i = 0 TO upper
			map[i].scolor = -1			' initialize to "empty/available" state
			cache[i].scolor = -1		' initialize to "empty/available" state
		NEXT i
		displayPrevious = display
	END IF
'
' see if we can read the memory more quickly if 8-bit pixels
'
	extra = $$FALSE
	quickie = $$FALSE
	IF xaddress THEN
		IF (xdepth = 8) THEN
			IF (xbitsperpixel = 8) THEN
				IF (xbytesperline >= xwidth) THEN
					extra = xbytesperline - xwidth
					IF (extra < 8) THEN quickie = $$TRUE
				END IF
			END IF
		END IF
	END IF
'
' get every pixel from image, convert into RGB, and put in DIB24
'
	xaddr = xaddress																		' addr of XWindows image
	data = dataOffset + (widthbytes * (height-1))				' array element of last scan line
	daddr = daddrImage + (widthbytes * (height-1))			' addr of last scan line in BMP array
'
	FOR y = 0 TO height-1
		scanlinedata = data
		scanlineaddr = daddr
		FOR x = 0 TO width-1
			IF quickie THEN
				scolor = UBYTEAT (xaddr)
				INC xaddr
			ELSE
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				scolor = XGetPixel (ximage, x, y)
				##LOCKOUT = lockout
				##WHOMASK = whomask
			END IF
'
			sc.scolor = scolor
'
' check for scolor in the map cache
'
			map = $$FALSE
			IF (scolor >= 0) THEN
				IF (scolor <= upper) THEN
					pixel = map[scolor].scolor
					IF (pixel != -1) THEN
						m = scolor
						map = $$TRUE
						sc = map[scolor]
					END IF
				END IF
			END IF
'
			IF (scolor >= 0) THEN
				IFZ map THEN
					cache = $$FALSE
					FOR c = 0 TO upper
						pixel = cache[c].scolor
						IF (pixel = -1) THEN EXIT FOR					' past all valid entries
						IF (pixel = scolor) THEN
							cache = $$TRUE
							sc = cache[c]
							EXIT FOR
						END IF
					NEXT c
				END IF
			END IF
'
			mm = 0 : IF map THEN mm = 1
			cc = c : IF cache THEN cc = 1
'
			IFZ (map OR cache) THEN
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				huh = XQueryColor (sdisplay, colormap, &sc)
				##LOCKOUT = lockout
				##WHOMASK = whomask
			END IF
'
			scolor = sc.scolor
'
' if scolor is not in map[] or cache[], put pixel scolor in map[] if it fits,
' otherwise if cache still has room, put pixel scolor in cache[]
'
			IFZ map THEN
				IF (scolor >= 0) THEN
					IF (scolor <= upper) THEN
						map[scolor] = sc
						map = $$TRUE
					END IF
				END IF
			END IF
'
			IFZ map THEN
				IFZ cache THEN
					IF (scolor >= 0) THEN
						IF (c <= upper) THEN cache[c] = sc
					END IF
				END IF
			END IF
'
' convert sc into 24-bit .BMP color - RGB = 8 bits each
'
			red = (sc.r >> 8) AND 0x00FF
			green = (sc.g >> 8) AND 0x00FF
			blue = (sc.b >> 8) AND 0x00FF
			image[data] = blue	: INC data
			image[data] = green	: INC data
			image[data] = red		: INC data
'
'			IF test THEN GOSUB PrintPixelInformation
'
		NEXT x
		IF quickie THEN xaddr = xaddr + extra
		daddr = scanlineaddr - widthbytes
		data = scanlinedata - widthbytes
	NEXT y
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDestroyImage (ximage)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	RETURN ($$FALSE)
'
'
'
' *****  PrintImageHeader  *****
'
SUB PrintImageHeader
	xwidth = XLONGAT (ximage, 0)
	xheight = XLONGAT (ximage, 4)
	xoffset = XLONGAT (ximage, 8)
	xformat = XLONGAT (ximage, 12)
	xaddress = XLONGAT (ximage, 16)
	xbyteorder = XLONGAT (ximage, 20)
	xbitmapunit = XLONGAT (ximage, 24)
	xbitorder = XLONGAT (ximage, 28)
	xbitmappad = XLONGAT (ximage, 32)
	xdepth = XLONGAT (ximage, 36)
	xbytesperline = XLONGAT (ximage, 40)
	xbitsperpixel = XLONGAT (ximage, 44)
	xredmask = XLONGAT (ximage, 48)
	xgreenmask = XLONGAT (ximage, 52)
	xbluemask = XLONGAT (ximage, 56)
	xhooks = XLONGAT (ximage, 60)
	x0 = XLONGAT (ximage, 64)
	x1 = XLONGAT (ximage, 68)
	x2 = XLONGAT (ximage, 72)
	x3 = XLONGAT (ximage, 76)
	a$ = HEX$ (visual, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xwidth, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xheight, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xoffset, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xformat, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xaddress, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbyteorder, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbitmapunit, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbitorder, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbitmappad, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xdepth, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbytesperline, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbitsperpixel, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xredmask, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xgreenmask, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbluemask, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xhooks, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (x0, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (x1, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (x2, 8) + " "
	write (1, &a$, LEN(a$))
'
' print 16 scan lines of data
'
	IF xaddress THEN
		addr = xaddress
		FOR y = 0 TO 15
			FOR x = 0 TO xbytesperline
				byte = UBYTEAT (addr)
				a$ = HEX$ (byte, 2) + " "
				write (1, &a$, LEN(a$))
				INC addr
			NEXT x
			a$ = "\n"
			write (1, &a$, LEN(a$))
		NEXT y
	END IF
END SUB
'
'
' *****  PrintPixelInformation  *****
'
SUB PrintPixelInformation
	a$ = HEX$(y,4) + " " + HEX$(x,4) + " : " + HEX$(scolor,8) + " " + HEX$(dcolor, 8) + " : " + HEX$(red,8) + " " + HEX$(green,8) + " " + HEX$(blue,8) + " : " + HEX$(m,4) + " " + HEX$(c,4) + " : " + STRING$(mm) + " " + STRING$(cc) + "\n"
	write (1, &a$, LEN(a$))
END SUB
END FUNCTION
'
'
' ##############################
' #####  XgrGetImage32 ()  #####
' ##############################
'
FUNCTION  XgrGetImage32 (grid, UBYTE image[])
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  flushTime
	SHARED  debug
	STATIC  displayPrevious
	STATIC  XColor  cache[]
	STATIC  XColor  map[]
	UBYTE  dimage[]
	XColor  sc
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	DIM image[]
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetImage() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	width = window[window].width					' image/grid width
	height = window[window].height				' image/grid height
	visual = window[window].visual				' visual (DirectColor, TrueColor, etc)
	swindow = window[window].swindow			' system image/grid #
	display = window[window].display			' native display #
	sdisplay = window[window].sdisplay		' system display #
	colormap = display[display].colormap	' system colormap
'
	IF (width <= 0) THEN RETURN ($$FALSE)
	IF (height <= 0) THEN RETURN ($$FALSE)
'
' compute size of DIB32 and create dimage[] array to hold it
'
	dataOffset = 128
	widthbytes = width << 2
	dsize = dataOffset + (height * widthbytes)		' size of image[] array
	dupper = dsize - 1														' upper bound of image[] array
	DIM dimage[dupper]														' destination image[] in DIB32
'
' initialize destination image[] array header with DIB32 format info
'
	daddr = &dimage[]											' start addr of destination image[] array
	daddrImage = daddr + 256							' start addr of destination image data
	daddrPalette = daddr + 64							' start addr of destination color masks
'
	UBYTEAT (daddr, 0) = 'B'							' okay : DIB signature = "BM"
	UBYTEAT (daddr, 1) = 'M'							' okay : DIB signature = "BM"
	XLONGAT (daddr, 2) = dsize						' boom : # of bytes in dimage[]
	XLONGAT (daddr, 10) = 256							' boom : offset to image data
	XLONGAT (daddr, 14) = 50							' boom : # of bytes in info data (to color masks)
	XLONGAT (daddr, 18) = width						' boom : width of image in pixels
	XLONGAT (daddr, 22) = height					' boom : height of image in pixels
	USHORTAT (daddr, 26) = 1							' okay : # of planes == 1
	USHORTAT (daddr, 28) = 32							' okay : # of bits per pixel
	XLONGAT (daddr, 30) = 3								' boom : "compression" == BI_BITFIELDS
	XLONGAT (daddr, 34) = 0								' boom : 0 == image not compressed
	XLONGAT (daddr, 38) = 0								' boom : who knows ???
	XLONGAT (daddr, 42) = 0								' boom : who knows ???
	XLONGAT (daddr, 46) = 0								' boom : # of colors in palette == 0
	XLONGAT (daddr, 50) = 0								' boom : # of important colors == 0
'
	dredMask = 0xFFC00000									' 10 bits
	dgreenMask = 0x003FF800								' 11 bits
	dblueMask = 0x000007FF								' 11 bits
'
	XLONGAT (daddrPalette, 0) = dredMask
	XLONGAT (daddrPalette, 4) = dgreenMask
	XLONGAT (daddrPalette, 8) = dblueMask
'
' *****  IMPORTANT NOTE  *****
'
' The next to last argument is called "plane_mask", and in an example in
' the "xlib programming manual" book, the constant "AllPlanes" is passed
' to indicate data from all bit planes should be returned.  That's great,
' and should work, but on Linux at least I wasted a whole frigging day
' trying to make this routine work until I figured I would try $$TRUE
' aka -1 aka 0xFFFFFFFF in the "plane_mask" argument.  Note that the
' xlib constant "AllPlanes" is 0x00000000, not -1.  Gimme a break someday!
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSync (sdisplay, 0)
'	a$ = "XGetImage().A\n"
'	write (1, &a$, LEN(a$))
	ximage = XGetImage (sdisplay, swindow, 0, 0, width, height, $$TRUE, $$ZPixmap)
'	a$ = "XGetImage().Z\n"
'	write (1, &a$, LEN(a$))
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	flushTime = eventTime
'
	IFZ ximage THEN
		##ERROR = ($$ErrorObjectSystemFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrGetImage() : XGetImage() failed"
		RETURN ($$TRUE)
	END IF
'
	xwidth = XLONGAT (ximage, 0)
	xheight = XLONGAT (ximage, 4)
	xaddress = XLONGAT (ximage, 16)
	xdepth = XLONGAT (ximage, 36)
	xbytesperline = XLONGAT (ximage, 40)
	xbitsperpixel = XLONGAT (ximage, 44)
	xredmask = XLONGAT (ximage, 48)
	xgreenmask = XLONGAT (ximage, 52)
	xbluemask = XLONGAT (ximage, 56)
'
' look at the image header
'
'	test = $$TRUE
'	test = $$FALSE
'
'	IF test THEN GOSUB PrintImageHeader
'
' create a "pixel to rgb" cache to avoid excess XQueryColor() calls
'
	upper = 65535
	IFZ map[] THEN
		##WHOMASK = 0
		DIM map[upper]
		DIM cache[upper]
		##WHOMASK = whomask
	END IF
'
' keep previous entries if working on same display as last time
'
	IF (display != displayPrevious) THEN
		FOR i = 0 TO upper
			map[i].scolor = -1			' initialize to "empty/available" state
			cache[i].scolor = -1		' initialize to "empty/available" state
		NEXT i
		displayPrevious = display
	END IF
'
' see if we can read the memory more quickly if 8-bit pixels
'
	extra = $$FALSE
	quickie = $$FALSE
	IF xaddress THEN
		IF (xdepth = 8) THEN
			IF (xbitsperpixel = 8) THEN
				IF (xbytesperline >= xwidth) THEN
					extra = xbytesperline - xwidth
					IF (extra < 8) THEN quickie = $$TRUE
				END IF
			END IF
		END IF
	END IF
'
' get every pixel from image, convert into RGB, and put in DIB32
'
	xaddr = xaddress
	data = dataOffset + (widthbytes * (height-1))				' array element of last scan line
	daddr = daddrImage + (widthbytes * (height-1))			' addr of last scan line in BMP array
'
	FOR y = 0 TO height-1
		scanlinedata = data
		scanlineaddr = daddr
		FOR x = 0 TO width-1
			IF quickie THEN
				scolor = UBYTEAT (xaddr)
				INC xaddr
			ELSE
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				scolor = XGetPixel (ximage, x, y)
				##LOCKOUT = lockout
				##WHOMASK = whomask
			END IF
'
			sc.scolor = scolor
'
' check for scolor in the map cache
'
			map = $$FALSE
			IF (scolor >= 0) THEN
				IF (scolor <= upper) THEN
					pixel = map[scolor].scolor
					IF (pixel != -1) THEN
						m = scolor
						map = $$TRUE
						sc = map[scolor]
					END IF
				END IF
			END IF
'
			IF (scolor >= 0) THEN
				IFZ map THEN
					cache = $$FALSE
					FOR c = 0 TO upper
						pixel = cache[c].scolor
						IF (pixel = -1) THEN EXIT FOR					' past all valid entries
						IF (pixel = scolor) THEN
							cache = $$TRUE
							sc = cache[c]
							EXIT FOR
						END IF
					NEXT c
				END IF
			END IF
'
			mm = 0 : IF map THEN mm = 1
			cc = c : IF cache THEN cc = 1
'
			IFZ (map OR cache) THEN
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				huh = XQueryColor (sdisplay, colormap, &sc)
				##LOCKOUT = lockout
				##WHOMASK = whomask
			END IF
'
			scolor = sc.scolor
'
' if scolor is not in map[] or cache[], put pixel scolor in map[] if it fits,
' otherwise if cache still has room, put pixel scolor in cache[]
'
			IFZ map THEN
				IF (scolor >= 0) THEN
					IF (scolor <= upper) THEN
						map[scolor] = sc
						map = $$TRUE
					END IF
				END IF
			END IF
'
			IFZ map THEN
				IFZ cache THEN
					IF (scolor >= 0) THEN
						IF (c <= upper) THEN cache[c] = sc
					END IF
				END IF
			END IF
'
' convert sc into 32-bit .BMP color - RGB = 10,11,11 bits with R in most significant 10 bits
'
			red = (sc.r << 16) AND dredMask
			green = (sc.g << 6) AND dgreenMask
			blue = (sc.b >> 5) AND dblueMask
			dcolor = red OR green OR blue							' 10-11-11 rgb color
			XLONGAT (daddr) = dcolor
			daddr = daddr + 4
'
'			IF test THEN GOSUB PrintPixelInformation
'
		NEXT x
		IF quickie THEN xaddr = xaddr + extra
		daddr = scanlineaddr - widthbytes
		data = scanlinedata - widthbytes
	NEXT y
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XDestroyImage (ximage)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	SWAP image[], dimage[]
	RETURN ($$FALSE)
'
'
'
' *****  PrintImageHeader  *****
'
SUB PrintImageHeader
	xwidth = XLONGAT (ximage, 0)
	xheight = XLONGAT (ximage, 4)
	xoffset = XLONGAT (ximage, 8)
	xformat = XLONGAT (ximage, 12)
	xaddress = XLONGAT (ximage, 16)
	xbyteorder = XLONGAT (ximage, 20)
	xbitmapunit = XLONGAT (ximage, 24)
	xbitorder = XLONGAT (ximage, 28)
	xbitmappad = XLONGAT (ximage, 32)
	xdepth = XLONGAT (ximage, 36)
	xbytesperline = XLONGAT (ximage, 40)
	xbitsperpixel = XLONGAT (ximage, 44)
	xredmask = XLONGAT (ximage, 48)
	xgreenmask = XLONGAT (ximage, 52)
	xbluemask = XLONGAT (ximage, 56)
	xhooks = XLONGAT (ximage, 60)
	x0 = XLONGAT (ximage, 64)
	x1 = XLONGAT (ximage, 68)
	x2 = XLONGAT (ximage, 72)
	x3 = XLONGAT (ximage, 76)
	a$ = HEX$ (visual, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xwidth, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xheight, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xoffset, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xformat, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xaddress, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbyteorder, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbitmapunit, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbitorder, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbitmappad, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xdepth, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbytesperline, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbitsperpixel, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xredmask, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xgreenmask, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xbluemask, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (xhooks, 8) + "\n"
	write (1, &a$, LEN(a$))
	a$ = HEX$ (x0, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (x1, 8) + " "
	write (1, &a$, LEN(a$))
	a$ = HEX$ (x2, 8) + " "
	write (1, &a$, LEN(a$))
'
' print 16 scan lines of data
'
	IF xaddress THEN
		addr = xaddress
		FOR y = 0 TO 15
			FOR x = 0 TO xbytesperline
				byte = UBYTEAT (addr)
				a$ = HEX$ (byte, 2) + " "
				write (1, &a$, LEN(a$))
				INC addr
			NEXT x
			a$ = "\n"
			write (1, &a$, LEN(a$))
		NEXT y
	END IF
END SUB
'
'
' *****  PrintPixelInformation  *****
'
SUB PrintPixelInformation
	a$ = HEX$(y,4) + " " + HEX$(x,4) + " : " + HEX$(scolor,8) + " " + HEX$(dcolor, 8) + " : " + HEX$(red,8) + " " + HEX$(green,8) + " " + HEX$(blue,8) + " : " + HEX$(m,4) + " " + HEX$(c,4) + " : " + STRING$(mm) + " " + STRING$(cc) + "\n"
	write (1, &a$, LEN(a$))
END SUB
END FUNCTION
'
'
' #####################################
' #####  XgrGetImageArrayInfo ()  #####
' #####################################
'
FUNCTION  XgrGetImageArrayInfo (UBYTE image[], bitsPerPixel, width, height)
	SHARED  xgrError
'
	IFZ image[] THEN RETURN ($$TRUE)
	bytes = SIZE (image[])
	iAddr = &image[]
'
	IF (bytes < 32) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	byte0 = image[0]
	byte1 = image[1]
'
	IF ((byte0 != 'B') OR (byte1 != 'M')) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	byte2 = image[2]
	byte3 = image[3]
	byte4 = image[4]
	byte5 = image[5]
	fileSize = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2
'
	byte14 = image[14]
	byte15 = image[15]
	byte16 = image[16]
	byte17 = image[17]
	headerSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14
'
	info = 14
'
	IF (headerSize = 12) THEN							' BITMAPCOREINFO
		w0 = image[info+4]
		w1 = image[info+5]
		h0 = image[info+6]
		h1 = image[info+7]
		b0 = image[info+10]
		b1 = image[info+11]
		width = (w1 << 8) OR w0
		height = (h1 << 8) OR h0
		bitsPerPixel = (b1 << 8) OR b0
	ELSE																	' BITMAPINFO
		w0 = image[info+4]
		w1 = image[info+5]
		w2 = image[info+6]
		w3 = image[info+7]
		h0 = image[info+8]
		h1 = image[info+9]
		h2 = image[info+10]
		h3 = image[info+11]
		b0 = image[info+14]
		b1 = image[info+15]
		width = (w3 << 24) OR (w2 << 16) OR (w1 << 8) OR w0
		height = (h3 << 24) OR (h2 << 16) OR (h1 << 8) OR h0
		bitsPerPixel = (b1 << 8) OR b0
	END IF
END FUNCTION
'
'
' #############################
' #####  XgrLoadImage ()  #####
' #############################
'
FUNCTION  XgrLoadImage (filename$, UBYTE image[])
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
	UBYTE  file[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	DIM image[]
'
	IFZ filename$ THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrLoadImage() : invalid file$ argument"
		RETURN ($$TRUE)
	END IF
'
	file$ = XstPathString$ (@filename$)
'
	ifile = OPEN (file$, $$RD)
'
	IF (ifile <= 0) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrLoadImage() : invalid file$ argument"
		RETURN ($$TRUE)
	END IF
'
	insize = LOF (ifile)
	IF (insize <= 64) THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureEmpty
		IF debug THEN PRINT "XgrLoadImage() : image file is empty or too small : "; file$
		RETURN ($$TRUE)
	END IF
'
	upper = insize - 1			' upper bound of UBYTE file[]
	DIM file[upper]					' UBYTE file[] big enough for whole DIB file
'
	READ [ifile], file[]		' read whole DIB file into UBYTE file[]
	CLOSE (ifile)						' done with DIB file on disk
'
	IF ((file[0] != 'B') OR (file[1] != 'M')) THEN
		##ERROR = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidSignature
		IF debug THEN PRINT "XgrLoadImage() : invalid DIB signature"
		RETURN ($$TRUE)
	END IF
'
' DIBToDIB32() converts 1,4,8,16,24,32 bits per pixel DIBs into the
' native standard DIB, which has 32 bits per pixel with red-green-blue
' fields having 10-11-11 bits (from MSb to LSb in XLONG).
'
	r = XxxDIBToDIB32 (@file[], @image[])
	RETURN (r)
END FUNCTION
'
'
' ###############################
' #####  XgrRefreshGrid ()  #####
' ###############################
'
FUNCTION  XgrRefreshGrid (grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrRefreshGrid() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	IFZ window[window].state THEN RETURN ($$FALSE)
'
	image = window[window].buffer
	IF debug THEN PRINT "XgrRefreshGrid() : "; grid, image
	IF (image <= 0) THEN RETURN ($$FALSE)			' no buffer grid is okay
'
	IF InvalidGrid (image) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "XgrRefreshGrid() : invalid buffer grid #"
		RETURN ($$TRUE)
	END IF
'
	igt = window[image].type
	IF (igt != #GridTypeImage) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrRefreshGrid() : buffer grid != #GridTypeImage"
		RETURN ($$TRUE)
	END IF
'
' get offset of buffer on grid
'
	dx = window[window].bufferX
	dy = window[window].bufferY
'
' grid coords in grid local
'
	x1 = 0
	y1 = 0
	x2 = window[window].width - 1
	y2 = window[window].height - 1
'
' image coords in image local
'
	xx1 = 0
	yy1 = 0
	xx2 = window[image].width - 1
	yy2 = window[image].height - 1
'
' image coords in grid local - adjusted by offset of image in grid
'
	ix1 = xx1 + dx
	iy1 = yy1 + dy
	ix2 = xx2 + dx
	iy2 = yy2 + dy
'
' image coords in grid local that are within the grid
'
	IF (dx1 < x1) THEN dx1 = x1 ELSE dx1 = ix1
	IF (dy1 < y1) THEN dy1 = y1 ELSE dy1 = iy1
	IF (dx2 > x2) THEN dx2 = x2 ELSE dx2 = ix2
	IF (dy2 > y2) THEN dy2 = y2 ELSE dy2 = iy2
'
' no overlap means no draw
'
	IF (dx1 > x2) THEN RETURN ($$FALSE)
	IF (dy1 > y2) THEN RETURN ($$FALSE)
	IF (dx2 < x1) THEN RETURN ($$FALSE)
	IF (dy2 < y1) THEN RETURN ($$FALSE)
'
' image coords of active part of source image
'
	sx1 = dx1 + dx
	sy1 = dy1 + dy
	sx2 = dx2 + dx
	sy2 = dy2 + dy
	swidth = sx2 - sx1 + 1
	sheight = sy2 - sy1 + 1
'
	IFZ (x OR y) THEN
'		PRINT "XgrRefreshGrid() : XgrCopyImage() : "; grid, image
		return = XgrCopyImage (grid, image)
	ELSE
'		PRINT "XgrRefreshGrid() : XgrDrawImage() : "; grid, image
		return = XgrDrawImage (grid, image, sx1, sy1, swidth, sheight, dx1, dy1)
	END IF
	RETURN (return)
END FUNCTION
'
'
' #############################
' #####  XgrSaveImage ()  #####
' #############################
'
FUNCTION  XgrSaveImage (file$, UBYTE image[])
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ file$ THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName
		IF debug THEN PRINT "XgrSaveImage() : empty file$ string"
		RETURN ($$TRUE)
	END IF
'
	IFZ image[] THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrSaveImage() : image[] array is empty"
		RETURN ($$TRUE)
	END IF
'
	size = SIZE (image[])
'
	IF (size < 260) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrSaveImage() : input argument image[] too small"
		RETURN ($$TRUE)
	END IF
'
	byte0 = image[0]
	byte1 = image[1]
'
	IF ((byte0 != 'B') OR (byte1 != 'M')) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	byte2 = image[2]
	byte3 = image[3]
	byte4 = image[4]
	byte5 = image[5]
'
	bytes = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2
'
	IF (size < bytes) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	ofile = OPEN (fileName$, $$WRNEW)
'
	IF (ofile < 3) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	byteWrite = XstBinWrite (ofile, &image[], size)
	CLOSE (ofile)
END FUNCTION
'
'
' ############################
' #####  XgrSetImage ()  #####
' ############################
'
FUNCTION  XgrSetImage (grid, UBYTE image[])
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  flushTime
	SHARED  debug
	XColor  sc[]
	XColor  sc
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetImage() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	display = window[window].display
'
	IF (window[window].type != #GridTypeImage) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureInvalidType
		IF debug THEN PRINT "XgrSetImage() : invalid grid type : not an image grid"
		RETURN ($$TRUE)
	END IF
'
	IFZ image[] THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrSetImage() : image[] array is empty"
		RETURN ($$TRUE)
	END IF
'
	size = SIZE (image[])
'
	IF (size < 64) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XgrSetImage() : input argument image[] too small"
		RETURN ($$TRUE)
	END IF
'
	simage = window[window].swindow			' system pixmap #
	IFZ simage THEN RETURN ($$FALSE)		' no destination image
'
'
' look at BMP image header
'
	byte0 = image[0]
	byte1 = image[1]
'
	IF ((byte0 != 'B') OR (byte1 != 'M')) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	byte2 = image[2]
	byte3 = image[3]
	byte4 = image[4]
	byte5 = image[5]
'
	bytes = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2
'
	IF (size < bytes) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		IF debug THEN PRINT "XgrSetImage() : error : (size < bytes) : "; size;; bytes
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	byte10 = image[10]
	byte11 = image[11]
	byte12 = image[12]
	byte13 = image[13]
'
	dataOffset = (byte13 << 24) OR (byte12 << 16) OR (byte11 << 8) OR byte10
'
	IF (dataOffset AND 0x03) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		IF debug THEN PRINT "XgrSetImage() : error : (dataOffset not mod 4) : "; dataOffset
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	byte14 = image[14]
	byte15 = image[15]
	byte16 = image[16]
	byte17 = image[17]
'
	headerSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14
'
	info = 14
'
	IF (headerSize = 12) THEN							' BITMAPCOREINFO
		w0 = image[info+4]
		w1 = image[info+5]
		h0 = image[info+6]
		h1 = image[info+7]
		b0 = image[info+10]
		b1 = image[info+11]
		width = (w1 << 8) OR w0
		height = (h1 << 8) OR h0
		bitsPerPixel = (b1 << 8) OR b0
	ELSE																	' BITMAPINFO
		w0 = image[info+4]
		w1 = image[info+5]
		w2 = image[info+6]
		w3 = image[info+7]
		h0 = image[info+8]
		h1 = image[info+9]
		h2 = image[info+10]
		h3 = image[info+11]
		b0 = image[info+14]
		b1 = image[info+15]
		width = (w3 << 24) OR (w2 << 16) OR (w1 << 8) OR w0
		height = (h3 << 24) OR (h2 << 16) OR (h1 << 8) OR h0
		bitsPerPixel = (b1 << 8) OR b0
	END IF
'
'
' color masks for 32-bit DIB
'
	redMask = 0xFFC00000									' 10 bits
	greenMask = 0x003FF800								' 11 bits
	blueMask = 0x000007FF									' 11 bits
'
	swidth = width												' DIB width
	sheight = height											' DIB height
'
	dwidth = window[window].width					' pixmap width
	dheight = window[window].height				' pixmap height
'
	IF (dwidth <= 0) THEN RETURN ($$FALSE)
	IF (dheight <= 0) THEN RETURN ($$FALSE)
'
	IF (width > dwidth) THEN width = dwidth
	IF (height > dheight) THEN height = dheight

	gc = window[window].gc								' system gc
	depth = display[display].depth				' system depth
	visual = display[display].visual			' system visual
	swindow = window[window].swindow			' system window # of pixmap
	sdisplay = window[window].sdisplay		' system display #
	colormap = display[display].colormap	' system colormap #
'
' get XImage - XWindows memory "image" for the existing pixmap
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSync (sdisplay, 0)
	ximage = XGetImage (sdisplay, simage, 0, 0, dwidth, dheight, $$AllPlanes, $$ZPixmap)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	flushTime = eventTime
'
	IFZ ximage THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrSetImage() : XGetImage() failed"
		RETURN ($$TRUE)
	END IF
'
' create a "color cache" to avoid XAllocColor() for repeated colors
'
	DIM sc[255]														' create color cache for speed
	FOR i = 0 TO 255
		sc[i].scolor = -1										' mark as available
	NEXT i
'
' transfer the DIB image to the pixmap
'
'	PRINT "display,window,sdisplay,swindow,gc,depth,colormap,swidth,sheight,dwidth,dheight,width,height"
'	PRINT display; window;; HEX$(sdisplay);; HEX$(swindow);; HEX$(gc); depth;; HEX$(colormap); swidth; sheight; dwidth; dheight; width; height
'
	data = dataOffset
	saddr = &image[] + dataOffset
'
	SELECT CASE bitsPerPixel
		CASE 24		: GOSUB DIB24
		CASE 32		: GOSUB DIB32
	END SELECT
'
' put image into pixmap = image grid
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XPutImage (sdisplay, simage, gc, ximage, 0, 0, 0, 0, width, height)
	XDestroyImage (ximage)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
'
' *****  DIB24  *****
'
SUB DIB24
	upper = UBOUND (sc[])
	FOR y = 0 TO sheight - 1
		IF (y >= dheight) THEN EXIT FOR
		FOR x = 0 TO swidth - 1
			blue = image[data]	: INC data					' 8-bit blue
			green = image[data]	: INC data					' 8-bit green
			red = image[data]		: INC data					' 8-bit red
			IF (x < dwidth) THEN
				red = red << 8
				green = green << 8
				blue = blue << 8
				sc.scolor = 0													' return pixel #
				sc.r = red														' log 16-bit red
				sc.g = green													' log 16-bit green
				sc.b = blue														' log 16-bit blue
'
' first try to find color in color cache
'
				scolor = -1
				FOR slot = 0 TO upper
					IF (sc[slot].scolor = -1) THEN EXIT FOR		' past entries
					IF (sc[slot].r != red) THEN DO NEXT				' no match red
					IF (sc[slot].g != green) THEN DO NEXT			' no match green
					IF (sc[slot].b != blue) THEN DO NEXT			' no match blue
					scolor = sc[slot].scolor									' repeated color
				NEXT slot
'
				IF (scolor < 0) THEN
					##WHOMASK = 0
					##LOCKOUT = $$TRUE
					okay = XAllocColor (sdisplay, colormap, &sc)
					##LOCKOUT = lockout
					##WHOMASK = whomask
					scolor = sc.scolor
					IF (slot < upper) THEN
						sc[slot].scolor = sc.scolor
						sc[slot].r = red
						sc[slot].g = green
						sc[slot].b = blue
					END IF
				END IF
'
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				XPutPixel (ximage, x, y, scolor)
				##LOCKOUT = lockout
				##WHOMASK = whomask
			END IF
		NEXT x
		data = (data + 3) AND -4
	NEXT y
END SUB
'
'
' *****  DIB32  *****
'
SUB DIB32
	upper = UBOUND (sc[])
	FOR y = 0 TO sheight - 1
		IF (y >= dheight) THEN EXIT FOR
		FOR x = 0 TO swidth - 1
			pixel = XLONGAT (saddr)									' pixel rgb = 10-11-11 bits
			saddr = saddr + 4												' 4 bytes per pixel
			IF (x < dwidth) THEN
				red = (pixel AND redMask) >> 22				' 10-bit red
				green = (pixel AND greenMask) >> 11		' 11-bit green
				blue = (pixel AND blueMask) >> 0			' 11-bit blue
				sc.scolor = 0													' return pixel #
				red = red << 6												' 16-bit red
				green = green << 5										' 16-bit green
				blue = blue << 5											' 16-bit blue
				sc.r = red														' log 16-bit red
				sc.g = green													' log 16-bit green
				sc.b = blue														' log 16-bit blue
'
' first try to find color in color cache
'
				scolor = -1
				FOR slot = 0 TO upper
					IF (sc[slot].scolor = -1) THEN EXIT FOR		' past entries
					IF (sc[slot].r != red) THEN DO NEXT				' no match red
					IF (sc[slot].g != green) THEN DO NEXT			' no match green
					IF (sc[slot].b != blue) THEN DO NEXT			' no match blue
					scolor = sc[slot].scolor									' repeated color
				NEXT slot
'
				IF (scolor < 0) THEN
					##WHOMASK = 0
					##LOCKOUT = $$TRUE
					okay = XAllocColor (sdisplay, colormap, &sc)
					##LOCKOUT = lockout
					##WHOMASK = whomask
					scolor = sc.scolor
					IF (slot < upper) THEN
						sc[slot].scolor = sc.scolor
						sc[slot].r = red
						sc[slot].g = green
						sc[slot].b = blue
					END IF
				END IF
'
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				XPutPixel (ximage, x, y, scolor)
				##LOCKOUT = lockout
				##WHOMASK = whomask
			END IF
		NEXT x
	NEXT y
END SUB
END FUNCTION
'
'
' ################################
' #####  XgrGetMouseInfo ()  #####
' ################################
'
FUNCTION  XgrGetMouseInfo (window, grid, x, y, state, time)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	grid = display[1].mouseGrid
	window = display[1].mouseWindow
	x = display[1].mouseX
	y = display[1].mouseY
	state = display[1].mouseState
	time = display[1].mouseTime + 1
END FUNCTION
'
'
' #####################################
' #####  XgrGetSelectedWindow ()  #####
' #####################################
'
FUNCTION  XgrGetSelectedWindow (window)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	window = display[1].selectedWindow
END FUNCTION
'
'
' ########################################
' #####  XgrGetTextSelectionGrid ()  #####
' ########################################
'
FUNCTION  XgrGetTextSelectionGrid (@grid)
	SHARED  textSelectionGrid
	SHARED  debug
'
	grid = textSelectionGrid
END FUNCTION
'
'
' #####################################
' #####  XgrSetSelectedWindow ()  #####
' #####################################
'
FUNCTION  XgrSetSelectedWindow (window)
'
	return = XgrDisplayWindow (window)
	RETURN (return)
END FUNCTION
'
'
' ########################################
' #####  XgrSetTextSelectionGrid ()  #####
' ########################################
'
FUNCTION  XgrSetTextSelectionGrid (grid)
	SHARED  textSelectionGrid
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF grid THEN
		IF InvalidGrid (grid) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrSetTextSelectionGrid() : invalid grid #"; grid
			RETURN ($$TRUE)
		END IF
	END IF
'
	IF grid THEN
		IF (grid != textSelectionGrid) THEN
			IF textSelectionGrid THEN
				IF window[grid].window THEN
					IFZ window[grid].destroy THEN
						IFZ window[grid].destroyed THEN
							IFZ window[grid].destroyProcessed THEN
								XgrAddMessage (textSelectionGrid, #LostTextSelection, 0, 0, 0, 0, 0, textSelectionGrid)
							END IF
						END IF
					END IF
				END IF
			END IF
		END IF
	END IF
	textSelectionGrid = grid
END FUNCTION
'
'
' ##############################
' #####  XgrAddMessage ()  #####
' ##############################
'
' Because timers and possibly other activities are asynchronous,
' the inQueue and mess[] variables exist to avoid damage to the
' message queue caused by updating the queue while it is already
' being updated by another instance of XgrAddMessage() or any
' other queue manipulating function.
'
FUNCTION  XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
	SHARED  MESSAGE  message[]
	SHARED	WINDOW  window[]
	SHARED	userCount
	SHARED	sysCount
	SHARED  userOut
	SHARED	sysOut
	SHARED	userIn
	SHARED  sysIn
	SHARED  inQueue
	SHARED	debug
	STATIC  uuuuu
	STATIC  inHold
	STATIC  MESSAGE  mess[]
'
	IF #trace THEN PRINT "XgrAddMessage() : "; window; message; v0; v1; v2; v3; r0; r1;; sysCount; sysOut; sysIn, userCount; userOut; userIn
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ mess[] THEN
		##WHOMASK = 0
		DIM mess[15]
		##WHOMASK = whomask
		umess = UBOUND (mess[])
	END IF
'
' If XgrAddMessage() previously received one or more message that it
' counldn't add to the message queue because a previous instance of a
' message queue manipulating function is in the process of updating
' the message queue variables, it added the message to the holding
' queue instead.  Move these messages in the holding queue to the
' message queue before adding this message to the message queue.
'
	IF inHold THEN GOSUB EmptyHoldingQueue
'
' If XgrAddMessage() is called while message queue variables are being
' updated (inQueue != 0), add message to synchronizing message queue.
'
	IF inQueue THEN
		GOSUB AddToHoldingQueue
		RETURN ($$FALSE)
	END IF
'
' programmer can add any message to queue - XgrProcessMessages() checks
'
' get "count,out,in" variables for window owner - either user or system
'
	who = window[window].whomask
	IF who THEN queue = 1 ELSE queue = 0
'
' create message queue array and the required message queue if necessary
'
	IFZ message[] THEN CreateQueue (queue)					' create message queue array
	IFZ message[queue,] THEN CreateQueue (queue)		' create needed message queue
	upper = UBOUND (message[queue,])
'
' make sure the message array and message queue exist, just to be sure
'
	IFZ message[queue,] THEN
		##ERROR = ($$ErrorObjectQueue << 8) OR $$ErrorNatureNonexistent
		IF debug THEN
			PRINT "XgrAddMessage() : disaster : CreateQueue() failed : ";
			IF queue THEN PRINT "user queue" ELSE PRINT "system queue"
		END IF
		RETURN ($$TRUE)
	END IF
'
' get local variables from appropriate queue variables
'
	IF inQueue THEN PRINT "XgrAddMessage() : inQueue"
	inQueue = $$TRUE
'
	IF queue THEN
		count = userCount
		out = userOut
		in = userIn
	ELSE
		count = sysCount
		out = sysOut
		in = sysIn
	END IF
'
' see if queue is full
'
	IF (count AND (out = in)) THEN
		##ERROR = ($$ErrorObjectQueue << 8) AND $$ErrorNatureFull
'		IF debug THEN
			PRINT "XgrAddMessage() : message queue full : message lost : ";
			IF queue THEN PRINT "user queue" ELSE PRINT "system queue"
'		END IF
		inQueue = $$FALSE
		RETURN ($$TRUE)
	END IF
'
' put message in queue
'
	message[queue,in].wingrid = window
	message[queue,in].message = message
	message[queue,in].v0 = v0
	message[queue,in].v1 = v1
	message[queue,in].v2 = v2
	message[queue,in].v3 = v3
	message[queue,in].r0 = r0
	message[queue,in].r1 = r1
'
' update appropriate queue variables
'
	IF queue THEN
		INC userCount
		INC userIn
		IF (userIn > upper) THEN userIn = 0
		IF (userCount > upper) THEN PRINT "XgrAddMessage() : (userCount > upper)"
	ELSE
		INC sysCount
		INC sysIn
		IF (sysIn > upper) THEN sysIn = 0
		IF (sysCount > upper) THEN PRINT "XgrAddMessage() : (sysCount > upper)"
	END IF
'
	inQueue = $$FALSE
	IF inHold THEN GOSUB EmptyHoldingQueue
	RETURN ($$FALSE)
'
'
' *****  EmptyHoldingQueue  *****
'
SUB EmptyHoldingQueue
'	write (1, &"(empty", 6)
	GOSUB GetUnique											' unique = a unique value
	IF inHold THEN											' something in holding queue
		IFZ inQueue THEN									' not updating queue variables
			FOR m = 0 TO UBOUND (mess[])		' check all messages
				mess = mess[m].message				' check message
				IF (mess > 0) THEN						' not being processed
					mess[m].message = -unique		' mark as being processed
					check = mess[m].message			' sync check - still in sync?
					IF (check = -unique) THEN		' sync okay - add to queue
						DEC inHold								' one less in holding queue
						wg = mess[m].wingrid
						mm = mess
						a0 = mess[m].v0
						a1 = mess[m].v1
						a2 = mess[m].v2
						a3 = mess[m].v3
						a4 = mess[m].r0
						a5 = mess[m].r1
						mess[m].message = 0				' now available
						XgrAddMessage (wg, mm, a0, a1, a2, a3, a4, a5)
					END IF
				END IF
			NEXT m
		END IF
	END IF
'	write (1, &")", 1)
END SUB
'
'
' *****  AddToHoldingQueue  *****
'
SUB AddToHoldingQueue
'	write (1, &"{add", 4)
	GOSUB GetUnique												' unique = a unique value
	added = $$FALSE												' message not yet added
	DO
		FOR m = 0 TO UBOUND (mess[])
			mess = mess[m].message						' slot available
			IFZ mess THEN
				mess[m].message = -unique				' reserve with -unique value
				check = mess[m].message					' sync check - still -unique?
				IF (check = -unique) THEN				' sync okay - add to mess
					mess[m].r1 = r1
					mess[m].r0 = r0
					mess[m].v3 = v3
					mess[m].v2 = v2
					mess[m].v1 = v1
					mess[m].v0 = v0
					mess[m].wingrid = window
					mess[m].message = message			' valid message
					INC inHold										' now available
					INC added											' message added
					EXIT FOR
				END IF
			END IF
		NEXT m
		IFZ added THEN
			umess = UBOUND (mess[])
			umess = umess + 16
			##WHOMASK = 0
			REDIM mess[umess]
			##WHOMASK = whomask
			umess = UBOUND (umess[])
		END IF
	LOOP UNTIL added
'	write (1, &"}", 1)
END SUB
'
'
' *****  GetUnique  *****
'
SUB GetUnique
	DO
		u = uuuuu
		INC uuuuu
		unique = uuuuu - 1
	LOOP UNTIL (u = unique)										' unique is a unique value
	IF (uuuuu >= 0x7FFFFF00) THEN uuuuu = 1		' recycle unique counter
END SUB
END FUNCTION
'
'
' ##################################
' #####  XgrDeleteMessages ()  #####
' ##################################
'
FUNCTION  XgrDeleteMessages (count)
	SHARED  MESSAGE  message[]
	SHARED  userCount
	SHARED  sysCount
	SHARED  userOut
	SHARED  sysOut
	SHARED  userIn
	SHARED  sysIn
	SHARED  inQueue
	SHARED  debug
'
	IF #trace THEN PRINT "XgrDeleteMessages() : "; count
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	queue = 0																				' 0 = sys
	IF whomask THEN queue = 1												' 1 = user
	IFZ count THEN RETURN ($$FALSE)									' remove none
	IF (count < -1) THEN RETURN ($$TRUE)						' bad argument
	IFZ message[] THEN RETURN ($$FALSE)							' no queues at all
	IFZ message[queue,] THEN RETURN ($$FALSE)				' no queue yet
	upper = UBOUND (message[queue,])
'
	IF inQueue THEN PRINT "XgrDeleteMessages() : inQueue"
	inQueue = $$TRUE
'
	DO WHILE count
		IFZ queue THEN
			IFZ sysCount THEN EXIT DO										' queue empty
			DEC sysCount
			INC sysOut
			IF (sysOut > upper) THEN sysOut = 0					' wrap around
		ELSE
			IFZ userCount THEN EXIT DO									' queue empty
			DEC userCount
			INC userOut
			IF (userOut > upper) THEN userOut = 0				' wrap around
		END IF
		DEC count
	LOOP
'
	inQueue = $$FALSE
END FUNCTION
'
'
' ##########################
' #####  XgrGetCEO ()  #####
' ##########################
'
FUNCTION  XgrGetCEO (func)
	SHARED	userCEO
	SHARED	sysCEO
'
	IF ##WHOMASK THEN func = userCEO ELSE func = sysCEO
END FUNCTION
'
'
' ###############################
' #####  XgrGetMessages ()  #####
' ###############################
'
FUNCTION  XgrGetMessages (@count, MESSAGE m[])
	SHARED  MESSAGE  message[]
	SHARED  userCount
	SHARED  sysCount
	SHARED  userOut
	SHARED  sysOut
	SHARED  inQueue
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF inQueue THEN PRINT "XgrGetMessages() : inQueue"
	inQueue = $$TRUE
'
	DIM m[]
'
	IF whomask THEN																' user count, out, queue
		count = userCount
		out = userOut
		queue = 1
	ELSE																					' system count, out, queue
		queue = 0
		out = sysOut
		count = sysCount
	END IF
'
	IF (count <= 0) THEN													' no messages
		inQueue = $$FALSE
		RETURN ($$FALSE)
	END IF
'
	upper = UBOUND (message[queue,])							' message queue
	top = count - 1																' upper bound
	DIM m[top]																		' return array
'
	FOR i = 0 TO top
		m[i] = message[queue,out]
		IF (out = upper) THEN out = 0 ELSE INC out
	NEXT i
'
	inQueue = $$FALSE
END FUNCTION
'
'
' ##################################
' #####  XgrGetMessageType ()  #####
' ##################################
'
FUNCTION  XgrGetMessageType (message, @messageType)
	SHARED  message$[]
	SHARED  debug
'
	IF (message <= 0) THEN
		##ERROR = ($$ErrorObjectMessage << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "XgrGetMessageType() : invalid message # : (message <= 0) : "; message
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND (message$[])
	IF (message > upper) THEN
		##ERROR = ($$ErrorObjectMessage << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "XgrGetMessageType() : invalid message # : (message # too large) : "; message; upper
		RETURN ($$TRUE)
	END IF
'
	IFZ message$[message] THEN
		messageType = 0
		RETURN ($$FALSE)
	END IF
'
	messageType = $$Grid
	w = INSTR (message$[message], "Window")
	IF (w = 1) THEN messageType = $$Window
END FUNCTION
'
'
' ###############################
' #####  XgrGetMonitors ()  #####
' ###############################
'
FUNCTION  XgrGetMonitors (grid, MESSAGE r1[])
	SHARED  MESSAGE  monitor[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	DIM r1[]
	IF (grid < 0) THEN grid = 0
	IFZ monitor[] THEN RETURN ($$FALSE)
'
	IF grid THEN
		IF InvalidGrid (grid) THEN
			##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "XgrGetMonitor() : invalid grid #"; grid
			RETURN ($$TRUE)
		END IF
	END IF
'
	upper = UBOUND (monitor[])
	DIM r1[upper]
	slot = -1
'
	FOR i = 0 TO upper
		IF monitor[i].wingrid THEN
			IF monitor[i].message THEN
				IF ((grid = 0) OR (grid = monitor[i].wingrid)) THEN
					INC slot
					r1[slot] = monitor[i]
				END IF
			END IF
		END IF
	NEXT i
'
	IF (slot < 0) THEN DIM r1[] ELSE REDIM r1[slot]
END FUNCTION
'
'
' ##############################
' #####  XgrJamMessage ()  #####
' ##############################
'
FUNCTION  XgrJamMessage (window, message, v0, v1, v2, v3, r0, r1)
	SHARED  MESSAGE  message[]
	SHARED	WINDOW  window[]
	SHARED	userCount
	SHARED	sysCount
	SHARED  userOut
	SHARED	sysOut
	SHARED	userIn
	SHARED  sysIn
	SHARED  inQueue
	SHARED	debug
'
	IF #trace THEN PRINT "XgrJamMessage() : "; grid; message; v0; v1; v2; v3; r0; r1
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
' get "count,out,in" variables for window owner - either user or system
'
	who = window[window].whomask
	IF who THEN queue = 1 ELSE queue = 0
'
' create message queue array and the required message queue if necessary
'
	IFZ message[] THEN CreateQueue (queue)					' create message queue array
	IFZ message[queue,] THEN CreateQueue (queue)		' create needed message queue
	upper = UBOUND (message[queue,])
'
' make sure the message array and message queue exist, just to be sure
'
	IFZ message[queue,] THEN
		##ERROR = ($$ErrorObjectQueue << 8) OR $$ErrorNatureNonexistent
		IF debug THEN
			PRINT "XgrJamMessage() : disaster : CreateQueue() failed : ";
			IF queue THEN PRINT "user queue" ELSE PRINT "system queue"
		END IF
		RETURN ($$TRUE)
	END IF
'
' get local variables from appropriate queue variables
'
	IF inQueue THEN PRINT "XgrJamMessage() : inQueue"
	inQueue = $$TRUE
'
	IF queue THEN
		count = userCount
		out = userOut
		in = userIn
	ELSE
		count = sysCount
		out = sysOut
		in = sysIn
	END IF
'
' see if queue is full
'
	IF (count AND (out = in)) THEN
		##ERROR = ($$ErrorObjectQueue << 8) AND $$ErrorNatureFull
'		IF debug THEN
			PRINT "XgrJamMessage() : message queue full : message lost :";
			IF queue THEN PRINT " user queue" ELSE PRINT " system queue"
'		END IF
		inQueue = $$FALSE
		RETURN ($$TRUE)
	END IF
'
' update appropriate queue variables
'
	IF queue THEN
		INC userCount
		DEC userOut
		IF (userOut < 0) THEN userOut = upper
		IF (userCount > upper) THEN PRINT "XgrJamMessage() : (userCount > upper)"
	ELSE
		INC sysCount
		DEC sysOut
		IF (sysOut < 0) THEN sysOut = upper
		IF (sysCount > upper) THEN PRINT "XgrJamMessage() : (sysCount > upper)"
	END IF
'
' update variables
'
	IF queue THEN
		count = userCount
		out = userOut
		in = userIn
	ELSE
		count = sysCount
		out = sysOut
		in = sysIn
	END IF
'
'
' jam message in queue (put in the output end)
'
	message[queue,out].wingrid = window
	message[queue,out].message = message
	message[queue,out].v0 = v0
	message[queue,out].v1 = v1
	message[queue,out].v2 = v2
	message[queue,out].v3 = v3
	message[queue,out].r0 = r0
	message[queue,out].r1 = r1
'
	inQueue = $$FALSE
END FUNCTION
'
'
' #######################################
' #####  XgrMessageNameToNumber ()  #####
' #######################################
'
FUNCTION  XgrMessageNameToNumber (message$, message)
	SHARED  lastMessage
	SHARED  message$[]
	SHARED  debug
'
	message = 0
	IFZ message$ THEN RETURN ($$FALSE)
	IFZ message$[] THEN RETURN ($$FALSE)
'
	IF (message$ = "LastMessage") THEN
		message = lastMessage
		RETURN ($$FALSE)
	END IF
'
	FOR i = 0 TO UBOUND (message$[])
		IF (message$ = message$[i]) THEN message = i : EXIT FOR
	NEXT i
END FUNCTION
'
'
' ################################
' #####  XgrMessageNames ()  #####
' ################################
'
FUNCTION  XgrMessageNames (count, mess$[])
	SHARED  message$[]
'
	count = 0
	IFZ message$[] THEN RETURN ($$FALSE)
	upper = UBOUND (message$[])
	count = upper + 1
	DIM mess$[upper]
'
	FOR i = 0 TO upper
		mess$[i] = message$[i]
	NEXT i
END FUNCTION
'
'
' #######################################
' #####  XgrMessageNumberToName ()  #####
' #######################################
'
FUNCTION  XgrMessageNumberToName (message, message$)
	SHARED  message$[]
	SHARED  debug
'
	message$ = ""
	IFZ message THEN RETURN ($$FALSE)
	IFZ message$[] THEN RETURN ($$FALSE)
'
	IF (message < 0) THEN
		##ERROR = ($$ErrorObjectMessage << 8) OR $$ErrorNatureInvalidNumber
		IF debug THEN PRINT "XgrMessageNumberToName() : (message < 0)"
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND (message$[])
	IF (message > upper) THEN RETURN ($$FALSE)
	message$ = message$[message]
END FUNCTION
'
'
' ###################################
' #####  XgrMessagesPending ()  #####
' ###################################
'
FUNCTION  XgrMessagesPending (count)
	SHARED	userCount
	SHARED	sysCount
'
	IF ##WHOMASK THEN count = userCount ELSE count = sysCount
	IFZ count THEN
		DispatchEvents ($$TRUE, $$FALSE)
		IF ##WHOMASK THEN count = userCount ELSE count = sysCount
	END IF
END FUNCTION
'
'
' ###########################
' #####  XgrMonitor ()  #####
' ###########################
'
FUNCTION  XgrMonitor (grid, message, v0, v1, v2, v3, r0, r1)
	SHARED  MESSAGE  monitor[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrMonitor() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	SELECT CASE message
		CASE #MonitorContext		: error = $$FALSE
		CASE #MonitorHelp				: error = $$FALSE
		CASE #MonitorKeyboard		: error = $$FALSE
		CASE #MonitorMouse			: error = $$FALSE
		CASE ELSE								: error = $$TRUE
	END SELECT
'
	IF error THEN
		XgrMessageNumberToName (message, @message$)
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidMessage
		IF debug THEN PRINT "XgrMonitor() : invalid message argument : "; message$
		RETURN ($$TRUE)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	IFZ monitor[] THEN DIM monitor[15]		' first monitor request
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	return = $$FALSE											' no error
	upper = UBOUND (monitor[])						' last existing monitor slot
'
	SELECT CASE r1
		CASE $$FALSE	: GOSUB Remove
		CASE $$TRUE		: GOSUB Install
		CASE ELSE			: GOSUB Broken
	END SELECT
	RETURN (return)
'
' *****  Remove  *****
'
SUB Remove
	FOR i = 0 TO upper
		IF (grid = monitor[i].wingrid) THEN
			IF (message = monitor[i].message) THEN
				monitor[i].message = 0
				monitor[i].wingrid = 0
			END IF
		END IF
	NEXT i
END SUB
'
' *****  Install  *****
'
SUB Install
END SUB
'
' *****  Broken  *****
'
SUB Broken
	##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidCommand
	IF debug THEN PRINT "XgrMonitor() : invalid command in r1"
	return = $$TRUE
END SUB
END FUNCTION
'
'
' ###############################
' #####  XgrPeekMessage ()  #####
' ###############################
'
FUNCTION  XgrPeekMessage (wingrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  MESSAGE  message[]
	SHARED  userCount
	SHARED  sysCount
	SHARED  userOut
	SHARED  sysOut
	SHARED  userIn
	SHARED  sysIn
	SHARED  inQueue
	SHARED  debug
	SHARED	huh
'
	IF #trace THEN PRINT "XgrPeekMessage() : "; wingrid; message; v0; v1; v2; v3; r0; r1
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	wingrid = 0 : message = 0 : v0 = 0 : v1 = 0 : v2 = 0 : v3 = 0 : r0 = 0 : r1 = 0
'
	queue = 0
	IF whomask THEN queue = 1
'
'	a$ = "XgrPeekMessage().A : " + STRING$(queue) + "\n"
'	write (1, &a$, LEN(a$))
'
	IFZ message[] THEN RETURN ($$TRUE)
	IFZ message[queue,] THEN RETURN ($$TRUE)
'
'	a$ = "XgrPeekMessage().B : " + STRING$(queue) + "\n"
'	write (1, &a$, LEN(a$))
'
' wait for message in system or user queue to appear
'
	DO
		IF inQueue THEN PRINT "XgrPeekMessage().A : inQueue"
'		a$ = "XgrPeekMessage().C : " + STRING$(queue) + "\n"
'		write (1, &a$, LEN(a$))
		inQueue = $$TRUE
		GOSUB UpdateVariables
		inQueue = $$FALSE
'		a$ = "XgrPeekMessage().D : " + STRING$(queue) + "." + STRING$(count) + "." + STRING$(sysCount) + "." + STRING$(userCount) + "\n"
'		write (1, &a$, LEN(a$))
		IF count THEN EXIT DO
		IF huh THEN XxxXstLog ("{")
'		a$ = "XgrPeekMessage().E : " + STRING$(queue) + "." + STRING$(count) + "." + STRING$(sysCount) + "." + STRING$(userCount) + "\n"
'		write (1, &a$, LEN(a$))
		XxxCheckMessages ()
'		a$ = "XgrPeekMessage().F : " + STRING$(queue) + "." + STRING$(count) + "." + STRING$(sysCount) + "." + STRING$(userCount) + "\n"
'		write (1, &a$, LEN(a$))
		DispatchEvents ($$TRUE, $$TRUE)
		IF ##SOFTBREAK THEN EXIT DO
'		a$ = "XgrPeekMessage().G : " + STRING$(queue) + "." + STRING$(count) + "." + STRING$(sysCount) + "." + STRING$(userCount) + "\n"
'		write (1, &a$, LEN(a$))
		IF huh THEN XxxXstLog ("}")
	LOOP
'
'	a$ = "XgrPeekMessage().H : " + STRING$(queue) + "\n"
'	write (1, &a$, LEN(a$))
'
	IF ##SOFTBREAK THEN RETURN ($$TRUE)
'
'	a$ = "XgrPeekMessage().I : " + STRING$(queue) + "\n"
'	write (1, &a$, LEN(a$))
'
' get message arguments from queue
'
	inQueue = $$TRUE
	wingrid = message[queue,out].wingrid
	message = message[queue,out].message
	v0 = message[queue,out].v0
	v1 = message[queue,out].v1
	v2 = message[queue,out].v2
	v3 = message[queue,out].v3
	r0 = message[queue,out].r0
	r1 = message[queue,out].r1
	inQueue = $$FALSE
'
'	XgrMessageNumberToName (message, @message$)
'	a$ = "XgrPeekMessage().Z : " + STRING$(queue) + " : " + STRING$(wingrid) + "," + message$ + "," + STRING$(v0) + "\n"
'	write (1, &a$, LEN(a$))
	RETURN ($$FALSE)
'
'
' *****  UpdateVariables  *****
'
SUB UpdateVariables
	IF queue THEN
		count = userCount
		out = userOut
		in = userIn
	ELSE
		count = sysCount
		out = sysOut
		in = sysIn
	END IF
END SUB
END FUNCTION
'
'
' ###################################
' #####  XgrProcessMessages ()  #####
' ###################################
'
' If a modal window is set for the system/user who calls
' XgrProcessMessages(), all keyboard messages are sent to
' the modal window and all mouse messages outside the modal
' window are removed from the queue and discarded (ignored).
'
' XgrProcessMessages() has first chance to clear out the window
' or grid information in window[] after it processes a #Destroyed
' or #WindowDestroyed message.  This work can't be done in the
' EventDestroyNotify() function or before, because this function
' needs the grid function or window function address, and the
' function it calls might need other data.
'
' Are MonitorContext, MonitorHelp, MonitorKeyboard, MonitorMouse
' handled in this XgrProcessMessages() function, or in GuiDesigner ???
'
FUNCTION  XgrProcessMessages (argCount)
	SHARED  DISPLAY  display[]
	SHARED  MESSAGE  message[]
	SHARED  MESSAGE  monitor[]
	SHARED	WINDOW  window[]
	SHARED  modalWindowSystem
	SHARED  modalWindowUser
	SHARED  userCEO
	SHARED  sysCEO
	SHARED	userCount
	SHARED	sysCount
	SHARED  userOut
	SHARED	sysOut
	SHARED	userIn
	SHARED  sysIn
	SHARED  inQueue
	SHARED	debug
	SHARED	huh
	SHARED	window$[]
	STATIC  WINDOW  winzip
	STATIC	trips
	MESSAGE m[]
	FUNCADDR  ceo (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	IF #trace THEN PRINT "XgrProcessMessages() : "; argCount;; sysCount;; sysOut;; sysIn;; userCount;; userOut;; userIn
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	INC trips
	IF huh THEN
		trips$ = STRING$ (trips)
		IF whomask THEN
			trips$ = "<u" + STRING$(trips) + "."
		ELSE
			trips$ = "<s" + STRING$(trips) + "."
		END IF
		IF huh THEN XxxXstLog (@trips$)
	END IF
'
	IF ##SOFTBREAK THEN
'		XxxGetEbpEsp (@ebp, @esp)
'		a$ = "  ebp = " + HEX$(  ebp,8) + "     esp = " + HEX$(  esp,8) + "\n"
'		xebp = XLONGAT(ebp) : xesp = XLONGAT (ebp,4)
'		b$ = " xebp = " + HEX$( xebp,8) + "    xesp = " + HEX$( xesp,8) + "\n"
'		xxebp = XLONGAT(xebp) : xxesp = XLONGAT (xebp,4)
'		c$ = "xxebp = " + HEX$(xxebp,8) + "   xxesp = " + HEX$(xxesp,8) + "\n"
'		write (1, &a$, LEN(a$))
'		write (1, &b$, LEN(b$))
'		write (1, &c$, LEN(c$))
		IF huh THEN
			IF whomask THEN
				DEC trips
				XxxXstLog ("u>")
			ELSE
				DEC trips
				XxxXstLog ("s>")
			END IF
		END IF
		RETURN ($$FALSE)
	END IF
'
	IF whomask THEN GOSUB ProcessSystemMessages
	IF huh THEN XxxXstLog ("A")
'
' get "count,out,in" variables for window owner - either user or system
'
	queue = 0																				' system queue
	IF whomask THEN queue = 1												' user queue
'
' see if message queue array and the required message queue exist
'
	noQueue = $$FALSE
	IFZ message[] THEN
		noQueue = $$TRUE															' no message queue at all
	ELSE
		IFZ message[queue,] THEN noQueue = $$TRUE			' no queue for sys/user
	END IF
'
	IF noQueue THEN CreateQueue (queue)							' create a queue
'
	noQueue = $$FALSE
	IFZ message[] THEN
		noQueue = $$TRUE															' no message queue at all
	ELSE
		IFZ message[queue,] THEN noQueue = $$TRUE			' no queue for sys/user
	END IF
'
	IF noQueue THEN															' no queue means no messages
		##ERROR = ($$ErrorObjectQueue << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrProcessMessages() : message queue doesn't exist"
		IF huh THEN XxxXstLog ("a>")
		DEC trips
		RETURN ($$FALSE)
	END IF
'
' get local variables from appropriate queue variables
'
	GOSUB UpdateVariables
'
' if zero messages requested, return if there are none
'
	IFZ argCount THEN
		IFZ count THEN
			IF huh THEN XxxXstLog ("B")
			DispatchEvents ($$TRUE, $$FALSE)	' xlib events to sys/user queues
			IF huh THEN XxxXstLog ("C")
			GOSUB UpdateVariables
			IF huh THEN XxxXstLog ("D")
			IFZ count THEN
				IF huh THEN XxxXstLog ("E")
				UpdateMouse (whomask)				' generate #MouseMove if mouse moved
				IF huh THEN XxxXstLog ("F")
				GOSUB UpdateVariables
				IF huh THEN XxxXstLog ("G")
				IFZ count THEN
					IF huh THEN XxxXstLog ("b>")
					DEC trips
					RETURN ($$FALSE)					' argCount = 0, no messages, return
				END IF
			END IF
		END IF
		argCount = 1										' process 1 message, then return
	END IF
'
' need at least one open sdisplay
'
	sdisplay = 0
	upper = UBOUND (display[])
'
	FOR i = 0 TO upper
		sdisplay = display[i].sdisplay
		IF sdisplay THEN display = i : EXIT FOR
	NEXT i
'
	IFZ sdisplay THEN
		##ERROR = ($$ErrorObjectDisplay << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrProcessMessages() : no open display"
		IF huh THEN XxxXstLog ("c>")
		DEC trips
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND (window[])
'
' flush event queue if not enough messages in queue to satisfy argCount request
'
	IF (argCount = -2) THEN
		DispatchEvents ($$TRUE, $$FALSE)
		GOSUB UpdateVariables
	END IF
'
	IF (argCount > 0) THEN
		IF (argCount > count) THEN
			IF huh THEN XxxXstLog ("H")
			DispatchEvents ($$TRUE, $$FALSE)
			IF huh THEN XxxXstLog ("I")
		END IF
	END IF
'
' process all pending system messages first
'
	IF whomask THEN GOSUB ProcessSystemMessages
'
' if messages are exhausted before count messages are processed,
' change event mask to enable mouse motion events.
'
	motion = 0
	removed = 0
	GOSUB UpdateVariables
	IF ((argCount = -2) AND (count = 0)) THEN
		IF huh THEN XxxXstLog ("d>")
		DEC trips
		RETURN ($$FALSE)
	END IF
'
	DO
		window = queue
		DO UNTIL count											' wait for system/user message
			IF huh THEN XxxXstLog ("J")
			UpdateMouse (whomask)							' see if mouse moved
			IF huh THEN XxxXstLog ("K")
			GOSUB UpdateVariables							' update count variable
			IFZ (count OR motion) THEN				' if no messages...
				GOSUB EnableMotion							' enable mouse motion events
			END IF
			IF huh THEN XxxXstLog ("L")
			IF ##SOFTBREAK THEN EXIT DO				' break out
			DispatchEvents ($$TRUE, $$TRUE)		' sync and wait for event
			IF ##SOFTBREAK THEN EXIT DO				' break out of message loop
			IF huh THEN XxxXstLog ("M")
			IF whomask THEN										' if user program called
				IF sysCount THEN								' and system messages exist
					GOSUB ProcessSystemMessages		' process system messages first
				END IF
			END IF
			GOSUB UpdateVariables							' update count variable
		LOOP UNTIL ##SOFTBREAK							' signals make this func return
		IF ##SOFTBREAK THEN EXIT DO
'
		RemoveMessage (@window, @message, @v0, @v1, @v2, @v3, @r0, @r1)
		IF huh THEN XxxXstLog ("N."+STRING$(window)+"."+STRING$(sysCount)+".N")
'		XgrMessageNumberToName (message, @message$)
'		m$ = RJUST$(STRING$(window),4) + "  " + message$ + "\n"
'		write (1, &m$, LEN(m$))
'		SELECT CASE message
'			CASE #WindowDestroyed
'						a$ = "XgrProcessMessages() : #WindowDestroyed : " + STRING$(window) + "\n"
'						write (1, &a$, LEN(a$))
'			CASE #Destroyed
'						a$ = "XgrProcessMessages() : #Destroyed : " + STRING$(window) + "\n"
'						write (1, &a$, LEN(a$))
'		END SELECT
		IF (message = #ExitMessageLoop) THEN EXIT DO
		IF huh THEN XxxXstLog ("." + STRING$(window) + ":")
'
		invalid = $$FALSE
		destroy = $$FALSE
		destroyed = $$FALSE
		processed = $$FALSE
		IF (window < 0) THEN invalid = $$TRUE
		IF (window > upper) THEN invalid = $$TRUE
		IFZ invalid THEN
			IFZ window[window].window THEN invalid = $$TRUE
			IFZ window[window].swindow THEN invalid = $$TRUE
			IF window[window].destroy THEN destroy = $$TRUE
			IF window[window].destroyed THEN destroyed = $$TRUE
			IF window[window].destroyProcessed THEN processed = $$TRUE
		END IF
		IFZ invalid THEN
			top = window[window].top
			who = window[top].whomask
			IF who THEN modal = modalWindowUser ELSE modal = modalWindowSystem
			IF modal THEN
				IF (top != modal) THEN
					SELECT CASE TRUE
						CASE MouseMessage (message)			' skip mouse messages not in modalWindow
									GOSUB UpdateVariables
									invalid = $$TRUE
'									PRINT "XgrProcessMessages() : modal.mouse.kill.message"
						CASE KeyboardMessage (message)
									window = modal						' send keyboard messages to modalWindow
'									PRINT "XgrProcessMessages() : modal.keyboard.redirect.message"
					END SELECT
					XgrMessageNumberToName (message, @message$)
'					PRINT "XgrProcessMessages().modality : "; HEX$(who,8);; HEX$(window,8);; HEX$(top,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; invalid;; message$
				END IF
			END IF
		END IF
		IFZ invalid THEN
			abort = $$FALSE
			func = window[window].gridFunc
			IF (window = top) THEN func = window[window].winFunc
			IF debug THEN
				XgrMessageNumberToName (message, @message$)
				PRINT "XgrProcessMessage() : "; window;; HEX$(window);; HEX$(message);; message$, HEX$(v0);; HEX$(v1);; HEX$(v2);; HEX$(v3);; HEX$(r0);; HEX$(r1), HEX$(func);; HEX$(whomask,8)
			END IF
			IF huh THEN XxxXstLog ("=" + STRING$(sysCount) + "=")
			IF ceo THEN
				IF huh THEN XxxXstLog ("<<")
				@ceo (window, message, v0, v1, v2, v3, @abort, r1)
				IF huh THEN XxxXstLog (">>")
			END IF
			IF huh THEN XxxXstLog ("_" + STRING$(sysCount) + "_")
			IF huh THEN
				IF abort THEN XxxXstLog ("!") ELSE XxxXstLog (">")
			END IF
			IF abort THEN
				PRINT "XgrProcessMessages().abort : "; HEX$(who,8);; HEX$(window,8);; HEX$(top,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; HEX$(func,8);; invalid;; abort;; message$
			ELSE
				IF func THEN
					IF huh THEN XxxXstLog ("[[")
					@func (window, message, v0, v1, v2, v3, r0, r1)
'					PRINT "XgrProcessMessages().callfunc : "; HEX$(who,8);; HEX$(window,8);; HEX$(top,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; invalid;; abort;; message$
					IF huh THEN XxxXstLog ("]]")
				END IF
			END IF
			IF huh THEN XxxXstLog ("~" + STRING$(sysCount) + "~")
			SELECT CASE message
				CASE #Destroyed				: window[window].destroyProcessed = $$TRUE
'																PRINT "#Destroyed : after @func() : "; window;; top;;; HEX$(func,8);; sysOut;; userOut
				CASE #WindowDestroyed	: window[window].destroyProcessed = $$TRUE
'																PRINT "#WindowDestroyed : after @func() : "; window;; top;;; HEX$(func,8);; sysOut;; userOut
			END SELECT
		END IF
		IF huh THEN XxxXstLog ("+" + STRING$(sysCount) + "+")
		INC removed
		GOSUB UpdateVariables
		IF huh THEN XxxXstLog ("?" + STRING$(sysCount) + "?")
		IF whomask THEN GOSUB ProcessSystemMessages
		IF huh THEN XxxXstLog ("U")
		SELECT CASE argCount
			CASE -2		: IFZ count THEN
										DispatchEvents ($$TRUE, $$FALSE)			' squeeze harder
										GOSUB UpdateVariables
										IFZ count THEN EXIT DO								' all processed
									END IF
			CASE -1		: IFZ count THEN EXIT DO									' all processed
			CASE ELSE	: IF (removed >= argCount) THEN EXIT DO		' complete
		END SELECT
		IF huh THEN XxxXstLog ("V")
	LOOP
'
	IF huh THEN
		IF whomask THEN
			trips$ = "." + STRING$(trips) + "u>"
		ELSE
			trips$ = "." + STRING$(trips) + "s>"
		END IF
		IF huh THEN XxxXstLog (@trips$)
	END IF
'
	IF motion THEN GOSUB DisableMotion
	DEC trips
	RETURN ($$FALSE)
'
'
' *****  EnableMotion  *****
'
SUB EnableMotion
	IF huh THEN XxxXstLog ("(")
	IF motion THEN EXIT SUB												'
	FOR w = 1 TO UBOUND (window[])								' for all windows
		IF window[w].destroyProcessed THEN DO NEXT	'
		IF window[w].destroyed THEN DO NEXT					'
		IF window[w].destroy THEN DO NEXT						'
		IF window[w].window THEN										' window exists
			windowWhomask = window[w].whomask					' system/user
			IF windowWhomask THEN windowWhomask = 1		' user queue
			IFZ (queue XOR windowWhomask) THEN				' same whomask
				mask = window[w].eventMask							' mask w/o mouse motion
				IF mask THEN														' belt and suspenders
					IFZ (mask AND $$PointerMotionMask) THEN	' motion not enabled
						mask = mask OR $$PointerMotionMask		' enable mouse motion
						smouseWindow = window[w].swindow			'
						IF smouseWindow THEN								' belt, suspenders, more
							##WHOMASK = 0
							##LOCKOUT = $$TRUE
							XSelectInput (sdisplay, smouseWindow, mask)		' enable motion
							##LOCKOUT = lockout
							##WHOMASK = whomask
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT w
	motion = $$TRUE
END SUB
'
'
' *****  DisableMotion  *****
'
SUB DisableMotion
	IF huh THEN XxxXstLog (")")
	IFZ motion THEN EXIT SUB											' motion never enabled
	FOR w = 1 TO UBOUND (window[])								'
		IF window[w].destroyProcessed THEN DO NEXT	'
		IF window[w].destroyed THEN DO NEXT					'
		IF window[w].destroy THEN DO NEXT						'
		IF window[w].window THEN										'
			windowWhomask = window[w].whomask					'
			IF windowWhomask THEN windowWhomask = 1		' who queue
			IFZ (queue XOR windowWhomask) THEN				' same whomask
				mask = window[w].eventMask							' mask w/o mouse motion
				IF mask THEN														' belt and suspenders
					IF (mask AND $$PointerMotionMask) THEN		' motion enabled
						mask = mask AND NOT $$PointerMotionMask	' disable mouse motion
						smouseWindow = window[w].swindow
						IF smouseWindow THEN								' belt, suspenders, more
							##WHOMASK = 0
							##LOCKOUT = $$TRUE
							XSelectInput (sdisplay, smouseWindow, mask)		' enable motion
							##LOCKOUT = lockout
							##WHOMASK = whomask
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT w
	motion = $$FALSE
END SUB
'
'
' *****  ProcessSystemMessages  *****
'
SUB ProcessSystemMessages
	IF huh THEN XxxXstLog ("X")
	DO WHILE sysCount
		##WHOMASK = $$FALSE										' system whomask
		XgrProcessMessages (0)								' process system message
		##WHOMASK = whomask										' restore user whomask
	LOOP UNTIL ##SOFTBREAK
	IF huh THEN XxxXstLog ("Y")
END SUB
'
'
' *****  UpdateVariables  *****
'
SUB UpdateVariables
	IF huh THEN XxxXstLog ("Z.")
	IF inQueue THEN PRINT "XgrProcessMessages() : inQueue"
	inQueue = $$TRUE
	IF queue THEN
		ceo = userCEO
		count = userCount
		out = userOut
		in = userIn
	ELSE
		ceo = sysCEO
		count = sysCount
		out = sysOut
		in = sysIn
	END IF
	inQueue = $$FALSE
	IF huh THEN
		XxxXstLog (STRING$(count) + ".")
		IF queue THEN XxxXstLog ("z") ELSE XxxXstLog ("Z")
	END IF
END SUB
END FUNCTION
'
'
' ###################################
' #####  XgrRegisterMessage ()  #####
' ###################################
'
FUNCTION  XgrRegisterMessage (message$, message)
	SHARED  lastMessage
	SHARED  messageType[]
	SHARED  message$[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ message$ THEN RETURN ($$FALSE)
	IFZ message$[] THEN GOSUB Initialize
'
	slot = 0
	upper = UBOUND (message$[])
'
	IF (message$ = "LastMessage") THEN
		message = lastMessage
		RETURN ($$FALSE)
	END IF
'
	FOR i = 1 TO upper
		IF message$[i] THEN
			IF (message$ = message$[i]) THEN
				message = i
				RETURN ($$FALSE)
			END IF
		ELSE
			IFZ slot THEN slot = i
		END IF
	NEXT i
'
' message not yet registered
'
	IFZ slot THEN
		slot = i
		upper = upper + 64
		##WHOMASK = 0
		REDIM message$[upper]
		REDIM messageType[upper]
		##WHOMASK = whomask
	END IF
'
	message = slot
	IF (message > lastMessage) THEN lastMessage = message
'
' register the message
'
	##WHOMASK = 0
	message$[message] = message$
	##WHOMASK = whomask
'
' register the message type
'
	messageType = $$Grid
	x = INSTR (message$, "Window")
	IF (x = 1) THEN messageType = $$Window
	messageType[message] = messageType
	RETURN ($$FALSE)
'
'
' *****  Initialize  *****
'
SUB Initialize
	##WHOMASK = 0
	lastMessage = 0
	upperMessage = 255
	DIM message$[upperMessage]
	DIM messageType[upperMessage]
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ###############################
' #####  XgrSendMessage ()  #####
' ###############################
'
FUNCTION  XgrSendMessage (wingrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  WINDOW  window[]
	SHARED  debug
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	IF InvalidWindow (wingrid) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSendMessage() : invalid wingrid #"; wingrid
		RETURN ($$TRUE)
	END IF
'
	window = wingrid
	top = window[window].top
	func = window[window].gridFunc
	IF (top = window) THEN func = window[window].winFunc
	IF func THEN @func (wingrid, message, @v0, @v1, @v2, @v3, @r0, @r1)
END FUNCTION
'
'
' #####################################
' #####  XgrSendStringMessage ()  #####
' #####################################
'
FUNCTION  XgrSendStringMessage (wingrid, message$, v0, v1, v2, v3, r0, r1)
	SHARED  WINDOW  window[]
	SHARED  debug
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	IF InvalidWindow (wingrid) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSendMessage() : invalid wingrid #"; wingrid
		RETURN ($$TRUE)
	END IF
'
	XgrMessageNameToNumber (@message$, @message)
	IFZ message THEN RETURN ($$TRUE)
'
	window = wingrid
	top = window[window].top
	func = window[window].gridFunc
	IF (top = window) THEN func = window[window].winFunc
	IF func THEN @func (wingrid, message, @v0, @v1, @v2, @v3, @r0, @r1)
END FUNCTION
'
'
' ##########################
' #####  XgrSetCEO ()  #####
' ##########################
'
FUNCTION  XgrSetCEO (func)
	SHARED	userCEO
	SHARED	sysCEO
'
	IF ##WHOMASK THEN
		userCEO = func
	ELSE
		sysCEO = func
	END IF
END FUNCTION
'
'
' #############################
' #####  XgrGetColors ()  #####
' #############################
'
FUNCTION  XgrGetColors (window, back, draw, low, high, dull, acc, lowtext, hightext)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrGetColors() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	back = window[window].backgroundColor
	draw = window[window].drawingColor
	low = window[window].lowlightColor
	high = window[window].highlightColor
	dull = window[window].dullColor
	acc = window[window].accentColor
	lowtext = window[window].lowtextColor
	hightext = window[window].hightextColor
END FUNCTION
'
'
' ###############################
' #####  XgrGetGridClip ()  #####
' ###############################
'
FUNCTION  XgrGetGridClip (grid, @clip)
'	PRINT "XgrGetGridClip() : unimplemented"
END FUNCTION
'
'
' #####################################
' #####  XgrRegisterIconColor ()  #####
' #####################################
'
' this does not work, apparently because icons have to be bitmaps
' (1 bit depth pixmaps), though I can't find this stated anywhere.
'
FUNCTION  XgrRegisterIconColor (filename$, @icon)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  icon$[]
	SHARED  icon[]
	SHARED  debug
	UBYTE  ico[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	icon = 0
	IFZ filename$ THEN RETURN ($$FALSE)			' default icon
'
	icon$ = filename$
	u = UBOUND (icon$)
	FOR i = 0 TO u
		c = icon${i}
		IF (c = '\\') THEN icon${i} = '/'			' change "\" to "/"
	NEXT i
'
	IFZ icon$[] THEN
		##WHOMASK = 0
		DIM icon[15]
		DIM icon$[15]
		DIM sicon[15]
		##WHOMASK = whomask
	END IF
'
	slot = -1
	upper = UBOUND (icon$[])
	FOR icon = 1 TO upper
		IF icon$[icon] THEN
			IF (icon$ = icon$[icon]) THEN RETURN ($$FALSE)	' registered
		ELSE
			IF (slot < 0) THEN slot = icon
		END IF
	NEXT icon
'
' icon not yet registered - try to load from disk
'
	IF (slot < 0) THEN
		##WHOMASK = 0
		slot = icon
		upper = upper + 16
		REDIM icon[upper]
		REDIM icon$[upper]
		REDIM sicon[upper]
		##WHOMASK = whomask
	END IF
'
	FOR w = 1 TO UBOUND (window[])
		IF window[w].window THEN
			window = window[w].window
			swindow = window[w].swindow
			sdisplay = window[w].sdisplay
			display = window[w].display
			EXIT FOR
		END IF
	NEXT w
'
	IF ((swindow = 0) OR (sdisplay = 0)) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "XgrRegisterIcon() : some display and window must exist"
		RETURN ($$TRUE)
	END IF
'
	path$ = LCASE$(icon$)
'
	icon = 0
	dot = RINSTR (path$, ".")												' .extent ?
	IF dot THEN path$ = LEFT$ (path$, dot-1)				' remove .extent
	back = RINSTR (path$, "/")											' imbedded path ?
	IFZ back THEN path$ = "$XBDIR/images/" + path$			' default path
	ico$ = path$ + ".ico"
'
	error = XgrLoadImage (@ico$, @ico[])
'
	IF error THEN
		##ERROR = ($$ErrorObjectIcon << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrRegisterIcon() : icon file not found"
		RETURN ($$TRUE)
	END IF
'
	XgrGetImageArrayInfo (@ico[], @depth, @width, @height)
	XgrCreateGrid (@image, #GridTypeImage, 0, 0, width, height, window, 0, 0)
	sicon = window[image].swindow
	XgrSetImage (image, @ico[])
'
	ico$ = RCLIP$ (ico$, 4)										' remove ".ico"
	back = RINSTR (ico$, $$PathSlash$)				' find last path slash
	IF back THEN ico$ = MID$ (ico$, back+1)		' ico$ = pure icon name
'
	icon = slot
	sicon[icon] = sicon				' swindow of icon image grid
	icon$[icon] = ico$				' icon name
	icon[icon] = image				' native grid # of image grid
	#iconMax = icon						' new icon # upper bound
END FUNCTION
'
'
' #############################
' #####  XgrSetColors ()  #####
' #############################
'
FUNCTION  XgrSetColors (grid, back, draw, low, high, dull, acc, lowtext, hightext)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XgrSetDrawingRGB() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	window = grid
	xdraw = window[window].drawingColor
	xback = window[window].backgroundColor
'
	IF (back != -1) THEN XgrSetBackgroundColor (grid, back)
	IF (draw != -1) THEN XgrSetDrawingColor (grid, draw)
	IF (low != -1) THEN window[window].lowlightColor = low
	IF (high != -1) THEN window[window].highlightColor = high
	IF (dull != -1) THEN window[window].dullColor = dull
	IF (acc != -1) THEN window[window].accentColor = acc
	IF (lowtext != -1) THEN window[window].lowtextColor = lowtext
	IF (hightext != -1) THEN window[window].hightextColor = hightext
END FUNCTION
'
'
' ###############################
' #####  XgrSetGridClip ()  #####
' ###############################
'
FUNCTION  XgrSetGridClip (grid, clip)
'	PRINT "XgrSetGridClip() : unimplemented"
END FUNCTION
'
'
' #################################
' #####  XxxCheckMessages ()  #####
' #################################
'
FUNCTION  XxxCheckMessages ()
	SHARED	sysCount
	SHARED  userCount
	SHARED  eventTime
	STATIC  checkTime
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ sysCount THEN DispatchEvents ($$TRUE, $$FALSE)
'
' process all system messages
'
'	IF whomask THEN
		DO WHILE sysCount
			##WHOMASK = $$FALSE
			XgrProcessMessages (0)							' process system message
			##WHOMASK = whomask
		LOOP UNTIL ##SOFTBREAK
'	END IF
END FUNCTION
'
'
' ##################################
' #####  XxxDispatchEvents ()  #####
' ##################################
'
FUNCTION  XxxDispatchEvents (arg1, arg2)
'
	DispatchEvents (arg1, arg2)
END FUNCTION
'
'
' ###############################
' #####  XxxXgrBlowback ()  #####
' ###############################
'
' Want to free all user graphics contexts and windows without
' processing associated messages that might call functions in
' the user program being killed that might be screwed up.
' ##WHOMASK = 0 prevents XgrProcessMessages() from processing
' user messages, even if user messages are in fact generated.
' After all user resources are destroyed, DispatchEvents()
' processes the xlib events and adds user messages to the
' user queue.  This function simply clears the queue.
'
FUNCTION  XxxXgrBlowback ()
	SHARED  WINDOW  window[]
	SHARED  charMap[]
	SHARED  userCount
	SHARED  userOut
	SHARED  userIn
	SHARED  userCEO
	SHARED  inQueue
	SHARED  blowback
'
	blowback = $$TRUE
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
' start with an empty user message queue
'
	inQueue = $$TRUE
	userCount = 0
	userOut = 0
	userIn = 0
	userCEO = 0
	inQueue = $$FALSE
'
	##WHOMASK = 0
'
'	write (1, &"XxxXgrBlowback().A\n", 19)
'
	FOR i = 1 TO UBOUND (window[])
		IF window[i].window THEN
			IF window[i].swindow THEN
				IF window[i].whomask THEN
					IF (i = window[i].top) THEN
'						INC count
'						i$ = STRING$(i) + " "
'						IFZ (count AND 0x000F) THEN i$ = i$ + "\n"
'						write (1, &i$, LEN(i$))
						gc = window[i].gc
						swindow = window[i].swindow
						sdisplay = window[i].sdisplay
						##WHOMASK = 0
						##LOCKOUT = $$TRUE
						XFreeGC (sdisplay, gc)
						XDestroyWindow (sdisplay, swindow)
						DispatchEvents ($$TRUE, $$FALSE)
						##WHOMASK = whomask
						##LOCKOUT = lockout
					END IF
					window[i].window = 0								' mark user grids available
					window[i].swindow = 0								' ditto
					ATTACH charMap[i,] TO temp[]				' ditch char map
				END IF
			END IF
		END IF
	NEXT i
'	PRINT
'
' clear xlib event queue completely
'
	DispatchEvents ($$TRUE, $$FALSE)
'
' clear user message queue completely
'
	inQueue = $$TRUE
	userCount = 0
	userOut = 0
	userIn = 0
	userCEO = 0
	inQueue = $$FALSE
'
	##WHOMASK = whomask
	##LOCKOUT = lockout
	blowback = $$FALSE
'
'	write (1, &"XxxXgrBlowback().Z\n", 19)
END FUNCTION
'
'
' ################################
' #####  XxxXgrGridTimer ()  #####
' ################################
'
' XxxXgrGridTimer() is called by the standard library when
' any grid timer started by XgrSetGridTimer() expires.
' XxxXgrGridTimer() add the appropriate #TimeOut message
' to the appropriate message queue.
'
FUNCTION  XxxXgrGridTimer (timer, count, msec, time)
	SHARED  WINDOW  window[]
	SHARED  userCount
	SHARED  sysCount
	SHARED  debug
	AUTOX  FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
'	PRINT "XxxXgrGridTimer().A : "; grid;; #TimeOut;; timer;; count;; msec;; time
	upper = UBOUND (window[])
'	write (1, &"%(", 2)
	FOR grid = 0 TO upper
		IF (timer = window[grid].timer) THEN
			window[grid].timer = 0
			XgrAddMessage (grid, #TimeOut, timer, count, msec, time, 0, grid)
'			a$ = STRING$(grid) + "." + STRING$(timer) + "." + STRING$(msec) + "." + STRING$(time)
'			write (1, &a$, LEN(a$))
			EXIT FOR
		END IF
	NEXT grid
'	write (1, &")%", 2)
'	PRINT "XxxXgrGridTimer().Z : "; grid;; #TimeOut;; timer;; count;; msec;; time
END FUNCTION
'
'
' ###########################
' #####  XxxXgrQuit ()  #####
' ###########################
'
FUNCTION  XxxXgrQuit ()
	SHARED  WINDOW  window[]
	SHARED  userCount
	SHARED  sysCount
	SHARED  userOut
	SHARED  sysOut
	SHARED  userIn
	SHARED  sysIn
	SHARED  sysCEO
	SHARED  userCEO
	SHARED  inQueue
	SHARED  blowback
'
	blowback = $$TRUE
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	alarmbusy = ##ALARMBUSY
	##ALARMBUSY	= $$TRUE
'
' start with empty message queues
'
	inQueue = $$TRUE
	userCount = 0
	sysCount = 0
	userOut = 0
	sysOut = 0
	userIn = 0
	sysIn = 0
	sysCEO = 0
	userCEO = 0
	inQueue = $$FALSE
'
	##WHOMASK = 0
'
'	write (1, &"XxxXgrQuit().A\n", 15)
	FOR i = 1 TO UBOUND (window[])
		IF window[i].window THEN
			IF window[i].swindow THEN
				IF (i = window[i].top) THEN
'					INC count
'					i$ = STRING$(i) + " "
'					IFZ (count AND 0x001F) THEN i$ = i$ + "\n"
'					write (1, &i$, LEN(i$))
					gc = window[i].gc
					swindow = window[i].swindow
					sdisplay = window[i].sdisplay
					##WHOMASK = 0
					##LOCKOUT = $$TRUE
					XFreeGC (sdisplay, gc)
					XDestroyWindow (sdisplay, swindow)
					DispatchEvents ($$TRUE, $$FALSE)
					##WHOMASK = whomask
					##LOCKOUT = lockout
				END IF
				window[i].window = 0
				window[i].swindow = 0
			END IF
		END IF
	NEXT i
'	PRINT
'
' clear xlib event queue completely
'
	DispatchEvents ($$TRUE, $$FALSE)
'
' clear message queues completely
'
	inQueue = $$TRUE
	userCount = 0
	sysCount = 0
	userOut = 0
	sysOut = 0
	userIn = 0
	sysIn = 0
	sysCEO = 0
	userCEO = 0
	inQueue = $$FALSE
'
	##ALARMBUSY	= alarmbusy
	##WHOMASK = whomask
	##LOCKOUT = lockout
	blowback = $$FALSE
'	write (1, &"XxxXgrQuit().Z\n", 15)
END FUNCTION
'
'
' ####################################
' #####  XxxXgrSetHelpWindow ()  #####
' ####################################
'
FUNCTION  XxxXgrSetHelpWindow (window)
	SHARED	helpWindow
	SHARED  debug
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "XxxXgrSetHelpWindow() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	helpWindow = window
END FUNCTION
'
'
' #############################
' #####  XxxXgrSetHuh ()  #####
' #############################
'
FUNCTION  XxxXgrSetHuh (duh)
	SHARED	huh
'
	huh = duh
END FUNCTION
'
'
' #####################################################
' #####  XxxXgrWindowToSystemDisplayAndWindow ()  #####
' #####################################################
'
FUNCTION  XxxXgrWindowToSystemDisplayAndWindow (window, @sdisplay, @swindow)
	SHARED  WINDOW  window[]
'
	IF (window < 0) THEN RETURN ($$TRUE)
	IF (window > UBOUND (window[])) THEN RETURN ($$TRUE)
'
	sdisplay = window[window].sdisplay
	swindow = window[window].swindow
END FUNCTION
'
'
' ##########################################
' #####  ConvertColorToSystemColor ()  #####
' ##########################################
'
FUNCTION  ConvertColorToSystemColor (window, color, @scolor)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  rgb[]
	SHARED  debug
	AUTOX  XColor  sc
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "ConvertColorToSystemColor() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	display = window[window].display
	sdisplay = window[window].sdisplay
	colormap = display[display].colormap
'
' color = 0 means standard color # 0 = $$Black
'
	IFZ color THEN
'		window[window].backRed = 0
'		window[window].backGreen = 0
'		window[window].backBlue = 0
'		window[window].backColor = 0
'		window[window].backgroundColor = 0
		scolor = display[display].color[0]
		RETURN ($$FALSE)
	END IF
'
' standard color # != 0 means color is standard color #
'
	c = color AND 0x000000FF
	IF (c > 124) THEN c = 124
'
	IF c THEN
		rgb = rgb[c]
'		window[window].backColor = c
'		window[window].backRed = (rgb AND 0xFF000000) >> 16
'		window[window].backGreen = (rgb AND 0x00FF0000) >> 8
'		window[window].backBlue = (rgb AND 0x0000FF00)
'		window[window].backgroundColor = c
		scolor = display[display].color[c]
		RETURN ($$FALSE)
	END IF
'
' color is in rgb field of rgbc color argument
'
	red = (color AND 0xFF000000) >> 16
	green = (color AND 0x00FF0000) >> 8
	blue = (color AND 0x0000FF00)
'
	r = red >> 8
	g = green >> 8
	b = blue >> 8
	c = 0
'
'	window[window].backRed = red
'	window[window].backGreen = green
'	window[window].backBlue = blue
'	window[window].backColor = 0
'	window[window].backgroundColor = (r << 24) + (g << 16) + (b << 8) + c
'
	sc.scolor = 0
	sc.r = red
	sc.g = green
	sc.b = blue
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = XAllocColor (sdisplay, colormap, &sc)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF okay THEN scolor = sc.scolor
END FUNCTION
'
'
' ########################################
' #####  ConvertRGBToSystemColor ()  #####
' ########################################
'
FUNCTION  ConvertRGBToSystemColor (window, red, green, blue, @scolor)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
	AUTOX  XColor  sc
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "ConvertRGBToSystemColor() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	display = window[window].display
	sdisplay = window[window].sdisplay
	colormap = display[display].colormap
'
' color = 0 means standard color # 0 = $$Black
'
	IFZ (red OR green OR blue) THEN
'		window[window].backRed = 0
'		window[window].backGreen = 0
'		window[window].backBlue = 0
'		window[window].backColor = 0
'		window[window].backgroundColor = 0
		scolor = display[display].color[0]
		RETURN ($$FALSE)
	END IF
'
' allocate rgb color
'
	red = red AND 0x0000FFFF
	green = green AND 0x0000FFFF
	blue = blue AND 0x0000FFFF
	r = red >> 8
	g = green >> 8
	b = blue >> 8
	c = 0
'
'	window[window].backRed = red
'	window[window].backGreen = green
'	window[window].backBlue = blue
'	window[window].backColor = 0
'	window[window].backgroundColor = (r << 24) + (g << 16) + (b << 8) + c
'
	sc.scolor = 0
	sc.r = red
	sc.g = green
	sc.b = blue
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = XAllocColor (sdisplay, colormap, &sc)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF okay THEN scolor = sc.scolor
END FUNCTION
'
'
' ############################
' #####  CreateQueue ()  #####
' ############################
'
' if message[] is empty, create message[1,]
' if specified queue (0 or 1) is empty, attach message queue to message[queue,]
'
FUNCTION  CreateQueue (queue)
	SHARED  MESSAGE  message[]
	SHARED  userCount
	SHARED  sysCount
	SHARED  userOut
	SHARED  sysOut
	SHARED  userIn
	SHARED  sysIn
	SHARED  inQueue
	SHARED  debug
	MESSAGE m[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF queue THEN queue = 1							' queue 0 = system : queue 1 = user
'
	##WHOMASK = 0
	IFZ message[] THEN DIM message[1,]	' create message queue array
	##WHOMASK = whomask
'
	IF message[queue,] THEN
		PRINT "CreateQueue() : error : specified queue already exists"
		RETURN ($$TRUE)
	END IF
'
' initialize the appropriate queue variables
'
	inQueue = $$TRUE
'
	IF queue THEN
		userCount = 0
		userOut = 0
		userIn = 0
	ELSE
		sysCount = 0
		sysOut = 0
		sysIn = 0
	END IF
'
' create a message array and attach to appropriate leg of message array
'
	##WHOMASK = 0
	DIM m[2047]
	ATTACH m[] TO message[queue,]
	##WHOMASK = whomask
	inQueue = $$FALSE
END FUNCTION
'
'
' ####################################
' #####  DestroySystemResources  #####
' ####################################
'
FUNCTION  DestroySystemResources ()
	SHARED	MESSAGE  message[]
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED	inQueue
	SHARED	sysCount
	SHARED	sysOut
	SHARED	sysIn
	SHARED	sysCEO
	STATIC  WINDOW  zipwin
'
	GOSUB ProcessEventsAndMessages
	FOR window = 1 TO UBOUND (window[])
		IF window[window].window THEN
			IF window[window].swindow THEN
				IFZ window[window].whomask THEN
					IFZ window[window].destroy THEN
						IFZ window[window].destroyed THEN
							IFZ window[window].destroyProcessed THEN
								IF (window[window].kind = $$KindWindow) THEN
									XgrDestroyWindow (window)
									GOSUB ProcessEventsAndMessages
									window[window] = zipwin
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT window
	GOSUB ProcessEventsAndMessages			' one last flush
'
' clear out system message queue
'
	inQueue = $$TRUE
	sysCount = 0
	sysOut = 0
	sysIn = 0
	sysCEO = 0
'
	IF message[0,] THEN
		FOR i = 0 TO UBOUND (message[1,])
			message[0,i].wingrid = 0
			message[0,i].message = 0
			message[0,i].v0 = 0
			message[0,i].v1 = 0
			message[0,i].v2 = 0
			message[0,i].v3 = 0
			message[0,i].r0 = 0
			message[0,i].r1 = 0
		NEXT i
	END IF
	inQueue = $$FALSE
	RETURN
'
'
' *****  ProcessEventsAndMessages  *****
'
SUB ProcessEventsAndMessages
	DispatchEvents ($$TRUE, $$FALSE)			' convert events into messages
	DO
		XgrProcessMessages (0)							' and process the messages
		XgrMessagesPending (@count)					' until they're gone
	LOOP WHILE count
END SUB
END FUNCTION
'
'
' #####################################
' #####  DestroyUserResources ()  #####
' #####################################
'
FUNCTION  DestroyUserResources ()
	SHARED	MESSAGE  message[]
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  blowback
	SHARED	inQueue
	SHARED	userCount
	SHARED	userOut
	SHARED	userIn
	SHARED	userCEO
	STATIC  WINDOW  zipwin
'
	GOSUB ProcessEventsAndMessages
	FOR window = 1 TO UBOUND (window[])
		IF window[window].window THEN
			IF window[window].swindow THEN
				IF window[window].whomask THEN
					IFZ window[window].destroy THEN
						IFZ window[window].destroyed THEN
							IFZ window[window].destroyProcessed THEN
								IF (window[window].kind = $$KindWindow) THEN
									XgrDestroyWindow (window)
									GOSUB ProcessEventsAndMessages
									window[window] = zipwin
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT window
	GOSUB ProcessEventsAndMessages			' one last flush
'
' clear out user message queue
'
	inQueue = $$TRUE
	userCount = 0
	userOut = 0
	userIn = 0
	userCEO = 0
'
	IF message[1,] THEN
		FOR i = 0 TO UBOUND (message[1,])
			message[1,i].wingrid = 0
			message[1,i].message = 0
			message[1,i].v0 = 0
			message[1,i].v1 = 0
			message[1,i].v2 = 0
			message[1,i].v3 = 0
			message[1,i].r0 = 0
			message[1,i].r1 = 0
		NEXT i
	END IF
	inQueue = $$FALSE
	RETURN
'
'
' *****  ProcessEventsAndMessages  *****
'
SUB ProcessEventsAndMessages
	DispatchEvents ($$TRUE, $$FALSE)			' convert events into messages
	DO
		XgrProcessMessages (0)							' and process the messages
		XgrMessagesPending (@count)					' until they're gone
	LOOP WHILE count
END SUB
END FUNCTION
'
'
' ##############################
' #####  XxxDIBToDIB24 ()  #####
' ##############################
'
' enter with valid 1,4,8,16,24,32 bit DIB in simage[]
' return 24-bit RGB DIB in dimage[]
'
' NOTE: this is FULL of misaligned access problems because microsoft
' buttheads defined STUPID wierd-size and misaligned DIB components.
'
FUNCTION  XxxDIBToDIB24 (UBYTE simage[], UBYTE dimage[])
	SHARED  debug
	RGBQUAD  palette[]
'
	$BI_RGB       = 0					' 24-bit RGB
	$BI_BITFIELDS = 3					' 32-bit RGB
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	DIM dimage[]
'
	IFZ simage[] THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XxxDIBToDIB32() : input argument simage[] is empty"
		RETURN ($$TRUE)
	END IF
'
	addr = &simage[]
	size = SIZE (simage[])
'
	IF (size < 64) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XxxDIBToDIB32() : error : input argument simage[] too small : "; size
		RETURN ($$TRUE)
	END IF
'
	byte0 = simage[0]
	byte1 = simage[1]
'
	byte2 = simage[2]
	byte3 = simage[3]
	byte4 = simage[4]
	byte5 = simage[5]
'
	byte10 = simage[10]
	byte11 = simage[11]
	byte12 = simage[12]
	byte13 = simage[13]
'
	byte14 = simage[14]
	byte15 = simage[15]
	byte16 = simage[16]
	byte17 = simage[17]
'
	byte18 = simage[18]
	byte19 = simage[19]
	byte20 = simage[20]
	byte21 = simage[21]
'
	byte22 = simage[22]
	byte23 = simage[23]
	byte24 = simage[24]
	byte25 = simage[25]
'
	byte26 = simage[26]
	byte27 = simage[27]
'
	byte28 = simage[28]
	byte29 = simage[29]
'
	byte30 = simage[30]
	byte31 = simage[31]
'
	byte46 = simage[46]
	byte47 = simage[47]
	byte48 = simage[48]
	byte49 = simage[49]
'
	byte50 = simage[50]
	byte51 = simage[51]
	byte52 = simage[52]
	byte53 = simage[53]
'
	bfType = (byte1 << 8) OR byte0
	bfSize = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2
	offBits = (byte13 << 24) OR (byte12 << 16) OR (byte11 << 8) OR byte10
	biSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14
	width = (byte21 << 24) OR (byte20 << 16) OR (byte19 << 8) OR byte18
	height = (byte25 << 24) OR (byte24 << 16) OR (byte23 << 8) OR byte22
	bitCount = (byte29 << 8) OR byte28
	clrUsed = (byte49 << 24) OR (byte48 << 16) OR (byte47 << 8) OR byte46
	clrImportant = (byte53 << 24) OR (byte52 << 16) OR (byte51 << 8) OR byte50
'
	biWidth = width
	biHeight = height
	biBitCount = bitCount
	biClrUsed = clrUsed
	biClrImportant = clrImportant
'
	bitmapAddr = iAddr + offBits
	paletteAddr = iAddr + 14 + biSize
'
	addrImage = addr + offBits						' boom : image address
	addrPalette = addr + biSize + 14			' boom : palette address in 1,4,8 bits/pixel
'
' initialize palette entry to color array if bits/pixel = 1,4,8
'
'	PRINT "print palette contents : entry, blue, green, red"
'
	skip = $$FALSE
	SELECT CASE biBitCount
		CASE 1		: top = 1
		CASE 4		: top = 15
		CASE 8		: top = 255
		CASE ELSE	: skip = $$TRUE
	END SELECT
'
	IFZ skip THEN
		paddr = addrPalette
		DIM palette[top]
		FOR p = 0 TO top
			palette[p].blue = UBYTEAT (paddr)		: INC paddr
			palette[p].green = UBYTEAT (paddr)	: INC paddr
			palette[p].red = UBYTEAT (paddr)		: INC paddr
			palette[p].zero = 0									: INC paddr
'			PRINT HEX$(p); " : "; HEX$(palette[p].blue,2);; HEX$(palette[p].green,2);; HEX$(palette[p].red,2)
		NEXT p
	END IF
'
'	a$ = INLINE$ ("press enter to continue...")
'
' make sure width and height are positive (can be negative in BMP format)
'
	dataOffset = 128
	width = ABS (biWidth)
	height = ABS (biHeight)
'
' compute size and upper bound of destination DIB image array
'
	widthbytes = ((width * 3) + 3) AND -4
	dsize = dataOffset + (height * widthbytes)
	dupper = dsize - 1
'
' create destination image array
'
	DIM dimage[dupper]										' destination image[] in DIB32
'
'
' initialize destination image[] array
'
	dataOffset = 128
	daddr = &dimage[]											' start addr of destination image[] array
	daddrPalette = daddr + 54							' start addr of destination color masks
	daddrImage = daddr + dataOffset				' start addr of destination image data
'
' create 32-bit DIB header
'
	dimage[0] = 'B'															' DIB aka BMP signature
	dimage[1] = 'M'
	dimage[2] = dsize AND 0x00FF								' file size
	dimage[3] = (dsize >> 8) AND 0x00FF
	dimage[4] = (dsize >> 16) AND 0x00FF
	dimage[5] = (dsize >> 24) AND 0x00FF
	dimage[6] = 0
	dimage[7] = 0
	dimage[8] = 0
	dimage[9] = 0
	dimage[10] = dataOffset AND 0x00FF					' file offset of bitmap data
	dimage[11] = (dataOffset >> 8) AND 0x00FF
	dimage[12] = (dataOffset >> 16) AND 0x00FF
	dimage[13] = (dataOffset >> 24) AND 0x00FF
'
'	fill BITMAPINFOHEADER (first 6 members)
'
	info = 14
	dimage[info+0] = 40													' XLONG : BITMAPINFOHEADER size
	dimage[info+1] = 0
	dimage[info+2] = 0
	dimage[info+3] = 0
	dimage[info+4] = width AND 0x00FF						' XLONG : width in pixels
	dimage[info+5] = (width >> 8) AND 0x00FF
	dimage[info+6] = (width >> 16) AND 0x00FF
	dimage[info+7] = (width >> 24) AND 0x00FF
	dimage[info+8] = height AND 0x00FF						' XLONG : height in pixels
	dimage[info+9] = (height >> 8) AND 0x00FF
	dimage[info+10] = (height >> 16) AND 0x00FF
	dimage[info+11] = (height >> 24) AND 0x00FF
	dimage[info+12] = 1													' USHORT : # of planes
	dimage[info+13] = 0													'
	dimage[info+14] = 32												' USHORT : bits per pixel
	dimage[info+15] = 0													'
	dimage[info+16] = $BI_BITFIELDS							' XLONG : 32-bit bitfield RGB
	dimage[info+17] = 0													'
	dimage[info+18] = 0													'
	dimage[info+19] = 0													'
	dimage[info+20] = 0													' XLONG : size image
	dimage[info+21] = 0													'
	dimage[info+22] = 0													'
	dimage[info+23] = 0													'
	dimage[info+24] = 0													' XLONG : xPPM
	dimage[info+25] = 0													'
	dimage[info+26] = 0													'
	dimage[info+27] = 0													'
	dimage[info+28] = 0													' XLONG : yPPM
	dimage[info+29] = 0													'
	dimage[info+30] = 0													'
	dimage[info+31] = 0													'
	dimage[info+32] = 0													' XLONG : clrUsed
	dimage[info+33] = 0													'
	dimage[info+34] = 0													'
	dimage[info+35] = 0													'
	dimage[info+36] = 0													' XLONG : clrImportant
	dimage[info+37] = 0													'
	dimage[info+38] = 0													'
	dimage[info+39] = 0													'
'
' note : the following are for 32-bit $$BI_BITFIELDS only,
' not for standard/default Windows 24-bit RGB format
'
	cbit = info+40															' color bitmasks offset
	rbits = 0xFFC00000													' 10-bits - red
	gbits = 0x003FF800													' 11-bits - green
	bbits = 0x000007FF													' 11-bits - blue
'
	dimage[cbit+0] = rbits AND 0x00FF
	dimage[cbit+1] = (rbits >> 8) AND 0x00FF
	dimage[cbit+2] = (rbits >> 16) AND 0x00FF
	dimage[cbit+3] = (rbits >> 24) AND 0x00FF
	dimage[cbit+4] = gbits AND 0x00FF
	dimage[cbit+5] = (gbits >> 8) AND 0x00FF
	dimage[cbit+6] = (gbits >> 16) AND 0x00FF
	dimage[cbit+7] = (gbits >> 24) AND 0x00FF
	dimage[cbit+8] = bbits AND 0x00FF
	dimage[cbit+9] = (bbits >> 8) AND 0x00FF
	dimage[cbit+10] = (bbits >> 16) AND 0x00FF
	dimage[cbit+11] = (bbits >> 24) AND 0x00FF
'
'
'
	off = 0									' offset on sub-byte size pixels
	daddr = daddrImage			' address of destination image
	saddr = addrImage				' address of source image
	width = ABS (width)			' width without flip
	height = ABS (height)		' height without flip
'
	mask = $$FALSE
	SELECT CASE biBitCount
		CASE 16	: mask = $$TRUE
		CASE 32	: mask = $$TRUE
	END SELECT
'
	IF mask THEN
		pa = addrPalette
		p0 = UBYTEAT (pa)		: INC pa
		p1 = UBYTEAT (pa)		: INC pa
		p2 = UBYTEAT (pa)		: INC pa
		p3 = UBYTEAT (pa)		: INC pa
		p4 = UBYTEAT (pa)		: INC pa
		p5 = UBYTEAT (pa)		: INC pa
		p6 = UBYTEAT (pa)		: INC pa
		p7 = UBYTEAT (pa)		: INC pa
		p8 = UBYTEAT (pa)		: INC pa
		p9 = UBYTEAT (pa)		: INC pa
		p10 = UBYTEAT (pa)	: INC pa
		p11 = UBYTEAT (pa)	: INC pa
'
		redMask = (p3 << 24) OR (p2 << 16) OR (p1 << 8) OR p0
		greenMask = (p7 << 24) OR (p6 << 16) OR (p5 << 8) OR p4
		blueMask = (p11 << 24) OR (p10 << 16) OR (p9 << 8) OR p8
'
		redMaskLow = -1			' bit # of least significant mask bit = 1
		redMaskHigh = -1		' bit # of most significant mask bit = 1
		greenMaskLow = -1		' bit # of least significant mask bit = 1
		greenMaskHigh = -1	' bit # of most significant mask bit = 1
		blueMaskLow = -1		' bit # of least significant mask bit = 1
		blueMaskHigh = -1		' bit # of most significant mask bit = 1
'
' find width and position of mask field for each source field (rgb)
'
		FOR n = 0 TO 31
			IF (redMaskLow < 0) THEN
				IF ((redMask >> n) AND 0x0001) THEN redMaskLow = n
			END IF
			IF (redMaskLow >= 0) THEN
				IF ((redMask >> n) AND 0x0001) THEN redMaskHigh = n
			END IF
'
			IF (greenMaskLow < 0) THEN
				IF ((greenMask >> n) AND 0x0001) THEN greenMaskLow = n
			END IF
			IF (greenMaskLow >= 0) THEN
				IF ((greenMask >> n) AND 0x0001) THEN greenMaskHigh = n
			END IF
'
			IF (blueMaskLow < 0) THEN
				IF ((blueMask >> n) AND 0x0001) THEN blueMaskLow = n
			END IF
			IF (blueMaskLow >= 0) THEN
				IF ((blueMask >> n) AND 0x0001) THEN blueMaskHigh = n
			END IF
		NEXT n
'
		redBits = redMaskHigh - redMaskLow + 1
		greenBits = greenMaskHigh - greenMaskLow + 1
		blueBits = blueMaskHigh - blueMaskLow + 1
	END IF
'
	SELECT CASE biBitCount
		CASE 1	:	scanx = ((((width * 1) + 31) AND -32) >> 3)
		CASE 4	: scanx = ((((width * 4) + 31) AND -32) >> 3)
		CASE 8	: scanx = ((((width * 8) + 31) AND -32) >> 3)
		CASE 16	: scanx = ((((width * 16) + 31) AND -32) >> 3)
		CASE 24	: scanx = ((((width * 24) + 31) AND -32) >> 3)
		CASE 32	: scanx = ((((width * 32) + 31) AND -32) >> 3)
	END SELECT
'
	dy = scanx
	IF (biHeight > 0) THEN				' image is upside down - flip y
		dy = -scanx
		saddr = saddr + (scanx * (height-1))		' move to last scan line
	END IF
'
	FOR y = 0 TO height-1
		xaddr = saddr								' xaddr = saddr at start of scan line
		FOR x = 0 TO width-1
			SELECT CASE biBitCount
				CASE 1	: GOSUB Move1		: offset = offset + 1
				CASE 4	: GOSUB Move4		: offset = offset + 4
				CASE 8	: GOSUB Move8		: offset = offset + 8
				CASE 16	:	GOSUB Move16	: offset = offset + 16
				CASE 24	: GOSUB Move24	: offset = offset + 24
				CASE 32	: GOSUB Move32	: offset = offset + 32
			END SELECT
		NEXT x
		off = 0													' bit offset = 0
		saddr = xaddr + dy							' move to next/previous scan line
		daddr = (daddr + 3) AND -4			' next scan line at MOD 4 address
	NEXT y
'
'	a$ = INLINE$ ("press enter to continue...")
'
	DIM palette[]
	RETURN
'
'
' *****  Move1  *****
'
SUB Move1
	shift = 7 - off												' upper bits of byte first
	pixel = UBYTEAT (saddr)
	IF shift THEN pixel = pixel >> shift
	pixel = pixel AND 0x01
	off = off + 1
	IF (off = 8) THEN off = 0 : INC saddr
'
	red = palette[pixel].red
	green = palette[pixel].green
	blue = palette[pixel].blue
'
	UBYTEAT (daddr) = blue		: INC daddr
	UBYTEAT (daddr) = green		: INC daddr
	UBYTEAT (daddr) = red			: INC daddr
END SUB
'
'
' *****  Move4  *****
'
SUB Move4
	shift = 4 - off													' upper nybble of byte first
	pixel = UBYTEAT (saddr)
	IF shift THEN pixel = pixel >> shift
	pixel = pixel AND 0x0F
	off = off + 4
	IF (off = 8) THEN off = 0 : INC saddr
'
	blue = palette[pixel].blue
	green = palette[pixel].green
	red = palette[pixel].red
'
	UBYTEAT (daddr) = blue	: INC daddr
	UBYTEAT (daddr) = green	: INC daddr
	UBYTEAT (daddr) = red		: INC daddr
END SUB
'
'
' *****  Move8  *****
'
SUB Move8
	pixel = UBYTEAT (saddr)
	INC saddr
'
	red = palette[pixel].red
	green = palette[pixel].green
	blue = palette[pixel].blue
'
	UBYTEAT (daddr) = blue	: INC daddr
	UBYTEAT (daddr) = green	: INC daddr
	UBYTEAT (daddr) = red		: INC daddr
END SUB
'
'
' *****  Move16  *****
'
SUB Move16
	byte0 = UBYTEAT (saddr)	: INC saddr
	byte1 = UBYTEAT (saddr) : INC saddr
	pixel = (byte1 << 8) OR byte0
'
	red = (pixel AND redMask) >> redMaskLow
	green = (pixel AND greenMask) >> greenMaskLow
	blue = (pixel AND blueMask) >> blueMaskLow
'
	UBYTEAT (daddr) = blue	: INC daddr
	UBYTEAT (daddr) = green	: INC daddr
	UBYTEAT (daddr) = red		: INC daddr
END SUB
'
'
' *****  Move24  *****
'
SUB Move24
	blue = UBYTEAT (saddr)	: INC saddr
	green = UBYTEAT (saddr)	: INC saddr
	red = UBYTEAT (saddr)		: INC saddr
'
	UBYTEAT (daddr) = blue	: INC daddr
	UBYTEAT (daddr) = green	: INC daddr
	UBYTEAT (daddr) = red		: INC daddr
END SUB
'
'
' *****  Move32  *****
'
SUB Move32
	byte0 = UBYTEAT (saddr)	: INC saddr
	byte1 = UBYTEAT (saddr) : INC saddr
	byte2 = UBYTEAT (saddr)	: INC saddr
	byte3 = UBYTEAT (saddr) : INC saddr
	pixel = (byte3 << 24) OR (byte2 << 16) OR (byte1 << 8) OR byte0
'
	red = (pixel AND redMask) >> redMaskLow
	green = (pixel AND greenMask) >> greenMaskLow
	blue = (pixel AND blueMask) >> blueMaskLow
'
	UBYTEAT (daddr) = blue	: INC daddr
	UBYTEAT (daddr) = green	: INC daddr
	UBYTEAT (daddr) = red		: INC daddr
END SUB
END FUNCTION
'
'
' ##############################
' #####  XxxDIBToDIB32 ()  #####
' ##############################
'
' enter with valid 1,4,8,16,24,32 bit DIB in simage[]
' return 32-bit 10-11-11 RGB DIB in dimage[] (standard image[] array)
'
' NOTE: this is FULL of misaligned access problems because microsoft
' buttheads defined STUPID wierd-size and misaligned DIB components.
'
FUNCTION  XxxDIBToDIB32 (UBYTE simage[], UBYTE dimage[])
	SHARED  debug
	RGBQUAD  palette[]
'
	$BI_RGB       = 0					' 24-bit RGB
	$BI_BITFIELDS = 3					' 32-bit RGB
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	DIM dimage[]
'
	IFZ simage[] THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XxxDIBToDIB32() : input argument simage[] is empty"
		RETURN ($$TRUE)
	END IF
'
	addr = &simage[]
	size = SIZE (simage[])
'
	IF (size < 64) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "XxxDIBToDIB32() : error : input argument simage[] too small : "; size
		RETURN ($$TRUE)
	END IF
'
	byte0 = simage[0]
	byte1 = simage[1]
'
	byte2 = simage[2]
	byte3 = simage[3]
	byte4 = simage[4]
	byte5 = simage[5]
'
	byte10 = simage[10]
	byte11 = simage[11]
	byte12 = simage[12]
	byte13 = simage[13]
'
	byte14 = simage[14]
	byte15 = simage[15]
	byte16 = simage[16]
	byte17 = simage[17]
'
	byte18 = simage[18]
	byte19 = simage[19]
	byte20 = simage[20]
	byte21 = simage[21]
'
	byte22 = simage[22]
	byte23 = simage[23]
	byte24 = simage[24]
	byte25 = simage[25]
'
	byte26 = simage[26]
	byte27 = simage[27]
'
	byte28 = simage[28]
	byte29 = simage[29]
'
	byte30 = simage[30]
	byte31 = simage[31]
'
	byte46 = simage[46]
	byte47 = simage[47]
	byte48 = simage[48]
	byte49 = simage[49]
'
	byte50 = simage[50]
	byte51 = simage[51]
	byte52 = simage[52]
	byte53 = simage[53]
'
	bfType = (byte1 << 8) OR byte0
	bfSize = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2
	offBits = (byte13 << 24) OR (byte12 << 16) OR (byte11 << 8) OR byte10
	biSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14
	width = (byte21 << 24) OR (byte20 << 16) OR (byte19 << 8) OR byte18
	height = (byte25 << 24) OR (byte24 << 16) OR (byte23 << 8) OR byte22
	bitCount = (byte29 << 8) OR byte28
	clrUsed = (byte49 << 24) OR (byte48 << 16) OR (byte47 << 8) OR byte46
	clrImportant = (byte53 << 24) OR (byte52 << 16) OR (byte51 << 8) OR byte50
'
	biWidth = width
	biHeight = height
	biBitCount = bitCount
	biClrUsed = clrUsed
	biClrImportant = clrImportant
'
	bitmapAddr = iAddr + offBits
	paletteAddr = iAddr + 14 + biSize
'
	addrImage = addr + offBits						' boom : image address
	addrPalette = addr + biSize + 14			' boom : palette address in 1,4,8 bits/pixel
'
' initialize palette entry to color array if bits/pixel = 1,4,8
'
'	PRINT "print palette contents : entry, blue, green, red"
'
	skip = $$FALSE
	SELECT CASE biBitCount
		CASE 1		: top = 1
		CASE 4		: top = 15
		CASE 8		: top = 255
		CASE ELSE	: skip = $$TRUE
	END SELECT
'
	IFZ skip THEN
		paddr = addrPalette
		DIM palette[top]
		FOR p = 0 TO top
			palette[p].blue = UBYTEAT (paddr)		: INC paddr
			palette[p].green = UBYTEAT (paddr)	: INC paddr
			palette[p].red = UBYTEAT (paddr)		: INC paddr
			palette[p].zero = 0									: INC paddr
'			PRINT HEX$(p); " : "; HEX$(palette[p].blue,2);; HEX$(palette[p].green,2);; HEX$(palette[p].red,2)
		NEXT p
	END IF
'
'	a$ = INLINE$ ("press enter to continue...")
'
' make sure width and height are positive (can be negative in BMP format)
'
	dataOffset = 128
	width = ABS (biWidth)
	height = ABS (biHeight)
'
' compute size and upper bound of destination DIB image array
'
	dsize = dataOffset + ((width * height) << 2)
	dupper = dsize - 1
'
' create destination image array
'
	DIM dimage[dupper]										' destination image[] in DIB32
'
'
' initialize destination image[] array
'
	dataOffset = 128
	daddr = &dimage[]											' start addr of destination image[] array
	daddrPalette = daddr + 54							' start addr of destination color masks
	daddrImage = daddr + dataOffset				' start addr of destination image data
'
' create 32-bit DIB header
'
	dimage[0] = 'B'															' DIB aka BMP signature
	dimage[1] = 'M'
	dimage[2] = dsize AND 0x00FF								' file size
	dimage[3] = (dsize >> 8) AND 0x00FF
	dimage[4] = (dsize >> 16) AND 0x00FF
	dimage[5] = (dsize >> 24) AND 0x00FF
	dimage[6] = 0
	dimage[7] = 0
	dimage[8] = 0
	dimage[9] = 0
	dimage[10] = dataOffset AND 0x00FF					' file offset of bitmap data
	dimage[11] = (dataOffset >> 8) AND 0x00FF
	dimage[12] = (dataOffset >> 16) AND 0x00FF
	dimage[13] = (dataOffset >> 24) AND 0x00FF
'
'	fill BITMAPINFOHEADER (first 6 members)
'
	info = 14
	dimage[info+0] = 40													' XLONG : BITMAPINFOHEADER size
	dimage[info+1] = 0
	dimage[info+2] = 0
	dimage[info+3] = 0
	dimage[info+4] = width AND 0x00FF						' XLONG : width in pixels
	dimage[info+5] = (width >> 8) AND 0x00FF
	dimage[info+6] = (width >> 16) AND 0x00FF
	dimage[info+7] = (width >> 24) AND 0x00FF
	dimage[info+8] = height AND 0x00FF					' XLONG : height in pixels
	dimage[info+9] = (height >> 8) AND 0x00FF
	dimage[info+10] = (height >> 16) AND 0x00FF
	dimage[info+11] = (height >> 24) AND 0x00FF
	dimage[info+12] = 1													' USHORT : # of planes
	dimage[info+13] = 0													'
	dimage[info+14] = 32												' USHORT : bits per pixel
	dimage[info+15] = 0													'
	dimage[info+16] = $BI_BITFIELDS							' XLONG : 32-bit bitfield RGB
	dimage[info+17] = 0													'
	dimage[info+18] = 0													'
	dimage[info+19] = 0													'
	dimage[info+20] = 0													' XLONG : size image
	dimage[info+21] = 0													'
	dimage[info+22] = 0													'
	dimage[info+23] = 0													'
	dimage[info+24] = 0													' XLONG : xPPM
	dimage[info+25] = 0													'
	dimage[info+26] = 0													'
	dimage[info+27] = 0													'
	dimage[info+28] = 0													' XLONG : yPPM
	dimage[info+29] = 0													'
	dimage[info+30] = 0													'
	dimage[info+31] = 0													'
	dimage[info+32] = 0													' XLONG : clrUsed
	dimage[info+33] = 0													'
	dimage[info+34] = 0													'
	dimage[info+35] = 0													'
	dimage[info+36] = 0													' XLONG : clrImportant
	dimage[info+37] = 0													'
	dimage[info+38] = 0													'
	dimage[info+39] = 0													'
'
' note : the following are for 32-bit $$BI_BITFIELDS only,
' not for standard/default Windows 24-bit RGB format
'
	cbit = info+40															' color bitmasks offset
	rbits = 0xFFC00000													' 10-bits - red
	gbits = 0x003FF800													' 11-bits - green
	bbits = 0x000007FF													' 11-bits - blue
'
	dimage[cbit+0] = rbits AND 0x00FF
	dimage[cbit+1] = (rbits >> 8) AND 0x00FF
	dimage[cbit+2] = (rbits >> 16) AND 0x00FF
	dimage[cbit+3] = (rbits >> 24) AND 0x00FF
	dimage[cbit+4] = gbits AND 0x00FF
	dimage[cbit+5] = (gbits >> 8) AND 0x00FF
	dimage[cbit+6] = (gbits >> 16) AND 0x00FF
	dimage[cbit+7] = (gbits >> 24) AND 0x00FF
	dimage[cbit+8] = bbits AND 0x00FF
	dimage[cbit+9] = (bbits >> 8) AND 0x00FF
	dimage[cbit+10] = (bbits >> 16) AND 0x00FF
	dimage[cbit+11] = (bbits >> 24) AND 0x00FF
'
'
'
	off = 0									' offset on sub-byte size pixels
	daddr = daddrImage			' address of destination image
	saddr = addrImage				' address of source image
	width = ABS (width)			' width without flip
	height = ABS (height)		' height without flip
'
	mask = $$FALSE
	SELECT CASE biBitCount
		CASE 16	: mask = $$TRUE
		CASE 32	: mask = $$TRUE
	END SELECT
'
	IF mask THEN
		pa = addrPalette
		p0 = UBYTEAT (pa)		: INC pa
		p1 = UBYTEAT (pa)		: INC pa
		p2 = UBYTEAT (pa)		: INC pa
		p3 = UBYTEAT (pa)		: INC pa
		p4 = UBYTEAT (pa)		: INC pa
		p5 = UBYTEAT (pa)		: INC pa
		p6 = UBYTEAT (pa)		: INC pa
		p7 = UBYTEAT (pa)		: INC pa
		p8 = UBYTEAT (pa)		: INC pa
		p9 = UBYTEAT (pa)		: INC pa
		p10 = UBYTEAT (pa)	: INC pa
		p11 = UBYTEAT (pa)	: INC pa
'
		redMask = (p3 << 24) OR (p2 << 16) OR (p1 << 8) OR p0
		greenMask = (p7 << 24) OR (p6 << 16) OR (p5 << 8) OR p4
		blueMask = (p11 << 24) OR (p10 << 16) OR (p9 << 8) OR p8
'
		redMaskLow = -1			' bit # of least significant mask bit = 1
		redMaskHigh = -1		' bit # of most significant mask bit = 1
		greenMaskLow = -1		' bit # of least significant mask bit = 1
		greenMaskHigh = -1	' bit # of most significant mask bit = 1
		blueMaskLow = -1		' bit # of least significant mask bit = 1
		blueMaskHigh = -1		' bit # of most significant mask bit = 1
'
' find width and position of mask field for each source field (rgb)
'
		FOR n = 0 TO 31
			IF (redMaskLow < 0) THEN
				IF ((redMask >> n) AND 0x0001) THEN redMaskLow = n
			END IF
			IF (redMaskLow >= 0) THEN
				IF ((redMask >> n) AND 0x0001) THEN redMaskHigh = n
			END IF
'
			IF (greenMaskLow < 0) THEN
				IF ((greenMask >> n) AND 0x0001) THEN greenMaskLow = n
			END IF
			IF (greenMaskLow >= 0) THEN
				IF ((greenMask >> n) AND 0x0001) THEN greenMaskHigh = n
			END IF
'
			IF (blueMaskLow < 0) THEN
				IF ((blueMask >> n) AND 0x0001) THEN blueMaskLow = n
			END IF
			IF (blueMaskLow >= 0) THEN
				IF ((blueMask >> n) AND 0x0001) THEN blueMaskHigh = n
			END IF
		NEXT n
'
		redBits = redMaskHigh - redMaskLow + 1
		greenBits = greenMaskHigh - greenMaskLow + 1
		blueBits = blueMaskHigh - blueMaskLow + 1
	END IF
'
	SELECT CASE biBitCount
		CASE 1	:	scanx = ((((width * 1) + 31) AND -32) >> 3)
		CASE 4	: scanx = ((((width * 4) + 31) AND -32) >> 3)
		CASE 8	: scanx = ((((width * 8) + 31) AND -32) >> 3)
		CASE 16	: scanx = ((((width * 16) + 31) AND -32) >> 3)
		CASE 24	: scanx = ((((width * 24) + 31) AND -32) >> 3)
		CASE 32	: scanx = ((((width * 32) + 31) AND -32) >> 3)
	END SELECT
'
	dy = scanx
	IF (biHeight > 0) THEN				' image is upside down - flip y
		dy = -scanx
		saddr = saddr + (scanx * (height-1))		' move to last scan line
	END IF
'
	FOR y = 0 TO height-1
		xaddr = saddr								' xaddr = saddr at start of scan line
		FOR x = 0 TO width-1
			SELECT CASE biBitCount
				CASE 1	: GOSUB Move1		: offset = offset + 1
				CASE 4	: GOSUB Move4		: offset = offset + 4
				CASE 8	: GOSUB Move8		: offset = offset + 8
				CASE 16	:	GOSUB Move16	: offset = offset + 16
				CASE 24	: GOSUB Move24	: offset = offset + 24
				CASE 32	: GOSUB Move32	: offset = offset + 32
			END SELECT
		NEXT x
		off = 0													' bit offset = 0
		saddr = xaddr + dy							' move to next/previous scan line
	NEXT y
'
'	a$ = INLINE$ ("press enter to continue...")
	DIM palette[]
	RETURN
'
'
' *****  Move1  *****
'
SUB Move1
	shift = 7 - off												' upper bits of byte first
	pixel = UBYTEAT (saddr)
	IF shift THEN pixel = pixel >> shift
	pixel = pixel AND 0x01
	off = off + 1
	IF (off = 8) THEN off = 0 : INC saddr
'
	red = palette[pixel].red
	green = palette[pixel].green
	blue = palette[pixel].blue
'
	rgb32 = 0
	rgb32 = rgb32 OR ((red << 24) AND 0xFFC00000)
	rgb32 = rgb32 OR ((green << 14) AND 0x003FF800)
	rgb32 = rgb32 OR ((blue << 3) AND 0x000007FF)
'
	XLONGAT (daddr) = rgb32
	daddr = daddr + 4
END SUB
'
'
' *****  Move4  *****
'
SUB Move4
	shift = 4 - off													' upper nybble of byte first
	pixel = UBYTEAT (saddr)
	IF shift THEN pixel = pixel >> shift
	pixel = pixel AND 0x0F
	off = off + 4
	IF (off = 8) THEN off = 0 : INC saddr
'
	blue = palette[pixel].blue
	green = palette[pixel].green
	red = palette[pixel].red
'
	rgb32 = 0
	rgb32 = rgb32 OR ((red << 24) AND 0xFFC00000)
	rgb32 = rgb32 OR ((green << 14) AND 0x003FF800)
	rgb32 = rgb32 OR ((blue << 3) AND 0x000007FF)
'
'	PRINT HEX$(rgb32,8); " : "; HEX$(red,2);; HEX$(green,2);; HEX$(blue,2)
'
	XLONGAT (daddr) = rgb32
	daddr = daddr + 4
END SUB
'
'
' *****  Move8  *****
'
SUB Move8
	pixel = UBYTEAT (saddr)
	INC saddr
'
	red = palette[pixel].red
	green = palette[pixel].green
	blue = palette[pixel].blue
'
	rgb32 = 0
	rgb32 = rgb32 OR ((red << 24) AND 0xFFC00000)
	rgb32 = rgb32 OR ((green << 14) AND 0x003FF800)
	rgb32 = rgb32 OR ((blue << 3) AND 0x000007FF)
'
	XLONGAT (daddr) = rgb32
	daddr = daddr + 4
END SUB
'
'
' *****  Move16  *****
'
SUB Move16
	byte0 = UBYTEAT (saddr)	: INC saddr
	byte1 = UBYTEAT (saddr) : INC saddr
	pixel = (byte1 << 8) OR byte0
'
	red = (pixel AND redMask) >> redMaskLow
	green = (pixel AND greenMask) >> greenMaskLow
	blue = (pixel AND blueMask) >> blueMaskLow
'
	rgb32 = 0
	rgb32 = rgb32 OR ((red << (32 - redBits)) AND 0xFFC00000)
	rgb32 = rgb32 OR ((green << (22 - greenBits)) AND 0x003FF800)
	rgb32 = rgb32 OR ((blue << (11 - blueBits)) AND 0x000007FF)
'
	XLONGAT (daddr) = rgb32
	daddr = daddr + 4
END SUB
'
'
' *****  Move24  *****
'
SUB Move24
	blue = UBYTEAT (saddr) : INC saddr
	green = UBYTEAT (saddr) : INC saddr
	red = UBYTEAT (saddr) : INC saddr
'
	rgb32 = 0
	rgb32 = rgb32 OR ((red << 24) AND 0xFFC00000)
	rgb32 = rgb32 OR ((green << 14) AND 0x003FF800)
	rgb32 = rgb32 OR ((blue << 3) AND 0x000007FF)
'
	XLONGAT (daddr) = rgb32
	daddr = daddr + 4
END SUB
'
'
' *****  Move32  *****
'
SUB Move32
	byte0 = UBYTEAT (saddr)	: INC saddr
	byte1 = UBYTEAT (saddr) : INC saddr
	byte2 = UBYTEAT (saddr)	: INC saddr
	byte3 = UBYTEAT (saddr) : INC saddr
	pixel = (byte3 << 24) OR (byte2 << 16) OR (byte1 << 8) OR byte0
'
	red = (pixel AND redMask) >> redMaskLow
	green = (pixel AND greenMask) >> greenMaskLow
	blue = (pixel AND blueMask) >> blueMaskLow
'
	rgb32 = 0
	rgb32 = rgb32 OR ((red << (32 - redBits)) AND 0xFFC00000)
	rgb32 = rgb32 OR ((green << (22 - greenBits)) AND 0x003FF800)
	rgb32 = rgb32 OR ((blue << (11 - blueBits)) AND 0x000007FF)
'
	XLONGAT (daddr) = rgb32
	daddr = daddr + 4
END SUB
END FUNCTION
'
'
' ###############################
' #####  DispatchEvents ()  #####
' ###############################
'
FUNCTION  DispatchEvents (sync, wait)
	EXTERNAL  errno
	SHARED  FUNCADDR  ehelp[] (ANY)
	SHARED  FUNCADDR  event[] (ANY)
	SHARED  DISPLAY  display[]
	SHARED  maxConnect
	SHARED  connect[]
	SHARED  eventTime
	SHARED  flushTime
	SHARED  userCount
	SHARED	sysCount
	SHARED  debug
	SHARED	huh
	STATIC  trips
	AUTOX  conn[]
	AUTOX  UTIMEVAL  delay
	AUTOX  XAnyEvent  event
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	INC trips
	IF ##INEXIT THEN RETURN								' avoid trouble
	IF ##SOFTBREAK THEN RETURN						' break out first
	sdisplay = display[1].sdisplay				' default display
'
	IFZ sdisplay THEN
		##ERROR = ($$ErrorObjectDisplay << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "DispatchEvents() : no display exists"
		DEC trips
		RETURN ($$TRUE)
	END IF
'
	IF huh THEN
		IF whomask THEN
			trips$ = "[u" + STRING$(trips) + "."
		ELSE
			trips$ = "[s" + STRING$(trips) + "."
		END IF
		IF huh THEN XxxXstLog (@trips$)
	END IF
'
	IF sync THEN
		IF huh THEN XxxXstLog ("1")
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSync (sdisplay, $$FALSE)
		##LOCKOUT = lockout
		##WHOMASK = whomask
		IF huh THEN XxxXstLog ("2")
		flushTime = eventTime
	END IF
'
	loop = 0
	sunk = sync
	hang = wait
	flush = $$FALSE
	cancel = $$FALSE
	scount = sysCount
	ucount = userCount
'
'	write (1, &"[$", 2)
	DO
		IF huh THEN XxxXstLog ("3")
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		c = XEventsQueued (sdisplay, $$QueuedAlready)		' events pending ?
		##LOCKOUT = lockout
		##WHOMASK = whomask
		IF huh THEN XxxXstLog ("4")
'
		IFZ c THEN																	' if no events pending
			IF huh THEN XxxXstLog ("@")
			IF loop THEN EXIT DO											' exit if not initial loop
			IF huh THEN XxxXstLog ("#")
			IFZ hang THEN EXIT DO											' exit if "don't wait"
			IF huh THEN XxxXstLog ("$")
			IFZ sunk THEN															' if no sync yet
				IF huh THEN XxxXstLog ("5")
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				XSync (sdisplay, $$FALSE)
				##LOCKOUT = lockout
				##WHOMASK = whomask
				IF huh THEN XxxXstLog ("6")
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				c = XEventsQueued (sdisplay, $$QueuedAlready)
				##LOCKOUT = lockout
				##WHOMASK = whomask
				IF huh THEN XxxXstLog ("7")
				flushTime = eventTime
				sunk = $$TRUE
			END IF
		END IF
'
' need to flush output queue so graphics drawn by xlib functions
' appear on screen within a reasonable time - every 200ms or so.
' XFlush() flushes output, XSync() flushes output, fills input.
'
		IFZ (sunk OR flush) THEN
			IF ((eventTime - flushTime) > 200) THEN
				flushTime = eventTime											' flush output queue
				XFlush (sdisplay)													' every 200ms or so
				flush = $$TRUE
			END IF
		END IF
'
' if no events and not asked to wait then return
'
		IFZ c THEN																	' no events
			IFZ hang THEN EXIT DO											' no hang
			IFZ (sunk OR flush) THEN									' no events ready and
				XFlush (sdisplay)												' gonna hang, so better
				flush = $$TRUE													' flush graphics out
			END IF
		END IF
'
' wait for one event or signal caused message
'
		IF ##SOFTBREAK THEN EXIT DO									' break out of loop
		IF huh THEN XxxXstLog ("8")
'
' the following code segment works fine, except #TimeOut messages
' generated by grid timers (caused by interval timer signals) do not
' break out of XNextEvent() until another event occurs and therefore
' are often not noticed when they should be.  One example of ignored
' grid timer activity is the auto-repeat of scroll bar buttons.
'
'		##WHOMASK = 0
'		##LOCKOUT = $$TRUE
'		##WAITING = $$TRUE													' waiting for event
'		event.type = $$TRUE													' mark event as invalid
'		XNextEvent (sdisplay, &event)								' wait for next event
'		##WAITING = $$FALSE													' done waiting for event
'		##LOCKOUT = lockout
'		##WHOMASK = whomask
'
' the following code segment attempts to avoid locking up in
' XNextEvent() and thereby missing messages generated by signals
' from the likes of interval timers.
'
'		write (1, &"<?", 2)
'		GOTO skiper
		IFZ c THEN
'			write (1, &"|", 1)
			DO
'				write (1, &":", 1)
				delay.tv_sec = 1										' 0 seconds +
				delay.tv_usec = 10000								' 10ms = 10000us delay
				u = maxConnect >> 5
				uc = UBOUND (conn[])
				uct = UBOUND (connect[])
				IF (uc != u) THEN
					uc = u
					##WHOMASK = 0
					DIM conn[u]
					##WHOMASK = whomask
				END IF
				FOR nn = 0 TO u
					conn[nn] = connect[nn]
'					IF conn[nn] THEN a$ = STRING$(uct) + "!" + STRING$(maxConnect) + ":" + STRING$(nn) + "." + HEX$(conn[nn],8) + "\n" : write(1, &a$, LEN(a$))
				NEXT nn
'				IF (u > uct) THEN write (1, &"Disaster.A\n", 11)
'				IF (u > uc) THEN write (1, &"Disaster.B\n", 11)
'				write (1, &"=", 1)
				errno = 0
				ready = 1
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				##WAITING = $$TRUE												' waiting for event
				IFZ XEventsQueued (sdisplay, $$QueuedAlready) THEN
'					write (1, &"{", 1)
					ready = select (maxConnect+1, &conn[], 0, &conn[], &delay)
'					write (1, &"}", 1)
				END IF
				##WAITING = $$FALSE												' done waiting for event
				##LOCKOUT = lockout
				##WHOMASK = whomask
'				a$ = "{" + STRING$(ready) + "." + STRING$(errno) + "}"
'				write (1, &a$, LEN(a$))
				SELECT CASE TRUE
					CASE (ready < 0)	:	'	a$ = "^" + STRING$(errno) + "^\n"
															'	write (1, &a$, LEN(a$))
															EXIT DO																	' signal broke out of select
					CASE (ready = 0)	:	IF (userCount OR sysCount) THEN EXIT DO	' message added to queue
															IF (ucount < userCount) THEN EXIT DO		' message added to user queue
															IF (scount < sysCount) THEN EXIT DO			' message added to system queue
					CASE (ready > 0)	:	' !!! event ready !!!
				END SELECT
			LOOP UNTIL ready
'			write (1, &"+", 1)
			IF (ready <= 0) THEN EXIT DO								' message added to queue
		END IF
'		write (1, &"?>", 2)
skiper:
'
' event ready, so XNextEvent() will return immediately
'
'		write (1, &"[", 1)
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		event.type = $$TRUE													' mark event as invalid
		XNextEvent (sdisplay, &event)								' wait for next event
		##LOCKOUT = lockout
		##WHOMASK = whomask
'		write (1, &"]", 1)
		IF (event.type = $$TRUE) THEN EXIT DO				' no event received : signal broke out of XNextEvent()
		IF huh THEN XxxXstLog ("9")
'
' at least one event is ready
'
		IF (event.type < 0) THEN DO LOOP						' bad event type
		IF (event.type > $$LastEvent) THEN DO LOOP	' bad event type
		error = @event [event.type] (@event)				' call event function
		IF debug THEN @ehelp [event.type] (@event)	' display debug help
		hang = $$FALSE															' only hang once
		INC loop																		' count loops
	LOOP UNTIL ##SOFTBREAK
'	write (1, &"$]", 2)
'
	IF huh THEN
		IF whomask THEN
			trips$ = "." + STRING$(trips) + "u]"
		ELSE
			trips$ = "." + STRING$(trips) + "s]"
		END IF
		IF huh THEN XxxXstLog (@trips$)
	END IF
'
	DEC trips
'	a$ = "t" + STRING$(trips) + "t"
'	write (1, &a$, LEN(a$))
END FUNCTION
'
'
' #####################
' #####  Display  #####
' #####################
'
' display 0 = invalid
' display 1 = default display (reserved slot)
'
' command = $$Open
' command = $$Close
'
FUNCTION  Display (display, command, display$)
	SHARED  DISPLAY  display[]
	SHARED	display$[]
	SHARED  maxConnect
	SHARED  connect[]
	SHARED  bitmask[]
	SHARED  debug
	SHARED  r[]
	SHARED  g[]
	SHARED  b[]
	SHARED  rgb[]
	STATIC  default$
	AUTOX  XWindowAttributes  rootAttributes
	AUTOX  XColor  sc
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ default$ THEN GOSUB Initialize
'
	SELECT CASE command
		CASE $$Open			: GOSUB Open
		CASE $$Close		: GOSUB Close
		CASE ELSE				: GOSUB ErrorInvalidArgument
	END SELECT
	##LOCKOUT = lockout
	##WHOMASK = whomask
	RETURN (return)
'
'
' *****  Open  *****
'
SUB Open
	slot = 0
	display = 0
	upper = UBOUND (display$[])
'
' see if display is already open
'
	IFZ display$ THEN
		display = 1
	ELSE
		IF (display$ = default$) THEN
			display = 1
		ELSE
			FOR display = 2 TO upper
				IF (display$ = display$[display]) THEN EXIT SUB		' display open
				IFZ slot THEN
					IFZ display$[display] THEN slot = display				' available slot
				END IF
			NEXT display
		END IF
	END IF
'
' make room in display$[] and display[] for new display
'
	IF (display > upper) THEN
		IF slot THEN
			display = slot															' take available slot
		ELSE
			##WHOMASK = 0
			upper = display
			REDIM display[upper]												' create new slot
			REDIM display$[upper]
			##WHOMASK = whomask
		END IF
	END IF
'
' if display is already open, return without error
'
	IF (display[display].status AND $$Open) THEN		' display already open
		return = $$FALSE
		EXIT SUB
	END IF
'
' open a new display, default or otherwise
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	sdisplay = XOpenDisplay (&display$)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ sdisplay THEN
		##ERROR = ($$ErrorObjectDevice << 8) OR $$ErrorNatureInvalidName
		IF debug THEN PRINT "Display() : Open : error : XOpenDisplay() failed"
		return = $$TRUE
		EXIT SUB
	END IF
'
' get info about display and root (most via info on root window)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	screen = XDefaultScreen (sdisplay)
	sroot = XRootWindow (sdisplay, screen)
	visual = XDefaultVisual (sdisplay, screen)
	connect = XConnectionNumber (sdisplay)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF (connect > 0) THEN
		IF (connect > maxConnect) THEN maxConnect = connect
		upper = UBOUND (connect[])
		bit = connect AND 0x1F
		mask = bitmask[bit]
		word = connect >> 5
		IF (word > upper) THEN
			##WHOMASK = 0
			REDIM connect[word]
			##WHOMASK = whomask
		END IF
		connect[word] = connect[word] OR mask
	ELSE
		connect = 0
	END IF
'
'	a$ = "'" + STRING$(word) + ":" + STRING$(maxConnect) + "*" + STRING$(connect) + "." + HEX$(mask,8) + "'\n"
'	write (1, &a$, LEN(a$))
'
	status = XGetWindowAttributes (sdisplay, sroot, &rootAttributes)
'	PrintWindowAttributes (@rootAttributes)
'
	IFZ status THEN
		##ERROR = ($$ErrorObjectSystemRoutine << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "Display() : Open : error : XGetWindowAttributes(sroot)"
		return = $$TRUE
		EXIT SUB
	END IF
'
	black = XBlackPixel (sdisplay, screen)					' system black color #
	white = XWhitePixel (sdisplay, screen)					' system white color #
	colormap = XDefaultColormap (sdisplay, screen)	' the colormap
'
	display$[display] = display$                		' save display name
'
	display[display].display = display
	display[display].sdisplay = sdisplay
	display[display].status = $$Open
	display[display].selectedWindow = 0
	display[display].x = rootAttributes.x
	display[display].y = rootAttributes.y
	display[display].width = rootAttributes.width
	display[display].height = rootAttributes.height
	display[display].depth = rootAttributes.depth
	display[display].class = rootAttributes.class
	display[display].borderWidth = 0
	display[display].titleHeight = 0
	display[display].mouseX = 0
	display[display].mouseY = 0
	display[display].mouseState = 0
	display[display].mouseTime = 0
	display[display].mouseGrid = 0
	display[display].mouseWindow = 0
	display[display].mouseMessage = 0
	display[display].mouseFocusGrid = 0
	display[display].screen = screen
	display[display].visual = visual
	display[display].sroot = sroot
	display[display].connect = connect
	display[display].bitGravity = rootAttributes.bitGravity
	display[display].winGravity = rootAttributes.winGravity
	display[display].backingStore = rootAttributes.backingStore
	display[display].backingPlanes = rootAttributes.backingPlanes
	display[display].backingPixel = rootAttributes.backingPixel
	display[display].saveUnder = rootAttributes.saveUnder
	display[display].mapInstalled = rootAttributes.mapInstalled
	display[display].mapState = rootAttributes.mapState
	display[display].allEventMasks = rootAttributes.allEventMasks
	display[display].yourEventMask = rootAttributes.yourEventMask
	display[display].doNotPropagateMask = rootAttributes.doNotPropagateMask
	display[display].overrideRedirect = rootAttributes.overrideRedirect
	display[display].defaultColormap = colormap
	display[display].colormap = colormap
	display[display].black = black
	display[display].white = white
	display[display].color[0] = black
	display[display].color[124] = white
'
' disaster colormap has 0 = $$Black and 1-124 = $$White
'
	FOR i = 1 TO 127
		display[display].color[i] = white		' in case colors don't assign right
	NEXT i
'
' establish standard colors 0 to 124 in colormap
'
	color = 0
	FOR r = 0 TO 4
		FOR g = 0 TO 4
			FOR b = 0 TO 4
				sc.r = r[r]
				sc.g = g[g]
				sc.b = b[b]
				okay = XAllocColor (sdisplay, colormap, &sc)
				display[display].color[color] = sc.scolor
				INC color
			NEXT b
		NEXT g
	NEXT r
'
	##WHOMASK = whomask
END SUB
'
'
' *****  Close  *****
'
SUB Close
	IF InvalidDisplay (display) THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "Display() : Close : error : invalid display #"
		return = $$TRUE
	END IF
'
' check for invalid display #
'
	error = $$FALSE
	upper = UBOUND (display[])
	IFZ display[] THEN error = $$TRUE
	IF (display < 0) THEN error = $$TRUE
	IF (display > upper) THEN error = $$TRUE
	IFZ (display[display].status AND $$Open) THEN error = $$TRUE
'
	IF error THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		IF debug THEN PRINT "Display() : Close : error : invalid display #"
		return = $$TRUE
		EXIT SUB
	END IF
'
	sdisplay = display[display].sdisplay
	connect = display[display].connect
	display[display].sdisplay = 0
	display[display].connect = 0
	display[display].status = 0
	display$[display] = ""
'
	IF (connect > 0) THEN
		upper = UBOUND (connect[])
		bit = connect AND 0x1F
		mask = bitmask[bit]
		word = connect >> 5
		IF (word > upper) THEN
			upper = word
			##WHOMASK = 0
			REDIM connect[word]
			##WHOMASK = whomask
		END IF
		connect[word] = connect[word] AND NOT mask
		IF (connect >= maxConnect) THEN
			FOR wo = upper TO 0 STEP -1
				IF connect[wo] THEN maxConnect = (wo * 32) + 31
			NEXT wo
		END IF
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XCloseDisplay (sdisplay)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END SUB
'
'
' *****  ErrorInvalidArgument  *****
'
SUB ErrorInvalidArgument
	##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
	return = $$TRUE
END SUB
'
' *****  Initialize  *****
'
SUB Initialize
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	DIM display[1]												' 0 invalid : 1 default
	default = XDisplayName (&zero)				' get default display name
	default$ = CSTRING$ (default)					' make it a valid native string
	##LOCKOUT = lockout
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' #####################
' #####  Font ()  #####
' #####################
'
' o  font      = native font #
' i  display   = native display #
' i  ufont$    = font name string = empty string for default font
'
FUNCTION  Font (font, command, display, sfont, addrFont, size, weight, italic, angle, ufont$)
	SHARED	DISPLAY  display[]
	SHARED  FONT  font[]
	SHARED  ufont$[]
	SHARED	font$[]
	SHARED	debug
	STATIC	fixed$[]
	STATIC	sdefaultFont
	STATIC  sdefaultAddrFont
	XFontStruct  fontStruct
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ fixed$[] THEN GOSUB Initialize
'
	font = 0
	angle = 0
	IF InvalidDisplay (display) THEN
		##ERROR = ($$ErrorObjectDisplay << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "Font() : error : display argument invalid"; display
		RETURN ($$TRUE)
	END IF
'
	sdisplay = display[display].sdisplay
'
	IFZ sdefaultFont THEN
		##WHOMASK = $$FALSE
		addrFont = $$FALSE
		hold$ = ufont$
		file$ = "$XBDIR" + $$PathSlash$ + "templates" + $$PathSlash$ + "font.xxx"
		XstLoadStringArray (@file$, @def$[])
		IF def$[] THEN
			u = UBOUND (def$[])
			FOR i = 0 TO u
				ufont$ = TRIM$(def$[i])
				IF ufont$ THEN
					IF (ufont${0} != ''') THEN
						addrFont = 0
						GOSUB Create
						IF addrFont THEN EXIT FOR
					END IF
				END IF
			NEXT i
			DIM def$[]
		END IF
		IF addrFont THEN
			sdefaultAddrFont = addrFont
			sdefaultFont = sfont
		ELSE
			upper = UBOUND (fixed$[])
			FOR i = 0 TO upper
				ufont$ = fixed$[i]
				addrFont = 0
				GOSUB Create
				IF addrFont THEN EXIT FOR
			NEXT i
		END IF
		##WHOMASK = whomask
		sdefaultAddrFont = addrFont
		sdefaultFont = sfont
		ufont$ = hold$
	END IF
'
	SELECT CASE command
		CASE $$Create			: GOSUB Create
		CASE $$Destroy		: GOSUB Destroy
		CASE $$DestroyAll	: GOSUB DestroyAll
		CASE ELSE					: PRINT "Font() : unknown command"
	END SELECT
	##WHOMASK = whomask
	##LOCKOUT = lockout
	RETURN (return)
'
'
' *****  Create  *****
'
SUB Create
'
'	XstLog ("Font().Create.A : " + ufont$ + " " + STRING$(font) + " " + STRING$(size) + " " + STRING$(weight) + " " + STRING$(italic) + " " + STRING$(angle) + " " + HEX$(sfont,8) + " " + HEX$(addrFont,8))
'
	font = 0
	IFZ ufont$ THEN
		IF sdefaultFont THEN
			sfont = sdefaultFont
			addrFont = sdefaultAddrFont				' default font
			return = $$FALSE
			EXIT SUB
		END IF
	END IF
'
'	XstLog ("Font().Create.B : " + ufont$ + " " + STRING$(font) + " " + STRING$(size) + " " + STRING$(weight) + " " + STRING$(italic) + " " + STRING$(angle) + " " + HEX$(sfont,8) + " " + HEX$(addrFont,8))
'
	FOR f = 0 TO UBOUND (ufont$[])
		IF (ufont$ = ufont$[f]) THEN
			font = f
			sfont = font[font].sfont
			addrFont = font[font].addrFont		' font already created
			return = $$FALSE
			EXIT SUB
		END IF
	NEXT f
'
'	XstLog ("Font().Create.C : " + ufont$ + " " + STRING$(font) + " " + STRING$(size) + " " + STRING$(weight) + " " + STRING$(italic) + " " + STRING$(angle) + " " + HEX$(sfont,8) + " " + HEX$(addrFont,8))
'
	addrFont = 0
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	addrFont = XLoadQueryFont (sdisplay, &ufont$)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
'	XstLog ("Font().Create.D : " + ufont$ + " " + STRING$(font) + " " + STRING$(size) + " " + STRING$(weight) + " " + STRING$(italic) + " " + STRING$(angle) + " " + HEX$(sfont,8) + " " + HEX$(addrFont,8))
'
	IFZ addrFont THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureFailed
		IF debug THEN PRINT "Font() : Create : XLoadQueryFont() failed"
		##WHOMASK = whomask
		return = $$TRUE
		EXIT SUB
	END IF
'
	upper = UBOUND (font[])
	FOR font = 0 TO upper
		IFZ font[font].count THEN EXIT FOR
	NEXT font
'
	IF (font > upper) THEN
		upper = upper + 8
		##WHOMASK = 0
		REDIM font[upper]
		REDIM font$[upper]
		REDIM ufont$[upper]
		##WHOMASK = whomask
	END IF
'
	##WHOMASK = 0
	font$[font] = ""											' font name
	ufont$[font] = ufont$									' unix font name
	##WHOMASK = whomask
'
	XLONGAT (&&fontStruct) = addrFont
'
	sfont = fontStruct.fid
	ascent = fontStruct.ascent
	descent = fontStruct.descent
'
	minWidth = fontStruct.minBoundsWidth
	minAscent = fontStruct.minBoundsAscent
	minDescent = fontStruct.minBoundsDescent
	maxWidth = fontStruct.maxBoundsWidth
	maxAscent = fontStruct.maxBoundsAscent
	maxDescent = fontStruct.maxBoundsDescent
'
'	PRINT "Font() : sfont, ascent, descent = ";
'	PRINT "Font() :"; HEX$(sfont), ascent, descent
'	PRINT "Font() : min width,ascent,descent"
'	PRINT "Font() :";  minWidth, minAscent, minDescent
'	PRINT "Font() : max width,ascent,descent"
'	PRINT "Font() :";  maxWidth, maxAscent, maxDescent
'
	font[font].font = font
	font[font].sfont = sfont
	font[font].addrFont = addrFont
	font[font].size = size
	font[font].weight = weight
	font[font].italic = italic
	font[font].angle = angle
	font[font].count = font[font].count + 1
	font[font].width = maxWidth
	font[font].height = ascent + descent
	font[font].ascent = ascent
	font[font].descent = descent
'	XstLog ("Font().Create.Z : " + ufont$ + " " + STRING$(font) + " " + STRING$(size) + " " + STRING$(weight) + " " + STRING$(italic) + " " + STRING$(angle) + " " + HEX$(sfont,8) + " " + HEX$(addrFont,8))
	return = $$FALSE
END SUB
'
'
' *****  Destroy  *****
'
SUB Destroy
	IF debug THEN PRINT "Font() : Destroy : unimplemented"
END SUB
'
'
' *****  DestroyAll  *****
'
SUB DestroyAll
	IF debug THEN PRINT "Font() : DestroyAll : unimplemented"
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	##WHOMASK = 0
	DIM font[7]
	DIM font$[7]
	DIM ufont$[7]
	DIM fixed$[7]
	fixed$[0] = "6x13"
	fixed$[1] = "7x13"
	fixed$[2] = "8x13"
	fixed$[3] = "9x15"
	fixed$[4] = "6x13bold"
	fixed$[5] = "7x13bold"
	fixed$[6] = "8x13bold"
	fixed$[7] = "9x15bold"
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ###################################
' #####  GetNewWindowNumber ()  #####
' ###################################
'
FUNCTION  GetNewWindowNumber (@wingrid)
	SHARED  WINDOW  window[]
	SHARED  window$[]
	SHARED  charMap[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ window[] THEN
		##WHOMASK = 0
		DIM window[63]
		DIM window$[63]
		DIM charMap[63,]
		##WHOMASK = whomask
	END IF
'
	upper = UBOUND (window[])
'
	FOR wingrid = 1 TO upper
		IFZ window[wingrid].window THEN EXIT FOR
	NEXT wingrid
'
	IF (wingrid > upper) THEN
		##WHOMASK = 0
		upper = upper + 64
		REDIM window[upper]
		REDIM window$[upper]
		REDIM charMap[upper,]
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ################################
' #####  GraphicsContext ()  #####
' ################################
'
' o  gc        = system gc = graphics context (return value)
' i  command   = $$Create, $$Destroy
' i  sdisplay  = system display #
' i  swindow   = system window #
' i  sfont     = system font #
'
FUNCTION  GraphicsContext (gc, command, sdisplay, screen, swindow, sfont)
	SHARED	debug
	XGCValues  gcvalues
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	SELECT CASE command
		CASE $$Create		: GOSUB Create
		CASE ELSE				: IF debug THEN PRINT "GraphicsContext() : bad command"
	END SELECT
	RETURN (return)
'
'
' *****  Create  *****
'
SUB Create
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	sblack = XBlackPixel (sdisplay, screen)
	swhite = XWhitePixel (sdisplay, screen)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
' The default of lineWidth = 0 screws up on SCO UNIX
' when the line goes out of grid/window.  ! STUPID !
' But when lineWidth = 1 the lines are ragged, have
' pixel gaps here and there, look generally rotten,
' and draw slower than hell.  !!!! Yell at SCO !!!!
'
	valuemask = 0
'	gcvalues.lineWidth = 1
	gcvalues.background = sblack
	gcvalues.foreground = swhite
	IF sfont THEN
		gcvalues.font = sfont
		valuemask = valuemask OR $$GCFont
	END IF
'	valuemask = valuemask OR $$GCLineWidth
	valuemask = valuemask OR $$GCBackground OR $$GCForeground
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	gc = XCreateGC (sdisplay, swindow, valuemask, &gcvalues)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ##############################
' #####  InvalidCursor ()  #####
' ##############################
'
FUNCTION  InvalidCursor (cursor)
	SHARED  cursor$[]
	SHARED  cursor[]
'
	upper = UBOUND (cursor[])
	IF (cursor < 0) THEN RETURN ($$TRUE)					' bad cursor #
	IF (cursor > upper) THEN RETURN ($$TRUE)			' bad cursor #
	IF cursor THEN
		IFZ cursor$[cursor] THEN RETURN ($$TRUE)		' not registered
		IFZ cursor[cursor] THEN RETURN ($$TRUE)			' not registered
	END IF
END FUNCTION
'
'
' ###############################
' #####  InvalidDisplay ()  #####
' ###############################
'
FUNCTION  InvalidDisplay (display)
	SHARED  DISPLAY  display[]
	SHARED  debug
'
	upper = UBOUND (display[])
'
	IF (display <= 0) THEN
		##ERROR = ($$ErrorObjectDisplay << 8) OR $$ErrorNatureInvalidNumber
		IF debug THEN PRINT "InvalidDisplay() : (display < 0)"
		RETURN ($$TRUE)
	END IF
'
	IF (display > upper) THEN
		##ERROR = ($$ErrorObjectDisplay << 8) OR $$ErrorNatureInvalidNumber
		IF debug THEN PRINT "InvalidDisplay() : (display > upper)"
		RETURN ($$TRUE)
	END IF
'
	IFZ (display[display].status AND $$Open) THEN
		##ERROR = ($$ErrorObjectDisplay << 8) OR $$ErrorNatureInvalidNumber
		IF debug THEN PRINT "InvalidDisplay() : (display not open)"
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' ############################
' #####  InvalidFont ()  #####
' ############################
'
FUNCTION  InvalidFont (font)
	SHARED  FONT  font[]
'
	upper = UBOUND (font[])
	IF ((font < 0) OR (font > upper)) THEN RETURN ($$TRUE)	' invalid font #
	IFZ (font[font].sfont) THEN RETURN ($$TRUE)							' not open
END FUNCTION
'
'
' ############################
' #####  InvalidGrid ()  #####
' ############################
'
FUNCTION  InvalidGrid (grid)
	SHARED  WINDOW  window[]
'
	upper = UBOUND (window[])
	IF ((grid <= 0) OR (grid > upper)) THEN RETURN ($$TRUE)		' invalid grid #
	IFZ window[grid].swindow THEN RETURN ($$TRUE)							' not open
	IFZ window[grid].window THEN RETURN ($$TRUE)							' not open
END FUNCTION
'
'
' ################################
' #####  InvalidGridType ()  #####
' ################################
'
FUNCTION  InvalidGridType (gridType)
	SHARED  gridType$[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	upper = UBOUND (gridType$[])
	IF (gridType < 0) THEN RETURN ($$TRUE)
	IF (gridType > upper) THEN RETURN ($$TRUE)
	IFZ (gridType$[gridType]) THEN RETURN ($$TRUE)
END FUNCTION
'
'
' ############################
' #####  InvalidIcon ()  #####
' ############################
'
FUNCTION  InvalidIcon (icon)
	SHARED  sicon[]
	SHARED  icon$[]
	SHARED  icon[]
'
	upper = UBOUND (icon[])
	IF (icon < 0) THEN RETURN ($$TRUE)					' bad icon #
	IF (icon > upper) THEN RETURN ($$TRUE)			' bad icon #
	IF icon THEN
		IFZ sicon[icon] THEN RETURN ($$TRUE)			' not registered
		IFZ icon$[icon] THEN RETURN ($$TRUE)			' not registered
		IFZ icon[icon] THEN RETURN ($$TRUE)				' not registered
	END IF
END FUNCTION
'
'
' ##############################
' #####  InvalidWindow ()  #####
' ##############################
'
FUNCTION  InvalidWindow (window)
	SHARED  WINDOW  window[]
'
	upper = UBOUND (window[])
	IF ((window <= 0) OR (window > upper)) THEN RETURN ($$TRUE)	' invalid window #
	IFZ window[window].swindow THEN RETURN ($$TRUE)							' no system window #
	IFZ window[window].window THEN RETURN ($$TRUE)							' not open
END FUNCTION
'
'
' ################################
' #####  KeyboardMessage ()  #####
' ################################
'
FUNCTION  KeyboardMessage (message)
	SHARED  message$[]
	SHARED  debug
'
	upper = UBOUND (message$[])
	IF (message <= 0) THEN
		##ERROR = ($$ErrorObjectMessage << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "KeyboardMessage() : invalid message # : message # < 0"
		RETURN ($$FALSE)		' DEFINITELY NOT A KEYBOARD MESSAGE
	END IF
'
	IF (message > upper) THEN
		##ERROR = ($$ErrorObjectMessage << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "KeyboardMessage() : invalid message # : message > upper"
		RETURN ($$FALSE)		' DEFINITELY NOT A KEYBOARD MESSAGE
	END IF
'
	SELECT CASE message
		CASE #WindowKeyDown	: RETURN ($$TRUE)
		CASE #WindowKeyUp		: RETURN ($$TRUE)
		CASE #KeyDown				: RETURN ($$TRUE)
		CASE #KeyUp					: RETURN ($$TRUE)
	END SELECT
END FUNCTION
'
'
' ####################
' #####  Log ()  #####
' ####################
'
FUNCTION  Log (message$, newline)
'
	#log = OPEN ("log.txt", $$WR)
'
	IF #log THEN
		end = LOF (#log)
		SEEK (#log, end)
		IFZ newline THEN
			PRINT [#log], message$
		ELSE
			PRINT [#log], "\n" + message$
		END IF
		CLOSE (#log)
	END IF
'
	IF #print THEN
		IFZ newline THEN
			PRINT message$
		ELSE
			PRINT "\n" + message$
		END IF
	END IF
END FUNCTION
'
'
' #############################
' #####  MouseMessage ()  #####
' #############################
'
FUNCTION  MouseMessage (message)
	SHARED  message$[]
	SHARED  debug
'
	upper = UBOUND (message$[])
	IF (message <= 0) THEN
		##ERROR = ($$ErrorObjectMessage << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "MouseMessage() : invalid message # : message # < 0"
		RETURN ($$FALSE)		' DEFINITELY NOT A MOUSE MESSAGE
	END IF
'
	IF (message > upper) THEN
		##ERROR = ($$ErrorObjectMessage << 8) OR $$ErrorNatureInvalid
		IF debug THEN PRINT "MouseMessage() : invalid message # : message > upper"
		RETURN ($$FALSE)		' DEFINITELY NOT A MOUSE MESSAGE
	END IF
'
	SELECT CASE message
		CASE #WindowMouseDown		: RETURN ($$TRUE)		' mouse message
		CASE #WindowMouseDrag		: RETURN ($$TRUE)		' mouse message
		CASE #WindowMouseEnter	: RETURN ($$TRUE)		' mouse message
		CASE #WindowMouseExit		: RETURN ($$TRUE)		' mouse message
		CASE #WindowMouseMove		: RETURN ($$TRUE)		' mouse message
		CASE #WindowMouseUp			: RETURN ($$TRUE)		' mouse message
		CASE #MouseDown					: RETURN ($$TRUE)		' mouse message
		CASE #MouseDrag					: RETURN ($$TRUE)		' mouse message
		CASE #MouseEnter				: RETURN ($$TRUE)		' mouse message
		CASE #MouseExit					: RETURN ($$TRUE)		' mouse message
		CASE #MouseMove					: RETURN ($$TRUE)		' mouse message
		CASE #MouseUp						: RETURN ($$TRUE)		' mouse message
	END SELECT
END FUNCTION
'
'
' ############################
' #####  NormalAngle ()  #####
' ############################
'
FUNCTION  NormalAngle (angle#)
'
	IFZ angle# THEN RETURN
'	SELECT CASE angle#
'		CASE $$NINF	: angle# = 0# : RETURN ($$TRUE)
'		CASE $$PINF	: angle# = 0# : RETURN ($$TRUE)
'		CASE $$NNAN	: angle# = 0# : RETURN ($$TRUE)
'		CASE $$PNAN	: angle# = 0# : RETURN ($$TRUE)
'	END SELECT
'
	IF ((angle# >= 0#) AND (angle# <= $$TWOPI)) THEN RETURN
'
	a# = ABS (angle#)
	IF (a# > $$TWOPI) THEN
		rev# = a# / $$TWOPI				' angle in units of $$TWOPI revolutions
		irev# = INT (rev#)				' integer # of $$TWOPI revolutions
		a# = rev# - irev#					' 0# <= a# < $$TWOPI
	END IF
'
	IF (angle# < 0#) THEN				' if original angle was negative
		a# = $$TWOPI - a#					' 0# <= a# < $$TWOPI
	END IF
'
	angle# = a#
END FUNCTION
'
'
' #####################################
' #####  NormalAnglePlusMinus ()  #####
' #####################################
'
FUNCTION  NormalAnglePlusMinus (angle#)
'
	IFZ angle# THEN RETURN
'	SELECT CASE angle#
'		CASE $$NINF	: angle# = 0# : RETURN ($$TRUE)
'		CASE $$PINF	: angle# = 0# : RETURN ($$TRUE)
'		CASE $$NNAN	: angle# = 0# : RETURN ($$TRUE)
'		CASE $$PNAN	: angle# = 0# : RETURN ($$TRUE)
'	END SELECT
'
	IF ((angle# >= -$$TWOPI) AND (angle# <= $$TWOPI)) THEN RETURN
'
	IF (angle < 0#) THEN a# = -angle# ELSE a# = angle#
'
	IF (a# > $$TWOPI) THEN
		rev# = a# / $$TWOPI				' angle in units of $$TWOPI revolutions
		irev# = INT (rev#)				' integer # of $$TWOPI revolutions
		a# = rev# - irev#					' 0# <= a# < $$TWOPI
	END IF
'
	IF (angle# < 0#) THEN angle# = -a# ELSE angle# = a#
END FUNCTION
'
'
' ##################################
' #####  RedrawGridAndKids ()  #####
' ##################################
'
FUNCTION  RedrawGridAndKids (grid, action, xWin, yWin, width, height)
	SHARED  WINDOW  window[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = window[grid].top
	gridType = window[grid].type
	IFZ window[grid].state THEN RETURN ($$FALSE)
	IF (gridType = $$GridTypeImage) THEN RETURN ($$FALSE)
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	x1Win = xWin
	y1Win = yWin
	x2Win = xWin + width - 1
	y2Win = yWin + height - 1
	XgrGetGridBoxWindow (grid, @gx1, @gy1, @gx2, @gy2)
	gdx = gx2 - gx1
	gdy = gy2 - gy1
'
	exposed = $$TRUE
	IF ((width <= 0) OR (height <= 0)) THEN
		x1 = 0
		y1 = 0
		x2 = 0
		y2 = 0
		ww = 0
		hh = 0
	ELSE
		IF (x1Win > gx2) THEN exposed = $$FALSE
		IF (y1Win > gy2) THEN exposed = $$FALSE
		IF (x2Win < gx1) THEN exposed = $$FALSE
		IF (y2Win < gy1) THEN exposed = $$FALSE
		x1 = x1Win - gx1
		y1 = y1Win - gy1
		x2 = x2Win - gx1
		y2 = y2Win - gy1
		IF (x1 < 0) THEN x1 = 0
		IF (y1 < 0) THEN y1 = 0
		IF (x2 > gdx) THEN x2 = gdx
		IF (y2 > gdy) THEN y2 = gdy
		ww = x2 - x1 + 1
		hh = y2 - y1 + 1
	END IF
'
	IFZ exposed THEN RETURN ($$FALSE)
'
' send or queue a #RedrawGrid to the grid itself
'
	buffer = window[grid].buffer
	IF buffer THEN
		IF InvalidGrid (buffer) THEN THEN buffer = 0
	END IF
'
' if grid is buffered, refresh it and skip #RedrawGrid
'
	IF buffer THEN
'		PRINT "RedrawWindowAndKids() : call XgrRefreshGrid() : "; grid, buffer
		XgrRefreshGrid (grid)
	ELSE
		IFZ action THEN
			XgrAddMessage (grid, #RedrawGrid, x1, y1, ww, hh, 0, grid)
		ELSE
			XgrSendMessage (grid, #RedrawGrid, x1, y1, ww, hh, 0, grid)
		END IF
	END IF
'
' send or queue #RedrawGrid to its kids, and their kids, etc...
'
	FOR gg = 1 TO UBOUND (window[])
		g = window[gg].window
		IF g THEN
			IF (g = gg) THEN
				IF window[g].state THEN
					IF (grid = window[g].parent) THEN
						RedrawGridAndKids (g, action, xWin, yWin, width, height)
					END IF
				END IF
			END IF
		END IF
	NEXT gg
END FUNCTION
'
'
' ##############################
' #####  RemoveMessage ()  #####
' ##############################
'
' this internal function expects 0 or 1 in window to designate sys/user queue
'
FUNCTION  RemoveMessage (wingrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  MESSAGE  message[]
	SHARED  userCount
	SHARED  sysCount
	SHARED  userOut
	SHARED  sysOut
	SHARED  userIn
	SHARED  sysIn
	SHARED  inQueue
	SHARED  debug
	SHARED  huh
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	queue = wingrid
	IF queue THEN queue = 1
'
	IF inQueue THEN PRINT "RemoveMessage() : inQueue"
	inQueue = $$TRUE
	GOSUB UpdateVariables
'
	IF huh THEN
		kkk$ = STRING$(count)
		IF queue THEN XxxXstLog ("(*r"+kkk$) ELSE XxxXstLog ("(*R"+kkk$)
	END IF
'
	IFZ count THEN							' error : no messages
		wingrid = 0
		message = 0
		v0 = 0
		v1 = 0
		v2 = 0
		v3 = 0
		r0 = 0
		r1 = 0
		inQueue = $$FALSE
		RETURN ($$TRUE)
	END IF
	upper = UBOUND (message[queue,])
'
' get message arguments from queue
'
	wingrid = message[queue,out].wingrid
	message = message[queue,out].message
	v0 = message[queue,out].v0
	v1 = message[queue,out].v1
	v2 = message[queue,out].v2
	v3 = message[queue,out].v3
	r0 = message[queue,out].r0
	r1 = message[queue,out].r1
'
' remove message from queue
'
	IFZ queue THEN
		INC sysOut
		DEC sysCount
		IF (sysOut > upper) THEN sysOut = 0					' wrap around
		IF huh THEN
			kkk$ = STRING$(sysCount)
			XxxXstLog ("-"+kkk$+"S*)")
		END IF
	ELSE
		INC userOut
		DEC userCount
		IF (userOut > upper) THEN userOut = 0				' wrap around
		IF huh THEN
			kkk$ = STRING$(userCount)
			XxxXstLog ("-"+kkk$+"U*)")
		END IF
	END IF
'
	inQueue = $$FALSE
'
'	XgrMessageNumberToName (message, @message$)
'	PRINT " R["; wingrid;; message$; "]"
	RETURN ($$FALSE)
'
'
' *****  UpdateVariables  *****
'
SUB UpdateVariables
	IF queue THEN
		ceo = userCEO
		count = userCount
		out = userOut
		in = userIn
	ELSE
		ceo = sysCEO
		count = sysCount
		out = sysOut
		in = sysIn
	END IF
END SUB
END FUNCTION
'
'
' ################################
' #####  SetBackgroundColor  #####
' ################################
'
FUNCTION  SetBackgroundColor (window, color)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	gc = window[window].gc
	sdisplay = window[window].sdisplay
	sbackground = window[window].sbackground
	sbackgroundDefault = window[window].sbackgroundDefault
'
	IF (color = -1) THEN
		scolor = window[window].sbackgroundDefault
	ELSE
		ConvertColorToSystemColor (window, color, @scolor)
	END IF
'
'	PRINT "SetBackgroundColor() : "; window, color, scolor, sbackground, sbackgroundDefault
'
	IF (scolor = -1) THEN RETURN
	IF (scolor = sbackground) THEN RETURN
	window[window].sbackground = scolor
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSetBackground (sdisplay, gc, scolor)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ##############################
' #####  SetBackgroundRGB  #####
' ##############################
'
FUNCTION  SetBackgroundRGB (window, red, green, blue)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	gc = window[window].gc
	sdisplay = window[window].sdisplay
	sbackground = window[window].sbackground
	sbackgroundDefault = window[window].sbackgroundDefault
	ConvertRGBToSystemColor (window, red, green, blue, @scolor)
'
'	PRINT "SetBackgroundRGB() : "; window, red, green, blue, scolor, sbackground, sbackgroundDefault
'
	IF (scolor = -1) THEN RETURN
	IF (scolor = sbackground) THEN RETURN
	window[window].sbackground = scolor
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSetBackground (sdisplay, gc, scolor)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' #############################
' #####  SetDrawingColor  #####
' #############################
'
FUNCTION  SetDrawingColor (window, color)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	gc = window[window].gc
	sdisplay = window[window].sdisplay
	sforeground = window[window].sforeground
	sforegroundDefault = window[window].sforegroundDefault
'
	IF (color = -1) THEN
		scolor = window[window].sforegroundDefault
	ELSE
		ConvertColorToSystemColor (window, color, @scolor)
	END IF
'
'	PRINT "SetDrawingColor() : "; window, color, scolor, sforeground, sforegroundDefault
'
	IF (scolor = -1) THEN RETURN
	IF (scolor = sforeground) THEN RETURN
	window[window].sforeground = scolor
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSetForeground (sdisplay, gc, scolor)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###########################
' #####  SetDrawingRGB  #####
' ###########################
'
FUNCTION  SetDrawingRGB (window, red, green, blue)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	gc = window[window].gc
	sdisplay = window[window].sdisplay
	sforeground = window[window].sforeground
	sforegroundDefault = window[window].sforegroundDefault
	ConvertRGBToSystemColor (window, red, green, blue, @scolor)
'
'	PRINT "SetDrawingRGB() : "; window, red, green blue, scolor, sforeground, sforegroundDefault
'
	IF (scolor = -1) THEN RETURN
	IF (scolor = sforeground) THEN RETURN
	window[window].sforeground = scolor
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSetForeground (sdisplay, gc, scolor)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END FUNCTION
'
'
' ###############################################
' #####  SystemButtonStateToButtonState ()  #####
' ###############################################
'
' 0-3 : button number that caused event
' 4-6 : # of clicks (1 to 4)								handled by calling function
'   7 : window has mouse focus (always 1)
'  16 : ShiftKey state       : 1 = down
'  17 : ControlKey state     : 1 = down
'  18 : AltKey state         : 1 = down
'  24 : mouse button 1 state : 1 = down
'  25 : mouse button 2 state : 1 = down
'  26 : mouse button 3 state : 1 = down
'  27 : mouse button 4 state : 1 = down
'  28 : mouse button 5 state : 1 = down
'
FUNCTION  SystemButtonStateToButtonState (button, system, time, state)
'
	state = button AND 0x0007			' 0-3 : 0 = none : 1 = button1 : 2 = button2 : ...
	state = state OR 0x0080				'   7 : window has mouse focus
	IF (system AND $$ShiftMask)   THEN state = state OR $$MouseShiftKey    ' 16 : Shift
	IF (system AND $$ControlMask) THEN state = state OR $$MouseControlKey  ' 17 : Ctrl
	IF (system AND $$Mod1Mask)    THEN state = state OR $$MouseAltKey      ' 18 : Alt
	IF (system AND $$Mod2Mask)    THEN state = state OR $$MouseMod2Key     ' 19 : ?
	IF (system AND $$Mod3Mask)    THEN state = state OR $$MouseMod3Key     ' 20 : ?
	IF (system AND $$Mod4Mask)    THEN state = state OR $$MouseMod4Key     ' 21 : ?
	IF (system AND $$Mod5Mask)    THEN state = state OR $$MouseMod5Key     ' 22 : ?
	IF (system AND $$Button1Mask) THEN state = state OR $$MouseButton1     ' 24 : Left
	IF (system AND $$Button2Mask) THEN state = state OR $$MouseButton2     ' 25 : Middle
	IF (system AND $$Button3Mask) THEN state = state OR $$MouseButton3     ' 26 : Right
	IF (system AND $$Button4Mask) THEN state = state OR $$MouseButton4     ' 27 : Other
	IF (system AND $$Button5Mask) THEN state = state OR $$MouseButton5     ' 28 : Other
END FUNCTION
'
'
' #########################################
' #####  SystemKeyStateToKeyState ()  #####
' #########################################
'
' 00-15 : character code of some kind (see bits 20-22)
'    16 : ShiftKey state
'    17 : ControlKey state
'    18 : AltKey state
'    19 : reserved (right AltKey - bit 18 = 1 if either AltKey is down)
' 20-21 : 0 = 8-bit vkey : 1 = 8-bit ASCII char : 2 = 16-bit UNICODE char
'    22 : reserved (right ShiftKey - bit 16 = 1 if either ShiftKey is down)
'    23 : reserved (right ControlKey - bit 17 = 1 if either ControlKey is down)
' 24-31 : 8-bit vkey (virtual keycode)
'
FUNCTION  SystemKeyStateToKeyState (message, keysym, sstate, time, state)
	SHARED  UBYTE virtualKey00[]
	SHARED  UBYTE virtualKeyFF[]
	SHARED  UBYTE asciiKey00[]
	SHARED  UBYTE asciiKeyFF[]
	SHARED  UBYTE altChar[]
	SHARED	UBYTE	altCharFF[]
	SHARED  debug
	STATIC  mod
'
'	PRINT "keysym, sstate = "; HEX$(keysym,8);; HEX$(sstate,8)
	keygroup = (keysym >> 8) AND 0x00FF
	keytype = $$KeyTypeVirtualKey
	key = keysym AND 0x00FF
	ascii = $$FALSE
	state = 0
	vkey = 0
'
	SELECT CASE keygroup
		CASE 0x00	:	char = asciiKey00[key]
								vkey = virtualKey00[key]
								IF (sstate AND ($$AltMask OR $$RightAltMask)) THEN
									char = altChar[char]
								ELSE
									IF char THEN keytype = $$KeyTypeAscii
									IF (sstate AND $$ControlMask) THEN
										SELECT CASE TRUE
											CASE ((char >= 'A') AND (char <= 'Z'))		: char = char - 'A' + 1
											CASE ((char >= 'a') AND (char <= 'z'))		: char = char - 'a' + 1
											CASE ((char >= 0x5B) AND (char <= 0x5F))	: char = char - 'A' + 1
											CASE ((char >= 0x7B) AND (char <= 0x7E))	: char = char - 'a' + 1
										END SELECT
									END IF
								END IF
		CASE 0xFF	:	char = asciiKeyFF[key]
								vkey = virtualKeyFF[key]
								IF (sstate AND ($$AltMask OR $$RightAltMask)) THEN
									char = altCharFF[char]
									vkey = char										' to handle Alt+Keypadn
								ELSE
									IF char THEN keytype = $$KeyTypeAscii ELSE char = vkey
								END IF
		CASE ELSE	: char = keysym AND 0x0000FFFF		' unicode or disaster
								IF char = $$XK_ISO_Left_Tab THEN
									vkey = $$KeyTab
									sstate = $$TRUE
									char = 0
								ELSE
									vkey = 0
								END IF
								IF char THEN keytype = $$KeyTypeUnicode
	END SELECT
'
'
'	IF (sstate AND $$AltMask) THEN state = state OR $$AltBit
'	IF (sstate AND $$ShiftMask) THEN state = state OR $$ShiftBit
'	IF (sstate AND $$ControlMask) THEN state = state OR $$ControlBit
'	IF (sstate AND $$RightAltMask) THEN state = state OR $$RightAltBit
'	IF (sstate AND $$RightShiftMask) THEN state = state OR $$RightShiftBit
'	IF (sstate AND $$RightControlMask) THEN state = state OR $$RightControlBit
'
' the sstate bits were the states of the modifier keys BEFORE this event,
' so if this event is a modifier key going up or down, the sstate is wrong
' and must be fixed (because XBasic reports modifier states AFTER the event).
'
	IF (keytype = $$KeyTypeVirtualKey) THEN
		IFZ sstate THEN mod = 0
		SELECT CASE message
			CASE #WindowKeyDown
						SELECT CASE vkey
							CASE $$KeyAlt							: mod = mod OR $$AltBit								: ' state = state OR $$AltBit
							CASE $$KeyLeftAlt					: mod = mod OR $$AltBit								: ' state = state OR $$AltBit
							CASE $$KeyShift						: mod = mod OR $$ShiftBit							: ' state = state OR $$ShiftBit
							CASE $$KeyLeftShift				: mod = mod OR $$ShiftBit							: ' state = state OR $$ShiftBit
							CASE $$KeyControl					: mod = mod OR $$ControlBit						: ' state = state OR $$ControlBit
							CASE $$KeyLeftControl			: mod = mod OR $$ControlBit						: ' state = state OR $$ControlBit
							CASE $$KeyRightAlt				: mod = mod OR $$RightAltBit					: ' state = state OR mod OR $$AltBit
							CASE $$KeyRightShift			: mod = mod OR $$RightShiftBit				: ' state = state OR mod OR $$ShiftBit
							CASE $$KeyRightControl		: mod = mod OR $$RightControlBit			: ' state = state OR mod OR $$ControlBit
						END SELECT
			CASE #WindowKeyUp
						SELECT CASE vkey
							CASE $$KeyAlt							: mod = mod AND NOT $$AltBit					: ' IFZ (mod AND $$RightAltBit) THEN state = state AND NOT $$AltBit
							CASE $$KeyLeftAlt					: mod = mod AND NOT $$AltBit					: ' IFZ (sstate AND $$RightAltMask) THEN state = state AND NOT $$AltBit
							CASE $$KeyRightAlt				: mod = mod AND NOT $$RightAltBit			: ' state = state AND NOT $$RightAltBit : IFZ (sstate AND $$AltMask) THEN state = state AND NOT $$AltBit
							CASE $$KeyShift						: mod = mod AND NOT $$ShiftBit				: ' IFZ (sstate AND $$RightShiftMask) THEN state = state AND NOT $$ShiftBit
							CASE $$KeyLeftShift				: mod = mod AND NOT $$ShiftBit				: ' IFZ (sstate AND $$RightShiftMask) THEN state = state AND NOT $$ShiftBit
							CASE $$KeyRightShift			: mod = mod AND NOT $$RightShiftBit		: ' state = state AND NOT $$RightShiftBit : IFZ (sstate AND $$ShiftMask) THEN state = state AND NOT $$ShiftBit
							CASE $$KeyControl					: mod = mod AND NOT $$ControlBit			: ' IFZ (sstate AND $$RightControlMask) THEN state = state AND NOT $$ControlBit
							CASE $$KeyLeftControl			: mod = mod AND NOT $$ControlBit			: ' IFZ (sstate AND $$RightControlMask) THEN state = state AND NOT $$ControlBit
							CASE $$KeyRightControl		: mod = mod AND NOT $$RightControlBit	: ' state = state AND NOT $$RightControlBit : IFZ (sstate AND $$ControlMask) THEN state = state AND NOT $$ControlBit
						END SELECT
		END SELECT
	END IF
'
	state = char AND 0x0000FFFF
	state = state OR ((vkey AND 0x00FF) << 24)
	state = state OR ((keytype AND 0x0003) << 20)
	IF (mod AND $$AltBit) THEN state = state OR $$AltBit
	IF (mod AND $$ShiftBit) THEN state = state OR $$ShiftBit
	IF (mod AND $$ControlBit) THEN state = state OR $$ControlBit
	IF (mod AND $$RightAltBit) THEN state = state OR $$AltBit OR $$RightAltBit
	IF (mod AND $$RightShiftBit) THEN state = state OR $$ShiftBit OR $$RightShiftBit
	IF (mod AND $$RightControlBit) THEN state = state OR $$ControlBit OR $$RightControlBit
'
'	a$ = STRING$(keytype) + "." + HEX$(keysym,8) + " " + HEX$(sstate,8) + " " + HEX$(state,8) + ":" + HEX$(mod,8) + "\n"
'	write (1, &a$, LEN(a$))
END FUNCTION
'
'
' ############################
' #####  UpdateMouse ()  #####
' ############################
'
' generate a mouse message if the mouse moved in a system/user window
'
FUNCTION  UpdateMouse (who)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  flushTime
	SHARED  userCount
	SHARED  sysCount
 	SHARED  debug
	AUTOX  sroot
	AUTOX  schild
	AUTOX  rootX
	AUTOX  rootY
	AUTOX  winX
	AUTOX  winY
	AUTOX  status
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
' only update mouse if no events in the specified event queue
'
	IF who THEN
		IF userCount THEN RETURN ($$FALSE)		' user queue not empty
	ELSE
		IF sysCount THEN RETURN ($$FALSE)			' system queue not empty
	END IF
'
' should check all displays, but for now just check default display
'
	display = display[1].display
	IFZ display THEN RETURN ($$FALSE)		' default display not open
'
' get information about last mouse message put in queue
'
	mouseX = display[display].mouseX
	mouseY = display[display].mouseY
	mouseState = display[display].mouseState
	mouseTime = display[display].mouseTime
	mouseWindow = display[display].mouseWindow
	mouseGrid = display[display].mouseGrid
	mouseMessage = display[display].mouseMessage
'
' if one or more buttons are down, messages are generated automatically
'
	IF (mouseState AND $$MouseButtonMask) THEN RETURN ($$FALSE)
'
	grid = mouseGrid
	window = mouseGrid
	top = window[window].top
	swindow = window[window].swindow
	sdisplay = display[display].sdisplay
'
	destroy = window[window].destroy
	destroyed = window[window].destroyed
	processed = window[window].destroyProcessed	' grid no longer exists
	IF destroy THEN RETURN ($$FALSE)						' grid no longer exists
	IF destroyed THEN RETURN ($$FALSE)					' grid no longer exists
'
	IF (mouseGrid <= 0) THEN RETURN ($$FALSE)		' no mouse messages yet
	IFZ swindow THEN RETURN ($$FALSE)						' no mouse messages yet
'
' force any server events into event queue
'
	discard = 0
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSync (sdisplay, discard)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	flushTime = eventTime
'
' only update mouse if no events in the specified event queue
'
	IF who THEN
		IF userCount THEN RETURN ($$FALSE)		' user queue not empty
	ELSE
		IF sysCount THEN RETURN ($$FALSE)			' system queue not empty
	END IF
'
' get mouse state - keys/buttons are unchanged since no events pending
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XQueryPointer (sdisplay, swindow, &sroot, &schild, &rootX, &rootY, &winX, &winY, &status)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
' if XQueryPointer() generated an event, don't generate a mouse message
'
	IF who THEN
		IF userCount THEN RETURN ($$FALSE)		' user queue not empty
	ELSE
		IF sysCount THEN RETURN ($$FALSE)			' system queue not empty
	END IF
'
	SystemButtonStateToButtonState (0, status, 0, @state)
'
	change = $$FALSE
	IF (mouseX != winX) THEN change = $$TRUE		' mouse x motion
	IF (mouseY != winY) THEN change = $$TRUE		' mouse y motion
	IFZ change THEN RETURN ($$FALSE)
'
	message = #WindowMouseMove
	v0 = winX
	v1 = winY
	v2 = mouseState
	v3 = mouseTime + 1
	r0 = 0
	r1 = mouseGrid
'
	display[display].mouseX = v0
	display[display].mouseY = v1
	display[display].mouseState = v2
	display[display].mouseTime = v3
	display[display].mouseGrid = grid
	display[display].mouseWindow = top
	display[display].mouseMessage = message
'
	XgrAddMessage (top, message, v0, v1, v2, v3, r0, r1)
END FUNCTION
'
'
' ###################################
' #####  UpdateScaledCoords ()  #####
' ###################################
'
' Whenever a grid is resized the relationship between local coordinates
' and scaled coordinates changes, thus the multipliers that convert
' local coordinates into scaled coordinates and vice versa also change.
'
' Call UpdateScaledCoords() to update the conversion multipliers from
' the current width,height in pixels, and gridBoxScaled coordinates.
' Since drawing into most grids is not performed in scaled coordinates,
' it is more efficient to call UpdateScaledCoords() the first time a
' scaled coordinate draw or conversion is performed after a resize.
'
' Scaled multipliers of 0# are invalid and would cause divide by zero
' exceptions, so they are set to 0# during resizes to indicate their
' values have not yet been calculated.
'
FUNCTION  UpdateScaledCoordinates (grid)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	window = grid
	x1# = window[window].gridBoxScaledX1
	y1# = window[window].gridBoxScaledY1
	x2# = window[window].gridBoxScaledX2
	y2# = window[window].gridBoxScaledY2
'
	IF (x1# = x2#) THEN x1# = 0 : x2# = 1#			' avoid math exceptions
	IF (y1# = y2#) THEN y1# = 0 : y2# = 1#			' avoid math exceptions
	window[window].gridBoxScaledX1 = x1#
	window[window].gridBoxScaledY1 = y1#
	window[window].gridBoxScaledX2 = x2#
	window[window].gridBoxScaledY2 = y2#
'
	XgrGetGridPositionAndSize (grid, @x, @y, @width, @height)
'
	IFZ width THEN width = 1										' avoid math exceptions
	IFZ height THEN height = 1									' avoid math exceptions
	IF (width < 0) THEN width = -width
	IF (height < 0) THEN height = -height
'
	x1 = 0
	y1 = 0
	x2 = width - 1
	y2 = height - 1
	IF (x2 = 0) THEN x2 = 1											' avoid math exceptions
	IF (y2 = 0) THEN y2 = 1											' avoid math exceptions
'
	mx# = (x2# - x1#) / DOUBLE (x2)
	my# = (y2# - y1#) / DOUBLE (y2)
	window[window].xScaledPerPixel = mx#
	window[window].yScaledPerPixel = my#
	window[window].xPixelsPerScaled = 1# / mx#
	window[window].yPixelsPerScaled = 1# / my#
END FUNCTION
'
'
' ####################################
' #####  LocalToBufferCoords ()  #####
' ####################################
'
' Compute the two local buffer grid coordinates bx1,by1:bx2,by2
' that correspond to the two local grid coordinates x1,y1:x2,y2.
' Confirm the buffer grid argument is the grid number of the
' buffer grid attached to grid.
'
' Return the system window number of the buffer grid, as well as
' an overlap variable that tells where the x1,y1:x2,y2 line or
' box extends beyond the boundaries of the grid and buffer grid,
' plus where the grid extends beyond the buffer grid and where
' the buffer grid extends beyond the grid.  The overlap variable
' also tells where the region is totally outside the grid and
' buffer grid, as well as when the grid and buffer grid do not
' overlap each other (a pretty sad situation for buffer grids).
'
' The bufferX and bufferY variables are the values assigned to
' grid by XgrSetGridBuffer (grid, buffer, bufferX, bufferY).
' Note that bufferX and bufferY are distances from origin of
' the grid to the buffer grid, so they are positive when the
' buffer grid is to the right and below the grid 0,0 origin.
'
' This function is called by many drawing routines that draw
' to a grid in local grid coordinates, then draw again to the
' potentially offset buffer grid in local buffer coordinates.
'
FUNCTION  LocalToBufferCoords (grid, buffer, @sbuffer, @overlap, x1, y1, x2, y2, @xx1, @yy1, @xx2, @yy2)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	xx1 = 0
	yy1 = 0
	xx2 = 0
	yy2 = 0
	sbuffer = 0
	overlap = 0
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "LocalToBufferCoords() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	IF InvalidGrid (buffer) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "LocalToBufferCoords() : invalid buffer grid #"; buffer
		RETURN ($$TRUE)
	END IF
'
	window = grid
	check = window[grid].buffer
	bufferX = window[grid].bufferX
	bufferY = window[grid].bufferY
	sbuffer = window[buffer].swindow
'
	IF (sbuffer <= 0) THEN RETURN ($$FALSE)
	IF (buffer != check) THEN RETURN ($$FALSE)
'
' local coords of grid
'
	gx1 = 0
	gy1 = 0
	gx2 = window[grid].width - 1
	gy2 = window[grid].height - 1
'
' local coords of buffer
'
	bx1 = 0
	by1 = 0
	bx2 = window[buffer].width - 1
	by2 = window[buffer].height - 1
'
' grid local coordinates of buffer grid
'
	bgx1 = bx1 + bufferX
	bgy1 = by1 + bufferY
	bgx2 = bx2 + bufferX
	bgy2 = by2 + bufferY
'
' buffer local coordinates at x1,y1:x2,y2 grid local coordinates
'
	xx1 = x1 - bufferX
	yy1 = y1 - bufferY
	xx2 = x2 - bufferX
	yy2 = y2 - bufferY
'
' sort buffer local coordinates of region so (lx1 < lx2) and (ly1 < ly2)
'
	IF (xx1 <= xx2) THEN lx1 = xx1 : lx2 = xx2 ELSE lx1 = xx2 : lx2 = xx1
	IF (yy1 <= yy2) THEN ly1 = yy1 : ly2 = yy2 ELSE ly1 = yy2 : ly2 = yy1
'
' sort grid local coordinates of region so (ax1 < ax2) and (ay1 < ay2)
'
	IF (x1 <= x2) THEN ax1 = x1 : ax2 = x2 ELSE ax1 = x2 : ax2 = x1
	IF (y1 <= y2) THEN ay1 = y1 : ay2 = y2 ELSE ay1 = y2 : ay2 = y1
'
' note where region extends beyond the buffer grid
'
	IF (lx1 < bx1) THEN overlap = overlap OR $$RegionExceedsBufferLeft
	IF (ly1 < by1) THEN overlap = overlap OR $$RegionExceedsBufferTop
	IF (lx2 > bx2) THEN overlap = overlap OR $$RegionExceedsBufferRight
	IF (ly2 > by2) THEN overlap = overlap OR $$RegionExceedsBufferBottom
'
' note where region extends beyond the grid
'
	IF (ax1 < gx1) THEN overlap = overlap OR $$RegionExceedsGridLeft
	IF (ay1 < gy1) THEN overlap = overlap OR $$RegionExceedsGridTop
	IF (ax2 > gx2) THEN overlap = overlap OR $$RegionExceedsGridRight
	IF (ay2 > gy2) THEN overlap = overlap OR $$RegionExceedsGridBottom
'
' note where buffer grid extends outside the grid
'
	IF (gx1 > bgx1) THEN overlap = overlap OR $$BufferExceedsGridLeft
	IF (gy1 > bgy1) THEN overlap = overlap OR $$BufferExceedsGridTop
	IF (gx2 < bgx2) THEN overlap = overlap OR $$BufferExceedsGridRight
	IF (gy2 < bgy2) THEN overlap = overlap OR $$BufferExceedsGridBottom
'
' note where grid extends outside the buffer grid
'
	IF (gx1 < bgx1) THEN overlap = overlap OR $$GridExceedsBufferLeft
	IF (gy1 < bgy1) THEN overlap = overlap OR $$GridExceedsBufferTop
	IF (gx2 > bgx2) THEN overlap = overlap OR $$GridExceedsBufferRight
	IF (gy2 > bgy2) THEN overlap = overlap OR $$GridExceedsBufferBottom
'
' note where region is totally outside buffer grid
'
	IF (bx1 > lx2) THEN overlap = overlap OR $$RegionOutsideBufferLeft
	IF (by1 > ly2) THEN overlap = overlap OR $$RegionOutsideBufferTop
	IF (bx2 < lx1) THEN overlap = overlap OR $$RegionOutsideBufferRight
	IF (by2 < ly2) THEN overlap = overlap OR $$RegionOutsideBufferBottom
'
' note where region is totally outside grid
'
	IF (gx1 > ax2) THEN overlap = overlap OR $$RegionOutsideGridLeft
	IF (gy1 > ay2) THEN overlap = overlap OR $$RegionOutsideGridTop
	IF (gx2 < ax1) THEN overlap = overlap OR $$RegionOutsideGridRight
	IF (gy2 < ay1) THEN overlap = overlap OR $$RegionOutsdieGridBottom
'
' note where buffer grid is totally outside grid
'
	IF (gx1 > bgx2) THEN overlap = overlap OR $$BufferOutsideGridLeft
	IF (gy1 > bgy2) THEN overlap = overlap OR $$BufferOutsideGridTop
	IF (gx2 < bgx1) THEN overlap = overlap OR $$BufferOutsideGridRight
	IF (gy2 < bgy1) THEN overlap = overlap OR $$BufferOutsideGridBottom
'
' note where grid is totally outside buffer grid
'
	IF (bgx1 > gx2) THEN overlap = overlap OR $$GridOutsideBufferLeft
	IF (bgy1 > gy2) THEN overlap = overlap OR $$GridOutsideBufferTop
	IF (bgx2 < gx1) THEN overlap = overlap OR $$GridOutsideBufferRight
	IF (bgy2 < gy1) THEN overlap = overlap OR $$GridOutsideBufferBottom
END FUNCTION
'
'
' **************************************************
' *****  Event  EventFunction  EventStructure  *****
' **************************************************
'
' ButtonPress         EventButtonPress()          XButtonEvent
' ButtonRelease       EventButtonRelease()        XButtonEvent
' CirculateNotify     EventCirculateNotify()      XCirculateEvent
' CirculateRequest    EventCirculateRequest()     XCirculateRequestEvent
' ClientMessage       EventClientMessage()        XClientMessageEvent
' ColormapNotify      EventColormapNotify()       XColormapEvent
' ConfigureNotify     EventConfigureNotify()      XConfigureEvent
' ConfigureRequest    EventConfigureRequest()     XConfigureRequestEvent
' CreateNotify        EventCreateNotify()         XCreateWindowEvent
' DestroyNotify       EventDestroyNotify()        XDestroyWindowEvent
' EnterNotify         EventEnterNotify()          XCrossingEvent
' Error               EventError()                XErrorEvent
' Expose              EventExpose()               XExposeEvent
' FocusIn             EventFocusIn()              XFocusChangeEvent
' FocusOut            EventFocusOut()             XFocusChangeEvent
' GraphicsExpose      EventGraphicsExpose()       XGraphicsExposeEvent
' GravityNotify       EventGravityNotify()        XGravityEvent
' KeyPress            EventKeyPress()             XKeyEvent
' KeyRelease          EventKeyRelease()           XKeyEvent
' KeymapNotify        EventKeymapNotify()         XKeymapEvent
' LeaveNotify         EventLeaveNotify()          XCrossingEvent
' MapNotify           EventMapNotify()            XMapEvent
' MapRequest          EventMapRequest()           XMapRequestEvent
' MappingNotify       EventMappingNotify()        XMappingEvent
' MotionNotify        EventMotionNotify()         XMotionEvent
' NoExpose            EventNoExpose()             XNoExposeEvent
' PropertyNotify      EventPropertyNotify()       XPropertyEvent
' ReparentNotify      EventReparentNotify()       XReparentEvent
' ResizeRequest       EventResizeRequest()        XResizeRequestEvent
' SelectionClear      EventSelectionClear()       XSelectionClearEvent
' SelectionNotify     EventSelectionNotify()      XSelectionEvent
' SelectionRequest    EventSelectionRequest()     XSelectionRequestEvent
' UnmapNotify         EventUnmapNotify()          XUnmapEvent
' VisibilityNotify    EventVisibilityNotify()     XVisibilityEvent
'
'
'
' #################################
' #####  EventButtonPress ()  #####
' #################################
'
FUNCTION  EventButtonPress (XButtonEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  modalWindowSystem
	SHARED  modalWindowUser
	SHARED  eventTime
	SHARED  flushTime
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	eventTime = event.time
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
	grid = window
	window = top
'
	IFZ window THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventButtonPress() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IFZ grid THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventButtonPress() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	stop = window[window].stop
	display = window[window].display
	sdisplay = window[window].sdisplay
'
	time = event.time
	button = event.button
	clickTime = window[grid].clickTime
	clickCount = window[grid].clickCount
	clickButton = window[grid].clickButton
'
	SystemButtonStateToButtonState (event.button, event.state, event.time, @state)
'
' event.state contains the button state BEFORE this ButtonPress event,
' so the pressed button must be set manually.
'
	SELECT CASE event.button
		CASE $$Button1	: state = state OR $$MouseButton1
		CASE $$Button2	: state = state OR $$MouseButton2
		CASE $$Button3	: state = state OR $$MouseButton3
		CASE $$Button4	: state = state OR $$MouseButton4
		CASE $$Button5	: state = state OR $$MouseButton5
	END SELECT
'
	count = 1
	delta = time - clickTime
	IF (delta < 250) THEN
		IF (button = clickButton) THEN
			IF (clickCount < 4) THEN count = clickCount + 1
		END IF
	END IF
'
	state = state OR (count << 4)
	window[grid].clickTime = time
	window[grid].clickCount = count
	window[grid].clickButton = button
'
' always remember last mouse event added to queue
'
	message = #WindowMouseDown
	display[display].mouseX = v0
	display[display].mouseY = v1
	display[display].mouseState = v2
	display[display].mouseTime = v3
	display[display].mouseGrid = grid
	display[display].mouseWindow = window
	display[display].mouseMessage = message
	display[display].mouseFocusGrid = grid
'
' If window != current selected window then make it so.
' XSetInputFocus() generates FocusOut and FocusIn events.
' FocusOut and FocusIn generate #Deselected and #Selected messages.
'
	who = window[window].whomask
	IF who THEN modal = modalWindowUser ELSE modal = modalWindowSystem
	selectedWindow = display[display].selectedWindow
	suppress = $$FALSE
'
	IF modal THEN
		IF (top != modal) THEN
			top = modal
			suppress = $$TRUE
			stop = window[modal].swindow
		END IF
	END IF
'
'	PRINT "EventButtonPress().A : "; HEX$(top,8);; HEX$(who,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; window;; grid;; suppress
'
	IF (top != selectedWindow) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XSetInputFocus (sdisplay, stop, $$RevertToParent, 0)
		XSync (sdisplay, $$FALSE)
		##LOCKOUT = $$FALSE
		##WHOMASK = whomask
		flushTime = eventTime
'		PRINT "EventButtonPress().B : "; HEX$(top,8);; HEX$(who,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; window;; grid;; suppress
	END IF
'
' add #WindowMouseDown message to message queue
'
	IFZ suppress THEN
		IF (event.button == $$Button4) OR (event.button == $$Button5) THEN
			' MouseWheel is usually mapped to button4 and 5 on Linux (button4 is
			' up, button5 is down).
			' Add 'ZAxisMapping 4 5' to the 'Pointer' section in your XF86Config
			' to enable it.
			message = #WindowMouseWheel
			v0 = event.x
			v1 = event.y
			v2 = state
			v3 = 1
			IF event.button == $$Button5 THEN
				v3 = -v3
			END IF
			r0 = 0
			r1 = grid
		ELSE
			message = #WindowMouseDown
			v0 = event.x
			v1 = event.y
			v2 = state
			v3 = event.time
			r0 = 0
			r1 = grid
		END IF
		XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
'		PRINT "EventButtonPress().C : "; HEX$(top,8);; HEX$(who,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; window;; grid;; suppress
	END IF
END FUNCTION
'
'
' ###################################
' #####  EventButtonRelease ()  #####
' ###################################
'
FUNCTION  EventButtonRelease (XButtonEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  debug
'
	eventTime = event.time
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
	grid = window
	window = top
'
	IFZ window THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventButtonRelease() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IFZ grid THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventButtonRelease() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	top = window[window].top
	stop = window[window].stop
	display = window[window].display
	sdisplay = window[window].sdisplay
'
	SystemButtonStateToButtonState (event.button, event.state, event.time, @state)
'
' event.state contains the button state BEFORE this ButtonRelease event,
' so the released button must be cleared manually.
'
	SELECT CASE event.button
		CASE $$Button1	: state = state AND NOT $$MouseButton1
		CASE $$Button2	: state = state AND NOT $$MouseButton2
		CASE $$Button3	: state = state AND NOT $$MouseButton3
		CASE $$Button4	: state = state AND NOT $$MouseButton4
		CASE $$Button5	: state = state AND NOT $$MouseButton5
	END SELECT
'
	message = #WindowMouseUp
	v0 = event.x
	v1 = event.y
	v2 = state
	v3 = event.time
	r0 = 0
	r1 = grid
'
' always remember last mouse event added to queue
'
	display[display].mouseX = v0
	display[display].mouseY = v1
	display[display].mouseState = v2
	display[display].mouseTime = v3
	display[display].mouseGrid = grid
	display[display].mouseWindow = window
	display[display].mouseMessage = message
	display[display].mouseFocusGrid = grid
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
END FUNCTION
'
'
' #####################################
' #####  EventCirculateNotify ()  #####
' #####################################
'
FUNCTION  EventCirculateNotify (XCirculateEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventCirculateNotify() : no action or message"
END FUNCTION
'
'
' ######################################
' #####  EventCirculateRequest ()  #####
' ######################################
'
FUNCTION  EventCirculateRequest (XCirculateRequestEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventCirculateRequest() : no action or message"
END FUNCTION
'
'
' ###################################
' #####  EventClientMessage ()  #####
' ###################################
'
FUNCTION  EventClientMessage (XClientMessageEvent event)
	SHARED  WINDOW  window[]
	SHARED  event$[]
	SHARED  debug
'
	swindow = event.window								' should be valid system window #
	message = event.data[0]								' should be #XA_WM_DELETE_WINDOW
	messageType = event.messageType				' should be #XA_WM_PROTOCOLS
'
	XgrSystemWindowToWindow (swindow, @window, @top)
'
'	PRINT "EventClientMessage() : "; event.type, messageType, message
'
	SELECT CASE message
		CASE #XA_WM_TAKE_FOCUS		:	' not requested
		CASE #XA_WM_SAVE_YOURSELF	:	' not requested
		CASE #XA_WM_DELETE_WINDOW	: message = #WindowClose
																IF (window > 0) THEN
																	IF (window = top) THEN
																		IF window[window].destroy THEN message = #WindowDestroyed
																		IF window[window].destroyed THEN message = #WindowDestroyed
																		IF window[window].destroyProcessed THEN message = #windowDestroyed
																		XgrAddMessage (window, message, 0, 0, 0, 0, 0, window)
'																		PRINT "EventClientMessage() : WM_DELETE_WINDOW : "; window;; HEX$(swindow,8);;
'																		IF (message = #WindowClose) THEN PRINT "#WindowClose" ELSE PRINT "#WindowDestroyed"
																	END IF
																END IF
	END SELECT
END FUNCTION
'
'
' ####################################
' #####  EventColormapNotify ()  #####
' ####################################
'
FUNCTION  EventColormapNotify (XColormapEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventColormapNotify() : no action or message"
END FUNCTION
'
'
' #####################################
' #####  EventConfigureNotify ()  #####
' #####################################
'
FUNCTION  EventConfigureNotify (XConfigureEvent event)
	SHARED	WINDOW  window[]
	SHARED  debug
	AUTOX  rootX,  rootY,  schild
'
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IFZ window THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventConfigureNotify() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	kind = window[window].kind
	sroot = window[window].sroot
	mapped = window[window].mapped
	sparent = window[window].sparent
	sdisplay = window[window].sdisplay
	borderWidth = window[window].borderWidth
	titleHeight = window[window].titleHeight
'
' must ignore when unmapped ::: later: why ???
'
	IF (window != top) THEN RETURN		' windows only
'
' Find top-level window coordinates on the display aka root window.
' The x,y coordinates supplied in this event are total lies because
' the window manager creates artificial parents to implement the
' window resize frame.  XGeometry() and all other functions return
' bogus values.  Only XTranslateCoordinates() works.
'
'	PRINT "<XTC";
	XTranslateCoordinates (sdisplay, swindow, sroot, 0, 0, &rootX, &rootY, &schild)
'	PRINT ">"
'
' get x,y,width,height from this event plus XTranslateCoordinates()
'
	x = rootX								' window xDisp
	y = rootY								' window yDisp
	width = event.width			' width of window
	height = event.height		' height of window
'
' get previous x, y, width, height
'
	xx = window[window].x
	yy = window[window].y
	ww = window[window].width
	hh = window[window].height
'
'	PRINT "EventConfigureNotify().A : "; window;; event.x; event.y;; x; y; event.width; event.height;;;; xx; yy; ww; hh;;;; event.sendEvent;; mapped
'
	IFZ mapped THEN
		IFZ event.sendEvent THEN RETURN				' not mapped, not interesting
		sendMessage = $$TRUE
	END IF
'
'	PRINT "EventConfigureNotify().B : "; window;; event.x; event.y;; x; y; event.width; event.height;;;; xx; yy; ww; hh;;;; event.sendEvent;; mapped
'
' set new x, y, width, height
'
	window[window].x = x
	window[window].y = y
	window[window].width = width
	window[window].height = height
'
' see if window was moved and/or resized
'
	move = $$FALSE
	resize = $$FALSE
	IF (xx != x) THEN move = $$TRUE
	IF (yy != y) THEN move = $$TRUE
	IF (ww != width) THEN resize = $$TRUE
	IF (hh != height) THEN resize = $$TRUE
'
' if window moved, note previous position
'
	IF move THEN
		window[window].priorX = xx
		window[window].priorY = yy
	END IF
'
' if window resized, note previous size and update grid/scaled coords
'
	IF resize THEN
		window[window].priorWidth = ww					'
		window[window].priorHeight = hh					'
		window[window].xScaledPerPixel = 0#			' invalidate
		window[window].yScaledPerPixel = 0#			' scaled coordinate
		window[window].xPixelsPerScaled = 0#		' multipliers
		window[window].yPixelsPerScaled = 0#		'
'
		gridBoxX1 = window[window].gridBoxX1		' current
		gridBoxY1 = window[window].gridBoxY1		' grid box
		gridBoxX2 = window[window].gridBoxX2		' coords
		gridBoxY2 = window[window].gridBoxY2		'
'
		IF (gridBoxX2 < gridBoxX1) THEN
			gridBoxX2 = gridBoxX1 - width + 1			' x coords decrease rightward
		ELSE
			gridBoxX2 = gridBoxX1 + width - 1			' x coords increase rightward
		END IF
'
		IF (gridBoxY2 < gridBoxY1) THEN
			gridBoxY2 = gridBoxY1 - height + 1		' y coords decrease downward
		ELSE
			gridBoxY2 = gridBoxY1 + height - 1		' y coords increase downward
		END IF
'
		window[window].gridBoxX1 = gridBoxX1
		window[window].gridBoxY1 = gridBoxY1
		window[window].gridBoxX2 = gridBoxX2
		window[window].gridBoxY2 = gridBoxY2
	END IF
'
	IF (sendMessage OR move OR resize) THEN
'		PRINT "EventConfigureNotify().C : "; window;; x; y; width; height;;;; event.sendEvent;; mapped
		message = #WindowResized
		v0 = x
		v1 = y
		v2 = width
		v3 = height
		r0 = 0
		r1 = window
		XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
	END IF
END FUNCTION
'
'
' ######################################
' #####  EventConfigureRequest ()  #####
' ######################################
'
FUNCTION  EventConfigureRequest (XConfigureRequestEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventConfigureRequest() : no action or message"
END FUNCTION
'
'
' ##################################
' #####  EventCreateNotify ()  #####
' ##################################
'
FUNCTION  EventCreateNotify (XCreateWindowEvent event)
	SHARED  WINDOW  window[]
	SHARED	debug
'
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
	RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventCreateNotify() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IF (window[window].kind != $$KindWindow) THEN RETURN	' for windows only
'
	x = event.x
	y = event.y
	width = event.width
	height = event.height
	sparent = event.parent
	sdisplay = event.display
'
	message = #WindowCreated
	v0 = x
	v1 = y
	v2 = width
	v3 = height
	r0 = 0
	r1 = window
'
	IF (sparent = window[window].sroot) THEN
		parent = 0
	ELSE
		XgrSystemWindowToWindow (sparent, @parent, @ptop)
	END IF
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
'
	window[window].x = v0
	window[window].y = v1
	window[window].width = v2
	window[window].height = v3
'
	IF (sparent != window[window].sparent) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureUnexpected
		IF debug THEN PRINT "EventCreateNotify() : unexpected sparent #"
	END IF
'
	IF (parent != window[window].parent) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureUnexpected
		IF debug THEN PRINT "EventCreateNotify() : unexpected parent #"
	END IF
'
	IF (sdisplay != window[window].sdisplay) THEN
		##ERROR = ($$ErrorObjectDisplay << 8) OR $$ErrorNatureUnexpected
		IF debug THEN PRINT "EventCreateNotify() : unexpected sdisplay #"
	END IF
END FUNCTION
'
'
' ###################################
' #####  EventDestroyNotify ()  #####
' ###################################
'
' As of 95 Feb 08, GraphicsDesigner does not add #Destroyed messages
' for grids, only #WindowDestroyed messages for windows.  This is not
' good design, but the Windows version of GraphicsDesigner works this
' way, and GuiDesigner works the Windows way.  To change this will
' require changes to both versions of GraphicsDesigner and GuiDesigner.
'
' The current method works because the only time grids are destroyed
' is when a user program calls XgrDestroyGrid() and when a window is
' destroyed by user action or a user program calls XgrDestroyWindow().
'
FUNCTION  EventDestroyNotify (XDestroyWindowEvent event)
	SHARED  debug
	SHARED  textSelectionGrid
	SHARED  WINDOW  window[]
	STATIC  WINDOW  zipwin
'
	sevent = event.event
	swindow = event.window
	XgrSystemWindowToWindow (swindow, @window, @top)
	upper = UBOUND (window[])
'
'	a$ = "EventDestroyNotify().A : " + STRING$(window) + " : " + HEX$(swindow,8) + " : " + HEX$(sevent,8) + "\n"
'	write (1, &a$, LEN(a$))
'
	IF InvalidWindow (window) THEN
		IF ((window < 0) OR (window > upper)) THEN
			##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "EventDestroyNotify() : invalid window #"; window
			RETURN ($$TRUE)
		END IF
		IF window[window].destroyProcessed THEN
			##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "EventDestroyNotify() : window already destroyed and processed : invalid window #"; window
			RETURN ($$TRUE)
		END IF
		IF window[window].destroyed THEN
			##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "EventDestroyNotify() : window already destroyed : invalid window #"; window
			RETURN ($$TRUE)
		END IF
		IFZ window[window].destroy THEN
			##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "EventDestroyNotify() : invalid window #"; window
			RETURN ($$TRUE)
		END IF
	END IF
'
	IF (window = textSelectionGrid) THEN textSelectionGrid = 0
'
' Event handling functions normally add appropriate messages
' to the message queue.  If this function did so, it would add
' a #Destroyed message for grids and a #WindowDestroyed for
' windows.  This function does not add any messages to the
' message queue at this time for two reasons.  First, grids
' currently receive #Destroy messages from GuiDesigner when
' it processes a #WindowDestroyed message.  Second, the way
' GuiDesigner works now, it has to receive #WindowDestroyed
' before the window is actually destroyed, to prevent calls
' to functions that attempt to manipulate grids that have
' already been destroyed.  Just in case a window does get
' destroyed without XgrDestroyWindow() being called, this
' function does add #WindowDestroyed message if it finds
' window[window].destroy is $$FALSE.
'
	destroy = window[window].destroy
'
	IF (window = top) THEN
		func = window[window].winFunc
		window[window].destroy = $$TRUE
		window[window].destroyed = $$TRUE
		IFZ destroy THEN XgrAddMessage (window, #WindowDestroyed, func, 0, 0, 0, 0, window)
'		a$ = "EventDestroyNotify().W : " + STRING$(window) + " : " + HEX$(swindow,8) + " : " + HEX$(sevent,8) + "\n"
'		write (1, &a$, LEN(a$))
	ELSE
		func = window[window].gridFunc
		window[window].destroy = $$TRUE
		window[window].destroyed = $$TRUE
		window[window].destroyProcessed = $$TRUE
'		XgrAddMessage (window, #Destroyed, func, 0, 0, 0, 0, window)
'		a$ = "EventDestroyNotify().G : " + STRING$(window) + " : " + HEX$(swindow,8) + " : " + HEX$(sevent,8) + "\n"
'		write (1, &a$, LEN(a$))
	END IF
'	a$ = "EventDestroyNotify().Z : " + STRING$(window) + " : " + HEX$(swindow,8) + " : " + HEX$(sevent,8) + "\n"
'	write (1, &a$, LEN(a$))
END FUNCTION
'
'
' #################################
' #####  EventEnterNotify ()  #####
' #################################
'
FUNCTION  EventEnterNotify (XCrossingEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  debug
'
	eventTime = event.time
	subwindow = event.subwindow
	IF subwindow THEN RETURN									' skip parents
'
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
	grid = window
	window = top
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventEnterNotify() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventEnterNotify() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	stop = window[window].stop
	display = window[window].display
	sdisplay = window[window].sdisplay
'
	SystemButtonStateToButtonState (0, event.state, event.time, @state)
'
	message = #WindowMouseEnter
	v0 = event.x
	v1 = event.y
	v2 = state
	v3 = event.time
	r0 = 0
	r1 = grid
'
' always remember last mouse event added to queue
'
	display[display].mouseX = v0
	display[display].mouseY = v1
	display[display].mouseState = v2
	display[display].mouseTime = v3
	display[display].mouseGrid = grid
	display[display].mouseWindow = window
	display[display].mouseMessage = message
	display[display].mouseFocusGrid = grid
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
END FUNCTION
'
'
' ###########################
' #####  EventError ()  #####
' ###########################
'
FUNCTION  EventError (XErrorEvent event)
	SHARED  debug
	AUTOX  error$
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
'
	sdisplay = event.display
	serror = event.errorCode
'
	error$ = NULL$ (1023)
	XGetErrorText (sdisplay, serror, &error$, 1023)
	error$ = CSIZE$ (error$)
'
	a$ = "System error of failed request : " + error$ + "\n"
	b$ = "Failure code of failed request : " + STRING$(event.errorCode) + "\n"
	c$ = "Major opcode of failed request : " + STRING$(event.requestCode) + "\n"
	d$ = "Minor opcode of failed request : " + STRING$(event.minorCode) + "\n"
	e$ = "Resource ID for failed request : " + HEX$(event.resourceid) + "\n"
	f$ = "Serial number : failed request : " + STRING$(event.serial) + "\n\n"
'
	write (1, &a$, LEN(a$))
	write (1, &b$, LEN(b$))
	write (1, &c$, LEN(c$))
	write (1, &d$, LEN(d$))
	write (1, &e$, LEN(e$))
	write (1, &f$, LEN(f$))
'
	##WHOMASK = whomask
	##LOCKOUT = lockout
END FUNCTION
'
'
' ############################
' #####  EventExpose ()  #####
' ############################
'
FUNCTION  EventExpose (XExposeEvent event)
	SHARED  WINDOW  window[]
	SHARED	noExpose
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	swindow = event.window
	sdisplay = event.display
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventExpose() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IF (window = noExpose) THEN RETURN ($$FALSE)		' suppress #RedrawGrid
'
	x1 = event.x
	y1 = event.y
	x2 = x1 + event.width - 1
	y2 = y1 + event.height - 1
'
' process all consecutive expose messages
' combine all consecutive expose messages to same window into one message
'
	DO
		xx1 = event.x
		yy1 = event.y
		xx2 = xx1 + event.width - 1
		yy2 = yy1 + event.height - 1
		count = event.count
'
		IF (xx1 < x1) THEN x1 = xx1
		IF (yy1 < y1) THEN y1 = yy1
		IF (xx2 > x2) THEN x2 = xx2
		IF (yy2 > y2) THEN y2 = yy2
'
		more = 0
		IF count THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			more = XCheckTypedWindowEvent (sdisplay, swindow, event.type, &event)
			##LOCKOUT = lockout
			##WHOMASK = whomask
		END IF
	LOOP WHILE more
'
' prepare #WindowRedraw or #RedrawGrid message
'
	message = #WindowRedraw
	IF (window != top) THEN message = #RedrawGrid
	v0 = x1
	v1 = y1
	v2 = x2 - x1 + 1
	v3 = y2 - y1 + 1
	r0 = 0
	r1 = window
'
	grid = window
	buffer = window[grid].buffer
	IF buffer THEN
		IF InvalidGrid (buffer) THEN buffer = 0
	END IF
	IF buffer THEN
		XgrRefreshGrid (grid)
	ELSE
		XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
	END IF
END FUNCTION
'
'
' #############################
' #####  EventFocusIn ()  #####
' #############################
'
' if a modal window is active and a FocusIn event to another window
' in the application occurs, a #Selected message is sent to the new
' focus window, but XSetInputFocus() is called to restore input focus
' to the modal window.
'
FUNCTION  EventFocusIn (XFocusChangeEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  modalWindowSystem
	SHARED  modalWindowUser
	SHARED  eventTime
	SHARED  flushTime
	SHARED  debug
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventFocusIn() : invalid window #"; window, top
		RETURN ($$TRUE)
	END IF
'
	IF (window != top) THEN
		IF InvalidWindow (top) THEN
			##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "EventFocusIn() : invalid top window #"; window, top
			RETURN ($$TRUE)
		END IF
	END IF
'
	window = top
	display = window[window].display
	sdisplay = window[window].sdisplay
	selectedWindow = display[display].selectedWindow
	display[display].selectedWindow = window
	IF (window = selectedWindow) THEN RETURN
'
	suppress = $$FALSE
	who = window[window].whomask
	IF who THEN modal = modalWindowUser ELSE modal =  modalWindowSystem
'	PRINT "EventFocusIn().A : "; HEX$(who,8);; HEX$(window,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; suppress
'
	IF modal THEN
		IF (window != modal) THEN
			window = modal
			suppress = $$TRUE
			swindow = window[window].swindow
			sdisplay = window[window].sdisplay
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			XSetInputFocus (sdisplay, swindow, $$RevertToParent, 0)
			XSync (sdisplay, $$FALSE)
			XBell (sdisplay, 0)
			##LOCKOUT = $$FALSE
			##WHOMASK = whomask
			flushTime = eventTime
'			PRINT "EventFocusIn().B : "; HEX$(who,8);; HEX$(window,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; suppress
		END IF
	END IF
'
' select the window
'
	IFZ suppress THEN
		message = #WindowSelected
		v0 = 0
		v1 = 0
		v2 = 0
		v3 = 0
		r0 = 0
		r1 = window
		XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
'		PRINT "EventFocusIn().C : "; HEX$(who,8);; HEX$(window,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; suppress
	END IF
END FUNCTION
'
'
' ##############################
' #####  EventFocusOut ()  #####
' ##############################
'
' modal window can be deselected and loose keyboard focus
' if a window in another application is selected.
'
FUNCTION  EventFocusOut (XFocusChangeEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  debug
'
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventFocusIn() : invalid window #"; window, top
		RETURN ($$TRUE)
	END IF
'
	IF (window != top) THEN
		IF InvalidWindow (top) THEN
			##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
			IF debug THEN PRINT "EventFocusIn() : invalid top window #"; window, top
			RETURN ($$TRUE)
		END IF
	END IF
'
	window = top
	display = window[window].display
	display[display].selectedWindow = 0
'
	who = window[window].whomask
	IF who THEN modal = modalWindowUser ELSE modal = modalWindowSystem
'
	message = #WindowDeselected
	v0 = 0
	v1 = 0
	v2 = 0
	v3 = 0
	r0 = 0
	r1 = window
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
'
'	PRINT "EventFocusOut().A : "; HEX$(who,8);; HEX$(window,8);; HEX$(modal,8);; HEX$(modalWindowSystem,8);; HEX$(modalWindowUser,8);; suppress
'
' to try to prevent loss of focus is to try to prevent
' other applications from being able to get keystrokes.
'
'	IF modal THEN
'		IF (window != modal) THEN
'			window = modal
'			swindow = window[window].swindow
'			sdisplay = window[window].sdisplay
'			##WHOMASK = 0
'			##LOCKOUT = $$TRUE
'			XSetInputFocus (sdisplay, swindow, $$RevertToParent, 0)
'			XSync (sdisplay, $$FALSE)
'			XBell (sdisplay, 0)
'			##LOCKOUT = $$FALSE
'			##WHOMASK = whomask
'			flushTime = eventTime
'		END IF
'	END IF
END FUNCTION
'
'
' ####################################
' #####  EventGraphicsExpose ()  #####
' ####################################
'
FUNCTION  EventGraphicsExpose (XGraphicsExposeEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventGraphicsExpose() : no action or message"
END FUNCTION
'
'
' ###################################
' #####  EventGravityNotify ()  #####
' ###################################
'
FUNCTION  EventGravityNotify (XGravityEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventGravityNotify() : no action or message"
END FUNCTION
'
'
' ##############################
' #####  EventKeyPress ()  #####
' ##############################
'
FUNCTION  EventKeyPress (XKeyEvent event)
	SHARED  WINDOW  window[]
	SHARED  modalWindowSystem
	SHARED  modalWindowUser
	SHARED  eventTime
	SHARED  debug
	AUTOX  keysym
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	eventTime = event.time
	sstate = event.state
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventKeyPress() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	window = top
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventKeyPress() : invalid top window #"
		RETURN ($$TRUE)
	END IF
'
	who = window[window].whomask
	IF who THEN modal = modalWindowUser ELSE modal = modalWindowSystem
'
	IF modal THEN window = modal
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	buffer$ = NULL$ (63)
	XLookupString (&event, &buffer, 63, &keysym, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ keysym THEN RETURN ($$FALSE)			' unrecognized keystroke
'
	SystemKeyStateToKeyState (#WindowKeyDown, keysym, sstate, event.time, @state)
'
	message = #WindowKeyDown
	v0 = event.x
	v1 = event.y
	v2 = state
	v3 = event.time
	r0 = 0
	r1 = window
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
END FUNCTION
'
'
' ################################
' #####  EventKeyRelease ()  #####
' ################################
'
FUNCTION  EventKeyRelease (XKeyEvent event)
	SHARED  WINDOW  window[]
	SHARED  modalWindowSystem
	SHARED  modalWindowUser
	SHARED  eventTime
	SHARED  debug
	AUTOX  keysym
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	eventTime = event.time
	sstate = event.state
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventKeyRelease() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	window = top
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventKeyRelease() : invalid top window #"
		RETURN ($$TRUE)
	END IF
'
	who = window[window].whomask
	IF who THEN modal = modalWindowUser ELSE modal = modalWindowSystem
'
	IF modal THEN window = modal
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	buffer$ = NULL$ (63)
	XLookupString (&event, &buffer, 63, &keysym, 0)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ keysym THEN RETURN ($$FALSE)			' unrecognized keystroke
'
	SystemKeyStateToKeyState (#WindowKeyUp, keysym, sstate, event.time, @state)
'
	message = #WindowKeyUp
	v0 = event.x
	v1 = event.y
	v2 = state
	v3 = event.time
	r0 = 0
	r1 = window
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
END FUNCTION
'
'
' ##################################
' #####  EventKeymapNotify ()  #####
' ##################################
'
FUNCTION  EventKeymapNotify (XKeymapEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventKeymapNotify() : no action or message"
END FUNCTION
'
'
' #################################
' #####  EventLeaveNotify ()  #####
' #################################
'
FUNCTION  EventLeaveNotify (XCrossingEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  debug
'
	eventTime = event.time
	subwindow = event.subwindow
	IF subwindow THEN RETURN									' skip parents
'
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
	grid = window
	window = top
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventLeaveNotify() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IF InvalidGrid (grid) THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventLeaveNotify() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	stop = window[window].stop
	display = window[window].display
	sdisplay = window[window].sdisplay
'
	SystemButtonStateToButtonState (0, event.state, event.time, @state)
'
	message = #WindowMouseExit
	v0 = event.x
	v1 = event.y
	v2 = state
	v3 = event.time
	r0 = 0
	r1 = grid
'
' always remember last mouse event added to queue
'
	display[display].mouseX = v0
	display[display].mouseY = v1
	display[display].mouseState = v2
	display[display].mouseTime = v3
	display[display].mouseGrid = grid
	display[display].mouseWindow = window
	display[display].mouseMessage = message
	display[display].mouseFocusGrid = grid
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
END FUNCTION
'
'
' ###############################
' #####  EventMapNotify ()  #####
' ###############################
'
FUNCTION  EventMapNotify (XMapEvent event)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IF (window != top) THEN RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventMapNotify() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	request = window[window].visibilityRequest
	window[window].visibilityRequest = -1
	window[window].mapped = $$TRUE
	message = #WindowDisplayed
	state = $$WindowDisplayed
'
	IF (request = $$WindowMaximized) THEN
		message = #WindowMaximized
		state = $$WindowMaximized
	END IF
'
	state = $$WindowDisplayed							' !!!!!!
	message = #WindowDisplayed						' !!!!!!
'
	window[window].visibility = state
'
	v0 = 0
	v1 = 0
	v2 = 0
	v3 = 0
	r0 = 0
	r1 = window
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
END FUNCTION
'
'
' ################################
' #####  EventMapRequest ()  #####
' ################################
'
FUNCTION  EventMapRequest (XMapRequestEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventMapRequest() : no action or message"
END FUNCTION
'
'
' ###################################
' #####  EventMappingNotify ()  #####
' ###################################
'
FUNCTION  EventMappingNotify (XMappingEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventMappingNotify() : no action or message"
END FUNCTION
'
'
' ##################################
' #####  EventMotionNotify ()  #####
' ##################################
'
' generate #WindowMouseMove or #WindowMouseDrag only if window owner queue is empty
'
FUNCTION  EventMotionNotify (XMotionEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  MESSAGE  message[]
	SHARED  eventTime
	SHARED  userCount
	SHARED  sysCount
	SHARED  userOut
	SHARED  sysOut
	SHARED  userIn
	SHARED  sysIn
	SHARED  inQueue
	SHARED  debug
'
	eventTime = event.time
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
	grid = window
	window = top
'
	IFZ window THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventMotionNotify() : invalid window #"; window
		RETURN ($$TRUE)
	END IF
'
	IFZ grid THEN
		##ERROR = ($$ErrorObjectGrid << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventMotionNotify() : invalid grid #"; grid
		RETURN ($$TRUE)
	END IF
'
	stop = window[window].stop
	display = window[window].display
	sdisplay = window[window].sdisplay
'
	mouseX = display[display].mouseX
	mouseY = display[display].mouseY
	mouseState = display[display].mouseState
	mouseTime = display[display].mouseTime
'
	SystemButtonStateToButtonState (0, event.state, event.time, @state)
'	PRINT "EventMotionNotify() : "; HEX$(event.state,8);; HEX$(state,8);;
'
	change = $$FALSE
	eventButtons = state AND $$MouseButtonMask
	mouseButtons = mouseState AND $$MouseButtonMask
	IF (mouseX != event.x) THEN change = $$TRUE
	IF (mouseY != event.y) THEN change = $$TRUE
	IF (mouseButtons != eventButtons) THEN change = $$TRUE
'
'	PRINT HEX$(eventButtons,8);; HEX$(mouseButtons,8)
'
	IFZ change THEN
'		PRINT "EventMotionNotify() : no change"
		RETURN ($$FALSE)
	END IF
'
	queue = 0																		' system queue
	IF window[window].whomask THEN queue = 1		' user queue
	GOSUB UpdateVariables												' queue state
'
	IF count THEN																' queue not empty
		IFZ eventButtons THEN											' no buttons down
			x = message[queue,out].r1
			g = message[queue,out].wingrid
			mess = message[queue,out].message
			XgrMessageNumberToName (mess, @mess$)
'			PRINT "EventMotionNotify() : trash motion event because queue is not empty : "; queue;; count;; out;; in;; g;; mess$;; x
			RETURN ($$FALSE)
		END IF
	END IF
'
	message = #WindowMouseMove
	IF eventButtons THEN message = #WindowMouseDrag
	v0 = event.x
	v1 = event.y
	v2 = state
	v3 = event.time
	r0 = 0
	r1 = grid
'
' remember last mouse event added to queue
'
	display[display].mouseX = v0
	display[display].mouseY = v1
	display[display].mouseState = v2
	display[display].mouseTime = v3
	display[display].mouseGrid = grid
	display[display].mouseWindow = window
	display[display].mouseMessage = message
	display[display].mouseFocusGrid = grid
'
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
	RETURN ($$FALSE)
'
'
' *****  UpdateVariables  *****
'
SUB UpdateVariables
	IF inQueue THEN PRINT "EventMotionNotify() : inQueue"
	inQueue = $$TRUE
	IF queue THEN
		count = userCount
		out = userOut
		in = userIn
	ELSE
		count = sysCount
		out = sysOut
		in = sysIn
	END IF
	inQueue = $$FALSE
END SUB
END FUNCTION
'
'
' ##############################
' #####  EventNoExpose ()  #####
' ##############################
'
FUNCTION  EventNoExpose (XNoExposeEvent event)
	SHARED  debug
'
'	IF debug THEN PRINT "EventNoExpose() : no action or message"
END FUNCTION
'
'
' ####################################
' #####  EventPropertyNotify ()  #####
' ####################################
'
FUNCTION  EventPropertyNotify (XPropertyEvent event)
	SHARED  WINDOW  window[]
	SHARED  eventTime
	SHARED  debug
'
	eventTime = event.time
	IF debug THEN PRINT "EventPropertyNotify() : no action or message"
END FUNCTION
'
'
' ####################################
' #####  EventReparentNotify ()  #####
' ####################################
'
FUNCTION  EventReparentNotify (XReparentEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	XWindowAttributes  windowAttributes
	XWindowAttributes  parentAttributes
	AUTOX  rp, xp, yp, wp, hp, bp, dp
	AUTOX  rw, xw, yw, ww, hw, bw, dw
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	dx = event.x
	dy = event.y
	sparent = event.parent
	swindow = event.window
	sdisplay = event.display
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IFZ window THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventReparentNotify() : invalid window"
		RETURN ($$TRUE)
	END IF
'
	display = window[window].display
	sroot = window[window].sroot									' system root window #
'
	IF (sroot = sparent) THEN
'		a$ = HEX$(sdisplay,8) + " " + HEX$(swindow,8) + " " + HEX$(sparent,8) + " " + HEX$(sroot,8) + " " + HEX$(rw,8) + " " + HEX$(rp,8) + "\n"
'		b$ = HEX$(dx,4) + " " + HEX$(dy,4) + " " + HEX$(window[window].x,4) + " " + HEX$(window[window].y,4) + "\n"
'		write (1, &a$, LEN(a$))
'		write (1, &b$, LEN(b$))
		RETURN ($$FALSE)		' ignore root reparent
	END IF
'
	window[window].sparent = sparent		' system parent #
	x = window[window].x								' requested x
	y = window[window].y								' requested y
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XGetGeometry (sdisplay, swindow, &rw, &xw, &yw, &ww, &hw, &bw, &dw)
	XGetGeometry (sdisplay, sparent, &rp, &xp, &yp, &wp, &hp, &bp, &dp)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	borderWidth = xp
	titleHeight = yp - xp
'
	log = $$FALSE
'
	IF log THEN
		a$ = "event      : " + HEX$(display,8) + " " + HEX$(window,8) + " " + HEX$(sdisplay,8) + " " + HEX$(swindow,8) + " " + HEX$(sparent,8) + " " + HEX$(rw,8) + " " + HEX$(rp,8) + " " + HEX$(dx,4) + " " + HEX$(dy,4) + "\n"
		b$ = "geometry w : " + HEX$(xw,4) + " " + HEX$(yw,4) + " " + HEX$(ww,4) + " " + HEX$(hw,4) + " " + HEX$(bw,4) + " " + HEX$(dw,4) + "\n"
		c$ = "geometry p : " + HEX$(xp,4) + " " + HEX$(yp,4) + " " + HEX$(wp,4) + " " + HEX$(hp,4) + " " + HEX$(bp,4) + " " + HEX$(dp,4) + "\n"
		d$ = "calculate  : " + HEX$(x,4)  + " " + HEX$(y,4)  + " " + HEX$(moveX,4) + " " + HEX$(moveY,4) + " " + HEX$(borderWidth,4) + " " + HEX$(titleHeight,4) + " " + HEX$(#windowBorderWidth,4) + " " + HEX$(#windowTitleHeight,4) +  "\n"
'
		XstLog (@a$)
		XstLog (@b$)
		XstLog (@c$)
		XstLog (@d$)
'
'		write (1, &a$, LEN(a$))
'		write (1, &b$, LEN(b$))
'		write (1, &c$, LEN(c$))
'		write (1, &d$, LEN(d$))
	END IF
'
' the following total cop-out prevents DISASTER under some window managers
'
	IF ((borderWidth < 2) OR (borderWidth > 8)) THEN borderWidth = 4
	IF ((titleHeight < 6) OR (titleHeight > 32)) THEN titleHeight = 19
'
	window[window].borderWidth = borderWidth
	window[window].titleHeight = titleHeight
	IF xp THEN display[display].borderWidth = borderWidth : #windowBorderWidth = borderWidth
	IF yp THEN display[display].titleHeight = titleHeight : #windowTitleHeight = titleHeight
'
	moveX = x - borderWidth
	moveY = y - borderWidth - titleHeight
	IF (moveX < 0) THEN moveX = 0
	IF (moveY < 0) THEN moveY = 0
'
	IF log THEN
		a$ = "event      = " + HEX$(display,8) + " " + HEX$(window,8) + " " + HEX$(sdisplay,8) + " " + HEX$(swindow,8) + " " + HEX$(sparent,8) + " " + HEX$(rw,8) + " " + HEX$(rp,8) + " " + HEX$(dx,4) + " " + HEX$(dy,4) + "\n"
		b$ = "geometry w = " + HEX$(xw,4) + " " + HEX$(yw,4) + " " + HEX$(ww,4) + " " + HEX$(hw,4) + " " + HEX$(bw,4) + " " + HEX$(dw,4) + "\n"
		c$ = "geometry p = " + HEX$(xp,4) + " " + HEX$(yp,4) + " " + HEX$(wp,4) + " " + HEX$(hp,4) + " " + HEX$(bp,4) + " " + HEX$(dp,4) + "\n"
		d$ = "calculate  = " + HEX$(x,4)  + " " + HEX$(y,4)  + " " + HEX$(moveX,4) + " " + HEX$(moveY,4) + " " + HEX$(borderWidth,4) + " " + HEX$(titleHeight,4) + " " + HEX$(#windowBorderWidth,4) + " " + HEX$(#windowTitleHeight,4) +  "\n"
'
		XstLog (@a$)
		XstLog (@b$)
		XstLog (@c$)
		XstLog (@d$)
'
'		write (1, &a$, LEN(a$))
'		write (1, &b$, LEN(b$))
'		write (1, &c$, LEN(c$))
'		write (1, &d$, LEN(d$))
	END IF
'
'
' The following works with KDE and GNOME and RedHat61 on 2000/02/12.
' The following empirically determined pile of crap difference is
' necessary because window managers do not play by the same rules.
'
	IF ((dx == 0) OR (dy == 0)) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XMoveWindow (sdisplay, swindow, x, y)
		DispatchEvents ($$TRUE, $$FALSE)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	ELSE
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		XMoveWindow (sdisplay, swindow, moveX, moveY)
		DispatchEvents ($$TRUE, $$FALSE)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ###################################
' #####  EventResizeRequest ()  #####
' ###################################
'
FUNCTION  EventResizeRequest (XResizeRequestEvent event)
	SHARED  debug
'
	IF debug THEN PRINT "EventResizeRequest() : no action or message"
END FUNCTION
'
'
' ####################################
' #####  EventSelectionClear ()  #####
' ####################################
'
FUNCTION  EventSelectionClear (XSelectionClearEvent event)
	SHARED  WINDOW  window[]
	SHARED  debug
	SHARED  eventTime
'
	eventTime = event.time
	IF debug THEN PRINT "EventSelectionClear() : no action or message"
END FUNCTION
'
'
' #####################################
' #####  EventSelectionNotify ()  #####
' #####################################
'
FUNCTION  EventSelectionNotify (XSelectionEvent event)
	SHARED  WINDOW  window[]
	SHARED  debug
	SHARED  eventTime
	SHARED  XSelectionEvent  selectionNotify
'
	eventTime = event.time
	selectionNotify = event
'
'	PRINT "EventSelectionNotify()"
'	PRINT "#sdisplayEternal  = "; HEX$(#sdisplayEternal,8)
'	PRINT "#swindowEternal   = "; HEX$(#swindowEternal,8)
'	PRINT "event.type        = "; HEX$(event.type,8);;			HEX$($$SelectionNotify,8)
'	PRINT "event.serial      = "; HEX$(event.serial,8)
'	PRINT "event.sendEvent   = "; HEX$(event.sendEvent,8)
'	PRINT "event.display     = "; HEX$(event.display,8)
'	PRINT "event.requestor   = "; HEX$(event.requestor,8)
'	PRINT "event.selection   = "; HEX$(event.selection,8)
'	PRINT "event.target      = "; HEX$(event.target,8)
'	PRINT "event.property    = "; HEX$(event.property,8)
'	PRINT "event.time        = "; HEX$(event.time,8)
END FUNCTION
'
'
' ######################################
' #####  EventSelectionRequest ()  #####
' ######################################
'
FUNCTION  EventSelectionRequest (XSelectionRequestEvent event)
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  UBYTE  clipData[]
	SHARED  clipText$[]
	SHARED	clipType[]
	SHARED  eventTime
	SHARED  debug
	XSelectionEvent  notify
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ clipType[] THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		DIM clipType[7]
		DIM clipText$[7]
		DIM clipData[7,]
		##LOCKOUT = lockout
		##WHOMASK = whomask
'
		FOR i = 0 TO 7
			clipType[i] = $$ClipboardTypeNone				' no contents
		NEXT i
	END IF
'
'	PRINT "EventSelectionRequest() : "; HEX$(event.display,8);; HEX$(event.owner,8);; HEX$(event.requestor,8);; HEX$(event.selection,8);; HEX$(event.target,8);; HEX$(event.property,8)
'
	eventTime = event.time
	selection = event.selection				' should be #XA_PRIMARY
	swindow = event.requestor
	sdisplay = event.display
	target = event.target							' type of data wanted : #XA_DIB, #XA_STRING, #XA_PIXMAP
'
	IFZ clipType[] THEN RETURN				' no clipboards defined
	clipType = clipType[0]						' does interapplication clipboard have text and/or data ?
	IFZ clipType THEN RETURN					' clipboard has no text and no data
'
	SELECT CASE target
		CASE #XA_DIB			: GOSUB dib						' DIB aka "device independent bitmap" image
		CASE #XA_STRING		: GOSUB text					' text string
		CASE ELSE					: GOSUB unsupported		' unsupported type
	END SELECT
	RETURN
'
SUB dib
	notify.type = $$SelectionNotify			' event type = SelectionNotify
	notify.serial = event.serial				' from incoming SelectionRequest event
	notify.sendEvent = 1								' gonna XSendEvent() this event to requestor
	notify.display = event.display			' return display of requestor SelectionRequest event
	notify.requestor = event.requestor	' return requestor from requestor SelectionRequest event
	notify.selection = event.selection	' return selection from requestor SelectionRequest event
	notify.target = event.target				' return target type from requestor SelectionRequest event
	notify.property = $$FALSE						' unsupported type - cannot supply data as requested type
	notify.time = eventTime							' return event time from requestor SelectionRequest event
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSendEvent (sdisplay, swindow, 1, 0, &notify)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END SUB
'
SUB text
	notify.type = $$SelectionNotify			' event type = SelectionNotify
	notify.serial = event.serial				' from incoming SelectionRequest event
	notify.sendEvent = 1								' gonna XSendEvent() this event to requestor
	notify.display = event.display			' return display of requestor SelectionRequest event
	notify.requestor = event.requestor	' return requestor from requestor SelectionRequest event
	notify.selection = event.selection	' return selection from requestor SelectionRequest event
	notify.target = event.target				' return target type from requestor SelectionRequest event
	notify.property = event.property		' return target property from requestor SelectRequest event
	notify.time = event.time						' return event time from requestor SelectionRequest event
'
	sdisplay = event.display
	swindow = event.requestor
	property = event.property
	format = 8
	mode = $$PropModeReplace
	text = &clipText$[0]
	length = LEN(clipText$[0])
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	a = XChangeProperty (sdisplay, swindow, property, #XA_STRING, format, mode, text, length)
	b = XSendEvent (sdisplay, swindow, 0, 0, &notify)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
'	PRINT "EventSelectionRequest()"
'	PRINT "#sdisplayEternal  = "; HEX$(#sdisplayEternal,8)
'	PRINT "#swindowEternal   = "; HEX$(#swindowEternal,8)
'	PRINT "event.type        = "; HEX$(event.type,8);;				HEX$(notify.type,8);;		HEX$($$SelectionRequest,8)
'	PRINT "event.serial      = "; HEX$(event.serial,8);;			HEX$(notify.serial,8)
'	PRINT "event.sendEvent   = "; HEX$(event.sendEvent,8);;		HEX$(notify.sendEvent,8)
'	PRINT "event.display     = "; HEX$(event.display,8);;			HEX$(notify.display,8)
'	PRINT "event.owner       = "; HEX$(event.owner,8)
'	PRINT "event.requestor   = "; HEX$(event.requestor,8);;		HEX$(notify.requestor,8)
'	PRINT "event.selection   = "; HEX$(event.selection,8);;		HEX$(notify.selection,8)
'	PRINT "event.target      = "; HEX$(event.target,8);;			HEX$(notify.target,8)
'	PRINT "event.property    = "; HEX$(event.property,8);;		HEX$(notify.property,8)
'	PRINT "event.time        = "; HEX$(event.time,8);;				HEX$(notify.time,8)
'	PRINT "sdisplay          = "; HEX$(sdisplay,8);; 					"XChangeProperty ( arg 1 )
'	PRINT "swindow           = "; HEX$(swindow,8);;						"XChangeProperty ( arg 2 )
'	PRINT "#XA_PRIMARY       = "; HEX$(#XA_PRIMARY,8);;				"XChangeProperty ( arg 3 )
'	PRINT "#XA_STRING        = "; HEX$(#XA_STRING,8);;				"XChangeProperty ( arg 4 )
'	PRINT "format            = "; HEX$(format,8);;						"XChangeProperty ( arg 5 )
'	PRINT "mode              = "; HEX$(mode,8);;							"XChangeProperty ( arg 6 )
'	PRINT "data aka &text$   = "; HEX$(text,8);;							"XChangeProperty ( arg 7 )
'	PRINT "elements          = "; HEX$(length,8);;						"XChangeProperty ( arg 8 )
'	PRINT "EventSelectionRequest() : "; HEX$(sdisplay,8);; HEX$(#swindowEternal,8);; HEX$(swindow,8);; #XA_PRIMARY;; #XA_STRING;; 8;; mode;; HEX$(&text$,8);; length;; a;; b
'	PRINT "("; CSTRING$ (text); ")"
'	addr = XGetAtomName (sdisplay, event.property)
'	atom$ = CSTRING$ (addr)
'	PRINT ":"; atom$; ":"
'	XFree (addr)
END SUB
'
SUB unsupported
	notify.type = $$SelectionNotify			' event type = SelectionNotify
	notify.serial = event.serial				' from incoming SelectionRequest event
	notify.sendEvent = 1								' gonna XSendEvent() this event to requestor
	notify.display = event.display			' return display of requestor SelectionRequest event
	notify.requestor = event.requestor	' return requestor from requestor SelectionRequest event
	notify.selection = event.selection	' return selection from requestor SelectionRequest event
	notify.target = event.target				' return target type from requestor SelectionRequest event
	notify.property = $$FALSE						' unsupported type - cannot supply data as requested type
	notify.time = event.time						' return event time from requestor SelectionRequest event
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XSendEvent (sdisplay, swindow, 1, 0, &notify)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' #################################
' #####  EventUnmapNotify ()  #####
' #################################
'
FUNCTION  EventUnmapNotify (XUnmapEvent event)
	SHARED  WINDOW  window[]
	SHARED  debug
'
	swindow = event.window
	IF XgrSystemWindowToWindow (swindow, @window, @top) THEN RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN
		##ERROR = ($$ErrorObjectWindow << 8) OR $$ErrorNatureNonexistent
		IF debug THEN PRINT "EventUnmapNotify() : invalid window #"; window;;; HEX$(swindow)
		RETURN ($$TRUE)
	END IF
'
	IF (window != top) THEN RETURN							' for windows, not grids
'
	request = window[window].visibilityRequest
	window[window].visibilityRequest = -1
	window[window].mapped = $$FALSE
	message = #WindowHidden
	state = $$WindowHidden
'
	IF (request = $$WindowMinimized) THEN
		message = #WindowMinimized
		state = $$WindowMinimized
	END IF
'
	state = $$WindowHidden							' !!!!!!!
	message = #WindowHidden							' !!!!!!!
'
	window[window].visibility = state
'
' send message to windows, not grids
'
	v0 = 0
	v1 = 0
	v2 = 0
	v3 = 0
	r0 = 0
	r1 = window
	XgrAddMessage (window, message, v0, v1, v2, v3, r0, r1)
END FUNCTION
'
'
' ######################################
' #####  EventVisibilityNotify ()  #####
' ######################################
'
FUNCTION  EventVisibilityNotify (XVisibilityEvent event)
	SHARED  debug
'
'	IF debug THEN PRINT "EventVisibilityNotify() : no action or message"
END FUNCTION
'
'
' ###################################
' #####  PrintWindowAttributes  #####
' ###################################
'
FUNCTION  PrintWindowAttributes (XWindowAttributes attr)
'
	PRINT "    .x      .y           = "; HEX$(attr.x, 8);; HEX$ (attr.y, 8)
	PRINT "    .width  .height      = "; HEX$(attr.width,8);; HEX$(attr.height,8)
	PRINT "    .borderWidth         = "; HEX$(attr.borderWidth, 8)
	PRINT "    .depth               = "; HEX$(attr.depth,  8)
	PRINT "    .visual              = "; HEX$(attr.visual, 8)
	PRINT "    .root                = "; HEX$(attr.root, 8)
	PRINT "    .class               = "; HEX$(attr.class, 8)
	PRINT "    .bitGravity          = "; HEX$(attr.bitGravity, 8)
	PRINT "    .winGravity          = "; HEX$(attr.winGravity, 8)
	PRINT "    .backingStore        = "; HEX$(attr.backingStore, 8)
	PRINT "    .backingPlanes       = "; HEX$(attr.backingPlanes, 8)
	PRINT "    .backingPixel        = "; HEX$(attr.backingPixel, 8)
	PRINT "    .saveUnder           = "; HEX$(attr.saveUnder, 8)
	PRINT "    .colormap            = "; HEX$(attr.colormap, 8)
	PRINT "    .mapInstalled        = "; HEX$(attr.mapInstalled, 8)
	PRINT "    .mapState            = "; HEX$(attr.mapState, 8)
	PRINT "    .allEventMasks       = "; HEX$(attr.allEventMasks, 8)
	PRINT "    .yourEventMask       = "; HEX$(attr.yourEventMask, 8)
	PRINT "    .doNotPropagateMask  = "; HEX$(attr.doNotPropagateMask, 8)
	PRINT "    .overrideRedirect    = "; HEX$(attr.overrideRedirect, 8)
	PRINT "    .screen              = "; HEX$(attr.screen, 8)
END FUNCTION
'
'
' #################################
' #####  PrintButtonPress ()  #####
' #################################
'
FUNCTION  PrintButtonPress (XButtonEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.root);; HEX$(event.subwindow);; event.x; event.y;; HEX$(event.state);; HEX$(event.button)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".root                = "; HEX$ (event.root, 8)
	PRINT ".subwindow           = "; HEX$ (event.subwindow, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
	PRINT ".button              = "; HEX$ (event.button, 8)
	PRINT ".sameScreen          = "; HEX$ (event.sameScreen, 8)
END SUB
END FUNCTION
'
'
' ###################################
' #####  PrintButtonRelease ()  #####
' ###################################
'
FUNCTION  PrintButtonRelease (XButtonEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.root);; HEX$(event.subwindow);; event.x; event.y;; HEX$(event.state);; HEX$(event.button)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".root                = "; HEX$ (event.root, 8)
	PRINT ".subwindow           = "; HEX$ (event.subwindow, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
	PRINT ".button              = "; HEX$ (event.button, 8)
	PRINT ".sameScreen          = "; HEX$ (event.sameScreen, 8)
END SUB
END FUNCTION
'
'
' #####################################
' #####  PrintCirculateNotify ()  #####
' #####################################
'
FUNCTION  PrintCirculateNotify (XCirculateEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.event);; HEX$(event.window);; HEX$(event.place)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".event               = "; HEX$ (event.event, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".place               = "; HEX$ (event.place, 8)
END SUB
END FUNCTION
'
'
' ######################################
' #####  PrintCirculateRequest ()  #####
' ######################################
'
FUNCTION  PrintCirculateRequest (XCirculateRequestEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.parent);; HEX$(event.window);; HEX$(event.place)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".parent              = "; HEX$ (event.parent, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".place               = "; HEX$ (event.place, 8)
END SUB
END FUNCTION
'
'
' ###################################
' #####  PrintClientMessage ()  #####
' ###################################
'
FUNCTION  PrintClientMessage (XClientMessageEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.messageType);; HEX$(event.format);; HEX$(event.data[0]);; HEX$(event.data[1]);; HEX$(event.data[2]);; HEX$(event.data[3]);; HEX$(event.data[4])
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; "$$ClientMessage"
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".messageType         = "; HEX$ (event.messageType, 8)
	PRINT ".format              = "; HEX$ (event.format, 8)
	PRINT ".data[0]             = "; HEX$ (event.data[0], 8)
	PRINT ".data[1]             = "; HEX$ (event.data[1], 8)
	PRINT ".data[2]             = "; HEX$ (event.data[2], 8)
	PRINT ".data[3]             = "; HEX$ (event.data[3], 8)
	PRINT ".data[4]             = "; HEX$ (event.data[4], 8)
END SUB
END FUNCTION
'
'
' ####################################
' #####  PrintColormapNotify ()  #####
' ####################################
'
FUNCTION  PrintColormapNotify (XColormapEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.colormap);; HEX$(event.new);; HEX$(event.state)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".colormap            = "; HEX$ (event.colormap, 8)
	PRINT ".new                 = "; HEX$ (event.new, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
END SUB
END FUNCTION
'
'
' #####################################
' #####  PrintConfigureNotify ()  #####
' #####################################
'
FUNCTION  PrintConfigureNotify (XConfigureEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.event);; HEX$(event.window);; HEX$(event.x);; HEX$(event.y);; HEX$(event.width);; HEX$(event.height);; HEX$(event.borderWidth);; HEX$(event.above);; HEX$(event.overrideRedirect)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".event               = "; HEX$ (event.event, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".width               = "; HEX$ (event.width, 8)
	PRINT ".height              = "; HEX$ (event.height, 8)
	PRINT ".borderWidth         = "; HEX$ (event.borderWidth, 8)
	PRINT ".above               = "; HEX$ (event.above, 8)
	PRINT ".overrideRedirect    = "; HEX$ (event.overrideRedirect, 8)
END SUB
END FUNCTION
'
'
' ######################################
' #####  PrintConfigureRequest ()  #####
' ######################################
'
FUNCTION  PrintConfigureRequest (XConfigureRequestEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.parent);; HEX$(event.window);; HEX$(event.x);; HEX$(event.y);; HEX$(event.width);; HEX$(event.height);; HEX$(event.borderWidth);; HEX$(event.above);; HEX$(event.detail);; HEX$(event.valuemask)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".parent              = "; HEX$ (event.parent, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".width               = "; HEX$ (event.width, 8)
	PRINT ".height              = "; HEX$ (event.height, 8)
	PRINT ".borderWidth         = "; HEX$ (event.borderWidth, 8)
	PRINT ".above               = "; HEX$ (event.above, 8)
	PRINT ".detail              = "; HEX$ (event.detail, 8)
	PRINT ".valuemask           = "; HEX$ (event.valuemask, 8)
END SUB
END FUNCTION
'
'
' ##################################
' #####  PrintCreateNotify ()  #####
' ##################################
'
FUNCTION  PrintCreateNotify (XCreateWindowEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.parent);; HEX$(event.window);; HEX$(event.x);; HEX$(event.y);; HEX$(event.width);; HEX$(event.height);; HEX$(event.borderWidth);; HEX$(event.overrideRedirect)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".parent              = "; HEX$ (event.parent, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".width               = "; HEX$ (event.width, 8)
	PRINT ".height              = "; HEX$ (event.height, 8)
	PRINT ".borderWidth         = "; HEX$ (event.borderWidth, 8)
	PRINT ".overrideRedirect    = "; HEX$ (event.overrideRedirect, 8)
END SUB
END FUNCTION
'
'
' ###################################
' #####  PrintDestroyNotify ()  #####
' ###################################
'
FUNCTION  PrintDestroyNotify (XDestroyWindowEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.event);; HEX$(event.window)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".event               = "; HEX$ (event.event, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
END SUB
END FUNCTION
'
'
' #################################
' #####  PrintEnterNotify ()  #####
' #################################
'
FUNCTION  PrintEnterNotify (XCrossingEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.root);; HEX$(event.subwindow);; HEX$(event.time);;  HEX$(event.x);; HEX$(event.y);; HEX$(event.xRoot);; HEX$(event.yRoot);; HEX$(event.mode);; HEX$(event.detail);; HEX$(event.focus);; HEX$(event.state)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".root                = "; HEX$ (event.root, 8)
	PRINT ".subwindow           = "; HEX$ (event.subwindow, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".xRoot               = "; HEX$ (event.xRoot, 8)
	PRINT ".yRoot               = "; HEX$ (event.yRoot, 8)
	PRINT ".mode                = "; HEX$ (event.mode, 8)
	PRINT ".detail              = "; HEX$ (event.detail, 8)
	PRINT ".focus               = "; HEX$ (event.focus, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
END SUB
END FUNCTION
'
'
' ############################
' #####  PrintErrorX ()  #####
' ############################
'
FUNCTION  PrintErrorX (XErrorEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; HEX$(event.resourceid);; HEX$(event.errorCode);; HEX$(event.requestCode);; HEX$(event.minorCode)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".resourceid          = "; HEX$ (event.resourceid, 8)
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".errorCode           = "; HEX$ (event.errorCode, 8)
	PRINT ".requestCode         = "; HEX$ (event.requestCode, 8)
	PRINT ".minorCode           = "; HEX$ (event.minorCode, 8)
END SUB
END FUNCTION
'
'
' ############################
' #####  PrintExpose ()  #####
' ############################
'
FUNCTION  PrintExpose (XExposeEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.x);; HEX$(event.y);; HEX$(event.width);; HEX$(event.height);; HEX$(event.count)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".width               = "; HEX$ (event.width, 8)
	PRINT ".height              = "; HEX$ (event.height, 8)
	PRINT ".count               = "; HEX$ (event.count, 8)
END SUB
END FUNCTION
'
'
' #############################
' #####  PrintFocusIn ()  #####
' #############################
'
FUNCTION  PrintFocusIn (XFocusChangeEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.mode);; HEX$(event.detail)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".mode                = "; HEX$ (event.mode, 8)
	PRINT ".detail              = "; HEX$ (event.detail, 8)
END SUB
END FUNCTION
'
'
' ##############################
' #####  PrintFocusOut ()  #####
' ##############################
'
FUNCTION  PrintFocusOut (XFocusChangeEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.mode);; HEX$(event.detail)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".mode                = "; HEX$ (event.mode, 8)
	PRINT ".detail              = "; HEX$ (event.detail, 8)
END SUB
END FUNCTION
'
'
' ####################################
' #####  PrintGraphicsExpose ()  #####
' ####################################
'
FUNCTION  PrintGraphicsExpose (XGraphicsExposeEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.drawable);; HEX$(event.x);; HEX$(event.y);; HEX$(event.width);; HEX$(event.height);; HEX$(event.count);; HEX$(event.majorCode);; HEX$(event.minorCode)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".drawable            = "; HEX$ (event.drawable, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".width               = "; HEX$ (event.width, 8)
	PRINT ".height              = "; HEX$ (event.height, 8)
	PRINT ".count               = "; HEX$ (event.count, 8)
	PRINT ".majorCode           = "; HEX$ (event.majorCode, 8)
	PRINT ".minorCode           = "; HEX$ (event.minorCode, 8)
END SUB
END FUNCTION
'
'
' ###################################
' #####  PrintGravityNotify ()  #####
' ###################################
'
FUNCTION  PrintGravityNotify (XGravityEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.event);; HEX$(event.window);; HEX$(event.x);; HEX$(event.y)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".event               = "; HEX$ (event.event, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
END SUB
END FUNCTION
'
'
' ##############################
' #####  PrintKeyPress ()  #####
' ##############################
'
FUNCTION  PrintKeyPress (XKeyEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.root);; HEX$(event.subwindow);; HEX$(event.time);; HEX$(event.x);; HEX$(event.y);; HEX$(event.state);; HEX$(event.keycode)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".xRoot               = "; HEX$ (event.xRoot, 8)
	PRINT ".yRoot               = "; HEX$ (event.yRoot, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
	PRINT ".keycode             = "; HEX$ (event.keycode, 8)
	PRINT ".sameScreen          = "; HEX$ (event.sameScreen, 8)
END SUB
END FUNCTION
'
'
' ################################
' #####  PrintKeyRelease ()  #####
' ################################
'
FUNCTION  PrintKeyRelease (XKeyEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.root);; HEX$(event.subwindow);; HEX$(event.time);; HEX$(event.x);; HEX$(event.y);; HEX$(event.state);; HEX$(event.keycode)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".xRoot               = "; HEX$ (event.xRoot, 8)
	PRINT ".yRoot               = "; HEX$ (event.yRoot, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
	PRINT ".keycode             = "; HEX$ (event.keycode, 8)
	PRINT ".sameScreen          = "; HEX$ (event.sameScreen, 8)
END SUB
END FUNCTION
'
'
' ##################################
' #####  PrintKeymapNotify ()  #####
' ##################################
'
FUNCTION  PrintKeymapNotify (XKeymapEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.x);; HEX$(event.y);; HEX$(event.width);; HEX$(event.height);; HEX$(event.count)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".width               = "; HEX$ (event.width, 8)
	PRINT ".height              = "; HEX$ (event.height, 8)
	PRINT ".count               = "; HEX$ (event.count, 8)
END SUB
END FUNCTION
'
'
' #################################
' #####  PrintLeaveNotify ()  #####
' #################################
'
FUNCTION  PrintLeaveNotify (XCrossingEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.root);; HEX$(event.subwindow);; HEX$(event.time);;  HEX$(event.x);; HEX$(event.y);; HEX$(event.xRoot);; HEX$(event.yRoot);; HEX$(event.mode);; HEX$(event.detail);; HEX$(event.focus);; HEX$(event.state)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".root                = "; HEX$ (event.root, 8)
	PRINT ".subwindow           = "; HEX$ (event.subwindow, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".xRoot               = "; HEX$ (event.xRoot, 8)
	PRINT ".yRoot               = "; HEX$ (event.yRoot, 8)
	PRINT ".mode                = "; HEX$ (event.mode, 8)
	PRINT ".detail              = "; HEX$ (event.detail, 8)
	PRINT ".focus               = "; HEX$ (event.focus, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
END SUB
END FUNCTION
'
'
' ###############################
' #####  PrintMapNotify ()  #####
' ###############################
'
FUNCTION  PrintMapNotify (XMapEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.event);; HEX$(event.window);; HEX$(event.overrideRedirect)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".event               = "; HEX$ (event.event, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".overrideRedirect    = "; HEX$ (event.overrideRedirect, 8)
END SUB
END FUNCTION
'
'
' ################################
' #####  PrintMapRequest ()  #####
' ################################
'
FUNCTION  PrintMapRequest (XMapRequestEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.parent);; HEX$(event.window)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".parent              = "; HEX$ (event.parent, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
END SUB
END FUNCTION
'
'
' ###################################
' #####  PrintMappingNotify ()  #####
' ###################################
'
FUNCTION  PrintMappingNotify (XMappingEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.request);; HEX$(event.firstKeycode);; HEX$(event.count)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".request             = "; HEX$ (event.request, 8)
	PRINT ".firstKeycode        = "; HEX$ (event.firstKeycode, 8)
	PRINT ".count               = "; HEX$ (event.count, 8)
END SUB
END FUNCTION
'
'
' ##################################
' #####  PrintMotionNotify ()  #####
' ##################################
'
FUNCTION  PrintMotionNotify (XMotionEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.root);; HEX$(event.subwindow);; HEX$(event.time);; HEX$(event.xRoot);; HEX$(event.yRoot);; HEX$(event.state);; HEX$(event.isHint)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".root                = "; HEX$ (event.root, 8)
	PRINT ".subwindow           = "; HEX$ (event.subwindow, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
	PRINT ".xRoot               = "; HEX$ (event.xRoot, 8)
	PRINT ".yRoot               = "; HEX$ (event.yRoot, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
	PRINT ".isHint              = "; HEX$ (event.isHint, 8)
	PRINT ".sameScreen          = "; HEX$ (event.sameScreen, 8)
END SUB
END FUNCTION
'
'
' ##############################
' #####  PrintNoExpose ()  #####
' ##############################
'
FUNCTION  PrintNoExpose (XNoExposeEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.drawable);; HEX$(event.majorOpcode);; HEX$(event.minorOpcode)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".drawable            = "; HEX$ (event.drawable, 8)
	PRINT ".majorOpcode         = "; HEX$ (event.majorOpcode, 8)
	PRINT ".minorOpcode         = "; HEX$ (event.minorOpcode, 8)
END SUB
END FUNCTION
'
'
' ####################################
' #####  PrintPropertyNotify ()  #####
' ####################################
'
FUNCTION  PrintPropertyNotify (XPropertyEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.atom);; HEX$(event.time);; HEX$(event.state)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".atom                = "; HEX$ (event.atom, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
END SUB
END FUNCTION
'
'
' ####################################
' #####  PrintReparentNotify ()  #####
' ####################################
'
FUNCTION  PrintReparentNotify (XReparentEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.event);; HEX$(event.window);; HEX$(event.parent);; HEX$(event.x);; HEX$(event.y);; HEX$(overrideRedirect)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".event               = "; HEX$ (event.event, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".parent              = "; HEX$ (event.parent, 8)
	PRINT ".x                   = "; HEX$ (event.x, 8)
	PRINT ".y                   = "; HEX$ (event.y, 8)
	PRINT ".overrideRedirect    = "; HEX$ (event.overrideRedirect, 8)
END SUB
END FUNCTION
'
'
' ###################################
' #####  PrintResizeRequest ()  #####
' ###################################
'
FUNCTION  PrintResizeRequest (XResizeRequestEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.width);; HEX$(event.height)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".width               = "; HEX$ (event.width, 8)
	PRINT ".height              = "; HEX$ (event.height, 8)
END SUB
END FUNCTION
'
'
' ####################################
' #####  PrintSelectionClear ()  #####
' ####################################
'
FUNCTION  PrintSelectionClear (XSelectionClearEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.atom);; HEX$(event.time)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".atom                = "; HEX$ (event.atom, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
END SUB
END FUNCTION
'
'
' #####################################
' #####  PrintSelectionNotify ()  #####
' #####################################
'
FUNCTION  PrintSelectionNotify (XSelectionEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.requestor);; HEX$(event.selection);; HEX$(event.target);; HEX$(event.property);; HEX$(event.time)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".requestor           = "; HEX$ (event.requestor, 8)
	PRINT ".selection           = "; HEX$ (event.selection, 8)
	PRINT ".target              = "; HEX$ (event.target, 8)
	PRINT ".property            = "; HEX$ (event.property, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
END SUB
END FUNCTION
'
'
' ######################################
' #####  PrintSelectionRequest ()  #####
' ######################################
'
FUNCTION  PrintSelectionRequest (XSelectionRequestEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.owner);; HEX$(event.requestor);; HEX$(event.selection);; HEX$(event.target);; HEX$(event.property);; HEX$(event.time)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".requestor           = "; HEX$ (event.requestor, 8)
	PRINT ".selection           = "; HEX$ (event.selection, 8)
	PRINT ".target              = "; HEX$ (event.target, 8)
	PRINT ".property            = "; HEX$ (event.property, 8)
	PRINT ".time                = "; HEX$ (event.time, 8)
END SUB
END FUNCTION
'
'
' #################################
' #####  PrintUnmapNotify ()  #####
' #################################
'
FUNCTION  PrintUnmapNotify (XUnmapEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.event);; HEX$(event.window);; HEX$(event.fromConfigure)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".event               = "; HEX$ (event.event, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".fromConfigure       = "; HEX$ (event.fromConfigure, 8)
END SUB
END FUNCTION
'
'
' #####################################
' #####  PrintVisibilityEvent ()  #####
' #####################################
'
FUNCTION  PrintVisibilityNotify (XVisibilityEvent event)
	SHARED	event$[]
	SHARED	debug
'
	SELECT CASE TRUE
		CASE (debug OR $$DebugBrief)		: GOSUB Brief
		CASE (debug OR $$DebugWordy)		: GOSUB Wordy
	END SELECT
	RETURN
'
SUB Brief
	PRINT event$[event.type]; event.type; event.sendEvent;; HEX$(event.window);; HEX$(event.state)
END SUB
'
SUB Wordy
	PRINT ".type                = "; HEX$ (event.type, 8);; event$[event.type]
	PRINT ".serial              = "; HEX$ (event.serial, 8)
	PRINT ".sendEvent           = "; HEX$ (event.sendEvent, 8)
	PRINT ".display             = "; HEX$ (event.display, 8)
	PRINT ".window              = "; HEX$ (event.window, 8)
	PRINT ".state               = "; HEX$ (event.state, 8)
END SUB
END FUNCTION
'
'
' ######################
' #####  JunkHeap  #####
' ######################
'
FUNCTION  JunkHeap ()
	SHARED  DISPLAY  display[]
	XColor  sc
'
'
' given display[], display, and colormap, the following routine displays
' all 256 colors in an 8-bit colormap.
'
	sdisplay = display[display].sdisplay
'
	FOR i = 0 TO 255
		sc.scolor = i
		XQueryColor (sdisplay, colormap, &sc)
		PRINT HEX$(i,2);; HEX$(sc.r,4);; HEX$(sc.g,4);; HEX$(sc.b,4)
		IF ((i AND 0x0F) = 0x0F) THEN a$ = INLINE$ ("press enter for 16 more")
	NEXT i
END FUNCTION
'
'
' ##############################
' #####  DefaultFontNames  #####
' ##############################
'
FUNCTION  DefaultFontNames (count, fontName$[])
	SHARED  DISPLAY  display[]
	SHARED  WINDOW  window[]
	SHARED  FONT  font[]
	AUTOX  fonts
'
	count = 0
	DIM fontName$[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	sdisplay = display[1].sdisplay			' default display
	filter$ = "-*-*-*-*-*-*-*-*-*-*-c-*-*-*"
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	addrFontList = XListFonts (sdisplay, &filter$, 4096, &fonts)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
'
	IFZ fonts THEN RETURN ($$FALSE)						' no fonts
	IFZ addrFontList THEN RETURN ($$FALSE)		' no fonts
'
	f = 0
	count = 0
	upper = fonts-1
	addr = addrFontList
'
	##WHOMASK = $$FALSE
	DIM fontName$[upper]
'
	DO
		INC f
		font = XLONGAT (addr)						' font = address of font name
		font$ = CSTRING$ (font)					' font$ = font name
		addr = addr + 4									' addr = address of next font name
		IF font$ THEN
			pos = 0
			FOR i = 1 TO 7
				pos = INSTR (font$, "-", pos+1)
				IFZ pos THEN EXIT FOR
			NEXT i
			IF pos THEN
				size = XLONG(MID$(font$,pos+1))
				IF ((size > 6) AND (size < 25)) THEN
					fontName$[count] = font$
					INC count
				END IF
			END IF
		END IF
	LOOP UNTIL (f >= fonts)
'
	top = count - 1
	IF (top != upper) THEN REDIM fontName$[top]
	##WHOMASK = whomask
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	XFreeFontNames (addrFontList)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
END FUNCTION
'
'* Reset all user-mode variables to their default value. This is called when
' a user-program is started in the PDE.
FUNCTION XgrResetUserMode()
	SHARED userCEO
	userCEO = 0
END FUNCTION
'
'* Retrieve the 'X11 display pointer
' @return	The X11 display pointer
FUNCTION XgrGetSystemDisplay()
	SHARED DISPLAY	display[]

	RETURN display[1].sdisplay
END FUNCTION
END PROGRAM
