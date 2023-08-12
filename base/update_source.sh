#!/bin/bash

# 更新Yum/apt源脚本（Ubuntu和CentOS自适配版）
# 作者：mvfeng & chatgpt3.5
# 时间：2023年6月8日

# 判断是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# 判断系统是否为CentOS或RedHat或Ubuntu
os=$(cat /etc/os-release | grep '^ID=' | cut -d= -f2 | tr -d '"')
case $os in
    centos|rhel)
        echo "Detected CentOS or RedHat"
        version=$(cat /etc/os-release | grep '^VERSION_ID=' | cut -d= -f2 | sed 's/"//g')
        case $version in
            7)
                url="http://mirrors.aliyun.com/repo/Centos-7.repo"
                ;;
            8)
                url="http://mirrors.aliyun.com/repo/Centos-8.repo"
                ;;
            *)
                echo "Unsupported CentOS version"
                exit 1
        esac
        ;;
    ubuntu)
        echo "Detected Ubuntu"
        url="http://mirrors.aliyun.com/ubuntu/"
        ;;
    *)
        echo "Unsupported system"
        exit 1
esac

# 备份原有Yum源文件
if [[ $os == "centos" || $os == "rhel" ]]; then
    cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
    # 检查 wget 是否存在
    if command -v wget &> /dev/null; then
        wget -O /etc/yum.repos.d/CentOS-Base.repo $url
    else
        # 检查 curl 是否存在
        if ! command -v curl &> /dev/null; then
            echo "Neither wget nor curl found, please install one of them and retry."
            exit 1
        fi
        curl -o /etc/yum.repos.d/CentOS-Base.repo $url
    fi
    # 清除Yum缓存并生成新的缓存
    yum clean all
    yum makecache
elif [[ $os == "ubuntu" ]]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sed -i "s#http://archive.ubuntu.com/#$url#g" /etc/apt/sources.list
    sed -i "s#http://security.ubuntu.com/#$url#g" /etc/apt/sources.list
    apt update
fi

echo "$os 源已更新完成。"
