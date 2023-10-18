' 
' ####################
' #####  PROLOG  #####
' ####################
' 
' Demonstrates saving a composite array to a string
' loading a composite array from a string
' saving a composite array to a file
' loading a composite array from a file
' creation of template$ for sub-arrays and sub-composites
' use of formatting options when saving an array
' 
PROGRAM "comparray2"
VERSION "0.0001"
CONSOLE

IMPORT "xst"
IMPORT "xsx"				' Extended standard library
IMPORT "xio"				' Console input/ouput library
IMPORT "gdi32"			' gdi32.dll
IMPORT "kernel32"		' kernel32.dll


DECLARE FUNCTION Entry ()

TYPE TESTTYPE
	XLONG .x[2]		'numeric sub-array
	DOUBLE .d
	STRING * 10 .z[2]		'string sub-array
	GIANT .g
	POINT .p		'sub-composite
END TYPE


' 
' ######################
' #####  Entry ()  #####
' ######################
' 
FUNCTION Entry ()

	TESTTYPE t[], z[], v[]

	' create a decent sized scrolling console window
	hStdOut = XioGetStdOut ()
	XioSetTextColor (hStdOut, $$WHITE)
	XioSetTextBackColor (hStdOut, $$LIGHTBLUE)
	FillConsoleOutputAttribute (hStdOut, $$WHITE | $$BACKGROUND_BLUE | $$BACKGROUND_INTENSITY, 0xFFFFFF, 0, &written)
	XioSetConsoleBufferSize (hStdOut, 100, 100)

	DIM t[9]
	DIM z[0]		'will be redimensioned to accommodate data
	' 
	' populate t[] with some data
	FOR i = 0 TO UBOUND (t[])
		t[i].x[0] = i
		t[i].x[1] = i * 2
		t[i].x[2] = i * 3
		t[i].d = i * 3.14159
		t[i].z[0] = CHR$ ( 'a' + i, 10)
		t[i].z[1] = CHR$ ( 'A' + i, 10)
		t[i].z[2] = "abc,d{e},j"
		t[i].g = i * 1000
		t[i].p.x = i + 100
		t[i].p.y = i + 300
	NEXT i
	' 
	' template$ summarises the composite definition
	' note that the arrays .x[2] and .z[2] have been expanded into their individual fields
	' also the composite POINT .p has been expanded to XLONG,XLONG
	template$ = "TYPE,XLONG,XLONG,XLONG,DOUBLE,STRING*10,STRING*10,STRING*10,GIANT,XLONG,XLONG"

	' save the data in t[] to output$
	' note that the , { } in t[i].z[2] are saved as special characters to avoid clashing with the
	' use of these characters for formatting.
	XstSaveCompositeDataArray (@t[], @output$, template$, 1, 0, @errornum)

	PRINT "Save error = "; errornum
	' display the saved data as comma separated variables at 1 composite per line with no braces
	PRINT "Output string from save of t[]"
	PRINT output$
	PRINT

	' load data back into z[]
	XstLoadCompositeDataArray (@z[], output$, template$, @errornum)
	PRINT "Load error = "; errornum

	' Check that z[] has been correctly dimensioned and populated
	' The special characters are automatically converted back to , { }
	PRINT "Data in z[] after loading from output$"
	FOR i = 0 TO UBOUND (z[])
		PRINT z[i].x[0], z[i].x[1], z[i].x[2], z[i].d, z[i].z[0], z[i].z[1], z[i].z[2], z[i].g, z[i].p.x, z[i].p.y
	NEXT i
	PRINT

	' Save z[] to a file with 2 composites per line and enclosing braces
	XstSaveCompositeDataArray (@z[], "zdata.txt", template$, 2, $$TRUE, @errornum)
	PRINT "Save error = "; errornum

	' And load it back into array v[] from the file
	DIM v[1000]		'give v[] far too many elements
	XstLoadCompositeDataArray (@v[], "zdata.txt", template$, @errornum)
	PRINT "Load error = "; errornum

	' Show contents of v[] - note that v[] has been redimensioned from v[1000] to v[9]
	PRINT "Contents of v[] after loading from file unloaded from z[]"
	FOR i = 0 TO UBOUND (v[])
		PRINT v[i].x[0], v[i].x[1], v[i].x[2], v[i].d, v[i].z[0], v[i].z[1], v[i].z[2], v[i].g, z[i].p.x, z[i].p.y
	NEXT i

	a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

END PROGRAM