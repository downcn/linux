#!/bin/bash

# 配置host ip脚本（Ubuntu和CentOS自适配版）
# 作者：mvfeng & chatgpt3.5
# 时间：2023年8月14日

# 判断系统版本
os=$(cat /etc/os-release | grep -w "ID" | awk -F '=' '{print $2}' | sed 's/"//g')

# 检查nmcli命令是否可用
check_nmcli() {
    if ! command -v nmcli &> /dev/null; then
        echo "请安装NetworkManager (nmcli)来管理网络连接."
        echo "在Ubuntu上，请使用以下命令安装："
        echo "sudo apt-get update"
        echo "sudo apt-get install network-manager"
        exit 1
    fi
}

# 获取所有可用网卡名称和连接状态
get_network_interfaces() {
    network_interfaces=($(ip link show | grep -oP '(?<=^\d: ).*(?=: <)'))
    interface_states=($(ip link show | grep -oP '(?<=state )\S+'))

    for ((i=0; i<${#network_interfaces[@]}; i++)); do
      if [[ ${interface_states[$i]} == "UP" ]]; then
        network_interfaces[$i]="${network_interfaces[$i]}(connect)"
      else
        network_interfaces[$i]="${network_interfaces[$i]}(disconnect)"
      fi
    done

    echo "${network_interfaces[@]}"
}

# 让用户选择要进行配置的网卡
select_network_interface() {
    network_interfaces=($(get_network_interfaces))
    echo "请选择要进行配置的网卡:"
    for ((i=0; i<${#network_interfaces[@]}; i++)); do
        echo "$(($i+1)). ${network_interfaces[$i]}"
    done

    read -p "请输入选项: " choice

    network_interfaces=${network_interfaces[$(($choice-1))]}
    selected_interface=$(echo "$network_interfaces" | sed -e 's/([^)]*)//g')
    echo "已选择的网卡: $selected_interface"
}

# 定义函数以设置静态IP
set_static_ip() {
    select_network_interface
    network_interface=$selected_interface

    read -p "请输入静态IP地址[172.17.1.Y]: " ip_address
    read -p "请输入子网掩码[24]: " subnet_mask
    read -p "请输入网关[172.17.1.254]: " gateway
    read -p "请输入首选DNS服务器[114.114.114.114]: " dns_primary
    read -p "请输入备用DNS服务器[8.8.8.8]: " dns_secondary

    # 使用nmcli设置静态IP
    nmcli con mod $network_interface ipv4.method manual
    nmcli con mod $network_interface ipv4.addresses $ip_address/$subnet_mask
    nmcli con mod $network_interface ipv4.gateway $gateway
    nmcli con mod $network_interface ipv4.dns "$dns_primary $dns_secondary"

    # 重启网络接口
    nmcli con down $network_interface
    nmcli con up $network_interface
}

# 定义函数以设置动态IP
set_dynamic_ip() {
    select_network_interface
    network_interface=$selected_interface

    # 使用nmcli设置动态IP
    nmcli con mod $network_interface ipv4.method auto

    # 重启网络接口
    nmcli con down $network_interface
    nmcli con up $network_interface
}

# 检查nmcli命令是否可用
check_nmcli

# 主菜单
while true; do
    echo "请选择要进行的配置:"
    echo "1. 设置静态IP"
    echo "2. 设置动态IP"
    echo "3. 退出"

    read -p "请输入选项: " choice

    case $choice in
        1) set_static_ip;;
        2) set_dynamic_ip;;
        3) exit;;
        *) echo "无效选项";;
    esac

    echo ""
done
