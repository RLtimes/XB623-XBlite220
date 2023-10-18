 ' ========================================================================
 ' Matrix Saver v. 1.01 - by Arrow and Gluck from G-D-E
 '		G-D-E.narod.ru
 '
 ' glfw\XBLite conversion by Michael McElligott 20/12/2002
 ' Mapei_@hotmail.com
 ' ========================================================================

' MAKEFILE "xexe.xxx"

'	IMPORT "xst"
	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "kernel32"
	IMPORT "msvcrt"


DECLARE FUNCTION Main ()
DECLARE FUNCTION Render()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION key (k,action)

DECLARE FUNCTION RenderScene()
DECLARE FUNCTION LoadTGA (font$)
DECLARE FUNCTION BuildFont ()
DECLARE FUNCTION KillFont ()
DECLARE FUNCTION glSetChar(ch)
DECLARE FUNCTION InitMatrix()


FUNCTION Main ()
	SHARED event

	Create ()
	Init()

	event=1
	DO
	
		Render()
		glfwSwapBuffers ()

		IFZ glfwGetWindowParam ($$GLFW_OPENED) THEN event = 0
		IF (#vsync = 1) THEN glfwSleep(0.01)

	LOOP WHILE event=1

	glfwTerminate()
	glDeleteTextures (#font_texture,1)
	KillFont()	
	
END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
    glfwInit()

    #Width = 1024
    #Height = 768
    #vsync = 1
    
    wtype = $$GLFW_FULLSCREEN
    'glfwOpenWindowHint   ( $$GLFW_REFRESH_RATE,85)    

    IFZ glfwOpenWindow (#Width,#Height, 0,0,0,0, 32,0, wtype) THEN
        glfwTerminate()
        QUIT (0)
    END IF

    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
    glfwSetWindowTitle( &"XBlite - The Matrix" )
		glfwEnable( $$GLFW_KEY_REPEAT )
    glfwSwapInterval(#vsync)

END FUNCTION

FUNCTION key (k,action)
	SHARED SINGLE fMove
	SHARED event, DTick


	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k

		CASE ' ' :
			fMove = 0: DTick = 0
			InitMatrix()
			
	    CASE 'V' :
			IF #vsync=1 THEN
				glfwSwapInterval( 0 )
				#vsync=0
			ELSE
				glfwSwapInterval( 1 )
				#vsync=1
			END IF
			
		CASE ELSE : event = 0		' end program

	END SELECT

END FUNCTION


FUNCTION Render()
	SHARED Tick1,Tick2,DTick
	SHARED UBYTE map[]
	SHARED XLONG nmap[],speedmap[]
	SHARED SINGLE brmap[]
	SHARED SINGLE fMove,rot,xpos
	STATIC UBYTE m,f
	
	
	Tick1 = Tick2
	Tick2 = GetTickCount ( )
	DTick = DTick + (Tick2 - Tick1)
	fMove = fMove - 0.005 * SINGLE (Tick2 - Tick1)
  '	DTick =DTick + 30
 ' 	fMove = fMove - 0.005 *SINGLE (30)
 ' 	rot = rot +0.05*SINGLE(Tick2 - Tick1)
  	
	IF (fMove < -200.0) THEN fMove = -120.0	
	IF (DTick>250) THEN
	
		DTick = DTick - 25
		FOR x = 0 TO 49
		
			INC speedmap[x,1]
			IF (speedmap[x,1]>speedmap[x,0]) THEN
				speedmap[x,1]= 0
				m = 1
			ELSE
				m = 0
			END IF
			
			FOR y = 0 TO 39
				
				IF (m) THEN
					map[x,y] = map[x,y+1]
					brmap[x,y] = brmap[x,y+1]
					nmap[x,y] = nmap[x,y+1]
				END IF
					
				brmap[x,y] = brmap[x,y]+ (SINGLE (nmap[x,y])* SINGLE (0.01))
				IF ((brmap[x,y] >  SINGLE (0.95)) || (brmap[x,y] <  SINGLE (0.05))) THEN
					nmap[x,y] = nmap[x,y]*(-1)
				END IF
					
			NEXT y
		NEXT x
		
		FOR x = 0 TO 49
			
			i = rand() MOD 1000
			IF (i<300) THEN
				
				map[x,40] = 0
				IF ((rand() MOD 10)<2)
					speedmap[x,0]= 1 + (rand() MOD 5)
				END IF
			
			ELSE
			
				IF ((i==300) && (x<40))	THEN
				
					f = (rand() MOD 5)-2
					brmap[x,40]=1.0
					nmap[x,40]=f
					map[x,40]='A'
					
					INC x
					brmap[x,40]=1.0
					nmap[x,40]=f
					map[x,40]='R'
					
					INC x
					brmap[x,40]=1.0
					nmap[x,40]=f
					map[x,40]='R'
					
					INC x
					brmap[x,40]=1.0
					nmap[x,40]=f
					map[x,40]='O'
					
					INC x
					brmap[x,40]=1.0
					nmap[x,40]=f
					map[x,40]='W'
				ELSE
					
					map[x,40]=rand() MOD 256
					brmap[x,40]= SINGLE (0.35) + SINGLE (rand() MOD 51)/ 100
					nmap[x,40]= (rand() MOD 5)-2
						
				END IF
			END IF
		NEXT x
	END IF
	
	RenderScene()

END FUNCTION


FUNCTION RenderScene()
	SHARED Tick1,Tick2
	SHARED DTick
	SHARED UBYTE map[]
	SHARED XLONG nmap[],speedmap[]
	SHARED SINGLE brmap[]
	SHARED SINGLE fMove,rot,xpos


	glClear( $$GL_COLOR_BUFFER_BIT )	 '  Clear The Screen And The Depth Buffer
	glLoadIdentity()
	glBindTexture( $$GL_TEXTURE_2D, #font_texture)
	glColor4f(0,0.5,0,0.75)
'  	glRotatef(rot,0,0,1)
	glTranslatef(-20,-20,-36+fMove)
	
	FOR y = 0 TO 39
		FOR x = 0 TO 49
		
			IF (brmap[x,y]<0.75) THEN
				glColor4f(0,0.5,0,brmap[x,y])
			ELSE
				glColor4f(brmap[x,y]/2,brmap[x,y],brmap[x,y]/2,0.75)
			END IF
			
			glSetChar(map[x,y])
			glTranslatef(0,0,40)
			glSetChar(map[x,y])
			glTranslatef(0,0,40)
			glSetChar(map[x,y])
			glTranslatef(0,0,40)
			glSetChar(map[x,y])
			glTranslatef(0,0,40)
			glSetChar(map[x,y])
			glTranslatef(0,0,40)
			glSetChar(map[x,y])
			glTranslatef(0.8,0,-200)
			
		NEXT x
		
		glTranslatef(-40,1,0)
		
	NEXT y
	
END FUNCTION


FUNCTION LoadTGA (font$)

	IFZ &font$ THEN RETURN $$FALSE

    #font_texture = 0
   
    '  Generate texture objects
    glGenTextures(1, &#font_texture)
    
    '  Select texture object
    glBindTexture( $$GL_TEXTURE_2D, #font_texture)

    '  Set texture parameters
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )

    '  Upload texture from file to texture memory
    glfwLoadTexture2D( &font$, $$GLFW_BUILD_MIPMAPS_BIT )
    
    RETURN $$TRUE
         
END FUNCTION
         
FUNCTION glSetChar(ch)
	glCallList(#base + ch)
END FUNCTION      
         
FUNCTION BuildFont ()
	SINGLE cx,cy

	#base = glGenLists(256)									 					'  Creating 256 Display Lists
	glBindTexture($$GL_TEXTURE_2D, #font_texture)			'  Select Our Font Texture
	FOR loop = 0 TO 255										 						'  Loop Through All 256 Lists
	
		cx = SINGLE (loop MOD 16)/16.0						 			'  X Position Of Current Character
		cy = SINGLE (loop /16)/16.0							 				'  Y Position Of Current Character

		glNewList(#base + loop,$$GL_COMPILE)				 		'  Start Building A List
			glBegin($$GL_TRIANGLE_STRIP) 					 				'  Use A Quad For Each Character
				glTexCoord2f(cx,1-cy-0.0625)
				glVertex3f(0,0,0)
				glTexCoord2f(cx+0.0625,1-cy-0.0625)
				glVertex3f(1,0,0)
				glTexCoord2f(cx,1-cy)
				glVertex3f(0,1,0)
				glTexCoord2f(cx+0.0625,1-cy)
				glVertex3f(1,1,0)
			glEnd() 										 									'  Done Building Our Quad (Character)
		glEndList() 	
		
	NEXT loop

END FUNCTION


FUNCTION KillFont()
	glDeleteLists(#base,256)		' delete font from memory
END FUNCTION

FUNCTION Init()
	SHARED UBYTE map[]
	SHARED XLONG nmap[],speedmap[]
	SHARED SINGLE brmap[]
	SHARED SINGLE fMove,rot,xpos


 	DIM map[50,41]
 	DIM brmap[50,41]
 	DIM nmap[50,41]
 	DIM speedmap[50,2]
 
 	fMove = 0
 	rot = 0
	xpos = 0

 ' 	glEnable( $$GL_DEPTH_TEST)
	glEnable( $$GL_TEXTURE_2D)
	glEnable( $$GL_BLEND)
	glBlendFunc( $$GL_SRC_ALPHA, $$GL_ONE)
 ' 	glShadeModel( $$GL_SMOOTH)
 ' 	glHint( $$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)
	glCullFace( $$GL_BACK)
	glEnable( $$GL_CULL_FACE)
	
	IFF LoadTGA ("Font.tga") THEN RETURN $$FALSE		 '  Load The Font Texture
	BuildFont()											 '  Build The Font	

	InitMatrix()
	
END FUNCTION 

FUNCTION InitMatrix()
	SHARED Tick1,Tick2
	SHARED UBYTE map[]
	SHARED XLONG nmap[],speedmap[]
	SHARED SINGLE brmap[]


	srand ( time( $$NULL ) )
	
	Tick1 = GetTickCount ( )
	Tick2 = Tick1	'GetTickCount ( )	

	FOR y = 0 TO 40
		FOR x = 0 TO 50
		
			i= rand() MOD 10
			IF (i<2) THEN
				map[x,y]=0
			ELSE
				map[x,y]=rand() MOD 256
			END IF
			
			brmap[x,y]=0 ' 0.35 + SINGLE (rand() MOD 51)/100
			nmap[x,y]=0 '(rand() MOD 5)-2
			speedmap[x,0]=1+rand() MOD 5
			speedmap[x,1]=0
			
		NEXT x
	NEXT y

END FUNCTION

FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height < 150) THEN #Height = 150
	IF (#Width < 200) THEN #Width = 200
	
	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(45.0, SINGLE(#Width/#Height), 1.0,150.0)
	glMatrixMode( $$GL_MODELVIEW)
	glLoadIdentity()	

END FUNCTION

END PROGRAM
