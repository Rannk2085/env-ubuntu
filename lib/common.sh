#!/bin/bash
# 公共函数库

#=============================================================================
# 颜色定义
#=============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#=============================================================================
# 日志函数
#=============================================================================
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_step() {
    echo -e "${BLUE}==>${NC} $*"
}

#=============================================================================
# 系统检查函数
#=============================================================================

# 检查是否以 root 运行（不推荐）
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "请不要以 root 用户运行此脚本，使用普通用户运行（脚本会在需要时使用 sudo）"
        exit 1
    fi
}

# 检查 sudo 权限
check_sudo() {
    if ! sudo -v; then
        log_error "需要 sudo 权限"
        exit 1
    fi
}

# 检测发行版
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# 检测发行版版本
detect_distro_version() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "$VERSION_ID"
    else
        echo "unknown"
    fi
}

# 检测桌面环境
detect_desktop() {
    if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
        echo "$XDG_CURRENT_DESKTOP"
    elif [[ -n "$DESKTOP_SESSION" ]]; then
        echo "$DESKTOP_SESSION"
    else
        echo "unknown"
    fi
}

# 检测显示服务器
detect_display_server() {
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        echo "wayland"
    elif [[ -n "$DISPLAY" ]]; then
        echo "x11"
    else
        echo "unknown"
    fi
}

#=============================================================================
# 文件操作函数
#=============================================================================

# 备份文件
backup_file() {
    local file="$1"
    if [[ -f "$file" && ! -f "${file}.bak" ]]; then
        log_info "备份 $file"
        cp "$file" "${file}.bak"
    fi
}

# 追加内容到文件（如果不存在）
append_if_missing() {
    local file="$1"
    local content="$2"
    local marker="$3"  # 用于检测是否已添加的标记

    if [[ -n "$marker" ]] && grep -q "$marker" "$file" 2>/dev/null; then
        log_info "内容已存在于 $file，跳过"
        return 0
    fi

    echo "$content" >> "$file"
    log_info "已添加内容到 $file"
}

# 创建目录（如果不存在）
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "创建目录: $dir"
    fi
}

#=============================================================================
# 包管理函数
#=============================================================================

# 安装 apt 包
apt_install() {
    log_step "安装: $*"
    sudo apt install -y "$@"
}

# 检查包是否已安装
is_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# 安装本地 deb 包
install_local_deb() {
    local deb_file="$1"
    if [[ -f "$deb_file" ]]; then
        log_step "安装本地包: $deb_file"
        sudo dpkg -i "$deb_file" || sudo apt -f install -y
    else
        log_error "文件不存在: $deb_file"
        return 1
    fi
}

#=============================================================================
# 用户交互函数
#=============================================================================

# 确认提示
confirm() {
    local prompt="${1:-确认继续?}"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        read -r -p "$prompt [Y/n] " response
        [[ -z "$response" || "$response" =~ ^[Yy] ]]
    else
        read -r -p "$prompt [y/N] " response
        [[ "$response" =~ ^[Yy] ]]
    fi
}

# 选择菜单
select_menu() {
    local prompt="$1"
    shift
    local options=("$@")

    echo "$prompt"
    local i=1
    for opt in "${options[@]}"; do
        echo "  $i) $opt"
        ((i++))
    done

    read -r -p "请选择 [1-${#options[@]}]: " choice
    echo "$choice"
}
