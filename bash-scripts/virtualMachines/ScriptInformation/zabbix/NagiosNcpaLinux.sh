#!/bin/bash
# tags: centos7,centos8,debian10,ubuntu2004,alma8,rocky8,oracle8
set -x

LOG_PIPE=/tmp/log.pipe.$$

mkfifo ${LOG_PIPE}
LOG_FILE=/root/ncpa.log
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
    apt-get update
    which which 2>/dev/null || apt-get -y install which
    which lsb-release 2>/dev/null || apt-get -y install lsb-release
    which wget 2>/dev/null || apt-get -y install wget
    DEB_VERSION=$(lsb_release -r -s)
    if [ "${DEB_VERSION}" = "10" ]; then
        echo 'deb https://repo.nagios.com/deb/buster /' > /etc/apt/sources.list.d/nagios.list
    else
        echo 'deb https://repo.nagios.com/deb/focal /' > /etc/apt/sources.list.d/nagios.list
    fi
    apt-get -y install apt-transport-https gnupg
    wget -qO - https://repo.nagios.com/GPG-KEY-NAGIOS-V2 | apt-key add -
    apt-get update 
    apt-get -y install ncpa
else
    OSREL=$(printf '%.0f' $(rpm -qf --qf '%{version}' /etc/redhat-release))
    if [ ! "x${OSREL}" = "x8" ]; then
        rpm -Uvh https://repo.nagios.com/nagios/8/nagios-repo-8-1.el8.noarch.rpm
    else
        rpm -Uvh https://repo.nagios.com/nagios/7/nagios-repo-7-4.el7.noarch.rpm
    fi
    yum install ncpa -y
fi
if [ ! "($TOKEN)" = "()" ]; then
    sed -i '/community_string =/ccommunity_string = ($TOKEN)' /usr/local/ncpa/etc/ncpa.cfg
fi
/etc/init.d/ncpa_listener restart
which firewall-cmd 2>/dev/null || exit 0
firewall-cmd --permanent --zone=public --add-port=5693/tcp
firewall-cmd --reload

