
' A simple polygon rendering example. 

VERSION "0.0001"

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
DECLARE FUNCTION Render ()
DECLARE FUNCTION KeyCB (k, action)
DECLARE FUNCTION NonlinearMap (DOUBLE x, DOUBLE y)

$$pi2 = 6.28318530718
$$K_max = 3.5
$$K_min = 0.1

FUNCTION Main ()

	wtype = $$GLFW_WINDOW		' or $$GLFW_FULLSCREEN 
	w = 300
	h = 300
	title$ = "Order to chaos"
	
	IFF CreateWindow (wtype, w, h, title$) THEN ShutDown ()
	IFF InitProgram () THEN ShutDown ()
	Loop ()
	ShutDown ()

END FUNCTION

FUNCTION InitProgram ()

	SHARED DOUBLE K, Delta_K
	
	K = 0.1
	Delta_K = 0.005

	glOrtho (0.0, $$pi2, 0.0, $$pi2, -1, 1)
	
	RETURN $$TRUE		

END FUNCTION

FUNCTION Render ()

	' draw image here

	DOUBLE Delta_x, x, y
	SHARED DOUBLE K, Delta_K
	
	' increase the stochastic parameter 
  K = K + Delta_K
  IF (K > $$K_max) THEN K = $$K_min

  NumberSteps = 1000
  NumberOrbits = 50

  Delta_x = $$pi2/DOUBLE((NumberOrbits-1))

  glColor3f (0.0, 0.0, 0.0)
  glClear ($$GL_COLOR_BUFFER_BIT)
  glColor3f (1.0, 1.0, 1.0)

  glBegin ($$GL_POINTS)

	FOR orbit = 0 TO NumberOrbits-1 
		y = 3.1415
		x = Delta_x * orbit
    FOR step = 0 TO NumberSteps - 1 
      NonlinearMap (@x, @y)
      glVertex2d (x, y)
		NEXT step
  NEXT orbit

	FOR orbit = 0 TO NumberOrbits-1
		x = 3.1415
    y = Delta_x * orbit
    FOR step = 0 TO NumberSteps - 1 
      NonlinearMap (@x, @y)
      glVertex2d (x, y)
		NEXT step
	NEXT orbit

  glEnd ()

END FUNCTION

FUNCTION Loop ()

	SHARED RunStatus, vsync

	RunStatus = 1
	DO
		Render ()
		IF vsync THEN glfwSleep (0.01)		' could also take into account Render() time too.
		glfwSwapBuffers ()
		IFZ glfwGetWindowParam ($$GLFW_OPENED) THEN RunStatus = 0
	LOOP WHILE RunStatus

END FUNCTION

FUNCTION ShutDown ()

	glfwTerminate ()

END FUNCTION

FUNCTION CreateWindow (wtype, w, h, title$)
	SHARED width, height, vsync

	IFZ glfwInit () THEN		' Init GLFW and open window
		MessageBoxA ($$NULL, &"Unable to initialize glfw library.   ", &"glfwInit() Error", $$MB_OK)
		RETURN
	END IF

	width = w
	height = h
	'	wtype = $$GLFW_WINDOW		'$$GLFW_FULLSCREEN
	' glfwOpenWindowHint   ( $$GLFW_REFRESH_RATE,85)	' use with care. Fullscreen mode only

	IFZ glfwOpenWindow (width, height, 0, 0, 0, 0, 32, 0, wtype) THEN
		MessageBoxA ($$NULL, &"Unable to create glfw window.   ", &"glfwOpenWindow() Error", $$MB_OK)
		RETURN
	END IF

	glfwSetWindowTitle (&title$)
	glfwSetKeyCallback (&KeyCB ())
	glfwEnable ($$GLFW_KEY_REPEAT)

	vsync = 1		' 1 = sync buffer swaps to monitor vertical sync rate, ie monitor refresh rate.
	glfwSwapInterval (vsync)

	RETURN $$TRUE

END FUNCTION

FUNCTION KeyCB (k, action)
	SHARED RunStatus, vsync

	IF (action != $$GLFW_PRESS) THEN RETURN

	SELECT CASE k

		CASE $$GLFW_KEY_ESC : RunStatus = 0		' exit program

		' CASE ' ' :

		CASE 'V' :
			IF vsync = 1 THEN
				vsync = 0
				glfwSwapInterval (vsync)
			ELSE
				vsync = 1
				glfwSwapInterval (vsync)
			END IF

			' CASE ELSE : RunStatus = 0		' exit program

	END SELECT

END FUNCTION


FUNCTION NonlinearMap (DOUBLE x, DOUBLE y)

	SHARED DOUBLE K

  ' Standard Map 

  y = y + (K * sin(x))
  x = x + y

  ' Angle x is mod 2Pi 

  x = fmod (x, $$pi2)
  IF (x < 0.0) THEN x = x + $$pi2

END FUNCTION

END PROGRAM