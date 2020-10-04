## Guide to Automated OpenHPC Install, with CentOS

#### Stanford High Performance Computing Center

#### CentOS Installation

1. Log into your cluster:
```
ssh [sunetid]@me344-cluster.stanford.edu
```
2. Set the next boot to PXE:
```
ipmitool -H me344-cluster-[ClusterNum]-ipmi -U USERID -P PASSW0RD chassis bootdev pxe
```
3. Reboot the machine:
```
ipmitool -H me344-cluster-[ClusterNum]-ipmi -U USERID -P PASSW0RD chassis power cycle
```
4. Message staff to provision your cluster with the operating system. 

Normally, this is done in-person at the physical clusters. Due to restrictions on facility access, staff will provision the operating system remotely. 

5. Re-log into your cluster

6. Modify `/etc/hosts` so the machine knows its hostname. NNN is the last octet of the public IP address for the cluster which is listed in network information document. 
```
echo "171.64.116.[NNN] me344-cluster-[ClusterNum].stanford.edu" >> /etc/hosts
echo "10.1.1.1 me344-cluster-[ClusterNum].localdomain me344-cluster-[ClusterNum]" >> /etc/hosts
```
#### Open HPC Installation

1. Connect to the master node (default password is `stanford`):
```
ssh root@me344-cluster-[ClusterNum].stanford.edu
```

2. Disable SELinux:
```
perl -pi -e "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
```
3. Reboot the machine:

Note: Your connection to the cluster will end, and you need to wait a few minutes while the cluster reboot before you can re-connect. 
```
reboot
```
4. Once rebooted, connect through SSH and verify that SELinux is disabled:
```
sestatus
```

### The below section can be further automated
5. Disable the firewall service
```
systemctl stop firewalld
systemctl disable firewalld
```
6. Add kernel pacakges:
```
yum -y install http://vault.centos.org/7.7.1908/os/x86_64/Packages/kernel-debug-3.10.0-1062.el7.x86_64.rpm
yum -y install http://vault.centos.org/7.7.1908/os/x86_64/Packages/kernel-debug-devel-3.10.0-1062.el7.x86_64.rpm
```
7. Lock kernel version:
```
yum -y install yum-plugin-versionlock 
yum versionlock *-3.10.0-1062.el7.x86_64
```
8. Install the repository for OpenHPC
```
yum -y install http://build.openhpc.community/OpenHPC:/1.3/CentOS_7/x86_64/ohpc-release-1.3-1.el7.x86_64.rpm 
```
9. Install the docs-ohpc package:
```
yum -y install docs-ohpc
```
10A Option. For more tailored installations, copy the docs-ohpc template input file to define local site settings:
```
cp -p /opt/ohpc/pub/doc/recipes/centos7/input.local input.local
```
10B Option. For simple installations, copy the following template input file to define local site settings:
```
rm /opt/ohpc/pub/doc/recipes/centos7/input.local

wget -P /opt/ohpc/pub/doc/recipes/centos7 https://raw.githubusercontent.com/davidrbradshaw/HPCC/master/input.local

wget -P https://raw.githubusercontent.com/davidrbradshaw/HPCC/master/input.local

```
11. Edit input.local with a text editor to the desired settings

12A Option. For more tailored installations, copy the docs-ohpc template installation script:
```
cp -p /opt/ohpc/pub/doc/reciples/vanilla/recipe.sh .
```
12B Option. For simple installations, copy this template installation script, DRAFT:
```
wget https://raw.githubusercontent.com/davidrbradshaw/HPCC/master/recipe.sh
```
13. Use environment variable to define local input file:
```
export OHPC_INPUT_LOCAL=./input.local
```
14. Open access to the installation file:
```
chmod u+r+x recipe.sh
```
15. Run the local installation
```
./recipe.sh
```
