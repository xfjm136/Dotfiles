#!/usr/bin/env bash
set -euo pipefail
operation="${1:-}"
workspace="${2:-}"
# Only accept a positive integer; never interpolate arbitrary Lua input.
if [[ ! "$workspace" =~ ^[1-9][0-9]*$ ]]; then
    echo "Usage: $0 {switch|move} <workspace-number>" >&2
    exit 2
fi
case "$operation" in
    switch) exec hyprctl dispatch "hl.dsp.focus({ workspace = $workspace })" ;;
    move) exec hyprctl dispatch "hl.dsp.window.move({ workspace = $workspace })" ;;
    *) echo "Unknown operation: $operation" >&2; exit 2 ;;
esac
