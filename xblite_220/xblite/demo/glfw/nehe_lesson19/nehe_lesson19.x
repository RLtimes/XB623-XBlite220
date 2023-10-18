 ' ========================================================================
 ' Based on NeHe lesson 19
 '
 ' XBLite\XBasic conversion by Michael McElligott 1/12/2002
 ' Mapei_@hotmail.com
 ' ========================================================================


	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "msvcrt"


TYPE particles					 '  Create A Structure For Particle
	XLONG	.active					 '  Active (Yes/No)
	SINGLE	.life					 '  Particle Life
	SINGLE	.fade					 '  Fade Speed
	SINGLE	.r						 '  Red Value
	SINGLE	.g						 '  Green Value
	SINGLE	.b						 '  Blue Value
	SINGLE	.x						 '  X Position
	SINGLE	.y						 '  Y Position
	SINGLE	.z						 '  Z Position
	SINGLE	.xi						 '  X Direction
	SINGLE	.yi						 '  Y Direction
	SINGLE	.zi						 '  Z Direction
	SINGLE	.xg						 '  X Gravity
	SINGLE	.yg						 '  Y Gravity
	SINGLE	.zg						 '  Z Gravity
END TYPE


DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadGLTexture (file)
DECLARE FUNCTION FillArray (array, SINGLE v1, SINGLE v2, SINGLE v3) ', SINGLE v4)
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)


FUNCTION Main ()
	SHARED delay,col,rainbow
	SHARED SINGLE zoom

	Create ()
	Init()

	event=1
	DO
	
	
		Render ()
		glfwSwapBuffers ()


		IF rainbow = $$TRUE THEN
			INC col
			IF col>11 THEN col=0
		END IF

	    IF glfwGetKey('A')=1 THEN
	    	zoom = zoom + 0.4
	    END IF

	    IF glfwGetKey('Z')=1 THEN
	    	zoom = zoom - 0.4	
	    END IF

		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN event=0
		
		IF (#vsync = 1) THEN glfwSleep(0.01)

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
    
    glfwSetWindowTitle( &"XBlite NeHe Lesson 19 - Particles" )
    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
   ' glfwSetMousePosCallback (&MousePos() ) 
    glfwSwapInterval( 1 )
    
	glfwEnable( $$GLFW_KEY_REPEAT )
	#vsync = 1

END FUNCTION

FUNCTION key (k,action)
	SHARED SINGLE xspeed,yspeed,zoom,slowdown
	SHARED rainbow
	
	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k
	
		CASE $$GLFW_KEY_UP :
			IF yspeed< 200 THEN yspeed = yspeed + 1.0
			#up = $$TRUE
		CASE $$GLFW_KEY_DOWN :
			IF yspeed> -200 THEN yspeed = yspeed - 1.0			
			#down = $$TRUE
		CASE $$GLFW_KEY_LEFT :
			IF xspeed> -200 THEN xspeed = xspeed - 1.0			
			#left = $$TRUE
		CASE $$GLFW_KEY_RIGHT :
			IF xspeed < 200 THEN xspeed = xspeed + 1.0						
			#right = $$TRUE
	    CASE ' ' :
	    	IF rainbow = $$TRUE THEN rainbow = $$FALSE ELSE rainbow = $$TRUE
	    CASE 'S' :
	    	IF slowdown>1 THEN slowdown = slowdown - 0.04
	    CASE 'X' :
	    	IF slowdown<4 THEN slowdown = slowdown + 0.04	    	
	    CASE 'B' : 	#burst=1

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
	SHARED mx,my
	
	mx=x
	my=y
	
END FUNCTION


FUNCTION Render()
	SHARED particles particle[]
	SHARED SINGLE colors[]
	SHARED SINGLE slowdown,xspeed,yspeed,zoom
	SHARED rainbow,col,delay, MAX_PARTICLES,mx,my
	SINGLE z,x,y

	
	glClear($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)		 '  Clear Screen And Depth Buffer
	glLoadIdentity()										 '  Reset The ModelView Matrix

	FOR loop = 0 TO MAX_PARTICLES-1					 '  Loop Through All The Particles
	
		IF (particle[loop].active = $$TRUE ) THEN							 '  If The Particle Is Active
		
			x=particle[loop].x						 '  Grab Our Particle X Position
			y=particle[loop].y						 '  Grab Our Particle Y Position
			z=particle[loop].z + zoom					 '  Particle Z Pos + Zoom

			 '  Draw The Particle Using Our RGB Values, Fade The Particle Based On It's Life
			glColor4f(particle[loop].r,particle[loop].g,particle[loop].b,particle[loop].life)

			glBegin($$GL_TRIANGLE_STRIP)						 '  Build Quad From A Triangle Strip
			    glTexCoord2d(1,1): glVertex3f(x+0.5,y + 0.5,z)  '  Top Right
				glTexCoord2d(0,1): glVertex3f(x-0.5,y + 0.5,z)  '  Top Left
				glTexCoord2d(1,0): glVertex3f(x+0.5,y - 0.5,z)  '  Bottom Right
				glTexCoord2d(0,0): glVertex3f(x-0.5,y - 0.5,z)  '  Bottom Left
			glEnd()										 '  Done Building Triangle Strip

			particle[loop].x =particle[loop].x + particle[loop].xi / (slowdown * 1000) '  Move On The X Axis By X Speed
			particle[loop].y =particle[loop].y + particle[loop].yi / (slowdown * 1000) '  Move On The Y Axis By Y Speed
			particle[loop].z =particle[loop].z + particle[loop].zi / (slowdown * 1000) '  Move On The Z Axis By Z Speed

			particle[loop].xi=particle[loop].xi + particle[loop].xg			 '  Take Pull On X Axis Into Account
			particle[loop].yi=particle[loop].yi + particle[loop].yg			 '  Take Pull On Y Axis Into Account
			particle[loop].zi=particle[loop].zi + particle[loop].zg			 '  Take Pull On Z Axis Into Account
			particle[loop].life=particle[loop].life - particle[loop].fade		 '  Reduce Particles Life By 'Fade'

			IF particle[loop].life < 0.0 THEN				 '  If Particle Is Burned Out
			
				particle[loop].life=1.0					 '  Give It New Life
				particle[loop].fade= SINGLE (rand() MOD 100) / SINGLE (1000.0) + SINGLE (0.003)	 '  Random Fade Value
				particle[loop].x=0.0						 '  Center On X Axis
				particle[loop].y=0.0						 '  Center On Y Axis
				particle[loop].z=0.0						 '  Center On Z Axis
				particle[loop].xi=xspeed+ SINGLE ((rand() MOD 60)-32.0)	 '  X Axis Speed And Direction
				particle[loop].yi=yspeed+ SINGLE ((rand() MOD 60)-30.0)	 '  Y Axis Speed And Direction
				particle[loop].zi= SINGLE ((rand() MOD 60)-30.0)	 '  Z Axis Speed And Direction
				particle[loop].r=colors[col,0]			 '  Select Red From Color Table
				particle[loop].g=colors[col,1]			 '  Select Green From Color Table
				particle[loop].b=colors[col,2]			 '  Select Blue From Color Table
				
			END IF


			IF ((#up = $$TRUE) && (particle[loop].yg<1.5)) THEN
				particle[loop].yg = particle[loop].yg + 0.01
			END IF
		
			IF ((#down = $$TRUE) && (particle[loop].yg>-1.5)) THEN
				particle[loop].yg = particle[loop].yg - 0.01
			END IF			
			
			IF ((#right = $$TRUE) && (particle[loop].xg<1.5)) THEN
				particle[loop].xg = particle[loop].xg + 0.01
			END IF			
			
			IF ((#left = $$TRUE) && (particle[loop].xg>-1.5)) THEN
				particle[loop].xg = particle[loop].xg - 0.01
			END IF						
			

			IF #burst = 1 THEN										 '  b Key Causes A Burst
			
				particle[loop].x= 0.0								 '  Center On X Axis
				particle[loop].y= 0.0								 '  Center On Y Axis
				particle[loop].z= 0.0								 '  Center On Z Axis
				particle[loop].xi= SINGLE ((rand() MOD 50)-26.0)* 10.0	 '  Random Speed On X Axis
				particle[loop].yi= SINGLE ((rand() MOD 50)-25.0)* 10.0	 '  Random Speed On Y Axis
				particle[loop].zi= SINGLE ((rand() MOD 50)-25.0)* 10.0	 '  Random Speed On Z Axis
				
			END IF
		END IF
		
    NEXT loop
    
    #up = $$FALSE
    #down = $$FALSE
    #left = $$FALSE
    #right = $$FALSE
    #burst = 0

	RETURN $$TRUE										 '  Keep Going

END FUNCTION

FUNCTION Init()
	SHARED SINGLE slowdown,xspeed,yspeed,zoom
	SHARED rainbow,col,delay,MAX_PARTICLES
	SHARED particles particle[]
	SHARED SINGLE colors[]
	
	slowdown = 2.0				 '  Slow Down Particles
	xspeed = 0.01						 '  Base X Speed (To Allow Keyboard Direction Of Tail)
	yspeed = 0.01						 '  Base Y Speed (To Allow Keyboard Direction Of Tail)
	zoom = -40.0					 '  Used To Zoom Out
	col = 0						 '  Current Color Selection
	rainbow = $$TRUE

	MAX_PARTICLES = 1000
	DIM particle[MAX_PARTICLES]
	
	DIM colors[11,2]		 '  Rainbow Of Colors

	FillArray (&colors[0,0],1.0,0.5,0.5)
	FillArray (&colors[1,0],1.0,0.75,0.5)
	FillArray (&colors[2,0],1.0,1.0,0.5)
	FillArray (&colors[3,0],0.75,1.0,0.5)
	FillArray (&colors[4,0],0.5,1.0,0.5)
	FillArray (&colors[5,0],0.5,1.0,0.75) 
	FillArray (&colors[6,0],0.5,1.0,1.0) 
	FillArray (&colors[7,0],0.5,0.75,1.0)
	FillArray (&colors[8,0],0.5,0.5,1.0) 
	FillArray (&colors[9,0],0.75,0.5,1.0)
	FillArray (&colors[10,0],1.0,0.5,1.0)
	FillArray (&colors[11,0],1.0,0.5,0.75)		
	
	#texture = LoadGLTexture (&"Particle.tga")								 '  Load the texture
	
	glShadeModel($$GL_SMOOTH)							 '  Enable Smooth Shading
	glClearColor(0.0,0.0,0.0,0.0)					 '  Black Background
	glClearDepth(1.0)									 '  Depth Buffer Setup
	glDisable($$GL_DEPTH_TEST)							 '  Disable Depth Testing
	glEnable($$GL_BLEND)									 '  Enable Blending
	glBlendFunc($$GL_SRC_ALPHA, $$GL_ONE)					 '  Type Of Blending To Perform
	glHint($$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)	 '  Really Nice Perspective Calculations
	glHint($$GL_POINT_SMOOTH_HINT, $$GL_NICEST)				 '  Really Nice Point Smoothing
	glEnable($$GL_TEXTURE_2D)							 '  Enable Texture Mapping
	glBindTexture($$GL_TEXTURE_2D, #texture)			 '  Select Our Texture

	FOR loop = 0 TO MAX_PARTICLES-1			 '  Initials All The Textures
	
		particle[loop].active = $$TRUE								 '  Make All The Particles Active
		particle[loop].life= 1.0								 '  Give All The Particles Full Life
		particle[loop].fade= SINGLE (rand() MOD 100)/ SINGLE (1000.0) + SINGLE (0.003)	 '  Random Fade Speed
		particle[loop].r=colors[loop*(12 / MAX_PARTICLES),0]	 '  Select Red Rainbow Color
		particle[loop].g=colors[loop*(12 / MAX_PARTICLES),1]	 '  Select Red Rainbow Color
		particle[loop].b=colors[loop*(12 / MAX_PARTICLES),2]	 '  Select Red Rainbow Color
		particle[loop].xi= SINGLE ((rand() MOD 50)-26.0)* 10.0		 '  Random Speed On X Axis
		particle[loop].yi= SINGLE ((rand() MOD 50)-25.0)* 10.0		 '  Random Speed On Y Axis
		particle[loop].zi= SINGLE ((rand() MOD 50)-25.0)* 10.0		 '  Random Speed On Z Axis
		particle[loop].xg=0.0									 '  Set Horizontal Pull To Zero
		particle[loop].yg=-0.8								 '  Set Vertical Pull Downward
		particle[loop].zg= 0.0									 '  Set Pull On Z Axis To Zero
		
	NEXT loop	

END FUNCTION 

FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height < 50) THEN #Height = 50

	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(45.0, SINGLE(#Width/#Height), 0.1, 200.0)
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

FUNCTION FillArray ( array, SINGLE v1, SINGLE v2, SINGLE v3 ) ', SINGLE v4)

	
	SINGLEAT (array)= v1
	SINGLEAT (array+4)= v2
	SINGLEAT (array+8)= v3
	'SINGLEAT (array+12)= v4

END FUNCTION


END PROGRAM
