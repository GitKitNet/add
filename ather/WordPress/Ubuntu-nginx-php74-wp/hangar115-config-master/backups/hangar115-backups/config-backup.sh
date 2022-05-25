history > /var/log/bash_print.log
tar --ignore-failed-read -czvf /var/hangar115-backups/config/config_backup_`date +%F`_`date +%H`_`date +%M`_backup.tar.gz /etc/nginx /etc/php /etc/redis /etc/mysql /var/log/ufw.log /var/log/fail2ban.log /var/log/kern.log /var/log/auth.logauth.log /var/log/syslog /var/log/apt/history.log /var/log/bash_print.log /var/log/dpkg.log
cd /var/hangar115-backups/config/
rm `ls -td *_backup.tar.gz | awk 'NR>25'`
