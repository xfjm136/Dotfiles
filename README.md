# Dotfiles

这个仓库只备份我实际在用、并且适合公开同步的桌面与编辑器配置。

## Included

- `~/.config/hypr`
- `~/.config/waybar`
- `~/.config/kitty`
- `~/.config/rofi`
- `~/.config/nvim`
- `~/.config/colors`
- `~/.config/fuzzel`
- `~/.config/swaync`
- `~/.config/wlogout`
- `~/.config/private/*.example`
- `~/.config/hypr/wallpapers`

## Private Files

真实密钥和 Wi-Fi 密码不会进入 Git。

- `~/.config/private/ai.env`
- `~/.config/private/wifi.env`

仓库里只提供模板：

- `.config/private/ai.env.example`
- `.config/private/wifi.env.example`

## Usage

```bash
git clone https://github.com/xfjm136/Dotfiles.git
cd Dotfiles
cp .config/private/ai.env.example ~/.config/private/ai.env
cp .config/private/wifi.env.example ~/.config/private/wifi.env
```

如果你使用 `stow`：

```bash
stow .
```

## Hyprland 0.57+

Hyprland 的主配置为 `.config/hypr/hyprland.lua`。0.57 已不再加载旧的
`hyprland.conf`，仓库中的 `.conf` 仅保留为迁移参考。

保留原来的 45 个快捷键和 9 项自启动。工作区仍使用 Super + 1–5，
Super + Shift + 1–5 移动窗口。

Waybar 0.15 的默认工作区点击命令与新版 Hyprland 不兼容，因此顶栏使用
`group/workspaces` 和五个自定义按钮；`hypr-workspace.py` 通过事件套接字
更新高亮，点击时调用 `switch_workspace.sh` 中的 Lua dispatcher。
这部分需要 Python 3，无第三方 Python 依赖。

配置检查：

```bash
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
```

在 Hyprland 内更新顶栏后，可以执行 `pkill -USR2 -x waybar` 重载。
