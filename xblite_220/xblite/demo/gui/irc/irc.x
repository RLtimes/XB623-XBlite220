'
' a multi server irc client.

' irc backend by Michael McElligott.
' gui frontend taken from edit.x by David Szafranski (DS).
' 
' 

' Michael McElligott
'   Mapei_@hotmail.com
'
' 7nd of June 2003
'
'
'	"/server serverAddr port nickname password   - joins a server
'	"/server                - join default server using defaults - **recommended**
'	"/nick alias            - set and change nickname
'	"/join #chan password   - join a channel, channel names must begin with #
'	"/serv                  - view current active server connection
'	"/serv list             - list all active server connections
'	"/serv n                - n = server number, set active server to n
'	"/chn                   - view active channel
'	"/chan list             - list all joined channels
'	"/chan #channel         - set #channel as active channel, must have prejoined this channel first"
'	"/partc #channel        - leave this channel"
'	"/parts	n               - leave this server, n = server number"
'	"/url list              - list all filtered url's"
'	"/url n                 - open url n in browser"
' "/exit                  - exit server and client program"

'	check 'ProcessClientCmd ()' for other commands

PROGRAM	"irc"
VERSION	"0.0003"

	IMPORT	"xst"
	IMPORT	"xsx"
	IMPORT	"xio"

	IMPORT	"wsock32"
	IMPORT	"kernel32"
	IMPORT	"gdi32"
	IMPORT  "user32"
	IMPORT  "shell32"
	IMPORT  "irc.dec"

DECLARE FUNCTION Entry ()
DECLARE FUNCTION Initialize ()
DECLARE FUNCTION InitGUIsubsystem ()

DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, titleBar$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CreateCallbacks ()
DECLARE FUNCTION  EditProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  InitConsole ()

DECLARE FUNCTION GetIPName (numIPAddr$, @IPName$)
DECLARE FUNCTION GetIPAddr (IPName$, @numIPAddr$)
DECLARE FUNCTION GetError ()

DECLARE FUNCTION sConnect (idx)
DECLARE FUNCTION sBind (socket,ipaddress$,port)
DECLARE FUNCTION sListen (idx)
DECLARE FUNCTION sOpen (socket)
DECLARE FUNCTION sClose (socket)
DECLARE FUNCTION sMessageListen (idx)

DECLARE FUNCTION OpenSConnection (idx)
DECLARE FUNCTION AuthSConnection (idx)
DECLARE FUNCTION CloseSConnection (idx)

DECLARE FUNCTION SendSMessage (idx,buffer$)
DECLARE FUNCTION SendSMsg (idx,buffer$)
DECLARE FUNCTION SendSNotice (idx,buffer$)
DECLARE FUNCTION SendSAction (idx,buffer$)

DECLARE FUNCTION GetMessage (str$,msg$,remaining$)
DECLARE FUNCTION GetNextToken (str$,msg$,remaining$)
DECLARE FUNCTION GetTokens (str$,v1$,v2$,v3$,v4$,v5$)
DECLARE FUNCTION GetToken (str$,msg$,remianing$,term)

DECLARE FUNCTION MessagePump (idx,str$)
DECLARE FUNCTION ProcessCommands (idx,str$)
DECLARE FUNCTION ProcessSMessage (idx,str$)
DECLARE FUNCTION ProcessClientText (idx,str$)
DECLARE FUNCTION ProcessClientCmd (idx,cmd$,msg$)
DECLARE FUNCTION ProcessServerNumeric (idx,numeric,msg$)
DECLARE FUNCTION ProcessCMessage (idx,from$,fromip$,cmd$,msg$)

DECLARE FUNCTION DisconnectServer (idx)
DECLARE FUNCTION Shutdown (msg$)
DECLARE FUNCTION ShutdownFast (msg$)
DECLARE FUNCTION JoinChannel (idx,channel$)
DECLARE FUNCTION PartChannel (idx,channel$)
DECLARE FUNCTION JoinServer (idx,server$)
DECLARE FUNCTION PartServer (idx,msg$)

DECLARE FUNCTION SetChannelMode (idx,mode$)
DECLARE FUNCTION SetChannelTopic (idx,topic$)
DECLARE FUNCTION SetNick (idx,msg$)
DECLARE FUNCTION UserKick (idx,msg$)

DECLARE FUNCTION OnError (idx,STRING)
DECLARE FUNCTION OnPing (idx,STRING)
DECLARE FUNCTION OnNotice (idx,STRING)

DECLARE FUNCTION STRING error (error)
DECLARE FUNCTION wprint (STRING text)
DECLARE FUNCTION IrcLog (text$,filename$)

DECLARE FUNCTION ClientMsg  (idx,from$,to$,msg$)
DECLARE FUNCTION ClientPart (idx,user$,chn$,msg$)
DECLARE FUNCTION ClientJoin (idx,user$,ip$,chn$)
DECLARE FUNCTION ClientQuit (idx,user$,ip$,msg$)
DECLARE FUNCTION ClientMode (idx,from$,chn$,mode$,to$,msg$)
DECLARE FUNCTION ClientNotice (idx,from$,to$,msg$)
DECLARE FUNCTION ClientNick (idx,from$,to$)
DECLARE FUNCTION ClientTopic (idx,from$,chn$,topic$)
DECLARE FUNCTION ClientInvite (idx,from$,who$,chn$)
DECLARE FUNCTION ClientKick (idx,from$,chn$,who$,msg$)

DECLARE FUNCTION SPrint	(STRING text)
DECLARE FUNCTION CPrint (idx,STRING text)
DECLARE FUNCTION EPrint (STRING text)

DECLARE FUNCTION STRING trim (str$,char)
DECLARE FUNCTION filterMessage (message$,text$,action)
DECLARE FUNCTION filterFind (message$,text$,start)
DECLARE FUNCTION filterMirc (text$)

DECLARE FUNCTION urlCatch (url$)
DECLARE FUNCTION urlOpen (url$)
DECLARE FUNCTION urlList (listfrom)
DECLARE FUNCTION LaunchBrowser (url$)

DECLARE FUNCTION chanList (idx,msg$)
DECLARE FUNCTION serverList (idx,msg$)
DECLARE FUNCTION serverSet (idx,msg$)

DECLARE FUNCTION newSProfile ()
DECLARE FUNCTION setSPServer (idx,STRING server,port,STRING password,socket)
DECLARE FUNCTION getSPServer (idx,STRING address,port,STRING password,socket)
DECLARE FUNCTION setSPClient (idx,STRING alias,STRING hostid,STRING cinfo,STRING alias2)
DECLARE FUNCTION getSPClient (idx,STRING alias,STRING hostid,STRING cinfo,STRING alias2)
DECLARE FUNCTION setSPChan   (idx,cidx,STRING channel,STRING password,STRING topic)
DECLARE FUNCTION getSPChan   (idx,cidx,STRING channel,STRING password,STRING topic)
DECLARE FUNCTION setSPAChan  (idx,STRING channel)
DECLARE FUNCTION setSPuser   (idx,STRING alias)
DECLARE FUNCTION STRING getSPAChan (idx)
DECLARE FUNCTION STRING getSPuser (idx)
DECLARE FUNCTION STRING getSPuseralt (idx)
DECLARE FUNCTION getSPactive (idx)
DECLARE FUNCTION setSPinactive (idx)
DECLARE FUNCTION setSPthreadid (idx,tid)
DECLARE FUNCTION getSPthreadid (idx)
DECLARE FUNCTION setSPtopic (idx,STRING chn, STRING topic)
DECLARE FUNCTION getSPtopic (idx,STRING chn, STRING topic)
DECLARE FUNCTION DisplayCommands ()

' Edit box return message
$$EDITBOX_RETURN = 402
'Control IDs
'$$Edit1  = 101
$$Edit2  = 102
'$$Edit3  = 103
'$$Edit4  = 104
'$$Edit5  = 105
'$$Button1 = 120

$$MAX_LBUFFER = 511			' socket recv buffer size


FUNCTION  Entry ()

	' will later acquire these from a config file/option window
	#cinfo$ 	= "a multi server irc client written in xblite"		' general client info/comment/real name
	#hostid$ 	= "xbhello"								' hostid@...
	#server$ 	= "irc.quakenet.org" 			' "130.240.22.202" or try "irc.prison.net"
	#port 		= 6667										' default port
	#nick$ 		= "xbnonick"							' default nickname
	#arejoin 	= $$TRUE									' auto rejoin channel when kicked
	
	' todo: add an option to enable/disable each of the following.
'	#slog$ = "c:\\xblite\\irc\\sirc.log"		' all incomming [server] strings are logged here
'	#clog$ = "c:\\xblite\\irc\\circ.log"		' all output text as viewed by client
'	#elog$ = "c:\\xblite\\irc\\eirc.log"		' error log and junk
'	#urllog$ = "c:\\xblite\\irc\\urlirc.log"	' url catcher log
	
	#slog$ = "sirc.log"			' all incomming [server] strings are logged here
	#clog$ = "circ.log"			' all output text as viewed by client
	#elog$ = "eirc.log"			' error log and junk
	#urllog$ = "urlirc.log"	' url catcher log

	#cserver = 0						' current server idx which edit control sends to
	
	InitConsole ()					' create console, if console is not wanted, comment out this line

	IFF Initialize () THEN
		EPrint (error($$ER_INITFAILURE))
		RETURN $$FALSE
	END IF
	
	DisplayCommands ()

	InitGUIsubsystem ()
	Shutdown ("")
	
	RETURN $$TRUE

END FUNCTION

FUNCTION setSPinactive (idx)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	'IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	
	sprofile[idx].active = $$FALSE
	RETURN $$TRUE
	
END FUNCTION

FUNCTION getSPthreadid (idx)
	SHARED TSPROFILE sprofile[]


	IF idx > UBOUND(sprofile[]) THEN RETURN 0
	IFF sprofile[idx].active THEN RETURN 0		' error flag here
	
	RETURN sprofile[idx].server.threadid
	
END FUNCTION

FUNCTION setSPthreadid (idx,tid)
	SHARED TSPROFILE sprofile[]


	IFZ tid THEN RETURN $$FALSE
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	
	sprofile[idx].server.threadid = tid
	RETURN $$TRUE
	
END FUNCTION

	
FUNCTION getSPactive (idx)
	SHARED TSPROFILE sprofile[]
	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	RETURN sprofile[idx].active
	
END FUNCTION


FUNCTION STRING getSPAChan (idx)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN ""
	IFF sprofile[idx].active THEN RETURN ""		' error flag here
	
	RETURN sprofile[idx].chan.channel[sprofile[idx].client.achan]
	
END FUNCTION

FUNCTION setSPuser (idx,STRING alias)
	SHARED TSPROFILE sprofile[]
	
	
	IFZ alias THEN RETURN $$FALSE
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here

	sprofile[idx].client.alias = alias
	RETURN $$TRUE

END FUNCTION

FUNCTION STRING getSPuseralt (idx)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN ""
	IFF sprofile[idx].active THEN RETURN ""		' error flag here

	RETURN sprofile[idx].client.alias2

END FUNCTION

FUNCTION STRING getSPuser (idx)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN ""
	IFF sprofile[idx].active THEN RETURN ""		' error flag here

	RETURN sprofile[idx].client.alias

END FUNCTION

FUNCTION newSProfile ()
	SHARED TSPROFILE sprofile[]
	
	
	IFZ sprofile[] THEN
		DIM sprofile[0]
		FOR i = 0 TO UBOUND(sprofile[])
			sprofile[i].active = $$FALSE
		NEXT i
	END IF

	FOR i = 0 TO UBOUND(sprofile[])
		IFF sprofile[i].active THEN
			RtlZeroMemory (&sprofile[i], SIZE(TSPROFILE))
			
			sprofile[i].active = $$TRUE
			sprofile[i].server.status = $$SST_NOCONNECTION
			
			RETURN i
		END IF
	NEXT i

	i = UBOUND(sprofile[]) + 1
	REDIM sprofile[i+1]
	
	FOR x = i TO UBOUND(sprofile[])
		sprofile[x].active = $$FALSE
	NEXT x
	
	' not really required but its neater
	FOR x = i TO UBOUND(sprofile[])
		IFF sprofile[x].active THEN
			RtlZeroMemory (&sprofile[x], SIZE(TSPROFILE))
			
			sprofile[x].active = $$TRUE
			sprofile[x].server.status = $$SST_NOCONNECTION
			
			RETURN x
		END IF
	NEXT x

	' should never reach this point
	EPrint ("-- newSProfile () : unable to create new profile")
	RETURN -1
	
END FUNCTION

FUNCTION setSPServer (idx,STRING server,port,STRING password,socket)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	
	IF server THEN sprofile[idx].server.addressb = server
	IF port THEN sprofile[idx].server.port = port
	IF password THEN sprofile[idx].server.password = password
	IF socket THEN sprofile[idx].server.socket = socket
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION getSPServer (idx,STRING server,port,STRING password,socket)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	
	server = sprofile[idx].server.addressb
	port = sprofile[idx].server.port
	password = sprofile[idx].server.password
	socket = sprofile[idx].server.socket
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION getSPClient (idx,STRING alias,STRING hostid,STRING cinfo,STRING alias2)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	
	
	alias = sprofile[idx].client.alias
	hostid = sprofile[idx].client.hostid
	cinfo = sprofile[idx].client.cinfo
	alias2 = sprofile[idx].client.alias2
	
	RETURN $$TRUE
		
END FUNCTION

FUNCTION setSPClient (idx,STRING alias,STRING hostid,STRING cinfo,STRING alias2)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here

	IF alias THEN sprofile[idx].client.alias = alias
	IF hostid THEN sprofile[idx].client.hostid = hostid
	IF cinfo THEN sprofile[idx].client.cinfo = cinfo
	IF alias2 THEN sprofile[idx].client.alias2 = alias2
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION getSPChan (idx,cidx,STRING channel,STRING password,STRING topic)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	IF cidx > $$SP_chanMax THEN RETURN $$FALSE
	IFF sprofile[idx].chan.active[cidx] THEN RETURN $$FALSE

	channel = sprofile[idx].chan.channel[cidx]
	password = sprofile[idx].chan.password[cidx]
	topic = sprofile[idx].chan.topic[cidx]
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION setSPChan (idx,cidx,STRING channel,STRING password,STRING topic)
	SHARED TSPROFILE sprofile[]
	
	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	IF cidx > $$SP_chanMax THEN RETURN $$FALSE
	'IFF sprofile[idx].chan.active[cidx] THEN RETURN $$FALSE
	
	IF LEN (channel) OR LEN (password) OR LEN (topic) THEN
		sprofile[idx].chan.active[cidx] = $$TRUE
	ELSE
		'sprofile[idx].chan.active[cidx] = $$FALSE
	END IF

	IF channel THEN sprofile[idx].chan.channel[cidx] = channel
	IF password THEN sprofile[idx].chan.password[cidx] = password
	IF topic THEN sprofile[idx].chan.topic[cidx] = topic
	
	RETURN $$TRUE
		
END FUNCTION


FUNCTION getSPtopic (idx,STRING chn, STRING topic)
	SHARED TSPROFILE sprofile[]

	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	
	FOR c = 0 TO $$SP_chanMax
		IF LCASE$(sprofile[idx].chan.channel[c]) = LCASE$(chn) THEN
			topic = sprofile[idx].chan.topic[c]
			RETURN $$TRUE
		END IF
	NEXT c	
	
	RETURN $$FALSE
	
END FUNCTION


FUNCTION setSPtopic (idx,STRING chn, STRING topic)
	SHARED TSPROFILE sprofile[]

	
	IF idx > UBOUND(sprofile[]) THEN RETURN $$FALSE
	IFF sprofile[idx].active THEN RETURN $$FALSE		' error flag here
	
	FOR c = 0 TO $$SP_chanMax
		IF LCASE$(sprofile[idx].chan.channel[c]) = LCASE$(chn) THEN
			sprofile[idx].chan.topic[c] = topic
			RETURN $$TRUE
		END IF
	NEXT c

	RETURN $$FALSE
	
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


	' seperate server messages in to single command strings for processing
	' might be worth creating a command queue.
FUNCTION MessagePump (idx,str$)
	STATIC oldstr$
	

	p = 0
	IF oldstr$ THEN str$ = oldstr$ + str$

	DO
		char = str${p}
		
		SELECT CASE char
			CASE 0x0D		:'ProcessCommands (idx,trim (cmd$,0))
							 'cmd$ = ""
			CASE 0x0A		:ProcessCommands (idx,TRIM$(trim (cmd$,0)))
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
	
	'should never reach this point.
	
END FUNCTION

FUNCTION ProcessServerNumeric (idx,numeric,str$)
	STATIC lastnumeric
	
	
	'SPrint (":: "+STRING$(numeric)+" "+str$)
	smsg$ = ":: "+ str$

	SELECT CASE numeric
		CASE $$RPL_WELCOME				:#cserver = idx
										 getSPServer (idx,@server$,port,password$,socket)
										 CPrint (idx,"*** connected to "+server$)
										 GetToken (str$,col$,@msg$,':')
										 CPrint (idx,":: "+ msg$)
		CASE $$RPL_YOURHOST				:GetToken (str$,col$,@msg$,':')
										 CPrint (idx,":: "+ msg$)
		CASE $$RPL_CREATED				:
		CASE $$RPL_MYINFO				:
		CASE $$RPL_SINFO				:
		
		CASE $$RPL_NONE					:
		CASE $$RPL_AWAY					:
		CASE $$RPL_USERHOST				:' PRINT ":: user host:";msg$
		CASE $$RPL_ISON
		CASE $$RPL_TEXT
		CASE $$RPL_UNAWAY
		CASE $$RPL_NOWAWAY
		CASE $$RPL_WHOISUSER			:CPrint (idx,smsg$)
		CASE $$RPL_WHOISSERVER
		CASE $$RPL_WHOISOPERATOR
		CASE $$RPL_ENDOFWHOWAS
		CASE $$RPL_WHOWASUSER
		' rpl_endofwho below (315)
		CASE $$RPL_WHOISCHANOP			'redundant and not needed but reserved
		CASE $$RPL_WHOISIDLE

		CASE $$RPL_ENDOFWHOIS
		CASE $$RPL_WHOISCHANNELS
		CASE $$RPL_LISTSTART
		CASE $$RPL_LIST
		CASE $$RPL_LISTEND
		CASE $$RPL_CHANNELMODEIS
		
		CASE $$RPL_NOTOPIC			:CPrint (idx,smsg$)
		CASE $$RPL_TOPIC			:GetToken (str$,@who$,@msg$,' ')
									 GetToken (msg$,@chn$,@msg$,' ')
									 GetToken (msg$,@topic$,@msg$,'\r')
									 CPrint (idx,"*** "+chn$+" topic: "+topic$)
									 setSPtopic (idx,chn$,topic$)
		CASE $$RPL_INVITING
		CASE $$RPL_SUMMONING
		CASE $$RPL_VERSION
		CASE $$RPL_WHOREPLY
		CASE $$RPL_ENDOFWHO
		CASE $$RPL_NAMREPLY			:GetToken (str$,me$,@msg$,' ')
									 GetToken (msg$,token$,@msg$,' ')
									 GetToken (msg$,@chn$,@msg$,' ')
									 GetToken (msg$,@clients$,msg$,'\n')
									 CPrint (idx,"*** Current users in "+chn$+": "+clients$)
		CASE $$RPL_ENDOFNAMES		:CPrint (idx,"***..........")
		CASE $$RPL_KILLDONE
		CASE $$RPL_CLOSING			:CPrint (idx,smsg$)
		CASE $$RPL_CLOSEEND
		CASE $$RPL_LINKS
		CASE $$RPL_ENDOFLINKS
 		' rpl_endofnames above (366) 
		CASE $$RPL_BANLIST
		CASE $$RPL_ENDOFBANLIST
 		' rpl_endofwhowas above (369) 

		CASE $$RPL_INFO
		CASE $$RPL_MOTD
		CASE $$RPL_INFOSTART
		CASE $$RPL_ENDOFINFO
		CASE $$RPL_MOTDSTART
		CASE $$RPL_ENDOFMOTD			:IFT #ric THEN
											ProcessClientCmd (idx,"join","#ric key")
											#ric = $$FALSE
										 END IF
										' IFT #okio THEN
										' 	ProcessClientCmd (idx,"join","#byc")
										' 	#okio = $$FALSE
										' END IF
		CASE $$RPL_YOUREOPER
		CASE $$RPL_REHASHING
		CASE $$RPL_YOURESERVICE
		CASE $$RPL_MYPORTIS
		CASE $$RPL_NOTOPERANYMORE

		CASE $$RPL_TIME
		CASE $$RPL_USERSSTART
		CASE $$RPL_USERS
		CASE $$RPL_ENDOFUSERS
		CASE $$RPL_NOUSERS

		CASE $$RPL_TRACELINK
		CASE $$RPL_TRACECONNECTING
		CASE $$RPL_TRACEHANDSHAKE
		CASE $$RPL_TRACEUNKNOWN
		CASE $$RPL_TRACEOPERATOR
		CASE $$RPL_TRACEUSER
		CASE $$RPL_TRACESERVER
		CASE $$RPL_TRACESERVICE
		CASE $$RPL_TRACENEWTYPE
		CASE $$RPL_TRACECLASS
		CASE $$RPL_TRACERECONNECT

		CASE $$RPL_STATSLINKINFO
		CASE $$RPL_STATSCOMMANDS
		CASE $$RPL_STATSCLINE
		CASE $$RPL_STATSNLINE
		CASE $$RPL_STATSILINE
		CASE $$RPL_STATSKLINE
		CASE $$RPL_STATSQLINE
		CASE $$RPL_STATSYLINE
		CASE $$RPL_ENDOFSTATS

		CASE $$RPL_UMODEIS

		CASE $$RPL_SERVICEINFO
		CASE $$RPL_ENDOFSERVICES
		CASE $$RPL_SERVICE
		CASE $$RPL_SERVLIST
		CASE $$RPL_SERVLISTEND

		CASE $$RPL_STATSLLINE
		CASE $$RPL_STATSUPTIME
		CASE $$RPL_STATSOLINE
		CASE $$RPL_STATSHLINE
		CASE $$RPL_STATSSLINE
		CASE $$RPL_STATSPING
		CASE $$RPL_STATSDEFINE
		CASE $$RPL_STATSDEBUG

		CASE $$RPL_LUSERCLIENT
		CASE $$RPL_LUSEROP
		CASE $$RPL_LUSERUNKNOWN
		CASE $$RPL_LUSERCHANNELS
		CASE $$RPL_LUSERME
		CASE $$RPL_ADMINME
		CASE $$RPL_ADMINLOC1
		CASE $$RPL_ADMINLOC2
		CASE $$RPL_ADMINEMAIL

		CASE $$RPL_TRACELOG
		CASE $$RPL_TRACEEND
		
		
		CASE $$ERR_NOSUCHNICK			:CPrint (idx,smsg$)
		CASE $$ERR_NOSUCHSERVER
		CASE $$ERR_NOSUCHCHANNEL		:CPrint (idx,smsg$)
		CASE $$ERR_CANNOTSENDTOCHAN		:CPrint (idx,smsg$)
		CASE $$ERR_TOOMANYCHANNELS		:CPrint (idx,smsg$)
		CASE $$ERR_WASNOSUCHNICK
		CASE $$ERR_TOOMANYTARGETS
		CASE $$ERR_NOSUCHSERVICE
		CASE $$ERR_NOORIGIN

		CASE $$ERR_NORECIPIENT
		CASE $$ERR_NOTEXTTOSEND
		CASE $$ERR_NOTOPLEVEL
		CASE $$ERR_WILDTOPLEVEL
		CASE $$ERR_BADMASK
		CASE $$ERR_TOOMANYMATCHES

		CASE $$ERR_UNKNOWNCOMMAND		:CPrint (idx,smsg$)
		CASE $$ERR_NOMOTD
		CASE $$ERR_NOADMININFO
		CASE $$ERR_FILEERROR

		CASE $$ERR_NONICKNAMEGIVEN		:CPrint (idx,smsg$)
										 CPrint (idx,"*** trying default nick: "+ #nick$)
										 SetNick (idx,#nick$)
										 setSPuser(idx,#nick$)
		CASE $$ERR_ERRONEUSNICKNAME		:CPrint (idx,smsg$)
		CASE $$ERR_NICKNAMEINUSE		:CPrint (idx,smsg$)
										 CPrint (idx,"*** trying alt nick: "+getSPuseralt(idx))
										 SetNick (idx,getSPuseralt(idx))
										 ' todo: fix this!
		CASE $$ERR_SERVICENAMEINUSE
		CASE $$ERR_SERVICECONFUSED
		
		CASE $$ERR_NICKCOLLISION		:CPrint (idx,smsg$)
		CASE $$ERR_UNAVAILRESOURCE
 ' 		CASE $$ERR_DEAD    438  reserved for later use -krys 

		CASE $$ERR_USERNOTINCHANNEL		:CPrint (idx,smsg$)
		CASE $$ERR_NOTONCHANNEL			:CPrint (idx,smsg$)
		CASE $$ERR_USERONCHANNEL		:CPrint (idx,smsg$)
		CASE $$ERR_NOLOGIN
		CASE $$ERR_SUMMONDISABLED
		CASE $$ERR_USERSDISABLED

		CASE $$ERR_NOTREGISTERED		:CPrint (idx,smsg$)

		CASE $$ERR_NEEDMOREPARAMS
		CASE $$ERR_ALREADYREGISTRED		:CPrint (idx,smsg$)
		CASE $$ERR_NOPERMFORHOST
		CASE $$ERR_PASSWDMISMATCH		:CPrint (idx,smsg$)
		CASE $$ERR_YOUREBANNEDCREEP		:GetMessage (str$,@to$,@msg$)
										 GetMessage (msg$,@chn$,@msg$)
										 trim (@msg$,':')
										 CPrint (idx,"*** "+chn$+" "+msg$)
		CASE $$ERR_YOUWILLBEBANNED		:CPrint (idx,smsg$)
		CASE $$ERR_KEYSET				:CPrint (idx,smsg$)

		CASE $$ERR_CHANNELISFULL		:CPrint (idx,smsg$)
		CASE $$ERR_UNKNOWNMODE			:CPrint (idx,smsg$)
		CASE $$ERR_INVITEONLYCHAN		:CPrint (idx,smsg$)
		CASE $$ERR_BANNEDFROMCHAN		:GetMessage (str$,@to$,@msg$)
										 GetMessage (msg$,@chn$,@msg$)
										 trim (@msg$,':')
										 CPrint (idx,"*** "+chn$+" "+msg$)
		CASE $$ERR_BADCHANNELKEY		:CPrint (idx,smsg$)
		CASE $$ERR_BADCHANMASK
		CASE $$ERR_NOCHANMODES

		CASE $$ERR_NOPRIVILEGES
		CASE $$ERR_CHANOPRIVSNEEDED		:CPrint (idx,smsg$)
		CASE $$ERR_CANTKILLSERVER
		CASE $$ERR_RESTRICTED

		CASE $$ERR_NOOPERHOST
		CASE $$ERR_NOSERVICEHOST

		CASE $$ERR_UMODEUNKNOWNFLAG
		CASE $$ERR_USERSDONTMATCH
	
		CASE $$ERR_GLINE				:GetMessage (str$,@to$,@msg$)
										 GetMessage (msg$,@who$,@msg$)
										 text$ = "*** "+who$+" - "+msg$
										 trim (@text$,':')
										 CPrint (idx,text$)
		CASE $$ERR_GLINESTART			:GetToken (str$,to$,@msg$,' ')
										 CPrint (idx,"*** gline: "+msg$)
		CASE $$ERR_GLINEEND				:GetToken (str$,to$,@msg$,' ')
										 trim (@msg$,':')
										 CPrint (idx,"*** "+msg$)
		CASE $$ERR_JOINCHANDENIED		:GetMessage (str$,@to$,@msg$)
										 GetMessage (msg$,@chn$,@msg$)
										 trim (@msg$,':')
										 CPrint (idx,"*** ["+chn$+"] "+msg$)
	END SELECT
	
	lastnumeric = numeric
	RETURN $$TRUE

END FUNCTION

FUNCTION ProcessCMessage (idx,from$,fromip$,cmd$,str$)


	'PRINT "$$ ";from$,fromip$,cmd$,str$
	
	SELECT CASE LCASE$(cmd$)
	
		CASE "privmsg"		:GetMessage (str$,@to$,@msg$)
							 ClientMsg  (idx,from$,to$,msg$)
		CASE "part"			:GetToken (str$,@chn$,@msg$,' ')
							 GetToken (msg$,@parttxt$,msg$,'\r')
							 ClientPart (idx,from$,chn$,parttxt$)
		CASE "join" 		:GetToken (str$,@chn$,msg$,'\r')
							 ClientJoin (idx,from$,fromip$,chn$)
		CASE "quit"			:ClientQuit (idx,from$,fromip$,str$)
		CASE "mode"			:GetMessage (str$,@chn$,@msg$)
							 GetMessage (msg$,@mode$,@msg$)
							 ClientMode (idx,from$,chn$,mode$,to$,msg$)
		CASE "notice"		:GetMessage (str$,@to$,@msg$)
							 ClientNotice (idx,from$,to$,msg$)
		CASE "nick"			:GetToken (str$,@to$,msg$,'\n')
							 ClientNick (idx,from$,to$)
		CASE "topic"		:GetMessage (str$,@chn$,@topic$)
							 ClientTopic (idx,from$,chn$,topic$)
		CASE "invite"		:GetMessage (str$,@who$,@chn$)
							 ClientInvite (idx,from$,who$,chn$)
		CASE "kick"			:GetMessage (str$,@chn$,@msg$)
							 GetMessage (msg$,@who$,@msg$)
							 ClientKick (idx,from$,chn$,who$,msg$)
	END SELECT
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientMsg (idx,from$,chn$,msg$)		' /msg to 'you' or '#chan'
	STRING text


	IF chn${0}='#' THEN					' message sent to channel
		IF LEFT$(msg$,2) =":\1" THEN
		
			trim (@msg$,1)
			str$=MID$(msg$,2,LEN(msg$))
			GetToken (str$,@ctcp$,@str$,32)
			GetToken (str$,@msg$,rmsg$,'\r')
			
			trim (@msg$,0)
 			text = "* "+chn$+" "+from$+" "+msg$
		ELSE
			text = chn$+" ("+from$+") "+msg$
		END IF
	ELSE
		' is a private message to$/you
		IF LEFT$(msg$,2) =":\1" THEN
		
			trim (@msg$,1)
			str$=MID$(msg$,2,LEN(msg$))
			GetToken (str$,@ctcp$,@str$,32)
			GetToken (str$,@msg$,rmsg$,'\n')
			
			trim (@msg$,0)
			trim (@ctcp$,0)
			
			SELECT CASE UCASE$(ctcp$)
				CASE "VERSION"	:text = "* $ ctcp version request from "+from$
				CASE "PING"		:text = "* $ pinged by "+from$
				CASE "TIME"		:text = "* $ ctcp time request from "+from$
				CASE "CHAT"		:text = "* $ ctcp chat request from "+from$+" ("+msg$+")"
				CASE "PAGE"		:text = "* $ ctcp page by "+from$+" ("+msg$+")"
				CASE "USERINFO" :text = "* $ ctcp userinfo request from "+from$
				CASE "ACTION"	:text = "- * "+from$+" "+msg$
				CASE ELSE		:PRINT ctcp$;" ";msg$;" ";from$
			END SELECT

		ELSE
			text = "*"+from$+"* "+msg$
		END IF
	END IF
	
	CPrint (idx,text)
	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientPart (idx,user$,chn$,msg$)	' user$ parted chn$ leaving msg$
	SHARED TSPROFILE sprofile[]
	
	
	IF msg$ THEN
		part$=" ("+msg$+")"
	ELSE
		part$=""
	END IF
	
	trim(@chn$,0)
	
	IF user$ = getSPuser (idx) THEN
		FOR c = 0 TO $$SP_chanMax
			getSPChan (idx,c,@chan$,"","")
			
			IF chn$ = chan$ THEN
				setSPChan (idx,c,"","","")
				'channel$ = ""
			ELSE
				IF chan$ THEN
					channel$ = chan$
					sprofile[idx].client.achan = c
				END IF
			END IF
			
		NEXT c
		CPrint (idx,"*** you have left "+chn$+part$)
		
		IFZ channel$ THEN
			CPrint (idx,"*** you are no longer in a channel")
		ELSE
			IF channel$ != chn$ THEN CPrint (idx,"*** Now talking in " + channel$)
		END IF
		
	ELSE
		CPrint (idx,"*** "+user$+" has left "+chn$+part$)
	END IF

	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientJoin (idx,user$,ip$,chn$)	' user$ @ ip$ joined chn$
	SHARED TSPROFILE sprofile[]
	

	'PRINT "######",idx,user$,ip$,chn$
	IF user$ = getSPuser (idx) THEN
		CPrint (idx,"*** Now talking in "+chn$)
		FOR c = 0 TO $$SP_chanMax
			IFF sprofile[idx].chan.active[c] THEN
			
				chan$ = LEFT$(chn$,LEN (chn$)-1) +"\0"
				setSPChan (idx,c, chan$ ,"","")
				sprofile[idx].client.achan = c
				
				RETURN $$TRUE
			END IF 
		NEXT c
		EPrint ("-- unable to register channel ::  ClientJoin ()")
	ELSE
		CPrint (idx,"*** "+user$+"("+ip$+") has joined "+chn$)
		RETURN $$TRUE
	END IF
	
END FUNCTION

FUNCTION ClientQuit (idx,user$,ip$,msg$)	' user$ quit server leavng msg$


	IF msg$ THEN msg$=" ("+msg$+")"
	CPrint (idx,"*** "+user$+"("+ip$+") Quit "+chn$+msg$)

	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientMode (idx,from$,chn$,mode$,to$,msg$)		' a channel mode was set


	IF to$ = mode$ THEN to$ = ""
	CPrint (idx,"*** ("+chn$+") "+from$+" sets mode "+mode$+to$+" "+msg$)
	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientNotice (idx,user$,client$,str$)		' user$ sent notice msg$ to client$
	STRING text


	GetToken (str$,@col$,@msg$,':')
	IF col$ THEN
		text = ("-"+user$+"- "+str$)
	ELSE
		text = ("-"+user$+"- "+msg$)
	END IF
	
	CPrint (idx,text)
	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientNick (idx,user$,newnick$)		' user$ changed nick to newnick$


	user$ = TRIM$(trim(user$,32))
	newnick$ = TRIM$(trim(newnick$,32))
	
	IF user$ = getSPuser (idx) THEN
		setSPuser (idx,LEFT$(newnick$,LEN (newnick$)-1))
	END IF

	CPrint (idx,"*** "+user$+" is now known as "+newnick$)
	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientTopic (idx,user$,chn$,topic$)		' user$ set topic$ in chn$

	
	CPrint (idx,"*** "+user$+" sets "+chn$+" topic to "+topic$)
	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientInvite (idx,user$,you$,chn$)		' user$ has invited you$ to chn$


	CPrint (idx,"*** "+user$+" invites you to join "+chn$)
	RETURN $$TRUE
	
END FUNCTION

FUNCTION ClientKick (idx,user$,chn$,who$,reason$)		' who$ was kicked from chn$ by user$ with reason$
	SHARED TSPROFILE sprofile[]
	

	IF reason$ THEN
		GetToken (reason$,col$,@reason$,':')
		reason$=" ("+reason$+")"
	END IF

	trim (@chn$,0)
	
	IF who$ = getSPuser (idx) THEN
		CPrint (idx,"*** you were kicked from "+chn$+" by "+user$+reason$)

		FOR c = 0 TO $$SP_chanMax
			getSPChan (idx,c,@chan$,"","")
			IF chn$ = chan$ THEN
				setSPChan (idx,c,"","","")
				channel$ = ""
			ELSE
				IF chan$ THEN
					channel$ = chan$
					sprofile[idx].client.achan = c
				END IF
			END IF
		NEXT c	
		
		IFZ channel$ THEN
			CPrint (idx,"*** you are no longer in a channel")
		ELSE
			IF channel$ != chn$ THEN CPrint (idx,"*** Now talking in " + channel$)
		END IF
		
		' auto rejoin channel at this point
		IFT #arejoin THEN
			CPrint (idx,"*** attempting to rejoin "+chn$)
			ProcessClientCmd (idx,"join",chn$)
			'IF #channel$ THEN	' check if rejoin was successful
			'	EXIT FUNCTION
			'ELSE
			'	CPrint (idx,"*** rejoin attempt failed")
			'END IF
		END IF		
	ELSE
		CPrint (idx,"*** ("+chn$+") "+who$+" was kicked by "+user$+reason$)
	END IF
		
	RETURN $$TRUE
	
END FUNCTION

FUNCTION IrcLog (text$,filename$)

	'TODO: queue text to save upon each x amount of lines.
	' should save the hdd head a little

	IFZ filename$ THEN RETURN $$FALSE
	IFZ text$ THEN RETURN $$FALSE
	
	XstLog (text$,0,filename$)
	RETURN $$TRUE

END FUNCTION

FUNCTION ProcessCommands (idx,str$)
	UBYTE binfile[]


	'trim (@str$,0)
	SPrint (STRING$(idx)+": "+str$)
	GetMessage (str$,@cmd$,@msg$)

	SELECT CASE UCASE$(cmd$)
		CASE ":"			:ProcessSMessage (idx,msg$)
		CASE "PING"			:OnPing (idx,msg$)
		CASE "ERROR"		:OnError (idx,msg$)
		CASE "NOTICE"		:OnNotice (idx,msg$)
		CASE ELSE			:EPrint (" unprocessed :: "+str$)
	END SELECT

END FUNCTION


FUNCTION ProcessSMessage (idx,str$)
	SHARED TSPROFILE sprofile[]


	GetMessage (str$,@from$,@msg$)

	IFZ sprofile[idx].server.server THEN		' acquire server name from first notice message
		sprofile[idx].server.server = from$
	END IF
	
	server$ = sprofile[idx].server.server
	
	SELECT CASE from$
		CASE server$		:GetMessage (msg$,@numeric$,@msg$)
							 num = XLONG (numeric$)
							 IF num THEN
							 	ProcessServerNumeric (idx,num,msg$)
							 ELSE
							 	SELECT CASE LCASE$(numeric$)
							 		CASE "notice"		:GetToken (msg$,@to$,@msg$,' ')
							 							 GetToken (msg$,@message$,msg$,'\n')
							 							 ClientNotice (idx,from$,to$,message$)
							 		'CASE ELSE			:ClientNotice (from$,to$,message$)
							 	END SELECT
							 END IF
		CASE ELSE			:GetMessage (msg$,@fromip$,@msg$)
							 GetMessage (msg$,@cmd$,@msg$)
							 ProcessCMessage (idx,from$,fromip$,cmd$,msg$)
	END SELECT
	
END FUNCTION

FUNCTION ProcessClientCmd (idx,cmd$,msg$)


	msg$ = LTRIM$(msg$)
	msg$ = RTRIM$(msg$)
	'IFF getSPactive (idx) THEN
	'	idx = 9999
	'	#cserver = idx
	'END IF

	SELECT CASE LCASE$(LTRIM$(trim(cmd$,32)))
		CASE "chn"				:setSPAChan (idx,msg$)		' set active channel
		CASE "url"				:urlOpen (msg$)				' open url
		CASE "quit","exit"		:Shutdown (msg$)			' initiate client logoff then exit client
		CASE "."				:ShutdownFast (msg$)		' is the boss near?
		CASE "nick","n"			:SetNick (idx,msg$)
		CASE "join","j"			:JoinChannel (idx,msg$)
		CASE "partc","part"		:PartChannel (idx,msg$)
		CASE "server","connect"	:JoinServer  (@idx,msg$)
		CASE "me"				:SendSAction (idx,msg$)
		CASE "notice"			:SendSNotice (idx,msg$)
		CASE "msg"				:SendSMsg    (idx,msg$)
		CASE "disconn","parts"	:PartServer (idx,msg$)
		CASE "clear","cls","l"	:XioClearConsole (XioGetStdOut())
		CASE "help"				:' display general application usage
		CASE "showcommands"		:' display command list
		CASE "op"				:SetChannelMode (idx,"+o "+msg$)' give user ops
		CASE "deop","unop"		:SetChannelMode (idx,"-o "+msg$)' remove users op
		CASE "voice"			:SetChannelMode (idx,"+v "+msg$)' give user voice
		CASE "devoice","unvoice":SetChannelMode (idx,"-v "+msg$)' remove users voice		
		CASE "mute"				:SetChannelMode (idx,"+m "+msg$)' mute channel
		CASE "demute","unmute"	:SetChannelMode (idx,"-m "+msg$)' remove channel mute
		CASE "setkey"			:SetChannelMode (idx,"+k "+msg$)' set channel password
		CASE "removekey"		:SetChannelMode (idx,"-k "+msg$)' remove channel password
		CASE "secret"			:SetChannelMode (idx,"+s "+msg$)' hide channel from whois replies,etc..
		CASE "unsecret"			:SetChannelMode (idx,"-s "+msg$)' unhide channel
		CASE "limit"			:SetChannelMode (idx,"+l "+msg$)' restrict channel to x users
		CASE "unlimit"			:SetChannelMode (idx,"-l "+msg$)' unrestrict user count for channel
		CASE "invite","in"		:SetChannelMode (idx,"+i "+msg$)' entry to channel is via invite only
		CASE "uninvite","unin"	:SetChannelMode (idx,"-i "+msg$)' remove invite only from channel
		CASE "ban"				:SetChannelMode (idx,"+b "+msg$)' ban user from channel
		CASE "unban"			:SetChannelMode (idx,"-b "+msg$)' remove ban from channel
		CASE "bankick","bk"		:SetChannelMode (idx,"+b "+msg$)' ban then kick user from channel
								 UserKick (idx,msg$)
		CASE "topic"			:SetChannelTopic (idx,msg$)		' set channel topic
		CASE "kick"				:UserKick (idx,msg$)			' kick user from channel
		CASE "redo"				:' redo last command action. eg, redo will ban last unban.
		CASE "undo"				:' undo last command action. eg, undo will unban last ban. 								 

		CASE "serv"				:serverSet (idx,msg$)
		CASE ELSE				:'IFT getSPactive (idx) THEN
									SendSMessage(idx,cmd$+" "+msg$)
								 'ELSE
								 '	CPrint (idx,"*** not connected")
								 'END IF
	END SELECT
	
END FUNCTION

FUNCTION serverSet (idx,msg$)


	msg$ = TRIM$(trim(msg$,32))

	IF msg$ = LCASE$("list") THEN
		serverList (idx,msg$)
		RETURN $$TRUE
	END IF	
	
	IF msg$ THEN
		ser = XLONG (msg$)
		IFT getSPactive (ser) THEN
			#cserver = ser
		ELSE
			CPrint (idx,"*** server number invalid")
			RETURN $$FALSE
		END IF
	END IF
	
	getSPServer (#cserver,@server$,port, password$,socket)
	CPrint (#cserver,"*** active server set to "+STRING$(#cserver)+": "+server$)

	RETURN $$TRUE
	
END FUNCTION

FUNCTION serverList (idx,msg$)
	SHARED TSPROFILE sprofile[]


	cflag = $$FALSE
	FOR s = 0 TO UBOUND (sprofile[])
		IFT getSPactive (s) THEN
			getSPServer (s,@server$,port, password$,socket)
			CPrint (idx,"*** connected to "+STRING$(s)+": "+server$+" as "+getSPuser(s))
			cflag = $$TRUE
		END IF
	NEXT s

	IFT cflag THEN
		getSPServer (#cserver,@server$,port, password$,socket)
		CPrint (idx,"*** active server set to "+STRING$(#cserver)+": "+server$)
	ELSE
		CPrint (idx,"*** not currently connected")	
	END IF
	
	RETURN $$TRUE

END FUNCTION

FUNCTION PartServer (idx,msg$)
	SHARED TSPROFILE sprofile[]
	

	msg$ = TRIM$(trim(msg$,32))
	IF LCASE$(msg$) = "all" THEN
		FOR s = 0 TO UBOUND (sprofile[])
			IFT getSPactive (s) THEN DisconnectServer (s)
		NEXT s
		#cserver = 9999
		RETURN $$TRUE
	END IF
	
	IFZ msg$ THEN
		DisconnectServer (idx)
	ELSE
		DisconnectServer (XLONG(msg$))
	END IF
	
	FOR s = 0 TO UBOUND (sprofile[])
		IFT getSPactive (s) THEN
			#cserver = s
			RETURN $$TRUE
		END IF
	NEXT s

	#cserver = 9999
	CPrint (idx,"*** no current server connection")	
	RETURN $$TRUE
	
END FUNCTION


FUNCTION chanList (idx,msg$)


	IFZ msg$ THEN RETURN $$FALSE

	channel$ = "Current channels:"
	FOR c = 0 TO $$SP_chanMax
		IFT getSPChan (idx,c,@chn$,"","") THEN
			channel$ = channel$ +" "+ chn$
		END IF
	NEXT c
	
	CPrint (idx,"*** "+channel$)
	RETURN $$TRUE

END FUNCTION

FUNCTION setSPAChan (idx,chn$)
	SHARED TSPROFILE sprofile[]


	trim (@chn$,32)
	
	IFZ chn$ THEN
		CPrint (idx,"*** active channel set to "+getSPAChan (idx))
		RETURN $$TRUE
	END IF
	
	IF LCASE$(TRIM$(trim(chn$,32))) = "list" THEN
		chanList (idx,chn$)
		RETURN $$TRUE
	ELSE
		IF chn${0}!='#' THEN chn$ = "#"+chn$
	END IF
		
	FOR c = 0 TO $$SP_chanMax
		getSPChan (idx,c,@channel$,"","")
		IF TRIM$(chn$) = TRIM$(channel$) THEN
			sprofile[idx].client.achan = c
			CPrint (idx,"*** active channel set to "+chn$)
			RETURN $$TRUE
		END IF
	NEXT c

	CPrint (idx,"*** "+chn$+" - not in channel")
	RETURN $$FALSE
		
END FUNCTION

FUNCTION urlList (url)
	SHARED urllog$[]


	IF url > UBOUND (urllog$[]) THEN RETURN $$FALSE
	FOR u = url TO UBOUND (urllog$[])
		IF urllog$[u] THEN
			text$ = "*** url "+STRING$(u)+": "+urllog$[u]
			PRINT text$ 
			IrcLog (text$,#clog$)
		END IF
	NEXT u
	
	RETURN $$TRUE
		
END FUNCTION

FUNCTION urlOpen (url$)
	SHARED urllog$[]

	
	url$ = TRIM$(trim(url$,32))
	IF LCASE$(url$) = "list" THEN
		urlList (XLONG(msg$))
		RETURN $$TRUE
	END IF
	
	IF LEN (url$) < 6 THEN
		url = XLONG(url$)
		IF url > UBOUND (urllog$[]) THEN RETURN $$FALSE
		IFZ urllog$[url] THEN RETURN $$FALSE
		
		url$ = urllog$[url]
		text$ = "*** opening url "+STRING$(url)+" - "+url$
	ELSE
		text$ = "*** opening url "+url$
	END IF
	
	PRINT text$ 
	IrcLog (text$,#clog$)
	LaunchBrowser (url$)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION LaunchBrowser (url$)		' function taken from 'launchbrowser' by D.S.
	STATIC defBrowserExe$
	
	
	IFZ defBrowserExe$ THEN										' first, create a known, temporary HTML file
		defBrowserExe$ = NULL$ (256)							' create default browser path string
		file$ = "temphtm.htm"									' temp html file
		s$ = "<HTML> <\HTML>"									' html string

		of = OPEN (file$, $$RW)									' open temp html file
		WRITE [of], s$											' write string to file
		CLOSE (of)												' close file

		ret = FindExecutableA (&file$, NULL, &defBrowserExe$)	' find executable
		defBrowserExe$ = CSIZE$ (defBrowserExe$)
		DeleteFileA (&file$)									' delete temp file
		
		IF (ret <= 32) || (defBrowserExe$ = "") THEN
			EPrint (error($$ER_NOBROWSER))
			RETURN $$FALSE
		END IF
	END IF

	ret = ShellExecuteA (NULL, &"open", &defBrowserExe$, &url$, NULL, $$SW_SHOWNORMAL)
	IF url$ THEN
		IF ret <= 32 THEN
			EPrint (error($$ER_NOURLPAGE))
			RETURN $$FALSE
		END IF
	END IF
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION STRING error (errornum)

	SELECT CASE errornum
		CASE  $$ER_NOCONNECTION		: text$ = "*** not connected"
		CASE  $$ER_NOTINCHANNEL		: text$ = "*** not in channel"
		CASE  $$ER_CONNECTED		: text$ = "-- join server error :: already connected, disconnect first"
		CASE  $$ER_CONNECTFAILURE	: text$ = "-- join server error :: unable to connect to server"
		CASE  $$ER_INVALIDADDRESS	: text$ = "-- unable to connect to server address"
		CASE  $$ER_AUTHNOCONNECT	: text$ = "-- auth server error :: not connected"
		CASE  $$ER_WSASTARTUPFAIL	: text$ = "-- WSA startup error :: unable to initialize"
		CASE  $$ER_WSANOWINSOCK		: text$ = "-- WSA startup error :: unsupported winsock version"
		CASE  $$ER_WSANOTINITILIZED	: text$ = "-- WSA startup error :: not initilized"
		CASE  $$ER_INITFAILURE		: text$ = "-- start up error :: unable to initialize client"
		CASE  $$ER_NOBROWSER		: text$ = "-- url error : could not find associated browser"
		CASE  $$ER_NOURLPAGE		: text$ = "-- url error : unable to open url"
		CASE ELSE					: text$ = "my poor programming has led you to read message"
	END SELECT
	
	RETURN text$
	
END FUNCTION

FUNCTION SPrint	(STRING text)

	IFZ text THEN RETURN $$FALSE
	
	trim (@text,0)
	'PRINT text
	IrcLog (text,#slog$)
	RETURN $$TRUE

END FUNCTION

FUNCTION CPrint (idx,STRING text) 	' text sent to client


	IFZ text THEN RETURN $$FALSE
	
' TODO: add mirc and url filter on/off option
	filterMirc (@text)
	filterMessage (text,"http://",1)
	filterMessage (text,"www.",1)
	filterMessage (text,"ftp://",1)
	filterMessage (text,"ftp.",1)
	
	trim (@text,0)
	'text = TRIM$ (text)

'	XstStdio (@hStdIn, @hStdOut, @hStdErr)'
'	curx = 11 										' 12 characters from left
'	cury = 14 										' 15 lines down
'	pos = MAKELONG (curx, cury)
'	ret = SetConsoleCursorPosition (hStdOut, pos)	' move cursor to location
'	XstWriteConsole (@"12 across, 15 down. \n \n")	

	text = STRING$(idx)+": "+text
	
	PRINT text
	IrcLog (text,#clog$)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION EPrint (STRING text)

	IFZ text THEN RETURN $$FALSE
	
	trim (@text,0)
	PRINT text
	IrcLog (text,#elog$)
	RETURN $$TRUE

END FUNCTION

FUNCTION filterMirc (text$)

	
	newtext$ = ""
	FOR c = 0 TO LEN(text$)
	
		char = text${c}

		SELECT CASE char
			CASE 0x01		:
			CASE 0x01		:
			CASE 0x02		:
			CASE 0x03		:INC c
							 char = XLONG (text${c+1})
							 IF ((char > 47) AND (char < 58)) THEN INC c
			CASE 0x1F		:
			CASE 0x16		:
			CASE ELSE		:newtext$ = newtext$ + CHR$(char)
		END SELECT
	NEXT c
	
	text$ = newtext$
	RETURN $$TRUE

END FUNCTION

FUNCTION urlCatch (url$)
	SHARED urllog$[]
	STATIC count


	IFZ url$ THEN RETURN $$FALSE
	IFZ count THEN
		DIM urllog$[10]
	ELSE
		IF count >= UBOUND(urllog$[]) THEN
			REDIM urllog$[count+10]
		END IF
	END IF
	
	IF LEFT$(url$,4) = "www." THEN url$ = "http://" + url$
	IF LEFT$(url$,4) = "ftp." THEN url$ = "ftp://" + url$

	FOR u = 0 TO count
		IF url$ = urllog$[u] THEN
			' do not log
			'PRINT "type '/url ";u;"' to open ";url$
			RETURN $$TRUE
		END IF
	NEXT u
	
	urllog$[count] = url$

	PRINT "*** url ";count;": ";url$
	IrcLog (url$,#urllog$)
	
	INC count
	RETURN $$TRUE
	
END FUNCTION


FUNCTION filterMessage (message$,text$,action)

	
	start = 1
	DO 
		IFT filterFind (message$,text$,@start) THEN
			' text found
			
			SELECT CASE action
				CASE 1			:GetToken (RIGHT$ (message$,LEN(message$)-start+1),@url$,else$,' ')
								 trim (@url$,0)
								 urlCatch (url$)
				CASE 2			:			' remove text
				CASE 3			:			' replace text with 'space' or '*'
				CASE 4			:			' highlight text?
				CASE 5			:			' append text?
				CASE ELSE		:			' mark as found - notify?
			END SELECT
			
			start = start + LEN(text$)
		ELSE
			' text no longer found
			start = -1
		END IF
	LOOP WHILE (start != -1)
	

END FUNCTION

FUNCTION filterFind (message$,text$,start)


	IFZ text$ THEN RETURN $$FALSE
	IFZ message$ THEN RETURN $$FALSE
	sizet = LEN(text$)
	sizem = LEN(message$)
	IF (start+size) > sizem THEN RETURN $$FALSE
	IF sizet > sizem THEN RETURN $$FALSE
	
	FOR p = start TO sizem-sizet
		msg$ = MID$(message$,p,sizet)
		IF msg$ = text$ THEN
			start = p
			RETURN $$TRUE
		END IF
	NEXT p

	start = -1
	RETURN $$FALSE

END FUNCTION


FUNCTION wprint (STRING text)
	SHARED winh,winw,charh
	STATIC msglog$[]
	STATIC firstline,lastline,ltotal
	RECT rc

	
	'IrcLog (text,#clog$)
	RETURN $$FALSE
	
	trim (@text,0)
	PRINT text
	RETURN $$FALSE
	
	IFZ text THEN RETURN $$FALSE
	
	IFZ msglog$[] THEN
		DIM msglog$[100]
		firstline = 0
		lastline = 0
		charh = 18
		ltotal = ((winh-45)/(charh))-1
	ELSE
		INC lastline
		IF lastline > UBOUND (msglog$[]) THEN REDIM msglog$[lastline+100]
		IF lastline > ltotal THEN INC firstline
	END IF

	msglog$[lastline] = text
	hwnd = #winMain
	hdc = GetDC (hwnd)
	GetClientRect (hwnd, &rc)

	PatBlt (hdc, 0, 0, rc.right, rc.bottom-45, $$PATCOPY)
	
	FOR pos = firstline TO lastline
		charposh = (pos-firstline) * charh
		TextOutA (hdc, 1, charposh,&msglog$[pos], LEN (msglog$[pos]))
		'PRINT msglog$[pos]
	NEXT pos

	ReleaseDC (hwnd, hdc)
	
	RETURN $$TRUE
	
END FUNCTION


FUNCTION SetNick (idx,nick$)



	IFT getSPactive (idx) THEN
		nick$ = TRIM$(trim(nick$,32))
		SendSMessage(idx,"NICK "+nick$)
		RETURN $$TRUE
	ELSE 
		CPrint (idx,error($$ER_NOCONNECTION))
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION UserKick (idx,user$)


	IFT getSPactive (idx) THEN	
		IF getSPAChan (idx) THEN
			SendSMessage(idx,"KICK "+getSPAChan (idx)+" "+user$)
			RETURN $$TRUE
		ELSE
			CPrint (idx,error($$ER_NOTINCHANNEL))
			RETURN $$FALSE
		END IF
	ELSE
		CPrint (idx,error($$ER_NOCONNECTION))
		RETURN $$FALSE
	END IF
	
END FUNCTION

FUNCTION SetChannelTopic (idx,topic$)


	IFT getSPactive (idx) THEN	
		IF getSPAChan (idx) THEN
			SendSMessage(idx,"TOPIC "+getSPAChan (idx)+" :"+topic$)
			RETURN $$TRUE
		ELSE
			CPrint (idx,error($$ER_NOTINCHANNEL))
			RETURN $$FALSE
		END IF
	ELSE
		CPrint (idx,error($$ER_NOCONNECTION))
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION SetChannelMode (idx,mode$)


	IFT getSPactive (idx) THEN	
		IF getSPAChan (idx) THEN
			SendSMessage(idx,"MODE "+getSPAChan (idx)+" "+mode$)
			RETURN $$TRUE
		ELSE
			CPrint (idx,error($$ER_NOTINCHANNEL))
			RETURN $$FALSE
		END IF
	ELSE
		CPrint (idx,error($$ER_NOCONNECTION))
		RETURN $$FALSE
	END IF

END FUNCTION


FUNCTION JoinServer (idx,str$)


	GetMessage (str$,@server$,@msg$)
	GetMessage (msg$,@port$,@msg$)
	GetMessage (msg$,@alias$,@password$)

	trim (@server$,32)
	IFZ server$ THEN server$ = #server$
	port = XLONG (port$)
	IFZ port THEN port = #port
	
	idx = newSProfile ()
	alias2$ = TRIM$(trim(alias$,0))+"-"
	setSPServer (idx, server$,port,password$,0)
	setSPClient (idx, alias$, #hostid$, #cinfo$,alias2$)
		
	CPrint (idx,"*** connecting to "+server$+":"+STRING$(port))
 
	IFT OpenSConnection (idx) THEN
		IFT AuthSConnection (idx) THEN
			setSPthreadid (idx,CreateThread (NULL, 0, &sMessageListen(), idx, 0, &tid2))
			RETURN $$TRUE
		ELSE
			' error message is supplied by AuthSConnection()
			RETURN $$FALSE
		END IF
	ELSE
		CPrint (idx,error($$ER_CONNECTFAILURE))
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION DisconnectServer (idx)


	IFF getSPactive (idx) THEN
		' error message here
		RETURN $$FALSE
	END IF

	getSPServer (idx,@server$,port,password$,socket)
	CPrint (idx,"*** disconnecting from "+server$)
		
	IFZ msg$ THEN msg$ = "I'm outa here!"	' set default exit message
	SendSMessage (idx,"QUIT :"+msg$)
	Sleep (300)								' i found if we did not sleep for around this time (~ping time reply to/from server) -
	CloseSConnection (idx)					' the quit message would not be processed by the host
	CPrint (idx,"*** "+server$+" disconnected")
		
	tid = getSPthreadid (idx)
	setSPinactive (idx)
	IF tid THEN TerminateThread (tid , 0)


	RETURN $$TRUE ' either way^ we don't have a connection

END FUNCTION

FUNCTION SendSAction (idx,str$)


	SendSMessage (idx,"privmsg "+ getSPAChan (idx) + " :\1ACTION "+str$+"\1")
	CPrint (idx,"* "+getSPAChan (idx)+" "+ getSPuser (idx)+" "+str$)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION SendSMsg (idx,str$)

	GetMessage (str$,@to$,@msg$)
	SendSMessage (idx,"privmsg "+to$+ " :"+msg$)
	CPrint (idx,"-> *"+ getSPuser (idx) +"* "+msg$)
	
	RETURN $$TRUE
END FUNCTION


FUNCTION SendSNotice (idx,str$)

	GetMessage (str$,@where$,@msg$)
	SendSMessage (idx,"notice "+ where$+ " :"+msg$)
	
	RETURN $$TRUE
END FUNCTION

FUNCTION PartChannel (idx,msg$)


	IFZ msg$ THEN RETURN $$FALSE
	GetMessage (msg$,@channel$,@pmsg$)
	IFZ pmsg$ THEN pmsg$ = "i've had enough"	' use default message if none supplied
	
	IF channel${0}!='#' THEN channel$ = "#"+channel$
	SendSMessage (idx,"PART "+channel$+" :"+pmsg$)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION JoinChannel (idx,str$)

	
	IFZ str$ THEN RETURN $$FALSE
	IF str${0}!='#' THEN str$ = "#"+str$
	SendSMessage (idx,"JOIN "+str$)

	RETURN $$TRUE
	
END FUNCTION

FUNCTION ShutdownFast (msg$)
	SHARED TSPROFILE sprofile[]	


	FOR t = 0 TO UBOUND(sprofile[])
		IFT sprofile[t].active THEN
			tid = sprofile[t].server.threadid
			IF tid THEN TerminateThread (tid, 0)
			setSPinactive (t)
		END IF
	NEXT t

	CloseSConnection (idx)
	WSACleanup ()
	QUIT (0)

END FUNCTION

FUNCTION Shutdown (msg$)
	SHARED TSPROFILE sprofile[]
	
	FOR s = 0 TO UBOUND(sprofile[])
		IFT getSPactive(s) THEN DisconnectServer (s)
	NEXT s
	
	WSACleanup ()
	QUIT (0)

END FUNCTION


FUNCTION ProcessClientText (idx,str$)


	str$ = LTRIM$(str$)
	IFZ	str$ THEN RETURN $$FALSE

	IF str${0} = '/' THEN
		GetMessage (str$,@cmd$,@msg$)
		ProcessClientCmd (idx,TRIM$ (cmd$),msg$)
		RETURN $$TRUE
	ELSE
		IFT getSPactive (idx) THEN
			chan$ = trim (getSPAChan (idx),0)
			IF chan$ THEN
				SendSMessage (idx,"privmsg "+ chan$+ " :"+str$)
				ClientMsg (idx,getSPuser(idx),chan$,":"+str$)
				RETURN $$TRUE
			ELSE
				CPrint (idx,error($$ER_NOTINCHANNEL))
				RETURN $$FALSE
			END IF
			
		ELSE
			IFF getSPactive (idx) THEN idx = 9999
			CPrint (idx,error($$ER_NOCONNECTION))
			RETURN $$FALSE
		END IF
	END IF

END FUNCTION


FUNCTION OnError (idx,str$)

	
	GetMessage (str$,@cmd$,@msg$)
	'TODO : use (add) white space message parsing
	
	SELECT CASE LCASE$(cmd$)
		CASE "closing"			:getSPServer (idx, @server$,port,password$,0)
								 CPrint (idx,"***  ping timeout by "+server$)
								 DisconnectServer (idx)
								 ' :closing link:
		CASE ELSE				:SPrint ("+++ "+str$)
								 EPrint ("+++ "+str$)
								 DisconnectServer (idx)
	END SELECT
	
	RETURN $$FALSE
	
END FUNCTION

FUNCTION OnNotice (idx,str$)

	CPrint (idx,"NOTICE "+str$)
	RETURN $$TRUE
END FUNCTION


FUNCTION OnPing (idx,str$)

	SendSMessage (idx,"PONG "+str$)
	RETURN $$TRUE
END FUNCTION

FUNCTION SendSMessage (idx,buffer$)
	SHARED TSPROFILE sprofile[]


	IFF getSPactive (idx) THEN
		CPrint (idx,error($$ER_NOCONNECTION))
		RETURN $$FALSE
	END IF
	
	buffer$ = buffer$ + "\r\n"
	IF send (sprofile[idx].server.socket, &buffer$, LEN(buffer$), 0) = -1 THEN
		EPrint ("socket send error :: -1")
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF

	
END FUNCTION


FUNCTION GetTokens (str$,v1$,v2$,v3$,v4$,v5$)	' not very useful


	GetNextToken (str$,@v1$,@msg$)
	GetNextToken (msg$,@v2$,@msg$)
	GetNextToken (msg$,@v3$,@msg$)
	GetNextToken (msg$,@v4$,@msg$)
	GetNextToken (msg$,@v5$,@msg$)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION GetNextToken (str$,cmd$,remaining$)


	GetMessage (str$,@cmd$,@remaining$)
	
	IF (cmd$ = ":") OR (cmd$ = " ") THEN
		GetMessage (remaining$,@cmd$,@remaining$)
	END IF
	
	RETURN $$TRUE

END FUNCTION

FUNCTION GetToken (str$,msg$,remaining$,term)


	IFZ str$ THEN RETURN $$FALSE
	'trim (@str$,0)
	len = LEN(str$)
	msg$=""

	FOR p = 0 TO len
	
		IF str${p} = term THEN
			INC p
			remaining$ = RIGHT$(str$,len-p)
			'trim (@msg$,0)
			'trim (@remaining$,0)				
			RETURN p
		ELSE
			IF str${0}=':' THEN
				str${0}=' '
				'trim (@msg$,0)
				'trim (@remaining$,0)				
				EXIT IF 2
			END IF
			msg$ = msg$ + CHR$(str${p})
		END IF
			
	NEXT p
	
	'trim (@msg$,0)
	'trim (@remaining$,0)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION GetMessage (str$,msg$,remaining$)		' rename function
	UBYTE char


' TODO : improve parsing for lines such as ":from to :Closing Link: (ping timeout)"

	IFZ str$ THEN RETURN $$FALSE
	'trim (@str$,0)
	len = LEN(str$)
	msg$=""
		
	FOR p = 0 TO len
		'char = str${p}
		IF str${0} = ':' THEN
			msg$ = ":"
			INC p
			remaining$ = trim(RIGHT$(str$,len-p),0)
			'trim (@msg$,0)
			'trim (@remaining$,0)
			RETURN p
		END IF

		IF str${0} = '/' THEN
			'msg$ = "/"
			str${0} = ' '
			INC p
		END IF
		
		IF (str${p} = '!') OR (str${p} = ' ') THEN
			INC p
			remaining$ = trim (RIGHT$(str$,len-p),0)
			'trim (@msg$,0)
			'trim (@remaining$,0)
			RETURN p
		ELSE
			msg$= msg$ + CHR$(str${p})
		END IF
	NEXT p
	
	'trim (@msg$,0)
	'trim (@remaining$,0)
	
	DEC p
	RETURN p
	
END FUNCTION

FUNCTION sClose (socket)

	RETURN closesocket (socket)
		' is it possible for the socket not to close?
	
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
	
	length = LEN (udtSocket)
	
	IF bind (socket, &udtSocket, length) = -1 THEN
		EPrint ("socket bind error :: -1")
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF
	
	
END FUNCTION

FUNCTION sListen (socket)

	
	IF listen (socket, 1) = -1 THEN
		EPrint ("socket listen error :: -1")
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF
		
END FUNCTION


FUNCTION sOpen (socket)


	socket = socket ($$AF_INET, $$SOCK_STREAM, 0)
	
	IFZ socket THEN
		EPrint ("open socket error :: 0")
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF
	
END FUNCTION

FUNCTION sConnect (idx)
	SOCKADDR_IN udtSocket


	getSPServer (idx,@ipaddress$,@port,password$,@socket)
	
	udtSocket.sin_family = $$AF_INET
	GetIPAddr (ipaddress$, @numIPAddr$)
	udtSocket.sin_addr = inet_addr (&numIPAddr$)
	udtSocket.sin_port = htons (port)
	
	IF (connect (socket, &udtSocket, SIZE(udtSocket)) == $$SOCKET_ERROR) THEN
		EPrint (error($$ER_INVALIDADDRESS))
		closesocket (socket)
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF

END FUNCTION

FUNCTION sMessageListen (idx)
	
	
	getSPServer (idx,ipaddress$,port,password$,@socket)
	DO
		pageBuffer$ = NULL$($$MAX_LBUFFER)
		rover = &pageBuffer$
		read = 0
		
		DO WHILE (read < $$MAX_LBUFFER)
			thisRead = recv (socket, rover, $$MAX_LBUFFER-read, 0)
		
			IF (thisRead == $$SOCKET_ERROR || thisRead == 0) THEN
				EXIT DO
			ELSE		
				str$ = MID$(CSIZE$(pageBuffer$),read+1,thisRead)+"\0"
				MessagePump (idx,str$)
				read = read + thisRead
				rover = rover + thisRead
			END IF
		LOOP
	LOOP ' WHILE socket
	
	RETURN $$TRUE

END FUNCTION

FUNCTION OpenSConnection (idx)
	SHARED TSPROFILE sprofile[]


	sOpen (@socket)
	sprofile[idx].server.socket = socket
	IFT sConnect (idx) THEN
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF
	
END FUNCTION	

FUNCTION AuthSConnection (idx)	


	getSPClient (idx,@alias$, @hostid$, @cinfo$, alias2$)
	getSPServer (idx,@server$,port,password$,socket)		
	buffer$ = "USER "+ hostid$ +" host "+ server$ +" :"+ cinfo$
	
	SetNick (idx,alias$)
	SendSMessage (idx,buffer$)
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION CloseSConnection (idx)


	getSPServer (idx,server$,port,password$,@socket)
	sClose (socket)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION Initialize ()
	WSADATA wsadata


	version = 2 OR (2 << 8)								' version winsock v2.2 (MAKEWORD (2,2))
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	
	IF ret THEN
		EPrint (error($$ER_WSASTARTUPFAIL))
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		EPrint (error($$ER_WSANOWINSOCK))
		WSACleanup ()
		RETURN $$FALSE
	END IF

	
	RETURN $$TRUE

END FUNCTION

FUNCTION GetError ()

	lastErr = WSAGetLastError ()
	EPrint ("error code :: "+STRING$(lastErr))
	RETURN lastErr
	
END FUNCTION



' IN		:IPName$ (www.usatoday.com)
' OUT		:numIPAddr$ (66.54.32.27)		' DS
FUNCTION GetIPAddr (IPName$, @numIPAddr$)

	WSADATA wsadata
	HOSTENT	host

	version = 0x0001
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		EPrint (error($$ER_WSANOTINITILIZED))
		WSACleanup ()
		RETURN
	END IF

	IF wsadata.wVersion != version THEN
		EPrint (error($$ER_WSANOWINSOCK))
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


' IN		:numIPAddr$ (66.54.32.27)
' OUT		:IPName$ (www.usatoday.com)			' DS
FUNCTION GetIPName (numIPAddr$, @IPName$)
	WSADATA wsadata
	HOSTENT	host
	

	version = 0x0001
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		EPrint (error($$ER_WSANOTINITILIZED))
		WSACleanup ()
		RETURN
	END IF

	IF wsadata.wVersion != version THEN
		EPrint (error($$ER_WSANOWINSOCK))
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



' code taken almost exactly as is from edit.x by David S.

FUNCTION InitGUIsubsystem ()

	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

	InitGui ()										' initialize program and libraries
	CreateWindows ()							' create main windows and other child controls
	CreateCallbacks ()						' if necessary, assign callback functions to child controls
	MessageLoop ()								' the message loop
	CleanUp ()										' unregister all window classes
	
END FUNCTION


' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)
	STATIC str$


	SELECT CASE msg

		CASE $$WM_CREATE:
			str$ = NULL$(512)
			
		CASE $$WM_SIZE:
			w = LOWORD(lParam)
			h = HIWORD(lParam)
			SetWindowPos (#edit2, 0, 1, h-18, w-1, 18, $$SWP_NOZORDER)
			
		CASE $$WM_DESTROY :
			DeleteObject (#hFontArial)
			PostQuitMessage (0)
			Shutdown ("")
			RETURN $$TRUE

		CASE $$WM_COMMAND :

			id         = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE $$EDITBOX_RETURN :
					SELECT CASE id :
						CASE $$Edit2	:				' demonstrate that RETURN key was
							text$ = NULL$(1024)										' pressed in one of the edit controls
							SendMessageA (hwndCtl, $$WM_GETTEXT, 1024, &text$)
							text$ = CSIZE$(text$)
							ProcessClientText (#cserver,text$)
							text$ = ""
							SendMessageA (#edit2, $$WM_SETTEXT, 0, &text$)		' set new text

							RETURN
					END SELECT
			END SELECT

		CASE $$WM_CTLCOLOREDIT :
			hdcStatic = wParam
			hwndStatic = lParam
			SELECT CASE hwndStatic
				
				CASE #edit2 :													' change the text and background color
					RETURN SetColor (RGB(150, 150, 150), RGB(212, 208, 200), wParam, lParam)

			END SELECT

	END SELECT

RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
' ########################
' #####  InitGui ()  #####
' ########################
'
FUNCTION  InitGui ()

	SHARED hInst

	hInst = GetModuleHandleA (0)		' get current instance handle
	IFZ hInst THEN QUIT(0)

END FUNCTION
'
'
' #################################
' #####  RegisterWinClass ()  #####
' #################################
'
FUNCTION  RegisterWinClass (className$, titleBar$)

	SHARED hInst
	WNDCLASS wc

	wc.style           = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_OWNDC
	wc.lpfnWndProc     = &WndProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"scrabble")
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = GetStockObject ($$LTGRAY_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &className$

	RETURN RegisterClassA (&wc)

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()
	SHARED className$
	SHARED winh,winw
	
' create main window

	className$  = "EditControls"
	titleBar$  	= ""
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 400
	h 					= 45

	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	winh=h
	winw=w

	#edit2 = NewChild ("edit","", $$ES_AUTOHSCROLL, 0, 0, 0, 0, #winMain, $$Edit2, $$WS_EX_STATICEDGE)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window
	SetFocus (#edit2)

END FUNCTION
'
'
' ##########################
' #####  NewWindow ()  #####
' ##########################
'
FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
	SHARED hInst

	RegisterWinClass (className$, titleBar$)
	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION
'
'
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	hwnd = CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

	RETURN hwnd

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

	STATIC USER32_MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, hwnd, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
  			TranslateMessage (&msg)						' translate virtual-key messages into character messages
  			DispatchMessageA (&msg)						' send message to window callback function WndProc()
		END SELECT
	LOOP

END FUNCTION
'
'
' ################################
' #####  CreateCallbacks ()  #####
' ################################
'
FUNCTION  CreateCallbacks ()

'	assign a new callback function to be used by child edit controls
	#old_proc = SetWindowLongA(#edit2, $$GWL_WNDPROC, &EditProc())

END FUNCTION
'
'
' #########################
' #####  EditProc ()  #####
' #########################
'
FUNCTION  EditProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg

		CASE $$WM_KEYDOWN :			' WM_KEYDOWN returns virtKey constants
			virtKey = wParam
			IF virtKey = $$VK_RETURN THEN
				id = GetWindowLongA (hWnd, $$GWL_ID)
				wParam = ($$EDITBOX_RETURN << 16) OR id
				SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)	' send WM_COMMAND message to main window callback function
				RETURN 0
			END IF
	END SELECT

RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

END FUNCTION
'
'
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
	SHARED hNewBrush
	
	
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	
	RETURN hNewBrush

END FUNCTION
'
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC 					= GetDC ($$HWND_DESKTOP)
	hFont 				= GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes 				= GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName 	= fontName$														' set font name
	lf.italic 		= italic															' set italic
	lf.weight 		= weight															' set weight
	lf.underline 	= underline														' set underlined
	lf.height 		= -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72.0
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)										' create a new font and get handle

END FUNCTION
'
'
' ###########################
' #####  SetNewFont ()  #####
' ###########################
'
FUNCTION  SetNewFont (hwndCtl, hFont)

	SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$
	SHARED fConsole

	UnregisterClassA(&className$, hInst)
	IF fConsole THEN XioFreeConsole ()			' free console before leaving!!

END FUNCTION
'
'
' ############################
' #####  InitConsole ()  #####
' ############################
'
FUNCTION  InitConsole ()
	SHARED fConsole
	STATIC entry
	
	IFT entry THEN RETURN
	entry = $$TRUE
	XioCreateConsole (@consoleTitle$, 100)
	fConsole = $$TRUE

END FUNCTION

FUNCTION DisplayCommands ()

	PRINT "IRC Client for XBLite by Michael McElligott."
	PRINT "Command List:"
	PRINT
	PRINT "/server serverAddr port nickname password   - joins a server"
	PRINT "/server                - join default server using defaults - **recommended**"
	PRINT "/nick alias            - set and change nickname"
	PRINT "/join #chan password   - join a channel, channel names must begin with #"
	PRINT "/serv                  - view current active server connection"
	PRINT "/serv list             - list all active server connections"
	PRINT "/serv n                - n = server number, set active server to n"
	PRINT "/chn                   - view active channel"
	PRINT "/chan list             - list all joined channels"
	PRINT "/chan #channel         - set already joined #channel as active channel"
	PRINT "/partc #channel        - leave this channel"
	PRINT "/parts n               - leave this server, n = server number"
	PRINT "/url list              - list all filtered url's"
	PRINT "/url n                 - open url n in browser"
	PRINT "/exit                  - exit server and client program"

END FUNCTION


END PROGRAM

