#!/bin/bash
#set -x

title="Menu & Main Menu"


pause_func () {
while :; do
   read -n 1
   [[ $? = 0 ]] && break
done
}



task1-5 () {
clear
while :; do
cat << 'MENUITEM'
    1. alb
    2. bla
    b.  Back to Main Menu
MENUITEM
echo -n "Enter: "
read -n 1 NUMBER
  case $NUMBER in
    1) #
echo; cut -d: -f1,3 /etc/group | tee file | more
    ;;
    2) #
echo; find . -type f -name "*.sh"
    pause_func
    ;;
   b) #
main_menu
  ;;
  esac
done
}


task6-10 () {
clear
while :; do
cat << 'MENUITEM'
    6. blabla
    7. blabla
    b.  Back to Main Menu
MENUITEM
echo -n "Enter: "
read -n 1 NUMBER
  case $NUMBER in
    6) #
echo; comm -12 <(ls -1 dir1) <(ls -1 dir2) | sort
    pause_func
    ;;
    7) #
echo; find -L . -samefile fileee
    pause_func
    ;;
    q) #
echo; exit 0
    pause_func
  ;;
   b) #
main_menu
  ;;
  esac
done
}



main_menu () {
clear
while :; do
    cat << MENUITEM
  1) task1-5
  2) task6-10
  q) Quit
MENUITEM
echo -n "Enter: "
read -n 1 NUMBER
  case $NUMBER in
    1) task1-5
    ;;
    2) task6-10
    ;;
    q) echo; exit 0
    ;;
    *) echo;
echo "Please select 1, 2 ... or q for quit"
    ;;
  esac
done
}


main_menu 

## END ##
