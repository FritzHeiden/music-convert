#!/bin/bash

if ! which tageditor > /dev/null ; then
  echo "'tageditor' not found"
  exit 1
fi;
if ! which loudgain > /dev/null ; then
  echo "'loudgain' not found"
  exit 1
fi;

force_rewrite=false

for var in "$@"
do
  if [[ "$var" = "-f" ]]; then
    force_rewrite=true;
  fi;
done

calc_gain() {
  source_file=$1
  force_rewrite=$2
  if [[ ! "$source_file" =~ \.flac$ ]]; then
    return
  fi;
  tags=$(tageditor get -u -f "$source_file")
  has_track_gain=false
  has_track_peak=false
  if [[ $tags == *"REPLAYGAIN_TRACK_GAIN"* ]]; then
    has_track_gain=true;
  fi;
  if [[ $tags == *"REPLAYGAIN_TRACK_PEAK"* ]]; then
    has_track_peak=true;
  fi;

  if [[ $has_track_gain == true && $has_track_peak == true && $force_rewrite == false ]]; then
    return;
  fi;
  loudgain -r -s i "$source_file"
}
export -f calc_gain;
if [ -d "$1" ]; then
  find "$1" -mindepth 1 -type f -exec bash -c 'calc_gain "$0" $1' {} $force_rewrite \;
else
  calc_gain "$1"
fi
