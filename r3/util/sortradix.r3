| RadixSort
| PHREDA 2012
|-----------------------------------------
#count * 1024

:inicount
	'count 0 256 fill ;

:addcount
	'count >a 0 256
	( 1? 1 - swap a@ + dup a!+ swap ) 2drop ;

:radix8bit | cnt '2array 'destino 'vector -- cnt '2array 'destino
	>b
	inicount
	over pick3
	( 1? 1 -
		swap @+ b> ex
		$ff and
		2 << 'count + 1 swap +!
		4 + swap ) 2drop
	addcount
	over pick3 | '2array cnt
	( 1? 1 -
		over @ b> ex | nbuck
		$ff and
		2 << 'count +
		dup @ 1 - dup rot !	| posicion-1
		3 << pick3 + 		| '2array cnt-1 'destino
		rot  | 'hasta 'desde
		@+ rot !+ swap @+ rot ! | copia los 2
		swap
		) 2drop ;

:getvalue0	;
:getvalue8	8 >> ;
:getvalue16	16 >> ;
:getvalue24	24 >> ;

::radixsort | cnt '2array --
	here 'getvalue24 radix8bit
	swap 'getvalue16 radix8bit
	swap 'getvalue8 radix8bit
	swap 'getvalue0 radix8bit
	3drop ;
