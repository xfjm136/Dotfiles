#!/usr/bin/env bash

set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
wallpapers_dir="$script_dir/wallpapers"

if [[ ! -d "$wallpapers_dir" ]]; then
    wallpapers_dir="$HOME/Pictures/wallpaper/hyprland"
fi

mapfile -t wallpapers < <(
    find "$wallpapers_dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        | sort
)

if (( ${#wallpapers[@]} == 0 )); then
    exit 0
fi

transitions=(
    "simple"
    "fade"
    "left"
    "right"
    "top"
    "bottom"
    "wipe"
    "grow"
    "center"
    "outer"
    "wave"
)

current_wallpaper="$(
    awww query 2>/dev/null | awk -F'image: ' '/image:/ {print $2; exit}'
)"

candidates=()
for wallpaper_path in "${wallpapers[@]}"; do
    if [[ "$wallpaper_path" != "$current_wallpaper" ]]; then
        candidates+=("$wallpaper_path")
    fi
done

if (( ${#candidates[@]} == 0 )); then
    candidates=("${wallpapers[@]}")
fi

random_wallpaper="${candidates[RANDOM % ${#candidates[@]}]}"
random_transition="${transitions[RANDOM % ${#transitions[@]}]}"
duration="$(awk -v min=0.3 -v max=1.5 'BEGIN{srand(); print min+rand()*(max-min)}')"

awww img "$random_wallpaper" \
    --transition-type "$random_transition" \
    --transition-duration "$duration" \
    --transition-fps 60
