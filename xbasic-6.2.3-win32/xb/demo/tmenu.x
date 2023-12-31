'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM "tmenu"
VERSION "0.0000"
'
IMPORT  "xst"
IMPORT  "xgr"
IMPORT  "xui"
'
INTERNAL FUNCTION  Menu            ( )
INTERNAL FUNCTION  GetDisplayGrid  ( @label )
INTERNAL FUNCTION  DisplayCallback ( grid, message$, v0, v1, v2, v3, kid, r1$ )
'
'
' ##################
' #####  Menu  #####
' ##################
'
FUNCTION  Menu ()
  $XuiMenu = 12
'
  GetDisplayGrid ( @label )
'
' create window with XuiMenu grid
'
  DIM menu$[15]             ' callback arguments
  menu$[ 0] = "_File"
  menu$[ 1] = " _Load"      ' v0 = 1 : v1 = 0
  menu$[ 2] = " _Save"      ' v0 = 1 : v1 = 1
  menu$[ 3] = " _Quit"      ' v0 = 1 : v1 = 2
  menu$[ 4] = "_Edit"
  menu$[ 5] = " _Cut"       ' v0 = 2 : v1 = 0
  menu$[ 6] = " _Grab"      ' v0 = 2 : v1 = 1
  menu$[ 7] = " _Paste"     ' v0 = 2 : v1 = 2
  menu$[ 8] = "_View"
  menu$[ 9] = " _First"     ' v0 = 3 : v1 = 0
  menu$[10] = " _Last"      ' v0 = 3 : v1 = 1
  menu$[11] = " _All"       ' v0 = 3 : v1 = 2
  menu$[12] = "_Help"
  menu$[13] = " _Contents"  ' v0 = 4 : v1 = 0
  menu$[14] = " _Summary"   ' v0 = 4 : v1 = 1
  menu$[15] = " _Index"     ' v0 = 4 : v1 = 2
'
  XuiCreateWindow      (@grid, @"XuiMenu", 100, 256, 256, 24, 0, "")
  XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $XuiMenu, -1)
  XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @"Menu")
  XuiSendStringMessage ( grid, @"SetTextArray", 0, 0, 0, 0, 0, @menu$[])
  XuiSendStringMessage ( grid, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
'
' convenience function message loop
'
  DO
    XgrProcessMessages (1)
    DO WHILE XuiGetNextCallback (@grid, @message$, @v0, @v1, @v2, @v3, @kid, @r1$)
      GOSUB Callback
    LOOP
  LOOP
  RETURN
'
' callback
'
SUB Callback
  win = kid >> 16
  kid = kid AND 0xFF
  SELECT CASE message$
    CASE "CloseWindow" : QUIT (0)
    CASE "Selection"   : GOSUB Selection
    CASE ELSE          : DisplayCallback (grid, @message$, v0, v1, v2, v3, kid, @r1$)
  END SELECT
END SUB
'
' Selection message
'
SUB Selection
  XuiSendStringMessage (grid, @"GetTextArray", 0, 0, 0, 0, 0, @text$[])
  IF text$[] THEN
    u = UBOUND (text$[])
    menubar = 0
    FOR i = 0 TO u
      text$ = text$[i]
      IF text$ THEN
        char = text${0}
        IF ((char != ' ') AND (char != '	')) THEN    ' not tab or space
          INC menubar
          IF (menubar = v0) THEN header = i : EXIT FOR
        END IF
      END IF
    NEXT i
    IF (v0 = menubar) THEN
      menu$ = text$[header]
      list = header + v1 + 1
      IF (list <= u) THEN list$ = text$[list]
      v0$ = " : Menu entry : \"" + menu$ + "\""
      v1$ = " : List entry : \"" + list$ + "\""
    END IF
  END IF
'
  text$ = "XuiMenu"
  text$ = text$ + "\n    grid = " + HEX$ (grid,8)
  text$ = text$ + "\n message = " + message$
  text$ = text$ + "\n   state = " + HEX$ (v0,8) + v0$
  text$ = text$ + "\n      v1 = " + HEX$ (v1,8) + v1$
  text$ = text$ + "\n      v2 = " + HEX$ (v2,8)
  text$ = text$ + "\n      v3 = " + HEX$ (v3,8)
  text$ = text$ + "\n     kid = " + HEX$ (kid,8)
  text$ = text$ + "\n     r1$ = " + r1$
  XuiSendStringMessage (label, @"SetTextString", 0, 0, 0, 0, 0, @text$)    ' set message text
  XuiSendStringMessage (label, @"Redraw", 0, 0, 0, 0, 0, 0)                ' redraw label
END SUB
END FUNCTION
'
'
' ###############################
' #####  GetDisplayGrid ()  #####
' ###############################
'
FUNCTION  GetDisplayGrid ( label )
  STATIC  grid
'
  IFZ grid THEN
    XuiCreateWindow      (@grid, @"XuiLabel", 100, 100, 512, 128, 0, "")
    XuiSendStringMessage ( grid, @"SetColor", $$BrightGreen, -1, -1, -1, 0, 0)
    XuiSendStringMessage ( grid, @"SetAlign", $$AlignUpperLeft, 0, 0, 0, 0, 0)
    XuiSendStringMessage ( grid, @"SetJustify", $$JustifyLeft, 0, 0, 0, 0, 0)
    XuiSendStringMessage ( grid, @"SetIndent", 6, 4, 0, 0, 0, 0)
    XuiSendStringMessage ( grid, @"DisplayWindow", 0, 0, 0, 0, 0, 0)
  END IF
'
  label = grid
END FUNCTION
'
'
' ################################
' #####  DisplayCallback ()  #####
' ################################
'
FUNCTION  DisplayCallback ( grid, message$, v0, v1, v2, v3, kid, r1$ )
'
  XgrGetGridType (grid, @gridType)
  XgrGridTypeNumberToName (gridType, @gridType$)
'
  text$ = gridType$ + "\n"
  text$ = text$ + "    grid = " + HEX$ (grid, 8) + "\n"
  text$ = text$ + " message = " + message$ + "\n"
  text$ = text$ + "      v0 = " + HEX$ (v0,8) + "\n"
  text$ = text$ + "      v1 = " + HEX$ (v1,8) + "\n"
  text$ = text$ + "      v2 = " + HEX$ (v2,8) + "\n"
  text$ = text$ + "      v3 = " + HEX$ (v3,8) + "\n"
  text$ = text$ + "     kid = " + HEX$ (kid,8) + "\n"
  text$ = text$ + "     r1$ = " + r1$
'
  GetDisplayGrid (@label)
  XuiSendStringMessage (label, @"SetTextString", 0, 0, 0, 0, 0, @text$)
  XuiSendStringMessage (label, @"Redraw", 0, 0, 0, 0, 0, 0)
END FUNCTION
END PROGRAM
 