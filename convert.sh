#! /bin/bash

# Arguments
# -f Force rewrite
# -c Convert files
# -t Copy tags
# -g Calculate ReplayGain

# Set constants
OPUS_DIRECTORY="./opus"
OGG_DIRECTORY="./ogg"
MP3_DIRECTORY="./mp3"

# Set defaults
force_rewrite=false
convert=false
copy_tags=false
calc_gain=false
src_dir=""
args=("$@")

# Get arguments without leading dash (-)
for ((i = $# - 1; i >= 0; i--)); do
    arg=${args[$i]}
    if [[ $arg == -* ]]; then
        continue
    fi
    src_dir=$arg
    break
done

# Get arguments with leading dash
params=""
for var in "$@"; do
    if [[ "$var" = "-f" ]]; then
        force_rewrite=true
        params="$params -f"
    fi
    if [[ "$var" = "-c" ]]; then
        convert=true
    fi
    if [[ "$var" = "-t" ]]; then
        copy_tags=true
    fi
    if [[ "$var" = "-g" ]]; then
        calc_gain=true
    fi
done

# Calc ReplayGain

if [ "$calc_gain" == true ]; then
    echo
    echo Calculating ReplayGain ...
    echo
    command="$(dirname $0)/calcgain.sh '$src_dir'$params"
    echo $command
    eval $command
fi

# Convert to opus

if [ "$convert" == true ]; then
    echo
    echo Converting to OPUS ...
    echo
    command="$(dirname $0)/flactoopus.sh '$src_dir' '$OPUS_DIRECTORY'$params"
    echo $command
    eval $command
fi

if [ "$copy_tags" == true ]; then
    echo
    echo Copying tags ...
    echo
    command="$(dirname $0)/copytagsopus.sh '$src_dir' '$OPUS_DIRECTORY'"
    echo $command
    eval $command
fi

# Convert to ogg

if [ "$convert" == true ]; then
    echo
    echo Converting to OGG ...
    echo
    command="$(dirname $0)/flactoogg.sh '$src_dir' '$OGG_DIRECTORY'$params"
    echo $command
    eval $command
fi

if [ "$copy_tags" == true ]; then
    echo
    echo Copying tags ...
    echo
    command="$(dirname $0)/copytagsogg.sh '$src_dir' '$OGG_DIRECTORY'"
    echo $command
    eval $command
fi

# Convert to mp3

if [ "$convert" == true ]; then
    echo
    echo Converting to MP3 ...
    echo
    command="$(dirname $0)/flactomp3.sh '$src_dir' '$MP3_DIRECTORY'$params"
    echo $command
    eval $command
fi

if [ "$copy_tags" == true ]; then
    echo
    echo Copying tags ...
    echo
    command="$(dirname $0)/copytagsmp3.sh '$src_dir' '$MP3_DIRECTORY'"
    echo $command
    eval $command
fi
