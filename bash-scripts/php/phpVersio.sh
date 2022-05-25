
function PHP_INSTALL() {

# Add required repositories
sudo add-apt-repository -y ppa:ondrej/php

#======================
	if [ "$PHP70_INSTALL" = "y" ]; then

		echo "##########################################"
		echo -e "\t Installing php7.0-fpm   "
		echo "##########################################"

		sleep 2;
		sudo apt install php7.0 php7.0-fpm php7.0-mysqlnd -y
		sudo apt-get -y install php7.0-curl php7.0-gd php7.0-imap php7.0-mcrypt php7.0-readline \
			php7.0-common php7.0-recode php7.0-mysql php7.0-cli php7.0-curl php7.0-soap php7.0-mbstring \
			php7.0-bcmath php7.0-mysql php7.0-opcache php7.0-zip php7.0-xml \
			php-memcache memcached graphviz php-pear php-xdebug php-msgpack php-memcached php-imagick

		echo "Some php.ini tweaks"
		sleep 2;
		sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.0/fpm/php.ini
		sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.0/fpm/php.ini
		sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1000M/" /etc/php/7.0/fpm/php.ini
		sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.0/fpm/php.ini
		sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.0/fpm/php.ini
		sudo systemctl restart php7.0-fpm.service
	fi

#======================
	if [ "$PHP71_INSTALL" = "y" ]; then

		echo "##########################################"
		echo -e "\t Installing php7.1-fpm   "
		echo "##########################################"



	fi

#======================
	if [ "$PHP72_INSTALL" = "y" ]; then

		echo "##########################################"
		echo -e "\t Installing php7.2-fpm   "
		echo "##########################################"

		sleep 2;
		sudo apt install php7.2 php7.2-fpm php7.2-mysql -y
		sudo apt-get -y install php7.2-curl php7.2-cli php7.2-curl php7.2-zip php7.2-common \
			php7.2-xml php7.2-mbstring php7.2-readline php7.2-intl php7.2-gd php7.2-recode \
			php7.2-imap php7.2-bcmath php7.2-opcache php7.2-soap
		sudo apt-get -y install php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack

		echo "Some php.ini Tweaks"
		sleep 2;
		sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.2/fpm/php.ini
		sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.2/fpm/php.ini
		sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.2/fpm/php.ini
		sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.2/fpm/php.ini
		sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.2/fpm/php.ini
		sudo systemctl restart php7.2-fpm.service
	fi

#======================
	if [ "$PHP73_INSTALL" = "y" ]; then

		echo "##########################################"
		echo -e "\t Installing php7.3-fpm   "
		echo "##########################################"

		sleep 2;
		sudo apt install php7.3 php7.3-fpm php7.3-mysql -y
		sudo apt-get -y install php7.3-xml php7.3-bz2 php7.3-zip php7.3-intl \
			php7.3-gd php7.3-curl php7.3-soap php7.3-mbstring php7.3-bcmath
		#cp -rf $HOME/ubuntu-nginx-web-server/etc/php/7.3/* /etc/php/7.3/
		service php7.3-fpm restart

		echo "Some php.ini Tweaks"
		sleep 2;
		sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.3/fpm/php.ini
		sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.3/fpm/php.ini
		sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.3/fpm/php.ini
		sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.3/fpm/php.ini
		sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.3/fpm/php.ini
		sudo systemctl restart php7.3-fpm.service
	fi

#======================
	if [ "$PHP74_INSTALL" = "y" ]; then

		echo "##########################################"
		echo -e "\t Installing php7.4-fpm   "
		echo "##########################################"

		sleep 2;
		sudo apt install php7.4 php7.4-fpm php7.4-mysql -y
		sudo apt-get -y install php7.4-curl php7.4-gd php7.4-zip php7.4-sqlite3 php7.4-pgsql \
			php7.4-bz2 php7.4-mbstring php7.4-soap php7.4-xml php7.4-json php7.4-dev \
			php7.4-imap php7.4-tidy php7.4-gmp php7.4-bcmath
		sudo service php7.4-fpm restart

		echo "Some php.ini Tweaks"
		sleep 2;
		sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.4/fpm/php.ini
		sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.4/fpm/php.ini
		sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.4/fpm/php.ini
		sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.4/fpm/php.ini
		sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.4/fpm/php.ini
		sudo systemctl restart php7.4-fpm.service
	fi

#======================
	if [ "$PHP80_INSTALL" = "y" ]; then

		echo "##########################################"
		echo -e "\t Installing php8.0-fpm   "
		echo "##########################################"

		sleep 2;
		sudo apt install php8.0 php8.0-fpm php8.0-mysql -y
		sudo apt-get -y install php8.0-cli php8.0-sqlite3 php8.0-opcache php8.0-readline php8.0-xml \
			php8.0-curl php8.0-zip php8.0-gd php8.0-pgsql php8.0-bz2 php8.0-mbstring php8.0-soap \
			php8.0-dev php8.0-imap php8.0-tidy php8.0-gmp php8.0-bcmath 
		sudo service php8.0-fpm restart


		echo "Some php.ini Tweaks"
		sleep 2;
		sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/8.0/fpm/php.ini
		sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/8.0/fpm/php.ini
		sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.0/fpm/php.ini
		sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/8.0/fpm/php.ini
		sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/8.0/fpm/php.ini
		sudo systemctl restart php8.0-fpm.service

	fi
}


