' ========================================================================
' * Title:   GLBoing
' * Desc:    Tribute to Amiga Boing.
' * Author:  Jim Brooks  <gfx@jimbrooks.org>
' *          Original Amiga authors were R.J. Mical and Dale Luck.
' *          GLFW conversion by Marcus Geelnard
' * Notes:   - 360' = 2*PI [radian]
' *
' *          - Distances between objects are created by doing a relative
' *            Z translations.
' *
' *          - Although OpenGL enticingly supports alpha-blending,
' *            the shadow of the original Boing didn't affect the color
' *            of the grid.
' *
' *          - [Marcus] Changed timing scheme from interval driven to frame-
' *            time based animation steps (which results in much smoother
' *            movement)
' *
' * History of Amiga Boing:
' *
' * Boing was demonstrated on the prototype Amiga (codenamed "Lorraine") in
' * 1985. According to legend, it was written ad-hoc in one night by
' * R. J. Mical and Dale Luck. Because the bouncing ball animation was so fast
' * and smooth, attendees did not believe the Amiga prototype was really doing
' * the rendering. Suspecting a trick, they began looking around the booth for
' * a hidden computer or VCR.
' 
' XBLite\XBasic conversion by Michael McElligott 15/12/2002
' Mapei_@hotmail.com
' ========================================================================



' IMPORT "xst"
IMPORT "glfw"
IMPORT "opengl32"
IMPORT "glu32"
' IMPORT "kernel32"
IMPORT "msvcrt"

TYPE VERTEX_T
	SINGLE .x
	SINGLE .y
	SINGLE .z
END TYPE

$$RADIUS = 70.0
$$STEP_LONGITUDE = 22.5		'  22.5 makes 8 bands like original Boing
$$STEP_LATITUDE = 22.5
$$SHADOW_OFFSET_X = - 20.0
$$SHADOW_OFFSET_Y = 10.0
$$SHADOW_OFFSET_Z = 0.0
$$WALL_L_OFFSET = 0.0
$$WALL_R_OFFSET = 5.0
' Animation speed (50.0 mimics the original GLUT demo speed) '
$$ANIMATION_SPEED = 25.0
$$RAND_MAX = 4095


DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w, h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION key (k, action)

DECLARE FUNCTION SINGLE TruncateDeg (SINGLE deg)
DECLARE FUNCTION DOUBLE deg2rad (DOUBLE deg)
DECLARE FUNCTION DOUBLE sin_deg (DOUBLE deg)
DECLARE FUNCTION DOUBLE cos_deg (DOUBLE deg)
DECLARE FUNCTION CrossProduct (VERTEX_T a, VERTEX_T b, VERTEX_T c, VERTEX_T n)
DECLARE FUNCTION SINGLE PerspectiveAngle (SINGLE size, SINGLE dist)
DECLARE FUNCTION DrawBoingBall ()
DECLARE FUNCTION BounceBall (DOUBLE dt)
DECLARE FUNCTION DrawBoingBallBand (SINGLE long_lo, SINGLE long_hi)
DECLARE FUNCTION DrawGrid ()


FUNCTION Main ()
	SHARED DOUBLE t, t_old
	SHARED DOUBLE dt_total
	SHARED DOUBLE dt

	' XstCreateConsole ("Console", 50, @hStdOut, @hStdIn, @hConWnd)

	Create ()
	Init ()
	Resize (640, 480)

	' t_old = glfwGetTime()  - 0.01		'  Initialize timer
	event = 1
	DO

		' Timing
		t = glfwGetTime ()
		dt = (t - t_old)
		t_old = t

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

	glfwSetWindowTitle (&"XBlite Boing")
	glfwSetWindowSizeCallback (&Resize ())
	glfwSetKeyCallback (&key ())
	' glfwSetMousePosCallback (&MousePos())
	' glfwSetMouseButtonCallback (&MouseButton())
	glfwSwapInterval (1)

	glfwEnable ($$GLFW_KEY_REPEAT)
	#vsync = 1

END FUNCTION

FUNCTION key (k, action)

	IF (action != $$GLFW_PRESS) THEN RETURN

	SELECT CASE k

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

FUNCTION Render ()
	SHARED drawBallHow

	glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)
	glPushMatrix ()

	drawBallHow = #DRAW_BALL_SHADOW
	DrawBoingBall ()

	DrawGrid ()

	drawBallHow = #DRAW_BALL
	DrawBoingBall ()

	glPopMatrix ()
	glFlush ()

END FUNCTION

FUNCTION SINGLE TruncateDeg (SINGLE deg)

	IF (deg >= 360.0)
	RETURN (deg - 360.0)
ELSE
	RETURN deg
END IF

END FUNCTION

FUNCTION DOUBLE deg2rad (DOUBLE deg)

	RETURN deg / 360 * (2 * $$M_PI)

END FUNCTION

FUNCTION DOUBLE sin_deg (DOUBLE deg)

	RETURN sin (deg2rad (deg))

END FUNCTION

FUNCTION DOUBLE cos_deg (DOUBLE deg)

	RETURN cos (deg2rad (deg))

END FUNCTION

FUNCTION CrossProduct (VERTEX_T a, VERTEX_T b, VERTEX_T c, VERTEX_T n)
	SINGLE u1, u2, u3
	SINGLE v1, v2, v3

	u1 = b.x - a.x
	u2 = b.y - a.y
	u3 = b.y - a.z

	v1 = c.x - a.x
	v2 = c.y - a.y
	v3 = c.z - a.z

	n.x = u2 * v3 - v2 * v3
	n.y = u3 * v1 - v3 * u1
	n.z = u1 * v2 - v1 * u2

END FUNCTION

FUNCTION SINGLE PerspectiveAngle (SINGLE size, SINGLE dist)
	SINGLE radTheta, degTheta

	radTheta = 2.0 * atan2 (size / 2.0, dist)
	degTheta = (180.0 * radTheta) / $$M_PI
	RETURN degTheta

END FUNCTION


FUNCTION DrawBoingBall ()
	SHARED SINGLE deg_rot_y, deg_rot_y_inc
	SHARED SINGLE ball_x, ball_y, ball_x_inc, ball_y_inc
	SINGLE lon_deg
	SHARED drawBallHow
	SHARED DOUBLE dt_total, dt2, dt

	glPushMatrix ()
	glMatrixMode ($$GL_MODELVIEW)
	glTranslatef (0.0, 0.0, #DIST_BALL)

	' Update ball position and rotation (iterate if necessary) '
	dt_total = dt
	DO WHILE (dt_total > 0.0)

		IF dt_total > #MAX_DELTA_T# THEN dt2 = #MAX_DELTA_T# ELSE dt2 = dt_total
		dt_total = dt_total - dt2

		BounceBall (dt2)
		deg_rot_y = TruncateDeg (deg_rot_y + deg_rot_y_inc * (dt2 * $$ANIMATION_SPEED))

	LOOP

	' Set ball position '
	glTranslatef (ball_x, ball_y, 0.0)


	IF (drawBallHow == #DRAW_BALL_SHADOW) THEN
		glTranslatef ($$SHADOW_OFFSET_X, $$SHADOW_OFFSET_Y, $$SHADOW_OFFSET_Z)
	END IF

	glRotatef (- 20.0, 0.0, 0.0, 1.0)
	glRotatef (deg_rot_y, 0.0, 1.0, 0.0)

	glCullFace ($$GL_FRONT)
	glEnable ($$GL_CULL_FACE)
	glEnable ($$GL_NORMALIZE)

	FOR lon_deg = 0 TO 180 - 1 STEP $$STEP_LONGITUDE
		DrawBoingBallBand (lon_deg, lon_deg + $$STEP_LONGITUDE)
	NEXT lon_deg

	glPopMatrix ()

END FUNCTION

FUNCTION BounceBall (DOUBLE dt)
	SHARED SINGLE deg_rot_y, deg_rot_y_inc
	SHARED SINGLE ball_x, ball_y, ball_x_inc, ball_y_inc
	SINGLE sign, deg


	' Bounce on walls '
	IF (ball_x > (#BOUNCE_WIDTH / 2 + $$WALL_R_OFFSET)) THEN

		ball_x_inc = - 0.5 - 0.75 * SINGLE (rand ()) / SINGLE ($$RAND_MAX)
		deg_rot_y_inc = - deg_rot_y_inc

	END IF
	IF (ball_x < - (#BOUNCE_HEIGHT / 2 + $$WALL_L_OFFSET)) THEN

		ball_x_inc = 0.5 + 0.75 * SINGLE (rand ()) / SINGLE ($$RAND_MAX)
		deg_rot_y_inc = - deg_rot_y_inc
	END IF

	' Bounce on floor / roof '
	IF (ball_y > #BOUNCE_HEIGHT / 2) THEN

		ball_y_inc = - 0.75 - 1.0 * SINGLE (rand ()) / SINGLE ($$RAND_MAX)
	END IF
	IF (ball_y < - #BOUNCE_HEIGHT / 2 * 0.85) THEN

		ball_y_inc = 0.75 + 1.0 * SINGLE (rand ()) / SINGLE ($$RAND_MAX)
	END IF

	' Update ball position '
	ball_x = ball_x + ball_x_inc * (dt * $$ANIMATION_SPEED)
	ball_y = ball_y + ball_y_inc * (dt * $$ANIMATION_SPEED)

	IF (ball_y_inc < 0) THEN sign = - 1.0 ELSE sign = 1.0

	deg = (ball_y + #BOUNCE_HEIGHT / 2) * 90 / #BOUNCE_HEIGHT
	IF (deg > 80) THEN deg = 80
	IF (deg < 10) THEN deg = 10

	ball_y_inc = sign * 4.0 * sin_deg (deg)

END FUNCTION

FUNCTION DrawBoingBallBand (SINGLE long_lo, SINGLE long_hi)
	VERTEX_T vert_ne		'  "ne" means south-east, so on '
	VERTEX_T vert_nw
	VERTEX_T vert_sw
	VERTEX_T vert_se
	VERTEX_T vert_norm
	SINGLE lat_deg
	STATIC XLONG colorToggle
	SHARED drawBallHow

	' colorToggle = 0

	FOR lat_deg = 0 TO (360 - $$STEP_LATITUDE) STEP $$STEP_LATITUDE


		IF (colorToggle) THEN
			glColor3f (0.8, 0.1, 0.1)
		ELSE
			glColor3f (0.95, 0.95, 0.95)
		END IF

		' IF ( lat_deg >= 180 )
		' IF ( colorToggle )
		' glColor3f( 0.1, 0.8, 0.1 )
		' ELSE
		' glColor3f( 0.5, 0.5, 0.95 )
		' END IF
		' END IF

		IF colorToggle = 0 THEN colorToggle = 1 ELSE colorToggle = 0

		IF (drawBallHow == #DRAW_BALL_SHADOW)
		glColor3f (0.35, 0.35, 0.35)
	END IF

	vert_ne.y = cos_deg (long_hi) * $$RADIUS
	vert_nw.y = cos_deg (long_hi) * $$RADIUS
	vert_sw.y = cos_deg (long_lo) * $$RADIUS
	vert_se.y = cos_deg (long_lo) * $$RADIUS

	' * Assign each X,Z with sin,cos values scaled by latitude radius indexed by longitude.
	' * Eg, long=0 and long=180 are at the poles, so zero scale is sin(longitude),
	' * while long=90 (sin(90)=1) is at equator.
	' '
	vert_ne.x = cos_deg (lat_deg) * ($$RADIUS * sin_deg (long_lo + $$STEP_LONGITUDE))
	vert_se.x = cos_deg (lat_deg) * ($$RADIUS * sin_deg (long_lo))
	vert_nw.x = cos_deg (lat_deg + $$STEP_LATITUDE) * ($$RADIUS * sin_deg (long_lo + $$STEP_LONGITUDE))
	vert_sw.x = cos_deg (lat_deg + $$STEP_LATITUDE) * ($$RADIUS * sin_deg (long_lo))

	vert_ne.z = sin_deg (lat_deg) * ($$RADIUS * sin_deg (long_lo + $$STEP_LONGITUDE))
	vert_se.z = sin_deg (lat_deg) * ($$RADIUS * sin_deg (long_lo))
	vert_nw.z = sin_deg (lat_deg + $$STEP_LATITUDE) * ($$RADIUS * sin_deg (long_lo + $$STEP_LONGITUDE))
	vert_sw.z = sin_deg (lat_deg + $$STEP_LATITUDE) * ($$RADIUS * sin_deg (long_lo))

	glBegin ($$GL_POLYGON)

	CrossProduct (vert_ne, vert_nw, vert_sw, @vert_norm)
	glNormal3f (vert_norm.x, vert_norm.y, vert_norm.z)

	glVertex3f (vert_ne.x, vert_ne.y, vert_ne.z)
	glVertex3f (vert_nw.x, vert_nw.y, vert_nw.z)
	glVertex3f (vert_sw.x, vert_sw.y, vert_sw.z)
	glVertex3f (vert_se.x, vert_se.y, vert_se.z)

	glEnd ()

NEXT lat_deg

IF colorToggle = 0 THEN colorToggle = 1 ELSE colorToggle = 0

END FUNCTION

FUNCTION DrawGrid ()
	XLONG row, col
	XLONG rowTotal
	XLONG colTotal
	SINGLE widthLine
	SINGLE sizeCell
	SINGLE z_offset
	SINGLE xl, xr
	SINGLE yt, yb


	rowTotal = 12.0		'  must be divisible by 2 '
	colTotal = rowTotal		'  must be same as rowTotal '
	widthLine = 2.0		'  should be divisible by 2 '
	sizeCell = SINGLE (#GRID_SIZE) / rowTotal
	z_offset = - 40.0


	glPushMatrix ()
	glDisable ($$GL_CULL_FACE)

	' 
	' * Another relative Z translation to separate objects.
	' '
	glTranslatef (0.0, 0.0, #DIST_BALL)

	' 
	' Draw vertical lines (as skinny 3D rectangles).
	' 
	FOR col = 0 TO colTotal

		' 
		' * Compute co-ords of line.
		' 
		xl = - #GRID_SIZE / 2 + col * sizeCell
		xr = xl + widthLine

		yt = #GRID_SIZE / 2
		yb = - #GRID_SIZE / 2 - widthLine

		glBegin ($$GL_POLYGON)

		glColor3f (0.6, 0.1, 0.6)		'  purple '

		glVertex3f (xr, yt, z_offset)		'  NE '
		glVertex3f (xl, yt, z_offset)		'  NW '
		glVertex3f (xl, yb, z_offset)		'  SW '
		glVertex3f (xr, yb, z_offset)		'  SE '

		glEnd ()
	NEXT col

	' 
	' * Draw horizontal lines (as skinny 3D rectangles).
	' 
	FOR row = 0 TO rowTotal

		' 
		' Compute co-ords of line.
		' 
		yt = #GRID_SIZE / 2 - row * sizeCell
		yb = yt - widthLine

		xl = - #GRID_SIZE / 2
		xr = #GRID_SIZE / 2 + widthLine

		glBegin ($$GL_POLYGON)

		glColor3f (0.6, 0.1, 0.6)		'  purple '

		glVertex3f (xr, yt, z_offset)		'  NE '
		glVertex3f (xl, yt, z_offset)		'  NW '
		glVertex3f (xl, yb, z_offset)		'  SW '
		glVertex3f (xr, yb, z_offset)		'  SE '

		glEnd ()
	NEXT row

	glPopMatrix ()


END FUNCTION

FUNCTION Init ()
	SHARED drawBallHow
	SHARED SINGLE deg_rot_y, deg_rot_y_inc
	SHARED SINGLE ball_x, ball_y, ball_x_inc, ball_y_inc


	#GRID_SIZE = ($$RADIUS * 4.5)		'  length (width) of grid '
	#BOUNCE_HEIGHT = ($$RADIUS * 2.1)
	#BOUNCE_WIDTH = ($$RADIUS * 2.1)
	#DRAW_BALL = 1
	#DRAW_BALL_SHADOW = 2
	#MAX_DELTA_T# = 0.02
	#DIST_BALL = ($$RADIUS * 2.0 + $$RADIUS * 0.1)
	#VIEW_SCENE_DIST = (#DIST_BALL * 3.0 + 200.0)		' distance from viewer to middle of boing area '

	drawBallHow = #DRAW_BALL
	deg_rot_y = 0.0
	deg_rot_y_inc = 2.0
	ball_x = - $$RADIUS
	ball_y = - $$RADIUS
	ball_x_inc = 1.0
	ball_y_inc = 2.0

	glClearColor (0.55, 0.55, 0.55, 0.0)
	glShadeModel ($$GL_SMOOTH)
	' glPolygonMode( $$GL_FRONT_AND_BACK, $$GL_LINE )

END FUNCTION

FUNCTION Resize (Width, Height)

	#Width = Width
	#Height = Height

	IF (#Height < 50) THEN #Height = 50
	IF (#Width < 50) THEN #Width = 50

	glViewport (0, 0, #Width, #Height)
	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity ()
	' gluPerspective(50.0, SINGLE(#Width/#Height), 0.1, 200.0)

	gluPerspective (PerspectiveAngle ($$RADIUS * 2, 200), SINGLE (#Width / #Height), 0.1, #VIEW_SCENE_DIST)

	glMatrixMode ($$GL_MODELVIEW)
	glLoadIdentity ()

	gluLookAt (0.0, 0.0, #VIEW_SCENE_DIST, 0.0, 0.0, 0.0, .0, - 1.0, 0.0)

END FUNCTION

END PROGRAM