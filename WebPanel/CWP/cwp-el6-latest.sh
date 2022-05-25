#!/bin/bash

########################################################################
# Use of code or any part of it is strictly prohibited. File protected by copyright law and provided under license.
# To Use any part of this code you need to get a writen approval from the code owner: info@centos-webpanel.com
########################################################################
#
# CWP instaler for CentOS 6
#
########################################################################
link='https://dl1.centos-webpanel.com/files/cwp-latest'

help() {
  echo "Usage: $0 [OPTIONS]
  -r, --restart       Restart server after install  [yes]  default: no
  -p, --phpfpm        Install PHP-FPM  [5.4|5.5|5.6|7.0|7.1|7.2|7.3]  default: no
  -s, --softaculous   Install Softaculous  [yes]  default: no
  -m, --modsecurity   Install ModSecurity CWAF  [yes]  default: no
  -h, --help          Print this help

  Example: sh $0 -r yes --phpfpm 7.2 --softaculous yes --modsecurity yes"
    exit 1
}

for argument; do
    delimiter=""
    case "$argument" in
        --restart)              arguments="${arguments}-r " ;;
        --phpfpm)               arguments="${arguments}-p " ;;
        --softaculous)          arguments="${arguments}-s " ;;
        --modsecurity)          arguments="${arguments}-m " ;;

        --help)                 arguments="${arguments}-h " ;;
        *)                      [[ "${argument:0:1}" == "-" ]] || delimiter="\""
                                arguments="${arguments}${delimiter}${argument}${delimiter} ";;
    esac
done
eval set -- "$arguments"

while getopts "r:p:s:m:h" Oflags; do
    case $Oflags in
        r) restart=$OPTARG ;;            # Restart server after install
        p) phpfpm=$OPTARG ;;             # Install PHP-FPM
        s) softaculous=$OPTARG ;;        # Install Softaculous
        m) modsecurity=$OPTARG ;;        # Install ModSecurity CWAF 

        h) help ;;                       # Print help
        *) help ;;                       # Print help 
    esac
done

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [ -e "/usr/local/cwpsrv/" ]; then
    echo
    echo "CWP is already installed on your server."
    echo "If you want to update it, run this command: sh /scripts/update_cwp"
    echo 
    exit 1
fi

#clear
echo "#################################################################"
echo "#             CentOS Web Panel (CWP)   Installer                #"
echo "#################################################################"
echo ""
echo "visit www.centos-webpanel.com"
echo ""

if [ ! -e "/etc/redhat-release" ]; then
	echo "You need to have CentOS, RedHat or CloudLinux system!"
exit 1
fi

arch=$(uname -m)
if [[ $arch == "i686" ]]; then
    platform="x86"
    mariadb="x86"
else
	platform="x86-64"
    mariadb="amd64"
fi

CHKDATE=`date +%Y`
if [ "$CHKDATE" -le "2014" ];then
    echo "You have incorrect date set on your server!"
    echo `date`
    exit 1
fi

type mysql 2> /dev/null && MYSQLCHK="on" || MYSQLCHK="off"


# MySQL checker
if [ "$MYSQLCHK" = "on" ]; then
	#check pwd if works
	while [ "$check" != "Database" ]
	do
		echo "Enter MySQL root Password: "
		read -p "MySQL root password []:" password
		check=`mysql -u root -p$password -e "show databases;" -B|head -n1`
		if [ "$check" = "Database" ]; then
			echo "Password OK!!"
		else
			echo "MySQL root passwordis invalid!!!"
			echo "You can remove MySQL server using command: yum remove mysql"
			echo "after mysql is removed run installer again."
			echo ""
			echo "if exists you can check your mysql password in file: /root/.my.cnf"
			echo ""
			if [ -e "/root/.my.cnf" ]; then
				echo ""
				cat /root/.my.cnf
				echo ""
			fi
		fi
	done
	
	
else
	password=$(</dev/urandom tr -dc A-Za-z0-9 | head -c12)
fi


service httpd stop 
service mysql stop 

yum -y update ca-certificates
yum -y install wget chkconfig epel-release
yum -y erase apr httpd

#Fix epel ssl issue 
sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo

# Check if version el5
centosversion=`rpm -qa \*-release | grep -Ei "oracle|redhat|centos|cloudlinux" | cut -d"-" -f3`

if [ $centosversion -eq "5" ]; then
echo 
echo "#######################################"
echo "# el5 version detected"
echo "#######################################"
echo
echo
echo "We recommend you to use CentOS 6 servers for full functionality!"
echo "Press ENTER to continue with CentOS 5 installation"
read CENTOS5CONFIRM
fi

if [ $centosversion -eq "7" ]; then
echo
echo "#######################################"
echo "# el7 version detected"
echo "#######################################"
echo
cd /usr/local/src
wget -q http://dl1.centos-webpanel.com/files/cwp-el7-latest
sh cwp-el7-latest
rm -f cwp-el7-latest
exit 0
fi

if [ $centosversion -eq "6" ]; then
echo 
echo "#######################################"
echo "# el6 version detected"
echo "#######################################"
echo
#Install SQL
if [ "$mariadb" = "x86" ];then
        # INSTALLING 32bit MARIADB
cat > /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos6-x86
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=0
EOF
else
    	# INSTALLING 64bit MARIADB
cat > /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=0
EOF
fi

yum install MariaDB-server MariaDB-client -y
chkconfig --levels 235 mysql on
sed -i "s|old_passwords=1|#old_passwords=1|" /etc/my.cnf

ln -s /etc/init.d/mysql	/etc/init.d/mysqld
service mysql start
mysqladmin -u root password $password
mysql -u root -p$password -e "DROP DATABASE test";
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User='root' AND Host!='localhost'";
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User=''";
mysql -u root -p$password -e "FLUSH PRIVILEGES";

# ADD SQL ROOT PASSWORD
cat > /root/.my.cnf <<EOF
[client]
password=$password
user=root
EOF

# SECURE SQL ROOT PASSWORD
chmod 600 /root/.my.cnf

# RESTART SQL TO ACCEPT THE NEW CHANGES
service mysqld restart

if [ ! -e "/var/lib/mysql" ];then
    echo "Installation FAILED at SQL !!!"
	echo "Please contact CWP support about this issue and include the last few lines from the error:"
	echo "http://centos-webpanel.com/contact"
    exit 1
fi
fi

if [ $centosversion -eq "7" ]; then
echo
echo "#######################################"
echo "# el7 version detected"
echo "#######################################"
echo
cd /usr/local/src
wget -q http://dl1.centos-webpanel.com/files/cwp-el7-latest
sh cwp-el7-latest
rm -f cwp-el7-latest
exit 0
fi

# Check /tmp
if [[ `cat /etc/fstab | grep -E 'tmp.*noexec'` != "" ]]; then mount -o remount,exec /tmp >/dev/null 2>&1 ; fi

#Umask Fix
sed -ie "s/umask\=002/umask=022/g" /etc/bashrc >/dev/null 2>&1

# Install CWP repo
cat > /etc/yum.repos.d/cwp.repo <<EOF
[cwp]
name=CentOS Web Panel repo for Linux 6 - \$basearch
baseurl=http://repo.centos-webpanel.com/repo/6/\$basearch
enabled=1
gpgcheck=0
priority=1
EOF

#Install dependecies
yum -y install apr apr-util bzip2-devel gcc libxml2-devel openssl-devel pcre-devel sqlite-devel curl curl-devel libc-client-devel libmcrypt-devel libxslt-devel libpng-devel automake autoconf gcc-c++ freetype-devel libjpeg-devel which sysstat
yum -y install make rsync at bzip2-devel zip git unzip cronie perl-libwww-perl bash-completion
yum -y install rsync cpulimit nano links bzip2-devel
#yum -y install postfix dovecot dovecot-mysql
yum -y install bind bind-utils bind-libs

pubip=`curl -s http://centos-webpanel.com/webpanel/main.php?app=showip`
#pubip=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`

fqdn=`/bin/hostname`
echo ""
echo "PREPARING THE SERVER"
echo "##########################"

if [ -e "/etc/selinux/config" ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0
fi

if [ -e "/etc/init.d/sendmail" ];then
	chkconfig --levels 235 sendmail off
	/etc/init.d/sendmail stop
fi
 
service iptables save
service iptables stop

## PACKAGE INSTALLER
#yum -y install make zip unzip git ld-linux.so.2 libbz2.so.1 libdb-4.7.so libgd.so.2 vsftpd

echo
echo "#############################################"
echo "Please wait... installing web server files..."
echo "#############################################"
echo

## APACHE INSTALLER ##
mkdir -p /usr/local/src
cd /usr/local/src

yum -y install apr apr-util cwp-httpd 2>&1 |tee /tmp/cwp.log
yum -y install cwp-suphp

if [ ! -e "/usr/local/apache/bin/httpd" ]
then
echo
echo "Compiler requires 512 MB RAM + SWAP"
echo "Installation FAILED at httpd"
echo "Installation FAILED at httpd" >> /tmp/cwp.log
curl http://dl1.centos-webpanel.com/files/s_scripts/sinfo.sh|sh 2>&1 >> /tmp/cwp.log
curl -F"operation=upload" -F"file=@/tmp/cwp.log" http://error-reporting.control-webpanel.com/?service=installer
echo "Please contact CWP support about this issue and include the last few lines from the error:"
echo "http://centos-webpanel.com/contact"
exit 1
fi

yum -y install cwp-php --enablerepo=epel 2>&1 |tee /tmp/cwp.log

if [ ! -e "/usr/local/bin/php" ]
then
echo
echo "Compiler requires 512 MB RAM + SWAP"
echo "Installation FAILED at php"
echo "Installation FAILED at php" >> /tmp/cwp.log
curl http://dl1.centos-webpanel.com/files/s_scripts/sinfo.sh|sh 2>&1 >> /tmp/cwp.log
curl -F"operation=upload" -F"file=@/tmp/cwp.log" http://error-reporting.control-webpanel.com/?service=installer
echo "Please contact CWP support about this issue and include the last few lines from the error:"
echo "http://centos-webpanel.com/contact"
exit 1
fi

if [ -e "/usr/local/bin/php-config" ]
then
CHKEXTENSIONTDIR=`/usr/local/bin/php-config --extension-dir`;grep ^extension_dir /usr/local/php/php.ini || echo "extension_dir='$CHKEXTENSIONTDIR'" >> /usr/local/php/php.ini
fi

yum -y install cwpsrv 

if [ ! -e "/usr/local/cwpsrv/bin/cwpsrv" ]
then
echo
echo "Compiler requires 512 MB RAM + SWAP"
echo "Installation FAILED at cwpsrv"
echo "Installation FAILED at cwpsrv" > /tmp/cwp.log
curl http://dl1.centos-webpanel.com/files/s_scripts/sinfo.sh|sh 2>&1 >> /tmp/cwp.log
curl -F"operation=upload" -F"file=@/tmp/cwp.log" http://error-reporting.control-webpanel.com/?service=installer
echo "Please contact CWP support about this issue and include the last few lines from the error:"
echo "http://centos-webpanel.com/contact"
exit 1
fi

yum -y install cwpphp --enablerepo=epel
if [ ! -e "/usr/local/cwp/php71/bin/php" ]
then
echo
echo "Compiler requires 512 MB RAM + SWAP"
echo "Installation FAILED at cwpphp"
echo "Installation FAILED at cwpphp" > /tmp/cwp.log
curl http://dl1.centos-webpanel.com/files/s_scripts/sinfo.sh|sh 2>&1 >> /tmp/cwp.log
curl -F"operation=upload" -F"file=@/tmp/cwp.log" http://error-reporting.control-webpanel.com/?service=installer
echo "Please contact CWP support about this issue and include the last few lines from the error:"
echo "http://centos-webpanel.com/contact"
exit 1
fi

# CONFIGURE APACHE
####################
touch /usr/local/apache/conf.d/vhosts.conf
sed -i "s|#Include conf/extra/httpd-userdir.conf|Include conf/extra/httpd-userdir.conf|" /usr/local/apache/conf/httpd.conf
sed -i "s|#LoadModule userdir_module modules.*$|LoadModule userdir_module modules/mod_userdir.so|" /usr/local/apache/conf/httpd.conf


# Apache Server Status 
cat > /usr/local/apache/conf.d/server-status.conf <<EOF
<Location /server-status>
    SetHandler server-status
    Order deny,allow
    Allow from localhost
</Location>
EOF


# Set PHP Config
sed -i "s|\;date\.timezone \=.*|date\.timezone = Etc/UTC|" /usr/local/php/php.ini

echo "127.0.0.1 "$fqdn >> /etc/hosts
chkconfig --levels 235 httpd on
service httpd restart

# Install CSF/LFD Firewall
echo "Installing CSF Firewall"
echo "#######################"
cd /tmp
rm -fv csf.tgz
wget http://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
sh install.sh
#sed -i "s|465,587,993,995|465,587,993,995,2030,2031,2082,2083,2086,2087,2095,2096|" /etc/csf/csf.conf
sed -i "s|80,110,113,443|80,110,113,443,2030,2031,2082,2083,2086,2087,2095,2096|" /etc/csf/csf.conf
sed -i 's|TESTING = "1"|TESTING = "0"|' /etc/csf/csf.conf
echo "# Run external commands before csf configures iptables" >> /usr/local/csf/bin/csfpre.sh
echo "# Run external commands after csf configures iptables" >> /usr/local/csf/bin/csfpost.sh
csf -x

cat >> /etc/csf/csf.pignore <<EOF
# CWP CUSTOM
exe:/usr/sbin/clamd
exe:/usr/sbin/opendkim
exe:/usr/libexec/mysqld
exe:/usr/sbin/mysqld
exe:/usr/bin/postgres
exe:/usr/bin/mongod
exe:/usr/libexec/dovecot/anvil
exe:/usr/libexec/dovecot/auth
exe:/usr/libexec/dovecot/imap-login
exe:/usr/libexec/dovecot/dict
exe:/usr/libexec/dovecot/pop3-login

exe:/usr/libexec/postfix/tlsmgr
exe:/usr/libexec/postfix/qmgr
exe:/usr/libexec/postfix/pickup
exe:/usr/libexec/postfix/smtpd
exe:/usr/libexec/postfix/smtp
exe:/usr/libexec/postfix/bounce
exe:/usr/libexec/postfix/scache
exe:/usr/libexec/postfix/anvil
exe:/usr/libexec/postfix/cleanup
exe:/usr/libexec/postfix/proxymap
exe:/usr/libexec/postfix/trivial-rewrite
exe:/usr/libexec/postfix/local
exe:/usr/libexec/postfix/pipe
exe:/usr/libexec/postfix/spawn

exe:/usr/sbin/varnishd
exe:/usr/sbin/nginx

exe:/usr/bin/perl
user:amavis
cmd:/usr/sbin/amavisd
user:netdata
EOF

touch /var/lib/csf/csf.tempban
touch /var/lib/csf/csf.tempallow

# CWP BruteForce Protection
sed -i "s|CUSTOM1_LOG.*|CUSTOM1_LOG = \"/var/log/cwp_client_login.log\"|g" /etc/csf/csf.conf
sed -i "s|^HTACCESS_LOG.*|HTACCESS_LOG = \"/usr/local/apache/logs/error_log\"|g" /etc/csf/csf.conf
sed -i "s|^MODSEC_LOG.*|MODSEC_LOG = \"/usr/local/apache/logs/error_log\"|g" /etc/csf/csf.conf
sed -i "s|^POP3D_LOG.*|POP3D_LOG = \"/var/log/dovecot-info.log\"|g" /etc/csf/csf.conf
sed -i "s|^IMAPD_LOG.*|IMAPD_LOG = \"/var/log/dovecot-info.log\"|g" /etc/csf/csf.conf
sed -i "s|^SMTPAUTH_LOG.*|SMTPAUTH_LOG = \"/var/log/maillog\"|g" /etc/csf/csf.conf

cat > /usr/local/csf/bin/regex.custom.pm <<EOF
#!/usr/bin/perl
sub custom_line {
        my \$line = shift;
        my \$lgfile = shift;
# Do not edit before this point
if ((\$globlogs{CUSTOM1_LOG}{\$lgfile}) and (\$line =~ /^\S+\s+\S+\s+(\S+)\s+Failed Login from:\s+(\S+) on: (\S+)/)) {
               return ("Failed CWP-Login login for User: \$1 from IP: \$2 URL: \$3",\$2,"cwplogin","5","2030,2031","1");
}
# Do not edit beyond this point
        return 0;
}
1;
EOF

#Dovecot bug fix
touch /var/log/dovecot-debug.log
touch /var/log/dovecot-info.log
touch /var/log/dovecot.log
chmod 600 /var/log/dovecot-debug.log
chmod 600 /var/log/dovecot-info.log
chmod 600 /var/log/dovecot.log
usermod -G mail dovecot

# WebPanel Install
echo "Installing CWP Files"
echo "#######################"
mkdir -p /usr/local/cwpsrv/htdocs
cd /usr/local/cwpsrv/htdocs

wget dl1.centos-webpanel.com/files/cwp/cwp2-0.9.8.879.zip
unzip -o cwp2-0.9.8.879.zip
rm -f cwp2-0.9.8.879.zip

if [ ! -e "/usr/local/cwpsrv/var/services" ];then
mkdir -p /usr/local/cwpsrv/var/services/
fi
cd /usr/local/cwpsrv/var/services/
wget dl1.centos-webpanel.com/files/cwp/el7/cwp-services.zip
unzip -o cwp-services.zip
rm -f cwp-services.zip

cd /usr/local/cwpsrv/htdocs/resources/admin/include
wget -q http://dl1.centos-webpanel.com/files/cwp/sql/db_conn.txt
mv db_conn.txt db_conn.php
cd /usr/local/cwpsrv/htdocs/resources/admin/modules
wget -q http://dl1.centos-webpanel.com/files/cwp/modules/example.txt
mv example.txt example.php


# phpMyAdmin Installer
echo "Installing phpMyAdmin"
echo "#######################"
cd /usr/local/cwpsrv/var/services
wget -q http://dl1.centos-webpanel.com/files/mysql/phpMyAdmin-4.7.9-all-languages.zip
unzip -o -q phpMyAdmin-4.7.9-all-languages.zip
mv phpMyAdmin-4.7.9-all-languages pma
rm -Rf phpMyAdmin-4.7.9-all-languages.zip pma/setup

# webFTP Installer
cd /usr/local/apache/htdocs/
wget -q dl1.centos-webpanel.com/files/cwp/addons/webftp_simple.zip
unzip -o webftp_simple.zip
rm -f webftp_simple.zip


# Default website setup
cp /usr/local/cwpsrv/htdocs/resources/admin/tpl/new_account_tpl/* /usr/local/apache/htdocs/.


# WebPanel Settings
mv /usr/local/cwpsrv/var/services/pma/config.sample.inc.php /usr/local/cwpsrv/var/services/pma/config.inc.php
ran_password=$(</dev/urandom tr -dc A-Za-z0-9 | head -c32)
sed -i "s|\['blowfish_secret'\] = ''|\['blowfish_secret'\] = '${ran_password}'|" /usr/local/cwpsrv/var/services/pma/config.inc.php
ran_password2=$(</dev/urandom tr -dc A-Za-z0-9 | head -c12)
sed -i "s|\$crypt_pwd = ''|\$crypt_pwd = '${ran_password2}'|" /usr/local/cwpsrv/htdocs/resources/admin/include/db_conn.php
sed -i "s|\$db_pass = ''|\$db_pass = '$password'|" /usr/local/cwpsrv/htdocs/resources/admin/include/db_conn.php
chmod 600 /usr/local/cwpsrv/htdocs/resources/admin/include/db_conn.php
chmod 777 /var/lib/php/session/

# PHP Short tags fix
sed -i "s|short_open_tag = Off|short_open_tag = On|" /usr/local/cwp/php71/php.ini
sed -i "s|short_open_tag = Off|short_open_tag = On|" /usr/local/php/php.ini

# Setup Cron
cat > /etc/cron.daily/cwp <<EOF
/usr/local/cwp/php71/bin/php -d max_execution_time=1000000 -q /usr/local/cwpsrv/htdocs/resources/admin/include/cron.php
/usr/local/cwp/php71/bin/php -d max_execution_time=1000000 -q /usr/local/cwpsrv/htdocs/resources/admin/include/cron_backup.php
EOF
chmod +x /etc/cron.daily/cwp

# SSL Crons
CRONDATE1=`date +%M\ %H -d '1 hour ago'`;echo "$CRONDATE1 * * * /usr/local/cwp/php71/bin/php -d max_execution_time=18000 -q /usr/local/cwpsrv/htdocs/resources/admin/include/cron_autossl_all_domains.php" >> /var/spool/cron/root
echo "0 0 * * * /usr/local/cwp/php71/bin/php -d max_execution_time=18000 -q /usr/local/cwpsrv/htdocs/resources/admin/include/alertandautorenewssl.php" >> /var/spool/cron/root

# MySQL Database import
curl 'http://dl1.centos-webpanel.com/files/cwp/sql/root_cwp.sql'|mysql -uroot -p$password
curl 'http://dl1.centos-webpanel.com/files/cwp/sql/oauthv2.sql'|mysql -uroot -p$password

mysql -u root -p$password << EOF
use root_cwp;
UPDATE settings SET shared_ip="$pubip";
EOF


# Disable named for antiDDoS security
chkconfig named on

# DNS Setup
if [ $centosversion -eq "5" ]; then
	ln -s /etc/named.rfc1912.zones /etc/named.conf
fi

# Google DNS
CHECKDNS=`dig a centos-webpanel.com @8.8.8.8 +short`
CHECKDNSERROR=$?
if [ $CHECKDNSERROR -eq 0 ];then
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
fi

sed -i "s|127.0.0.1|any|" /etc/named.conf
sed -i "s|localhost|any|" /etc/named.conf
sed -i 's/recursion yes/recursion no/g' /etc/named.conf

# MAIL SERVER INSTALLER

# clean yum
yum clean all


######## Replace and read from root foder
#if [ ! -e "/usr/local/cwpsrv/htdocs/mysql.txt" ]
#then
#echo "\"$password\"" > /etc/webpanel/mysql.txt
#fi

##########################################################
# MAIL SERVER
##########################################################


# check MySQL root password
mysql_root_password=$password
if [ -z "${mysql_root_password}" ]; then
  read -p "MySQL root password []:" mysql_root_password
fi

clear
echo "#########################################################"
echo "          CentOS Web Panel MailServer Installer          "
echo "#########################################################"
echo
echo "visit for help: www.centos-webpanel.com"
echo 

check=`mysql -u root -p$mysql_root_password -e "show databases;" -B|head -n1`
if [ "$check" = "Database" ]; then
    echo "Password OK!!"
else
	echo "MySQL root password is invalid!!!"
	echo "Check password and run this script again."
	exit 1

fi

## Needed to add password in root folder
mysql -u root -p$mysql_root_password -e "UPDATE mysql.user SET Password = PASSWORD('$mysql_root_password') WHERE user = 'root';"
mysql -u root -p$mysql_root_password -e "FLUSH PRIVILEGES;"

# password generator
postfix_pwd=$(</dev/urandom tr -dc A-Za-z0-9 | head -c12)
cnf_hostname=`/bin/hostname`

# create database and user
mysql -u root -p$mysql_root_password -e "CREATE DATABASE postfix;"
mysql -u root -p$mysql_root_password -e "CREATE USER postfix@localhost IDENTIFIED BY '$postfix_pwd';"
mysql -u root -p$mysql_root_password -e "GRANT ALL PRIVILEGES ON postfix . * TO postfix@localhost;" 

# MySQL Database import
curl 'http://centos-webpanel.com/webpanel/main.php?dl=postfix.sql'|mysql -uroot -p$mysql_root_password -h localhost postfix

yum -y remove sendmail exim
yum -y install postfix dovecot dovecot-mysql dovecot-pigeonhole cyrus-sasl-devel cyrus-sasl-sql subversion crontabs sysstat
yum -y install perl-MailTools perl-MIME-EncWords perl-MIME-Charset perl-Email-Valid perl-Test-Pod perl-TimeDate 
yum -y install perl-Mail-Sender perl-Log-Log4perl imapsync offlineimap
yum -y install perl-Razor-Agent perl-Convert-BinHex crypto-utils
yum -y install amavisd-new clamav clamd --disablerepo=rpmforge-webpanel

# Mail Server Config
sed -i "s|inet_interfaces = localhost|inet_interfaces = all|" /etc/postfix/main.cf
sed -i "s|mydestination = $myhostname, localhost.$mydomain, localhost|mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain, $domain|" /etc/postfix/main.cf
sed -i "s|#home_mailbox = Maildir/|home_mailbox = Maildir/|" /etc/postfix/main.cf

# GET MAIL configs
cd /
wget -q http://dl1.centos-webpanel.com/files/mail/mail_server2.zip
unzip -o /mail_server2.zip
rm -f /mail_server2.zip

#User add
mkdir /var/vmail
chmod 770 /var/vmail
useradd -r -u 101 -g mail -d /var/vmail -s /sbin/nologin -c "Virtual mailbox" vmail
chown vmail:mail /var/vmail 

touch /etc/postfix/virtual_regexp

#vacation
useradd -r -d /var/spool/vacation -s /sbin/nologin -c "Virtual vacation" vacation
mkdir /var/spool/vacation
chmod 770 /var/spool/vacation 
cd /var/spool/vacation/
#ln -s /etc/postfix/vacation.pl /var/spool/vacation/vacation.pl
ln -s /etc/postfix/vacation.php /var/spool/vacation/vacation.php
chmod +x /etc/postfix/vacation.php
usermod -G mail vacation
chown vacation /etc/postfix/vacation.php
chown postfix.mail /usr/local/cwpsrv/htdocs/resources/admin/include/postfix.php
chmod 440 /usr/local/cwpsrv/htdocs/resources/admin/include/postfix.php

echo "autoreply.$cnf_hostname vacation:" > /etc/postfix/transport
postmap /etc/postfix/transport
chown -R vacation:vacation /var/spool/vacation
echo "127.0.0.1 autoreply.$cnf_hostname" >> /etc/hosts

#sieve
mkdir -p /var/sieve/
cat > /var/sieve/globalfilter.sieve <<EOF
require "fileinto";
if exists "X-Spam-Flag" {
if header :contains "X-Spam-Flag" "NO" {
} else {
fileinto "Spam";
stop;
}
}
if header :contains "subject" ["***SPAM***"] {
fileinto "Spam";
stop;
}
EOF
chown -R vmail:mail /var/sieve


#razor-admin -register -user=some_user -pass=somepas
freshclam
service clamd restart

##### SSL Cert START #####
# SSL Self signed certificate
cd /root
DOMAIN="$cnf_hostname"
if [ -z "$DOMAIN" ]; then
echo "Hostname is not properly set!"
exit 11
fi
 
fail_if_error() {
[ $1 != 0 ] && {
unset PASSPHRASE
exit 10
}
}
 
# Generate a passphrase
export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)
 
# Certificate details; replace items in angle brackets with your own info
subj="
C=HR
ST=Zagreb
O=CentOS Web Panel
localityName=HR
commonName=$DOMAIN
organizationalUnitName=CentOS Web Panel
emailAddress=info@studio4host.com
"
 
# Generate the server private key
openssl genrsa -des3 -out $DOMAIN.key -passout env:PASSPHRASE 2048
fail_if_error $?
 
# Generate the CSR
openssl req \
-new \
-batch \
-subj "$(echo -n "$subj" | tr "\n" "/")" \
-key $DOMAIN.key \
-out $DOMAIN.csr \
-passin env:PASSPHRASE
fail_if_error $?
cp $DOMAIN.key $DOMAIN.key.org
fail_if_error $?
 
# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in $DOMAIN.key.org -out $DOMAIN.key -passin env:PASSPHRASE
fail_if_error $?
 
# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
fail_if_error $?

mv /root/$cnf_hostname.key /etc/pki/tls/private/hostname.key
mv /root/$cnf_hostname.crt /etc/pki/tls/certs/hostname.crt
cp /etc/pki/tls/certs/hostname.crt /etc/pki/tls/certs/hostname.bundle

ln -s /etc/pki/tls/private/hostname.key /etc/pki/tls/private/$cnf_hostname.key
ln -s /etc/pki/tls/certs/hostname.crt /etc/pki/tls/certs/$cnf_hostname.crt

##### END SSL Cert START #####

#FTPD configuration
if [ ! -e "/etc/pure-ftpd/pure-ftpd.conf" ]
then
yum -y install pure-ftpd --enablerepo=epel
touch /etc/pure-ftpd/pureftpd.passwd
pure-pw mkdb /etc/pure-ftpd/pureftpd.pdb -f /etc/pure-ftpd/pureftpd.passwd -m
fi

if [ ! -e "/etc/pure-ftpd/pure-ftpd.conf" ]
then
echo "Installation FAILED at pure-ftpd"
echo "Please contact CWP support about this issue and include the last few lines from the error:"
echo "http://centos-webpanel.com/contact"
exit 1
fi

sed -i 's|.*pureftpd.pdb.*|PureDB /etc/pure-ftpd/pureftpd.pdb|g' /etc/pure-ftpd/pure-ftpd.conf
sed -i 's|.*PAMAuthentication.*yes|PAMAuthentication    yes|g' /etc/pure-ftpd/pure-ftpd.conf
sed -i 's|.*UnixAuthentication.*yes|UnixAuthentication       yes|g' /etc/pure-ftpd/pure-ftpd.conf

# /etc/postfix/main.cf
sed -i "s|MY_HOSTNAME|$cnf_hostname|" /etc/postfix/main.cf
sed -i "s|MY_HOSTNAME|autoreply.$cnf_hostname|" /etc/postfix/mysql-virtual_vacation.cf
sed -i "s|MY_DOMAIN|$cnf_hostname|" /etc/postfix/main.cf

# MySQL PWD Fix for postfix
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/mysql-relay_domains_maps.cf
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/mysql-virtual_alias_maps.cf
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/mysql-virtual_alias_pipe_maps.cf   
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/mysql-virtual_alias_default_maps.cf
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/mysql-virtual_domains_maps.cf
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/mysql-virtual_mailbox_limit_maps.cf
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/mysql-virtual_mailbox_maps.cf
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/mysql-virtual_vacation.cf

# Postfix Web panel SQL setup
if [ ! -e "/usr/local/cwpsrv/htdocs/resources/admin/include/postfix.php" ]
then
cd /usr/local/cwpsrv/htdocs/resources/admin/include
wget -q http://centos-webpanel.com/webpanel/main.php?dl=postfix.txt
mv main.php?dl=postfix.txt postfix.php
fi
sed -i "s|\$db_pass_postfix = ''|\$db_pass_postfix = '$postfix_pwd'|" /usr/local/cwpsrv/htdocs/resources/admin/include/postfix.php
chmod 600 /usr/local/cwpsrv/htdocs/resources/admin/include/postfix.php

# Vacation fix
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/postfix/vacation.conf
sed -i "s|AUTO_REPLAY|autoreply.$cnf_hostname|" /etc/postfix/vacation.conf

# DOVECOT fix
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/dovecot/dovecot-dict-quota.conf
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|" /etc/dovecot/dovecot-mysql.conf
sed -i "s|MY_DOMAIN|$cnf_hostname|" /etc/dovecot/dovecot.conf
sed -i "s|MY_DOMAIN|$cnf_hostname|" /etc/dovecot/dovecot.conf


##### ROUNDCUBE INSTALLER #####
/usr/local/cwp/php71/bin/pear install Mail_mime
/usr/local/cwp/php71/bin/pear install Net_SMTP
/usr/local/cwp/php71/bin/pear install channel://pear.php.net/Net_IDNA2-0.1.1

#SIEVE REQUIREMENTS
# >=5.3.0, roundcube/plugin-installer: >=0.1.3, roundcube/net_sieve: "1.5.0
/usr/local/cwp/php71/bin/pear install Net_Sieve

if [ -z "${mysql_roundcube_password}" ]; then
  tmp=$(</dev/urandom tr -dc A-Za-z0-9 | head -c12)
  mysql_roundcube_password=${mysql_roundcube_password:-${tmp}}
  echo "MySQL roundcube: ${mysql_roundcube_password}" >> .passwords
fi

if [ -z "${mysql_root_password}" ]; then
  read -p "MySQL root password []:" mysql_root_password
fi

wget -P /usr/local/cwpsrv/var/services http://dl1.centos-webpanel.com/files/mail/roundcubemail-1.2.3.tar.gz
tar -C /usr/local/cwpsrv/var/services -zxvf /usr/local/cwpsrv/var/services/roundcubemail-*.tar.gz
rm -f /usr/local/cwpsrv/var/services/roundcubemail-*.tar.gz
mv /usr/local/cwpsrv/var/services/roundcubemail-* /usr/local/cwpsrv/var/services/roundcube
chown cwpsvc:cwpsvc -R /usr/local/cwpsrv/var/services/roundcube
chmod 777 -R /usr/local/cwpsrv/var/services/roundcube/temp/
chmod 777 -R /usr/local/cwpsrv/var/services/roundcube/logs/

sed -e "s|mypassword|${mysql_roundcube_password}|" <<'EOF' | mysql -u root -p"${mysql_root_password}"
USE mysql;
CREATE DATABASE IF NOT EXISTS roundcube;
GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost' IDENTIFIED BY 'mypassword';
FLUSH PRIVILEGES;
EOF

mysql -u root -p"${mysql_root_password}" 'roundcube' < /usr/local/cwpsrv/var/services/roundcube/SQL/mysql.initial.sql

cp /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php.sample /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php

sed -i "s|^\(\$config\['default_host'\] =\).*$|\1 \'localhost\';|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_server'\] =\).*$|\1 \'localhost\';|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_user'\] =\).*$|\1 \'%u\';|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_pass'\] =\).*$|\1 \'%p\';|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
#sed -i "s|^\(\$config\['support_url'\] =\).*$|\1 \'mailto:${E}\';|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['quota_zero_as_unlimited'\] =\).*$|\1 true;|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['preview_pane'\] =\).*$|\1 true;|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['read_when_deleted'\] =\).*$|\1 false;|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['check_all_folders'\] =\).*$|\1 true;|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['display_next'\] =\).*$|\1 true;|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['top_posting'\] =\).*$|\1 true;|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['sig_above'\] =\).*$|\1 true;|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['login_lc'\] =\).*$|\1 2;|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
sed -i "s|MYSQL_PASSWORD|$postfix_pwd|g" /usr/local/cwpsrv/var/services/roundcube/plugins/password/config.inc.php
sed -i "s|^\(\$config\['db_dsnw'\] =\).*$|\1 \'mysqli://roundcube:${mysql_roundcube_password}@localhost/roundcube\';|" /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
rm -rf /usr/local/cwpsrv/var/services/roundcube/installer
chown -R cwpsvc:cwpsvc /usr/local/cwpsrv/var/services/roundcube

# MAIL SECURITY
chmod 640 /etc/postfix/mysql-*.cf
chmod 640 /etc/dovecot/dovecot-*.conf
chmod 640 /usr/local/cwpsrv/var/services/roundcube/config/config.inc.php
chown root.mail /etc/postfix/mysql-*.cf
chown root.mail /etc/dovecot/dovecot-*.conf

# Opendkim
/usr/bin/yum --enablerepo=epel -y install opendkim libopendkim perl-Mail-DKIM perl-Mail-SPF pypolicyd-spf
/bin/cat > /etc/opendkim.conf << EOL
AutoRestart             Yes
AutoRestartRate         10/1h
LogWhy                  Yes
Syslog                  Yes
SyslogSuccess           Yes
Mode                    sv
Canonicalization        relaxed/simple
ExternalIgnoreList      refile:/etc/opendkim/TrustedHosts
InternalHosts           refile:/etc/opendkim/TrustedHosts
KeyTable                refile:/etc/opendkim/KeyTable
SigningTable            refile:/etc/opendkim/SigningTable
SignatureAlgorithm      rsa-sha256
Socket                  inet:8891@localhost
PidFile                 /var/run/opendkim/opendkim.pid
UMask                   022
UserID                  opendkim:opendkim
TemporaryDirectory	/var/tmp
EOL

# Setup Login Screen
[[ $(grep "bash_cwp" /root/.bash_profile) == "" ]] && echo "sh /root/.bash_cwp" >>  /root/.bash_profile

cat > /root/.bash_cwp <<EOF
echo ""
echo "********************************************"
echo "Welcome to CWP (CentOS WebPanel) server"
echo "Restart CWP using: service cwpsrv restart"
echo "********************************************"
echo ""
echo "CWP Wiki: http://wiki.centos-webpanel.com"
echo "CWP Forum: http://forum.centos-webpanel.com"
echo "CWP Support: http://centos-webpanel.com/support-services"
echo ""
w
echo ""
EOF

# FIX /etc/init.d links
yum -y remove httpd
cd /etc/init.d/
rm -f /etc/init.d/httpd
wget -q http://dl1.centos-webpanel.com/files/s_scripts/httpd
chmod +x /etc/init.d/httpd

if [ ! -e "/scripts" ]
then
	cd /;ln -s /usr/local/cwpsrv/htdocs/resources/scripts /scripts
	chmod +x /scripts/*
fi

# FIX QUOTA for first few users caused by UID & GID
sed -i 's/^UID_MIN.*/UID_MIN 700/' /etc/login.defs
sed -i 's/^GID_MIN.*/GID_MIN 700/' /etc/login.defs

# Email AutoResponder Fix
chmod +x /usr/sbin/sendmail.postfix

# NAT-ed networking setup detection
checklocal=`/sbin/ip addr sh | grep $pubip`

if [ -z "$checklocal" ];then
	mkdir -p /usr/local/cwp/.conf/
        touch /usr/local/cwp/.conf/nat_check.conf
fi

# Chkconfig
# iptables -F
chkconfig iptables off
chkconfig httpd on
chkconfig cwpsrv on
chkconfig mysqld on
chkconfig pure-ftpd on
chkconfig postfix on
chkconfig dovecot on

# Lets make php easier for usage
ln -s /usr/local/bin/php /bin/php
ln -s /usr/local/bin/php /usr/bin/php

# service restart
service httpd restart
service cwpsrvd restart

# Check /tmp
if [[ `cat /etc/fstab | grep -E 'tmp.*noexec'` != "" ]]; then mount -o remount /tmp >/dev/null 2>&1 ; fi

chown vmail.mail /var/log/dovecot*
mkdir /usr/local/apache/htdocs/.well-known
chown -R nobody:nobody /usr/local/apache/htdocs/*
chown -R cwpsvc.cwpsvc /usr/local/cwpsrv/var/services
/usr/bin/chattr +i /usr/local/cwpsrv/htdocs/admin

# All non standart ports are closed by default
iptables -A INPUT ! -i lo -p tcp -m state --state NEW -m tcp --dport 2030 -j ACCEPT
iptables -A INPUT ! -i lo -p tcp -m state --state NEW -m tcp --dport 2031 -j ACCEPT
service iptables save

# NAT-ed networking setup detection
checklocal=`/sbin/ip addr sh | grep $pubip`

if [ -z "$checklocal" ];then
        mkdir -p /usr/local/cwp/.conf/
        touch /usr/local/cwp/.conf/nat_check.conf
fi

# PHPFPM Installer
if [ ! -z "$phpfpm" ]; then
    CWPDLLINK="http://dl1.centos-webpanel.com/files/php/selector/"
    mkdir -p /usr/local/cwp/.conf/php-fpm_conf/

    if [ "$phpfpm" = "5.3" ];then
        wget -q ${CWPDLLINK}php53.conf -O /usr/local/cwp/.conf/php-fpm_conf/php53.conf
    elif [ "$phpfpm" = "5.4" ]; then
        wget -q ${CWPDLLINK}php54.conf -O /usr/local/cwp/.conf/php-fpm_conf/php54.conf
    elif [ "$phpfpm" = "5.5" ]; then
        wget -q ${CWPDLLINK}php55.conf -O /usr/local/cwp/.conf/php-fpm_conf/php55.conf
    elif [ "$phpfpm" = "5.6" ]; then
        wget -q ${CWPDLLINK}php56.conf -O /usr/local/cwp/.conf/php-fpm_conf/php56.conf
    elif [ "$phpfpm" = "7.0" ]; then
        wget -q ${CWPDLLINK}php70.conf -O /usr/local/cwp/.conf/php-fpm_conf/php70.conf
    elif [ "$phpfpm" = "7.1" ]; then
        wget -q ${CWPDLLINK}php71.conf -O /usr/local/cwp/.conf/php-fpm_conf/php71.conf
    elif [ "$phpfpm" = "7.2" ]; then
        wget -q ${CWPDLLINK}php72.conf -O /usr/local/cwp/.conf/php-fpm_conf/php72.conf
    fi

    wget -q ${CWPDLLINK}php-fpm-${phpfpm}.sh -O /usr/local/src/php-fpm-${phpfpm}.sh
    wget -q ${CWPDLLINK}php-build.sh -O /usr/local/src/php-build.sh
    sed -i "s|CONFIGURE_VERSIONS_TO_BUILD|sh /usr/local/src/php-fpm-${phpfpm}.sh;|g" /usr/local/src/php-build.sh
    sh /usr/local/src/php-build.sh 2>&1 |tee /var/log/php-selector-rebuild.log
fi

# Softaculous Installer
if [ "$softaculous" = "yes" ];then
    IONCUBELOADED=`/usr/local/cwp/php71/bin/php -v|grep ionCube`
    IONCUBECONF=`grep ioncube_loader /usr/local/cwp/php71/php.ini`
    SOFTACULOUSPWD=$(</dev/urandom tr -dc A-Za-z0-9 | head -c12)
    SOFTACULOUSAPI=`grep softaculous /usr/local/cwp/.conf/.api_keys`

    if [ -z "$IONCUBELOADED" ];then
        if [ -z "$IONCUBECONF" ];then
            echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.0.so" >> /usr/local/cwp/php71/php.ini
        fi
    fi

    if [ -z "$SOFTACULOUSAPI" ];then
        echo "softaculous:${SOFTACULOUSPWD}:1: " > /usr/local/cwp/.conf/.api_keys
    fi

    if [ ! -e "/usr/local/cwp/php" ];then
        ln -s /usr/local/cwp/php71/ /usr/local/cwp/php
    fi

    cd /usr/local/src;rm -f install.sh;wget -N http://files.softaculous.com/install.sh;chmod 755 install.sh;
    cd /usr/local/src/;sh /usr/local/src/install.sh --quick

    if [ -e "/usr/local/cwpsrv/conf.d/softaculous.conf" ];then
        rm -f /usr/local/cwpsrv/conf.d/softaculous.conf
    fi

    if [ -e "/usr/local/cwpsrv/conf/include/softaculous.conf" ];then
        rm -f /usr/local/cwpsrv/conf/include/softaculous.conf
    fi

    cd /usr/local/cwpsrv/conf/include; wget http://dl1.centos-webpanel.com/files/3rdparty/softaculous/el7/softaculous.conf
fi

if [ "$modsecurity" = "yes" ];then
    MODSECCONF="/usr/local/cwp/.conf/mod_security.conf"
    MODSECMAINCONF="/usr/local/apache/conf.d/mod_security.conf"
    RHELLIBDIR=`if [[ \`uname -m\` != "x86_64" ]]; then libdir=/usr/lib/ ; else libdir=/usr/lib64/ ; fi;echo $libdir`

    # Install dependencies
    yum -y install libxml2 libxml2-devel pcre-devel curl-devel expat-devel apr-devel apr-util-devel libuuid-devel gcc --enablerepo=cwp

    # Install Mod_Security for CWP
    cd /usr/local/src
    wget -q http://dl1.centos-webpanel.com/files/apache/modsecurity-2.9.1.tar.gz
    tar -xzf modsecurity-2.9.1.tar.gz
    cd /usr/local/src/modsecurity-2.9.1
    ./configure --with-apxs=/usr/local/apache/bin/apxs --with-apr=/usr/bin/apr-1-config --with-apu=/usr/bin/apu-1-config
    make clean
    make
    make install

    # Create CWP Conf file
    touch $MODSECCONF

    # Create Mod_Security Configuration
    if [ -e "/usr/local/apache/modules/mod_security2.so" ];then
        echo "modsecurityinstall = 1" >> $MODSECCONF

        cat > $MODSECMAINCONF <<EOF
LoadFile ${RHELLIBDIR}libxml2.so
LoadFile ${RHELLIBDIR}liblua-5.1.so

<IfModule !unique_id_module>
  LoadModule unique_id_module modules/mod_unique_id.so
</IfModule>

<IfModule !mod_security2.c>
  LoadModule security2_module  modules/mod_security2.so
</IfModule>

<IfModule mod_security2.c>
  <IfModule mod_ruid2.c>
    SecAuditLogStorageDir /usr/local/apache/logs/modsec_audit
    SecAuditLogType Concurrent
  </IfModule>
  <IfModule itk.c>
    SecAuditLogStorageDir /usr/local/apache/logs/modsec_audit
    SecAuditLogType Concurrent
  </IfModule>

  SecRuleEngine On
  SecAuditEngine RelevantOnly
  SecAuditLog /usr/local/apache/logs/modsec_audit.log
  SecDebugLog /usr/local/apache/logs/modsec_debug.log
  SecAuditLogType Serial
  SecDebugLogLevel 0
  SecRequestBodyAccess On
  SecDataDir /tmp
  SecTmpDir /tmp
  SecUploadDir /tmp
  SecCollectionTimeout 600
  SecPcreMatchLimit 1250000
  SecPcreMatchLimitRecursion 1250000
  Include "/usr/local/apache/modsecurity-cwaf/cwaf.conf"
</IfModule>
EOF

        # Install CWP Mod_Security Rules
        if [ -e "/usr/local/apache/" ];then
            cd /usr/local/apache/
            rm -Rf modsecurity-cwaf modsecurity-cwaf.zip
            wget -q http://dl1.centos-webpanel.com/files/apache/mod-security/modsecurity-cwaf.zip
            unzip modsecurity-cwaf.zip

            cd /usr/local/apache/modsecurity-cwaf/rules
            rm -f comodo_waf.zip
            wget -q http://dl1.centos-webpanel.com/files/apache/mod-security/comodo_waf.zip
            unzip -o comodo_waf.zip;rm -f comodo_waf.zip

            echo "modsecurityrules = 3" >> $MODSECCONF
            mkdir /usr/local/apache/logs/tmp;chown nobody.root /usr/local/apache/logs/tmp
        fi
    fi
fi

# Apache-only conf
if [ ! -e "/usr/local/cwp/.conf" ];then
	mkdir /usr/local/cwp/.conf
fi

cat > /usr/local/cwp/.conf/web_servers.conf <<EOF
{
    "webserver_setup": "apache-only",
    "apache-main": true,
    "php-cgi": true,
    "php-fpm": true,
    "apache_template-type-default": "default",
    "apache_template-name-default": "default"
}
EOF

# Secure home folder
chmod 711 /home

sh /scripts/restart_cwpsrv
service httpd restart
service postfix restart
service dovecot restart
service named restart

# Add cPanel AddHandler names
sh /scripts/cpanel_addhandlers

# Download and install all php selector versions from 5.3 - 7.3
#PHP Selector
echo
echo "Starting PHP Selector Fast Install"
cd /
wget static.cdn-cwp.com/files/php/full/el7/selector/php-selector.zip
unzip php-selector.zip
rm -f php-selector.zip

wget static.cdn-cwp.com/files/php/selector/el7/php-dependencies.sh -O /usr/local/src/php-dependencies.sh
sh /usr/local/src/php-dependencies.sh

yum -y install ImageMagick ImageMagick-devel ImageMagick-perl icu icu-devel libmcrypt libmcrypt-devel

rpm -e --nodeps libzip libzip-devel
yum -y install cmake cmake3 zlib-devel --enablerepo=epel

cd /usr/local/src
wget http://libzip.org/download/libzip-1.5.1.tar.gz
tar zxvf libzip*
cd libzip*
mkdir build
cd build
/usr/bin/cmake3 ..
make && make install
rm -Rf /usr/local/src/libzip*

if [ ! -e "/usr/local/ioncube/" ];then
    sh /scripts/update_ioncube
    # ioncube installer
    if [ -e "/usr/local/php/php.d/ioncube.ini" ]; then
        echo 'zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.3.so' > /opt/alt/php73/usr/php/php.d/ioncube.ini
    fi
fi

# Quota Setup
/usr/bin/yum -y install quota quota-devel
if [ -e "/usr/sbin/repquota" ];then

	if [[ `cat /etc/fstab | grep -i quota` != "" ]]; then
	    echo "Disk quota already configured in file /etc/fstab"
	else
		/bin/cp /etc/fstab /etc/fstab.backup

		if [[ `cat /etc/fstab | grep "home"` == "" ]]; then
			LN=`cat /etc/fstab | grep -n "\/\ " |cut -f1 -d:`
			MNT='/'
			mount -o remount,usrquota,grpquota $MNT
			MLINE=`cat /etc/mtab | grep "\/\ "`
			/bin/sed -ie "${LN}s|^.*$|$MLINE|" /etc/fstab
		else
			LN=`cat /etc/fstab | grep -n "home" |cut -f1 -d:`
			MNT='/home'
			mount -o remount,usrquota,grpquota $MNT
			MLINE=`cat /etc/mtab | grep "home"`
			/bin/sed -ie "${LN}s|^.*$|$MLINE|" /etc/fstab
		fi

		mount -o remount ${MNT} >/dev/null 2>&1

		if [[ $? -ne 0 ]]; then
			echo "You have an error with remount filesystem."
			echo "Try adding manualy usrquota,grpquota in your /etc/fstab on ${MNT}"

			if [ `cat /etc/mtab |grep -v cgroup |grep ' / ' | awk '{print $1}'` == '/dev/root' ]; then
				#geting correct device
				DEV=`mount|grep -v cgroup |grep ' / '|  awk '{print $1}'`
				# make the symlink
				ln -s $DEV /dev/root
			fi

			/bin/mv /etc/fstab /root/etc/fstab_
			/bin/mv /etc/fstab.backup /etc/fstab
			mount -o remount ${MNT}
		fi

		/sbin/quotacheck -cugm ${MNT}

		if [ ! -e "/usr/local/cwp/.conf" ];then
			mkdir -p /usr/local/cwp/.conf
		fi
		echo "${MNT}" > /usr/local/cwp/.conf/quota_part.conf

	fi

fi

# Install goaccess stats
yum -y install goaccess --enablerepo=epel
wget static.cdn-cwp.com/files/3rdparty/stats/goaccess/goaccess.conf -O /etc/goaccess.conf

# update cwp
chmod +x /scripts/cwp_api
sh /scripts/update_cwp
sh /scripts/cwp_set_memory_limit

clear
echo "#############################"
echo "#      CWP Installed        #"
echo "#############################"
echo ""
echo "Go to CentOS WebPanel Admin GUI at http://SERVER_IP:2030/"
echo ""
echo "http://${pubip}:2030"
echo "SSL: https://${pubip}:2031"
echo -e "---------------------"
echo "Username: root"
echo "Password: ssh server root password"
echo "MySQL root Password: $password"
echo 
echo "#########################################################"
echo "          CentOS Web Panel MailServer Installer          "
echo "#########################################################"
#echo "Roundcube MySQL Password: ${mysql_roundcube_password}"
#echo "Postfix MySQL Password: ${postfix_pwd}"
echo "SSL Cert name (hostname): ${cnf_hostname}"
echo "SSL Cert file location /etc/pki/tls/ private|certs"
echo "#########################################################"
echo
echo "Visit for help: www.centos-webpanel.com"
echo "Write down login details and press ENTER for server reboot!"

if [ "$restart" = "yes" ]; then
    echo "restarting server...."
    shutdown -r now
else
    echo "Please reboot the server!"
    echo "Reboot command: shutdown -r now"
fi
