USING: compiler definitions generic assocs inference math
namespaces parser tools.test words kernel sequences arrays io
effects tools.test.inference compiler.units inference.state ;
IN: temporary

DEFER: x-1
DEFER: x-2

[ [ f ] { } map>assoc modify-code-heap ] recompile-hook [
    "IN: temporary USE: math GENERIC: x-1 ( x -- y ) M: integer x-1 ;" eval
    "IN: temporary : x-2 3 x-1 ;" eval

    [ t ] [
        { x-2 } compile

        \ x-2 word-xt

        { x-1 } compile

        \ x-2 word-xt =
    ] unit-test
] with-variable

DEFER: b
DEFER: c

[ ] [ "IN: temporary : a 1 2 ; : b a a ;" eval ] unit-test

[ 1 2 1 2 ] [ "USE: temporary b" eval ] unit-test

{ 0 4 } [ b ] unit-test-effect

[ ] [ "IN: temporary : a 1 2 3 ;" eval ] unit-test

[ 1 2 3 1 2 3 ] [ "USE: temporary b" eval ] unit-test

{ 0 6 } [ b ] unit-test-effect

\ b word-xt "b-xt" set

[ ] [ "IN: temporary : c b ;" eval ] unit-test

[ t ] [ "b-xt" get \ b word-xt = ] unit-test

\ c word-xt "c-xt" set

[ ] [ "IN: temporary : a 1 2 4 ;" eval ] unit-test

[ t ] [ "c-xt" get \ c word-xt = ] unit-test

[ 1 2 4 1 2 4 ] [ "USE: temporary c" eval ] unit-test

[ ] [ "IN: temporary : a 1 2 ;" eval ] unit-test

{ 0 4 } [ c ] unit-test-effect

[ f ] [ "c-xt" get \ c word-xt = ] unit-test

[ 1 2 1 2 ] [ "USE: temporary c" eval ] unit-test

[ ] [ "IN: temporary : d 3 ; inline" eval ] unit-test

[ ] [ "IN: temporary : e d d ;" eval ] unit-test

[ 3 3 ] [ "USE: temporary e" eval ] unit-test

[ ] [ "IN: temporary : d 4 ; inline" eval ] unit-test

[ 4 4 ] [ "USE: temporary e" eval ] unit-test

DEFER: x-3

[ ] [ "IN: temporary : x-3 3 ;" eval ] unit-test

DEFER: x-4

[ ] [ "IN: temporary : x-4 x-3 ;" eval ] unit-test

[ t ] [ \ x-4 compiled? ] unit-test

[ ] [ "IN: temporary USE: sequences : x-3 { } [ ] each ;" eval ] unit-test

[ f ] [ \ x-3 compiled? ] unit-test

[ f ] [ \ x-4 compiled? ] unit-test

[ ] [ "IN: temporary USING: kernel sequences ; : x-3 { } [ drop ] each ;" eval ] unit-test

[ t ] [ \ x-3 compiled? ] unit-test

[ t ] [ \ x-4 compiled? ] unit-test

[ t ] [ \ x-3 "compiled-uses" word-prop >boolean ] unit-test

[ t ] [ \ x-3 "compiled-uses" word-prop [ drop interned? ] assoc-all? ] unit-test

DEFER: g-test-1

DEFER: g-test-3

[ ] [ "IN: temporary USE: math GENERIC: g-test-1 ( x -- y ) M: integer g-test-1 sq ;" eval ] unit-test

[ ] [ "IN: temporary : g-test-2 ( -- y ) 3 g-test-1 ;" eval ] unit-test

[ ] [ "IN: temporary : g-test-3 ( -- y ) g-test-2 ;" eval ] unit-test

[ 25 ] [ 5 g-test-1 ] unit-test

[ ] [ "IN: temporary USE: math GENERIC: g-test-1 ( x -- y ) M: integer g-test-1 ;" eval ] unit-test

[ 5 ] [ 5 g-test-1 ] unit-test

[ t ] [
    \ g-test-3 word-xt

    "IN: temporary USE: math GENERIC: g-test-1 ( x -- y ) M: integer g-test-1 3 + ;" eval

    \ g-test-3 word-xt =
] unit-test

DEFER: g-test-5

[ ] [ "IN: temporary : g-test-4 ( -- y ) 3 g-test-1 ; inline" eval ] unit-test

[ ] [ "IN: temporary : g-test-5 ( -- y ) g-test-4 ;" eval ] unit-test

[ 6 ] [ g-test-5 ] unit-test

[ ] [ "IN: temporary USE: math GENERIC: g-test-1 ( x -- y ) M: integer g-test-1 10 + ;" eval ] unit-test

[ 13 ] [ g-test-5 ] unit-test

DEFER: g-test-6

[ ] [ "IN: temporary USING: arrays kernel ; GENERIC: g-test-6 ( x -- y ) M: array g-test-6 drop 123 g-test-1 ;" eval ] unit-test

DEFER: g-test-7

[ ] [ "IN: temporary : g-test-7 { } g-test-6 ;" eval ] unit-test

[ 133 ] [ g-test-7 ] unit-test

[ ] [ "IN: temporary USE: math GENERIC: g-test-1 ( x -- y ) M: integer g-test-1 15 + ;" eval ] unit-test

[ 138 ] [ g-test-7 ] unit-test

USE: macros

DEFER: macro-test-3

[ ] [ "IN: temporary USING: macros math ; : macro-test-1 sq ;" eval ] unit-test

[ ] [ "IN: temporary USING: macros arrays quotations ; MACRO: macro-test-2 ( n word -- quot ) <array> >quotation ;" eval ] unit-test

[ ] [ "IN: temporary : macro-test-3 2 \\ macro-test-1 macro-test-2 ;" eval ] unit-test

[ 625 ] [ 5 macro-test-3 ] unit-test

[ ] [ "IN: temporary USING: macros arrays quotations kernel math ; MACRO: macro-test-2 ( n word -- quot ) 2drop [ 3 + ] ;" eval ] unit-test

[ 8 ] [ 5 macro-test-3 ] unit-test

USE: hints

DEFER: hints-test-2

[ ] [ "IN: temporary USING: math hints ; : hints-test-1 3 + ; HINTS: hints-test-1 fixnum ;" eval ] unit-test

[ ] [ "IN: temporary : hints-test-2 5 hints-test-1 ;" eval ] unit-test

[ 8 ] [ hints-test-2 ] unit-test

[ ] [ "IN: temporary USE: math : hints-test-1 5 + ;" eval ] unit-test

[ 10 ] [ hints-test-2 ] unit-test

DEFER: inline-then-not-inline-test-1
DEFER: inline-then-not-inline-test-2

[ ] [ "IN: temporary : inline-then-not-inline-test-1 1 2 3 ; inline" eval ] unit-test

[ ] [ "IN: temporary : inline-then-not-inline-test-2 inline-then-not-inline-test-1 ;" eval ] unit-test

[ 1 2 3 ] [ inline-then-not-inline-test-2 ] unit-test

\ inline-then-not-inline-test-2 word-xt "a" set

[ ] [ "IN: temporary : inline-then-not-inline-test-1 6 6 9 ;" eval ] unit-test

[ f ] [ \ inline-then-not-inline-test-2 word-xt "a" get = ] unit-test

[ 6 6 9 ] [ inline-then-not-inline-test-2 ] unit-test

DEFER: generic-then-not-generic-test-1
DEFER: generic-then-not-generic-test-2

[ ] [ "IN: temporary GENERIC: generic-then-not-generic-test-1 ( a -- b )" eval ] unit-test

[ ] [ "IN: temporary USE: math M: integer generic-then-not-generic-test-1 sq ;" eval ] unit-test

[ ] [ "IN: temporary : generic-then-not-generic-test-2 3 generic-then-not-generic-test-1 ;" eval ] unit-test

[ 9 ] [ generic-then-not-generic-test-2 ] unit-test

[ ] [ "IN: temporary USE: math : generic-then-not-generic-test-1 1 + ;" eval ] unit-test

[ 4 ] [ generic-then-not-generic-test-2 ] unit-test

DEFER: foldable-test-1
DEFER: foldable-test-2

[ ] [ "IN: temporary : foldable-test-1 3 ; foldable" eval ] unit-test

[ ] [ "IN: temporary : foldable-test-2 foldable-test-1 ;" eval ] unit-test

[ +inlined+ ] [ \ foldable-test-2 \ foldable-test-1 compiled-usage at ] unit-test

[ 3 ] [ foldable-test-2 ] unit-test

[ ] [ "IN: temporary : foldable-test-1 4 ; foldable" eval ] unit-test

[ 4 ] [ foldable-test-2 ] unit-test

DEFER: flushable-test-2

[ ] [ "IN: temporary USE: kernel : flushable-test-1 drop 3 ; flushable" eval ] unit-test

[ ] [ "IN: temporary USE: kernel : flushable-test-2 V{ } dup flushable-test-1 drop ;" eval ] unit-test

[ V{ } ] [ flushable-test-2 ] unit-test

[ ] [ "IN: temporary USING: kernel sequences ; : flushable-test-1 3 over push ;" eval ] unit-test

[ V{ 3 } ] [ flushable-test-2 ] unit-test

: ax ;
: bx ax ;
[ \ bx forget ] with-compilation-unit

[ t ] [ \ ax compiled-usage [ drop interned? ] assoc-all? ] unit-test

DEFER: defer-redefine-test-2

[ ] [ "IN: temporary DEFER: defer-redefine-test-1" eval ] unit-test

[ ] [ "IN: temporary : defer-redefine-test-2 defer-redefine-test-1 1 ;" eval ] unit-test

[ defer-redefine-test-2 ] unit-test-fails

[ ] [ "IN: temporary : defer-redefine-test-1 2 ;" eval ] unit-test

[ 2 1 ] [ defer-redefine-test-2 ] unit-test
