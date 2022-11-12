#!/usr/bin/env bash

set -ex  # Exit on non-zero status and print each command

script=$(basename $0)
setup=../scripts/setup.source.bash

  if [ -f ../../$setup ] ; then . ../../$setup
elif [ -f    ../$setup ] ; then .    ../$setup
elif [ -f       $setup ] ; then .       $setup
else
  printf "$script: cannot find $setup\n" 1>&2
  exit 1
fi

#-----------------------------------------------------------------------------

>top.qpf
cp $rtl_dir/*.mem ../*.qsf .

#-----------------------------------------------------------------------------

is_command_available_or_error quartus_sh " from Intel FPGA Quartus II package"

if ! quartus_sh --no_banner --flow compile top 2>&1 | tee syn.log
then
    ec=$?
    echo "ERROR CODE $ec"
    grep -i -A 5 error syn.log 2>&1
    error $ec "synthesis failed"
fi

#-----------------------------------------------------------------------------

./configure.bash
