
TYPE NEWTYPE
	XLONG .ok
	XLONG .okdokey
END TYPE

DECLARE FUNCTION TestFunc ()
DECLARE FUNCTION Foo ()

$$MYCONSTANT = 7
'
' ######################
' #####  TestFunc  #####
' ######################
'
'
'
FUNCTION TestFunc ()

	PRINT "TestFunc() called from include.inc"

END FUNCTION

FUNCTION Foo ()

	PRINT "Foo() called from include.inc"
	
END FUNCTION
