#!/bin/sh
#C/C++配置，gcc12是为了mware
sudo apt install vim git build-essential
sudo apt install gcc-12 g++-12
gcc-11 --version
gcc-12 --version
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 110
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 120
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 110
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 120
sudo update-alternatives --config gcc
sudo update-alternatives --config g++

#usb udev rules 针对bf 烧录规则
sudo usermod -a -G dialout $USER
sudo usermod -a -G plugdev $USER
echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="****", GROUP="plugdev", MODE="0664"' | sudo tee /etc/udev/rules.d/45-stm32.rules
sudo udevadm control --reload
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager

# vscode调试报错lib，net工具，com工具，转换ubix格式工具，Cursor的fuse环境，fcitx5,截图脚本需要的工具,
sudo apt install -y \
  cifs-utils picocom minicom dos2unix libncurses5 net-tools libfuse2 fonts-firacode \
  fcitx5 fcitx5-chinese-addons \
  fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2 \
  fcitx5-frontend-qt5 fcitx5-config-qt \
  drawing wl-clipboard gnome-screenshot




##################################  zsh config
# 定义要添加的内容
content='
# Custom PATH and alias configurations

# Add local bin to PATH
export PATH="$PATH:/home/rjn/.local/bin"

# Aliases for GCC versions
alias gcc11="sudo update-alternatives --set gcc /usr/bin/gcc-11 && sudo update-alternatives --set g++ /usr/bin/g++-11"
alias gcc12="sudo update-alternatives --set gcc /usr/bin/gcc-12 && sudo update-alternatives --set g++ /usr/bin/g++-12"

# Get IDF environment variables
alias get_idf=". $HOME/esp/esp-idf/export.sh"

# Add rtk-project to PATH
export PATH=$PATH:/home/ren/rtk-project/rtk-work-Rannk-gitea/spbe-rtk

# Add arm toolchain to PATH
export PATH=$PATH:/home/ren/.local/bin/gcc-arm-none-eabi-10.3-2021.10/bin
'

# 判断当前 shell 类型并决定配置文件
if [ -n "$ZSH_VERSION" ]; then
  # 当前 shell 是 zsh，写入 .zshrc
  config_file="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  # 当前 shell 是 bash，写入 .bashrc
  config_file="$HOME/.bashrc"
else
  echo "Unsupported shell. Exiting..."
  exit 1
fi

# 向相应的配置文件写入内容
echo "$content" >> "$config_file"
echo "Configurations added to $config_file"

#添加windows共享文件夹，nautilus挂载会提示参数错误，nmblookup可以查看主机名对应的ip
#echo “//192.168.1.157/7-release /home/ren/Desktop/share/liangjiahao cifs vers=3.0,uid=1000,gid=1000,defaults,nofail,x-systemd.automount 0 0” >> /etc/fstab

#基于 Electron 开发的软件在wayland的分数缩放下需要添加特定的启动参数，：https://yangqiuyi.com/blog/linux/%E5%9C%A8wayland%E6%A8%A1%E5%BC%8F%E7%9A%84vscode%E4%B8%AD%E4%BD%BF%E7%94%A8fcitx5%E8%BE%93%E5%85%A5%E4%B8%AD%E6%96%87/
cp src/* ~/.local/share/applications/
#更新启动器索引
update-desktop-database


######################################### .profile config
# 定义要添加的内容
content='
#waland下对某些程序的兼容变量。
#export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORM=xbc

#输入法设置
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export DefaultIMModule=fcitx
'
  config_file="$HOME/.profile"

# 向相应的配置文件写入内容
echo "$content" >> "$config_file"
echo "Configurations added to $config_file"

#添加windows共享文件夹，nautilus挂载会提示参数错误，nmblookup可以查看主机名对应的ip
#echo “//192.168.1.157/7-release /home/ren/Desktop/share/liangjiahao cifs vers=3.0,uid=1000,gid=1000,defaults,nofail,x-systemd.automount 0 0” >> /etc/fstab

#基于 Electron 开发的软件在wayland的分数缩放下需要添加特定的启动参数，：https://yangqiuyi.com/blog/linux/%E5%9C%A8wayland%E6%A8%A1%E5%BC%8F%E7%9A%84vscode%E4%B8%AD%E4%BD%BF%E7%94%A8fcitx5%E8%BE%93%E5%85%A5%E4%B8%AD%E6%96%87/
cp src/code* ~/.local/share/applications/
cp src/cursor* ~/.local/share/applications/
#更新启动器索引
update-desktop-database


######################################### screen config
cp src/screen.sh ~/.local/bin/
# 添加快捷键
