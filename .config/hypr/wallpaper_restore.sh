#!/usr/bin/env bash

set -euo pipefail

wallpapers_dir="$HOME/Pictures/wallpaper/hyprland"
cache_dir="$HOME/.cache/awww"
state_file="$cache_dir/last_wallpaper"
default_wallpaper="$HOME/Pictures/wallpaper/hyprland/wallhaven-6o6orw.png"

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
