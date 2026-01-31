#!/bin/bash
# USB 设备规则配置模块

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

#=============================================================================
# 配置用户组
#=============================================================================
configure_user_groups() {
    log_step "添加用户到设备访问组"

    sudo usermod -a -G dialout "$USER_NAME"
    sudo usermod -a -G plugdev "$USER_NAME"

    log_info "已添加 $USER_NAME 到 dialout 和 plugdev 组"
    log_warn "需要注销并重新登录以使组成员身份生效"
}

#=============================================================================
# 安装 STM32/AT32 udev 规则
#=============================================================================
install_stm32_rules() {
    log_step "安装 STM32/AT32 udev 规则"

    local rules_file="/etc/udev/rules.d/45-stm32.rules"

    # 生成规则内容
    local rules_content=""
    for device in "${STM32_DEVICES[@]}"; do
        local vid="${device%%:*}"
        local pid="${device##*:}"
        rules_content+="SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"$vid\", ATTRS{idProduct}==\"$pid\", GROUP=\"plugdev\", MODE=\"0664\", TAG+=\"uaccess\""$'\n'
    done

    # 写入规则文件
    echo "$rules_content" | sudo tee "$rules_file" > /dev/null

    log_info "已创建规则文件: $rules_file"
}

#=============================================================================
# 添加自定义设备规则
#=============================================================================
add_custom_device() {
    local vid="$1"
    local pid="$2"
    local description="${3:-Custom Device}"

    if [[ -z "$vid" || -z "$pid" ]]; then
        log_error "用法: add_custom_device <VID> <PID> [描述]"
        return 1
    fi

    local rules_file="/etc/udev/rules.d/99-custom-devices.rules"
    local rule="# $description"$'\n'
    rule+="SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"$vid\", ATTRS{idProduct}==\"$pid\", GROUP=\"plugdev\", MODE=\"0664\", TAG+=\"uaccess\""

    echo "$rule" | sudo tee -a "$rules_file" > /dev/null
    log_info "已添加设备规则: $vid:$pid ($description)"
}

#=============================================================================
# 重载 udev 规则
#=============================================================================
reload_udev_rules() {
    log_step "重载 udev 规则"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    log_info "udev 规则已重载"
}

#=============================================================================
# 禁用 ModemManager（避免干扰串口设备）
#=============================================================================
disable_modem_manager() {
    log_step "禁用 ModemManager"

    if systemctl is-active --quiet ModemManager; then
        sudo systemctl stop ModemManager
        sudo systemctl disable ModemManager
        log_info "已禁用 ModemManager"
    else
        log_info "ModemManager 未运行"
    fi
}

#=============================================================================
# 主函数
#=============================================================================
setup_udev() {
    configure_user_groups
    install_stm32_rules
    reload_udev_rules
    disable_modem_manager
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_udev
fi
