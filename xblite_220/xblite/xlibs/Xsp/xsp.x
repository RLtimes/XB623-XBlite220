'
' #################### David Szafranski
' #####  PROLOG  ##### copyright 2000
' #################### XBLite sprite animation library
'
' This library consists of functions for drawing animated sprites.
' David Szafranski (c) 2000 GPL
'
PROGRAM	"xsp"
VERSION	"0.0004"		'Aug 2002
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
  IMPORT  "xbm"       ' xbm.dll      : XBLite bitmap library
'
EXPORT
TYPE SPRITEDATA
	STRING*128 .fileName  'file name
	XLONG .bmpWidth  			'BMP width
	XLONG .bmpHeight 			'BMP height
	XLONG .hMemBmp 				'sprite memory bitmap handle    'imageGrid
	XLONG .hWnd						'window handle									'grid
	XLONG .x		          'current sprite x position in hWnd
	XLONG .y		          'current sprite y position in hWnd
	XLONG .dx							'sprite speed x (offset x) in hWnd
	XLONG .dy							'sprite speed y (offset y) in hWnd
	XLONG .scale					'sprite scale in percent
	XLONG .orient					'orientation values  0=normal 1=mirror 2=flip 3=180
	XLONG .nextID					'next animation sequence sID
	XLONG .previousID			'previous animation sequence sID
	XLONG .startFlag			'flag to turn on sprite animation sequence on = $$TRUE, off = $$FALSE
	XLONG .repeatCount		'count for sprite animation
	ULONG .bb_width				'bounding box width
	ULONG .bb_height			'bounding box height
	ULONG .bb_xOffset			'bounding box x offset
	ULONG .bb_yOffset			'bounding box y offset
	XLONG .detection      'sprite collision detection  on = $$TRUE, off = $$FALSE
	ULONG	.xMin						'x min range
	ULONG	.xMax						'x max range
	ULONG	.yMin						'y min range
	ULONG	.yMax						'y max range
END TYPE
'
TYPE STAGEGRID
	XLONG .hWnd				'window handle
	XLONG .width			'window width
	XLONG .height			'window height
	XLONG .hWndStage	'handle of stage window			'stageGrid
	XLONG .sID        'background sprite ID or screenGrid if $$TRUE
	XLONG .hWndScr		'handle of screen window   	'scrGrid
	XLONG .hWndParent	'parent window handle
END TYPE
'
'
DECLARE FUNCTION  Xsp         ()
DECLARE FUNCTION  XspLoadSpriteBmp (hWnd, fileName$, @sID)
DECLARE FUNCTION  XspRefreshScreen (hWnd)
DECLARE FUNCTION  XspPause (msec)
DECLARE FUNCTION  XspCaptureBackground (hWnd)
DECLARE FUNCTION  XspScrollBackground (hWnd, dx, dy)
DECLARE FUNCTION  XspAddSpriteToBackground (hWnd, sID, x, y, scale, orient)
DECLARE FUNCTION  XspLoadSpriteLibraryBmp (hWnd, fileName$, @hMemBmpLib)
DECLARE FUNCTION  XspCreateLibrarySprite (hMemBmpLib, x1, y1, x2, y2, @sID)
DECLARE FUNCTION  XspGetSpriteInfo (sID, @fileName$, @hWnd, @hMemBmp, @w, @h, @x, @y, @dx, @dy)
DECLARE FUNCTION  XspSetSpriteScale (sID, scale)
DECLARE FUNCTION  XspSetSpriteOrientation (sID, orient)
DECLARE FUNCTION  XspGetSpriteOrientAndScale (sID, @orient, @scale)
DECLARE FUNCTION  XspDrawSprite (hWnd, sID, x, y, orient)
DECLARE FUNCTION  XspGetStageSize (hWnd, @gw, @gh)
DECLARE FUNCTION  XspSetSpriteSequence (sID, @sequence[])
DECLARE FUNCTION  XspDrawSpriteAnimation (hWnd, @sID, direction, repeat)
DECLARE FUNCTION  XspCloneSprite (sID, @sIDNew)
DECLARE FUNCTION  XspSetSpritePositionAndSpeed (sID, x, y, dx, dy)
DECLARE FUNCTION  XspGetSpritePositionAndSpeed (sID, @x, @y, @dx, @dy)
DECLARE FUNCTION  XspCreateBoundingBox (sID, @bb_width, @bb_height, @bb_xOffset, @bb_yOffset)
DECLARE FUNCTION  XspDetectCollision (sID1, sID2)
DECLARE FUNCTION  XspSetSpriteDetection (sID, detection)
DECLARE FUNCTION  XspDetectAllCollisions (@list[])
DECLARE FUNCTION  XspDetectCollisions (sID, @list[])
DECLARE FUNCTION  XspStartSpriteAnimation (sID)
DECLARE FUNCTION  XspSetBackgroundBmp (hWnd, sID)
DECLARE FUNCTION  XspUnloadSprites ()
DECLARE FUNCTION  XspReverseSpriteDirection (sID, direction)
DECLARE FUNCTION  XspDrawSpriteRange (hWnd, sID, direction, fInvert)
DECLARE FUNCTION  XspSetSpriteRange (sID, xMin, xMax, yMin, yMax)
DECLARE FUNCTION  XspGetSpriteRange (sID, @xMin, @xMax, @yMin, @yMax)
'
END EXPORT
'
'
' ####################
' #####  Xsp ()  #####
' ####################
'
FUNCTION  Xsp ()
'
	IF LIBRARY(0) THEN RETURN			' main program executes message loop
'
END FUNCTION
'
'
' #################################
' #####  XspLoadSpriteBmp ()  #####
' #################################
'
'PUPOSE : Load sprites into memory
'IN     : hWnd,  fileName$ of sprite .bmp
'OUT    : sprite ID, sID
'RETURN : $$TRUE on success, $$FALSE on failure
'
FUNCTION  XspLoadSpriteBmp (hWnd, fileName$, @sID)

	UBYTE image[]
	SHARED SPRITEDATA spriteInfo[]

	IFZ fileName$ THEN RETURN 0
	IFZ hWnd THEN RETURN 0

	upper = UBOUND(spriteInfo[])

	IF upper == -1 THEN upper = 1 ELSE INC upper
	REDIM spriteInfo[upper]

'Load Image
	IFZ XbmLoadImage (fileName$, @image[]) THEN RETURN

'Get width, height
	XbmGetImageArrayInfo (@image[], 0, @width, @height)

'Create a memory bitmap for each sprite
	XbmCreateMemBitmap (hWnd, width, height, @hMemBitmap)
	IFZ hMemBitmap THEN RETURN 0

'Set image[] in sprite memory bitmap
	XbmSetImage(hMemBitmap, @image[])

'Set sprite info
	spriteInfo[upper-1].fileName  = fileName$			'file name
	spriteInfo[upper-1].bmpWidth  = width					'BMP width
	spriteInfo[upper-1].bmpHeight = height				'BMP height
	spriteInfo[upper-1].hMemBmp 	= hMemBitmap		'memory bitmap handle
	spriteInfo[upper-1].hWnd		  = hWnd					'window handle
	spriteInfo[upper-1].x			    = 0							'current sprite x position
	spriteInfo[upper-1].y			    = 0							'current sprite y position
	spriteInfo[sID].detection			= $$TRUE				'set collision detection on

	sID = upper-1

'create bounding box for sprite collision detection
	XspCreateBoundingBox (sID, @bb_width, @bb_height, @bb_xOffset, @bb_yOffset)

	RETURN $$TRUE

END FUNCTION
'
'
' #################################
' #####  XspRefreshScreen ()  #####
' #################################
'
'PURPOSE : Draw image from stage memory bitmap onto screen
'IN      : hWnd		- window handle
'
FUNCTION  XspRefreshScreen (hWnd)

	SHARED SPRITEDATA spriteInfo[]
	SHARED STAGEGRID sg[]

	IFZ hWnd THEN RETURN

'Get stage image id
	upper = UBOUND(sg[])
	FOR i = 0 TO upper -1
		IF sg[i].hWnd = hWnd THEN id = i
	NEXT i

'PRINT "hWnd="; hWnd, "id="; id
'PRINT "sg[id].hWndStage ="; sg[id].hWndStage
'PRINT "sg[id].hWndScr ="; sg[id].hWndScr

'Draw from hWndStage to physical screen
	IFZ XbmCopyImage (hWnd, sg[id].hWndStage) THEN RETURN

'Redraw background image onto hWndStage
	sID = sg[id].sID
	IFZ XbmCopyImage (sg[id].hWndStage, sg[id].hWndScr) THEN RETURN

	RETURN ($$TRUE)
END FUNCTION
'
'
' #########################
' #####  XspPause ()  #####
' #########################
'
FUNCTION  XspPause (msec)

	IFZ msec THEN RETURN ($$FALSE)
	Sleep (msec)
	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  XspCaptureBackground ()  #####
' #####################################
'
'PURPOSE : Capture current background from screen and use it as background
'          This allows graphic elements and text to be added to background
'          at any point in the animation process.
'IN      : hWnd
'RETURN  : $$TRUE on success, $$FALSE on failure
'
FUNCTION  XspCaptureBackground (hWnd)

	SHARED SPRITEDATA spriteInfo[]
	SHARED STAGEGRID sg[]
	UBYTE image[]
	RECT rect

	IFZ hWnd THEN RETURN 0
	upper = UBOUND(sg[])

'Get window width & height
	GetClientRect (hWnd, &rect)
	width = rect.right - rect.left
	height = rect.bottom - rect.top

'Check to see if hWndStage for this window already exists
'Only one hWndStage per window
	FOR i = 0 TO upper-1
		IF sg[i].hWnd = hWnd THEN
'if it does, then just capture screen background onto hWndStage and hWndScr
			id = i
			ret = XbmGetImage (hWnd, @image[])
			ret = XbmSetImage (sg[id].hWndStage, @image[])

'check to see if hWndScr exists, if not, create one
			IFZ sg[id].hWndScr THEN
				XbmCreateMemBitmap (hWnd, width, height, @hWndScr)
				sg[id].hWndScr	= hWndScr
			END IF
			ret = XbmSetImage (sg[id].hWndScr, @image[])
'PRINT "XbmSetImage ret="; ret
'PRINT "id="; id
'PRINT "hWndStage="; sg[id].hWndStage
			sg[id].sID = $$TRUE
 			flag = 1
		END IF
		IF flag THEN EXIT FOR
	NEXT i
	IF flag THEN RETURN 1

	IF upper == -1 THEN upper = 1 ELSE INC upper
	REDIM sg[upper]

'Create an memory bitmap for each stage
	XbmCreateMemBitmap (hWnd, width, height, @hWndStage)
	IFZ hWndStage THEN RETURN 0

'Create a screen memory bitmap for capturing the screen as a background
'or for use with scrolling background
	XbmCreateMemBitmap (hWnd, width, height, @hWndScr)
	IFZ hWndScr THEN RETURN 0

'Set sg[] members
	sg[upper-1].hWnd      = hWnd
	sg[upper-1].width     = width
	sg[upper-1].height    = height
	sg[upper-1].hWndStage = hWndStage
	sg[upper-1].sID       = $$TRUE				'sprite ID or screen background ($$TRUE)
	sg[upper-1].hWndScr		= hWndScr
	sg[upper-1].hWndParent= GetParent (hWnd)	'parent window

'get image[] from hWnd
	IFZ XbmGetImage (hWnd, @image[]) THEN RETURN

'set image[] into hWndStage
	IFZ XbmSetImage (hWndStage, @image[]) THEN RETURN

'set image[] into hWndScr
	IFZ XbmSetImage (hWndScr, @image[]) THEN RETURN

	RETURN ($$TRUE)

END FUNCTION
'
'
' ####################################
' #####  XspScrollBackground ()  #####
' ####################################
'
'PURPOSE : Scroll background bmp by offsetting by dx, dy pixels
'IN      : hWnd, dx, dy (change in x and y must be > 0)
'OUT     : $$TRUE on success, $$FALSE on failure
'
FUNCTION  XspScrollBackground (hWnd, dx, dy)

	SHARED SPRITEDATA spriteInfo[]
	SHARED STAGEGRID sg[]

	IFZ hWnd THEN RETURN
	IF dx < 0 THEN RETURN
	IF dy < 0 THEN RETURN

'Get stage image id
	upper = UBOUND(sg[])
	IF upper = 1 THEN
		id = 0
	ELSE
		FOR i = 0 TO upper -1
			IF sg[i].hWnd = hWnd THEN id = i
		NEXT i
	END IF

	hWndStage 		= sg[id].hWndStage
	hWndScr				= sg[id].hWndScr
	width 				= sg[id].width
	height 				= sg[id].height
'PRINT hWndStage, hWndScr, width, height

'Calculate x and y offsets
	offsetX = dx MOD width
	offsetY = dy MOD height

	x1 = offsetX
	y1 = 0
	x2 = width
	y2 = height - offsetY

	x3 = 0
	y3 = 0
	x4 = offsetX
	y4 = height - offsetY

	x5 = offsetX
	y5 = height - offsetY
	x6 = width
	y6 = height

	x7 = 0
	y7 = height - offsetY
	x8 = offsetX
	y8 = height

'Draw background hWndScr to hWndStage in four parts if necessary
'two for x movement, two for y movement

	IFZ XbmDrawImage (hWndStage, hWndScr, x1, y1, x2, y2, 0, offsetY) THEN RETURN

	IF offsetX == 0 && offsetY == 0 THEN RETURN ($$TRUE)

	IF offsetX THEN
		IFZ XbmDrawImage (hWndStage, hWndScr, x3, y3, x4, y4, width-offsetX, offsetY) THEN RETURN
	END IF

	IF offsetY THEN
		IFZ XbmDrawImage (hWndStage, hWndScr, x5, y5, x6, y6, 0, 0) THEN RETURN

		IFZ XbmDrawImage (hWndStage, hWndScr, x7, y7, x8, y8, width-offsetX, 0) THEN RETURN
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
'
' #########################################
' #####  XspAddSpriteToBackground ()  #####
' #########################################
'
FUNCTION  XspAddSpriteToBackground (hWnd, sID, x, y, scale, orient)

	SHARED SPRITEDATA spriteInfo[]
	SHARED STAGEGRID sg[]

	IFZ hWnd THEN RETURN 0
	IFZ scale THEN scale = 100
	upper = UBOUND(spriteInfo[])
	IF sID > upper-1 THEN RETURN 0

	upper = UBOUND(sg[])

'Get screen image id
	IF upper = 1 THEN
		id = 0
	ELSE
		FOR i = 0 TO upper -1
			IF sg[i].hWnd = hWnd THEN id = i
		NEXT i
	END IF

'Draw animation sprite image directly onto screen
	sw = spriteInfo[sID].bmpWidth
	sh = spriteInfo[sID].bmpHeight/2

	dWidth = scale/100.0 * sw
	dHeight = scale/100.0 * sh

'Draw sprite to hWndScr first with mode SRCAND then with mode SRCINVERT

'	ret = XgrDrawImageResizedMode (sg[id].hWndScr, spriteInfo[sID].hMemBmp, 0, 0, sw, sh-1, x, y, dWidth, dHeight, $$MODE_SRCAND)
	ret1 = XbmDrawImageEx (sg[id].hWndScr, spriteInfo[sID].hMemBmp, 0, 0, sw, sh, x, y, x+dWidth, y+dHeight, $$SRCAND, orient)

'	ret = XgrDrawImageResizedMode (sg[id].hWndScr, spriteInfo[sID].hMemBmp, 0, sh, sw, 2*sh, x, y, dWidth, dHeight, $$MODE_SRCINVERT)
	ret2 = XbmDrawImageEx (sg[id].hWndScr, spriteInfo[sID].hMemBmp, 0, sh, sw, 2*sh, x, y, x+dWidth, y+dHeight, $$SRCINVERT, orient)

	IFZ ret1 * ret2 THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

END FUNCTION
'
'
' ########################################
' #####  XspLoadSpriteLibraryBmp ()  #####
' ########################################
'
FUNCTION  XspLoadSpriteLibraryBmp (hWnd, fileName$, @hMemBmpLib)


END FUNCTION
'
'
' #######################################
' #####  XspCreateLibrarySprite ()  #####
' #######################################
'
FUNCTION  XspCreateLibrarySprite (hMemBmpLib, x1, y1, x2, y2, @sID)


END FUNCTION
'
'
' #################################
' #####  XspGetSpriteInfo ()  #####
' #################################
'
FUNCTION  XspGetSpriteInfo (sID, @fileName$, @hWnd, @hMemBmp, @w, @h, @x, @y, @dx, @dy)

	SHARED SPRITEDATA spriteInfo[]
	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

	fileName$ = spriteInfo[sID].fileName
	hWnd      = spriteInfo[sID].hWnd
	hMemBmp 	= spriteInfo[sID].hMemBmp
	w         = spriteInfo[sID].bmpWidth
	h         = spriteInfo[sID].bmpHeight
	x         = spriteInfo[sID].x
	y         = spriteInfo[sID].y
	dx        = spriteInfo[sID].dx
	dy        = spriteInfo[sID].dy

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##################################
' #####  XspSetSpriteScale ()  #####
' ##################################
'
FUNCTION  XspSetSpriteScale (sID, scale)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN 0
	IF sID > upper-1 THEN RETURN 0

	IF scale <= 0 THEN scale = 100

	spriteInfo[sID].scale = scale

'reset bounding box for scaled sprite
'bounding boxes for scaled images are approximated

	XspCreateBoundingBox (sID, @bb_width, @bb_height, @bb_xOffset, @bb_yOffset)

	spriteInfo[sID].bb_xOffset = bb_xOffset * scale/100.0
	spriteInfo[sID].bb_yOffset = bb_yOffset * scale/100.0
	spriteInfo[sID].bb_width   = bb_width   * scale/100.0
	spriteInfo[sID].bb_height  = bb_height  * scale/100.0

	RETURN ($$TRUE)

END FUNCTION
'
'
' ########################################
' #####  XspSetSpriteOrientation ()  #####
' ########################################
'
'PURPOSE	: Set the sprite orientation
'
'IN				: sID			-sprite ID
'						orient	-orientation mode : 0=normal 1=mirror 2=flip 3=180
'
FUNCTION  XspSetSpriteOrientation (sID, orient)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

'orientation values  0=normal 1=mirror 2=flip 3=180
	IF orient < 0 || orient > 3 THEN orient = 0

	spriteInfo[sID].orient = orient

	RETURN ($$TRUE)



END FUNCTION
'
'
' ###########################################
' #####  XspGetSpriteOrientAndScale ()  #####
' ###########################################
'
'PURPOSE	: return sprite orientation and scale values
'IN				: sID			- sprite ID
'OUT			: orient	- sprite orientation
'						scale		- sprite scale
'
FUNCTION  XspGetSpriteOrientAndScale (sID, @orient, @scale)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

	orient = spriteInfo[sID].orient
	scale  = spriteInfo[sID].scale

	RETURN $$TRUE

END FUNCTION
'
'
' ##############################
' #####  XspDrawSprite ()  #####
' ##############################
'
'PURPOSE : Set sprite position, scale, and orientation
'					 and draw onto stage memory bitmap.
'IN      : hWnd, sID, x, y, scale, orient
'          scale is in percent
'          orientation  0=normal 1=mirror 2=flip 3=180 deg rotation
'RETURN  : $$TRUE on success, $$FALSE on failure

FUNCTION  XspDrawSprite (hWnd, sID, x, y, orient)

	SHARED SPRITEDATA spriteInfo[]
	SHARED STAGEGRID sg[]

	IFZ hWnd THEN RETURN
	upper = UBOUND(spriteInfo[])
	IF sID > upper-1 THEN	RETURN

'set sprint x, y position
	spriteInfo[sID].x = x
	spriteInfo[sID].y = y

'get sprite scale
	XspGetSpriteOrientAndScale (sID, 0, @scale)
	IF scale = 0 THEN scale = 100

	upper = UBOUND(sg[])

'Get stage image id
	IF upper = 1 THEN
		id = 0
	ELSE
		FOR i = 0 TO upper -1
			IF sg[i].hWnd = hWnd THEN id = i
		NEXT i
	END IF

'Draw animation sprite image onto stage memory bitmap
	sw = spriteInfo[sID].bmpWidth
	sh = spriteInfo[sID].bmpHeight/2.0

	dWidth  = scale/100.0 * sw
	dHeight = scale/100.0 * sh

'Draw sprite to hWndStage first with mode SRCAND then draw mask with mode SRCINVERT

	ret1 = XbmDrawImageEx (sg[id].hWndStage, spriteInfo[sID].hMemBmp, 0, 0, sw, sh, x, y, x+dWidth, y+dHeight, $$SRCAND, orient)
	ret2 = XbmDrawImageEx (sg[id].hWndStage, spriteInfo[sID].hMemBmp, 0, sh, sw, 2*sh, x, y, x+dWidth, y+dHeight, $$SRCINVERT, orient)

	IFZ ret1 * ret2 THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)
END FUNCTION
'
'
' ################################
' #####  XspGetStageSize ()  #####
' ################################
'
FUNCTION  XspGetStageSize (hWnd, @w, @h)

	SHARED STAGEGRID  sg[]

	IFZ sg[] THEN RETURN 0
	upper = UBOUND(sg[])

	FOR i = 0 TO upper-1
		IF sg[i].hWnd = hWnd THEN
			id = i
		END IF
	NEXT i

	w = sg[id].width
	h = sg[id].height

	RETURN ($$TRUE)


END FUNCTION
'
'
' #####################################
' #####  XspSetSpriteSequence ()  #####
' #####################################
'
'PURPOSE : Set an animation sequence of sprites
'          beginning with sprite sID, eg, if initial starting
'          sprite is sID = 2 and it has two more sprites
'          in the animation sequence, sID = 3, and sID = 4
'          then sequence[0] = 2, sequence[1] = 3, sequence[2] = 4.
'NOTE    : Animation sprite sID's must be in numerical sequential order; 1, 2, 3, 4...
'IN      : sID, sequence[]
'RETURNS : $$FALSE on failure, $$TRUE on success

FUNCTION  XspSetSpriteSequence (sID, @sequence[])

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN
	IFZ sequence[] THEN RETURN

	upper = UBOUND(sequence[])

	IF sID <> sequence[0] THEN RETURN 0

	FOR i = 0 TO upper-1
		id = sequence[i]
		next = i+1
		IF next > upper-1 THEN next = 0
		previous = i-1
		IF previous < 0 THEN previous = upper-1

		spriteInfo[id].nextID     = sequence[next]
		spriteInfo[id].previousID = sequence[previous]
	NEXT i

	RETURN $$TRUE

END FUNCTION
'
'
' #######################################
' #####  XspDrawSpriteAnimation ()  #####
' #######################################
'
'PURPOSE : Automatically draw a repeated sprite animation sequence
'          of two or more sprites.
'					 Use XspStartSpriteAnimation(sID) to initialize animation
'          and use XspDrawSpriteAnimation() in main animation loop
'IN      : hWnd				- window handle
'          sID				- first sprite ID in sequence to commence animation
'          direction	- animation direction
'          repeat			- no of times to animate sequence
'OUT     : sID        - next sID of sprite to animate
'
FUNCTION  XspDrawSpriteAnimation (hWnd, @sID, direction, repeat)

	SHARED SPRITEDATA spriteInfo[]

	IFZ hWnd THEN RETURN 0
	IFZ repeat THEN RETURN 0
	IFZ spriteInfo[sID].startFlag THEN RETURN

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN 0
	IF sID > upper-1 THEN RETURN 0

'make sure XspSetSpriteSequence() has been called
	IF (ABS(spriteInfo[sID].nextID - sID > 1)) || (ABS(sID - spriteInfo[sID].previousID > 1)) THEN RETURN 0

	XspGetSpriteInfo (sID, fn$, 0, 0, 0, 0, @x, @y, @dx, @dy)
	XspGetSpriteOrientAndScale (sID, @orient, @scale)

'draw sprite at current x, y, scale, orientation
	XspDrawSprite (hWnd, sID, x, y, orient)

'repeat sequence in same place
	count = spriteInfo[sID].repeatCount
	INC count
	IF count == repeat THEN
		spriteInfo[sID].repeatCount = 0
		spriteInfo[sID].startFlag = $$FALSE
	ELSE
		spriteInfo[sID].repeatCount = count
		RETURN 1
	END IF

'move sprite to next x,y position
	x = x + dx
	y = y + dy

'update all sprite positions in sprite animation sequence
	id = sID
	DO
		spriteInfo[id].x = x
		spriteInfo[id].y = y
		id = spriteInfo[id].nextID
	LOOP UNTIL id = sID

'return value for next or previous sprite ID in sequence
	IFZ direction THEN
		sID = spriteInfo[sID].nextID
	ELSE
		sID = spriteInfo[sID].previousID
	END IF

	RETURN $$TRUE

END FUNCTION
'
'
' ###############################
' #####  XspCloneSprite ()  #####
' ###############################
'
FUNCTION  XspCloneSprite (sID, @sIDNew)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN 0
	IF sID > upper-1 THEN RETURN 0

	INC upper
	REDIM spriteInfo[upper]

	XspGetSpriteInfo (sID, @fileName$, @hWnd, @hBmp, @w, @h, @x, @y, @dx, @dy)
	XspGetSpriteOrientAndScale (sID, @orient, @scale)

'Create a memory bitmap for each sprite
	XbmCreateMemBitmap (hWnd, w, h, @hMemBmp)
	IFZ hMemBmp THEN RETURN 0

'copy ig to hMemBmp
	XbmCopyImage(hMemBmp, hBmp)

	sIDNew = upper-1

'Set sprite info
	spriteInfo[sIDNew].fileName = fileName$
	spriteInfo[sIDNew].bmpWidth = w
	spriteInfo[sIDNew].bmpHeight= h
	spriteInfo[sIDNew].hMemBmp  = hMemBmp
	spriteInfo[sIDNew].hWnd		  = hWnd
	spriteInfo[sIDNew].x			  = x						'current sprite x position
	spriteInfo[sIDNew].y			  = y						'current sprite y position
	spriteInfo[sIDNew].dx			  = dx					'current sprite x speed
	spriteInfo[sIDNew].dy			  = dy					'current sprite y speed
	spriteInfo[sIDNew].orient		= orient			'current orientation
	spriteInfo[sIDNew].scale		= scale				'current scale
	spriteInfo[sIDNew].bb_width		  =	spriteInfo[sID].bb_width		'bounding box width
	spriteInfo[sIDNew].bb_height		=	spriteInfo[sID].bb_height		'bounding box height
	spriteInfo[sIDNew].bb_xOffset		=	spriteInfo[sID].bb_xOffset	'bounding box x offset
	spriteInfo[sIDNew].bb_yOffset		=	spriteInfo[sID].bb_yOffset	'bounding box y offset

	RETURN 1
END FUNCTION
'
'
' #############################################
' #####  XspSetSpritePositionAndSpeed ()  #####
' #############################################
'
'PURPOSE	: set sprite position and speed
'IN				: sID	- sprite ID
'						x		- x position
'						y		- y position
'						dx	- speed in x direction
'						dy	- speed in y direction
'
FUNCTION  XspSetSpritePositionAndSpeed (sID, x, y, dx, dy)
'
	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

	spriteInfo[sID].x = x
	spriteInfo[sID].y = y

	spriteInfo[sID].dx = dx
	spriteInfo[sID].dy = dy

	RETURN $$TRUE

END FUNCTION
'
'
' #############################################
' #####  XspGetSpritePositionAndSpeed ()  #####
' #############################################
'
'PURPOSE	: return sprite position and speed
'IN				: sID			- sprite ID
'OUT			: x		- x position
'						y		- y position
'						dx	- speed in x direction
'						dy	- speed in y direction
'
FUNCTION  XspGetSpritePositionAndSpeed (sID, @x, @y, @dx, @dy)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

	x = spriteInfo[sID].x
	y = spriteInfo[sID].y

	dx = spriteInfo[sID].dx
	dy = spriteInfo[sID].dy

	RETURN $$TRUE

END FUNCTION
'
'
' #####################################
' #####  XspCreateBoundingBox ()  #####
' #####################################
'
' PURPOSE	:	Create the smallest bounding rectangular that
'						encompasses sprite image.
'	IN			: sID
'	OUT			: bb_width, bb_height, bb_xOffset, bb_yOffset
'
FUNCTION  XspCreateBoundingBox (sID, @bb_width, @bb_height, @bb_xOffset, @bb_yOffset)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN 0
	IF sID > upper-1 THEN RETURN 0

	height = spriteInfo[sID].bmpHeight
	width =  spriteInfo[sID].bmpWidth

	hdcSprite = CreateCompatibleDC (NULL)
	hdcSpriteOld = SelectObject (hdcSprite, spriteInfo[sID].hMemBmp)

	FOR y = height/2 TO height-1
'		color = 0
		xFlag = $$FALSE
		FOR x = 0 TO width-1
			color = GetPixel (hdcSprite, x, y)
'			XgrGrabPoint (spriteInfo[sID].hMemBmp, x, y, @red, @green, @blue, @color)
			IF color THEN
				IFZ init THEN
					init = $$TRUE
					xMin = x
					yMin = y
				END IF

				xMin = MIN(xMin, x)
				yMin = MIN(yMin, y)

				xMax = MAX(xMax, x)
				yMax = MAX(yMax, y)
'PRINT x, y, xMin, xMax, yMin, yMax, color
			END IF
		NEXT x
	NEXT y

	SelectObject (hdcSpriteOld, spriteInfo[sID].hMemBmp)
	DeleteDC (hdcSprite)

	bb_xOffset = xMin
	bb_yOffset = yMin - height/2
	bb_width   = xMax-xMin
	bb_height  = yMax-yMin

'PRINT bb_width, bb_height, bb_xOffset, bb_yOffset

	spriteInfo[sID].bb_xOffset = bb_xOffset
	spriteInfo[sID].bb_yOffset = bb_yOffset
	spriteInfo[sID].bb_width   = bb_width
	spriteInfo[sID].bb_height  = bb_height

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###################################
' #####  XspDetectCollision ()  #####
' ###################################
'
'PURPOSE : Detect a collision between two sprite bounding boxes
'          This will detect collisions for any two valid sprites
'          whether or not their detection setting is on or off
'          See SetSpriteDetection().
'IN      : sID1, sID2
'RETURNS : $$TRUE if collision detected, $$FALSE if no collision detected (or not a valid sprite ID)

FUNCTION  XspDetectCollision (sID1, sID2)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN 0
	IF sID1 > upper-1 THEN RETURN 0
	IF sID2 > upper-1 THEN RETURN 0

	s1x = spriteInfo[sID1].x
	s1y = spriteInfo[sID1].y

	s2x = spriteInfo[sID2].x
	s2y = spriteInfo[sID2].y

	s1x1 = s1x  + spriteInfo[sID1].bb_xOffset
	s1x2 = s1x1 + spriteInfo[sID1].bb_width

	s1y1 = s1y  + spriteInfo[sID1].bb_yOffset
	s1y2 = s1y1 + spriteInfo[sID1].bb_height

	s2x1 = s2x  + spriteInfo[sID2].bb_xOffset
	s2x2 = s2x1 + spriteInfo[sID2].bb_width

	s2y1 = s2y  + spriteInfo[sID2].bb_yOffset
	s2y2 = s2y1 + spriteInfo[sID2].bb_height

 	IF ((s1x1 <= s2x2) && (s2x1 <= s1x2) && (s1y1 <= s2y2) && (s2y1 <= s1y2)) THEN
		RETURN $$TRUE				'collision detected
	ELSE
   	RETURN $$FALSE			'no collision detected
	END IF

END FUNCTION
'
'
' ######################################
' #####  XspSetSpriteDetection ()  #####
' ######################################
'
FUNCTION  XspSetSpriteDetection (sID, detection)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN 0
	IF sID > upper-1 THEN RETURN 0

	IF detection THEN detection = $$TRUE
	spriteInfo[sID].detection= detection

	RETURN ($$TRUE)

END FUNCTION
'
'
' ####################################
' #####  XspDetectAllCollisions ()  #####
' ####################################
'
'PURPOSE : Return an array of all sprite collisons detected
'          by sprites with detection turned on.
'          Each item in array is a pairing of two sprite IDs
'          with info stored in high/low word of long integer.
'					 sID1 = list[n]{16,16}, sID2 = list[n]{16,0}
'OUT     : list[]
'RETURNS : $$TRUE if collisions detected, $$FALSE if no collisions detected (or failure)
'
FUNCTION  XspDetectAllCollisions (@list[])

	SHARED SPRITEDATA spriteInfo[]

	IFZ spriteInfo[] THEN RETURN 0

	upper = UBOUND(spriteInfo[])

	FOR i = 1 TO upper-1
		IFZ spriteInfo[i].detection THEN DO NEXT
		FOR j = 0 TO i-1
			IFZ spriteInfo[j].detection THEN DO NEXT
			ret = XspDetectCollision (i, j)
			IF ret THEN
				INC count
				REDIM list[count]
				list[count-1] = i<<16 OR j		'i = list[]{16,16}, j = list[]{16,0}
			END IF
		NEXT j
	NEXT i

	IFZ count RETURN $$FALSE ELSE RETURN $$TRUE



END FUNCTION
'
'
' ####################################
' #####  XspDetectCollisions ()  #####
' ####################################
'
'PURPOSE : Return an array of sprite IDs that were detected
'          as having collided with sprite sID.
'IN      : sID			sprite ID
'OUT     : list[]		array of sprite IDs
'RETURNS : $$TRUE if collisions detected, $$FALSE if no collisions detected (or failure)
'
FUNCTION  XspDetectCollisions (sID, @list[])

	SHARED SPRITEDATA spriteInfo[]

	IFZ spriteInfo[] THEN RETURN 0

	upper = UBOUND(spriteInfo[])

	FOR i = 0 TO upper-1
		IFZ spriteInfo[i].detection THEN DO NEXT
		IF i = sID THEN DO NEXT
		ret = XspDetectCollision (i, sID)
		IF ret THEN
			INC count
			REDIM list[count]
			list[count-1] = i
		END IF
	NEXT i

	IFZ count RETURN $$FALSE ELSE RETURN $$TRUE

END FUNCTION
'
'
' ########################################
' #####  XspStartSpriteAnimation ()  #####
' ########################################
'
' PURPOSE	: Initialize all flags in animation sequence array.
' IN			: sID	- first sprite ID in sequence
'
FUNCTION  XspStartSpriteAnimation (sID)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

'update all startFlags in sprite animation sequence
	id = sID
	DO
		spriteInfo[id].startFlag = $$TRUE
		id = spriteInfo[id].nextID
	LOOP UNTIL id = sID

	RETURN $$TRUE
END FUNCTION
'
'
' ####################################
' #####  XspSetBackgroundBmp ()  #####
' ####################################
'
'PURPOSE : Initialize stage memory bitmap for drawing onto screen
'          and select a background bmp image
'IN      : hWnd, sID (background bmp sprite ID)
'RETURN  : TRUE on success, FALSE on failure
'
FUNCTION  XspSetBackgroundBmp (hWnd, sID)

	RECT rect

	SHARED SPRITEDATA spriteInfo[]
	SHARED STAGEGRID sg[]

	IFZ hWnd THEN RETURN 0
	upper = UBOUND(spriteInfo[])
	IF sID > upper-1 THEN RETURN 0

	upper = UBOUND(sg[])

'Check to see if hWndStage for this hWnd already exists
	FOR i = 0 TO upper-1
		IF sg[i].hWnd = hWnd THEN

'if it does, then just draw new bmp background onto stage
			id = i
'			XgrDrawImageScaled (sg[id].hWndStage, spriteInfo[sID].hMemBmp, 0, 0, sg[id].width, sg[id].height, 0, 0)
'			ret = StretchBlt (hdcStage, 0, 0, sg[id].width, sg[id].height, hdcBack, 0, 0, spriteInfo[sID].bmpWidth, spriteInfo[sID].bmpHeight, $$SRCCOPY)
			ret = XbmDrawImageEx (sg[id].hWndStage, spriteInfo[sID].hMemBmp, 0, 0, spriteInfo[sID].bmpWidth, spriteInfo[sID].bmpHeight, 0, 0, sg[id].width, sg[id].height, $$SRCCOPY, 0)
			IFZ ret THEN RETURN

'and copy stage window onto screen window
'			XgrCopyImage (sg[id].hWndScr, sg[id].hWndStage)
			IFZ XbmCopyImage (sg[id].hWndScr, sg[id].hWndStage) THEN RETURN

'update stagegrid data
			sg[id].sID = sID
 			flag = 1
		END IF
		IF flag THEN EXIT FOR
	NEXT i
	IF flag THEN RETURN ($$TRUE)

	IF upper == -1 THEN upper = 1 ELSE INC upper
	REDIM sg[upper]

'Get window width & height
	GetClientRect (hWnd, &rect)
	width = rect.right - rect.left
	height = rect.bottom - rect.top

'Create an memory bitmap for each stage
	XbmCreateMemBitmap (hWnd, width, height, @hWndStage)
	IFZ hWndStage THEN RETURN 0

'Create a screen memory bitmap for capturing the screen as a background
'or for use with scrolling background
	XbmCreateMemBitmap (hWnd, width, height, @hWndScr)
	IFZ hWndScr THEN RETURN 0

'Set sg[] members
	sg[upper-1].hWnd      = hWnd
	sg[upper-1].width     = width
	sg[upper-1].height    = height
	sg[upper-1].hWndStage = hWndStage
	sg[upper-1].sID       = sID								'sprite ID or screen background ($$TRUE)
	sg[upper-1].hWndScr		= hWndScr
	sg[upper-1].hWndParent= GetParent (hWnd)	'parent window
	spriteInfo[sID].detection	= $$FALSE				'turn off collision detection for background bmp

'Draw background image onto stage memory bitmap
'	XgrDrawImageScaled (hWndStage, spriteInfo[sID].hMemBmp, 0, 0, width, height, 0, 0)

'	ret = StretchBlt (hdcStage, 0, 0, width, height, hdcBack, 0, 0, spriteInfo[sID].bmpWidth, spriteInfo[sID].bmpHeight, $$SRCCOPY)
	ret = XbmDrawImageEx (hWndStage, spriteInfo[sID].hMemBmp, 0, 0, spriteInfo[sID].bmpWidth, spriteInfo[sID].bmpHeight, 0, 0, width, height, $$SRCCOPY, 0)
	IFZ ret THEN RETURN

'and copy stageImage onto scrImage memory bitmap
'	XgrDrawImageScaled (hWndScr, spriteInfo[sID].hMemBmp, 0, 0, width, height, 0, 0)
'	XgrCopyImage (sg[id].hWndScr, sg[id].hWndStage)
	IFZ XbmCopyImage (hWndScr, hWndStage) THEN RETURN

	RETURN ($$TRUE)

END FUNCTION
'
'
' #################################
' #####  XspUnloadSprites ()  #####
' #################################
'
' PURPOSE	:	Delete all sprite memory bitmaps
'						and supporting stage and screen memory bitmaps
'           Call this function before exiting program.
'
FUNCTION  XspUnloadSprites ()

	SHARED SPRITEDATA spriteInfo[]
	SHARED STAGEGRID sg[]

	upper = UBOUND(spriteInfo[])
	FOR i = 0 TO upper-1
		DeleteObject (spriteInfo[i].hMemBmp)
	NEXT i

	upper = UBOUND(sg[])
	FOR i = 0 TO upper-1
		DeleteObject (sg[i].hWndStage)
		DeleteObject (sg[i].hWndScr)
	NEXT i

END FUNCTION
'
'
' ##########################################
' #####  XspReverseSpriteDirection ()  #####
' ##########################################
'
' PURPOSE	:	Reverse sprite direction.
'	IN			:	sID	- sprite id
'						direction to change, 0=x, 1=y
'
FUNCTION  XspReverseSpriteDirection (sID, direction)

	SHARED SPRITEDATA spriteInfo[]

	IFZ hWnd THEN RETURN
	IFZ repeat THEN RETURN
	IFZ spriteInfo[sID].startFlag THEN RETURN

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

	XspGetSpritePositionAndSpeed (sID, @x, @y, @dx, @dy)

	IFZ direction THEN
		spriteInfo[sID].dx = -dx
	ELSE
		spriteInfo[sID].dy = -dy
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###################################
' #####  XspDrawSpriteRange ()  #####
' ###################################
'
' PURPOSE : Draw a sprite with a specified bounding area.
'           If the sprite position exceeds the bounding area,
'           then reverse it's direction. Optionally, invert
'           the sprite as well (flip or mirror).
'	IN			:	hWnd			- window handle
'						sID				- sprite ID
'						direction - direction to check range, 0=x, 1=y, 2=both
'           fInvert 	- invert sprite at boundary, $$TRUE=on, $$FALSE=off
'
FUNCTION  XspDrawSpriteRange (hWnd, sID, direction, fInvert)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN
	IFZ hWnd THEN RETURN

	XspGetSpritePositionAndSpeed (sID, @x, @y, @dx, @dy)
	XspGetSpriteRange (sID, @xMin, @xMax, @yMin, @yMax)
	XspGetSpriteOrientAndScale (sID, @orient, @scale)

	SELECT CASE direction
		CASE 0 :	GOSUB CheckX
		CASE 1 :	GOSUB CheckY
		CASE 2 :	GOSUB CheckX	: GOSUB CheckY
	END SELECT

	IFZ XspDrawSprite (hWnd, sID, x, y, orient) THEN RETURN

	XspSetSpritePositionAndSpeed (sID, x+dx, y+dy, dx, dy)
	XspSetSpriteOrientation (sID, orient)

	RETURN ($$TRUE)

' ***** CheckX *****
SUB CheckX
	IF (x > xMax) OR (x < xMin) THEN
		dx = -dx
		IF fInvert THEN
			IFZ orient THEN
				orient = 1
			ELSE
				orient = 0
			END IF
		END IF
	END IF
END SUB

' ***** CheckY *****
SUB CheckY
	IF (y > yMax) OR (y < yMin) THEN
		dy = -dy
		IF fInvert THEN
			IFZ orient THEN
				orient = 2
			ELSE
				orient = 0
			END IF
		END IF
	END IF
END SUB

END FUNCTION
'
'
' ##################################
' #####  XspSetSpriteRange ()  #####
' ##################################
'
FUNCTION  XspSetSpriteRange (sID, xMin, xMax, yMin, yMax)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

	IF xMax < xMin THEN SWAP xMax, xMin
	IF yMax < yMin THEN SWAP yMax, yMin

	spriteInfo[sID].xMin = xMin
	spriteInfo[sID].xMax = xMax
	spriteInfo[sID].yMin = yMin
	spriteInfo[sID].yMax = yMax

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##################################
' #####  XspSetSpriteRange ()  #####
' ##################################
'
FUNCTION  XspGetSpriteRange (sID, @xMin, @xMax, @yMin, @yMax)

	SHARED SPRITEDATA spriteInfo[]

	upper = UBOUND(spriteInfo[])
	IF upper < 1 THEN RETURN
	IF sID > upper-1 THEN RETURN

	xMin = spriteInfo[sID].xMin
	xMax = spriteInfo[sID].xMax
	yMin = spriteInfo[sID].yMin
	yMax = spriteInfo[sID].yMax

	RETURN ($$TRUE)

END FUNCTION
END PROGRAM
