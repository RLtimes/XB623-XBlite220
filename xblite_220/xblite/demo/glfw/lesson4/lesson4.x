'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Ported from a VB example by Michael McElligott.  5/11/2002.
' Mapei_@hotmail.com
'
PROGRAM	"lesson4"
VERSION	"0.0001"
'
'	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "user32"    ' user32.dll
'	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "opengl32"
	IMPORT  "glu32"
	IMPORT	"glfw"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()
  XLONG running, frames, ok,fps
  XLONG x, y, width, height
  DOUBLE t0, t
  STRING titlestr

	glfwInit ()
	ok = glfwOpenWindow(640, 480, 0, 0, 0, 0, 16, 0, $$GLFW_WINDOW)
	IFZ ok THEN glfwTerminate (): EXIT FUNCTION

	glfwEnable ($$GLFW_STICKY_KEYS)

  ' Disable vertical sync (on cards that support it)
  glfwSwapInterval (0)

  ' Main loop
  running = 1
  frames = 0

  t0 = glfwGetTime ()

  DO WHILE (running = 1)
      ' Get time and mouse position
      t = glfwGetTime ()
      glfwGetMousePos (&x, &y)

      ' Calculate and display FPS (frames per second)
      IF (((t - t0) > 1#) || (frames = 0)) THEN
          fps = frames / (t - t0)
          titlestr = "Spinning Triangle (" + STRING (fps) + " FPS)"
          glfwSetWindowTitle (&titlestr)
          t0 = t
          frames = 0
      END IF
      INC frames

      ' Get window size (may be different than the requested size)
      glfwGetWindowSize (&width, &height)
      IF height < 1 THEN height = 2

      ' Set viewport
      glViewport (0, 0, width, height)

      ' Clear color buffer
      glClearColor (0#, 0#, 0#, 0#)
      glClear ($$GL_COLOR_BUFFER_BIT)

      ' Select and setup the projection matrix
      glMatrixMode ($$GL_PROJECTION)
      glLoadIdentity ()
      gluPerspective (65#, width / height, 1#, 100#)

      ' Select and setup the modelview matrix
      glMatrixMode ($$GL_MODELVIEW)
      glLoadIdentity ()
      gluLookAt (0#, 1#, 0#, 0#, 20#, 0#, 0#, 0#, 1#)

      ' Draw a rotating colorful triangle
      glTranslatef (0#, 14#, 0#)
      glRotatef ((0.3 * x) + (t * 100#), 0#, 0#, 1#)
      glBegin ($$GL_TRIANGLES)
          glColor3f (1#, 0#, 0#)
          glVertex3f (-5#, 0#, -4#)
          glColor3f (0#, 1#, 0#)
          glVertex3f (5#, 0#, -4#)
          glColor3f (0#, 0#, 1#)
          glVertex3f (0#, 0#, 6#)
      glEnd ()

      ' Swap buffers
'   	glFlush ()
      glfwSwapBuffers ()

      ' Check if the ESC key was pressed or the window was closed
      IF ((glfwGetKey($$GLFW_KEY_ESC) = 1) || (glfwGetWindowParam($$GLFW_OPENED) = 0)) THEN running = 0

  LOOP

  ' Close OpenGL window and terminate GLFW
  glfwTerminate ()

END FUNCTION
END PROGRAM
