## Guide to CentOS Install and Automated OpenHPC Configuration

### Stanford High Performance Computing Center

NOTE: Text surrounded by brackets (inclusive of the brackets) is to be replaced with a relevant parameter value. For example, if your cluster number is seven, then the following instruction:
```
ipmitool -H me344-cluster-[ClusterNum]-ipmi -U USERID -P PASSW0RD chassis bootdev pxe
```
should be executed as:
```
ipmitool -H me344-cluster-7-ipmi -U USERID -P PASSW0RD chassis bootdev pxe
```

#### CentOS Installation

1. Log into your cluster:
```
ssh [sunetid]@me344-cluster.stanford.edu
```
2. Set the next boot to PXE:
```
ipmitool -H me344-cluster-[ClusterNum]-ipmi -U USERID -P PASSW0RD chassis bootdev pxe
```
3. Power cycle the cluster. This will end your session with the cluster.
```
ipmitool -H me344-cluster-[ClusterNum]-ipmi -U USERID -P PASSW0RD chassis power cycle
```
4. Message staff to provision your cluster with the operating system. 

Normally, this is done in-person at the physical clusters. Due to restrictions on facility access, staff will provision the operating system remotely. 

5. You will need to wait a few minutes after staff provision the cluster. Then re-connect and login through SSH. 

6. Modify `/etc/hosts` so the machine knows its hostname. NNN is the last octet of the public IP address for the cluster which is listed in network information document. 
```
echo "171.64.116.[NNN] me344-cluster-[ClusterNum].stanford.edu" >> /etc/hosts
echo "10.1.1.1 me344-cluster-[ClusterNum].localdomain me344-cluster-[ClusterNum]" >> /etc/hosts
```
#### Open HPC Installation

1. Disable SELinux:
```
perl -pi -e "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
```
2. Reboot the machine. Your session with the cluster will end, and you will need to wait a few minutes before you can re-connect.
```
reboot
```
3. Re-connect and login through SSH. Note: 

4. Verify that SELinux is disabled:
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

wget https://raw.githubusercontent.com/davidrbradshaw/HPCC/master/input.local

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
