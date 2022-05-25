#!/bin/bash

# LINK="raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/module/pureftp.sh"; bash <(curl -fsSL $LINK || wget -O - $LINK)

# -------------------------------------
#      Colors settings
# -------------------------------------
GREEN='\033[32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
YELOW='\033[1;33m'
PURPLE='\033[0;4;35m'
CYAN='\033[4;36m'
BLACK='\033[40m'
TEXTCOLOR=$GREEN
BGCOLOR=$BLACK
NC='\033[0m'

#===================================================

clear
echo -e "${GREEN}Welcome to Pure-FTP Auto Installer Script${NC}"
echo ""

if [ "$(whoami)" != "root" ]; then
  echo -e "${RED}This script must be run as root${NC}"
  sleep 5
  exit
fi

if [ -e /etc/debian_version ]; then
  if [ -e /etc/pure-ftpd ]; then
    while :
    do
      echo -en "${GREEN}\nPure-FTP IS already INSTALLED.\n${NC}"
      echo ""
      echo -en "\n1) ${YELOW}Add a new user${NC}"
      echo -en "\n2) ${YELOW}Change a user password${NC}"
      echo -en "\n3) ${RED}Delete a user${NC}"
      echo -en "\n4) ${PURPLE}Remove Pure-FTP and configurations${NC}"
      echo -en "\n5) ${RED}Exit... ${NC}"
      echo -en "\n${BLUE} Select an Option: ${NC}" && read option
      case $option in
      
        1) # ADD NEW USER
          read -p "Enter a Username: " -e ADDUSERNAME
          read -p "Enter $ADDUSERNAME’s password: " -e ADDPASSWORD
          read -p "Enter $ADDUSERNAME’s directory: " -e -i /home/$ADDUSERNAME ADDUSERDIR
          read -p "Is this an http user? [y/n]: " -e HTTP
          echo ""
          echo "${GREEN}The User is creating now... Please wait."
          echo ""
          if [ "$HTTP" = "y" ]; then
            echo -e "$ADDPASSWORD\\n$ADDPASSWORD" | pure-pw useradd $ADDUSERNAME -u www-data -d $ADDUSERDIR
          else
            if [ "$HTTP" = "n" ]; then
              echo -e "$ADDPASSWORD\\n$ADDPASSWORD" | pure-pw useradd $ADDUSERNAME -u $ADDUSERNAME -d $ADDUSERDIR
            else
              echo "${YELOW}Please enter [y/n] ...${NC}"
              #exit
            fi
          fi
          pure-pw mkdb
          if [ -e /etc/init.d/pure-ftpd ]; then
            /etc/init.d/pure-ftpd restart
          else
            echo "${RED}Pure-FTP is not working properly. Please remove and Re-install it.${NC}"
            exit
          fi
          exit
        ;;
        2) #Change a user password
          read -p "Enter the username: " -e CHNUSERNAME
          read -p "Enter password: " -e CHNPASSWORD
          echo -e "$CHNPASSWORD\\n$CHNPASSWORD" | pure-pw passwd $CHNUSERNAME -m
          pure-pw mkdb
          exit
        ;;
        3) #Delete a user
          read -p "Enter the username: " -e DELUSERNAME
          read -p "Are you sure? [y/n]: " -e -i n TTT
          if [ "$TTT" = "y" ]; then
            pure-pw userdel $DELUSERNAME -m
            pure-pw mkdb
          else
            echo "Closing now.."
            exit
          fi
          exit
        ;;
        4) read -p "Are you sure? [y/n]: " -e -i n TTTT
          if [ "$TTTT" = "y" ]; then
            apt-get remove —purge —yes pure-ftpd
            apt-get —yes autoremove
          if [ -e /etc/pure-ftpd ]; then
            rm -rf /etc/pure-ftpd
          fi
          else
            echo "Closing now.." && exit
          fi
            exit
          ;;
        5) exit
          ;;
      esac
    done
  else
    read -p "Pure-FTP is not installed, install now? [y/n]: " -e -i y TT
  if [ "$TT" = "y" ]; then
    apt-get update -y && apt-get upgrade -y
    apt-get install pure-ftpd -y
    IP=$(curl ip.mtak.nl -4)
      cd /etc/pure-ftpd/conf
      touch ForcePassiveIP
      touch PassivePortRange
      echo -e "$IP" | tee -a /etc/pure-ftpd/conf/ForcePassiveIP
      echo -e "10110 10210" | tee -a /etc/pure-ftpd/conf/PassivePortRange
      perl -pi -e "s/1000/1/g" /etc/pure-ftpd/conf/MinUID
      perl -pi -e "s/yes/no/g" /etc/pure-ftpd/conf/PAMAuthentication
      ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
  else
      echo -e "${YELOW}Closing now..${NC}"
      sleep 5 && exit
  fi
    echo -e "\n${GREEN}Pure-FTP is installed. Please Re-open this script for create user.\n Closing now.. ${NC}\n"
    sleep 5 && exit
  fi
else
  echo -e "${YELOW}This script must be run on Debian or Ubuntu.${NC}"
  exit
fi


echo -e "${GREEN}End installation${NC}"

# exit
