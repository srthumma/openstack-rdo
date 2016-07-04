#!/bin/bash -x

INT_NAME=${1:-em1}
HOST_IP=${2:-172.16.1.60}
HOST_GW=${3:-172.16.1.1}



cat << EOF > /etc/sysconfig/network-scripts/ifcfg-${INT_NAME}
DEVICE=${INT_NAME}
TYPE="Ethernet"
BOOTPROTO=static
DEFROUTE=no
IPADDR=${HOST_IP}
NETMASK=255.255.255.0  
GATEWAY=${HOST_GW} 
DNS1=${HOST_GW}
DNS2=8.8.8.8
ONBOOT=yes
PEERDNS="yes"
PEERROUTES="yes"
EOF


systemctl restart network

sleep 2 

ping  -c 3 google.com


