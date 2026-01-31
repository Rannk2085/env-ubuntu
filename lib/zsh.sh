#!/bin/bash
# ZSH 和 Oh-My-Zsh 配置模块

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

#=============================================================================
# 检查网络连接
#=============================================================================
check_network() {
    log_step "检查网络连接"
    if ! curl -s --connect-timeout 5 https://github.com > /dev/null; then
        log_error "无法连接到 GitHub，请检查网络连接"
        exit 1
    fi
    log_info "网络连接正常"
}

#=============================================================================
# 安装 ZSH
#=============================================================================
install_zsh() {
    log_step "安装 ZSH"

    if command -v zsh &> /dev/null; then
        log_info "zsh 已安装: $(zsh --version)"
        return
    fi

    apt_install zsh

    if command -v zsh &> /dev/null; then
        log_info "zsh 安装成功: $(zsh --version)"
    else
        log_error "zsh 安装失败"
        exit 1
    fi
}

#=============================================================================
# 安装依赖工具
#=============================================================================
install_dependencies() {
    log_step "安装依赖工具"

    # git 是必需的
    if ! command -v git &> /dev/null; then
        apt_install git
    fi

    # curl 用于下载
    if ! command -v curl &> /dev/null; then
        apt_install curl
    fi

    # fzf 模糊搜索
    if ! command -v fzf &> /dev/null; then
        log_info "正在安装 fzf..."
        apt_install fzf || {
            log_warn "通过包管理器安装 fzf 失败，尝试从 git 安装..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all --no-bash --no-fish
        }
    fi

    log_info "依赖工具安装完成"
}

#=============================================================================
# 安装 Oh-My-Zsh
#=============================================================================
install_oh_my_zsh() {
    log_step "安装 Oh-My-Zsh"

    if [ -d "$USER_HOME/.oh-my-zsh" ]; then
        log_info "Oh-My-Zsh 已安装"
        return
    fi

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    if [ -d "$USER_HOME/.oh-my-zsh" ]; then
        log_info "Oh-My-Zsh 安装成功"
    else
        log_error "Oh-My-Zsh 安装失败"
        exit 1
    fi
}

#=============================================================================
# 安装 ZSH 插件
#=============================================================================
install_zsh_plugins() {
    log_step "安装 ZSH 插件"

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        log_info "正在安装 zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        log_info "zsh-autosuggestions 已安装"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        log_info "正在安装 zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
        log_info "zsh-syntax-highlighting 已安装"
    fi

    # zsh-completions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        log_info "正在安装 zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    else
        log_info "zsh-completions 已安装"
    fi

    # history-substring-search
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
        log_info "正在安装 zsh-history-substring-search..."
        git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
    else
        log_info "zsh-history-substring-search 已安装"
    fi

    log_info "所有插件安装完成"
}

#=============================================================================
# 安装 Powerlevel10k 主题
#=============================================================================
install_powerlevel10k() {
    log_step "安装 Powerlevel10k 主题"

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}"

    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        log_info "正在安装 Powerlevel10k 主题..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    else
        log_info "Powerlevel10k 主题已安装"
    fi

    log_info "主题安装完成"
    log_warn "提示: Powerlevel10k 需要 Nerd Font 字体才能正确显示图标"
    log_info "推荐字体: MesloLGS NF, FiraCode Nerd Font, JetBrainsMono Nerd Font"
    log_info "下载地址: https://www.nerdfonts.com/font-downloads"
}

#=============================================================================
# 配置 .zshrc
#=============================================================================
install_zshrc() {
    log_step "配置 .zshrc"

    local zshrc_target="$USER_HOME/.zshrc"

    # 备份原有配置
    if [ -f "$zshrc_target" ]; then
        cp "$zshrc_target" "$zshrc_target.backup.$(date +%Y%m%d%H%M%S)"
        log_info "已备份原有 .zshrc"
    fi

    cat > "$zshrc_target" << 'EOF'
# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh 路径
export ZSH="$HOME/.oh-my-zsh"

# 主题设置
ZSH_THEME="powerlevel10k/powerlevel10k"

# 插件列表
plugins=(
    git                         # Git 别名和补全
    z                           # 智能目录跳转
    sudo                        # 双击 ESC 添加 sudo
    extract                     # 统一解压命令
    command-not-found           # 命令未找到提示
    colored-man-pages           # 彩色 man 手册
    safe-paste                  # 防止粘贴时意外执行
    zsh-autosuggestions         # 命令自动建议
    zsh-syntax-highlighting     # 语法高亮
    zsh-completions             # 增强补全
    zsh-history-substring-search # 历史子串搜索
    fzf                         # 模糊搜索集成
)

# 加载 zsh-completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# 加载 Oh My Zsh
source $ZSH/oh-my-zsh.sh

# history-substring-search 键绑定
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 历史记录配置
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# 其他实用设置
setopt AUTO_CD              # 直接输入目录名即可 cd
setopt CORRECT              # 命令纠错
setopt COMPLETE_ALIASES     # 别名补全

# 别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# fzf 配置（如果存在）
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Powerlevel10k 配置（如果存在）
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

    log_info ".zshrc 配置完成"
}

#=============================================================================
# 切换默认 shell
#=============================================================================
set_default_shell() {
    log_step "设置默认 Shell"

    local ZSH_PATH
    ZSH_PATH=$(which zsh)

    local CURRENT_SHELL
    CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)

    if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
        log_info "默认 shell 已经是 zsh"
        return
    fi

    log_info "正在将默认 shell 切换为 zsh..."

    # 确保 zsh 在 /etc/shells 中
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        log_info "将 zsh 添加到 /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    chsh -s "$ZSH_PATH"
    log_info "默认 shell 已切换为 zsh"
}

#=============================================================================
# 显示安装完成信息
#=============================================================================
show_complete_message() {
    echo ""
    echo "=========================================="
    log_info "ZSH 安装完成！"
    echo "=========================================="
    echo ""
    echo "请执行以下操作完成配置："
    echo ""
    echo "  1. 重新登录或执行: exec zsh"
    echo "  2. 首次启动会运行 Powerlevel10k 配置向导"
    echo "  3. 按照向导选择你喜欢的样式"
    echo ""
    echo "已安装的插件："
    echo "  - git              : Git 别名和补全"
    echo "  - z                : 智能目录跳转 (用法: z <目录关键词>)"
    echo "  - sudo             : 双击 ESC 添加 sudo"
    echo "  - extract          : 统一解压 (用法: extract <压缩文件>)"
    echo "  - command-not-found: 命令未找到时提示安装包"
    echo "  - colored-man-pages: 彩色 man 手册"
    echo "  - safe-paste        : 防止粘贴时意外执行命令"
    echo "  - zsh-autosuggestions    : 命令自动建议 (按 → 接受)"
    echo "  - zsh-syntax-highlighting: 语法高亮"
    echo "  - zsh-completions        : 增强 Tab 补全"
    echo "  - history-substring-search: 历史搜索 (输入后按 ↑↓)"
    echo "  - fzf              : 模糊搜索 (Ctrl+R 搜索历史)"
    echo ""
}

#=============================================================================
# 主函数
#=============================================================================
setup_zsh() {
    echo ""
    echo "=========================================="
    echo "       Zsh 自动安装配置脚本"
    echo "=========================================="
    echo ""

    check_network
    install_zsh
    install_dependencies
    install_oh_my_zsh
    install_zsh_plugins
    install_powerlevel10k
    install_zshrc
    set_default_shell
    show_complete_message
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_zsh
fi
