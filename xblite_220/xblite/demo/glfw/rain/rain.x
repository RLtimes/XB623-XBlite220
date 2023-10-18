 ' ========================================================================
 '                     OpenGL Water Rain Demo
 ' Author: Roman Podobedov
 ' Email: romka@ut.ee
 ' WEB: http://romka.demonews.com
 '
 ' XBLite\XBasic conversion by Michael McElligott 8/12/2002
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
DECLARE FUNCTION LoadGLTexture (file)
DECLARE FUNCTION FillArray (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)

DECLARE FUNCTION DrawModel ()
DECLARE FUNCTION ProcessWave ()
DECLARE FUNCTION DrawWave ()
DECLARE FUNCTION InvertWaveMap ()
DECLARE FUNCTION InitWave()
'DECLARE FUNCTION 

FUNCTION Main ()

	Create ()
	Init()

	event=1
	DO
	
		Render ()
		
		glfwSwapBuffers ()

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
    
    glfwSetWindowTitle( &"XBlite Water and Rain" )
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
	
		CASE ' ' :
			IF #freelook = 1 THEN #freelook = 0 ELSE #freelook = 1

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
	SHARED MAPY,MAPX,my,mx
	SHARED SINGLE wavemap[]
	
	glClear( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)
	
	glLoadIdentity()
	gluLookAt(250, 250, 250, 0, 0, 0, 0, 1, 0)
	
	IF #freelook = 1 THEN 
		glRotatef( SINGLE(mx-(#Width/ 2)), 0.0, 1.0, 0)			 '	Use Mouse to control
		glRotatef( SINGLE(my-(#Height/ 2)), 1.0, 0.0, 0)
	END IF
	
	glColor3f(1, 1, 1)
	
	DrawModel()

	IF ((rand() MOD 2) == 0) THEN
	
		wavemap[nmap,(rand() MOD (MAPY-2))+1,(rand() MOD (MAPX-2))+1] = 60
		wavemap[cmap,(rand() MOD (MAPY-2))+1,(rand() MOD (MAPX-2))+1] = 60
		
	END IF

	ProcessWave()
	glTranslatef(-128, 0, -128)
	DrawWave()
	InvertWaveMap()
	glLoadIdentity()

	RETURN $$TRUE										 '  Keep Going

END FUNCTION

FUNCTION InitWave()
	SHARED MAPY,MAPX
	SHARED SINGLE wavemap[]

	FOR i = 0 TO MAPY-1		'(int i=0 i<MAPY i++)
		FOR j = 0 TO MAPX-1		'(int j=0 j<MAPX j++)
			FOR k = 0 TO 1		'(int k=0 k<2 k++)
				wavemap[k,i,j] = 0
			NEXT k
		NEXT j
	NEXT i
	
END FUNCTION

FUNCTION ProcessWave()
	SHARED SINGLE damp,wavemap[]
	SHARED nmap,cmap,MAPX,MAPY
	SINGLE temp
	
	FOR i = 1 TO MAPY-2
		FOR j = 1 TO MAPX-2
		
			temp = ((wavemap[cmap,i-1,j] + wavemap[cmap,i+1,j] + wavemap[cmap,i,j-1] + wavemap[cmap,i,j + 1] + wavemap[cmap,i-1,j + 1] + wavemap[cmap,i+1,j + 1] + wavemap[cmap,i-1,j-1] + wavemap[cmap,i+1,j-1]) / 4) - wavemap[nmap,i,j]
			temp = temp - (temp / damp)
			 ' IF ((temp < 0.01) && (temp > -0.01)) temp = 0
			IF (temp < 0.01) THEN temp = 0
			wavemap[nmap,i,j] = temp
		NEXT j
	NEXT i
		
END FUNCTION

FUNCTION InvertWaveMap()
	SHARED cmap,nmap

	temp = cmap
	cmap = nmap
	nmap = temp
	
END FUNCTION


FUNCTION DrawWave()
	SHARED SINGLE wavemap[]
	SHARED MAPX,MAPY,cmap,nmap

	XLONG i, j

	glDisable( $$GL_TEXTURE_2D)	
	glColor4f(1, 1, 1, 0.1)
	glBegin( $$GL_TRIANGLES)
	
	FOR i = 0 TO MAPY-2		' (i=0 i<MAPY-1 i++)
	
		FOR j = 0 TO MAPX-2		' (j=0 j<MAPX-1 j++)
		
			glVertex3f(j * 2, wavemap[cmap,i,j], i * 2)
			glVertex3f((j + 1)* 2, wavemap[cmap,i + 1,j + 1], (i + 1)* 2)
			glVertex3f(j * 2, wavemap[cmap,i + 1,j], (i + 1) * 2)

			glVertex3f(j * 2, wavemap[cmap,i,j], i * 2)
			glVertex3f((j + 1) * 2, wavemap[cmap,i,j + 1], i * 2)
			glVertex3f((j + 1) * 2, wavemap[cmap,i + 1,j + 1], (i + 1)* 2)
			
		NEXT j
	NEXT i
	glEnd()
	glEnable( $$GL_TEXTURE_2D)	
	
END FUNCTION


FUNCTION DrawModel()
	SHARED SINGLE texture0, texture1
	STATIC model_list


	glDisable( $$GL_BLEND)
	glColor4f(1, 1, 1, 1)

	glBindTexture( $$GL_TEXTURE_2D, texture1)

    IFZ model_list THEN
    
         '  Start recording displaylist
    model_list = glGenLists( 1 ) 
    glNewList( model_list, $$GL_COMPILE ) 
    
	glBegin( $$GL_QUADS)	

	glTexCoord2f(0, 0) glVertex3f(128, 0, 256)
	glTexCoord2f(2, 0) glVertex3f(256, 0, 256)
	glTexCoord2f(2, 6) glVertex3f(256, 0, -256)
	glTexCoord2f(0, 6) glVertex3f(128, 0, -256)

	glTexCoord2f(0, 0) glVertex3f(-256, 0, 256)
	glTexCoord2f(2, 0) glVertex3f(-128, 0, 256)
	glTexCoord2f(2, 6) glVertex3f(-128, 0, -256)
	glTexCoord2f(0, 6) glVertex3f(-256, 0, -256)


	glTexCoord2f(0, 0) glVertex3f(-128, 0, 128)
	glTexCoord2f(0, 4) glVertex3f(-128, 0, 256)
	glTexCoord2f(4, 4) glVertex3f(128, 0, 256)
	glTexCoord2f(4, 0) glVertex3f(128, 0, 128)

	glTexCoord2f(0, 0) glVertex3f(-128, 0, -256)
	glTexCoord2f(0, 4) glVertex3f(-128, 0, -128)
	glTexCoord2f(4, 4) glVertex3f(128, 0, -128)
	glTexCoord2f(4, 0) glVertex3f(128, 0, -256)

	glEnd()	

	glBindTexture( $$GL_TEXTURE_2D, texture0)

	glBegin( $$GL_QUADS)	

	glTexCoord2f(0, 0) glVertex3f(-128, -64, -128)
	glTexCoord2f(4, 0) glVertex3f(-128, -64, 128)
	glTexCoord2f(4, 4) glVertex3f(128, -64, 128)
	glTexCoord2f(0, 4) glVertex3f(128, -64, -128)

	glTexCoord2f(0, 0) glVertex3f(128, -64, -128)
	glTexCoord2f(3, 0) glVertex3f(128, -64, 128)
	glTexCoord2f(3, 2) glVertex3f(128, 0, 128)
	glTexCoord2f(0, 2) glVertex3f(128, 0, -128)

	glTexCoord2f(0, 0) glVertex3f(-128, -64, 128)
	glTexCoord2f(4, 0) glVertex3f(-128, -64, -128)
	glTexCoord2f(4, 2) glVertex3f(-128, 0, -128)
	glTexCoord2f(0, 2) glVertex3f(-128, 0, 128)

	glTexCoord2f(0, 0) glVertex3f(-128, -64, -128)
	glTexCoord2f(4, 0) glVertex3f(128, -64, -128)
	glTexCoord2f(4, 2) glVertex3f(128, 0, -128)
	glTexCoord2f(0, 2) glVertex3f(-128, 0, -128)

	glTexCoord2f(0, 0) glVertex3f(128, -64, 128)
	glTexCoord2f(4, 0) glVertex3f(-128, -64, 128)
	glTexCoord2f(4, 2) glVertex3f(-128, 0, 128)
	glTexCoord2f(0, 2) glVertex3f(128, 0, 128)
	
	glEnd()
	glEnable( $$GL_BLEND)
	
         '  Stop recording displaylist
    glEndList() 
    
    ELSE
    	'  Playback displaylist
    glCallList( model_list ) 
    END IF	
	
	
END FUNCTION 

FUNCTION Init()
'	SHARED SINGLE light_ambient[],light_diffuse[],light_specular[],light_position[]
	SHARED SINGLE wavemap[],damp,texture0,texture1
	SHARED MAPX,MAPY,nmap,cmap	
	
	
	
	'DIM light_ambient[3]
	'DIM light_diffuse[3]
	'DIM light_specular[3]
	'DIM light_position[3]

 '  Light attributes
	'FillArray (&light_ambient[],0.8, 0.8, 0.8, 1.0)
	'FillArray (&light_diffuse[],0.8, 0.8, 0.8, 1.0)
	'FillArray (&light_specular[],0.8, 0.8, 0.8, 1.0)
	'FillArray (&light_position[],0.0, 100.0, 0.0, 1.0)

	MAPX = 129
	MAPY = 129

	DIM wavemap[2,MAPY,MAPX]
	damp = 500.0
	cmap = 0
	nmap = 1

	alpha = 0  '  Rotating angle


  		'  /* Textures */

	srand (985.464536)
	glClearColor(0, 0, 0, 1)

'	texture0 = LoadGLTexture(&"wall.tga")
	texture1 = LoadGLTexture(&"wood.tga")
	texture0 = texture1

	glEnable( $$GL_TEXTURE_2D)

	glDepthFunc( $$GL_LESS)
	glEnable( $$GL_DEPTH_TEST)

	glBlendFunc( $$GL_SRC_ALPHA, $$GL_ONE)
	glEnable( $$GL_BLEND)

	InitWave()

	
END FUNCTION 



FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height < 50) THEN #Height = 50
	IF (#Width < 50) THEN #Width = 50

	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(45.0, SINGLE(#Width/#Height), 10, 1000.0)
	'glFrustum(-7, 7, -5, 5, 10, 1000)
	glMatrixMode( $$GL_MODELVIEW)
	glLoadIdentity()
	
END FUNCTION


FUNCTION LoadGLTexture (file)


	' load and set texture type
	texture=0
	glGenTextures (1,&texture)
	
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


END PROGRAM
