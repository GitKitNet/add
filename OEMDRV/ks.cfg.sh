##################################### ks.cfg #####################################

# version=DEVEL
	
	## System authorization information
auth --enableshadow --passalgo=sha512

	## Install OS instead of upgrade
install

	## Reboot after installation
reboot --eject

	## License agreement
eula --agreed



	################################################
	####    -Источник установки CDROM, СЕТЬ-    ####
	################################################

	## Use CDROM installation media  ##
cdrom
	## Use network installation  ##
	# url --url="https://mirror.yandex.ru/centos/7/os/x86_64"
	# url --url="http://mirror.mirohost.net/centos/7/os/x86_64"
	# url --url="http://mirrors.bytes.ua/centos/7/os/x86_64"


	## Use graphical install
	# graphical
	## Use text mode install
text


	## Run the Setup Agent on first boot ###
firstboot --enable
ignoredisk --only-use=sda
group --name=ftp


	################################################
	####          -Языки, Раскладка-            №###
	################################################

	## Keyboard layouts
keyboard --vckeymap=us --xlayouts='us','ru' --switch='grp:ctrl_shift_toggle'

	## System language
lang ru_UA.UTF-8


	################################################
	##   -Опция сетевого подключения, hostname-  ###
	################################################

	## Network information ##
	# network  --bootproto=static --device=eth0 --gateway=192.168.1.2 --ip=192.168.1.10 --nameserver=192.168.1.2 --netmask=255.255.255.0 --ipv6=auto --activate
	# network  --bootproto=static --device=enp1s6 --gateway=192.168.1.2 --ip=192.168.1.10 --nameserver=192.168.1.2 --netmask=255.255.255.0 --ipv6=auto --activate
	# network  --bootproto=dhcp --device=enp1s6 --ipv6=auto --activate
network  --bootproto=dhcp --ipv6=auto --activate
network  --hostname=localhost.localdomain


	################################################
	####  -Затем идут параметры пользователей-  ####
	################################################
	
	## rootpw —lock — запрет подключения к серверу root-ом
	## Root password ###
	# rootpw --lock
rootpw --iscrypted $6$2BwJm420ktkyORqz$Wwha.a6XczjBH4k1lDwtEpsF/.wUsejcUyMcz3Enf9giL22yvyTSfZiek3ZQrqAs8jjd2wvQGqn8bkPqdpMfH/

user --groups=wheel,ftp --name=admin --password=$6$tQW19FtNcfZrsrbZ$j2Hnn4/9MMEmXZd9BP81p21SD6zky6uLk9xq.wYavfx.6q2ea3zfIRD.RGgONwnc6EZP9nhQpCsAN3OByW2o91 --iscrypted --gecos="Admin"
	
	## Пароль пользователя root и админ можно сгенерировать заранее";
	#$ python -c "import crypt,random,string; print crypt.crypt(\"my_password\", '\$6\$' + ''.join([random.choice(string.ascii_letters + string.digits) for _ in range(16)]))" ;



	################################################
	####          -Add ssh user key-            ####
	################################################

sshkey --username=admin "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3nyIJFszoNVmLolr3gV+yOJyCT+0ImsOH/C3rZloR4 admin"
sshkey --username=root "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp3bxeApwQec9N6DaIP1Iq3o7Ks4jcL66wHi1YdqkFC root"


	## System services ###
	# services --disabled=autofs,alsa-state,avahi-daemon,bluetooth,pcscd,cachefilesd,colord,fancontrol,fcoe,firewalld,firstboot-graphical,gdm,httpd,initial-setup,initial-setup-text,initial-setup-graphical,initial-setup-reconfiguration,kdump,libstoragemgmt,ModemManager,tog-pegasus,tmp.mount,tuned \
	# --enabled=bacula-fd,chronyd,edac,gpm,numad,rsyslog,sendmail,smartd,sm-client,sssd,zabbix-agent		services --disabled=NetworkManager
services --enabled="chronyd"

	## System timezone
timezone Europe/Kiev --isUtc --ntpservers=192.168.1.2,ua.pool.ntp.org

	## Firewall rule ##
	# firewall --enabled --port=22822:tcp
	# firewall --disabled --service=ssh

	## System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda


	################################################
	####   -Partition clearing information-     ####
	################################################

	## Повторном инициализировании диска (Рекоменд. при авто установке)
zerombr

	##  Все разделы будут очищены на диске sda
clearpart --all --initlabel --drives=sda
	# clearpart --none --initlabel



	################################################
	####           -разбивка диска-             ####
	################################################

	## Disk partitioning information ##
	# part pv.374 --fstype="lvmpv" --ondisk=sda --size=297046
	# grow - Эта команда указывает установщику anaconda создать максимально большой раздел.
	# pv.01 - не используется после установки

part pv.01 --fstype="lvmpv" --ondisk=sda --size=1024 --grow
part /boot --fstype="xfs" --ondisk=sda --size=8196 --label=BOOT
part biosboot --fstype="biosboot" --ondisk=sda --size=2
part pv.374 --fstype="lvmpv" --ondisk=sda --size=297046 --grow
volgroup nnserver --pesize=4096 pv.01
logvol swap  --fstype="swap" --size=8192 --name=swap --vgname=nnserver
logvol /  --fstype="xfs" --maxsize=102400 --size=102400 --label="ROOT" --name=root --vgname=nnserver
logvol /home  --fstype="xfs" --size=186449 --grow --label="HOME" --name=home --vgname=nnserver



	################################################
	####      -3. Package installation-         ####
	################################################

	##    -установленные / удаленные (-) пакеты-    ##
	# url --url="http://mirror.mirohost.net/centos/7/os/x86_64/"
	# url --url="http://centos.ip-connect.vn.ua/7/os/x86_64/"
	# url --url="http://mirrors.bytes.ua/centos/7/os/x86_64/"
	# url --url="https://mirror.yandex.ru/centos/7/os/x86_64/"
	# repo --install --name="CentOS" --baseurl="http://mirror.centos.org/centos/7/os/x86_64/"
	# repo --name="CentOS" --baseurl="https://mirror.yandex.ru/centos/7/os/x86_64/"
	# repo --name="EPEL" --baseurl="https://dl.fedoraproject.org/pub/epel/7/x86_64/"
	# repo -–name="EPEL" -–baseurl="http://download.fedoraproject.org/pub/epel/7/x86_64/"
	# repo --install --name="ELRepo" --baseurl="http://mirror.mirohost.net/centos/7/extras/x86_64/Packages/elrepo-release-7.0-4.el7.elrepo.noarch.rpm"
	# repo --install --name="ELRepo" --baseurl="http://mirror.mirohost.net/centos/7/extras/x86_64/"
	# repo --install --name="EPEL" --baseurl="http://mirror.mirohost.net/centos/7/extras/x86_64/"
	# repo --name="CentOS" --baseurl="http://mirror.mirohost.net/centos/7/os/x86_64/"
	# repo --name="EPEL" --baseurl="https://dl.fedoraproject.org/pub/epel/7/x86_64/"
	# repo -–name="EPEL" -–baseurl="http://mirror.mirohost.net/centos/7/os/x86_64/"
	# repo -–name="ELRepo" -–baseurl="http://mirror.mirohost.net/centos/7/extras/x86_64/"
	# repo -–name="elrepo" -–baseurl="https://elrepo.org/linux/elrepo/el7/x86_64/"


%packages
@^minimal
@core
	# @base
	# @web-server
	# @^web-server-environment
	# @system-admin-tools
	# @php
	# @debugging
	# @compat-libraries
	# @guest-agents
chrony
kexec-tools
sudo

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

%post
	# yum install -y policycoreutils-python
echo "admin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/admin

	## Change ssh port
	# /usr/bin/sed -i "s%#Port 22%Port 43389%g" "/etc/ssh/sshd_config"
	# /usr/bin/sed -i "s%#PermitRootLogin yes%PermitRootLogin no%g" "/etc/ssh/sshd_config"
	# /sbin/semanage port -a -t ssh_port_t -p tcp 22822
	# /usr/bin/firewall-cmd --permanent --zone=public --remove-service=ssh
%end