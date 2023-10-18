 ' ========================================================================
 ' Loosely based on NeHe lesson 23
 '
 ' XBLite\XBasic rewrite by Michael McElligott 1/12/2002
 ' Mapei_@hotmail.com
 ' ========================================================================


	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "kernel32"
	IMPORT "msvcrt"

'$$PI = 0.31415926535	'897932384626433832795
$$TORUS_MAJOR    = 1.5
$$TORUS_MINOR    = 0.6

DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadGLTextures ()
DECLARE FUNCTION FillArray (SINGLE @array[], SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)

DECLARE FUNCTION glDrawCube ()
DECLARE FUNCTION ResetView ()
DECLARE FUNCTION DrawTorus ()
DECLARE FUNCTION ProcessHelix()	
DECLARE FUNCTION calcNormal (SINGLE @v[], SINGLE @out[])
DECLARE FUNCTION ReduceToUnit (SINGLE @array[])

FUNCTION Main ()
	SHARED SINGLE z

	Create ()
	Init()

	event=1
	DO
		
		Render ()
		glfwSwapBuffers ()
		

		IF glfwGetKey('Z')=1 THEN
			z=z - 0.2
		END IF			
			
		IF glfwGetKey('A')=1 THEN
			z=z + 0.2
		END IF

		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0) THEN event=0
		
		IF (#vsync = 1)  THEN
			glfwSleep(0.01)
		END IF

	LOOP WHILE event=1

	glfwTerminate()

END FUNCTION

FUNCTION Create ()

	' Init GLFW and open window
    glfwInit()
    IFZ glfwOpenWindow(640,480, 0,0,0,0, 32,0, $$GLFW_WINDOW ) THEN
        glfwTerminate()
        RETURN 0
    END IF
    
    glfwSetWindowTitle( &"XBlite Spherical Environment Mapping" )
    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
    glfwSetMousePosCallback (&MousePos() ) 
    glfwSwapInterval( 1 )
    
	glfwEnable( $$GLFW_KEY_REPEAT )
	
	#vsync=1

END FUNCTION

FUNCTION key (k,action)
	SHARED object,filter,sleep
	SHARED SINGLE yspeed,xspeed
	SHARED torus_list,helix
	STATIC light

	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k
	
		CASE $$GLFW_KEY_LEFT  :
			yspeed=yspeed - 0.02
		CASE $$GLFW_KEY_RIGHT  :
			yspeed=yspeed + 0.02		
		CASE $$GLFW_KEY_UP  :
			xspeed=xspeed - 0.02		
		CASE $$GLFW_KEY_DOWN  :
			xspeed=xspeed + 0.02		
			
		CASE 'M' :
			IF #FreeLook=1 THEN #FreeLook=0 ELSE #FreeLook=1
			
		CASE 'R' :
			ResetView ()
	
		CASE ' ' :
			INC object
			IF object >5 THEN object=0
			
		CASE 'L':
			IF light=1 THEN
				glDisable($$GL_LIGHTING)
				light=0
			ELSE
				glEnable($$GL_LIGHTING)
				light=1
			END IF

		CASE 'S' :
			#PI# = #PI# + 0.314159
			IF torus_list<>0 THEN glDeleteLists (torus_list, 1)
			IF helix<>0 THEN glDeleteLists (helix ,1)
			torus_list=0
			helix=0
		CASE 'X' :
			#PI# = #PI# - 0.314159
			IF torus_list<>0 THEN glDeleteLists (torus_list, 1)
			IF helix<>0 THEN glDeleteLists (helix ,1)
			torus_list=0
			helix=0
			
		CASE 'F' :
			INC filter
			IF filter > 2 THEN filter = 0

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

FUNCTION ResetView ()
	SHARED SINGLE z,yspeed,xspeed,xrot,yrot
	SHARED filter,object,twists,helix,torus_list
	
	xrot = 0
	yrot = 0
	xspeed = 0
	yspeed = 0
	z = -10
	object = 1
	filter = 1
	twists = 4
	#FreeLook = 0
	#PI# = 3.1415926535 	'897932384626433832795
	
    #TORUS_MAJOR_RES = 48
    #TORUS_MINOR_RES = 48	
    
	IF torus_list<>0 THEN glDeleteLists (torus_list, 1)
	IF helix<>0 THEN glDeleteLists (helix ,1)
	torus_list=0
	helix=0
	
END FUNCTION



FUNCTION Render()
	SHARED object,filter,texture[],quadratic
	SHARED SINGLE z,yspeed,xspeed,xrot,yrot
	SHARED my,mx
	

	glClear( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)	 '  Clear The Screen And The Depth Buffer
	glLoadIdentity()									 '  Reset The View

	glTranslatef(0.0,0.0,z)
	
	IF #FreeLook=1 THEN
		glRotatef( SINGLE(mx-(#Width/2)), 0.0, 1.0, 0.0)			 '	Use Mouse to control
		glRotatef( SINGLE(my-(#Height/2)), 1.0, 0.0, 0.0)	
	END IF
	

	glEnable( $$GL_TEXTURE_GEN_S)							 '  Enable Texture Coord Generation For S (NEW)
	glEnable( $$GL_TEXTURE_GEN_T)							 '  Enable Texture Coord Generation For T (NEW)

	glBindTexture( $$GL_TEXTURE_2D, texture[filter+(filter + 1)])  '  This Will Select The Sphere Map
	glPushMatrix()
	glRotatef(xrot,1.0,0.0,0.0)
	glRotatef(yrot,0.0,1.0,0.0)
	
	SELECT CASE object
	
	CASE 0:
		glDrawCube()

	CASE 1:
		glTranslatef(0.0,0.0,-1.5)					 '  Center The Cylinder
		gluCylinder(quadratic,1.0,1.0,3.0,32,32)	 '  A Cylinder With A Radius Of 0.5 And A Height Of 2

	CASE 2:
		gluSphere(quadratic,1.3,32,32)				 '  Draw A Sphere With A Radius Of 1 And 16 Longitude And 16 Latitude Segments

	CASE 3:
		glTranslatef(0.0,0.0,-1.5)					 '  Center The Cone
		gluCylinder(quadratic,1.0,0.0,3.0,32,32)	 '  A Cone With A Bottom Radius Of .5 And A Height Of 2
		
	CASE 4:
		DrawTorus ()
	CASE 5:
		ProcessHelix ()

	END SELECT

	glPopMatrix()
	glDisable( $$GL_TEXTURE_GEN_S)
	glDisable( $$GL_TEXTURE_GEN_T)

	glBindTexture( $$GL_TEXTURE_2D, texture[filter * 2])	 '  This Will Select The BG Maps...
	glPushMatrix()
		glTranslatef(0.0, 0.0, -24.0)
		glBegin( $$GL_QUADS)
			glNormal3f( 0.0, 0.0, 1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f(-13.3, -10.0,  10.0)
			glTexCoord2f(1.0, 0.0) glVertex3f( 13.3, -10.0,  10.0)
			glTexCoord2f(1.0, 1.0) glVertex3f( 13.3,  10.0,  10.0)
			glTexCoord2f(0.0, 1.0) glVertex3f(-13.3,  10.0,  10.0)
		glEnd()
	glPopMatrix()

	xrot = xrot + xspeed
	yrot = yrot + yspeed

	RETURN $$TRUE										 '  Keep Going

END FUNCTION



FUNCTION Init()
	SHARED GLfloat LightAmbient[],LightDiffuse[],LightPosition[]
	SHARED SINGLE vertexes[],glfMaterialColor[], specular[],normal[]
	SHARED quadratic,twists
	
	
	DIM LightPosition[3]
	DIM LightAmbient[3]
	DIM LightDiffuse[3]
	
	DIM glfMaterialColor[3]
	DIM specular[3]
	DIM normal[2]
	DIM vertexes[3,3]
	
	FillArray (@LightAmbient[], 0.5, 0.5, 0.5, 1.0 )
	FillArray (@LightDiffuse[], 1.0, 1.0, 1.0, 1.0 )
	FillArray (@LightPosition[], 0.0, 0.0, 2.0, 1.0 )
	
	FillArray (@glfMaterialColor[], 0.4,0.2,0.8,1.0)			 '  Set The Material Color
	FillArray (@specular[], 1.0,1.0,1.0,1.0)					 '  Sets Up Specular Lighting

	#AutoSpin=1												 '  5 Twists

	LoadGLTextures ()
	ResetView ()


	glEnable( $$GL_TEXTURE_2D)							 '  Enable Texture Mapping
	glShadeModel( $$GL_SMOOTH)							 '  Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5)				 '  Black Background
	glClearDepth(1.0)									 '  Depth Buffer Setup
	glEnable( $$GL_DEPTH_TEST)							 '  Enables Depth Testing
	glDepthFunc( $$GL_LEQUAL)								 '  The Type Of Depth Testing To Do
	glHint( $$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)	 '  Really Nice Perspective Calculations

	glLightfv( $$GL_LIGHT1, $$GL_AMBIENT, &LightAmbient[])		 '  Setup The Ambient Light
	glLightfv( $$GL_LIGHT1, $$GL_DIFFUSE, &LightDiffuse[])		 '  Setup The Diffuse Light
	glLightfv( $$GL_LIGHT1, $$GL_POSITION,&LightPosition[])	 '  Position The Light
	glEnable( $$GL_LIGHT1)								 '  Enable Light One

	quadratic = gluNewQuadric()							 '  Create A Pointer To The Quadric Object (Return 0 If No Memory)
	gluQuadricNormals(quadratic, $$GLU_SMOOTH)			 '  Create Smooth Normals 
	gluQuadricTexture(quadratic, $$GL_TRUE)				 '  Create Texture Coords 

	glTexGeni( $$GL_S, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)  '  Set The Texture Generation Mode For S To Sphere Mapping (NEW)
	glTexGeni( $$GL_T, $$GL_TEXTURE_GEN_MODE, $$GL_SPHERE_MAP)  '  Set The Texture Generation Mode For T To Sphere Mapping (NEW)

	
END FUNCTION 

FUNCTION DrawTorus ()
    SHARED torus_list
    XLONG    i, j, k 
    DOUBLE s, t, x, y, z, nx, ny, nz, scale, twopi 

    IFZ torus_list THEN
    
         '  Start recording displaylist
        torus_list = glGenLists( 1 ) 
        glNewList( torus_list, $$GL_COMPILE_AND_EXECUTE ) 

         '  Draw torus
        twopi = 2.0 * #PI# 
        FOR i=0 TO #TORUS_MINOR_RES-1
        
            glBegin( $$GL_QUAD_STRIP ) 
            FOR j=0 TO #TORUS_MAJOR_RES
            
                FOR k=1 TO 0 STEP -1
                
                    s = (i + k) MOD #TORUS_MINOR_RES + 0.5
                    t = j MOD #TORUS_MAJOR_RES    

                     '  Calculate point on surface
                    x = ($$TORUS_MAJOR+ $$TORUS_MINOR*cos(s*twopi/ #TORUS_MINOR_RES)) * cos(t*twopi/ #TORUS_MAJOR_RES) 
                    y = $$TORUS_MINOR * sin(s * twopi / #TORUS_MINOR_RES) 
                    z = ($$TORUS_MAJOR+ $$TORUS_MINOR*cos(s*twopi/ #TORUS_MINOR_RES)) * sin(t*twopi/ #TORUS_MAJOR_RES) 

                     '  Calculate surface normal
                    nx = x - $$TORUS_MAJOR*cos(t*twopi/ #TORUS_MAJOR_RES) 
                    ny = y 
                    nz = z - $$TORUS_MAJOR*sin(t*twopi/ #TORUS_MAJOR_RES) 
                    scale = 1.0 / sqrt( nx*nx + ny*ny + nz*nz ) 
                    nx =nx * scale 
                    ny =ny * scale 
                    nz =nz * scale 

                    glNormal3f( SINGLE (nx), SINGLE (nz), SINGLE (ny) ) 
                    glVertex3f( SINGLE (x), SINGLE (z), SINGLE (y) ) 
                NEXT k
            NEXT j
            glEnd() 
        NEXT i

         '  Stop recording displaylist
        glEndList() 
    
    ELSE
    	'  Playback displaylist
        glCallList( torus_list ) 
    END IF
    
END FUNCTION


FUNCTION glDrawCube()
	STATIC cube
	
	
    IFZ cube THEN
    
         '  Start recording displaylist
		cube = glGenLists( 1 ) 
        glNewList( cube, $$GL_COMPILE_AND_EXECUTE ) 
        
        
		  glBegin( $$GL_QUADS)
		 '  Front Face
			glNormal3f( 0.0, 0.0, 0.5)
			glTexCoord2f(0.0, 0.0) glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f( 1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f(-1.0,  1.0,  1.0)
			 '  Back Face
			glNormal3f( 0.0, 0.0,-0.5)
			glTexCoord2f(1.0, 0.0) glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f( 1.0, -1.0, -1.0)
			 '  Top Face
			glNormal3f( 0.0, 0.5, 0.0)
			glTexCoord2f(0.0, 1.0) glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f( 1.0,  1.0, -1.0)
			 '  Bottom Face
			glNormal3f( 0.0,-0.5, 0.0)
			glTexCoord2f(1.0, 1.0) glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f( 1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f(-1.0, -1.0,  1.0)
			 '  Right Face
			glNormal3f( 0.5, 0.0, 0.0)
			glTexCoord2f(1.0, 0.0) glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 0.0) glVertex3f( 1.0, -1.0,  1.0)
			 '  Left Face
			glNormal3f(-0.5, 0.0, 0.0)
			glTexCoord2f(0.0, 0.0) glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 0.0) glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0) glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0) glVertex3f(-1.0,  1.0, -1.0)
		  glEnd()
	
		 '  Stop recording displaylist
		glEndList() 
    
	ELSE
    	'  Playback displaylist
		glCallList( cube ) 
	END IF
	
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
	SHARED texture[]


	DIM texture[5]
	DIM TextureImage[1]
	
	TextureImage[0]=&"BG.tga"
	TextureImage[1]=&"Reflect.tga"

	glGenTextures(5, &texture[])					 '  Create Three Textures

	FOR loop = 0 TO 1 
		
		 '  Create Nearest Filtered Texture
		glBindTexture( $$GL_TEXTURE_2D, texture[loop])	 '  Gen Tex 0 and 1
		glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_NEAREST)
		glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_NEAREST)
		glfwLoadTexture2D( TextureImage[loop], 0 )

		 '  Create Linear Filtered Texture
		glBindTexture( $$GL_TEXTURE_2D, texture[loop + 2])	 '  Gen Tex 2 and 3 
		glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)
		glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR)
		glfwLoadTexture2D( TextureImage[loop], 0 )

		 '  Create MipMapped Texture
		glBindTexture( $$GL_TEXTURE_2D, texture[loop + 4])	 '  Gen Tex 4 and 5
		glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)
		glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR_MIPMAP_NEAREST)
		glfwLoadTexture2D( TextureImage[loop], $$GLFW_BUILD_MIPMAPS_BIT )
			
	NEXT loop
	

 RETURN texture

END FUNCTION

FUNCTION FillArray (SINGLE array[], SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)

	array[0] = v1
	array[1] = v2
	array[2] = v3
	array[3] = v4

END FUNCTION

FUNCTION ProcessHelix()												 '  Draws A Helix
	SHARED SINGLE vertexes[],glfMaterialColor[], specular[],normal[]
	SHARED SINGLE angle
	GLfloat x,y,phi,theta,v,u,r,zz
	SHARED SINGLE z
	SHARED twists
	SHARED mx,my
	SHARED helix
	STATIC lastTickCount


	tickCount = GetTickCount ()			 '  Get The Tick Count
	angle = angle + SINGLE(tickCount - lastTickCount) / 5.0	
	lastTickCount = tickCount			 '  Set Last Count To Current Count

	glLoadIdentity()											 '  Reset The Modelview Matrix
	gluLookAt(0, 1, 55, 0, 0, 0, 0, 1, 1)						 '  Eye Position (0,5,50) Center Of Scene (0,0,0), Up On Y Axis
	glPushMatrix()												 '  Push The Modelview Matrix
	glTranslatef(0,0,50+z)										 '  Translate 50 Units Into The Screen
	glRotatef(angle/3.0,1,0,0)									 '  Rotate By angle/2 On The X-Axis
	glRotatef(angle/1.5,0,1,0)									 '  Rotate By angle/3 On The Y-Axis


'   glMaterialfv( $$GL_FRONT_AND_BACK,$$GL_AMBIENT_AND_DIFFUSE, &glfMaterialColor[])
'	glMaterialfv( $$GL_FRONT_AND_BACK,$$GL_SPECULAR, &specular[])
	
	
  IFZ helix THEN
    
     '  Start recording displaylist
	helix = glGenLists( 1 ) 
	glNewList( helix, $$GL_COMPILE_AND_EXECUTE ) 
        
	r = 0.3															 '  Radius
		
	glBegin( $$GL_QUADS)											 '  Begin Drawing Quads
	FOR phi = 0 TO 360 STEP 20										 '  360 Degrees In Steps Of 20
	
		FOR theta = 0 TO (360 * twists) STEP 15   					 '  360 Degrees * Number Of Twists In Steps Of 20
		
			v=(phi / 180.0 * #PI#) 									 '  Calculate Angle Of First Point	(  0 )
			u=(theta / 180.0 * #PI#) 								 '  Calculate Angle Of First Point	(  0 )

			x= SINGLE ((cos(u)*(2.0 + cos(v) ))*r)					 '  Calculate x Position (1st Point)
			y= SINGLE ((sin(u)*(2.0 + cos(v) ))*r)					 '  Calculate y Position (1st Point)
			zz= SINGLE ((( u - (2.0 * #PI# )) + sin(v) )) * r		 '  Calculate z Position (1st Point)

			vertexes[0,0]=x											 '  Set x Value Of First Vertex
			vertexes[0,1]=y											 '  Set y Value Of First Vertex
			vertexes[0,2]=zz										 '  Set z Value Of First Vertex

			v=(phi/180.0 * #PI# )									 '  Calculate Angle Of Second Point	(  0 )
			u=((theta + 20)/ 180.0 * #PI# )							 '  Calculate Angle Of Second Point	( 20 )

			x= SINGLE (cos(u)*(2.0 + cos(v) ))*r					 '  Calculate x Position (2nd Point)
			y= SINGLE (sin(u)*(2.0 + cos(v) ))*r					 '  Calculate y Position (2nd Point)
			zz= SINGLE ((( u-(2.0 * #PI# )) + sin(v) )) * r			 '  Calculate z Position (2nd Point)

			vertexes[1,0]=x											 '  Set x Value Of Second Vertex
			vertexes[1,1]=y											 '  Set y Value Of Second Vertex
			vertexes[1,2]=zz											 '  Set z Value Of Second Vertex

			v=((phi + 20)/ 180.0 * #PI# )							 '  Calculate Angle Of Third Point	( 20 )
			u=((theta + 20)/ 180.0 * #PI# )							 '  Calculate Angle Of Third Point	( 20 )

			x= SINGLE (cos(u)*(2.0 + cos(v) ))*r					 '  Calculate x Position (3rd Point)
			y= SINGLE (sin(u)*(2.0 + cos(v) ))*r					 '  Calculate y Position (3rd Point)
			zz= SINGLE ((( u-(2.0 * #PI# )) + sin(v) )) * r			 '  Calculate z Position (3rd Point)

			vertexes[2,0]=x											 '  Set x Value Of Third Vertex
			vertexes[2,1]=y											 '  Set y Value Of Third Vertex
			vertexes[2,2]=zz									 		 '  Set z Value Of Third Vertex

			v=((phi + 20)/ 180.0 * #PI# )							 '  Calculate Angle Of Fourth Point	( 20 )
			u=((theta)/ 180.0 * #PI# )								 '  Calculate Angle Of Fourth Point	(  0 )

			x= SINGLE (cos(u)*(2.0 + cos(v) ))*r					 '  Calculate x Position (4th Point)
			y= SINGLE (sin(u)*(2.0 + cos(v) ))*r					 '  Calculate y Position (4th Point)
			zz= SINGLE ((( u-(2.0 * #PI# )) + sin(v) )) * r			 '  Calculate z Position (4th Point)

			vertexes[3,0]=x											 '  Set x Value Of Fourth Vertex
			vertexes[3,1]=y											 '  Set y Value Of Fourth Vertex
			vertexes[3,2]=zz											 '  Set z Value Of Fourth Vertex

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
	
	 '  Stop recording displaylist
    glEndList() 
    
  ELSE
     '  Playback displaylist
    glCallList( helix ) 
  END IF
	
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

END PROGRAM
