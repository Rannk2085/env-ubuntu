### 1. samba/smb.conf 修改
```shell
#在smb.conf 的global下添加，允许在命令行挂载无密码的windows共享文件夹
client min protocol = NT1
client max protocol = SMB3
client use spnego = no
client ntlmv2 auth = no
```

### pio对esp32调试需要使用python2.7.so 动态库，需手动安装
```shell
sudo apt update
sudo apt install build-essential libssl-dev zlib1g-dev \
                 libncurses5-dev libffi-dev libbz2-dev libreadline-dev \
                 libsqlite3-dev wget tar

wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar -xf Python-2.7.18.tgz
cd Python-2.7.18

#--enable-unicode=usc4 是比选项，针对pio调试的编译选项
./configure --prefix=/usr/local --enable-shared --enable-unicode=ucs4
make -j$(nproc)
sudo make install


#配置特定的动态库路径
echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/python2.7.conf
sudo ldconfig

```
