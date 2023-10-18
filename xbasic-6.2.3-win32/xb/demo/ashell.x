'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"ashell"
VERSION	"0.0000"
'
IMPORT "xst"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' NOTE: if the first character in the string argument passed
' to SHELL() is a colon == ":", then SHELL() returns immediately
' after executing the command string.  Otherwise SHELL() hangs
' until the command strings is completed, which means the invoked
' program terminates.
'
FUNCTION  Entry ()
'
' start NOTEPAD and have it open document c:/windows/programs.txt
'
	a = SHELL (":c:/windows/notepad.exe c:/windows/programs.txt")
'
' find the XBasic directory
'
	drive = 'b'
'
	DO UNTIL text$
		INC drive
		text$ = ""
		drive$ = CHR$ (drive)
		file$ = drive$ + ":/xb/new.hlp"
		XstLoadString (@file$, @text$)
	LOOP UNTIL (drive >= 'g')
'
' if XBasic directory is found, have Windows Explorer display that directory
'
	IF text$ THEN
		text$ = "c:\\windows\\explorer.exe " + CHR$(drive) + ":\\xb"
		a = SHELL (text$)
	ELSE
		a = SHELL (":c:/windows/explorer.exe c:\\")
	END IF
END FUNCTION
END PROGRAM
