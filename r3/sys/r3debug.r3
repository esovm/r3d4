|MEM 8192  | 8MB
| r3debug
| PHREDA 2020
|------------------
^./r3base.r3
^./r3pass1.r3
^./r3pass2.r3
^./r3pass3.r3
^./r3pass4.r3

^./r3vm.r3

^r3/lib/print.r3
^r3/lib/btn.r3
^r3/lib/input.r3
^r3/lib/fontm.r3
^media/fntm/droidsans13.fnt

#name * 1024
#namenow * 256
#cntinc

::r3debuginfo | str --
	r3name
	here dup 'src !
	'r3filename
	2dup load			|	"load" slog
	here =? ( 3drop "no src" 'error ! ; )
	src only13 0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	r3fullmode swap	|	"stage 1" slog
	r3-stage-1 error 1? ( drop ; ) drop	|	"stage 2" slog
	r3-stage-2 1? ( drop ; ) drop 		|	"stage 3" slog
	r3-stage-3			|	"stage 4" slog
	r3-stage-4			|	"stage ok" slog
	inc> 'inc - 3 >> 'cntinc !
	;

:savedebug
	mark
	error ,s ,cr
	lerror src - ,d ,cr
	"mem/debuginfo.db" savemem
	empty ;

:emptyerror
 	0 0	"mem/debuginfo.db" save ;

|-----------------------------
#emode

#xcode 5
#ycode 1
#wcode 40
#hcode 25

#xseli	| x ini win
#xsele	| x end win

|------ MODES
:calcselect
	xcode wcode + gotox ccx 'xsele !
	xcode gotox ccx 'xseli !
	;

:mode!imm
	0 'emode !
	rows 7 - 'hcode !
	cols 25 - 'wcode !
	calcselect ;

:mode!view
	1 'emode !
	rows 2 - 'hcode !
	cols 6 - 'wcode !
	calcselect ;

:mode!src
	2 'emode !
	rows 2 - 'hcode !
	cols 6 - 'wcode !
	calcselect ;

|------ MEMORY VIEW
#actword 0
#iniword 0

:incmap
	$ffff00 'ink !
	0 ( cntinc <?
		30 over 1 + gotoxy
		dup 3 << 'inc +
		@+ swap @ swap "%l %h" print
		1 + ) drop
	;

|---------
:printcode
	$ff0000 'ink !
	@+ " :%w " print
	drop ;
:a
	4 + @+
	mark
	dup 1 >> $1 and "le" + c@ ,c	| export/local
	dup 2 >> $1 and " '" + c@ ,c	| /adress used
	dup 3 >> $1 and " r" + c@ ,c	| /rstack mod
	dup 4 >> $1 and " ;" + c@ ,c	| /multi;
	dup 5 >> $1 and " R" + c@ ,c	| /recurse
	dup 6 >> $1 and " [" + c@ ,c	| /anon
	dup 7 >> $1 and " ." + c@ ,c	| /no ;
	dup 8 >> $1 and " i" + c@ ,c	| /inline
|	dup 9 >> $1 and " >" + c@ ,c	| /llama palabras
	dup 10 >> $1 and " I" + c@ ,c	| /inline adentro
	dup 12 >> $fff and "| c:%d " ,print
	24 >> $ff and "n:%d " ,print
	@ dup 12 >>> "l:%d " ,print
	,mov ,eol
	empty
	$ffffff 'ink !
	15 gotox
	here print
	;

:printdata
	$ff00ff 'ink !
	@+ " #%w " print
	drop ;
:a
	4 + @+
	mark
	dup 1 >> $1 and "le" + c@ ,c	| export/local
	dup 2 >> $1 and " '" + c@ ,c	| /adress used
	dup 3 >> $1 and " c" + c@ ,c	| cte

	dup 12 >> $fff and "| c:%d " ,print
	" t:" ,s
	24 >> $f and datatype ,s

	@ dup 12 >>> " l:%d " ,print
	$fff and " %h " ,print
	,eol
	empty
	$ffffff 'ink !
	15 gotox
	here print
	;

:printword | nro --
	actword =? ( $222222 'ink ! backline )
	4 << dicc +
	dup 8 + @ 1 nand? ( drop printcode ; ) drop
	printdata ;

:memorydic
	0 ( hcode <?
		dup iniword +
		$888888 'ink !
		dup 1 + "%d." print
		printword cr
		1 + ) drop ;

:+word | d --
	actword +
	cntdef 1 - clamp0max
	iniword <? ( dup 'iniword ! )
	iniword hcode + >=? ( dup hcode - 1 + 'iniword ! )
	'actword ! ;


:modeview
	0 1 gotoxy
	memorydic
	incmap

	0 hcode 1 + gotoxy
	$0000AE 'ink !
	rows hcode - 1 - backlines
	0 rows 1 - gotoxy
	"Search" "F3" btnf

	key
	>esc< =? ( exit )
	<f1> =? ( mode!imm )

	<up> =? ( -1 +word )
	<dn> =? ( 1 +word )
	<home> =? ( cntdef neg +word )
	<end> =? ( cntdef +word )
	<pgup> =? ( hcode neg +word ) 
	<pgdn> =? ( hcode +word )

|	<f1> =? ( srcview 1 + inc> 'inc - 4 >> >? ( 0 nip ) dup 'srcview ! srcnow )
|	<f3> =? ( )
|	<f4> =? ( )
|	<ctrl> =? ( controlon ) >ctrl< =? ( controloff )
|	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )

|	<tab> =? ( mode!imm )

	drop
	;


|------ CODE VIEW
#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor

#pantaini>	| comienzo de pantalla
#pantafin>	| fin de pantalla
#fuente  	| fuente editable
#fuente> 	| cursor
#$fuente	| fin de texto

|------------- sourc code

:col_inc $ff7f00 'ink ! ;
:col_com $666666 'ink ! ;
:col_cod $ff0000 'ink ! ;
:col_dat $ff00ff 'ink ! ;
:col_str $ffffff 'ink ! ;
:col_adr $ffff 'ink ! ;
:col_nor $ff00 'ink ! ;
:col_nro $ffff00 'ink ! ;
:col_select $444444 'ink ! ;

#mcolor

:wcolor
	mcolor 1? ( drop ; ) drop
	over c@
	$5e =? ( drop col_inc ; )				| $5e ^  Include
	$7c =? ( drop col_com 1 'mcolor ! ; )	| $7c |	 Comentario
	$3A =? ( drop col_cod ; )				| $3a :  Definicion
	$23 =? ( drop col_dat ; )				| $23 #  Variable
	$27 =? ( drop col_adr ; )				| $27 ' Direccion
    drop
	over isNro 1? ( drop col_nro ; ) drop
	col_nor
	;

| "" logic
:strcol
	mcolor
	0? ( drop col_str 2 'mcolor ! ; )
	1 =? ( drop ; )
	drop
	over c@ $22 <>? ( drop
		mcolor 3 =? ( drop 2 'mcolor ! ; )
		drop 0 'mcolor ! ; ) drop
	mcolor 2 =? ( drop 3 'mcolor ! ; ) drop
	2 'mcolor !
	;

:iniline
	0 'mcolor !
	xlinea wcolor
	( 1? 1 - swap
		c@+ 0? ( drop nip 1 - ; )
		13 =? ( drop nip 1 - ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		$22 =? ( strcol )
		drop swap ) drop ;

:emitl
	9 =? ( drop gtab ; )
	emit ccx xsele <? ( drop ; ) drop
	( c@+ 1? 13 <>? drop ) drop 1 -		| eat line to cr or 0
	wcode xcode + gotox
	$ffffff 'ink ! "." print
	;

:drawline
	iniline
	( c@+ 1?
		13 =? ( drop ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		$22 =? ( strcol )
		emitl
		) drop 1 - ;

|..............................
:linenro | lin -- lin
	dup ylinea +
	ycursor =? ( $222222 'ink ! backline )
	$aaaaaa 'ink !
	 1 + .d 3 .r. emits sp ;

:<<13 | a -- a
	( fuente >=?
		 dup c@
		13 =? ( drop ; )
		drop 1 - ) ;

:>>13 | a -- a
	( $fuente <?
		 dup c@
		13 =? ( drop 1 - ; ) | quitar el 1 -
		drop 1 + )
	drop $fuente 2 - ;

:khome
	fuente> 1 - <<13 1 + 'fuente> ! ;
:kend
	fuente> >>13  1 + 'fuente> ! ;

:scrollup | 'fuente -- 'fuente
	pantaini> 1 - <<13 1 - <<13  1 + 'pantaini> !
	ylinea 1? ( 1 - ) 'ylinea ! ;

:scrolldw
	pantaini> >>13 2 + 'pantaini> !
	pantafin> >>13 2 + 'pantafin> !
	1 'ylinea +! ;

:colcur
	fuente> 1 - <<13 swap - ;

:karriba
	fuente> fuente =? ( drop ; )
	dup 1 - <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1 - <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> !
	;

:kabajo
	fuente> $fuente >=? ( drop ; )
	dup 1 - <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1 +    | cnt cura
	dup 1 + >>13 1 + 	| cnt cura curb
	over -
	rot min +
	'fuente> !
	;

:kder
	fuente> $fuente <? ( 1 + 'fuente> ! ; ) drop ;

:kizq
	fuente> fuente >? ( 1 - 'fuente> ! ; ) drop ;

:kpgup
	20 ( 1? 1 - karriba ) drop ;

:kpgdn
	20 ( 1? 1 - kabajo ) drop ;

|..............................
:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 4 'xcursor +! ; )
	1 'xcursor +!
	noemit ;

:cursorpos
	ylinea 'ycursor ! 0 'xcursor !
	pantaini> ( fuente> <? c@+ emitcur ) drop
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea wcode + >=? ( dup wcode - 1 + 'xlinea ! )
	drop ;

:drawcursor
	cursorpos
	blink 1? ( drop ; ) drop
	xcode xlinea - xcursor +
	ycode ylinea - ycursor + gotoxy
	ccx ccy xy>v >a
	cch ( 1? 1 -
		ccw ( 1? 1 -
			a@ not a!+
			) drop
		sw ccw - 2 << a+
		) drop ;

:drawcursorfix
	cursorpos
	xcode xlinea - xcursor +
	ycode ylinea - ycursor + gotoxy
	ccx ccy xy>v >a
	cch ( 1? 1 -
		ccw ( 1? 1 -
			a@ not a!+
			) drop
		sw ccw - 2 << a+
		) drop ;

|..............................
:drawcode
	pantaini>
	0 ( hcode <?
		0 ycode pick2 + gotoxy
		linenro
		xcode gotox
		swap drawline
		swap 1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> !
	fuente>
	( pantafin> >? scrolldw )
	( pantaini> <? scrollup )
	drop ;

:setsource | src --
	dup 'pantaini> !
	dup 'fuente !
	dup 'fuente> !
	count + '$fuente !
	;

#srcview 0

:srcnow | nro --
	inc> 'inc - 4 >> >=? ( drop 'name 'namenow strcpy src setsource ; )
	4 << 'inc +
	@+ "%l" sprint 'namenow strcpy | warning ! is IN the source code
	@ setsource
	;

:gotosrc
	;

|---------------------------------
:barratop
	home
	$B2B0B2 'ink ! backline
	$0 'ink !
	" D3bug " emits
	"PLAY/VIEW" "TAB" btnf
	"INSPECT" "F2" btnf
	"MEMORY" "F3" btnf
	"RUN" "F4" btnf

	'namenow printr
	;

|----- scratchpad
#outpad * 2048
#inpad * 1024

:console
	xsele cch op
	wcode hcode 1 + gotoxy
	xsele ccy pline
	sw ccy pline
	sw cch pline
	$040486 'ink !
	poli


	0 hcode 1 + gotoxy
	$0000AE 'ink !
	rows hcode - 1 - backlines

	$ffffff 'ink !
	'outpad text cr
	" > " emits
	'inpad 1024 input

	0 rows 1 - gotoxy
	"Play2C" "F1" btnf
	"Step" "F2" btnf
	"StepN" "F3" btnf
	"BREAK" "F4" btnf
	"VIEW" "F6" btnf

	;


|-------------------------------
:modesrc
	drawcode
	drawcursor

	key
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	>esc< =? ( exit )

	<tab> =? ( mode!imm )
	<f1> =? ( mode!view )
	drop
	;

:modeimm
	drawcode
	drawcursorfix

	console
	key
	>esc< =? ( exit )

	<f2> =? ( fuente> breakpoint playvm gotosrc )
	<f3> =? ( stepvm gotosrc )
	<f4> =? ( stepvmn gotosrc )
	<f5> =? (  fuente> breakpoint )
|	<f6> =? ( viewscreen )

	<tab> =? ( mode!src )
	<f1> =? ( mode!view )
	drop
	;


|------ MAIN
:debugmain
	cls gui
	barratop

	emode
	0 =? ( modeimm )
	1 =? ( modeview )
	2 =? ( modesrc )
	drop

	acursor ;


: mark
	'name "mem/main.mem" load drop
	'name r3debuginfo
	error 1? ( drop savedebug ; ) drop
	emptyerror
	'name "mem/main.mem" load drop

	'fontdroidsans13 fontm
|	fonti

	calcselect
	'name 'namenow strcpy
	src setsource

	mode!imm

	'debugmain onshow
	;

