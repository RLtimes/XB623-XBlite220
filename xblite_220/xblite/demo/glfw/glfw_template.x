 
' glfwTemplate.x by Michael McElligott 21/12/2002
' version 0.1 Mapei_@hotmail.com

PROGRAM "program"
VERSION "0.0001"

' IMPORT "xst"
' IMPORT "xsx"
	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "msvcrt"
	IMPORT "gdi32.dec"
	IMPORT "user32"	
'	IMPORT "kernel32"

DECLARE FUNCTION Main ()
DECLARE FUNCTION InitProgram ()
DECLARE FUNCTION CreateWindow (wtype, w, h, title$)
DECLARE FUNCTION ShutDown ()
DECLARE FUNCTION Loop ()
DECLARE FUNCTION ResizeWindow (Width, Height)

DECLARE FUNCTION Render ()
DECLARE FUNCTION LoadTexture (addrfile)
DECLARE FUNCTION FillArray4f (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)

DECLARE FUNCTION KeyCB (k, action)
DECLARE FUNCTION MousePosCB (x, y)

DECLARE FUNCTION BuildFont ()
DECLARE FUNCTION glPrint (x, y, set, scale, addrtext)


FUNCTION Main ()

	wtype = $$GLFW_WINDOW		' or $$GLFW_FULLSCREEN 
	w = 800
	h = 600
	title$ = "Title"

	IFF CreateWindow (wtype, w, h, title$) THEN ShutDown ()
	IFF InitProgram () THEN ShutDown ()
	Loop ()
	ShutDown ()

END FUNCTION

FUNCTION InitProgram ()

' initialize opengl parameters
' must return $$TRUE if function is successful
	RETURN $$TRUE		

END FUNCTION

FUNCTION Render ()

' draw image here

END FUNCTION

FUNCTION Loop ()

	SHARED RunStatus

	RunStatus = 1
	DO
		Render ()
		IF #vsync THEN glfwSleep (0.01)		' could also take into account Render() time too.
		glfwSwapBuffers ()

		IFZ glfwGetWindowParam ($$GLFW_OPENED) THEN RunStatus = 0
	LOOP WHILE RunStatus

END FUNCTION

FUNCTION ShutDown ()
	SHARED FONT
	SHARED XLONG TEXID[], TEXTURE

	glfwTerminate ()

	IF TEXTURE THEN glDeleteTextures (TEXTURE, &TEXID[])		' delete all textures
	IFT FONT THEN glDeleteLists (#FontBase, 256)						' delete font from memory

END FUNCTION

FUNCTION CreateWindow (wtype, w, h, title$)
	SHARED XLONG TEXTURE

	IFZ glfwInit () THEN		' Init GLFW and open window
		MessageBoxA ($$NULL, &"Unable to initialize glfw library.   ", &"glfwInit() Error", $$MB_OK)
		RETURN
	END IF

	#Width = w
	#Height = h
	'	wtype = $$GLFW_WINDOW		'$$GLFW_FULLSCREEN
	' glfwOpenWindowHint   ( $$GLFW_REFRESH_RATE,85)	' use with care. Fullscreen mode only

	IFZ glfwOpenWindow (#Width, #Height, 0, 0, 0, 0, 32, 0, wtype) THEN
		MessageBoxA ($$NULL, &"Unable to create glfw window.   ", &"glfwOpenWindow() Error", $$MB_OK)
		RETURN
	END IF

	glfwSetWindowTitle (&title$)
	glfwSetWindowSizeCallback (&ResizeWindow ())
	glfwSetKeyCallback (&KeyCB ())
	' glfwSetMousePosCallback (&MousePosCB() )
	glfwEnable ($$GLFW_KEY_REPEAT)

	TEXTURE = 0		' set flag to show there are no textures loaded.
	#vsync = 1		' 1 = sync buffer swaps to monitor vertical sync rate, ie monitor refresh rate.
	glfwSwapInterval (#vsync)

	RETURN $$TRUE

END FUNCTION

FUNCTION KeyCB (k, action)
	SHARED RunStatus

	IF (action != $$GLFW_PRESS) THEN RETURN

	SELECT CASE k

		CASE $$GLFW_KEY_ESC : RunStatus = 0		' exit program

		' CASE ' ' :

		CASE 'V' :
			IF #vsync = 1 THEN
				#vsync = 0
				glfwSwapInterval (#vsync)
			ELSE
				#vsync = 1
				glfwSwapInterval (#vsync)
			END IF

			' CASE ELSE : RunStatus = 0		' exit program

	END SELECT

END FUNCTION

FUNCTION MousePosCB (x, y)
	SHARED mx, my

	mx = x: my = y
END FUNCTION

FUNCTION ResizeWindow (Width, Height)

	#Width = Width
	#Height = Height

	IF (#Height < 100) THEN #Height = 100
	IF (#Width < 100) THEN #Width = 100


	glViewport (0, 0, #Width, #Height)
	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity ()
	gluPerspective (45.0, SINGLE (#Width / #Height), 0.1, 100.0)
	glMatrixMode ($$GL_MODELVIEW)
	glLoadIdentity ()

END FUNCTION

FUNCTION LoadTexture (file)
	SHARED XLONG TEXTURE, TEXID[]

	IFZ TEXTURE THEN
		TEXTURE = 0
		DIM TEXID[TEXTURE]
	END IF

	INC TEXTURE
	REDIM TEXID[TEXTURE]
	TEXID[TEXTURE] = 0

	glGenTextures (1, &TEXID[TEXTURE])
	glBindTexture ($$GL_TEXTURE_2D, TEXID[TEXTURE])
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR)

	IFZ glfwLoadTexture2D (file, 0) THEN
		DEC TEXTURE
		RETURN $$FALSE
	ELSE
		RETURN TEXID[TEXTURE]
	END IF

END FUNCTION

FUNCTION glPrint (x, y, set, scale, text)
	STATIC blend_src, blend_dst

	IFZ #FontTexture THEN
		IFF BuildFont () THEN RETURN $$FALSE
	END IF

	glGetIntegerv ($$GL_BLEND_SRC, &blend_src)		' enable overlay
	glGetIntegerv ($$GL_BLEND_DST, &blend_dst)
	glPushAttrib ($$GL_ALL_ATTRIB_BITS)
	glDisable ($$GL_LIGHTING)
	glDisable ($$GL_DEPTH_TEST)
	glBlendFunc ($$GL_SRC_ALPHA, $$GL_ONE_MINUS_SRC_ALPHA)
	glEnable ($$GL_BLEND)
	glMatrixMode ($$GL_PROJECTION)
	glPushMatrix ()
	glLoadIdentity ()
	gluOrtho2D (0.0, #Width, 0.0, #Height)
	glMatrixMode ($$GL_MODELVIEW)
	glPushMatrix ()
	glLoadIdentity ()
	glEnable ($$GL_TEXTURE_2D)										'  Enable Texture Mapping

	glBindTexture ($$GL_TEXTURE_2D, #FontTexture)
	glTranslated (x, y, 0)												'  Position The Text (0,0 - Top Left)
	glListBase (#FontBase - 32 + (128 * set))			'  Choose The Font Set (0 or 1)

	glScalef (scale, - scale, 1.0)								'  Set print size

	text$ = CSTRING$ (text)
	len = LEN (text$)
	glCallLists (len, $$GL_UNSIGNED_BYTE, text)		'  Write The Text To The Screen

	glDisable ($$GL_TEXTURE_2D)										' disable overlay
	glPopMatrix ()
	glMatrixMode ($$GL_PROJECTION)
	glPopMatrix ()
	glPopAttrib ()
	glBlendFunc (blend_src, blend_dst)

END FUNCTION

FUNCTION BuildFont ()
	SINGLE cx, cy
	SHARED FONT

	IFZ #FontTexture THEN
		#FontTexture = LoadTexture (&"Font.tga")
		IFZ #FontTexture THEN
			MessageBoxA ($$NULL, &"Unable to load 'Font.tga'.", &"BuildFont() Error", $$MB_OK)
			FONT = $$FALSE
			RETURN $$FALSE
		END IF
	ELSE
		IFT FONT THEN RETURN $$TRUE										'  font already built
	END IF

	#FontBase = glGenLists (256)										'  Creating 256 Display Lists
	glBindTexture ($$GL_TEXTURE_2D, #FontTexture)		'  Select Our Font Texture
	FOR loop = 0 TO 255															'  Loop Through All 256 Lists

		cx = SINGLE (loop MOD 16) / 16.0							'  X Position Of Current Character
		cy = SINGLE (loop / 16) / 16.0								'  Y Position Of Current Character

		glNewList (#FontBase + loop, $$GL_COMPILE)		'  Start Building A List
		glBegin ($$GL_QUADS)													'  Use A Quad For Each Character
		glTexCoord2f (cx, 1.0 - cy - 0.0625)					'  Texture Coord (Bottom Left)
		glVertex2d (0, 16)														'  Vertex Coord (Bottom Left)
		glTexCoord2f (cx + 0.0625, 1.0 - cy - 0.0625)	'  Texture Coord (Bottom Right)
		glVertex2i (16, 16)														'  Vertex Coord (Bottom Right)
		glTexCoord2f (cx + 0.0625, 1.0 - cy - 0.001)	'  Texture Coord (Top Right)
		glVertex2i (16, 0)														'  Vertex Coord (Top Right)
		glTexCoord2f (cx, 1.0 - cy - 0.001)						'  Texture Coord (Top Left)
		glVertex2i (0, 0)															'  Vertex Coord (Top Left)
		glEnd ()																			'  Done Building Our Quad (Character)
		glTranslated (14, 0, 0)												'  Move To The Right Of The Character
		glEndList ()

	NEXT loop

	FONT = $$TRUE
	RETURN $$TRUE

END FUNCTION

FUNCTION FillArray4f (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)

	SINGLEAT (array) = v1
	SINGLEAT (array + 4) = v2
	SINGLEAT (array + 8) = v3
	SINGLEAT (array + 12) = v4

END FUNCTION

END PROGRAM