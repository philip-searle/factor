USING: accessors alien alien.c-types alien.syntax arrays ascii
assocs combinators fry kernel macros math.parser sequences splitting ;
IN: alien.fortran

! XXX this currently only supports the gfortran/f2c abi.
! XXX we should also support ifort at some point for commercial BLASes

C-STRUCT: (fortran-complex)
    { "float" "r" }
    { "float" "i" } ;
C-STRUCT: (fortran-double-complex)
    { "double" "r" }
    { "double" "i" } ;

: fortran-c-abi ( -- abi ) "cdecl" ;

: fortran-name>symbol-name ( fortran-name -- c-name )
    >lower CHAR: _ over member? 
    [ "__" append ] [ "_" append ] if ;

ERROR: invalid-fortran-type type ;

<PRIVATE

TUPLE: fortran-type dims size ;

TUPLE: number-type < fortran-type ;
TUPLE: integer-type < number-type ;
TUPLE: logical-type < integer-type ;
TUPLE: real-type < number-type ;
TUPLE: double-precision-type < number-type ;

TUPLE: character-type < fortran-type ;
TUPLE: misc-type < fortran-type name ;

TUPLE: complex-type < number-type ;
TUPLE: real-complex-type < complex-type ;
TUPLE: double-complex-type < complex-type ;

CONSTANT: fortran>c-types H{
    { "character"        character-type        }
    { "integer"          integer-type          }
    { "logical"          logical-type          }
    { "real"             real-type             }
    { "double precision" double-precision-type }
    { "complex"          real-complex-type     }
    { "double complex"   double-complex-type   }
}

: append-dimensions ( base-c-type type -- c-type )
    dims>>
    [ product number>string "[" "]" surround append ] when* ;

MACRO: size-case-type ( cases -- )
    [ invalid-fortran-type ] suffix
    '[ [ size>> _ case ] [ append-dimensions ] bi ] ;

: simple-type ( type base-c-type -- c-type )
    swap
    [ dup size>> [ invalid-fortran-type ] [ drop ] if ]
    [ append-dimensions ] bi ;

: new-fortran-type ( dims size class -- type )
    new [ (>>size) ] [ (>>dims) ] [ ] tri ;

GENERIC: (fortran-type>c-type) ( type -- c-type )

M: integer-type (fortran-type>c-type)
    {
        { f [ "int"      ] }
        { 2 [ "short"    ] }
        { 4 [ "int"      ] }
        { 8 [ "longlong" ] }
    } size-case-type ;
M: real-type (fortran-type>c-type)
    {
        { f [ "float"  ] }
        { 4 [ "float"  ] }
        { 8 [ "double" ] }
    } size-case-type ;
M: complex-type (fortran-type>c-type)
    {
        {  f [ "(fortran-complex)"        ] }
        {  8 [ "(fortran-complex)"        ] }
        { 16 [ "(fortran-double-complex)" ] }
    } size-case-type ;

M: double-precision-type (fortran-type>c-type)
    "double" simple-type ;
M: double-complex-type (fortran-type>c-type)
    "(fortran-double-complex)" simple-type ;
M: misc-type (fortran-type>c-type)
    dup name>> simple-type ;

: fix-character-type ( character-type -- character-type' )
    clone dup size>>
    [ dup dims>> [ invalid-fortran-type ] [ dup size>> 1array >>dims f >>size ] if ]
    [ dup dims>> [ ] [ { 1 } >>dims ] if ] if ;

M: character-type (fortran-type>c-type)
    fix-character-type "char" simple-type ;

: dimension>number ( string -- number )
    dup "*" = [ drop 0 ] [ string>number ] if ;

: parse-dims ( string -- string' dim )
    "(" split1 dup
    [ ")" ?tail drop "," split [ [ blank? ] trim dimension>number ] map ] when ;

: parse-size ( string -- string' size )
    "*" split1 dup [ string>number ] when ;

: parse-fortran-type ( fortran-type-string -- type )
    parse-dims swap parse-size swap
    dup >lower fortran>c-types at*
    [ nip new-fortran-type ] [ drop misc-type boa ] if ;

: c-type>pointer ( c-type -- c-type* )
    "[" split1 drop "*" append ;

GENERIC: added-c-args ( type -- args )

M: fortran-type added-c-args drop { } ;
M: character-type added-c-args drop { "long" } ;

PRIVATE>

: fortran-type>c-type ( fortran-type -- c-type )
    parse-fortran-type (fortran-type>c-type) ;

: fortran-arg-type>c-type ( fortran-type -- c-type added-args ) { } ;
: fortran-ret-type>c-type ( fortran-type -- c-type added-args ) { } ;

: fortran-sig>c-sig ( fortran-return fortran-args -- c-return c-args ) ;

! : F-RECORD: ... ; parsing
! : F-ABI: ... ; parsing
! : F-SUBROUTINE: ... ; parsing
! : F-FUNCTION: ... ; parsing

