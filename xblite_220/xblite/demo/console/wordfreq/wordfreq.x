' ####################
' #####  PROLOG  #####
' ####################
'
' Word frequency count utility, based on Pelles C example.
'
PROGRAM "wordfreq"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst_s.lib"				' Standard library : required by most programs
	IMPORT  "xsx_s.lib"				' Extended standard library
'	IMPORT  "xio_s.lib"				' Console input/ouput library
	IMPORT  "msvcrt"					' msvcrt.dll

TYPE TNODE
  XLONG .word       	' points to the text 
  XLONG .count        ' number of occurrences 
  XLONG .left 				' points to left tnode child 
	XLONG .right  			' points to right tnode child 
END TYPE

$$MAXWORD = 128
$$LETTER = 'a'
$$DIGIT = '0'

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION GetWord (fd, @w$, lim)
DECLARE FUNCTION StrSave (s)
DECLARE FUNCTION Tree (p, w)
DECLARE FUNCTION TreePrint (p)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	STRING word

	XstGetCommandLineArguments (@argc, @argv$[])
	IF argc != 2 THEN 
		PRINT "usage: wordfreq <textfile>"
		GOTO end
	END IF
	
	fd = fopen (&argv$[1], &"r")
	PRINT "wordfreq: opening "; argv$[1]
	
	IF fd == NULL THEN
    PRINT "wordfreq: can't open "; argv$[1]
		GOTO end
	END IF

	root = 0
	
	t = GetWord (fd, @word, $$MAXWORD)
	
	DO WHILE (t != $$EOF)
		IF (t == $$LETTER) THEN 
			root = Tree (root, &word)
		END IF 
		t = GetWord (fd, @word, $$MAXWORD)
	LOOP 

	fclose (fd)

	TreePrint (root)

end:	
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION


' get next word from input 
FUNCTION GetWord (fd, @w$, lim)

	w$ = NULL$(lim)

	DO
		c = fgetc (fd)
	LOOP UNTIL !isspace (c)
	
	IF c = $$EOF THEN 
		w$ = ""
		RETURN c
	END IF

	w${0} = c

	FOR i = 1 TO lim-1
		c = fgetc (fd)
		IF isspace (c) THEN EXIT FOR
		w${i} = c
	NEXT i
	RETURN $$LETTER

END FUNCTION

' allocate and save string s
FUNCTION StrSave (s)
	p = malloc (strlen(s)+1)
	IF p != NULL THEN
    strcpy (p, s)
	END IF
	RETURN p

END FUNCTION

' install word w at or below node p 
FUNCTION Tree (p, w)

	TNODE t

	IF (p == NULL) THEN 							' a new word has arrived 

		p = malloc (SIZE(t))  					' make a new node 
		t.word = StrSave (w)
		t.count = 1
		t.left = NULL
		t.right = NULL
		
	ELSE
		XstCopyMemory (p, &t, SIZE(t))
		cond = strcmp (w, t.word)
		IF (cond == 0) THEN
			INC t.count  									' repeated word
		ELSE 
			IF (cond < 0) THEN   					' lower goes into left subtree
				t.left = Tree (t.left, w)
			ELSE   												' greater into right subtree
        t.right = Tree (t.right, w)
			END IF 
		END IF 
	END IF 
	
	XstCopyMemory (&t, p, SIZE(t))
	RETURN p

END FUNCTION


' print tree p recursively
FUNCTION TreePrint (p)

	TNODE t

	IF (p != NULL) THEN
		XstCopyMemory (p, &t, SIZE(t))
		TreePrint (t.left)
		PRINT t.count, TAB(8), CSTRING$(t.word)
		TreePrint (t.right)
	END IF 

END FUNCTION

END PROGRAM