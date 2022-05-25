#!/bin/sh
#
# Рецепт установки 1С-Битрикс: Веб-окружение
# metadata_begin
# recipe: Bitrix Env
# tags: centos7
# revision: 12
# description_ru: Рецепт установки 1С-Битрикс: Веб-окружение
# description_en: 1С-Bitrix: Web-Environment recipe
# metadata_end
#
RNAME="Bitrixenv"

set -x

LOG_PIPE=/tmp/log.pipe.$$                                                                                                                                                                                                                    
mkfifo ${LOG_PIPE}
LOG_FILE=/root/bitrixenv.log
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

HOME=/root
export HOME

if [ -f /etc/redhat-release ]; then
	OSNAME=centos
else
	OSNAME=debian
fi

set -x

yum -y install wget expect
yum -y remove net-snmp net-snmp-agent-libs

yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
#sed -i -e 's/gpgcheck = 1/gpgcheck = 0/' /etc/yum.repos.d/percona-release.repo
rpm -e --nodeps mariadb-libs || :

if [ -f /proc/user_beancounters ]; then
	yum -y remove percona-release || :
	yum -y remove Percona-Server-shared-56 || :
fi

# Bitrix environment isntall
wget -P /tmp "http://repos.1c-bitrix.ru/yum/bitrix-env.sh"
chmod +x /tmp/bitrix-env.sh

echo "5" | /tmp/bitrix-env.sh
rm -rf /tmp/bitrix-env*

password=$(mkpasswd -s 0)
mysqladmin password ${password}
echo -e "# mysql bvat config file\n[client]\nuser=root\npassword = ${password}\nsocket=/var/lib/mysqld/mysqld.sock" > /root/.my.cnf
#sed -i -r "s|(\\\$DBPassword = ).*$|\1\"${password}\";|" /home/bitrix/www/bitrix/php_interface/dbconn.php
#sed -i -r "s/('password' => ).*/\1'${password}',/" /home/bitrix/www/bitrix/.settings.php

sed -i -r '/^\s*LogFormat.+%h.*/s/(^\s*LogFormat.+)%h(.*)/\1%a\2/g' /etc/httpd/conf/httpd.conf || :
service httpd restart

# Bitrix environment end
