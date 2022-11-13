. $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/setup.source.bash

   cp "../${hex_file:=code_demo.1mem}" .               \
|| cp "$rtl_dir/$hex_file"            .               \
                                                      \
|| error "Cannot find \"$hex_file\""                  \
         "neither in $(dirname $(readlink -f ..))"    \
         "nor in $(dirname $(readlink -f $rtl_dir))"

exit

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

cat 
for i in {0..300}
do
  echo 12345678 > $dev
done
