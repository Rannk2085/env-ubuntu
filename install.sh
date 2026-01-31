#!/bin/bash
#=============================================================================
# env-ubuntu 安装脚本
# 用于配置 Linux 开发环境
#=============================================================================

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载配置和公共函数
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib/common.sh"

#=============================================================================
# 显示帮助信息
#=============================================================================
show_help() {
    cat << EOF
用法: $0 [选项] [模块...]

env-ubuntu - Linux 开发环境配置工具

选项:
  -h, --help        显示帮助信息
  -l, --list        列出所有可用模块
  -d, --distro      指定发行版 (ubuntu22, kde-neon24, auto)
  -a, --all         安装所有模块
  --dry-run         仅显示将执行的操作，不实际执行

模块:
  gcc               安装和配置 GCC 多版本
  apps              安装开发工具和常用应用
  fcitx             安装 Fcitx5 输入法
  zsh               安装 ZSH 和 Oh-My-Zsh
  udev              配置 USB 设备规则
  desktop           安装桌面配置和图标
  fonts             安装中文字体
  libreoffice       安装 LibreOffice

示例:
  $0                          # 交互式安装
  $0 -a                       # 安装所有模块
  $0 gcc zsh                  # 只安装 gcc 和 zsh 模块
  $0 -d kde-neon24 -a         # 为 KDE Neon 24 安装所有模块

EOF
}

#=============================================================================
# 列出可用模块
#=============================================================================
list_modules() {
    echo "可用模块:"
    echo "  gcc         - GCC 多版本安装和配置"
    echo "  apps        - 开发工具和常用应用"
    echo "  fcitx       - Fcitx5 输入法框架"
    echo "  zsh         - ZSH 和 Oh-My-Zsh"
    echo "  udev        - USB 设备规则"
    echo "  desktop     - 桌面配置和图标"
    echo "  fonts       - 中文字体"
    echo "  libreoffice - LibreOffice 办公套件"
}

#=============================================================================
# 显示菜单
#=============================================================================
show_menu() {
    echo ""
    echo "========================================"
    echo "  env-ubuntu 开发环境配置工具"
    echo "========================================"
    echo ""
    echo "检测到的系统信息:"
    echo "  发行版: $(detect_distro) $(detect_distro_version)"
    echo "  桌面环境: $(detect_desktop)"
    echo "  显示服务器: $(detect_display_server)"
    echo ""
    echo "请选择安装方式:"
    echo "  1) 完整安装 (推荐)"
    echo "  2) 选择模块安装"
    echo "  3) 仅安装开发工具"
    echo "  4) 仅安装 ZSH"
    echo "  5) 退出"
    echo ""
}

#=============================================================================
# 完整安装
#=============================================================================
full_install() {
    local distro="$1"

    case "$distro" in
        ubuntu22|ubuntu)
            source "$SCRIPT_DIR/distro/ubuntu22.sh"
            run_ubuntu22_setup
            ;;
        kde-neon24|neon)
            source "$SCRIPT_DIR/distro/kde-neon24.sh"
            run_kde_neon24_setup
            ;;
        *)
            # 自动检测
            local detected
            detected=$(detect_distro)
            local version
            version=$(detect_distro_version)

            case "$detected" in
                ubuntu)
                    if [[ "$version" == "22.04" ]]; then
                        source "$SCRIPT_DIR/distro/ubuntu22.sh"
                        run_ubuntu22_setup
                    else
                        source "$SCRIPT_DIR/distro/kde-neon24.sh"
                        run_kde_neon24_setup
                    fi
                    ;;
                neon)
                    source "$SCRIPT_DIR/distro/kde-neon24.sh"
                    run_kde_neon24_setup
                    ;;
                *)
                    log_warn "未识别的发行版: $detected"
                    log_info "将使用通用安装流程"
                    install_selected_modules gcc apps fcitx zsh udev desktop
                    ;;
            esac
            ;;
    esac
}

#=============================================================================
# 安装选定模块
#=============================================================================
install_selected_modules() {
    local modules=("$@")

    for module in "${modules[@]}"; do
        case "$module" in
            gcc)
                source "$SCRIPT_DIR/lib/gcc.sh"
                setup_gcc
                ;;
            apps)
                source "$SCRIPT_DIR/lib/apps.sh"
                setup_apps
                ;;
            fcitx)
                source "$SCRIPT_DIR/lib/fcitx.sh"
                setup_fcitx5
                ;;
            zsh)
                source "$SCRIPT_DIR/lib/zsh.sh"
                setup_zsh
                ;;
            udev)
                source "$SCRIPT_DIR/lib/udev.sh"
                setup_udev
                ;;
            desktop)
                source "$SCRIPT_DIR/lib/desktop.sh"
                setup_desktop
                ;;
            fonts)
                source "$SCRIPT_DIR/lib/apps.sh"
                install_fonts
                ;;
            libreoffice)
                source "$SCRIPT_DIR/lib/apps.sh"
                install_libreoffice
                ;;
            *)
                log_warn "未知模块: $module"
                ;;
        esac
    done
}

#=============================================================================
# 交互式模块选择
#=============================================================================
interactive_module_select() {
    echo ""
    echo "请选择要安装的模块 (用空格分隔数字):"
    echo "  1) GCC 多版本"
    echo "  2) 开发工具"
    echo "  3) Fcitx5 输入法"
    echo "  4) ZSH"
    echo "  5) USB 设备规则"
    echo "  6) 桌面配置"
    echo "  7) 中文字体"
    echo "  8) LibreOffice"
    echo ""

    read -r -p "输入选择 (例如: 1 2 3 4): " choices

    local modules=()
    for choice in $choices; do
        case "$choice" in
            1) modules+=("gcc") ;;
            2) modules+=("apps") ;;
            3) modules+=("fcitx") ;;
            4) modules+=("zsh") ;;
            5) modules+=("udev") ;;
            6) modules+=("desktop") ;;
            7) modules+=("fonts") ;;
            8) modules+=("libreoffice") ;;
        esac
    done

    if [[ ${#modules[@]} -gt 0 ]]; then
        install_selected_modules "${modules[@]}"
    else
        log_warn "未选择任何模块"
    fi
}

#=============================================================================
# 主函数
#=============================================================================
main() {
    local distro="auto"
    local all_modules=false
    local dry_run=false
    local modules=()

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--list)
                list_modules
                exit 0
                ;;
            -d|--distro)
                distro="$2"
                shift 2
                ;;
            -a|--all)
                all_modules=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -*)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                modules+=("$1")
                shift
                ;;
        esac
    done

    # 检查权限
    check_not_root
    check_sudo

    # dry-run 模式
    if [[ "$dry_run" == true ]]; then
        log_info "Dry-run 模式，不会执行实际操作"
        # TODO: 实现 dry-run
        exit 0
    fi

    # 根据参数执行
    if [[ "$all_modules" == true ]]; then
        full_install "$distro"
    elif [[ ${#modules[@]} -gt 0 ]]; then
        install_selected_modules "${modules[@]}"
    else
        # 交互式模式
        show_menu
        read -r -p "请输入选择 [1-5]: " choice

        case "$choice" in
            1)
                full_install "$distro"
                ;;
            2)
                interactive_module_select
                ;;
            3)
                install_selected_modules gcc apps
                ;;
            4)
                install_selected_modules zsh
                ;;
            5)
                log_info "退出"
                exit 0
                ;;
            *)
                log_error "无效选择"
                exit 1
                ;;
        esac
    fi

    echo ""
    log_info "安装完成！"
    log_warn "请注销并重新登录以使所有更改生效"
}

# 运行主函数
main "$@"
