'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This OpenGL/GLUT demo program displays
' the predefined teapot object.
' ---
' NOTE : Use the ESC key to exit the program. If you hit
'        the window close button on the titlebar, the
'        window will close, but the program will not exit
'        properly.
'
	PROGRAM "teapot"
'
	IMPORT	"xst"
	IMPORT  "xsx"
	IMPORT  "kernel32"
	IMPORT	"opengl32"
	IMPORT	"glu32"
	IMPORT	"glut32"
'
DECLARE  FUNCTION  Entry ()
DECLARE  FUNCTION  Init ()
DECLARE  CFUNCTION  Reshape (x, y)
DECLARE  FUNCTION  Shutdown ()
DECLARE  CFUNCTION  Display ()
DECLARE  CFUNCTION  KeyProc (key, x, y)
'
'
' ###################
' #####  Entry  #####
' ###################
'
FUNCTION  Entry ()

'	XioCreateConsole (title$, 100)

	XstGetCommandLineArguments (@argc, @argv$[])
	glutInit (&argc, &&argv$[])
	glutInitDisplayMode ($$GLUT_DOUBLE | $$GLUT_RGB | $$GLUT_DEPTH)

	glutInitWindowSize (400, 400)
	glutInitWindowPosition (100, 100)
	glutCreateWindow ("GLUT teapot demo.")

	Init ()

	glutDisplayFunc (&Display())
	glutReshapeFunc (&Reshape())
	glutKeyboardFunc (&KeyProc())

	glutMainLoop ()

'	XioFreeConsole ()


END FUNCTION
'
'
' #####################
' #####  Init ()  #####
' #####################
'
FUNCTION  Init ()

	glEnable ($$GL_BLEND)
	glBlendFunc ($$GL_ONE, $$GL_ONE)

END FUNCTION
'
'
' ########################
' #####  Reshape ()  #####
' ########################
'
CFUNCTION  Reshape (x, y)

	x# = DOUBLE (x)
	y# = DOUBLE (y)

	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity ()
	gluPerspective (90.0, x#/y#, 0.1, 100.0)
	glMatrixMode ($$GL_MODELVIEW)
	glViewport (0, 0, x, y)
	glutPostRedisplay ()

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
	glutKeyboardFunc (NULL)
	glutDestroyWindow (glutGetWindow ())

END FUNCTION
'
'
' ########################
' #####  Display ()  #####
' ########################
'
CFUNCTION  Display ()

	glClear ($$GL_COLOR_BUFFER_BIT OR $$GL_DEPTH_BUFFER_BIT)
  glClearColor (0.0, 0.0, 1.0, 0.0)
	glLoadIdentity ()
	glTranslatef (0.0, 0.0, -2.0)
	glColor3f (0.5, 0.25, 0.125)
	glutSolidTeapot (1.0)
	glutWireTeapot (1.0)
	glutSwapBuffers ()

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
END PROGRAM
