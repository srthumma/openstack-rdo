#!/bin/bash -x

EXT_GW=${HOST_GW:-192.168.0.1}
EXT_NET=${HOST_NET:-192.168.0.0}
EXT_SUBNET_START=${EXT_SUBNET_START:-192.168.0.100}
EXT_SUBNET_END=${EXT_SUBNET_END:-192.168.0.150}

DEF_TENANT=${DEF_TENANT:-rdo-starter}
DEF_TENANT_USER=${DEF_TENANT_USER:-rdo-starter}
DEF_TENANT_PWD=${DEF_TENANT_PWD:-rdo-starter-123}

DEF_TENANT_EMAIL=${DEF_TENANT_EMAIL:-rdo@openstack.org}

#cd /root
. /root/keystonerc_admin

neutron net-create external_network --provider:network_type flat --provider:physical_network extnet  --router:external

neutron subnet-create --name public_subnet --enable_dhcp=False --allocation-pool=start=${EXT_SUBNET_START},end=${EXT_SUBNET_END} \
                        --gateway=${EXT_GW} external_network ${EXT_NET}/24

curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | glance \
         image-create --name='cirros image' --visibility=public --container-format=bare --disk-format=qcow2  
         


nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0


openstack project create --enable ${DEF_TENANT}
openstack user create --project ${DEF_TENANT} --password ${DEF_TENANT_PWD} --email ${DEF_TENANT_EMAIL} --enable ${DEF_TENANT_USER}

export OS_USERNAME=${DEF_TENANT_USER}
export OS_TENANT_NAME=${DEF_TENANT}
export OS_PASSWORD=${DEF_TENANT_PWD}

cat << EOF > ./${DEF_TENANT}.cred
export OS_USERNAME=${DEF_TENANT_USER}
export OS_TENANT_NAME=${DEF_TENANT}
export OS_PASSWORD=${DEF_TENANT_PWD}
EOF


neutron router-create ${DEF_TENANT}_router
neutron router-gateway-set ${DEF_TENANT}_router external_network

neutron net-create ${DEF_TENANT}_private_network
neutron subnet-create --name ${DEF_TENANT}_private_subnet ${DEF_TENANT}_private_network 10.1.10.0/24

neutron router-interface-add ${DEF_TENANT}_router ${DEF_TENANT}_private_subnet

neutron floatingip-create external_network

ssh-keygen -b 2048 -t rsa -f ./${DEF_TENANT}_key -q -N ""

nova keypair-add --pub-key ./${DEF_TENANT}_key.pub ${DEF_TENANT}-key

neutron net-list
nova keypair-list
nova image-list
nova secgroup-list

neutron net-list


#echo -n "Enter ${DEF_TENANT}_private_network ID and press [ENTER]: "
#read PRIV_NET_ID

nova boot --flavor m1.tiny --image "cirros image"  --nic net-name=${DEF_TENANT}_private_network \
          --security-group default --key-name ${DEF_TENANT}-key ${DEF_TENANT}-demo-instance1



neutron floatingip-list
neutron port-list
#neutron floatingip-associate de3b2be2-29d3-4ff1-83f7-2c79fedf156e  89146ad8-4e25-4878-8ac1-bb2d2f7c8907