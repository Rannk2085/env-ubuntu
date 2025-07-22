#!/bin/bash

# 文件名（带时间戳）
FILE=~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png

# 区域截图
gnome-screenshot -a -f "$FILE"
if [ $? -ne 0 ]; then
  echo "截图失败"
  exit 1
fi

# 用 drawing 打开编辑（此命令会阻塞，等你关闭编辑器后继续）
drawing "$FILE"

# 编辑完成后复制图片到剪贴板
wl-copy < "$FILE"

echo "图片已复制到剪贴板：$FILE"

