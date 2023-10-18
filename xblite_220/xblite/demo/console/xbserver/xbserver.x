'
'	xbserver.x
'	a net server example by Michael McElligott
'	Mapei_@hotmail.com
'
'	16/6/2003
'
'	note: try using telnet as a client or simply using xbclient.x
'

PROGRAM	"xbserver"
VERSION	"0.0002"
CONSOLE
'MAKEFILE "xexe.xxx"

	IMPORT "xsx"
	IMPORT "wsock32"
	IMPORT "kernel32"

DECLARE FUNCTION Entry ()
DECLARE FUNCTION Initialize ()
DECLARE FUNCTION ShutDown ()
DECLARE FUNCTION ShutDownNet ()

DECLARE FUNCTION GetIPAddr (IPName$, @numIPAddr$)
DECLARE FUNCTION GetIPName (numIPAddr$,@IPName$)
DECLARE FUNCTION STRING localIp ()

DECLARE FUNCTION SendSMessage (socket,buffer$)
DECLARE FUNCTION SendSMessageBin (socket,pbuffer,len)
DECLARE FUNCTION sMessageListen (socket)
DECLARE FUNCTION sMessageListenBin (socket,size,ANY)
DECLARE FUNCTION sBind (socket,ipaddress$,port)
DECLARE FUNCTION MessagePump (socket,str$)
DECLARE FUNCTION ProcessCommands (socket,str$)

DECLARE FUNCTION GetToken (string$,token$,term)
DECLARE FUNCTION STRING trim (STRING text,char)

DECLARE FUNCTION CmdRestart ()

$$MAX_LBUFFER	= 512			' listen buffer size in bytes
$$L_Port		= 5566			' listening port to accept connection on


FUNCTION Entry ()
	SOCKADDR_IN  sockaddrin
	SHARED socket,client

 	IFF Initialize () THEN RETURN $$FALSE

	socket = socket ($$AF_INET, $$SOCK_STREAM, 0)
	IFZ socket THEN RETURN $$FALSE

	ret = $$FALSE
	DO					' wait until port is free to bind
		ret = sBind (socket,#ip$,$$L_Port)
		IFF ret THEN Sleep(1000)
	LOOP WHILE (ret == $$FALSE)

	listen (socket, 1)
	length = SIZE (sockaddrin)
	PRINT "local ip : "; #ip$
	PRINT "listening on port "+STRING$($$L_Port)+"\n"

	DO
		client = accept (socket, &sockaddrin, &length)
		IF client THEN				' a client has connected
			#cip$ = CSTRING$(inet_ntoa (sockaddrin.sin_addr))
			PRINT #cip$;" connected"

			SendSMessage (client,"HELLO *** Welcome "+ #cip$+" ***")
			SendSMessage (client,"CMSG *** Server Ready ***")
			SendSMessage (client,"CMSG *** 'CMSG' this is a message from host to client ***")
			sMessageListen (client)

			PRINT #cip$;" disconnected\n"
		END IF
	LOOP WHILE socket

	ShutDown ()

END FUNCTION

FUNCTION Initialize ()
	WSADATA wsadata

	#ip$ = localIp ()

	version = 2 OR (2 << 8)
	ret = WSAStartup (version, &wsadata)

	IF ret THEN
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		WSACleanup ()
		RETURN $$FALSE
	END IF

	RETURN $$TRUE

END FUNCTION


FUNCTION ShutDown ()

	ShutDownNet ()
	QUIT (0)

END FUNCTION

FUNCTION ShutDownNet ()
	SHARED socket,client

	closesocket (client): client = 0
	closesocket (socket): socket = 0
	WSACleanup ()
	RETURN $$TRUE

END FUNCTION

FUNCTION GetIPAddr (IPName$, @numIPAddr$)
	WSADATA wsadata
	HOSTENT	host

 	version = 0x0001
	ret = WSAStartup (version, &wsadata)
	IF ret THEN
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		WSACleanup ()
		RETURN $$FALSE
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
	RETURN $$TRUE

END FUNCTION

FUNCTION GetIPName (numIPAddr$, @IPName$)
	WSADATA wsadata
	HOSTENT	host

	version = 0x0001
	ret = WSAStartup (version, &wsadata)		' initialize winsock.dll
	IF ret THEN
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		WSACleanup ()
		RETURN $$FALSE
	END IF

	addr = inet_addr (&numIPAddr$)
	host = gethostbyaddr (&addr, 4, $$AF_INET)

	IF host.h_name <> 0 THEN
		IPName$ = NULL$ (512)
		RtlMoveMemory (&IPName$, host.h_name, LEN(IPName$))
		IPName$ = CSIZE$ (IPName$)
	END IF

	WSACleanup ()
	RETURN $$TRUE

END FUNCTION

FUNCTION STRING localIp ()

	name$ = NULL$(256)
	gethostname (&name$,255)
	GetIPAddr (name$, @ip$)

	RETURN  ip$
END FUNCTION

FUNCTION SendSMessage (socket,buff$)

	WaitForSingleObject (#hSSMsg,$$INFINITE)
	buffer$ = buff$ + "\r\n"

	IF send (socket, &buffer$, LEN(buffer$), 0) = -1 THEN
		ret = $$FALSE
	ELSE
		ret = $$TRUE
	END IF

	ReleaseSemaphore (#hSSMsg,1,NULL)
	RETURN ret

END FUNCTION

FUNCTION SendSMessageBin (socket,pbuffer,len)

 	WaitForSingleObject (#hSSMsg,$$INFINITE)

	IF send (socket, pbuffer, len, 0) = -1 THEN
		ret = $$FALSE
	ELSE
		ret = $$TRUE
	END IF

	ReleaseSemaphore (#hSSMsg,1,NULL)
	RETURN ret

END FUNCTION

FUNCTION sMessageListen (socket)

	DO
		pageBuffer$ = NULL$($$MAX_LBUFFER)
		rover = &pageBuffer$
		read = 0

		DO WHILE (read < $$MAX_LBUFFER)
			thisRead = recv (socket, rover, $$MAX_LBUFFER-read, 0)

			IF (thisRead == $$SOCKET_ERROR || thisRead == 0) THEN
				socket = 0
				RETURN $$TRUE
			ELSE
				str$ = MID$(CSIZE$(pageBuffer$),read+1,thisRead)+"\0"
				MessagePump (socket,str$)
				read = read + thisRead
				rover = rover + thisRead
			END IF
		LOOP WHILE socket
	LOOP WHILE socket

	RETURN $$TRUE

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

FUNCTION sBind (socket,ipaddress$,port)
	SOCKADDR_IN udtSocket

	GetIPAddr (ipaddress$, @numIPAddr$)
	address$$ = inet_addr (&numIPAddr$)
	IF (address$$ <= 0) THEN address$$ = $$INADDR_ANY
	IF (port <= 0) THEN port = 0

	udtSocket.sin_family = $$AF_INET
	udtSocket.sin_port = htons (port)
	udtSocket.sin_addr = address$$

	IF bind (socket, &udtSocket, SIZE (udtSocket)) = -1 THEN
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF

END FUNCTION


FUNCTION MessagePump (socket,str$)
	STATIC oldstr$

 	p = 0
	IF oldstr$ THEN str$ = oldstr$ + str$

	DO
		char = str${p}

		SELECT CASE char
			CASE 0x0D		:
			CASE 0x0A		:ProcessCommands (socket,trim (cmd$,0))
							 cmd$ = ""
			CASE 0x00		:IF cmd$ THEN
								oldstr$ = cmd$
							 ELSE
								oldstr$ = ""
							 END IF
							 EXIT FUNCTION
			CASE ELSE		:cmd$ = cmd$ + CHR$(char)
		END SELECT

		INC p
	LOOP UNTIL (p >= LEN (str$))
	'should never reach this point.

END FUNCTION

FUNCTION ProcessCommands (socket,str$)

	str$ = TRIM$(str$)
	GetToken (@str$,@cmd$,32)

	SELECT CASE UCASE$(cmd$)
		CASE "RESTART"		:CmdRestart ()
		CASE "SHUTDOWN"		:SendSMessage (socket,"CMSG *** Server shutting down ***")
							 Sleep (500)
							 ShutDown ()
		CASE "SMSG"			:PRINT str$
		CASE ELSE			:SendSMessage (socket,"ECHO "+cmd$+" "+str$)
	END SELECT

	RETURN $$TRUE
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

FUNCTION STRING trim (str$,char)

	IFZ str$ THEN RETURN ""
	out$=""

	FOR p = 0 TO LEN (str$)-1
		IF str${p} != char THEN out$ = out$ + CHR$(str${p})
	NEXT p

	str$ = out$
	RETURN str$

END FUNCTION

FUNCTION CmdRestart ()
	SHARED socket,client

	SendSMessage (client,"CMSG *** Server Restarting ***")
	Sleep (500)

	ShutDownNet ()
	XstGetCommandLineArguments (argc,@argv$[])
	SHELL (":"+argv$[0])
	QUIT (0)

END FUNCTION
END PROGRAM
