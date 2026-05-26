#!/usr/bin/env bash

set -euo pipefail

wallpapers_dir="$HOME/Pictures/wallpaper/hyprland"

mapfile -t wallpaper_paths < <(
    find "$wallpapers_dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        | sort
)

if (( ${#wallpaper_paths[@]} == 0 )); then
    exit 0
fi

selected_wallpaper=""

if command -v rofi >/dev/null 2>&1; then
    rofi_theme="$HOME/.config/rofi/config.rasi"
    selected_wallpaper="$(
        for wallpaper_path in "${wallpaper_paths[@]}"; do
            printf '%s\0icon\x1f%s\n' "$(basename "${wallpaper_path%.*}")" "$wallpaper_path"
        done | rofi -show-icons -dmenu -theme "$rofi_theme" -p " "
    )"
else
    selected_wallpaper="$(
        printf '%s\n' "${wallpaper_paths[@]}" \
            | while IFS= read -r wallpaper_path; do
                basename "${wallpaper_path%.*}"
            done \
            | fuzzel --dmenu --prompt="wallpaper> "
    )"
fi

if [[ -z "$selected_wallpaper" ]]; then
    exit 0
fi

image_fullname_path="$(
    find "$wallpapers_dir" -maxdepth 1 -type f -name "$selected_wallpaper.*" | head -n 1
)"

if [[ -z "$image_fullname_path" || ! -f "$image_fullname_path" ]]; then
    exit 1
fi

"$HOME/.config/hypr/wallpaper_apply.sh" "$image_fullname_path" \
    --transition-type any \
    --transition-duration 2
