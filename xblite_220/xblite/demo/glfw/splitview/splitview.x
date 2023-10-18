 ' ========================================================================
 '  This is a small test application for GLFW.
 '  The program uses a "split window" view, rendering four views of the
 '  same scene in one window (e.g. uesful for 3D modelling software). This
 '  demo uses scissors to separete the four dIFferent rendering areas from
 '  each other.
 '
 '  (If the code seems a little bit strange here and there, it may be
 '   because I am not a friend of orthogonal projections)
 '
 '  Marcus Geelnard
 '  marcus.geelnard@home.se
 '  http://hem.passagen.se/opengl/glfw/
 '
 ' XBLite/XBasic port and modifications by Michael McElligott 9/11/2002
 ' Mapei_@hotmail.com
 ' ========================================================================

	IMPORT	"xst"
	IMPORT  "opengl32"
	IMPORT  "glu32"
	IMPORT	"glfw"
	IMPORT  "xma"

DECLARE FUNCTION Entry ()
DECLARE FUNCTION DrawTorus ()
DECLARE FUNCTION DrawScene (w,h,DOUBLE t)
DECLARE FUNCTION DrawAllViews (DOUBLE t)
DECLARE FUNCTION WindowSizeFun (w,h)
DECLARE FUNCTION MousePosFun  (x,y)
DECLARE FUNCTION MouseButtonFun (b,action)
DECLARE FUNCTION KeyFun (k,action)
DECLARE FUNCTION DrawGrid ( SINGLE scale, XLONG steps )

 ' ========================================================================
 '  Global variables
 ' ========================================================================

 $$TORUS_MAJOR    = 1.5
 $$TORUS_MINOR    = 0.5


FUNCTION Entry ()

    XLONG     running
    DOUBLE  t

     '  Initialise GLFW
    glfwInit()

     '  Open OpenGL window
    IFZ glfwOpenWindow( 500, 500, 0,0,0,0, 16,0, $$GLFW_WINDOW ) THEN
    	glfwTerminate()
    	RETURN 0
    END IF

     '  Set window title
    glfwSetWindowTitle( &"Split view demo" )

     '  Enable sticky keys
    glfwEnable( $$GLFW_STICKY_KEYS )

     '  Enable mouse cursor (only needed for fullscreen mode)
    glfwEnable( $$GLFW_MOUSE_CURSOR )

     '  Set callback functions
    glfwSetWindowSizeCallback( &WindowSizeFun() )
    glfwSetMousePosCallback( &MousePosFun() )
    glfwSetMouseButtonCallback( &MouseButtonFun() )
    glfwSetKeyCallback( &KeyFun() )

    running=1
    #TORUS_MAJOR_RES = 32
    #TORUS_MINOR_RES = 32

    '  Main loop
    DO WHILE (running=1)

         '  Get time
        t = glfwGetTime()

         '  Draw all views
        DrawAllViews( t )

         '  Swap buffers
        glfwSwapBuffers()

         '  Check IF the ESC key was pressed or the window was closed
	IF ((glfwGetKey($$GLFW_KEY_ESC) = 1) || (glfwGetWindowParam($$GLFW_OPENED) = 0)) THEN running = 0

    LOOP

     '  Close OpenGL window and terminate GLFW
    glfwTerminate()

END FUNCTION

 ' ========================================================================
 '  DrawTorus() - Draw a solid torus (use a display list for the model)
 ' ========================================================================

FUNCTION DrawTorus ()
    SHARED torus_list
    XLONG    i, j, k
    DOUBLE s, t, x, y, z, nx, ny, nz, scale, twopi

    IFZ torus_list THEN

         '  Start recording displaylist
        torus_list = glGenLists( 1 )
        glNewList( torus_list, $$GL_COMPILE_AND_EXECUTE )

         '  Draw torus
        twopi = 2.0 * $$PI
        FOR i=0 TO#TORUS_MINOR_RES   ' for( i = 0  i <#TORUS_MINOR_RES  i++ )

            glBegin( $$GL_QUAD_STRIP )
            FOR j=0 TO #TORUS_MAJOR_RES ' for( j = 0  j <= #TORUS_MAJOR_RES  j++ )

                FOR k=1 TO 0 STEP -1  ' for( k = 1  k >= 0  k-- )

                    s = (i + k) -#TORUS_MINOR_RES + 0.5  ' %
                    t = j - #TORUS_MAJOR_RES   ' %

                     '  Calculate point on surface
                    x = ($$TORUS_MAJOR+ $$TORUS_MINOR*Cos(s*twopi/#TORUS_MINOR_RES)) * Cos(t*twopi/ #TORUS_MAJOR_RES)
                    y = $$TORUS_MINOR * Sin(s * twopi /#TORUS_MINOR_RES)
                    z = ($$TORUS_MAJOR+ $$TORUS_MINOR*Cos(s*twopi/#TORUS_MINOR_RES)) * Sin(t*twopi/ #TORUS_MAJOR_RES)

                     '  Calculate surface normal
                    nx = x - $$TORUS_MAJOR*Cos(t*twopi/ #TORUS_MAJOR_RES)
                    ny = y
                    nz = z - $$TORUS_MAJOR*Sin(t*twopi/ #TORUS_MAJOR_RES)
                    scale = 1.0 / Sqrt( nx*nx + ny*ny + nz*nz )
                    nx =nx * scale
                    ny =ny * scale
                    nz =nz * scale

                    glNormal3f( SINGLE (nx), SINGLE (ny), SINGLE (nz) )
                    glVertex3f( SINGLE (x), SINGLE (y), SINGLE (z) )
                NEXT k
            NEXT j
            glEnd()
        NEXT i

         '  Stop recording displaylist
        glEndList()

    ELSE
    	'  Playback displaylist
        glCallList( torus_list )
    END IF

END FUNCTION


 ' ========================================================================
 '  DrawScene() - Draw the scene (a rotating torus)
 ' ========================================================================

FUNCTION DrawScene( width,  height, DOUBLE t )

'    const GLfloat model_dIFfuse[4]  = {1.0, 0.8, 0.8, 1.0f}
 '   const GLfloat model_specular[4] = {0.6, 0.6, 0.6, 1.0f}
     SINGLE model_shininess


    DIM model_dIFfuse![3]
    DIM model_specular![3]

    model_dIFfuse![0]=1.0
    model_dIFfuse![1]=0.8
    model_dIFfuse![2]=0.8
    model_dIFfuse![3]=1.0

    model_specular![0]=0.6
    model_specular![1]=0.6
    model_specular![2]=0.6
    model_specular![3]=1.0

    model_shininess = 17.0

    glPushMatrix()

     '  Rotate the object
    glRotatef( SINGLE (#rot_x)*0.5, 1.0, 0.0, 0.0 )
    glRotatef( SINGLE (#rot_y)*0.5, 0.0, 1.0, 0.0 )
    glRotatef( SINGLE (#rot_z)*0.5, 0.0, 0.0, 1.0 )

     '  Set model color (used for orthogonal views, lighting disabled)
    glColor4fv( &model_dIFfuse![] )

     '  Set model material (used for perspective view, lighting enabled)
    glMaterialfv( $$GL_FRONT, $$GL_DIFFUSE, &model_dIFfuse![] )
    glMaterialfv( $$GL_FRONT, $$GL_SPECULAR, &model_specular![] )
    glMaterialf(  $$GL_FRONT, $$GL_SHININESS, model_shininess )

     '  Draw torus
    DrawTorus()

    glPopMatrix()

END FUNCTION


 ' ========================================================================
 '  DrawAllViews()
 ' ========================================================================

FUNCTION DrawAllViews( DOUBLE t )

    'const GLfloat light_position[4] = {0.0, 8.0, 8.0, 1.0f}
    'const GLfloat light_dIFfuse[4]  = {1.0, 1.0, 1.0, 1.0f}
    'const GLfloat light_specular[4] = {1.0, 1.0, 1.0, 1.0f}
    'const GLfloat light_ambient[4]  = {0.2, 0.2, 0.3, 1.0f}
    DOUBLE aspect

    DIM light_position![3]
    DIM light_dIFfuse![3]
    DIM light_specular![3]
    DIM light_ambient![3]


    light_position![0]=0.0
    light_position![1]=8.0
    light_position![2]=8.0
    light_position![3]=1.0

    light_dIFfuse![0]=1.0
    light_dIFfuse![1]=1.0
    light_dIFfuse![2]=1.0
    light_dIFfuse![3]=1.0

    light_specular![0]=1.0
    light_specular![1]=1.0
    light_specular![2]=1.0
    light_specular![3]=1.0

    light_ambient![0]=0.2
    light_ambient![1]=0.2
    light_ambient![2]=0.3
    light_ambient![3]=1.0


     '  Calculate aspect of window
    IF ( #height > 0 ) THEN
        aspect = DOUBLE (#width) / DOUBLE (#height)
    ELSE
        aspect = 1.0
    END IF

     '  Clear screen
    glClearColor( 0.0, 0.0, 0.0, 0.0)
    glClear( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT )

     '  Enable scissor test
    glEnable( $$GL_SCISSOR_TEST )

     '  Enable depth test
    glEnable( $$GL_DEPTH_TEST )
    glDepthFunc( $$GL_LEQUAL )


     '  ** ORTHOGONAL VIEWS **

     '  For orthogonal views, use wireframe rendering
    glPolygonMode( $$GL_FRONT_AND_BACK, $$GL_LINE )

     '  Enable line anti-aliaSing
    glEnable( $$GL_LINE_SMOOTH )
    glEnable( $$GL_BLEND )
    glBlendFunc( $$GL_SRC_ALPHA, $$GL_ONE_MINUS_SRC_ALPHA )

     '  Setup orthogonal projection matrix
    glMatrixMode( $$GL_PROJECTION )
    glLoadIdentity()
    glOrtho( -3.0*aspect, 3.0*aspect, -3.0, 3.0, 1.0, 50.0 )

     '  Upper left view (TOP VIEW)
    glViewport( 0, #height/2, #width/2, #height/2 )
    glScissor( 0, #height/2, #width/2, #height/2 )
    glMatrixMode( $$GL_MODELVIEW )
    glLoadIdentity()
    gluLookAt( 0.0, 10.0, 1e-3, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0 )
    DrawGrid( 0.5, 12 )
    DrawScene( #width/2, #height/2, t )

     '  Lower left view (FRONT VIEW)
    glViewport( 0, 0, #width/2, #height/2 )
    glScissor( 0, 0, #width/2, #height/2 )
    glMatrixMode( $$GL_MODELVIEW )
    glLoadIdentity()
    gluLookAt( 0.0, 0.0, 10.0, 0.0, 0.0, 0.0,0.0, 1.0, 0.0 )
    DrawGrid( 0.5, 12 )
    DrawScene( #width/2, #height/2, t )

     '  Lower right view (SIDE VIEW)
    glViewport( #width/2, 0, #width/2, #height/2 )
    glScissor( #width/2, 0, #width/2, #height/2 )
    glMatrixMode( $$GL_MODELVIEW )
    glLoadIdentity()
    gluLookAt( 10.0, 0.0, 0.0,0.0, 0.0, 0.0, 0.0, 1.0, 0.0 )
    DrawGrid( 0.5, 12 )
    DrawScene( #width/2, #height/2, t )

     '  Disable line anti-aliaSing
    glDisable( $$GL_LINE_SMOOTH )
    glDisable( $$GL_BLEND )

     '  ** PERSPECTIVE VIEW **
     '  For perspective view, use solid rendering
    glPolygonMode( $$GL_FRONT_AND_BACK, $$GL_FILL )

     '  Enable face culling (faster rendering)
    glEnable( $$GL_CULL_FACE )
    glCullFace( $$GL_BACK )
    glFrontFace( $$GL_CW )

     '  Setup perspective projection matrix
    glMatrixMode( $$GL_PROJECTION )
    glLoadIdentity()
    gluPerspective( 65.0, aspect, 1.0, 50.0 )

     '  Upper right view (PERSPECTIVE VIEW)
    glViewport( #width/2, #height/2, #width/2, #height/2 )
    glScissor( #width/2, #height/2, #width/2, #height/2 )
    glMatrixMode( $$GL_MODELVIEW )
    glLoadIdentity()
    gluLookAt( 3.0, 1.5, 3.0,0.0, 0.0, 0.0,0.0, 1.0, 0.0 )

     '  Configure and enable light source 1
    glLightfv( $$GL_LIGHT1, $$GL_POSITION, &light_position![] )
    glLightfv( $$GL_LIGHT1, $$GL_AMBIENT, &light_ambient![] )
    glLightfv( $$GL_LIGHT1, $$GL_DIFFUSE, &light_dIFfuse![] )
    glLightfv( $$GL_LIGHT1, $$GL_SPECULAR, &light_specular![] )
    glEnable( $$GL_LIGHT1 )
    glEnable( $$GL_LIGHTING )

     '  Draw scene
    DrawScene( #width/2, #height/2, t )

     '  Disable lighting
    glDisable( $$GL_LIGHTING )

     '  Disable face culling
    glDisable( $$GL_CULL_FACE )

     '  Disable depth test
    glDisable( $$GL_DEPTH_TEST )

     '  Disable scissor test
    glDisable( $$GL_SCISSOR_TEST )


     '  Draw a border around the active view
    IF( (#active_view > 0) && (#active_view != 2) ) THEN

        glViewport( 0, 0, #width, #height )
        glMatrixMode( $$GL_PROJECTION )
        glLoadIdentity()
        glOrtho( 0.0, 2.0, 0.0, 2.0, 0.0, 1.0 )
        glMatrixMode( $$GL_MODELVIEW )
        glLoadIdentity()
        glColor3f( 1.0, 1.0, 0.6 )
        glTranslatef( (#active_view-1)& 1, 1-(#active_view-1)/2.0, 0.0 )
        glBegin( $$GL_LINE_STRIP )
          glVertex2i( 0, 0 )
          glVertex2i( 1, 0 )
          glVertex2i( 1, 1 )
          glVertex2i( 0, 1 )
          glVertex2i( 0, 0 )
        glEnd()

   END IF

END FUNCTION


 ' ========================================================================
 '  WindowSizeFun() - Window size callback function
 ' ========================================================================

FUNCTION WindowSizeFun( w, h )
    #width  = w
    #height = h
    IF #height <2 THEN #height=2

END FUNCTION


 ' ========================================================================
 '  MousePosFun() - Mouse position callback function
 ' ========================================================================

FUNCTION MousePosFun(  x,  y )

     '  Depending on which view was selected, rotate around dIFferent axes
    SELECT CASE #active_view

        CASE 1:
            #rot_x = #rot_x +  y - #ypos
            #rot_z = #rot_z +  x - #xpos

        CASE 3:
            #rot_x = #rot_x +  y - #ypos
            #rot_y = #rot_y +  x - #xpos

        CASE 4:
            #rot_y = #rot_y +  x - #xpos
            #rot_z = #rot_z +  y - #ypos

        CASE ELSE:
             '  Do nothing for perspective view, or IF no view is selected

    END SELECT

     '  Remember mouse position
    #xpos = x
    #ypos = y
END FUNCTION


 ' ========================================================================
 '  MouseButtonFun() - Mouse button callback function
 ' ========================================================================

FUNCTION MouseButtonFun ( button,  action )

     '  Button clicked?
    IF (( button == $$GLFW_MOUSE_BUTTON_LEFT ) && (action == $$GLFW_PRESS) ) THEN

         '  Detect which of the four views was clicked
        #active_view = 1
        IF ( #xpos >= (#width/2) ) THEN #active_view = #active_view + 1
        IF ( #ypos >= (#height/2) ) THEN #active_view = #active_view+ 2

     '  Button released?
    ELSE
     '  Deselect any previously selected view
    	IF ( button == $$GLFW_MOUSE_BUTTON_LEFT ) THEN #active_view = 0
   END IF

END FUNCTION

FUNCTION  KeyFun ( k, action )
    SHARED torus_list

  IF ( action != $$GLFW_PRESS ) THEN RETURN

  SELECT CASE k

    CASE $$GLFW_KEY_LEFT :
    	#TORUS_MAJOR_RES= #TORUS_MAJOR_RES-4
    	#TORUS_MINOR_RES= #TORUS_MINOR_RES-4
    	IF #TORUS_MAJOR_RES<4 THEN #TORUS_MAJOR_RES=4
    	IF #TORUS_MINOR_RES<4 THEN #TORUS_MINOR_RES=4
    	torus_list=0
    CASE $$GLFW_KEY_RIGHT :
    	#TORUS_MAJOR_RES= #TORUS_MAJOR_RES+4
    	#TORUS_MINOR_RES= #TORUS_MINOR_RES+4
    	torus_list=0

  END SELECT


END FUNCTION


 ' ========================================================================
 '  DrawGrid() - Draw a 2D grid (used for orthogonal views)
 ' ========================================================================

FUNCTION DrawGrid ( SINGLE scale, XLONG steps )

    XLONG   i
    SINGLE x, y

    glPushMatrix()

     '  Set background to some dark bluish grey
    glClearColor( 0.05, 0.05, 0.2, 0.0)
    glClear( $$GL_COLOR_BUFFER_BIT )

     '  Setup modelview matrix (flat XY view)
    glLoadIdentity()
    gluLookAt( 0.0, 0.0, 1.0,0.0, 0.0, 0.0, 0.0, 1.0, 0.0 )

     '  We don't want to update the Z-buffer
    glDepthMask( $$GL_FALSE )

     '  Set grid color
    glColor3f( 0.0, 0.5, 0.5 )

    glBegin( $$GL_LINES )

     '  Horizontal lines
    x = scale * 0.5 * SINGLE (steps-1)
    y = -scale * 0.5 * SINGLE (steps-1)
    FOR i=0 TO (steps-1)   ' for( i = 0  i < steps  i ++ )

        glVertex3f( -x, y, 0.0 )
        glVertex3f( x, y, 0.0 )
        y =y+ scale
    NEXT i

     '  Vertical lines
    x = -scale * 0.5 * SINGLE (steps-1)
    y = scale * 0.5 * SINGLE (steps-1)
    FOR i=0 TO (steps-1) ' for( i = 0  i < steps  i ++ )

        glVertex3f( x, -y, 0.0 )
        glVertex3f( x, y, 0.0 )
        x =x+ scale
    NEXT i

    glEnd()

     '  Enable Z-buffer writing again
    glDepthMask( $$GL_TRUE )

    glPopMatrix()
END FUNCTION
END PROGRAM
