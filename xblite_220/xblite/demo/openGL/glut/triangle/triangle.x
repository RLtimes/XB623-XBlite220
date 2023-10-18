'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This example program is discussed in
' Basics of GLUT, see First_GLUT_Program.html.
' It is also shown in the OpenGL Programming Guide.
' ---
' This OpenGL/GLUT demo displays a colored triangle.
' ---
' NOTE : Use the ESC key to exit the program. If you hit
'        the window close button on the titlebar, the
'        window will close, but the program will not exit
'        properly.
'
	PROGRAM "triangle"
'
	IMPORT	"xst"
	IMPORT  "xsx"
	IMPORT	"opengl32"
	IMPORT	"glu32"
	IMPORT	"glut32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  Init()
DECLARE CFUNCTION  SpinDisplay ()
DECLARE CFUNCTION  Display ()
DECLARE CFUNCTION  KeyProc (key, x, y)
DECLARE FUNCTION  Shutdown ()
'
'
' ###################
' #####  Entry  #####
' ###################
'
FUNCTION  Entry ()

	XstGetCommandLineArguments (@argc, @argv$[])
	glutInit (&argc, &&argv$[])																			' initializes the GLUT framework
	glutInitDisplayMode ($$GLUT_RGB | $$GLUT_DOUBLE | $$GLUT_DEPTH)	' sets up the display mode

'	glutInitWindowSize (500, 500)
	glutInitWindowPosition (100, 100)
	glutCreateWindow ("Draw a triangle.")														' creates a window

	glutDisplayFunc (&Display())			' specifies redraw callback function
	glutKeyboardFunc (&KeyProc())			' specifies keyboard event callback function

	Init ()														' initialize drawing parameters

	glutMainLoop ()										' enter the main loop

END FUNCTION
'
'
' ##################
' #####  Init  #####
' ##################
'
FUNCTION  Init ()

	glMatrixMode ($$GL_PROJECTION)				' changes the current matrix to the projection matrix

  gluPerspective (45, 1.0, 10.0, 200.0)	' sets up the projection matrix for a perspective transform
																				' gluPerspective (viewAngle, aspectRatio, nearClip, farClip)

	glMatrixMode ($$GL_MODELVIEW)					' changes the current matrix to the modelview matrix


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
	Display ()

END FUNCTION
'
'
' ########################
' #####  Display ()  #####
' ########################
'
CFUNCTION  Display ()

  glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)  ' clears the colour and depth buffers

  glPushMatrix ()          ' saves the current matrix on the top of the matrix stack
  glTranslatef (0,0,-100)  ' translates the current matrix 0 in x, 0 in y and -100 in z

  glBegin ($$GL_TRIANGLES) ' tells OpenGL that we're going to start drawing triangles
  	glColor3f (1,0,0)      ' sets the current colour to red
  	glVertex3f (-30,-30,0) ' specifies the first vertex of our triangle

  	glColor3f (0,1,0)      ' sets the current colour to green
  	glVertex3f (30,-30,0)  ' specifies the second vertex of our triangle

  	glColor3f (0,0,1)      ' sets the current colour to blue
  	glVertex3f (-30,30,0)  ' specifies the third vertex of our triangle
  glEnd ()                 ' tells OpenGL that we've finished drawing

	glPopMatrix ()           ' retrieves our saved matrix from the top of the matrix stack
	glutSwapBuffers ()       ' swaps the front and back buffers

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
