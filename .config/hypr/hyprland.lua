-- Hyprland 0.57: migrated from your hyprland.conf on 2026-10-30.
-- Edit this file; hyprland.conf is kept only as the original reference.
-- API reference shipped with this version: /usr/share/hypr/stubs/hl.meta.lua

hl.monitor({ output = "", mode = "1920x1200@60", position = "0x0", scale = 1.0 })

hl.config({
    xwayland = { force_zero_scaling = true },
    input = {
        kb_layout = "us", follow_mouse = 1, sensitivity = 0,
        accel_profile = "flat", touchpad = { natural_scroll = true },
    },
    general = {
        gaps_in = 4, gaps_out = 8, border_size = 2,
        col = {
            active_border = { colors = { "rgb(89b4fa)", "rgb(cba6f7)" }, angle = 45 },
            inactive_border = "rgba(45475aaa)",
        },
        layout = "dwindle", allow_tearing = true,
    },
    decoration = {
        rounding = 2, rounding_power = 2,
        active_opacity = 1.0, inactive_opacity = 1.0,
        shadow = { enabled = true, range = 4, render_power = 3, color = "rgba(1a1a1aee)" },
        blur = { enabled = true, size = 6, passes = 3, new_optimizations = true, ignore_opacity = true },
    },
    cursor = { no_hardware_cursors = true },
    animations = { enabled = true },
    dwindle = { preserve_split = true, split_width_multiplier = 1.33 },
    misc = {
        disable_hyprland_logo = true, force_default_wallpaper = 0,
        mouse_move_enables_dpms = true, key_press_enables_dpms = true,
        render_unfocused_fps = 60, enable_anr_dialog = false,
        background_color = "rgb(11111b)",
    },
})

-- Keep the original Fcitx, Qt and cursor environment local to Hyprland.
for name, value in pairs({
    GTK_IM_MODULE = "fcitx", QT_IM_MODULE = "fcitx",
    XMODIFIERS = "@im=fcitx", SDL_IM_MODULE = "fcitx",
    HYPRCURSOR_THEME = "Bibata-Modern-Ice", HYPRCURSOR_SIZE = "32",
    XCURSOR_THEME = "Bibata-Modern-Ice", XCURSOR_SIZE = "32",
    QT_QPA_PLATFORMTHEME = "qt5ct",
}) do
    hl.env(name, value)
end

hl.curve("ease", { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })
hl.curve("overshot", { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.05} } })
for _, a in ipairs({
    { "windows", 5, "overshot", "gnomed" },
    { "windowsOut", 5, "ease", "slide bottom" },
    { "windowsMove", 5, "overshot", "slide" },
    { "fade", 3, "ease" },
    { "border", 2, "ease" },
    { "workspaces", 5, "overshot", "slide" },
}) do
    hl.animation({ leaf = a[1], enabled = true, speed = a[2], bezier = a[3], style = a[4] })
end

-- Layer rules: retain panel, logout and notification blur.
for _, namespace in ipairs({ "waybar", "logout_dialog", "swaync-control-center", "swaync-notification-window" }) do
    hl.layer_rule({ name = "blur-" .. namespace, match = { namespace = namespace }, blur = true })
end
for _, namespace in ipairs({ "swaync-control-center", "swaync-notification-window" }) do
    hl.layer_rule({ name = "alpha-" .. namespace, match = { namespace = namespace }, ignore_alpha = 0.5 })
end

-- Window rules. Long strings preserve regex backslashes in Lua.
hl.window_rule({ name = "kitty-tiled", match = { class = "^kitty$" }, float = false })
hl.window_rule({ name = "obsidian-opacity", match = { class = "^obsidian$" }, opacity = "0.90 0.90" })
for i, class in ipairs({
    "^QQ$", "^steam$", "^vlc$", [[^org\.gnome\.Nautilus$]],
    [[^com\.st\.app\.Main$]], [[^ltspice\.exe$]],
    "^xdg-desktop-portal-gtk$", "^qemu.*$",
}) do
    hl.window_rule({ name = "float-app-" .. i, match = { class = class }, float = true })
end
for i, title in ipairs({ "^Volume Control$", "^Qt5 Configuration Tool$", "^Qt6 Configuration Tool$", "^Fcitx Configuration$" }) do
    hl.window_rule({ name = "float-dialog-" .. i, match = { title = title }, float = true })
end
hl.window_rule({ name = "firefox-library", match = { class = "^firefox$", title = "^Library$" }, float = true })
hl.window_rule({ name = "telegram-media", match = { class = [[^org\.telegram\.desktop$]], title = "^Media viewer$" }, float = true })
hl.window_rule({ name = "clash-window", match = { class = "^clash-verge$" }, float = true, center = true, size = {1000, 700} })
hl.window_rule({ name = "pinned-border", match = { pin = true }, border_color = "rgb(598da8) rgb(598da8)" })
hl.window_rule({ name = "vseeface-unfocused", match = { class = [[^vseeface\.exe$]] }, render_unfocused = true })

-- Existing screenshot permissions.
hl.permission("/usr/bin/grim", "screencopy", "allow")
hl.permission("/usr/lib/xdg-desktop-portal-hyprland", "screencopy", "allow")

local mod = "SUPER"
local function command(keys, cmd)
    hl.bind(keys, hl.dsp.exec_cmd(cmd))
end

-- Media/brightness keys retain the original commands.
command("XF86AudioMute", "pactl -- set-sink-mute @DEFAULT_SINK@ toggle")
command("XF86AudioLowerVolume", "pactl -- set-sink-volume @DEFAULT_SINK@ -5%")
command("XF86AudioRaiseVolume", "pactl -- set-sink-volume @DEFAULT_SINK@ +5%")
command("XF86AudioMicMute", "pactl -- set-source-mute @DEFAULT_SOURCE@ toggle")
command("XF86MonBrightnessDown", "brightnessctl set 5%-")
command("XF86MonBrightnessUp", "brightnessctl set +5%")

command(mod .. " + W", "~/.config/hypr/wallpaper_random.sh")
command(mod .. " + SHIFT + W", "~/.config/hypr/wallpaper_select.sh")
command(mod .. " + T", "kitty")
command(mod .. " + R", "fuzzel")
command(mod .. " + B", "resources")
command(mod .. " + SHIFT + E", "wlogout -b 5")
command(mod .. " + SHIFT + L", "hyprlock")
command(mod .. " + CTRL + ALT + R", "killall waybar; waybar & killall fcitx5; fcitx5")
hl.bind(mod .. " + E", hl.dsp.exec_cmd("nautilus --new-window", { float = true }))
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. " + M", hl.dsp.exit())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("swapsplit"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(mod .. " + U", hl.dsp.window.bring_to_top())
hl.bind(mod .. " + Z", hl.dsp.window.pin({ action = "toggle" }))

-- Do not open swappy if the region selection is cancelled.
command("Print", [[geometry=$(slurp) && grim -g "$geometry" - | swappy -f -]])
command(mod .. " + Print", "grim - | swappy -f -")
for _, direction in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. direction, hl.dsp.focus({ direction = direction }))
end

-- Native Lua dispatchers replace the old shell dispatcher names.
for i = 1, 5 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + X", hl.dsp.workspace.toggle_special())
hl.bind(mod .. " + SHIFT + X", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Run once per Hyprland session, rather than on every config reload.
hl.on("hyprland.start", function()
    for _, cmd in ipairs({
        "awww-daemon --format xrgb",
        "~/.config/hypr/wallpaper_restore.sh",
        "waybar", "swaync", "fcitx5",
        "dbus-update-activation-environment --systemd --all",
        "/usr/lib/polkit-kde-authentication-agent-1",
        "~/.config/hypr/network-connect.sh",
        "clash-verge",
    }) do
        hl.exec_cmd(cmd)
    end
end)
