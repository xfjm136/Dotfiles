#!/usr/bin/env bash

set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
wallpapers_dir="$script_dir/wallpapers"
cache_dir="$HOME/.cache/awww"
state_file="$cache_dir/last_wallpaper"

if [[ ! -d "$wallpapers_dir" ]]; then
    wallpapers_dir="$HOME/Pictures/wallpaper/hyprland"
fi

default_wallpaper="$wallpapers_dir/wallhaven-6o6orw.png"

wallpaper_path=""

if [[ -f "$state_file" ]]; then
    wallpaper_path="$(<"$state_file")"
fi

if [[ -z "$wallpaper_path" || ! -f "$wallpaper_path" ]]; then
    wallpaper_path="$default_wallpaper"
fi

if [[ ! -f "$wallpaper_path" ]]; then
    wallpaper_path="$(
        find "$wallpapers_dir" -maxdepth 1 -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
            | sort | head -n 1
    )"
fi

if [[ -z "$wallpaper_path" || ! -f "$wallpaper_path" ]]; then
    exit 0
fi

"$HOME/.config/hypr/wallpaper_apply.sh" "$wallpaper_path" --transition-type none --transition-duration 0
