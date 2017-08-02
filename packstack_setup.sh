#!/bin/bash -x

source ./env.vars

HOSTNAME=${HOSTNAME:-rdo-control-n1}

HOST_IP=${HOST_IP:-192.168.0.60}
HOST_GW=${HOST_GW:-192.168.0.1}
INT_NAME=${INT_NAME:-em1}



yum install -y centos-release-openstack-ocata && yum update -y
yum install -y openstack-packstack


packstack --allinone --provision-demo=n --os-neutron-ovs-bridge-mappings=extnet:br-ex  --os-neutron-ml2-type-drivers=vxlan,flat


cat << EOF > /etc/sysconfig/network-scripts/ifcfg-${INT_NAME}
DEVICE=${INT_NAME}
TYPE=OVSPort
DEVICETYPE=ovs
OVS_BRIDGE=br-ex
ONBOOT=yes
NM_CONTROLLED=no
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
NM_CONTROLLED=no
EOF

rmmod kvm_intel
rmmod kvm
modprobe kvm
modprobe kvm_intel

systemctl restart network
