'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  Windows XBasic GraphicsDesigner function library
'
' subject to LGPL license - see COPYING_LIB
'
' maxreason@maxreason.com
'
' for Windows XBasic
'
'
PROGRAM	"xgr"
VERSION	"0.0442"
'
IMPORT	"xst"
IMPORT	"xma"
IMPORT	"xlib"
IMPORT	"gdi32"
IMPORT	"user32"
IMPORT	"kernel32"
'
EXPORT
'
'
' **********************************************
' *****  GraphicsDesigner COMPOSITE TYPES  *****
' **********************************************
'
TYPE MESSAGE
	XLONG     .wingrid            ' window/grid number
	XLONG     .message            ' message number
	XLONG     .v0                 ' arguments
	XLONG     .v1
	XLONG     .v2
	XLONG     .v3
	XLONG     .r0
	XLONG     .r1
END TYPE
END EXPORT
'
'
' ***************************************
' *****  WindowsNT COMPOSITE TYPES  *****
' ***************************************
'
'	TYPE BOOL		= XLONG
'	TYPE HBRUSH	= XLONG
'	TYPE HDC		= XLONG
'	TYPE HPEN		= XLONG
'	TYPE HWND		= XLONG
'
'
TYPE MSG
	XLONG     .hwnd
	XLONG     .message
	XLONG     .wParam
	XLONG     .lParam
	XLONG     .time
	XLONG     .x
	XLONG     .y
END TYPE
'
TYPE DISPLAYINFO							' host display information
	XLONG 	.status							' 0 if not initialized
	USHORT	.displayWidth				' display width in pixels
	USHORT	.displayHeight			' display height in pixels
	USHORT	.borderWidth				' border width in pixels (4 sides)
	USHORT	.titleHeight				' title height in pixels (titleBar ONLY)
	XLONG		.selectedWindow			' currently selected Xgr window
	XLONG		.mouseWindowHwnd		' Xgr window handle
	XLONG		.mouseWindow				' Xgr window number (0 if not Xgr)
	XLONG		.mouseState					' current XBasic key/mouse state
	XLONG		.mouseXDisp					' current mouse xy in root coords
	XLONG		.mouseYDisp
	XLONG		.grabMouseFocusGrid	' grid with grabbed mouse focus (if any)
	XLONG		.gridMouseInside		' grid the mouse is inside
	XLONG		.reserved						' reserved
	XLONG		.a[3]								' reserved
END TYPE											' DISPLAYINFO contains 64 bytes
'
' *********************************
' *****  Xgr COMPOSITE TYPES  *****
' *********************************
'
TYPE FONTINFO									' 32 bytes
	XLONG		.font								' font number (0 = element unused)
	XLONG		.hFont							' system font handle
	XLONG		.sysFont						' system font family number
	USHORT	.size								' twips (20th of a point) - approx (.height - .internalLeading)
	USHORT	.weight							' 0 - 1000 by 100s
	SSHORT	.italic							' T/F
	USHORT	.angle							' 1/10 degrees tilt (0 - 3599)
	USHORT	.width							' max width of font character cell									(pixels)
	USHORT	.height							' ascent + descent																	(pixels)
	USHORT	.ascent							' height above baseline (includes internalLeading)	(pixels)
	USHORT	.descent						' height below baseline															(pixels)
	USHORT	.internalLeading		' height above character "top" (part of ascent)			(pixels)
	USHORT	.externalLeading		' height between lines
END TYPE
'
TYPE POINT										' 8 bytes
	XLONG		.x									' x position
	XLONG		.y									' y position
END TYPE
'
TYPE DPOINT										' 16 bytes
	DOUBLE	.x									' x# position
	DOUBLE	.y									' y# position
END TYPE
'
TYPE BOX											' 16 bytes
	XLONG		.x1									' x position of 1st corner
	XLONG		.y1									' y position of 1st corner
	XLONG		.x2									' x position of 2nd corner
	XLONG		.y2									' y position of 2nd corner
END TYPE
'
TYPE DBOX											' 32 bytes
	DOUBLE	.x1									' x# position of 1st corner
	DOUBLE	.y1									' y# position of 1st corner
	DOUBLE	.x2									' x# position of 2nd corner
	DOUBLE	.y2									' y# position of 2nd corner
END TYPE
'
TYPE WINDOWINFO								' WindowsNT information for window
	XLONG		.host								' hostDisplay[] index (0 = not used)
	XLONG		.windowType					' window type
	XLONG		.parent							' parent window
	XLONG		.hwnd								' window handle						(HWND)
	XLONG		.whomask						' creator's whomask
	XLONG		.hdc								' display context handle	(HDC)
	XLONG		.func								' function address for window messages
	XLONG		.xDisp							' xUL of window interior on display
	XLONG		.yDisp							' yUL of window interior on display
	XLONG		.width							' width of window interior
	XLONG		.height							' height of window interior
	XLONG		.icon								' icon
	XLONG		.font								' XBasic font ID
	UBYTE		.drawMode						' last drawMode used
	UBYTE		.lineWidth					' last lineWidth used
	UBYTE		.lineStyle					' last lineStyle used
	SBYTE		.visible						' hidden/displayed/min/max (0/1/2/3)
	SBYTE		.priorVisible
	SBYTE		.a[2]
	XLONG		.clipGrid						' last clipGrid used
	XLONG		.xClip							' XgrRedrawWindow: window clip box
	XLONG		.yClip
	XLONG		.clipWidth					' 0 = No window clip box
	XLONG		.clipHeight
	XLONG		.clipIsNull					' clip intersection is NULL
	XLONG		.winPixel						' current window pixel (for ClearWindow)
	XLONG		.bgPixel						' current background pixel
	XLONG		.fgBrushPixel				'   fg brush pixel
	XLONG		.fgBrush						'   fg brush handle (HBRUSH)
	XLONG		.fgPenPixel					'   fg pen   pixel
	XLONG		.fgPen							'   fg pen   handle (HPEN)
	XLONG		.textPixel					' current text pixel
	XLONG		.b[3]								' WINDOWINFO contains 128 bytes
END TYPE
'
TYPE GRIDINFO									' 256 bytes - one for every open grid
	XLONG		.grid								' grid number (0 if undefined)
	XLONG		.window							' window number this grid is attached to
	XLONG		.gridType						' grid type (0 = grid, 1 = image, 2...)
	XLONG		.parentGrid					' parentGrid (used in Redraw)
	XLONG		.bufferGrid					' buffer grid
	XLONG		.clipGrid						' grid number to clip to (0 = no clip)
	XLONG		.func								' function address
	XLONG		.font								' XBasic font number
	UBYTE		.res0								'
	UBYTE		.res1								'
	UBYTE		.res2								'
	SBYTE		.disabled						' from mouse events only (GuiDesigner)
	UBYTE		.drawMode						' COPY, XOR, AND, OR, etc...
	UBYTE		.lineWidth					' line width (1 = default)
	UBYTE		.lineStyle					' line style (0 = default = solid)
	UBYTE		.buttonClicks				'
	XLONG		.lastClickTime			'
	XLONG		.timeOutID					'
	XLONG		.lowColor						' 3D shadow color
	XLONG		.highColor					' 3D highlight color
	XLONG		.dullColor					' dull color
	XLONG		.accentColor				' accent color
	XLONG		.lowTextColor				' 3D text shadow color
	XLONG		.highTextColor			' 3D text highlight color		18 * XLONG
	USHORT	.backBlue						' blue intensity of current background color
	USHORT	.backGreen					' green intensity of current background color
	USHORT	.backRed						' red intensity of current background color
	USHORT	.backColor					' standard color of current background color
	USHORT	.drawBlue						' blue intensity of current drawing color
	USHORT	.drawGreen					' green intensity of current drawing color
	USHORT	.drawRed						' red intensity of current drawing color
	USHORT	.drawColor					' standard color of current drawing color  22 * XLONG
	POINT		.drawpoint					' current x,y drawpoint for local coords
	POINT		.drawpointGrid			' current x,y drawpoint for grid coords
	DPOINT	.drawpointScaled		' current x,y drawpoint for scaled coords
	BOX			.winBox							' corners of grid-box in window coords
	BOX			.gridBox						' corners of grid-box in grid coords
	DBOX		.gridBoxScaled			' corners of grid-box in scaled coords
	DOUBLE	.xScale							' x grid units equal to 1 scaled unit (signed)
	DOUBLE	.yScale							' y grid units equal to 1 scaled unit (signed)
	DOUBLE	.xInvScale					' x scaled units equal to 1 grid unit (signed)
	DOUBLE	.yInvScale					' y scaled units equal to 1 grid unit (signed)  54 * XLONG
	XLONG		.width							' current grid-box width
	XLONG		.height							' current grid-box height
	XLONG		.sysImage						' internal (system image handle--hBitmap--image grids)
	XLONG		.sysBackground			' internal (system color #)
	XLONG		.sysDrawing					' internal (system color #)
	XLONG		.borderOffsetLeft		'
	XLONG		.borderOffsetTop		'
	XLONG		.borderOffsetRight	'
	XLONG		.borderOffsetBottom	'
	UBYTE		.border							'
	UBYTE		.borderUp						'
	UBYTE		.borderDown					'
	UBYTE		.borderFlags				'
END TYPE
'
TYPE NTIMAGEINFO
	XLONG		.hdcImage						' hdc for image
	XLONG		.window							' last window used
	XLONG		.imageGrid					' last imageGrid used
	XLONG		.hBitmap						' current Bitmap
	XLONG		.defaultBitmap			' original Bitmap
	UBYTE		.drawMode						' last drawMode used
	UBYTE		.lineWidth					' last lineWidth used
	UBYTE		.lineStyle					' last lineStyle used
	UBYTE		.resByte						' unused
	XLONG		.font								' XBasic font ID
	XLONG		.bgPixel						' current background pixel
	XLONG		.fgBrushPixel				'   fg brush pixel
	XLONG		.fgBrush						'   fg brush handle (HBRUSH)
	XLONG		.fgPenPixel					'   fg pen   pixel
	XLONG		.fgPen							'   fg pen   handle (HPEN)
	XLONG		.textPixel					' current text pixel
	XLONG		.clipGrid						' last clipGrid used
	XLONG		.clipGridImage			' last clipGridImage used
	XLONG		.xClip							' window clip box used
	XLONG		.yClip
	XLONG		.clipWidth					' 0 = No window clip box
	XLONG		.clipHeight
	XLONG		.clipIsNull					' clip intersection is NULL
END TYPE
'
TYPE XGR_MESSAGE
	XLONG		.window							' Xgr window number (0 if not Xgr)
	MSG			.msg								' NT mouse message
END TYPE
'
'
' *****  data types for GIF format images  *****
'
TYPE GifHeader												' REQUIRED
	STRING*3 .signature
	STRING*3 .version
END TYPE
'
TYPE GifLogicalScreenDescriptor				' REQUIRED
	UBYTE    .widthLSB
	UBYTE    .widthMSB
	UBYTE    .heightLSB
	UBYTE    .heightMSB
	UBYTE    .bitfields
	UBYTE    .backgroundColorIndex
	UBYTE    .pixelAspectRatio
END TYPE
'
TYPE GifColorTableEntry								' global/local color tables are optional
	UBYTE    .r													' red
	UBYTE    .g													' green
	UBYTE    .b													' blue
END TYPE
'
TYPE GifDataBlockSize									' required if image has any data blocks
	UBYTE    .blockSize									' 0x00 blockSize means end of data
END TYPE
'
TYPE GifImageDescriptor								' required for images
	UBYTE    .imageSeparator
	UBYTE    .imageLeftPositionLSB
	UBYTE    .imageLeftPositionMSB
	UBYTE    .imageTopPositionLSB
	UBYTE    .imageTopPositionMSB
	UBYTE    .imageWidthLSB
	UBYTE    .imageWidthMSB
	UBYTE    .imageHeightLSB
	UBYTE    .imageHeightMSB
	UBYTE    .bitfields
END TYPE
'
TYPE GifTableBasedImageDataHeader			' required before 1st image block
	UBYTE    .minimumCodeSize
END TYPE
'
TYPE GifGraphicControlExtension				' OPTIONAL
	UBYTE    .extensionIntroducer
	UBYTE    .graphicControlLabel
	UBYTE    .blockSize
	UBYTE    .bitfields
	UBYTE    .delayTimeLSB
	UBYTE    .delayTImeMSB
	UBYTE    .transparentColorIndex
	UBYTE    .blockTerminator
END TYPE
'
TYPE GifCommentExtensionHeader				' OPTIONAL
	UBYTE    .extensionIntroducer
	UBYTE    .commentLabel
END TYPE
'
TYPE GifPlainTextExtensionHeader			' OPTIONAL
	UBYTE    .extensionIntroducer
	UBYTE    .plainTextLabel
	UBYTE    .blockSize
	UBYTE    .textGridLeftPositionLSB
	UBYTE    .textGridLeftPositionMSB
	UBYTE    .textGridWidthLSB
	UBYTE    .textGridWidthMSB
	UBYTE    .textGridHeightLSB
	UBYTE    .textGridHeightMSB
	UBYTE    .characterCellWidth
	UBYTE    .characterCellHeight
	UBYTE    .textForegroundColorIndex
	UBYTE    .textBackgroundColorIndex
END TYPE
'
TYPE GifApplicationExtensionHeader		' OPTIONAL
	UBYTE    .extensionIntroducer
	UBYTE    .extensionLabel
	UBYTE    .blockSize
	UBYTE    .applicationIdentifier0
	UBYTE    .applicationIdentifier1
	UBYTE    .applicationIdentifier2
	UBYTE    .applicationIdentifier3
	UBYTE    .applicationIdentifier4
	UBYTE    .applicationIdentifier5
	UBYTE    .applicationIdentifier6
	UBYTE    .applicationIdentifier7
	UBYTE    .applicationAuthenticationCode0
	UBYTE    .applicationAuthenticationCode1
	UBYTE    .applicationAuthenticationCode2
END TYPE
'
TYPE GifTrailer												' REQUIRED
	UBYTE    .gifTrailer
END TYPE
'
EXPORT
'
'
' ************************************************
' *****  GraphicsDesigner Library Functions  *****
' ************************************************
'
' Miscellaneous Functions
'
DECLARE FUNCTION  Xgr                          ()
DECLARE FUNCTION  XgrBorderNameToNumber        (border$, @border)
DECLARE FUNCTION  XgrBorderNumberToName        (border, @border$)
DECLARE FUNCTION  XgrBorderNumberToWidth       (border, @width)
DECLARE FUNCTION  XgrColorNameToNumber         (color$, @color)
DECLARE FUNCTION  XgrColorNumberToName         (color, @color$)
DECLARE FUNCTION  XgrCreateFont                (font, fontName$, fontSize, fontWeight, fontItalic, fontAngle)
DECLARE FUNCTION  XgrCursorNameToNumber        (cursorName$, @cursorNumber)
DECLARE FUNCTION  XgrCursorNumberToName        (cursorNumber, @cursorName$)
DECLARE FUNCTION  XgrDestroyFont               (font)
DECLARE FUNCTION  XgrGetClipboard              (clipboard, clipType, text$, UBYTE image[])
DECLARE FUNCTION  XgrGetCursor                 (cursor)
DECLARE FUNCTION  XgrGetCursorOverride         (cursor)
DECLARE FUNCTION  XgrGetDisplaySize            (display$, width, height, borderWidth, titleHeight)
DECLARE FUNCTION  XgrGetFontInfo               (font, fontName$, pointSize, weight, italic, angle)
DECLARE FUNCTION  XgrGetFontNames              (count, fontNames$[])
DECLARE FUNCTION  XgrGetFontMetrics            (font, maxCharWidth, maxCharHeight, ascent, descent, gap, flags)
DECLARE FUNCTION  XgrGetKeystateModify         (state, @modify, @edit)
DECLARE FUNCTION  XgrGetTextArrayImageSize     (font, @text$[], @w, @h, @width, @height, extraX, extraY)
DECLARE FUNCTION  XgrGetTextImageSize          (font, @text$, @dx, @dy, @width, @height, gap, space)
DECLARE FUNCTION  XgrGridToSystemWindow        (grid, @swindow, @dx, @dy, @width, @height)
DECLARE FUNCTION  XgrIconNameToNumber          (iconName$, iconNumber)
DECLARE FUNCTION  XgrIconNumberToName          (iconNumber, iconName$)
DECLARE FUNCTION  XgrRegisterCursor            (cursorName$, cursor)
DECLARE FUNCTION  XgrRegisterIcon              (iconName$, icon)
DECLARE FUNCTION  XgrSetClipboard              (clipboard, clipType, text$, UBYTE image[])
DECLARE FUNCTION  XgrSetCursor                 (cursor, oldCursor)
DECLARE FUNCTION  XgrSetCursorOverride         (cursor, oldCursorOverride)
DECLARE FUNCTION  XgrSystemWindowToWindow      (swindow, @window, @top)
DECLARE FUNCTION  XgrWindowToSystemWindow      (window, @swindow, @dx, @dy, @width, @height)
DECLARE FUNCTION  XgrVersion$                  ()
DECLARE FUNCTION  XgrResetUserMode             ()
'
' Color Functions
'
DECLARE FUNCTION  XgrConvertColorToRGB         (color, @red, @green, @blue)
DECLARE FUNCTION  XgrConvertRGBToColor         (red, green, blue, @color)
DECLARE FUNCTION  XgrGetBackgroundColor        (grid, @color)
DECLARE FUNCTION  XgrGetBackgroundRGB          (grid, @red, @green, @blue)
DECLARE FUNCTION  XgrGetDefaultColors          (back, @draw, @low, @high, @dull, @accent, @lowText, @highText)
DECLARE FUNCTION  XgrGetDrawingColor           (grid, @color)
DECLARE FUNCTION  XgrGetDrawingRGB             (grid, @red, @green, @blue)
DECLARE FUNCTION  XgrGetGridColors             (grid, @back, @draw, @low, @high, @dull, @accent, @lowText, @highText)
DECLARE FUNCTION  XgrSetBackgroundColor        (grid, color)
DECLARE FUNCTION  XgrSetBackgroundRGB          (grid, red, green, blue)
DECLARE FUNCTION  XgrSetDefaultColors          (back, draw, low, high, dull, acc, lowText, highText)
DECLARE FUNCTION  XgrSetDrawingColor           (grid, color)
DECLARE FUNCTION  XgrSetDrawingRGB             (grid, red, green, blue)
DECLARE FUNCTION  XgrSetGridColors             (grid, back, draw, low, high, dull, acc, lowText, highText)
'
' Window Functions
'
DECLARE FUNCTION  XgrClearWindow               (window, color)
DECLARE FUNCTION  XgrClearWindowAndImages      (window, color)
DECLARE FUNCTION  XgrCreateWindow              (window, windowType, xDisp, yDisp, width, height, winFunc, display$)
DECLARE FUNCTION  XgrDestroyWindow             (window)
DECLARE FUNCTION  XgrDisplayWindow             (window)
DECLARE FUNCTION  XgrGetModalWindow            (window)
DECLARE FUNCTION  XgrGetWindowDisplay          (window, @display$)
DECLARE FUNCTION  XgrGetWindowFunction         (window, @func)
DECLARE FUNCTION  XgrGetWindowGrid             (window, @grid)
DECLARE FUNCTION  XgrGetWindowIcon             (window, @icon)
DECLARE FUNCTION  XgrGetWindowPositionAndSize  (window, @xDisp, @yDisp, @width, @height)
DECLARE FUNCTION  XgrGetWindowState            (window, @state)
DECLARE FUNCTION  XgrGetWindowTitle            (window, @title$)
DECLARE FUNCTION  XgrHideWindow                (window)
DECLARE FUNCTION  XgrMaximizeWindow            (window)
DECLARE FUNCTION  XgrMinimizeWindow            (window)
DECLARE FUNCTION  XgrRestoreWindow             (window)
DECLARE FUNCTION  XgrSetModalWindow            (window)
DECLARE FUNCTION  XgrSetWindowFunction         (window, func)
DECLARE FUNCTION  XgrSetWindowIcon             (window, icon)
DECLARE FUNCTION  XgrSetWindowPositionAndSize  (window, xDisp, yDisp, width, height)
DECLARE FUNCTION  XgrSetWindowState            (window, state)
DECLARE FUNCTION  XgrSetWindowTitle            (window, title$)
DECLARE FUNCTION  XgrShowWindow                (window)
'
' Grid Functions
'
DECLARE FUNCTION  XgrClearGrid                 (grid, color)
DECLARE FUNCTION  XgrCloneGrid                 (grid, newGrid, newWindow, newParent, xWin, yWin)
DECLARE FUNCTION  XgrConvertDisplayToGrid      (grid, xDisp, yDisp, @xGrid, @yGrid)
DECLARE FUNCTION  XgrConvertDisplayToLocal     (grid, xDisp, yDisp, @x, @y)
DECLARE FUNCTION  XgrConvertDisplayToScaled    (grid, xDisp, yDisp, @x#, @y#)
DECLARE FUNCTION  XgrConvertDisplayToWindow    (grid, xDisp, yDisp, @xWin, @yWin)
DECLARE FUNCTION  XgrConvertGridToDisplay      (grid, xGrid, yGrid, @xDisp, @yDisp)
DECLARE FUNCTION  XgrConvertGridToLocal        (grid, xGrid, yGrid, @x, @y)
DECLARE FUNCTION  XgrConvertGridToScaled       (grid, xGrid, yGrid, @x#, @y#)
DECLARE FUNCTION  XgrConvertGridToWindow       (grid, xGrid, yGrid, @xWin, @yWin)
DECLARE FUNCTION  XgrConvertLocalToDisplay     (grid, xGrid, yGrid, @xDisp, @yDisp)
DECLARE FUNCTION  XgrConvertLocalToGrid        (grid, xGrid, yGrid, @x, @y)
DECLARE FUNCTION  XgrConvertLocalToScaled      (grid, xGrid, yGrid, @x#, @y#)
DECLARE FUNCTION  XgrConvertLocalToWindow      (grid, xGrid, yGrid, @xWin, @yWin)
DECLARE FUNCTION  XgrConvertScaledToDisplay    (grid, x#, y#, @xDisp, @yDisp)
DECLARE FUNCTION  XgrConvertScaledToGrid       (grid, x#, y#, @xGrid, @yGrid)
DECLARE FUNCTION  XgrConvertScaledToLocal      (grid, x#, y#, @x, @y)
DECLARE FUNCTION  XgrConvertScaledToWindow     (grid, x#, y#, @xWin, @yWin)
DECLARE FUNCTION  XgrConvertWindowToDisplay    (grid, xWin, yWin, @xDisp, @yDisp)
DECLARE FUNCTION  XgrConvertWindowToGrid       (grid, xWin, yWin, @xGrid, @yGrid)
DECLARE FUNCTION  XgrConvertWindowToLocal      (grid, xWin, yWin, @x, @y)
DECLARE FUNCTION  XgrConvertWindowToScaled     (grid, xWin, yWin, @x#, @y#)
DECLARE FUNCTION  XgrCreateGrid                (grid, gridType, x, y, width, height, window, parent, func)
DECLARE FUNCTION  XgrDestroyGrid               (grid)
DECLARE FUNCTION  XgrGetGridBorder             (grid, @border, @borderUp, @borderDown, @borderFlags)
DECLARE FUNCTION  XgrGetGridBorderOffset       (grid, @left, @top, @right, @bottom)
DECLARE FUNCTION  XgrGetGridBox                (grid, @x1, @y1, @x2, @y2)
DECLARE FUNCTION  XgrGetGridBoxDisplay         (grid, @x1Disp, @y1Disp, @x2Disp, @y2Disp)
DECLARE FUNCTION  XgrGetGridBoxGrid            (grid, @x1Grid, @y1Grid, @x2Grid, @y2Grid)
DECLARE FUNCTION  XgrGetGridBoxLocal           (grid, @x1, @y1, @x2, @y2)
DECLARE FUNCTION  XgrGetGridBoxScaled          (grid, @x1#, @y1#, @x2#, @y2#)
DECLARE FUNCTION  XgrGetGridBoxWindow          (grid, @x1Win, @y1Win, @x2Win, @y2Win)
DECLARE FUNCTION  XgrGetGridBuffer             (grid, @buffer, @x, @y)
DECLARE FUNCTION  XgrGetGridCharacterMapArray  (grid, @map[])
DECLARE FUNCTION  XgrGetGridClip               (grid, @clipGrid)
DECLARE FUNCTION  XgrGetGridCoords             (grid, @xWin, @yWin, @x1, @y1, @x2, @y2)
DECLARE FUNCTION  XgrGetGridDrawingMode        (grid, @drawingMode, @lineStyle, @lineWidth)
DECLARE FUNCTION  XgrGetGridFont               (grid, @font)
DECLARE FUNCTION  XgrGetGridFunction           (grid, @func)
DECLARE FUNCTION  XgrGetGridParent             (grid, @parent)
DECLARE FUNCTION  XgrGetGridPositionAndSize    (grid, @x, @y, @width, @height)
DECLARE FUNCTION  XgrGetGridState              (grid, @state)
DECLARE FUNCTION  XgrGetGridType               (grid, @gridType)
DECLARE FUNCTION  XgrGetGridWindow             (grid, @window)
DECLARE FUNCTION  XgrGridTypeNameToNumber      (gridTypeName$, @gridTypeNumber)
DECLARE FUNCTION  XgrGridTypeNumberToName      (gridTypeNumber, @gridTypeName$)
DECLARE FUNCTION  XgrRegisterGridType          (gridTypeName$, gridType)
DECLARE FUNCTION  XgrSetGridBorder             (grid, border, borderUp, borderDown, borderFlags)
DECLARE FUNCTION  XgrSetGridBorderOffset       (grid, left, top, right, bottom)
DECLARE FUNCTION  XgrSetGridBox                (grid, x1, y1, x2, y2)
DECLARE FUNCTION  XgrSetGridBoxGrid            (grid, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrSetGridBoxScaled          (grid, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrSetGridBoxScaledAt        (grid, x1#, y1#, x2#, y2#, x1, y1, x2, y2)
DECLARE FUNCTION  XgrSetGridBuffer             (grid, buffer, x, y)
DECLARE FUNCTION  XgrSetGridCharacterMapArray  (grid, @map[])
DECLARE FUNCTION  XgrSetGridClip               (grid, clipGrid)
DECLARE FUNCTION  XgrSetGridDrawingMode        (grid, drawingMode, lineStyle, lineWidth)
DECLARE FUNCTION  XgrSetGridFont               (grid, font)
DECLARE FUNCTION  XgrSetGridFunction           (grid, func)
DECLARE FUNCTION  XgrSetGridParent             (grid, parent)
DECLARE FUNCTION  XgrSetGridPositionAndSize    (grid, x, y, width, height)
DECLARE FUNCTION  XgrSetGridState              (grid, state)
DECLARE FUNCTION  XgrSetGridTimer              (grid, msTimeInterval)
DECLARE FUNCTION  XgrSetGridType               (grid, gridType)
'
' Drawing Functions
'
DECLARE FUNCTION  XgrDrawArc                   (grid, color, r, startAngle#, endAngle#)
DECLARE FUNCTION  XgrDrawArcGrid               (grid, color, r, startAngle#, endAngle#)
DECLARE FUNCTION  XgrDrawArcScaled             (grid, color, r#, startAngle#, endAngle#)
DECLARE FUNCTION  XgrDrawBorder                (grid, border, back, low, high, x1, y1, x2, y2)
DECLARE FUNCTION  XgrDrawBorderGrid            (grid, border, back, low, high, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrDrawBorderScaled          (grid, border, back, low, high, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrDrawBox                   (grid, color, x1, y1, x2, y2)
DECLARE FUNCTION  XgrDrawBoxGrid               (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrDrawBoxScaled             (grid, color, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrDrawCircle                (grid, color, r)
DECLARE FUNCTION  XgrDrawCircleGrid            (grid, color, r)
DECLARE FUNCTION  XgrDrawCircleScaled          (grid, color, r#)
DECLARE FUNCTION  XgrDrawEllipse               (grid, color, rx, ry)
DECLARE FUNCTION  XgrDrawEllipseGrid           (grid, color, rx, ry)
DECLARE FUNCTION  XgrDrawEllipseScaled         (grid, color, rx#, ry#)
DECLARE FUNCTION  XgrDrawGridBorder            (grid, border)
DECLARE FUNCTION  XgrDrawIcon                  (grid, icon, x, y)
DECLARE FUNCTION  XgrDrawIconGrid              (grid, icon, xGrid, yGrid)
DECLARE FUNCTION  XgrDrawIconScaled            (grid, icon, x#, y#)
DECLARE FUNCTION  XgrDrawLine                  (grid, color, x1, y1, x2, y2)
DECLARE FUNCTION  XgrDrawLineGrid              (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrDrawLineScaled            (grid, color, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrDrawLineTo                (grid, color, x, y)
DECLARE FUNCTION  XgrDrawLineToGrid            (grid, color, xGrid, yGrid)
DECLARE FUNCTION  XgrDrawLineToScaled          (grid, color, x#, y#)
DECLARE FUNCTION  XgrDrawLineToDelta           (grid, color, dx, dy)
DECLARE FUNCTION  XgrDrawLineToDeltaGrid       (grid, color, dxGrid, dyGrid)
DECLARE FUNCTION  XgrDrawLineToDeltaScaled     (grid, color, dx#, dy#)
DECLARE FUNCTION  XgrDrawLines                 (grid, color, first, count, ANY lines[])
DECLARE FUNCTION  XgrDrawLinesGrid             (grid, color, first, count, ANY lines[])
DECLARE FUNCTION  XgrDrawLinesScaled           (grid, color, first, count, ANY lines[])
DECLARE FUNCTION  XgrDrawLinesTo               (grid, color, first, count, ANY lines[])
DECLARE FUNCTION  XgrDrawLinesToGrid           (grid, color, first, count, ANY lines[])
DECLARE FUNCTION  XgrDrawLinesToScaled         (grid, color, first, count, ANY lines[])
DECLARE FUNCTION  XgrDrawPoint                 (grid, color, x, y)
DECLARE FUNCTION  XgrDrawPointGrid             (grid, color, xGrid, yGrid)
DECLARE FUNCTION  XgrDrawPointScaled           (grid, color, x#, y#)
DECLARE FUNCTION  XgrDrawPoints                (grid, color, first, count, ANY points[])
DECLARE FUNCTION  XgrDrawPointsGrid            (grid, color, first, count, ANY points[])
DECLARE FUNCTION  XgrDrawPointsScaled          (grid, color, first, count, ANY points[])
DECLARE FUNCTION  XgrDrawText                  (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextGrid              (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextScaled            (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextFill              (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextFillGrid          (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextFillScaled        (grid, color, text$)
DECLARE FUNCTION  XgrDrawTextWide              (grid, color, USHORT text[])
DECLARE FUNCTION  XgrDrawTextWideGrid          (grid, color, USHORT text[])
DECLARE FUNCTION  XgrDrawTextWideScaled        (grid, color, USHORT text[])
DECLARE FUNCTION  XgrDrawTextWideFill          (grid, color, USHORT text[])
DECLARE FUNCTION  XgrDrawTextWideFillGrid      (grid, color, USHORT text[])
DECLARE FUNCTION  XgrDrawTextWideFillScaled    (grid, color, USHORT text[])
DECLARE FUNCTION  XgrFillBox                   (grid, color, x1, y1, x2, y2)
DECLARE FUNCTION  XgrFillBoxGrid               (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrFillBoxScaled             (grid, color, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrFillTriangle              (grid, color, style, direction, x1, y1, x2, y2)
DECLARE FUNCTION  XgrFillTriangleGrid          (grid, color, style, direction, x1Grid, y1Grid, x2Grid, y2Grid)
DECLARE FUNCTION  XgrFillTriangleScaled        (grid, color, style, direction, x1#, y1#, x2#, y2#)
DECLARE FUNCTION  XgrGetDrawpoint              (grid, x, y)
DECLARE FUNCTION  XgrGetDrawpointGrid          (grid, xGrid, yGrid)
DECLARE FUNCTION  XgrGetDrawpointScaled        (grid, x#, y#)
DECLARE FUNCTION  XgrGrabPoint                 (grid, x, y, red, green, blue, color)
DECLARE FUNCTION  XgrGrabPointGrid             (grid, xGrid, yGrid, red, green, blue, color)
DECLARE FUNCTION  XgrGrabPointScaled           (grid, x#, y#, red, green, blue, color)
DECLARE FUNCTION  XgrMoveDelta                 (grid, dx, dy)
DECLARE FUNCTION  XgrMoveDeltaGrid             (grid, dxGrid, dyGrid)
DECLARE FUNCTION  XgrMoveDeltaScaled           (grid, dx#, dy#)
DECLARE FUNCTION  XgrMoveTo                    (grid, x, y)
DECLARE FUNCTION  XgrMoveToGrid                (grid, xGrid, yGrid)
DECLARE FUNCTION  XgrMoveToScaled              (grid, x#, y#)
DECLARE FUNCTION  XgrSetDrawpoint              (grid, x, y)
DECLARE FUNCTION  XgrSetDrawpointGrid          (grid, xGrid, yGrid)
DECLARE FUNCTION  XgrSetDrawpointScaled        (grid, x#, y#)
'
' Image Functions
'
DECLARE FUNCTION  XgrCopyImage                 (destGrid, srcGrid)
DECLARE FUNCTION  XgrDrawImage                 (destGrid, srcGrid, x1, y1, x2, y2, dx1, dy1)
DECLARE FUNCTION  XgrDrawImageExtend           (destGrid, srcGrid, x1, y1, x2, y2, dx1, dy1)
DECLARE FUNCTION  XgrDrawImageExtendScaled     (destGrid, srcGrid, x1, y1, x2, y2, dx1, dy1)
DECLARE FUNCTION  XgrDrawImageScaled           (destGrid, srcGrid, x1, y1, x2, y2, dx1, dy1)
DECLARE FUNCTION  XgrGetImage                  (grid, UBYTE image[])
DECLARE FUNCTION  XgrGetImageArrayInfo         (UBYTE image[], bitsPerPixel, width, height)
DECLARE FUNCTION  XgrLoadImage                 (fileName$, UBYTE image[])
DECLARE FUNCTION  XgrRefreshGrid               (grid)
DECLARE FUNCTION  XgrSaveImage                 (fileName$, UBYTE image[])
DECLARE FUNCTION  XgrSetImage                  (grid, UBYTE image[])
'
' Focus Functions
'
DECLARE FUNCTION  XgrGetMouseFocus             (window, grid)
DECLARE FUNCTION  XgrGetMouseInfo              (window, grid, x, y, state, time)
DECLARE FUNCTION  XgrGetSelectedWindow         (window)
DECLARE FUNCTION  XgrGetTextSelectionGrid      (grid)
DECLARE FUNCTION  XgrSetMouseFocus             (window, grid)
DECLARE FUNCTION  XgrSetSelectedWindow         (window)
DECLARE FUNCTION  XgrSetTextSelectionGrid      (grid)
'
' Message Functions
'
DECLARE FUNCTION  XgrAddMessage                (wingrid, message, v0, v1, v2, v3, r0, ANY)
DECLARE FUNCTION  XgrDeleteMessages            (count)
DECLARE FUNCTION  XgrGetCEO                    (func)
DECLARE FUNCTION  XgrGetMessages               (count, MESSAGE messages[])
DECLARE FUNCTION  XgrGetMessageType            (message, messageType)
DECLARE FUNCTION  XgrJamMessage                (wingrid, message, v0, v1, v2, v3, r0, ANY)
DECLARE FUNCTION  XgrMessageNameToNumber       (messageName$, messageNumber)
DECLARE FUNCTION  XgrMessageNames              (count, messages$[])
DECLARE FUNCTION  XgrMessageNumberToName       (messageNumber, messageName$)
DECLARE FUNCTION  XgrMessagesPending           (count)
DECLARE FUNCTION  XgrPeekMessage               (wingrid, message, v0, v1, v2, v3, r0, ANY)
DECLARE FUNCTION  XgrProcessMessages           (maxCount)
DECLARE FUNCTION  XgrRedrawWindow              (window, action, xWin, yWin, width, height)
DECLARE FUNCTION  XgrRegisterMessage           (message$, message)
DECLARE FUNCTION  XgrSendMessage               (wingrid, message, v0, v1, v2, v3, r0, ANY)
DECLARE FUNCTION  XgrSendMessageToWindow       (wingrid, message, v0, v1, v2, v3, r0, ANY)
DECLARE FUNCTION  XgrSendStringMessage         (wingrid, message$, v0, v1, v2, v3, r0, ANY)
DECLARE FUNCTION  XgrSendStringMessageToWindow (wingrid, message$, v0, v1, v2, v3, r0, ANY)
DECLARE FUNCTION  XgrSetCEO                    (func)
'
END EXPORT
'
' **********************************
' *****  Xgr ACCESS FUNCTIONS  *****
' **********************************
'
DECLARE FUNCTION  XgrGetImage32           (grid, UBYTE image[])
DECLARE FUNCTION  XxxDispatchEvents       (wait, processSystem)
DECLARE FUNCTION  XxxXgrBlowback          ()
DECLARE FUNCTION  XxxXgrReleaseMice       ()
DECLARE FUNCTION  XxxXgrSetHelpWindow     (window)
DECLARE FUNCTION  XxxXgrQuit              ()
'
DECLARE FUNCTION  XxxDIBToDIB24           (UBYTE simage[], UBYTE dimage[])
DECLARE FUNCTION  XxxDIBToDIB32           (UBYTE simage[], UBYTE dimage[])
'
' ****************************************
' *****  EVENT PROCESSING FUNCTIONS  *****
' ****************************************
'
INTERNAL FUNCTION  CheckMice              ()
INTERNAL FUNCTION  MouseMessage           ()
INTERNAL FUNCTION  Initialize             ()
INTERNAL FUNCTION  WinProc                (hwnd, message, wParam, lParam)
INTERNAL FUNCTION  WindowInfo             (window, xDisp, yDisp, width, height)
'
' ******************************************
' *****  INTERNAL CLIPBOARD FUNCTIONS  *****
' ******************************************
'
INTERNAL FUNCTION  GetClipText            (text$)
INTERNAL FUNCTION  SetClipText            (text$)
'
'
' *****************************************
' *****  INTERNAL GRAPHICS FUNCTIONS  *****
' *****************************************
'
INTERNAL FUNCTION  AlarmBlock							()
INTERNAL FUNCTION  AlarmUnblock						()
INTERNAL FUNCTION  ConvertWinToGrid				(grid, npoints, points[])
INTERNAL FUNCTION  ConvertWinToScaled			(grid, npoints, points[], points#[])
INTERNAL FUNCTION  ConvertDIBto24Bit			(UBYTE image[])
INTERNAL FUNCTION  ConvertGridToWin				(grid, npoints, points[])
INTERNAL FUNCTION  ConvertGridToScaled		(grid, npoints, points[], points#[])
INTERNAL FUNCTION  ConvertScaledToWin			(grid, npoints, points[], points#[])
INTERNAL FUNCTION  ConvertScaledToGrid		(grid, npoints, points[], points#[])
INTERNAL FUNCTION  CreateSysImage					(imageGrid, sysImage)
INTERNAL FUNCTION  ClosestGrid						(window, xWin, yWin)
INTERNAL FUNCTION  DestroySysImage				(grid, sysImage)
INTERNAL FUNCTION  InvalidWindow					(window)
INTERNAL FUNCTION  InvalidGrid						(grid)
INTERNAL FUNCTION  LoadFonts							(hdc)
INTERNAL FUNCTION  LoadFontsCallback			(LOGFONT logFont, newTextMetricAddr, fontType, action)
INTERNAL FUNCTION  Log										(message$)
INTERNAL FUNCTION  OpenDisplay						(display$)
INTERNAL FUNCTION  RedrawGridAndKids      (grid, action, xWin, yWin, width, height)
INTERNAL FUNCTION  ReturnGridClip					(window, clipGrid, x, y, width, height)
INTERNAL FUNCTION  SetGridClip						(window, clipGrid)
INTERNAL FUNCTION  SetGridClip2						(window, grid, x, y, width, height)
INTERNAL FUNCTION  SetDrawMode						(window, drawMode)
INTERNAL FUNCTION  SetGridBrushPen				(grid, color)
INTERNAL FUNCTION  SetImageClip						(window, clipGrid, imageGrid)
INTERNAL FUNCTION  SetLineAttributes			(grid, color)
INTERNAL FUNCTION  SetPointAttributes			(grid, color)
INTERNAL FUNCTION  SetTextAttributes			(grid, color, style)
INTERNAL FUNCTION  SetWindowBrush					(window, color)
INTERNAL FUNCTION  UpdateSysImage					(imageGrid)
INTERNAL FUNCTION  XgrShowColors					(grid)
INTERNAL FUNCTION  calculateCoordinates   (grid, x1, y1, x2, y2, ixWin, iyWin, ix2Win, iy2Win)

'
EXTERNAL FUNCTION  XxxGetVersion          ()
EXTERNAL CFUNCTION  printf                (addr, ...)
'
'
'	Primary information for the Xgr system:
'		hostDisplayName$[]									info on each display
'		DISPLAYINFO hostDisplay[host]
'			OpenDisplay() (or via XxxCreateWindow()) initializes the display on the
'				specified display$.  It assigns a "host" number and stores information
'				that is unique to that display and applicable to all windows opened on
'				it.  hostDisplay[] is a 1D array with host index.  (See DISPLAYINFO).
'				host = 0 is unused and indicates invalid host number.
'
'		FONTINFO  fontInfo[i]								font information
'			fontInfo[] is a 1D array whose index is the Xgr font number
'
'		WINDOWINFO windowInfo[window]				info on the many windows per display
'			XgrCreateWindow() opens a window on a specified display$.  It assigns a
'			window number and stores information that is unique to that
'			window and applicable to all grids opened on it.  windowInfo[] is a
'			1D array with window index.  (See WINDOWINFO).
'			window = 0 is unused and indicates invalid window number.
'
'		GRIDINFO gridInfo[grid]							info on the many grids per window
'			XgrCreateGrid() opens a new grid on the specified window.  It assigns a grid
'				number and stores information that is unique to that grid.  gridInfo[]
'				is a 1D array with grid index.  (See GRIDINFO).
'			grid = 0 is unused and indicates invalid grid number.
'
'		NTIMAGEINFO  ntImageInfo						hdc info for image grids
'			NT uses a separate hdc for the image, so its current status
'			must be retained.  The hdc values are those currently in
'			the image hdc and typically won't match the imageGrid values.
'			(Drawing into a grid with a buffer will draw on the screen
'			[changing the window hdc] then on the imageGrid [changing
'			the image hdc, but not the imageGrid GRIDINFO settings].
'
'		XLONG hostWin[host,i]								windows open on each host
'			hostWin[] is a 2D array containing a list of open windows for each host
'
'		XLONG winGrid[window,i]							grids open on each window
'			winGrid[] is a 2D array containing a list of open grids for each window
'
'		MESSAGE  systemMessageQueue[i]
'			systemMessageQueue[] is a 1D array containing the system messages
'				It has a max size (1024).  Messages go in at systemMessageQueueIn and
'					come out at systemMessageQueueOut.
'				If the queue fills, wait till it is emptied completely before allowing
'					more messages to come in.  (This prevents choppy behavior that occurs
'					if messages pop in as the gap widens, halts till there is another gap.)
'			NOTE:  res0/res1  are unused, uninitialized, unmaintained in this version
'					XgrGetMessages() returns 0 for their values
'
'		XLONG  systemMessageQueueOut,  systemMessageQueueIn
'			the in and out indices of the system message queue

'		MESSAGE  userMessageQueue[i]
'			userMessageQueue[] is a 1D array containing the user messages
'				It has a max size (1024).  Messages go in at userMessageQueueIn and come out
'					at userMessageQueueOut.
'				If the queue fills, wait till it is emptied completely before allowing
'					more messages to come in.  (This prevents choppy behavior that occurs
'					if messages pop in as the gap widens, halts till there is another gap.)
'			NOTE:  res0/res1  are unused, uninitialized, unmaintained in this version
'					XgrGetMessages() returns 0 for their values
'
'		XLONG  userMessageQueueOut,  userMessageQueueIn
'			the in and out indices of the user message queue
'
'		XGR_MESSAGE  lastMouseMessage
'			holds the last mouse state received.
'
'		SBYTE  msgType[]
'			holds message type of all messages (1 = window, 2 = grid)
'
'		STRING  sysFontNames$[]
'			holds the names of all TrueType fonts available on system
'
'		LOGFONT  sysFontInfo[]
'			holds the LOGFONT (name and info) for all TrueType fonts
'				available (ie those installed into Windows OS)
'
' ************************************
' *****  Xit hostDisplay Arrays  *****
' ************************************
'
	SHARED  DISPLAYINFO  hostDisplay[]			' display info
'
' *****************************************
' *****  SHARED VARIABLES and ARRAYS  *****
' *****************************************
'
	SHARED  hostDisplayName$[]							' display names (eg "leia:0.0")
	SHARED  FONTINFO  fontInfo[]						' XBasic font info
	SHARED  WINDOWINFO  windowInfo[]				' window information
	SHARED  GRIDINFO  gridInfo[]						' grid specifications
	SHARED  NTIMAGEINFO  ntImageInfo				' image specifications
	SHARED  hostWin[]												' windows open on each host
	SHARED  winGrid[]												' grids open for each window
	SHARED  SBYTE  msgType[]								' message types
	SHARED  LOGFONT  sysFontInfo[]					' detailed font info
	SHARED  sysFontNames$[]									' system font names available
	SHARED  sysFontNames										' number of font names
	SHARED  hdcFont													' required for initialization
	SHARED  fontWindow											' required to create fonts (needs hdc)
	SHARED  fontPtr
	SHARED  defaultFont

	SHARED  textSelectionGrid								' text selection grid/array

	SHARED  systemCEO												' CEO functions
	SHARED  userCEO
	SHARED  operatingSystem

	SHARED  XGR_MESSAGE  lastMouseMessage
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  systemMessageQueueOut
	SHARED  systemMessageQueueIn
	SHARED  noMessagesTillSystemQueueEmptied
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  userMessageQueueOut
	SHARED  userMessageQueueIn
	SHARED  noMessagesTillUserQueueEmptied
	SHARED	mouseWheelMessage
	SHARED	mouseWheelLines

	SHARED  xgrError												' Xgr error code--unused 5/14/93
	SHARED  colorPixel[]										' XBasic color --> WindowsNT pixel
	SHARED  ntDrawMode[]										' XBasic drawMode --> NT drawMode
	SHARED  xgrInitialized									' Xgr() has been executed
	SHARED  alarmBlocked

	SHARED  arg[]														' X-Windows resource array
	SHARED  suspend[]												' For suspend (Peek/Process Messages)
	SHARED  points[]												' For conversion routines ([3])
	SHARED  points#[]

	SHARED  messageHash%%[]									' Message name registry
	SHARED  messageName$[]
	SHARED  messagePtr											' also last valid message

	SHARED  gridTypeHash%%[]
	SHARED  gridTypeName$[]
	SHARED  gridTypePtr											' also last valid gridType

	SHARED  cursorHash%%[]
	SHARED  cursorName$[]
	SHARED  cursorHandle[]
	SHARED  cursorPtr
	SHARED  currentCursor
	SHARED  overrideCursor

	SHARED  iconName$[]
	SHARED  iconHandle[]
	SHARED  iconPtr

	SHARED  bufferText$[]
'
'
' ****************************
' *****  Xgr Grid Types  *****
' ****************************
'
	SHARED  GT_Coordinate			' 0
	SHARED  GT_Image					' 1
'
' ********************************
' *****  Xgr Default Colors  *****
' ********************************
'
	SHARED  defaultBackground
	SHARED  defaultDrawing
	SHARED  defaultLowlight
	SHARED  defaultHighlight
	SHARED  defaultDull
	SHARED  defaultAccent
	SHARED	defaultLowText
	SHARED	defaultHighText
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
  $$LightGrey           =  93   ' 0xBFBFBF5D
  $$BrightGrey          =  93   ' 0xBFBFBF5D
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
  $$AsciiEscape         = 0x1B    '  \e
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
  $$KeyPad0             = 0x60
  $$KeyPad1             = 0x61
  $$KeyPad2             = 0x62
  $$KeyPad3             = 0x63
  $$KeyPad4             = 0x64
  $$KeyPad5             = 0x65
  $$KeyPad6             = 0x66
  $$KeyPad7             = 0x67
  $$KeyPad8             = 0x68
  $$KeyPad9             = 0x69
  $$KeyPadMultiply      = 0x6A
  $$KeyPadAdd           = 0x6B
  $$KeyPadSubtract      = 0x6D
  $$KeyPadDecimalPoint  = 0x6E
  $$KeyPadDivide        = 0x6F
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
  $$KeyLeftMenu         = 0xA4
  $$KeyRightMenu        = 0xA5
END EXPORT
'
' ******************************
' *****  Alternate Colors  *****  Sometimes Work Better  *****
' ******************************
'
'
' ColorConstant  Decimal  Hexadecimal
'
'                   color#    RRGGBBCC
'	$$Black         =   0   ' 0x00000000
'	$$DarkBlue      =   1   ' 0x00004001
'	$$MediumBlue    =   2   ' 0x00008002
'	$$Blue          =   2   ' 0x00008002
'	$$BrightBlue    =   3   ' 0x0000C003
'	$$LightBlue     =   4   ' 0x0000FF04
'	$$DarkGreen     =   5   ' 0x00400005
'	$$MediumGreen   =  10   ' 0x0080000A
'	$$Green         =  10   ' 0x0080000A
'	$$BrightGreen   =  15   ' 0x00C0000F
'	$$LightGreen    =  20   ' 0x00FF0014
'	$$DarkCyan      =   6   ' 0x00404006
'	$$MediumCyan    =  12   ' 0x0080800C
'	$$Cyan          =  12   ' 0x0080800C
'	$$BrightCyan    =  18   ' 0x00C0C012
'	$$LightCyan     =  24   ' 0x00FFFF18
'	$$DarkRed       =  25   ' 0x40000019
'	$$MediumRed     =  50   ' 0x80000032
'	$$Red           =  50   ' 0x80000032
'	$$BrightRed     =  75   ' 0xC000004B
'	$$LightRed      = 100   ' 0xFF000064
'	$$DarkMagenta   =  26   ' 0x4000401A
'	$$MediumMagenta =  52   ' 0x80008034
'	$$Magenta       =  52   ' 0x80008034
'	$$BrightMagenta =  78   ' 0xC000C04E
'	$$LightMagenta  = 104   ' 0xFF00FF68
'	$$DarkBrown     =  30   ' 0x4040001E
'	$$MediumBrown   =  60   ' 0x8080003C
'	$$Brown         =  60   ' 0x8080003C
'	$$BrightYellow  =  90   ' 0xC0C0005A
'	$$Yellow        =  90   ' 0xC0C0005A
'	$$LightYellow   = 120   ' 0xFFFF0078
'	$$DarkGrey      =  31   ' 0x4040401F
'	$$MediumGrey    =  62   ' 0x8080803E
'	$$Grey          =  62   ' 0x8080803E
'	$$BrightGrey    =  93   ' 0xC0C0C05D
'	$$DarkSteel     =  32   ' 0x40408020
'	$$MediumSteel   =  63   ' 0x8080C03F
'	$$Steel         =  63   ' 0x8080C03F
'	$$BrightSteel   =  94   ' 0xC0C0FF5E
'	$$MediumOrange  =  81   ' 0xC0404051
'	$$Orange        =  81   ' 0xC0404051
'	$$BrightOrange  = 112   ' 0xFF808070
'	$$MediumAqua    =  42   ' 0x40C0802A
'	$$Aqua          =  42   ' 0x40C0802A
'	$$BrightAqua    =  73   ' 0x80FFC049
'	$$DarkViolet    =  57   ' 0x80408039
'	$$MediumViolet  =  88   ' 0xC080C058
'	$$Violet        =  88   ' 0xC080C058
'	$$BrightViolet  = 119   ' 0xFFC0FF77
'	$$White         = 124   ' 0xFFFFFF7C
'
'
	$$BYTE0					= BITFIELD (8, 0)
	$$BYTE1					= BITFIELD (8, 8)
	$$BYTE2					= BITFIELD (8, 16)
	$$BYTE3					= BITFIELD (8, 24)
	$$WORD0					= BITFIELD (16, 0)
	$$WORD1					= BITFIELD (16, 16)
'
	$$StateContents	= BITFIELD (2, 20)
'
	$$SIG_BLOCK		= 0											' block signal		(AlarmBlock())
	$$SIG_UNBLOCK = 1											' unblock signal
'
'	Color:
'
	$$ColorNumber	= BITFIELD (8, 0)
	$$B	= BITFIELD (8, 8)
	$$G	= BITFIELD (8,16)
	$$R	= BITFIELD (8,24)
'
	$$BlackPixel	= 0											' NT pixels
	$$WhitePixel	= 0x00FFFFFF
'
'	Operating System types
'
	$$WindowsNT	= 0
	$$Windows		= 1
'
'	The Xgr() error codes:
'
	$$XgrNoError						= 0
	$$XgrNotInitialized			= 1
	$$XgrCannotOpenDisplay	= 2
	$$XgrWindowUndefined		= 3
	$$XgrGridUndefined			= 4
	$$XgrGridDisabled				= 5
	$$XgrInvalidArgument		= 6
	$$XgrMessageQueueFull		= 7
	$$XgrRegisterFull				= 8
	$$XgrUnregistered				= 9
	$$XgrNotAnImageGrid			= 10
	$$XgrNoImageGrid				= 11
	$$XgrNoImage						= 12
	$$XgrImageError					= 13
	$$XgrDifferentWindows		= 14
	$$XgrIOError						= 15
	$$XgrNotDIBFormat				= 16
	$$XgrFontNotCreated			= 17
	$$XgrUnimplemented			= 18
	$$XgrWindowHidden				= 19
	$$XgrRequestFailed			= 20
	$$XgrBadMessage					= 21
'
	$$DrawPointValid				= BITFIELD (1, 0)				' Reserved
	$$DrawPointScaledValid	= BITFIELD (1, 1)				' Reserved
'
	$$10thDEG_TO_RAD = 0d3F5C987103B761F5
'
'
'
' *********************************  should be in
' *****  WindowsNT CONSTANTS  *****  gdi32.dec, kernel32.dec, user32.dec
' *********************************
'
	$$CS_BYTEALIGNCLIENT		= 0x00001000
	$$CS_BYTEALIGNWINDOW		= 0x00002000
	$$CS_CLASSDC						= 0x00000040
	$$CS_GLOBALCLASS				= 0x00004000
	$$CS_HREDRAW						= 0x00000002
	$$CS_OWNDC							= 0x00000020
	$$CS_PARENTDC						= 0x00000080
	$$CS_SAVEBITS						= 0x00000800
	$$CS_VREDRAW						= 0x00000001
'
	$$CW_USEDEFAULT					= 0x80000000
'
	$$GCL_MENUNAME					= -8
	$$GCL_HBRBACKGROUND			= -10
	$$GCL_HCURSOR						= -12
	$$GCL_HICON							= -14
	$$GCL_HMODULE						= -16
	$$GCL_CBWNDEXTRA				= -18
	$$GCL_CBCLSEXTRA				= -20
	$$GCL_WNDPROC						= -24
	$$GCL_STYLE							= -26
'
	$$HWND_BOTTOM						= 1
	$$HWND_NOTOPMOST				= -2
	$$HWND_TOP							= 0
	$$HWND_TOPMOST					= -1
'
	$$IDI_APPLICATION				= 32512
	$$IDI_HAND							= 32513
	$$IDI_QUESTION					= 32514
	$$IDI_EXCLAMATION				= 32515
	$$IDI_ASTERISK					= 32516
'
	$$IDC_ARROW							= 32512
	$$IDC_IBEAM							= 32513
	$$IDC_WAIT							= 32514
	$$IDC_CROSS							= 32515
	$$IDC_UPARROW						= 32516
	$$IDC_SIZE							= 32640
	$$IDC_ICON							= 32641
	$$IDC_SIZENWSE					= 32642
	$$IDC_SIZENESW					= 32643
	$$IDC_SIZEWE						= 32644
	$$IDC_SIZENS						= 32645
	$$IDC_SIZEALL						= 32646
	$$IDC_NO								= 32648
	$$IDC_HAND							= 32649
	$$IDC_APPSTARTING				= 32650
	$$IDC_HELP							= 32651
'
	$$MA_NOACTIVATE					= 3
'
	$$MK_LBUTTON						= 0x0001
	$$MK_RBUTTON						= 0x0002
	$$MK_SHIFT							= 0x0004
	$$MK_CONTROL						= 0x0008
	$$MK_MBUTTON						= 0x0010
'
	$$PM_NOREMOVE						= 0
	$$PM_REMOVE							= 1
'
	$$QS_KEY								= 0x01
	$$QS_MOUSEMOVE					= 0x02
	$$QS_MOUSEBUTTON				= 0x04
	$$QS_POSTMESSAGE				= 0x08
	$$QS_TIMER							= 0x10
	$$QS_PAINT							= 0x20
	$$QS_SENDMESSAGE				= 0x40
	$$QS_HOTKEY							= 0x80
	$$QS_MOUSE							= 0x06
	$$QS_INPUT							= 0x07
	$$QS_ALLEVENTS					= 0xFF

	$$NULLREGION						= 1
	$$SIMPLEREGION					= 2
	$$COMPLEXREGION					= 3

	$$SC_SIZE								= 0xF000
	$$SC_MOVE								= 0xF010
	$$SC_MINIMIZE						= 0xF020
	$$SC_MAXIMIZE						= 0xF030
	$$SC_NEXTWINDOW					= 0xF040
	$$SC_PREVWINDOW					= 0xF050
	$$SC_CLOSE							= 0xF060
	$$SC_VSCROLL						= 0xF070
	$$SC_HSCROLL						= 0xF080
	$$SC_MOUSEMENU					= 0xF090
	$$SC_KEYMENU						= 0xF100
	$$SC_ARRANGE						= 0xF110
	$$SC_RESTORE						= 0xF120
	$$SC_TASKLIST						= 0xF130
	$$SC_SCREENSAVE					= 0xF140
	$$SC_HOTKEY							= 0xF150

	$$SM_CXSCREEN						= 0
	$$SM_CYSCREEN						= 1
	$$SW_HIDE								= 0
	$$SW_SHOWNORMAL					= 1
	$$SW_SHOWMINIMIZED			= 2
	$$SW_SHOWMAXIMIZED			= 3
	$$SW_SHOWNOACTIVATE			= 4
	$$SW_SHOW								= 5
	$$SW_MINIMIZE						= 6
	$$SW_SHOWMINNOACTIVATE	= 7
	$$SW_SHOWNA							= 8
	$$SW_RESTORE						= 9
	$$SW_PARENTCLOSING			= 1
	$$SW_PARENTOPENING			= 3

	$$SWP_NOACTIVATE				= 0x0010
	$$SWP_NOMOVE						= 0x0002
	$$SWP_NOSIZE						= 0x0001
	$$SWP_SHOWWINDOW				= 0x0040
'
	$$VK_LBUTTON						= 0x01
	$$VK_RBUTTON						= 0x02
	$$VK_MBUTTON						= 0x04
	$$VK_SHIFT							= 0x10
	$$VK_CONTROL						= 0x11
	$$VK_MENU								= 0x12															' alt key
	$$VK_LSHIFT             = 0xA0
	$$VK_RSHIFT             = 0xA1
	$$VK_LCONTROL           = 0xA2
	$$VK_RCONTROL           = 0xA3
	$$VK_LMENU              = 0xA4
	$$VK_RMENU              = 0xA5
'
	$$WS_BORDER							= 0x00800000
	$$WS_CAPTION						= 0x00C00000
	$$WS_CHILD							= 0x40000000
	$$WS_CHILDWINDOW				= 0x40000000
	$$WS_DISABLED						= 0x08000000
	$$WS_DLGFRAME						= 0x00400000
	$$WS_MAXIMIZE						= 0x01000000
	$$WS_MAXIMIZEBOX				= 0x00010000
	$$WS_MINIMIZE						= 0x20000000
	$$WS_MINIMIZEBOX				= 0x00020000
	$$WS_OVERLAPPED					= 0x00000000
	$$WS_OVERLAPPEDWINDOW		= 0x00CF0000
	$$WS_POPUP							= 0x80000000
	$$WS_POPUPWINDOW				= 0x80880000
	$$WS_VISIBLE						= 0x10000000
	$$WS_SYSMENU						= 0x00080000
	$$WS_THICKFRAME					= 0x00040000
	$$WS_EX_ACCEPTFILES			= 0x00000010
	$$WS_EX_DLGMODALFRAME		= 0x00000001
	$$WS_EX_NOPARENTNOTIFY	= 0x00000004
	$$WS_EX_TOPMOST					= 0x00000008
  $$WS_EX_TOOLWINDOW      = 0x00000080
	$$WS_EX_TRANSPARENT			= 0x00000020
'
'	Window:  Overlapped / Caption / ThickFrame
'          NO SysMenu / MinimizeBox / MaximizeBox
'
	$$WS_XBASICWINDOW				= 0x00C40000
'
	$$TRANSPARENT           = 1							' SetBkMode()
	$$OPAQUE                = 2							' SetBkMode()
'
	$$STD_INPUT_HANDLE			= -10
	$$STD_OUTPUT_HANDLE			= -11
	$$STD_ERROR_HANDLE			= -12
'
'
' ####################
' #####  Xgr ()  #####
' ####################
'
FUNCTION  Xgr ()
	SHARED  xgrError
	SHARED  arg[]															' X-Windows resource array
	SHARED  suspend[]													' For suspend (Peek/Process Events)
	SHARED  points[]													' For conversion routines ([3])
	SHARED  points#[]
	SHARED  xgrInitialized
'
	IF xgrInitialized THEN RETURN	($$FALSE)
	xgrError = 0
'
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0
'
	a$ = "Max Reason"
	a$ = "copyright 1988-2000"
	a$ = "Windows XBasic GraphicsDesigner function library"
	a$ = "maxreason@maxreason.com"
	a$ = ""
'
	DIM arg[15]
	DIM points[15]
	DIM points#[3]
	DIM suspend[1]
	suspend[0] = 0xFFFBFFFF					' Wake up to normal alarm  (0xFFFBFFFF)
	suspend[1] = 0xFFFFFFFF
'
	##WHOMASK = entryWHOMASK
'
	xgrInitialized = $$TRUE					' must be prior to Initialize for XgrCreateWindows()
	error = Initialize ()
	IF error THEN
		xgrInitialized = $$FALSE
		RETURN (error)
	END IF

END FUNCTION
'
'
' ######################################
' #####  XgrBorderNameToNumber ()  #####
' ######################################
'
FUNCTION  XgrBorderNameToNumber (border$, border)
	SHARED	border$[]
'
	border = XLONG (border$)
	IF border THEN RETURN
	b$ = TRIM$ (border$)
	IFZ b$ THEN RETURN
	c = b${0}
'
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
FUNCTION  XgrBorderNumberToName (border, border$)
	SHARED	border$[]
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
FUNCTION  XgrBorderNumberToWidth (border, width)
	SHARED	borderWidth[]
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
	color = -1
	upper = UBOUND (color$[])
	IF (c$ = "$$LightGrey") THEN c$ = "$$BrightGrey"
	IF (c$ = "$$BrightYellow") THEN c$ = "$$LightYellow"
	IF (c$ = "$$LightOrange") THEN c$ = "$$BrightOrange"
	IF (c$ = "$$LightViolet") THEN c$ = "$$BrightViolet"
'
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
	IFZ color$ THEN color$ = STRING$ (color)
END FUNCTION
'
'
' ##############################
' #####  XgrCreateFont ()  #####
' ##############################
'
'	Create a font
'
'	In:				fontName$				fileName of font on disk ("" for default)
'						fontSize				20th of a point
'						fontWeight			1 - 1000
'						fontItalic			TRUE/FALSE
'						fontAngle				10ths of degrees
'
'	Out:			font						XBasic font number
'
'	Return:		$$FALSE					no errors
'						$$TRUE					error
'
'	Discussion:
'		If name already created, just return font.
'		font 0 is default; created by XgrCreateWindow() during initialization
'		Error if fontPtr > 65535
'
'		Font glossary:
'			ascent		= height above baseline (including internalLeading)
'			descent		= height below baseline
'			height		= ascent + descent
'			internalLeading	= gap above "top" of character for accents, etc
'			externalLeading	= line spacing above character cell (usually 0)
'
'		TrueType fonts:  (those I tested)
'			internalLeading	= 1-3 depending on family, pointSize
'			externalLeading = 0
'			Windows:  specify pointSize as NEGATIVE to force pointSize to be
'									charHeight, not nomLineHeight.
'								With MM_TEXT mapping mode (1 logical unit per pixel),
'									this means point size = charHeight = #pixels.
'
'		OEM_FIXED_FONT:
'			internalLeading	= 0		Looks like 1 pixel blank above char top, though
'			externalLeading = 0
'
'
'		Petzold talks about mucking with the MapMode and Window/Viewport
'			extents to get better font appearance.
'			Setting these values screws all normal drawing operations
'				(Filling, lines,..)
'			Setup for TrueType fonts with "normal" point sizes for heights
'
'			xSysLPPI = GetDeviceCaps (hdc, $$LOGPIXELSX)
'			ySysLPPI = GetDeviceCaps (hdc, $$LOGPIXELSY)
'
'			Window/Viewport extent are ignored in MM_TEXT map mode
'				These settings are enabled only in Text Mode
'
'			SetMapMode (hdc, $$MM_ANISOTROPIC)
'			SetWindowExtEx (hdc, 1440, 1440, 0)
'			SetViewportExtEx (hdc, xSysLPPI, ySysLPPI, 0)
'
'			SetMapMode (hdc, $$MM_TEXT)
'
' ********* DO **********
'   XgrDestroyFont():  MUST keep track of how many times a font has been
'     "created".  Only REALLY destroy it when destroyed for last time.
'
FUNCTION  XgrCreateFont (font, fontName$, fontSize, fontWeight, fontItalic, fontAngle)
	SHARED  xgrError
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  FONTINFO  fontInfo[]
	SHARED  fontWindow
	SHARED  fontPtr
	SHARED  hdcFont
	SHARED  xgrInitialized
	SHARED  bitFontNames
	SHARED  sysFontNames
	SHARED  bitFontNames$[]
	SHARED  sysFontNames$[]
	SHARED  LOGFONT  bitFontInfo[]
	SHARED  LOGFONT  sysFontInfo[]
	STATIC  LOGFONT  logFont
	STATIC  TEXTMETRIC  textMetric
'
	IFZ xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = $$FALSE
'
	font = 0
	font$ = TRIM$ (fontName$)
	IFZ font$ THEN
		IFZ fontInfo[] THEN GOSUB InstallDefaultFont
		##WHOMASK = whomask
		RETURN ($$FALSE)
	END IF
'
'	Standard font name?
'
	typeface$ = LCASE$ (font$)
	SELECT CASE typeface$
		CASE "default"	: RETURN ($$FALSE)
		CASE "fixed"		: RETURN ($$FALSE)
		CASE "serif"		: font$ = "Times New Roman"
		CASE "sanserif"	: font$ = "Arial"
		CASE "courier"	: font$ = "Courier New"
		CASE "roman"		: font$ = "Times New Roman"
		CASE "fancy"		:	font$ = "Times New Roman"
	END SELECT
'
'	known TrueType font name?
'
	FOR sysFont = 0 TO sysFontNames - 1
		IF (font$ = sysFontNames$[sysFont]) THEN EXIT FOR
	NEXT sysFont
'
	IF (sysFont >= sysFontNames) THEN
		xgrError = $$XgrInvalidArgument
		##WHOMASK = whomask
		RETURN ($$TRUE)
	END IF
'
'	set font parameters to Windows ranges
'
	fontWeight = (fontWeight \ 100) * 100							' fontWeight	: 100-900 step 100
	IF (fontWeight < 100) THEN fontWeight = 100
	IF (fontWeight > 900) THEN fontWeight = 900
	IF (fontAngle > 3599) THEN fontAngle = 0
	IF (fontAngle < 0) THEN fontAngle = 0							' fontAngle		: 0-3600 only
	IF (fontItalic < -1000) THEN fontItalic = 0				' fontItalic	: -1000 to +1000
	IF (fontItalic > +1000) THEN fontItalic = 0				' fontItalic	: -1000 to +1000
	IF fontItalic THEN logItalic = $$TRUE ELSE logItalic = $$FALSE
'
'	is font already defined ?
'
'	PRINT " n", 0, sysFont, fontSize, fontWeight, fontItalic, fontAngle
	IF fontInfo[] THEN
		FOR i = 1 TO UBOUND(fontInfo[])
'			PRINT i, fontInfo[i].sysFont, fontInfo[i].size, fontInfo[i].weight, fontInfo[i].italic, fontInfo[i].angle
			IFZ fontInfo[i].font										THEN DO NEXT
			IF (sysFont != fontInfo[i].sysFont)			THEN DO NEXT
			IF (fontSize != fontInfo[i].size)				THEN DO NEXT
			IF (fontWeight != fontInfo[i].weight)		THEN DO NEXT
			IF (fontAngle != fontInfo[i].angle)			THEN DO NEXT
			IF fontItalic THEN
				IFZ fontInfo[i].italic 								THEN DO NEXT
			ELSE
				IF fontInfo[i].italic									THEN DO NEXT
			END IF
			font = i
			##WHOMASK = whomask
			RETURN ($$FALSE)
		NEXT i
	END IF
'
'	unique font request : assign a font number
'
	IF (fontPtr >= 0xFFFF) THEN													' no more room
		font = 0
		xgrError = $$XgrRegisterFull
		##WHOMASK = whomask
		RETURN ($$TRUE)
	END IF
'
'	get font handle
'
	logFont = sysFontInfo[sysFont]
	logFont.width = 0
	logFont.height = -fontSize / 20					' .height - .internalLeading (point)
'	logFont.height = fontSize / 20					' .height (point)
	logFont.weight = fontWeight							' 100 - 900
	logFont.italic = logItalic							' T/F
	logFont.escapement = fontAngle					' 10ths of degree
	logFont.orientation = fontAngle					' 10ths of degree
	hFont = CreateFontIndirectA (&logFont)
'
	IFZ hFont THEN
		xgrError = $$XgrFontNotCreated
		##WHOMASK = whomask
		RETURN ($$TRUE)
	END IF
'
	INC fontPtr																' default font is 0
	font = fontPtr														' first named font is 1

	IFZ fontInfo[] THEN
		DIM fontInfo[3]
	ELSE
		uFont = UBOUND(fontInfo[])
		IF (fontPtr >= uFont) THEN
			uFont = (fontPtr + 8) OR 7
			REDIM fontInfo[uFont]
		END IF
	END IF
'
	GOSUB SetFontInfo
'
'	message$ = "XgrCreateFont() : " + STRING$(font) + "." + HEX$(hFont) + "." + RIGHT$("0" + STRING$(sysFont),2) + ":" + RIGHT$("00" + STRING$(fontSize),3) + "," + RIGHT$("00" + STRING$(fontWeight),3) + "," + RIGHT$("00" + STRING$(fontItalic),3) + "," + RIGHT$("00" + STRING$(fontAngle),3) + "." + font$
'	XstLog (@message$)
'
	##WHOMASK = whomask
	RETURN ($$FALSE)
'
'
' *****  SetFontInfo  *****
'
SUB SetFontInfo
	hdc = windowInfo[fontWindow].hdc
'
	##LOCKOUT = $$TRUE
	hFontOld = SelectObject (hdc, hFont)
	GetTextMetricsA (hdc, &textMetric)
	SelectObject (hdc, hFontOld)
	##LOCKOUT = lockout
'
	fontInfo[font].font = font
	fontInfo[font].hFont = hFont
	fontInfo[font].sysFont = sysFont
	fontInfo[font].size = (textMetric.height - textMetric.internalLeading) * 20
	fontInfo[font].size = fontSize
	fontInfo[font].weight = textMetric.weight
	fontInfo[font].weight = fontWeight
	fontInfo[font].italic = textMetric.italic
	fontInfo[font].italic = fontItalic
	fontInfo[font].angle = fontAngle
	fontInfo[font].width = textMetric.maxCharWidth
	fontInfo[font].height = textMetric.height
	fontInfo[font].ascent = textMetric.ascent
	fontInfo[font].descent = textMetric.descent
	fontInfo[font].internalLeading = textMetric.internalLeading
	fontInfo[font].externalLeading = textMetric.externalLeading
END SUB
'
'
' *****  SetDefaultFontInfo  *****
'
SUB SetDefaultFontInfo
	hdc = windowInfo[fontWindow].hdc
'
	##LOCKOUT = $$TRUE
	hFontOld = SelectObject (hdc, hFont)
	GetTextMetricsA (hdc, &textMetric)
	SelectObject (hdc, hFontOld)
	##LOCKOUT = lockout
'
	fontInfo[font].font = font
	fontInfo[font].hFont = hFont
	fontInfo[font].sysFont = sysFont
	fontInfo[font].size = (textMetric.height - textMetric.internalLeading) * 20
	fontInfo[font].weight = textMetric.weight
	fontInfo[font].italic = textMetric.italic
	fontInfo[font].angle = 0
	fontInfo[font].width = textMetric.maxCharWidth
	fontInfo[font].height = textMetric.height
	fontInfo[font].ascent = textMetric.ascent
	fontInfo[font].descent = textMetric.descent
	fontInfo[font].internalLeading = textMetric.internalLeading
	fontInfo[font].externalLeading = textMetric.externalLeading
END SUB
'
'
' *****  InstallDefaultFont  *****
'
SUB InstallDefaultFont
	done = $$FALSE
	DIM fontInfo[3]
	GOSUB SaveBitmapFonts
	GOSUB FontFileDefaultFont					' set xxx/font.xxx font
	IFZ done THEN GOSUB BitmapDefault
	IFZ done THEN GOSUB DefaultFont
END SUB
'
'
' *****  SaveBitmapFonts  *****
'
SUB SaveBitmapFonts
	file$ = "$XBDIR" + $$PathSlash$ + "templates" + $$PathSlash$ + "fonts.xxx"
	u = UBOUND (bitFontNames$[])
	v = u + 8
	DIM temp$[v]
	temp$[0] = "OEM_FIXED_FONT"
	temp$[1] = "ANSI_FIXED_FONT"
	temp$[2] = "ANSI_VAR_FONT"
	temp$[3] = "SYSTEM_FONT"
	temp$[4] = "DEVICE_DEFAULT_FONT"
	temp$[5] = "UNSPECIFIED_FONT"
	temp$[6] = "SYSTEM_FIXED_FONT"
	temp$[7] = "DEFAULT_GUI_FONT"
	FOR i = 0 TO u
		temp$[i+8] = bitFontNames$[i]
	NEXT i
	XstSaveStringArray (@file$, @temp$[])
	DIM temp$[]
END SUB
'
'
' *****  FontFileDefaultFont  *****
'
SUB FontFileDefaultFont
	file$ = "$XBDIR" + $$PathSlash$ + "templates" + $$PathSlash$ + "font.xxx"
	XstLoadStringArray (@file$, @temp$[])
	IFZ temp$[] THEN
		xfont$ = ""
	ELSE
		uu = UBOUND (temp$[])
		FOR i = 0 TO uu
			xfont$ = TRIM$ (temp$[i])
			IF xfont$ THEN
				IF (xfont${0} != ''') THEN EXIT FOR
			END IF
		NEXT i
		DIM temp$[]
		IF (i > uu) THEN xfont$ = ""
	END IF
	IFZ xfont$ THEN EXIT SUB
'
	object = 0
	SELECT CASE xfont$
		CASE "OEM_FIXED_FONT"				: object = $$OEM_FIXED_FONT
		CASE "ANSI_FIXED_FONT"			: object = $$ANSI_FIXED_FONT
		CASE "ANSI_VAR_FONT"				: object = $$ANSI_VAR_FONT
		CASE "SYSTEM_FONT"					: object = $$SYSTEM_FONT
		CASE "DEVICE_DEFAULT_FONT"	: object = $$DEVICE_DEFAULT_FONT
		CASE "UNSPECIFIED_FONT"			: object = $$UNSPECIFIED_FONT
		CASE "SYSTEM_FIXED_FONT"		: object = $$SYSTEM_FIXED_FONT
		CASE "DEFAULT_GUI_FONT"			: object = $$DEFAULT_GUI_FONT
	END SELECT
'
	IF object THEN
		font = 0
		sysFont = 0
'
		##LOCKOUT = $$TRUE
		hFont = GetStockObject (object)
		##LOCKOUT = lockout
'
		IF hFont THEN
			done = $$TRUE
			GOSUB SetDefaultFontInfo
		END IF
	END IF
END SUB
'
'
' *****  BitmapDefault  *****
'
SUB BitmapDefault
	bitFont$ = ""
	IFZ xfont$ THEN EXIT SUB
	FOR bitFont = 0 TO bitFontNames-1
		IF (xfont$ = bitFontNames$[bitFont]) THEN
			bitFont$ = xfont$
			EXIT FOR
		END IF
	NEXT bitFont
'
	IF bitFont$ THEN
		font$ = bitFont$
		logFont = bitFontInfo[bitFont]
		logFont.faceName = bitFont$
		h = ABS (logFont.height)
'
'		w = logFont.width
'		h$ = font$ + " : height = " + STRING$(h)
'		w$ = font$ + " :  width = " + STRING$(w)
'		XstLog (@h$)
'		XstLog (@w$)
'
		IF (h < 10) THEN
			logFont.height = -10
			logFont.width = 0
		END IF
'
		##LOCKOUT = $$TRUE
		hFont = CreateFontIndirectA (&logFont)
		##LOCKOUT = lockout
'
		IF hFont THEN												' xxx/font.xxx font exists
			font = 0													' default font
			sysFont = 0
			GOSUB SetDefaultFontInfo
			sysFontInfo[sysFont] = bitFontInfo[bitFont]
			done = $$TRUE
		END IF
	END IF
END SUB
'
'
' *****  DefaultFont  *****
'
SUB DefaultFont
	font = 0
	sysFont = 0
	##LOCKOUT = $$TRUE
	hFont = GetStockObject ($$OEM_FIXED_FONT)
	##LOCKOUT = lockout
	GOSUB SetDefaultFontInfo
	done = $$TRUE
END SUB
END FUNCTION
'
'
' ######################################
' #####  XgrCursorNameToNumber ()  #####
' ######################################
'
FUNCTION  XgrCursorNameToNumber (cursorName$, cursorNumber)
	SHARED  xgrError
	SHARED  cursorHash%%[],  cursorName$[],  cursorPtr
	SHARED  xgrInitialized
'
	cursorNumber = -1
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IFZ cursorName$ THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF (cursorName$ = "LastCursor") THEN
		cursorNumber = cursorPtr
		RETURN ($$FALSE)
	END IF
'
	IFZ cursorHash%%[] THEN
		xgrError = $$XgrUnregistered
		RETURN ($$TRUE)
	END IF
'
	hash = 0
	FOR i = 0 TO UBOUND(cursorName$)
		hash = hash + cursorName${i}
	NEXT i
	hash = hash{6,0}
'
'	Is cursorName$ already defined?
'
	IF cursorHash%%[hash,] THEN
		last = cursorHash%%[hash,0]
		FOR i = 1 TO last
			check = cursorHash%%[hash,i]
			IF (cursorName$ = cursorName$[check]) THEN
				cursorNumber = check
				RETURN ($$FALSE)
			END IF
		NEXT i
	END IF
'
	xgrError = $$XgrUnregistered
	RETURN ($$TRUE)
END FUNCTION
'
'
' ######################################
' #####  XgrCursorNumberToName ()  #####
' ######################################
'
FUNCTION  XgrCursorNumberToName (cursorNumber, cursorName$)
	SHARED  xgrError
	SHARED  cursorName$[],  cursorPtr
	SHARED  xgrInitialized
'
	cursorName$ = ""
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IF ((cursorNumber < 0) OR (cursorNumber > cursorPtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	cursorName$ = cursorName$[cursorNumber]
END FUNCTION
'
'
' ###############################
' #####  XgrDestroyFont ()  #####
' ###############################
'
FUNCTION  XgrDestroyFont (font)
'	PRINT "XgrDestroyFont() not implemented"
END FUNCTION
'
'
' ################################
' #####  XgrGetClipboard ()  #####
' ################################
'
FUNCTION  XgrGetClipboard (clipboard, clipType, text$, UBYTE image[])
	SHARED  xgrError
	SHARED  bufferText$[]
	SHARED	bufferImage[]
	UBYTE  temp[]
'
	text$ = ""
	DIM image[]
	whomask = ##WHOMASK
'
	IF ((clipboard < 0) OR (clipboard > 7)) THEN
		error = ($$ErrorObjectClipboard << 8) OR $$ErrorNatureInvalidNumber
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IF ((clipType < 1) OR (clipType > 2)) THEN
		error = ($$ErrorObjectClipboard << 8) OR $$ErrorNatureInvalidType
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IFZ bufferText$[] THEN
		##WHOMASK = $$FALSE
		DIM bufferText$[7]
		DIM bufferImage[7,]
		##WHOMASK = whomask
	END IF
'
	SELECT CASE clipType
		CASE 1	:	IFZ clipboard THEN
								GetClipText (@text$)
							ELSE
								text$ = bufferText$[clipboard]
							END IF
		CASE 2	: IF bufferImage[clipboard,] THEN
								upper = UBOUND (bufferImage[clipboard,])
								SWAP temp[], bufferImage[clipboard,]
								upper = UBOUND (temp[])
								bytes = SIZE (temp[])
								DIM image[upper]
								XstCopyMemory (&temp[], &image[], size)
								SWAP temp[], bufferImage[clipboard,]
							END IF
	END SELECT
END FUNCTION
'
'
' #############################
' #####  XgrGetCursor ()  #####
' #############################
'
FUNCTION  XgrGetCursor (cursor)
	SHARED  xgrError
	SHARED  currentCursor
	SHARED  xgrInitialized
'
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	cursor = currentCursor
END FUNCTION
'
'
' #####################################
' #####  XgrGetCursorOverride ()  #####
' #####################################
'
FUNCTION  XgrGetCursorOverride (cursor)
	SHARED  xgrError
	SHARED  overrideCursor
	SHARED  xgrInitialized
'
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	cursor = overrideCursor
END FUNCTION
'
'
' ##################################
' #####  XgrGetDisplaySize ()  #####
' ##################################
'
'	Get the display size
'
'	In:				display$			display name
'													""  for default display
'
'	Out:			display$			default display name if display$ = ""
'						width					width/height of specified display
'						height
'						borderWidth		in pixels (LR and Bottom)
'						titleHeight		top (including both title and resize)
'
'	Return:		$$TRUE				error
'						$$FALSE				no error
'
FUNCTION  XgrGetDisplaySize (display$, width, height, borderWidth, titleHeight)
	SHARED  xgrError
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  xgrInitialized
'
	width = 0:  height = 0:  borderWidth = 0:  titleHeight = 0
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	host = OpenDisplay (@display$)
	IFZ host THEN
		xgrError = $$XgrCannotOpenDisplay
		EXIT FUNCTION ($$TRUE)
	END IF
'
	width					= hostDisplay[host].displayWidth
	height				= hostDisplay[host].displayHeight
	borderWidth		= hostDisplay[host].borderWidth
	titleHeight		= hostDisplay[host].titleHeight
END FUNCTION
'
'
' ###############################
' #####  XgrGetFontInfo ()  #####
' ###############################
'
FUNCTION  XgrGetFontInfo (font, fontName$, fontSize, fontWeight, fontItalic, fontAngle)
	SHARED  xgrError
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  sysFontNames$[]
	SHARED  FONTINFO  fontInfo[]
	SHARED  fontPtr
	SHARED  xgrInitialized
'
	fontName$ = ""
	fontSize = 0
	fontWeight = 0
	fontItalic = 0
	fontAngle = 0
'
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IF ((font < 0) OR (font > fontPtr)) THEN
		xgrError = $$XgrFontNotCreated
		RETURN ($$TRUE)
	END IF
	IF font THEN
		IFZ fontInfo[font].font THEN
			xgrError = $$XgrFontNotCreated
			RETURN ($$TRUE)
		END IF
	END IF
'
	sysFont = fontInfo[font].sysFont
	fontName$ = sysFontNames$[sysFont]
	fontSize = fontInfo[font].size
	fontWeight = fontInfo[font].weight
	fontItalic = fontInfo[font].italic
	fontAngle = fontInfo[font].angle
END FUNCTION
'
'
' ################################
' #####  XgrGetFontNames ()  #####
' ################################
'
FUNCTION  XgrGetFontNames (count, fontNames$[])
	SHARED  sysFontNames$[]
	SHARED  sysFontNames
'
	IFZ sysFontNames THEN
		count = 0
		DIM fontNames$[]
	ELSE
		count = sysFontNames
		DIM fontNames$[count-1]
		FOR i = 0 TO count-1
			fontNames$[i] = sysFontNames$[i]		' caller WHOMASK
		NEXT i
	END IF
END FUNCTION
'
'
' ##################################
' #####  XgrGetFontMetrics ()  #####
' ##################################
'
'	Return font metrics
'
'	In:				font						XBasic font number
'
'	Out:			maxCharWidth		max cell width (= min for fixed font)	(pixels)
'						maxCharHeight		full Height														(pixels)
'						ascent					baseline to top												(pixels)
'						descent					baseline to bottom										(pixels)
'						gap							internalLeading (part of ascent for accents, etc)		(pixels)
'						flags						0 = TRUE if gap occupied in 0x01-0x1F
'														1 = TRUE if gap occupied in 0x20-0x7F
'														2 = TRUE if gap occupied in 0x80-0xFF
'
'	Return:		$$FALSE			no errors
'						$$TRUE			error
'
FUNCTION  XgrGetFontMetrics (font, maxCharWidth, maxCharHeight, ascent, descent, gap, flags)
	SHARED  xgrError
	SHARED  FONTINFO  fontInfo[]
	SHARED  fontPtr
	SHARED  xgrInitialized
'
	maxCharWidth = 0:  maxCharHeight = 0:  nomLineHeight = 0
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
	IF ((font < 0) OR (font > fontPtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
	IF font THEN
		IFZ fontInfo[font].font THEN
			xgrError = $$XgrInvalidArgument
			RETURN ($$TRUE)
		END IF
	END IF
'
	maxCharWidth  = fontInfo[font].width							' pixels
	maxCharHeight = fontInfo[font].height
	ascent				= fontInfo[font].ascent
	descent				= fontInfo[font].descent
	gap						= fontInfo[font].internalLeading
	flags					= fontInfo[font].externalLeading
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
' #########################################
' #####  XgrGetTextArrayImageSize ()  #####
' #########################################
'
FUNCTION  XgrGetTextArrayImageSize (font, text$[], w, h, width, height, extraX, extraY)
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
'	Return width/height dx/dy for text$ drawn in font
'
'	In:				font
'						text$
'
'	Out:			dxWin			xy offset of new start point:  (width,0) unless angle != 0
'						dyWin
'						width			(pixels)
'						height		(pixels)
'						gap				(pixels)
'						space			(pixels)
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		- font 0 is the default font
'		- Assumes font has the same metrics on ANY display (?)
'
FUNCTION  XgrGetTextImageSize (font, text$, dxWin, dyWin, width, height, gap, space)
	SHARED  xgrError
	SHARED  FONTINFO  fontInfo[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  fontWindow
	SHARED  xgrInitialized
	STATIC  stringSize[]

	dxWin		= 0
	dyWin		= 0
	width		= 0
	height	= 0
	gap			= 0
	space		= 0

	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF

	uFonts = UBOUND (fontInfo[])
	IF ((font < 0) OR (font > uFonts)) THEN
		xgrError = $$XgrFontNotCreated
		RETURN ($$TRUE)
	END IF

	IF font THEN
		IFZ fontInfo[font].font THEN
			xgrError = $$XgrFontNotCreated
			RETURN ($$TRUE)
		END IF
	END IF

	height	= fontInfo[font].height
	gap			= fontInfo[font].internalLeading
	space		= fontInfo[font].externalLeading
'
	IFZ text$ THEN
		RETURN ($$FALSE)
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0

	IFZ stringSize[] THEN DIM stringSize[1]

	hdc = windowInfo[fontWindow].hdc
	lenText = LEN (text$)
	##LOCKOUT	= $$TRUE
	hFont = fontInfo[font].hFont
	hFontOld = SelectObject (hdc, hFont)
	GetTextExtentPointA (hdc, &text$, lenText, &stringSize[])
	SelectObject (hdc, hFontOld)
	##LOCKOUT	= entryLOCKOUT
	width = stringSize[0]
	angle = fontInfo[font].angle
	IF angle THEN
		angleRAD#			= angle * $$10thDEG_TO_RAD
		dxWin					= width * COS(angleRAD#)
		dyWin					= width * SIN(angleRAD#)
	ELSE
		dxWin					= width
		dyWin					= 0
	END IF
'
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ######################################
' #####  XgrGridToSystemWindow ()  #####
' ######################################
'
FUNCTION  XgrGridToSystemWindow (grid, swindow, dx, dy, width, height)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	dx = 0
	dy = 0
	width = 0
	height = 0
	swindow = 0
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	XgrWindowToSystemWindow (window, @swindow, 0, 0, 0, 0)

	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	x2Win = gridInfo[grid].winBox.x2
	y2Win = gridInfo[grid].winBox.y2
'
	dx = x1Win
	dy = y1Win
	width = x2Win - x1Win + 1
	height = y2Win - y1Win + 1
END FUNCTION
'
'
' ####################################
' #####  XgrIconNameToNumber ()  #####
' ####################################
'
FUNCTION  XgrIconNameToNumber (name$, icon)
	SHARED  xgrError
	SHARED  iconName$[],  iconPtr
	SHARED  xgrInitialized
'
	icon = -1
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IFZ name$ THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	iconName$ = LCASE$(name$)
	IF (iconName$ = "lasticon") THEN
		icon = iconPtr
		RETURN ($$FALSE)
	END IF
'
'	Is iconName$ already defined?
'
	FOR i = 0 TO UBOUND (iconName$[])
		IF (iconName$ = iconName$[i]) THEN
			icon = i
			RETURN
		END IF
	NEXT i
	RETURN ($$TRUE)
END FUNCTION
'
'
' ####################################
' #####  XgrIconNumberToName ()  #####
' ####################################
'
FUNCTION  XgrIconNumberToName (icon, icon$)
	SHARED  xgrError
	SHARED  iconName$[],  iconPtr
	SHARED  xgrInitialized
'
	icon$ = ""
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IF ((icon < 0) OR (icon > iconPtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	icon$ = iconName$[icon]
END FUNCTION
'
'
' ##################################
' #####  XgrRegisterCursor ()  #####
' ##################################
'
'	Return a cursor number for a cursor name
'
'	In:				cursorName$			cursor name
'
'	Out:			cursor
'
'	Return:		$$FALSE					no errors
'						$$TRUE					error
'
'	Discussion:
'		If name already registered, just return cursor.
'			cursorName$ can refer to:
'				- Windows standard cursor
'				- cursor imbedded in executable file
'				- *.cur file name (unimplemented--6/4/93)
'		Error if cursorPtr > 65535
'
FUNCTION  XgrRegisterCursor (cursor$, cursor)
	SHARED  xgrError
	SHARED  cursorHash%%[],  cursorName$[],  cursorHandle[],  cursorPtr
	SHARED  xgrInitialized
'
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0
'
	cursorName$ = LCASE$ (cursor$)
'
	IFZ cursorName$ THEN cursorName$ = "arrow"
	IF (cursorName$ = "default") THEN cursorName$ = "arrow"
'
	IF (cursorName$ = "lastcursor") THEN
		cursor = cursorPtr - 1
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	IFZ cursorHash%%[] THEN DIM cursorHash%%[63,]
'
	hash	= 0
	FOR i = 0 TO UBOUND(cursorName$)
		hash = hash + cursorName${i}
	NEXT i
	hash = hash{6,0}															' 0-63 hash
'
'	Is cursorName$ already defined?
'
	IF cursorHash%%[hash,] THEN
		last = cursorHash%%[hash,0]
		FOR i = 1 TO last
			check = cursorHash%%[hash,i]
			IF (cursorName$ = cursorName$[check]) THEN
				cursor = check
				##WHOMASK = entryWHOMASK
				RETURN ($$FALSE)
			END IF
		NEXT i
	END IF
'
'	Assign a cursor
'
	IF (cursorPtr >= 0xFFFF) THEN									' no more room
		cursor = 0
		xgrError = $$XgrRegisterFull
		##WHOMASK = entryWHOMASK
		RETURN ($$TRUE)
	END IF
'
	IFZ cursorHash%%[hash,] THEN
		DIM temp%%[3]
		ATTACH temp%%[] TO cursorHash%%[hash,]
		last = 0
	ELSE
		last = cursorHash%%[hash,0]
		uHash = UBOUND(cursorHash%%[hash,])
		IF (last >= uHash) THEN
			uHash = (uHash + 4) OR 3
			ATTACH cursorHash%%[hash,] TO temp%%[]
			REDIM temp%%[uHash]
			ATTACH temp%%[] TO cursorHash%%[hash,]
		END IF
	END IF
'
'	Standard cursor name?
'
	IF (cursorName$ = "none") THEN
		hCursor = 0
	ELSE
		hinst = 0
		SELECT CASE cursorName$
			CASE "startup"		: cursorID = $$IDC_APPSTARTING
			CASE "uparrow"		: cursorID = $$IDC_UPARROW
			CASE "arrow"			: cursorID = $$IDC_ARROW
			CASE "nesw"				: cursorID = $$IDC_SIZENESW
			CASE "nwse"				: cursorID = $$IDC_SIZENWSE
			CASE "ns"					: cursorID = $$IDC_SIZENS
			CASE "sn"					: cursorID = $$IDC_SIZENS
			CASE "ew"					: cursorID = $$IDC_SIZEWE
			CASE "we"					: cursorID = $$IDC_SIZEWE
			CASE "n"					: cursorID = $$IDC_UPARROW
			CASE "all"				: cursorID = $$IDC_SIZEALL
			CASE "sizenesw"		: cursorID = $$IDC_SIZENESW
			CASE "sizenwse"		: cursorID = $$IDC_SIZENWSE
			CASE "sizens"			: cursorID = $$IDC_SIZENS
			CASE "sizesn"			: cursorID = $$IDC_SIZENS
			CASE "sizeew"			: cursorID = $$IDC_SIZEWE
			CASE "sizewe"			: cursorID = $$IDC_SIZEWE
			CASE "sizeall"		: cursorID = $$IDC_SIZEALL
			CASE "plus"				: cursorID = $$IDC_CROSS
			CASE "wait"				: cursorID = $$IDC_WAIT
			CASE "hourglass"	: cursorID = $$IDC_WAIT
			CASE "crosshair"	: cursorID = $$IDC_CROSS
			CASE "insert"			: cursorID = $$IDC_IBEAM
			CASE "icon"				: cursorID = $$IDC_ICON
			CASE "hand"				: cursorID = $$IDC_HAND
			CASE "help"				: cursorID = $$IDC_HELP
			CASE "no"					: cursorID = $$IDC_NO
			CASE ELSE					: hinst = ##HINSTANCE
													cursorID = &cursorName$
		END SELECT
		entryLOCKOUT = ##LOCKOUT
		##LOCKOUT = $$TRUE
		hCursor = LoadCursorA (hinst, cursorID)
		##LOCKOUT = entryLOCKOUT
'
'		Later:  Look for a disk file:  cursorName$
'			This will call CreateCursor().  These created
'				cursors must be destroyed in XxxXgrQuit().
'
		IFZ hCursor THEN
			##LOCKOUT = $$TRUE
			hCursor = LoadCursorA (0, $$IDC_ARROW)
			##LOCKOUT = entryLOCKOUT
		END IF
	END IF
'
	cursor = cursorPtr												' first cursor is 0
	INC cursorPtr
	INC last
	cursorHash%%[hash,0] = last
	cursorHash%%[hash,last] = cursor
'
	IFZ cursorName$[] THEN
		DIM cursorName$[7]
		DIM cursorHandle[7]
	ELSE
		uName = UBOUND(cursorName$[])
		IF (cursor > uName) THEN
			uName = (cursor + 8) OR 7
			REDIM cursorName$[uName]
			REDIM cursorHandle[uName]
		END IF
	END IF
'
	cursorName$[cursor] = cursorName$
	cursorHandle[cursor] = hCursor
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ################################
' #####  XgrRegisterIcon ()  #####
' ################################
'
'	iconName$ can be:
'		Windows standard icon
'		icon imbedded in executable file
'		.ico file name (not yet implemented)
'
FUNCTION  XgrRegisterIcon (icon$, icon)
	SHARED  xgrError
	SHARED  iconName$[],  iconHandle[],  iconPtr
	SHARED  xgrInitialized
'
	entryWHOMASK = ##WHOMASK
'
	icon = 0
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IFZ icon$ THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	iconName$ = LCASE$(icon$)
	IF (iconName$ = "lasticon") THEN
		icon = iconPtr - 1
		RETURN ($$FALSE)
	END IF
'
'	Is iconName$ already defined?
'
	FOR i = 0 TO UBOUND (iconName$[])
		IF (iconName$ = iconName$[i]) THEN
			icon = i
			RETURN
		END IF
	NEXT i
'
'	Standard icon name?
'
	hinst = 0
	IFZ iconName$ THEN iconName$ = "window"
	IF (iconName$) = "default" THEN iconName$ = "window"
'
	SELECT CASE iconName$
		CASE "application"	:	iconID = $$IDI_APPLICATION
		CASE "hand"					:	iconID = $$IDI_HAND
		CASE "question"			:	iconID = $$IDI_QUESTION
		CASE "exclamation"	:	iconID = $$IDI_EXCLAMATION
		CASE "asterisk"			:	iconID = $$IDI_ASTERISK
		CASE ELSE						:	hinst  = ##HINSTANCE
													iconID = &iconName$
	END SELECT
	entryLOCKOUT = ##LOCKOUT
	##LOCKOUT = $$TRUE
	hIcon = LoadIconA (hinst, iconID)
	##LOCKOUT = entryLOCKOUT
'
' For now we give up here
'	Look for disk file iconName$
'	When this is done, call CreateIcon().
'	These created icons must be destroyed in XxxXgrQuit().
'
	icon = 0
	IFZ hIcon THEN RETURN ($$FALSE)
'
	icon = iconPtr												' first icon is 0
	INC iconPtr
'
	##WHOMASK = 0
'
	IFZ iconName$[] THEN
		DIM iconName$[7]
		DIM iconHandle[7]
	ELSE
		uName = UBOUND(iconName$[])
		IF (icon > uName) THEN
			uName = (icon + 8) OR 7
			REDIM iconName$[uName]
			REDIM iconHandle[uName]
		END IF
	END IF
'
	iconHandle[icon] = hIcon
	iconName$[icon] = iconName$
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ################################
' #####  XgrSetClipboard ()  #####
' ################################
'
FUNCTION  XgrSetClipboard (clipboard, clipType, text$, UBYTE image[])
	SHARED  xgrError
	SHARED  bufferText$[]
	SHARED	bufferImage[]
	UBYTE  temp[]
'
	IF ((clipboard < 0) OR (clipboard > 7)) THEN
		error = ($$ErrorObjectClipboard << 8) OR $$ErrorNatureInvalidNumber
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IF ((clipType < 1) OR (clipType > 2)) THEN
		error = ($$ErrorObjectClipboard << 8) OR $$ErrorNatureInvalidType
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	##WHOMASK = 0
'
	IFZ bufferText$[] THEN
		DIM bufferText$[7]
		DIM bufferImage[7,]
	END IF
'
	SELECT CASE clipType
		CASE 1	: IFZ clipboard THEN
								SetClipText (@text$)
							ELSE
								bufferText$[clipboard] = text$
							END IF
		CASE 2	: ATTACH bufferImage[clipboard,] TO temp[] : DIM temp[]
							IF image[] THEN
								upper = UBOUND (image[])
								bytes = SIZE (image[])
								DIM temp[upper]
								XstCopyMemory (&image[], &temp[], bytes)
								ATTACH temp[] TO bufferImage[clipboard,]
							END IF
	END SELECT
'
	##WHOMASK = whomask
END FUNCTION
'
'
' #############################
' #####  XgrSetCursor ()  #####
' #############################
'
FUNCTION  XgrSetCursor (cursor, oldCursor)
	SHARED  xgrError
	SHARED  cursorHandle[],  cursorPtr,  currentCursor,  overrideCursor
	SHARED  xgrInitialized
'
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	oldCursor = currentCursor
	IF ((cursor < 0) OR (cursor >= cursorPtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	currentCursor = cursor
	IFZ overrideCursor THEN
		hCursor = cursorHandle[cursor]
		entryWHOMASK = ##WHOMASK
		entryLOCKOUT = ##LOCKOUT
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		SetCursor (hCursor)
'		GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
		##LOCKOUT = entryLOCKOUT
		##WHOMASK = entryWHOMASK
	END IF
'	PRINT "XgrSetCursor() : hCursor, cursor, oldCursor, overrideCursor ="; hCursor, cursor, oldCursor, overrideCursor
END FUNCTION
'
'
' #####################################
' #####  XgrSetCursorOverride ()  #####
' #####################################
'
FUNCTION  XgrSetCursorOverride (cursor, oldOverrideCursor)
	SHARED  xgrError
	SHARED  cursorHandle[],  cursorPtr,  currentCursor,  overrideCursor
	SHARED  xgrInitialized
'
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	oldOverrideCursor = overrideCursor
	IF ((cursor < 0) OR (cursor >= cursorPtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IFZ cursor THEN
		hCursor = cursorHandle[currentCursor]
	ELSE
		hCursor = cursorHandle[cursor]
	END IF
	overrideCursor = cursor
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	SetCursor (hCursor)
'	GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'	PRINT "XgrSetCursorOverride() : hCursor, cursor, currentCursor, overrideCursor ="; hCursor, cursor, currentCursor, overrideCursor
END FUNCTION
'
'
' ########################################
' #####  XgrSystemWindowToWindow ()  #####
' ########################################
'
FUNCTION  XgrSystemWindowToWindow (swindow, @window, @top)
	SHARED  WINDOWINFO  windowInfo[]
'
	top = 0
	window = 0
	IFZ swindow THEN RETURN ($$TRUE)
	upper = UBOUND (windowInfo[])
'
	FOR i = 1 TO upper
		IF windowInfo[i].host THEN
			IF (windowInfo[i].hwnd = swindow) THEN
				window = i
				top = i
				EXIT FOR
			END IF
		END IF
	NEXT i
END FUNCTION
'
'
' ########################################
' #####  XgrWindowToSystemWindow ()  #####
' ########################################
'
FUNCTION  XgrWindowToSystemWindow (window, @swindow, @dx, @dy, @width, @height)
	SHARED  WINDOWINFO  windowInfo[]
'
	dx = 0
	dy = 0
	width = 0
	height = 0
	swindow = 0
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	width = windowInfo[window].width
	height = windowInfo[window].height
	swindow = windowInfo[window].hwnd
END FUNCTION
'
'
'	############################
'	#####  XgrVersion$ ()  #####
'	############################
'
FUNCTION  XgrVersion$ ()
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' #####################################
' #####  XgrConvertColorToRGB ()  #####
' #####################################
'
' Convert color to RGB
'
'	In:				color			RGBx
'
'	Out:			red				16-bit RGB
'						green
'						blue
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		Just extracts 16 bit RGB from 8-bit values in color
'
'		For XBasic standard 125 colors
'			colorNumber (0-124):
'			- red varies slowest, blue fastest
'			-	5 color levels each for RGB:  0000 4000 8000 C000 FFFF
'
FUNCTION  XgrConvertColorToRGB (color, red, green, blue)
'
	colorIndex = color{$$ColorNumber}
	IFZ colorIndex THEN													' colorIndex = 0, see RGB
		red		= color{$$R} << 8
		green	= color{$$G} << 8
		blue	= color{$$B} << 8
	ELSE																				' standard color
		IF (colorIndex > 124) THEN colorIndex = 124
'
'	avoid division
'
		SELECT CASE TRUE
			CASE (colorIndex >= 100)	: red = 0xFFFF	: igb = colorIndex - 100
			CASE (colorIndex >=  75)	: red = 0xC000	: igb = colorIndex -  75
			CASE (colorIndex >=  50)	: red = 0x8000	: igb = colorIndex -  50
			CASE (colorIndex >=  25)	: red = 0x4000	: igb = colorIndex -  25
			CASE ELSE									: red = 0x0000	: igb = colorIndex
		END SELECT
'
		SELECT CASE TRUE
			CASE (igb >= 20)	: green = 0xFFFF	: blue = (igb - 20) << 14
			CASE (igb >= 15)	: green = 0xC000	: blue = (igb - 15) << 14
			CASE (igb >= 10)	: green = 0x8000	: blue = (igb - 10) << 14
			CASE (igb >=  5)	: green = 0x4000	: blue = (igb -  5) << 14
			CASE ELSE					: green = 0x0000	: blue = igb        << 14
		END SELECT
'
		IF (blue > 0xFFFF) THEN blue = 0xFFFF
	END IF
END FUNCTION
'
'
' #####################################
' #####  XgrConvertRGBToColor ()  #####
' #####################################
'
' Convert RGB to color
'
'	In:				red				16-bit RGB
'						green
'						blue
'
'	Out:			color
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		32-bit word:  color = RGBx  with 8-bit R,G,B
'			x:  0					Not an XBasic color:  USE RGB
'			x:  1-124			An XBasic standard 125 colors (black = 0000)
'
'		For XBasic standard 124 colors
'			red green blue: compute index (0-124)
'			- red varies slowest, blue fastest
'			-	5 color levels each for RGB:  00 40 80 C0 FF
'
FUNCTION  XgrConvertRGBToColor (red, green, blue, color)

	color = (red{8,8} << 24) OR (green{8,8} << 16) OR (blue{8,8} << 8)
'
'	avoid division
'
	SELECT CASE red
		CASE 0xFFFF	:	number = 100
		CASE 0xC000	:	number =  75
		CASE 0x8000	:	number =  50
		CASE 0x4000	:	number =  25
		CASE 0x0000	:	number =   0
		CASE ELSE		:	RETURN ($$FALSE)
	END SELECT
'
	SELECT CASE green
		CASE 0xFFFF	:	number = number + 20
		CASE 0xC000	:	number = number + 15
		CASE 0x8000	:	number = number + 10
		CASE 0x4000	:	number = number + 5
		CASE 0x0000
		CASE ELSE		:	RETURN ($$FALSE)
	END SELECT
'
	SELECT CASE blue
		CASE 0xFFFF	:	number = number + 4
		CASE 0xC000	:	number = number + 3
		CASE 0x8000	:	number = number + 2
		CASE 0x4000	:	number = number + 1
		CASE 0x0000
		CASE ELSE		:	RETURN ($$FALSE)
	END SELECT
'
	color = color OR number
END FUNCTION
'
'
' ######################################
' #####  XgrGetBackgroundColor ()  #####
' ######################################
'
'	Gets current background color
'
'	In:				grid
'
'	Out:			color			RGBx of current background color
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		color		= 0				use 16 bit RGB
'		COLOR.x = 1-124		RGB == XBasic color of that number
'							0				RGB != XBasic color
'
FUNCTION  XgrGetBackgroundColor (grid, color)
	SHARED  GRIDINFO  gridInfo[]

	color = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)

	color	= gridInfo[grid].backColor											' 0-124
	IFZ color THEN																				' not an XBasic color
		red		= gridInfo[grid].backRed
		green	= gridInfo[grid].backGreen
		blue	= gridInfo[grid].backBlue
		color	= (red{8,8} << 24) OR (green{8,8} << 16) OR (blue{8,8} << 8)
	END IF
END FUNCTION
'
'
' ####################################
' #####  XgrGetBackgroundRGB ()  #####
' ####################################
'
'	Gets current background RGB
'
'	In:				grid
'
'	Out:			red
'						green
'						blue
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetBackgroundRGB (grid, red, green, blue)
	SHARED  GRIDINFO  gridInfo[]

	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
'	RGB is not kept up to date if an XBasic color
'
	color	= gridInfo[grid].backColor											' 0-124
	IFZ color THEN																				' not an XBasic color
		red		= gridInfo[grid].backRed
		green	= gridInfo[grid].backGreen
		blue	= gridInfo[grid].backBlue
	ELSE
		XgrConvertColorToRGB (color, @red, @green, @blue)
	END IF
END FUNCTION
'
'
' ####################################
' #####  XgrGetDefaultColors ()  #####
' ####################################
'
'	Gets current default colors
'
'	Out:			back				all are 32-bit XBasic colors
'						draw					(-1 means "don't change")
'						low
'						high
'						dull
'						acc
'						lowText
'						highText
'
'	Return:		$$FALSE				no errors
'						$$TRUE				error
'
FUNCTION  XgrGetDefaultColors (back, draw, lo, hi, dull, acc, lowText, highText)
	SHARED  defaultBackground
	SHARED  defaultDrawing
	SHARED  defaultLowlight
	SHARED  defaultHighlight
	SHARED  defaultDull
	SHARED  defaultAccent
	SHARED	defaultLowText
	SHARED	defaultHighText
'
	back			= defaultBackground
	draw			= defaultDrawing
	lo				= defaultLowlight
	hi				= defaultHighlight
	dull			= defaultDull
	acc				= defaultAccent
	lowText		= defaultLowText
	highText	= defaultHighText
END FUNCTION
'
'
' ###################################
' #####  XgrGetDrawingColor ()  #####
' ###################################
'
'	Gets current drawing color
'
'	In:				grid
'
'	Out:			color			RGBx of current drawing color
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		color		= 0				use 16 bit RGB
'		COLOR.x = 1-124		RGB == XBasic color of that number
'							0				RGB != XBasic color
'
FUNCTION  XgrGetDrawingColor (grid, color)
	SHARED  GRIDINFO  gridInfo[]

	color = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)

	color	= gridInfo[grid].drawColor											' 0-124
	IFZ color THEN																				' not an XBasic color
		red		= gridInfo[grid].drawRed
		green	= gridInfo[grid].drawGreen
		blue	= gridInfo[grid].drawBlue
		color	= (red{8,8} << 24) OR (green{8,8} << 16) OR (blue{8,8} << 8)
	END IF
END FUNCTION
'
'
' #################################
' #####  XgrGetDrawingRGB ()  #####
' #################################
'
'	Gets current drawing RGB
'
'	In:				grid
'
'	Out:			red
'						green
'						blue
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetDrawingRGB (grid, red, green, blue)
	SHARED  GRIDINFO  gridInfo[]
'
	red = 0:  green = 0:  blue = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
'	RGB is not kept up to date if an XBasic color
'
	color	= gridInfo[grid].drawColor											' 0-124
	IFZ color THEN																				' not an XBasic color
		red		= gridInfo[grid].drawRed
		green	= gridInfo[grid].drawGreen
		blue	= gridInfo[grid].drawBlue
	ELSE
		XgrConvertColorToRGB (color, @red, @green, @blue)
	END IF
END FUNCTION
'
'
' #################################
' #####  XgrGetGridColors ()  #####
' #################################
'
'	Gets current grid colors
'
'	In:				grid
'
'	Out:			back				all as 32-bit XBasic colors
'						draw
'						low
'						high
'						dull
'						acc
'           lowText
'						highText
'
'	Return:		$$FALSE				no errors
'						$$TRUE				error
'
FUNCTION  XgrGetGridColors (grid, back, draw, lo, hi, dull, acc, lowText, highText)
	SHARED  GRIDINFO  gridInfo[]
'
	back = 0 : draw = 0 : lo = 0 : hi = 0 : dull = 0 : acc = 0 : lowText = 0 : highText = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	back = gridInfo[grid].backColor
	IFZ back THEN																				' not an XBasic color
		red		= gridInfo[grid].backRed
		green	= gridInfo[grid].backGreen
		blue	= gridInfo[grid].backBlue
		back = (red{8,8} << 24) OR (green{8,8} << 16) OR (blue{8,8} << 8)
	END IF
	draw = gridInfo[grid].drawColor
	IFZ draw THEN																				' not an XBasic color
		red		= gridInfo[grid].drawRed
		green	= gridInfo[grid].drawGreen
		blue	= gridInfo[grid].drawBlue
		draw = (red{8,8} << 24) OR (green{8,8} << 16) OR (blue{8,8} << 8)
	END IF
'
	lo				= gridInfo[grid].lowColor
	hi				= gridInfo[grid].highColor
	dull			= gridInfo[grid].dullColor
	acc				= gridInfo[grid].accentColor
	lowText		= gridInfo[grid].lowTextColor
	highText	= gridInfo[grid].highTextColor
END FUNCTION
'
'
' ######################################
' #####  XgrSetBackgroundColor ()  #####
' ######################################
'
'	Sets background color from color
'
'	In:				grid
'						color			RGBx
'
'	Out:			none			args unchanged
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		If color = -1, do nothing
'
FUNCTION  XgrSetBackgroundColor (grid, color)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  colorPixel[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ (NOT color) THEN RETURN ($$FALSE)					' RGBx = -1: use current color
'
'	Set the background color
'
	colorIndex = color{$$ColorNumber}
	SELECT CASE FALSE
		CASE colorIndex																' x = 0:  use RGB
			red		= color{$$R}
			green	= color{$$G}
			blue	= color{$$B}
			pixel = (blue << 16) OR (green << 8) OR red
			gridInfo[grid].backRed	 = red		<< 8
			gridInfo[grid].backGreen = green	<< 8
			gridInfo[grid].backBlue	 = blue		<< 8

		CASE ELSE																			' x != 0:  use 1-124
			IF (colorIndex > 124) THEN colorIndex = 124
			pixel = colorPixel[colorIndex]
	END SELECT

	gridInfo[grid].backColor			= colorIndex			' rgb 'undefined' if 1-124
	gridInfo[grid].sysBackground	= pixel
END FUNCTION
'
'
' ####################################
' #####  XgrSetBackgroundRGB ()  #####
' ####################################
'
'	Sets background color from 16-bit RGB
'
'	In:				grid
'						red				RGB
'						green
'						blue
'
'	Out:			none			args unchanged
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrSetBackgroundRGB (grid, red, green, blue)
	SHARED  GRIDINFO  gridInfo[]

	IF InvalidGrid (grid) THEN RETURN ($$TRUE)

	pixel = (blue{8,8} << 16) OR (green{8,8} << 8) OR red{8,8}

	gridInfo[grid].backRed				= red{16,0}
	gridInfo[grid].backGreen			= green{16,0}
	gridInfo[grid].backBlue				= blue{16,0}
	gridInfo[grid].backColor			= 0							' don't take time to see if 1-124
	gridInfo[grid].sysBackground	= pixel
END FUNCTION
'
'
' ####################################
' #####  XgrSetDefaultColors ()  #####
' ####################################
'
'	Sets current default colors
'
'	In:				back			all are 32-bit XBasic colors
'						draw				(-1 means "don't change")
'						low
'						high
'						dull
'						acc
'						lowText
'						highText
'
'	Out:			none					args unchanged
'
'	Return:		$$FALSE				no errors
'						$$TRUE				error
'
FUNCTION  XgrSetDefaultColors (back, draw, lo, hi, dull, acc, lowText, highText)
	SHARED  defaultBackground
	SHARED  defaultDrawing
	SHARED  defaultLowlight
	SHARED  defaultHighlight
	SHARED  defaultDull
	SHARED  defaultAccent
	SHARED	defaultLowText
	SHARED	defaultHighText
'
	IF (back			!= -1) THEN defaultBackground	= back
	IF (draw			!= -1) THEN defaultDrawing		= draw
	IF (lo				!= -1) THEN defaultLowlight		= lo
	IF (hi				!= -1) THEN defaultHighlight	= hi
	IF (dull			!= -1) THEN defaultDull				= dull
	IF (acc				!= -1) THEN defaultAccent			= acc
	IF (lowText		!= -1) THEN defaultLowText		= lowText
	IF (highText	!= -1) THEN defaultHighText		= highText
END FUNCTION
'
'
' ###################################
' #####  XgrSetDrawingColor ()  #####
' ###################################
'
'	Sets drawing color
'
'	In:				grid
'						color			RGBx
'
'	Out:			none			args unchanged
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		If color = -1, do nothing
'
FUNCTION  XgrSetDrawingColor (grid, color)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  colorPixel[]

	IF InvalidGrid (grid) THEN RETURN ($$TRUE)

	IFZ (NOT color) THEN RETURN ($$FALSE)					' RGBx = -1: use current color
'
'	Set the drawing color
'
	colorIndex = color{$$ColorNumber}
	SELECT CASE FALSE
		CASE colorIndex																' x = 0:  use RGB
			red		= color{$$R}
			green	= color{$$G}
			blue	= color{$$B}
			pixel = (blue << 16) OR (green << 8) OR red
			gridInfo[grid].drawRed		= red		<< 8
			gridInfo[grid].drawGreen	= green	<< 8
			gridInfo[grid].drawBlue		= blue	<< 8
		CASE ELSE																			' x != 0:  use 1-124
			IF (colorIndex > 124) THEN colorIndex = 124
			pixel = colorPixel[colorIndex]
	END SELECT

	gridInfo[grid].drawColor	= colorIndex
	gridInfo[grid].sysDrawing	= pixel
END FUNCTION
'
'
' #################################
' #####  XgrSetDrawingRGB ()  #####
' #################################
'
'	Sets drawing color
'
'	In:				grid
'						red				RGB
'						green
'						blue
'
'	Out:			none			args unchanged
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrSetDrawingRGB (grid, red, green, blue)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	pixel = (blue{8,8} << 16) OR (green{8,8} << 8) OR red{8,8}
'
	gridInfo[grid].drawRed		= red{16,0}
	gridInfo[grid].drawGreen	= green{16,0}
	gridInfo[grid].drawBlue		= blue{16,0}
	gridInfo[grid].drawColor	= 0								' don't take time to see if 1-124
	gridInfo[grid].sysDrawing	= pixel
END FUNCTION
'
'
' #################################
' #####  XgrSetGridColors ()  #####
' #################################
'
'	Sets current grid colors
'
'	In:				grid
'						back			all are 32-bit XBasic colors
'						draw				(-1 means "don't change")
'						low
'						high
'						dull
'						acc
'						lowText
'						highText
'
'	Out:			none					args unchanged
'
'	Return:		$$FALSE				no errors
'						$$TRUE				error
'
FUNCTION  XgrSetGridColors (grid, back, draw, lo, hi, dull, acc, lowText, highText)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  colorPixel[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IF (back != -1) THEN
		colorIndex = back{$$ColorNumber}
		SELECT CASE FALSE
			CASE colorIndex																' x = 0:  use RGB
				red		= back{$$R}
				green	= back{$$G}
				blue	= back{$$B}
				pixel = (blue << 16) OR (green << 8) OR red
				gridInfo[grid].backRed	 = red		<< 8
				gridInfo[grid].backGreen = green	<< 8
				gridInfo[grid].backBlue	 = blue		<< 8
			CASE ELSE																			' x != 0:  use 1-124
				IF (colorIndex > 124) THEN colorIndex = 124
				pixel = colorPixel[colorIndex]
		END SELECT
		gridInfo[grid].backColor			= colorIndex			' rgb 'undefined' if 1-124
		gridInfo[grid].sysBackground	= pixel
	END IF
'
	IF (draw != -1) THEN
		colorIndex = draw{$$ColorNumber}
		SELECT CASE FALSE
			CASE colorIndex																' x = 0:  use RGB
				red		= draw{$$R}
				green	= draw{$$G}
				blue	= draw{$$B}
				pixel = (blue << 16) OR (green << 8) OR red
				gridInfo[grid].drawRed	 = red		<< 8
				gridInfo[grid].drawGreen = green	<< 8
				gridInfo[grid].drawBlue	 = blue		<< 8
			CASE ELSE																			' x != 0:  use 1-124
				IF (colorIndex > 124) THEN colorIndex = 124
				pixel = colorPixel[colorIndex]
		END SELECT
		gridInfo[grid].drawColor	= colorIndex					' rgb 'undefined' if 1-124
		gridInfo[grid].sysDrawing	= pixel
	END IF
'
	IF (lo				!= -1) THEN gridInfo[grid].lowColor				= lo
	IF (hi				!= -1) THEN gridInfo[grid].highColor			= hi
	IF (dull			!= -1) THEN gridInfo[grid].dullColor			= dull
	IF (acc				!= -1) THEN gridInfo[grid].accentColor		= acc
	IF (lowText		!= -1) THEN gridInfo[grid].lowTextColor		= lowText
	IF (highText	!= -1) THEN gridInfo[grid].highTextColor	= highText
END FUNCTION
'
'
' ###############################
' #####  XgrClearWindow ()  #####
' ###############################
'
'	Fill window with color
'
'	In:				window
'						color			RGBx
'	Out:			none			args unchanged
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		Sets 'window color'
'		Does not XOR or clip
'		Does not clear associated images
'
'	NT issues:
'		PatBlt			= .0003090 sec (50x50)
'		FillRect		= .0003240 sec
'		Rectangle		= .0059650 sec --- !!! 20x slower !!!
'
'		PatBlt/FillRect ONLY work on COPY drawmode (not XOR, etc)
'		PatBlt says it may not work on all systems, so:
'			use FillRect for COPY and Rectangle for all else.
'
FUNCTION  XgrClearWindow (window, color)
	SHARED  WINDOWINFO  windowInfo[]
	STATIC  RECT  rect
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IF (windowInfo[window].visible = $$WindowMinimized) THEN RETURN ($$FALSE)
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hdc = windowInfo[window].hdc
'
'	Set color
'
	SetWindowBrush (window, color)
'
'	Draw mode irrelevant for FillRect()
'
'	No clipping
'
	IF (windowInfo[window].clipGrid != 0) THEN
		SetGridClip (window, 0)
	END IF
'
	rect.left = 0
	rect.top = 0
	rect.right = windowInfo[window].width
	rect.bottom = windowInfo[window].height
	##LOCKOUT = $$TRUE
	FillRect (hdc, &rect, windowInfo[window].fgBrush)
'	GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ########################################
' #####  XgrClearWindowAndImages ()  #####
' ########################################
'
FUNCTION  XgrClearWindowAndImages (window, color)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  winGrid[]
	SHARED  GT_Image
	STATIC  RECT  rect
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hdc = windowInfo[window].hdc
'
'	Set color
'
	SetWindowBrush (window, color)
'
'	Draw mode irrelevant for FillRect()
'
'	No clipping
'
	IF (windowInfo[window].clipGrid != 0) THEN
		SetGridClip (window, 0)
	END IF
'
	fgBrush = windowInfo[window].fgBrush
	rect.left = 0
	rect.top = 0
	rect.right = windowInfo[window].width
	rect.bottom = windowInfo[window].height
	IF (windowInfo[window].visible != $$WindowMinimized) THEN
		##LOCKOUT = $$TRUE
		FillRect (hdc, &rect, fgBrush)
'		GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	Clear all images
'
	IF winGrid[window,] THEN
		FOR i = 0 TO UBOUND(winGrid[window,])
			grid = winGrid[window,i]
			IFZ grid THEN DO NEXT
			IF (gridInfo[grid].gridType = GT_Image) THEN
				sysImage = gridInfo[grid].sysImage
				IFZ sysImage THEN										'	if not, make sysImage
					CreateSysImage (grid, @sysImage)
					IFZ sysImage THEN DO NEXT					' problem with sysImage
				ELSE
					UpdateSysImage (grid)
				END IF
				SetImageClip (window, 0, grid)			' No clipping
				IFF ntImageInfo.clipIsNull THEN
					hdcImage = ntImageInfo.hdcImage
					rect.left = 0
					rect.top = 0
					rect.right = gridInfo[grid].width
					rect.bottom = gridInfo[grid].height
					##LOCKOUT = $$TRUE
					FillRect (hdcImage, &rect, fgBrush)
					##LOCKOUT = entryLOCKOUT
				END IF
			END IF
		NEXT i
	END IF

	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ################################
' #####  XgrCreateWindow ()  #####
' ################################
'
'	Create a graphics window on a specified display$
'
'	In:				windowType
'						xDisp					requested x,y of window BORDER in display coordinates
'						yDisp						(-1, or invalid value -> no preference)
'						width					requested width, height of window INTERIOR in pixels
'						height
'						winFunc				address of window function
'						display$			display name : machine:display.screen : as in "fred:0.0"
'													"" for default display
'
'	Out:			window
'						display$			default display name if display$ = ""
'
'	Return:		$$FALSE				no errors
'						$$TRUE				error
'
'	windowType:	bits  0-15 = parentWindow
'							bits 16-31 = windowType (see $$Window... constants)
'
'							0x0000xxxx	= default windowType
'													= ResizeFrame, TitleBar, Minimize, Maximize
'
FUNCTION  XgrCreateWindow (window, windowType, xDisp, yDisp, width, height, winFunc, display$)
	SHARED	I_Window
	SHARED  xgrError
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  hostWin[]
	SHARED  sysFontNames$[]
	SHARED  sysFontNames
	SHARED  FONTINFO  fontInfo[]
	SHARED  defaultFont
	SHARED  fontWindow
	SHARED  hdcFont
	SHARED  winGrid[]
	SHARED  xgrInitialized
	SHARED  alarmBlocked
	SHARED  LOGFONT  sysFontInfo[]
	SHARED	iconHandle[]
	STATIC  WNDCLASS  windowClass
	STATIC  notFirstEntry
	STATIC  POINT  point
	STATIC  RECT  rect
	STATIC  TEXTMETRIC  textMetric
'
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		EXIT FUNCTION ($$TRUE)
	END IF
'
'	Turn off alarm while creating window
'
	entryAlarmBlock = alarmBlocked
	IFF alarmBlocked THEN AlarmBlock ()
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0														' protect Windows allocations
'
	IFF notFirstEntry THEN GOSUB Initialize
'
'	Open the display (multiple displays not supported in WindowsNT)
'
	host = OpenDisplay (@display$)
	IFZ host THEN
		IFF entryAlarmBlock THEN AlarmUnblock ()
		##WHOMASK = entryWHOMASK
		EXIT FUNCTION ($$TRUE)
	END IF
'
'	Adjust xy/width/height for window border size
'
	x = xDisp
	y = yDisp
	w = MAX(width, 1)																	' get that last pixel
	h = MAX(height,1)
	setPosition = $$TRUE
	IF ((x = -1) OR (y = -1)) THEN
		x = $$CW_USEDEFAULT
		y = $$CW_USEDEFAULT
		setPosition = $$FALSE
	END IF
'
'	Default title is application name
'
	XstGetCommandLineArguments (@argc, @argv$[])
	IF argv$[] THEN title$ = argv$[0]
	IFZ title$ THEN title$ = "???"
'
'	Create class/style window
'
	hwnd = 0
	class	= &"XBasicWindow"

	parent = windowType{$$WORD0}
	wt = windowType AND 0xFFFF0000
	IFZ wt THEN																	' default windowType
		wt = $$WindowTypeResizeFrame OR $$WindowTypeTitleBar OR $$WindowTypeMinimizeBox OR $$WindowTypeMaximizeBox OR $$WindowTypeSystemMenu
	ELSE
		IF (wt AND ($$WindowTypeSystemMenu OR $$WindowTypeMinimizeBox OR $$WindowTypeMaximizeBox)) THEN
			wt = wt OR $$WindowTypeTitleBar
		END IF
		IF (wt AND $$WindowTypeTitleBar) THEN
			wt = wt OR $$WindowTypeResizeFrame
		END IF
		IF (wt AND $$WindowTypeResizeFrame) THEN
			wt = wt AND (NOT $$WindowTypeNoFrame)
		END IF
	END IF
	windowType = wt OR parent										' Fill bits for calling function
'
	exStyle = 0
'
	SELECT CASE TRUE
		CASE (windowType AND $$WindowTypeTitleBar)
			style = $$WS_CAPTION OR $$WS_THICKFRAME					' Title Bar / frame
			SELECT CASE ALL TRUE
				CASE (windowType AND $$WindowTypeMaximizeBox):	style = style OR $$WS_MAXIMIZEBOX
				CASE (windowType AND $$WindowTypeMinimizeBox):	style = style OR $$WS_MINIMIZEBOX
				CASE (windowType AND $$WindowTypeSystemMenu):		style = style OR $$WS_SYSMENU
			END SELECT
'
			borderWidth = hostDisplay[host].borderWidth			' adjust xywh for border
			titleHeight = hostDisplay[host].titleHeight
			w = w + (borderWidth << 1)
			h = h + (borderWidth << 1) + titleHeight
			IF setPosition THEN
				x = x - borderWidth
				y = y - borderWidth - titleHeight
			END IF
'
		CASE (windowType AND $$WindowTypeResizeFrame)
			style = $$WS_POPUP OR $$WS_THICKFRAME OR $$WS_BORDER
			borderWidth = hostDisplay[host].borderWidth			' adjust xywh for border
			w = w + (borderWidth << 1)
			h = h + (borderWidth << 1)
			IF setPosition THEN
				x = x - borderWidth
				y = y - borderWidth
			END IF
'
		CASE ELSE																					' no frame
			style = $$WS_POPUP															' POPUP removes TitleBar
			IF (windowType AND $$WindowTypeNoIcon) THEN
				IF (windowType AND $$WindowTypeNoFrame) THEN
					exStyle = $$WS_EX_TOOLWINDOW                                                                            ' No taskbar icon
				END IF
			ELSE
'				PRINT "Icon wanted, make it display in the taskbar, default"
			END IF
	END SELECT
'
	IF (windowType AND $$WindowTypeTopMost) THEN
		IFZ exStyle THEN
			exStyle = $$WS_EX_TOPMOST
		ELSE
			exStyle = $$WS_EX_TOPMOST OR $$WS_EX_TOOLWINDOW
		END IF
	END IF
'
	hwnd = CreateWindowExA (exStyle, class, &title$, style, x, y, w, h, 0, 0, ##HINSTANCE, 0)
	XgrProcessMessages (-2)						' Clear queue
'
	IFZ hwnd THEN
		IFF entryAlarmBlock THEN AlarmUnblock ()
		xgrError = $$XgrCannotOpenDisplay
		##WHOMASK = entryWHOMASK
		EXIT FUNCTION ($$TRUE)
	END IF
'
'	Get actual window xywh
'
	point.x = 0
	point.y = 0
	ClientToScreen (hwnd, &point)
	xDisp = point.x
	yDisp = point.y
'
	GetClientRect (hwnd, &rect)
	width = rect.right - rect.left
	height = rect.bottom - rect.top
'
'	Assign window number (1,2,...)		(window 0 is invalid window number)
'		Find lowest windowInfo slot
'
	IFZ windowInfo[] THEN
		window = 1
		DIM windowInfo[7]								' [window].host = 0:  all windows unused
		DIM winGrid[7,]									' [window,] = 0:			no grids open
	ELSE
		window = 0
		uWindow = UBOUND(windowInfo[])
		FOR i = 1 TO uWindow
			IFZ windowInfo[i].host THEN
				window = i
				EXIT FOR
			END IF
		NEXT i
		IFZ window THEN
			window = uWindow + 1
			uWindow = (uWindow << 1) OR 7
			REDIM windowInfo[uWindow]			' [window].host = 0:  all new windows unused
			REDIM winGrid[uWindow,]				' [window,] = 0:			no grids open
		END IF
	END IF
'
'	Add window to hostWin[] list
'
	uHost = UBOUND(hostDisplay[])
	IFZ hostWin[] THEN
		REDIM hostWin[uHost,]
	ELSE
		IF (uHost > UBOUND(hostWin[])) THEN
			REDIM hostWin[uHost,]
		END IF
	END IF
	IFZ hostWin[host,] THEN
		DIM temp[7]
		ATTACH temp[] TO hostWin[host,]
		i = 0
	ELSE
		uHostWin = UBOUND(hostWin[host,])
		FOR i = 0 TO uHostWin
			IFZ hostWin[host,i] THEN EXIT FOR
		NEXT i
		IF (i > uHostWin) THEN
			i = uHostWin + 1
			uHostWin = (uHostWin + 8) OR 7
			ATTACH hostWin[host,] TO temp[]
			REDIM temp[uHostWin]
			ATTACH temp[] TO hostWin[host,]
		END IF
	END IF
	hostWin[host,i] = window
	IFZ fontWindow THEN fontWindow = window
'
'	Get window's display context : set default to TRANSPARENT background
'
	hdc = GetDC (hwnd)
	SetBkMode (hdc, $$TRANSPARENT)
'
'	Fill window information array
'
	windowInfo[window].host								= host				' also says window in use
	windowInfo[window].windowType					= windowType AND 0xFFFF0000
	windowInfo[window].parent							= parent
	windowInfo[window].hwnd								= hwnd
	windowInfo[window].whomask						= entryWHOMASK
	windowInfo[window].hdc								= hdc
	windowInfo[window].func								= winFunc
	windowInfo[window].xDisp							= xDisp				' of drawing area
	windowInfo[window].yDisp							= yDisp
	windowInfo[window].width							= width				' of interior
	windowInfo[window].height							= height
	windowInfo[window].icon								= 0						' default icon
	windowInfo[window].font								= defaultFont
	windowInfo[window].drawMode						= $$DrawCOPY
	windowInfo[window].lineWidth					= 1
	windowInfo[window].lineStyle					= 0						' Solid
	windowInfo[window].visible						= $$WindowHidden
	windowInfo[window].priorVisible				= 0
	windowInfo[window].clipGrid						= 0
	windowInfo[window].xClip							= 0
	windowInfo[window].yClip							= 0
	windowInfo[window].clipWidth					= 0
	windowInfo[window].clipHeight					= 0
	windowInfo[window].winPixel						= -2
	windowInfo[window].bgPixel						= -2
	windowInfo[window].fgBrushPixel				= -2
	windowInfo[window].fgBrush						= -2
	windowInfo[window].fgPenPixel					= -2
	windowInfo[window].fgPen							= -2
	windowInfo[window].textPixel          = -2
'
'	Initialize font (requires an hdc)
'
'	hdcFont MUST be defined by XgrCreateWindow() for use in
'	XgrCreateFont() : which is ALWAYS called during initialization
'
	IFZ fontInfo[] THEN
		hdcFont = hdc
		LoadFonts (hdcFont)
		XgrCreateFont (@defaultFont, "", 0, 0, 0, 0)
		IF sysFontNames THEN
			FOR i = 0 TO sysFontNames-1
				IF (sysFontNames$[i] = "Courier New") THEN
					XgrCreateFont (@courierFont, "Courier New", 280, 600, $$FALSE, 0)
'					IF courierFont THEN defaultFont = courierFont
					EXIT FOR
				END IF
			NEXT i
		END IF
	END IF
	hFontOld = SelectObject (hdc, fontInfo[defaultFont].hFont)
	IF hFontOld THEN DeleteObject (hFontOld)
'
	IFF notFirstEntry THEN
		notFirstEntry = $$TRUE
		windowInfo[window].icon = I_Window
		hwnd = windowInfo[window].hwnd
		iconHandle = iconHandle[I_Window]
'
'	##WHOMASK = entryWHOMASK
'	RETURN ($$FALSE)
'
' the following changes icons for ALL windows
'
		IF iconHandle THEN
			entryLOCKOUT = ##LOCKOUT
			##LOCKOUT = $$TRUE
			SetClassLongA (hwnd, $$GCL_HICON, iconHandle)
			##LOCKOUT = entryLOCKOUT
		END IF
	END IF
'
	XgrProcessMessages (-2)											' Clear queue
	##WHOMASK = entryWHOMASK
	IFF entryAlarmBlock THEN AlarmUnblock ()
	RETURN ($$FALSE)
'
'	*****  Initialize  *****
'
SUB Initialize
'	notFirstEntry = $$TRUE
	windowClass.style					= $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	windowClass.lpfnWndProc		= &WinProc()
	windowClass.cbClsExtra		= 0
	windowClass.cbWndExtra		= 0
	windowClass.hInstance			= ##HINSTANCE
'	windowClass.hIcon					= LoadIconA (##HINSTANCE, &"window")
	windowClass.hIcon					= 0								' Allow icon to be changed
	windowClass.hCursor				= 0								' Allow cursor to be changed
	windowClass.hbrBackground	= 0								' Don't paint background on expose
	windowClass.lpszMenuName	= 0
	windowClass.lpszClassName	= &"XBasicWindow"
	RegisterClassA (windowClass)
END SUB
END FUNCTION
'
'
' #################################
' #####  XgrDestroyWindow ()  #####
' #################################
'
FUNCTION  XgrDestroyWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED	modalWindowSystem
	SHARED	modalWindowUser
	SHARED  hostWin[]
	SHARED  winGrid[]
	SHARED  textSelectionGrid
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IF (window = modalWindowUser) THEN XgrSetModalWindow (0)
	IF (window = modalWindowSystem) THEN XgrSetModalWindow (0)
'
	entryALARMBUSY = ##ALARMBUSY
	##ALARMBUSY	= $$TRUE
'
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0															' protect system allocations
'
	host = windowInfo[window].host
	hwnd = windowInfo[window].hwnd
'
'	Save .func for #WindowDestroyed
'
	func = windowInfo[window].func
'
	windowInfo[window].host = 0								' window is now available
	windowInfo[window].func = 0
'
	GOSUB WasteGrids
'
' Seems like XgrProcessMessages() should be called with entry whomask.
' If the user called this function, the user queue will not be flushed
' by the following XgrProcessMessages() and thus trash might still exist.
'
	DestroyWindow (hwnd)											' destroy the window
'	##WHOMASK = entryWHOMASK									' ???  added 95 Feb 07
	XgrProcessMessages (-2)										' clear queue
'	##WHOMASK = 0															' ???  added 95 Feb 07
'
'	Remove window from host list
'
	uHostWin = UBOUND(hostWin[host,])
	FOR i = 0 TO uHostWin
		IF (window = hostWin[host,i]) THEN hostWin[host,i] = 0
	NEXT i
'
'	Send #WindowDestroyed message (eg Xui clears its grid arrays)
'
	IFZ ##BLOWBACK THEN
		IF func THEN @func (window, #WindowDestroyed, func, 0, 0, 0, 0, 0)
	END IF
'
'	Destroy any kid windows
'
	uHostWin = UBOUND(hostWin[host,])
	FOR i = 0 TO uHostWin
		iWindow = hostWin[host,i]
		IFZ iWindow THEN DO NEXT
		parent = windowInfo[iWindow].parent
		windowType = windowInfo[iWindow].windowType
		IF ((windowType > 0) AND (window = parent)) THEN
			XgrDestroyWindow (iWindow)
		END IF
	NEXT i
'
	##WHOMASK = entryWHOMASK
	##ALARMBUSY = entryALARMBUSY
	RETURN ($$FALSE)
'
'	*****  WasteGrids  *****  Waste grids associated with destroyed window
'
SUB WasteGrids
	IF winGrid[window,] THEN
		uWinGrid = UBOUND(winGrid[window,])
		FOR j = 0 TO uWinGrid
			grid = winGrid[window,j]
			IFZ grid THEN DO NEXT
			IFZ gridInfo[grid].grid THEN DO NEXT						' already dead
			gridInfo[grid].grid = 0													' grid
			IF (grid = textSelectionGrid) THEN textSelectionGrid = 0
			timeOutID = gridInfo[grid].timeOutID
			IF timeOutID THEN KillTimer (windowInfo[window].hwnd, grid)
			sysImage = gridInfo[grid].sysImage
			IF sysImage THEN DestroySysImage (grid, sysImage)
		NEXT j
		ATTACH winGrid[window,] TO temp[]								' waste winGrid[window,]
		DIM temp[]
	END IF
END SUB
END FUNCTION
'
'
' #################################
' #####  XgrDisplayWindow ()  #####
' #################################
'
FUNCTION  XgrDisplayWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
'
'	PRINT "XgrDisplayWindow() : queue #WindowDisplayed : "; window
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hwnd = windowInfo[window].hwnd
	visible = windowInfo[window].visible
	windowInfo[window].visible = $$WindowDisplayed
	windowType = windowInfo[window].windowType
'
	stackAction = $$HWND_TOP
	action = $$SWP_SHOWWINDOW OR $$SWP_NOMOVE OR $$SWP_NOSIZE
	IF (windowType AND $$WindowTypeNoSelect) THEN action = action OR $$SWP_NOACTIVATE
'
	##LOCKOUT = $$TRUE
	SetWindowPos (hwnd, stackAction, 0, 0, 0, 0, action)
	UpdateWindow (hwnd)
'
	IF IsZoomed (hwnd) THEN
		ShowWindow (hwnd, $$SW_RESTORE)
		UpdateWindow (hwnd)
	END IF
'
	IF IsIconic (hwnd) THEN
		ShowWindow (hwnd, $$SW_RESTORE)
		UpdateWindow (hwnd)
		IF IsIconic (hwnd) THEN PRINT "XgrDisplayWindow() : Disaster : stuck iconic"
	END IF
'
	##LOCKOUT = entryLOCKOUT
	WindowInfo (window, 0, 0, 0, 0)							' update window position/size
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##################################
' #####  XgrGetModalWindow ()  #####
' ##################################
'
FUNCTION  XgrGetModalWindow (window)
	SHARED	modalWindowSystem
	SHARED	modalWindowUser
'
	IF ##WHOMASK THEN window = modalWindowUser ELSE window = modalWindowSystem
END FUNCTION
'
'
' ####################################
' #####  XgrGetWindowDisplay ()  #####
' ####################################
'
FUNCTION  XgrGetWindowDisplay (window, display$)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  hostDisplayName$[]
'
	display$ = ""
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IFZ hostDisplayName$[] THEN RETURN ($$TRUE)
	upper = UBOUND (hostDisplayName$[])
	host = windowInfo[window].host
'
	IF (host > upper) THEN RETURN ($$TRUE)
	display$ = hostDisplayName$[i]
END FUNCTION
'
'
' #####################################
' #####  XgrGetWindowFunction ()  #####
' #####################################
'
FUNCTION  XgrGetWindowFunction (window, func)
	SHARED  WINDOWINFO  windowInfo[]
'
	func = 0
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	func = windowInfo[window].func
END FUNCTION
'
'
' #################################
' #####  XgrGetWindowGrid ()  #####
' #################################
'
FUNCTION  XgrGetWindowGrid (window, grid)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  winGrid[]
'
	grid = 0
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IFZ winGrid[window,] THEN RETURN ($$FALSE)
	grid = winGrid[window,0]
END FUNCTION
'
'
' #################################
' #####  XgrGetWindowIcon ()  #####
' #################################
'
FUNCTION  XgrGetWindowIcon (window, icon)
	SHARED  WINDOWINFO  windowInfo[]
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	icon = windowInfo[window].icon
END FUNCTION
'
'
' ############################################
' #####  XgrGetWindowPositionAndSize ()  #####
' ############################################
'
FUNCTION  XgrGetWindowPositionAndSize (window, xDisp, yDisp, width, height)
	SHARED  WINDOWINFO  windowInfo[]
'
	xDisp = 0:  yDisp = 0:  width = 0:  height = 0
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	WindowInfo (window, @xDisp, @yDisp, @width, @height)
END FUNCTION
'
'
' ##################################
' #####  XgrGetWindowState ()  #####
' ##################################
'
FUNCTION  XgrGetWindowState (window, state)
	SHARED  WINDOWINFO  windowInfo[]
'
	state = 0
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	state = windowInfo[window].visible
END FUNCTION
'
'
' ##################################
' #####  XgrGetWindowTitle ()  #####
' ##################################
'
FUNCTION  XgrGetWindowTitle (window, title$)
	SHARED  WINDOWINFO  windowInfo[]
'
	title$ = ""
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hwnd = windowInfo[window].hwnd
	##LOCKOUT = $$TRUE
	lenTitle = GetWindowTextLengthA(hwnd)
	##LOCKOUT = entryLOCKOUT
'
	##WHOMASK = entryWHOMASK
	title$ = NULL$(lenTitle)												' allocates terminating NULL
	##WHOMASK = 0
'
	##LOCKOUT = $$TRUE
	GetWindowTextA (hwnd, &title$, lenTitle + 1)		' include NULL
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##############################
' #####  XgrHideWindow ()  #####
' ##############################
'
FUNCTION  XgrHideWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED	modalWindowSystem
	SHARED	modalWindowUser
'
'	PRINT "XgrHideWindow() : queue #WindowHidden : "; window
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IF (window = modalWindowUser) THEN RETURN ($$TRUE)		' was XgrSetModalWindow (0)
	IF (window = modalWindowSystem) THEN RETURN ($$TRUE)	' was XgrSetModalWindow (0)
'
	visible = windowInfo[window].visible
	hwnd = windowInfo[window].hwnd
	windowInfo[window].priorVisible = visible
	windowInfo[window].visible = $$WindowHidden
	XgrAddMessage (window, #WindowHidden, $$WindowHidden, 0, 0, 0, 0, 0)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	ShowWindow (hwnd, $$SW_HIDE)
	UpdateWindow (hwnd)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##################################
' #####  XgrMaximizeWindow ()  #####
' ##################################
'
FUNCTION  XgrMaximizeWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
'
'	PRINT "XgrMaximizeWindow() : queue #WindowMaximized : "; window
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hwnd = windowInfo[window].hwnd
	visible = windowInfo[window].visible
	windowInfo[window].visible = $$WindowMaximized
	##LOCKOUT = $$TRUE
	ShowWindow (hwnd, $$SW_SHOWMAXIMIZED)
	BringWindowToTop (hwnd)
	UpdateWindow (hwnd)
	##LOCKOUT = entryLOCKOUT
	XgrAddMessage (window, #WindowMaximized, $$WindowMaximized, 0, 0, 0, 0, 0)
	WindowInfo (window, 0, 0, 0, 0)				' update window position/size
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##################################
' #####  XgrMinimizeWindow ()  #####
' ##################################
'
FUNCTION  XgrMinimizeWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED	modalWindowSystem
	SHARED	modalWindowUser
'
'	PRINT "XgrMinimizeWindow() : queue #WindowMinimized : "; window
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IF (window = modalWindowUser) THEN RETURN ($$TRUE)		' was XgrSetModalWindow (0)
	IF (window = modalWindowSystem) THEN RETURN ($$TRUE)	' was XgrSetModalWindow (0)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
'
	hwnd = windowInfo[window].hwnd
	visible = windowInfo[window].visible
	windowInfo[window].visible = $$WindowMinimized
	XgrAddMessage (window, #WindowMinimized, $$WindowMinimized, 0, 0, 0, 0, 0)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	ShowWindow (hwnd, $$SW_MINIMIZE)
	UpdateWindow (hwnd)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' #################################
' #####  XgrRestoreWindow ()  #####
' #################################
'
FUNCTION  XgrRestoreWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
'
'	PRINT "XgrRestoreWindow() : call appropriate Xgr function "; window
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	XgrDisplayWindow (window)
	RETURN ($$FALSE)
'
' old code
'
	state = windowInfo[window].visible
	IF state THEN
		state = $$WindowDisplayed
	ELSE
		state = windowInfo[window].priorVisible
		IFZ state THEN state = $$WindowDisplayed
	END IF
'
	SELECT CASE state
		CASE $$WindowMaximized
					XgrMaximizeWindow (window)
		CASE $$WindowMinimized
					XgrMinimizeWindow (window)
		CASE ELSE
					XgrDisplayWindow (window)
	END SELECT
END FUNCTION
'
'
' ##################################
' #####  XgrSetModalWindow ()  #####
' ##################################
'
FUNCTION  XgrSetModalWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED	modalWindowSystem
	SHARED	modalWindowUser
	SHARED	helpWindow
	SHARED	hostWin[]
'
	IF window THEN
		enable = $$FALSE
		IF InvalidWindow (window) THEN window = 0
		winType = windowInfo[window].windowType
		whom = windowInfo[window].whomask
		IF (##WHOMASK ^^ whom) THEN window = 0 : PRINT "##WHOMASK ^^ window[window].whomask"
	END IF
'
' enable all windows = no modal window
'
	enable = $$TRUE
	GOSUB EnableWindows
	IF ##WHOMASK THEN modalWindowUser = 0 ELSE modalWindowSystem = 0
	IFZ window THEN RETURN ($$FALSE)
'
' select modal window if not already selected
'
	XgrGetSelectedWindow (@sw)
	IF (sw != window) THEN
		XgrDisplayWindow (window)
		XgrProcessMessages (-2)
		XgrGetSelectedWindow (@sw)
		IF (sw != window) THEN RETURN ($$TRUE)	' window not selectable
	END IF
'
' no current modal window = all windows enabled
' disable all windows except modal window and its kids
'
	upper = UBOUND (windowInfo[])
	FOR w = 1 TO upper
		host = windowInfo[w].host
		hwnd = windowInfo[w].hwnd
		whom = windowInfo[w].whomask
'
		IFZ host THEN DO NEXT										' no such window
		IF (##WHOMASK ^^ whom) THEN DO NEXT			' not same system/user
'
' enable window and its kids - disable all other windows
'
		enable = $$FALSE
		p = w
		DO
			IF (p = helpWindow) THEN enable = $$TRUE : EXIT DO
			IF (p = window) THEN enable = $$TRUE : EXIT DO
			p = windowInfo[p].parent
		LOOP WHILE p
		EnableWindow (hwnd, enable)
	NEXT
'
	IF ##WHOMASK THEN modalWindowUser = window ELSE modalWindowSystem = window
	RETURN ($$FALSE)
'
'
' *****  Disable/Enable all windows with same ##WHOMASK  *****
'
SUB EnableWindows
	upper = UBOUND (windowInfo[])
	FOR w = 1 TO upper
		host = windowInfo[w].host
		hwnd = windowInfo[w].hwnd
		whom = windowInfo[w].whomask
		IF (w = helpWindow) THEN
			IFZ enable THEN DO NEXT
			EnableWindow (hwnd, enable)
		END IF
'
		IF host THEN
			IF (##WHOMASK ^^ whom) THEN DO NEXT		' not same system/user
			EnableWindow (hwnd, enable)						' disable/enable window
		END IF
	NEXT
END SUB
END FUNCTION
'
'
' #####################################
' #####  XgrSetWindowFunction ()  #####
' #####################################
'
FUNCTION  XgrSetWindowFunction (window, func)
	SHARED  WINDOWINFO  windowInfo[]
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	windowInfo[window].func = func
END FUNCTION
'
'
' #################################
' #####  XgrSetWindowIcon ()  #####
' #################################
'
FUNCTION  XgrSetWindowIcon (window, icon)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  iconHandle[],  iconPtr
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
' The following check doesn't work correctly, because icon == 0 is the
' 'XBasic icon' but windowInfo[window].icon is also initialised to 0, so the
' window icon is never set (if icon == 0).
'	IF (icon = windowInfo[window].icon) THEN RETURN ($$FALSE)
	IF ((icon < 0) OR (icon >= iconPtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	windowInfo[window].icon = icon
	hwnd = windowInfo[window].hwnd
	iconHandle = iconHandle[icon]
'
'	##WHOMASK = entryWHOMASK
'	RETURN ($$FALSE)
'
' the following changes icons for ALL windows
'
	IF iconHandle THEN
		##LOCKOUT = $$TRUE
		SetClassLongA (hwnd, $$GCL_HICON, iconHandle)
		##LOCKOUT = entryLOCKOUT
		##WHOMASK = entryWHOMASK
	END IF
	RETURN ($$FALSE)
'
'
' the following draws the icon in the upper-left corner of the window
'
'	IF (windowInfo[window].visible = $$WindowMinimized) THEN
'		##WHOMASK = 0
'		##LOCKOUT = $$TRUE
'		DrawIcon (windowInfo[window].hdc, 0, 0, iconHandle[icon])
'		##LOCKOUT = entryLOCKOUT
'		##WHOMASK = entryWHOMASK
'	END IF
END FUNCTION
'
'
' ############################################
' #####  XgrSetWindowPositionAndSize ()  #####
' ############################################
'
FUNCTION  XgrSetWindowPositionAndSize (window, xDisp, yDisp, width, height)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
'
	hwnd = windowInfo[window].hwnd
	visible = windowInfo[window].visible
	prior = windowInfo[window].priorVisible
	IF IsIconic (hwnd) THEN RETURN ($$FALSE)
	IF (visible = $$WindowMinimized) THEN RETURN ($$FALSE)
	IF ((visible = $$WindowHidden) AND (prior = $$WindowMinimized)) THEN RETURN ($$FALSE)
'
	##WHOMASK = 0
	IF ((xDisp AND yDisp AND width AND height) != -1) THEN
		IF (xDisp		= -1) THEN xDisp	= windowInfo[window].xDisp
		IF (yDisp		= -1) THEN yDisp	= windowInfo[window].yDisp
		IF (width		<= 0) THEN width	= windowInfo[window].width
		IF (height	<= 0) THEN height	= windowInfo[window].height
'
		x = xDisp
		y = yDisp
		w = width
		h = height
		WindowInfo (window, @xDisp, @yDisp, @width, @height)
		IF ((xDisp != x) OR (yDisp != y) OR (width != w) OR (height != h)) THEN
			host				= windowInfo[window].host
			windowType	= windowInfo[window].windowType
'			PRINT "XgrSetWindowPositionAndSize():A:", window, visible, prior
'			PRINT "XgrSetWindowPositionAndSize():B:", x, y, w, h
			SELECT CASE ALL TRUE
				CASE (windowType AND $$WindowTypeResizeFrame)
					borderWidth = hostDisplay[host].borderWidth
					x = x - borderWidth
					y = y - borderWidth
					w = w + (borderWidth << 1)
					h = h + (borderWidth << 1)
				CASE (windowType AND $$WindowTypeTitleBar)
					titleHeight = hostDisplay[host].titleHeight
					y = y - titleHeight
					h = h + titleHeight
			END SELECT
'			PRINT "XgrSetWindowPositionAndSize():C:", x, y, w, h
			hwnd = windowInfo[window].hwnd
			##LOCKOUT = $$TRUE
			MoveWindow (hwnd, x, y, w, h, $$TRUE)									' repaint
			UpdateWindow (hwnd)
			##LOCKOUT = entryLOCKOUT
			WindowInfo (window, @xDisp, @yDisp, @width, @height)	' update
'			PRINT "XgrSetWindowPositionAndSize():D:", xDisp, yDisp, width, height
		END IF
	END IF
'
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##################################
' #####  XgrSetWindowState ()  #####
' ##################################
'
'
FUNCTION  XgrSetWindowState (window, state)
	SHARED  WINDOWINFO  windowInfo[]
'
'	PRINT "XgrSetWindowState() : call appropriate Xgr function : "; window; state
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	SELECT CASE state
		CASE 4		: XgrShowWindow (window)
		CASE 3		: XgrMaximizeWindow (window)
		CASE 2		:	XgrMinimizeWindow (window)
		CASE 1		: XgrDisplayWindow (window)
		CASE 0		:	XgrHideWindow (window)
		CASE ELSE	: XgrDisplayWindow (window)
	END SELECT
END FUNCTION
'
'
' ##################################
' #####  XgrSetWindowTitle ()  #####
' ##################################
'
FUNCTION  XgrSetWindowTitle (window, title$)
	SHARED  WINDOWINFO  windowInfo[]
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##LOCKOUT = $$TRUE
	##WHOMASK = 0
'
	SetWindowTextA (windowInfo[window].hwnd, &title$)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##############################
' #####  XgrShowWindow ()  #####
' ##############################
'
FUNCTION  XgrShowWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
'
'	PRINT "XgrShowWindow() : queue #WindowDisplayed : "; window
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
'
	hwnd = windowInfo[window].hwnd
	visible = windowInfo[window].visible
	windowInfo[window].visible = $$WindowDisplayed
	windowType = windowInfo[window].windowType
'
	stackAction = $$HWND_TOP
	action = $$SWP_SHOWWINDOW OR $$SWP_NOACTIVATE OR $$SWP_NOMOVE OR $$SWP_NOSIZE
	##LOCKOUT = $$TRUE
	SetWindowPos (hwnd, stackAction, 0, 0, 0, 0, action)
	UpdateWindow (hwnd)
'
	IF IsZoomed (hwnd) THEN
		ShowWindow (hwnd, $$SW_RESTORE)
		UpdateWindow (hwnd)
	END IF
'
	IF IsIconic (hwnd) THEN
		ShowWindow (hwnd, $$SW_RESTORE)
		UpdateWindow (hwnd)
		IF IsIconic (hwnd) THEN PRINT "XgrShowWindow() : Disaster : stuck iconic"
	END IF
'
	##LOCKOUT = entryLOCKOUT
	WindowInfo (window, 0, 0, 0, 0)							' update window position/size
END FUNCTION
'
'
' #############################
' #####  XgrClearGrid ()  #####
' #############################
'
FUNCTION  XgrClearGrid (grid, color)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
	STATIC  RECT  rect

	IF InvalidGrid (grid) THEN RETURN ($$TRUE)

	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0

	window		= gridInfo[grid].window
	hdc				= windowInfo[window].hdc
	clipGrid	= gridInfo[grid].clipGrid							' clipGrid always valid (or 0)

	xWin			= gridInfo[grid].winBox.x1
	yWin			= gridInfo[grid].winBox.y1
	width			= gridInfo[grid].width
	height		= gridInfo[grid].height
'
'	Set the drawing color = background color
'
	IF (color = -1) THEN
		pixel = gridInfo[grid].sysBackground
		color = (pixel{8,0} << 24) OR (pixel{8,8} << 16) OR (pixel{8,16} << 8)
		SetWindowBrush (window, color)
		color = -1
	ELSE
		SetWindowBrush (window, color)
	END IF
	fgBrush = windowInfo[window].fgBrush
'
'	Draw mode irrelevant for FillRect()
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		IF windowInfo[window].clipIsNull THEN			' Null intersection
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF

		rect.left = xWin
		rect.top = yWin
		rect.right = xWin + width
		rect.bottom = yWin + height
		IF (windowInfo[window].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			FillRect (hdc, &rect, fgBrush)
'			GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF

	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF

	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	xWin = xWin - ixUL
	yWin = yWin - iyUL
	rect.left		= xWin
	rect.top		= yWin
	rect.right	= xWin + width
	rect.bottom	= yWin + height
	##LOCKOUT = $$TRUE
	FillRect (ntImageInfo.hdcImage, &rect, fgBrush)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' #############################
' #####  XgrCloneGrid ()  #####
' #############################
'
FUNCTION  XgrCloneGrid (grid, newGrid, newWindow, newParent, xWin, yWin)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  winGrid[]
	SHARED  charMap[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IF InvalidWindow (newWindow) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0																	' protect MOTIF allocations
'
'	Assign newGrid number (1,2,...)								(grid 0 indicates grid unused)
'
	newGrid = 0
	uGrids = UBOUND(gridInfo[])
	FOR i = 1 TO uGrids
		IFZ gridInfo[i].grid THEN newGrid = i:  EXIT FOR
	NEXT i
	IFZ newGrid THEN															' no grid slots available
		newGrid = uGrids + 1
		uGrids = (uGrids + 8) OR 7
		REDIM gridInfo[uGrids]											' [i].grid = 0:	new grids unused
		REDIM charMap[uGrids,]
	END IF
'
'	Add newGrid to winGrid[]
'
	IFZ winGrid[newWindow,] THEN
		DIM temp[7]
		ATTACH temp[] TO winGrid[newWindow,]
		winGrid[newWindow,0] = newGrid
	ELSE
		index = -1
		uWinGrids = UBOUND(winGrid[newWindow,])
		FOR i = 0 TO uWinGrids
			IFZ winGrid[newWindow,i] THEN index = i:  EXIT FOR
		NEXT i
		IF (index < 0) THEN
			index = uWinGrids + 1
			uWinGrids = (uWinGrids + 8) OR 7
			ATTACH winGrid[newWindow,] TO temp[]
			REDIM temp[uWinGrids]
			ATTACH temp[] TO winGrid[newWindow,]
		END IF
		winGrid[newWindow, index] = newGrid
	END IF
'
	width = gridInfo[grid].width
	height = gridInfo[grid].height
'
'	Set newGrid information
'
	gridInfo[newGrid].gridType						= gridInfo[grid].gridType
	gridInfo[newGrid].window							= newWindow
	gridInfo[newGrid].grid								= newGrid
	gridInfo[newGrid].parentGrid					= newParent
	gridInfo[newGrid].clipGrid						= 0									' no clipGrid
	gridInfo[newGrid].bufferGrid					= 0									' no bufferGrid
	gridInfo[newGrid].func								= gridInfo[grid].func
	gridInfo[newGrid].font								= gridInfo[grid].font
	gridInfo[newGrid].drawMode						= gridInfo[grid].drawMode
	gridInfo[newGrid].lineWidth						= gridInfo[grid].lineWidth
	gridInfo[newGrid].lineStyle						= gridInfo[grid].lineStyle
	gridInfo[newGrid].disabled						= 0
	gridInfo[newGrid].buttonClicks				= gridInfo[grid].buttonClicks
	gridInfo[newGrid].lastClickTime				= gridInfo[grid].lastClickTime
	gridInfo[newGrid].timeOutID						= 0
	gridInfo[newGrid].highColor						= gridInfo[grid].highColor
	gridInfo[newGrid].lowColor						= gridInfo[grid].lowColor
	gridInfo[newGrid].accentColor					= gridInfo[grid].accentColor
	gridInfo[newGrid].dullColor						= gridInfo[grid].dullColor
	gridInfo[newGrid].backBlue						= gridInfo[grid].backBlue
	gridInfo[newGrid].backGreen						= gridInfo[grid].backGreen
	gridInfo[newGrid].backRed							= gridInfo[grid].backRed
	gridInfo[newGrid].backColor						= gridInfo[grid].backColor
	gridInfo[newGrid].drawBlue						= gridInfo[grid].drawBlue
	gridInfo[newGrid].drawGreen						= gridInfo[grid].drawGreen
	gridInfo[newGrid].drawRed							= gridInfo[grid].drawRed
	gridInfo[newGrid].drawColor						= gridInfo[grid].drawColor
	gridInfo[newGrid].drawpoint.x					= gridInfo[grid].drawpoint.x
	gridInfo[newGrid].drawpoint.y					= gridInfo[grid].drawpoint.y
	gridInfo[newGrid].drawpointGrid.x			= gridInfo[grid].drawpointGrid.x
	gridInfo[newGrid].drawpointGrid.y			= gridInfo[grid].drawpointGrid.y
	gridInfo[newGrid].drawpointScaled.x		= gridInfo[grid].drawpointScaled.x
	gridInfo[newGrid].drawpointScaled.y		= gridInfo[grid].drawpointScaled.y
	gridInfo[newGrid].winBox.x1						= xWin
	gridInfo[newGrid].winBox.y1						= yWin
	gridInfo[newGrid].winBox.x2						= xWin + width - 1
	gridInfo[newGrid].winBox.y2						= yWin + height - 1
	gridInfo[newGrid].gridBox.x1					= gridInfo[grid].gridBox.x1
	gridInfo[newGrid].gridBox.y1					= gridInfo[grid].gridBox.y1
	gridInfo[newGrid].gridBox.x2					= gridInfo[grid].gridBox.x2
	gridInfo[newGrid].gridBox.y2					= gridInfo[grid].gridBox.y2
	gridInfo[newGrid].gridBoxScaled.x1		= gridInfo[grid].gridBoxScaled.x1
	gridInfo[newGrid].gridBoxScaled.y1		= gridInfo[grid].gridBoxScaled.y1
	gridInfo[newGrid].gridBoxScaled.x2		= gridInfo[grid].gridBoxScaled.x2
	gridInfo[newGrid].gridBoxScaled.y2		= gridInfo[grid].gridBoxScaled.y2
	gridInfo[newGrid].xScale							= gridInfo[grid].xScale
	gridInfo[newGrid].yScale							= gridInfo[grid].yScale
	gridInfo[newGrid].xInvScale						= gridInfo[grid].xInvScale
	gridInfo[newGrid].yInvScale						= gridInfo[grid].yInvScale
	gridInfo[newGrid].width								= width
	gridInfo[newGrid].height							= height
	gridInfo[newGrid].sysImage						= 0
	gridInfo[newGrid].sysBackground				= gridInfo[grid].sysBackground
	gridInfo[newGrid].sysDrawing					= gridInfo[grid].sysDrawing
	gridInfo[newGrid].borderOffsetLeft		= gridInfo[grid].borderOffsetLeft
	gridInfo[newGrid].borderOffsetTop			= gridInfo[grid].borderOffsetTop
	gridInfo[newGrid].borderOffsetRight		= gridInfo[grid].borderOffsetRight
	gridInfo[newGrid].borderOffsetBottom	= gridInfo[grid].borderOffsetBottom
	gridInfo[newGrid].border							= gridInfo[grid].border
	gridInfo[newGrid].borderUp						= gridInfo[grid].borderUp
	gridInfo[newGrid].borderDown					= gridInfo[grid].borderDown
	gridInfo[newGrid].borderFlags					= gridInfo[grid].borderFlags

	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ########################################
' #####  XgrConvertDisplayToGrid ()  #####
' ########################################
'
FUNCTION  XgrConvertDisplayToGrid (grid, xDisp, yDisp, xGrid, yGrid)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	xWin = xDisp - windowInfo[window].xDisp
	yWin = yDisp - windowInfo[window].yDisp
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1		' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2		' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	IF (xLR > xUL) THEN										' x increases right
		xGrid = xUL + (xWin - xULWin)
	ELSE
		yGrid = xUL + (xULWin - xWin)
	END IF
'
	IF (yLR > yUL) THEN										' y increases down
		yGrid = yUL + (yWin - yULWin)
	ELSE
		yGrid = yUL + (yULWin - yWin)
	END IF
END FUNCTION
'
'
' #########################################
' #####  XgrConvertDisplayToLocal ()  #####
' #########################################
'
FUNCTION  XgrConvertDisplayToLocal (grid, xDisp, yDisp, x, y)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	xULWin = gridInfo[grid].winBox.x1					' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xWin = xDisp - windowInfo[window].xDisp
	yWin = yDisp - windowInfo[window].yDisp
'
	x = xWin - xULWin
	y = yWin - yULWin
END FUNCTION
'
'
' ##########################################
' #####  XgrConvertDisplayToScaled ()  #####
' ##########################################
'
FUNCTION  XgrConvertDisplayToScaled (grid, xDisp, yDisp, x#, y#)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	xWin = xDisp - windowInfo[window].xDisp
	yWin = yDisp - windowInfo[window].yDisp
'
	xULWin = gridInfo[grid].winBox.x1					' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1		' upper-left grid coordinate
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2		' lower-right grid coordinate
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xInvScale# = gridInfo[grid].xInvScale
	yInvScale# = gridInfo[grid].yInvScale
'
	IF (xLR# > xUL#) THEN																	' x increases right
		x# = xUL# + (DOUBLE(xWin - xULWin) * xInvScale#)
	ELSE
		x# = xUL# + (DOUBLE(xULWin - xWin) * xInvScale#)
	END IF
'
	IF (yLR# > yUL#) THEN																	' y increases down
		y# = yUL# + (DOUBLE(yWin - yULWin) * yInvScale#)
	ELSE
		y# = yUL# + (DOUBLE(yULWin - yWin) * yInvScale#)
	END IF
END FUNCTION
'
'
' ##########################################
' #####  XgrConvertDisplayToWindow ()  #####
' ##########################################
'
FUNCTION  XgrConvertDisplayToWindow (grid, xDisp, yDisp, xWin, yWin)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	xWin = xDisp - windowInfo[window].xDisp
	yWin = yDisp - windowInfo[window].yDisp
END FUNCTION
'
'
' ########################################
' #####  XgrConvertGridToDisplay ()  #####
' ########################################
'
FUNCTION  XgrConvertGridToDisplay (grid, x, y, xDisp, yDisp)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1			' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2			' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	IF (xLR > xUL) THEN									' x increases right
		xWin = xULWin + (x - xUL)
	ELSE
		xWin = xULWin + (xUL - x)
	END IF
'
	IF (yLR > yUL) THEN									' y increases down
		yWin = yULWin + (y - yUL)
	ELSE
		yWin = yULWin + (yUL - y)
	END IF
'
	window = gridInfo[grid].window
	xDisp = xWin + windowInfo[window].xDisp
	yDisp = yWin + windowInfo[window].yDisp
END FUNCTION
'
'
' ######################################
' #####  XgrConvertGridToLocal ()  #####
' ######################################
'
FUNCTION  XgrConvertGridToLocal (grid, xGrid, yGrid, x, y)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xUL = gridInfo[grid].gridBox.x1				' grid xy of UL grid-box
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2				' grid xy of LR grid-box
	yLR = gridInfo[grid].gridBox.y2
'
	IF (xLR > xUL) THEN
		x = xGrid - xUL
	ELSE
		x = xUL - xGrid
	END IF
'
	IF (yLR > yUL) THEN
		y = yGrid - yUL
	ELSE
		y = yUL - yGrid
	END IF
END FUNCTION
'
'
' #######################################
' #####  XgrConvertGridToScaled ()  #####
' #######################################
'
FUNCTION  XgrConvertGridToScaled (grid, xGrid, yGrid, x#, y#)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xUL = gridInfo[grid].gridBox.x1						' grid xy of UL grid-box
	yUL = gridInfo[grid].gridBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1		' scaled xy of UL grid-box
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xInvScale# = gridInfo[grid].xInvScale			' sign: grid/scale
	yInvScale# = gridInfo[grid].yInvScale
'
	x# = xUL# + ((xGrid - xUL) * xInvScale#)
	y# = yUL# + ((yGrid - yUL) * yInvScale#)
END FUNCTION
'
'
' #######################################
' #####  XgrConvertGridToWindow ()  #####
' #######################################
'
FUNCTION  XgrConvertGridToWindow (grid, xGrid, yGrid, xWin, yWin)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1			' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2			' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	IF (xLR > xUL) THEN									' x increases right
		xWin = xULWin + (xGrid - xUL)
	ELSE
		xWin = xULWin + (xUL - xGrid)
	END IF
'
	IF (yLR > yUL) THEN									' y increases down
		yWin = yULWin + (yGrid - yUL)
	ELSE
		yWin = yULWin + (yUL - yGrid)
	END IF
END FUNCTION
'
'
' #########################################
' #####  XgrConvertLocalToDisplay ()  #####
' #########################################
'
FUNCTION  XgrConvertLocalToDisplay (grid, x, y, xDisp, yDisp)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	xDisp = x + gridInfo[grid].winBox.x1 + windowInfo[window].xDisp
	yDisp = y + gridInfo[grid].winBox.y1 + windowInfo[window].yDisp
END FUNCTION
'
'
' ######################################
' #####  XgrConvertLocalToGrid ()  #####
' ######################################
'
FUNCTION  XgrConvertLocalToGrid (grid, x, y, xGrid, yGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xUL = gridInfo[grid].gridBox.x1		' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2		' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	IF (xLR > xUL) THEN								' x increases right
		xGrid = xUL + x
	ELSE
		xGrid = xUL - x
	END IF
'
	IF (yLR > yUL) THEN								' y increases down
		yGrid = yUL + y
	ELSE
		yGrid = yUL - y
	END IF
END FUNCTION
'
'
' ########################################
' #####  XgrConvertLocalToScaled ()  #####
' ########################################
'
FUNCTION  XgrConvertLocalToScaled (grid, x, y, x#, y#)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xUL# = gridInfo[grid].gridBoxScaled.x1					' upper-left grid coordinate
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2					' lower-right grid coordinate
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xInvScale# = gridInfo[grid].xInvScale
	yInvScale# = gridInfo[grid].yInvScale
'
	x# = xUL# + (DOUBLE(x) * xInvScale#)
	y# = yUL# + (DOUBLE(y) * yInvScale#)
END FUNCTION
'
'
' ########################################
' #####  XgrConvertLocalToWindow ()  #####
' ########################################
'
FUNCTION  XgrConvertLocalToWindow (grid, x, y, xWin, yWin)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
'
	xWin = xULWin + x
	yWin = yULWin + y
END FUNCTION
'
'
' ##########################################
' #####  XgrConvertScaledToDisplay ()  #####
' ##########################################
'
FUNCTION  XgrConvertScaledToDisplay (grid, x#, y#, xDisp, yDisp)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xULWin = gridInfo[grid].winBox.x1					' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1		' upper-left grid coordinate
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2		' lower-right grid coordinate
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xScale# = gridInfo[grid].xScale
	yScale# = gridInfo[grid].yScale
'
	xWin = xULWin + ((x# - xUL#) * xScale#)
	yWin = yULWin + ((y# - yUL#) * yScale#)
'
	window = gridInfo[grid].window
	xDisp = xWin + windowInfo[window].xDisp
	yDisp = yWin + windowInfo[window].yDisp
END FUNCTION
'
'
' #######################################
' #####  XgrConvertScaledToGrid ()  #####
' #######################################
'
FUNCTION  XgrConvertScaledToGrid (grid, x#, y#, xGrid, yGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xUL = gridInfo[grid].gridBox.x1						' grid xy of UL grid-box
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2
	yLR = gridInfo[grid].gridBox.y2
	xUL# = gridInfo[grid].gridBoxScaled.x1		' scaled xy of UL grid-box
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xScale# = gridInfo[grid].xScale						' sign: grid/scale
	yScale# = gridInfo[grid].yScale
'
	IF (xUL <= xLR) THEN
		xGrid = xUL + ((x# - xUL#) * xScale#)
	ELSE
		xGrid = xUL - ((x# - xUL#) * xScale#)
	END IF
'
	IF (yUL <= yLR) THEN
		yGrid = yUL + ((y# - yUL#) * yScale#)
	ELSE
		yGrid = yUL - ((y# - yUL#) * yScale#)
	END IF
END FUNCTION
'
'
' ########################################
' #####  XgrConvertScaledToLocal ()  #####
' ########################################
'
FUNCTION  XgrConvertScaledToLocal (grid, x#, y#, x, y)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xUL# = gridInfo[grid].gridBoxScaled.x1		' scaled xy of UL grid-box
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xScale# = gridInfo[grid].xScale							' sign: grid/scale
	yScale# = gridInfo[grid].yScale
'
	x = (x# - xUL#) * xScale#
	y = (y# - yUL#) * yScale#
END FUNCTION
'
'
' #########################################
' #####  XgrConvertScaledToWindow ()  #####
' #########################################
'
FUNCTION  XgrConvertScaledToWindow (grid, x#, y#, xWin, yWin)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xULWin = gridInfo[grid].winBox.x1					' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1		' upper-left grid coordinate
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2		' lower-right grid coordinate
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xScale#	= gridInfo[grid].xScale
	yScale#	= gridInfo[grid].yScale
'
	xWin = xULWin + ((x# - xUL#) * xScale#)
	yWin = yULWin + ((y# - yUL#) * yScale#)
END FUNCTION
'
'
' ##########################################
' #####  XgrConvertWindowToDisplay ()  #####
' ##########################################
'
FUNCTION  XgrConvertWindowToDisplay (grid, xWin, yWin, xDisp, yDisp)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	xDisp = xWin + windowInfo[window].xDisp
	yDisp = yWin + windowInfo[window].yDisp
END FUNCTION
'
'
' #######################################
' #####  XgrConvertWindowToGrid ()  #####
' #######################################
'
FUNCTION  XgrConvertWindowToGrid (grid, xWin, yWin, xGrid, yGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1			' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2			' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	IF (xLR > xUL) THEN									' x increases right
		xGrid = xUL + (xWin - xULWin)
	ELSE
		xGrid = xUL + (xULWin - xWin)
	END IF
'
	IF (yLR > yUL) THEN									' y increases down
		yGrid = yUL + (yWin - yULWin)
	ELSE
		yGrid = yUL + (yULWin - yWin)
	END IF
END FUNCTION
'
'
' ########################################
' #####  XgrConvertWindowToLocal ()  #####
' ########################################
'
FUNCTION  XgrConvertWindowToLocal (grid, xWin, yWin, x, y)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
'
	x = xWin - xULWin
	y = yWin - yULWin
END FUNCTION
'
'
' #########################################
' #####  XgrConvertWindowToScaled ()  #####
' #########################################
'
FUNCTION  XgrConvertWindowToScaled (grid, xWin, yWin, x#, y#)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xULWin = gridInfo[grid].winBox.x1					' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1		' upper-left grid coordinate
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2		' lower-right grid coordinate
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xInvScale# = gridInfo[grid].xInvScale
	yInvScale# = gridInfo[grid].yInvScale
'
	x# = xUL# + (DOUBLE(xWin - xULWin) * xInvScale#)
	y# = yUL# + (DOUBLE(yWin - yULWin) * yInvScale#)
END FUNCTION
'
'
' ##############################
' #####  XgrCreateGrid ()  #####
' ##############################
'
'	Create a grid for the specified window, setting its gridBox
'
'	In:				gridType
'						x,y					upper left corner of grid in parent coordinates
'						width				width/height in pixels
'						height
'						window			window
'						parent			0 = child of window (gets redraw messages)
'						func
'
'	Out:			grid				grid
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		Clipping code relies on most grid 0 GRIDINFO values to be 0.
'
FUNCTION  XgrCreateGrid (grid, gridType, x, y, width, height, window, parent, func)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  winGrid[]
	SHARED  charMap[]
	SHARED  defaultBackground
	SHARED  defaultDrawing
	SHARED  defaultLowlight
	SHARED  defaultHighlight
	SHARED  defaultDull
	SHARED  defaultAccent
	SHARED	defaultLowText
	SHARED	defaultHighText
	SHARED  defaultFont
'
	grid = 0
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IF parent THEN
		IF InvalidGrid (parent) THEN RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = 0																	' protect MOTIF allocations
'
' negative grid type means create grid in disabled state
'
	state = $$TRUE
	IF (gridType < 0) THEN gridType = -gridType : state = $$FALSE
'
'	Assign grid number (1,2,...)									(grid 0 indicates grid unused)
'
	IFZ gridInfo[] THEN
		grid = 1
		DIM gridInfo[7]															' [i].grid = 0:	all grids unused
		DIM charMap[7,]
		GOSUB DefaultCharacterMap
	ELSE
		grid = 0
		uGrids = UBOUND(gridInfo[])
		FOR i = 1 TO uGrids
			IFZ gridInfo[i].grid THEN grid = i : EXIT FOR
		NEXT i
		IFZ grid THEN																' no grid slots available
			grid = uGrids + 1
			uGrids = (uGrids + 8) OR 7
			REDIM gridInfo[uGrids]										' [i].grid = 0:	new grids unused
			REDIM charMap[uGrids,]
		END IF
	END IF
'
'	Add grid to winGrid[]
'
	IFZ winGrid[window,] THEN
		DIM temp[7]
		ATTACH temp[] TO winGrid[window,]
		winGrid[window,0] = grid
	ELSE
		index = -1
		uWinGrids = UBOUND(winGrid[window,])
		FOR i = 0 TO uWinGrids
			IFZ winGrid[window,i] THEN index = i : EXIT FOR
		NEXT i
		IF (index < 0) THEN
			index = uWinGrids + 1
			uWinGrids = (uWinGrids + 8) OR 7
			ATTACH winGrid[window,] TO temp[]
			REDIM temp[uWinGrids]
			ATTACH temp[] TO winGrid[window,]
		END IF
		winGrid[window,index] = grid
	END IF
'
'	Set default grid information
'
	IFZ parent THEN
		xWin = x
		yWin = y
	ELSE
		xWin = x + gridInfo[parent].winBox.x1
		yWin = y + gridInfo[parent].winBox.y1
	END IF
'
	x1 = 0
	y1 = 0
	IF (width < 1) THEN width = 1
	IF (height < 1) THEN height = 1
	x2 = width - 1
	y2 = height - 1
	host = windowInfo[window].host
'
	gridInfo[grid].gridType						= gridType
	gridInfo[grid].window							= window
	gridInfo[grid].grid								= grid					' also says grid is used
	gridInfo[grid].parentGrid					= parent
	gridInfo[grid].clipGrid						= 0							' don't clip now
	gridInfo[grid].bufferGrid					= 0
	gridInfo[grid].func								= func
	gridInfo[grid].font								= defaultFont
	gridInfo[grid].drawMode						= $$DrawCOPY
	gridInfo[grid].lineWidth					= 1
	gridInfo[grid].lineStyle					= 0							' solid
	gridInfo[grid].disabled						= NOT state
	gridInfo[grid].buttonClicks				= 0
	gridInfo[grid].lastClickTime			= 0
	gridInfo[grid].timeOutID					= 0
	gridInfo[grid].drawpoint.x				= x1						' local coords
	gridInfo[grid].drawpoint.y				= y1
	gridInfo[grid].drawpointGrid.x		= x1						' grid coords
	gridInfo[grid].drawpointGrid.y		= y1
	gridInfo[grid].drawpointScaled.x	= 0#						' scaled coords
	gridInfo[grid].drawpointScaled.y	= 0#
	gridInfo[grid].winBox.x1					= xWin					' winBox
	gridInfo[grid].winBox.y1					= yWin
	gridInfo[grid].winBox.x2					= xWin + width - 1
	gridInfo[grid].winBox.y2					= yWin + height - 1
	gridInfo[grid].gridBox.x1					= x1						' gridBox
	gridInfo[grid].gridBox.y1					= y1
	gridInfo[grid].gridBox.x2					= x2
	gridInfo[grid].gridBox.y2					= y2
	gridInfo[grid].gridBoxScaled.x1		= x1						' gridBoxScaled
	gridInfo[grid].gridBoxScaled.y1		= y1
	gridInfo[grid].gridBoxScaled.x2		= x2
	gridInfo[grid].gridBoxScaled.y2		= y2
	gridInfo[grid].xScale							= 1#						' scale = 1 grid / scaled
	gridInfo[grid].yScale							= 1#
	gridInfo[grid].xInvScale					= 1#
	gridInfo[grid].yInvScale					= 1#
	gridInfo[grid].width							= width
	gridInfo[grid].height							= height
	gridInfo[grid].sysImage						= 0
	gridInfo[grid].sysBackground			= -1
	gridInfo[grid].sysDrawing					= -1
	gridInfo[grid].borderOffsetLeft		= 0
	gridInfo[grid].borderOffsetTop		= 0
	gridInfo[grid].borderOffsetRight	= 0
	gridInfo[grid].borderOffsetBottom	= 0
	gridInfo[grid].border							= 0
	gridInfo[grid].borderUp						= 0
	gridInfo[grid].borderDown					= 0
	gridInfo[grid].borderFlags				= 0
'
	XgrSetGridColors (grid, defaultBackground, defaultDrawing, defaultLowlight, defaultHighlight, defaultDull, defaultAccent, defaultLowText, defaultHighText)
	##WHOMASK = whomask
	RETURN ($$FALSE)
'
'
' install default character map if one exists
'
SUB DefaultCharacterMap
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
END SUB
END FUNCTION
'
'
' ###############################
' #####  XgrDestroyGrid ()  #####
' ###############################
'
FUNCTION  XgrDestroyGrid (grid)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  winGrid[]
	SHARED  charMap[]
	SHARED  textSelectionGrid
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	gridInfo[grid].grid = 0												' say grid is available
'
	gridType	= gridInfo[grid].gridType
	window		= gridInfo[grid].window							' does grid have focus
	hwnd			= windowInfo[window].hwnd
	host			= windowInfo[window].host
'
	IF (hostDisplay[host].grabMouseFocusGrid = grid) THEN
		##LOCKOUT = $$TRUE
		IF (hwnd = GetCapture()) THEN ReleaseCapture ()
		##LOCKOUT = entryLOCKOUT
		hostDisplay[host].grabMouseFocusGrid = 0
	END IF
	IF (hostDisplay[host].gridMouseInside = grid) THEN
		hostDisplay[host].gridMouseInside = 0
	END IF
'
'	If imageType, destroy image area
'
	sysImage = gridInfo[grid].sysImage
	IF sysImage THEN DestroySysImage (grid, sysImage)
'
'	Scan grids in this window:  winGrid[]
'		- remove grid
'		-	Fix clipping:
'			- If any use this grid as clipGrid, set clipGrid = 0, disable clipping.
'		- Fix buffering:
'			-	If any use this grid as bufferGrid, set bufferGrid = 0, disable buffering.
'
	window = gridInfo[grid].window
	uWinGrids = UBOUND(winGrid[window,])
	FOR i = 0 TO uWinGrids
		winGrid = winGrid[window,i]
		IFZ winGrid THEN DO NEXT
'
		IF (winGrid = grid) THEN
			winGrid[window,i] = 0														' remove grid
			DO NEXT
		END IF
'
		IF (gridInfo[winGrid].clipGrid = grid) THEN				' reset clipGrid?
			gridInfo[winGrid].clipGrid = 0
		END IF
'
		IF (gridInfo[winGrid].bufferGrid = grid) THEN			' reset bufferGrid?
			gridInfo[winGrid].bufferGrid = 0
		END IF
	NEXT i
'
' remove char map array
'
	IF charMap[grid,] THEN
		ATTACH charMap[grid,] TO temp[]
		DIM temp[]
	END IF
'
'	If this grid is textSelection grid, waste it
'
	IF (grid = textSelectionGrid) THEN textSelectionGrid = 0
'
	timeOutID = gridInfo[grid].timeOutID
	IF timeOutID THEN
		##LOCKOUT = $$TRUE
		KillTimer (hwnd, grid)
		##LOCKOUT = entryLOCKOUT
	END IF
'
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' #################################
' #####  XgrGetGridBorder ()  #####
' #################################
'
FUNCTION  XgrGetGridBorder (grid, border, borderUp, borderDown, borderFlags)
	SHARED	GRIDINFO	gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	border = gridInfo[grid].border
	borderUp = gridInfo[grid].borderUp
	borderDown = gridInfo[grid].borderDown
	borderFlags = gridInfo[grid].borderFlags
END FUNCTION
'
'
' #######################################
' #####  XgrGetGridBorderOffset ()  #####
' #######################################
'
FUNCTION  XgrGetGridBorderOffset (grid, inLeft, inTop, inRight, inBottom)
	SHARED	GRIDINFO	gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	inLeft = gridInfo[grid].borderOffsetLeft
	inTop = gridInfo[grid].borderOffsetTop
	inRight = gridInfo[grid].borderOffsetRight
	inBottom = gridInfo[grid].borderOffsetBottom
END FUNCTION
'
'
' ##############################
' #####  XgrGetGridBox ()  #####
' ##############################
'
FUNCTION  XgrGetGridBox (grid, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  GRIDINFO  gridInfo[]
'
	x1Grid = 0 : y1Grid = 0 : x2Grid = 0 : y2Grid = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x1Grid = gridInfo[grid].gridBox.x1
	y1Grid = gridInfo[grid].gridBox.y1
	x2Grid = gridInfo[grid].gridBox.x2
	y2Grid = gridInfo[grid].gridBox.y2
END FUNCTION
'
'
' #####################################
' #####  XgrGetGridBoxDisplay ()  #####
' #####################################
'
FUNCTION  XgrGetGridBoxDisplay (grid, x1Disp, y1Disp, x2Disp, y2Disp)
	SHARED  GRIDINFO  gridInfo[]
'
	x1Disp = 0 : y1Disp = 0 : x2Disp = 0 : y2Disp = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x1 = 0
	y1 = 0
	x2 = gridInfo[grid].width - 1
	y2 = gridInfo[grid].height - 1
'
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
	SHARED  GRIDINFO  gridInfo[]
'
	x1Grid = 0 : y1Grid = 0 : x2Grid = 0 : y2Grid = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x1Grid = gridInfo[grid].gridBox.x1
	y1Grid = gridInfo[grid].gridBox.y1
	x2Grid = gridInfo[grid].gridBox.x2
	y2Grid = gridInfo[grid].gridBox.y2
END FUNCTION
'
'
' ###################################
' #####  XgrGetGridBoxLocal ()  #####
' ###################################
'
FUNCTION  XgrGetGridBoxLocal (grid, x1, y1, x2, y2)
	SHARED  GRIDINFO  gridInfo[]
'
	x1 = 0 : y1 = 0 : x2 = 0 : y2 = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x1 = 0
	y1 = 0
	x2 = gridInfo[grid].width - 1
	y2 = gridInfo[grid].height - 1
END FUNCTION
'
'
' ####################################
' #####  XgrGetGridBoxScaled ()  #####
' ####################################
'
FUNCTION  XgrGetGridBoxScaled (grid, x1#, y1#, x2#, y2#)
	SHARED  GRIDINFO  gridInfo[]

	x1# = 0 : y1# = 0 : x2# = 0 : y2# = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x1# = gridInfo[grid].gridBoxScaled.x1
	y1# = gridInfo[grid].gridBoxScaled.y1
	x2# = gridInfo[grid].gridBoxScaled.x2
	y2# = gridInfo[grid].gridBoxScaled.y2
END FUNCTION
'
'
' ####################################
' #####  XgrGetGridBoxWindow ()  #####
' ####################################
'
FUNCTION  XgrGetGridBoxWindow (grid, x1Win, y1Win, x2Win, y2Win)
	SHARED  GRIDINFO  gridInfo[]

	x1Win = 0 : y1Win = 0 : x2Win = 0 : y2Win = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	x2Win = gridInfo[grid].winBox.x2
	y2Win = gridInfo[grid].winBox.y2
END FUNCTION
'
'
' #################################
' #####  XgrGetGridBuffer ()  #####
' #################################
'
FUNCTION  XgrGetGridBuffer (grid, bufferGrid, x, y)
	SHARED  GRIDINFO  gridInfo[]
'
	x = 0 : y = 0 : bufferGrid = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	bufferGrid = gridInfo[grid].bufferGrid
END FUNCTION
'
'
' ############################################
' #####  XgrGetGridCharacterMapArray ()  #####
' ############################################
'
FUNCTION  XgrGetGridCharacterMapArray (grid, map[])
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
	IF (grid <= u) THEN										' if big enough for this grid
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
' ###############################
' #####  XgrGetGridClip ()  #####
' ###############################
'
'	Get clip grid
'
'	In:				grid
'
'	Out:			clipGrid
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetGridClip (grid, clipGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	clipGrid = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	clipGrid = gridInfo[grid].clipGrid
END FUNCTION
'
'
' #################################
' #####  XgrGetGridCoords ()  #####
' #################################
'
FUNCTION  XgrGetGridCoords (grid, xWin, yWin, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  GRIDINFO  gridInfo[]
'
	xWin = 0 : yWin = 0 : x1Grid = 0 : y1Grid = 0 : x2Grid = 0 : y2Grid = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	x1Grid = gridInfo[grid].gridBox.x1
	y1Grid = gridInfo[grid].gridBox.y1
	x2Grid = gridInfo[grid].gridBox.x2
	y2Grid = gridInfo[grid].gridBox.y2
END FUNCTION
'
'
' ######################################
' #####  XgrGetGridDrawingMode ()  #####
' ######################################
'
'	Gets current drawing mode, line style, line width
'
'	In:				grid
'
'	Out:			drawMode
'						lineStyle
'						lineWidth
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetGridDrawingMode (grid, drawMode, lineStyle, lineWidth)
	SHARED  GRIDINFO  gridInfo[]
'
	drawMode = 0:  lineStyle = 0:  lineWidth = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	drawMode	= gridInfo[grid].drawMode
	lineStyle	= gridInfo[grid].lineStyle
	lineWidth	= gridInfo[grid].lineWidth
END FUNCTION
'
'
' ###############################
' #####  XgrGetGridFont ()  #####
' ###############################
'
'	Get font for grid
'
'	In:				grid
'
'	Out:			font					associated font
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetGridFont (grid, font)
	SHARED  GRIDINFO  gridInfo[]
'
	font = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	font = gridInfo[grid].font
END FUNCTION
'
'
' ###################################
' #####  XgrGetGridFunction ()  #####
' ###################################
'
'	Get grid function
'
'	In:				grid
'
'	Out:			func			message function
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetGridFunction (grid, func)
	SHARED  GRIDINFO  gridInfo[]
'
	func = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	func = gridInfo[grid].func
END FUNCTION
'
'
' #################################
' #####  XgrGetGridParent ()  #####
' #################################
'
'	Get parent grid
'
'	In:				grid
'
'	Out:			parent
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetGridParent (grid, parent)
	SHARED  GRIDINFO  gridInfo[]
'
	parent = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	parent = gridInfo[grid].parentGrid
END FUNCTION
'
'
' ##########################################
' #####  XgrGetGridPositionAndSize ()  #####
' ##########################################
'
'	Gets x,y of the grid-box in parent local coords, plus width,height
'
'	In:				grid
'
'	Out:			x					x,y of upper-left corner of grid-box in parent
'						y
'						width
'						height
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetGridPositionAndSize (grid, x, y, width, height)
	SHARED  GRIDINFO  gridInfo[]
'
	x = 0 : y = 0 : width = 0 : height = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	parent = gridInfo[grid].parentGrid
	IF parent THEN
		IF InvalidGrid (parent) THEN RETURN ($$TRUE)
	END IF
'
	x = gridInfo[grid].winBox.x1
	y = gridInfo[grid].winBox.y1
	width = gridInfo[grid].width
	height = gridInfo[grid].height
'
	IF parent THEN
		x = x - gridInfo[parent].winBox.x1
		y = y - gridInfo[parent].winBox.y1
	END IF
END FUNCTION
'
'
' ################################
' #####  XgrGetGridState ()  #####
' ################################
'
FUNCTION  XgrGetGridState (grid, state)
	SHARED  GRIDINFO  gridInfo[]
'
	state = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ gridInfo[grid].disabled THEN state = $$TRUE
END FUNCTION
'
'
' ###############################
' #####  XgrGetGridType ()  #####
' ###############################
'
'	Get gridType for grid
'
'	In:				grid
'
'	Out:			gridType	associated gridType
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetGridType (grid, gridType)
	SHARED  GRIDINFO  gridInfo[]
'
	gridType = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	gridType = gridInfo[grid].gridType
END FUNCTION
'
'
' #################################
' #####  XgrGetGridWindow ()  #####
' #################################
'
'	Get window containing grid
'
'	In:				grid
'
'	Out:			window		associated window
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
FUNCTION  XgrGetGridWindow (grid, window)
	SHARED  GRIDINFO  gridInfo[]
'
	window = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	window = gridInfo[grid].window
END FUNCTION
'
'
' ########################################
' #####  XgrGridTypeNameToNumber ()  #####
' ########################################
'
'	Convert gridTypeName$ to gridTypeNumber
'
'	In:				gridTypeName$			XBasic or User gridType name
'
'	Out:			gridTypeNumber		-1 if unregistered
'
'	Return:		$$FALSE						no error
'						$$TRUE						error
'
FUNCTION  XgrGridTypeNameToNumber (gridTypeName$, gridTypeNumber)
	SHARED  xgrError
	SHARED  gridTypeHash%%[],  gridTypeName$[],  gridTypePtr
	SHARED  xgrInitialized
'
	gridTypeNumber = -1
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IFZ gridTypeName$ THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF (gridTypeName$ = "LastGridType") THEN
		gridTypeNumber = gridTypePtr
		RETURN ($$FALSE)
	END IF
'
	IFZ gridTypeHash%%[] THEN
		xgrError = $$XgrUnregistered
		RETURN ($$TRUE)
	END IF
'
	hash	= 0
	FOR i = 0 TO UBOUND(gridTypeName$)
		hash = hash + gridTypeName${i}
	NEXT i
	hash = hash{6,0}
'
'	Is gridTypeName$ already defined?
'
	IF gridTypeHash%%[hash,] THEN
		last = gridTypeHash%%[hash,0]
		FOR i = 1 TO last
			check = gridTypeHash%%[hash,i]
			IF (gridTypeName$ = gridTypeName$[check]) THEN
				gridTypeNumber = check
				RETURN ($$FALSE)
			END IF
		NEXT i
	END IF
'
	xgrError = $$XgrUnregistered
	RETURN ($$TRUE)
END FUNCTION
'
'
' ########################################
' #####  XgrGridTypeNumberToName ()  #####
' ########################################
'
'	Convert gridTypeNumber to gridTypeName$
'
'	In:				gridTypeNumber		XBasic or User gridType
'
'	Out:			gridTypeName$
'
'	Return:		$$FALSE			no error
'						$$TRUE			error
'
FUNCTION  XgrGridTypeNumberToName (gridTypeNumber, gridTypeName$)
	SHARED  xgrError
	SHARED  gridTypeName$[],  gridTypePtr
	SHARED  xgrInitialized
'
	gridTypeName$ = ""
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IF ((gridTypeNumber <= 0) OR (gridTypeNumber > gridTypePtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	gridTypeName$ = gridTypeName$[gridTypeNumber]
END FUNCTION
'
'
' ####################################
' #####  XgrRegisterGridType ()  #####
' ####################################
'
'	Return a gridType number for a gridType name
'
'	In:				gridTypeName$		XBasic or User gridType name
'
'	Out:			gridType
'
'	Return:		$$FALSE					no errors
'						$$TRUE					error
'
'	Discussion:
'		If name already registered, just return gridType.
'		Error if gridTypePtr > 65535
'
FUNCTION  XgrRegisterGridType (gridTypeName$, gridType)
	SHARED  xgrError
	SHARED  gridTypeHash%%[],  gridTypeName$[],  gridTypePtr
	SHARED  xgrInitialized

	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF

	IFZ gridTypeName$ THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF

	IF (gridTypeName$ = "LastGridType") THEN
		gridType = gridTypePtr
		RETURN ($$FALSE)
	END IF

	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0

	IFZ gridTypeHash%%[] THEN DIM gridTypeHash%%[63,]

	hash	= 0
	FOR i = 0 TO UBOUND(gridTypeName$)
		hash = hash + gridTypeName${i}
	NEXT i
	hash = hash{6,0}															' 0-63 hash
'
'	Is gridTypeName$ already defined?
'
	IF gridTypeHash%%[hash,] THEN
		last = gridTypeHash%%[hash,0]
		FOR i = 1 TO last
			check = gridTypeHash%%[hash,i]
			IF (gridTypeName$ = gridTypeName$[check]) THEN
				gridType = check
				##WHOMASK = entryWHOMASK
				RETURN ($$FALSE)
			END IF
		NEXT i
	END IF
'
'	Assign a gridType
'
	IF (gridTypePtr >= 0xFFFF) THEN													' no more room
		gridType = 0
		xgrError = $$XgrRegisterFull
		##WHOMASK = entryWHOMASK
		RETURN ($$TRUE)
	END IF

	IFZ gridTypeHash%%[hash,] THEN
		DIM temp%%[3]
		ATTACH temp%%[] TO gridTypeHash%%[hash,]
		last = 0
	ELSE
		last = gridTypeHash%%[hash,0]
		uTypeHash = UBOUND(gridTypeHash%%[hash,])
		IF (last >= uTypeHash) THEN
			uTypeHash = (uTypeHash + 4) OR 3
			ATTACH gridTypeHash%%[hash,] TO temp%%[]
			REDIM temp%%[uTypeHash]
			ATTACH temp%%[] TO gridTypeHash%%[hash,]
		END IF
	END IF

	gridType = gridTypePtr												' first gridType is 0
	INC gridTypePtr

	INC last
	gridTypeHash%%[hash,0]		= last
	gridTypeHash%%[hash,last]	= gridType

	IFZ gridTypeName$[] THEN
		DIM gridTypeName$[7]
	ELSE
		uTypeName = UBOUND(gridTypeName$[])
		IF (gridType > uTypeName) THEN
			uTypeName = (gridType + 8) OR 7
			REDIM gridTypeName$[uTypeName]
		END IF
	END IF

	gridTypeName$[gridType] = gridTypeName$
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' #################################
' #####  XgrSetGridBorder ()  #####
' #################################
'
FUNCTION  XgrSetGridBorder (grid, border, borderUp, borderDown, borderFlags)
	SHARED	GRIDINFO	gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IF ((border >= 0) AND (border <= $$BorderUpper)) THEN gridInfo[grid].border = border
	IF ((borderUp >= 0) AND (borderUp <= $$BorderUpper)) THEN gridInfo[grid].borderUp = borderUp
	IF ((borderDown >= 0) AND (borderDown <= $$BorderUpper)) THEN gridInfo[grid].borderDown = borderDown
	IF (borderFlags != -1) THEN gridInfo[grid].borderFlags = borderFlags
END FUNCTION
'
'
' #######################################
' #####  XgrSetGridBorderOffset ()  #####
' #######################################
'
FUNCTION  XgrSetGridBorderOffset (grid, left, top, right, bottom)
	SHARED	GRIDINFO	gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	gridInfo[grid].borderOffsetLeft = left
	gridInfo[grid].borderOffsetTop = top
	gridInfo[grid].borderOffsetRight = right
	gridInfo[grid].borderOffsetBottom = bottom
END FUNCTION
'
'
' ##############################
' #####  XgrSetGridBox ()  #####
' ##############################
'
FUNCTION  XgrSetGridBox (grid, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	wx1 = gridInfo[grid].winBox.x1
	wy1 = gridInfo[grid].winBox.y1
	wx2 = gridInfo[grid].winBox.x2
	wy2 = gridInfo[grid].winBox.y2
	wdx = wx2 - wx1
	wdy = wy2 - wy1
	dx = x2Grid - x1Grid
	dy = y2Grid - y1Grid
'
	IF (dx >= 0) THEN x2Grid = x1Grid + wdx ELSE x2Grid = x1Grid - wdx
	IF (dy >= 0) THEN y2Grid = y1Grid + wdy ELSE y2Grid = y1Grid - wdy
'
	gridInfo[grid].gridBox.x1 = x1Grid
	gridInfo[grid].gridBox.y1 = y1Grid
	gridInfo[grid].gridBox.x2 = x2Grid
	gridInfo[grid].gridBox.y2 = y2Grid
END FUNCTION
'
'
' ##################################
' #####  XgrSetGridBoxGrid ()  #####
' ##################################
'
FUNCTION  XgrSetGridBoxGrid (grid, x1Grid, y1Grid, x2Grid, y2Grid)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	wx1 = gridInfo[grid].winBox.x1
	wy1 = gridInfo[grid].winBox.y1
	wx2 = gridInfo[grid].winBox.x2
	wy2 = gridInfo[grid].winBox.y2
	wdx = wx2 - wx1
	wdy = wy2 - wy1
	dx = x2Grid - x1Grid
	dy = y2Grid - y1Grid
'
	IF (dx >= 0) THEN x2Grid = x1Grid + wdx ELSE x2Grid = x1 - wdx
	IF (dy >= 0) THEN y2Grid = y1Grid + wdy ELSE y2Grid = y1 - wdy
'
	gridInfo[grid].gridBox.x1 = x1Grid
	gridInfo[grid].gridBox.y1 = y1Grid
	gridInfo[grid].gridBox.x2 = x2Grid
	gridInfo[grid].gridBox.y2 = y2Grid
END FUNCTION
'
'
' ####################################
' #####  XgrSetGridBoxScaled ()  #####
' ####################################
'
FUNCTION  XgrSetGridBoxScaled (grid, x1#, y1#, x2#, y2#)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	gridInfo[grid].gridBoxScaled.x1 = x1#
	gridInfo[grid].gridBoxScaled.y1 = y1#
	gridInfo[grid].gridBoxScaled.x2 = x2#
	gridInfo[grid].gridBoxScaled.y2 = y2#
'
'	Set xyScale
'
	x1 = gridInfo[grid].winBox.x1
	y1 = gridInfo[grid].winBox.y1
	x2 = gridInfo[grid].winBox.x2
	y2 = gridInfo[grid].winBox.y2
'
	dxScaled# = x2# - x1#
	dyScaled# = y2# - y1#
'
	IFZ dxScaled# THEN
		gridInfo[grid].xScale = 1#
	ELSE
		gridInfo[grid].xScale = DOUBLE(x2-x1) / dxScaled#
	END IF
'
	IF (x2 = x1) THEN
		gridInfo[grid].xInvScale = 1#
	ELSE
		gridInfo[grid].xInvScale = dxScaled# / DOUBLE(x2-x1)
	END IF
'
	IFZ dyScaled# THEN
		gridInfo[grid].yScale = 1#
	ELSE
		gridInfo[grid].yScale = DOUBLE(y2-y1) / dyScaled#
	END IF
'
	IF (y2 = y1) THEN
		gridInfo[grid].yInvScale = 1#
	ELSE
		gridInfo[grid].yInvScale = dyScaled# / DOUBLE(y2-y1)
	END IF
END FUNCTION
'
'
' ######################################
' #####  XgrSetGridBoxScaledAt ()  #####
' ######################################
'
FUNCTION  XgrSetGridBoxScaledAt (grid, x1#, y1#, x2#, y2#, x1, y1, x2, y2)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
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
' #################################
' #####  XgrSetGridBuffer ()  #####
' #################################
'
'	XgrSetGridBuffer()
'		-	If bufferGrid invalid, different window, or not imageType,
'				return error with no changes.
'	XgrGetGridBuffer()
'		- assume bufferGrid is valid
'	XgrDestroyGrid()
'		- If imageType, free sysImage memory area
'		- scan all grids sharing this window:
'			If any use this grid as bufferGrid, set bufferGrid = 0.
'	XgrCloneGrid()
'		- bufferGrid = 0; image area = 0
'			(ie:  buffering doesn't clone)
'	XgrSetGridType()
'		- If changing from non-image to image type, just set gridType to GT_Image
'		- If changing from image to non-image type:
'			- free the sysImage memory area
'			- scan all grids sharing this window:
'				If any use this grid as bufferGrid, set bufferGrid = 0
'	XgrSetGridBox()
'		- If gridType = GT_Image and box is resized, free the sysImage memory area.
'	For speed, bufferGrid (if non-zero) must ALWAYS be valid.
'
'	A GC can be used on any window or pixmap of the same depth and on
'		the same screen as the drawable specified in XCreateGC().
'	So, the sysImage can use the same gc as the grid, even though the
'		sysImage may be a different size than the window.
'
FUNCTION  XgrSetGridBuffer (grid, bufferGrid, x, y)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IFZ bufferGrid THEN
		gridInfo[grid].bufferGrid = 0
	ELSE
		IFF InvalidGrid (bufferGrid) THEN
			IF (gridInfo[grid].window = gridInfo[bufferGrid].window) THEN
				IF (gridInfo[bufferGrid].gridType = GT_Image) THEN
					gridInfo[grid].bufferGrid = bufferGrid
				END IF
			END IF
		END IF
	END IF
END FUNCTION
'
'
' ############################################
' #####  XgrSetGridCharacterMapArray ()  #####
' ############################################
'
FUNCTION  XgrSetGridCharacterMapArray (grid, map[])
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
' ###############################
' #####  XgrSetGridClip ()  #####
' ###############################
'
'	Set info for grid
'
'	In:				clipGrid
'
'	Out:			none			args unchanged
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'
'		Clipping:
'			XgrSetGridClip()
'				-	0, disable clipping
'				-	If clipGrid invalid or different windows, return error with no changes.
'			XgrGetGridClip()
'				- assume clipGrid is valid
'			XgrDestroyGrid()
'				- scan all grids sharing this window
'				- If any use this grid as clipGrid, set clipGrid = 0, disable clipping.
'			XgrCloneGrid()
'				- clipGrid = 0; disable clipping		(ie:  clipping doesn't clone)
'
FUNCTION  XgrSetGridClip (grid, clipGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IFZ clipGrid THEN
		gridInfo[grid].clipGrid = 0
	ELSE
		IFF InvalidGrid (clipGrid) THEN
			IF (gridInfo[grid].window = gridInfo[clipGrid].window) THEN
				gridInfo[grid].clipGrid = clipGrid
			END IF
		END IF
	END IF
END FUNCTION
'
'
' ######################################
' #####  XgrSetGridDrawingMode ()  #####
' ######################################
'
'		No action here, required action is performed just prior to draw.
'
FUNCTION  XgrSetGridDrawingMode (grid, drawMode, lineStyle, lineWidth)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IF (drawMode	!= -1) THEN
		newDrawMode = drawMode
		IF (newDrawMode > 3) THEN newDrawMode = $$DrawCOPY
		gridInfo[grid].drawMode = newDrawMode
	END IF
'
	IF (lineStyle	!= -1) THEN
		newLineStyle = lineStyle
		IF ((lineStyle AND 0xF) > 4) THEN newLineStyle = lineStyle AND 0xFFFFFFF0
		gridInfo[grid].lineStyle = newLineStyle
	END IF
'
	IF (lineWidth	!= -1) THEN
		newLineWidth = lineWidth
		IF (lineWidth <= 0) THEN newLineWidth = 1
		gridInfo[grid].lineWidth = newLineWidth
	END IF
END FUNCTION
'
'
' ###############################
' #####  XgrSetGridFont ()  #####
' ###############################
'
FUNCTION  XgrSetGridFont (grid, font)
	SHARED  xgrError
	SHARED  GRIDINFO  gridInfo[]
	SHARED  FONTINFO  fontInfo[]
	SHARED  fontPtr
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IF ((font < 0) OR (font > fontPtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
	IF font THEN
		IFZ fontInfo[font].font THEN
			xgrError = $$XgrInvalidArgument
			RETURN ($$TRUE)
		END IF
	END IF
	gridInfo[grid].font = font
END FUNCTION
'
'
' ###################################
' #####  XgrSetGridFunction ()  #####
' ###################################
'
FUNCTION  XgrSetGridFunction (grid, func)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	gridInfo[grid].func = func
END FUNCTION
'
'
' #################################
' #####  XgrSetGridParent ()  #####
' #################################
'
FUNCTION  XgrSetGridParent (grid, parent)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IFZ parent THEN
		gridInfo[grid].parentGrid = 0
	ELSE
		IFF InvalidGrid (parent) THEN
			IF (gridInfo[grid].window = gridInfo[parent].window) THEN
				gridInfo[grid].parentGrid = parent
			END IF
		END IF
	END IF
END FUNCTION
'
'
' ##########################################
' #####  XgrSetGridPositionAndSize ()  #####
' ##########################################
'
FUNCTION  XgrSetGridPositionAndSize (grid, x, y, width, height)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IF ((x AND y AND width AND height) = -1) THEN RETURN ($$FALSE)
'
	parent = gridInfo[grid].parentGrid
	IFZ parent THEN
		xWin = x
		yWin = y
	ELSE
		IF InvalidGrid (grid) THEN RETURN ($$TRUE)
		xWin = gridInfo[parent].winBox.x1 + x
		yWin = gridInfo[parent].winBox.y1 + y
	END IF
'
	IF (x = -1) THEN xWin = gridInfo[grid].winBox.x1
	IF (y = -1) THEN yWin = gridInfo[grid].winBox.y1
	IF (width <= 0) THEN width = gridInfo[grid].width
	IF (height <= 0) THEN height = gridInfo[grid].height
'
	sameSize = (width = gridInfo[grid].width) AND (height = gridInfo[grid].height)
'
	x1Win = xWin
	y1Win = yWin
	x2Win = xWin + width - 1
	y2Win = yWin + height - 1
'
'	update winBox
'
	gridInfo[grid].winBox.x1 = x1Win
	gridInfo[grid].winBox.y1 = y1Win
	gridInfo[grid].winBox.x2 = x2Win
	gridInfo[grid].winBox.y2 = y2Win
'
'	update gridBox
'
	x1Grid = gridInfo[grid].gridBox.x1
	y1Grid = gridInfo[grid].gridBox.y1
	x2Grid = gridInfo[grid].gridBox.x2
	y2Grid = gridInfo[grid].gridBox.y2
'
	IF (x1Grid <= x2Grid) THEN gdx = x2Win - x1Win ELSE gdx = x1Win - x2Win
	IF (y1Grid <= y2Grid) THEN gdy = y2Win - y1Win ELSE gdy = y1Win - y2Win
'
	IFF sameSize THEN
		gridInfo[grid].width = width
		gridInfo[grid].height = height
		gridInfo[grid].gridBox.x2 = x1Grid + gdx				' x1Grid unchanged
		gridInfo[grid].gridBox.y2 = y1Grid + gdy				' y1Grid unchanged
	END IF
'
	IF sameSize THEN RETURN ($$FALSE)									' no change: scale/window/image
'
'	Resized:	Reset xyScale
'
	x1# = gridInfo[grid].gridBoxScaled.x1
	y1# = gridInfo[grid].gridBoxScaled.y1
	x2# = gridInfo[grid].gridBoxScaled.x2
	y2# = gridInfo[grid].gridBoxScaled.y2
'
	dxScaled# = x2# - x1#
	dyScaled# = y2# - y1#
'
	IFZ dxScaled# THEN
		gridInfo[grid].xScale = 1#
	ELSE
		gridInfo[grid].xScale = DOUBLE(width-1) / dxScaled#
	END IF
'
	IFZ (width - 1) THEN
		gridInfo[grid].xInvScale = 1#
	ELSE
		gridInfo[grid].xInvScale = dxScaled# / DOUBLE(width-1)
	END IF
'
	IFZ dyScaled# THEN
		gridInfo[grid].yScale = 1#
	ELSE
		gridInfo[grid].yScale = DOUBLE(height-1) / dyScaled#
	END IF
'
	IFZ (height - 1) THEN
		gridInfo[grid].yInvScale = 1#
	ELSE
		gridInfo[grid].yInvScale = dyScaled# / DOUBLE(height-1)
	END IF
'
	IF (gridInfo[grid].gridType != GT_Image) THEN RETURN ($$FALSE)
'
'	Resizing GT_Image:  free sysImage
'
	sysImage = gridInfo[grid].sysImage
	IF sysImage THEN DestroySysImage (grid, sysImage)
END FUNCTION
'
'
' ################################
' #####  XgrSetGridState ()  #####
' ################################
'
' Disable only prevents all Xgr events (including mouse, keyboard,
' enter/exit, redraw).  It prevents selection as ClosestGrid to
' pointer.  It does NOT terminate keyboard or mouse focus, just
'	messages.  (So if reenable, focus kicks in as it was.)
'
' Other events (#Create, #Destroy, #Enable, etc) are NOT disabled
' so grid function must handle appropriately.
'
FUNCTION  XgrSetGridState (grid, state)
	SHARED  GRIDINFO  gridInfo[]
'
	IFZ state THEN disabled = $$TRUE ELSE disabled = $$FALSE
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	gridInfo[grid].disabled = disabled
END FUNCTION
'
'
' ################################
' #####  XgrSetGridTimer ()  #####
' ################################
'
'	Set timer interrupt for grid
'
'	in			:	grid
'						msTimeInterval
'
'	out			:	none
'
'	return	:	$$FALSE = no errors
'						$$TRUE = error
'
' Must be a one-shot else run the risk of filling the queue.
' SetTimer() resets timer, so KillTimer() is called after every timeout.
' SetTimer() second arg is the timerID used in KillTimer() = grid.
'	This will cause problems if grid numbers exceed 0xFFFF.
' SetTimer() WM_Timer message goes into application queue in this usage.
'
FUNCTION  XgrSetGridTimer (grid, msec)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = $$FALSE
'
	window = gridInfo[grid].window
	hwnd = windowInfo[window].hwnd
'
	timeOutID = gridInfo[grid].timeOutID
	IF timeOutID THEN
		##LOCKOUT = $$TRUE
		KillTimer (hwnd, grid)
		##LOCKOUT = lockout
	END IF
'
	timeOutID = 0
	IF msec THEN
		##LOCKOUT = $$TRUE
		timeOutID = SetTimer (hwnd, grid, msec, 0)
		##LOCKOUT = lockout
	END IF
'
	gridInfo[grid].timeOutID = timeOutID
	##WHOMASK = whomask
END FUNCTION
'
'
' ###############################
' #####  XgrSetGridType ()  #####
' ###############################
'
FUNCTION  XgrSetGridType (grid, gridType)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  winGrid[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	oldGridType = gridInfo[grid].gridType
	IF (gridType = oldGridType) THEN RETURN ($$FALSE)			' no change
'
	gridInfo[grid].gridType = gridType
'
'	Clean up if changing from GT_Image
'
	window = gridInfo[grid].window
	IF ((oldGridType = GT_Image) AND (gridType != GT_Image)) THEN
'
'		Destroying GT_Image:  free sysImage
'
		sysImage = gridInfo[grid].sysImage
		IF sysImage THEN DestroySysImage (grid, sysImage)
'
'		Remove references to bufferGrid as buffer for other grids
'
		uWinGrids = UBOUND(winGrid[window,])
		FOR i = 0 TO uWinGrids
			winGrid = winGrid[window,i]
			IFZ winGrid THEN DO NEXT
			IF (gridInfo[winGrid].bufferGrid = grid) THEN
				gridInfo[winGrid].bufferGrid = 0
			END IF
		NEXT i
	END IF
END FUNCTION
'
'
' ###########################
' #####  XgrDrawArc ()  #####
' ###########################
'
FUNCTION  XgrDrawArc (grid, color, r, startAngle#, endAngle#)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[],  points#[]
	SHARED  GT_Image
'
	$ARC_UNITS_PER_TWOPI = 0d40ACA5DC1A63C1F8			' 360 * 64 / $$TWOPI
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window		= gridInfo[grid].window
	hdc				= windowInfo[window].hdc
	clipGrid	= gridInfo[grid].clipGrid					' clipGrid always valid (or 0)
'
	x				= gridInfo[grid].drawpoint.x
	y				= gridInfo[grid].drawpoint.y
	xWin		= gridInfo[grid].winBox.x1
	yWin		= gridInfo[grid].winBox.y1
	left		= x - r
	top			= y - r
	right		= x + r + 1													' include last pixel
	bottom	= y + r + 1
	x1			= x + 1024# * COS(startAngle#)
	y1			= y - 1024# * SIN(startAngle#)
	x2			= x + 1024# * COS(endAngle#)
	y2			= y - 1024# * SIN(endAngle#)
'
'	Set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		IF windowInfo[window].clipIsNull THEN			' Null intersection
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'		xy is upper left corner, not center
'
		IF (windowInfo[window].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			Arc (hdc, left, top, right, bottom, xWin+x1, yWin+y1, xWin+x2, yWin+y2)
'			GetQueueStatus ($$QS_ALLEVENTS)
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	##LOCKOUT = $$TRUE
	Arc (ntImageInfo.hdcImage, left, top, right, bottom, x1, y1, x2, y2)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ###############################
' #####  XgrDrawArcGrid ()  #####
' ###############################
'
FUNCTION  XgrDrawArcGrid (grid, color, r, startAngle#, endAngle#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xGrid, @yGrid)
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawArc (grid, color, r, startAngle#, endAngle#)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
'
' #################################
' #####  XgrDrawArcScaled ()  #####
' #################################
'
FUNCTION  XgrDrawArcScaled (grid, color, r#, startAngle#, endAngle#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @x#, @y#)
	XgrConvertScaledToLocal (grid, x#, y#, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawArc (grid, color, r, startAngle#, endAngle#)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ##############################
' #####  XgrDrawBorder ()  #####
' ##############################
'
FUNCTION  XgrDrawBorder (grid, border, back, lo, hi, x1, y1, x2, y2)
	SHARED	GRIDINFO	gridInfo[]
	STATIC  points[]
'
	IFZ points[] THEN GOSUB Initialize
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IF ((border < 0) OR (border > $$BorderUpper)) THEN border = gridInfo[grid].border
'
	IF (back = -1) THEN back = gridInfo[grid].backColor
	IF (lo = -1) THEN lo = gridInfo[grid].lowColor
	IF (hi = -1) THEN hi = gridInfo[grid].highColor
	lot = gridInfo[grid].lowTextColor
	hit = gridInfo[grid].highTextColor
'
	XgrGetDrawpoint (grid, @xx, @yy)
'
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
	XgrSetDrawpoint (grid, xx, yy)
	RETURN ($$FALSE)
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
	XgrDrawLines (grid, lo, 0, 4, @points[])
	points[0] = x1			: points[1] = y2 - 1		' Line 0
	points[2] = x1			: points[3] = y1
	points[4] = x1			: points[5] = y1				' Line 1
	points[6] = x2 - 1	: points[7] = y1
	points[8] = x2 - 1	: points[9] = y1				' Line 2
	points[10] = x2 - 1	: points[11] = y2 - 1
	points[12] = x2 - 1	: points[13] = y2 - 1		' Line 3
	points[14] = x1			: points[15] = y2 - 1
	XgrDrawLines (grid, hi, 0, 4, @points[])
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
	XgrDrawLines (grid, lo, 0, 4, @points[])
	points[0] = x1 + 1	: points[1] = y2				' Line 0
	points[2] = x1 + 1	: points[3] = y1 + 1
	points[4] = x1 + 1	: points[5] = y1 + 1		' Line 1
	points[6] = x2			: points[7] = y1 + 1
	points[8] = x2			: points[9] = y1 + 1		' Line 2
	points[10] = x2			: points[11] = y2
	points[12] = x2			: points[13] = y2				' Line 3
	points[14] = x1 + 1	: points[15] = y2
	XgrDrawLines (grid, hi, 0, 4, @points[])
END SUB
'
'
' *****  Wide  *****  Up = 1, Flat = 2, Down = 1  *****
'
SUB Wide
	GOSUB DrawBorder1												' draw up-slope outside
	xhi	= hi
	xlo	= lo
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= back															' flat
	lo	= back															' flat
	n		= 2																	' flat is 2 pixels wide
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
' *****  WideResize  *****  Up = 1, Flat = 4, Down = 1, Resize marks  *****
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
'
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
	XgrDrawLines (grid, lo, 0, 8, @points[])
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
	XgrDrawLines (grid, hi, 0, 8, @points[])
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
' *****  DrawBorder1  *****  1 pixel wide border
'
SUB DrawBorder1
	points[0] = x1	: points[1] = y1		' left-edge
	points[2] = x1	: points[3] = y2
	points[4] = x1	: points[5] = y1		' top-edge
	points[6] = x2	: points[7] = y1
	XgrDrawLines (grid, hi, 0, 2, @points[])
	points[0] = x2	: points[1] = y1		' right-edge
	points[2] = x2	: points[3] = y2
	points[4] = x1	: points[5] = y2		' bottom-edge
	points[6] = x2	: points[7] = y2
	XgrDrawLines (grid, lo, 0, 2, @points[])
END SUB
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
	XgrDrawLines (grid, hi, 0, (n << 1), @points[])
'
	j = 0
	FOR i = 0 TO n - 1
		points[j    ] = x1 + i	: points[j + 1] = y2 - i			' right
		points[j + 2] = x2 - i	: points[j + 3] = y2 - i
		points[j + 4] = x2 - i	: points[j + 5] = y2 - i			' lower
		points[j + 6] = x2 - i	: points[j + 7] = y1 + i
		j = j + 8
	NEXT i
	XgrDrawLines (grid, lo, 0, (n << 1), @points[])
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
	whomask = ##WHOMASK
	##WHOMASK = $$FALSE
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
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrConvertGridToLocal (grid, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (grid, x2Grid, y2Grid, @x2, @y2)
	XgrDrawBorder (grid, border, back, lo, hi, x1, y1, x2, y2)
END FUNCTION
'
'
' ####################################
' #####  XgrDrawBorderScaled ()  #####
' ####################################
'
FUNCTION  XgrDrawBorderScaled (grid, border, back, lo, hi, x1#, y1#, x2#, y2#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrConvertScaledToLocal (grid, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (grid, x2#, y2#, @x2, @y2)
	XgrDrawBorder (grid, border, back, lo, hi, x1, y1, x2, y2)
END FUNCTION
'
'
' ###########################
' #####  XgrDrawBox ()  #####
' ###########################
'
FUNCTION  XgrDrawBox (grid, color, x1, y1, x2, y2)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid					' clipGrid always valid (or 0)
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
' *** SVG -	not necessary to check order, Polyline doesn't care
'
'	Set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		IF windowInfo[window].clipIsNull THEN			' Null intersection
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'	compute window coordinates of box corners
'
		points[0] = xWin + x1			' x : upper left
		points[1] = yWin + y1			' y : upper left
		points[2] = xWin + x2			' x : upper right
		points[3] = yWin + y1			' y : upper right
		points[4] = xWin + x2			' x : lower right
		points[5] = yWin + y2			' y : lower right
		points[6] = xWin + x1			' x : lower left
		points[7] = yWin + y2			' y : lower left
		points[8]	= xWin + x1			' x : upper left
		points[9] = yWin + y1			' y : upper left
'
		IF (windowInfo[window].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			Polyline (hdc, &points[], 5)
'			GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF

	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF

	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	compute local coordinates of box corners
'
	points[0] = x1			' x : upper left
	points[1] = y1			' y : upper left
	points[2] = x2			' x : upper right
	points[3] = y1			' y : upper right
	points[4] = x2			' x : lower right
	points[5] = y2			' y : lower right
	points[6] = x1			' x : lower left
	points[7] = y2			' y : lower left
	points[8]	= x1			' x : upper left
	points[9] = y1			' y : upper left
'
	##LOCKOUT = $$TRUE
	Polyline (ntImageInfo.hdcImage, &points[], 5)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ###############################
' #####  XgrDrawBoxGrid ()  #####
' ###############################
'
FUNCTION  XgrDrawBoxGrid (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrConvertGridToLocal (grid, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (grid, x2Grid, y2Grid, @x2, @y2)
	XgrDrawBox (grid, color, x1, y1, x2, y2)
END FUNCTION
'
'
' #################################
' #####  XgrDrawBoxScaled ()  #####
' #################################
'
FUNCTION  XgrDrawBoxScaled (grid, color, x1#, y1#, x2#, y2#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrConvertScaledToLocal (grid, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (grid, x2#, y2#, @x2, @y2)
	XgrDrawBox (grid, color, x1, y1, x2, y2)
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
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[],  points#[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid							' clipGrid always valid (or 0)
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	x = gridInfo[grid].drawpoint.x
	y = gridInfo[grid].drawpoint.y
	hdc = windowInfo[window].hdc
'
'	Set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		IF windowInfo[window].clipIsNull THEN			' Null intersection
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		left = xWin + x - rx
		top = yWin + y - ry
		right = xWin + x + rx + 1
		bottom	= yWin + y + ry + 1
'
' NOTE : Ellipse() was wrong choice - it draws the circle, but also clears its innards
'
		IF (windowInfo[window].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
'			Ellipse (hdc, left, top, right, bottom)									' error - clears center of circle
			Arc (hdc, left, top, right, bottom, x, y-ry, x, y-ry)
'			GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF

	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF

	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	left = x - rx
	top = y - ry
	right = x + rx + 1				' v0.0432 : SVG : added the "+ 1"
	bottom = y + ry + 1			' v0.0432 : SVG : added the "+ 1"
'
' NOTE : Ellipse() was wrong choice - it draws the circle, but also clears its innards
'
	##LOCKOUT = $$TRUE
'	Ellipse (ntImageInfo.hdcImage, left, top, right, bottom)
	Arc (ntImageInfo.hdcImage, left, top, right, bottom, x, y-ry, x, y-ry)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
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
	SHARED	GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	back = gridInfo[grid].backColor
	low = gridInfo[grid].lowColor
	high = gridInfo[grid].highColor
'
	left = gridInfo[grid].borderOffsetLeft
	top = gridInfo[grid].borderOffsetTop
	right = gridInfo[grid].borderOffsetRight
	bottom = gridInfo[grid].borderOffsetBottom
'
	XgrGetGridBoxLocal (grid, @x1, @y1, @x2, @y2)
	XgrDrawBorder (grid, border, back, low, high, x1+left, y1+top, x2+right, y2+bottom)
END FUNCTION
'
'
' ############################
' #####  XgrDrawIcon ()  #####
' ############################
'
FUNCTION  XgrDrawIcon (grid, icon, x, y)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  iconHandle[],  iconPtr
	SHARED  points[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IF ((icon < 0) OR (icon >= iconPtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
	hIcon = iconHandle[icon]
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		IF windowInfo[window].clipIsNull THEN			' no overlap
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		IF (windowInfo[window].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			DrawIcon (hdc, xWin + x, yWin + y, hIcon)
'			GetQueueStatus ($$QS_ALLEVENTS)
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN			' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	##LOCKOUT = $$TRUE
	DrawIcon (ntImageInfo.hdcImage, x, y, hIcon)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ################################
' #####  XgrDrawIconGrid ()  #####
' ################################
'
FUNCTION  XgrDrawIconGrid (grid, icon, xGrid, yGrid)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x, @y)
	XgrDrawIcon (grid, icon, x, y)
END FUNCTION
'
'
' ##################################
' #####  XgrDrawIconScaled ()  #####
' ##################################
'
FUNCTION  XgrDrawIconScaled (grid, icon, x#, y#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrConvertScaledToLocal (grid, x#, y#, @x, @y)
	XgrDrawIcon (grid, icon, x, y)
END FUNCTION
'
'
' ############################
' #####  XgrDrawLine ()  #####
' ############################
'
FUNCTION  XgrDrawLine (grid, color, x1, y1, x2, y2)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
'	compute endpoints in window coordinates
'
	points[0] = xWin + x1
	points[1] = yWin + y1
	points[2] = xWin + x2
	points[3] = yWin + y2
'
' #####  v0.0432 : SVG
'
	numPoints = 2
	IF (gridInfo[grid].lineWidth < 2) THEN
		points[4] = xWin + x2 + 1
		points[5] = yWin + y2
		numPoints = 3
	END IF
'
' update draw point
'
	gridInfo[grid].drawpoint.x = x2
	gridInfo[grid].drawpoint.y = y2
'
'	#####
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw to window coords
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				Polyline (hdc, &points[], numPoints)
'				GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN									' no overlap
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	compute endpoints in local coordinates
'
	points[0] = x1
	points[1] = y1
	points[2] = x2
	points[3] = y2
	points[4] = x2 + 1
	points[5] = y2
'
	##LOCKOUT = $$TRUE
	Polyline (ntImageInfo.hdcImage, &points[], numPoints)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ################################
' #####  XgrDrawLineGrid ()  #####
' ################################
'
FUNCTION  XgrDrawLineGrid (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xGrid, @yGrid)
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x, @y)
	XgrConvertGridToLocal (grid, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (grid, x2Grid, y2Grid, @x2, @y2)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawLine (grid, color, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointGrid (grid, x2Grid, y2Grid)
END FUNCTION
'
'
' ##################################
' #####  XgrDrawLineScaled ()  #####
' ##################################
'
FUNCTION  XgrDrawLineScaled (grid, color, x1#, y1#, x2#, y2#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @x#, @y#)
	XgrConvertScaledToLocal (grid, x#, y#, @x, @y)
	XgrConvertScaledToLocal (grid, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (grid, x2#, y2#, @x2, @y2)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawLine (grid, color, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointScaled (grid, x2#, y2#)
END FUNCTION
'
'
' ##############################
' #####  XgrDrawLineTo ()  #####
' ##############################
'
FUNCTION  XgrDrawLineTo (grid, color, x, y)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[],  points#[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
	x1 = gridInfo[grid].drawpoint.x
	y1 = gridInfo[grid].drawpoint.y
	x2 = x
	y2 = y
'
	points[0] = xWin + x1
	points[1] = yWin + y1
	points[2] = xWin + x2
	points[3] = yWin + y2
	points[4] = xWin + x2 + 1
	points[5] = yWin + y2
'
' #####  v0.0432 : SVG
'
	numPoints = 2
	IF (gridInfo[grid].lineWidth < 2) THEN numPoints = 3
'
' update draw point
'
	gridInfo[grid].drawpoint.x = x2
	gridInfo[grid].drawpoint.y = y2
'
'	#####
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				Polyline (hdc, &points[], numPoints)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	points[0] = x1
	points[1] = y1
	points[2] = x2
	points[3] = y2
	points[4] = x2 + 1
	points[5] = y2
'
	##LOCKOUT = $$TRUE
	Polyline (ntImageInfo.hdcImage, &points[], numPoints)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##################################
' #####  XgrDrawLineToGrid ()  #####
' ##################################
'
FUNCTION  XgrDrawLineToGrid (grid, color, xGrid, yGrid)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @x1Grid, @y1Grid)
	XgrConvertGridToLocal (grid, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x2, @y2)
	XgrDrawLine (grid, color, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointGrid (grid, xGrid, yGrid)
END FUNCTION
'
'
' ####################################
' #####  XgrDrawLineToScaled ()  #####
' ####################################
'
FUNCTION  XgrDrawLineToScaled (grid, color, x#, y#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @x1#, @y1#)
	XgrConvertScaledToLocal (grid, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (grid, x#, y#, @x2, @y2)
	XgrDrawLine (grid, color, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointScaled (grid, x#, y#)
END FUNCTION
'
'
' ###################################
' #####  XgrDrawLineToDelta ()  #####
' ###################################
'
FUNCTION  XgrDrawLineToDelta (grid, color, dx, dy)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
	x1 = gridInfo[grid].drawpoint.x
	y1 = gridInfo[grid].drawpoint.y
	x2 = x1 + dx
	y2 = y1 + dy
'
	points[0] = xWin + x1
	points[1] = yWin + y1
	points[2] = xWin + x2
	points[3] = yWin + y2
	points[4] = xWin + x2 + 1
	points[5] = yWin + y2
'
' #####  v0.0432 : SVG
'
	numPoints = 2
	IF (gridInfo[grid].lineWidth < 2) THEN numPoints = 3
'
' update draw point
'
	gridInfo[grid].drawpoint.x = x2
	gridInfo[grid].drawpoint.y = y2
'
'	#####
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				Polyline (hdc, &points[], numPoints)
'				GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF

	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	points[0] = x1
	points[1] = y1
	points[2] = x2
	points[3] = y2
	points[4] = x2 + 1
	points[5] = y2
'
	##LOCKOUT = $$TRUE
	Polyline (ntImageInfo.hdcImage, &points[], numPoints)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' #######################################
' #####  XgrDrawLineToDeltaGrid ()  #####
' #######################################
'
FUNCTION  XgrDrawLineToDeltaGrid (grid, color, dxGrid, dyGrid)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @x1Grid, @y1Grid)
'
	x2Grid = x1Grid + dxGrid
	y2Grid = y1Grid + dyGrid
'
	XgrConvertGridToLocal (grid, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (grid, x2Grid, y2Grid, @x2, @y2)
	XgrDrawLine (grid, color, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointGrid (grid, x2Grid, y2Grid)
END FUNCTION
'
'
' #########################################
' #####  XgrDrawLineToDeltaScaled ()  #####
' #########################################
'
FUNCTION  XgrDrawLineToDeltaScaled (grid, color, dx#, dy#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @x1#, @y1#)
'
	x2# = x1# + dx#
	y2# = y1# + dy#
'
	XgrConvertScaledToLocal (grid, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (grid, x2#, y2#, @x2, @y2)
	XgrDrawLine (grid, color, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointScaled (grid, x2#, y2#)
END FUNCTION
'
'
' #############################
' #####  XgrDrawLines ()  #####
' #############################
'
FUNCTION  XgrDrawLines (grid, color, start, count, lines[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  operatingSystem
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IFZ count THEN RETURN ($$FALSE)
'
	IFZ lines[] THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF ((start < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE (lines[])
	IF (theType != $$XLONG) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 2										' first = array element #
	last = first + (count << 2) - 1				' last = array element #
	upper = UBOUND(lines[])
	IF (upper < last) THEN last = upper
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
'	PolyPolyline() needs window coordinates
'		Above first/count are point-pairs (x1,y1,x2,y2)
'		This is half the number of points (x1,y1)
'		This is a quarter the number of elements (x1)
'
	size = (last - first + 1) AND -4						' # of array elements (mod 4)
	segments = size >> 2												' # of lines to draw
	numPoints = 2																' number points per segment
	points = segments << 1											' total points for all segments
	IF (gridInfo[grid].lineWidth < 2) THEN			' include extra terminating point
		points = points + segments
		numPoints = 3
	END IF
	elements = (points << 1) - 1								' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertLocalToWinArray
'
' #####  v0.0432 : SVG
'
' update drawpoint
'
	index = last - 2
	gridInfo[grid].drawpoint.x = lines[index]
	gridInfo[grid].drawpoint.y = lines[index + 1]
'
'	PolyPolyline() needs to know the number of points in each segment
'
	IF (operatingSystem = $$WindowsNT) THEN
		DIM polyCounts[segments - 1]
		FOR i = 0 TO (segments - 1)
			polyCounts[i] = numPoints
		NEXT i
	END IF
'
'	#####
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				IF (operatingSystem = $$WindowsNT) THEN
					##LOCKOUT = $$TRUE
					PolyPolyline (hdc, &pointsWin[], &polyCounts[], segments)
'					GetQueueStatus ($$QS_ALLEVENTS)
					##LOCKOUT = entryLOCKOUT
				ELSE
					index = 0
					numXY = numPoints << 1
					FOR i = 0 TO segments - 1
						##LOCKOUT = $$TRUE
						Polyline (hdc, &pointsWin[index], numPoints)
'						GetQueueStatus ($$QS_ALLEVENTS)
						##LOCKOUT = entryLOCKOUT
						index = index + numXY
					NEXT i
				END IF
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN									' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	oIndex = 0
	FOR i = 1 TO segments
		FOR j = 1 TO numPoints
			pointsWin[oIndex] = pointsWin[oIndex] - ixUL : INC oIndex
			pointsWin[oIndex] = pointsWin[oIndex] - iyUL : INC oIndex
		NEXT j
	NEXT i
	IF (operatingSystem = $$WindowsNT) THEN
		##LOCKOUT = $$TRUE
		PolyPolyline (ntImageInfo.hdcImage, &pointsWin[], &polyCounts[], segments)
		##LOCKOUT = entryLOCKOUT
	ELSE
		index = 0
		numXY = numPoints << 1
		FOR i = 0 TO segments - 1
			##LOCKOUT = $$TRUE
			Polyline (ntImageInfo.hdcImage, &pointsWin[index], numPoints)
			##LOCKOUT = entryLOCKOUT
			index = index + numXY
		NEXT i
	END IF
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertLocalToWinArray  *****
'
SUB ConvertLocalToWinArray
	firstPoint = first
	lastPoint = firstPoint + segments + segments - 1
	iIndex = firstPoint
	oIndex = 0
	pair = 0
'
	xULWin	= gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin	= gridInfo[grid].winBox.y1
'
	FOR i = firstPoint TO lastPoint
		xWin = xULWin + lines[iIndex]
		pointsWin[oIndex] = xWin
'
		INC iIndex
		INC oIndex
		yWin = yULWin + lines[iIndex]
		pointsWin[oIndex] = yWin
'
		IF (numPoints = 3) THEN
			IF (pair AND 0x01) THEN
				INC oIndex
				pointsWin[oIndex] = xWin + 1
				INC oIndex
				pointsWin[oIndex] = yWin
			END IF
		END IF
'
		INC iIndex
		INC oIndex
		INC pair
	NEXT i
END SUB
END FUNCTION
'
'
' #################################
' #####  XgrDrawLinesGrid ()  #####
' #################################
'
FUNCTION  XgrDrawLinesGrid (grid, color, start, count, lines[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  operatingSystem
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ count THEN RETURN ($$FALSE)
'
	IFZ lines[] THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF ((start < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE (lines[])
	IF (theType != $$XLONG) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 2										' first = array element #
	last = first + (count << 2) - 1				' last = array element #
	upper = UBOUND(lines[])
	IF (upper < last) THEN last = upper
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
'	PolyPolyline() needs window coordinates
'		Above first/count are point-pairs (x1,y1,x2,y2)
'		This is half the number of points (x1,y1)
'		This is a quarter the number of elements (x1)
'
	size = (last - first + 1) AND -4						' # of array elements (mod 4)
	segments = size >> 2												' # of lines to draw
	numPoints = 2																' number points per segment
	points = segments << 1											' total points for all segments
	IF (gridInfo[grid].lineWidth < 2) THEN			' include extra terminating point
		points = points + segments
		numPoints = 3
	END IF
	elements = (points << 1) - 1								' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertGridToWinArray
'
' #####  v0.0432 : SVG
'
' update drawpoint
'
	index = last - 2
	gridInfo[grid].drawpointGrid.x = lines[index]
	gridInfo[grid].drawpointGrid.y = lines[index + 1]
'
'	PolyPolyline() needs to know the number of points in each segment
'
	IF (operatingSystem = $$WindowsNT) THEN
		DIM polyCounts[segments - 1]
		FOR i = 0 TO (segments - 1)
			polyCounts[i] = numPoints
		NEXT i
	END IF
'
'	#####
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				IF (operatingSystem = $$WindowsNT) THEN
					##LOCKOUT = $$TRUE
					PolyPolyline (hdc, &pointsWin[], &polyCounts[], segments)
'					GetQueueStatus ($$QS_ALLEVENTS)
					##LOCKOUT = entryLOCKOUT
				ELSE
					index = 0
					numXY = numPoints << 1
					FOR i = 0 TO segments - 1
						##LOCKOUT = $$TRUE
						Polyline (hdc, &pointsWin[index], numPoints)
'						GetQueueStatus ($$QS_ALLEVENTS)
						##LOCKOUT = entryLOCKOUT
						index = index + numXY
					NEXT i
				END IF
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN									' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	oIndex = 0
	FOR i = 1 TO segments
		FOR j = 1 TO numPoints
			pointsWin[oIndex] = pointsWin[oIndex] - ixUL : INC oIndex
			pointsWin[oIndex] = pointsWin[oIndex] - iyUL : INC oIndex
		NEXT j
	NEXT i
	IF (operatingSystem = $$WindowsNT) THEN
		##LOCKOUT = $$TRUE
		PolyPolyline (ntImageInfo.hdcImage, &pointsWin[], &polyCounts[], segments)
		##LOCKOUT = entryLOCKOUT
	ELSE
		index = 0
		numXY = numPoints << 1
		FOR i = 0 TO segments - 1
			##LOCKOUT = $$TRUE
			Polyline (ntImageInfo.hdcImage, &pointsWin[index], numPoints)
			##LOCKOUT = entryLOCKOUT
			index = index + numXY
		NEXT i
	END IF
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertGridToWinArray  *****
'
SUB ConvertGridToWinArray
	firstPoint = first
	lastPoint = firstPoint + segments + segments - 1
	iIndex = firstPoint
	oIndex = 0
	pair = 0
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2
	yLR = gridInfo[grid].gridBox.y2
'
	xIncreasesRight = $$TRUE
	IF (xLR < xUL) THEN xIncreasesRight = $$FALSE
'
	yIncreasesDown = $$TRUE
	IF (yLR < yUL) THEN yIncreasesDown = $$FALSE
'
	FOR i = firstPoint TO lastPoint
		IF xIncreasesRight THEN
			xWin = xULWin + (lines[iIndex] - xUL)
		ELSE
			xWin = xULWin + (xUL - lines[iIndex])
		END IF
		pointsWin[oIndex] = xWin
'
		INC iIndex
		INC oIndex
		IF yIncreasesDown THEN
			yWin = yULWin + (lines[iIndex] - yUL)
		ELSE
			yWin = yULWin + (yUL - lines[iIndex])
		END IF
		pointsWin[oIndex] = yWin
'
		IF (numPoints = 3) THEN
			IF (pair AND 0x1) THEN						' Add third point
				INC oIndex
				pointsWin[oIndex] = xWin + 1
				INC oIndex
				pointsWin[oIndex] = yWin
			END IF
		END IF
'
		INC iIndex
		INC oIndex
		INC pair
	NEXT i
END SUB
END FUNCTION
'
'
' ###################################
' #####  XgrDrawLinesScaled ()  #####
' ###################################
'
FUNCTION  XgrDrawLinesScaled (grid, color, start, count, lines#[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  operatingSystem
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ count THEN RETURN ($$FALSE)
'
	IFZ lines#[] THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF ((first < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE (lines#[])
	IF (theType != $$DOUBLE) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 2
	last = first + (count << 2) - 1
	upper = UBOUND (lines#[])
	IF (upper < last) THEN last = upper
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window		= gridInfo[grid].window
	hdc				= windowInfo[window].hdc
	clipGrid	= gridInfo[grid].clipGrid					' clipGrid always valid (or 0)
'
'	PolyPolyline() needs window coordinates
'		Above first/last are point-pairs (x1,y1,x2,y2)
'		This is half the number of points (x1,y1)
'		It is a quarter the number of elements (x1)
'
	size = (last - first + 1) AND -4						' # of array elements (mod 4)
	segments = size >> 2												' # of lines to draw
	numPoints = 2																' number points per segment
	points = segments << 1											' total points for all segments
	IF (gridInfo[grid].lineWidth < 2) THEN			' include extra terminating point
		numPoints = 3
		points = points + segments
	END IF
'
' #####  v0.0432 : SVG
'
'	update draw point
'
	index = last - 1
	gridInfo[grid].drawpointScaled.x = lines#[index]
	gridInfo[grid].drawpointScaled.y = lines#[index + 1]
'
'	#####
'
	elements = (points << 1) - 1								' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertScaledToWinArray
'
'	PolyPolyline() needs to know the number of points in each segment
'
	IF (operatingSystem = $$WindowsNT) THEN
		DIM polyCounts[segments - 1]
		FOR i = 0 TO (segments - 1)
			polyCounts[i] = numPoints
		NEXT i
	END IF
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				IF (operatingSystem = $$WindowsNT) THEN
					##LOCKOUT = $$TRUE
					PolyPolyline (hdc, &pointsWin[], &polyCounts[], segments)
'					GetQueueStatus ($$QS_ALLEVENTS)
					##LOCKOUT = entryLOCKOUT
				ELSE
					index = 0
					numXY = numPoints << 1
					FOR i = 0 TO segments - 1
						##LOCKOUT = $$TRUE
						Polyline (hdc, &pointsWin[index], numPoints)
'						GetQueueStatus ($$QS_ALLEVENTS)
						##LOCKOUT = entryLOCKOUT
						index = index + numXY
					NEXT i
				END IF
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	oIndex = 0
	FOR i = 1 TO segments
		FOR j = 1 TO numPoints
			pointsWin[oIndex] = pointsWin[oIndex] - ixUL : INC oIndex
			pointsWin[oIndex] = pointsWin[oIndex] - iyUL : INC oIndex
		NEXT j
	NEXT i
	IF (operatingSystem = $$WindowsNT) THEN
		##LOCKOUT = $$TRUE
		PolyPolyline (ntImageInfo.hdcImage, &pointsWin[], &polyCounts[], segments)
		##LOCKOUT = entryLOCKOUT
	ELSE
		index = 0
		numXY = numPoints << 1
		FOR i = 0 TO segments - 1
			##LOCKOUT = $$TRUE
			Polyline (ntImageInfo.hdcImage, &pointsWin[index], numPoints)
			##LOCKOUT = entryLOCKOUT
			index = index + numXY
		NEXT i
	END IF
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertScaledToWinArray  *****
'
SUB ConvertScaledToWinArray
	firstPoint = first
	lastPoint = firstPoint + segments + segments - 1
	iIndex = firstPoint
	oIndex = 0
	pair = 0
'
	xULWin = gridInfo[grid].winBox.x1					' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1		' upper-left grid coordinate
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2		' lower-right grid coordinate
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xScale#	= gridInfo[grid].xScale
	yScale#	= gridInfo[grid].yScale
'
	FOR i = firstPoint TO lastPoint
		xWin = xULWin + ((lines#[iIndex] - xUL#) * xScale#)
		pointsWin[oIndex] = xWin
'
		INC iIndex
		INC oIndex
		yWin = yULWin + ((lines#[iIndex] - yUL#) * yScale#)
		pointsWin[oIndex] = yWin
'
		IF (numPoints = 3) THEN
			IF (pair AND 0x1) THEN						' Add third point
				INC oIndex
				pointsWin[oIndex] = xWin + 1
				INC oIndex
				pointsWin[oIndex] = yWin
			END IF
		END IF
'
		INC iIndex
		INC oIndex
		INC pair
	NEXT i
END SUB
END FUNCTION
'
'
' ###############################
' #####  XgrDrawLinesTo ()  #####
' ###############################
'
FUNCTION  XgrDrawLinesTo (grid, color, start, count, lines[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
'
	$COORD_MODE_ORIGIN	= 0
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ count THEN RETURN ($$FALSE)
'
	IFZ lines[] THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF ((start < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE(lines[])
	IF ((theType != $$XLONG) AND (theType != $$DOUBLE)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 1
	last = first + (count << 2) - 1
	upper = UBOUND(lines[])
	IF (upper < last) THEN last = upper
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window		= gridInfo[grid].window
	hdc				= windowInfo[window].hdc
	clipGrid	= gridInfo[grid].clipGrid					' clipGrid always valid (or 0)
'
'	Polyline() needs window coordinates
'		Above first/last are point-pairs (x1,y1,x2,y2)
'		This is half the number of points (x1,y1)
'		It is a quarter the number of elements (x1)
'
	size = (last - first + 1) AND -4						' # of array elements (mod 4)
	segments = size >> 1												' # of lines to draw
	numPoints = 2																' number points per segment
	points = segments << 1											' total points for all segments
	IF (gridInfo[grid].lineWidth < 2) THEN			' include extra terminating point
		INC terminator
		INC points
	END IF
	elements = (points << 1) - 1								' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertLocalToWinArray
'
	IF terminator THEN
		pointsWin[elements - 1] = pointsWin[elements - 3] + 1
		pointsWin[elements] = pointsWin[elements - 2]
	END IF
'
' #####  v0.0432 : SVG
'
' update draw point
'
		gridInfo[grid].drawpoint.x = lines[index]
		gridInfo[grid].drawpoint.y = lines[index + 1]
'
'	#####
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull

		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				Polyline (hdc, &pointsWin[], points)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF

	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	FOR i = 0 TO elements STEP 2
		pointsWin[i] = pointsWin[i] - ixUL
		pointsWin[i+1] = pointsWin[i+1] - iyUL
	NEXT i
	##LOCKOUT = $$TRUE
	Polyline (ntImageInfo.hdcImage, &pointsWin[], points)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertLocalToWinArray  *****
'
SUB ConvertLocalToWinArray
	firstPoint = first
	lastPoint = first + segments - 1
'
	x1Win	= gridInfo[grid].winBox.x1
	y1Win	= gridInfo[grid].winBox.y1
'
	iIndex = firstPoint
	oIndex = 0
	FOR i = firstPoint TO lastPoint
		xWin = x1Win + lines[iIndex]
		pointsWin[oIndex] = xWin
'
		INC iIndex
		INC oIndex
		yWin = y1Win + lines[iIndex]
		pointsWin[oIndex] = yWin
'
		INC iIndex
		INC oIndex
	NEXT i
END SUB
END FUNCTION
'
'
' ###################################
' #####  XgrDrawLinesToGrid ()  #####
' ###################################
'
FUNCTION  XgrDrawLinesToGrid (grid, color, start, count, lines[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
'
	$COORD_MODE_ORIGIN	= 0
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ count THEN RETURN ($$FALSE)
'
	IFZ lines[] THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF ((start < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE (lines[])
	IF ((theType != $$XLONG) AND (theType != $$DOUBLE)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 1
	last = first + (count << 2) - 1
	upper = UBOUND(lines[])
	IF (upper < last) THEN last = upper
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	hdc = windowInfo[window].hdc
'
'	Polyline() needs window coordinates
'		Above first/last are point-pairs (x1,y1,x2,y2)
'		This is half the number of points (x1,y1)
'		It is a quarter the number of elements (x1)
'
	size = (last - first + 1) AND -4						' # of array elements (mod 4)
	segments = size >> 1												' # of lines to draw
	numPoints = 2																' number points per segment
	points = segments << 1											' total points for all segments
	IF (gridInfo[grid].lineWidth < 2) THEN			' include extra terminating point
		INC terminator
		INC points
	END IF
	elements = (points << 1) - 1								' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertGridToWinArray
'
	IF terminator THEN
		pointsWin[elements - 1] = pointsWin[elements - 3] + 1
		pointsWin[elements] = pointsWin[elements - 2]
	END IF
'
' #####  v0.0432 : SVG
'
' update draw point
'
		gridInfo[grid].drawpointGrid.x = lines[index]
		gridInfo[grid].drawpointGrid.y = lines[index+1]
'
'	#####
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull

		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				Polyline (hdc, &pointsWin[], points)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF

	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	FOR i = 0 TO elements STEP 2
		pointsWin[i]			= pointsWin[i] - ixUL
		pointsWin[i + 1]	= pointsWin[i + 1] - iyUL
	NEXT i
	##LOCKOUT = $$TRUE
	Polyline (ntImageInfo.hdcImage, &pointsWin[], points)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertGridToWinArray  *****
'
SUB ConvertGridToWinArray
	firstPoint = first
	lastPoint = first + segments - 1
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1			' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2			' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	xIncreasesRight = $$TRUE
	IF (xLR < xUL) THEN xIncreasesRight = $$FALSE
'
	yIncreasesDown = $$TRUE
	IF (yLR < yUL) THEN yIncreasesDown = $$FALSE
'
	iIndex = firstPoint
	oIndex = 0
	FOR i = firstPoint TO lastPoint
		IF xIncreasesRight THEN
			xWin = xULWin + (lines[iIndex] - xUL)
		ELSE
			xWin = xULWin + (xUL - lines[iIndex])
		END IF
		pointsWin[oIndex] = xWin
'
		INC iIndex
		INC oIndex
		IF yIncreasesDown THEN
			yWin = yULWin + (lines[iIndex] - yUL)
		ELSE
			yWin = yULWin + (yUL - lines[iIndex])
		END IF
		pointsWin[oIndex] = yWin
'
		INC iIndex
		INC oIndex
	NEXT i
END SUB
END FUNCTION
'
'
' #####################################
' #####  XgrDrawLinesToScaled ()  #####
' #####################################
'
FUNCTION  XgrDrawLinesToScaled (grid, color, start, count, lines#[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
'
	$COORD_MODE_ORIGIN	= 0
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ count THEN RETURN ($$FALSE)
'
	IFZ lines#[] THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF ((start < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE (lines#[])
	IF (theType != $$DOUBLE) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 1
	last = first + (count << 2) - 1
	upper = UBOUND (lines#[])
	IF (upper < last) THEN last = upper
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	hdc = windowInfo[window].hdc
'
'	Polyline() needs window coordinates
'		Above first/segments are point-pairs (x1,y1,x2,y2)
'		This is half the number of points (x1,y1)
'		It is a quarter the number of elements (x1)
'
	size = (last - first + 1) AND -4						' # of array elements (mod 4)
	segments = size >> 1												' # of lines to draw
	points = segments << 1											' total points for all segments
	terminator = 0
	numPoints = 2																' number points per segment
	IF (gridInfo[grid].lineWidth < 2) THEN			' include extra terminating point
		INC terminator
		INC points
	END IF
	elements = (points << 1) - 1								' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertScaledToWinArray
'
	IF terminator THEN
		pointsWin[elements - 1] = pointsWin[elements - 3] + 1
		pointsWin[elements] = pointsWin[elements - 2]
	END IF
'
' #####  v0.0432 : SVG
'
'	update drawpoint
'
		index = last - 1
		gridInfo[grid].drawpointScaled.x = lines#[index]
		gridInfo[grid].drawpointScaled.y = lines#[index+1]
'
'	#####
'
'	set line color, mode, style, width
'
	SetLineAttributes (grid, color)
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				Polyline (hdc, &pointsWin[], points)
'				GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	FOR i = 0 TO elements STEP 2
		pointsWin[i] = pointsWin[i] - ixUL
		pointsWin[i+1] = pointsWin[i+1] - iyUL
	NEXT i
	##LOCKOUT = $$TRUE
	Polyline (ntImageInfo.hdcImage, &pointsWin[], points)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertScaledToWinArray  *****
'
SUB ConvertScaledToWinArray
	firstPoint = first
	lastPoint = first + segments - 1
'
	xULWin = gridInfo[grid].winBox.x1
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xScale#	= gridInfo[grid].xScale
	yScale#	= gridInfo[grid].yScale
'
	iIndex = firstPoint
	oIndex = 0
	FOR i = firstPoint TO lastPoint
		xWin = xULWin + ((lines#[iIndex] - xUL#) * xScale#)
		pointsWin[oIndex] = xWin
'
		INC iIndex
		INC oIndex
		yWin = yULWin + ((lines#[iIndex] - yUL#) * yScale#)
		pointsWin[oIndex] = yWin
'
		INC iIndex
		INC oIndex
	NEXT i
END SUB
END FUNCTION
'
'
' #############################
' #####  XgrDrawPoint ()  #####
' #############################
'
FUNCTION  XgrDrawPoint (grid, color, x, y)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  colorPixel[]
	SHARED  points[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
	points[0] = x1Win + x
	points[1] = y1Win + y
	points[2] = x1Win + x + 1
	points[3] = y1Win + y
'
' #####  v0.0432 : SVG
'
'	update drawpoint
'
	gridInfo[grid].drawpoint.x = x
	gridInfo[grid].drawpoint.y = y
'
'	#####
'
	SetPointAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				Polyline (hdc, &points[], 2)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	points[0] = x
	points[1] = y
	points[2] = x + 1
	points[3] = y
'
	##LOCKOUT = $$TRUE
	Polyline (ntImageInfo.hdcImage, &points[], 2)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' #################################
' #####  XgrDrawPointGrid ()  #####
' #################################
'
FUNCTION  XgrDrawPointGrid (grid, color, xGrid, yGrid)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x, @y)
	XgrDrawPoint (grid, color, x, y)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointGrid (grid, xGrid, yGrid)
END FUNCTION
'
'
' ###################################
' #####  XgrDrawPointScaled ()  #####
' ###################################
'
FUNCTION  XgrDrawPointScaled (grid, color, x#, y#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrConvertScaledToLocal (grid, x#, y#, @x, @y)
	XgrDrawPoint (grid, color, x, y)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointScaled (grid, x#, y#)
END FUNCTION
'
'
' ##############################
' #####  XgrDrawPoints ()  #####
' ##############################
'
FUNCTION  XgrDrawPoints (grid, color, start, count, @points[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  operatingSystem
	SHARED  GT_Image
'
	$COORD_MODE_ORIGIN	= 0
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IF ((start < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE (points[])
	IF (theType != $$XLONG) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 1
	last = first + (count << 1) - 1
	lastOK = UBOUND (points[]) >> 1
	IFZ count THEN last = lastOK
	IF (last < lastOK) THEN lastOK = last
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
'	PolyPolyline() needs window coordinates
'		Above first/lastOK are points (x,y)
'		This is half the number of elements (x)
'
	segments = lastOK - first + 1
	points = segments << 1										' include terminating points
	elements = (points << 1) - 1							' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertLocalToWinArray
'
' #####  v0.0432 : SVG
'
'	update drawpoint
'
		index = lastOK << 1
		gridInfo[grid].drawpoint.x = points[index]
		gridInfo[grid].drawpoint.y = points[index+1]
'
'	#####
'
'	PolyPolyline() needs to know the number of points in each segment (2)
'
	IF (operatingSystem = $$WindowsNT) THEN
		DIM polyCounts[segments - 1]
		FOR i = 0 TO (segments - 1)
			polyCounts[i] = 2
		NEXT i
	END IF
'
'	set line color, mode, style=SOLID, width=1
'
	SetPointAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				IF (operatingSystem = $$WindowsNT) THEN
					##LOCKOUT = $$TRUE
					PolyPolyline (hdc, &pointsWin[], &polyCounts[], segments)
'					GetQueueStatus ($$QS_ALLEVENTS)
					##LOCKOUT = entryLOCKOUT
				ELSE
					index = 0
					FOR i = 0 TO segments - 1
						##LOCKOUT = $$TRUE
						Polyline (hdc, &pointsWin[index], 2)
'						GetQueueStatus ($$QS_ALLEVENTS)
						##LOCKOUT = entryLOCKOUT
						index = index + 4
					NEXT i
				END IF
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN			' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	FOR i = 0 TO elements STEP 2
		pointsWin[i] = pointsWin[i] - ixUL
		pointsWin[i+1] = pointsWin[i + 1] - iyUL
	NEXT i
	IF (operatingSystem = $$WindowsNT) THEN
		##LOCKOUT = $$TRUE
		PolyPolyline (ntImageInfo.hdcImage, &pointsWin[], &polyCounts[], segments)
		##LOCKOUT = entryLOCKOUT
	ELSE
		index = 0
		FOR i = 0 TO segments - 1
			##LOCKOUT = $$TRUE
			Polyline (ntImageInfo.hdcImage, &pointsWin[index], 2)
			##LOCKOUT = entryLOCKOUT
			index = index + 4
		NEXT i
	END IF
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertLocalToWinArray  *****
'
SUB ConvertLocalToWinArray
	iIndex = first << 1
	oIndex = 0
'
	x1Win	= gridInfo[grid].winBox.x1
	y1Win	= gridInfo[grid].winBox.y1
'
	FOR i = first TO lastOK
		xWin = x1Win + points[iIndex]
		pointsWin[oIndex] = xWin
'
		INC iIndex
		INC oIndex
		yWin = y1Win + points[iIndex]
		pointsWin[oIndex] = yWin
'
		INC iIndex
		INC oIndex
		pointsWin[oIndex] = xWin + 1 : INC oIndex
		pointsWin[oIndex] = yWin : INC oIndex
	NEXT i
END SUB
END FUNCTION
'
'
' ##################################
' #####  XgrDrawPointsGrid ()  #####
' ##################################
'
FUNCTION  XgrDrawPointsGrid (grid, color, start, count, @points[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  operatingSystem
	SHARED  GT_Image
'
	$COORD_MODE_ORIGIN	= 0
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ count THEN RETURN ($$FALSE)
'
	IFZ points[] THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF

	IF ((start < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE (points[])
	IF (theType != $$XLONG) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 1
	last = first + (count << 1) - 1
	lastOK = UBOUND (points[]) >> 1
	IF (last < lastOK) THEN lastOK = last
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
'	PolyPolyline() needs window coordinates
'		Above first/lastOK are points (x,y)
'		This is half the number of elements (x)
'
	segments = lastOK - first + 1
	points = segments << 1										' include terminating points
	elements = (points << 1) - 1							' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertGridToWinArray
'
'	PolyPolyline() needs to know the number of points in each segment (2)
'
	IF (operatingSystem = $$WindowsNT) THEN
		DIM polyCounts[segments - 1]
		FOR i = 0 TO (segments - 1)
			polyCounts[i] = 2
		NEXT i
	END IF
'
' #####  v0.0432 : SVG
'
'	update drawpoint
'
		index = lastOK << 1
		gridInfo[grid].drawpointGrid.x = points[index]
		gridInfo[grid].drawpointGrid.y = points[index+1]
'
'	#####
'
'	set line color, mode, style=SOLID, width=1
'
	SetPointAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				IF (operatingSystem = $$WindowsNT) THEN
					##LOCKOUT = $$TRUE
					PolyPolyline (hdc, &pointsWin[], &polyCounts[], segments)
'					GetQueueStatus ($$QS_ALLEVENTS)
					##LOCKOUT = entryLOCKOUT
				ELSE
					index = 0
					FOR i = 0 TO segments - 1
						##LOCKOUT = $$TRUE
						Polyline (hdc, &pointsWin[index], 2)
'						GetQueueStatus ($$QS_ALLEVENTS)
						##LOCKOUT = entryLOCKOUT
						index = index + 4
					NEXT i
				END IF
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN			' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	FOR i = 0 TO elements STEP 2
		pointsWin[i] = pointsWin[i] - ixUL
		pointsWin[i+1] = pointsWin[i + 1] - iyUL
	NEXT i
	IF (operatingSystem = $$WindowsNT) THEN
		##LOCKOUT = $$TRUE
		PolyPolyline (ntImageInfo.hdcImage, &pointsWin[], &polyCounts[], segments)
		##LOCKOUT = entryLOCKOUT
	ELSE
		index = 0
		FOR i = 0 TO segments - 1
			##LOCKOUT = $$TRUE
			Polyline (ntImageInfo.hdcImage, &pointsWin[index], 2)
			##LOCKOUT = entryLOCKOUT
			index = index + 4
		NEXT i
	END IF
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertGridToWinArray  *****
'
SUB ConvertGridToWinArray
	iIndex = first << 1
	oIndex = 0
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1			' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2			' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	xIncreasesRight = $$TRUE
	IF (xLR < xUL) THEN xIncreasesRight = $$FALSE
'
	yIncreasesDown = $$TRUE
	IF (yLR < yUL) THEN yIncreasesDown = $$FALSE
'
	FOR i = first TO lastOK
		IF xIncreasesRight THEN
			xWin = xULWin + (points[iIndex] - xUL)
		ELSE
			xWin = xULWin + (xUL - points[iIndex])
		END IF
		pointsWin[oIndex] = xWin
		INC iIndex
		INC oIndex
'
		IF yIncreasesDown THEN
			yWin = yULWin + (points[iIndex] - yUL)
		ELSE
			yWin = yULWin + (yUL - points[iIndex])
		END IF
		pointsWin[oIndex] = yWin
		INC iIndex
		INC oIndex
'
		pointsWin[oIndex] = xWin + 1 : INC oIndex
		pointsWin[oIndex] = yWin : INC oIndex
	NEXT i
END SUB
END FUNCTION
'
'
' ####################################
' #####  XgrDrawPointsScaled ()  #####
' ####################################
'
FUNCTION  XgrDrawPointsScaled (grid, color, start, count, @points#[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  operatingSystem
	SHARED  GT_Image
'
	$COORD_MODE_ORIGIN	= 0
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IFZ count THEN RETURN ($$FALSE)
'
	IFZ points#[] THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF ((start < 0) OR (count < 0)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	theType = TYPE (points#[])
	IF (theType != $$DOUBLE) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	first = start << 1
	last = first + (count << 1) - 1
	lastOK = UBOUND(points#[]) >> 1
	IF (last < lastOK) THEN lastOK = last
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	hdc = windowInfo[window].hdc
'
'	PolyPolyline() needs window coordinates
'		Above first/lastOK are points (x,y)
'		This is half the number of elements (x)
'
	segments = lastOK - first + 1
	points = segments << 1								' include terminating points
	elements = (points << 1) - 1					' elements start at 0
	DIM pointsWin[elements]
	GOSUB ConvertScaledToWinArray
'
' #####  v0.0432 : SVG
'
' update drawpoint
'
	index = lastOK << 1
	gridInfo[grid].drawpointScaled.x = points#[index]
	gridInfo[grid].drawpointScaled.y = points#[index+1]
'
'	#####
'
'	PolyPolyline() needs to know the number of points in each segment (2)
'
	IF (operatingSystem = $$WindowsNT) THEN
		DIM polyCounts[segments - 1]
		FOR i = 0 TO (segments - 1)
			polyCounts[i] = 2
		NEXT i
	END IF
'
'	set line color, mode, style=SOLID, width=1
'
	SetPointAttributes (grid, color)
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				IF (operatingSystem = $$WindowsNT) THEN
					##LOCKOUT = $$TRUE
					PolyPolyline (hdc, &pointsWin[], &polyCounts[], segments)
'					GetQueueStatus ($$QS_ALLEVENTS)
					##LOCKOUT = entryLOCKOUT
				ELSE
					index = 0
					FOR i = 0 TO segments - 1
						##LOCKOUT = $$TRUE
						Polyline (hdc, &pointsWin[index], 2)
'						GetQueueStatus ($$QS_ALLEVENTS)
						##LOCKOUT = entryLOCKOUT
						index = index + 4
					NEXT i
				END IF
			END IF
		END IF
'
		IF clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	FOR i = 0 TO elements STEP 2
		pointsWin[i] = pointsWin[i] - ixUL
		pointsWin[i+1] = pointsWin[i+1] - iyUL
	NEXT i
	IF (operatingSystem = $$WindowsNT) THEN
		##LOCKOUT = $$TRUE
		PolyPolyline (ntImageInfo.hdcImage, &pointsWin[], &polyCounts[], segments)
		##LOCKOUT = entryLOCKOUT
	ELSE
		index = 0
		FOR i = 0 TO segments - 1
			##LOCKOUT = $$TRUE
			Polyline (ntImageInfo.hdcImage, &pointsWin[index], 2)
			##LOCKOUT = entryLOCKOUT
			index = index + 4
		NEXT i
	END IF
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'
'	*****  ConvertScaledToWinArray  *****
'
SUB ConvertScaledToWinArray
	iIndex = first << 1
	oIndex = 0
'
	xULWin = gridInfo[grid].winBox.x1
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xScale#	= gridInfo[grid].xScale
	yScale#	= gridInfo[grid].yScale
'
	FOR i = first TO lastOK
		xWin = xULWin + ((points#[iIndex] - xUL#) * xScale#)
		pointsWin[oIndex] = xWin
		INC iIndex
		INC oIndex
'
		yWin = yULWin + ((points#[iIndex] - yUL#) * yScale#)
		pointsWin[oIndex] = yWin
		INC iIndex
		INC oIndex
'
		pointsWin[oIndex] = xWin + 1 : INC oIndex
		pointsWin[oIndex] = yWin : INC oIndex
	NEXT i
END SUB
END FUNCTION
'
'
' ############################
' #####  XgrDrawText ()  #####
' ############################
'
FUNCTION  XgrDrawText (grid, color, text$)
	SHARED  xgrError
	SHARED  FONTINFO  fontInfo[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[],  points#[]
	SHARED  charMap[]
	SHARED  GT_Image
	STATIC  stringSize[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text$ THEN RETURN ($$FALSE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	IFZ stringSize[] THEN DIM stringSize[1]
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	x = gridInfo[grid].drawpoint.x
	y = gridInfo[grid].drawpoint.y
	font = gridInfo[grid].font
	hdc = windowInfo[window].hdc
	xWin = x1Win + x
	yWin = y1Win + y
'
'	set text font, color, mode, style
'
	SetTextAttributes (grid, color, 0)
'
	lenText = LEN (text$)
	length = lenText
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
'	get dxy offset in pixels
'
	##LOCKOUT	= $$TRUE
	GetTextExtentPointA (hdc, &text$, lenText, &stringSize[])
	##LOCKOUT	= entryLOCKOUT
'
	width = stringSize[0]
	angle = fontInfo[font].angle
'
	IF angle THEN
		angleRAD# = angle * $$10thDEG_TO_RAD
		dx = width * COS (angleRAD#)
		dy = width * SIN (angleRAD#)
	ELSE
		dx = width
		dy = 0
	END IF
'
' #####  v0.0432 : SVG
'
	gridInfo[grid].drawpoint.x = x + dx
	gridInfo[grid].drawpoint.y = y + dy
'
'	#####
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				TextOutA (hdc, xWin, yWin, &text$, lenText)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
			##WHOMASK = entryWHOMASK								' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage		' sysImage exists?
	IFZ sysImage THEN														'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
			##WHOMASK = entryWHOMASK								' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	ixWin = xWin - ixUL
	iyWin = yWin - iyUL
'
	##LOCKOUT = $$TRUE
	TextOutA (ntImageInfo.hdcImage, ixWin, iyWin, &text$, lenText)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	IF (g >= 0) THEN SWAP text$, temp$
END FUNCTION
'
'
' ################################
' #####  XgrDrawTextGrid ()  #####
' ################################
'
FUNCTION  XgrDrawTextGrid (grid, color, text$)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text$ THEN RETURN ($$FALSE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xxGrid, @yyGrid)
	XgrConvertGridToLocal (grid, xxGrid, yyGrid, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawText (grid, color, @text$)
	XgrGetDrawpoint (grid, @xxx, @yyy)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointGrid (grid, xxGrid+(xxx-xx), yyGrid+(yyy-yy))
END FUNCTION
'
'
' ##################################
' #####  XgrDrawTextScaled ()  #####
' ##################################
'
FUNCTION  XgrDrawTextScaled (grid, color, text$)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text$ THEN RETURN ($$FALSE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @xx#, @yy#)
	XgrConvertScaledToLocal (grid, xx#, yy#, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawText (grid, color, @text$)
	XgrGetDrawpoint (grid, @xxx, @yyy)
	XgrConvertLocalToScaled (grid, xxx, yyy, @xx#, @yy#)
	XgrSetDrawpointScaled (grid, xx#, yy#)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ################################
' #####  XgrDrawTextFill ()  #####
' ################################
'
FUNCTION  XgrDrawTextFill (grid, color, text$)
	SHARED  xgrError
	SHARED  FONTINFO  fontInfo[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[],  points#[]
	SHARED  charMap[]
	SHARED  GT_Image
	STATIC  stringSize[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text$ THEN RETURN ($$FALSE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	IFZ stringSize[] THEN DIM stringSize[1]
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	x = gridInfo[grid].drawpoint.x
	y = gridInfo[grid].drawpoint.y
	font = gridInfo[grid].font
	hdc = windowInfo[window].hdc
	xWin = x1Win + x
	yWin = y1Win + y
'
'	set text font, color, mode, style
'
	SetTextAttributes (grid, color, $$LineFill)
'
	lenText = LEN(text$)
	length = lenText
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
'	get dxy offset in pixels
'
	##LOCKOUT	= $$TRUE
	GetTextExtentPointA (hdc, &text$, lenText, &stringSize[])
	##LOCKOUT	= entryLOCKOUT
'
	width = stringSize[0]
	angle = fontInfo[font].angle
'
	IF angle THEN
		angleRAD# = angle * $$10thDEG_TO_RAD
		dx = width * COS (angleRAD#)
		dy = width * SIN (angleRAD#)
	ELSE
		dx = width
		dy = 0
	END IF
'
' #####  v0.0432 : SVG
'
	gridInfo[grid].drawpoint.x = x + dx
	gridInfo[grid].drawpoint.y = y + dy
'
'	#####
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				TextOutA (hdc, xWin, yWin, &text$, lenText)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
			##WHOMASK = entryWHOMASK												' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
		SetTextAttributes (grid, color, $$LineFill)		' update attributes : v0.0432 : SVG
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	ixWin = xWin - ixUL
	iyWin = yWin - iyUL
'
	##LOCKOUT = $$TRUE
	TextOutA (ntImageInfo.hdcImage, ixWin, iyWin, &text$, lenText)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	IF (g >= 0) THEN SWAP text$, temp$			' restore non mapped text
END FUNCTION
'
'
' ####################################
' #####  XgrDrawTextFillGrid ()  #####
' ####################################
'
FUNCTION  XgrDrawTextFillGrid (grid, color, text$)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text$ THEN RETURN ($$FALSE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xxGrid, @yyGrid)
	XgrConvertGridToLocal (grid, xxGrid, yyGrid, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawTextFill (grid, color, @text$)			' #####  v0.0433 : SVG
	XgrGetDrawpoint (grid, @xxx, @yyy)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointGrid (grid, xxGrid+(xxx-xx), yyGrid+(yyy-yy))
END FUNCTION
'
'
' ######################################
' #####  XgrDrawTextFillScaled ()  #####
' ######################################
'
FUNCTION  XgrDrawTextFillScaled (grid, color, text$)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text$ THEN RETURN ($$FALSE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @xx#, @yy#)
	XgrConvertScaledToLocal (grid, xx#, yy#, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawTextFill (grid, color, @text$)				' #####  v 0.0433 : SVG
	XgrGetDrawpoint (grid, @xxx, @yyy)
	XgrConvertLocalToScaled (grid, xxx, yyy, @xx#, @yy#)
	XgrSetDrawpointScaled (grid, xx#, yy#)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ################################
' #####  XgrDrawTextWide ()  #####
' ################################
'
FUNCTION  XgrDrawTextWide (grid, color, USHORT text[])
	SHARED  xgrError
	SHARED  FONTINFO  fontInfo[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[],  points#[]
	SHARED  charMap[]
	SHARED  GT_Image
	STATIC  stringSize[]
	USHORT  temp[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text[] THEN RETURN ($$FALSE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	IFZ stringSize[] THEN DIM stringSize[1]
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	x = gridInfo[grid].drawpoint.x
	y = gridInfo[grid].drawpoint.y
	font = gridInfo[grid].font
	hdc = windowInfo[window].hdc
	xWin = x1Win + x
	yWin = y1Win + y
'
'	set text font, color, mode, style
'
	SetTextAttributes (grid, color, 0)
'
	lenText = UBOUND(text[]) + 1
	length = lenText
'
	g = -1
	IF charMap[] THEN
		u = UBOUND (charMap[])
		IF (grid <= u) THEN
			IF charMap[0,] THEN g = 0
			IF charMap[grid,] THEN g = grid
'
			IF (g >= 0) THEN
				DIM temp[length-1]
				FOR i = 0 TO length-1
					temp[i] = charMap[g,text[i]]				' map character
				NEXT i
				SWAP temp[], text[]
			END IF
		END IF
	END IF
'
'	get dxy offset in pixels
'
	##LOCKOUT	= $$TRUE
	GetTextExtentPointW (hdc, &text[], lenText, &stringSize[])
	##LOCKOUT	= entryLOCKOUT
'
	width = stringSize[0]
	angle = fontInfo[font].angle
'
	IF angle THEN
		angleRAD# = angle * $$10thDEG_TO_RAD
		dx = width * COS (angleRAD#)
		dy = width * SIN (angleRAD#)
	ELSE
		dx = width
		dy = 0
	END IF
'
' #####  v0.0432 : SVG
'
	gridInfo[grid].drawpoint.x = x + dx
	gridInfo[grid].drawpoint.y = y + dy
'
'	#####
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				TextOutW (hdc, xWin, yWin, &text[], lenText)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			IF (g >= 0) THEN SWAP text[], temp[]		' restore non mapped text
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			IF (g >= 0) THEN SWAP text[], temp[]		' restore non mapped text
			##WHOMASK = entryWHOMASK								' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage		' sysImage exists?
	IFZ sysImage THEN														'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			IF (g >= 0) THEN SWAP text[], temp[]		' restore non mapped text
			##WHOMASK = entryWHOMASK								' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN							' null intersection
		IF (g >= 0) THEN SWAP text[], temp[]			' restore non mapped text
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	ixWin = xWin - ixUL
	iyWin = yWin - iyUL
'
	##LOCKOUT = $$TRUE
	TextOutW (ntImageInfo.hdcImage, ixWin, iyWin, &text[], lenText)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	IF (g >= 0) THEN SWAP text[], temp[]
	DIM temp[]
END FUNCTION
'
'
' ####################################
' #####  XgrDrawTextWideGrid ()  #####
' ####################################
'
FUNCTION  XgrDrawTextWideGrid (grid, color, USHORT text[])
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text[] THEN RETURN ($$FALSE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xxGrid, @yyGrid)
	XgrConvertGridToLocal (grid, xxGrid, yyGrid, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawTextWide (grid, color, @text[])
	XgrGetDrawpoint (grid, @xxx, @yyy)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointGrid (grid, xxGrid+(xxx-xx), yyGrid+(yyy-yy))
END FUNCTION
'
'
' ######################################
' #####  XgrDrawTextWideScaled ()  #####
' ######################################
'
FUNCTION  XgrDrawTextWideScaled (grid, color, USHORT text[])
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text[] THEN RETURN ($$FALSE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @xx#, @yy#)
	XgrConvertScaledToLocal (grid, xx#, yy#, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawTextWide (grid, color, @text[])
	XgrGetDrawpoint (grid, @xxx, @yyy)
	XgrConvertLocalToScaled (grid, xxx, yyy, @xx#, @yy#)
	XgrSetDrawpointScaled (grid, xx#, yy#)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ####################################
' #####  XgrDrawTextWideFill ()  #####
' ####################################
'
FUNCTION  XgrDrawTextWideFill (grid, color, USHORT text[])
	SHARED  xgrError
	SHARED  FONTINFO  fontInfo[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[],  points#[]
	SHARED  charMap[]
	SHARED  GT_Image
	STATIC  stringSize[]
	USHORT	temp[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text[] THEN RETURN ($$FALSE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	IFZ stringSize[] THEN DIM stringSize[1]
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	x1Win = gridInfo[grid].winBox.x1
	y1Win = gridInfo[grid].winBox.y1
	x = gridInfo[grid].drawpoint.x
	y = gridInfo[grid].drawpoint.y
	font = gridInfo[grid].font
	hdc = windowInfo[window].hdc
	xWin = x1Win + x
	yWin = y1Win + y
'
'	set text font, color, mode, style
'
	SetTextAttributes (grid, color, $$LineFill)
'
	lenText = UBOUND (text[]) + 1
	length = lenText
'
	g = -1
	IF charMap[] THEN
		u = UBOUND (charMap[])
		IF (grid <= u) THEN
			IF charMap[0,] THEN g = 0
			IF charMap[grid,] THEN g = grid
'
			IF (g >= 0) THEN
				DIM temp[length-1]
				FOR i = 0 TO length-1
					temp[i] = charMap[j,text[i]]					' map character
				NEXT i
				SWAP temp[], text[]
			END IF
		END IF
	END IF
'
'	get dxy offset in pixels
'
	##LOCKOUT	= $$TRUE
	GetTextExtentPointA (hdc, &text[], lenText, &stringSize[])
	##LOCKOUT	= entryLOCKOUT
'
	width = stringSize[0]
	angle = fontInfo[font].angle
'
	IF angle THEN
		angleRAD# = angle * $$10thDEG_TO_RAD
		dx = width * COS (angleRAD#)
		dy = width * SIN (angleRAD#)
	ELSE
		dx = width
		dy = 0
	END IF
'
' #####  v0.0432 : SVG
'
	gridInfo[grid].drawpoint.x = x + dx
	gridInfo[grid].drawpoint.y = y + dy
'
'	#####
'
'	if grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		clipIsNull = windowInfo[window].clipIsNull
'
		IFF clipIsNull THEN
			IF (windowInfo[window].visible != $$WindowMinimized) THEN
				##LOCKOUT = $$TRUE
				TextOutW (hdc, xWin, yWin, &text[], lenText)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		IF clipIsNull THEN
			IF (g >= 0) THEN SWAP text[], temp[]			' restore non mapped text
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			IF (g >= 0) THEN SWAP text[], temp[]			' restore non mapped text
			##WHOMASK = entryWHOMASK									' no buffering
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage			' sysImage exists?
	IFZ sysImage THEN															'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			IF (g >= 0) THEN SWAP text[], temp[]			' restore non mapped text
			##WHOMASK = entryWHOMASK									' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN								' null intersection
		IF (g >= 0) THEN SWAP text[], temp[]				' restore non mapped text
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	ixWin = xWin - ixUL
	iyWin = yWin - iyUL
'
	##LOCKOUT = $$TRUE
	TextOutA (ntImageInfo.hdcImage, ixWin, iyWin, &text[], lenText)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	IF (g >= 0) THEN SWAP text[], temp[]					' restore non mapped text
END FUNCTION
'
'
' ########################################
' #####  XgrDrawTextWideFillGrid ()  #####
' ########################################
'
FUNCTION  XgrDrawTextWideFillGrid (grid, color, USHORT text[])
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text[] THEN RETURN ($$FALSE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xxGrid, @yyGrid)
	XgrConvertGridToLocal (grid, xxGrid, yyGrid, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawTextWideFill (grid, color, @text[])
	XgrGetDrawpoint (grid, @xxx, @yyy)
	XgrSetDrawpoint (grid, xx, yy)
	XgrSetDrawpointGrid (grid, xxGrid+(xxx-xx), yyGrid+(yyy-yy))
END FUNCTION
'
'
' ##########################################
' #####  XgrDrawTextWideFillScaled ()  #####
' ##########################################
'
FUNCTION  XgrDrawTextWideFillScaled (grid, color, USHORT text[])
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IFZ text[] THEN RETURN ($$FALSE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @xx#, @yy#)
	XgrConvertScaledToLocal (grid, xx#, yy#, @x, @y)
	XgrSetDrawpoint (grid, x, y)
	XgrDrawTextWideFill (grid, color, @text[])
	XgrGetDrawpoint (grid, @xxx, @yyy)
	XgrConvertLocalToScaled (grid, xxx, yyy, @xx#, @yy#)
	XgrSetDrawpointScaled (grid, xx#, yy#)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ###########################
' #####  XgrFillBox ()  #####
' ###########################
'
FUNCTION  XgrFillBox (grid, color, x1, y1, x2, y2)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[]
	SHARED  GT_Image
	STATIC  RECT  rect
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	clipGrid = gridInfo[grid].clipGrid
	xWin = gridInfo[grid].winBox.x1
	yWin = gridInfo[grid].winBox.y1
	hdc = windowInfo[window].hdc
'
	IF (x1 > x2) THEN SWAP x1, x2
	IF (y1 > y2) THEN SWAP y1, y2
	width = (x2 - x1) + 1
	height = (y2 - y1) + 1
'
'	set the drawing color
'
	SetGridBrushPen (grid, color)
'
'	check draw mode
'
	drawMode = gridInfo[grid].drawMode
	IF (drawMode != windowInfo[window].drawMode) THEN
		SetDrawMode (window, drawMode)
	END IF
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[grid].gridType = GT_Image) THEN
		bufferGrid = grid
	ELSE
		IF (clipGrid != windowInfo[window].clipGrid) THEN
			SetGridClip (window, clipGrid)
		END IF
		IF windowInfo[window].clipIsNull THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
		IF (windowInfo[window].visible != $$WindowMinimized) THEN
			IF (drawMode = $$DrawCOPY) THEN
				rect.left = xWin + x1
				rect.top = yWin + y1
				rect.right = xWin + x2 + 1
				rect.bottom = yWin + y2 + 1
				##LOCKOUT = $$TRUE
				FillRect (hdc, &rect, windowInfo[window].fgBrush)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			ELSE
				##LOCKOUT = $$TRUE
				Rectangle (hdc, xWin+x1, yWin+y1, xWin+x2+1, yWin+y2+1)
'				GetQueueStatus ($$QS_ALLEVENTS)
				##LOCKOUT = entryLOCKOUT
			END IF
		END IF
'
		bufferGrid = gridInfo[grid].bufferGrid
		IFZ bufferGrid THEN
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN
			##WHOMASK = entryWHOMASK												' problem with sysImage
			RETURN ($$FALSE)
		END IF
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (window, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN											' Null intersection
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Translate to image coordinates
'		(xWin,yWin) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	ixUL = gridInfo[bufferGrid].winBox.x1
	iyUL = gridInfo[bufferGrid].winBox.y1
	IF (drawMode = $$DrawCOPY) THEN
		rect.left = x1
		rect.top = y1
		rect.right = x2 + 1
		rect.bottom = y2 + 1
		##LOCKOUT = $$TRUE
		FillRect (ntImageInfo.hdcImage, &rect, windowInfo[window].fgBrush)
		##LOCKOUT = entryLOCKOUT
	ELSE
		##LOCKOUT = $$TRUE
		Rectangle (ntImageInfo.hdcImage, x1, y1, x2+1, y2+1)
		##LOCKOUT = entryLOCKOUT
	END IF
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ###############################
' #####  XgrFillBoxGrid ()  #####
' ###############################
'
FUNCTION  XgrFillBoxGrid (grid, color, x1Grid, y1Grid, x2Grid, y2Grid)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointGrid (grid, @xxGrid, @yyGrid)
	XgrConvertGridToLocal (grid, xxGrid, yyGrid, @x, @y)
	XgrConvertGridToLocal (grid, x1Grid, y1Grid, @x1, @y1)
	XgrConvertGridToLocal (grid, x2Grid, y2Grid, @x2, @y2)
	XgrSetDrawpoint (grid, x, y)
	XgrFillBox (grid, color, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' #################################
' #####  XgrFillBoxScaled ()  #####
' #################################
'
FUNCTION  XgrFillBoxScaled (grid, color, x1#, y1#, x2#, y2#)
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrGetDrawpoint (grid, @xx, @yy)
	XgrGetDrawpointScaled (grid, @xx#, @yy#)
	XgrConvertScaledToLocal (grid, xx#, yy#, @x, @y)
	XgrConvertScaledToLocal (grid, x1#, y1#, @x1, @y1)
	XgrConvertScaledToLocal (grid, x2#, y2#, @x2, @y2)
	XgrSetDrawpoint (grid, x, y)
	XgrFillBox (grid, color, x1, y1, x2, y2)
	XgrSetDrawpoint (grid, xx, yy)
END FUNCTION
'
'
' ################################
' #####  XgrFillTriangle ()  #####
' ################################
'
FUNCTION  XgrFillTriangle (grid, color, style, direction, x1, y1, x2, y2)
	SHARED GRIDINFO gridInfo[]
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
'	##### v0.0433 : SVG : save current line style, set temporary style to $$LineStyleSolid
'
	lineStyle = gridInfo[grid].lineStyle
	gridInfo[grid].lineStyle = $$LineStyleSolid
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
'	##### v0.0433 : SVG : restore original line style
'
	gridInfo[grid].lineStyle = lineStyle
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
	SHARED  GRIDINFO  gridInfo[]
'
	x = 0 : y = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x = gridInfo[grid].drawpoint.x
	y = gridInfo[grid].drawpoint.y
END FUNCTION
'
'
' ####################################
' #####  XgrGetDrawpointGrid ()  #####
' ####################################
'
FUNCTION  XgrGetDrawpointGrid (grid, xGrid, yGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	xGrid = 0 : yGrid = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xGrid = gridInfo[grid].drawpointGrid.x
	yGrid = gridInfo[grid].drawpointGrid.y
END FUNCTION
'
'
' ######################################
' #####  XgrGetDrawpointScaled ()  #####
' ######################################
'
FUNCTION  XgrGetDrawpointScaled (grid, x#, y#)
	SHARED  GRIDINFO  gridInfo[]
'
	x# = 0 : y# = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x# = gridInfo[grid].drawpointScaled.x
	y# = gridInfo[grid].drawpointScaled.y
END FUNCTION
'
'
' #############################
' #####  XgrGrabPoint ()  #####
' #############################
'
FUNCTION  XgrGrabPoint (grid, x, y, red, green, blue, color)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  NTIMAGEINFO ntImageInfo
	SHARED  GRIDINFO  gridInfo[]
	SHARED  points[]
	SHARED  GT_Image
'
	$AllPlanes	= -1
	$XYPixmap		= 1
'
	red = 0 : green = 0 : blue = 0 : color = 0
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
'	#####  v0.0433 : SVG : support for image grids
'
	IF (gridInfo[grid].gridType = GT_Image) THEN		' Not on display, so point unaltered
		sysImage = gridInfo[grid].sysImage						' sysImage exists?
		IFZ sysImage THEN
			##WHOMASK = whomask												  ' problem with sysImage
			RETURN ($$FALSE)
		ELSE
			UpdateSysImage (grid)
		END IF
		xWin = x
		yWin = y
		xUL = 0
		yUL = 0
		xLR = gridInfo[grid].width - 1
		yLR = gridInfo[grid].height - 1
		hdc = ntImageInfo.hdcImage
	ELSE
'
'	#####
'
		x1Win = gridInfo[grid].winBox.x1
		y1Win = gridInfo[grid].winBox.y1
'
		xWin = x1Win + x
		yWin = y1Win + y
'
'	is the point on the display
'
		window = gridInfo[grid].window
		hdc = windowInfo[window].hdc
		host = windowInfo[window].host
		displayWidth = hostDisplay[host].displayWidth
		displayHeight = hostDisplay[host].displayHeight
'
		xWindow = windowInfo[window].xDisp
		yWindow = windowInfo[window].yDisp
		width = windowInfo[window].width
		height = windowInfo[window].height
'
'	Done if UL corner is off display to LR.
'
		IF (xWindow >= displayWidth)  THEN RETURN
		IF (yWindow >= displayHeight) THEN RETURN
'
'	Done if LR corner is off display to UL.
'
		IF ((xWindow + width - 1) < 0)  THEN RETURN
		IF ((yWindow + height - 1) < 0) THEN RETURN
'
'	Get the VISIBLE UL corner
'
		xUL = 0
		IF (xWindow < 0) THEN xUL = -xWindow
		yUL = 0
		IF (yWindow < 0) THEN yUL = -yWindow
'
'	Get the VISIBLE LR corner
'
		xLR = width - 1
		IF ((xWindow + width) >= displayWidth) THEN xLR = displayWidth - 1
		yLR = height - 1
		IF ((yWindow + height) >= displayHeight) THEN yLR = displayHeight - 1
  END IF
'
' #####  v0.0433 : SVG : required by IF above
'
'	Done if current draw point (xWin, yWin) is not on display
'		Either outside window or actually off display
'
	IF (xWin < xUL) THEN RETURN
	IF (xWin > xLR) THEN RETURN
	IF (yWin < yUL) THEN RETURN
	IF (yWin > yLR) THEN RETURN
'
'	(xWin, yWin) is on the display
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	pixel = GetPixel (hdc, xWin, yWin)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF (pixel = -1) THEN RETURN
'
	red = (pixel AND 0x000000FF) << 8
	green = (pixel AND 0x0000FF00)
	blue = (pixel AND 0x00FF0000) >> 8
	XgrConvertRGBToColor (red, green, blue, @color)
END FUNCTION
'
'
' #################################
' #####  XgrGrabPointGrid ()  #####
' #################################
'
FUNCTION  XgrGrabPointGrid (grid, xGrid, yGrid, red, green, blue, color)
'
	red = 0 : green = 0 : blue = 0 : color = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrConvertGridToLocal (grid, xGrid, yGrid, @x, @y)
	XgrGrabPoint (grid, x, y, @red, @green, @blue, @color)
END FUNCTION
'
'
' ###################################
' #####  XgrGrabPointScaled ()  #####
' ###################################
'
FUNCTION  XgrGrabPointScaled (grid, x#, y#, red, green, blue, color)
'
	red = 0 : green = 0 : blue = 0 : color = 0
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	XgrConvertScaledToLocal (grid, x#, y#, @x, @y)
	XgrGrabPoint (grid, x, y, @red, @green, @blue, @color)
END FUNCTION
'
'
' #############################
' #####  XgrMoveDelta ()  #####
' #############################
'
FUNCTION  XgrMoveDelta (grid, dx, dy)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x = gridInfo[grid].drawpoint.x
	y = gridInfo[grid].drawpoint.y
	gridInfo[grid].drawpoint.x = x + dx
	gridInfo[grid].drawpoint.y = y + dy
END FUNCTION
'
'
' #################################
' #####  XgrMoveDeltaGrid ()  #####
' #################################
'
FUNCTION  XgrMoveDeltaGrid (grid, dxGrid, dyGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	xGrid = gridInfo[grid].drawpointGrid.x
	yGrid = gridInfo[grid].drawpointGrid.y
	gridInfo[grid].drawpointGrid.x = xGrid + dxGrid
	gridInfo[grid].drawpointGrid.y = yGrid + dyGrid
END FUNCTION
'
'
' ###################################
' #####  XgrMoveDeltaScaled ()  #####
' ###################################
'
FUNCTION  XgrMoveDeltaScaled (grid, dx#, dy#)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	x# = gridInfo[grid].drawpointScaled.x
	y# = gridInfo[grid].drawpointScaled.y
	gridInfo[grid].drawpointScaled.x = x# + dx#
	gridInfo[grid].drawpointScaled.y = y# + dy#
END FUNCTION
'
'
' ##########################
' #####  XgrMoveTo ()  #####
' ##########################
'
FUNCTION  XgrMoveTo (grid, x, y)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	gridInfo[grid].drawpoint.x = x
	gridInfo[grid].drawpoint.y = y
END FUNCTION
'
'
' ##############################
' #####  XgrMoveToGrid ()  #####
' ##############################
'
FUNCTION  XgrMoveToGrid (grid, xGrid, yGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	gridInfo[grid].drawpointGrid.x = xGrid
	gridInfo[grid].drawpointGrid.y = yGrid
END FUNCTION
'
'
' ################################
' #####  XgrMoveToScaled ()  #####
' ################################
'
FUNCTION  XgrMoveToScaled (grid, x#, y#)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	gridInfo[grid].drawpointScaled.x = x#
	gridInfo[grid].drawpointScaled.y = y#
END FUNCTION
'
'
' ################################
' #####  XgrSetDrawpoint ()  #####
' ################################
'
FUNCTION  XgrSetDrawpoint (grid, x, y)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	gridInfo[grid].drawpoint.x = x
	gridInfo[grid].drawpoint.y = y
END FUNCTION
'
'
' ####################################
' #####  XgrSetDrawpointGrid ()  #####
' ####################################
'
FUNCTION  XgrSetDrawpointGrid (grid, xGrid, yGrid)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	gridInfo[grid].drawpointGrid.x = xGrid
	gridInfo[grid].drawpointGrid.y = yGrid
END FUNCTION
'
'
' ######################################
' #####  XgrSetDrawpointScaled ()  #####
' ######################################
'
FUNCTION  XgrSetDrawpointScaled (grid, x#, y#)
	SHARED  GRIDINFO  gridInfo[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	gridInfo[grid].drawpointScaled.x = x#
	gridInfo[grid].drawpointScaled.y = y#
END FUNCTION
'
'
' #############################
' #####  XgrCopyImage ()  #####
' #############################
'
' BitBlt() is time consuming, so be careful
' about the area transfered (clipping, etc).
'
FUNCTION  XgrCopyImage (destGrid, srcGrid)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
'
	IF InvalidGrid (srcGrid) THEN RETURN ($$TRUE)
	IF InvalidGrid (destGrid) THEN RETURN ($$TRUE)
	IF (destGrid = srcGrid) THEN
		PRINT "XgrCopyImage():  copy grid image to itself - unavailable"
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	windowSrc = gridInfo[srcGrid].window
	gridTypeSrc = gridInfo[srcGrid].gridType
	IF (gridTypeSrc = GT_Image) THEN
		sysImageSrc = gridInfo[srcGrid].sysImage
		IFZ sysImageSrc THEN														' image is empty
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'		Create a temporary hdc for source
'			Nothing fancy required for BitBlt()
'
		hdcSrc = CreateCompatibleDC (windowInfo[windowSrc].hdc)
		IF (sysImageSrc = ntImageInfo.hBitmap) THEN			' bitmap in only 1 hdc at a time
			defaultBitmap = ntImageInfo.defaultBitmap
			SelectObject (ntImageInfo.hdcImage, defaultBitmap)
			ntImageInfo.hBitmap = defaultBitmap
		END IF
		hBitmapOrig = SelectObject (hdcSrc, sysImageSrc)
	ELSE
		hdcSrc = windowInfo[windowSrc].hdc
	END IF

	windowDest		= gridInfo[destGrid].window
	gridTypeDest	= gridInfo[destGrid].gridType
	IF (gridTypeDest != GT_Image) THEN
		hdcDest = windowInfo[windowDest].hdc
	END IF
'
'	Basic transfer:  xWin,yWin  destGrid;  ixWin,iyWin,width,height  srcGrid
'
	xWin = gridInfo[destGrid].winBox.x1
	yWin = gridInfo[destGrid].winBox.y1
	ixWin = 0
	iyWin = 0
	IF (gridTypeSrc != GT_Image) THEN
		ixWin = gridInfo[srcGrid].winBox.x1
		iyWin = gridInfo[srcGrid].winBox.y1
	END IF
	width		= gridInfo[srcGrid].width
	height	= gridInfo[srcGrid].height
'
'	Factor in clipping manually
'
	clipGrid = gridInfo[destGrid].clipGrid
	ReturnGridClip (windowDest, clipGrid, @cx, @cy, @cw, @ch)
	IF windowInfo[windowDest].clipIsNull THEN GOTO Done			' Null intersection
	IF (cw && ch) THEN
		x2Win = xWin + width - 1
		y2Win = yWin + height - 1
		cx2 = cx + cw - 1
		cy2 = cy + ch - 1
		IF (xWin > cx2) THEN GOTO Done						' area outside clip region
		IF (cx > x2Win) THEN GOTO Done
		IF (yWin > cy2) THEN GOTO Done
		IF (cy > y2Win) THEN GOTO Done
		IF (xWin < cx) THEN											' adjust src and dest start
			ixWin = ixWin + (cx - xWin)
			xWin = cx
		END IF
		IF (cx2 < x2Win) THEN x2Win = cx2
		IF (yWin < cy) THEN
			iyWin = iyWin + (cy - yWin)
			yWin = cy
		END IF
		IF (cy2 < y2Win) THEN y2Win = cy2
		width = x2Win - xWin + 1
		height = y2Win - yWin + 1
	END IF
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridTypeDest = GT_Image) THEN
		bufferGrid = destGrid
	ELSE
'
'		NT:  BitBlt is not supported by all devices
'
		IF (windowInfo[windowDest].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			BitBlt (hdcDest, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, $$SRCCOPY)
'			GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
'			UpdateWindow (windowInfo[windowDest].hwnd)
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[destGrid].bufferGrid
		IFZ bufferGrid THEN GOTO Done											' no buffering
	END IF

	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN GOTO Done												' problem with sysImage
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
'	Could speed this up by making ReturnImageClip() but the context is
'		a bit messy.  Look into it later.
'
	SetImageClip (windowDest, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN GOTO Done						' Null intersection
'
'	Translate to image coordinates
'		(x,y) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	xWin = xWin - gridInfo[bufferGrid].winBox.x1
	yWin = yWin - gridInfo[bufferGrid].winBox.y1
	hdcImage = ntImageInfo.hdcImage
	##LOCKOUT = $$TRUE
	BitBlt (hdcImage, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, $$SRCCOPY)
	##LOCKOUT = entryLOCKOUT

Done:
	IF (gridTypeSrc = GT_Image) THEN
		##LOCKOUT = $$TRUE
		SelectObject (hdcSrc, hBitmapOrig)
		DeleteDC (hdcSrc)
		##LOCKOUT = entryLOCKOUT
	END IF

	SetGridClip (windowDest, 0)				' Required due to ReturnGridClip()
	##WHOMASK = entryWHOMASK
END FUNCTION

'* Calculate the coordinates of the source bitmap, relative to the origin of
' the grid.
' The x1,x2,y1,y2 parameters can be specified as -1. This function calculates
' the correct values for the parameters in these cases.
' @param grid			The grid
' @param x1				start offset horizontal, -1 is left of grid (0)
' @param y1				start offset vertical, -1 is top of grid (0)
' @param x2				end offset horizontal, -1 is right of grid.
' @param y2				end offset vertical, -1 is bottom of grid.
FUNCTION calculateCoordinates(grid, x1, y1, x2, y2, ixWin, iyWin, ix2Win, iy2Win)
	SHARED  GRIDINFO  gridInfo[]

	sx1Win = gridInfo[grid].winBox.x1
	sy1Win = gridInfo[grid].winBox.y1
	sx2Win = gridInfo[grid].winBox.x2
	sy2Win = gridInfo[grid].winBox.y2

	IF x1 < 0 THEN
		ixWin = sx1Win
	ELSE
		ixWin = sx1Win + x1
	END IF
	IF y1 < 0 THEN
		iyWin = sy1Win
	ELSE
		iyWin = sy1Win + y1
	END IF
	'Note: this will change to < 0 in 6.1.3.
	IF x2 <= 0 THEN
		ix2Win = sx2Win
	ELSE
		ix2Win = sx1Win + x2
	END IF
	'Note: this will change to < 0 in 6.1.3.
	IF y2 <= 0 THEN
		iy2Win = sy2Win
	ELSE
		iy2Win = sy1Win + y2
	END IF
END FUNCTION
'
'
' #############################
' #####  XgrDrawImage ()  #####
' #############################
'
'	Draw srcGrid to destGrid at current draw point
'
'	In:				destGrid
'						srcGrid
'						x1, y1			srcGrid start (local coordinates)
'						x2, y2			srcGrid end
'
'	Out:			none				arg unchanged
'
'	Return:		$$FALSE			no errors
'						$$TRUE			errors
'
'	Discussion:
'		Because BitBlt() is time consuming, be VERY careful about
'			the area transfered (clipping, etc)
'		If x2/y2 = -1, set to xy limits of the srcGrid
'		Draws at current draw point, to lower right
'
'		More cases must be added later:
'			"Clip" to windowDest size
'
FUNCTION  XgrDrawImage (destGrid, srcGrid, x1, y1, x2, y2, dx1, dy1)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[]
	SHARED  GT_Image
'
	IF InvalidGrid (srcGrid) THEN RETURN ($$TRUE)
	IF InvalidGrid (destGrid) THEN RETURN ($$TRUE)
	IF (destGrid = srcGrid) THEN
		PRINT "XgrDrawImage():  copy grid image to itself - unavailable"
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	windowSrc = gridInfo[srcGrid].window
	gridTypeSrc = gridInfo[srcGrid].gridType
	IF (gridTypeSrc = GT_Image) THEN
		sysImageSrc = gridInfo[srcGrid].sysImage
		IFZ sysImageSrc THEN														' image is empty
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'		Create a temporary hdc for source
'			Nothing fancy required for BitBlt()
'
		hdcSrc = CreateCompatibleDC (windowInfo[windowSrc].hdc)
		IF (sysImageSrc = ntImageInfo.hBitmap) THEN			' bitmap in only 1 hdc at a time
			defaultBitmap = ntImageInfo.defaultBitmap
			SelectObject (ntImageInfo.hdcImage, defaultBitmap)
			ntImageInfo.hBitmap = defaultBitmap
		END IF
		hBitmapOrig = SelectObject (hdcSrc, sysImageSrc)
	ELSE
		hdcSrc = windowInfo[windowSrc].hdc
	END IF
'
	windowDest = gridInfo[destGrid].window
	gridTypeDest = gridInfo[destGrid].gridType
	IF (gridTypeDest != GT_Image) THEN
		hdcDest = windowInfo[windowDest].hdc
	END IF
'
'	Basic transfer:	xWin,yWin									destGrid
'									ixWin,iyWin,width,height	srcGrid
'
	dx1Win = gridInfo[destGrid].winBox.x1
	dy1Win = gridInfo[destGrid].winBox.y1
'	xWin = dx1Win + gridInfo[destGrid].drawpoint.x
'	yWin = dy1Win + gridInfo[destGrid].drawpoint.y
	xWin = dx1Win + dx1
	yWin = dy1Win + dy1
'
	calculateCoordinates(srcGrid, x1, y1, x2, y2, @ixWin, @iyWin, @ix2Win, @iy2Win)
'
	IF ((ix2Win < ixWin) OR (iy2Win < iyWin)) THEN GOTO Done
'
	IF (gridTypeSrc = GT_Image) THEN
		xUL = gridInfo[srcGrid].winBox.x1			' 0
		yUL = gridInfo[srcGrid].winBox.y1			' 0
		ixWin = ixWin - xUL
		iyWin = iyWin - yUL
		ix2Win = ix2Win - xUL
		iy2Win = iy2Win - yUL
		IF (ixWin < 0) THEN ixWin = 0					' nothing beyond UL
		IF (iyWin < 0) THEN iyWin = 0
		xLR = gridInfo[srcGrid].width - 1			' nothing beyond LR
		yLR = gridInfo[srcGrid].height - 1
		IF (ix2Win > xLR) THEN ix2Win = xLR
		IF (iy2Win > yLR) THEN iy2Win = yLR
	END IF
	width = (ix2Win - ixWin) + 1
	height = (iy2Win - iyWin) + 1
	IF ((width <= 0) OR (height <= 0)) THEN GOTO Done				' empty
'
'	Factor in clipping manually
'
	clipGrid = gridInfo[destGrid].clipGrid
	ReturnGridClip (windowDest, clipGrid, @cx, @cy, @cw, @ch)
	IF windowInfo[windowDest].clipIsNull THEN GOTO Done			' Null intersection
	IF (cw && ch) THEN
		x2Win = xWin + width - 1
		y2Win = yWin + height - 1
		cx2 = cx + cw - 1
		cy2 = cy + ch - 1
		IF (xWin > cx2) THEN GOTO Done				' area outside clip region
		IF (cx > x2Win) THEN GOTO Done
		IF (yWin > cy2) THEN GOTO Done
		IF (cy > y2Win) THEN GOTO Done
		IF (xWin < cx) THEN										' adjust src and dest start
			ixWin = ixWin + (cx - xWin)
			xWin = cx
		END IF
		IF (cx2 < x2Win) THEN x2Win = cx2
		IF (yWin < cy) THEN
			iyWin = iyWin + (cy - yWin)
			yWin = cy
		END IF
		IF (cy2 < y2Win) THEN y2Win = cy2
		width = x2Win - xWin + 1
		height = y2Win - yWin + 1
	END IF
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridTypeDest = GT_Image) THEN
		bufferGrid = destGrid
	ELSE
'
'		NT:  BitBlt is not supported by all devices
'
		IF (windowInfo[windowDest].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			BitBlt (hdcDest, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, $$SRCCOPY)
'			GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
'			UpdateWindow (windowInfo[windowDest].hwnd)
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[destGrid].bufferGrid
		IFZ bufferGrid THEN GOTO Done											' no buffering
	END IF
'
	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN GOTO Done												' problem with sysImage
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
'	Could speed this up by making ReturnImageClip() but the context is
'		a bit messy.  Look into it later.
'
	SetImageClip (windowDest, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN GOTO Done						' Null intersection
'
'	Translate to image coordinates
'		(x,y) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	xWin = xWin - gridInfo[bufferGrid].winBox.x1
	yWin = yWin - gridInfo[bufferGrid].winBox.y1
	xLR = gridInfo[bufferGrid].width - 1
	yLR = gridInfo[bufferGrid].height - 1
	IF (xWin > xLR) THEN GOTO Done
	IF (yWin > yLR) THEN GOTO Done
	x2Win = xWin + width - 1
	y2Win = yWin + height - 1
	IF (x2Win > xLR) THEN width = width - (x2Win - xLR)
	IF (y2Win > yLR) THEN height = height - (y2Win - yLR)
	hdcImage = ntImageInfo.hdcImage
	##LOCKOUT = $$TRUE
	BitBlt (hdcImage, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, $$SRCCOPY)
	##LOCKOUT = entryLOCKOUT
'
Done:
	IF (gridTypeSrc = GT_Image) THEN
		##LOCKOUT = $$TRUE
		SelectObject (hdcSrc, hBitmapOrig)
		DeleteDC (hdcSrc)
		##LOCKOUT = entryLOCKOUT
	END IF
'
	SetGridClip (windowDest, 0)				' Required due to ReturnGridClip()
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ###################################
' #####  XgrDrawImageExtend ()  #####
' ###################################
'
'	Draw srcGrid to destGrid at current draw point, extend to fill
'
'	In:				destGrid
'						srcGrid
'						x1, y1			srcGrid start (grid coordinates)
'						x2, y2			srcGrid end
'
'	Out:			none				arg unchanged
'
'	Return:		$$FALSE			no errors
'						$$TRUE			errors
'
'	Discussion:
'		Because BitBlt() is time consuming, be VERY careful about
'			the area transfered (clipping, etc)
'		If x2/y2 = -1, set to xy limits of the srcGrid
'		Draws at current draw point, to lower right
'
'		More cases must be added later:
'			"Clip" to windowDest size
'		Currently, if primary copy does not intersect window, this is
'			a NOP.  (ie it does NOT extend from outside the window...)
'
FUNCTION  XgrDrawImageExtend (destGrid, srcGrid, x1, y1, x2, y2, dx1, dy1)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[]
	SHARED  GT_Image
	STATIC  RECT  rect
'
	IF InvalidGrid (srcGrid) THEN RETURN ($$TRUE)
	IF InvalidGrid (destGrid) THEN RETURN ($$TRUE)
	IF (destGrid = srcGrid) THEN
		PRINT "XgrDrawImageExtend():  copy grid image to itself - unavailable"
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	windowSrc		= gridInfo[srcGrid].window
	gridTypeSrc	= gridInfo[srcGrid].gridType
	IF (gridTypeSrc = GT_Image) THEN
		sysImageSrc	= gridInfo[srcGrid].sysImage
		IFZ sysImageSrc THEN														' image is empty
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'		Create a temporary hdc for source
'			Nothing fancy required for BitBlt()
'
		hdcSrc = CreateCompatibleDC (windowInfo[windowSrc].hdc)
		IF (sysImageSrc = ntImageInfo.hBitmap) THEN			' bitmap in only 1 hdc at a time
			defaultBitmap = ntImageInfo.defaultBitmap
			SelectObject (ntImageInfo.hdcImage, defaultBitmap)
			ntImageInfo.hBitmap = defaultBitmap
		END IF
		hBitmapOrig = SelectObject (hdcSrc, sysImageSrc)
	ELSE
		hdcSrc = windowInfo[windowSrc].hdc
	END IF

	windowDest		= gridInfo[destGrid].window
	gridTypeDest	= gridInfo[destGrid].gridType
	IF (gridTypeDest != GT_Image) THEN
		hdcDest = windowInfo[windowDest].hdc
	END IF
'
'	Basic transfer:	xWin,yWin									destGrid
'									ixWin,iyWin,width,height	srcGrid
'
	dx1Win = gridInfo[destGrid].winBox.x1
	dy1Win = gridInfo[destGrid].winBox.y1
'	xWin = dx1Win + gridInfo[destGrid].drawpoint.x
'	yWin = dy1Win + gridInfo[destGrid].drawpoint.y
	xWin = dx1Win + dx1
	yWin = dy1Win + dy1
'
	calculateCoordinates(srcGrid, x1, y1, x2, y2, @ixWin, @iyWin, @ix2Win, @iy2Win)
'
	IF ((ix2Win < ixWin) OR (iy2Win < iyWin)) THEN GOTO Done
'
	IF (gridTypeSrc = GT_Image) THEN
		xUL = gridInfo[srcGrid].winBox.x1			' 0
		yUL = gridInfo[srcGrid].winBox.y1			' 0
		ixWin = ixWin - xUL
		iyWin = iyWin - yUL
		ix2Win = ix2Win - xUL
		iy2Win = iy2Win - yUL
		IF (ixWin < 0) THEN ixWin = 0					' nothing beyond UL
		IF (iyWin < 0) THEN iyWin = 0
		xLR = gridInfo[srcGrid].width - 1			' nothing beyond LR
		yLR = gridInfo[srcGrid].height - 1
		IF (ix2Win > xLR) THEN ix2Win = xLR
		IF (iy2Win > yLR) THEN iy2Win = yLR
	END IF
	width		= (ix2Win - ixWin) + 1
	height	= (iy2Win - iyWin) + 1
	IF ((width <= 0) OR (height <= 0)) THEN GOTO Done				' empty
'
'	Factor in clipping manually
'
	clipGrid = gridInfo[destGrid].clipGrid
	ReturnGridClip (windowDest, clipGrid, @cx, @cy, @cw, @ch)
	IF windowInfo[windowDest].clipIsNull THEN GOTO Done			' Null intersection
	IF (cw && ch) THEN
		x2Win = xWin + width - 1
		y2Win = yWin + height - 1
		cx2 = cx + cw - 1
		cy2 = cy + ch - 1
		IF (xWin > cx2) THEN GOTO Done				' area outside clip region
		IF (cx > x2Win) THEN GOTO Done
		IF (yWin > cy2) THEN GOTO Done
		IF (cy > y2Win) THEN GOTO Done
		IF (xWin < cx) THEN										' adjust src and dest start
			ixWin = ixWin + (cx - xWin)
			xWin = cx
		END IF
		IF (cx2 < x2Win) THEN x2Win = cx2
		IF (yWin < cy) THEN
			iyWin = iyWin + (cy - yWin)
			yWin = cy
		END IF
		IF (cy2 < y2Win) THEN y2Win = cy2
		width = x2Win - xWin + 1
		height = y2Win - yWin + 1
	END IF
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridInfo[destGrid].gridType = GT_Image) THEN
		bufferGrid = destGrid
	ELSE
'
'		NT:  BitBlt is not supported by all devices
'
		IF (windowInfo[windowDest].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			BitBlt (hdcDest, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, $$SRCCOPY)
			##LOCKOUT = entryLOCKOUT
			IF (cw && ch) THEN
				x1Ext = cx
				y1Ext = cy
				x2Ext = cx2
				y2Ext = cy2
			ELSE
				x1Ext = 0
				y1Ext = 0
				x2Ext = windowInfo[windowDest].width - 1
				y2Ext = windowInfo[windowDest].height - 1
			END IF
			hdcExt = hdcDest
			GOSUB ExtendImage
			##LOCKOUT = $$TRUE
'			GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
'			UpdateWindow (windowInfo[windowDest].hwnd)
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[destGrid].bufferGrid
		IFZ bufferGrid THEN GOTO Done											' no buffering
	END IF

	sysImage = gridInfo[bufferGrid].sysImage						' sysImage exists?
	IFZ sysImage THEN																		'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN GOTO Done												' problem with sysImage
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
'	Could speed this up by making ReturnImageClip() but the context is
'		a bit messy.  Look into it later.
'
	SetImageClip (windowDest, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN GOTO Done						' Null intersection
'
'	Translate to image coordinates
'		(x,y) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	xULWin = gridInfo[bufferGrid].winBox.x1
	yULWin = gridInfo[bufferGrid].winBox.y1
	xLR = gridInfo[bufferGrid].width - 1
	yLR = gridInfo[bufferGrid].height - 1
	xWin = xWin - xULWin
	yWin = yWin - yULWin
	IF (xWin > xLR) THEN GOTO Done
	IF (yWin > yLR) THEN GOTO Done
	x2Win = xWin + width - 1
	y2Win = yWin + height - 1
	IF (x2Win > xLR) THEN width = width - (x2Win - xLR)
	IF (y2Win > yLR) THEN height = height - (y2Win - yLR)
	hdcImage = ntImageInfo.hdcImage
	##LOCKOUT = $$TRUE
	BitBlt (hdcImage, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, $$SRCCOPY)
	##LOCKOUT = entryLOCKOUT
	x1Ext = 0
	y1Ext = 0
	x2Ext = xLR
	y2Ext = yLR
	IF (cw && ch) THEN
		cx1Ext = cx - xULWin:		IF (cx1Ext > 0) THEN x1Ext = cx1Ext
		cy1Ext = cy - yULWin:		IF (cy1Ext > 0) THEN y1Ext = cy1Ext
		cx2Ext = cx2 - xULWin:	IF (cx2Ext < xLR) THEN x2Ext = cx2Ext
		cy2Ext = cy2 - yULWin:	IF (cy2Ext < yLR) THEN y2Ext = cy2Ext
	END IF
	hdcExt = hdcImage
	GOSUB ExtendImage

Done:
	IF (gridTypeSrc = GT_Image) THEN
		##LOCKOUT = $$TRUE
		SelectObject (hdcSrc, hBitmapOrig)
		DeleteDC (hdcSrc)
		##LOCKOUT = entryLOCKOUT
	END IF

	SetGridClip (windowDest, 0)				' Required due to ReturnGridClip()
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'	*****  ExtendImage  *****
'		In:		(x1Ext,y1Ext), (x2Ext,y2Ext)	= destination rectangle to fill
'					(xWin,yWin), width/height			= destination rectangle already filled
'					(ixWin,iyWin), width/height		= corresponding source rectangle
'					hdcExt												= hdc to fill
'					hdcSrc												= source hdc
'
'		Discussion:
'			Could create a temporary bitmap and BitBlt() the image there first, then
'				BitBlt() it to the destination hdc.  Decided not to do this as this
'				area could be large (up to full screen size) and take several MBytes.
'			This technique could be slower, be doesn't require the memory.
'
'		Similar approach is used in XgrDrawImageExtendScaled()
'
SUB ExtendImage
	x2Win = xWin + width - 1
	y2Win = yWin + height - 1
	ix2Win = ixWin + width - 1
	iy2Win = iyWin + height - 1
'
'	Left
'
	IF (xWin > x1Ext) THEN
		##LOCKOUT = $$TRUE
		FOR x = (xWin - 1) TO x1Ext STEP -1
			BitBlt (hdcExt, x, yWin, 1, height, hdcSrc, ixWin, iyWin, $$SRCCOPY)
		NEXT x
'
'		UL
'
		IF (yWin > y1Ext) THEN
			pixel = GetPixel (hdcSrc, ixWin, iyWin)
			IF (pixel != -1) THEN
				rect.left		= x1Ext
				rect.top		= y1Ext
				rect.right	= xWin		' FillRect() doesn't do bottom/right
				rect.bottom	= yWin
				hBrush	= CreateSolidBrush (pixel)
				FillRect (hdcExt, &rect, hBrush)
				DeleteObject (hBrush)
			END IF
		END IF
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	Top
'
	IF (yWin > y1Ext) THEN
		##LOCKOUT = $$TRUE
		FOR y = (yWin - 1) TO y1Ext STEP -1
			BitBlt (hdcExt, xWin, y, width, 1, hdcSrc, ixWin, iyWin, $$SRCCOPY)
		NEXT y
'
'		UR
'
		IF (x2Win < x2Ext) THEN
			pixel = GetPixel (hdcSrc, ix2Win, iyWin)
			IF (pixel != -1) THEN
				rect.left		= x2Win + 1
				rect.top		= y1Ext
				rect.right	= x2Ext + 1		' FillRect() doesn't do bottom/right
				rect.bottom	= yWin
				hBrush	= CreateSolidBrush (pixel)
				FillRect (hdcExt, &rect, hBrush)
				DeleteObject (hBrush)
			END IF
		END IF
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	Right
'
	IF (x2Win < x2Ext) THEN
		##LOCKOUT = $$TRUE
		FOR x = (x2Win + 1) TO x2Ext
			BitBlt (hdcExt, x, yWin, 1, height, hdcSrc, ix2Win, iyWin, $$SRCCOPY)
		NEXT x
'
'		LR
'
		IF (y2Win < y2Ext) THEN
			pixel = GetPixel (hdcSrc, ix2Win, iy2Win)
			IF (pixel != -1) THEN
				rect.left		= x2Win + 1
				rect.top		= y2Win + 1
				rect.right	= x2Ext + 1		' FillRect() doesn't do bottom/right
				rect.bottom	= y2Ext + 1
				hBrush	= CreateSolidBrush (pixel)
				FillRect (hdcExt, &rect, hBrush)
				DeleteObject (hBrush)
			END IF
		END IF
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	Bottom
'
	IF (y2Win < y2Ext) THEN
		##LOCKOUT = $$TRUE
		FOR y = (y2Win + 1) TO y2Ext
			BitBlt (hdcExt, xWin, y, width, 1, hdcSrc, ixWin, iy2Win, $$SRCCOPY)
		NEXT y
'
'		LL
'
		IF (xWin > x1Ext) THEN
			pixel = GetPixel (hdcSrc, ixWin, iy2Win)
			IF (pixel != -1) THEN
				rect.left		= x1Ext
				rect.top		= y2Win + 1
				rect.right	= xWin 				' FillRect() doesn't do bottom/right
				rect.bottom	= y2Ext + 1
				hBrush	= CreateSolidBrush (pixel)
				FillRect (hdcExt, &rect, hBrush)
				DeleteObject (hBrush)
			END IF
		END IF
		##LOCKOUT = entryLOCKOUT
	END IF
END SUB
END FUNCTION
'
'
' #########################################
' #####  XgrDrawImageExtendScaled ()  #####
' #########################################
'
'	Scale draw srcGrid to destGrid at current draw point
'
'	In:				destGrid
'						srcGrid
'						x1, y1			srcGrid start (local coordinates)
'						x2, y2			srcGrid end
'
'	Out:			none				arg unchanged
'
'	Return:		$$FALSE			no errors
'						$$TRUE			errors
'
'	Discussion:
'		If x2/y2 = -1, set to xy limits of srcGrid
'		The scaled coordinates of the destination specify the scale
'			factor and orientation (mirror or not).
'
FUNCTION  XgrDrawImageExtendScaled (destGrid, srcGrid, x1, y1, x2, y2, dx1, dy1)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[]
	SHARED  GT_Image
	STATIC  RECT  rect
'
	$HALFTONE = 5
'
	IF InvalidGrid (srcGrid) THEN RETURN ($$TRUE)
	IF InvalidGrid (destGrid) THEN RETURN ($$TRUE)
	IF (destGrid = srcGrid) THEN
		PRINT "XgrDrawImageExtendScaled():  copy grid image to itself - unavailable"
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	windowSrc		= gridInfo[srcGrid].window
	gridTypeSrc	= gridInfo[srcGrid].gridType
	IF (gridTypeSrc = GT_Image) THEN
		sysImageSrc	= gridInfo[srcGrid].sysImage
		IFZ sysImageSrc THEN														' image is empty
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'		Create a temporary hdc for source
'			Nothing fancy required for BitBlt()
'
		hdcSrc			= CreateCompatibleDC (windowInfo[windowSrc].hdc)
		IF (sysImageSrc = ntImageInfo.hBitmap) THEN			' bitmap in only 1 hdc at a time
			defaultBitmap = ntImageInfo.defaultBitmap
			SelectObject (ntImageInfo.hdcImage, defaultBitmap)
			ntImageInfo.hBitmap = defaultBitmap
		END IF
		hBitmapOrig = SelectObject (hdcSrc, sysImageSrc)
	ELSE
		hdcSrc = windowInfo[windowSrc].hdc
	END IF
'
	windowDest		= gridInfo[destGrid].window
	gridTypeDest	= gridInfo[destGrid].gridType
	clipGrid			= gridInfo[destGrid].clipGrid
	IF (gridTypeDest != GT_Image) THEN
		hdcDest = windowInfo[windowDest].hdc
	END IF
'
'	Basic transfer:	xWin,yWin									destGrid
'									ixWin,iyWin,width,height	srcGrid
'
	dx1Win = gridInfo[destGrid].winBox.x1
	dy1Win = gridInfo[destGrid].winBox.y1
'	xWin = dx1Win + gridInfo[destGrid].drawpoint.x
'	yWin = dy1Win + gridInfo[destGrid].drawpoint.y
	xWin = dx1Win + dx1
	yWin = dy1Win + dy1
'
	calculateCoordinates(srcGrid, x1, y1, x2, y2, @ixWin, @iyWin, @ix2Win, @iy2Win)
'
	IF ((ix2Win < ixWin) OR (iy2Win < iyWin)) THEN GOTO Done
'
	IF (gridTypeSrc = GT_Image) THEN
		xUL = gridInfo[srcGrid].winBox.x1			' 0
		yUL = gridInfo[srcGrid].winBox.y1			' 0
		ixWin = ixWin - xUL
		iyWin = iyWin - yUL
		ix2Win = ix2Win - xUL
		iy2Win = iy2Win - yUL
		IF (ixWin < 0) THEN ixWin = 0					' nothing beyond UL
		IF (iyWin < 0) THEN iyWin = 0
		xLR = gridInfo[srcGrid].width - 1			' nothing beyond LR
		yLR = gridInfo[srcGrid].height - 1
		IF (ix2Win > xLR) THEN ix2Win = xLR
		IF (iy2Win > yLR) THEN iy2Win = yLR
	END IF
	iWidth	= (ix2Win - ixWin) + 1
	iHeight	= (iy2Win - iyWin) + 1
	IF ((iWidth <= 0) OR (iHeight <= 0)) THEN GOTO Done					' empty
'
'	Calculate destination rectangle (include scaling)
'
	x1# = gridInfo[destGrid].gridBoxScaled.x1
	x2# = gridInfo[destGrid].gridBoxScaled.x2
	width = ABS(x2# - x1#) + 1
	IF (x2# < x1#) THEN
		xWin = xWin + width
		width = -width
	END IF
	y1# = gridInfo[destGrid].gridBoxScaled.y1
	y2# = gridInfo[destGrid].gridBoxScaled.y2
	height = ABS(y2# - y1#) + 1
	IF (y2# < y1#) THEN
		yWin = yWin + height
		height = -height
	END IF
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridTypeDest = GT_Image) THEN
		bufferGrid = destGrid
	ELSE
		IF (clipGrid != windowInfo[windowDest].clipGrid) THEN
			SetGridClip (windowDest, clipGrid)
		END IF
		IF windowInfo[windowDest].clipIsNull THEN GOTO Done		' Null intersection
'
'		NT:  BitBlt is not supported by all devices
'
		IF (windowInfo[windowDest].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			SetStretchBltMode (hdcDest, $HALFTONE)
			StretchBlt (hdcDest, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, iWidth, iHeight, $$SRCCOPY)
			##LOCKOUT = entryLOCKOUT
			x1Ext = 0
			y1Ext = 0
			x2Ext = windowInfo[windowDest].width - 1
			y2Ext = windowInfo[windowDest].height - 1
			hdcExt = hdcDest
			GOSUB ExtendImage
			##LOCKOUT = $$TRUE
'			GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
'			UpdateWindow (windowInfo[windowDest].hwnd)
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[destGrid].bufferGrid
		IFZ bufferGrid THEN GOTO Done
	END IF

	sysImage = gridInfo[bufferGrid].sysImage			' sysImage exists?
	IFZ sysImage THEN															'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN GOTO Done									' problem with sysImage
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (windowDest, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN GOTO Done			' Null intersection
'
'	Translate to image coordinates
'		(x,y) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	xWin = xWin - gridInfo[bufferGrid].winBox.x1
	yWin = yWin - gridInfo[bufferGrid].winBox.y1
	xLR = gridInfo[bufferGrid].width - 1
	yLR = gridInfo[bufferGrid].height - 1
	hdcImage = ntImageInfo.hdcImage
	##LOCKOUT = $$TRUE
	SetStretchBltMode (hdcImage, $HALFTONE)
	StretchBlt (hdcImage, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, iWidth, iHeight, $$SRCCOPY)
	##LOCKOUT = entryLOCKOUT
	x1Ext = 0
	y1Ext = 0
	x2Ext = xLR
	y2Ext = yLR
	hdcExt = hdcImage
	GOSUB ExtendImage

Done:
	IF (gridTypeSrc = GT_Image) THEN
		##LOCKOUT = $$TRUE
		SelectObject (hdcSrc, hBitmapOrig)
		DeleteDC (hdcSrc)
		##LOCKOUT = entryLOCKOUT
	END IF
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
'	*****  ExtendImage  *****  same routine in XgrDrawImageExtend()
'		In:		(x1Ext,y1Ext), (x2Ext,y2Ext)	= destination rectangle to fill
'					(xWin,yWin), width/height			= destination rectangle already filled
'					hdcExt												= hdc to fill
'
'		Discussion:
'			Could create a temporary bitmap and BitBlt() the image there first, then
'				BitBlt() it to the destination hdc.  Decided not to do this as this
'				area could be large (up to full screen size) and take several MBytes.
'			This technique could be slower, be doesn't require the memory.
'
'		Similar approach is used in XgrDrawImageExtend()
'
SUB ExtendImage
	exWin	= xWin
	eyWin	= yWin
	w			= width
	h			= height
	IF (w < 0) THEN
		w = ABS(w)
		exWin = exWin - w
	END IF
	IF (h < 0) THEN
		h = ABS(h)
		eyWin = eyWin - h
	END IF
	ex2Win = exWin + w - 1
	ey2Win = eyWin + h - 1
'
'	Left
'
	IF (exWin > x1Ext) THEN
		##LOCKOUT = $$TRUE
		FOR x = (exWin - 1) TO x1Ext STEP -1
			BitBlt (hdcExt, x, eyWin, 1, h, hdcExt, exWin, eyWin, $$SRCCOPY)
		NEXT x
'
'		UL
'
		IF (eyWin > y1Ext) THEN
			pixel = GetPixel (hdcExt, exWin, eyWin)
			IF (pixel != -1) THEN
				rect.left		= x1Ext
				rect.top		= y1Ext
				rect.right	= exWin		' FillRect() doesn't do bottom/right
				rect.bottom	= eyWin
				hBrush	= CreateSolidBrush (pixel)
				FillRect (hdcExt, &rect, hBrush)
				DeleteObject (hBrush)
			END IF
		END IF
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	Top
'
	IF (eyWin > y1Ext) THEN
		##LOCKOUT = $$TRUE
		FOR y = (eyWin - 1) TO y1Ext STEP -1
			BitBlt (hdcExt, exWin, y, w, 1, hdcExt, exWin, eyWin, $$SRCCOPY)
		NEXT y
'
'		UR
'
		IF (ex2Win < x2Ext) THEN
			pixel = GetPixel (hdcExt, ex2Win, eyWin)
			IF (pixel != -1) THEN
				rect.left		= ex2Win + 1
				rect.top		= y1Ext
				rect.right	= x2Ext + 1		' FillRect() doesn't do bottom/right
				rect.bottom	= eyWin
				hBrush	= CreateSolidBrush (pixel)
				FillRect (hdcExt, &rect, hBrush)
				DeleteObject (hBrush)
			END IF
		END IF
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	Right
'
	IF (ex2Win < x2Ext) THEN
		##LOCKOUT = $$TRUE
		FOR x = (ex2Win + 1) TO x2Ext
			BitBlt (hdcExt, x, eyWin, 1, h, hdcExt, ex2Win, eyWin, $$SRCCOPY)
		NEXT x
'
'		LR
'
		IF (ey2Win < y2Ext) THEN
			pixel = GetPixel (hdcExt, ex2Win, ey2Win)
			IF (pixel != -1) THEN
				rect.left		= ex2Win + 1
				rect.top		= ey2Win + 1
				rect.right	= x2Ext + 1		' FillRect() doesn't do bottom/right
				rect.bottom	= y2Ext + 1
				hBrush	= CreateSolidBrush (pixel)
				FillRect (hdcExt, &rect, hBrush)
				DeleteObject (hBrush)
			END IF
		END IF
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	Bottom
'
	IF (ey2Win < y2Ext) THEN
		##LOCKOUT = $$TRUE
		FOR y = (ey2Win + 1) TO y2Ext
			BitBlt (hdcExt, exWin, y, w, 1, hdcExt, exWin, ey2Win, $$SRCCOPY)
		NEXT y
'
'		LL
'
		IF (exWin > x1Ext) THEN
			pixel = GetPixel (hdcExt, exWin, ey2Win)
			IF (pixel != -1) THEN
				rect.left		= x1Ext
				rect.top		= ey2Win + 1
				rect.right	= exWin 				' FillRect() doesn't do bottom/right
				rect.bottom	= y2Ext + 1
				hBrush	= CreateSolidBrush (pixel)
				FillRect (hdcExt, &rect, hBrush)
				DeleteObject (hBrush)
			END IF
		END IF
		##LOCKOUT = entryLOCKOUT
	END IF
END SUB
END FUNCTION
'
'
' ###################################
' #####  XgrDrawImageScaled ()  #####
' ###################################
'
'	Scale draw srcGrid to destGrid at current draw point
'
'	In:				destGrid
'						srcGrid
'						x1, y1			srcGrid start (local coordinates)
'						x2, y2			srcGrid end
'
'	Out:			none				arg unchanged
'
'	Return:		$$FALSE			no errors
'						$$TRUE			errors
'
'	Discussion:
'		If x2/y2 = -1, set to xy limits of srcGrid
'		The scaled coordinates of the destination specify the scale
'			factor and orientation (mirror or not).
'
FUNCTION  XgrDrawImageScaled (destGrid, srcGrid, x1, y1, x2, y2, dx1, dy1)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  points[]
	SHARED  GT_Image
'
	$HALFTONE = 5
'
	IF InvalidGrid (srcGrid) THEN RETURN ($$TRUE)
	IF InvalidGrid (destGrid) THEN RETURN ($$TRUE)
	IF (destGrid = srcGrid) THEN
		PRINT "XgrDrawImageScaled():  copy grid image to itself - unavailable"
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	windowSrc		= gridInfo[srcGrid].window
	gridTypeSrc	= gridInfo[srcGrid].gridType
	IF (gridTypeSrc = GT_Image) THEN
		sysImageSrc = gridInfo[srcGrid].sysImage
		IFZ sysImageSrc THEN														' image is empty
			##WHOMASK = entryWHOMASK
			RETURN ($$FALSE)
		END IF
'
'		Create a temporary hdc for source
'			Nothing fancy required for BitBlt()
'
		hdcSrc			= CreateCompatibleDC (windowInfo[windowSrc].hdc)
		IF (sysImageSrc = ntImageInfo.hBitmap) THEN			' bitmap in only 1 hdc at a time
			defaultBitmap = ntImageInfo.defaultBitmap
			SelectObject (ntImageInfo.hdcImage, defaultBitmap)
			ntImageInfo.hBitmap = defaultBitmap
		END IF
		hBitmapOrig = SelectObject (hdcSrc, sysImageSrc)
	ELSE
		hdcSrc = windowInfo[windowSrc].hdc
	END IF

	windowDest		= gridInfo[destGrid].window
	gridTypeDest	= gridInfo[destGrid].gridType
	clipGrid			= gridInfo[destGrid].clipGrid
	IF (gridTypeDest != GT_Image) THEN
		hdcDest = windowInfo[windowDest].hdc
	END IF
'
'	Basic transfer:	xWin,yWin									destGrid
'									ixWin,iyWin,width,height	srcGrid
'
	dx1Win = gridInfo[destGrid].winBox.x1
	dy1Win = gridInfo[destGrid].winBox.y1
'	xWin = dx1Win + gridInfo[destGrid].drawpoint.x
'	yWin = dy1Win + gridInfo[destGrid].drawpoint.y
	xWin = dx1Win + dx1
	yWin = dy1Win + dy1
'
	calculateCoordinates(srcGrid, x1, y1, x2, y2, @ixWin, @iyWin, @ix2Win, @iy2Win)
'
	IF ((ix2Win < ixWin) OR (iy2Win < iyWin)) THEN GOTO Done
'
	IF (gridTypeSrc = GT_Image) THEN
		xUL = gridInfo[srcGrid].winBox.x1			' 0
		yUL = gridInfo[srcGrid].winBox.y1			' 0
		ixWin = ixWin - xUL
		iyWin = iyWin - yUL
		ix2Win = ix2Win - xUL
		iy2Win = iy2Win - yUL
		IF (ixWin < 0) THEN ixWin = 0					' nothing beyond UL
		IF (iyWin < 0) THEN iyWin = 0
		xLR = gridInfo[srcGrid].width - 1			' nothing beyond LR
		yLR = gridInfo[srcGrid].height - 1
		IF (ix2Win > xLR) THEN ix2Win = xLR
		IF (iy2Win > yLR) THEN iy2Win = yLR
	END IF
	iWidth	= (ix2Win - ixWin) + 1
	iHeight	= (iy2Win - iyWin) + 1
	IF ((iWidth <= 0) OR (iHeight <= 0)) THEN GOTO Done		' empty
'
'	Calculate destination rectangle (include scaling)
'
	x1# = gridInfo[destGrid].gridBoxScaled.x1
	x2# = gridInfo[destGrid].gridBoxScaled.x2
	width = ABS(x2# - x1#) + 1
	IF (x2# < x1#) THEN
		xWin = xWin + width
		width = -width
	END IF
	y1# = gridInfo[destGrid].gridBoxScaled.y1
	y2# = gridInfo[destGrid].gridBoxScaled.y2
	height = ABS(y2# - y1#) + 1
	IF (y2# < y1#) THEN
		yWin = yWin + height
		height = -height
	END IF
'
'	If grid is GT_Image, doesn't draw into window
'
	IF (gridTypeDest = GT_Image) THEN
		bufferGrid = destGrid
	ELSE
		IF (clipGrid != windowInfo[windowDest].clipGrid) THEN
			SetGridClip (windowDest, clipGrid)
		END IF
		IF windowInfo[windowDest].clipIsNull THEN GOTO Done		' Null intersection
'
'		NT:  BitBlt is not supported by all devices
'
		IF (windowInfo[windowDest].visible != $$WindowMinimized) THEN
			##LOCKOUT = $$TRUE
			SetStretchBltMode (hdcDest, $HALFTONE)
			StretchBlt (hdcDest, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, iWidth, iHeight, $$SRCCOPY)
'			GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
'			UpdateWindow (windowInfo[windowDest].hwnd)
			##LOCKOUT = entryLOCKOUT
		END IF
'
'		Buffering?
'
		bufferGrid = gridInfo[destGrid].bufferGrid
		IFZ bufferGrid THEN GOTO Done								' no buffering
	END IF

	sysImage = gridInfo[bufferGrid].sysImage			' sysImage exists?
	IFZ sysImage THEN															'		if not, make sysImage
		CreateSysImage (bufferGrid, @sysImage)
		IFZ sysImage THEN GOTO Done									' problem with sysImage
	ELSE
		UpdateSysImage (bufferGrid)
	END IF
'
	SetImageClip (windowDest, clipGrid, bufferGrid)
	IF ntImageInfo.clipIsNull THEN GOTO Done			' Null intersection
'
'	Translate to image coordinates
'		(x,y) is relative to the WINDOW origin of (0,0)
'		Must subtract off the origin of the bufferGrid because
'			the sysImage upper left corner is (0,0)--
'			NOT (winBox.x1,winBox.y1).
'
	xWin = xWin - gridInfo[bufferGrid].winBox.x1
	yWin = yWin - gridInfo[bufferGrid].winBox.y1
	hdcImage = ntImageInfo.hdcImage
	##LOCKOUT = $$TRUE
	SetStretchBltMode (hdcImage, $HALFTONE)
	StretchBlt (hdcImage, xWin, yWin, width, height, hdcSrc, ixWin, iyWin, iWidth, iHeight, $$SRCCOPY)
	##LOCKOUT = entryLOCKOUT

Done:
	IF (gridTypeSrc = GT_Image) THEN
		##LOCKOUT = $$TRUE
		SelectObject (hdcSrc, hBitmapOrig)
		DeleteDC (hdcSrc)
		##LOCKOUT = entryLOCKOUT
	END IF
	##WHOMASK = entryWHOMASK
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
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
'
	$BI_RGB       = 0					' 24-bit RGB
	$BI_BITFIELDS = 3					' 32-bit RGB
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	DIM image[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	gridType = gridInfo[grid].gridType
'
	IF (gridType = GT_Image) THEN
		sysImage = gridInfo[grid].sysImage
		IFZ sysImage THEN RETURN ($$FALSE)
		hdc = ntImageInfo.hdcImage
	ELSE
		hdc = windowInfo[window].hdc
	END IF
'
	width = gridInfo[grid].width
	height = gridInfo[grid].height
'
'	dataOffset = 128			'???? why set to 128 if dataOffset for 24-bit is 54?
	dataOffset = 54
'
' alignment on multiple of 32 bits or 4 bytes
'
'	#####  v 0.0433 : SVG : simplified following line
'
	size = dataOffset + (height * ((width * 3) + 3 AND -4))
	upper = size - 1
	DIM image[upper]
'
'	Fill BITMAPFILEHEADER
'		Windows version:  little ENDIAN; no alignment concerns
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
'
	IF (gridType = GT_Image) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		IF (sysImage = ntImageInfo.hBitmap) THEN			' bitmap not in hdc
			defaultBitmap = ntImageInfo.defaultBitmap
			SelectObject (hdc, defaultBitmap)
			ntImageInfo.hBitmap = defaultBitmap
		END IF
		res = GetDIBits (hdc, sysImage, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	ELSE
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		x = gridInfo[grid].winBox.x1
		y = gridInfo[grid].winBox.y1
		hdcTmp	= CreateCompatibleDC (hdc)
		hBitmap	= CreateCompatibleBitmap (hdc, width, height)
		hBitmapOld = SelectObject (hdcTmp, hBitmap)
		BitBlt (hdcTmp, 0, 0, width, height, hdc, x, y, $$SRCCOPY)
		hBitmap	= SelectObject (hdcTmp, hBitmapOld)	' bitmap not in hdc
		GetDIBits (hdc, hBitmap, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)
		DeleteObject (hBitmapOld)
		DeleteObject (hBitmap)
		DeleteDC (hdcTmp)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
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
'	Load DIB format image[] from disk file
' convert from other color depths to 24-bit or 32-bit RGB
'
FUNCTION  XgrLoadImage (fileName$, UBYTE image[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  GT_Image
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	DIM image[]
'
	IFZ fileName$ THEN
		error = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	ifile = OPEN (fileName$, $$RD)
'
	IF (ifile < 3) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	bytes = LOF (ifile)
	upper = bytes - 1
	DIM image[upper]
'
	old = ERROR (0)
	bytesRead = XstBinRead (ifile, &image[], bytes)
	CLOSE (ifile)
'
	IF (bytesRead != bytes) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureFailed
		old = ERROR (error)
		DIM image[]
		RETURN ($$TRUE)
	END IF
'
	byte0 = image[0]
	byte1 = image[1]
	byte2 = image[2]
	byte3 = image[3]
	byte4 = image[4]
	byte5 = image[5]
'
	SELECT CASE TRUE
		CASE ((byte0='B') & (byte1='M'))								: GOSUB BM
		CASE ((byte0='G') & (byte1='I') & (byte2='F'))	: GOSUB GIF
		CASE ELSE																				: DIM image[]
																											error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
																											RETURN ($$TRUE)
	END SELECT
'
'
' *****  BM  *****
'
SUB BM
	bs = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2
'
	IF (bs > bytes) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureFailed
		old = ERROR (error)
		DIM image[]
		RETURN ($$TRUE)
	END IF
END SUB
'
'
' *****  GIF  *****
'
SUB GIF
	PRINT "XgrLoadImage() : GIF : error : not implemented"
END SUB
END FUNCTION
'
'
' ###############################
' #####  XgrRefreshGrid ()  #####
' ###############################
'
' copy buffer grid onto grid
'
FUNCTION  XgrRefreshGrid (grid)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	window = gridInfo[grid].window
	IF (windowInfo[window].visible = $$WindowMinimized) THEN RETURN ($$FALSE)
'
	bufferGrid = gridInfo[grid].bufferGrid
'
	IFZ bufferGrid THEN RETURN ($$TRUE)
'
	IF (gridInfo[bufferGrid].gridType != GT_Image) THEN RETURN ($$TRUE)
'
	sysImage = gridInfo[bufferGrid].sysImage
	IFZ sysImage THEN RETURN ($$TRUE)
'
'
'	Clip to grid AND its clipGrid
'
	SetGridClip2 (window, grid, @x1, @y1, @width, @height)
'
	IF (width && height) THEN
		x2 = x1 + width - 1									' intersect clip and buffer
		y2 = y1 + height - 1
		ix1 = gridInfo[bufferGrid].winBox.x1
		iy1 = gridInfo[bufferGrid].winBox.y1
		ix2 = ix1 + gridInfo[bufferGrid].width - 1
		iy2 = iy1 + gridInfo[bufferGrid].height - 1
'
		IF ((ix1 > x2) OR (ix2 < x1)) THEN
			SetGridClip2 (window, 0, 0, 0, 0, 0)
			RETURN ($$FALSE)
		END IF
'
		IF ((iy1 > y2) OR (iy2 < y1)) THEN
			SetGridClip2 (window, 0, 0, 0, 0, 0)
			RETURN ($$FALSE)
		END IF
'
		IF (x1 < ix1) THEN x1 = ix1
		IF (ix2 < x2) THEN x2 = ix2
		IF (y1 < iy1) THEN y1 = iy1
		IF (iy2 < y2) THEN y2 = iy2
		width = x2 - x1 + 1
		height = y2 - y1 + 1
		hdc = windowInfo[window].hdc
		hdcImage = ntImageInfo.hdcImage
'
		IF (sysImage != ntImageInfo.hBitmap) THEN
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			SelectObject (hdcImage, sysImage)
			##LOCKOUT = lockout
			##WHOMASK = whomask
			ntImageInfo.hBitmap = sysImage
		END IF
'
'		NT : BitBlt is not supported by all devices
'
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		result = BitBlt (hdc, x1, y1, width, height, hdcImage, x1 - ix1, y1 - iy1, $$SRCCOPY)
'		GetQueueStatus ($$QS_ALLEVENTS)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
'
	SetGridClip2 (window, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' #############################
' #####  XgrSaveImage ()  #####
' #############################
'
FUNCTION  XgrSaveImage (fileName$, UBYTE image[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  GT_Image
'
	IFZ image[] THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	size = SIZE (image[])
'
	IF (size < 64) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IFZ fileName$ THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidName
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
'	Set DIB format image[] into grid
'
'	In:				grid				Screen grid or Image grid
'						image[]			DIB format
'
'	Return:		$$FALSE			no errors
'						$$TRUE			errors
'
'		Bitmap structure:
'			Bytes			Structure
'			0  - 13		BITMAPFILEHEADER
'			14 -			BITMAPINFO or BITMAPCOREINFO
'
FUNCTION  XgrSetImage (grid, UBYTE image[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IFZ image[] THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	size = SIZE (image[])
'
	IF (size < 64) THEN
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
'
	bytes = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2
'
	IF (size < bytes) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	iAddr = &image[]
	window = gridInfo[grid].window
	gridType = gridInfo[grid].gridType
'
	IF (gridType = GT_Image) THEN
		sysImage = gridInfo[grid].sysImage
		IFZ sysImage THEN												' if not, make sysImage
			CreateSysImage (grid, @sysImage)
			IFZ sysImage THEN
				error = ($$ErrorObjectImage << 8) OR $$ErrorNatureFailed
				old = ERROR (error)
				RETURN ($$TRUE)
			END IF
		ELSE
			UpdateSysImage (grid)
		END IF
		hdc = ntImageInfo.hdcImage
	ELSE
		hdc = windowInfo[window].hdc
	END IF
'
'
'
	byte10 = image[10]
	byte11 = image[11]
	byte12 = image[12]
	byte13 = image[13]
'
	dataOffset = (byte13 << 24) OR (byte12 << 16) OR (byte11 << 8) OR byte10
'
	byte14 = image[14]
	byte15 = image[15]
	byte16 = image[16]
	byte17 = image[17]
'
	headerSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14
'
'	copy the image
'
	xDest = 0
	yDest = 0
	IF (gridType != GT_Image) THEN
		xDest = gridInfo[grid].winBox.x1
		yDest = gridInfo[grid].winBox.y1
	END IF
'
	xSrc = 0
	ySrc = 0
	info = 14
	bitmapInfo = iAddr + 14
	bitmapData = iAddr + dataOffset
	usage = $$DIB_RGB_COLORS							' RGB values
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
	startScan = 0
	scanLines = height
'
'	Clipping could be made more efficient
'		But remember, DIB scan lines may be stored from LowerLeft up
'
	SetGridClip2 (window, grid, 0, 0, 0, 0)
'
' SetDIBitsToDevice() for memory dc doesn't work on Win32s (6/29/93)
'
	version = XxxGetVersion()
	platform = (version >> 16) AND 0x00FF
	IF (platform == $$VER_PLATFORM_WIN32s) THEN win32s = $$TRUE ELSE win32s = $$FALSE
'
	IF (win32s && (gridType = GT_Image)) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		defaultBitmap = ntImageInfo.defaultBitmap
		hBitmap = SelectObject (hdc, defaultBitmap)
		ok = SetDIBits (hdc, hBitmap, startScan, scanLines, bitmapData, bitmapInfo, usage)
		SelectObject (hdc, hBitmap)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	ELSE
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		ok = SetDIBitsToDevice (hdc, xDest, yDest, width, height, xSrc, ySrc, startScan, scanLines, bitmapData, bitmapInfo, usage)
'		IF (gridType != GT_Image) THEN GetQueueStatus ($$QS_ALLEVENTS)			' Force change NOW
'		IF (gridType != GT_Image) THEN UpdateWindow (windowInfo[window].hwnd)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
'
	SetGridClip2 (window, 0, 0, 0, 0, 0)
	IFZ ok THEN RETURN ($$TRUE)
END FUNCTION
'
'
' #################################
' #####  XgrGetMouseFocus ()  #####
' #################################
'
'	Get mouse focus grid for window
'
'	in			: window
' out			: grid			with focus (0 if not in this window)
'	return	: $$FALSE = no error
'						$$TRUE = error
'
' one mouse focus per display
'
FUNCTION  XgrGetMouseFocus (window, grid)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]

	grid = 0
	IF InvalidWindow (window) THEN RETURN ($$TRUE)

	host = windowInfo[window].host
	grid = hostDisplay[host].grabMouseFocusGrid
END FUNCTION
'
'
' ################################
' #####  XgrGetMouseInfo ()  #####
' ################################
'
'	Get mouse info for this window
'
'	in			:	window
'
'	out			:	grid				grid with mouse focus (0 if none)
'						xWin				xy in window coordinates wrt window
'						yWin
'						state				button states
'						time
'
'	return	:	$$FALSE = no errors
'						$$TRUE = error
'
'	Returns xWin, yWin for window even if mouse is outside that window.
'	Error if mouse is not on display with this window (esoteric).
'
FUNCTION  XgrGetMouseInfo (window, grid, x, y, state, time)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED	lastMouseWindow
	STATIC  POINT  point
'
	IF (window <= 0) THEN window = lastMouseWindow
	grid = 0 : x = 0 : y = 0 : state = 0 : time = 0
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = 0
'
	hwnd = windowInfo[window].hwnd
	host = windowInfo[window].host
'
	##LOCKOUT = $$TRUE
	GetCursorPos(&point)
	ScreenToClient(hwnd, &point)
	##LOCKOUT = lockout
	x = point.x											' window coords if no grid
	y = point.y											' window coords if no grid
'
'	Mouse State:	Bits
'								24-31		btn state		buttons 1-8 (24-31);  1 = down
'								19-23		0						unused/reserved for key state use
'								18			KeyAlt			1 = down
'								17			KeyControl		"
'								16			KeyShift			"
'								8-15		0						unused/reserved
'								7				focus				1 = grid has mouse focus
'								4-6			0						clicks 1-4 (button down only)
'								0-3			button			0-8 button number (0 for mouse motion)
'
' Note: GetAsyncKeyState() returns a value with the most significant bit
' (0x8000) set if a key/button is currently pressed and the least significant
' bit (0x0001) if it has been pressed since the last call to
' GetAsyncKeyState(). We're only interested in if it is currently pressed.
'
	IF GetAsyncKeyState($$VK_SHIFT) AND 0x8000	  THEN state = state OR $$ShiftBit
	IF GetAsyncKeyState($$VK_CONTROL)	AND 0x8000	THEN state = state OR $$ControlBit
	IF GetAsyncKeyState($$VK_MENU) AND 0x8000			THEN state = state OR $$AltBit
	IF GetAsyncKeyState($$VK_LBUTTON) AND 0x8000	THEN state = state OR $$LeftButtonBit
	IF GetAsyncKeyState($$VK_MBUTTON)	AND 0x8000	THEN state = state OR $$MiddleButtonBit
	IF GetAsyncKeyState($$VK_RBUTTON)	AND 0x8000	THEN state = state OR $$RightButtonBit
	time = GetTickCount()
'
	grid = hostDisplay[host].grabMouseFocusGrid
'
	IF grid THEN
		state = state OR 0x80
	ELSE
		grid = ClosestGrid (window, x, y)
		IF (grid < 0) THEN grid = 0
	END IF
'
	IF grid THEN
		x = x - gridInfo[grid].winBox.x1
		y = y - gridInfo[grid].winBox.y1
	END IF
'
	##WHOMASK = whomask
END FUNCTION
'
'
' #####################################
' #####  XgrGetSelectedWindow ()  #####
' #####################################
'
'	Get current selected window on default display
'
'	In:				none
'	Out:			window		selected window on default display
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		Keyboard focus is independent for each DISPLAY.  Need a different function
'			for multiple displays.
'
FUNCTION  XgrGetSelectedWindow (window)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
'
	host = 1
	window = 0
	IFZ hostDisplay[] THEN RETURN ($$TRUE)
	IFZ hostDisplay[1].status THEN RETURN ($$TRUE)
	window = hostDisplay[host].selectedWindow
END FUNCTION
'
'
' ########################################
' #####  XgrGetTextSelectionGrid ()  #####
' ########################################
'
FUNCTION  XgrGetTextSelectionGrid (grid)
	SHARED  textSelectionGrid
'
	grid = textSelectionGrid
END FUNCTION
'
'
' #################################
' #####  XgrSetMouseFocus ()  #####
' #################################
'
'	Set mouse focus grid for window
'
'	in			: window, grid
'	out			: none
'	return	: $$FALSE = no error
'						$$TRUE = error
'
' one mouse focus per display
'
FUNCTION  XgrSetMouseFocus (window, grid)
	SHARED  xgrError
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  XGR_MESSAGE  lastMouseMessage
	SHARED  #LostMouseFocus

	IF InvalidWindow (window) THEN RETURN ($$TRUE)

	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0

	hwnd = windowInfo[window].hwnd
	host = windowInfo[window].host

	IFZ grid THEN
		grabGrid = hostDisplay[host].grabMouseFocusGrid
		IF grabGrid THEN
			##LOCKOUT = $$TRUE
			ReleaseCapture()
			##LOCKOUT = entryLOCKOUT
			XgrAddMessage (grabGrid, #LostMouseFocus, 0, 0, 0, 0, 0, grabGrid)
		END IF
		hostDisplay[host].grabMouseFocusGrid = 0

		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF

	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
	IF (window != gridInfo[grid].window) THEN
		xgrError = $$XgrDifferentWindows
		##WHOMASK = entryWHOMASK
		RETURN ($$TRUE)
	END IF

	mouseState		= hostDisplay[host].mouseState
	mouseXDisp		= hostDisplay[host].mouseXDisp
	mouseYDisp		= hostDisplay[host].mouseYDisp
	buttonDown		= mouseState AND 0xFF000000

'	IFZ buttonDown THEN
'		grabGrid = hostDisplay[host].grabMouseFocusGrid
'		IF grabGrid THEN
'			##LOCKOUT = $$TRUE
'			IF (GetCapture() = hwnd) THEN ReleaseCapture()
'			##LOCKOUT = entryLOCKOUT
'			XgrAddMessage (grabGrid, #LostMouseFocus, 0, 0, 0, 0, 0, grabGrid)
'		END IF
'		hostDisplay[host].grabMouseFocusGrid = 0
'	ELSE
		##LOCKOUT = $$TRUE
		SetCapture (hwnd)
		##LOCKOUT = entryLOCKOUT

		xWin = mouseXDisp - windowInfo[window].xDisp
		yWin = mouseYDisp - windowInfo[window].yDisp

		xUL = gridInfo[grid].winBox.x1
		yUL = gridInfo[grid].winBox.y1
		xLR = gridInfo[grid].winBox.x2
		yLR = gridInfo[grid].winBox.y2

		inside = $$FALSE
		IF ((xUL <= xWin) AND (xWin <= xLR)) THEN
			IF ((yUL <= yWin) AND (yWin <= yLR)) THEN
				inside = grid
			END IF
		END IF

		hostDisplay[host].grabMouseFocusGrid = grid
		hostDisplay[host].gridMouseInside = inside
'	END IF
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' #####################################
' #####  XgrSetSelectedWindow ()  #####
' #####################################
'
FUNCTION  XgrSetSelectedWindow (window)
	SHARED  WINDOWINFO  windowInfo[]
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hwnd = windowInfo[window].hwnd
	visible = windowInfo[window].visible
	windowInfo[window].visible = $$WindowDisplayed
'
	show = $$SW_SHOW
	windowType = windowInfo[window].windowType
	IF (windowType AND $$WindowTypeNoSelect) THEN show = $$SW_SHOWNOACTIVATE
'
	##LOCKOUT = $$TRUE
'	ShowWindow (hwnd, show)			' doesn't activate window as doc claims
	SetActiveWindow (hwnd)			' works okay on WindowsNT
'	SetFocus (hwnd)							' works okay on WindowsNT
	UpdateWindow (hwnd)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ########################################
' #####  XgrSetTextSelectionGrid ()  #####
' ########################################
'
FUNCTION  XgrSetTextSelectionGrid (grid)
	SHARED  textSelectionGrid
'
	IF (grid = textSelectionGrid) THEN RETURN ($$FALSE)
'
	IFZ grid THEN
		IF textSelectionGrid THEN
			XgrAddMessage (textSelectionGrid, #LostTextSelection, 0, 0, 0, 0, 0, textSelectionGrid)
		END IF
	END IF
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	IF textSelectionGrid THEN
		XgrAddMessage (textSelectionGrid, #LostTextSelection, 0, 0, 0, 0, 0, textSelectionGrid)
	END IF
	textSelectionGrid = grid
END FUNCTION
'
'
' ##############################
' #####  XgrAddMessage ()  #####
' ##############################
'
FUNCTION  XgrAddMessage (wingrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  systemMessageQueueOut
	SHARED  systemMessageQueueIn
	SHARED  userMessageQueueOut
	SHARED  userMessageQueueIn
	SHARED  noMessagesTillSystemQueueEmptied
	SHARED  noMessagesTillUserQueueEmptied
	SHARED  xgrInitialized
	SHARED  xgrError
'
	IFZ xgrInitialized THEN RETURN ($$TRUE)
'
	XgrGetMessageType (message, @msgType)
	IFZ msgType THEN RETURN ($$TRUE)
'
	IF (msgType = $$Window) THEN
		IF InvalidWindow (wingrid) THEN RETURN ($$TRUE)
		window = wingrid
	ELSE
		IF InvalidGrid (wingrid) THEN RETURN ($$TRUE)
		window = gridInfo[wingrid].window
	END IF
'
	entryALARMBUSY = ##ALARMBUSY
	##ALARMBUSY	= $$TRUE
'
	whomask	= windowInfo[window].whomask
	IFZ whomask THEN																' system queue
		IF noMessagesTillSystemQueueEmptied THEN
			xgrError = $$XgrMessageQueueFull
			##ALARMBUSY = entryALARMBUSY
			EXIT FUNCTION ($$TRUE)
		END IF
'
'	if next systemMessageQueueIn = current systemMessageQueueOut, queue full
'
		nextMessageQueueIn = systemMessageQueueIn + 1
		IF (nextMessageQueueIn > UBOUND(systemMessageQueue[])) THEN
			nextMessageQueueIn = 0
		END IF
'
		IF (nextMessageQueueIn = systemMessageQueueOut) THEN
			noMessagesTillSystemQueueEmptied = $$TRUE		' queue full
			PRINT "XgrAddMessage() :  System Message Queue full!!!"
			xgrError = $$XgrMessageQueueFull
			##ALARMBUSY	= entryALARMBUSY
			EXIT FUNCTION ($$TRUE)
		END IF
'
		systemMessageQueue[systemMessageQueueIn].message	= message
		systemMessageQueue[systemMessageQueueIn].wingrid	= wingrid
		systemMessageQueue[systemMessageQueueIn].v0				= v0
		systemMessageQueue[systemMessageQueueIn].v1				= v1
		systemMessageQueue[systemMessageQueueIn].v2				= v2
		systemMessageQueue[systemMessageQueueIn].v3				= v3
		systemMessageQueue[systemMessageQueueIn].r0				= r0
		systemMessageQueue[systemMessageQueueIn].r1				= r1
		systemMessageQueueIn = nextMessageQueueIn
	ELSE																						' user queue
		IF noMessagesTillUserQueueEmptied THEN
			xgrError = $$XgrMessageQueueFull
			##ALARMBUSY = entryALARMBUSY
			EXIT FUNCTION ($$TRUE)
		END IF
'
' if next userMessageQueueIn = current userMessageQueueOut, queue full
'
		nextMessageQueueIn = userMessageQueueIn + 1
		IF (nextMessageQueueIn > UBOUND(userMessageQueue[])) THEN
			nextMessageQueueIn = 0
		END IF
'
		IF (nextMessageQueueIn = userMessageQueueOut) THEN
			noMessagesTillUserQueueEmptied = $$TRUE		' queue full
			PRINT "XgrAddMessage() :  User Message Queue full!!!"
			xgrError = $$XgrMessageQueueFull
			##ALARMBUSY	= entryALARMBUSY
			EXIT FUNCTION ($$TRUE)
		END IF
'
		userMessageQueue[userMessageQueueIn].message	= message
		userMessageQueue[userMessageQueueIn].wingrid	= wingrid
		userMessageQueue[userMessageQueueIn].v0				= v0
		userMessageQueue[userMessageQueueIn].v1				= v1
		userMessageQueue[userMessageQueueIn].v2				= v2
		userMessageQueue[userMessageQueueIn].v3				= v3
		userMessageQueue[userMessageQueueIn].r0				= r0
		userMessageQueue[userMessageQueueIn].r1				= r1
		userMessageQueueIn = nextMessageQueueIn
	END IF
'
	##ALARMBUSY	= entryALARMBUSY
END FUNCTION
'
'
' ##################################
' #####  XgrDeleteMessages ()  #####
' ##################################
'
FUNCTION  XgrDeleteMessages (count)
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  systemMessageQueueOut
	SHARED  systemMessageQueueIn
	SHARED  userMessageQueueOut
	SHARED  userMessageQueueIn
	SHARED  xgrInitialized
	SHARED  xgrError
'
	IFZ xgrInitialized THEN RETURN ($$TRUE)
'
	whomask = ##WHOMASK
	XgrMessagesPending (@messages)
	IFZ messages THEN RETURN ($$FALSE)
	IF (messages < count) THEN count = messages
'
	IFZ whomask THEN
		systemMessageQueueOut = systemMessageQueueOut + count
		uQueue = UBOUND(systemMessageQueue[])
		IF (systemMessageQueueOut > uQueue) THEN
			systemMessageQueueOut = systemMessageQueueOut - uQueue - 1
		END IF
	ELSE
		userMessageQueueOut = userMessageQueueOut + count
		uQueue = UBOUND(userMessageQueue[])
		IF (userMessageQueueOut > uQueue) THEN
			userMessageQueueOut = userMessageQueueOut - uQueue - 1
		END IF
	END IF
END FUNCTION
'
'
' ##########################
' #####  XgrGetCEO ()  #####
' ##########################
'
'	Get CEO function
'
'	Out:			func
'
'	Return:		$$FALSE		no error
'						$$TRUE		error
'
'	Discussion:
'		##WHOMASK is used to determine if system or user CEO function
'
FUNCTION  XgrGetCEO (func)
	SHARED  systemCEO,  userCEO
'
	IF ##WHOMASK THEN func = userCEO ELSE func = systemCEO
END FUNCTION
'
'
' ###############################
' #####  XgrGetMessages ()  #####
' ###############################
'
FUNCTION  XgrGetMessages (count, MESSAGE messages[])
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  systemMessageQueueOut
	SHARED  systemMessageQueueIn
	SHARED  userMessageQueueOut
	SHARED  userMessageQueueIn
	SHARED  xgrInitialized
	SHARED  xgrError
'
	count = 0
	DIM messages[]
'
	IFZ xgrInitialized THEN RETURN ($$TRUE)
	XgrMessagesPending (@messages)
	IF (messages <= 0) THEN RETURN ($$FALSE)			' no messages
'	PRINT "XgrGetMessages() : messages pending = "; messages
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ whomask THEN
		upper = UBOUND (systemMessageQueue[])
		out = systemMessageQueueOut
		in = systemMessageQueueIn
		IF (in = out) THEN RETURN									' no messages in queue
		DIM messages[upper]
		count = 0
		ooo = out
		iii = in
'
		FOR i = 0 TO upper
			INC count
			messages[i] = systemMessageQueue[out]
			IF (out < upper) THEN INC out ELSE out = 0
			IF (out = in) THEN EXIT FOR
		NEXT i
		REDIM messages[count-1]
'		PRINT "sss : "; messages;; count;; upper;; ooo;; iii;; out;; in
	ELSE
		upper = UBOUND (userMessageQueue[])
		out = userMessageQueueOut
		in = userMessageQueueIn
		IF (in = out) THEN RETURN									' no messages in queue
		DIM messages[upper]
		count = 0
		ooo = out
		iii = in
'
		FOR i = 0 TO upper
			INC count
			messages[i] = userMessageQueue[out]
			IF (out < upper) THEN INC out ELSE out = 0
			IF (out = in) THEN EXIT FOR
		NEXT i
		REDIM messages[count-1]
'		PRINT "uuu : "; messages;; count;; upper;; ooo;; iii;; out;; in
	END IF
END FUNCTION
'
'
' ##################################
' #####  XgrGetMessageType ()  #####
' ##################################
'
'	#		messageType
' 0 = not defined
' 1 = window message
' 2 = grid message
'
FUNCTION  XgrGetMessageType (message, messageType)
	SHARED  xgrError
	SHARED  SBYTE  msgType[]
	SHARED  messagePtr
'
	messageType = 0
	IF ((message <= 0) OR (message > messagePtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
	messageType = msgType[message]
END FUNCTION
'
'
' ##############################
' #####  XgrJamMessage ()  #####
' ##############################
'
FUNCTION  XgrJamMessage (wingrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  systemMessageQueueOut
	SHARED  systemMessageQueueIn
	SHARED  userMessageQueueOut
	SHARED  userMessageQueueIn
	SHARED  noMessagesTillSystemQueueEmptied
	SHARED  noMessagesTillUserQueueEmptied
	SHARED  xgrInitialized
	SHARED  xgrError
'
	IFZ xgrInitialized THEN RETURN ($$TRUE)
	XgrGetMessageType (message, @msgType)
	IFZ msgType THEN RETURN ($$TRUE)
'
	IF (msgType = $$Window) THEN
		IF InvalidWindow (wingrid) THEN RETURN ($$TRUE)
		window = wingrid
	ELSE
		IF InvalidGrid (wingrid) THEN RETURN ($$TRUE)
		window = gridInfo[wingrid].window
	END IF
'
	entryALARMBUSY = ##ALARMBUSY
	##ALARMBUSY	= $$TRUE
'
	whomask	= windowInfo[window].whomask
	IFZ whomask THEN																' system queue
		IF noMessagesTillSystemQueueEmptied THEN
			xgrError = $$XgrMessageQueueFull
			##ALARMBUSY = entryALARMBUSY
			EXIT FUNCTION ($$TRUE)
		END IF
'
' if next systemMessageQueueOut = current systemMessageQueueIn, queue full
'
		nextMessageQueueOut = systemMessageQueueOut - 1
		IF (nextMessageQueueOut < 0) THEN
			nextMessageQueueOut = UBOUND(systemMessageQueue[])
		END IF
'
		IF (nextMessageQueueIn = systemMessageQueueOut) THEN
			noMessagesTillSystemQueueEmptied = $$TRUE		' queue full
			PRINT "XgrJamMessage() :  System Message Queue full!!!"
			xgrError = $$XgrMessageQueueFull
			##ALARMBUSY	= entryALARMBUSY
			EXIT FUNCTION ($$TRUE)
		END IF
'
		systemMessageQueue[nextMessageQueueOut].message	= message
		systemMessageQueue[nextMessageQueueOut].wingrid	= wingrid
		systemMessageQueue[nextMessageQueueOut].v0			= v0
		systemMessageQueue[nextMessageQueueOut].v1			= v1
		systemMessageQueue[nextMessageQueueOut].v2			= v2
		systemMessageQueue[nextMessageQueueOut].v3			= v3
		systemMessageQueue[nextMessageQueueOut].r0			= r0
		systemMessageQueue[nextMessageQueueOut].r1			= r1
		systemMessageQueueOut = nextMessageQueueOut
	ELSE																						' user queue
		IF noMessagesTillUserQueueEmptied THEN
			xgrError = $$XgrMessageQueueFull
			##ALARMBUSY = entryALARMBUSY
			EXIT FUNCTION ($$TRUE)
		END IF
'
' if next userMessageQueueOut = current userMessageQueueIn, queue full
'
		nextMessageQueueOut = userMessageQueueOut - 1
		IF (nextMessageQueueOut < 0) THEN
			nextMessageQueueOut = UBOUND(userMessageQueue[])
		END IF
'
		IF (nextMessageQueueIn = userMessageQueueOut) THEN
			noMessagesTillUserQueueEmptied = $$TRUE		' queue full
			PRINT "XgrJamMessage() :  User Message Queue full!!!"
			xgrError = $$XgrMessageQueueFull
			##ALARMBUSY	= entryALARMBUSY
			EXIT FUNCTION ($$TRUE)
		END IF
'
		userMessageQueue[nextMessageQueueOut].message	= message
		userMessageQueue[nextMessageQueueOut].wingrid	= wingrid
		userMessageQueue[nextMessageQueueOut].v0			= v0
		userMessageQueue[nextMessageQueueOut].v1			= v1
		userMessageQueue[nextMessageQueueOut].v2			= v2
		userMessageQueue[nextMessageQueueOut].v3			= v3
		userMessageQueue[nextMessageQueueOut].r0			= r0
		userMessageQueue[nextMessageQueueOut].r1			= r1
		userMessageQueueOut = nextMessageQueueOut
	END IF
'
	##ALARMBUSY	= entryALARMBUSY
END FUNCTION
'
'
' #######################################
' #####  XgrMessageNameToNumber ()  #####
' #######################################
'
FUNCTION  XgrMessageNameToNumber (messageName$, messageNumber)
	SHARED  xgrError
	SHARED  messageHash%%[],  messageName$[],  messagePtr
	SHARED  xgrInitialized
'
	messageNumber = 0
	IFZ xgrInitialized THEN RETURN ($$TRUE)
	IFZ messageName$ THEN RETURN ($$TRUE)
'
	IF (messageName$ = "LastMessage") THEN
		messageNumber = messagePtr
		RETURN ($$FALSE)
	END IF
'
	IFZ messageHash%%[] THEN RETURN ($$FALSE)
'
	hash	= 0
	FOR i = 0 TO UBOUND(messageName$)
		hash = hash + messageName${i}
	NEXT i
	hash = hash{6,0}
'
'	is messageName$ defined?
'
	IF messageHash%%[hash,] THEN
		last = messageHash%%[hash,0]
		FOR i = 1 TO last
			check = messageHash%%[hash,i]
			IF (messageName$ = messageName$[check]) THEN
				messageNumber = check
				RETURN
			END IF
		NEXT i
	END IF
	RETURN ($$TRUE)
END FUNCTION
'
'
' ################################
' #####  XgrMessageNames ()  #####
' ################################
'
FUNCTION  XgrMessageNames (count, messages$[])
	SHARED  xgrError
	SHARED  messageHash%%[],  messageName$[],  messagePtr
	SHARED  xgrInitialized
'
	DIM messages$[]
	IFZ xgrInitialized THEN RETURN ($$TRUE)
	IFZ messageHash%%[] THEN RETURN ($$TRUE)
'
	DIM messages$[messagePtr]
	FOR i = 1 TO messagePtr
		messages$[i] = messageName$[i]
	NEXT i
	count = messagePtr
END FUNCTION
'
'
' #######################################
' #####  XgrMessageNumberToName ()  #####
' #######################################
'
FUNCTION  XgrMessageNumberToName (messageNumber, messageName$)
	SHARED  xgrError
	SHARED  messageName$[],  messagePtr
	SHARED  xgrInitialized
'
	messageName$ = ""
	IFZ xgrInitialized THEN RETURN ($$TRUE)
'
	IF ((messageNumber < 0) OR (messageNumber > messagePtr)) THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	messageName$ = messageName$[messageNumber]
END FUNCTION
'
'
' ###################################
' #####  XgrMessagesPending ()  #####
' ###################################
'
FUNCTION  XgrMessagesPending (count)
	SHARED  systemMessageQueueOut,  systemMessageQueueIn
	SHARED  userMessageQueueOut,  userMessageQueueIn
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  xgrInitialized
	SHARED  xgrError
'
	count = 0
	IFZ xgrInitialized THEN RETURN ($$TRUE)
	XxxDispatchEvents ($$FALSE, ##WHOMASK)
	whomask = ##WHOMASK
'
	IFZ whomask THEN
'		IF (systemMessageQueueOut = systemMessageQueueIn) THEN CheckMice ()		' ??? Feb 94
		SELECT CASE TRUE
			CASE (systemMessageQueueOut = systemMessageQueueIn)
						count = 0
			CASE (systemMessageQueueOut < systemMessageQueueIn)
						count = systemMessageQueueIn - systemMessageQueueOut
			CASE ELSE
						upper = UBOUND (systemMessageQueue[])
						count = systemMessageQueueIn + upper - systemMessageQueueOut + 1
		END SELECT
'		IF count THEN PRINT "XgrMessagesPending() : s : "; count;; systemMessageQueueOut;; systemMessageQueueIn
	ELSE
'		IF (userMessageQueueOut = userMessageQueueIn) THEN CheckMice ()				' ??? Feb 94
		SELECT CASE TRUE
			CASE (userMessageQueueOut = userMessageQueueIn)
						count = 0
			CASE (userMessageQueueOut < userMessageQueueIn)
						count = userMessageQueueIn - userMessageQueueOut
			CASE ELSE
						upper = UBOUND (userMessageQueue[])
						count = userMessageQueueIn + upper - userMessageQueueOut + 1
		END SELECT
'		IF count THEN PRINT "XgrMessagesPending() : u : "; count;; userMessageQueueOut;; userMessageQueueIn
	END IF
END FUNCTION
'
'
' ###############################
' #####  XgrPeekMessage ()  #####  wait for message if none pending
' ###############################
'
FUNCTION  XgrPeekMessage (wingrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  xgrError
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  systemMessageQueueOut
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  userMessageQueueOut
	SHARED  xgrInitialized
'
	IFZ xgrInitialized THEN RETURN ($$TRUE)
'
	XgrMessagesPending (@messages)
	whomask = ##WHOMASK
'
	DO UNTIL messages
		XxxDispatchEvents ($$FALSE, ##WHOMASK)
		IF ##SOFTBREAK THEN
			wingrid = 0: message = 0: v0 = 0: v1 = 0: v2 = 0: v3 = 0: r0 = 0: r1 = 0
			RETURN ($$TRUE)
		END IF
		XgrMessagesPending (@messages)
		IFZ messages THEN Sleep (0)
	LOOP
'
	IFZ whomask THEN
		message	= systemMessageQueue[systemMessageQueueOut].message
		wingrid	= systemMessageQueue[systemMessageQueueOut].wingrid
		v0			= systemMessageQueue[systemMessageQueueOut].v0
		v1			= systemMessageQueue[systemMessageQueueOut].v1
		v2			= systemMessageQueue[systemMessageQueueOut].v2
		v3			= systemMessageQueue[systemMessageQueueOut].v3
		r0			= systemMessageQueue[systemMessageQueueOut].r0
		r1			= systemMessageQueue[systemMessageQueueOut].r1
	ELSE
		message	= userMessageQueue[userMessageQueueOut].message
		wingrid	= userMessageQueue[userMessageQueueOut].wingrid
		v0			= userMessageQueue[userMessageQueueOut].v0
		v1			= userMessageQueue[userMessageQueueOut].v1
		v2			= userMessageQueue[userMessageQueueOut].v2
		v3			= userMessageQueue[userMessageQueueOut].v3
		r0			= userMessageQueue[userMessageQueueOut].r0
		r1			= userMessageQueue[userMessageQueueOut].r1
	END IF
END FUNCTION
'
'
' ###################################
' #####  XgrProcessMessages ()  #####
' ###################################
'
'	Process maxCount messages from the message queue (at least 1)
'
'	In:				maxCount		max number of messages to process
'	Out:			maxCount		number of messages still pending
'	Return:		$$FALSE			no errors
'						$$TRUE			error
'
'	##WHOMASK determines system vs user message queue
'
'	If maxCount = -1 or there are fewer than maxCount messages in the queue,
'		execute all messages in the queue (flush).
'
'	If maxCount = -2, return if no messages pending, else process all.
'	If maxCount = 0, return if no messages pending, else process 1.
'
'	Mouse messages are checked for when the userMessageQueue is empty.
'	If the mouse state or position has changed, generate a message.
'
FUNCTION  XgrProcessMessages (maxCount)
	SHARED  xgrError
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  systemMessageQueueOut,  systemMessageQueueIn
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  userMessageQueueOut,  userMessageQueueIn
	SHARED  systemCEO,  userCEO
	SHARED  xgrInitialized
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		EXIT FUNCTION ($$TRUE)
	END IF
'
	XxxDispatchEvents ($$FALSE, $$FALSE)			' collect pending events
	XgrMessagesPending (@messages)						' checks for mouse events
	SELECT CASE maxCount
		CASE  0	:	IFZ messages THEN RETURN ($$FALSE)
							maxCount = 1
		CASE -2	:	IFZ messages THEN RETURN ($$FALSE)
	END SELECT
'
	DO UNTIL messages
		XxxDispatchEvents ($$TRUE, ##WHOMASK)	' wait for system message
		IF ##SOFTBREAK THEN
			maxCount = 0
			RETURN ($$TRUE)
		END IF
		XgrMessagesPending (@messages)					' any Xgr messages?
		IFZ messages THEN Sleep (0)							' sleep one time slice
	LOOP
'
	process = maxCount
	IF (maxCount < 0) THEN process = 0				' Say:  do them all
'
	count = 1
	entryALARMBUSY = ##ALARMBUSY
	##ALARMBUSY = $$TRUE
'
	IFZ ##WHOMASK THEN												' system queue
		DO
			DO UNTIL (systemMessageQueueOut = systemMessageQueueIn)
				IF process THEN											' fixed number to process?
					IF (count > process) THEN EXIT DO
				END IF
'
				INC count
				wingrid = systemMessageQueue[systemMessageQueueOut].wingrid
				message = systemMessageQueue[systemMessageQueueOut].message
				v0			= systemMessageQueue[systemMessageQueueOut].v0
				v1			= systemMessageQueue[systemMessageQueueOut].v1
				v2			= systemMessageQueue[systemMessageQueueOut].v2
				v3			= systemMessageQueue[systemMessageQueueOut].v3
				r0			= systemMessageQueue[systemMessageQueueOut].r0
				r1			= systemMessageQueue[systemMessageQueueOut].r1
'
				INC systemMessageQueueOut
				IF (systemMessageQueueOut > UBOUND(systemMessageQueue[])) THEN
					systemMessageQueueOut = 0
				END IF
'
				GOSUB ProcessMessage
			LOOP
			IF process THEN EXIT DO
			XgrMessagesPending (@messages)					' clears NT queue
			IFZ messages THEN EXIT DO
		LOOP
		SELECT CASE TRUE
			CASE (systemMessageQueueOut = systemMessageQueueIn)
						messages = 0
			CASE (systemMessageQueueOut < systemMessageQueueIn)
						messages = systemMessageQueueIn - systemMessageQueueOut
			CASE ELSE
						messages = systemMessageQueueIn + (UBOUND(systemMessageQueue[]) - systemMessageQueueOut + 1)
		END SELECT
		maxCount = messages
	ELSE																					' user queue
		DO
			DO UNTIL (userMessageQueueOut = userMessageQueueIn)
				IF process THEN													' fixed number to process?
					IF (count > process) THEN EXIT DO
				END IF
'
				INC count
				wingrid = userMessageQueue[userMessageQueueOut].wingrid
				message = userMessageQueue[userMessageQueueOut].message
				v0			= userMessageQueue[userMessageQueueOut].v0
				v1			= userMessageQueue[userMessageQueueOut].v1
				v2			= userMessageQueue[userMessageQueueOut].v2
				v3			= userMessageQueue[userMessageQueueOut].v3
				r0			= userMessageQueue[userMessageQueueOut].r0
				r1			= userMessageQueue[userMessageQueueOut].r1
'
				INC userMessageQueueOut
				IF (userMessageQueueOut > UBOUND(userMessageQueue[])) THEN
					userMessageQueueOut = 0
				END IF
'
				GOSUB ProcessMessage
			LOOP
			IF process THEN EXIT DO									' fixed number to process
			XgrMessagesPending (@messages)					' clears NT queue
			IFZ messages THEN EXIT DO
		LOOP
		SELECT CASE TRUE
			CASE (userMessageQueueOut = userMessageQueueIn)
						messages = 0
			CASE (userMessageQueueOut < userMessageQueueIn)
						messages = userMessageQueueIn - userMessageQueueOut
			CASE ELSE
						messages = userMessageQueueIn + (UBOUND(userMessageQueue[]) - userMessageQueueOut + 1)
		END SELECT
		maxCount = messages
	END IF
'
	##ALARMBUSY = entryALARMBUSY
	RETURN ($$FALSE)
'
' *****  ProcessMessage  *****
'
SUB ProcessMessage
'	IF (message = #WindowRedraw) THEN
'		XgrRedrawWindow (wingrid, $$TRUE, v0, v1, v2, v3)
'		EXIT SUB
'	END IF
'
	XgrGetMessageType (message, @msgType)
	IFZ msgType THEN EXIT SUB
'
'	Send all messages to CEO
'
	IFZ ##WHOMASK THEN															' system CEO message
		func = systemCEO
	ELSE																						' user's CEO message
		func = userCEO
	END IF
'
	IF func THEN
		abortR0 = r0
		##ALARMBUSY = entryALARMBUSY
		@func (wingrid, message, v0, v1, v2, v3, @abortR0, r1)
		##ALARMBUSY = $$TRUE
		IF (abortR0 = -1) THEN EXIT SUB
	END IF
'
'	Send to the Window Function
'
	IF (msgType = $$Window) THEN
		window = wingrid															' here, "grid" is the window
		IF (message != #WindowDestroyed) THEN
			IFZ window THEN EXIT SUB
			IFZ windowInfo[] THEN EXIT SUB
			IF (window > UBOUND(windowInfo[])) THEN EXIT SUB
			func = windowInfo[window].func
		ELSE
			func = v0																		' window already gone
		END IF
'		SELECT CASE message
'			CASE #WindowKeyDown
'			CASE #WindowKeyUp
'			CASE #WindowMouseDown
'			CASE #WindowMouseDrag
'			CASE #WindowMouseEnter
'			CASE #WindowMouseExit
'			CASE #WindowMouseMove
'			CASE #WindowMouseUp
'			CASE ELSE
'						XgrMessageNumberToName (message, @message$)
'						PRINT "XgrProcessMessages() : "; wingrid;; message$;; v0
'		END SELECT
	ELSE
		IFZ wingrid THEN EXIT SUB
		IFZ gridInfo[] THEN EXIT SUB
		IF (wingrid > UBOUND(gridInfo[])) THEN EXIT SUB
		IFZ gridInfo[wingrid].grid THEN EXIT SUB			' wingrid is dead now
		window = gridInfo[wingrid].window
		func = windowInfo[window].func
	END IF
	##ALARMBUSY = entryALARMBUSY
	@func (wingrid, message, v0, v1, v2, v3, r0, r1)
	##ALARMBUSY = $$TRUE
END SUB
END FUNCTION
'
'
' ################################
' #####  XgrRedrawWindow ()  #####
' ################################
'
' action == 0 means queue #RedrawGrid messages for exposed grids/kids
' action != 0 means send #RedrawGrid messages to exposed grids/kids
'
'	Add #RedrawGrid messages to queue for all grids partially or fully
' within the rectangle specified by the window coordinate arguments.
' The #RedrawGrid messages must be queued/sent in parent to kid order.
' A width or height of zero or less redraws all grids in the window.
' When #RedrawGrid messages are sent to grids rather than queued,
' the clipping set for the window will prevent updates outside the
' clip rectangle, and therefore #RedrawGrid messages need not be
' sent to grids wholly outside the clip rectangle.
' When #RedrawGrid messages are queued, all kid grids must receive
' #RedrawGrid messages, and they must be told to redraw themselves
' completely, since the clip rectangle is not longer active when
' the messages are processes, and parent grids will probably erase
' all kid grids within it, whether inside the rectangle or not.
'
FUNCTION  XgrRedrawWindow (window, action, xWin, yWin, width, height)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  winGrid[]
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IFZ winGrid[window,] THEN RETURN ($$FALSE)
'
	IF (windowInfo[window].visible = $$WindowMinimized) THEN RETURN ($$FALSE)
'
	IF ((width <= 0) OR (height <= 0)) THEN width = 0 : height = 0
'
	new = 0
	IF new THEN
		grid = winGrid[window,0]
		IF grid THEN
			IFZ action THEN
				XgrAddMessage (grid, #Redraw, xWin, yWin, width, height, 0, grid)
			ELSE
				XgrSendMessage (grid, #Redraw, xWin, yWin, width, height, 0, grid)
			END IF
		END IF
	ELSE
		IF width THEN
			windowInfo[window].xClip = xWin
			windowInfo[window].yClip = yWin
			windowInfo[window].clipWidth = width
			windowInfo[window].clipHeight = height
			SetGridClip (window, 0)
		END IF
'
		FOR i = 0 TO UBOUND (winGrid[window,])
			grid = winGrid[window,i]
			IFZ grid THEN DO NEXT
			IF gridInfo[grid].disabled THEN DO NEXT
			IF gridInfo[grid].parentGrid THEN DO NEXT
			RedrawGridAndKids (grid, action, xWin, yWin, width, height)
		NEXT i
'
		IF width THEN
			windowInfo[window].xClip = 0
			windowInfo[window].yClip = 0
			windowInfo[window].clipWidth = 0
			windowInfo[window].clipHeight = 0
			SetGridClip (window, 0)
		END IF
	END IF
END FUNCTION
'
'
' ###################################
' #####  XgrRegisterMessage ()  #####
' ###################################
'
FUNCTION  XgrRegisterMessage (message$, message)
	SHARED  xgrError
	SHARED  xgrInitialized
	SHARED  SBYTE  msgType[]
	SHARED  messageHash%%[]
	SHARED	messageName$[]
	SHARED	messagePtr
'
	message = 0
	IFF xgrInitialized THEN
		xgrError = $$XgrNotInitialized
		RETURN ($$TRUE)
	END IF
'
	IFZ message$ THEN
		xgrError = $$XgrInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	IF (message$ = "LastMessage") THEN
		message = messagePtr
		RETURN ($$FALSE)
	END IF
'
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0
'
	IFZ messageHash%%[] THEN DIM messageHash%%[63,]
'
	hash	= 0
	FOR i = 0 TO UBOUND(message$)
		hash = hash + message${i}
	NEXT i
	hash = hash{6,0}									' 0-63 hash
'
'	is message$ already defined?
'
	IF messageHash%%[hash,] THEN
		last = messageHash%%[hash,0]
		FOR i = 1 TO last
			check = messageHash%%[hash,i]
			IF (message$ = messageName$[check]) THEN
				message = check
				##WHOMASK = entryWHOMASK
				RETURN ($$FALSE)
			END IF
		NEXT i
	END IF
'
'	assign a message
'
	IF (messagePtr >= 0xFFFF) THEN		' no more room
		message = 0
		xgrError = $$XgrRegisterFull
		##WHOMASK = entryWHOMASK
		RETURN ($$TRUE)
	END IF
'
	IFZ messageHash%%[hash,] THEN
		DIM temp%%[3]
		ATTACH temp%%[] TO messageHash%%[hash,]
		last = 0
	ELSE
		last = messageHash%%[hash,0]
		uMessageHash = UBOUND(messageHash%%[hash,])
		IF (last >= uMessageHash) THEN
			uMessageHash = (uMessageHash + 4) OR 3
			ATTACH messageHash%%[hash,] TO temp%%[]
			REDIM temp%%[uMessageHash]
			ATTACH temp%%[] TO messageHash%%[hash,]
		END IF
	END IF
'
	INC messagePtr										' first valid message number is 1
	message = messagePtr
'
	INC last
	messageHash%%[hash,0] = last
	messageHash%%[hash,last] = message
'
	IFZ messageName$[] THEN
		DIM messageName$[63]
		DIM msgType[63]
	ELSE
		uMessage = UBOUND(messageName$[])
		IF (message > uMessage) THEN
			uMessage = (message + 64) OR 7
			REDIM messageName$[uMessage]
			REDIM msgType[uMessage]
		END IF
	END IF
	messageName$[message] = message$
'
	msgType = $$Grid
	IF (LCASE$(LEFT$(message$,6)) = "window") THEN msgType = $$Window
	msgType[message] = msgType
'
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ###############################
' #####  XgrSendMessage ()  #####
' ###############################
'
'	send a message to a grid or window function
'
'	In:				wingrid
'						message
'						v0, v1, v2, v3
'						r0, r1
'
'	Out:			none				args unchanged
'
'	Return:		$$FALSE			no errors
'						$$TRUE			error
'
'	ANY must be sent by reference (r1)
'
FUNCTION  XgrSendMessage (wingrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	XgrGetMessageType (message, @msgType)
	IFZ msgType THEN
		xgrError = $$XgrBadMessage
		EXIT FUNCTION ($$TRUE)
	END IF
	IF (msgType = $$Window) THEN
		window = wingrid
		IF (message = #WindowDestroyed) THEN
			func = v0
		ELSE
			IF InvalidWindow (window) THEN EXIT FUNCTION ($$TRUE)
			func = windowInfo[window].func
		END IF
	ELSE
		IF InvalidGrid (wingrid) THEN EXIT FUNCTION ($$TRUE)
		func = gridInfo[wingrid].func
	END IF
	IF func THEN @func (wingrid, message, @v0, @v1, @v2, @v3, @r0, @r1)
END FUNCTION
'
'
' #######################################
' #####  XgrSendMessageToWindow ()  #####
' #######################################
'
'	Send message to window function NOW
'
'	In:				wingrid
'						message
'						v0, v1, v2, v3
'						r0, r1
'
'	Out:			none				args unchanged
'
'	Return:		$$FALSE			no errors
'						$$TRUE			error
'
'	Discussion:
'		- ANY must be sent by reference (r1)
'
FUNCTION  XgrSendMessageToWindow (wingrid, message, v0, v1, v2, v3, r0, r1)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	XgrGetMessageType (message, @msgType)
	IFZ msgType THEN
		xgrError = $$XgrBadMessage
		EXIT FUNCTION ($$TRUE)
	END IF
	IF (msgType = $$Window) THEN
		window = wingrid
		IF (message = #WindowDestroyed) THEN
			func = v0
		ELSE
			IF InvalidWindow (window) THEN EXIT FUNCTION ($$TRUE)
			func = windowInfo[window].func
		END IF
	ELSE
		IF InvalidGrid (wingrid) THEN EXIT FUNCTION ($$TRUE)
		window	= gridInfo[wingrid].window
		func		= windowInfo[window].func
	END IF
	IF func THEN @func (@wingrid, @message, @v0, @v1, @v2, @v3, @r0, @r1)
END FUNCTION
'
'
' #####################################
' #####  XgrSendStringMessage ()  #####
' #####################################
'
'	Send string message to grid or window function NOW
'
'	In:				wingrid
'						message$
'						v0, v1, v2, v3
'						r0, r1
'
'	Out:			none				args unchanged
'
'	Return:		$$FALSE			no errors
'						$$TRUE			error
'
'	Discussion:
'		- ANY must be sent by reference (r1)
'
FUNCTION  XgrSendStringMessage (wingrid, message$, v0, v1, v2, v3, r0, r1)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	XgrMessageNameToNumber (@message$, @message)
	IFZ message THEN RETURN ($$TRUE)
'
	XgrGetMessageType (message, @msgType)
	IFZ msgType THEN
		xgrError = $$XgrBadMessage
		RETURN ($$TRUE)
	END IF
'
	IF (msgType = $$Window) THEN
		window = wingrid
		IF (message = #WindowDestroyed) THEN
			func = v0
		ELSE
			IF InvalidWindow (window) THEN EXIT FUNCTION ($$TRUE)
			func = windowInfo[window].func
		END IF
	ELSE
		IF InvalidGrid (wingrid) THEN EXIT FUNCTION ($$TRUE)
		func = gridInfo[wingrid].func
	END IF
	IF func THEN @func(@wingrid, @message, @v0, @v1, @v2, @v3, @r0, @r1)
END FUNCTION
'
'
' #############################################
' #####  XgrSendStringMessageToWindow ()  #####
' #############################################
'
'	Send string message to window function NOW
'
'	In:				wingrid
'						message$
'						v0, v1, v2, v3
'						r0, r1
'
'	Out:			none				args unchanged
'
'	Return:		$$FALSE			no errors
'						$$TRUE			error
'
'	Discussion:
'		- ANY must be sent by reference (r1)
'
FUNCTION  XgrSendStringMessageToWindow (wingrid, message$, v0, v1, v2, v3, r0, r1)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	FUNCADDR  func (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
'
	XgrMessageNameToNumber (@message$, @message)
	IFZ message THEN RETURN ($$TRUE)
'
	XgrGetMessageType (message, @msgType)
	IFZ msgType THEN
		xgrError = $$XgrBadMessage
		EXIT FUNCTION ($$TRUE)
	END IF
'
	IF (msgType = $$Window) THEN
		window = wingrid
		IF (message = #WindowDestroyed) THEN
			func = v0
		ELSE
			IF InvalidWindow (window) THEN EXIT FUNCTION ($$TRUE)
			func = windowInfo[window].func
		END IF
	ELSE
		IF InvalidGrid (wingrid) THEN EXIT FUNCTION ($$TRUE)
		window	= gridInfo[wingrid].window
		func		= windowInfo[window].func
	END IF
	IF func THEN @func (@wingrid, @message, @v0, @v1, @v2, @v3, @r0, @r1)
END FUNCTION
'
'
' ##########################
' #####  XgrSetCEO ()  #####
' ##########################
'
'	Set CEO function
'
'	In:			func
'
'	Return:		$$FALSE		no error
'						$$TRUE		error
'
'	Discussion:
'		##WHOMASK is used to determine if system or user CEO function
'
FUNCTION  XgrSetCEO (func)
	SHARED  systemCEO,  userCEO

	IF ##WHOMASK THEN
		userCEO = func
	ELSE
		systemCEO = func
	END IF
END FUNCTION
'
'
' ##############################
' #####  XgrGetImage32 ()  #####
' ##############################
'
'	Get image in XBasic standard 32-bit DIB format array
'
'	In:				grid
'	Out:			image[]			DIB format - return empty if error
'
'	DIB BITMAPFILEHEADER		: offset 0x0000 = 0 bytes
'		USHORT	.bfType							'BM' aka BitMap
'		ULONG		.bfSize							size of the file in bytes
'		USHORT	.res1								0
'		USHORT	.res2								0
'		ULONG		.bfOffBits					66 - offset to bitmapData in file
'
'	DIB BITMAPINFO					:  offset 0x000E = 14 bytes
'		DIB BITMAPINFOHEADER	:  offset 0x000E = 14 bytes
'			ULONG		.biSize						Size of BitmapInfoHeader in bytes (40)
'			SLONG		.biWidth					Width of bitmap in pixels
'			SLONG		.biHeight					Height of bitmap in pixels
'			USHORT	.biPlanes					1
'			USHORT	.biBitCount				Color bits per pixel (32)
'			ULONG		.biCompression		Compression scheme (BI_BITFIELDS = 3)
'			ULONG		.biSizeImage			Size of bitmap bits in bytes (0--no compression)
'			SLONG		.biXPelsPerMeter	Horizontal resolution in pixels per meter
'			SLONG		.biYPelsPerMeter	Vertical resolution
'			ULONG		.biClrUsed				Number of colors used in image (0)
'			ULONG		.biClrImportant		Number of important colors in image (0)
'
'		DIB bmiColors					: offset = 54 bytes
'			ULONG		.redBits					0xFFC00000		10 bits
'			ULONG		.greenBits				0x003FF800		11 bits
'			ULONG		.blueBits					0x000007FF		11 bits
'
'		DIB bitmapData				: offset = 66 bytes
'			XLONG		.pixels						32-bits per pixel (10-11-11 = R-G-B)
'
FUNCTION  XgrGetImage32 (grid, UBYTE image[])
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  GT_Image
'
	$BI_RGB       = 0					' 24-bit RGB
	$BI_BITFIELDS = 3					' 32-bit RGB
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	DIM image[]
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	gridType = gridInfo[grid].gridType
	IF (gridType = GT_Image) THEN
		sysImage = gridInfo[grid].sysImage
		IFZ sysImage THEN RETURN ($$FALSE)			' image is empty
		hdc = ntImageInfo.hdcImage
	ELSE
		hdc = windowInfo[window].hdc
	END IF
	width = gridInfo[grid].width
	height = gridInfo[grid].height
'
' figure out how big the array needs to be
'
	dataOffset = 128												' offset to data in file
	row = (width << 2)											' 32-bit aka 4-bytes per pixel
	size = dataOffset + (height * row)
	upper = size - 1
'
	DIM image[upper]
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
	image[info+14] = 32													' USHORT : bits per pixel
	image[info+15] = 0													'
	image[info+16] = $BI_BITFIELDS							' XLONG : 32-bit bitfield RGB
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
' not for standard/default Windows 24-bit RGB format
'
	cbit = info+40															' color bitmasks offset
	rbits = 0xFFC00000													' 10-bits - red
	gbits = 0x003FF800													' 11-bits - green
	bbits = 0x000007FF													' 11-bits - blue
'
	image[cbit+0] = rbits AND 0x00FF
	image[cbit+1] = (rbits >> 8) AND 0x00FF
	image[cbit+2] = (rbits >> 16) AND 0x00FF
	image[cbit+3] = (rbits >> 24) AND 0x00FF
	image[cbit+4] = gbits AND 0x00FF
	image[cbit+5] = (gbits >> 8) AND 0x00FF
	image[cbit+6] = (gbits >> 16) AND 0x00FF
	image[cbit+7] = (gbits >> 24) AND 0x00FF
	image[cbit+8] = bbits AND 0x00FF
	image[cbit+9] = (bbits >> 8) AND 0x00FF
	image[cbit+10] = (bbits >> 16) AND 0x00FF
	image[cbit+11] = (bbits >> 24) AND 0x00FF
'
	dataAddr = iAddr + dataOffset
	infoAddr = iAddr + 14
'
	IF (gridType = GT_Image) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		IF (sysImage = ntImageInfo.hBitmap) THEN			' bitmap not in hdc
			defaultBitmap = ntImageInfo.defaultBitmap
			SelectObject (hdc, defaultBitmap)
			ntImageInfo.hBitmap = defaultBitmap
		END IF
		res = GetDIBits (hdc, sysImage, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	ELSE
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		x = gridInfo[grid].winBox.x1
		y = gridInfo[grid].winBox.y1
		hdcTmp	= CreateCompatibleDC (hdc)
		hBitmap	= CreateCompatibleBitmap (hdc, width, height)
		hBitmapOld = SelectObject (hdcTmp, hBitmap)
		BitBlt (hdcTmp, 0, 0, width, height, hdc, x, y, $$SRCCOPY)
		hBitmap	= SelectObject (hdcTmp, hBitmapOld)	' bitmap not in hdc
		GetDIBits (hdc, hBitmap, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)
		DeleteObject (hBitmapOld)
		DeleteObject (hBitmap)
		DeleteDC (hdcTmp)
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ##################################
' #####  XxxDispatchEvents ()  #####
' ##################################
'
'	Dispatch OS ntEvents;  Queue up any pending system/user ntEvents
'
'	In:				wait						Wait for ANY OS event
'						processSystem		process system messages NOW
'	Out:			none
'	Return:		none
'
'	Discussion:
'		Used by Xit() and Alarm (xlib.s).
'			##WHOMASK = 0 (system) upon entry from either source
'
'		NT: GetQueueStatus() is REQUIRED to process the "dregs" of drawing commands.
'				Who knows why ???
'
'		Not sure who should go in here and who in WinProc()
'			Some serious yuckiness wrt TranslateMessage() and
'			DispatchMessageA()--the latter does more than send
'			the message to WinProc() (eg PAINT construction, etc).
'
'		To use TranslateMessage->DispatchMessage ONLY in this routine
'		would lose xytime for KEY messages and time for MOUSE messages.
'
'		TYPE MSG
'			XLONG		.hwnd
'			XLONG		.message
'			XLONG		.wParam
'			XLONG		.lParam
'			XLONG		.time
'			XLONG		.x
'			XLONG		.y
'		END TYPE
'
FUNCTION  XxxDispatchEvents (wait, processSystem)
	SHARED  XGR_MESSAGE  lastMouseMessage
	SHARED  xgrInitialized
	SHARED  terminateXgr
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  hostWin[]
	SHARED  winGrid[]
	SHARED	modalWindowUser
	SHARED	modalWindowSystem
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  systemMessageQueueOut,  systemMessageQueueIn
	SHARED  noMessagesTillSystemQueueEmptied
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  userMessageQueueOut,  userMessageQueueIn
	SHARED  noMessagesTillUserQueueEmptied
	STATIC  SUBADDR  NTmessageType[]
	STATIC  MSG  msg,  charMsg
	STATIC  RECT  rect
	STATIC  enter
	STATIC  flush
	AUTO   i, j, k, index, window, wingrid
'
'	*****  Virtual keys  *****
'
	IFZ hostDisplay[] THEN RETURN							' no displays up yet
'
	entryALARMBUSY	= ##ALARMBUSY							' prevent ALARM reentry
	entryWHOMASK		= ##WHOMASK
	##WHOMASK				= 0
	##ALARMBUSY			= $$TRUE
'
	IFZ NTmessageType[] THEN GOSUB InitArrays
'
	host = 1											' only one NT host for now
'
'	IFZ enter THEN
'		flush = $$TRUE
'		XstGetOSName (@osName$)
'		XstGetOSVersionName$ (@version$)
'		IF (osName$ = "Windows") THEN
'			version# = DOUBLE (version$)
'			IF (version# < 3.50#) THEN flush = $$FALSE
'		END IF
'	END IF
'
'	IF flush THEN
'		IF (enter > 3) THEN
'			okay = GdiFlush ()					' flush draw commands
'			IFZ okay THEN
'				syserr = GetLastError ()
'				XstSystemErrorToError (syserr, @error)
'				XstErrorNumberToName (error, @error$)
'				XstSystemErrorNumberToName (syserr, @syserr$)
'				XstLog ("[" + STRING$(syserr) + " : " + syserr$ + " = " + STRING$(error) + " : " + error$ + "]")
'			END IF
'		END IF
'	END IF
'
	INC enter
	noMessage = $$TRUE
	IF (enter > 255) THEN enter = 128
'
' *****  IMPORTANT:  Windows 3.1 Bug Notice  *****
'
' The following IF block cannot be replaced by either of the following:
'
' IF (wait AND noMessage) THEN
'   GetQueueStatus ($$QS_ALLEVENTS)
'   WaitMessage()
'   noMessage = $$FALSE
' END IF
'
'  ... or ...
'
' IF (wait AND noMessage) THEN
'   DO
'     Sleep (20)
'     pending = GetQueueStatus ($$QS_ALLEVENTS)
'   LOOP UNTIL pending
'   noMessage = $$FALSE
' END IF
'
' If either of the above replaces the IF block below, XBasic works okay
' on WindowsNT, but Windows 3.1 locks up under certain circumstances.
' Specifically, if the XBasic main window (or any XBasic window) is the
' selected window and the mouse is outside all XBasic windows, then a
' keystoke is performed (press escape to move text cursor to upper text),
' everything everywhere, including the program manager and other tasks
' are locked out.  The only thing that unlocks the system is a keystroke.
'
' The following works okay on both Windows 3.1 and WindowsNT.
'
'	IF (wait AND noMessage) THEN											' wait for first message
'		DO
'			Sleep (0)																								' sleep rest of time-slice
'			pending = PeekMessageA (&msg, 0, 0, 0, $$PM_NOREMOVE)		' some are internal
'		LOOP UNTIL pending
'		noMessage = $$FALSE
'	END IF
'
'
'
	waitForMessage = wait
	DO
'		IF (wait AND noMessage) THEN											' wait for first message
'			DO
'				Sleep (0)
'				pending = PeekMessageA (&msg, 0, 0, 0, $$PM_NOREMOVE)			' some are internal
'			LOOP UNTIL pending
'			noMessage = $$FALSE
'		END IF
'
'		pending = GetQueueStatus ($$QS_ALLEVENTS)							' dump dregs/FAST test
'		IFZ pending THEN EXIT DO
'
		IF waitForMessage THEN
			' If wait == $$TRUE wait *only* for the first messages but handle
			' remaining messages too (if any).
			GetMessageA(&msg, 0, 0, 0)
			waitForMessage = $$FALSE
		ELSE
			pending = PeekMessageA (&msg, 0, 0, 0, $$PM_REMOVE)		' some are internal
			IFZ pending THEN EXIT DO
		END IF
'
'		Shouldn't need TranslateMessage() for EVERY message, but enough
'			wacky things are going on to make it necessary.
'		Who knows what TranslateMessage() REALLY does ???
'
		translate = TranslateMessage (&msg)		' non-obvious return value MarchNT
'
		hwnd = msg.hwnd
		NTmessage = msg.message
'
'		PRINT "win32 : "; HEX$(NTmessage,8), HEX$(hwnd,8),
'
'		XstLog ("XxxDispatchEvents().win : hwnd, NTmessage = " + STRING$(hwnd) + " " + STRING$(NTmessage))
		IF (NTmessage = $$WM_QUIT) THEN XxxXgrQuit ()
		IF (NTmessage <= $$WM_LASTMESSAGE) THEN
			IF NTmessageType[NTmessage] THEN
				IF hostWin[] THEN
					IF hostWin[host,] THEN
						uHostWin = UBOUND(hostWin[host,])
'
'						See if it belongs to Xgr
'
						FOR j = 0 TO uHostWin
							window = hostWin[host,j]
							IFZ window THEN DO NEXT
							IF (hwnd != windowInfo[window].hwnd) THEN DO NEXT
'							XstLog ("XxxDispatchEvents().app : hwnd, NTmessage = " + STRING$(hwnd) + " " + STRING$(NTmessage))
							GOSUB @NTmessageType[NTmessage]
							DO DO
						NEXT j
					END IF
				END IF
			END IF
		END IF
'
'		XstLog ("XxxDispatchEvents().xxx : hwnd, NTmessage = " + STRING$(hwnd) + " " + STRING$(NTmessage))
		DispatchMessageA (&msg)			' Dispatch messages not handled
	LOOP
'
'	IF (systemMessageQueueOut = systemMessageQueueIn) THEN
'		IF lastMouseMessage.msg.hwnd THEN									' pending mouse event
'			IFZ windowInfo[lastMouseMessage.window].whomask THEN CheckMice()
'		END IF
'	END IF
'
	IF processSystem THEN
		IF (systemMessageQueueOut != systemMessageQueueIn) THEN
			XgrProcessMessages (-1)													' process system messages
		END IF
	END IF
'
	##WHOMASK = entryWHOMASK
	##ALARMBUSY = entryALARMBUSY
	RETURN ($$FALSE)
'
'
'	*****  WindowClose  *****
'
SUB WindowClose
'	PRINT "DispatchEvents() : WindowClose : queue #WindowClose : "; window
	message = #WindowClose
	wingrid = window
	v0 = 0
	v1 = 0
	v2 = 0
	v3 = 0
	GOSUB AddMessageToQueue
END SUB
'
'
'	*****  WindowMaximize  *****
'
SUB WindowMaximize
'	PRINT "DispatchEvents() : WindowMaximize : queue #WindowMaximize : "; window
	message = #WindowMaximize
	wingrid = window
	v0 = 0
	v1 = 0
	v2 = 0
	v3 = 0
	GOSUB AddMessageToQueue
END SUB
'
'
'	*****  WindowMinimize  *****
'
SUB WindowMinimize
'	PRINT "DispatchEvents() : WindowMinimize : queue #WindowMinimize : "; window
	message = #WindowMinimize
	wingrid = window
	v0 = 0
	v1 = 0
	v2 = 0
	v3 = 0
	GOSUB AddMessageToQueue
END SUB
'
'
'	*****  WindowDestroyed  *****
'
SUB WindowDestroyed
'	PRINT "DispatchEvents() : WindowDestroyed : call DestroyWindow() and queue #WindowDestroyed : "; window
	message = #WindowDestroyed								'
	v0 = windowInfo[window].func							' note window function
	windowInfo[window].host = 0								' window is available
	windowInfo[window].func = 0								'
'
	uHostWin = UBOUND(hostWin[host,])
	FOR j = 0 TO uHostWin
		IF (window = hostWin[host,j]) THEN			' remove window from hostWin[]
			hostWin[host,j] = 0
		END IF
	NEXT j
'
	IF winGrid[window,] THEN
		uWinGrid = UBOUND(winGrid[window,])
		FOR j = 0 TO uWinGrid
			grid = winGrid[window,j]
			IFZ grid THEN DO NEXT
			gridInfo[grid].grid = 0								' grid
		NEXT j
		ATTACH winGrid[window,] TO temp[]				' waste winGrid[window,]
		DIM temp[]
	END IF
	DestroyWindow (hwnd)
	wingrid = window
	v1 = 0
	v2 = 0
	v3 = 0
	GOSUB AddMessageToQueue
END SUB
'
'
'	*****  KeyMessage  *****  Key messages go to window function
'
'	From:  Mike Markley [MS] 72420,3517  4/23/93
'	There is a difference between the way TranslateMessage() works between
'	the March and the October SDKs.   The change was made in order to make
' the behavior for TranslateMessage() in Win32 work more like the behavior
' in Windows 3.1.
'
' TranslateMessage() calls PostMessage() if there has been some form
' of translation of the keystroke contained within the message.
' PostMessage() does not perform any message reordering so there is a
' potential for there to be different messages in the queue ahead of
' the message generated by TranslateMessage() i.e. messages for child
' windows etc.
'
' TranslateMessage() may post WM_CHAR, WM_DEADCHAR, WM_SYSCHAR or WM_SYSDEADCHAR.
' All of these messages will result in a return value of TRUE from TranslateMessage().
' There are also several other ways for TranslateMessage() to result in
' a return value of TRUE.
'
SUB KeyMessage
'	IF winGrid[window,] THEN								' window has grids
'		uWinGrid = UBOUND(winGrid[window,])		'
'		FOR j = 0 TO uWinGrid
'			grid = winGrid[window,j]						' valid grid number?
'			IF grid THEN EXIT FOR								' yes, have a grid in window
'		NEXT j
'	END IF
'
'	xDisp = msg.x
'	yDisp = msg.y
'	XgrConvertDisplayToWindow (grid, xDisp, yDisp, @xWin, @yWin)
'	v0 = xWin
'	v1 = yWin
'
	v0 = msg.x				' v0 = x in display coordinates
	v1 = msg.y				' v1 = y in display coordinates
	v2 = $$FALSE			' state
	v3 = msg.time			' time
'
	flags = msg.lParam
	virtualKey = msg.wParam
'
'	GetKeyState() bit 0 = toggle state; bit 15 = current state
'
	shift	= (GetKeyState($$VK_SHIFT) AND 0x00008000) << 1
	ctrl = (GetKeyState($$VK_CONTROL) AND 0x00008000) << 2
	alt = (flags AND 0x20000000) >> 11
	ralt = (GetKeyState($$VK_RMENU) AND 0x00008000) << 4
	rshift = (GetKeyState($$VK_RSHIFT) AND 0x00008000) << 7
	rctrl = (GetKeyState($$VK_RCONTROL) AND 0x00008000) << 8
'
'	Key State:		Bits
'								24-31		virtualKey		virtual-key
'								23		  rightControl	right control key down
'								22-23		rightShift    right shift key down
'								20-21		contents			bit 0-15 contents:
'																					0 = virtual
'																					1 = ascii
'																					2 = unicode
'								19			rightAlt			right alt key down
'								18			KeyAlt				1 = down
'								17			KeyControl			"
'								16			KeyShift				"
'								0-15		key						virtual/ascii/unicode
'
	state = (virtualKey << 24) OR rctrl OR rshift OR ralt OR alt OR ctrl OR shift
	v2 = state OR virtualKey
	message = #WindowKeyUp
	SELECT CASE NTmessage
		CASE $$WM_KEYDOWN,  $$WM_SYSKEYDOWN
					message = #WindowKeyDown
					IF PeekMessageA (&charMsg, hwnd, $$WM_CHAR, $$WM_CHAR, $$PM_REMOVE) THEN
						key = charMsg.wParam AND 0x000000FF
						v2 = state OR 0x00100000 OR key
					END IF
	END SELECT
'
'	Post message to window
'
	wingrid = window
	GOSUB AddMessageToQueue
END SUB
'
'
'	*****  ShowWindow  *****  Hide, Display, Minimize, Maximize
'
SUB ShowWindow
'	PRINT "DispatchEvents() : $$WM_SHOWWINDOW : call ShowWindow(SHOWNORMAL) : "; hwnd; HEX$(wParam,8);; HEX$(lParam,8);;; window; "  queue ";
	IF msg.wParam THEN
		ShowWindow (hwnd, $$SW_SHOWNORMAL)
		SELECT CASE TRUE
			CASE IsIconic (hwnd)	:	v0 = $$WindowMinimized
															message = #WindowMinimized
'															PRINT "#WindowMinimized"
			CASE IsZoomed (hwnd)	: v0 = $$WindowMaximized
															message = #WindowMaximized
'															PRINT "#WindowMaximized"
			CASE ELSE							: v0 = $$WindowDisplayed
															message = #WindowDisplayed
'															PRINT "#WindowDisplayed"
		END SELECT
	ELSE
		v0 = $$WindowHidden
		message = #WindowHidden
'		PRINT "#WindowHidden"
	END IF
	windowInfo[window].visible = v0
	wingrid = window
	v1 = 0
	v2 = 0
	v3 = 0
	GOSUB AddMessageToQueue
END SUB
'
'
'	*****  Mouse  *****
'
SUB Mouse
	lastMouseMessage.window	= window
	lastMouseMessage.msg = msg
	MouseMessage ()
END SUB
'
'
'	*****  MouseMove  *****
'
SUB MouseMove
'	XstLog ("XxxDispatchEvents() : MouseMoveNC : " + STRING$(window))
	lastMouseMessage.window	= window
	lastMouseMessage.msg = msg
	MouseMessage ()
END SUB
'
'
'	*****  MouseActivate  *****
'
SUB MouseActivate
	DispatchMessageA (&msg)					' add 02/02/94 - try to cure lockup
'	PRINT "XXX MouseActivate "; window
END SUB
'
'
'	*****  MouseMoveNC  *****
'
SUB MouseMoveNC
'	XstLog ("XxxDispatchEvents() : MouseMoveNC : " + STRING$(window))
	lastMouseMessage.window = window
	lastMouseMessage.msg = msg
	DispatchMessageA (&msg)
'
'	Non-Client wParam isn't "flags":  kludge one up
'
	flags = 0
	IF GetAsyncKeyState($$VK_SHIFT)		THEN flags = flags OR 0x0004
	IF GetAsyncKeyState($$VK_CONTROL)	THEN flags = flags OR 0x0008
	IF GetAsyncKeyState($$VK_LBUTTON)	THEN flags = flags OR 0x0001
	IF GetAsyncKeyState($$VK_MBUTTON)	THEN flags = flags OR 0x0010
	IF GetAsyncKeyState($$VK_RBUTTON)	THEN flags = flags OR 0x0002
	lastMouseMessage.msg.wParam = flags
'
'	Force this message into the queue
'	Since OS gobbles up messages, we miss corresponding mouse up, etc...
'	This is typically only a NCxButtonDown message.
'
' The following MouseMessage() call is required because otherwise
' MouseExit is missed when cursor exits grid AND window client area.
'
	MouseMessage ()
END SUB
'
'
'	*****  MouseNC  *****
'
SUB MouseNC
	lastMouseMessage.window = window
	lastMouseMessage.msg = msg
	DispatchMessageA (&msg)
'
'	Non-Client wParam isn't "flags":  kludge one up
'
	flags = 0
	IF GetAsyncKeyState($$VK_SHIFT)		THEN flags = flags OR 0x0004
	IF GetAsyncKeyState($$VK_CONTROL)	THEN flags = flags OR 0x0008
	IF GetAsyncKeyState($$VK_LBUTTON)	THEN flags = flags OR 0x0001
	IF GetAsyncKeyState($$VK_MBUTTON)	THEN flags = flags OR 0x0010
	IF GetAsyncKeyState($$VK_RBUTTON)	THEN flags = flags OR 0x0002
	lastMouseMessage.msg.wParam = flags
'
'	Force this message into the queue
'	Since OS gobbles up messages, we miss corresponding mouse up, etc...
'	This is typically only a NCxButtonDown message.
'
'	CheckMice ()
	MouseMessage ()
END SUB
'
'
'	*****  SysCommand  *****
'
'	$$SC_SIZE								= 0xF000
'	$$SC_MOVE								= 0xF010
'	$$SC_MINIMIZE						= 0xF020
'	$$SC_MAXIMIZE						= 0xF030
'	$$SC_NEXTWINDOW					= 0xF040
'	$$SC_PREVWINDOW					= 0xF050
'	$$SC_CLOSE							= 0xF060
'	$$SC_VSCROLL						= 0xF070
'	$$SC_HSCROLL						= 0xF080
'	$$SC_MOUSEMENU					= 0xF090
'	$$SC_KEYMENU						= 0xF100
'	$$SC_ARRANGE						= 0xF110
'	$$SC_RESTORE						= 0xF120
'	$$SC_TASKLIST						= 0xF130
'	$$SC_SCREENSAVE					= 0xF140
'	$$SC_HOTKEY							= 0xF150
'
SUB SysCommand
	sysCommand = msg.wParam AND 0xFFFFFFF0
'	PRINT "XxxDispatchEvents(): System Command:  "; HEX$(sysCommand,8)
	SELECT CASE sysCommand
		CASE $$SC_CLOSE
'					PRINT "XxxDispatchEvents() : SysCommand : $$SC_CLOSE : "; window, modalWindowSystem, modalWindowUser
'					GOSUB WindowClose
'					EXIT SUB
		CASE $$SC_MAXIMIZE
'					PRINT "XxxDispatchEvents() : SysCommand : $$SC_MAXIMIZE : "; window, modalWindowSystem, modalWindowUser
'					GOSUB WindowMaximize
'					EXIT SUB
		CASE $$SC_MINIMIZE
'					PRINT "XxxDispatchEvents() : SysCommand : $$SC_MINIMIZE : "; window, modalWindowSystem, modalWindowUser
					IF (window = modalWindowSystem) THEN XgrSetModalWindow (0) : EXIT SUB
					IF (window = modalWindowUser) THEN XgrSetModalWindow (0) : EXIT SUB
'					GOSUB WindowMinimize
'					EXIT SUB
		CASE $$SC_MOVE
'					PRINT "XxxDispatchEvents(): SysCommand: $$SC_MOVE", window, modalWindowSystem, modalWindowUser
		CASE $$SC_SIZE
'					PRINT "XxxDispatchEvents(): SysCommand: $$SC_SIZE", window, modalWindowSystem, modalWindowUser
		CASE $$SC_NEXTWINDOW, $$SC_PREVWINDOW
					IF (window = modalWindowSystem) THEN EXIT SUB
					IF (window = modalWindowUser) THEN EXIT SUB
	END SELECT
	DispatchMessageA (&msg)
END SUB
'
'
' *****  Timer  *****  Register grid timeout event.
'
SUB Timer
'	PRINT " Timer";
	grid = msg.wParam
	IF InvalidGrid (grid) THEN EXIT SUB						' grid is deceased
'
	timeOutID = gridInfo[grid].timeOutID
	IF timeOutID THEN KillTimer (hwnd, grid)
	gridInfo[grid].timeOutID = 0
'
	wingrid = grid
	message = #TimeOut
	v0 = 0
	v1 = 0
	v2 = 0
	v3 = 0
	GOSUB AddMessageToQueue
END SUB
'
'
'	*****  AddMessageToQueue  *****
'
'	userMessageQueue[] is a 1D array containing the user messages
'		It has a max size (1024).
'		Messages go in at userMessageQueueIn.
'		Messages come out at userMessageQueueOut.
'		If the queue fills, wait till it is emptied completely before allowing
'			more messages to come in.  (This prevents choppy behavior that occurs
'			if messages pop in as the gap widens, halts till there is another gap.)
'
'	similar for systemMessageQueue[]
'
SUB AddMessageToQueue
	IFZ windowInfo[window].whomask THEN				' system queue
		IF noMessagesTillSystemQueueEmptied THEN
			IF (systemMessageQueueOut != systemMessageQueueIn) THEN EXIT SUB
			noMessagesTillSystemQueueEmptied = $$FALSE
		END IF
'
'		If next systemMessageQueueIn = current systemMessageQueueOut:  queue is full
'
		nextMessageQueueIn = systemMessageQueueIn + 1
		IF (nextMessageQueueIn > UBOUND(systemMessageQueue[])) THEN
			nextMessageQueueIn = 0
		END IF
'
		IF (nextMessageQueueIn = systemMessageQueueOut) THEN
			noMessagesTillSystemQueueEmptied = $$TRUE				' queue full
			PRINT "Dispatch : System Message Queue full!!!"
			EXIT SUB
		END IF
'
		systemMessageQueue[systemMessageQueueIn].message	= message
		systemMessageQueue[systemMessageQueueIn].wingrid	= wingrid
		systemMessageQueue[systemMessageQueueIn].v0				= v0
		systemMessageQueue[systemMessageQueueIn].v1				= v1
		systemMessageQueue[systemMessageQueueIn].v2				= v2
		systemMessageQueue[systemMessageQueueIn].v3				= v3
		systemMessageQueue[systemMessageQueueIn].r0				= 0
		systemMessageQueue[systemMessageQueueIn].r1				= wingrid
		systemMessageQueueIn = nextMessageQueueIn
	ELSE																							' user queue
		IF noMessagesTillUserQueueEmptied THEN
			IF (userMessageQueueOut != userMessageQueueIn) THEN EXIT SUB
			noMessagesTillUserQueueEmptied = $$FALSE
		END IF
'
'		If next userMessageQueueIn = current userMessageQueueOut:  queue is now full
'
		nextMessageQueueIn = userMessageQueueIn + 1
		IF (nextMessageQueueIn > UBOUND(userMessageQueue[])) THEN
			nextMessageQueueIn = 0
		END IF
'
		IF (nextMessageQueueIn = userMessageQueueOut) THEN
			noMessagesTillUserQueueEmptied = $$TRUE				' queue full
			PRINT "Dispatch : User Message Queue full!!!"
			EXIT SUB
		END IF
'
		userMessageQueue[userMessageQueueIn].message	= message
		userMessageQueue[userMessageQueueIn].wingrid	= wingrid
		userMessageQueue[userMessageQueueIn].v0				= v0
		userMessageQueue[userMessageQueueIn].v1				= v1
		userMessageQueue[userMessageQueueIn].v2				= v2
		userMessageQueue[userMessageQueueIn].v3				= v3
		userMessageQueue[userMessageQueueIn].r0				= 0
		userMessageQueue[userMessageQueueIn].r1				= wingrid
		userMessageQueueIn = nextMessageQueueIn
	END IF
END SUB
'
'
'	*****  Init Arrays  *****
'
SUB InitArrays
	DIM NTmessageType[$$WM_LASTMESSAGE]
	NTmessageType[ $$WM_DESTROY						]	= SUBADDRESS (WindowDestroyed)
	NTmessageType[ $$WM_KEYDOWN						]	= SUBADDRESS (KeyMessage)
	NTmessageType[ $$WM_KEYUP							]	= SUBADDRESS (KeyMessage)
	NTmessageType[ $$WM_SYSKEYDOWN				]	= SUBADDRESS (KeyMessage)
	NTmessageType[ $$WM_SYSKEYUP					]	= SUBADDRESS (KeyMessage)
	NTmessageType[ $$WM_MOUSEACTIVATE			] = SUBADDRESS (MouseActivate)
	NTmessageType[ $$WM_MOUSEMOVE					]	= SUBADDRESS (MouseMove)
	NTmessageType[ $$WM_LBUTTONDOWN				]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_LBUTTONUP					]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_LBUTTONDBLCLK			]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_RBUTTONDOWN				]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_RBUTTONUP					]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_RBUTTONDBLCLK			]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_MBUTTONDOWN				]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_MBUTTONUP					]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_MBUTTONDBLCLK			]	= SUBADDRESS (Mouse)
	NTmessageType[ $$WM_NCMOUSEMOVE				]	= SUBADDRESS (MouseMoveNC)
	NTmessageType[ $$WM_NCLBUTTONDOWN			]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCLBUTTONUP				]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCLBUTTONDBLCLK		]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCRBUTTONDOWN			]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCRBUTTONUP				]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCRBUTTONDBLCLK		]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCMBUTTONDOWN			]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCMBUTTONUP				]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCMBUTTONDBLCLK		]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_SHOWWINDOW				]	= SUBADDRESS (ShowWindow)
	NTmessageType[ $$WM_SYSCOMMAND				]	= SUBADDRESS (SysCommand)
	NTmessageType[ $$WM_TIMER							]	= SUBADDRESS (Timer)
END SUB
END FUNCTION
'
'
' ###############################
' #####  XxxXgrBlowback ()  #####
' ###############################
'
FUNCTION  XxxXgrBlowback ()
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  hostWin[]
	SHARED  userMessageQueueOut,  userMessageQueueIn
	SHARED  xgrInitialized
'
	IFF xgrInitialized THEN RETURN
	IFZ hostWin[] THEN RETURN													' no windows open
'
	entryALARMBUSY = ##ALARMBUSY											'	no new messages here
	##ALARMBUSY	= $$TRUE
'
	uHost = UBOUND(hostWin[])
	FOR host = 1 TO uHost
		hostDisplay[host].grabMouseFocusGrid	= 0
		IFZ hostWin[host,] THEN DO NEXT									' no windows for this host
		uHostWin = UBOUND(hostWin[host,])
		FOR i = 0 TO uHostWin
			window = hostWin[host,i]
			IFZ window THEN DO NEXT												' empty slot
			IFZ windowInfo[window].host THEN DO NEXT			' child already destroyed
			IFZ windowInfo[window].whomask THEN DO NEXT		' not a USER window
			XgrDestroyWindow (window)											' destroy window
			IFZ hostWin[host,] THEN EXIT FOR							' no windows left
		NEXT i
	NEXT host
'
'	waste user message Queue
'
	userMessageQueueOut = userMessageQueueIn
	##ALARMBUSY	= entryALARMBUSY
END FUNCTION
'
'
' ##################################
' #####  XxxXgrReleaseMice ()  #####
' ##################################
'
FUNCTION  XxxXgrReleaseMice ()
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  hostWin[]
	SHARED  xgrInitialized
'
	$CurrentTime = 0
'
	IFF xgrInitialized THEN RETURN
	IFZ hostDisplay[] THEN RETURN											' No displays open
	IFZ hostWin[] THEN RETURN													' No windows open
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	FOR host = 1 TO UBOUND(hostDisplay[])
		IFZ hostDisplay[host].status THEN DO NEXT
		hostDisplay[host].grabMouseFocusGrid = 0				' lost dibs
		##LOCKOUT = $$TRUE
'		XUngrabPointer (display, $CurrentTime)
		##LOCKOUT = entryLOCKOUT
	NEXT host
'
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ####################################
' #####  XxxXgrSetHelpWindow ()  #####
' ####################################
'
FUNCTION  XxxXgrSetHelpWindow (window)
	SHARED	helpWindow
'
	helpWindow = window
END FUNCTION
'
'
' ###########################
' #####  XxxXgrQuit ()  #####
' ###########################
'
'	Prep Xgr for Quit
'
'	In:				none
'	Out:			none
'	Return:		none
'
'	Discussion:
'	*	Delete hdc pens, brushes, fonts
'		Clip regions are deleted immediately upon selecting them into the hdc
'			(a copy is made)
'		Release hdc
'
'	*	Delete hdcImage pens, brushes, fonts, bitmaps, hdc
'			(See DestroySysImage())
'
'	*	Delete all cursors, fonts, icons
'
'	*	defaultBitmap:
'			CreateCompatibleDC() creates a default monochrome 1x1 bitmap.
'				We select that out in favor of a WxH bitmap compatible with the
'				screen.  All the 1x1 bitmaps are deleted except for the first:
'				since all of XBasic's images are on the same screen, keep the first
'				instance to be used during destruction of the image.
'			The defaultBitmap is selected into each hdcImage and the WxH image
'				popped out is deleted.  The bitmap in hdcImage is not destroyed upon
'				a DeleteDC() call.  When all hdcImages are destroyed, delete the
'				defaultBitmap.  See XxxXgrQuit() and DestroySysImage().
'
FUNCTION  XxxXgrQuit ()
	SHARED  DISPLAYINFO hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  FONTINFO  fontInfo[]
	SHARED  sysFontNames$[]
	SHARED  cursorHandle[]
	SHARED  iconHandle[]
	SHARED  hostWin[]

	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
'	Destroy windows and their hdc's
'
	IF hostDisplay[] THEN
		FOR host = 1 TO UBOUND(hostDisplay[])
			IF hostWin[host,] THEN
				uHostWin = UBOUND(hostWin[host,])
				FOR i = 0 TO uHostWin
					window = hostWin[host,i]
					IFZ window THEN DO NEXT											' empty slot
					hdc		= windowInfo[window].hdc
					hwnd	= windowInfo[window].hwnd
'
					##LOCKOUT = $$TRUE
					hPen = SelectObject (hdc, GetStockObject($$BLACK_PEN))
					hBrush = SelectObject (hdc, GetStockObject($$BLACK_BRUSH))
					hFont = SelectObject (hdc, GetStockObject($$OEM_FIXED_FONT))
					DeleteObject (hPen)
					DeleteObject (hBrush)
					DeleteObject (hFont)
					SelectClipRgn (hdc, 0)											' NULL clip region
					ReleaseDC (hwnd, hdc)
					DestroyWindow (hwnd)
					##LOCKOUT = entryLOCKOUT
					windowInfo[window].host = 0									' window is now available
					windowInfo[window].func = 0
					hostWin[host,i] = 0
				NEXT i
			END IF
		NEXT host
	END IF
'
'	Destroy image hdc
'
	hdcImage = ntImageInfo.hdcImage
	IF hdcImage THEN
		##LOCKOUT = $$TRUE
		hPen = SelectObject (hdcImage, GetStockObject($$BLACK_PEN))
		hBrush = SelectObject (hdcImage, GetStockObject($$BLACK_BRUSH))
		hFont = SelectObject (hdcImage, GetStockObject($$OEM_FIXED_FONT))
		DeleteObject (hPen)
		DeleteObject (hBrush)
		DeleteObject (hFont)
		defaultBitmap = ntImageInfo.defaultBitmap
		hBitmap = SelectObject (hdcImage, defaultBitmap)
		IF (hBitmap != defaultBitmap) THEN DeleteObject (hBitmap)
		SelectClipRgn (hdcImage, 0)								' NULL clip region
		DeleteDC (hdcImage)
		##LOCKOUT = entryLOCKOUT
		ntImageInfo.hdcImage = 0
	END IF
'
'	Destroy all bitmaps
'
	IF gridInfo[] THEN
		FOR grid = 0 TO UBOUND(gridInfo[])
			IFZ gridInfo[grid].grid THEN DO NEXT
			sysImage = gridInfo[grid].sysImage
			IFZ sysImage THEN DO NEXT
			##LOCKOUT = $$TRUE
			DeleteObject (sysImage)
			##LOCKOUT = entryLOCKOUT
			gridInfo[grid].sysImage = 0
		NEXT grid
	END IF
'
'	Cursors:
'		Destroy cursors creates by CreateCursor() ONLY
'			(NOT LoadCursor() cursors)
'		At this time, all cursors are Loaded.
'
'	IF cursorHandle[] THEN
'		Delete CreateCursor() cursors
'	END IF
'
'	Icons:
'		Destroy icons creates by CreateIcon() ONLY
'			(NOT LoadIcon() icons)
'		At this time, all icons are Loaded.
'
'	IF iconHandle[] THEN
'		Delete CreateIcon() icons
'	END IF
'
'	Fonts:
'
	IF fontInfo[] THEN
		FOR font = 0 TO UBOUND (fontInfo[])
			IF fontInfo[font].font THEN
				##LOCKOUT = $$TRUE
				hFont = fontInfo[font].hFont
'				sysFont = fontInfo[font].sysFont
'				fontSize = fontInfo[font].size
'				fontWeight = fontInfo[font].weight
'				fontItalic = fontInfo[font].italic
'				fontAngle = fontInfo[font].angle
'				fontName$ = sysFontNames$[sysFont]
'				message$ = " DeleteObject() : " + STRING$(font) + "." + HEX$(hFont) + "." + RIGHT$("0" + STRING$(sysFont),2) + ":" + RIGHT$("00" + STRING$(fontSize),3) + "," + RIGHT$("00" + STRING$(fontWeight),3) + "," + RIGHT$("00" + STRING$(fontItalic),3) + "," + RIGHT$("00" + STRING$(fontAngle),3) + "." + fontName$
'				XstLog (@message$)
				DeleteObject (hFont)
				##LOCKOUT = entryLOCKOUT
			END IF
		NEXT font
	END IF
'
'	FreeConsole ()			' should be unnecessary now with XuiConsole()
'
	##WHOMASK = entryWHOMASK
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
	IF (biHeight < 0) THEN				' image is upside down - flip y
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
	IF (biHeight < 0) THEN				' image is upside down - flip y
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
' ##########################
' #####  CheckMice ()  #####
' ##########################
'
'	Add mouse message if one is pending in lastMouseMessage
' Grab mouse focus if going from no buttons down to buttons down
' Release mouse focus if going from buttons down to no buttons down
'
FUNCTION  CheckMice ()
	SHARED  xgrError
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  hostWin[]
	SHARED  cursorHandle[],  currentCursor,  overrideCursor
	SHARED  MESSAGE  lastQueuedMouseMessage
	SHARED  XGR_MESSAGE  lastMouseMessage
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  systemMessageQueueOut,  systemMessageQueueIn
	SHARED  noMessagesTillSystemQueueEmptied
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  userMessageQueueOut,  userMessageQueueIn
	SHARED  noMessagesTillUserQueueEmptied
	SHARED  xgrInitialized
	STATIC  POINT  point
'
'	XstLog ("CheckMice().a")
	IFF xgrInitialized THEN EXIT FUNCTION
	IFZ hostDisplay[] THEN EXIT FUNCTION						' no hosts open
'
	host = 1
	IFZ hostDisplay[host].status THEN RETURN				' host is dead
	IFZ hostWin[host,] THEN RETURN									' no windows for this host
'
	entryLOCKOUT = ##LOCKOUT
	entryALARMBUSY = ##ALARMBUSY
	##ALARMBUSY = $$TRUE
'
'	new mouse event received after last one queued ???
'
	hwnd = lastMouseMessage.msg.hwnd			' hwnd = 0 after message queued
	IFZ hwnd THEN GOTO done								' message already queued
'	XstLog ("CheckMice().b : " + STRING$(hwnd))
	lastMouseMessage.msg.hwnd = 0					' say queued
'
	window = lastMouseMessage.window
	message = lastMouseMessage.msg.message
	flags = lastMouseMessage.msg.wParam
	xy = lastMouseMessage.msg.lParam
	time = lastMouseMessage.msg.time
'
'	XstLog ("CheckMice().c : " + STRING$(window))
'	XstLog ("CheckMice().d : " + STRING$(message))
'	XstLog ("CheckMice().e : " + STRING$(flags))
'	XstLog ("CheckMice().f : " + STRING$(xy{16,0}))
'	XstLog ("CheckMice().g : " + STRING$(xy{16,16}))
'
	lButton = (flags AND 0x0001) << 24
	mButton = (flags AND 0x0010) << 21
	rButton = (flags AND 0x0002) << 25
	shift = (flags AND 0x0004) << 14
	ctrl = (flags AND 0x0008) << 14
	alt = 0
	IF GetKeyState($$VK_MENU) THEN alt = 0x00040000
	state = rButton OR mButton OR lButton OR alt OR ctrl OR shift
'
	clientMessage = $$TRUE
	IF ((message >= $$WM_NCMOUSEMOVE) AND (message <= $$WM_NCMBUTTONDBLCLK)) THEN
		clientMessage = $$FALSE
	END IF
'
'	Get xy in Window and Display coords and mouse state
'
	IF clientMessage THEN
		xWin = xy{{16,0}}						' client xy relative to client
		yWin = xy{{16,16}}
		point.x	= xWin
		point.y	= yWin
		ClientToScreen (hwnd, &point)
		xDisp	= point.x
		yDisp	= point.y
	ELSE
		xDisp = xy{{16,0}}						' non-Client xy relative to screen
		yDisp = xy{{16,16}}
		point.x	= xDisp
		point.y	= yDisp
		ScreenToClient (hwnd, &point)
		xWin = point.x
		yWin = point.y
	END IF
'	XstLog ("CheckMice().h : " + STRING$(clientMessage) + " " + STRING$(xWin) + " " + STRING$(yWin) + " " + STRING$(xDisp) + " " + STRING$(yDisp))
'
'	Mouse State:	Bits
'								24-31		btn state		buttons 1-8 (24-31);  1 = down
'								19-23		0						unused/reserved for key state use
'								18			KeyAlt			1 = down
'								17			KeyControl		"
'								16			KeyShift			"
'								8-15		0						unused/reserved
'								7				focus				1 = grid has mouse focus
'								4-6			0						clicks 1-4 (button down only)
'								0-3			button			0-8 button number (0 for mouse motion)
'
' has mouse state/position changed?
'
	oldHwnd = hostDisplay[host].mouseWindowHwnd
	oldWindow = hostDisplay[host].mouseWindow
	oldState = hostDisplay[host].mouseState
	oldXDisp = hostDisplay[host].mouseXDisp
	oldYDisp = hostDisplay[host].mouseYDisp
'
	IF (hwnd = oldHwnd) THEN
		IF ((state AND 0xFF000000) = (oldState AND 0xFF000000)) THEN
			IF (xDisp = oldXDisp) THEN
				IF (yDisp = oldYDisp) THEN GOTO done
			END IF
		END IF
	END IF
'
	newState = state
	grabMouseFocusGrid = hostDisplay[host].grabMouseFocusGrid
'
' grab mouse focus when going from no buttons down to buttons down
'
	grab = $$FALSE
	IFZ grabMouseFocusGrid THEN
		IFZ (oldState AND 0xFF000000) THEN
			IF (newState AND 0xFF000000) THEN
				IF clientMessage THEN
					grid = ClosestGrid (window, xWin, yWin)
					IF (grid > 0) THEN
						hostDisplay[host].grabMouseFocusGrid = grid
						hostDisplay[host].gridMouseInside = grid
						##LOCKOUT = $$TRUE
						SetCapture (hwnd)
						##LOCKOUT = entryLOCKOUT
						grab = $$TRUE
					END IF
				END IF
			END IF
		END IF
	END IF
'
'
'	Enter/Exit Messages
'
'	if mouse was already grabbed, check for Enter/Exit of grab grid.
'
	SELECT CASE TRUE
		CASE grabMouseFocusGrid
			IF gridInfo[grabMouseFocusGrid].disabled THEN
				IF clientMessage THEN
					grid = ClosestGrid (window, xWin, yWin)
					IF (grid < 0) THEN grid = 0
				END IF
				EXIT SELECT
			END IF
'
			grid = grabMouseFocusGrid
			grabWindow = gridInfo[grid].window
			xDispGrab = windowInfo[grabWindow].xDisp
			yDispGrab = windowInfo[grabWindow].yDisp
'
			xULDisp = xDispGrab + gridInfo[grid].winBox.x1
			yULDisp = yDispGrab + gridInfo[grid].winBox.y1
			xLRDisp = xDispGrab + gridInfo[grid].winBox.x2
			yLRDisp = yDispGrab + gridInfo[grid].winBox.y2
'
			inside = $$FALSE
			IF ((xULDisp <= xDisp) AND (xDisp <= xLRDisp)) THEN
				IF ((yULDisp <= yDisp) AND (yDisp <= yLRDisp)) THEN
					inside = grid
				END IF
			END IF
'
			IF (window != grabWindow) THEN
				xWin = (xWin + windowInfo[window].xDisp) - xDispGrab
				yWin = (yWin + windowInfo[window].yDisp) - yDispGrab
			END IF
'
			IF (inside != hostDisplay[host].gridMouseInside) THEN
				IF inside THEN
					message = #WindowMouseEnter
				ELSE
					message = #WindowMouseExit
				END IF
				state = oldState OR 0x80							' grid has mouse focus
				XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
				GOSUB AddMessageToQueue
				hostDisplay[host].gridMouseInside = inside
			END IF
		CASE ELSE
			IF clientMessage THEN
				grid = ClosestGrid (window, xWin, yWin)		' won't find disabled
			ELSE
				grid = 0
			END IF
'
' skip #WindowMouseMove messages unless queue is empty
'
			lastMouseFocusGrid = hostDisplay[host].gridMouseInside
			IF (grid = lastMouseFocusGrid) THEN
				IFZ (state AND 0xFF000000) THEN
					IFZ (oldState AND 0xFF000000) THEN
						IFZ windowInfo[window].whomask THEN				' system queue
							IF (systemMessageQueueOut != systemMessageQueueIn) THEN
								lastMouseMessage.msg.hwnd = hwnd			' say not queued
								GOTO done															' no #MouseMove
							END IF
						ELSE																			' user queue
							IF (userMessageQueueOut != userMessageQueueIn) THEN
								lastMouseMessage.msg.hwnd = hwnd			' say not queued
								GOTO done															' no #MouseMove
							END IF
						END IF
					END IF
				END IF
				EXIT SELECT						' this grid = last grid so no Enter/Exit
			END IF
'
			IF lastMouseFocusGrid THEN
				saveGrid = grid
				grid = lastMouseFocusGrid
				message = #WindowMouseExit
				state = oldState																		' no FOCUS
				XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
				GOSUB AddMessageToQueue
				grid = saveGrid
			END IF
'
			IF grid THEN
				message = #WindowMouseEnter
				state = oldState OR 0x80														' has FOCUS
				XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
				GOSUB AddMessageToQueue
			END IF
'
			hostDisplay[host].gridMouseInside = grid
	END SELECT
'
' message will definitely be posted, so update display variables
'
	hostDisplay[host].mouseWindowHwnd = hwnd
	hostDisplay[host].mouseWindow = window
	hostDisplay[host].mouseState = state
	hostDisplay[host].mouseXDisp = xDisp
	hostDisplay[host].mouseYDisp = yDisp
'
'
'	Motion, drag, down, up, selected, deselected
'
'
	XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
	SELECT CASE ALL TRUE
		CASE (xDisp != oldXDisp), (yDisp != oldYDisp)
			IF clientMessage THEN
				IFZ grid THEN NEXT CASE
			END IF
			IF oldHwnd THEN													' skip "first" move event
				state = oldState OR 0x80							' has FOCUS
				IF (state AND 0xFF000000) THEN
					message = #WindowMouseDrag
				ELSE
					message = #WindowMouseMove
				END IF
				GOSUB AddMessageToQueue
			END IF
		CASE ((newState AND 0xFF000000) != (oldState AND 0xFF00000))	' down/up: new state
			change = newState XOR oldState
			buttonDown = $$FALSE
			mask = 0x00800000
			FOR i = 24 TO 31															' check all buttons
				mask = mask << 1
				IF (change AND mask) THEN
					buttonNumber = i - 23
					IF (newState AND mask) THEN
						buttonDown = $$TRUE
						IF (message = #WindowMouseEnter) THEN
							message = #WindowMouseDrag						' just entered with buttons down
						ELSE
							message = #WindowMouseDown						' didn't just enter this grid
						END IF
'
'						Get button clicks
'
						clicks = 1
						dt&& = ULONG(time) - ULONG(gridInfo[grid].lastClickTime)
						IF ((dt&& > 0) AND (dt&& < 400)) THEN
							clicks = gridInfo[grid].buttonClicks
							INC clicks
							IF (clicks > 4) THEN clicks = 1
						END IF
						gridInfo[grid].lastClickTime	= time
						gridInfo[grid].buttonClicks		= clicks
					ELSE
						message = #WindowMouseUp
						clicks = 0
					END IF
'
					IF clientMessage THEN
						IFZ grid THEN DO NEXT
					END IF
					state = newState OR 0x80 OR (clicks << 4) OR buttonNumber		' focus
					GOSUB AddMessageToQueue
				END IF
			NEXT i
'
' The following section disabled on 11 Feb 94 to fix errant focus shifts
'
'			IF buttonDown THEN
'				IFZ grabMouseFocusGrid THEN
'					selectedWindow = hostDisplay[host].selectedWindow
'					IF (window != selectedWindow) THEN
'						saveGrid = grid
'						state = 0
'						IF selectedWindow THEN
'							grid = selectedWindow									' deselected
'							message = #WindowDeselected
'							GOSUB AddMessageToQueue
'							hostDisplay[host].selectedWindow = 0
'						END IF
'
'						IF window THEN
'							grid = window													' selected
'							message = #WindowSelected
'							GOSUB AddMessageToQueue
'						END IF
'						grid = saveGrid
'						hostDisplay[host].selectedWindow = window
'					END IF
'				END IF
'			END IF
	END SELECT
'
'	if dibs just lost, release mouse, send Enter/Exit messages as required
'
	IFZ (newState AND 0xFF000000) THEN									' no button down
		IF grabMouseFocusGrid THEN
			hostDisplay[host].grabMouseFocusGrid = 0				' lost dibs
			hostDisplay[host].gridMouseInside = 0
'
			##LOCKOUT = $$TRUE
			ReleaseCapture ()
			##LOCKOUT = entryLOCKOUT
'
			IF clientMessage THEN
				grid = ClosestGrid (window, xWin, yWin)				' won't choose disabled
			ELSE
				grid = 0
			END IF
			inside = hostDisplay[host].gridMouseInside
'
			IF (grid = grabMouseFocusGrid) THEN
				IFF inside THEN
					state = newState OR 0x80										' has FOCUS
					message = #WindowMouseEnter									' enter grid
					XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
					GOSUB AddMessageToQueue
				END IF
			ELSE
'				sg = grid: sx = xWin: sy = yWin: ss = state: st = time
'				grid = grabMouseFocusGrid
'				message = #LostMouseFocus
'				xWin = 0: yWin = 0: state = 0: time = 0
'				GOSUB AddMessageToQueue
'				grid = sg: xWin = sx: yWin = sy: state = ss: time = st
'
				IF inside THEN
					IFF gridInfo[grabMouseFocusGrid].disabled THEN
						saveGrid = grid
						grid = grabMouseFocusGrid									' exit dibs
						message = #WindowMouseExit
						state = newState													' no FOCUS
						XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
						GOSUB AddMessageToQueue
						grid = saveGrid
					END IF
				END IF
'
				IF grid THEN
					state = newState OR 0x80										' has FOCUS
					message = #WindowMouseEnter
					XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
					GOSUB AddMessageToQueue
				END IF
			END IF
'
			hostDisplay[host].gridMouseInside = grid
		END IF
	END IF
'
done:
'	XstLog ("CheckMice().Z : " + STRING$(message))
	##ALARMBUSY = entryALARMBUSY
	RETURN ($$FALSE)
'
'
'	*******************************
'	*****  AddMessageToQueue  *****
'	*******************************
'
'	userMessageQueue[] is a 1D array containing the user messages
'		It has a max size (1024).  Messages go in at userMessageQueueIn and come out
'			at userMessageQueueOut.
'		If the queue fills, wait till it is emptied completely before allowing
'			more messages to come in.  (This prevents choppy behavior that occurs
'			if messages pop in as the gap widens, halts till there is another gap.)
'
'	similar for systemMessageQueue[]
'
SUB AddMessageToQueue
'	XstLog ("CheckMice().Q : " + STRING$(message))
	SELECT CASE message
		CASE #WindowMouseMove,  #WindowMouseDrag
			cursor = overrideCursor
			IFZ overrideCursor THEN cursor = currentCursor
			hCursor = cursorHandle[cursor]
'			entryWHOMASK = ##WHOMASK
'			##WHOMASK = 0
'			SetCursor(hCursor)							' doesn't let resize cursor work
'			##WHOMASK = entryWHOMASK
	END SELECT
'
' don't post #WindowMouseMove unless queue is empty
'
	IFZ windowInfo[window].whomask THEN				' system queue
		IF (message = #WindowMouseMove) THEN
			IF (systemMessageQueueOut != systemMessageQueueIn) THEN EXIT SUB
		END IF
'
		IF noMessagesTillSystemQueueEmptied THEN
			IF (systemMessageQueueOut != systemMessageQueueIn) THEN EXIT SUB
			noMessagesTillSystemQueueEmptied = $$FALSE
		END IF
'
' if next systemMessageQueueIn = current systemMessageQueueOut, queue full
'
		nextMessageQueueIn = systemMessageQueueIn + 1
		IF (nextMessageQueueIn > UBOUND(systemMessageQueue[])) THEN
			nextMessageQueueIn = 0
		END IF
'
		IF (nextMessageQueueIn = systemMessageQueueOut) THEN
			noMessagesTillSystemQueueEmptied = $$TRUE							' queue full
			PRINT "Mice:  System Message Queue full!!!"
			EXIT SUB
		END IF
'
		systemMessageQueue[systemMessageQueueIn].message	= message
		systemMessageQueue[systemMessageQueueIn].wingrid	= window
		systemMessageQueue[systemMessageQueueIn].v0				= xxx			' was xWin
		systemMessageQueue[systemMessageQueueIn].v1				= yyy			' was yWin
		systemMessageQueue[systemMessageQueueIn].v2				= state
		systemMessageQueue[systemMessageQueueIn].v3				= time
		systemMessageQueue[systemMessageQueueIn].r0				= 0
		systemMessageQueue[systemMessageQueueIn].r1				= grid
		systemMessageQueueIn = nextMessageQueueIn
	ELSE																							' user queue
		IF (message = #WindowMouseMove) THEN
			IF (userMessageQueueOut != userMessageQueueIn) THEN EXIT SUB
		END IF
'
		IF noMessagesTillUserQueueEmptied THEN
			IF (userMessageQueueOut != userMessageQueueIn) THEN EXIT SUB
			noMessagesTillUserQueueEmptied = $$FALSE
		END IF
'
'		If next userMessageQueueIn = current userMessageQueueOut:  queue is now full
'
		nextMessageQueueIn = userMessageQueueIn + 1
		IF (nextMessageQueueIn > UBOUND(userMessageQueue[])) THEN
			nextMessageQueueIn = 0
		END IF
'
		IF (nextMessageQueueIn = userMessageQueueOut) THEN
			noMessagesTillUserQueueEmptied = $$TRUE				' queue full
			PRINT "SortX:  User Message Queue full!!!"
			EXIT SUB
		END IF
'
		userMessageQueue[userMessageQueueIn].message	= message
		userMessageQueue[userMessageQueueIn].wingrid	= window
		userMessageQueue[userMessageQueueIn].v0				= xxx			' was xWin
		userMessageQueue[userMessageQueueIn].v1				= yyy			' was yWin
		userMessageQueue[userMessageQueueIn].v2				= state
		userMessageQueue[userMessageQueueIn].v3				= time
		userMessageQueue[userMessageQueueIn].r0				= 0
		userMessageQueue[userMessageQueueIn].r1				= grid
		userMessageQueueIn = nextMessageQueueIn
	END IF
END SUB
END FUNCTION
'
'
' #############################
' #####  MouseMessage ()  #####
' #############################
'
FUNCTION  MouseMessage ()
	SHARED  xgrError
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  hostWin[]
	SHARED  cursorHandle[],  currentCursor,  overrideCursor
	SHARED  MESSAGE  lastQueuedMouseMessage
	SHARED  XGR_MESSAGE  lastMouseMessage
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  systemMessageQueueOut,  systemMessageQueueIn
	SHARED  noMessagesTillSystemQueueEmptied
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  userMessageQueueOut,  userMessageQueueIn
	SHARED  noMessagesTillUserQueueEmptied
	SHARED  lastMouseWindow
	SHARED  xgrInitialized
	STATIC  POINT  point
	STATIC	mouseWindow				' window that captured mouse
	STATIC  mouseGrid					' grid that captured mouse
	STATIC	downWindow				' window mouse button went down in
	STATIC  downGrid					' grid mouse button went down in
'
	IFF xgrInitialized THEN EXIT FUNCTION
	IFZ hostDisplay[] THEN EXIT FUNCTION						' no hosts open
'
	host = 1
	IFZ hostDisplay[host].status THEN RETURN				' host is dead
	IFZ hostWin[host,] THEN RETURN									' no windows for this host
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	alarmbusy = ##ALARMBUSY
	##ALARMBUSY = $$TRUE
'
'	new mouse event received after last one queued ???
'
	hwnd = lastMouseMessage.msg.hwnd								' hwnd = 0 after message queued
'	XstLog ("mm00: hwnd       = " + STRING$(hwnd))
	IFZ hwnd THEN ##ALARMBUSY = alarmbusy : RETURN
	lastMouseMessage.msg.hwnd = 0										' say queued
'
	grid = 0
	window = lastMouseMessage.window
	message = lastMouseMessage.msg.message
	flags = lastMouseMessage.msg.wParam
	xy = lastMouseMessage.msg.lParam
	time = lastMouseMessage.msg.time
'
	lButton = (flags AND $$MK_LBUTTON) << 24
	mButton = (flags AND $$MK_MBUTTON) << 21
	rButton = (flags AND $$MK_RBUTTON) << 25
	shift = (flags AND $$MK_SHIFT) << 14
	ctrl = (flags AND $$MK_CONTROL) << 14
	IF GetKeyState($$VK_MENU) THEN alt = 0x00040000 ELSE alt = 0
	state = rButton OR mButton OR lButton OR alt OR ctrl OR shift
'
	clientMessage = message
	IF ((message >= $$WM_NCMOUSEMOVE) AND (message <= $$WM_NCMBUTTONDBLCLK)) THEN clientMessage = $$FALSE
'
'
'	Get mouse location in window and display coordinates
'
	IF clientMessage THEN
		xWin = xy{{16,0}}							' client xy relative to client
		yWin = xy{{16,16}}
		point.x	= xWin
		point.y	= yWin
		ClientToScreen (hwnd, &point)
		xDisp	= point.x
		yDisp	= point.y
	ELSE
		xDisp = xy{{16,0}}						' non-Client xy relative to screen
		yDisp = xy{{16,16}}
		point.x	= xDisp
		point.y	= yDisp
		ScreenToClient (hwnd, &point)
		xWin = point.x
		yWin = point.y
	END IF
'
'	Mouse State:	Bits
'								24-31		btn state		buttons 1-8 (24-31);  1 = down
'								19-23		0						unused/reserved for key state use
'								18			KeyAlt			1 = down
'								17			KeyControl		"
'								16			KeyShift			"
'								8-15		0						unused/reserved
'								7				focus				1 = grid has mouse focus
'								4-6			0						clicks 1-4 (button down only)
'								0-3			button			0-8 button number (0 for mouse motion)
'
' old mouse information - from previous message
'
	newState     = state
	ohwnd        = hostDisplay[host].mouseWindowHwnd
	owindow      = hostDisplay[host].mouseWindow
	ostate       = hostDisplay[host].mouseState
	oxDisp       = hostDisplay[host].mouseXDisp
	oyDisp       = hostDisplay[host].mouseYDisp
	ogrid        = hostDisplay[host].gridMouseInside
	ograbGrid    = hostDisplay[host].grabMouseFocusGrid
	ogridInside  = ogrid
'
	grid = 0									' default
	gridInside = 0						' default
	grabGrid = ograbGrid			' default
'
	IF window THEN
		gridInside = ClosestGrid (window, xWin, yWin)
		grid = gridInside
	END IF
'
'	XstLog ("mm01: window     = " + STRING$(window))
'	XstLog ("mm02: message    = " + STRING$(message))
'	XstLog ("mm03: x          = " + STRING$(xy{16,0}))
'	XstLog ("mm04: y          = " + STRING$(xy{16,16}))
'	XstLog ("mm05: client     = " + STRING$(clientMessage))
'	XstLog ("mm06: xWin       = " + STRING$(xWin))
'	XstLog ("mm07: yWin       = " + STRING$(yWin))
'	XstLog ("mm08: xDisp      = " + STRING$(xDisp))
'	XstLog ("mm09: yDisp      = " + STRING$(yDisp))
'	XstLog ("mm10: newState   = " + HEX$(state,8))
'	XstLog ("mm11: ohwnd      = " + STRING$(ohwnd))
'	XstLog ("mm12: owindow    = " + STRING$(owindow))
'	XstLog ("mm13: oxDisp     = " + STRING$(oxDisp))
'	XstLog ("mm14: oyDisp     = " + STRING$(oyDisp))
'	XstLog ("mm15: ostate     = " + HEX$(ostate,8))
'	XstLog ("mm16: ogrid      = " + STRING$(ogrid))
'	XstLog ("mm17: grabGrid   = " + STRING$(grabGrid))
'	XstLog ("mm18: grabInside = " + STRING$(grabInside))
'	XstLog ("mm19: grid       = " + STRING$(grid))
'
' check for capture focus or release focus
'
	error = $$FALSE
	mousemove = $$FALSE
	updateMouseStatus = $$FALSE
	oldDown = oldState AND 0xFF000000
	newDown = newState AND 0xFF000000
	IF ((grid == ogrid) AND ((xDisp != oxDisp) OR (newDown != oldDown))) THEN mousemove = $$TRUE
	IF ((grid == ogrid) AND ((yDisp != oyDisp) OR (newDown != oldDown))) THEN mousemove = $$TRUE
'
' different routines depending on who currently has mouse captured
'
	SELECT CASE TRUE
		CASE ograbGrid	: GOSUB GridHasCapture
		CASE owindow		: GOSUB WindowHasCapture
		CASE ELSE				: GOSUB WindowCapture
	END SELECT
'
	IF updateMouseStatus THEN
		GOSUB UpdateMouseStatus
	ELSE
		IF grid THEN
			IFZ grabGrid THEN
				IF mousemove THEN
					message = #WindowMouseMove
					XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
					GOSUB AddMessageToQueue
					GOSUB UpdateMouseStatus
				END IF
			END IF
		END IF
	END IF
'
	IF window THEN lastMouseWindow = window
	RETURN error
'
'
'
'
' *************************
' *****  subroutines  *****
' *************************
'
'
' *****  GridHasCapture  *****
'
SUB GridHasCapture
'	XstLog ("mm20: GridHasCapture")
'
	drag = $$TRUE
	XgrConvertWindowToLocal (ograbGrid, xWin, yWin, @xxx, @yyy)
'
' if mouse has entered or exited the capture grid,
' issue a #WindowMouseEnter or #WindowMouseExit
'
	IF (ogridInside == ograbGrid) THEN
		IF (gridInside != ograbGrid) THEN
			gggg = grid
			wwww = window
			grid = ograbGrid
			window = owindow
			message = #WindowMouseExit
			updateMouseStatus = $$TRUE
			GOSUB AddMessageToQueue
			drag = $$FALSE
			window = wwww
			grid = gggg
		END IF
	ELSE
		IF (gridInside == grabGrid) THEN
			message = #WindowMouseEnter
			updateMouseStatus = $$TRUE
			GOSUB AddMessageToQueue
			drag = $$FALSE
		END IF
	END IF
'
' if grid had mouse capture previously but no mouse buttons
' are down now, add a #WindowMouseUp message to the queue
'
	IFZ newDown THEN
		gggg = grid
		wwww = window
		grid = ograbGrid
		window = owindow
		grabGrid = $$FALSE
		message = #WindowMouseUp
		updateMouseStatus = $$TRUE
		GOSUB AddMessageToQueue
		drag = $$FALSE
		window = wwww
		grid = gggg
'
		IF (grid AND (grid != ograbGrid)) THEN
			message = #WindowMouseEnter
			updateMouseStatus = $$TRUE
			GOSUB AddMessageToQueue
		END IF
'
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		ReleaseCapture ()
		##LOCKOUT = lockout
		##WHOMASK = whomask
	END IF
'
' one or more buttons are still down, so add #WindowMouseDrag
' message to the queue if the mouse position has changed
'
	IF newDown THEN
		IF drag THEN
			IF (xDisp == oxDisp) THEN
				IF (yDisp == oyDisp) THEN
					IF (newDown == oldDown) THEN drag = $$FALSE
				END IF
			END IF
		END IF
'
		IF drag THEN
			gggg = grid
			wwww = window
			grid = ograbGrid
			window = owindow
			message = #WindowMouseDrag
			updateMouseStatus = $$TRUE
			GOSUB AddMessageToQueue
			window = wwww
			grid = gggg
		END IF
	END IF
'
'	PRINT "z:"; grabGrid, grid, ogridInside, gridInside, ohwnd, hwnd, owindow, window, xDisp, yDisp, drag
END SUB
'
'
' *****  WindowHasCapture  *****
'
SUB WindowHasCapture
'	XstLog ("mm40: WindowHasCapture")
'
	GOSUB MouseExitEnter
'
	IFZ clientMessage THEN
		GOSUB ZeroMouseStatus
		updateMouseStatus = $$TRUE
'		XstLog ("mm41: WindowReleaseCapture")
		EXIT SUB
	END IF
'
	IFZ oldDown THEN
		IF newDown THEN
			IF (grid > 0) THEN
				message = #WindowMouseDown
				XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
				updateMouseStatus = $$TRUE
				GOSUB AddMouseDownToQueue
				grabGrid = grid
'
				##WHOMASK = 0
				##LOCKOUT = $$TRUE
				SetCapture (hwnd)
				##LOCKOUT = lockout
				##WHOMASK = whomask
				EXIT SUB
			END IF
		END IF
	END IF
END SUB
'
'
' *****  WindowCapture  *****
'
SUB WindowCapture
'	XstLog ("mm60: WindowCapture")
	IFZ clientMessage THEN EXIT SUB		' mouse not in client part of window
	updateMouseStatus = $$TRUE
	GOSUB MouseExitEnter
END SUB
'
'
' *****  AddMouseDownToQueue  *****
'
' The following subroutine is from an older version of GraphicsDesigner
' before this function was re-written.  The new code does not yet update
' and check lastClickTime, buttonClicks, and generate the appropriate
' multiple-click field and button number field.
'
SUB AddMouseDownToQueue
	change = oldDown XOR newDown
	buttonDown = $$FALSE
	mask = 0x00800000
	FOR i = 24 TO 31															' check all buttons
		mask = mask << 1
		IF (change AND mask) THEN
			buttonNumber = i - 23
			IF (newState AND mask) THEN
				buttonDown = $$TRUE
'
'	get button clicks
'
				clicks = 1
				dt&& = ULONG(time) - ULONG(gridInfo[grid].lastClickTime)
				IF ((dt&& > 0) AND (dt&& < 400)) THEN
					clicks = gridInfo[grid].buttonClicks
					INC clicks
					IF (clicks > 4) THEN clicks = 4
				END IF
				gridInfo[grid].lastClickTime = time
				gridInfo[grid].buttonClicks = clicks
			END IF
'
			state = newState OR 0x80 OR (clicks << 4) OR buttonNumber
			GOSUB AddMessageToQueue
		END IF
	NEXT i
END SUB
'
'
' *****  MouseExitEnter  *****
'
SUB MouseExitEnter
'	XstLog ("mm80: MouseExitEnter")
	IF (ogrid == grid) THEN EXIT SUB					' same grid, no enter/exit
'
' exit old grid if any
'
	IF ogrid THEN
		ggg = grid
		sss = state
		www = window
		grid = ogrid
		state = ostate																					' no FOCUS
		window = owindow
		message = #WindowMouseExit
'		XstLog ("mm81: #WindowMouseExit = " + STRING$(message))
		XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
		hostDisplay[host].gridMouseInside = 0
		updateMouseStatus = $$TRUE
		GOSUB AddMessageToQueue
		window = www
		state = sss
		grid = ggg
	END IF
'
' enter new grid if any
'
	IF grid THEN
		state = state OR 0x80																		' has FOCUS
		message = #WindowMouseEnter
'		XstLog ("mm82: #WindowMouseEnter = " + STRING$(message))
		XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
		hostDisplay[host].gridMouseInside = grid
		updateMouseStatus = $$TRUE
		GOSUB AddMessageToQueue
	END IF
END SUB
'
'
' *****  ZeroMouseStatus  *****
'
SUB ZeroMouseStatus
'	XstLog ("mm90: ZeroMouseStatus")
'
	grid = 0
	hwnd = 0
	window = 0
	grabGrid = 0
	gridInside = 0
END SUB
'
'
' *****  UpdateMouseStatus  *****
'
SUB UpdateMouseStatus
'	XstLog ("mm90: UpdateMouseStatus")
'
	hostDisplay[host].mouseWindowHwnd = hwnd
	hostDisplay[host].mouseWindow = window
	hostDisplay[host].mouseState = state
	hostDisplay[host].mouseXDisp = xDisp
	hostDisplay[host].mouseYDisp = yDisp
	hostDisplay[host].gridMouseInside = grid
	hostDisplay[host].grabMouseFocusGrid = grabGrid
END SUB
'
'
' *****  CheckInsideWindow  *****
'
SUB CheckInsideWindow
'	XstLog ("mm92: CheckInsideWindow")
'
	insideWindow = $$FALSE
	x1Disp = windowInfo[checkWindow].xDisp
	y1Disp = windowInfo[checkWindow].yDisp
	x2Disp = windowInfo[checkWindow].width + x1Disp - 1
	y2Disp = windowInfo[checkWindow].height + y1Disp - 1
'
	IF (xDisp < x1Disp) THEN EXIT SUB
	IF (yDisp < y1Disp) THEN EXIT SUB
	IF (xDisp > x2Disp) THEN EXIT SUB
	IF (yDisp > y2Disp) THEN EXIT SUB
	insideWindow = $$TRUE
END SUB
'
'
' *****  CheckInsideGrid  *****
'
SUB CheckInsideGrid
'	XstLog ("mm94: CheckInsideGrid")
'
	insideGrid = $$FALSE
	checkWindow = gridInfo[checkGrid].window
	x0Disp = windowInfo[checkWindow].xDisp
	y0Disp = windowInfo[checkWindow].yDisp
	x1Disp = x0Disp + gridInfo[checkGrid].winBox.x1
	y1Disp = y0Disp + gridInfo[checkGrid].winBox.y1
	x2Disp = x0Disp + gridInfo[checkGrid].winBox.x2
	y2Disp = y0Disp + gridInfo[checkGrid].winBox.y2
'
	IF (xDisp < x1Disp) THEN EXIT SUB
	IF (yDisp < y1Disp) THEN EXIT SUB
	IF (xDisp > x2Disp) THEN EXIT SUB
	IF (yDisp > y2Disp) THEN EXIT SUB
	insideGrid = $$TRUE
END SUB
'
'
'	*******************************
'	*****  AddMessageToQueue  *****
'	*******************************
'
' userMessageQueue[] is a 1024 element array that holds user messages.
' Messages go in at userMessageQueueIn and come out at userMessageQueueOut.
' If the queue fills, wait till it is emptied completely before allowing
' more messages to come in.  This prevents choppy behavior that occurs if
' messages pop in as the gap widens then halts until another gap appears.
'
'	similar for systemMessageQueue[]
'
SUB AddMessageToQueue
'	XstLog ("Q:" + STRING$(message))
	SELECT CASE message
		CASE #WindowMouseMove,  #WindowMouseDrag
			cursor = overrideCursor
			IFZ overrideCursor THEN cursor = currentCursor
			hCursor = cursorHandle[cursor]
'			entryWHOMASK = ##WHOMASK
'			##WHOMASK = 0
'			SetCursor(hCursor)							' doesn't let resize cursor work
'			##WHOMASK = entryWHOMASK
	END SELECT
'
' don't post #WindowMouseMove unless queue is empty
'
	IFZ windowInfo[window].whomask THEN				' system queue
		IF (message = #WindowMouseMove) THEN
			IF (systemMessageQueueOut != systemMessageQueueIn) THEN EXIT SUB
		END IF
'
		IF noMessagesTillSystemQueueEmptied THEN
			IF (systemMessageQueueOut != systemMessageQueueIn) THEN EXIT SUB
			noMessagesTillSystemQueueEmptied = $$FALSE
		END IF
'
' if next systemMessageQueueIn = current systemMessageQueueOut, queue full
'
		nextMessageQueueIn = systemMessageQueueIn + 1
		IF (nextMessageQueueIn > UBOUND(systemMessageQueue[])) THEN
			nextMessageQueueIn = 0
		END IF
'
		IF (nextMessageQueueIn = systemMessageQueueOut) THEN
			noMessagesTillSystemQueueEmptied = $$TRUE							' queue full
			PRINT "Mice:  System Message Queue full!!!"
			EXIT SUB
		END IF
'
'		XgrMessageNumberToName (message, @message$)
'		PRINT "msys: " + RJUST$(STRING$(window),4) + " : " + RJUST$(STRING$(grid),4) + ", " + LJUST$(message$,20) + ", " + RJUST$(STRING$(xxx),4) + ", " + RJUST$(STRING$(yyy),4) + ", " + RJUST$(STRING$(state),4) + ", " + RJUST$(STRING$(time),10)
'		XstLog ("msys: " + RJUST$(STRING$(window),4) + " : " + RJUST$(STRING$(grid),4) + ", " + LJUST$(message$,20) + ", " + RJUST$(STRING$(xxx),4) + ", " + RJUST$(STRING$(yyy),4) + ", " + RJUST$(STRING$(state),4) + ", " + RJUST$(STRING$(time),10))
		systemMessageQueue[systemMessageQueueIn].message	= message
		systemMessageQueue[systemMessageQueueIn].wingrid	= window
		systemMessageQueue[systemMessageQueueIn].v0				= xxx			' was xWin
		systemMessageQueue[systemMessageQueueIn].v1				= yyy			' was yWin
		systemMessageQueue[systemMessageQueueIn].v2				= state
		systemMessageQueue[systemMessageQueueIn].v3				= time
		systemMessageQueue[systemMessageQueueIn].r0				= 0
		systemMessageQueue[systemMessageQueueIn].r1				= grid
		systemMessageQueueIn = nextMessageQueueIn
	ELSE																							' user queue
		IF (message = #WindowMouseMove) THEN
			IF (userMessageQueueOut != userMessageQueueIn) THEN EXIT SUB
		END IF
'
		IF noMessagesTillUserQueueEmptied THEN
			IF (userMessageQueueOut != userMessageQueueIn) THEN EXIT SUB
			noMessagesTillUserQueueEmptied = $$FALSE
		END IF
'
'		If next userMessageQueueIn = current userMessageQueueOut:  queue is now full
'
		nextMessageQueueIn = userMessageQueueIn + 1
		IF (nextMessageQueueIn > UBOUND(userMessageQueue[])) THEN
			nextMessageQueueIn = 0
		END IF
'
		IF (nextMessageQueueIn = userMessageQueueOut) THEN
			noMessagesTillUserQueueEmptied = $$TRUE				' queue full
			PRINT "SortX:  User Message Queue full!!!"
			EXIT SUB
		END IF
'
'		XgrMessageNumberToName (message, @message$)
'		PRINT "musr: " + RJUST$(STRING$(window),4) + " : " + RJUST$(STRING$(grid),4) + ", " + LJUST$(message$,20) + ", " + RJUST$(STRING$(xxx),4) + ", " + RJUST$(STRING$(yyy),4) + ", " + RJUST$(STRING$(state),4) + ", " + RJUST$(STRING$(time),10)
'		XstLog ("musr: " + RJUST$(STRING$(window),4) + " : " + RJUST$(STRING$(grid),4) + ", " + LJUST$(message$,20) + ", " + RJUST$(STRING$(xxx),4) + ", " + RJUST$(STRING$(yyy),4) + ", " + RJUST$(STRING$(state),4) + ", " + RJUST$(STRING$(time),10))
		userMessageQueue[userMessageQueueIn].message	= message
		userMessageQueue[userMessageQueueIn].wingrid	= window
		userMessageQueue[userMessageQueueIn].v0				= xxx			' was xWin
		userMessageQueue[userMessageQueueIn].v1				= yyy			' was yWin
		userMessageQueue[userMessageQueueIn].v2				= state
		userMessageQueue[userMessageQueueIn].v3				= time
		userMessageQueue[userMessageQueueIn].r0				= 0
		userMessageQueue[userMessageQueueIn].r1				= grid
		userMessageQueueIn = nextMessageQueueIn
	END IF
END SUB
END FUNCTION
'
'
' ###########################
' #####  Initialize ()  #####
' ###########################
'
'	Initialize the message arrays
'
'	In:				none
'	Out:			none
'	Return:		none
'
FUNCTION  Initialize ()
	SHARED  UBYTE  charsetKeystateModify[]
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  operatingSystem
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  systemMessageQueueOut,  systemMessageQueueIn
	SHARED  noMessagesTillSystemQueueEmptied
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  userMessageQueueOut,  userMessageQueueIn
	SHARED  noMessagesTillUserQueueEmptied
	SHARED  colorPixel[]
	SHARED  ntDrawMode[]
	SHARED  fontWindow
	SHARED  color$[]
	SHARED	border$[]
	SHARED	borderWidth[]

	SHARED  defaultBackground
	SHARED  defaultDrawing
	SHARED  defaultLowlight
	SHARED  defaultHighlight
	SHARED  defaultAccent
	SHARED  defaultDull
'
	SHARED  GT_Coordinate				' 0 (fixed by GraphicsDesigner)
	SHARED  GT_Image						' 1 (fixed by GraphicsDesigner)
'
	SHARED	I_Window
'
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0
'
	DIM charsetKeystateModify[255]
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE (i = $$KeyTab)				: charsetKeystateModify[i] = i
			CASE (i = $$KeyEnter)			: charsetKeystateModify[i] = i
			CASE (i = $$KeyDelete)		: charsetKeystateModify[i] = i
			CASE (i = $$KeyInsert)		: charsetKeystateModify[i] = i
			CASE (i = $$KeyBackspace)	: charsetKeystateModify[i] = i
			CASE (i < 0x20)						: charsetKeystateModify[i] = 0
			CASE ELSE									: charsetKeystateModify[i] = i
		END SELECT
	NEXT i
'
	XstGetOSName (@name$)
	IF (name$ = "Windows") THEN
		operatingSystem = $$Windows
	ELSE
		operatingSystem = $$WindowsNT
	END IF
'
'	Create the message queues
'
	DIM systemMessageQueue[1023]
	systemMessageQueueOut = 0
	systemMessageQueueIn = 0
	noMessagesTillSystemQueueEmptied = $$FALSE
'
	DIM userMessageQueue[1023]
	userMessageQueueOut = 0
	userMessageQueueIn = 0
	noMessagesTillUserQueueEmptied = $$FALSE
'
'
' **********************************************
' *****  Initialize Border Constant Names  *****
' **********************************************
'
	DIM border$[31]
	DIM borderWidth[31]
	border$[$$BorderNone]					= "$$BorderNone"					: borderWidth[$$BorderNone]					= 0
	border$[$$BorderFlat1]				= "$$BorderFlat1"					: borderWidth[$$BorderFlat1]				= 1
	border$[$$BorderFlat2]				= "$$BorderFlat2"					: borderWidth[$$BorderFlat2]				= 2
	border$[$$BorderFlat4]				= "$$BorderFlat4"					: borderWidth[$$BorderFlat4]				= 4
	border$[$$BorderHiLine1]			= "$$BorderHiLine1"				: borderWidth[$$BorderHiLine1]			= 1
	border$[$$BorderHiLine2]			= "$$BorderHiLine2"				: borderWidth[$$BorderHiLine2]			= 2
	border$[$$BorderHiLine4]			= "$$BorderHiLine4"				: borderWidth[$$BorderHiLine4]			= 4
	border$[$$BorderLoLine1]			= "$$BorderLoLine1"				: borderWidth[$$BorderLoLine1]			= 1
	border$[$$BorderLoLine2]			= "$$BorderLoLine2"				: borderWidth[$$BorderLoLine2]			= 2
	border$[$$BorderLoLine4]			= "$$BorderLoLine4"				: borderWidth[$$BorderLoLine4]			= 4
	border$[$$BorderRaise1]				= "$$BorderRaise1"				: borderWidth[$$BorderRaise1]				= 1
	border$[$$BorderLower1]				= "$$BorderLower1"				: borderWidth[$$BorderLower1]				= 1
	border$[$$BorderRaise2]				= "$$BorderRaise2"				: borderWidth[$$BorderRaise2]				= 2
	border$[$$BorderLower2]				= "$$BorderLower2"				: borderWidth[$$BorderLower2]				= 2
	border$[$$BorderRaise4]				= "$$BorderRaise4"				: borderWidth[$$BorderRaise4]				= 4
	border$[$$BorderLower4]				= "$$BorderLower4"				: borderWidth[$$BorderLower4]				= 4
	border$[$$BorderFrame]				= "$$BorderFrame"					: borderWidth[$$BorderFrame]				= 4
	border$[$$BorderDrain]				= "$$BorderDrain"					: borderWidth[$$BorderDrain]				= 4
	border$[$$BorderRidge]				= "$$BorderRidge"					: borderWidth[$$BorderRidge]				= 2
	border$[$$BorderValley]				= "$$BorderValley"				: borderWidth[$$BorderValley]				= 2
	border$[$$BorderWide]					= "$$BorderWide"					: borderWidth[$$BorderWide]					= 6
	border$[$$BorderWideResize]		= "$$BorderResize"				: borderWidth[$$BorderWideResize]		= 6
	border$[$$BorderWindow]				= "$$BorderWindow"				: borderWidth[$$BorderWindow]				= 4
	border$[$$BorderWindowResize]	= "$$BorderWindowResize"	: borderWidth[$$BorderWindowResize]	= 4
	border$[$$BorderRise2]				= "$$BorderRise2"					: borderWidth[$$BorderRise2]				= 2
	border$[$$BorderSink2]				= "$$BorderSink2"					: borderWidth[$$BorderSink2]				= 2
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
'
' ******************************
' *****  Register Messages *****  Create message numbers for message names
' ******************************
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
'	Register common grid types and XBasic environment specific ones too
'
	XgrRegisterGridType (@"Coordinate",				@GT_Coordinate)
	XgrRegisterGridType (@"Image",						@GT_Image)
'
'	standard color number to win32 pixel
'
	DIM colorPixel[255]
	colorIndex = 0
	red = 0x00
	FOR r = 0 TO 4
		green = 0x00
		FOR g = 0 TO 4
			blue = 0x00
			FOR b = 0 TO 4
				colorPixel[colorIndex] = (blue << 16) OR (green << 8) OR red
				INC colorIndex
				blue = blue + 0x40
				IF (blue > 0xFF) THEN blue = 0xFF
			NEXT b
			green = green + 0x40
			IF (green > 0xFF) THEN green = 0xFF
		NEXT g
		red = red + 0x40
		IF (red > 0xFF) THEN red = 0xFF
	NEXT r
'
	IF hostDisplay[] THEN
		FOR host = 0 TO UBOUND(hostDisplay[])
			IFZ hostDisplay[host].status THEN DO NEXT
			hostDisplay[host].mouseWindowHwnd	= 0
			hostDisplay[host].mouseWindow			= 0
			hostDisplay[host].mouseState			= 0
			hostDisplay[host].mouseXDisp			= 0
			hostDisplay[host].mouseYDisp			= 0
		NEXT host
	END IF
'
'	draw mode to win32 draw mode
'
	DIM ntDrawMode[3]
	ntDrawMode[ $$DrawCOPY] = 13
	ntDrawMode[ $$DrawXOR	] = 7
	ntDrawMode[ $$DrawAND	] = 9
	ntDrawMode[ $$DrawOR	] = 15
'
'	default colors
'
	defaultBackground	= $$MediumGrey
	defaultDrawing		= $$Black
	defaultLowlight		= $$DarkGrey
	defaultHighlight	= $$BrightGrey
	defaultDull				= $$DarkGrey
	defaultAccent			= $$Yellow
	defaultLowText		= $$Black
	defaultHighText		= $$White
'
'	default cursor
'
	XgrRegisterCursor (@"arrow", @C_Arrow)
'
'	default icon
'
	XgrRegisterIcon (@"window", @I_Window)
'
'	Open font window  (REQUIRED to initialize font)
'		fontWindow REQUIRED to create fonts (needs an hdc)
'
	XgrCreateWindow (@fontWindow, 0, 0, 0, 1, 1, 0, "")
'
'	Flush draw commands instantly (MAY BE SLOW!)
'		Disable batching
'
	GdiSetBatchLimit (1)
'	ShowCursor (1)
'
	##WHOMASK = entryWHOMASK
	RETURN (error)
END FUNCTION
'
'
' ########################
' #####  WinProc ()  #####
' ########################
'
' The path of all Windows messages is:
'   XxxDispatchEvents() removes message from Windows queue
'   XxxDispatchEvents() calls DispatchMessageA()
'		DispatchMessageA calls WinProc() - this function
'		WinProc() does one of two things:
'			a. process the message and return - GraphicsDesigner handling
'			b. call DefWindowProc() and return - default Windows handling
'
FUNCTION  WinProc (hwnd, NTmessage, wParam, lParam)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  XGR_MESSAGE  lastMouseMessage
	SHARED  winGrid[]
	SHARED  hostWin[]
	SHARED  iconHandle[]
	SHARED	modalWindowUser
	SHARED	modalWindowSystem
	SHARED  MESSAGE  systemMessageQueue[]
	SHARED  systemMessageQueueOut,  systemMessageQueueIn
	SHARED  noMessagesTillSystemQueueEmptied
	SHARED  MESSAGE  userMessageQueue[]
	SHARED  userMessageQueueOut,  userMessageQueueIn
	SHARED  noMessagesTillUserQueueEmptied
	STATIC  SUBADDR  NTmessageType[]
	STATIC  POINT  point
	STATIC  RECT  rect
	STATIC	PAINTSTRUCT  ps
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	IFZ NTmessageType[] THEN GOSUB InitArrays
'
'	PRINT "WinProc:  "; HEX$(NTmessage,8),, HEX$(hwnd,8),,
'	XstLog ("WinProc() : " + STRING$(hwnd) + " " + STRING$(NTmessage) + " " + STRING$(wParam) + " " + STRING$(lParam))
	IF (NTmessage <= $$WM_LASTMESSAGE) THEN
		IF NTmessageType[NTmessage] THEN
			IF hostWin[] THEN
				host = 1															' only one NT host for now
				IF hostWin[host,] THEN
					uHostWin = UBOUND(hostWin[host,])
					FOR j = 0 TO uHostWin
						window = hostWin[host,j]
						IFZ window THEN DO NEXT
						IF (hwnd != windowInfo[window].hwnd) THEN DO NEXT
						GOSUB @NTmessageType[NTmessage]		' wingrid != 0 if successful queue
'						PRINT window, NTmessage
						##WHOMASK = entryWHOMASK
						RETURN (0)												' 0 = "Message processed"
					NEXT j
				END IF
			END IF
		END IF
	ELSE							' user message - okay with hwnd = 0 so window = 0
		host = 1
		window = 0
		IF hwnd THEN
			IF hostWin[] THEN
				IF hostWin[host,] THEN
					uHostWin = UBOUND (hostWin[host,])
					FOR j = 0 TO uHostWin
						window = hostWin[host,j]
						IF window THEN
							IF hwnd THEN
								IF (hwnd = windowInfo[window].hwnd) THEN EXIT FOR
							END IF
						END IF
						window = 0
					NEXT j
				END IF
			END IF
		END IF
'
' #####
' #####  begin vv non-generic MouseWheel code (applies to Win'95 platform)
' #####
'
' Try to get the Magellan message handle, if the native NTmessage 0x20a is not detected this
' is the last filter funnel to filter out the wheelmouse handle from the system-messages.
' This small section applies to win'95 only.
'
		##LOCKOUT = $$TRUE
		mouseWheelMessage = RegisterWindowMessageA (&"MSWHEEL_ROLLMSG")
		##LOCKOUT = entryLOCKOUT
		##WHOMASK = entryWHOMASK
'
		IF (NTmessage == mouseWheelMessage) THEN
			GOSUB MouseWheel												' generated Magellan message found
		ELSE
			GOSUB WindowSystemMessage								' without window # is okay
		END IF
'
' #####
' #####  end vv non-generic MouseWheel code
' #####
'
	END IF
'
'	execute default window procedure for unhandled messages
'
	##LOCKOUT = $$TRUE
	val = DefWindowProcA (hwnd, NTmessage, wParam, lParam)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN (val)
'
'
' *****  WindowSystemMessage  *****
'
SUB WindowSystemMessage
	wingrid = window
	message = #WindowSystemMessage
	v0 = hwnd
	v1 = NTmessage
	v2 = wParam
	v3 = lParam
	r0 = 0
	r1 = window
'
	IF window THEN
		GOSUB AddMessageToQueue					' let window whomask decide
	ELSE
		GOSUB AddMessageToUserQueue			' no window means user queue
	END IF
END SUB
'
'
'	*****  Focus  *****  SetFocus, KillFocus
'
SUB Focus
	v0 = 0 : v1 = 0 : v2 = 0 : v3 = 0
	selectedWindow = hostDisplay[host].selectedWindow
	SELECT CASE NTmessage
		CASE $$WM_KILLFOCUS
'					PRINT "WinProc(): Focus: $$WM_KILLFOCUS", window, selectedWindow
					IF (window != selectedWindow) THEN EXIT SUB
					hostDisplay[host].selectedWindow = 0
					message = #WindowDeselected
					wingrid = window
					r1 = window
					GOSUB AddMessageToQueue
		CASE $$WM_SETFOCUS
'					PRINT "WinProc(): Focus: $$WM_KILLFOCUS", window, selectedWindow
					IF (window = selectedWindow) THEN EXIT SUB		' already selected
					message = #WindowSelected
					hostDisplay[host].selectedWindow = window
					wingrid = window
					r1 = window
					GOSUB AddMessageToQueue
		CASE ELSE
					PRINT "WinProc(): Focus: Error: (message != $$WM_SETFOCUS or $$WM_KILLFOCUS)"
	END SELECT
'
	##LOCKOUT = $$TRUE
	val = DefWindowProcA (hwnd, NTmessage, wParam, lParam)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN (val)
END SUB
'
'
'	*****  Move  *****
'
SUB Move
	IF (windowInfo[window].visible = $$WindowMinimized) THEN EXIT SUB
	xDisp			= lParam{{16,0}}
	yDisp			= lParam{{16,16}}
	oldXDisp	= windowInfo[window].xDisp				' former size
	oldYDisp	= windowInfo[window].yDisp
'
	IF (xDisp = oldXDisp) THEN
		IF (yDisp = oldYDisp) THEN EXIT SUB				' no xy change
	END IF
'
'	Update windowInfo[]
'
	windowInfo[window].xDisp = xDisp
	windowInfo[window].yDisp = yDisp
	width = windowInfo[window].width
	height = windowInfo[window].height
'
	message = #WindowResized
	wingrid = window
	v0 = xDisp
	v1 = yDisp
	v2 = width
	v3 = height
	r1 = window
	GOSUB AddMessageToQueue
END SUB
'
'
' *****  MouseWheel  *****
'
SUB MouseWheel
	grid = 0
	xy = lParam
	flags = wParam
	window = lastMouseMessage.window
	time = lastMouseMessage.msg.time
	IFZ window THEN EXIT SUB
	IFZ hwnd THEN EXIT SUB
'
	lButton = (flags AND $$MK_LBUTTON) << 24
	mButton = (flags AND $$MK_MBUTTON) << 21
	rButton = (flags AND $$MK_RBUTTON) << 25
	shift = (flags AND $$MK_SHIFT) << 14
	ctrl = (flags AND $$MK_CONTROL) << 14
	IF GetKeyState($$VK_MENU) THEN alt = 0x00040000 ELSE alt = 0
	state = rButton OR mButton OR lButton OR alt OR ctrl OR shift
'
	xDisp = xy{{16,0}}						' non-Client xy relative to screen
	yDisp = xy{{16,16}}
	point.x	= xDisp
	point.y	= yDisp
	ScreenToClient (hwnd, &point)
	xWin = point.x
	yWin = point.y
'
	##LOCKOUT = $$TRUE
'
' #####
' #####  begin vv magallan parameter block
' #####
'
' The following code draws the messages from the configuration driver that sets
' the scroll lines.  The last parameter contains the amount of lines to be scrolled
' up or down: A negative value means scrolling them down, a positive value means
' scrolling them up.  These message handles are generic if the Magellan configurator
' is used.  Note for Linux programmers: you are advised to translate platform related
' messages in the same similar matter as done here, if native messages are on hand,
' use native as much as possible, it all depends on what will be the generic wheelmouse
' driver for Linux / Unix.
'
	hdlMsWheel = FindWindowA (&"MouseZ", &"Magellan MSWHEEL")
'
	IF hdlMsWheel THEN  ' Mouse configurator Found
'
' get global configuration parameters to use for mouse-wheel event, these are NOT *system*
'	native messages but native messages from the configuration manager that controls your mouse
' configuration. This manager translates incoming signals from several wheelmouse brands to
' general configuration messages.
'
'	For the sake of win'95 support, Only the wheelmessage is used to cover what is a native message 
' in Win'98 / NT 4 SP4+ / 2000. The button messages are not enabled.
'
'		puiMsh_Msg3DSupport = RegisterWindowMessageA (&"MSH_WHEELSUPPORT_MSG")
		puiMsh_MsgScrollLines = RegisterWindowMessageA (&"MSH_SCROLL_LINES_MSG")
'
'		IF puiMsh_Msg3DSupport THEN
'			pf3DSupport = SendMessageA(hdlMsWheel, puiMsh_Msg3DSupport, 0, 0)
'		ELSE
'			pf3DSupport = $$FALSE
'		END IF
'
'
' scroll how many lines? (This parameter is non-native)
'
		IF puiMsh_MsgScrollLines THEN
			mouseWheelLines = SendMessageA(hdlMsWheel, puiMsh_MsgScrollLines, 0, 0)
'
'
'	Scroll per page instead, value will be -1, decrease another 100 to go beyond magallan maximum.
'
			IF mouseWheelLines = -1 THEN
				mouseWheelLines = 101
			END IF
'
		ELSE
			mouseWheelLines = 3  ' default
		END IF
'
'		PRINT "Lines   :"; MouseWheelLines; "  Message  :"; mouseWheelMessage; "  3dsupp  :"; puiMsh_Msg3DSupport
'		PRINT "Scrolllines y/n :"; puiMsh_MsgScrollLines ; "  3dsup type :"; pf3DSupport
	ELSE
'
'	Huh?.. A wheelmousedriver that did not supplied the generic config handle's
' Default to native system message support only.
'
		mouseWheelLines = 1
	END IF
'
' #####
' #####  end vv magallan parameter block
' #####
'
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	lines = wParam >> 24
	extra = wParam AND 0x0000FFFF
	grid = ClosestGrid (window, xWin, yWin)
	IF lines THEN lines = -mouseWheelLines ELSE lines = mouseWheelLines
'
	IFZ grid THEN EXIT SUB
'
	XgrConvertWindowToLocal (grid, xWin, yWin, @xxx, @yyy)
'
	message = #WindowMouseWheel
	wingrid = window
	v0 = xxx
	v1 = yyy
	v2 = state
	v3 = lines
	r1 = grid
	GOSUB AddMessageToQueue
'	PRINT "WinProc() :  #WindowMouseWheel : "; #WindowMouseWheel;; hwnd;; NTmessage;; HEX$(wParam,8);; HEX$(lParam,8);;; xDisp;; yDisp;;; xWin;; yWin;;; xxx;; yyy;;; HEX$(v2,8);; HEX$(v3,8)
END SUB
'
'
'	*****  MouseActivate  *****  If $$WindowNoSelect, don't process any further
'
SUB MouseActivate
'	XstLog ("WinProc() : MouseActivate : " + STRING$(window) + " " + STRING$(hwnd) + " " + STRING$(NTmessage) + " " + STRING$(lParam))
	windowType = windowInfo[window].windowType
	IF (windowType AND $$WindowTypeNoSelect) THEN
'		PRINT "WP MouseActivate "; window; " skip it"
		##WHOMASK = entryWHOMASK
		RETURN ($$MA_NOACTIVATE)
	END IF
'
'	PRINT "NT messsage type found"
'	PRINT "WP MouseActivate "; window; " activate it"
'
	##LOCKOUT = $$TRUE
	val = DefWindowProcA (hwnd, NTmessage, wParam, lParam)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN (val)
END SUB
'
'
'	*****  MouseNC  *****  WinProc() not handed time - use previous time
'
SUB MouseNC
'	XstLog ("WinProc() : MouseNC : " + STRING$(window) + " " + STRING$(hwnd) + " " + STRING$(NTmessage) + " " + STRING$(lParam))
	lastMouseMessage.window = window
	lastMouseMessage.msg.hwnd = hwnd
	lastMouseMessage.msg.message = NTmessage
	lastMouseMessage.msg.lParam = lParam
'
'	Non-Client wParam isn't "flags":  kludge one up
'
	flags = 0
	IF GetAsyncKeyState($$VK_SHIFT)		THEN flags = flags OR 0x0004
	IF GetAsyncKeyState($$VK_CONTROL)	THEN flags = flags OR 0x0008
	IF GetAsyncKeyState($$VK_LBUTTON)	THEN flags = flags OR 0x0001
	IF GetAsyncKeyState($$VK_MBUTTON)	THEN flags = flags OR 0x0010
	IF GetAsyncKeyState($$VK_RBUTTON)	THEN flags = flags OR 0x0002
	lastMouseMessage.msg.wParam = flags
'
'	Force this message into the queue (since OS gobbles up messages,
'		we'll miss corresponding mouse up, etc)
'		This is typically only a NCxButtonDown message.
'
'	CheckMice ()
'
	##LOCKOUT = $$TRUE
	val = DefWindowProcA (hwnd, NTmessage, wParam, lParam)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN (val)
END SUB
'
'
'	*****  QueryDragIcon  *****  Give NT the icon handle to draw while dragging
'
SUB QueryDragIcon
	icon = windowInfo[window].icon
	hIcon = iconHandle[icon]
' PRINT "Drag Icon: "; window, icon, HEX$(hIcon,8)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN (hIcon)
END SUB
'
'
' *****  PaintIcon  *****
'
SUB PaintIcon
	hdc = windowInfo[window].hdc
	icon = windowInfo[window].icon
	hIcon = iconHandle[icon]
	IFZ hIcon THEN hIcon = iconHandle[0]
'
	IF hIcon THEN
		##LOCKOUT = $$TRUE
		BeginPaint (hwnd, &ps)
		DrawIcon (ps.hdc, 0, 0, hIcon)
		EndPaint (hwnd, &ps)
		##LOCKOUT = entryLOCKOUT
		EXIT SUB
	ELSE
		##LOCKOUT = $$TRUE
		val = DefWindowProcA (hwnd, NTmessage, wParam, lParam)
		##LOCKOUT = entryLOCKOUT
		##WHOMASK = entryWHOMASK
		RETURN (val)
	END IF
END SUB
'
'
' *****  EraseBackground  *****
'
SUB EraseBackground
'	isIconic = IsIconic (hwnd)
'	IF isIconic THEN
'		##WHOMASK = entryWHOMASK
'		RETURN (1)
'	ELSE
		##LOCKOUT = $$TRUE
		val = DefWindowProcA (hwnd, NTmessage, wParam, lParam)
		##LOCKOUT = entryLOCKOUT
		##WHOMASK = entryWHOMASK
		RETURN (val)
'	END IF
END SUB
'
'
'	*****  WindowRedraw  *****
'
SUB WindowRedraw
	isIconic = IsIconic(hwnd)
	IF isIconic THEN
		hdc = windowInfo[window].hdc
		icon = windowInfo[window].icon
		hIcon = iconHandle[icon]
		IFZ hIcon THEN hIcon = iconHandle[0]
'
		IF hIcon THEN											' draw icon assigned to window
'			##LOCKOUT = $$TRUE
			InvalidateRect (hwnd, 0, 0)
			hdc = GetDC (hwnd)
			DrawIcon (hdc, 0, 0, hIcon)
			ReleaseDC (hwnd, hdc)
			ValidateRect (hwnd, 0)
'			##LOCKOUT = entryLOCKOUT
			EXIT SUB
		ELSE															' windows draws blank square
			##LOCKOUT = $$TRUE
			val = DefWindowProcA (hwnd, NTmessage, wParam, lParam)
			##LOCKOUT = entryLOCKOUT
			##WHOMASK = entryWHOMASK
			RETURN (val)
		END IF
	END IF
'
	exists = GetUpdateRect (hwnd, &rect, $$FALSE)			' don't erase
	IFZ exists THEN
		ValidateRect (hwnd, 0)
		EXIT SUB
	END IF
'
'	NT bug?  If part of window offscreen, then resize it, update rect is all 0s
'		and ValidateRect generates another PAINT message (ad infinitum)
'
	IFZ (rect.left OR rect.top OR rect.right OR rect.bottom) THEN
		ValidateRect (hwnd, 0)
		EXIT SUB												' redraw whole window (clip nothing)
	END IF
'
	width = rect.right - rect.left
	height = rect.bottom - rect.top
'
	wingrid = window
	message = #WindowRedraw
	v0 = rect.left
	v1 = rect.top
	v2 = width
	v3 = height
	r1 = window
	GOSUB AddMessageToQueue
'
' The above puts a #WindowRedraw message in the queue.
' When XgrProcessMessages() processes #WindowRedraw it
' calls XgrRedrawWindow(), which:
'		1. Sets clip rectangle based on (v0,v1,v2,v3).
'		2. Sends #RedrawGrid messages to all exposed grids.
'		3. Erases clip rectangle to disable clipping.
'
' This method is different than, but hopefully compatible with
' UNIX versions.  The UNIX versions do not add a #WindowRedraw
' message at this point.  Instead, they add #RedrawGrid for all
' exposed grids.
'
'	XgrRedrawWindow (window, 0, v0, v1, v2, v3)	' queue #RedrawGrid messages
'
'	By experience:  Must validate with '0 (whole window)' if window extends
'		beyond screen, else PAINT commands go ad infinitum.
'	May want to use 0 in all cases, but will this will screw up
'		multiple PAINT messages.  Are they all merged or left separate?
'
	x = windowInfo[window].xDisp
	y = windowInfo[window].yDisp
	w = windowInfo[window].width
	h = windowInfo[window].height
'
	IF ((v0 < x) OR (v1 < y) OR (v0 + v2 >= x + w) OR (v1 + v3 >= y + h)) THEN
		ValidateRect (hwnd, 0)
	ELSE
		ValidateRect (hwnd, &rect)
	END IF
END SUB
'
'
'	*****  Resize  *****
'
SUB Resize
	IF (windowInfo[window].visible = $$WindowMinimized) THEN EXIT SUB
	width			= lParam{{16,0}}
	height		= lParam{{16,16}}
	oldWidth	= windowInfo[window].width
	oldHeight	= windowInfo[window].height
'
	IF (width = oldWidth) THEN
		IF (height = oldHeight) THEN EXIT SUB					' no size change
	END IF
'
'	Update windowInfo[]
'
	windowInfo[window].width = width
	windowInfo[window].height = height
'
	message = #WindowResized
	wingrid = window
	v0 = windowInfo[window].xDisp
	v1 = windowInfo[window].yDisp
	v2 = width
	v3 = height
	r1 = window
	GOSUB AddMessageToQueue
END SUB
'
'
'	*****  ShowWindow  *****  Window is ABOUT to be shown/hidden
'
SUB ShowWindow
'	PRINT "WinProc() : $$WM_SHOWWINDOW : "; hwnd;; HEX$(wParam,8);; HEX$(lParam,8);; window;;;
	wingrid = window : v1 = 0 : v2 = 0 : v3 = 0
	visible = windowInfo[window].visible
'
	IF wParam THEN
		IFZ lParam THEN
			v0 = visible
		ELSE
			v0 = $$WindowDisplayed
			IF (lParam == $$SW_PARENTCLOSING) THEN v0 = $$WindowMinimized
		END IF
		IF (v0 = $$WindowMinimized) THEN
			message = #WindowMinimized
		ELSE
			message = #WindowDisplayed
		END IF
	ELSE
		v0 = 0
		message = #WindowHidden
	END IF
'
	IF (message == #WindowDisplayed) THEN
		IF IsZoomed(hwnd) THEN message = #WindowMaximized
	END IF
'
	qqq = $$TRUE
	SELECT CASE message
		CASE #WindowHidden		:	' PRINT "#WindowHidden : "; v0;
														IF (visible = $$WindowHidden) THEN qqq = $$FALSE
		CASE #WindowDisplayed	: ' PRINT "#WindowDisplayed : "; v0;
														IF (visible = $$WindowDisplayed) THEN qqq = $$FALSE
		CASE #WindowMinimized	: ' PRINT "#WindowMinimized : "; v0;
														IF (visible = $$WindowMinimized) THEN qqq = $$FALSE
		CASE #WindowMaximized	: ' PRINT "#WindowMaximized : "; v0;
														IF (visible = $$WindowMaximized) THEN qqq = $$FALSE
	END SELECT
'
	IF qqq THEN
		r1 = wingrid
'		PRINT " : add to queue"
		windowInfo[window].visible = v0
		GOSUB AddMessageToQueue
	ELSE
'		PRINT
	END IF
END SUB
'
'
'	*****  SysCommand  *****
'
SUB SysCommand
	sysCommand = wParam AND 0xFFFFFFF0
'	PRINT "WinProc() : System Command : "; HEX$(sysCommand,8), HEX$(lParam,8), window, modalWindowUser, modalWindowSystem
	wt = windowInfo[window].windowType
	wingrid = window
	message = 0
	v0 = 0
	v1 = 0
	v2 = 0
	v3 = 0
	r1 = window
	SELECT CASE sysCommand
		CASE $$SC_CLOSE				: SELECT CASE TRUE
															CASE (wt AND $$WindowTypeCloseHide)
'																		PRINT "WinProc() : SysCommand : $$SC_CLOSE : call XgrHideWindow() : "; window
																		XgrHideWindow (window)
																		EXIT SUB
															CASE (wt AND $$WindowTypeCloseMinimize)
'																		PRINT "WinProc() : SysCommand : $$SC_CLOSE : call XgrMinimizeWindow() : "; window
																		XgrMinimizeWindow (window)
																		EXIT SUB
															CASE (wt AND $$WindowTypeCloseDestroy)
'																		PRINT "WinProc() : SysCommand : $$SC_CLOSE : queue #WindowDestroy : "; window
																		message = #WindowDestroy
																		GOSUB AddMessageToQueue
																		EXIT SUB
															CASE (wt AND $$WindowTypeCloseTerminate)
'																		PRINT "WinProc() : SysCommand : $$SC_CLOSE : queue #ExitMessageLoop : "; window
																		message = #ExitMessageLoop
																		GOSUB AddMessageToQueue
																		EXIT SUB
															CASE ELSE
'																		PRINT "WinProc() : SysCommand : $$SC_CLOSE : queue #WindowClose : "; window
																		message = #WindowClose
																		GOSUB AddMessageToQueue
																		EXIT SUB
														END SELECT
		CASE $$SC_MAXIMIZE		: ' PRINT "WinProc() : SysCommand : $$SC_MAXIMIZE : call XgrMaximizeWindow() : "; window
														IFZ (wt AND $$WindowTypeMaximizeButton) THEN
															message = #WindowMaximize
															GOSUB AddMessageToQueue
														ELSE
															XgrMaximizeWindow (window)
														END IF
														EXIT SUB
		CASE $$SC_MINIMIZE		: IF (window = modalWindowUser) THEN EXIT SUB
														IF (window = modalWindowSystem) THEN EXIT SUB
														' PRINT "WinProc() : SysCommand : $$SC_MINIMIZE : call XgrMinimizeWindow() : "; window
														IFZ (wt AND $$WindowTypeMinimizeButton) THEN
															message = #WindowMinimize
															GOSUB AddMessageToQueue
														ELSE
															XgrMinimizeWindow (window)
														END IF
														EXIT SUB
		CASE $$SC_NEXTWINDOW	: IF (window = modalWindowSystem) THEN EXIT SUB
														IF (window = modalWindowUser) THEN EXIT SUB
'														' PRINT "WinProc() : SysCommand : $$SC_NEXTWINDOW : call DefWindowProc() : "; window
		CASE $$SC_PREVWINDOW	: IF (window = modalWindowSystem) THEN EXIT SUB
														IF (window = modalWindowUser) THEN EXIT SUB
'														' PRINT "WinProc(): SysCommand: $$SC_PREVWINDOW : call DefWindowProc() : "; window
		CASE $$SC_RESTORE			: ' PRINT "WinProc() : SysCommand : $$SC_RESTORE : call XgrRestoreWindow() : "; window
														XgrRestoreWindow (window)
														EXIT SUB
	END SELECT
'
	##LOCKOUT = $$TRUE
	val = DefWindowProcA (hwnd, NTmessage, wParam, lParam)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN (val)
END SUB
'
'
'	*****  AddMessageToQueue  *****  (Same as XxxDispatchEvents subroutine)
'
'	userMessageQueue[] is a 1D array containing the user messages
'		It has a max size (1024).  Messages go in at userMessageQueueIn
'			and come out at userMessageQueueOut.
'		If the queue fills, wait till it is emptied completely before allowing
'			more messages to come in.  (This prevents choppy behavior that occurs
'			if messages pop in as the gap widens, halts till there is another gap.)
'
'	similar for systemMessageQueue[]
'
' *****  AddMessageToQueue  *****
'
SUB AddMessageToQueue
	IFZ windowInfo[window].whomask THEN
		GOSUB AddMessageToSystemQueue				' system queue
	ELSE
		GOSUB AddMessageToUserQueue					' user queue
	END IF
END SUB
'
' *****  AddMessageToSystemQueue  *****
'
SUB AddMessageToSystemQueue
	IF noMessagesTillSystemQueueEmptied THEN
		IF (systemMessageQueueOut != systemMessageQueueIn) THEN EXIT SUB
		noMessagesTillSystemQueueEmptied = $$FALSE
	END IF
'
'		If next systemMessageQueueIn = current systemMessageQueueOut:  queue is full
'
	nextMessageQueueIn = systemMessageQueueIn + 1
	IF (nextMessageQueueIn > UBOUND(systemMessageQueue[])) THEN
		nextMessageQueueIn = 0
	END IF
'
	IF (nextMessageQueueIn = systemMessageQueueOut) THEN
		noMessagesTillSystemQueueEmptied = $$TRUE				' queue full
		PRINT "WinProc:  System Message Queue full!!!"
		EXIT SUB
	END IF
'
	systemMessageQueue[systemMessageQueueIn].message	= message
	systemMessageQueue[systemMessageQueueIn].wingrid	= wingrid
	systemMessageQueue[systemMessageQueueIn].v0				= v0
	systemMessageQueue[systemMessageQueueIn].v1				= v1
	systemMessageQueue[systemMessageQueueIn].v2				= v2
	systemMessageQueue[systemMessageQueueIn].v3				= v3
	systemMessageQueue[systemMessageQueueIn].r0				= 0
	systemMessageQueue[systemMessageQueueIn].r1				= r1
	systemMessageQueueIn = nextMessageQueueIn
END SUB
'
' *****  AddMessageToUserQueue  *****
'
SUB AddMessageToUserQueue
	IF noMessagesTillUserQueueEmptied THEN
		IF (userMessageQueueOut != userMessageQueueIn) THEN EXIT SUB
		noMessagesTillUserQueueEmptied = $$FALSE
	END IF
'
'		If next userMessageQueueIn = current userMessageQueueOut:  queue is now full
'
	nextMessageQueueIn = userMessageQueueIn + 1
	IF (nextMessageQueueIn > UBOUND(userMessageQueue[])) THEN
		nextMessageQueueIn = 0
	END IF
'
	IF (nextMessageQueueIn = userMessageQueueOut) THEN
		noMessagesTillUserQueueEmptied = $$TRUE				' queue full
		PRINT "WinProc:  User Message Queue full!!!"
		EXIT SUB
	END IF
'
	userMessageQueue[userMessageQueueIn].message	= message
	userMessageQueue[userMessageQueueIn].wingrid	= wingrid
	userMessageQueue[userMessageQueueIn].v0				= v0
	userMessageQueue[userMessageQueueIn].v1				= v1
	userMessageQueue[userMessageQueueIn].v2				= v2
	userMessageQueue[userMessageQueueIn].v3				= v3
	userMessageQueue[userMessageQueueIn].r0				= 0
	userMessageQueue[userMessageQueueIn].r1				= r1
	userMessageQueueIn = nextMessageQueueIn
END SUB
'
'
'	*****  Init Arrays  *****
'
SUB InitArrays
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0
	DIM NTmessageType[$$WM_LASTMESSAGE]
	NTmessageType[ $$WM_KILLFOCUS					]	= SUBADDRESS (Focus)
	NTmessageType[ $$WM_MOUSEACTIVATE			] = SUBADDRESS (MouseActivate)
	NTmessageType[ $$WM_MOVE							]	= SUBADDRESS (Move)
	NTmessageType[ $$WM_PAINT							]	= SUBADDRESS (WindowRedraw)
	NTmessageType[ $$WM_PAINTICON					]	= SUBADDRESS (PaintIcon)
	NTmessageType[ $$WM_ERASEBKGND				] = SUBADDRESS (EraseBackground)
	NTmessageType[ $$WM_QUERYDRAGICON			]	= SUBADDRESS (QueryDragIcon)
	NTmessageType[ $$WM_SIZE							]	= SUBADDRESS (Resize)
	NTmessageType[ $$WM_SETFOCUS					]	= SUBADDRESS (Focus)
	NTmessageType[ $$WM_SHOWWINDOW				]	= SUBADDRESS (ShowWindow)
	NTmessageType[ $$WM_SYSCOMMAND				]	= SUBADDRESS (SysCommand)
	NTmessageType[ $$WM_NCMOUSEMOVE				]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCLBUTTONDOWN			]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCLBUTTONUP				]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCLBUTTONDBLCLK		]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCRBUTTONDOWN			]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCRBUTTONUP				]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCRBUTTONDBLCLK		]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCMBUTTONDOWN			]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCMBUTTONUP				]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_NCMBUTTONDBLCLK		]	= SUBADDRESS (MouseNC)
	NTmessageType[ $$WM_MOUSEWHEEL				]	= SUBADDRESS (MouseWheel)
'	PRINT "Arrays initialised"
	##WHOMASK = entryWHOMASK
END SUB
END FUNCTION
'
'
' ###########################
' #####  WindowInfo ()  #####
' ###########################
'
FUNCTION  WindowInfo (window, xDisp, yDisp, width, height)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	STATIC  RECT  rect
	STATIC  POINT  point
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hwnd = windowInfo[window].hwnd
	visible = windowInfo[window].visible
	point.x = 0
	point.y = 0
	##LOCKOUT = $$TRUE
	ClientToScreen (hwnd, &point)
	GetClientRect (hwnd, &rect)
	##LOCKOUT = entryLOCKOUT
'
	xDisp		= point.x
	yDisp		= point.y
	width		= rect.right - rect.left						' actually width/height
	height	= rect.bottom - rect.top
'
'	Take opportunity to update windowInfo stats
'
	windowInfo[window].xDisp	= xDisp
	windowInfo[window].yDisp	= yDisp
	windowInfo[window].width	= width
	windowInfo[window].height	= height
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ############################
' #####  GetClipText ()  #####
' ############################
'
FUNCTION  GetClipText (text$)
	$Text = 1
'
	text$ = ""															' default text$ is empty
	ok = OpenClipboard (0)									' open clipboard
	IFZ ok THEN RETURN											' clipboard unavailable
	handle = GetClipboardData ($Text)				' get clipboard data handle
	IFZ handle THEN CloseClipboard() : RETURN		' no text in clipboard
	addr = GlobalLock (handle)									' get address of text
	IFZ addr THEN CloseClipboard() : RETURN			' no text in clipboard
	upper = GlobalSize (handle)									' get upper bound of text$
	IF (upper <= 0) THEN CloseClipboard() : RETURN		' valid size ???
	text$ = NULL$ (upper)										' create return string
	d = -1																	' destination offset
	lastByte = 0														' nothing to start
	FOR s = 0 TO upper											' for whole loop
		byte = UBYTEAT (addr, s)							' get next byte
		IFZ byte THEN EXIT FOR								' done on null terminator
		IF (byte == '\n') THEN								' if this byte is a newline
			IF (lastByte == '\r') THEN DEC d		' overwrite if lastByte was a <cr>
		END IF																'
		INC d
		text${d} = byte												' byte to text string
		lastByte = byte												' lastByte = this byte
	NEXT s																	' next source byte
	text$ = LEFT$(text$,d+1)								' give text$ correct length
	GlobalUnlock (handle)
	CloseClipboard()												' release clipboard
END FUNCTION
'
'
' ############################
' #####  SetClipText ()  #####
' ############################
'
FUNCTION  SetClipText (text$)
	$Text = 1
'
	length = LEN(text$) << 1 + 1
	handle = GlobalAlloc (0x2002, length)
	addr = GlobalLock (handle)
	j = 0
	preByte = 0
	IFZ text$ THEN
		UBYTEAT (addr) = 0				' if text$ is an empty string
	ELSE
		FOR i = 0 TO LEN(text$)
			byte = text${i}
			UBYTEAT (addr,j) = byte
			IF (byte = '\n') THEN
				IF (preByte != '\r') THEN
					UBYTEAT (addr,j) = '\r' : INC j
					UBYTEAT (addr,j) = '\n'
				END IF
			END IF
			preByte = byte
			INC j
		NEXT i
	END IF
	GlobalUnlock (handle)
	OpenClipboard (0)
	EmptyClipboard ()
	SetClipboardData ($Text, handle)
	CloseClipboard ()
END FUNCTION
'
'
' ###########################
' #####  AlarmBlock ()  #####
' ###########################
'
'	Block alarm signals
'
'	In:				none
'	Out:			none
'	Return:		none
'
'	Discussion:
'		Sets alarmBlocked
'
FUNCTION  AlarmBlock ()
	SHARED  alarmBlocked
	AUTOX  signals$$

	IF alarmBlocked THEN RETURN
	alarmBlocked = $$TRUE
	RETURN

	signals$$ = 0x0004000000000000
'	SYSTEMCALL ($$SIGPROCMASK, $$SIG_BLOCK, &signals$$, 0)
	alarmBlocked = $$TRUE
END FUNCTION
'
'
' #############################
' #####  AlarmUnblock ()  #####
' #############################
'
'	Unblocks the alarm
'
'	In:				none
'	Out:			none
'	Return:		none
'
'	Discussion:
'		Resets alarmBlocked
'
FUNCTION  AlarmUnblock ()
	SHARED  alarmBlocked
	AUTOX  signals$$

	IFF alarmBlocked THEN RETURN
	alarmBlocked = $$FALSE
	RETURN

	signals$$ = 0x0004000000000000
'	SYSTEMCALL ($$SIGPROCMASK, $$SIG_UNBLOCK, &signals$$, 0)
	alarmBlocked = $$FALSE
END FUNCTION
'
'
' #################################
' #####  ConvertWinToGrid ()  #####
' #################################
'
'	Convert points in window coords to grid coords
'
'	In:				grid				Assumed Valid
'						npoints			number of points (x,y)
'						points[]		x1,y1,x2,y2,... in window coordinates
'
'	Out:			points[]		in grid coordinates
'
'	Return:		none
'
'	Discussion:
'		No clipping.
'
FUNCTION  ConvertWinToGrid (grid, npoints, points[])
	SHARED  GRIDINFO  gridInfo[]

	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1		' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2		' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	xIncreasesRight = $$TRUE
	IF (xLR < xUL) THEN xIncreasesRight = $$FALSE
'
	yIncreasesDown = $$TRUE
	IF (yLR < yUL) THEN yIncreasesDown = $$FALSE
'
	index = 0
	FOR i = 1 TO npoints
		IF xIncreasesRight THEN
			points[index] = xUL + (points[index] - xULWin)
		ELSE
			points[index] = xUL + (xULWin - points[index])
		END IF
'
		INC index
		IF yIncreasesDown THEN
			points[index] = yUL + (points[index] - yULWin)
		ELSE
			points[index] = yUL + (yULWin - points[index])
		END IF
'
		INC index
	NEXT i
END FUNCTION
'
'
' ###################################
' #####  ConvertWinToScaled ()  #####
' ###################################
'
'	Convert points in window coords to scaled coords
'
'	In:				grid				Assumed valid
'						npoints			number of points (x,y)
'						points[]		x1,y1,x2,y2,... in window coordinates
'
'	Out:			points#[]		in scaled coordinates
'
'	Return:		none
'
'	Discussion:
'		No clipping.
'
FUNCTION  ConvertWinToScaled (grid, npoints, points[], points#[])
	SHARED  GRIDINFO  gridInfo[]
'
	xULWin = gridInfo[grid].winBox.x1						' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1			' upper-left grid coordinate
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2			' lower-right grid coordinate
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xInvScale# = gridInfo[grid].xInvScale
	yInvScale# = gridInfo[grid].yInvScale
'
	index = 0
	FOR i = 1 TO npoints
		points#[index] = xUL# + (DOUBLE(points[index] - xULWin) * xInvScale#)
		INC index
		points#[index] = yUL# + (DOUBLE(points[index] - yULWin) * yInvScale#)
		INC index
	NEXT i
END FUNCTION
'
'
' ##################################
' #####  ConvertDIBto24Bit ()  #####
' ##################################
'
'	Convert 1,4,8-bit DIB image[] to DIB 24-bit RGB format
'
'	In:				image[]			in 1,4,8-bit DIB format ONLY
'	Out:			image[]			in 24-bit DIB RGB format
'
FUNCTION  ConvertDIBto24Bit (UBYTE image[])
	UBYTE  image24[]
'
	$BI_RGB       = 0					' 24-bit RGB
	$BI_BITFIELDS = 3					' 32-bit RGB
'
	iAddr = &image[]
'
	byte10 = image[10]
	byte11 = image[11]
	byte12 = image[12]
	byte13 = image[13]
'
	byte14 = image[14]
	byte15 = image[15]
	byte16 = image[16]
	byte17 = image[17]
'
	byte18 = image[18]
	byte19 = image[19]
	byte20 = image[20]
	byte21 = image[21]
'
	byte22 = image[22]
	byte23 = image[23]
	byte24 = image[24]
	byte25 = image[25]
'
	byte26 = image[26]
	byte27 = image[27]
'
	byte28 = image[28]
	byte29 = image[29]
'
	byte30 = image[30]
	byte31 = image[31]
'
	byte46 = image[46]
	byte47 = image[47]
	byte48 = image[48]
	byte49 = image[49]
'
	offBits = (byte13 << 24) OR (byte12 << 16) OR (byte11 << 8) OR byte10
	biSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14
	width = (byte21 << 24) OR (byte20 << 16) OR (byte19 << 8) OR byte18
	height = (byte25 << 24) OR (byte24 << 16) OR (byte23 << 8) OR byte22
	bitCount = (byte29 << 8) OR byte28
	clrUsed = (byte49 << 24) OR (byte48 << 16) OR (byte47 << 8) OR byte46
'
	paletteAddr = iAddr + 14 + biSize
	bitmapAddr = iAddr + offBits
'
'	get palette
'
	IFZ clrUsed THEN
		SELECT CASE bitCount
			CASE 1		: clrUsed = 2
			CASE 4		: clrUsed = 16
			CASE 8		: clrUsed = 256
			CASE ELSE	: xgrError = $$XgrInvalidArgument
									RETURN ($$TRUE)
		END SELECT
	END IF
'
	DIM palette[clrUsed - 1]
	pAddr = &palette[0]
	offset = 0
'
	FOR i = 0 TO clrUsed - 1
		UBYTEAT (pAddr, offset) = UBYTEAT (paletteAddr, offset) : INC offset
		UBYTEAT (pAddr, offset) = UBYTEAT (paletteAddr, offset) : INC offset
		UBYTEAT (pAddr, offset) = UBYTEAT (paletteAddr, offset) : INC offset
		INC offset
	NEXT i
'
'	Create the new array:  Dimension image24[]
'		54 bytes for header (no palette)
'		row = (width * 3) OR 3							' 1 byte each for RGB.  Multiple of 4
'		size = 54 + height * row						' bytes of data
'		words = (size >> 2) + 1							' 32-bit words
'
	dataOffset = 128
'
	row = ((width * 3) + 3) AND -4
	size = dataOffset + (height * row)
	upper = size - 1
	DIM image24[upper]
'
'	Fill header (non-assigned values are to be 0)
'
	iAddr24	= &image24[0]
'
	image24[0] = 'B'															' DIB aka BMP signature
	image24[1] = 'M'
	image24[2] = size AND 0x00FF									' file size
	image24[3] = (size >> 8) AND 0x00FF
	image24[4] = (size >> 16) AND 0x00FF
	image24[5] = (size >> 24) AND 0x00FF
	image24[6] = 0
	image24[7] = 0
	image24[8] = 0
	image24[9] = 0
	image24[10] = dataOffset AND 0x00FF						' file offset of bitmap data
	image24[11] = (dataOffset >> 8) AND 0x00FF
	image24[12] = (dataOffset >> 16) AND 0x00FF
	image24[13] = (dataOffset >> 24) AND 0x00FF
'
'	fill BITMAPINFOHEADER (first 6 members)
'
	info = 14
	image24[info+0] = 40													' XLONG : BITMAPINFOHEADER size
	image24[info+1] = 0
	image24[info+2] = 0
	image24[info+3] = 0
	image24[info+4] = width AND 0x00FF						' XLONG : width in pixels
	image24[info+5] = (width >> 8) AND 0x00FF
	image24[info+6] = (width >> 16) AND 0x00FF
	image24[info+7] = (width >> 24) AND 0x00FF
	image24[info+8] = height AND 0x00FF						' XLONG : height in pixels
	image24[info+9] = (height >> 8) AND 0x00FF
	image24[info+10] = (height >> 16) AND 0x00FF
	image24[info+11] = (height >> 24) AND 0x00FF
	image24[info+12] = 1													' USHORT : # of planes
	image24[info+13] = 0													'
	image24[info+14] = 24													' USHORT : bits per pixel
	image24[info+15] = 0													'
	image24[info+16] = $BI_RGB										' XLONG : 24-bit RGB
	image24[info+17] = 0													'
	image24[info+18] = 0													'
	image24[info+19] = 0													'
	image24[info+20] = 0													' XLONG : sizeImage
	image24[info+21] = 0													'
	image24[info+22] = 0													'
	image24[info+23] = 0													'
	image24[info+24] = 0													' XLONG : xPPM
	image24[info+25] = 0													'
	image24[info+26] = 0													'
	image24[info+27] = 0													'
	image24[info+28] = 0													' XLONG : yPPM
	image24[info+29] = 0													'
	image24[info+30] = 0													'
	image24[info+31] = 0													'
	image24[info+32] = 0													' XLONG : clrUsed
	image24[info+33] = 0													'
	image24[info+34] = 0													'
	image24[info+35] = 0													'
	image24[info+36] = 0													' XLONG : clrImportant
	image24[info+37] = 0													'
	image24[info+38] = 0													'
	image24[info+39] = 0													'
'
'	fill image
'
	bmOffset = bitmapAddr
	offset24 = dataOffset
	bitPtr = 0
'
	FOR j = 0 TO (height - 1)
		FOR i = 0 TO (width - 1)
			SELECT CASE bitCount
				CASE 1
							index = UBYTEAT(bmOffset) : INC bmOffset
							IFZ bitPtr THEN
								shortIndex = UBYTEAT(bmOffset)
								index = shortIndex{4,0}
								INC bitPtr
							ELSE
								index = shortIndex{4,bitPtr}
								INC bitPtr
								IF bitPtr{3,0} THEN								' next byte after 8 bits
									bitPtr = 0
									INC bmOffset
								END IF
							END IF
				CASE 4
							IFZ bitPtr THEN
								shortIndex = UBYTEAT(bmOffset)
								index = shortIndex{4,4}
								INC bitPtr
							ELSE
								index = shortIndex{4,0}
								bitPtr = 0												' next byte after 2 SHORTs
								INC bmOffset
							END IF
				CASE ELSE
							index = UBYTEAT(bmOffset):  INC bmOffset
			END SELECT
			color = palette[index]
'
			UBYTEAT (iAddr, offset24) = color{8,24}	: INC offset24
			UBYTEAT (iAddr, offset24) = color{8,16}	: INC offset24
			UBYTEAT (iAddr, offset24) = color{8,8}	: INC offset24
		NEXT i
'
		align = (bmOffset - bitmapAddr){2,0}							' ok if align = 0
		IF align THEN bmOffset = bmOffset + (4 - align)
		align = (offset24 - 54){2,0}											' ok if align = 0
		IF align THEN offset24 = offset24 + (4 - align)		' align 4
	NEXT j
'
	SWAP image[], image24[]
	DIM image24[]
END FUNCTION
'
'
' #################################
' #####  ConvertGridToWin ()  #####
' #################################
'
'	Convert points in grid coords to window coords
'
'	In:				grid				Assumed valid
'						npoints			number of points (x,y)
'						points[]		x1,y1,x2,y2,... in grid coordinates
'
'	Out:			points[]		in window coordinates
'
FUNCTION  ConvertGridToWin (grid, npoints, points[])
	SHARED  GRIDINFO  gridInfo[]
'
	xULWin = gridInfo[grid].winBox.x1		' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL = gridInfo[grid].gridBox.x1			' upper-left grid coordinate
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2			' lower-right grid coordinate
	yLR = gridInfo[grid].gridBox.y2
'
	xIncreasesRight = $$TRUE
	IF (xLR < xUL) THEN xIncreasesRight = $$FALSE
'
	yIncreasesDown = $$TRUE
	IF (yLR < yUL) THEN yIncreasesDown = $$FALSE
'
	index = 0
	FOR i = 1 TO npoints
		IF xIncreasesRight THEN
			points[index] = xULWin + (points[index] - xUL)
		ELSE
			points[index] = xULWin + (xUL - points[index])
		END IF
		INC index
'
		IF yIncreasesDown THEN
			points[index] = yULWin + (points[index] - yUL)
		ELSE
			points[index] = yULWin + (yUL - points[index])
		END IF
		INC index
	NEXT i
END FUNCTION
'
'
' ####################################
' #####  ConvertGridToScaled ()  #####
' ####################################
'
'	Convert points in grid coords to scaled coords
'
'	In:				grid				Assumed valid
'						npoints			number of points (x,y)
'						points[]		x1,y1,x2,y2,... in grid coordinates
'
'	Out:			points#[]		in scaled coordinates
'
'	Return:		none
'
'	Discussion:
'		No clipping.
'
FUNCTION  ConvertGridToScaled (grid, npoints, points[], points#[])
	SHARED  GRIDINFO  gridInfo[]
'
	xUL = gridInfo[grid].gridBox.x1						' grid xy of UL grid-box
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2						' grid xy of LR grid-box
	yLR = gridInfo[grid].gridBox.y2
	xUL# = gridInfo[grid].gridBoxScaled.x1		' scaled xy of UL grid-box
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2		' scaled xy of LR grid-box
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xInvScale# = gridInfo[grid].xInvScale			' sign: local/scale
	yInvScale# = gridInfo[grid].yInvScale
'
	index = 0
	FOR i = 1 TO npoints
		IF (xUL <= xLR) THEN
			points#[index] = xUL# + ((points[index] - xUL) * xInvScale#)
		ELSE
			points#[index] = xUL# + ((xUL - points[index]) * xInvScale#)
		END IF
		INC index
		IF (yUL <= yLR) THEN
			points#[index] = yUL# + ((points[index] - yUL) * yInvScale#)
		ELSE
			points#[index] = yUL# + ((yUL - points[index]) * yInvScale#)
		END IF
		INC index
	NEXT i
END FUNCTION
'
'
' ###################################
' #####  ConvertScaledToWin ()  #####
' ###################################
'
'	Convert points in scaled coords to window coords
'
'	In:				grid			Assumed valid
'						npoints		number of points (x,y)
'						points#[]	x1#,y1#,x2#,y2#,... in scaled coordinates
'
'	Out:			points[]	in window coordinates
'
'	Return:		none
'
'	Discussion:
'		No clipping.
'
FUNCTION  ConvertScaledToWin (grid, npoints, points[], points#[])
	SHARED  GRIDINFO  gridInfo[]

	xULWin = gridInfo[grid].winBox.x1					' window xy of UL grid-box
	yULWin = gridInfo[grid].winBox.y1
	xUL# = gridInfo[grid].gridBoxScaled.x1		' upper-left grid coordinate
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2		' lower-right grid coordinate
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xScale# = gridInfo[grid].xScale
	yScale# = gridInfo[grid].yScale
'
	index = 0
	FOR i = 1 TO npoints
		points[index] = xULWin + ((points#[index] - xUL#) * xScale#)
		INC index
		points[index] = yULWin + ((points#[index] - yUL#) * yScale#)
		INC index
	NEXT i
END FUNCTION
'
'
' ####################################
' #####  ConvertScaledToGrid ()  #####
' ####################################
'
'	Convert points in scaled coords to grid coords
'
'	In:				grid			Assumed valid
'						npoints		number of points (x,y)
'						points#[]	x1#,y1#,x2#,y2#,... in scaled coordinates
'
'	Out:			points[]	in grid coordinates
'
'	Return:		none
'
'	Discussion:
'		No clipping.
'
FUNCTION  ConvertScaledToGrid (grid, npoints, points[], points#[])
	SHARED  GRIDINFO  gridInfo[]
'
	xUL = gridInfo[grid].gridBox.x1					' grid xy of UL grid-box
	yUL = gridInfo[grid].gridBox.y1
	xLR = gridInfo[grid].gridBox.x2					' grid xy of LR grid-box
	yLR = gridInfo[grid].gridBox.y2
	xUL# = gridInfo[grid].gridBoxScaled.x1	' scaled xy of UL grid-box
	yUL# = gridInfo[grid].gridBoxScaled.y1
	xLR# = gridInfo[grid].gridBoxScaled.x2	' scaled xy of LR grid-box
	yLR# = gridInfo[grid].gridBoxScaled.y2
	xScale# = gridInfo[grid].xScale
	yScale# = gridInfo[grid].yScale
'
	index = 0
	FOR i = 1 TO npoints
		IF (xUL <= xLR) THEN
			points[index] = xUL + ((points#[index] - xUL#) * xScale#)
		ELSE
			points[index] = xUL - ((points#[index] - xUL#) * xScale#)
		END IF
		INC index
		IF (yUL <= yLR) THEN
			points[index] = yUL + ((points#[index] - yUL#) * yScale#)
		ELSE
			points[index] = yUL - ((points#[index] - yUL#) * yScale#)
		END IF
		INC index
	NEXT i
END FUNCTION
'
'
' ###############################
' #####  CreateSysImage ()  #####
' ###############################
'
'	Create sysImage (pixmap)
'
'	In:				imageGrid		ASSUMED VALID
'	Out:			sysImage
'	Return:		none
'
'	Discussion:
'		Assumed sysImage does not exist.
'		In XWindows, image and window used same GraphicsContext.
'		In Windows, memory images must have a memory DeviceContext (hdcImage).
'			We create ONE memory DC for the entire environment;  all window images
'				share this one DC.  I used to make a separate DC for each image grid
'				but this Blows 3.1 as it has a limited number of DCs.  (The window
'				DCs are OWNDC and (apparently) I can have as many as I want of these.)
'			Each image grid does have its own bitmap which is selected into the
'				the (sole) memory DC for drawing.
'			The memory DC values (pen/brush/font...) must be UPDATED to the current
'				ones for the window prior to every draw.
'
FUNCTION  CreateSysImage (imageGrid, sysImage)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  ntDrawMode[]
	SHARED  GT_Image
	STATIC  RECT  rect
'
	sysImage = 0
	IF (gridInfo[imageGrid].gridType != GT_Image) THEN RETURN
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window		= gridInfo[imageGrid].window
	hdc				= windowInfo[window].hdc
	width			= gridInfo[imageGrid].width
	height		= gridInfo[imageGrid].height
'
	##LOCKOUT = $$TRUE
	IFZ ntImageInfo.hdcImage THEN				' Create system-wide memory hdc
		hdcImage = CreateCompatibleDC (hdc)
		hBitmapTmp = CreateCompatibleBitmap (hdc, 1, 1)
		hBitmapOrig = SelectObject (hdcImage, hBitmapTmp)
		SelectObject (hdcImage, hBitmapOrig)
		DeleteObject (hBitmapTmp)
'
		fgBrushPixel = windowInfo[window].fgBrushPixel
		hNewBrush	= CreateSolidBrush (fgBrushPixel)
		hBrush = SelectObject (hdcImage, hNewBrush)
		DeleteObject (hBrush)
'
		fgPenPixel	= windowInfo[window].fgPenPixel
		lineStyle		= windowInfo[window].lineStyle
		lineWidth		= windowInfo[window].lineWidth
'
'		background mode (transparent or fill)
'
		backMode = lineStyle AND $$LineFill
		ntBackMode = $$TRANSPARENT
		IF backMode THEN ntBackMode = $$OPAQUE
		SetBkMode (hdcImage, ntBackMode)
'
'		style (NT style constants = Xgr values)
'
		style = lineStyle AND 0xF
		IFZ style THEN style = $$PS_INSIDEFRAME					' solid with dithering
'
		hNewPen	= CreatePen (style, lineWidth, fgPenPixel)
		hPen		= SelectObject (hdcImage, hNewPen)
		DeleteObject (hPen)
'
'		NEVER delete old fonts
'
		SelectObject (hdcImage, GetCurrentObject(hdc,$$OBJ_FONT))
'
		drawMode = windowInfo[window].drawMode
		SetROP2 (hdcImage, ntDrawMode[drawMode])
'
		bgPixel = windowInfo[window].bgPixel
		SetBkColor (hdcImage, bgPixel)
'
		textPixel = windowInfo[window].textPixel
		SetTextColor (hdcImage, textPixel)
'
		ntImageInfo.hdcImage			= hdcImage
		ntImageInfo.defaultBitmap	= hBitmapOrig
		ntImageInfo.drawMode			= drawMode
		ntImageInfo.lineWidth			= lineWidth
		ntImageInfo.lineStyle			= lineStyle
		ntImageInfo.font					= windowInfo[window].font
		ntImageInfo.bgPixel				= bgPixel
		ntImageInfo.fgBrushPixel	= fgBrushPixel
		ntImageInfo.fgBrush				= hNewBrush
		ntImageInfo.fgPenPixel		= fgPenPixel
		ntImageInfo.fgPen					= hNewPen
		ntImageInfo.textPixel			= textPixel
		ntImageInfo.clipGrid			= 0
		ntImageInfo.clipGridImage	= 0
		ntImageInfo.xClip					= 0
		ntImageInfo.yClip					= 0
		ntImageInfo.clipWidth			= 0
		ntImageInfo.clipHeight		= 0
		ntImageInfo.clipIsNull		= $$FALSE
	END IF
'
'	Don't Delete old bitmap--it belongs to someone else
'
	hdcImage = ntImageInfo.hdcImage
	hBitmap = CreateCompatibleBitmap (hdc, width, height)
	hBrush = GetStockObject ($$BLACK_BRUSH)
	SelectObject (hdcImage, hBitmap)
	ntImageInfo.hBitmap		= hBitmap
	rect.left		= 0
	rect.top		= 0
	rect.right	= width
	rect.bottom	= height
	FillRect (hdcImage, &rect, hBrush)
'
	ntImageInfo.window		= window
	ntImageInfo.imageGrid	= imageGrid
'
	sysImage = hBitmap
	gridInfo[imageGrid].sysImage = sysImage
'
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ############################
' #####  ClosestGrid ()  #####
' ############################
'
'	Get the closest grid to xWin/yWin in window
'
'	in			: window, xWin, yWin
'	return	: grid (closest to xWin, yWin - including xWin, yWin)
'
'		Look at all grids in this window (except coord/image/disabled grids)
'			a) (xWin,yWin) must be within grid
'			b) closest grid
'						grid whose left is closest - in case of ties...
'						grid whose top is closest - in case of ties...
'						grid whose width is less - in case of ties...
'						grid whose height is less - in case of ties...
'						grid that is child (especially of other possibilities)
'
FUNCTION  ClosestGrid (window, xWin, yWin)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  winGrid[]
'
	IFZ window THEN RETURN (0)
	IFZ winGrid[window,] THEN RETURN (0)
'
	closestGrid = 0
	closestParent = 0
	closestX1 = 0x80000000
	closestY1 = 0x80000000
	closestX2 = 0x7FFFFFFF
	closestY2 = 0x7FFFFFFF
'
	uWinGrid = UBOUND(winGrid[window,])					' grids active for window
	FOR i = 0 TO uWinGrid
		grid = winGrid[window,i]
		IFZ grid THEN DO NEXT
		IF (gridInfo[grid].gridType <= 1) THEN DO NEXT		' ignore coord/image grids
		IF gridInfo[grid].disabled THEN DO NEXT						' mouse events disabled
		parent = gridInfo[grid].parentGrid
'
		xULWin = gridInfo[grid].winBox.x1
		IF (xWin < xULWin) THEN DO NEXT					' LR of UL
		yULWin = gridInfo[grid].winBox.y1
		IF (yWin < yULWin) THEN DO NEXT

		xLRWin = gridInfo[grid].winBox.x2
		IF (xWin > xLRWin) THEN DO NEXT					' UL of LR
		yLRWin = gridInfo[grid].winBox.y2
		IF (yWin > yLRWin) THEN DO NEXT
'
' contained in this grid
'
		IF (xWin < closestX1) THEN DO NEXT			' left edge further left
		IF (yWin < closestY1) THEN DO NEXT			' top edge further up
		IF (xWin > closestX2) THEN DO NEXT			' right edge further right
		IF (yWin > closestY2) THEN DO NEXT			' bottom edge further down
'
' better or equal choice to best so far
'
		IF (xWin > closestX1) THEN GOSUB Closest
		IF (yWin > closestY1) THEN GOSUB Closest
		IF (xWin < closestX2) THEN GOSUB Closest
		IF (yWin < closestY2) THEN GOSUB Closest
'
' equal to best choice so far - choose child or most recent
'
		IFZ closestParent THEN							' old has no parent
			GOSUB Closest											' choose new
			DO NEXT
		ELSE
			IFZ parent THEN DO NEXT						' old has parent, new doesn't
			IF (parent = closestParent) THEN	' same parent ?
				GOSUB Closest										' choose new
				DO NEXT
			END IF
			IF (parent = closestGrid) THEN		' new child of old ?
				GOSUB Closest										' yes, choose new
				DO NEXT
			END IF
			IF (grid != closestParent) THEN		' old child of new ?
				GOSUB Closest										' no, choose new
				DO NEXT
			END IF
		END IF
	NEXT i
	RETURN (closestGrid)
'
'
' *****  Closest  *****
'
SUB Closest
	closestParent = parent
	closestGrid = grid
	closestX1 = xULWin
	closestY1 = yULWin
	closestX2 = xLRWin
	closestY2 = yLRWin
END SUB
END FUNCTION
'
'
' ################################
' #####  DestroySysImage ()  #####
' ################################
'
'	Destroy sysImage (hBitmap)
'
'	In:				grid				assumed GT_Image
'						sysImage		assumed valid
'	Out:			none
'	Return:		none
'
'	Discussion:
'		Assumed sysImage exists (so memory hdc exists).
'		See CreateSysImage()
'
FUNCTION  DestroySysImage (grid, sysImage)
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo

	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE

	hdcImage = ntImageInfo.hdcImage
	IFZ hdcImage THEN RETURN											' Huh?
	IF (sysImage = ntImageInfo.hBitmap) THEN			' hBitmap must not be in hdc
		defaultBitmap = ntImageInfo.defaultBitmap
		SelectObject (hdcImage, defaultBitmap)
		ntImageInfo.hBitmap = defaultBitmap
	END IF
	DeleteObject (sysImage)
	gridInfo[grid].sysImage = 0

	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##############################
' #####  InvalidWindow ()  #####
' ##############################
'
'	Test the validity of window
'
'	In:				window
'
'	Out:			none			args unchanged
'
'	Return:		$$FALSE		valid window
'						$$TRUE		invalid
'
FUNCTION  InvalidWindow (window)
	SHARED  xgrError
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  xgrInitialized

	IFF xgrInitialized THEN														' Xgr() initialized
		xgrError = $$XgrNotInitialized
		EXIT FUNCTION ($$TRUE)
	END IF
	IFZ windowInfo[] THEN															' Window initialized
		xgrError = $$XgrWindowUndefined
		EXIT FUNCTION ($$TRUE)
	END IF
	IF ((window <= 0) OR (window > UBOUND(windowInfo[]))) THEN		' Valid window
		xgrError = $$XgrWindowUndefined
		EXIT FUNCTION ($$TRUE)
	END IF
	IFZ windowInfo[window].host THEN									' Window initialized
		xgrError = $$XgrWindowUndefined
		EXIT FUNCTION ($$TRUE)
	END IF
END FUNCTION
'
'
' ############################
' #####  InvalidGrid ()  #####
' ############################
'
'	Test the validity of grid
'
'	In:				grid
'
'	Out:			none			args unchanged
'
'	Return:		$$FALSE		valid grid
'						$$TRUE		invalid
'
FUNCTION  InvalidGrid (grid)
	SHARED  xgrError
	SHARED  GRIDINFO  gridInfo[]
	SHARED  xgrInitialized

	IFF xgrInitialized THEN																		' Xgr() initialized
		xgrError = $$XgrNotInitialized
		EXIT FUNCTION ($$TRUE)
	END IF
	IFZ gridInfo[] THEN																				' grid initialized
		xgrError = $$XgrGridUndefined
		EXIT FUNCTION ($$TRUE)
	END IF
	IF ((grid <= 0) OR (grid > UBOUND(gridInfo[]))) THEN			' Valid grid
		xgrError = $$XgrGridUndefined
		EXIT FUNCTION ($$TRUE)
	END IF
	IFZ gridInfo[grid].grid THEN															' Grid initialized
		xgrError = $$XgrGridUndefined
		EXIT FUNCTION ($$TRUE)
	END IF
END FUNCTION
'
'
' ##########################
' #####  LoadFonts ()  #####
' ##########################
'
FUNCTION  LoadFonts (hdc)
	SHARED  LOGFONT  bitFontInfo[]
	SHARED  LOGFONT  sysFontInfo[]
	SHARED  bitFontNames$[]
	SHARED  sysFontNames$[]
	SHARED  bitFontNames
	SHARED  sysFontNames
'
	IF sysFontInfo[] THEN RETURN ($$FALSE)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = 0
'
	DIM sysFontNames$[]
	DIM bitFontNames$[]
	bitFontNames = 0
	sysFontNames = 0
	##LOCKOUT = $$TRUE
	EnumFontFamiliesA (hdc, 0, &LoadFontsCallback(), 0)
	##LOCKOUT = lockout
'
	IF bitFontNames THEN
		REDIM bitFontInfo[bitFontNames-1]
		REDIM bitFontNames$[bitFontNames-1]
	END IF
'
	IFZ sysFontNames THEN
		##WHOMASK = whomask
		RETURN ($$FALSE)
	END IF
'
	uFontNames = sysFontNames-1
	REDIM sysFontNames$[uFontNames]
	REDIM sysFontInfo$[uFontNames]
	##WHOMASK = whomask
	RETURN ($$FALSE)
'
'	FOR i = 0 TO uFontNames
'		PRINT CSTRING$(&sysFontInfo[i].faceName),,sysFontNames$[i]
'		PRINT sysFontInfo[i].height
'		PRINT sysFontInfo[i].width
'		PRINT sysFontInfo[i].escapement
'		PRINT sysFontInfo[i].orientation
'		PRINT sysFontInfo[i].weight
'		PRINT sysFontInfo[i].italic
'		PRINT sysFontInfo[i].underline
'		PRINT sysFontInfo[i].strikeOut
'		PRINT sysFontInfo[i].charSet
'		PRINT sysFontInfo[i].outPrecision
'		PRINT sysFontInfo[i].clipPrecision
'		PRINT sysFontInfo[i].quality
'		PRINT sysFontInfo[i].pitchAndFamily
'	NEXT i
END FUNCTION
'
'
' ##################################
' #####  LoadFontsCallback ()  #####
' ##################################
'
'	Load available font names and info from Windows
'		Callback function for EnumFontFamiliesA() called from
'			LoadFonts()
'
'	In:				LOGFONT  logFont
'						newTextMetricAddr
'						fontType
'						action
'	Out:			none
'	Return:		none
'
FUNCTION  LoadFontsCallback (LOGFONT logFont, newTextMetricAddr, fontType, action)
	SHARED  LOGFONT  bitFontInfo[]
	SHARED  LOGFONT  sysFontInfo[]
	SHARED  bitFontNames$[]
	SHARED  sysFontNames$[]
	SHARED  bitFontNames
	SHARED  sysFontNames
'
	$BitmapTypeFont = 1
	$DeviceTypeFont = 2
	$TrueTypeFont   = 4
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = $$FALSE
'
	SELECT CASE fontType
		CASE $DeviceTypeFont
'					PRINT "LoadFontsCallback:  SKIP  "; CSTRING$(&logFont.faceName)
'		CASE $BitmapTypeFont
'					upper = UBOUND (bitFontNames$[])
'					IF (upper < bitFontNames) THEN
'						upper = upper + 16
'						DIM bitFontInfo[upper]
'						DIM bitFontNames$[upper]
'					END IF
'					bitFontInfo[bitFontNames] = logFont
'					bitFontNames$[bitFontNames] = CSTRING$(&logFont.faceName)
'					INC bitFontNames
		CASE $BitmapTypeFont, $TrueTypeFont
					IFZ sysFontInfo[] THEN
						DIM sysFontInfo[15]
						DIM sysFontNames$[15]
					ELSE
						uInfo = UBOUND(sysFontInfo[])
						IF (sysFontNames >= uInfo) THEN
							uInfo = uInfo + 64
							REDIM sysFontInfo[uInfo]
							REDIM sysFontNames$[uInfo]
						END IF
					END IF
					sysFontInfo[sysFontNames] = logFont
					sysFontNames$[sysFontNames]	= CSTRING$(&logFont.faceName)
					INC sysFontNames
	END SELECT
'
	##WHOMASK = whomask
	RETURN (1)
END FUNCTION
'
'
' ####################
' #####  Log ()  #####
' ####################
'
FUNCTION  Log (message$)
	STATIC	enter
	STATIC	length
	STATIC	console
'
	GOTO logFile
	IFZ console THEN
		XstGetConsoleGrid (@console)
		XgrRegisterMessage (@"Print", @#Print)
	END IF
'
	m$ = message$
	length = length + LEN (message$)
'
	IF (length > 72) THEN
		m$ = "\n" + m$
		length = LEN (message$)
	END IF
	XgrSendMessage (console, #Print, 0, 0, 0, 0, 0, @m$)
	RETURN
'
' old way (didn't work cause break-out polluted data with extra trash)
'
logFile:
	IFZ enter THEN
		ofile = OPEN ("log.log", $$WRNEW)
	ELSE
		ofile = OPEN ("log.log", $$WR)
	END IF
	enter = $$TRUE
'
	IF (ofile > 0) THEN
		end = LOF (ofile)
		end = SEEK (ofile, end)
		PRINT [ofile], message$;
		length = length + LEN (message$)
		IF (length > 72) THEN length = 0 : PRINT [ofile]
		CLOSE (ofile)
	END IF
END FUNCTION
'
'
' ############################
' #####  OpenDisplay ()  #####
' ############################
'
' Return host index for display$
'
'	In:				display$			display name to open
'													""   for default display
'
'	Out:			display$			Return defaultDisplayName$ if display$ = ""
'
'	Return:		host					host index (1,2,...)
'						0							error
'
'	Discussion:
'		Multiple host displays for WindowsNT are not yet supported.
'			Does return new host for each different display$, but all refer
'				to the main display.
'			This is left in to maintain capability already established in X-Windows
'				and to establish display information.
'
'		If the display is already open, just return the host index
'
'		First call on a display:
'			- return 0 if display doesn't exist
'			- open the display
'
FUNCTION  OpenDisplay (display$)
	SHARED  DISPLAYINFO hostDisplay[]
	SHARED  hostDisplayName$[]
	SHARED  hostWin[]
	SHARED  alarmBlocked
	STATIC  RECT  rect
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
'	Is display already open?  (Only one screen per display is supported)
'
	displayOpen = $$FALSE
	IF hostDisplayName$[] THEN
'
'		strip screen number from display name (if present)
'
		FOR i = 1 TO UBOUND(hostDisplayName$[])
			IF (display$ = hostDisplayName$[i]) THEN
				displayOpen = $$TRUE
				host = i
				EXIT FOR
			END IF
		NEXT i
	END IF
'
	IF displayOpen THEN
		##WHOMASK = entryWHOMASK
		RETURN (host)
	END IF
'
	entryAlarmBlock = alarmBlocked
	IFF alarmBlocked THEN AlarmBlock ()
'
'	Find a slot for the new display
'
	IFZ hostDisplay[] THEN
		uHost = 1
		DIM hostDisplayName$[uHost]
		DIM hostDisplay[uHost]
		DIM hostWin[uHost,]
		host = 1
	ELSE
		uHost = UBOUND(hostDisplay[])
		FOR host = 1 TO uHost
			IFZ hostDisplay[host] THEN EXIT FOR
		NEXT host
		IF (host > uHost) THEN
			INC uHost
			host = uHost
			REDIM hostDisplay[uHost]
			REDIM hostDisplayName$[uHost]
			REDIM hostWin[uHost,]
		END IF
	END IF
'
'	Determine border sizes
'		OVERLAPPEDWINDOW:  THICKFRAME + BORDER + CAPTION
'			borderWidth = THICKFRAME + BORDER (all 4 sides)
'			titleHeight = CAPTION only
'
	rect.left		= 0								' use window with width = 100
	rect.top		= 0
	rect.right	= 100							' actually width/height
	rect.bottom	= 100
	AdjustWindowRectEx (&rect, $$WS_OVERLAPPEDWINDOW, 0, 0)
	w = rect.right - rect.left
	h = rect.bottom - rect.top
	borderWidth	= (w - 100) >> 1
	titleHeight	= h - 100 - (borderWidth << 1)
'
	hostDisplayName$[host]								= display$
	hostDisplay[host].status							= 1								' initialized
	hostDisplay[host].displayWidth 				= GetSystemMetrics ($$SM_CXSCREEN)
	hostDisplay[host].displayHeight				= GetSystemMetrics ($$SM_CYSCREEN)
	hostDisplay[host].borderWidth					= borderWidth
	hostDisplay[host].titleHeight					= titleHeight
	hostDisplay[host].selectedWindow			= 0
	hostDisplay[host].mouseWindowHwnd			= 0
	hostDisplay[host].mouseWindow					= 0
	hostDisplay[host].mouseState					= 0
	hostDisplay[host].mouseXDisp					= 0
	hostDisplay[host].mouseYDisp					= 0
	hostDisplay[host].grabMouseFocusGrid	= 0
	hostDisplay[host].gridMouseInside			= 0
'
	IFZ entryAlarmBlock THEN AlarmUnblock ()
	##WHOMASK = entryWHOMASK
	RETURN (host)
END FUNCTION
'
'
' ##################################
' #####  RedrawGridAndKids ()  #####
' ##################################
'
FUNCTION  RedrawGridAndKids (grid, action, xWin, yWin, width, height)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED	gridTypeName$[]
	SHARED  winGrid[]
	SHARED  GT_Image
'
	IF InvalidGrid (grid) THEN RETURN ($$TRUE)
'
	window = gridInfo[grid].window
	gridType = gridInfo[grid].gridType
	IF (gridType = GT_Image) THEN RETURN ($$FALSE)
	IF gridInfo[grid].disabled THEN RETURN ($$FALSE)
'
	IF InvalidWindow (window) THEN RETURN ($$TRUE)
	IFZ winGrid[window,] THEN RETURN ($$FALSE)
'
	x1Win = xWin
	y1Win = yWin
	x2Win = xWin + width - 1
	y2Win = yWin + height - 1
	gx1 = gridInfo[grid].winBox.x1
	gy1 = gridInfo[grid].winBox.y1
	gx2 = gridInfo[grid].winBox.x2
	gy2 = gridInfo[grid].winBox.y2
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
	IFZ exposed THEN
'		Beep (2000,20)
'		ofile = OPEN ("bogus.txt", $$WR)
'		lof = LOF (ofile)
'		SEEK (ofile, lof)
'		gridType$ = gridTypeName$[gridType]
'		PRINT [ofile], grid;; gridType$, xWin; yWin; width; height, x1Win; y1Win; x2Win; y2Win, gx1; gy1; gx2; gy2, x1; y1; x2; y2, ww;; hh
'		CLOSE (ofile)
		RETURN ($$FALSE)
	END IF
'
' send or queue a #RedrawGrid to the grid itself
'
	IF gridInfo[grid].bufferGrid THEN
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
	FOR i = 0 TO UBOUND (winGrid[window,])
		g = winGrid[window,i]
		IF g THEN
			IF (grid = gridInfo[g].parentGrid) THEN
				IFZ gridInfo[g].disabled THEN
					IFZ action THEN
						RedrawGridAndKids (g, action, 0, 0, 0, 0)
					ELSE
						RedrawGridAndKids (g, action, xWin, yWin, width, height)
					END IF
				END IF
			END IF
		END IF
	NEXT i
END FUNCTION
'
'
' ###############################
' #####  ReturnGridClip ()  #####
' ###############################
'
'	Remove clip region, but return clip area for this window/grid
'
'	In:				window			ASSUMED VALID
'						clipGrid		clipGrid  ASSUMED VALID
'	Out:			x						clipping area
'						y
'						width
'						height
'	Return:		none
'
'	Discussion:
'		Used by Image routines (XgrCopyImage, XgrDrawImage, ...)
'		These don't use a clip region, but limit the BitBlt() area
'			by the clipping xywh (speed)
'		This routine wastes the clipping region (including the
'			Redraw window clip region).  Functions calling ReturnGridClip
'			must call SetGridClip(window,0) when done to reestablish
'			window clip region.  (See XgrCopyImage)
'
FUNCTION  ReturnGridClip (window, clipGrid, x, y, width, height)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	hdc = windowInfo[window].hdc
	w		= windowInfo[window].clipWidth
	clipGridOld = windowInfo[window].clipGrid
'
	IF (w || clipGridOld) THEN		' Remove clip region if there
		entryWHOMASK = ##WHOMASK
		entryLOCKOUT = ##LOCKOUT
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		SelectClipRgn (hdc, 0)
		##LOCKOUT = entryLOCKOUT
		##WHOMASK = entryWHOMASK
	END IF
'
	windowInfo[window].clipGrid		= 0						' no clip grid
	windowInfo[window].clipIsNull	= $$FALSE
'
	x = 0:  y = 0:  width = 0:  height = 0
	IFZ clipGrid THEN
		IFZ w THEN RETURN
	END IF
'
	IF w THEN
		x = windowInfo[window].xClip
		y = windowInfo[window].yClip
		width = w
		height = windowInfo[window].clipHeight
		IF clipGrid THEN
			x2 = x + width - 1
			y2 = y + height - 1
			xc1 = gridInfo[clipGrid].winBox.x1
			yc1 = gridInfo[clipGrid].winBox.y1
			xc2 = xc1 + gridInfo[clipGrid].width - 1
			yc2 = yc1 + gridInfo[clipGrid].height - 1
			IF ((xc1 > x2) OR (xc2 < x)) THEN GOTO ClipAll
			IF ((yc1 > y2) OR (yc2 < y)) THEN GOTO ClipAll
'
			IF (x < xc1) THEN x = xc1
			IF (xc2 < x2) THEN x2 = xc2
			IF (y < yc1) THEN y = yc1
			IF (yc2 < y2) THEN y2 = yc2
			width = x2 - x + 1
			height = y2 - y + 1
		END IF
	ELSE
		x = gridInfo[clipGrid].winBox.x1
		y = gridInfo[clipGrid].winBox.y1
		width = gridInfo[clipGrid].width
		height = gridInfo[clipGrid].height
	END IF
	RETURN
'
ClipAll:
	x = 0:  y = 0:  width = 0:  height = 0
	windowInfo[window].clipIsNull = $$TRUE
	RETURN
END FUNCTION
'
'
' ############################
' #####  SetGridClip ()  #####
' ############################
'
'	Set clip mode/size for this window
'
'	In:				window			ASSUMED VALID
'						clipGrid		new clipGrid  ASSUMED VALID
'	Out:			none
'	Return:		none
'
'	Discussion:
'		clipGrid = 0 is used by XgrRedrawWindow to set redraw clip window
'
'		I might be able to optimize this better by keeping track of the
'			active clip region.
'
FUNCTION  SetGridClip (window, clipGrid)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hdc = windowInfo[window].hdc
	w		= windowInfo[window].clipWidth
'
	windowInfo[window].clipGrid		= clipGrid
	windowInfo[window].clipIsNull	= $$FALSE
'
	IFZ clipGrid THEN
		IFZ w THEN
			##LOCKOUT = $$TRUE
			SelectClipRgn (hdc, 0)										' no clipping
			##LOCKOUT = entryLOCKOUT
			##WHOMASK = entryWHOMASK
			RETURN
		END IF
	END IF
'
	IF w THEN
		x1 = windowInfo[window].xClip
		y1 = windowInfo[window].yClip
		x2 = x1 + w - 1
		y2 = y1 + windowInfo[window].clipHeight - 1
		IF clipGrid THEN
			xc1 = gridInfo[clipGrid].winBox.x1
			yc1 = gridInfo[clipGrid].winBox.y1
			xc2 = xc1 + gridInfo[clipGrid].width - 1
			yc2 = yc1 + gridInfo[clipGrid].height - 1
			IF ((xc1 > x2) OR (xc2 < x1)) THEN GOTO ClipAll
			IF ((yc1 > y2) OR (yc2 < y1)) THEN GOTO ClipAll
'
			IF (x1 < xc1) THEN x1 = xc1
			IF (xc2 < x2) THEN x2 = xc2
			IF (y1 < yc1) THEN y1 = yc1
			IF (yc2 < y2) THEN y2 = yc2
		END IF
	ELSE
		x1 = gridInfo[clipGrid].winBox.x1
		y1 = gridInfo[clipGrid].winBox.y1
		x2 = x1 + gridInfo[clipGrid].width - 1
		y2 = y1 + gridInfo[clipGrid].height - 1
	END IF
'
'	CreateRectRgn doesn't include right/bottom edges, so add 1
'
	##LOCKOUT = $$TRUE
	hrgn = CreateRectRgn (x1, y1, x2 + 1, y2 + 1)
	SelectClipRgn (hdc, hrgn)											' makes copy
	DeleteObject (hrgn)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN
'
ClipAll:
	windowInfo[window].clipIsNull = $$TRUE
	##WHOMASK = entryWHOMASK
	RETURN
END FUNCTION
'
'
' #############################
' #####  SetGridClip2 ()  #####
' #############################
'
'	Set clip mode/size for grid and clipGrid
'
'	In:				window			ASSUMED VALID
'						grid				ASSUMED VALID
'	Out:			x						clipping area
'						y
'						width
'						height
'	Return:		none
'
'	Discussion:
'		Used by XgrCopyImage(), XgrRefreshImage()
'		See SetGridClip()
'		clipGrid = 0 is used by XgrRedrawWindow to set redraw clip window
'
FUNCTION  SetGridClip2 (window, grid, x, y, width, height)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	hdc	= windowInfo[window].hdc
	w		= windowInfo[window].clipWidth
	IFZ grid THEN
		IFZ w THEN
			##LOCKOUT = $$TRUE
			SelectClipRgn (hdc, 0)						' no clipping
			##LOCKOUT = entryLOCKOUT
			##WHOMASK = entryWHOMASK
			x				= 0
			y				= 0
			width		= windowInfo[window].width
			height	= windowInfo[window].height
			windowInfo[window].clipGrid = 0
			RETURN ($$FALSE)
		END IF
	END IF
'
	xw1	= windowInfo[window].xClip
	yw1	= windowInfo[window].yClip
	h		= windowInfo[window].clipHeight
	IF w THEN
		x1 = xw1
		y1 = yw1
		x2 = xw1 + w - 1
		y2 = yw1 + h - 1
	ELSE
		x1 = 0																		' no clipping
		y1 = 0
		x2 = windowInfo[window].width - 1
		y2 = windowInfo[window].height - 1
	END IF
'
	IF grid THEN
		xc1 = gridInfo[grid].winBox.x1
		yc1 = gridInfo[grid].winBox.y1
		xc2 = xc1 + gridInfo[grid].width - 1
		yc2 = yc1 + gridInfo[grid].height - 1
		IF ((xc1 > x2) OR (xc2 < x1)) THEN GOTO ClipAll
		IF ((yc1 > y2) OR (yc2 < y1)) THEN GOTO ClipAll
'
		IF (x1 < xc1) THEN x1 = xc1
		IF (xc2 < x2) THEN x2 = xc2
		IF (y1 < yc1) THEN y1 = yc1
		IF (yc2 < y2) THEN y2 = yc2
'
		clipGrid = gridInfo[grid].clipGrid
		IF clipGrid THEN
			xc1 = gridInfo[clipGrid].winBox.x1
			yc1 = gridInfo[clipGrid].winBox.y1
			xc2 = xc1 + gridInfo[clipGrid].width - 1
			yc2 = yc1 + gridInfo[clipGrid].height - 1
			IF ((xc1 > x2) OR (xc2 < x1)) THEN GOTO ClipAll
			IF ((yc1 > y2) OR (yc2 < y1)) THEN GOTO ClipAll
'
			IF (x1 < xc1) THEN x1 = xc1
			IF (xc2 < x2) THEN x2 = xc2
			IF (y1 < yc1) THEN y1 = yc1
			IF (yc2 < y2) THEN y2 = yc2
		END IF
	END IF
'
	x				= x1
	y				= y1
	width		= x2 - x1 + 1
	height	= y2 - y1 + 1
'
'	CreateRectRgn doesn't include right/bottom edges, so add 1
'
	##LOCKOUT = $$TRUE
	hrgn = CreateRectRgn (x1, y1, x2 + 1, y2 + 1)
	SelectClipRgn (hdc, hrgn)									' makes copy
	DeleteObject (hrgn)
	##LOCKOUT = entryLOCKOUT
'
	windowInfo[window].clipGrid = grid
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
ClipAll:
	x = 0
	y = 0
	width = 0
	height = 0
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ############################
' #####  SetDrawMode ()  #####
' ############################
'
'	Set drawing mode for this window
'
'	In:				window
'						drawMode
'
'	Out:			none				arg unaltered
'
'	Return:		none
'
FUNCTION  SetDrawMode (window, drawMode)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  ntDrawMode[]
'
	IF (windowInfo[window].drawMode != drawMode) THEN
		entryWHOMASK = ##WHOMASK
		entryLOCKOUT = ##LOCKOUT
		##WHOMASK = 0
'
		hdc = windowInfo[window].hdc
		##LOCKOUT = $$TRUE
		result = SetROP2 (hdc, ntDrawMode[drawMode])
		##LOCKOUT = entryLOCKOUT
		windowInfo[window].drawMode = drawMode
		##WHOMASK = entryWHOMASK
	END IF
END FUNCTION
'
'
' ################################
' #####  SetGridBrushPen ()  #####
' ################################
'
'		Set hdc brush and pen to grid color
'
'	In:		grid			ASSUMED VALID
'				color
'	Out:	none			args unchanged
'
'	Discussion:
'		Does NOT override gridInfo color
'		Used in XgrFillBox... routines which uses Rectangle()
'			Pen is set to SOLID, 1 wide, Black
'
FUNCTION  SetGridBrushPen (grid, color)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  colorPixel[]
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	hdc = windowInfo[window].hdc
'
	colorIndex = color{$$ColorNumber}
	SELECT CASE FALSE
		CASE (NOT color)														' color = -1:  use old value
			pixel = gridInfo[grid].sysDrawing
		CASE colorIndex															' x = 0:  use RGB
			pixel = (color{$$B} << 16) OR (color{$$G} << 8) OR color{$$R}
		CASE ELSE																		' x != 0:  use 1-124
			IF (colorIndex > 124) THEN colorIndex = 124
			pixel = colorPixel[colorIndex]
	END SELECT
'
	IF (pixel != windowInfo[window].fgBrushPixel) THEN
		##LOCKOUT	= $$TRUE
		hNewBrush	= CreateSolidBrush (pixel)
		hBrush		= SelectObject (hdc, hNewBrush)
		DeleteObject (hBrush)
		##LOCKOUT	= entryLOCKOUT
'
		windowInfo[window].fgBrushPixel	= pixel
		windowInfo[window].fgBrush			= hNewBrush
	END IF
'
'	Skip it if current window attributes are already correct
'
	IF (windowInfo[window].fgPenPixel != pixel) THEN GOTO change
	IF (windowInfo[window].lineStyle != $$LineSolid) THEN
		IF (windowInfo[window].lineStyle != $$LineFill) THEN GOTO change
	END IF
	IF (windowInfo[window].lineWidth != 1) THEN GOTO change
	##WHOMASK = entryWHOMASK
	RETURN
'
change:
'
'	style (NT style constants = Xgr values)
'
	style = $$PS_INSIDEFRAME												' solid with dithering
	IFZ (windowInfo[window].lineStyle AND $$LineFill) THEN
		windowInfo[window].lineStyle = $$LineSolid
	ELSE
		windowInfo[window].lineStyle = $$LineFill
		bgPixel = gridInfo[grid].sysBackground
		IF (bgPixel != windowInfo[window].bgPixel) THEN
			##LOCKOUT = $$TRUE
			SetBkColor (hdc, bgPixel)
			##LOCKOUT = entryLOCKOUT
			windowInfo[window].bgPixel = bgPixel
		END IF
	END IF
'
'	Line width
'
	lineWidth = 1
	windowInfo[window].lineWidth = lineWidth
'
	##LOCKOUT	= $$TRUE
	hNewPen	= CreatePen (style, lineWidth, pixel)
	hPen		= SelectObject (hdc, hNewPen)
	DeleteObject (hPen)
	##LOCKOUT	= entryLOCKOUT
'
	windowInfo[window].fgPenPixel		= pixel
	windowInfo[window].fgPen				= hNewPen
'
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' #############################
' #####  SetImageClip ()  #####
' #############################
'
'	Set clip mode/size for this image
'
'	In:				window			ASSUMED VALID
'						clipGrid		new clipGrid  ASSUMED VALID
'						imageGrid		ASSUMED VALID
'	Out:			none
'	Return:		none
'
'	Discussion:
'		See SetGridClip()
'		clipGrid = 0 is used by XgrRedrawWindow to set redraw clip window
'		ntImageInfo is already set up for this window.
'			We are just adding clipping.
'
FUNCTION  SetImageClip (window, clipGrid, imageGrid)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
'
	clipGridImage	= gridInfo[imageGrid].clipGrid
	hdcImage			= ntImageInfo.hdcImage
	xw1	= windowInfo[window].xClip
	yw1	= windowInfo[window].yClip
	w		= windowInfo[window].clipWidth
	h		= windowInfo[window].clipHeight
	IF (clipGrid = ntImageInfo.clipGrid) THEN
		IF (clipGridImage = ntImageInfo.clipGridImage) THEN
			IFZ (w OR ntImageInfo.clipWidth) THEN
				RETURN ($$FALSE)										' No changes
			END IF
			same =					(xw1 = ntImageInfo.xClip)
			same = same &&	(yw1 = ntImageInfo.yClip)
			same = same &&	(w   = ntImageInfo.clipWidth)
			same = same &&	(h   = ntImageInfo.clipHeight)
			IF same THEN RETURN ($$FALSE)					' No changes
		END IF
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	ntImageInfo.clipGrid			= clipGrid
	ntImageInfo.clipGridImage	= clipGridImage
	ntImageInfo.xClip					= xw1
	ntImageInfo.yClip					= yw1
	ntImageInfo.clipWidth			= w
	ntImageInfo.clipHeight		= h
	ntImageInfo.clipIsNull		= $$FALSE
'
	IFZ clipGrid THEN
		IFZ clipGridImage THEN
			IFZ w THEN
				##LOCKOUT = $$TRUE
				SelectClipRgn (hdcImage, 0)						' no clipping
				##LOCKOUT = entryLOCKOUT
				##WHOMASK = entryWHOMASK
				RETURN ($$FALSE)
			END IF
		END IF
	END IF
'
	IF w THEN
		x1 = xw1
		y1 = yw1
		x2 = xw1 + w - 1
		y2 = yw1 + h - 1
	ELSE
		x1 = 0																		' no clipping
		y1 = 0
		x2 = windowInfo[window].width - 1
		y2 = windowInfo[window].height - 1
	END IF
'
	IF clipGrid THEN
		xc1 = gridInfo[clipGrid].winBox.x1
		yc1 = gridInfo[clipGrid].winBox.y1
		xc2 = xc1 + gridInfo[clipGrid].width - 1
		yc2 = yc1 + gridInfo[clipGrid].height - 1
		IF ((xc1 > x2) OR (xc2 < x1)) THEN GOTO ClipAll
		IF ((yc1 > y2) OR (yc2 < y1)) THEN GOTO ClipAll

		IF (x1 < xc1) THEN x1 = xc1
		IF (xc2 < x2) THEN x2 = xc2
		IF (y1 < yc1) THEN y1 = yc1
		IF (yc2 < y2) THEN y2 = yc2
	END IF
'
	IF clipGridImage THEN
		xc1 = gridInfo[clipGridImage].winBox.x1
		yc1 = gridInfo[clipGridImage].winBox.y1
		xc2 = xc1 + gridInfo[clipGridImage].width - 1
		yc2 = yc1 + gridInfo[clipGridImage].height - 1
		IF ((xc1 > x2) OR (xc2 < x1)) THEN GOTO ClipAll
		IF ((yc1 > y2) OR (yc2 < y1)) THEN GOTO ClipAll

		IF (x1 < xc1) THEN x1 = xc1
		IF (xc2 < x2) THEN x2 = xc2
		IF (y1 < yc1) THEN y1 = yc1
		IF (yc2 < y2) THEN y2 = yc2
	END IF
'
'	Translate to sysImage coordinates
'
	xImage = gridInfo[imageGrid].winBox.x1
	yImage = gridInfo[imageGrid].winBox.y1
	dx = 0 - xImage									' UL window is (0,0)
	dy = 0 - yImage
	x1 = x1 + dx:		y1 = y1 + dy
	x2 = x2 + dx:		y2 = y2 + dy
'
'	CreateRectRgn doesn't include right/bottom edges, so add 1
'
	##LOCKOUT = $$TRUE
	hrgn = CreateRectRgn (x1, y1, x2 + 1, y2 + 1)
	SelectClipRgn (hdcImage, hrgn)									' makes copy
	DeleteObject (hrgn)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
'
ClipAll:
	ntImageInfo.clipIsNull = $$TRUE
	##WHOMASK = entryWHOMASK
	RETURN ($$FALSE)
END FUNCTION
'
'
' ##################################
' #####  SetLineAttributes ()  #####
' ##################################
'
'	Set color, mode, style, width
'
'	In:				grid				grid whose parameters are to be set (ASSUMED VALID)
'						color
'	Out:			none				arg unaltered
'	Return:		none
'
'	Discussion:
'		Color
'		Mode:		$$DrawCOPY,  $$DrawXOR,  $$DrawAND
'		Style:	$$LineSolid,  $$LineOnOffDash,  $$LineDoubleDash
'		Width
'
FUNCTION  SetLineAttributes (grid, color)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  colorPixel[]
	SHARED  ntDrawMode[]
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window = gridInfo[grid].window
	hdc = windowInfo[window].hdc
'
'	Set draw mode
'
	drawMode = gridInfo[grid].drawMode
	IF (windowInfo[window].drawMode != drawMode) THEN
		##LOCKOUT = $$TRUE
		result = SetROP2 (hdc, ntDrawMode[drawMode])
		##LOCKOUT = entryLOCKOUT
		windowInfo[window].drawMode = drawMode
	END IF
'
'	Set background color
'
	bgPixel = gridInfo[grid].sysBackground
	IF (bgPixel != windowInfo[window].bgPixel) THEN
		##LOCKOUT = $$TRUE
		SetBkColor (hdc, bgPixel)
		##LOCKOUT = entryLOCKOUT
		windowInfo[window].bgPixel = bgPixel
	END IF
'
'	Get pixel for this color
'
	colorIndex = color{$$ColorNumber}
	SELECT CASE FALSE
		CASE (NOT color)														' color = -1:  use old value
			pixel = gridInfo[grid].sysDrawing
		CASE colorIndex															' x = 0:  use RGB
			pixel = (color{$$B} << 16) OR (color{$$G} << 8) OR color{$$R}
		CASE ELSE																		' x != 0:  use 1-124
			IF (colorIndex > 124) THEN colorIndex = 124
			pixel = colorPixel[colorIndex]
	END SELECT
'
'	Skip it if current window attributes are already correct
'
	IF (windowInfo[window].fgPenPixel != pixel) THEN GOTO change
	IF (windowInfo[window].lineStyle != gridInfo[grid].lineStyle) THEN GOTO change
	IF (windowInfo[window].lineWidth != gridInfo[grid].lineWidth) THEN GOTO change
	##WHOMASK = entryWHOMASK
	RETURN

change:
'
'	background mode (transparent or fill)
'
	windowLineStyle	= windowInfo[window].lineStyle
	lineStyle = gridInfo[grid].lineStyle
	windowInfo[window].lineStyle = lineStyle
'
	backMode = lineStyle AND $$LineFill
	IF (backMode != (windowLineStyle AND $$LineFill)) THEN
		ntBackMode = $$TRANSPARENT
		IF backMode THEN ntBackMode = $$OPAQUE
		##LOCKOUT = $$TRUE
		SetBkMode (hdc, ntBackMode)
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	style (NT style constants = Xgr values)
'
	style = lineStyle AND 0xF
	IFZ style THEN style = $$PS_INSIDEFRAME					' solid with dithering
'
'	Line width
'
	lineWidth	= gridInfo[grid].lineWidth
	windowInfo[window].lineWidth = lineWidth
'
	##LOCKOUT	= $$TRUE
	hNewPen	= CreatePen (style, lineWidth, pixel)
	hPen		= SelectObject (hdc, hNewPen)
	DeleteObject (hPen)
	##LOCKOUT	= entryLOCKOUT
'
	windowInfo[window].fgPenPixel		= pixel
	windowInfo[window].fgPen				= hNewPen
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ###################################
' #####  SetPointAttributes ()  #####
' ###################################
'
'	Set color, mode, style, width
'
'	In:				grid				grid whose parameters are to be set (ASSUMED VALID)
'						color
'	Out:			none				arg unaltered
'	Return:		none
'
'	Discussion:
'		Color
'		Mode:		$$DrawCOPY,  $$DrawXOR,  $$DrawAND
'		Style:	$$LineSolid
'		Width:	1
'
'		WindowsNT has no SetPoints function.  Use PolyPolyline for speed
'			To use line for a point, width = 1, style = solid
'
FUNCTION  SetPointAttributes (grid, color)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  colorPixel[]
	SHARED  ntDrawMode[]
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window	= gridInfo[grid].window
	hdc			= windowInfo[window].hdc
'
'	Set draw mode
'
	drawMode = gridInfo[grid].drawMode
	IF (windowInfo[window].drawMode != drawMode) THEN
		##LOCKOUT = $$TRUE
		SetROP2 (hdc, ntDrawMode[drawMode])
		##LOCKOUT = entryLOCKOUT
		windowInfo[window].drawMode = drawMode
	END IF
'
'	Get pixel for this color
'
	colorIndex = color{$$ColorNumber}
	SELECT CASE FALSE
		CASE (NOT color)														' color = -1:  use old value
			pixel = gridInfo[grid].sysDrawing
		CASE colorIndex															' x = 0:  use RGB
			pixel = (color{$$B} << 16) OR (color{$$G} << 8) OR color{$$R}
		CASE ELSE																		' x != 0:  use 1-124
			IF (colorIndex > 124) THEN colorIndex = 124
			pixel = colorPixel[colorIndex]
	END SELECT
'
'	Skip it if current window attributes are already correct
'
	IF (windowInfo[window].fgPenPixel != pixel) THEN GOTO change
	IF (windowInfo[window].lineStyle != $$LineSolid) THEN GOTO change
	IF (windowInfo[window].lineWidth != 1) THEN GOTO change
	##WHOMASK = entryWHOMASK
	RETURN
'
change:
'
'	background mode (transparent or fill)
'
	windowLineStyle	= windowInfo[window].lineStyle
	lineStyle = $$LineSolid
	windowInfo[window].lineStyle = lineStyle
'
	backMode = 0																	' No fill
	IF (backMode != (windowLineStyle AND $$LineFill)) THEN
		ntBackMode = $$TRANSPARENT
		##LOCKOUT = $$TRUE
		SetBkMode (hdc, ntBackMode)
		##LOCKOUT = entryLOCKOUT
	END IF
'
'	style (NT style constants = Xgr values)
'
	style = $$PS_INSIDEFRAME											' solid with dithering
'
'	Line width
'
	lineWidth	= 1
	windowInfo[window].lineWidth = lineWidth
'
	##LOCKOUT	= $$TRUE
	hNewPen	= CreatePen (style, lineWidth, pixel)
	hPen		= SelectObject (hdc, hNewPen)
	DeleteObject (hPen)
	##LOCKOUT	= entryLOCKOUT
'
	windowInfo[window].fgPenPixel		= pixel
	windowInfo[window].fgPen				= hNewPen
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ##################################
' #####  SetTextAttributes ()  #####
' ##################################
'
'	Set color, mode, style
'
'	In:				grid		grid whose parameters are to be set (ASSUMED VALID)
'						color
'           style
'	Out:			none		args unaltered
'	Return:		none
'
'	Discussion:
'		Color
'		Mode:		$$DrawCOPY,  $$DrawXOR,  $$DrawAND
'		Style:	$$LineSolid, $$LineFill
'
FUNCTION  SetTextAttributes (grid, color, style)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  FONTINFO  fontInfo[]
	SHARED  colorPixel[]
	SHARED  ntDrawMode[]
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	window	= gridInfo[grid].window
	hdc			= windowInfo[window].hdc
'
'	Set font
'
	font = gridInfo[grid].font
	IF (windowInfo[window].font != font) THEN
'
'		DO NOT destroy old hFont!  It is maintained in XBasic until
'			the task is destroyed!!!
'
		##LOCKOUT = $$TRUE
		SelectObject (hdc, fontInfo[font].hFont)
		##LOCKOUT = entryLOCKOUT
		windowInfo[window].font = font
	END IF
'
'	Set draw mode
'
	drawMode = gridInfo[grid].drawMode
	IF (windowInfo[window].drawMode != drawMode) THEN
		##LOCKOUT = $$TRUE
		SetROP2 (hdc, ntDrawMode[drawMode])
		##LOCKOUT = entryLOCKOUT
		windowInfo[window].drawMode = drawMode
	END IF
'
'	Get pixel for this color
'
	colorIndex = color{$$ColorNumber}
	SELECT CASE FALSE
		CASE (NOT color)														' color = -1:  use old value
'			log$ = "a: "
			pixel = gridInfo[grid].sysDrawing
		CASE colorIndex															' x = 0:  use RGB
'			log$ = "b: "
			pixel = (color{$$B} << 16) OR (color{$$G} << 8) OR color{$$R}
		CASE ELSE																		' x != 0:  use 1-124
'			log$ = "c: "
			IF (colorIndex > 124) THEN colorIndex = 124
			pixel = colorPixel[colorIndex]
	END SELECT
'
'	Text color
'
'	log$ = log$ + HEX$(window,4) + ":" + HEX$(grid,4) + " : " + HEX$(hdc,8) + " : " + HEX$(color,8) + " :: " + HEX$(colorIndex,2) + " : " + HEX$(pixel,8) + " : " + HEX$(windowInfo[window].textPixel,8)
	IF (windowInfo[window].textPixel != pixel) THEN
		##LOCKOUT = $$TRUE
		old = SetTextColor (hdc, pixel)
		##LOCKOUT = entryLOCKOUT
		windowInfo[window].textPixel = pixel
'		log$ = log$ + " ==> " + HEX$(windowInfo[window].textPixel,8) + " <== " + HEX$(old,8)
	END IF
'	XstLog (@log$)
'
'	Background mode
'
	windowLineStyle	= windowInfo[window].lineStyle
	IF ((windowLineStyle AND $$LineFill) != style) THEN
		ntBackMode = $$TRANSPARENT
		IF style THEN ntBackMode = $$OPAQUE
		##LOCKOUT = $$TRUE
		SetBkMode (hdc, ntBackMode)
		##LOCKOUT = entryLOCKOUT
		windowInfo[window].lineStyle = windowLineStyle AND (NOT $$LineFill) OR style
	END IF
'
'	Background color
'
	IF style THEN
		bgPixel = gridInfo[grid].sysBackground
		IF (bgPixel != windowInfo[window].bgPixel) THEN
			##LOCKOUT = $$TRUE
			SetBkColor (hdc, bgPixel)
			##LOCKOUT = entryLOCKOUT
			windowInfo[window].bgPixel = bgPixel
		END IF
	END IF
'
'	PRINT "Draw mode    = "; GetROP2(hdc)
'	PRINT "  Back mode  = "; GetBkMode (hdc)
'	PRINT "  Text color = "; HEX$(GetTextColor(hdc), 8)
'	PRINT "  Back color = "; HEX$(GetBkColor(hdc), 8)
'
	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ###############################
' #####  SetWindowBrush ()  #####
' ###############################
'
'		Set hdc brush and pen to window color
'
'	In:		window		ASSUMED VALID
'				color
'	Out:	none			args unchanged
'
FUNCTION  SetWindowBrush (window, color)
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  colorPixel[]

	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0

	hdc = windowInfo[window].hdc
	colorIndex = color{$$ColorNumber}
	SELECT CASE FALSE
		CASE (NOT color)														' color = -1:  use old value
			pixel = windowInfo[window].winPixel

		CASE colorIndex															' x = 0:  use RGB
			pixel = (color{$$B} << 16) OR (color{$$G} << 8) OR color{$$R}
			windowInfo[window].winPixel = pixel

		CASE ELSE																		' x != 0:  use 1-124
			IF (colorIndex > 124) THEN colorIndex = 124
			pixel = colorPixel[colorIndex]
			windowInfo[window].winPixel = pixel
	END SELECT

	IF (pixel != windowInfo[window].fgBrushPixel) THEN
		##LOCKOUT	= $$TRUE
		hNewBrush	= CreateSolidBrush (pixel)
		hBrush		= SelectObject (hdc, hNewBrush)
		DeleteObject (hBrush)
		##LOCKOUT	= entryLOCKOUT

		windowInfo[window].fgBrushPixel	= pixel
		windowInfo[window].fgBrush			= hNewBrush
	END IF

	##WHOMASK = entryWHOMASK
END FUNCTION
'
'
' ###############################
' #####  UpdateSysImage ()  #####
' ###############################
'
'	Update sysImage (pixmap)
'
'	In:				imageGrid		ASSUMED VALID
'	Out:			none
'	Return:		none
'
'	Discussion:
'		Assumed sysImage exists (implies memory hdc exists).
'		See CreateSysImage().
'
FUNCTION  UpdateSysImage (imageGrid)
	SHARED  DISPLAYINFO  hostDisplay[]
	SHARED  WINDOWINFO  windowInfo[]
	SHARED  GRIDINFO  gridInfo[]
	SHARED  NTIMAGEINFO  ntImageInfo
	SHARED  ntDrawMode[]
	SHARED  GT_Image
'
	IF (gridInfo[imageGrid].gridType != GT_Image) THEN RETURN
	sysImage = gridInfo[imageGrid].sysImage			' hBitmap
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
'
	window = gridInfo[imageGrid].window
	hdc = windowInfo[window].hdc
	hdcImage = ntImageInfo.hdcImage
'
'	Put imageGrid's bitmap into memory hdc
'		(Don't Delete old bitmap--it belongs to another imageGrid)
'
	IF (sysImage != ntImageInfo.hBitmap) THEN
		SelectObject (hdcImage, sysImage)
		ntImageInfo.hBitmap = sysImage
	END IF
'
	lineStyle = windowInfo[window].lineStyle
	lineStyleImage = ntImageInfo.lineStyle
'
'	Every hdc must have its own pen/brush so they can be destroyed
'		independently when a change is made.
'
	GOSUB UpdateBrushPen
'
'	DO NOT destroy old hFont !!!
'	It is maintained internally until the task is destroyed !!!
'
	font = windowInfo[window].font
	IF (ntImageInfo.font != font) THEN
		SelectObject (hdcImage, GetCurrentObject(hdc,$$OBJ_FONT))
		ntImageInfo.font = font
	END IF
'
	drawMode = windowInfo[window].drawMode
	IF (ntImageInfo.drawMode != drawMode) THEN
		SetROP2 (hdcImage, ntDrawMode[drawMode])
		ntImageInfo.drawMode = drawMode
	END IF
'
	bgPixel = windowInfo[window].bgPixel
	IF (bgPixel != ntImageInfo.bgPixel) THEN
		SetBkColor (hdcImage, bgPixel)
		ntImageInfo.bgPixel = bgPixel
	END IF
'
	textPixel = windowInfo[window].textPixel
	IF (ntImageInfo.textPixel != textPixel) THEN
		SetTextColor (hdcImage, textPixel)
		ntImageInfo.textPixel = textPixel
	END IF
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN
'
'
'	*****  UpdateBrushPen  *****
'
SUB UpdateBrushPen
'
'	Update brush
'
	fgBrushPixel = windowInfo[window].fgBrushPixel
	IF (fgBrushPixel != ntImageInfo.fgBrushPixel) THEN
		hNewBrush = CreateSolidBrush (fgBrushPixel)
		hBrush = SelectObject (hdcImage, hNewBrush)
		DeleteObject (hBrush)
		ntImageInfo.fgBrush = hNewBrush
		ntImageInfo.fgBrushPixel = fgBrushPixel
	END IF
'
'	Update pen
'
	fgPenPixel = windowInfo[window].fgPenPixel
	lineStyle = windowInfo[window].lineStyle
	lineWidth = windowInfo[window].lineWidth
	IF (ntImageInfo.lineWidth = lineWidth) THEN
		IF (ntImageInfo.lineStyle = lineStyle) THEN
			IF (ntImageInfo.fgPenPixel = fgPenPixel) THEN		' no changes
				EXIT SUB
			END IF
		END IF
	END IF
'
'	background mode (transparent or fill)
'
	lineStyleImage = ntImageInfo.lineStyle
	backMode = lineStyle AND $$LineFill
	IF (backMode != (lineStyleImage AND $$LineFill)) THEN
		ntBackMode = $$TRANSPARENT
		IF backMode THEN ntBackMode = $$OPAQUE
		SetBkMode (hdcImage, ntBackMode)
	END IF
'
'	style (NT style constants = Xgr values)
'
	style = lineStyle AND 0xF
	IFZ style THEN style = $$PS_INSIDEFRAME					' solid with dithering

	hNewPen = CreatePen (style, lineWidth, fgPenPixel)
	hPen = SelectObject (hdcImage, hNewPen)
	DeleteObject (hPen)

	ntImageInfo.fgPenPixel = fgPenPixel
	ntImageInfo.lineWidth = lineWidth
	ntImageInfo.lineStyle = lineStyle
	ntImageInfo.fgPen = hNewPen
END SUB
END FUNCTION
'
'
' ##############################
' #####  XgrShowColors ()  #####
' ##############################
'
'	NEEDS TO BE REWRITTEN FOR 125 COLORS
'
'	Show the XBasic standard 216 colors in the specified grid
'
'	In:				grid
'
'	Out:			none			args unchanged
'
'	Return:		$$FALSE		no errors
'						$$TRUE		error
'
'	Discussion:
'		- Clone a new grid for drawing, destroy it when done
'
FUNCTION  XgrShowColors (grid)

	IF InvalidGrid (grid) THEN RETURN ($$TRUE)

	XgrGetGridWindow (grid, @window)
	XgrGetGridPositionAndSize (grid, @xWin, @yWin, @w, @h)
	XgrCloneGrid (grid, @newGrid, window, 0, xWin, yWin)
	XgrClearGrid (newGrid, $$Black)

	XgrGetGridBox (newGrid, @x1, @y1, @x2, @y2)
	width = ABS(x2 - x1) + 1
	height = ABS(y2 - y1) + 1
'
'	binSize = size of each color bin
'	border	= number of pixels for xy borders
'	boxSize = size of 36 bin box
'
	IF ((width <= 540) OR (height <= 360)) THEN
		small		= $$TRUE
		xBinMin	= width \ 18
		yBinMin	= height \ 12
		binSize	= MIN (xBinMin, yBinMin)
		xBorder = 0
		yBorder = 0
	ELSE
		small		= $$FALSE
		xBinMin	= (width  - 60) \ 18
		yBinMin	= (height - 40) \ 12
		binSize	= MIN (xBinMin, yBinMin)
		xBorder	= (width - (binSize * 18)) >> 1
		yBorder	= (height - (binSize * 12)) >> 1
	END IF
	boxSize = binSize * 6
'
'	Arrange 6 boxes (one for each red color)
'		Pattern:  0  1  2			xBorder on left, right
'							3  4  5			yBorder on top, middle, bottom
'
	DIM xUL[5]
	DIM yUL[5]
	x = xWin	+ xBorder:		xUL[0] = x:  xUL[3] = x
	x = x			+ boxSize:		xUL[1] = x:  xUL[4] = x
	x = x			+ boxSize:		xUL[2] = x:  xUL[5] = x
	y = yWin	+ yBorder:		yUL[0] = y:  yUL[1] = y:  yUL[2] = y
	y = y			+ boxSize:		yUL[3] = y:  yUL[4] = y:  yUL[5] = y

	XgrSetGridBox				(newGrid, 0, boxSize, boxSize, 0)
	XgrSetGridBoxScaled	(newGrid, 0#, 6#, 6#, 0#)
'
'	Blue label
'
	XgrSetGridPositionAndSize (newGrid, xUL[3], yUL[3], -1, -1)
	XgrMoveToScaled (newGrid, 0, -.25)
	XgrDrawText (newGrid, $$Blue, "Blue ->")
'
'	Green label
'
	green$ = "neerG |"
	FOR i = 1 TO LEN(green$)
		y# = DOUBLE(i - 1) * .2
		XgrMoveToScaled (newGrid, -.2, y#)
		XgrDrawText (newGrid, $$Green, MID$(green$, i, 1))
	NEXT i
	XgrMoveToScaled (newGrid, -.2, y#)
	XgrDrawText (newGrid, $$Green, "^")

	GOTO colorConstants
'
'	125 colors
'
	red = 0x0000
	FOR ir = 0 TO 4
		XgrSetGridPositionAndSize (newGrid, xUL[ir], yUL[ir], -1, -1)

		IF (ir <= 2) THEN
			XgrMoveToScaled (newGrid, 4.2, 6.1)
		ELSE
			XgrMoveToScaled (newGrid, 4.2, -.25)
		END IF
		XgrDrawText (newGrid, $$Red, "Red = " + HEXX$(red,4))

		green = 0x0000
		FOR ig = 0 TO 4
			blue = 0x0000
			FOR ib = 0 TO 4
				XgrConvertRGBToColor (red, green, blue, @color)
				XgrFillBoxScaled (newGrid, color, ib, ig, ib + 1, ig + 1)
				blue = blue + 0x4000
				IF (blue > 0xFFFF) THEN blue = 0xFFFF
			NEXT ib
			green = green + 0x4000
			IF (green > 0xFFFF) THEN green = 0xFFFF
		NEXT ig
		red = red + 0x4000
		IF (red > 0xFFFF) THEN red = 0xFFFF
	NEXT ir

	XgrDestroyGrid (newGrid)

	RETURN ($$FALSE)
'
'	216 colors
'
	red = 0x0000
	FOR ir = 0 TO 5
		XgrSetGridPositionAndSize (newGrid, xUL[ir], yUL[ir], -1, -1)

		IF (ir <= 2) THEN
			XgrMoveToScaled (newGrid, 4.2, 6.1)
		ELSE
			XgrMoveToScaled (newGrid, 4.2, -.25)
		END IF
		XgrDrawText (newGrid, $$Red, "Red = " + HEXX$(red,4))

		green = 0x0000
		FOR ig = 0 TO 5
			blue = 0x0000
			FOR ib = 0 TO 5
				XgrConvertRGBToColor (red, green, blue, @color)
				XgrFillBoxScaled (newGrid, color, ib, ig, ib + 1, ig + 1)
				blue = blue + 0x3333
			NEXT ib
			green = green + 0x3333
		NEXT ig
		red = red + 0x3333
	NEXT ir

	XgrDestroyGrid (newGrid)

	RETURN ($$FALSE)
'
' Color Constants
'
colorConstants:
	DIM x$[255]:  DIM x[255]
	FOR i = 0 TO 255
		x$[i] = "": x[i] = 0
	NEXT i
	i = 0
	x$[i] = "Black"          : x[i] =  0		: INC i	' 00000000
	x$[i] = "White"          : x[i] =  124	: INC i	' FFFFFF7C
	i = i + 3
	x$[i] = "DarkBlue"       : x[i] =  1		: INC i	' 00004001
	x$[i] = "MediumBlue"     : x[i] =  2		: INC i	' 00008002
	x$[i] = "Blue"           : x[i] =  2		: INC i	' 00008002
	x$[i] = "LightBlue"      : x[i] =  3		: INC i	' 0000C003
	x$[i] = "MaxBlue"        : x[i] =  4		: INC i	' 0000FF04
	x$[i] = "DarkGreen"      : x[i] =  5		: INC i	' 00400005
	x$[i] = "MediumGreen"    : x[i] =  10		: INC i	' 0080000A
	x$[i] = "Green"          : x[i] =  10		: INC i	' 0080000A
	x$[i] = "LightGreen"     : x[i] =  15		: INC i	' 00C0000F
	x$[i] = "MaxGreen"       : x[i] =  20		: INC i	' 00FF0014
	x$[i] = "DarkCyan"       : x[i] =  6		: INC i	' 00404006
	x$[i] = "MediumCyan"     : x[i] =  12		: INC i	' 0080800C
	x$[i] = "Cyan"           : x[i] =  12		: INC i	' 0080800C
	x$[i] = "LightCyan"      : x[i] =  18		: INC i	' 00C0C012
	x$[i] = "MaxCyan"        : x[i] =  24		: INC i	' 00FFFF18
	x$[i] = "DarkRed"        : x[i] =  25		: INC i	' 40000019
	x$[i] = "MediumRed"      : x[i] =  50		: INC i	' 80000032
	x$[i] = "Red"            : x[i] =  50		: INC i	' 80000032
	x$[i] = "LightRed"       : x[i] =  75		: INC i	' C000004B
	x$[i] = "MaxRed"         : x[i] =  100	: INC i	' FF000064
	x$[i] = "DarkMagenta"    : x[i] =  26		: INC i	' 4000401A
	x$[i] = "MediumMagenta"  : x[i] =  52		: INC i	' 80008034
	x$[i] = "Magenta"        : x[i] =  52		: INC i	' 80008034
	x$[i] = "LightMagenta"   : x[i] =  78		: INC i	' C000C04E
	x$[i] = "MaxMagenta"     : x[i] =  104	: INC i	' FF00FF68
	x$[i] = "DarkBrown"      : x[i] =  30		: INC i	' 4040001E
	x$[i] = "MediumBrown"    : x[i] =  60		: INC i	' 8080003C
	x$[i] = "Brown"          : x[i] =  60		: INC i	' 8080003C
	x$[i] = "LightYellow"    : x[i] =  90		: INC i	' C0C0005A
	x$[i] = "Yellow"         : x[i] =  90		: INC i	' C0C0005A
	x$[i] = "DarkGrey"       : x[i] =  31		: INC i	' 4040401F
	x$[i] = "MediumGrey"     : x[i] =  62		: INC i	' 8080803E
	x$[i] = "Grey"           : x[i] =  62		: INC i	' 8080803E
	x$[i] = "LightGrey"      : x[i] =  93		: INC i	' C0C0C05D
  INC i
	x$[i] = "DarkSteel"      : x[i] =  32		: INC i	' 40408020
	x$[i] = "MediumSteel"    : x[i] =  63		: INC i	' 8080C03F
	x$[i] = "Steel"          : x[i] =  63		: INC i	' 8080C03F
	x$[i] = "LightSteel"     : x[i] =  94		: INC i	' C0C0FF5E
  INC i
	x$[i] = "MediumOrange"   : x[i] =  81		: INC i	' C0404051
	x$[i] = "Orange"         : x[i] =  81		: INC i	' C0404051
	x$[i] = "LightOrange"    : x[i] =  112	: INC i	' FF808070
  i = i + 2
	x$[i] = "MediumAqua"     : x[i] =  42		: INC i	' 40C0802A
	x$[i] = "Aqua"           : x[i] =  42		: INC i	' 40C0802A
	x$[i] = "LightAqua"      : x[i] =  73		: INC i	' 80FFC049
  i = i + 2
	x$[i] = "DarkViolet"     : x[i] =  57		: INC i	' 80408039
	x$[i] = "MediumViolet"   : x[i] =  88		: INC i	' C080C058
	x$[i] = "Violet"         : x[i] =  88		: INC i	' C080C058
	x$[i] = "LightViolet"    : x[i] =  119	: INC i	' FFC0FF77

	i = 0
	FOR ir = 0 TO 4
		XgrSetGridPositionAndSize (newGrid, xUL[ir], yUL[ir], -1, -1)

		IF (ir <= 2) THEN
			XgrMoveToScaled (newGrid, 4.2, 6.1)
		ELSE
			XgrMoveToScaled (newGrid, 4.2, -.25)
		END IF

		FOR ig = 0 TO 4
			FOR ib = 0 TO 4
				XgrFillBoxScaled (newGrid, x[i], ib, ig, ib + 1, ig + 1)
				XgrMoveToScaled (newGrid, ib + .1, ig + .4)
				IF (i = 124) THEN
					XgrDrawText (newGrid, $$Black, x$[i])
				ELSE
					XgrDrawText (newGrid, $$White, x$[i])
				END IF
				INC i
			NEXT ib
		NEXT ig
	NEXT ir
'
	XgrDestroyGrid (newGrid)
END FUNCTION
'
'* Reset all user-mode variables to their default value. This is called when
' a user-program is started in the PDE.
FUNCTION XgrResetUserMode()
	SHARED userCEO
	userCEO = 0
END FUNCTION
END PROGRAM

