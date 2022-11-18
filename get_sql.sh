#!/usr/bin/env bash

set -e

if [[ "$#" != 1 && "$#" != 2 ]]; then
    echo "Usage: $0 <function-name> (<produce-blob: yes/no>)"
    exit 1
fi

LIBSQL_EXPORTED_FUNC=$1
LIBSQL_PRODUCE_BLOB=$2
LIBSQL_COMPILED_WASM=libsql-target/wasm32-unknown-unknown/release/libsql_generate.wasm
LIBSQL_OPTIMIZED_WASM=libsql-target/libsql_generate.wasm
LIBSQL_TARGET_FILE=libsql-target/create_${LIBSQL_EXPORTED_FUNC}.sql

CARGO_TARGET_DIR=libsql-target \
    cargo +nightly build -Z build-std=std,panic_abort -Z build-std-features=panic_immediate_abort \
    -j1 --quiet --release --target wasm32-unknown-unknown
wasm-opt -Os $LIBSQL_COMPILED_WASM -o $LIBSQL_OPTIMIZED_WASM
wasm-strip $LIBSQL_OPTIMIZED_WASM
echo ".init_wasm_func_table -- only needed for shell" > $LIBSQL_TARGET_FILE
echo "DROP FUNCTION IF EXISTS $1;" >> $LIBSQL_TARGET_FILE
if [[ "$LIBSQL_PRODUCE_BLOB" == "yes" ]]; then
    echo -n "CREATE FUNCTION $1 LANGUAGE wasm AS X'" >> $LIBSQL_TARGET_FILE
    xxd -p -c0 $LIBSQL_OPTIMIZED_WASM | tr -d '\n' >> $LIBSQL_TARGET_FILE
else
    echo "CREATE FUNCTION $1 LANGUAGE wasm AS '" >> $LIBSQL_TARGET_FILE
    wasm2wat $LIBSQL_OPTIMIZED_WASM | sed "s/'/''/g" >> $LIBSQL_TARGET_FILE
fi

if ! wasm2wat $LIBSQL_OPTIMIZED_WASM | grep -q "export \"$LIBSQL_EXPORTED_FUNC\""; then
    echo "Error: function $LIBSQL_EXPORTED_FUNC not exported from the WebAssembly module"
    exit 1
fi
if ! wasm2wat $LIBSQL_OPTIMIZED_WASM | grep -q "export \"memory\""; then
    echo "Error: memory not exported from the WebAssembly module"
    exit 1
fi

echo "';" >> $LIBSQL_TARGET_FILE

cat $LIBSQL_TARGET_FILE
