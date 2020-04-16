| Editor de imagenes
| PHREDA 2020
|--------------------------------------------------
^r3/lib/gui.r3
^r3/lib/btn.r3
^r3/lib/rand.r3
^r3/lib/input.r3
^r3/lib/sprite.r3
^r3/lib/vdraw.r3

^r3/util/loadimg.r3

^r3/lib/trace.r3

#nombre * 256

#imagen
#imagenw 320
#imagenh 200

#limx 60 #limy 24

#zoom 0
#xi 60 #yi 24 | donde esta el pixel 0,0
#color 0
#size 1

#pal8
$000000 $888888 $ffffff
$1D2B53 $7E2553 $008751
$AB5236 $5F574F $C2C3C7
$FFF1E8 $FF004D $FFA300
$FFEC27 $00E436 $29ADFF
$83769C $FF77A8 $FFCCAA
* 200

:scr2img | x y -- xi yi
	yi - zoom >> swap
	xi - zoom >> swap ;

:imagena
	imagenw * + 2 << imagen + 4 + ;

:imagenset | x y --
	imagena color swap ! ;

:imagenget | x y -- c
	imagena @ ;

#xa #ya
#xs1 #ys1
#xs2 #ys2

|----------- DRAW
:mododraw
	[ xypen scr2img vop ; ] [ xypen scr2img vline ; ]  onDnMove ;

|----------- FILL
:modofill
	[ color xypen scr2img vfill ; ] onClick ;

|----------- LINE
:modoline
	[ xypen 'ya ! 'xa ! ; ]
	[ color 'ink ! xa ya op xypen line ; ]
	[ xa ya scr2img vop xypen scr2img vline ; ] guiMap ;

|----------- BOX
:modobox
	[ xypen 'ya ! 'xa ! ; ]
	[ color 'ink ! xa ya xypen rectbox ; ]
	[ xa ya scr2img xypen scr2img vrect ; ] guiMap ;

|----------- CIRCLE
:border2cenrad
	rot 2dup + 1 >> >r - abs 1 >> >r
	2dup + 1 >> >r - abs 1 >>
	r> r> swap r> ;			| xr yr xm ym

:modocircle
	[ xypen 'ya ! 'xa ! ; ]
	[ color 'ink ! xa ya xypen border2cenrad bellipseb ; ]
	[ xa ya scr2img xypen scr2img 	| x y x y
		border2cenrad vellipseb ; ] guiMap ;

|----------- PICKER
:modopicker
	[ xypen scr2img imagenget 'color ! ; ] onClick ;

|----------- ERASER
:modoeraser
	[ xypen scr2img vop ; ] [ xypen scr2img vline ; ]  onDnMove ;

|----------- SELECT
:modoselect
	[ xypen 'ys1 ! 'xs1 ! ; ]
	[ xs1 ys1 xypen box.dot ; ]
	[ xypen scr2img 'ys2 ! 'xs2 ! ; ] guiMap ;


|------------------------------
#modo 0
#modoex 'mododraw

#xtool 0 #ytool 24

#imgtoolbar
#modos
	'mododraw 'modopicker
	'modoline 'modofill
	'modobox 'modocircle
	'modoeraser 'modoselect

:modo2xy
	dup $1 and 30 * xtool +
	swap 1 >> 30 * ytool + ;

:toolbar
    xtool ytool imgtoolbar sprite
	modo modo2xy
	30 30 2swap
	box.inv

	xypen
	swap xtool - -? ( 2drop ; ) 59 >? ( 2drop ; )
	swap ytool - -? ( 2drop ; ) 119 >? ( 2drop ; )
	30 / 1 << swap 30 / +
	dup modo2xy
	2dup 30 30 guiBox
	rot
	[ dup 'modo ! dup 2 << 'modos + @ 'modoex ! ; ] onClick
	drop
|	over 30 + over 30 +
|	$ffffff 'ink ! rectbox
 	30 30 2swap
	$7f 'ink ! box.mix50
	;

#xpal 0 #ypal 200
#npal

:palbar
	$454545 'ink !
	xpal ypal
	over 60 + over 380 +
	fillbox

	color 'ink !
	xpal 10 + ypal 5 +
	40 30 guiBox
	guiFill

	'pal8
	0 ( 20 <?
		0 ( 3 <?
			rot @+ 'ink ! rot rot
        	over 4 << 41 + ypal +
			over 4 << 7 + xpal + swap
			14 14 guiBox
			guiFill
			over 3 * over +
			[ dup 'npal ! ink 'color ! ; ] onClick
			npal =? ( $ffffff 'ink ! guiBorde )
			drop
			1 + ) drop
		1 + ) 2drop ;

:imagen.draw | --
|	bmrm 1 and? ( imagenw imagenh xi yi drawalphagrid ) drop
	xi yi
	imagenw zoom <<
	imagenh zoom <<
	imagen
	spritesize
	;

:teclado
	key
	<up> =? ( 1 zoom << neg 'yi +! )
	<dn> =? ( 1 zoom << 'yi +! )
	<le> =? ( 1 zoom << neg 'xi +! )
	<ri> =? ( 1 zoom << 'xi +! )
	<f1> =? ( 1 'modo +! )
	>esc< =? ( exit )
	drop
	;

|-----------------------------
:main
	cls gui

	'imagenset vset!
    imagen.draw

	$454545 'ink !
	home
	2 backlines

	$ffffff 'ink !
	4 5 atxy
	over ":r%d Img Editor [ " print
	'nombre print
	imagenh imagenw " | %dx%d ] " print
	$7f7f7f 'ink !
	sp [ 0 'zoom ! ; ] "x1" btnt
	sp [ 1 'zoom ! ; ] "x2" btnt
	sp [ 2 'zoom ! ; ] "x4" btnt
	sp [ 3 'zoom ! ; ] "x8" btnt

	toolbar
	palbar

	xi limx clampmin
	yi limy clampmin
	imagenw zoom << xi + sw clampmax
	imagenh zoom << yi + sh clampmax
	guiBox
	modoex 1? ( dup ex ) drop

	teclado
	acursor ;

:inimem
	mark
	"media/img/img-toolbar.png" loadimg 'imgtoolbar !
	here
	dup 'imagen !
	imagenw $fff and imagenh $fff and 12 << or swap !+

	dup >a imagenw imagenh * ( 1? 1 - $ffffff a!+ ) drop

	imagenw imagenh * 2 << +
	'here !

	imagenw imagenh vsize
	'imagenset vset!
	'imagenget vget!
	;

:   inimem
	$454545 'paper !
|	"mem/img-edit.mem" bmr.load
	3
	'main onShow
	drop
|	"mem/img-edit.mem" bmr.save
	;
