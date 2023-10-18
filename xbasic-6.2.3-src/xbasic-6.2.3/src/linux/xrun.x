'
'
'  ####################  Max Reason
'  #####  PROLOG  #####  copyright 1988-2000
'  ####################  Linux XBasic executable support
'
' subject to LGPL license - see COPYING_LIB
'
' maxreason@maxreason.com
'
' for Linux XBasic
'
'
PROGRAM	"xrun"
VERSION	"0.0047"
'
IMPORT	"xst"
IMPORT	"xin"
IMPORT	"xma"
IMPORT	"xcm"
IMPORT	"xgr"
IMPORT	"xui"
IMPORT	"clib"
IMPORT	"kernel32"
IMPORT	"xut"
'
'
DECLARE FUNCTION  XxxXit                    (argc, argv, envp)
DECLARE CFUNCTION  XxxXitMain               (sigNumber)
INTERNAL FUNCTION  EstablishSignals         ()
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
DECLARE FUNCTION  XxxXitExit               (status)							' called by xst.x
'
EXTERNAL FUNCTION  XxxStartApplication      ()									' in application
EXTERNAL FUNCTION  XxxSetExceptions         (exception, osexception)	' in xlib.s
EXTERNAL FUNCTION	Xio												()
EXTERNAL FUNCTION  XxxXstTimer                (command, timer, count, msec, func)
'
'
'
' timer command arguments to XxxXstTimer()
'
	$$TimerStart					= 1
	$$TimerExpire					= 2
	$$TimerKill						= 3
'
'
' #######################
' #####  XxxXit ()  #####  Entry Function
' #######################
'
FUNCTION  XxxXit (argc, argv, envp)
	STATIC  firstEntry
'
	a$ = "Max Reason"
	a$ = "copyright 1988-2000"
	a$ = "Linux XBasic executable support"
	a$ = "maxreason@maxreason.com"
	a$ = ""
'
	IFZ firstEntry THEN
		firstEntry = $$TRUE
		' Note: Linux is currently the only OS supported by this source.
		##XBSystem = $$XBSysLinux
		InitProgram ()
		Xst ()
		XutInit ()
		Xio	()
		Xin ()
		Xma ()
		Xcm ()
		Xgr ()
		Xui ()
	END IF
'
	error = XxxXitMain (0)
	RETURN (error)
END FUNCTION
'
'
' ########################
' #####  XxxXitMain  #####  Called on program startup and all signals
' ########################
'
CFUNCTION  XxxXitMain (sigNumber)
	FUNCADDR	func()
'
' *****  start program  *****
'
	IFZ sigNumber THEN
		EstablishSignals ()
		error = XxxStartApplication ()
		RETURN (error)
	END IF
'
' *****  Process Exception  *****
'
	IF ##INEXIT THEN exit (0)
	XstSystemExceptionToException (sigNumber, @exception)
	SELECT CASE exception
		CASE $$ExceptionTimer
			XxxXstTimer ($$TimerExpire, 0, 0, 0, 0)
			RETURN ($$FALSE)
	END SELECT
	XstExceptionNumberToName (exception, @exception$)
	XstGetExceptionFunction (@response)
	XxxSetExceptions (exception, sigNumber)
	log$ = PROGRAM$(0)
	log$ = " : XitMain() : exception$, exception, response = "
	log$ = log$ +  exception$ + " " + STRING$(exception) + " " + HEXX$(response,8)
	XstLog (@log$)
'
	IF ##INEXIT THEN exit(0)
'
	DO
		SELECT CASE response
			CASE $$ExceptionContinue	: RETURN ($$FALSE)
			CASE $$ExceptionTerminate	: RETURN ($$TRUE)
			CASE ELSE									: func = response
																	response = @func()
		END SELECT
	LOOP
END FUNCTION
'
'
' #################################
' #####  EstablishSignals ()  #####
' #################################
'
FUNCTION  EstablishSignals ()
	USIGACTION	sig
'
	mask = 0x00000000
	mask = mask OR $$SIGMASK_HUP
'	mask = mask OR $$SIGMASK_INT
'	mask = mask OR $$SIGMASK_QUIT
	mask = mask OR $$SIGMASK_ILL			' later comment this one out !!!
	mask = mask OR $$SIGMASK_TRAP			' mask $$SIGILL out now because
'	mask = mask OR $$SIGMASK_ABRT			' $$SIGILL is occuring right after
	mask = mask OR $$SIGMASK_IOT			' entry into the XxxXitMain()
	mask = mask OR $$SIGMASK_BUS
	mask = mask OR $$SIGMASK_FPE			' screws up the frame information.
	mask = mask OR $$SIGMASK_KILL
	mask = mask OR $$SIGMASK_USR1
	mask = mask OR $$SIGMASK_SEGV
	mask = mask OR $$SIGMASK_USR2
	mask = mask OR $$SIGMASK_PIPE
	mask = mask OR $$SIGMASK_ALRM
	mask = mask OR $$SIGMASK_TERM
	mask = mask OR $$SIGMASK_STKFLT
	mask = mask OR $$SIGMASK_CHLD
	mask = mask OR $$SIGMASK_CONT
	mask = mask OR $$SIGMASK_STOP
	mask = mask OR $$SIGMASK_TSTP
	mask = mask OR $$SIGMASK_TTIN
	mask = mask OR $$SIGMASK_TTOU
	mask = mask OR $$SIGMASK_URG
	mask = mask OR $$SIGMASK_XCPU
	mask = mask OR $$SIGMASK_XFSZ
	mask = mask OR $$SIGMASK_VTALRM
	mask = mask OR $$SIGMASK_WINCH
	mask = mask OR $$SIGMASK_IO
	mask = mask OR $$SIGMASK_POLL
	mask = mask OR $$SIGMASK_PWR
	mask = mask OR $$SIGMASK_UNUSED
	mask = mask OR $$SIGMASK_MAX
'
	sig.sa_handler = &XxxXitMain()	' signal catching function
	sig.sa_mask = mask							' block all signals upon signal catch
	sig.sa_flags = 0								' nothing special
'
	e = xb_sigaction ($$SIGINT, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGINT"
	e = xb_sigaction ($$SIGQUIT, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGQUIT"
	e = xb_sigaction ($$SIGILL, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGILL"
	e = xb_sigaction ($$SIGTRAP, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGTRAP"
	e = xb_sigaction ($$SIGABRT, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGABRT"
	e = xb_sigaction ($$SIGFPE, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGFPE"
	e = xb_sigaction ($$SIGBUS, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGBUS"
	e = xb_sigaction ($$SIGSEGV, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGSEGV"
	e = xb_sigaction ($$SIGALRM, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGALRM"
	e = xb_sigaction ($$SIGTERM, &sig, 0)		: IF (e < 0) THEN PRINT "$$SIGTERM"
	e = xb_sigaction ($$SIGVTALRM, &sig, 0)	: IF (e < 0) THEN PRINT "$$SIGVTALRM"
END FUNCTION
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
' This function in xit.x is called by xui.x
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
' This function in xit.x is called by xui.x
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
' This function in xit.x is called by xui.x
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
' This function in xit.x is called by xui.x
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
' This function in xit.x is called by xui.x
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
' This function in xit.x is called by xui.x
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
' This function in xit.x is called by xui.x
'
END FUNCTION
'
'
' #############################
' #####  XitSoftBreak ()  #####
' #############################
'
FUNCTION  XitSoftBreak ()
'
	pid = getpid ()
	kill (pid, $$ExceptionBreakKey)
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
' This function in xit.x is called by xst.x
'
END FUNCTION
'
'
' ###########################
' #####  XxxXitExit ()  #####  This function in xit.x is called by xst.x
' ###########################
'
FUNCTION  XxxXitExit (status)
'
	##INEXIT = $$TRUE
	exit (status)
END FUNCTION
END PROGRAM
