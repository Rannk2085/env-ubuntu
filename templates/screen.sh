#!/bin/bash
# 截图并编辑脚本
# 使用方法: 绑定到快捷键

set -e

# 截图保存目录
SCREENSHOT_DIR="${HOME}/Pictures"
mkdir -p "$SCREENSHOT_DIR"

# 文件名（带时间戳）
FILE="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

# 区域截图
if ! gnome-screenshot -a -f "$FILE"; then
    echo "截图失败或已取消"
    exit 1
fi

# 检查文件是否生成
if [[ ! -f "$FILE" ]]; then
    echo "截图已取消"
    exit 0
fi

# 用 drawing 打开编辑（此命令会阻塞，等你关闭编辑器后继续）
if command -v drawing &>/dev/null; then
    drawing "$FILE"
fi

# 编辑完成后复制图片到剪贴板
if command -v wl-copy &>/dev/null; then
    wl-copy < "$FILE"
    echo "图片已复制到剪贴板：$FILE"
elif command -v xclip &>/dev/null; then
    xclip -selection clipboard -t image/png -i "$FILE"
    echo "图片已复制到剪贴板：$FILE"
else
    echo "图片已保存：$FILE"
fi
