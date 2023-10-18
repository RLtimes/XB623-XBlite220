'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' RNGs is a RNG function library. It contains
' 18 RNG functions, 10 RNG test functions, as
' well as various RN conversion functions.
' ---
' It is not recommended that any of these
' functions be used for generating crypto RNs.
' ---
' All Rand_ functions are self-seeding but can
' be seeded with the corresponding Seed_Rand
' function.
' ---
' For more info, see individual RNG functions.
' All functions are in the public domain.
' ---
' Examples:
' To run NIST tests:
'	ULONG data[]
'	DIM data[624]
'	FOR i = 0 TO 624
'  data[i] = Rand_KISS_2 ()
'	NEXT i
'	ret = Monobit_Test (@data[], $$TRUE)
'	ret = Poker_Test (@data[], $$TRUE)
'	ret = Runs_Test (@data[], $$TRUE)
'	ret = Long_Run_Test (@data[], $$TRUE)
' ---
' To run Entropy tests:
' ULONG rn, data[]
'	DIM data[1999999]
'	Seed_Rand_KISS_2 (12345)
'	FOR i = 0 TO 1999999 STEP 4
'  rn = Rand_KISS_2 ()
'  rn = Rand_Integer(Uni_ULTRA ())
'  Int2Byte (rn, @byte1, @byte2, @byte3, @byte4)
'  data[i]   = byte1
'  data[i+1] = byte2
'  data[i+2] = byte3
'  data[i+3] = byte4
'	NEXT i
'	Mean_Test (@data[], @mean#, $$TRUE)
'	Chi_Square_Test (@data[], @chi_squared#, @chip#, -1)
'	Serial_Correlation_Test (@data[], @scc#, $$TRUE)
'	Entropy_Test (@data[], @ent#, $$TRUE)
' ---
' To run Monte Carlo Pi test
'	DOUBLE dataX[], dataY[]
'	DIM dataX[999999]
'	DIM dataY[999999]
'	FOR i = 0 TO 999999
'  dataX[i] = Uniform (Rand_KISS_2())
'  dataY[i] = Uniform (Rand_KISS_2())
'	NEXT i
'Monte_Carlo_Pi_Test (@dataX[], @dataY[], @pi#, @err#, -1)
' ---
' To run Universal test:
'	DIM data[255999]
'	FOR i = 0 TO 255999 STEP 4
'  rn = Rand_CONG ()
'  Int2Byte (rn, @byte1, @byte2, @byte3, @byte4)
'  data[i]   = byte1
'  data[i+1] = byte2
'  data[i+2] = byte3
'  data[i+3] = byte4
'	NEXT i
'	Universal_Test (@data[], @fTU#, @tsd#, $$TRUE)

PROGRAM	"rngs"
VERSION	"0.1001"
CONSOLE
'
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT  "xsx"		' Standard Extended library
	IMPORT	"xma"   ' Math library
	IMPORT	"xio"		' Console IO library
	IMPORT  "kernel32"
'
DECLARE FUNCTION  Entry ()

EXPORT
' ***** Integer RNG functions *****

DECLARE FUNCTION  ULONG  Rand_CONG ()				' CONG - linear congruential generator
DECLARE FUNCTION  ULONG  Rand_IBAA ()				' IBAA - Indirection, Barrelshift, Accumulate and Add RNG
DECLARE FUNCTION  ULONG  Rand_ISAAC ()			' ISAAC - Indirection, Shift, Accumulate, Add, and Count
DECLARE FUNCTION  ULONG  Rand_KISS ()				' KISS - Keep It Simple Stupid
DECLARE FUNCTION  ULONG  Rand_KISS_2 ()
DECLARE FUNCTION  ULONG  Rand_LFIB4 ()			' LFIB4 - Lagged Fibonacci generator
DECLARE FUNCTION  ULONG  Rand_MOTHER ()			' MOTHER - George Marsaglia's - The mother of all random number generators
DECLARE FUNCTION  ULONG  Rand_MT ()					' MT - Mersenne Twister
DECLARE FUNCTION  ULONG  Rand_MWC ()				' MWC - multiply with-carry generator
DECLARE FUNCTION  ULONG  Rand_MWC1019 ()		' MWC1019 - multiply with-carry generator
DECLARE FUNCTION  ULONG  Rand_R250 ()				' R250 - Shift-Register Sequence Random Number Generator
DECLARE FUNCTION  ULONG  Rand_ROTB ()				' ROTB - lagged-Fibonacci with rotation of bits
DECLARE FUNCTION  ULONG  Rand_SHR3 ()				' SHR3 - 3-shift-register prn generator
DECLARE FUNCTION  ULONG  Rand_TAUS ()				' TAUS - maximally equidistributed combined Tausworthe generator
DECLARE FUNCTION  ULONG  Rand_TT800 ()			' TT800 - twisted GFSR generator

' ***** Uniform RNG functions *****

DECLARE FUNCTION  DOUBLE Uniform (ULONG rn)		' convert any integer RN to uni RN

DECLARE FUNCTION  DOUBLE Uni_BORN49 ()				' BORN49 - Binary Oblong Random Number Generator
DECLARE FUNCTION  DOUBLE Uni_MLCG ()					' MLCG - Multiplicitive Linear Congruential Generator
DECLARE FUNCTION  DOUBLE Uni_ULTRA ()					' ULTRA - rng by George Marsaglia

' ***** RNG Seed Functions *****

DECLARE FUNCTION  VOID   Seed_Rand_CONG (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_IBAA (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_ISAAC (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_KISS (ULONG seed_1, ULONG seed_2, ULONG seed_3, ULONG seed_4)
DECLARE FUNCTION  VOID   Seed_Rand_KISS_2 (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_LFIB4 (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_MOTHER (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_MWC (ULONG seed_1, ULONG seed_2)
DECLARE FUNCTION  VOID   Seed_Rand_MWC1019 (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_MT (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_R250 (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_ROTB (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_SHR3 (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_TAUS (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_TT800 (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Rand_ULTRA (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Uni_BORN49 (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Uni_MLCG (ULONG seed)
DECLARE FUNCTION  VOID   Seed_Uni_ULTRA (ULONG seed)

' ***** ENT Test Functions *****
'
' These tests are part of the Fourmilab RNG test program called ENT,
' A Pseudorandom Number Sequence Test Program for
' Entropy calculation and analysis of putative random sequences.
' Designed and implemented by John "Random" Walker in May 1985.
' see http://www.fourmilab.ch/random/
' The tests are useful for those evaluating pseudo-random number generators
' for encryption and statistical sampling applications, compression algorithms,
' and other applications where the information density of a file is of interest.

DECLARE FUNCTION  Chi_Square_Test (ANY data[], DOUBLE chi_squared, DOUBLE chip, report)
DECLARE FUNCTION  Entropy_Test (ANY data[], DOUBLE ent, report)
DECLARE FUNCTION  Mean_Test (ANY data[], DOUBLE mean, report)
DECLARE FUNCTION  Monte_Carlo_Pi_Test (DOUBLE dataX[], DOUBLE dataY[], DOUBLE pi, DOUBLE error, report)
DECLARE FUNCTION  Serial_Correlation_Test (ANY data[], DOUBLE scc, report)

' ***** Universal Test Function *****

' This test is based on the Ueli Maurer Universal Statistical Test
' A Universal Statistical Test for Random Bit Generators
' Journal of Cryptology, vol. 5, no. 2, pp. 89-105, 1992.
' see http://www.inf.ethz.ch/department/TI/um/personal/publications-maurer.html
'
DECLARE FUNCTION  Universal_Test (ANY data[], DOUBLE fTU, DOUBLE tsd, report)

' ***** FIPS Statistical Random Number Generator Tests *****

' These are the randomness tests recommended in the NIST Federal
' Information Processing Standards 140-1 (FIPS PUB 140-1)
' see http://csrc.nist.gov/publications/fips/fips1401.htm
' All four tests must pass for RNG to be validated

DECLARE FUNCTION  Long_Run_Test (ULONG data[], report)
DECLARE FUNCTION  Monobit_Test (ULONG data[], report)
DECLARE FUNCTION  Poker_Test (ULONG data[], report)
DECLARE FUNCTION  Runs_Test (ULONG data[], report)

' ***** Misc test functions *****

DECLARE FUNCTION  Run_All_Tests ()

' ***** MISC RN Functions *****

DECLARE FUNCTION  ULONG  Create_Seed ()
DECLARE FUNCTION  ULONG  Rand_Integer (DOUBLE uni)
DECLARE FUNCTION  ULONG  Range (ULONG min, ULONG max, DOUBLE uni)
DECLARE FUNCTION  ULONG  Shuffle (ULONG data[])

' ***** Statistical Functions *****

DECLARE FUNCTION  Frequency_Data (ANY data[], DOUBLE bin_count, DOUBLE hist[], DOUBLE expected, DOUBLE chi_squared)
DECLARE FUNCTION  Sample_Data (ANY data[], DOUBLE mean, DOUBLE variance, DOUBLE std_dev, DOUBLE min, DOUBLE max, DOUBLE range)

' ***** MISC Functions *****

DECLARE FUNCTION  ULONG  ROTL (ULONG c, ULONG r)																						'Rotate Left
DECLARE FUNCTION  Int2Byte (ULONG int, UBYTE byte1, UBYTE byte2, UBYTE byte3, UBYTE byte4)  'convert integer to 4 bytes
DECLARE FUNCTION  Int2Bits (ULONG rn, bits[])
DECLARE FUNCTION  DOUBLE FMOD (DOUBLE x, DOUBLE y)
DECLARE FUNCTION  Mix (ULONG a, ULONG b, ULONG c, ULONG d, ULONG e, ULONG f, ULONG g, ULONG h)
'
' ***** Constants *****
'
$$INVM      = 2.3283064365387d-10		 '1/(2^32)
$$M         = 4294967296						 '2^32
$$UNIDIV    = 2.3283064370808d-10    '1/(2^32-1)
$$two2neg31 = 4.65661287307739d-10   '1/(2^31)
$$two31     = 2147483648             '2^31
'
END EXPORT
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	ULONG rn, data[]

	IF LIBRARY(0) THEN RETURN

	hStdOut = XioGetStdOut ()

' make console buffer bigger to handle print output
	w = 132
	h = 200
	XioSetConsoleBufferSize (hStdOut, w, h)

' ***** run tests on integer prng's *****

	Run_All_Tests ()

' ***** test individual rng's *****

' Seed_Rand_ISAAC (1234567)
'	FOR i = 0 TO 999
'		rn = Rand_ISAAC ()
'		PRINT i, rn
'	NEXT i
'	PRINT i, rn

'	DIM data[1999999]
'	Seed_Rand_ISAAC (1234567)
'	FOR i = 0 TO 1999999 STEP 4
'		rn = Rand_ISAAC ()
'		Int2Byte (rn, @byte1, @byte2, @byte3, @byte4)
'		data[i]   = byte1
'		data[i+1] = byte2
'		data[i+2] = byte3
'		data[i+3] = byte4
'	NEXT i

'	Mean_Test (@data[], @mean#, $$TRUE)
'	Chi_Square_Test (@data[], @chi_squared#, @chip#, $$TRUE)
'	Serial_Correlation_Test (@data[], @scc#, $$TRUE)
'	Entropy_Test (@data[], @ent#, $$TRUE)

' ***** test Shuffle function *****

'shuffle a deck of cards
'	DIM data[51]
'	FOR i = 1 TO 51 : data[i] = i : NEXT
'	Shuffle (@data[])
'	FOR i = 0 TO 51 : PRINT i, data[i] : NEXT

	a$ = INLINE$ ("Press RETURN to QUIT >")

	XioCloseStdHandle (hStdOut)

END FUNCTION
'
'
' ##########################
' #####  Rand_CONG ()  #####
' ##########################

'   CONG is a linear congruential generator with the widely
'   used 69069 multiplier: x(n)=69069x(n-1)+1234567.
'   It has period 2^32. The leading half of its 32 bits seem
'   to pass tests, but bits in the last half are too regular.
'
'   It is the only RNG in this library that fails the Chi-Square
'   and Universal tests. It is often used for creating seeds.

'	USE	: ULONG rn
'				rn = Rand_CONG ()

FUNCTION  ULONG Rand_CONG ()

	SHARED GIANT jcong_cong

	IFZ jcong_cong THEN jcong_cong = Create_Seed ()

	jcong_cong = (69069 * jcong_cong + 1234567) MOD $$M

	RETURN ULONG(jcong_cong)

END FUNCTION
'
'
' ##########################
' #####  Rand_IBAA ()  #####
' ##########################

' Implementation of Robert Jenkins'
' IBAA (Indirection, Barrelshift, Accumulate and Add) RNG.

' The IA RNG was designed to satisfy these goals:

' * Deducing the internal state from the results should be intractable.
' * The code should be easy to memorize.
' * It should be as fast as possible.

' More requirements were added for IBAA:

' * It should by cryptographically secure \cite{BBS} \cite{Yao}.
' * No biases should be detectable for the entire cycle length.
' * Short cycles should be astronomically rare.

' For details see http://burtleburtle.net/bob/rand/isaac.html

'	USE	: ULONG rn
'				rn = Rand_IBAA ()
'
FUNCTION  ULONG Rand_IBAA ()

	SHARED ULONG seed_ibaa
	GIANT seed
	STATIC GIANT aa, bb
	STATIC c
	STATIC ULONG m[], r[]
	GIANT a, b, x, m
	GIANT y

	$C = 255

	IFZ m[] THEN GOSUB Initialize
	DEC c
	IF c < 0 THEN
		a = aa
		b = bb
		FOR i = 0 TO $C
			x = m[i]
			a = (((a << 19) ^ (a >> 13)) + m[(i+128) & 255]) MOD $$M
			y = (m[ULONG(x & 255)] + a + b) MOD $$M
			m[i] = y
			b = (m[ULONG((y >> 8)) & 255] + x) MOD $$M
			r[i] = b
'PRINT x, a, y, b
		NEXT i
		bb = b
		aa = a
		c = $C
	END IF

	RETURN  r[c]

' ***** Initialize *****
SUB Initialize

	seed = seed_ibaa
	IFZ seed THEN seed = Create_Seed ()
	DIM m[$C]
	DIM r[$C]
	FOR i = 0 TO $C
		seed = 16807 * (seed MOD 127773) - 2836 * (seed/127773)
		IF (seed < 0) THEN seed = seed + 2147483647
		m[i] = seed
'	PRINT "m["; i; "]="; m[i]
	NEXT i
	c = -1
END SUB


END FUNCTION
'
'
' ###########################
' #####  Rand_ISSAC ()  #####
' ###########################

' ISAAC - (Indirection, Shift, Accumulate, Add, and Count)
' generates 32-bit random numbers. Averaged out, it requires
' 18.75 machine cycles to generate each 32-bit value. Cycles
' are guaranteed to be at least 240 values long, and they
' are 28295 values long on average. The results are uniformly
' distributed, unbiased, and unpredictable unless you know
' the seed.

'
FUNCTION  ULONG Rand_ISAAC ()

	STATIC GIANT randrsl[], mm[]
	STATIC GIANT aa, bb, cc
	ULONG a, b, c, d, e, f, g, h, i, x, y
	STATIC refresh

	$gold = 0x9e3779b9

	IFZ randrsl[] THEN GOSUB Initialize

	IF refresh= -1 THEN

		cc = cc + 1							' cc just gets incremented once per 256 results
		bb = bb + cc						' then combined with bb

		FOR i = 0 TO 255
			x = mm[i]
			SELECT CASE i MOD 4
				CASE 0: aa = aa^(aa<<13)
				CASE 1: aa = aa^(aa>>6)
				CASE 2: aa = aa^(aa<<2)
				CASE 3: aa = aa^(aa>>16)
			END SELECT
			aa = ULONG((GIANT(mm[(i+128) MOD 256]) + GIANT(aa)) MOD $$M)
			y  = ULONG((GIANT(mm[(x>>2)  MOD 256]) + GIANT(aa) + GIANT(bb)) MOD $$M)
			mm[i] = y
			bb = ULONG((GIANT(mm[(y>>10) MOD 256]) + GIANT(x)) MOD $$M)
			randrsl[i] = bb
		NEXT i

		refresh = 255
	END IF
	x = randrsl[refresh]
	DEC refresh

	RETURN x

' ***** Initialize *****
SUB Initialize

	DIM randrsl[255]
	DIM mm[255]

'seed randrsl[]
	FOR i = 0 TO 255
		randrsl[i] = Rand_KISS_2 ()
	NEXT i

	a = $gold : b = $gold : c = $gold : d = $gold
	e = $gold : f = $gold : g = $gold : h = $gold

'mix a...h
	FOR i = 0 TO 3
		Mix(@a, @b, @c, @d, @e, @f, @g, @h)
	NEXT i

'fill in mm[] with messy stuff
	FOR i = 0 TO 255 STEP 8
		a=ULONG((GIANT(a)+GIANT(randrsl[i  ])) MOD $$M)
		b=ULONG((GIANT(b)+GIANT(randrsl[i+1])) MOD $$M)
		c=ULONG((GIANT(c)+GIANT(randrsl[i+2])) MOD $$M)
		d=ULONG((GIANT(d)+GIANT(randrsl[i+3])) MOD $$M)
		e=ULONG((GIANT(e)+GIANT(randrsl[i+4])) MOD $$M)
		f=ULONG((GIANT(f)+GIANT(randrsl[i+5])) MOD $$M)
		g=ULONG((GIANT(g)+GIANT(randrsl[i+6])) MOD $$M)
		h=ULONG((GIANT(h)+GIANT(randrsl[i+7])) MOD $$M)
		Mix(a,b,c,d,e,f,g,h)
		mm[i  ]=a : mm[i+1]=b : mm[i+2]=c : mm[i+3]=d
		mm[i+4]=e : mm[i+5]=f : mm[i+6]=g : mm[i+7]=h
	NEXT i

'do a second pass to make all of the seed affect all of mm
	FOR i = 0 TO 255 STEP 8
		a=ULONG((GIANT(a)+GIANT(mm[i  ])) MOD $$M)
		b=ULONG((GIANT(b)+GIANT(mm[i+1])) MOD $$M)
		c=ULONG((GIANT(c)+GIANT(mm[i+2])) MOD $$M)
		d=ULONG((GIANT(d)+GIANT(mm[i+3])) MOD $$M)
		e=ULONG((GIANT(e)+GIANT(mm[i+4])) MOD $$M)
		f=ULONG((GIANT(f)+GIANT(mm[i+5])) MOD $$M)
		g=ULONG((GIANT(g)+GIANT(mm[i+6])) MOD $$M)
		h=ULONG((GIANT(h)+GIANT(mm[i+7])) MOD $$M)
		Mix(a,b,c,d,e,f,g,h)
		mm[i  ]=a : mm[i+1]=b : mm[i+2]=c : mm[i+3]=d
		mm[i+4]=e : mm[i+5]=f : mm[i+6]=g : mm[i+7]=h
	NEXT i

	refresh = -1

'	FOR i = 0 TO 255
'		PRINT mm[i], randrsl[i]
'	NEXT i
END SUB

END FUNCTION
'
'
' ##########################
' #####  Rand_KISS ()  #####
' ##########################
'
'   The KISS generator, (Keep It Simple Stupid), is
'   designed to combine the two multiply-with-carry
'   generators in MWC with the 3-shift register SHR3 and
'   the congruential generator CONG, using addition and
'   exclusive-or. Period about 2^123.
'   It is one of my favorite generators.
'   George Marsaglia

'	USE	: ULONG rn
'				rn = Rand_KISS ()
'
FUNCTION  ULONG Rand_KISS ()

	SHARED ULONG seed_kiss1, seed_kiss2, seed_kiss3, seed_kiss4
	GIANT a
	STATIC GIANT jcong_cong
	STATIC ULONG z_mwc, w_mwc, mwc, jsr_shr3
	ULONG z_new, w_new
	STATIC init

	IFZ init THEN GOSUB Initialize

	GOSUB Cong
	GOSUB Mwc
	GOSUB Shr3

'PRINT mwc, jcong_cong, jsr_shr3
'	a = ((mwc ^ jcong_cong) + jsr_shr3) MOD $$M

	RETURN ULONG(((mwc ^ jcong_cong) + jsr_shr3) MOD $$M)

' ***** Cong *****

SUB Cong
	jcong_cong = (69069 * jcong_cong + 1234567) MOD $$M
END SUB

' ***** Mwc *****
SUB Mwc
	z_mwc = 36969 * (z_mwc & 65535) + (z_mwc >> 16)
	z_new = z_mwc << 16
	w_mwc = 18000 * (w_mwc & 65535) + (w_mwc >> 16)
	w_new = w_mwc & 65535
	mwc =  z_new + w_new
END SUB

' ***** Shr3 *****
SUB Shr3
	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 << 17)
	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 >> 13)
	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 << 5)
END SUB

' ***** Initialize *****
SUB Initialize

	init = $$TRUE

	jcong_cong = seed_kiss1
	z_mwc      = seed_kiss2
	w_mwc      = seed_kiss3
	jsr_shr3   = seed_kiss4

	SELECT CASE ALL FALSE
		CASE jcong_cong : jcong_cong = Create_Seed ()
		CASE z_mwc 			: GOSUB Cong
											z_mwc = jcong_cong
		CASE w_mwc 			: GOSUB Cong
											w_mwc = jcong_cong
		CASE jsr_shr3 	: GOSUB Cong
											jsr_shr3 = jcong_cong
	END SELECT
END SUB
END FUNCTION
'
'
' ############################
' #####  Rand_KISS_2 ()  #####
' ############################

' Typical KISS RNG -
' the idea is to use simple, fast, individually promising
' generators to get a composite that will be fast, easy to code
' have a very long period and pass all the tests put to it.

' The three components of KISS are:
'          i = (69069 * i + 23606797) mod (2 ^ 32)
'          j = (I + (L^15)) * (I + (R^17)) * j mod (2 ^ 32)
'          k = (I + (L^13)) * (I + (R^18)) * k mod (2 ^ 31)
'          x = (i + j + k) mod (2^32)
'
'	USE	: ULONG rn
'				rn = Rand_KISS_2 ()

FUNCTION  ULONG Rand_KISS_2 ()

	SHARED GIANT kiss_i, kiss_j, kiss_k
	STATIC initialize

	$a = 69069
	$b = 23606797
	$M2 = 2147483648

	IFZ initialize THEN GOSUB Initialize

  kiss_i = ($a * kiss_i + $b) MOD $$M
  kiss_j = kiss_j ^ (kiss_j << 17)
  kiss_j = kiss_j ^ (kiss_j >> 15)
  kiss_j = kiss_j MOD $$M
  kiss_k = kiss_k ^ (kiss_k << 18)
  kiss_k = kiss_k ^ (kiss_k >> 13)
  kiss_k = kiss_k MOD $$two31
	RETURN ULONG((kiss_i + kiss_j + kiss_k) MOD $$M)

' ***** Initialize *****
SUB Initialize
	initialize = $$TRUE
	IFZ kiss_i THEN kiss_i = Create_Seed ()
	IFZ kiss_j THEN
		kiss_j = ($a * kiss_i + $b) MOD $$M
	ELSE
		kiss_j = ($a * kiss_j + $b) MOD $$M
	END IF
	IFZ kiss_k THEN
		kiss_k = ($a * kiss_j + $b) MOD $$M
	ELSE
		kiss_k = ($a * kiss_k + $b) MOD $$M
	END IF
'PRINT "Rand_KISS_2 seeds:"; kiss_i, kiss_j, kiss_k
END SUB


END FUNCTION
'
'
' ###########################
' #####  Rand_LFIB4 ()  #####
' ###########################
'
' LFIB4 is an extension of what I have previously
' defined as a lagged Fibonacci generator:
' x(n)=x(n-r) op x(n-s), with the x's in a finite
' set over which there is a binary operation op, such
' as +,- on integers mod 2^32, * on odd such integers,
' exclusive-or(xor) on binary vectors. Except for
' those using multiplication, lagged Fibonacci
' generators fail various tests of randomness, unless
' the lags are very long. (See SWB).
' To see if more than two lags would serve to overcome
' the problems of 2-lag generators using +,- or xor, I
' have developed the 4-lag generator LFIB4 using
' addition: x(n)=x(n-256)+x(n-179)+x(n-119)+x(n-55)
' mod 2^32. Its period is 2^31*(2^256-1), about 2^287,
' and it seems to pass all tests---in particular,
' those of the kind for which 2-lag generators using
' +,-,xor seem to fail.  For even more confidence in
' its suitability,  LFIB4 can be combined with KISS,
' with a resulting period of about 2^410: just use
' (KISS+LFIB4) in any C expression. GM.

'	USE	: ULONG rn
'				rn = Rand_LFIB4 ()
'
FUNCTION  ULONG Rand_LFIB4 ()

	STATIC GIANT t[]
	STATIC UBYTE c

	IFZ t[] THEN GOSUB Initialize

	INC c
	IF c > 255 THEN c = 0
	t[c] = (t[c] + t[(c+58) & 0xFF] + t[(c+119) & 0xFF] + t[(c+178) & 0xFF]) MOD $$M

	RETURN ULONG(t[c])

' ***** Initialize *****

SUB Initialize
	DIM t[255]

	FOR i = 0 TO 255
		t[i] = Rand_KISS_2 ()
	NEXT i
END SUB
END FUNCTION
'
'
' ############################
' #####  Rand_MOTHER ()  #####
' ############################

' This is George Marsaglia's - The mother of all random number generators
' producing uniformly distributed pseudo random 32 bit values
' with a period about 2^250.

' The arrays mother1[] and mother2[] store carry values in their
' first element, and random 16 bit numbers in elements 1 to 8.
' These random numbers are moved to elements 2 to 9 and a new
' carry and number are generated and placed in elements 0 and 1.
' The arrays mother1 and mother2 are filled with random 16 bit values
' on first call of Mother by another generator.

' A 32 bit random number is obtained by combining the output of the
' two generators
'
' ***********************************************

' Marsaglia's comments

'                 Yet another RNG
' Random number generators are frequently posted on
' the network; my colleagues and I posted ULTRA in
' 1992 and, from the number of requests for releases
' to use it in software packages, it seems to be
' widely used.

' I have long been interested in RNG's and several
' of my early ones are used as system generators or
' in statistical packages.

' So why another one?  And why here?

' Because I want to describe a generator, or
' rather, a class of generators, so promising
' I am inclined to call it

'  The Mother of All Random Number Generators

' and because the generator seems promising enough
' to justify shortcutting the many months, even
' years, before new developments are widely
' known through publication in a journal.

' This new class leads to simple, fast programs that
' produce sequences with very long periods.  They
' use multiplication, which experience has shown
' does a better job of mixing bits than do +,- or
' exclusive-or, and they do it with easily-
' implemented arithmetic modulo a power of 2, unlike
' arithmetic modulo a prime.  The latter, while
' satisfactory, is difficult to implement.  But the
' arithmetic here modulo 2^16 or 2^32 does not suffer
' the flaws of ordinary congruential generators for
' those moduli: trailing bits too regular.  On the
' contrary, all bits of the integers produced by
' this new method, whether leading or trailing, have
' passed extensive tests of randomness.

' Here is an idea of how it works, using, say, integers
' of six decimal digits from which we return random 3-
' digit integers.  Start with n=123456, the seed.

' Then form a new n=672*456+123=306555 and return 555.
' Then form a new n=672*555+306=373266 and return 266.
' Then form a new n=672*266+373=179125 and return 125,

' and so on.  Got it?  This is a multiply-with-carry
' sequence x(n)=672*x(n-1)+ carry mod b=1000, where
' the carry is the number of b's dropped in the
' modular reduction. The resulting sequence of 3-
' digit x's has period 335,999.  Try it.

' No big deal, but that's just an example to give
' the idea. Now consider the sequence of 16-bit
' integers produced by the two C statements:

' k=30903*(k&65535)+(k>>16); return(k&65535);

' Notice that it is doing just what we did in the
' example: multiply the bottom half (by 30903,
' carefully chosen), add the top half and return the
' new bottom.

' That will produce a sequence of 16-bit integers
' with period > 2^29, and if we concatenate two
' such:
'          k=30903*(k&65535)+(k>>16);
'          j=18000*(j&65535)+(j>>16);
'          return((k<<16)+j);
' we get a sequence of more than 2^59 32-bit integers
' before cycling.

' The following segment in a (properly initialized)
' C procedure will generate more than 2^118
' 32-bit random integers from six random seed values
' i,j,k,l,m,n:
'              k=30903*(k&65535)+(k>>16);
'              j=18000*(j&65535)+(j>>16);
'              i=29013*(i&65535)+(i>>16);
'              l=30345*(l&65535)+(l>>16);
'              m=30903*(m&65535)+(m>>16);
'              n=31083*(n&65535)+(n>>16);
'              return((k+i+m)>>16)+j+l+n);

' And it will do it much faster than any of several
' widely used generators designed to use 16-bit
' integer arithmetic, such as that of Wichman-Hill
' that combines congruential sequences for three
' 15-bit primes (Applied Statistics, v31, p188-190,
' 1982), period about 2^42.

' I call these multiply-with-carry generators. Here
' is an extravagant 16-bit example that is easily
' implemented in C or Fortran. It does such a
' thorough job of mixing the bits of the previous
' eight values that it is difficult to imagine a
' test of randomness it could not pass:

' x[n]=12013x[n-8]+1066x[n-7]+1215x[n-6]+1492x[n-5]+1776x[n-4]
'  +1812x[n-3]+1860x[n-2]+1941x[n-1]+carry mod 2^16.

' The linear combination occupies at most 31 bits of
' a 32-bit integer. The bottom 16 is the output, the
' top 15 the next carry. It is probably best to
' implement with 8 case segments. It takes 8
' microseconds on my PC. Of course it just provides
' 16-bit random integers, but awfully good ones. For
' 32 bits you would have to combine it with another,
' such as

' x[n]=9272x[n-8]+7777x[n-7]+6666x[n-6]+5555x[n-5]+4444x[n-4]
'          +3333x[n-3]+2222x[n-2]+1111x[n-1]+carry mod 2^16.

' Concatenating those two gives a sequence of 32-bit
' random integers (from 16 random 16-bit seeds),
' period about 2^250. It is so awesome it may merit
' the Mother of All RNG's title.

' The coefficients in those two linear combinations
' suggest that it is easy to get long-period
' sequences, and that is true.  The result is due to
' Cemal Kac, who extended the theory we gave for
' add-with-carry sequences: Choose a base b and give
' r seed values x[1],...,x[r] and an initial 'carry'
' c. Then the multiply-with-carry sequence

'  x[n]=a1*x[n-1]+a2*x[n-2]+...+ar*x[n-r]+carry mod b,

' where the new carry is the number of b's dropped
' in the modular reduction, will have period the
' order of b in the group of residues relatively
' prime to m=ar*b^r+...+a1b^1-1.  Furthermore, the
' x's are, in reverse order, the digits in the
' expansion of k/m to the base b, for some 0<k<m.

' In practice b=2^16 or b=2^32 allows the new
' integer and the new carry to be the bottom and top
' half of a 32- or 64-bit linear combination of  16-
' or 32-bit integers.  And it is easy to find
' suitable m's if you have a primality test:  just
' search through candidate coefficients until you
' get an m that is a safeprime---both m and (m-1)/2
' are prime.  Then the period of the multiply-with-
' carry sequence will be the prime (m-1)/2. (It
' can't be m-1 because b=2^16 or 2^32 is a square.)

' George Marsaglia geo@stat.fsu.edu

'	USE	: ULONG rn
'				rn = Rand_MOTHER ()

FUNCTION  ULONG Rand_MOTHER ()

	STATIC mother1[], mother2[]
	ULONG number1, number2
	USHORT sNumber
	SHARED ULONG seed_mother

	$m16Long = 65536
	$m16Mask = 0xFFFF
	$m15Mask = 0x7FFF
	$m31Mask = 0x7FFFFFFF

	IFZ mother1[] THEN GOSUB Initialize

' Move elements 1 to 8 to 2 to 9

	FOR i = 7 TO 0 STEP -1
		mother1[i+2] = mother1[i+1]
		mother2[i+2] = mother2[i+1]
	NEXT i

' Put the carry values in numberi

	number1 = mother1[0]
	number2 = mother2[0]

' Form the linear combinations

	number1 = number1 + 1941*mother1[2]+1860*mother1[3]+1812*mother1[4]+1776*mother1[5]+1492*mother1[6]+1215*mother1[7]+1066*mother1[8]+12013*mother1[9]
	number2 = number2 + 1111*mother2[2]+2222*mother2[3]+3333*mother2[4]+4444*mother2[5]+5555*mother2[6]+6666*mother2[7]+7777*mother2[8]+9272*mother2[9]

' Save the high bits of numberi as the new carry

	mother1[0] = number1 / $m16Long
	mother2[0] = number2 / $m16Long

' Put the low bits of numberi into motheri[1]

	mother1[1] = $m16Mask & number1
	mother2[1] = $m16Mask & number2

' Combine the two 16 bit random numbers into one 32 bit

 RETURN ULONG((mother1[1] << 16) + mother2[1])

' ***** Initialize *****

SUB Initialize

	DIM mother1[9]
	DIM mother2[9]

	IFZ seed_mother THEN seed_mother = Create_Seed ()

	sNumber = seed_mother & $m16Mask
	number  = seed_mother & $m31Mask

	FOR n = 8 TO 0 STEP -1
		number = 30903 * sNumber + (number >> 16)  	' one line multiply-with-carry
		mother1[i] = number & $m16Mask
		sNumber = mother1[i]
	NEXT n

	FOR n = 8 TO 0 STEP -1
		number = 30903 * sNumber + (number >> 16)  	' one line multiply-with-carry
		mother2[i] = number & $m16Mask
		sNumber = mother2[i]
	NEXT n

	mother1[0] = mother1[0] & $m15Mask
	mother2[0] = mother2[0] & $m15Mask

END SUB


END FUNCTION
'
'
' ########################
' #####  Rand_MT ()  #####
' ########################

' Mersenne Twister(MT) is a pseudorandom number generator
' developped by Makoto Matsumoto  and Takuji Nishimura
' (alphabetical order) during 1996-1997.

' MT has the following merits:

' * It is designed with consideration on the flaws
'   of various existing generators.
' * The algorithm is coded into a C source downloadable below.
' * Far longer period and far higher order of equidistribution
'   than any other implemented generators.
'   (It is proved that the period is 2^19937-1,
'   and 623-dimensional equidistribution property is assured.)
' * Fast generation. (Although it depends on the system,
'   it is reported that MT is sometimes faster than the
'   standard ANSI-C library in a system with pipeline and
'   cache memory.)
' * Efficient use of the memory.

' C code translated by Vic Drastik (Source: XRandom.x)
'
'	USE	: ULONG rn
'				rn = Rand_MT ()

FUNCTION  ULONG Rand_MT ()

STATIC XLONG m[], index
XLONG y, i
$uMask = 0b10000000000000000000000000000000
$lMask = 0b01111111111111111111111111111111
$magic = 0x9908B0DF
$tmb   = 0x9D2C5680
$tmc   = 0xEFC60000

IFZ m[] THEN GOSUB Initialize

' check if the m[] array needs to be refreshed
IF index==624 THEN GOSUB Refresh

' now grab the next m[] value
y = m[index]

' update the index ,
INC index

' and scramble y a bit to make the next random number
y = y XOR ( (y>>11)          )
y = y XOR ( (y<< 7) AND $tmb )
y = y XOR ( (y<<15) AND $tmc )
y = y XOR ( (y>>18)          )
RETURN ULONG(y)

' ***** Refresh *****

SUB Refresh
' generate 624 new m[] values
FOR i = 0 TO 226
  y = ( m[i] AND $uMask ) OR ( m[i+1] AND $lMask )
  SELECT CASE (y AND 1)
    CASE 0 : m[i] = m[i+397] XOR (y>>1)
    CASE 1 : m[i] = m[i+397] XOR (y>>1) XOR $magic
  END SELECT
NEXT i

FOR i = 227 TO 622
  y = ( m[i] AND $uMask ) OR ( m[i+1] AND $lMask )
  SELECT CASE (y AND 1)
    CASE 0 : m[i] = m[i-227] XOR (y>>1)
    CASE 1 : m[i] = m[i-227] XOR (y>>1) XOR $magic
  END SELECT
NEXT i

y = ( m[623] AND $uMask ) OR ( m[0] AND $lMask )
SELECT CASE (y AND 1)
  CASE 0 : m[623] = m[396] XOR (y>>1)
  CASE 1 : m[623] = m[396] XOR (y>>1) XOR $magic
END SELECT

' reset the index
index = 0
END SUB

' ***** Initialize *****
SUB Initialize

DIM m[623]

FOR i = 0 TO 623
  m[i] = Rand_KISS_2 ()
NEXT i

' force immediate refresh
index = 624

END SUB


END FUNCTION
'
'
' #########################
' #####  Rand_MWC ()  #####
' #########################

'   The  MWC generator concatenates two 16-bit multiply-
'   with-carry generators, x(n)=36969x(n-1)+carry,
'   y(n)=18000y(n-1)+carry  mod 2^16, has period about
'   2^60 and seems to pass all tests of randomness. A
'   favorite stand-alone generator---faster than KISS,
'   which contains it.
'   George Marsaglia

'	USE	: ULONG rn
'				rn = Rand_MWC ()
'
FUNCTION  ULONG Rand_MWC ()

	SHARED ULONG z_mwc, w_mwc
	ULONG z_new, w_new
	GIANT seed2

	IF z_mwc = 0 || w_mwc = 0 THEN
		z_mwc = Create_Seed ()
		seed2 = (z_mwc * 69069 + 1234567) MOD $$M
		w_mwc = ULONG(seed2)
	END IF

	z_mwc = 36969 * (z_mwc & 65535) + (z_mwc >> 16)
	z_new = z_mwc << 16

	w_mwc = 18000 * (w_mwc & 65535) + (w_mwc >> 16)
	w_new = w_mwc & 65535

	RETURN z_new + w_new


END FUNCTION
'
'
' #############################
' #####  Rand_MWC1019 ()  #####
' #############################

' MWC1019 will provide random 32-bit integers at the rate of
' 300 million per second (on a 850MHz PC).

' It requires that you seed Q[0],Q[1],...Q[1018] with 32-bit random
' integers, before calling MWC1019( ) in your main.  You might use a
' good RNG such as KISS to fill the Q array.

' The period of MWC1019 exceeds 10^9824, making it billions and
' billions ... and billions times as long as the highly touted
' longest-period RNG, the Mersenne twister.  It is also several times
' as fast and takes a few lines rather than several pages of code.
' (This is not to say that the Mersenne twister is not a good RNG; it
' is.  I just do not equate complexity of code with randomness.  It is
' the complexity of the underlying randomness that counts.)

' As for randomness, it passes all tests in The Diehard Battery of
' Tests of Randomness
'     http://stat.fsu.edu/pub/diehard
' as well as three new tough tests I have developed with the apparent
' property that a RNG that passes tuftsts.c will pass all the tests in
' Diehard.

' MWC1019 has the property that every possible sequence of 1018
' successive 32-bit integers will appear somewhere in the full period,
' for those concerned with the "equi-distribution" in dimensions
' 2,3,...1016,1017,1018. George Marsaglia

' C code translated by Vic Drastik

'	USE	: ULONG rn
'				rn = Rand_MWC1019 ()
'
FUNCTION  ULONG Rand_MWC1019 ()

	STATIC ULONG Q[], i, c
	ULONG r
	GIANT t

	IFZ Q[] THEN GOSUB Initialize

	t = 147669672$$ * Q[i] + c
	c = GHIGH(t)
	r = GLOW (t)

	Q[i] = r
	IFZ i THEN i = 1018 ELSE DEC i
	RETURN r


' ***** Initialize *****

SUB Initialize
	DIM Q[1018]

	FOR i = 0 TO 1018
  	Q[i] = Rand_KISS_2 ()
	NEXT i

	c = 362436
	i = 1018
END SUB


END FUNCTION
'
'
' ##########################
' #####  Rand_R250 ()  #####
' ##########################

' The R250 method is an method of generating random number by
' shifting registers. The length of the register is 250 which
' results in a period of 2^249. The code provided in the
' implementation of R250 can be easily modified for other
' register lengths. It was implemented by Kirkpatrick and Stoll.

' Kirkpatrick, S., and E. Stoll, 1981; "A Very Fast
'	Shift-Register Sequence Random Number Generator",
' Journal of Computational Physics, V.40

'	USE	: ULONG rn
'				rn = Rand_R250 ()
'
FUNCTION  ULONG Rand_R250 ()

	STATIC r250_index
	ULONG new_rand
	STATIC ULONG r250_buffer[]

	IFZ r250_buffer[] THEN GOSUB Initialize

	IF (r250_index >= 147) THEN
		j = r250_index - 147					' wrap pointer around
	ELSE
		j = r250_index + 103
	END IF

	new_rand = r250_buffer[r250_index] ^ r250_buffer[j]
	r250_buffer[r250_index] = new_rand

	IF (r250_index >= 249) THEN 		' increment pointer for next time
		r250_index = 0
	ELSE
		INC r250_index
	END IF

	RETURN new_rand

' ***** Initialize *****

SUB Initialize

	DIM r250_buffer[249]
	FOR i = 0 TO 249
		r250_buffer[i] = Rand_KISS_2 ()
	NEXT i
END SUB



END FUNCTION
'
'
' ##########################
' #####  Rand_ROTB ()  #####
' ##########################

' Random Number generator 'RANROT' type B
'
'  This is a lagged-Fibonacci type of random number generator with
'  rotation of bits.  The algorithm is:
'  X[n] = ((X[n-j] rotl r1) + (X[n-k] rotl r2)) modulo 2^b

'  The last k values of X are stored in a circular buffer named
'  randbuffer.
'
'  The theory of the RANROT type of generators is described at
'  www.agner.org/random/ranrot.htm

'  This type of RNG has a random cycle length. It is advisable to
'  implement some kind of self-test to determine if the initial
'  state of the RNG has been repeated, and if so, stop the program
'  with an error message. This example does not contain an initial
'  state self-test.

'	USE	: ULONG rn
'				rn = Rand_ROTB ()
'
FUNCTION  ULONG Rand_ROTB ()
	STATIC ULONG randbuffer[]
	SHARED ULONG seed_rotb
	STATIC XLONG r_p1, r_p2
	GIANT s1, s2
	ULONG x

	KK = 17
	JJ = 10
	R1 = 5
	R2 = 3

	IFZ randbuffer[] THEN GOSUB Initialize

' generate next random number
	s1 = ULONG((randbuffer[r_p2] << 5) | ( randbuffer[r_p2] >> 27))    'ROTL(randbuffer[r_p2], R1)
	s2 = ULONG((randbuffer[r_p1] << 3) | ( randbuffer[r_p1] >> 29))    'ROTL(randbuffer[r_p1], R2)

	randbuffer[r_p1] = (s1 + s2) MOD $$M
	x = randbuffer[r_p1]

' rotate list pointers
	DEC r_p1
  IF (r_p1 < 0) THEN r_p1 = KK - 1
	DEC r_p2
  IF (r_p2 < 0) THEN r_p2 = KK - 1

	RETURN x


' ***** Initialize *****
' initialize the random number generator

SUB Initialize

	DIM randbuffer[KK-1]

	IFZ seed_rotb THEN seed_rotb = Create_Seed ()

' put semi-random numbers into the buffer
	FOR i = 0 TO KK - 1
		randbuffer[i] = seed_rotb
    seed_rotb = ULONG((seed_rotb << 5) | ( seed_rotb >> 27))  + 97   'ROTL(seed_rotb,5) + 97
	NEXT i

' initialize pointers to circular buffer
  r_p1 = 0
  r_p2 = JJ

' randomize
  FOR i = 0 TO 299
		Rand_ROTB()
	NEXT i

END SUB


END FUNCTION
'
'
' ##########################
' #####  Rand_SHR3 ()  #####
' ##########################
'
'   SHR3 is a 3-shift-register generator with period
'   2^32-1. It uses y(n)=y(n-1)(I+L^17)(I+R^13)(I+L^5),
'   with the y's viewed as binary vectors, L the 32x32
'   binary matrix that shifts a vector left 1, and R its
'   transpose.  SHR3 seems to pass all except those
'   related to the binary rank test, since 32 successive
'   values, as binary vectors, must be linearly
'   independent, while 32 successive truly random 32-bit
'   integers, viewed as binary vectors, will be linearly
'   independent only about 29% of the time.
'   George Marsaglia

'	USE	: ULONG rn
'				rn = Rand_SHR3 ()

FUNCTION  ULONG Rand_SHR3 ()

	SHARED ULONG jsr_shr3

	IFZ jsr_shr3 THEN jsr_shr3 = Create_Seed ()

	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 << 17)
	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 >> 13)
	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 << 5)
	RETURN jsr_shr3

END FUNCTION
'
'
' ##########################
' #####  Rand_TAUS ()  #####
' ##########################

'  This is a maximally equidistributed combined Tausworthe
'   generator. The sequence is,

'   x_n = (s1_n ^ s2_n ^ s3_n)

'   s1_{n+1} = (((s1_n & 4294967294) <<12) ^ (((s1_n <<13) ^ s1_n) >>19))
'   s2_{n+1} = (((s2_n & 4294967288) << 4) ^ (((s2_n << 2) ^ s2_n) >>25))
'   s3_{n+1} = (((s3_n & 4294967280) <<17) ^ (((s3_n << 3) ^ s3_n) >>11))

'   computed modulo 2^32. In the three formulas above '^' means
'   exclusive-or (C-notation), not exponentiation. Note that the
'   algorithm relies on the properties of 32-bit unsigned integers (it
'   is formally defined on bit-vectors of length 32). I have added a
'   bitmask to make it work on 64 bit machines.

'   We initialize the generator with s1_1 .. s3_1 = s_n MOD m, where
'   s_n = (69069 * s_{n-1}) mod 2^32, and s_0 = s is the user-supplied
'   seed.

'   The period of this generator is about 2^88.

'   From: P. L'Ecuyer, "Maximally Equidistributed Combined Tausworthe
'   Generators", Mathematics of Computation, 65, 213 (1996), 203--213.

'   This is available on the net from L'Ecuyer's home page,

'   http://www.iro.umontreal.ca/~lecuyer/myftp/papers/tausme.ps
'   ftp://ftp.iro.umontreal.ca/pub/simulation/lecuyer/papers/tausme.ps */

'	USE	: ULONG rn
'				rn = Rand_TAUS ()

FUNCTION  ULONG Rand_TAUS ()

	STATIC GIANT s1, s2, s3
	SHARED ULONG taus_seed
	STATIC init
	GIANT seed

	IFZ init THEN
		GOSUB Initialize
		init = $$TRUE
	END IF

	s1 = (((s1 & 4294967294) << 12) ^ (((s1 << 13) ^ s1) >> 19)) MOD $$M
	s2 = (((s2 & 4294967288) <<  4) ^ (((s2 <<  2) ^ s2) >> 25)) MOD $$M
	s3 = (((s3 & 4294967280) << 17) ^ (((s3 <<  3) ^ s3) >> 11)) MOD $$M

	RETURN ULONG(s1 ^ s2 ^ s3)

' ***** Initialize *****

SUB Initialize

	IFZ taus_seed THEN taus_seed = Create_Seed ()

	s1 = taus_seed
	s2 = (69069 * s1 + 1234567) MOD $$M
	s3 = (69069 * s2 + 1234567) MOD $$M
'PRINT "seeds"; s1, s2, s3

END SUB


END FUNCTION
'
'
' ###########################
' #####  Rand_TT800 ()  #####
' ###########################

' TT800 : July 8th 1996 Version
' by M. Matsumoto
' TT800 generates one pseudo random integer
' One may choose any initial 25 seeds except all zeros.

' TT800 is a twisted GFSR generator proposed by Matsumoto and Kurita
' in the ACM Transactions on Modelling and Computer Simulation,
' Vol. 4, No. 3, 1994, pp. 254-266.

' This has a period of 2^800 - 1 and excellent equidistribution
' properties up to dimension 25.

'	USE	: ULONG rn
'				rn = Rand_TT800 ()
'
FUNCTION  ULONG Rand_TT800 ()

	$N = 25
	$M = 7

	ULONG y
	STATIC k
	STATIC ULONG x[]
	STATIC ULONG mag01[1]

	IFZ x[] THEN GOSUB Initialize

	mag01[0] = 0x0						' this is magic vector `a', don't change
	mag01[1] = 0x8ebfd028

	IF (k == $N) THEN      							' generate N words at one time
		FOR kk = 0 TO $N-$M-1
			x[kk] = x[kk+M] ^ (x[kk] >> 1) ^ mag01[x[kk] MOD 2]
		NEXT kk
    FOR kk = $N-$M TO $N-1
			x[kk] = x[kk+(M-N)] ^ (x[kk] >> 1) ^ mag01[x[kk] MOD 2]
		NEXT kk
		k=0
	END IF

	y = x[k]
	y = y ^ ((y << 7) & 0x2b5b2500)  		' s and b, magic vectors
	y = y ^ ((y << 15) & 0xdb8b0000)		' t and c, magic vectors

' the following line was added by Makoto Matsumoto in the 1996 version
' to improve lower bit's correlation.

	y = y ^ (y >> 16)										' added to the 1994 version
	INC k
	RETURN y

' ***** Initialize *****
SUB Initialize

	DIM x[$N-1]
	FOR i = 0 TO $N-1
		x[i] = Rand_KISS_2 ()
	NEXT i
END SUB


END FUNCTION
'
'
' ########################
' #####  Uniform ()  #####
' ########################
'
' Uniform () converts a 32-bit integer random number into
' a uniform DOUBLE float

FUNCTION  DOUBLE Uniform (ULONG rn)

	RETURN rn * $$UNIDIV

END FUNCTION
'
'
' ###########################
' #####  Uni_BORN49 ()  #####
' ###########################

' Binary Oblong Random Number Generator
' by Panos Karagiorgis
' Provides a period of 2^49
'
FUNCTION  DOUBLE Uni_BORN49 ()

	STATIC DOUBLE BORN49
	SHARED ULONG seed_born49
	DOUBLE c, d
	STATIC init_BORN49

	$A = 67108864.0
	$B = 25877693.0

	IFZ init_BORN49 THEN GOSUB Intialize

	c = FMOD(BORN49, $A)
	d = c * $B
	c = INT(BORN49/$A) * $B + INT(d/$A) + c * 9347912
	BORN49 = FMOD(c, 33554432.0) * $A + FMOD(d, $A)
	RETURN (BORN49 + 1) / 2251799813685248.0

SUB Intialize
	IFZ seed_born49 THEN
		seed_born49 = Create_Seed () MOD $$two31
	END IF
	BORN49 = DOUBLE(seed_born49)
'PRINT "seed = "; BORN49
	init_BORN49 = $$TRUE
END SUB


END FUNCTION
'
'
' ##########################
' #####  Uni_MLCG ()  #####
' ##########################
'
' Returns a Uniform [0,1) pseudo-random number using a
' two-seed MLCG (Multiplicitive Linear Congruential
' Generator) formula based on algorithm by L'Ecuyer.

' L'Ecuyer, Pierre.  Efficient and Portable Combined Random
' Number Generators.  Communications of the ACM, Vol. 31,
' No. 6, pgs. 742-749,774.  (June 1988)

FUNCTION  DOUBLE Uni_MLCG ()

	ULONG m1, m2, a1, a2, q1, q2, r1, r2, k
	SHARED XLONG mlcg_s1, mlcg_s2
	SLONG z
	GIANT seed2

	IF mlcg_s1 = 0 || mlcg_s2 = 0 THEN
		mlcg_s1 = Create_Seed ()
		seed2 = (mlcg_s1 * 69069 + 1234567) MOD $$M
		mlcg_s2 = ULONG(seed2)
	END IF

	k = mlcg_s1/53668
	mlcg_s1 = (40014 * (mlcg_s1 MOD 53668)) - (k * 12211)
	IF (mlcg_s1 < 0) THEN mlcg_s1 = mlcg_s1 + 2147483563

	k = mlcg_s2/52774
	mlcg_s2 = (40692 * (mlcg_s2 MOD 52774)) - (k * 3791)
	IF (mlcg_s2 < 0) THEN mlcg_s2 = mlcg_s2 + 2147483399


	z = ABS(mlcg_s1 ^ mlcg_s2)
	z = (mlcg_s1 - 2147483563) + mlcg_s2
	IF (z < 1) THEN z = z + 2147483562

	RETURN DOUBLE(z)/2147483563.0


END FUNCTION
'
'
' ##########################
' #####  Uni_ULTRA ()  #####
' ##########################

FUNCTION  DOUBLE Uni_ULTRA ()

	STATIC GIANT swbseed[], swb32[], congx
	SHARED ULONG seed_ultra_1, seed_ultra_2
	ULONG tidbits, shrgx, congy
	STATIC SLONG swb32n, flags, swb32p
	ULONG temp
	GIANT seed2

	$N = 37
	$N2 = 24

	flags = 0

	IFZ swbseed[] THEN GOSUB Initialize

	DEC swb32n
	IF swb32n < 0 THEN
		GOSUB Swb32fill
	ELSE
		INC swb32p
		GOSUB ReturnUni
	END IF

' ***** Swb32fill *****

SUB Swb32fill

	swb32p = 0
  GOSUB SWBfill
  swb32n = $N-1
	INC swb32p
	GOSUB ReturnUni

END SUB

'	***** ReturnUni *****

SUB ReturnUni

	RETURN ULONG(swb32[swb32p-1] & 0x7FFFFFFF) * $$two2neg31

END SUB

' ***** SWBfill *****

SUB SWBfill

	FOR i = 0 TO $N2-1

		IF swbseed[i] < 0 THEN
			swbseed[i] = (swbseed[i+$N-$N2] - swbseed[i] - flags) MOD $$two31
			flags = ((swbseed[i] ) < 0) || (swbseed[i+$N-$N2] >= 0)
		ELSE
			swbseed[i] = (swbseed[i+$N-$N2] - swbseed[i] - flags) MOD $$two31
			flags = ((swbseed[i]) < 0) && (swbseed[i+$N-$N2] >= 0)
		END IF
	NEXT i

	FOR i = $N2 TO $N-1

		IF swbseed[i] < 0 THEN
			swbseed[i] = (swbseed[i-$N2] - swbseed[i] - flags) MOD $$two31
			flags = ((swbseed[i] ) < 0) || (swbseed[i-$N2] >= 0)
		ELSE
			swbseed[i] = (swbseed[i-$N2] - swbseed[i] - flags) MOD $$two31
			flags = ((swbseed[i]) < 0) && (swbseed[i-$N2] >= 0)
		END IF
	NEXT i

	FOR i = 0 TO $N-1
		congx = (congx * 69069) MOD $$two31
		swb32[i] = swbseed[i] ^ congx
	NEXT i

END SUB

' ***** Initialize *****
SUB Initialize

	DIM swbseed[$N-1]
	DIM swb32[$N-1]

	IF seed_ultra_1 = 0 || seed_ultra_2 = 0 THEN
		seed_ultra_1 = Create_Seed ()
		seed2 = (seed_ultra_1 * 69069 + 1234567) MOD $$M
		seed_ultra_2 = ULONG(seed2)
	END IF

	congy = seed_ultra_1
	shrgx = seed_ultra_2

	congx = (congy*2 + 1) MOD $$M

	FOR i = 0 TO $N-1
		FOR j = 32 TO 1 STEP -1
			congx = (congx * 69069) MOD $$M
			shrgx = shrgx ^ (shrgx >> 15)
			shrgx = shrgx ^ (shrgx << 17)
			tidbits = (tidbits >> 1 ) | (0x80000000 & (congx^shrgx))
		NEXT j
    swbseed[i] = tidbits
	NEXT i

	flags = 0

END SUB


END FUNCTION
'
'
' ###############################
' #####  Seed_Rand_CONG ()  #####
' ###############################
'
FUNCTION  Seed_Rand_CONG (ULONG seed)

	SHARED GIANT jcong_cong

	IFZ seed THEN
		jcong_cong = Create_Seed ()
		seed = jcong_cong
	ELSE
		jcong_cong = seed
	END IF

END FUNCTION
'
'
' ###############################
' #####  Seed_Rand_IBAA ()  #####
' ###############################
'
FUNCTION  Seed_Rand_IBAA (ULONG seed)

	SHARED ULONG seed_ibaa

	IFZ seed THEN
		seed = Create_Seed ()
		seed_ibaa = seed
	ELSE
		seed_ibaa = seed
	END IF


END FUNCTION
'
'
' ################################
' #####  Seed_Rand_ISAAC ()  #####
' ################################
'
FUNCTION  Seed_Rand_ISAAC (ULONG seed)

	Seed_Rand_KISS_2 (@seed)

END FUNCTION
'
'
' ###############################
' #####  Seed_Rand_KISS ()  #####
' ###############################
'
FUNCTION  Seed_Rand_KISS (ULONG seed_1, ULONG seed_2, ULONG seed_3, ULONG seed_4)

	SHARED ULONG seed_kiss1, seed_kiss2, seed_kiss3, seed_kiss4

	seed_kiss1 = seed_1
	seed_kiss2 = seed_2
	seed_kiss3 = seed_3
	seed_kiss4 = seed_4

	SELECT CASE ALL FALSE
		CASE seed_kiss1 : seed_kiss1 = Rand_CONG ()
											seed_1 = seed_kiss1
		CASE seed_kiss2 : seed_kiss2 = Rand_CONG ()
											seed_2 = seed_kiss2
		CASE seed_kiss3 : seed_kiss3 = Rand_CONG ()
											seed_3 = seed_kiss3
		CASE seed_kiss4 : seed_kiss4 = Rand_CONG ()
											seed_4 = seed_kiss4
	END SELECT

END FUNCTION
'
'
' #################################
' #####  Seed_Rand_KISS_2 ()  #####
' #################################
'
FUNCTION  Seed_Rand_KISS_2 (ULONG seed)

	SHARED GIANT kiss_i, kiss_j, kiss_k

	IFZ seed THEN seed = Create_Seed ()
	kiss_i = seed
	kiss_j = seed
	kiss_k = seed


END FUNCTION
'
'
' ################################
' #####  Seed_Rand_LFIB4 ()  #####
' ################################
'
FUNCTION  Seed_Rand_LFIB4 (ULONG seed)

	Seed_Rand_KISS_2 (seed)

END FUNCTION
'
'
' #################################
' #####  Seed_Rand_MOTHER ()  #####
' #################################
'
FUNCTION  Seed_Rand_MOTHER (ULONG seed)

	SHARED ULONG seed_mother

	IFZ seed THEN
		seed = Create_Seed ()
		seed_mother = seed
	ELSE
		seed_mother = seed
	END IF


END FUNCTION
'
'
' ##############################
' #####  Seed_Rand_MWC ()  #####
' ##############################
'
FUNCTION  Seed_Rand_MWC (ULONG seed_1, ULONG seed_2)

	SHARED ULONG z_mwc, w_mwc

	IFZ seed_1 THEN
		z_mwc = Rand_CONG ()
		seed_1 = z_mwc
	ELSE
		z_mwc = seed_1
	END IF

	IFZ seed_2 THEN
		w_mwc = Rand_CONG ()
		seed_2 = w_mwc
	ELSE
		w_mwc = seed_2
	END IF

END FUNCTION
'
'
' ##################################
' #####  Seed_Rand_MWC1019 ()  #####
' ##################################
'
FUNCTION  Seed_Rand_MWC1019 (ULONG seed)

	Seed_Rand_KISS_2 (seed)

END FUNCTION
'
'
' #############################
' #####  Seed_Rand_MT ()  #####
' #############################
'
FUNCTION  Seed_Rand_MT (ULONG seed)

	Seed_Rand_KISS_2 (seed)

END FUNCTION
'
'
' ###############################
' #####  Seed_Rand_R250 ()  #####
' ###############################
'
FUNCTION  Seed_Rand_R250 (ULONG seed)

	Seed_Rand_KISS_2 (seed)

END FUNCTION
'
'
' ###############################
' #####  Seed_Rand_ROTB ()  #####
' ###############################
'
FUNCTION  Seed_Rand_ROTB (ULONG seed)

	SHARED ULONG seed_rotb

	IFZ seed THEN
		seed_rotb = Create_Seed ()
		seed = seed_rotb
	ELSE
		seed_rotb = seed
	END IF

END FUNCTION
'
'
' ###############################
' #####  Seed_Rand_SHR3 ()  #####
' ###############################
'
FUNCTION  Seed_Rand_SHR3 (ULONG seed)

	SHARED ULONG jsr_shr3

	IFZ seed THEN
		jsr_shr3 = Create_Seed ()
		seed = jsr_shr3
	ELSE
		jsr_shr3 = seed
	END IF


END FUNCTION
'
'
' ###############################
' #####  Seed_Rand_TAUS ()  #####
' ###############################
'
FUNCTION  Seed_Rand_TAUS (ULONG seed)

	SHARED ULONG taus_seed

	IFZ seed THEN
		taus_seed = Create_Seed ()
		seed = taus_seed
	ELSE
		taus_seed = seed
	END IF


END FUNCTION
'
'
' ################################
' #####  Seed_Rand_TT800 ()  #####
' ################################
'
FUNCTION  Seed_Rand_TT800 (ULONG seed)

	Seed_Rand_KISS_2 (seed)

END FUNCTION
'
'
' ################################
' #####  Seed_Rand_ULTRA ()  #####
' ################################
'
FUNCTION  Seed_Rand_ULTRA (ULONG seed)

	SHARED ULONG seed_ultra

	IFZ seed THEN
		seed_ultra = Create_Seed ()
		seed = seed_ultra
	ELSE
		seed_ultra = seed
	END IF

END FUNCTION
'
'
' ##############################
' #####  Seed_Uni_MLCG ()  #####
' ##############################
'
FUNCTION  Seed_Uni_BORN49 (ULONG seed)

	SHARED ULONG seed_born49

	IFZ seed THEN
		seed = Create_Seed () MOD $$two31
		seed_born49 = seed
	ELSE
		seed = seed MOD $$two31
		seed_born49 = seed
	END IF

END FUNCTION
'
'
' ##############################
' #####  Seed_Uni_MLCG ()  #####
' ##############################
'
FUNCTION  Seed_Uni_MLCG (ULONG seed)

	SHARED XLONG mlcg_s1, mlcg_s2
	GIANT seed2

	IFZ seed THEN seed = Create_Seed ()
	mlcg_s1 = seed
	seed2 = (mlcg_s1 * 69069 + 1234567) MOD $$M
	mlcg_s2 = ULONG(seed2)

END FUNCTION
'
'
' ###############################
' #####  Seed_Uni_ULTRA ()  #####
' ###############################
'
FUNCTION  Seed_Uni_ULTRA (ULONG seed)

	SHARED ULONG seed_ultra_1, seed_ultra_2
	GIANT seed2

	IFZ seed THEN seed = Create_Seed ()
	seed_ultra_1 = seed
	seed2 = (seed_ultra_1 * 69069 + 1234567) MOD $$M
	seed_ultra_2 = ULONG(seed2)

END FUNCTION
'
'
' ################################
' #####  Chi_Square_Test ()  #####
' ################################

' The chi-square test is the most commonly used test for the
' randomness of data, and is extremely sensitive to errors in
' pseudorandom sequence generators. The chi-square distribution
' is calculated for the stream of bytes in the file and expressed
' as an absolute number and a percentage which indicates how
' frequently a truly random sequence would exceed the value
' calculated. We interpret the percentage as the degree to which
' the sequence tested is suspected of being non-random.

' If the percentage is greater than 99% or less than 1%, the
' sequence is almost certainly not random. If the percentage is
' between 99% and 95% or between 1% and 5%, the sequence is suspect.
' Percentages between 90% and 95% and 5% and 10% indicate the
' sequence is "almost suspect".

'     Chi square distribution for 51768 samples is 1542.26, and
'     randomly would exceed this value 0.01 percent of the times.

' Note above that our JPEG file, while very dense in information, is
' far from random as revealed by the chi-square test.

' An improved generator [Park & Miller] reports:

'     Chi square distribution for 500000 samples is 212.53, and
'     randomly would exceed this value 95.00 percent of the times.

' The improved generator is sufficiently non-random to cause
' concern for demanding applications. Contrast this result to that of
' a genuine random sequence created by timing radioactive decay events.

'     Chi square distribution for 32768 samples is 237.05, and
'     randomly would exceed this value 75.00 percent of the times.
'
FUNCTION  Chi_Square_Test (@data[], DOUBLE chi_squared, DOUBLE chip, report)

	DOUBLE chsqt[], expected, hist[]
	DIM chsqt[2, 10]

' table of chi-square Xp vaulues versus corresponding probabilities
	chsqt[0,0] = 0.5
	chsqt[0,1] = 0.25
	chsqt[0,2] = 0.1
	chsqt[0,3] = 0.05
	chsqt[0,4] = 0.025
	chsqt[0,5] = 0.01
	chsqt[0,6] = 0.005
	chsqt[0,7] = 0.001
	chsqt[0,8] = 0.0005
	chsqt[0,9] = 0.0001

	chsqt[1,0] = 0.0
	chsqt[1,1] = 0.6745
	chsqt[1,2] = 1.2816
	chsqt[1,3] = 1.6449
	chsqt[1,4] = 1.9600
	chsqt[1,5] = 2.3263
	chsqt[1,6] = 2.5758
	chsqt[1,7] = 3.0902
	chsqt[1,8] = 3.2905
	chsqt[1,9] = 3.7190

	chi_squared = 0.0
	expected = (UBOUND(data[])+1.0)/256.0
	Frequency_Data (@data[], 256, @hist[], expected, @chi_squared)

'Calculate probability of observed distribution occurring from
'the results of the Chi-Square test

	chip = Sqrt(2.0 * chi_squared) - Sqrt(2.0 * 255.0 - 1.0)
	a# = ABS(chip)
	FOR i = 9 TO 0 STEP -1
		IF chsqt[1, i] < a# THEN EXIT FOR
	NEXT i

	IF chip >= 0 THEN
		chip = chsqt[0, i]
	ELSE
		chip = 1.0 - chsqt[0, i]
	END IF

	IF report THEN
		PRINT "Chi square distribution for"; UBOUND(data[])+1; " samples is"; chi_squared
		PRINT "and randomly would exceed this value"; chip * 100; " percent of the time."
	END IF

END FUNCTION
'
'
' #############################
' #####  Entropy_Test ()  #####
' #############################

' Entropy - The information density of the contents of the file,
' expressed as a number of bits per character. The results

' Entropy = 7.980627 bits per character.
' Optimum compression would reduce the size
' of this 51768 character file by 0 percent.

' which resulted from processing an image file compressed with JPEG,
' indicate that the file is extremely dense in information--
' essentially random. Hence, compression of the file is unlikely
' to reduce its size. By contrast, the C source code of the program
' has entropy of about 4.9 bits per character, indicating that
' optimal compression of the file would reduce its size by 38%.
' [Hamming, pp. 104-108]
'
FUNCTION  Entropy_Test (@data[], DOUBLE ent, report)

	DOUBLE prob[255], hist[], expected

	$log2of10 = 3.32192809488736234787

	IFZ data[] THEN RETURN

	ent = 0.0
	chi_squared = 0.0
	expected = (UBOUND(data[])+1.0)/256.0    'expected not used here but prevents div by 0 error
	Frequency_Data (@data[], 256, @hist[], expected, @chi_squared)

	FOR i = 0 TO 255
		prob[i] = DOUBLE(hist[i])/DOUBLE(UBOUND(data[])+1.0)
		IF prob[i] > 0.0 THEN
			ent = ent + prob[i] * $log2of10 * Log10(1.0/prob[i])
		END IF
	NEXT i

	IF report THEN
		PRINT "Entropy = "; FORMAT$("#.######", ent); " bits per byte"
		PRINT "Optimum compression would reduce the size"
		PRINT "of this"; UBOUND(data[])+1; " byte file by "; FORMAT$("##.######", (8.0-ent)/8.0*100); " percent"
	END IF
END FUNCTION
'
'
' ##########################
' #####  Mean_Test ()  #####
' ##########################

' The arithmetic mean test is simply the result of summing the
' all the bytes in the file and dividing by the file length.
' If the data are close to random, this should be about 127.5.
' If the mean departs from this value, the values are
' consistently high or low.
'
FUNCTION  Mean_Test (@data[], DOUBLE mean, report)

	mean = 0.0
	Sample_Data (@data[], @mean#, @variance#, @std_dev#, @min#, @max#, @range#)
	mean = mean#
	IF report THEN
	 PRINT "Arithmetic mean value of data ="; mean#; " (random = 127.5)"
	END IF
END FUNCTION
'
'
' ####################################
' #####  Monte_Carlo_Pi_Test ()  #####
' ####################################

' Two successive sequences of uniform RNs are used as 24 bit X and Y
' coordinates within a square. If the distance of the randomly
' generated point is less than the radius of a circle inscribed
' within the square, the sequence is considered a "hit".
' The percentage of hits can be used to calculate the value of Pi.
' For very large streams (this approximation converges very slowly),
' the value will approach the correct value of Pi if the sequence
' is close to random.
'
' A 32768 byte file created by radioactive decay yielded:

'     Monte Carlo value for Pi is 3.139648438 (error 0.06 percent).
'
FUNCTION  Monte_Carlo_Pi_Test (DOUBLE dataX[], DOUBLE dataY[], DOUBLE pi, DOUBLE error, report)

	DOUBLE dist
	total = UBOUND(dataX[])+1

	FOR i = 0 TO UBOUND(dataX[])
		dist = dataX[i] * dataX[i] + dataY[i] * dataY[i]
		IF dist < 1.0 THEN INC count  			'the point is inside the unit circle
	NEXT i

	pi = 4.0# * DOUBLE(count) / DOUBLE(total)
	error = (ABS(pi - $$PI))/$$PI * 100.0

	IF report THEN
		PRINT "Monte Carlo Value for PI is"; pi; " (error ="; FORMAT$("##.####", error); " percent)"
	END IF
END FUNCTION
'
'
' ########################################
' #####  Serial_Correlation_Test ()  #####
' ########################################

' Serial Correlation Coefficient
' This quantity measures the extent to which each byte in
' the file depends upon the previous byte. For random sequences,
' this value (which can be positive or negative) will, of course,
' be close to zero. A non-random byte stream such as a C program
' will yield a serial correlation coefficient on the order of 0.5.
' Wildly predictable data such as uncompressed bitmaps will exhibit
' serial correlation coefficients approaching 1.
' See [Knuth, pp. 64-65] for more details.
'
FUNCTION  Serial_Correlation_Test (@data[], DOUBLE scc, report)

	DOUBLE sccun, sccu0, scclast, scct1, scct2, scct3

	sccfirst = $$TRUE
	scc = 0.0

	totalc = UBOUND(data[]) + 1

	FOR i = 0 TO UBOUND(data[])
' Update calculation of serial correlation coefficient

		sccun = data[i]
		IF (sccfirst) THEN
			sccfirst = $$FALSE
			scclast = 0
			sccu0 = sccun
		ELSE
			scct1 = scct1 + scclast * sccun
		END IF
		scct2 = scct2 + sccun
		scct3 = scct3 + (sccun * sccun)
		scclast = sccun
	NEXT i

' Complete calculation of serial correlation coefficient

	scct1 = scct1 + scclast * sccu0
	scct2 = scct2 * scct2
	scc = DOUBLE(totalc) * scct3 - scct2
	IF (scc == 0.0) THEN
		scc = -100000.0
	ELSE
		scc = (DOUBLE(totalc) * scct1 - scct2) / scc
	END IF

	IF report THEN
		PRINT "Serial correlation coefficient is";
		IF scc >= -99999 THEN
			PRINT FORMAT$("+##.######", scc); " (totally uncorrelated = 0.0)"
		ELSE
			PRINT "undefined (all values equal!)"
		END IF
	END IF

END FUNCTION
'
'
' ###############################
' #####  Universal_Test ()  #####
' ###############################

' This test implements Ueli M. Maurer큦 "Universal Statistical Test"
' created by Ueli M. Maurer and presented in "A Universal Statistical
' Test for Random Bit Generators", which can be found in Journal of
' Cryptology, vol.5, no.2, pp 89-105.

' http://www.inf.ethz.ch/personal/maurer/
' http://www.inf.ethz.ch/department/TI/um/personal/publications-maurer.html

' Having as input the bit succession
' s = s0, s1,..., sn-1

' The steps to check that a sequence satisfies Maurer큦 test are:

'   1.  The sequence s is divided in L bit length blocks, where L
'       can be from 1 to 16. It is recommended to make the check
'       for 6 <= L <= 16. The remaining bits from dividing n
'       between L can be ignored, it is the tail of the sequence.

'   2.  The resulting blocks are classified in two parts:
'       the first Q blocks and the remaining K blocks.
'       Q must be chosen from at least 10�2L blocks, as different
'       2L blocks of length L exist, it is supposed that in a chain
'       of 10 times this number there should be at least a block
'       from the different 2L.  Q is the initialisation chain.

'       The remaining K blocks is the part of the check, it is
'       recommended that K should be at least 1000�2L, that is to say,
'       expecting that the device generates each different block
'       1000 times.  In practice, the aforementioned recommended
'       parameters imply that a bit series must be for L=8 at least
'       of 258,560 bits and for L=16 at least of 66,191,360 bits.

'   3.  The test is done using the table tab[block[n]], in which
'       the index of the last appearance of block[n] is stored,
'       where block[n] is the number whose binary representation
'       is in the block block[n]. Exactly the table tab, is initialised
'       with the first Q blocks making 1 <= i <= Q tab[block[n]] = n.
'       Then the test K blocks are scanned incrementing for each block
'       the sum variable for natural logarithm of the distance between
'       the index of the block[n] current occurrence and the last
'       previous occurrence of the same block[n]. Updating then the
'       table which maintains the index of the last appearance of
'       block[n] through tab[block[n]] := n.

'       Then ( sum / K )/ ln ( 2.0 ) is calculated, resulting in the
'       test parameter fTU.

' 			The measure of the randomness of a given sequence of bits
' 			is then given as the distance of the measured mean to the
' 			theoretical value, expressed in theoretical standard deviations.
'				D = (value - Expectance(L)) / sqrt(Variance(L))
' 			The smaller the distance, better the randomness mark. Of course,
' 			the distance D itself is a random variable. For perfect random
' 			bits sequences it is nearly Gaussian distributed, with the mean
' 			of 0 and variance of 1.
'
FUNCTION  Universal_Test (@data[], DOUBLE fTU, DOUBLE tsd, report)

	DOUBLE E_fTU, Var_An, d, e, sum, cLK2, sigma, L, t1, t2, y

	E_fTU  = 7.1836656
	Var_An = 3.2386622
	V      = 256
	Q      = 2560
	K      = 253440
	L      = 8					'we are testing 8 bit blocks or 1 byte
	y      = 2.58       'for a rejection rate of 0.01

'256000 bytes (K+Q) are created by RNG and placed into data[] array

	DIM table[256]
	FOR n = 1 TO Q
		table[data[n-1]] = n
	NEXT n

	FOR n = Q+1 TO Q + K
		sum = sum + Log(n-table[data[n-1]])
		table[data[n-1]] = n
	NEXT n

	fTU = (sum/DOUBLE(K))/Log(2.0)
	cLK = 0.7 - 0.8/L + (4.0 + 32.0/L) * (K**(-3./L))/15.0    'constant c(L,K)
	sigma = cLK * Sqrt(Var_An / DOUBLE(K))

' The measure of the randomness of a given sequence of bits
' is then given as the distance of the measured mean to the
' theoretical value, expressed in theoretical standard deviations.
'	D = (value - Expectance(L)) / sqrt(Variance(L))
' The smaller the distance, better the randomness mark. Of course,
' the distance D itself is a random variable. For perfect random
' bits sequences it is nearly Gaussian distributed, with the mean
' of 0 and variance of 1.

	tsd = (fTU - E_fTU) / sigma
	t1 = E_fTU - y * sigma
	t2 = E_fTU + y * sigma

	IF report THEN
		PRINT "Universal Test value fTU is "; FORMAT$("#.######", fTU); " (vs 7.1836656 for perfect RNG)"
		PRINT "Randomness Distance is "; FORMAT$("##.####", tsd); " theoretical standard deviations"
' A device should be rejected if and only if either fTU < t1 or fTU > t2
		IF fTU < t1 || fTU > t2 THEN
			PRINT "RNG exceeds thresholds"
		ELSE
			PRINT "RNG does not exceed thresholds"
		END IF
	END IF

END FUNCTION
'
'
' ##############################
' #####  Long_Run_Test ()  #####
' ##############################

' The Long Run Test

' 1. A long run is defined to be a run of length 34 or more
'    (of either zeros or ones).

' 2. On the sample of 20,000 bits, the test is passed if
'    there are NO long runs.
'
FUNCTION  Long_Run_Test (ULONG data[], report)

	FOR i = 0 TO UBOUND(data[])				'do max run count on 1's
		Int2Bits (data[i], @bits[])
		FOR j = 0 TO 31
			n = bits[j]
			IF n THEN
				INC count
			ELSE
				max1 = MAX(max1, count)
				count = 0
			END IF
		NEXT j
	NEXT i

	FOR i = 0 TO UBOUND(data[])				'do max run count on 0's
		Int2Bits (data[i], @bits[])
		FOR j = 0 TO 31
			n = bits[j]
			IFZ n THEN
				INC count
			ELSE
				max0 = MAX(max0, count)
				count = 0
			END IF
		NEXT j
	NEXT i

	IF max1 < 34 || max0 < 34 THEN pass = $$TRUE

	IF report THEN
		PRINT "Maximum run of 1's:"; max1; " (long run >= 34)"
		PRINT "Maximum run of 0's:"; max0; " (long run >= 34)"
		IF pass THEN
			PRINT "Long run test PASSED"
		ELSE
			PRINT "Long run test FAILED"
		END IF
	END IF

	RETURN pass

END FUNCTION
'
'
' #############################
' #####  Monobit_Test ()  #####
' #############################

' Count the number of 1큦 in the 20,000 bit stream.
' Denote this quantity by X.

' The test is passed if 9,654 < X < 10,346.

' Note: 625 ULONG integers = 20,000 bits.

FUNCTION  Monobit_Test (ULONG data[], report)

	FOR i = 0 TO UBOUND(data[])
		Int2Bits (data[i], @bits[])
		FOR j = 0 TO 31
			IF bits[j] = 1 THEN INC count
		NEXT j
	NEXT i

	IF count > 9654 && count < 10346 THEN pass = $$TRUE

	IF report THEN
		PRINT "Number of 1's in 20000 bit stream:"; count; " (9654 < count < 10346)"
		IF pass THEN
			PRINT "Monobit test PASSED"
		ELSE
			PRINT "Monobit test FAILED"
		END IF
	END IF

	RETURN pass
END FUNCTION
'
'
' ###########################
' #####  Poker_Test ()  #####
' ###########################

' Divide the 20.000 bit stream into 5.000 contiguous 4-bit segments.
' Count and store the number of ocurrences of each of the 16 possible
' 4-bit values.
' Denote f(i) as the number of each 4-bit value i where 0 <= i <= 15.
' Evaluate the following:

'  x = (16/5000) * SUM[f(i)^2] - 5000

' The test is passed if 1.03 < x < 57.4.

' Note: this is basically another chi-square test
'
FUNCTION  Poker_Test (ULONG data[], report)

	DOUBLE x, sumsqrd
	DIM f[15]

	FOR i = 0 TO UBOUND(data[])
		FOR j = 0 TO 7
			n = data[i]{4, j*4}				'extract 4 bits
			INC f[n]									'sum 4-bit value n
		NEXT j
	NEXT i

	FOR i = 0 TO 15								'calc sum of f(i) squared
		sumsqrd = sumsqrd + f[i] * f[i]
	NEXT i

	x = (16.0 / 5000.0 * sumsqrd) - 5000.0

	IF x > 1.03 && x < 57.4 THEN pass = $$TRUE

	IF report THEN
		PRINT "Poker test result:"; FORMAT$("###.###", x); " (1.03 < result < 57.4)"
		IF pass THEN
			PRINT "Poker test PASSED"
		ELSE
			PRINT "Poker test FAILED"
		END IF
	END IF

	RETURN pass

END FUNCTION
'
'
' ##########################
' #####  Runs_Test ()  #####
' ##########################

' The Runs Test

' 1. A run is defined as a maximal sequence of consecutive
' bits of either all ones or all zeros, which is part of the
' 20,000 bit sample stream. The incidences of runs (for both
' consecutive zeros and consecutive ones) of all lengths
' ( >= 1 ) in the sample stream should be counted and stored.

' 2. The test is passed if the number of runs that occur
' (of lengths 1 through 6) is each within the corresponding
' interval specified below. This must hold for both the zeros
' and ones; that is, all 12 counts must lie in the specified
' interval. For the purpose of this test, runs of greater than
' 6 are considered to be of length 6.

' Length of Run  Required Interval
'   1              2,267 - 2,733
'   2              1,079 - 1,421
'   3                502 - 748
'   4                223 - 402
'   5                 90 - 223
'   6 +               90 - 223
'
FUNCTION  Runs_Test (ULONG data[], report)

	DIM runs[6, 1]			'[run count, 0 or 1]

	FOR i = 0 TO UBOUND(data[])				'do count on 1 runs
		Int2Bits (data[i], @bits[])
		FOR j = 0 TO 31
			n = bits[j]
			IF n THEN
				INC count
			ELSE
				IF count < 6 THEN
					INC runs[count,1]
				ELSE
					INC runs[6,1]
				END IF
				count = 0
			END IF
		NEXT j
	NEXT i

	count = 0
	FOR i = 0 TO UBOUND(data[])				'do count on 0 runs
		Int2Bits (data[i], @bits[])
		FOR j = 0 TO 31
			n = bits[j]
			IFZ n THEN
				INC count
			ELSE
				IF count < 6 THEN
					INC runs[count,0]
				ELSE
					INC runs[6,0]
				END IF
				count = 0
			END IF
		NEXT j
	NEXT i

	IF report THEN
		PRINT "Length of Run  Required Interval  Runs of 1's  Runs of 0's"
		PRINT "=========================================================="
		PRINT "   1             2,267 - 2,733        "; FORMAT$("####", runs[1,1]); SPACE$(9); FORMAT$("####", runs[1,0])
		PRINT "   2             1,079 - 1,421        "; FORMAT$("####", runs[2,1]); SPACE$(9); FORMAT$("####", runs[2,0])
		PRINT "   3               502 - 748          "; FORMAT$("####", runs[3,1]); SPACE$(9); FORMAT$("####", runs[3,0])
		PRINT "   4               223 - 402          "; FORMAT$("####", runs[4,1]); SPACE$(9); FORMAT$("####", runs[4,0])
		PRINT "   5                90 - 223          "; FORMAT$("####", runs[5,1]); SPACE$(9); FORMAT$("####", runs[5,0])
		PRINT "   6+               90 - 223          "; FORMAT$("####", runs[6,1]); SPACE$(9); FORMAT$("####", runs[6,0])
	END IF

	pass = $$TRUE

	SELECT CASE ALL FALSE
		CASE runs[1,0] > 2267 && runs[1,0] < 2733 : pass = $$FALSE
		CASE runs[1,1] > 2267 && runs[1,1] < 2733 : pass = $$FALSE
		CASE runs[2,0] > 1079 && runs[2,0] < 1421 : pass = $$FALSE
		CASE runs[2,1] > 1079 && runs[2,1] < 1421 : pass = $$FALSE
		CASE runs[3,0] > 502  && runs[3,0] < 748  : pass = $$FALSE
		CASE runs[3,1] > 502  && runs[3,1] < 748  : pass = $$FALSE
		CASE runs[4,0] > 223  && runs[4,0] < 402  : pass = $$FALSE
		CASE runs[4,1] > 223  && runs[4,1] < 402  : pass = $$FALSE
		CASE runs[5,0] > 90   && runs[5,0] < 223  : pass = $$FALSE
		CASE runs[5,1] > 90   && runs[5,1] < 223  : pass = $$FALSE
		CASE runs[6,0] > 90   && runs[6,0] < 223  : pass = $$FALSE
		CASE runs[6,1] > 90   && runs[6,1] < 223  : pass = $$FALSE
	END SELECT

	IF report THEN
		IF pass THEN
			PRINT "Runs test PASSED"
		ELSE
			PRINT "Runs test FAILED"
		END IF
	END IF

	RETURN pass

END FUNCTION
'
'
' ##############################
' #####  Run_All_Tests ()  #####
' ##############################

' This runs all of the various RNG tests on the integer
' RNG functions.
'
FUNCTION  Run_All_Tests ()

	ULONG rn
	DOUBLE uni
	UBYTE byte1, byte2, byte3, byte4
	DOUBLE dataX[], dataY[]
	DOUBLE results[14,10]			'[rng, test]
	FUNCADDR ULONG rngFuncAddr[] ()

	DIM rngFuncAddr[14]

' create rng function address array
	rngFuncAddr[0] = &Rand_CONG ()
	rngFuncAddr[1] = &Rand_IBAA ()
	rngFuncAddr[2] = &Rand_ISAAC ()
	rngFuncAddr[3] = &Rand_KISS ()
	rngFuncAddr[4] = &Rand_KISS_2 ()
	rngFuncAddr[5] = &Rand_LFIB4 ()
	rngFuncAddr[6] = &Rand_MOTHER ()
	rngFuncAddr[7] = &Rand_MT ()
	rngFuncAddr[8] = &Rand_MWC ()
	rngFuncAddr[9] = &Rand_MWC1019 ()
	rngFuncAddr[10] = &Rand_R250 ()
	rngFuncAddr[11] = &Rand_ROTB ()
	rngFuncAddr[12] = &Rand_SHR3 ()
	rngFuncAddr[13] = &Rand_TAUS ()
	rngFuncAddr[14] = &Rand_TT800 ()


' ***** Run Entropy test series *****

' This series of tests is run on 250,000 integer rn's

	DIM data[249999]
	PRINT "Running Entropy tests...";

	FOR i = 0 TO UBOUND(rngFuncAddr[])

		FOR j = 0 TO 249999 STEP 4											'create data[] array of ubytes
			rn = @rngFuncAddr[i] ()												'call rng function
			Int2Byte (rn, @byte1, @byte2, @byte3, @byte4)	'convert rn to ubyte
			data[j]   = byte1
			data[j+1] = byte2
			data[j+2] = byte3
			data[j+3] = byte4
		NEXT j

		Mean_Test (@data[], @mean#, 0)									'run tests
		Chi_Square_Test (@data[], @chi_squared#, @chip#, 0)
		Serial_Correlation_Test (@data[], @scc#, 0)
		Entropy_Test (@data[], @ent#, 0)

		results[i,0] = mean#														'save results
		results[i,1] = chi_squared#
		results[i,2] = scc#
		results[i,3] = ent#

'	PRINT i, results[i,0], results[i,1], results[i,2], results[i,3]
		PRINT "...";
	NEXT i

' ***** Run Monte Carlo Test *****

' This test is run on 100,000 pairs of uniform rn's

	DIM dataX[99999]
	DIM dataY[99999]

	PRINT
	PRINT "Running Monte Carlo Pi test...";

	FOR i = 0 TO UBOUND(rngFuncAddr[])
		FOR j = 0 TO 99999
			rn = @rngFuncAddr[i] ()
			dataX[j] = Uniform (rn)
			rn = @rngFuncAddr[i] ()
			dataY[j] = Uniform (rn)
		NEXT j

		Monte_Carlo_Pi_Test (@dataX[], @dataY[], @pi#, @error#, 0)
		results[i,4] = error#
'		PRINT i, results[i,4]
		PRINT "...";
	NEXT i

' ***** Run Universal Test *****

' This test requires a 25600 ubyte sequence
	DIM data[255999]
	PRINT
	PRINT "Running Universal test...";
	FOR i = 0 TO UBOUND(rngFuncAddr[])
		FOR j = 0 TO 255999 STEP 4
			rn = @rngFuncAddr[i] ()
			Int2Byte (rn, @byte1, @byte2, @byte3, @byte4)
			data[j]   = byte1
			data[j+1] = byte2
			data[j+2] = byte3
			data[j+3] = byte4
		NEXT j
		Universal_Test (@data[], @fTU#, @tsd#, report)
		results[i,5] = fTU#
'		PRINT i, results[i,5]
		PRINT "...";
	NEXT i

' ***** Run speed test *****

' Create 500,000 rn's

	PRINT
	PRINT "Running speed test...";

	FOR i = 0 TO UBOUND(rngFuncAddr[])
		XstGetSystemTime (@start)
		FOR j = 0 TO 499999
			rn = @rngFuncAddr[i] ()
		NEXT j
		XstGetSystemTime (@finish)
		results[i,6] = finish - start
		PRINT "...";
	NEXT i

'	***** Run FIPS tests *****

' These tests require a 20,000 bit sequence (625 32-bit integer rn's)

	DIM data[624]
	PRINT
	PRINT "Running FIPS tests...";
	FOR i = 0 TO UBOUND(rngFuncAddr[])
		FOR j = 0 TO 624
			data[j] = @rngFuncAddr[i] ()
		NEXT j

		results[i,7] = Monobit_Test (@data[], 0)
		results[i,8] = Poker_Test (@data[], 0)
		results[i,9] = Runs_Test (@data[], 0)
		results[i,10] = Long_Run_Test (@data[], 0)
'		PRINT i, results[i,7], results[i,8], results[i,9], results[i,10]
		PRINT "...";
	NEXT i
	PRINT
' ***** Print out test results *****

	DIM rng$[14]
	rng$[0]  = "  CONG    "
	rng$[1]  = "  IBAA    "
	rng$[2]  = "  ISAAC   "
	rng$[3]  = "  KISS    "
	rng$[4]  = "  KISS_2  "
	rng$[5]  = "  LFIB4   "
	rng$[6]  = "  MOTHER  "
	rng$[7]  = "  MT      "
	rng$[8]  = "  MWC     "
	rng$[9]  = "  MWC1019 "
	rng$[10] = "  R250    "
	rng$[11] = "  ROTB    "
	rng$[12] = "  SHR3    "
	rng$[13] = "  TAUS    "
	rng$[14] = "  TT800   "


PRINT "   RNG        Mean     ChiSquare  SerialCoeff    Entropy    %Dif Pi    Universal  msec/MM  Monobit  Poker  Runs  LongRuns"
PRINT "=========================================================================================================================="

FOR i = 0 TO 14
	line$ = ""
	data$ = ""
	FOR j = 0 TO 10

		SELECT CASE TRUE
			CASE j < 6 : format$ = FORMAT$("###.######", results[i,j])
			CASE j = 6 : format$ = " " + FORMAT$("#####", results[i,j]*2)		'msec/MM rn's
			CASE j > 6 : 	IF results[i,j] THEN
											format$ = " " + "PASS" + " "
										ELSE
											format$ = " " + "FAIL" + " "
										END IF
		END SELECT
		data$ = data$ + format$ + "  "
	NEXT j
	line$ = rng$[i] + data$
	PRINT line$
NEXT i

END FUNCTION
'
'
' ############################
' #####  Create_Seed ()  #####
' ############################
'
' Create_Seed () is used to generate a random ULONG integer seed
' which can be used to seed any of the RNGs.
' Created by Vic Drastik (source: xbrandom.x)

FUNCTION  ULONG Create_Seed ()

	XLONG year, month, day, hour, minute, second, nsec
	GIANT centis
	ULONG M

' get the current time in centiseconds since year 0

	XstGetDateAndTime ( @year, @month, @day, @weekDay, @hour, @minute, @second, @nsec)
	centis = (nsec\10000000)+100*(second+60*(minute+60*(hour+24*(day+31*(month+12*GIANT(year))))))
'	M = 4294967295

	RETURN ULONG(1 + ULONG(centis MOD $$M-1))


END FUNCTION
'
'
' #############################
' #####  Rand_Integer ()  #####
' #############################
'
FUNCTION  ULONG Rand_Integer (DOUBLE uni)

	RETURN uni * ($$M-1)

END FUNCTION
'
'
' ######################
' #####  Range ()  #####
' ######################

' Range is used to produce a positive integer within
' the interval (inclusive) min and max, where uni
' is a uniform random number in range [0,1).
'
' USE	: range = Range (1, 6, Uni_ULTRA () )

FUNCTION  ULONG Range (ULONG min, ULONG max, DOUBLE uni)

	IFZ max-min THEN RETURN 0
	IF max < min THEN SWAP max, min

	RETURN INT(DOUBLE(min) + (max - min + 1) * uni)

END FUNCTION
'
'
' ########################
' #####  Shuffle ()  #####
' ########################

' PURPOSE	: Randomly shuffle a set of data.
'
FUNCTION  ULONG Shuffle (ULONG data[])

	ULONG where, i, upper

	IFZ data[] THEN RETURN 0
	upper = UBOUND(data[])

	FOR i = 0 TO upper
		where = Rand_KISS () MOD ULONG(upper+1)
		SWAP data[where], data[i]
	NEXT i

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###############################
' #####  Frequency_Data ()  #####
' ###############################
'
FUNCTION  Frequency_Data (@data[], DOUBLE bin_count, DOUBLE hist[], DOUBLE expected, DOUBLE chi_squared)

	DOUBLE dif

	IFZ expected THEN RETURN 0
	IFZ data[] THEN RETURN 0

' put all data in bins and count
' this assumes data is in range (0, bin_count-1)
' there is no range checking here

	DIM hist[bin_count-1]

	FOR i = 0 TO UBOUND(data[])
		INC hist[data[i]]
	NEXT i

' calc chi-squared

	FOR i = 0 TO UBOUND(hist[])
		dif = hist[i] - expected
		chi_squared = chi_squared + (dif * dif) / expected
'		PRINT i, hist[i], dif, chi_squared
	NEXT i

	RETURN

END FUNCTION
'
'
' ############################
' #####  Sample_Data ()  #####
' ############################
'
FUNCTION  Sample_Data (@data[], DOUBLE mean, DOUBLE variance, DOUBLE std_dev, DOUBLE min, DOUBLE max, DOUBLE range)

	DOUBLE sum, count, data

	upper = UBOUND(data[])
	count = DOUBLE(upper) + 1.0

'init max, min
	max = -1d308
	min = 1d308

'compute mean (average), min, max, range
	FOR i = 0 TO upper
		data = DOUBLE(data[i])
		sum = sum + data
		min = MIN (min, data)
		max = MAX (max, data)
	NEXT i

	mean = sum / count
	range = max - min

'compute variance
	FOR i = 0 TO upper
		sum = sum + ((DOUBLE(data[i]) - mean)**2)
	NEXT i
	variance = sum / (count - 1.0)

' compute standard deviation
	std_dev = Sqrt(variance)




END FUNCTION
'
'
' #####################
' #####  ROTL ()  #####
' #####################
'
FUNCTION  ULONG ROTL (ULONG x, ULONG r)

	IF r > 30 THEN RETURN 0
	RETURN (x << r) | ( x >> (SIZE(x)*8 - r))

END FUNCTION
'
'
' #########################
' #####  Int2Byte ()  #####
' #########################
'
' Create 4 bytes from one ULONG integer
'
FUNCTION  Int2Byte (ULONG int, UBYTE byte1, UBYTE byte2, UBYTE byte3, UBYTE byte4)

	byte1 = int{8,0}
	byte2 = int{8,8}
	byte3 = int{8,16}
	byte4 = int{8,24}

END FUNCTION
'
'
' #########################
' #####  Int2Bits ()  #####
' #########################

' Extract each bit from an unsigned integer
' and place into an array bits[]
'
FUNCTION  Int2Bits (ULONG rn, bits[])

	DIM bits[31]

	FOR i = 0 TO 31
		bits[i] = rn{1, i}
'PRINT i, bits[i]
	NEXT i


END FUNCTION
'
'
' #####################
' #####  FMOD ()  #####
' #####################
'
FUNCTION  DOUBLE FMOD (DOUBLE x, DOUBLE y)

RETURN x - (FIX(x/y) * y)

END FUNCTION
'
'
' ####################
' #####  Mix ()  #####
' ####################
'
FUNCTION  Mix (ULONG a, ULONG b, ULONG c, ULONG d, ULONG e, ULONG f, ULONG g, ULONG h)

  a = a ^ (b<<11)
  d= ULONG((GIANT(d)+GIANT(a)) MOD $$M)
  b= ULONG((GIANT(b)+GIANT(c)) MOD $$M)
  b = b ^ (c>>2)
  e= ULONG((GIANT(e)+GIANT(b)) MOD $$M)
  c= ULONG((GIANT(c)+GIANT(d)) MOD $$M)
  c = c ^ (d<<8)
  f= ULONG((GIANT(f)+GIANT(c)) MOD $$M)
  d= ULONG((GIANT(d)+GIANT(e)) MOD $$M)
  d = d ^ (e>>16)
  g= ULONG((GIANT(g)+GIANT(d)) MOD $$M)
  e= ULONG((GIANT(e)+GIANT(f)) MOD $$M)
  e = e ^ (f<<10)
  h= ULONG((GIANT(h)+GIANT(e)) MOD $$M)
  f= ULONG((GIANT(f)+GIANT(g)) MOD $$M)
  f = f ^ (g>>4)
  a= ULONG((GIANT(a)+GIANT(f)) MOD $$M)
  g= ULONG((GIANT(g)+GIANT(h)) MOD $$M)
  g = g ^ (h<<8)
  b= ULONG((GIANT(b)+GIANT(g)) MOD $$M)
  h= ULONG((GIANT(h)+GIANT(a)) MOD $$M)
  h = h ^ (a>>9)
  c= ULONG((GIANT(c)+GIANT(h)) MOD $$M)
  a= ULONG((GIANT(a)+GIANT(b)) MOD $$M)

END FUNCTION
END PROGRAM
