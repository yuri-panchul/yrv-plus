#!/usr/bin/env bash

set -ex  # Exit on non-zero status and print each command

script=$(basename $0)
setup=scripts/x.setup.source.bash

pwd

   [ -f ../../$setup ] && . ../../$setup \
|| [ -f    ../$setup ] && .    ../$setup \
|| (printf "$script: cannot find $setup\n" 1>&2; exit 1)

