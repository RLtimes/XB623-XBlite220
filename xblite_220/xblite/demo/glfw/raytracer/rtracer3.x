
' A ray-tracing program.
' Based on example ray-tracing program found here:
' http://www.devmaster.net/articles/raytracing_series/part1.php
' by Jacco Bikker

' XBLite code by David Szafranski Jan 2006

' v0.0003 
' - added refraction code to rayTrace()
' - modified drawScene() 

PROGRAM "rtracer3"
VERSION "0.0003"

' IMPORT "xst"
' IMPORT "xsx"
	IMPORT "glfw"
	IMPORT "opengl32"
	IMPORT "glu32"
	IMPORT "msvcrt"
	IMPORT "gdi32.dec"
	IMPORT "user32"	
	IMPORT "kernel32"
	IMPORT "xio"

' a vector is just a point
TYPE vector
	DOUBLE .x
  DOUBLE .y
  DOUBLE .z
END TYPE

' color values should be between 0 and 1 
TYPE color
  DOUBLE .r
  DOUBLE .g
  DOUBLE .b
END TYPE

TYPE material
  color  .c						' color 
  DOUBLE .ambient 		' ambient factor
	DOUBLE .diffuse   	' diffuse reflectivity
	DOUBLE .specular  	' specular reflectivity
	XLONG  .shine 			' specular shine power, only powers of 2
	DOUBLE .reflection	' reflection
	DOUBLE .refraction	' refraction
	DOUBLE .rindex 			' index of refraction
END TYPE

' the object structure
TYPE object
	XLONG .type
	XLONG .index
	material .m
	vector .center      ' center of sphere or light source
	DOUBLE .radius      ' radius of sphere
	vector .N           ' plane N
	DOUBLE .D           ' plane D
END TYPE

' the ray struction
TYPE ray
  vector .pos		' origin of ray
  vector .dir		' direction of ray
	object .obj  	' where ray comes from
END TYPE

DECLARE FUNCTION Entry ()
DECLARE FUNCTION InitProgram (w, h)
DECLARE FUNCTION CreateWindow (wtype, w, h, title$)
DECLARE FUNCTION ShutDown ()
DECLARE FUNCTION Loop ()

DECLARE FUNCTION BuildFont ()
DECLARE FUNCTION LoadTexture (addrfile)
DECLARE FUNCTION glPrint (x, y, set, scale, addrtext)
DECLARE FUNCTION CenterWindow ()
DECLARE FUNCTION PrintRenderTime (time)

' ray-tracer functions
DECLARE FUNCTION          render ()
DECLARE FUNCTION vector   makePoint (DOUBLE x, DOUBLE y, DOUBLE z)
DECLARE FUNCTION          makeSphere (DOUBLE x, DOUBLE y, DOUBLE z, DOUBLE r)
DECLARE FUNCTION          initCamera ()
DECLARE FUNCTION          initScene ()
DECLARE FUNCTION          flushCanvas ()
DECLARE FUNCTION          drawScene ()
DECLARE FUNCTION material makeMaterial (DOUBLE r, DOUBLE g, DOUBLE b, DOUBLE reflection, DOUBLE diffuse, DOUBLE specular, shine)
DECLARE FUNCTION          makeLight (DOUBLE x, DOUBLE y, DOUBLE z)
DECLARE FUNCTION vector   reflect (vector n, vector v1)
DECLARE FUNCTION          makeObject (type)
DECLARE FUNCTION          setObjectMaterial (index, material m)
DECLARE FUNCTION          setGlobalAmbient (DOUBLE ambient)
DECLARE FUNCTION DOUBLE   getGlobalAmbient ()
DECLARE FUNCTION          intersectSphere (ray r, index, DOUBLE dist)
DECLARE FUNCTION          rayTrace (ray r, color c, depth, DOUBLE rIndex, DOUBLE dist)
DECLARE FUNCTION color    makeColor (DOUBLE r, DOUBLE g, DOUBLE b)
DECLARE FUNCTION          intersectPlane (ray r, index, DOUBLE dist)
DECLARE FUNCTION          makePlane (DOUBLE x, DOUBLE y, DOUBLE z, DOUBLE d)
DECLARE FUNCTION          setObjectRefraction (index, DOUBLE refraction, DOUBLE rindex)

' vector functions
DECLARE FUNCTION vector   vsub (vector a, vector b)
DECLARE FUNCTION vector   norm (vector a)
DECLARE FUNCTION DOUBLE   vdot (vector a, vector b)
DECLARE FUNCTION vector   vadd (vector a, vector b)
DECLARE FUNCTION vector   vneg (vector a)
DECLARE FUNCTION vector   vcross (vector a, vector b)
DECLARE FUNCTION DOUBLE   vlength (vector a)
DECLARE FUNCTION vector   svproduct (DOUBLE k, vector a)


$$RB = 0    ' offset to red byte
$$GB = 1    ' offset to green byte 
$$BB = 2    ' offset to blue byte 

' object types
$$SPHERE = 1
$$LIGHT  = 2
$$PLANE  = 3

$$HIT		 = 1			' Ray hit primitive
$$MISS	 = 0			' Ray missed primitive
$$INPRIM = -1			' Ray started inside primitive

$$TRACEDEPTH = 6

$$MAXDIST  = 0d412E848000000000  ' 1000000.0
$$EPSILON  = 0d3F1A36E2EB1C432D  ' 0.0001
$$256OVER9 = 0d403C71C71C71C71C  ' 256/9


FUNCTION Entry ()

	XioCreateConsole (@title$, 1000)

	wtype = $$GLFW_WINDOW		' or $$GLFW_FULLSCREEN 
	w = 640 '320
	h = 480 '240
	title$ = "A Ray Tracer"

	IFF CreateWindow (wtype, w, h, title$) THEN ShutDown ()
	CenterWindow ()
	IFF InitProgram (w, h) THEN ShutDown ()
	BuildFont ()
	Loop ()
	ShutDown ()

END FUNCTION

FUNCTION InitProgram (w, h)

	SHARED UBYTE canvas[]

  ' OpenGL setup
  glMatrixMode ($$GL_PROJECTION)
  glLoadIdentity ()
  glOrtho (0.0, 1.0, 0.0, 1.0, -1.0, 1.0)
  glClearColor (0.0, 0.0, 0.0, 1.0)  

  ' allocate image array
	DIM canvas[w*h*3]

  ' raytracer setup
  initCamera ()
  initScene ()
	
	' must return $$TRUE if function is successful
	RETURN $$TRUE		

END FUNCTION

FUNCTION render ()

  glClear ($$GL_COLOR_BUFFER_BIT)
  drawScene ()  		' draws the picture in the canvas
	flushCanvas ()  	' draw the canvas to the OpenGL window 
  glFlush ()

END FUNCTION

FUNCTION Loop ()

	SHARED RunStatus

	RunStatus = 1
	DO
		fstart = GetTickCount ()
		render ()
		ftime = GetTickCount () - fstart
		PrintRenderTime (ftime)
		
		IF #vsync THEN glfwSleep (0.01)		' could also take into account Render() time too.
		glfwSwapBuffers ()
		IFZ glfwGetWindowParam ($$GLFW_OPENED) THEN RunStatus = 0
	LOOP WHILE RunStatus

END FUNCTION

FUNCTION ShutDown ()

	SHARED FONT
	SHARED XLONG TEXID[], TEXTURE
	SHARED FontBase

	glfwTerminate ()

	IF TEXTURE THEN glDeleteTextures (TEXTURE, &TEXID[])		' delete all textures
	IFT FONT THEN glDeleteLists (FontBase, 256)						' delete font from memory

END FUNCTION

FUNCTION CreateWindow (wtype, w, h, title$)

	SHARED XLONG TEXTURE
	SHARED width, height

	IFZ glfwInit () THEN		' Init GLFW and open window
		MessageBoxA ($$NULL, &"Unable to initialize glfw library.   ", &"glfwInit() Error", $$MB_OK)
		RETURN
	END IF

	' set global width, height vars
	width = w
	height = h
	
	wtype = $$GLFW_WINDOW		'$$GLFW_FULLSCREEN
	' glfwOpenWindowHint ($$GLFW_REFRESH_RATE, 85)	' use with care. Fullscreen mode only

	IFZ glfwOpenWindow (width, height, 0, 0, 0, 0, 32, 0, wtype) THEN
		MessageBoxA ($$NULL, &"Unable to create glfw window.   ", &"glfwOpenWindow() Error", $$MB_OK)
		RETURN
	END IF

	glfwSetWindowTitle (&title$)

	TEXTURE = 0		' set flag to show there are no textures loaded.
	#vsync = 1		' 1 = sync buffer swaps to monitor vertical sync rate, ie monitor refresh rate.
	glfwSwapInterval (#vsync)

	RETURN $$TRUE

END FUNCTION

FUNCTION LoadTexture (file)

	SHARED XLONG TEXTURE, TEXID[]

	IFZ TEXTURE THEN
		TEXTURE = 0
		DIM TEXID[TEXTURE]
	END IF

	INC TEXTURE
	REDIM TEXID[TEXTURE]
	TEXID[TEXTURE] = 0

	glGenTextures (1, &TEXID[TEXTURE])
	glBindTexture ($$GL_TEXTURE_2D, TEXID[TEXTURE])
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR)

	IFZ glfwLoadTexture2D (file, 0) THEN
		DEC TEXTURE
		RETURN $$FALSE
	ELSE
		RETURN TEXID[TEXTURE]
	END IF

END FUNCTION

FUNCTION glPrint (x, y, set, scale, text)

	STATIC blend_src, blend_dst
	SHARED width, height
	SHARED FontTexture
	SHARED FontBase

	IFZ FontTexture THEN
		IFF BuildFont () THEN RETURN $$FALSE
	END IF

	glGetIntegerv ($$GL_BLEND_SRC, &blend_src)		' enable overlay
	glGetIntegerv ($$GL_BLEND_DST, &blend_dst)
	glPushAttrib ($$GL_ALL_ATTRIB_BITS)
	glDisable ($$GL_LIGHTING)
	glDisable ($$GL_DEPTH_TEST)
	glBlendFunc ($$GL_SRC_ALPHA, $$GL_ONE_MINUS_SRC_ALPHA)
	glEnable ($$GL_BLEND)
	glMatrixMode ($$GL_PROJECTION)
	glPushMatrix ()
	glLoadIdentity ()
	gluOrtho2D (0.0, width, 0.0, height)
	glMatrixMode ($$GL_MODELVIEW)
	glPushMatrix ()
	glLoadIdentity ()
	glEnable ($$GL_TEXTURE_2D)										'  Enable Texture Mapping

	glBindTexture ($$GL_TEXTURE_2D, FontTexture)
	glTranslated (x, y, 0)												'  Position The Text (0,0 - Top Left)
	glListBase (FontBase - 32 + (128 * set))			'  Choose The Font Set (0 or 1)

	glScalef (scale, -scale, 1.0)								'  Set print size

	text$ = CSTRING$ (text)
	len = LEN (text$)
	glCallLists (len, $$GL_UNSIGNED_BYTE, text)		'  Write The Text To The Screen

	glDisable ($$GL_TEXTURE_2D)										' disable overlay
	glPopMatrix ()
	glMatrixMode ($$GL_PROJECTION)
	glPopMatrix ()
	glPopAttrib ()
	glBlendFunc (blend_src, blend_dst)

END FUNCTION

FUNCTION BuildFont ()

	SINGLE cx, cy
	SHARED FONT
	SHARED FontTexture
	SHARED FontBase

	IFZ FontTexture THEN
		FontTexture = LoadTexture (&"Font.tga")
		IFZ FontTexture THEN
			MessageBoxA ($$NULL, &"Unable to load 'Font.tga'.", &"BuildFont() Error", $$MB_OK)
			FONT = $$FALSE
			RETURN $$FALSE
		END IF
	ELSE
		IFT FONT THEN RETURN $$TRUE										'  font already built
	END IF

	FontBase = glGenLists (256)											'  Creating 256 Display Lists
	glBindTexture ($$GL_TEXTURE_2D, FontTexture)		'  Select Our Font Texture
	FOR loop = 0 TO 255															'  Loop Through All 256 Lists

		cx = SINGLE (loop MOD 16) / 16.0							'  X Position Of Current Character
		cy = SINGLE (loop / 16) / 16.0								'  Y Position Of Current Character

		glNewList (FontBase + loop, $$GL_COMPILE)			'  Start Building A List
		glBegin ($$GL_QUADS)													'  Use A Quad For Each Character
		glTexCoord2f (cx, 1.0 - cy - 0.0625)					'  Texture Coord (Bottom Left)
		glVertex2d (0, 16)														'  Vertex Coord (Bottom Left)
		glTexCoord2f (cx + 0.0625, 1.0 - cy - 0.0625)	'  Texture Coord (Bottom Right)
		glVertex2i (16, 16)														'  Vertex Coord (Bottom Right)
		glTexCoord2f (cx + 0.0625, 1.0 - cy - 0.001)	'  Texture Coord (Top Right)
		glVertex2i (16, 0)														'  Vertex Coord (Top Right)
		glTexCoord2f (cx, 1.0 - cy - 0.001)						'  Texture Coord (Top Left)
		glVertex2i (0, 0)															'  Vertex Coord (Top Left)
		glEnd ()																			'  Done Building Our Quad (Character)
		glTranslated (14, 0, 0)												'  Move To The Right Of The Character
		glEndList ()

	NEXT loop

	FONT = $$TRUE
	RETURN $$TRUE

END FUNCTION
'
' #######################
' #####  makePoint  #####
' #######################
'
'
'
FUNCTION vector makePoint (DOUBLE x, DOUBLE y, DOUBLE z)

	vector p
	p.x = x
	p.y = y
	p.z = z

	RETURN p

END FUNCTION
'
' ########################
' #####  makeSphere  #####
' ########################
'
'
'
FUNCTION makeSphere (DOUBLE x, DOUBLE y, DOUBLE z, DOUBLE r)

	SHARED object objects[]
	
	index = makeObject ($$SPHERE)
	
  objects[index].center = makePoint(x, y, z)  ' center
  objects[index].radius = r   								' radius

  RETURN index

END FUNCTION
'
'
' ########################
' #####  initCamera  #####
' ########################
'
'
FUNCTION initCamera ()

	SHARED width, height
	SHARED vector o
	SHARED DOUBLE DX, DY, SX, SY
	SHARED WX1, WX2, WY1, WY2

	WX1 = -4
	WX2 = 4
	WY1 = 3
	WY2 = -3
	
	DX = (WX2 - WX1) / DOUBLE(width)
	DY = (WY2 - WY1) / DOUBLE(height)

	' set origin
	o = makePoint (0, 0, -5)

END FUNCTION
'
' #######################
' #####  initScene  #####
' #######################
'
'
'
FUNCTION initScene ()

	material m
	
'	makeMaterial (r, g, b, reflection, diffuse, specular, shine)

	' ground plane
	iPlane1 = makePlane (0.0, 1.0, 0.0, 4.4)
	m = makeMaterial (0.4, 0.3, 0.3, 0, 1.0, 0.8, 20)
	setObjectMaterial (iPlane1, @m)

	' make sphere
  iSphere1 = makeSphere (2.0, 0.8, 3.0, 2.5)
  m = makeMaterial (0.7, 0.7, 1.0, 0.2, 0.2, 0.8, 20)
	setObjectMaterial (iSphere1, @m)
	setObjectRefraction (iSphere1, 0.8, 1.3)

	' make another sphere
	iSphere2  = makeSphere (-5.5, -0.5, 7.0, 2.0)
  m = makeMaterial (0.7, 0.7, 1.0, 0.5, 0.1, 0.8, 20)
	setObjectMaterial (iSphere2, @m)	

	' make light 1
	iLight1 = makeLight (0.0, 5.0, 5.0)
	m = makeMaterial (0.4, 0.4, 0.4, 0, 0, 0, 0)
	setObjectMaterial (iLight1, @m)

	' make light 2
	iLight2 = makeLight (-3.0, 5.0, 1.0)
	m = makeMaterial (0.6, 0.6, 0.8, 0, 0, 0, 0)
	setObjectMaterial (iLight2, @m)
	
	' another sphere
	iSphere3  = makeSphere (-1.5, -3.8, 1.0, 1.5)
  m = makeMaterial (1.0, 0.4, 0.4, 0, 0.2, 0.8, 20)
	setObjectMaterial (iSphere3, @m)
	setObjectRefraction (iSphere3, 0.8, 1.5)	
	
	' back plane
	iPlane2 = makePlane (0.4, 0, -1, 12)
	m = makeMaterial (0.5, 0.3, 0.5, 0, 0.6, 0, 20)
	setObjectMaterial (iPlane2, @m)		
	
	' ceiling plane
	iPlane3 = makePlane (0, -1, 0, 7.4)
	m = makeMaterial (0.4, 0.7, 0.7, 0, 0.5, 0, 20)
	setObjectMaterial (iPlane3, @m)	
	
	' grid
	FOR x = 0 TO 7
		FOR y = 0 TO 6
			i = makeSphere (-4.5 + x * 1.5, -4.3 + y * 1.5, 10, 0.3)
			m = makeMaterial (0.3, 1.0, 0.4, 0, 0.6, 0.6, 20)
			setObjectMaterial (i, @m)
		NEXT y
	NEXT x
	
	' set ambient factor
	setGlobalAmbient (0.05)


END FUNCTION
'
' #########################
' #####  flushCanvas  #####
' #########################
'
' draw the canvas array on the screen
'
FUNCTION flushCanvas ()

	SHARED width, height
	SHARED UBYTE canvas[]

  glPixelStorei ($$GL_UNPACK_ALIGNMENT, 1)
	glRasterPos2f (0, 1.0)
	glPixelZoom (1.0, -1.0)  ' invert image
  glDrawPixels (width, height, $$GL_RGB, $$GL_UNSIGNED_BYTE, &canvas[])

END FUNCTION
'
' #######################
' #####  drawScene  #####
' #######################
'
'
'
FUNCTION drawScene ()

	SHARED width, height
	SHARED UBYTE canvas[]
  ray r
  color c
	SHARED vector o
	SHARED DOUBLE DX, DY, SX, SY
	SHARED WX1, WX2, WY1, WY2
	vector dir
	DOUBLE dist
	
	SY = WY1
	
	uppX = width-1
	uppY = height-1
	
	lastprim = 0

  ' trace a ray for every pixel 
  FOR y = 0 TO uppY
		SX = WX1
    FOR x = 0 TO uppX
			
			c = makeColor (0, 0, 0)

			dir = makePoint (SX, SY, 0)
			dir = norm (vsub (dir, o))
			r.pos = o
			r.dir = dir
			prim = rayTrace (r, @c, 1, 1.0, dist)
			
			IF (prim != lastprim) THEN
				
				lastprim = prim
				c = makeColor (0, 0, 0)
				
				FOR tx = -1 TO 1 
					FOR ty = -1 TO 1
					dir = makePoint (SX + DX * tx/2.0, SY + DY * ty/2.0, 0)
					dir = norm (vsub (dir, o))
					r.pos = o
					r.dir = dir
					prim = rayTrace(r, @c, 1, 1.0, dist)
					NEXT ty
				NEXT tx
				
				red   = c.r * $$256OVER9  '(256 / 9.0)
				green = c.g * $$256OVER9	'(256 / 9.0)
				blue  = c.b * $$256OVER9	'(256 / 9.0)

			ELSE
				red   = c.r * 256
				green = c.g * 256
				blue  = c.b * 256
			END IF
			
      ' write the pixel! 
			IF red > 255 THEN red = 255
			IF green > 255 THEN green = 255
			IF blue > 255 THEN blue = 255
			
			pos = 3 * (width*(y) + x)
			canvas[pos]        = red
			canvas[pos + $$GB] = green
			canvas[pos + $$BB] = blue
			
			SX = SX + DX
			
			glfwPollEvents ()   ' detect any events if necessary
    
		NEXT x
		SY = SY + DY
		IFZ glfwGetWindowParam ($$GLFW_OPENED) THEN RETURN  ' closing window, exit now
	NEXT y


END FUNCTION
'
' ##########################
' #####  makeMaterial  #####
' ##########################
'
'
'
FUNCTION material makeMaterial (DOUBLE r, DOUBLE g, DOUBLE b, DOUBLE reflection, DOUBLE diffuse, DOUBLE specular, shine)

	material m

  m.c.r = r
  m.c.g = g
  m.c.b = b
	
	m.reflection 	= reflection
	m.diffuse 		= diffuse
	m.specular 		= specular
	IF shine < 2 THEN shine = 2
	IF (shine MOD 2) THEN INC shine  ' make shine an even number power
	m.shine = shine

  RETURN m

END FUNCTION
'
'
'
' ##################
' #####  vsub  #####
' ##################
'
'
'
FUNCTION vector vsub (vector a, vector b)

	vector c
	
	c.x = a.x - b.x
  c.y = a.y - b.y
  c.z = a.z - b.z

  RETURN c 

END FUNCTION
'
' ##################
' #####  norm  #####
' ##################
'
'
'
FUNCTION vector norm (vector a)

  DOUBLE len
  vector  b

  len = 1.0/sqrt (a.x * a.x + a.y * a.y + a.z * a.z)
  b.x = a.x * len
  b.y = a.y * len
  b.z = a.z * len

  RETURN b

END FUNCTION
'
' ##################
' #####  vdot  #####
' ##################
'
'
'
FUNCTION DOUBLE vdot (vector a, vector b)

 RETURN (a.x * b.x + a.y * b.y + a.z * b.z) 

END FUNCTION
'
' #######################
' #####  makeLight  #####
' #######################
'
'
'
FUNCTION makeLight (DOUBLE x, DOUBLE y, DOUBLE z)

	SHARED object objects[]
	
	index = makeObject ($$LIGHT)
	objects[index].center = makePoint(x, y, z)   ' center of light
	objects[index].radius = 0.1
	RETURN index
END FUNCTION
'
' #####################
' #####  reflect  #####
' #####################
'
' calculate the reflection vector.
' D. Rogers: "Procedural elements for computer graphics". 5-12. p. 367
'
FUNCTION vector reflect (vector n, vector v1)

  vector v2

	v2 = vsub (v1, svproduct (2.0 * vdot (v1, n), n))
  RETURN v2

END FUNCTION
'
' #######################
' #####  svproduct  #####
' #######################
'
'
'
FUNCTION vector svproduct (DOUBLE k, vector a)

  a.x = a.x * k
  a.y = a.y * k
  a.z = a.z * k

  RETURN a

END FUNCTION


FUNCTION makeObject (type)

' objects[] array index begins at 1

	SHARED object objects[]
	SHARED noo
	
	IF type <= 0 THEN RETURN ($$TRUE)
	
	INC noo
	REDIM objects[noo]
	objects[noo].type = type
	objects[noo].index = noo
	
	RETURN noo

END FUNCTION

FUNCTION setObjectMaterial (index, material m)

	SHARED object objects[]
	
	objects[index].m = m


END FUNCTION
'
'
' ##############################
' #####  setGlobalAmbient  #####
' ##############################
'
'
'
FUNCTION setGlobalAmbient (DOUBLE ambient)

	SHARED DOUBLE gAmbient
	gAmbient = ambient
	
END FUNCTION
'
' ##############################
' #####  getGlobalAmbient  #####
' ##############################
'
'
'
FUNCTION DOUBLE getGlobalAmbient ()

	SHARED DOUBLE gAmbient
	RETURN gAmbient

END FUNCTION
'
'
' ##################
' #####  vadd  #####
' ##################
'
'
'
FUNCTION vector vadd (vector a, vector b)

	vector c
	
  c.x = a.x + b.x
  c.y = a.y + b.y
  c.z = a.z + b.z

  RETURN c
	
END FUNCTION
'
' ##################
' #####  vneg  #####
' ##################
'
'
'
FUNCTION vector vneg (vector a)

	vector b
	
  b.x = -a.x
  b.y = -a.y
  b.z = -a.z

  RETURN b

END FUNCTION
'
' ####################
' #####  vcross  #####
' ####################
'
'
'
FUNCTION vector vcross (vector a, vector b)

  vector c

  c.x = a.y * b.z - b.y * a.z
  c.y = b.x * a.z - a.x * b.z
  c.z = a.x * b.y - b.x * a.y

  RETURN c

END FUNCTION
'
' #############################
' #####  intersectSphere  #####
' #############################
'
'
'
FUNCTION intersectSphere (ray r, index, DOUBLE dist)

	vector v
	SHARED object objects[]
	DOUBLE b, det, radius, i1, i2
	
	v = vsub (r.pos, objects[index].center) 
	b = -vdot (v, r.dir)
	radius = objects[index].radius
	det = (b * b) - vdot(v, v) + (radius * radius)
	retval = $$MISS
	
	IF (det > 0) THEN
		det = sqrt (det)
		i1 = b - det
		i2 = b + det
		IF (i2 > 0) THEN
			IF (i1 < 0) THEN 
				IF (i2 < dist) THEN 
					dist = i2
					retval = $$INPRIM
				END IF
			ELSE
				IF (i1 < dist) THEN
					dist = i1
					retval = $$HIT
				END IF
			END IF
		END IF
	END IF
	RETURN retval

END FUNCTION
'
'
' ######################
' #####  rayTrace  #####
' ######################
'
' the ray-tracing part where depth is recursion level
' returns color c
'
FUNCTION rayTrace (ray r, color c, depth, DOUBLE RIndex, DOUBLE dist)

	vector pi
	SHARED noo
	SHARED object objects[]
	DOUBLE shade
	vector li
	ray r1
	DOUBLE tdist
	vector L, N, V, R, T
	DOUBLE dot
	DOUBLE diff, spec, ambient, refl
	color rcol
	ray rr
	DOUBLE distance
	DOUBLE refr, rindex, n, cosI, cosT2, e
	color absorbance, transparency
	
	IF (depth > $$TRACEDEPTH) THEN RETURN 
	
	' trace primary ray
	dist = $$MAXDIST  ' 1000000.0
	prim = 0

	' find the nearest intersection
	FOR i = 1 TO noo
		res = 0
		SELECT CASE objects[i].type
			CASE $$SPHERE, $$LIGHT : res = intersectSphere (r, i, @dist)
			CASE $$PLANE  				 : res = intersectPlane (r, i, @dist)
		END SELECT

		IF res THEN
			prim = i
			result = res   ' 0 = miss, 1 = hit, -1 = hit from inside primitive
		END IF
	NEXT i

	' no hit, terminate ray
	IF (!prim) THEN RETURN
	
	IF objects[prim].type = $$LIGHT THEN
		' we hit a light, stop tracing
		c = makeColor (1.0, 1.0, 1.0)
	ELSE
		
		' begin with ambient color
		ambient = getGlobalAmbient ()
		IF ambient > 0 THEN
			SELECT CASE objects[prim].type
				CASE $$SPHERE, $$PLANE :
					c.r = objects[prim].m.c.r * ambient
					c.g = objects[prim].m.c.g * ambient
					c.b = objects[prim].m.c.b * ambient
			END SELECT
		END IF
		
		' determine color at point of intersection
		pi = vadd (r.pos, svproduct (dist, r.dir)) 
		
		' trace all lights
		FOR i = 1 TO noo
			
			IF objects[i].type = $$LIGHT THEN

				light = i
				shade = 1.0
				li = objects[i].center

				L = vsub (li, pi)
				tdist = vlength (L)
				
				L = svproduct (1.0/tdist, L)

				r1.pos = vadd (pi, svproduct ($$EPSILON, L))
				r1.dir = L

				FOR s = 1 TO noo
					ret = 0
					
					SELECT CASE objects[s].type
						CASE $$SPHERE, $$LIGHT : ret = intersectSphere (r1, s, tdist)
						CASE $$PLANE  				 : ret = intersectPlane (r1, s, tdist)
					END SELECT
					
					IF ((s != light) && (ret)) THEN
						shade = 0.0
						EXIT FOR
					END IF
				NEXT s

				' calculate diffuse shading
				L = vsub (objects[light].center, pi) 
				L = norm (L)

				' calculate the normal at intersection.  It is just the direction of the radius
				SELECT CASE objects[prim].type
					CASE $$SPHERE, $$LIGHT :
						N = vsub (pi, objects[prim].center)
						N = svproduct (1.0/objects[prim].radius, N)
					CASE $$PLANE :
						N = objects[prim].N
				END SELECT
		
				IF objects[prim].m.diffuse > 0 THEN 
					dot = vdot (L, N)
					IF (dot > 0) THEN
						diff = dot * objects[prim].m.diffuse * shade
						' add diffuse component to ray color
						c.r = c.r + diff * objects[light].m.c.r * objects[prim].m.c.r
						c.g = c.g + diff * objects[light].m.c.g * objects[prim].m.c.g
						c.b = c.b + diff * objects[light].m.c.b * objects[prim].m.c.b
					END IF		
				END IF
	
				' determine specular component
				IF objects[prim].m.specular > 0 THEN 

					' point light source: sample once for specular highlight
					V = r.dir
					R = reflect (N, L)
					dot = vdot (V, R)
					IF (dot > 0) THEN
						spec = pow (dot, objects[prim].m.shine) * objects[prim].m.specular * shade
						' add specular component to ray color
						c.r = c.r + spec * objects[light].m.c.r
						c.g = c.g + spec * objects[light].m.c.g
						c.b = c.b + spec * objects[light].m.c.b
					END IF 
				END IF 
			END IF	
		NEXT i
		
		' calculate reflection
		refl = objects[prim].m.reflection 
		IF (refl > 0.0) THEN

			SELECT CASE objects[prim].type
				CASE $$SPHERE, $$LIGHT :
					N = vsub (pi, objects[prim].center)
					N = svproduct (1.0/objects[prim].radius, N)
				CASE $$PLANE :
					N = objects[prim].N
			END SELECT

			R = reflect (N, r.dir)

			IF (depth < $$TRACEDEPTH) THEN
				rcol = makeColor (0.0, 0.0, 0.0)
				rr.pos = vadd (pi, svproduct ($$EPSILON, R)) 
				rr.dir = R
				distance = 0
				p = rayTrace (rr, @rcol, depth + 1, RIndex, distance)
				c.r = c.r + refl * rcol.r * objects[prim].m.c.r
				c.g = c.g + refl * rcol.g * objects[prim].m.c.g
				c.b = c.b + refl * rcol.b * objects[prim].m.c.b
			END IF
		END IF
		
		' calculate refraction
		refr = objects[prim].m.refraction 
		IF ((refr > 0.0) && (depth < $$TRACEDEPTH)) THEN

			rindex = objects[prim].m.rindex
			IF rindex <= 0.0 THEN rindex = 1.0
			n = RIndex / rindex

			SELECT CASE objects[prim].type
				CASE $$SPHERE, $$LIGHT :
					N = vsub (pi, objects[prim].center)
					N = svproduct (1.0/objects[prim].radius, N)
				CASE $$PLANE :
					N = objects[prim].N
			END SELECT
			
			N = svproduct (DOUBLE(result), N)
			
			cosI = -vdot (N, r.dir)
			cosT2 = 1.0 - n * n * (1.0 - cosI * cosI)
			IF (cosT2 > 0.0) THEN
				T = vadd (svproduct (n, r.dir), svproduct (n * cosI - sqrt(cosT2), N))

				rcol = makeColor (0.0, 0.0, 0.0)
				distance = 0
				rr.pos = vadd (pi, svproduct ($$EPSILON, T))
				rr.dir = T
				rayTrace (rr, @rcol, depth + 1, rindex, @distance)
				
				IF distance < 100.0 THEN 
					' apply Beer's law
					e = 0.15 * (-distance)
					absorbance.r = objects[prim].m.c.r * e
					absorbance.g = objects[prim].m.c.g * e
					absorbance.b = objects[prim].m.c.b * e
					transparency = makeColor (exp (absorbance.r), exp (absorbance.g), exp (absorbance.b))
					c.r = c.r + rcol.r * transparency.r
					c.g = c.g + rcol.g * transparency.g
					c.b = c.b + rcol.b * transparency.b
				END IF
			END IF
		END IF
	END IF
	
	
	RETURN prim

END FUNCTION

FUNCTION color makeColor (DOUBLE r, DOUBLE g, DOUBLE b)

	color c
	c.r = r
	c.g = g
	c.b = b
	RETURN c

END FUNCTION

FUNCTION DOUBLE vlength (vector a)

	RETURN sqrt (a.x*a.x + a.y*a.y + a.z*a.z)

END FUNCTION
'
' ############################
' #####  intersectPlane  #####
' ############################
'
'
'
FUNCTION intersectPlane (ray r, index, DOUBLE dist)

	DOUBLE d, newDist
	SHARED object objects[]

	d = vdot (objects[index].N, r.dir)
	IF (d != 0.0) THEN 
		newDist = -(vdot (objects[index].N, r.pos) + objects[index].D) / d
		IF (newDist > 0) THEN
			IF (newDist < dist) THEN 
				dist = newDist
				RETURN ($$HIT)
			END IF
		END IF
	END IF
	RETURN ($$MISS)

END FUNCTION
'
' #######################
' #####  makePlane  #####
' #######################
'
'
'
FUNCTION makePlane (DOUBLE x, DOUBLE y, DOUBLE z, DOUBLE d)

	SHARED object objects[]
	
	index = makeObject ($$PLANE)
	
  objects[index].N = makePoint(x, y, z)   ' plane N
  objects[index].D = d   									' plane D

  RETURN index

END FUNCTION
'
' #############################
' #####  printRenderTime  #####
' #############################
'
'
'
FUNCTION PrintRenderTime (time)

	t$ = "00:00.000"
	t${6} = ASC (STRING$ ((time / 100) MOD 10))
	t${7} = ASC (STRING$ ((time / 10) MOD 10))
	t${8} = ASC (STRING$ ((time MOD 10)))
	secs = (time / 1000) MOD 60
	mins = (time / 60000) MOD 100
	t${3} = ASC (STRING$ (((secs / 10) MOD 10)))
	t${4} = ASC (STRING$ ((secs MOD 10)))
	t${1} = ASC (STRING$ ((mins MOD 10)))
	t${0} = ASC (STRING$ (((mins / 10) MOD 10)))
	
'	PRINT "Render Time: "; t$

	glColor3f (1.0, 0.4, 0.4)						' set color to red
	text$ = "Render Time " + t$
	glPrint (20, 30, 0, 1, &text$)
	
END FUNCTION
'
' ##########################
' #####  centerWindow  #####
' ##########################
'
'
'
FUNCTION CenterWindow ()
	
	RECT rc

	hWnd = GetDesktopWindow ()
	GetWindowRect (hWnd, &rc)

	width = 0
	height = 0
	glfwGetWindowSize (&width, &height)
	
	x = rc.right/2 - width/2
	y = rc.bottom/2 - height/2
	
	glfwSetWindowPos (x, y)
	glClearColor (0.0, 0.0, 0.0, 1.0) 
	glClear ($$GL_COLOR_BUFFER_BIT)
	glfwSwapBuffers ()

END FUNCTION

FUNCTION setObjectRefraction (index, DOUBLE refraction, DOUBLE rindex)

	SHARED object objects[]
	
	objects[index].m.refraction = refraction
	objects[index].m.rindex = rindex


END FUNCTION

END PROGRAM