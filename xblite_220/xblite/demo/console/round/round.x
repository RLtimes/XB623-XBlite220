'
' ####################
' #####  PROLOG  #####
' ####################
'
' Example of using ROUND, ROUNDNE, and CEIL intrinsics.
' Demo by Alan Gent
'
PROGRAM "round"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
'
' ROUND
'  syntax   float = ROUND(float)
'           rounds towards nearest integer, .5 rounds up towards positive infinity
'
' ROUNDNE
'  syntax   float = ROUNDNE(float)
'           rounds towards nearest integer, .5 rounds up or down to whichever is the even integer
'
' CEIL
'  syntax   float = CEIL(float)
'           rounds upwards towards positive infinity  - opposite of INT()
'
'
' b# = 2.352
' c# = 2.5
' d# = 2.567
' e# = 3.5 
'
' f# = ROUND(b#)   'f# = 2.000#
' g# = ROUND(c#)   'g# = 3.000#
' h# = ROUND(d#)   'h# = 3.000#
' i# = ROUND(e#)   'i# = 4.000#
' 
' j# = ROUNDNE(b#)   'j# = 2.000#
' k# = ROUNDNE(c#)   'k# = 2.000#
' l# = ROUNDNE(d#)   'l# = 3.000#
' m# = ROUNDNE(e#)   'm# = 4.000#
'
' n# = CEIL(b#)   'n# = 3.000#
' o# = CEIL(c#)   'o# = 3.000#
' p# = CEIL(d#)   'p# = 3.000#
' q# = CEIL(e#)   'q# = 4.000#

'
DECLARE FUNCTION Entry ()


'
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()
'doubles
b# = 2.352
c# = 2.5
d# = 2.567
e# = 3.5
f# = -2.352
g# = -2.5
h# = -2.567
i# = -3.5

PRINT "doubles ..."
PRINT TAB(10); "INT    FIX   ROUND   ROUNDNE   CEIL"
PRINT b#; TAB(10); INT(b#); TAB(17) FIX(b#); TAB(24); ROUND(b#); TAB(33); ROUNDNE(b#); TAB(42); CEIL(b#)
PRINT c#; TAB(10); INT(c#); TAB(17) FIX(c#); TAB(24); ROUND(c#); TAB(33); ROUNDNE(c#); TAB(42); CEIL(c#)
PRINT d#; TAB(10); INT(d#); TAB(17) FIX(d#); TAB(24); ROUND(d#); TAB(33); ROUNDNE(d#); TAB(42); CEIL(d#)
PRINT e#; TAB(10); INT(e#); TAB(17) FIX(e#); TAB(24); ROUND(e#); TAB(33); ROUNDNE(e#); TAB(42); CEIL(e#)
PRINT f#; TAB(10); INT(f#); TAB(17) FIX(f#); TAB(24); ROUND(f#); TAB(33); ROUNDNE(f#); TAB(42); CEIL(f#)
PRINT g#; TAB(10); INT(g#); TAB(17) FIX(g#); TAB(24); ROUND(g#); TAB(33); ROUNDNE(g#); TAB(42); CEIL(g#)
PRINT h#; TAB(10); INT(h#); TAB(17) FIX(h#); TAB(24); ROUND(h#); TAB(33); ROUNDNE(h#); TAB(42); CEIL(h#)
PRINT i#; TAB(10); INT(i#); TAB(17) FIX(i#); TAB(24); ROUND(i#); TAB(33); ROUNDNE(i#); TAB(42); CEIL(i#)
PRINT

'integers
sb@ = 78
ub@@ = 80
ss% = 2
su%% = 3
sl& = 7
ul&& = 897
xl = 453
g$$ = 1234
'all integer types handled and remain unchanged
PRINT "integers ..."
PRINT ROUND(sb@), ROUND(ub@@), ROUND(ss%), ROUND(su%%), CEIL(sl&), CEIL(ul&&), ROUNDNE(xl), ROUNDNE(g$$)
PRINT

'singles
s1! = 3.2: s2! = 3.5: s3! = 3.7
PRINT "singles ..."
PRINT INT(s1!), FIX(s1!), ROUND(s1!), ROUNDNE(s1!), CEIL(s1!)
PRINT INT(s2!), FIX(s2!), ROUND(s2!), ROUNDNE(s2!), CEIL(s2!)
PRINT INT(s3!), FIX(s3!), ROUND(s3!), ROUNDNE(s3!), CEIL(s3!)
PRINT

'longdoubles
ld1## = 3.2: ld2## = 3.5: ld3## = 3.7
PRINT "longdoubles ..."
PRINT INT(ld1##), FIX(ld1##), ROUND(ld1##), ROUNDNE(ld1##), CEIL(ld1##)
PRINT INT(ld2##), FIX(ld2##), ROUND(ld2##), ROUNDNE(ld2##), CEIL(ld2##)
PRINT INT(ld3##), FIX(ld3##), ROUND(ld3##), ROUNDNE(ld3##), CEIL(ld3##)
PRINT

'examples
a# = 3.2
b# = -4.7
PRINT "CEIL (3.2)="; CEIL(a#)
PRINT "CEIL(-4.7)="; CEIL(b#)
PRINT

a# = 3.2
b# = 3.5
c# = 3.8
d# = 4.2
e# = 4.5
f# = 4.8
PRINT "ROUNDNE(3.2)="; ROUNDNE(a#)
PRINT "ROUNDNE(3.5)="; ROUNDNE(b#)
PRINT "ROUNDNE(3.8)="; ROUNDNE(c#)
PRINT "ROUNDNE(4.2)="; ROUNDNE(d#)
PRINT "ROUNDNE(4.5)="; ROUNDNE(e#)
PRINT "ROUNDNE(4.8)="; ROUNDNE(f#)
PRINT
a# = 3.2
b# = 3.5
c# = 3.8
d# = -7.2
e# = -7.5
f# = -7.8
PRINT "ROUND (3.2)="; ROUNDNE(a#)
PRINT "ROUND (3.5)="; ROUNDNE(b#)
PRINT "ROUND (3.8)="; ROUNDNE(c#)
PRINT "ROUND(-7.2)="; ROUNDNE(d#)
PRINT "ROUND(-7.5)="; ROUNDNE(e#)
PRINT "ROUND(-7.8)="; ROUNDNE(f#)

a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM