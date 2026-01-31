# env-ubuntu

Linux 开发环境自动化配置工具，支持 Ubuntu 22.04 和 KDE Neon 24。

## 功能特性

- **GCC 多版本管理** - 安装和配置 GCC 11/12/13，使用 update-alternatives 切换
- **ZSH 环境** - Oh-My-Zsh + Powerlevel10k 主题 + 常用插件
- **中文输入法** - Fcitx5 输入法框架，支持 Wayland
- **嵌入式开发** - STM32/AT32 USB 设备规则，ARM 工具链支持
- **开发工具** - cmake、ninja、picocom、minicom 等
- **桌面集成** - VS Code/Cursor 的 Wayland 优化启动配置

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/yourname/env-ubuntu.git
cd env-ubuntu

# 完整安装（自动检测发行版）
./install.sh -a

# 或者交互式安装
./install.sh
```

## 使用方法

### 命令行参数

```bash
# 显示帮助
./install.sh --help

# 列出所有模块
./install.sh --list

# 安装指定模块
./install.sh gcc zsh fcitx

# 指定发行版
./install.sh -d kde-neon24 -a
```

### 可用模块

| 模块 | 功能 |
|------|------|
| `gcc` | GCC 多版本安装和配置 |
| `apps` | 开发工具和常用应用 |
| `fcitx` | Fcitx5 输入法框架 |
| `zsh` | ZSH 和 Oh-My-Zsh |
| `udev` | USB 设备规则 |
| `desktop` | 桌面配置和图标 |
| `fonts` | 中文字体 |
| `libreoffice` | LibreOffice 办公套件 |

## 项目结构

```
env-ubuntu/
├── install.sh          # 统一入口脚本
├── config.sh           # 全局配置变量
├── lib/                # 模块化脚本库
│   ├── common.sh       # 公共函数
│   ├── gcc.sh          # GCC 配置
│   ├── fcitx.sh        # 输入法配置
│   ├── zsh.sh          # ZSH 配置
│   ├── udev.sh         # USB 规则
│   ├── apps.sh         # 应用安装
│   └── desktop.sh      # 桌面配置
├── distro/             # 发行版特定配置
│   ├── ubuntu22.sh
│   └── kde-neon24.sh
├── templates/          # 配置文件模板
│   ├── zshrc.template
│   ├── code.desktop
│   ├── cursor.desktop
│   └── screen.sh
├── scripts/            # 独立工具脚本
│   └── samba.sh
├── packages/           # 预打包的 deb 文件
├── assets/             # 图标等资源
└── docs/               # 文档
    └── troubleshooting.md
```

## 配置自定义

编辑 `config.sh` 修改默认配置：

```bash
# 功能开关
INSTALL_GCC=true
INSTALL_ZSH=true
INSTALL_FCITX=true
INSTALL_LIBREOFFICE=false  # 禁用 LibreOffice

# GCC 版本优先级
GCC_12_PRIORITY=120  # 数字越大优先级越高

# USB 设备规则
STM32_DEVICES=(
    "0483:df11"  # STM32 DFU
    "0483:5740"  # STM32 VCP
)
```

## 安装后配置

### GCC 版本切换

```bash
# 使用别名快速切换
gcc11  # 切换到 GCC 11
gcc12  # 切换到 GCC 12
gcc13  # 切换到 GCC 13

# 或手动选择
sudo update-alternatives --config gcc
```

### ESP-IDF 环境

```bash
# 激活 ESP-IDF 环境
get_idf
```

## 常见问题

详见 [docs/troubleshooting.md](docs/troubleshooting.md)

## 支持的发行版

- Ubuntu 22.04 LTS
- KDE Neon 24 (基于 Ubuntu 24.04)
- 其他基于 Ubuntu 的发行版（可能需要调整）

## 许可证

MIT License
