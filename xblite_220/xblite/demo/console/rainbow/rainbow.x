'
' ####################
' #####  PROLOG  #####
' ####################
'
' A 256 color console demo program.
'
PROGRAM "rainbow"
VERSION "0.0001"
CONSOLE
IMPORT  "xst"
IMPORT  "xio"	

DECLARE FUNCTION Entry ()

FUNCTION Entry ()

	DIM sColors$[15]

	sColors$[0] = "Color Black:"
	sColors$[1] = "Color Dark Blue:"
	sColors$[2] = "Color Dark Green:"
	sColors$[3] = "Color Dark Aqua:"
	sColors$[4] = "Color Dark Red:"
	sColors$[5] = "Color Dark Purple:"
	sColors$[6] = "Color Dark Yellow:"
	sColors$[7] = "Color Dark White:"
	sColors$[8] = "Color Gray:"
	sColors$[9] = "Color Blue: "
	sColors$[10] = "Color Green:"
	sColors$[11] = "Color Aqua:"
	sColors$[12] = "Color Red:"
	sColors$[13] = "Color Purple:"
	sColors$[14] = "Color Yellow:"
	sColors$[15] = "Color White:     "
	
	hStdOut = XioGetStdOut () 
	
	' Show all 16x16 (256) Foreground to Background colors in a Rainbow.
  FOR iz = 0 TO 255 STEP 16											' background color
    FOR ix = 0 TO 15 														' text color (0 - 15)
      IF ((ix == 5) || (ix == 10)) THEN PRINT  	' start new line at item 5 and 10
			XioSetTextAttributes (hStdOut, ix | iz) 
      PRINT sColors$[ix];
		NEXT ix
		PRINT
	NEXT iz
	
	XioSetDefaultColors (hStdOut) 

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM