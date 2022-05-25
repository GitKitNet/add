#!/bin/bash

# bash <(curl -L -fSs raw.githubusercontent.com/numbnet/WebPanel/master/bash-scripts/snipets/menu/mainmenu.sh)
# bash -c "$(curl -L -fSs raw.githubusercontent.com/numbnet/WebPanel/master/bash-scripts/snipets/menu/mainmenu.sh)"
# bash <(wget -O - raw.githubusercontent.com/numbnet/WebPanel/master/bash-scripts/snipets/menu/mainmenu.sh)

#  - - - - - - - - - - - - - - - - -
#            COLOR
#  - - - - - - - - - - - - - - - - -
NC="\033[0m"
GREEN="\033[32m";
RED="\033[1;31m";
BLUE="\033[1;34m";
YELOW="\033[1;33m";
PURPLE='\033[0;4;35m';
CYAN='\033[4;36m';
BLACK="\033[40m";
TEXTCOLOR=$GREEN;
BGCOLOR=$BLACK;

#  - - - - - - - - - - - - - - - - -
#      VARIABLE & function
#  - - - - - - - - - - - - - - - - -
#figlet -f smslant SSH Toolkit;
function showBanner() { clear; echo -e "
      ______            __ __    _  __
    /_  __/___  ___   / // /__ (_)/ /_
     / /  / _ \/ _ \ / //  '_// // __/
    /_/   \___/\___//_//_/\_\/_/ \__/
"; }
function title() { clear; echo "${title} ${TKEY}"; }
function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function wait() { read -p "Press [ANY] key to continue..? " -s -n 1; }
function TIMER() { if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; else T="5"; fi; SE="\033[0K\r"; E="$((1 * ${T}))"; while [ $E -gt 0 ]; do echo -en " Please wait: ${RED}$E$SE${NC}" && sleep 1 && : $((E--)); done; }

#========================
function MyCOMMANDS() {
      echo -e "\n\t ${GREEN} My COMMANDS ${NC} \n"
}



#  - - - - - - - - - - - - - - - - -  #
#          MENU and Main MENU         #
#  - - - - - - - - - - - - - - - - -  #
function BOSSMENU() {
      echo -e -n "\n\t${GREEN} MENU OPTIONS: ${NC}\n"
      echo -e -n "
\t1. MENU 1
\t2. MENU 2
\t2. MENU 3
\n\t${RED}q. Quit...       ${NC}";
      echo -n -e "\n\tSelection: "
      read -n1 opt;
}
#  - - - - - - - - - - - - - - - - -  
##   MainMENU 1
function SUBMENUONE() {
  echo -e "\n\t ${GREEN} MENU OPTIONS: Main MENU 1 ${NC} \n"
  echo -e -n "
\t1. MENU 1 | MainMENU 1
\t2. MENU 1 | MainMENU 2
\t3. MENU 1 | MainMENU 3
${RED}\n\t0. Back ${NC}\n";
  echo -n -e "\n\tSelection: "
  read -n1 opt;
}
#  - - - - - - - - - - - - - - - - -  
##   MainMENU 2
function SUBMENUTWO() {
  echo -e "\n\t ${GREEN} MENU OPTIONS: Main MENU 2 ${NC} \n"
  echo -e -n "
\t1. MENU 2 | MainMENU 1
\t2. MENU 2 | MainMENU 2
\t3. MENU 2 | MainMENU 3
${RED}\n\t0. Back ${NC}\n";
  echo -n -e "\n\tSelection: "
  read -n1 opt;
}
#  - - - - - - - - - - - - - - - - -  
##   MainMENU 3
function SUBMENUTHREE() {
  echo -e "\n\t ${GREEN} MENU OPTIONS: Main MENU 3 ${NC} \n"
  echo -e -n "
\t1. MENU 3 | MainMENU 1
\t2. MENU 3 | MainMENU 2
\t3. MENU 3 | MainMENU 3
${RED}\n\t0. Back ${NC}\n";
  echo -n -e "\n\tSelection: "
  read -n1 opt;
}
#  - - - - - - - - - - - - - - - - -  
while :
do
showBanner
BOSSMENU
a=true;
case $opt in

# = = = = = = = = =  MainMENU 1  = = = = = = = = = #
    1) echo -e "   MainMENU 1    "
    while :
    do
    showBanner
    SUBMENUONE
    case $opt in
      1) echo -e "MainMENU 1 | MENU 1" ;;
      2) echo -e "MainMENU 2 | MENU 1" ;;
      3) echo -e "MainMENU 3 | MENU 1" ;;
      /q | q | 0)break;;
      *) ;;
    esac
    done
    ;;

# = = = = = = = = =  MainMENU 2   = = = = = = = = = #
    2)  echo -e "   MainMENU 2    "
    while :
    do
    showBanner
    SUBMENUTWO

    case $opt in
      1) echo -e "MainMENU 1 | MENU 2" ;;
      2) echo -e "MainMENU 2 | MENU 2" ;;
      3) echo -e "MainMENU 3 | MENU 2" ;;
      /q | q | 0)break;;
      *) ;;
    esac
    done
    ;;


# = = = = = = = = =  MainMENU 3   = = = = = = = = = #
    3)  echo -e "   MainMENU 3    "
    while :
    do
    showBanner
    SUBMENUTHREE
    case $opt in
      1) echo -e "SUBmenu 1 | MENU 3" ;;
      2) echo -e "SUBmenu 2 | MENU 3" ;;
      3) echo -e "SUBmenu 3 | MENU 3" ;;
      /q | q | 0) break ;;
      *) ;;
    esac
    done
    ;;
  /q | q | 0) echo; break ;;
  *) ;;

esac
done
echo "Quit...";
clear;

# exit 1
