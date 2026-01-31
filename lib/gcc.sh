#!/bin/bash
# GCC 多版本配置模块

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

#=============================================================================
# 安装 GCC
#=============================================================================
install_gcc() {
    log_step "安装 GCC 编译工具链"

    # 安装基础构建工具
    apt_install build-essential

    # 安装 GCC 多版本
    apt_install gcc-11 g++-11
    apt_install gcc-12 g++-12

    # 检查是否有 gcc-13 可用
    if apt-cache show gcc-13 &>/dev/null; then
        apt_install gcc-13 g++-13
    fi
}

#=============================================================================
# 配置 GCC alternatives
#=============================================================================
configure_gcc_alternatives() {
    log_step "配置 GCC 版本管理"

    # GCC 11
    if command -v gcc-11 &>/dev/null; then
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 "${GCC_11_PRIORITY:-110}"
        sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 "${GCC_11_PRIORITY:-110}"
        log_info "已注册 gcc-11 (优先级: ${GCC_11_PRIORITY:-110})"
    fi

    # GCC 12
    if command -v gcc-12 &>/dev/null; then
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 "${GCC_12_PRIORITY:-120}"
        sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 "${GCC_12_PRIORITY:-120}"
        log_info "已注册 gcc-12 (优先级: ${GCC_12_PRIORITY:-120})"
    fi

    # GCC 13
    if command -v gcc-13 &>/dev/null; then
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 "${GCC_13_PRIORITY:-130}"
        sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 "${GCC_13_PRIORITY:-130}"
        log_info "已注册 gcc-13 (优先级: ${GCC_13_PRIORITY:-130})"
    fi

    log_info "当前 GCC 版本:"
    gcc --version | head -1
}

#=============================================================================
# 交互式选择 GCC 版本
#=============================================================================
select_gcc_version() {
    log_step "选择默认 GCC 版本"
    sudo update-alternatives --config gcc
    sudo update-alternatives --config g++
}

#=============================================================================
# 生成 GCC 别名
#=============================================================================
generate_gcc_aliases() {
    local aliases=""

    if command -v gcc-11 &>/dev/null; then
        aliases+="alias gcc11='sudo update-alternatives --set gcc /usr/bin/gcc-11 && sudo update-alternatives --set g++ /usr/bin/g++-11'"$'\n'
    fi

    if command -v gcc-12 &>/dev/null; then
        aliases+="alias gcc12='sudo update-alternatives --set gcc /usr/bin/gcc-12 && sudo update-alternatives --set g++ /usr/bin/g++-12'"$'\n'
    fi

    if command -v gcc-13 &>/dev/null; then
        aliases+="alias gcc13='sudo update-alternatives --set gcc /usr/bin/gcc-13 && sudo update-alternatives --set g++ /usr/bin/g++-13'"$'\n'
    fi

    echo "$aliases"
}

#=============================================================================
# 主函数
#=============================================================================
setup_gcc() {
    install_gcc
    configure_gcc_alternatives
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_gcc
fi
