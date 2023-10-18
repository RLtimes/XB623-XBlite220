'========================================================================
' This is a small test application for GLFW.
' The program shows texture loading with mipmap generation and trilienar
' filtering.
'
' Ported by Michael McElligott
' Mapei_@hotmail.com
'========================================================================
PROGRAM	"mipmaps"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "user32"    ' user32.dll
'	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "opengl32"
	IMPORT  "glu32"
	IMPORT	"glfw"
'	IMPORT	"xma"


'========================================================================
' main()
'========================================================================

DECLARE FUNCTION  Entry ()




FUNCTION  Entry ()
    XLONG  width, height, running, frames, x, y ,fps 
    DOUBLE  t, t0  
    GLuint  texid  

    ' Initialise GLFW
    glfwInit()  

    ' Open OpenGL window
    ok = glfwOpenWindow(640, 480, 0, 0, 0, 0, 16, 0, $$GLFW_WINDOW)
    IFZ ok THEN glfwTerminate(): RETURN 0

    ' Enable sticky keys
    glfwEnable( $$GLFW_STICKY_KEYS )  

    ' Disable vertical sync (on cards that support it)
    glfwSwapInterval( 0 )  '

    ' Get and select a texture object ID
    glGenTextures( 1, &texid )  '
    glBindTexture( $$GL_TEXTURE_2D, texid )  '

    ' Load texture from file, and build all mipmap levels. The
    ' texture is automatically uploaded to texture memory.
    ok = glfwLoadTexture2D( &"mipmaps.tga", $$GLFW_BUILD_MIPMAPS_BIT )
    IFZ ok THEN glfwTerminate(): RETURN 0

    ' Use trilinear interpolation ($$GL_LINEAR_MIPMAP_LINEAR)
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER,$$GL_LINEAR_MIPMAP_LINEAR ) 
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER,$$GL_LINEAR ) 

    ' Enable texturing
    glEnable( $$GL_TEXTURE_2D ) 

    ' Main loop
    running = 1 
    frames = 0 
    t0 = glfwGetTime() 
    DO WHILE ( running=1)

        ' Get time and mouse position
        t = glfwGetTime()
        glfwGetMousePos( &x, &y )

        ' Calculate and display FPS (frames per second)
        IF ( (t-t0) > 1.0 || frames == 0 ) THEN
            fps = DOUBLE (frames) / (t-t0)
            title$="Trilinear interpolation "+ STRING$ (fps)
            glfwSetWindowTitle( &title$ ) 
            t0 = t
            frames = 0 
        END IF

        INC frames  

        ' Get window size (may be different than the requested size)
        glfwGetWindowSize( &width, &height ) 
				IFZ height THEN height = 2

        ' Set viewport
        glViewport( 0, 0, width, height )

        ' Clear color buffer
        glClearColor( 0.0#, 0.0#, 0.0#, 0.0#) 
        glClear( $$GL_COLOR_BUFFER_BIT )

        ' Select and setup the projection matrix
        glMatrixMode( $$GL_PROJECTION )
        glLoadIdentity() 
        gluPerspective( 65.0#, SINGLE(width)/ SINGLE(height), 1.0#, 50.0# ) 

        ' Select and setup the modelview matrix
        glMatrixMode( $$GL_MODELVIEW )
        glLoadIdentity()
        gluLookAt( 0.0#,  3.0#, -20.0#, 0.0#, -4.0#, -11.0#,0.0#,  1.0#,   0.0# )

        ' Draw a textured quad
        glRotatef( (0.05* SINGLE (x)) + (SINGLE (t) *5.0#), 0.0#, 1.0#, 0.0# )
        glBindTexture( $$GL_TEXTURE_2D, texid )  '
        glBegin( $$GL_QUADS )
          glTexCoord2f( -20.0#,  20.0# )
          glVertex3f( -50.0#, 0.0#, -50.0# )
          glTexCoord2f(  20.0#,  20.0# )
          glVertex3f(  50.0#, 0.0#, -50.0# )
          glTexCoord2f(  20.0#, -20.0# ) 
          glVertex3f(  50.0#, 0.0#,  50.0# )
          glTexCoord2f( -20.0#, -20.0# )
          glVertex3f( -50.0#, 0.0#,  50.0# )
        glEnd()  '

        ' Swap buffers
        glfwSwapBuffers()

        ' Check if the ESC key was pressed or the window was closed
				IF ((glfwGetKey($$GLFW_KEY_ESC) = 1) OR (glfwGetWindowParam($$GLFW_OPENED) = 0)) THEN running = 0

	LOOP

    ' Close OpenGL window and terminate GLFW
    glfwTerminate()  '


END FUNCTION
END PROGRAM
