#!/bin/sh
#!/bin/sh
# check if argument was passed. If not exit.
[[ -z $1 ]] && echo "please pass the first argument containing the desired openstack password" && exit
[[ -z $2 ]] && echo "please pass the second argument containing the openstack hosts physical NIC IP" && exit
[[ -z $3 ]] && echo "please pass the second argument containing your LAN's gateway IP" && exit
openstack_host_priv_ip=$2
gw=$3
mac=$(facter macaddress_enp2s0)
packstack --allinone --provision-demo=n --os-heat-install=y --os-ironic-install=y --os-trove-install=y --os-neutron-lbaas-install=y --os-heat-cfn-install=y --os-heat-cloudwatch-install=y --os-neutron-vpnaas-install=y --neutron-fwaas=y --default-password=$1
sudo mv /etc/sysconfig/networking-scripts/ifcfg-enp2s0 ~/ifcfg-enp2s0-$(date +%s)
sudo mv /etc/sysconfig/networking-scripts/ifcfg-br-ex ~/ifcfg-br-ex-$(date +%s)
sudo cp ./ifcfg-enp2s0 /etc/sysconfig/networking-scripts/
sudo cp ./ifcfg-br-ex /etc/sysconfig/networking-scripts/
sed -i "r/ip/$openstack_host_priv_ip/g" /etc/sysconfig/networking-scripts/ifcfg-br-ex
sed -i "r/gateway/$gw/g" /etc/sysconfig/networking-scripts/ifcfg-br-ex
sed -i "r/macaddress/$mac/g" /etc/sysconfig/networking-scripts/ifcfg-enp2s0