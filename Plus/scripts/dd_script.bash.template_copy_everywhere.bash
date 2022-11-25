#!/usr/bin/env bash

set -Eeuo pipefail  # See the meaning in scripts/README.md
# set -x  # Print each command

script=$(basename "$0")
dirname=$(dirname "$0")

if [ "$dirname" != "." ]; then
    printf "$script: this script should be run from its directory\n" 1>&2
    exit 1
fi

find_command="find .. -name '[0-9][0-9]_*.bash' -not -path '../scripts/*'"
eval "$find_command"

read -p "Are you sure to overwrite all the files above? " -n 1 -r
printf "\n"

if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    # -n max-args,  --max-args=max-args
    # -r,           --no-run-if-empty    (GNU extension)
    eval "$find_command" | xargs -n 1 -r cp dd_script.bash.template
else
    printf "$script: nothing is copied\n" 1>&2
    exit 1
fi

exit 0
