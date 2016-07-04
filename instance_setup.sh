#!/bin/bash -x

source ./env.vars



. /root/keystonerc_admin

neutron net-create external_network --provider:network_type flat --provider:physical_network extnet  --router:external

neutron subnet-create --name public_subnet --enable_dhcp=False --allocation-pool=start=${EXT_SUBNET_START},end=${EXT_SUBNET_END} \
                        --gateway=${EXT_GW} external_network ${EXT_NET}/24


curl ${CIRROS_IMAGE_URL} | \
    glance image-create --name="${CIRROS_IMAGE_NAME}" \
                        --visibility=public \
                        --container-format=bare \
                        --disk-format=qcow2
glance image-list


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


nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

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

nova boot --flavor m1.tiny --image "${CIRROS_IMAGE_NAME}" \
		  --nic net-name=${DEF_TENANT}_private_network \
          --security-group default \
          --key-name ${DEF_TENANT}-key \
           ${DEF_TENANT}-demo-instance1



neutron floatingip-list
neutron port-list

#neutron floatingip-associate de3b2be2-29d3-4ff1-83f7-2c79fedf156e  89146ad8-4e25-4878-8ac1-bb2d2f7c8907




