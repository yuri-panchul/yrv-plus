set -Eeuo pipefail  # See the meaning in scripts/README.md
# set -x  # Print each command

setup_source_bash_already_run=1

#-----------------------------------------------------------------------------

script=$(basename "$0")
log="$PWD/log.txt"

cd $(dirname "$0")
mkdir -p run
cd run

#-----------------------------------------------------------------------------

error ()
{
    printf "$script: error: $*\n" 1>&2
    exit 1
}

#-----------------------------------------------------------------------------

warning ()
{
    printf "$script: warning: $*\n" 1>&2
}

#-----------------------------------------------------------------------------

info ()
{
    printf "$script: $*\n" 1>&2
}

#-----------------------------------------------------------------------------

is_command_available ()
{
    command -v $1 &> /dev/null
}

#-----------------------------------------------------------------------------

is_command_available_or_error ()
{
    is_command_available $1 ||  \
        error "program $1$2 is not in the path or cannot be run$3"
}

#-----------------------------------------------------------------------------

is_command_available_or_error_and_sudo_apt_install ()
{
    if [ -n "$2" ]; then
        package=$2
    else
        package=$1
    fi

    is_command_available_or_error  \
        $1 "" ". To install run: sudo apt install $package"
}

#-----------------------------------------------------------------------------

design_dir=../../design

if ! [ -d $design_dir ]; then
    design_dir=../$design_dir
fi

if ! [ -d $design_dir ]; then
    error "cannot find design directory"
fi

design_dir=$(readlink -f "$design_dir")

if ! [ -d "$design_dir" ]; then
    error "design directory path \"$design_dir\" is broken"
fi

#-----------------------------------------------------------------------------

external_dir="$design_dir/../external"
mkdir -p "$external_dir"

external_dir=$(readlink -f "$external_dir")

if ! [ -d "$external_dir" ]; then
    error "external directory path \"$external_dir\" is broken"
fi

#-----------------------------------------------------------------------------

scripts_dir=$(readlink -f "$design_dir/../scripts")

if ! [ -d "$scripts_dir" ]; then
    error "scripts directory path \"$scripts_dir\" is broken"
fi

#-----------------------------------------------------------------------------


if [ -z ${INTELFPGA_INSTALL_DIR+x} ] 
then 
    echo "Quartus installetion directory is not set." 
    INTELFPGA_INSTALL_DIR=intelFPGA_lite
else 
    echo "Quartus package installation directory '$INTELFPGA_INSTALL_DIR'"; 
fi

QUESTA_DIR=questa_fse
QUARTUS_DIR=quartus

if [ "$OSTYPE" = "linux-gnu" ]
then
    INTELFPGA_INSTALL_PARENT_DIR="$HOME"

    QUESTA_BIN_DIR=bin
    QUESTA_LIB_DIR=linux_x86_64

    if [ -z "${LM_LICENSE_FILE-}" ]
    then
        export LM_LICENSE_FILE=$HOME/flexlm/license.dat
    fi

    QUARTUS_BIN_DIR=bin

elif  [ "$OSTYPE" = "cygwin"    ]  \
   || [ "$OSTYPE" = "msys"      ]
then
    INTELFPGA_INSTALL_PARENT_DIR=/c

    QUESTA_BIN_DIR=win64
    QUESTA_LIB_DIR=win64

    if [ -z "{$LM_LICENSE_FILE-}" ]
    then
        export LM_LICENSE_FILE=/c/flexlm/license.dat
    fi

    QUARTUS_BIN_DIR=bin64
else
    error "this script does not support your OS '$OSTYPE'"
fi

if ! [ -d "$INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR" ]
then
    error "expected to find '$INTELFPGA_INSTALL_DIR' directory"  \
          " in '$INTELFPGA_INSTALL_PARENT_DIR'"
fi

#-----------------------------------------------------------------------------

# A workaround for a find problem when running bash under Microsoft Windows

find_to_run=find
true_find=/usr/bin/find

if [ -x "$true_find" ]
then
    find_to_run="$true_find"
fi

#-----------------------------------------------------------------------------

FIND_COMMAND="$find_to_run $INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR -mindepth 1 -maxdepth 1 -type d -print"
FIRST_VERSION_DIR=$($FIND_COMMAND -quit)

if [ -z "$FIRST_VERSION_DIR" ]
then
    error "cannot find any version of Intel FPGA installed in "  \
          "'$INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR'"
fi

#-----------------------------------------------------------------------------

export QUESTA_ROOTDIR="$FIRST_VERSION_DIR/$QUESTA_DIR"

if [ -z "${PATH-}" ]
then
    export PATH="$QUESTA_ROOTDIR/$QUESTA_BIN_DIR"
else
    export PATH="$PATH:$QUESTA_ROOTDIR/$QUESTA_BIN_DIR"
fi

if [ -z "${LD_LIBRARY_PATH-}" ]
then
    export LD_LIBRARY_PATH="$QUESTA_ROOTDIR/$QUESTA_LIB_DIR"
else
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$QUESTA_ROOTDIR/$QUESTA_LIB_DIR"
fi

export QUARTUS_ROOTDIR="$FIRST_VERSION_DIR/$QUARTUS_DIR"
export PATH="$PATH:$QUARTUS_ROOTDIR/$QUARTUS_BIN_DIR"

#-----------------------------------------------------------------------------

ALL_VERSION_DIRS=$($FIND_COMMAND | xargs echo)

if [ "$FIRST_VERSION_DIR" != "$ALL_VERSION_DIRS" ]
then
    warning 1 "multiple Intel FPGA versions installed in"  \
            "'$INTELFPGA_INSTALL_PARENT_DIR/$INTELFPGA_INSTALL_DIR':"  \
            "'$ALL_VERSION_DIRS'"

    info "QUESTA_ROOTDIR=$QUESTA_ROOTDIR"
    info "QUARTUS_ROOTDIR=$QUARTUS_ROOTDIR"
    info "PATH=$PATH"
    info "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

                   [ -d "$QUESTA_ROOTDIR" ]  \
    || error "directory '$QUESTA_ROOTDIR' expected"

                   [ -d "$QUESTA_ROOTDIR/$QUESTA_BIN_DIR" ]  \
    || error "directory '$QUESTA_ROOTDIR/$QUESTA_BIN_DIR' expected"

                   [ -d "$QUARTUS_ROOTDIR" ]  \
    || error "directory '$QUARTUS_ROOTDIR' expected"

                   [ -d "$QUARTUS_ROOTDIR/$QUARTUS_BIN_DIR" ]  \
    || error "directory '$QUARTUS_ROOTDIR/$QUARTUS_BIN_DIR' expected"
fi

#-----------------------------------------------------------------------------

rars=rars1_5.jar
rars_version=v1.5

rars_path="$external_dir/$rars"

#-----------------------------------------------------------------------------

program_mem32=program.mem32
demo_program_mem32=code_demo.mem32

cp "$design_dir"/code_demo.mem* .
