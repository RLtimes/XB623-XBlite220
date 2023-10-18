 ' ========================================================================
 ' Based on lesson 34 by NeHe
 ' Height Mapping
 '
 ' XBLite\XBasic conversion by Michael McElligott 1/12/2002
 ' Mapei_@hotmail.com
 ' ========================================================================


	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "msvcrt"
	IMPORT "gdi32.dec"
	IMPORT "user32"



DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadGLTexture (fileAddr)
DECLARE FUNCTION FillArray (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)

DECLARE FUNCTION LoadRawFile( strName,  nSize, pHeightMap)
DECLARE FUNCTION Height (pHeightMap,  X,  Y)
DECLARE FUNCTION SetVertexColor (pHeightMap,  x,  y)
DECLARE FUNCTION RenderHeightMap (pHeightMap)



FUNCTION Main ()
	SHARED SINGLE scaleValue
	
	Create ()
	Init()
	
	event=1
	DO
	
		Render ()
		
		glfwSwapBuffers ()
		
		IF glfwGetKey($$GLFW_KEY_UP)= 1 THEN
			scaleValue = scaleValue + 0.001
		END IF
		
		IF glfwGetKey($$GLFW_KEY_DOWN)= 1 THEN
			scaleValue = scaleValue - 0.001
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
    
    glfwSetWindowTitle( &"XBlite Height Mapping" )
    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
    glfwSetMousePosCallback (&MousePos() ) 
    glfwSwapInterval( 1 )
    
	glfwEnable( $$GLFW_KEY_REPEAT )
	#vsync = 1

END FUNCTION

FUNCTION key (k,action)
	SHARED bRender
	SHARED SINGLE scaleValue,HEIGHT_RATIO
	SHARED STEP_SIZE
	SHARED map_list
	
	
	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k
	
		CASE 'A'
			HEIGHT_RATIO = HEIGHT_RATIO + 0.2
			IF map_list <> 0 THEN glDeleteLists (map_list ,1)
			map_list = 0
			
		CASE 'Z'
			HEIGHT_RATIO = HEIGHT_RATIO - 0.2		
			IF map_list <> 0 THEN glDeleteLists (map_list ,1)
			map_list = 0
			
		CASE 'S'
			STEP_SIZE = STEP_SIZE - 2
			IF STEP_SIZE < 2 THEN STEP_SIZE = 2
			IF map_list <> 0 THEN glDeleteLists (map_list ,1)
			map_list = 0
			
		CASE 'X'
			STEP_SIZE = STEP_SIZE + 2		
			IF map_list <> 0 THEN glDeleteLists (map_list ,1)
			map_list = 0			
	
		CASE ' ':
			IF bRender=1 THEN
				IF map_list <> 0 THEN glDeleteLists (map_list ,1)
				bRender = 0
				map_list = 0
				
			ELSE
				IF map_list <> 0 THEN glDeleteLists (map_list ,1)
				bRender = 1
				map_list = 0
			END IF

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
	SHARED SINGLE HEIGHT_RATIO,scaleValue
	SHARED UBYTE g_HeightMap[]
	SHARED mx,my

	glClear( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)	 '  Clear The Screen And The Depth Buffer
	glLoadIdentity()									 '  Reset The Matrix
	
	 '  	 Position	      View	  	Up Vector
	gluLookAt(212, 55, 194,  186, 55 , 171,  0,1,0)	 '  This Determines Where The Camera's Position And View Is

	glScalef(scaleValue, scaleValue * HEIGHT_RATIO, scaleValue)

	RenderHeightMap(&g_HeightMap[])						 '  Render The Height Map

	RETURN $$TRUE										 '  Keep Going

END FUNCTION

FUNCTION  Height (pHeightMap,  X,  Y)				 '  This Returns The Height From A Height Map Index
	SHARED MAP_SIZE

	x = X MOD MAP_SIZE								 '  Error Check Our x Value
	y = Y MOD MAP_SIZE								 '  Error Check Our y Value

	IFZ pHeightMap THEN RETURN 0							 '  Make Sure Our Data Is Valid

	'RETURN g_HeightMap [x + (y * MAP_SIZE)]
	RETURN UBYTEAT (pHeightMap + x + (y * MAP_SIZE))				 '  Index Into Our Height Array And Return The Height

END FUNCTION 
														
FUNCTION SetVertexColor (pHeightMap,  x,  y)		 '  Sets The Color Value For A Particular Index, Depending On The Height Index
	SINGLE fColor

	IFZ pHeightMap THEN RETURN 0								 '  Make Sure Our Height Data Is Valid

	fColor = SINGLE (-0.15) + (Height (pHeightMap, x, y ) / 256.0)

	 '  Assign This Blue Shade To The Current Vertex
	glColor3f(0, 0, fColor )
	
END FUNCTION 

FUNCTION RenderHeightMap (pHeightMap)					 '  This Renders The Height Map As Quads
	SHARED MAP_SIZE, STEP_SIZE
	SHARED bRender,mx,my
	XLONG x, y, z										 '  Create Some Variables For Readability
	XLONG X,Y
	SHARED map_list

	IFZ pHeightMap THEN RETURN 0							 '  Make Sure Our Height Data Is Valid

   IFZ map_list THEN
    
    '  Start recording displaylist
    map_list = glGenLists( 1 ) 
    glNewList( map_list, $$GL_COMPILE_AND_EXECUTE ) 


	X = 0
	Y = 0									 '  Create Some Variables To Walk The Array With.

	IF bRender=1 THEN										 '  What We Want To Render
		glBegin( $$GL_QUADS )							 '  Render Polygons
	ELSE 
		glBegin( $$GL_LINES )							 '  Render Lines Instead
	END IF
	

	FOR X = 0 TO MAP_SIZE-1 STEP STEP_SIZE
		FOR Y = 0 TO MAP_SIZE-1 STEP STEP_SIZE
		
			 '  Get The (X, Y, Z) Value For The Bottom Left Vertex
			x = X							
			y = Height(pHeightMap, X, Y )	
			z = Y							

			 '  Set The Color Value Of The Current Vertex
			SetVertexColor(pHeightMap, x, z)

			glVertex3i(x, y, z)						 '  Send This Vertex To OpenGL To Be Rendered (Integer Points Are Faster)

			 '  Get The (X, Y, Z) Value For The Top Left Vertex
			x = X										
			y = Height(pHeightMap, X, Y + STEP_SIZE )  
			z = Y + STEP_SIZE 							
			
			 '  Set The Color Value Of The Current Vertex
			SetVertexColor(pHeightMap, x, z)

			glVertex3i(x, y, z)						 '  Send This Vertex To OpenGL To Be Rendered

			 '  Get The (X, Y, Z) Value For The Top Right Vertex
			x = X + STEP_SIZE 
			y = Height(pHeightMap, X + STEP_SIZE, Y + STEP_SIZE ) 
			z = Y + STEP_SIZE 

			 '  Set The Color Value Of The Current Vertex
			SetVertexColor(pHeightMap, x, z)
			
			glVertex3i(x, y, z)						 '  Send This Vertex To OpenGL To Be Rendered

			 '  Get The (X, Y, Z) Value For The Bottom Right Vertex
			x = X + STEP_SIZE 
			y = Height(pHeightMap, X + STEP_SIZE, Y ) 
			z = Y

			 '  Set The Color Value Of The Current Vertex
			SetVertexColor(pHeightMap, x, z)

			glVertex3i(x, y, z)						 '  Send This Vertex To OpenGL To Be Rendered
		NEXT Y
	NEXT X
	glEnd()
	
    '  Stop recording displaylist
    glEndList() 
    
   ELSE
     '  Playback displaylist
     glCallList( map_list ) 
   END IF	
	

	glColor4f(1.0, 1.0, 1.0, 1.0)					 '  Reset The Color
	
END FUNCTION


FUNCTION Init()
	SHARED MAP_SIZE, STEP_SIZE
	SHARED SINGLE HEIGHT_RATIO, scaleValue
	SHARED bRender
	SHARED UBYTE g_HeightMap[]
	
	MAP_SIZE = 1024
	STEP_SIZE = 16
	HEIGHT_RATIO = 1.5
	scaleValue = 0.15
	bRender=1
	
	DIM g_HeightMap[MAP_SIZE * MAP_SIZE]
	
	
	glShadeModel( $$GL_SMOOTH)							 '  Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5)				 '  Black Background
	glClearDepth(1.0)									 '  Depth Buffer Setup
	glEnable( $$GL_DEPTH_TEST)							 '  Enables Depth Testing
	glDepthFunc( $$GL_LEQUAL)								 '  The Type Of Depth Testing To Do
	glHint( $$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)	 '  Really Nice Perspective Calculations


	LoadRawFile(&"Terrain.raw", MAP_SIZE * MAP_SIZE, &g_HeightMap[])
	'#texture = LoadGLTexture (&"xbsplash.tga")								 '  Load the texture
	
END FUNCTION 



FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height < 50) THEN #Height = 50

	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(45.0, SINGLE(#Width/#Height), 0.1, 500.0)
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

FUNCTION FillArray ( array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)

	
	SINGLEAT (array)= v1
	SINGLEAT (array+4)= v2
	SINGLEAT (array+8)= v3
	SINGLEAT (array+12)= v4

END FUNCTION

FUNCTION LoadRawFile( strName,  nSize, pHeightMap)		' Loads The .RAW File And Stores It In pHeightMap

	pFile = fopen( strName, &"rb" )			 '  Open The File In Read / Binary Mode.
	 
	IF ( pFile == $$NULL ) THEN 		 '  Check To See If We Found The File And Could Open It
		MessageBoxA ($$NULL, &"Can't Find The Height Map!", &"Error", $$MB_OK)	'  Display Error Message And Stop The Function
		RETURN
	END IF

	fread( pHeightMap, 1, nSize, pFile )
	result = ferror( pFile ) '  After We Read The Data, It's A Good Idea To Check If Everything Read Fine
	 
	IF (result) THEN		'  Check If We Received An Error
			MessageBoxA ($$NULL, &"Failed To Get Data!", &"Error", $$MB_OK)
	END IF

	 '  Close The File.
	fclose(pFile)
	
END FUNCTION

END PROGRAM
