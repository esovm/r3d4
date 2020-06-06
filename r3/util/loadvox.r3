| read vox files
| PHREDA 2016
|-----------------
^r3/lib/gui.r3
^r3/lib/trace.r3

#paleta
$000000 $ffffff $ccffff $99ffff $66ffff $33ffff $00ffff $ffccff $ccccff $99ccff $66ccff $33ccff $00ccff $ff99ff $cc99ff $9999ff
$6699ff $3399ff $0099ff $ff66ff $cc66ff $9966ff $6666ff $3366ff $0066ff $ff33ff $cc33ff $9933ff $6633ff $3333ff $0033ff $ff00ff
$cc00ff $9900ff $6600ff $3300ff $0000ff $ffffcc $ccffcc $99ffcc $66ffcc $33ffcc $00ffcc $ffcccc $cccccc $99cccc $66cccc $33cccc
$00cccc $ff99cc $cc99cc $9999cc $6699cc $3399cc $0099cc $ff66cc $cc66cc $9966cc $6666cc $3366cc $0066cc $ff33cc $cc33cc $9933cc
$6633cc $3333cc $0033cc $ff00cc $cc00cc $9900cc $6600cc $3300cc $0000cc $ffff99 $ccff99 $99ff99 $66ff99 $33ff99 $00ff99 $ffcc99
$cccc99 $99cc99 $66cc99 $33cc99 $00cc99 $ff9999 $cc9999 $999999 $669999 $339999 $009999 $ff6699 $cc6699 $996699 $666699 $336699
$006699 $ff3399 $cc3399 $993399 $663399 $333399 $003399 $ff0099 $cc0099 $990099 $660099 $330099 $000099 $ffff66 $ccff66 $99ff66
$66ff66 $33ff66 $00ff66 $ffcc66 $cccc66 $99cc66 $66cc66 $33cc66 $00cc66 $ff9966 $cc9966 $999966 $669966 $339966 $009966 $ff6666
$cc6666 $996666 $666666 $336666 $006666 $ff3366 $cc3366 $993366 $663366 $333366 $003366 $ff0066 $cc0066 $990066 $660066 $330066
$000066 $ffff33 $ccff33 $99ff33 $66ff33 $33ff33 $00ff33 $ffcc33 $cccc33 $99cc33 $66cc33 $33cc33 $00cc33 $ff9933 $cc9933 $999933
$669933 $339933 $009933 $ff6633 $cc6633 $996633 $666633 $336633 $006633 $ff3333 $cc3333 $993333 $663333 $333333 $003333 $ff0033
$cc0033 $990033 $660033 $330033 $000033 $ffff00 $ccff00 $99ff00 $66ff00 $33ff00 $00ff00 $ffcc00 $cccc00 $99cc00 $66cc00 $33cc00
$00cc00 $ff9900 $cc9900 $999900 $669900 $339900 $009900 $ff6600 $cc6600 $996600 $666600 $336600 $006600 $ff3300 $cc3300 $993300
$663300 $333300 $003300 $ff0000 $cc0000 $990000 $660000 $330000 $0000ee $0000dd $0000bb $0000aa $000088 $000077 $000055 $000044
$000022 $000011 $00ee00 $00dd00 $00bb00 $00aa00 $008800 $007700 $005500 $004400 $002200 $001100 $ee0000 $dd0000 $bb0000 $aa0000
$880000 $770000 $550000 $440000 $220000 $110000 $eeeeee $dddddd $bbbbbb $aaaaaa $888888 $777777 $555555 $444444 $222222 $111111

#vx #vy #vz
#vcnt #vdata ##vpaleta
#subs
#vsize

:voxsize | adr -- adr'
	@+ 'vsize ! 4 +
	@+ 32 >? ( 2 'subs ! ) 'vx !
	@+ 32 >? ( 2 'subs ! ) 'vy !
	@+ 'vz !
	vsize 12 - + ;

:voxxyzi | adr -- adr'
	@+ 'vsize ! 4 +
	@+ 'vcnt !
	dup 'vdata !
	vsize 4 - + ;

:voxrgba | adr -- adr'
	@+ 'vsize ! 4 +
	dup 'vpaleta !
	vsize + ;

:parsevox | adr -- adr'
	@+
	$455a4953 =? ( drop voxsize ; )
	$495a5958 =? ( drop voxxyzi ; )
	$41424752 =? ( drop voxrgba ; )
	drop
	@+ 4 + + ; | skip size

::loadvox | "fn" --
	here dup rot load 'here !
	@+ $20584f56 <>? ( 2drop ; ) drop	| VOX
	@+ drop 							| version
	1 'subs !			| subsample
	'paleta 'vpaleta !
	( here <? parsevox ) drop ;

:bswapc
	dup 16 >> $ff and
	over 16 << $ff0000 and
	or swap $ff00 and or ;

::mapvox32 | 'vector --
	vdata >a
	vcnt ( 1? swap
		a@+
		dup 24 >> $ff and 1 -
		2 << vpaleta + @ bswapc
		swap dup 16 >> $ff and
		swap dup 8 >> $ff and
		swap $ff and
		pick4 ex
		swap 1 - ) 2drop ;

::mapvox8 | 'vector --
	vdata >a
	vcnt ( 1? swap
		a@+
		dup 24 >> $ff and
		swap dup 16 >> $ff and
		swap dup 8 >> $ff and
		swap $ff and
		pick4 ex
		swap 1 - ) 2drop ;

:apow
	0 swap ( 1? 1 >> swap 1 + swap ) drop 1 - ;

::voxqsize | -- qsize
	vx vy max vz max
	1 ( 1024 <?
		over >=? ( nip apow ; )
		1 << ) nip apow ;

|---- test, not work in library mode!
|:main
|	mark
|	"media/vox/falc.vox" loadvox
|	show clrscr
|		vx vy vz "%d %d %d" print cr
|		vcnt vdata "%h %d " print cr
|		[ "%d %d %d %h" print cr allowchome ; ] mapvox32
|		'exit >esc<	;
|: main ;