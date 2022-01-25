#!/bin/bash

set -e

# Enables backtraces on panic and anyhow errors.
export RUST_BACKTRACE=1

export TEMPDIR=$(mktemp -d)

cwd=$(pwd)

export CHISEL_SECRET_LOCATION="file://$TEMPDIR/.env"

cd $TEMPDIR
$CHISEL init --no-examples
cd $cwd

$CHISELD --webui -m "sqlite://$TEMPDIR/chiseld.db?mode=rwc" -d "sqlite://$TEMPDIR/chiseld-data.db?mode=rwc" &
PID=$!

function cleanup() {
    kill $PID
    wait
    rm -rf "$TEMPDIR"
}

trap cleanup EXIT

$CHISEL wait

set +e
sh -c "$2"
ret=$?
set -e

exit $ret
