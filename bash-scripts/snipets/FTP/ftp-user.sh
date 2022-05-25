# only centos

echo "Enter name of FTP user: ";
read FTPUSER;

echo "Add FTP user after 5sec"
sleep 10

ftpuser="media"

#echo -n "Enter password: "
#read ftppass
sleep 3

useradd -s /sbin/nologin $ftpuser
passwd $ftpuser
mkdir -p /etc/vsftpd/users
sleep 3

# параметры пользователя:
touch /etc/vsftpd/users/$ftpuser
echo 'local_root=/ftp/$ftpuser/' >> /etc/vsftpd/users/$ftpuser
sleep 3

# каталог и назначить ему владельца:
mkdir -p /ftp
chmod 0777 /ftp
mkdir -p /ftp/$ftpuser
chown $ftp-user. /ftp/$ftpuser/
sleep 3

# список польз. за пределы домашнего каталога:
touch /etc/vsftpd/chroot_list
# echo 'root' >> /etc/vsftpd/chroot_list

# списком польз. разрешен доступ:
touch /etc/vsftpd/user_list
echo "$ftpuser" >> /etc/vsftpd/user_list
sleep 3

# создать файл для логов:
touch /var/log/vsftpd.log
chmod 600 /var/log/vsftpd.log
sleep 3

# автозагрузку и запускаем:
systemctl enable vsftpd
systemctl start vsftpd
sleep 3

# Проверяем:
netstat -tulnp | grep vsftpd

