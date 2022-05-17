#!/bin/bash -e
#
#
# Post install script for RHEL Server 8.x
# created by Maheh Reddy

##################################
# Start RHEL Configuration script #
##################################
start=$(date +%s.%N)
# setup VM Name for this VM
read -p "Enter hostname (ex:- name.xxx.xxll.com) : " name
hostnamectl set-hostname $name
echo "hostname is  $name."

#Stop and disbale firewall service
for i in postfix.service firewalld.service ; do
echo "systemctl disable $i"
systemctl disable $i
echo "systemctl stop $i"
systemctl stop $i
done

#disabled selinux
out=$(sestatus | awk '{print $3}')
if [ $out == 'disabled' ];
then
  echo 'Selinux is diabled';
else
  echo 'Selinux is not enabled';
  echo 'Now using below command to disabling selinux';
  setenforce 0;
  sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config;
fi

#Chnage tuned-adm profile to throughput_performance
tuned-adm profile throughput-performance

#Change systemctl settings
file="/etc/sysctl.conf"
rm $file
cat >> /etc/sysctl.d/99-sysctl.conf <<EOF
kernel.numa_balancing=0
vm.max_map_count=262144
kernel.sched_min_granularity_ns = 10000000
kernel.sched_wakeup_granularity_ns = 15000000
vm.dirty_ratio = 40
vm.dirty_background_ratio = 10
vm.swappiness = 10
EOF

