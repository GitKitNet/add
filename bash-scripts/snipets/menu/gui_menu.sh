#!/usr/bin/bash

GUI_main_menu(){

  dialog=$(dpkg-query -W -f='${Status}' dialog 2>/dev/null | grep -c "ok installed");
  if [ "${MC}" -eq 0 ]; then echo -e "${YELLOW}Installing mc${NC}" && sleep 2 && apt install dialog --yes;
  elif [ "${MC}" -eq 1 ]; then echo -e "${GREEN}mc - is installed!${NC}" && sleep 2;
  fi
  #---------------------------
  exec 3>&1
  RESULT=$(dialog --menu "Main Menu" 10 80 8 1 "Option 1" 2 "Option 2" 3 "Option 3" 4 "Option 4" 2>&1 >&3)
  exec 3>&-

case "$RESULT" in 
	1) echo "option one";sleep 5;;
	2) echo "oPtion two";sleep 5;;
	3) echo "opTion three";sleep 5;;
	4) echo "optIon 4 NEW";sleep 5;;
	5) echo "EXIT" && sleep 5 && exit 5 ;;
	*) echo -e -n "\n\tOpps!!! \nPlease Select Correct Choice!" ;
	   echo "Press ENTER To Continue...";
     read ;;
esac

};

GUI_main_menu
