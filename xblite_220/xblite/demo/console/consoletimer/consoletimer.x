

'	a console timer taken from the win32 api programmer's reference.
' example provided by Michael McKenzie

PROGRAM "consoletimer"
CONSOLE

	IMPORT "winmm"
	IMPORT "kernel32"

DECLARE FUNCTION Entry () 
DECLARE FUNCTION TimerCallback(wtimerid, msg, dwUser, dw1, dw2) 
DECLARE FUNCTION SetTimerCallback(npSeq, msInterval)
DECLARE FUNCTION DestroyTimer() 

' This topic describes how an application can use the timer services.
' First, the application calls the timeGetDevCaps function to determine
' the minimum and maximum resolution supported by the timer services.
' Before setting up any timer events, the application uses the timeBeginPeriod
' function to establish the minimum timer resolution it will use, as shown
' in the following example: 

$$TARGET_RESOLUTION = 1  ' millisecond accuracy set between 1 & 1000000


FUNCTION Entry ()
	SHARED wTimerID, wTimerRes
	TIMECAPS tc

	IF (timeGetDevCaps (&tc, SIZE (TIMECAPS)) != $$TIMERR_NOERROR) THEN
		RETURN		' Error  application can't continue.
	END IF
	PRINT "period min, max:"; tc.wPeriodMin, tc.wPeriodMax

	wTimerRes = MIN (MAX (tc.wPeriodMin, XLONG ($$TARGET_RESOLUTION)), tc.wPeriodMax)
	PRINT "wTimerRes="; wTimerRes

	timeBeginPeriod (wTimerRes)
	SetTimerCallback (npSeq, 1000)

	Sleep (10000)

	' Finally, to cancel the minimum timer resolution it established, the application calls
	' timeEndPeriod as follows.
	timeEndPeriod (wTimerRes)
	DestroyTimer ()

END FUNCTION

' To start the timer event, the application specifies the amount of time before the callback occurs,
' the required resolution, the address of the callback function, and user data to supply with the callback.
' The application can use a function like the following to start a one-time timer event.
FUNCTION SetTimerCallback (npSeq, msInterval)		' Sequencer data         ' Event interval
	SHARED wTimerRes
	SHARED wTimerID

	wTimerID = timeSetEvent (msInterval, wTimerRes, &TimerCallback (), npSeq, $$TIME_PERIODIC)		' or use $$TIME_ONESHOT
	IF (wTimerID != 0) THEN RETURN $$TIMERR_NOCANDO ELSE RETURN $$TIMERR_NOERROR

END FUNCTION

' The following callback function is used for the one-shot timer.
FUNCTION TimerCallback (wtimerid, msg, dwUser, dw1, dw2)
	SHARED wTimerID

	PRINT wtimerid, msg, dwUser, dw1, dw2
	' wTimerID = 0

END FUNCTION

' Before freeing the dynamic-link library (DLL) that contains the callback function,
' the application cancels any outstanding timers. To cancel one timer event, it can call
' the following function.
FUNCTION DestroyTimer ()
	SHARED wTimerID

	IF (wTimerID) THEN
		timeKillEvent (wTimerID)		' Cancel the event
		wTimerID = 0
	END IF

END FUNCTION
END PROGRAM

