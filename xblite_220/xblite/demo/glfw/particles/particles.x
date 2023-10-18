' ========================================================================
' Based on the original particles demo as part of the glfw source package
' 
' XBLite\XBasic port and (and somewhat of a rewrite) by Michael McElligott  12/12/02 2002
' Mapei_@hotmail.com
' ========================================================================

IMPORT "glfw"
IMPORT "opengl32"
IMPORT "glu32"
IMPORT "msvcrt"

TYPE VEC
	SINGLE .x
	SINGLE .y
	SINGLE .z
END TYPE

TYPE VERTEX
	SINGLE .s
	SINGLE .t		'  Texture coordinates
	UBYTE .r
	UBYTE .g
	UBYTE .b
	UBYTE .a		'  Color (four ubytes packed into an uint)
	SINGLE .x
	SINGLE .y
	SINGLE .z		'  Vertex coordinates
END TYPE

TYPE GLFWcond = XLONG
TYPE GLFWmutex = XLONG

TYPE thread_sync
	DOUBLE .t		'  Time (s)
	SINGLE .dt		'  Time since last frame (s)
	XLONG .p_frame		'  Particle physics frame number
	XLONG .d_frame		'  Particle draw frame number
	GLFWcond .p_done		'  Condition: particle physics done
	GLFWcond .d_done		'  Condition: particle draw done
	GLFWmutex .particles_lock		'  Particles data sharing mutex
END TYPE

TYPE PARTICLE
	SINGLE .x		'  Position in space
	SINGLE .y
	SINGLE .z
	SINGLE .vx
	SINGLE .vy
	SINGLE .vz		'  Velocity vector
	SINGLE .r
	SINGLE .g
	SINGLE .b		'  Color of particle
	SINGLE .life		'  Life of particle (1.0 = newborn, < 0.0 = dead)
	UBYTE .active		'  Tells if this particle is active
END TYPE

DECLARE FUNCTION Main ()
DECLARE FUNCTION Render (DOUBLE t)
DECLARE FUNCTION Resize (w, h)
DECLARE FUNCTION Init ()
DECLARE FUNCTION Create ()
DECLARE FUNCTION LoadTextures ()
DECLARE FUNCTION key (k, action)
DECLARE CFUNCTION MousePos (x, y)
DECLARE FUNCTION MouseButton (button, state)
DECLARE FUNCTION FillArray4b (array, v1, v2, v3, v4)
DECLARE FUNCTION FillArray8 (array, v1, v2, v3, v4, v5, v6, v7, v8)
DECLARE FUNCTION FillArray4 (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)
DECLARE FUNCTION FillArray8b (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4, SINGLE v5, SINGLE v6, SINGLE v7, SINGLE v8)
DECLARE FUNCTION FillArray16 (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16)

DECLARE FUNCTION InitParticle (i, DOUBLE t)
DECLARE FUNCTION UpdateParticle (particle, SINGLE dt)
DECLARE FUNCTION ParticleEngine (DOUBLE t, SINGLE dt)
DECLARE FUNCTION DrawParticles (DOUBLE t, SINGLE dt)
DECLARE FUNCTION DrawFountain ()
DECLARE FUNCTION TesselateFloor (SINGLE x1, SINGLE y1, SINGLE x2, SINGLE y2, recursion)
DECLARE FUNCTION DrawFloor ()
DECLARE FUNCTION SetupLights ()


$$GL_LIGHT_MODEL_COLOR_CONTROL_EXT = 0x81F8
$$GL_SEPARATE_SPECULAR_COLOR_EXT = 0x81FA


$$P_TEX_WIDTH = 8		'  Particle texture dimensions
$$P_TEX_HEIGHT = 8
$$F_TEX_WIDTH = 16		'  Floor texture dimensions
$$F_TEX_HEIGHT = 16

' Life span of a particle (in seconds)
$$LIFE_SPAN = 5.0

' Particle size (meters)
$$PARTICLE_SIZE = 0.6

' Gravitational constant (m/s^2)
$$GRAVITY = 9.8

' Base initial velocity (m/s)
$$VELOCITY = 8.0

' Bounce friction (1.0 = no friction, 0.0 = maximum friction)
$$FRICTION = 0.75

' "Fountain" height (m)
$$FOUNTAIN_HEIGHT = 3.0

' Fountain radius (m)
$$FOUNTAIN_RADIUS = 1.6
$$FOUNTAIN_SIDE_POINTS = 16
$$FOUNTAIN_SWEEP_STEPS = 32

$$BATCH_PARTICLES = 100		'  Number of particles to draw in each batch (70 corresponds to 7.5 KB = will not blow
' the L1 data cache on most CPUs)
$$PARTICLE_VERTS = 4		'  Number of vertices per particle


FUNCTION Main ()
	STATIC DOUBLE t0, t, t1, t2, time
	STATIC XLONG frames

	' XstCreateConsole ("Console", 50, @hStdOut, @hStdIn, @hConWnd)

	Create ()
	Init ()

	event = 1
	frames = 0
	t0 = glfwGetTime ()
	DO

		time = glfwGetTime ()
		t = DOUBLE (time - t0)
		Render (t)

		glfwSwapBuffers ()
		INC frames

		IF ((glfwGetKey ( 'Q') = 1) || glfwGetWindowParam ($$GLFW_OPENED) = 0) THEN event = 0


		t2 = DOUBLE (time - t1)
		IF t2 > 1 THEN
			title$ = "XBlite Particles: " + STRING$ (#MAX_PARTICLES) + " fps: " + STRING$ (frames)
			glfwSetWindowTitle (&title$)
			frames = 0
			t1 = time
		END IF

	LOOP WHILE event = 1

	glfwTerminate ()
	' XstFreeConsole ()

END FUNCTION


FUNCTION Create ()

	' Init GLFW and open window
	glfwInit ()
	IFZ glfwOpenWindow (600, 400, 8, 8, 8, 8, 16, 8, $$GLFW_WINDOW) THEN
		glfwTerminate ()
		RETURN 0
	END IF

	glfwSetWindowTitle (&"XBlite")
	glfwSetWindowSizeCallback (&Resize ())
	glfwSetKeyCallback (&key ())
	glfwSetMousePosCallback (&MousePos ())
	glfwSetMouseButtonCallback (&MouseButton ())
	glfwSwapInterval (1)

	glfwEnable ($$GLFW_KEY_REPEAT)
	#vsync = 1

END FUNCTION

FUNCTION key (k, action)
	SHARED wireframe 
	SHARED SINGLE fog
	SHARED PARTICLE p_new[]


	IF (action! = $$GLFW_PRESS) THEN RETURN

	SELECT CASE k

		CASE 'A' :
			#MAX_PARTICLES = #MAX_PARTICLES + 150
			#BIRTH_INTERVAL! = ($$LIFE_SPAN / SINGLE (#MAX_PARTICLES))
			#MIN_DELTA_T! = (#BIRTH_INTERVAL! / 2)
			REDIM p_new[#MAX_PARTICLES]

		CASE 'Z' :
			#MAX_PARTICLES = #MAX_PARTICLES - 150
			IF #MAX_PARTICLES < 150 THEN #MAX_PARTICLES = 150
			#BIRTH_INTERVAL! = ($$LIFE_SPAN / SINGLE (#MAX_PARTICLES))
			#MIN_DELTA_T! = (#BIRTH_INTERVAL! / 2)
			REDIM p_new[#MAX_PARTICLES]

		CASE ' ' :
			DIM p_new[#MAX_PARTICLES]
		CASE 'W' :
			IF wireframe = 1 THEN
				wireframe = 0
				glPolygonMode ($$GL_FRONT_AND_BACK, $$GL_FILL)
			ELSE
				wireframe = 1
				glPolygonMode ($$GL_FRONT_AND_BACK, $$GL_LINE)
			END IF
		CASE 'F' :
			IF fog = 1 THEN fog = 0 ELSE fog = 1

		CASE 'V' :
			IF #vsync = 1 THEN
				glfwSwapInterval (0)
				#vsync = 0
			ELSE
				glfwSwapInterval (1)
				#vsync = 1
			END IF

	END SELECT


END FUNCTION

CFUNCTION MousePos (x, y)
SHARED mButton, mLeft, mRight
SHARED mx, my, mOldY, mOldX
SHARED SINGLE zoom

mx = x
my = y
IF mButton = mRight THEN

	zoom = zoom - ((mOldY - my) * 180.0) / 200.0

END IF

mOldX = mx
mOldY = my

END FUNCTION

FUNCTION MouseButton (button, state)
	SHARED mButton, mLeft, mRight

	IF (state == $$GLFW_PRESS) THEN

		SELECT CASE button
			CASE $$GLFW_MOUSE_BUTTON_RIGHT: mButton = mRight
		END SELECT

	ELSE
		IF (state == $$GLFW_RELEASE) THEN mButton = 0
	END IF

END FUNCTION


FUNCTION Render (DOUBLE t)
	DOUBLE xpos, ypos, zpos, angle_x, angle_y, angle_z
	SHARED SINGLE fog_color[], fog, zoom
	STATIC DOUBLE t_old
	SINGLE dt
	SHARED my, mx


	' Calculate frame-to-frame delta time
	dt = SINGLE (t - t_old)
	t_old = t

	' Setup viewport
	' glViewport( 0, 0, #Width, #Height )

	' Clear color and Z-buffer
	glClearColor (0.1, 0.1, 0.1, 1.0)
	glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)

	' Setup projection
	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity ()
	gluPerspective (65, DOUBLE (#Width) / DOUBLE (#Height), 1.0, 60.0)

	' Setup camera
	glMatrixMode ($$GL_MODELVIEW)
	glLoadIdentity ()

	' Rotate camera
	angle_x = 90.0 - 10.0
	angle_y = 10.0 * sin (0.3 * t)
	angle_z = 10.0 * t
	glRotated (-angle_x,1.0, 0.0, 0.0)
	glRotated (-angle_y, 0.0, 1.0, 0.0)
	glRotated (-angle_z, 0.0, 0.0, 1.0)

	' Translate camera
	xpos = 15.0 * sin (($$M_PI / 180.0) * angle_z) + 2.0 * sin (($$M_PI / 180.0) * 3.1 * t)
	ypos = - 15.0 * cos (($$M_PI / 180.0) * angle_z) + 2.0 * cos (($$M_PI / 180.0) * 2.9 * t)
	zpos = 4.0 + 2.0 * cos (($$M_PI / 180.0) * 4.9 * t)
	glTranslated (-xpos, - ypos + zoom, - zpos)


	IF #freelook = 1 THEN
		glRotatef (SINGLE (mx - (#Width / 2)), 0.0, 1.0, 0.0)		'	Use Mouse to control
		glRotatef (SINGLE (my - (#Height / 2)), 1.0, 0.0, 0.0)
	END IF

	' Enable face culling
	glFrontFace ($$GL_CCW)
	glCullFace ($$GL_BACK)
	glEnable ($$GL_CULL_FACE)

	' Enable lighting
	SetupLights ()
	glEnable ($$GL_LIGHTING)

	' Enable fog (dim details far away)
	IF fog = 1 THEN
		glEnable ($$GL_FOG)
		glFogi ($$GL_FOG_MODE, $$GL_EXP)
		glFogf ($$GL_FOG_DENSITY, 0.05)
		glFogfv ($$GL_FOG_COLOR, &fog_color[])
	END IF

	' Draw floor
	DrawFloor ()

	' Enable Z-buffering
	glEnable ($$GL_DEPTH_TEST)
	glDepthFunc ($$GL_LEQUAL)
	glDepthMask ($$GL_TRUE)

	' Draw fountain
	DrawFountain ()

	' Disable fog & lighting
	glDisable ($$GL_LIGHTING)
	glDisable ($$GL_FOG)

	' Draw all particles (must be drawn after all solid objects have been drawn!)
	DrawParticles (t, dt)

	' Z-buffer not needed anymore
	glDisable ($$GL_DEPTH_TEST)

END FUNCTION


FUNCTION InitParticle (i, DOUBLE t)
	SHARED SINGLE glow_pos[], glow_color[]
	SINGLE xy_angle, velocity
	SHARED PARTICLE p_new[], p_old[]
	STATIC SINGLE lt

	' Start position of particle is at the fountain blow-out
	p_new[i].x = 0.0
	p_new[i].y = 0.0
	p_new[i].z = $$FOUNTAIN_HEIGHT

	' Start velocity is up (Z)...
	p_new[i].vz = 0.7 + (0.3 / 4096.0) * SINGLE (rand () & 4095)

	' ...and a randomly chosen X/Y direction
	xy_angle = (2.0 * $$M_PI / 4096.0) * SINGLE (rand () & 4095)
	p_new[i].vx = 0.4 * SINGLE (cos (xy_angle))
	p_new[i].vy = 0.4 * SINGLE (sin (xy_angle))

	' Scale velocity vector according to a time-varying velocity
	velocity = $$VELOCITY * (0.8 + 0.1 * SINGLE (sin (0.5 * t) + sin (1.31 * t)))
	p_new[i].vx = p_new[i].vx * velocity
	p_new[i].vy = p_new[i].vy * velocity
	p_new[i].vz = p_new[i].vz * velocity

	' Color is time-varying
	p_new[i].r = 0.7 + 0.3 * SINGLE (sin (0.34 * t + 0.1))
	p_new[i].g = 0.6 + 0.4 * SINGLE (sin (0.63 * t + 1.1))
	p_new[i].b = 0.6 + 0.4 * SINGLE (sin (0.91 * t + 2.1))

	' Store settings for fountain glow lighting
	glow_pos[0] = 0.4 * SINGLE (sin (1.34 * t))
	glow_pos[1] = 0.4 * SINGLE (sin (3.11 * t))
	glow_pos[2] = $$FOUNTAIN_HEIGHT + 1.0
	glow_pos[3] = 1.0
	glow_color[0] = p_new[i].r
	glow_color[1] = p_new[i].g
	glow_color[2] = p_new[i].b
	glow_color[3] = 1.0

	' The particle is new-born and active
	IF lt < $$LIFE_SPAN THEN
		lt = lt + 0.0005
	ELSE
		lt = 0.005
	END IF

	p_new[i].life = lt
	p_new[i].active = 1


END FUNCTION


FUNCTION UpdateParticle (i, SINGLE dt)
	SHARED PARTICLE p_new[]

	IF (p_new[i].active = 0) THEN
		RETURN
	END IF

	' The particle is getting older...
	p_new[i].life = p_new[i].life - dt * (SINGLE (1.0) / $$LIFE_SPAN)

	' Did the particle die?
	IF (p_new[i].life <= 0.0) THEN
		p_new[i].active = 0
		RETURN
	END IF

	' Update particle velocity (apply gravity)
	p_new[i].vz = p_new[i].vz - $$GRAVITY * dt

	' Update particle position
	p_new[i].x = p_new[i].x + p_new[i].vx * dt
	p_new[i].y = p_new[i].y + p_new[i].vy * dt
	p_new[i].z = p_new[i].z + p_new[i].vz * dt


	' Simple collision detection + response
	IF (p_new[i].vz < 0.0)

	' Particles should bounce on the fountain (with friction)
	IF (((p_new[i].x * p_new[i].x + p_new[i].y * p_new[i].y) < #FOUNTAIN_R2!) && (p_new[i].z < ($$FOUNTAIN_HEIGHT + $$PARTICLE_SIZE / 2))) THEN
		p_new[i].vz = - $$FRICTION * p_new[i].vz
		p_new[i].z = $$FOUNTAIN_HEIGHT + ($$PARTICLE_SIZE / 2) + $$FRICTION * ($$FOUNTAIN_HEIGHT + $$PARTICLE_SIZE / 2 - p_new[i].z)

		' Particles should bounce on the floor (with friction)
	ELSE
		IF (p_new[i].z < ($$PARTICLE_SIZE / 2))
		p_new[i].vz = - $$FRICTION * p_new[i].vz
		p_new[i].z = ($$PARTICLE_SIZE / 2) + $$FRICTION * (($$PARTICLE_SIZE / 2) - p_new[i].z)

	END IF
END IF

END IF


END FUNCTION


FUNCTION ParticleEngine (DOUBLE t, SINGLE dt)
	SHARED PARTICLE p_new[]
	SHARED SINGLE min_age
	SINGLE dt2


	' Update particles (iterated several times per frame if dt is too large)

	DO WHILE (dt > 0.0)

		' Calculate delta time for this iteration
		IF dt < #MIN_DELTA_T! THEN dt2 = dt : ELSE dt2 = #MIN_DELTA_T!

		' Update particles
		FOR i = 0 TO #MAX_PARTICLES
			UpdateParticle (i, dt2)
		NEXT i

		' Increase minimum age
		min_age = min_age + dt2

		' Should we create any new particle(s)?
		DO WHILE (min_age >= #BIRTH_INTERVAL!)

			min_age = min_age - #BIRTH_INTERVAL!

			' Find a dead particle to replace with a new one
			FOR i = 0 TO #MAX_PARTICLES

				IF (p_new[i].active = 0) THEN
					InitParticle (i, t + min_age)
					UpdateParticle (i, min_age)
				END IF

			NEXT i
		LOOP

		' Decrease frame delta time
		dt = dt - dt2
	LOOP

END FUNCTION

FUNCTION DrawParticles (DOUBLE t, SINGLE dt)
	SHARED PARTICLE p_new[]
	SHARED particle_tex_id
	SHARED VERTEX vertex_array[]
	SHARED wireframe
	SINGLE alpha
	STATIC VEC quad_lower_left, quad_lower_right
	SHARED SINGLE mat[]
	UBYTE r, g, b, a




	' Here comes the real trick with flat single primitive objects (s.c.
	' "billboards"): We must rotate the textured primitive so that it
	' always faces the viewer (is coplanar with the view-plane).
	' We:
	' 1) Create the primitive around origo (0,0,0)
	' 2) Rotate it so that it is coplanar with the view plane
	' 3) Translate it according to the particle position
	' Note that 1) and 2) is the same for all particles (done only once).

	' Get modelview matrix. We will only use the upper left 3x3 part of
	' the matrix, which represents the rotation.
	glGetFloatv ($$GL_MODELVIEW_MATRIX, &mat[])

	' 1) & 2) We do it in one swift step:
	' Although not obvious, the following six lines represent two matrix/
	' vector multiplications. The matrix is the inverse 3x3 rotation
	' matrix (i.e. the transpose of the same matrix), and the two vectors
	' represent the lower left corner of the quad,  $$PARTICLE_SIZE / 2 *
	' (-1,-1,0), and the lower right corner,  $$PARTICLE_SIZE / 2 * (1,-1,0).
	' The upper left/right corners of the quad is always the negative of
	' the opposite corners (regardless of rotation).
	quad_lower_left.x = (-$$PARTICLE_SIZE / 2 * (mat[0] + mat[1]))
	quad_lower_left.y = (-$$PARTICLE_SIZE / 2 * (mat[4] + mat[5]))
	quad_lower_left.z = (-$$PARTICLE_SIZE / 2 * (mat[8] + mat[9]))
	quad_lower_right.x = ($$PARTICLE_SIZE / 2 * (mat[0] - mat[1]))
	quad_lower_right.y = ($$PARTICLE_SIZE / 2 * (mat[4] - mat[5]))
	quad_lower_right.z = ($$PARTICLE_SIZE / 2 * (mat[8] - mat[9]))

	' Don't update z-buffer, since all particles are transparent!
	glDepthMask ($$GL_FALSE)

	' Enable blending
	glEnable ($$GL_BLEND)
	glBlendFunc ($$GL_SRC_ALPHA, $$GL_ONE)

	' Select particle texture
	IF (wireframe = 0) THEN

		glEnable ($$GL_TEXTURE_2D)
		glBindTexture ($$GL_TEXTURE_2D, particle_tex_id)
	END IF

	' Set up vertex arrays. We use interleaved arrays, which is easier to
	' handle (in most situations) and it gives a linear memeory access
	' access pattern (which may give better performance in some
	' situations). $$GL_T2F_C4UB_V3F means: 2 floats for texture coords,
	' 4 ubytes for color and 3 floats for vertex coord (in that order).
	' Most OpenGL cards / drivers are optimized for this format.
	glInterleavedArrays ($$GL_T2F_C4UB_V3F, 0, &vertex_array[])

	' Perform particle physics in this thread
	ParticleEngine (t, dt)


	' Loop through all particles and build vertex arrays.
	particle_count = 0
	vert_count = 0

	FOR i = 0 TO #MAX_PARTICLES		'( i = 0 i < #MAX_PARTICLES i ++ )


		IF (p_new[i].active = 1) THEN


			' Calculate particle intensity (we set it to max during 75%
			' of its life, then it fades out)
			alpha = 4.0 * p_new[i].life
			IF (alpha > 1.0) THEN
				alpha = 1
			END IF

			' 3) Translate the quad to the correct position in modelview
			' space and store its parameters in vertex arrays (we also
			' store texture coord and color information for each vertex).

			r = UBYTE (p_new[i].r * 255.0)
			g = UBYTE (p_new[i].g * 255.0)
			b = UBYTE (p_new[i].b * 255.0)
			a = alpha * 255.0

			' Lower left corner
			vertex_array[vert_count].s = 0.0
			vertex_array[vert_count].t = 0.0
			vertex_array[vert_count].r = r
			vertex_array[vert_count].g = g
			vertex_array[vert_count].b = b
			vertex_array[vert_count].a = a
			vertex_array[vert_count].x = p_new[i].x + quad_lower_left.x
			vertex_array[vert_count].y = p_new[i].y + quad_lower_left.y
			vertex_array[vert_count].z = p_new[i].z + quad_lower_left.z
			INC vert_count

			' Lower right corner
			vertex_array[vert_count].s = 1.0
			vertex_array[vert_count].t = 0.0
			vertex_array[vert_count].r = r
			vertex_array[vert_count].g = g
			vertex_array[vert_count].b = b
			vertex_array[vert_count].a = a
			vertex_array[vert_count].x = p_new[i].x + quad_lower_right.x
			vertex_array[vert_count].y = p_new[i].y + quad_lower_right.y
			vertex_array[vert_count].z = p_new[i].z + quad_lower_right.z
			INC vert_count

			' Upper right corner
			vertex_array[vert_count].s = 1.0
			vertex_array[vert_count].t = 1.0
			vertex_array[vert_count].r = r
			vertex_array[vert_count].g = g
			vertex_array[vert_count].b = b
			vertex_array[vert_count].a = a
			vertex_array[vert_count].x = p_new[i].x - quad_lower_left.x
			vertex_array[vert_count].y = p_new[i].y - quad_lower_left.y
			vertex_array[vert_count].z = p_new[i].z - quad_lower_left.z
			INC vert_count

			' Upper left corner
			vertex_array[vert_count].s = 0.0
			vertex_array[vert_count].t = 1.0
			vertex_array[vert_count].r = r
			vertex_array[vert_count].g = g
			vertex_array[vert_count].b = b
			vertex_array[vert_count].a = a
			vertex_array[vert_count].x = p_new[i].x - quad_lower_right.x
			vertex_array[vert_count].y = p_new[i].y - quad_lower_right.y
			vertex_array[vert_count].z = p_new[i].z - quad_lower_right.z
			INC vert_count

			' Increase count of drawable particles
			INC particle_count
		END IF

		' If we have filled up one batch of particles, draw it as a set
		' of quads using glDrawArrays.
		IF (particle_count >= $$BATCH_PARTICLES) THEN

			' The first argument tells which primitive type we use (QUAD)
			' The second argument tells the index of the first vertex (0)
			' The last argument is the vertex count
			glDrawArrays ($$GL_QUADS, 0, ($$PARTICLE_VERTS * particle_count))
			particle_count = 0
			vert_count = 0

		END IF

	NEXT i		'  Next particle


	' Draw final batch of particles (if any)
	glDrawArrays ($$GL_QUADS, 0, $$PARTICLE_VERTS * particle_count)
	glFlush ()

	' Disable vertex arrays (Note: glInterleavedArrays implicitly called
	' glEnableClientState for vertex, texture coord and color arrays)
	glDisableClientState ($$GL_VERTEX_ARRAY)
	glDisableClientState ($$GL_TEXTURE_COORD_ARRAY)
	glDisableClientState ($$GL_COLOR_ARRAY)

	' Disable texturing and blending
	glDisable ($$GL_TEXTURE_2D)
	glDisable ($$GL_BLEND)

	' Allow Z-buffer updates again
	glDepthMask ($$GL_TRUE)


END FUNCTION

FUNCTION DrawFountain ()
	SHARED SINGLE fountain_diffuse[], fountain_specular[]
	SHARED SINGLE fountain_shininess
	SHARED SINGLE fountain_side[], fountain_normal[]
	STATIC fountain_list
	DOUBLE angle
	SINGLE x, y
	SHARED floor_tex_id


	' The first time, we build the fountain display list
	IFZ (fountain_list) THEN

		' Start recording of a new display list
		fountain_list = glGenLists (1)
		glNewList (fountain_list, $$GL_COMPILE_AND_EXECUTE)

		' Set fountain material

		' glBindTexture($$GL_TEXTURE_2D, floor_tex_id)

		glMaterialfv ($$GL_FRONT, $$GL_DIFFUSE, &fountain_diffuse[])
		glMaterialfv ($$GL_FRONT, $$GL_SPECULAR, &fountain_specular[])
		glMaterialf ($$GL_FRONT, $$GL_SHININESS, fountain_shininess)

		' Build fountain using triangle strips
		FOR n = 0 TO $$FOUNTAIN_SIDE_POINTS - 1

			glBegin ($$GL_TRIANGLE_STRIP)
			FOR m = 0 TO $$FOUNTAIN_SWEEP_STEPS

				angle = DOUBLE (m * (2.0 * $$M_PI / DOUBLE ($$FOUNTAIN_SWEEP_STEPS)))
				x = SINGLE (cos (angle))
				y = SINGLE (sin (angle))

				' Draw triangle strip
				glNormal3f (x * fountain_normal[ (n * 2) + 2], y * fountain_normal[ (n * 2) + 2], fountain_normal[ (n * 2) + 3])
				glVertex3f (x * fountain_side[ (n * 2) + 2], y * fountain_side[ (n * 2) + 2], fountain_side[ (n * 2) + 3])
				glNormal3f (x * fountain_normal[n * 2], y * fountain_normal[n * 2], fountain_normal[ (n * 2) + 1])
				glVertex3f (x * fountain_side[n * 2], y * fountain_side[n * 2], fountain_side[ (n * 2) + 1])

			NEXT m
			glEnd ()
		NEXT n

		' End recording of display list
		glEndList ()

	ELSE

		' Playback display list
		glCallList (fountain_list)
	END IF


END FUNCTION

FUNCTION TesselateFloor (SINGLE x1, SINGLE y1, SINGLE x2, SINGLE y2, recursion)
	SINGLE delta, x, y

	' Last recursion?
	IF (recursion >= 5) THEN
		delta = 999999.0
	ELSE
		IF fabs (x1) < fabs (x2) THEN x = fabs (x1) ELSE x = fabs (x2)
		IF fabs (y1) < fabs (y2) THEN y = fabs (y1) ELSE y = fabs (y2)
		delta = x * x + y * y
	END IF

	' Recurse further?
	IF (delta < 0.1) THEN

		x = (x1 + x2) * 0.5
		y = (y1 + y2) * 0.5
		TesselateFloor (x1, y1, x, y, recursion + 1)
		TesselateFloor (x, y1, x2, y, recursion + 1)
		TesselateFloor (x1, y, x, y2, recursion + 1)
		TesselateFloor (x, y, x2, y2, recursion + 1)

	ELSE

		glTexCoord2f (x1 * 30.0, y1 * 30.0)
		glVertex3f (x1 * 80.0, y1 * 80.0, 0.0)
		glTexCoord2f (x2 * 30.0, y1 * 30.0)
		glVertex3f (x2 * 80.0, y1 * 80.0, 0.0)
		glTexCoord2f (x2 * 30.0, y2 * 30.0)
		glVertex3f (x2 * 80.0, y2 * 80.0, 0.0)
		glTexCoord2f (x1 * 30.0, y2 * 30.0)
		glVertex3f (x1 * 80.0, y2 * 80.0, 0.0)
	END IF

END FUNCTION

FUNCTION DrawFloor ()
	SHARED particle_tex_id, floor_tex_id
	SHARED SINGLE floor_diffuse[], floor_specular[], fog_color[]
	SHARED SINGLE floor_shininess
	STATIC floor_list
	SHARED wireframe

	' Select floor texture
	IF (wireframe = 0) THEN

		glEnable ($$GL_TEXTURE_2D)
		glBindTexture ($$GL_TEXTURE_2D, floor_tex_id)

	END IF

	' The first time, we build the floor display list
	IFZ (floor_list) THEN

		' Start recording of a new display list
		floor_list = glGenLists (1)
		glNewList (floor_list, $$GL_COMPILE_AND_EXECUTE)

		' Set floor material
		glMaterialfv ($$GL_FRONT, $$GL_DIFFUSE, &floor_diffuse[])
		glMaterialfv ($$GL_FRONT, $$GL_SPECULAR, &floor_specular[])
		glMaterialf ($$GL_FRONT, $$GL_SHININESS, floor_shininess)



		' Draw floor as a bunch of triangle strips (high tesselation
		' improves lighting)
		glNormal3f (0.0, 0.0, 1.0)
		glBegin ($$GL_QUADS)
		TesselateFloor (- 1.0, - 1.0, 0.0, 0.0, 0)
		TesselateFloor (0.0, - 1.0, 1.0, 0.0, 0)
		TesselateFloor (0.0, 0.0, 1.0, 1.0, 0)
		TesselateFloor (- 1.0, 0.0, 0.0, 1.0, 0)
		glEnd ()

		' End recording of display list
		glEndList ()

	ELSE

		' Playback display list
		glCallList (floor_list)
	END IF

	glDisable ($$GL_TEXTURE_2D)


END FUNCTION

FUNCTION SetupLights ()
	SHARED SINGLE glow_color[], glow_pos[]
	SINGLE l1pos[], l1amb[], l1dif[], l1spec[]
	SINGLE l2pos[], l2amb[], l2dif[], l2spec[]

	DIM l1pos[3]
	DIM l1amb[3]
	DIM l1dif[3]
	DIM l1spec[3]
	DIM l2pos[3]
	DIM l2amb[3]
	DIM l2dif[3]
	DIM l2spec[3]

	' Set light source 1 parameters
	l1pos[0] = 0.0: l1pos[1] = - 9.0: l1pos[2] = 8.0: l1pos[3] = 1.0
	l1amb[0] = 0.2: l1amb[1] = 0.2: l1amb[2] = 0.2: l1amb[3] = 1.0
	l1dif[0] = 0.8: l1dif[1] = 0.4: l1dif[2] = 0.2: l1dif[3] = 1.0
	l1spec[0] = 1.0: l1spec[1] = 0.6: l1spec[2] = 0.2: l1spec[3] = 0.0

	' Set light source 2 parameters
	l2pos[0] = - 15.0: l2pos[1] = 12.0: l2pos[2] = 1.5: l2pos[3] = 1.0
	l2amb[0] = 0.0: l2amb[1] = 0.0: l2amb[2] = 0.0: l2amb[3] = 1.0
	l2dif[0] = 0.2: l2dif[1] = 0.4: l2dif[2] = 0.8: l2dif[3] = 1.0
	l2spec[0] = 0.2: l2spec[1] = 0.6: l2spec[2] = 1.0: l2spec[3] = 0.0

	' Configure light sources in OpenGL
	glLightfv ($$GL_LIGHT1, $$GL_POSITION, &l1pos[])
	glLightfv ($$GL_LIGHT1, $$GL_AMBIENT, &l1amb[])
	glLightfv ($$GL_LIGHT1, $$GL_DIFFUSE, &l1dif[])
	glLightfv ($$GL_LIGHT1, $$GL_SPECULAR, &l1spec[])
	glLightfv ($$GL_LIGHT2, $$GL_POSITION, &l2pos[])
	glLightfv ($$GL_LIGHT2, $$GL_AMBIENT, &l2amb[])
	glLightfv ($$GL_LIGHT2, $$GL_DIFFUSE, &l2dif[])
	glLightfv ($$GL_LIGHT2, $$GL_SPECULAR, &l2spec[])
	glLightfv ($$GL_LIGHT3, $$GL_POSITION, &glow_pos[])
	glLightfv ($$GL_LIGHT3, $$GL_DIFFUSE, &glow_color[])
	glLightfv ($$GL_LIGHT3, $$GL_SPECULAR, &glow_color[])

	' Enable light sources
	glEnable ($$GL_LIGHT1)
	glEnable ($$GL_LIGHT2)
	glEnable ($$GL_LIGHT3)

END FUNCTION


FUNCTION Init ()
	SHARED particle_tex_id, floor_tex_id
	SHARED PARTICLE p_new[]
	SHARED VERTEX vertex_array[]
	SHARED SINGLE fountain_diffuse[], fountain_specular[], floor_diffuse[], floor_specular[], fog_color[]
	SHARED SINGLE fountain_shininess, floor_shininess
	SHARED SINGLE min_age, glow_color[], glow_pos[]
	SHARED SINGLE fountain_side[], fountain_normal[]
	SHARED UBYTE particle_texture[], floor_texture[]
	SHARED SINGLE mat[], zoom
	SHARED wireframe
	SHARED SINGLE fog
	SHARED mButton, mLeft, mRight


	#MAX_PARTICLES = 1000
	#BIRTH_INTERVAL! = ($$LIFE_SPAN / SINGLE (#MAX_PARTICLES))		'  A new particle is born every [BIRTH_INTERVAL] second
	#MIN_DELTA_T! = (#BIRTH_INTERVAL! / 2)		'  Minimum delta-time for particle phisics (s)
	#FOUNTAIN_R2! = SINGLE ($$FOUNTAIN_RADIUS + $$PARTICLE_SIZE / 2) * ($$FOUNTAIN_RADIUS + $$PARTICLE_SIZE / 2)

	min_age = 0.10		'  Global variable holding the age of the youngest particle
	wireframe = 0
	floor_shininess = 18.0
	fountain_shininess = 12.0
	fog = 1
	mButton = 0
	mLeft = 1
	mRight = 2
	zoom = 0.0

	DIM p_new[#MAX_PARTICLES]
	DIM mat[15]
	DIM vertex_array[$$BATCH_PARTICLES * $$PARTICLE_VERTS]
	DIM fountain_diffuse[3]
	DIM fountain_specular[3]
	DIM floor_diffuse[3]
	DIM floor_specular[3]
	DIM fog_color[3]
	DIM glow_color[3]		'  Color of latest born particle (used for fountain lighting)
	DIM glow_pos[3]		'  Position of latest born particle (used for fountain lighting)
	DIM fountain_side[$$FOUNTAIN_SIDE_POINTS * 2]
	DIM fountain_normal[$$FOUNTAIN_SIDE_POINTS * 2]

	FillArray4 (&fountain_diffuse[], 0.7, 1.0, 1.0, 1.0)
	FillArray4 (&fountain_specular[], 1.0, 1.0, 1.0, 1.0)
	FillArray4 (&floor_diffuse[], 1.0, 0.6, 0.6, 1.0)
	FillArray4 (&floor_specular[], 0.6, 0.6, 0.6, 1.0)
	FillArray4 (&fog_color[], 0.1, 0.1, 0.1, 1.0)
	FillArray8b (&fountain_side[], 1.2, 0.0, 1.0, 0.2, 0.41, 0.3, 0.4, 0.35)
	FillArray8b (&fountain_side[8], 0.4, 1.95, 0.41, 2.0, 0.8, 2.2, 1.2, 2.4)
	FillArray8b (&fountain_side[16], 1.5, 2.7, 1.55, 2.95, 1.6, 3.0, 1.0, 3.0)
	FillArray4 (&fountain_side[24], 0.5, 3.0, 0.0, 3.0)
	FillArray8b (&fountain_normal[], 1.0000, 0.0000, 0.6428, 0.7660, 0.3420, 0.9397, 1.0000, 0.0000)
	FillArray8b (&fountain_normal[8], 1.0000, 0.0000, 0.3420, - 0.9397, 0.4226, - 0.9063, 0.5000, - 0.8660)
	FillArray8b (&fountain_normal[16], 0.7660, - 0.6428, 0.9063, - 0.4226, 0.0000, 1.00000, 0.0000, 1.00000)
	FillArray4 (&fountain_normal[24], 0.0000, 1.00000, 0.0000, 1.00000)

	LoadTextures ()

	' Upload particle texture
	glGenTextures (1, &particle_tex_id)
	glBindTexture ($$GL_TEXTURE_2D, particle_tex_id)
	glPixelStorei ($$GL_UNPACK_ALIGNMENT, 1)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_CLAMP)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_CLAMP)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR)
	glTexImage2D ($$GL_TEXTURE_2D, 0, $$GL_LUMINANCE, $$P_TEX_WIDTH, $$P_TEX_HEIGHT, 0, $$GL_LUMINANCE, $$GL_UNSIGNED_BYTE, &particle_texture[])

	' Upload floor texture
	glGenTextures (1, &floor_tex_id)
	glBindTexture ($$GL_TEXTURE_2D, floor_tex_id)
	glPixelStorei ($$GL_UNPACK_ALIGNMENT, 1)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_REPEAT)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_REPEAT)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)
	glTexParameteri ($$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR)
	glTexImage2D ($$GL_TEXTURE_2D, 0, $$GL_LUMINANCE, $$F_TEX_WIDTH, $$F_TEX_HEIGHT, 0, $$GL_LUMINANCE, $$GL_UNSIGNED_BYTE, &floor_texture[])

	IF (glfwExtensionSupported (&"GL_EXT_separate_specular_color")) THEN
		glLightModeli ($$GL_LIGHT_MODEL_COLOR_CONTROL_EXT, $$GL_SEPARATE_SPECULAR_COLOR_EXT)
	END IF

	' Set filled polygon mode as default (not wireframe)
	glPolygonMode ($$GL_FRONT_AND_BACK, $$GL_FILL)


END FUNCTION

FUNCTION Resize (Width, Height)

	#Width = Width
	#Height = Height

	IF (#Height < 50) THEN #Height = 50
	IF (#Width < 50) THEN #Width = 50

	glViewport (0, 0, #Width, #Height)
	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity ()
	gluPerspective (65.0, SINGLE (#Width / #Height), 1.0, 60.0)
	glMatrixMode ($$GL_MODELVIEW)
	glLoadIdentity ()

END FUNCTION

FUNCTION LoadTextures ()
	SHARED UBYTE particle_texture[], floor_texture[]
	SHARED array

	DIM particle_texture[$$P_TEX_WIDTH * $$P_TEX_HEIGHT]
	DIM floor_texture[$$F_TEX_WIDTH * $$F_TEX_HEIGHT]

	FillArray8 (&particle_texture[], 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
	FillArray8 (&particle_texture[8], 0x00, 0x00, 0x11, 0x22, 0x22, 0x11, 0x00, 0x00)
	FillArray8 (&particle_texture[16], 0x00, 0x11, 0x33, 0x88, 0x77, 0x33, 0x11, 0x00)
	FillArray8 (&particle_texture[24], 0x00, 0x22, 0x88, 0xee, 0xee, 0x77, 0x22, 0x00)
	FillArray8 (&particle_texture[32], 0x00, 0x22, 0x77, 0xee, 0xee, 0x88, 0x22, 0x00)
	FillArray8 (&particle_texture[40], 0x00, 0x11, 0x33, 0x77, 0x88, 0x33, 0x11, 0x00)
	FillArray8 (&particle_texture[48], 0x00, 0x00, 0x11, 0x33, 0x22, 0x11, 0x00, 0x00)
	FillArray8 (&particle_texture[56], 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)

	array = &floor_texture[]: FillArray16 (0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30)
	array = &floor_texture[16]: FillArray16 (0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30)
	array = &floor_texture[32]: FillArray16 (0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30)
	array = &floor_texture[48]: FillArray16 (0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30)
	array = &floor_texture[64]: FillArray16 (0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30)
	array = &floor_texture[80]: FillArray16 (0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30)
	array = &floor_texture[96]: FillArray16 (0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30)
	array = &floor_texture[112]: FillArray16 (0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30)
	array = &floor_texture[128]: FillArray16 (0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0)
	array = &floor_texture[144]: FillArray16 (0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0)
	array = &floor_texture[160]: FillArray16 (0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0)
	array = &floor_texture[176]: FillArray16 (0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0)
	array = &floor_texture[192]: FillArray16 (0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0)
	array = &floor_texture[208]: FillArray16 (0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0)
	array = &floor_texture[224]: FillArray16 (0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0)
	array = &floor_texture[240]: FillArray16 (0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0)

END FUNCTION

' 8ub
FUNCTION FillArray8 (array, v1, v2, v3, v4, v5, v6, v7, v8)

	UBYTEAT (array) = v1
	UBYTEAT (array + 1) = v2
	UBYTEAT (array + 2) = v3
	UBYTEAT (array + 3) = v4
	UBYTEAT (array + 4) = v5
	UBYTEAT (array + 5) = v6
	UBYTEAT (array + 6) = v7
	UBYTEAT (array + 7) = v8

END FUNCTION

' 8fl
FUNCTION FillArray8b (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4, SINGLE v5, SINGLE v6, SINGLE v7, SINGLE v8)

	SINGLEAT (array) = v1
	SINGLEAT (array + 4) = v2
	SINGLEAT (array + 8) = v3
	SINGLEAT (array + 12) = v4
	SINGLEAT (array + 16) = v5
	SINGLEAT (array + 20) = v6
	SINGLEAT (array + 24) = v7
	SINGLEAT (array + 28) = v8

END FUNCTION

' 16ub
FUNCTION FillArray16 (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16)
	SHARED array

	UBYTEAT (array) = v1
	UBYTEAT (array + 1) = v2
	UBYTEAT (array + 2) = v3
	UBYTEAT (array + 3) = v4
	UBYTEAT (array + 4) = v5
	UBYTEAT (array + 5) = v6
	UBYTEAT (array + 6) = v7
	UBYTEAT (array + 7) = v8
	UBYTEAT (array + 8) = v9
	UBYTEAT (array + 9) = v10
	UBYTEAT (array + 10) = v11
	UBYTEAT (array + 11) = v12
	UBYTEAT (array + 12) = v13
	UBYTEAT (array + 13) = v14
	UBYTEAT (array + 14) = v15
	UBYTEAT (array + 15) = v16

END FUNCTION

' 4fl
FUNCTION FillArray4 (array, SINGLE v1, SINGLE v2, SINGLE v3, SINGLE v4)

	SINGLEAT (array) = v1
	SINGLEAT (array + 4) = v2
	SINGLEAT (array + 8) = v3
	SINGLEAT (array + 12) = v4

END FUNCTION

' 4ub
FUNCTION FillArray4b (array, v1, v2, v3, v4)

	UBYTEAT (array) = v1
	UBYTEAT (array + 1) = v2
	UBYTEAT (array + 2) = v3
	UBYTEAT (array + 3) = v4

END FUNCTION

END PROGRAM