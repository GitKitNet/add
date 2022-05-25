mysqldump -u root -p'5Y2Wv4BfwtwiY5VnB22Ha9Z3' --all-databases | gzip > /var/hangar115-backups/mysql/mysql_backup_`date +%F`_`date +%H`_`date +%M`_backup.sql.gz
cd /var/hangar115-backups/mysql/
rm `ls -td *_backup.sql.gz | awk 'NR>50'`
