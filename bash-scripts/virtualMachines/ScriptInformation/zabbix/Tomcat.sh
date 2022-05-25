#!/bin/sh
#
# Tomcat сервер. Запущен на порту 8080. Если виртуализация не openvz, то также доступен админ-интерфейс с паролем рута.
# metadata_begin
# recipe: Tomcat
# tags: centos,debian,ubuntu1604,ubuntu1804
# revision: 6
# description_ru: Tomcat сервер. Запущен на порту 8080. Если виртуализация не openvz, то также доступен админ-интерфейс с паролем рута.
# description_en: Tomcat server. Listenin on 8080. Admin interface avalible if not openvz. Password same as root password.
# metadata_end
#
RNAME=Tomcat

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
	test -n "$(jobs -p)" && kill $(jobs -p) || :
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

	if [ -f /usr/bin/systemctl ]; then
		systemctl ${2} ${1}.service
	elif [ -f /lib/systemd/systemd ]; then
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

if [ "${OSNAME}" = "debian" ]; then
	export DEBIAN_FRONTEND="noninteractive"

	# Wait firstrun script
	while ps uxaww | grep  -v grep | grep -Eq 'apt-get|dpkg' ; do echo "waiting..." ; sleep 3 ; done
	apt-get update --allow-releaseinfo-change || :
	apt-get update
	which lsb-release 2>/dev/null || apt-get -y install lsb-release
    RELEASE=$(lsb_release -s -c)
	if [ "x${RELEASE}" = "xwheezy" ] ; then
	    pkglist="tomcat7 tomcat7-admin tomcat7-examples tomcat7-user"
	    servicename=tomcat7
	elif [ "x${RELEASE}" = "xjessie" ] || [ "x${RELEASE}" = "xstretch" ] || [ "x${RELEASE}" = "xxenial" ]; then
	    pkglist="tomcat8 tomcat8-admin tomcat8-examples tomcat8-user"
	    servicename=tomcat8
	elif [ "x${RELEASE}" = "xbuster" ] || [ "x${RELEASE}" = "xbionic" ] ; then
	    pkglist="tomcat9 tomcat9-admin tomcat9-examples tomcat9-user"
	    servicename=tomcat9
	fi
	apt-get -y install vim ${pkglist}

else
	OSREL=$(printf '%.0f' $(rpm -qf --qf '%{version}' /etc/redhat-release))

	# Setting proxy
	if [ ! "($HTTPPROXYv4)" = "()" ]; then
		# Стрипаем пробелы, если они есть
		PR="($HTTPPROXYv4)"
		PR=$(echo ${PR} | sed "s/''//g" | sed 's/""//g')
		if [ -n "${PR}" ]; then
			echo "proxy=${PR}" >> /etc/yum.conf
		fi
	fi

	yum -y install epel-release || yum -y install oracle-epel-release-el8

    if [ "x${OSREL}" = "x8" ]; then
        pkglist="java-11-openjdk tar wget"
    else
        pkglist="vim java-1.7.0-openjdk tomcat tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc" # on centos-6 this is tomcat7 from epel repo
    fi

	yum -y install ${pkglist} || yum -y install ${pkglist} || yum -y install ${pkglist}
	# Removing proxy
	sed -r -i "/proxy=/d" /etc/yum.conf

	servicename=tomcat
fi
if [ "x${OSREL}" = "x8" ]; then
    groupadd --system tomcat
    useradd -d /usr/share/tomcat -r -s /bin/false -g tomcat tomcat
    VER="9.0.34"
    wget -O - https://archive.apache.org/dist/tomcat/tomcat-9/v${VER}/bin/apache-tomcat-${VER}.tar.gz | tar xzv -C /usr/share/
    ln -s /usr/share/apache-tomcat-$VER/ /usr/share/tomcat
    chown -R tomcat:tomcat /usr/share/tomcat
    chown -R tomcat:tomcat /usr/share/apache-tomcat-$VER/
    cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat Server
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment='JAVA_OPTS=-Djava.awt.headless=true'
Environment=CATALINA_HOME=/usr/share/tomcat
Environment=CATALINA_BASE=/usr/share/tomcat
Environment=CATALINA_PID=/usr/share/tomcat/temp/tomcat.pid
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M'
ExecStart=/usr/share/tomcat/bin/catalina.sh start
ExecStop=/usr/share/tomcat/bin/catalina.sh stop

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
fi
# Setting admin password if macro exists
_tmppass="($PASS)"
if [ -n "${_tmppass}" ] && [ "${_tmppass}" != "()" ]; then
	if [ -f /etc/tomcat/tomcat-users.xml ]; then
		usersxml=/etc/tomcat/tomcat-users.xml
	elif [ -f /etc/tomcat7/tomcat-users.xml ]; then
		usersxml=/etc/tomcat7/tomcat-users.xml
	elif [ -f /etc/tomcat7/server.xml ]; then
		usersxml=/etc/tomcat7/server.xml
	elif [ -f /etc/tomcat8/tomcat-users.xml ]; then
		usersxml=/etc/tomcat8/tomcat-users.xml
	elif [ -f /etc/tomcat9/tomcat-users.xml ]; then
		usersxml=/etc/tomcat9/tomcat-users.xml
	elif [ -f /etc/tomcat9/server.xml ]; then
		usersxml=/etc/tomcat9/server.xml
	elif [ -f /usr/share/tomcat/conf/tomcat-users.xml ]; then
		usersxml=/usr/share/tomcat/conf/tomcat-users.xml
	else
		usersxml=/etc/tomcat/server.xml
	fi
	sed -i -r "/<\/tomcat-users>/i <user name=\"admin\" password=\"${_tmppass}\" roles=\"manager-gui,admin-gui\"\/>" ${usersxml}
fi

Service ${servicename} restart
Service ${servicename} enable

if [ "${OSNAME}" = "centos" ]; then
	if [ -n "$(which firewall-cmd)" ] && Service firewalld status ; then
		firewall-cmd --add-port=8080/tcp
		firewall-cmd --add-port=8080/tcp --permanent
	fi
fi
