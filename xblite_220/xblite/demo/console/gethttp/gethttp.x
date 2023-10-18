'
'
' #######################
' #####  gethttp.x  #####
' #######################
'
' This program shows how to retrieve a file using
' the Hyper Text Transfer Protocol, HTTP and
' windows socket functions in wsock32.dll
' It creates a stream, connection-oriented client.
'
' Ex: GetHTTP ("www.usatoday.com", "/", @http$)
'
' It is based on gethttp.c and examples provided in \
' the VB program URLInfo:
' http://vbwork.4mg.com/articles/urlinfo.html
'
' Note: this does not work on all IP addresses so
' it would probably be best to PING or otherwise
' validate that the IP address is correct.
'
PROGRAM	"gethttp"
VERSION	"0.0003"
CONSOLE
'
	IMPORT	"xst"   		' Standard library 	: required by most programs
	IMPORT	"xsx"
'	IMPORT	"xio"
	IMPORT	"wsock32"		' wsock32.dll				: windows socket library
	IMPORT	"msvcrt"		' msvcrt.dll				: MS Visual C++ Runtime library
	IMPORT	"kernel32"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  GetHTTP (IPAddr$, page$, @html$, @header$)
DECLARE FUNCTION  GetIPAddr (IPName$, @numIPAddr$)
DECLARE FUNCTION  GetIPName (numIPAddr$, @IPName$)
DECLARE FUNCTION  GetHTTP2 (IPAddr$, page$, @html$, @header$)
DECLARE FUNCTION  HttpError (header$, @statusCode, @statusMsg$)
DECLARE FUNCTION  GetHttpHeaderInfo (header$, @date$, @server$, @location$, @type$, @length)


'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

' add some rows to console buffer
'	hStdOut = XioGetStdOut ()
'	XioSetConsoleBufferSize (hStdOut, 0, 100)
'	XioCloseStdHandle (hStdOut)

'	IPName$   = "perso.wanadoo.fr"
'	fileName$ = "/xblite/"
' save$     = "xblite.htm"

	IPName$   = "www.usatoday.com"
	fileName$ = "/"
  save$     = "usatoday.htm"

' 4.6 MB tif image from the Cassini probe
'	IPName$   = "photojournal.jpl.nasa.gov"
' fileName$ = "/tiff/PIA06141.tif"
' save$     = "PIA06141.tif"
	
	GetIPAddr (IPName$, @numIPAddr$)
	PRINT IPName$; " :: "; numIPAddr$

	GetIPName (numIPAddr$, @IPName2$)
	PRINT numIPAddr$; " :: "; IPName2$

	GetIPAddr (IPName2$, @numIPAddr$)
	PRINT IPName2$; " :: "; numIPAddr$

'	a$ = INLINE$ ("Press ENTER to continue >")

'	PRINT
'	PRINT "GetHTTP    : "; IPName$; fileName$
'	start = GetTickCount ()
'	GetHTTP (IPName$, fileName$, @http$, @header$)
'	time# = (GetTickCount() - start)/1000.0
'  PRINT "DL time   :"; time#
'	PRINT "bytes      :"; LEN (http$)
	
	a$ = INLINE$ ("Press ENTER to continue >")

	http$ = ""
	header$ = ""
	PRINT
	PRINT "GetHTTP2   : "; IPName$; fileName$
	start = GetTickCount ()
	GetHTTP2 (IPName$, fileName$, @http$, @header$)
	time# = (GetTickCount() - start)/1000.0
  PRINT "DL time    :"; time#
	PRINT "bytes      :"; LEN (http$)

	IF http$ THEN
		XstSaveString (save$, http$)
	END IF

  IF header$ THEN
    GetHttpHeaderInfo (header$, @date$, @server$, @location$, @type$, @length)  
    HttpError (header$, @statusCode, @statusMsg$)
    PRINT "date       : "; date$
    PRINT "server     : "; server$
    PRINT "location   : "; location$
    PRINT "type       : "; type$
    PRINT "length     :"; length
    PRINT "status     :"; statusCode
    PRINT "status msg : "; statusMsg$
  END IF

	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
'
'
' ########################
' #####  GetHTTP ()  #####
' ########################
'
' PURPOSE	: Retrieves a file using http protocol.
'	IN			: IPName$			- internet provider name, www.usatoday.com
'						page$				- name of file to retrieve, /index.html
'	OUT			:	html$				- downloaded file
'         : header$     - header info
'
FUNCTION  GetHTTP (IPName$, page$, @html$, @header$)

	WSADATA wsadata
	SOCKADDR_IN udtSocket
	SOCKET socket
	UBYTE data[]

	version = 2 OR (2 << 8)											' version winsock v2.2 (MAKEWORD (2,2))
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		PRINT "WSAStartup Error :: "; ret
		WSACleanup ()
		RETURN
	END IF

	IF wsadata.wVersion != version THEN
		PRINT "winsock version not supported"
		WSACleanup ()
		RETURN
	END IF

	socket = socket ($$AF_INET, $$SOCK_STREAM, $$IPPROTO_TCP)
	PRINT "socket :: "; socket
	IF (socket < 0) THEN
		PRINT "socket() Error :: "; socket
		RETURN
	END IF

	udtSocket.sin_family = $$AF_INET
	GetIPAddr (IPName$, @numIPAddr$)
	udtSocket.sin_addr = inet_addr (&numIPAddr$)
	udtSocket.sin_port = htons (80)

	ret = connect (socket, &udtSocket, SIZE(udtSocket))
	PRINT "connect :: "; ret
	IF (ret == $$SOCKET_ERROR) THEN
		PRINT "connect() error :: "; ret
		GOSUB GetError
		closesocket (socket)
		RETURN
	END IF

	request$ = "GET " + page$ + " HTTP/1.0\r\n" + "Host: " + IPName$ + "\r\n" + "Accept: */*\r\n\r\n"

	ret = send (socket, &request$, LEN(request$), 0)
	PRINT "send :: "; ret
	IF (ret == $$SOCKET_ERROR) THEN
		PRINT "send() error :: "; ret
		GOSUB GetError
		closesocket (socket)
		RETURN
	END IF

' receive the file contents
  DIM data[65536]
  addr = &data[]
  DO
  	read = recv (socket, addr, 8400, 0)
  	IF (read == $$SOCKET_ERROR || read == 0) THEN EXIT DO
  	bytes = bytes + read
  	IF bytes+8400 >= UBOUND(data[]) THEN REDIM data[bytes*2]
  	addr = &data[] + bytes
  LOOP
  
  IFZ bytes THEN GOTO finish
  REDIM data[bytes-1]

' copy data from array data[] to string html$
  html$ = NULL$(bytes)
  IF bytes THEN RtlMoveMemory (&html$, &data[], bytes)

' split off header
  IF INSTR (html$, "HTTP/") THEN
    x = INSTR (html$, "\r\n\r\n")
    IF x THEN
      header$ = LEFT$ (html$, x + 3)
      html$ = RIGHT$ (html$, LEN (html$) - x - 3)
    END IF
  END IF

finish:
	closesocket (socket)
	WSACleanup ()

	RETURN ($$TRUE)

' ***** GetError *****
SUB GetError
	lastErr = WSAGetLastError ()
	PRINT "error code :: "; lastErr
END SUB

END FUNCTION
'
'
' ##########################
' #####  GetIPAddr ()  #####
' ##########################
'
' PURPOSE	: Convert from a IP server name to a
' 					numeric IP address. For example,
'						www.usatoday.com is a IP name while
'						66.54.32.237 is the numeric IP address.
' IN			: IPName$ (www.usatoday.com)
' OUT			: numIPAddr$ (66.54.32.27)
'
FUNCTION  GetIPAddr (IPName$, @numIPAddr$)

	WSADATA wsadata
	HOSTENT	host

	version = 0x0001
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		PRINT "WSAStartup Error :: "; ret
		WSACleanup ()
		RETURN
	END IF

	IF wsadata.wVersion != version THEN
		PRINT "winsock version not supported"
		WSACleanup ()
		RETURN
	END IF

	host = gethostbyname (&IPName$)

	IF host.h_addr_list <> 0 THEN
		addr = 0
		RtlMoveMemory (&addr, host.h_addr_list, 4)
		RtlMoveMemory (&addr, addr, 4)
		addr2 = inet_ntoa (addr)
		numIPAddr$ = NULL$ (512)
		RtlMoveMemory (&numIPAddr$, addr2, LEN(numIPAddr$))
		numIPAddr$ = CSIZE$ (numIPAddr$)
	END IF

	WSACleanup ()


END FUNCTION
'
'
' ##########################
' #####  GetIPName ()  #####
' ##########################
'
' PURPOSE	: Convert from a numeric IP address to a
'						IP server name. For example, 66.54.32.237 is
' 					a numeric IP address while www.usatoday.com
'						is a IP server name.
' IN			: numIPAddr$ (66.54.32.27)
' OUT			: IPName$ (www.usatoday.com)
'
FUNCTION  GetIPName (numIPAddr$, @IPName$)

	WSADATA wsadata
	HOSTENT	host

	version = 0x0001
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		PRINT "WSAStartup Error :: "; ret
		WSACleanup ()
		RETURN
	END IF

	IF wsadata.wVersion != version THEN
		PRINT "winsock version not supported"
		WSACleanup ()
		RETURN
	END IF

	addr = inet_addr (&numIPAddr$)
	host = gethostbyaddr (&addr, 4, $$AF_INET)

	IF host.h_name <> 0 THEN
		IPName$ = NULL$ (512)
		RtlMoveMemory (&IPName$, host.h_name, LEN(IPName$))
		IPName$ = CSIZE$ (IPName$)
	END IF

	WSACleanup ()

END FUNCTION
'
'
' #########################
' #####  GetHTTP2 ()  #####
' #########################
'
' PURPOSE	: Retrieves a file from a HTTP server.
'						This version uses event objects and
'						WSASelectEvent() for asynchronous
'						notification of network events.
'
'	IN			: IPName$			- internet provider name, www.usatoday.com
'						page$				- name of file to retrieve, /index.html
'	OUT			:	html$				- downloaded file
'         : header$     - header info
'
FUNCTION  GetHTTP2 (IPName$, page$, @html$, @header$)

	WSADATA wsadata
	SOCKADDR_IN sa
	SOCKET socket
	HOSTENT	host
'	WSAEVENT hEvent
	WSANETWORKEVENTS events
	UBYTE buffer[]
	STATIC entry
	STATIC FUNCADDR CloseEvent (XLONG)
	STATIC FUNCADDR EnumNetworkEvents (XLONG, XLONG, XLONG)
	STATIC FUNCADDR WaitForMultipleEvents (XLONG, XLONG, XLONG, XLONG, XLONG)
	STATIC FUNCADDR EventSelect (XLONG, XLONG, XLONG)
	STATIC FUNCADDR CreateEvent ()
	STATIC hws2

	GOSUB Initialize

	error = $$FALSE
	html$ = ""
	header$ = ""

	version = 2 OR (2 << 8)											' version winsock v2.2 (MAKEWORD (2,2))
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		PRINT "WSAStartup Error :: "; ret
		WSACleanup ()
		RETURN $$TRUE
	END IF

	IF wsadata.wVersion != version THEN
		PRINT "winsock version not supported"
		WSACleanup ()
		RETURN $$TRUE
	END IF

	sa.sin_family = $$AF_INET
	GetIPAddr (IPName$, @numIPAddr$)
	sa.sin_addr = inet_addr (&numIPAddr$)
	sa.sin_port = htons (80)					' well-known HTTP port

' create a TCP/IP stream socket
	socket = socket ($$AF_INET, $$SOCK_STREAM, $$IPPROTO_TCP)
	IF (socket < 0) THEN
		PRINT "Error : socket ()"
		RETURN $$TRUE
	END IF

	optlen = 4
	optval = 0
	ret = getsockopt (socket, $$SOL_SOCKET, $$SO_RCVBUF, &optval, &optlen)
	IF (ret == $$SOCKET_ERROR) THEN
		err = WSAGetLastError ()
		PRINT "Error : getsockopt()", err
	END IF

' create an event object to be used with this socket

	hEvent = @CreateEvent ()
	IF (hEvent == $$WSA_INVALID_EVENT) THEN
		PRINT "Error : WSACreateEvent()"
		closesocket (socket)
		RETURN $$TRUE
	END IF

' make the socket non-blocking and
' associate it with network events

	ret = @EventSelect (socket, hEvent, $$FD_READ | $$FD_CONNECT | $$FD_CLOSE)
	IF (ret == $$SOCKET_ERROR) THEN
		PRINT "Error : WSAEventSelect()"
		closesocket (socket)
		@CloseEvent (hEvent)
		RETURN $$TRUE
	END IF

' request a connection
	ret = connect (socket, &sa, SIZE(SOCKADDR_IN))
	IF (ret == $$SOCKET_ERROR) THEN
		ret = WSAGetLastError ()
		IF (ret == $$WSAEWOULDBLOCK) THEN
'			PRINT "Connect would block"
		ELSE
			PRINT "Error : connect()"
			closesocket (socket)
			@CloseEvent (hEvent)
			RETURN $$TRUE
		END IF
	END IF

' handle async network events

' create buffer to save data
	DIM buffer[65536]
	addr = &buffer[]

	DO
' wait for something to happen
		ret = @WaitForMultipleEvents (1, &hEvent, $$FALSE, 10000, $$FALSE)
		IF (ret == $$WSA_WAIT_TIMEOUT) THEN
			PRINT "Wait timed out"
			error = $$TRUE
			EXIT DO
		END IF

' figure out what happened
		ret = @EnumNetworkEvents (socket, hEvent, &events)
		IF (ret == $$SOCKET_ERROR) THEN
			PRINT "Error : WSAEnumNetworkEvents()"
			error = $$TRUE
			EXIT DO
		END IF

' handle events

    SELECT CASE ALL TRUE
      CASE events.lNetworkEvents & $$FD_READ :          ' read event?
        ' read the data
			  thisRead = recv (socket, addr, 8400, 0)
			  IF (thisRead == $$SOCKET_ERROR) THEN
				  err = WSAGetLastError ()
				  PRINT "Error : recv() :: "; err
				  error = $$TRUE
				  EXIT DO
			  END IF
		    bytes = bytes + thisRead
        IF bytes+8400 >= UBOUND(buffer[]) THEN REDIM buffer[bytes*2]
        addr = &buffer[] + bytes

      CASE events.lNetworkEvents & $$FD_CONNECT :       ' connect event?
        ' send the http request
        request$ = "GET " + page$ + " HTTP/1.0\r\n" + "Host: " + IPName$ + "\r\n" + "Accept: */*\r\n\r\n"
			  ret = send (socket, &request$, LEN (request$), 0)
			  IF (ret == $$SOCKET_ERROR) THEN
				  PRINT "Error : send()"
				  error = $$TRUE
				  EXIT DO
			  END IF
			
      CASE events.lNetworkEvents & $$FD_CLOSE :          ' close event?
        EXIT DO
    END SELECT

	LOOP

  IFZ bytes THEN GOTO finish
  REDIM buffer[bytes-1]

' copy data from array data[] to string html$
  html$ = NULL$(bytes)
  IF bytes THEN RtlMoveMemory (&html$, &buffer[], bytes)

	IF INSTR (html$, "HTTP/") THEN
		x = INSTR (html$, "\r\n\r\n")
		IF x THEN
			header$ = LEFT$ (html$, x + 3)
			html$ = RIGHT$ (html$, LEN (html$) - x - 3)
		END IF
	END IF
	
finish:

	closesocket (socket)
'	WSACloseEvent (hEvent)
	@CloseEvent (hEvent)
	WSACleanup ()
	FreeLibrary (hws2)

	IFT error THEN RETURN $$TRUE
	RETURN

' ***** Initialize *****
SUB Initialize
'	entry = $$TRUE
	hws2 = LoadLibraryA (&"ws2_32.dll")
	IFZ hws2 THEN
		PRINT "Error : LoadLibraryA() : ws2_32.dll"
 		RETURN ($$TRUE)
	END IF

	CloseEvent            = GetProcAddress (hws2, &"WSACloseEvent")
	IFZ CloseEvent THEN RETURN ($$TRUE)

	EnumNetworkEvents     = GetProcAddress (hws2, &"WSAEnumNetworkEvents")
	IFZ EnumNetworkEvents THEN RETURN ($$TRUE)

	WaitForMultipleEvents = GetProcAddress (hws2, &"WSAWaitForMultipleEvents")
	IFZ WaitForMultipleEvents THEN RETURN ($$TRUE)

	EventSelect           = GetProcAddress (hws2, &"WSAEventSelect")
	IFZ EventSelect THEN RETURN ($$TRUE)

	CreateEvent           = GetProcAddress (hws2, &"WSACreateEvent")
	IFZ CreateEvent THEN RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ##################################
' #####  GetHttpHeaderInfo ()  #####
' ##################################
'
FUNCTION  GetHttpHeaderInfo (header$, @date$, @server$, @location$, @type$, @length)

	IFZ header$ THEN RETURN ($$TRUE)

	date$ = ""
	start = INSTR (header$, "Date: ")
	IF start THEN
		end = INSTR (header$, "\r\n", start)
		IF end THEN
			date$ = TRIM$ (MID$ (header$, start+6, end-start-6))
		END IF
	END IF

	server$ = ""
	start = INSTR (header$, "Server: ")
	IF start THEN
		end = INSTR (header$, "\r\n", start)
		IF end THEN
			server$ = TRIM$ (MID$ (header$, start+8, end-start-8))
		END IF
	END IF

	location$ = ""
	start = INSTR (header$, "Location: ")
	IF start THEN
		end = INSTR (header$, "\r\n", start)
		IF end THEN
			location$ = TRIM$ (MID$ (header$, start+10, end-start-10))
		END IF
	END IF

	type$ = ""
	start = INSTRI (header$, "Content-Type: ")
	IF start THEN
		end = INSTR (header$, "\r\n", start)
		IF end THEN
			type$ = TRIM$ (MID$ (header$, start+14, end-start-14))
		END IF
	END IF

	length = 0
	start = INSTRI (header$, "Content-Length: ")
	IF start THEN
		end = INSTR (header$, "\r\n", start)
		IF end THEN
			length = XLONG (TRIM$ (MID$ (header$, start+16, end-start-16)))
		END IF
	END IF

END FUNCTION
'
'
' ##########################
' #####  HttpError ()  #####
' ##########################
'
FUNCTION  HttpError (header$, @statusCode, @statusMsg$)

	pos = INSTR (header$, "HTTP/1.")
	IF pos THEN
  	statusCode = XLONG (MID$ (header$, pos + 9, 3))
	END IF

	IFZ pos THEN
		pos = INSTR (header$, "HTTP Error ")
		IF pos THEN
   		statusCode = XLONG (MID$ (header$, pos + 11, 3))
 		END IF
	END IF

	IF pos THEN
		SELECT CASE statusCode
			CASE 200 :  statusMsg$ = "OK, request succeeded."
			CASE 201 :  statusMsg$ = "OK, new resource created."
			CASE 202 :  statusMsg$ = "Request accepted but processing not completed."
			CASE 204 :  statusMsg$ = "OK, but no content return."
			CASE 301 :  statusMsg$ = "Requested resource has been assigned a new permanant URL."
			CASE 302 :  statusMsg$ = "Requested resource resides temporarily under a different URL."
			CASE 304 :  statusMsg$ = "Document has not been modified."
			CASE 400 :  statusMsg$ = "Bad request."
			CASE 401 :  statusMsg$ = "Unauthorized; request requires user authentication."
			CASE 403 :  statusMsg$ = "Forbidden for unspecified reason."
			CASE 404 :  statusMsg$ = "Not Found."
			CASE 407 :  statusMsg$ = "Unauthorized; reject by proxy server."
			CASE 500 :  statusMsg$ = "Internal server error."
			CASE 501 :  statusMsg$ = "Not implemented."
			CASE 502 :  statusMsg$ = "Bad gateway; invalid response from gateway or upstream server."
			CASE 503 :  statusMsg$ = "Service temporarily unavailable."
			CASE ELSE:	statusMsg$ = "Not A Valid Status Code"
		END SELECT

  	RETURN $$FALSE
	ELSE
		statusCode = 0
		statusMsg$ = ""
		RETURN $$TRUE
	END IF
END FUNCTION
END PROGRAM
