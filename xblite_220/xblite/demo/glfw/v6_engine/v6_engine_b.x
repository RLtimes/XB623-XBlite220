 ' ========================================================================
 ' No credits contained in original C file.
 '
 ' XBLite\XBasic conversion by Michael McElligott 4/12/2002
 ' Mapei_@hotmail.com
 ' ========================================================================



	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "kernel32"
	IMPORT "msvcrt"
'	IMPORT "glut32"
	IMPORT "tga"

$$PI = 3.141592653589793238 '4626433832795028841971693993751058209749445923
'$$GL_SEPARATE_SPECULAR_COLOR_EXT   =   0x81FA
'$$GL_LIGHT_MODEL_COLOR_CONTROL_EXT  =  0x81F8

$$GL_REFLECTION_MAP_ARB = 0x8512
$$GL_TEXTURE_CUBE_MAP_ARB = 0x8513
$$GL_GENERATE_MIPMAP_SGIS = 0x8191
$$GL_TEXTURE_BASE_LEVEL_SGIS = 0x813C
$$GL_SEPARATE_SPECULAR_COLOR_EXT   =   0x81FA
$$GL_LIGHT_MODEL_COLOR_CONTROL_EXT  =  0x81F8

DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION FillArray (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)
DECLARE FUNCTION LoadGLTexture (file)

DECLARE FUNCTION DOUBLE COS (x)
DECLARE FUNCTION DOUBLE SIN (x)
DECLARE FUNCTION DOUBLE ACOS (x)
DECLARE FUNCTION CreateLists ()
DECLARE FUNCTION CalcNormal (SINGLE v0x, SINGLE v0y, SINGLE v0z, SINGLE v1x, SINGLE v1y, SINGLE v1z, SINGLE v2x, SINGLE v2y, SINGLE v2z)
DECLARE FUNCTION FlowControl ()
DECLARE FUNCTION Env ()
DECLARE FUNCTION Tex (texture)
DECLARE FUNCTION Lights (flag)

FUNCTION Main ()
	SHARED listbase

	Create ()
	Init()

	event=1
	DO
	
		FlowControl ()
		Render ()
		
		glfwSwapBuffers ()

		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN event=0
		
		IF (#vsync = 1) THEN glfwSleep(0.01)

	LOOP WHILE event=1

	glDeleteLists(listbase, 50)
	glfwTerminate()

END FUNCTION

FUNCTION FlowControl ()
	SHARED DOUBLE crankangle,camangle
	STATIC lastTickCount
	DOUBLE time
	SHARED DOUBLE speed
	
	tickCount = GetTickCount ()
	time = tickCount - lastTickCount
	
	crankangle	= DOUBLE (crankangle + ( time / DOUBLE (5.0)) *  speed)
	camangle	= DOUBLE (camangle + ( time / DOUBLE (2.5)) *  speed)
	
	lastTickCount = tickCount

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
    glfwInit()
    IFZ glfwOpenWindow(#Width,#Height, 0,0,0,0, 32,0, $$GLFW_WINDOW ) THEN 
        glfwTerminate()
        RETURN 0
    END IF
    
    glfwSetWindowTitle( &"V6 Engine")
    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
    glfwSetMousePosCallback (&MousePos() ) 
    glfwSwapInterval( 1 )
    
	glfwEnable( $$GLFW_KEY_REPEAT )
	#vsync = 1

END FUNCTION

FUNCTION key (k,action)
	SHARED DOUBLE speed
	SHARED nsections,listbase
	SHARED SINGLE zoom,XX,YY
	STATIC drawtype,drawcull

	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k
	
		CASE 'T' :
			glDisable($$GL_TEXTURE_2D)
			Lights ($$TRUE)

		CASE '1' : Tex (#texture1)
		CASE '2' : Tex (#texture2)
		CASE '3' : Tex (#texture3)                
		CASE '4' : Tex (#texture4)
		CASE '5' : Tex (#texture5)
		CASE 'E' : Env ()
		CASE '6' : 		
			glTexGeni($$GL_S, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
			glTexGeni($$GL_T, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)	
			glTexGeni($$GL_R, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
			
		CASE 'A' :
			speed = speed + 0.2
		CASE 'Z' : 
			speed = speed - 0.2
			
		CASE 'D' :
			zoom = zoom + 1
		CASE 'C' : 
			zoom = zoom - 1		
			
		CASE 'F' :
			XX = XX + 1
		CASE 'G' : 
			XX = XX - 1				

		CASE 'H' :
			YY = YY - 1
		CASE 'N' : 
			YY = YY + 1							
			
		CASE 'W' :
			IF drawtype = 0 THEN
				glPolygonMode( $$GL_FRONT_AND_BACK, $$GL_LINE )
				drawtype = 1
			ELSE
				glPolygonMode( $$GL_FRONT_AND_BACK, $$GL_FILL )
				drawtype = 0
			END IF
			
		CASE '0' :
			IF drawcull = 0 THEN
				glFrontFace( $$GL_CCW )
	  			glCullFace( $$GL_BACK )
    			glEnable( $$GL_CULL_FACE )
    			drawcull = 1
    		ELSE
    			glDisable( $$GL_CULL_FACE )
    			drawcull = 0
    		END IF
	
			
			
		CASE 'S' :
			nsections = nsections + 1
			glDeleteLists(listbase, 50)
			CreateLists ()
		CASE 'X' : 
			nsections = nsections - 1
			IF nsections < 1 THEN nsections = 1
			glDeleteLists(listbase, 50)
			CreateLists ()

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
	SHARED connrod, cranksectiona, cranksectionb, cranksection, crank
	SHARED piston, crankpulley, cam, campulley, lincamshaft, rincamshaft
	SHARED lexcamshaft, rexcamshaft, invalve, exvalve, plug, listbase
	SHARED SINGLE lightposition[],lightposition2[],lightposition3[]	
	SHARED DOUBLE crankangle,camangle
	STATIC SINGLE sine,cosine
	STATIC SINGLE x,y,z
	STATIC SINGLE xa,ya,za
	SHARED SINGLE angle, connrodangle,zoom,XX,YY
	SHARED nsections ,mx,my
	SINGLE result

	
	xa = 0.02: ya = 0.025: za = 0.03

	glClear ( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)		 '  Clear Screen And Depth Buffer
	glLoadIdentity ()											 '  Reset The Modelview Matrix
	
	 ' scene
	glLightfv( $$GL_LIGHT1, $$GL_POSITION, &lightposition[])
	glLightfv( $$GL_LIGHT2, $$GL_POSITION, &lightposition2[])
	glLightfv( $$GL_LIGHT3, $$GL_POSITION, &lightposition3[])
	
'	Env ()

	glTranslatef(XX, YY, zoom)

	IF #freelook = 1 THEN 
		glRotatef( SINGLE(mx-(#Width/ 2)), 0.0, 1.0, 0)			 '	Use Mouse to control
		glRotatef( SINGLE(my-(#Height/ 2)), 1.0, 0.0, 0)
	ELSE
		y = y + ya
		x = x + xa
		z = z + za	
		glRotatef(y, 0.0, 1.0, 0.0)
		glRotatef(x, 0.0, 0.0, 1.0)
		glRotatef(z, 1.0, 0.0, 0.0)
	END IF

	IF ((x < -20) ||( x > 20)) THEN xa = -xa
	IF ((z < -20) || (z > 20)) THEN za = -za

'	glTranslatef(0, 0, 6)
	glRotatef(45, 0, 0, 1)  '  'V' orientation
	


	 ' crankshaft
	glPushMatrix()
		glRotatef(-crankangle, 0.0, 0.0, 1.0)
		glCallList(listbase + crank)
	glPopMatrix()

	 ' left inlet cam & pulley
	glPushMatrix()
		glRotatef(-77, 0, 0, 1)
		glTranslatef(0, 13, 0)
		glRotatef(-camangle - 150, 0, 0, 1)
		glCallList(listbase + campulley)
		glCallList(listbase + lincamshaft)
	glPopMatrix()

	 ' left exhaust cam & pulley
	glPushMatrix()
		glRotatef(-103, 0, 0, 1)
		glTranslatef(0, 13, 0)
		glRotatef(-camangle + 90, 0, 0, 1)
		glCallList(listbase + campulley)
		glCallList(listbase + lexcamshaft)
	glPopMatrix()

	 ' right inlet cam & pulley
	glPushMatrix()
		glRotatef(-13, 0, 0, 1)
		glTranslatef(0, 13, 0)
		glRotatef(-camangle + 103, 0, 0, 1)
		glCallList(listbase + campulley)
		glCallList(listbase + rincamshaft)
	glPopMatrix()

	 ' right exhaust cam & pulley
	glPushMatrix()
		glRotatef(13, 0, 0, 1)
		glTranslatef(0, 13, 0)
		glRotatef(-camangle - 127, 0, 0, 1)
		glCallList(listbase + campulley)
		glCallList(listbase + rexcamshaft)
	glPopMatrix()

	FOR p = 0 TO nsections-1  ' (p = 0 p < 3 p++)
	
		glPushMatrix()

		 ' depth
		glTranslatef(0.0, 0.0, -6.0 * p)

		 ' right-bank info
		angle = crankangle - 120 * (p - 1) + 150
		sine =  SINGLE (SIN(angle))*  1.75  ' stroke = 1.75
		cosine =  SINGLE (COS(angle))* 1.75

		 ' conn. rod 1
		glPushMatrix()
			connrodangle =  SINGLE (ACOS(cosine / 6.0))
			glTranslatef(-cosine, sine, 0.0)
			glRotatef(connrodangle - 90.0, 0.0, 0.0, 1.0)
			glCallList(listbase + connrod)
		glPopMatrix()

		 ' piston 1
		glPushMatrix()
			glTranslatef(0, 7.25 + sine - (1.0 -  SINGLE (SIN(connrodangle)))* 6.0, -0.25)
			glCallList(listbase + piston)
		glPopMatrix()

		 ' spark plug 1
		glPushMatrix()
			glTranslatef(0.0, 10.9, -0.25)
			glCallList(listbase + plug)
		glPopMatrix()

		 ' right exhaust valve
		glPushMatrix()
			glRotatef(30, 0, 0, 1)
			angle = camangle + 140 - (p - 1) * 60 + (p MOD 2) * 180
			
			IF (XLONG (angle) MOD 360) <= 180 THEN result = SINGLE (SIN(angle))* 0.6 ELSE result = 0
						
			glTranslatef(3.85, 10.0 - result, -1.0)
			glCallList(listbase + exvalve)
			glTranslatef(0, 0, 1.5)
			glCallList(listbase + exvalve)
		glPopMatrix()

		 ' right inlet valve
		glPushMatrix()
			glRotatef(-30, 0, 0, 1)
			angle = camangle - p * 60 + 130 + (p MOD 2) * 180.0
			IF ((angle) MOD 360) <= 180 THEN result = SINGLE (SIN(angle))* 0.6 ELSE result = 0
			glTranslatef(-3.85, 10.0 - result, -1.2)
			glCallList(listbase + invalve)
			glTranslatef(0.0, 0.0, 1.9)
			glCallList(listbase + invalve)
		glPopMatrix()

		glRotatef(-90, 0, 0, 1)
		angle = crankangle - 120 * (p - 2) - 60
		sine =  SINGLE (SIN(angle))* 1.75  					' stroke = 1.75
		cosine =  SINGLE (COS(angle))* 1.75

		 ' conn. rod 2
		glPushMatrix()
			glTranslatef(0.0, 0.0, -1.01)
			connrodangle =  SINGLE (ACOS(cosine / 6.0))
			glTranslatef(-cosine, sine, 0)
			glRotatef(connrodangle - 90, 0, 0, 1)
			glCallList(listbase + connrod)
		glPopMatrix()

		 ' piston 2
		glPushMatrix()
			glTranslatef(0.0, 0.0, -1.01)
			glTranslatef(0.0, 7.25 + sine - (1.0 -  SINGLE (SIN(connrodangle))) * 6.0, -0.25)
			glCallList(listbase + piston)
		glPopMatrix()

		 ' spark plug 2
		glPushMatrix()
			glTranslatef(0.0, 10.9, -1.25)
			glCallList(listbase + plug)
		glPopMatrix()

		 ' left inlet valve
		glPushMatrix()
			glRotatef(30, 0, 0, 1)
			angle = camangle - p * 60 + 60 + (p MOD 2) * 180
			IF (XLONG (angle) MOD 360) <= 180 THEN result = SINGLE (SIN(angle))* 0.6 ELSE result = 0
			glTranslatef(3.85, 10.0 - result, -2.2)
			glCallList(listbase + invalve)
			glTranslatef(0.0, 0.0, 1.9)
			glCallList(listbase + invalve)
		glPopMatrix()

		 ' left exhaust valve
		glPushMatrix()
			glRotatef(-30, 0, 0, 1)
			angle = camangle + 80 - (p - 1) * 60 + (p MOD 2) * 180
			IF (XLONG (angle) MOD 360) <= 180 THEN result = SINGLE (SIN(angle))* 0.6 ELSE result = 0
			glTranslatef(-3.85, 10.0 - result, -2.0)
			glCallList(listbase + exvalve)
			glTranslatef(0, 0, 1.5)
			glCallList(listbase + exvalve)
		glPopMatrix()

		glPopMatrix()
	NEXT p

	glFlush ()													 '  Flush The GL Rendering Pipeline

	RETURN $$TRUE										 '  Keep Going

END FUNCTION



FUNCTION Init()
	SHARED connrod, cranksectiona, cranksectionb, cranksection, crank
	SHARED piston, crankpulley, cam, campulley, lincamshaft, rincamshaft
	SHARED lexcamshaft, rexcamshaft, invalve, exvalve, plug, listbase
	SHARED SINGLE lightposition[],lightposition2[],lightposition3[]	
	SHARED DOUBLE camangle, crankangle
	SHARED DOUBLE PIDIV180,speed
	SHARED nsections 
	SHARED SINGLE zoom,XX,YY
	
	
	nsections = 3
	PIDIV180 = $$PI / 180.0
	speed = 1.05
	camangle = 360.0: crankangle = 720.0
	zoom = -40
	XX = 0
	YY = -6

	connrod = 0
	cranksectiona = 1
	cranksectionb = 2
	cranksection = 3
	crank = 4
	piston = 5
	crankpulley = 6
	cam = 7
	campulley = 8
	lincamshaft = 9
	rincamshaft = 10
	lexcamshaft = 11
	rexcamshaft = 12
	invalve = 13
	exvalve = 14
	plug = 15

	#texture1 = LoadGLTexture (&"data/phong.tga")
	#texture2 = LoadGLTexture (&"data/64firery.tga")
	#texture3 = LoadGLTexture (&"data/testenv.tga")
	#texture4 = LoadGLTexture (&"data/proto_zzztblu2.tga")
	#texture5 = LoadGLTexture (&"data/tex1.tga")
	#Envmap = TGA_UploadCube(&"data/right.tga", &"data/left.tga", &"data/top.tga", &"data/bottom.tga", &"data/front.tga", &"data/back.tga")

	DIM lightposition[3]
	DIM lightposition2[3]
	DIM lightposition3[3]
	DIM lightambient[3]
	DIM lightambient2[3]
	DIM lightambient3[3]
	DIM lightdiffuse[3]
	DIM lightdiffuse2[3]
	DIM lightdiffuse3[3]
	DIM lightspecular[3]
	DIM lightspecular2[3]
	DIM lightspecular3[3]
'	DIM lightoff[3]
	DIM t[3]
	
	FillArray (&lightposition[]	,10, 15, -10, 1)						 ' 4th parameter: 0 = directional, 1 = positional
	FillArray (&lightposition2[],0, 15, 0, 1)						 ' 4th parameter: 0 = directional, 1 = positional
	FillArray (&lightposition3[],-10, 15, -10, 1)					 ' 4th parameter: 0 = directional, 1 = positional
	FillArray (&lightambient[]	,0.5, 0.5, 0.5, 1.0)
	FillArray (&lightambient2[]	,0.0, 0.0, 0.0, 1.0)
	FillArray (&lightambient3[]	,0, 0, 0, 1)
	FillArray (&lightdiffuse[]	,0.5, 0.5, 0.5, 1)
	FillArray (&lightdiffuse2[]	,0, 0, 0, 1)
	FillArray (&lightdiffuse3[]	,0, 0, 0, 1)
	FillArray (&lightspecular[]	,1, 0, 0, 1)
	FillArray (&lightspecular2[],0, 1, 0, 1)
	FillArray (&lightspecular3[],0, 0, 1, 1)
'	FillArray (&lightoff[]		,0, 0, 0, 1)
	FillArray (&t[]			,1, 1, 1, 1)


	'glClearColor (0.0, 0.0, 0.0, 0.99)						 '  Black Background
	glClearColor(0x3A / 255.0, 0x6E / 255.0, 0xA5 / 255.0, 1)
	glClearDepth (1.0)										 '  Depth Buffer Setup
	glDepthFunc ( $$GL_LEQUAL)									 '  The Type O Depth Testing (Less Or Equal)
	glEnable ( $$GL_DEPTH_TEST)									 '  Enable Depth Testing
	glDepthMask( $$GL_TRUE  )
	'glEnable($$GL_BLEND)									 '  Enable Blending
	'glBlendFunc($$GL_SRC_ALPHA, $$GL_ONE)					 '  Type Of Blending To Perform
	
	glShadeModel ( $$GL_SMOOTH)									 '  Select Smooth Shading
	glHint ( $$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)			 '  Set Perspective Calculations To Most Accurate
	glHint($$GL_POINT_SMOOTH_HINT, $$GL_NICEST)				 '  Really Nice Point Smoothing
	
	glLightModelf( $$GL_LIGHT_MODEL_AMBIENT, $$GL_TRUE)
	glMaterialfv( $$GL_FRONT, $$GL_SPECULAR, &t[])
	glMateriali( $$GL_FRONT, $$GL_SHININESS, 32)
	
	glColorMaterial( $$GL_FRONT, $$GL_DIFFUSE)

	glLightfv( $$GL_LIGHT1, $$GL_AMBIENT, &lightambient[])
	glLightfv( $$GL_LIGHT2, $$GL_AMBIENT, &lightambient2[])
	glLightfv( $$GL_LIGHT3, $$GL_AMBIENT, &lightambient3[])
	glLightfv( $$GL_LIGHT1, $$GL_DIFFUSE, &lightdiffuse[])
	glLightfv( $$GL_LIGHT2, $$GL_DIFFUSE, &lightdiffuse2[])
	glLightfv( $$GL_LIGHT3, $$GL_DIFFUSE, &lightdiffuse3[])
	glLightfv( $$GL_LIGHT1, $$GL_SPECULAR, &lightspecular[])
	glLightfv( $$GL_LIGHT2, $$GL_SPECULAR, &lightspecular2[])
	glLightfv( $$GL_LIGHT3, $$GL_SPECULAR, &lightspecular3[])
	glLightfv( $$GL_LIGHT1, $$GL_POSITION, &lightposition[])
	glLightfv( $$GL_LIGHT2, $$GL_POSITION, &lightposition2[])
	glLightfv( $$GL_LIGHT3, $$GL_POSITION, &lightposition3[])

	glEnable( $$GL_LIGHTING)
	glEnable( $$GL_NORMALIZE)
	glEnable( $$GL_LIGHT1)
	glEnable( $$GL_LIGHT2)
	glEnable( $$GL_LIGHT3)
	glEnable( $$GL_DEPTH_TEST)
	glEnable( $$GL_COLOR_MATERIAL)
	glLightModeli( $$GL_LIGHT_MODEL_COLOR_CONTROL_EXT, $$GL_SEPARATE_SPECULAR_COLOR_EXT )
	
  IF test = 1 THEN	
	DIM fogColor![3]
	FillArray (&fogColor![],0.7, 0.7, 0.7, 1)
	glFogi($$GL_FOG_MODE, $$GL_EXP2)
	glFogfv($$GL_FOG_COLOR, &fogColor![])
	glFogf($$GL_FOG_DENSITY, 0.04)
	glHint($$GL_FOG_HINT, $$GL_DONT_CARE)
	glFogf($$GL_FOG_START, 0.04)
	glFogf($$GL_FOG_END, 0.02)
  	glEnable($$GL_FOG)
  END IF


	CreateLists()
					
	
END FUNCTION

FUNCTION Lights (flag)

	IF flag = $$TRUE THEN
		glEnable($$GL_LIGHTING)
		glEnable( $$GL_LIGHT1)
		glEnable( $$GL_LIGHT2)
		glEnable( $$GL_LIGHT3)
	ELSE
		glDisable($$GL_LIGHTING)
		glDisable( $$GL_LIGHT1)
		glDisable( $$GL_LIGHT2)
		glDisable( $$GL_LIGHT3)	
	END IF
	
END FUNCTION


FUNCTION Tex (texture)

	glEnable($$GL_TEXTURE_2D)
	glEnable($$GL_DEPTH_TEST)
	Lights ($$FALSE)
					
	glBindTexture($$GL_TEXTURE_2D, texture)
	glTexEnvf($$GL_TEXTURE_ENV, $$GL_TEXTURE_ENV_MODE, $$GL_DECAL)
	glTexGeni($$GL_S, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
	glTexGeni($$GL_T, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)
	glEnable($$GL_TEXTURE_GEN_S)
	glEnable($$GL_TEXTURE_GEN_T)  
	glDisable( $$GL_TEXTURE_CUBE_MAP_ARB) 
                
END FUNCTION 
                

FUNCTION Env ()		'cube map
	

	Lights ($$FALSE)
	
	glTexEnvf( $$GL_TEXTURE_ENV, $$GL_TEXTURE_ENV_MODE, $$GL_DECAL)
	glTexGeni( $$GL_S,  $$GL_TEXTURE_GEN_MODE,  $$GL_REFLECTION_MAP_ARB)
	glTexGeni( $$GL_T,  $$GL_TEXTURE_GEN_MODE,  $$GL_REFLECTION_MAP_ARB)
	glTexGeni( $$GL_R,  $$GL_TEXTURE_GEN_MODE,  $$GL_REFLECTION_MAP_ARB)
	glEnable( $$GL_TEXTURE_GEN_S)
	glEnable( $$GL_TEXTURE_GEN_T)
	glEnable( $$GL_TEXTURE_GEN_R)
	glBindTexture( $$GL_TEXTURE_CUBE_MAP_ARB, #Envmap)
	glDisable( $$GL_TEXTURE_2D)
	glEnable( $$GL_TEXTURE_CUBE_MAP_ARB)
	


END FUNCTION


FUNCTION CalcNormal (SINGLE v0x, SINGLE v0y, SINGLE v0z, SINGLE v1x, SINGLE v1y, SINGLE v1z, SINGLE v2x, SINGLE v2y, SINGLE v2z)
	SHARED SINGLE normalx,normalz,normaly
	SINGLE qx, qy, qz, px, py, pz

	qx = v1x - v0x
	qy = v1y - v0y
	qz = v1z - v0z
	px = v2x - v0x
	py = v2y - v0y
	pz = v2z - v0z

	normalx = py * qz - pz * qy
	normaly = pz * qx - px * qz
	normalz = px * qy - py * qx
	
END FUNCTION 


FUNCTION CreateLists ()
	SHARED connrod, cranksectiona, cranksectionb, cranksection, crank
	SHARED piston, crankpulley, cam, campulley, lincamshaft, rincamshaft
	SHARED lexcamshaft, rexcamshaft, invalve, exvalve, plug
	SHARED SINGLE normalx,normalz,normaly
	SINGLE x0, x1, x2, y0, y1, y2, z0, z1, z2
	SHARED listbase
	DOUBLE hyp
	SINGLE sine, cosine, a, result
	SHARED nsections
	
	
	listbase = glGenLists(50)
	
	cylinder = gluNewQuadric()  ' bigend cylinder
	gluQuadricNormals(cylinder, $$GLU_SMOOTH)
	gluQuadricDrawStyle(cylinder, $$GLU_FILL)

	disk = gluNewQuadric()
	gluQuadricNormals(disk, $$GLU_SMOOTH)
	gluQuadricDrawStyle(disk, $$GLU_FILL)

	 ' conn. rod
	hyp = sqrt(pow(0.5, 2) + pow(6, 2))
	sine = 0.5 /  SINGLE (hyp)
	cosine = 5.0 /  SINGLE (hyp)

	glNewList(listbase + connrod, $$GL_COMPILE)
	
	glColor3f(0, 1, 0)

	glBegin( $$GL_QUADS)  ' front face
		glNormal3f(0, 0, 1)
		glVertex3f(-1, 0, 0)
		glVertex3f(-0.5, 6, 0)
		glVertex3f(0.5, 6, 0)
		glVertex3f(1, 0, 0)
	glEnd()

	glBegin( $$GL_QUADS)  ' rear face
		glNormal3f(0, 0, -1)
		glVertex3f(1, 0, -0.5)
		glVertex3f(0.5, 6, -0.5)
		glVertex3f(-0.5, 6, -0.5)
		glVertex3f(-1, 0, -0.5)
	glEnd()

    glBegin( $$GL_QUADS)  ' left side
      glNormal3f(-cosine, sine, 0)
      glVertex3f(-1, 0, -0.5)
      glVertex3f(-0.5, 6, -0.5)
      glVertex3f(-0.5, 6, 0)
      glVertex3f(-1, 0, 0)
    glEnd()

    glBegin( $$GL_QUADS)  ' right side
      glNormal3f(cosine, sine, 0)
      glVertex3f(1, 0, 0)
      glVertex3f(0.5, 6, 0)
      glVertex3f(0.5, 6, -0.5)
      glVertex3f(1, 0, -0.5)
    glEnd()

    glPushMatrix()  ' bigend
      glTranslatef(0, 0, -0.75)
      gluCylinder(cylinder, 1, 1, 1, 16, 1)
    glPopMatrix()

    glPushMatrix()  ' littleend
      glTranslatef(0, 6, -1.25)
      gluCylinder(cylinder, 0.5, 0.5, 2, 12, 1)
    glPopMatrix()
	glEndList()

	 ' crank section
	glNewList(listbase + cranksectiona, $$GL_COMPILE)  ' end plate
	
		glColor3f(1, 1, 0)
		glBegin( $$GL_POLYGON)  ' counter weight
			glNormal3f(0, 0, 1)
			FOR a = 0 TO 180 STEP 10 ' (SINGLE a = 0 a <= 180 a += 10)
				glVertex3f( SINGLE (COS(a)) * 2.5,  SINGLE (SIN(a)) * 2.5, 0.0)
			NEXT a

			glVertex3f(0, 0, 0)
		glEnd()

		glBegin( $$GL_QUADS)
			glNormal3f(0, 0, 1)
			glVertex3f(-1.25, 0, 0)
			glVertex3f(-1.25, -1.75, 0)
			glVertex3f(1.25, -1.75, 0)
			glVertex3f(1.25, 0, 0)
		glEnd()

	    glBegin( $$GL_POLYGON)  ' counter weight
			glNormal3f(0, 0, 1)
			FOR a = 0 TO 180 STEP 10 ' (a = 0 a <= 180 a += 10)
				glVertex3f( SINGLE (COS(a)) * 1.25, - SINGLE (SIN(a)) * 1.25 - 1.75, 0.0)
			NEXT a

			glVertex3f(-1.25, -1.75, 0)
		glEnd()
	glEndList()

	glNewList(listbase + cranksectionb, $$GL_COMPILE)
		glPushMatrix()
			glCallList(listbase + 1)
			glTranslatef(0, 0, -.5)
			glRotatef(180, 0, 1, 0)
			glCallList(listbase + 1)
		glPopMatrix()

		glPushMatrix()
			glTranslatef(0, -1.75, -.5)
			gluCylinder(cylinder, 1.25, 1.25, 0.5, 20, 1)
		glPopMatrix()

		glBegin( $$GL_QUADS)
			glNormal3f(-1, 0, 0)
			glVertex3f(-1.25, -1.75, 0)
			glVertex3f(-1.25, -1.75, -.5)
			glVertex3f(-1.25, 0, -0.5)
			glVertex3f(-1.25, 0, 0)

			glNormal3f(0, -1, 0)
			glVertex3f(-1.25, 0, 0)
			glVertex3f(-2.5, 0, 0)
			glVertex3f(-2.5, 0, -0.5)
			glVertex3f(-1.25, 0, -.5)

			glNormal3f(1, 0, 0)
			glVertex3f(1.25, -1.75, 0)
			glVertex3f(1.25, -1.75, -.5)
			glVertex3f(1.25, 0, -0.5)
			glVertex3f(1.25, 0, 0)

			glNormal3f(0, -1, 0)
			glVertex3f(1.25, 0, 0)
			glVertex3f(2.5, 0, 0)
			glVertex3f(2.5, 0, -0.5)
			glVertex3f(1.25, 0, -.5)

			FOR a = 0 TO 179 STEP 10 ' (a = 0 a < 180 a += 10)
			
				glNormal3f( SINGLE (COS(a)),			 SINGLE (SIN(a)),			 0.0)
				glVertex3f( SINGLE (COS(a))* 2.5,		 SINGLE (SIN(a))*2.5,		 0.0)
				glVertex3f( SINGLE (COS(a+10))*2.5,	 SINGLE (SIN(a+10))*2.5,	 0.0)
				glVertex3f( SINGLE (COS(a+10))*2.5,	 SINGLE (SIN(a+10))*2.5,	-0.5)
				glVertex3f( SINGLE (COS(a))*2.5,		 SINGLE (SIN(a))*2.5,		-0.5)
			NEXT a
		glEnd()
	glEndList()

	glNewList(listbase + cranksection, $$GL_COMPILE)  ' end plates
		glPushMatrix()
			glTranslatef(0, 0, 0.75)
			glCallList(listbase + 2)
			glTranslatef(0, 0, -2.5)
			glCallList(listbase + 2)
			glTranslatef(0, 0, 2.5)
			gluCylinder(cylinder, 1, 1, 3, 16, 1)
		glPopMatrix()
	glEndList()

	 ' crank
	glNewList(listbase + crank, $$GL_COMPILE)
	
		glColor3f(1, 1, 0)
		FOR a = 0 TO nsections-1 ' (a = 0 a < 3 a++)
		
			glPushMatrix()
				glTranslatef(0, 0, -6 * a)
				glRotatef(a * 120, 0, 0, 1)
				glCallList(listbase + cranksection)

				IF (a == 0)	THEN										 ' crank pulley
					glCallList(listbase + crankpulley)
				END IF

				IF (a == nsections-1)	THEN									 ' crank end				
					glTranslatef(0, 0, -3)
					gluCylinder(cylinder, 1, 1, 0.75, 16, 1)
					glRotatef(180, 0, 1, 0)
					gluDisk(disk, 0, 1, 16, 1)
				END IF
			glPopMatrix()
		NEXT a
	glEndList()

	 ' piston
	glNewList(listbase + piston, $$GL_COMPILE)
	
		glColor3f(1, 0, 0)
		glPushMatrix()
			glRotatef(90, 1, 0, 0)
			gluCylinder(cylinder, 2.5, 2.5, 2.5, 30, 1)
			glRotatef(180, 0, 1, 0)
			gluDisk(disk, 0, 2.5, 30, 1)
		glPopMatrix()
	glEndList()

	 ' crank pulley
	glNewList(listbase + crankpulley, $$GL_COMPILE)
		
		glColor3f(1, 1, 1)
	    glPushMatrix()
			glTranslatef(0, 0, 3.75)
			glRotatef(180, 0, 1, 0)
			gluDisk(disk, 0, 1.25, 16, 1)
			glTranslatef(0, 0, -1)
			gluCylinder(cylinder, 1.25, 1.25, 1, 16, 1)
			glRotatef(180, 0, 1, 0)
			gluDisk(disk, 0, 1.25, 16, 1)
		glPopMatrix()
	glEndList()

	 ' cam
	glNewList(listbase + cam, $$GL_COMPILE)
	
		glColor3f(0, 1, 1)
		glPushMatrix()
			glBegin( $$GL_POLYGON)  ' front face
				glNormal3f(0, 0, 1)
				FOR a = 0 TO 360 'STEP 10 ' (a = 0 a <= 360 a += 10)
					IF  a > 180 THEN result = 1.2 ELSE result = 0.6
					glVertex3f( SINGLE (COS(a))*0.6, -(SINGLE (SIN(a) * result)), 0.0)
				NEXT a
			glEnd()

			glBegin( $$GL_POLYGON)  ' rear face
				glNormal3f(0, 0, -1)
				FOR a = 0 TO 360 'STEP 10 ' (a = 0 a <= 360 a += 10)
					IF  a > 180 THEN result = 1.2 ELSE result = 0.6
					glVertex3f( SINGLE (COS(a))*0.6, -(SINGLE (SIN(a)*result)), -0.4)
				NEXT a
			glEnd()


			glBegin( $$GL_QUADS)
				FOR a = 0 TO 359 STEP 10 ' (a = 0 a < 360 a += 10)
				
					x0 =  SINGLE (COS(a)) * 0.6
					IF a >= 180 THEN result = -1.2 ELSE result = -0.6
					y0 =  SINGLE (SIN(a))*(result)
					z0 = 0

					x1 =  SINGLE (COS(a+10)) * 0.6
					IF a >= 180 THEN result = -1.2 ELSE result = -0.6
					y1 =  SINGLE (SIN(a+10))*result
					z1 = 0

					x2 = x1
					y2 = y1
					z2 = -0.4

					CalcNormal(x0, y0, z0, x1, y1, z1, x2, y2, z2)
					glNormal3f(-normalx, -normaly, -normalz)
					glVertex3f(x0, y0, z0)
					glVertex3f(x1, y1, z1)
					glVertex3f(x2, y2, z2)
					glVertex3f(x0, y0, -0.4)
				NEXT a
			glEnd()
		glPopMatrix()
	glEndList()

	 ' camshaft pulley
	glNewList(listbase + campulley, $$GL_COMPILE)
	
		glColor3f(1, 1, 1)
		glPushMatrix()
			glTranslatef(0, 0, 3.75)

			gluCylinder(cylinder, 2.5, 2.5, 1, 30, 1)
			glTranslatef(0.0, 0.0, 0.8)

			gluDisk(disk, 0.0, 2.49, 30, 1)
			glTranslatef(0.0, 0.0, -0.6)
			glRotatef(180.0, 0.0, 1.0, 0.0)

			gluDisk(disk, 0, 2.49, 30, 1)
		glPopMatrix()
	glEndList()

	 ' left inlet camshaft
	glNewList(listbase + lincamshaft, $$GL_COMPILE)
		glColor3f(1, 0, 1)
		glPushMatrix()
			glTranslatef(0, 0, -3.25 - (nsections - 1)  * 6)

			gluCylinder(cylinder, 0.5, 0.5, 6 *  nsections  + 1.2, 20, 1)  ' shaft
			glRotatef(180, 0, 1, 0)
			gluDisk(disk, 0, 0.5, 25, 1)  ' shaft end
		glPopMatrix()

		FOR a = 0 TO nsections-1 '(a = 0 a < 3 a++)
		
			glPushMatrix()
				glTranslatef(0, 0, -6 * a - 2)
				glRotatef(a * 60 + (XLONG (a) MOD 2) * 180, 0, 0, 1)
				glCallList(listbase + cam)
				glTranslatef(0.0, 0.0, 1.9)
				glCallList(listbase + cam)
			glPopMatrix()
		NEXT a
	glEndList()

	 ' right inlet camshaft
	glNewList(listbase + rincamshaft, $$GL_COMPILE)
	
		glColor3f(1, 0, 1)
		glPushMatrix()
			glTranslatef(0, 0, -3.25 - ( nsections -1) * 6)

			gluCylinder(cylinder, 0.5, 0.5, 6 *  nsections  + 1.2, 20, 1)  ' shaft
			glRotatef(180, 0, 1, 0)
			gluDisk(disk, 0, 0.5, 25, 1)  ' shaft end
		glPopMatrix()

		FOR a = 0 TO nsections-1 '(a = 0 a < 3 a++)
		
			glPushMatrix()
				glTranslatef(0, 0, -6 * a - 1)
				glRotatef(a * 60 + (XLONG (a) MOD 2) * 180, 0, 0, 1)
				glCallList(listbase + cam)
				glTranslatef(0.0, 0.0, 1.9)
				glCallList(listbase + cam)
			glPopMatrix()
		NEXT a
	glEndList()

	 ' left exhaust camshaft
	glNewList(listbase + lexcamshaft, $$GL_COMPILE)
	
		glColor3f(1, 0, 1)
		glPushMatrix()
			glTranslatef(0, 0, -3.25 - ( nsections -1) * 6)

			gluCylinder(cylinder, 0.5, 0.5, 6 *  nsections  + 1.2, 20, 1)  ' shaft
			glRotatef(180, 0, 1, 0)
			gluDisk(disk, 0, 0.5, 25, 1)  ' shaft end
		glPopMatrix()

		FOR a = 0 TO nsections -1 '(a = 0 a < 3 a++)
		
			glPushMatrix()
				glTranslatef(0.0, 0.0, -6.0 * a - 1.8)
				glRotatef(a * 60 + (XLONG(a) MOD 2) * 180, 0, 0, 1)
				glCallList(listbase + cam)
				glTranslatef(0, 0, 1.5)
				glCallList(listbase + cam)
			glPopMatrix()
		NEXT a
	glEndList()

	 ' right exhaust camshaft
	glNewList(listbase + rexcamshaft, $$GL_COMPILE)
	
		glColor3f(1, 0, 1)
		glPushMatrix()
			glTranslatef(0, 0, -3.25 - ( nsections -1) * 6)
			gluCylinder(cylinder, 0.5, 0.5, 6 *  nsections  + 1.2, 20, 1)  ' shaft
			glRotatef(180, 0, 1, 0)
			gluDisk(disk, 0, 0.5, 25, 1)  ' shaft end
		glPopMatrix()

		FOR a = 0 TO nsections -1 '(a = 0 a < 3 a++)
		
			glPushMatrix()
				glTranslatef(0.0, 0.0, -6.0 * a - 0.8)
				glRotatef(a * 60 + 193 + (XLONG (a) MOD 2) * 180, 0, 0, 1)
				glCallList(listbase + cam)
				glTranslatef(0, 0, 1.5)
				glCallList(listbase + cam)
			glPopMatrix()
		NEXT a
	glEndList()

	 ' exhaust valve
	glNewList(listbase + exvalve, $$GL_COMPILE)
	
		glColor3f(0, 0, 1)
		glPushMatrix()
			glRotatef(-90, 1, 0, 0)
			glBegin( $$GL_TRIANGLE_FAN)
				FOR a = 0 TO 360 STEP 15 ' (a = 0 a <= 360 a += 15)
				
					x0 = 0
					y0 = 0
					z0 = 0

					x1 =  SINGLE (COS(a)) * 0.7
					y1 =  SINGLE (SIN(a)) * 0.7
					z1 = -0.2

					x2 =  SINGLE (COS(a+15)) * 0.7
					y2 =  SINGLE (SIN(a+15)) * 0.7
					z2 = -0.2

					CalcNormal(x0, y0, z0, x1, y1, z1, x2, y2, z2)
					glNormal3f(-normalx, -normaly, -normalz)
					glVertex3f(x0, y0, z0)
					glVertex3f(x1, y1, z1)
					glVertex3f(x2, y2, z2)
				NEXT a
			glEnd()

			glPushMatrix()
				glTranslatef(0.0, 0.0, -0.2)
				glRotatef(180.0, 1.0, 0.0, 0.0)
				gluDisk(disk, 0, 0.695, 24, 1)  ' valve base
			glPopMatrix()

			glPushMatrix()
				glTranslatef(0.0, 0.0, -0.05)
				gluCylinder(cylinder, 0.1, 0.1, 1.5, 10, 1)  ' valve stem
			glPopMatrix()

			glPushMatrix()
				glTranslatef(0.0, 0.0, 1.3)
				gluCylinder(cylinder, 0.3, 0.3, 0.5, 16, 1)  ' follower
				glTranslatef(0.0, 0.0, 0.5)
				gluDisk(disk, 0, 0.3, 16, 1)  ' follower end-cap
			glPopMatrix()
		glPopMatrix()
	glEndList()

	 ' inlet valve
	glNewList(listbase + invalve, $$GL_COMPILE)
	
		glColor3f(0, 0, 1)
		glPushMatrix()
			glRotatef(-90, 1, 0, 0)
			glBegin( $$GL_TRIANGLE_FAN)
				FOR a = 0 TO 360 STEP 10 ' (a = 0 a <= 360 a += 10)
				
					x0 = 0
					y0 = 0
					z0 = 0

					x1 =  SINGLE (COS(a)) * 0.9
					y1 =  SINGLE (SIN(a)) * 0.9
					z1 = -0.2

					x2 =  SINGLE (COS(a+10)) * 0.9
					y2 =  SINGLE (SIN(a+10)) * 0.9
					z2 = -0.2

					CalcNormal(x0, y0, z0, x1, y1, z1, x2, y2, z2)
					glNormal3f(-normalx, -normaly, -normalz)
					glVertex3f(x0, y0, z0)
					glVertex3f(x1, y1, z1)
					glVertex3f(x2, y2, z2)
				NEXT a
			glEnd()

			glPushMatrix()
				glTranslatef(0.0, 0.0, -0.2)
				glRotatef(180.0, 1, 0.0, 0.0)
				gluDisk(disk, 0.0, 0.895, 36, 1)  ' valve base
			glPopMatrix()

			glPushMatrix()
				glTranslatef(0.0, 0.0, -0.05)
				gluCylinder(cylinder, 0.1, 0.1, 1.5, 10, 1)  ' valve stem
			glPopMatrix()

			glPushMatrix()
				glTranslatef(0.0, 0.0, 1.3)
				gluCylinder(cylinder, 0.3, 0.3, 0.5, 16, 1)  ' follower
				glTranslatef(0.0, 0.0, 0.5)
				gluDisk(disk, 0.0, 0.3, 16, 1)  ' follower end-cap
			glPopMatrix()
		glPopMatrix()
	glEndList()

	 ' spark plug
	glNewList(listbase + plug, $$GL_COMPILE)
	
		glColor3f(0.5, 0.5, 0.5)
		glPushMatrix()
			glRotatef(-90.0, 1, 0.0, 0.0)

			glPushMatrix()
				 ' thread
				gluCylinder(cylinder, 0.27, 0.27, 0.5, 16, 1)

				 ' hexagon
				glTranslatef(0.0, 0.0, 0.5)
				gluCylinder(cylinder, 0.4, 0.4, 0.3, 6, 1)
				glPushMatrix()
					glRotatef(180.0, 0.0, 1, 0.0)
					gluDisk(disk, 0.0, 0.4, 6, 1)  ' valve base
					glTranslatef(0.0, 0.0, -0.3)
					glRotatef(180.0, 0.0, 1, 0.0)
					gluDisk(disk, 0.0, 0.4, 6, 1)  ' valve base
				glPopMatrix()

				 ' insulator
				glColor3f(1.0, 1.0, 1.0)
				glTranslatef(0.0, 0.0, 0.3)
				gluCylinder(cylinder, 0.27, 0.13, 0.9, 16, 1)
				glColor3f(0.5, 0.5, 0.5)

				 ' electrode / nipple
				glTranslatef(0.0, 0.0, -0.85)
				gluCylinder(cylinder, 0.08, 0.08, 2, 10, 1)
			glPopMatrix()
		glPopMatrix()
	glEndList()
	
	
END FUNCTION


FUNCTION DOUBLE ACOS (x)
	RETURN (180 * acos(DOUBLE (x))) / $$PI
END FUNCTION

FUNCTION DOUBLE SIN (x)
	SHARED DOUBLE PIDIV180
	
	RETURN sin(DOUBLE (x) * PIDIV180)
END FUNCTION

FUNCTION DOUBLE COS (x)
	SHARED DOUBLE PIDIV180
	
	RETURN cos(DOUBLE (x) * PIDIV180)
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

FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height < 50) THEN #Height = 50

	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(45.0, SINGLE(#Width/#Height), 1, 1000.0)
	glMatrixMode( $$GL_MODELVIEW)
	glLoadIdentity()

END FUNCTION


FUNCTION FillArray ( array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)

	
	SINGLEAT (array)= v1
	SINGLEAT (array+4)= v2
	SINGLEAT (array+8)= v3
	SINGLEAT (array+12)= v4

END FUNCTION


END PROGRAM
