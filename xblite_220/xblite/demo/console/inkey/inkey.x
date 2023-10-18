'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program demonstrates using an XioInkey()
' function. The XioInkey() function returns a
' character code when a keyboard key has been
' pressed. It does not wait for a keyboard
' event. If there is no pending key in the
' input buffer, then program execution continues
' after XioInkey() has checked for a keystroke.
'
PROGRAM "inkey"
VERSION "0.0003"
CONSOLE
'
	IMPORT "xst"
	IMPORT "kernel32"
	IMPORT "xio"
'
DECLARE  FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	PRINT "Press any key."
	PRINT "Hit ENTER key to exit."

	DO															' start a loop
		chr = XioInkey ()							' check for keyboard events

		IF chr THEN
			IF (chr >= 0) && (chr <= 255) THEN
				c$ = CHR$(chr)
				PRINT "key = "; chr, c$
			ELSE
				PRINT "key code ="; chr
			END IF
		END IF
		Sleep (0)											' give up time slice to other processes
	LOOP UNTIL chr = 13	 						' return if Enter is pressed

END FUNCTION
END PROGRAM
