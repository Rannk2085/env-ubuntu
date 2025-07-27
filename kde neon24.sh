#!/bin/sh

# 启动参数，cursor需要no-sandbox,
# --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=1 %F

##################  C/C++配置，gcc12是为了mware
sudo apt install vim git build-essential
sudo apt install gcc-12 g++-12
gcc-11 --version
gcc-12 --version
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 130
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 120
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 130
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 120
sudo update-alternatives --config gcc
sudo update-alternatives --config g++


##################### usb udev rules 针对bf 烧录规则
sudo usermod -a -G dialout $USER
sudo usermod -a -G plugdev $USER
echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="****", GROUP="plugdev", MODE="0664"' | sudo tee /etc/udev/rules.d/45-stm32.rules
sudo udevadm control --reload
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager


####################### 软件安装
# vscode调试报错lib，net工具，com工具，转换ubix格式工具，Cursor的fuse环境，fcitx5,截图脚本需要的工具,
sudo apt install -y \
  cifs-utils exfatprogs picocom minicom dos2unix net-tools libfuse2 fonts-firacode \
  fcitx5 fcitx5-chinese-addons \
  fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2 \
  fcitx5-frontend-qt5 fcitx5-config-qt
# 安装补充字体
sudo apt install -y fonts-noto-cjk fonts-arphic-uming fonts-wqy-zenhei fonts-wqy-microhei fonts-hanazono
# 使用pkcon安装office
pkcon install libreoffice
# 先安装依赖包，然后安装libncurses5 以支持vscode调试。
sudo apt install ./pkg/libtinfo5_6.4-4_amd64.deb ./pkg/libncurses5_6.4-4_amd64.deb
# 安装betaflight configurator需要的ubuntu22 老库
sudo apt remove -y libgconf-2-4 gconf2-common || true
sudo apt autoremove -y
wget -c http://mirrors.ustc.edu.cn/ubuntu/pool/universe/g/gconf/gconf2-common_3.2.6-7ubuntu2_all.deb
wget -c http://mirrors.ustc.edu.cn/ubuntu/pool/universe/g/gconf/libgconf-2-4_3.2.6-7ubuntu2_amd64.deb
sudo dpkg -i gconf2-common_3.2.6-7ubuntu2_all.deb
sudo dpkg -i libgconf-2-4_3.2.6-7ubuntu2_amd64.deb
sudo apt -f install -y
ldconfig -p | grep libgconf || echo "❌ libgconf 安装失败"
# 安装python3 在安装esp-idf时缺少的库
sudo apt install python3.12-venv
# 定义要添加的内容
content='
export XMODIFIERS=@im=fcitx
'
  config_file="$HOME/.profile"
# 向相应的配置文件写入内容
echo "$content" >> "$config_file"
echo "Configurations added to $config_file"




##################################  zsh config
# 定义要添加的内容
sudo apt install zsh
chsh -s /bin/zsh
sudo chsh -s /bin/zsh
# 跟换shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 安装oh-my-zsh
# su
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 给root安装oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
# 安装主题
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
cp src/.zshrc /home/ren/.zshrc





#添加windows共享文件夹，nautilus挂载会提示参数错误，nmblookup可以查看主机名对应的ip
#echo “//192.168.1.157/7-release /home/ren/Desktop/share/liangjiahao cifs vers=3.0,uid=1000,gid=1000,defaults,nofail,x-systemd.automount 0 0” >> /etc/fstab

#基于 Electron 开发的软件在wayland的分数缩放下需要添加特定的启动参数，：https://yangqiuyi.com/blog/linux/%E5%9C%A8wayland%E6%A8%A1%E5%BC%8F%E7%9A%84vscode%E4%B8%AD%E4%BD%BF%E7%94%A8fcitx5%E8%BE%93%E5%85%A5%E4%B8%AD%E6%96%87/
# cp src/code* ~/.local/share/applications/
# cp src/cursor* ~/.local/share/applications/
#更新启动器索引
# update-desktop-database


######################################### screen config
# cp src/screen.sh ~/.local/bin/
# 添加快捷键

# 添加cursor icon
mkdir -p ~/.local/share/icons/hicolor/128x128/apps/
cp icon/cursor.png ~/.local/share/icons/hicolor/128x128/apps/cursor.png

