#!/bin/bash
# 更新Yum/apt源脚本（Ubuntu和CentOS和华为欧拉openEuler自适配版）
# 作者：mvfeng
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
    openEuler)
        echo "Detected openEuler"
        url="http://mirrors.aliyun.com/openeuler/"
        ;;    
    *)
        echo "Unsupported system"
        exit 1
esac

# 备份原有Yum源文件
if [[ $os == "centos" || $os == "rhel" ]]; then
    cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
	# 先替换全部为官方源 CentOs Linux7/8从2021.10.31号后已经停止维护，更新镜像需要通过 vault.centos.org来获取更新。
	sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
	sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
    # 检查 wget 是否存在
    if command -v wget &> /dev/null; then
	# 后替换基础核心源 阿里源
        wget -O /etc/yum.repos.d/CentOS-Base.repo $url
    else
        # 检查 curl 是否存在
        if ! command -v curl &> /dev/null; then
            echo "Neither wget nor curl found, please install one of them and retry."
            exit 1
        fi
	# 后替换基础核心源 阿里源
        curl -o /etc/yum.repos.d/CentOS-Base.repo $url
    fi
    # 上面是CentOS Stream源（centos-stream）8.5.2111
    # 下面是CentOS过期源（centos-vault）非8.5.2111
    version=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ "$version" != "8.5.2111" ]; then
        sudo sed -i "s|com/centos/\$releasever|com/centos-vault/\$releasever|g" /etc/yum.repos.d/CentOS-Base.repo
        sudo sed -i "s/\$releasever/$version/g" /etc/yum.repos.d/CentOS-Base.repo
    fi
    # 清除Yum缓存并生成新的缓存
    yum clean all
    yum makecache
elif [[ $os == "ubuntu" ]]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sed -i "s#http://archive.ubuntu.com/#$url#g" /etc/apt/sources.list
    sed -i "s#http://security.ubuntu.com/#$url#g" /etc/apt/sources.list
    apt update
elif [[ $os == "openEuler" ]]; then
    cp /etc/yum.repos.d/openEuler.repo /etc/yum.repos.d/openEuler.repo.bak
    sed -i "s#http://repo.openeuler.org/#$url#g" /etc/yum.repos.d/openEuler.repo
    sed -i "s#https://mirrors.openeuler.org/#$url#g" /etc/yum.repos.d/openEuler.repo
    # 清除Yum缓存并生成新的缓存
    yum clean all
    yum makecache
fi

echo "$os 源已更新完成。"
