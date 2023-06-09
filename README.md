### Linux/base/update_source.sh
更新Yum/apt源脚本（Ubuntu和CentOS自适配版）

1. 手动输入终端：  
`command -v wget` 或者 `command -v curl`  
2.1 Linux有wget:  
执行：  
`wget -O install.sh https://gitee.com/downcn/linux/raw/main/base/update_source.sh && sudo bash install.sh`   
2.2 Linux有curl:   
`curl -o install.sh https://gitee.com/downcn/linux/raw/main/base/update_source.sh && sudo bash install.sh`   