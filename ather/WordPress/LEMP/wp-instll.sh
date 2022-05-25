#!/bin/bash


## ====================================
# VARIABLE
NGINX_conf='https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/LEMP/nginx.conf'
NGINX_default='https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/LEMP/default'
ROBOTS_txt='https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/LEMP/robots.txt'
WP_latest='https://wordpress.org/latest.zip'
phpV="7.0"


## VAR function
TIMER() {
  sT=3
  secs=$((1 * ${sT}))
  while [ $secs -gt 0 ]; do
    echo -en "\tAfter: $secs\033[0K\r"
    sleep 1
    : $((secs--))
  done
};



# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "Username (eg. mysitedatabase)?"
read USERNAME
echo "Updating OS................."
TIMER
apt-get upgrade -y && \
   apt-get update -y

echo "Installing Nginx"
TIMER
apt-get install -y nginx \
    zip unzip pwgen



echo "Sit back and relax :) ......"
TIMER
cd /etc/nginx/sites-available/
# sudo wget -O "$DOMAIN" https://goo.gl/T3YBrn
wget -O "$DOMAIN" "$NGINX_default"


sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/

echo "Setting up Cloudflare FULL SSL"
TIMER
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
mv nginx.conf nginx.conf.backup

wget -O nginx.conf "$NGINX_conf"

mkdir -p /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"

wget -O robots.txt "$ROBOTS_txt"

sudo su -c 'echo "<?php phpinfo(); ?>" |tee info.php'
cd ~
wget "$WP_latest"
unzip latest.zip
mv wordpress/* /var/www/"$DOMAIN"/
rm -rf wordpress latest.zip

echo "Nginx server installation completed"
TIMER
cd ~
chown www-data:www-data -R /var/www/"$DOMAIN"
systemctl restart nginx.service

echo "lets install php ${phpV} and modules"
TIMER
apt install -y php${phpV} php${phpV}-fpm php${phpV}-mysqlnd
apt-get -y install \
  php${phpV}-common php${phpV}-mysql php${phpV}-cli php${phpV}-mbstring \
  php${phpV}-curl  php${phpV}-zip php${phpV}-xml php${phpV}-readline \
  php${phpV}-bcmath php${phpV}-opcache php${phpV}-gd php${phpV}-imap \
  php${phpV}-mcrypt php${phpV}-recode php${phpV}-soap\
  php-memcached php-imagick php-memcache \
  memcached graphviz php-pear php-xdebug php-msgpack

echo "Some php.ini tweaks"
TIMER
sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.0/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.0/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1000M/" /etc/php/7.0/fpm/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.0/fpm/php.ini
sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.0/fpm/php.ini
systemctl restart php${phpV}-fpm.service

echo "Instaling MariaDB"
TIMER
apt install -y mariadb-server mariadb-client
systemctl restart php${phpV}-fpm.service
mysql_secure_installation
PASS=`pwgen -s 14 1`

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

echo "Installation & configuration succesfully finished."

