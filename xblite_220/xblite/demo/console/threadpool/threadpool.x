'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A thread demo which uses a pool of threads
' to perform a series of tasks in a que.
' Based on example in "Multithreading Applications
' in Win32."
'
PROGRAM	"threadpool"
VERSION	"0.0001"
CONSOLE
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"xsx"
	IMPORT	"kernel32"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  ErrorExit (msg$)
DECLARE FUNCTION  ThreadFunc (n)

$$THREAD_POOL_SIZE = 3
$$MAX_THREAD_INDEX = 2
$$NUM_TASKS = 6
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' Call ThreadFunc() NUM_TASKS times, using
' no more than THREAD_POOL_SIZE threads.
' WaitForMultipleObjects is used to wait
' on more than one object at a time. You
' pass the function an array of handles,
' the size of the array, and whether to
' wait on one or all of the handles.
'
FUNCTION  Entry ()

	DIM hThrds[$$THREAD_POOL_SIZE-1]

' Create multiple threads.

	FOR i = 1 TO $$NUM_TASKS
	
' until we've used all threads in the pool, do
' not need to wait for one to exit
    IF i > $$THREAD_POOL_SIZE THEN

' wait for one thread to terminate
      rc = WaitForMultipleObjects ($$THREAD_POOL_SIZE, &hThrds[], $$FALSE, $$INFINITE)
      slot = rc - $$WAIT_OBJECT_0
      IFZ (slot >= 0 && slot < $$THREAD_POOL_SIZE) THEN ErrorExit ("WaitForMultipleObjects ret:" + STRING$ (rc))
      PRINT "Slot "; slot; " terminated"
      IFZ CloseHandle (hThrds[slot]) THEN ErrorExit ("CloseHandle error")
    END IF

' create a new thread in the given available slot
  	hThrds[slot] = CreateThread (NULL, 0, &ThreadFunc(), slot, 0, &IDThread)
  	IFZ hThrds[slot] THEN ErrorExit ("CreateThread error")
		PRINT "Launched thread #"; i; " (slot"; slot; ")"
		INC slot
	NEXT i

' Now wait for all threads to terminate
  rc = WaitForMultipleObjects ($$THREAD_POOL_SIZE, &hThrds[], 1, $$INFINITE)
  IFZ (rc >= $$WAIT_OBJECT_0 && rc < $$WAIT_OBJECT_0 + $$THREAD_POOL_SIZE) THEN
    ErrorExit ("WaitForMultipleObjects ret:" + STRING$ (rc))
  END IF
  
  FOR slot = 0 TO $$THREAD_POOL_SIZE -1
    IFZ CloseHandle (hThrds[slot]) THEN ErrorExit ("CloseHandle error")
  NEXT slot
  
  PRINT "All slots terminated"
  
	a$ = INLINE$ ("Press Enter key to quit >")

END FUNCTION
'
'
' ##########################
' #####  ErrorExit ()  #####
' ##########################
'
FUNCTION  ErrorExit (msg$)

  error = GetLastError ()
  XstSystemErrorNumberToName(error, @error$)
	PRINT msg$; " Error: "; error$
	ExitProcess (0)

END FUNCTION
'
'
' ###########################
' #####  ThreadFunc ()  #####
' ###########################
'
FUNCTION  ThreadFunc (n)
' This function just calls Sleep() for 
' a random amount of time, thereby simulating
' some task that takes time.

' The parameter n is the index into the thread
' handle array, kept for informational purposes

  time = (XstRandom() MOD 10) * 800 + 500
  a$ = "Slot " + STRING$ (n) + " idle for " + STRING$ (time) + " msec"
  PRINT a$
  Sleep (time)
  RETURN n

END FUNCTION
'
END PROGRAM
