'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A library of functions used to create and play wav
' format files. Functions based on VB by David M.Hitchner.
'
'-----------------------------------------------------------------------------------
' Wave File Format
'-----------------------------------------------------------------------------------
' Header is 44 bytes total followed by data bytes
'-----------------------------------------------------------------------------------
' RIFF Chunk   ( 12 bytes)
' 00 00 - 03  "RIFF"
' 04 04 - 07  Total Length to Follow  (Length of File - 8)
' 08 08 - 11  "WAVE"
'
' FORMAT Chunk ( 24 bytes )
' 0C 12 - 15  "fmt_"
' 10 16 - 19  Length of FORMAT Chunk  Always 0x10
' 14 20 - 21  Audio Format            Always 0x01
' 16 22 - 23  Channels                1 = Mono, 2 = Stereo
' 18 24 - 27  Sample Rate             In Hertz
' 1C 28 - 31  Bytes per Second        Sample Rate * Channels * Bits per Sample / 8
' 20 32 - 33  Bytes per Sample        Channels * Bits per Sample / 8
'                                       1 = 8 bit Mono
'                                       2 = 8 bit Stereo or 16 bit Mono
'                                       4 = 16 bit Stereo
' 22 34 - 35  Bits per Sample
'
' DATA Chunk
' 24 36 - 39  "data"
' 28 40 - 43  Length of Data          Samples * Channels * Bits per Sample / 8
' 2C 44 - End Data Samples
'              8 Bit = 0 to 255             unsigned bytes
'             16 Bit = -32,768 to 32,767    2's-complement signed integers
'-----------------------------------------------------------------------------------
'
'
PROGRAM	"xwav"
VERSION	"0.0001"
CONSOLE

'
	IMPORT	"xst"   ' Standard library : required by most programs
'	IMPORT  "xsx"
	IMPORT  "kernel32"
'	IMPORT  "user32"
'	IMPORT  "gdi32"
	IMPORT  "winmm"
	IMPORT	"msvcrt"
'
EXPORT
TYPE SINEWAVE
	DOUBLE .dblFrequency
	DOUBLE .dblDataSlice
	DOUBLE .dblAmplitudeL
	DOUBLE .dblAmplitudeR
END TYPE
END EXPORT

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  RunTests ()

EXPORT
DECLARE FUNCTION  Xwav_PlayFileLoop (fileName$)
DECLARE FUNCTION  Xwav_BuildHeader (UBYTE wavArray[], sampleRate, resolution, audioMode, DOUBLE volumeL, DOUBLE volumeR)
DECLARE FUNCTION  Xwav_WriteToFile (fileName$, UBYTE wavArray[])
DECLARE FUNCTION  Xwav_SineWave (UBYTE wavArray[], DOUBLE frequency)
DECLARE FUNCTION  Xwav_MultiSineWave (UBYTE wavArray[], SINEWAVE sineWaves[], DOUBLE seconds)
DECLARE FUNCTION  Xwav_Stop ()
DECLARE FUNCTION  Xwav_CreateDTMFTones (UBYTE tones[], audioMode, sampleRate, resolution, DOUBLE seconds)
DECLARE FUNCTION  Xwav_Play (UBYTE wavArray[])
DECLARE FUNCTION  Xwav_PlayDTMFTones (UBYTE tones[], nTone, mode)
DECLARE FUNCTION  Xwav_CreateAndPlayTrainHorn (sampleRate, resolution, audioMode, DOUBLE seconds)
DECLARE FUNCTION  Xwav_SetVolume (DOUBLE volumeL, DOUBLE volumeR)
DECLARE FUNCTION  Xwav_CreateAndPlayWav (DOUBLE frequency, sampleRate, resolution, audioMode, DOUBLE volumeL, DOUBLE volumeR, DOUBLE seconds)
DECLARE FUNCTION  Xwav_PlayLoop (UBYTE wavArray[])
DECLARE FUNCTION  Xwav_StopTimer (msec)
DECLARE FUNCTION  DOUBLE Xwav_CalcNoteFreq (note, octave)
DECLARE FUNCTION  Xwav_PrintNoteFreqTable ()
DECLARE FUNCTION  Xwav_IsWavFile (fileName$)
DECLARE FUNCTION  Xwav_GetWavInfo (UBYTE wavArray[], @audioMode, @sampleRate, @resolution, @bpsec, @bpsample)
DECLARE FUNCTION  Xwav_GetWavFileInfo (fileName$, @audioMode, @sampleRate, @resolution, @bpsec, @bpsample)
DECLARE FUNCTION  Xwav_PlayFile (fileName$)

' audio modes
$$MODE_MONO = 0      ' Mono
$$MODE_LR = 1        ' Stereo L+R
$$MODE_L = 2         ' Stereo L
$$MODE_R = 3         ' Stereo R

' sample rates
$$RATE_8000  = 8000
$$RATE_11025 = 11025
$$RATE_22050 = 22050
$$RATE_32000 = 32000
$$RATE_44100 = 44100
$$RATE_48000 = 48000
$$RATE_88000 = 88000
$$RATE_96000 = 96000

' bit resolution
$$BITS_8 = 8
$$BITS_16 = 16

' 16 DTMF dial tones
$$TONE_1 = 0
$$TONE_2 = 1
$$TONE_3 = 2
$$TONE_4 = 4
$$TONE_5 = 5
$$TONE_6 = 6
$$TONE_7 = 8
$$TONE_8 = 9
$$TONE_9 = 10
$$TONE_STAR = 12
$$TONE_0 = 13
$$TONE_POUND = 14
$$TONE_A = 3
$$TONE_B = 7
$$TONE_C = 11
$$TONE_D = 15

' play dial tone mode
$$DT_NORMAL = 0
$$DT_CONTINUOUS = 1
'
' notes
' note that there are no double-sharps nor
' double-flats in this enumeration

$$NOTE_Cf =-10   ' C-flat
$$NOTE_C  = -9   ' C
$$NOTE_Cs = -8   ' C-sharp
$$NOTE_Df = -8   ' D-flat
$$NOTE_D  = -7   ' D
$$NOTE_Ds = -6   ' D-sharp
$$NOTE_Ef = -6   ' E-flat
$$NOTE_E  = -5   ' E
$$NOTE_Es = -4   ' E-sharp
$$NOTE_Ff = -5   ' F-flat
$$NOTE_F  = -4   ' F
$$NOTE_Fs = -3   ' F-sharp
$$NOTE_Gf = -3   ' G-flat
$$NOTE_G  = -2   ' G
$$NOTE_Gs = -1   ' G-sharp
$$NOTE_Af = -1   ' A-flat
$$NOTE_A  =  0   ' A
$$NOTE_As =  1   ' A-sharp
$$NOTE_Bf =  1   ' B-flat
$$NOTE_B  =  2   ' B
$$NOTE_Bs =  3   ' B-sharp

END EXPORT

$$PI = 0d400921FB54442D18
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

	IF LIBRARY(0) THEN RETURN

	RunTests ()
	a$ = INLINE$("Press Enter to Quit")

END FUNCTION
'
'
' ##################################
' #####  Xwav_PlayFileLoop ()  #####
' ##################################
'
'	Continuously play a wav file from a file.
'
FUNCTION  Xwav_PlayFileLoop (fileName$)

	IFZ fileName$ THEN RETURN ($$TRUE)
	err = PlaySoundA (&fileName$, 0, $$SND_FILENAME | $$SND_APPLICATION | $$SND_ASYNC | $$SND_LOOP | $$SND_NODEFAULT)
	IFZ err THEN RETURN ($$TRUE)

END FUNCTION
'
'
' #################################
' #####  Xwav_BuildHeader ()  #####
' #################################
'
' Builds the WAV file header based on the sample rate, resolution,
' audio mode.  Also sets the volume level for other routines.
'
FUNCTION  Xwav_BuildHeader (UBYTE wavArray[], sampleRate, resolution, audioMode, DOUBLE volumeL, DOUBLE volumeR)

	SHARED DOUBLE dblVolumeL, dblVolumeR
	SHARED lngSampleRate, intBits, intAudioMode
	SHARED intAudioWidth, intSampleBytes

' Save parameters
	lngSampleRate = sampleRate
	intBits = resolution
	intAudioMode = audioMode

	dblVolumeL = volumeL
	dblVolumeR = volumeR

	DIM wavArray[43]

'-------------------------------------------------------------------------------
' Fixed Data
'-------------------------------------------------------------------------------
	wavArray[0] = 82   ' R
	wavArray[1] = 73   ' I
	wavArray[2] = 70   ' F
	wavArray[3] = 70   ' F

	wavArray[8] = 87   ' W
	wavArray[9] = 65   ' A
	wavArray[10] = 86  ' V
	wavArray[11] = 69  ' E

	wavArray[12] = 102 ' f
	wavArray[13] = 109 ' m
	wavArray[14] = 116 ' t
	wavArray[15] = 32  ' .
	wavArray[16] = 16  ' Length of Format Chunk
	wavArray[17] = 0   ' Length of Format Chunk
	wavArray[18] = 0   ' Length of Format Chunk
	wavArray[19] = 0   ' Length of Format Chunk
	wavArray[20] = 1   ' Audio Format
	wavArray[21] = 0   ' Audio Format
	wavArray[36] = 100 ' d
	wavArray[37] = 97  ' a
	wavArray[38] = 116 ' t
	wavArray[39] = 97  ' a

'-------------------------------------------------------------------------------
' Bytes 22 - 23  Channels   1 = Mono, 2 = Stereo
'-------------------------------------------------------------------------------
	SELECT CASE audioMode
		CASE $$MODE_MONO:
			wavArray[22] = 1
			wavArray[23] = 0
			intAudioWidth = 1
		CASE $$MODE_LR:
			wavArray[22] = 2
			wavArray[23] = 0
			intAudioWidth = 2
		CASE $$MODE_L:
			wavArray[22] = 2
			wavArray[23] = 0
			intAudioWidth = 2
		CASE $$MODE_R:
			wavArray[22] = 2
			wavArray[23] = 0
			intAudioWidth = 2
	END SELECT

'-------------------------------------------------------------------------------
' 24 - 27  Sample Rate             In Hertz
'-------------------------------------------------------------------------------
	wavArray[24] = sampleRate{8, 0}
	wavArray[25] = sampleRate{8, 8}
	wavArray[26] = sampleRate{8, 16}
	wavArray[27] = sampleRate{8, 24}

'-------------------------------------------------------------------------------
' Bytes 34 - 35  Bits per Sample  8 or 16
'-------------------------------------------------------------------------------
	SELECT CASE resolution
		CASE 8:
			wavArray[34] = 8
			wavArray[35] = 0
			intSampleBytes = 1
		CASE 16:
			wavArray[34] = 16
			wavArray[35] = 0
			intSampleBytes = 2
	END SELECT

'-------------------------------------------------------------------------------
' Bytes 28 - 31  Bytes per Second =  Sample Rate * Channels * Bits per Sample / 8
'-------------------------------------------------------------------------------
	bytesASec = sampleRate * intAudioWidth * intSampleBytes

	wavArray[28] = bytesASec{8, 0}
	wavArray[29] = bytesASec{8, 8}
	wavArray[30] = bytesASec{8, 16}
	wavArray[31] = bytesASec{8, 24}

'-------------------------------------------------------------------------------
' Bytes 32 - 33 Bytes per Sample =  Channels * Bits per Sample / 8
'                                       1 = 8 bit Mono
'                                       2 = 8 bit Stereo or 16 bit Mono
'                                       4 = 16 bit Stereo
'-------------------------------------------------------------------------------
	IF (audioMode = $$MODE_MONO) && (resolution = 8) THEN
		wavArray[32] = 1
		wavArray[33] = 0
	END IF

	IF ((audioMode = $$MODE_LR) || (audioMode = $$MODE_L) || (audioMode = $$MODE_R)) && (resolution = 8) THEN
		wavArray[32] = 2
		wavArray[33] = 0
	END IF

	IF (audioMode = $$MODE_MONO) && (resolution = 16) THEN
		wavArray[32] = 2
		wavArray[33] = 0
	END IF

	IF ((audioMode = $$MODE_LR) || (audioMode = $$MODE_L) || (audioMode = $$MODE_R)) && (resolution = 16) THEN
		wavArray[32] = 4
		wavArray[33] = 0
	END IF

END FUNCTION
'
'
' #################################
' #####  Xwav_WriteToFile ()  #####
' #################################
'
FUNCTION  Xwav_WriteToFile (fileName$, UBYTE wavArray[])

	UBYTE byte

	IFZ fileName$ THEN RETURN ($$TRUE)
	IFZ wavArray[] THEN RETURN ($$TRUE)

	upper = UBOUND (wavArray[])

	fn = OPEN (fileName$, $$RW)
	IF (fn < 3) THEN RETURN ($$TRUE)

	FOR i = 0 TO upper
		byte = wavArray[i]
		WRITE [fn], byte
	NEXT i

	CLOSE (fn)

END FUNCTION
'
'
' ##############################
' #####  Xwav_SineWave ()  #####
' ##############################
'
' Builds a sine wave that may be played in a continuous loop.
' Return value is size of wavArray[] on success or -1 on failure.
'
FUNCTION  Xwav_SineWave (UBYTE wavArray[], DOUBLE frequency)

	SHARED DOUBLE dblVolumeL, dblVolumeR
	SHARED lngSampleRate, intBits, intAudioMode
	SHARED intAudioWidth, intSampleBytes

	DOUBLE dblDataPt
	DOUBLE dblDataSlice
	DOUBLE dblWaveTime
	DOUBLE dblTotalTime
	DOUBLE dblSampleTime

	IFZ wavArray[] THEN RETURN ($$TRUE)
	IFZ frequency THEN RETURN ($$TRUE)

	dblFrequency = frequency

	IF dblFrequency > 1000 THEN
		intCycles = 100
	ELSE
		intCycles = 10
	END IF

	dblWaveTime = 1.0 / dblFrequency
	dblTotalTime = dblWaveTime * intCycles
	dblSampleTime = 1.0 / DOUBLE(lngSampleRate)
	dblDataSlice = (2.0 * $$PI) / (dblWaveTime / dblSampleTime)

	lngSamples = 0
	intCycleCount = 0
	blnPositive = $$TRUE

	DO
		dblDataPt = sin(lngSamples * dblDataSlice)
		IF lngSamples > 0 THEN
			IF dblDataPt < 0 THEN
				blnPositive = $$FALSE
			ELSE
' Detect Zero Crossing
				IF NOT blnPositive THEN
					intCycleCount = intCycleCount + 1
					IF intCycleCount >= intCycles THEN EXIT DO
					blnPositive = $$TRUE
				END IF
			END IF
		END IF
		lngSamples = lngSamples + 1
	LOOP

'-------------------------------------------------------------------------------
' Bytes 40 - 43  Length of Data =  Samples * Channels * Bits per Sample / 8
'-------------------------------------------------------------------------------
	lngDataSize = lngSamples * intAudioWidth * (intBits / 8)
  REDIM wavArray[43 + lngDataSize]

	wavArray[40] = lngDataSize{8, 0}
	wavArray[41] = lngDataSize{8, 8}
	wavArray[42] = lngDataSize{8, 16}
	wavArray[43] = lngDataSize{8, 24}

'-------------------------------------------------------------------------------
' Bytes 04 - 07  Total Length to Follow  (Length of File - 8)
'-------------------------------------------------------------------------------
	lngFileSize = lngDataSize + 36

	wavArray[4] = lngFileSize{8, 0}
	wavArray[5] = lngFileSize{8, 8}
	wavArray[6] = lngFileSize{8, 16}
	wavArray[7] = lngFileSize{8, 24}

'-------------------------------------------------------------------------------
' Bytes 44 - END   Data Samples
'-------------------------------------------------------------------------------

	IF intBits = 8 THEN
		lngLimit = 127
	ELSE
		lngLimit = 32767
	END IF

	FOR i = 0 TO lngSamples - 1

		IF intBits = 8 THEN
'-----------------------------------------------------------------------
' 8 Bit Data
'-----------------------------------------------------------------------
' Calculate data point.
			dblDataPt = sin(i * dblDataSlice) * lngLimit
			lngDataL = INT(dblDataPt * dblVolumeL) + lngLimit
			lngDataR = INT(dblDataPt * dblVolumeR) + lngLimit

' Place data point in wave tile.
			IF intAudioMode = $$MODE_MONO THEN
				wavArray[i + 44] = lngDataL{8, 0}
			END IF

			IF intAudioMode = $$MODE_LR THEN       			'L+R stereo
				wavArray[(2 * i) + 44] = lngDataL{8, 0}
				wavArray[(2 * i) + 45] = lngDataR{8, 0}
			END IF

			IF intAudioMode = $$MODE_L THEN       			' L only stereo
				wavArray[(2 * i) + 44] = lngDataL{8, 0}
				wavArray[(2 * i) + 45] = 0
			END IF

			IF intAudioMode = $$MODE_R THEN       			' R only stereo
				wavArray[(2 * i) + 44] = 0
				wavArray[(2 * i) + 45] = lngDataR{8, 0}
			END IF

		ELSE

'-----------------------------------------------------------------------
' 16 Bit Data
'-----------------------------------------------------------------------
' Calculate data point.
			dblDataPt = sin(i * dblDataSlice) * lngLimit
			lngDataL = INT(dblDataPt * dblVolumeL)
			lngDataR = INT(dblDataPt * dblVolumeR)

' Place data point in wave tile.
			IF intAudioMode = $$MODE_MONO THEN
				wavArray[(2 * i) + 44] = lngDataL{8, 0}
				wavArray[(2 * i) + 45] = lngDataL{8, 8}
			END IF

			IF intAudioMode = $$MODE_LR THEN
				wavArray[(4 * i) + 44] = lngDataL{8, 0}
				wavArray[(4 * i) + 45] = lngDataL{8, 8}
				wavArray[(4 * i) + 46] = lngDataR{8, 0}
				wavArray[(4 * i) + 47] = lngDataR{8, 8}
			END IF

			IF intAudioMode = $$MODE_L THEN
				wavArray[(4 * i) + 44] = lngDataL{8, 0}
				wavArray[(4 * i) + 45] = lngDataL{8, 8}
				wavArray[(4 * i) + 46] = 0
				wavArray[(4 * i) + 47] = 0
			END IF

			IF intAudioMode = $$MODE_R THEN
				wavArray[(4 * i) + 44] = 0
				wavArray[(4 * i) + 45] = 0
				wavArray[(4 * i) + 46] = lngDataR{8, 0}
				wavArray[(4 * i) + 47] = lngDataR{8, 8}
			END IF
		END IF
	NEXT

	RETURN (lngFileSize + 8)

END FUNCTION
'
'
' ###################################
' #####  Xwav_MultiSineWave ()  #####
' ###################################
'
' Builds a complex wave form from one or more sine waves.
' Return value is size of wavArray[] on success or -1 on failure.
'
FUNCTION  Xwav_MultiSineWave (UBYTE wavArray[], SINEWAVE sineWaves[], DOUBLE seconds)

	SHARED lngSampleRate, intBits, intAudioMode
	SHARED intAudioWidth, intSampleBytes
	SHARED DOUBLE dblVolumeL, dblVolumeR

	DOUBLE dblDataPtL, dblDataPtR
	DOUBLE dblWaveTime, dblSampleTime

	IFZ wavArray[] THEN RETURN ($$TRUE)
	IFZ sineWaves[] THEN RETURN ($$TRUE)
	IFZ seconds THEN RETURN ($$TRUE)

	intSineCount = UBOUND(sineWaves[])

	FOR i = 0 TO intSineCount
		dblWaveTime = 1.0 / sineWaves[i].dblFrequency
		dblSampleTime = 1.0 / DOUBLE(lngSampleRate)
		sineWaves[i].dblDataSlice = (2.0 * $$PI) / (dblWaveTime / dblSampleTime)
	NEXT

	lngSamples = XLONG(seconds / dblSampleTime)

'-------------------------------------------------------------------------------
' Bytes 40 - 43  Length of Data = Samples * Channels * Bits per Sample / 8
'-------------------------------------------------------------------------------
	lngDataSize = lngSamples * intAudioWidth * (intBits / 8)
	REDIM wavArray[43 + lngDataSize]

	wavArray[40] = lngDataSize{8, 0}
	wavArray[41] = lngDataSize{8, 8}
	wavArray[42] = lngDataSize{8, 16}
	wavArray[43] = lngDataSize{8, 24}

'-------------------------------------------------------------------------------
' Bytes 04 - 07  Total Length to Follow  (Length of File - 8)
'-------------------------------------------------------------------------------
	lngFileSize = lngDataSize + 36

	wavArray[4] = lngFileSize{8, 0}
	wavArray[5] = lngFileSize{8, 8}
	wavArray[6] = lngFileSize{8, 16}
	wavArray[7] = lngFileSize{8, 24}

'-------------------------------------------------------------------------------
' Bytes 44 - END   Data Samples
'-------------------------------------------------------------------------------

	IF intBits = 8 THEN
		lngLimit = 127
	ELSE
		lngLimit = 32767
	END IF

	FOR i = 0 TO lngSamples - 1

		IF intBits = 8 THEN
'-----------------------------------------------------------------------
' 8 Bit Data
'-----------------------------------------------------------------------
			dblDataPtL = 0
			dblDataPtR = 0
			FOR j = 0 TO intSineCount
				dblDataPtL = dblDataPtL + (sin(i * sineWaves[j].dblDataSlice) * sineWaves[j].dblAmplitudeL)
				dblDataPtR = dblDataPtR + (sin(i * sineWaves[j].dblDataSlice) * sineWaves[j].dblAmplitudeR)
			NEXT j

			lngDataL = INT(dblDataPtL * dblVolumeL * lngLimit) + lngLimit
			lngDataR = INT(dblDataPtL * dblVolumeR * lngLimit) + lngLimit

			IF intAudioMode = $$MODE_MONO THEN
				wavArray[i + 44] = lngDataL{8, 0}
			END IF

			IF intAudioMode = $$MODE_LR THEN       			'L+R stereo
				wavArray[(2 * i) + 44] = lngDataL{8, 0}
				wavArray[(2 * i) + 45] = lngDataR{8, 0}
			END IF

			IF intAudioMode = $$MODE_L THEN       			' L only stereo
				wavArray[(2 * i) + 44] = lngDataL{8, 0}
				wavArray[(2 * i) + 45] = 0
			END IF

			IF intAudioMode = $$MODE_R THEN       			' R only stereo
				wavArray[(2 * i) + 44] = 0
				wavArray[(2 * i) + 45] = lngDataR{8, 0}
			END IF

		ELSE

'-----------------------------------------------------------------------
' 16 Bit Data
'-----------------------------------------------------------------------
			dblDataPtL = 0
			dblDataPtR = 0
			FOR j = 0 TO intSineCount
				dblDataPtL = dblDataPtL + (sin(i * sineWaves[j].dblDataSlice) * sineWaves[j].dblAmplitudeL)
				dblDataPtR = dblDataPtR + (sin(i * sineWaves[j].dblDataSlice) * sineWaves[j].dblAmplitudeR)
			NEXT j

			lngDataL = INT(dblDataPtL * dblVolumeL * lngLimit)
			lngDataR = INT(dblDataPtL * dblVolumeR * lngLimit)

			IF intAudioMode = $$MODE_MONO THEN
				wavArray[(2 * i) + 44] = lngDataL{8, 0}
				wavArray[(2 * i) + 45] = lngDataL{8, 8}
			END IF

			IF intAudioMode = $$MODE_LR THEN
				wavArray[(4 * i) + 44] = lngDataL{8, 0}
				wavArray[(4 * i) + 45] = lngDataL{8, 8}
				wavArray[(4 * i) + 46] = lngDataR{8, 0}
				wavArray[(4 * i) + 47] = lngDataR{8, 8}
			END IF

			IF intAudioMode = $$MODE_L THEN
				wavArray[(4 * i) + 44] = lngDataL{8, 0}
				wavArray[(4 * i) + 45] = lngDataL{8, 8}
				wavArray[(4 * i) + 46] = 0
				wavArray[(4 * i) + 47] = 0
			END IF

			IF intAudioMode = $$MODE_R THEN
				wavArray[(4 * i) + 44] = 0
				wavArray[(4 * i) + 45] = 0
				wavArray[(4 * i) + 46] = lngDataR{8, 0}
				wavArray[(4 * i) + 47] = lngDataR{8, 8}
			END IF
		END IF
	NEXT i

	RETURN (lngFileSize + 8)

END FUNCTION
'
'
' ##########################
' #####  Xwav_Stop ()  #####
' ##########################
'
' Stop the currently playing wav.
'
FUNCTION  Xwav_Stop ()

	err = PlaySoundA (0, 0, $$SND_PURGE | $$SND_NODEFAULT)
	IFZ err THEN RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  Xwav_CreateDTMFTones ()  #####
' #####################################
'
'---------------------------------------------------
'              DTMF Tones
' Freq  1209  1336  1477  1633
'  697    1     2     3     A
'  770    4     5     6     B
'  852    7     8     9     C
'  941    *     0     #     D
'---------------------------------------------------
'
' Create DTMF dial tones.
'
FUNCTION  Xwav_CreateDTMFTones (UBYTE tones[], audioMode, sampleRate, resolution, DOUBLE seconds)

	DOUBLE freq0, freq1
	SINEWAVE udtSineWaves[]
	UBYTE ttone[]

	DIM tones[15,]			' create irregular array
	DIM udtSineWaves[1]

	intAudioMode = audioMode
	lngSampleRate = sampleRate
	intBits = resolution

	udtSineWaves[0].dblAmplitudeL = 0.25
	udtSineWaves[0].dblAmplitudeR = 0.25
	udtSineWaves[1].dblAmplitudeL = 0.25
	udtSineWaves[1].dblAmplitudeR = 0.25

	FOR i = 0 TO 15

		SELECT CASE i / 4
			CASE 0: freq0 = 697
			CASE 1: freq0 = 770
			CASE 2: freq0 = 852
			CASE 3: freq0 = 941
		END SELECT

		udtSineWaves[0].dblFrequency = freq0

		SELECT CASE i MOD 4
			CASE 0: freq1 = 1209
			CASE 1: freq1 = 1336
			CASE 2: freq1 = 1477
			CASE 3: freq1 = 1633
		END SELECT

		udtSineWaves[1].dblFrequency = freq1

		err = Xwav_BuildHeader (@ttone[], lngSampleRate, intBits, intAudioMode, 0.5, 0.5)
    err = Xwav_MultiSineWave (@ttone[], @udtSineWaves[], seconds)

		ATTACH ttone[] TO tones[i,]

	NEXT i

END FUNCTION
'
'
' ##########################
' #####  Xwav_Play ()  #####
' ##########################
'
' Plays the wav file from memory.
'
FUNCTION  Xwav_Play (UBYTE wavArray[])

	IFZ wavArray[] THEN RETURN ($$TRUE)
	err = PlaySoundA (&wavArray[], 0, $$SND_MEMORY | $$SND_APPLICATION | $$SND_SYNC | $$SND_NODEFAULT)
	IFZ err THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ###################################
' #####  Xwav_PlayDTMFTones ()  #####
' ###################################
'
' Play dial tone using tones created by Xwav_CreateDTMFTones.
' Use nTone contant and mode (normal or continuous).
'
FUNCTION  Xwav_PlayDTMFTones (UBYTE tones[], nTone, mode)

	UBYTE ttone[]

	IFZ tones[] THEN RETURN ($$TRUE)
	IF nTone > 15 THEN RETURN ($$TRUE)

	ATTACH tones[nTone,] TO ttone[]

	IFZ ttone[] THEN RETURN ($$TRUE)

	IF mode THEN
		Xwav_PlayLoop (@ttone[])
	ELSE
		Xwav_Play (@ttone[])
	END IF

	ATTACH ttone[] TO tones[nTone,]

END FUNCTION
'
'
' ############################################
' #####  Xwav_CreateAndPlayTrainHorn ()  #####
' ############################################
'
FUNCTION  Xwav_CreateAndPlayTrainHorn (sampleRate, resolution, audioMode, DOUBLE seconds)

	SINEWAVE udtSineWaves[]
	UBYTE bytSound[]

	IFZ sampleRate THEN RETURN ($$TRUE)

	Xwav_Stop()

	DIM udtSineWaves[2]

	udtSineWaves[0].dblFrequency = 255
	udtSineWaves[0].dblAmplitudeL = 0.25
	udtSineWaves[0].dblAmplitudeR = 0.25

	udtSineWaves[1].dblFrequency = 311
	udtSineWaves[1].dblAmplitudeL = 0.25
	udtSineWaves[1].dblAmplitudeR = 0.25

	udtSineWaves[2].dblFrequency = 440
	udtSineWaves[2].dblAmplitudeL = 0.25
	udtSineWaves[2].dblAmplitudeR = 0.25

	Xwav_BuildHeader (@bytSound[], sampleRate, resolution, audioMode, 0.9, 0.9)
	Xwav_MultiSineWave (@bytSound[], @udtSineWaves[], seconds)

'fileName$ = "C:/xblite/xlibs/Xwav/" + "hornwav" + STRING$(i) + ".wav"
'Xwav_WriteToFile (fileName$, @bytSound[])

	Xwav_Play (@bytSound[])

END FUNCTION
'
'
' ###############################
' #####  Xwav_SetVolume ()  #####
' ###############################
'
FUNCTION  Xwav_SetVolume (DOUBLE volumeL, DOUBLE volumeR)

	SHARED DOUBLE dblVolumeL, dblVolumeR

	dblVolumeL = volumeL
	dblVolumeR = volumeR

END FUNCTION
'
'
' ######################################
' #####  Xwav_CreateAndPlayWav ()  #####
' ######################################
'
FUNCTION  Xwav_CreateAndPlayWav (DOUBLE frequency, sampleRate, resolution, audioMode, DOUBLE volumeL, DOUBLE volumeR, DOUBLE seconds)

	UBYTE bytSound[]

	IFZ seconds THEN RETURN ($$TRUE)

	Xwav_Stop()

	err = Xwav_BuildHeader (@bytSound[], sampleRate, resolution, audioMode, volumeL, volumeR)
	IF err = $$TRUE THEN RETURN ($$TRUE)

	err = Xwav_SineWave (@bytSound[], frequency)
	IF err = $$TRUE THEN RETURN ($$TRUE)

	err = Xwav_PlayLoop (@bytSound[])
	IF err = $$TRUE THEN RETURN ($$TRUE)

	Xwav_StopTimer (1000*seconds)

END FUNCTION
'
'
' ##############################
' #####  Xwav_PlayLoop ()  #####
' ##############################
'
' Continuously play a wav file from memory.
'
FUNCTION  Xwav_PlayLoop (UBYTE wavArray[])

	err = PlaySoundA (&wavArray[], 0, $$SND_MEMORY | $$SND_APPLICATION | $$SND_ASYNC | $$SND_LOOP | $$SND_NODEFAULT)

	IFZ err THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ###############################
' #####  Xwav_StopTimer ()  #####
' ###############################
'
' Call Xwav_Stop() after msec milliseconds
'
FUNCTION  Xwav_StopTimer (msec)

	start = timeGetTime()
	DO UNTIL dif >= msec
		dif = timeGetTime() - start
	LOOP
	Xwav_Stop ()

END FUNCTION
'
'
' #########################
' #####  RunTests ()  #####
' #########################
'
FUNCTION  RunTests ()

	UBYTE tones[]
	DOUBLE seconds, frequency

	IF LIBRARY(0) THEN RETURN

' create 16 dial tones
	audioMode = $$MODE_LR
	sampleRate = $$RATE_22050
	resolution = $$BITS_16
	seconds = 0.33
	Xwav_CreateDTMFTones (@tones[], audioMode, sampleRate, resolution, seconds)

' play dial tones
	FOR i = 0 TO 15
		Xwav_PlayDTMFTones (@tones[], i, $$DT_NORMAL)
	NEXT i

' play one dial tone continuously for 5 seconds
'	Xwav_PlayDTMFTones (@tones[], $$TONE_1, $$DT_CONTINUOUS)
'	Xwav_StopTimer (5000)

' create and play train horn sound for 3 seconds
	Xwav_CreateAndPlayTrainHorn (sampleRate, resolution, audioMode, 3.0)

' create and play a continuous wav sound
	audioMode = $$MODE_LR
	sampleRate = $$RATE_22050
	resolution = $$BITS_16
	frequency = 440
	Xwav_CreateAndPlayWav (frequency, sampleRate, resolution, audioMode, 0.5, 0.5, 3.0)

' print table of note freqencies
	Xwav_PrintNoteFreqTable ()

' play high C(5)
	audioMode = $$MODE_LR
	sampleRate = $$RATE_22050
	resolution = $$BITS_8
	frequency = Xwav_CalcNoteFreq ($$NOTE_C, 5)
	Xwav_CreateAndPlayWav (frequency, sampleRate, resolution, audioMode, 0.5, 0.5, 1.0)

' play scale
	audioMode = $$MODE_LR
	sampleRate = $$RATE_22050
	resolution = $$BITS_16
	FOR i = $$NOTE_C TO $$NOTE_B
		frequency = Xwav_CalcNoteFreq (i, 5)
		Xwav_CreateAndPlayWav (frequency, sampleRate, resolution, audioMode, 0.5, 0.5, 0.5)
	NEXT i

	file$ = "c:/xblite/xlibs/xwav/alarm.wav" 
	PRINT "Xwav_IsWavFile is"; Xwav_IsWavFile (file$)

	Xwav_GetWavFileInfo (file$, @audioMode, @sampleRate, @resolution, @bpsec, @bpsample)
	PRINT "audioMode (channels) ="; audioMode
	PRINT "sampleRate           ="; sampleRate
	PRINT "resolution (8 or 16) ="; resolution
	PRINT "bits per sec         ="; bpsec
	PRINT "bits per sample      ="; bpsample
	
	Xwav_PlayFile (file$)


END FUNCTION
'
'
' ##################################
' #####  Xwav_CalcNoteFreq ()  #####
' ##################################
'
' A tempered scale, which is one resulting
' from dividing the octave in 12 steps (semitones)
' of equal size, unlike other traditional scales
' which have semitones of different sizes.
'
' Takes a note as defined by enum notes, and an
' octave as defined by ANSI; returns the freq. of
' the note in the given octave, in hertz.
' Assumes a temperate scale and a fundamental freq.
' of 440 hertz for A4, as defined by ISO.
'
' For the actual frequency of your tones, nowadays
' normally the ISO-standardized frequency of 440 hertz
' for the A above middle C is used.

' For the octave notation, it consists of a numerical
' subscript appended to a note, with the subscript 0
' identifying the theoretically lowest audible octave,
' and incrementing by 1 upwards from there, so A above
' middle C is denoted as A(4).
'
FUNCTION  DOUBLE Xwav_CalcNoteFreq (note, octave)

	DOUBLE f0, a, f

	f0 = 440.0							' A(4)
	a  = 1.05946309436			' pow(2, 1/12)

	X  = (octave-4) * 12 + note
  f  = f0 * pow(a, X)
  RETURN f

END FUNCTION
'
'
' ########################################
' #####  Xwav_PrintNoteFreqTable ()  #####
' ########################################
'
FUNCTION  Xwav_PrintNoteFreqTable ()

	DOUBLE freq
	DIM note_name$[11]

	note_name$[0] = "C"
	note_name$[1] = "C#"
	note_name$[2] = "D"
	note_name$[3] = "D#"
	note_name$[4] = "E"
	note_name$[5] = "F"
	note_name$[6] = "F#"
	note_name$[7] = "G"
	note_name$[8] = "G#"
	note_name$[9] = "A"
	note_name$[10] = "A#"
	note_name$[11] = "B"

	PRINT
	PRINT "Table of note frequencies"
	PRINT "========================="
	PRINT SPACE$(30), "Octave number"
	PRINT "Note";
	FOR oct = 0 TO 8
		PRINT FORMAT$("|||||||||", STRING$(oct));
	NEXT oct
	PRINT
	FOR j = $$NOTE_C TO $$NOTE_B
		PRINT FORMAT$(">>>", note_name$[j+9]);
		FOR oct = 0 TO 8
			freq = Xwav_CalcNoteFreq (j, oct)
      PRINT FORMAT$("#####.## ", freq);
		NEXT oct
		PRINT
	NEXT j
END FUNCTION
'
'
' ###############################
' #####  Xwav_IsWavFile ()  #####
' ###############################
'
' Return 0 if file is a valid wav format file,
' -1 on failure.
'
FUNCTION  Xwav_IsWavFile (fileName$)

	UBYTE data[]
	UBYTE temp

	IFZ fileName$ THEN RETURN ($$TRUE)
	fn = OPEN (fileName$, $$RD)
	IF fn < 3 THEN RETURN ($$TRUE)
	len = LOF(fn)
	IF len < 44 THEN			' not enough data for 44 byte header
		CLOSE (fn)
		RETURN ($$TRUE)
	END IF

' get RIFF 12 byte chunk
	DIM data[11]
	FOR i = 0 TO 11
		READ [fn], temp
		data[i] = temp
	NEXT i

	CLOSE (fn)

' check for RIFF and WAVE
	err = data[0] <> 'R'
	err = data[1] <> 'I'
	err = data[2] <> 'F'
	err = data[3] <> 'F'

	err = data[8] <> 'W'
	err = data[9] <> 'A'
	err = data[10] <> 'V'
	err = data[11] <> 'E'

	IF err THEN RETURN ($$TRUE)

' check size of file
	fileSize = data[4]
	fileSize = fileSize + (data[5] << 8)
	fileSize = fileSize + (data[6] << 16)
	fileSize = fileSize + (data[7] << 24)

	fileSize = fileSize + 8
	IF fileSize <> len THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ################################
' #####  Xwav_GetWavInfo ()  #####
' ################################
'
FUNCTION  Xwav_GetWavInfo (UBYTE wavArray[], @audioMode, @sampleRate, @resolution, @bpsec, @bpsample)

	IF UBOUND(wavArray[]) < 43 THEN RETURN ($$TRUE)

' audioMode: Bytes 22 - 23  Channels 1 = Mono, 2 = Stereo
	audioMode = wavArray[22]

' sampleRate: 24 - 27  Sample Rate in Hertz
	sampleRate = wavArray[24]
	sampleRate = sampleRate + (wavArray[25] << 8)
	sampleRate = sampleRate + (wavArray[26] << 16)
	sampleRate = sampleRate + (wavArray[27] << 24)

' resolution:  Bytes 34 - 35  Bits per Sample  8 or 16 bits
	resolution = wavArray[34]

' bpsec: Bytes 28 - 31  Bytes per Second =  Sample Rate * Channels * Bits per Sample / 8
	bpsec = wavArray[28]
	bpsec = sampleRate + (wavArray[29] << 8)
	bpsec = sampleRate + (wavArray[30] << 16)
	bpsec = sampleRate + (wavArray[31] << 24)

' bpsample: Bytes 32 - 33 Bytes per Sample =  Channels * Bits per Sample / 8
'                                       1 = 8 bit Mono
'                                       2 = 8 bit Stereo or 16 bit Mono
'                                       4 = 16 bit Stereo
	bpsample = wavArray[32]

END FUNCTION
'
'
' ####################################
' #####  Xwav_GetWavFileInfo ()  #####
' ####################################
'
FUNCTION  Xwav_GetWavFileInfo (fileName$, @audioMode, @sampleRate, @resolution, @bpsec, @bpsample)

	UBYTE data[]
	UBYTE temp

	IFZ fileName$ THEN RETURN ($$TRUE)
	fn = OPEN (fileName$, $$RD)
	IF fn < 3 THEN RETURN ($$TRUE)
	len = LOF(fn)
	IF len < 44 THEN			' not enough data for 44 byte header
		CLOSE (fn)
		RETURN ($$TRUE)
	END IF

' get 44 byte header
	DIM data[43]
	FOR i = 0 TO 43
		READ [fn], temp
		data[i] = temp
	NEXT i

	CLOSE (fn)

	Xwav_GetWavInfo (@data[], @audioMode, @sampleRate, @resolution, @bpsec, @bpsample)

END FUNCTION
'
'
' #############################
' ##### Xwav_PlayFile ()  #####
' #############################
'
FUNCTION  Xwav_PlayFile (fileName$)

	IFZ fileName$ THEN RETURN ($$TRUE)
	err = PlaySoundA (&fileName$, 0, $$SND_FILENAME | $$SND_APPLICATION | $$SND_ASYNC | $$SND_NODEFAULT)
	IFZ err THEN RETURN ($$TRUE)

END FUNCTION
END PROGRAM
