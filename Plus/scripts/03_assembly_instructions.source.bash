. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/00_setup.source.bash"

#  nc                                 - Copyright notice will not be displayed
#  a                                  - assembly only, do not simulate
#  ae<n>                              - terminate RARS with integer exit code if an assemble error occurs
#  dump .text HexText $program_mem32  - dump segment .text to $program_mem32 file in HexText format

rars_args="nc a ae1 dump .text HexText $program_mem32 ../program.S"

if is_command_available rars
then
    rars $rars_args
else
    if ! [ -f "$rars_path"  ]; then
        wget -O "$rars_path" -o wget.log \
            "https://github.com/TheThirdOne/rars/releases/download/$rars_version/$rars"
    fi

    is_command_available_or_error_and_install java default-jre
    java -jar "$rars_path" $rars_args
fi
