>> I search a function for interpolate a series data into:
>> linear y=B + Mx
>> exponential y =B * e^(Mx)
>> log y=B + M * ln(x)
>> power  y=B* x^M
>> interpolation.

As a mathematician, I can tell you how most calculators do it. They have
a formula for "least squares" fitting of a line to data, the other three
are done by transforming the data.

In math we'd use the greek letter Sigma to denote a sum (total) of
something, lacking that symbol in ASCII I'll write S.

You have a collection of points which we'll presume are defined as
follows:

TYPE POINT
  DOUBLE .x
  DOUBLE .y
END TYPE

So then you have an array which I'll call data[] which would be declared
in your calling function as

  POINT data[]

At this time we'd DIM the array and fill it with your data (or read it
from some file), and we'd call a function which I'll name Linear:

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
    Syy# = Syy# + y# * y#    ' used to check accuracy of fit
  NEXT i
  n# = upper + 1

Let me stop here to describe what we're doing next. If the points
actually were all on a straight line, then of course we'd have (for each
point) y# = m# * x# + b#, so certainly we'd also have Sy# = m# * Sx# + n#
* b# (n# is the number of points, I made it a double now to save later
conversion). We can also multiply the equation at any point by any other
value, so (multiplying by x#) it would also be true that Sxy# = m# * Sxx#
+ b# * Sx#. If the data weren't actually a straight line there's no
particular reason why using completely arbitrary multipliers would lead
to a meaningful answer, but if we are looking for the "least squares" fit
then these particular equations will still be true.

In high school algebra you may have learned several different methods to
solve a system of linear equations such as this and thus find m# and b#,
I suppose which method you choose doesn't matter too much. Provided that
the two equations are not simply multiples of each other, we can solve
this system by any method you know and the answers will be the same.

  d# = Sx# * Sx# - n# * Sxx#
' if d# = 0, the equations are multiples of each other
  IFZ d# THEN RETURN ($$FALSE)
' otherwise, we can now compute m# and b#
  m# = (Sx# * Sy# - n# * Sxy#) / d#
  b# = (Sx# * Sxy# - Sxx# * Sy#) / d#
  RETURN ($$TRUE)
END FUNCTION

You'll notice, this function was set up to return a value of $$FALSE
(that is, 0) if there is no line that fits the data, otherwise it will
return $$TRUE (that is, -1). A good way to call this function would be as
follows:

  IF Linear (@data[], @m#, @b#) THEN
    PRINT "The best fit linear equation for your data is:"
    PRINT "  y = "; m#; "* x + "; b#
  ELSE
    PRINT "Not enough data or no line fits the data."
  END IF

Your other three functions would simply transform the data by taking a
logarithm of x, y or both, and then use Linear to fit a line to the
transformed data, and then transform m# and b# if necessary. Note that
your program will need to IMPORT "xma" in order to use the LOG function.
Also note, whichever value LOG is applied to better not be negative or
zero - in the case of a power equation that means neither x nor y is
allowed to be negative or 0.

FUNCTION LogFit (POINT data[], m#, b#)
  POINT logData[]
  IFF data[] THEN RETURN ($$FALSE)
  upper = UBOUND(data[])
  DIM logData[upper]
  FOR i = 0 TO upper
    logData[i].x = LOG(data[i].x)
    logData[i].y = data[i].y
  NEXT i
' not required to transform m# or b# in this case, so ...
  RETURN (Linear (@logData[], @m#, @b#)
END FUNCTION

FUNCTION ExpFit (POINT data[], m#, b#)
  POINT expData[]
  IFF data[] THEN RETURN ($$FALSE)
  upper = UBOUND(data[])
  DIM expData[upper]
  FOR i = 0 TO upper
    expData[i].x = data[i].x
    expData[i].y = LOG(data[i].y)
  NEXT i
  IF Linear (@expData[], @m#, @b#) THEN
    b# = EXP(b#)
    RETURN ($$TRUE)
  ELSE
    RETURN ($$FALSE)
  END IF
END FUNCTION

FUNCTION PowerFit (POINT data[], m#, b#)
  POINT powerData[]
  IFF data[] THEN RETURN ($$FALSE)
  upper = UBOUND(data[])
  DIM powerData[upper]
  FOR i = 0 TO upper
    powerData[i].x = LOG(data[i].x)
    powerData[i].y = LOG(data[i].y)
  NEXT i
  IF Linear (@powerData[], @m#, @b#) THEN
    b# = EXP(b#)
    RETURN ($$TRUE)
  ELSE
    RETURN ($$FALSE)
  END IF
END FUNCTION

So there are your four functions (deleting my remarks). You'll find them
along with a quick demo in the attached file bestfit.x.

Steven Gunhouse