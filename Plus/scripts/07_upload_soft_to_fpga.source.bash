. $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/00_setup.source.bash

program=program.mem

   cp "${hex_file:=code_demo.mem32}" $program &> /dev/null \
|| cp "../$hex_file"                 $program &> /dev/null \
|| cp "$design_dir/$hex_file"        $program &> /dev/null \
\
|| error "Cannot find \"$hex_file\""    \
         "neither in $(readlink -f .)"  \
         "nor in $(readlink -f ..)"     \
         "nor in $(readlink -f $design_dir)"

# id
#
# -G, --groups  print all group IDs
# -n, --name    print a name instead of a number, for -ugG
#
# grep
#
# -w, --word-regexp      match only whole words
# -q, --quiet, --silent  suppress all normal output

gr=dialout

if ! id -nG | grep -qw $gr
then
  error "User \"$USER\" is not in \"$gr\" group."  \
     "Run: \"sudo usermod -a -G $gr $USER\","      \
     "then logout, login and try again."
fi

dev=/dev/ttyUSB0

stty -F $dev raw speed 115200 -crtscts cs8 -parenb -cstopb &> /dev/null
cat $program > $dev
