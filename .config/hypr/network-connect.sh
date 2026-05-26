#!/usr/bin/expect -f

# 设置 WiFi 名称和密码

# 学校
set ssid "YNU"
set password "yunnandaxue"

# 家
#set ssid "ABC_2"
#set password "13658819485"

# 设置超时时间为 1 秒
set timeout 1

# 检查当前是否已连接到 WiFi
spawn nmcli device status
expect {
    # 如果 wlan0 接口已连接到 WiFi，跳过连接操作
    "wlan0" {
        expect "已连接" { 
            exit 0
        }
    }
    # 如果没有连接 WiFi，继续连接操作
    timeout {
        # 没有连接 WiFi时，继续连接
    }
}

# 启动 nmcli 连接 WiFi，使用 --ask 以触发交互式密码输入
spawn nmcli device wifi connect $ssid --ask

# 等待密码提示并发送密码
expect {
    "密码 (802-11-wireless-security.psk):" { send "$password\r" }
    timeout { exit 1 }
}

# 等待 "Activation successful" 提示确认连接成功
expect "WiFi connected successfully"

# 退出脚本，不做任何输出
exit 0
