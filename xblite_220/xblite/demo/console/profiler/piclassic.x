'
'/* http://numbers.computation.free.fr/Constants/constants.html
'** Pascal Sebah : September 1999
'** 
'** Subject:
'**
'**    A very easy program to compute Pi with many digits.
'**    No optimisations, no tricks, just a basic program to learn how
'**    to compute in multiprecision.  
'**
'** Formulae:
'**
'**    Pi/4 =    arctan(1/2)+arctan(1/3)                     (Hutton 1)
'**    Pi/4 =  2*arctan(1/3)+arctan(1/7)                     (Hutton 2)
'**    Pi/4 =  4*arctan(1/5)-arctan(1/239)                   (Machin)
'**    Pi/4 = 12*arctan(1/18)+8*arctan(1/57)-5*arctan(1/239) (Gauss)
'**
'**      with arctan(x) =  x - x^3/3 + x^5/5 - ...
'**
'**    The Lehmer's measure is the sum of the inverse of the decimal
'**    logarithm of the pk in the arctan(1/pk). The more the measure
'**    is small, the more the formula is efficient.
'**    For example, with Machin's formula:
'**
'**      E = 1/log10(5)+1/log10(239) = 1.852
'** 
'** Data:
'**
'**    A big real (or multiprecision real) is defined in base B as:
'**      X = x(0) + x(1)/B^1 + ... + x(n-1)/B^(n-1)
'**      where 0<=x(i)<B
'**
'** Results: (PentiumII, 450Mhz)
'**    
'**   Formula      :    Hutton 1  Hutton 2   Machin   Gauss
'**   Lehmer's measure:   5.418     3.280      1.852    1.786
'**
'**  1000   decimals:     0.2s      0.1s       0.06s    0.06s
'**  10000  decimals:    19.0s     11.4s       6.7s     6.4s
'**  100000 decimals:  1891.0s   1144.0s     785.0s   622.0s
'**
'** With a little work it's possible to reduce those computation
'** times by a factor 3 and more:
'**  
'**     => Work with double instead of long and the base B can
'**        be choosen as 10^8
'**     => During the iterations the numbers you add are smaller
'**        and smaller, take this in account in the +, *, /
'**     => In the division of y=x/d, you may precompute 1/d and
'**        avoid multiplications in the loop (only with doubles)
'**     => MaxDiv may be increased to more than 3000 with doubles
'**     => ...
'*/
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A program to calculate pi digits using 
' classic arbitrary precision math.
'
PROGRAM "piclassic"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
	IMPORT  "xio"				' Console input/ouput library
'	IMPORT  "user32"		' user32.dll
	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"		' msvcrt.dll
'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION SetToInteger (XLONG n, XLONG x[], XLONG Integer)
DECLARE FUNCTION IsZero (XLONG n, XLONG x[])
DECLARE FUNCTION Add (XLONG n, XLONG x[], XLONG y[])
DECLARE FUNCTION Sub (XLONG n, XLONG x[], XLONG y[])
DECLARE FUNCTION Mul (XLONG n, XLONG x[], XLONG q)
DECLARE FUNCTION Div (XLONG n, XLONG x[], XLONG d, XLONG y[])
DECLARE FUNCTION arccot (XLONG p, XLONG n, XLONG x[], XLONG buf1[], XLONG buf2[])
DECLARE FUNCTION Print (XLONG n, XLONG x[])
'
	$$B=10000					' Working base 
	$$LB=4						' Log10(base)  
	$$MaxDiv=450			' about sqrt(2^31/B) 
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

' Computation of the constant Pi with arctan relations
	XLONG NbDigits, NbArctan
	XLONG p[10]
	XLONG m[10]
	XLONG size
	
	XLONG Pi[], arctan[], buffer1[], buffer2[]
	
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, w, 2200)
	XioCloseStdHandle (hStdOut)
	
	NbDigits = 100
	size     = 1 + NbDigits/$$LB
	
	DIM Pi[size]
	DIM arctan[size]
	DIM buffer1[size]
	DIM buffer2[size]
	
  startclock = GetTickCount () 
'  
'  Formula used: 
'    
'  Pi/4 = 12*arctan(1/18)+8*arctan(1/57)-5*arctan(1/239) (Gauss)
'  
  NbArctan = 3
  m[0] = 12 : m[1] = 8 :  m[2] = -5
  p[0] = 18 : p[1] = 57 : p[2] = 239
'	 
  SetToInteger (size, @Pi[], 0)
'  
'  ** Computation of Pi/4 = Sum(i) [m[i]*arctan(1/p[i])] 
'  
  FOR i = 0 TO NbArctan-1
    arccot (p[i], size, @arctan[], @buffer1[], @buffer2[])
    Mul (size, @arctan[], ABS(m[i]))
    IF (m[i]>0) THEN 
			Add (size, @Pi[], @arctan[])  
    ELSE
			Sub (size, @Pi[], @arctan[]) 
		END IF 
	NEXT i

  Mul (size, @Pi[], 4)
	
  endclock = GetTickCount()
	
	f$ = FORMAT$ ("####.##", DOUBLE((endclock-startclock)/1000.0))	
  Print (size, @Pi[])							'   Print out of Pi[] 
	PRINT "Time to compute"; NbDigits; " digits of pi ="; f$; " seconds."

'	a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
' ##########################
' #####  SetToInteger  #####
' ##########################
'
' Set the big real x to the small integer Integer 
'
FUNCTION SetToInteger (XLONG n, XLONG x[], XLONG Integer)

	FOR i = 1 TO n-1 
		x[i] = 0
	NEXT i
  x[0] = Integer

END FUNCTION
'
' ####################
' #####  IsZero  #####
' ####################
'
' Is the big real x equal to zero ?
'
FUNCTION IsZero (XLONG n, XLONG x[])

	FOR i = 0 TO n-1 
		IF (x[i])	THEN RETURN 0
	NEXT i
	RETURN 1

END FUNCTION
'
' #################
' #####  Add  #####
' #################
'
' Addition of big reals : x = x + y
' Like school addition with carry management
'
FUNCTION Add (XLONG n, XLONG x[], XLONG y[])

	XLONG carry
	carry = 0

	FOR i = n-1 TO 0 STEP -1  
		x[i] = x[i] + y[i] + carry
		IF (x[i] < $$B) THEN
			carry = 0
		ELSE
			carry = 1
			x[i] = x[i] - $$B
		END IF
	NEXT i

END FUNCTION
'
' #################
' #####  Sub  #####
' #################
'
' Substraction of big reals : x = x - y
' Like school substraction with carry management
' x must be greater than y
'
FUNCTION Sub (XLONG n, XLONG x[], XLONG y[])

	FOR i = n-1 TO 0 STEP -1
		x[i] = x[i] - y[i]
		IF (x[i] < 0) THEN
			IF (i) THEN
        x[i] = x[i] + $$B
        DEC x[i-1]
			END IF
		END IF
	NEXT i

END FUNCTION
'
' #################
' #####  Mul  #####
' #################
'
' Multiplication of the big real x by the integer q 
' x = x*q.
' Like school multiplication with carry management
'
FUNCTION Mul (XLONG n, XLONG x[], XLONG q)

	XLONG carry, xi
	carry = 0

	FOR i = n-1 TO 0 STEP -1
		xi  = x[i]*q		
		xi = xi + carry		
		IF (xi >= $$B) THEN
			carry = xi/$$B
			xi = xi - (carry*$$B)
		ELSE  
      carry = 0
		END IF
    x[i] = xi
	NEXT i

END FUNCTION
'
' #################
' #####  Div  #####
' #################
'
' Division of the big real x by the integer d 
' The result is y=x/d.
' Like school division with carry management
' d is limited to MaxDiv*MaxDiv.
'
FUNCTION Div (XLONG n, XLONG x[], XLONG d, XLONG y[])

  XLONG carry, xi, q
	carry = 0
	FOR i = 0 TO n-1 
		xi    = x[i]+carry*$$B
    q     = xi/d
    carry = xi-q*d 
    y[i]  = q 
	NEXT i

END FUNCTION
'
' ####################
' #####  arccot  #####
' ####################
'
' Find the arc cotangent of the integer p = arctan (1/p)
' Result in the big real x (size n)
' buf1 and buf2 are two buffers of size n
'
FUNCTION arccot (XLONG p, XLONG n, XLONG x[], XLONG buf1[], XLONG buf2[])

	XLONG p2, k, sign
	
	p2 = p*p
	k = 3
	sign = 0

  SetToInteger (n, @x[], 0)
  SetToInteger (n, @buf1[], 1)				' uk = 1/p 
  Div (n, @buf1[], p, @buf1[])
  Add (n, @x[], @buf1[])							' x  = uk 

  DO WHILE (!IsZero (n, @buf1[])) 
    IF (p < $$MaxDiv) THEN
      Div (n, @buf1[], p2, @buf1[])   ' One step for small p 
		ELSE
      Div (n, @buf1[], p, @buf1[])    ' Two steps for large p (see division) 
      Div (n, @buf1[], p, @buf1[])  
		END IF
'																			' uk = u(k-1)/(p^2) 
    Div (n, @buf1[], k, @buf2[])      ' vk = uk/k  
    IF (sign) THEN
			Add (n, @x[], @buf2[])					' x = x+vk   
    ELSE
			Sub (n, @x[], @buf2[])					' x = x-vk 
		END IF  
    k = k + 2
    sign = 1-sign
	LOOP

END FUNCTION
'
' ###################
' #####  Print  #####
' ###################
'
' Print the big real x
'
FUNCTION Print (XLONG n, XLONG x[])

	PRINT "Pi = ";
  printf (&"%d.", x[0])
	PRINT
	
	FOR i = 1 TO n-1 
    printf (&" %.4d", x[i])
    IF (i MOD 12 == 0) THEN printf (&" : %8d\n", i*4)
	NEXT i
  PRINT

END FUNCTION

END PROGRAM

