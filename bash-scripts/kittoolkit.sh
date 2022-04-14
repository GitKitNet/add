#!/bin/bash

# set +x

# LINK='https://raw.githubusercontent.com/GitKitNet/add/main/bash-scripts/kittoolkit.sh' && bash <(curl -L -fSs $LINK)
# read LINK && bash -c "$(curl -L -fSs $LINK)"
# read LINK && bash <(wget -O - $LINK)
# read LINK && bash -c "$(curl -fsSL $LINK || wget -O - $LINK)"


function sshkeygen() {

#  - - - - - - - - - - - - - - - - -
#            COLOR
#  - - - - - - - - - - - - - - - - -
GREEN="\033[32m";
RED="\033[1;31m";
BLUE="\033[1;34m";
YELOW="\033[1;33m";
PURPLE='\033[0;4;35m';
CYAN='\033[4;36m';
BLACK="\033[40m";
NC="\033[0m";

Black="`tput setaf 0`"
Red="`tput setaf 1`"
Green="`tput setaf 2`"
Yellow="`tput setaf 3`"
Blue="`tput setaf 4`"
Cyan="`tput setaf 5`"
Purple="`tput setaf 6`"
White="`tput setaf 7`"
 
BGBlack="`tput setab 0`"
BGRed="`tput setab 1`"
BGGreen="`tput setab 2`"
BGYellow="`tput setab 3`"
BGBlue="`tput setab 4`"
BGCyan="`tput setab 5`"
BGPurple="`tput setab 6`"
BGWhite="`tput setab 7`"

RC="`tput sgr0`"

TEXTCOLOR=$White;
BGCOLOR=$BLACK;

function C2() {
  for (( i = 0; i < 16; i++ )); do
    echo -e "`tput setaf $i`(C$i=\"\`tput setaf $i\`\"`tput sgr0`; `tput setab $i`(BC$i=\"\`tput setab $i\`\")`tput sgr0`";
done;
sleep 3
for (( i = 16; i < 256; i++ )); do
    echo -e "`tput setaf $i`(C$i=\"\`tput setaf $i\`\"`tput sgr0`; `tput setab $i`(BC$i=\"\`tput setab $i\`\")`tput sgr0`";
done;

}


#  - - - - - - - - - - - - - - - - -
#      VARIABLE & function
#  - - - - - - - - - - - - - - - - -

function THIS() {
 while true; do
  echo -e "${Yellow}Do you want Run $THIS script [y/N] .? ${RC}"
  read -e syn
  case $syn in
  [Yy]* ) break ;;
  [Nn]* ) echo -e "${RED}Cancel..${NC}"; exit 0 ;;
  esac
 done
}; 
THIS




#figlet -f smslant SSH Toolkit;
function showBanner()
{
  clear;
  echo -e "${BGBlack}
  ${BLUE}_______________${NC}${GREEN}________________________________${NC}
  ${BLUE}    __ ___ __  ${NC}${GREEN}  ______          ____    _ __  ${NC}
  ${BLUE}   / //_(_) /_ ${NC}${GREEN} /_  __/__  ___  / / /__ (_) /_ ${NC}
  ${BLUE}  / ,< / / __/ ${NC}${GREEN}  / / / _ \/ _ \/ /  '_// / __/ ${NC}
  ${BLUE} /_/|_/_/\__/  ${NC}${GREEN} /_/  \___/\___/_/_/\_\/_/\__/  ${NC}
  ${BLUE}_______________${NC}${GREEN}________________________________${NC}
  ";
}


function LoockUP() {
 while true; do
  read -e -p "Do you want Look UP SSH keys [y/N] .? " syn
  case $syn in
  [Yy]* ) clear;
   echo -en "\n${GREEN}=======================\n==    INFORMATION    ==\n=======================";
   echo -en "\n${GREEN}NAME:     ${NC}${Yellow}${kName}";
   echo -en "\n${GREEN}PUBLIC:   ${NC}${Yellow}" && cat "$HOME/.ssh/${kName}.pub"
   echo -en "\n${GREEN}PRIVAT:   ${NC}${YELLOW}" && cat "$HOME/.ssh/${kName}";
   echo -en "\n${GREEN}=======================${NC}\n";
   pause && break ;;

  [Nn]* ) echo -e "${RED}Cancel..${NC}" && break ;;
  esac
 done
}

function ConvertPPK()
{
OS="$( cat /etc/*release |grep '^ID=' | awk -F= '{print $2 }' )";

 while true; do
 read -e -p "Do you want PuTTy file ${kName}.ppk [y/N] ..? " syn
 case $syn in
  [Yy]* ) echo -en "\n${YELLOW}Install PuTTy and Converted to *.PPK ${NC}";
    if [[ "$OS" == arch ]]; then pacman -S putty;
      elif [[ "$OS" == centos ]] && [[ "$OS" == rhell ]]; then yum install putty -y;
      elif [[ "$OS" == fedora ]]; then dnf install putty -y;
      elif [[ "$OS" == ubuntu ]]; then apt-get install putty-tools -y;
    fi;
   if [[ -f "$HOME/.ssh/${kName}" ]]; then echo -en "\n${GREEN}SSH Key Exist\n ${NC}"; puttygen ${kName} -o ${kName}.ppk; else echo "SSH key Not Exist"; fi ;;
  [Nn]* ) echo -e "${RED}Cancel..${NC}"; break ;;
  esac;
 done
}


function title() { clear; echo "${title} ${TKEY}"; }
function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function wait() { read -p "Press [ANY] key to continue..? " -s -n 1; }
function TIMER() { if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; else T="5"; fi; SE="\033[0K\r"; E="$((1 * ${T}))"; while [ $E -gt 0 ]; do echo -en " Please wait: ${RED}$E$SE${NC}" && sleep 1 && : $((E--)); done; }
function AddON() { 
  while true; do read -e -p "Do you want RUN Agent? [y/N] ?" ryn; case $ryn in [Yy]* ) clear; eval $(ssh-agent) && ssh-add -D; break ;; [Nn]* ) break;; esac; done
  while true; do  read -e -p "Do you want add key to SSH Agent? [y/N]" ayn; case $ayn in [Yy]* ) local -r kName="$1"; ssh-add "$HOME/.ssh/$kName" ;; [Nn]* ) break;; esac; done
  while true; do read -e -p "Add to authorized_key? [y/N]" uyn; case $uyn in [Yy]* ) cat "$HOME/.ssh/${kName}.pub" >> "$HOME/.ssh/authorized_keys" ;; [Nn]* ) break;; esac; done;
}

function OnRUN() {
  title;
  read -e -p "Enter NAME ssh key: " IDK && ID="$( echo ${IDK} | sed 's/ /_/g' )";
  read -e -p "Add comment: " COMENT && COM="$( echo ${COMENT} | sed 's/ /./g' )";
  read -e -p "Enter password: " PASS;

  if [ -z "${ID}" ]; then ID="${hostname}_${USER}" && echo "${ID}"; else echo "${ID}"; fi
  if [ -z "${COM}" ]; then COM="${USER}"@"$( echo ${IDK} | sed 's/ /./g' )"; else echo "${COM}"; fi;

  kName="id_${TKEY}_$( echo ${ID} | sed 's/ /_/g' ).key";
  ssh-keygen -t ${TKEY} -f $HOME/.ssh/${kName} -C "${COM}" -N "$PASS";
  ConvertPPK ;
  LoockUP ;
}





function PMAdmin() {

    curl -s --connect-timeout 30 --retry 10 --retry-delay 5 -k -L "https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz" > pma.tar.gz
    mkdir -p /var/www/html/phpmyadmin
    tar xzf pma.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin
    rm pma.tar.gz
    cp /var/www/html/phpmyadmin/config{.sample,}.inc.php
    chmod 660 /var/www/html/phpmyadmin/config.inc.php
    sed -i "/blowfish_secret/s/''/'$(pwgen -s 32 1)'/" /var/www/html/phpmyadmin/config.inc.php
    chown -R www-data:www-data /var/www/html/phpmyadmin
    test -f /etc/nginx/conf.d/default.conf && rm -f /etc/nginx/conf.d/default.conf

    # Узнаём версию php
    fpmver=$(php -v | head -1 | cut -c5-7)
    cat > /etc/nginx/conf.d/phpmyadmin.conf << EOF
server {
  listen 80;
  listen [::]:80;
  server_name _;
  root /usr/share/nginx/html/;
  index index.php index.html index.htm index.nginx-debian.html;

  location / {
    try_files \$uri \$uri/ =404;
  }

  location ~ \.php$ {
    fastcgi_pass unix:/run/php/php$fpmver-fpm.sock;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
    include snippets/fastcgi-php.conf;
  }

  location /phpmyadmin {
    root /var/www/html/;
    index index.php index.html index.htm;
    location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
            root /var/www/html/;
    }
    location ~  ^/phpmyadmin/(.+\.php)$ {
            fastcgi_pass unix:/run/php/php$fpmver-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
            include snippets/fastcgi-php.conf;
    }
  }

  location ~ /\.ht {
      access_log off;
      log_not_found off;
      deny all;
  }
}
EOF
    systemctl restart nginx
}

#=====================================
function SQLwpLAND() {

echo "============================================
      Mysql Server Installation
============================================"

if [ ! -x /usr/bin/mysql ] ; then
apt install mysql-server -y && systemctl start mysql
fi

echo "============================================================
Please Enter root  password for authorization to mysql db
------------------------------------------------------------"

read -r -p "Do you want to generated automatically ? [y/N] If not it will provide password.  " rootpass
if [[ "$rootpass" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
 db_pass=$(date +%s|sha256sum|base64|head -c 30)
else
 echo "Enter DB ROOT PASSWORD: "
 read -e db_pass


mysql_secure_installation <<EOF
y
y
${db_pass}
${db_pass}
y
y
y
y
EOF
fi

echo -e "WordPress Install Script \n Please Enter Domain Name: "
read -e domain
authorization="mysql -uroot -p${db_pass}"
read -r -p "Do you want to generated automatically ? [y/N] If not it will provide password.  " answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
 dbPassword=$(date +%s|sha256sum|base64|head -c 25)
else
 echo -en "Enter DB USER PASSWORD: " && read -e dbPassword
fi

echo "Is everything ok, run install? [y/N]"

read -e run
if [ "$run" == n ] ; then
exit
else
echo "A robot is now installing WordPress for you"
#set +e
mkdir -p /var/www/$domain
cd /var/www/$domain
#Connect to mysql docker container and create database
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_")
Host=\'%\'

echo "--Reusing credentials----------------------"
$authorization -e "
CREATE USER 'root'@${Host} IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@${Host} WITH GRANT OPTION;
DROP USER 'root'@'localhost';"

$authorization -e "
DROP USER IF EXISTS ${dbNameandUser}@${Host};
DROP DATABASE IF EXISTS ${dbNameandUser};"

$authorization -e "
CREATE DATABASE ${dbNameandUser};
CREATE USER ${dbNameandUser}@${Host} IDENTIFIED BY '${dbPassword}';
GRANT ALL PRIVILEGES ON ${dbNameandUser}.* TO ${dbNameandUser}@${Host};
FLUSH PRIVILEGES;"
db_pass=${db_pass} >/dev/null 2>/dev/null
db_pass=${db_pass} > /tmp/${db_pass}
wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)

apt-get install curl -y || apk add curl \
&& curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x /tmp/wp-cli.phar \
&& mv /tmp/wp-cli.phar /usr/local/bin/wp \
&& wp core download --path=/var/www/${domain} --locale=en_US --allow-root \
&& wp config create --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check \
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=alina.m.giese@gmail.com --allow-root --path=/var/www/${domain}

###mkdir /var/www/$domain/wp-content/uploads
chmod 775 -R /var/www/$domain/ ###wp-content/uploads
chown www-data:www-data -R /var/www/$domain
echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}"

echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
-----------------------------------------------------------------------------" >> /tmp/credentials.txt
fi
}


#=============================================
function AddNewWP(){

echo "============================================
      WordPress Install Script
============================================
      Please Enter Domain Name:
--------------------------------------------"
read -e domain

read -r -p "Do you want Enter root DB pass automatically from cache ? [y/N] If not it will provide password." answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
  db_pass=${db_pass} < /dev/null 2>/dev/null
  db_pass=${db_pass} >/dev/null 2>/dev/null
else
  echo "Enter DB ROOT PASSWORD: "
  read -e db_pass
fi

authorization="mysql -uroot -p${db_pass}"
read -r -p "Do you want to generated automatically ? [y/N] If not it will provide password.  " answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
 dbPassword=$(date +%s|sha256sum|base64|head -c 25)
else
 echo "Enter DB_PASSWORD:"
 read -e dbPassword
fi

echo "Is everything ok, run install? [y/N]"

read -e run
if [ "$run" == n ] ; then
exit
else
echo "==============================================
  A robot is now installing WordPress for you.
=============================================="
#set +e
mkdir -p /var/www/$domain
cd /var/www/$domain
#Connect to mysql docker container and create database
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_")
Host=\'%\'

echo "--Reusing credentials----------------------"

$authorization -e "
DROP USER IF EXISTS ${dbNameandUser}@${Host};
DROP DATABASE IF EXISTS ${dbNameandUser};"

$authorization -e "
CREATE DATABASE ${dbNameandUser};
CREATE USER ${dbNameandUser}@${Host} IDENTIFIED BY '${dbPassword}';
GRANT ALL PRIVILEGES ON ${dbNameandUser}.* TO ${dbNameandUser}@${Host};
FLUSH PRIVILEGES;"
wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)

apt-get install curl -y || apk add curl \
&& curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x /tmp/wp-cli.phar \
&& mv /tmp/wp-cli.phar /usr/local/bin/wp \
&& wp core download --path=/var/www/${domain} --locale=en_US --allow-root \
&& wp config create --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check \
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=alina.m.giese@gmail.com --allow-root --path=/var/www/${domain}

###mkdir /var/www/$domain/wp-content/uploads
chmod 775 -R /var/www/$domain ###/wp-content/uploads
chown www-data:www-data -R /var/www/$domain
echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass: ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}"

echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass: ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
-----------------------------------------------------------------------------" >> /tmp/credentials.txt
fi
}



#=============================================
function Preinstall(){

#set -x
clear
echo -en "\n\n\tPlease Enter Domain Name: "; read -e domain;

apt update && apt upgrade -y
apt install -y mc htop curl git wget gnupg gnupg2 nginx
apt-get -y install software-properties-common
apt-get update
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get -y install php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline  php7.4-imap php7.4-mbstring php7.4-xml php7.4-xmlrpc php7.4-imagick php7.4-dev php7.4-opcache php7.4-soap php7.4-gd php7.4-zip php7.4-intl php7.4-curl
sed -i 's/;cgi.fix_pathinfo=0/ cgi.fix_pathinfo=1/g' /etc/php/7.4/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 300M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 300M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_input_time = 60/max_input_time = 600/g' /etc/php/7.4/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/fpm/php.ini

cat << 'eof' >> /etc/php/7.4/fpm/php-fpm.conf

pm = dynamic
 pm.max_children = 97
 pm.start_servers = 20
 pm.min_spare_servers = 10
 pm.max_spare_servers = 20
 pm.max_requests = 200

eof
sudo apt-get -y install certbot
apt install -y python-certbot-nginx || apt-get -y install python3-certbot-nginx

       # Проверка существования файла.
if [ ! -f "/etc/nginx/sites-available/$domain.conf" ]; then
  echo "Файл \"/etc/nginx/sites-available/$domain.conf\" не найден."
  touch /etc/nginx/sites-available/$domain.conf
fi

fpmver=$(php -v | head -1 | cut -c5-7)
cat << 'eof' >> /etc/nginx/sites-available/$domain.conf
### Configuration ###

server {
	listen 80;
	listen [::]:80;
	listen 443;
	listen [::]:443;
	server_name DMN www.DMN;
	root /var/www/DMN;
	index index.php index.html index.htm index.nginx-debian.html;

	location / {
		try_files $uri $uri/ /index.php$is_args$args;

		# allow 94.131.223.230;     # main
		# allow 185.16.228.210;     # mirror
		# allow 89.40.119.49;       # vpn
		# allow 94.177.247.152;     # vpn
		# allow 168.119.246.146;    # vpn
		# allow 159.69.210.127;     # control
		# allow 188.239.37.177;     # NN
		# deny all;                 # 
	}

	proxy_connect_timeout 3600;
	proxy_send_timeout 3600;
	proxy_read_timeout 3600;
	send_timeout 3600;
	client_max_body_size 100M;

	location ~ "^\/([a-z0-9]{{28,32}})\.html" {
		add_header Content-Type text/plain;
		return 200 $1;
	}

	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass unix:/var/run/php/php$fpmver-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param REMOTE_ADDR $remote_addr;
		fastcgi_param HTTP_X_FORWARDED_FOR $http_x_forwarded_for;
		fastcgi_param HTTP_X_REAL_IP $http_x_real_ip;
		fastcgi_param HTTP_CF_CONNECTING_IP $http_cf_connecting_ip;
		fastcgi_intercept_errors off;
		fastcgi_buffer_size 16k;
		fastcgi_buffers 4 16k;
		fastcgi_read_timeout 3600;
	}

	location ~* \.(jpg|jpeg|png|gif|ico|css|js|mp4|svg|woff|woff2|ttf)$ {
		expires 365d;
	}

	location ~* /(?:uploads|files)/.*.php$ {
		deny all;
	}

	location ~* /*.sql {
		deny all;
	}

	location ~* /.git/* {
		deny all;
	}
	location  ^~ /wp-cron.php {
		   allow 127.0.0.1;
	}

	location ~ /\.ht {
			deny all;
	}

	location = /xmlrpc.php {
		deny all;
	}

	location ~ /\. {
		deny all;
	}
}
eof




cd /etc/nginx/sites-enabled/
ln -s ../sites-available/$domain.conf

mkdir -p /var/www/$domain/
chown -R www-data:www-data /var/www/$domain/
cat << 'eof' >> /var/www/$domain/index.html
<!DOCTYPE html>
<html>
	<head>
		<title>Welcome to ${domain}!</title>
		<style>body {width: 35em; margin: 0 auto;font-family: Tahoma, Verdana, Arial, sans-serif;}</style>
	</head>
	<body style="background-color:white;">
		<h1 style="color:black;">Welcome to ${domain} </h1>
	</body>
</html>
eof

sed -i "s/DMN/$domain/g" /etc/nginx/sites-available/$domain.conf
sed -i "s/EXP/$domain/g" /var/www/$domain/index.html

sed -i "17a\\\treal_ip_header X-Forwarded-For;" /etc/nginx/nginx.conf
sed -i "18a\\\tset_real_ip_from 0.0.0.0/0;"  /etc/nginx/nginx.conf
nginx -s reload

# sed -i "4a\\\tserver_name ${domain} www.${domain};" /etc/nginx/sites-available/$domain.conf
# sed -i "5a\\\treturn 301 https://\$host\$request_uri;" /etc/nginx/sites-available/$domain.conf
# sed -i "6a\\\}" /etc/nginx/sites-available/$domain.conf
# sed -i "7a\\\server {" /etc/nginx/sites-available/$domain.conf
# sed -i "9c\\\tlisten 443 ssl;"  /etc/nginx/sites-available/$domain.conf
# sed -i "10c\\\tlisten [::]:443 ssl;" /etc/nginx/sites-available/$domain.conf
# sed -i "14i\\\tssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;" /etc/nginx/sites-available/$domain.conf
# sed -i "15i\\\tssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;" /etc/nginx/sites-available/$domain.conf
# sed -i "16i\\\tssl_protocols   TLSv1 TLSv1.1 TLSv1.2 SSLv3;" /etc/nginx/sites-available/$domain.conf
#
# certbot --nginx -d ${domain} -d www.${domain} -m brain.devops@gmail.com --non-interactive ###--agree-tos
# sleep 5
# nginx -s reload


#----------------------------------------
function PMAdmin() {
PWGEN=$(dpkg-query -W -f='${Status}' pwgen 2>/dev/null | grep -c "ok installed")
	if [ "$PWGEN" -eq 0 ]; then
		echo -e "${YELLOW}Installing pwgen${NC}" && apt-get install pwgen --yes;
	elif [ "$PWGEN" -eq 1 ]; then
		echo -e "${GREEN}pwgen	- is installed!${NC}";
	fi;



     curl -s --connect-timeout 30 --retry 10 --retry-delay 5 -k -L "https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz" > pma.tar.gz
    mkdir -p /var/www/html/phpmyadmin
    tar xzf pma.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin
    rm pma.tar.gz
    cp /var/www/html/phpmyadmin/config{.sample,}.inc.php
    chmod 660 /var/www/html/phpmyadmin/config.inc.php
    sed -i "/blowfish_secret/s/''/'$(pwgen -s 32 1)'/" /var/www/html/phpmyadmin/config.inc.php
    chown -R www-data:www-data /var/www/html/phpmyadmin
    test -f /etc/nginx/conf.d/default.conf && rm -f /etc/nginx/conf.d/default.conf

    # Узнаём версию php
    fpmver=$(php -v | head -1 | cut -c5-7)
    cat > /etc/nginx/conf.d/phpmyadmin.conf << EOF
server {
  listen 80;
  listen [::]:80;
  server_name _;
  root /usr/share/nginx/html/;
  index index.php index.html index.htm index.nginx-debian.html;

  location / {
    try_files \$uri \$uri/ =404;
  }

  location ~ \.php$ {
    fastcgi_pass unix:/run/php/php$fpmver-fpm.sock;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
    include snippets/fastcgi-php.conf;
  }

  location /phpmyadmin {
    root /var/www/html/;
    index index.php index.html index.htm;
    location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
            root /var/www/html/;
    }
    location ~  ^/phpmyadmin/(.+\.php)$ {
            fastcgi_pass unix:/run/php/php$fpmver-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
            include snippets/fastcgi-php.conf;
    }
  }

  location ~ /\.ht {
      access_log off;
      log_not_found off;
      deny all;
  }
}
EOF
    systemctl restart nginx
};
PMAdmin


	cd /root/
	touch dm && wget https://scr.devkong.work/addomain_into_file.py && chmod +x addomain_into_file.py

}






#==============================
#           MENU
#==============================

function BOSSMENU()
{
echo -e -n "\n\t${GREEN}${BGBlack}==== MAIN MENU ====${NC}\n"
echo -e -n "${Yellow}
\t1. Create SSH key ${NC} ${Purple}
\t2. LEMP
\t2. Select 3      ${RED}
\n\tq. Quit...       ${NC}";

}


#   subMENU 1
function SUBMENUONE()
{
M="= = = = =";
title="Generate SSH Key";
echo -e -n "\n\t${GREEN}${M} SSH KeyGen ${M}${NC}\n"
echo -e -n "
\t1. $title ${CYAN}ED25519${NC}
\t2. $title ${PURPLE}RSA${NC}
\t3. $title ${BLUE}DSA${NC}
\t4. $title ${GREEN}ECDSA${NC}
\t5. $title ${RED}EdDSA${RED} - [OFF]${NC}
${RED}\n\t0. Back ${NC}\n";
}

##   subMENU 2
function SUBMENUTWO() {
echo -e -n "\n\t ${GREEN}LEMP installation & Settings:${NC} \n"
echo -e -n "
\t1. Preinstall ${CYAN} Ngx Php7.4 Certbot ${STD}
\t2. Install MySQL ${CYAN}With WordPress land${STD}
\t3. Add one more WordPress land ${CYAN}With New DB-user DB-data WP-admin WP-pass${STD}
${RED}\n\t0. Back ${NC}\n";
} 

##   subMENU 3
function SUBMENUTHREE() {
  echo -e "\n\t ${GREEN}SubMENU 3 OPTIONS:${NC} \n"
  echo -e -n "
\t1. MENU 3 SubMenu 1
\t2. MENU 3 SubMenu 2
\t3. MENU 3 SubMenu 3
${RED}\n\t0. Back ${NC}\n";
} 

#--------------------------
while :
do
showBanner
BOSSMENU
echo -n -e "\n\tSelection: "
read -n1 opt
a=true;
case $opt in

# 1 ----------------------------
1) echo -e "==== Create SSH key ===="
while :
do
showBanner
SUBMENUONE
echo -n -e "\n\tSelection: "
read -n1 opt;
case $opt in
      1) TKEY="ed25519" && OnRUN ;;
      2) TKEY="rsa" && OnRUN ;;
      3) TKEY="dsa" && OnRUN ;;
      4) TKEY="ecdsa" && OnRUN ;;
      5) TKEY="eddsa" && OffRUN ;;
      /q | q | 0) echo -en "${RED}Quit..${NC}"; break ;;
      *) ;;
esac
done
;;

# 2 ----------------------------
2) echo -e "# submenu: MENU 2"
while :
do
showBanner
SUBMENUTWO
echo -n -e "\n\tSelection: "
read -n1 opt;
case $opt in
      1) Preinstall ;;
      2) SQLwpLAND ;;
      3) AddNewWP ;;
      /q | q | 0)break;;
      *) ;;
esac
done
;;


# 3 ----------------------------
3) echo -e "# submenu: MEMU 3"
while :
do
showBanner
SUBMENUTHREE
echo -n -e "\n\tSelection: "
read -n1 opt;
case $opt in
      1) echo -e "MENU 3 - SUBmenu 1" ;;
      2) echo -e "MENU 3 - SUBmenu 2" ;;
      3) echo -e "MENU 3 - SUBmenu 3" ;;
      /q | q | 0) break ;;
      *) ;;
esac
done
;;
      /q | q | 0) echo; break ;;
      *) ;;
esac
done
echo "Quit...";
clear;
}; 
sshkeygen

# exit 1
