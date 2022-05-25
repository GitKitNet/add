rclone copy --ignore-existing --bwlimit 20M /var/hangar115-backups/mysql wasabi:msbackup/backups/mysql
rclone copy --ignore-existing --bwlimit 20M /var/hangar115-backups/config wasabi:msbackup/backups/config
rclone copy --ignore-existing --bwlimit 20M /var/hangar115-backups/www wasabi:msbackup/backups/www
