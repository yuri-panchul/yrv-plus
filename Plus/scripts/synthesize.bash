#!/usr/bin/env bash

set -Eeuxo pipefail  # See the meaning in scripts/README.md
. $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/setup.source.bash

>top.qpf
cp $rtl_dir/*.mem ../*.qsf .

is_command_available_or_error quartus_sh " from Intel FPGA Quartus Prime package"

if ! quartus_sh --no_banner --flow compile top 2>&1 | tee syn.log
then
    grep -i -A 5 error syn.log 2>&1
    error 1 "synthesis failed"
fi

./x.configure.bash
