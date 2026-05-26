#!/usr/bin/env bash

# =========================
#  壁纸列表自行维护
# =========================
WALLPAPER_1="/home/xfjm/Pictures/wallpaper/wallhaven-6o6orw.png"
WALLPAPER_2="/home/xfjm/Pictures/wallpaper/minimalist-black-hole.png"
WALLPAPER_3="/home/xfjm/Pictures/wallpaper/jellyfish.jpg"
WALLPAPER_4="/home/xfjm/Pictures/wallpaper/samurai.jpg"
WALLPAPER_5="/home/xfjm/Pictures/wallpaper/wallhaven-l31y6y.png"
WALLPAPER_6="/home/xfjm/Pictures/wallpaper/sushi.jpg"
WALLPAPER_7="/home/xfjm/Pictures/wallpaper/waterfall.jpg"

wallpapers=(
    "$WALLPAPER_1"
    "$WALLPAPER_2"
    "$WALLPAPER_3"
    "$WALLPAPER_4"
    "$WALLPAPER_5"
    "$WALLPAPER_6"
    "$WALLPAPER_7"
)

# =========================
#  动画类型列表（可增删）
# =========================
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

# =========================
#  获取当前壁纸路径
# =========================
# 依赖：swww 已经 init，且有壁纸在用
current_wallpaper=$(swww query 2>/dev/null | awk -F'image: ' 'NF>1 {gsub(/^ +| +$/, "", $2); print $2; exit}')

# =========================
#  从列表中过滤掉当前壁纸
# =========================
candidates=()
for wp in "${wallpapers[@]}"; do
    if [[ "$wp" != "$current_wallpaper" ]]; then
        candidates+=("$wp")
    fi
done

# 如果因为某些原因没拿到当前壁纸，或者当前壁纸不在列表里
# 就退回到“随便一张”
if ((${#candidates[@]} == 0)); then
    candidates=("${wallpapers[@]}")
fi

# =========================
#  随机选一张“不是当前的”壁纸
# =========================
random_wallpaper=${candidates[$RANDOM % ${#candidates[@]}]}

# =========================
#  随机动画参数
# =========================
random_transition=${transitions[$RANDOM % ${#transitions[@]}]}

# 随机动画时长 (0.3 - 1.5 秒)
duration=$(awk -v min=0.3 -v max=1.5 'BEGIN{srand(); print min+rand()*(max-min)}')

# =========================
#  执行切换
# =========================
awww img "$random_wallpaper" \
    --transition-type "$random_transition" \
    --transition-duration "$duration" \
    --transition-fps 60
