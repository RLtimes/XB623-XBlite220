'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Ported from a C example by Michael McElligott.  5/11/2002.
' Mapei_@hotmail.com
'
PROGRAM	"lesson8"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "user32"    ' user32.dll
'	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "opengl32"
	IMPORT  "glu32"
	IMPORT	"glfw"
	IMPORT	"xma"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  Draw ()



FUNCTION Entry ()
    STATIC XLONG    ok'             ' Flag telling if the window was opened
    STATIC XLONG    running'        ' Flag telling if the program is running

    ' Initialize GLFW
    glfwInit()'

    ' Open window
    ok = glfwOpenWindow(640, 480,8, 8, 8, 8, 24, 0, $$GLFW_WINDOW)
    ' If we could not open a window, exit now
    IFZ ok THEN glfwTerminate(): RETURN 0

    ' Set window title
    glfwSetWindowTitle( &"My OpenGL program" )

    ' Enable sticky keys
    glfwEnable( $$GLFW_STICKY_KEYS )

    ' Main rendering loop
    running=1
    DO WHILE (running=1)

        ' Call our rendering function
        Draw()
       ' Swap front and back buffers (we use a double buffered display)
        glfwSwapBuffers()'
        ' Check if the escape key was pressed, or if the window was closed
				IF ((glfwGetKey($$GLFW_KEY_ESC) = 1) OR (glfwGetWindowParam($$GLFW_OPENED) = 0)) THEN running = 0
    LOOP

    ' Terminate GLFW

    glfwTerminate()


END FUNCTION


FUNCTION  Draw ()

    XLONG width, height 								' Window dimensions
    DOUBLE t 								            ' Time (in seconds)
    XLONG quadric 											' GLU quadrics object
    DOUBLE field_of_view 								' Camera field of view
    DOUBLE camera_x, camera_y, camera_z ' Camera position
    XLONG i 

    ' Get current time
    t = glfwGetTime()'

    ' Get window size
    glfwGetWindowSize( &width, &height )

    ' Make sure that height is non-zero to avoid division by zero
    IFZ height THEN height =2

    ' Set viewport
    glViewport(0, 0, width, height)

    ' Clear color and depht buffers
    glClearColor( 0.0#, 0.0#, 0.0#, 0.0# )
    glClear( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT )

    ' Calculate field of view as a function of time
    field_of_view = 50.0 + 30.0*Sin( 0.5 * t) 

    ' Set up projection matrix
    glMatrixMode( $$GL_PROJECTION )      	' Select projection matrix
    glLoadIdentity()                 			' Start with an identity matrix
    gluPerspective(field_of_view,DOUBLE (width)/ DOUBLE (height), 1.0#, 100.0#)

    ' Calculate camera position
    camera_x = 20.0 * Cos( 0.3 * t )
    camera_z = 20.0 * Sin( 0.3 * t )
    camera_y = 4.0 + 1.0 * Sin( 1.0 * t )

    ' Set up modelview matrix
    glMatrixMode( $$GL_MODELVIEW )     	' Select modelview matrix
    glLoadIdentity()                 		' Start with an identity matrix
    gluLookAt(camera_x, camera_y, camera_z, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0)

    ' Enable Z buffering
    glEnable( $$GL_DEPTH_TEST )'
    glDepthFunc( $$GL_LEQUAL )'

    ' Draw a grid
    glColor3f( 0.7#, 1.0#, 1.0# )'
    glBegin( $$GL_LINES )
     FOR i = -10 TO 10   ' for( i = -10; i <= 10; i ++ )

        glVertex3f( SINGLE (-10.0), SINGLE(0.0), SINGLE (i) )  ' Line along X axis
        glVertex3f(  10.0#, 0.0#, SINGLE (i) )  ' -"-
        glVertex3f( SINGLE (i), 0.0#, -10.0# )  ' Line along Z axis
        glVertex3f( SINGLE (i), 0.0#,  10.0# )  ' -"-
    	INC i

     NEXT i
    glEnd()'

    ' Create a GLU quadrics object
    quadric = gluNewQuadric()'

    ' Draw a blue cone in the center
    glPushMatrix()
    glRotatef( -90.0#, 1.0#, 0.0#, 0.0# )
    glColor3f( 0.0#, 0.0#, 1.0# )
    gluCylinder( quadric, 1.5, 0.0, 4.0, 30, 30 )
    glPopMatrix()

    ' Draw four spheres in the corners of the grid
    glColor3f( 1.0#, 0.2#, 0.0# )'
    glPushMatrix()'
    glTranslatef( -9.0, 1.0, -9.0 )'
    gluSphere( quadric, 1.0, 30, 30 )'
    glPopMatrix()'
    glPushMatrix()'
    glTranslatef(  9.0, 1.0, -9.0 )'
    gluSphere( quadric, 1.0, 30, 30 )'
    glPopMatrix()'
    glPushMatrix()'
    glTranslatef( -9.0, 1.0,  9.0 )'
    gluSphere( quadric, 1.0, 30, 30 )'
    glPopMatrix()'
    glPushMatrix()'
    glTranslatef(  9.0, 1.0,  9.0 )'
    gluSphere( quadric, 1.0, 30, 30 )'
    glPopMatrix()'

    ' Destroy the GLU quadrics object
    gluDeleteQuadric( quadric )'


    RETURN 1




END FUNCTION
END PROGRAM
