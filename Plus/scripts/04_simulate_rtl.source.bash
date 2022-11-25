. $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/00_setup.source.bash

#-----------------------------------------------------------------------------

is_command_available_or_error_and_sudo_apt_install iverilog

iverilog -g2005-sv    \
    -D INTEL_VERSION  \
    -I $design_dir    \
    ../*.sv           \
    2>&1 | tee "$log"

vvp a.out 2>&1 | tee "$log"

#-----------------------------------------------------------------------------

is_command_available_or_error_and_sudo_apt_install gtkwave

gtkwave_script=../xx.gtkwave.tcl
gtkwave_options=

if [ -f $gtkwave_script ]; then
    gtkwave_options="--script $gtkwave_script"
fi

gtkwave dump.vcd $gtkwave_options
