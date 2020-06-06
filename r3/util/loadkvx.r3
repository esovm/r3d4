| read kvx files
| PHREDA 2016
|-----------------
^r3/lib/gui.r3
^r3/lib/trace.r3

#vcnt
#vx #vy #vz
#xoffset
#xyoffset
#voxdata
#vpaleta

::loadkvx | "fn" --
	here dup rot load dup 'here !
	768 - 'vpaleta !
	@+ 'vcnt !
	@+ 'vx ! @+ 'vy ! @+ 'vz !
	12 + | pivot
	dup 'voxdata !
	dup 'xoffset !
	vx 1 + 2 << +
	'xyoffset !
	;

#top
#vec

:getdata8 | x y -- x y
	over 2 << xoffset + @ voxdata +		| x y xoff
	pick2 vy 1 + * pick2 + 1 << xyoffset +    | x y xoff yoff+

	@+ dup $ffff and pick3 +
	16 >> rot + swap

|	w@+ pick2 + swap			| x y xoff ini yoffn
|	w@ rot + swap 				| x y fin ini

	( over <? 					| x y fin act
		c@+ 'top ! c@+
		swap 1 + swap			| x y fin act len
		( 1? 1 - >r				| x y fin act r: len
			c@+	$ff and			| x y fin act col
			pick4 pick4 top
			vec ex
			1 'top +!
			r> ) drop
		) 2drop ;

::mapkvx8 | vector --
	'vec !
	0 ( vx <?
		0 ( vy <?
    		getdata8
			1 + ) drop
		1 + ) drop ;


:bswap64 | rgb64 -- rgb
	dup $3 and over 2 << $fc and or 16 << swap
	dup $300 and over 2 << $fc00 and or rot or swap
	dup $30000 and swap 2 << $fc0000 and or 16 >> or
	;

:getdata32 | x y -- x y
	over 2 << xoffset + @ voxdata +		| x y xoff
	pick2 vy 1 + * pick2 + 1 << xyoffset +    | x y xoff yoff+

	@+ dup $ffff and pick3 +
	16 >> rot + swap

|	w@+ pick2 + swap			| x y xoff ini yoffn
|	w@ rot + swap 				| x y fin ini

	( over <? 					| x y fin act
		c@+ 'top ! c@+
		swap 1 + swap			| x y fin act len
		( 1? 1 - >r				| x y fin act r: len
			c@+	$ff and 					| x y fin act col
			dup 1 << + vpaleta + @
			bswap64
			pick4 pick4
			top dup 1 + 'top !
			vec ex
			r> ) drop
		) 2drop ;

::mapkvx32 | vector --
	'vec !
	0 ( vx <?
		0 ( vy <?
    		getdata32
			1 + ) drop
		1 + ) drop ;

:apow
	0 swap ( 1? 1 >> swap 1 + swap ) drop 1 - ;

::kvxqsize | -- qsize
	vx vy max vz max
	1 ( 1024 <? over >=? ( nip apow ; ) 1 << ) nip apow ;

|---- test, not work in library mode!
|:main
|	mark
|	"media/vox/kvx/0902_queball.kvx" loadkvx
|	show clrscr
|		vx vy vz "%d %d %d" print cr
|		vcnt voxdata "%h %d " print cr
|		[ "%d %d %d %h " print cr allowchome ; ] mapkvx32
|		[ "%d %d %d %h " print cr allowchome ; ] mapkvx8
|		'exit >esc<
|	;

|: main ;