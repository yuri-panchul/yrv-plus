scripts_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
. "$scripts_dir/00_setup.source.bash"

>top.qpf
cp ../*.qsf .

if [ -n "${hex_file-}" ]; then
  cp "$hex_file" .
else
  cp "$design_dir/code_demo.mem32" .
fi

is_command_available_or_error quartus_sh " from Intel FPGA Quartus Prime package"

if ! quartus_sh --no_banner --flow compile top 2>&1 | tee syn.log
then
    grep -i -A 5 error syn.log 2>&1
    error "synthesis failed"
fi

. "$scripts_dir/configure_fpga.source.bash"
