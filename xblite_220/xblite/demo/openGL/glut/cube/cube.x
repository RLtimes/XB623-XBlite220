'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This example is from the OpenGL Programming Guide.
' ---
' http://ask.ii.uib.no/ebt-bin/nph-dweb/dynaweb
' /SGI_Developer/OpenGL_PG
' ---
' Example 3-1 : Transformed Cube: cube.c

' NOTE : Use the ESC key to exit the program. If you hit
'        the window close button on the titlebar, the
'        window will close, but the program will not exit
'        properly.

	PROGRAM "cube"
'
	IMPORT	"xst"
	IMPORT  "xsx"
	IMPORT	"opengl32"
	IMPORT	"glu32"
	IMPORT	"glut32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  Init()
DECLARE CFUNCTION  Display()
DECLARE CFUNCTION  Reshape (w, h)
DECLARE CFUNCTION  KeyProc (key, x, y)
DECLARE FUNCTION  Shutdown ()
'
'
' ###################
' #####  Entry  #####
' ###################
'
FUNCTION Entry ()

	XstGetCommandLineArguments (@argc, @argv$[])
	glutInit(&argc, &&argv$[])
	glutInitDisplayMode ($$GLUT_SINGLE | $$GLUT_RGB)
	glutInitWindowSize (500, 400)
	glutInitWindowPosition (100, 100)
	glutCreateWindow (argv$[0])
	Init ()
	glutDisplayFunc(&Display())
	glutReshapeFunc(&Reshape())
	glutKeyboardFunc (&KeyProc())
	glutMainLoop()

END FUNCTION
'
'
' #####################
' #####  Init ()  #####
' #####################
'
FUNCTION Init()
   glClearColor (0.0, 0.0, 0.0, 0.0)
   glShadeModel ($$GL_FLAT)
END FUNCTION
'
'
' ########################
' #####  Display ()  #####
' ########################
'
CFUNCTION Display()

  glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)
  glColor3f (1.0, 1.0, 1.0)
  glLoadIdentity ()            'clear the matrix
'viewing transformation
  gluLookAt (0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
  glScalef (1.0, 2.0, 1.0)     'modeling transformation
  glutWireCube (1.0)
  glFlush ()

END FUNCTION
'
'
' ########################
' #####  Reshape ()  #####
' ########################
'
CFUNCTION Reshape (w, h)
	glViewport (0, 0, w, h)
  glMatrixMode ($$GL_PROJECTION)
  glLoadIdentity ()
  glFrustum (-1.0, 1.0, -1.0, 1.0, 1.5, 20.0)
  glMatrixMode ($$GL_MODELVIEW)
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
	glutKeyboardFunc (NULL)
	glutDestroyWindow (glutGetWindow ())
	QUIT (0)

END FUNCTION
END PROGRAM
