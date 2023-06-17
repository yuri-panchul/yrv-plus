. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/00_setup.source.bash"

dev=/dev/ttyUSB0
[ -e $dev ] || error "USB-to-UART $dev is not connected or is not working"
dev_grp=$(stat -c "%G" $dev)
[ -n "${dev_grp-}" ] || error "Cannot determine the groups that owns $dev"

# id
#
# -G, --groups  print all group IDs
# -n, --name    print a name instead of a number, for -ugG
#
# grep
#
# -w, --word-regexp      match only whole words
# -q, --quiet, --silent  suppress all normal output

if ! id -nG | grep -qw $dev_grp
then
    error "User \"$USER\" is not in \"$dev_grp\" group."  \
          "Run: \"sudo usermod -a -G $dev_grp $USER\","   \
          "then reboot and try again."                    \
          "(On some systems it is sufficient"             \
          "to logout and login instead of the reboot)."
fi

   stty -F $dev raw speed 115200 -crtscts cs8 -parenb -cstopb > /dev/null  \
|| error "USB-to-UART is not working"

if [ -f $program_mem32 ]; then
    cat $program_mem32 > $dev
else
    warning "Cannot find \"$program_mem32\", use \"$demo_program_mem32\" instead."
    cat $demo_program_mem32 > $dev
fi
