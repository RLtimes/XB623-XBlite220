'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program tests various methods of doing
' range checking on a variable. In this case,
' the range is 0 - 255. It appears that type 5,
' is the most promising.
'	IF (x AND 0xFFFFFF00) THEN
'		IF (x < 0) THEN x = 0 ELSE x = 255
'	END IF
'
PROGRAM	"clamp"
VERSION	"0.0001"
CONSOLE
'
	IMPORT	"xst"
	IMPORT  "gdi32.dec"
	IMPORT	"user32"
	IMPORT	"kernel32"
	
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	SUBADDR subs[]

	GOSUB Init

	PRINT "1) Test functions for -1, 0, 255, 256: "
	PRINT

	FOR i = 0 TO 7

		PRINT "ClampX"; STRING$(i+1); ": ";
		x=-1 :	GOSUB @subs[i]:	PRINT x,
		x=0  :	GOSUB @subs[i]:	PRINT x,
		x=255:	GOSUB @subs[i]:	PRINT x,
		x=256:	GOSUB @subs[i]:	PRINT x

	NEXT i

	PRINT
	PRINT "Timed test for each clamp :";
	PRINT

	FOR i = 0 TO 7

		PRINT "ClampX"; STRING$(i+1); ":";
		d = 0
		start = GetTickCount ()
		FOR j = 0 TO 9999999
			x = -1 	: GOSUB @subs[i]
			x = 255	: GOSUB @subs[i]
			x = 0		: GOSUB @subs[i]
			x = 256	: GOSUB @subs[i]
		NEXT j

		d = GetTickCount () - start
		PRINT " msec ="; d

	NEXT i


	PRINT
	a$ = INLINE$ ("Press RETURN to QUIT >")

	RETURN

' ***** ClampX1 *****
SUB ClampX1
		IF x < 0 THEN
			x = 0
		ELSE
			IF x > 255 THEN x = 255
		END IF
END SUB

' ***** ClampX2 *****
SUB ClampX2
		x = (x > -1)*(x < 256)*x-(x > 255)*255
END SUB

' ***** ClampX3 *****
SUB ClampX3
		x = (x{1,31}-1)*(x < 256)*x-(x > 255)*255
END SUB

' ***** ClampX4 *****
SUB ClampX4
		x = MAX(0, MIN(x,255))
END SUB

' ***** ClampX5 *****
SUB ClampX5
	IF (x AND 0xFFFFFF00) THEN
		IF (x < 0) THEN x = 0 ELSE x = 255
	END IF
END SUB

' ***** ClampX6 *****
SUB ClampX6
	x = (x AND (x > 0) AND (x <= 255)) + (255 AND (x > 255))
END SUB

' ***** ClampX7 *****
SUB ClampX7

   SELECT CASE TRUE
    CASE (x < 0)   : x = 0
    CASE (x > 255) : x = 255
   END SELECT

END SUB

' ***** ClampX8 *****
SUB ClampX8
		IF (x < 0)   THEN x = 0
    IF (x > 255) THEN x = 255
END SUB

' ***** Init *****
SUB Init
	DIM subs[7]
	subs[0] = SUBADDRESS (ClampX1)
	subs[1] = SUBADDRESS (ClampX2)
	subs[2] = SUBADDRESS (ClampX3)
	subs[3] = SUBADDRESS (ClampX4)
	subs[4] = SUBADDRESS (ClampX5)
	subs[5] = SUBADDRESS (ClampX6)
	subs[6] = SUBADDRESS (ClampX7)
	subs[7] = SUBADDRESS (ClampX8)

END SUB

END FUNCTION
END PROGRAM
