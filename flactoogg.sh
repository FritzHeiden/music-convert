#! /bin/bash

force_rewrite=false
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

convert_flac() {
  source_file=$1
  dest_dir=$2
  basename=$3
  force_rewrite=$4
  if [[ ! "$source_file" =~ \.flac$ ]]; then
    return
  fi;

  outfile=$(echo "$source_file" | sed "s/flac$/ogg/")
  #outfile=$(echo "$source_file" | sed "s/flac$/ogg/" | sed -E "s|$basename||g")
    
  if [ -n "$dest_dir" ]; then
    outfile="$dest_dir/$outfile"
    outdir="$(echo "$outfile" | sed -E "s/(.*\/).*/\1/g")"
  fi;

  if [ -f "$outfile" ] && [ "$force_rewrite" = false ]; then
    echo "Skipping exisiting file $outfile";
    return;
  fi;

  mkdir -p "$outdir"
  echo "$outfile"
  ffmpeg -loglevel error -y -i "$source_file" -c:a libvorbis -q:a 5 -vn -map_metadata 0 "$outfile"
}
export -f convert_flac;

for var in "$@"
do
  if [[ "$var" = "-f" ]]; then
    force_rewrite=true;
  fi;
done

for var in "$@"
do
  if [[ $var = -* ]]; then
    continue;
  elif [[ "$var" = "$dest_dir" ]]; then
    continue;
  else
    basename="$(echo "$var" | sed -E "s/(.*\/).*/\1/g")"
    find "$var" -mindepth 1 -type f -exec bash -c 'convert_flac "$1" "$2" "$3" "$4"' -- {} "$dest_dir" "$basename" "$force_rewrite" \;
  fi;
done
