#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear

CentOS_Install()
{
yum -y install python-setuptools && easy_install pip
yum -y install git
yum -y groupinstall "Development Tools"
git clone -b stable https://github.com/jedisct1/libsodium
cd /root/libsodium
./configure && make -j2 && make install
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
ldconfig

rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm --quiet
chkconfig shadowsocks-libev off
yum install supervisor python-pip -y
yum install trickle -y
pip install supervisor==3.1
chkconfig supervisord on
wget https://raw.githubusercontent.com/siyisiyi/one-click-ss-server/master/supervisord.conf -O /etc/supervisord.conf
wget https://raw.githubusercontent.com/siyisiyi/one-click-ss-server/master/supervisord -O /etc/init.d/supervisord

cd /root
pip install cymysql
pip install speedtest-cli
git clone -b manyuser https://github.com/glzjin/shadowsocks.git


cat >>/etc/security/limits.conf<< EOF
* soft nofile  512000
* hard nofile 1024000
* soft nproc 512000
* hard nproc 512000
EOF


cat >>/etc/sysctl.conf<<EOF
fs.file-max = 1024000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla
EOF


sed -i "s/exit 0/ulimit -n 512000/g" /etc/rc.local
cat >>/etc/rc.local<<EOF
supervisorctl restart all
exit 0
EOF

echo "ulimit -n 512000" >>/etc/default/supervisor
echo "ulimit -n 512000" >>/etc/profile
source /etc/default/supervisor
source /etc/profile
sysctl -p
ulimit -n 51200

cd /root/shadowsocks
cp apiconfig.py userapiconfig.py
cp config.json user-config.json

host="db.breakthewall.pw"
#read -p "输入MySQL,IP地址或者域名: " host
sed -i "s/MYSQL_HOST = '127.0.0.1'/MYSQL_HOST = '${host}'/g" /root/shadowsocks/userapiconfig.py

username="ss_panel"
#read -p "输入MySQL,用户名: " username
sed -i "s/MYSQL_USER = 'ss'/MYSQL_USER = '${username}'/g" /root/shadowsocks/userapiconfig.py

password="Jintian123"
#read -p "输入MySQL,登录密码: " password
sed -i "s/MYSQL_PASS = 'ss'/MYSQL_PASS = '${password}'/g" /root/shadowsocks/userapiconfig.py

db="ss_panel"
#read -p "输入MySQL,数据库名: " db
sed -i "s/MYSQL_DB = 'shadowsocks'/MYSQL_DB = '${db}'/g" /root/shadowsocks/userapiconfig.py

NODE_ID="1"
read -p "请输入此节点在面板中的ID号: " NODE_ID
sed -i "s/NODE_ID = 1/NODE_ID = ${NODE_ID}/g" /root/shadowsocks/userapiconfig.py

SPEEDTEST="6"
#read -p "输入测速时间,默认为6小时,0为关闭: " SPEEDTEST
sed -i "s/SPEEDTEST = 6/SPEEDTEST = ${SPEEDTEST}/g" /root/shadowsocks/userapiconfig.py

CLOUDSAFE="1"
#read -p "是否开启云安全,自动上报与下载封禁IP,1为开启,0为关闭: " CLOUDSAFE
sed -i "s/CLOUDSAFE = 1/CLOUDSAFE = ${CLOUDSAFE}/g" /root/shadowsocks/userapiconfig.py

ANTISSATTACK="1"
#read -p "是否开启自动封禁SS密码和加密方式错误的 IP,1为开启,0为关闭: " ANTISSATTACK
sed -i "s/ANTISSATTACK = 0/ANTISSATTACK = ${ANTISSATTACK}/g" /root/shadowsocks/userapiconfig.py

AUTOEXEC="1"
#read -p "是否接受上级下发的命令,1为开启,0为关闭: " AUTOEXEC
sed -i "s/AUTOEXEC = 1/AUTOEXEC = ${AUTOEXEC}/g" /root/shadowsocks/userapiconfig.py

MULTI_THREAD="0"
#read -p "是否开启多线程,1为开启,0为关闭: " MULTI_THREAD
sed -i "s/MULTI_THREAD = 0/MULTI_THREAD = ${MULTI_THREAD}/g" /root/shadowsocks/userapiconfig.py

INFO="1"
#read -p "是否开启详细日志,1为开启,0为关闭: " INFO
sed -i ‘s/\"connect_verbose_info\": 0/\"connect_verbose_info\": ${INFO}/g’ /root/shadowsocks/userapiconfig.py

echo "#############################################################"
echo "Shadowsocks配置完成:"
cat ./userapiconfig.py
echo "#############################################################"

sudo service supervisord start

echo
echo "#############################################################"
echo "# One click Install Shadowsocks-Python Manyusers Version    #"
echo "# Author: C Wang <wang@siyi.me> 		                      #"
echo "# Thanks: @zd423 <http://zdfans.com> @glzhaojin <zhaoj.in>  #"
echo "#############################################################"
echo
echo "恭喜您!Shadowsocks Python多用户版安装并与前段SS-Panel对接完成!"
echo "此脚本仅支持v3魔改版! 其他版本勿用!"
}

CentOS_Install
