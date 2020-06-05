| Build Octree
| PHREDA 2015
| from r4
|-----------------------------
^r3/lib/gui.r3
^r3/lib/trace.r3
^r3/lib/sort.r3

##memvox		| inicio de puntos ordenados
##memvox>
##octre			| inicio de octree
##octre>

|---- archivo a grabar
##$inifile
##$octree
##$lastlev
##$pixels
##$realpixels
##$end

#bith	| bitmask hijos
#padre	| de que padre
#levels * 1024	| niveles del octree
#level>

#xmin #ymin #zmin #xmax #ymax #zmax

##qsize $ff	| lado
##deepvox 8 	| profundidad octree

:vertices | -- cnt
	memvox memvox> - 3 >> ;

::octreedim | --
	xmax ymax zmax max max
	1024 <? ( $3ff 'qsize ! 10 'deepvox ! )
	512 <? ( $1ff 'qsize ! 9 'deepvox ! )
	256 <? ( $ff 'qsize ! 8 'deepvox ! )
	128 <? ( $7f 'qsize ! 7 'deepvox ! )
	64 <? ( $3f 'qsize ! 6 'deepvox ! )
	32 <? ( $1f 'qsize ! 5 'deepvox ! )
	drop ;

::octreedeep | od --
	dup 'deepvox !
	1 swap << 1 - 'qsize ! ;

|----- conversion
|--- 3D x y z . 10 bits
:p1x2 | x -- v
	$3ff and
	dup 16 << xor $ff0000ff and
	dup 8 << xor  $0300f00f and
	dup 4 << xor  $030c30c3 and
	dup 2 << xor  $09249249 and ;

::morton3d | x y z -- Z
	p1x2 1 << swap p1x2 or 1 << swap p1x2 or ;

:c1x2 | x - v
	$09249249 and
	dup 2 >> xor $030c30c3 and
	dup 4 >> xor $0300f00f and
	dup 8 >> xor $ff0000ff and
	dup 16 >> xor $3ff and ;

::invmorton3d | Z -- x y z
 	dup c1x2 swap 1 >> dup c1x2 swap 1 >> c1x2 ;

|------------ construye octree
:,oc | val --
	octre> !+ 'octre> ! ;

#colores 0 0 0 0 0 0 0 0 0 0
#colores * $ffff
#colores>

#sumr #sumg #sumb
:promediocol | -- rgb
	0 'sumr ! 0 'sumg ! 0 'sumb !
	'colores ( colores> <? 
		@+
		dup $ff and 16 << 'sumb +!
		dup $ff00 and 8 << 'sumg +!
		$ff0000 and 'sumr +!
		) drop
	colores> 'colores - 2 >>
	1.0 swap / | optimizacion
	sumr over *. $ff0000 and
	sumg pick2 *. 8 >> $ff00 and or
	sumb rot *. 16 >> $ff and or
	;

:nodecolor+ | node -- node+ color
	memvox> <? ( @+ ; ) @+ 8 >> ;

:oct2!+
	padre ,oc
	promediocol 8 << bith or ,oc ;

:level!+
	octre> level> !+ 'level> ! ;

:ininode | nodo -- nodo+			| inicio de nivel
	@+ dup 3 >> $1fffffff and 'padre !
	$7 and place 'bith !
	nodecolor+ 'colores !+ 'colores> ! ;

:nextnode | nodo -- nodo+
	@+ dup 3 >> $1fffffff and
	padre =? ( drop $7 and place bith or 'bith ! nodecolor+ colores> !+ 'colores> ! ; )
	oct2!+
	'padre ! $7 and place 'bith !
	nodecolor+ 'colores !+ 'colores> ! ;

:collectnode | end start --
	level!+
	ininode ( over <? nextnode ) 2drop
	oct2!+
	level!+ ;

:,levelnode |  hasta desde --
	( over <? 
		4 + @+ $ff and ,oc
		) 2drop ;

:calcdir | suma adr --- suma adr+
	dup @	 		| suma adr valor
	dup popcnt >r

	pick2 pick2 4 + $octree - 2 >> - 8 << or swap !+	| relativo
|	pick2 8 << or swap !+	| absoluto

	swap r> + swap
	;

:,levelcolor |  hasta desde --
	( over <?
		4 + @+ 8 >>
		$ffffff and
|***		$f8fcf8 and | 16 bits
		,oc
		) 2drop ;

|------------ elimina repetidos
:equal
	pick2 =? ( drop 4 + ; )
	rot drop	| nextdir+ nextval
	dup a!+ swap @+ a!+ ;

::repetidos
	memvox memvox> over - 3 >> 1 + swap
	shellsort
	memvox >a
	a@+ 4 a+ memvox 8 +
	( memvox> <? 	| prevval nextdir
		@+ equal 	| prevval nextdir+ nextval
		) 2drop
	a> 'memvox> !
	;


#ncol
:.col |col --
	1 'ncol !
	dup $ff and 16 << 'sumb !
	dup $ff00 and 8 << 'sumg !
	$ff0000 and 'sumr ! ;

:+col | col --
	1 'ncol +!
	dup $ff and 16 << 'sumb +!
	dup $ff00 and 8 << 'sumg +!
	$ff0000 and 'sumr +! ;

:col@ | -- col
	1.0 ncol /
	sumr over *. $ff0000 and
	sumg pick2 *. 8 >> $ff00 and or
	sumb rot *. 16 >> $ff and or ;

:equal
	pick2 =? ( drop 4 + ; )
	rot drop	| nextdir+ nextval
	dup a!+ swap
	@+ a!+ ;

::repetidosmix
	memvox memvox> over - 3 >> 1 + swap
	shellsort
	memvox >a
	a@+ 4 a+ memvox 8 +
	( memvox> <? 	| prevval nextdir
		@+ equal	| prevval nextdir+ nextval
		) 2drop
	a> 'memvox> !
	;

|-------------------------------
::buildoctree | --
	memvox>
	memvox =? ( drop ; ) drop	| sin puntos
	repetidos

	memvox>	dup
	'octre ! 'octre> !
	'levels 'level> !
	|--- calcula hijos
	memvox> memvox collectnode

	'levels deepvox 1 -
	( 1? 1 - swap
		@+ swap @+ rot collectnode
		swap ) 2drop

	|--- graba octree real
	octre> '$inifile !
	$3d000000
	deepvox or
	,oc
	0 ,oc | pixels
	0 ,oc | p1
	0 ,oc | p2
	0 ,oc | xlim
	0 ,oc | ylim
	0 ,oc | zlim

    octre> '$octree !
	level> ( 'levels >? 8 -
		'levels =? ( octre> '$lastlev ! )
		dup 4 + @ over @
		,levelnode
		 ) drop

	1 $octree ( octre> <? calcdir ) 2drop

    octre> '$pixels !
	level> ( 'levels >?  8 -
		dup 4 + @ over @
		,levelcolor
		 ) drop

	octre> '$realpixels !
	memvox ( memvox> <? 
		4 + @+
|***		$f8fcf8 and | 16 bits
|***		$fcfcfc and | 18 bits
|***		$fefefe and | 21 bits
		,oc ) drop
	octre> dup '$end ! 'here !

	|... save header
	$pixels $octree - $inifile 4 + !
	;

|------------ optimiza ultimo nivel
:todos? | cant dir1 dir2 -- 0/1
	>a ( swap 1? 1 - swap
		@+ a@+ <>? ( 3drop 0 ; )
		drop )
	2drop 1 ;

:buscacol | nodo cnt direccion -- nodo cnt nuevadireccion/0
	@+ swap >b 		| nodo cant col1  r: dirpix
	$realpixels  		| nodo cant col1 dpix  r:dirpix
	( $end pick3 2 << - <? 
		@+ pick2 =? ( drop pick2 1 - over b>		| ya comprobo el primero!!
			todos? 1? ( drop nip 4 - ; ) )
		drop )
	2drop 0 ;

:nodorepe | nodo dir -- nodo++
	$pixels - $octree + over - 2 >> 1 - 8 << over @ $ff and or swap !+ ;

:searchcolors | nodo valor -- nodo++
	dup $ff and popcnt			| nodo valor cnt
	swap 8 >> 1 + 2 <<
	pick2 + $octree - $pixels +	| nodo cnt direccion
	buscacol 1? ( nip nodorepe ; ) drop
	swap dup @ 		| cnt nodo valor
	dup 8 >> 1 + 2 << pick2 + $octree - $pixels + >a | cnt nodo valor  r:fuente
	$ff and $end $pixels - $octree + pick2 - 2 >> 1 - 8 << or swap !+
	swap $end				| nodo+ cnt dirdes
	( swap 1? 1 -
		a@+ rot !+ ) drop
	dup '$end !
	drop ;

|--------------------------------------
::optoctree
	$realpixels '$end !
	$lastlev ( $pixels <? 
		dup @ searchcolors
		) drop ;

|----------- ajuste
::getminmax
	memvox
	@+ invmorton3d
	dup 'zmin ! 'zmax !
	dup 'ymin ! 'ymax !
	dup 'xmin ! 'xmax !
	4 +
	( memvox> <? 
		@+ invmorton3d
		zmin <? ( dup 'zmin ! ) zmax >? ( dup 'zmax ! ) drop
		ymin <? ( dup 'ymin ! ) ymax >? ( dup 'ymax ! ) drop
		xmin <? ( dup 'xmin ! ) xmax >? ( dup 'xmax ! ) drop
		4 + ) drop
	octreedim ;

#ddx #ddy #ddz

:movevox | --
	memvox
	( memvox> <? >a
		a@ invmorton3d
		ddz + qsize and rot
		ddx + qsize and rot
		ddy + qsize and rot
		morton3d a>
		!+ 4 + ) drop ;

::centravoxel | --
	getminmax
	qsize 1 >> xmax xmin + 1 >> - 'ddx !
	qsize 1 >> ymax ymin + 1 >> - 'ddy !
	qsize 1 >> zmax zmin + 1 >> - 'ddz !
	movevox ;

::movevoxel | x y z --
	'ddz ! 'ddy ! 'ddx !
	movevox ;

|----- calcula normales
#p0 #p0d
#p1 #p1d

:dist | p p1 -- p p1 dist2 | x^2+y^2+z^2
	over @ over @ - dup *. >a
	over 4 + @ over 4 + @ - dup *. a+
	over 8 + @ over 8 + @ - dup *. a> + ;

:dista | p p1 -- p p1 dist2 | |x|+|y|+|z|
	over @ over @ - abs  >a
	over 4 + @ over 4 + @ - abs a+
	over 8 + @ over 8 + @ - abs a> + ;

:compmax | p pn dist - p
	0? ( 2drop ; )
	p0d <? ( p0d 'p1d ! 'p0d ! p0 'p1 ! 'p0 ! ; )
	p1d <? ( 'p1d ! 'p1 ! ; )
	2drop ;

:busco2mascerca | p -- p p0 p1
	memvox >b
	$7fffffff 'p0d !
	$7fffffff 'p1d !
	vertices ( 1? 1 - swap
		b> dista compmax
		16 b+ swap ) drop
	p0 p1 ;

#v0 0 0 0
#v1 0 0 0

|------------------------------------------------
|	Vector3f v0 = (p0-p).Unit();
|	Vector3f v1 = (p1-p).Unit();
|	point.normal = v1.Cross(v0);
|	if(p.Dot(point.normal) < 0) point.normal = -point.normal;
|------------------------------------------------
:calculonormal | p p0 p1 -- p zn yn xn
	'v1 swap v3=
	'v0 swap v3=
	'v0 over v3- 'v0 v3nor
	'v1 over v3- 'v0 v3nor
	'v1 'v0 v3vec
	dup 'v1 v3ddot -? ( 'v1 -1.0 v3* ) drop

	'v1 v3nor

	'v1 @+ swap @+ swap @ swap rot
	;

::calcnormales
	memvox> >b
	memvox
	vertices ( 1? 1 - swap
		busco2mascerca	| p p0 p1
		calculonormal	| p xn yn zn
		b!+ b!+ b!+ 	| guardo normal
		16 + swap ) 2drop
	
| guarda como color
	memvox> >b
	memvox ( memvox> <? 
		4 +
		b@+ 9 >> $ff and
		b@+ 1 >> $ff00 and or
		b@+ 7 << $ff0000 and or
		swap !+
		) drop
	;

|--------- cambia coordenada
::rotacoordvoxel
	memvox ( memvox> <? 
		dup @
		invmorton3d rot morton3d
		swap !+
		4 + ) drop
	;

|--------- espejo coordenada
::espejovoxel
	memvox ( memvox> <? 
		dup @ invmorton3d
		qsize xor rot
		qsize xor rot
		qsize xor rot
		morton3d
		swap !+
		4 + ) drop ;

|---------
::coloreavoxel
	memvox ( memvox> <?
		@+
		invmorton3d
		2 >> $ff and
		swap 2 >> $ff and 8 << or
		swap 2 >> $ff and 16 << or
		swap !+ ) drop
	;
