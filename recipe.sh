#!/bin/bash

inputFile=${OHPC_INPUT_LOCAL:-/opt/ohpc/pub/doc/recipes/centos7/input.local}

if [ ! -e ${inputFile} ];then
  echo "Error: Unable to access local input file -> ${inputFile}"
  exit 1
else
  . ${inputFile} || { echo "Error sourcing ${inputFile}"; exit 1; }
fi

yum -y install ohpc-base
yum -y install ohpc-warewulf

systemctl enable ntpd.service
echo "server time.stanford.edu" >> /etc/ntp.conf
systemctl restart ntpd

yum -y install ohpc-slurm-server

perl -pi -e "s/ControlMachine=\S+/ControlMachine=me344-cluster-${ClusterNum}/" /etc/slurm/slurm.conf

perl -pi -e "s/ReturnToService=1/ReturnToService=2/" /etc/slurm/slurm.conf

perl -pi -e "s/NodeName=\S+/NodeName=compute-${ClusterNum}-[12-14]/" /etc/slurm/slurm.conf

perl -pi -e "s/Nodes=\S+/Nodes=ALL/" /etc/slurm/slurm.conf

systemctl enable munge
systemctl start munge
systemctl enable slurmctld
systemctl start slurmctld

perl -pi -e "s/device = eth1/device = enp6s0f1/" /etc/warewulf/provision.conf

perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp

systemctl restart xinetd
systemctl enable mariadb.service
systemctl restart mariadb
systemctl enable httpd.service
systemctl restart httpd
systemctl enable dhcpd.service

export CHROOT=/opt/ohpc/admin/images/centos7

echo "export CHROOT=/opt/ohpc/admin/images/centos7" >> /root/.bashrc

wwmkchroot centos-7 $CHROOT

yum -y --installroot=$CHROOT install http://vault.centos.org/7.7.1908/os/x86_64/Packages/kernel-3.10.0-1062.el7.x86_64.rpm
yum -y --installroot=$CHROOT install http://vault.centos.org/7.7.1908/os/x86_64/Packages/kernel-headers-3.10.0-1062.el7.x86_64.rpm
yum -y --installroot=$CHROOT install http://vault.centos.org/7.7.1908/os/x86_64/Packages/kernel-devel-3.10.0-1062.el7.x86_64.rpm
yum -y --installroot=$CHROOT install http://vault.centos.org/7.7.1908/os/x86_64/Packages/kernel-debug-3.10.0-1062.el7.x86_64.rpm
yum -y --installroot=$CHROOT install http://vault.centos.org/7.7.1908/os/x86_64/Packages/kernel-debug-devel-3.10.0-1062.el7.x86_64.rpm

yum -y --installroot=$CHROOT install yum-plugin-versionlock 
chroot $CHROOT
yum versionlock *-3.10.0-1062.el7.x86_64
exit

yum -y --installroot=$CHROOT install ohpc-base-compute

cp -p /etc/resolv.conf $CHROOT/etc/resolv.conf

yum -y --installroot=$CHROOT install ohpc-slurm-client

yum -y --installroot=$CHROOT install ntp

yum -y --installroot=$CHROOT install lmod-ohpc ipmitool

wwinit database
wwinit ssh_keys
cat ~/.ssh/cluster.pub >> $CHROOT/root/.ssh/authorized_keys

echo "10.1.1.1:/home /home nfs nfsvers=3,nodev,nosuid,noatime 0 0" >> $CHROOT/etc/fstab
echo "10.1.1.1:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev,noatime 0 0" >> $CHROOT/etc/fstab

echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/ohpc/pub *(ro,no_subtree_check,fsid=11)" >> /etc/exports
exportfs -a
systemctl restart nfs-server
systemctl enable nfs-server

chroot $CHROOT systemctl enable ntpd
echo "server 10.1.1.1" >> $CHROOT/etc/ntp.conf

echo "*.* @10.1.1.1:514" >> $CHROOT/etc/rsyslog.conf

perl -pi -e "s/^\*\.info/\\#\*\.info/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^authpriv/\\#authpriv/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^mail/\\#mail/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^cron/\\#cron/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^uucp/\\#uucp/" $CHROOT/etc/rsyslog.conf

wwsh file import /etc/passwd
wwsh file import /etc/group
wwsh file import /etc/shadow
wwsh file import /etc/slurm/slurm.conf
wwsh file import /etc/munge/munge.key

echo "GATEWAYDEV=eth0" > /tmp/network.$$
echo "GATEWAY=10.1.1.1" >> /tmp/network.$$
wwsh -y file import /tmp/network.$$ --name network
wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0

wwbootstrap `uname -r`

wwvnfs --chroot $CHROOT

wwsh -y node new compute-${ClusterNum}-12 --ipaddr=10.${ClusterNum}.12.2 --hwaddr=${MAC_ADDR_12}
wwsh -y node new compute-${ClusterNum}-13 --ipaddr=10.${ClusterNum}.13.2 --hwaddr=${MAC_ADDR_13}
wwsh -y node new compute-${ClusterNum}-14 --ipaddr=10.${ClusterNum}.14.2 --hwaddr=${MAC_ADDR_14}

wwsh -y provision set "compute-*" --vnfs=centos7 --bootstrap=`uname -r` --files=dynamic_hosts,passwd,group,shadow,network,slurm.conf,munge.key

systemctl restart dhcpd
wwsh pxe update
