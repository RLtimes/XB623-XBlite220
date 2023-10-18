'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program using functions in wininet.dll
' to download any type of internet file from
' a source URL address.
'
PROGRAM	"geturl"
VERSION	"0.0002"
CONSOLE
'
	IMPORT	"xst"
	IMPORT  "xsx"
	IMPORT	"kernel32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  GetURLSource$ (URL$, fileName$, @bytesRead)
'
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

'	path$ = "c:/xblite/demo/console/geturl/"
	path$ = ""

'	url$ = "http://ourworld.compuserve.com/homepages/trishnickell/gallery.htm"
'	file$ = "gallery.htm"
'	fileName$ = path$ + file$
'	GetURLSource$ (url$, fileName$, @bytesRead)
'	PRINT file$, " : bytes :"; bytesRead

'	url$ = "http://ourworld.compuserve.com/homepages/trishnickell/images/075-2002-01.jpg"
'	file$ = "075-2002-01.jpg"
'	fileName$ = path$ + file$
'	GetURLSource$ (url$, fileName$, @bytesRead)
'	PRINT file$, " : bytes :"; bytesRead

'	url$ = "http://ourworld.compuserve.com/homepages/trishnickell/images/reddot.gif"
'	file$ = "reddot.gif"
'	fileName$ = path$ + file$
'	GetURLSource$ (url$, fileName$, @bytesRead)
'	PRINT file$, " : bytes :"; bytesRead
	
	url$ = "http://photojournal.jpl.nasa.gov/tiff/PIA06141.tif"
	file$ = "PIA06141.tif"
	fileName$ = path$ + file$
	start = GetTickCount ()
	GetURLSource$ (url$, fileName$, @bytesRead)
	time# = (GetTickCount() - start)/1000.0
	PRINT "Download time (sec):"; time#

	PRINT
	a$ = INLINE$ ("Press ENTER to exit >")

	RETURN

END FUNCTION
'
'
' ##############################
' #####  GetURLSource$ ()  #####
' ##############################
'
' PURPOSE : download a file from a url address
' IN			: URL$ - internet address
' 					fileName$ - the path and filename to save file as
' OUT			: bytesRead - number of bytes read from url file
' RETURN  : return is complete url file as a string
'
FUNCTION  GetURLSource$ (URL$, fileName$, @bytesRead)

	FUNCADDR Open (XLONG, XLONG, XLONG, XLONG, XLONG)
	FUNCADDR OpenUrl (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
	FUNCADDR ReadFile (XLONG, XLONG, XLONG, XLONG)
	FUNCADDR CloseHandle (XLONG)

	$INTERNET_FLAG_RELOAD = 0x80000000
	$INTERNET_OPEN_TYPE_PRECONFIG = 0
	$INTERNET_FLAG_EXISTING_CONNECT = 0x20000000

	IFZ URL$ THEN RETURN ""

	hWininetDll = LoadLibraryA (&"wininet.dll")
	IFZ hWininetDll THEN RETURN ""

	Open = GetProcAddress (hWininetDll, &"InternetOpenA")
	OpenUrl = GetProcAddress (hWininetDll, &"InternetOpenUrlA")
	ReadFile = GetProcAddress (hWininetDll, &"InternetReadFile")
	CloseHandle = GetProcAddress (hWininetDll, &"InternetCloseHandle")

	IFZ Open THEN
		FreeLibrary (hWininetDll)
		RETURN ""
	ELSE
		IFZ OpenUrl THEN
			FreeLibrary (hWininetDll)
			RETURN ""
		ELSE
			IFZ ReadFile THEN
				FreeLibrary (hWininetDll)
				RETURN ""
			ELSE
				IFZ CloseHandle THEN
					FreeLibrary (hWininetDll)
					RETURN ""
				END IF
			END IF
		END IF
	END IF

	null$ = ""
	agent$ = "httpGetFile"
	hSession = @Open (&agent$, $INTERNET_OPEN_TYPE_PRECONFIG, &null$, &null$, 0)
	IFZ hSession THEN GOSUB GetSourceErr

	hOpenUrl = @OpenUrl (hSession, &URL$, &null$, 0, $INTERNET_FLAG_RELOAD | $INTERNET_FLAG_EXISTING_CONNECT, 0)
	IFZ hOpenUrl THEN GOSUB GetSourceErr

	fDoLoop = $$TRUE
	DO WHILE fDoLoop
		readBuffer$ = NULL$ (2048)
		ret = @ReadFile (hOpenUrl, &readBuffer$, LEN (readBuffer$), &numberOfBytesRead)
    buffer$ = buffer$ + LEFT$ (readBuffer$, numberOfBytesRead)
		IFZ numberOfBytesRead THEN fDoLoop = $$FALSE
	LOOP

'	IFZ ret THEN GOSUB GetSourceErr

	IFZ buffer$ THEN
'		text$ = "GetURLSource$ Error : Empty returned buffer."
'		MessageBoxA (0, &text$, &"GetURLSource$ Error", $$MB_OK | $$MB_ICONEXCLAMATION)
 		GOTO end
	END IF

	IF fileName$ <> "" THEN
		err = XstSaveString (fileName$, buffer$)
'		IF err THEN
'			text$ = "GetURLSource$ Error : File not saved."
'			MessageBoxA (0, &text$, &"GetURLSource$ Error", $$MB_OK | $$MB_ICONEXCLAMATION)
'		END IF
	END IF

end:
	IF hOpenUrl <> 0 THEN @CloseHandle (hOpenUrl)
	IF hSession <> 0 THEN @CloseHandle (hSession)

	bytesRead = LEN (buffer$)

'	text$ = "Download Done. Bytes Read ="  + STRING$ (bytesRead)
'	MessageBoxA (0, &text$, &"GetURLSource Message", $$MB_OK | MB_ICONINFORMATION)

	RETURN buffer$


' ***** GetSourceErr *****
SUB GetSourceErr

'	XstGetSystemError (@errorNumber)
' Use InternetGetLastResponseInfo () to retrieve error info

'	XstSystemErrorNumberToName(errorNumber, @error$)

'	text$ = "Unable to open Internet Connection. "
'	text$ = text$ + "\r\nGetURLSource : error : " + STRING$ (errorNumber) + " : " + error$
'	MessageBoxA (0, &text$, &"GetURLSource$ Error", $$MB_OK | $$MB_ICONEXCLAMATION)

	IF hOpenUrl <> 0 THEN @CloseHandle (hOpenUrl)
	IF hSession <> 0 THEN @CloseHandle (hSession)

	RETURN ""
END SUB


END FUNCTION
END PROGRAM
