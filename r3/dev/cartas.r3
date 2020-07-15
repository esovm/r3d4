^r3/lib/gui.r3
^r3/lib/vsprite.r3
^media/vsp/cartas.vsp

#dibs
svg0  svg1  svg2  svg3  svg4  svg5  svg6  svg7  svg8  svg9  svg10 svg11 svg12
svg13 svg14 svg15 svg16 svg17 svg18 svg19 svg20 svg21 svg22 svg23 svg24 svg25
svg26 svg27 svg28 svg29 svg30 svg31 svg32 svg33 svg34 svg35 svg36 svg37 svg38
svg39 svg40 svg41 svg42 svg43 svg44 svg45 svg46 svg47 svg48 svg49 svg50 svg51

:drawcarta | nro --
	2 << 'dibs + @ 3dvsprite ;

#mazo * 208

:mazo.ini
	'mazo >a 0 ( 52 <? dup a!+ 1 + ) drop ;

:mazo.chg | n m --
	2 << 'mazo + swap
	2 << 'mazo +
	dup @ over @
	rot ! swap !
	;

:mazo.mix
	100 ( 1? 1 -
		rand 52 mod abs
		rand 52 mod abs
		mazo.chg
		) drop ;

:printmazo
	-9.1 -3.0 0 mtransi
	0
	4 ( 1? 1 -
		13 ( 1? 1 -
			1.4 0 0 mtransi
			rot dup drawcarta 1 + rot rot
			) drop
		-18.2 2.0 0 mtransi
		) 2drop
	;


:freelook
	xypen
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg mrotx
	mroty ;

:ini
	mark
	mazo.ini
	;

:main
	cls home
	over "%d" print
	omode
	freelook
	0 0 16.0 mtrans
	printmazo

	key
	>esc< =? ( exit )
	<f1> =? ( mazo.mix )
	drop
	;

: ini
	33
	'main onshow
	 ;
