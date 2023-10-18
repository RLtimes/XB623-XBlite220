 ' ========================================================================
 '  This is a small test application FOR GLFW.
 '  This is an OpenGL port of the famous "PONG" game (the first computer
 '  game ever?). It is very simple, and could be improved alot. It was
 '  created in order to show off the gaming capabilities of GLFW.
 '
 '
 '
 ' XBLite port by Michael McElligott 18/11/2002
 ' Mapei_@hotmail.com
 ' ========================================================================
CONSOLE

IMPORT "xst"
IMPORT "xma"
IMPORT "glfw"
IMPORT "opengl32"
IMPORT "glu32"


DECLARE FUNCTION main()
DECLARE FUNCTION LoadTextures()
DECLARE FUNCTION DrawImage( XLONG texnum, SINGLE x1, SINGLE x2, SINGLE y1, SINGLE y2 )
DECLARE FUNCTION GameMenu()
DECLARE FUNCTION NewGame ()
DECLARE FUNCTION PlayerControl()
DECLARE FUNCTION BallControl()
DECLARE FUNCTION DrawBox( SINGLE x1, SINGLE y1, SINGLE z1, SINGLE x2, SINGLE y2, SINGLE z2 )
DECLARE FUNCTION UpdateDisplay ()
DECLARE FUNCTION GameOver()
DECLARE FUNCTION GameLoop()

 ' ========================================================================
 '  Constants
 ' ========================================================================

 '  Player size (units)
 $$PLAYER_XSIZE = 0.05
 $$PLAYER_YSIZE = 0.15

 '  Ball size (units)
 $$BALL_SIZE = 0.02

 '  Maximum player movement speed (units / second)
 $$MAX_SPEED  =  1.5

 '  Player movement acceleration (units / seconds^2)
 $$ACCELERATION = 4.0

 '  Player movement deceleration (units / seconds^2)
 $$DECELERATION = 2.0

 '  Ball movement speed (units / second)
 $$BALL_SPEED  =  0.3

 '  Menu options
 $$MENU_NONE  =  0
 $$MENU_PLAY  =  1
 $$MENU_QUIT  =  2

 '  Game events
 $$NOBODY_WINS  = 0
 $$PLAYER1_WINS = 1
 $$PLAYER2_WINS = 2

 '  Winner ID
 $$NOBODY     =  0
 $$PLAYER1    =  1
 $$PLAYER2    =  2

 '  Camera positions
 $$CAMERA_CLASSIC =  0
 $$CAMERA_ABOVE    = 1
 $$CAMERA_SPECTATOR = 2
 $$CAMERA_DEFAULT   = 0 ' $$CAMERA_CLASSIC


 ' ========================================================================
 '  Textures
 ' ========================================================================

$$TEX_TITLE  =  0
$$TEX_MENU    = 1
$$TEX_INSTR   = 2
$$TEX_WINNER1 = 3
$$TEX_WINNER2 = 4
$$TEX_FIELD   = 5
$$NUM_TEXTURES =5

$$TEX_SCALE= 4.0

TYPE PLAYER
    DOUBLE .ypos      '  -1.0 to +1.0
    DOUBLE .yspeed    '  - $$MAX_SPEED to + $$MAX_SPEED
END TYPE


 '  Ball inFORmation
TYPE BALL
    DOUBLE .xpos
    DOUBLE .ypos
    DOUBLE .xspeed
    DOUBLE .yspeed
END TYPE



 ' ========================================================================
 '  main() - Program entry pooint
 ' ========================================================================

FUNCTION main ()

    XLONG menuoption

    '  Initialize GLFW
    IFZ glfwInit() THEN QUIT (0)

    '  Open OpenGL window
    IFZ glfwOpenWindow( 800, 600, 16, 16, 16, 0, 16, 0, $$GLFW_WINDOW )  THEN
        glfwTerminate()
        QUIT (0)
    END IF

		glfwSetWindowTitle( &"Pong3D" )

    '  Disable system keys
    glfwDisable( $$GLFW_SYSTEM_KEYS )

    '  Load all textures
    LoadTextures()
		
    '  Main loop
    DO
         '  Get menu option
        menuoption = GameMenu()

         '  If the user wants to play, let him...
        IF ( menuoption == $$MENU_PLAY ) THEN
        	GameLoop()
        END IF
    LOOP WHILE ( menuoption <> $$MENU_QUIT )

     '  Unload all textures
    IF( glfwGetWindowParam( $$GLFW_OPENED ) ) =1 THEN
            glDeleteTextures( $$NUM_TEXTURES, &#tex_id[] )
    END IF

     '  Terminate GLFW
    glfwTerminate()


END FUNCTION

 ' ========================================================================
 '  LoadTextures() - Load textures from disk and upload to OpenGL card
 ' ========================================================================

FUNCTION LoadTextures()

 '  Lighting configuration
 ' env_ambient[4]     = {1.0,1.0,1.0,1.0}
DIM #env_ambient![3]
#env_ambient![0]=1
#env_ambient![1]=1
#env_ambient![2]=1
#env_ambient![3]=1

 ' light1_position[4] = {-1.0,3.0,2.0,1.0}
DIM #light1_position![3]
#light1_position![0]=-3
#light1_position![1]=3
#light1_position![2]=2
#light1_position![3]=1

 ' light1_diffuse[4]  = {1.0,1.0,1.0,0.0}
DIM #light1_diffuse![3]
#light1_diffuse![0]=1
#light1_diffuse![1]=1
#light1_diffuse![2]=1
#light1_diffuse![3]=0

 ' light1_ambient[4]  = {0.0,0.0,0.0,0.0}
DIM #light1_ambient![3]
#light1_ambient![0]=0
#light1_ambient![1]=0
#light1_ambient![2]=0
#light1_ambient![3]=0

 '  Object material properties
 ' player1_diffuse[4] = {1.0,0.3,0.3,1.0}
DIM #player1_diffuse![3]
#player1_diffuse![0]=1
#player1_diffuse![1]=0.3
#player1_diffuse![2]=0.3
#player1_diffuse![3]=1
 ' player1_ambient[4] = {0.3,0.1,0.0,1.0}
DIM #player1_ambient![3]
#player1_ambient![0]=0.3
#player1_ambient![1]=0.1
#player1_ambient![2]=0
#player1_ambient![3]=0.1
 ' player2_diffuse[4] = {0.3,1.0,0.3,1.0}
DIM #player2_diffuse![3]
#player2_diffuse![0]=0.3
#player2_diffuse![1]=1.0
#player2_diffuse![2]=0.3
#player2_diffuse![3]=1.0
 ' player2_ambient[4] = {0.1,0.3,0.1,1.0}
DIM #player2_ambient![3]
#player2_ambient![0]=0.1
#player2_ambient![1]=0.3
#player2_ambient![2]=0.1
#player2_ambient![3]=1.0

 ' ball_diffuse[4]    = {1.0,1.0,0.5,1.0}
DIM #ball_diffuse![3]
#ball_diffuse![0]=1
#ball_diffuse![1]=1
#ball_diffuse![2]=0.5
#ball_diffuse![3]=1
 ' ball_ambient[4]    = {0.3,0.3,0.1,1.0}
DIM #ball_ambient![3]
#ball_ambient![0]=0.3
#ball_ambient![1]=0.3
#ball_ambient![2]=0.1
#ball_ambient![3]=1
 ' border_diffuse[4]  = {0.3,0.3,1.0,1.0}
DIM #border_diffuse![3]
#border_diffuse![0]=0.3
#border_diffuse![1]=0.3
#border_diffuse![2]=1
#border_diffuse![3]=1
 ' border_ambient[4]  = {0.1,0.1,0.3,1.0}
DIM #border_ambient![3]
#border_ambient![0]=0.1
#border_ambient![1]=0.1
#border_ambient![2]=0.3
#border_ambient![3]=1
 ' floor_diffuse[4]   = {1.0,1.0,1.0,1.0}
DIM #floor_diffuse![3]
#floor_diffuse![0]=1
#floor_diffuse![1]=1
#floor_diffuse![2]=1
#floor_diffuse![3]=1

 ' floor_ambient[4]   = {0.3,0.3,0.3,1.0}
DIM #floor_ambient![3]
#floor_ambient![0]=0.4
#floor_ambient![1]=0.4
#floor_ambient![2]=0.4
#floor_ambient![3]=1


 '  Texture names
    DIM #tex_name$[$$NUM_TEXTURES]
    #tex_name$[0]="pong3d_title.tga"
    #tex_name$[1]="pong3d_menu.tga"
    #tex_name$[2]="pong3d_instr.tga"
    #tex_name$[3]="pong3d_winner1.tga"
    #tex_name$[4]="pong3d_winner2.tga"
    #tex_name$[5]="pong3d_field.tga"


    '  OpenGL texture object IDs
    DIM #tex_id [$$NUM_TEXTURES]

     '  Generate texture objects
    glGenTextures( $$NUM_TEXTURES, &#tex_id[] )

     '  Load textures
    FOR i=0 TO $$NUM_TEXTURES  '  ( i = 0 i < $$NUM_TEXTURES i ++ )

         '  Select texture object
        glBindTexture( $$GL_TEXTURE_2D, #tex_id[i])

         '  Set texture parameters
        glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_REPEAT )
        glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_REPEAT )
        glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR )
        glTexParameteri( $$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR )

         '  Upload texture from file to texture memory
         glfwLoadTexture2D( &#tex_name$[i], 0 )
    NEXT i

END FUNCTION


 ' ========================================================================
 '  DrawImage() - Draw a 2D image as a texture
 ' ========================================================================

FUNCTION DrawImage( XLONG texnum, SINGLE x1, SINGLE x2, SINGLE y1, SINGLE y2 )

    glEnable( $$GL_TEXTURE_2D )
    glBindTexture( $$GL_TEXTURE_2D, #tex_id[ texnum ] )
    glBegin( $$GL_QUADS )
      glTexCoord2f( 0.0, 1.0 )
      glVertex2f( x1, y1 )
      glTexCoord2f( 1.0, 1.0 )
      glVertex2f( x2, y1 )
      glTexCoord2f( 1.0, 0.0 )
      glVertex2f( x2, y2 )
      glTexCoord2f( 0.0, 0.0 )
      glVertex2f( x1, y2 )
    glEnd()
    glDisable( $$GL_TEXTURE_2D )

END FUNCTION


 ' ========================================================================
 '  GameMenu() - Game menu (RETURNs menu option)
 ' ========================================================================

FUNCTION GameMenu(  )

    XLONG option

     '  Enable sticky keys
    glfwEnable( $$GLFW_STICKY_KEYS )

     '  Wait FOR a game menu key to be pressed
    option = $$MENU_NONE
    DO WHILE ( option == $$MENU_NONE )

         '  Get window size
        glfwGetWindowSize( &#width, &#height )

         '  Set viewport
        glViewport( 0, 0, #width, #height )

         '  Clear display
        glClearColor( 0.0, 0.0, 0.0, 0.0 )
        glClear( $$GL_COLOR_BUFFER_BIT )

         '  Setup projection matrix
        glMatrixMode( $$GL_PROJECTION )
        glLoadIdentity()
        glOrtho( 0.0, 1.0, 1.0, 0.0, -1.0, 1.0 )

         '  Setup modelview matrix
        glMatrixMode( $$GL_MODELVIEW )
        glLoadIdentity()

         '  Display title
        glColor3f( 1.0, 1.0, 1.0 )
        DrawImage( $$TEX_TITLE, 0.1, 0.9, 0.0, 0.3 )

         '  Display menu
        glColor3f( 1.0, 1.0, 0.0 )
        DrawImage( $$TEX_MENU, 0.38, 0.62, 0.35, 0.5 )

         '  Display instructions
        glColor3f( 0.0, 1.0, 1.0 )
        DrawImage( $$TEX_INSTR, 0.32, 0.68, 0.65, 0.85 )

         '  Swap buffers
        glfwSwapBuffers()

         '  Check FOR keys
        IF ((glfwGetKey('Q')=1) || glfwGetWindowParam( $$GLFW_OPENED )=0)  THEN
            option =  $$MENU_QUIT
        ELSE
						IF ( glfwGetKey( $$GLFW_KEY_F1 ) ) THEN
            	option = $$MENU_PLAY
            ELSE
							option = $$MENU_NONE
            END IF
        END IF

         '  To avoid horrible busy waiting, sleep FOR at least 20 ms
        glfwSleep( 0.02 )

    LOOP

     '  Disable sticky keys
    glfwDisable( $$GLFW_STICKY_KEYS )

    RETURN option
END FUNCTION


 ' ========================================================================
 '  NewGame() - Initialize a new game
 ' ========================================================================

FUNCTION  NewGame(  )
    SHARED PLAYER player1,player2
    SHARED BALL ball

     '  Frame inFORmation
    #starttime# = glfwGetTime()
    #thistime# = #starttime#

     '  Camera inFORmation
    #camerapos =  $$CAMERA_DEFAULT

     '  Player 1 inFORmation
    player1.ypos   = 0.0
    player1.yspeed = 0.0

     '  Player 2 inFORmation
    player2.ypos   = 0.0
    player2.yspeed = 0.0

     '  Ball inFORmation
    ball.xpos = -1.0 + $$PLAYER_XSIZE
    ball.ypos = player1.ypos
    ball.xspeed = 1.0
    ball.yspeed = 1.0

END FUNCTION


 ' ========================================================================
 '  PlayerControl() - Player control
 ' ========================================================================

FUNCTION PlayerControl()
    SHARED PLAYER player1,player2


    DIM joy1pos![ 1 ]
    DIM joy2pos![ 1 ]


     '  Get joystick X & Y axis positions
   glfwGetJoystickPos( $$GLFW_JOYSTICK_1, &joy1pos![], 2 )
   glfwGetJoystickPos( $$GLFW_JOYSTICK_2, &joy2pos![], 2 )


     '  Player 1 control
    IF ( glfwGetKey( 'A' )) THEN ' || joy1pos![ 0 ] > 0.2 ) THEN

        player1.yspeed = player1.yspeed + (#dt# *  $$ACCELERATION)
        IF( player1.yspeed >  $$MAX_SPEED ) THEN
            player1.yspeed =  $$MAX_SPEED
        END IF

    ELSE
    	IF( glfwGetKey( 'Z' )) THEN '|| joy1pos![ 0 ] < -0.2 )

           player1.yspeed =player1.yspeed - (#dt# *  $$ACCELERATION)
           IF ( player1.yspeed < -$$MAX_SPEED ) THEN
               player1.yspeed = -$$MAX_SPEED
           END IF
        ELSE
               player1.yspeed = player1.yspeed / Exp(  $$DECELERATION * #dt# )
        END IF
    END IF


     '  Player 2 control
    IF ( glfwGetKey( 'K' )) THEN '|| joy2pos![ 0 ] > 0.2 ) THEN

        player2.yspeed = player2.yspeed + (#dt# *  $$ACCELERATION)
        IF( player2.yspeed >  $$MAX_SPEED ) THEN
            player2.yspeed =  $$MAX_SPEED
        END IF
    ELSE
    	IF( glfwGetKey( 'M' )) THEN ' || joy2pos![ 0 ] < -0.2 ) THEN

           player2.yspeed =player2.yspeed - (#dt# *  $$ACCELERATION)
           IF( player2.yspeed < -$$MAX_SPEED )
               player2.yspeed = -$$MAX_SPEED
           END IF

      	ELSE
           player2.yspeed =player2.yspeed/ Exp(  $$DECELERATION * #dt# )
        END IF
    END IF

     '  Update player 1 position
    player1.ypos =player1.ypos + (#dt# * player1.yspeed)
    IF ( player1.ypos > 1.0 - $$PLAYER_YSIZE ) THEN
        player1.ypos = 1.0 - $$PLAYER_YSIZE
        player1.yspeed = 0.0

    ELSE
    	IF( player1.ypos < -1.0 + $$PLAYER_YSIZE ) THEN
           player1.ypos = -1.0 + $$PLAYER_YSIZE
           player1.yspeed = 0.0
        END IF
    END IF

     '  Update player 2 position
    player2.ypos = player2.ypos+ (#dt# * player2.yspeed)
    IF( player2.ypos > 1.0 - $$PLAYER_YSIZE ) THEN
        player2.ypos = 1.0 - $$PLAYER_YSIZE
        player2.yspeed = 0.0
    ELSE
        IF( player2.ypos < -1.0 + $$PLAYER_YSIZE ) THEN
           player2.ypos = -1.0 + $$PLAYER_YSIZE
           player2.yspeed = 0.0
        END IF
    END IF


END FUNCTION


 ' ========================================================================
 '  BallControl() - Ball control
 ' ========================================================================

FUNCTION BallControl(  )
    SHARED BALL ball
    SHARED PLAYER player1,player2
    XLONG event
    DOUBLE ballspeed

     '  Calculate new ball speed
    ballspeed =  DOUBLE($$BALL_SPEED) * (DOUBLE(1.0) + (DOUBLE(0.02)* DOUBLE((#thistime#-#starttime#)))	)


    IF ball.xspeed <0 THEN
    	ball.xspeed =-1 + ballspeed
    ELSE
    	ball.xspeed =1  - ballspeed
    END IF


    IF ball.yspeed <0 THEN
    	ball.yspeed = ball.yspeed - ballspeed
    ELSE
    	ball.yspeed = ball.yspeed + ballspeed
    END IF


    ball.yspeed = ball.yspeed * DOUBLE(0.74321)


     '  Update ball position
    ball.xpos = ball.xpos + #dt# * ball.xspeed
    ball.ypos = ball.ypos + #dt# * ball.yspeed



     '  Did the ball hit a top/bottom wall?
    IF( ball.ypos >= 1.0 ) THEN
        ball.ypos = 2  - ball.ypos
        ball.yspeed = ball.yspeed - ball.yspeed - ball.yspeed

    ELSE IF ( ball.ypos <= -1.0 ) THEN

    	    ball.ypos = -2.0 - ball.ypos
        	ball.yspeed = ball.yspeed - ball.yspeed - ball.yspeed
         END IF
    END IF



     '  Did the ball hit/miss a player?
    event = $$NOBODY_WINS

     '  Is the ball entering the player 1 goal?
    IF( ball.xpos < (-1.0 + $$PLAYER_XSIZE )) THEN

        '  Did player 1 catch the ball?
        IF (( ball.ypos > (player1.ypos - $$PLAYER_YSIZE)) && (ball.ypos < (player1.ypos + $$PLAYER_YSIZE)))
            ball.xpos = -2.0 + (2.0 * $$PLAYER_XSIZE) - ball.xpos
            ball.xspeed = -ball.xspeed
        ELSE
            event =  $$PLAYER2_WINS
        END IF

    END IF

     '  Is the ball entering the player 2 goal?
    IF( ball.xpos > 1.0 - $$PLAYER_XSIZE ) THEN

         '  Did player 2 catch the ball?
        IF ((ball.ypos > (player2.ypos- $$PLAYER_YSIZE)) && (ball.ypos < (player2.ypos+ $$PLAYER_YSIZE)) ) THEN
            ball.xpos = 2.0 - (2.0 * $$PLAYER_XSIZE) - ball.xpos
            ball.xspeed = ball.xspeed - ball.xspeed - ball.xspeed

        ELSE
            event =  $$PLAYER1_WINS
        END IF

    END IF


    RETURN event

END FUNCTION


 ' ========================================================================
 '  DrawBox() - Draw a 3D box
 ' ========================================================================

' $$TEX_SCALE 4.0


FUNCTION DrawBox( SINGLE x1, SINGLE y1, SINGLE z1, SINGLE x2, SINGLE y2, SINGLE z2 )

     '  Draw six sides of a cube
    glBegin( $$GL_QUADS )
       '  Side 1 (down)
      glNormal3f( 0.0, 0.0, -1.0 )
      glTexCoord2f( 0.0, 0.0 )
      glVertex3f( x1,y2,z1 )
      glTexCoord2f( $$TEX_SCALE, 0.0 )
      glVertex3f( x2,y2,z1 )
      glTexCoord2f( $$TEX_SCALE, $$TEX_SCALE )
      glVertex3f( x2,y1,z1 )
      glTexCoord2f( 0.0, $$TEX_SCALE )
      glVertex3f( x1,y1,z1 )
       '  Side 2 (up)
      glNormal3f( 0.0, 0.0, 1.0 )
      glTexCoord2f( 0.0, 0.0 )
      glVertex3f( x1,y1,z2 )
      glTexCoord2f( $$TEX_SCALE, 0.0 )
      glVertex3f( x2,y1,z2 )
      glTexCoord2f( $$TEX_SCALE, $$TEX_SCALE )
      glVertex3f( x2,y2,z2 )
      glTexCoord2f( 0.0, $$TEX_SCALE )
      glVertex3f( x1,y2,z2 )
       '  Side 3 (backward)
      glNormal3f( 0.0, -1.0, 0.0 )
      glTexCoord2f( 0.0, 0.0 )
      glVertex3f( x1,y1,z1 )
      glTexCoord2f( $$TEX_SCALE, 0.0 )
      glVertex3f( x2,y1,z1 )
      glTexCoord2f( $$TEX_SCALE, $$TEX_SCALE )
      glVertex3f( x2,y1,z2 )
      glTexCoord2f( 0.0, $$TEX_SCALE )
      glVertex3f( x1,y1,z2 )
       '  Side 4 (FORward)
      glNormal3f( 0.0, 1.0, 0.0 )
      glTexCoord2f( 0.0, 0.0 )
      glVertex3f( x1,y2,z2 )
      glTexCoord2f( $$TEX_SCALE, 0.0 )
      glVertex3f( x2,y2,z2 )
      glTexCoord2f( $$TEX_SCALE, $$TEX_SCALE )
      glVertex3f( x2,y2,z1 )
      glTexCoord2f( 0.0, $$TEX_SCALE )
      glVertex3f( x1,y2,z1 )
       '  Side 5 (left)
      glNormal3f( -1.0, 0.0, 0.0 )
      glTexCoord2f( 0.0, 0.0 )
      glVertex3f( x1,y1,z2 )
      glTexCoord2f( $$TEX_SCALE, 0.0 )
      glVertex3f( x1,y2,z2 )
      glTexCoord2f( $$TEX_SCALE, $$TEX_SCALE )
      glVertex3f( x1,y2,z1 )
      glTexCoord2f( 0.0, $$TEX_SCALE )
      glVertex3f( x1,y1,z1 )
       '  Side 6 (right)
      glNormal3f( 1.0, 0.0, 0.0 )
      glTexCoord2f( 0.0, 0.0 )
      glVertex3f( x2,y1,z1 )
      glTexCoord2f( $$TEX_SCALE, 0.0 )
      glVertex3f( x2,y2,z1 )
      glTexCoord2f( $$TEX_SCALE, $$TEX_SCALE )
      glVertex3f( x2,y2,z2 )
      glTexCoord2f( 0.0, $$TEX_SCALE )
      glVertex3f( x2,y1,z2 )
    glEnd()

END FUNCTION


 ' ========================================================================
 '  UpdateDisplay() - Draw graphics (all game related OpenGL stuff goes
 '  here)
 ' ========================================================================

FUNCTION UpdateDisplay(  )
    SHARED BALL ball
    SHARED PLAYER player1,player2


     '  Get window size
    glfwGetWindowSize( &#width, &#height )

     '  Set viewport
    glViewport( 0, 0, #width, #height )

     '  Clear display
    glClearColor( 0.02, 0.02, 0.02, 0.0 )
    glClearDepth( 1.0 )
    glClear( $$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT )

     '  Setup projection matrix
    glMatrixMode( $$GL_PROJECTION )
    glLoadIdentity()
    gluPerspective(55.0, SINGLE(#width)/ SINGLE(#height),1.0,100.0)


     '  Setup modelview matrix
    glMatrixMode( $$GL_MODELVIEW )
    glLoadIdentity()

    SELECT CASE  #camerapos

    	CASE  $$CAMERA_CLASSIC:
        	gluLookAt( 0.0, 0.0, 2.5,0.0, 0.0, 0.0,0.0, 1.0, 0.0 )

    	CASE  $$CAMERA_ABOVE:
        	gluLookAt(0.0, 0.0, 2.5,SINGLE(ball.xpos), SINGLE(ball.ypos), 0.0,0.0, 1.0, 0.0)

    	CASE  $$CAMERA_SPECTATOR:
        	gluLookAt(0.0, -2.0, 1.2,SINGLE(ball.xpos), SINGLE(ball.ypos), 0.0,0.0, 0.0, 1.0)

    END SELECT



     '  Enable depth testing
    glEnable( $$GL_DEPTH_TEST )
    glDepthFunc( $$GL_LEQUAL )

     '  Enable lighting
    glEnable( $$GL_LIGHTING )
    glLightModelfv( $$GL_LIGHT_MODEL_AMBIENT, &#env_ambient![] )
    glLightModeli( $$GL_LIGHT_MODEL_LOCAL_VIEWER, $$GL_TRUE )
    glLightModeli( $$GL_LIGHT_MODEL_TWO_SIDE, $$GL_FALSE )
    glLightfv( $$GL_LIGHT1, $$GL_POSITION, &#light1_position![] )
    glLightfv( $$GL_LIGHT1, $$GL_DIFFUSE,  &#light1_diffuse![] )
    glLightfv( $$GL_LIGHT1, $$GL_AMBIENT,  &#light1_ambient![] )

    glEnable( $$GL_LIGHT1 )


     '  Front face is counter-clock-wise
    glFrontFace( $$GL_CCW )

     '  Enable face culling (not necessary, but speeds up rendering)
    glCullFace( $$GL_BACK )
    glEnable( $$GL_CULL_FACE )

     '  Draw Player 1
    glMaterialfv( $$GL_FRONT, $$GL_DIFFUSE, &#player1_diffuse![] )
    glMaterialfv( $$GL_FRONT, $$GL_AMBIENT, &#player1_ambient![] )

    DrawBox( -1.0,SINGLE(player1.ypos) - $$PLAYER_YSIZE, 0.0,-1.0+ $$PLAYER_XSIZE, SINGLE(player1.ypos) + $$PLAYER_YSIZE, 0.1 )

     '  Draw Player 2
    glMaterialfv( $$GL_FRONT, $$GL_DIFFUSE, &#player2_diffuse![] )
    glMaterialfv( $$GL_FRONT, $$GL_AMBIENT, &#player2_ambient![] )
    DrawBox( 1.0- $$PLAYER_XSIZE, SINGLE(player2.ypos) - $$PLAYER_YSIZE, 0.0,1.0, SINGLE(player2.ypos) + $$PLAYER_YSIZE, 0.1 )

     '  Draw Ball
    glMaterialfv( $$GL_FRONT, $$GL_DIFFUSE, &#ball_diffuse![] )
    glMaterialfv( $$GL_FRONT, $$GL_AMBIENT, &#ball_ambient![] )
    DrawBox( SINGLE(ball.xpos)- $$BALL_SIZE, SINGLE(ball.ypos) - $$BALL_SIZE, 0.0,SINGLE(ball.xpos)+ $$BALL_SIZE, SINGLE(ball.ypos) + $$BALL_SIZE,  $$BALL_SIZE*2 )

     '  Top game field border
    glMaterialfv( $$GL_FRONT, $$GL_DIFFUSE, &#border_diffuse![] )
    glMaterialfv( $$GL_FRONT, $$GL_AMBIENT, &#border_ambient![] )
    DrawBox( -1.1, 1.0, 0.0,  1.1, 1.1, 0.1 )
     '  Bottom game field border
    glColor3f( 0.0, 0.0, 0.7 )
    DrawBox( -1.1, -1.1, 0.0,  1.1, -1.0, 0.1 )
     '  Left game field border
    DrawBox( -1.1, -1.0, 0.0,  -1.0, 1.0, 0.1 )
     '  Left game field border
    DrawBox( 1.0, -1.0, 0.0,  1.1, 1.0, 0.1 )

     '  Enable texturing
    glEnable( $$GL_TEXTURE_2D )
    glBindTexture( $$GL_TEXTURE_2D, #tex_id[ $$TEX_FIELD ] )

     '  Game field floor
    glMaterialfv( $$GL_FRONT, $$GL_DIFFUSE, &#floor_diffuse![] )
    glMaterialfv( $$GL_FRONT, $$GL_AMBIENT, &#floor_ambient![] )

    DrawBox( -1.01, -1.01, -0.01,  1.01, 1.01, 0.0 )

     '  Disable texturing
    glDisable( $$GL_TEXTURE_2D )

     '  Disable face culling
    glDisable( $$GL_CULL_FACE )

     '  Disable lighting
    glDisable( $$GL_LIGHTING )

     '  Disable depth testing
    glDisable( $$GL_DEPTH_TEST )


END FUNCTION


 ' ========================================================================
 '  GameOver()
 ' ========================================================================

FUNCTION GameOver()

     '  Enable sticky keys
    glfwEnable( $$GLFW_STICKY_KEYS )

     '  Until the user presses ESC or SPACE
    DO WHILE ((( glfwGetKey( $$GLFW_KEY_ESC )=0) && (glfwGetKey(' ')=0) && (glfwGetWindowParam( $$GLFW_OPENED)=1) ))

         '  Draw display
        UpdateDisplay()

         '  Setup projection matrix
        glMatrixMode( $$GL_PROJECTION )
        glLoadIdentity()
        glOrtho( 0.0, 1.0, 1.0, 0.0, -1.0, 1.0 )

         '  Setup modelview matrix
        glMatrixMode( $$GL_MODELVIEW )
        glLoadIdentity()

         '  Enable blending
        glEnable( $$GL_BLEND )

         '  Dim background
        glBlendFunc( $$GL_ONE_MINUS_SRC_ALPHA, $$GL_SRC_ALPHA )
        glColor4f( 0.3, 0.3, 0.3, 0.3 )
        glBegin( $$GL_QUADS )
          glVertex2f( 0.0, 0.0 )
          glVertex2f( 1.0, 0.0 )
          glVertex2f( 1.0, 1.0 )
          glVertex2f( 0.0, 1.0 )
        glEnd()

         '  Display winner text
        glBlendFunc( $$GL_ONE, $$GL_ONE_MINUS_SRC_COLOR )
        IF ( #winner ==  $$PLAYER1 ) THEN

            glColor4f( 1.0, 0.5, 0.5, 1.0 )
            DrawImage( $$TEX_WINNER1, 0.35, 0.65, 0.46, 0.54 )

        ELSE
        	IF( #winner ==  $$PLAYER2 ) THEN

            	glColor4f( 0.5, 1.0, 0.5, 1.0 )
        	    DrawImage( $$TEX_WINNER2, 0.35, 0.65, 0.46, 0.54 )
        	END IF
        END IF

         '  Disable blending
        glDisable( $$GL_BLEND )

         '  Swap buffers
        glfwSwapBuffers()
    LOOP

     '  Disable sticky keys
    glfwDisable( $$GLFW_STICKY_KEYS )

END FUNCTION


 ' ========================================================================
 '  GameLoop() - Game loop
 ' ========================================================================

FUNCTION GameLoop()

    XLONG playing, event

     '  Initialize a new game
    NewGame ()

     '  Enable sticky keys
    glfwEnable( $$GLFW_STICKY_KEYS )

     '  Loop until the game ends
    playing = $$GL_TRUE
     DO WHILE ( playing && glfwGetWindowParam( $$GLFW_OPENED )<>0 )

         '  Frame timer
        #oldtime# = #thistime#
        #thistime# = glfwGetTime()
        #dt# = #thistime# - #oldtime#

         '  Get user input and update player positions
        PlayerControl()

         '  Move the ball, and check IF a player hits/misses the ball
        event = BallControl()

         '  Did we have a winner?
        SELECT CASE ( event )

        CASE  $$PLAYER1_WINS:
            #winner =  $$PLAYER1
            playing = $$GL_FALSE
        CASE  $$PLAYER2_WINS:
            #winner =  $$PLAYER2
            playing = $$GL_FALSE

        END SELECT

         '  Did the user press ESC?
        IF  glfwGetKey( $$GLFW_KEY_ESC )=1 THEN playing = $$GL_FALSE


         '  Did the user change camera view?
        IF ( glfwGetKey( '1' ) ) THEN
            #camerapos =  $$CAMERA_CLASSIC
        ELSE
        	IF( glfwGetKey( '2' ) ) THEN
        	    #camerapos =  $$CAMERA_ABOVE
        	ELSE
        		IF( glfwGetKey( '3' ) ) THEN
        			#camerapos =  $$CAMERA_SPECTATOR
        		END IF
        	END IF
        END IF

         '  Draw display
        UpdateDisplay()

         '  Swap buffers
        glfwSwapBuffers()
    LOOP

     '  Disable sticky keys
    glfwDisable( $$GLFW_STICKY_KEYS )

     '  Show winner
    GameOver ()


END FUNCTION

END PROGRAM
