#!/bin/sh
# check if argument was passed. If not exit.
[[ ! $(grep -i centos /etc/redhat-release) ]] && echo "script only supported on CentOS" && exit
[[ -z $1 ]] && echo "please pass the first argument containing the desired openstack password" && exit
[[ -z $2 ]] && echo "please pass the second argument containing the openstack hosts physical NIC IP" && exit
[[ -z $3 ]] && echo "please pass the third argument containing your LAN's gateway IP" && exit
[[ -z $4 ]] && echo "please pass the fourth argument containing desired domain suffix" && exit
echo "make sure to have sudo priv's AND run cleanup-old-packstack.sh before running this script"
echo
openstack_host_priv_ip=$2
gw=$3
sudo yum install -y https://www.rdoproject.org/repos/rdo-release.rpm
sudo yum install -y openstack-packstack
packstack --allinone --provision-demo=n --os-heat-install=y --os-ironic-install=y --os-trove-install=y --os-neutron-lbaas-install=y --os-heat-cfn-install=y --os-heat-cloudwatch-install=y --os-neutron-vpnaas-install=y --neutron-fwaas=y --default-password=$1
mac=$(facter macaddress_enp2s0)
sudo mv /etc/sysconfig/networking-scripts/ifcfg-enp2s0 ~/ifcfg-enp2s0-$(date +%s)
sudo mv /etc/sysconfig/networking-scripts/ifcfg-br-ex ~/ifcfg-br-ex-$(date +%s)
sudo cp ./ifcfg-enp2s0 /etc/sysconfig/networking-scripts/
sudo cp ./ifcfg-br-ex /etc/sysconfig/networking-scripts/
sed -i "s/ip/$openstack_host_priv_ip/g" /etc/sysconfig/networking-scripts/ifcfg-br-ex
sed -i "s/gateway/$gw/g" /etc/sysconfig/networking-scripts/ifcfg-br-ex
sed -i "s/macaddress/$mac/g" /etc/sysconfig/networking-scripts/ifcfg-enp2s0
sudo openstack-config --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings extnet:br-ex
sudo openstack-config --set /etc/neutron/plugin.ini ml2 type_drivers vxlan,flat,vlan
sudo sh -c "systemctl restart network.service && systemctl restart neutron-openvswitch-agent.service && systemctl restart neutron-server.service"
sudo openstack-config --set /etc/neutron/plugin.ini ml2_type_flat flat_networks physnet1,extnet
cd ~
source keystonerc_admin
neutron net-create external_network --provider:network_type flat --provider:physical_network extnet  --router:external --shared
sudo openstack-config --set /etc/nova/nova.conf DEFAULT compute_driver libvirt.LibvirtDriver
sudo openstack-config --set /etc/nova/nova.conf DEFAULT dhcp_domain $4
sudo openstack-config --set /etc/nova/nova.conf DEFAULT resume_guests_state_on_host_boot true
sudo systemctl restart openstack-nova-compute.service
sudo openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://$openstack_host_priv_ip:5000
sudo openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://$openstack_host_priv_ip:35357
sudo openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_plugin password
sudo openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_domain_id default
sudo openstack-config --set /etc/cinder/cinder.conf keystone_authtoken user_domain_id default
sudo openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_name services
sudo openstack-config --set /etc/cinder/cinder.conf keystone_authtoken username cinder
sudo openstack-config --set /etc/cinder/cinder.conf keystone_authtoken password $OS_PASSWORD
openstack-services restart cinder
openstack-services restart cinder-api

