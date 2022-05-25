#!/bin/bash
# Установка Zabbix - сервера
# login: Admin
# pass: zabbix
# tags: centos7,centos8,debian10,ubuntu2004,alma8,rocky8,oracle8
set -x

LOG_PIPE=/tmp/log.pipe.$$

mkfifo ${LOG_PIPE}
LOG_FILE=/root/zabbix.log
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
        wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
        dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb
        MYSQL_VERSION="mysql-server"
    fi
    apt-get -y install pwgen
    mysqlpass=$(pwgen -s 10 1)
    echo "${MYSQL_VERSION} ${MYSQL_VERSION}/root_password password ${mysqlpass}" | debconf-set-selections
    echo "${MYSQL_VERSION} ${MYSQL_VERSION}/root_password_again password ${mysqlpass}" | debconf-set-selections
    apt-get -y install ${MYSQL_VERSION}
    RootMyCnf ${mysqlpass}
    apt-get -y install apt-transport-https gnupg ca-certificates
    apt-get update
    apt-get -y install  zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
else
    rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
    yum install -y epel-release || yum install -y oracle-epel-release-el8
    yum install -y zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
    yum install -y mariadb-server 
    systemctl enable mariadb
    systemctl start mariadb
    rpm -q pwgen || yum -y install pwgen
    mysqlpass=$(pwgen -s 10 1)
    /usr/bin/mysqladmin -u root password ${mysqlpass}
    RootMyCnf ${mysqlpass}
fi
zabbix_mysqlpass=$(pwgen -s 10 1)
echo 'create database zabbix character set utf8 collate utf8_bin;' | mysql --defaults-file=/root/.my.cnf -N 
echo 'create user zabbix@localhost identified by "'${zabbix_mysqlpass}'";' | mysql --defaults-file=/root/.my.cnf -N 
echo 'grant all privileges on zabbix.* to zabbix@localhost;' | mysql --defaults-file=/root/.my.cnf -N 
zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -uzabbix -p${zabbix_mysqlpass} zabbix
sed -i "/DBPassword=/cDBPassword=${zabbix_mysqlpass}" /etc/zabbix/zabbix_server.conf
sed -i "/ProxyConfigFrequency=/cProxyConfigFrequency=60" /etc/zabbix/zabbix_server.conf
sed -i '/listen/s/#//' /etc/nginx/conf.d/zabbix.conf
sed -i '/    server {/,$c}' /etc/nginx/nginx.conf
if [ -e '/etc/nginx/sites-enabled/default' ]; then
    rm -f '/etc/nginx/sites-enabled/default'
fi
echo 'php_value[date.timezone] = UTC' >> /etc/php-fpm.d/zabbix.conf
cat << EOF >  /etc/zabbix/web/zabbix.conf.php
<?php
\$DB['TYPE']                             = 'MYSQL';
\$DB['SERVER']                   = 'localhost';
\$DB['PORT']                             = '0';
\$DB['DATABASE']                 = 'zabbix';
\$DB['USER']                             = 'zabbix';
\$DB['PASSWORD']                 = '${zabbix_mysqlpass}';
\$DB['SCHEMA']                   = '';
\$DB['ENCRYPTION']               = false;
\$DB['KEY_FILE']                 = '';
\$DB['CERT_FILE']                = '';
\$DB['CA_FILE']                  = '';
\$DB['VERIFY_HOST']              = false;
\$DB['CIPHER_LIST']              = '';
\$DB['DOUBLE_IEEE754']   = true;
\$ZBX_SERVER                             = 'localhost';
\$ZBX_SERVER_PORT                = '10051';
\$ZBX_SERVER_NAME                = 'ah';
\$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;
EOF
systemctl restart zabbix-server zabbix-agent nginx php-fpm
systemctl enable zabbix-server zabbix-agent nginx php-fpm

which firewall-cmd 2>/dev/null || exit 0
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --reload
