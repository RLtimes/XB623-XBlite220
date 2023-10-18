' #################### (c) 2000-2005 Alexander Ivanov: eto@applet-bg.com
' #####  PROLOG  ##### An XBasic/XBlite Statistical Library for raw (not arranged) data
' #################### Subject to LGPL (see http://www.gnu.org/copyleft/lgpl.html)
'
' I'll try to write some remarks here. I hope you'll understand this remarks
' regardless of my wrong English. Sorry!
'
' About compilation:
' 1) You can use the library with both XBasic and XBlite (of course in Win only).
'    Linux users can copy the library functions in their source. In the library is
'    used only one external functions - LOG() for xma library. It is located in
'    Xsts_LambdaSqr(). You have to redact its name to Log() to compile the
'    library in XBlite, or to LOG() to compile in XBasic.
' 2) Type in MS-DOS Prompt:
'       xb xsts.x -lib
'       nmake -f xsts.mak
'    or
'       xblite xsts.x -lib
'       xsts.bat
' 3) To create the library accessible for all purposes you have to copy
'       xsts.dll --> XB/bin
'       xsts.dec --> XB/incude
'       xsts.lib --> XB/lib
'
' Some explanations:
' 1) For default the parameter *power* is closed inclisively between 1 an 4
'    (see initial function xsts()).
'    In run-time you can get the actual limits with finctions
'       XstsGetMinPower()
'       XstsGetMaxPower()
'    and set them with
'       XstsSetMinPower(n)
'       XstsSetMaxPower(n)
'    This integer parameter assigns the degrees of power for estimations of sums
'    and moments.
'    All moments are solved with denominator N, nor with (N-1).
' 2) All functions estimating or using a value based on the difference
'    between data and mean have a parameter *unbiased*. This is a boolean
'    parameter. If you set $$TRUE here you'll get or use an unbiased
'    estimation (an estimation of population). If you set $$FALSE here
'    you'll get or use a biased estimation (an estimation of sample).
' 3) The function Xsts_tStudent() solving the t-test of Student has
'    a boolean parameter *same*. If your assumption is the two samples
'    are drawed from single population set $$TRUE here. Else you have to
'    put $$FALSE in this parameter. Remember that the degrees of freedom for
'    this test can be real.
' 4) After using any functions you can test XstsGetWarning(). If this function
'    returns a non-zero value that means the called finction is generated a warning
'    message. You can get the name of this functions with
'       XstsGetWarning$(XstsGetWorning())
'    and clean warning message with XstsCleanWorning(). For example:
'       t# = Xsts_tStudent (@X#[], @Y#[], 0, 0, @f#)
'       IF XstsGetWarning() THEN
'         PRINT "There is an warning message from function ";XstsGetWarning$(XstsGetWarning())
'         XstsCleanWarning()
'       END IF
'    NOTE: No any function cleans the warning message "automaticaly": you have to
'    clean it yourself with calling the function XstsCleanWarning().
' 5) There is not a (pseudo)random number generator here. The XBlite users 
'    can use the random number generator from xsx library; the XBasic users -
'    xbrandom.zip from XBasic file area in Yahoo.
'
' Some suggestions:
'
' 1)
'   AbsoluteVariance = XstsVariance(@X#[], 0) * XstsN(@X#[])
' or
'   AbsiluteVariance = XstsCentralMoment(@X#[], 2) * XstsN(@X#[])
' or (stupid)
'   AbsoluteVariance = XstsVariance(@X#[], 1) * (XstsN(@X#[]) - 1)
'
' 2) In similar way you can resolve the moments with denominator (N-1):
'       mu2=XstsCentralMoment(@X#[],2)
'       mu2N1 = mu2 * XstsN(@X[]) / (XstsN(@X[]) - 1)
'
' 3) Be caråful! For some reasons 
'
'   a) IF XstsMean(@X#[]) = XstsMean(@X#[]) --> true
'
'   b) m1=XstsMean(@X#[]: m2=XstsMean(@X[])
'      IF m1 = m2 --> true
'
' but
'
'   c) m1 = XstsMean(@X#[])
'      IF m1 = XstsMean(@X#[]) --> NOT TRUE !!!
'
' The difference between the variable and the result of function is very, very small
' but it can be greater than "epsylon" (machine error, approximately = 1.11d-16).
' And that is not good!
'
' Regards
' Sasho
'
PROGRAM	"xsts"
VERSION	"4.0001" '	Last modification: 18.09.2005
'
	IMPORT	"xma" ' === Log() [or LOG() for XBlite] in Xsts_LambdaSqr() ===
'
INTERNAL FUNCTION  xsts ()
'
EXPORT
	DECLARE FUNCTION DOUBLE XstsN (DOUBLE X[])
	DECLARE FUNCTION DOUBLE XstsSum (DOUBLE X[], power)
	DECLARE FUNCTION DOUBLE XstsMean (DOUBLE X[])
	DECLARE FUNCTION DOUBLE XstsMinValue (DOUBLE X[])
	DECLARE FUNCTION DOUBLE XstsMaxValue (DOUBLE X[])
	DECLARE FUNCTION DOUBLE XstsDeltaMax (DOUBLE X[])
	DECLARE FUNCTION DOUBLE XstsAbsolutMoment (DOUBLE X[], DOUBLE point, power)
	DECLARE FUNCTION DOUBLE XstsRawMoment (DOUBLE X[], power)
	DECLARE FUNCTION DOUBLE XstsCentralMoment (DOUBLE X[], power)
	DECLARE FUNCTION DOUBLE XstsVariance (DOUBLE X[], unbiased)
	DECLARE FUNCTION DOUBLE XstsStdDev (DOUBLE X[], unbiased)
	DECLARE FUNCTION DOUBLE XstsSkewness (DOUBLE X[], unbiased)
	DECLARE FUNCTION DOUBLE XstsKurtosis (DOUBLE X[], unbiased)
'==========================
' Standard Error of...
'==========================
	DECLARE FUNCTION DOUBLE XstsSEMean (DOUBLE X[], unbiased)
	DECLARE FUNCTION DOUBLE XstsSEVariance (DOUBLE X[], unbiased)
	DECLARE FUNCTION DOUBLE XstsSEStdDev (DOUBLE X[], unbiased)
'
'
'
	DECLARE FUNCTION  XstsCenterAndNorm (DOUBLE old[], DOUBLE new[], unbiased)
'==========================
' Statistical tests
'==========================
' F-test of Fisher (comparing two variances)
	DECLARE FUNCTION DOUBLE Xsts_FFisher (DOUBLE X[], DOUBLE Y[], unbiased, @fmin, @fmax)
' t-test of Student (comparing two averages)
	DECLARE FUNCTION DOUBLE Xsts_tStudent (DOUBLE X[], DOUBLE Y[], same, unbiased, DOUBLE @f)
' Lambda-Square-test of Kolmogorov-Smirnov (two-sample test)
	DECLARE FUNCTION DOUBLE Xsts_LambdaSqr (DOUBLE X[], DOUBLE Y[], DOUBLE alpha, DOUBLE @criticalLambda)
'==========================
' Mescellaneous functions
'==========================
	DECLARE FUNCTION  XstsSetMinPower (n)
	DECLARE FUNCTION  XstsGetMinPower ()
	DECLARE FUNCTION  XstsSetMaxPower (n)
	DECLARE FUNCTION  XstsGetMaxPower ()
	DECLARE FUNCTION  XstsGetWarning ()
	DECLARE FUNCTION  XstsGetWarning$ (warning)
	DECLARE FUNCTION  XstsCleanWarning ()
'====================
' Warning constants
'====================
	$$XstsN_warning							= 1
	$$XstsSum_warning					  = 2
	$$XstsMean_warning					= 3
	$$XstsMinValue_warning			= 4
	$$XstsMaxValue_warning			= 5
	$$XstsDeltaMax_warning			= 6
	$$XstsAbsolutMoment_warning = 7
	$$XstsRawMoment_warning			= 8
	$$XstsCentralMoment_warning	= 9
	$$XstsVariance_warning			= 10
	$$XstsStdDev_warning				= 11
	$$XstsSkewness_warning			= 12
	$$XstsKurtosis_warning			= 13
	$$XstsSEMean_warning				= 14
	$$XstsSEVariance_warning		= 15
	$$XstsSEStdDev_warning			= 16
	$$Xsts_FFisher_warning			= 17
	$$Xsts_tStudent_warning			= 18
	$$Xsts_LambdaSqr_warning		= 19
	$$XstsCenterAndNorm_warning	= 20
'
END EXPORT
'
INTERNAL FUNCTION  XstsQuickSort (DOUBLE unsorted[], DOUBLE sorted[])
INTERNAL FUNCTION  XstsDuplicate (DOUBLE current[], DOUBLE new[])
'
FUNCTION  xsts ()
	XstsSetMinPower(1)
	XstsSetMaxPower(4)
END FUNCTION
'
FUNCTION  DOUBLE XstsN (DOUBLE X[])
	IFZ X[] THEN #__warning = $$XstsN_warning
END FUNCTION UBOUND(X[]) + 1
'
FUNCTION DOUBLE XstsSum (DOUBLE X[], power)
	DOUBLE sum

	IFZ X[] THEN #__warning=$$XstsSum_warning: RETURN 0
	IF power < #__MinPower THEN #__warning=$$XstsSum_warning: RETURN 0
	IF power > #__MaxPower THEN #__warning=$$XstsSum_warning: RETURN 0

	IF power=1 THEN	' faster
		FOR i=0 TO UBOUND(X[])
		  sum=sum+X[i]
		NEXT
	ELSE
		FOR i=0 TO UBOUND(X[])
		  sum=sum+X[i]**power
		NEXT
	END IF
END FUNCTION sum
'
FUNCTION DOUBLE XstsMean (DOUBLE X[])
	IFZ X[] THEN #__warning = $$XstsMean_warning: RETURN 0
END FUNCTION XstsRawMoment(@X[],1)
'
FUNCTION DOUBLE XstsMinValue (DOUBLE X[])
	DOUBLE min

	IFZ X[] THEN #__warning=$$XstsMinValue_warning: RETURN 0

	min = X[0]
	FOR i=1 TO UBOUND(X[])
		IF X[i] < min THEN min = X[i]
	NEXT
END FUNCTION min
'
FUNCTION DOUBLE XstsMaxValue (DOUBLE X[])
	DOUBLE max

	IFZ X[] THEN #__warning=$$XstsMaxValue_warning: RETURN 0

	max = X[0]
	FOR i=1 TO UBOUND(X[])
		IF max < X[i] THEN max = X[i]
	NEXT

END FUNCTION max
'
FUNCTION DOUBLE XstsDeltaMax (DOUBLE X[])
	DOUBLE max, test

	IFZ X[] THEN #__warning = $$XstsDeltaMax_warning: RETURN 0
	IF UBOUND(X[])=0 THEN RETURN 0

	XstsQuickSort(@X[], @sorted#[])
	FOR i = 1 TO UBOUND(sorted#[])
		test=ABS(sorted#[i]-sorted#[i-1])
		IF test > max THEN max = test
	NEXT
END FUNCTION max
' Absolut moments
FUNCTION DOUBLE XstsAbsolutMoment (DOUBLE X[], DOUBLE point, power)
	DOUBLE am, test

	IFZ X[] THEN #__warning=$$XstsAbsolutMoment_warning: RETURN 0
	IF UBOUND(X[])=0 THEN RETURN 0
	IF (power < #__MinPower) THEN #__warning=$$XstsAbsolutMoment_warning: RETURN 0
	IF (power > #__MaxPower) THEN #__warning=$$XstsAbsolutMoment_warning: RETURN 0

	IF power=1 THEN								' The trivial case: sums of differenses
		test = XstsMean(@X[])				' Don't reduce this code because
		IF test=point THEN RETURN 0	' (point = XstsMean(@X[])) is not true!
	END IF

  FOR i=0 TO UBOUND(X[])
		am=am+(X[i]-point)**power
	NEXT

END FUNCTION am / XstsN(@X[])
' Raw (crude) moments
FUNCTION  DOUBLE XstsRawMoment (DOUBLE X[], power)

	IFZ X[] THEN #__warning=$$XstsRawMoment_warning: RETURN 0
	IF UBOUND(X[])= 0 THEN RETURN 0
	IF (power < #__MinPower) THEN #__warning=$$XstsRawMoment_warning: RETURN 0
	IF (power > #__MaxPower) THEN #__warning=$$XstsRawMoment_warning: RETURN 0

END FUNCTION (XstsSum(@X[], power) / XstsN(@X[]))
' Central moments
FUNCTION  DOUBLE XstsCentralMoment (DOUBLE X[], power)
	DOUBLE mean, mu

	IFZ X[] THEN #__warning=$$XstsCentralMoment_warning: RETURN 0
	IF UBOUND(X[])=0 THEN RETURN 0
	IF power < #__MinPower THEN #__warning=$$XstsCentralMoment_warning: RETURN 0
	IF power > #__MaxPower THEN #__warning=$$XstsCentralMoment_warning: RETURN 0

	IF power = 1 THEN RETURN 0	' Always zero...

	mean = XstsMean(@X[])
	FOR i=0 TO UBOUND(X[])
		mu=mu + (X[i] - mean)**power
	NEXT
END FUNCTION mu / XstsN(@X[])
'
FUNCTION DOUBLE XstsVariance (DOUBLE X[], unbiased)
	DOUBLE V, m2, m1

	IFZ X[] THEN #__warning=$$XstsVariance_warning: RETURN 0
	N=XstsN(@X[])
	IF N < 2 THEN #__warning=$$XstsVariance_warning: RETURN 0

	V = XstsCentralMoment(@X[],2)
  IF unbiased THEN
		V = (V * N) / (N - 1)
	END IF

END FUNCTION V
'
FUNCTION DOUBLE XstsStdDev (DOUBLE X[], unbiased)
	DOUBLE V

	IFZ X[] THEN #__warning = $$XstsStdDev_warning: RETURN 0
	IF UBOUND(X[]) < 1 THEN #__warning = $$XstsStdDev_warning: RETURN 0

	V = XstsVariance(@X[], unbiased)
END FUNCTION V ** 0.5#
'
FUNCTION DOUBLE XstsSkewness (DOUBLE X[], unbiased)
	DOUBLE Skew, mu3, mu2

	IFZ X[] THEN #__warning=$$XstsSkewness_warning: RETURN 0
	N = XstsN(@X[])
	IF N < 3 THEN #__warning=$$XstsSkewness_warning: RETURN 0

	mu2 = XstsCentralMoment(@X[],2)
  mu3 = XstsCentralMoment(@X[],3)
	Skew = mu3 / mu2**1.5#
	IF unbiased THEN Skew = (N * (N - 1))**0.5# * Skew / (N - 2)

END FUNCTION Skew
'
FUNCTION DOUBLE XstsKurtosis (DOUBLE X[], unbiased)
  DOUBLE mu4, mu2, kurtosis, N

	IFZ X[] THEN #__warning=$$XstsKurtosis_warning: RETURN 0
	N = XstsN(@X[])
	IF N < 4 THEN #__warning=$$XstsKurtosis_warning: RETURN 0

	mu4=XstsCentralMoment(@X[], 4)
	mu2=XstsCentralMoment(@X[], 2)
	kurtosis = (mu4 / (mu2 * mu2)) - 3
	IF unbiased THEN kurtosis = (kurtosis + (6 / (N + 1))) * (N * N - 1) / ((N - 2) * ( N - 3))

END FUNCTION kurtosis
'
FUNCTION DOUBLE XstsSEMean (DOUBLE X[], unbiased)

	IFZ X[] THEN #__warning=$$XstsSEMean_warning: RETURN 0
	IF UBOUND(X[]) < 1 THEN #__warning=$$XstsSEMean_warning: RETURN 0

END FUNCTION XstsStdDev(@X[],unbiased) / (XstsN(@X[])**0.5#)
'
FUNCTION DOUBLE XstsSEVariance (DOUBLE X[], unbiased)
	DOUBLE N

	IFZ X[] THEN #__warning=$$XstsSEVariance_warning: RETURN 0
	N=XstsN(@X[])
	IF N < 2 THEN #__warning=$$XstsSEVariance_warning: RETURN 0

END FUNCTION XstsVariance(@X[], unbiased) * (N/2#)**0.5#
'
'##########################################################
' NOTE: Following function gets an approximate estimation
'##########################################################
'
FUNCTION DOUBLE XstsSEStdDev (DOUBLE X[], unbiased)
	DOUBLE N

	IFZ X[] THEN #__warning=$$XstsSEStdDev_warning: RETURN 0
	N=XstsN(@X[])
	IF N < 2 THEN #__warning=$$XstsSEStdDev_warning: RETURN 0

END FUNCTION XstsStdDev(@X[], unbiased) * (2*N) ** 0.5#
'
FUNCTION  XstsCenterAndNorm (DOUBLE old[], DOUBLE new[], unbiased)
	DOUBLE mean, stddev
	
	IFZ old[] THEN #__warning=$$XstsCenterAndNorm_warning: 	REDIM new[]: RETURN

	mean = XstsMean(@old[])
	stddev=XstsStdDev(@old[], unbiased)
	IF XstsGetWarning() THEN RETURN

	REDIM new[UBOUND(old[])]
	FOR i=0 TO UBOUND(old[]): new[i]=(old[i]-mean)/stddev: NEXT
END FUNCTION
'
FUNCTION DOUBLE Xsts_FFisher (DOUBLE X[], DOUBLE Y[], unbiased, @fmin, @fmax)
	DOUBLE Vx,Vy,F,Nx,Ny

	IFZ X[] THEN #__warning=$$Xsts_FFisher_warning: RETURN 0
	Nx=XstsN(@X[])
	IF Nx < 2 THEN #__warning=$$Xsts_FFisher_warning: RETURN 0

	IFZ Y[] THEN #__warning=$$Xsts_FFisher_warning: RETURN 0
	Ny=XstsN(@Y[])
	IF Ny < 2 THEN #__warning=$$Xsts_FFisher_warning: RETURN 0

	Vx = XstsVariance(@X[], unbiased)
	Vy = XstsVariance(@Y[], unbiased)

	IF Vx > Vy THEN
		F = Vx / Vy
		fmax = Nx - 1
		fmin = Ny - 1
	ELSE
		F = Vy / Vx
		fmax = Ny - 1
		fmin = Nx - 1
	END IF

END FUNCTION F
'
FUNCTION DOUBLE Xsts_tStudent (DOUBLE X[], DOUBLE Y[], same, unbiased, @DOUBLE f)
	DOUBLE Nx, Ny, Vx, Vy, s

	f = 0

	IFZ X[] THEN #__warning=$$Xsts_tStudent_warning: RETURN 0
	Nx=XstsN(@X[])
	IF Nx < 2 THEN #__warning=$$Xsts_tStudent_warning: RETURN 0

	IFZ Y[] THEN #__warning=$$Xsts_tStudent_warning: RETURN 0
	Ny=XstsN(@Y[])
	IF Ny < 2 THEN #__warning=$$Xsts_tStudent_warning: RETURN 0

	s = 0
	f = Nx + Ny - 2
	IF f > 1 THEN
		IF same THEN
			Vx = XstsVariance(@X[], unbiased)
			Vy = XstsVariance(@Y[], unbiased)
			s = ((Nx - 1) * Vx + (Ny - 1) * Vy) / f
			s = (s * ((Nx + Ny) / (Nx * Ny)))**0.5#
			s = ABS(XstsMean(@X[]) - XstsMean(@Y[])) / s
		ELSE
			Vx = XstsVariance(@X[], unbiased)
			Vy = XstsVariance(@Y[], unbiased)
			s = (Vx / Nx + Vy / Ny)**0.5#
			s = ABS(XstsMean(@X[]) - XstsMean(@Y[])) / s
			f = f * (0.5# + (Vx * Vy / (Vx * Vx + Vy * Vy)))
		END IF
	END IF
END FUNCTION s
'
FUNCTION DOUBLE Xsts_LambdaSqr (DOUBLE X[], DOUBLE Y[], DOUBLE alpha, @DOUBLE criticalLambda)

	DOUBLE Xs[], Ys[], RangX, RangY, Delta, Nx, Ny

	IFZ X[] THEN criticalLambda = 0: #__warning=$$Xsts_LambdaSqr_warning:	RETURN 0
	IFZ Y[] THEN criticalLambda = 0: #__warning=$$Xsts_LambdaSqr_warning:	RETURN 0

	IF (alpha > 0) AND (alpha <= 1) THEN
		criticalLambda = 0.5# * Log(2 / alpha)
	ELSE
		criticalLambda = 0
		#__warning=$$Xsts_LambdaSqr_warning
		RETURN 0
	END IF

	XstsQuickSort(@X[], @Xs[])
	XstsQuickSort(@Y[], @Ys[])

	Nx = XstsN(@X[])
	Ny = XstsN(@Y[])
	i = 0: j = 0

	DO
		IF i < Nx THEN
			IF j < Ny THEN
				IF Xs[i] < Ys[j] THEN
					RangX = RangX + (1 / Nx)
					IF i < Nx THEN INC i
				ELSE
					IF Xs[i] = Ys[j] THEN
						RangX = RangX + (1 / Nx)
						IF i < Nx THEN INC i
						RangY = RangY + (1 / Ny)
						IF j < Ny THEN INC j
					END IF
				END IF
			ELSE
				RangX = RangX + (1 / Nx)
				INC i
			END IF
		END IF
		IF ABS(RangX - RangY) > Delta THEN Delta = ABS(RangX - RangY)
		IF j < Ny THEN
			IF i < Nx THEN
				IF Ys[j] < Xs[i] THEN
					RangY = RangY + (1 / Ny)
					IF j < Ny THEN INC j
				ELSE
					IF Ys[j] = Xs[i] THEN
						RangY = RangY + (1 / Ny)
						IF j < Ny THEN INC j
						RangX = RangX + (1 / Nx)
						IF i < Nx THEN INC i
					END IF
				END IF
			ELSE
				RangY = RangX + (1 / Ny)
				INC j
			END IF
		END IF
		IF ABS(RangX - RangY) > Delta THEN Delta = ABS(RangX - RangY)
	LOOP UNTIL (i >= Nx) AND (j >= Ny)

END FUNCTION Delta * Delta * Nx * Ny /(Nx + Ny)
'
FUNCTION  XstsSetMinPower (n)
	#__MinPower = n
END FUNCTION
'
FUNCTION  XstsGetMinPower()
END FUNCTION #__MinPower
'
FUNCTION  XstsSetMaxPower (n)
	#__MaxPower = n
END FUNCTION
'
FUNCTION  XstsGetMaxPower()
END FUNCTION #__MaxPower
'
FUNCTION  XstsGetWarning ()
END FUNCTION #__warning
'
FUNCTION  XstsGetWarning$ (warning)
SELECT CASE warning
  CASE 0                            : RETURN "No warning"
	CASE $$XstsN_warning							: RETURN "XstsN()"
	CASE $$XstsSum_warning						: RETURN "XstsSum()"
	CASE $$XstsMean_warning						: RETURN "XstsMean()"
	CASE $$XstsMinValue_warning				: RETURN "XstsMinValue()"
	CASE $$XstsMaxValue_warning				: RETURN "XstsMaxValue()"
	CASE $$XstsDeltaMax_warning				: RETURN "XstsDeltaMax()"
	CASE $$XstsAbsolutMoment_warning  : RETURN "XstsAbsolutMoment"
	CASE $$XstsRawMoment_warning			: RETURN "XstsRawMoment()"
	CASE $$XstsCentralMoment_warning	: RETURN "XstsCentralMoment()"
	CASE $$XstsVariance_warning				: RETURN "XstsVariance()"
	CASE $$XstsStdDev_warning					: RETURN "XstsStdDev()"
	CASE $$XstsSkewness_warning				: RETURN "XstsSkewness()"
	CASE $$XstsKurtosis_warning				: RETURN "XstsKurtosis()"
	CASE $$XstsSEMean_warning					: RETURN "XstsSEMean()"
	CASE $$XstsSEVariance_warning			: RETURN "XstsSEVariance()"
	CASE $$XstsSEStdDev_warning				: RETURN "XstsSEStdDev()"
	CASE $$Xsts_FFisher_warning				: RETURN "Xsts_FFisher()"
	CASE $$Xsts_tStudent_warning			: RETURN "Xsts_tStudent()"
	CASE $$Xsts_LambdaSqr_warning			: RETURN "Xsts_LambdaSqr()"
	CASE $$XstsCenterAndNorm_warning	: RETURN "XstsCenterAndNorm()"
  CASE ELSE
        RETURN "unrecognized warning"
END SELECT
END FUNCTION
'
FUNCTION  XstsCleanWarning ()
	#__warning=$$FALSE
END FUNCTION
'
FUNCTION  XstsQuickSort (DOUBLE unsorted[], DOUBLE sorted[])
	$Left = 0
	$Right= 1

	DOUBLE X

		XstsDuplicate(@unsorted[], @sorted[])

		DIM Stack[1,1]


		sPtr = 1
		Stack[sPtr,$Left] = 0
		Stack[sPtr,$Right] = UBOUND(sorted[])

		DO
			L = Stack[sPtr,$Left]
			R = Stack[sPtr,$Right]
			DEC sPtr

			DO
				i = L: j = R: X = sorted[(L + R) \ 2]
				DO
					DO WHILE sorted[i] < X: INC i: LOOP
					DO WHILE sorted[j] > X: DEC j: LOOP
					IF i <= j THEN
						SWAP sorted[i], sorted[j]
						INC i
						DEC j
					END IF
				LOOP UNTIL i > j

				IF (j - L) < (R - i) THEN
					IF i < R THEN
						INC sPtr: REDIM Stack[sPtr,1]
						Stack[sPtr,$Left] = i
						Stack[sPtr,$Right] = R
					END IF
					R = j
				ELSE
					IF L < j THEN
						INC sPtr: REDIM Stack[sPtr,1]
						Stack[sPtr,$Left] = L
						Stack[sPtr,$Right] = j
					END IF
					L = i
				END IF
			LOOP WHILE L < R

		LOOP WHILE sPtr

END FUNCTION
'
FUNCTION  XstsDuplicate (DOUBLE current[], DOUBLE new[])
  test = UBOUND(current[])
	REDIM new[test]
	FOR i = 0 TO test
		new[i]=current[i]
	NEXT
END FUNCTION
END PROGRAM
