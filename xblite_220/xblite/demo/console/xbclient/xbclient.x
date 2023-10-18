
'
'	A net client example.
' Michael McElligott - Mapei_@hotmail.com
'	16/6/2003
'
'	Note: try connecting to an http or irc
' server or using xbserver.x. If testing with
' xbserver.exe, run xbserver.exe FIRST before
' running xbclient.exe
'
'
PROGRAM	"xbclient"
VERSION	"0.0002"
CONSOLE
'MAKEFILE "xexe.xxx"

 	IMPORT "wsock32"
	IMPORT "kernel32"
	IMPORT "msvcrt"
 
DECLARE FUNCTION Entry ()
DECLARE FUNCTION Initialize ()
DECLARE FUNCTION Shutdown ()

DECLARE FUNCTION ConnectToServer (server$,port)
DECLARE FUNCTION sConnect (server$,port,socket)
DECLARE FUNCTION sMessageListen (socket)
DECLARE FUNCTION MessagePump (socket,str$)
DECLARE FUNCTION ProcessCommands (socket,str$)
DECLARE FUNCTION SendSMessage (socket,buffer$)
DECLARE FUNCTION SendSMessageBin (socket,pbuffer,len)
DECLARE FUNCTION sMessageListenBin (socket,size,ANY)

DECLARE FUNCTION CPrint (socket,STRING text)

DECLARE FUNCTION STRING trim (str$,char)
DECLARE FUNCTION GetToken (str$,msg$,term)

DECLARE FUNCTION GetIPName (numIPAddr$, @IPName$)
DECLARE FUNCTION GetIPAddr (IPName$, @numIPAddr$)
DECLARE FUNCTION GetError ()
DECLARE FUNCTION STRING error (error)

$$MAX_LBUFFER			= 512		' socket recv buffer size

$$ER_CONNECTED			= 3
$$ER_CONNECTFAILURE		= 4
$$ER_INVALIDADDRESS		= 5
$$ER_AUTHNOCONNECT		= 6
$$ER_WSASTARTUPFAIL		= 7
$$ER_WSANOWINSOCK		= 8
$$ER_WSANOTINITILIZED	= 9
$$ER_INITFAILURE		= 10


FUNCTION  Entry ()
	SHARED socket


	IFF Initialize () THEN
		CPrint (socket,error($$ER_INITFAILURE))
		RETURN $$FALSE
	END IF

	server$ = #ip$
	port = 5566
	socket = ConnectToServer (server$,port)
	IFZ socket THEN Shutdown ()

	SendSMessage (socket,"SMSG 'SMSG' this is a message from client to host")
	SendSMessage (socket,"this message is unhandled by server")
	Sleep (6000)

	SendSMessage (socket,"SHUTDOWN")			' shutdown server
	Sleep (3000)								' wait for reply before exiting

	Shutdown ()

END FUNCTION

FUNCTION Initialize ()
	WSADATA wsadata


	version = 2 OR (2 << 8)								' version winsock v2.2 (MAKEWORD (2,2))
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll

	IF ret THEN
		CPrint (socket,error($$ER_WSASTARTUPFAIL))
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		CPrint (socket,error($$ER_WSANOWINSOCK))
		WSACleanup ()
		RETURN $$FALSE
	END IF

	GetIPAddr ("", @#ip$)

	RETURN $$TRUE

END FUNCTION


FUNCTION Shutdown ()
	SHARED socket

	closesocket (socket)
	CloseHandle (#hThread)
	WSACleanup ()
	a$ = INLINE$ ("Press any key to quit >")
	QUIT (0)

END FUNCTION

FUNCTION ConnectToServer (server$,port)


	CPrint (socket,"* connecting to "+server$+":"+STRING$(port))

	IFT sConnect (server$,port,@socket) THEN
		#hThread = _beginthreadex (NULL, 0, &sMessageListen(), socket, 0, &tid2)
		' thread can be killed via 'CloseHandle (#hThread)'
		' remebmer that thread will die when main process has ended
		CPrint (socket,"* connected to "+server$+" on port "+STRING$(port)+"\n")
		RETURN socket
	ELSE
	'	CPrint (socket,error($$ER_CONNECTFAILURE))
		RETURN 0
	END IF

END FUNCTION

FUNCTION sConnect (server$,port,socket)
	SOCKADDR_IN udtSocket

	udtSocket.sin_family = $$AF_INET
	udtSocket.sin_port   = htons (port)
	udtSocket.sin_addr   = inet_addr (&server$)

' Check to see if address was in numeric form
' if not, then resolve it
	IF udtSocket.sin_addr = $$INADDR_NONE THEN
		GetIPAddr (server$, @numIPAddr$)
		udtSocket.sin_addr = inet_addr (&numIPAddr$)
	END IF

	socket = socket (udtSocket.sin_family, $$SOCK_STREAM, $$IPPROTO_IP)
	IF (connect (socket, &udtSocket, SIZE(udtSocket)) == $$SOCKET_ERROR) THEN
		CPrint (socket,error($$ER_INVALIDADDRESS))
		closesocket (socket)
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF

END FUNCTION

FUNCTION sMessageListen (csocket)
	SHARED socket

	DO
		pageBuffer$ = NULL$($$MAX_LBUFFER)
		rover = &pageBuffer$
		read = 0

		DO WHILE (read < $$MAX_LBUFFER)
			thisRead = recv (csocket, rover, $$MAX_LBUFFER-read, 0)

			IF (thisRead == $$SOCKET_ERROR || thisRead == 0) THEN
				EXIT DO
			ELSE
				str$ = MID$(CSIZE$(pageBuffer$),read+1,thisRead)+"\0"
				MessagePump (csocket,str$)
				read = read + thisRead
				rover = rover + thisRead
			END IF
		LOOP
	LOOP WHILE socket

	RETURN $$TRUE

END FUNCTION

FUNCTION MessagePump (socket,str$)
	STATIC oldstr$

	p = 0
	IF oldstr$ THEN str$ = oldstr$ + str$

	DO
		char = str${p}
		SELECT CASE char
			CASE 0x0D		:
			CASE 0x0A		:ProcessCommands (socket,LTRIM$(trim (cmd$,0)))
							 cmd$ = ""
			CASE 0x00		:IF cmd$ THEN
								oldstr$ = cmd$
								ldp = p-1
							 ELSE
								oldstr$ = ""
								ldp = 0
							 END IF
							 EXIT FUNCTION
			CASE ELSE		:cmd$ = cmd$ + CHR$(char)
		END SELECT

		INC p
	LOOP UNTIL (p-1 >= LEN (str$))

END FUNCTION

FUNCTION ProcessCommands (socket,msg$)

	GetToken (@msg$,@cmd$,32)

	SELECT CASE UCASE$(cmd$)
		CASE "CMSG"			:CPrint (socket,msg$)
		CASE "HELLO"		:CPrint (socket,msg$)
		CASE "ECHO"			:CPrint (socket,msg$)
		CASE ELSE			:CPrint (socket,": "+cmd$+" "+msg$)
	END SELECT

END FUNCTION

FUNCTION SendSMessage (socket,buffer$)

	buffer$ = buffer$ + "\r\n"
	SendSMessageBin (socket,&buffer$,SIZE(buffer$))

END FUNCTION

FUNCTION SendSMessageBin (socket,pbuffer,size)

	IF send (socket, pbuffer, size, 0) = -1 THEN
		CPrint (socket,"socket send error :: -1")
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF

END FUNCTION

FUNCTION sMessageListenBin (socket,size,STRING buffer)

	IFZ size THEN RETURN $$FALSE
	buffer = NULL$(size)
	rover = &buffer
	read = 0

	DO WHILE (read < size)
		thisRead = recv (socket, rover, size-read, 0)

		IF (thisRead == $$SOCKET_ERROR || thisRead == 0) THEN
			EXIT DO
		ELSE
			read = read + thisRead
			rover = rover + thisRead
		END IF
	LOOP

	RETURN $$TRUE

END FUNCTION

FUNCTION CPrint (socket,STRING text)

	IFZ text THEN RETURN $$FALSE
	trim (@text,0)

	PRINT text

	RETURN $$TRUE
END FUNCTION

FUNCTION STRING trim (str$,char)

	IFZ str$ THEN RETURN ""
	out$=""

	FOR p = 0 TO LEN (str$)-1
		IF str${p} != char THEN out$ = out$ + CHR$(str${p})
	NEXT p

	str$ = out$
	RETURN str$

END FUNCTION

FUNCTION GetToken (str$,msg$,term)

	IFZ str$ THEN RETURN $$FALSE

	len = LEN(str$)
	msg$=""

	FOR p = 0 TO len-1
		IF str${p} = term THEN
			INC p
			str$ = RIGHT$(str$,len-p)
			RETURN p
		ELSE
			msg$ = msg$ + CHR$(str${p})
		END IF
	NEXT p

	str$ = ""
	RETURN p

END FUNCTION


' IN		:numIPAddr$ (66.54.32.27)
' OUT		:IPName$ (www.usatoday.com)			' DS
FUNCTION GetIPName (numIPAddr$, @IPName$)
	WSADATA wsadata
	HOSTENT	host

 	version = 0x0001
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		CPrint (socket,error($$ER_WSANOTINITILIZED))
		WSACleanup ()
		RETURN
	END IF

	IF wsadata.wVersion != version THEN
		CPrint (socket,error($$ER_WSANOWINSOCK))
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

' IN		:IPName$ (www.usatoday.com)
' OUT		:numIPAddr$ (66.54.32.27)		' DS
FUNCTION GetIPAddr (IPName$, @numIPAddr$)

	WSADATA wsadata
	HOSTENT	host

	version = 0x0001
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		CPrint (socket,error($$ER_WSANOTINITILIZED))
		WSACleanup ()
		RETURN
	END IF

	IF wsadata.wVersion != version THEN
		CPrint (socket,error($$ER_WSANOWINSOCK))
		WSACleanup ()
		RETURN
	END IF

	host = gethostbyname (&IPName$)

	IF host.h_addr_list <> 0 THEN
		addr = 0
		RtlMoveMemory (&addr, host.h_addr_list, 4)
		RtlMoveMemory (&addr, addr, 4)

		addr2 = inet_ntoa (addr)

'		length = strlen (addr2)
		numIPAddr$ = NULL$ (512)
		RtlMoveMemory (&numIPAddr$, addr2, LEN(numIPAddr$))
		numIPAddr$ = CSIZE$ (numIPAddr$)
	END IF

	WSACleanup ()

END FUNCTION

FUNCTION GetError ()

	lastErr = WSAGetLastError ()
	CPrint (socket,"error code :: "+STRING$(lastErr))
	RETURN lastErr

END FUNCTION


FUNCTION STRING error (errornum)

	SELECT CASE errornum
		CASE  $$ER_CONNECTED				: text$ = "-- join server error :: already connected, disconnect first"
		CASE  $$ER_CONNECTFAILURE		: text$ = "-- join server error :: unable to connect to server"
		CASE  $$ER_INVALIDADDRESS		: text$ = "-- unable to connect to host"
		CASE  $$ER_AUTHNOCONNECT		: text$ = "-- auth server error :: not connected"
		CASE  $$ER_WSASTARTUPFAIL		: text$ = "-- WSA startup error :: unable to initialize"
		CASE  $$ER_WSANOWINSOCK			: text$ = "-- WSA startup error :: unsupported winsock version"
		CASE  $$ER_WSANOTINITILIZED	: text$ = "-- WSA startup error :: not initilized"
		CASE  $$ER_INITFAILURE			: text$ = "-- start up error :: unable to initialize client"
		CASE ELSE										: text$ = "-- my poor programming has led you to read this message"
	END SELECT

	RETURN text$

END FUNCTION
END PROGRAM
