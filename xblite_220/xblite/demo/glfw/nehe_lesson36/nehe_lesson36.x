 ' ========================================================================
 ' Based on lesson 36 by NeHe
 '
 ' XBLite\XBasic conversion by Michael McElligott 29/11/2002
 ' Mapei_@hotmail.com
 ' ========================================================================


	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "kernel32"
	IMPORT "msvcrt"


DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION EmptyTexture ()
DECLARE FUNCTION Update (XLONG time)
DECLARE FUNCTION DrawBlur(XLONG,SINGLE)
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)
DECLARE FUNCTION FillArray (SINGLE @array[], SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)
DECLARE FUNCTION ProcessHelix ()
DECLARE FUNCTION ReduceToUnit (SINGLE @array[])
DECLARE FUNCTION RenderToTexture ()
DECLARE FUNCTION ViewOrtho ()
DECLARE FUNCTION ViewPerspective ()
DECLARE FUNCTION calcNormal (SINGLE @v[], SINGLE @out[])


FUNCTION Main ()
	STATIC XLONG lastTickCount

	Create ()
	Init ()

	event = 1
	DO

		tickCount = GetTickCount ()						'  Get The Tick Count
		Update (tickCount - lastTickCount)		'  Update The Counter
		lastTickCount = tickCount							'  Set Last Count To Current Count
		Render ()

		glfwSwapBuffers ()

		IF ((glfwGetKey ( 'Q') = 1) || glfwGetWindowParam ($$GLFW_OPENED) = 0) THEN event = 0

		' glfwSleep(0.01)

	LOOP WHILE event = 1

	glfwTerminate ()

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
    glfwInit()
    IFZ glfwOpenWindow(#Width,#Height, 0,0,0,0, 32,0, $$GLFW_WINDOW ) THEN
        glfwTerminate()
        RETURN 0
    END IF
    
    glfwSetWindowTitle( &"XBlite Radial Blur" )
    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
    glfwSetMousePosCallback (&MousePos() ) 
    'glfwSwapInterval( 0 )
    
	glfwEnable( $$GLFW_KEY_REPEAT )

END FUNCTION

FUNCTION key (k,action)
	SHARED GLfloat yrot,xrotspeed,yrotspeed,zoom,bheight

	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k
	
		CASE ' ' : IF #AutoSpin=1 THEN #AutoSpin=0 ELSE #AutoSpin=1

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

	glClearColor(0.0, 0.0, 0.0, 0.5)							 '  Set The Clear Color To Black
	glClear ( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)	 '  Clear Screen And Depth Buffer
	glLoadIdentity()											 '  Reset The View	
	RenderToTexture()											 '  Render To A Texture
	ProcessHelix()												 '  Draw Our Helix
	DrawBlur(25,0.02)											 '  Draw The Blur Effect
	glFlush ()													 '  Flush The GL Rendering Pipeline
	

END FUNCTION

FUNCTION FillArray (SINGLE array[], SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)

	array[0] = v1
	array[1] = v2
	array[2] = v3
	array[3] = v4

END FUNCTION

FUNCTION Init()
	SHARED SINGLE vertexes[],global_ambient[],lmodel_ambient[]
	SHARED SINGLE light0specular[],light0diffuse[],light0ambient[],light0pos[]
	SHARED SINGLE glfMaterialColor[], specular[],normal[]
	SHARED SINGLE angle
	SHARED XLONG BlurTexture
	
	DIM vertexes[3,3]
	DIM global_ambient[3]
	DIM lmodel_ambient[3]
	DIM light0specular[3]
	DIM light0diffuse[3]
	DIM light0ambient[3]
	DIM light0pos[3]
	
	DIM glfMaterialColor[3]
	DIM specular[3]
	DIM normal[2]
	
	FillArray (@global_ambient[], 0.2, 0.2,  0.2, 1.0)		 '  Set Ambient Lighting To Fairly Dark Light (No Color)
	FillArray (@light0pos[], 0.0, 5.0, 10.0, 1.0)			 '  Set The Light Position
	FillArray (@light0ambient[], 0.2, 0.2,  0.2, 1.0)		 '  More Ambient Light
	FillArray (@light0diffuse[], 0.3, 0.3,  0.3, 1.0)		 '  Set The Diffuse Light A Bit Brighter
	FillArray (@light0specular[], 0.8, 0.8,  0.8, 1.0)		 '  Fairly Bright Specular Lighting
	FillArray (@lmodel_ambient[], 0.2,0.2,0.2,1.0)			 '  And More Ambient Light
		
	#AutoSpin=1
	angle		= 0.0										 '  Set Starting Angle To Zero
	BlurTexture = EmptyTexture()							 '  Create Our Empty Texture

	glViewport(0 , 0,#Width ,#Height)	 '  Set Up A Viewport
	glMatrixMode( $$GL_PROJECTION)									 '  Select The Projection Matrix
	glLoadIdentity()												 '  Reset The Projection Matrix
	gluPerspective(50, SINGLE (#Width)/ SINGLE (#Height), 5,  2000)  '  Set Our Perspective
	glMatrixMode( $$GL_MODELVIEW)									 '  Select The Modelview Matrix
	glLoadIdentity()												 '  Reset The Modelview Matrix

	glEnable( $$GL_DEPTH_TEST)										 '  Enable Depth Testing

	glLightModelfv( $$GL_LIGHT_MODEL_AMBIENT,&lmodel_ambient[])		 '  Set The Ambient Light Model
	glLightModelfv( $$GL_LIGHT_MODEL_AMBIENT, &global_ambient[])	 '  Set The Global Ambient Light Model
	glLightfv( $$GL_LIGHT0, $$GL_POSITION, &light0pos[])			 '  Set The Lights Position
	glLightfv( $$GL_LIGHT0, $$GL_AMBIENT, &light0ambient[])			 '  Set The Ambient Light
	glLightfv( $$GL_LIGHT0, $$GL_DIFFUSE, &light0diffuse[])			 '  Set The Diffuse Light
	glLightfv( $$GL_LIGHT0, $$GL_SPECULAR, &light0specular[])		 '  Set Up Specular Lighting
	glEnable( $$GL_LIGHTING)										 '  Enable Lighting
	glEnable( $$GL_LIGHT0)											 '  Enable Light0

	glShadeModel( $$GL_SMOOTH)										 '  Select Smooth Shading
	glHint($$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)			 '  Really Nice Perspective Calculations
	glMateriali( $$GL_FRONT, $$GL_SHININESS, 128)
	glClearColor(0.0, 0.0, 0.0, 0.5)								 '  Set The Clear Color To Black

	
END FUNCTION 

FUNCTION RenderToTexture()											 '  Renders To A Texture
	SHARED XLONG BlurTexture

	glViewport(0,0,128,128)											 '  Set Our Viewport (Match Texture Size)
	ProcessHelix()													 '  Render The Helix
	glBindTexture( $$GL_TEXTURE_2D,BlurTexture)						 '  Bind To The Blur Texture

	 '  Copy Our ViewPort To The Blur Texture (From 0,0 To 128,128... No Border)
	glCopyTexImage2D( $$GL_TEXTURE_2D, 0, $$GL_LUMINANCE, 0, 0, 128, 128, 0)

	glClearColor(0.0, 0.0, 0.5, 0.5)								 '  Set The Clear Color To Medium Blue
	glClear( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)			 '  Clear The Screen And Depth Buffer

	glViewport(0 , 0,#Width ,#Height)										 '  Set Viewport (0,0 to #Width x #Height)

END FUNCTION

FUNCTION DrawBlur( XLONG  times, SINGLE inc)						 '  Draw The Blurred Image
	SINGLE spost,alpha,alphainc
	SHARED XLONG BlurTexture

	 spost = 0.0													 '  Starting Texture Coordinate Offset
	 alphainc = 0.9 / times											 '  Fade Speed For Alpha Blending
	 alpha = 0.2													 '  Starting Alpha Value

	 '  Disable AutoTexture Coordinates
	glDisable( $$GL_TEXTURE_GEN_S)
	glDisable( $$GL_TEXTURE_GEN_T)

	glEnable( $$GL_TEXTURE_2D)									 '  Enable 2D Texture Mapping
	glDisable( $$GL_DEPTH_TEST)									 '  Disable Depth Testing
	glBlendFunc( $$GL_SRC_ALPHA,$$GL_ONE)						 '  Set Blending Mode
	glEnable( $$GL_BLEND)										 '  Enable Blending
	glBindTexture( $$GL_TEXTURE_2D,BlurTexture)					 '  Bind To The Blur Texture
	ViewOrtho()													 '  Switch To An Ortho View

	alphainc = alpha / times									 '  alphainc=0.2f / Times To Render Blur

	glBegin( $$GL_QUADS)										 '  Begin Drawing Quads
		FOR num = 0 TO times-1   								 '  Number Of Times To Render Blur
		
			glColor4f(1.0, 1.0, 1.0, alpha)						 '  Set The Alpha Value (Starts At 0.2)
			glTexCoord2f(0 + spost,1 - spost)					 '  Texture Coordinate	( 0, 1 )
			glVertex2f(0,0)										 '  First Vertex		(   0,   0 )

			glTexCoord2f(0 + spost,0 + spost)					 '  Texture Coordinate	( 0, 0 )
			glVertex2f(0,#Height)									 '  Second Vertex	(   0, #Height )

			glTexCoord2f(1 - spost,0 + spost)					 '  Texture Coordinate	( 1, 0 )
			glVertex2f(#Width,#Height)									 '  Third Vertex		( #Width, #Height )

			glTexCoord2f(1 - spost,1 - spost)					 '  Texture Coordinate	( 1, 1 )
			glVertex2f(#Width,0)									 '  Fourth Vertex	( #Width,   0 )

			spost = spost  + inc								 '  Gradually Increase spost (Zooming Closer To Texture Center)
			alpha = alpha - alphainc							 '  Gradually Decrease alpha (Gradually Fading Image Out)
		NEXT num
	glEnd()														 '  Done Drawing Quads

	ViewPerspective()											 '  Switch To A Perspective View

	glEnable( $$GL_DEPTH_TEST)									 '  Enable Depth Testing
	glDisable( $$GL_TEXTURE_2D)									 '  Disable 2D Texture Mapping
	glDisable( $$GL_BLEND)										 '  Disable Blending
	glBindTexture( $$GL_TEXTURE_2D,0)							 '  Unbind The Blur Texture

END FUNCTION

FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height < 50) THEN #Height = 50

	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(50.0, SINGLE(#Width/#Height), 5, 2000.0)
	glMatrixMode( $$GL_MODELVIEW)
	glLoadIdentity()

END FUNCTION


FUNCTION Update (XLONG milliseconds)								 '  Perform Motion Updates Here
	SHARED SINGLE angle

	angle = angle + SINGLE(milliseconds) / 5.0						 '  Update angle Based On The Clock
	
END FUNCTION

FUNCTION ViewOrtho()
'	SHARED mx,my												 '  Set Up An Ortho View

	glMatrixMode( $$GL_PROJECTION)								 '  Select Projection
	glPushMatrix()												 '  Push The Matrix
	glLoadIdentity()											 '  Reset The Matrix

	'glRotatef( SINGLE(mx-(#Width/2)), 0.0, 1.0, 0.0)
	'glRotatef( SINGLE(my-(#Height/2)), 1.0, 0.0, 0.0)

	glOrtho( 0, #Width , #Height , 0, -1, 1 )					 '  Select Ortho Mode (#Width x #Height)
	glMatrixMode( $$GL_MODELVIEW)								 '  Select Modelview Matrix
	glPushMatrix()												 '  Push The Matrix
	glLoadIdentity()											 '  Reset The Matrix
	
END FUNCTION

FUNCTION ViewPerspective()										 '  Set Up A Perspective View

	glMatrixMode( $$GL_PROJECTION )								 '  Select Projection
	glPopMatrix()												 '  Pop The Matrix
	glMatrixMode( $$GL_MODELVIEW )								 '  Select Modelview
	glPopMatrix()												 '  Pop The Matrix
	
END FUNCTION

FUNCTION ProcessHelix()												 '  Draws A Helix
	SHARED SINGLE vertexes[],glfMaterialColor[], specular[],normal[]
	SHARED SINGLE angle
	GLfloat x,y,z,phi,theta,v,u,r
	XLONG twists
	SHARED mx,my
	

'	GLfloat x													 '  Helix x Coordinate
'	GLfloat y													 '  Helix y Coordinate
'	GLfloat z													 '  Helix z Coordinate
'	GLfloat phi													 '  Angle
'	GLfloat theta												 '  Angle
'	GLfloat v,u													 '  Angles
'	GLfloat r													 '  Radius Of Twist
	twists = 5													 '  5 Twists

	'DIM glfMaterialColor[3]
	'DIM specular[3]

	FillArray (@glfMaterialColor[], 0.4,0.2,0.8,1.0)			 '  Set The Material Color
	FillArray (@specular[], 1.0,1.0,1.0,1.0)					 '  Sets Up Specular Lighting

	glLoadIdentity()											 '  Reset The Modelview Matrix
	gluLookAt(0, 5, 50, 0, 0, 0, 0, 1, 0)						 '  Eye Position (0,5,50) Center Of Scene (0,0,0), Up On Y Axis

	glPushMatrix()												 '  Push The Modelview Matrix

	glTranslatef(0,0,-50)										 '  Translate 50 Units Into The Screen
	
	IF #AutoSpin=1 THEN 
		glRotatef(angle/2.0,1,0,0)									 '  Rotate By angle/2 On The X-Axis
		glRotatef(angle/3.0,0,1,0)									 '  Rotate By angle/3 On The Y-Axis
	ELSE
		glRotatef( SINGLE(mx-(#Width/2)), 0.0, 1.0, 0.0)			 '	Use Mouse to control
		glRotatef( SINGLE(my-(#Height/2)), 1.0, 0.0, 0.0)
	END IF

    glMaterialfv( $$GL_FRONT_AND_BACK,$$GL_AMBIENT_AND_DIFFUSE, &glfMaterialColor[])
	glMaterialfv( $$GL_FRONT_AND_BACK,$$GL_SPECULAR, &specular[])
	
	r=1.5															 '  Radius

	glBegin( $$GL_QUADS)											 '  Begin Drawing Quads
	FOR phi = 0 TO 360 STEP 20										 '  360 Degrees In Steps Of 20
	
		FOR theta = 0 TO (360 * twists) STEP 20   					 '  360 Degrees * Number Of Twists In Steps Of 20
		
			v=(phi / 180.0 * 3.142)									 '  Calculate Angle Of First Point	(  0 )
			u=(theta / 180.0 * 3.142)								 '  Calculate Angle Of First Point	(  0 )

			x= SINGLE ((cos(u)*(2.0 + cos(v) ))*r)					 '  Calculate x Position (1st Point)
			y= SINGLE ((sin(u)*(2.0 + cos(v) ))*r)					 '  Calculate y Position (1st Point)
			z= SINGLE ((( u - (2.0 * 3.142)) + sin(v) )) * r		 '  Calculate z Position (1st Point)

			vertexes[0,0]=x											 '  Set x Value Of First Vertex
			vertexes[0,1]=y											 '  Set y Value Of First Vertex
			vertexes[0,2]=z											 '  Set z Value Of First Vertex

			v=(phi/180.0 * 3.142)									 '  Calculate Angle Of Second Point	(  0 )
			u=((theta + 20)/ 180.0 * 3.142 )						 '  Calculate Angle Of Second Point	( 20 )

			x= SINGLE (cos(u)*(2.0 + cos(v) ))*r					 '  Calculate x Position (2nd Point)
			y= SINGLE (sin(u)*(2.0 + cos(v) ))*r					 '  Calculate y Position (2nd Point)
			z= SINGLE ((( u-(2.0 * 3.142 )) + sin(v) )) * r			 '  Calculate z Position (2nd Point)

			vertexes[1,0]=x											 '  Set x Value Of Second Vertex
			vertexes[1,1]=y											 '  Set y Value Of Second Vertex
			vertexes[1,2]=z											 '  Set z Value Of Second Vertex

			v=((phi + 20)/ 180.0 * 3.142)							 '  Calculate Angle Of Third Point	( 20 )
			u=((theta + 20)/ 180.0 * 3.142)							 '  Calculate Angle Of Third Point	( 20 )

			x= SINGLE (cos(u)*(2.0 + cos(v) ))*r					 '  Calculate x Position (3rd Point)
			y= SINGLE (sin(u)*(2.0 + cos(v) ))*r					 '  Calculate y Position (3rd Point)
			z= SINGLE ((( u-(2.0 * 3.142)) + sin(v) )) * r			 '  Calculate z Position (3rd Point)

			vertexes[2,0]=x											 '  Set x Value Of Third Vertex
			vertexes[2,1]=y											 '  Set y Value Of Third Vertex
			vertexes[2,2]=z									 		 '  Set z Value Of Third Vertex

			v=((phi + 20)/ 180.0 * 3.142)							 '  Calculate Angle Of Fourth Point	( 20 )
			u=((theta)/ 180.0 * 3.142)								 '  Calculate Angle Of Fourth Point	(  0 )

			x= SINGLE (cos(u)*(2.0 + cos(v) ))*r					 '  Calculate x Position (4th Point)
			y= SINGLE (sin(u)*(2.0 + cos(v) ))*r					 '  Calculate y Position (4th Point)
			z= SINGLE ((( u-(2.0 * 3.142 )) + sin(v) )) * r			 '  Calculate z Position (4th Point)

			vertexes[3,0]=x											 '  Set x Value Of Fourth Vertex
			vertexes[3,1]=y											 '  Set y Value Of Fourth Vertex
			vertexes[3,2]=z											 '  Set z Value Of Fourth Vertex

			calcNormal(@vertexes[],@normal[])						 '  Calculate The Quad Normal
			glNormal3f(normal[0],normal[1],normal[2])				 '  Set The Normal

			 '  Render The Quad
			glVertex3f(vertexes[0,0],vertexes[0,1],vertexes[0,2])
			glVertex3f(vertexes[1,0],vertexes[1,1],vertexes[1,2])
			glVertex3f(vertexes[2,0],vertexes[2,1],vertexes[2,2])
			glVertex3f(vertexes[3,0],vertexes[3,1],vertexes[3,2])
		NEXT theta
	NEXT phi
	glEnd()														 '  Done Rendering Quads
	
	glPopMatrix()												 '  Pop The Matrix
END FUNCTION

FUNCTION ReduceToUnit (SINGLE vector[])							 '  Reduces A Normal Vector (3 Coordinates)
																 '  To A Unit Normal Vector With A Length Of One.
	SINGLE length												 '  Holds Unit Length
	 '  Calculates The Length Of The Vector
	length = SINGLE (sqrt((vector[0]*vector[0]) + (vector[1]*vector[1]) + (vector[2]*vector[2])))

	IF (length == 0.0) THEN										 '  Prevents Divide By 0 Error By Providing
		length = 1.0											 '  An Acceptable Value For Vectors To Close To 0.
	END IF

	vector[0] = vector[0] / length								 '  Dividing Each Element By
	vector[1] = vector[1] / length								 '  The Length Results In A
	vector[2] = vector[2] / length								 '  Unit Normal Vector.
	
END FUNCTION

FUNCTION calcNormal (SINGLE v[], SINGLE out[])					 '  Calculates Normal For A Quad Using 3 Points
	SHARED SINGLE normal[]
	SINGLE v1[],v2[]
	
	DIM v1[2]
	DIM v2[2]
	
	x=0
	y=1
	z=2

'	float v1[3],v2[3]											 '  Vector 1 (x,y,z) & Vector 2 (x,y,z)
'	static const int x = 0										 '  Define X Coord
'	static const int y = 1										 '  Define Y Coord
'	static const int z = 2										 '  Define Z Coord

	 '  Finds The Vector Between 2 Points By Subtracting
	 '  The x,y,z Coordinates From One Point To Another.

	 '  Calculate The Vector From Point 1 To Point 0
	v1[x] = v[0,x] - v[1,x]										 '  Vector 1.x=Vertex[0].x-Vertex[1].x
	v1[y] = v[0,y] - v[1,y]										 '  Vector 1.y=Vertex[0].y-Vertex[1].y
	v1[z] = v[0,z] - v[1,z]									 	 '  Vector 1.z=Vertex[0].y-Vertex[1].z
	 '  Calculate The Vector From Point 2 To Point 1
	v2[x] = v[1,x] - v[2,x]									 	 '  Vector 2.x=Vertex[0].x-Vertex[1].x
	v2[y] = v[1,y] - v[2,y]										 '  Vector 2.y=Vertex[0].y-Vertex[1].y
	v2[z] = v[1,z] - v[2,z]										 '  Vector 2.z=Vertex[0].z-Vertex[1].z
	 '  Compute The Cross Product To Give Us A Surface Normal
	out[x] = v1[y]*v2[z] - v1[z]*v2[y]							 '  Cross Product For Y - Z
	out[y] = v1[z]*v2[x] - v1[x]*v2[z]							 '  Cross Product For X - Z
	out[z] = v1[x]*v2[y] - v1[y]*v2[x]							 '  Cross Product For X - Y

	ReduceToUnit(@out[])										 '  Normalize The Vectors
	
END FUNCTION


FUNCTION EmptyTexture()											 '  Create An Empty Texture
	 UBYTE data[]												 '  Stored Data
	 XLONG txtnumber											 '  Texture ID
										 
	'  Stored Data
	 '  Create Storage Space For Texture Data (128x128x4)
	DIM data [128*128*4]

	glGenTextures(1, &txtnumber)								 '  Create 1 Texture
	glBindTexture( $$GL_TEXTURE_2D, txtnumber)					 '  Bind The Texture
	glTexImage2D( $$GL_TEXTURE_2D, 0, 4, 128, 128, 0, $$GL_RGBA, $$GL_UNSIGNED_BYTE, &data[])	 '  Build Texture Using Information In data
	glTexParameteri( $$GL_TEXTURE_2D,$$GL_TEXTURE_MIN_FILTER,$$GL_LINEAR)
	glTexParameteri( $$GL_TEXTURE_2D,$$GL_TEXTURE_MAG_FILTER,$$GL_LINEAR)

	REDIM data[]												 '  Release data

	RETURN txtnumber											 '  Return The Texture ID
END FUNCTION

END PROGRAM
