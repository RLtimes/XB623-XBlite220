'
' ####################
' #####  PROLOG  #####
' ####################
'
' Test line extension "_" 
'
PROGRAM "helloworld"
VERSION "0.0001"
CONSOLE
'
'	IMPORT  "xst"				' Standard library : required by most programs
'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION AddThis (a, b)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

' in extending strings, leading spaces and tabs are included in string!
PRINT _		' a comment
" _
H _
e _
l _				' another comment
l _
o _
W _
o _
r _
l _
d _
! _
"         ' last comment
	
	x = AddThis (5, 10)
	PRINT x

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

FUNCTION AddThis (a, _		' comment on a parameter
									b  _		' comment on b parameter
									)   		' comment at end
									
	RETURN a + b						' comment here

END FUNCTION
END PROGRAM