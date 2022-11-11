#!/usr/bin/env bash

# See the decription of these settings in scripts/README.md file
set -Eeuxo pipefail

cd "$(dirname $0)"
rm -rf log.txt run
