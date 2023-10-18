'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Get the version number for comctl32.dll.
'
PROGRAM	"comctlversion"
VERSION	"0.0002"
CONSOLE
'
	IMPORT	"xst"
	IMPORT	"gdi32"
	IMPORT  "kernel32"
	IMPORT  "comctl32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  ComCtl32Version (@major, @minor, @build)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

	DLLVERSIONINFO dvi

	ComCtl32Version (@major, @minor, @build)
	PRINT " ***** Common Controls comctl32.dll Version *****"
	PRINT "ComCtl32Version ()"
	PRINT "Major : "; major
	PRINT "Minor : "; minor
	PRINT "Build : "; build
	PRINT

	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
'
'
' ################################
' #####  ComCtl32Version ()  #####
' ################################
'
FUNCTION  ComCtl32Version (@major, @minor, @build)

	DLLVERSIONINFO dvi
	STATIC FUNCADDR DllGetVersion (XLONG)

	hMod = LoadLibraryA (&"comctl32.dll")
	IFZ hMod THEN RETURN

' You must get this function explicitly because
' earlier versions of the DLL don't implement this
' function. That makes the lack of implementation
' of the function a version marker in itself.

	DllGetVersion = GetProcAddress (hMod, &"DllGetVersion")
	IF DllGetVersion THEN
		dvi.cbSize = SIZE(DLLVERSIONINFO)
		ret = @DllGetVersion (&dvi)
		IFZ ret THEN
			major = dvi.dwMajor
			minor = dvi.dwMinor
			build = dvi.dwBuildNumber
		END IF
	ELSE
'If GetProcAddress failed, then the DLL is a version previous
' to the one shipped with IE 3.x.
		major = 4
	END IF

	FreeLibrary (hMod)
	RETURN $$TRUE


END FUNCTION
END PROGRAM
