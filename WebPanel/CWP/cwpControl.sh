#!/bin/bash


## --------------------------
##  Centos Web Panel Control
## --------------------------

title="Install Centos Web Panel Control";


# ---------------------------
# VARIABLE
function wait { echo -en "\n\t\tНажмите любую клавишу для продолжения";read -s -n 1; }

function OSandREL() {
if [ -z "$1" ]; then echo "$OS $release" fi
OS="$(cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )";
release="$(cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )";

}
function title() { clear; title="Start now "; wait; }



function MyIP
{
IP_ADDR_ETH="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
IP_ICANHAZIP="$(echo $(curl -4 icanhazip.com))";
IP_MY=$(hostname -I|cut -f1 -d ' ');
## ======
if [ "$IP_ADDR_ETH" == "$IP_ICANHAZIP" ]; then
  myip="$IP_ADDR_ETH";
  echo "Внешний ip (eth0): $myip";
else
  if [ "$MY_IP" == "$IP_ICANHAZIP" ]; then
    myip="$MY_IP";
    echo "Внешний ip (hostname): $myip";
  else
    myip="$IP_ICANHAZIP";
    echo "Внешний ip (icanhazip.com): $myip";
  fi;
fi
}
# echo ${OS} ${release}

function TIMER_RUN {
  SE=$((1 * 10)) && RE='\033[0K\r';
  while [ $SE -gt 0 ]; do
     echo -ne "Exit after \t $SE$RE";
     sleep 1
     : $((SE--))
  done
}

function DATA_READ {

    #echo -e "${GREEN}Adding user & database for owncloud${NC}"
    #echo -e "Please, set username for database: "
    #read DB_USER
    DB_USER="owncloud"
    DB_NAME="owncloud"

    #echo -e "Please, set password for database user: "
    #read DB_PASS
    DB_PASS="htjXAaTk@qGcpkfAcH"

    echo -e "Please, set username for ADMIN: "
    read ADMIN_NAME

    echo -e "Please, set password for ADMIN: "
    read ADMIN_PASS
    
    echo -en "admin name: $ADMIN_NAME\n admin password: $ADMIN_PASS\n\nDatabase Name: $DB_NAME\n Database user: $DB_USER\n Database password: $DB_PASS" >> ~/SetUpinfo.txt;
}



function startInstall {

#!/bin/bash

# Required for servers using other lang
LANG=en_US.UTF-8

########################################################################
# Use of code or any part of it is strictly prohibited. File protected by copyright law and provided under license.
# To Use any part of this code you need to get a writen approval from the code owner: info@centos-webpanel.com
########################################################################
#
# CWP instaler for CentOS 6, 7, 8
#
########################################################################

#link='https://dl1.centos-webpanel.com/files/cwp-el8-latest'
LINK8='https://raw.githubusercontent.com/numbnet/WebPanel/master/CWP/cwp-el8-latest.sh'
LINK7='https://raw.githubusercontent.com/numbnet/WebPanel/master/CWP/cwp-el7-latest.sh'
LINK6='https://raw.githubusercontent.com/numbnet/WebPanel/master/CWP/cwp-el6-latest.sh'

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   sleep 10 && exit 1
fi

# Check for unsupported Operating systems
arch=$(uname -m)
#centosversion=`rpm -qa \*-release | grep -Ei "oracle|redhat|centos|cloudlinux" | cut -d"-" -f3`
centosversion=`rpm -qa \*-release | grep -Ei "oracle|redhat|centos|cloudlinux" | cut -d"-" -f3|sed 's/\..$//'`

if [[ $arch == "i686" ]]; then
    echo "Unsupported Operating system, please use CentOS 8.x 64bit"
    sleep 10 && exit 1
elif [[ $arch == "armv7l" ]]; then
    echo "Unsupported Operating system, please use CentOS 8.x 64bit"
    sleep 10 && exit 1
fi


if [ $centosversion -eq "8" ]; then
    echo "Supported Operating system"
    bash -c $(curl -LSs ${LINK8})
elif [[ $centosversion -eq "7" ]]; then
    echo "Supported Operating system"
    bash -c $(curl -LSs ${LINK7})
elif [[ $centosversion -eq "6" ]]; then
    echo "Supported Operating system"
    bash -c $(curl -LSs ${LINK6})
elif [[ $centosversion -eq "5" ]]; then
    echo "Unsupported Operating system, please use CentOS [6, 7, 8] 64bit"
    sleep 10 && exit 1
fi

}




