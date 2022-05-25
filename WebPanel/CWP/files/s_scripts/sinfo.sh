#!/bin/bash
#
# CentOS Web Panel Detection Script for Support
#

if [ ! -e "/usr/sbin/virt-what" ]; then
	yum -y -q install virt-what
fi

echo ===============================================
echo "Kernel:"
uname -a

echo
echo "CPU info:"
grep "model name" /proc/cpuinfo |head -n1

echo
echo "Release:"
cat /etc/redhat-release

echo
echo "Arch:"
arch

echo
echo "Virtualization Type:"
virt-what

echo
echo "Memory:"
free -m

echo
echo "MySQL info:"
mysql --version

echo
echo "Disk Info:"
df -h
echo
cat /etc/fstab

echo
echo "Apache PHP info:"
/usr/local/bin/php -v

echo 
echo "Apache start script check:"
grep "httpd=" /etc/init.d/httpd

if [ -e "/usr/local/cwpsrv/htdocs/admin" ];then
	echo
	echo "CWP Admin check:"
	echo "/usr/local/cwpsrv/htdocs/admin"
	echo
	echo "CWP version:"
	/usr/local/cwp/php71/bin/php /scripts/cwp_version
	echo
fi

echo ===============================================
