#!/bin/bash

if ! which tageditor > /dev/null ; then
  echo "'tageditor' not found"
  exit 1
fi;

dest_dir=""
args=("$@")

for (( i=$#-1 ; i>=0 ; i-- )) ; do
	arg=${args[$i]};
	if [[ $arg == -* ]]; then
		continue;
	fi;
	dest_dir=$arg;
	break;
done

copy_tags() {
  source_file=$1
  dest_dir=$2
  basename=$3
  if [[ ! "$source_file" =~ \.flac$ ]]; then
    return
  fi;
  dest_file="$(echo "$source_file" | sed "s/flac$/mp3/")"
  #dest_file="$(echo "$source_file" | sed "s/flac$/mp3/" | sed -E "s|$basename||g")"
  echo "$dest_file"
  if [ -n "$dest_dir" ]; then
    dest_file="$dest_dir/$dest_file"
  fi;
  tags=$(tageditor get -u -f "$source_file" \
    | sed -nE "/(Title  |Album  |Artist  |Track  |Record date  |Album artist  |REPLAYGAIN_TRACK_GAIN|REPLAYGAIN_TRACK_PEAK).*/p" \
    | sed -E 's/Title\s{2,}(.+)/title="\1"/g' \
    | sed -E 's/Album\s{2,}(.+)/album="\1"/g' \
    | sed -E 's/Artist\s{2,}(.+)/artist="\1"/g' \
    | sed -E 's/Track\s{2,}(.+)/track="\1"/g' \
    | sed -E 's/Record date\s{2,}(.+)/recorddate="\1"/g' \
    | sed -E 's/Album artist\s{2,}(.+)/albumartist="\1"/g' \
    | sed -E 's/(REPLAYGAIN_TRACK_GAIN) (.+)/vorbis:\1="\2"/g' \
    | sed -E 's/(REPLAYGAIN_TRACK_PEAK) (.+)/vorbis:\1="\2"/g' \
    | sed -E 's/(TRACKTOTAL)\s{2,}(.+)/vorbis:\1="\2"/g' \
    | tr "\n" " ")

  coverpath="$(echo "$source_file" | sed -E "s/(.*\/).*/\1/g")cover.jpg"
  if [[ $coverpath != *"/"* ]]; then
    coverpath="cover.jpg"
  fi
  #echo "cover $coverpath"
  if [ ! -f "$coverpath" ]; then
    tageditor extract cover -f "$source_file" -o "$coverpath"
  fi
  if [ ! -f "$coverpath" ]; then
    alt_coverpath=$(ls -1 "$(echo "$source_file" | sed -E "s/(.*\/).*/\1/g")"cover-Vorbis*.jpg)
    mv "$alt_coverpath" "$coverpath"
  fi
  if [ ! -f "$coverpath" ]; then
    alt_coverpath=$(ls -1 "$(echo "$source_file" | sed -E "s/(.*\/).*/\1/g")"cover*.jpg)
    mv "$alt_coverpath" "$coverpath"
  fi
  #coverpath=$(echo $coverpath | sed -E "s|'|\\\'|g")
  tags=$tags' cover"='$coverpath'"'
  tags=$(echo $tags | sed -E "s|\\$|\\\\\\$|g")
  OLD_IFS="$IFS"
  IFS=
  dest_file=$(echo "$dest_file" | sed -E "s|\\$|\\\\\\$|g")
  command="tageditor set $tags -f \"$dest_file\""
  eval $command
  IFS="$OLD_IFS"
  backup_file="$dest_file.bak"
  if [ -f "$backup_file" ]; then
    rm "$dest_file.bak"
  fi;
}
export -f copy_tags;

for var in "$@"
do
  if [[ "$var" = "$dest_dir" ]]; then
    continue;
  else
    basename="$(echo "$var" | sed -E "s/(.*\/).*/\1/g")"
    if [ -d "$var" ]; then
      find "$var" -mindepth 1 -type f -exec bash -c 'copy_tags "$1" "$2" "$3"' -- {} "$dest_dir" "$basename" \;
    else
      echo "$var"
      copy_tags "$var" "$dest_dir"
    fi
  fi;
done
