'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo of using FORMAT$ intrinsic.
'
PROGRAM	"format"
VERSION	"0.0002"
CONSOLE

'	IMPORT  "xst_s.lib"

DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

' test FORMAT$

	left$   = "left"
	center$ = "center"
	right$  = "right"
	PRINT
	PRINT "<"; FORMAT$ ("  ######.#####", 23);              ">"
	PRINT "<"; FORMAT$ (" $######.#####", 234567$$);        ">"
	PRINT "<"; FORMAT$ ("*#######.#####", 23.456789!);      ">"
	PRINT "<"; FORMAT$ ("*#######.#####", 23.456789#);      ">"
	PRINT "<"; FORMAT$ ("   ###,###,###", 23456789);				">"
	PRINT "<"; FORMAT$ ("<<<<<<<<<<<<<<", "left");          ">"
	PRINT "<"; FORMAT$ ("||||||||||||||", "center");        ">"
	PRINT "<"; FORMAT$ (">>>>>>>>>>>>>>", "right");         ">"
	PRINT "<"; FORMAT$ ("<<<<<<<<<<<<<<", left$);           ">"
	PRINT "<"; FORMAT$ ("||||||||||||||", center$);         ">"
	PRINT "<"; FORMAT$ (">>>>>>>>>>>>>>", right$);          ">"
	PRINT "<"; FORMAT$ ("<<<<<<<<<<<<<<", left$+left$);     ">"
	PRINT "<"; FORMAT$ ("||||||||||||||", center$+center$); ">"
	PRINT "<"; FORMAT$ (">>>>>>>>>>>>>>", right$+right$);   ">"
	width = 14
	PRINT "<"; FORMAT$ (CHR$('<',width), left$); 						">"
	PRINT "<"; FORMAT$ (CHR$('|',width), center$); 					">"
	PRINT "<"; FORMAT$ (CHR$('>',width), right$); 					">"
	PRINT

' set some columns

	width1 = 4
	width2 = 5
	width3 = 6
	width4 = 7
	headFormat$ = CHR$('>', 18)
	FOR i = 1 TO 8
		number1 = i
		number2 = i * i
		number3 = i * i * i
		number4 = i * i * i * i
		name$ = "heading " + CHR$('>',i)
		PRINT FORMAT$(headFormat$,name$); FORMAT$(CHR$('#',width1),number1); FORMAT$(CHR$('#',width2),number2); FORMAT$(CHR$('#',width3),number3); FORMAT$(CHR$('#',width4),number4)
	NEXT i

	PRINT
	a$ = INLINE$ ("Press any key to quit >")

END FUNCTION
END PROGRAM
