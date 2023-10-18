'*************************************************************************
'* Name:        bfc.c
'* Author:      Marcus Geelnard
'* Description: Basic Compression Library file compressor.
'* $Id: bfc.c,v 1.3 2004/05/09 11:48:06 marcus256 Exp $
'*
'* BFC stands for Basic File Compressor.
'*
'* This is a simple test application for all the compression types
'* supported by the Basic Compression Library. It compresses or
'* decompresses an input file with a selected compression algorithm. In no
'* way is this program intended to be used for general purpose compression.
'* It is just a testbed for the the different algorithms supported by the
'* Basic Compression Library.
'*
'*-------------------------------------------------------------------------
'* Copyright (c) 2003-2004 Marcus Geelnard
'*
'* This software is provided 'as-is', without any express or implied
'* warranty. In no event will the authors be held liable for any damages
'* arising from the use of this software.
'*
'* Permission is granted to anyone to use this software for any purpose,
'* including commercial applications, and to alter it and redistribute it
'* freely, subject to the following restrictions:
'*
'* 1. The origin of this software must not be misrepresented; you must not
'*    claim that you wrote the original software. If you use this software
'*    in a product, an acknowledgment in the product documentation would
'*    be appreciated but is not required.
'*
'* 2. Altered source versions must be plainly marked as such, and must not
'*    be misrepresented as being the original software.
'*
'* 3. This notice may not be removed or altered from any source
'*    distribution.
'*
'* Marcus Geelnard
'* marcus.geelnard at home.se
''*************************************************************************

' Ported to XB by Michael McElligott


PROGRAM "xbfc"
VERSION "1"
CONSOLE

	IMPORT "msvcrt"
	IMPORT "kernel32"
	IMPORT "xsx"


TYPE huff_sym_t
    XLONG	.Symbol
    XLONG	.Count
    XLONG	.Code
    XLONG	.Bits
END TYPE


TYPE huff_bitstream_t
    XLONG	.BytePtr
    XLONG	.BitPos
    XLONG	.NumBytes
END TYPE


' lowered from original value of 100000 to decrease compression time.
$$LZ_MAX_OFFSET = 10000


DECLARE FUNCTION main ()
DECLARE FUNCTION GetFileSize2( f )
DECLARE FUNCTION ReadWord32( f )
DECLARE FUNCTION WriteWord32(  x, f )
DECLARE FUNCTION Help( STRING prgname )

DECLARE FUNCTION _Huffman_InitBitstream( huff_bitstream_t stream, buf,bytes)
DECLARE FUNCTION _Huffman_ReadBits( huff_bitstream_t stream, bits )
DECLARE FUNCTION _Huffman_WriteBits( huff_bitstream_t stream, x, bits )
DECLARE FUNCTION _Huffman_Hist( UBYTE in[], huff_sym_t sym[], size )
DECLARE FUNCTION _Huffman_MakeTree( huff_sym_t sym[], huff_bitstream_t stream, code, bits, first, last )
DECLARE FUNCTION _Huffman_RecoverTree( huff_sym_t sym[], huff_bitstream_t stream, code, bits, symnum)

DECLARE FUNCTION _LZ_WriteVarSize ( x, pbuf)
DECLARE FUNCTION _LZ_ReadVarSize  ( x, pbuf)

DECLARE FUNCTION _RLE_WriteRep( UBYTE out[], outpos, marker, symbol, count )
DECLARE FUNCTION _RLE_WriteNonRep( UBYTE out[], outpos,marker, symbol )


'	_compress (source,dest,..)
'	_uncompress (source,dest,..)
DECLARE FUNCTION RLE_Compress( ANY, ANY, insize )
DECLARE FUNCTION RLE_Uncompress( ANY, ANY, insize )
DECLARE FUNCTION LZ_Compress  (ANY , ANY , src_size)
DECLARE FUNCTION LZ_Uncompress(ANY , ANY, src_size)
DECLARE FUNCTION Huffman_Compress( ANY , ANY ,insize )
DECLARE FUNCTION Huffman_Uncompress( ANY , ANY ,insize, outsize )



'*************************************************************************
'* main()
'*************************************************************************

FUNCTION main()
    XLONG command, algo
    XLONG insize, outsize,t0,t1
    STRING in,out
    STRING inname, outname,argv[]


	XstGetCommandLineArguments (@argc,@argv[])
    '* Check arguments 
    IF( argc < 4 ) THEN
        Help( argv[ 0 ] )
        RETURN 0
    END IF

    '* Get command 
    command = ASC(argv[1])
    IF( (command != 'c') && (command != 'd') ) THEN
        Help( argv[ 0 ] )
        RETURN 0
    END IF

    '* Get algo 
    IF( argc == 5 && command == 'c' ) THEN
        algo = 0
        SELECT CASE argv[2]
        	CASE "rle"		:algo = 1
        	CASE "huff"		:algo = 2
        	CASE "lz"		:algo = 9
        	CASE ELSE		:Help(argv[0]): RETURN 0
        END SELECT

        inname  = argv[3]
        outname = argv[4]
    ELSE
    	IF( argc == 4 && command == 'd' ) THEN
        	inname  = argv[ 2 ]
        	outname = argv[ 3 ]
        ELSE
			Help(argv[ 0 ])
		    RETURN 0
		END IF
	END IF


    '* Open input file 
    f = fopen(&inname, &"rb" )
    IF( !f ) THEN
        PRINT "Unable to open input file " + inname+"\r\n"
        RETURN 0
    END IF

    '* Get input file size 
    insize = GetFileSize2( f )

    '* Decompress?
    IF( command == 'd' ) THEN 
    	'* Read header
    	algo = ReadWord32( f )
    	algo = ReadWord32( f )
    	outsize = ReadWord32( f )
     	insize = insize - 12
     END IF

    '* Print operation... 
    SELECT CASE ( algo )
        CASE 1	:PRINT  "RLE ";
        CASE 2	:PRINT  "Huffman ";
        CASE 9	:PRINT  "LZ77 ";
    END SELECT

    SELECT CASE ( command )
        CASE 'c'	:PRINT  "compress ";
        CASE 'd'	:PRINT "decompress ";
    END SELECT

    PRINT inname+" to "+outname+"\r\n"

    '* Read input file 
    PRINT "Input file: "+STRING(insize)+" bytes\r\n"
    in =  NULL$( insize )

    fread( &in, insize, 1, f )
    fclose( f )

    '* Show output file size for decompression 
    IF ( command == 'd' ) THEN
        PRINT "Output file: "+STRING$(outsize)+" bytes\r\n"
    END IF


    '* Open output file 
    f = fopen(&outname,&"wb" )
    IF ( !f ) THEN
        PRINT  "Unable to open output file "+outname +"\r\n"
        RETURN 0
    END IF

    '* Compress? 
    IF ( command == 'c' ) THEN
        '* Write header 
        fwrite( &"BCL1", 4, 1, f )
        WriteWord32( algo, f )
        WriteWord32( insize, f )

        '* Worst CASE buffer size 
        outsize = (insize*104.0+50.0)/100.0 + 384
    END IF

    '* Allocate memory for output buffer 
    out = NULL$( outsize )

    '* Compress or decompress 
    IF ( command == 'c' ) THEN
        t0 = GetTickCount()	' start time
        SELECT CASE  algo 
            CASE 1:
                outsize = RLE_Compress( @in, @out, insize )
            CASE 2:
                outsize = Huffman_Compress( @in, @out, insize )
            CASE 9:
                outsize = LZ_Compress( @in, @out, insize )
        END SELECT
        t1 = GetTickCount()-t0
        out = LEFT$(out,outsize)
        PRINT( "Output file: "+STRING$(outsize)+" bytes ("+STRING$(100.0*SINGLE(outsize)/SINGLE(insize)))+"%)\r\n"
        PRINT "time = ";t1;"\r\n"
    ELSE
    	t0 = GetTickCount()	' start time
        SELECT CASE( algo )
            CASE 1:
                RLE_Uncompress( @in, @out, insize )
            CASE 2:
                Huffman_Uncompress( @in, @out, insize, outsize )
            CASE 9:
                LZ_Uncompress( @in, @out, insize )
		END SELECT
		PRINT "time = ";GetTickCount()-t0;"\r\n"
	END IF


    '* Write output file 
    fwrite(&out, outsize, 1, f )
    fclose( f )

    '* Free memory 
	in = ""
	out = ""
	
    RETURN 0
END FUNCTION


FUNCTION ReadWord32( f )
	UBYTE buf[]

	
	DIM buf[3]
	fread( &buf[], 4, 1, f )
  	RETURN ((buf[0])<< 24) + ((buf[1])<< 16) + ((buf[2])<< 8) +  buf[3]
END FUNCTION


'*************************************************************************
'* WriteWord32()
'*************************************************************************

FUNCTION WriteWord32(  x, f)

	fputc( (x >> 24)& 255, f)
	fputc( (x >> 16)& 255, f)
	fputc( (x >> 8)& 255, f)
	fputc(x & 255, f )

END FUNCTION


'*************************************************************************
'* GetFileSize2()
'*************************************************************************
FUNCTION GetFileSize2( f )

    pos = ftell( f )
    fseek( f, 0, 2)
    size = ftell( f )
		fsetpos (f, &pos)
    RETURN size
END FUNCTION



'*************************************************************************
'* Help()
'*************************************************************************

FUNCTION Help( STRING prgname )

    PRINT  "Usage: "+prgname+" command [algo] infile outfile     "
    PRINT "Commands:" 
    PRINT "  c       Compress" 
    PRINT "  d       Deompress     " 
    PRINT "Algo (only specify for compression):" 
    PRINT "  rle     RLE Compression" 
    PRINT "  lz      LZ77 Compression" 
    PRINT "  huff    Huffman compression" 

	PRINT
	a$ = INLINE$("Press Enter to Quit")

END FUNCTION 

 ' ************************************************************************
' * _Huffman_InitBitstream() - Initialize a bitstream.
 ' ************************************************************************

FUNCTION _Huffman_InitBitstream( huff_bitstream_t stream, pbuf,bytes )

    stream.BytePtr  = pbuf
    stream.BitPos   = 0
    stream.NumBytes = bytes

END FUNCTION


 ' ************************************************************************
' * _Huffman_ReadBits() - Read bits from a bitstream.
 ' ************************************************************************

FUNCTION _Huffman_ReadBits( huff_bitstream_t stream, bits )
    XLONG x, bit, bytesleft, count
    XLONG buf

     '  Get current stream state 
    buf       = stream.BytePtr
    bit       = stream.BitPos
    bytesleft = stream.NumBytes

     '  Extract bits 
    x = 0
    FOR count = 0 TO bits-1
        IFZ bytesleft THEN EXIT FOR        
        IF (UBYTEAT(buf) & (1 << (7 - bit))) THEN b = 1 ELSE b = 0
        x = (x << 1) + b
        
        bit = (bit+1) & 7
        IF !bit THEN
            DEC bytesleft
            INC buf
		END IF
    NEXT count

     '  Store new stream state 
    stream.BytePtr  = buf
    stream.BitPos   = bit
    stream.NumBytes = bytesleft

    RETURN x
END FUNCTION


 ' ************************************************************************
 ' * _Huffman_WriteBits() - Write bits to a bitstream.
 ' ************************************************************************

FUNCTION _Huffman_WriteBits( huff_bitstream_t stream, x, bits )

     '  Get current stream state
    buf       = stream.BytePtr
    bit       = stream.BitPos
    bytesleft = stream.NumBytes

     '  Append bits 
    mask = 1 << (bits-1)
    FOR count = 0 TO bits-1
      IFZ bytesleft THEN EXIT FOR
    	IF (x & mask) THEN b = 1 ELSE b = 0
      UBYTEAT(buf) = (UBYTEAT(buf) & (0xff ^ (1 << (7 - bit)))) + (b << (7 - bit))
      x = x << 1
      bit = (bit+1) & 7
      IF !bit THEN
        DEC bytesleft
        INC buf
      END IF
    NEXT count

     '  Store new stream state 
    stream.BytePtr  = buf
    stream.BitPos   = bit
    stream.NumBytes = bytesleft
END FUNCTION


 ' ************************************************************************
 ' * _Huffman_Hist() - Calculate (sorted) histogram for a block of data.
 ' ************************************************************************

FUNCTION _Huffman_Hist( UBYTE in[], huff_sym_t sym[], size )
    XLONG k, swaps
    huff_sym_t tmp

     '  Clear/init histogram 
     FOR k = 0 TO 255
    'for( k = 0; k < 256; ++ k )
        sym[k].Symbol = k
        sym[k].Count  = 0
        sym[k].Code   = 0
        sym[k].Bits   = 0
    NEXT k

     '  Build histogram 
    FOR k = 0 TO size-1
       INC sym[in[k]].Count
    NEXT k

     '  Sort histogram - most frequent symbol first (bubble sort) 
    DO
        swaps = 0
        FOR k = 0 TO 254
            IF (sym[k].Count < sym[k+1].Count) THEN
                tmp      = sym[k]
                sym[k]   = sym[k+1]
                sym[k+1] = tmp
                swaps    = 1
            END IF
        NEXT k
    LOOP WHILE ( swaps )

END FUNCTION


 ' ************************************************************************
 ' * _Huffman_MakeTree() - Generate a Huffman tree.
 ' ************************************************************************

FUNCTION _Huffman_MakeTree( huff_sym_t sym[], huff_bitstream_t stream, code, bits, first, last )
	XLONG k, size, size_a, size_b, last_a, first_b

     '  Is this a leaf node? 
    IF ( first == last ) THEN
         '  Append symbol to tree description 
        _Huffman_WriteBits(@stream, 1, 1 )
        _Huffman_WriteBits(@stream,sym[first].Symbol, 8 )

         '  Store code info in symbol array 
        sym[first].Code = code
        sym[first].Bits = bits
        RETURN
    ELSE
             '  This was not a leaf node 
        _Huffman_WriteBits(@stream, 0, 1 )
    END IF

     '  Total size of interval 
    size = 0
    FOR k = first TO last
        size = size + sym[k].Count
    NEXT k

     '  Find size of branch a 
    size_a = 0
	FOR k = first TO last-1
		IF !(size_a <= (size / 2)) THEN EXIT FOR
		size_a = size_a + sym[k].Count
	NEXT k

     '  Branch a and b cut in histogram 
    last_a  = k-1
    first_b = k

     '  Non-empty branch? 
    IF( size_a > 0 ) THEN
         '  Continue branching 
        _Huffman_WriteBits(@stream, 1, 1 )

         '  Create branch a 
        _Huffman_MakeTree(@sym[],@stream, (code<<1)+0, bits+1, first, last_a )
    ELSE
         '  This was an empty branch 
        _Huffman_WriteBits(@stream, 0, 1 )
    END IF

     '  Size of branch b 
    size_b = size - size_a

     '  Non-empty branch? 
    IF( size_b > 0 ) THEN
         '  Continue branching 
        _Huffman_WriteBits( @stream, 1, 1 )

         '  Create branch b 
        _Huffman_MakeTree( @sym[],@stream, (code<<1)+1, bits+1, first_b, last )
        'PRINT UBOUND(sym[])
    ELSE
    	
         '  This was an empty branch 
        _Huffman_WriteBits( @stream, 0, 1 )
        
    END IF

END FUNCTION


 ' ************************************************************************
' * _Huffman_RecoverTree() - Recover a Huffman tree from a bitstream.
 ' ************************************************************************

FUNCTION _Huffman_RecoverTree( huff_sym_t sym[], huff_bitstream_t stream, code, bits, symnum)

     '  Is this a leaf node? 
    IF( _Huffman_ReadBits(@stream, 1 ) ) THEN
         '  Get symbol from tree description 
        symbol = _Huffman_ReadBits(@stream, 8 )

         '  Store code info in symbol array 
        sym[symnum].Symbol = symbol
        sym[symnum].Code   = code
        sym[symnum].Bits   = bits

         '  Increase symbol counter 
        symnum = symnum + 1

        RETURN
	END IF
	
     '  Non-empty branch? 
    IF ( _Huffman_ReadBits(@stream, 1 ) ) THEN
         '  Create branch a 
        _Huffman_RecoverTree(@sym[],@stream, (code<<1)+0, bits+1,@symnum)
    END IF

     '  Non-empty branch? 
    IF( _Huffman_ReadBits(@stream, 1 ) ) THEN
         '  Create branch b 
        _Huffman_RecoverTree(@sym[],@stream, (code<<1)+1, bits+1, @symnum )
    END IF
 
END FUNCTION


 ' ************************************************************************
 ' *                            PUBLIC FUNCTIONS                            *
 ' ************************************************************************


 ' ************************************************************************
'* Huffman_Compress() - Compress a block of data using a Huffman coder.
'*  in     - Input (uncompressed) buffer.
'*  out    - Output (compressed) buffer. This buffer must be 384 bytes
'*           larger than the input buffer.
'*  insize - Number of input bytes.
'* The function RETURNs the size of the compressed data.
 ' ************************************************************************

FUNCTION Huffman_Compress( UBYTE in[], UBYTE out[],insize )
    huff_sym_t sym[], tmp
    huff_bitstream_t stream
    XLONG k, bufsize, total_bytes, swaps, symbol


	DIM sym[255]
     '  Do we have anything to compress? 
    IF( insize < 1 ) THEN RETURN 0

     '  Calculate necessary buffer memory (we need max 384 bytes for storing the tree) 
    bufsize = insize + 384
    
     '  Initialize bitstream
    _Huffman_InitBitstream( @stream, &out[], bufsize )
    
     '  Calculate and sort histogram for input data
    _Huffman_Hist(@in[], @sym[], insize )
    
     '  Build Huffman tree
    _Huffman_MakeTree(@sym[],@stream, 0, 0, 0, 255 )
    
     '  Was any code > 32 bits? (we do not handle that at present)
     FOR k = 0 TO 254
        IF ( sym[k].Bits > 32 ) THEN RETURN 0
    NEXT k
    
     '  Sort histogram - first symbol first (bubble sort)
    DO
        swaps = 0
        FOR k = 0 TO 254
            IF (sym[k].Symbol > sym[k+1].Symbol ) THEN
                tmp      = sym[k]
                sym[k]   = sym[k+1]
                sym[k+1] = tmp
                swaps    = 1
            END IF
        NEXT k
    LOOP WHILE ( swaps )
    
' this following section of code is the bottleneck
' *****
     '  Encode input stream 
    FOR k = 0 TO insize-1
        symbol = in[ k ]
        _Huffman_WriteBits( @stream,sym[symbol].Code,sym[symbol].Bits )
    NEXT k
' *****
    
     '  Calculate size of output data
    total_bytes = (stream.BytePtr - &out[])
    IF ( stream.BitPos > 0 ) THEN INC total_bytes

    RETURN total_bytes
END FUNCTION


 ' ************************************************************************
'* Huffman_Uncompress() - Uncompress a block of data using a Huffman
'* decoder.
'*  in      - Input (compressed) buffer.
'*  out     - Output (uncompressed) buffer. This buffer must be large
'*            enough to hold the uncompressed data.
'*  insize  - Number of input bytes.
'*  outsize - Number of output bytes.
 ' ************************************************************************

FUNCTION Huffman_Uncompress( UBYTE in[], UBYTE out[],insize, outsize )
    huff_sym_t sym[], tmp
    huff_bitstream_t stream
    XLONG k, m, symbol_count, swaps
    UBYTE buf[]
    XLONG bits, delta_bits, new_bits, code


	DIM sym[255]
     '  Do we have anything to decompress? 
    IF ( insize < 1 ) THEN RETURN

     '  Initialize bitstream 
    _Huffman_InitBitstream( @stream, &in[], insize )

     '  Clear tree/histogram 
    FOR k = 0 TO 255
        sym[k].Bits = 0x7fffffff
    NEXT k

     '  Recover Huffman tree 
    symbol_count = 0
    _Huffman_RecoverTree( @sym[], @stream, 0, 0, @symbol_count )

     '  Sort histogram - shortest code first (bubble sort) 
    DO
        swaps = 0
        FOR k = 0 TO symbol_count-2
            IF ( sym[k].Bits > sym[k+1].Bits ) THEN
                tmp      = sym[k]
                sym[k]   = sym[k+1]
                sym[k+1] = tmp
                swaps    = 1
            END IF
        NEXT k
   LOOP WHILE( swaps )

     '  Decode input stream 
 	c = 0
   	FOR k = 0 TO outsize-1
         '  Search tree for matching code 
        bits = 0
        code = 0
        FOR m = 0 TO symbol_count -1
        'for( m = 0; m < symbol_count; ++ m )
            delta_bits = sym[m].Bits - bits
            IF( delta_bits ) THEN
                new_bits = _Huffman_ReadBits( @stream, @delta_bits )
                code = code | (new_bits << (32 - bits-delta_bits))
                bits = sym[m].Bits
            END IF
            IF( code == (sym[m].Code << (32 - sym[m].Bits)) ) THEN
                UBYTEAT(&out[c]) = sym[m].Symbol
                INC c
                EXIT FOR
           END IF
        NEXT m
    NEXT k

END FUNCTION

 ' ************************************************************************
 ' * _LZ_WriteVarSize() - Write unsigned_integer with variable number of
 ' * bytes depending on value.
 ' *************************************************************************

FUNCTION _LZ_WriteVarSize ( x, pbuf )
    XLONG  y
    XLONG num_bytes, i, b

     '  Determine number of bytes needed to store the number x 
    y = x >> 3
    FOR num_bytes = 5 TO 2 STEP -1
        IF (y & 0xfe000000) THEN EXIT FOR
        y = y << 7
    NEXT num_bytes


     '  Write all bytes, seven bits in each, with 8:th bit set for all 
     '  but the last byte. 
     FOR i = num_bytes-1 TO 0 STEP -1
        b = (x >> (i * 7)) & 0x0000007f
        IF ( i > 0 ) THEN
            b = b | 0x00000080
        END IF
        UBYTEAT (pbuf) = b
        INC pbuf
    NEXT i

     '  Return number of bytes written 
    RETURN num_bytes
END FUNCTION


 ' ************************************************************************
 ' _LZ_ReadVarSize() - Read unsigned_integer with variable number of
 ' bytes depending on value.
 ' *************************************************************************

FUNCTION _LZ_ReadVarSize( x, pbuf )
    XLONG y, b, num_bytes

     '  Read complete value (stop when byte contains zero in 8:th bit) 
    y = 0
    num_bytes = 0
    DO
        b = UBYTEAT (pbuf)
        INC pbuf
        y = (y << 7) | (b & 0x0000007f)
        INC num_bytes
    LOOP WHILE (b & 0x00000080)

     '  Store value in x 
    UBYTEAT(x) = y

     '  Return number of bytes read 
    RETURN num_bytes
END FUNCTION



 ' ************************************************************************
 '                           PUBLIC FUNCTIONS                            *
 ' *************************************************************************


 ' ************************************************************************
' LZ_Compress() - Compress a block of data using an LZ77 coder.
 ' in     - Input (uncompressed) buffer.
 ' out    - Output (compressed) buffer. This buffer must be 0.4% larger
 '          than the input buffer, plus one byte.
 ' insize - Number of input bytes.
'* The function returns the size of the compressed data.
 ' *************************************************************************

FUNCTION LZ_Compress( UBYTE in[], UBYTE out[], insize )
    UBYTE marker
    XLONG  inpos, outpos, i
    XLONG  maxoffset, offset, bestoffset
    XLONG  maxlength, length, bestlength
    XLONG  histogram[], codesize
    UBYTE dummybuf[], ptr1, ptr2


	DIM dummybuf[4]
	DIM histogram[255]

	'  Do we have anything to compress? 
	IFZ insize THEN RETURN 0

     '  Create histogram 
    FOR i = 0 TO UBOUND(histogram[])
    	histogram[i] = 0
    NEXT i

	FOR i = 0 TO insize-1
		INC histogram[in[i]]
	NEXT i

     '  Find the least common byte, and use it as the code marker 
    marker = 0
    FOR i = 1 TO 255
    	IF histogram[ i ] < histogram[ marker ] THEN marker = i
    NEXT i

     '  Remember the repetition marker for the decoder 
    out[0] = marker

     '  Start of compression 
    out[1] = in[0]
    inpos = 1
    outpos = 2

     '  Main compression loop 
    DO
         '  Determine most distant position 
        IF( inpos > $$LZ_MAX_OFFSET ) THEN
        	maxoffset = $$LZ_MAX_OFFSET
        ELSE
        	maxoffset = inpos
       	END IF

         '  Search history window for maximum length string match 
        bestlength = 0
        bestoffset = 0
        offset = 3
        FOR offset = 3 TO maxoffset
             '  Quickly determine if this is a candidate (for speed) 
            IF ( (in[ inpos - offset ] == in[ inpos ]) && (in[ inpos - offset + bestlength ] == in[ inpos + bestlength ]) ) THEN
            
                 '  Determine maximum length for this offset 
                maxlength = insize - inpos
                IF ( maxlength > offset ) THEN maxlength = offset

                 '  Count maximum length match at this offset 
                ptr1 = &in[ inpos - offset ]
                ptr2 = &in[ inpos ]
                FOR length = 0 TO maxlength
                    IF UBYTEAT(ptr1) != UBYTEAT(ptr2) THEN EXIT FOR
                    INC ptr1: INC ptr2
                NEXT length

                 '  Best possible match? 
                IF ( length > maxlength ) THEN
                    bestlength = maxlength
                    bestoffset = offset
                    EXIT FOR
                END IF

                 '  Better match than any previous match? 
                IF (length > bestlength) THEN
                    bestlength = length
                    bestoffset = offset
                END IF
            END IF
        NEXT offset

         '  Calculate size of code (marker + length + offset ) 
        codesize = 2 + _LZ_WriteVarSize( bestoffset, &dummybuf[])

         '  Was there a good enough match? 
        IF ( bestlength > codesize ) THEN
        
            out[outpos] = marker
            INC outpos
            outpos = outpos + _LZ_WriteVarSize( bestlength, &out[ outpos ] )
            outpos = outpos + _LZ_WriteVarSize( bestoffset, &out[ outpos ] )
            inpos = inpos + bestlength
        ELSE
        
             '  Output single byte (or two bytes if marker byte) 
            IF ( in[ inpos ] == marker ) THEN
                out[ outpos ] = marker
                INC outpos
                out[ outpos ] = 0
                INC outpos
                INC inpos
            ELSE
                out[ outpos ] = in[ inpos ]
                INC outpos
                INC inpos
            END IF
        END IF
    LOOP WHILE ( inpos < insize )

    RETURN outpos
END FUNCTION


 ' ************************************************************************
 ' * LZ_Uncompress() - Uncompress a block of data using an LZ77 decoder.
 ' in      - Input (compressed) buffer.
 ' out     - Output (uncompressed) buffer. This buffer must be large
 '           enough to hold the uncompressed data.
 ' insize  - Number of input bytes.
 ' *************************************************************************

FUNCTION LZ_Uncompress( UBYTE in[], UBYTE out[], insize )
    XLONG marker, symbol
    XLONG  i, inpos, outpos, length, offset

     '  Do we have anything to compress? 
    IFZ insize THEN RETURN 0


     '  Get marker symbol from input stream 
    marker = in[ 0 ]
    inpos = 1

     '  Main decompression loop 
    outpos = 0
    DO
        symbol = in[ inpos ]
        INC inpos
        IF ( symbol == marker ) THEN
             '  We had a marker byte 
            IF ( in[ inpos ] == 0 ) THEN
                 '  It was a single occurrence of the marker byte 
                out[ outpos] = marker
                INC outpos
                INC inpos
            ELSE
                 '  Extract true length and offset 
                inpos = inpos + _LZ_ReadVarSize( &length, &in[ inpos ])
                inpos = inpos + _LZ_ReadVarSize( &offset, &in[ inpos ])

                 '  Copy corresponding data from history window 
                FOR i = 0 TO length-1
                    out[ outpos ] = out[ outpos - offset ]
                    INC outpos
                NEXT i
           END IF
        ELSE
             '  No marker, plain copy 
            out[ outpos ] = symbol
            INC outpos
        END IF
    LOOP WHILE ( inpos < insize )
    
END FUNCTION


'*************************************************************************
'* _RLE_WriteRep() - Encode a repetition of 'symbol' repeated 'count'
'* times.
'************************************************************************

FUNCTION _RLE_WriteRep( UBYTE out[], outpos, marker, symbol, count )
    XLONG i, idx


    idx = outpos
    IF ( count < 4 ) THEN
        IF ( symbol == marker ) THEN
            out[ idx ] = marker: INC idx
            out[ idx ] = count-1: INC idx
            IF ( count == 3 ) THEN
                out[ idx] = marker: INC idx
            END IF
        ELSE
            FOR i = 0 TO count-1
                out[ idx ] = symbol: INC idx
            NEXT i
        END IF
    ELSE
        out[ idx ] = marker: INC idx
        DEC count
        IF ( count >= 128 ) THEN
            out[ idx ] = (count >> 8) | 0x80
            INC idx
        END IF
        out[ idx ] = count & 0xff: INC idx
        out[ idx ] = symbol: INC idx
    END IF
    outpos = idx

END FUNCTION


'*************************************************************************
'* _RLE_WriteNonRep() - Encode a non-repeating symbol, 'symbol'. 'marker'
'* is the marker symbol, and special care has to be taken for the case
'* when 'symbol' == 'marker'.
'************************************************************************

FUNCTION _RLE_WriteNonRep( UBYTE out[], outpos,marker, symbol )
    XLONG idx

    idx = outpos
    IF ( symbol == marker ) THEN
        out[ idx ] = marker: INC idx
        out[ idx ] = 0: INC idx
    ELSE
        out[ idx ] = symbol: INC idx
    END IF
    outpos = idx

END FUNCTION



'*************************************************************************
'*                            PUBLIC FUNCTIONS                            *
'************************************************************************


'*************************************************************************
'* RLE_Compress() - Compress a block of data using an RLE coder.
'*  in     - Input (uncompressed) buffer.
'*  out    - Output (compressed) buffer. This buffer must be 0.4% larger
'*           than the input buffer, plus one byte.
'*  insize - Number of input bytes.
'* The function returns the size of the compressed data.
'************************************************************************

FUNCTION RLE_Compress( UBYTE in[], UBYTE out[], insize )
	XLONG byte1, byte2, marker
    XLONG inpos, outpos, count, i, histogram[]


    '* Do we have anything to compress? 
    IF ( insize < 1 ) THEN RETURN 0

	DIM histogram[255]    
    '* Create histogram 
    'FOR i = 0 TO UBOUND(histogram[])
    '	histogram[i] = 0
    'NEXT i

	FOR i = 0 TO insize-1
		INC histogram[in[i]]
	NEXT i

     '  Find the least common byte, and use it as the code marker 
    marker = 0
    FOR i = 0 TO 255
    	IF histogram[ i ] < histogram[ marker ] THEN marker = i
    NEXT i

     '  Remember the repetition marker for the decoder 
    out[0] = marker
    outpos = 1

    '* Start of compression 
    byte1 = in[ 0 ]
    inpos = 1
    count = 1

    '* Are there at least two bytes? 
    IF ( insize >= 2 ) THEN
        byte2 = in[ inpos ]: INC inpos 
        count = 2

        '* Main compression loop 
        DO
            IF ( byte1 == byte2 ) THEN
                '* Do we meet only a sequence of identical bytes? 
                DO WHILE (inpos < insize) && (byte1 == byte2) && (count < 32768) 
                	'IF (inpos < insize) && (byte1 == byte2) && (count < 32768) THEN
                    	byte2 = in[ inpos ]: INC inpos
                    	INC count
                    'ELSE
                    '	EXIT DO
                   	'END IF
                LOOP
                IF ( byte1 == byte2 ) THEN
                    _RLE_WriteRep( @out[], @outpos, marker, byte1, count )
                    IF ( inpos < insize ) THEN
                        byte1 = in[ inpos ]: INC inpos
                        count = 1
                    ELSE
                        count = 0
                    END IF
                ELSE
                    _RLE_WriteRep( @out[], @outpos, marker, byte1, count-1 )
                    byte1 = byte2
                    count = 1
                END IF
            ELSE
                '* No, then don't handle the last byte 
                _RLE_WriteNonRep( @out[], @outpos, marker, byte1 )
                byte1 = byte2
                count = 1
            END IF

            IF ( inpos < insize ) THEN
                byte2 = in[ inpos ]: INC inpos 
                count = 2
            END IF
        LOOP WHILE( (inpos < insize) || (count >= 2) )
    END IF

    '* One byte left? 
    IF ( count == 1 ) THEN
        _RLE_WriteNonRep( @out[], @outpos, marker, byte1 )
    END IF

    RETURN outpos
END FUNCTION


'*************************************************************************
'* RLE_Uncompress() - Uncompress a block of data using an RLE decoder.
'*  in      - Input (compressed) buffer.
'*  out     - Output (uncompressed) buffer. This buffer must be large
'*            enough to hold the uncompressed data.
'*  insize  - Number of input bytes.
'************************************************************************

FUNCTION RLE_Uncompress( UBYTE in[], UBYTE out[], insize )
    XLONG marker, symbol
    XLONG i, inpos, outpos, count

    '* Do we have anything to compress? 
    IF ( insize < 1 ) THEN RETURN

    '* Get marker symbol from input stream 
    inpos = 0
    marker = in[ inpos ]: INC inpos

    '* Main decompression loop 
    outpos = 0
    DO
        symbol = in[ inpos ]: INC inpos
        IF ( symbol == marker ) THEN
            '* We had a marker byte 
            count = in[ inpos ]: INC inpos
            IF ( count < 3 ) THEN
                FOR i = 0 TO count
                    out[ outpos ] = marker: INC outpos
                NEXT i
            ELSE
                IF ( count & 0x80 ) THEN
                    count = ((count & 0x7f) << 8) + in[ inpos ]
                    INC inpos
                END IF
                symbol = in[ inpos ]: INC inpos
                FOR i = 0 TO count
                    out[ outpos ] = symbol: INC outpos
                NEXT i
            END IF
        ELSE
            '* No marker, plain copy 
            out[ outpos ] = symbol: INC outpos
        END IF
    LOOP WHILE( inpos < insize )

END FUNCTION
END PROGRAM

