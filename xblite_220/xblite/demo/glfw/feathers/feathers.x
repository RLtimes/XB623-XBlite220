 ' ========================================================================
 ' "Flock of Feathers" by Andreas Gustafsson (C) 2001
 '
 ' XBLite\XBasic conversion by Michael McElligott 29/11/2002
 ' Mapei_@hotmail.com
 ' ========================================================================

	IMPORT "xst"
	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "kernel32"
	IMPORT "msvcrt"

TYPE vertex
	SINGLE	.x
	SINGLE	.y
	SINGLE	.z
END TYPE

$$PI = 3.14159265
$$BEZ_DIVS = 16
$$NR_OBJS = 511


DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadTexture (file)
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)

DECLARE FUNCTION Bezier(vertex p1,vertex p2,vertex p3,vertex p4,vertex p5,vertex p6)
DECLARE FUNCTION DrawSkybox()
DECLARE FUNCTION SINGLE random (SINGLE high)


FUNCTION Main ()

	Create ()
	Init()

	event=1
	DO
	
		Render ()
		glfwSwapBuffers ()

		IF ((glfwGetKey($$GLFW_KEY_ESC)=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN event=0		
		IF (#vsync = 1) THEN glfwSleep(0.01)

	LOOP WHILE event=1

	glfwTerminate()

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
    glfwInit()
    IFZ glfwOpenWindow(800,600, 0,0,0,0, 32,0, $$GLFW_WINDOW ) THEN
        glfwTerminate()
        RETURN 0
    END IF

    glfwSetWindowTitle( &"XBlite Feathers" )
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

FUNCTION Bezier (vertex p1,vertex p2,vertex p3,vertex p4,vertex p5,vertex p6)
	SINGLE u,bez02,bez12,bez22 
	SINGLE i,x,y 
	vertex tmpV
	
	u=0 
	glBegin( $$GL_TRIANGLE_STRIP)

	FOR i = 0 TO $$BEZ_DIVS	
	
   		bez02 = (1-u)*(1-u) 
    	bez12 = 2 * u* (1-u) 
    	bez22 = u * u 

    	tmpV.x = bez02 * p1.x + bez12 * p2.x + bez22 * p3.x 
    	tmpV.y = bez02 * p1.y + bez12 * p2.y + bez22 * p3.y 
    	tmpV.z = bez02 * p1.z + bez12 * p2.z + bez22 * p3.z 

		glTexCoord2f(0, i / SINGLE ($$BEZ_DIVS-1)) 
    	glVertex3f(tmpV.x,tmpV.y,tmpV.z) 

    	tmpV.x = bez02 * p4.x + bez12 * p5.x + bez22 * p6.x 
    	tmpV.y = bez02 * p4.y + bez12 * p5.y + bez22 * p6.y 
    	tmpV.z = bez02 * p4.z + bez12 * p5.z + bez22 * p6.z 

		glTexCoord2f(1, i / SINGLE ($$BEZ_DIVS-1)) 
    glVertex3f(tmpV.x,tmpV.y,tmpV.z) 

		u = u + 1.0 / SINGLE ($$BEZ_DIVS)

	NEXT i
	glEnd() 	


END FUNCTION

FUNCTION Render()
	SHARED vertex pos[], rot[], rotadd[], color[] 
	SHARED SINGLE size[], bend[]
	vertex t1,t2,t3,t4,t5,t6,wind 
	DOUBLE windStrength,tilt1,tilt2 
	SHARED SINGLE rotY
	SHARED featherTexture
	STATIC DOUBLE deltaTime,time
	SHARED mx,my

	glClear( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT )
	
	IFZ time THEN
		time = 1034.0007868
		deltaTime = 0.0083
	END IF
	
	time = time + deltaTime

  rotY = rotY + deltaTime * 15 
	tilt1 = -25 + 50 * sin( time * 0.27) 
	tilt2 = 45 * sin( time * 0.18) 
	
	glPushMatrix()  
	
	IF #freelook THEN
	 	glRotatef( SINGLE(mx-(#Width/2)), 0.0, 1.0, 0.0)	'	Use Mouse to control
		glRotatef( SINGLE(my-(#Height/2)), 1.0, 0.0, 0.0)
	END IF

	glPushMatrix()    

	IFZ #freelook THEN
		glRotatef(tilt1, 1.0, 0.0, 0.0) 
   		glRotatef(rotY, 0.0, 1.0, 0.0) 
   		glRotatef(tilt2, 0.0, 0.0, 1.0) 
  END IF

	glColor3f(1.0, 1.0, 1.0) 
	glDisable( $$GL_DEPTH_TEST) 
	DrawSkybox() 
	glEnable( $$GL_DEPTH_TEST) 
	glPopMatrix()	 
	
	glTranslatef (0.0, 0.0, 10.0 * cos(time * 0.2)) 
	glRotatef(tilt1, 1.0, 0.0, 0.0) 
	glRotatef(rotY, 0.0, 1.0, 0.0) 
	glRotatef(tilt2, 0.0, 0.0, 1.0) 

	wind.x = 1 * sin(time) 
	wind.y = 0.25 * cos(time * 0.8) 
	wind.z = 1 * sin(time* 0.5) + 0.5 * cos(time * 1.2) 
	windStrength = 1.65 * (sin(time * 0.6) + 0.2 * sin(time * 2.3)) 
	
	glBindTexture( $$GL_TEXTURE_2D, featherTexture)
	glDepthMask( $$GL_FALSE )
	glEnable( $$GL_BLEND) 
	glBlendFunc( $$GL_SRC_ALPHA, $$GL_ONE_MINUS_SRC_ALPHA)                 

	t1.x=0 			
	t1.y=-1 
	t1.z=0 

	t2.x=0 			
	t2.y=0 
	t2.z=0.5 

	t3.x=0 			
	t3.y=1.0 
	t3.z=0 

	t4.x=0.5 			
	t4.y=-1 
	t4.z=0 

	t5.x=0.5 			
	t5.y=0.0 
	t5.z=0.5 

	t6.x=0.5 			
	t6.y=1.0 
	t6.z=0 


	FOR i = 0 TO $$NR_OBJS

		glColor3f (color[i].x,color[i].y,color[i].z) 
		glPushMatrix() 		
		glTranslatef (pos[i].x,pos[i].y,pos[i].z)

   		glRotatef(rot[i].x, 1.0, 0.0, 0.0) 
   		glRotatef(rot[i].y, 0.0, 1.0, 0.0) 
   		glRotatef(rot[i].z, 0.0, 0.0, 1.0) 	
   		glScalef(size[i],size[i],size[i]) 

   		t2.z = bend[i] 
   		t5.z = bend[i] 

   		rot[i].x = rot[i].x + rotadd[i].x * deltaTime 
   		rot[i].y = rot[i].y + rotadd[i].y * deltaTime 
   		rot[i].z = rot[i].z + rotadd[i].z * deltaTime 
   		pos[i].x = pos[i].x + deltaTime * (sin(rot[i].x* $$PI /90)+windStrength*(1+sin(rot[i].x* $$PI /90))*wind.x) 
	   	pos[i].y = pos[i].y + deltaTime * (sin(rot[i].y* $$PI /90)+windStrength*(1+sin(rot[i].y* $$PI /90))*wind.y) 
	   	pos[i].z = pos[i].z + deltaTime * (sin(rot[i].z* $$PI /90)+windStrength*(1+sin(rot[i].z* $$PI /90))*wind.z) 

		Bezier (t1,t2,t3,t4,t5,t6) 
		glPopMatrix() 

	NEXT i
	
	
	glDisable( $$GL_BLEND) 	
	glPopMatrix() 
 
	RETURN $$TRUE	 '  Keep Going

END FUNCTION


FUNCTION Init()
	SHARED vertex pos[], rot[], rotadd[], color[] 
	SHARED box_front,box_back,box_left,box_right,box_up,box_down,featherTexture
	SHARED SINGLE rotY, size[], bend[]
	SINGLE v1,v2,r

	rotY = 0.0 
	
	DIM pos[$$NR_OBJS]
	DIM rot[$$NR_OBJS]
	DIM rotadd[$$NR_OBJS]
	DIM color[$$NR_OBJS] 
	DIM size[$$NR_OBJS]
	DIM bend[$$NR_OBJS]

	featherTexture = LoadTexture (&"feather.tga") 
	box_front = LoadTexture (&"sky_front.tga") 
	box_back = LoadTexture (&"sky_back.tga") 
	box_left = LoadTexture (&"sky_left.tga") 
	box_right = LoadTexture (&"sky_right.tga") 
	box_up = LoadTexture (&"sky_up.tga") 
	box_down = LoadTexture (&"sky_down.tga") 


	FOR i = 0 TO $$NR_OBJS		' (int i=0 i< $$NR_OBJS i++)
	
		v1 = random($$PI) 
		v2 = random(2 * $$PI ) 
		r = random(2) + random(40) 
		pos[i].x = r*cos(v1) 
		pos[i].y = r*cos(v2)*sin(v1) 
		pos[i].z = r*sin(v2)*sin(v1) 

'		pos[i].x=20*(random(2)-1) 
'		pos[i].y=20*(random(2)-1) 
'		pos[i].z=20*(random(2)-1) 

		rot[i].x = random(360) 
		rot[i].y = random(360) 
		rot[i].z = random(360) 
		rotadd[i].x = random(150)-75 
		rotadd[i].y = random(150)-75 
		rotadd[i].z = random(150)-75 
		color[i].x = 0.85 + random(0.15) 
		color[i].y = 0.85 + random(0.15) 
		color[i].z = 0.85 + random(0.15) 
		size[i] = 0.8 + random(0.4) 
		bend[i] = 0.25 + random(0.5) 
	NEXT i


  glClearColor( 0.0, 0.0, 0.0, 0.0 )  
  glEnable ( $$GL_DEPTH_TEST)  
	
END FUNCTION 

FUNCTION SINGLE random (SINGLE high)
	
  RETURN  ((rand() / DOUBLE (32768)) * high)

END FUNCTION

FUNCTION DrawSkybox()
	SHARED box_front,box_back,box_left,box_right,box_up,box_down
	STATIC cube
	
	
  IFZ cube THEN
  '  Start recording displaylist
	cube = glGenLists( 1 ) 
	glNewList( cube, $$GL_COMPILE_AND_EXECUTE ) 	

	
  glEnable( $$GL_TEXTURE_2D) 
  glBindTexture( $$GL_TEXTURE_2D, box_front)
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_CLAMP) 
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_CLAMP) 

  glBegin( $$GL_QUADS) 
	glTexCoord2f(1,0) 
	glVertex3f(-1,-1,-1) 
	glTexCoord2f(0,0) 
	glVertex3f(1,-1,-1) 
	glTexCoord2f(0,1) 
	glVertex3f(1,1,-1) 
	glTexCoord2f(1,1) 
	glVertex3f(-1,1,-1) 
	glEnd() 

  glBindTexture( $$GL_TEXTURE_2D, box_up)
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_CLAMP) 
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_CLAMP) 
  glBegin( $$GL_QUADS) 
	glTexCoord2f(1,0) 
	glVertex3f(-1,1,-1) 
	glTexCoord2f(0,0) 
	glVertex3f(1,1,-1) 
	glTexCoord2f(0,1) 
	glVertex3f(1,1,1) 
	glTexCoord2f(1,1) 
	glVertex3f(-1,1,1) 
	glEnd() 

  glBindTexture( $$GL_TEXTURE_2D, box_left)
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_CLAMP) 
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_CLAMP) 
  glBegin( $$GL_QUADS) 
	glTexCoord2f(1,1) 
	glVertex3f(-1,1,1) 
	glTexCoord2f(0,1) 
	glVertex3f(-1,1,-1) 
	glTexCoord2f(0,0) 
	glVertex3f(-1,-1,-1) 
	glTexCoord2f(1,0) 
	glVertex3f(-1,-1,1) 
	glEnd() 

  glBindTexture( $$GL_TEXTURE_2D, box_right)
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_CLAMP) 
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_CLAMP) 
  glBegin( $$GL_QUADS) 
	glTexCoord2f(0,1) 
	glVertex3f(1,1,1) 
	glTexCoord2f(1,1) 
	glVertex3f(1,1,-1) 
	glTexCoord2f(1,0) 
	glVertex3f(1,-1,-1) 
	glTexCoord2f(0,0) 
	glVertex3f(1,-1,1) 
	glEnd() 

  glBindTexture( $$GL_TEXTURE_2D, box_down)
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_CLAMP) 
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_CLAMP) 
  glBegin( $$GL_QUADS) 
	glTexCoord2f(1,1) 
	glVertex3f(-1,-1,-1) 
	glTexCoord2f(0,1) 
	glVertex3f(1,-1,-1) 
	glTexCoord2f(0,0) 
	glVertex3f(1,-1,1) 
	glTexCoord2f(1,0) 
	glVertex3f(-1,-1,1) 
	glEnd() 

  glBindTexture( $$GL_TEXTURE_2D, box_back)
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_CLAMP) 
  glTexParameteri ( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_CLAMP) 
  glBegin( $$GL_QUADS) 
	glTexCoord2f(0,0) 
	glVertex3f(-1,-1,1) 
	glTexCoord2f(1,0) 
	glVertex3f(1,-1,1) 
	glTexCoord2f(1,1) 
	glVertex3f(1,1,1) 
	glTexCoord2f(0,1) 
	glVertex3f(-1,1,1) 
	glEnd() 
	
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
	IF (#Width < 50) THEN #Width = 50

	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(90.0, SINGLE(#Width/#Height), 0.1, 200.0)
	glMatrixMode( $$GL_MODELVIEW)
	glLoadIdentity()

END FUNCTION


FUNCTION LoadTexture (file)
	STATIC texture

	IFZ texture THEN
		texture = 0
		glGenTextures (10,&texture)
	END IF
	
	INC texture
	
	glBindTexture( $$GL_TEXTURE_2D, texture)
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
    glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )
	glfwLoadTexture2D( file, 0 )


	RETURN texture

END FUNCTION

END PROGRAM
