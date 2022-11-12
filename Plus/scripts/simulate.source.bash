. $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/setup.source.bash

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
