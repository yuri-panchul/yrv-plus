[ -z "${setup_source_bash_already_run-}" ] && \
. $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/setup.source.bash

is_command_available_or_error quartus_pgm " from Intel FPGA Quartus Prime package"

killall jtagd 2>/dev/null || true

quartus_pgm -l &> cable_list

CABLE_NAME_1=$(set +o pipefail; grep "1) " cable_list | sed 's/1) //')
CABLE_NAME_2=$(set +o pipefail; grep "2) " cable_list | sed 's/2) //')

if [ -n "$CABLE_NAME_1" ]
then
    if [ -n "$CABLE_NAME_2" ]
    then
        warning "more than one cable is connected: $CABLE_NAME_1 and $CABLE_NAME_2"
    fi

    info "using cable $CABLE_NAME_1"
    quartus_pgm --no_banner -c "$CABLE_NAME_1" --mode=jtag -o "P;top.sof"
else
    error 1 "cannot detect a USB-Blaster cable connected"
fi

rm cable_list
