#!/bin/bash

operation=$1
workspace=$2

echo "Final Operation: $operation to workspace $workspace"

if [[ $operation == "switch" ]]; then
    # 切换到该 workspace
    hyprctl dispatch workspace "$workspace"
elif [[ $operation == "move" ]]; then
    # 把当前窗口移动到该 workspace
    hyprctl dispatch movetoworkspace "$workspace"
fi
