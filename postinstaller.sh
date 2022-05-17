#!/bin/bash -e
#
#
# Post install script for RHEL Server 8.x
# created by Maheh Reddy

##################################
# Start RHEL_DISK Configuration script #
##################################

#Current Partition list
echo current parttion list....
cat /proc/partitions

#Make partition and create ext4 filesystem using parted
echo creating parttion using parted....
for disk in /dev/sd{b,c,d,e,f,g} ; do
echo $disk
 parted  $disk mklabel gpt
 parted  $disk mkpart primary 2048s 100%
 partprobe $disk
 mkfs.ext4 ${disk}1
done

#Create directories
echo creating all required directories....
rm -rf /opt/db/*
sudo mkdir -p /opt/db/{data1,data2,log,tempdb,templog,backup}

#Get the UUID number for each device
echo getting the all UUID numbers....
for disk in /dev/sd{b,c,d,e,f,g} ; do
if [[ "${disk: -1}" == "b" ]];then
   mntp='/opt/db/data1'
elif [[ "${disk: -1}" == "c" ]];then
   mntp='/opt/db/data2'
elif [[ "${disk: -1}" == "d" ]];then
   mntp='/opt/db/templog'
elif [[ "${disk: -1}" == "d" ]];then
   mntp='/opt/db/tempdb'
elif [[ "${disk: -1}" == "e" ]];then
   mntp='/opt/db/log'
elif [[ "${disk: -1}" == "f" ]];then
   mntp='/opt/db/backup'
else
   echo "wrong disk"
   exit
fi
UUID=`blkid ${disk}1 |awk '{print $2}'|sed 's/"//g'`
sed -i "/$UUID/d" /etc/fstab
echo "${UUID}       $mntp  ext4 auto,user,rw 0 0" >>/etc/fstab
done

#change ownership to below directories
echo changing ownership to below directories as  msssql...
chown mssql:mssql /opt/db/{data1,data2,log,tempdb,templog,backup}

#MOunt the all directories
echo mounting all directories....
mount -a
export PATH=/opt/mssql/bin:/opt/mssql-tools/bin:$PATH

#Check the SQL SERVER STATUS
systemctl status mssql-server.service
