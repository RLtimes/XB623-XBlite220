'
' This program using functions in wininet.dll
' to download any type of internet file from
' a source URL address.
'
' modified from the original geturl.x by DS.
'
' URL_GetFile() has been recoded to remove the need for string
' concatenation of the input buffer, drastically improving performance.
'
PROGRAM	"geturl"
VERSION	"0.0002"
CONSOLE

IMPORT "kernel32"
IMPORT "msvcrt"

$$INTERNET_FLAG_RELOAD = 0x80000000
$$INTERNET_OPEN_TYPE_PRECONFIG = 0
$$INTERNET_FLAG_EXISTING_CONNECT = 0x20000000

PACKED TBUFFER
	XLONG .size
	UBYTE	.buffer[65530]
END TYPE

DECLARE FUNCTION Entry ()

DECLARE FUNCTION URL_GetFile (STRING URL, TBUFFER buff[])
DECLARE FUNCTION URL_SaveFile (STRING filename, TBUFFER buff[])

DECLARE FUNCTION open_file (lpfilename, flags)
DECLARE FUNCTION close_file (file)
DECLARE FUNCTION write_file (hfile, ULONG buffer, nbytes)


FUNCTION Entry ()

	TBUFFER fbuff[]
	
	IF LIBRARY(0) THEN RETURN
	
	' 45meg ATI graphics demo.
	'f$ = "http://www2.ati.com/misc/demos/ati-radeon-x850-dangerouscurves-movie-v1.0.mpg"
		
	' 4.6 meg tif image from the Cassini probe
	f$ = "http://photojournal.jpl.nasa.gov/tiff/PIA06141.tif"
	save$ = "PIA06141.tif"
	
	PRINT "Downloading "; f$
	start = GetTickCount ()

	IF URL_GetFile (f$, @fbuff[]) THEN
		' downloaded ok
		IF URL_SaveFile (save$, @fbuff[]) THEN
			' downloaded and saved ok.
			time# = (GetTickCount() - start)/1000.0
			PRINT "Downloaded and saved "; save$
	    PRINT "Download time (sec):"; time#
		ELSE
			' unable to save
		  PRINT "URL_SaveFile Error"
		END IF
	ELSE
		' unable to download
	  PRINT "URL_GetFile Error"
	END IF

	a$ = INLINE$ ("Press any key to quit")

	RETURN 1
END FUNCTION


FUNCTION URL_SaveFile (STRING filename, TBUFFER buff[])

	hfile = open_file (&filename, &"wb")
	IFZ hfile THEN RETURN 0
	
	FOR i = 0 TO UBOUND(buff[])
		IF buff[i].size THEN
			write_file (hfile, &buff[i].buffer[0], buff[i].size)
		ELSE
			EXIT FOR
		END IF
	NEXT i

	close_file (hfile)
	RETURN 1
END FUNCTION

FUNCTION URL_GetFile (STRING URL, TBUFFER buff[])

	FUNCADDR Open (XLONG, XLONG, XLONG, XLONG, XLONG)
	FUNCADDR OpenUrl (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
	FUNCADDR ReadFile (XLONG, XLONG, XLONG, XLONG)
	FUNCADDR CloseHandle (XLONG)
	STRING null

	IFZ URL THEN RETURN 0

	hWininetDll = LoadLibraryA (&"wininet.dll")
	IFZ hWininetDll THEN RETURN 0

	Open = GetProcAddress (hWininetDll, &"InternetOpenA")
	OpenUrl = GetProcAddress (hWininetDll, &"InternetOpenUrlA")
	ReadFile = GetProcAddress (hWininetDll, &"InternetReadFile")
	CloseHandle = GetProcAddress (hWininetDll, &"InternetCloseHandle")

	IFZ Open THEN
		FreeLibrary (hWininetDll)
		RETURN 0
	ELSE
		IFZ OpenUrl THEN
			FreeLibrary (hWininetDll)
			RETURN 0
		ELSE
			IFZ ReadFile THEN
				FreeLibrary (hWininetDll)
				RETURN 0
			ELSE
				IFZ CloseHandle THEN
					FreeLibrary (hWininetDll)
					RETURN 0
				END IF
			END IF
		END IF
	END IF
	
	null = ""
	hSession = @Open (&"httpGetFile", $$INTERNET_OPEN_TYPE_PRECONFIG, &null, &null, 0)
	IFZ hSession THEN RETURN 0

	hOpenUrl = @OpenUrl (hSession, &URL, &null, 0, $$INTERNET_FLAG_RELOAD | $$INTERNET_FLAG_EXISTING_CONNECT, 0)
	IFZ hOpenUrl THEN
		IF (hSession != 0) THEN @CloseHandle (hSession)
		RETURN 0
	END IF
	
	DIM buff[15]
	tbytes = 0
	i = 0

	DO
		IFZ @ReadFile (hOpenUrl, &buff[i].buffer[0], 65530, &buff[i].size) THEN EXIT DO
		IFZ buff[i].size THEN EXIT DO
		tbytes = tbytes + buff[i].size
		INC i
		IF (i >= UBOUND(buff[])) THEN REDIM buff[i+15]
	LOOP

	' Use InternetGetLastResponseInfo () to retrieve error info

	IF (hOpenUrl != 0) THEN @CloseHandle (hOpenUrl): hOpenUrl = 0
	IF (hSession != 0) THEN @CloseHandle (hSession): hSession = 0

	RETURN tbytes
END FUNCTION

FUNCTION open_file (lpfilename, flags)

	IFZ lpfilename THEN RETURN 0
	IFZ flags THEN
		type = &"rb"
	ELSE
		type = flags
	END IF
	
	hfile = fopen (lpfilename, type)
	IFZ hfile THEN
		RETURN 0
	ELSE
		RETURN hfile
	END IF
END FUNCTION

FUNCTION close_file (file)

	IF file THEN
		fclose (file)
		RETURN 1
	ELSE
		RETURN 0
	END IF
END FUNCTION

FUNCTION write_file (hfile, ULONG buffer, nbytes)

	'_write (hfile, buffer, nbytes)
	foffset = 0
	fgetpos (hfile, &foffset)
	
	IF (fwrite (buffer, 1, nbytes, hfile) < nbytes) THEN
		RETURN -1
	ELSE
		RETURN foffset
	END IF
END FUNCTION

END PROGRAM
