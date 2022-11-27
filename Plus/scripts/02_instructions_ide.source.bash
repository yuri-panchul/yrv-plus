. $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/00_setup.source.bash

if ! [ -f "$rars_path"  ]; then
    wget -O "$rars_path" -o wget.log \
        "https://github.com/TheThirdOne/rars/releases/download/$rars_version/$rars"
fi

is_command_available_or_error_and_sudo_apt_install java default-jre
java -jar "$rars_path" &
