#
#  set -e           - Exit immediately if a command exits with a non-zero
#                     status.  Note that failing commands in a conditional
#                     statement will not cause an immediate exit.
#
#  set -o pipefail  - Sets the pipeline exit code to zero only if all
#                     commands of the pipeline exit successfully.
#
#  set -u           - Causes the bash shell to treat unset variables as an
#                     error and exit immediately.
#
#  set -x           - Causes bash to print each command before executing it.
#
#  set -E           - Improves handling ERR signals
#

set -Eeuxo pipefail

script=$(basename "$0")
log="$PWD/log.txt"

cd $(dirname "$0")
mkdir -p run
cd run

//----------------------------------------------------------------------------

error ()
{
  printf "$script: $*\n" 1>&2
  exit 1
}

//----------------------------------------------------------------------------

rtl_dir=../../rtl

if ! [ -d $rtl_dir ]; then
  rtl_dir=../$rtl_dir
fi

if ! [ -d $rtl_dir ]; then
  error "cannot find rtl directory"
fi
