'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo extracting data from a resource.
' Any kind of binary data can be stored in
' a resource as RCDATA and retreived. In this
' example, a GIF file is stored as a resource,
' then loaded and copied back to a file.
'
PROGRAM	"rcdata"
VERSION	"0.0001"
CONSOLE
'
IMPORT  "xst"
IMPORT	"xsx"
'IMPORT  "xio"
IMPORT  "kernel32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  LoadResData (resName$, resID, @data$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

  err = LoadResData (resName$, 100, @data$)
  PRINT "LoadResData err ="; err
  PRINT "Size data$      ="; LEN (data$)
  
  IF data$ THEN 
    XstSaveString (@"dataGif1.gif", @data$)
    PRINT "Resource 100 GIF saved as dataGif1.gif"
  END IF

  data$ = ""
  err = LoadResData ("GO", 0, @data$)
  PRINT "LoadResData err ="; err
  PRINT "Size data$      ="; LEN (data$)
  
  IF data$ THEN 
    XstSaveString (@"dataGif2.gif", @data$)
    PRINT "Resource GO GIF saved as dataGif2.gif"
  END IF

	a$ = INLINE$("Press ENTER to exit >")
END FUNCTION
'
'
' #############################
' #####  LoadResData ()  #####
' #############################
'
' PURPOSE : Load resource data into a string buffer.
' Resource must be identified with type RCDATA in
' *.rc file.
' IN      : resName$ - resource name string
'         : resID - resource integer ID
' OUT     : data$ - returned resource data as string
' NOTE    : use either a resource string name or integer id, but not both!
' EXAMPLE : 100   RCDATA   "mygif.gif"
'         : agif  RCDATA   "mygif.gif"
' RETURN  : 0 on success, -1 on error
'
FUNCTION LoadResData (resName$, resID, @data$)

  data$ = ""

' search for the resource
  IF resName$ THEN 
    lpName = &resName$
  ELSE
    IF resID THEN
      lpName = resID
    ELSE
      RETURN ($$TRUE)
    END IF
  END IF

  hRes = FindResourceA (0, lpName, $$RT_RCDATA)
  IF (!hRes) THEN RETURN ($$TRUE)

' get the memory for the loaded resource
  memBlock = LoadResource (0, hRes)
  IF (!memBlock) THEN RETURN ($$TRUE)

' obtain the size for the resource
  sizeRes = SizeofResource (0, hRes)
  IF (!sizeRes) THEN RETURN ($$TRUE)

' get the memory location of the loaded resource
  pData = LockResource (memBlock)
  IF (!pData) THEN RETURN ($$TRUE)

' create a string buffer to hold data
  data$ = NULL$ (sizeRes)
  
' copy data to string buffer
  RtlMoveMemory (&data$, pData, sizeRes)
  
END FUNCTION
END PROGRAM
