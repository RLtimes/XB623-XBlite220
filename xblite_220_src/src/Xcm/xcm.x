'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2002
' ####################  XBLite complex number function library
'
' Xcm is the complex number function library.
' ---
' subject to LGPL license - see COPYING_LIB
' maxreason@maxreason.com
' ---
' Note that this version of Xcm is a separate
' function library, xcm.dll. The names of the
' functions have all been changed to indicate
' that they are no longer built-in functions;
' e.g., DCABS > Dcabs.
'
PROGRAM	"xcm"
VERSION	"0.0007"
'
IMPORT  "xst"
IMPORT	"xma"
'IMPORT  "xio"
'
EXPORT
'
' *******************************
' *****  declare functions  *****
' *******************************
'
DECLARE FUNCTION Xcm                   ()
DECLARE FUNCTION XcmVersion$           ()
'
' DCOMPLEX functions  (.R and .I components are DOUBLE precision)
'
DECLARE FUNCTION DOUBLE    Dcabs       (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dcacos      (DCOMPLEX z)
DECLARE FUNCTION DOUBLE    Dcarg       (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dcasin      (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dcatan      (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dcconj      (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dccos       (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dccosh      (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dcexp       (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dclog       (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dclog10     (DCOMPLEX z)
DECLARE FUNCTION DOUBLE    Dcnorm      (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dcpolor     (DOUBLE mag, DOUBLE angle)
DECLARE FUNCTION DCOMPLEX  Dcpowercc   (DCOMPLEX z, DCOMPLEX n)
DECLARE FUNCTION DCOMPLEX  Dcpowercr   (DCOMPLEX z, DOUBLE   n)
DECLARE FUNCTION DCOMPLEX  Dcpowerrc   (DOUBLE   z, DCOMPLEX n)
DECLARE FUNCTION DCOMPLEX  Dcrmul      (DCOMPLEX x, DOUBLE y)
DECLARE FUNCTION DCOMPLEX  Dcsin       (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dcsinh      (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dcsqrt      (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dctan       (DCOMPLEX z)
DECLARE FUNCTION DCOMPLEX  Dctanh      (DCOMPLEX z)
'
' SCOMPLEX functions  (.R and .I components are SINGLE precision)
'
DECLARE FUNCTION SINGLE    Scabs       (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Scacos      (SCOMPLEX z)
DECLARE FUNCTION SINGLE    Scarg       (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Scasin      (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Scatan      (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Scconj      (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Sccos       (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Sccosh      (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Scexp       (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Sclog       (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Sclog10     (SCOMPLEX z)
DECLARE FUNCTION SINGLE    Scnorm      (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Scpolar     (SINGLE mag, SINGLE angle)
DECLARE FUNCTION SCOMPLEX  Scpowercc   (SCOMPLEX z, SCOMPLEX n)
DECLARE FUNCTION SCOMPLEX  Scpowercr   (SCOMPLEX z, SINGLE   n)
DECLARE FUNCTION SCOMPLEX  Scpowerrc   (SINGLE   z, SCOMPLEX n)
DECLARE FUNCTION SCOMPLEX  Scrmul      (SCOMPLEX x, SINGLE y)
DECLARE FUNCTION SCOMPLEX  Scsin       (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Scsinh      (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Scsqrt      (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Sctan       (SCOMPLEX z)
DECLARE FUNCTION SCOMPLEX  Sctanh      (SCOMPLEX z)
'
DECLARE FUNCTION DOUBLE    Atan2       (DOUBLE y, DOUBLE x)
END EXPORT
'
INTERNAL FUNCTION DOUBLE  XdcGetAlpha    (DCOMPLEX z)      ' called by Dcasin & Dcacos
INTERNAL FUNCTION DOUBLE  XdcGetBeta     (DCOMPLEX z)      ' ditto
INTERNAL FUNCTION SINGLE  XscGetAlpha    (SCOMPLEX z)      ' called by Scasin & Scacos
INTERNAL FUNCTION SINGLE  XscGetBeta     (SCOMPLEX z)      ' ditto
'
'
' ####################
' #####  Xcm ()  #####
' ####################
'
FUNCTION  Xcm () DOUBLE

	XLONG i, j, ofile
	DCOMPLEX z, zneg, zexp
	DCOMPLEX polar
	DCOMPLEX conj, sq1, sq2, sq3
	DCOMPLEX expx, expxi, emeix, epeix, log1, log10x
	DCOMPLEX sinr, cosr, tanr, asinx, acosx, atanx
	DCOMPLEX sinhx, coshx, tanhx
	DCOMPLEX powCC, powCR, powRC
'
	IF LIBRARY(0) THEN RETURN
	RETURN
'
'	a$ = "Max Reason"
'	a$ = "copyright 1988-2000"
'	a$ = "XBasic complex number function library"
'	a$ = "maxreason@maxreason.com"
'	a$ = ""
'
'	XioCreateConsole ("Console Demo for XBLite", 200)

' Comment out the following line to route output to file ofile$
'
	ofile = $$STDOUT
	IF (ofile != $$STDOUT) THEN
		ofile$ = "complex.out"
 		ofile = OPEN (ofile$, $$WRNEW)
	  IF (ofile <= 0) THEN PRINT [$$STDERR], "cannot open ofile"
	END IF
'
	DO
	  a$ = INLINE$ ("Input base real value      ===>> ")
		IFZ TRIM$(a$) THEN
'			XioFreeConsole ()
			EXIT FUNCTION
		END IF
		b$ = INLINE$ ("Input base imaginary value ===>> ")
		z.R = DOUBLE (a$)
		z.I = DOUBLE (b$)
'
' Uncomment the following 4 lines when testing DCPOWERDC, Dcpowercr or Dcpowerrc
'
'	  a$ = INLINE$ ("Input exp real value       ===>> ")
'		b$ = INLINE$ ("Input exp imaginary value  ===>> ")
'		zexp.R = DOUBLE (a$)
'		zexp.I = DOUBLE (b$)

		zneg.R = -z.R
		zneg.I = -z.I

		norm   = Dcnorm(z)
		aabs	 = Dcabs(z)
		arg    = Dcarg(z)
		polar  = Dcpolor(aabs, arg)
		conj	 = Dcconj(z)
		sq1		 = Dcsqrt(z)
		log10x = Dclog10(z)
		log1   = Dclog(z)
		expx   = Dcexp(z)
		expxi  = Dcexp(zneg)
		emeix  = expx - expxi
		epeix  = expx + expxi
		sinr	 = Dcsin(z)
		cosr   = Dccos(z)
		tanr   = Dctan(z)
		asinx	 = Dcasin(sinr)
		acosx  = Dcacos(cosr)
		atanx  = Dcatan(tanr)
		asinx	 = Dcasin(z)
		acosx  = Dcacos(z)
		atanx  = Dcatan(z)
		sinhx  = Dcsinh(z)
		coshx  = Dccosh(z)
		tanhx  = Dctanh(z)

		powCC  = Dcpowercc(z, zexp)
		powCR  = Dcpowercr(z, zexp.R)
		powRC  = Dcpowerrc(z.R, zexp)

		PRINT [ofile], "abs      = "; aabs,  TAB(36); HEX$(DHIGH(aabs), 8);;  HEX$(DLOW(aabs), 8)
		PRINT [ofile], "arg      = "; arg,   TAB(36); HEX$(DHIGH(arg), 8);;   HEX$(DLOW(arg), 8)
		PRINT [ofile], "norm     = "; norm,  TAB(36); HEX$(DHIGH(norm), 8);;  HEX$(DLOW(norm), 8)
		PRINT [ofile], "polar.R  = "; polar.R,  TAB(36); HEX$(DHIGH(polar.R), 8);;  HEX$(DLOW(polar.R), 8)
		PRINT [ofile], "polar.I  = "; polar.I,  TAB(36); HEX$(DHIGH(polar.I), 8);;  HEX$(DLOW(polar.I), 8)
		PRINT [ofile], "conj.R   = "; conj.R,  TAB(36); HEX$(DHIGH(conj.R), 8);;  HEX$(DLOW(conj.R), 8)
		PRINT [ofile], "conj.I   = "; conj.I,  TAB(36); HEX$(DHIGH(conj.I), 8);;  HEX$(DLOW(conj.I), 8)
		PRINT [ofile], "sq1.R    = "; sq1.R,  TAB(36); HEX$(DHIGH(sq1.R), 8);;  HEX$(DLOW(sq1.R), 8)
		PRINT [ofile], "sq1.I    = "; sq1.I,  TAB(36); HEX$(DHIGH(sq1.I), 8);;  HEX$(DLOW(sq1.I), 8)
		PRINT [ofile], "log1.R   = "; log1.R,  TAB(36); HEX$(DHIGH(log1.R), 8);;  HEX$(DLOW(log1.R), 8)
		PRINT [ofile], "log1.I   = "; log1.I,  TAB(36); HEX$(DHIGH(log1.I), 8);;  HEX$(DLOW(log1.I), 8)
		PRINT [ofile], "log10x.R = "; log10x.R,  TAB(36); HEX$(DHIGH(log10x.R), 8);;  HEX$(DLOW(log10x.R), 8)
		PRINT [ofile], "log10x.I = "; log10x.I,  TAB(36); HEX$(DHIGH(log10x.I), 8);;  HEX$(DLOW(log10x.I), 8)
		PRINT [ofile], "expx.R   = "; expx.R,  TAB(36); HEX$(DHIGH(expx.R), 8);;  HEX$(DLOW(expx.R), 8)
		PRINT [ofile], "expx.I   = "; expx.I,  TAB(36); HEX$(DHIGH(expx.I), 8);;  HEX$(DLOW(expx.I), 8)
		PRINT [ofile], "expxi.R  = "; expxi.R,  TAB(36); HEX$(DHIGH(expxi.R), 8);;  HEX$(DLOW(expxi.R), 8)
		PRINT [ofile], "expxi.I  = "; expxi.I,  TAB(36); HEX$(DHIGH(expxi.I), 8);;  HEX$(DLOW(expxi.I), 8)
		PRINT [ofile], "emeix.R  = "; emeix.R,  TAB(36); HEX$(DHIGH(emeix.R), 8);;  HEX$(DLOW(emeix.R), 8)
		PRINT [ofile], "emeix.I  = "; emeix.I,  TAB(36); HEX$(DHIGH(emeix.I), 8);;  HEX$(DLOW(emeix.I), 8)
		PRINT [ofile], "epeix.R  = "; epeix.R,  TAB(36); HEX$(DHIGH(epeix.R), 8);;  HEX$(DLOW(epeix.R), 8)
		PRINT [ofile], "epeix.I  = "; epeix.I,  TAB(36); HEX$(DHIGH(epeix.I), 8);;  HEX$(DLOW(epeix.I), 8)
		PRINT [ofile], "sinr.R   = "; sinr.R,  TAB(36); HEX$(DHIGH(sinr.R), 8);;  HEX$(DLOW(sinr.R), 8)
		PRINT [ofile], "sinr.I   = "; sinr.I,  TAB(36); HEX$(DHIGH(sinr.I), 8);;  HEX$(DLOW(sinr.I), 8)
		PRINT [ofile], "cosr.R   = "; cosr.R,  TAB(36); HEX$(DHIGH(cosr.R), 8);;  HEX$(DLOW(cosr.R), 8)
		PRINT [ofile], "cosr.I   = "; cosr.I,  TAB(36); HEX$(DHIGH(cosr.I), 8);;  HEX$(DLOW(cosr.I), 8)
		PRINT [ofile], "tanr.R   = "; tanr.R,  TAB(36); HEX$(DHIGH(tanr.R), 8);;  HEX$(DLOW(tanr.R), 8)
		PRINT [ofile], "tanr.I   = "; tanr.I,  TAB(36); HEX$(DHIGH(tanr.I), 8);;  HEX$(DLOW(tanr.I), 8)
		PRINT [ofile], "asin.R   = "; asinx.R, TAB(36); HEX$(DHIGH(asinx.R), 8);; HEX$(DLOW(asinx.R), 8)
		PRINT [ofile], "asin.I   = "; asinx.I, TAB(36); HEX$(DHIGH(asinx.I), 8);; HEX$(DLOW(asinx.I), 8)
		PRINT [ofile], "acos.R   = "; acosx.R, TAB(36); HEX$(DHIGH(acosx.R), 8);; HEX$(DLOW(acosx.R), 8)
		PRINT [ofile], "acos.I   = "; acosx.I, TAB(36); HEX$(DHIGH(acosx.I), 8);; HEX$(DLOW(acosx.I), 8)
		PRINT [ofile], "atan.R   = "; atanx.R, TAB(36); HEX$(DHIGH(atanx.R), 8);; HEX$(DLOW(atanx.R), 8)
		PRINT [ofile], "atan.I   = "; atanx.I, TAB(36); HEX$(DHIGH(atanx.I), 8);; HEX$(DLOW(atanx.I), 8)
		PRINT [ofile], "sinhx.R  = "; sinhx.R,  TAB(36); HEX$(DHIGH(sinhx.R), 8);;  HEX$(DLOW(sinhx.R), 8)
		PRINT [ofile], "sinhx.I  = "; sinhx.I,  TAB(36); HEX$(DHIGH(sinhx.I), 8);;  HEX$(DLOW(sinhx.I), 8)
		PRINT [ofile], "coshx.R  = "; coshx.R,  TAB(36); HEX$(DHIGH(coshx.R), 8);;  HEX$(DLOW(coshx.R), 8)
		PRINT [ofile], "coshx.I  = "; coshx.I,  TAB(36); HEX$(DHIGH(coshx.I), 8);;  HEX$(DLOW(coshx.I), 8)
		PRINT [ofile], "tanhx.R  = "; tanhx.R,  TAB(36); HEX$(DHIGH(tanhx.R), 8);;  HEX$(DLOW(tanhx.R), 8)
		PRINT [ofile], "tanhx.I  = "; tanhx.I,  TAB(36); HEX$(DHIGH(tanhx.I), 8);;  HEX$(DLOW(tanhx.I), 8)

		PRINT [ofile], "powCC.R  = "; powCC.R, TAB(36); HEX$(DHIGH(powCC.R), 8);; HEX$(DLOW(powCC.R), 8)
		PRINT [ofile], "powCC.I  = "; powCC.I, TAB(36); HEX$(DHIGH(powCC.I), 8);; HEX$(DLOW(powCC.I), 8)
		PRINT [ofile], "powCR.R  = "; powCR.R,  TAB(36); HEX$(DHIGH(powCR.R), 8);;  HEX$(DLOW(powCR.R), 8)
		PRINT [ofile], "powCR.I  = "; powCR.I,  TAB(36); HEX$(DHIGH(powCR.I), 8);;  HEX$(DLOW(powCR.I), 8)
		PRINT [ofile], "powRC.R  = "; powRC.R,  TAB(36); HEX$(DHIGH(powRC.R), 8);;  HEX$(DLOW(powRC.R), 8)
		PRINT [ofile], "powRC.I  = "; powRC.I,  TAB(36); HEX$(DHIGH(powRC.I), 8);;  HEX$(DLOW(powRC.I), 8)
	LOOP
	IF (ofile != $$STDOUT) THEN CLOSE (ofile)
'
END FUNCTION
'
'
'  ############################
'  #####  XcmVersion$ ()  #####
'  ############################
'
FUNCTION  XcmVersion$ ()
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' ######################
' #####  Dcabs ()  ##### this version uses the Numerical Recipes method
' ######################
'
FUNCTION DOUBLE Dcabs (DCOMPLEX z) DOUBLE
'
	x = ABS(z.R)
	y = ABS(z.I)
'
	SELECT CASE TRUE
		CASE (x = 0#):	RETURN y
		CASE (y = 0#):	RETURN x
		CASE (x > y):		tmp = y / x : RETURN (x * Sqrt(1#+(tmp*tmp)))
		CASE ELSE:			tmp = x / y : RETURN (y * Sqrt(1#+(tmp*tmp)))
	END SELECT
END FUNCTION
'
'
' #######################
' #####  Dcacos ()  ##### from Handbook of Mathematical Functions
' #######################
'
FUNCTION DCOMPLEX Dcacos (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	alpha = XdcGetAlpha(z)
	beta  = XdcGetBeta (z)
	ans.R = Acos(beta)
	ans.I = -alpha
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Dcarg ()  ##### returns radians
' ######################
'
FUNCTION DOUBLE Dcarg (DCOMPLEX z) DOUBLE
	IF (z.I = 0) & (z.R = 0) THEN RETURN (0#)
	RETURN (Atan2(z.I, z.R))
END FUNCTION
'
'
' #######################
' #####  Dcasin ()  ##### from Handbook of Math Functions
' #######################
'
FUNCTION DCOMPLEX Dcasin (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	alpha = XdcGetAlpha(z)
	beta  = XdcGetBeta (z)

	ans.R = Asin(beta)
	ans.I = alpha
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Dcatan ()  #####
' #######################
'
FUNCTION DCOMPLEX Dcatan (DCOMPLEX z) DOUBLE
	DCOMPLEX	ans
'
'	z*z may not = -1"
'
	IF ((z.R = 0#) & (z.I = 1#)) THEN
		lastErr = ERROR ($$ErrorNatureInvalidArgument) : RETURN (0#)
	END IF
'
	xsq = z.R * z.R
	ysq = z.I * z.I
	yincsq = z.I + 1#
	yincsq = yincsq * yincsq
	ydecsq = z.I - 1#
	ydecsq = ydecsq * ydecsq
	ans.R = Atan((z.R * 2#) / (1# - xsq - ysq)) * 0.5#
	ans.I = Log((xsq + yincsq) / (xsq + ydecsq)) * 0.25#
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Dcconj ()  #####
' #######################
'
FUNCTION DCOMPLEX Dcconj (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	ans.R =  z.R
	ans.I = -z.I
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Dccos ()  #####
' ######################
'
FUNCTION DCOMPLEX Dccos (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	ans.R =  Cos(z.R) * Cosh(z.I)
	ans.I = -Sin(z.R) * Sinh(z.I)
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Dccosh ()  #####
' #######################
'
FUNCTION DCOMPLEX Dccosh (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	ans.R = Cosh(z.R) * Cos(z.I)
	ans.I = Sinh(z.R) * Sin(z.I)
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Dcexp ()  #####
' ######################
'
FUNCTION DCOMPLEX Dcexp (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	ans.R = Exp(z.R) * Cos(z.I)
	ans.I = Exp(z.R) * Sin(z.I)
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Dclog ()  #####
' ######################
'
FUNCTION DCOMPLEX Dclog (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	ans.R = Log(Dcnorm(z)) * 0.5#
	ans.I = Atan2(z.I, z.R)
	RETURN (ans)
END FUNCTION
'
'
' ########################
' #####  Dclog10 ()  #####
' ########################
'
FUNCTION DCOMPLEX Dclog10 (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	ans = Dclog(z)
	ans.R = ans.R * $$LOG10E
	ans.I = ans.I * $$LOG10E
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Dcnorm ()  #####
' #######################
'
FUNCTION DOUBLE Dcnorm (DCOMPLEX z) DOUBLE
'
	RETURN ((z.R * z.R) + (z.I * z.I))
END FUNCTION
'
'
' ########################
' #####  Dcpolor ()  #####
' ########################
'
FUNCTION DCOMPLEX Dcpolor (DOUBLE mag, DOUBLE angle) DOUBLE
	DCOMPLEX ans
'
	ans.R = mag * Cos(angle)
	ans.I = mag * Sin(angle)
	RETURN (ans)
END FUNCTION
'
'
' ##########################
' #####  Dcpowercc ()  #####
' ##########################
'
FUNCTION DCOMPLEX Dcpowercc (DCOMPLEX z, DCOMPLEX n) DOUBLE
	DCOMPLEX ans
'
	ans = Dcexp( n * Dclog(z) )
	RETURN (ans)
END FUNCTION
'
'
' ##########################
' #####  Dcpowercr ()  #####
' ##########################
'
FUNCTION DCOMPLEX Dcpowercr (DCOMPLEX z, DOUBLE n) DOUBLE
	DCOMPLEX ans
'
	ans = Dcexp( Dcrmul(Dclog(z), n) )
	RETURN (ans)
END FUNCTION
'
'
' ##########################
' #####  Dcpowerrc ()  #####
' ##########################
'
FUNCTION DCOMPLEX Dcpowerrc (DOUBLE z, DCOMPLEX n) DOUBLE
	DCOMPLEX ans
'
	ans = Dcexp( Dcrmul(n, Log(z)) )
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Dcrmul ()  #####
' #######################
'
FUNCTION DCOMPLEX Dcrmul (DCOMPLEX x, DOUBLE y) DOUBLE
	DCOMPLEX ans
'
	ans.R = x.R * y
	ans.I = x.I * y
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Dcsin ()  #####
' ######################
'
FUNCTION DCOMPLEX Dcsin (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	ans.R = Sin(z.R) * Cosh(z.I)
	ans.I = Cos(z.R) * Sinh(z.I)
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Dcsinh ()  #####
' #######################
'
FUNCTION DCOMPLEX Dcsinh (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	ans.R = Sinh(z.R) * Cos(z.I)
	ans.I = Cosh(z.R) * Sin(z.I)
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Dcsqrt ()  #####  Math Handbook
' #######################
'
FUNCTION DCOMPLEX Dcsqrt (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	zabs	= Dcabs(z)
	ans.R	= Sqrt( (zabs + z.R) * 0.5#)
	ans.I	= Sqrt( (zabs - z.R) * 0.5#) * SIGN(z.I)
	RETURN (ans)
'
'	*****************************************
'	*****  Dcsqrt2:  numeric recipes:  *****
'	*****************************************
'
'	IF (z.R = 0#) & (z.I = 0#) THEN ans.R = 0# : ans.I = 0# : RETURN (ans)
'	x = ABS(z.R)
'	y = ABS(z.I)
'	IF (x >= y) THEN
'		r = y/x
'		w = Sqrt(x) * Sqrt(0.5# * (1# + Sqrt(1# + (r*r))))
'	ELSE
'		r = x/y
'		w = Sqrt(y) * Sqrt(0.5# * (r  + Sqrt(1# + (r*r))))
'	END IF
'	IF z.R >= 0 THEN
'		ans.R = w
'		ans.I = z.I / (2# * w)
'	ELSE
'		IF z.I >= 0 THEN ans.I = w ELSE ans.I = -w
'		ans.R = z.I / (2# * ans.I)
'	END IF
'	RETURN (ans)
'
'	****************************************
'	*****  Dcsqrt3:  Turbo C++ method  *****
'	****************************************
'
'	sqrtzabs = Sqrt(Dcabs(z))
'	hargz = Dcarg(z) / 2#
'	ans.R = sqrtzabs * Cos(hargz)
'	ans.I = sqrtzabs * Sin(hargz)
'	RETURN (ans)
'
END FUNCTION
'
'
' ######################
' #####  Dctan ()  #####
' ######################
'
FUNCTION DCOMPLEX Dctan (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	denom = 1# / (Cos(2# * z.R) + Cosh(2# * z.I))
	ans.R = Sin (2# * z.R) * denom
	ans.I = Sinh (2# * z.I) * denom
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Dctanh ()  #####
' #######################
'
FUNCTION DCOMPLEX Dctanh (DCOMPLEX z) DOUBLE
	DCOMPLEX ans
'
	denom = 1# / (Cosh(2# * z.R) + Cos(2# * z.I))
	ans.R = Sinh(2# * z.R) * denom
	ans.I = Sin (2# * z.I) * denom
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Scabs ()  #####  This version uses the Numerical Recipes method
' ######################
'
FUNCTION SINGLE Scabs (SCOMPLEX z) SINGLE
'
	x = ABS(z.R)
	y = ABS(z.I)
'
	SELECT CASE TRUE
		CASE (x = 0#):	RETURN y
		CASE (y = 0#):	RETURN x
		CASE (x > y):		tmp = y / x : RETURN (x * Sqrt(1#+(tmp*tmp)))
		CASE ELSE:			tmp = x / y : RETURN (y * Sqrt(1#+(tmp*tmp)))
	END SELECT
END FUNCTION
'
'
' #######################
' #####  Scacos ()  ##### from Handbook of Mathematical Functions
' #######################
'
FUNCTION SCOMPLEX Scacos (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	alpha = XscGetAlpha(z)
	beta  = XscGetBeta (z)
	ans.R = Acos(beta)
	ans.I = -alpha
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Scarg ()  ##### returns radians
' ######################
'
FUNCTION SINGLE Scarg (SCOMPLEX z) SINGLE
'
	IF (z.I = 0) & (z.R = 0) THEN RETURN (0#)
	RETURN (Atan2(z.I, z.R))
END FUNCTION
'
'
' #######################
' #####  Scasin ()  ##### from Handbook of Math Functions
' #######################
'
FUNCTION SCOMPLEX Scasin (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	alpha = XscGetAlpha(z)
	beta  = XscGetBeta (z)
	ans.R = Asin(beta)
	ans.I = alpha
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Scatan ()  #####
' #######################
'
FUNCTION SCOMPLEX Scatan (SCOMPLEX z) SINGLE
	SCOMPLEX	ans
'
'	z*z may not = -1"
'
	IF ((z.R = 0#) & (z.I = 1#)) THEN
		lastErr = ERROR ($$ErrorNatureInvalidArgument)
		RETURN (0#)
	END IF
'
	xsq = z.R * z.R
	ysq = z.I * z.I
'
	yincsq = z.I + 1#
	yincsq = yincsq * yincsq
'
	ydecsq = z.I - 1#
	ydecsq = ydecsq * ydecsq
'
	ans.R = Atan((z.R * 2#) / (1# - xsq - ysq)) * 0.5#
	ans.I = Log((xsq + yincsq) / (xsq + ydecsq)) * 0.25#
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Scconj ()  #####
' #######################
'
FUNCTION SCOMPLEX Scconj (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	ans.R = 	z.R
	ans.I = - z.I
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Sccos ()  #####
' ######################
'
FUNCTION SCOMPLEX Sccos (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	ans.R =  Cos(z.R) * Cosh(z.I)
	ans.I = -Sin(z.R) * Sinh(z.I)
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Sccosh ()  #####
' #######################
'
FUNCTION SCOMPLEX Sccosh (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	ans.R = Cosh(z.R) * Cos(z.I)
	ans.I = Sinh(z.R) * Sin(z.I)
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Scexp ()  #####
' ######################
'
FUNCTION SCOMPLEX Scexp (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	ans.R = Exp(z.R) * Cos(z.I)
	ans.I = Exp(z.R) * Sin(z.I)
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Sclog ()  #####
' ######################
'
FUNCTION SCOMPLEX Sclog (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	ans.R = Log(Scnorm(z)) * 0.5#
	ans.I = Atan2(z.I, z.R)
	RETURN (ans)
END FUNCTION
'
'
' ########################
' #####  Sclog10 ()  #####
' ########################
'
FUNCTION SCOMPLEX Sclog10 (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	ans = Sclog(z)
	ans.R = ans.R * $$LOG10E
	ans.I = ans.I * $$LOG10E
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Scnorm ()  #####
' #######################
'
FUNCTION SINGLE Scnorm (SCOMPLEX z) SINGLE
	RETURN ((z.R * z.R) + (z.I * z.I))
END FUNCTION
'
'
' ########################
' #####  Scpolar ()  #####
' ########################
'
FUNCTION SCOMPLEX Scpolar (SINGLE mag, SINGLE angle) SINGLE
	SCOMPLEX ans
'
	ans.R = mag * Cos(angle)
	ans.I = mag * Sin(angle)
	RETURN (ans)
END FUNCTION
'
'
' ##########################
' #####  Scpowercc ()  #####
' ##########################
'
FUNCTION SCOMPLEX Scpowercc (SCOMPLEX z, SCOMPLEX n) SINGLE
	SCOMPLEX ans
'
	ans = Scexp( n * Sclog(z) )
	RETURN (ans)
END FUNCTION
'
'
' ##########################
' #####  Scpowercr ()  #####
' ##########################
'
FUNCTION SCOMPLEX Scpowercr (SCOMPLEX z, SINGLE n) SINGLE
	SCOMPLEX ans
'
	ans = Scexp( Scrmul(Sclog(z), n) )
	RETURN (ans)
END FUNCTION
'
'
' ##########################
' #####  Scpowerrc ()  #####
' ##########################
'
FUNCTION SCOMPLEX Scpowerrc (SINGLE z, SCOMPLEX n) SINGLE
	SCOMPLEX ans
'
	ans = Scexp( Scrmul(n, Log(z)) )
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Scrmul ()  #####
' #######################
'
FUNCTION SCOMPLEX Scrmul (SCOMPLEX x, SINGLE y) SINGLE
	SCOMPLEX ans
'
	ans.R = x.R * y
	ans.I = x.I * y
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Scsin ()  #####
' ######################
'
FUNCTION SCOMPLEX Scsin (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	ans.R = Sin(z.R) * Cosh(z.I)
	ans.I = Cos(z.R) * Sinh(z.I)
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Scsinh ()  #####
' #######################
'
FUNCTION SCOMPLEX Scsinh (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	ans.R = Sinh(z.R) * Cos(z.I)
	ans.I = Cosh(z.R) * Sin(z.I)
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Scsqrt ()  #####  Math Handbook
' #######################
'
FUNCTION SCOMPLEX Scsqrt (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	zabs	= Scabs(z)
	ans.R	= Sqrt( (zabs + z.R) * 0.5#)
	ans.I	= Sqrt( (zabs - z.R) * 0.5#) * SIGN(z.I)
	RETURN (ans)
'
'	*****************************************
'	*****  XSqrt2:  numeric recipes:  *****
'	*****************************************
'
'	IF (z.R = 0#) & (z.I = 0#) THEN ans.R = 0# : ans.I = 0# : RETURN (ans)
'	x = ABS(z.R)
'	y = ABS(z.I)
'	IF (x >= y) THEN
'		r = y/x
'		w = Sqrt(x) * Sqrt(0.5# * (1# + Sqrt(1# + (r*r))))
'	ELSE
'		r = x/y
'		w = Sqrt(y) * Sqrt(0.5# * (r  + Sqrt(1# + (r*r))))
'	END IF
'	IF z.R >= 0 THEN
'		ans.R = w
'		ans.I = z.I / (2# * w)
'	ELSE
'		IF z.I >= 0 THEN ans.I = w ELSE ans.I = -w
'		ans.R = z.I / (2# * ans.I)
'	END IF
'	RETURN (ans)
'
'	****************************************
'	*****  Scsqrt3:  Turbo C++ method  *****
'	****************************************
'
'	sqrtzabs = Sqrt(Scabs(z))
'	hargz = Scarg(z) / 2#
'	ans.R = sqrtzabs * Cos (hargz)
'	ans.I = sqrtzabs * Sin (hargz)
'	RETURN (ans)
'
END FUNCTION
'
'
' ######################
' #####  Sctan()  #####
' ######################
'
FUNCTION SCOMPLEX Sctan(SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	denom = 1# / (Cos(2# * z.R) + Cosh(2# * z.I))
	ans.R = Sin (2# * z.R) * denom
	ans.I = Sinh(2# * z.I) * denom
	RETURN (ans)
END FUNCTION
'
'
' #######################
' #####  Sctanh ()  #####
' #######################
'
FUNCTION SCOMPLEX Sctanh (SCOMPLEX z) SINGLE
	SCOMPLEX ans
'
	denom = 1# / (Cosh(2# * z.R) + Cos(2# * z.I))
	ans.R = Sinh(2# * z.R) * denom
	ans.I = Sin (2# * z.I) * denom
	RETURN (ans)
END FUNCTION
'
'
' ######################
' #####  Atan2 ()  #####
' ######################
'
FUNCTION DOUBLE Atan2 (DOUBLE y, DOUBLE x) DOUBLE
'
	IF ((x = 0) & (y = 0)) THEN
		errLast = ERROR($$ErrorNatureInvalidArgument) : RETURN(0#)
	END IF
	IF ((y = 0) & (x < 0)) THEN RETURN ($$PI)
'
	xsign = SIGN(x)
	ysign = SIGN(y)

	x = ABS(x)
	y = ABS(y)

	IF (x >= y) THEN
		s = (y/x)
	ELSE
		s = (x/y)
		inv = 1
	END IF

	res = Atan(s)
	IF inv THEN res = $$PIDIV2 - res            ' atan(y/x) = pi/2 - atan(x/y)
	IF (xsign = -1#) THEN res = $$PI - res
	RETURN (ysign * res)
END FUNCTION
'
'
' ############################  From Handbook of Mathematical Functions
' #####  XdcGetAlpha ()  #####  Called by XAsin and Dcacos
' ############################
'
'	returns the complete imaginary term, to be specific
'
FUNCTION DOUBLE XdcGetAlpha (DCOMPLEX z) DOUBLE
	ysq = z.I * z.I
	xincsq = z.R + 1#
	xincsq = xincsq * xincsq
	xdecsq = z.R - 1#
	xdecsq = xdecsq * xdecsq
	alpha = (Sqrt( xincsq + ysq ) + Sqrt( xdecsq + ysq ) ) * 0.5#
	RETURN ( Log(alpha + Sqrt((alpha*alpha) - 1#)) )
END FUNCTION
'
'
' ###########################
' #####  XdcGetBeta ()  #####
' ###########################
'
FUNCTION DOUBLE XdcGetBeta (DCOMPLEX z) DOUBLE
	ysq = z.I * z.I
	xincsq = z.R + 1#
	xincsq = xincsq * xincsq
	xdecsq = z.R - 1#
	xdecsq = xdecsq * xdecsq
	beta = (Sqrt( xincsq + ysq ) - Sqrt( xdecsq + ysq ) ) * 0.5#
	RETURN (beta)
END FUNCTION
'
'
' ############################  From Handbook of Mathematical Functions
' #####  XscGetAlpha ()  #####  Called by Scasin and XAcos
' ############################
'
'	returns the complete imaginary term, to be specific
'
FUNCTION SINGLE XscGetAlpha (SCOMPLEX z) SINGLE
	ysq = z.I * z.I
	xincsq = z.R + 1#
	xincsq = xincsq * xincsq
	xdecsq = z.R - 1#
	xdecsq = xdecsq * xdecsq
	alpha = (Sqrt( xincsq + ysq ) + Sqrt( xdecsq + ysq ) ) * 0.5#
	RETURN ( Log(alpha + Sqrt((alpha*alpha) - 1#)) )
END FUNCTION
'
'
' ###########################
' #####  XscGetBeta ()  #####
' ###########################
'
FUNCTION SINGLE XscGetBeta (SCOMPLEX z) SINGLE
	ysq = z.I * z.I
	xincsq = z.R + 1#
	xincsq = xincsq * xincsq
	xdecsq = z.R - 1#
	xdecsq = xdecsq * xdecsq
	beta = (Sqrt( xincsq + ysq ) - Sqrt( xdecsq + ysq ) ) * 0.5#
	RETURN (beta)

END FUNCTION
END PROGRAM
