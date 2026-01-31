#!/bin/bash
# Ubuntu 22.04 特定配置

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib/common.sh"

#=============================================================================
# Ubuntu 22 特定包
#=============================================================================
install_ubuntu22_packages() {
    log_step "安装 Ubuntu 22 特定包"

    # Ubuntu 22 默认有 gcc-11，需要额外安装 gcc-12
    apt_install gcc-11 g++-11
    apt_install gcc-12 g++-12
}

#=============================================================================
# Ubuntu 22 特定配置
#=============================================================================
configure_ubuntu22() {
    log_step "应用 Ubuntu 22 特定配置"

    # libncurses5 可能需要从本地包安装
    if ! is_installed libncurses5; then
        source "$SCRIPT_DIR/lib/apps.sh"
        install_vscode_debug_deps
    fi
}

#=============================================================================
# 运行 Ubuntu 22 完整安装
#=============================================================================
run_ubuntu22_setup() {
    log_info "开始 Ubuntu 22.04 环境配置"

    # 加载并运行各模块
    source "$SCRIPT_DIR/lib/gcc.sh"
    source "$SCRIPT_DIR/lib/apps.sh"
    source "$SCRIPT_DIR/lib/fcitx.sh"
    source "$SCRIPT_DIR/lib/zsh.sh"
    source "$SCRIPT_DIR/lib/udev.sh"
    source "$SCRIPT_DIR/lib/desktop.sh"

    # Ubuntu 22 特定
    install_ubuntu22_packages
    configure_ubuntu22

    # 通用模块
    [[ "$INSTALL_GCC" == true ]] && setup_gcc
    [[ "$INSTALL_DEV_TOOLS" == true ]] && setup_apps
    [[ "$INSTALL_FCITX" == true ]] && setup_fcitx5
    [[ "$INSTALL_ZSH" == true ]] && setup_zsh
    [[ "$INSTALL_UDEV_RULES" == true ]] && setup_udev
    setup_desktop

    log_info "Ubuntu 22.04 环境配置完成！"
    log_warn "请注销并重新登录以使所有更改生效"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_not_root
    check_sudo
    run_ubuntu22_setup
fi
