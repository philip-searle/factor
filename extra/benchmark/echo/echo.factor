! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors destructors kernel io.binary io.sockets
sequences ;

IN: benchmark.echo

: send/recv ( packet server client -- )
    [ over over addr>> ] [ send ] bi* receive drop assert= ;

: udp-echo ( -- )
    [
        10000 iota [ 4 >be ] map
        "127.0.0.1" 0 <inet4> <datagram>
        "127.0.0.1" 0 <inet4> <datagram>
        [ send/recv ] 2curry each
    ] with-destructors ;

MAIN: udp-echo
