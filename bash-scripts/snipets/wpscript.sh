#!/bin/bash
# wget https://raw.githubusercontent.com/numbnet/WebPanel/master/snipets/wpscript.sh && chmod +x wpscript.sh && ./wpscript.sh

function Updating_OS() {
echo "Updating OS................."
apt-get update
apt install pwgen -y

}

## ==============================
## VARIABLE && FUNCTION

function wait { 
  read -p "Press [ANY] key to continue ..." -s -n 1
}

function pause() {
  read -p "Press [Enter] key to continue ..." fackEnterKey;
}
function title {
  clear;
  echo "${title}";
  wait;
}
## TIMER
function TIMER() {
  T=$1
  if [ -z "${T}" ]; then 
    T=9
  fi
  secs="$((1 * ${T}))"
  
  while [ $secs -gt 0 ]; do
    echo -ne "\tContinue, after: $secs\033[0K\r"
    sleep 1 && : $((secs--))
  done
}


## ==============================
function ADD_NEW() {
TIMER
echo "Domain Name (eg. example.com)?" && read DOMAIN

## ----------     GENERATE     ---------- ## 
PASS_GENERATE=`pwgen -s 22 1`
WP_PASS_GEN="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 22 )"
DB_PASS_GEN="$(</dev/urandom tr -dc 'A-Za-z0-9' |head -c 28 )"
DB_NAME_GEN="$( echo ${DOMAIN} | sed 's/\.//g' )"


# echo "WordPress Username (eg. admin)?" && read WP_USERNAME
# echo "WordPress Password (eg. pass )?" && read WP_PASS
# echo "Username DataBase (eg. domain_user)?" && read DB_USERNAME
# echo "Name DataBase (eg. domain_db)?" && read DB_DBNAME
# echo "DataBase password: " && read DB_PASS

WP_USERNAME="root"
WP_PASS="${WP_PASS_GEN}"

DB_DBNAME="db_${DB_NAME_GEN}"
DB_USERNAME="${DB_NAME_GEN}_u"
DB_PASS="${DB_PASS_GEN}"


echo "NGINX ..."
cd /etc/nginx/sites-available/
NGINX_DEFAULT='/etc/nginx/sites-available/default'
touch $NGINX_DEFAULT
cat> $NGINX_DEFAULT <<EOF
server {
	listen 443 ssl http2;
	listen [::]:443 ssl http2;
	root /var/www/example.com;
	index index.html index.htm index.php;
	server_name example.com www.example.com;
	location / {
		#try_files $uri $uri/ =404;
		try_files $uri $uri/ /index.php?q=$uri&$args;
	}
	rewrite ^/sitemap.xml$ /index.php?aiosp_sitemap_path=root last;
	rewrite ^/sitemap_(.+)_(\d+).xml$ /index.php?aiosp_sitemap_path=$1&aiosp_sitemap_page=$2 last;
	rewrite ^/sitemap_(.+).xml$ /index.php?aiosp_sitemap_path=$1 last;
	location ~* \.(txt|xml|js)$ {
		expires 8d;
	}
	location ~* \.(css)$ {
		expires 8d;
	}
	location ~* \.(flv|ico|pdf|avi|mov|ppt|doc|mp3|wmv|wav|mp4|m4v|ogg|webm|aac|eot|ttf|otf|woff|svg)$ {
		expires 8d;
	}
	location ~* \.(jpg|jpeg|png|gif|swf|webp)$ {
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
EOF

sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/
echo "Setting up Wordpress With Cloudflare FULL SSL"
TIMER
mkdir -p /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"
ROBOTS_TXT="/var/www/"$DOMAIN"/robots.txt"
touch $ROBOTS_TXT
cat> $ROBOTS_TXT <<EOF
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
EOF


su -c 'echo "<?php phpinfo(); ?>" |tee info.php'
mkdir -p '/temp' && cd /temp
wget -O wordpress.zip 'wordpress.org/latest.zip'
unzip wordpress.zip
mv wordpress/* /var/www/"$DOMAIN"/
rm -rf wordpress wordpress.zip
echo "Nginx server installation completed"
TIMER

cd /var/www/"${DOMAIN}"
chown www-data:www-data -R /var/www/"$DOMAIN"
systemctl restart nginx.service


mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $DB_DBNAME;
CREATE USER '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_DBNAME.* TO '$DB_USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

}

echo "Here is the database"
echo "Database:   $DB_DBNAME"
echo "Username:   $DB_USERNAME"
echo "Password:   $DB_PASS"
