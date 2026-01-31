#!/bin/bash
# 桌面配置模块（Desktop 文件、图标等）

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

#=============================================================================
# 安装桌面文件
#=============================================================================
install_desktop_files() {
    log_step "安装桌面启动文件"

    ensure_dir "$APPLICATIONS_DIR"

    local templates_dir="$SCRIPT_DIR/templates"

    # 复制桌面文件
    for desktop_file in "$templates_dir"/*.desktop; do
        if [[ -f "$desktop_file" ]]; then
            cp "$desktop_file" "$APPLICATIONS_DIR/"
            log_info "已安装: $(basename "$desktop_file")"
        fi
    done

    # 更新桌面数据库
    update-desktop-database "$APPLICATIONS_DIR" 2>/dev/null || true
}

#=============================================================================
# 安装图标
#=============================================================================
install_icons() {
    log_step "安装应用图标"

    local assets_dir="$SCRIPT_DIR/assets"

    # Cursor 图标
    if [[ -f "$assets_dir/cursor.png" ]]; then
        ensure_dir "$ICONS_DIR/128x128/apps"
        cp "$assets_dir/cursor.png" "$ICONS_DIR/128x128/apps/cursor.png"
        log_info "已安装 Cursor 图标"
    fi

    # 更新图标缓存
    gtk-update-icon-cache -f "$ICONS_DIR" 2>/dev/null || true
}

#=============================================================================
# 安装自定义脚本
#=============================================================================
install_scripts() {
    log_step "安装自定义脚本"

    ensure_dir "$LOCAL_BIN"

    local templates_dir="$SCRIPT_DIR/templates"

    # 复制脚本文件
    if [[ -f "$templates_dir/screen.sh" ]]; then
        cp "$templates_dir/screen.sh" "$LOCAL_BIN/"
        chmod +x "$LOCAL_BIN/screen.sh"
        log_info "已安装截图脚本: screen.sh"
    fi
}

#=============================================================================
# 生成 VS Code 桌面文件
#=============================================================================
generate_vscode_desktop() {
    local display_server
    display_server=$(detect_display_server)

    local exec_args="--new-window %F"

    if [[ "$display_server" == "wayland" ]]; then
        exec_args="--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3 --new-window %F"
    fi

    cat << EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=/usr/share/code/code $exec_args
Icon=vscode
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=/usr/share/code/code --new-window %F
Icon=vscode
EOF
}

#=============================================================================
# 生成 Cursor 桌面文件
#=============================================================================
generate_cursor_desktop() {
    local cursor_path="$LOCAL_BIN/Cursor.AppImage"
    local display_server
    display_server=$(detect_display_server)

    local exec_args=""

    if [[ "$display_server" == "wayland" ]]; then
        exec_args="--no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3"
    fi

    cat << EOF
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
GenericName=Text Editor
Exec=$cursor_path $exec_args %F
Icon=cursor
Type=Application
StartupNotify=false
Categories=TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;
Keywords=cursor;ai;code;
EOF
}

#=============================================================================
# 主函数
#=============================================================================
setup_desktop() {
    install_icons
    install_desktop_files
    install_scripts
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_desktop
fi
