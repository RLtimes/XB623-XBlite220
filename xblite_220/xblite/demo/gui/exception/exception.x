'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demonstrates the use of some exception
' handling functions in XBLite:
'
'  XstExceptionNumberToName ()
'  XstRaiseException ()
'  XstRegisterException ()
'  XstSetExceptionFunction ()
'  XstTry ()
'
' Most of the exception-related code
' is in FUNCTION InvokeException ().
'
' Demo by Ken Minogue
'
PROGRAM "exception"
VERSION "1.0001"

IMPORT  "xst"
IMPORT  "gdi32"
IMPORT  "user32"
IMPORT  "kernel32"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  MainWindow (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  ResponseButtons (x0, y0, w0, h0)
DECLARE FUNCTION  CodeButtons (x0, y0, w0, h0)
DECLARE FUNCTION  EnableTypes (enable)
DECLARE FUNCTION  ShowMessage (msg$)
DECLARE FUNCTION  InvokeException ()
DECLARE FUNCTION  ExceptionFunction ()

'internal messages
$$CreateWindow  = 0x401

'control IDs, etc
$$ResponseGroup = 100
$$Forward       = 101
$$Terminate     = 102
$$Continue      = 103
$$Retry         = 104

$$CodeGroup     = 200
$$CodeBreak     = 201
$$CodeDivZero   = 202
$$CodeUser      = 203

$$TypeGroup     = 300
$$TypeWarning   = 301
$$TypeError     = 302

$$Raise         = 400
$$Clear         = 450
$$Edit          = 500


' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

  #hInst = GetModuleHandleA (0)
  IFZ #hInst THEN QUIT (0)

  IF CreateWindows () THEN QUIT(0)
  MessageLoop ()
  CleanUp ()
END FUNCTION

' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

'create main window
  MainWindow (@#winMain, $$CreateWindow, 0, 0)
  IFZ #winMain THEN RETURN ($$TRUE)

'show main window
  ShowWindow (#winMain, $$SW_SHOWNORMAL)

END FUNCTION

' #################################
' #####  RegisterWinClass ()  #####
' #################################
'
FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
  WNDCLASS wc

  wc.style           = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
  wc.lpfnWndProc     = addrWndProc
  wc.cbClsExtra      = 0
  wc.cbWndExtra      = 0
  wc.hInstance       = #hInst
  wc.hIcon           = LoadIconA (#hInst, &icon$)
  wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
  wc.hbrBackground   = $$COLOR_BTNFACE + 1
  wc.lpszMenuName    = &menu$
  wc.lpszClassName   = &className$

  RETURN RegisterClassA (&wc)
END FUNCTION

' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()
  MSG msg

  IF LIBRARY(0) THEN RETURN

  DO
    ret = GetMessageA (&msg, NULL, 0, 0)
    SELECT CASE ret
      CASE  0 : RETURN msg.wParam         ' WM_QUIT message
      CASE -1 : RETURN $$TRUE             ' error
      CASE ELSE:
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
          TranslateMessage (&msg)
          DispatchMessageA (&msg)
        END IF
    END SELECT
  LOOP
END FUNCTION

' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()
  SHARED className$
  DeleteObject (#hFont)
  UnregisterClassA (&className$, #hInst)
END FUNCTION

' ###########################
' #####  MainWindow ()  #####
' ###########################
'
' Window procedure for main window
'
FUNCTION  MainWindow (hWnd, msg, wParam, lParam)
  LOGFONT lf
  SHARED className$

  SELECT CASE msg

    CASE $$CreateWindow
      GOSUB CreateWindow
      hWnd = #winMain

    CASE $$WM_DESTROY
      PostQuitMessage (0)

    CASE $$WM_COMMAND
      controlID = LOWORD(wParam)
      notifyCode = HIWORD(wParam)
      hwndCtl = lParam
      SELECT CASE notifyCode
        CASE $$BN_CLICKED : GOSUB ButtonClick
      END SELECT

    CASE ELSE
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

  END SELECT
  RETURN

SUB CreateWindow
'create main window
  className$  = "exhclass"
  icon$ = "scrabble"
  menu$ = ""
  IFZ RegisterWinClass (@className$, &MainWindow(), @icon$, @menu$) THEN EXIT SUB

  titleBar$ = "Exception Handling Demo"
  style = $$WS_OVERLAPPED | $$WS_SYSMENU
  x = 200
  y = 100
  w = 400
  h = 400
  #winMain = CreateWindowExA (0, &className$, &titleBar$, style, x, y, w, h, 0, 0, #hInst, 0)

'create radio buttons for user choices
  CodeButtons (10, 10, 150, 160)
  ResponseButtons (180, 10, 200, 160)

'Raise Exception button (causes the chosen exception to occur)
  t$ = "raise exception"
  style = $$WS_CHILD | $$WS_VISIBLE
  x = 30: y = 185: w = 150: h = 25
  #hRaise = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$Raise, #hInst, 0)

'Clear Output button
  t$ = "clear output"
  style = $$WS_CHILD | $$WS_VISIBLE
  x = 210: y = 185: w = 150: h = 25
  #hClear = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$Clear, #hInst, 0)

'listbox control for messages
  style = $$WS_CHILD | $$WS_VISIBLE | $$WS_VSCROLL
  x = 10: y = 220: w = 370: h = 160
  #hMsg = CreateWindowExA ($$WS_EX_STATICEDGE, &"LISTBOX", 0, style, x, y, w, h, #winMain, $$Edit, #hInst, 0)
'set font for listbox
  hdc = GetDC (#winMain)
  lf.height =  -1 * 8 * GetDeviceCaps(hdc, $$LOGPIXELSY) / 72.0
  lf.faceName = "Verdana"
  #hFont = CreateFontIndirectA (&lf)
  ReleaseDC (#winMain, hdc)
  SendMessageA (#hMsg, $$WM_SETFONT, #hFont, 0)
END SUB

SUB ButtonClick
  SELECT CASE controlID
  'exception response buttons
    CASE $$Forward
      #exResponse = $$ExceptionForward
    CASE $$Terminate
      #exResponse = $$ExceptionTerminate
    CASE $$Continue
      #exResponse = $$ExceptionContinue
    CASE $$Retry
      #exResponse = $$ExceptionRetry
  'exception code buttons
    CASE $$CodeBreak
      #exCode = $$ExceptionBreakpoint
      SendMessageA (#hWarn, $$BM_SETCHECK, 1, 0)
      SendMessageA (#hError, $$BM_SETCHECK, 0, 0)
      #exType = $$ExceptionTypeWarning
      EnableTypes ($$FALSE)
    CASE $$CodeDivZero
      #exCode = $$ExceptionIntDivideByZero
      SendMessageA (#hWarn, $$BM_SETCHECK, 0, 0)
      SendMessageA (#hError, $$BM_SETCHECK, 1, 0)
      #exType = $$ExceptionTypeError
      EnableTypes ($$FALSE)
    CASE $$CodeUser
      XstRegisterException (@"UserException", @#exCode)
      EnableTypes ($$TRUE)
  'exception type buttons
    CASE $$TypeWarning
      #exType = $$ExceptionTypeWarning
    CASE $$TypeError
       #exType = $$ExceptionTypeError
  'raise selected exception
    CASE $$Raise
      InvokeException ()
  'clear output window
    CASE $$Clear
      SendMessageA (#hMsg, $$LB_RESETCONTENT, 0, 0)
  END SELECT
END SUB
END FUNCTION

' Create radio buttons for choosing exception response
FUNCTION  ResponseButtons (x0, y0, w0, h0)

  style = $$BS_GROUPBOX | $$WS_CHILD | $$WS_VISIBLE
  #responseGroup = CreateWindowExA (0, &"BUTTON", &"Response", style, x0, y0, w0, h0, #winMain, $$ResponseGroup, #hInst, 0)

  dy = 25
  x = x0 + 10
  y = y0 + dy
  w = w0 - 20
  h = 25

  t$ = "$$ExceptionForward"
  style = $$BS_AUTORADIOBUTTON | $$WS_CHILD | $$WS_VISIBLE | $$WS_GROUP
  #hForward = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$Forward, #hInst, 0)

  y = y + dy
  t$ = "$$ExceptionTerminate"
  style = $$BS_AUTORADIOBUTTON | $$WS_CHILD | $$WS_VISIBLE
  #hTerminate = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$Terminate, #hInst, 0)

  y = y + dy
  t$ = "$$ExceptionContinue"
  #hContinue = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$Continue, #hInst, 0)

  y = y + dy
  t$ = "$$ExceptionRetry"
  #hRetry = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$Retry, #hInst, 0)

  SendMessageA (#hForward, $$BM_SETCHECK, 1, 0)
  #exResponse = $$ExceptionForward

END FUNCTION

'create radio buttons for choosing exception code to be raised
'
FUNCTION  CodeButtons (x0, y0, w0, h0)

  style = $$BS_GROUPBOX | $$WS_CHILD | $$WS_VISIBLE
  #codeGroup = CreateWindowExA (0, &"BUTTON", &"Exception", style, x0, y0, w0, h0, #winMain, $$CodeGroup, #hInst, 0)

  dy = 25
  x = x0 + 10
  y = y0 + dy
  w = w0 - 20
  h = 25

  t$ = "Breakpoint"
  style = $$BS_AUTORADIOBUTTON | $$WS_CHILD | $$WS_VISIBLE | $$WS_GROUP
  #hBreak = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$CodeBreak, #hInst, 0)

  y = y + dy
  t$ = "Divide-by-zero"
  style = $$BS_AUTORADIOBUTTON | $$WS_CHILD | $$WS_VISIBLE
  #hDivZero = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$CodeDivZero, #hInst, 0)

  y = y + dy
  t$ = "User-registered"
  #hUser = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$CodeUser, #hInst, 0)

  SendMessageA (#hBreak, $$BM_SETCHECK, 1, 0)
  #exCode = $$ExceptionBreakpoint

'exception type radio buttons
' There is also an $$ExceptionTypeInformation, but this
' behaves the same way as $$ExceptionTypeWarning
  x = x + 20
  y = y + dy
  w = w - 20
  t$ = "Warning"
  style = $$BS_AUTORADIOBUTTON | $$WS_CHILD | $$WS_VISIBLE | $$WS_GROUP
  #hWarn = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$TypeWarning, #hInst, 0)

  y = y + dy
  t$ = "Error"
  style = $$BS_AUTORADIOBUTTON | $$WS_CHILD | $$WS_VISIBLE
  #hError = CreateWindowExA (0, &"BUTTON", &t$, style, x, y, w, h, #winMain, $$TypeError, #hInst, 0)

  SendMessageA (#hWarn, $$BM_SETCHECK, 1, 0)
  #exType = $$ExceptionTypeWarning
  EnableTypes ($$FALSE)

END FUNCTION

'enable/disable exception type radio buttons
'exception type can be set only for user-registered exceptions
FUNCTION  EnableTypes (enable)
  EnableWindow (#hWarn, enable)
  EnableWindow (#hError, enable)
END FUNCTION

'display message in the listbox
FUNCTION  ShowMessage (msg$)
  STATIC text$

  IFZ #hMsg THEN RETURN

	IFZ msg$ THEN msg$ = " "
  SendMessageA (#hMsg, $$LB_ADDSTRING, 0, &msg$)
  count = SendMessageA (#hMsg, $$LB_GETCOUNT, 0, 0)
  SendMessageA (#hMsg, $$LB_SETTOPINDEX, count-1, 0)

END FUNCTION


' ################################
' #####  InvokeException ()  #####
' ################################
'
'
FUNCTION  InvokeException ()
  STATIC trial

'the EXCEPTION_DATA variable provides information about the exception
  EXCEPTION_DATA exception

  INC trial
  ShowMessage ("") 'newline
  ShowMessage ("Trial "+STRING$(trial))

'setting an exception function is optional, and can be done anywhere in a program
  XstSetExceptionFunction (&ExceptionFunction())

  XstExceptionNumberToName (@#exCode, @name$)
  ShowMessage (@"Call XstTry() to install exception handler.")

'XstTry() causes the code in SUB Try to be executed.
  XstTry (SUBADDRESS(Try), SUBADDRESS(Except), @exception)

  ShowMessage (@"Return from XstTry().")
  IF aborted THEN ShowMessage (@"Execution of protected code was aborted.")

  RETURN

'This SUB contains the protected code. Ordinarily this would do
' something useful; here we just generate a few example exceptions.
SUB Try
  aborted = $$TRUE 'set FALSE if SUB exits normally
  ShowMessage (@" Enter protected code.")
  ShowMessage ("  Raise exception "+STRING$(#exCode)+" ("+name$+")")

  SELECT CASE #exCode 'this value is selected by the radio buttons
'the simplest to generate a breakpoint is the STOP statement
' XstRaiseException() or XstCauseException() can also be used
    CASE $$ExceptionBreakpoint
      STOP

'Divide-by-zero exception occurs because y has not been assigned a value.
'If $$ExceptionRetry has been selected, SUB Except assigns a value to y,
' and returns control to the Retry label.
    CASE $$ExceptionIntDivideByZero
      ShowMessage (@"   z = 10 / 0")
Retry:
      z = 10 / y
      ShowMessage (@"   z = 10 / 2")

'Any exception can be raised through XstRaiseException(). In this example,
' a user exception is registered in FUNCTION MainWindow(), SUB ButtonClick,
' when the appropriate radio button is selected.
    CASE ELSE
      XstRaiseException (#exCode, #exType, @args[])

  END SELECT
  ShowMessage (@" Normal exit from protected code.")
  aborted = $$FALSE
END SUB

'Control is passed to this handler by XstTry() when an exception occurs.
' The EXCEPTION_DATA variable contains information about the exception,
' and the handler sets the .response member to indicate how the exception
' is to be handled.
SUB Except
  ShowMessage (@"   Enter exception handler: ")
  XstExceptionNumberToName (exception.code, @name$)
  ShowMessage ("     " +name$+" at address "+HEXX$(exception.address,8))
  exception.response = #exResponse 'selected by appropriate radio button
  SELECT CASE exception.response
    CASE $$ExceptionForward   : GOSUB MsgForward
    CASE $$ExceptionContinue  : GOSUB MsgContinue
    CASE $$ExceptionRetry
      IF exception.code == $$ExceptionIntDivideByZero THEN
          y = 2
          ShowMessage (@"     set divisor = 2 and retry")
          exception.address = GOADDRESS(Retry) 'MUST be an address within SUB Try
        ELSE
          GOSUB MsgRetry
      END IF
  END SELECT
  ShowMessage (@"   Leave exception handler.")
END SUB

SUB MsgForward
  title$ = "Fatal Exception!"
  msg$ = "The exception is about to be forwarded to the default handler. Press"
  msg$ = msg$ + " OK to watch the program crash, Cancel to ignore the exception."
  flag = $$MB_OKCANCEL | $$MB_ICONWARNING
  IF MessageBoxA (#winMain, &msg$, &title$, flag) == $$IDCANCEL THEN
    exception.response = $$ExceptionTerminate
  END IF
END SUB

SUB MsgContinue
  IF exception.type == $$ExceptionTypeError THEN
    title$ = "Fatal Exception!"
    msg$ = "$$ExceptionContinue not valid with $$ExceptionTypeError. Press"
    msg$ = msg$ + " OK to watch the program crash, Cancel to ignore the exception."
    flag = $$MB_OKCANCEL|$$MB_ICONWARNING
    IF MessageBoxA (#winMain, &msg$, &title$, flag) == $$IDCANCEL THEN
      exception.response = $$ExceptionTerminate
    END IF
  END IF
END SUB

SUB MsgRetry
  title$ = "Information"
  msg$ ="Exception address is unchanged (see source code), so "
  msg$ = msg$ +  "$$ExceptionRetry is treated like $$ExceptionContinue."
  flag = $$MB_OK|$$MB_ICONINFORMATION
  MessageBoxA (#winMain, &msg$, &title$, flag)
  GOSUB MsgContinue
END SUB

END FUNCTION

'This function is called only if the exception is forwarded to the
' default handler. See documentation for XstSetExceptionFunction().
' Might be used for clean-up code, or to display a message.
'
FUNCTION  ExceptionFunction ()

  ShowMessage (@"Execute user-installed exception function.")
  CleanUp ()
  RETURN $$ExceptionForward


END FUNCTION
END PROGRAM
