
' The Tak Benchmark (Takeuchi function)
' Deep recursion can test the speed with which a language
' can make method calls. This is important because modern
' applications have a tendency to spend much of their time
' calling various API functions. PCWeek invented a benchmark
' called Tak which performs 63,609 recursive method calls per pass.

' According to [Gabriel85], the Tak benchmark contains 63,609
' recursive calls to tak, as well as 47,706 decrement operations,
' when performed on the arguments (18 12 6) to produce the answer 7.
' None of the arguments to tak ever becomes negative, nor does any
' ever exceed 18. The first arm of the conditional is executed 75% of the time.
   
' The algorithm is simple: If y is greater than or equal to x,
' Tak(x, y, z) is z. This is the nonrecursive stopping condition.
' Otherwise, if y is less than x, Tak(x, y, z) is
' Tak(Tak(x-1, y, z), Tak(y-1, z, x), Tak(z-1, x, y)).
   
' For more information about the Tak benchmark see
' Peter Coffee's article, "Tak test stands the test of time"
' on p. 91 of the 9-30-1996 PCWeek.

' Note that this benchmark also tests how quickly a
' trivial program can be fired up -- some language implementations
' have large startup overhead.

PROGRAM "benchmark"
CONSOLE
'IMPORT "xst"
'IMPORT "xsx"

IMPORT "xst_s.lib"
IMPORT "xsx_s.lib"

DECLARE FUNCTION VOID Entry ()
DECLARE FUNCTION XLONG Tak (XLONG x, XLONG y, XLONG z)

FUNCTION VOID Entry()

  FOR i = 0 TO 25
    XstGetSystemTime(@a)
    PRINT i, Tak(9, 0, i),
    XstGetSystemTime(@b)
    PRINT (b-a); " msec"
  NEXT i

  INLINE$ ("Finished. Press any key to quit.")

END FUNCTION

FUNCTION XLONG Tak(XLONG x, XLONG y, XLONG z)

  IF x>y THEN RETURN Tak(Tak((x-1),y,z), Tak((y-1),z,x), Tak((z-1),x,y)) ELSE RETURN z

END FUNCTION

END PROGRAM
