'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This OpenGL/GLUT example draws a rotating square.
' It is based on an example in Chapter 1 of the
' OpenGL Programming Guide
' http://ask.ii.uib.no/ebt-bin/nph-dweb/dynaweb/
' SGI_Developer/OpenGL_PG/@Generic__BookView;cs=fullhtml
' ---
' NOTE : Use the ESC key to exit the program. If you hit
'        the window close button on the titlebar, the
'        window will close, but the program will not exit
'        properly.
'
	PROGRAM "spinbox"
'
	IMPORT	"xst"
	IMPORT  "xsx"
	IMPORT	"opengl32"
	IMPORT	"glu32"
	IMPORT	"glut32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  Init()
DECLARE CFUNCTION  Reshape (w, h)
DECLARE CFUNCTION  SpinDisplay ()
DECLARE CFUNCTION  Display ()
DECLARE CFUNCTION  MouseProc (button, state, x, y)
DECLARE CFUNCTION  KeyProc (key, x, y)
DECLARE FUNCTION  Shutdown ()
'
'
' ###################
' #####  Entry  #####
' ###################
'
FUNCTION  Entry ()

' initialize glut dll and display mode

	XstGetCommandLineArguments (@argc, @argv$[])
	glutInit (&argc, &&argv$[])
	glutInitDisplayMode ($$GLUT_DOUBLE | $$GLUT_RGB)

' set window size and position, create window

	glutInitWindowSize (500, 500)
	glutInitWindowPosition (100, 50)
	glutCreateWindow ("Spinning Box Demo.")

' initialize drawing parameters

	Init ()

' assign callback functions

	glutDisplayFunc (&Display())
	glutReshapeFunc (&Reshape())
	glutMouseFunc (&MouseProc())
	glutKeyboardFunc (&KeyProc())
	glutIdleFunc (&SpinDisplay())

' enter the main loop

	glutMainLoop ()

END FUNCTION
'
'
' ##################
' #####  Init  #####
' ##################
'
FUNCTION  Init ()

	glClearColor (0.0, 0.0, 0.0, 1.0)
  glShadeModel ($$GL_FLAT)

END FUNCTION
'
'
' ########################
' #####  Reshape ()  #####
' ########################
'
CFUNCTION  Reshape (w, h)

	glViewport (0, 0, w, h)
  glMatrixMode ($$GL_PROJECTION)
  glLoadIdentity ()
  IF (w <= h) THEN
		glOrtho (-50.0, 50.0, -50.0*h/SINGLE(w), 50.0*w/SINGLE(h), -1.0, 1.0)
	ELSE
		glOrtho (50.0*w/SINGLE(h), 50.0*w/SINGLE(h), -50.0, 50.0, -1.0, 1.0)
	END IF
  glMatrixMode ($$GL_MODELVIEW)
	glLoadIdentity ()

END FUNCTION
'
'
' ############################
' #####  SpinDisplay ()  #####
' ############################
'
CFUNCTION  SpinDisplay ()

	SHARED spin
	spin = spin + 2.0
	IF (spin > 360.0) THEN spin = spin - 360.0
	glutPostRedisplay ()

END FUNCTION
'
'
' ########################
' #####  Display ()  #####
' ########################
'
CFUNCTION  Display ()

	SHARED spin

	glClear ($$GL_COLOR_BUFFER_BIT)
	glPushMatrix ()
	glRotatef (spin, 0.0, 0.0, 1.0)
	glColor3f (1.0, 1.0, 1.0)
	glRectf (-25.0, -25.0, 25.0, 25.0)
	glPopMatrix ()
	glFlush ()
	glutSwapBuffers ()

END FUNCTION
'
'
' ##########################
' #####  MouseProc ()  #####
' ##########################
'
CFUNCTION  MouseProc (button, state, x, y)

'	PRINT button, state, x, y

	SELECT CASE button
		CASE $$GLUT_LEFT_BUTTON  : glutIdleFunc (&SpinDisplay())
		CASE $$GLUT_RIGHT_BUTTON : glutIdleFunc (0)
	END SELECT

END FUNCTION
'
'
' ########################
' #####  KeyProc ()  #####
' ########################
'
CFUNCTION  KeyProc (key, x, y)

	key = key & 0xFF

	SELECT CASE key
		CASE 27 : Shutdown ()			' esc key pressed, so exit program
	END SELECT

END FUNCTION
'
'
' #########################
' #####  Shutdown ()  #####
' #########################
'
FUNCTION  Shutdown ()

	glutDisplayFunc (0)
	glutReshapeFunc (NULL)
	glutMouseFunc (NULL)
	glutKeyboardFunc (NULL)
	glutIdleFunc (NULL)
	glutDestroyWindow (glutGetWindow ())
	QUIT (0)

END FUNCTION
END PROGRAM
