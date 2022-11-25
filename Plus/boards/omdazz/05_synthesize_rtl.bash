#!/usr/bin/env bash

set -Eeuo pipefail  # See the meaning in scripts/README.md

script=$(basename "$0")
source_script=${script/\.bash/.source.bash}
dir_source_script=../scripts/$source_script

if ! [ -f $dir_source_script ]; then
    dir_source_script=../$dir_source_script
fi

if ! [ -f $dir_source_script ]; then
    dir_source_script=../$dir_source_script
fi

if ! [ -f $dir_source_script ]; then
    printf "$script: cannot find \"$source_script\"\n" 1>&2
    exit 1
fi

. "$(readlink -f $dir_source_script)"
