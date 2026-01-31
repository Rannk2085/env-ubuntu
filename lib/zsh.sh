#!/bin/bash
# ZSH 和 Oh-My-Zsh 配置模块

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

#=============================================================================
# 安装 ZSH
#=============================================================================
install_zsh() {
    log_step "安装 ZSH"
    apt_install zsh
}

#=============================================================================
# 设置 ZSH 为默认 Shell
#=============================================================================
set_default_shell() {
    log_step "设置 ZSH 为默认 Shell"

    if [[ "$SHELL" != "/bin/zsh" && "$SHELL" != "/usr/bin/zsh" ]]; then
        chsh -s /bin/zsh
        log_info "已将默认 Shell 更改为 ZSH，请重新登录以生效"
    else
        log_info "ZSH 已经是默认 Shell"
    fi
}

#=============================================================================
# 安装 Oh-My-Zsh
#=============================================================================
install_oh_my_zsh() {
    log_step "安装 Oh-My-Zsh"

    local omz_dir="$USER_HOME/.oh-my-zsh"

    if [[ -d "$omz_dir" ]]; then
        log_info "Oh-My-Zsh 已安装"
        return 0
    fi

    # 非交互式安装
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

#=============================================================================
# 安装 Powerlevel10k 主题
#=============================================================================
install_powerlevel10k() {
    log_step "安装 Powerlevel10k 主题"

    local theme_dir="${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    if [[ -d "$theme_dir" ]]; then
        log_info "Powerlevel10k 已安装"
        return 0
    fi

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
}

#=============================================================================
# 安装 ZSH 插件
#=============================================================================
install_zsh_plugins() {
    log_step "安装 ZSH 插件"

    local custom_dir="${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [[ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
        log_info "已安装 zsh-autosuggestions"
    fi

    # zsh-completions
    if [[ ! -d "$custom_dir/plugins/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$custom_dir/plugins/zsh-completions"
        log_info "已安装 zsh-completions"
    fi
}

#=============================================================================
# 安装 .zshrc 配置
#=============================================================================
install_zshrc() {
    log_step "安装 .zshrc 配置"

    local zshrc_template="$SCRIPT_DIR/templates/zshrc.template"
    local zshrc_target="$USER_HOME/.zshrc"

    if [[ -f "$zshrc_template" ]]; then
        backup_file "$zshrc_target"
        cp "$zshrc_template" "$zshrc_target"
        log_info "已安装 .zshrc"
    else
        log_warn "未找到 zshrc 模板: $zshrc_template"
    fi
}

#=============================================================================
# 主函数
#=============================================================================
setup_zsh() {
    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    install_zshrc
    set_default_shell
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_zsh
fi
