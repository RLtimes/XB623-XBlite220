 ' ========================================================================
 ' Based on NeHe lesson 12
 '
 ' XBLite\XBasic conversion by Michael McElligott 1/12/2002
 ' Mapei_@hotmail.com
 ' ========================================================================

	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
'	IMPORT "kernel32"
	IMPORT "msvcrt"

DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadGLTexture (file)
DECLARE FUNCTION FillArray (array, SINGLE v1, SINGLE v2, SINGLE v3) ', SINGLE v4)
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)

DECLARE FUNCTION BuildLists ()

FUNCTION Main ()

	Create ()
	Init()

	event=1
	DO
	
		Render ()
		
		glfwSwapBuffers ()

		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN event=0
		
		IF (#vsync = 1)  THEN
			glfwSleep(0.01)

		END IF

	LOOP WHILE event=1

	glfwTerminate()

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
    glfwInit()
    IFZ glfwOpenWindow(#Width,#Height, 0,0,0,0, 32,0, $$GLFW_WINDOW ) THEN
        glfwTerminate()
        RETURN 0
    END IF
    
    glfwSetWindowTitle( &"XBlite Using Display Lists" )
    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
    glfwSetMousePosCallback (&MousePos() ) 
    glfwSwapInterval( 1 )
    
	glfwEnable( $$GLFW_KEY_REPEAT )
	#vsync = 1

END FUNCTION

FUNCTION key (k,action)

	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k
	
	    CASE 'V' :
			IF #vsync=1 THEN
				glfwSwapInterval( 0 )
				#vsync=0
			ELSE
				glfwSwapInterval( 1 )
				#vsync=1
			END IF
	
	END SELECT


END FUNCTION

FUNCTION MousePos (x,y)
	SHARED SINGLE mx,my
	
	mx=x
	my=y
	
END FUNCTION


FUNCTION Render()
	SHARED box,top
	SHARED SINGLE mx,my
	SHARED SINGLE topcol[],boxcol[]
			

	glClear($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)	 '  Clear The Screen And The Depth Buffer

	glBindTexture( $$GL_TEXTURE_2D, #texture)

	FOR yloop=1 TO 5
		FOR xloop=0 TO yloop-1
			glLoadIdentity()							 '  Reset The View
			glTranslatef(1.4 + ( SINGLE (xloop) * 2.8)-( SINGLE (yloop)* 1.4),((6.0 - SINGLE (yloop))* 2.4)-7.0,-20.0)
			glRotatef(45.0-(2.0 * yloop) + my,1.0,0.0,0.0)
			glRotatef(45.0 + mx,0.0,1.0,0.0)
			glColor3fv(&boxcol[yloop-1,0])
			glCallList(box)
			glColor3fv(&topcol[yloop-1,0])
			glCallList(top)

		NEXT xloop
	NEXT yloop

	RETURN $$TRUE										 '  Keep Going

END FUNCTION



FUNCTION Init()
	SHARED SINGLE topcol[],boxcol[]
	
	DIM boxcol[4,2]
	DIM topcol[4,2]
	

'	(1.0,0.0,0.0),(1.0,0.5,0.0),(1.0,1.0,0.0),(0.0,1.0,0.0),(0.0,1.0,1.0)
	
	FillArray (&boxcol[0,0],1.0,0.0,0.0)
	FillArray (&boxcol[1,0],1.0,0.5,0.0)
	FillArray (&boxcol[2,0],1.0,1.0,0.0)
	FillArray (&boxcol[3,0],0.0,1.0,0.0)
	FillArray (&boxcol[4,0],0.0,1.0,1.0)

'	(.5,0.0,0.0),(0.5,0.25,0.0),(0.5,0.5,0.0),(0.0,0.5,0.0),(0.0,0.5,0.5)

	FillArray (&topcol[0,0],0.5,0.0,0.0)
	FillArray (&topcol[1,0],0.5,0.25,0.0)
	FillArray (&topcol[2,0],0.5,0.5,0.0)
	FillArray (&topcol[3,0],0.0,0.5,0.0)
	FillArray (&topcol[4,0],0.0,0.5,0.5)

	
	#texture = LoadGLTexture (&"Cube.tga")				 '  Load the texture
	BuildLists()										 '  Create Our Display Lists

	glEnable( $$GL_TEXTURE_2D)							 '  Enable Texture Mapping
	glShadeModel( $$GL_SMOOTH)							 '  Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5)					 '  Black Background
	glClearDepth(1.0)									 '  Depth Buffer Setup
	glEnable( $$GL_DEPTH_TEST)							 '  Enables Depth Testing
	glDepthFunc( $$GL_LEQUAL)							 '  The Type Of Depth Testing To Do
	glEnable( $$GL_LIGHT0)								 '  Quick And Dirty Lighting (Assumes Light0 Is Set Up)
	glEnable( $$GL_LIGHTING)							 '  Enable Lighting
	glEnable( $$GL_COLOR_MATERIAL)						 '  Enable Material Coloring
	glHint( $$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)	 '  Really Nice Perspective Calculations
	
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


FUNCTION LoadGLTexture (file)


	' load and set texture type
	texture=0
	glGenTextures (0,&texture)
	
	glBindTexture( $$GL_TEXTURE_2D, texture)
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )
	glfwLoadTexture2D( file, 0 )

	RETURN texture

END FUNCTION

FUNCTION FillArray ( array, SINGLE v1, SINGLE v2, SINGLE v3) ', SINGLE v4)

	
	SINGLEAT (array)= v1
	SINGLEAT (array+4)= v2
	SINGLEAT (array+8)= v3

	'array[0] = v1
	'array[1] = v2
	'array[2] = v3
	'array[3] = v4

END FUNCTION


FUNCTION BuildLists ()
	SHARED box,top

	box=glGenLists(2)									 '  Generate 2 Different Lists
	glNewList(box, $$GL_COMPILE)							 '  Start With The Box List
		glBegin( $$GL_QUADS)
			 '  Bottom Face
			glNormal3f( 0.0,-1.0, 0.0)
			glTexCoord2f(1.0, 1.0) glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f( 1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f(-1.0, -1.0,  1.0)
			 '  Front Face
			glNormal3f( 0.0, 0.0, 1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f( 1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f(-1.0,  1.0,  1.0)
			 '  Back Face
			glNormal3f( 0.0, 0.0,-1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f( 1.0, -1.0, -1.0)
			 '  Right face
			glNormal3f( 1.0, 0.0, 0.0)
			glTexCoord2f(1.0, 0.0) glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f( 1.0, -1.0,  1.0)
			 '  Left Face
			glNormal3f(-1.0, 0.0, 0.0)
			glTexCoord2f(0.0, 0.0) glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f(-1.0,  1.0, -1.0)
		glEnd()
	glEndList()
	top=box+1											 '  Storage For "Top" Is "Box" Plus One
	glNewList(top, $$GL_COMPILE)							 '  Now The "Top" Display List
		glBegin( $$GL_QUADS)
			 '  Top Face
			glNormal3f( 0.0, 1.0, 0.0)
			glTexCoord2f(0.0, 1.0) glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f( 1.0,  1.0, -1.0)
		glEnd()
	glEndList()

END FUNCTION

END PROGRAM
