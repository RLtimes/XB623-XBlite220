'
' ####################
' #####  PROLOG  #####
' ####################
'
' Compute the digits of pi using a spigot algorithm.
'
PROGRAM "pidigits"
VERSION "0.0001"
CONSOLE
'
'	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
'	IMPORT  "xio"				' Console input/ouput library
'	IMPORT  "user32"		' user32.dll
	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"		' msvcrt.dll
'
DECLARE FUNCTION Entry   ()
DECLARE FUNCTION ComputePi (digits, @pi$)
DECLARE FUNCTION PrintPi (@pi$)
'
FUNCTION  Entry ()

	ComputePi (10000, @pi$)
	PrintPi (@pi$)
	
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

FUNCTION ComputePi (digits, @pi$)

' Calculate the digits of PI, where digits is number of 
' digits after decimal place; 3.(no of digits).
' 
' The spigot algorithm for pi (written up by Rabinowitz and Wagon
' in the March 1995 American Mathematical Monthly) is based on the
' representation
'
'   pi = 2 + (1/3)(2 + (2/5)(2 + (3/7)(2 + (4/9)(2 + (5/11)(2 + ... ))))
'
' where the k'th fraction is k/(2k+1).
' It takes O(n^2) time for n digits.

	IFZ digits THEN RETURN ($$TRUE)
	PRINT "Calculating"; digits; " digits of pi."

	s = GetTickCount ()
	d = 4
	r = 10000
	n = 1 + ((digits + 3 AND -4)/4)   ' pad to 4 digits
	m = 3.322*n*d
	DIM a[m]
	tmp$ = NULL$ (n*d)

	FOR i = 0 TO m
		a[i] = 2
	NEXT i
  a[m] = 4

  FOR i = 1 TO n 
    q = 0
    FOR k = m TO 1 STEP -1
      a[k] = a[k]*r+q
      q = a[k]/(2*k+1)
      a[k] = a[k]-(2*k+1)*q
      q = q * k
    NEXT k
    a[0] = a[0]*r+q
    q = a[0]/r
    a[0] = a[0]-q*r
		
		q$ = NULL$(4)
		sprintf (&q$, &"%04d", q)   					' format value with leading 0 if necessary

		FOR j = 0 TO 3
			tmp${count+j} = q${j}									' copy q$ to tmp$
		NEXT j
		count = count + 4
		
'		IF i & 7 THEN s$ = "  " ELSE s$ = "\n"	' print 8 lines, then skip line
'		PRINT q$, s$

	NEXT i
	
	pi$ = MID$ (tmp$, 4, 1 + digits)					' get digits
	
	f = GetTickCount() - s
	f$ = FORMAT$ ("####.##", DOUBLE((f)/1000.0))	
	PRINT "Time to compute"; digits; " digits of pi ="; f$; " seconds."

END FUNCTION

FUNCTION PrintPi (@pi$)

	$PAD0 = "  "
	$PAD1 = " "
	IFZ pi$ THEN RETURN ($$TRUE)
	upp = LEN(pi$) - 1

	PRINT "Pi = 3."
	PRINT $PAD0;

	FOR i = 1 TO upp
		chr$ = CHR$(pi${i})
		
		IF count = 48 THEN
			PRINT ":"; i-1; 
			PRINT
			PRINT $PAD0;
			count = 1
		ELSE
			INC count
		END IF

		IF i & 3 THEN 
			PRINT chr$;
		ELSE
			PRINT chr$; $PAD1;
		END IF

	NEXT i
	PRINT

END FUNCTION

END PROGRAM
