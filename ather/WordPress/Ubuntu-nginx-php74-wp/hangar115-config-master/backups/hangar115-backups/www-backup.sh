tar -czvf /var/hangar115-backups/www/www_backup_`date +%F`_`date +%H`_`date +%M`_backup.tar.gz /var/www
cd /var/hangar115-backups/www/
rm `ls -td *_backup.tar.gz | awk 'NR>2'`
