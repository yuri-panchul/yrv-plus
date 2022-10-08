#!/usr/bin/env bash

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
  rm -rf a.out
}

rm -rf log.txt

iverilog -g2005-sv -I ../rtl *.sv 2>&1 | tee "$log"
vvp a.out                         2>&1 | tee "$log"
gtkwave dump.vcd
