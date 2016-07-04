#!/bin/bash -x

source ./env.vars

HOSTNAME=${HOSTNAME:-rdo-control-n1}

HOST_IP=${HOST_IP:-192.168.0.60}
HOST_GW=${HOST_GW:-192.168.0.1}
INT_NAME=${INT_NAME:-em1}


hostnamectl set-hostname "${HOSTNAME}"


mkdir /root/backup
cp /etc/sysconfig/network-scripts/ifcfg-* /root/backup # backup


cat << EOF > /etc/sysconfig/network-scripts/ifcfg-${INT_NAME}
DEVICE=${INT_NAME}
TYPE="Ethernet"
BOOTPROTO=static
DEFROUTE="yes"
IPADDR=${HOST_IP}
NETMASK=255.255.255.0  
GATEWAY=${HOST_GW} 
DNS1=${HOST_GW}
DNS2=8.8.8.8
ONBOOT=yes
PEERDNS="yes"
PEERROUTES="yes"
EOF

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

ping -t 2 google.com


