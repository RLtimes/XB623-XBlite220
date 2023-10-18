'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"abuffer"
VERSION	"0.0007"
'
IMPORT	"xst"		' Standard
IMPORT	"xma"		' Mathematics
IMPORT	"xgr"		' GraphicsDesigner
IMPORT	"xui"		' GuiDesigner
'
'
' This program is the same as acircle.x except for a short marked section
' of code added to the "SUB Resize" subroutine of grid function Circle().
' The added code attaches an "image grid" to "buffer" the main drawing grid.
' Once attached to the drawing grid, all graphics drawing on the drawing grid
' is automatically drawn onto the "buffer grid" also.  When the drawing grid
' is covered then uncovered by another window, the drawn graphics in the
' drawing grid are lost.  But the attached buffer grid still contains the
' drawn graphics and GraphicsDesigner automatically restores the graphics
' to the drawing grid by copying the buffer grid onto the drawing grid.
' Thus this program shows how a few lines of code on place in a program
' can capture and automatically restore arbitrary graphics to any grid.
' Again, the only difference between this program and acircle.x is the
' short marked section in the Resize subroutine in grid function Circle().
' This code also resizes the buffer grid when the drawing grid is resized.
'
' To clearly see the difference the buffer grid makes, do the following
' in acircle.x then in abuffer.x (this program).
'
' 1. Run the program.
' 2. Click "Pause" to freeze some drawn graphics on the drawing grid.
' 3. Cover part of the graphics on the drawing grid with another window.
' 4. Remove the window to uncover the drawing grid.
' 5. Look at the graphics.
'
' In acircle.x the drawn graphics is lost where the drawing grid was uncovered.
' In abuffer.x the drawn graphics is automatically restored.
'
'
'
DECLARE  FUNCTION  Entry         ()
INTERNAL FUNCTION  InitGui       ()
INTERNAL FUNCTION  InitProgram   ()
INTERNAL FUNCTION  CreateWindows ()
INTERNAL FUNCTION  Circle        (grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  CircleCode    (grid, message, v0, v1, v2, v3, r0, ANY)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()
	SHARED  terminateProgram
	SHARED	paused
'
	InitGui ()										' initialize messages
	InitProgram ()								' initialize this program
	CreateWindows ()							' create main window and others
'
' This message loop is modified to draw the circle pattern continuously
' when not paused, but still process messages whenever they occur.
'
	DO														' the message loop
		count = 1										' wait for 1+ messages, then process 1
		IFZ paused THEN							' if circle drawing not paused
			CircleCode (0, #Redraw, 0, 0, 0, 0, 0, 0)		' draw a few circles
			count = 0									' avoid hang up in XgrProcessMessages()
		END IF
		XgrProcessMessages (count)	' process zero or one message
	LOOP UNTIL terminateProgram		' and repeats until program is terminated
END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
' InitGui() initializes cursor, icon, message, and display variables.
' Programs can reference these variables, but must never change them.
'
FUNCTION  InitGui ()
'
' ***************************************
' *****  Register Standard Cursors  *****
' ***************************************
'
	XgrRegisterCursor (@"Arrow",			@#cursorArrow)
	XgrRegisterCursor (@"UpArrow",		@#cursorArrowN)
	XgrRegisterCursor (@"Arrow",			@#cursorArrowNW)
	XgrRegisterCursor (@"SizeNS",			@#cursorArrowsNS)
	XgrRegisterCursor (@"SizeWE",			@#cursorArrowsWE)
	XgrRegisterCursor (@"SizeNWSE",		@#cursorArrowsNWSE)
	XgrRegisterCursor (@"SizeNESW",		@#cursorArrowsNESW)
	XgrRegisterCursor (@"SizeAll",		@#cursorArrowsAll)
	XgrRegisterCursor (@"CrossHair",	@#cursorCrosshair)
	XgrRegisterCursor (@"Arrow",			@#cursorDefault)
	XgrRegisterCursor (@"Wait",				@#cursorHourglass)
	XgrRegisterCursor (@"Insert",			@#cursorInsert)
	XgrRegisterCursor (@"No",					@#cursorNo)
	XgrRegisterCursor (@"Arrow",			@#defaultCursor)
'
'
' ********************************************
' *****  Register Standard Window Icons  *****
' ********************************************
'
	XgrRegisterIcon (@"hand",					@#iconHand)
	XgrRegisterIcon (@"asterisk",			@#iconAsterisk)
	XgrRegisterIcon (@"question",			@#iconQuestion)
	XgrRegisterIcon (@"exclamation",	@#iconExclamation)
	XgrRegisterIcon (@"application",	@#iconApplication)
'
	XgrRegisterIcon (@"hand",					@#iconStop)						' alias
	XgrRegisterIcon (@"asterisk",			@#iconInformation)		' alias
	XgrRegisterIcon (@"application",  @#iconBlank)					' alias
'
	XgrRegisterIcon (@"window",				@#iconWindow)					' custom
'
'
' ******************************
' *****  Register Messages *****  Create message numbers for message names
' ******************************
'
	XgrRegisterMessage (@"Blowback",										@#Blowback)
	XgrRegisterMessage (@"Callback",										@#Callback)
	XgrRegisterMessage (@"Cancel",											@#Cancel)
	XgrRegisterMessage (@"Change",											@#Change)
	XgrRegisterMessage (@"CloseWindow",									@#CloseWindow)
	XgrRegisterMessage (@"ContextChange",								@#ContextChange)
	XgrRegisterMessage (@"Create",											@#Create)
	XgrRegisterMessage (@"CreateValueArray",						@#CreateValueArray)
	XgrRegisterMessage (@"CreateWindow",								@#CreateWindow)
	XgrRegisterMessage (@"CursorH",											@#CursorH)
	XgrRegisterMessage (@"CursorV",											@#CursorV)
	XgrRegisterMessage (@"Deselected",									@#Deselected)
	XgrRegisterMessage (@"Destroy",											@#Destroy)
	XgrRegisterMessage (@"Destroyed",										@#Destroyed)
	XgrRegisterMessage (@"DestroyWindow",								@#DestroyWindow)
	XgrRegisterMessage (@"Disable",											@#Disable)
	XgrRegisterMessage (@"Disabled",										@#Disabled)
	XgrRegisterMessage (@"Displayed",										@#Displayed)
	XgrRegisterMessage (@"DisplayWindow",								@#DisplayWindow)
	XgrRegisterMessage (@"Enable",											@#Enable)
	XgrRegisterMessage (@"Enabled",											@#Enabled)
	XgrRegisterMessage (@"Enter",												@#Enter)
	XgrRegisterMessage (@"ExitMessageLoop",							@#ExitMessageLoop)
	XgrRegisterMessage (@"Find",												@#Find)
	XgrRegisterMessage (@"FindForward",									@#FindForward)
	XgrRegisterMessage (@"FindReverse",									@#FindReverse)
	XgrRegisterMessage (@"Forward",											@#Forward)
	XgrRegisterMessage (@"GetAlign",										@#GetAlign)
	XgrRegisterMessage (@"GetBorder",										@#GetBorder)
	XgrRegisterMessage (@"GetBorderOffset",							@#GetBorderOffset)
	XgrRegisterMessage (@"GetCallback",									@#GetCallback)
	XgrRegisterMessage (@"GetCallbackArgs",							@#GetCallbackArgs)
	XgrRegisterMessage (@"GetCan",											@#GetCan)
	XgrRegisterMessage (@"GetCharacterMapArray",				@#GetCharacterMapArray)
	XgrRegisterMessage (@"GetClipGrid",									@#GetClipGrid)
	XgrRegisterMessage (@"GetColor",										@#GetColor)
	XgrRegisterMessage (@"GetColorExtra",								@#GetColorExtra)
	XgrRegisterMessage (@"GetCursor",										@#GetCursor)
	XgrRegisterMessage (@"GetCursorXY",									@#GetCursorXY)
	XgrRegisterMessage (@"GetDisplay",									@#GetDisplay)
	XgrRegisterMessage (@"GetEnclosedGrids",						@#GetEnclosedGrids)
	XgrRegisterMessage (@"GetEnclosingGrid",						@#GetEnclosingGrid)
	XgrRegisterMessage (@"GetFocusColor",								@#GetFocusColor)
	XgrRegisterMessage (@"GetFocusColorExtra",					@#GetFocusColorExtra)
	XgrRegisterMessage (@"GetFont",											@#GetFont)
	XgrRegisterMessage (@"GetFontNumber",								@#GetFontNumber)
	XgrRegisterMessage (@"GetGridFunction",							@#GetGridFunction)
	XgrRegisterMessage (@"GetGridFunctionName",					@#GetGridFunctionName)
	XgrRegisterMessage (@"GetGridName",									@#GetGridName)
	XgrRegisterMessage (@"GetGridNumber",								@#GetGridNumber)
	XgrRegisterMessage (@"GetGridType",									@#GetGridType)
	XgrRegisterMessage (@"GetGridTypeName",							@#GetGridTypeName)
	XgrRegisterMessage (@"GetGroup",										@#GetGroup)
	XgrRegisterMessage (@"GetHelp",											@#GetHelp)
	XgrRegisterMessage (@"GetHelpFile",									@#GetHelpFile)
	XgrRegisterMessage (@"GetHelpString",								@#GetHelpString)
	XgrRegisterMessage (@"GetHelpStrings",							@#GetHelpStrings)
	XgrRegisterMessage (@"GetHintString",								@#GetHintString)
	XgrRegisterMessage (@"GetImage",										@#GetImage)
	XgrRegisterMessage (@"GetImageCoords",							@#GetImageCoords)
	XgrRegisterMessage (@"GetIndent",										@#GetIndent)
	XgrRegisterMessage (@"GetInfo",											@#GetInfo)
	XgrRegisterMessage (@"GetJustify",									@#GetJustify)
	XgrRegisterMessage (@"GetKeyboardFocus",						@#GetKeyboardFocus)
	XgrRegisterMessage (@"GetKeyboardFocusGrid",				@#GetKeyboardFocusGrid)
	XgrRegisterMessage (@"GetKidNumber",								@#GetKidNumber)
	XgrRegisterMessage (@"GetKids",											@#GetKids)
	XgrRegisterMessage (@"GetKidArray",									@#GetKidArray)
	XgrRegisterMessage (@"GetKind",											@#GetKind)
	XgrRegisterMessage (@"GetMaxMinSize",								@#GetMaxMinSize)
	XgrRegisterMessage (@"GetMessageFunc",							@#GetMessageFunc)
	XgrRegisterMessage (@"GetMessageFuncArray",					@#GetMessageFuncArray)
	XgrRegisterMessage (@"GetMessageSub",								@#GetMessageSub)
	XgrRegisterMessage (@"GetMessageSubArray",					@#GetMessageSubArray)
	XgrRegisterMessage (@"GetModalInfo",								@#GetModalInfo)
	XgrRegisterMessage (@"GetModalWindow",							@#GetModalWindow)
	XgrRegisterMessage (@"GetParent",										@#GetParent)
	XgrRegisterMessage (@"GetPosition",									@#GetPosition)
	XgrRegisterMessage (@"GetProtoInfo",								@#GetProtoInfo)
	XgrRegisterMessage (@"GetRedrawFlags",							@#GetRedrawFlags)
	XgrRegisterMessage (@"GetSize",											@#GetSize)
	XgrRegisterMessage (@"GetSmallestSize",							@#GetSmallestSize)
	XgrRegisterMessage (@"GetState",										@#GetState)
	XgrRegisterMessage (@"GetStyle",										@#GetStyle)
	XgrRegisterMessage (@"GetTabArray",									@#GetTabArray)
	XgrRegisterMessage (@"GetTabWidth",									@#GetTabWidth)
	XgrRegisterMessage (@"GetTextArray",								@#GetTextArray)
	XgrRegisterMessage (@"GetTextArrayBounds",					@#GetTextArrayBounds)
	XgrRegisterMessage (@"GetTextArrayLine",						@#GetTextArrayLine)
	XgrRegisterMessage (@"GetTextArrayLines",						@#GetTextArrayLines)
	XgrRegisterMessage (@"GetTextCursor",								@#GetTextCursor)
	XgrRegisterMessage (@"GetTextFilename",							@#GetTextFilename)
	XgrRegisterMessage (@"GetTextPosition",							@#GetTextPosition)
	XgrRegisterMessage (@"GetTextSelection",						@#GetTextSelection)
	XgrRegisterMessage (@"GetTextString",								@#GetTextString)
	XgrRegisterMessage (@"GetTextStrings",							@#GetTextStrings)
	XgrRegisterMessage (@"GetTexture",									@#GetTexture)
	XgrRegisterMessage (@"GetTimer",										@#GetTimer)
	XgrRegisterMessage (@"GetValue",										@#GetValue)
	XgrRegisterMessage (@"GetValues",										@#GetValues)
	XgrRegisterMessage (@"GetValueArray",								@#GetValueArray)
	XgrRegisterMessage (@"GetWindow",										@#GetWindow)
	XgrRegisterMessage (@"GetWindowFunction",						@#GetWindowFunction)
	XgrRegisterMessage (@"GetWindowGrid",								@#GetWindowGrid)
	XgrRegisterMessage (@"GetWindowIcon",								@#GetWindowIcon)
	XgrRegisterMessage (@"GetWindowSize",								@#GetWindowSize)
	XgrRegisterMessage (@"GetWindowTitle",							@#GetWindowTitle)
	XgrRegisterMessage (@"GotKeyboardFocus",						@#GotKeyboardFocus)
	XgrRegisterMessage (@"GrabArray",										@#GrabArray)
	XgrRegisterMessage (@"GrabTextArray",								@#GrabTextArray)
	XgrRegisterMessage (@"GrabTextString",							@#GrabTextString)
	XgrRegisterMessage (@"GrabValueArray",							@#GrabValueArray)
	XgrRegisterMessage (@"Help",												@#Help)
	XgrRegisterMessage (@"Hidden",											@#Hidden)
	XgrRegisterMessage (@"HideTextCursor",							@#HideTextCursor)
	XgrRegisterMessage (@"HideWindow",									@#HideWindow)
	XgrRegisterMessage (@"Initialize",									@#Initialize)
	XgrRegisterMessage (@"Initialized",									@#Initialized)
	XgrRegisterMessage (@"Inline",											@#Inline)
	XgrRegisterMessage (@"InquireText",									@#InquireText)
	XgrRegisterMessage (@"KeyboardFocusBackward",				@#KeyboardFocusBackward)
	XgrRegisterMessage (@"KeyboardFocusForward",				@#KeyboardFocusForward)
	XgrRegisterMessage (@"KeyDown",											@#KeyDown)
	XgrRegisterMessage (@"KeyUp",												@#KeyUp)
	XgrRegisterMessage (@"LostKeyboardFocus",						@#LostKeyboardFocus)
	XgrRegisterMessage (@"LostTextSelection",						@#LostTextSelection)
	XgrRegisterMessage (@"Maximized",										@#Maximized)
	XgrRegisterMessage (@"MaximizeWindow",							@#MaximizeWindow)
	XgrRegisterMessage (@"Maximum",											@#Maximum)
	XgrRegisterMessage (@"Minimized",										@#Minimized)
	XgrRegisterMessage (@"MinimizeWindow",							@#MinimizeWindow)
	XgrRegisterMessage (@"Minimum",											@#Minimum)
	XgrRegisterMessage (@"MonitorContext",							@#MonitorContext)
	XgrRegisterMessage (@"MonitorHelp",									@#MonitorHelp)
	XgrRegisterMessage (@"MonitorKeyboard",							@#MonitorKeyboard)
	XgrRegisterMessage (@"MonitorMouse",								@#MonitorMouse)
	XgrRegisterMessage (@"MouseDown",										@#MouseDown)
	XgrRegisterMessage (@"MouseDrag",										@#MouseDrag)
	XgrRegisterMessage (@"MouseEnter",									@#MouseEnter)
	XgrRegisterMessage (@"MouseExit",										@#MouseExit)
	XgrRegisterMessage (@"MouseMove",										@#MouseMove)
	XgrRegisterMessage (@"MouseUp",											@#MouseUp)
	XgrRegisterMessage (@"MuchLess",										@#MuchLess)
	XgrRegisterMessage (@"MuchMore",										@#MuchMore)
	XgrRegisterMessage (@"OneLess",											@#OneLess)
	XgrRegisterMessage (@"OneMore",											@#OneMore)
	XgrRegisterMessage (@"PokeArray",										@#PokeArray)
	XgrRegisterMessage (@"PokeTextArray",								@#PokeTextArray)
	XgrRegisterMessage (@"PokeTextString",							@#PokeTextString)
	XgrRegisterMessage (@"PokeValueArray",							@#PokeValueArray)
	XgrRegisterMessage (@"Print",												@#Print)
	XgrRegisterMessage (@"Redraw",											@#Redraw)
	XgrRegisterMessage (@"RedrawGrid",									@#RedrawGrid)
	XgrRegisterMessage (@"RedrawLines",									@#RedrawLines)
	XgrRegisterMessage (@"RedrawText",									@#RedrawText)
	XgrRegisterMessage (@"RedrawWindow",								@#RedrawWindow)
	XgrRegisterMessage (@"Replace",											@#Replace)
	XgrRegisterMessage (@"ReplaceForward",							@#ReplaceForward)
	XgrRegisterMessage (@"ReplaceReverse",							@#ReplaceReverse)
	XgrRegisterMessage (@"Reset",												@#Reset)
	XgrRegisterMessage (@"Resize",											@#Resize)
	XgrRegisterMessage (@"Resized",											@#Resized)
	XgrRegisterMessage (@"ResizeNot",										@#ResizeNot)
	XgrRegisterMessage (@"ResizeWindow",								@#ResizeWindow)
	XgrRegisterMessage (@"ResizeWindowToGrid",					@#ResizeWindowToGrid)
	XgrRegisterMessage (@"Resized",											@#Resized)
	XgrRegisterMessage (@"Reverse",											@#Reverse)
	XgrRegisterMessage (@"ScrollH",											@#ScrollH)
	XgrRegisterMessage (@"ScrollV",											@#ScrollV)
	XgrRegisterMessage (@"Select",											@#Select)
	XgrRegisterMessage (@"Selected",										@#Selected)
	XgrRegisterMessage (@"Selection",										@#Selection)
	XgrRegisterMessage (@"SelectWindow",								@#SelectWindow)
	XgrRegisterMessage (@"SetAlign",										@#SetAlign)
	XgrRegisterMessage (@"SetBorder",										@#SetBorder)
	XgrRegisterMessage (@"SetBorderOffset",							@#SetBorderOffset)
	XgrRegisterMessage (@"SetCallback",									@#SetCallback)
	XgrRegisterMessage (@"SetCan",											@#SetCan)
	XgrRegisterMessage (@"SetCharacterMapArray",				@#SetCharacterMapArray)
	XgrRegisterMessage (@"SetClipGrid",									@#SetClipGrid)
	XgrRegisterMessage (@"SetColor",										@#SetColor)
	XgrRegisterMessage (@"SetColorAll",									@#SetColorAll)
	XgrRegisterMessage (@"SetColorExtra",								@#SetColorExtra)
	XgrRegisterMessage (@"SetColorExtraAll",						@#SetColorExtraAll)
	XgrRegisterMessage (@"SetCursor",										@#SetCursor)
	XgrRegisterMessage (@"SetCursorXY",									@#SetCursorXY)
	XgrRegisterMessage (@"SetDisplay",									@#SetDisplay)
	XgrRegisterMessage (@"SetFocusColor",								@#SetFocusColor)
	XgrRegisterMessage (@"SetFocusColorExtra",					@#SetFocusColorExtra)
	XgrRegisterMessage (@"SetFont",											@#SetFont)
	XgrRegisterMessage (@"SetFontNumber",								@#SetFontNumber)
	XgrRegisterMessage (@"SetGridFunction",							@#SetGridFunction)
	XgrRegisterMessage (@"SetGridFunctionName",					@#SetGridFunctionName)
	XgrRegisterMessage (@"SetGridName",									@#SetGridName)
	XgrRegisterMessage (@"SetGridType",									@#SetGridType)
	XgrRegisterMessage (@"SetGridTypeName",							@#SetGridTypeName)
	XgrRegisterMessage (@"SetGroup",										@#SetGroup)
	XgrRegisterMessage (@"SetHelp",											@#SetHelp)
	XgrRegisterMessage (@"SetHelpFile",									@#SetHelpFile)
	XgrRegisterMessage (@"SetHelpString",								@#SetHelpString)
	XgrRegisterMessage (@"SetHelpStrings",							@#SetHelpStrings)
	XgrRegisterMessage (@"SetHintString",								@#SetHintString)
	XgrRegisterMessage (@"SetImage",										@#SetImage)
	XgrRegisterMessage (@"SetImageCoords",							@#SetImageCoords)
	XgrRegisterMessage (@"SetIndent",										@#SetIndent)
	XgrRegisterMessage (@"SetInfo",											@#SetInfo)
	XgrRegisterMessage (@"SetJustify",									@#SetJustify)
	XgrRegisterMessage (@"SetKeyboardFocus",						@#SetKeyboardFocus)
	XgrRegisterMessage (@"SetKeyboardFocusGrid",				@#SetKeyboardFocusGrid)
	XgrRegisterMessage (@"SetMaxMinSize",								@#SetMaxMinSize)
	XgrRegisterMessage (@"SetMessageFunc",							@#SetMessageFunc)
	XgrRegisterMessage (@"SetMessageFuncArray",					@#SetMessageFuncArray)
	XgrRegisterMessage (@"SetMessageSub",								@#SetMessageSub)
	XgrRegisterMessage (@"SetMessageSubArray",					@#SetMessageSubArray)
	XgrRegisterMessage (@"SetModalWindow",							@#SetModalWindow)
	XgrRegisterMessage (@"SetParent",										@#SetParent)
	XgrRegisterMessage (@"SetPosition",									@#SetPosition)
	XgrRegisterMessage (@"SetRedrawFlags",							@#SetRedrawFlags)
	XgrRegisterMessage (@"SetSize",											@#SetSize)
	XgrRegisterMessage (@"SetState",										@#SetState)
	XgrRegisterMessage (@"SetStyle",										@#SetStyle)
	XgrRegisterMessage (@"SetTabArray",									@#SetTabArray)
	XgrRegisterMessage (@"SetTabWidth",									@#SetTabWidth)
	XgrRegisterMessage (@"SetTextArray",								@#SetTextArray)
	XgrRegisterMessage (@"SetTextArrayLine",						@#SetTextArrayLine)
	XgrRegisterMessage (@"SetTextArrayLines",						@#SetTextArrayLines)
	XgrRegisterMessage (@"SetTextCursor",								@#SetTextCursor)
	XgrRegisterMessage (@"SetTextFilename",							@#SetTextFilename)
	XgrRegisterMessage (@"SetTextSelection",						@#SetTextSelection)
	XgrRegisterMessage (@"SetTextString",								@#SetTextString)
	XgrRegisterMessage (@"SetTextStrings",							@#SetTextStrings)
	XgrRegisterMessage (@"SetTexture",									@#SetTexture)
	XgrRegisterMessage (@"SetTimer",										@#SetTimer)
	XgrRegisterMessage (@"SetValue",										@#SetValue)
	XgrRegisterMessage (@"SetValues",										@#SetValues)
	XgrRegisterMessage (@"SetValueArray",								@#SetValueArray)
	XgrRegisterMessage (@"SetWindowFunction",						@#SetWindowFunction)
	XgrRegisterMessage (@"SetWindowIcon",								@#SetWindowIcon)
	XgrRegisterMessage (@"SetWindowTitle",							@#SetWindowTitle)
	XgrRegisterMessage (@"ShowTextCursor",							@#ShowTextCursor)
	XgrRegisterMessage (@"ShowWindow",									@#ShowWindow)
	XgrRegisterMessage (@"SomeLess",										@#SomeLess)
	XgrRegisterMessage (@"SomeMore",										@#SomeMore)
	XgrRegisterMessage (@"StartTimer",									@#StartTimer)
	XgrRegisterMessage (@"SystemMessage",								@#SystemMessage)
	XgrRegisterMessage (@"TextDelete",									@#TextDelete)
	XgrRegisterMessage (@"TextEvent",										@#TextEvent)
	XgrRegisterMessage (@"TextInsert",									@#TextInsert)
	XgrRegisterMessage (@"TextModified",								@#TextModified)
	XgrRegisterMessage (@"TextReplace",									@#TextReplace)
	XgrRegisterMessage (@"TimeOut",											@#TimeOut)
	XgrRegisterMessage (@"Update",											@#Update)
	XgrRegisterMessage (@"WindowClose",									@#WindowClose)
	XgrRegisterMessage (@"WindowCreate",								@#WindowCreate)
	XgrRegisterMessage (@"WindowDeselected",						@#WindowDeselected)
	XgrRegisterMessage (@"WindowDestroy",								@#WindowDestroy)
	XgrRegisterMessage (@"WindowDestroyed",							@#WindowDestroyed)
	XgrRegisterMessage (@"WindowDisplay",								@#WindowDisplay)
	XgrRegisterMessage (@"WindowDisplayed",							@#WindowDisplayed)
	XgrRegisterMessage (@"WindowGetDisplay",						@#WindowGetDisplay)
	XgrRegisterMessage (@"WindowGetFunction",						@#WindowGetFunction)
	XgrRegisterMessage (@"WindowGetIcon",								@#WindowGetIcon)
	XgrRegisterMessage (@"WindowGetKeyboardFocusGrid",	@#WindowGetKeyboardFocusGrid)
	XgrRegisterMessage (@"WindowGetSelectedWindow",			@#WindowGetSelectedWindow)
	XgrRegisterMessage (@"WindowGetSize",								@#WindowGetSize)
	XgrRegisterMessage (@"WindowGetTitle",							@#WindowGetTitle)
	XgrRegisterMessage (@"WindowHelp",									@#WindowHelp)
	XgrRegisterMessage (@"WindowHide",									@#WindowHide)
	XgrRegisterMessage (@"WindowHidden",								@#WindowHidden)
	XgrRegisterMessage (@"WindowKeyDown",								@#WindowKeyDown)
	XgrRegisterMessage (@"WindowKeyUp",									@#WindowKeyUp)
	XgrRegisterMessage (@"WindowMaximize",							@#WindowMaximize)
	XgrRegisterMessage (@"WindowMaximized",							@#WindowMaximized)
	XgrRegisterMessage (@"WindowMinimize",							@#WindowMinimize)
	XgrRegisterMessage (@"WindowMinimized",							@#WindowMinimized)
	XgrRegisterMessage (@"WindowMonitorContext",				@#WindowMonitorContext)
	XgrRegisterMessage (@"WindowMonitorHelp",						@#WindowMonitorHelp)
	XgrRegisterMessage (@"WindowMonitorKeyboard",				@#WindowMonitorKeyboard)
	XgrRegisterMessage (@"WindowMonitorMouse",					@#WindowMonitorMouse)
	XgrRegisterMessage (@"WindowMouseDown",							@#WindowMouseDown)
	XgrRegisterMessage (@"WindowMouseDrag",							@#WindowMouseDrag)
	XgrRegisterMessage (@"WindowMouseEnter",						@#WindowMouseEnter)
	XgrRegisterMessage (@"WindowMouseExit",							@#WindowMouseExit)
	XgrRegisterMessage (@"WindowMouseMove",							@#WindowMouseMove)
	XgrRegisterMessage (@"WindowMouseUp",								@#WindowMouseUp)
	XgrRegisterMessage (@"WindowRedraw",								@#WindowRedraw)
	XgrRegisterMessage (@"WindowRegister",							@#WindowRegister)
	XgrRegisterMessage (@"WindowResize",								@#WindowResize)
	XgrRegisterMessage (@"WindowResized",								@#WindowResized)
	XgrRegisterMessage (@"WindowResizeToGrid",					@#WindowResizeToGrid)
	XgrRegisterMessage (@"WindowSelect",								@#WindowSelect)
	XgrRegisterMessage (@"WindowSelected",							@#WindowSelected)
	XgrRegisterMessage (@"WindowSetFunction",						@#WindowSetFunction)
	XgrRegisterMessage (@"WindowSetIcon",								@#WindowSetIcon)
	XgrRegisterMessage (@"WindowSetKeyboardFocusGrid",	@#WindowSetKeyboardFocusGrid)
	XgrRegisterMessage (@"WindowSetTitle",							@#WindowSetTitle)
	XgrRegisterMessage (@"WindowShow",									@#WindowShow)
	XgrRegisterMessage (@"WindowSystemMessage",					@#WindowSystemMessage)
	XgrRegisterMessage (@"LastMessage",									@#LastMessage)
'
	XgrGetDisplaySize ("", @#displayWidth, @#displayHeight, @#windowBorderWidth, @#windowTitleHeight)
END FUNCTION
'
'
' ############################
' #####  InitProgram ()  #####
' ############################
'
FUNCTION  InitProgram ()
'		Initialize everything your program needs to initialize
END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()
	SHARED  Circle
'
	wt = 0
'	wt = $$WindowTypeNoFrame
	Circle (@Circle, #CreateWindow, 0, 0, 0, 0, wt, 0)
	Circle ( Circle, #SetCallback, Circle, &CircleCode(), -1, -1, -1, -1)
	XuiSendMessage (Circle, #DisplayWindow, 0, 0, 0, 0, 0, 0)
'	XuiSendMessage (Circle, #MaximizeWindow, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' #######################
' #####  Circle ()  #####
' #######################
'
FUNCTION  Circle (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1[], r1$[]))
  STATIC	designX,  designY,  designWidth,  designHeight
  STATIC	SUBADDR  sub[]
	STATIC	upperMessage
  STATIC	Circle
'
  $Circle       =   0  ' kid   0 grid type = Circle
  $DrawingArea  =   1  ' kid   1 grid type = XuiArea
  $ClearButton  =   2  ' kid   2 grid type = XuiPushButton
  $PauseButton  =   3  ' kid   3 grid type = XuiPushButton
  $QuitButton   =   4  ' kid   4 grid type = XuiPushButton
  $UpperKid     =   4  ' kid maximum
'
  IFZ sub[] THEN GOSUB Initialize
' XuiReportMessage (grid, message, v0, v1, v2, v3, r0, r1)
  IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, Circle) THEN RETURN
  IF (message <= upperMessage) THEN GOSUB @sub[message]
  RETURN
'
'
' *****  Callback  *****  message = Callback : r1 = original message
'
SUB Callback
  message = r1
  IF (message <= upperMessage) THEN GOSUB @sub[message]
END SUB
'
'
' *****  Create  *****  v0123 = xywh : r0 = window : r1 = parent
'
SUB Create
  IF (v0 <= 0) THEN v0 = 0
  IF (v1 <= 0) THEN v1 = 0
  IF (v2 <= 0) THEN v2 = designWidth
  IF (v3 <= 0) THEN v3 = designHeight
  XuiCreateGrid (@grid, Circle, @v0, @v1, @v2, @v3, r0, r1, &Circle())
  XuiSendMessage ( grid, #SetGridName, 0, 0, 0, 0, 0, @"Circle")
	XuiSendMessage ( grid, #SetBorder, 0, 0, 0, 0, 0, 0)
  XuiArea        (@g, #Create, 4, 4, 444, 444, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &Circle(), -1, -1, $DrawingArea, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"DrawingArea")
  XuiSendMessage ( g, #SetColor, $$Black, $$White, $$Black, $$White, 0, 0)
  XuiPushButton  (@g, #Create, 4, 448, 148, 20, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &Circle(), -1, -1, $ClearButton, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"ClearButton")
  XuiSendMessage ( g, #SetColor, $$BrightGreen, $$Black, $$Black, $$White, 0, 0)
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" Clear ")
  XuiPushButton  (@g, #Create, 152, 448, 148, 20, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &Circle(), -1, -1, $PauseButton, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"PauseButton")
  XuiSendMessage ( g, #SetColor, 110, $$Black, $$Black, $$White, 0, 0)
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" Pause ")
  XuiPushButton  (@g, #Create, 300, 448, 148, 20, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &Circle(), -1, -1, $QuitButton, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"QuitButton")
  XuiSendMessage ( g, #SetColor, 102, $$Black, $$Black, $$White, 0, 0)
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @" Quit ")
  GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1$ = display$
'
SUB CreateWindow
  IF (v0 =  0) THEN v0 = designX
  IF (v1 =  0) THEN v1 = designY
  IF (v2 <= 0) THEN v2 = designWidth
  IF (v3 <= 0) THEN v3 = designHeight
  XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
  v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
  GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
  XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"Circle")
END SUB
'
'
' *****  GetSmallestSize  *****
'
SUB GetSmallestSize
	v2 = 100
	v3 = 120
	XuiGetBorder (grid, #GetBorder, 0, 0, 0, 0, 0, @bw)
	FOR i = 2 TO 4
		XuiSendMessage (grid, #GetSmallestSize, 0, 0, @ww, @hh, i, 0)
		w = MAX (w, ww) : h = MAX (h, hh)
	NEXT i
	w = w + 4 AND -4
	h = h + 4 AND -4
	innerWidth = w + w + w
	innerHeight = innerWidth + h
	totalWidth = bw + bw + innerWidth
	totalHeight = bw + bw + innerHeight
	v2 = totalWidth
	v3 = totalHeight
END SUB
'
'
' *****  Resize  *****
'
SUB Resize
	v2Entry = v2
	v3Entry = v3
	GOSUB GetSmallestSize
	v2 = MAX (v2, v2Entry)
	v3 = MAX (v3, v3Entry)
'
	XuiPositionGrid (grid, @v0, @v1, @v2, @v3)
'
	innerWidth = v2 - bw - bw
	innerHeight = v3 - bw - bw
	gw = innerWidth
	gh = innerHeight - h
	bw0 = innerWidth / 3
	bw1 = bw0
	bw2 = innerWidth - bw1 - bw0
	bx0 = bw
	bx1 = bx0 + bw0
	bx2 = bx1 + bw1
	by = v3-h-bw
'
	XuiSendMessage (grid, #Resize,  bw, bw,  gw, gh, 1, 0)
	XuiSendMessage (grid, #Resize, bx0, by, bw0,  h, 2, 0)
	XuiSendMessage (grid, #Resize, bx1, by, bw1,  h, 3, 0)
	XuiSendMessage (grid, #Resize, bx2, by, bw2,  h, 4, 0)
	XuiResizeWindowToGrid (grid, #ResizeWindowToGrid, 0, 0, 0, 0, 0, 0)
'
' start new code : create buffer grid first time through this subroutine
'
	XuiGetValues (grid, #GetValues, @g, @i, 0, 0, 0, 0)
'
	IFZ i THEN
		XuiSendMessage (grid, #GetGridNumber, @g, 0, 0, 0, $DrawingArea, 0)
		XgrCreateGrid  (@i, 1, 0, 0, v2, v3, r0, g, 0)
		XgrSetGridBuffer (g, i, 0, 0)
		XgrClearGrid (g, 0)
		XuiSetValues (grid, #SetValues, g, i, 0, 0, 0, 0)
	END IF
'
	XgrSetGridPositionAndSize (i, 0, 0, gw, gh)
'
' end new code : buffer grid resized same as $DrawingArea kid grid
'
	XuiGetSize (grid, #GetSize, 0, 0, @width, @height, 0, 0)
	XuiCallback (grid, #Resized, 0, 0, width, height, 0, 0)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
  XuiGetDefaultMessageFuncArray (@func[])
  XgrMessageNameToNumber (@"LastMessage", @upperMessage)
'
  func[#Callback]           = &XuiCallback()
  func[#Resize]             = &XuiResizeNot()
  func[#Selection]          = &XuiCallback()
	func[#GetSmallestSize]    = 0
	func[#Resize]             = 0
'
  DIM sub[upperMessage]
  sub[#Create]              = SUBADDRESS (Create)
  sub[#CreateWindow]        = SUBADDRESS (CreateWindow)
  sub[#GetSmallestSize]     = SUBADDRESS (GetSmallestSize)
  sub[#Resize]              = SUBADDRESS (Resize)
'
	IF func[0] THEN PRINT "Circle(): Initialize: Error::: (Undefined Message)"
	IF sub[0] THEN PRINT "Circle(): Initialize: Error::: (Undefined Message)"
  XuiRegisterGridType (@Circle, "Circle", &Circle(), @func[], @sub[])
'
  designX = 568
  designY = 23
  designWidth = 452
  designHeight = 472
'
	gridType = Circle
	XuiSetGridTypeValue (gridType, @"x",           designX)
	XuiSetGridTypeValue (gridType, @"y",           designY)
	XuiSetGridTypeValue (gridType, @"width",       designWidth)
	XuiSetGridTypeValue (gridType, @"height",      designHeight)
	XuiSetGridTypeValue (gridType, @"border",      $$BorderFrame)
	XuiSetGridTypeValue (gridType, @"can",         $$Focus OR $$Respond OR $$Callback)
  IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ###########################
' #####  CircleCode ()  #####
' ###########################
'
FUNCTION  CircleCode (grid, message, v0, v1, v2, v3, r0, r1)
	SHARED	Circle,  CircleGrid
	SHARED	paused,  circleWidth,  circleHeight
	STATIC	entry,  color,  dx,  dy,  half,  rad,  jjj
	STATIC	s1#,  s2#,  a1#,  a2#
'
  $Circle       =   0  ' kid   0 grid type = Circle
  $DrawingArea  =   1  ' kid   1 grid type = XuiArea
  $ClearButton  =   2  ' kid   2 grid type = XuiPushButton
  $PauseButton  =   3  ' kid   3 grid type = XuiPushButton
  $QuitButton   =   4  ' kid   4 grid type = XuiPushButton
  $UpperKid     =   4  ' kid maximum
'
	IFZ entry THEN entry = $$TRUE : GOSUB Resized
' XuiReportMessage (grid, message, v0, v1, v2, v3, r0, r1)
	IF (message = #Callback) THEN message = r1
'
	SELECT CASE message
'		CASE #Help:				GOSUB Help
		CASE #Redraw:			GOSUB Redraw
		CASE #Resized:		GOSUB Resized
		CASE #Selection:	GOSUB Selection
	END SELECT
	RETURN
'
'
' ***********************
' *****  Selection  *****  Callbacks from Circle() pushbuttons
' ***********************
'
SUB Selection
	SELECT CASE r0
		CASE $ClearButton	: XgrClearGrid (CircleGrid, -1)
		CASE $PauseButton	: paused = NOT paused
		CASE $QuitButton	: QUIT (0)
	END SELECT
END SUB
'
'
' *********************
' *****  Resized  *****  Callbacks from Circle() resize routine
' *********************
'
SUB Resized
	entry = $$TRUE
	XuiSendMessage (Circle, #GetKidArray, 0, 0, 0, 0, 0, @kid[])
	XuiSendMessage (Circle, #GetSize, 0, 0, @circleWidth, @circleHeight, 1, 0)
	CircleGrid = kid[1]
	s1#		= $$PI / 256#
	s2#		= 4.9# * s1#
	a1#		= 0#
	a2#		= $$PI / 4#
	dx		= circleWidth >> 1
	dy		= circleHeight >> 1
	rad		= MIN (circleWidth, circleHeight) >> 1
	rad		= rad - 6
	color = 0
	XgrClearGrid (CircleGrid, -1)
END SUB
'
'
' ********************
' *****  Redraw  *****  Messages from Entry ()
' ********************
'
SUB Redraw
	INC jjj
	IF (jjj > 100) THEN jjj = 0
	IF (jjj < 50) THEN XgrClearGrid (CircleGrid, -1)		' comment out or in for variety
	FOR i = 0 TO 99
		GOSUB Circle
	NEXT i
	INC color
END SUB
'
'
' ********************
' *****  Circle  *****  Drawing subroutine
' ********************
'
SUB Circle
	IF (a1# >= $$TWOPI) THEN
		a1# = a1# - $$TWOPI
		color = (color + 3)
		IF (color > 124) THEN color = color - 124
	END IF
	IF (a2# >= $$TWOPI) THEN
		a2# = a2# - $$TWOPI
		INC i
	END IF
	IFZ color THEN INC color
	p1x	= SIN (a1#) * rad + dx
	p1y	= COS (a1#) * rad + dy
	p2x	= SIN (a2#) * rad + dx
	p2y	= COS (a2#) * rad + dy
	XgrDrawLine (CircleGrid, color, p1x, p1y, p2x, p2y)
	a1#	= a1# + s1#
	a2#	= a2# + s2#
	s2# = 1.0002# * s2#
	IF (s2# > $$TWOPI) THEN s2# = s2# - $$TWOPI
END SUB
END FUNCTION
END PROGRAM
