#!/bin/bash
# KDE Neon 24 特定配置

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib/common.sh"

#=============================================================================
# KDE Neon 24 特定包
#=============================================================================
install_kde_neon24_packages() {
    log_step "安装 KDE Neon 24 特定包"

    # KDE Neon 24 基于 Ubuntu 24.04，有 gcc-13
    apt_install gcc-12 g++-12

    if apt-cache show gcc-13 &>/dev/null; then
        apt_install gcc-13 g++-13
    fi

    # KDE 特定的依赖
    apt_install fcitx5-frontend-qt6 2>/dev/null || true
}

#=============================================================================
# KDE Neon 24 特定配置
#=============================================================================
configure_kde_neon24() {
    log_step "应用 KDE Neon 24 特定配置"

    # 对于 Wayland+KDE，可能需要额外的配置
    local display_server
    display_server=$(detect_display_server)

    if [[ "$display_server" == "wayland" ]]; then
        log_info "检测到 Wayland 环境"

        # KDE Plasma Wayland 特定设置
        local plasma_env="$USER_HOME/.config/plasma-workspace/env"
        ensure_dir "$plasma_env"

        # 创建输入法环境脚本
        cat > "$plasma_env/fcitx5.sh" << 'EOF'
#!/bin/bash
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF
        chmod +x "$plasma_env/fcitx5.sh"
        log_info "已创建 KDE Plasma 输入法环境配置"
    fi
}

#=============================================================================
# 安装 Betaflight Configurator 依赖
#=============================================================================
install_betaflight() {
    log_step "安装 Betaflight Configurator 依赖"
    source "$SCRIPT_DIR/lib/apps.sh"
    install_betaflight_deps
}

#=============================================================================
# 运行 KDE Neon 24 完整安装
#=============================================================================
run_kde_neon24_setup() {
    log_info "开始 KDE Neon 24 环境配置"

    # 加载并运行各模块
    source "$SCRIPT_DIR/lib/gcc.sh"
    source "$SCRIPT_DIR/lib/apps.sh"
    source "$SCRIPT_DIR/lib/fcitx.sh"
    source "$SCRIPT_DIR/lib/zsh.sh"
    source "$SCRIPT_DIR/lib/udev.sh"
    source "$SCRIPT_DIR/lib/desktop.sh"

    # KDE Neon 24 特定
    install_kde_neon24_packages
    configure_kde_neon24

    # 通用模块
    [[ "$INSTALL_GCC" == true ]] && setup_gcc
    [[ "$INSTALL_DEV_TOOLS" == true ]] && setup_apps
    [[ "$INSTALL_FONTS" == true ]] && install_fonts
    [[ "$INSTALL_FCITX" == true ]] && setup_fcitx5
    [[ "$INSTALL_ZSH" == true ]] && setup_zsh
    [[ "$INSTALL_UDEV_RULES" == true ]] && setup_udev
    [[ "$INSTALL_LIBREOFFICE" == true ]] && install_libreoffice
    setup_desktop

    # Betaflight 依赖（可选）
    if confirm "是否安装 Betaflight Configurator 依赖?"; then
        install_betaflight
    fi

    log_info "KDE Neon 24 环境配置完成！"
    log_warn "请注销并重新登录以使所有更改生效"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_not_root
    check_sudo
    run_kde_neon24_setup
fi
