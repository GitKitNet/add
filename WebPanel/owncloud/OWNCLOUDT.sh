#/bin/bash

# OWC="$HOME/owncloud.sh" && wget -O "${OWC}" 'https://raw.githubusercontent.com/numbnet/WebPanel/master/owncloud/OWNCLOUDT.sh' && chmod +x "${OWC}" && "${OWC}"

title="Install ownCloud on ${OS} ${release}"

function COLORS() {
## -------------------
## Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'        # No Color
}; COLORS

# ------------------------------
# VAR FUNCTION
OS="$( cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )"
release="$( cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )"

function wait() {
    echo -e -n "${GREEN} Press [ANY] key to continue... \n ${NC}"
read -s -n 1;
}

function pause() {
  read -p "Press [Enter] key to continue..." fackEnterKey;
}

function title() {
  clear; 
  echo -e "${GREEN} ${title} ${NC}"
  pause
}

function myip() {
  ipE="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
  ipW="$(echo $(curl -s -4 icanhazip.com))";
  ipH=$(hostname -I|cut -f1 -d ' ');
  if [ "$ipE" == "$ipW" ]; then
    myip="$ipE";
  else
    if [ "$ipH" == "$ipW" ]; then
      myip="$ipH";
    else
      myip="$ipW";
    fi
  fi
  echo "${myip}"
}

function TIMER() {
  T="$1"
  if [ -z "${T}" ]; then
    T="5"
  fi
  secs="$((1 * ${T}))"
  while [ $secs -gt 0 ]; do
    echo -ne "\t $secs\033[0K\r"
    sleep 1
    : $((secs—-))
  done
}


## ----------------------------------------
##      ownCloud в Ubuntu 20.04
## ----------------------------------------
OWNCLOUDT() {
function DATAREAD() {
    #echo -e "${GREEN}Adding user & database for owncloud${NC}"
    #echo -e "Please, set username for database: "
    #read DB_USER
    GEN_PASS=`pwgen -s 22 1`
    ADM_PASS="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 22 )"

    DB_USER="owncloud"
    DB_NAME="owncloud"
    DB_PASS="${GEN_PASS}"

    #echo -e "Please, set password for database user: "
    #read DB_PASS
   
    #echo -e "Please, set username for ADMIN: " && read ADMIN_NAME
    ADMIN_NAME="admin"
    # echo -e "Please, set password for ADMIN: " && read ADMIN_PASS
    ADMIN_PASS="${ADM_PASS}"
    
    #echo -en "Database NAME: ${DB_NAME}" >> /root/.acses
    #echo -en "Database password: ${DB_PASS}" >> /root/.acses
    #echo -en "Database user: ${DB_USER}" >> /root/.acses
    #echo -en "ADMIN NAME: ${ADMIN_NAME}" >> /root/.acses
    #echo -en "ADMIN Pass: ${ADM_PASS}" >> /root/.acses

    echo -en "
      ADMIN name: $ADMIN_NAME
      ADMIN password: $ADMIN_PASS
      
      Database Name: $DB_NAME
      Database user: $DB_USER
      Database pass: $DB_PASS
    
    " >> ~/.setupinfo.txt;
}
DATAREAD

# Подготовка
apt-get update -y && apt-get upgrade -y

# вспомогательный скрипт occ
FILE="/usr/local/bin/occ"
/bin/cat <<EOM >$FILE
#! /bin/bash

cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM

chmod +x /usr/local/bin/occ

# необходимые пакеты
apt install -y \
	wget apache2 libapache2-mod-php mariadb-server openssl php-imagick php-common php-curl php-mysql php-zip php-gd php-imap php-ssh2 php-xml php-intl php-json php-mbstring php-apcu php-redis redis-server

# рекомендуемые пакеты
apt install -y \
  ssh bzip2 rsync curl jq inetutils-ping coreutils



## ---------------------------------
## NOTE:
# php 7.4 - это версия по умолчанию, устанавливаемая с Ubuntu 20.04
## ---------------------------------


# Установка
## ---------------------------------

# Настроить Apache
# Изменить корень документа
sed -i "s#html#owncloud#" /etc/apache2/sites-available/000-default.conf
service apache2 restart

# Создать конфигурацию виртуального хоста
FILE="/etc/apache2/sites-available/owncloud.conf"
/bin/cat <<EOM >$FILE
Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
EOM

# Включите конфигурацию виртуального хоста
a2ensite owncloud.conf
service apache2 reload

# Настроить базу данных

## *******************************************
#mysql -u root -p <<EOF
#CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
#CREATE DATABASE IF NOT EXISTS $DB_NAME;
#GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
#ALTER DATABASE $DB_USER CHARACTER SET utf8 COLLATE utf8_general_ci;
#EOF
## *******************************************

mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; \
GRANT ALL PRIVILEGES ON $DB_NAME.* \
  TO owncloud@localhost \
  IDENTIFIED BY $DB_PASS";

# Включите рекомендуемые модули Apache
echo "Enabling Apache Modules"
a2enmod dir env headers mime rewrite setenvif
service apache2 reload

# Скачать ownCloud
cd /var/www/
wget https://download.owncloud.org/community/owncloud-10.8.0.tar.bz2 && \
    tar -xjf owncloud-10.8.0.tar.bz2 && \
    chown -R www-data. owncloud

# Установить ownCloud
occ maintenance:install \
    --database "mysql" \
    --database-name "$DB_NAME" \
    --database-user "$DB_USER" \
    --database-pass "$DB_PASS" \
    --admin-user "$ADMIN_NAME" \
    --admin-pass "$ADMIN_PASS"

# Настройка доверенных доменов ownCloud
# myip=$(hostname -I|cut -f1 -d ' ')
MyIP
occ config:system:set trusted_domains 1 --value="$(myip)"

# Настроить Cron Job, режим фоновой работы
occ background:cron
# 
echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
  > /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data
chmod 0600 /var/spool/cron/crontabs/www-data


## ---------------------------------
## NOTE 
# Если вам нужно синхронизировать пользователей с LDAP или Active Directory Server, добавьте это дополнительное задание Cron . Каждые 15 минут это задание cron будет синхронизировать пользователей LDAP в ownCloud и отключать тех, которые недоступны для ownCloud. Кроме того, вы получаете файл журнала /var/log/ldap-sync/user-sync.logдля отладки.
## ---------------------------------


echo "*/15 * * * * /var/www/owncloud/occ user:sync 'OCA\User_LDAP\User_Proxy' -m disable -vvv >> /var/log/ldap-sync/user-sync.log 2>&1" >> /var/spool/cron/crontabs/www-data
chown www-data.crontab  /var/spool/cron/crontabs/www-data
chmod 0600  /var/spool/cron/crontabs/www-data
mkdir -p /var/log/ldap-sync
touch /var/log/ldap-sync/user-sync.log
chown www-data. /var/log/ldap-sync/user-sync.log



# Настроить кеширование и блокировку файлов
occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'
occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'
occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json

# Настроить ротацию журналов
FILE="/etc/logrotate.d/owncloud"
sudo /bin/cat <<EOM >$FILE
/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
EOM

# Завершите установку
cd /var/www/
chown -R www-data. owncloud

echo "ownCloud установлен.Откройте в браузере установку ownCloud"

}




## ----------------------------------------
## OwnCloud START Installation
function STARTINSTALL() {
if [ "$OS" == 'ubuntu' ]; then
OWNCLOUDT
else
  echo -en "Not install OwnCloud.\n\n OS: ${OS}\n\n RELEASE: ${release}"
  echo -en "Run new installation script"
fi

}; STARTINSTALL

exit 1
