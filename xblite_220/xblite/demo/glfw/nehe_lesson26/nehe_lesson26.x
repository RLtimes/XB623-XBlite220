 ' ========================================================================
 ' Based on lesson 24 by NeHe
 '
 ' XBLite\XBasic conversion by Michael McElligott 27/11/2002
 ' Mapei_@hotmail.com
 ' ========================================================================


	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"


DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadGLTextures ()
DECLARE FUNCTION DrawFloor ()
DECLARE FUNCTION DrawObject()
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)


FUNCTION Main ()
	SHARED SINGLE zoom,tilt
	SHARED twinkle

	Create ()
	Init()

	event=1
	DO
		Render()
		glfwSwapBuffers ()

		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN event=0
		
		IFZ #vsync THEN glfwSleep(0.01)

	LOOP WHILE event=1

	glfwTerminate()

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
    glfwInit()
    IFZ glfwOpenWindow(640,480, 16,16,16,0, 16,0, $$GLFW_WINDOW ) THEN
        glfwTerminate()
        RETURN 0
    END IF
    
    glfwSetWindowTitle( &"XBlite True Reflections" )
    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
    glfwSetMousePosCallback (&MousePos() ) 
    glfwSwapInterval( 0 )
    
	glfwEnable( $$GLFW_KEY_REPEAT )
	
	#vsync = 1

END FUNCTION

FUNCTION key (k,action)
	SHARED GLfloat yrot,xrotspeed,yrotspeed,zoom,bheight

	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k

	    CASE $$GLFW_KEY_RIGHT	:		yrotspeed = yrotspeed + 0.08		'	 Right Arrow Pressed (Increase yrotspeed)
	    CASE $$GLFW_KEY_LEFT	:		yrotspeed = yrotspeed - 0.08		'	 Left Arrow Pressed (Decrease yrotspeed)
	    CASE $$GLFW_KEY_DOWN	:		xrotspeed = xrotspeed + 0.08		'	 Down Arrow Pressed (Increase xrotspeed)
	    CASE $$GLFW_KEY_UP		:		xrotspeed = xrotspeed - 0.08		'	 Up Arrow Pressed (Decrease xrotspeed)

	    CASE 'A' :			zoom = zoom + 0.05		'		 'A' Key Pressed ... Zoom In
	    CASE 'Z' :			zoom = zoom - 0.05		'		 'Z' Key Pressed ... Zoom Out

	    CASE 'S' :			bheight = bheight + 0.03	'			 Page Up Key Pressed Move Ball Up
	    CASE 'X' :			bheight = bheight - 0.03	'	
	    
	    CASE 'V' :   '	    		IF (glfwGetKey('V')=1) THEN
			IF #vsync=1 THEN
				glfwSwapInterval( 1 )
				#vsync=0
			ELSE
				glfwSwapInterval( 0 )
				#vsync=1
			END IF
	
	END SELECT


END FUNCTION

FUNCTION MousePos (x,y)
	SHARED mx,my
	
	mx=x
	my=y
	
END FUNCTION


FUNCTION Render()
	SHARED GLfloat yrot,xrotspeed,yrotspeed,zoom,bheight,xrot
	SHARED mx,my
	
	 '  Clear Screen, Depth Buffer & Stencil Buffer
	glClear($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT | $$GL_STENCIL_BUFFER_BIT)


	 '  Clip Plane Equations

	
	glLoadIdentity()									 '  Reset The Modelview Matrix
	glTranslatef(0.0, -0.6, zoom)						 '  Zoom And Raise Camera Above The Floor (Up 0.6 Units)
	
	glRotatef( SINGLE(mx-(#Width/2)), 0.0, 1.0, 0.0)
	glRotatef( SINGLE(my-(#Height/2)), 1.0, 0.0, 0.0)
	
	glColorMask(0,0,0,0)								 '  Set Color Mask
	glEnable($$GL_STENCIL_TEST)							 '  Enable Stencil Buffer For "marking" The Floor
	glStencilFunc($$GL_ALWAYS, 1, 1)					 '  Always Passes, 1 Bit Plane, 1 As Mask
	glStencilOp($$GL_KEEP, $$GL_KEEP, $$GL_REPLACE)		 '  We Set The Stencil Buffer To 1 Where We Draw Any Polygon
														 '  Keep If Test Fails, Keep If Test Passes But Buffer Test Fails
														 '  Replace If Test Passes
	glDisable($$GL_DEPTH_TEST)							 '  Disable Depth Testing
	DrawFloor()											 '  Draw The Floor (Draws To The Stencil Buffer)
														 '  We Only Want To Mark It In The Stencil Buffer
	glEnable($$GL_DEPTH_TEST)							 '  Enable Depth Testing
	glColorMask(1,1,1,1)								 '  Set Color Mask to TRUE, TRUE, TRUE, TRUE
	glStencilFunc($$GL_EQUAL, 1, 1)						 '  We Draw Only Where The Stencil Is 1
														 '  (I.E. Where The Floor Was Drawn)
	glStencilOp($$GL_KEEP, $$GL_KEEP, $$GL_KEEP)		 '  Don't Change The Stencil Buffer
	glEnable($$GL_CLIP_PLANE0)							 '  Enable Clip Plane For Removing Artifacts
														 '  (When The Object Crosses The Floor)
	glClipPlane($$GL_CLIP_PLANE0, &#eqr#[])				 '  Equation For Reflected Objects
	glPushMatrix()										 '  Push The Matrix Onto The Stack
		glScalef(1.0, -1.0, 1.0)						 '  Mirror Y Axis
		glLightfv($$GL_LIGHT0, $$GL_POSITION, &#LightPos![])	 '  Set Up Light0
		glTranslatef(0.0, bheight, 0.0)					 '  Position The Object
		glRotatef(xrot, 1.0, 0.0, 0.0)					 '  Rotate Local Coordinate System On X Axis
		glRotatef(yrot, 0.0, 1.0, 0.0)					 '  Rotate Local Coordinate System On Y Axis
		DrawObject()									 '  Draw The Sphere (Reflection)
	glPopMatrix()										 '  Pop The Matrix Off The Stack
	glDisable($$GL_CLIP_PLANE0)							 '  Disable Clip Plane For Drawing The Floor
	glDisable($$GL_STENCIL_TEST)							'  We Don't Need The Stencil Buffer Any More (Disable)
	glLightfv($$GL_LIGHT0, $$GL_POSITION, &#LightPos![])	'  Set Up Light0 Position
	glEnable($$GL_BLEND)									'  Enable Blending (Otherwise The Reflected Object Wont Show)
	glDisable($$GL_LIGHTING)								'  Since We Use Blending, We Disable Lighting
	glColor4f(1.0, 1.0, 1.0, 0.8)							'  Set Color To White With 80% Alpha
	glBlendFunc($$GL_SRC_ALPHA, $$GL_ONE_MINUS_SRC_ALPHA)	'  Blending Based On Source Alpha And 1 Minus Dest Alpha
	DrawFloor()												'  Draw The Floor To The Screen
	glEnable($$GL_LIGHTING)									'  Enable Lighting
	glDisable($$GL_BLEND)									'  Disable Blending
	glTranslatef(0.0, bheight, 0.0)					 		'  Position The Ball At Proper Height
	glRotatef(xrot, 1.0, 0.0, 0.0)							'  Rotate On The X Axis
	glRotatef(yrot, 0.0, 1.0, 0.0)							'  Rotate On The Y Axis
	DrawObject()											'  Draw The Ball
	xrot = xrot + xrotspeed									'  Update X Rotation Angle By xrotspeed
	yrot = yrot + yrotspeed									'  Update Y Rotation Angle By yrotspeed
	glFlush()												'  Flush The GL Pipeline
	

END FUNCTION

FUNCTION Init()
	SHARED GLfloat yrot,xrotspeed,yrotspeed,zoom,bheight
	
	xrot		=  0.0						 '  X Rotation
	yrot		=  0.0						 '  Y Rotation
	xrotspeed	=  0.08						 '  X Rotation Speed
	yrotspeed	=  0.08						 '  Y Rotation Speed
	zoom		= -6.0						 '  Depth Into The Screen
	bheight		=  1.0						 '  Height Of Ball From Floor
	
	LoadGLTextures ()
	 
	DIM #LightAmb![3]
	DIM #LightDif![3]
	DIM #LightPos![3]
	
	#LightAmb![0] = 0.7					'  Ambient Light
	#LightAmb![1] = 0.7
	#LightAmb![2] = 0.7
	#LightAmb![3] = 1.0
	
	#LightDif![0] = 1.0					'  Diffuse Light
	#LightDif![1] = 1.0
	#LightDif![2] = 1.0
	#LightDif![3] = 1.0
	
	#LightPos![0] = 4.0					'  Light Position
	#LightPos![1] = 4.0
	#LightPos![2] = 6.0
	#LightPos![3] = 1.0
	
	DIM #eqr#[3]											'  Plane Equation To Use For The Reflected Objects
	#eqr#[0] = 0.0
	#eqr#[1] = -1.0
	#eqr#[2] = 0.0
	#eqr#[3] = 0.0


	glShadeModel($$GL_SMOOTH)								 '  Enable Smooth Shading
	glClearColor(0.2, 0.5, 1.0, 1.0)						 '  Background
	glClearDepth(1.0)										 '  Depth Buffer Setup
	glClearStencil(0)										 '  Clear The Stencil Buffer To 0
	glEnable($$GL_DEPTH_TEST)								 '  Enables Depth Testing
	glDepthFunc($$GL_LEQUAL)								 '  The Type Of Depth Testing To Do
	glHint($$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)	 '  Really Nice Perspective Calculations
	glEnable($$GL_TEXTURE_2D)								 '  Enable 2D Texture Mapping

	glLightfv($$GL_LIGHT0, $$GL_AMBIENT, &#LightAmb![])			 '  Set The Ambient Lighting For Light0
	glLightfv($$GL_LIGHT0, $$GL_DIFFUSE, &#LightDif![])			 '  Set The Diffuse Lighting For Light0
	glLightfv($$GL_LIGHT0, $$GL_POSITION, &#LightPos![])		 '  Set The Position For Light0

	glEnable($$GL_LIGHT0)										 '  Enable Light 0
	glEnable($$GL_LIGHTING)										 '  Enable Lighting

	#Quadric = gluNewQuadric()									 '  Create A New Quadratic
	gluQuadricNormals(#Quadric, $$GL_SMOOTH)					 '  Generate Smooth Normals For The Quad
	gluQuadricTexture(#Quadric, $$GL_TRUE)						 '  Enable Texture Coords For The Quad

	glTexGeni($$GL_S, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)	 '  Set Up Sphere Mapping
	glTexGeni($$GL_T, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)	 '  Set Up Sphere Mapping

	
END FUNCTION 

FUNCTION DrawObject()										 '  Draw Our Ball

	glColor3f(1.0, 1.0, 1.0)						 		 '  Set Color To White
	glBindTexture($$GL_TEXTURE_2D, #texture[1])				 '  Select Texture 2 (1)
	gluSphere(#Quadric, 0.35, 32, 32)						 '  Draw First Sphere

	glBindTexture($$GL_TEXTURE_2D, #texture[2])				 '  Select Texture 3 (2)
	glColor4f(1.0, 1.0, 1.0, 0.4)							 '  Set Color To White With 40% Alpha
	glEnable($$GL_BLEND)									 '  Enable Blending
	glBlendFunc($$GL_SRC_ALPHA, $$GL_ONE)					 '  Set Blending Mode To Mix Based On SRC Alpha
	glEnable($$GL_TEXTURE_GEN_S)							 '  Enable Sphere Mapping
	glEnable($$GL_TEXTURE_GEN_T)							 '  Enable Sphere Mapping

	gluSphere(#Quadric, 0.35, 32, 32)						 '  Draw Another Sphere Using New Texture
															 '  Textures Will Mix Creating A MultiTexture Effect (Reflection)
	glDisable($$GL_TEXTURE_GEN_S)							 '  Disable Sphere Mapping
	glDisable($$GL_TEXTURE_GEN_T	)						 '  Disable Sphere Mapping
	glDisable($$GL_BLEND)									 '  Disable Blending
END FUNCTION

FUNCTION DrawFloor()										 '  Draws The Floor

	glBindTexture($$GL_TEXTURE_2D, #texture[0])			 '  Select Texture 1 (0)
	glBegin($$GL_QUADS)									 '  Begin Drawing A Quad
		glNormal3f(0.0, 1.0, 0.0)						 '  Normal Pointing Up
			glTexCoord2f(0.0, 1.0)						 '  Bottom Left Of Texture
			glVertex3f(-2.0, 0.0, 2.0)					 '  Bottom Left Corner Of Floor
			
			glTexCoord2f(0.0, 0.0)						 '  Top Left Of Texture
			glVertex3f(-2.0, 0.0,-2.0)					 '  Top Left Corner Of Floor
			
			glTexCoord2f(1.0, 0.0)						 '  Top Right Of Texture
			glVertex3f( 2.0, 0.0,-2.0)					 '  Top Right Corner Of Floor
			
			glTexCoord2f(1.0, 1.0)					 	 '  Bottom Right Of Texture
			glVertex3f( 2.0, 0.0, 2.0)					 '  Bottom Right Corner Of Floor
	glEnd()												 '  Done Drawing The Quad
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

FUNCTION LoadGLTextures ()

	DIM #texture [2]

	' load and set texture type
	glGenTextures (2,&#texture[])
	
	glBindTexture( $$GL_TEXTURE_2D, #texture[0])
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )
	glfwLoadTexture2D( &"xbsplash.tga", 0 )
	
	glBindTexture( $$GL_TEXTURE_2D, #texture[1])
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )
	glfwLoadTexture2D( &"Ball.tga", 0 )
	
	glBindTexture( $$GL_TEXTURE_2D, #texture[2])
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )
	glfwLoadTexture2D( &"Envroll.tga", 0 )

	RETURN $$TRUE

END FUNCTION

END PROGRAM
