sudo dnf clean all
sudo dnf update


# cd /etc/yum.repos.d/

cat > /etc/yum.repos.d/plex.repo << EOF
[PlexRepo]
name=PlexRepo
baseurl=https://downloads.plex.tv/repo/rpm/$basearch/
enabled=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
gpgcheck=1

EOF


mkdir -p /temp && cd /temp
wget https://github.com/numbnet/unix/releases/download/v1.24.3/plexmediaserver-1.24.3.5033-757abe6b4.x86_64.rpm
yum -y install plexmediaserver-1.24.3.5033-757abe6b4.x86_64.rpm

yum -y install plexmediaserver
dnf -y install plexmediaserver
yum -y install 


systemctl start plexmediaserver
systemctl enable plexmediaserver
systemctl status plexmediaserver

sleep 5

# sudo yum -y install firewalld
# systemctl start firewalld
# systemctl enable firewalld


## Next, we need to add new firewalld configuration for our plex installation. Plex media server needs some port in the 'LISTEN' state, so we will create new firewalld XML configuration.

## Go to the '/etc/firewalld/service' directory and create a new service firewalld configuration 'plex.xml' using vim

cat >> /etc/firewalld/services/plexmediaserver.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>plexmediaserver</short>
  <description>Ports required by plexmediaserver.</description>
  <port protocol="tcp" port="32400"></port>
  <port protocol="udp" port="1900"></port>
  <port protocol="tcp" port="3005"></port>
  <port protocol="udp" port="5353"></port>
  <port protocol="tcp" port="8324"></port>
  <port protocol="udp" port="32410"></port>
  <port protocol="udp" port="32412"></port>
  <port protocol="udp" port="32413"></port>
  <port protocol="udp" port="32414"></port>
  <port protocol="tcp" port="32469"></port>
</service>
EOF


#Now add the 'plexmediaserver' service to the firewalld services list, then reload the configuration

# sudo firewall-cmd --add-service=plexmediaserver --permanent
# sudo firewall-cmd --reload


## The plexmediaserver service has been added to firewalld - check it using the firewalld command below.
# firewall-cmd --list-all


mkdir -p /opt/plexmedia/{movies,series}
chown -R plex: /opt/plexmedia

### Добавление ваших библиотек

mkdir -p /plex_media/movies
chown -R plex: /plex_media/movies
