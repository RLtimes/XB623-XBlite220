'
' ####################
' #####  PROLOG  #####
' ####################
'
' Test various aspects of PRINT and ? statements
'
CONSOLE

DECLARE FUNCTION Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	PRINT 100
	PRINT 100;100;100				' use ; as delimiter 
	PRINT 100;;100;;100			' each extra ; is treated as space
	PRINT 100,100,100				' use , to align on next tab position
	PRINT
	
	PRINT -100
	PRINT -100;-100;-100
	PRINT -100;;-100;;-100
	PRINT -100,-100,-100
	PRINT
	
	?100
	?100;100;100
	?100;;100;;100
	?100,100,100
	?
	
	? -100
	? -100;-100;-100
	? -100;;-100;;-100
	? -100,-100,-100
	?

	PRINT TAB(5); 100; TAB(10); 100
	? TAB(5); 100; TAB(10); 100
	
  INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM