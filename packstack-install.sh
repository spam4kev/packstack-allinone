#!/bin/sh
# check if argument was pass. If not exit
[[ -z $1 ]] && echo "please pass the first argument containing the desired openstack password" && exit
[[ -z $2 ]] && echo "please pass the second argument containing the openstack private IP" && exit
[[ -z $3 ]] && echo "please pass the second argument containing your LAN's gateway IP" && exit
openstack_host_priv_ip=$2
gw=$3
packstack --allinone --provision-demo=n --os-heat-install=y --os-ironic-install=y --os-trove-install=y --os-neutron-lbaas-install=y --os-heat-cfn-install=y --os-heat-cloudwatch-install=y --os-neutron-vpnaas-install=y --neutron-fwaas=y --default-password=$1

