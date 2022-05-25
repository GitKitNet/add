#!/bin/sh
#
# Рецепт установки Django с uwsgi и nginx. Инструкции будут при открытии IP адреса сервера в браузере
# metadata_begin
# recipe: Django
# tags: centos7,centos8,debian8,ubuntu1604,ubuntu1804,rocky8,alma8,oracle8
# revision: 6
# description_ru: Рецепт установки Django с uwsgi и nginx. Инструкции будут при открытии IP адреса сервера в браузере
# description_en: Django + uwsgi + nginx. Instructions are avalible on server ip url
# metadata_end
#
RNAME=Django
DJANGO_VER=1.11.8  # Last python2 release

set -x

umask 0022

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
	
	pkglist="uwsgi uwsgi-plugin-python nginx python-virtualenv wget mysql-server mysql-client python-mysqldb"
	
	_tmppass="($PASS)"
    if [ -n "${_tmppass}" ] && [ "${_tmppass}" != "()" ]; then
        mysqlpass="${_tmppass}"
    else
        apt-get -y install pwgen
        mysqlpass=$(pwgen -s 10 1)
    fi

    if [ -z "$(ls /var/lib/mysql/)" ]; then
        install_mysql=yes
    fi
    if [ -n "${install_mysql}" ]; then
        # Setting mysql root password
        echo "mysql-server mysql-server/root_password password ${mysqlpass}" | debconf-set-selections
        echo "mysql-server mysql-server/root_password_again password ${mysqlpass}" | debconf-set-selections
    fi

    # Installing packages
    apt-get -y install ${pkglist}

    if [ -n "${install_mysql}" ] && [ ! -e /root/.my.cnf ]; then
        RootMyCnf ${mysqlpass}
    fi

    # Installing packages
    apt-get -y install ${pkglist}
    uwsgiconf=/etc/uwsgi/apps-enabled/django.ini
else
    OSREL=$(printf '%.0f' $(rpm -qf --qf '%{version}' /etc/redhat-release))

    yum -y install epel-release || yum -y oracle-epel-release-el8
    # Setting proxy
    if [ ! "($HTTPPROXYv4)" = "()" ]; then
        # Стрипаем пробелы, если они есть
        PR="($HTTPPROXYv4)"
        PR=$(echo ${PR} | sed "s/''//g" | sed 's/""//g')
        if [ -n "${PR}" ]; then
            echo "proxy=${PR}" >> /etc/yum.conf
        fi
    fi
    if [ "x${OSREL}" = "x8" ]; then
        pkglist="python3 python3-pip python3-virtualenv"
    else
        uwsgiconf=/etc/uwsgi.d/django.ini
        emperor=yes

        pkglist="uwsgi uwsgi-plugin-python nginx python-virtualenv wget MySQL-python"

    fi
    NginxRepo
    pkglist="${pkglist} nginx"
    if [ "${OSREL}" -ge 7 ]; then
        pkglist="${pkglist} mariadb-server"
        mysqlname=mariadb
    else
        pkglist="${pkglist} mysql-server"
        mysqlname=mysqld
    fi

    yum -y install ${pkglist} || yum -y install ${pkglist} || yum -y install ${pkglist}

    # Removing proxy
    sed -r -i "/proxy=/d" /etc/yum.conf

    Service ${mysqlname} enable

    if [ -z "$(ls /var/lib/mysql/)" ]; then
        install_mysql=yes
    fi
    Service ${mysqlname} start

    if [ -n "${install_mysql}" ]; then
        # Setting mysql password

        _tmppass="($PASS)"
        if [ -n "${_tmppass}" ] && [ "${_tmppass}" != "()" ]; then
            mysqlpass="${_tmppass}"
        else
            rpm -q pwgen || yum -y install pwgen
            mysqlpass=$(pwgen -s 10 1)
        fi
        /usr/bin/mysqladmin -u root password ${mysqlpass}
        RootMyCnf ${mysqlpass}
        echo "DELETE FROM user WHERE Password='';" | mysql --defaults-file=/root/.my.cnf -N mysql
    fi


fi
mkdir -p /var/www
useradd -d /var/www/django django
mkdir -p /var/www/django
chown django:django /var/www/django
cd /var/www/django
su django -c "virtualenv venv"
source venv/bin/activate
su django -c ". venv/bin/activate ; pip install django==${DJANGO_VER}"
su django -c ". venv/bin/activate ; django-admin startproject mysite"
mv mysite project
test -f /etc/nginx/conf.d/default.conf   && echo "#Disabled" > /etc/nginx/conf.d/default.conf
test -f /etc/nginx/conf.d/default        && echo "#Disabled" > /etc/nginx/conf.d/default
test -f /etc/nginx/sites-enabled/default &&echo "#Disabled" > /etc/nginx/sites-enabled/default
main_ip=$(ip route get 1 | grep -Po '(?<=src )[^ ]+')
if [ -n "${main_ip}" ]; then
    sed -i -r "/ALLOWED_HOSTS/s/\[\]/['${main_ip}']/" project/mysite/settings.py
fi


if [ "x${OSREL}" = "x8" ]; then
    sed -i '/server {/,$d'  /etc/nginx/nginx.conf
    echo '}' >> /etc/nginx/nginx.conf
    su django -c ". venv/bin/activate ; cd project; python manage.py migrate"
    cat << EOF > /usr/lib/systemd/system/django.service
[Unit]
Description = Django
After = syslog.target nss-lookup.target network.target network-online.target mysql.target
Wants = network-online.target

[Service]
Type = simple
WorkingDirectory = /var/www/django/project
User = django
ExecStart = /var/www/django/venv/bin/python manage.py runserver 0.0.0.0:8000
Restart = on-failure

[Install]
WantedBy = multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable django
    systemctl start django
    cat > /etc/nginx/conf.d/django.conf << EOF
upstream django {
    server 127.0.0.1:8000;
}

server {
    listen       80;
    server_name  django.site;

    proxy_set_header   Host \$http_host;
    proxy_set_header   X-Real-IP \$remote_addr;
    proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto \$scheme;

    proxy_redirect off;

    location /static {
        root /var/www/django/project/mysyte/static;
    }
    
    location /media {
        root /var/www/django/project/mysite/media;
    }

    location / {
        proxy_pass http://django\$request_uri;
    }
}
EOF
else

    cat > ${uwsgiconf} << EOF
[uwsgi]
plugin=python
chdir=/var/www/django/project
virtualenv=/var/www/django/venv
module=mysite.wsgi:application
master=True
vacuum=True
socket=127.0.0.1:9000
py-autoreload=5
EOF

    test -n "${emperor}" && chown django:django ${uwsgiconf}

    test -f /etc/nginx/uwsgi_params || wget -O /etc/nginx/uwsgi_params https://raw.githubusercontent.com/nginx/nginx/master/conf/uwsgi_params

    cat > /etc/nginx/conf.d/django.conf << EOF
upstream uwsgi {
    server 127.0.0.1:9000;
}

server {
    listen       80;
    server_name  django.site;

    proxy_set_header   Host \$http_host;                                                                                                                     
    proxy_set_header   X-Real-IP \$remote_addr;                                                                                                                   
    proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto \$scheme;

    proxy_redirect off;

    location /static {
        root /var/www/django/project/mysyte/static;
    }
    
    location /media {
        root /var/www/django/project/mysite/media;
    }

    location / {
        include uwsgi_params;
        uwsgi_pass uwsgi;
    }
}
EOF


    cd /var/www/django/project/mysite

    sed -i -r "/^urlpatterns =.*/a\ \ \ \ url(r'^', views.default),"  urls.py
    sed -i -r "/urlpatterns/i import views" urls.py
    sed -i -r "/^TEMPLATES =/,/\// s/(\s+'DIRS':\s*\[)/\1 BASE_DIR + '\/mysite\/templates\/',/" settings.py

    mkdir templates
    cat > templates/default.html << EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Django recipe completed</title>

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">

  </head>
  <body>
<div class="container">
<div class="jumbotron">
<p class="lead">
{% if lang == "ru" %}
Django установлен.<br/>
Для запуска своего приложения необходимо:
<ul>
<li>Удалить файлы из директории {{ ddir }} и заменить их своим приложением</li>
<li>В файлах конфигурации nginx и uwsgi (/etc/nginx/conf.d/django.conf , /etc/uwsgi.d/django.ini , /etc/uwsgi/app-enabled/django.ini (в зависимости от ОС)) заменить mysite на имя Вашего приложения(его директорию)</li>
<li>Перезапустить nginx и uwsgi: service nginx restart ; service uwsgi restart</li>
</ul>
{% else %}
Django installed.</br>
For deploy Your application You need:
<li>Remove all files from {{ ddir }} and put Your application there</li>
<li>In config files (/etc/nginx/conf.d/django.conf , /etc/uwsgi.d/django.ini , /etc/uwsgi/app-enabled/django.ini (depends on OS)) replace mysite to Your application's name (dir name)</li>
<li>Restart nginx and uwsgi: service nginx restart ; service uwsgi restart</li>
{% endif %}
</p>
</div>
</div>

  </body>
</html>
EOF

    cat > views.py << EOF

from django.http import HttpResponse
from django.shortcuts import render_to_response
import os

def default(request):
        if request.META.get('HTTP_ACCEPT_LANGUAGE') and 'ru-RU' in request.META.get('HTTP_ACCEPT_LANGUAGE'):
                lang = 'ru'
        else:
                lang = 'en'
        ddir = os.getcwd()
        return render_to_response('default.html', {'lang': lang, 'ddir': ddir})
EOF
	if [ -e /usr/bin/systemd-tmpfiles ]; then
		systemd-tmpfiles --create
	fi
    Service uwsgi restart
    Service uwsgi enable
    if [ -n "$(which dpkg 2>/dev/null)" ] && dpkg -l | grep -q apache2 ; then
        Service apache2 disable
        Service apache2 stop
    fi
fi

Service nginx enable
Service nginx restart

if [ "${OSNAME}" = "centos" ]; then
	if [ -n "$(which firewall-cmd)" ] && Service firewalld status ; then
		firewall-cmd --add-port=80/tcp
		firewall-cmd --add-port=80/tcp --permanent
	fi
fi
