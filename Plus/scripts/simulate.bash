#!/usr/bin/env bash

set -ex  # Exit on non-zero status and print each command

script=$(basename $0)
setup=scripts/setup.source.bash

   [ -f ../../$setup ] && . ../../$setup \
|| [ -f    ../$setup ] && .    ../$setup \
|| (printf "$script: cannot find $setup\n" 1>&2; exit 1)

#-----------------------------------------------------------------------------

   cp "../${hex_file:=code_demo.mem}" . \
|| cp "../../rtl/$hex_file"           .

iverilog -g2005-sv  \
  -D INTEL_VERSION  \
  -I $rtl_dir       \
  ../*.sv           \
  2>&1 | tee "$log"

vvp a.out 2>&1 | tee "$log"

#-----------------------------------------------------------------------------

gtkwave_script=../xx.gtkwave.tcl
gtkwave_options=

if [ -f $gtkwave_script ]; then
  gtkwave_options="--script $gtkwave_script"
fi

gtkwave dump.vcd $gtkwave_options
