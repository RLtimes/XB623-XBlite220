'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' First version of XioKeyPress () for
' monitoring keyboard input in console progs.
' Also see inkey.x demo.
'
PROGRAM	"keypress"
VERSION	"0.0002"
CONSOLE
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"gdi32.dec"
	IMPORT  "user32"
	IMPORT  "kernel32"

'
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  GetChar (@shift, @ctrl, @vk)
DECLARE FUNCTION  XioKeyPress ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

	PRINT "Press any key..."
	PRINT "Press ENTER to QUIT."

	DO WHILE (k != $$VK_RETURN)
		k = XioKeyPress ()
		k$ = ""
		IF k > 31 THEN k$ = CHR$(k)
		IF k THEN PRINT "key pressed: "; k, k$
	LOOP

	a$ = INLINE$ ("Press ENTER to QUIT >")

END FUNCTION
'
'
' ########################
' #####  GetChar ()  #####
' ########################
'
FUNCTION  GetChar (@shift, @ctrl, @vk)

	INPUT_RECORD inrec
	KEY_EVENT_RECORD r

	h = GetStdHandle ($$STD_INPUT_HANDLE)
  done = 0
  DO WHILE (!done)
		nr = 0
		ReadConsoleInputA (h, &inrec, 1, &nr)
		IF (inrec.EventType != $$KEY_EVENT) THEN DO DO
    r = inrec.KeyEvent
    IF (!r.bKeyDown) THEN DO DO
    k = r.wVirtualKeyCode
    IF( (k==$$VK_SHIFT) || (k==$$VK_CONTROL) || (k==$$VK_CAPITAL) || (k==$$VK_NUMLOCK) || (k==$$VK_SCROLL) || (k==$$VK_SNAPSHOT) || (k==$$VK_MENU) ) THEN DO DO
    s = r.dwControlKeyState
    IF ((s & $$LEFT_ALT_PRESSED) || (s & $$RIGHT_ALT_PRESSED)) THEN DO DO
    shp = s & $$SHIFT_PRESSED
    cpl = s & $$CAPSLOCK_ON
    shift = (shp && !cpl) || (!shp && cpl)
    ctrl = (s & $$RIGHT_CTRL_PRESSED) || (s & $$LEFT_CTRL_PRESSED)
    vk = k
    done = 1
	LOOP
  RETURN r.AsciiChar

END FUNCTION
'
'
' ############################
' #####  XioKeyPress ()  #####
' ############################
'
FUNCTION  XioKeyPress ()

	STATIC Kbd_Queue

  IF (Kbd_Queue) THEN
		ret = Kbd_Queue
		Kbd_Queue = 0
		RETURN ret
	END IF

  ac = GetChar (@sh, @ctr, @vk)

  IF (sh && (ac==9)) THEN 							' shift + tab = tab-left
		Kbd_Queue = 0x0F										' return 15
		RETURN 0
	END IF

  IF (ac) THEN RETURN ac								' ascii

	SELECT CASE vk

		CASE $$VK_LEFT		: IF (ctr) THEN Kbd_Queue=-(0x73) ELSE Kbd_Queue=-(0x4B)
		CASE $$VK_RIGHT		: IF (ctr) THEN Kbd_Queue=-(0x74) ELSE Kbd_Queue=-(0x4D)
		CASE $$VK_HOME		: IF (ctr) THEN Kbd_Queue=-(0x77) ELSE Kbd_Queue=-(0x47)
		CASE $$VK_END			: IF (ctr) THEN Kbd_Queue=-(0x75) ELSE Kbd_Queue=-(0x4F)
		CASE $$VK_UP			: Kbd_Queue=-(0x48)
		CASE $$VK_DOWN		: Kbd_Queue=-(0x50)
		CASE $$VK_DELETE	: Kbd_Queue=-(0x53)
		CASE $$VK_PRIOR		: Kbd_Queue=-(0x49)
		CASE $$VK_NEXT		: Kbd_Queue=-(0x51)
		CASE $$VK_INSERT	: Kbd_Queue=-(0x52)
		CASE $$VK_F1			: Kbd_Queue=-(0x3B)
		CASE $$VK_F2			: Kbd_Queue=-(0x3C)
		CASE $$VK_F3			: Kbd_Queue=-(0x3D)
		CASE $$VK_F4			: Kbd_Queue=-(0x3E)
		CASE $$VK_F5			: Kbd_Queue=-(0x3F)
		CASE $$VK_F6			: Kbd_Queue=-(0x40)
		CASE $$VK_F7			: Kbd_Queue=-(0x41)
		CASE $$VK_F8			: Kbd_Queue=-(0x42)
		CASE $$VK_F9			: Kbd_Queue=-(0x43)
		CASE $$VK_F10			: Kbd_Queue=-(0x44)
		CASE $$VK_F11			: Kbd_Queue=-(0x85)
		CASE $$VK_F12			: Kbd_Queue=-(0x86)
    CASE ELSE					: Kbd_Queue='?'
	END SELECT

  RETURN 0

END FUNCTION
END PROGRAM
