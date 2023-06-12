### Linux/base/update_source.sh
更新Yum/apt源脚本（Ubuntu和CentOS自适配版）

1.1. 手动输入终端：  
```
command -v wget  或者  command -v curl 
```
1.2. Linux有wget则运行:  
```
wget --no-check-certificate -O - https://gitee.com/downcn/linux/raw/main/base/update_source.sh | sudo bash -s
```
1.3.  Linux有curl则运行:   
```
curl -sSL https://gitee.com/downcn/linux/raw/main/base/update_source.sh | sudo bash -s
```
1.4.  更换源完成

