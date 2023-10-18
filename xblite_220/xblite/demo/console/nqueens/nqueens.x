'
' ####################
' #####  PROLOG  #####
' ####################
'
' A N-Queens benchmark program by Vic Drastik.
' The N-Queens benchmark solves the combinatorially hard
' chess problem of placing N queens on an NxN chessboard
' such that no queen can attack any other. The typical
' software solution to this problem uses a recursive search
' for a placement of the queens that meets the correct
' conditions.
'
PROGRAM "nqueens"
VERSION "0.0001"
CONSOLE
'
'	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
	IMPORT  "xst_s.lib"
	IMPORT  "xsx_s.lib"

'
DECLARE FUNCTION VOID Entry ()
DECLARE FUNCTION VOID Find (XLONG level)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION VOID Entry ()

  SHARED XLONG n, empty, solutions, file[], forw[], back[]
  XLONG start, finish

	n = XLONG(INLINE$("Enter board size n > "))
	
	empty = n + 1
	solutions = 0
	DIM file[n], forw[2*n-1], back[2*n-1]
	FOR i = 0 TO n-1
		file[i] = empty
	NEXT i
	FOR i = 0 TO 2*n-1
		forw[i] = empty
		back[i] = empty
	NEXT i

	XstGetSystemTime(@start)
	Find(0)
	XstGetSystemTime(@finish)

	PRINT "There are" ; solutions ; " solutions on a"; n; " X"; n; " board."
	PRINT "Run time was "; 0.001 * (finish-start) ; " seconds."

  INLINE$ ("Press any key to quit > ")

END FUNCTION
'
' ##################
' #####  Find  #####
' ##################
'
'
'
FUNCTION VOID Find (XLONG level)

	SHARED XLONG n, empty, solutions, file[], forw[], back[]
	XLONG f

	IF level == n THEN INC solutions : EXIT FUNCTION

	' here, we have not done the last row yet
	' so try to place the next queen in file f
	FOR f = 0 TO n - 1
		' check for conflict and skip this file if there is conflict
		IF file[f] >= level THEN
			IF forw[level + f] >= level THEN
				IF back[level + n - 1 - f] >= level THEN
					' no conflict so place queen on file f in rank level
					file[f] = level
					forw[level + f] = level
					back[level + n - 1 - f] = level
					' recurse to the next level
					Find (level + 1)
					' remove the queen that was placed above
					file[f] = empty
					forw[level + f] = empty
					back[level + n - 1 - f] = empty
				END IF
			END IF
		END IF
	NEXT f

END FUNCTION
END PROGRAM