#!/bin/bash
# Rename torrent files based on the "name" field in the torrent file
# Usage: ./rename_files.sh [folder_path]

FOLDER="${1:-.}"

for file in "$FOLDER"/*.torrent "$FOLDER"/*.TORRENT; do
    [ -f "$file" ] || continue
    match=$(cat "$file" | grep -a -o '4:name[0-9]*:' | head -1)
    [ -z "$match" ] && continue
    len=$(echo "$match" | sed 's/4:name\([0-9]*\):/\1/')
    [ -z "$len" ] && continue
    pos=$(cat "$file" | grep -a -b -o "$match" | head -1 | cut -d: -f1)
    value_start=$((pos + ${#match}))
    new_name=$(dd if="$file" bs=1 skip=$value_start count=$len 2>/dev/null | tr -d '\0')
    new_name=$(echo "$new_name" | sed 's/[<>:"/\\|?*]/-/g' | sed 's/  */ /g')
    new_file="$FOLDER/${new_name}.torrent"
    [ -n "$new_name" ] && mv "$file" "$new_file" 2>/dev/null && echo "Renamed: $(basename "$file") -> $(basename "$new_file")"
done

