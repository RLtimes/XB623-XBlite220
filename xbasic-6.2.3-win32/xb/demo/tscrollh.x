'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM "tscrollh"
VERSION "0.0000"
'
IMPORT  "xst"
IMPORT  "xgr"
IMPORT  "xui"
'
DECLARE  FUNCTION  ScrollBarH      ( )
INTERNAL FUNCTION  GetDisplayGrid  ( @label )
INTERNAL FUNCTION  DisplayCallback ( grid, message$, v0, v1, v2, v3, kid, r1$ )
'
'
' ########################
' #####  ScrollBarH  #####
' ########################
'
FUNCTION  ScrollBarH ()
  $XuiScrollBarH = 8
'
  GetDisplayGrid ( @label )
'
' create window with XuiScrollBarH grid
'
  XuiCreateWindow      (@grid, @"XuiScrollBarH", 100, 256, 256, 128, 0, "")
  XuiSendStringMessage ( grid, @"SetCallback", grid, &XuiQueueCallbacks(), -1, -1, $XuiScrollBarH, -1)
  XuiSendStringMessage ( grid, @"SetGridName", 0, 0, 0, 0, 0, @"ScrollBarH")
  XuiSendStringMessage ( grid, @"SetTextString", 0, 0, 0, 0, 0, @"XuiScrollBarH")
  XuiSendStringMessage ( grid, @"SetPosition", 0, 25, 75, 100, 0, 0)
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
    CASE "OneLess"     : GOSUB ScrollBarH
    CASE "MuchLess"    : GOSUB ScrollBarH
    CASE "Change"      : GOSUB ScrollBarH
    CASE "MuchMore"    : GOSUB ScrollBarH
    CASE "OneMore"     : GOSUB ScrollBarH
    CASE ELSE          : DisplayCallback (grid, @message$, v0, v1, v2, v3, kid, @r1$)
  END SELECT
END SUB
'
' XuiScrollBarH messages
'
SUB ScrollBarH
  text$ = ""
  text$ = text$ + "XuiScrollBarH"
  text$ = text$ + "\n    grid = " + HEX$ (grid, 8)
  text$ = text$ + "\n message = " + message$
  text$ = text$ + "\n  lowest = " + HEX$ (v0)
  text$ = text$ + "\n     low = " + HEX$ (v1)
  text$ = text$ + "\n    high = " + HEX$ (v2)
  text$ = text$ + "\n highest = " + HEX$ (v3)
  text$ = text$ + "\n     kid = " + HEX$ (kid)
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