copy_tags() {
  echo $1
  echo $2
	if [[ ! "$1" =~ \.flac$ ]]; then
    return
  fi;
  oggfile="$(echo $1 | sed "s/flac$/ogg/")"
  if [ -n "$2" ]; then
    oggfile="$2/$oggfile"
  fi;
  tags=$(tageditor get -u -f "$1" | sed "/Cover/d" | grep -E "^\s{4}\w" \
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

  coverpath=$(echo "$(echo "$1" | sed -E "s/(.*\/).*/\1/g")cover.jpg")
  if [[ $coverpath != *"/"* ]]; then
    coverpath="cover.jpg"
  fi
  echo "cover $coverpath"
  if [ ! -f "$coverpath" ]; then
    tageditor extract cover -f "$1" -o "$coverpath"
  fi
  
  tags=$(echo $tags)
  tags="$tags cover'=$coverpath'"
  command=$(echo "tageditor set $tags -f \"$oggfile\"")
  eval $command
  rm "$oggfile.bak"
}
export -f copy_tags;
if [ -d "$1" ]; then
  find "$1" -mindepth 1 -type f -exec bash -c "copy_tags \"{}\" \"$2\"" \;
else
  echo $1
  copy_tags "$1" "$2"
fi
