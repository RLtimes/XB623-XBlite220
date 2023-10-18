'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program uses GetTimeFormatA to create a
' formatted time string. It demonstrates the process
' of calling API functions. This API function is in the
' "kernel32" library, which means it needs to be imported
' by using the IMPORT statement in the PROLOG.
' See the IMPORT statements below. 
'
' In order to use the function it must be declared
' in the kernel32.dec declaration file.
'
PROGRAM "api"
VERSION "0.0002"
CONSOLE

'IMPORT  "xst"
'IMPORT  "xst_s.lib"
IMPORT	"kernel32"	' Import kernel32.dll API library
'
DECLARE  FUNCTION  Entry       ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

  SYSTEMTIME sysTime
	
' get local time
  GetLocalTime (&sysTime)
  
' set parameters for GetTimeFormatA
  timeStr$ = NULL$ (100)
  flags = 0
  format$ = ""
  GetTimeFormatA ($$LOCALE_USER_DEFAULT, flags, &sysTime, &format$, &timeStr$, LEN(timeStr$))
  timeStr$ = CSIZE$ (timeStr$)
  PRINT "Default local time format:", timeStr$
  
' use a time format string
  timeStr$ = NULL$ (100)
  flags = 0
  format$ = "hh\':\'mm\':\'ss tt"   ' use escape backslash before :
  GetTimeFormatA ($$LOCALE_USER_DEFAULT, flags, &sysTime, &format$, &timeStr$, LEN(timeStr$))
  timeStr$ = CSIZE$ (timeStr$)
  PRINT "Use time format string   :", timeStr$
  
' use a time format string
  timeStr$ = NULL$ (100)
  flags = 0
  format$ = "HH\'h\'mm"
  GetTimeFormatA ($$LOCALE_USER_DEFAULT, flags, &sysTime, &format$, &timeStr$, LEN(timeStr$))
  timeStr$ = CSIZE$ (timeStr$)
  PRINT "Use time format string   :", timeStr$
  
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM
