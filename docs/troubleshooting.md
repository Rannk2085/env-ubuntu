# 常见问题与解决方案

## 1. Samba 共享文件夹配置

### 问题描述
在命令行挂载无密码的 Windows 共享文件夹时失败。

### 解决方案
在 `/etc/samba/smb.conf` 的 `[global]` 段添加：

```ini
client min protocol = NT1
client max protocol = SMB3
client use spnego = no
client ntlmv2 auth = no
```

然后重启 Samba 服务：

```bash
sudo systemctl restart smbd
```

---

## 2. PIO 对 ESP32 调试需要 Python 2.7

### 问题描述
PlatformIO 调试 ESP32 时需要 Python 2.7 的动态库（libpython2.7.so）。

### 解决方案
手动编译安装 Python 2.7：

```bash
# 安装依赖
sudo apt update
sudo apt install build-essential libssl-dev zlib1g-dev \
                 libncurses5-dev libffi-dev libbz2-dev libreadline-dev \
                 libsqlite3-dev wget tar

# 下载并编译
wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar -xf Python-2.7.18.tgz
cd Python-2.7.18

# --enable-unicode=ucs4 是必选项，针对 PIO 调试
./configure --prefix=/usr/local --enable-shared --enable-unicode=ucs4
make -j$(nproc)
sudo make install

# 配置动态库路径
echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/python2.7.conf
sudo ldconfig
```

---

## 3. VS Code 调试缺少 libncurses5

### 问题描述
VS Code 调试 C/C++ 程序时报错找不到 libncurses5。

### 解决方案
使用项目提供的 deb 包安装：

```bash
cd env-ubuntu
sudo apt install ./packages/libtinfo5_6.4-4_amd64.deb
sudo apt install ./packages/libncurses5_6.4-4_amd64.deb
```

---

## 4. Wayland 下 Electron 应用输入法不工作

### 问题描述
在 Wayland 环境下，VS Code、Cursor 等 Electron 应用无法使用 Fcitx5 输入中文。

### 解决方案
使用带有特殊启动参数的桌面文件，参见 `templates/code.desktop` 和 `templates/cursor.desktop`。

关键启动参数：
```
--ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3
```

---

## 5. USB 设备权限问题

### 问题描述
烧录 STM32/AT32 设备时提示权限不足。

### 解决方案

1. 确保已运行 udev 规则安装：
   ```bash
   ./install.sh udev
   ```

2. 注销并重新登录（使组成员生效）

3. 检查规则是否生效：
   ```bash
   ls -la /etc/udev/rules.d/45-stm32.rules
   groups  # 确认用户在 dialout 和 plugdev 组
   ```

4. 重新插拔设备

---

## 6. Oh-My-Zsh 安装失败

### 问题描述
从 GitHub 下载 Oh-My-Zsh 安装脚本失败。

### 解决方案

使用镜像源或手动安装：

```bash
# 使用 Gitee 镜像
sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

# 或手动克隆
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
```

---

## 7. Powerlevel10k 字体显示异常

### 问题描述
终端提示符显示方块或问号。

### 解决方案

安装推荐字体：

```bash
# 方法 1: 使用包管理器
sudo apt install fonts-firacode

# 方法 2: 手动安装 MesloLGS NF 字体
# 从 https://github.com/romkatv/powerlevel10k#fonts 下载并安装
```

然后在终端设置中选择相应的 Nerd Font。
