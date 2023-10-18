'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM "atimer"
VERSION "0.0003"
'
IMPORT "xst"
'
DECLARE  FUNCTION  Entry ()
INTERNAL FUNCTION  Timer (timer, count, msec, time)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' This function tells XstStartTimer() to:
'   Create and start a timer.
'   Return timer number in timer1.
'   Tell timer1 to cycle 10 times.
'   Set timer1 interval to 1000 milliseconds.
'   Call Timer() whenever timer1 times out.
'
'   Create and start another timer.
'   Return timer number in timer2.
'   Tell timer2 to cycle 3 times.
'   Set timer2 interval to 2500 milliseconds.
'   Call Timer() whenever timer2 times out.
'
' *************************************
' *****  Timers Are Asynchronous  *****
' *************************************
'
' Note that timeouts can occur at any machine instruction
' boundary in your program.  In other words, timeouts can
' interrupt your program at any point, including part way
' between lines in your program, and call the function you
' specified in XstStartTimer().  This function can thus
' encounter variables, or sets of related variables, in
' invalid or partially updated state if they are modified
' elsewhere in your program.  Timeout functions in many
' programs simply increment a timeout variable that is
' examined periodically by your program, and acted on and
' decremented when found to be non-zero.
'
' Note that GraphicsDesigner timers and timeouts do not
' have these considerations, since your program has to
' call XgrProcessMessage(), XgrPeekMessage(), or another
' GraphicsDesigner function to respond to timeout messages.
'
FUNCTION  Entry ()
'
	PRINT "*****  start atimer.x program  *****"
	XstStartTimer (@timer1, 10, 1000, &Timer())
	XstStartTimer (@timer2, 3, 2500, &Timer())
	XstGetSystemTime (@atime)
	XstSleep (10000)
	XstGetSystemTime (@ztime)
	PRINT "actual sleep time = "; ztime-atime; " ms"
	PRINT "*****  done atimer.x program  *****"
	PRINT
END FUNCTION
'
'
' ######################
' #####  Timer ()  #####
' ######################
'
' This function can change count to add or subtract remaining timeouts.
' Entry() told XstStartTimer() to call this function upon timeouts.
' This function is called whenever either timer times out.
' This function can call XstKillTimer() to kill timers.
' This function can return -1 to kill the timer.
'
FUNCTION  Timer (timer, count, msec, time)
'
	PRINT RJUST$(STRING$(timer),5); RJUST$(STRING$(count),3); RJUST$(STRING$(msec),6); RJUST$(STRING$(time),10)
	IF (count = 8) THEN count = 5								' reduce count to 5
	IF (count = 3) THEN RETURN (-1)							' one way to kill timer
	IF (count = 1) THEN XstKillTimer (timer)		' kill timer early
END FUNCTION
END PROGRAM
