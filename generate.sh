#!/usr/bin/env bash

set -e

rustfmt libsql-target/input.rs
analyzed=$(rust-code-analysis-cli -lrust -F -p libsql-target/input.rs | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g')
loc=$(wc -l libsql-target/input.rs | cut -d' ' -f1)
fn_name=$(echo $analyzed | cut -d' ' -f 5 | tr -d ':')
fn_start=$(echo $analyzed | cut -d' ' -f 8)
fn_end=$(echo $analyzed | cut -d' ' -f 11 | tr -d '.')

if [[ "$fn_start" != "1" || "$fn_end" != "$loc" ]]; then
  echo $fn_start $fn_end $loc
  echo "The source code should only contain a single function definition"
  exit 1
fi

echo "use libsql_bindgen::*;" > src/lib.rs
echo >> src/lib.rs
echo "#[libsql_bindgen::libsql_bindgen]" >> src/lib.rs
cat libsql-target/input.rs >> src/lib.rs

./get_sql.sh $fn_name
