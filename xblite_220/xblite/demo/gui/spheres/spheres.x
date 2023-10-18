'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Program      : sphere2.cpp
' Date         : 4.23.1995
' Author       : Hans Kopp
' EMail        : hskopp@cip.informatik.uni-erlangen.de
' Description  : This program draws a diffuse shaded,
'  specular shaded or bump-mapped sphere, that can be
'  rotated interactively around an arbitrary axis
'---
' See article Fast_Texture_Mapping_Of_Spheres.html
'
PROGRAM	"spheres"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"msvcrt"		' msvcrt.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  sphere_to_kart (alpha, beta, DOUBLE x, DOUBLE y, DOUBLE z)
DECLARE FUNCTION  kart_to_sphere (DOUBLE x, DOUBLE y, DOUBLE z, @alpha, @beta)
DECLARE FUNCTION  inittex_circles (UBYTE tex[])
DECLARE FUNCTION  inittex_diffuse (UBYTE tex[])
DECLARE FUNCTION  inittex_specular (UBYTE tex[])
DECLARE FUNCTION  DOUBLE bump_fkt (DOUBLE x, DOUBLE y, DOUBLE z)
DECLARE FUNCTION  init_bumpmap (USHORT bump[])
DECLARE FUNCTION  initialize ()
DECLARE FUNCTION  set_grey_palette ()
DECLARE FUNCTION  draw_sphere_specular (hdc, phi, theta, psi, radius, x0, y0)
DECLARE FUNCTION  draw_sphere (hdc, phi, theta, psi, radius, x0, y0)
DECLARE FUNCTION  draw_sphere_bump (hdc, phi, theta, psi, phi2, theta2, radius, x0, y0)
DECLARE FUNCTION  DrawCustomFontText (hDC, fontName$, pointSize, weight, italic, underline, angle#, x, y, text$, @lineSpace)
DECLARE FUNCTION  GetLineHeight (hDC, @lineSpace, @pixels, @leading)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline, angle#)

'Control IDs
$$Button1  = 101
$$Button2  = 102
$$Button3  = 103
$$Button4  = 104
$$Button5  = 105
'
' Size of the Texture and the Lookuptable
' (Only Powers of 2 below or equal to 256 are allowed)
$$SIZEOFTEX = 256
$$EPSILON   = 0.0000001
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create main windows and other child controls
	MessageLoop ()								' the message loop
	CleanUp ()										' unregister all window classes
'	XioFreeConsole ()							' free console

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	PAINTSTRUCT ps
	RECT rect
	STATIC button
	STATIC psi, radius, phi, theta, y0, phi2, theta2

	SELECT CASE msg

		CASE $$WM_CREATE:
			psi 		= 0				'(0 < psi < 256)
			radius 	= 60
			phi 		= 0				'(0 < phi < 256)
			theta 	= 0				'(0 < theta < 256)
			phi2		= 0				'(0 < phi2 < 256)
			theta2	= 0				'(0 < theta2 < 256)
			GetClientRect (hWnd, &rect)
			y0 			= rect.bottom/2.0

		CASE $$WM_PAINT:
			hdc = BeginPaint (hWnd, &ps)
				bcolor = GetSysColor ($$COLOR_BTNFACE)
				SetBkColor (hdc, bcolor)
				draw_sphere (hdc, phi, theta, psi, radius, 80, 80)
				draw_sphere_specular (hdc, phi, theta, psi, radius, 240, 80)
				draw_sphere_bump (hdc, phi, theta, psi, phi2, theta2, radius, 400, 80)
				DrawCustomFontText (hdc, "ms sans serif", 9, $$FW_NORMAL, $$FALSE, $$FALSE, 0, 20,  150, "Diffuse Shaded Sphere", @spacing)
				DrawCustomFontText (hdc, "ms sans serif", 9, $$FW_NORMAL, $$FALSE, $$FALSE, 0, 180, 150, "Specular Shaded Sphere", @spacing)
				DrawCustomFontText (hdc, "ms sans serif", 9, $$FW_NORMAL, $$FALSE, $$FALSE, 0, 340, 150, "Bump-map Shaded Sphere", @spacing)
			EndPaint (hWnd, &ps)

		CASE $$WM_DESTROY:
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			button = LOWORD (wParam)
			SELECT CASE button
				CASE $$Button1 : phi 		= phi + 16		: IF phi 		>= $$SIZEOFTEX THEN phi 		= 0
				CASE $$Button2 : theta 	= theta + 16 	: IF theta 	>= $$SIZEOFTEX THEN theta 	= 0
				CASE $$Button3 : psi 		= psi + 16 		: IF psi 		>= $$SIZEOFTEX THEN psi 		= 0
				CASE $$Button4 : phi2 	= phi2 + 16 	: IF phi2 	>= $$SIZEOFTEX THEN phi2 		= 0
				CASE $$Button5 : theta2 = theta2 + 16 : IF theta2 >= $$SIZEOFTEX THEN theta2 	= 0
			END SELECT
			InvalidateRect (hWnd, NULL, $$FALSE)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
FUNCTION  InitGui ()

	SHARED hInst

	hInst = GetModuleHandleA (0) 	' get current instance handle
	IFZ hInst THEN QUIT(0)

END FUNCTION
'
'
' #################################
' #####  RegisterWinClass ()  #####
' #################################
'
FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)

	SHARED hInst
	WNDCLASS wc

	wc.style           = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc     = addrWndProc
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &icon$)
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = $$COLOR_BTNFACE + 1
	wc.lpszMenuName    = &menu$
	wc.lpszClassName   = &className$

	IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

	RECT rect
	SHARED className$, hInst

' register window class
	className$  = "TexturedSphereDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Textured Spheres Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 508
	h 					= 260
	#winMain 		= NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	GetClientRect (#winMain, &rect)
	y = rect.bottom - 24
	style 			= $$BS_PUSHBUTTON | $$WS_TABSTOP
	#button1 		= NewChild ("button", "INC phi",    style, 0,   y, 100, 24, #winMain, $$Button1, 0)
	#button2 		= NewChild ("button", "INC theta",  style, 100, y, 100, 24, #winMain, $$Button2, 0)
	#button3 		= NewChild ("button", "INC psi",    style, 200, y, 100, 24, #winMain, $$Button3, 0)
	#button4 		= NewChild ("button", "INC phi2",   style, 300, y, 100, 24, #winMain, $$Button4, 0)
	#button5 		= NewChild ("button", "INC theta2", style, 400, y, 100, 24, #winMain, $$Button5, 0)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

END FUNCTION
'
'
' ##########################
' #####  NewWindow ()  #####
' ##########################
'
FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

	SHARED hInst

	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION
'
'
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

	SHARED hInst

	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

	STATIC MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, hwnd, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  				TranslateMessage (&msg)						' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)						' send message to window callback function WndProc()
				END IF
		END SELECT
	LOOP

END FUNCTION
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$
	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' ###############################
' #####  sphere_to_kart ()  #####
' ###############################
'
' This function converts the (integer-) spherical
' coordinates (alpha,beta) into cartesian coordinates (x,y,z)
' on the unit-sphere. The polar axis of the SCS is the y-axis.
'
FUNCTION  sphere_to_kart (alpha, beta, DOUBLE x, DOUBLE y, DOUBLE z)

	DOUBLE alpha1, beta1

	alpha1 = alpha * $$M_PI*2/DOUBLE($$SIZEOFTEX)
	beta1  = (beta - $$SIZEOFTEX/2.0) * $$M_PI/DOUBLE($$SIZEOFTEX)

' convert to kartesian coordinates
	x = cos(alpha1) * cos(beta1)
	y = sin(beta1)
	z = sin(alpha1) * cos(beta1)

END FUNCTION
'
'
' ###############################
' #####  kart_to_sphere ()  #####
' ###############################
'
' This function converts a point (x,y,z) on the
' unit-sphere into (integer-) spherical
' coordinates (alpha,beta).
'
FUNCTION  kart_to_sphere (DOUBLE x, DOUBLE y, DOUBLE z, @alpha, @beta)

	DOUBLE beta1, alpha1, w

' convert to spherical coordinates
	beta1 = asin(y)
	IF (fabs(cos(beta1)) > $$EPSILON) THEN
		w = x / cos(beta1)
		IF (w > 1) THEN w = 1
		IF (w < -1) THEN w = -1
		alpha1 = acos(w)
		IF (z/cos(beta1) < 0) THEN alpha1 = $$M_PI*2 - alpha1
 	ELSE
		alpha1 = 0
	END IF

' convert to integer
	alpha = alpha1 / ($$M_PI*2) * $$SIZEOFTEX
	beta = beta1 / $$M_PI * $$SIZEOFTEX + $$SIZEOFTEX/2.0

' truncate integers
	IF (alpha < 0) THEN alpha = 0
	IF (alpha >= $$SIZEOFTEX) THEN alpha = $$SIZEOFTEX-1
	IF (beta < 0) THEN beta = 0
	IF (beta >= $$SIZEOFTEX) THEN beta = $$SIZEOFTEX-1

END FUNCTION
'
'
' ################################
' #####  inittex_circles ()  #####
' ################################
'
' This function initializes the texture for the
' texture-mapped sphere.
' (Of course, you can change this texture).
'
FUNCTION  inittex_circles (UBYTE tex[])

	upper = $$SIZEOFTEX - 1
	DIM tex[upper*upper+upper]

	FOR x = 0 TO upper
		FOR y = 0 TO $$SIZEOFTEX
			x1 = x - $$SIZEOFTEX/2
			y1 = y - $$SIZEOFTEX/2
			tex[x + y*$$SIZEOFTEX] = sqrt(x1*x1 + y1*y1)			' max = 181
		NEXT y
	NEXT x

END FUNCTION
'
'
' ################################
' #####  inittex_diffuse ()  #####
' ################################
'
' This function initializes the texture for the
' diffuse shaded sphere.
'
FUNCTION  inittex_diffuse (UBYTE tex[])

	DOUBLE x, y, z
	DOUBLE dot
	DOUBLE lx, ly, lz               ' direction of the incident light
	DOUBLE lr
	DOUBLE nx, ny, nz               ' normal of a point on the sphere

	lx=1 : ly=0 : lz=0

' normalize direction of light
	lr = sqrt(lx*lx+ly*ly+lz*lz)
	lx = lx / lr
	ly = ly / lr
	lz = lz / lr

' for all pixels in the intensity-texture ...
	upper = $$SIZEOFTEX - 1
	DIM tex[upper*upper+upper]

	FOR alpha = 0 TO upper
		FOR beta = 0 TO upper

' convert to cartesian coordinates
			sphere_to_kart(alpha, beta, @nx, @ny, @nz)

' compute the intensity using the dot-product
			dot = nx*lx + ny*ly + nz*lz
			IF (dot < 0) THEN dot = 0

' set pixel of the texture
			tex[alpha+beta*$$SIZEOFTEX] = (dot + .2) / 1.2 * 255

		NEXT beta
	NEXT alpha

END FUNCTION
'
'
' #################################
' #####  inittex_specular ()  #####
' #################################
'
' This function initializes the texture for the
' specular shaded sphere.

FUNCTION  inittex_specular (UBYTE tex[])

	DOUBLE rx, ry, rz						' direction of a ray after it has been
															' reflected on the spheres surface
	DOUBLE lx[10], ly[10], lz[10]
	DOUBLE li[10], lr
	DOUBLE exponent							' specular exponent
	DOUBLE intensity
	DOUBLE dot

	exponent = 6
	n=2                   			' number of lightsources

' directions and brightnesses of the lightsources
	lx[0] = 12 : ly[0] = 12 : lz[0] = 12 : li[0] = 1
	lx[1] = -5 : ly[1] = 4  : lz[1] = -4 : li[1] = .6

' normalize directions of the lightsources
	FOR i = 0 TO n - 1
		lr = sqrt(lx[i]*lx[i]+ly[i]*ly[i]+lz[i]*lz[i])
		lx[i] = lx[i]/lr
		ly[i] = ly[i]/lr
		lz[i] = lz[i]/lr
	NEXT i

' for all pixels of the intensity-texture ...
	upper = $$SIZEOFTEX - 1
	DIM tex[upper*upper+upper]

	FOR alpha = 0 TO upper
		FOR beta = 0 TO $$SIZEOFTEX
			intensity = 0
			sphere_to_kart(alpha, beta, @rx, @ry, @rz)

' sum up the intensities of the lightsources ...
			FOR i = 0 TO n - 1

' compute the intensity-contribution of a single lightsource
				dot = rx*lx[i] + ry*ly[i] + rz*lz[i]
				IF (dot < 0) THEN dot = 0
				dot = pow(dot, exponent)

' scale with the brightness of the lightsource
				intensity = intensity + dot*li[i]
			NEXT i

' store this pixel
			tex[alpha + beta*$$SIZEOFTEX] = 255 * (intensity + .3)/1.3
		NEXT beta
	NEXT alpha

END FUNCTION
'
'
' #########################
' #####  bump_fkt ()  #####
' #########################
'
' The gradients of this (mathematical) function on the
' unit-sphere are used as normals for the bump-map.
' You can modify it, to achieve other effects.
'
FUNCTION  DOUBLE bump_fkt (DOUBLE x, DOUBLE y, DOUBLE z)

	RETURN sqrt(x*x + y*y + z*z) * (1+.01*sin(x*23)) * (1+.01*cos(z*30))

END FUNCTION
'
'
' #############################
' #####  init_bumpmap ()  #####
' #############################
'
' This function initializes the bump-map.
'
FUNCTION  init_bumpmap (USHORT bump[])

	DOUBLE px, py, pz             ' point on the unit-sphere
	DOUBLE gx, gy, gz             ' gradient at this point
	DOUBLE base, gr, nr

' for all entries of the bump-map ...
	upper = $$SIZEOFTEX - 1
	DIM bump[upper*upper+upper]

	FOR alpha = 0 TO upper
		FOR beta = 0 TO upper

' convert to cartesian coordinates
			sphere_to_kart(alpha, beta, @px, @py, @pz)

' compute the gradient of the function above at this point
			base = bump_fkt(px, py, pz)
			gx = (bump_fkt(px+$$EPSILON, py, pz) - base)/$$EPSILON
			gy = (bump_fkt(px, py+$$EPSILON, pz) - base)/$$EPSILON
			gz = (bump_fkt(px, py, pz+$$EPSILON) - base)/$$EPSILON

' normalize ...
			gr = sqrt(gx*gx + gy*gy + gz*gz)
			gx = gx/gr : gy = gy/gr : gz = gz/gr

' store this vector in the bump-map
			kart_to_sphere(gx, gy, gz, @alpha1, @beta1)
			bump[alpha + beta * $$SIZEOFTEX] = alpha1 + beta1 * $$SIZEOFTEX
		NEXT beta
	NEXT alpha

END FUNCTION
'
'
' ###########################
' #####  initialize ()  #####
' ###########################
'
' This function initializes all the lookuptables.
'
FUNCTION  initialize ()

	SHARED USHORT LOOKUPTABLE[]
	SHARED ULONG SCR_TO_SPHERE[]
	DOUBLE x_kart, y_kart, z_kart					' cartesian coordinates

' compute the lookup-table for the switching between the coordinate-systems
	upper = $$SIZEOFTEX - 1
	DIM LOOKUPTABLE[upper*upper+upper]

	FOR x = 0 TO upper
		FOR y = 0 TO $$SIZEOFTEX

' sperical coordinates to cartesian coordinates
			sphere_to_kart(x, y, @x_kart, @y_kart, @z_kart)

' cartesian coordinates to spherical coordinates
' (compared to the line above, y_kart and z_kart are toggled.!!!)
			kart_to_sphere(x_kart, z_kart, y_kart, @alpha, @beta)
			LOOKUPTABLE[x + y * $$SIZEOFTEX] = alpha + beta * $$SIZEOFTEX
		NEXT y
	NEXT x

' compute the lookuptable, that is used to
' convert the 2D-screen-coordinates to the initial
' spherical coordinates (this is somewhat different
' from the pseudocode in the article)

	DIM SCR_TO_SPHERE[$$SIZEOFTEX*2-1]

	FOR x = 0 TO upper
    SCR_TO_SPHERE[x] = acos(DOUBLE((x-$$SIZEOFTEX/2+1) * 2/DOUBLE($$SIZEOFTEX))) * $$SIZEOFTEX/$$M_PI
    SCR_TO_SPHERE[x] = SCR_TO_SPHERE[x] MOD $$SIZEOFTEX
    SCR_TO_SPHERE[x+$$SIZEOFTEX] = SCR_TO_SPHERE[x]
	NEXT x

END FUNCTION
'
'
' #################################
' #####  set_grey_palette ()  #####
' #################################
'
' This function creates a grey-scale palette.
'
FUNCTION  set_grey_palette ()

	SHARED palette[]
	DIM palette[255]

	FOR rgb = 0 TO 255
		palette[rgb] = RGB(rgb, rgb, rgb)
	NEXT rgb

END FUNCTION
'
'
' #####################################
' #####  draw_sphere_specular ()  #####
' #####################################
'
' Description : This function draws a specular shaded sphere.
' Arguments 	: phi, theta and psi : angles describing the orientation of the lights
'              (angle_in_degree = phi/$$SIZEOFTEX*360)
'							:	radius : radius of the sphere in pixels
'							: x0, y0 : coordinates of center of sphere
'
FUNCTION  draw_sphere_specular (hdc, phi, theta, psi, radius, x0, y0)

	XLONG x, y              ' current pixel-position
	XLONG xr                ' width of sphere in current scanline
	XLONG screenpos         ' auxiliary Variable
	XLONG beta1, alpha1     ' initial spherical coordinates

' other spherical coordinates (positions and directions)
	XLONG alpha_beta2, alpha_beta3, alpha_beta4, alpha_beta5
	XLONG xinc, xscaled     ' auxiliary variables

	SHARED USHORT LOOKUPTABLE[]
	SHARED ULONG SCR_TO_SPHERE[]

	STATIC UBYTE TEXTURE[]
	SHARED palette[]

	IFZ TEXTURE[] THEN
		inittex_specular (@TEXTURE[])
	END IF

	IFZ LOOKUPTABLE[] THEN
		initialize ()
	END IF

	IFZ palette[] THEN
		set_grey_palette ()
	END IF

' for all scanlines ...
	FOR y = -radius+1 TO radius-1

' compute the width of the sphere in this scanline
		xr = sqrt(radius*radius - y*y)
		IF (xr == 0) THEN xr = 1

' computer the first spherical coordinate beta
		beta1 = SCR_TO_SPHERE[(y+radius) * $$SIZEOFTEX/(2*radius)] * $$SIZEOFTEX
		xinc = $$SIZEOFTEX * 0x10000 / (2*xr)
		xscaled = 0

' calculate y screen position
		yscr = y0 + y

' for all pixels in this scanline ...
		FOR x = -xr TO xr-1

' compute the second spherical coordinate alpha
			alpha1 = SCR_TO_SPHERE[xscaled >> 16] / 2
			xscaled = xscaled + xinc
			alpha1 = alpha1 + $$SIZEOFTEX/2

' go into a SCS with the z-axis as polar axis
			alpha_beta2 = LOOKUPTABLE[beta1 + alpha1]

' multiply only the beta-coordinate by 2
			alpha_beta3 = ((alpha_beta2*2) & (($$SIZEOFTEX-2)*$$SIZEOFTEX)) | (alpha_beta2 & ($$SIZEOFTEX-1))

' rotate the directional vector
			alpha_beta4 = LOOKUPTABLE[alpha_beta3+phi] + theta
			alpha_beta5 = LOOKUPTABLE[alpha_beta4] + psi

   ' draw the pixel
'			SCREEN[screenpos + x] = TEXTURE[alpha_beta5]
			xscr = x0 + x
			color = palette[TEXTURE[alpha_beta5]]
			SetPixelV (hdc, xscr, yscr, color)
		NEXT x
	NEXT y

END FUNCTION
'
'
' ############################
' #####  draw_sphere ()  #####
' ############################
'
' Description : This function draws a diffuse shaded sphere.
' Arguments 	: phi, theta and psi : angles describing the
' 							orientation of the sphere (angle_in_degree = phi/SIZEOFTEX*360)
' 						: radius : radius of the sphere in pixels
'							: x0, y0 : coordinates of center of sphere
'
FUNCTION  draw_sphere (hdc, phi, theta, psi, radius, x0, y0)

	XLONG x, y							' current pixel-position
	XLONG xr								' width of sphere in current scanline
	XLONG beta1, alpha1 		' initial spherical coordinates
	XLONG xinc, xscaled			' auxiliary variables
	XLONG alpha_beta2, alpha_beta3 ' spherical coordinates of the 2 pt and 3 pt system (the 2 coordinates are stored in a single integer)

	SHARED USHORT LOOKUPTABLE[]
	SHARED ULONG SCR_TO_SPHERE[]

	SHARED UBYTE TEXTURE1[]
	SHARED palette[]

	IFZ TEXTURE1[] THEN
		inittex_diffuse (@TEXTURE1[])
	END IF

	IFZ LOOKUPTABLE[] THEN
		initialize ()
	END IF

	IFZ palette[] THEN
		set_grey_palette ()
	END IF

' for all scanlines ...
	FOR y = -radius+1 TO radius-1

' compute the width of the sphere in this scanline
		xr = sqrt(radius*radius - y*y)
		IF (xr==0) THEN xr = 1

' computer the first spherical coordinate beta
		beta1 = SCR_TO_SPHERE[(y+radius) * $$SIZEOFTEX/(2*radius)] * $$SIZEOFTEX
		xinc = $$SIZEOFTEX * 0x10000 / (2*xr)
		xscaled = 0

' calculate y screen position
		yscr = y0 + y

' for all pixels in this scanline ...
		FOR x = -xr TO xr-1

' compute the second spherical coordinate alpha
			alpha1 = SCR_TO_SPHERE[xscaled >> 16] / 2
			xscaled = xscaled + xinc
			alpha1 = alpha1 + phi

' rotate texture in the first coordinate-system (alpha,beta),
' switch to the next coordinate-system and rotate there
			alpha_beta2 = LOOKUPTABLE[beta1 + alpha1] + theta

' the same procedure again ...
			alpha_beta3 = LOOKUPTABLE[alpha_beta2] + psi

' draw the pixel
'			SCREEN[screenpos + x] = TEXTURE1[alpha_beta3]
			xscr = x0 + x
			color = palette[TEXTURE1[alpha_beta3]]
			SetPixelV (hdc, xscr, yscr, color)
		NEXT x
	NEXT y

END FUNCTION
'
'
' #################################
' #####  draw_sphere_bump ()  #####
' #################################
'
' Description : This function draws a bump-mapped sphere.
' Arguments 	: phi, theta, psi, phi2, theta2 : angles describing the
'								orientation of the bumpmap and the lights
'								(angle_in_degree = phi/SIZEOFTEX*360)
'							: radius : radius of the sphere in pixels.
'							: x0, y0 : coordinates of center of sphere.

FUNCTION  draw_sphere_bump (hdc, phi, theta, psi, phi2, theta2, radius, x0, y0)

	XLONG x, y               ' current pixel-position
	XLONG xr                 ' width of sphere in current scanline
	XLONG screenpos          ' auxiliary variable
	XLONG beta1, alpha1      ' initial spherical coordinates
	XLONG xinc, xscaled      ' auxiliary variables
	XLONG alpha_beta2, alpha_beta3 ' spherical coordinates of the 2pt and 3pt system (the 2 coordinates are stored in a single integer)
	XLONG normal1, normal2

	SHARED USHORT LOOKUPTABLE[]
	SHARED ULONG SCR_TO_SPHERE[]

	SHARED UBYTE TEXTURE1[]

	STATIC USHORT BUMPMAP[]
	SHARED palette[]

	IFZ BUMPMAP[] THEN
		init_bumpmap (@BUMPMAP[])
	END IF

	IFZ TEXTURE1[] THEN
		inittex_diffuse (@TEXTURE1[])
	END IF

	IFZ LOOKUPTABLE[] THEN
		initialize ()
	END IF

	IFZ palette[] THEN
		set_grey_palette ()
	END IF

' for all scanlines ...
	FOR y = -radius+1 TO radius-1

' compute the width of the sphere in this scanline
		xr = sqrt(radius*radius - y*y)
		IF (xr==0) THEN xr = 1

' compute the first spherical coordinate beta
		beta1 = SCR_TO_SPHERE[(y+radius) * $$SIZEOFTEX/(2*radius)] * $$SIZEOFTEX
		xinc = $$SIZEOFTEX * 0x10000 / (2*xr)
		xscaled = 0

' calculate y screen position
		yscr = y0 + y

' for all pixels in this scanline ...
		FOR x = -xr TO xr-1

' compute the second spherical coordinate alpha
			alpha1 = SCR_TO_SPHERE[xscaled >> 16] / 2
			xscaled = xscaled + xinc
			alpha1 = alpha1 + phi

' rotate texture in the first coordinate-system (alpha,beta),
' switch to the next coordinate-system and rotate there
			alpha_beta2 = LOOKUPTABLE[beta1 + alpha1] + theta

' the same procedure again ...
			alpha_beta3 = LOOKUPTABLE[alpha_beta2] + psi

' draw the pixel
			normal1 = BUMPMAP[alpha_beta3] + phi2
			normal2 = LOOKUPTABLE[normal1] + theta2
'			SCREEN[screenpos + x] = TEXTURE1[normal2]
			xscr = x0 + x
			color = palette[TEXTURE1[normal2]]
			SetPixelV (hdc, xscr, yscr, color)
		NEXT x
	NEXT y

END FUNCTION
'
'
' ###################################
' #####  DrawCustomFontText ()  #####
' ###################################
'
FUNCTION  DrawCustomFontText (hDC, fontName$, pointSize, weight, italic, underline, angle#, x, y, text$, @lineSpace)

	hCustFont = NewFont (fontName$, pointSize, weight, italic, underline, angle#)
	hOldFont = SelectObject (hDC, hCustFont)
	GetLineHeight (hDC, @lineSpace, @pixels, @leading)
	TextOutA (hDC, x, y, &text$, LEN(text$))
	SelectObject (hDC, hOldFont)
	DeleteObject (hCustFont)

END FUNCTION
'
'
' ##############################
' #####  GetLineHeight ()  #####
' ##############################
'
FUNCTION  GetLineHeight (hDC, @lineSpace, @pixels, @leading)

	TEXTMETRIC tm

	GetTextMetricsA (hDC, &tm)
	lineSpace 	= tm.height + tm.externalLeading
	pixels 			= tm.height
	leading 		= tm.externalLeading

END FUNCTION
'
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline, angle#)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underlined
	lf.escapement = angle# * 10									' set text rotation
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle


END FUNCTION
END PROGRAM
