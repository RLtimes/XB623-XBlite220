'
'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"aeasy"
VERSION	"0.0002"
'
IMPORT	"xgr"
IMPORT	"xui"
'
DECLARE  FUNCTION  EasyGui ()
'
'
' ########################
' #####  EasyGui ()  #####
' ########################
'
FUNCTION  EasyGui ()
	$SwitchWindow = 1
	$EasyGuiWindow = 2
	$NanoWayWindow = 3
'
' create and configure the $SwitchWindow
'
	XuiCreateWindow      (@grid, @"XuiPushButton", 100, 300, 200, 100, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $SwitchWindow, -1)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightGreen, $$Yellow, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @"Press Here\nTo Switch Windows")
	XuiSendStringMessage ( grid, @"SetFont", 320, 600, 400, 0, 0, @"Serif")
	XuiSendStringMessage ( grid, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
	switch = grid
'
' create and configure the $EasyGuiWindow
'
	XuiCreateWindow      (@grid, @"XuiCheckBox", 308, 300, 200, 100, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $EasyGuiWindow, -1)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, $$Yellow, -1, -1, 0, 0)
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @"EasyGui Is\n!!!  So Damn Easy  !!!")
	XuiSendStringMessage ( grid, @"SetFont", 320, 600, 400, 0, 0, @"Serif")
	XuiSendStringMessage ( grid, @"SetValue", -1, 0, 0, 0, 0, 0)
	XuiSendStringMessage ( grid, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
	easy = grid
'
' create and configure the $NanoWayWindow
'
	XuiCreateWindow      (@grid, @"XuiDialog3B", 100, 427, 408, 200, 0, "")
	XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $NanoWayWindow, -1)
	XuiSendStringMessage ( grid, @"SetColor", $$LightBlue, $$Yellow, -1, -1, 1, 0)
	XuiSendStringMessage ( grid, @"SetColorExtra", -1, -1, $$Black, $$Yellow, 1, 0)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightGreen, -1, -1, -1, 3, 0)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightCyan, -1, -1, -1, 4, 0)
	XuiSendStringMessage ( grid, @"SetColor", $$BrightMagenta, -1, -1, -1, 5, 0)
	XuiSendStringMessage ( grid, @"SetFocusColor", $$BrightGreen, -1, -1, -1, 3, 0)
	XuiSendStringMessage ( grid, @"SetFocusColor", $$BrightCyan, -1, -1, -1, 4, 0)
	XuiSendStringMessage ( grid, @"SetFocusColor", $$BrightMagenta, -1, -1, -1, 5, 0)
	XuiSendStringMessage ( grid, @"SetFont", 480, 600, 400, 0, 1, @"Serif")
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 1, @"Easy Gui\nFrom NanoWay")
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 2, @"Demo By Steve Fraud")
	XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 5, @"Quit")
	XuiSendStringMessage ( grid, @"SetTexture", $$TextureShadow, -1, -1, -1, 1, 0)
	nanoway = grid
	visible = easy
'
' 1: Wait for one message in XgrProcessMessages(1) then process it.
' 2: Call XuiGetNextCallback() to check for a pending callback message.
' 3: If a callback message is ready and returned by XuiGetNextCallback(),
'    then go to a subroutine designed to handle callbacks from the
'    window that caused the callback.
' 4: When the callback is processed, loop to continue processing
'
' To put this loop in a function that a running program can call
' periodically to process user actions, just change the argument
' to XgrProcessMessages() to -2 and change the last line to
' "LOOP WHILE ready".
'
	DO
		XgrProcessMessages (1)
		grid = 0 : message = 0 : v0 = 0 : v1 = 0 : v2 = 0 : v3 = 0 : rr0 = 0 : r1$ = ""
		ready = XuiGetNextCallback (@grid, @message$, @v0, @v1, @v2, @v3, @rr0, @r1$)
		r0 = rr0 AND 0xFFFF
		wintag = rr0 >> 16
		IF ready THEN
			SELECT CASE wintag
				CASE $SwitchWindow		: GOSUB SwitchWindow
				CASE $EasyGuiWindow		: GOSUB EasyGuiWindow
				CASE $NanoWayWindow		: GOSUB NanoWayWindow
				CASE ELSE							: PRINT "You're pulling my leg, right?"
			END SELECT
		END IF
	LOOP
'
'
' *****  SwitchWindow  *****
'
SUB SwitchWindow
	SELECT CASE visible
		CASE easy			: XuiSendStringMessage (easy, @"HideWindow", 0, 0, 0, 0, 0, 0)
										XuiSendStringMessage (nanoway, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
										visible = nanoway
		CASE nanoway	: XuiSendStringMessage (nanoway, @"HideWindow", 0, 0, 0, 0, 0, 0)
										XuiSendStringMessage (easy, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
										visible = easy
		CASE ELSE			: PRINT "Programmer Is BrainDamaged"
	END SELECT
END SUB
'
'
' *****  EasyGuiWindow  *****
'
SUB EasyGuiWindow
	XuiSendStringMessage (grid, @"GetValue", @value, 0, 0, 0, r0, 0)
	IF value THEN
		string$ = "EasyGui\xAE Is\n!!!  So Damn Easy  !!!"
	ELSE
		string$ = "EasyGui\x99 Is\n!!!  So Damn Easy  !!!\n\xAB\xAB\xAB  NOT  \xBB\xBB\xBB"
	END IF
	XuiSendStringMessage (grid, @"SetTextString", 0, 0, 0, 0, r0, @string$)
	XuiSendStringMessage (grid, @"Redraw", 0, 0, 0, 0, 0, 0)
END SUB
'
'
' *****  NanoWayWindow  *****
'
SUB NanoWayWindow
	XuiSendStringMessage (grid, "GetTextString", 0, 0, 0, 0, r0, @string$)
	XuiSendStringMessage (grid, "GetTextString", 0, 0, 0, 0, 2, @text$)
	PRINT "$NanoWayWindow : "; LJUST$(r1$,8); " : "; RJUST$(message$,12); " : "; CJUST$(string$,21); " : "; text$
	IF (r0 = 5) THEN QUIT (0)
END SUB
END FUNCTION
END PROGRAM
