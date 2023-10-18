'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Thread local storage (TLS) enables multiple threads
' of the same process to use an index allocated by the
' TlsAlloc function to store and retrieve a value that
' is local to the thread. In this example, an index is
' allocated when the process starts. When each thread
' starts, it allocates a block of dynamic memory and
' stores a pointer to this memory by using the TLS index.
' The TLS index is used by the locally defined CommonFunc
' function to access the data local to the calling thread.
' Before each thread terminates, it releases its dynamic memory.
'
PROGRAM	"tls"
VERSION	"0.0001"
CONSOLE
'
'	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"kernel32"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  ErrorExit (msg$)
DECLARE FUNCTION  CommonFunc ()
DECLARE FUNCTION  ThreadFunc ()

$$THREADCOUNT = 3
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

	SHARED tlsIndex

	DIM hThread[$$THREADCOUNT]

' Allocate a TLS index.

	tlsIndex = TlsAlloc ()
	IF tlsIndex == 0xFFFFFFFF THEN ErrorExit (@"TlsAlloc failed")

' Create multiple threads.

	FOR i = 0 TO $$THREADCOUNT

		hThread[i] = CreateThread (NULL, 0, &ThreadFunc(), NULL, 0, &IDThread)

' Check the return value for success.
		IF (hThread[i] == NULL) THEN ErrorExit (@"CreateThread error\n")

	NEXT i

	FOR i = 0 TO $$THREADCOUNT
		WaitForSingleObject (hThread[i], $$INFINITE)
	NEXT i

	a$ = INLINE$ ("Press Enter key to quit >")

END FUNCTION
'
'
' ##########################
' #####  ErrorExit ()  #####
' ##########################
'
FUNCTION  ErrorExit (msg$)

	PRINT msg$
	ExitProcess (0)

END FUNCTION
'
'
' ###########################
' #####  ThreadFunc ()  #####
' ###########################
'
FUNCTION  ThreadFunc ()

	SHARED tlsIndex

' Initialize the TLS index for this thread.

	pData = LocalAlloc ($$LPTR, 256)
	IF (! TlsSetValue (tlsIndex, pData)) THEN ErrorExit (@"TlsSetValue error")

	PRINT "thread "; GetCurrentThreadId (); ":\n"; "pData="; pData

	CommonFunc ()

' Release the dynamic memory before the thread returns.

	pData = TlsGetValue (tlsIndex)
	IF (lpvData != 0) THEN LocalFree (pData)

END FUNCTION
'
'
' ###########################
' #####  CommonFunc ()  #####
' ###########################
'
FUNCTION  CommonFunc ()

	SHARED tlsIndex

' Retrieve a data pointer for the current thread.

	pData = TlsGetValue (tlsIndex)
	IF ((pData == 0) && (GetLastError () != 0)) THEN ErrorExit (@"TlsGetValue error")

' Use the data stored for the current thread.

	PRINT "common: thread "; GetCurrentThreadId(); "\npData="; pData
	Sleep (5000)

END FUNCTION
END PROGRAM
