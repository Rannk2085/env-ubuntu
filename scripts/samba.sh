#!/bin/bash
set -e

# 1. 安装 samba
echo "👉 安装 Samba"
# sudo apt update
sudo apt install -y samba

# 2. 创建共享目录
SHARE_DIR="/home/ren/share"
echo "👉 创建共享目录: $SHARE_DIR"
sudo mkdir -p "$SHARE_DIR"
sudo chmod 2770 "$SHARE_DIR"  # 目录权限，只有拥有者和组能读写
sudo chown "$USER":"$USER" "$SHARE_DIR"  # 当前用户拥有目录

# 3. 备份原始 samba 配置文件
SMB_CONF="/etc/samba/smb.conf"
if [ ! -f "${SMB_CONF}.bak" ]; then
  echo "👉 备份原始 smb.conf"
  sudo cp "$SMB_CONF" "${SMB_CONF}.bak"
fi

# 4. 添加共享配置（追加到 smb.conf）
echo "👉 配置 Samba 共享 'share'"

if sudo grep -q "^\[share\]" "$SMB_CONF"; then
  echo "共享 'share' 已存在，跳过添加配置"
else
  sudo tee -a "$SMB_CONF" > /dev/null << EOF

[share]
   path = $SHARE_DIR
   browsable = yes
   writable = yes
   guest ok = no
   read only = no
   valid users = $USER
EOF
fi

# 5. 创建 Samba 用户，密码需交互输入
echo "👉 创建 Samba 用户：$USER"
sudo smbpasswd -a "$USER"

# 6. 重启 Samba 服务
echo "👉 重启 Samba 服务"
sudo systemctl restart smbd

echo "✅ 配置完成！请用用户名 $USER 和你设置的密码访问 smb://<你的IP>/share"
