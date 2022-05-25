# Don't change these
TIME_NOW=`date +%s`
LEMPress="$HOME/LEMPress"
DEFAULT_URL="new-wordpress-site.com"
URL=""
DB_NAME=""
DB_USER=""
DB_PASSWORD=""
DB_SALT=""
DB_PREFIX=""
DEFAULT_USER="deployer"
PUBLIC_IP=`curl -s http://checkip.dyndns.org | awk '{print $6}' | awk -F '<' '{print $1}'`

if [ "$USER" == "root" ]
  then
    echo -e "\033[32m Don't run this script at root. \033[0m"
    exit
  fi


# Change these if you have alternate configuration files
TMUX_CONFIG="$LEMPress/configs/tmux.conf"
FASTCGI_INIT="$LEMPress/configs/fastcgi-init.sh"

function get_website_url() {
  echo -ne "\033[32m Enter website URL [DEFAULT:new-wordpress-site.com]: \033[0m"
  read USER_URL
  if [ -z $USER_URL ]
  then
    URL=$DEFAULT_URL
  else
    URL=$USER_URL
  fi
  echo -e "\033[32m URL set to: $URL \033[0m"
}


# Upgrade

function upgrade() {
  sudo apt-get -y update
  sudo apt-get -y --force-yes upgrade
}

# Install

function install_tools() {
  sudo apt-get -y install openssh-server tmux rsync iptables wget curl build-essential python-software-properties unzip htop pwgen git-core
}

function install_new_tmux() {
  sudo apt-get -y install build-essential debhelper diffstat dpkg-dev \
  fakeroot g++ g++-4.4 html2text intltool-debian libmail-sendmail-perl \
  libncurses5-dev libstdc++6-4.4-dev libsys-hostname-long-perl po-debconf \
  quilt xz-utils libevent-1.4-2 libevent-core-1.4-2 libevent-extra-1.4-2 libevent-dev

  DOWNLOAD_URL="http://sourceforge.net/projects/tmux/files/tmux/tmux-1.6/tmux-1.6.tar.gz"
  wget -P "$HOME/tmp" $DOWNLOAD_URL
  cd "$HOME/tmp"
  tar xvvf tmux-1.6.tar.gz
  cd tmux-1.6/
  ./configure --prefix=/usr
  make
  sudo make install
}

function install_nginx() {
  sudo apt-get -y install nginx
}

function install_mysql() {
  sudo apt-get -y install mysql-server
}

function install_php() {
  sudo apt-get -y install php5-common php5-cli php5-cgi php5-mcrypt \
  php5-mysql libssh2-php php5-xcache php5-curl php5-memcache php5-tidy
  # php5-dev
  # sudo pecl install apc
}


function install_varnish() {
  sudo apt-get -y install varnish
}

function install_memcached() {
  sudo apt-get -y install memcached
  # php5-memcache
}


function install_wordpress() {
  mkdir "$HOME/tmp"
  mkdir "$HOME/sites"
  mkdir "$HOME/sites/$URL/"
  wget -P "$HOME/tmp" http://wordpress.org/latest.zip
  unzip -d "$HOME/tmp/wordpress-$TIME_NOW" "$HOME/tmp/latest.zip"
  rsync -av --progress "$HOME/tmp/wordpress-$TIME_NOW/wordpress/" "$HOME/sites/$URL/"
  mkdir "$HOME/sites/$URL/logs"
}




# Configure

function configure_virtualhost() {
  sudo rsync "$LEMPress/configs/LEMPress-virtualhost.txt" "/etc/nginx/sites-available/$URL"
  sudo sed -i "s/URL/$URL/g" "/etc/nginx/sites-available/$URL"
  sudo ln -s "/etc/nginx/sites-available/$URL" "/etc/nginx/sites-enabled/$URL"
  sudo rm "/etc/nginx/sites-enabled/default"
}

function configure_nginx() {
  sudo sed -i "s/www-data/$DEFAULT_USER/g" "/etc/nginx/nginx.conf"
  sudo service nginx restart
}

function configure_fastcgi() {
  sudo rsync "$FASTCGI_INIT" "/etc/init.d/php-fastcgi"
  sudo chmod +x "/etc/init.d/php-fastcgi"
  sudo update-rc.d php-fastcgi defaults
}

function configure_tmux() {
  rsync "$LEMPress/configs/tmux.conf" "$HOME/.tmux.conf"
}

function configure_bash() {
  rsync "$HOME/.bashrc" "$HOME/.bashrc~backup"
  rsync "$LEMPress/configs/bashrc" "$HOME/.bashrc"

  sudo rsync /root/.bashrc /root/.bashrc~backup
  sudo rsync "$LEMPress/configs/bashrc" /root/.bashrc
}

function configure_varnish() {
  sudo rsync "$LEMPress/configs/varnish" "/etc/default/varnish"
  sudo rsync "$LEMPress/configs/default.vcl" "/etc/varnish/default.vcl"
}


function create_passwords() {
  DB_NAME="`pwgen -Bs 10 1`"
  DB_USER="`pwgen -Bs 10 1`"
  DB_PASSWORD="`pwgen -Bs 40 1`"
  DB_SALT="`pwgen -Bs 80 1`"
  DB_PREFIX="`pwgen -0 5 1`_"
}

function create_db() {
  MYSQL=`which mysql`
  Q1="CREATE DATABASE IF NOT EXISTS $DB_NAME;"
  Q2="GRANT ALL ON *.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
  Q3="FLUSH PRIVILEGES;"
  SQL="${Q1}${Q2}${Q3}"

  echo -e "\033[32m Enter the MySQL password you entered earlier.  \033[0m"
  $MYSQL -uroot -p -e "$SQL"
}

function configure_wordpress() {
  rsync "$HOME/sites/$URL/wp-config-sample.php" "$HOME/sites/$URL/wp-config.php"
  sed -i "s/database_name_here/$DB_NAME/g" "$HOME/sites/$URL/wp-config.php"
  sed -i "s/username_here/$DB_USER/g" "$HOME/sites/$URL/wp-config.php"
  sed -i "s/password_here/$DB_PASSWORD/g" "$HOME/sites/$URL/wp-config.php"
  sed -i "s/put your unique phrase here/$DB_SALT/g" "$HOME/sites/$URL/wp-config.php"
  sed -i "s/wp_/$DB_PREFIX/g" "$HOME/sites/$URL/wp-config.php"

  touch "$HOME/sites/$URL/nginx.conf"

  # Sucks, I know. I'll see what I can do about this.
  chmod 777 "$HOME/sites/$URL/nginx.conf"
}


function ip_dump() {
  echo -e "" && \
  echo -e "\033[32mOk, you're all done. Point your browser at your server (URL: $URL, IP: $PUBLIC_IP) , and you should see a new wordpress site." && \
  echo -e "" && \
  echo -e "\033[32mHere's some local network information about this machine." && \
  ifconfig | grep "inet addr" && \
  echo -e "\033[0m"
}


function start_servers() {
  sudo service php-fastcgi start
  sudo service memcached start
  sudo service varnish restart
  sudo service nginx reload
  sudo service nginx start
}
