
Make sure to understand how to build [development and test environments with virtual machine](../libvirt.md).

The **configuration is deployed using Chef** with the [sys](https://github.com/GSI-HPC/sys-chef-cookbook) cookbook.

Slurm has the capability to simulate resources on execution nodes for testing:

* Set `FastSchedule=2` in order to emulate nodes with more resources then physically available by defining them with NodeName.
* Set `ReturnToService=1` to prevent nodes from been set to state down due to limitations like "low memory". This can help to emulate non existed memory resources on test nodes. 

**Slurm configuration files are located in [var/slurm/][slurm_basic].**

# Deployment

## Account Database

Create a virtual machine to host the database server called **lxdb01.devops.test**

```bash
>>> virsh-instance -O shadow debian64-9 lxdb01.devops.test
>>> cd $VM_INSTANCE_PATH/lxdb01.devops.test
>>> ssh-exec -r 'echo lxdb01 > /etc/hostname ; hostname lxdb01 ; hostname -f'
lxdb01.devops.test
```

Deploy role [account_database][account_database.rb], to install a MySQL database. 

```bash
>>> chef-remote cookbook sys 
>>> chef-remote role $SCRIPTS/var/chef/roles/debian/slurm/account_database.rb
>>> chef-remote -r "role[account_database]" solo
```

Grant the `slurm` user access to the database

```bash
>>> ssh-exec -r 'sed -i "s/^bind-address/#bind-address/" /etc/mysql/mysql.conf.d/mysqld.cnf'
>>> ssh-exec -r "grep -e '^user' -e '^password' /etc/mysql/debian.cnf"
>>> ssh-exec -r "mysql -u debian-sys-maint -p"
mysql> grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by '12345678' with grant option;
mysql> grant all on slurm_acct_db.* TO 'slurm'@'lxrm01' identified by '12345678' with grant option;
mysql> grant all on slurm_acct_db.* TO 'slurm'@'lxrm01.devops.test' identified by '12345678' with grant option;
mysql> select User,Host from mysql.user where User = 'slurm';
[…]
mysql> quit
>>> ssh-exec -r 'systemctl restart mysql'
```
## Cluster Controller

Create a virtual machine to host the Slurm cluster controller called **lxrm01.devops.test** 

```bash
>>> virsh-instance -O shadow debian64-9 lxrm01.devops.test
>>> slurm-cc() { cd $VM_INSTANCE_PATH/lxrm01.devops.test ; ssh-exec -r $@ ; cd - >/dev/null }
>>> slurm-cc 'echo lxrm01 > /etc/hostname ; hostname lxrm01 ; hostname -f'
lxrm01.devops.test
```

Deploy role [cluster_controller][cluster_controller.rb], to install slurmctld, and slurmdbd

```bash
>>> cd $VM_INSTANCE_PATH/lxrm01.devops.test
>>> chef-remote cookbook sys 
>>> chef-remote role $SCRIPTS/var/chef/roles/debian/slurm/cluster_controller.rb
>>> chef-remote -r "role[cluster_controller]" solo
```

Deploy a basic Slurm configuration from [slurm/basis][slurm_basic]

```bash
>>> slurm-cc -r 'systemctl restart munge nfs-kernel-server ; exportfs -r && exportfs'
>>> ssh-sync -r $SCRIPTS/var/slurm/ :/etc/slurm-llnl
>>> slurm-cc 'systemctl restart slurmdbd'
```

Manage the account DB configuration: 

```bash
>>> ssh-sync $SCRIPTS/var/slurm/accounts.conf :/tmp/
>>> slurm-cc 'sacctmgr load /tmp/accounts.conf'
```
```bash
>>> slurm-cc 'sacctmgr dump vega file=/tmp/accounts.conf'
>>> ssh-sync :/tmp/accounts.conf $SCRIPTS/var/slurm/
```

Start the controller:

```bash
>>> slurm-cc 'systemctl restart slurmctld'
>>> slurm-cc sinfo
```


## Execution Nodes

Create a couple a virtual machines for the execution nodes called **lxb00[1,4].devops.test**

```bash
>>> NODES lxb00[1-4] 
>>> nodeset-loop "virsh-instance -O shadow debian64-9 {}.devops.test"
>>> nodeset-loop "cd $VM_INSTANCE_PATH/{}.devops.test ; ssh-exec -r 'echo {} > /etc/hostname ; hostname {} ; hostname -f' ; cd -"
[…]
```

Deploy the Chef role [execution_node][execution_node.rb] to install _slurmd_

```bash
>>> slurm-en() { for d in $VM_INSTANCE_PATH/lxb* ; do cd $d ; $@ ; cd - >/dev/null ; done }
>>> slurm-en-exec() { slurm-en ssh-exec -r $@ }
```
```bash
>>> slurm-en chef-remote cookbook sys
>>> slurm-en chef-remote role $SCRIPTS/var/chef/roles/debian/slurm/execution_node.rb
>>> slurm-en chef-remote -r "role[execution_node]" solo
[…]
>>> slurm-en-exec 'systemctl reboot'
```


# Tests

Copy the job helper script [slurm-stress][slurm_stress] into the home directory of a user:

```bash
>>> cd $VM_INSTANCE_PATH/lxrm01.devops.test 
>>> ssh-sync -r $SCRIPTS/bin/slurm-* :/network/spock && ssh-exec -r 'chown spock /network/spock/slurm*'
>>> ssh-exec -r 'su spock -c bash'
[…]
```

Execute jobs:

```bash
>>> cd /network/devops
>>> sbatch slurm-stress 60s 1 128M
[…]
>>> sbatch -n 64 --mem-per-cpu=4096 slurm-stress 300s 64 4G
[…]
```

[slurm_basic]: ../../var/slurm/slurm.conf
[slurm_stress]: ../../bin/slurm-stress
[account_database.rb]: ../../var/chef/roles/debian/slurm/account_database.rb
[cluster_controller.rb]: ../../var/chef/roles/debian/slurm/cluster_controller.rb
[execution_node.rb]: ../../var/chef/roles/debian/slurm/execution_node.rb
