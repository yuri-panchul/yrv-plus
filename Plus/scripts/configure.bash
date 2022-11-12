#!/usr/bin/env bash

set -ex  # Exit on non-zero status and print each command

script=$(basename $0)
setup=../scripts/setup.source.bash

   [ -f ../../$setup ] && . ../../$setup \
|| [ -f    ../$setup ] && .    ../$setup \
|| [ -f       $setup ] && .       $setup \
|| (printf "$script: cannot find $setup\n" 1>&2; exit 1)

#-----------------------------------------------------------------------------

is_command_available_or_error quartus_pgm " from Intel FPGA Quartus Prime package"

killall jtagd 2>/dev/null

quartus_pgm -l &> cable_list

CABLE_NAME_1=$(grep "1) " cable_list | sed 's/1) //')
CABLE_NAME_2=$(grep "2) " cable_list | sed 's/2) //')

if [ "$CABLE_NAME_1" ]
then
    if [ "$CABLE_NAME_2" ]
    then
        warning "more than one cable is connected: $CABLE_NAME_1 and $CABLE_NAME_2"
    fi

    info "using cable $CABLE_NAME_1"
    quartus_pgm --no_banner -c \""$CABLE_NAME_1"\" --mode=jtag -o \""P;top.sof"\"
else
    error 1 "cannot detect a USB-Blaster cable connected"
fi

rm cable_list
