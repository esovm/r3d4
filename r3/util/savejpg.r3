| JPGEncoder
| 2017 PHREDA
| from http://www.bytearray.org/?p=90
|---------------------------------
^r3/lib/math.r3

^r3/lib/gui.r3
^r3/util/loadjpg.r3

#sf		| calidad
#wi		| ancho
#hi		| alto

:,32 dup 24 >> ,c dup 16 >> ,c
:,16 dup 8 >> ,c ,c ;

#ZigZag
 0  1  5  6 14 15 27 28
 2  4  7 13 16 26 29 42
 3  8 12 17 25 30 41 43
 9 11 18 24 31 40 44 53
10 19 23 32 39 45 52 54
20 22 33 38 46 51 55 60
21 34 37 47 50 56 59 61
35 36 48 49 57 58 62 63

#aasf
1.0 1.3870 1.3066 1.1759 1.0 0.7857 0.5412 0.2759

#YQT
16  11  10  16  24  40  51  61
12  12  14  19  26  58  60  55
14  13  16  24  40  57  69  56
14  17  22  29  51  87  80  62
18  22  37  56  68 109 103  77
24  35  55  64  81 104 113  92
49  64  78  87 103 121 120 101
72  92  95  98 112 100 103  99

#UVQT
17  18  24  47  99  99  99  99
18  21  26  66  99  99  99  99
24  26  56  99  99  99  99  99
47  66  99  99  99  99  99  99
99  99  99  99  99  99  99  99
99  99  99  99  99  99  99  99
99  99  99  99  99  99  99  99
99  99  99  99  99  99  99  99

#YTable * 256
#UVTable * 256
#outputfDCTQuant * 256
#fdtbl_Y * 256
#fdtbl_UV * 256

:]YQT 2 << 'YQT + @ ;
:]UVQT 2 << 'UVQT + @ ;
:]ZigZag 2 << 'ZigZag + @ 2 << ;
:zzYTable! ]ZigZag 'YTable + ! ;
:]zzYTable ]ZigZag 'YTable + @ ;
:zzUVTable! ]ZigZag 'UVTable + ! ;
:]zzUVTable ]ZigZag 'UVTable + @ ;

:]aasf
	2 << 'aasf + @ ;

:aasf* | nro val
	over $7 and ]aasf pick2 3 >> ]aasf *. 3 << * 1.0 swap /. ;

:fdtbl_Y!
	2 << 'fdtbl_Y + ! ;
:fdtbl_UV!
	2 << 'fdtbl_UV + ! ;

:initQuantTables
	0 ( 64 <?
		dup ]YQT sf * 50 + 16 << 0.01 *. 16 >>
		1 clampmin 255 clampmax over zzYTable!
		1 + ) drop
	0 ( 64 <?
    	dup ]UVQT sf * 50 + 16 << 0.01 *. 16 >>
		1 clampmin 255 clampmax over zzUVTable!
		1 + ) drop
	0 ( 64 <?
		dup ]zzYTable aasf* over fdtbl_Y!
		dup ]zzUVTable aasf* over fdtbl_UV!
		1 + ) drop ;

#YDC_HT * 1024
#UVDC_HT * 1024
#YAC_HT * 1024
#UVAC_HT * 1024

:computeHuffmanTbl | 'nrocodes 'std_table HT --
	>r
	0 0					| codevalue posintable
	1 ( 16 <=? 		| codevalue posintable k
		pick4 over 2 << + @	| codevalue posintable k j
		( 1?  1 -
			pick4 pick3 2 << + @	| codevalue posintable k j std
			pick4 pick3 16 << or	| codevalue posintable k j std cvK
			swap 2 << r@ + ! | HT	| codevalue posintable k j
			>r rot 1 + rot 1 + rot r> ) drop
		rot 1 << rot rot 1 + )
	nip 4drop r> drop ;

#std_dc_lumi_nrcodes 0 0 1 5 1 1 1 1 1 1 0 0 0 0 0 0 0
#std_dc_lumi_values 0 1 2 3 4 5 6 7 8 9 10 11
#std_ac_lumi_nrcodes 0 0 2 1 3 3 2 4 3 5 5 4 4 0 0 1 $7d
#std_ac_lumi_values
$01 $02 $03 $00 $04 $11 $05 $12 $21 $31 $41 $06 $13 $51 $61 $07
$22 $71 $14 $32 $81 $91 $a1 $08 $23 $42 $b1 $c1 $15 $52 $d1 $f0
$24 $33 $62 $72 $82 $09 $0a $16 $17 $18 $19 $1a $25 $26 $27 $28
$29 $2a $34 $35 $36 $37 $38 $39 $3a $43 $44 $45 $46 $47 $48 $49
$4a $53 $54 $55 $56 $57 $58 $59 $5a $63 $64 $65 $66 $67 $68 $69
$6a $73 $74 $75 $76 $77 $78 $79 $7a $83 $84 $85 $86 $87 $88 $89
$8a $92 $93 $94 $95 $96 $97 $98 $99 $9a $a2 $a3 $a4 $a5 $a6 $a7
$a8 $a9 $aa $b2 $b3 $b4 $b5 $b6 $b7 $b8 $b9 $ba $c2 $c3 $c4 $c5
$c6 $c7 $c8 $c9 $ca $d2 $d3 $d4 $d5 $d6 $d7 $d8 $d9 $da $e1 $e2
$e3 $e4 $e5 $e6 $e7 $e8 $e9 $ea $f1 $f2 $f3 $f4 $f5 $f6 $f7 $f8
$f9 $fa

#std_dc_chro_nrcodes 0 0 3 1 1 1 1 1 1 1 1 1 0 0 0 0 0
#std_dc_chro_values 0 1 2 3 4 5 6 7 8 9 10 11
#std_ac_chro_nrcodes 0 0 2 1 2 4 4 3 4 7 5 4 4 0 1 2 $77
#std_ac_chro_values
$00 $01 $02 $03 $11 $04 $05 $21 $31 $06 $12 $41 $51 $07 $61 $71
$13 $22 $32 $81 $08 $14 $42 $91 $a1 $b1 $c1 $09 $23 $33 $52 $f0
$15 $62 $72 $d1 $0a $16 $24 $34 $e1 $25 $f1 $17 $18 $19 $1a $26
$27 $28 $29 $2a $35 $36 $37 $38 $39 $3a $43 $44 $45 $46 $47 $48
$49 $4a $53 $54 $55 $56 $57 $58 $59 $5a $63 $64 $65 $66 $67 $68
$69 $6a $73 $74 $75 $76 $77 $78 $79 $7a $82 $83 $84 $85 $86 $87
$88 $89 $8a $92 $93 $94 $95 $96 $97 $98 $99 $9a $a2 $a3 $a4 $a5
$a6 $a7 $a8 $a9 $aa $b2 $b3 $b4 $b5 $b6 $b7 $b8 $b9 $ba $c2 $c3
$c4 $c5 $c6 $c7 $c8 $c9 $ca $d2 $d3 $d4 $d5 $d6 $d7 $d8 $d9 $da
$e2 $e3 $e4 $e5 $e6 $e7 $e8 $e9 $ea $f2 $f3 $f4 $f5 $f6 $f7 $f8
$f9 $fa

#bitcode * $3ffff
#category * $3ffff

:initCategoryNumber
	1 2	| low upp
	1 ( 16 <? 	| lo up cat
		|--- Positive numbers
		pick2 ( pick2 <?
            32767 over + 2 << >r | lo up cat nr r:pos
			over 'category r@ + !
			over 16 << over or 'bitcode r> + !
			1 + ) drop
		|--- Negative numbers
		over 1 - neg ( pick3 neg <=? 	| lo up cat nr
            32767 over + 2 << >r 		| lo up cat nr r:pos
			over 'category r@ + !
			over 16 << pick3 1 - pick2 + or
			'bitcode r> + !
			1 + ) drop
		rot 1 << rot 1 << rot 1 + )
	3drop ;


|----------- IO functions
| bitstring
| len(4)nro(8)
|-----------
#bytenew
#bytepos

:caseff
	$ff =? ( ,c 0 ,c ; ) ,c ;

:case0
	0? ( drop bytenew caseff 0 'bytenew ! 7 ; )
	1 - ;

:writeBits | (bs:BitString):void
	dup 16 >>
	( 1? 1 - swap
		1 pick2 << and? ( 1 bytepos << 'bytenew +! )
		bytepos case0 'bytepos !
		swap ) 2drop ;

| DCT & quantization core
#d0 #d1 #d2 #d3 #d4 #d5 #d6 #d7
#t0 #t1 #t2 #t3 #t4 #t5 #t6 #t7
#t10 #t11 #t12 #t13

:@datacol | adrdata --
	'd0 >a @+ a!+ @+ a!+ @+ a!+ @+ a!+ @+ a!+ @+ a!+ @+ a!+ @ a! ;
:!datacol | adrdata --
	>a 'd0 @+ a!+ @+ a!+ @+ a!+ @+ a!+ @+ a!+ @+ a!+ @+ a!+ @ a! ;
:@datarow | adrdata --
	'd0 >a @+ a!+ 28 + @+ a!+ 28 + @+ a!+ 28 + @+ a!+ 28 + @+ a!+ 28 + @+ a!+ 28 + @+ a!+ 28 + @ a! ;
:!datarow | adrdata --
	>a 'd0 @+ a!+ 28 a+ @+ a!+ 28 a+ @+ a!+ 28 a+ @+ a!+ 28 a+ @+ a!+ 28 a+ @+ a!+ 28 a+ @+ a!+ 28 a+ @ a! ;

:dtc
	d0 d7 2dup + 't0 ! - 't7 !
	d1 d6 2dup + 't1 ! - 't6 !
	d2 d5 2dup + 't2 ! - 't5 !
	d3 d4 2dup + 't3 ! - 't4 !
	t0 t3 2dup + 't10 ! - 't13 !
	t1 t2 2dup + 't11 ! - 't12 !
	t10 t11 2dup + 'd0 ! - 'd4 !
	t13 t12 over + 0.7071 *.
	2dup + 'd2 ! - 'd6 !
	t5 t6 t7
	over + 't12 ! over + 't11 ! t4 + 't10 !
	t10 t12 - 0.3827 *.		| z5
	t10 0.5412 *. over +	| z5 z2
	t12 1.3066 *. rot +		| z2 z4
	t11 0.7071 *.			| z2 z4 z3
	t7 over + rot			| z2 z3 z11 z4
	2dup + 'd1 ! - 'd7 !	| z2 z3
	t7 swap - swap			| z2 z13
	2dup + 'd5 ! - 'd3 !
	;

:scale0.5
	+? ( 0.5 + ; ) 0.5 - ;

:fDCTQuant | out data dbtbl -- |(data:Vector.<Number>, fdtbl:Vector.<Number>):Vector.<int>
	over 0 ( 8 <? swap
		dup @datacol dtc dup !datacol
		32 + swap 1 + ) 2drop
	over 0 ( 8 <? swap
		dup @datarow dtc dup !datarow
		4 + swap 1 + ) 2drop
	>a
	64 ( 1? 1 - >r		| Quantize/descale the coefficients
		@+ a@+ * scale0.5 16 >>
		rot !+ swap r> ) 3drop ;

| Chunk writing
:writeAPP0
	$FFE0 ,16 | marker
	16 ,16 | length
	$4A464946 ,32 | JFIF
	0 ,c | = "JFIF",'\0'
	1 ,c 1 ,c | versionhi versionlo
	0 ,c | xyunits
	1 ,16 1 ,16 | xdensity ydensity
	0 ,c 0 ,c | thumbnwidth thumbnheight
	;

:writeSOF0 |(width:int, height:int):void
	$FFC0 ,16	| marker
	17 ,16	| length, truecolor YUV JPG
	8 ,c	| precision
	hi ,16 wi ,16
	3 ,c    | nrofcomponents
	1 ,c $11 ,c 0 ,c | IdY HVY QTY
	2 ,c $11 ,c 1 ,c | IdU HVU QTU
	3 ,c $11 ,c 1 ,c | IdV HVV QTV
	;

:writeDQT
	$FFDB ,16 | marker
	132 ,16	   | length
	0 ,c 'YTable 64 ( 1? 1 - swap @+ ,c swap ) 2drop
	1 ,c 'UVTable 64 ( 1? 1 - swap @+ ,c swap ) 2drop
	;

:,list ( 1? 1 - swap @+ ,c swap ) 2drop ;

:writeDHT
	$FFC4 ,16 | marker
	$01A2 ,16 | length
	0 ,c | HTYDCinfo
	'std_dc_lumi_nrcodes 4 + 16 ,list | i+1
	'std_dc_lumi_values 12 ,list
	$10 ,c | HTYACinfo
	'std_ac_lumi_nrcodes 4 + 16 ,list | i+1
	'std_ac_lumi_values 162 ,list
	1 ,c | HTUDCinfo
	'std_dc_chro_nrcodes 4 + 16 ,list | i+1
	'std_dc_chro_values 12 ,list
	$11 ,c | HTUACinfo
	'std_ac_chro_nrcodes 4 + 16 ,list | i+1
	'std_ac_chro_values 162 ,list
	;

:writeSOS
	$FFDA ,16 | marker
	12 ,16 | length
	3 ,c | nrofcomponents
	1 ,c 0 ,c | IdY HTY
	2 ,c $11 ,c | IdU HTU
	3 ,c $11 ,c | IdV HTV
	0 ,c | Ss
	$3f ,c | Se
	0 ,c | Bf
	;

| Core processing
#DU * 256
#DU_DCT * 256

:preDU | CDU fdtbl --
	'DU_DCT rot rot fDCTQuant
	'DU_DCT 'ZigZag >a
	64 ( 1? 1 - swap
		@+ a@+ 2 << 'DU + !
		swap ) 2drop ;

:encodeDC | HTDC HTAC diff -- HTAC
	0? ( drop swap @ writeBits ; )
	32767 + 2 << dup | HTDC HTAC d2 d2
	'category + @ 2 << >r rot r> + @ writeBits
	'bitcode + @ writeBits ;

:fistDU0 | -- endpos0
	63 ( 1?
		dup 2 << 'DU + @ 1? ( drop ; ) drop
		1 - ) ;

:nextn0 | end0pos s i -- end0pos s i+
	( pick2 <=? 
		dup 2 << 'DU + @ 1? ( drop ; ) drop
		1 + ) ;

:processDU | HTDC HTAC DC --
	DU over @ - DU rot ! | HTDC HTAC diff
	encodeDC	| HTAC
	| Encode ACs
	fistDU0		| HTAC endpos0
	0? ( drop @ writeBits ; )
	1 ( over <=? 
		dup nextn0	| HTAC startpos i
		dup rot -	| HTAC i nrzeroes
		16 >=? (
			dup 4 >> | HTAC i nrzeroes lng
			( 1? 1 - pick4 $f0 2 << + @ writeBits ) drop
			$f and )
		over 2 << 'DU + @ 32767 + 2 << | HTAC i nrzeroes pos
		swap 4 << over 'category + @ +	| HTAC i pos int
		2 << pick4 + @ writeBits
		'bitcode + @ writeBits
		1 + ) drop
	63 =? ( 2drop ; ) drop
	@ writeBits ;

#DCY
#YDU * 256
#DCU
#UDU * 256
#DCV
#VDU * 256

:(rgb2yuv) | y x col -- yuv
	pick2 3 << pick2 + 2 << >r
	dup 16 >> $ff and over 8 >> $ff and rot $ff and | r g b
	pick2 0.299 * pick2 0.587 * pick2 0.114 * + + 16 >> $80 - r@ 'YDU + !
	pick2 -0.1687 * pick2 -0.3313 * pick2 0.5 * + + 16 >> r@ 'UDU + !
	rot 0.5 * rot -0.4187 * rot -0.0813 * + + 16 >> r> 'VDU + ! ;

:RGB2YUV | y x -- (img:BitmapData, xpos:int, ypos:int):void
	2dup swap sw * + 2 << vframe + >a
	0 ( 8 <?
		0 ( 8 <?
			a@+ (rgb2yuv)
			1 + ) drop
		sw 8 - 2 << a+
		1 + ) drop ;


:macroblock | x y -- x y
	rgb2yuv
	'YDU 'fdtbl_Y preDU
	'YDC_HT 'YAC_HT 'DCY processDU
	'UDU 'fdtbl_UV preDU
	'UVDC_HT 'UVAC_HT 'DCU processDU
	'VDU 'fdtbl_UV preDU
	'UVDC_HT 'UVAC_HT 'DCV processDU
	;

:scale50
	50 <? ( 5000 swap / ; )
	1 << 200 swap - ;

:JPEGEncoder | w h q -- ;(quality:int=50)
	1 clampmin 100 clampmax
    scale50
	'sf ! 'hi ! 'wi !
	'std_dc_lumi_nrcodes 'std_dc_lumi_values 'YDC_HT  computeHuffmanTbl
	'std_dc_chro_nrcodes 'std_dc_chro_values 'UVDC_HT computeHuffmanTbl
	'std_ac_lumi_nrcodes 'std_ac_lumi_values 'YAC_HT  computeHuffmanTbl
	'std_ac_chro_nrcodes 'std_ac_chro_values 'UVAC_HT computeHuffmanTbl
	initCategoryNumber
	initQuantTables
	0 'bytenew ! 0 'bytepos !
	$FFD8 ,16 | SOI | Add JPEG headers
	writeAPP0
	writeDQT
	writeSOF0
	writeDHT
	writeSOS
	| Encode 8x8 macroblocks
	0 'DCY ! 0 'DCU ! 0 'DCV !
	0 'bytenew ! 7 'bytepos !
	0 ( hi <?
		0 ( wi <?
			macroblock
			8 + ) drop
		8 + ) drop
	bytepos 1? ( | Do the bit alignment of the EOI marker
		dup 1 + 1 over << 1 -
		swap 16 << or writeBits
		) drop
	$FFD9 ,16 | EOI
	;

::savejpg | "" w h q --
	mark
	JPEGEncoder
	savemem
	empty
	;

