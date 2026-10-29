#!/usr/bin/env bash

set -euo pipefail

cache_dir="$HOME/.cache/awww"
state_file="$cache_dir/last_wallpaper"
link_path="$cache_dir/current_wallpaper"

mkdir -p "$cache_dir"

current_wallpaper_path="$(
    awww query 2>/dev/null | awk -F'image: ' '/image:/ {print $2; exit}'
)"

if [[ -z "$current_wallpaper_path" || ! -f "$current_wallpaper_path" ]]; then
    echo "wallpaper_effects.sh: unable to resolve current wallpaper" >&2
    exit 1
fi

printf '%s\n' "$current_wallpaper_path" > "$state_file"
ln -sfn "$current_wallpaper_path" "$link_path"
