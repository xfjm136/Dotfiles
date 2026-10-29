#!/usr/bin/env bash

set -euo pipefail

wallpaper_path="${1:-}"
shift || true

if [[ -z "$wallpaper_path" || ! -f "$wallpaper_path" ]]; then
    echo "wallpaper_apply.sh: wallpaper file not found: $wallpaper_path" >&2
    exit 1
fi

attempt=0
until awww img "$wallpaper_path" "$@"; do
    attempt=$((attempt + 1))
    if (( attempt >= 10 )); then
        echo "wallpaper_apply.sh: failed to apply wallpaper after $attempt attempts" >&2
        exit 1
    fi
    sleep 0.2
done

"$HOME/.config/hypr/wallpaper_effects.sh"
