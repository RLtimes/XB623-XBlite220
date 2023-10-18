'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' An OOP-like demo.
'
PROGRAM	"oop"
VERSION	"0.0002"
CONSOLE

TYPE OOPLIKE
  XLONG	    .var
  FUNCADDR  .squared (OOPLIKE)
  FUNCADDR  .cubed   (OOPLIKE)
  FUNCADDR  .timesX  (OOPLIKE, XLONG)
END TYPE

' inherit type OOPLIKE
TYPE MORE_OOPLIKE
  OOPLIKE .ooplike
  FUNCADDR .modX (OOPLIKE, XLONG)
END TYPE

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  OOPLIKE Initialize (b)
DECLARE FUNCTION  Squared (OOPLIKE this)
DECLARE FUNCTION  Cubed (OOPLIKE this)
DECLARE FUNCTION  TimesX (OOPLIKE this, x)
DECLARE FUNCTION  ModX (OOPLIKE this, x)
DECLARE FUNCTION  MORE_OOPLIKE InitMoreOop (b)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	SHARED OOPLIKE me, you
	SHARED MORE_OOPLIKE him

	me  = Initialize (3)
	you = Initialize (5)

	PRINT "================="

	PRINT "me.var      " , me.var
	PRINT "me.squared  " , @me.squared (@me)
	PRINT "me.cubed    " , @me.cubed   (@me)
	PRINT "me.timesX   " , @me.timesX  (@me, 100)

	PRINT "================="

	PRINT "you.var     " , you.var
	PRINT "you.squared " , @you.squared (@you)
	PRINT "you.cubed   " , @you.cubed   (@you)
	PRINT "you.timesX  " , @you.timesX  (@you, 100)

	PRINT "================="

	PRINT "Changing .var in me and you"

	me.var  = 6
	you.var = 7


	PRINT "================="

	PRINT "me.var      " , me.var
	PRINT "me.squared  " , @me.squared (@me)
	PRINT "me.cubed    " , @me.cubed   (@me)
	PRINT "me.timesX   " , @me.timesX  (@me, 100)

	PRINT "================="

	PRINT "you.var     " , you.var
	PRINT "you.squared " , @you.squared (@you)
	PRINT "you.cubed   " , @you.cubed   (@you)
	PRINT "you.timesX  " , @you.timesX  (@you, 100)

	PRINT "================="
	
' him inherits OOPLIKE functions and adds one more
  him = InitMoreOop (9)

  PRINT "him.ooplike.var     " , him.ooplike.var
  PRINT "him.ooplike.squared " , @him.ooplike.squared (@him.ooplike)
	PRINT "him.ooplike.cubed   " , @him.ooplike.cubed   (@him.ooplike)
	PRINT "him.ooplike.timesX  " , @him.ooplike.timesX  (@him.ooplike, 100)
	PRINT "him.modX            " , @him.modX  (@him.ooplike, 5)
	
	PRINT "================="

	INLINE$ ("Press any key to quit>")

END FUNCTION
'
'
' ###########################
' #####  Initialize ()  #####
' ###########################
'
FUNCTION  OOPLIKE Initialize (b)

	OOPLIKE this

  this.var     = b
  this.squared = &Squared ()
  this.cubed   = &Cubed ()
  this.timesX  = &TimesX ()

	RETURN this

END FUNCTION
'
'
' ########################
' #####  Squared ()  #####
' ########################
'
FUNCTION  Squared (OOPLIKE this)

  RETURN this.var * this.var

END FUNCTION
'
'
' ######################
' #####  Cubed ()  #####
' ######################
'
FUNCTION  Cubed (OOPLIKE this)

	RETURN this.var * this.var * this.var

END FUNCTION
'
'
' #######################
' #####  TimesX ()  #####
' #######################
'
FUNCTION  TimesX (OOPLIKE this, x)

	RETURN this.var * x

END FUNCTION
'
'
' #####################
' #####  ModX ()  #####
' #####################
'
FUNCTION  ModX (OOPLIKE this, x)

	RETURN this.var MOD x

END FUNCTION
'
' ############################
' #####  InitMoreOop ()  #####
' ############################
'
FUNCTION  MORE_OOPLIKE InitMoreOop (b)

	MORE_OOPLIKE that

  that.ooplike = Initialize (b)
  that.modX    = &ModX ()

	RETURN that

END FUNCTION
END PROGRAM
