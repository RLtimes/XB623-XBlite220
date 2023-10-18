' ========================================================================
' * Wave Simulation in OpenGL
' * (C) 2002 Jakob Thomsen
' * http://home.in.tum.de/~thomsen
' * Modified for GLFW by Sylvain Hellegouarch - sh@programmationworld.com
' * Modified for variable frame rate by Marcus Geelnard
' 
' XBLite/XBasic conversion by Michael McElligott  15/12/2002
' Mapei_@hotmail.com
' ========================================================================


' IMPORT "xst"
IMPORT "glfw"
IMPORT "opengl32"
IMPORT "glu32"
' IMPORT "kernel32"
IMPORT "msvcrt"

TYPE Vertex
	SINGLE .x
	SINGLE .y
	SINGLE .z
	SINGLE .r
	SINGLE .g
	SINGLE .b
END TYPE


DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE CFUNCTION Resize (w, h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadTexture (file)
DECLARE CFUNCTION key (k, action)
DECLARE CFUNCTION MousePos (x, y)
DECLARE CFUNCTION MouseButton (button, state)


DECLARE FUNCTION DOUBLE mod (DOUBLE value, DOUBLE modulo)
DECLARE FUNCTION adjustGrid ()
DECLARE FUNCTION initVertices ()
DECLARE FUNCTION initSurface ()
DECLARE FUNCTION calc ()


' Animation speed (10.0 looks good)
$$ANIMATION_SPEED = 8.0

$$GRIDW = 100
$$GRIDH = 100


FUNCTION Main ()
	SHARED DOUBLE t, t_old
	SHARED DOUBLE dt_total
	SHARED SINGLE dt

	' XstCreateConsole ("Console", 50, @hStdOut, @hStdIn, @hConWnd)
	Create ()		'  Initialize OpenGL
	Init ()

	initVertices ()		'  Initialize simulation
	initSurface ()
	adjustGrid ()

	t_old = glfwGetTime () - 0.01		'  Initialize timer
	event = 1
	DO

		' Timing
		t = glfwGetTime ()
		dt_total = (t - t_old)

		t_old = t

		DO WHILE (dt_total > 0.0)		'  Safety - iterate if dt_total is too large

			' Select iteration time step
			IF dt_total > #MAX_DELTA_T! THEN dt = #MAX_DELTA_T! ELSE dt = dt_total
			dt_total = dt_total - dt

			calc ()		'  Calculate wave propagation
		LOOP


		adjustGrid ()		'  Compute height of each vertex
		Render ()

		glfwSwapBuffers ()

		IF ((glfwGetKey ( 'Q') = 1) || glfwGetWindowParam ($$GLFW_OPENED) = 0) THEN event = 0

		IF (#vsync = 1) THEN glfwSleep (0.01)

	LOOP WHILE event = 1

	glfwTerminate ()
	' XstFreeConsole ()

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
	glfwInit ()
	IFZ glfwOpenWindow (640, 480, 0, 0, 0, 0, 16, 0, $$GLFW_WINDOW) THEN
		glfwTerminate ()
		RETURN 0
	END IF

	glfwSetWindowTitle (&"XBlite Wave Simulation")
	glfwSetWindowSizeCallback (&Resize ())
	glfwSetKeyCallback (&key ())
	glfwSetMousePosCallback (&MousePos ())
	glfwSetMouseButtonCallback (&MouseButton ())
	glfwSwapInterval (1)

	glfwEnable ($$GLFW_KEY_REPEAT)
	#vsync = 1

END FUNCTION

CFUNCTION key (k, action)
SHARED envMap

IF (action != $$GLFW_PRESS) THEN RETURN

SELECT CASE k

	CASE 'W' :
		INC #wavet
		IF #wavet = 4 THEN #wavet = 0
		IF #wavet = 1 THEN
			glPolygonMode ($$GL_FRONT_AND_BACK, $$GL_FILL)
		ELSE
			glPolygonMode ($$GL_FRONT_AND_BACK, $$GL_LINE)
		END IF

	CASE 'C' :
		IF #cmode = 1 THEN #cmode = 0 ELSE #cmode = 1
		initVertices ()

	CASE ' ' :
		initSurface ()

	CASE 'L' :
		IF #freelook = 1 THEN #freelook = 0 ELSE #freelook = 1

	CASE 'V' :
		IF #vsync = 1 THEN
			glfwSwapInterval (0)
			#vsync = 0
		ELSE
			glfwSwapInterval (1)
			#vsync = 1
		END IF

END SELECT


END FUNCTION

CFUNCTION MouseButton (button, state)
SHARED mButton, mLeft, mRight

IF (state == $$GLFW_PRESS) THEN

	SELECT CASE button
		CASE $$GLFW_MOUSE_BUTTON_RIGHT: mButton = mRight
	END SELECT

ELSE
	IF (state == $$GLFW_RELEASE) THEN mButton = 0
END IF

END FUNCTION

CFUNCTION MousePos (x, y)
SHARED mButton, mLeft, mRight
SHARED mx, my, mOldY, mOldX
SHARED SINGLE zoom

mx = x
my = y
IF mButton = mRight THEN
	zoom = zoom - ((mOldY - my) * 180.0) / 8000.0
END IF

mOldX = mx
mOldY = my

END FUNCTION


FUNCTION Render ()
	SHARED SINGLE zoom, beta, alpha
	SHARED ULONG quad[]
	SHARED my, mx, mButton, mRight

	' Clear the color and depth buffers.
	glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)

	' We don't want to modify the projection matrix.
	glMatrixMode ($$GL_MODELVIEW)
	glLoadIdentity ()

	glTranslatef (0.0, 0.0, - zoom)

	IFZ #freelook THEN
		' Rotate the view
		glRotatef (beta, 1.0, 0.0, 0.0)
		glRotatef (alpha, 0.0, 0.0, 1.0)
	ELSE

		IF mButton <> mRight THEN
			glRotatef (SINGLE (mx - (#Width / 2)), 0.0, 1.0, 0.0)
			glRotatef (SINGLE (my - (#Height / 2)), 1.0, 0.0, 0.0)
		END IF
	END IF


	SELECT CASE #wavet
		CASE 0: glDrawArrays ($$GL_POINTS, 0, #VERTEXNUM)		'  Points only
		CASE 1: glDrawElements ($$GL_QUADS, 4 * #QUADNUM, $$GL_UNSIGNED_INT, &quad[])
		CASE 2: glDrawElements ($$GL_LINES, 4 * #QUADNUM, $$GL_UNSIGNED_INT, &quad[])
		CASE 3: glDrawElements ($$GL_QUADS, 4 * #QUADNUM, $$GL_UNSIGNED_INT, &quad[])
	END SELECT

END FUNCTION

FUNCTION initVertices ()
	SHARED Vertex vertex[]
	SHARED ULONG quad[]
	XLONG x, y, p


	' place the vertices in a grid
	FOR y = 0 TO $$GRIDH
		FOR x = 0 TO $$GRIDW

			p = (y * $$GRIDW) + x

			' vertex[p].x = (-$$GRIDW/2)+ x + sin (2.0 * $$M_PI * DOUBLE(y) / DOUBLE ($$GRIDH))
			' vertex[p].y = (-$$GRIDH/2)+ y + cos (2.0 * $$M_PI * DOUBLE(x) / DOUBLE ($$GRIDW))
			' vertex[p].x = SINGLE ((SINGLE (x)- SINGLE ( SINGLE ($$GRIDW) / SINGLE(2) ) /  ( SINGLE ($$GRIDW) / SINGLE(2) )))
			' vertex[p].y =  SINGLE ((SINGLE (y)- SINGLE( SINGLE ($$GRIDH) / SINGLE(2) ) /  ( SINGLE ($$GRIDH) / SINGLE(2) )))
			vertex[p].x = (x - $$GRIDW / 2.0) / ($$GRIDW / 2.0)
			vertex[p].y = (y - $$GRIDH / 2.0) / ($$GRIDH / 2.0)
			vertex[p].z = 0		' sin(d * $$M_PI)

			IF #cmode = 0 THEN
				IF (x MOD 4 < 2) ^ (y MOD 4 < 2) THEN vertex[p].r = 0.0 ELSE vertex[p].r = 1.0
				vertex[p].g = SINGLE (y) / (SINGLE ($$GRIDH))
				vertex[p].b = 1.0 - (SINGLE (x) / SINGLE ($$GRIDW) + (SINGLE (y) / SINGLE ($$GRIDH)) / 2.0)
			ELSE
				vertex[p].r = SINGLE (x) / SINGLE ($$GRIDW)
				vertex[p].g = SINGLE (y) / SINGLE ($$GRIDH)
				vertex[p].b = 1.0 - (SINGLE (x) / SINGLE ($$GRIDW) + SINGLE (y) / SINGLE ($$GRIDH)) / 2.0
			END IF

		NEXT x
	NEXT y

	FOR y = 0 TO #QUADH
		FOR x = 0 TO #QUADW

			p = 4 * (y * #QUADW + x)

			' first quad
			quad[p] = y * $$GRIDW + x		'  some point
			quad[p + 1] = y * $$GRIDW + x + 1		'  neighbor at the right side
			quad[p + 2] = (y + 1) * $$GRIDW + x + 1		'  upper right neighbor
			quad[p + 3] = (y + 1) * $$GRIDW + x		'  upper neighbor
		NEXT x
	NEXT y

END FUNCTION

FUNCTION initSurface ()
	SHARED SINGLE p[], vx[], vy[]
	XLONG x, y
	DOUBLE d2, d


	FOR y = 0 TO $$GRIDH
		FOR x = 0 TO $$GRIDW

			d2 = pow (x - ($$GRIDW / 2), 2) + pow (y - $$GRIDH / 2, 2)
			d = sqrt (d2)

			IF d < (0.1 * ($$GRIDW / 2)) THEN
				d = d * 10.0
				p[x, y] = - cos (d * $$M_PI / ($$GRIDW / 2) / 2) * 100
			ELSE
				p[x, y] = 0.0
			END IF

			vx[x, y] = 0
			vy[x, y] = 0

		NEXT x
	NEXT y

END FUNCTION

' Calculate wave propagation
FUNCTION calc ()
	SHARED SINGLE p[], vx[], vy[], ax[], ay[]
	SHARED ULONG quad[]
	XLONG x, y, y2, x2
	DOUBLE d
	SINGLE time_step
	SHARED SINGLE dt

	time_step = (dt * ($$ANIMATION_SPEED))

	' compute accelerations
	FOR x = 0 TO $$GRIDW
		x2 = (mod (x + 1, $$GRIDW))
		FOR y = 0 TO $$GRIDH
			d = p[x, y] - p[x2, y]
			ax[x, y] = d
		NEXT y
	NEXT x

	FOR y = 0 TO $$GRIDH
		y2 = (mod (y + 1, $$GRIDH))
		FOR x = 0 TO $$GRIDW
			d = p[x, y] - p[x, y2]
			ay[x, y] = d
		NEXT x
	NEXT y

	' compute speeds
	FOR x = 0 TO $$GRIDW
		FOR y = 0 TO $$GRIDH
			vx[x, y] = vx[x, y] + ax[x, y] * time_step
			vy[x, y] = vy[x, y] + ay[x, y] * time_step
		NEXT y
	NEXT x

	' compute pressure
	FOR x = 0 TO $$GRIDW
		x2 = (mod (x - 1, $$GRIDW))
		FOR y = 0 TO $$GRIDH
			y2 = (mod (y - 1, $$GRIDH))
			p[x, y] = p[x, y] + XLONG (vx[x2, y] - vx[x, y] + vy[x, y2] - vy[x, y]) * time_step
		NEXT y
	NEXT x

END FUNCTION


' Modify the height of each vertex according to the pressure.
FUNCTION adjustGrid ()
	SHARED SINGLE p[], vx[], vy[], ax[], ay[]
	SHARED ULONG quad[]
	SHARED Vertex vertex[]
	XLONG pos, x, y

	FOR y = 0 TO $$GRIDH
		FOR x = 0 TO $$GRIDW

			pos = y * $$GRIDW + x
			vertex[pos].z = p[x, y] * (1.0 / 50.0)

		NEXT x
	NEXT y


END FUNCTION

FUNCTION DOUBLE mod (DOUBLE value, DOUBLE modulo)

	RETURN value - (modulo * floor (value / modulo))

END FUNCTION

FUNCTION Init ()
	SHARED Vertex vertex[], temp
	SHARED SINGLE alpha, beta, zoom, dt
	SHARED SINGLE p[], vx[], vy[], ax[], ay[]
	SHARED ULONG quad[]
	SHARED mButton, mLeft, mRight


	#VERTEXNUM = $$GRIDW * $$GRIDH
	#QUADW = $$GRIDW - 1
	#QUADH = $$GRIDH - 1
	#QUADNUM = #QUADW * #QUADH
	#MAX_DELTA_T! = 0.1
	#wavet = 1

	alpha = 210
	beta = -65
	zoom = 2
	dt = 0
	mButton = 0
	mLeft = 1
	mRight = 2

	DIM p[$$GRIDW, $$GRIDH]
	DIM vx[$$GRIDW, $$GRIDH]
	DIM vy[$$GRIDW, $$GRIDH]
	DIM ax[$$GRIDW, $$GRIDH]
	DIM ay[$$GRIDW, $$GRIDH]
	DIM vertex[#VERTEXNUM]
	DIM quad[4 * #QUADNUM]

	glShadeModel ($$GL_SMOOTH)		'  Our shading model--Gouraud (smooth).

	' Culling.
	' glCullFace( $$GL_BACK)
	' glFrontFace( $$GL_CCW)
	' glEnable( $$GL_CULL_FACE)


	glEnable ($$GL_DEPTH_TEST)		'  Switch on the z-buffer.
	glHint ($$GL_LINE_SMOOTH_HINT, $$GL_NICEST)
	glHint ($$GL_POLYGON_SMOOTH_HINT, $$GL_NICEST)
	glHint ($$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)

	glEnableClientState ($$GL_VERTEX_ARRAY)
	glEnableClientState ($$GL_COLOR_ARRAY)
	glVertexPointer (3, $$GL_FLOAT, SIZE (temp), &vertex[])
	glColorPointer (3, $$GL_FLOAT, SIZE (temp), &vertex[0].r)		' Pointer to the first color
	glPointSize (2.0)

	' Background color is black.
	glClearColor (0, 0, 0, 0)
	glPolygonMode ($$GL_FRONT_AND_BACK, $$GL_FILL)

END FUNCTION


CFUNCTION Resize (Width, Height)
SINGLE ratio

#Width = Width
#Height = Height

IF (#Height < 50) THEN #Height = 50
IF (#Width < 50) THEN #Width = 50

IF #Height > 0 THEN
	ratio = SINGLE (#Width) / SINGLE (#Height)
ELSE
	ratio = 1
END IF

glViewport (0, 0, #Width, #Height)
glMatrixMode ($$GL_PROJECTION)
glLoadIdentity ()
gluPerspective (60.0, ratio, 0.1, 1024.0)
glMatrixMode ($$GL_MODELVIEW)
glLoadIdentity ()

END FUNCTION

FUNCTION LoadTexture (file)
	STATIC XLONG textid, text[]

	IFZ textid THEN
		textid = 1
		DIM text[texture]
	END IF


	INC textid
	REDIM text[textid]

	glGenTextures (1, &text[textid])
	glBindTexture ($$GL_TEXTURE_2D, text[textid])
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR)
	glfwLoadTexture2D (file, 0)

	RETURN text[textid]

END FUNCTION

END PROGRAM