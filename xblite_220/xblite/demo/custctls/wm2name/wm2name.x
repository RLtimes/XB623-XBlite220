'
'
' ####################
' #####  PROLOG  #####
' ####################
'
'
'
PROGRAM "wm2name"
VERSION "000.1"
'
IMPORT "xst"
'IMPORT "xio"
IMPORT "gdi32"
IMPORT "kernel32"
IMPORT "user32"
IMPORT "comctl32"
IMPORT "cmcs21"
'
'
EXPORT
DECLARE FUNCTION Msg2Name (hWnd, msg, wParam, lParam)
DECLARE FUNCTION ShowWM2Name ()
DECLARE FUNCTION DestroyWM2Name ()
END EXPORT
'
INTERNAL FUNCTION Entry ()
INTERNAL FUNCTION PlaceWindow (hwnd)
INTERNAL FUNCTION InitGui ()
INTERNAL FUNCTION CreateWindows ()
INTERNAL FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
INTERNAL FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
INTERNAL FUNCTION MessageLoop ()
INTERNAL FUNCTION RegisterWinClass (style, wndProc, clsExtra, wndExtra, hInst, icon$, cursor$, bckGrdClr, menuName, className$)
INTERNAL FUNCTION InitConsole ()
INTERNAL FUNCTION WM2Name (hWnd, msg, wParam, lParam)
INTERNAL FUNCTION AddFontToControl (hwndCtl, fontName$, pointSize, weight, italic, underline)
INTERNAL FUNCTION CCMsg (wParam)
INTERNAL FUNCTION SetCMAppearance (hCodeMax)
INTERNAL FUNCTION GetWindowTextPlus (hWnd, text$)
'
'
' #######################
' ##### Msg2Name () #####
' #######################

FUNCTION Msg2Name (hWnd, msg, wParam, lParam)

 SHARED hCM_Hwnd
 SHARED hCM_Msg
 SHARED hCM_WParam
 SHARED hCM_LParam
 SHARED onMseMve, onMseFirst
 SHARED onSetCur
 SHARED onNcHitTst
 SHARED onCtlClrMsgBx, onCtlClrEdit, onCtlClrLstBx
 SHARED onCtlClrBtn, onCtlClrDlg, onCtlClrScrlBar, onCtlClrStatic
 SHARED proOff
 STATIC num
 STATIC sameWin
 CM_POSITION  cmp

 IF proOff THEN RETURN

 access = 1
 hexPos = 24
 hpPos  = 2
 lpPos  = 10

 IF (sameWin != hWnd) THEN
  sameWin = hWnd
  GetWindowTextPlus (hWnd, @text$)
  hwnd$ = STRING$(hWnd)
  tLen = LEN(text$)
  IF (tLen >= hexPos) THEN hexPos = tLen + 1
  title$ = text$ + SPACE$(hexPos - tLen) + hwnd$ + "\n"
  lines = SendMessageA (hCM_Hwnd, $$CMM_GETLINECOUNT, 0, 0)
  SendMessageA (hCM_Hwnd, $$CMM_ADDTEXT, lines, &title$)
  SendMessageA (hCM_Hwnd, $$CMM_SETCARETPOS, lines, 0)
 END IF

'Window Notification Messages
 SELECT CASE msg
   CASE $$WM_NULL                   : msg$ = "$$WM_NULL"
   CASE $$WM_CREATE                 : msg$ = "$$WM_CREATE"
   CASE $$WM_DESTROY                : msg$ = "$$WM_DESTROY"
   CASE $$WM_MOVE                   : msg$ = "$$WM_MOVE"
   CASE $$WM_SIZE                   : msg$ = "$$WM_SIZE"
   CASE $$WM_ACTIVATE               : msg$ = "$$WM_ACTIVATE"
   CASE $$WM_SETFOCUS               : msg$ = "$$WM_SETFOCUS"
   CASE $$WM_KILLFOCUS              : msg$ = "$$WM_KILLFOCUS"
   CASE $$WM_ENABLE                 : msg$ = "$$WM_ENABLE"
   CASE $$WM_SETREDRAW              : msg$ = "$$WM_SETREDRAW"
   CASE $$WM_SETTEXT                : msg$ = "$$WM_SETTEXT"
   CASE $$WM_GETTEXT                : msg$ = "$$WM_GETTEXT"
   CASE $$WM_GETTEXTLENGTH          : msg$ = "$$WM_GETTEXTLENGTH"
   CASE $$WM_PAINT                  : msg$ = "$$WM_PAINT"
   CASE $$WM_CLOSE                  : msg$ = "$$WM_CLOSE"
   CASE $$WM_QUERYENDSESSION        : msg$ = "$$WM_QUERYENDSESSION"
   CASE $$WM_QUIT                   : msg$ = "$$WM_QUIT"
   CASE $$WM_QUERYOPEN              : msg$ = "$$WM_QUERYOPEN"
   CASE $$WM_ERASEBKGND             : msg$ = "$$WM_ERASEBKGND"
   CASE $$WM_SYSCOLORCHANGE         : msg$ = "$$WM_SYSCOLORCHANGE"
   CASE $$WM_ENDSESSION             : msg$ = "$$WM_ENDSESSION"
   CASE $$WM_SHOWWINDOW             : msg$ = "$$WM_SHOWWINDOW"
   CASE $$WM_WININICHANGE           : msg$ = "$$WM_WININICHANGE"
   CASE $$WM_DEVMODECHANGE          : msg$ = "$$WM_DEVMODECHANGE"
   CASE $$WM_ACTIVATEAPP            : msg$ = "$$WM_ACTIVATEAPP"
   CASE $$WM_FONTCHANGE             : msg$ = "$$WM_FONTCHANGE"
   CASE $$WM_TIMECHANGE             : msg$ = "$$WM_TIMECHANGE"
   CASE $$WM_CANCELMODE             : msg$ = "$$WM_CANCELMODE"
   CASE $$WM_SETCURSOR              : msg$ = "$$WM_SETCURSOR"
   CASE $$WM_MOUSEACTIVATE          : msg$ = "$$WM_MOUSEACTIVATE"
   CASE $$WM_CHILDACTIVATE          : msg$ = "$$WM_CHILDACTIVATE"
   CASE $$WM_QUEUESYNC              : msg$ = "$$WM_QUEUESYNC"
   CASE $$WM_GETMINMAXINFO          : msg$ = "$$WM_GETMINMAXINFO"
   CASE $$WM_PAINTICON              : msg$ = "$$WM_PAINTICON"
   CASE $$WM_ICONERASEBKGND         : msg$ = "$$WM_ICONERASEBKGND"
   CASE $$WM_NEXTDLGCTL             : msg$ = "$$WM_NEXTDLGCTL"
   CASE $$WM_SPOOLERSTATUS          : msg$ = "$$WM_SPOOLERSTATUS"
   CASE $$WM_DRAWITEM               : msg$ = "$$WM_DRAWITEM"
   CASE $$WM_MEASUREITEM            : msg$ = "$$WM_MEASUREITEM"
   CASE $$WM_DELETEITEM             : msg$ = "$$WM_DELETEITEM"
   CASE $$WM_VKEYTOITEM             : msg$ = "$$WM_VKEYTOITEM"
   CASE $$WM_CHARTOITEM             : msg$ = "$$WM_CHARTOITEM"
   CASE $$WM_SETFONT                : msg$ = "$$WM_SETFONT"
   CASE $$WM_GETFONT                : msg$ = "$$WM_GETFONT"
   CASE $$WM_SETHOTKEY              : msg$ = "$$WM_SETHOTKEY"
   CASE $$WM_GETHOTKEY              : msg$ = "$$WM_GETHOTKEY"
   CASE $$WM_QUERYDRAGICON          : msg$ = "$$WM_QUERYDRAGICON"
   CASE $$WM_COMPAREITEM            : msg$ = "$$WM_COMPAREITEM"
   CASE $$WM_COMPACTING             : msg$ = "$$WM_COMPACTING"
   CASE $$WM_OTHERWINDOWCREATED     : msg$ = "$$WM_OTHERWINDOWCREATED"
   CASE $$WM_OTHERWINDOWDESTROYED   : msg$ = "$$WM_OTHERWINDOWDESTROYED"
   CASE $$WM_COMMNOTIFY             : msg$ = "$$WM_COMMNOTIFY"
   CASE $$WM_WINDOWPOSCHANGING      : msg$ = "$$WM_WINDOWPOSCHANGING"
   CASE $$WM_WINDOWPOSCHANGED       : msg$ = "$$WM_WINDOWPOSCHANGED"
   CASE $$WM_POWER                  : msg$ = "$$WM_POWER"
   CASE $$WM_COPYDATA               : msg$ = "$$WM_COPYDATA"
   CASE $$WM_CANCELJOURNAL          : msg$ = "$$WM_CANCELJOURNAL"
   CASE $$WM_NOTIFY                 : msg$ = "$$WM_NOTIFY"
   CASE $$WM_INPUTLANGCHANGEREQUEST : msg$ = "$$WM_INPUTLANGCHANGEREQUEST"
   CASE $$WM_INPUTLANGCHANGE        : msg$ = "$$WM_INPUTLANGCHANGE"
   CASE $$WM_TCARD                  : msg$ = "$$WM_TCARD"
   CASE $$WM_HELP                   : msg$ = "$$WM_HELP"
   CASE $$WM_USERCHANGED            : msg$ = "$$WM_USERCHANGED"
   CASE $$WM_NOTIFYFORMAT           : msg$ = "$$WM_NOTIFYFORMAT"
   CASE $$WM_CONTEXTMENU            : msg$ = "$$WM_CONTEXTMENU"
   CASE $$WM_STYLECHANGING          : msg$ = "$$WM_STYLECHANGING"
   CASE $$WM_STYLECHANGED           : msg$ = "$$WM_STYLECHANGED"
   CASE $$WM_DISPLAYCHANGE          : msg$ = "$$WM_DISPLAYCHANGE"
   CASE $$WM_GETICON                : msg$ = "$$WM_GETICON"
   CASE $$WM_SETICON                : msg$ = "$$WM_SETICON"
   CASE $$WM_NCCREATE               : msg$ = "$$WM_NCCREATE"
   CASE $$WM_NCDESTROY              : msg$ = "$$WM_NCDESTROY"
   CASE $$WM_NCCALCSIZE             : msg$ = "$$WM_NCCALCSIZE"
   CASE $$WM_NCHITTEST              : msg$ = "$$WM_NCHITTEST"
   CASE $$WM_NCPAINT                : msg$ = "$$WM_NCPAINT"
   CASE $$WM_NCACTIVATE             : msg$ = "$$WM_NCACTIVATE"
   CASE $$WM_GETDLGCODE             : msg$ = "$$WM_GETDLGCODE"
   CASE $$WM_NCMOUSEMOVE            : msg$ = "$$WM_NCMOUSEMOVE"
   CASE $$WM_NCLBUTTONDOWN          : msg$ = "$$WM_NCLBUTTONDOWN"
   CASE $$WM_NCLBUTTONUP            : msg$ = "$$WM_NCLBUTTONUP"
   CASE $$WM_NCLBUTTONDBLCLK        : msg$ = "$$WM_NCLBUTTONDBLCLK"
   CASE $$WM_NCRBUTTONDOWN          : msg$ = "$$WM_NCRBUTTONDOWN"
   CASE $$WM_NCRBUTTONUP            : msg$ = "$$WM_NCRBUTTONUP"
   CASE $$WM_NCRBUTTONDBLCLK        : msg$ = "$$WM_NCRBUTTONDBLCLK"
   CASE $$WM_NCMBUTTONDOWN          : msg$ = "$$WM_NCMBUTTONDOWN"
   CASE $$WM_NCMBUTTONUP            : msg$ = "$$WM_NCMBUTTONUP"
   CASE $$WM_NCMBUTTONDBLCLK        : msg$ = "$$WM_NCMBUTTONDBLCLK"
   CASE $$WM_KEYFIRST               : msg$ = "$$WM_KEYFIRST"
   CASE $$WM_KEYDOWN                : msg$ = "$$WM_KEYDOWN"
   CASE $$WM_KEYUP                  : msg$ = "$$WM_KEYUP"
   CASE $$WM_CHAR                   : msg$ = "$$WM_CHAR"
   CASE $$WM_DEADCHAR               : msg$ = "$$WM_DEADCHAR"
   CASE $$WM_SYSKEYDOWN             : msg$ = "$$WM_SYSKEYDOWN"
   CASE $$WM_SYSKEYUP               : msg$ = "$$WM_SYSKEYUP"
   CASE $$WM_SYSCHAR                : msg$ = "$$WM_SYSCHAR"
   CASE $$WM_SYSDEADCHAR            : msg$ = "$$WM_SYSDEADCHAR"
   CASE $$WM_KEYLAST                : msg$ = "$$WM_KEYLAST"
   CASE $$WM_INITDIALOG             : msg$ = "$$WM_INITDIALOG"
   CASE $$WM_COMMAND                : msg$ = "$$WM_COMMAND"
   CASE $$WM_SYSCOMMAND             : msg$ = "$$WM_SYSCOMMAND"
   CASE $$WM_TIMER                  : msg$ = "$$WM_TIMER"
   CASE $$WM_HSCROLL                : msg$ = "$$WM_HSCROLL"
   CASE $$WM_VSCROLL                : msg$ = "$$WM_VSCROLL"
   CASE $$WM_INITMENU               : msg$ = "$$WM_INITMENU"
   CASE $$WM_INITMENUPOPUP          : msg$ = "$$WM_INITMENUPOPUP"
   CASE $$WM_MENUSELECT             : msg$ = "$$WM_MENUSELECT"
   CASE $$WM_MENUCHAR               : msg$ = "$$WM_MENUCHAR"
   CASE $$WM_ENTERIDLE              : msg$ = "$$WM_ENTERIDLE"
   CASE $$WM_CTLCOLORMSGBOX         : msg$ = "$$WM_CTLCOLORMSGBOX"
   CASE $$WM_CTLCOLOREDIT           : msg$ = "$$WM_CTLCOLOREDIT"
   CASE $$WM_CTLCOLORLISTBOX        : msg$ = "$$WM_CTLCOLORLISTBOX"
   CASE $$WM_CTLCOLORBTN            : msg$ = "$$WM_CTLCOLORBTN"
   CASE $$WM_CTLCOLORDLG            : msg$ = "$$WM_CTLCOLORDLG"
   CASE $$WM_CTLCOLORSCROLLBAR      : msg$ = "$$WM_CTLCOLORSCROLLBAR"
   CASE $$WM_CTLCOLORSTATIC         : msg$ = "$$WM_CTLCOLORSTATIC"
   CASE $$WM_MOUSEFIRST             : msg$ = "$$WM_MOUSEFIRST"
   CASE $$WM_MOUSEMOVE              : msg$ = "$$WM_MOUSEMOVE"
   CASE $$WM_LBUTTONDOWN            : msg$ = "$$WM_LBUTTONDOWN"
   CASE $$WM_LBUTTONUP              : msg$ = "$$WM_LBUTTONUP"
   CASE $$WM_LBUTTONDBLCLK          : msg$ = "$$WM_LBUTTONDBLCLK"
   CASE $$WM_RBUTTONDOWN            : msg$ = "$$WM_RBUTTONDOWN"
   CASE $$WM_RBUTTONUP              : msg$ = "$$WM_RBUTTONUP"
   CASE $$WM_RBUTTONDBLCLK          : msg$ = "$$WM_RBUTTONDBLCLK"
   CASE $$WM_MBUTTONDOWN            : msg$ = "$$WM_MBUTTONDOWN"
   CASE $$WM_MBUTTONUP              : msg$ = "$$WM_MBUTTONUP"
   CASE $$WM_MBUTTONDBLCLK          : msg$ = "$$WM_MBUTTONDBLCLK"
   CASE $$WM_MOUSEWHEEL             : msg$ = "$$WM_MOUSEWHEEL"
   CASE $$WM_XBUTTONDOWN            : msg$ = "$$WM_XBUTTONDOWN"
   CASE $$WM_XBUTTONUP              : msg$ = "$$WM_XBUTTONUP"
   CASE $$WM_XBUTTONDBLCLK          : msg$ = "$$WM_XBUTTONDBLCLK"
   CASE $$WM_MOUSELAST              : msg$ = "$$WM_MOUSELAST"
   CASE $$WM_MOUSEHOVER             : msg$ = "$$WM_MOUSEHOVER"
   CASE $$WM_MOUSELEAVE             : msg$ = "$$WM_MOUSELEAVE"
   CASE $$WM_PARENTNOTIFY           : msg$ = "$$WM_PARENTNOTIFY"
   CASE $$WM_ENTERMENULOOP          : msg$ = "$$WM_ENTERMENULOOP"
   CASE $$WM_EXITMENULOOP           : msg$ = "$$WM_EXITMENULOOP"
   CASE $$WM_MDICREATE              : msg$ = "$$WM_MDICREATE"
   CASE $$WM_MDIDESTROY             : msg$ = "$$WM_MDIDESTROY"
   CASE $$WM_MDIACTIVATE            : msg$ = "$$WM_MDIACTIVATE"
   CASE $$WM_MDIRESTORE             : msg$ = "$$WM_MDIRESTORE"
   CASE $$WM_MDINEXT                : msg$ = "$$WM_MDINEXT"
   CASE $$WM_MDIMAXIMIZE            : msg$ = "$$WM_MDIMAXIMIZE"
   CASE $$WM_MDITILE                : msg$ = "$$WM_MDITILE"
   CASE $$WM_MDICASCADE             : msg$ = "$$WM_MDICASCADE"
   CASE $$WM_MDIICONARRANGE         : msg$ = "$$WM_MDIICONARRANGE"
   CASE $$WM_MDIGETACTIVE           : msg$ = "$$WM_MDIGETACTIVE"
   CASE $$WM_MDISETMENU             : msg$ = "$$WM_MDISETMENU"
   CASE $$WM_DROPFILES              : msg$ = "$$WM_DROPFILES"
   CASE $$WM_MDIREFRESHMENU         : msg$ = "$$WM_MDIREFRESHMENU"
   CASE $$WM_CUT                    : msg$ = "$$WM_CUT"
   CASE $$WM_COPY                   : msg$ = "$$WM_COPY"
   CASE $$WM_PASTE                  : msg$ = "$$WM_PASTE"
   CASE $$WM_CLEAR                  : msg$ = "$$WM_CLEAR"
   CASE $$WM_UNDO                   : msg$ = "$$WM_UNDO"
   CASE $$WM_RENDERFORMAT           : msg$ = "$$WM_RENDERFORMAT"
   CASE $$WM_RENDERALLFORMATS       : msg$ = "$$WM_RENDERALLFORMATS"
   CASE $$WM_DESTROYCLIPBOARD       : msg$ = "$$WM_DESTROYCLIPBOARD"
   CASE $$WM_DRAWCLIPBOARD          : msg$ = "$$WM_DRAWCLIPBOARD"
   CASE $$WM_PAINTCLIPBOARD         : msg$ = "$$WM_PAINTCLIPBOARD"
   CASE $$WM_VSCROLLCLIPBOARD       : msg$ = "$$WM_VSCROLLCLIPBOARD"
   CASE $$WM_SIZECLIPBOARD          : msg$ = "$$WM_SIZECLIPBOARD"
   CASE $$WM_ASKCBFORMATNAME        : msg$ = "$$WM_ASKCBFORMATNAME"
   CASE $$WM_CHANGECBCHAIN          : msg$ = "$$WM_CHANGECBCHAIN"
   CASE $$WM_HSCROLLCLIPBOARD       : msg$ = "$$WM_HSCROLLCLIPBOARD"
   CASE $$WM_QUERYNEWPALETTE        : msg$ = "$$WM_QUERYNEWPALETTE"
   CASE $$WM_PALETTEISCHANGING      : msg$ = "$$WM_PALETTEISCHANGING"
   CASE $$WM_PALETTECHANGED         : msg$ = "$$WM_PALETTECHANGED"
   CASE $$WM_HOTKEY                 : msg$ = "$$WM_HOTKEY"
   CASE $$WM_PENWINFIRST            : msg$ = "$$WM_PENWINFIRST"
   CASE $$WM_PENWINLAST             : msg$ = "$$WM_PENWINLAST"
   CASE $$EM_SCROLL                 : msg$ = "$$EM_SCROLL"
   CASE ELSE                        : msg$ = "Message not recognized:"
END SELECT

SELECT CASE msg
 CASE $$WM_SETCURSOR         : IF onSetCur        THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_NCHITTEST         : IF onNcHitTst      THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_MOUSEFIRST        : IF onMseFirst      THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_MOUSEMOVE         : IF onMseMve        THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_CTLCOLORMSGBOX    : IF onCtlClrMsgBx   THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_CTLCOLOREDIT      : IF onCtlClrEdit    THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_CTLCOLORLISTBOX   : IF onCtlClrLstBx   THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_CTLCOLORBTN       : IF onCtlClrBtn     THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_CTLCOLORDLG       : IF onCtlClrDlg     THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_CTLCOLORSCROLLBAR : IF onCtlClrScrlBar THEN access = 1 ELSE access = $$FALSE
 CASE $$WM_CTLCOLORSTATIC    : IF onCtlClrStatic  THEN access = 1 ELSE access = $$FALSE
END SELECT

INC num

IF access THEN
 mLen = LEN(msg$)
'If title is >= hexPos, increase hexPos (len + 5) otherwise a crash will occur
 IF (mLen >= hexPos) THEN hexPos = mLen + 5
 msg$ = msg$ + SPACE$(hexPos - mLen) + HEXX$(msg) + "\n"
 lines = SendMessageA (hCM_Msg, $$CMM_GETLINECOUNT, 0, 0)
 SendMessageA (hCM_Msg, $$CMM_ADDTEXT, 0, &msg$)
 SendMessageA (hCM_Msg, $$CMM_SETCARETPOS, lines, 0)
 CCMsg (wParam)
 lParam$ = STRING$(lParam) + SPACE$(hpPos) + STRING$(HIWORD(lParam)) + SPACE$(lpPos) + STRING$(LOWORD(lParam))
 lParam$ = lParam$ + "\n"
 lines = SendMessageA (hCM_LParam, $$CMM_GETLINECOUNT, 0, 0)
 SendMessageA (hCM_LParam, $$CMM_ADDTEXT, 0, &lParam$)
 SendMessageA (hCM_LParam, $$CMM_SETCARETPOS, lines, 0)
END IF

END FUNCTION
'
'
' ###########################
' ##### ShowWM2Name ()  #####
' ###########################
'
FUNCTION ShowWM2Name ()
 Entry ()
END FUNCTION
'
'
' ##############################
' #####  DestroyWM2Name () #####
' ##############################
'
FUNCTION  DestroyWM2Name ()

  SHARED hInst
  SHARED fConsole
  SHARED className$

  UnregisterClassA(&className$, hInst)
'  IF fConsole THEN XioFreeConsole ()          ' free console before leaving!!

END FUNCTION
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' Programs contain:
'   1. A PROLOG with type/function/constant declarations.
'   2. This Entry() function where execution begins.
'   3. Zero or more additional functions.
'
FUNCTION  Entry ()

  STATIC  entry

  IF entry THEN RETURN           ' enter once
  entry =  $$TRUE                ' enter occured

 'InitConsole ()                 ' create console, if console is not wanted, comment out this line
  InitGui ()                     ' initialize program and libraries
  CreateWindows ()               ' create windows and other child controls
  MessageLoop ()                 ' the main message loop
  DestroyWM2Name ()              ' unregister all window classes

END FUNCTION
'
'
' ############################
' #####  PlaceWindow ()  #####
' ############################
'
FUNCTION  PlaceWindow (hWnd)

  RECT wRect

  GetWindowRect (hWnd, &wRect)
  #screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
  #screenHeight = GetSystemMetrics ($$SM_CYSCREEN)
  x = (#screenWidth  - wRect.right)  - 10
  y = (#screenHeight - wRect.bottom) - 60
  SetWindowPos (hWnd, 0, x, y, 0, 0, $$SWP_NOSIZE OR $$SWP_NOZORDER)

END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
FUNCTION  InitGui ()

  SHARED hInst
  SHARED hBitMapCmb
  SHARED proOff
  SHARED onBtn

  hInst = GetModuleHandleA (0)    ' get current instance handle
  IFZ hInst THEN QUIT(0)
  InitCommonControls()            ' initialize comctl32.dll library
  proOff = 1
  onBtn  = 1

  ret = CMRegisterControl(0x02100)
  SELECT CASE ret
   CASE $$CME_SUCCESS     : 'PRINT "success"
   CASE $$CME_FAILURE     : 'PRINT "failure"
   CASE $$CME_BADARGUMENT : 'PRINT "badargument"
  END SELECT

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

 WM2Name = WM2Name (0, 0, 0, 0)
 PlaceWindow (WM2Name)                   ' center window position
 ShowWindow (WM2Name, $$SW_SHOWNORMAL)    ' show window
 #WM2Name = WM2Name

END FUNCTION
'
'
' ##########################
' #####  NewWindow ()  #####
' ##########################
'
FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

  SHARED hInst

' create window, return with window number (hwnd)
  hwnd = CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

  RETURN hwnd

END FUNCTION
'
'
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

  SHARED hInst

' create child control
  style = style | $$WS_CHILD | $$WS_VISIBLE
  hwnd = CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)
  AddFontToControl (hwnd, "Arial", 10, 5, $$FALSE, $$FALSE)

  RETURN hwnd

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

 STATIC MSG msg

' main message loop

    IF LIBRARY(0) THEN RETURN           ' main program executes message loop

    DO
        ret = GetMessageA (&msg, 0, 0, 0)

        SELECT CASE ret
            CASE  0 : RETURN msg.wParam
            CASE -1 : RETURN $$TRUE
            CASE ELSE:
               active = GetActiveWindow ()
               IFZ IsDialogMessageA (active, &msg) THEN      ' process dialog messages like TAB keys and arrow keys
                TranslateMessage (&msg)
                DispatchMessageA (&msg)
               END IF
        END SELECT
    LOOP

END FUNCTION
'
'
' #################################
' #####  RegisterWinClass ()  #####
' #################################
'
FUNCTION  RegisterWinClass (style, wndProc, clsExtra, wndExtra, hInst, icon$, cursor$, bckGrdClr, menuName, className$)

  SHARED WNDCLASS wc
  SHARED hIconScrab

  hIconScrab = LoadIconA (hInst, &icon$)

  sysIcon = 0
  SELECT CASE icon$
   CASE  "$$IDI_APPLICATION" : sysIcon = $$IDI_APPLICATION
   CASE  "$$IDI_HAND"        : sysIcon = $$IDI_HAND
   CASE  "$$IDI_QUESTION"    : sysIcon = $$IDI_QUESTION
   CASE  "$$IDI_EXCLAMATION" : sysIcon = $$IDI_EXCLAMATION
'  CASE  "$$IDI_ASTERISK"    : sysIcon = $$ASTERISK
   CASE  "$$IDI_WINLOGO"     : sysIcon = $$IDI_WINLOGO
  END SELECT

  sysCursor = 0
  SELECT CASE cursor$
   CASE "$$IDC_ARROW"        : sysCursor = $$IDC_ARROW
   CASE "$$IDC_IBEAM"        : sysCursor = $$IDC_IBEAM
   CASE "$$IDC_WAIT"         : sysCursor = $$IDC_WAIT
   CASE "$$IDC_CROSS"        : sysCursor = $$IDC_CROSS
   CASE "$$IDC_UPARROW"      : sysCursor = $$IDC_UPARROW
   CASE "$$IDC_SIZE"         : sysCursor = $$IDC_SIZE
   CASE "$$IDC_ICON"         : sysCursor = $$IDC_ICON
   CASE "$$IDC_SIZENWSE"     : sysCursor = $$IDC_SIZENWSE
   CASE "$$IDC_SIZENESW"     : sysCursor = $$IDC_SIZENESW
   CASE "$$IDC_SIZEWE"       : sysCursor = $$IDC_SIZEWE
   CASE "$$IDC_SIZENS"       : sysCursor = $$IDC_SIZENS
   CASE "$$IDC_SIZEALL"      : sysCursor = $$IDC_SIZEALL
   CASE "$$IDC_NO"           : sysCursor = $$IDC_NO
   CASE "$$IDC_HAND"         : sysCursor = $$IDC_HAND
   CASE "$$IDC_APPSTARTING"  : sysCursor = $$IDC_APPSTARTING
   CASE "$$IDC_HELP"         : sysCursor = $$IDC_HELP
  END SELECT

  wc.style          = style
  wc.lpfnWndProc    = wndProc
  wc.cbClsExtra     = clsExtra
  wc.cbWndExtra     = wndExtra
  wc.hInstance      = hInst
   IF sysIcon THEN
    wc.hIcon        = LoadIconA (hInst, sysIcon)
   ELSE
    wc.hIcon        = hIconScrab
   END IF
   IF sysCursor THEN
    wc.hCursor      = LoadCursorA (0, sysCursor)
   ELSE
    wc.hCursor      = LoadCursorA (0, &cursor$)
   END IF
  wc.hbrBackground  = GetStockObject (bckGrdClr)
  wc.lpszMenuName   = menuName
  wc.lpszClassName  = &className$

  IFZ RegisterClassA (&wc) THEN
   MessageBoxA (0, &"Classify error! Cannot continue! Shutting down!", &"error", $$MB_OK | $$MB_ICONSTOP)
   QUIT(0)
  END IF

END FUNCTION
'
'
' ############################
' #####  InitConsole ()  #####
' ############################
'
FUNCTION  InitConsole ()

  SHARED fConsole
  STATIC entry
  IFT entry THEN RETURN
  entry = $$TRUE
'  XioCreateConsole (@consoleTitle$, 100)
  fConsole = $$TRUE

END FUNCTION
'
'
' ######################
' ##### WM2Name () #####
' ######################
'
FUNCTION WM2Name (hWnd, msg, wParam, lParam)

 SHARED hInst
 SHARED hWM2N
 SHARED hCM_Hwnd
 SHARED hCM_Msg
 SHARED hCM_WParam
 SHARED hCM_LParam
 SHARED onEdit, onBtn, onCmbBx
 SHARED onLstBx, onStatic
 SHARED onMseMve, onMseFirst
 SHARED onSetCur
 SHARED onNcHitTst
 SHARED onCtlClrMsgBx, onCtlClrEdit, onCtlClrLstBx
 SHARED onCtlClrBtn, onCtlClrDlg, onCtlClrScrlBar, onCtlClrStatic
 SHARED proOff
 STATIC hMenu_DisableMsgs
 STATIC hMenu_CtrlType
 STATIC SUBADDR  sub[]

 $Menu_File_On                   = 100
 $Menu_File_Off                  = 101
 $Menu_File_Minimize             = 102
 $Menu_DisableMsgs               = 120
 $Menu_DisableMsgs_MouseMove     = 121
 $Menu_DisableMsgs_MouseFirst    = 122
 $Menu_DisableMsgs_SetCursor     = 123
 $Menu_DisableMsgs_NcHitTest     = 124
 $Menu_DisableMsgs_CtlClrMsgBx   = 125
 $Menu_DisableMsgs_CtlClrEdit    = 126
 $Menu_DisableMsgs_CtlClrLstBx   = 127
 $Menu_DisableMsgs_CtlClrBtn     = 128
 $Menu_DisableMsgs_CtlClrDlg     = 129
 $Menu_DisableMsgs_CtlClrScrlBar = 130
 $Menu_DisableMsgs_CtlClrStatic  = 131
 $Menu_CtrlType_Btn              = 140
 $Menu_CtrlType_CmbBx            = 141
 $Menu_CtrlType_Edit             = 142
 $Menu_CtrlType_LstBx            = 143
 $Menu_CtrlType_Static           = 144
 $GrpBx_Hwnd                     = 160
 $GrpBx_Msg                      = 161
 $GrpBx_WParam                   = 162
 $GrpBx_LParam                   = 163
 $CM_Hwnd                        = 180
 $CM_Msg                         = 181
 $CM_WParam                      = 182
 $CM_LParam                      = 183
 $PshBtn_Cancel                  = 200
 $ClassName                      = "WM2Name"

 IFZ sub[] THEN GOSUB InitializeWindow
 GOSUB @sub[msg]

 IF (msg == $$WM_CTLCOLOREDIT) THEN RETURN

 'WM_Msg2Name (msg)

'
'     (**************)
' (***** WM_COMMAND *****)
'     (**************)
'
SUB WM_COMMAND

  ctrlID     = LOWORD(wParam)
  ctrlHwnd   = lParam
  notifyCode = HIWORD(wParam)

  'WM_Msg2Name (msg)

  SELECT CASE TRUE
   CASE (ctrlID >= 100) AND (ctrlID <= 119) : GOSUB ManageMenuFile
   CASE (ctrlID >= 120) AND (ctrlID <= 139) : GOSUB ManageMenuDisableMsgs
   CASE (ctrlID >= 140) AND (ctrlID <= 159) : GOSUB ManageMenuCtrlType
  'CASE (ctrlID >= 160) AND (ctrlID <= 179) : GOSUB ManageMenuHelp
   CASE (ctrl == $PshBtn_Cancel)            : GOSUB WM_CLOSE
  END SELECT

END SUB
'
'     (******************)
' (***** ManageMenuFile *****)
'     (******************)
'
SUB ManageMenuFile

  SELECT CASE ctrlID
    CASE $Menu_File_On       : proOff = 0
    CASE $Menu_File_Off      : proOff = 1
    CASE $Menu_File_Minimize : GOSUB WM_CLOSE
  END SELECT

END SUB
'
'     (*************************)
' (***** ManageMenuDisableMsgs *****)
'     (*************************)
'
SUB ManageMenuDisableMsgs

 state = GetMenuState (hMenu_DisableMsgs, ctrlID, $$MF_BYCOMMAND)
 IF (state & $$MF_CHECKED) THEN
   CheckMenuItem (hMenu_DisableMsgs, ctrlID, $$MF_BYCOMMAND | $$MF_UNCHECKED)
  ELSE
   CheckMenuItem (hMenu_DisableMsgs, ctrlID, $$MF_BYCOMMAND | $$MF_CHECKED)
 END IF
 GOSUB GetKidsInfo
 RETURN ($$FALSE)

END SUB
'
'     (**********************)
' (***** ManageMenuCtrlType *****)
'     (**********************)
'
SUB ManageMenuCtrlType

 ' must toggle items radial-like along this menu
 count = GetMenuItemCount (hMenu_CtrlType)
 FOR oldChk = 0 TO count-1
  chkFirst = GetMenuState (hMenu_CtrlType, oldChk, $$MF_BYPOSITION)
  IF (chkFirst & $$MF_CHECKED) THEN EXIT FOR
 NEXT oldChk

 state = GetMenuState (hMenu_CtrlType, ctrlID, $$MF_BYCOMMAND)
 IF (state & $$MF_CHECKED) THEN
   CheckMenuItem (hMenu_CtrlType, ctrlID, $$MF_BYCOMMAND | $$MF_UNCHECKED)
  ELSE
   CheckMenuItem (hMenu_CtrlType, ctrlID, $$MF_BYCOMMAND | $$MF_CHECKED)
 END IF

 CheckMenuItem (hMenu_CtrlType, oldChk, $$MF_BYPOSITION | $$MF_UNCHECKED)
 GOSUB GetKidsInfo

 RETURN ($$FALSE)

END SUB
'
'     (******************)
' (***** ManageMenuHelp *****)
'     (******************)
'
SUB ManageMenuHelp

  'SELECT CASE ctrlID
   'CASE
   'CASE
  'END SELECT

END SUB
'
'     (***************)
' (***** GetKidsInfo *****)
'     (***************)
'
SUB GetKidsInfo

 onMseMve        = 0
 onMseFirst      = 0
 onSetCur        = 0
 onNcHitTst      = 0
 onCtlClrMsgBx   = 0
 onCtlClrEdit    = 0
 onCtlClrLstBx   = 0
 onCtlClrBtn     = 0
 onCtlClrDlg     = 0
 onCtlClrScrlBar = 0
 onCtlClrStatic  = 0

 SELECT CASE ALL FALSE
  CASE (GetMenuState (hMenu_DisableMsgs, 00, $$MF_BYPOSITION) & $$MF_CHECKED) : onMseMve        = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 01, $$MF_BYPOSITION) & $$MF_CHECKED) : onMseFirst      = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 03, $$MF_BYPOSITION) & $$MF_CHECKED) : onSetCur        = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 05, $$MF_BYPOSITION) & $$MF_CHECKED) : onNcHitTst      = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 07, $$MF_BYPOSITION) & $$MF_CHECKED) : onCtlClrMsgBx   = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 08, $$MF_BYPOSITION) & $$MF_CHECKED) : onCtlClrEdit    = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 09, $$MF_BYPOSITION) & $$MF_CHECKED) : onCtlClrLstBx   = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 10, $$MF_BYPOSITION) & $$MF_CHECKED) : onCtlClrBtn     = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 11, $$MF_BYPOSITION) & $$MF_CHECKED) : onCtlClrDlg     = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 12, $$MF_BYPOSITION) & $$MF_CHECKED) : onCtlClrScrlBar = 1
  CASE (GetMenuState (hMenu_DisableMsgs, 13, $$MF_BYPOSITION) & $$MF_CHECKED) : onCtlClrStatic  = 1
 END SELECT

 onBtn = 0 : onCmbBx = 0 : onEdit = 0 : onLstBx = 0 : onStatic = 0
 SELECT CASE TRUE
  CASE (GetMenuState (hMenu_CtrlType, 0, $$MF_BYPOSITION) & $$MF_CHECKED) : onBtn   = 1
  CASE (GetMenuState (hMenu_CtrlType, 1, $$MF_BYPOSITION) & $$MF_CHECKED) : onCmbBx = 1
  CASE (GetMenuState (hMenu_CtrlType, 2, $$MF_BYPOSITION) & $$MF_CHECKED) : onEdit  = 1
  CASE (GetMenuState (hMenu_CtrlType, 3, $$MF_BYPOSITION) & $$MF_CHECKED) : onLstBx = 1
  CASE (GetMenuState (hMenu_CtrlType, 4, $$MF_BYPOSITION) & $$MF_CHECKED) : onStatic = 1
 END SELECT

END SUB
'
'     (*********)
' (***** Apply *****)
'     (*********)
'
SUB Apply
END SUB
'
'     (*************)
' (***** WM_NOTIFY *****)
'     (*************)
'
SUB WM_NOTIFY
END SUB
'
'     (*************)
' (***** WM_CREATE *****)
'     (*************)
'
SUB WM_CREATE
END SUB
'
'     (**************)
' (***** WM_DESTROY *****)
'     (**************)
'
SUB WM_DESTROY
END SUB
'
'     (***********)
' (***** WM_SIZE *****)
'     (***********)
'
SUB WM_SIZE
END SUB
'
'     (***************)
' (***** WM_SETFOCUS *****)
'     (***************)
'
SUB WM_SETFOCUS
END SUB
'
'     (************)
' (***** WM_PAINT *****)
'     (************)
'
SUB WM_PAINT
END SUB
'
'     (************)
' (***** WM_CLOSE *****)
'     (************)
'
SUB WM_CLOSE

 ShowWindow (hWnd, $$SW_MINIMIZE)
 RETURN

END SUB
'
'     (*****************)
' (***** WM_INITDIALOG *****)
'     (*****************)
'
SUB WM_INITDIALOG
END SUB
'
'     (**********************)
' (***** WM_CTLCOLORLISTBOX *****)
'     (**********************)
'
SUB WM_CTLCOLORLISTBOX
END SUB
'
'     (********************)
' (***** InitializeWindow *****)
'     (********************)
'
SUB InitializeWindow
'
'
   DIM sub[$$WM_LASTMESSAGE]
   sub[$$WM_COMMAND]                  = SUBADDRESS (WM_COMMAND)
   sub[$$WM_NOTIFY]                   = SUBADDRESS (WM_NOTIFY)
   sub[$$WM_CREATE]                   = SUBADDRESS (WM_CREATE)
   sub[$$WM_DESTROY]                  = SUBADDRESS (WM_DESTROY)
   sub[$$WM_SIZE]                     = SUBADDRESS (WM_SIZE)
   sub[$$WM_SETFOCUS]                 = SUBADDRESS (WM_SETFOCUS)
   sub[$$WM_PAINT]                    = SUBADDRESS (WM_PAINT)
   sub[$$WM_CLOSE]                    = SUBADDRESS (WM_CLOSE)
   sub[$$WM_INITDIALOG]               = SUBADDRESS (WM_INITDIALOG)
   sub[$$WM_CTLCOLORLISTBOX]          = SUBADDRESS (WM_CTLCOLORLISTBOX)

 'register window class
  RegisterWinClass ($$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC, &WM2Name(), 0, 0, hInst, "$$IDI_APPLICATION", "$$IDC_ARROW", $$LTGRAY_BRUSH, 0, $ClassName)

 'create main window
  hWM2N  = NewWindow ($ClassName, "WM2Name (Dll): v1.0 - Created By Garquint", $$WS_OVERLAPPEDWINDOW & ~$$WS_MAXIMIZEBOX & ~$$WS_SIZEBOX, 0, 0, 350, 530, 0)

  hMenu = CreateMenu()
  hMenu_File = CreateMenu()
  InsertMenuA (hMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, hMenu_File, &"&File")
  AppendMenuA (hMenu_File, $$MF_STRING, $Menu_File_On, &"&On")
  AppendMenuA (hMenu_File, $$MF_SEPARATOR, 0, 0)
  AppendMenuA (hMenu_File, $$MF_STRING, $Menu_File_Off, &"O&ff")
  AppendMenuA (hMenu_File, $$MF_SEPARATOR, 0, 0)
  AppendMenuA (hMenu_File, $$MF_STRING, $Menu_File_Minimize, &"&Minimize")
  hMenu_DisableMsgs = CreateMenu()
  InsertMenuA (hMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, hMenu_DisableMsgs, &"&Disable Msgs")
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_MouseMove, &"WM_MOUSEMOVE")
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_MouseFirst, &"WM_MOUSEFIRST")
  AppendMenuA (hMenu_DisableMsgs, $$MF_SEPARATOR, 0, 0)
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_SetCursor, &"WM_SETCURSOR")
  AppendMenuA (hMenu_DisableMsgs, $$MF_SEPARATOR, 0, 0)
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_NcHitTest, &"WM_NCHITTEST")
  AppendMenuA (hMenu_DisableMsgs, $$MF_SEPARATOR, 0, 0)
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_CtlClrMsgBx, &"WM_CTLCOLORMSGBOX")
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_CtlClrEdit, &"WM_CTLCOLOREDIT")
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_CtlClrLstBx, &"WM_CTLCOLORLISTBOX")
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_CtlClrBtn, &"WM_CTLCOLORBTN")
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_CtlClrDlg, &"WM_CTLCOLORDLG")
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_CtlClrScrlBar, &"WM_CTLCOLORSCROLLBAR")
  AppendMenuA (hMenu_DisableMsgs, $$MF_STRING | $$MF_CHECKED, $Menu_DisableMsgs_CtlClrStatic, &"WM_CTLCOLORSTATIC")
  hMenu_CtrlType = CreateMenu()
  InsertMenuA (hMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, hMenu_CtrlType, &"&Control Type")
  AppendMenuA (hMenu_CtrlType, $$MF_STRING, $Menu_CtrlType_Btn, &"Push Button")
  AppendMenuA (hMenu_CtrlType, $$MF_STRING, $Menu_CtrlType_CmbBx, &"Combo Box")
  AppendMenuA (hMenu_CtrlType, $$MF_STRING, $Menu_CtrlType_Edit, &"Edit")
  AppendMenuA (hMenu_CtrlType, $$MF_STRING, $Menu_CtrlType_LstBx, &"List Box")
  AppendMenuA (hMenu_CtrlType, $$MF_STRING, $Menu_CtrlType_Static, &"Static")
  SetMenu (hWM2N, hMenu)

  CheckMenuItem (hMenu_CtrlType, $Menu_CtrlType_Btn, $$MF_BYCOMMAND | $$MF_CHECKED)

  NewChild ("button", "Num  Window Title" + SPACE$(35) + "Hwnd", $$BS_GROUPBOX, 5, 30, 335, 50, hWM2N, $GrpBx_Hwnd, 0)
  style  = $$WS_CHILD | $$WS_VISIBLE | $$WS_VSCROLL | $$WS_HSCROLL
  hCM_Hwnd =  CreateWindowExA ($$WS_EX_CLIENTEDGE, &"CodeSense", 0, style, 10, 45, 324, 30, hWM2N, $CM_Hwnd, hInst, 0)
  SendMessageA (hCM_Hwnd, $$CMM_SHOWSCROLLBAR, 0, 0)
  SendMessageA (hCM_Hwnd, $$CMM_SHOWSCROLLBAR, 1, 0)
  SetCMAppearance (hCM_Hwnd)
  NewChild ("button", "Order  Msg" + SPACE$(47) + "Hex", $$BS_GROUPBOX, 5, 80, 335, 200, hWM2N, $GrpBx_Msg, 0)
  style  = $$WS_CHILD | $$WS_VISIBLE | $$WS_VSCROLL | $$WS_HSCROLL
  hCM_Msg =  CreateWindowExA ($$WS_EX_CLIENTEDGE, &"CodeSense", 0, style, 10, 95, 324, 180, hWM2N, $CM_Msg, hInst, 0)
  SetCMAppearance (hCM_Msg)
  NewChild ("button", "Order  HIWORD(wParam)" + SPACE$(15) + "LOWORD(wParam)", $$BS_GROUPBOX, 5, 280, 335, 100, hWM2N, $GrpBx_WParam, 0)
  style  = $$WS_CHILD | $$WS_VISIBLE | $$WS_VSCROLL | $$WS_HSCROLL
  hCM_WParam =  CreateWindowExA ($$WS_EX_CLIENTEDGE, &"CodeSense", 0, style, 10, 295, 324, 80, hWM2N, $CM_WParam, hInst, 0)
  SetCMAppearance (hCM_WParam)
  NewChild ("button", "Order  LParam   HIWORD(lParam)  LOWORD(lParam)", $$BS_GROUPBOX, 5, 380, 335, 100, hWM2N, $GrpBx_LParam, 0)
  style  = $$WS_CHILD | $$WS_VISIBLE | $$WS_VSCROLL | $$WS_HSCROLL
  hCM_LParam =  CreateWindowExA ($$WS_EX_CLIENTEDGE, &"CodeSense", 0, style, 10, 395, 324, 80, hWM2N, $CM_LParam, hInst, 0)
  SetCMAppearance (hCM_LParam)

  RETURN hWM2N

END SUB

  RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
'
' #################################
' #####  AddFontToControl ()  #####
' #################################
'
FUNCTION  AddFontToControl (hwndCtl, fontName$, pointSize, weight, italic, underline)

    LOGFONT lf
    hDC = GetDC ($$HWND_DESKTOP)
    hFont = GetStockObject($$DEFAULT_GUI_FONT)  ' get a font handle
    bytes = GetObjectA(hFont, SIZE(lf), &lf)        ' fill LOGFONT struct lf
    lf.faceName = fontName$                                         ' set font name
    lf.italic = italic                                              ' set italic
    lf.weight = weight                                              ' set weight
    lf.underline = underline                                        ' set underline
    lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
    ReleaseDC ($$HWND_DESKTOP, hDC)
    SendMessageA (hwndCtl, $$WM_SETFONT, CreateFontIndirectA (&lf), $$TRUE)

END FUNCTION
'
'
' ####################
' ##### CCMsg () #####
' ####################
'
FUNCTION CCMsg (wParam)

 SHARED hCM_Hwnd
 SHARED hCM_Msg
 SHARED hCM_WParam
 SHARED hCM_LParam
 SHARED onEdit, onBtn, onCmbBx
 SHARED onLstBx, onStatic

 lwPos = 20

 IF onEdit THEN
  SELECT CASE HIWORD(wParam)
   CASE $$EN_SETFOCUS       : nc$ = "$$EN_SETFOCUS"
   CASE $$EN_KILLFOCUS      : nc$ = "$$EN_KILLFOCUS"
   CASE $$EN_CHANGE         : nc$ = "$$EN_CHANGE"
   CASE $$EN_UPDATE         : nc$ = "$$EN_UPDATE"
   CASE $$EN_ERRSPACE       : nc$ = "$$EN_ERRSPACE"
   CASE $$EN_MAXTEXT        : nc$ = "$$EN_MAXTEXT"
   CASE $$EN_HSCROLL        : nc$ = "$$EN_HSCROLL"
   CASE $$EN_VSCROLL        : nc$ = "$$EN_VSCROLL"
   CASE ELSE                : nc$ = "Not Recognized"
  END SELECT
 END IF

 IF onBtn THEN
  SELECT CASE HIWORD(wParam)
   CASE $$BN_CLICKED        : nc$ = "$$BN_CLICKED"
   CASE $$BN_PAINT          : nc$ = "$$BN_PAINT"
   CASE $$BN_HILITE         : nc$ = "$$BN_HILITE"
   CASE $$BN_UNHILITE       : nc$ = "$$BN_UNHILITE"
   CASE $$BN_DISABLE        : nc$ = "$$BN_DISABLE"
   CASE $$BN_DOUBLECLICKED  : nc$ = "$$BN_DOUBLECLICKED"
   CASE $$BN_PUSHED         : nc$ = "$$BN_PUSHED"
   CASE $$BN_UNPUSHED       : nc$ = "$$BN_UNPUSHED"
   CASE $$BN_DBLCLK         : nc$ = "$$BN_DBLCLK"
   CASE $$BN_SETFOCUS       : nc$ = "$$BN_SETFOCUS"
   CASE $$BN_KILLFOCUS      : nc$ = "$$BN_KILLFOCUS"
   CASE ELSE                : nc$ = "Not Recognized"
  END SELECT
 END IF

 IF onCmbBx THEN
  SELECT CASE HIWORD(wParam)
   CASE $$CBN_ERRSPACE      : nc$ = "$$CBN_ERRSPACE"
   CASE $$CBN_SELCHANGE     : nc$ = "$$CBN_SELCHANGE"
   CASE $$CBN_DBLCLK        : nc$ = "$$CBN_DBLCLK"
   CASE $$CBN_SETFOCUS      : nc$ = "$$CBN_SETFOCUS"
   CASE $$CBN_KILLFOCUS     : nc$ = "$$CBN_KILLFOCUS"
   CASE $$CBN_EDITCHANGE    : nc$ = "$$CBN_EDITCHANGE"
   CASE $$CBN_EDITUPDATE    : nc$ = "$$CBN_EDITUPDATE"
   CASE $$CBN_DROPDOWN      : nc$ = "$$CBN_DROPDOWN"
   CASE $$CBN_CLOSEUP       : nc$ = "$$CBN_CLOSEUP"
   CASE $$CBN_SELENDOK      : nc$ = "$$CBN_SELENDOK"
   CASE $$CBN_SELENDCANCEL  : nc$ = "$$CBN_SELENDCANCEL"
   CASE ELSE                : nc$ = "Not Recognized"
  END SELECT
 END IF

 IF onLstBx THEN
  SELECT CASE HIWORD(wParam)
   CASE $$LBN_ERRSPACE   : nc$ = "$$LBN_ERRSPACE"
   CASE $$LBN_SELCHANGE  : nc$ = "$$LBN_SELCHANGE"
   CASE $$LBN_DBLCLK     : nc$ = "$$LBN_DBLCLK"
   CASE $$LBN_SELCANCEL  : nc$ = "$$LBN_SELCANCEL"
   CASE $$LBN_SETFOCUS   : nc$ = "$$LBN_SETFOCUS"
   CASE $$LBN_KILLFOCUS  : nc$ = "$$LBN_KILLFOCUS"
   CASE ELSE             : nc$ = "Not Recognized"
  END SELECT
 END IF

 IF onStatic THEN
  SELECT CASE HIWORD(wParam)
   CASE $$STN_CLICKED  : nc$ = "$$STN_CLICKED"
   CASE $$STN_DBLCLK   : nc$ = "$$STN_DBLCLK"
   CASE $$STN_ENABLE   : nc$ = "$$STN_ENABLE"
   CASE $$STN_DISABLE  : nc$ = "$$STN_DISABLE"
   CASE ELSE           : nc$ = "Not Recognized"
  END SELECT
 END IF

 IF (nc$ == "") THEN nc$ = "Control Type off"
 ncLen = LEN(nc$)
 IF (ncLen >= lwPos) THEN lwPos = ncLen + 1
 wParam$ = nc$ + SPACE$(lwPos - ncLen) + STRING$(LOWORD(wParam)) + "\n"
'wParam$ = wParam$ + "\n"
 lines = SendMessageA (hCM_WParam, $$CMM_GETLINECOUNT, 0, 0)
 SendMessageA (hCM_WParam, $$CMM_ADDTEXT, 0, &wParam$)
 SendMessageA (hCM_WParam, $$CMM_SETCARETPOS, lines, 0)

END FUNCTION
'
'
' ##############################
' ##### SetCMAppearance () #####
' ##############################
'
FUNCTION SetCMAppearance (hCodeMax)

  CM_COLORS         cmc
  CM_FONTSTYLES     cmfs
  CM_LINENUMBERING  cmln

  white  = RGB(255, 255, 255) ' bkColor
  red    = RGB(255, 0, 0)     ' keyword color
  green  = RGB(0, 128, 0)     ' comment color
  blue   = RGB(0, 0, 160)
  purple = RGB(128, 0, 128)
  brown1 = RGB(128, 128, 0)
  yellow = RGB(255, 255, 0)
  grey1  = RGB(150, 150, 150)
  brown1 = RGB(171, 128, 24)
  black1 = RGB(95, 95, 95)
  grey   = RGB(192, 192, 192)

  cmc.crWindow              = white          ' window background color
  cmc.crLeftMargin          = white          ' left margin background color
  cmc.crBookmark            = blue           ' bookmark foreground color
  cmc.crBookmarkBk          = white          ' bookmark background color
  cmc.crText                = red            ' plain text foreground color
  cmc.crTextBk              = white          ' plain text background color
  cmc.crNumber              = blue           ' numeric literal foreground color
  cmc.crNumberBk            = white          ' numeric literal background color
  cmc.crKeyword             = red            ' keyword foreground color
  cmc.crKeywordBk           = white          ' keyword background color
  cmc.crOperator            = blue           ' operator foreground color
  cmc.crOperatorBk          = white          ' operator background color
  cmc.crScopeKeyword        = white          ' scope keyword foreground color
  cmc.crScopeKeywordBk      = brown1         ' scope keyword background color
  cmc.crComment             = green          ' comment foreground color
  cmc.crCommentBk           = white          ' comment background color
  cmc.crString              = purple         ' string foreground color
  cmc.crStringBk            = white          ' string background color
  cmc.crTagText             = purple         ' plain tag text foreground color
  cmc.crTagTextBk           = white          ' plain tag text background color
' cmc.crTagEntity           =                ' tag entity foreground color
  cmc.crTagEntityBk         = white          ' tag entity background color
' cmc.crTagElementName      =                ' tag element name foreground color
  cmc.crTagElementNameBk    = white          ' tag element name background color
' cmc.crTagAttributeName    =                ' tag attribute name foreground color
  cmc.crTagAttributeNameBk  = white          ' tag attribute name background color
  cmc.crLineNumber          = blue           ' line number foreground color
  cmc.crLineNumberBk        = white          ' line number background color
' cmc.crHDividerLines       =                ' line number separate line color
  cmc.crVDividerLines       = purple         ' left margin separate line color
  cmc.crHighlightedLine     = yellow         ' highlighted line color

 'cmfs.byText               = $$CM_FONT_NORMAL    ' plain text font style
 'cmfs.byNumber             = $$CM_FONT_NORMAL    ' numeric literal font style
 'cmfs.byKeyword            = $$CM_FONT_UNDERLINE ' keyword font style
 'cmfs.byOperator           = $$CM_FONT_NORMAL    ' operator font style
 'cmfs.byScopeKeyword       = $$CM_FONT_NORMAL    ' scope keyword font style
 'cmfs.byComment            = $$CM_FONT_NORMAL    ' comment font style
 'cmfs.byString             = $$CM_FONT_NORMAL    ' string font style
 'cmfs.byTagText            = $$CM_FONT_NORMAL    ' plain tag text font style
 'cmfs.byTagEntity          = $$CM_FONT_NORMAL    ' tag entity font style
 'cmfs.byTagElementName     = $$CM_FONT_NORMAL    ' tag element name font style
 'cmfs.byTagAttributeName   = $$CM_FONT_NORMAL    ' tag attribute name font style
 'cmfs.byLineNumber         = $$CM_FONT_NORMAL    ' line number font style

 cmln.bEnabled = 1
 cmln.nStartAt = 0
 cmln.dwStyle  = $$CM_DECIMAL

 SendMessageA (hCodeMax, $$CMM_SETCOLORS, 0, &cmc)
'SendMessageA (hCodeMax, $$CMM_SETFONTSTYLES, 0, &cmfs)
 SendMessageA (hCodeMax, $$CMM_SETLINENUMBERING, 0, &cmln)
 SendMessageA (hCodeMax, $$CMM_ENABLELEFTMARGIN, 0, 0)
 AddFontToControl (hCodeMax, "Courier", 2, 2, $$FALSE, $$FALSE)
 SendMessageA (hCodeMax, $$CMM_SETREADONLY, 1, 0)

END FUNCTION
'
'
' ################################
' ##### GetWindowTextPlus () #####
' ################################
'
FUNCTION GetWindowTextPlus (hWnd, text$)

 text$ = ""
 len = GetWindowTextLengthA (hWnd)
 text$ = NULL$(len)
 GetWindowTextA (hWnd, &text$, &len)

END FUNCTION
END PROGRAM
