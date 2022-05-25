#!/bin/sh
#Teamspeak 3 сервер. Логин, пароль и токен можно найти в файле /root/ts3_login_data
# metadata_begin
# recipe: Teamspeak
# tags: centos,debian,ubuntu1604,ubuntu1804
# revision: 13
# description_ru: Teamspeak 3 сервер. Логин, пароль и токен можно найти в файле /root/ts3_login_data
# description_en: Teamspeak 3 server. Login, password and token placed in file /root/ts3_login_data
# metadata_end
#
RNAME=Teamspeak

set -x

LOG_PIPE=/tmp/log.pipe.$$                                                                                                                                                                                                                    
mkfifo ${LOG_PIPE}
LOG_FILE=/root/${RNAME}.log
touch ${LOG_FILE}
chmod 600 ${LOG_FILE}

tee < ${LOG_PIPE} ${LOG_FILE} &

exec > ${LOG_PIPE}
exec 2> ${LOG_PIPE}

killjobs() {
	jops="$(jobs -p)"
	test -n "${jops}" && kill ${jops} || :
}
trap killjobs INT TERM EXIT

echo
echo "=== Recipe ${RNAME} started at $(date) ==="
echo

if [ -f /etc/redhat-release ]; then
	OSNAME=centos
else
	OSNAME=debian
fi

Service() {
	# $1 - name
	# $2 - command

	if [ -n "$(which systemctl 2>/dev/null)" ]; then
		systemctl ${2} ${1}.service
	else
		if [ "${2}" = "enable" ]; then
			if [ "${OSNAME}" = "debian" ]; then
				update-rc.d ${1} enable
			else
				chkconfig ${1} on
			fi
		else
			service ${1} ${2}
		fi
	fi
}

RootMyCnf() {
    # Saving mysql password
    touch /root/.my.cnf 
    chmod 600 /root/.my.cnf
    echo "[client]" > /root/.my.cnf
    echo "password=${1}" >> /root/.my.cnf

}

NginxRepo() {
	# nginx repo
cat > /etc/yum.repos.d/nginx.repo << EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF
}

if [ "${OSNAME}" = "debian" ]; then
	export DEBIAN_FRONTEND="noninteractive"

	# Wait firstrun script
	while ps uxaww | grep  -v grep | grep -Eq 'apt-get|dpkg' ; do echo "waiting..." ; sleep 3 ; done
	apt-get update --allow-releaseinfo-change || :
	apt-get update
	test -f /usr/bin/which || apt-get -y install which
	which lsb_release 2>/dev/null || apt-get -y install lsb-release
	which logger 2>/dev/null || apt-get -y install bsdutils
	OSREL=$(lsb_release -s -c)
	
	pkglist="openssl sqlite3 wget apache2 bzip2 cron ca-certificates"
	release="$(lsb_release -s -c)"
	case ${release} in
		xenial|stretch|bionic|buster|bullseye)
			pkglist="${pkglist} libapache2-mod-php"
			;;
		*)
			pkglist="${pkglist} libapache2-mod-php5"
			;;
	esac
	
    # Installing packages
    apt-get -y install ${pkglist}
else
	OSREL=$(rpm -qf --qf '%{version}' /etc/redhat-release)
	
	yum -y install epel-release || yum -y install oracle-epel-release-el8

	# Setting proxy
	if [ ! "($HTTPPROXYv4)" = "()" ]; then
		# Стрипаем пробелы, если они есть
		PR="($HTTPPROXYv4)"
		PR=$(echo ${PR} | sed "s/''//g" | sed 's/""//g')
		if [ -n "${PR}" ]; then
			echo "proxy=${PR}" >> /etc/yum.conf
		fi
	fi
	
	pkglist="openssl sqlite wget httpd php bzip2 which anacron tar"
	
    	yum -y install ${pkglist} || yum -y install ${pkglist} || yum -y install ${pkglist}

	# Removing proxy
	sed -r -i "/proxy=/d" /etc/yum.conf
fi

arch=$(uname -m)
test "x${arch}" = "xx86_64" && arch=amd64


useradd teamspeak
mkdir -p /home/teamspeak
chown teamspeak:teamspeak /home/teamspeak
mkdir /home/teamspeak/ts3
chown teamspeak:teamspeak /home/teamspeak/ts3
cd /home/teamspeak
TSVER=3.12.1
wget --no-check-certificate https://files.teamspeak-services.com/releases/server/${TSVER}/teamspeak3-server_linux_${arch}-${TSVER}.tar.bz2

tar --strip-components=1 -xpf teamspeak3-server_linux_${arch}-${TSVER}.tar.bz2 -C /home/teamspeak/ts3
chown -R teamspeak:teamspeak /home/teamspeak/ts3
cd ts3
touch .ts3server_license_accepted
su teamspeak -c "./ts3server_startscript.sh start" > /root/credits.txt 2>&1
sleep 5
login=serveradmin
password=$(cat /root/credits.txt | sed -r -n 's/.+password=\s*"(.+)"/\1/p')
token=$(cat /root/credits.txt | sed -r -n 's/.+token=\s*"*?(.+)"*?/\1/p')
#rm -f /root/credits.txt
touch 600 /root/credits.txt

_tmppass="($PASS)"
if [ -n "${_tmppass}" ] && [ "${_tmppass}" != "()" ]; then
    newpass=$(echo -n ${_tmppass} | openssl dgst -binary -sha1 | awk '{printf $NF}' | base64)
    su teamspeak -c "./ts3server_startscript.sh stop"
    echo "UPDATE clients set client_login_password='${newpass}' where client_id=1;" | sqlite3 ts3server.sqlitedb
    su teamspeak -c "./ts3server_startscript.sh start"
	password="${_tmppass}"
fi

cat > /root/ts3_login_data << EOF
login=${login}
password=${password}
token=${token}
EOF
touch 600 /root/ts3_login_data

crontab -u teamspeak -l > /tmp/ts.crontab
echo "@reboot      cd /home/teamspeak/ts3 ; ./ts3server_startscript.sh start" >> /tmp/ts.crontab
crontab -u teamspeak /tmp/ts.crontab
rm -f /tmp/ts.crontab


if [ -d /var/www/html ]; then
    cd /var/www/html
else
    cd /var/www
fi
wget --no-check-certificate http://download.ispsystem.com/external/ts3cp.tar.gz -O ts3cp.tar.gz
tar --strip-components=1 -xpf ts3cp.tar.gz
rm -f ts3cp.tar.gz

mkdir -p templates_c icons
if [ "x${OSNAME}" = "xdebian" ]; then
    chown -R www-data templates_c icons
else
    chown -R apache templates_c icons
fi

echo >> motd.txt
echo "You can find login data in file /root/ts3_login_data" > motd.txt

mv config.php config.orig.php
cat > config.php << EOF
<?php
/*
*Copyright (C) 2012-2013  Psychokiller
*
*This program is free software; you can redistribute it and/or modify it under the terms of 
*the GNU General Public License as published by the Free Software Foundation; either 
*version 3 of the License, or any later version.
*
*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
*without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
*See the GNU General Public License for more details.
*
*You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>. 
*/
if(!defined("SECURECHECK")) {die(\$lang['error_file_alone']);} 
/*
REGARD!!
If you use the web interface, they must write the webserver ip in the query_ip_whitelist.txt.
After adding the ip, the server must be restarted!

Add more Server Ip's.
For Example
\$server[0]['alias']= "Lokaler Server1";
\$server[0]['ip']= "127.0.0.1";
\$server[0]['tport']= "10011";

\$server[1]['alias']= "Lokaler Server2";
\$server[1]['ip']= "127.0.0.2";
\$server[1]['tport']= "20022";
*/

\$server[0]['alias']= "Server #1";
\$server[0]['ip']= "127.0.0.1";
\$server[0]['tport']= 10011;
\$cfglang        =       "en";                   //Language German = de, English = en, Netherlandish=nl (by pd1evl), French = fr (by supra63200)
\$duration = "100";                              //Set the Limit for Clients show per Page on Client List
\$fastswitch=true;                               //If true you can switch the Server on the header
\$showicons="left";                              //Define the position where the icons on the Viewer will show left or right
\$style="bootstrap";                                     //Chose your design  set 'new' for the default design or the name of your own create design
\$msgsend_name="Control_panel";  //This Name will be show if you send a message to a Server
\$show_motd=true;                                // Set it to false to not show the message of the day window
\$show_version=true;                             // Set it to false to not show the Webinterface Version on the footer
?>
EOF

rm -f index.html
if [ "x${OSNAME}" = "xdebian" ]; then
   Service apache2 enable
   Service apache2 restart
else
   Service httpd enable
   Service httpd restart
   if service firewalld status >/dev/null ; then
	   # http port
	   firewall-cmd --add-service=http --zone=public --permanent
	   # TS3 ports
	   firewall-cmd --add-port=30033/tcp --zone=public --permanent
	   firewall-cmd --add-port=10011/tcp --zone=public --permanent
	   firewall-cmd --add-port=9987/udp --zone=public --permanent
	   firewall-cmd --reload
   elif [ -f /sbin/iptables ]; then
	   # TS3 ports
	   iptables -A INPUT -p udp --dport 9987 -j ACCEPT
	   iptables -A INPUT -p tcp --dport 30033 -j ACCEPT
	   iptables -A INPUT -p tcp --dport 10011 -j ACCEPT
	   # httpd port
	   iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	   service iptables save || :
   fi
fi
