[root@176 install]# cat bmc_ip.sh
#!/bin/bash
#配置bmc ip脚本（Ubuntu和CentOS自适配版）
#作者：mvfeng
#时间：2023年8月14日
#检查ipmitool是否已安装
if ! command -v ipmitool &> /dev/null; then
    echo "尚未安装ipmitool，请根据您的操作系统类型安装该工具。"

    # 检查操作系统类型
    if [ -f "/etc/centos-release" ]; then
        echo "正在安装ipmitool..."
        yum install -y ipmitool
    elif [ -f "/etc/os-release" ]; then
        echo "正在安装ipmitool..."
        apt-get update
        apt-get install -y ipmitool
    else
        echo "无法确定操作系统类型，请手动安装ipmitool。"
        exit 1
    fi
fi

ipmitool lan print 1

# 用户交互获取BMC IP地址
read -p "请输入BMC IP地址:172.17.x.x " bmc_ip

# 用户交互获取子网掩码
read -p "请输入子网掩码:255.255.255.0 " netmask

# 用户交互获取网关
read -p "请输入网关:172.17.x.x " gateway

# 用户交互获取DNS服务器
read -p "请输入DNS服务器:114.114.114.114 " dns_server

# 设置BMC IP地址
ipmitool lan set 1 ipaddr $bmc_ip

# 设置网关
ipmitool lan set 1 netmask $netmask
ipmitool lan set 1 defgw ipaddr $gateway

# 设置DNS服务器
ipmitool lan set 1 ipsrc static
ipmitool lan set 1 dns1 $dns_server

# 保存设置
ipmitool lan set 1 apply

ipmitool lan print 1
