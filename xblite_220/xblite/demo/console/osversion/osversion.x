'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Updated versions of XstGetOSVersion ()
' XstOSName () functions for new windows
' versions. These have been implemented in Xsx.
'
PROGRAM	"osversion"
VERSION	"0.0002"
CONSOLE
'
	IMPORT  "xsx"
	IMPORT	"xst"
	IMPORT  "kernel32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  OSName (@name$)
DECLARE FUNCTION  OSVersion (@major, @minor, @platformId, @version$, @platform$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

'test new functions in xsx.dll
	XstGetOSName (@name$)
	XstGetOSVersion (@major, @minor, @platformId, @version$, @platform$)

	PRINT "OS Name               : "; name$
	PRINT "OS Version Major      : "; major
	PRINT "OS Version Minor      : "; minor
	PRINT "OS Version platformId : "; platformId
	PRINT "OS Version Name       : "; version$
	PRINT "OS Platform Name      : "; platform$
	PRINT

' new functions
	OSName (@osname$)
	PRINT "OS Name               : "; osname$
	major = 0 : minor = 0
	OSVersion (@major, @minor, @platformId, @version$, @platform$)
	PRINT "OS Version Major      : "; major
	PRINT "OS Version Minor      : "; minor
	PRINT "OS Version platformId : "; platformId
	PRINT "OS Version Name       : "; version$
	PRINT "OS Platform Name      : "; platform$

	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
'
'
' #######################
' #####  OSName ()  #####
' #######################
'
FUNCTION  OSName (name$)
'
	SHARED OSVERSIONINFO os
'
	os.dwOSVersionInfoSize = SIZE(OSVERSIONINFO)
'
	IF GetVersionExA(&os) THEN
		csdVersion = XLONG(TRIM$(os.szCSDVersion))
  	SELECT CASE os.dwPlatformId
'
			CASE 1 :
				IF os.dwMinorVersion = 0  THEN
					IF csdVersion <> 66 && csdVersion <> 67 THEN name$ = "Windows 95"
					IF csdVersion = 66 || csdVersion = 67 THEN name$ = "Windows 95 OSR2"
				END IF
'
				IF os.dwMinorVersion = 10 THEN
					IF csdVersion = 65 THEN name$ = "Windows 98 Second Edition"
					IF csdVersion <> 65 THEN name$ = "Windows 98"
				END IF
'
				IF os.dwMinorVersion = 90 THEN name$ = "Windows Millennium"
'
			CASE 2 :   											'  Windows NT 3.51
				IF os.dwMajorVersion = 3 THEN name$ = "Windows NT 3.51"
				IF os.dwMajorVersion = 4 THEN name$ = "Windows NT 4.0"

				IF os.dwMajorVersion = 5 THEN
					IF os.dwMinorVersion = 0 THEN name$ = "Windows 2000"
					IF os.dwMinorVersion = 1 THEN name$ = "Windows XP"
				END IF
		END SELECT
		RETURN $$TRUE
	END IF
	RETURN $$FALSE

END FUNCTION
'
'
' ##########################
' #####  OSVersion ()  #####
' ##########################
'
FUNCTION  OSVersion (major, minor, platformId, version$, platform$)
'
	SHARED OSVERSIONINFO os
	IF OSName (@name$) THEN
		major = os.dwMajorVersion
		minor = os.dwMinorVersion
		platformId = os.dwPlatformId
		version$ = STRING$(major) + "." + STRING$(minor)
		SELECT CASE platformId
			CASE 0: platform$ = "Win32s"
			CASE 1: platform$ = "Windows"
			CASE 2: platform$ = "NT"
		END SELECT
		RETURN $$TRUE
	END IF
	RETURN 0

END FUNCTION
END PROGRAM
