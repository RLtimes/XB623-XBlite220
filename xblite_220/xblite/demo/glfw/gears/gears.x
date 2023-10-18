'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Ported from a C example by Michael McElligott.  7/11/2002.
' Mapei_@hotmail.com
'
PROGRAM	"gears"
VERSION	"0.0001"

	IMPORT	"xst"
	IMPORT  "opengl32"
	IMPORT  "glu32"
	IMPORT	"glfw"
	IMPORT  "xma"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  init ()
DECLARE FUNCTION  gear  (SINGLE inner_radius, SINGLE outer_radius, SINGLE width,XLONG  teeth, SINGLE tooth_depth)
DECLARE FUNCTION  draw  ()
DECLARE FUNCTION  animate ()
DECLARE FUNCTION  key (k, action)
DECLARE FUNCTION  reshape (width, height)


' program entry '
FUNCTION Entry ()


'XstCreateConsole ("", 50, @hStdOut, @hStdIn, @hConWnd)

    ' Init GLFW and open window
    glfwInit ()
    IFZ glfwOpenWindow (300, 300, 0, 0, 0, 0, 16, 0, $$GLFW_WINDOW) THEN
        glfwTerminate ()
        RETURN 0
    END IF

    glfwSetWindowTitle (&"Gears")
'    glfwEnable ($$GLFW_KEY_REPEAT)
'    glfwSwapInterval (0)

    ' Special args?
    init ()

    ' Set callback functions
    glfwSetWindowSizeCallback (&reshape())
    glfwSetKeyCallback (&key())

    ' Main loop
    #running=1
    DO WHILE (#running=1)

        ' Draw gears
        draw ()

        ' Update animation
        animate ()

        ' Swap buffers
        glfwSwapBuffers ()

        ' Was the window closed?
        IF glfwGetWindowParam ($$GLFW_OPENED) = 0 THEN #running = 0

    LOOP

  'XstFreeConsole ()
   ' Terminate GLFW
    glfwTerminate ()

END FUNCTION


' program & OpenGL initialization '
FUNCTION init()

 #running = 1
 #t0# = 0.0
 #Frames = 0
 #autoexit = 0

 #view_rotx! = 20.0
 #view_roty! = 30.0
 #view_rotz! = 0.0
 #angle! = 0.0


  DIM pos! [3]
  DIM red! [3]
  DIM green! [3]
  DIM blue! [3]


  pos![0]=5.0
  pos![1]=5.0
  pos![2]=10.0
  pos![3]=0.0

  red![0]=0.8
  red![1]=0.1
  red![2]=0.0
  red![3]=1.0

  green![0]=0.0
  green![1]=0.8
  green![2]=0.2
  green![3]=1.0

  blue![0]=0.2
  blue![1]=0.2
  blue![2]=1.0
  blue![3]=1.0

  glLightfv ($$GL_LIGHT0, $$GL_POSITION, &pos![])
  glEnable ($$GL_CULL_FACE)
  glEnable ($$GL_LIGHTING)
  glEnable ($$GL_LIGHT0)
  glEnable ($$GL_DEPTH_TEST)


  ' make the gears '
  #gear1 = glGenLists (1)
  glNewList (#gear1, $$GL_COMPILE)
  glMaterialfv ($$GL_FRONT, $$GL_AMBIENT_AND_DIFFUSE, &red![])
  gear (1.0, 4.0, 1.0, 20, 0.7)
  glEndList ()

  #gear2 = glGenLists (1)
  glNewList (#gear2, $$GL_COMPILE)
  glMaterialfv ($$GL_FRONT, $$GL_AMBIENT_AND_DIFFUSE, &green![])
  gear (0.5, 2.0, 2.0, 10, 0.7)
  glEndList ()

  #gear3 = glGenLists (1)
  glNewList (#gear3, $$GL_COMPILE)
  glMaterialfv ($$GL_FRONT, $$GL_AMBIENT_AND_DIFFUSE, &blue![])
  gear (1.3, 2.0, 0.5, 10, 0.7)
  glEndList ()

END FUNCTION

'*

'  Draw a gear wheel.  You'll probably want to call this function when
 ' building a display list Since we do a lot of trig here.
'
 ' Input:  inner_radius - radius of hole at center
  '        outer_radius - radius at center of teeth
 '  '       width - width of gear
  '        teeth - number of teeth
  '        tooth_depth - depth of tooth'
'
 '

FUNCTION  gear (SINGLE inner_radius, SINGLE outer_radius, SINGLE width,XLONG  teeth, SINGLE tooth_depth)
  SINGLE r0, r1, r2
  DOUBLE da
  SINGLE u, v, len

  r0 = inner_radius
  r1 = outer_radius - tooth_depth / 2.0
  r2 = outer_radius + tooth_depth / 2.0

   da = (SINGLE(2.0) * $$PI) / teeth / SINGLE(4.0)
  glShadeModel ($$GL_FLAT)
  glNormal3f (0.0, 0.0, 1.0)

  ' draw front face '
  glBegin ($$GL_QUAD_STRIP)

  FOR i=0 TO teeth
    #angle! = (i * SINGLE(2.0) * $$PI) / teeth
    glVertex3f (r0 * Cos(#angle!), r0 * Sin(#angle!), width * 0.5)
    glVertex3f (r1 * Cos(#angle!), r1 * Sin(#angle!), width * 0.5)
    IF (i < teeth) THEN
      glVertex3f (r0 * Cos(#angle!), r0 * Sin(#angle!), width * 0.5)
      glVertex3f (r1 * Cos(#angle! + 3 * da), r1 * Sin(#angle! + 3 * da), width * 0.5)
    END IF
  NEXT i

  glEnd ()

  ' draw front sides of teeth '
  glBegin ($$GL_QUADS)
   da = (SINGLE(2.0) * $$PI) / teeth / SINGLE(4.0)

  FOR i=0 TO teeth
    #angle! = (i * 2.0 * $$PI) / teeth
    glVertex3f (r1 * Cos(#angle!), r1 * Sin(#angle!), width * 0.5)
    glVertex3f (r2 * Cos(#angle! + da), r2 * Sin(#angle! + da), width * 0.5)
    glVertex3f (r2 * Cos(#angle! + 2 * da), r2 * Sin(#angle! + 2 * da), width * 0.5)
    glVertex3f (r1 * Cos(#angle! + 3 * da), r1 * Sin(#angle! + 3 * da), width * 0.5)
  NEXT i

  glEnd ()
  glNormal3f (0.0, 0.0, -1.0)

  ' draw back face '
  glBegin($$GL_QUAD_STRIP)
  FOR i=0 TO teeth
    #angle! = (i * 2.0 * $$PI) / teeth
    glVertex3f (r1 * Cos(#angle!), r1 * Sin(#angle!), -width * 0.5)
    glVertex3f (r0 * Cos(#angle!), r0 * Sin(#angle!), -width * 0.5)
    IF (i < teeth) THEN
      glVertex3f (r1 * Cos(#angle! + 3 * da), r1 * Sin(#angle! + 3 * da), -width * 0.5)
      glVertex3f (r0 * Cos(#angle!), r0 * Sin(#angle!), -width * 0.5)
    END IF
  NEXT i
  glEnd()

  ' draw back sides of teeth '
  glBegin($$GL_QUADS)
   da = 2.0 * $$PI / teeth / 4.0
  FOR i=0 TO teeth
    #angle! = (i * 2.0 * $$PI) / teeth

    glVertex3f (r1 * Cos(#angle! + 3 * da), r1 * Sin(#angle! + 3 * da), -width * 0.5)
    glVertex3f (r2 * Cos(#angle! + 2 * da), r2 * Sin(#angle! + 2 * da), -width * 0.5)
    glVertex3f (r2 * Cos(#angle! + da), r2 * Sin(#angle! + da), -width * 0.5)
    glVertex3f (r1 * Cos(#angle!), r1 * Sin(#angle!), -width * 0.5)
  NEXT i
  glEnd()

  ' draw outward faces of teeth '
  glBegin($$GL_QUAD_STRIP)
  FOR i=0 TO teeth
    #angle! = i * 2.0 * $$PI / teeth

    glVertex3f (r1 * Cos(#angle!), r1 * Sin(#angle!), width * 0.5)
    glVertex3f (r1 * Cos(#angle!), r1 * Sin(#angle!), -width * 0.5)
    u = r2 * Cos(#angle! + da) - r1 * Cos(#angle!)
    v = r2 * Sin(#angle! + da) - r1 * Sin(#angle!)
    len = Sqrt((u * u) + (v * v))
        u =u / len
    v =v / len
    glNormal3f (v, -u, 0.0)
    glVertex3f (r2 * Cos(#angle! + da), r2 * Sin(#angle! + da), width * 0.5)
    glVertex3f (r2 * Cos(#angle! + da), r2 * Sin(#angle! + da), -width * 0.5)
    glNormal3f (Cos(#angle!), Sin(#angle!), 0.0)
    glVertex3f (r2 * Cos(#angle! + 2 * da), r2 * Sin(#angle! + 2 * da), width * 0.5)
    glVertex3f (r2 * Cos(#angle! + 2 * da), r2 * Sin(#angle! + 2 * da), -width * 0.5)
    u = r1 * Cos(#angle! + 3 * da) - r2 * Cos(#angle! + 2 * da)
    v = r1 * Sin(#angle! + 3 * da) - r2 * Sin(#angle! + 2 * da)
    glNormal3f  (v, -u, 0.0)
    glVertex3f (r1 * Cos(#angle! + 3 * da), r1 * Sin(#angle! + 3 * da), width * 0.5)
    glVertex3f (r1 * Cos(#angle! + 3 * da), r1 * Sin(#angle! + 3 * da), -width * 0.5)
    glNormal3f (Cos(#angle!), Sin(#angle!), 0.0)
  NEXT i

  glVertex3f (r1 * Cos(0), r1 * Sin(0), width * 0.5)
  glVertex3f (r1 * Cos(0), r1 * Sin(0), -width * 0.5)

  glEnd ()
  glShadeModel ($$GL_SMOOTH)

  ' draw inside radius cylinder '
  glBegin ($$GL_QUAD_STRIP)
  FOR i=0 TO teeth
    #angle! = (i * 2.0 * $$PI) / teeth
    glNormal3f (-Cos(#angle!), -Sin(#angle!), 0.0)
    glVertex3f (r0 * Cos(#angle!), r0 * Sin(#angle!), -width * 0.5)
    glVertex3f (r0 * Cos(#angle!), r0 * Sin(#angle!), width * 0.5)
  NEXT i
  glEnd()


END FUNCTION



' OpenGL draw function & timing '
FUNCTION draw()
	STATIC SINGLE t
	XLONG fps

  glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)

  glPushMatrix ()
    glRotatef (#view_rotx!, 1.0, 0.0, 0.0)
    glRotatef (#view_roty!, 0.0, 1.0, 0.0)
    glRotatef (#view_rotz!, 0.0, 0.0, 1.0)

    glPushMatrix ()
      glTranslatef (-3.0, -2.0, #depth)
      glRotatef (#angle!, 0.0, 0.0, 1.0)
      glCallList (#gear1)
    glPopMatrix ()

    glPushMatrix ()
      glTranslatef (3.1, -2.0, #depth)
      glRotatef (-2.0 * #angle! - 9.0, 0.0, 0.0, 1.0)
      glCallList (#gear2)
    glPopMatrix ()

    glPushMatrix ()
      glTranslatef (-3.1, 4.2, #depth)
      glRotatef (-2.0 * #angle! - 25.0, 0.0, 0.0, 1.0)
      glCallList (#gear3)
    glPopMatrix ()

  glPopMatrix ()

  INC #Frames

  t_new! = glfwGetTime ()
  #dt# = t_new! - t
  t = t_new!

'  IF ((t - #t0#) > 1)
'       seconds = t - #t0#
'       IFZ seconds THEN seconds=2
'       fps = #Frames / seconds

'       title$ = "Gears: fps " + STRING$(fps)
'       glfwSetWindowTitle (&title$)

'       #t0# = t
'       #Frames = 0
'  END IF

END FUNCTION


' update animation parameters '
FUNCTION animate ()

  #angle! = #angle! + 100.0 * #dt#

END FUNCTION



' change view #angle!, exit upon ESC '
FUNCTION  key (k, action)

  IF (action != $$GLFW_PRESS) THEN RETURN

  SELECT CASE k
  CASE 'Z':

    IF glfwGetKey ($$GLFW_KEY_LSHIFT) THEN
      #view_rotz! = #view_rotz! - 5.0
    ELSE
      #view_rotz! = #view_rotz! + 5.0
    END IF

  CASE $$GLFW_KEY_ESC:
    #running = 0

  CASE $$GLFW_KEY_UP:
    #view_rotx! = #view_rotx! + 5.0

  CASE $$GLFW_KEY_DOWN:
    #view_rotx! = #view_rotx! - 5.0

  CASE $$GLFW_KEY_LEFT:
    #view_roty! = #view_roty! +5.0

  CASE $$GLFW_KEY_RIGHT:
    #view_roty! = #view_roty! -5.0

   CASE $$GLFW_KEY_PAGEUP
    INC #depth ' =#depth

   CASE $$GLFW_KEY_PAGEDOWN
    DEC #depth ' =#depth

  END SELECT


END FUNCTION

' new window size '
FUNCTION reshape (width, height)

  h! = SINGLE (height) / SINGLE (width)

  glViewport (0, 0, width, height)
  glMatrixMode ($$GL_PROJECTION)
  glLoadIdentity ()

  glFrustum (-1.0, 1.0, -h!, h!, 5.0, 60.0)
  glMatrixMode ($$GL_MODELVIEW)
  glLoadIdentity ()
  glTranslatef (0.0, 0.0, -40.0)

END FUNCTION
END PROGRAM
