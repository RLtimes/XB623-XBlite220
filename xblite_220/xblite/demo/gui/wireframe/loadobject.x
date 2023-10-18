'
'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"progname"  ' 1-8 char program/file name without .x or any .extent
VERSION	"0.0000"    ' version number - increment before saving altered program
'
' You can stop the PDE from inserting the following PROLOG comment lines
' by removing them from the prolog.xxx file in your \xb\xxx directory.
'
' Programs contain:  1: PROLOG          - no executable code - see below
'                    2: Entry function  - start execution at 1st declared func
' * = optional       3: Other functions - everything else - all other functions
'
' The PROLOG contains (in this order):
' * 1. Program name statement             PROGRAM "progname"
' * 2. Version number statement           VERSION "0.0000"
' * 3. Import library statements          IMPORT  "libName"
' * 4. Composite type definitions         TYPE <typename> ... END TYPE
'   5. Internal function declarations     DECLARE/INTERNAL FUNCTION Func (args)
' * 6. External function declarations     EXTERNAL FUNCTION FuncName (args)
' * 7. Shared constant definitions        $$ConstantName = literal or constant
' * 8. Shared variable declarations       SHARED  variable
'
' ******  Comment libraries in/out as needed  *****
'
'	IMPORT	"xma"   ' Math library     : SIN/ASIN/SINH/ASINH/LOG/EXP/SQRT...
'	IMPORT	"xcm"   ' Complex library  : complex number library  (trig, etc)
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
'	IMPORT	"xgr"   ' GraphicsDesigner : required by GuiDesigner programs
'	IMPORT	"xui"   ' GuiDesigner      : required by GuiDesigner programs
'
TYPE VERTICE
	DOUBLE	.x
	DOUBLE	.y
	DOUBLE	.z
END TYPE

' ************ .raw format **************
TYPE FACET
	ULONG	.nVertices
	VERTICE	.v[5]
END TYPE

TYPE WIREOBJ
	ULONG	.nFacets
	FACET	.f[2047]
END TYPE

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  LoadObject (fileName$, WIREOBJ obj)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' Programs contain:
'   1. A PROLOG with type/function/constant declarations.
'   2. This Entry() function where execution begins.
'   3. Zero or more additional functions.
'
FUNCTION  Entry ()

	WIREOBJ object
	XstClearConsole ()

	err = LoadObject ("cube.raw", @object)		' load an object from a file

	PRINT "nFacets="; object.nFacets


END FUNCTION
'
'
' ###########################
' #####  LoadObject ()  #####
' ###########################
'
FUNCTION  LoadObject (fileName$, WIREOBJ obj)

	ifile = OPEN(fileName$, $$RD)
	IF ifile < 0 THEN GOSUB Error

	fileSize = LOF(ifile)
	IF fileSize THEN
		text$ = NULL$(fileSize)
		READ [ifile], text$
	END IF
	CLOSE (ifile)

'	DIM text$[]
	XstStringToStringArray (text$, @text$[])

	upper = UBOUND(text$[])
	obj.nFacets = upper + 1

' parse line
	FOR i = 0 TO upper
		line$ = TRIM$(text$[i])
		GOSUB ParseLine
		index = 0
		nVertices = ULONG(data$[index])
		INC index
		obj.f[i].nVertices = nVertices

		FOR j = 0 TO nVertices-1
			obj.f[i].v[j].x = DOUBLE(data$[index]) : INC index
			obj.f[i].v[j].y = DOUBLE(data$[index]) : INC index
			obj.f[i].v[j].z = DOUBLE(data$[index]) : INC index
		NEXT j

	NEXT i

' ***** ParseLine *****
SUB ParseLine
	DIM data$[18]
	count = 0
	top = LEN(line$) - 1
	FOR v = 0 TO top
		c = line${v}
		IF c = 32 || c = 10 || c = 13 THEN
 			INC count
			DO NEXT
		END IF
		data$[count] = data$[count] + CHR$(c)
	NEXT v
END SUB

RETURN


' ***** Error *****
SUB Error
	error = ERROR (0)
	XstErrorNumberToName (error, @error$)
	PRINT "error #"; error; "  = "; error$
	IF (ifile > 3) THEN CLOSE (ifile)
	RETURN ($$TRUE)
END SUB


END FUNCTION
END PROGRAM
