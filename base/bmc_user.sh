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

# 用户密码
ipmitool user list 1

read -p "请输入BMC 用户名admin " bmc_user
#
ipmitool user set name 2 $bmc_user
#
read -p "请输入BMC 密码admin " bmc_passwd

ipmitool user set password 2 $bmc_passwd

ipmitool user enable 2

# 保存设置
ipmitool lan set 1 apply

ipmitool user list 1
