 ' ========================================================================
 ' Based on lesson9 by NeHe
 '
 ' XBLite\XBasic port by Michael McElligott 26/11/2002
 ' Mapei_@hotmail.com
 ' ========================================================================


	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "msvcrt"
	
	
TYPE STARS
	XLONG	.r
	XLONG	.g
	XLONG	.b
	GLfloat	.dist
	GLfloat	.angle
END TYPE



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
		
		
		IF (glfwGetKey($$GLFW_KEY_LEFT)=1) THEN zoom=zoom+0.2
		IF (glfwGetKey($$GLFW_KEY_RIGHT)=1) THEN zoom=zoom-0.2
		IF (glfwGetKey($$GLFW_KEY_UP)=1) THEN tilt=tilt+0.2
		IF (glfwGetKey($$GLFW_KEY_DOWN)=1) THEN tilt=tilt-0.2
		IF (glfwGetKey('S')=1) THEN
			IF #vsync=1 THEN
				glfwSwapInterval( 1 )
				glfwSleep(0.02)
				#vsync=0
			ELSE
				glfwSwapInterval( 0 )
				glfwSleep(0.02)
				#vsync=1
			END IF
		END IF
				
		IF (glfwGetKey('T')=1) THEN
			IF twinkle=0 THEN twinkle=1 ELSE twinkle=0
			sleep=0
		END IF
			
		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN event=0
		
		IFZ #vsync THEN glfwSleep(0.01)

	LOOP WHILE event=1

	glfwTerminate()

END FUNCTION


FUNCTION Create ()

	 ' Init GLFW and open window
    glfwInit()
    IFZ glfwOpenWindow( 640,480, 0,0,0,0, 32,0, $$GLFW_WINDOW ) THEN
        glfwTerminate()
        RETURN 0
    END IF
    
    glfwSetWindowTitle( &"Stars" )
    'glfwEnable( $$GLFW_STICKY_KEYS )
    glfwSwapInterval( 1 )
    glfwSetWindowSizeCallback (&Resize())

END FUNCTION


FUNCTION Render()
	SHARED SINGLE zoom,tilt
	SHARED STARS star[]
	STATIC SINGLE spin
	SHARED twinkle

	glClear( $$GL_COLOR_BUFFER_BIT| $$GL_DEPTH_BUFFER_BIT) 	'  Clear The Screen And The Depth Buffer
	glBindTexture( $$GL_TEXTURE_2D, #texture)			 '  Select Our Texture

	FOR loop=0 TO #StarsNum 						 '  Loop Through All The Stars
	
		glLoadIdentity()							 '  Reset The View Before We Draw Each Star
		glTranslatef(0.0,0.0,zoom)					 '  Zoom Into The Screen (Using The Value In 'zoom')
		glRotatef(tilt,1.0,0.0,0.0)					 '  Tilt The View (Using The Value In 'tilt')
		glRotatef(star[loop].angle,0.0,1.0,0.0)		 '  Rotate To The Current Stars Angle
		glTranslatef(star[loop].dist,0.0,0.0)		 '  Move Forward On The X Plane
		glRotatef(-star[loop].angle,0.0,1.0,0.0)	 '  Cancel The Current Stars Angle
		glRotatef(-tilt,1.0,0.0,0.0)				 '  Cancel The Screen Tilt
		
		IFZ (twinkle) THEN
		
			glColor4ub(star[(#StarsNum-loop)-1].r,star[(#StarsNum-loop)-1].g,star[(#StarsNum-loop)-1].b,255)
			glBegin( $$GL_QUADS)
				glTexCoord2f(0.0, 0.0) glVertex3f(-1.0,-1.0, 0.0)
				glTexCoord2f(1.0, 0.0) glVertex3f( 1.0,-1.0, 0.0)
				glTexCoord2f(1.0, 1.0) glVertex3f( 1.0, 1.0, 0.0)
				glTexCoord2f(0.0, 1.0) glVertex3f(-1.0, 1.0, 0.0)
			glEnd()
			
		END IF

		glRotatef(spin,0.0,0.0,1.0)
		glColor4ub(star[loop].r,star[loop].g,star[loop].b,255)
		glBegin( $$GL_QUADS)
			glTexCoord2f(0.0, 0.0) glVertex3f(-1.0,-1.0, 0.0)
			glTexCoord2f(1.0, 0.0) glVertex3f( 1.0,-1.0, 0.0)
			glTexCoord2f(1.0, 1.0) glVertex3f( 1.0, 1.0, 0.0)
			glTexCoord2f(0.0, 1.0) glVertex3f(-1.0, 1.0, 0.0)
		glEnd()

		spin = spin + 0.01
		star[loop].angle = star[loop].angle + SINGLE (loop) / #StarsNum
		star[loop].dist = star[loop].dist - 0.01
		
		IF (star[loop].dist<0.0) THEN
			star[loop].dist = star[loop].dist + 5.0
			star[loop].r=rand() MOD 256
			star[loop].g=rand() MOD 256
			star[loop].b=rand() MOD 256
		END IF	
					
	NEXT loop

END FUNCTION

FUNCTION Init()
	SHARED STARS star[]
	SHARED SINGLE zoom,tilt
	SHARED twinkle

	#StarsNum = 50
	#vsync=0
	zoom=-15
	tilt=90
	twinkle=1
	

	' load and set texture type
	glGenTextures (0,&#texture)
	glBindTexture( $$GL_TEXTURE_2D, #texture)
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )
	glfwLoadTexture2D( &"star.tga", 0 )


	glEnable( $$GL_TEXTURE_2D)							 '  Enable Texture Mapping
	glShadeModel( $$GL_SMOOTH)							 '  Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5)					 '  Black Background
	glClearDepth(1.0)									 '  Depth Buffer Setup
	glHint( $$GL_PERSPECTIVE_CORRECTION_HINT,  $$GL_NICEST)	 '  Really Nice Perspective Calculations
	glBlendFunc( $$GL_SRC_ALPHA,$$GL_ONE)					 '  Set The Blending Function For Translucency
	glEnable( $$GL_BLEND)
	

	DIM star[#StarsNum]

	FOR loop = 0 TO #StarsNum   ' for (loop=0 loop<num loop++)
	
		star[loop].angle=0.0
		star[loop].dist=(SINGLE(loop) / #StarsNum)*5.0
		star[loop].r=rand() MOD 256
		star[loop].g=rand() MOD 256
		star[loop].b=rand() MOD 256
	
	NEXT loop

	RETURN $$TRUE
	
END FUNCTION 

FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height<50) THEN #Height=50

	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(45.0,  SINGLE(#Width/#Height), 0.1, 100.0)
	glMatrixMode( $$GL_MODELVIEW)
	glLoadIdentity()

END FUNCTION

END PROGRAM
