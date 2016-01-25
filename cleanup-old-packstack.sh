#!/bin/bash
sudo openstack-service stop
sudo su -
mysql -e "show databases" | grep -v Database | grep -v mysql| grep -v information_schema| grep -v test | gawk '{print "drop database " $1 ";"}' | mysql
exit
sudo yum remove openstack* python-openstack* puppet* *-glance* *-nova* *-heat* nagios-* -y
sudo rm -rf /etc/puppet/ /var/lib/puppet/ /etc/rabbitmq/ /etc/nova/ /etc/glance/ /etc/heat/ /etc/swift /etc/neutron/ /etc/ceilometer/ /var/lib/cinder/ /etc/nagios/ /usr/lib64/nagios/ /etc/trove/ /etc/openstack-dashboard/ /etc/ironic/
sudo sh -c 'echo "" > /etc/sysconfig/iptables'
mv ~/keystonerc_admin ~/keystonerc_admin.$(date +%s)
mv ~/keystonerc_demo ~/keystonerc_demo.$(date +%s)
echo "Please Reboot and the run the install-packstack.sh script"
echo
