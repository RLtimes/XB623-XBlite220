'
'	Sets the transperancy level of any GDI window
'
'
'	Michael McElligott
'	Mapei_@hotmail.com
'	25/11/2003
'
'
'	usage:
'	alpha.exe -t WindowTitle -a AlphaValue
'	WindowTitle need not contain the complete title.
'
'	or
'	find the handle of the window (hWnd):
'	alpha.exe -L
'	this will display a two column list of all GDI windows.
'	look for your window title then and note its hWnd to the left
'	alpha.exe -w hWnd -a AlphaValue
'	
'	setting AlphaValue to 100 resets and removes transperancy.
'
'	eg, alpha.exe -t Ultra -a 70
'	this will set all UltraEdit-32 windows (infact any window beginning with 'Ultra')
'	to 30 percent trans
'
'
PROGRAM "alpha"
'MAKEFILE "xexe.xxx"
CONSOLE

	IMPORT "gdi32.dec"
	IMPORT "user32"
	IMPORT "kernel32"

$$WS_EX_LAYERED = 0x80000	' user32.dec
$$LWA_ALPHA = 0x00000002	' user32.dec

DECLARE FUNCTION Entry ()
DECLARE FUNCTION GetCommandLine (pid,wnd,alpha,STRING window,vbose,list)
DECLARE FUNCTION GetCommandLineArguments (argc, argv$[])
DECLARE FUNCTION CPrint (string$)
DECLARE FUNCTION PrintHelp ()



FUNCTION Entry ()
	FUNCADDR SLWA (ULONG, XLONG, UBYTE, XLONG)
	SHARED vbose
	STRING title,class,window
	ULONG wnd,hwnd


	GetCommandLine (@pid,@wnd,@alpha,@window,@vbose,@list)
	IFT list THEN
		vbose = $$TRUE
		wnd = 0
		'pid = 0
	ELSE
		IFZ (wnd || &window) THEN RETURN $$FALSE
		IF window THEN wnd = 0
		
        hlib = LoadLibraryA (&"user32.dll")
		IFZ hlib THEN RETURN $$FALSE
		
		SLWA = GetProcAddress (hlib, &"SetLayeredWindowAttributes")
		IFZ SLWA THEN
			IF hlib THEN FreeLibrary (hlib) 
			PRINT "Windows 2000 or later required"
			RETURN $$FALSE
		END IF
	END IF

	found = $$FALSE
	hwnd = FindWindowA(0,0)
	
	CPrint ("hWnd\t Window title")
	
	DO WHILE (hwnd <> 0)
 		IF GetParent(hwnd) = 0 THEN
 		
 			len = GetWindowTextLengthA (hwnd) + 1
			title = SPACE$(len)
			GetWindowTextA (hwnd, &title,len)
 			title = CSTRING$(&title)
			'tid = GetWindowThreadProcessId(hwnd, &test_pid)
			' could also use process id as a switch
			class = NULL$(64)
			GetClassNameA (hwnd,&class, 63)
			class = LEFT$ (TRIM$(class),63)
			title = LEFT$ (TRIM$(title),79)
			
			IFZ title THEN
				CPrint (STRING$(hwnd)+"\t "+class)
			ELSE
				CPrint (STRING$(hwnd)+"\t "+title)
			END IF

			ttitle$ = LEFT$(title,LEN(window))
			tclass$ = LEFT$(class,LEN(window))
			
     		IF (hwnd == wnd) || (((window == ttitle$) || (window == tclass$)) && window != "") THEN
				IF alpha == 100 THEN		' reset
					SetWindowLongA (hwnd, $$GWL_EXSTYLE, GetWindowLongA (hwnd, $$GWL_EXSTYLE) & ~$$WS_EX_LAYERED)'  | $$WS_EX_TRANSPARENT )
					RedrawWindow(hwnd, NULL, NULL, $$RDW_ERASE | $$RDW_INVALIDATE | $$RDW_FRAME | $$RDW_ALLCHILDREN)
       			ELSE						' set new alpha value
       				SetWindowLongA (hwnd, $$GWL_EXSTYLE, GetWindowLongA (hwnd, $$GWL_EXSTYLE) | $$WS_EX_LAYERED)
					@SLWA (hwnd, 0, (255 * alpha) / 100 , $$LWA_ALPHA)
					RedrawWindow(hwnd, NULL, NULL, $$RDW_ERASE | $$RDW_INVALIDATE | $$RDW_FRAME | $$RDW_ALLCHILDREN)
       			END IF
				found = $$TRUE
     		END IF
     		
  		END IF
  		hwnd = GetWindow(hwnd, $$GW_HWNDNEXT)
  		
 	LOOP WHILE (found == $$FALSE)
 	
 	IFF list THEN
		IFF found THEN
			vbose = $$TRUE
    		CPrint ("window not found: "+STRING$(hwnd))
    	ELSE
	    	CPrint ("window found: "+STRING$(hwnd)+" "+STRING$(test_pid)+" "+LEFT$ (title,79))
		END IF
	END IF

	IF hlib THEN FreeLibrary (hlib) 	
 	
 	RETURN
END FUNCTION

FUNCTION GetCommandLine (pid,wnd,alpha,STRING window,vbose,list)


	GetCommandLineArguments (@argc, @argv$[])

	pid = 0				' set default values
	wnd = 0
	alpha = 100
	vbose = $$FALSE
	list = $$FALSE
	window = ""
	
	IF (argc > 1) THEN
		FOR i = 1 TO argc-1														' for all command line arguments
			arg$ = TRIM$(argv$[i])											' get next argument
			IF (LEN (arg$) = 2) THEN										' if not empty
				IF (arg${0} = '-') THEN										' command line switch?
					SELECT CASE arg${1}											' which switch?
	'					CASE 'p','P'	:pid = XLONG (TRIM$(argv$[i+1]))
						CASE 'w','W'	:wnd = XLONG (TRIM$(argv$[i+1]))
						CASE 't','T'	:window = TRIM$(argv$[i+1])
						CASE 'f','F'	:Sleep (3000)
										 wnd = GetForegroundWindow ()
						CASE 'a','A'	:alpha = XLONG (TRIM$(argv$[i+1]))
										 IF alpha < 0 THEN
										 	alpha = 0
										 ELSE
										 	IF alpha > 100 THEN alpha = 100
										 END IF
						CASE 'v','V'			: vbose = $$TRUE
						CASE 'h','H','?'	: PrintHelp (): QUIT (0)
						CASE 'l','L'			: list = $$TRUE
					END SELECT
				END IF
			END IF
		NEXT i
	ELSE
		PrintHelp () : QUIT (0)
	END IF

	RETURN $$TRUE
END FUNCTION


FUNCTION PrintHelp ()
	SHARED vbose
	
	
	vbose = $$TRUE

	CPrint ("  Set Window Transperancy\n    by Michael McElligott")
	CPrint ("\nUsage: alpha -w -t -f -a -l -v -h")
	CPrint (" -w hWnd  Handle to a Win32 GDI window")
	CPrint (" -t title Window title")
	CPrint (" -f       Select foreground window")
'	CPrint (" -s sec   Seconds to wait before acquiring foreground window")
	CPrint (" -a alpha Transperancy level from 0 to 100")
	CPrint (" -l       List all windows")
	CPrint (" -v       Verbose display")
	CPrint (" -h       Display this page")
	
END FUNCTION

FUNCTION CPrint (string$)
	SHARED vbose

	IFT vbose THEN PRINT string$
	RETURN $$TRUE
	
END FUNCTION

FUNCTION GetCommandLineArguments (argc, argv$[]) ' taken from the Xst lib
	SHARED  setarg
	SHARED  setargc
	SHARED  setargv$[]


	DIM argv$[]
	inc = argc
	argc = 0
'
' return already set argc and argv$[]
'
	IF (inc >= 0) THEN
		IF setarg THEN
			argc = setargc
			upper = UBOUND (setargv$[])
			ucount = upper + 1
			IF (argc > ucount) THEN argc = ucount
			IF argc THEN
				DIM argv$[upper]
				FOR i = 0 TO upper
					argv$[i] = setargv$[i]
				NEXT i
			END IF
			RETURN ($$FALSE)
		END IF
	END IF
'
' get original command line arguments from system
'
	argc = 0
	index = 0
	DIM argv$[]
	addr = GetCommandLineA()			' address of full command line
	line$ = CSTRING$(addr)
	
'	PRINT "cmd line",line$
'
	done = 0
	IF addr THEN
		DIM argv$[1023]
		quote = $$FALSE
		argc = 0
		empty = $$FALSE
		I = 0
		DO
			cha = UBYTEAT(addr, I)
			IF (cha < ' ') THEN EXIT DO

			IF (cha = ' ') AND NOT quote THEN
				IF NOT empty THEN
					INC argc
					argv$[argc] = ""
					empty = $$TRUE
				END IF
			ELSE
				IF (cha = '"') THEN
					quote = NOT quote
				ELSE
					argv$[argc] = argv$[argc] + CHR$(cha)
					empty = $$FALSE
				END IF
			END IF
			INC I
		LOOP
		IF NOT empty THEN
			argc = argc + 1
		END IF
		REDIM argv$[argc-1]

	END IF
'
' if input argc < 0 THEN don't overwrite current values
'
	IF ((setarg = $$FALSE) OR (inc >= 0)) THEN
		setarg = $$TRUE
		setargc = argc
		DIM setargv$[]
		IF (argc > 0) THEN
			DIM setargv$[argc-1]
			FOR i = 0 TO argc-1
				setargv$[i] = argv$[i]
			NEXT i
		END IF
	END IF
	
END FUNCTION


END PROGRAM