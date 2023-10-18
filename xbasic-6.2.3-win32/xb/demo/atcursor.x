'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program shows how to set the location of the text cursor
' in an XuiTextArea grid.  Click on a line in one of the other
' four grids and the text cursor will be placed on that line * 2
' in the XuiTextArea grid.
'
PROGRAM "atcursor"
VERSION "0.0003"
'
IMPORT "xst"
IMPORT "xgr"
IMPORT "xui"
'
INTERNAL FUNCTION  Entry         ()
INTERNAL FUNCTION  InitGui       ()
INTERNAL FUNCTION  InitProgram   ()
INTERNAL FUNCTION  CreateWindows ()
INTERNAL FUNCTION  TextSet       (grid, message, v0, v1, v2, v3, r0, ANY)
INTERNAL FUNCTION  TextSetCode   (grid, message, v0, v1, v2, v3, kid, ANY)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()
	SHARED  terminateProgram
	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured
'
	InitGui ()										' initialize messages
	InitProgram ()								' initialize this program
	CreateWindows ()							' create main window and others
	IF LIBRARY(0) THEN RETURN			' main program has message loop
'
	DO														' the message loop
		XgrProcessMessages (1)			' process one message
	LOOP UNTIL terminateProgram		' and repeat until program is terminated
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
' Add code to InitProgram() to initialize whatever needs initialization.
' Do not delete this function - leave it empty if not needed.
'
FUNCTION  InitProgram ()

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
' GuiDesigner puts code in CreateWindows() to create, initialize, display
' every window you design graphically.  Don't modify this function unless
' absolutely necessary - GuiDesigner needs to read and update it at times.
'
' CreateWindows() usually should not be executed when compiled as library.
' Start CreateWindows() with "IF LIBRARY(0) THEN RETURN" to assure this.
'
FUNCTION  CreateWindows ()
'
  IF LIBRARY(0) THEN RETURN
'
  TextSet (@TextSet, #CreateWindow, 0, 0, 0, 0, 0, 0)
  XuiSendMessage (TextSet, #SetCallback, TextSet, &TextSetCode(), -1, -1, -1, 0)
  XuiSendMessage (TextSet, #DisplayWindow, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' ########################
' #####  TextSet ()  #####
' ########################
'
FUNCTION  TextSet (grid, message, v0, v1, v2, v3, r0, (r1, r1$, r1[], r1$[]))
  STATIC  designX,  designY,  designWidth,  designHeight
  STATIC  SUBADDR  sub[]
  STATIC  upperMessage
  STATIC  TextSet
'
  $TextSet     =   0  ' kid   0 grid type = TextSet
  $TextArea    =   1  ' kid   1 grid type = XuiTextArea
  $DropButton  =   2  ' kid   3 grid type = XuiDropButton
  $DropBox     =   3  ' kid   4 grid type = XuiDropBox
  $ListButton  =   4  ' kid   5 grid type = XuiListButton
  $ListBox     =   5  ' kid   2 grid type = XuiListBox
  $UpperKid    =   5  ' kid maximum
'
'
  IFZ sub[] THEN GOSUB Initialize
' XuiReportMessage (grid, message, v0, v1, v2, v3, r0, r1)
  IF XuiProcessMessage (grid, message, @v0, @v1, @v2, @v3, @r0, @r1, TextSet) THEN RETURN
  IF (message <= upperMessage) THEN GOSUB @sub[message]
  RETURN
'
'
' *****  Callback  *****  message = Callback : r1 = original message
'
SUB Callback
  message = r1
  callback = message
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
  XuiCreateGrid (@grid, TextSet, @v0, @v1, @v2, @v3, r0, r1, &TextSet())
  XuiSendMessage ( grid, #SetGridName, 0, 0, 0, 0, 0, @"TextSet")
  XuiTextArea    (@g, #Create, 4, 4, 156, 124, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &TextSet(), -1, -1, $TextArea, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"TextArea")
  DIM text$[31]
  text$[ 0] = "'"
  text$[ 1] = "' ####################"
  text$[ 2] = "' #####  PROLOG  #####"
  text$[ 3] = "' ####################"
  text$[ 4] = "'"
  text$[ 5] = "PROGRAM \"textset\""
  text$[ 6] = "VERSION \"0.0000\""
  text$[ 7] = "'"
  text$[ 8] = "IMPORT \"xst\""
  text$[ 9] = "IMPORT \"xgr\""
  text$[10] = "IMPORT \"xui\""
  text$[11] = "'"
  text$[12] = "INTERNAL FUNCTION  Entry         ()"
  text$[13] = "INTERNAL FUNCTION  InitGui       ()"
  text$[14] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[15] = "INTERNAL FUNCTION  CreateWindows ()"
  text$[16] = "'"
  text$[17] = "' ####################"
  text$[18] = "' #####  PROLOG  #####"
  text$[19] = "' ####################"
  text$[20] = "'"
  text$[21] = "PROGRAM \"textset\""
  text$[22] = "VERSION \"0.0000\""
  text$[23] = "'"
  text$[24] = "IMPORT \"xst\""
  text$[25] = "IMPORT \"xgr\""
  text$[26] = "IMPORT \"xui\""
  text$[27] = "'"
  text$[28] = "INTERNAL FUNCTION  Entry         ()"
  text$[29] = "INTERNAL FUNCTION  InitGui       ()"
  text$[30] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[31] = "INTERNAL FUNCTION  CreateWindows ()"
  XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"XuiScrollBarH826")
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 2, @"XuiScrollBarV827")
  XuiDropButton  (@g, #Create, 168, 8, 160, 24, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &TextSet(), -1, -1, $DropButton, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"DropButton")
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"DropButton")
  DIM text$[31]
  text$[ 0] = "'"
  text$[ 1] = "' ####################"
  text$[ 2] = "' #####  PROLOG  #####"
  text$[ 3] = "' ####################"
  text$[ 4] = "'"
  text$[ 5] = "PROGRAM \"textset\""
  text$[ 6] = "VERSION \"0.0000\""
  text$[ 7] = "'"
  text$[ 8] = "IMPORT \"xst\""
  text$[ 9] = "IMPORT \"xgr\""
  text$[10] = "IMPORT \"xui\""
  text$[11] = "'"
  text$[12] = "INTERNAL FUNCTION  Entry         ()"
  text$[13] = "INTERNAL FUNCTION  InitGui       ()"
  text$[14] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[15] = "INTERNAL FUNCTION  CreateWindows ()"
  text$[16] = "'"
  text$[17] = "' ####################"
  text$[18] = "' #####  PROLOG  #####"
  text$[19] = "' ####################"
  text$[20] = "'"
  text$[21] = "PROGRAM \"textset\""
  text$[22] = "VERSION \"0.0000\""
  text$[23] = "'"
  text$[24] = "IMPORT \"xst\""
  text$[25] = "IMPORT \"xgr\""
  text$[26] = "IMPORT \"xui\""
  text$[27] = "'"
  text$[28] = "INTERNAL FUNCTION  Entry         ()"
  text$[29] = "INTERNAL FUNCTION  InitGui       ()"
  text$[30] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[31] = "INTERNAL FUNCTION  CreateWindows ()"
  XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
  XuiDropBox     (@g, #Create, 168, 40, 160, 24, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &TextSet(), -1, -1, $DropBox, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"DropBox")
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"'")
  DIM text$[31]
  text$[ 0] = "'"
  text$[ 1] = "' ####################"
  text$[ 2] = "' #####  PROLOG  #####"
  text$[ 3] = "' ####################"
  text$[ 4] = "'"
  text$[ 5] = "PROGRAM \"textset\""
  text$[ 6] = "VERSION \"0.0000\""
  text$[ 7] = "'"
  text$[ 8] = "IMPORT \"xst\""
  text$[ 9] = "IMPORT \"xgr\""
  text$[10] = "IMPORT \"xui\""
  text$[11] = "'"
  text$[12] = "INTERNAL FUNCTION  Entry         ()"
  text$[13] = "INTERNAL FUNCTION  InitGui       ()"
  text$[14] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[15] = "INTERNAL FUNCTION  CreateWindows ()"
  text$[16] = "'"
  text$[17] = "' ####################"
  text$[18] = "' #####  PROLOG  #####"
  text$[19] = "' ####################"
  text$[20] = "'"
  text$[21] = "PROGRAM \"textset\""
  text$[22] = "VERSION \"0.0000\""
  text$[23] = "'"
  text$[24] = "IMPORT \"xst\""
  text$[25] = "IMPORT \"xgr\""
  text$[26] = "IMPORT \"xui\""
  text$[27] = "'"
  text$[28] = "INTERNAL FUNCTION  Entry         ()"
  text$[29] = "INTERNAL FUNCTION  InitGui       ()"
  text$[30] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[31] = "INTERNAL FUNCTION  CreateWindows ()"
  XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"XuiTextLine840")
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 1, @"'")
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 2, @"XuiArea842")
  XuiListButton  (@g, #Create, 168, 72, 160, 24, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &TextSet(), -1, -1, $ListButton, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"ListButton")
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"ListButton")
  DIM text$[31]
  text$[ 0] = "'"
  text$[ 1] = "' ####################"
  text$[ 2] = "' #####  PROLOG  #####"
  text$[ 3] = "' ####################"
  text$[ 4] = "'"
  text$[ 5] = "PROGRAM \"textset\""
  text$[ 6] = "VERSION \"0.0000\""
  text$[ 7] = "'"
  text$[ 8] = "IMPORT \"xst\""
  text$[ 9] = "IMPORT \"xgr\""
  text$[10] = "IMPORT \"xui\""
  text$[11] = "'"
  text$[12] = "INTERNAL FUNCTION  Entry         ()"
  text$[13] = "INTERNAL FUNCTION  InitGui       ()"
  text$[14] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[15] = "INTERNAL FUNCTION  CreateWindows ()"
  text$[16] = "'"
  text$[17] = "' ####################"
  text$[18] = "' #####  PROLOG  #####"
  text$[19] = "' ####################"
  text$[20] = "'"
  text$[21] = "PROGRAM \"textset\""
  text$[22] = "VERSION \"0.0000\""
  text$[23] = "'"
  text$[24] = "IMPORT \"xst\""
  text$[25] = "IMPORT \"xgr\""
  text$[26] = "IMPORT \"xui\""
  text$[27] = "'"
  text$[28] = "INTERNAL FUNCTION  Entry         ()"
  text$[29] = "INTERNAL FUNCTION  InitGui       ()"
  text$[30] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[31] = "INTERNAL FUNCTION  CreateWindows ()"
  XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
  XuiListBox     (@g, #Create, 168, 104, 160, 24, r0, grid)
  XuiSendMessage ( g, #SetCallback, grid, &TextSet(), -1, -1, $ListBox, grid)
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 0, @"ListBox")
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 0, @"PROGRAM \"textset\"")
  DIM text$[31]
  text$[ 0] = "'"
  text$[ 1] = "' ####################"
  text$[ 2] = "' #####  PROLOG  #####"
  text$[ 3] = "' ####################"
  text$[ 4] = "'"
  text$[ 5] = "PROGRAM \"textset\""
  text$[ 6] = "VERSION \"0.0000\""
  text$[ 7] = "'"
  text$[ 8] = "IMPORT \"xst\""
  text$[ 9] = "IMPORT \"xgr\""
  text$[10] = "IMPORT \"xui\""
  text$[11] = "'"
  text$[12] = "INTERNAL FUNCTION  Entry         ()"
  text$[13] = "INTERNAL FUNCTION  InitGui       ()"
  text$[14] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[15] = "INTERNAL FUNCTION  CreateWindows ()"
  text$[16] = "'"
  text$[17] = "' ####################"
  text$[18] = "' #####  PROLOG  #####"
  text$[19] = "' ####################"
  text$[20] = "'"
  text$[21] = "PROGRAM \"textset\""
  text$[22] = "VERSION \"0.0000\""
  text$[23] = "'"
  text$[24] = "IMPORT \"xst\""
  text$[25] = "IMPORT \"xgr\""
  text$[26] = "IMPORT \"xui\""
  text$[27] = "'"
  text$[28] = "INTERNAL FUNCTION  Entry         ()"
  text$[29] = "INTERNAL FUNCTION  InitGui       ()"
  text$[30] = "INTERNAL FUNCTION  InitProgram   ()"
  text$[31] = "INTERNAL FUNCTION  CreateWindows ()"
  XuiSendMessage ( g, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 1, @"XuiTextLine829")
  XuiSendMessage ( g, #SetTextString, 0, 0, 0, 0, 1, @"PROGRAM \"textset\"")
  XuiSendMessage ( g, #SetGridName, 0, 0, 0, 0, 2, @"XuiPressButton831")
  GOSUB Resize
END SUB
'
'
' *****  CreateWindow  *****  v0123 = xywh : r0 = windowType : r1 = &WindowFunc()
'
SUB CreateWindow
  IF (v0  = 0) THEN v0 = designX
  IF (v1  = 0) THEN v1 = designY
  IF (v2 <= 0) THEN v2 = designWidth
  IF (v3 <= 0) THEN v3 = designHeight
  XuiWindow (@window, #WindowCreate, v0, v1, v2, v3, r0, @r1$)
  v0 = 0 : v1 = 0 : r0 = window : ATTACH r1$ TO display$
  GOSUB Create
	r1 = 0 : ATTACH display$ TO r1$
  XuiWindow (window, #WindowRegister, grid, -1, v2, v3, @r0, @"TextSet")
END SUB
'
'
' *****  GetSmallestSize  *****  See "Anatomy of Grid Functions"
'
SUB GetSmallestSize
END SUB
'
'
' *****  Resize  *****  See "Anatomy of Grid Functions"
'
SUB Resize
END SUB
'
'
' *****  Selection  *****  See "Anatomy of Grid Functions"
'
SUB Selection
END SUB
'
'
' *****  Initialize  *****  ' see "Anatomy of Grid Functions"
'
SUB Initialize
  XuiGetDefaultMessageFuncArray (@func[])
  XgrMessageNameToNumber (@"LastMessage", @upperMessage)
'
  func[#Callback]           = &XuiCallback ()               ' disable to handle Callback messages internally
' func[#GetSmallestSize]    = 0                             ' enable to add internal GetSmallestSize routine
' func[#Resize]             = 0                             ' enable to add internal Resize routine
'
  DIM sub[upperMessage]
' sub[#Callback]            = SUBADDRESS (Callback)         ' enable to handle Callback messages internally
  sub[#Create]              = SUBADDRESS (Create)           ' must be internal routine
  sub[#CreateWindow]        = SUBADDRESS (CreateWindow)     ' must be internal routine
' sub[#GetSmallestSize]     = SUBADDRESS (GetSmallestSize)  ' enable to add internal GetSmallestSize routine
' sub[#Resize]              = SUBADDRESS (Resize)           ' enable to add internal Resize routine
  sub[#Selection]           = SUBADDRESS (Selection)        ' routes Selection callbacks to subroutine
'
  IF sub[0] THEN PRINT "TextSet(): Initialize: Error::: (Undefined Message)"
  IF func[0] THEN PRINT "TextSet(): Initialize: Error::: (Undefined Message)"
  XuiRegisterGridType (@TextSet, "TextSet", &TextSet(), @func[], @sub[])
'
' Don't remove the following 4 lines, or WindowFromFunction/WindowToFunction will not work
'
  designX = 689
  designY = 23
  designWidth = 332
  designHeight = 132
'
  gridType = TextSet
  XuiSetGridTypeValue (gridType, @"x",                designX)
  XuiSetGridTypeValue (gridType, @"y",                designY)
  XuiSetGridTypeValue (gridType, @"width",            designWidth)
  XuiSetGridTypeValue (gridType, @"height",           designHeight)
  XuiSetGridTypeValue (gridType, @"maxWidth",         designWidth)
  XuiSetGridTypeValue (gridType, @"maxHeight",        designHeight)
  XuiSetGridTypeValue (gridType, @"minWidth",         designWidth)
  XuiSetGridTypeValue (gridType, @"minHeight",        designHeight)
  XuiSetGridTypeValue (gridType, @"border",           $$BorderFrame)
  XuiSetGridTypeValue (gridType, @"can",              $$Focus OR $$Respond OR $$Callback OR $$InputTextString OR $$TextSelection)
  XuiSetGridTypeValue (gridType, @"focusKid",         $TextArea)
  XuiSetGridTypeValue (gridType, @"inputTextArray",   $TextArea)
  XuiSetGridTypeValue (gridType, @"inputTextString",  $ListBox)
  IFZ message THEN RETURN
END SUB
END FUNCTION
'
'
' ############################
' #####  TextSetCode ()  #####
' ############################
'
FUNCTION  TextSetCode (grid, message, v0, v1, v2, v3, kid, r1)
'
  $TextSet     =   0  ' kid   0 grid type = TextSet
  $TextArea    =   1  ' kid   1 grid type = XuiTextArea
  $DropButton  =   2  ' kid   3 grid type = XuiDropButton
  $DropBox     =   3  ' kid   4 grid type = XuiDropBox
  $ListButton  =   4  ' kid   5 grid type = XuiListButton
  $ListBox     =   5  ' kid   2 grid type = XuiListBox
  $UpperKid    =   5  ' kid maximum
'
  XuiReportMessage (grid, message, v0, v1, v2, v3, kid, r1)
  IF (message = #Callback) THEN message = r1
'
  SELECT CASE message
    CASE #Selection: GOSUB Selection   ' Common callback message
'   CASE #TextEvent: GOSUB TextEvent   ' KeyDown in TextArea or TextLine
  END SELECT
  RETURN
'
'
' *****  Selection  *****
'
SUB Selection
  SELECT CASE kid
    CASE $TextSet     : EXIT SUB
    CASE $TextArea    : EXIT SUB
    CASE $DropButton  :
    CASE $DropBox     :
    CASE $ListButton  :
    CASE $ListBox     :
  END SELECT
'
	XuiSendMessage (grid, #SetTextCursor, 0, 2*v0, 0, 0, $TextArea, 0)
	XuiSendMessage (grid, #SetTextCursor, 0, 2*v0, 0, 0, $DropButton, 0)
	XuiSendMessage (grid, #SetTextCursor, 0, 2*v0, 0, 0, $DropBox, 0)
	XuiSendMessage (grid, #SetTextCursor, 0, 2*v0, 0, 0, $ListButton, 0)
	XuiSendMessage (grid, #SetTextCursor, 0, 2*v0, 0, 0, $ListBox, 0)
	XuiSendMessage (grid, #SetKeyboardFocus, 0, 0, 0, 0, $TextArea, 0)
END SUB
END FUNCTION
END PROGRAM
