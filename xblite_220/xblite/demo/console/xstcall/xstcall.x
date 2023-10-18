'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo for using possible new Xst function
' XstCall which can be used to make a computed
' function call to any library function.
'
PROGRAM "xstcall"
VERSION "0.0002"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
	IMPORT  "xsx"				' Extended standard library

DECLARE FUNCTION Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	ret = XstCall ("GetCaretBlinkTime", "user32.dll", @args[])
	PRINT "XstCall: 0 args: GetCaretBlinkTime ret:"; ret

	DIM args[0]
	rootPath$ = "c:\\" 
	args[0] = &rootPath$ 
	ret = XstCall ("GetDriveType", "kernel32.dll", @args[])
	PRINT "XstCall: 1 args: GetDriveType ret:"; ret
	
	DIM args[1]
	args[0] = 255
	buf$ = NULL$(255)
	args[1] = &buf$
	ret = XstCall ("GetCurrentDirectory", "kernel32.dll", @args[])
	PRINT "XstCall: 2 args: GetCurrentDirectory ret:"; ret; " "; LEFT$(buf$, ret)
	
	DIM args[2]
	args[0] = 0
	fn$ = NULL$(255)
	args[1] = &fn$
	args[2] = LEN(fn$)
	ret = XstCall ("GetModuleFileName", "kernel32.dll", @args[])
	PRINT "XstCall: 3 args: GetModuleFileName ret="; ret; " "; LEFT$(fn$, ret)
	
	DIM args[3]
	args[0] = &"xstcall.exe"
	path$ = NULL$(255)	
	args[1] = LEN(path$)
	args[2] = &path$
	lpFilePart = 0
	args[3] = &lpFilePart
	ret = XstCall ("GetFullPathName", "kernel32", @args[])
	PRINT "XstCall  : 4 args: GetFullPathName ret:"; ret
	PRINT "path     : "; LEFT$(path$, ret) 
	PRINT "filename : "; CSTRING$(lpFilePart)
	
	
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

END PROGRAM