#!/usr/bin/env bash

hex_file=code_demo.mem

script_path="$0"
script=$(basename "$script_path")
script_dir=$(dirname "$script_path")

error ()
{
  printf "$script: $*\n" 1>&2
  exit 1
}

run_dir="$PWD"
log="$run_dir/log.txt"

cd "$script_dir" \
  || error "cannot cd \"$script_dir\""

. ../scripts/setup.source.bash

trap cleanup SIGINT SIGTERM ERR EXIT

cleanup ()
{
  trap - SIGINT SIGTERM ERR
  rm -rf run
}

rm -rf log.txt run
mkdir run
cd run

   cp "../$hex_file"         . \
|| cp "../../rtl/$hex_file"  .

iverilog -g2005-sv     \
  -D INTEL_VERSION     \
  -I ../../rtl         \
  ../../rtl/yrv_mcu.v  \
  ../*.sv              \
  2>&1 | tee "$log"

vvp a.out 2>&1 \
  | tee "$log"

gtkwave dump.vcd
