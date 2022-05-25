if [[ "$EUID" -ne 0 ]]; then
    echo -e "Sorry, you need to run this as root"
    exit 1
fi

clear
#echo ""
#read -p "Please enter a root MySQL and server password: " MYSQL_PASS;
#while [[ -z "$MYSQL_PASS" ]]; do
#    read -p "Please enter a root MySQL and server password: " MYSQL_PASS;
#done

echo ""
echo ""
echo ""

# Change server root password
#echo root:"$MYSQL_PASS" | chpasswd

# Set the timezone
sudo timedatectl set-timezone America/New_York # Africa/Cairo

# Fix environment
echo 'LC_ALL="en_US.UTF-8"' >> /etc/environment

# Add required repositories
sudo add-apt-repository -y ppa:ondrej/php # PHP 7.4
sudo add-apt-repository -y ppa:certbot/certbot # Let's Encrypt Certbot
sudo add-apt-repository -y ppa:teejee2008/ppa # Ukuu

wget -O - http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -cs) nginx"
#sudo add-apt-repository -y ppa:jonathonf/ffmpeg-4 # FFMPEG 4

sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc' # MariaDB 10.5
sudo add-apt-repository "deb [arch=amd64] http://mariadb.mirror.liquidtelecom.com/repo/10.5/ubuntu $(lsb_release -cs) main" # MariaDB 10.5

# GoAccess
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list

# Essentials
sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y install mc htop curl zip unzip build-essential tcl git fail2ban software-properties-common build-essential nasm autotools-dev autoconf libjemalloc-dev tcl tcl-dev uuid-dev goaccess

# Install Python
sudo apt-get -y install python3
cd /var
mkdir pip
cd pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
echo ""

# Install Let's Encypt and its Certbot
sudo apt-get -y install nginx certbot python3-certbot-nginx
#pip install certbot-nginx

# Install MariaDB
sudo apt-get -y install mariadb-server
sudo service mysql stop
#sudo mysql_secure_installation

# Install PHP 7.4-FPM
sudo apt-get -y install php7.4 php7.4-fpm php7.4-curl php7.4-gd php7.4-json php7.4-mysql php7.4-sqlite3 php7.4-pgsql php7.4-bz2 php7.4-mbstring php7.4-soap php7.4-xml php7.4-zip php7.4-dev php7.4-imap php7.4-tidy php7.4-gmp php7.4-bcmath

# Install PHP's Composer
sudo apt-get -y install composer
#php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#php composer-setup.php
#php -r "unlink('composer-setup.php');"

# Install NPM
sudo apt-get -y install npm

# Install Redis and PHP-Redis
#sudo apt-get -y install redis-server php-redis

# Add auto DB Backup and auto Database Optimization scripts
#sudo touch /var/mysqlbackups/mysqlbackup.sh
#echo "mysqldump -u root -p$MYSQL_PASS --all-databases | gzip > /var/mysqlbackups/linkyouonline_`date +%F`_`date +%H`_`date +%M`.sql.gz" >> /var/mysqlbackups/mysqlbackup.sh

# Add Auto Backups scripts
cp -rf backups/* /var/

# Make sure that the .sh-s can run.
sudo chmod +x /var/hangar115-backups/mysql-backup.sh
sudo chmod +x /var/hangar115-backups/www-backup.sh
sudo chmod +x /var/hangar115-backups/config-backup.sh

sudo crontab -l > mysql_backup
echo "0 */4 * * * /var/hangar115-backups/mysql-backup.sh" >> mysql_backup
sudo crontab mysql_backup
sudo rm mysql_backup

sudo crontab -l > www_backup
echo "2 */6 * * * /var/hangar115-backups/www-backup.sh" >> www_backup
sudo crontab www_backup
sudo rm www_backup

sudo crontab -l > config_backup
echo "4 */6 * * * /var/hangar115-backups/config-backup.sh" >> config_backup
sudo crontab config_backup
sudo rm config_backup

echo ""
echo "Backups set."
echo ""
# Cron jobs end.

# Certbot Configure Auto Renewal
sudo certbot renew --dry-run

# Restart PHP 7.4-FPM
sudo service php7.4-fpm restart

# MySQL Secure Installation
sudo mysql_secure_installation

# Restart MySQL (MariaDB)
sudo service mysql restart

# Finish MySQL Installation replacing 'mysql_secure_installation'
#sudo mysqladmin -u root password "$MYSQL_PASS"
#sudo mysql -u root -p"$MYSQL_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_PASS') WHERE User='root'"
#sudo mysql -u root -p"$MYSQL_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
#sudo mysql -u root -p"$MYSQL_PASS" -e "DELETE FROM mysql.user WHERE User=''"
#sudo mysql -u root -p"$MYSQL_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
#sudo mysql -u root -p"$MYSQL_PASS" -e "FLUSH PRIVILEGES"

# Raise Filelimit to Sky-High
sudo sh -c "ulimit -n 777777777777777 && exec su $LOGNAME"
sudo touch /etc/sysctl.conf
echo "fs.file-max = 777777777777777" >> /etc/sysctl.conf

# Remove Telnet
sudo apt-get -y remove telnet

# IP Tables #disabled for now - see UFW
#sudo iptables-restore < copy/iptables_secure.conf

# Enable Firewall #Not needed as of now
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
#sudo ufw deny out 25 #Deny SMTP
sudo ufw default deny incoming
sudo ufw default allow outgoing
echo "y" | sudo ufw enable

# Check Updates
sudo apt-get -y update
sudo apt-get -y dist-upgrade

# Install NGINX and compile its modules
sudo chmod +x nginx/nginx-autoinstall.sh
sudo bash nginx/nginx-autoinstall.sh #Stable option recommended
nginx -v

# Kerel Security
# + Configure PHP 7.4, PS-Watcher, Redis and MySQL (MariaDB)
yes | cp -rf configs/* /etc/

# Refresh sysctl.conf
sudo sysctl -p

# Configure NGINX
yes | cp -rf nginx_config/* /etc/

# Restart services
#sudo /etc/init.d/redis-server restart
sudo service php7.4-fpm restart
sudo service mysql restart
sudo service nginx restart

#Install mysqltuner
sudo apt-get -y install mysqltuner

# Install Ukuu
# + build new kernel
sudo apt-get -y install ukuu
sudo ukuu --install-latest

# Install PS-Watcher
sudo apt-get -y install ps-watcher

# Install latest YouTube-DL
#sudo apt-get -y install youtube-dl
#sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/bin/youtube-dl
#sudo chmod a+rx /usr/bin/youtube-dl

# Install FFMPEG 4
#sudo apt-get -y install ffmpeg

# Install RClone
curl https://rclone.org/install.sh | sudo bash

# Create sudo user (hangar)
#sudo adduser hangar --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
#echo "hangar:$MYSQL_PASS" | sudo chpasswd
#sudo usermod -aG sudo hangar

# Make sure to install security updates automatically
sudo apt-get -y install unattended-upgrades needrestart debsecan debsums
echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\nUnattended-Upgrade::Automatic-Reboot \"false\";\n" > /etc/apt/apt.conf.d/20auto-upgrades
sudo /etc/init.d/unattended-upgrades restart


cd /var
mkdir nginx-cache
cd nginx-cache
mkdir proxy

# Create NGINX site cache directories
mkdir pagespeed-cache
chown -R www-data:www-data /var/nginx-cache

sudo ukuu --install-latest

echo "Please run 'mysql_secure_installation' and then 'reboot' the server."
exit

#reboot

#exit
