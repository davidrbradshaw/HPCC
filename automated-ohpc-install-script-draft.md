## Guide to Automated OpenHPC Install
#### Stanford High Performance Computing Center

1. Connect to the master node (default password is `stanford`):
```
ssh root@me344-cluster-[C].stanford.edu
```

2. Disable SELinux:
```
perl -pi -e "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
```
3. Reboot the machine:
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
chmod u+r+x test-var.sh
```
15. Run the local installation
```
./recipe.sh
```
