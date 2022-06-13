#!/bin/bash


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
function PUREFTP_RUN() {

clear
echo -e "${GREEN}Welcome to Pure-FTP Auto Installer Script${NC}"
echo ""

if [ "$(whoami)" != "root" ]; then
  echo -e "${RED}This script must be run as root${NC}"
  sleep 5
  exit
fi

# =============================
#          Var & Func
# =============================

function PUREFTP_AddNewUser() {
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
};

function PUREFTP_ChangeUserPass() {
          read -p "Enter the username: " -e CHNUSERNAME
          read -p "Enter password: " -e CHNPASSWORD
          echo -e "$CHNPASSWORD\\n$CHNPASSWORD" | pure-pw passwd $CHNUSERNAME -m
          pure-pw mkdb
}

function PUREFTP_DelUser() {
    read -p "Enter the username: " -e DELUSERNAME
          read -p "Are you sure? [y/n]: " -e -i n TTT
          if [ "$TTT" = "y" ]; then
            pure-pw userdel $DELUSERNAME -m
            pure-pw mkdb
          else
            echo "Closing now.."
            exit
          fi
}

function PUREFTP_Remove() {
    read -p "Are you sure? [y/n]: " -e -i n TTTT
          if [ "$TTTT" = "y" ]; then
            apt-get remove —purge —yes pure-ftpd
            apt-get —yes autoremove
          if [ -e /etc/pure-ftpd ]; then
            rm -rf /etc/pure-ftpd
          fi
          else
            echo "Closing now.." && exit
          fi
}
function PUREFTP_Install() {
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
}

function PUREFTP_mainMENU() {

echo -en "${GREEN}\nPure-FTP IS already INSTALLED.\n${NC}"
echo ""
echo -en "\n1) ${YELOW}Add a new user${NC}"
echo -en "\n2) ${YELOW}Change a user password${NC}"
echo -en "\n3) ${RED}Delete a user${NC}"
echo -en "\n4) ${PURPLE}Remove Pure-FTP and configurations${NC}"
echo -en "\n5) ${RED}Exit... ${NC}"
echo -en "\n\n${BLUE} Select an Option: ${NC}"
};



function PUREFTP_Option() {
  if [ -e /etc/pure-ftpd ]; then
    while :
    do
      PUREFTP_mainMENU
      read option
      case $option in
      
        1) # ADD NEW USER
         PUREFTP_AddNewUser; exit ;;
        2) #Change a user password
         PUREFTP_ChangeUserPass; exit ;;
        3) #Delete a user
         PUREFTP_DelUser; exit ;;
        4) # Remove Pure-FTP
          PUREFTP_Remove; exit ;;
        0) exit ;;

      esac
    done;

  else
   echo -e "\n\t {RED}Pure-FTP is not installed.{NC}\n"
   read -p "Install now Pure-FTP..? [y/n]: " -e -i y TT

    if [ "$TT" = "y" ]; then
     PUREFTP_Install;
    else
      echo -e "${YELOW}Closing now..${NC}";
      sleep 5 && exit;
    fi;

    echo -e "\n${GREEN}Pure-FTP is installed. Please Re-open this script for create user.\n Closing now.. ${NC}\n"
    sleep 5 && exit;
  fi;
}

if [ -e /etc/debian_version ]; then
  PUREFTP_Option
else
  echo -e "${YELOW}This script must be run on Debian or Ubuntu.${NC}"
  exit
fi;

echo -e "${GREEN}End installation${NC}"

};

PUREFTP_RUN

# exit

