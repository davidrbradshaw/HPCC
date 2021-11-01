## Guide to Automated OpenHPC Install
#### Stanford High Performance Computing Center

[C] is the cluster number, and [N] is the compute node number. For example, if you are configuring cluster 10, replace [C] with 10. Replace [N] with 12, 13, and 14 to make modifications to compute nodes 12, 13, and 14.

1. Connect to the master node (default password is `stanford`):
```
ssh root@hpcc-cluster-[C].stanford.edu
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
### start of new script
5. Retrieve the recipe script
```
cd /
wget https://raw.githubusercontent.com/davidrbradshaw/HPCC/master/recipe.sh
```
6. Retrieve the input.local file and edit it to your system's settings.
```
wget https://raw.githubusercontent.com/davidrbradshaw/HPCC/master/input.local

nano input.local
```
7. Use environment variable to define local input file:
```
export OHPC_INPUT_LOCAL=./input.local
```
8. Open access to the installation file:
```
chmod u+r+x recipe.sh
```
9. Run the local installation
```
./recipe.sh
```

10. Run this command for each compute node 
```
ipmitool -H 10.[C].[N].3 -U USERID -P PASSW0RD chassis power cycle
```

11. To verify that the compute nodes have booted, you can ping their hostname, i.e:

```ping compute-1-12```

The output should resemble this:
```
PING compute-1-12.localdomain (10.1.12.2) 56(84) bytes of data.
64 bytes from compute-1-12.localdomain (10.1.12.2): icmp_seq=1 ttl=64 time=0.244 ms
64 bytes from compute-1-12.localdomain (10.1.12.2): icmp_seq=2 ttl=64 time=0.257 ms
64 bytes from compute-1-12.localdomain (10.1.12.2): icmp_seq=3 ttl=64 time=0.253 ms
```
