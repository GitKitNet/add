#!/bin/bash


## =============================
## VARIABLE
function wait() { echo -en "\n\tНажмите любую клавишу для продолжения\n";read -s -n 1; }
function TIMER() {
  T="$1"; if [ -z "${T}" ]; then T="5"; fi;
  secs="$((1 * ${T}))"; while [ $secs -gt 0 ]; do
    echo -ne "\t $secs\033[0K\r"; sleep 1 && : $((secs--));
  done;
}
PHPV="7.0"

## =============================
## GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "Username (eg. mysitedatabase)?"
read USERNAME
echo "Updating OS................."
TIMER 3;
apt-get update



## =============================
## Installing Nginx
echo "Installing Nginx"
TIMER 3;
apt-get install nginx -y
apt-get install zip -y
apt install unzip -y
apt-get install pwgen -y

echo "Sit back and relax :) ......"
TIMER
cd /etc/nginx/sites-available/
wget -O "$DOMAIN" https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/wordpress/default
sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/


## Setting up Cloudflare FULL SSL
Cloudflare_FULL_SSL() {
echo "Setting up Cloudflare FULL SSL"
TIMER 3;
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
}; Cloudflare_FULL_SSL

cd /etc/nginx/
mv nginx.conf nginx.conf.backup
wget -O nginx.conf https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/wordpress/nginx.conf
mkdir -p /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"
wget -O robots.txt https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/wordpress/robots.txt
su -c 'echo "<?php phpinfo(); ?>" |tee info.php'
cd ~
wget wordpress.org/latest.zip
unzip latest.zip
mv wordpress/* /var/www/"$DOMAIN"/
rm -rf wordpress latest.zip




echo "Nginx server installation completed"
TIMER 3;
cd ~
chown www-data:www-data -R /var/www/"$DOMAIN"
systemctl restart nginx.service

echo "lets install php 7.0 and modules"
TIMER 3;

apt -y install php${PHPV} php${PHPV}-fpm php${PHPV}-mysqlnd
apt-get -y install php${PHPV}-cli php${PHPV}-common php${PHPV}-mysql \
  php${PHPV}-curl php${PHPV}-xml php${PHPV}-zip php${PHPV}-mbstring \
  php${PHPV}-readline php${PHPV}-imap php${PHPV}-gd php${PHPV}-recode \
  php${PHPV}-mcrypt php${PHPV}-bcmath php${PHPV}-opcache php${PHPV}-soap
apt-get -y install php-memcached php-imagick php-memcache \
  php-pear php-xdebug php-msgpack memcached imagick graphviz

PHPTWEAKS() {
echo "Some php.ini tweaks"
TIMER 3;
PHP_INI="/etc/php/${PHPV}/fpm/php.ini"
sed -i "s/post_max_size = .*/post_max_size = 2000M/" $PHP_INI
sed -i "s/memory_limit = .*/memory_limit = 3000M/" $PHP_INI
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1000M/" $PHP_INI
sed -i "s/max_execution_time = .*/max_execution_time = 18000/" $PHP_INI
sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" $PHP_INI
systemctl restart php${PHPV}-fpm.service
}


echo "Instaling MariaDB"
TIMER 3;
apt install mariadb-server mariadb-client -y
systemctl restart php${PHPV}-fpm.service


mysql_secure_installation
PASS=`pwgen -s 22 1`

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Here is the database"
echo "Database:   $USERNAME"
echo "Username:   $USERNAME"
echo "Password:   $PASS"

echo "Installation & configuration succesfully finished"
