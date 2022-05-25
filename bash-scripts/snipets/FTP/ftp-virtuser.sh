#!/bin/sh

echo -n "Enter name of virtual user: "
read virtuser

echo -n "Enter password: "
read virtpass

mkdir /ftp/$virtuser
chown ftp. /ftp/$virtuser
touch /etc/vsftpd/users/$virtuser

echo "$virtuser" >> /etc/vsftpd/virt_users
echo "$virtpass" >> /etc/vsftpd/virt_users

db_load -T -t hash -f /etc/vsftpd/virt_users /etc/vsftpd/virt_users.db
