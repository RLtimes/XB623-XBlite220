'
' ####################
' #####  PROLOG  #####
' ####################
'
' A Sound() function which plays a MIDI note
' using winmm.dll functions and output to
' the default MIDI device (sound card).
' Based on BOINKIII.BAS written by
' Robert Wishlaw for BCX.
'
PROGRAM "midisound"
VERSION "0.0001"
CONSOLE
'
	IMPORT	"winmm"
	IMPORT  "kernel32"
'
DECLARE  FUNCTION  Entry ()
DECLARE FUNCTION  Sound (note, duration, volume, instrument, @error$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	GOSUB Initialize

	PRINT "Enter a number to play a MIDI note."
	PRINT "Enter 'a' to play all 128 MIDI instruments"
	PRINT "Enter 's' to play a scale of 12 notes"
	PRINT "Or enter 'q' to quit program."
	PRINT

	DO
		a$ = INLINE$ ("Enter a number (0-127), a for ALL, s for SCALE, or q to QUIT > ")
		a$ = TRIM$ (LCASE$ (a$))

		SELECT CASE TRUE

			CASE a$ = "q" 	: EXIT DO
			CASE a$ = ""		: EXIT DO

			CASE a$ = "s" 	:
				FOR i = 60 TO 72
					Sound (i, 1000, 127, 42, @error$)			' play scale of 12 notes on Cello
				NEXT i

			CASE a$ = "a" 	:
				FOR i = 0 TO 127
					PRINT "Instrument : "; instrument$[i]
					Sound (60, 1000, 127, i, @error$)			' play middle C - note 60
				NEXT i

			CASE ELSE							:
				instrument = XLONG (a$)
				IF instrument > 127 THEN EXIT SELECT
				PRINT "Instrument : "; instrument$[instrument]
				PRINT
				Sound (60, 1000, 127, instrument, @error$)
		END SELECT
		Sleep (0)
	LOOP


' ***** Initialize *****
SUB Initialize
	DIM instrument$[127]

	instrument$[0] =  "Acoustic Grand"
	instrument$[1] =  "Bright Acoustic"
	instrument$[2] =  "Electric Grand"
	instrument$[3] =  "Honky-Tonk"
	instrument$[4] =  "Electric Piano 1"
	instrument$[5] =  "Electric Piano 2"
	instrument$[6] =  "Harpsichord"
	instrument$[7] =  "Clavinet"
	instrument$[8] =  "Celesta"
	instrument$[9] =  "Glockenspiel"
	instrument$[10] =  "Music Box"
	instrument$[11] =  "Vibraphone"
	instrument$[12] =  "Marimba"
	instrument$[13] =  "Xylophone"
	instrument$[14] =  "Tubular Bells"
	instrument$[15] =  "Dulcimer"
	instrument$[16] =  "Drawbar Organ"
	instrument$[17] =  "Percussive Organ"
	instrument$[18] =  "Rock Organ"
	instrument$[19] =  "Church Organ"
	instrument$[20] =  "Reed Organ"
	instrument$[21] =  "Accoridan"
	instrument$[22] =  "Harmonica"
	instrument$[23] =  "Tango Accordian"
	instrument$[24] =  "Acoustic Guitar(nylon)"
	instrument$[25] =  "Acoustic Guitar(steel)"
	instrument$[26] =  "Electric Guitar(jazz)"
	instrument$[27] =  "Electric Guitar(clean)"
	instrument$[28] =  "Electric Guitar(muted)"
	instrument$[29] =  "Overdriven Guitar"
	instrument$[30] =  "Distortion Guitar"
	instrument$[31] =  "Guitar Harmonics"
	instrument$[32] =  "Acoustic Bass"
	instrument$[33] =  "Electric Bass(finger)"
	instrument$[34] =  "Electric Bass(pick)"
	instrument$[35] =  "Fretless Bass"
	instrument$[36] =  "Slap Bass 1"
	instrument$[37] =  "Slap Bass 2"
	instrument$[38] =  "Synth Bass 1"
	instrument$[39] =  "Synth Bass 2"
	instrument$[40] =  "Violin"
	instrument$[41] =  "Viola"
	instrument$[42] =  "Cello"
	instrument$[43] =  "Contrabass"
	instrument$[44] =  "Tremolo Strings"
	instrument$[45] =  "Pizzicato Strings"
	instrument$[46] =  "Orchestral Strings"
	instrument$[47] =  "Timpani"
	instrument$[48] =  "String Ensemble 1"
	instrument$[49] =  "String Ensemble 2"
	instrument$[50] =  "SynthStrings 1"
	instrument$[51] =  "SynthStrings 2"
	instrument$[52] =  "Choir Aahs"
	instrument$[53] =  "Voice Oohs"
	instrument$[54] =  "Synth Voice"
	instrument$[55] =  "Orchestra Hit"
	instrument$[56] =  "Trumpet"
	instrument$[57] =  "Trombone"
	instrument$[58] =  "Tuba"
	instrument$[59] =  "Muted Trumpet"
	instrument$[60] =  "French Horn"
	instrument$[61] =  "Brass Section"
	instrument$[62] =  "SynthBrass 1"
	instrument$[63] =  "SynthBrass 2"
	instrument$[64] =  "Soprano Sax"
	instrument$[65] =  "Sax"
	instrument$[66] =  "Tenor Sax"
	instrument$[67] =  "Baritone Sax"
	instrument$[68] =  "Oboe"
	instrument$[69] =  "English Horn"
	instrument$[70] =  "Bassoon"
	instrument$[71] =  "Clarinet"
	instrument$[72] =  "Piccolo"
	instrument$[73] =  "Flute"
	instrument$[74] =  "Recorder"
	instrument$[75] =  "Pan Flute"
	instrument$[76] =  "Blown Bottle"
	instrument$[77] =  "Skakuhachi"
	instrument$[78] =  "Whistle"
	instrument$[79] =  "Ocarina"
	instrument$[80] =  "Lead 1 (square)"
	instrument$[81] =  "Lead 2 (sawtooth)"
	instrument$[82] =  "Lead 3 (calliope)"
	instrument$[83] =  "Lead 4 (chiff)"
	instrument$[84] =  "Lead 5 (charang)"
	instrument$[85] =  "Lead 6 (voice)"
	instrument$[86] =  "Lead 7 (fifths)"
	instrument$[87] =  "Lead 8 (bass+lead)"
	instrument$[88] =  "Pad 1 (new age)"
	instrument$[89] =  "Pad 2 (warm)"
	instrument$[90] =  "Pad 3 (polysynth)"
	instrument$[91] =  "Pad 4 (choir)"
	instrument$[92] =  "Pad 5 (bowed)"
	instrument$[93] =  "Pad 6 (metallic)"
	instrument$[94] =  "Pad 7 (halo)"
	instrument$[95] =  "Pad 8 (sweep)"
	instrument$[96] =  "FX 1 (rain)"
	instrument$[97] =  "FX 2 (soundtrack)"
	instrument$[98] =  "FX 3 (crystal)"
	instrument$[99] =  "FX 4 (atmosphere)"
	instrument$[100] =  "FX 5 (brightness)"
	instrument$[101] =  "FX 6 (goblins)"
	instrument$[102] =  "FX 7 (echoes)"
	instrument$[103] =  "FX 8 (sci-fi)"
	instrument$[104] =  "Sitar"
	instrument$[105] =  "Banjo"
	instrument$[106] =  "Shamisen"
	instrument$[107] =  "Koto"
	instrument$[108] =  "Kalimba"
	instrument$[109] =  "Bagpipe"
	instrument$[110] =  "Fiddle"
	instrument$[111] =  "Shanai"
	instrument$[112] =  "Tinkle Bell"
	instrument$[113] =  "Agogo"
	instrument$[114] =  "Steel Drums"
	instrument$[115] =  "Woodblock"
	instrument$[116] =  "Taiko Drum"
	instrument$[117] =  "Melodic Tom"
	instrument$[118] =  "Synth Drum"
	instrument$[119] =  "Reverse Cymbal"
	instrument$[120] =  "Guitar Fret Noise"
	instrument$[121] =  "Breath Noise"
	instrument$[122] =  "Seashore"
	instrument$[123] =  "Bird Tweet"
	instrument$[124] =  "Telephone Ring"
	instrument$[125] =  "Helicopter"
	instrument$[126] =  "Applause"
	instrument$[127] =  "Gunshot"
END SUB


END FUNCTION
'
'
' ######################
' #####  Sound ()  #####
' ######################
'
' PURPOSE : Play a midi note.
' IN			: note 				- 0-127, middle c is 60
'					: duration 		- length of note in msec
'					: volume 			- 0-127
'					: instrument 	- 0-127
' OUT			: error$ 			- error string
' RETURN	: 0 on success, -1 on failure
'
FUNCTION  Sound (note, duration, volume, instrument, @error$)

' Middle C = note 60 = 261.625hz
' Twelve numbers, twelve notes, one octave.

' key60# = 261.625	' middle C
' key61# = 277.182
' key62# = 293.664
' key63# = 311.126
' key64# = 329.627
' key65# = 349.228
' key66# = 369.994
' key67# = 391.995
' key68# = 415.304
' key69# = 440.000
' key70# = 466.163
' key71# = 493.883

' note = ULONG((log(frequency) - log(440.0)) / log(2.0) * 12 + 69)

	error$ = ""

	IF note > 127 THEN
		error$ = "Invalid parameter : note > 127."
		RETURN ($$TRUE)
	END IF

	IFZ duration THEN
		error$ = "Invalid parameter : duration = 0."
		RETURN ($$TRUE)
	END IF

	IF instrument > 127 THEN
		error$ = "Invalid parameter : instrument > 127."
		RETURN ($$TRUE)
	END IF

	ret  = midiStreamOpen (&hMIDI, &err, 1, 0, 0, $$CALLBACK_NULL)

	SELECT CASE ret
		CASE $$MMSYSERR_BADDEVICEID:
			error$ = "The specified device identifier is out of range."
			RETURN ($$TRUE)

		CASE $$MMSYSERR_INVALPARAM:
			error$ = "The given handle or flags parameter is invalid."
			RETURN ($$TRUE)

		CASE $$MMSYSERR_NOMEM:
			error$ = "The system is unable to allocate or lock memory."
			RETURN ($$TRUE)

		CASE $$MMSYSERR_NOERROR:
			ret 			= midiOutShortMsg (hMIDI, (instrument << 8) + 0xC0)						' program change
'			note 			= ULONG((log(frequency) - log(440.0)) / log(2.0) * 12 + 69)		' midi note (0-127)
			phrase 		= ((volume << 8 + note) << 8) + 0x90													' note on
			ret 			= midiOutShortMsg (hMIDI, phrase)
			Sleep (duration)
			phrase 		= ((volume << 8 + note) << 8) + 0x80													' note off
			ret 			= midiOutShortMsg (hMIDI, phrase)
			midiStreamClose (hMIDI)
		CASE ELSE:
			RETURN ($$TRUE)
END SELECT

END FUNCTION
END PROGRAM
