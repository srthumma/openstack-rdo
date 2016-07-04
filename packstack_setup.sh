#!/bin/bash -x

HOSTNAME=${HOSTNAME:-rdo-control-n1}

HOST_IP=${HOST_IP:-192.168.0.60}
HOST_GW=${HOST_GW:-192.168.0.1}



hostnamectl set-hostname "${HOSTNAME}"

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

yum install -y centos-release-openstack-mitaka && yum update -y
yum install -y openstack-packstack


packstack --allinone --provision-demo=n --os-neutron-ovs-bridge-mappings=extnet:br-ex  --os-neutron-ml2-type-drivers=vxlan,flat

mkdir /root/backup

cp /etc/sysconfig/network-scripts/ifcfg-* /root/backup # backup

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-em1
DEVICE=em1
TYPE=OVSPort
DEVICETYPE=ovs
OVS_BRIDGE=br-ex
ONBOOT=yes
EOF


cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-ex 
DEVICE=br-ex
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
DEFROUTE="yes"
IPADDR=${HOST_IP}
NETMASK=255.255.255.0  
GATEWAY=${HOST_GW} 
DNS1=${HOST_GW}
DNS2=8.8.8.8
ONBOOT=yes
EOF


service network restart

