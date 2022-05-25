#! /bin/bash





## -----------------------------
##    Меню
## -----------------------------

function menu {
  clear
  echo
  echo -e "\t\t====    Меню    ===="
  echo -e "\t1. Main Menu 1"
  echo -e "\t2. "
  echo -e "\t0. Выход"
  echo -en "\t\tВведите номер раздела: "
  read -n 1 option
}
# меню.
while [ $? -ne 1 ]
do
  menu
  case $option in
    0) echo "Quite";sleep 3; break ;;
    1) mainMENU ;;
    2) mainMENU_two ;;
    *) clear && echo "Нужно выбрать раздел"
    ;;
  esac
  echo -en "\n\n\t\t\tНажмите любую клавишу для продолжения";
  read -n 1 line
done
clear
