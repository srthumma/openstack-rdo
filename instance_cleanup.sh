#!/bin/bash -x

source ./env.vars



. /root/keystonerc_admin

glance image-list

neutron net-list
nova keypair-list
nova image-list
nova secgroup-list

neutron net-list

neutron floatingip-list
neutron port-list

#neutron floatingip-associate de3b2be2-29d3-4ff1-83f7-2c79fedf156e  89146ad8-4e25-4878-8ac1-bb2d2f7c8907


#glance image-delete IMAGE

#nova delete 0e4011a4-3128-4674-ab16-dd1b7ecc126e




