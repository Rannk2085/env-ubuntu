#!/bin/bash
# Fcitx5 输入法配置模块

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

#=============================================================================
# 安装 Fcitx5
#=============================================================================
install_fcitx5() {
    log_step "安装 Fcitx5 输入法框架"

    apt_install \
        fcitx5 \
        fcitx5-chinese-addons \
        fcitx5-frontend-gtk4 \
        fcitx5-frontend-gtk3 \
        fcitx5-frontend-gtk2 \
        fcitx5-frontend-qt5 \
        fcitx5-config-qt

    # 安装主题
    if apt-cache show fcitx5-material-color &>/dev/null; then
        apt_install fcitx5-material-color
    fi
}

#=============================================================================
# 配置输入法环境变量
#=============================================================================
configure_fcitx5_env() {
    log_step "配置输入法环境变量"

    local profile_file="$USER_HOME/.profile"
    local marker="# Fcitx5 Input Method"

    local content="
$marker
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx
"

    backup_file "$profile_file"
    append_if_missing "$profile_file" "$content" "$marker"
}

#=============================================================================
# 配置 Wayland 兼容性
#=============================================================================
configure_wayland_ime() {
    local display_server
    display_server=$(detect_display_server)

    if [[ "$display_server" == "wayland" ]]; then
        log_step "配置 Wayland 输入法兼容性"
        log_info "Wayland 环境检测到，Electron 应用需要特殊启动参数"
        log_info "请参考 templates/code.desktop 和 templates/cursor.desktop"
    fi
}

#=============================================================================
# 主函数
#=============================================================================
setup_fcitx5() {
    install_fcitx5
    configure_fcitx5_env
    configure_wayland_ime
    log_info "Fcitx5 配置完成，请注销并重新登录以生效"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_fcitx5
fi
