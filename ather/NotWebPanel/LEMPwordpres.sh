#!/bin/bash


## ====================================
# VARIABLE && function
# NGINX_conf='https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/LEMP/nginx.conf'
phpV="7.0"
function TIMER() {
  if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; else T="6"; fi;
  secs="$((1 * ${T}))"; while [ $secs -gt 0 ]; do echo -ne "\t $secs\033[0K\r"; sleep 1 && : $((secs--)); done;
}

USER_PASS=`pwgen -s 14 1`
DB_PASS=`pwgen -s 14 1`



## ====================================
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?" && read domainname
#echo "Username (eg. mysitedatabase)?" && read USERNAME
USERNAME="root"
echo "Updating OS................."
TIMER
apt-get upgrade -y && \
   apt-get update -y


## ====================================
echo "Installing Nginx"
TIMER
apt-get install -y wget curl \
  nginx pwgen zip unzip tar \
  build-essential ntp ntpdate htop


## ====================================
echo "Sit back and relax :) ......"
TIMER
mkdir -p /etc/nginx/sites-available/ && cd /etc/nginx/sites-available/
# NGINX_DEFAULT='https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/LEMP/default'
#wget -O "$domainname" "${NGINX_DEFAULT}"
touch /etc/nginx/sites-available/default
cat> /etc/nginx/sites-available/default <<EOL
# default
server {
	listen 443 ssl http2;
	listen [::]:443 ssl http2;
	root /var/www/example.com;
	index index.html index.htm index.php;
	server_name $domainname www.$domainname;

	location / {
		#try_files \$uri \$uri/ =404;
		try_files \$uri \$uri/ /index.php?q=$uri&$args;
	}

	rewrite ^/sitemap.xml\$ /index.php?aiosp_sitemap_path=root last;
	rewrite ^/sitemap_(.+)_(\d+).xml$ /index.php?aiosp_sitemap_path=\$1&aiosp_sitemap_page=\$2 last;
	rewrite ^/sitemap_(.+).xml\$ /index.php?aiosp_sitemap_path=\$1 last;

	location ~* \.(txt|xml|js)\$ {
		expires 8d;
	}

	location ~* \.(css)\$ {
		expires 8d;
	}

	location ~* \.(flv|ico|pdf|avi|mov|ppt|doc|mp3|wmv|wav|mp4|m4v|ogg|webm|aac|eot|ttf|otf|woff|svg)\$ {
		expires 8d;
	}

	location ~* \.(jpg|jpeg|png|gif|swf|webp)\$ {
		expires 8d;
	}

	ssl_certificate /etc/nginx/ssl/nginx.crt;
	ssl_certificate_key /etc/nginx/ssl/nginx.key;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_prefer_server_ciphers on;
	ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
	ssl_dhparam /etc/nginx/ssl/dhparam.pem;
	ssl_session_cache shared:SSL:20m;
	ssl_session_timeout 180m;
	resolver 8.8.8.8 8.8.4.4;
	add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains; preload; always';
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header Referrer-Policy "strict-origin-when-cross-origin";
	# add_header Content-Security-Policy "script-src 'self' 'unsafe-inline' 'unsafe-eval' *.youtube.com maps.gstatic.com *.googleapis.com *.google-analytics.com cdnjs.cloudflare.com assets.zendesk.com connect.facebook.net; frame-src 'self' *.youtube.com assets.zendesk.com *.facebook.com s-static.ak.facebook.com tautt.zendesk.com; object-src 'self'";
	# add_header Content-Security-Policy "default-src 'self'; script-src 'self' cdnjs.cloudflare.com; img-src 'self'; style-src 'self' 'unsafe-inline' fonts.googleapis.com cdnjs.cloudflare.com; font-src 'self' fonts.gstatic.com cdnjs.cloudflare.com; form-action 'self'";
	# define error page
	error_page 404 = @notfound;
	# error page location redirect 301

	location @notfound {
		return 301 /;
	}

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}

server {
	listen 80;
	listen [::]:80;
	server_name example.com www.example.com;
	return 301 https://$server_name$request_uri;
}
EOL



sed -i -e "s/example.com/$domainname/" /etc/nginx/sites-available/$domainname
sed -i -e "s/www.example.com/www.$domainname/" /etc/nginx/sites-available/$domainname
ln -s /etc/nginx/sites-available/"$domainname" /etc/nginx/sites-enabled/



## ====================================
echo "Setting up Cloudflare FULL SSL"
TIMER
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
mv nginx.conf nginx.conf.backup

# wget -O nginx.conf "https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/LEMP/nginx.conf"
touch /etc/nginx/nginx.conf
cat> /etc/nginx/nginx.conf <<EOL
user www-data;
worker_processes auto;
pid /run/nginx.pid;
worker_rlimit_nofile 100000;


error_log /var/log/nginx/error.log crit;

events {
	worker_connections 4000;
	use epoll;
	multi_accept on;
	}

http {

	open_file_cache max=200000 inactive=20s; 
	open_file_cache_valid 30s; 
	open_file_cache_min_uses 2;
	open_file_cache_errors on;


	access_log off;

	reset_timedout_connection on;

	client_body_timeout 10;

	send_timeout 2;

	keepalive_requests 100000;

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 30;
	types_hash_max_size 2048;
	server_tokens off;
	client_max_body_size 100M;
	server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##
	
	#access_log /var/log/nginx/access.log;
	#error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	# Enable Gzip compression
gzip          on;

# Compression level (1-9)
gzip_comp_level     5;

# Don't compress anything under 256 bytes
gzip_min_length     256;

# Compress output of these MIME-types
gzip_types
    application/atom+xml
    application/javascript
    application/json
    application/rss+xml
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-font-opentype
    application/x-font-truetype
    application/x-javascript
    application/x-web-app-manifest+json
    application/xhtml+xml
    application/xml
    font/eot
    font/opentype
    font/otf
    image/svg+xml
    image/x-icon
    image/vnd.microsoft.icon
    text/css
    text/plain
    text/javascript
    text/x-component;

# Disable gzip for bad browsers
gzip_disable  "MSIE [1-6]\.(?!.*SV1)";


	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}


#mail {
#	# See sample authentication script at:
#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
# 
#	# auth_http localhost/auth.php;
#	# pop3_capabilities "TOP" "USER";
#	# imap_capabilities "IMAP4rev1" "UIDPLUS";
# 
#	server {
#		listen     localhost:110;
#		protocol   pop3;
#		proxy      on;
#	}
# 
#	server {
#		listen     localhost:143;
#		protocol   imap;
#		proxy      on;
#	}
#}
EOL




## ====================================
#ROBOTS_TXT=''
mkdir -p /var/www/${domainname}
cd /var/www/"$domainname"
# wget -O "robots.txt" "https://raw.githubusercontent.com/numbnet/WebPanel/master/WordPress/LEMP/robots.txt"
ROBOTS_TXT_DOM="/var/www/$domainname/robots.txt"
touch /var/www/$domainname/robots.txt
cat> /var/www/$domainname/robots.txt <<EOL
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

# sudo su -c 'echo "<?php phpinfo(); ?>" |tee info.php'
cd /Temp
wget -O 'wordpress.zip' https://wordpress.org/latest.zip
unzip /Temp/wordpress.zip
mv /Temp/wordpress/* /var/www/"$domainname"/
rm -rf /Temp/wordpress /Temp/wordpress.zip




## ====================================
echo "Nginx server installation completed"
TIMER
cd ~
chown www-data:www-data -R /var/www/"$domainname"
systemctl restart nginx.service




## ====================================
echo "lets install php ${phpV} and modules"
TIMER

apt-get -y install php${phpV} php${phpV}-fpm php${phpV}-mysqlnd

apt-get -y install \
  php${phpV}-common php${phpV}-mysql php${phpV}-cli php${phpV}-mbstring \
  php${phpV}-curl  php${phpV}-zip php${phpV}-xml php${phpV}-readline

apt-get -y install \
  php${phpV}-bcmath php${phpV}-opcache php${phpV}-gd php${phpV}-imap \
  php${phpV}-mcrypt php${phpV}-recode php${phpV}-soap

apt-get -y install \
  php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack






## ====================================
echo "Some php.ini tweaks"
TIMER
sed -i "s/post_max_size = .*/post_max_size = 2000M/"				/etc/php/${phpV}/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 3000M/"					/etc/php/${phpV}/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1000M/"	/etc/php/${phpV}/fpm/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 18000/"		/etc/php/${phpV}/fpm/php.ini
sed -i "s/; max_input_vars = .*/max_input_vars = 5000/"				/etc/php/${phpV}/fpm/php.ini
systemctl restart php${phpV}-fpm.service





## ====================================
echo "Instaling MariaDB"
TIMER
apt install -y mariadb-server mariadb-client
systemctl restart php${phpV}-fpm.service
mysql_secure_installation
mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Here is the database"
echo "Database:   $DB_NAME"
echo "Username:   $DB_USER"
echo "Password:   $DB_PASS"
echo "
======   DataBase   ======
Database:   $DB_NAME
Username:   $DB_USER
Password:   $DB_PASS
==========================
" > $HOME/.password.txt

TIMER

echo "Installation & configuration succesfully finished."
