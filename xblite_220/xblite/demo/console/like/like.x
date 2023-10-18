'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo uses a matching function 
' Like() which can be used to match
' a string against a masking string.
' Various masks can be used such as
' *, ?, #, $, and ranges [A-Z].
'
PROGRAM "like"
VERSION "0.0001"
CONSOLE
'
'IMPORT  "xst"
'
DECLARE  FUNCTION  Entry       ()
DECLARE  FUNCTION  Like        (string$, mask$)
DECLARE  FUNCTION  DoMatch     (stringAddr, maskAddr)
DECLARE  FUNCTION  IsDigit     (char)
DECLARE  FUNCTION  IsAlpha     (char)
DECLARE  FUNCTION  ParseRange  (p, @not, @start, @end, @count, @error)
DECLARE  FUNCTION  CheckRange  (char, start, end)

$$LIKE_TRUE		=	1
$$LIKE_FALSE	=	0
$$LIKE_ABORT	=	-1

$$LIKE_BAD_RANGE_FORMAT = -2
$$LIKE_MISSING_BRACKET = -3
$$LIKE_INVALID_RANGE = -4
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

  IF LIBRARY (0) THEN RETURN

  string$ = "help"
  mask$ = "h*p"
  mask$ = "h??p"
  mask$ = "*p"
  mask$ = "h*"
  mask$ = "h*x"
  mask$ = "*lp"
  
  string$ = "abcdef9"
  mask$ = "*#"
  mask$ = "abcdef#"
  mask$ = "*$"
  mask$ = "$$$$$$$"
  mask$ = "$$$$$$#"
  mask$ = "$bcdef#"
  mask$ = "$*#"

  string$ = "147"
  string$ = "947"
  string$ = "197"
  string$ = "141"
  mask$ = "[0-3][4-6][7-9]"
  
  string$ = "147"
  string$ = "141"
  mask$ = "[0-3][4-6][!7-9]"
  
  string$ = "abcdefghijk"
  mask$ = "*k"
  mask$ = "*?*"
  mask$ = "a*k"
  mask$ = "$*k"
  mask$ = "$*d*"
  
  string$ = "ABC"
  mask$ = "[A-Z][A-Z][a-z]"
  mask$ = "[A-Z][A-Z][A-Z]"
  mask$ = "*[a-z]*"
  mask$ = "*[A-Z]*"
  mask$ = "[A-Z]*"
  mask$ = "*[1-9]*"
  mask$ = "??[A-Z]"
	mask$ = "?B?"

  PRINT string$, mask$
  PRINT "result=", Like (string$, mask$)

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
'
' #####################
' #####  Like ()  #####
' #####################
'
' If match if found, returns $$TRUE.
'
FUNCTION  Like (string$, mask$)

  IFZ string$ THEN RETURN
  IFZ mask$ THEN RETURN
  IF mask${0} == '*' && mask${1} == '\0' THEN RETURN ($$TRUE)
  RETURN (DoMatch (&string$, &mask$) == $$LIKE_TRUE)

END FUNCTION
'
'
' ########################
' #####  DoMatch ()  #####
' ########################
'
' Match strings pointed to by 
' stringAddr and maskAddr.
' Return $$LIKE_TRUE, $$LIKE_FALSE, or $$LIKE_ABORT
' Mask characters:
' * - match any char, zero or more times
' ? - match any one char
' # - match any one digit 0123456789
' $ - match any one alpha char a-z, A-Z
' [c-c]  - match any one char within a range of chars; [A-Z]
' [!c-c] - match any one char not within a range of chars; [!x-z]
'
FUNCTION  DoMatch (stringAddr, maskAddr)

  p = maskAddr
  text = stringAddr
  
  DO WHILE (UBYTEAT (p) && UBYTEAT (text))
'PRINT UBYTEAT (p), CHR$ (UBYTEAT (p))
'PRINT UBYTEAT (text), CHR$ (UBYTEAT (text))

    SELECT CASE UBYTEAT (p)
      CASE '\\' : 
        INC p
        IF UBYTEAT (text) != UBYTEAT (p) THEN RETURN ($$LIKE_FALSE)
      CASE '#'  :                     ' match any one digit 0123456789
        IFZ IsDigit (UBYTEAT (text)) THEN RETURN ($$LIKE_FALSE)
      CASE '$'  :                     ' match any one alpha char a-z A-Z
        IFZ IsAlpha (UBYTEAT (text)) THEN RETURN ($$LIKE_FALSE)
      CASE '['  :                     ' match one from a range; [a-z]
        IFZ ParseRange (p, @not, @start, @end, @count, @error) THEN RETURN (error)
        IFZ not THEN
          IFZ CheckRange (UBYTEAT (text), start, end) THEN RETURN ($$LIKE_FALSE)
        ELSE
          IFT CheckRange (UBYTEAT (text), start, end) THEN RETURN ($$LIKE_FALSE)
        END IF
        p = p + count
      CASE '?'  :                     ' match any one char
      CASE '*'  :                     ' match zero or more - all chars
        DO WHILE UBYTEAT (p) == '*'   ' advance past all *'s
          INC p
        LOOP
        IF UBYTEAT (p) == '\0' THEN RETURN ($$LIKE_TRUE) ' trailing percent matches everything
        DO WHILE UBYTEAT (text)       ' optimization to prevent most recursion
          matched = DoMatch (text, p)
          pchar = UBYTEAT (p)
          IF ((UBYTEAT(text) == pchar || pchar == '\\' || pchar == '*' || pchar == '?' || pchar == '#' || pchar == '$' || pchar == '[') && (matched != $$LIKE_FALSE)) THEN
            RETURN matched
          END IF
          INC text
        LOOP
        RETURN ($$LIKE_ABORT)
      CASE ELSE : IF UBYTEAT (text) != UBYTEAT (p) THEN RETURN ($$LIKE_FALSE)
    END SELECT
    INC p
    INC text
  LOOP

  IF (UBYTEAT (text) != '\0') THEN
    RETURN ($$LIKE_ABORT)
  ELSE
' End of input string.  Do we have matching string remaining?
    IF (UBYTEAT (p) == '\0' || (UBYTEAT (p) == '*' && UBYTEAT (p+1) == '\0')) THEN
      RETURN ($$LIKE_TRUE)
    ELSE
      RETURN ($$LIKE_ABORT)
    END IF
  END IF
  RETURN

END FUNCTION
'
'
' ########################
' #####  IsDigit ()  #####
' ########################
'
' Returns $$TRUE if char is 0123456789.
'
FUNCTION  IsDigit (char)
  IF char > 47 && char < 58 THEN RETURN ($$TRUE)
END FUNCTION
'
'
' ########################
' #####  IsAlpha ()  #####
' ########################
'
' Returns $$TRUE if char is a-z or A-Z.
'
FUNCTION  IsAlpha (char)
  IF (char > 64 && char < 91) || (char > 96 && char < 123) THEN RETURN ($$TRUE)
END FUNCTION
'
'
' ###########################
' #####  ParseRange ()  #####
' ###########################
'
' Returns $$TRUE if range is valid.
' Returns not = $$TRUE if ! char is used.
' Returns start character and end character.
' On error, returns error code in error.
' Returned count contains number of bytes remaining in p
' Range must be from lower ascii value to higher ascii value; [A-Z]
' or equal; [!x-x]
'
FUNCTION  ParseRange (p, @not, @start, @end, @count, @error)

  not = 0
  start = 0
  end = 0
  count = 0
  error = 0

' find closing bracket
  pp = p
  DO WHILE UBYTEAT (p)
    INC pp
    INC count
    IF UBYTEAT (pp) == ']' THEN
      fBracket = $$TRUE
      EXIT DO
    END IF
  LOOP
  
  IFZ fBracket THEN 
    error = $$LIKE_MISSING_BRACKET
    RETURN
  END IF
  
' check max chars [!A-Z]
' count will be 4 or 5

  SELECT CASE count
    CASE 4 : 
      start = UBYTEAT (p+1)
      IF UBYTEAT (p+2) != '-' THEN error = $$LIKE_BAD_RANGE_FORMAT : RETURN
      end = UBYTEAT (p+3)
      not = $$FALSE
    CASE 5 :
      IF UBYTEAT (p+1) != '!' THEN error = $$LIKE_BAD_RANGE_FORMAT : RETURN
      start = UBYTEAT (p+2)
      IF UBYTEAT (p+3) != '-' THEN error = $$LIKE_BAD_RANGE_FORMAT : RETURN
      end = UBYTEAT (p+4)
      not = $$TRUE
    CASE ELSE : error = $$LIKE_BAD_RANGE_FORMAT : RETURN
  END SELECT
  
  IF end - start < 0 THEN error = $$LIKE_INVALID_RANGE : RETURN
  
  RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  CheckRange ()  #####
' ###########################
'
' Returns $$TRUE if char is within range of start and end.
'
FUNCTION  CheckRange (char, start, end)
  IF char > start-1 && char < end+1 THEN RETURN ($$TRUE)
END FUNCTION
END PROGRAM
