#!/usr/bin/sh bash

#set +x
#set -Eeuo pipefail


# - - - - - - - - - - - - - - - - -
#            INF RUN from SSH
# - - - - - - - - - - - - - - - - -
LINK="raw.githubusercontent.com/GitKitNet/add/main/ToolKit/stk.sh";  #bash -c "$(curl -L -fSs ${LINK})"
#bash <(wget -O - ${LINK})
#bash -c "$(wget -O - ${LINK} || curl -fsSL ${LINK})";



# - - - - - - - - - - - - - - - - -
#            COLOR
# - - - - - - - - - - - - - - - - -
#BLACK='\033[1;40m';           # Black
#RED='\033[7;31m';             # Red
#GREEN='\033[7;32m';           # Green
#YELLOW='\033[1;33m';          # Yellow
#BLUE='\033[7;34m';            # Blue
#PURPLE='\033[1;35m';          # Purple
#CYAN='\033[4;36m';            # Cyan

BLACK='\033[0;40m';           # Black
RED='\033[0;31m'              # Red
GREEN='\033[0;32m'            # Green
YELLOW='\033[0;33m'           # Yellow
BLUE='\033[0;34m'             # Blue
PURPLE='\033[0;35m'           # Purple
CYAN='\033[0;36m'             # Cyan
NC='\033[0m'                  # No Color

Black="`tput setaf 0`"        # Black
Red="`tput setaf 1`"          # Red
Green="`tput setaf 2`"        # Green
Yellow="`tput setaf 3`"       # Yellow
Blue="`tput setaf 4`"         # Blue
Cyan="`tput setaf 5`"         # Cyan
Purple="`tput setaf 6`"       # Purple
White="`tput setaf 7`"        # White

BGBlack="`tput setab 0`"      # Black
BGRed="`tput setab 1`"        # Red
BGGreen="`tput setab 2`"      # Green
BGYellow="`tput setab 3`"     # Yellow
BGBlue="`tput setab 4`"       # Blue
BGCyan="`tput setab 5`"       # Cyan
BGPurple="`tput setab 6`"     # Purple
BGWhite="`tput setab 7`"      # White
RC="`tput sgr0`"              # Reset Color

FGCOLOR=$Red;
FGCOLOR_Bla=$Black;
FGCOLOR_Blu=$Blue;

BGCOLOR=$BGBlack;
BGCOLOR_Red=$BGRed;
BGCOLOR_Blu=$BGBlue;
BGCOLOR_Wh=$BGWhite;



# - - - - - - - - - - - - - - - - -
#figlet -f smslant S c Toolkit;

function showBANNER() {
 clear;
 echo -e "${BLUE}=================${GREEN}================================="
 echo -e "${BLUE}    ____ _____  ${GREEN}______            __ __    _  __  "
 echo -e "${BLUE}   / __// ___/ ${GREEN}/_  __/___  ___   / // /__ (_)/ /_ "
 echo -e "${BLUE}  _\ \ / /__  ${GREEN}  / /  / _ \/ _ \ / //  '_// // __/ "
 echo -e "${BLUE} /___/ \___/ ${GREEN}  /_/   \___/\___//_//_/\_\/_/ \__/  "
 echo -e "${BLUE}=============${GREEN}=====================================";
};


# - - - - - - - - - - - - - - - - - - - -
#       ASK START
# - - - - - - - - - - - - - - - - - - - -
function THIS() { 
	clear;
	while true; do 
	echo -en "\t${Yellow}Do you want Run This script [y/N] .?${RC} "; 
	read -e syn; 
	case $syn in 
		[Yy]* ) echo -e "\n\t${GREEN}Starting NOW..${NC}"; sleep 2 && break ;; 
		[Nn]* ) exit 0 ;;
	esac; 
	done;
	clear; 
};

# = = = = = = = = = = = = = = = = = = = =
#      VARIABLE & function
# = = = = = = = = = = = = = = = = = = = =

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
filename='ScToolkit.sh'
updpath='https://raw.githubusercontent.com/GitKitNet/add/main/ToolKit/' 

function CleanUP_() {
  trap - SIGINT SIGTERM ERR EXIT
  trap - SIGINT SIGTRAP SIGTERM ERR EXIT
  echo "Script CleanUP here..." && sleep 2;
};

function title() { clear; echo "${title} ${TKEY}"; }
function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function wait() { read -p "Press [ANY] key to continue..? " -s -n 1; }
function TIMER() {
  T="6";
  SE="\033[0K\r";
  E="$((1 * ${T}))";
  if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; fi;
  while [ $E -gt 0 ]; do
    echo -en " Please wait: ${RED}$E$SE${NC}";
    sleep 1;
    : $((E--));
  done;
}


# = = = = = = = = = = = = = = = = = = = =
#            UFW
# = = = = = = = = = = = = = = = = = = = =
function UFW() {
echo -e "\n${GREEN} = = = = = = = = = = \n\tCONFIGURING UFW\n = = = = = = = = = = ${NC} \n"
if [ ! -d /etc/ufw ]; then apt-get install ufw -y; fi;

CURRENT_SSH_PORT=$(grep "Port" /etc/ssh/sshd_config | awk -F " " '{print $2}')

ufw allow 22                    # default ssh port
if [ "$CURRENT_SSH_PORT" != "22" ]; then
  ufw allow "$CURRENT_SSH_PORT" && echo "UFW allow custom SSH port";
fi;

ufw logging low                  # define firewall rules
ufw default allow outgoing
ufw default deny incoming
ufw allow 53                     # dns
ufw allow http                   # nginx
ufw allow https                  # 
ufw allow 123                    # ntp   
ufw allow 68                     # dhcp client
ufw allow 546                    # dhcp ipv6 client
ufw allow 873                    # rsync
ufw allow 22222                  # easyengine backend

####   OPTIONAL FOR MONITORING   ####
#ufw allow 161                   # SNMP UDP port
#ufw allow 1999                  # Netdata web interface
#ufw allow 6556                  # Librenms linux agent
#ufw allow 10050                 # Zabbix-agent

};

# = = = = = = = = = = = = = = = = = = = =
function LookUP() {
  sleep 3 && clear;
  echo -en "\n${GREEN}============    INFORMATION    ============${NC}\n";
  if [[ -f "$HOME/.ssh/${kName}" ]]; then
    echo -en "\n${GREEN}NAME:     ${NC}${Yellow}${kName}";
    echo -en "\n${GREEN}PRIVAT:   ${NC}${YELLOW}" && cat "$HOME/.ssh/${kName}";
  fi;

  if [[ -f "$HOME/.ssh/${kName}.pub" ]]; then
    echo -en "\n${GREEN}PUBLIC:   ${NC}${Yellow}" && cat "$HOME/.ssh/${kName}.pub"
  fi;

  echo -en "\n${GREEN}=======================${NC}\n";
  pause;
  break;
}


# = = = = = = = = = = = = = = = = = = = =
function ConvertPPK() {
	#OS="$( cat /etc/*release |grep '^ID=' | awk -F= '{print $2 }' )";
	#OS=echo "$( cat /etc/*release |grep '^ID=' | awk -F= '{print $2 }' )";

	while true; do
	read -e -p "Do you want PuTTy file ${kName}.ppk [y/N] ..? " syn
	case $syn in
		[Yy]* ) echo -en "\n${YELLOW}Install PuTTy and Converted to *.PPK ${NC}";

	if [[ "$OS" == 'arch' ]]; then 
		pacman -S putty;
	elif [[ "$OS" == 'centos' ]] && [[ "$OS" == rhell ]]; then 
		yum install putty -y;
	elif [[ "$OS" == 'fedora' ]]; then 
		dnf install putty -y;
	elif [[ "$OS" == 'ubuntu' ]]; then 
		apt-get install putty-tools -y;
	fi;

	if [[ -f "$HOME/.ssh/${kName}" ]]; then
		echo -e "${GREEN}\n SSH Key Exist\n ${NC}";
		puttygen "$HOME/.ssh/${kName}" -o "$HOME/.ssh/${kName}.ppk";
	else
		echo "SSH key Not Exist"; 
	fi;

if [[ -f "$HOME/.ssh/${kName}.ppk" ]]; then 
	echo -en "\n${GREEN}SSH Key Convert for PuTTy \n${NC}"; 
elif [[ -z "$HOME/.ssh/${kName}.ppk" ]]; then 
	echo -en "NOT Converted to *.PPK ${NC}"; 
fi;

	;;
	[Nn]* ) break ;;
	esac;
	done;
}


# = = = = = = = = = = = = = = = = = = = =
function AddON() {
  while true; do
  read -e -p "Do you want RUN Agent? [y/N] ?" ryn;
  case $ryn in
	  [Yy]* ) clear; eval $(ssh-agent) && ssh-add -D; break ;;
	  [Nn]* ) break;;
  esac;
  done;

  while true; do
  read -e -p "Do you want add key to SSH Agent? [y/N]" ayn;
  case $ayn in
	  [Yy]* ) local -r kName="$1"; ssh-add "$HOME/.ssh/$kName" ;;
	  [Nn]* ) break;;
  esac;
  done;

  while true; do
  read -e -p "Add to authorized_key? [y/N]" uyn;
  case $uyn in
	  [Yy]* ) cat "$HOME/.ssh/${kName}.pub" >> "$HOME/.ssh/authorized_keys";;
	  [Nn]* ) break;;
  esac;
  done;

}

function OnRUN() {
	title;
	read -e -p "Enter NAME ssh key: " IDK && ID="$( echo ${IDK} | sed 's/ /_/g' )";
	read -e -p "Add comment: " COMENT && COM="$( echo ${COMENT} | sed 's/ /./g' )";
	read -e -p "Enter password: " PASS;
	sleep 2;
	if [ -z "${ID}" ]; then ID="${hostname}_${USER}"; fi
	if [ -z "${COM}" ]; then COM="${USER}"@"$( echo ${IDK} | sed 's/ /./g' )"; fi;

	kName="$( echo ${ID} | sed 's/ /_/g' )_${TKEY}";
	PriSSHkey="${kName}.pem";
	PubSSHkey="${kName}.pub";

	if [ "$MKEY" == "PEM" ]; then
			BKEY="4096"
			if [ -z "${ID}" ]; then ID="azureuser"; fi
			if [ -z "${COM}" ]; then COM="azureuser"@"$( echo ${IDK} | sed 's/ /./g' )"; fi;
		ssh-keygen -m ${MKEY} -t ${TKEY} -b ${BKEY} -f $HOME/.ssh/${kName} -C "${COM}" -N "$PASS";

	elif [ -z "${MKEY}" ]; then
		ssh-keygen -t ${TKEY} -f $HOME/.ssh/${kName} -C "${COM}" -N "$PASS";
	fi;


	LookUP ;
	ConvertPPK ;
}



#=============================================
#=============================================
function Inst_MySQLWP(){
echo "
============================================
      Mysql Server Installation
============================================
"

if [ ! -x /usr/bin/mysql ] ; then
        apt install mysql-server -y && systemctl start mysql
fi

echo "
============================================================
Please Enter root  password for authorization to mysql db
------------------------------------------------------------"

read -r -p "Do you want to generated automatically ? [y/N] If not it will provide password." rootpass
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
    fi;

    echo "
============================================
      WordPress Install Scripts
============================================
";
echo -en "Please Enter Domain Name: "
read -e domain
authorization="mysql -uroot -p${db_pass}"
read -r -p "Do you want to generated automatically? [y/N] If not it will provide password.  " answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
        dbPassword=$(date +%s|sha256sum|base64|head -c 25)
else
        echo "Enter DB USER PASSWORD:"
        read -e dbPassword
fi;

echo "Is everything ok, run install? [y/N]"
read -e run
if [ "$run" == n ]; then
  exit;
else
  echo "
==============================================
  A robot is now installing WordPress for you.
==============================================
";

#set +e
mkdir -p /var/www/${domain}
cd /var/www/${domain}

# Connect to mysql docker container and create database
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_")
Host=\'%\'

echo "ReUsing credentials----------------------"
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

apt-get install curl -y || apk add curl
curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /tmp/wp-cli.phar \
    && mv /tmp/wp-cli.phar /usr/local/bin/wp

if [ -f /usr/local/bin/wp ]; then
    read -p "WP is Existing.Press [Enter] key to continue..." fackEnterKey;
else
    read -p "WP NOT Existing. Press [Enter] key to continue..." fackEnterKey;
fi; 



wp core download \
    --path=/var/www/${domain} \
    --locale=en_US --allow-root
wp config create \
    --path=/var/www/${domain} \
    --dbname=${dbNameandUser} \
    --dbuser=${dbNameandUser} \
    --dbpass=${dbPassword} \
    --dbhost=localhost \
    --allow-root --skip-check
wp core install \
    --skip-email \
    --url=${domain} \
    --title=${domain} \
    --admin_user=${wp_admin} \
    --admin_password=${wp_pass} \
    --admin_email=admin@${domain} \
    --allow-root \
    --path=/var/www/${domain}

# Installing plugin:
wp plugin install \
    wp-sitemap-page
# Activating plugin:
wp plugin activate \
    wp-sitemap-page

###mkdir -p /var/www/${domain}/wp-content/uploads
chmod 775 -R /var/www/${domain}/ ###wp-content/uploads
chown www-data:www-data -R /var/www/${domain}
echo -e "
Cleaning... \n

-----------------------------------------------
         Installation is complete!
-----------------------------------------------


=================================================
  Credentials for Database And for Wp-admin
=================================================
INFO
DataBase Root Password:     ${db_pass}
DataBase Name:              ${dbNameandUser}
DataBase User:              ${dbNameandUser}
DataBase Pass:              ${dbPassword}
-----------------------------------------------
Admin Panel Link:           http://${domain}/wp-admin/
Admin Panel Admin:          ${wp_admin}
Admin Panel Password:       ${wp_pass}

Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
=================================================
"

echo "
=================================================
  Credentials for Database And for Wp-admin
=================================================

DataBase Root Password:     ${db_pass}
DataBase Name:              ${dbNameandUser}
DataBase User:              ${dbNameandUser}
DataBase Pass:              ${dbPassword}
-----------------------------------------------

Admin Panel Link:           http://${domain}/wp-admin/
Admin Panel Admin:          ${wp_admin}
Admin Panel Password:       ${wp_pass}

-----------------------------------------------
" >> /tmp/credentials.txt
fi;

}





#=============================================
#=============================================
function Add_WPiNUSER(){

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
mkdir -p /var/www/${domain}
cd /var/www/${domain}
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
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}

###mkdir -p /var/www/${domain}/wp-content/uploads
chmod 775 -R /var/www/${domain} ###/wp-content/uploads
chown www-data:www-data -R /var/www/${domain}
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
-----------------------------------------------------------------------------
" >> /tmp/credentials.txt
fi
}




#=============================================
#=============================================
function PreIns_NPhpCert(){

#set -x

echo "============================================
      Please Enter Domain Name:
============================================"
read -e domain

apt update && apt upgrade -y && apt install -y mc htop curl git wget gnupg gnupg2 nginx
apt-get -y install software-properties-common
apt-get update
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get -y install php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline  php7.4-imap php7.4-mbstring php7.4-xml php7.4-xmlrpc php7.4-imagick php7.4-dev php7.4-opcache php7.4-soap php7.4-gd php7.4-zip php7.4-intl php7.4-curl
sed -i 's/;cgi.fix_pathinfo=0/  cgi.fix_pathinfo=1/g' /etc/php/7.4/fpm/php.ini
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

cat << 'eof' >> /etc/nginx/sites-available/${domain}.conf
### Configuration ###
    server {
        listen 80;
        listen [::]:80;
        listen 443;
        listen [::]:443;
        server_name DMN www.DMN;
        root /var/www/DMN;
        index index.php index.html index.htm index.nginx-debian.html;

        proxy_connect_timeout 3600;
        proxy_send_timeout 3600;
        proxy_read_timeout 3600;
        send_timeout 3600;
        client_max_body_size 100M;

        location / {
            try_files $uri $uri/ /index.php$is_args$args;
                allow all;
                #allow 000.000.000.000;        #EXAMPLE NOT BLOCK
                #deny all;                     #Example BLOCK ALL
        }

            location ^~ /(wp-admin|wp-login\.php) {
            allow 65.108.153.183; #office
                deny all;
            }

        location ~ "^\/([a-z0-9]{{28,32}})\.html" {
            add_header Content-Type text/plain;
            return 200 $1;
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
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
ln -s ../sites-available/${domain}.conf

mkdir -p /var/www/${domain}/
chown -R www-data:www-data /var/www/${domain}/
cat << 'eof' >> /var/www/${domain}/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to EXP!</title>
<style>body {width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; }</style>
</head>
<body style="background-color:white;">
<h1 style="color:black;">Welcome to EXP!</h1>
</body>
</html>
eof

sed -i "s/DMN/${domain}/g" /etc/nginx/sites-available/${domain}.conf
sed -i "s/EXP/${domain}/g" /var/www/${domain}/index.html

sed -i "17a\\\treal_ip_header X-Forwarded-For;" /etc/nginx/nginx.conf
sed -i "18a\\\tset_real_ip_from 0.0.0.0/0;"  /etc/nginx/nginx.conf
nginx -s reload

# sed -i "4a\\\tserver_name ${domain} www.${domain};" /etc/nginx/sites-available/${domain}.conf
# sed -i "5a\\\treturn 301 https://\$host\$request_uri;" /etc/nginx/sites-available/${domain}.conf
# sed -i "6a\\\}" /etc/nginx/sites-available/${domain}.conf
# sed -i "7a\\\server {" /etc/nginx/sites-available/${domain}.conf
# sed -i "9c\\\tlisten 443 ssl;"  /etc/nginx/sites-available/${domain}.conf
# sed -i "10c\\\tlisten [::]:443 ssl;" /etc/nginx/sites-available/${domain}.conf
# sed -i "14i\\\tssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;" /etc/nginx/sites-available/${domain}.conf
# sed -i "15i\\\tssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;" /etc/nginx/sites-available/${domain}.conf
# sed -i "16i\\\tssl_protocols   TLSv1 TLSv1.1 TLSv1.2 SSLv3;" /etc/nginx/sites-available/${domain}.conf
#
# certbot --nginx -d ${domain} -d www.${domain} -m brain.devops@gmail.com --non-interactive ###--agree-tos
# sleep 5
# nginx -s reload
cd /root/
touch dm && wget https://scr.devkong.work/addomain_into_file.py && chmod +x addomain_into_file.py

}






#=============================================
#=============================================
function Inst_WPiCF(){
#set -x

echo "============================================
      Please Enter Domain Name:
============================================"
read -e domain

apt update && apt upgrade -y
apt install -y mc htop curl git wget gnupg gnupg2 nginx
apt-get -y install software-properties-common
apt-get update
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get -y install php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline  php7.4-imap php7.4-mbstring php7.4-xml php7.4-xmlrpc php7.4-imagick php7.4-dev php7.4-opcache php7.4-soap php7.4-gd php7.4-zip php7.4-intl php7.4-curl
sed -i 's/;cgi.fix_pathinfo=0/  cgi.fix_pathinfo=1/g' /etc/php/7.4/fpm/php.ini
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
cat << 'eof' >> /etc/nginx/sites-available/${domain}.conf
### Configuration ###
    server {
        listen 80;
        listen [::]:80;
        listen 443;
        listen [::]:443;
        server_name DMN www.DMN;
        root /var/www/DMN;
        index index.php index.html index.htm index.nginx-debian.html;

        proxy_connect_timeout 3600;
        proxy_send_timeout 3600;
        proxy_read_timeout 3600;
        send_timeout 3600;
        client_max_body_size 100M;

        error_page 403 404 /404.html;

        location = /404.html {
            internal; #return 404
        }

        location / {
            try_files $uri $uri/ /index.php$is_args$args;
                allow all;
                #allow 000.000.000.000;        #EXAMPLE NOT BLOCK
                #deny all;                     #Example BLOCK ALL
        }

        location ^~ /(wp-admin|wp-login\.php) {
                allow all;
                #allow 000.000.000.000;        #EXAMPLE NOT BLOCK
                #deny all;                     #Example BLOCK ALL
        }

        location ~ "^\/([a-z0-9]{{28,32}})\.html" {
            add_header Content-Type text/plain;
            return 200 $1;
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
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
ln -s ../sites-available/${domain}.conf

mkdir -p /var/www/${domain}/
chown -R www-data:www-data /var/www/${domain}/
cat << 'eof' >> /var/www/${domain}/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to EXP!</title>
<style>body {width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; }</style>
</head>
<body style="background-color:white;">
<h1 style="color:black;">Welcome to EXP!</h1>
</body>
</html>
eof

sed -i "s/DMN/${domain}/g" /etc/nginx/sites-available/${domain}.conf
sed -i "s/EXP/${domain}/g" /var/www/${domain}/index.html

sed -i "17a\\\treal_ip_header X-Forwarded-For;" /etc/nginx/nginx.conf
sed -i "18a\\\tset_real_ip_from 0.0.0.0/0;"  /etc/nginx/nginx.conf
nginx -s reload

cd /root/
touch dm
wget -O ./addomain_into_file.py https://scr.it.cx.ua/addomain_into_file.py && chmod +x ./addomain_into_file.py

echo "
============================================
      Mysql Server Installation
============================================
"

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
fi;


echo "============================================
      WordPress Install Script
============================================"

authorization="mysql -uroot -p${db_pass}"

dbPassword=$(date +%s|sha256sum|base64|head -c 25)

echo "==============================================
  A robot is now installing WordPress for you.
=============================================="

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
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}


chmod 775 -R /var/www/${domain}/
chown www-data:www-data -R /var/www/${domain}
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

}





#=============================================
#=============================================
function Inst_WPiCRT(){
#set -x

echo "============================================
      Please Enter Domain Name:
============================================"
read -e domain

apt update && apt upgrade -y;
apt install -y mc htop curl git wget gnupg gnupg2 nginx
apt-get -y install software-properties-common
apt-get update
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get -y install \
        php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common \
        php7.4-json php7.4-opcache php7.4-readline php7.4-imap php7.4-mbstring \
        php7.4-xml php7.4-xmlrpc php7.4-imagick php7.4-dev php7.4-opcache \
        php7.4-soap php7.4-gd php7.4-zip php7.4-intl php7.4-curl

sed -i 's/;cgi.fix_pathinfo=0/  cgi.fix_pathinfo=1/g' /etc/php/7.4/fpm/php.ini
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
cat << 'eof' >> /etc/nginx/sites-available/${domain}.conf
### Configuration ###
    server {
        listen 80;
        listen [::]:80;
        listen 443;
        listen [::]:443;
        server_name DMN www.DMN;
        root /var/www/DMN;
        index index.php index.html index.htm index.nginx-debian.html;

        proxy_connect_timeout 3600;
        proxy_send_timeout 3600;
        proxy_read_timeout 3600;
        send_timeout 3600;
        client_max_body_size 100M;

        error_page 403 404 /404.html;

        location = /404.html {
            internal; #return 404
        }

        location / {
            try_files $uri $uri/ /index.php$is_args$args;

                allow all;

            allow 000.000.000.000; #EXAMPLE NOT BLOCK
                #deny all;  #Example BLOCK ALL

        }

        location ^~ /(wp-admin|wp-login\.php) {
                allow all;

            allow 000.000.000.000; #EXAMPLE NOT BLOCK
                #deny all;  #Example BLOCK ALL

        }

        location ~ "^\/([a-z0-9]{{28,32}})\.html" {
            add_header Content-Type text/plain;
            return 200 $1;
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
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
ln -s ../sites-available/${domain}.conf

mkdir -p /var/www/${domain}/
chown -R www-data:www-data /var/www/${domain}/
cat << 'eof' >> /var/www/${domain}/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to ${domain} !</title>
<style>body {width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; }</style>
</head>
<body style="background-color:white;">
<h1 style="color:black;">Welcome to ${domain} !</h1>
</body>
</html>
eof

sed -i "s/DMN/${domain}/g" /etc/nginx/sites-available/${domain}.conf
sed -i "s/EXP/${domain}/g" /var/www/${domain}/index.html

sed -i "17a\\\treal_ip_header X-Forwarded-For;" /etc/nginx/nginx.conf
sed -i "18a\\\tset_real_ip_from 0.0.0.0/0;"  /etc/nginx/nginx.conf
nginx -s reload

sed -i "4a\\\tserver_name ${domain} www.${domain};" /etc/nginx/sites-available/${domain}.conf
sed -i "5a\\\treturn 301 https://\$host\$request_uri;" /etc/nginx/sites-available/${domain}.conf
sed -i "6a\\\}" /etc/nginx/sites-available/${domain}.conf
sed -i "7a\\\server {" /etc/nginx/sites-available/${domain}.conf
sed -i "9c\\\tlisten 443 ssl;"  /etc/nginx/sites-available/${domain}.conf
sed -i "10c\\\tlisten [::]:443 ssl;" /etc/nginx/sites-available/${domain}.conf
sed -i "14i\\\tssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;" /etc/nginx/sites-available/${domain}.conf
sed -i "15i\\\tssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;" /etc/nginx/sites-available/${domain}.conf
sed -i "16i\\\tssl_protocols   TLSv1 TLSv1.1 TLSv1.2 SSLv3;" /etc/nginx/sites-available/${domain}.conf

certbot --nginx -d ${domain} -d www.${domain} -m brain.devops@gmail.com --non-interactive ###--agree-tos
#sleep 5
nginx -s reload
cd /root/
touch dm
wget -O ./addomain_into_file.py https://scr.it.cx.ua/addomain_into_file.py && chmod +x ./addomain_into_file.py

echo -e "\n ==========    Mysql Server Installation    ==========\n"

if [ ! -x /usr/bin/mysql ] ; then
        apt install mysql-server -y && systemctl start mysql
fi;

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

echo "============================================
      WordPress Install Script
============================================"

authorization="mysql -uroot -p${db_pass}"

dbPassword=$(date +%s|sha256sum|base64|head -c 25)

echo "==============================================
  A robot is now installing WordPress for you.
=============================================="

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
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}


chmod 775 -R /var/www/${domain}/
chown www-data:www-data -R /var/www/${domain}
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
}




#=================================================

#-------------------------------------------------
function CheckPack() {

        #WELCOME MESSAGE
clear
echo -e "Welcome to WordPress & LAMP stack installation and configuration wizard!
First of all, we going to check all required packeges..."

        #CHECKING PACKAGES
echo -e "${YELLOW}Checking packages...${NC}"
echo -e "List of required packeges: nano, zip, unzip, mc, htop, fail2ban, apache2 & php, mysql, php curl, phpmyadmin, wget, curl"
read -r -p "Do you want to check packeges? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])

WGET=$(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed")
  if [ "$WGET" -eq 0 ]; then
    echo -e "${YELLOW}Installing wget${NC}" && apt-get install wget --yes;
  elif [ "$WGET" -eq 1 ]; then echo -e "${GREEN}wget is installed!${NC}";
  fi;

CURL=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
  if [ "$CURL" -eq 0 ]; then
    echo -e "${YELLOW}Installing curl${NC}" && apt-get install curl --yes;
  elif [ "$CURL" -eq 1 ]; then echo -e "${GREEN}curl is installed!${NC}";
  fi;

NANO=$(dpkg-query -W -f='${Status}' nano 2>/dev/null | grep -c "ok installed")
  if [ "$NANO" -eq 0 ]; then
    echo -e "${YELLOW}Installing nano${NC}" && apt-get install nano --yes;
  elif [ "$NANO" -eq 1 ]; then echo -e "${GREEN}nano is installed!${NC}";
  fi;

ZIP=$(dpkg-query -W -f='${Status}' zip 2>/dev/null | grep -c "ok installed")
  if [ "$ZIP" -eq 0 ]; then
    echo -e "${YELLOW}Installing zip${NC}" && apt-get install zip --yes;
  elif [ "$ZIP" -eq 1 ]; then echo -e "${GREEN}zip is installed!${NC}";
  fi;

MC=$(dpkg-query -W -f='${Status}' mc 2>/dev/null | grep -c "ok installed")
  if [ "$MC" -eq 0 ]; then
    echo -e "${YELLOW}Installing mc${NC}" && apt-get install mc --yes;
  elif [ "$MC" -eq 1 ]; then echo -e "${GREEN}mc is installed!${NC}";
  fi;

HTOP=$(dpkg-query -W -f='${Status}' htop 2>/dev/null | grep -c "ok installed")
  if [ "$HTOP" -eq 0 ]; then
    echo -e "${YELLOW}Installing htop${NC}" && apt-get install htop --yes;
  elif [ "$HTOP" -eq 1 ]; then echo -e "${GREEN}htop is installed!${NC}";
  fi;

FAIL2BAN=$(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed")
  if [ "$FAIL2BAN" -eq 0 ]; then
    echo -e "${YELLOW}Installing fail2ban${NC}" && apt-get install fail2ban --yes;
  elif [ "$FAIL2BAN" -eq 1 ]; then echo -e "${GREEN}fail2ban is installed!${NC}";
  fi;

APACHE2=$(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed")
  if [ "$APACHE2" -eq 0 ]; then
    echo -e "${YELLOW}Installing apache2${NC}" && apt-get install apache2 php5 --yes;
  elif [ "$APACHE2" -eq 1 ]; then echo -e "${GREEN}apache2 is installed!${NC}";
  fi;

MYSQLSERVER=$(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c "ok installed")
  if [ "$MYSQLSERVER" -eq 0 ]; then
    echo -e "${YELLOW}Installing mysql-server${NC}" && apt-get install mysql-server --yes;
  elif [ "$MYSQLSERVER" -eq 1 ]; then echo -e "${GREEN}mysql-server is installed!${NC}";
  fi;

PHP5CURL=$(dpkg-query -W -f='${Status}' php5-curl 2>/dev/null | grep -c "ok installed")
  if [ "$PHP5CURL" -eq 0 ]; then
    echo -e "${YELLOW}Installing php5-curl${NC}" && apt-get install php5-curl --yes;
  elif [ "$PHP5CURL" -eq 1 ]; then echo -e "${GREEN}php5-curl is installed!${NC}";
  fi;

PHPMYADMIN=$(dpkg-query -W -f='${Status}' phpmyadmin 2>/dev/null | grep -c "ok installed")
  if [ "$PHPMYADMIN" -eq 0 ]; then
    echo -e "${YELLOW}Installing phpmyadmin${NC}" && apt-get install phpmyadmin --yes;
  elif [ "$PHPMYADMIN" -eq 1 ]; then echo -e "${GREEN}phpmyadmin is installed!${NC}";
  fi ;;

    *) echo -e "\n\t ${RED}Packeges check is ignored! \n Please be aware, that apache2, mysql, phpmyadmin and other software may not be installed! ${NC}\n" ;;
        esac
};



#      PHPMYADMIN
#-------------------------------------------------
function ChangingPMA() {
    P_IP="`wget http://ipinfo.io/ip -qO -`"

        echo -e "${YELLOW}Changing phpMyAdmin default path from /phpMyAdmin to /phpmyadmin...${NC}"

sleep 5

# read -r -p "Do you want to change default phpMyAdmin path to /phpmyadmin? [y/N] " response
# case $response in
#     [yY][eE][sS]|[yY])

cat >/etc/phpmyadmin/apache.conf <<EOL
# phpMyAdmin default Apache configuration

Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options FollowSymLinks
    DirectoryIndex index.php

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_flag magic_quotes_gpc Off
        php_flag track_vars On
        php_flag register_globals Off
        php_admin_flag allow_url_fopen Off
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOL


        echo -e "\n ${GREEN}Succesfully! phpMyAdmin path is: ${P_IP}/phpmyadmin (i.e.: yourwebsite.com/phpmyadmin)${NC} \n "
    #;;
    #*) echo -e "${RED}Path was not changed!${NC}"
    #;;
   #esac
};




function creatingUser() {

#creating user

echo -e "${YELLOW}Adding separate user & creating website home folder for secure running of your website...${NC}"

  # echo -e "${YELLOW}Please, enter new username: ${NC}"
  # read username
  username="www-data";
  echo -e "${YELLOW}Enter Domain: ${NC}"
  read websitename


  groupadd $username
  adduser --home /var/www/${domain} --ingroup $username $username
  mkdir -p /var/www/${domain}
  chown -R $username:$username /var/www/${domain}
  echo -e "${GREEN}
  #-------------------------------------------------
  User, group and home folder were succesfully created!

  USERNAME:        $username
  GROUP:           $username
  HOME FOLDER:     /var/www/${domain}
  WEBSITE FOLDER:  /var/www/${domain}

  ${NC}"
}





function ConfApache2() {
#configuring apache2
#-------------------------------------------------
echo -e "${YELLOW}Now we going to configure apache2 for your domain name & website root folder...${NC}"

read -r -p "Do you want to configure Apache2 automatically? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])

  echo -e "Please, provide us with your domain name: "
  read domain_name
  echo -e "Please, provide us with your email: "
  read domain_email
  cat >/etc/apache2/sites-available/${domain}.conf <<EOL
  <VirtualHost *:80>
        ServerAdmin $domain_email
        ServerName ${domain}
        ServerAlias www.${domain}
        DocumentRoot /var/www/${domain}/
        <Directory />
                Options +FollowSymLinks
                AllowOverride All
        </Directory>
        <Directory /var/www/${domain}>
                Options -Indexes +FollowSymLinks +MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL
        a2dissite 000-default
    a2ensite ${domain}
    service apache2 restart
    P_IP="`wget http://ipinfo.io/ip -qO -`"

    echo -e "${GREEN}Apache2 config was updated!
    NEW CONFIG FILE:            /etc/apache2/sites-available/${domain}.conf
    DOMAIN WAS SET TO:          ${domain}
    ADMIN EMAIL WAS SET TO:     ${domain_email}
    ROOT FOLDER WAS SET TO:     /var/www/${domain}
    OPTION INDEXES WAS SET TO:  -Indexes (to close directory listing)
    YOUR SERVER PUBLIC IP IS:   $P_IP (Please, set this IP into your domain name 'A' record)
    Website was activated & apache2 service reloaded! ${NC}" \n ;;

    *) echo -e "${RED}WARNING! Apache2 was not configured properly, you can do this manually or re run our script.${NC}" ;;

        esac
}


#-----------------------------------------------------------
#  Downloading WordPress, unPacking,ADDing basic pack of plugins,
# creating .htaccess with optimal & secure configuration
#-----------------------------------------------------------
function InstallWordPress() {

echo "Root password for authorization to mysql DataBase generated automatically"
db_pass=$(date +%s|sha256sum|base64|head -c 30);
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

#---------------------------------
#   WordPress Install Script
#---------------------------------
echo "Please Enter Domain Name: ";
read -e domain
authorization="mysql -uroot -p${db_pass}"
dbPassword=$(date +%s|sha256sum|base64|head -c 25)
echo "A robot is now installing WordPress for you.";

#set +e
mkdir -p /var/www/${domain} && cd /var/www/${domain}
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

apt-get install curl -y || apk add curl
curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        && chmod +x /tmp/wp-cli.phar \
        && mv /tmp/wp-cli.phar /usr/local/bin/wp
wp core download \
   --path=/var/www/${domain} --locale=en_US --allow-root
wp config create \
    --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check
wp core install \
    --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}

echo -e "
Now we going to download some useful plugins:
1. Google XML Sitemap generator
2. Social Networks Auto Poster
3. Add to Any
4. Easy Watermark
";
sleep 7

# installing plugin:
wp plugin install \
    wp-sitemap-page add-to-any easy-watermark social-networks-auto-poster-facebook-twitter-g
# activating plugin:
wp plugin activate \
    wp-sitemap-page add-to-any easy-watermark social-networks-auto-poster-facebook-twitter-g


###mkdir -p /var/www/${domain}/wp-content/uploads
chmod 775 -R /var/www/${domain}/ ###wp-content/uploads
chown www-data:www-data -R /var/www/${domain}

# installing plugin:
wp plugin install woocommerce

# activating the plugin:
wp plugin activate woocommerce


echo -e "
Cleaning... \n

-----------------------------------------------
         Installation is complete!
-----------------------------------------------


=================================================
  Credentials for Database And for Wp-admin
=================================================
INFO
DataBase Root Password:     ${db_pass}
DataBase Name:              ${dbNameandUser}
DataBase User:              ${dbNameandUser}
DataBase Pass:              ${dbPassword}
-----------------------------------------------
Admin Panel Link:           http://${domain}/wp-admin/
Admin Panel Admin:          ${wp_admin}
Admin Panel Password:       ${wp_pass}

Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
=================================================
"

echo "
=================================================
  Credentials for Database And for Wp-admin
=================================================

DataBase Root Password:     ${db_pass}
DataBase Name:              ${dbNameandUser}
DataBase User:              ${dbNameandUser}
DataBase Pass:              ${dbPassword}
-----------------------------------------------

Admin Panel Link:           http://${domain}/wp-admin/
Admin Panel Admin:          ${wp_admin}
Admin Panel Password:       ${wp_pass}

-----------------------------------------------
" >> /tmp/credentials.txt


}



function downWP() {

echo -e "${YELLOW}Download LATEST VERSION of WordPress with EN or RUS language, set optimal & secure configuration and add basic set of plugins...${NC}"
read -r -p "Do you want to install WordPress & automatically set optimal and secure configuration with basic set of plugins? [y/N] " response

case $response in
    [yY][eE][sS]|[yY])
  echo -e "${GREEN}Please, choose WordPress language you need (set RUS or ENG): "
  read wordpress_lang

  if [ "$wordpress_lang" == 'RUS' ]; then
    wget https://ru.wordpress.org/latest-ru_RU.zip -O /tmp/$wordpress_lang.zip
  else
    wget https://wordpress.org/latest.zip -O /tmp/$wordpress_lang.zip
  fi;

  echo -e "Unpacking WordPress into website home directory..."
  sleep 5
  unzip /tmp/$wordpress_lang.zip -d /var/www/${domain}/
  mv /var/www/${domain}/wordpress/* /var/www/${domain}
  rm -rf /var/www/${domain}/wordpress
  rm /tmp/$wordpress_lang.zip
  mkdir -p /var/www/${domain}/wp-content/uploads && \
    chmod -R 777 /var/www/${domain}/wp-content/uploads



  echo -e "Now we going to download some useful plugins:
  1. Google XML Sitemap generator
  2. Social Networks Auto Poster
  3. Add to Any
  4. Easy Watermark"
  sleep 7

  #SITEMAP="`curl https://wordpress.org/plugins/google-sitemap-generator/ | grep https://downloads.wordpress.org/plugin/google-sitemap-generator.*.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  SITEMAP="`curl https://wordpress.org/plugins/wp-sitemap-page/ | grep https://downloads.wordpress.org/plugin/wp-sitemap-page.*.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $SITEMAP -O /tmp/sitemap.zip
  unzip /tmp/sitemap.zip -d /tmp/sitemap
  mv /tmp/sitemap/* /var/www/${domain}/wp-content/plugins/

  SNAP="`curl https://wordpress.org/plugins/social-networks-auto-poster-facebook-twitter-g/ | grep https://downloads.wordpress.org/plugin/social-networks-auto-poster-facebook-twitter-g.*.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $SNAP -O /tmp/snap.zip
  unzip /tmp/snap.zip -d /tmp/snap
  mv /tmp/snap/* /var/www/${domain}/wp-content/plugins/

  ADDTOANY="`curl https://wordpress.org/plugins/add-to-any/ | grep https://downloads.wordpress.org/plugin/add-to-any.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $ADDTOANY -O /tmp/addtoany.zip
  unzip /tmp/addtoany.zip -d /tmp/addtoany
  mv /tmp/addtoany/* /var/www/${domain}/wp-content/plugins/

        WATERMARK="`curl https://wordpress.org/plugins/easy-watermark/ | grep https://downloads.wordpress.org/plugin/easy-watermark.*.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^\"]*.zip\).*/\1/p'`"
        if [ -z "$WATERMARK" ]; then
                echo "is ERROR";
        else
                echo "$WATERMARK"
                wget $WATERMARK -O /tmp/watermark.zip
                unzip /tmp/watermark.zip -d /tmp/watermark
                mv /tmp/watermark/* /var/www/${domain}/wp-content/plugins/
        fi;

  rm /tmp/sitemap.zip /tmp/snap.zip /tmp/addtoany.zip /tmp/watermark.zip
  rm -rf /tmp/sitemap/ /tmp/snap/ /tmp/addtoany/ /tmp/watermark/

  echo -e "Downloading of plugins finished! All plugins were transfered into /wp-content/plugins directory.${NC}"

        ;;
    *)
  echo -e "${RED}WordPress and plugins were not downloaded & installed. You can do this manually or re run this script.${NC}"

        ;;
esac
}


#creating of swap
#-------------------------------------------------
function CreatSWAP() {

echo -e "On next step we going to create SWAP (it should be your RAM x2)..."
read -r -p "Do you need SWAP? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
  RAM="`free -m | grep Mem | awk '{print $2}'`"
  swap_allowed=$(($RAM * 2))
  swap=$swap_allowed"M"
  fallocate -l $swap /var/swap.img
  chmod 600 /var/swap.img
  mkswap /var/swap.img
  swapon /var/swap.img

  echo -e "
  ${GREEN}RAM detected: $RAM
  Swap was created: $swap${NC}"
  sleep 5
        ;;
    *)
  echo -e "${RED}You didn't create any swap for faster system working. You can do this manually or re run this script.${NC}"
        ;;
esac
}





function creSECURE() {

#creation of secure .htaccess
echo -e "${YELLOW}Creation of secure .htaccess file...${NC}"
sleep 3
cat >/var/www/${domain}/.htaccess <<EOL
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

RewriteCond %{query_string} concat.*\( [NC,OR]
RewriteCond %{query_string} union.*select.*\( [NC,OR]
RewriteCond %{query_string} union.*all.*select [NC]
RewriteRule ^(.*)$ index.php [F,L]

RewriteCond %{QUERY_STRING} base64_encode[^(]*\([^)]*\) [OR]
RewriteCond %{QUERY_STRING} (<|%3C)([^s]*s)+cript.*(>|%3E) [NC,OR]
</IfModule>

<Files .htaccess>
Order Allow,Deny
Deny from all
</Files>

<Files wp-config.php>
Order Allow,Deny
Deny from all
</Files>

<Files wp-config-sample.php>
Order Allow,Deny
Deny from all
</Files>

<Files readme.html>
Order Allow,Deny
Deny from all
</Files>

<Files xmlrpc.php>
Order allow,deny
Deny from all
</files>

# Gzip
<ifModule mod_deflate.c>
AddOutputFilterByType DEFLATE text/text text/html text/plain text/xml text/css application/x-javascript application/javascript text/javascript
</ifModule>

Options +FollowSymLinks -Indexes

EOL

chmod 644 /var/www/${domain}/.htaccess
echo -e "${GREEN}.htaccess file was succesfully created!${NC}"


#cration of robots.txt
echo -e "${YELLOW}Creation of robots.txt file...${NC}"
sleep 3
cat >/var/www/${domain}/robots.txt <<EOL
User-agent: *
Disallow: /cgi-bin
Disallow: /wp-admin/
Disallow: /wp-includes/
Disallow: /wp-content/
Disallow: /wp-content/plugins/
Disallow: /wp-content/themes/
Disallow: /trackback
Disallow: */trackback
Disallow: */*/trackback
Disallow: */*/feed/*/
Disallow: */feed
Disallow: /*?*
Disallow: /tag
Disallow: /?author=*
EOL

echo -e "${GREEN}File robots.txt was succesfully created!
Setting correct rights on user's home directory and 755 rights on robots.txt${NC}"
sleep 3
chmod 755 /var/www/${domain}/robots.txt
echo -e "${GREEN}Configuring fail2ban...${NC}"
sleep 3
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf-old
cat >/etc/fail2ban/jail.conf <<EOL
[DEFAULT]

ignoreip = 127.0.0.1/8
ignorecommand =
bantime  = 1200
findtime = 1200
maxretry = 3
backend = auto
usedns = warn
destemail = $domain_email
sendername = Fail2Ban
sender = fail2ban@localhost
banaction = iptables-multiport
mta = sendmail

# Default protocol
protocol = tcp
# Specify chain where jumps would need to be added in iptables-* actions
chain = INPUT
# ban & send an e-mail with whois report to the destemail.
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
              %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s", sendername="%(sendername)s"]
action = %(action_mw)s

[ssh]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5

[ssh-ddos]
enabled  = true
port     = ssh
filter   = sshd-ddos
logpath  = /var/log/auth.log
maxretry = 5

[apache-overflows]
enabled  = true
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 5
EOL

service fail2ban restart
echo -e "${GREEN}
fail2ban configuration finished!
fail2ban service was restarted, default confige backuped at /etc/fail2ban/jail.conf-old
Jails were set for: ssh bruteforce, ssh ddos, apache overflows${NC}"
sleep 5
echo -e "${GREEN} Configuring apache2 prefork & worker modules...${NC}"
sleep 3
cat >/etc/apache2/mods-available/mpm_prefork.conf <<EOL
<IfModule mpm_prefork_module>
        StartServers                     1
        MinSpareServers           1
        MaxSpareServers          3
        MaxRequestWorkers         10
        MaxConnectionsPerChild   3000
</IfModule>
EOL

cat > /etc/apache2/mods-available/mpm_worker.conf <<EOL
<IfModule mpm_worker_module>
        StartServers                     1
        MinSpareThreads          5
        MaxSpareThreads          15
        ThreadLimit                      25
        ThreadsPerChild          5
        MaxRequestWorkers         25
        MaxConnectionsPerChild   200
</IfModule>
EOL

a2dismod status
echo -e "${GREEN}Configuration of apache mods was succesfully finished!
Restarting Apache & MySQL services...${NC}"
service apache2 restart
service mysql restart
echo -e "${GREEN}Services succesfully restarted!${NC}"
sleep 3
}




function AddingDB() {
echo -e "${GREEN}Adding user & database for WordPress, setting wp-config.php...${NC}"
echo -e "Please, set username for database: "
read db_user
echo -e "Please, set password for database user: "
read db_pass

mysql -u root -p <<EOF
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';
CREATE DATABASE IF NOT EXISTS $db_user;
GRANT ALL PRIVILEGES ON $db_user.* TO '$db_user'@'localhost';
ALTER DATABASE $db_user CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF

cat >/var/www/${domain}/wp-config.php <<EOL
<?php

define('DB_NAME', '$db_user');

define('DB_USER', '$db_user');

define('DB_PASSWORD', '$db_pass');

define('DB_HOST', 'localhost');

define('DB_CHARSET', 'utf8');

define('DB_COLLATE', '');

define('AUTH_KEY',         '$db_user');
define('SECURE_AUTH_KEY',  '$db_user');
define('LOGGED_IN_KEY',    '$db_user');
define('NONCE_KEY',        '$db_user');
define('AUTH_SALT',        '$db_user');
define('SECURE_AUTH_SALT', '$db_user');
define('LOGGED_IN_SALT',   '$db_user');
define('NONCE_SALT',       '$db_user');

\$table_prefix  = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOL
        chown -R $username:$username /var/www/$username
        echo -e "${GREEN}Database user, database and wp-config.php were succesfully created & configured!${NC}"
        sleep 3
}

function installLAMP() {
  CheckPack;
  ChangingPMA;
  creatingUser;
  ConfApache2;
  InstallWordPress
  #downWP;
  CreatSWAP;
  creSECURE;
  AddingDB;
  echo -e "Installation & configuration succesfully finished.";
  sleep 3
}


#=================================
#         OwnCloud
#=================================
function OWNCLOUD() {

# ------------------------------
#         VAR FUNCTION
# ------------------------------

function wait() { echo -e -n "${YELLOW}Press [ANY] key to continue...${NC}\n"; read -s -n 1; }
function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function myip() {
  ipH=$(hostname -I|cut -f1 -d ' ');
  ipW="$(echo $(curl -s -4 icanhazip.com))";
  ipE="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
  if [ "$ipE" == "$ipW" ]; then myip="$ipE"; elif [ "$ipH" == "$ipW" ]; then  myip="$ipH"; else myip="$ipW"; fi; echo "${myip}";
}

myip=$(hostname -I|cut -f1 -d ' ')

#--------------------------------------
#      OwnCloud Ubuntu 18
#--------------------------------------
function OwnCloud_V18() {

# Preparation
# ----------------------
FILE="/usr/local/bin/occ"
/bin/cat <<EOM >$FILE
#! /bin/bash

cd /var/www/owncloud
sudo -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM


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

# Change the Document Root
sed -i "s#html#owncloud#" /etc/apache2/sites-available/000-default.conf

service apache2 restart

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

a2ensite owncloud.conf
service apache2 reload


#  Passwords
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
cd /var/www/
wget https://download.owncloud.org/community/owncloud-10.8.0.tar.bz2 && \
    tar -xjf owncloud-10.8.0.tar.bz2 && \
    chown -R www-data. owncloud
# ----------------------------
occ maintenance:install \
    --database "mysql" \
    --database-name "${dbNAME}" \
    --database-user "${dbUSER}" \
    --database-pass "${dbPASS}" \
    --admin-user "${adminUSER}" \
    --admin-pass "${adminPASS}"

#occ config:system:get trusted_domains
#occ config:system:set trusted_domains 1 --value="$myip"
occ config:system:set trusted_domains 2 --value="$mydomain"

# ----------------------
occ background:cron
echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
    > /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data && chmod 0600 /var/spool/cron/crontabs/www-data

# ----------------------
echo "*/15 * * * * /var/www/owncloud/occ user:sync 'OCA\User_LDAP\User_Proxy' -m disable -vvv >> /var/log/ldap-sync/user-sync.log 2>&1" > /var/spool/cron/crontabs/www-data
chown www-data.crontab  /var/spool/cron/crontabs/www-data && chmod 0600  /var/spool/cron/crontabs/www-data
mkdir -p /var/log/ldap-sync && touch /var/log/ldap-sync/user-sync.log && chown www-data. /var/log/ldap-sync/user-sync.log

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
read -p "Press [Enter] key to continue..." fackEnterKey;

}; 




#--------------------------------------
#      Owncloud Ubuntu 20
#--------------------------------------
function OwnCloud_V20() {
# ----------------------------
FILE="/usr/local/bin/occ"
/bin/cat <<EOM >$FILE
#! /bin/bash
cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM
chmod +x /usr/local/bin/occ
# ----------------------------
apt install -y \
  apache2 wget openssl \
  libapache2-mod-php \
  mariadb-server \
  php-imagick php-common php-curl php-gd php-imap php-intl \
  php-json php-mbstring php-mysql php-ssh2 php-xml php-zip \
  php-apcu php-redis redis-server \
  
# ----------------------------
apt install -y ssh bzip2 rsync curl jq inetutils-ping coreutils


# ============================
#    Installation
echo "Installation"
sleep 3
# ----------------------------
sed -i "s#html#owncloud#" /etc/apache2/sites-available/000-default.conf
service apache2 restart
# ----------------------------
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
# ----------------------------
echo "Enabling Apache Modules"
a2enmod dir env headers mime rewrite setenvif
service apache2 reload
# ----------------------------
cd /var/www/
wget https://download.owncloud.org/community/owncloud-10.8.0.tar.bz2 && \
tar -xjf owncloud-10.8.0.tar.bz2 && \
chown -R www-data. owncloud

# ================================
#    Install ownCloud
# ================================
echo "Installation OwnCloud"
sleep 3
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

# ================================
# sudo -u www-data php occ config:system:set trusted_domains 2 --value="$mydomain"
#sudo nano /etc/apache2/sites-available/000-default.conf

#ServerName cloud.example.com

#ServerAdmin webmaster@localhost
#DocumentRoot /var/www/owncloud/

#ErrorLog ${APACHE_LOG_DIR}/error.log
#CustomLog ${APACHE_LOG_DIR}/access.log combined
# ================================

# ----------------------------
occ background:cron
echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
  > /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data
chmod 0600 /var/spool/cron/crontabs/www-data
# ----------------------------
echo "
# ==================   NOTE   ================== #
- Если нужно синхронизировать пользователей с LDAP или 
  Active Directory Server добавьте это дополнительное задание Cron.
- Каждые 15 минут это задание cron будет синхронизировать пользов. 
  LDAP в ownCloud и откл. тех, которые недоступны для ownCloud. 
- Кроме того, получаете файл журнала отладки /var/log/ldap-sync/user-sync.log
# ================================================ #
"
# ----------------------------
echo "*/15 * * * * /var/www/owncloud/occ user:sync 'OCA\User_LDAP\User_Proxy' -m disable -vvv >> /var/log/ldap-sync/user-sync.log 2>&1" >> /var/spool/cron/crontabs/www-data
chown www-data.crontab  /var/spool/cron/crontabs/www-data
chmod 0600  /var/spool/cron/crontabs/www-data
mkdir -p /var/log/ldap-sync
touch /var/log/ldap-sync/user-sync.log
chown www-data. /var/log/ldap-sync/user-sync.log
# ----------------------------
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
# ----------------------------
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
  mkdir -p /var/www/owncloud && chown -R www-data. owncloud

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
    read -p "Press [Enter] key to continue..." fackEnterKey;

}


# OwnCloud START Installation
#----------------------------------------
echo "Start Install ownCloud "
read -p "Domain Name (eg. example.com): " mydomain
sleep 3
apt update && apt upgrade -y
sleep 3

  OS="$( cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )";
  release="$( cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )";
  
  if [[ "${OS}" == 'ubuntu' ]] && [[ "${release:0:2}" == 20 ]]; then
    echo "Install OwnCloud for Ubuntu 20"
    OwnCloud_V${release:0:2}
  elif [[ "${OS}" == 'ubuntu' ]] && [[ "${release:0:2}" == 18 ]]; then
    echo "Install OwnCloud for Ubuntu 18"
    OwnCloud_V${release:0:2}
  else
    echo -en "\n ${RED} Not install OwnCloud.\n\n OS: ${OS}\n\n RELEASE: ${release} \n Run new installation script ${NC}\n"
  fi;

}



# =============================
#      Pure-FTP
#==============================
function PUREFTP_RUN() {
	clear
	echo -e "\n\n${GREEN}Welcome to Pure-FTP Auto Installer Script${NC}\n\n"

	if [ "$(whoami)" != "root" ]; then
		echo -e "${RED}This script must be run as root${NC}"
		sleep 5
		exit
	fi

	# =============================
	#      PURE FTP Var & Func 
	# =============================

	function PUREFTP_AddNewUser() {
		read -p "Enter a Username: " -e ADDUSERNAME
		read -p "Enter $ADDUSERNAME’s password: " -e ADDPASSWORD
		#read -p "Enter $ADDUSERNAME’s directory: " -e -i /home/$ADDUSERNAME ADDUSERDIR
		ADDUSERDIR="/home/$ADDUSERNAME"
		read -p "Is this an http user? [y/n]: " -e HTTP
		echo -e "\n${GREEN}The User is creating now... Please wait.\n\n" && sleep 2;
		
		if [ "$HTTP" = "y" ]; then
			echo -e "$ADDPASSWORD\\n$ADDPASSWORD" | pure-pw useradd $ADDUSERNAME -u www-data -d $ADDUSERDIR
		else
			if [ "$HTTP" = "n" ]; then
				echo -e "$ADDPASSWORD\\n$ADDPASSWORD" | pure-pw useradd $ADDUSERNAME -u $ADDUSERNAME -d $ADDUSERDIR
			else
				echo "${YELOW}Please enter [y/n] ...${NC}"
			fi;
		fi;
		
		pure-pw mkdb
		if [ -e /etc/init.d/pure-ftpd ]; then
			/etc/init.d/pure-ftpd restart
		else
			echo "\n\n${RED}Pure-FTP is not working properly. Please remove and Re-install it.${NC}\n"
		fi;
	};

	function PUREFTP_ChangeUserPass() {
		read -p "Enter the username: " -e CHNUSERNAME
		read -p "Enter password: " -e CHNPASSWORD
		echo -e "$CHNPASSWORD\\n$CHNPASSWORD" | pure-pw passwd $CHNUSERNAME -m
		pure-pw mkdb
	}

	function PUREFTP_DelUser() {
		read -p "Enter the username: " -e DELUSERNAME
		read -p "Are you sure? [y/n]: " -e -i n TTT
		if [ "$TTT" = "y" ]; then
			pure-pw userdel $DELUSERNAME -m
			pure-pw mkdb
		else
			echo "Closing now.."
		fi
	}

	function PUREFTP_Remove() {
		read -p "Are you sure? [y/n]: " -e -i n TTTT
		if [ "$TTTT" = "y" ]; then
			apt-get remove —purge —yes pure-ftpd
			apt-get —yes autoremove
			if [ -e /etc/pure-ftpd ]; then rm -rf /etc/pure-ftpd; fi;
		else
			echo "Closing now.." && exit
		fi;
	}
	
	function PUREFTP_Install() {
		apt-get update -y && apt-get upgrade -y
		apt-get install pure-ftpd -y
		IP=$(curl ip.mtak.nl -4)
		cd /etc/pure-ftpd/conf
		touch ForcePassiveIP
		touch PassivePortRange
		echo -e "$IP" | tee -a /etc/pure-ftpd/conf/ForcePassiveIP
		echo -e "10110 10210" | tee -a /etc/pure-ftpd/conf/PassivePortRange
		perl -pi -e "s/1000/1/g" /etc/pure-ftpd/conf/MinUID
		perl -pi -e "s/yes/no/g" /etc/pure-ftpd/conf/PAMAuthentication
		ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
	}

	function PUREFTP_mainMENU() {
		echo -en "${GREEN}\nPure-FTP IS already INSTALLED.\n${NC}"
		echo -en "\n1) ${YELOW}Add a new user${NC}"
		echo -en "\n2) ${YELOW}Change a user password${NC}"
		echo -en "\n3) ${RED}Delete a user${NC}"
		echo -en "\n4) ${PURPLE}Remove Pure-FTP and configurations${NC}"
		echo -en "\n5) ${RED}Exit... ${NC}"
		echo -en "\n\n${BLUE} Select an Option: ${NC}"
	};



	function PUREFTP_Option() {
		if [ -e /etc/pure-ftpd ]; then
			while :
			do
			PUREFTP_mainMENU
			read option
				case $option in
					1) echo "ADD NEW USER"; PUREFTP_AddNewUser ;;
					2) echo "Change a user password"; PUREFTP_ChangeUserPass ;;
					3) echo "Delete a user"; PUREFTP_DelUser;;
					4) echo "Remove Pure-FTP"; PUREFTP_Remove ;;
					0) exit ;;
				esac
			done;
		else
			echo -e "\n\t {RED}Pure-FTP is not installed.{NC}\n"
			read -p "Install now Pure-FTP..? [y/n]: " -e -i y TT
			if [ "$TT" = "y" ]; then PUREFTP_Install; else echo -e "${YELOW}Closing now..${NC}" && sleep 5; fi;
			echo -e "\n${GREEN}Pure-FTP is installed. Please Re-open this script for create user.\n Closing now.. ${NC}\n" && sleep 5;
		fi;
	}

	if [ -e /etc/debian_version ]; then
	  PUREFTP_Option
	else
	  echo -e "${YELOW}This script must be run on Debian or Ubuntu.${NC}"
	fi;

	echo -e "${GREEN}End installation${NC}"

};

# -----------------------------

title="Installation Vesta Web Panel Control"

##=========================
# VARIABLE
function wait { 
	echo -en "\n\t\tДля продолжения, нажмите любую клавишу";read -s -n 1;
}
function title {
  clear
  echo "$title"
  wait
}



##=========================
# Install Ubuntu, Debian, Centos 
function Inst_VESTA() {
  title
  read -p "Enter Domain name: " domainname
  read -p "Enter Email admina: " AdminEmail;

  if [ -z ${domainname} ]; then
    domainname="domainname.com"
  fi;
  if [ -z ${AdminEmail} ]; then
    AdminEmail="webmaster@${domainname}"
  fi;
  #read -p "Enter Admin Password: " AdminPassword
  AdminPassword="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 12 )";
  # Download installation script
  curl -O http://vestacp.com/pub/vst-install.sh

  # Run it
  bash vst-install.sh \
    --nginx yes --apache yes \
    --phpfpm no \
    --named yes \
    --remi yes \
    --vsftpd yes --proftpd no \
    --iptables yes --fail2ban yes \
    --quota no \
    --exim yes --dovecot yes \
    --spamassassin yes --clamav yes \
    --softaculous yes \
    --mysql yes --postgresql no \
    --hostname ${domainname} \
    --email ${AdminEmail} \
    --password ${AdminPassword}
    --force
  echo -en "\t===== Installation is END =====\n"
  echo -en "Domain name: ${domainname}\n ADMIN PASSWORD: ${AdminPassword}\n ADMIN MAIL:  ${AdminEmail}"
  wait
};




function INS_HESTIA() {
#-------------------------------------------#
#               Debian + Ubuntu             #
#-------------------------------------------#

# Hestia installation wrapper
# https://www.hestiacp.com

#
# Currently Supported Operating Systems:
#
#   Debian 9, 10, 11
#   Ubuntu 18.04, 20.04
#

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    #exit 1
fi

# Check admin user account
if [ ! -z "$(grep ^admin: /etc/passwd)" ] && [ -z "$1" ]; then
    echo "Error: user admin exists"
    echo
    echo 'Please remove admin user before proceeding.'
    echo 'If you want to do it automatically run installer with -f option:'
    echo "Example: bash $0 --force"
    #exit 1
fi

# Check admin group
if [ ! -z "$(grep ^admin: /etc/group)" ] && [ -z "$1" ]; then
    echo "Error: group admin exists"
    echo
    echo 'Please remove admin group before proceeding.'
    echo 'If you want to do it automatically run installer with -f option:'
    echo "Example: bash $0 --force"
    #exit 1
fi

# Detect OS
if [ -e "/etc/os-release" ]; then
    type=$(grep "^ID=" /etc/os-release | cut -f 2 -d '=')
    if [ "$type" = "ubuntu" ]; then
        # Check if lsb_release is installed
        if [ -e '/usr/bin/lsb_release' ]; then
            release="$(lsb_release -s -r)"
            VERSION='ubuntu'            
        else
            echo "lsb_release is currently not installed, please install it:"
            echo "apt-get update && apt-get install lsb_release"
            #exit 1
        fi
    elif [ "$type" = "debian" ]; then
        release=$(cat /etc/debian_version|grep -o "[0-9]\{1,2\}"|head -n1)
        VERSION='debian'
    fi
else
    type="NoSupport"
fi

no_support_message(){
    echo "****************************************************"
    echo "Your operating system (OS) is not supported by"
    echo "Hestia Control Panel. Officially supported releases:"
    echo "****************************************************"
    echo "  Debian 9, 10, 11"
    echo "  Ubuntu 18.04, 20.04 LTS"
    echo "";
    #exit 1;
}

if [ "$type" = "NoSupport" ]; then
    no_support_message
fi

check_wget_curl(){
    # Check wget
    if [ -e '/usr/bin/wget' ]; then
        echo "
        wget -q https://raw.githubusercontent.com/GitKitNet/add/main/WebPanel/hestiacp/hst-install-$type.sh -O hst-install-$type.sh"
        if [ "$?" -eq '0' ]; then
            bash hst-install-$type.sh $*
            #exit
        else
            echo "Error: hst-install-$type.sh download failed."
           #exit 1
        fi
    fi;
    # Check curl
    if [ -e '/usr/bin/curl' ]; then
        echo "curl -s -O https://raw.githubusercontent.com/GitKitNet/add/main/WebPanel/hestiacp/hst-install-$type.sh"
        if [ "$?" -eq '0' ]; then
            bash hst-install-$type.sh $*
           #exit
        else
            echo "Error: hst-install-$type.sh download failed."
            #exit 1
        fi
    fi;
}

# Check for supported operating system before 
# proceeding with download of OS-specific installer,
# and throw error message if unsupported OS detected.
#
if [[ "$release" =~ ^(9|10|11|18.04|20.04)$ ]]; then
    check_wget_curl $*
else
    no_support_message
fi

#exit;
}


# Update Script
function SCriptUPDATE() {
	echo -en "\n Updating SCRIPT $filename ..." && sleep 2;
	wget $updpath/$filename -r -N -nd --no-check-certificate

	chmod 777 $filename
	chmod +x $filename

	echo -en "\n\t...script is upgradet.\n" && sleep 3;
};

# Install OpenVpn server and add users
function INSTALL_OpenVPN() {

#!/bin/bash
#
# https://github.com/GitKitNet/add/ToolKit/OpenVPN/
#
# Copyright (c) 2013 ITUA. Released under the MIT License.


# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
	echo 'This installer needs to be run with "bash", not "sh".'
	exit 0
fi;

# Discard stdin. Needed when running from an one-liner which includes a newline
read -N 999999 -t 0.001

# Detect OpenVZ 6
if [[ $(uname -r | cut -d "." -f 1) -eq 2 ]]; then
	echo "The system is running an old kernel, which is incompatible with this installer."
	exit
fi;

# Detect OS
# ======================
# $os_version variables aren't always in use, but are kept here for convenience
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"; os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.'); group_name="nogroup"
elif [[ -e /etc/debian_version ]]; then
	os="debian"; os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1); group_name="nogroup"
elif [[ -e /etc/almalinux-release || -e /etc/rocky-release || -e /etc/centos-release ]]; then
	os="centos"; os_version=$(grep -shoE '[0-9]+' /etc/almalinux-release /etc/rocky-release /etc/centos-release | head -1); group_name="nobody"
elif [[ -e /etc/fedora-release ]]; then
	os="fedora"; os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1); group_name="nobody"
else echo -e -n "This installer seems to be running on an unsupported distribution.\n Supported distros are Ubuntu, Debian, AlmaLinux, Rocky Linux, CentOS and Fedora."
	exit
fi;

if [[ "$os" == "ubuntu" && "$os_version" -lt 1804 ]]; then echo -e -n "Ubuntu 18.04 or higher is required to use this installer.\nThis version of Ubuntu is too old and unsupported."
	exit
fi;

if [[ "$os" == "debian" && "$os_version" -lt 9 ]]; then echo -en "Debian 9 or higher is required to use this installer.\nThis version of Debian is too old and unsupported."
	exit
fi;

if [[ "$os" == "centos" && "$os_version" -lt 7 ]]; then echo -en "CentOS 7 or higher is required to use this installer.\nThis version of CentOS is too old and unsupported."
	exit
fi;

# Detect environments where $PATH does not include the sbin directories
if ! grep -q sbin <<< "$PATH"; then echo '$PATH does not include sbin. Try using "su -" instead of "su".'
	exit
fi;

if [[ "$EUID" -ne 0 ]]; then
	echo "This installer needs to be run with superuser privileges."
	exit
fi;
if [[ ! -e /dev/net/tun ]] || ! ( exec 7<>/dev/net/tun ) 2>/dev/null; then
	echo -en "The system does not have the TUN device available.\nTUN needs to be enabled before running this installer."
	exit
fi;

new_client () {
	# Generates the custom client.ovpn
	{
	cat /etc/openvpn/server/client-common.txt
	echo "<ca>"
	cat /etc/openvpn/server/easy-rsa/pki/ca.crt
	echo "</ca>"
	echo "<cert>"
	sed -ne '/BEGIN CERTIFICATE/,$ p' /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt
	echo "</cert>"
	echo "<key>"
	cat /etc/openvpn/server/easy-rsa/pki/private/"$client".key
	echo "</key>"
	echo "<tls-crypt>"
	sed -ne '/BEGIN OpenVPN Static key/,$ p' /etc/openvpn/server/tc.key
	echo "</tls-crypt>"
	} > ~/"$client".ovpn
}

if [[ ! -e /etc/openvpn/server/server.conf ]]; then
	# Detect some Debian minimal setups where neither wget nor curl are installed
	if ! hash wget 2>/dev/null && ! hash curl 2>/dev/null; then
		echo "Wget is required to use this installer."
		read -n1 -r -p "Press any key to install Wget and continue..."
		apt-get update
		apt-get install -y wget
	fi;
	clear
	echo 'Welcome to this OpenVPN road warrior installer!'
	# If system has a single IPv4, it is selected automatically. Else, ask the user
	if [[ $(ip -4 addr | grep inet | grep -vEc '127(\.[0-9]{1,3}){3}') -eq 1 ]]; then
		ip=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}')
	else
		number_of_ip=$(ip -4 addr | grep inet | grep -vEc '127(\.[0-9]{1,3}){3}')
		echo
		echo "Which IPv4 address should be used?"
		ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | nl -s ') '
		read -p "IPv4 address [1]: " ip_number
		until [[ -z "$ip_number" || "$ip_number" =~ ^[0-9]+$ && "$ip_number" -le "$number_of_ip" ]]; do
			echo "$ip_number: invalid selection."
			read -p "IPv4 address [1]: " ip_number
		done
		[[ -z "$ip_number" ]] && ip_number="1"
		ip=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | sed -n "$ip_number"p)
	fi;

	# If $ip is a private IP address, the server must be behind NAT
	if echo "$ip" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
		echo
		echo "This server is behind NAT. What is the public IPv4 address or hostname?"
		# Get public IP and sanitize with grep
		get_public_ip=$(grep -m 1 -oE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' <<< "$(wget -T 10 -t 1 -4qO- "http://ip1.dynupdate.no-ip.com/" || curl -m 10 -4Ls "http://ip1.dynupdate.no-ip.com/")")
		read -p "Public IPv4 address / hostname [$get_public_ip]: " public_ip
		# If the checkip service is unavailable and user didn't provide input, ask again
		until [[ -n "$get_public_ip" || -n "$public_ip" ]]; do
			echo "Invalid input."
			read -p "Public IPv4 address / hostname: " public_ip
		done
		[[ -z "$public_ip" ]] && public_ip="$get_public_ip"
	fi;

	# If system has a single IPv6, it is selected automatically
	if [[ $(ip -6 addr | grep -c 'inet6 [23]') -eq 1 ]]; then
		ip6=$(ip -6 addr | grep 'inet6 [23]' | cut -d '/' -f 1 | grep -oE '([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}')
	fi;

	# If system has multiple IPv6, ask the user to select one
	if [[ $(ip -6 addr | grep -c 'inet6 [23]') -gt 1 ]]; then
		number_of_ip6=$(ip -6 addr | grep -c 'inet6 [23]')
		echo
		echo "Which IPv6 address should be used?"
		ip -6 addr | grep 'inet6 [23]' | cut -d '/' -f 1 | grep -oE '([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}' | nl -s ') '
		read -p "IPv6 address [1]: " ip6_number
		until [[ -z "$ip6_number" || "$ip6_number" =~ ^[0-9]+$ && "$ip6_number" -le "$number_of_ip6" ]]; do
			echo "$ip6_number: invalid selection."
			read -p "IPv6 address [1]: " ip6_number
		done
		[[ -z "$ip6_number" ]] && ip6_number="1"
		ip6=$(ip -6 addr | grep 'inet6 [23]' | cut -d '/' -f 1 | grep -oE '([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}' | sed -n "$ip6_number"p)
	fi;
	echo
	echo "Which protocol should OpenVPN use?"
	echo "   1) UDP (recommended)"
	echo "   2) TCP"
	read -p "Protocol [1]: " protocol
	until [[ -z "$protocol" || "$protocol" =~ ^[12]$ ]]; do
		echo "$protocol: invalid selection."
		read -p "Protocol [1]: " protocol
	done
	case "$protocol" in
		1|"") protocol=udp ;;
		2) protocol=tcp ;;
	esac
	echo
	echo "What port should OpenVPN listen to?"
	read -p "Port [1194]: " port
	until [[ -z "$port" || "$port" =~ ^[0-9]+$ && "$port" -le 65535 ]]; do
		echo "$port: invalid port."
		read -p "Port [1194]: " port
	done
	[[ -z "$port" ]] && port="1194"
	echo
	echo "Select a DNS server for the clients:"
	echo "   1) Current system resolvers"
	echo "   2) Google"
	echo "   3) 1.1.1.1"
	echo "   4) OpenDNS"
	echo "   5) Quad9"
	echo "   6) AdGuard"
	read -p "DNS server [1]: " dns
	until [[ -z "$dns" || "$dns" =~ ^[1-6]$ ]]; do
		echo "$dns: invalid selection."
		read -p "DNS server [1]: " dns
	done
	echo
	echo "Enter a name for the first client:"
	read -p "Name [client]: " unsanitized_client
	# Allow a limited set of characters to avoid conflicts
	client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
	[[ -z "$client" ]] && client="client"
	echo
	echo "OpenVPN installation is ready to begin."
	# Install a firewall if firewalld or iptables are not already available
	if ! systemctl is-active --quiet firewalld.service && ! hash iptables 2>/dev/null; then
		if [[ "$os" == "centos" || "$os" == "fedora" ]]; then
			firewall="firewalld"
			# We don't want to silently enable firewalld, so we give a subtle warning
			# If the user continues, firewalld will be installed and enabled during setup
			echo "firewalld, which is required to manage routing tables, will also be installed."
		elif [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
			# iptables is way less invasive than firewalld so no warning is given
			firewall="iptables"
		fi
	fi
	read -n1 -r -p "Press any key to continue..."
	# If running inside a container, disable LimitNPROC to prevent conflicts
	if systemd-detect-virt -cq; then
		mkdir /etc/systemd/system/openvpn-server@server.service.d/ 2>/dev/null
		echo "[Service]
LimitNPROC=infinity" > /etc/systemd/system/openvpn-server@server.service.d/disable-limitnproc.conf
	fi
	if [[ "$os" = "debian" || "$os" = "ubuntu" ]]; then
		apt-get update
		apt-get install -y --no-install-recommends openvpn openssl ca-certificates $firewall
	elif [[ "$os" = "centos" ]]; then
		yum install -y epel-release
		yum install -y openvpn openssl ca-certificates tar $firewall
	else
		# Else, OS must be Fedora
		dnf install -y openvpn openssl ca-certificates tar $firewall
	fi
	# If firewalld was just installed, enable it
	if [[ "$firewall" == "firewalld" ]]; then
		systemctl enable --now firewalld.service
	fi;

	# Get easy-rsa
	easy_rsa_url='https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.1/EasyRSA-3.1.1.tgz'
	mkdir -p /etc/openvpn/server/easy-rsa/
	{ wget -qO- "$easy_rsa_url" 2>/dev/null || curl -sL "$easy_rsa_url" ; } | tar xz -C /etc/openvpn/server/easy-rsa/ --strip-components 1
	chown -R root:root /etc/openvpn/server/easy-rsa/
	cd /etc/openvpn/server/easy-rsa/

# Create the PKI, set up the CA and the server and client certificates
	./easyrsa --batch init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa --batch --days=3650 build-server-full server nopass
	./easyrsa --batch --days=3650 build-client-full "$client" nopass
	./easyrsa --batch --days=3650 gen-crl

# Move the stuff we need
	cp pki/ca.crt pki/private/ca.key pki/issued/server.crt pki/private/server.key pki/crl.pem /etc/openvpn/server

# CRL is read with each client connection, while OpenVPN is dropped to nobody
	chown nobody:"$group_name" /etc/openvpn/server/crl.pem

# Without +x in the directory, OpenVPN can't run a stat() on the CRL file
	chmod o+x /etc/openvpn/server/

# Generate key for tls-crypt
	openvpn --genkey --secret /etc/openvpn/server/tc.key

# Create the DH parameters file using the predefined ffdhe2048 group
	echo '-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA//////////+t+FRYortKmq/cViAnPTzx2LnFg84tNpWp4TZBFGQz
+8yTnc4kmz75fS/jY2MMddj2gbICrsRhetPfHtXV/WVhJDP1H18GbtCFY2VVPe0a
87VXE15/V8k1mE8McODmi3fipona8+/och3xWKE2rec1MKzKT0g6eXq8CrGCsyT7
YdEIqUuyyOP7uWrat2DX9GgdT0Kj3jlN9K5W7edjcrsZCwenyO4KbXCeAvzhzffi
7MA0BM0oNC9hkXL+nOmFg/+OTxIy7vKBg8P+OxtMb61zO7X8vC7CIAXFjvGDfRaD
ssbzSibBsu/6iGtCOGEoXJf//////////wIBAg==
-----END DH PARAMETERS-----' > /etc/openvpn/server/dh.pem
	# Generate server.conf
	echo "local $ip
port $port
proto $protocol
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA512
tls-crypt tc.key
topology subnet
server 10.8.0.0 255.255.255.0" > /etc/openvpn/server/server.conf
	# IPv6
	if [[ -z "$ip6" ]]; then
		echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server/server.conf
	else
		echo 'server-ipv6 fddd:1194:1194:1194::/64' >> /etc/openvpn/server/server.conf
		echo 'push "redirect-gateway def1 ipv6 bypass-dhcp"' >> /etc/openvpn/server/server.conf
	fi;
	echo 'ifconfig-pool-persist ipp.txt' >> /etc/openvpn/server/server.conf
	# DNS
	case "$dns" in
		1|"")
			# Locate the proper resolv.conf
			# Needed for systems running systemd-resolved
			if grep '^nameserver' "/etc/resolv.conf" | grep -qv '127.0.0.53' ; then
				resolv_conf="/etc/resolv.conf"
			else
				resolv_conf="/run/systemd/resolve/resolv.conf"
			fi
			# Obtain the resolvers from resolv.conf and use them for OpenVPN
			grep -v '^#\|^;' "$resolv_conf" | grep '^nameserver' | grep -v '127.0.0.53' | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | while read line; do
				echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server/server.conf
			done
		;;
		2) echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server/server.conf
		;;
		3) echo 'push "dhcp-option DNS 1.1.1.1"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 1.0.0.1"' >> /etc/openvpn/server/server.conf
		;;
		4) echo 'push "dhcp-option DNS 208.67.222.222"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 208.67.220.220"' >> /etc/openvpn/server/server.conf
		;;
		5) echo 'push "dhcp-option DNS 9.9.9.9"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 149.112.112.112"' >> /etc/openvpn/server/server.conf
		;;
		6) echo 'push "dhcp-option DNS 94.140.14.14"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 94.140.15.15"' >> /etc/openvpn/server/server.conf
		;;
	esac
	echo 'push "block-outside-dns"' >> /etc/openvpn/server/server.conf
	echo "keepalive 10 120
cipher AES-256-CBC
user nobody
group $group_name
persist-key
persist-tun
verb 3
crl-verify crl.pem" >> /etc/openvpn/server/server.conf
	if [[ "$protocol" = "udp" ]]; then
		echo "explicit-exit-notify" >> /etc/openvpn/server/server.conf
	fi
	# Enable net.ipv4.ip_forward for the system
	echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-openvpn-forward.conf
	# Enable without waiting for a reboot or service restart
	echo 1 > /proc/sys/net/ipv4/ip_forward
	if [[ -n "$ip6" ]]; then
		# Enable net.ipv6.conf.all.forwarding for the system
		echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.d/99-openvpn-forward.conf
		# Enable without waiting for a reboot or service restart
		echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
	fi
	if systemctl is-active --quiet firewalld.service; then
		# Using both permanent and not permanent rules to avoid a firewalld
		# reload.
		# We don't use --add-service=openvpn because that would only work with
		# the default port and protocol.
		firewall-cmd --add-port="$port"/"$protocol"
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --add-port="$port"/"$protocol"
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
		# Set NAT for the VPN subnet
		firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
		firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
		if [[ -n "$ip6" ]]; then
			firewall-cmd --zone=trusted --add-source=fddd:1194:1194:1194::/64
			firewall-cmd --permanent --zone=trusted --add-source=fddd:1194:1194:1194::/64
			firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
			firewall-cmd --permanent --direct --add-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
		fi
	else
		# Create a service to set up persistent iptables rules
		iptables_path=$(command -v iptables)
		ip6tables_path=$(command -v ip6tables)
		# nf_tables is not available as standard in OVZ kernels. So use iptables-legacy
		# if we are in OVZ, with a nf_tables backend and iptables-legacy is available.
		if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(command -v iptables)" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
			iptables_path=$(command -v iptables-legacy)
			ip6tables_path=$(command -v ip6tables-legacy)
		fi
		echo "[Unit]
Before=network.target
[Service]
Type=oneshot
ExecStart=$iptables_path -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ip
ExecStart=$iptables_path -I INPUT -p $protocol --dport $port -j ACCEPT
ExecStart=$iptables_path -I FORWARD -s 10.8.0.0/24 -j ACCEPT
ExecStart=$iptables_path -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
ExecStop=$iptables_path -t nat -D POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ip
ExecStop=$iptables_path -D INPUT -p $protocol --dport $port -j ACCEPT
ExecStop=$iptables_path -D FORWARD -s 10.8.0.0/24 -j ACCEPT
ExecStop=$iptables_path -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" > /etc/systemd/system/openvpn-iptables.service
		if [[ -n "$ip6" ]]; then
			echo "ExecStart=$ip6tables_path -t nat -A POSTROUTING -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to $ip6
ExecStart=$ip6tables_path -I FORWARD -s fddd:1194:1194:1194::/64 -j ACCEPT
ExecStart=$ip6tables_path -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
ExecStop=$ip6tables_path -t nat -D POSTROUTING -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to $ip6
ExecStop=$ip6tables_path -D FORWARD -s fddd:1194:1194:1194::/64 -j ACCEPT
ExecStop=$ip6tables_path -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/systemd/system/openvpn-iptables.service
		fi
		echo "RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/openvpn-iptables.service
		systemctl enable --now openvpn-iptables.service
	fi
	# If SELinux is enabled and a custom port was selected, we need this
	if sestatus 2>/dev/null | grep "Current mode" | grep -q "enforcing" && [[ "$port" != 1194 ]]; then
		# Install semanage if not already present
		if ! hash semanage 2>/dev/null; then
			if [[ "$os_version" -eq 7 ]]; then
				# Centos 7
				yum install -y policycoreutils-python
			else
				# CentOS 8 or Fedora
				dnf install -y policycoreutils-python-utils
			fi
		fi
		semanage port -a -t openvpn_port_t -p "$protocol" "$port"
	fi
	# If the server is behind NAT, use the correct IP address
	[[ -n "$public_ip" ]] && ip="$public_ip"
	# client-common.txt is created so we have a template to add further users later
	echo "client
dev tun
proto $protocol
remote $ip $port
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
cipher AES-256-CBC
ignore-unknown-option block-outside-dns
verb 3" > /etc/openvpn/server/client-common.txt
	# Enable and start the OpenVPN service
	systemctl enable --now openvpn-server@server.service
	# Generates the custom client.ovpn
	new_client
	echo
	echo "Finished!"
	echo
	echo "The client configuration is available in:" ~/"$client.ovpn"
	echo "New clients can be added by running this script again."
else
	clear
	echo "OpenVPN is already installed."
	echo
	echo "Select an option:"
	echo "   1) Add a new client"
	echo "   2) Revoke an existing client"
	echo "   3) Remove OpenVPN"
	echo "   4) Exit"
	read -p "Option: " option
	until [[ "$option" =~ ^[1-4]$ ]]; do
		echo "$option: invalid selection."
		read -p "Option: " option
	done
	case "$option" in
		1)
			echo
			echo "Provide a name for the client:"
			read -p "Name: " unsanitized_client
			client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
			while [[ -z "$client" || -e /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt ]]; do
				echo "$client: invalid name."
				read -p "Name: " unsanitized_client
				client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
			done
			cd /etc/openvpn/server/easy-rsa/
			./easyrsa --batch --days=3650 build-client-full "$client" nopass
			# Generates the custom client.ovpn
			new_client
			echo
			echo "$client added. Configuration available in:" ~/"$client.ovpn"
			exit
		;;
		2)
			# This option could be documented a bit better and maybe even be simplified
			# ...but what can I say, I want some sleep too
			number_of_clients=$(tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep -c "^V")
			if [[ "$number_of_clients" = 0 ]]; then
				echo
				echo "There are no existing clients!"
				exit
			fi
			echo
			echo "Select the client to revoke:"
			tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
			read -p "Client: " client_number
			until [[ "$client_number" =~ ^[0-9]+$ && "$client_number" -le "$number_of_clients" ]]; do
				echo "$client_number: invalid selection."
				read -p "Client: " client_number
			done
			client=$(tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$client_number"p)
			echo
			read -p "Confirm $client revocation? [y/N]: " revoke
			until [[ "$revoke" =~ ^[yYnN]*$ ]]; do
				echo "$revoke: invalid selection."
				read -p "Confirm $client revocation? [y/N]: " revoke
			done
			if [[ "$revoke" =~ ^[yY]$ ]]; then
				cd /etc/openvpn/server/easy-rsa/
				./easyrsa --batch revoke "$client"
				./easyrsa --batch --days=3650 gen-crl
				rm -f /etc/openvpn/server/crl.pem
				cp /etc/openvpn/server/easy-rsa/pki/crl.pem /etc/openvpn/server/crl.pem
				# CRL is read with each client connection, when OpenVPN is dropped to nobody
				chown nobody:"$group_name" /etc/openvpn/server/crl.pem
				echo
				echo "$client revoked!"
			else
				echo
				echo "$client revocation aborted!"
			fi
			exit
		;;
		3)
			echo
			read -p "Confirm OpenVPN removal? [y/N]: " remove
			until [[ "$remove" =~ ^[yYnN]*$ ]]; do
				echo "$remove: invalid selection."
				read -p "Confirm OpenVPN removal? [y/N]: " remove
			done
			if [[ "$remove" =~ ^[yY]$ ]]; then
				port=$(grep '^port ' /etc/openvpn/server/server.conf | cut -d " " -f 2)
				protocol=$(grep '^proto ' /etc/openvpn/server/server.conf | cut -d " " -f 2)
				if systemctl is-active --quiet firewalld.service; then
					ip=$(firewall-cmd --direct --get-rules ipv4 nat POSTROUTING | grep '\-s 10.8.0.0/24 '"'"'!'"'"' -d 10.8.0.0/24' | grep -oE '[^ ]+$')
					# Using both permanent and not permanent rules to avoid a firewalld reload.
					firewall-cmd --remove-port="$port"/"$protocol"
					firewall-cmd --zone=trusted --remove-source=10.8.0.0/24
					firewall-cmd --permanent --remove-port="$port"/"$protocol"
					firewall-cmd --permanent --zone=trusted --remove-source=10.8.0.0/24
					firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
					firewall-cmd --permanent --direct --remove-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
					if grep -qs "server-ipv6" /etc/openvpn/server/server.conf; then
						ip6=$(firewall-cmd --direct --get-rules ipv6 nat POSTROUTING | grep '\-s fddd:1194:1194:1194::/64 '"'"'!'"'"' -d fddd:1194:1194:1194::/64' | grep -oE '[^ ]+$')
						firewall-cmd --zone=trusted --remove-source=fddd:1194:1194:1194::/64
						firewall-cmd --permanent --zone=trusted --remove-source=fddd:1194:1194:1194::/64
						firewall-cmd --direct --remove-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
						firewall-cmd --permanent --direct --remove-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
					fi
				else
					systemctl disable --now openvpn-iptables.service
					rm -f /etc/systemd/system/openvpn-iptables.service
				fi
				if sestatus 2>/dev/null | grep "Current mode" | grep -q "enforcing" && [[ "$port" != 1194 ]]; then
					semanage port -d -t openvpn_port_t -p "$protocol" "$port"
				fi;
				systemctl disable --now openvpn-server@server.service
				rm -f /etc/systemd/system/openvpn-server@server.service.d/disable-limitnproc.conf
				rm -f /etc/sysctl.d/99-openvpn-forward.conf
				if [[ "$os" = "debian" || "$os" = "ubuntu" ]]; then
					rm -rf /etc/openvpn/server
					apt-get remove --purge -y openvpn
				else
					# Else, OS must be CentOS or Fedora
					yum remove -y openvpn
					rm -rf /etc/openvpn/server
				fi;
				echo -en "\nOpenVPN removed!"
			else echo -en "\nOpenVPN removal aborted!";
			fi;
			exit ;;
		4) exit ;;
	esac
fi;

}


# =============================
#       END MAIN SCRIPT
# =============================



# =============================
function MAIN() {

#==============================
#           MENU
#
#         MAIN MENU
#==============================
function MENU_MAIN() {
    clear;
    showBANNER
    echo -e -n "\n\t${GREEN}${BGBlack}==== MAIN MENU ====${NC}\n"
    echo -e -n "${Yellow}
\t1. Create SSH key     ${NC} ${Purple}
\t2. Install LEMP       ${NC} ${BLUE}
\t3. Install LAMP       ${NC} ${Yellow}
\t4. Control Panel      ${NC} ${MAGENTO}
\t5. OpenVPN, OpenSSL   ${NC} ${BLUE}
\t6. Free               ${NC} ${RED}
\t7. Free               ${NC} ${MAGENTO}
\t8. FTP & Ather        ${NC} ${MAGENTO}
\t9. Script         ${NC} ${RED}
\n\tq. Quit...          ${NC}";

}

#==============================

#   Menu SSH
function Men_SSH() {
	title="Generate Key SSH";
	echo -e -n "\n\t${GREEN}SSH KeyGen:${NC}\n"
	echo -e -n "
    \t1. $title ${GREEN} ED25519       ${NC}
    \t2. $title ${Yellow} RSA          ${NC}
    \t3. $title ${CYAN}2 RSA [PEM]     ${NC}
    \t4. $title ${BLUE} DSA            ${NC}
    \t5. $title ${Purple} ECDSA        ${NC}
    \t6. $title ${RED} EdDSA - [OFF]   ${RED}
    \n\t0. Back                        ${NC}
";
}

##   LEMP MENU 
function MENU_LEMP() {
	echo -e -n "\n\t ${GREEN}LEMP, WordPress installation & Settings:${NC} \n"
echo -e "
\t1. Install MySQL With ${CYAN} WordPress ${NC}
\t2. Add one more ${CYAN}WordPress With New user ${NC}
\t3. PreInstall ${CYAN}NGinX + Php-7.4 + Certbot${NC}
\t4. Install ${CYAN}WordPress With All Services Cloudflare ${NC}
\t5. Instal ${CYAN}WordPress With All Services Certbot ${NC}${RED}
\n\tq/0. Back ${NC}\n";
}

##   MENU 3: LAMP
function MENU_LAMP() {
    echo -e "\n\t ${GREEN}LAMP installation & Settings:${NC} \n"
    echo -e -n "${Yellow}";
    echo -e -n "\t1. Install LAMP & WordPress";
    echo -e -n "\t${BLUE}(Apache, php7.4, phpMyAdmin) ${RED} \n";
    echo -e -n "\n\tq/0. Back ${NC}\n";
    echo -e -n "";
}; 

##   MENU 4: Web Control Panel
function MENU_CPANEL() {
    echo -e "\n\t ${GREEN}Menu 4: CONTROL PANEL ${Yellow} \n";
    echo -e "\t1. Install OwnCloud       ${PURPLE} ";
    echo -e "\t2. Install Vesta          ${BLUE} ";
    echo -e "\t3. Install HESTIA         ${PURPLE} ";
    echo -e "\t4. FREE                   ${RED} ";
    echo -e "\n\tq/0. Back               ${NC}\n ";
};

##   MENU 5: Web Control Panel
function MENU_5() {
    echo -e "\n\t ${GREEN}Menu 5: Open VPN SSL Servers ${Yellow} \n";
    echo -e "\t1. Install OpenVPN Servers                   ${PURPLE} ";
    echo -e "\t2. FREE                            ${PURPLE} ";
    echo -e "\t3. FREE                            ${PURPLE} ";
    echo -e "\t4. FREE                            ${RED} ";
    echo -e "\n\t0. Back                          ${NC}\n ";
};


##   MENU 6: Web Control Panel
function MENU_6() {
    echo -e "\n\t ${GREEN}Menu 6: FREE ${Yellow} \n";
    echo -e "\t1. FREE                            ${PURPLE} ";
    echo -e "\t2. FREE                            ${PURPLE} ";
    echo -e "\t3. FREE                            ${PURPLE} ";
    echo -e "\t4. FREE                            ${RED} ";
    echo -e "\n\t0. Back                          ${NC}\n ";
};

##   MENU 7: Web Control Panel
function MENU_7() {
    echo -e "\n\t ${GREEN}Menu 7: FREE ${Yellow} \n";
    echo -e "\t1. FREE                            ${PURPLE} ";
    echo -e "\t2. FREE                            ${PURPLE} ";
    echo -e "\t3. FREE                            ${PURPLE} ";
    echo -e "\t4. FREE                            ${RED} ";
    echo -e "\n\t0. Back                          ${NC}\n ";
};


##   MENU 8: Modules & Components
function MENU_MODandCOMPON() {
    echo -e "\n\t ${GREEN}Menu 8: Modules & Components ${Yellow} \n";
    echo -e "\t1. Install Pure-FTP       ${PURPLE} ";
    echo -e "\t2. FREE                            ${PURPLE} ";
    echo -e "\t3. FREE                            ${PURPLE} ";
    echo -e "\t4. FREE                            ${RED} ";
    echo -e "\n\t0. Back                          ${NC}\n ";
};

##   MENU 9: Script Components
function MENU_ScriptCOMPON() {
    echo -e "\n\t ${GREEN}Menu 9: Script Components ${BLUE} \n";
    echo -e "\t1. Update Script                   ${PURPLE} ";
    echo -e "\t2. FREE                            ${PURPLE} ";
    echo -e "\t3. FREE                            ${PURPLE} ";
    echo -e "\t4. FREE                            ${RED} ";
    echo -e "\n\t0. Back                          ${NC}\n ";
};

# ============================================
	while :
	do
    showBANNER
    MENU_MAIN
    echo -n -e "\n\tSelection: "
    read -n1 opt
    a=true;
    case $opt in

# ==== 1 SubMenu =============================
		1) echo -e "==== Create SSH key ===="
		while :
		do
		showBANNER
		Men_SSH
		echo -n -e "\n\tSelection: "
		read -n1 opt;
		case $opt in
			1) TKEY="ed25519" && MKEY="" && OnRUN ;;
			2) TKEY="rsa" && MKEY="" && OnRUN ;;
			3) TKEY="rsa" && MKEY="PEM" && OnRUN ;;
			4) TKEY="dsa" && MKEY="" && OnRUN ;;
			5) TKEY="ecdsa" && MKEY="" && OnRUN ;;
			6) TKEY="eddsa" && MKEY="" && OffRUN ;;
			/q | q | 0) break ;;
			*) ;;
		esac
		done
		;;

# ==== 2 =====================================
		2) echo -e "Install LEMP: "
		while :
		do
		showBANNER
		MENU_LEMP
		echo -n -e "\n\tSelection: "
		read -n1 opt;
		case $opt in
			1) Inst_MySQLWP ;;
			2) Add_WPiNUSER ;;
			3) PreIns_NPhpCert ;;
			4) Inst_WPiCF ;;
			5) Inst_WPiCRT ;;
			/q | q | 0) break ;;
			*) ;;
		esac
		done
		;;

# ==== 3 =====================================
		3) echo -e "# submenu: MEMU 3"
		while :
		do
		showBANNER
		MENU_LAMP
		echo -n -e "\n\tSelection: "
		read -n1 opt;
		case $opt in
			1) installLAMP ;;
			2) echo -e "MENU 3 - SUBmenu 2" ;;
			3) echo -e "MENU 3 - SUBmenu 3" ;;
			/q | q | 0) break ;;
			*) ;;
		esac
		done
		;;

# ==== 4 =====================================
		4) echo -e "Control Panell: "
		while :
		do
		showBANNER
		MENU_CPANEL
		echo -n -e "\n\tSelection: "
		read -n1 opt;
		case $opt in
			1) OWNCLOUD ;;
			2) Inst_VESTA ;;
			3) INS_HESTIA ;;
			4) echo -e "FREE $opt"  ;;
			5) echo -e "FREE $opt"  ;;
			/q | q | 0) break ;;
			*) ;;
		esac
		done
		;;

# ==== 5 =====================================
		5) echo -e "Modules & Components: "
		while :
		do
		showBANNER
		MENU_5
		echo -n -e "\n\tSelection: "
		read -n1 opt;
		case $opt in
			1) echo -e "Start Install OpenVPN server"; echo "=============================="
;;
			2) INSTALL_OpenVPN ;;
			3) echo -e "FREE $opt"  ;;
			4) echo -e "FREE $opt"  ;;
			5) echo -e "FREE $opt"  ;;
			/q | q | 0) break ;;
			*) ;;
		esac
		done
		;;

# ==== 6 =====================================
		6) echo -e "Menu 6: "
		while :
		do
		showBANNER
		MENU_6
		echo -n -e "\n\tSelection: "
		read -n1 opt;
		case $opt in
			1) PUREFTP_RUN ;;
			2) echo -e "FREE $opt" && sleep 3 ;;
			3) echo -e "FREE $opt" && sleep 3 ;;
			4) echo -e "FREE $opt" && sleep 3 ;;
			5) echo -e "FREE $opt" && sleep 3 ;;
			/q | q | 0) break ;;
			*) ;;
		esac
		done
		;;

# ==== 7 =====================================
		7) #FREE
			echo -e "Menu 7: "
			while :
			do
			showBANNER
			MENU_7
			echo -n -e "\n\tSelection: "
			read -n1 opt;
			case $opt in
				1) echo -e "FREE $opt" && sleep 3 ;;
				2) echo -e "FREE $opt" && sleep 3 ;;
				3) echo -e "FREE $opt" && sleep 3 ;;
				4) echo -e "FREE $opt" && sleep 3 ;;
				5) echo -e "FREE $opt" && sleep 3 ;;
				/q | q | 0) break ;;
				*) ;;
			esac
			done
		;;

# ==== 8 =====================================
		8) #COMPONENTS
			echo -e "Menu 8: "
			while :
			do
			showBANNER
			MENU_MODandCOMPON
			echo -n -e "\n\tSelection: "
			read -n1 opt;
			case $opt in
				1) PUREFTP_RUN ;;
				2) echo -e "FREE $opt" && sleep 3 ;;
				3) echo -e "FREE $opt" && sleep 3 ;;
				4) echo -e "FREE $opt" && sleep 3 ;;
				5) echo -e "FREE $opt" && sleep 3 ;;
				/q | q | 0) break ;;
				*) ;;
			esac
			done
		;;

# ==== 9 =====================================
		9) #
			echo -e "Script Components: "
			while :
			do
			showBANNER
			MENU_ScriptCOMPON
			echo -n -e "\n\tSelection: "
			read -n1 opt;
			case $opt in
				1) SCriptUPDATE ;;
				2) echo -e "FREE $opt" && sleep 3 ;;
				3) echo -e "FREE $opt" && sleep 3 ;;
				4) echo -e "FREE $opt" && sleep 3 ;;
				5) echo -e "FREE $opt" && sleep 3 ;;
				/q | q | 0) break ;;
				*) ;;
			esac
			done
		;;

# ==== END ===================================
		/q | q | 0) echo; break ;;
		*) ;;
	esac
	done

# ==== END MENU ==============================

	echo "Quit..." && sleep 3 && clear;
}; 

THIS
MAIN

CleanUP_;

# # # # # # # # # # # # # # # # # # # # # # #

# exit 1

