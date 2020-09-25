perl -pi -e "s/NodeName=\S+/NodeName=compute-${ClusterNum}-[12-14]/" /etc/slurm/slurm.conf

perl -pi -e "s/Nodes=\S+/Nodes=ALL/" /etc/slurm/slurm.conf
