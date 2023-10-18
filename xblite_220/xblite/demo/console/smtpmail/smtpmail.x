
'
'	 smtpmail.x - a small smtp example
'	 by Michael McElligott
'	 Mapei_@hotmail.com
'
'	14/7/2003
'
'	for information on the SMTP protocol goto: http://www.sendmail.org/rfc/0821.html#4.2
'
PROGRAM	"smtpmail"
VERSION	"0.0003"
CONSOLE

'	IMPORT "xst"
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
DECLARE FUNCTION STRING localIp ()
EXPORT
DECLARE FUNCTION SendMail (from$, fromName$, to$, date$, subject$, body$, server$)
DECLARE FUNCTION GetTimeStamp (date$)
END EXPORT

$$MAX_LBUFFER			= 128		' socket recv buffer size

FUNCTION  Entry ()

	IF LIBRARY (0) THEN RETURN
	
	from$ 		= "myname@yahoo.com"
	fromName$ = "myname"
	to$ 			= "somebody@aol.com"
	GetTimeStamp (@date$)
	subject$ 	= "test mail"
	body$ 		= "just an email test"
	server$ 	= "mail.servername.com"
	err = SendMail (from$, fromName$, to$, date$, subject$, body$, server$)
	PRINT "SendMail err:"; err
	a$ = INLINE$ ("Press any key to quit >")

END FUNCTION

FUNCTION ProcessCommands (socket,msg$)

	GetToken (@msg$,@cmd$,32)

	SELECT CASE UCASE$(cmd$)		' parse smtp return codes
		'CASE "220"			:
		'CASE "221"			:
		'CASE "250"			:
		'etc,..
		CASE ELSE			:CPrint (socket,cmd$+" "+msg$)
	END SELECT

END FUNCTION

FUNCTION CPrint (socket,STRING text)

	IFZ text THEN RETURN $$FALSE
	trim (@text,0)
	PRINT text
	RETURN $$TRUE
	
END FUNCTION

FUNCTION ConnectToServer (server$,port)

	CPrint (socket,"* connecting to "+server$+":"+STRING$(port))
 
	IFT sConnect (server$,port,@socket) THEN
		#hThread = _beginthreadex (NULL, 0, &sMessageListen(), socket, 0, &tid2)
		' thread will die when main process has ended
		CPrint (socket,"* connected to "+server$+" on port "+STRING$(port)+"\n")
		RETURN socket
	ELSE
		RETURN 0
	END IF

END FUNCTION


FUNCTION Shutdown ()
	SHARED socket
	
	closesocket (socket): socket = 0
	Sleep (4000)
	CloseHandle (#hThread)
	WSACleanup ()
'	QUIT (0)

END FUNCTION

FUNCTION SendSMessage (socket, buffer$)

'	PRINT "***** " + buffer$ + " *****"

	buffer$ = buffer$ + "\r\n"
	RETURN SendSMessageBin (socket, &buffer$, SIZE(buffer$))

END FUNCTION

FUNCTION SendSMessageBin (socket, pbuffer, size)

	sent = 0
	DO
		size = size-sent
		sent = send (socket, pbuffer+sent, size, 0)
		IF (sent == $$SOCKET_ERROR) THEN
			CPrint (idx, "* send error: " + STRING$(WSAGetLastError()))
			RETURN $$FALSE
		END IF
	LOOP WHILE (sent < size)
	
	RETURN $$TRUE
END FUNCTION

FUNCTION sConnect (ipaddress$, port, socket)
	SOCKADDR_IN udtSocket

	
	udtSocket.sin_family = $$AF_INET
	udtSocket.sin_port = htons (port)
	udtSocket.sin_addr = inet_addr (&ipaddress$)

	IF udtSocket.sin_addr = $$INADDR_NONE THEN
		GetIPAddr (ipaddress$, @numIPAddr$)
		udtSocket.sin_addr = inet_addr (&numIPAddr$)
	END IF
	
	socket = socket (udtSocket.sin_family, $$SOCK_STREAM, 0)
	IF (connect (socket, &udtSocket, SIZE(udtSocket)) == $$SOCKET_ERROR) THEN
		CPrint (idx,"* connect error: "+STRING$(WSAGetLastError()))
		closesocket (socket)
		socket = 0
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF

END FUNCTION

FUNCTION sMessageListenBin (socket, size, STRING buffer)

	
	IFZ size THEN RETURN $$FALSE
	buffer = NULL$(size)
	rover = &buffer
	read = 0
		
	DO WHILE (read < size)
		thisRead = recv (socket, rover, size-read, 0)
	
		IF (thisRead == $$SOCKET_ERROR || thisRead == 0) THEN
			IF (thisRead == $$SOCKET_ERROR) THEN
				CPrint (idx,"* recv error: "+STRING$(WSAGetLastError()))
				RETURN $$FALSE
			END IF
		ELSE		
			read = read + thisRead
			rover = rover + thisRead
		END IF
	LOOP
	
	RETURN $$TRUE

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
				IF (thisRead == $$SOCKET_ERROR) THEN
					CPrint (idx,"* wsa return code: " + STRING$(WSAGetLastError()))
					EXIT DO 2
				ELSE
					EXIT DO 1
				END IF
			ELSE		
				str$ = MID$(CSIZE$(pageBuffer$),read+1,thisRead)+"\0"
				MessagePump (csocket,str$)
				read = read + thisRead
				rover = rover + thisRead
			END IF
			
		LOOP WHILE socket
	LOOP WHILE socket
	
	RETURN $$TRUE
END FUNCTION
	
FUNCTION MessagePump (socket, str$)
	STATIC oldstr$
	
	p = 0
	IF oldstr$ THEN str$ = oldstr$ + str$

	DO
		char = str${p}
		SELECT CASE char
			CASE 0x0D		:
			CASE 0x0A		:ProcessCommands (socket, LTRIM$(trim (cmd$,0)))
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
	LOOP UNTIL (p-1 >= LEN (str$))
	
END FUNCTION

FUNCTION Initialize ()
	WSADATA wsadata

	version = 2 OR (2 << 8)								' version winsock v2.2 (MAKEWORD (2,2))
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	
	IF ret THEN
		CPrint (idx,"* WSAStartup error: "+STRING$(WSAGetLastError()))
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		CPrint (idx,"* WSAStartup error: "+STRING$(WSAGetLastError()))
		WSACleanup ()
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION STRING localIp ()

	name$ = NULL$(256)
	gethostname (&name$,255)
	GetIPAddr (name$, @ip$)	

	RETURN  ip$
END FUNCTION

FUNCTION GetIPAddr (IPName$, @numIPAddr$)
	WSADATA wsadata
	HOSTENT	host

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
	
	RETURN $$TRUE
END FUNCTION


FUNCTION GetIPName (numIPAddr$, @IPName$)
	WSADATA wsadata
	HOSTENT	host

	addr = inet_addr (&numIPAddr$)
	host = gethostbyaddr (&addr, 4, $$AF_INET)

	IF host.h_name <> 0 THEN
		IPName$ = NULL$ (512)
		RtlMoveMemory (&IPName$, host.h_name, LEN(IPName$))
		IPName$ = CSIZE$ (IPName$)
	END IF

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

FUNCTION GetToken (str$, msg$, term)

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
	RETURN $$TRUE
END FUNCTION
'
' ######################
' #####  SendMail  #####
' ######################
'
' Send SMTP mail. Return -1 on sucess, 0 on error.
'
FUNCTION SendMail (from$, fromName$, to$, date$, subject$, body$, server$)

	SHARED socket

	IFF Initialize () THEN
		CPrint (0, "* unable to Initialize client")
		RETURN $$FALSE
	END IF

	port = 25
	time = 600	' server reply wait time in ms	
		
	socket = ConnectToServer (server$, port)
	IFZ socket THEN
		Shutdown ()
		RETURN $$FALSE
	END IF

	Sleep (time)
	SendSMessage (socket, "HELO " + localIp())
	Sleep (time)
	
	SendSMessage (socket, "MAIL FROM: <" + from$ + ">")
	Sleep (time)
		
	SendSMessage (socket, "RCPT TO: <" + to$ + ">")
	Sleep (time)
	
	SendSMessage (socket, "DATA")
	Sleep (time)

	SendSMessage (socket, "Date: " + date$)
	SendSMessage (socket, "To: <" + to$ + ">")
	SendSMessage (socket, "From: " + fromName$)
	SendSMessage (socket, "Sender: " + from$)
	SendSMessage (socket, "Reply-To: <" + from$ + ">")
	SendSMessage (socket, "Subject: " + subject$)
	SendSMessage (socket, body$)
	SendSMessage (socket, ".")
	Sleep (time)
	
	SendSMessage (socket, "QUIT")
	Sleep (time)

	Shutdown ()
	RETURN $$TRUE

END FUNCTION
'
' ##########################
' #####  GetTimeStamp  #####
' ##########################
'
'
'
FUNCTION GetTimeStamp (date$)

SYSTEMTIME systime

	GetSystemTime (&systime)

	format$ = "ddd',' dd MMM yyyy"
	d$ = NULL$(24)
	err = GetDateFormatA (NULL, NULL, &systime, &format$, &d$,	LEN(d$))
'	IFZ err THEN
'		error = GetLastError()
'		XstSystemErrorNumberToName(error, @sysError$)
'		PRINT sysError$
'	END IF
	d$ = CSIZE$(d$)

	format$ = "HH':'mm':'ss tt"
	t$ = NULL$(24)
	GetTimeFormatA (NULL, $$TIME_FORCE24HOURFORMAT, &systime, &format$, &t$, LEN(t$))
	t$ = CSIZE$(t$)
	
	date$ = d$ + " " + t$

END FUNCTION

END PROGRAM

