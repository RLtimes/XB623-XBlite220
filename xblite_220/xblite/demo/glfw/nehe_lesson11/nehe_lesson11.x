 ' ========================================================================
 ' Based on lesson11 by NeHe
 '
 ' XBLite\XBasic port by Michael McElligott 26/11/2002
 ' Mapei_@hotmail.com
 ' ========================================================================


	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "msvcrt"

DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()


FUNCTION Main ()
	SHARED SINGLE zoom,tilt
	SHARED twinkle

	Create ()
	Init()

	event=1
	DO
		Render()
		glfwSwapBuffers ()
		
		IF (glfwGetKey('S')=1) THEN
			IF #vsync=1 THEN
				glfwSwapInterval( 1 )
				glfwSleep(0.2)
				#vsync=0
			ELSE
				glfwSwapInterval( 0 )
				glfwSleep(0.2)
				#vsync=1
			END IF
		END IF
				
			
		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN event=0
		
		IFZ #vsync THEN glfwSleep(0.01)

	LOOP WHILE event=1

	glfwTerminate()

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
    glfwInit()
    IFZ glfwOpenWindow( 640,480, 0,0,0,0, 16,0, $$GLFW_WINDOW ) THEN
        glfwTerminate()
        RETURN 0
    END IF
    
    glfwSetWindowTitle( &"XBlite Flag Waving Texture" )
    glfwSetWindowSizeCallback (&Resize())
    glfwSwapInterval( 1 )

END FUNCTION


FUNCTION Render()
	SHARED GLfloat points[]
	STATIC GLfloat float_x, float_y, float_xb, float_yb
	STATIC GLfloat hold,xrot,yrot,zrot
	STATIC wiggle_count

	glClear( $$GL_COLOR_BUFFER_BIT| $$GL_DEPTH_BUFFER_BIT)		'  Clear The Screen And The Depth Buffer
	glLoadIdentity()											'  Reset The View

	glTranslatef(0.0,0.0,-12.0)
	glRotatef(xrot,1.0,0.0,0.0)
	glRotatef(yrot,0.0,1.0,0.0)  
	glRotatef(zrot,0.0,0.0,1.0)
	
	glBindTexture( $$GL_TEXTURE_2D, #texture)			 		'  Select Our Texture

	glBegin( $$GL_QUADS)
	FOR x=0 TO 43
	
		FOR y = 0 TO 43
		
			float_x = SINGLE (x) / 45.0
			float_y = SINGLE (y) / 45.0
			float_xb = SINGLE (x+1) / 45.0
			float_yb = SINGLE (y+1) / 45.0

			glTexCoord2f( float_x, float_y)
			glVertex3f( points[x,y,0], points[x,y,1], points[x,y,2] )

			glTexCoord2f( float_x, float_yb )
			glVertex3f( points[x,y+1,0], points[x,y+1,1], points[x,y+1,2] )

			glTexCoord2f( float_xb, float_yb )
			glVertex3f( points[x+1,y+1,0], points[x+1,y+1,1], points[x+1,y+1,2] )

			glTexCoord2f( float_xb, float_y )
			glVertex3f( points[x+1,y,0], points[x+1,y,1], points[x+1,y,2] )
			
		NEXT y
	NEXT x
	glEnd()

	IF ( wiggle_count == 2 ) THEN
	
		FOR y=0 TO 44
		
			hold=points[0,y,2]
			FOR x=0 TO 43
				points[x,y,2] = points[x+1,y,2]
			NEXT x 
			points[44,y,2]=hold
			
		NEXT y
		wiggle_count = 0
	END IF

	INC wiggle_count

	xrot = xrot + 0.3
	yrot = yrot + 0.2
	zrot = zrot + 0.4
	

END FUNCTION

FUNCTION Init()
	SHARED GLfloat points[]
	
	DIM points [44,44,2]
	

	' load and set texture type
	glGenTextures (0,&#texture)
	glBindTexture( $$GL_TEXTURE_2D, #texture)
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )
	glfwLoadTexture2D( &"xbsplash.tga", 0 )


	glEnable( $$GL_TEXTURE_2D)								 '  Enable Texture Mapping ( NEW )
	glShadeModel( $$GL_SMOOTH )								 '  Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5)						 '  Black Background
	glClearDepth(1.0)										 '  Depth Buffer Setup
	glEnable( $$GL_DEPTH_TEST)								 '  Enables Depth Testing
	glDepthFunc( $$GL_LEQUAL)								 '  The Type Of Depth Testing To Do
	glHint( $$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)	 '  Really Nice Perspective Calculations
	glPolygonMode( $$GL_BACK, $$GL_FILL )					 '  Back Face Is Solid
	glPolygonMode( $$GL_FRONT, $$GL_LINE )					 '  Front Face Is Made Of Lines
	
	
	FOR x = 0 TO 44
		FOR y = 0 TO 44
			points[x,y,0]= SINGLE ((x / 5.0)-4.5)
			points[x,y,1]= SINGLE ((y / 5.0)-4.5)
			points[x,y,2]= SINGLE ( sin (((( x / 5.0) * 40.0)/ 360.0)*  3.141592654 * 2.0))
		NEXT y
	NEXT x

	
END FUNCTION 

FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height < 50) THEN #Height = 50

	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(45.0, SINGLE(#Width/#Height), 0.1, 100.0)
	glMatrixMode( $$GL_MODELVIEW)
	glLoadIdentity()

END FUNCTION

END PROGRAM
