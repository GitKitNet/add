#/bin/bash

# wget -O owncloud.sh https://raw.githubusercontent.com/numbnet/WebPanel/master/OwnCloud/owncloud.sh && chmod +x $HOME/owncloud.sh && $HOME/owncloud.sh

title=" Install ownCloud "

## -------------------
## Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'        # No Color

# ------------------------------
# VAR FUNCTION
OS="$( cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )"
release="$( cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )"

function TIMER() {
  if [ ! -z "$1" ]; then T="$1";
  elif [ -z "$1" ]; then T=10;
  fi;
  secs="$((1 * ${T}))"
  while [ $secs -gt 0 ]; do
    echo -ne " Wait: \t $secs\033[0K\r"
    sleep 1
    : $((secs--))
  done
}

function wait() { echo -e -n "${YELLOW}Press [ANY] key to continue...${NC}\n"; read -s -n 1; }
function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function title() { clear; echo -e "${GREEN}------- ${title} -------${NC}"; TIMER 10; }
function myip() {
  ipE="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
  ipW="$(echo $(curl -s -4 icanhazip.com))";
  ipH=$(hostname -I|cut -f1 -d ' ');
## -------
  if [ "$ipE" == "$ipW" ]; then myip="$ipE";
  elif [ "$ipH" == "$ipW" ]; then  myip="$ipH";
  else myip="$ipW";
  fi;
  echo "${myip}";
}



## ----------------------------------------
## OwnCloud START Installation
function STARTINSTALL() {
    if [ "${OS}" == 'ubuntu' ]; then
        if [[ "${release:0:2}" == 20 ]]; then
            echo "Ubuntu ${release:0:2}"
            wget -O owncloud.sh https://raw.githubusercontent.com/numbnet/WebPanel/master/owncloud/owncloud${release:0:2}.sh && chmod +x ./owncloud.sh && bash ./owncloud.sh
        elif [[ "${release:0:2}" == 18 ]]; then
            echo "Ubuntu ${release:0:2}"
            wget -O owncloud.sh https://raw.githubusercontent.com/numbnet/WebPanel/master/owncloud/owncloud${release:0:2}.sh && chmod +x ./owncloud.sh && bash ./owncloud.sh
        else
            echo "QUIT"
        fi
    else
        echo -en "Not install OwnCloud.\n\n OS: ${OS}\n\n RELEASE: ${release}"
        echo -en "Run new installation script"   
    fi
}

STARTINSTALL

