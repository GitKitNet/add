#!/bin/bash
# Zabbix agent linux
# tags: centos7,centos8,debian10,ubuntu2004,alma8,rocky8,oracle8
set -x

LOG_PIPE=/tmp/log.pipe.$$

mkfifo ${LOG_PIPE}
LOG_FILE=/root/zabbix_agent.log
touch ${LOG_FILE}
chmod 600 ${LOG_FILE}

tee < ${LOG_PIPE} ${LOG_FILE} &

exec > ${LOG_PIPE}
exec 2> ${LOG_PIPE}

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
    else
        wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
        dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb
    fi
    apt-get -y install apt-transport-https gnupg
    apt-get update
    apt-get -y install zabbix-agent
else
    rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
    yum install -y zabbix-agent
fi
systemctl enable zabbix-agent 
if [ ! "($ZABBIX_SERVER)" = "()" ]; then
    sed -i 's/Server=127.0.0.1/Server=127.0.0.1,($ZABBIX_SERVER)/' /etc/zabbix/zabbix_agentd.conf
    sed -i 's/ServerActive=127.0.0.1/ServerActive=127.0.0.1,($ZABBIX_SERVER)/' /etc/zabbix/zabbix_agentd.conf
    systemctl restart zabbix-agent
    which firewall-cmd 2>/dev/null || exit 0
    firewall-cmd --permanent --zone=internal --add-port=10050/tcp
    firewall-cmd --zone=internal --add-source="($ZABBIX_SERVER)/32" --permanent
    firewall-cmd --reload
fi

