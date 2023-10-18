'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of displaying the date and 
' time in various formats.
'
PROGRAM	"datetimeformat"
VERSION	"0.0001" 
CONSOLE

IMPORT	"xst"   ' Standard library : required by most programs
IMPORT	"xsx"
IMPORT  "kernel32"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  GetDateAndTimeFormatted (language, dateFormat, @date$, timeFormat, @time$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	PRINT " *****  date format  *****  example  *****"

	FOR i = 0 TO 12
		GetDateAndTimeFormatted (language, i, @date$, timeFormat, @time$)
		PRINT "dateFormat ="; i; " : "; date$
	NEXT i

	PRINT
	PRINT " *****  time format  *****  example  *****"

	FOR i = 0 TO 8
		GetDateAndTimeFormatted (language, dateFormat, @date$, i, @time$)
		PRINT "timeFormat ="; i; " : "; time$
	NEXT i
	
	a$ = INLINE$ ("Press Enter to quit >")


END FUNCTION
'
'
' ########################################
' #####  GetDateAndTimeFormatted ()  #####
' ########################################
'
'PURPOSE	: Provide the current date and time in a formatted string
'IN				: language (see list below, 0 = English)
'						dateFormat (see list below)
'						timeFormat (see list below)
'OUT			: date$, time$
'         : return is 0 on success, -1 on error
'USE			: GetDateAndTimeFormatted (0, 3, @date$, 6, @time$)

'*****  language values  *****
' english = 0

'*****  date format  *****  example  *****
'	dateFormat =  0 : 2001/01/12
'	dateFormat =  1 : 01/12/2001
'	dateFormat =  2 : 01/12/01
'	dateFormat =  3 : Friday, 01/12/01
'	dateFormat =  4 : 12/01/2001
'	dateFormat =  5 : 12/01/01
'	dateFormat =  6 : Friday, 12/01/01
'	dateFormat =  7 : Friday, January 12, 2001
'	dateFormat =  8 : January 12, 2001
'	dateFormat =  9 : 12 January, 2001
'	dateFormat = 10 : 12-Jan-01
'	dateFormat = 11 : Jan-01
'	dateFormat = 12 : Fri, 12 Jan 2001

' *****  time format  *****  example  *****
'	timeFormat = 0 : 19:31 GMT
'	timeFormat = 1 : 19:31:31 GMT
'	timeFormat = 2 : 20:31 +0100 GMT
'	timeFormat = 3 : 20:31:31 +0100 GMT
'	timeFormat = 4 : 07:31 PM GMT
'	timeFormat = 5 : 07:31:31 PM GMT
'	timeFormat = 6 : 08:31 PM +0100 GMT
'	timeFormat = 7 : 08:31:31 PM +0100 GMT
'	timeFormat = 8 : 08:31:31 PM

FUNCTION  GetDateAndTimeFormatted (language, dateFormat, @date$, timeFormat, @time$)

  TIME_ZONE_INFORMATION tzi

	DIM day$[7]
	DIM month$[13]

	SELECT CASE language
		CASE 0 :
			day$[0] = "Sunday"
			day$[1] = "Monday"
			day$[2] = "Tuesday"
			day$[3] = "Wednesday"
			day$[4] = "Thursday"
			day$[5] = "Friday"
			day$[6] = "Saturday"
			month$[1] = "January"
			month$[2] = "February"
			month$[3] = "March"
			month$[4] = "April"
			month$[5] = "May"
			month$[6] = "June"
			month$[7] = "July"
			month$[8] = "August"
			month$[9] = "September"
			month$[10]= "October"
			month$[11]= "November"
			month$[12]= "December"
	END SELECT

	XstGetDateAndTime (@year, @month, @day, @weekday, @hour, @minute, @second, @nano)

	SELECT CASE dateFormat
		CASE 0		: date$ = STRING$(year) + "/" + RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$("00" + STRING$(day), 2)

		CASE 1		: date$ = RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$("00" + STRING$(day), 2) + "/" + STRING$(year)
		CASE 2		: date$ = RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$(STRING$(year),2)
		CASE 3		: date$ = day$[weekday] + ", " + RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$(STRING$(year),2)

		CASE 4		: date$ = RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$("00" + STRING$(month), 2) + "/" + STRING$(year)
		CASE 5		: date$ = RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$(STRING$(year),2)
		CASE 6		: date$ = day$[weekday] + ", " + RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$(STRING$(year),2)

		CASE 7		: date$ = day$[weekday] + ", " + month$[month] + " " + STRING$(day) + ", " + STRING$(year)
		CASE 8		: date$ = month$[month] + " " + STRING$(day) + ", " + STRING$(year)
		CASE 9		: date$ = STRING$(day) + " " + month$[month] + ", " + STRING$(year)
		CASE 10		: date$ = STRING$(day) + "-" + LEFT$(month$[month], 3) + "-" + RIGHT$(STRING$(year),2)
		CASE 11		: date$ = LEFT$(month$[month], 3) + "-" + RIGHT$(STRING$(year),2)
		CASE 12		: date$ = LEFT$(day$[weekday], 3) + ", " + STRING$(day) + " " + LEFT$(month$[month],3) + " " + STRING$(year)
	END SELECT

	XstGetLocalDateAndTime (0, 0, 0, 0, @localHour, 0, 0, 0)
	ret = GetTimeZoneInformation (&tzi)

	SELECT CASE ret
    CASE $$TIME_ZONE_ID_STANDARD : biasDaylight = tzi.StandardBias
    CASE $$TIME_ZONE_ID_DAYLIGHT : biasDaylight = tzi.DaylightBias
    CASE ELSE : RETURN ($$TRUE)
	END SELECT

	bias = tzi.Bias + biasDaylight
	diffGMT = bias/60.0

	sign = SIGN(diffGMT)
	IF sign > 0 THEN sign$ = "+" ELSE sign$ = "-"

	IF timeFormat > 3 THEN
		IF (hour < 12) THEN part1$ = " AM" ELSE part1$ = " PM" : hour = hour - 12
		IF (localHour < 12) THEN part2$ = " AM" ELSE part2$ = " PM" : localHour = localHour - 12
	END IF

	SELECT CASE timeFormat
			CASE 0		: time$ = RIGHT$("00" + STRING$(hour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + " GMT"
			CASE 1		: time$ = RIGHT$("00" + STRING$(hour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + " GMT"
			CASE 2		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + " " + sign$ + RIGHT$("00" + STRING$(ABS(diffGMT)) + "00", 4) + " GMT"
			CASE 3		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + " " + sign$ + RIGHT$("00" + STRING$(ABS(diffGMT)) + "00", 4) + " GMT"

			CASE 4		: time$ = RIGHT$("00" + STRING$(hour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + part1$  + " GMT"
			CASE 5		: time$ = RIGHT$("00" + STRING$(hour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + part1$  + " GMT"
			CASE 6		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + part2$  + " " + sign$ + RIGHT$("00" + STRING$(ABS(diffGMT)) + "00", 4) + " GMT"
			CASE 7		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + part2$  + " " + sign$ + RIGHT$("00" + STRING$(ABS(diffGMT)) + "00", 4) + " GMT"
			
			CASE 8		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + part2$

	END SELECT

END FUNCTION
END PROGRAM
