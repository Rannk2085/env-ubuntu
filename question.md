### 1. samba/smb.conf 修改
```
#在smb.conf 的global下添加，允许在命令行挂载无密码的windows共享文件夹
client min protocol = NT1
client max protocol = SMB3
client use spnego = no
client ntlmv2 auth = no
```
