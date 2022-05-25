#!/bin/bash
# Установка и настройка прокси Zabbix в пассивном режиме
# tags: centos7,centos8,debian10,ubuntu2004,alma8,rocky8,oracle8
set -x

LOG_PIPE=/tmp/log.pipe.$$

mkfifo ${LOG_PIPE}
LOG_FILE=/root/zabbix_proxy.log
touch ${LOG_FILE}
chmod 600 ${LOG_FILE}

tee < ${LOG_PIPE} ${LOG_FILE} &

exec > ${LOG_PIPE}
exec 2> ${LOG_PIPE}

RootMyCnf() {
    # Saving mysql password
    touch /root/.my.cnf
    chmod 600 /root/.my.cnf
    echo "[client]" > /root/.my.cnf
    echo "password=${1}" >> /root/.my.cnf

}


if [ -f /etc/redhat-release ]; then
    OSNAME=centos
else
    OSNAME=debian
fi

if [ "${OSNAME}" = "debian" ]; then
    export DEBIAN_FRONTEND="noninteractive"
	# Wait firstrun script
	while ps uxaww | grep  -v grep | grep -Eq 'apt-get|dpkg' ; do echo "waiting..." ; sleep 3 ; done
	apt-get update --allow-releaseinfo-change || :
    apt-get update
    which which 2>/dev/null || apt-get -y install which
    which lsb-release 2>/dev/null || apt-get -y install lsb-release
    which wget 2>/dev/null || apt-get -y install wget
    DEB_VERSION=$(lsb_release -r -s)
    if [ "${DEB_VERSION}" = "10" ]; then
        wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb
        dpkg -i zabbix-release_5.4-1+debian10_all.deb
        MYSQL_VERSION="mariadb-server" 
    else
        wget https://repo.zabbix.com/zabbix/5.4/ubuntu-arm64/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
        dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb
        MYSQL_VERSION="mysql-server"
    fi
    apt-get -y install pwgen
    mysqlpass=$(pwgen -s 10 1)
    echo "${MYSQL_VERSION} ${MYSQL_VERSION}/root_password password ${mysqlpass}" | debconf-set-selections
    echo "${MYSQL_VERSION} ${MYSQL_VERSION}/root_password_again password ${mysqlpass}" | debconf-set-selections
    apt-get -y install ${MYSQL_VERSION}
    RootMyCnf ${mysqlpass}
    apt-get -y install apt-transport-https gnupg
    apt-get update
    apt-get -y install zabbix-proxy-mysql
else
    rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
    yum install -y epel-release || yum install -y oracle-epel-release-el8
    yum install -y zabbix-proxy-mysql
    yum install -y mariadb-server
    systemctl enable mariadb
    systemctl start mariadb
    rpm -q pwgen || yum -y install pwgen
    mysqlpass=$(pwgen -s 10 1)
    /usr/bin/mysqladmin -u root password ${mysqlpass}
    RootMyCnf ${mysqlpass}
fi
zabbix_mysqlpass=$(pwgen -s 10 1)
echo 'create database zabbix_proxy character set utf8 collate utf8_bin;' | mysql --defaults-file=/root/.my.cnf -N 
echo 'create user zabbix_proxy@localhost identified by "'${zabbix_mysqlpass}'";' | mysql --defaults-file=/root/.my.cnf -N 
echo 'grant all privileges on zabbix_proxy.* to zabbix_proxy@localhost;' | mysql --defaults-file=/root/.my.cnf -N 
zcat /usr/share/doc/zabbix-proxy-mysql*/schema.sql.gz | mysql -uzabbix_proxy -p${zabbix_mysqlpass} zabbix_proxy
sed -i "/DBUser=zabbix/cDBUser=zabbix_proxy" /etc/zabbix/zabbix_proxy.conf
sed -i "/ProxyMode=0/cProxyMode=1" /etc/zabbix/zabbix_proxy.conf
sed -i "/# DBPassword/cDBPassword=${zabbix_mysqlpass}" /etc/zabbix/zabbix_proxy.conf
if [ ! "($ZABBIX_SERVER)" = "()" ]; then
    sed -i "s/Server=127.0.0.1/Server=($ZABBIX_SERVER)/" /etc/zabbix/zabbix_proxy.conf
fi

systemctl restart zabbix-proxy
systemctl enable zabbix-proxy
if [ ! "($ZABBIX_SERVER)" = "()" ]; then
    which firewall-cmd 2>/dev/null || exit 0
    firewall-cmd --permanent --zone=internal --add-port=10051/tcp
    firewall-cmd --zone=internal --add-source="($ZABBIX_SERVER)/32" --permanent
    firewall-cmd --reload
fi
