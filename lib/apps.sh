#!/bin/bash
# 应用程序安装模块

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

#=============================================================================
# 安装基础开发工具
#=============================================================================
install_dev_tools() {
    log_step "安装基础开发工具"

    apt_install \
        vim \
        git \
        wget \
        curl \
        cmake \
        ninja-build \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-venv
}

#=============================================================================
# 安装开发库
#=============================================================================
install_dev_libs() {
    log_step "安装开发库"

    apt_install \
        libncurses-dev \
        libreadline-dev \
        libssl-dev \
        libelf-dev \
        libusb-1.0-0-dev \
        libudev-dev \
        libhidapi-dev \
        libftdi-dev \
        flex \
        bison
}

#=============================================================================
# 安装系统工具
#=============================================================================
install_system_tools() {
    log_step "安装系统工具"

    apt_install \
        net-tools \
        cifs-utils \
        exfatprogs \
        p7zip-full \
        dos2unix \
        picocom \
        minicom
}

#=============================================================================
# 安装 FUSE 支持（AppImage 需要）
#=============================================================================
install_fuse() {
    log_step "安装 FUSE 支持"
    apt_install libfuse2
}

#=============================================================================
# 安装 GVFS 后端（文件管理器共享支持）
#=============================================================================
install_gvfs() {
    log_step "安装 GVFS 后端"
    apt_install gvfs-backends gvfs-fuse
}

#=============================================================================
# 安装中文字体
#=============================================================================
install_fonts() {
    log_step "安装字体"

    apt_install \
        fonts-firacode \
        fonts-noto-cjk \
        fonts-arphic-uming \
        fonts-wqy-zenhei \
        fonts-wqy-microhei \
        fonts-hanazono
}

#=============================================================================
# 安装截图和绘图工具
#=============================================================================
install_screenshot_tools() {
    log_step "安装截图工具"

    apt_install \
        gnome-screenshot \
        drawing \
        wl-clipboard
}

#=============================================================================
# 安装 LibreOffice
#=============================================================================
install_libreoffice() {
    log_step "安装 LibreOffice"

    apt_install \
        libreoffice \
        libreoffice-l10n-zh-cn \
        libreoffice-help-zh-cn
}

#=============================================================================
# 安装 VS Code 调试依赖（libncurses5）
#=============================================================================
install_vscode_debug_deps() {
    log_step "安装 VS Code 调试依赖"

    local packages_dir="$SCRIPT_DIR/packages"

    if [[ -f "$packages_dir/libtinfo5_6.4-4_amd64.deb" ]]; then
        install_local_deb "$packages_dir/libtinfo5_6.4-4_amd64.deb"
    fi

    if [[ -f "$packages_dir/libncurses5_6.4-4_amd64.deb" ]]; then
        install_local_deb "$packages_dir/libncurses5_6.4-4_amd64.deb"
    fi
}

#=============================================================================
# 安装 Betaflight Configurator 依赖
#=============================================================================
install_betaflight_deps() {
    log_step "安装 Betaflight Configurator 依赖"

    # 移除旧版本
    sudo apt remove -y libgconf-2-4 gconf2-common 2>/dev/null || true
    sudo apt autoremove -y

    # 下载并安装兼容包
    local tmp_dir="/tmp/betaflight-deps"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || return 1

    wget -q http://mirrors.ustc.edu.cn/ubuntu/pool/universe/g/gconf/gconf2-common_3.2.6-7ubuntu2_all.deb
    wget -q http://mirrors.ustc.edu.cn/ubuntu/pool/universe/g/gconf/libgconf-2-4_3.2.6-7ubuntu2_amd64.deb

    sudo dpkg -i gconf2-common_3.2.6-7ubuntu2_all.deb
    sudo dpkg -i libgconf-2-4_3.2.6-7ubuntu2_amd64.deb
    sudo apt -f install -y

    cd - > /dev/null || return 1
    rm -rf "$tmp_dir"

    if ldconfig -p | grep -q libgconf; then
        log_info "Betaflight 依赖安装成功"
    else
        log_warn "Betaflight 依赖可能安装失败"
    fi
}

#=============================================================================
# 安装 Python 虚拟环境支持
#=============================================================================
install_python_venv() {
    log_step "安装 Python 虚拟环境支持"

    # 检测 Python 版本
    local python_version
    python_version=$(python3 --version 2>/dev/null | grep -oP '\d+\.\d+')

    if [[ -n "$python_version" ]]; then
        apt_install "python${python_version}-venv"
    fi
}

#=============================================================================
# 主函数
#=============================================================================
setup_apps() {
    install_dev_tools
    install_dev_libs
    install_system_tools
    install_fuse
    install_gvfs
    install_fonts
    install_screenshot_tools
    install_vscode_debug_deps
    install_python_venv
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_apps
fi
