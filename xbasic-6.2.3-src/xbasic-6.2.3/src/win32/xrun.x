'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  Windows XBasic executable support
'
' subject to LGPL license - see COPYING_LIB
'
' maxreason@maxreason.com
'
' for Windows XBasic
'
PROGRAM	"xrun"
VERSION	"0.0038"
'
IMPORT	"xst"
IMPORT	"xin"
IMPORT	"xma"
IMPORT	"xcm"
IMPORT	"xgr"
IMPORT	"xui"
IMPORT	"kernel32"
IMPORT	"xut"
'
'
DECLARE FUNCTION  Xit                      (argc, argv, envp)
DECLARE FUNCTION  XitMain                  (sigNumber, sigSource)
INTERNAL FUNCTION  InitProgram              ()
'
' These empty functions need to be in here because they're
' called by xst.x and/or xui.x
'
DECLARE FUNCTION  XitGetDECLARE            (func$, declare$)		' called by xui.x
DECLARE FUNCTION  XitGetDisplayedFunction  (func$)							' called by xui.x
DECLARE FUNCTION  XitGetFunction           (func$, text$[])			' called by xui.x
DECLARE FUNCTION  XitQueryFunction         (func$, exists)			' called by xui.x
DECLARE FUNCTION  XitSetDECLARE            (func$, declare$)		' called by xui.x
DECLARE FUNCTION  XitSetDisplayedFunction  (func$)							' called by xui.x
DECLARE FUNCTION  XitSetFunction           (func$, text$[])			' called by xui.x
DECLARE FUNCTION  XitSoftBreak             ()										' called by xui.x
DECLARE FUNCTION  XxxGetLabelGivenAddress  (address, label$[])	' called by xui.x
DECLARE FUNCTION  XxxXitGetUserProgramName (file$)							' called by xui.x
DECLARE FUNCTION  XxxSetBlowback           ()										' called by xst.x
'
EXTERNAL FUNCTION  XxxStartApplication      ()									' in application
EXTERNAL FUNCTION  XxxSetExceptions         (exception, osexception)	' in xlib.s
EXTERNAL FUNCTION  Xio						          ()
'
'
' ####################
' #####  Xit ()  #####  Entry Function
' ####################
'
FUNCTION  Xit (argc, argv, envp)
	STATIC  firstEntry
'
	a$ = "Max Reason"
	a$ = "copyright 1988-2000"
	a$ = "XBasic executable support"
	a$ = "maxreason@maxreason.com"
	a$ = ""
'
	IFZ firstEntry THEN
		firstEntry = $$TRUE
		' Note: Win32 is currently the only OS supported by this source.
		##XBSystem = $$XBSysWin32
		InitProgram ()
		Xst ()
		Xio()
		XutInit()
		Xin ()
		Xma ()
		Xcm ()
		Xgr ()
		Xui ()
	END IF
'
	error = XitMain (0, 0)
	RETURN (error)
END FUNCTION
'
'
' #####################
' #####  XitMain  #####  Called on program startup and all signals
' #####################
'
FUNCTION  XitMain (sigNumber, sigSource)
	FUNCADDR	func()
'
' *****  Start Program  *****
'
	IFZ sigNumber THEN
		##ENTERED = $$FALSE
		func = ##APP
		error = @func ()
'		error = XxxStartApplication ()
		RETURN (error)
	END IF
'
' *****  Process Exception  *****
'
	XstSystemExceptionToException (sigNumber, @exception)
	XstExceptionNumberToName (exception, @exception$)
	XstGetExceptionFunction (@response)
	PRINT "XitMain(): exception$, exception, response = "; exception$, exception, HEX$(response, 8)
	XxxSetExceptions (exception, sigNumber)
'	##OSEXCEPTION = sigNumber
'	##EXCEPTION = exception
'
	DO
		SELECT CASE response
			CASE $$ExceptionContinue	: RETURN ($$EXCEPTION_CONTINUE_EXECUTION)
			CASE $$ExceptionTerminate	: RETURN ($$EXCEPTION_CONTINUE_SEARCH)
			CASE ELSE									: func = response
																	response = @func()
		END SELECT
	LOOP
END FUNCTION
'
'
'
'
' #########################
' #####  InitProgram  #####
' #########################
'
FUNCTION  InitProgram ()
'
END FUNCTION
'
'
' ##############################
' #####  XitGetDECLARE ()  #####
' ##############################
'
FUNCTION  XitGetDECLARE (func$, declare$)
'
' This function in xitwin.x is called by xui.x
'
END FUNCTION
'
'
' ########################################
' #####  XitGetDisplayedFunction ()  #####
' ########################################
'
FUNCTION  XitGetDisplayedFunction (func$)
'
' This function in xitwin.x is called by xui.x
'
END FUNCTION
'
'
' ###############################
' #####  XitGetFunction ()  #####
' ###############################
'
FUNCTION  XitGetFunction (func$, text$[])
'
' This function in xitwin.x is called by xui.x
'
END FUNCTION
'
'
' #################################
' #####  XitQueryFunction ()  #####
' #################################
'
FUNCTION  XitQueryFunction (func$, exists)
'
' This function in xitwin.x is called by xui.x
'
END FUNCTION
'
'
' ##############################
' #####  XitSetDECLARE ()  #####
' ##############################
'
FUNCTION  XitSetDECLARE (func$, declare$)
'
' This function in xitwin.x is called by xui.x
'
END FUNCTION
'
'
' ########################################
' #####  XitSetDisplayedFunction ()  #####
' ########################################
'
FUNCTION  XitSetDisplayedFunction (func$)
'
' This function in xitwin.x is called by xui.x
'
END FUNCTION
'
'
' ###############################
' #####  XitSetFunction ()  #####
' ###############################
'
FUNCTION  XitSetFunction (func$, text$[])
'
' This function in xitwin.x is called by xui.x
'
END FUNCTION
'
'
' #############################
' #####  XitSoftBreak ()  #####
' #############################
'
FUNCTION  XitSoftBreak ()
	RaiseException ($$EXCEPTION_CONTROL_C_EXIT, 0, 0, 0)
END FUNCTION
'
'
' #########################################
' #####  XxxXitGetUserProgramName ()  #####
' #########################################
'
FUNCTION  XxxXitGetUserProgramName (file$)
'
	XstGetCommandLineArguments (@argc, @argv$[])
	IF argc THEN
		IF argv$[] THEN
			IF argv$[0] THEN
				file$ = argv$[0]
			END IF
		END IF
	END IF
END FUNCTION
'
'
' ########################################
' #####  XxxGetLabelGivenAddress ()  #####
' ########################################
'
FUNCTION  XxxGetLabelGivenAddress (address, label$[])
'
' This function in xnt.x is called by xui.x
'
END FUNCTION
'
'
' ###############################
' #####  XxxSetBlowback ()  #####
' ###############################
'
FUNCTION  XxxSetBlowback ()
'
' This function in xitwin.x is called by xst.x
'
END FUNCTION
END PROGRAM
