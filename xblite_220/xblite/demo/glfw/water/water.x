' ========================================================================
' OpenGL Water
' 
' File		: water.c
' Date		: 28/12/00
' Author	: Mustata Bogdan (LoneRunner)
' 
' XBLite\XBasic conversion by Michael McElligott 8/12/2002
' Mapei_@hotmail.com
' ========================================================================

IMPORT "glfw"
IMPORT "opengl32"
IMPORT "glu32"
IMPORT "msvcrt"

DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w, h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadGLTexture (file)
DECLARE FUNCTION FillArray (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)
DECLARE FUNCTION FillArray3f (array, SINGLE v1, SINGLE v2, SINGLE v3)
DECLARE FUNCTION key (k, action)
DECLARE FUNCTION MousePos (x, y)
DECLARE FUNCTION MouseButton (button, state)

DECLARE FUNCTION Tex (texture)
DECLARE FUNCTION ResetSurface ()
DECLARE FUNCTION DrawSurface ()
DECLARE FUNCTION MakeNorm ()
DECLARE FUNCTION Wave ()


FUNCTION Main ()

	Create ()
	Init ()

	event = 1
	DO

		Render ()

		glfwSwapBuffers ()

		IF ((glfwGetKey ( 'Q') = 1) || glfwGetWindowParam ($$GLFW_OPENED) = 0) THEN event = 0

		IF (#vsync = 1) THEN glfwSleep (0.01)

	LOOP WHILE event = 1

	glfwTerminate ()

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
	glfwInit ()
	#Width = 640
	#Height = 480
	IFZ glfwOpenWindow (#Width, #Height, 16, 16, 16, 0, 32, 0, $$GLFW_WINDOW) THEN
		glfwTerminate ()
		RETURN 0
	END IF

	glfwSetWindowTitle (&"XBlite Water")
	glfwSetWindowSizeCallback (&Resize ())
	glfwSetKeyCallback (&key ())
	glfwSetMousePosCallback (&MousePos ())
	glfwSetMouseButtonCallback (&MouseButton ())
	glfwSwapInterval (1)

	glfwEnable ($$GLFW_KEY_REPEAT)
	#vsync = 1

END FUNCTION

FUNCTION key (k, action)
	SHARED texmode, envMap

	IF (action != $$GLFW_PRESS) THEN RETURN

	SELECT CASE k

		CASE ' ' :
			IF texmode = 0 THEN
				texmode = 1
				glEnable ($$GL_TEXTURE_2D)
				glEnable ($$GL_DEPTH_TEST)
				glEnable ($$GL_LIGHTING)
			ELSE
				texmode = 0
				glDisable ($$GL_TEXTURE_2D)
				glDisable ($$GL_DEPTH_TEST)
				glDisable ($$GL_LIGHTING)
			END IF

		CASE '1' : Tex (#texture1)
		CASE '2' : Tex (#texture2)
		CASE '3' : Tex (#texture3)
		CASE '4' : Tex (#texture4)

		CASE 'E' :
			IF envMap = $$TRUE THEN
				envMap = $$FALSE
				glBindTexture ($$GL_TEXTURE_2D, #ltex)
				glTexEnvf ($$GL_TEXTURE_ENV, $$GL_TEXTURE_ENV_MODE, $$GL_DECAL)
				glTexGeni ($$GL_S, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
				glTexGeni ($$GL_T, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
				glEnable ($$GL_TEXTURE_GEN_S)
				glEnable ($$GL_TEXTURE_GEN_T)
			ELSE
				envMap = $$TRUE
				glBindTexture ($$GL_TEXTURE_2D, #ltex)
				glTexEnvf ($$GL_TEXTURE_ENV, $$GL_TEXTURE_ENV_MODE, $$GL_MODULATE)
				glDisable ($$GL_TEXTURE_GEN_S)
				glDisable ($$GL_TEXTURE_GEN_T)
			END IF


		CASE 'R' : ResetSurface ()
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

FUNCTION MousePos (x, y)

	SHARED SINGLE eye[], rot[], surf[]
	SHARED mx, my, mButton, mOldX, mOldY
	SHARED hw, LEFT, RIGHT, size
	ULONG m, n

	REDIM surf[100, 100, 2]

	mx = x
	my = y

	IF (mButton == LEFT) THEN

		m = ULONG ((SINGLE (x) / SINGLE (#Width)) * SINGLE (size))
		n = ULONG ((SINGLE (y) / SINGLE (#Height)) * SINGLE (size))

		surf[m, n, 1] = hw
		surf[m, n + 1, 1] = hw
		surf[m + 1, n, 1] = hw
		surf[m + 1, n + 1, 1] = hw

	ELSE

		IF (mButton == RIGHT) THEN

			eye[2] = eye[2] - ((mOldY - y) * 180.0) / 200.0
			' clamp (@rot[])
			FOR i = 0 TO 2
				IF ((rot[i] > 360) OR (rot[i] < - 360)) THEN
					rot[i] = 0
				END IF
			NEXT i

		END IF
	END IF

	mOldX = mx
	mOldY = my

END FUNCTION


FUNCTION MouseButton (button, state)
	SHARED mButton, LEFT, RIGHT
	SHARED mx, my, mOldX, mOldY

	IF (state == $$GLFW_PRESS) THEN

		mOldX = mx
		mOldY = my

		SELECT CASE button

			CASE $$GLFW_MOUSE_BUTTON_LEFT: mButton = LEFT
			CASE $$GLFW_MOUSE_BUTTON_RIGHT: mButton = RIGHT

		END SELECT

	ELSE
		IF (state == $$GLFW_RELEASE) THEN mButton = - 1
	END IF

END FUNCTION

FUNCTION ResetSurface ()
	SHARED SINGLE surf[]
	SHARED SINGLE force[], veloc[]
	SHARED size
	UBYTE i, j

	FOR i = 0 TO size
		FOR j = 0 TO size

			surf[i, j, 0] = (SINGLE (i) / size * 100)
			surf[i, j, 1] = 0
			surf[i, j, 2] = (SINGLE (j) / size * 100)

			force[i, j] = 0.0
			veloc[i, j] = 0.0

		NEXT j
	NEXT i

END FUNCTION

FUNCTION DrawSurface ()
	SHARED SINGLE rot[], eye[], norm[], surf[]
	SHARED SINGLE tval
	SHARED texmode, size
	XLONG i, j

	glTranslatef (-eye[0], - eye[1], - eye[2])

	glRotatef (rot[0], 1.0, 0.0, 0.0)
	glRotatef (rot[1], 0.0, 1.0, 0.0)
	glRotatef (rot[2], 0.0, 0.0, 1.0)

	IF (texmode) = 1 THEN

		glColor3f (1, 1, 1)
		glBindTexture ($$GL_TEXTURE_2D, #ltex)

		FOR j = 0 TO size - 2		' (j=0 j<size-1 j++)

			glBegin ($$GL_TRIANGLE_STRIP)
			FOR i = 0 TO size - 1

				glTexCoord2f (SINGLE (i * tval), SINGLE (j * tval))
				glNormal3f (SINGLE (norm[i, j, 0]), SINGLE (norm[i, j, 1]), SINGLE (norm[i, j, 2]))
				glVertex3f (SINGLE (surf[i, j, 0]), SINGLE (surf[i, j, 1]), SINGLE (surf[i, j, 2]))

				glTexCoord2f (SINGLE (i * tval), SINGLE ((j + 1) * tval))
				glNormal3f (SINGLE (norm[i, (j + 1), 0]), SINGLE (norm[i, (j + 1), 1]), SINGLE (norm[i, j + 1, 2]))
				glVertex3f (SINGLE (surf[i, j + 1, 0]), SINGLE (surf[i, j + 1, 1]), SINGLE (surf[i, j + 1, 2]))

			NEXT i
			glEnd ()

		NEXT j

	ELSE

		glColor3f (1, 1, 1)
		FOR i = 0 TO size - 2
			FOR j = 0 TO size - 2

				glBegin ($$GL_LINE_STRIP)
				glVertex3f (SINGLE (surf[i, j, 0]), SINGLE (surf[i, j, 1]), SINGLE (surf[i, j, 2]))
				glVertex3f (SINGLE (surf[i + 1, j, 0]), SINGLE (surf[i + 1, j, 1]), SINGLE (surf[i + 1, j, 2]))
				glVertex3f (SINGLE (surf[i + 1, j + 1, 0]), SINGLE (surf[i + 1, j + 1, 1]), SINGLE (surf[i + 1, j + 1, 2]))
				glVertex3f (SINGLE (surf[i, j + 1, 0]), SINGLE (surf[i, j + 1, 1]), SINGLE (surf[i, j + 1, 2]))
				glVertex3f (SINGLE (surf[i, j, 0]), SINGLE (surf[i, j, 1]), SINGLE (surf[i, j, 2]))
				glEnd ()

			NEXT j
		NEXT i

		glColor3f (0, 1, 0)
		FOR i = 0 TO size - 1
			FOR j = 0 TO size - 1

				glBegin ($$GL_LINES)
				glVertex3f (SINGLE (surf[i, j, 0]), SINGLE (surf[i, j, 1]), SINGLE (surf[i, j, 2]))
				glVertex3f (SINGLE (surf[i, j, 0] + norm[i, j, 0]), SINGLE (surf[i, j, 1] + norm[i, j, 1]), SINGLE (surf[i, j, 2] + norm[i, j, 2]))
				glEnd ()
			NEXT j
		NEXT i

	END IF
END FUNCTION

FUNCTION MakeNorm ()
	SHARED SINGLE norm[], surf[], a[], b[], c[]
	SHARED size
	SINGLE c
	UBYTE i, j

	FOR i = 0 TO (size - 1)
		FOR j = 0 TO (size - 1)

			IF ((i <> size - 1) AND (j <> size - 1)) THEN

				' sub(@a[], i,j+1, i,j)
				a[0] = surf[i, j + 1, 0] - surf[i, j, 0]
				a[1] = surf[i, j + 1, 1] - surf[i, j, 1]
				a[2] = surf[i, j + 1, 2] - surf[i, j, 2]

				' sub(@b[], i+1,j, i,j)
				b[0] = surf[i + 1, j, 0] - surf[i, j, 0]
				b[1] = surf[i + 1, j, 1] - surf[i, j, 1]
				b[2] = surf[i + 1, j, 2] - surf[i, j, 2]
			ELSE
				' sub(@a[], i,j-1, i,j)

				IF j <> 0 THEN
					a[0] = surf[i, j - 1, 0] - surf[i, j, 0]
					a[1] = surf[i, j - 1, 1] - surf[i, j, 1]
					a[2] = surf[i, j - 1, 2] - surf[i, j, 2]
				END IF
				' sub(@b[], i-1,j, i,j)
				IF i <> 0 THEN
					b[0] = surf[i - 1, j, 0] - surf[i, j, 0]
					b[1] = surf[i - 1, j, 1] - surf[i, j, 1]
					b[2] = surf[i - 1, j, 2] - surf[i, j, 2]
				END IF

			END IF

			' cross(@c[], @a[], @b[])
			c[0] = a[1] * b[2] - a[2] * b[1]
			c[1] = a[2] * b[0] - a[0] * b[2]
			c[2] = a[0] * b[1] - a[1] * b[0]

			' normz(@c[])
			c = sqrt (c[0] * c[0] + c[1] * c[1] + c[2] * c[2])
			c[0] = c[0] / c
			c[1] = c[1] / c
			c[2] = c[2] / c

			IF ((i == 0) AND (j == (size - 1))) THEN

				' sub(@a[], i,j-1, i,j)
				a[0] = surf[i, j - 1, 0] - surf[i, j, 0]
				a[1] = surf[i, j - 1, 1] - surf[i, j, 1]
				a[2] = surf[i, j - 1, 2] - surf[i, j, 2]
				' sub(@b[], i+1,j, i,j)
				b[0] = surf[i + 1, j, 0] - surf[i, j, 0]
				b[1] = surf[i + 1, j, 1] - surf[i, j, 1]
				b[2] = surf[i + 1, j, 2] - surf[i, j, 2]

				' cross(@c[], @a[], @b[])
				c[0] = a[1] * b[2] - a[2] * b[1]
				c[1] = a[2] * b[0] - a[0] * b[2]
				c[2] = a[0] * b[1] - a[1] * b[0]
				' normz(@c[])
				c = sqrt (c[0] * c[0] + c[1] * c[1] + c[2] * c[2])
				c[0] = c[0] / c
				c[1] = c[1] / c
				c[2] = c[2] / c

				c[0] = - c[0]
				c[1] = - c[1]
				c[2] = - c[2]

			END IF

			' copy (@norm[i,j], @c[])
			norm[i, j, 0] = c[0]
			norm[i, j, 1] = c[1]
			norm[i, j, 2] = c[2]

		NEXT j
	NEXT i

END FUNCTION

FUNCTION Wave ()
	SHARED SINGLE norm[], surf[], force[], veloc[], SQRTOFTWOINV, dt
	SHARED size
	XLONG i, j
	SINGLE d

	FOR i = 0 TO size - 1
		FOR j = 0 TO size - 1
			force[i, j] = 0.0
		NEXT j
	NEXT i

	FOR i = 1 TO size - 2
		FOR j = 1 TO size - 2

			d = surf[i, j, 1] - surf[i, j - 1, 1]
			force[i, j] = force[i, j] - d
			force[i, j - 1] = force[i, j - 1] + d

			d = surf[i - 1, j, 1] - surf[i - 1, j, 1]
			force[i, j] = force[i, j] - d
			force[i - 1, j] = force[i - 1, j] + d

			d = surf[i, j, 1] - surf[i, j + 1, 1]
			force[i, j] = force[i, j] - d
			force[i, j + 1] = force[i, j + 1] + d

			d = surf[i, j, 1] - surf[i + 1, j, 1]
			force[i, j] = force[i, j] - d
			force[i + 1, j] = force[i + 1, j] + d

			d = surf[i, j, 1] - surf[i + 1, j + 1, 1] * SQRTOFTWOINV
			force[i, j] = force[i, j] - d
			force[i + 1, j + 1] = force[i + 1, j + 1] + d

			d = surf[i, j, 1] - surf[i - 1, j - 1, 1] * SQRTOFTWOINV
			force[i, j] = force[i, j] - d
			force[i - 1, j - 1] = force[i - 1, j - 1] + d

			d = surf[i, j, 1] - surf[i + 1, j - 1, 1] * SQRTOFTWOINV
			force[i, j] = force[i, j] - d
			force[i + 1, j - 1] = force[i + 1, j - 1] + d

			d = surf[i, j, 1] - surf[i + 1, j - 1, 1] * SQRTOFTWOINV
			force[i, j] = force[i, j] - d
			force[i + 1, j - 1] = force[i + 1, j - 1] + d

		NEXT j
	NEXT i


	FOR i = 0 TO size - 1
		FOR j = 0 TO size - 1
			veloc[i, j] = veloc[i, j] + force[i, j] * dt
		NEXT j
	NEXT i

	FOR i = 0 TO size - 1
		FOR j = 0 TO size - 1
			surf[i, j, 1] = surf[i, j, 1] + veloc[i, j]

			' IF (surf[i,j,1]>0) THEN
			' surf[i,j,1] = surf[i,j,1] - surf[i,j,1] / SINGLE (size)
			' ELSE
			surf[i, j, 1] = surf[i, j, 1] - surf[i, j, 1] / SINGLE (size)
			' END IF

		NEXT j
	NEXT i

END FUNCTION



FUNCTION Render ()

	glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)

	glPushMatrix ()
	DrawSurface ()

	MakeNorm ()
	Wave ()

	glPopMatrix ()
	glFlush ()

	RETURN $$TRUE		'  Keep Going

END FUNCTION

FUNCTION Init ()
	SHARED SINGLE SQRTOFTWOINV, eye[], rot[], dt, tval
	SHARED SINGLE force[], veloc[], surf[], norm[]
	SHARED mButton, texmode, envMap, size
	SHARED SINGLE a[], b[], c[]
	SHARED hw, LEFT, RIGHT

	SQRTOFTWOINV = SINGLE (1.0) / SINGLE (1.414213562)
	LEFT = 0
	RIGHT = 1
	mButton = - 1
	texmode = 1
	envMap = 1
	size = 25
	hw = 10
	dt = SINGLE (0.02)
	tval = SINGLE (1.0 / 25)

	DIM surf[100, 100, 2]
	DIM norm[100, 100, 2]
	DIM force[100, 100]
	DIM veloc[100, 100]
	DIM LightAmbient[3]
	DIM LightDiffuse[3]
	DIM LightPosition[3]
	DIM eye[2]
	DIM rot[2]

	DIM a[2]
	DIM b[2]
	DIM c[2]

	FillArray (&LightAmbient[], 1.0, 1.0, 1.0, 1.0)
	FillArray (&LightDiffuse[], 1.0, 1.0, 1.0, 1.0)
	FillArray (&LightPosition[], 0.0, 0.0, - 20.0, 1.0)
	FillArray3f (&eye[], 68.0, 0.0, 100.0)
	FillArray3f (&rot[], 45.0, 50.0, 0.0)

	glHint ($$GL_LINE_SMOOTH_HINT, $$GL_NICEST)
	glHint ($$GL_POLYGON_SMOOTH_HINT, $$GL_NICEST)
	glHint ($$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)

	glLightfv ($$GL_LIGHT1, $$GL_AMBIENT, &LightAmbient[])
	glLightfv ($$GL_LIGHT1, $$GL_DIFFUSE, &LightDiffuse[])
	glLightfv ($$GL_LIGHT1, $$GL_POSITION, &LightPosition[])
	glEnable ($$GL_LIGHT1)

	glEnable ($$GL_TEXTURE_2D)
	glEnable ($$GL_DEPTH_TEST)
	glEnable ($$GL_LIGHTING)

	#texture1 = LoadGLTexture (&"phong.tga")
	#texture2 = LoadGLTexture (&"64firery.tga")
	#texture3 = LoadGLTexture (&"tex1.tga")
	#texture4 = LoadGLTexture (&"back.tga")

	#ltex = #texture2
	glBindTexture ($$GL_TEXTURE_2D, #ltex)
	glTexEnvf ($$GL_TEXTURE_ENV, $$GL_TEXTURE_ENV_MODE, $$GL_DECAL)
	glTexGeni ($$GL_S, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
	glTexGeni ($$GL_T, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
	glEnable ($$GL_TEXTURE_GEN_S)
	glEnable ($$GL_TEXTURE_GEN_T)

	ResetSurface ()

END FUNCTION

FUNCTION Tex (texture)
	SHARED envMap

	glBindTexture ($$GL_TEXTURE_2D, texture)

	IF envMap = $$FALSE THEN
		glTexEnvf ($$GL_TEXTURE_ENV, $$GL_TEXTURE_ENV_MODE, $$GL_DECAL)
		glTexGeni ($$GL_S, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
		glTexGeni ($$GL_T, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
		glEnable ($$GL_TEXTURE_GEN_S)
		glEnable ($$GL_TEXTURE_GEN_T)
	END IF

	#ltex = texture

END FUNCTION


FUNCTION Resize (Width, Height)

	#Width = Width
	#Height = Height

	IF (#Height < 50) THEN #Height = 50
	IF (#Width < 50) THEN #Width = 50

	glViewport (0, 0, #Width, #Height)
	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity ()
	gluPerspective (65.0, SINGLE (#Width / #Height), 1, 300.0)
	glMatrixMode ($$GL_MODELVIEW)
	glLoadIdentity ()

END FUNCTION

FUNCTION LoadGLTexture (file)

	' load and set texture
	texture = 0
	glGenTextures (4, &texture)

	glBindTexture ($$GL_TEXTURE_2D, texture)

	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR)

	glfwLoadTexture2D (file, 0)

	RETURN texture

END FUNCTION

FUNCTION FillArray (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)

	SINGLEAT (array) = v1
	SINGLEAT (array + 4) = v2
	SINGLEAT (array + 8) = v3
	SINGLEAT (array + 12) = v4

END FUNCTION

FUNCTION FillArray3f (array, SINGLE v1, SINGLE v2, SINGLE v3)

	SINGLEAT (array) = v1
	SINGLEAT (array + 4) = v2
	SINGLEAT (array + 8) = v3

END FUNCTION

END PROGRAM