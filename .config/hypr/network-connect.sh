#!/usr/bin/env bash

set -euo pipefail

private_env="$HOME/.config/private/wifi.env"

if [[ ! -f "$private_env" ]]; then
    echo "network-connect.sh: missing $private_env" >&2
    exit 0
fi

# shellcheck source=/dev/null
source "$private_env"

if [[ -z "${WIFI_SSID:-}" || -z "${WIFI_PASSWORD:-}" ]]; then
    echo "network-connect.sh: WIFI_SSID or WIFI_PASSWORD is missing" >&2
    exit 1
fi

if nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null \
    | awk -F: -v ssid="$WIFI_SSID" '$1 == "yes" && $2 == ssid { found = 1 } END { exit found ? 0 : 1 }'
then
    exit 0
fi

nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASSWORD"
