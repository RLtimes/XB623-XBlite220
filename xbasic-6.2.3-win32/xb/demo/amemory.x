'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"nuke"
VERSION	"0.0001"
'
IMPORT  "xst"
IMPORT  "xcm"
IMPORT  "xma"
IMPORT  "xin"
IMPORT  "xgr"
IMPORT  "xui"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  MemoryMap (@mem$)
EXTERNAL FUNCTION  XxxGetFrameAddr ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()
'
	PRINT
	PRINT "########################################"
	PRINT HEX$(##START,8); " = &WinMain() = application base"
	PRINT HEX$(##MAIN,8); " = &XxxMain() = libraries base"
	PRINT HEX$(&Xst(),8); " = &Xst()"
	PRINT HEX$(&Xin(),8); " = &Xin()"
	PRINT HEX$(&Xma(),8); " = &Xma()"
	PRINT HEX$(&Xcm(),8); " = &Xcm()"
	PRINT HEX$(&Xgr(),8); " = &Xgr()"
	PRINT HEX$(&Xui(),8); " = &Xui()"
	PRINT
'
	MemoryMap (@memory$)
	PRINT memory$
'
	PRINT "######################################################"
	PRINT
END FUNCTION
'
'
' ##########################
' #####  MemoryMap ()  #####
' ##########################
'
FUNCTION  MemoryMap (@memory$)
'
	##STACK = XxxGetFrameAddr()
	##STACK0 = ##STACK AND 0xFFFFF000
'
	m1$ = "SECTION   PAGE BASE   LOW ADDR    HIGH ADDR   NEXT PAGE\n"
	m2$ = "  CODE    " + HEX$(##CODE0, 8)  + "    " + HEX$(##CODE, 8)  + "    " + HEX$(##CODEX, 8)  + "    " + HEX$(##CODEZ, 8) + "\n"
	m3$ = "   BSS    " + HEX$(##BSS0, 8)   + "    " + HEX$(##BSS, 8)   + "    " + HEX$(##BSSX, 8)   + "    " + HEX$(##BSSZ, 8)   + "\n"
	m4$ = "  DATA    " + HEX$(##DATA0, 8)  + "    " + HEX$(##DATA, 8)  + "    " + HEX$(##DATAX, 8)  + "    " + HEX$(##DATAZ, 8) + "\n"
	m5$ = "  DYNO    " + HEX$(##DYNO0, 8)  + "    " + HEX$(##DYNO, 8)  + "    " + HEX$(##DYNOX, 8)  + "    " + HEX$(##DYNOZ, 8) + "\n"
	m6$ = " UCODE    " + HEX$(##UCODE0, 8) + "    " + HEX$(##UCODE, 8) + "    " + HEX$(##UCODEX, 8) + "    " + HEX$(##UCODEZ, 8) + "\n"
	m7$ = " STACK    " + HEX$(##STACK0, 8) + "    " + HEX$(##STACK, 8) + "    " + HEX$(##STACKX, 8) + "    " + HEX$(##STACKZ, 8)
	memory$ = m1$ + m2$ + m3$ + m4$ + m5$ + m6$ + m7$
END FUNCTION
END PROGRAM
