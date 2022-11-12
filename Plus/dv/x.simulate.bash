#!/usr/bin/env bash

set -ex  # Exit on non-zero status and print each command

extra_var=extra_val

. "($realpath $(dirname $0))/../scripts/x.simulate.bash"
