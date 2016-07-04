#!/bin/bash -x

EXT_GW=${HOST_GW:-192.168.0.1}
EXT_NET=${HOST_NET:-192.168.0.0}
EXT_SUBNET_START=${EXT_SUBNET_START:-192.168.0.100}
EXT_SUBNET_END=${EXT_SUBNET_END:-192.168.0.150}

DEF_TENANT=${DEF_TENANT:-rdo-starter}
DEF_TENANT_USER=${DEF_TENANT_USER:-rdo-starter}
DEF_TENANT_PWD=${DEF_TENANT_PWD:-rdo-starter-123}

DEF_TENANT_EMAIL=${DEF_TENANT_EMAIL:-rdo@openstack.org}

cd /root
. keystonerc_admin

neutron net-create external_network --provider:network_type flat --provider:physical_network extnet  --router:external

neutron subnet-create --name public_subnet --enable_dhcp=False --allocation-pool=start=${EXT_SUBNET_START},end=${EXT_SUBNET_END} \
                        --gateway=${EXT_GW} external_network ${EXT_NET}/24

curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | glance \
         image-create --name='cirros image' --visibility=public --container-format=bare --disk-format=qcow2  
         


openstack project create --enable ${DEF_TENANT}
openstack user create --project ${DEF_TENANT} --password ${DEF_TENANT_PWD} --email ${DEF_TENANT_EMAIL} --enable ${DEF_TENANT}

export OS_USERNAME=${DEF_TENANT_USER}
export OS_TENANT_NAME=${DEF_TENANT}
export OS_PASSWORD=${DEF_TENANT_PWD}


neutron router-create ${DEF_TENANT}_router
neutron router-gateway-set ${DEF_TENANT}_router external_network

neutron net-create ${DEF_TENANT}_private_network
neutron subnet-create --name ${DEF_TENANT}_private_subnet ${DEF_TENANT}_private_network 10.1.10.0/24

neutron router-interface-add ${DEF_TENANT}_router ${DEF_TENANT}_private_subnet

