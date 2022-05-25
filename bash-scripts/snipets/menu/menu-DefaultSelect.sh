#!/bin/bash


main_menu() {

while :
do
	clear
	echo " "
	echo "-------------------------------------"
	echo "            Main Menu "
	echo "-------------------------------------"
	echo "[1] Option 1"
	echo "[2] Option 2"
	echo "[3] Option 3"
	echo "[4] Option 4"
	echo "[0] Exit"
	echo "====================================="
	echo -e "Enter your menu choice [1-5] [Default :1]: \c "
	read m_menu
	
	case "$m_menu" in
		1) option_1  ;;
		2) option_2  ;;
		3) option_3  ;;
		4) option_4  ;;
		0) exit 0    ;;
    "") option_1 ;;
    *) echo -en "\nOpps!!!  Please Select Correct Choice! \n\t Press ENTER To Continue..." ; read ;;
	esac
done
}

option_1() {
  echo "option 1"
  echo -en "\nPress ENTER To Continue..."
    read
	return
}

option_2() {
	echo "option 2"
	echo -en "\nPress ENTER To Continue..."
    read
	return
}

option_3() {
	echo "option 3"
	echo -en "\nPress ENTER To Continue..."
    read
	return
}

option_4() {
	echo "option 4"
	echo -en "\nPress ENTER To Continue..."
    read
	return
}

main_menu

