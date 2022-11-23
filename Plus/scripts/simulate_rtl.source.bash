. $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/setup.source.bash

#-----------------------------------------------------------------------------

if [ -n "${hex_file-}" ]; then
  cp "$hex_file" .
else
  cp "$rtl_dir"/code_demo.mem* .
fi

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
