#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear
echo
echo "#############################################################"
echo "# One click Install Shadowsocks + ServerSpeeder 		  #"
echo "# Author: C Wang <wang@siyi.me> 		                  #"
echo "# Thanks: @zd423 <http://zdfans.com> @glzhaojin <zhaoj.in>  #"
echo "#############################################################"
echo

#定义变量
#授权文件自动生成url
APX=http://soft.91yun.org/soft/serverspeeder/apx1.php
#安装包下载地址
INSTALLPACK=http://soft.91yun.org/soft/serverspeeder/91yunserverspeeder.tar.gz
#判断版本支持情况的地址
CHECKSYSTEM=http://soft.91yun.org/soft/serverspeeder/checksystem.php
#bin下载地址
BIN=downloadurl



#取操作系统的名称
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
	else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        ver3='x64'
    else
        ver3='x32'
    fi
}

Get_Dist_Name

#安装相应的软件
if [ "$DISTRO" == "CentOS" ];then
	yum install -y redhat-lsb curl net-tools
elif [ "$DISTRO" == "Debian" ];then
	apt-get update
	apt-get install -y lsb-release curl
elif [ "$DISTRO" == "Ubuntu" ];then
	apt-get update
	apt-get install -y lsb-release curl
else
	echo "一键脚本暂时只支持centos，ubuntu和debian的安装，其他系统请选择手动安装http://www.91yun.org/serverspeeder91yun"
	exit 1
fi

release=$DISTRO
#发行版本
if [ "$release" == "Debian" ]; then
	ver1str="lsb_release -rs | awk -F '.' '{ print \$1 }'"
else
	ver1str="lsb_release -rs | awk -F '.' '{ print \$1\".\"\$2 }'"
fi
ver1=$(eval $ver1str)
#ver11=`echo $ver1 | awk -F '.' '{ print $1 }'`

#内核版本
ver2=`uname -r`
#锐速版本
ver4=3.10.61.0

echo "================================================="
echo "操作系统：$release "
echo "发行版本：$ver1 "
echo "内核版本：$ver2 "
echo "位数：$ver3 "
echo "锐速版本：$ver4 "
echo "================================================="


#下载支持的bin列表
curl "http://soft.91yun.org/soft/serverspeeder/serverspeederbin.txt" -o serverspeederbin.txt || { echo "文件下载失败，自动退出，可以前往http://www.91yun.org/serverspeeder91yun手动下载安装包";exit 1; }




#判断内核版本
grep -q "$release/$ver11[^/]*/$ver2/$ver3" serverspeederbin.txt
if [ $? == 1 ]; then
		#echo "没有找到内核"
	if [ "$release" == "CentOS" ]; then
		ver21=`echo $ver2 | awk -F '-' '{ print $1 }'`
		ver22=`echo $ver2 | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $1 }'`
		#cat serverspeederbin.txt | grep -q  "$release/$ver1/$ver21-$ver22[^/]*/$ver3/"
		cat serverspeederbin.txt | grep -q  "$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/"

		if [ $? == 1 ]; then
			echo -e "\r\n"
			echo "锐速暂不支持该内核，程序退出.自动安装判断比较严格，你可以到http://www.91yun.org/serverspeeder91yun手动下载安装文件尝试不同版本"
			exit 1
		fi
		echo "没有完全匹配的内核，请选一个最接近的尝试，不确保一定成功,(如果有版本号重复的选项随便选一个就可以)"
		echo -e "您当前的内核为 \033[41;37m $ver2 \033[0m"
		cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/"  | awk -F '/' '{ print NR"："$3 }'
	fi


	if [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
		ver21=`echo $ver2 | awk -F '-' '{ print $1 }'`
		ver22=`echo $ver2 | awk -F '-' '{ print $2 }'`
		cat serverspeederbin.txt | grep -q  "$release/$ver11[^/]*/$ver21(-)?$ver22[^/]*/$ver3/"

		if [ $? == 1 ]; then
			echo -e "\r\n"
			echo "锐速暂不支持该内核，程序退出.自动安装判断比较严格，你可以到http://www.91yun.org/serverspeeder91yun手动下载安装文件尝试不同版本"
			exit 1
		fi
		echo "没有完全匹配的内核，请选一个最接近的尝试，不确保一定成功,(如果有版本号重复的选项随便选一个就可以)"
		echo -e "您当前的内核为 \033[41;37m $ver2 \033[0m"
		cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver21(-)?$ver22[^/]*/$ver3/"  | awk -F '/' '{ print NR"："$3 }'
	fi


	echo "请选择（输入数字序号）："
	read cver2
	if [ "$cver2" == "" ]; then
		echo "未选择任何内核版本，脚本退出"
		exit 1
	fi

	if [ "$release" == "CentOS" ]; then
		cver2str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }' | awk 'NR==1{print \$1}'"
	fi
	if [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
		cver2str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver21-[^/]*/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }' awk 'NR==1{print \$1}'"
	fi
	ver2=$(eval $cver2str)
	if [ "$ver2" == "" ]; then
        echo "脚本获得不了内核版本号，错误退出"
		exit 1
    fi
	#根据所选的内核版本，再回头确定大版本

fi
#判断锐速版本
grep -q "$release/$ver1/$ver2/$ver3/$ver4" serverspeederbin.txt
if [ $? == 1 ]; then
	grep -q "$release/$ver11[^/]*/$ver2/$ver3/$ver4" serverspeederbin.txt
	if [ $? == 1 ]; then
		echo -e "\r\n"
		echo -e "我们用的锐速安装文件是\033[41;37m 3.10.60.0  \033[0m，但这个内核没有匹配的，请选择一个接近的锐速版本号尝试，不确保一定可用,(如果有版本号重复的选项随便选一个就可以)"
		cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver2/$ver3/"  | awk -F '/' '{ print NR"："$5 }'
		echo "请选择锐速版本号（输入数字序号）："
			read cver4
		if [ "$cver4" == "" ]; then
			echo "未选择任何锐速版本，脚本退出"
			exit 1
		fi
			cver4str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver2/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$5 }' | awk -F '：' '/"$cver4："/{ print \$2 }' | awk 'NR==1{print \$1}'"
			ver4=$(eval $cver4str)
		if [ "$ver4" == "" ]; then
			echo "没取到锐速版本，程序出错退出。"
			exit 1
		fi
	fi
	#根据锐速版本，内核版本，再回头确定使用的大版本。
	cver1str="cat serverspeederbin.txt | grep '$release/$ver11[^/]*/$ver2/$ver3/$ver4' | awk -F '/' 'NR==1{ print \$2 }'"
	ver1=$(eval $cver1str)
fi



BINFILESTR="cat serverspeederbin.txt | grep '$release/$ver1/$ver2/$ver3/$ver4/0' | awk -F '/' '{ print \$7 }'"
BINFILE=$(eval $BINFILESTR)
BIN="http://soft.91yun.org/soft/serverspeeder/bin/$release/$ver1/$ver2/$ver3/$ver4/$BINFILE"
echo $BIN
rm -rf serverspeederbin.txt





#先取外网ip，根据取得ip获得网卡，然后通过网卡获得mac地址。
# if [ "$1" == "" ]; then
	# IP=$(curl ipip.net | awk -F ' ' '{print $2}' | awk -F '：' '{print $2}')
	# NC="ifconfig | awk -F ' |:' '/$IP/{print a}{a=\$1}'"
	# NETCARD=$(eval $NC)
# else
	# NETCARD=eth0
# fi
# MACSTR="LANG=C ifconfig $NETCARD | awk '/HWaddr/{ print \$5 }' "
# MAC=$(eval $MACSTR)
# if [ "$MAC" = "" ]; then
# MACSTR="LANG=C ifconfig $NETCARD | awk '/ether/{ print \$2 }' "
# MAC=$(eval $MACSTR)
# fi
# echo IP=$IP
# echo NETCARD=$NETCARD

if [ "$1" == "" ]; then
	MACSTR="LANG=C ifconfig eth0 | awk '/HWaddr/{ print \$5 }' "
	MAC=$(eval $MACSTR)
	if [ "$MAC" == "" ]; then
		MACSTR="LANG=C ifconfig eth0 | awk '/ether/{ print \$2 }' "
		MAC=$(eval $MACSTR)
	fi
	if [ "$MAC" == "" ]; then
		#MAC=$(ip link | awk -F ether '{print $2}' | awk NF | awk 'NR==1{print $1}')
		echo "本破解只支持eth0名的网卡，如果你的网卡不是eth0,请修改网卡名"
		exit 1
	fi
else
	MAC=$1
fi
echo MAC=$MAC

#如果自动取不到就要求手动输入
if [ "$MAC" = "" ]; then
echo "无法自动取得mac地址，请手动输入："
read MAC
echo "手动输入的mac地址是$MAC"
fi


#下载安装包
echo "======================================"
echo "开始下载安装包。。。。"
echo "======================================"
wget -N -O 91yunserverspeeder.tar.gz  $INSTALLPACK
tar xfvz 91yunserverspeeder.tar.gz || { echo "下载安装包失败，请检查";exit 1; }

#下载授权文件
echo "======================================"
echo "开始下载授权文件。。。。"
echo "======================================"
curl "$APX?mac=$MAC" -o 91yunserverspeeder/apxfiles/etc/apx-20341231.lic || { echo "下载授权文件失败，请检查$APX?mac=$MAC";exit 1;}


#取得序列号
echo "======================================"
echo "开始修改配置文件。。。。"
echo "======================================"
SNO=$(curl "$APX?mac=$MAC&sno") || { echo "生成序列号失败，请检查";exit 1; }
echo "序列号：$SNO"
sed -i "s/serial=\"sno\"/serial=\"$SNO\"/g" 91yunserverspeeder/apxfiles/etc/config
rv=$release"_"$ver1"_"$ver2
sed -i "s/Debian_7_3.2.0-4-amd64/$rv/g" 91yunserverspeeder/apxfiles/etc/config
# sed -i "s/accppp=\"1\"/accppp=\"0\"/g" 91yunserverspeeder/apxfiles/etc/config

#下载bin文件
echo "======================================"
echo "开始下载bin运行文件。。。。"
echo "======================================"
curl $BIN -o "91yunserverspeeder/apxfiles/bin/acce-3.10.61.0-["$release"_"$ver1"_"$ver2"]" || { echo "下载bin运行文件失败，请检查";exit 1; }

#切换目录执安装文件
cd 91yunserverspeeder

# Restore license permission to read and write if it exist for re-install.
if [ -f /serverspeeder/etc/apx-20341231.lic ]; then
    chattr -i /serverspeeder/etc/apx-20341231.lic
fi

bash install.sh

#禁止修改授权文件
chattr +i /serverspeeder/etc/apx*
#CentOS7添加开机启动
# if [ "$release" == "CentOS" ] && [ "$ver11" == "7" ]; then
	# chmod +x /etc/rc.d/rc.local
	# echo "/serverspeeder/bin/serverSpeeder.sh start" >> /etc/rc.local
# fi
#安装完显示状态
bash /serverspeeder/bin/serverSpeeder.sh status
echo "=================================="
echo "锐速安装完成，开始安装Shadowsocks"
echo "=================================="
# CentOS_Install()
# {
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
wget https://github.com/glzjin/ssshell-jar/raw/master/supervisord -O /etc/init.d/supervisord

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
sed -i "s/NODE_ID = 1/NODE_ID = '${NODE_ID}'/g" /root/shadowsocks/userapiconfig.py

SPEEDTEST="6"
#read -p "输入测速时间,默认为6小时,0为关闭: " SPEEDTEST
sed -i "s/SPEEDTEST = 6/SPEEDTEST = '${SPEEDTEST}'/g" /root/shadowsocks/userapiconfig.py

CLOUDSAFE="1"
read -p "是否开启云安全,自动上报与下载封禁IP,1为开启,0为关闭: " CLOUDSAFE
sed -i "s/CLOUDSAFE = 1/CLOUDSAFE = '${CLOUDSAFE}'/g" /root/shadowsocks/userapiconfig.py

ANTISSATTACK="1"
#read -p "是否开启自动封禁SS密码和加密方式错误的 IP,1为开启,0为关闭: " ANTISSATTACK
sed -i "s/ANTISSATTACK = 0/ANTISSATTACK = '${ANTISSATTACK}'/g" /root/shadowsocks/userapiconfig.py

AUTOEXEC="1"
#read -p "是否接受上级下发的命令,1为开启,0为关闭: " AUTOEXEC
sed -i "s/AUTOEXEC = 1/AUTOEXEC = '${AUTOEXEC}'/g" /root/shadowsocks/userapiconfig.py

MULTI_THREAD ="0"
#read -p "是否开启多线程,1为开启,0为关闭: " MULTI_THREAD
sed -i "s/MULTI_THREAD = 0/MULTI_THREAD = '${MULTI_THREAD}'/g" /root/shadowsocks/userapiconfig.py

echo "#############################################################"
echo "Shadowsocks配置完成:"
cat ./userapiconfig.py
echo "#############################################################"

/etc/init.d/supervisord reload
/etc/init.d/supervisord restart
ulimit -n 51200

echo
echo "#############################################################"
echo "# One click Install Shadowsocks-Python Manyusers Version    #"
echo "# Author: C Wang <wang@siyi.me> 		                      #"
echo "# Thanks: @zd423 <http://zdfans.com> @glzhaojin <zhaoj.in>  #"
echo "#############################################################"
echo
echo "恭喜您!Shadowsocks Python多用户版安装并与前段SS-Panel对接完成!"
echo "此脚本仅支持v3魔改版! 其他版本勿用!"
# }
