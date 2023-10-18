'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"amakemap"
VERSION	"0.0000"
'
IMPORT	"xst"
'
' This file creates a character map array that maps the
' "8514oem" font to the normal character order to the
' degree possible.  To change the character mapping of
' a grid, dimension an XLONG map[] array with an upper
' bound of 255, READ the file this program creates into
' the array, call XgrSetCharacterMapArray (grid, @map[])
' to install the array.
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()
'
' create and save a character map array for 8514eom font
'
	DIM char[255]
	FOR i = 0 TO 255
		char[i] = i
	NEXT i
'
	char[0xA0] = 0xA0		' no map
	char[0xA1] = 0xAD
	char[0xA2] = 0x9B
	char[0xA3] = 0x9C
	char[0xA4] = 0xA4		' no map
	char[0xA5] = 0x9D
	char[0xA6] = 0xA6		' no map
	char[0xA7] = 0xA7		' no map
	char[0xA8] = 0xA8		' no map
	char[0xA9] = 0xA9		' no map
	char[0xAA] = 0xA6
	char[0xAB] = 0xAE
	char[0xAC] = 0xAA
	char[0xAD] = 0xAD		' no map
	char[0xAE] = 0xAE		' no map
	char[0xAF] = 0xAF		' no map
'
	char[0xB0] = 0xF8
	char[0xB1] = 0xB1		' no map
	char[0xB2] = 0xFD
	char[0xB3] = 0xB3		' no map
	char[0xB4] = 0xB4		' no map
	char[0xB5] = 0xE6
	char[0xB6] = 0xB6		' no map
	char[0xB7] = 0xF9
	char[0xB8] = 0xB8		' no map
	char[0xB9] = 0xB9		' no map
	char[0xBA] = 0xA7
	char[0xBB] = 0xAF
	char[0xBC] = 0xAC
	char[0xBD] = 0xAB
	char[0xBE] = 0xBE		' no map
	char[0xBF] = 0xA8
'
	char[0xC0] = 0xC0		' no map
	char[0xC1] = 0xC1		' no map
	char[0xC2] = 0xC2		' no map
	char[0xC3] = 0xC3		' no map
	char[0xC4] = 0x8E
	char[0xC5] = 0x8F
	char[0xC6] = 0x92
	char[0xC7] = 0x80
	char[0xC8] = 0xC8		' no map
	char[0xC9] = 0x90
	char[0xCA] = 0xCA		' no map
	char[0xCB] = 0xCB		' no map
	char[0xCC] = 0xCC		' no map
	char[0xCD] = 0xCD		' no map
	char[0xCE] = 0xCE		' no map
	char[0xCF] = 0xCF		' no map
'
	char[0xD0] = 0xD0		' no map
	char[0xD1] = 0xA5
	char[0xD2] = 0xD2		' no map
	char[0xD3] = 0xD3		' no map
	char[0xD4] = 0xD4		' no map
	char[0xD5] = 0xD5		' no map
	char[0xD6] = 0x99
	char[0xD7] = 0xD7		' no map
	char[0xD8] = 0xD8		' no map
	char[0xD9] = 0xD9		' no map
	char[0xDA] = 0xDA		' no map
	char[0xDB] = 0xDB		' no map
	char[0xDC] = 0x9A
	char[0xDD] = 0xDD		' no map
	char[0xDE] = 0xDE		' no map
	char[0xDF] = 0xE1
'
	char[0xE0] = 0x85
	char[0xE1] = 0xA0
	char[0xE2] = 0x83
	char[0xE3] = 0xE3		' no map
	char[0xE4] = 0x84
	char[0xE5] = 0x86
	char[0xE6] = 0x91
	char[0xE7] = 0x87
	char[0xE8] = 0x8A
	char[0xE9] = 0x82
	char[0xEA] = 0x88
	char[0xEB] = 0x89
	char[0xEC] = 0x8D
	char[0xED] = 0xA1
	char[0xEE] = 0x8C
	char[0xEF] = 0x8B
'
	char[0xF0] = 0xF0		' no map
	char[0xF1] = 0xA4
	char[0xF2] = 0x95
	char[0xF3] = 0xA2
	char[0xF4] = 0x93
	char[0xF5] = 0xF5		' no map
	char[0xF6] = 0x94
	char[0xF7] = 0xF7		' no map
	char[0xF8] = 0xF8		' no map
	char[0xF9] = 0x97
	char[0xFA] = 0xA3
	char[0xFB] = 0x96
	char[0xFC] = 0x81
	char[0xFD] = 0xFD		' no map
	char[0xFE] = 0xFE		' no map
	char[0xFF] = 0xFF		' no map
'
	file$ = "$XBDIR" + $$PathSlash$ + "xxx" + $$PathSlash$ + "f8514oem.map"
	ofile = OPEN (file$, $$WRNEW)
	IF (ofile > 2) THEN
		WRITE [ofile], char[]
		CLOSE (ofile)
	END IF
END FUNCTION
END PROGRAM
