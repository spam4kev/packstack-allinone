#!/bin/sh
# check if argument was pass. If not exit
[[ -z $1 ]] && echo "this script takes an argument containing the desired openstack password" && exit
packstack --allinone --provision-demo=n --os-heat-install=y --os-ironic-install=y --os-trove-install=y --os-neutron-lbaas-install=y --os-heat-cfn-install=y --os-heat-cloudwatch-install=y --os-neutron-vpnaas-install=y --neutron-fwaas=y --default-password=$1

