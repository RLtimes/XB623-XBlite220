'
' ####################
' #####  PROLOG  #####
' ####################
'
' A console program template
'
VERSION "0.0001"

	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
'	IMPORT  "xio"				' Console input/ouput library
'	IMPORT  "user32"		' user32.dll
'	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
'	IMPORT  "msvcrt"		' msvcrt.dll
	IMPORT  "opengl32"
	IMPORT  "glu32"
	IMPORT	"glfw"

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION Init ()
DECLARE FUNCTION Shut_Down (return_code)
DECLARE FUNCTION Main_Loop ()
DECLARE FUNCTION Draw ()
DECLARE FUNCTION Draw_Square (DOUBLE red, DOUBLE green, DOUBLE blue)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	Init ()
	Main_Loop ()
  Shut_Down (0)	

END FUNCTION

FUNCTION Init ()

	SHARED DOUBLE rotate_y, rotate_z, rotations_per_second
	DOUBLE aspect_ratio
	
	rotate_y = 0
	rotate_z = 0
	rotations_per_second = 0.2
	
  window_width = 800
  window_height = 600
  
  IF (glfwInit() != $$GL_TRUE) THEN Shut_Down(1)
	
  ' 800 x 600, 16 bit color, no depth, alpha or stencil buffers, windowed
  IF (glfwOpenWindow (window_width, window_height, 5, 6, 5, 0, 16, 0, $$GLFW_WINDOW) != $$GL_TRUE) THEN
    Shut_Down (1)
	END IF
  glfwSetWindowTitle (&"The GLFW Window")

  ' set the projection matrix to a normal frustum with a max depth of 50
  glMatrixMode ($$GL_PROJECTION)
  glLoadIdentity ()
  aspect_ratio = window_height / DOUBLE(window_width)
  glFrustum (.5, -.5, -.5 * aspect_ratio, .5 * aspect_ratio, 1, 50)
  glMatrixMode ($$GL_MODELVIEW)

END FUNCTION

FUNCTION Shut_Down (return_code)

	glfwTerminate ()
	QUIT (return_code)

END FUNCTION

FUNCTION Main_Loop ()

	DOUBLE old_time, current_time, delta_rotate
	SHARED DOUBLE rotate_y, rotate_z, rotations_per_second

	' the time of the previous frame
  old_time = glfwGetTime()
	
  ' this just loops as long as the program runs
  DO
    ' calculate time elapsed, and the amount by which stuff rotates
    current_time = glfwGetTime()
    delta_rotate = (current_time - old_time) * rotations_per_second * 360
    old_time = current_time
		
    ' escape to quit, arrow keys to rotate view
    IF (glfwGetKey ($$GLFW_KEY_ESC) == $$GLFW_PRESS) || (glfwGetWindowParam($$GLFW_OPENED) = 0) THEN EXIT DO
		
		IF (glfwGetKey ($$GLFW_KEY_LEFT) == $$GLFW_PRESS) THEN
      rotate_y = rotate_y + delta_rotate
		END IF
    IF (glfwGetKey ($$GLFW_KEY_RIGHT) == $$GLFW_PRESS) THEN
      rotate_y = rotate_y - delta_rotate
		END IF
		
    ' z axis always rotates
    rotate_z = rotate_z + delta_rotate

    ' clear the buffer
    glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)
		
    ' draw the figure
    Draw ()
		
    ' swap back and front buffers
    glfwSwapBuffers ()
  LOOP

END FUNCTION

FUNCTION Draw ()

	SHARED DOUBLE rotate_y, rotate_z, rotations_per_second
	DOUBLE red, blue

  ' reset view matrix
  glLoadIdentity ()
	
  ' move view back a bit
  glTranslatef (0, 0, -30)
	
  ' apply the current rotation
  glRotatef (rotate_y, 0, 1, 0)
  glRotatef (rotate_z, 0, 0, 1)
	
  ' by repeatedly rotating the view matrix during drawing, the
  ' squares end up in a circle
	squares = 15
  red = 0
	blue = 1
	
  FOR i = 0 TO squares-1 
    glRotatef (360.0/squares, 0, 0, 1)
    ' colors change for each square
    red = red + 1.0/12.0
    blue = blue - 1.0/12.0
    Draw_Square (red, .6, blue)
  NEXT i

END FUNCTION

FUNCTION Draw_Square (DOUBLE red, DOUBLE green, DOUBLE blue)

	'Draws a square with a gradient color at coordinates 0, 10
  glBegin ($$GL_QUADS)

    glColor3f (red, green, blue)
    glVertex2i (1, 11)
    glColor3f (red * .8, green * .8, blue * .8)
    glVertex2i (-1, 11)
    glColor3f (red * .5, green * .5, blue * .5)
    glVertex2i (-1, 9)
    glColor3f (red * .8, green * .8, blue * .8)
    glVertex2i (1, 9)

  glEnd ()

END FUNCTION
END PROGRAM