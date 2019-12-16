#!/bin/bash
#Name:MySQL_base.sh
#Date:2018-08-15
#Author:David
#Version:1.0
#Function:Used to setup the basic settings of the MySQL server

marks()
{
echo "==================================================================================="
}



#Setup DNS
echo '##########Setting up DNS#########'
echo 'nameserver 8.8.8.8
nameserver 114.114.114.114
nameserver 8.8.4.4' >> /etc/resolv.conf
chattr +i /etc/resolv.conf
marks

#Test the network
echo '############Testing the network#########'
ping -c5 www.google.com && echo "ok" || exit 0
marks

#Setup selinux
echo '##########Setting up selinux#############'
setenforce 0
ulimit -SHn 65535
echo "ulimit -SHn 65535" >> /etc/rc.local
cat >>/etc/security/limits.conf<<EOF
* soft nproc 102400
* hard nproc 102400
* soft nofile 102400
* hard nofile 102400
EOF
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
marks

#Setup /etc/sysctl.com
echo '#########Setting up /etc/sysctl.conf#########'
echo 'net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
fs.file-max=102400
net.ipv4.tcp_max_tw_buckets = 10000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 873200 1746400 3492800
net.ipv4.tcp_rmem = 873200 1746400 3492800
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.wmem_max = 3492800
net.core.rmem_max = 3492800
net.core.netdev_max_backlog = 262144
#net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 131072
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_orphan_retries = 0
net.ipv4.tcp_max_orphans = 65536
#net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10240 65000
net.ipv4.tcp_abort_on_overflow = 1
net.netfilter.nf_conntrack_max = 1048576
net.nf_conntrack_max = 1048576
net.netfilter.nf_conntrack_tcp_timeout_established = 360
vm.swappiness=1
vm.min_free_kbytes=204800
vm.vfs_cache_pressure=150
vm.dirty_background_ratio=5
vm.dirty_ratio=10
' > /etc/sysctl.conf
#modprobe bridge
sysctl -p
marks

#Install the nessesary softwares
echo '##########Installing the nessesary softwares###########'
yum -y install epel-release
yum clean all && yum makecache
yum -y install ntpdate  lsof openssh-clients mlocate  make gcc  rsync
#网络方面的包
yum -y install net-tools traceroute iftop strace htop telnet

#编辑压缩类的包
yum -y install vim wget unzip bzip2 git gzip

#cpu,io
yum -y install sysstat tcpdump

#pt工具
wget https://www.percona.com/downloads/percona-toolkit/3.0.13/binary/redhat/7/x86_64/percona-toolkit-3.0.13-1.el7.x86_64.rpm
yum localinstall percona-toolkit-3.0.13-1.el7.x86_64.rpm -y
marks

#Setup the time
timedatectl set-timezone "Asia/Shanghai"
hwclock -w
marks

#Install iptables
systemctl stop firewalld
systemctl disable firewalld
#yum -y install iptables iptables-services
#service iptables restart

#Install jemalloc(安装jemalloc内存管理器)
#已方便安装好mysql后使用，使用也很简单在[mysqld_safe] 加上malloc-lib= /usr/local/lib/libjemalloc.so
wget https://github.com/jemalloc/jemalloc/releases/download/5.1.0/jemalloc-5.1.0.tar.bz2
yum install bzip2 -y
bzip2 -d jemalloc-5.1.0.tar.bz2
tar xvf jemalloc-5.1.0.tar
cd jemalloc-5.1.0
./configure
make && make install

#安装异步IO支持
yum install libaio-devel -y

#Install MySQL
rpm -qa|grep mysql
yum remove mysql *

wget 'https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm'
rpm -Uvh mysql57-community-release-el7-11.noarch.rpm

yum -y install mysql-community-server

echo '
[mysqld]
skip-name-resolve
datadir=/home/mysqldata
user=mysql
binlog_format=ROW
default_storage_engine=InnoDB
innodb_locks_unsafe_for_binlog=1
innodb_autoinc_lock_mode=2
# 根据实际服务器内存情况调整
innodb_buffer_pool_size = 1G
port = 3306
socket = /home/mysqldata/mysql.sock
log-bin=mysql-bin
expire_logs_days = 5
sort_buffer_size = 1M
join_buffer_size = 1M
query_cache_size=0
query_cache_type=0
innodb_data_file_path=ibdata1:1G:autoextend
innodb_log_buffer_size=32M
innodb_log_file_size=512M
innodb_flush_log_at_trx_commit=2
innodb_max_dirty_pages_pct=5
innodb_io_capacity = 10000
sync_binlog=0
# 根据实际情况调整(查看错误日志)
open_files_limit=5000    #1G对应65536
# 根据实际情况调整(查看错误日志)
max_connections = 400
thread_stack = 192K
tmp_table_size = 246M
max_heap_table_size = 246M
key_buffer_size = 300M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
max_allowed_packet=64M
slow_query_log = 1
long_query_time = 2
slow_query_log_file = /home/mysql/slowquery.log
log-error = /home/mysql/error.log
# 根据实际情况调整(有主从则开启 无主从则关闭)
log-slave-updates=off
gtid-mode=off
enforce-gtid-consistency=off
slave-parallel-type=LOGICAL_CLOCK
master-info-repository=TABLE
relay-log-info-repository=TABLE
relay_log_recovery=ON
sync-master-info=1
slave-parallel-workers=16
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog-rows-query-log_events=1
port=3306
#report-host=10.2.9.14
#report-port=143306
server_id = 14
log-slave-updates
slave-skip-errors=all
auto_increment_increment=2
auto_increment_offset=2
read_only = 0
sql_mode="NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
#rpl_semi_sync_master_enabled = 1
#rpl_semi_sync_master_timeout = 1000 # 1 second
#rpl_semi_sync_slave_enabled = 1
innodb_numa_interleave=1

[mysql]
prompt="\u@mysqldb \R:\m:\s [\d]> "
no-auto-rehash
socket = /home/mysqldata/mysql.sock
'> /etc/my.cnf

#Create a directory structure
mkdir -p /home/mysql /home/mysqldata/
touch /home/mysql/error.log  /home/mysql/slowquery.log
chown -R mysql:mysql /home/mysql /home/mysqldata
systemctl start mysqld

echo -e "\033[31;36m#Now, you have finished the basic settings for msyql  #\033[0m"
echo -e "\033[31;36m#You can execute the command to get your initial password:\n grep 'temporary password' mysql/error.log | awk '{print \$NF}'"