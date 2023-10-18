'
' Examples of finding best fit equation to data points.
' Demo by Steven Gunhouse
'
PROGRAM "bestfit"
VERSION "1.000"
CONSOLE
'

'IMPORT "xma"  ' math function library
'IMPORT "xsx"

IMPORT "xst_s.lib"
IMPORT "xsx_s.lib"
IMPORT "xma_s.lib"
'
TYPE POINT
  DOUBLE .x
  DOUBLE .y
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  Linear (POINT data[], @m#, @b#)
DECLARE FUNCTION  LogFit (POINT data[], @m#, @b#)
DECLARE FUNCTION  ExpFit (POINT data[], @m#, @b#)
DECLARE FUNCTION  PowerFit (POINT data[], @m#, @b#)

FUNCTION Entry ()
  POINT data[]
'
  DIM data[2]   ' three points
  data[0].x = 1#
  data[0].y = 1#
  data[1].x = 2#
  data[1].y = 2#
  data[2].x = 3#
  data[2].y = 4#

  IF Linear (@data[], @m#, @b#) THEN
    PRINT "The best fit linear equation for your data is:"
    PRINT "  y = "; m#; "* x + "; b#
  ELSE
    PRINT "Not enough data or no line fits the data."
  END IF

	PRINT

  IF LogFit (@data[], @m#, @b#) THEN
    PRINT "The best fit logarithmic equation for your data is:"
    PRINT "  y = "; m#; "* LOG(x) + "; b#
  ELSE
    PRINT "Not enough data or no logaritmic equation fits the data."
  END IF

	PRINT

  IF ExpFit (@data[], @m#, @b#) THEN
    PRINT "The best fit exponential equation for your data is:"
    PRINT "  y = "; b#; "* EXP("; m#; "* x)"
  ELSE
    PRINT "Not enough data or no exponential equation fits the data."
  END IF

	PRINT

  IF PowerFit (@data[], @m#, @b#) THEN
    PRINT "The best fit power equation for your data is:"
    PRINT "  y = "; b#; "* (x ** "; m#; ")"
  ELSE
    PRINT "Not enough data or no power equation fits the data."
  END IF

	PRINT

	a$ = INLINE$ ("Press any key to quit >")
END FUNCTION

FUNCTION Linear (POINT data[], m#, b#)
'
  upper = UBOUND(data[])
' must have at least two points
  IF upper < 1 THEN RETURN ($$FALSE)
  FOR i = 0 TO upper
    x# = data[i].x
    y# = data[i].y
    Sx# = Sx# + x#
    Sy# = Sy# + y#
    Sxy# = Sxy# + x# * y#
    Sxx# = Sxx# + x# * x#
'   Syy# = Syy# + y# * y#    ' may be used to check accuracy of fit
  NEXT i
  n# = upper + 1
'
  d# = Sx# * Sx# - n# * Sxx#
' if d# = 0, the equations are multiples of each other
  IFZ d# THEN RETURN ($$FALSE)
' otherwise, we can now compute m# and b#
  m# = (Sx# * Sy# - n# * Sxy#) / d#
  b# = (Sx# * Sxy# - Sxx# * Sy#) / d#
  RETURN ($$TRUE)
END FUNCTION


FUNCTION LogFit (POINT data[], m#, b#)
  POINT logData[]
  IFF data[] THEN RETURN ($$FALSE)
  upper = UBOUND(data[])
  DIM logData[upper]
  FOR i = 0 TO upper
    logData[i].x = Log(data[i].x)
    logData[i].y = data[i].y
  NEXT i
' not required to transform m# or b# in this case, so ...
  RETURN (Linear (@logData[], @m#, @b#))
END FUNCTION

FUNCTION ExpFit (POINT data[], m#, b#)
  POINT expData[]
  IFF data[] THEN RETURN ($$FALSE)
  upper = UBOUND(data[])
  DIM expData[upper]
  FOR i = 0 TO upper
    expData[i].x = data[i].x
    expData[i].y = Log(data[i].y)
  NEXT i
  IF Linear (@expData[], @m#, @b#) THEN
    b# = Exp(b#)
    RETURN ($$TRUE)
  ELSE
    RETURN ($$FALSE)
  END IF
END FUNCTION

FUNCTION PowerFit (POINT data[], m#, b#)
  POINT powerData[]
  IFF data[] THEN RETURN ($$FALSE)
  upper = UBOUND (data[])
  DIM powerData[upper]
  FOR i = 0 TO upper
    powerData[i].x = Log(data[i].x)
    powerData[i].y = Log(data[i].y)
  NEXT i
  IF Linear (@powerData[], @m#, @b#) THEN
    b# = Exp(b#)
    RETURN ($$TRUE)
  ELSE
    RETURN ($$FALSE)
  END IF
END FUNCTION
END PROGRAM