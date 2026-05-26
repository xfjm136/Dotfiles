#!/usr/bin/env bash

set -euo pipefail

wallpapers_dir="$HOME/Pictures/wallpaper/hyprland"

mapfile -t wallpapers < <(
    find "$wallpapers_dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        | sort
)

if (( ${#wallpapers[@]} == 0 )); then
    exit 0
fi

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

"$HOME/.config/hypr/wallpaper_apply.sh" "$random_wallpaper" \
    --transition-type any \
    --transition-duration 2
