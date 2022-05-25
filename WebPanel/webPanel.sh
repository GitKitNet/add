#!/bin/bash

## -------------------------------------
##      VARIABLE
## -------------------------------------


OS="$(cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )";
release="$(cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )";

function wait {
  echo -en "\n\t\tНажмите любую клавишу для продолжения";
  read -s -n 1;
}

function title {
  clear
  echo "${title}"
  wait
}

function myip {
SHOWeth="ip addr show eth"
  ipE="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
  ipW="$(echo $(curl -s -4 icanhazip.com))";
  ipH=$(hostname -I|cut -f1 -d ' ');
## -------
  if [ "$ipE" == "$ipW" ]; then
    myip="$ipE";
  else
    if [ "$ipH" == "$ipW" ]; then
      myip="$ipH";
    else
      myip="$ipW";
    fi
  fi
  echo "${myip}"
}
myip




function WebPanel_aaPANEL {

title_sc="aapanel.sh"
title="Install aaPanel WebPanel Control"

## -------------------------------------
## Start aaPanel Install
## -------------------------------------
function StartInstall {
  title
  # ====    centos
  if [ "$OS" == 'centos' ]; then
    echo "Is $OS ..." && yum -y update && yum -y upgrade && yum -y install wget
    wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh aapanel
  else
    echo "Not centos..." && sleep 3
    # ====    Ubuntu/Deepin:
    if [ "$OS" == 'ubuntu' ]; then
      echo "Is $OS ..." && apt-get -y update && apt-get -y upgrade && apt-get -y install wget
      wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel
    else
      echo "Not ubuntu..." && sleep 3
      # ====    debian
      if [ "$OS" == 'debian' ]; then
        echo "Is $OS ..." && apt -y update && apt -y upgrade && apt -y install wget
        wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel
      else
        echo "Not debian..." && sleep 3
        # ====    Fedora
        if [ "$OS" == 'fedora' ]; then
          echo "Is $OS ..." && yum -y update && yum -y upgrade && yum -y install wget
          wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh
        else
          echo "Is $OS ..."
        fi

      fi

    fi

  fi

}

StartInstall


PASSWORD_NEW="$(</dev/urandom tr -dc 'A-Za-z0-9!#$%&?@' | head -c 22 )";
password="${PASSWORD_NEW}"
echo "Password: ${password}" >> ~/.password_panel

mv /www/server/panel/data/admin_path.pl /www/server/panel/data/admin_path.pl.bac
rm -f /www/server/panel/data/*.login
cd /www/server/panel && python tools.py panel $password

}














## #############################

## -----------------------------
##    Меню
## -----------------------------
function menu {
  clear
  echo
  echo -e "\t\t\t====  Меню Установки  ====\n"
  echo -e "\t1. "
  echo -e "\t2. "
  echo -e "\t3. Установка aaPanel"
  echo -e "\t0. Выход"
  echo -en "\t\tВведите номер раздела: "
  read -n 1 option
}
# меню.
while [ $? -ne 1 ]
do
  menu
  case $option in
    0) # Exit menu
    break
    ;;
    1) 
    ;;
    2)  
    ;;
    3) WebPanel_aaPANEL
    ;;
    *) clear && echo "Нужно выбрать раздел"
    ;;
  esac
  echo -en "\n\n\t\t\tНажмите любую клавишу для продолжения";
  read -n 1 line
done
clear
exit 1

## #############################
