'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"scroll"
VERSION	"0.0000"
'
'
IMPORT	"xst"
IMPORT	"xui"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()
'
	DIM text$[]
	XstGetConsoleGrid (@console)
	XuiSendStringMessage (console, "SetTextArray", 0, 0, 0, 0, 0, @text$[])
	XuiSendStringMessage (console, "Redraw", 0, 0, 0, 0, 0, 0)
'
	FOR i = 0 TO 255
		IF (i == 220) THEN
			PRINT i; " : 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
		ELSE
			PRINT i
		END IF
	NEXT
'
' #####  SINGLE STEP THROUGH TO UNDERSTAND HOW THIS WORKS  #####
'
' NOTE: This first group puts the text cursor on the line specified
' in the v1 argument.  But it many only scroll far enough to make
' the new cursor line visible, so the cursor-line may be at the
' bottom of the console window.
'
	XuiSendStringMessage (console, "SetTextCursor", 0, 20, 0, 0, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 40, 0, 0, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 60, 0, 0, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 80, 0, 0, 0, 0)
'	XuiSendStringMessage (console, "Redraw", 0, 0, 0, 0, 0, 0)
'
' NOTE: This second group puts the text cursor on the line specified
' in the v1 argument.  But the following function also have an argument
' in the v3 argument to specify the top line that should be displayed.
' In addition, the next-to-last function call has a non-zero v0 argument
' to set the cursor before the 16th character and a non-zero v2 argument
' to scroll the window 8 characters left.  The last function call scrolls
' back to the normal horizontal position.  Note this also, if the v2,v3
' arguments contain values that would put the cursor outside the window,
' they are adjusted so the cursor is visible.
'
	XuiSendStringMessage (console, "SetTextCursor", 0, 100, 0, 100, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 120, 0, 120, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 140, 0, 139, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 160, 0, 158, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 180, 0, 180, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 200, 0, 199, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 16, 220, 8, 218, 0, 0)
	XuiSendStringMessage (console, "SetTextCursor", 0, 240, 0, 236, 0, 0)
END FUNCTION
END PROGRAM
