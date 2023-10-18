' 
' ####################
' #####  PROLOG  #####
' ####################
' 
' Demo of using XstSaveCompositeDataArray and XstLoadCompositeDataArray.
' 
PROGRAM "comparray1"
VERSION "0.0001"
CONSOLE
' 
IMPORT "xst"		' Standard library : required by most programs
IMPORT "xsx"		' Extended standard library

DECLARE FUNCTION Entry ()

TYPE TESTTYPE
	XLONG .x
	XLONG .y
	STRING * 10 .z
END TYPE

' 
' ######################
' #####  Entry ()  #####
' ######################
'
' Demonstrates saving a composite array to a string and reloading it into another array
' This array is then saved as a file
'
FUNCTION Entry ()

	TESTTYPE t[], z[]

	DIM t[9]
	DIM z[0]		'must be dimensioned but will be redimensioned to accommodate data

	' populate t[] with some data
	FOR i = 0 TO UBOUND (t[])
		t[i].x = i
		t[i].y = 3 * i
		t[i].z = CHR$ ( 'a' + i, 10)
	NEXT i

	' template$ summarises the composite definition
	template$ = "TYPE,XLONG,XLONG,STRING*10"

	' save the data in t[] to output$ with 3 composites per line and enclosing braces
	XstSaveCompositeDataArray (@t[], @output$, template$, 3, $$TRUE, @errornum)

	PRINT "Save error = "; errornum
	' display the saved data
	PRINT output$

	' load data back into z[]
	XstLoadCompositeDataArray (@z[], output$, template$, @errornum)
	PRINT "Load error = "; errornum

	' Check that z[] has been correctly dimensioned and populated
	FOR i = 0 TO UBOUND (z[])
		PRINT z[i].x, z[i].y, z[i].z
	NEXT i

	' save z[] to a file with 1 composite per line and no braces
	' this is the most suitable format for viewing / editting in a spreadsheet
	XstSaveCompositeDataArray (@z[], "outfile.csv", template$, 1, 0, @errornum)
	PRINT "Save error = "; errornum

	' now view outfile.csv in EXCEL or a word processor

	a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

END PROGRAM