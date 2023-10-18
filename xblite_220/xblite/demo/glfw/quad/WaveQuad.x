 ' ========================================================================
 ' Made by Ken Van Hoeylandt
 ' Based on OpenGL sample by Blaine Hodge
 '
 ' XBLite\XBasic conversion by Michael McElligott  20/12/2002
 ' Mapei_@hotmail.com
 ' ========================================================================



	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
'	IMPORT "kernel32"
	IMPORT "msvcrt"


DECLARE FUNCTION Main ()
DECLARE FUNCTION Render ()
DECLARE FUNCTION Resize (w,h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION key (k,action)
DECLARE FUNCTION MousePos (x,y)

DECLARE FUNCTION Draw_Quad(SINGLE placex, SINGLE placey, SINGLE placez, SINGLE sizex, SINGLE sizey, SINGLE sizez, SINGLE anglex, SINGLE angley, SINGLE anglez, SINGLE color_r, SINGLE color_g, SINGLE color_b)
DECLARE FUNCTION Draw_Axis(SINGLE placex, SINGLE placey, SINGLE placez, SINGLE anglex, SINGLE angley, SINGLE anglez)


FUNCTION Main ()

	Create ()
	Init()

	event=1
	DO
	
		Render ()
		glfwSwapBuffers ()

		IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0) THEN event=0
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
    
    glfwSetWindowTitle( &"XBlite Quads" )
    glfwSetWindowSizeCallback (&Resize())
    glfwSetKeyCallback(&key() )
    'glfwSetMousePosCallback (&MousePos() ) 
    glfwSwapInterval( 1 )
    
	glfwEnable( $$GLFW_KEY_REPEAT )
	#vsync = 1

END FUNCTION

FUNCTION key (k,action)

	IF ( action != $$GLFW_PRESS ) THEN RETURN
  
	SELECT CASE k

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
	SHARED SINGLE rotatevar,theta,theta2
	SINGLE i

	glClearColor(0.0, 0.0, 0.0, 0.0)
    glClear($$GL_COLOR_BUFFER_BIT)
    glClear($$GL_DEPTH_BUFFER_BIT)
    glPushMatrix()
    
	glLoadName(5)
          
    'glTranslatef(0, 0, 0)
          
     FOR i = 1.0 TO 8.0 
     	Draw_Quad(-sin(theta/50)*(i/10), -cos(theta/50)*(i/10), 0.0, 0.05, 0.05, 0.05, 10.0*i, 10.0 * i, 10.0 * i, 0.2, 0.0, 0.6)
	    Draw_Quad(sin(theta/50)*(i/10), cos(theta/50)*(i/10), 0.0, 0.05, 0.05, 0.05, 10.0 * i, 10.0 * i, 10.0 * i, 0.2, 0.0, 0.6)
     	Draw_Quad(sin((theta+90)/50)*(i/10), cos((theta+90)/50)*(i/10), 0.0, 0.05, 0.05, 0.05, 10.0 * i, 10.0 * i, 10.0 * i, 0.2, 0.0, 0.6)
     	Draw_Quad(-sin((theta+90)/50)*(i/10), -cos((theta+90)/50)*(i/10), 0.0, 0.05, 0.05, 0.05, 10.0 * i, 10.0 * i, 10.0 * i, 0.2, 0.0, 0.6)
     NEXT i
             
     glPopMatrix()
          
     'Draw_Axis(0.0, 0.0, 0.0, theta, theta, theta)
     'Draw_Axis(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)       
          
	theta = theta + rotatevar

END FUNCTION

FUNCTION Draw_Axis(SINGLE placex, SINGLE placey, SINGLE placez, SINGLE anglex, SINGLE angley, SINGLE anglez)
          glPushMatrix()
          
          glRotatef(anglex, 1.0, 0.0, 0.0)
          glRotatef(angley, 0.0, 1.0, 0.0)
          glRotatef(anglez, 0.0, 0.0, 1.0)

          glBegin($$GL_LINES)
          
            glColor3f(1.0,0.0,0.0)
            glVertex3f(0.0 + placex, 0.0 + placey, 0.0 + placez)
            glVertex3f(0.2 + placex, 0.0 + placey, 0.0 + placez)
          
            glColor3f(0.0,1.0,0.0)
            glVertex3f(0.0 + placex, 0.0 + placey, 0.0 + placez)
            glVertex3f(0.0 + placex, 0.2 + placey, 0.0 + placez)
          
            glColor3f(0.0,0.0,1.0)
            glVertex3f(0.0 + placex, 0.0 + placey, 0.0 + placez)
            glVertex3f(0.0 + placex, 0.0 + placey, 0.2 + placez)
            
          glEnd()
          
          glPopMatrix()
          
END FUNCTION



FUNCTION Draw_Quad(SINGLE placex, SINGLE placey, SINGLE placez, SINGLE sizex, SINGLE sizey, SINGLE sizez, SINGLE anglex, SINGLE angley, SINGLE anglez, SINGLE color_r, SINGLE color_g, SINGLE color_b)

          glPushMatrix()
          glRotatef(anglex, 1.0, 0.0, 0.0)
          glRotatef(angley, 0.0, 1.0, 0.0)
          glRotatef(anglez, 0.0, 0.0, 1.0)

          glBegin( $$GL_QUADS)
          glColor3f(color_r,color_g,color_b)  '  Front face
          glVertex3f(-0.5 * sizex+placex, -0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, -0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, 0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f(-0.5 * sizex+placex, 0.5 * sizey+placey, 0.5 * sizez+placez)

          glColor3f(color_r-0.02,color_g,color_b+0.04)  ' Back face
          glVertex3f(-0.5 * sizex+placex, -0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f(-0.5 * sizex+placex, 0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, 0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, -0.5 * sizey+placey, -0.5 * sizez+placez)

          glColor3f(color_r-0.04,color_g,color_b+0.08)  '  Top Face
          glVertex3f(-0.5 * sizex+placex, 0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f(-0.5 * sizex+placex, 0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, 0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, 0.5 * sizey+placey, -0.5 * sizez+placez)

          glColor3f(color_r-0.06,color_g,color_b+0.12)  '  Bottom Face
          glVertex3f(-0.5 * sizex+placex, -0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, -0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, -0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f(-0.5 * sizex+placex, -0.5 * sizey+placey, 0.5 * sizez+placez)

          glColor3f(color_r-0.08,color_g,color_b+0.16)  '  Right face
          glVertex3f( 0.5 * sizex+placex, -0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, 0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, 0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f( 0.5 * sizex+placex, -0.5 * sizey+placey, 0.5 * sizez+placez)

          glColor3f(color_r-0.10,color_g,color_b+0.20)  '  Left Face
          glVertex3f(-0.5 * sizex+placex, -0.5 * sizey+placey, -0.5 * sizez+placez)
          glVertex3f(-0.5 * sizex+placex, -0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f(-0.5 * sizex+placex, 0.5 * sizey+placey, 0.5 * sizez+placez)
          glVertex3f(-0.5 * sizex+placex, 0.5 * sizey+placey, -0.5 * sizez+placez)
          
          glEnd()
          glPopMatrix()

END FUNCTION

FUNCTION Init()
	SHARED SINGLE rotatevar,theta,theta2

	rotatevar = 1.0
	theta = 1.0
	theta2 = 0.1

  glEnable($$GL_CULL_FACE)             ' Enable cull facing (culling/discarding polygons)
  glCullFace($$GL_FRONT)               ' Discard back polygons

  glEnable( $$GL_DEPTH_TEST)
  glDepthFunc( $$GL_LEQUAL)

  glMatrixMode( $$GL_PROJECTION)
  glLoadIdentity()
  glMatrixMode( $$GL_MODELVIEW)
  glLoadIdentity()
  
  glShadeModel( $$GL_SMOOTH)  

 DIM specular![3]
 specular![0] = 1.0
 specular![1] = 1.0
 specular![2] = 1.0
 specular![3] = 1.0
 shininess! = 90.0 
 DIM lightposition![3]
 lightposition![0] = 0.0
 lightposition![1] = 0.0
 lightposition![2] = 0.5
 lightposition![3] = 1.0


  glMaterialfv( $$GL_FRONT_AND_BACK, $$GL_SPECULAR, &specular![])
  glMaterialfv( $$GL_FRONT_AND_BACK, $$GL_SHININESS, &shininess!)

   '  Set the $$GL_AMBIENT_AND_DIFFUSE color state variable to be the
   '  one referred to by all following calls to glColor
  glColorMaterial( $$GL_FRONT_AND_BACK, $$GL_AMBIENT_AND_DIFFUSE)
  glEnable( $$GL_COLOR_MATERIAL)

   '  Create a Directional Light Source
  glLightfv( $$GL_LIGHT0, $$GL_POSITION, &lightposition![])
  glEnable( $$GL_LIGHTING)
  glEnable( $$GL_LIGHT0)

	
END FUNCTION 

FUNCTION Resize (Width ,Height)

	#Width = Width
	#Height = Height
	
	IF (#Height < 50) THEN #Height = 50
	IF (#Width < 50) THEN #Width = 50

RETURN
	glViewport(0,0, #Width, #Height)
	glMatrixMode( $$GL_PROJECTION)
	glLoadIdentity()
	gluPerspective(90.0, SINGLE(#Width/#Height), 0.1, 200.0)
	glMatrixMode( $$GL_MODELVIEW)
	glLoadIdentity()

END FUNCTION

END PROGRAM
