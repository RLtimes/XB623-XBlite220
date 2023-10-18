'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' The "seive of Erasthones" prints all prime numbers between 2 and n.
'
PROGRAM	"seive"
VERSION	"0.0001"
CONSOLE

DECLARE FUNCTION Entry ()
DECLARE FUNCTION Seive (n)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	Seive (10007)
	a$ = INLINE$ ("Press Enter to exit >")

END FUNCTION
'
' ###################
' #####  Seive  #####
' ###################
'
'  The "seive of Erasthones" prints all prime numbers between 2 and n.
'
FUNCTION Seive (n)

' Initialize A to hold the values 2, 3, 4, ...
	DIM A[n-1]
	
	FOR i = 0 TO n-1
		A[i] = i + 2
	NEXT i
  
	FOR i = 0 TO n-1

    ' A[i] has been crossed out, hence so have its multiples.
    IF (A[i] == 0) THEN DO NEXT

    ' Cross out the multiples of A[i].
    j = 2
    DO WHILE (j*A[i]-2 < n)
			A[j*A[i]-2] = 0
			INC j
		LOOP
  NEXT i

  ' Print out the results.
  FOR i = 0 TO n-1
		IF (A[i] != 0) THEN PRINT A[i],
	NEXT i

	PRINT
  DIM A[]

END FUNCTION
END PROGRAM
