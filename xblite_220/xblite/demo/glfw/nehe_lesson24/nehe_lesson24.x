 ' ========================================================================
 ' Based on NeHe example 24
 '
 ' XBLite\XBasic port by Michael McElligott 22/11/2002
 ' Mapei_@hotmail.com
 ' ========================================================================


IMPORT "glfw"
IMPORT "opengl32"


DECLARE FUNCTION Main ()
DECLARE FUNCTION LoadTGA (font$)
DECLARE FUNCTION BuildFont ()
DECLARE FUNCTION KillFont ()
DECLARE FUNCTION glPrint (x, y, set,  text)
DECLARE FUNCTION InitGL ()
DECLARE FUNCTION UpdateDisplay ()


FUNCTION Main ()
 SHARED oldheight,height,oldwidth,width


	'  Initialize GLFW
    IFZ glfwInit() THEN QUIT (0)

    '  Open OpenGL window
    IFZ glfwOpenWindow( 640, 480, 0,0,0,0, 32,0, $$GLFW_WINDOW )  THEN
        glfwTerminate()
        QUIT (0)
    END IF
    
    glfwSetWindowTitle( &"glFonts" )
    
	InitGL()
	glfwSwapInterval( 0 )
	glfwEnable( $$GLFW_STICKY_KEYS )
	event=1
	
	DO 
	
	    glfwGetWindowSize( &width, &height )
	    
	    IF ((width <> oldwidth) OR (height <> oldheight)) THEN
	    
	    		oldheight=height
	    		oldwidth=width

         		'  Set viewport
          		glViewport( 0, 0, width, height )
        		glMatrixMode($$GL_PROJECTION)							 '  Select The Projection Matrix
				glLoadIdentity()										 '  Reset The Projection Matrix
				glOrtho(0.0,640, 480,0.0,-1.0,1.0)					 '  Create Ortho 640x480 View (0,0 At Top Left)
				glMatrixMode($$GL_MODELVIEW)							 '  Select The Modelview Matrix
				glLoadIdentity()
        END IF
	
	
		UpdateDisplay ()

		IF (glfwGetKey($$GLFW_KEY_UP)=1) THEN
			#scroll=#scroll+2
			sleep=0
		END IF
		
		IF (glfwGetKey($$GLFW_KEY_DOWN)=1) THEN
			#scroll=#scroll-2
			IF #scroll<0 THEN #scroll=0
			sleep=0
		END IF
		
		
		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN event=0

		IF sleep THEN
			glfwSleep( 0.01 )
		ELSE
			sleep=1
		END IF
	
	LOOP WHILE (event=1)
	
	glDeleteTextures( 0, &#tex_id[] )
	
	KillFont ()
	glfwTerminate()
	
END FUNCTION


FUNCTION LoadTGA (font$)

	IFZ &font$ THEN RETURN $$FALSE
	' todo, check that file exists

	'  Texture names
    DIM #tex_name$[0]
    #tex_name$[0]=font$
    
    '  OpenGL texture object IDs
    DIM #tex_id[0]
    
    '  Generate texture objects
    glGenTextures(0, &#tex_id[])
    
    '  Select texture object
    glBindTexture( $$GL_TEXTURE_2D, #tex_id[0])

    '  Set texture parameters
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )

    '  Upload texture from file to texture memory
    glfwLoadTexture2D( &#tex_name$[0], 0 )
    
    RETURN $$TRUE
         
         
END FUNCTION
         
         
FUNCTION BuildFont ()
	SINGLE cx,cy

	#base = glGenLists(256)									 '  Creating 256 Display Lists
	glBindTexture($$GL_TEXTURE_2D, #tex_id[0])		 '  Select Our Font Texture
	FOR loop1 = 0 TO 255  ' (int loop1=0  loop1<256  loop1++)					 '  Loop Through All 256 Lists
	
		cx= SINGLE (loop1 MOD 16)/16.0						 '  X Position Of Current Character
		cy= SINGLE (loop1/16)/16.0							 '  Y Position Of Current Character

		glNewList(#base+loop1,$$GL_COMPILE)					 '  Start Building A List
			glBegin($$GL_QUADS) 								 '  Use A Quad For Each Character
				glTexCoord2f(cx,1.0 - cy - 0.0625) 			 '  Texture Coord (Bottom Left)
				glVertex2d(0,16) 							 '  Vertex Coord (Bottom Left)
				glTexCoord2f(cx + 0.0625,1.0 - cy -0.0625) 	 '  Texture Coord (Bottom Right)
				glVertex2i(16,16) 							 '  Vertex Coord (Bottom Right)
				glTexCoord2f(cx + 0.0625,1.0 - cy - 0.001) 	 '  Texture Coord (Top Right)
				glVertex2i(16,0) 							 '  Vertex Coord (Top Right)
				glTexCoord2f(cx,1.0 - cy - 0.001) 			 '  Texture Coord (Top Left)
				glVertex2i(0,0) 							 '  Vertex Coord (Top Left)
			glEnd() 										 '  Done Building Our Quad (Character)
			glTranslated(14,0,0) 							 '  Move To The Right Of The Character
		glEndList() 	
		
	NEXT loop1


END FUNCTION



FUNCTION KillFont()

	' delete font from memory
	glDeleteLists(#base,256)

END FUNCTION


FUNCTION glPrint(x, y, set,  text)

	glEnable($$GL_TEXTURE_2D)								 '  Enable Texture Mapping
	glLoadIdentity()										 '  Reset The Modelview Matrix
	glTranslated(x,y,0)									 '  Position The Text (0,0 - Top Left)
	glListBase(#base-32+(128*set))							 '  Choose The Font Set (0 or 1)

	glScalef(1.0,2.0,1.0)								 '  Make The Text 2X Taller

	text$=CSTRING$(text)
	len= LEN (text$)
	glCallLists(len,$$GL_UNSIGNED_BYTE, text)		 '  Write The Text To The Screen
	glDisable($$GL_TEXTURE_2D)

END FUNCTION



FUNCTION InitGL()											 '  All Setup For OpenGL Goes Here

	IFF LoadTGA ("Font.tga") THEN RETURN $$FALSE				 '  Load The Font Texture
	
	BuildFont()											 '  Build The Font

	glShadeModel($$GL_SMOOTH)								 '  Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5)					 '  Black Background
	glClearDepth(1.0)										 '  Depth Buffer Setup
	glBindTexture($$GL_TEXTURE_2D, #tex_id[0])		 '  Select Our Font Texture
	
END FUNCTION

FUNCTION UpdateDisplay ()
	SHARED width,height


	glClear($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)		 '  Clear Screen And Depth Buffer

	glColor3f(1.0,0.5,0.5)								 '  Set Color To Bright Red
	glPrint(50,16,1,&"Renderer")							 '  Display Renderer
	glPrint(80,48,1,&"Vendor")								 '  Display Vendor Name
	glPrint(66,80,1,&"Version")								 '  Display Version

	glColor3f(1.0,0.7,0.4)								 '  Set Color To Orange
	glPrint(200,16,1,glGetString($$GL_RENDERER))		 '  Display Renderer
	glPrint(200,48,1,glGetString($$GL_VENDOR))		 '  Display Vendor Name
	glPrint(200,80,1,glGetString($$GL_VERSION))		 '  Display Version
	
	
	glColor3f(0.5,0.5,1.0)							'  Set Color To Bright Blue
	glPrint(140,432,1,&"Based on NeHe Example 24")				'	 Write NeHe Productions At The Bottom Of The Screen
	
	glLoadIdentity()									 '  Reset The ModelView Matrix
	glColor3f(1.0,1.0,1.0)								 '  Set The Color To White
	glBegin($$GL_LINE_STRIP)							 '  Start Drawing Line Strips (Something New)
		glVertex2d(639,417)						 '  Top Right Of Bottom Box
		glVertex2d(  0,417)						 '  Top Left Of Bottom Box
		glVertex2d(  0,480)							'  Lower Left Of Bottom Box
		glVertex2d(639,480)							'  Lower Right Of Bottom Box
		glVertex2d(639,128)								 '  Up To Bottom Right Of Top Box
	glEnd()												 '  Done First Line Strip
	glBegin($$GL_LINE_STRIP)							 '  Start Drawing Another Line Strip
		glVertex2d(  0,128)								 '  Bottom Left Of Top Box
		glVertex2d(639,128)								 '  Bottom Right Of Top Box								
		glVertex2d(639,  1)								 '  Top Right Of Top Box
		glVertex2d(  0,  1)								 '  Top Left Of Top Box
		glVertex2d(  0,480)							 '  Down To Top Left Of Bottom Box
	glEnd()												 '  Done Second Line Strip


	glScissor(1	,(0.135416* height),width-2,(0.597916* height))	'  Define Scissor Region
	glEnable($$GL_SCISSOR_TEST)									'  Enable Scissor Testing
	
	glColor3f(0.5,1.0,0.5)
	ext$=CSTRING$(glGetString($$GL_EXTENSIONS))
	extlen= LEN (ext$)

	FOR line=1 TO extlen
		
		end=0
		token$=""
		
		DO   
			char=ext${token}
			IF char=32 THEN end=1
			token$=token$+CHR$(char)
			INC token		
	
		LOOP WHILE ((end=0) AND (token<extlen)) 
	
		glPrint(1,(96+(line*32))- #scroll ,0,&token$)
			
	NEXT line
			
	glDisable($$GL_SCISSOR_TEST)
	
	glFlush()
	glfwSwapBuffers()

END FUNCTION
