#!/bin/sh
# Copyright (c) 2019 Caleb James DeLisle
# Use of this source code is governed by an ISC
# license that can be found in the LICENSE file.

die() { echo "Error " $1; exit 100; }
SED=`which gsed || which sed`
test "x$SED" = "x" && die "sed not found"
SH=`which sh`
test "x$SH" = "x" && die "sh not found"
CAT=`which cat`
test "x$CAT" = "x" && die "cat not found"
FIND=`which find`
test "x$FIND" = "x" && die "find not found"
MV=`which mv`
test "x$MV" = "x" && die "mv not found"

usage() {
    echo "pktconv.sh OPTIONS COMMAND"
    echo "  OPTIONS"
    echo "      --dryrun            # Don't actually change anything"
    echo "  COMMANDS"
    echo "      imports             # Update imported files"
    echo "      rimports            # Revert imported files back to btcd"
    echo "      internal            # Move ./internal directory to ./util"
    echo "      rinternal           # Move ./util directory back to ./internal"
}

RUN=$SH

imports() {
    ( $FIND ./ -name '*.go' && echo './go.mod' ) | while read x; do
        echo $SED -i -e \'s@"github.com/btcsuite/btcd@"github.com/pkt-cash/pktd@g\' $x;
        echo $SED -i -e \'s@"github.com/btcsuite/btcutil@"github.com/pkt-cash/btcutil@g\' $x;
        echo $SED -i -e \'s@"github.com/btcsuite/btcwallet@"github.com/pkt-cash/libpktwallet@g\' $x;
    done | $RUN
}
rimports() {
    ( $FIND ./ -name '*.go' && echo './go.mod' ) | while read x; do
        echo $SED -i -e \'s@"github.com/pkt-cash/pktd@"github.com/btcsuite/btcd@g\' $x;
        echo $SED -i -e \'s@"github.com/pkt-cash/btcutil@"github.com/btcsuite/btcutil@g\' $x;
        echo $SED -i -e \'s@"github.com/pkt-cash/libpktwallet@"github.com/btcsuite/btcwallet@g\' $x;
    done | $RUN
}
internal() {
    echo $MV ./internal ./util | $RUN
    $FIND ./ -name '*.go' | while read x; do
        echo $SED -i -e \'s@"github.com/pkt-cash/libpktwallet/internal@"github.com/pkt-cash/libpktwallet/util@g\' $x;
    done | $RUN
}
rinternal() {
    echo $MV ./util ./internal | $RUN
    $FIND ./ -name '*.go' | while read x; do
        echo $SED -i -e \'s@"github.com/pkt-cash/libpktwallet/util@"github.com/pkt-cash/libpktwallet/internal@g\' $x;
    done | $RUN
}

for arg in "$@"; do
    if test "x$arg" = "x--dryrun"; then
        RUN=$CAT
    elif test "x$arg" = "ximports"; then
        imports
        exit 0
    elif test "x$arg" = "xrimports"; then
        rimports
        exit 0
    elif test "x$arg" = "xinternal"; then
        internal
        exit 0
    elif test "x$arg" = "xrinternal"; then
        rinternal
        exit 0
    else
        usage
        die "I don't understand argument $arg"
    fi
done

usage
