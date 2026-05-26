#!/usr/bin/env bash

set -euo pipefail

target_connection="YNU"
target_ssid="YNU"
wifi_device="wlan0"

if ! command -v nmcli >/dev/null 2>&1; then
    exit 0
fi

if ! nmcli -t -f DEVICE,TYPE device status | grep -q "^${wifi_device}:wifi$"; then
    exit 0
fi

current_ssid="$(
    nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null \
        | awk -F: '$1 == "yes" { print $2; exit }'
)"

if [[ "$current_ssid" == "$target_ssid" ]]; then
    exit 0
fi

if ! nmcli -t -f NAME connection show | grep -Fxq "$target_connection"; then
    exit 0
fi

nmcli connection up "$target_connection" ifname "$wifi_device" >/dev/null 2>&1 || true
