## Stanford High Performance Computing Center

## Guide to Automated OpenHPC Install

[C] is your cluster number. For example, if you are configuring cluster 10, replace [C] with 10. 

1. Connect to your master node (default password is `stanford`):
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

5. Retrieve the recipe script
```
cd /
wget https://raw.githubusercontent.com/davidrbradshaw/HPCC/master/CS74/recipe.sh
```

6. Retrieve the input.local file and edit it to your system's settings.
```
wget https://raw.githubusercontent.com/davidrbradshaw/HPCC/master/CS74/input.local

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
ipmitool -H 10.2.2.2 -U USERID -P PASSW0RD chassis power cycle
```

11. To verify that the compute nodes have booted, you can ping their hostname, i.e:

```ping compute-1-1```

The output should resemble this:
```
PING compute-1-12.localdomain (10.1.12.2) 56(84) bytes of data.
64 bytes from compute-1-1.localdomain (10.1.12.2): icmp_seq=1 ttl=64 time=0.244 ms
64 bytes from compute-1-1.localdomain (10.1.12.2): icmp_seq=2 ttl=64 time=0.257 ms
64 bytes from compute-1-1.localdomain (10.1.12.2): icmp_seq=3 ttl=64 time=0.253 ms
```
