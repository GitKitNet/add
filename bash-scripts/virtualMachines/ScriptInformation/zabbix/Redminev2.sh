#!/bin/sh
#Баг трекер Redmine. Логин: admin. Пароль или admin или пароль рута (зависит от ОС)
# metadata_begin
# recipe: Redmine
# tags: centos8,debian10,oracle8,rocky8,alma8
# revision: 23
# description_ru: Баг трекер Redmine. Логин: admin. Пароль или admin или пароль рута (зависит от ОС)
# description_en: Redmine bug tracker. Login: admin. Password: admin or Your root password (depend on os type)
# metadata_end
#
RNAME=Redmine
export REDMINE_VER=4.2.3

set -x

LOG_PIPE=/tmp/log.pipe.$$
mkfifo ${LOG_PIPE}
LOG_FILE=/root/${RNAME}.log
touch ${LOG_FILE}
chmod 600 ${LOG_FILE}

tee < ${LOG_PIPE} ${LOG_FILE} &

exec > ${LOG_PIPE}
exec 2> ${LOG_PIPE}
umask 0022

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

RootMyCnf() {
	# Saving mysql password
	touch /root/.my.cnf 
	chmod 600 /root/.my.cnf
	echo "[client]" > /root/.my.cnf
	echo "password=${1}" >> /root/.my.cnf

}

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

NginxConfig() {
	echo '# Upstream Ruby process cluster for load balancing
upstream thin_cluster {
    server unix:/var/run/redmine/redmine.0.sock;
    server unix:/var/run/redmine/redmine.1.sock;
    server unix:/var/run/redmine/redmine.2.sock;
}

server {
    listen       80;
    server_name  your.domain.name;

    proxy_set_header   Host $http_host;                                                                                                                     
    proxy_set_header   X-Real-IP $remote_addr;                                                                                                                   
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;

    client_max_body_size       10m;
    client_body_buffer_size    128k;

    proxy_connect_timeout      90;
    proxy_send_timeout         90;
    proxy_read_timeout         90;

    proxy_buffer_size          4k;
    proxy_buffers              4 32k;
    proxy_busy_buffers_size    64k;
    proxy_temp_file_write_size 64k;

    root /var/www/redmine/public;

    proxy_redirect off;

    location / {
        try_files $uri/index.html $uri.html $uri @cluster;
    }

    location @cluster {
        proxy_pass http://thin_cluster;
    }
}
' > ${1}
}

ThinInitdBundleDebian7() {
	echo '#!/bin/bash
### BEGIN INIT INFO
# Provides:          thin
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: thin initscript
# Description:       thin
### END INIT INFO

## instead of using the installed script at /usr/local/ruby/bin/thin which
## fires up thin without bundler, this will cd into each site found in
## /etc/thin and run 'bundle exec thin'. Not pretty, but it is necessary to
## launch thin with bundler to avoid gem versioning conflicts


SCRIPT_NAME=/etc/init.d/thin
CONFIG_PATH=/etc/thin
BUNDLE_CMD=/usr/local/bin/bundle

bundle_exec_thin ()
{
        for CONFIG_FILE in "$CONFIG_PATH/*.yml"; do
           SITE_DIR=`awk '\''/^chdir:/ { print $2; }'\'' $CONFIG_FILE`
           cd $SITE_DIR
           $BUNDLE_CMD exec thin $1 -C $CONFIG_FILE
        done
}


case "$1" in
  start)
        bundle_exec_thin start
        ;;
  stop)
        bundle_exec_thin stop
        ;;
  restart)
        bundle_exec_thin restart
        ;;
  *)
        echo "Usage: $SCRIPT_NAME {start|stop|restart}" >&2
        exit 3
        ;;
esac

:
' >> ${1}
	chmod +x ${1}
}


ThinInitdBundleCentos6() {
	echo '#!/bin/bash
### BEGIN INIT INFO
# Provides:          thin
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: thin initscript
# Description:       thin
### END INIT INFO

## instead of using the installed script at /usr/local/ruby/bin/thin which
## fires up thin without bundler, this will cd into each site found in
## /etc/thin and run 'bundle exec thin'. Not pretty, but it is necessary to
## launch thin with bundler to avoid gem versioning conflicts

. /opt/rh/ruby193/enable

SCRIPT_NAME=/etc/init.d/thin
CONFIG_PATH=/etc/thin
BUNDLE_CMD=/opt/rh/ruby193/root/usr/bin/bundle

bundle_exec_thin ()
{
        for CONFIG_FILE in "$CONFIG_PATH/*.yml"; do
           SITE_DIR=`awk '\''/^chdir:/ { print $2; }'\'' $CONFIG_FILE`
           cd $SITE_DIR
           $BUNDLE_CMD exec thin $1 -C $CONFIG_FILE
        done
}


case "$1" in
  start)
        bundle_exec_thin start
        ;;
  stop)
        bundle_exec_thin stop
        ;;
  restart)
        bundle_exec_thin restart
        ;;
  *)
        echo "Usage: $SCRIPT_NAME {start|stop|restart}" >&2
        exit 3
        ;;
esac

:
' >> ${1}
	chmod +x ${1}
}

ThinSystemdBundleScl() {
	echo '[Unit]
Description=A fast and very simple Ruby web server
After=syslog.target network.target

[Service]
Type=forking
WorkingDirectory=/var/www/redmine
ExecStart=/usr/bin/scl enable rh-ruby25 -- bundle exec thin start -C /etc/thin/redmine.yml
ExecReload=/usr/bin/scl enable rh-ruby25 -- bundle exec thin restart -C /etc/thin/redmine.yml
ExecStop=/usr/bin/scl enable rh-ruby25 -- bundle exec thin stop -C /etc/thin/redmine.yml
TimeoutSec=300

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/${1}.service

echo 'd /var/run/redmine 0755 redmine redmine -' > /etc/tmpfiles.d/${1}.conf
}

ThinSystemdBundle() {
	echo '[Unit]
Description=A fast and very simple Ruby web server
After=syslog.target network.target

[Service]
Type=forking
WorkingDirectory=/var/www/redmine
ExecStart=/usr/bin/bundle exec thin start -C /etc/thin/redmine.yml
ExecReload=/usr/bin/bundle exec thin restart -C /etc/thin/redmine.yml
ExecStop=/usr/bin/bundle exec thin stop -C /etc/thin/redmine.yml
TimeoutSec=300

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/${1}.service

echo 'd /var/run/redmine 0755 redmine redmine -' > /etc/tmpfiles.d/${1}.conf
}

NginxRepo() {
	# nginx repo
cat > /etc/yum.repos.d/nginx.repo << EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/${OSREL}/\$basearch/
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
	pkglist="vim ruby ruby-dev gcc g++ libmagickwand-dev bundler nginx pwgen"
	if [ "x$(lsb_release -s -c)" = "xstretch" ]; then
		pkglist="${pkglist} mysql-server mysql-client default-libmysqlclient-dev"
	elif [ "x$(lsb_release -s -c)" = "xbuster" ]; then
		pkglist="${pkglist} mariadb-server libmariadb-dev-compat libmariadb-dev"
	elif [ "x$(lsb_release -s -c)" = "xbionic" ]; then
		pkglist="${pkglist} mysql-server mysql-client default-libmysqlclient-dev libmysql-ruby"
	else
		pkglist="${pkglist} mysql-server mysql-client libmysqlclient-dev"
	fi
	
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
	apt-get -y install ${pkglist} || apt-get -y install ${pkglist} || apt-get -y install ${pkglist}

	if [ "${install_mysql}" ] && [ ! -e /root/.my.cnf ]; then
		RootMyCnf ${mysqlpass}
	fi

else
	OSREL=$(printf '%0.f' $(rpm -qf --qf '%{version}' /etc/redhat-release))

	# Setting proxy
	if [ ! "($HTTPPROXYv4)" = "()" ]; then
		# Стрипаем пробелы, если они есть
		PR="($HTTPPROXYv4)"
		PR=$(echo ${PR} | sed "s/''//g" | sed 's/""//g')
		if [ -n "${PR}" ]; then
			echo "proxy=${PR}" >> /etc/yum.conf
		fi
	fi

	NginxRepo
	
	if [ "x${OSREL}" = "x6" ]; then
		yum -y install epel-release centos-release-scl
		pkglist="pwgen vim ruby193 ruby193-ruby-devel ImageMagick-devel" # from scl
    elif [ "x${OSREL}" = "x8" ]; then
        dnf -y install epel-release || dnf -y install oracle-epel-release-el8
        pkglist="ruby ruby-devel rubygem-bundler libxslt-devel libxml2-devel tar redhat-rpm-config make ImageMagick"
	else
		yum -y install epel-release centos-release-scl
		pkglist="pwgen vim rh-ruby25-ruby rh-ruby25-ruby-devel rh-ruby25-rubygem-bundler libxml2-devel libxslt-devel ImageMagick-devel" # rubygem-thin rpm package is broken
	fi
	if [ "${OSREL}" -ge 7 ]; then
		pkglist="${pkglist} mariadb-server mariadb-devel"
		mysqlname=mariadb
	else
		pkglist="${pkglist} mysql-server mysql-devel"
		mysqlname=mysqld
	fi
	pkglist="${pkglist} gcc gcc-c++ wget nginx which pwgen"

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


	if [ "x${OSREL}" = "x6" ]; then
		. /opt/rh/ruby193/enable
	elif [ "x${OSREL}" = "x7" ]; then
		. /opt/rh/rh-ruby25/enable
	fi
fi

# Fetch and extract
wget --no-check-certificate -O /tmp/redmine-${REDMINE_VER}.tar.gz http://www.redmine.org/releases/redmine-${REDMINE_VER}.tar.gz
mkdir -p /var/www/redmine
tar --strip-components=1 -xpzf /tmp/redmine-${REDMINE_VER}.tar.gz -C /var/www/redmine

# Create db
echo "CREATE DATABASE redmine_prod DEFAULT CHARACTER SET utf8" | mysql --defaults-file=/root/.my.cnf -N || exit 1
echo "CREATE DATABASE redmine_dev DEFAULT CHARACTER SET utf8" | mysql --defaults-file=/root/.my.cnf -N || exit 1
redmine_db_pass=$(pwgen -s 10 1)
echo "CREATE USER 'redmine'@'localhost' IDENTIFIED BY '${redmine_db_pass}';" | mysql --defaults-file=/root/.my.cnf -N mysql || exit 1
echo "GRANT ALL PRIVILEGES ON redmine_dev.* TO 'redmine'@'localhost';" | mysql --defaults-file=/root/.my.cnf -N mysql || exit 1
echo "GRANT ALL PRIVILEGES ON redmine_prod.* TO 'redmine'@'localhost';" | mysql --defaults-file=/root/.my.cnf -N mysql || exit 1

# DB config
cat > /var/www/redmine/config/database.yml << EOF
development:
  adapter: mysql2
  database: redmine_dev
  host: localhost
  username: redmine
  password: ${redmine_db_pass}
production:
  adapter: mysql2
  database: redmine_prod
  host: localhost
  username: redmine
  password: ${redmine_db_pass}
EOF

useradd redmine
mkdir -p /var/run/redmine
chown redmine /var/run/redmine
cd /var/www/redmine

export RAILS_ENV=production
export REDMINE_LANG=en
export HOME="/home/redmine"

# Gem installing
if [ "x${OSNAME}" = "xcentos" ]; then
	if [ "x${OSREL}" = "x6" ]; then
		gem update bundler
	else
		bundle config build.nokogiri --use-system-libraries
		mkdir -p .gem/ruby/2.3.0
		gem install --install-dir .gem/ruby/2.3.0 pkg-config -v "~> 1.1"
		gem install --install-dir .gem/ruby/2.3.0 nokogiri -- --use-system-libraries
	fi
else
	if [ "x$(lsb_release -s -c)" = "xwheezy" ] || [ "x$(lsb_release -s -c)" = "xbuster" ] || [ "x$(lsb_release -s -c)" = "xtrusty" ]; then
		gem update bundler
	fi
fi
echo 'gem "bigdecimal"' >> Gemfile
echo 'gem "json"' >> Gemfile
bundle install --path .gem

# Run migration
pwgen -s 32 1 > config/master.key
chmod 600 config/master.key
EDITOR=cat bundle exec rails credentials:edit
chown -R redmine:redmine config
bundle exec rake db:migrate || exit 1
bundle exec rake generate_secret_token

# load default data
bundle exec rake redmine:load_default_data

# Change password
_tmppass="($PASS)"
if [ -n "${_tmppass}" ] && [ "${_tmppass}" != "()" ]; then
	hashed_pass=$(echo -n ${_tmppass} | sha1sum |awk '{printf $1}'|sha1sum | awk '{printf $1}')
	echo "update user set hashed_password='49d76bd94e46e59d575f399757c476a7dd22874b', salt='' where id=1;" | mysql --defaults-file=/root/.my.cnf -N mysql
fi


# Dir permisiions
mkdir -p tmp tmp/pdf public/plugin_assets
chown -R redmine:redmine files log tmp public/plugin_assets
chmod -R 755 files log tmp public/plugin_assets

# Thin
if [ "x${OSNAME}" = "xcentos" ]; then
	if [ "x${OSREL}" = "x6" ]; then
		echo 'gem "thin"' >> Gemfile
		bundle install
		ThinInitdBundleCentos6 /etc/init.d/thin193
		thinservice=thin193
# rubygem-thin rpm package is broken
	else
		echo 'gem "thin"' >> Gemfile
		bundle install
        if [ "x${OSREL}" = "x7" ]; then
		    ThinSystemdBundleScl thin-redmine
        else
            ThinSystemdBundle thin-redmine
        fi
		systemctl daemon-reload
		thinservice=thin-redmine
	fi
else
	if [ "x$(lsb_release -c -s)" = "xwheezy" ] || [ "x$(lsb_release -c -s)" = "xtrusty" ]; then
		echo 'gem "thin"' >> Gemfile
		bundle install
		ThinInitdBundleDebian7 /etc/init.d/thin
		thinservice=thin
	else
		echo 'gem "thin"' >> Gemfile
		bundle install
		ThinSystemdBundle thin-redmine
		systemctl daemon-reload
		thinservice=thin-redmine

	fi
fi

mkdir -p /etc/thin
echo 'pid: /var/www/redmine/tmp/pids/thin.pid
group: redmine
wait: 30
timeout: 30
log: /var/www/redmine/log/thin.log
max_conns: 1024
require: []

environment: production
max_persistent_conns: 512
servers: 3
daemonize: true
user: redmine
socket: /var/run/redmine/redmine.sock
chdir: /var/www/redmine 
' > /etc/thin/redmine.yml

Service ${thinservice} enable
Service ${thinservice} start || exit 1

# Nginx
if [ -f /etc/nginx/conf.d/default.conf ]; then
	echo "#Disabled" > /etc/nginx/conf.d/default.conf
fi
if [ -f /etc/nginx/sites-enabled/default ]; then
	rm /etc/nginx/sites-enabled/default
fi
if [ "x${OSREL}" = "x8" ]; then
    sed -i '/server {/,$d'  /etc/nginx/nginx.conf
    echo '}' >> /etc/nginx/nginx.conf
fi
NginxConfig /etc/nginx/conf.d/redmine.conf

if Service apache2 status ; then
	Service apache2 stop
	Service apache2 disable
fi

Service nginx enable
Service nginx restart
if [ "${OSNAME}" = "centos" ]; then
    which firewall-cmd 2>/dev/null || exit 0
	firewall-cmd --permanent --zone=public --add-port=80/tcp
	firewall-cmd --reload
fi
