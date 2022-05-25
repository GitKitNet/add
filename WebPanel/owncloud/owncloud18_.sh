#! /bin/bash

set -e
title="Install ownCloud on Ubuntu 18.04"

# wget https://raw.githubusercontent.com/numbnet/WebPanel/master/OwnCloud/owncloud18.sh && chmod +x ./owncloud20.sh && ./owncloud20.sh

# ================================
#   Variable
# ================================
OS="$( cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )"
release="$( cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )"


function myip() {
  ipE="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
  ipW="$(echo $(curl -s -4 icanhazip.com))";
  ipH=$(hostname -I|cut -f1 -d ' ');
## -------
  if [ "$ipE" == "$ipW" ]; then
    myip="$ipE";
  else
    if [ "$ipH" == "$ipW" ]; then
      myip="$ipH"
    else
      myip="$ipW"
    fi
  fi
  echo "${myip}"
}

function timer() {
  T="$1"
  if [ -z "${T}" ]; then
    T=5
  fi
  secs="$((1 * ${T}))"
  while [ $secs -gt 0 ]; do
    echo -ne " Wait: \t $secs\033[0K\r"
    sleep 1
    : $((secs--))
  done
}

function wait() {
  echo -e -n "Press [ANY] key to continue...";
  read -s -n 1;
}
function pause() {
  read -p "Press [Enter] key to continue..." fackEnterKey
}
function title() {
  clear
  echo -e "${title}";
  timer 10;
}

##-----------------------------
function OWNCLOUD_UBUNTU18() {
myip=$(hostname -I|cut -f1 -d ' ')
read -p "Domain Name (eg. example.com): " mydomain
echo "Start $(title)"
timer 10
# ================================
#   Preparation
# ================================
# ----------------------------
apt update && \
  apt upgrade -y
# ----------------------
FILE="/usr/local/bin/occ"
/bin/cat <<EOM >$FILE
#! /bin/bash

cd /var/www/owncloud
sudo -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM

# ----------------------
chmod +x /usr/local/bin/occ
Install the Required Packages
apt install -y \
  apache2 \
  libapache2-mod-php \
  mariadb-server \
  openssl \
  php-imagick php-common php-curl \
  php-gd php-imap php-intl \
  php-json php-mbstring php-mysql \
  php-ssh2 php-xml php-zip \
  php-apcu php-redis redis-server \
  wget

# ----------------------
apt install -y \
  ssh bzip2 sudo cron rsync curl jq \
  inetutils-ping smbclient php-libsmbclient \
  php-smbclient coreutils php-ldap

# ----------------------
#    Installation
# ---------------------- 

# ----------------------
Change the Document Root
sed -i "s#html#owncloud#" /etc/apache2/sites-available/000-default.conf

service apache2 restart

# ----------------------
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

# ----------------------
a2ensite owncloud.conf
service apache2 reload


# ============================
#  Passwords
# ============================
dbPASS="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 22 )"
dbNAME="owncloud"
dbUSER="owncloud"
adminUSER="admin"
adminPASS="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 12 )"
# ----------------------------
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${dbNAME}; \
GRANT ALL PRIVILEGES ON ${dbNAME}.* \
  TO ${dbUSER}@localhost \
  IDENTIFIED BY '${dbPASS}'";
# ----------------------
echo "Enabling Apache Modules"

a2enmod dir env headers mime rewrite setenvif
service apache2 reload

# ----------------------
cd /var/www/
wget https://download.owncloud.org/community/owncloud-10.8.0.tar.bz2 && \
tar -xjf owncloud-10.8.0.tar.bz2 && \
chown -R www-data. owncloud

timer 3
# ----------------------------
occ maintenance:install \
    --database "mysql" \
    --database-name "${dbNAME}" \
    --database-user "${dbUSER}" \
    --database-pass "${dbPASS}" \
    --admin-user "${adminUSER}" \
    --admin-pass "${adminPASS}"


occ config:system:get trusted_domains
occ config:system:set trusted_domains 1 --value="$myip"
occ config:system:set trusted_domains 2 --value="$mydomain"
occ config:system:get trusted_domains

# ----------------------
occ background:cron
echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
  > /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data
chmod 0600 /var/spool/cron/crontabs/www-data

# ----------------------
echo "*/15 * * * * /var/www/owncloud/occ user:sync 'OCA\User_LDAP\User_Proxy' -m disable -vvv >> /var/log/ldap-sync/user-sync.log 2>&1" > /var/spool/cron/crontabs/www-data
chown www-data.crontab  /var/spool/cron/crontabs/www-data
chmod 0600  /var/spool/cron/crontabs/www-data
mkdir -p /var/log/ldap-sync
touch /var/log/ldap-sync/user-sync.log
chown www-data. /var/log/ldap-sync/user-sync.log

# ----------------------
occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'

occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'

service redis-server start

occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json

# ----------------------
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
# ----------------------------
cd /var/www/
chown -R www-data. owncloud

# ----------------------------
touch "$HOME/.owncloud-profile.txt"
echo -en "
========   DATABASE  ========
- OwnCloud site: ${mydomain}
- DATABASE PASS: ${dbPASS}
- DATABASE USER: ${dbUSER}
- DATABASE NAME: ${dbNAME}
========     USER    ========
- Admin USER: ${adminUSER}
- Admin PASS: ${adminPASS}
=============================
" >> "$HOME/.owncloud-profile.txt"
# ----------------------------

echo -en "ownCloud is now installed."
echo -en "Use web browser to your ownCloud installation."
# ----------------------------
cat "$HOME/.owncloud-profile.txt"
pause

}


function Start() {
  clear
  read -r -p "Do you want start Install OwnCloud? [y/N] " response;
  case $response in 
    [yY][eE][sS]|[yY]) 
OS="$( cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )"
release="$( cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )"
if [[ "$OS" == 'ubuntu' ]] && [[ ${release:0:2} -lt '18' ]]; then
  OWNCLOUD_UBUNTU18
  echo "$OS${release:0:2}"
else
  echo "Not Ubuntu 18.04"
  echo "$OS${release:0:2}"
fi

 ;;
    *) echo -e "Cancel & Quite.." ;;
  esac
};
Start
