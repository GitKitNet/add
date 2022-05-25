#!/bin/bash

normal=`echo "\033[m"`
menu=`echo "\033[36m"` #Blue
number=`echo "\033[33m"` #yellow
bgred=`echo "\033[41m"`
bggreen=`echo "\033[32m"`
fgred=`echo "\033[31m"`

function installs 
{
 option=0
 until [ "$option" = "3" ]; do
printf "\n	${bggreen}***** Installs *****${normal}\n"
printf "	${menu}**${number} 1)${menu} Update username ${normal}\n"
printf "	${menu}**${number} 2)${menu} Update password ${normal}\n"
printf "	${menu}**${number} 3)${menu} Return to menu ${normal}\n"
printf "	${bggreen}**********************${normal}\n"

 echo -n "Enter choice: "
 read option
 echo ""
 case $option in
 1 ) update_username; press_enter ;;
 2 ) update_password; press_enter ;;
 3 ) main_menu; press_enter ;;
 4 ) break ;;
 * ) tput setf 3;echo "Please enter 1, 2 or 3";tput setf 3; 
 esac
#   }
 done
}

function backups 
{
 option=0
 until [ "$option" = "3" ]; do
printf "\n	${bggreen}****** Backups ******${normal}\n"
printf "	${menu}**${number} 1)${menu} Update username ${normal}\n"
printf "	${menu}**${number} 2)${menu} Update password ${normal}\n"
printf "	${menu}**${number} 3)${menu} Return to menu ${normal}\n"
printf "	${bggreen}**********************${normal}\n"

 echo -n "Enter choice: "
 read option
 echo ""
 case $option in
 1 ) update_username; press_enter ;;
 2 ) update_password; press_enter ;;
 3 ) main_menu; press_enter ;;
 4 ) break ;;
 * ) tput setf 3;echo "Please enter 1, 2 or 3";tput setf 3; 
 esac
#   }
 done
}

function others 
{
 option=0
 until [ "$option" = "3" ]; do
printf "\n	${bggreen}****** Others ******${normal}\n"
printf "	${menu}**${number} 1)${menu} Update username ${normal}\n"
printf "	${menu}**${number} 2)${menu} Update password ${normal}\n"
printf "	${menu}**${number} 3)${menu} Return to menu ${normal}\n"
printf "	${bggreen}**********************${normal}\n"

 echo -n "Enter choice: "
 read option
 echo ""
 case $option in
 1 ) update_username; press_enter ;;
 2 ) update_password; press_enter ;;
 3 ) main_menu; press_enter ;;
 4 ) break ;;
 * ) tput setf 3;echo "Please enter 1, 2 or 3";tput setf 3; 
 esac
#   }
 done
}

function main_menu 
{
option=0
clear
until [ "$option" = "4" ]; do
printf "\n${bggreen}********************${normal}\n"
printf "${menu}**${number} 1)${menu} Installs ${normal}\n"
printf "${menu}**${number} 2)${menu} Backups ${normal}\n"
printf "${menu}**${number} 3)${menu} Others ${normal}\n"
printf "${menu}**${number} 4)${menu} Exit ${normal}\n"
printf "${bggreen}**********************${normal}\n"
printf "Please enter a menu option and enter or ${fgred}4 to exit: ${normal}"
# echo -n "Enter choice: "
read option
echo ""
case $option in
    1 ) installs ; press_enter ;;
    2 ) backups ; press_enter ;;
    3 ) others ; press_enter ;;
    4 ) exit;;
    * ) clear;tput setf 4;echo "Please enter 1, 2, 3, or 4";tput setf 4; 
esac
done
 }

main_menu
