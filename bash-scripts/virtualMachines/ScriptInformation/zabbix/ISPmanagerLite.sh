#!/bin/sh
# Рецепт установки ISPmanager Lite
# metadata_begin
# recipe: ISPmanager Lite
# tags: centos7,alma8,debian9,debian10,debian11,ubuntu1804,ubuntu2004,vzlinux8,lic_ISPmanager_6_Lite
# revision: 24
# description_ru: Рецепт установки ISPmanager Lite
# description_en: ISPmanager Lite installing recipe
# metadata_end
#
RNAME="ISPmanager Lite"

set -x

umask 0022

LOG_PIPE=/tmp/log.pipe.$$                                                                                                                                                                                                                    
mkfifo ${LOG_PIPE}
LOG_FILE=/root/ispmgr.log
touch ${LOG_FILE}
chmod 600 ${LOG_FILE}

tee < ${LOG_PIPE} ${LOG_FILE} &

exec > ${LOG_PIPE}
exec 2> ${LOG_PIPE}

killjobs() {
	rm -f /usr/local/mgr5/lib/pkgsh/hooks/ispmanager-plugin-revisium.sh
	rm -rf /usr/local/mgr5/etc/ihttpd_errpage
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

mkdir -p /usr/local/mgr5/etc/ihttpd_errpage
cat > /usr/local/mgr5/etc/ihttpd_errpage/manager_ispmgr.html << EOF
<!DOCTYPE html>
<html>
<head>
  <title>Panel is installing, please wait...</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <style>
    * {
      margin: 0;
      padding: 0;
      border: 0 none;
      background: none;
    }
    body {
      font-weight: normal;
      font-size: 11px;
      font-family: Arial;
    }
    #login-wrapper {
      width: 270px;
      left: 50%;
      margin-left: -135px;
      position: absolute;
      margin-top: -164px;
      top: 50%;
    }
    #login-form {
      width: 270px;
      background: #78a5df;
      height: 270px;
      -webkit-border-radius: 135px;
      -moz-border-radius: 135px;
      border-radius: 135px;
    }
    #login-form-form .loading {
      text-align: center;
      padding-top: 124px;
      color: white;
    }
    #login-wrapper #links {
      margin: 0 auto;
      display: table;
      margin-top: 75px;
    }
    ul li {
      list-style: none;
    }
    .body-login-form .tab-content {
      position: inherit;
      padding: inherit;
    }
    #login-wrapper #links li {
      padding-left: 24px;
      line-height: 23px;
    }
    a {
      color: #537393;
    }
  </style>
  <script type="text/javascript">
    setTimeout(function() {
      window.location.reload();
    }, 60000);
  </script>
</head>
<body class="body-login-form">
<div id="main-wrapper">
  <div id="overlay" class="hide"></div>
  <div id="content" class="tab-content active" data-tabid="tab1"><div id="login-wrapper">
    <div id="login-form">
      <div id="login-form-form">
        <h2 class="loading">ISPmanager is installing, please wait...</h2>
      </div>
    </div>
    <div id="links"><ul><li class="copyright"><a href="https://www.exo-soft.ru/" target="_blank">Exosoft © 2021</a></li></ul></div>
    <div id="error-log" style="display: none;"></div>
  </div></div>
</div>
</body>
</html>
EOF

mkdir -p /usr/local/mgr5/lib/pkgsh/hooks
cat > /usr/local/mgr5/lib/pkgsh/hooks/ispmanager-plugin-revisium.sh << EOF
echo "Locked"
exit 1
EOF

if [ "#${OSNAME}" = "#debian" ]; then
	if [ -f /etc/init.d/bind9 ] && ! dpkg -S /etc/init.d/bind9 ; then
		rm -f /etc/init.d/bind9
	fi
	apt-get update --allow-releaseinfo-change || :
fi

if [ "#${OSNAME}" = "#centos" ]; then

	if [ ! "($HTTPPROXYv4)" = "()" ]; then
		# Стрипаем пробелы, если они есть
		PR="($HTTPPROXYv4)"
		PR=$(echo ${PR} | sed "s/''//g" | sed 's/""//g')
		if [ -n "${PR}" ]; then
			echo "proxy=${PR}" >> /etc/yum.conf
#			export http_proxy="${PR}"
#			export HTTP_PROXY="${PR}"
		fi
	fi

#	sed -i"ispbak" -r "s/^(mirrorlist=)/#\1/g; s/^#(baseurl=)/\1/g" /etc/yum.repos.d/*.repo
    yum install -y curl ca-certificates
	echo "Installing ispmgr5"
	cd /root
	selinuxenabled && echo "selinux enabled"

	curl -o install.sh "https://download.ispsystem.com/reciepe.install.sh" || (sleep 1; curl -o install.sh "https://download.ispsystem.com/reciepe.install.sh") || (sleep 1; curl -o install.sh "https://download.ispsystem.com/reciepe.install.sh")
	sh install.sh --silent --ignore-hostname --release beta --ispmgr6 ispmanager-lite

	if [ "#$(rpm -qf /etc/centos-release --qf "%{version}")" = "#7" ]; then
		# centos-7
		yum -y remove ispmanager-lite ispmanager-pkg-httpd
		yum -y install ispmanager-pkg-httpd-itk ispmanager-pkg-php ispmanager-pkg-myadmin ispmanager-pkg-roundcube
	fi
	yum clean all

	sed -i -r "s|^short_open_tag = Off|short_open_tag = On|" /etc/php.ini
	_timezone="($TIMEZONE)"
	if [ -n "${_timezone}" ] && [ ! "${_timezone}" = "()" ]; then
		if ! grep -q "^date.timezone =" /etc/php.ini ; then
			sed -i -r "s|;date.timezone =|date.timezone = ${_timezone}|" /etc/php.ini
		else
			sed -i -r "s|^date.timezone = .+|date.timezone = ${_timezone}|" /etc/php.ini
		fi
	fi
	/usr/local/mgr5/sbin/mgrctl -m ispmgr -R feature.update sok=ok

#	for file in /etc/yum.repos.d/*.repoispbak; do mv -f $file $(echo $file|sed 's/ispbak//'); done
	sed -r -i "/proxy=/d" /etc/yum.conf
	echo "Installation finished at $(date)"
else
	sed -i -r '/jessie-updates/d' /etc/apt/sources.list || :
    apt update
    apt install -y wget ca-certificates
	wget -O install.sh "https://download.ispsystem.com/reciepe.install.sh" || (sleep 1; wget -O install.sh "https://download.ispsystem.com/reciepe.install.sh") || (sleep 1; wget -O install.sh "https://download.ispsystem.com/reciepe.install.sh")
	# Wait firstrun script
	while ps uxaww | grep  -v grep | grep -Eq 'apt-get|dpkg' ; do echo "waiting..." ; sleep 3 ; done
	sh install.sh --silent --ignore-hostname --release beta --ispmgr6 ispmanager-lite
fi

echo "utf-8" >> /usr/local/mgr5/etc/charset
echo "windows-1251" >> /usr/local/mgr5/etc/charset

/usr/local/mgr5/sbin/mgrctl -m ispmgr db.server.edit elid=MySQL sok=ok || exit 1
