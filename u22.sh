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

# vscode调试报错lib，net工具，com工具，转换ubix格式工具，Cursor的fuse环境，
sudo apt install cifs-utils picocom minicom dos2unix libncurses5 net-tools libfuse2

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

#nmblookup可以查看主机名对应的ip
#echo “//192.168.1.157/7-release /home/ren/Desktop/share/liangjiahao cifs vers=3.0,uid=1000,gid=1000,defaults,nofail,x-systemd.automount 0 0” >> /etc/fstab


